import type { SVGProps } from "react";

export type IconName = "today" | "all" | "history" | "plus" | "arrow" | "calendar" | "inbox" | "check" | "clock" | "repeat" | "distance";

export function Icon({ name, ...props }: SVGProps<SVGSVGElement> & { name: IconName }) {
  const shared = { fill: "none", stroke: "currentColor", strokeWidth: 1.8, strokeLinecap: "round" as const, strokeLinejoin: "round" as const };
  const paths: Record<IconName, React.ReactNode> = {
    today: <><rect x="3" y="5" width="18" height="16" rx="2" /><path d="M7 3v4M17 3v4M3 10h18M8 15h3" /></>,
    all: <><path d="M4 5.5h16M4 12h16M4 18.5h16" /><circle cx="6" cy="5.5" r="1" fill="currentColor" stroke="none" /><circle cx="6" cy="12" r="1" fill="currentColor" stroke="none" /><circle cx="6" cy="18.5" r="1" fill="currentColor" stroke="none" /></>,
    history: <><path d="M3.5 12a8.5 8.5 0 1 0 2.4-5.9M3.5 5v4h4" /><path d="M12 7.5V12l3 2" /></>,
    plus: <path d="M12 5v14M5 12h14" />,
    arrow: <path d="m9 5 7 7-7 7" />,
    calendar: <><rect x="3" y="5" width="18" height="16" rx="2" /><path d="M7 3v4M17 3v4M3 10h18" /></>,
    inbox: <><path d="M4 5h16l2 11v4H2v-4L4 5Z" /><path d="M2 15h6l2 3h4l2-3h6" /></>,
    check: <path d="m5 12 4 4L19 6" />,
    clock: <><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></>,
    repeat: <><path d="M19 7H6a3 3 0 0 0-3 3v1M5 4l-3 3 3 3M5 17h13a3 3 0 0 0 3-3v-1M19 20l3-3-3-3" /></>,
    distance: <><path d="M4 18c2-5 3-12 8-12s6 7 8 12" /><circle cx="4" cy="18" r="2" /><circle cx="20" cy="18" r="2" /></>,
  };

  return <svg aria-hidden="true" viewBox="0 0 24 24" width="24" height="24" {...shared} {...props}>{paths[name]}</svg>;
}
