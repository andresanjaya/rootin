import Link from "next/link";
import type { ReminderView } from "@/lib/reminder-model";

export function ReminderList({ reminders }: { reminders: ReminderView[] }) {
  return (
    <ul className="reminder-list">
      {reminders.map((reminder) => (
        <li className="reminder-row" key={reminder.id} id={reminder.id}>
          <span className={`row-marker marker-${reminder.status}`} aria-hidden="true" />
          <div className="row-content">
            <div className="row-title-line">
              <h3><Link className="row-link" href={`/reminder/${reminder.id}`}>{reminder.title}</Link></h3>
              <span className="row-category">{reminder.category}</span>
            </div>
            <p className="row-description">{reminder.description}</p>
            <p className={`row-status status-${reminder.status}`}>{reminder.statusText}</p>
          </div>
        </li>
      ))}
    </ul>
  );
}
