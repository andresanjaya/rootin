import { randomBytes } from "node:crypto";
import { readFile, writeFile } from "node:fs/promises";
import webpush from "web-push";

const localPath = ".env.local";
const productionPath = ".env.production";
const local = await readFile(localPath, "utf8");
const production = await readFile(productionPath, "utf8");
const value = (source, name) => source.match(new RegExp(`^${name}=(.+)$`, "m"))?.[1]?.trim();

if (value(local, "NEXT_PUBLIC_PUSH_VAPID_PUBLIC_KEY") || value(local, "PUSH_VAPID_PRIVATE_KEY") || value(production, "NEXT_PUBLIC_PUSH_VAPID_PUBLIC_KEY")) {
  throw new Error("Push keys already exist. Keep the same pair across deployments; this script will not rotate them.");
}

const { publicKey, privateKey } = webpush.generateVAPIDKeys();
const cronSecret = randomBytes(32).toString("hex");
await writeFile(localPath, `${local.trimEnd()}\nNEXT_PUBLIC_PUSH_VAPID_PUBLIC_KEY=${publicKey}\nPUSH_VAPID_PRIVATE_KEY=${privateKey}\nCRON_SECRET=${cronSecret}\n`);
await writeFile(productionPath, `${production.trimEnd()}\nNEXT_PUBLIC_PUSH_VAPID_PUBLIC_KEY=${publicKey}\n`);
console.log("VAPID keys and CRON_SECRET saved. Copy PUSH_VAPID_PRIVATE_KEY and CRON_SECRET from .env.local to Vercel Production Environment Variables. Never commit .env.local.");
