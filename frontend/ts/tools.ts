export function getReadableDate() {
  var date = new Date();

  var dateFormatted = date.toLocaleString("fr-FR", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  });
  return dateFormatted;
}
