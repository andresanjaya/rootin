import { fileURLToPath } from "node:url";
import sharp from "sharp";

const source = fileURLToPath(new URL("../assets/rootin-home-source.png", import.meta.url));
await Promise.all([180, 192, 512].map((size) =>
  sharp(source).resize(size, size).png().toFile(`public/rootin-home-${size}.png`)
));
console.log("Rootin PWA icons generated.");
