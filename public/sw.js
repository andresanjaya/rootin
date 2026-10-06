/* Rootin uses this worker only for push; page caching is intentionally omitted. */
self.addEventListener("push", (event) => {
  let payload = {};
  try { payload = event.data ? event.data.json() : {}; } catch { /* Use generic message. */ }
  const path = typeof payload.url === "string" && /^\/reminder\/[0-9a-f-]{36}$/i.test(payload.url) ? payload.url : "/";
  event.waitUntil(self.registration.showNotification("Rootin", {
    body: typeof payload.body === "string" ? payload.body.slice(0, 160) : "Ada pengingat untukmu.",
    icon: "/icon-192.png",
    badge: "/icon-192.png",
    tag: typeof payload.tag === "string" ? payload.tag : "rootin",
    data: { path },
  }));
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const path = event.notification.data?.path || "/";
  event.waitUntil((async () => {
    const windows = await clients.matchAll({ type: "window", includeUncontrolled: true });
    const target = new URL(path, self.location.origin).href;
    for (const windowClient of windows) {
      if (windowClient.url === target) return windowClient.focus();
    }
    return clients.openWindow(target);
  })());
});
