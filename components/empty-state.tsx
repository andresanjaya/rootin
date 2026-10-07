import { Icon } from "./icons";
import { Card } from "@heroui/react";

export function EmptyState({ title, description, action }: { title: string; description: string; action?: React.ReactNode }) {
  return (
    <Card className="empty-state" variant="transparent">
      <div className="empty-icon"><Icon name="inbox" width={25} height={25} /></div>
      <Card.Header>
        <Card.Title>{title}</Card.Title>
        <Card.Description>{description}</Card.Description>
      </Card.Header>
      {action && <Card.Footer className="empty-action">{action}</Card.Footer>}
    </Card>
  );
}
