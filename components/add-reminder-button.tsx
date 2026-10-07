import { Icon } from "./icons";
import Link from "next/link";
import { buttonVariants } from "@heroui/react";

export function AddReminderButton() {
  return (
    <Link className={`${buttonVariants({ variant: "primary" })} add-button`} href="/baru">
      <Icon name="plus" width={18} height={18} />
      <span>Tambah reminder</span>
    </Link>
  );
}
