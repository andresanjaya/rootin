import type { Metadata } from "next";
import Link from "next/link";
import { Card, Chip } from "@heroui/react";
import { AppShell } from "@/components/app-shell";
import { DataError } from "@/components/data-error";
import { EmptyState } from "@/components/empty-state";
import { requireUser } from "@/lib/auth";
import { getProfiles } from "@/lib/profile-data";
import { partitionProfiles, profileCategoryLabels, profileNearestStatus, profileReminderViews, type ProfileRow } from "@/lib/profile-model";
import { getReminders } from "@/lib/reminder-data";
import { todayISO, type ReminderRow } from "@/lib/reminder-model";

export const metadata: Metadata = { title: "Profil barang" };
export const dynamic = "force-dynamic";

function ProfileList({ profiles, reminders, today }: { profiles: ProfileRow[]; reminders: ReminderRow[]; today: string }) {
  return <ul className="profile-list">
    {profiles.map((profile) => {
      const views = profileReminderViews(profile.id, reminders, today);
      return <li key={profile.id}>
        <Card className="profile-list-card" variant="default">
          <Card.Header>
            <div className="profile-card-top"><Card.Title><Link className="profile-card-link" href={`/barang/${profile.id}`}>{profile.name}</Link></Card.Title><Chip size="sm" variant="tertiary">{profileCategoryLabels[profile.category]}</Chip></div>
            <Card.Description>{views.length} reminder aktif</Card.Description>
          </Card.Header>
          <Card.Content><p className="profile-nearest">{profileNearestStatus(views)}</p></Card.Content>
        </Card>
      </li>;
    })}
  </ul>;
}

export default async function ProfilesPage() {
  const { supabase, userId } = await requireUser();
  const [profileResult, reminderResult] = await Promise.all([getProfiles(supabase, userId, true), getReminders(supabase, userId, true)]);
  const { active, archived } = partitionProfiles(profileResult.profiles);
  const today = todayISO();
  return <AppShell active="items">
    <div className="page-heading"><div><p className="eyebrow">BARANG YANG DIRAWAT</p><h1>Profil barang<span className="heading-period">.</span></h1><p className="page-intro">Kumpulkan reminder dan catatan aktivitas untuk setiap barang.</p></div><Link className="add-button" href="/barang/baru">+ Buat profil</Link></div>
    {profileResult.error || reminderResult.error ? <DataError /> : <>
      {active.length ? <section className="content-section all-section" aria-labelledby="profiles-active-heading"><div className="section-heading"><div><p className="section-kicker">AKTIF</p><h2 id="profiles-active-heading">Barang saya</h2></div><Chip size="sm" variant="tertiary" className="section-count">{active.length}</Chip></div><ProfileList profiles={active} reminders={reminderResult.reminders} today={today} /></section>
        : <EmptyState title={archived.length ? "Belum ada profil aktif" : "Belum ada profil barang"} description="Buat profil untuk mengelompokkan reminder dan aktivitas barang yang sama." action={<Link className="text-link" href="/barang/baru">Buat profil</Link>} />}
      {archived.length > 0 && <section className="content-section profile-archived-section" aria-labelledby="profiles-archived-heading"><div className="section-heading"><div><p className="section-kicker">TERSIMPAN</p><h2 id="profiles-archived-heading">Diarsipkan</h2></div><Chip size="sm" variant="tertiary" className="section-count">{archived.length}</Chip></div><ProfileList profiles={archived} reminders={reminderResult.reminders} today={today} /></section>}
    </>}
  </AppShell>;
}
