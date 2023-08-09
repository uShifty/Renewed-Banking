export const convertToCSV = (objArray: any[]): string => {
  const fields = Object.keys(objArray[0]);
  const replacer = (key: any, value: any) => (value === null ? "" : value);

  const csvRows = objArray.map((row) =>
    fields.map((fieldName) => JSON.stringify(row[fieldName], replacer)).join(",")
  );

  const csvContent = [fields.join(","), ...csvRows].join("\r\n");

  return csvContent;
};