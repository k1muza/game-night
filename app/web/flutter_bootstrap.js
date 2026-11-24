{{flutter_js}}
{{flutter_build_config}}

// Offline support: our own service worker (tool/build_web.dart writes sw.js
// with the precache list). Flutter's built-in caching worker is no longer
// generated, so we don't rely on it.
const swReady = ('serviceWorker' in navigator)
  ? navigator.serviceWorker.register('sw.js').then(() => navigator.serviceWorker.ready).catch(() => null)
  : Promise.resolve(null);

/// Tells the worker which engine files this browser actually loaded, so only
/// that renderer variant is cached for offline play.
function cacheEngine() {
  swReady.then((reg) => {
    if (!reg || !reg.active) return;
    const urls = performance.getEntriesByType('resource')
      .map((e) => e.name)
      .filter((u) => u.startsWith(location.origin) && u.indexOf('/canvaskit/') !== -1);
    if (urls.length) reg.active.postMessage({ type: 'cache-runtime', urls });
  });
}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    // The engine (CanvasKit) is fully downloaded once initializeEngine resolves.
    cacheEngine();
    await appRunner.runApp();
    const splash = document.getElementById('splash');
    if (splash) {
      splash.style.opacity = '0';
      setTimeout(() => splash.remove(), 200);
    }
  },
});
