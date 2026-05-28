export const getLocalDayKey = (date = new Date()) => {
  const year = date.getFullYear();
  const month = `${date.getMonth() + 1}`.padStart(2, '0');
  const day = `${date.getDate()}`.padStart(2, '0');
  return `${year}-${month}-${day}`;
};

const startOfLocalDay = (date: Date) => new Date(date.getFullYear(), date.getMonth(), date.getDate()).getTime();

export const getLocalWeekKey = (date = new Date()) => {
  const dayStart = startOfLocalDay(date);
  const day = date.getDay() || 7;
  const monday = new Date(dayStart - (day - 1) * 24 * 60 * 60 * 1000);
  return getLocalDayKey(monday);
};

export const getWeeklyEventIndex = (count: number, date = new Date()) => {
  const monday = new Date(getLocalWeekKey(date));
  const epochMonday = new Date(2024, 0, 1).getTime();
  const weeks = Math.max(0, Math.floor((monday.getTime() - epochMonday) / (7 * 24 * 60 * 60 * 1000)));
  return weeks % count;
};

export const getEventTimeRemainingLabel = (date = new Date()) => {
  const day = date.getDay() || 7;
  const daysLeft = 7 - day;
  const end = new Date(date.getFullYear(), date.getMonth(), date.getDate() + daysLeft + 1, 0, 0, 0);
  const ms = Math.max(0, end.getTime() - date.getTime());
  const hours = Math.floor(ms / (60 * 60 * 1000));
  const days = Math.floor(hours / 24);
  const remainingHours = hours % 24;
  return days > 0 ? `${days}d ${remainingHours}h` : `${remainingHours}h`;
};
