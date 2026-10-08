"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { AlertDialog, Button } from "@heroui/react";
import { createClient } from "@/lib/supabase/client";

export function DeleteReminderButton({ id, title, location }: { id: string; title: string; location: "list" | "detail" }) {
  const router = useRouter();
  const [isOpen, setIsOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  async function deleteReminder() {
    if (busy) return;
    setBusy(true);
    setErrorMessage("");

    try {
      const { data, error } = await createClient().from("reminders").delete().eq("id", id).select("id").maybeSingle();
      if (error || !data) {
        setErrorMessage("Reminder belum dapat dihapus. Coba lagi.");
        return;
      }

      setIsOpen(false);
      if (location === "detail") router.replace("/semua");
      else router.refresh();
    } catch {
      setErrorMessage("Koneksi bermasalah. Coba lagi.");
    } finally {
      setBusy(false);
    }
  }

  return <>
    <Button
      type="button"
      size="sm"
      variant="ghost"
      className={`delete-reminder-trigger delete-reminder-${location}`}
      onPress={() => { setErrorMessage(""); setIsOpen(true); }}
    >
      {location === "detail" ? "Hapus reminder" : "Hapus"}
    </Button>
    <AlertDialog.Backdrop variant="opaque" isOpen={isOpen} onOpenChange={(open) => { if (!busy) setIsOpen(open); }}>
      <AlertDialog.Container size="sm">
        <AlertDialog.Dialog className="delete-reminder-dialog">
          <AlertDialog.Header>
            <AlertDialog.Icon status="danger" />
            <AlertDialog.Heading>Hapus reminder?</AlertDialog.Heading>
          </AlertDialog.Header>
          <AlertDialog.Body>
            <p><strong>{title}</strong> dan seluruh riwayat aktivitasnya akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.</p>
            {errorMessage && <p className="delete-reminder-error" role="alert">{errorMessage}</p>}
          </AlertDialog.Body>
          <AlertDialog.Footer>
            <Button slot="close" variant="tertiary" isDisabled={busy}>Batal</Button>
            <Button variant="danger" onPress={() => void deleteReminder()} isDisabled={busy}>
              {busy ? "Menghapus…" : "Hapus reminder"}
            </Button>
          </AlertDialog.Footer>
        </AlertDialog.Dialog>
      </AlertDialog.Container>
    </AlertDialog.Backdrop>
  </>;
}
