(function () {
  function cleanText(text) {
    return (text || "").replace(/\s+/g, " ").trim();
  }

  function getOverrideFromElement(el) {
    if (!el || !el.getAttribute) return "";
    return cleanText(
      el.getAttribute("data-section-title") ||
        el.getAttribute("data-section-short") ||
        ""
    );
  }

  function getHeadingText(slide, selector) {
    if (!slide) return "";
    const heading = slide.querySelector(selector);
    return heading ? cleanText(heading.textContent) : "";
  }

  function getTopLevelSectionLabel(slide) {
    const h1 = slide ? slide.querySelector(":scope > h1") : null;
    if (!h1) return "";
    return getOverrideFromElement(h1) || cleanText(h1.textContent);
  }

  function getSlideLocalOverride(slide) {
    if (!slide) return "";
    const slideOverride = getOverrideFromElement(slide);
    if (slideOverride) return slideOverride;

    const localHeading = slide.querySelector(
      ':scope > h2[data-section-title], :scope > h2[data-section-short], :scope > h3[data-section-title], :scope > h3[data-section-short]'
    );
    return getOverrideFromElement(localHeading);
  }

  function buildSectionMap() {
    const slides = document.querySelectorAll(".reveal .slides section");
    let currentSection = "";

    slides.forEach((slide) => {
      const topLevel = getTopLevelSectionLabel(slide);
      if (topLevel) currentSection = topLevel;

      const localOverride = getSlideLocalOverride(slide);
      const label = localOverride || currentSection;
      slide.dataset.sectionIndicator = label || "";
    });
  }

  function updateFooterIndicator(slide) {
    const indicator = document.getElementById("section-indicator");
    if (!indicator) return;

    const label = cleanText(slide && slide.dataset ? slide.dataset.sectionIndicator : "");
    indicator.textContent = label ? " | " + label : "";
  }

  function refresh(evt) {
    if (!window.Reveal) return;
    const currentSlide =
      (evt && evt.currentSlide) ||
      (Reveal.getCurrentSlide && Reveal.getCurrentSlide());
    updateFooterIndicator(currentSlide);
  }

  function init() {
    if (!window.Reveal) return;

    buildSectionMap();
    Reveal.on("ready", refresh);
    Reveal.on("slidechanged", refresh);
    Reveal.on("fragmentshown", refresh);
    Reveal.on("fragmenthidden", refresh);

    refresh();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
