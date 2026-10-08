import type { Metadata } from "next";
import Link from "next/link";
import { AppShell } from "@/components/app-shell";
import { ProfileForm } from "@/components/profile-form";
import { requireUser } from "@/lib/auth";

export const metadata: Metadata = { title: "Buat profil barang" };
export const dynamic = "force-dynamic";

export default async function NewProfilePage() {
  await requireUser();
  return <AppShell active="items">
    <Link className="text-link back-link" href="/barang">← Profil barang</Link>
    <div className="page-heading detail-heading"><div><p className="eyebrow">BARANG BARU</p><h1>Buat profil<span className="heading-period">.</span></h1><p className="page-intro">Kelompokkan reminder dan aktivitas untuk barang yang sama.</p></div></div>
    <ProfileForm />
  </AppShell>;
}
