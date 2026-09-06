#!/usr/bin/env python3
"""Capture the local Explorer Entry at exact review viewports via Chrome CDP."""

import argparse
import base64
import json
import time
import urllib.request
from pathlib import Path

import websocket


class CDP:
    def __init__(self, url):
        self.ws = websocket.create_connection(url, origin="http://localhost")
        self.next_id = 0

    def call(self, method, params=None):
        self.next_id += 1
        message_id = self.next_id
        self.ws.send(json.dumps({"id": message_id, "method": method, "params": params or {}}))
        while True:
            message = json.loads(self.ws.recv())
            if message.get("id") == message_id:
                if "error" in message:
                    raise RuntimeError(message["error"])
                return message.get("result", {})


def new_target(debug_port):
    request = urllib.request.Request(f"http://127.0.0.1:{debug_port}/json/new?about:blank", method="PUT")
    with urllib.request.urlopen(request) as response:
        return json.load(response)


def capture(debug_port, url, width, height, output, reduced_motion=False):
    target = new_target(debug_port)
    cdp = CDP(target["webSocketDebuggerUrl"])
    cdp.call("Page.enable")
    cdp.call("Runtime.enable")
    cdp.call("Emulation.setDeviceMetricsOverride", {
        "width": width,
        "height": height,
        "deviceScaleFactor": 1,
        "mobile": width < 768,
    })
    if reduced_motion:
        cdp.call("Emulation.setEmulatedMedia", {
            "features": [{"name": "prefers-reduced-motion", "value": "reduce"}]
        })
    cdp.call("Page.navigate", {"url": url})
    time.sleep(2)
    cdp.call("Runtime.evaluate", {
        "expression": "document.querySelector('#explorer-entry').scrollIntoView({block:'start'})"
    })
    time.sleep(1)
    result = cdp.call("Page.captureScreenshot", {"format": "png", "fromSurface": True})
    Path(output).write_bytes(base64.b64decode(result["data"]))
    state = cdp.call("Runtime.evaluate", {
        "expression": "JSON.stringify({state:document.querySelector('[data-explorer-idle]').dataset.animationState||'', hidden:document.querySelector('[data-explorer-idle]').hidden, src:document.querySelector('[data-explorer-idle] img').currentSrc, overflow:document.documentElement.scrollWidth-document.documentElement.clientWidth})",
        "returnByValue": True,
    })["result"]["value"]
    print(f"{width}x{height}: {state}")
    cdp.ws.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--debug-port", type=int, default=9223)
    parser.add_argument("--url", default="http://127.0.0.1:4010/")
    parser.add_argument("--width", type=int, required=True)
    parser.add_argument("--height", type=int, required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--reduced-motion", action="store_true")
    args = parser.parse_args()
    capture(args.debug_port, args.url, args.width, args.height, args.output, args.reduced_motion)
