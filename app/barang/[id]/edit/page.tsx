import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { AppShell } from "@/components/app-shell";
import { DataError } from "@/components/data-error";
import { ProfileForm } from "@/components/profile-form";
import { requireUser } from "@/lib/auth";
import type { ProfileRow } from "@/lib/profile-model";

export const metadata: Metadata = { title: "Edit profil barang" };
export const dynamic = "force-dynamic";

export default async function EditProfilePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  if (!/^[0-9a-f-]{36}$/i.test(id)) notFound();
  const { supabase, userId } = await requireUser();
  const { data, error } = await supabase.from("item_profiles").select("*").eq("id", id).eq("user_id", userId).maybeSingle();
  if (!data && !error) notFound();
  const profile = data as ProfileRow | null;
  return <AppShell active="items">
    {error || !profile ? <DataError /> : <>
      <Link className="text-link back-link" href={`/barang/${id}`}>← {profile.name}</Link>
      <div className="page-heading detail-heading"><div><p className="eyebrow">PROFIL BARANG</p><h1>Edit profil<span className="heading-period">.</span></h1></div></div>
      <ProfileForm profile={profile} />
    </>}
  </AppShell>;
}
