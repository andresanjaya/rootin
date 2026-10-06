import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    id: "/",
    name: "Rootin",
    short_name: "Rootin",
    description: "Pengingat rutin pribadi",
    start_url: "/",
    scope: "/",
    display: "standalone",
    background_color: "#f6f7f3",
    theme_color: "#246b53",
    icons: [
      { src: "/icon-192.png", sizes: "192x192", type: "image/png" },
      { src: "/icon-512.png", sizes: "512x512", type: "image/png" },
    ],
  };
}
