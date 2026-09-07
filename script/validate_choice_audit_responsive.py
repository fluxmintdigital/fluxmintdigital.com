#!/usr/bin/env python3
"""Exercise the CA-005 responsive composition in a real browser."""

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

    def evaluate(self, expression, await_promise=False):
        result = self.call("Runtime.evaluate", {"expression": expression, "returnByValue": True, "awaitPromise": await_promise})
        return result["result"].get("value")


def viewport(page, width, height):
    page.call("Emulation.setDeviceMetricsOverride", {"width": width, "height": height, "deviceScaleFactor": 1, "mobile": width < 768})
    time.sleep(0.2)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True)
    parser.add_argument("--debug-port", type=int, default=9225)
    args = parser.parse_args()
    request = urllib.request.Request(f"http://127.0.0.1:{args.debug_port}/json/new?about:blank", method="PUT")
    with urllib.request.urlopen(request) as response:
        target = json.load(response)
    page = CDP(target["webSocketDebuggerUrl"])
    page.call("Page.enable")
    page.call("Runtime.enable")
    viewport(page, 1440, 1000)
    page.call("Page.navigate", {"url": args.url})
    for _ in range(30):
        time.sleep(0.1)
        if page.evaluate("document.querySelector('[data-audit-field]') && (!document.querySelector('[data-audit-field]').disabled || !document.querySelector('[data-audit-returning]').hidden)"):
            break
    if page.evaluate("!document.querySelector('[data-audit-returning]').hidden"):
        page.evaluate("document.querySelector('[data-audit-continue]').click()")
        time.sleep(0.2)
    assert page.evaluate("!document.querySelector('[data-audit-field]').disabled")

    results = {}
    for name, width, height, columns in (
        ("wide_1440", 1440, 1000, 2),
        ("wide_1280", 1280, 800, 2),
        ("wide_1024", 1024, 768, 2),
        ("intermediate_900", 900, 1024, 2),
        ("intermediate_768", 768, 1024, 2),
    ):
        viewport(page, width, height)
        results[name] = page.evaluate(f"(()=>{{const r=document.querySelector('[data-choice-audit]');const g=document.querySelector('[data-audit-forces]');return !r.classList.contains('choice-audit--compact')&&getComputedStyle(g).gridTemplateColumns.split(' ').length==={columns}&&document.documentElement.scrollWidth<=innerWidth}})()")
        assert results[name]

    viewport(page, 390, 844)
    compact = page.evaluate("(()=>{const r=document.querySelector('[data-choice-audit]');return {active:r.classList.contains('choice-audit--compact'),names:r.querySelectorAll('[data-force-index] [data-force-open]').length,visible:[...r.querySelectorAll('[data-force-body]')].filter(n=>!n.hidden).length,overflow:document.documentElement.scrollWidth>innerWidth}})()")
    assert compact == {"active": True, "names": 8, "visible": 0, "overflow": False}, compact

    viewport(page, 767, 900)
    assert page.evaluate("document.querySelector('[data-choice-audit]').classList.contains('choice-audit--compact')") is True
    assert not page.evaluate("document.documentElement.scrollWidth>innerWidth")
    viewport(page, 390, 844)

    page.evaluate("document.querySelector('[data-force-index] [data-force-open=identity]').click()")
    focused = page.evaluate("(()=>{const r=document.querySelector('[data-force=identity]');const t=r.querySelector('[data-force-reflection]');t.value='Responsive state survives';t.dispatchEvent(new Event('input',{bubbles:true}));return r.classList.contains('choice-force--active')&&!r.querySelector('[data-force-body]').hidden&&document.activeElement===t})()")
    assert focused
    assert page.evaluate("document.querySelector('[data-force-index-state=identity]').hidden") is False
    page.evaluate("document.querySelector('[data-force=identity] [data-force-return]').click()")
    assert page.evaluate("document.querySelectorAll('[data-force-body]:not([hidden])').length") == 0
    assert page.evaluate("document.activeElement.matches('[data-force-index] [data-force-open]')")

    viewport(page, 360, 740)
    assert not page.evaluate("document.documentElement.scrollWidth>innerWidth")
    page.evaluate("(()=>{const long='A deliberately long reader-authored sentence that tests wrapping without reducing the promised writing capacity. '.repeat(12);for(const s of ['[data-audit-choice]','[data-force=identity] [data-force-reflection]','[data-evidence=supports]']){const n=document.querySelector(s);n.value=long;n.dispatchEvent(new Event('input',{bubbles:true}))}})()")
    assert not page.evaluate("document.documentElement.scrollWidth>innerWidth")
    target_sizes = page.evaluate("[...document.querySelectorAll('[data-choice-audit] :is(button,.choice-force__classifications label,.choice-force__influence label,.choice-counterfactual__responses label)')].filter(n=>getComputedStyle(n).display!=='none'&&!n.closest('[hidden]')).map(n=>n.getBoundingClientRect().height)")
    assert target_sizes and min(target_sizes) >= 43.5, min(target_sizes)
    viewport(page, 844, 390)
    assert page.evaluate("document.querySelector('[data-choice-audit]').classList.contains('choice-audit--compact')") is False
    viewport(page, 390, 844)
    assert page.evaluate("document.querySelector('[data-force=identity] [data-force-reflection]').value.startsWith('A deliberately long reader-authored sentence')")
    assert not page.evaluate("/Gumroad|Ko-fi|\\$12/.test(document.querySelector('[data-choice-audit]').textContent)")

    # DOM order remains one copy of each working region in canonical order.
    order = page.evaluate("[...document.querySelectorAll('[data-force]')].map(n=>n.dataset.force).join(',')")
    assert order == "desire,expectation,security,opportunity,identity,obligation,fearAvoidance,possibility"

    print(json.dumps({
        "result": "Choice Audit CA-005 responsive compositions valid",
        **results,
        "compact_force_index": 8,
        "compact_focus_return": True,
        "neutral_contains_material": True,
        "resize_state_preserved": True,
        "compact_360_overflow": False,
        "landscape_transition": True,
        "single_canonical_force_dom": True,
    }, indent=2))


if __name__ == "__main__":
    main()
