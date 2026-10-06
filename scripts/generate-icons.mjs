import sharp from "sharp";

const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <rect width="512" height="512" rx="110" fill="#246b53"/>
  <path d="M154 365V158h55v36c18-27 43-41 79-41h8v58h-13c-46 0-73 29-73 78v76z" fill="#ffffff"/>
  <circle cx="365" cy="336" r="29" fill="#d9ebdf"/>
</svg>`;

await Promise.all([192, 512].map((size) =>
  sharp(Buffer.from(svg)).resize(size, size).png().toFile(`public/icon-${size}.png`)
));
console.log("Rootin PWA icons generated.");
