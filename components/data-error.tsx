import { EmptyState } from "./empty-state";

export function DataError() {
  return <EmptyState title="Data belum bisa dimuat" description="Periksa koneksi dan pastikan migrasi database Rootin sudah diterapkan di Supabase." />;
}
