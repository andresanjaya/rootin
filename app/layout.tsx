import type { Metadata, Viewport } from "next";
import { Analytics } from "@vercel/analytics/next";
import "./globals.css";

export const metadata: Metadata = {
  title: { default: "Rootin", template: "%s · Rootin" },
  description: "Pengingat sederhana untuk hal-hal yang perlu dirawat dan diganti secara berkala.",
  appleWebApp: { capable: true, title: "Rootin", statusBarStyle: "default" },
  icons: { apple: "/rootin-home-180.png" },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  viewportFit: "cover",
  themeColor: "#1c64ef",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="id">
      <body>
        {children}
        <Analytics />
      </body>
    </html>
  );
}
