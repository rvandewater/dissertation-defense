(function () {
  const FADE_MS = 500;
  let refreshVersion = 0;
  function getFootnoteAside(slide) {
    if (!slide) return null;
    const asides = slide.querySelectorAll(":scope > aside");
    for (const aside of asides) {
      if (aside.querySelector(":scope > ol.aside-footnotes")) return aside;
    }
    return null;
  }
  function fragmentIsVisible(fragmentEl) {
    if (!fragmentEl) return true;
    if (
      fragmentEl.classList.contains("visible") ||
      fragmentEl.classList.contains("current-fragment")
    ) {
      return true;
    }
    const style = window.getComputedStyle(fragmentEl);
    return style.display !== "none" && style.visibility !== "hidden";
  }
  function getVisibleFootnoteNumbers(slide) {
    const nums = new Set();
    const sups = slide.querySelectorAll("sup");
    sups.forEach((sup) => {
      const frag = sup.closest(".fragment");
      if (!fragmentIsVisible(frag)) return;
      const n = Number.parseInt((sup.textContent || "").trim(), 10);
      if (Number.isFinite(n)) nums.add(n);
    });
    return nums;
  }
  function ensureFadeInit(el) {
    if (!el || el.dataset.fnInit === "1") return;
    el.dataset.fnInit = "1";
    el.style.transition = "opacity " + FADE_MS + "ms ease";
    el.style.opacity = "0";
    el.style.display = "none";
  }
  function setFadeState(el, show) {
    if (!el) return;
    ensureFadeInit(el);
    const wasShown = el.dataset.fnShown === "1";
    if (show === wasShown) return;
    el.dataset.fnShown = show ? "1" : "0";
    if (show) {
      el.style.display = "";
      el.style.opacity = "0";
      requestAnimationFrame(() => {
        if (el.dataset.fnShown === "1") {
          el.style.opacity = "1";
        }
      });
    } else {
      el.style.opacity = "0";
      window.setTimeout(() => {
        if (el.dataset.fnShown !== "1") {
          el.style.display = "none";
        }
      }, FADE_MS);
    }
  }
  function syncCurrentSlideFootnotes() {
    const slide =
      window.Reveal && Reveal.getCurrentSlide && Reveal.getCurrentSlide();
    if (!slide) return;
    const footAside = getFootnoteAside(slide);
    if (!footAside) return;
    const list = footAside.querySelector(":scope > ol.aside-footnotes");
    if (!list) return;
    const visibleNums = getVisibleFootnoteNumbers(slide);
    let anyShown = false;
    Array.from(list.children).forEach((li, idx) => {
      const liNum = idx + 1;
      const show = visibleNums.has(liNum);
      setFadeState(li, show);
      if (show) anyShown = true;
    });
    setFadeState(footAside, anyShown);
  }
  function scheduleRefresh() {
    const v = ++refreshVersion;
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        if (v !== refreshVersion) return;
        syncCurrentSlideFootnotes();
      });
    });
  }
  function init() {
    if (!window.Reveal) return;
    Reveal.on("ready", scheduleRefresh);
    Reveal.on("slidechanged", scheduleRefresh);
    Reveal.on("fragmentshown", scheduleRefresh);
    Reveal.on("fragmenthidden", scheduleRefresh);
    scheduleRefresh();
  }
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
