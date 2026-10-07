import Link from "next/link";
import { Card, Chip } from "@heroui/react";
import type { ReminderView } from "@/lib/reminder-model";

export function ReminderList({ reminders }: { reminders: ReminderView[] }) {
  return (
    <ul className="reminder-list">
      {reminders.map((reminder) => (
        <li className="reminder-item" key={reminder.id} id={reminder.id}>
          <Card className="reminder-card" variant="default">
            <Card.Header className="reminder-card-header">
              <span className={`row-marker marker-${reminder.status}`} aria-hidden="true" />
              <div className="row-title-line">
                <Card.Title><Link className="row-link" href={`/reminder/${reminder.id}`}>{reminder.title}</Link></Card.Title>
                <Chip className="row-category" size="sm" variant="tertiary">{reminder.category}</Chip>
              </div>
            </Card.Header>
            <Card.Content className="reminder-card-content">
              <Card.Description className="row-description">{reminder.description}</Card.Description>
              <p className={`row-status status-${reminder.status}`}>{reminder.statusText}</p>
            </Card.Content>
          </Card>
        </li>
      ))}
    </ul>
  );
}
