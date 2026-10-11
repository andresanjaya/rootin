import { Icon } from "./icons";
import type { ProfileRow } from "@/lib/profile-model";

export function ProfilePhoto({ profile, size }: { profile: Pick<ProfileRow, "id" | "name" | "photo_path" | "updated_at">; size: "thumb" | "detail" }) {
  return <span className={`profile-photo profile-photo-${size}`}>
    {profile.photo_path
      ? <img src={`/api/profile-photo/${profile.id}?v=${encodeURIComponent(profile.updated_at)}`} alt={profile.name} loading={size === "thumb" ? "lazy" : "eager"} />
      : <span role="img" aria-label={`Tanpa foto: ${profile.name}`}><Icon name="items" width={size === "thumb" ? 24 : 30} height={size === "thumb" ? 24 : 30} /></span>}
  </span>;
}
