import Link from "next/link";
import { Icon, type IconName } from "./icons";
import { SignOutButton } from "./sign-out-button";

type Tab = "today" | "all" | "items" | "history" | "settings";
const tabs: { id: Tab; label: string; href: string; icon: IconName }[] = [
  { id: "today", label: "Hari ini", href: "/", icon: "today" },
  { id: "all", label: "Semua", href: "/semua", icon: "all" },
  { id: "items", label: "Barang", href: "/barang", icon: "items" },
  { id: "history", label: "Riwayat", href: "/riwayat", icon: "history" },
];

function Navigation({ active, className }: { active: Tab; className: string }) {
  return (
    <nav className={className} aria-label="Navigasi utama">
      {tabs.map((tab) => (
        <Link key={tab.id} className={`nav-link ${active === tab.id ? "nav-link-active" : ""}`} href={tab.href} aria-current={active === tab.id ? "page" : undefined}>
          <Icon name={tab.icon} width={21} height={21} />
          <span>{tab.label}</span>
        </Link>
      ))}
    </nav>
  );
}

export function AppShell({ active, children }: { active: Tab; children: React.ReactNode }) {
  return (
    <div className="app-frame">
      <aside className="desktop-rail">
        <Link href="/" className="brand brand-desktop" aria-label="Rootin, ke Hari ini">rootin<span className="brand-dot">.</span></Link>
        <p className="rail-caption">Hal-hal rutin, tetap terurus.</p>
        <Navigation active={active} className="desktop-nav" />
        <div className="rail-foot"><Link className="settings-link" href="/pengaturan">Pengaturan</Link><SignOutButton /></div>
      </aside>

      <div className="app-content">
        <header className="mobile-header">
          <Link href="/" className="brand" aria-label="Rootin, ke Hari ini">rootin<span className="brand-dot">.</span></Link>
          <div className="mobile-header-actions"><Link className="settings-link" href="/pengaturan">Pengaturan</Link><SignOutButton /></div>
        </header>
        <main className="main-content" id="konten-utama">{children}</main>
      </div>
      <Navigation active={active} className="mobile-nav" />
    </div>
  );
}
