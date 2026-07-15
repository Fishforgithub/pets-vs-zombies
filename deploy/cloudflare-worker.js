const OCI_ORIGIN =
  "https://objectstorage.ap-tokyo-1.oraclecloud.com/n/nrfvwmwpvwsn/b/pets-vs-zombies-web/o";

const CONTENT_TYPES = new Map([
  [".html", "text/html; charset=utf-8"],
  [".js", "text/javascript; charset=utf-8"],
  [".wasm", "application/wasm"],
  [".pck", "application/octet-stream"],
  [".png", "image/png"],
]);

function contentTypeFor(pathname) {
  for (const [extension, contentType] of CONTENT_TYPES) {
    if (pathname.endsWith(extension)) return contentType;
  }
  return "application/octet-stream";
}

export default {
  async fetch(request) {
    if (request.method !== "GET" && request.method !== "HEAD") {
      return new Response("Method not allowed", {
        status: 405,
        headers: { Allow: "GET, HEAD" },
      });
    }

    const requestUrl = new URL(request.url);
    const pathname = requestUrl.pathname === "/" ? "/index.html" : requestUrl.pathname;
    if (pathname.includes("..")) return new Response("Bad request", { status: 400 });

    const originUrl = new URL(`${OCI_ORIGIN}${pathname}`);
    const upstream = await fetch(originUrl, {
      method: request.method,
      headers: request.headers,
      redirect: "follow",
    });

    if (!upstream.ok) {
      return new Response("Game asset not found", { status: upstream.status });
    }

    const headers = new Headers(upstream.headers);
    headers.set("Content-Type", contentTypeFor(pathname));
    headers.set("X-Content-Type-Options", "nosniff");
    headers.set(
      "Cache-Control",
      pathname.endsWith(".html") ? "no-cache" : "public, max-age=3600",
    );

    return new Response(upstream.body, {
      status: upstream.status,
      headers,
    });
  },
};
