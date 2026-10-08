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
    background_color: "#f5f8fe",
    theme_color: "#1c64ef",
    icons: [
      { src: "/rootin-home-192.png", sizes: "192x192", type: "image/png" },
      { src: "/rootin-home-512.png", sizes: "512x512", type: "image/png" },
    ],
  };
}
