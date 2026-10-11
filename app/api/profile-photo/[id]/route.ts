import { createClient } from "@/lib/supabase/server";
import { downloadProfilePhoto, ProfilePhotoError, removeProfilePhoto, uploadProfilePhoto } from "@/lib/profile-photo-service";
import { PROFILE_PHOTO_MAX_BYTES } from "@/lib/profile-photo";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

async function context(params: Promise<{ id: string }>) {
  const { id } = await params;
  if (!uuidPattern.test(id)) throw new ProfilePhotoError("Profil tidak valid.", 400);
  const supabase = await createClient();
  const { data, error } = await supabase.auth.getUser();
  if (error || !data.user) throw new ProfilePhotoError("Masuk untuk mengakses foto.", 401);
  return { id, supabase, userId: data.user.id };
}

function failure(error: unknown) {
  if (error instanceof ProfilePhotoError) return Response.json({ error: error.message }, { status: error.status, headers: { "Cache-Control": "private, no-store" } });
  console.error("Rootin profile photo failed:", error);
  return Response.json({ error: "Foto belum dapat diproses. Coba lagi." }, { status: 500, headers: { "Cache-Control": "private, no-store" } });
}

function sameOrigin(request: Request) {
  const origin = request.headers.get("origin");
  return request.headers.get("sec-fetch-site") !== "cross-site" && (!origin || origin === new URL(request.url).origin);
}

export async function GET(_request: Request, { params }: { params: Promise<{ id: string }> }) {
  try {
    const { id, supabase, userId } = await context(params);
    const photo = await downloadProfilePhoto(supabase, userId, id);
    return new Response(photo, { headers: {
      "Content-Type": photo.type,
      "Cache-Control": "private, no-store",
      "X-Content-Type-Options": "nosniff",
    } });
  } catch (error) { return failure(error); }
}

export async function POST(request: Request, { params }: { params: Promise<{ id: string }> }) {
  if (!sameOrigin(request)) return Response.json({ error: "Permintaan ditolak." }, { status: 403 });
  const length = Number(request.headers.get("content-length"));
  if (length > PROFILE_PHOTO_MAX_BYTES + 256 * 1024) return Response.json({ error: "Ukuran foto maksimal 4 MB." }, { status: 413 });
  try {
    const { id, supabase, userId } = await context(params);
    const form = await request.formData();
    const photo = form.get("photo");
    if (!(photo instanceof File)) throw new ProfilePhotoError("Pilih foto terlebih dahulu.", 400);
    await uploadProfilePhoto(supabase, userId, id, photo);
    return Response.json({ ok: true });
  } catch (error) { return failure(error); }
}

export async function DELETE(request: Request, { params }: { params: Promise<{ id: string }> }) {
  if (!sameOrigin(request)) return Response.json({ error: "Permintaan ditolak." }, { status: 403 });
  try {
    const { id, supabase, userId } = await context(params);
    await removeProfilePhoto(supabase, userId, id);
    return Response.json({ ok: true });
  } catch (error) { return failure(error); }
}
