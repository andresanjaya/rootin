import { Icon } from "./icons";
import Link from "next/link";

export function AddReminderButton() {
  return (
    <Link className="add-button" href="/baru">
      <Icon name="plus" width={18} height={18} />
      <span>Tambah reminder</span>
    </Link>
  );
}
