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

export function getReadableDateFromTimestampSecond(timestamp: number): string {
  const date = new Date(timestamp * 1000);

  // Construire la date au format "MMM dd, yyyy"
  const formattedDate = date.toLocaleDateString("en-US", {
    year: "numeric",
    month: "short",
    day: "numeric",
  });

  // Construire l'heure au format "HH:mm"
  const hours = date.getHours().toString().padStart(2, "0");
  const minutes = date.getMinutes().toString().padStart(2, "0");
  const formattedTime = `${hours}:${minutes}`;

  // Combiner les parties pour obtenir la chaîne de date finale
  return `${formattedDate} ${formattedTime}`;
}

export const weiToEth = (weiValue: any) => {
  return Number(weiValue / 10n ** 18n);
};
