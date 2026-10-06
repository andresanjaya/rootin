import { NextResponse, type NextRequest } from "next/server";
import { createClient } from "@/lib/supabase/server";

export async function GET(request: NextRequest) {
  const code = request.nextUrl.searchParams.get("code");
  if (!code) return NextResponse.redirect(new URL("/login?error=callback", request.url));

  const supabase = await createClient();
  const { error } = await supabase.auth.exchangeCodeForSession(code);
  const response = NextResponse.redirect(new URL(error ? "/login?error=callback" : "/", request.url));
  response.headers.set("Cache-Control", "private, no-store");
  return response;
}
