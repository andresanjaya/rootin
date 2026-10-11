import type { SupabaseClient } from "@supabase/supabase-js";
import { matchesProfilePhotoType, PROFILE_PHOTO_BUCKET, profilePhotoPath, validateProfilePhoto } from "./profile-photo";

export class ProfilePhotoError extends Error {
  constructor(message: string, public status: number) { super(message); }
}

async function ownedProfile(supabase: SupabaseClient, userId: string, profileId: string) {
  const { data, error } = await supabase.from("item_profiles").select("id,photo_path")
    .eq("id", profileId).eq("user_id", userId).maybeSingle();
  if (error) throw new ProfilePhotoError("Profil belum dapat dibaca. Coba lagi.", 503);
  if (!data) throw new ProfilePhotoError("Profil tidak ditemukan.", 404);
  return data as { id: string; photo_path: string | null };
}

export async function downloadProfilePhoto(supabase: SupabaseClient, userId: string, profileId: string) {
  const profile = await ownedProfile(supabase, userId, profileId);
  if (!profile.photo_path) throw new ProfilePhotoError("Foto tidak ditemukan.", 404);
  if (profile.photo_path !== profilePhotoPath(userId, profileId)) throw new ProfilePhotoError("Referensi foto tidak valid.", 409);
  const { data, error } = await supabase.storage.from(PROFILE_PHOTO_BUCKET).download(profile.photo_path);
  if (error || !data) throw new ProfilePhotoError("Foto belum dapat dibuka.", 503);
  return data;
}

export async function uploadProfilePhoto(supabase: SupabaseClient, userId: string, profileId: string, file: File) {
  const validationError = validateProfilePhoto(file);
  if (validationError) throw new ProfilePhotoError(validationError, 400);
  if (!(await matchesProfilePhotoType(file))) throw new ProfilePhotoError("Isi file tidak sesuai format gambar.", 400);
  const profile = await ownedProfile(supabase, userId, profileId);
  const path = profilePhotoPath(userId, profileId);
  if (profile.photo_path && profile.photo_path !== path) throw new ProfilePhotoError("Referensi foto tidak valid.", 409);
  const { error: uploadError } = await supabase.storage.from(PROFILE_PHOTO_BUCKET)
    .upload(path, file, { upsert: true, contentType: file.type, cacheControl: "0" });
  if (uploadError) throw new ProfilePhotoError("Foto belum terunggah. Coba lagi.", 503);

  const { error: saveError } = await supabase.rpc("set_item_profile_photo", { p_profile_id: profileId, p_photo_path: path });
  if (saveError) {
    if (!profile.photo_path) await supabase.storage.from(PROFILE_PHOTO_BUCKET).remove([path]);
    throw new ProfilePhotoError("Foto belum terhubung ke profil. Coba lagi.", 503);
  }
}

export async function removeProfilePhoto(supabase: SupabaseClient, userId: string, profileId: string) {
  const profile = await ownedProfile(supabase, userId, profileId);
  if (!profile.photo_path) return;
  if (profile.photo_path !== profilePhotoPath(userId, profileId)) throw new ProfilePhotoError("Referensi foto tidak valid.", 409);
  const { error: removeError } = await supabase.storage.from(PROFILE_PHOTO_BUCKET).remove([profile.photo_path]);
  if (removeError) throw new ProfilePhotoError("Foto belum terhapus. Coba lagi.", 503);
  const { error: saveError } = await supabase.rpc("set_item_profile_photo", { p_profile_id: profileId, p_photo_path: null });
  if (saveError) throw new ProfilePhotoError("Perubahan foto belum tersimpan. Coba lagi.", 503);
}
