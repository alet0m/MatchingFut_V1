export function formatRelative(iso: string): string {
  const date = new Date(iso);
  const now = new Date();
  const diff = (now.getTime() - date.getTime()) / 1000; // seconds
  if (diff < 60) return 'justo ahora';
  if (diff < 3600) {
    const m = Math.floor(diff / 60);
    return `${m} min`;
  }
  if (diff < 86400) {
    const h = Math.floor(diff / 3600);
    return `${h} h`;
  }
  const d = Math.floor(diff / 86400);
  return `${d} d`;
}
