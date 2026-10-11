export const PROFILE_PHOTO_BUCKET = "rootin-profile-photos";
export const PROFILE_PHOTO_MAX_BYTES = 4 * 1024 * 1024;
export const PROFILE_PHOTO_TYPES = ["image/jpeg", "image/png", "image/webp"] as const;

export function profilePhotoPath(userId: string, profileId: string) {
  return `${userId}/${profileId}/photo`;
}

export function validateProfilePhoto(file: Pick<File, "type" | "size">): string | null {
  if (!PROFILE_PHOTO_TYPES.some((type) => type === file.type)) return "Gunakan foto JPG, PNG, atau WebP.";
  if (file.size === 0) return "Foto kosong. Pilih gambar lain.";
  if (file.size > PROFILE_PHOTO_MAX_BYTES) return "Ukuran foto maksimal 4 MB.";
  return null;
}

export async function matchesProfilePhotoType(file: File) {
  const bytes = new Uint8Array(await file.slice(0, 12).arrayBuffer());
  if (file.type === "image/jpeg") return bytes.length >= 3 && bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff;
  if (file.type === "image/png") return bytes.length >= 8 && [137, 80, 78, 71, 13, 10, 26, 10].every((byte, index) => bytes[index] === byte);
  if (file.type === "image/webp") return bytes.length >= 12 && String.fromCharCode(...bytes.slice(0, 4)) === "RIFF" && String.fromCharCode(...bytes.slice(8, 12)) === "WEBP";
  return false;
}
