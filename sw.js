/* 手势花朵 · 离线缓存
 * 改动代码后记得把 CACHE 版本号 +1，否则手机上会一直用旧缓存
 */
const CACHE = 'hand-flower-v1';

const PRECACHE = [
  './',
  './index.html',
  './manifest.webmanifest',
  './icons/icon-192.png',
  './icons/icon-512.png',
  './libs/three/three.module.js',
  './libs/hands/hands.js',
  './libs/hands/hands.binarypb',
  './libs/hands/hands_solution_packed_assets_loader.js',
  './libs/hands/hands_solution_simd_wasm_bin.js',
  './libs/hands/hands_solution_wasm_bin.js',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE)
      .then((cache) => cache.addAll(PRECACHE))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;

  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return;

  event.respondWith(
    caches.match(req, { ignoreSearch: true }).then((cached) => {
      if (cached) return cached;

      return fetch(req).then((res) => {
        // 只缓存成功的同源响应（含 wasm / data 大文件，首次用到后即缓存）
        if (res && res.status === 200 && res.type === 'basic') {
          const copy = res.clone();
          caches.open(CACHE).then((cache) => cache.put(req, copy)).catch(() => {});
        }
        return res;
      }).catch(() => {
        // 离线兜底
        if (req.mode === 'navigate') return caches.match('./index.html');
        return Response.error();
      });
    })
  );
});
