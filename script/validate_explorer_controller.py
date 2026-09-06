#!/usr/bin/env python3
"""Exercise the gated Explorer controller against an explicitly enabled fixture."""

import argparse
import json
import time
import urllib.request

import websocket


class CDP:
    def __init__(self, url):
        self.ws = websocket.create_connection(url, origin="http://localhost")
        self.next_id = 0

    def call(self, method, params=None):
        self.next_id += 1
        request_id = self.next_id
        self.ws.send(json.dumps({"id": request_id, "method": method, "params": params or {}}))
        while True:
            message = json.loads(self.ws.recv())
            if message.get("id") == request_id:
                if "error" in message:
                    raise RuntimeError(message["error"])
                return message.get("result", {})

    def evaluate(self, expression):
        result = self.call("Runtime.evaluate", {"expression": expression, "returnByValue": True})
        return result["result"].get("value")


def new_page(port, reduced_motion=False):
    request = urllib.request.Request(f"http://127.0.0.1:{port}/json/new?about:blank", method="PUT")
    with urllib.request.urlopen(request) as response:
        target = json.load(response)
    page = CDP(target["webSocketDebuggerUrl"])
    page.call("Page.enable")
    page.call("Runtime.enable")
    page.call("Network.enable")
    page.call("Emulation.setDeviceMetricsOverride", {"width": 390, "height": 844, "deviceScaleFactor": 1, "mobile": True})
    if reduced_motion:
        page.call("Emulation.setEmulatedMedia", {"features": [{"name": "prefers-reduced-motion", "value": "reduce"}]})
    return page


def navigate(page, url):
    page.call("Page.navigate", {"url": url})
    time.sleep(1.5)


def state(page):
    expression = "JSON.stringify((()=>{const r=document.querySelector('[data-explorer-idle]');return {state:r.dataset.animationState||'',hidden:r.hidden,src:r.querySelector('img').currentSrc}})())"
    return json.loads(page.evaluate(expression))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True)
    parser.add_argument("--debug-port", type=int, default=9223)
    args = parser.parse_args()

    page = new_page(args.debug_port)
    navigate(page, args.url)
    initial = page.evaluate("performance.getEntriesByType('resource').filter(r=>r.name.includes('EXPLORERENTRY_DJ_IDLE')).length")
    assert initial <= 1, initial
    page.evaluate("document.querySelector('#explorer-entry').scrollIntoView({block:'start'})")
    time.sleep(5.5)
    active = state(page)
    loaded = page.evaluate("new Set(performance.getEntriesByType('resource').filter(r=>r.name.includes('EXPLORERENTRY_DJ_IDLE')).map(r=>r.name)).size")
    assert active["state"] in ("ready", "playing", "paused"), active
    assert 12 <= loaded <= 13, loaded
    page.evaluate("window.scrollTo(0,0)")
    time.sleep(0.5)
    paused = state(page)
    assert paused["state"] == "paused", paused
    held = paused["src"]
    time.sleep(1)
    assert state(page)["src"] == held
    page.ws.close()

    reduced = new_page(args.debug_port, reduced_motion=True)
    navigate(reduced, args.url)
    reduced.evaluate("document.querySelector('#explorer-entry').scrollIntoView({block:'start'})")
    time.sleep(1)
    reduced_state = state(reduced)
    reduced_resources = reduced.evaluate("performance.getEntriesByType('resource').filter(r=>r.name.includes('EXPLORERENTRY_DJ_IDLE')).length")
    assert reduced_state["state"] == "static", reduced_state
    assert reduced_resources <= 1, reduced_resources
    reduced.ws.close()

    failed = new_page(args.debug_port)
    failed.call("Network.setBlockedURLs", {"urls": ["*FMD_CHAR_EXPLORERENTRY_DJ_IDLE_F06_320W_v001.webp"]})
    navigate(failed, args.url)
    failed.evaluate("document.querySelector('#explorer-entry').scrollIntoView({block:'start'})")
    time.sleep(2)
    failed_state = state(failed)
    assert failed_state["state"] == "static" and not failed_state["hidden"], failed_state
    failed.ws.close()

    print(json.dumps({"initial_delivery_requests": initial, "loaded_frames": loaded, "offscreen": paused, "reduced_motion": reduced_state, "failed_frame": failed_state, "result": "Explorer ON fixture lifecycle valid"}, indent=2))


if __name__ == "__main__":
    main()
