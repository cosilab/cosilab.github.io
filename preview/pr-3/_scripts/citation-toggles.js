/*
  toggles the abstract/bibtex panels on publication citations.
*/

{
  document.addEventListener("click", (event) => {
    const button = event.target.closest(".citation-toggle");
    if (!button) return;
    const panel = button
      .closest(".citation-text")
      .querySelector(`.citation-${button.dataset.panel}`);
    if (!panel) return;
    panel.hidden = !panel.hidden;
    button.setAttribute("aria-expanded", String(!panel.hidden));
  });
}
