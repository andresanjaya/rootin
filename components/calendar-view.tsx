"use client";

import { useEffect, useState } from "react";
import { Button } from "@heroui/react";
import { calendarMonthDays, calendarReminders, remindersOnDate, shiftCalendarMonth } from "@/lib/calendar-model";
import { todayISO, type ReminderRow } from "@/lib/reminder-model";
import { ReminderList } from "./reminder-list";
import { Icon } from "./icons";

const weekdays = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];

function formatDate(date: string, options: Intl.DateTimeFormatOptions) {
  return new Intl.DateTimeFormat("id-ID", { timeZone: "UTC", ...options }).format(new Date(`${date}T00:00:00Z`));
}

export function CalendarView({ reminders, initialToday }: { reminders: ReminderRow[]; initialToday: string }) {
  const [today, setToday] = useState(initialToday);
  const [timeZone, setTimeZone] = useState("Asia/Makassar");
  const [month, setMonth] = useState(initialToday.slice(0, 7));
  const [selected, setSelected] = useState<string | null>(initialToday);

  useEffect(() => {
    const zone = Intl.DateTimeFormat().resolvedOptions().timeZone || "Asia/Makassar";
    const localToday = todayISO(zone);
    setTimeZone(zone);
    setToday(localToday);
    setMonth(localToday.slice(0, 7));
    setSelected(localToday);
  }, []);

  const { dated, undated, overdue } = calendarReminders(reminders, today);
  const dates = calendarMonthDays(month);
  const counts = new Map<string, number>();
  for (const reminder of dated) counts.set(reminder.dueDate!, (counts.get(reminder.dueDate!) ?? 0) + 1);
  const chosen = selected ? remindersOnDate(dated, selected) : [];

  function changeMonth(offset: number) {
    setMonth((current) => shiftCalendarMonth(current, offset));
    setSelected(null);
  }

  return <>
    {overdue.length > 0 && <a className="calendar-overdue-link" href="#reminder-terlambat"><strong>{overdue.length} reminder terlambat</strong><span>Lihat daftar</span><Icon name="arrow" width={16} height={16} /></a>}
    <section className="calendar-panel" aria-label="Kalender jatuh tempo">
      <div className="calendar-toolbar">
        <div><p className="section-kicker">JATUH TEMPO</p><h2>{formatDate(`${month}-01`, { month: "long", year: "numeric" })}</h2></div>
        <div className="calendar-controls">
          <Button type="button" variant="tertiary" className="calendar-control" onPress={() => changeMonth(-1)}>Sebelumnya</Button>
          <Button type="button" variant="secondary" className="calendar-control" onPress={() => { setMonth(today.slice(0, 7)); setSelected(today); }}>Hari ini</Button>
          <Button type="button" variant="tertiary" className="calendar-control" onPress={() => changeMonth(1)}>Berikutnya</Button>
        </div>
      </div>
      <div className="calendar-grid">
        {weekdays.map((day) => <span className="calendar-weekday" key={day}>{day}</span>)}
        {dates.map((date, index) => date
          ? <button key={date} type="button" className={`calendar-day ${date === today ? "calendar-day-today" : ""} ${date === selected ? "calendar-day-selected" : ""}`} onClick={() => setSelected(date)} aria-pressed={date === selected} aria-current={date === today ? "date" : undefined} aria-label={`${formatDate(date, { weekday: "long", day: "numeric", month: "long", year: "numeric" })}, ${counts.get(date) ?? 0} reminder${counts.has(date) ? date < today ? ", terlambat" : date === today ? ", jatuh tempo hari ini" : ", mendatang" : ""}`}>
              <span>{Number(date.slice(-2))}</span>{counts.has(date) && <span className="calendar-day-count" aria-hidden="true">{counts.get(date)}</span>}
            </button>
          : <span className="calendar-day-blank" aria-hidden="true" key={`blank-${index}`} />)}
      </div>
      <p className="calendar-timezone">Tanggal mengikuti zona waktu perangkat: {timeZone}.</p>
    </section>

    <section className="content-section calendar-selection" aria-live="polite" aria-labelledby="calendar-selection-heading">
      <div className="section-heading"><div><p className="section-kicker">TANGGAL DIPILIH</p><h2 id="calendar-selection-heading">{selected ? formatDate(selected, { weekday: "long", day: "numeric", month: "long", year: "numeric" }) : "Pilih tanggal"}</h2></div><span className="section-count">{chosen.length}</span></div>
      {selected ? chosen.length ? <ReminderList reminders={chosen} /> : <p className="section-empty">Tidak ada reminder jatuh tempo pada tanggal ini.</p> : <p className="section-empty">Pilih satu tanggal untuk melihat reminder.</p>}
    </section>

    {overdue.length > 0 && <section id="reminder-terlambat" className="content-section" aria-labelledby="overdue-heading"><div className="section-heading"><div><p className="section-kicker">PERLU PERHATIAN</p><h2 id="overdue-heading">Terlambat</h2></div><span className="section-count">{overdue.length}</span></div><ReminderList reminders={overdue} /></section>}

    {undated.length > 0 && <section className="content-section" aria-labelledby="undated-heading"><div className="section-heading"><div><p className="section-kicker">TANPA TANGGAL</p><h2 id="undated-heading">Pemakaian &amp; jarak</h2></div><span className="section-count">{undated.length}</span></div><p className="calendar-section-help">Reminder ini menunggu pemakaian atau pembaruan odometer, sehingga tidak diberi tanggal kalender.</p><ReminderList reminders={undated} /></section>}
  </>;
}
