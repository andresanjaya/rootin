import { describe, expect, it, vi } from "vitest";
import type { SupabaseClient } from "@supabase/supabase-js";
import { downloadProfilePhoto, ProfilePhotoError, removeProfilePhoto, uploadProfilePhoto } from "./profile-photo-service";
import { PROFILE_PHOTO_MAX_BYTES, profilePhotoPath, validateProfilePhoto } from "./profile-photo";
import { prepareProfilePhoto } from "./profile-photo-client";

const userId = "aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa";
const otherUserId = "bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb";
const profileId = "cccccccc-cccc-4ccc-cccc-cccccccccccc";
const path = profilePhotoPath(userId, profileId);
const jpeg = () => new File([new Uint8Array([0xff, 0xd8, 0xff, 0x00])], "foto.jpg", { type: "image/jpeg" });

function fakeClient(photoPath: string | null, exists = true) {
  const maybeSingle = vi.fn().mockResolvedValue({ data: exists ? { id: profileId, photo_path: photoPath } : null, error: null });
  const eq = vi.fn().mockReturnThis();
  const select = vi.fn().mockReturnValue({ eq, maybeSingle });
  const upload = vi.fn().mockResolvedValue({ error: null });
  const remove = vi.fn().mockResolvedValue({ error: null });
  const download = vi.fn().mockResolvedValue({ data: new Blob(["image"], { type: "image/jpeg" }), error: null });
  const rpc = vi.fn().mockResolvedValue({ error: null });
  const storageFrom = vi.fn().mockReturnValue({ upload, remove, download });
  const client = { from: vi.fn().mockReturnValue({ select }), storage: { from: storageFrom }, rpc } as unknown as SupabaseClient;
  return { client, eq, upload, remove, download, rpc, storageFrom };
}

describe("private profile photos", () => {
  it("validates format, size, and actual file signature", async () => {
    expect(validateProfilePhoto({ type: "image/svg+xml", size: 100 })).toContain("JPG");
    expect(validateProfilePhoto({ type: "image/jpeg", size: PROFILE_PHOTO_MAX_BYTES + 1 })).toContain("4 MB");
    const fake = fakeClient(null);
    await expect(uploadProfilePhoto(fake.client, userId, profileId, new File(["text"], "fake.jpg", { type: "image/jpeg" }))).rejects.toMatchObject({ status: 400 });
    expect(fake.upload).not.toHaveBeenCalled();
    await expect(prepareProfilePhoto(jpeg())).resolves.toBeInstanceOf(File);
    await expect(prepareProfilePhoto(new File(["text"], "text.svg", { type: "image/svg+xml" }))).rejects.toThrow("JPG");
  });

  it("uploads to one owner/profile path and saves the reference", async () => {
    const fake = fakeClient(null);
    await uploadProfilePhoto(fake.client, userId, profileId, jpeg());
    expect(fake.eq).toHaveBeenCalledWith("user_id", userId);
    expect(fake.upload).toHaveBeenCalledWith(path, expect.any(File), expect.objectContaining({ upsert: true, contentType: "image/jpeg" }));
    expect(fake.rpc).toHaveBeenCalledWith("set_item_profile_photo", { p_profile_id: profileId, p_photo_path: path });
    expect(fake.remove).not.toHaveBeenCalled();
  });

  it("replaces at the same path without leaving an old file, and cleans up a failed first save", async () => {
    const replacement = fakeClient(path);
    await uploadProfilePhoto(replacement.client, userId, profileId, jpeg());
    expect(replacement.upload).toHaveBeenCalledWith(path, expect.any(File), expect.objectContaining({ upsert: true }));
    expect(replacement.remove).not.toHaveBeenCalled();

    const failed = fakeClient(null);
    failed.rpc.mockResolvedValue({ error: new Error("database") });
    await expect(uploadProfilePhoto(failed.client, userId, profileId, jpeg())).rejects.toBeInstanceOf(ProfilePhotoError);
    expect(failed.remove).toHaveBeenCalledWith([path]);
  });

  it("removes only the image and clears its reference, without touching the profile", async () => {
    const fake = fakeClient(path);
    await removeProfilePhoto(fake.client, userId, profileId);
    expect(fake.remove).toHaveBeenCalledWith([path]);
    expect(fake.rpc).toHaveBeenCalledWith("set_item_profile_photo", { p_profile_id: profileId, p_photo_path: null });
    expect(fake.client.from).toHaveBeenCalledWith("item_profiles");
  });

  it("keeps the reference when Storage cannot remove the image, so deletion can be retried", async () => {
    const fake = fakeClient(path);
    fake.remove.mockResolvedValue({ error: new Error("storage unavailable") });
    await expect(removeProfilePhoto(fake.client, userId, profileId)).rejects.toMatchObject({ status: 503 });
    expect(fake.rpc).not.toHaveBeenCalled();
  });

  it("downloads only the owned profile's referenced object", async () => {
    const fake = fakeClient(path);
    const photo = await downloadProfilePhoto(fake.client, userId, profileId);
    expect(photo.type).toBe("image/jpeg");
    expect(fake.download).toHaveBeenCalledWith(path);
  });

  it("does not download or change another user's photo", async () => {
    const fake = fakeClient(null, false);
    await expect(downloadProfilePhoto(fake.client, otherUserId, profileId)).rejects.toMatchObject({ status: 404 });
    await expect(uploadProfilePhoto(fake.client, otherUserId, profileId, jpeg())).rejects.toMatchObject({ status: 404 });
    await expect(removeProfilePhoto(fake.client, otherUserId, profileId)).rejects.toMatchObject({ status: 404 });
    expect(fake.eq).toHaveBeenCalledWith("user_id", otherUserId);
    expect(fake.download).not.toHaveBeenCalled();
    expect(fake.upload).not.toHaveBeenCalled();
    expect(fake.remove).not.toHaveBeenCalled();
  });
});
