/* ── Room page interactive engine ─────────────────────────────────────────
   Each room page defines a `window.roomContent` object keyed by hotspot
   data-key, then includes this script. Handles click/keyboard activation,
   tabbed content within a hotspot, and scroll-reveal + compass on pages
   that have those elements.
─────────────────────────────────────────────────────────────────────────── */
(function () {
  function initHotspots() {
    var panel = document.getElementById('panel');
    if (!panel || !window.roomContent) return;

    var hotspots = document.querySelectorAll('.hotspot');
    var currentData = null;
    var currentTabIndex = 0;

    function renderTabs(data, activeIndex) {
      return '<div class="tab-row">' + data.tabs.map(function (t, i) {
        return '<button class="tab-btn' + (i === activeIndex ? ' active' : '') + '" data-idx="' + i + '">' + t.label + '</button>';
      }).join('') + '</div><p>' + data.tabs[activeIndex].body + '</p>';
    }

    function renderLinks(data) {
      if (!data.links) return '';
      return data.links.map(function (l) {
        return '<a href="' + l.href + '" class="link-btn">' + l.label + '</a>';
      }).join('');
    }

    function renderPanel() {
      var data = currentData;
      if (!data) return;
      var header =
        '<span class="panel-eyebrow">' + data.eyebrow + '</span>' +
        '<h2>' + data.title + '</h2>' +
        '<span class="badge">' + data.badge + '</span>';
      if (data.tabs) {
        panel.innerHTML = header + renderTabs(data, currentTabIndex) + renderLinks(data);
      } else {
        panel.innerHTML = header + '<p>' + data.body + '</p>' + renderLinks(data);
      }
    }

    panel.addEventListener('click', function (e) {
      var btn = e.target.closest('.tab-btn[data-idx]');
      if (!btn) return;
      currentTabIndex = parseInt(btn.getAttribute('data-idx'), 10);
      renderPanel();
    });

    function activate(key, el) {
      hotspots.forEach(function (h) { h.classList.remove('active'); });
      if (el) el.classList.add('active');
      var data = window.roomContent[key];
      if (!data) return;
      currentData = data;
      currentTabIndex = 0;
      renderPanel();
    }

    hotspots.forEach(function (h) {
      h.setAttribute('tabindex', '0');
      h.setAttribute('role', 'button');
      h.addEventListener('click', function () { activate(h.getAttribute('data-key'), h); });
      h.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); activate(h.getAttribute('data-key'), h); }
      });
    });
  }

  function initReveal() {
    var revealEls = document.querySelectorAll('.reveal');
    if (!revealEls.length) return;
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) { if (entry.isIntersecting) entry.target.classList.add('is-visible'); });
    }, { threshold: 0.2 });
    revealEls.forEach(function (el) { io.observe(el); });
  }

  function initCompass() {
    var needle = document.getElementById('compassNeedle');
    if (!needle) return;
    window.addEventListener('scroll', function () {
      var scrolled = window.scrollY;
      var max = document.body.scrollHeight - window.innerHeight;
      var pct = max > 0 ? scrolled / max : 0;
      needle.style.transform = 'rotate(' + (pct * 360) + 'deg)';
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    initHotspots();
    initReveal();
    initCompass();
  });
})();
