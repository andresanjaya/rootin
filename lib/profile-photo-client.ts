import { PROFILE_PHOTO_MAX_BYTES, PROFILE_PHOTO_TYPES, validateProfilePhoto } from "./profile-photo";

const convertibleTypes = new Set<string>([...PROFILE_PHOTO_TYPES, "image/heic", "image/heif"]);

function readImage(file: File) {
  return new Promise<HTMLImageElement>((resolve, reject) => {
    const url = URL.createObjectURL(file);
    const image = new Image();
    image.onload = () => { URL.revokeObjectURL(url); resolve(image); };
    image.onerror = () => { URL.revokeObjectURL(url); reject(new Error("Foto tidak dapat dibuka di perangkat ini. Pilih JPG, PNG, atau WebP.")); };
    image.src = url;
  });
}

function jpegBlob(canvas: HTMLCanvasElement, quality: number) {
  return new Promise<Blob>((resolve, reject) => {
    canvas.toBlob((blob) => blob ? resolve(blob) : reject(new Error("Foto tidak dapat disiapkan. Coba gambar lain.")), "image/jpeg", quality);
  });
}

export async function prepareProfilePhoto(file: File): Promise<File> {
  const type = file.type || (/\.heic$/i.test(file.name) ? "image/heic" : /\.heif$/i.test(file.name) ? "image/heif" : "");
  if (!convertibleTypes.has(type)) throw new Error("Gunakan foto JPG, PNG, WebP, atau HEIC dari kamera.");
  if (file.size === 0) throw new Error("Foto kosong. Pilih gambar lain.");
  if (PROFILE_PHOTO_TYPES.some((supported) => supported === type) && file.size <= PROFILE_PHOTO_MAX_BYTES) return file;

  const image = await readImage(file);
  const scale = Math.min(1, 1800 / Math.max(image.naturalWidth, image.naturalHeight));
  const canvas = document.createElement("canvas");
  canvas.width = Math.max(1, Math.round(image.naturalWidth * scale));
  canvas.height = Math.max(1, Math.round(image.naturalHeight * scale));
  const context = canvas.getContext("2d");
  if (!context) throw new Error("Foto tidak dapat disiapkan di perangkat ini.");
  context.fillStyle = "#ffffff";
  context.fillRect(0, 0, canvas.width, canvas.height);
  context.drawImage(image, 0, 0, canvas.width, canvas.height);
  for (const quality of [0.85, 0.7, 0.55]) {
    const blob = await jpegBlob(canvas, quality);
    const prepared = new File([blob], "foto-profil.jpg", { type: "image/jpeg" });
    if (!validateProfilePhoto(prepared)) return prepared;
  }
  throw new Error("Foto masih terlalu besar. Pilih gambar lain.");
}
