(() => {
  const explorer = document.querySelector("[data-relationship-explorer]");
  if (!explorer) return;

  const work = explorer.querySelector("[data-relationship-work]");
  const thread = explorer.querySelector("[data-relationship-thread]");
  const showAll = explorer.querySelector("[data-relationship-all]");
  const status = document.querySelector("[data-relationship-status]");
  const heading = document.querySelector("[data-relationship-heading]");
  const records = [...document.querySelectorAll("[data-relationship-record]")];
  explorer.hidden = false;

  const applyFilter = (kind, value) => {
    let shown = 0;
    records.forEach((record) => {
      const matches = !value || (kind === "work"
        ? record.dataset.source === value || record.dataset.target === value
        : record.dataset.type === value);
      record.hidden = !matches;
      if (matches) shown += 1;
    });
    status.textContent = value
      ? `${shown} immediate ${shown === 1 ? "relationship" : "relationships"} shown.`
      : "All canonical relationships are shown.";
    heading.textContent = value ? "Selected relationships" : "All relationships";
  };

  work.addEventListener("change", () => {
    thread.value = "";
    applyFilter("work", work.value);
  });
  thread.addEventListener("change", () => {
    work.value = "";
    applyFilter("thread", thread.value);
  });
  showAll.addEventListener("click", () => {
    work.value = "";
    thread.value = "";
    applyFilter("all", "");
    work.focus();
  });
})();
