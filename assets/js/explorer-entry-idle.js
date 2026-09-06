(function () {
  'use strict';

  var region = document.querySelector('[data-explorer-idle]');
  if (!region || region.dataset.explorerInitialized === 'true') return;
  region.dataset.explorerInitialized = 'true';

  var image = region.querySelector('img');
  var source = region.querySelector('source');
  var motion = window.matchMedia('(prefers-reduced-motion: reduce)');
  var frameBase = region.dataset.frameBase;
  var frameCount = Number(region.dataset.frameCount || 12);
  var widths = [320, 512, 768];
  var frameDuration = 140;
  var frames = [];
  var selectedWidth = 0;
  var preloadPromise = null;
  var preloadObserver;
  var visibilityObserver;
  var timer = 0;
  var animationFrame = 0;
  var generation = 0;
  var onscreen = false;
  var destroyed = false;
  var failed = false;
  var fallbackTried = false;
  var fallbackSrc = image.getAttribute('src');
  var fallbackSrcset = source ? source.getAttribute('srcset') : '';

  function frameUrl(index, width) {
    return frameBase + 'FMD_CHAR_EXPLORERENTRY_DJ_IDLE_F' + String(index).padStart(2, '0') + '_' + width + 'W_v001.webp';
  }

  function requiredWidth() {
    var pixels = Math.max(1, region.getBoundingClientRect().width) * Math.min(window.devicePixelRatio || 1, 2);
    return widths.find(function (width) { return width >= pixels; }) || widths[widths.length - 1];
  }

  function clearWork() {
    generation += 1;
    if (timer) window.clearTimeout(timer);
    if (animationFrame) window.cancelAnimationFrame(animationFrame);
    timer = 0;
    animationFrame = 0;
  }

  function restoreStatic() {
    if (source) source.setAttribute('srcset', fallbackSrcset);
    image.src = fallbackSrc;
  }

  function disableAnimation() {
    failed = true;
    clearWork();
    restoreStatic();
    region.dataset.animationState = 'static';
  }

  function loadFrames() {
    if (destroyed || failed || motion.matches) return Promise.resolve(false);
    var width = requiredWidth();
    if (preloadPromise && selectedWidth === width) return preloadPromise;
    selectedWidth = width;
    frames = Array.from({ length: frameCount }, function (_, index) { return frameUrl(index + 1, width); });
    preloadPromise = Promise.all(frames.map(function (url) {
      return new Promise(function (resolve, reject) {
        var loader = new Image();
        loader.onload = function () { resolve(url); };
        loader.onerror = reject;
        loader.src = url;
      });
    })).then(function () {
      region.dataset.animationState = 'ready';
      return true;
    }).catch(function () {
      disableAnimation();
      return false;
    });
    return preloadPromise;
  }

  function mayPlay() {
    return !destroyed && !failed && !motion.matches && onscreen && document.visibilityState === 'visible';
  }

  function showFrame(index) {
    if (source) source.setAttribute('srcset', frames[index]);
    image.src = frames[index];
  }

  function scheduleCycle(returning) {
    clearWork();
    if (!mayPlay()) return;
    var token = generation;
    var delay = returning ? 2500 + Math.random() * 2500 : 9000 + Math.random() * 9000;
    timer = window.setTimeout(function () {
      if (token !== generation || !mayPlay()) return;
      loadFrames().then(function (ready) {
        if (ready && token === generation && mayPlay()) playCycle();
      });
    }, delay);
  }

  function playCycle() {
    clearWork();
    if (!mayPlay() || !frames.length) return;
    var token = generation;
    var started = performance.now();
    var lastFrame = -1;
    region.dataset.animationState = 'playing';

    function step(now) {
      if (token !== generation || !mayPlay()) return;
      var index = Math.min(frameCount - 1, Math.floor((now - started) / frameDuration));
      if (index !== lastFrame) {
        showFrame(index);
        lastFrame = index;
      }
      if (index < frameCount - 1) {
        animationFrame = window.requestAnimationFrame(step);
      } else {
        region.dataset.animationState = 'paused';
        timer = window.setTimeout(function () {
          if (token !== generation || !mayPlay()) return;
          showFrame(0);
          scheduleCycle(false);
        }, 500);
      }
    }
    animationFrame = window.requestAnimationFrame(step);
  }

  function suspend() {
    clearWork();
    if (!failed) {
      restoreStatic();
      region.dataset.animationState = 'paused';
    }
  }

  function handleMotionChange() {
    if (motion.matches) suspend(); else if (onscreen) scheduleCycle(true);
  }

  function handleVisibility() {
    if (document.visibilityState === 'hidden') suspend(); else if (onscreen && !motion.matches) scheduleCycle(true);
  }

  function destroy() {
    destroyed = true;
    clearWork();
    if (preloadObserver) preloadObserver.disconnect();
    if (visibilityObserver) visibilityObserver.disconnect();
    document.removeEventListener('visibilitychange', handleVisibility);
    window.removeEventListener('pagehide', handlePageHide);
    if (motion.removeEventListener) motion.removeEventListener('change', handleMotionChange);
  }

  function handlePageHide(event) {
    if (event.persisted) suspend(); else destroy();
  }

  image.addEventListener('error', function () {
    if (!fallbackTried && image.getAttribute('src') !== fallbackSrc) {
      fallbackTried = true;
      disableAnimation();
    } else {
      region.hidden = true;
    }
  });

  if (motion.matches || !('IntersectionObserver' in window)) {
    region.dataset.animationState = 'static';
    return;
  }

  preloadObserver = new IntersectionObserver(function (entries) {
    if (entries[0].isIntersecting) {
      loadFrames();
      preloadObserver.disconnect();
    }
  }, { rootMargin: '280px 0px' });

  visibilityObserver = new IntersectionObserver(function (entries) {
    onscreen = entries[0].isIntersecting;
    if (onscreen) scheduleCycle(true); else suspend();
  }, { threshold: 0.08 });

  preloadObserver.observe(region);
  visibilityObserver.observe(region);
  document.addEventListener('visibilitychange', handleVisibility);
  window.addEventListener('pagehide', handlePageHide);
  if (motion.addEventListener) motion.addEventListener('change', handleMotionChange);
}());
