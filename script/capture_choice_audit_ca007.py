#!/usr/bin/env python3
"""Capture the required CA-007 human visual-gate evidence."""

import argparse
import base64
import json
import pathlib
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


def viewport(page, width, height):
    page.call("Emulation.setDeviceMetricsOverride", {"width": width, "height": height, "deviceScaleFactor": 1, "mobile": width < 768})
    time.sleep(.25)


def capture(page, destination):
    time.sleep(.2)
    data = page.call("Page.captureScreenshot", {"format": "png", "captureBeyondViewport": False})["data"]
    destination.write_bytes(base64.b64decode(data))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True)
    parser.add_argument("--debug-port", type=int, default=9225)
    parser.add_argument("--output", default="/tmp/FluxMintDigital_CA007_Evidence")
    args = parser.parse_args()
    output = pathlib.Path(args.output)
    output.mkdir(parents=True, exist_ok=True)
    request = urllib.request.Request(f"http://127.0.0.1:{args.debug_port}/json/new?about:blank", method="PUT")
    with urllib.request.urlopen(request) as response:
        target = json.load(response)
    page = CDP(target["webSocketDebuggerUrl"])
    page.call("Page.enable")
    page.call("Runtime.enable")
    viewport(page, 1440, 1000)
    page.call("Page.navigate", {"url": args.url})
    for _ in range(40):
        time.sleep(.1)
        if page.evaluate("document.querySelector('[data-audit-field]') && (!document.querySelector('[data-audit-field]').disabled || !document.querySelector('[data-audit-returning]').hidden)"):
            break
    if page.evaluate("!document.querySelector('[data-audit-returning]').hidden"):
        page.evaluate("document.querySelector('[data-audit-continue]').click()")
    page.evaluate("document.documentElement.style.scrollBehavior='auto'")
    page.evaluate("document.querySelector('.choice-audit__toolbar [data-audit-new]').click()")
    time.sleep(.4)
    page.evaluate("scrollTo(0,document.querySelector('.choice-audit__choice').getBoundingClientRect().top+scrollY-80)")
    capture(page, output / "01-wide-empty-1440x1000.png")

    page.evaluate("""(()=>{const set=(s,v)=>{const n=document.querySelector(s);n.value=v;n.dispatchEvent(new Event('input',{bubbles:true}))};set('[data-audit-choice]','Choosing whether to leave familiar work and begin something I have wanted to build for years.');set('[data-force=desire] [data-force-reflection]','I wanted room to make the work carefully and on my own terms.');set('[data-force=expectation] [data-force-reflection]','I expected myself to have a complete plan before beginning.');set('[data-force=identity] [data-force-reflection]','The choice touched the kind of builder I believed I could become.');for(const s of ['[data-force=desire] [value=W]','[data-force=desire] [value=P]','[data-force=expectation] [value=E]','[data-force=identity] [value=W]']){const n=document.querySelector(s);n.checked=true;n.dispatchEvent(new Event('change',{bubbles:true}))}const i=document.querySelector('[data-force=identity] [data-force-influence][value="2"]');i.checked=true;i.dispatchEvent(new Event('change',{bubbles:true}))})()""")
    page.evaluate("document.activeElement.blur();scrollTo(0,document.querySelector('.choice-audit__choice').getBoundingClientRect().top+scrollY-80)")
    capture(page, output / "02-wide-inhabited-1440x1000.png")
    page.evaluate("document.activeElement.blur();scrollTo(0,document.querySelector('.choice-evidence').getBoundingClientRect().top+scrollY-80)")
    capture(page, output / "03-evidence-lens-1440x1000.png")

    viewport(page, 390, 844)
    page.evaluate("document.activeElement.blur();scrollTo(0,document.querySelector('[data-force-index]').getBoundingClientRect().top+scrollY-80)")
    capture(page, output / "04-compact-force-overview-390x844.png")
    page.evaluate("document.querySelector('[data-force-index] [data-force-open=identity]').click()")
    capture(page, output / "05-compact-expanded-force-390x844.png")
    page.evaluate("document.activeElement.blur();scrollTo(0,document.querySelector('.choice-reflection').getBoundingClientRect().top+scrollY-80)")
    capture(page, output / "06-compact-reflection-390x844.png")
    page.evaluate("(()=>{const n=document.querySelector('[data-final-reflection]');n.value='I notice that wanting the work and expecting certainty were both present.';n.dispatchEvent(new Event('input',{bubbles:true}));n.blur();const r=document.querySelector('[data-architecture-reveal]');scrollTo(0,r.getBoundingClientRect().top+scrollY-80)})()")
    capture(page, output / "07-ten-map-reveal-390x844.png")
    print(json.dumps({"output": str(output), "screenshots": sorted(path.name for path in output.glob("*.png"))}, indent=2))


if __name__ == "__main__":
    main()
