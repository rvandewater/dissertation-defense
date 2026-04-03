document.addEventListener('DOMContentLoaded', function() {
  function getCurrentSectionTitle() {
    // Get all top-level sections (horizontal slides)
    const sections = Array.from(document.querySelectorAll('.reveal .slides > section'));
    const indices = Reveal.getIndices();
    let hSection = indices.h;
    // Defensive: Clamp to available sections
    if (hSection >= sections.length) hSection = sections.length - 1;
    // Look for h1 in the current horizontal section
    let sectionTitle = '';
    if (sections[hSection]) {
      // Prefer h1, fallback to first heading
      let h1 = sections[hSection].querySelector('h1');
      if (!h1) {
        // Try any heading
        h1 = sections[hSection].querySelector('h2, h3, h4, h5, h6');
      }
      if (h1) {
        sectionTitle = h1.textContent;
      }
    }
    return sectionTitle;
  }

  function updateFooterSection() {
    const sectionTitle = getCurrentSectionTitle();
    document.getElementById('slide-footer-section').textContent = sectionTitle;
  }

  Reveal.on('slidechanged', updateFooterSection);
  updateFooterSection();
});