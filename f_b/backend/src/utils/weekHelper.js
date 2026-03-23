exports.getWeekLabel = (dateStr) => {
  if (!dateStr) return "";

  const date = new Date(dateStr);

  // ISO Week Calculation
  const firstDay = new Date(date.getFullYear(), 0, 1);
  const pastDays = Math.floor((date - firstDay) / (1000 * 60 * 60 * 24));

  const week = Math.ceil((pastDays + firstDay.getDay() + 1) / 7);

  return `Week ${week}/${date.getFullYear()}`;
};
