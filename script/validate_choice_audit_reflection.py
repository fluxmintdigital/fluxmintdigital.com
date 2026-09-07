#!/usr/bin/env python3
"""Exercise the CA-004 reflection architecture in a real browser."""

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
        if result["result"].get("subtype") == "error":
            raise RuntimeError(result["result"].get("description"))
        return result["result"].get("value")


def new_page(port, indexeddb=True, width=1440, height=1000):
    request = urllib.request.Request(f"http://127.0.0.1:{port}/json/new?about:blank", method="PUT")
    with urllib.request.urlopen(request) as response:
        target = json.load(response)
    page = CDP(target["webSocketDebuggerUrl"])
    page.call("Page.enable")
    page.call("Runtime.enable")
    page.call("Network.enable")
    page.call("Emulation.setDeviceMetricsOverride", {"width": width, "height": height, "deviceScaleFactor": 1, "mobile": width < 768})
    if not indexeddb:
        page.call("Page.addScriptToEvaluateOnNewDocument", {"source": "Object.defineProperty(globalThis,'indexedDB',{configurable:false,value:null});"})
    return page


def navigate(page, url):
    page.call("Page.navigate", {"url": url})
    time.sleep(1)


def wait_for(page, expression, attempts=40):
    for _ in range(attempts):
        if page.evaluate(expression):
            return
        time.sleep(0.1)
    raise AssertionError(f"Timed out: {expression}")


def type_into(page, selector, value):
    page.evaluate(f"document.querySelector({json.dumps(selector)}).focus()")
    page.call("Input.insertText", {"text": value})


def press_space(page):
    page.call("Input.dispatchKeyEvent", {"type": "keyDown", "key": " ", "code": "Space"})
    page.call("Input.dispatchKeyEvent", {"type": "keyUp", "key": " ", "code": "Space"})


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True)
    parser.add_argument("--debug-port", type=int, default=9226)
    args = parser.parse_args()

    page = new_page(args.debug_port)
    navigate(page, args.url)
    page.evaluate("import('/assets/js/choice-audit-model.js').then(async m=>{const r=m.createAuditRepository();await r.ready;for(const a of await r.list())await r.delete(a.id);r.close();return true})", await_promise=True)
    page.call("Page.reload")
    time.sleep(1)
    wait_for(page, "!document.querySelector('[data-audit-field]').disabled")

    order_valid = page.evaluate("(()=>{const selectors=['.artifact-detail__header','.choice-audit__privacy','.choice-audit__choice','[data-force=desire]','[data-force=expectation]','[data-force=security]','[data-force=opportunity]','[data-force=identity]','[data-force=obligation]','[data-force=fearAvoidance]','[data-force=possibility]','.choice-relationships','[data-temporal=then]','.choice-counterfactual','.choice-evidence','.choice-preservation','.choice-noticing','[data-architecture-reveal]','.relationship-exits'];const nodes=selectors.map(s=>document.querySelector(s));return nodes.every(Boolean)&&nodes.every((n,i)=>i===0||(nodes[i-1].compareDocumentPosition(n)&Node.DOCUMENT_POSITION_FOLLOWING))})()")
    assert order_valid
    assert page.evaluate("document.querySelector('[data-architecture-reveal]').hidden") is True
    assert page.evaluate("!document.querySelector('.artifact-facts').textContent.includes('Not available yet') && document.querySelector('.artifact-facts').textContent.includes('Free browser instrument')") is True

    values = {
        "[data-temporal=then]": "Then, this was salient",
        "[data-temporal=now]": "Now, another detail is visible",
        "[data-counterfactual-reflection]": "A different possibility, not causal proof",
        "[data-evidence=supports]": "Something that supports it",
        "[data-evidence=challenges]": "Something that challenges it",
        "[data-evidence=alternatives]": "Another possible explanation",
        "[data-evidence=uncertainty]": "Something still uncertain",
        "[data-preservation]": "Something I choose to preserve",
    }
    for selector, value in values.items():
        type_into(page, selector, value)

    page.evaluate("document.querySelector('[data-counterfactual-response][value=Maybe]').focus()")
    press_space(page)
    assert page.evaluate("document.querySelector('[data-counterfactual-response][value=Maybe]').checked") is True
    assert page.evaluate("document.querySelector('[data-architecture-reveal]').hidden") is True
    assert page.evaluate("document.querySelector('[data-temporal=after]').value") == ""

    type_into(page, "[data-final-reflection]", "I notice a relationship without asking the audit to interpret it")
    wait_for(page, "!document.querySelector('[data-architecture-reveal]').hidden")
    page.evaluate("(()=>{const n=document.querySelector('[data-final-reflection]');n.value='';n.dispatchEvent(new Event('input',{bubbles:true}))})()")
    assert page.evaluate("document.querySelector('[data-architecture-reveal]').hidden") is True
    type_into(page, "[data-final-reflection]", "I notice a relationship without asking the audit to interpret it")
    wait_for(page, "!document.querySelector('[data-architecture-reveal]').hidden")
    time.sleep(0.6)
    assert page.evaluate("document.querySelector('[data-audit-save-status]').textContent") == "Saved on this device"

    maps = page.evaluate("[...document.querySelectorAll('[data-architecture-reveal] li')].map(n=>n.textContent.trim().replace(/^\\d+\\s*/,''))")
    assert maps == ["Formation", "Inheritance", "Recognition", "Choice Audit", "Alignment", "Friction", "Negative Geometry", "Influence / Control", "Becoming", "Personal Architecture"], maps
    assert page.evaluate("document.querySelector('[data-architecture-reveal]').textContent.includes('Where does my life reinforce what matters to me?')")
    assert page.evaluate("document.querySelector('[data-architecture-reveal] a[href=\"/workshop/personal-architecture-map/\"]')!==null && document.querySelector('[data-architecture-reveal] a[href=\"/workshop/\"]')!==null")
    assert page.evaluate("!/Gumroad|Ko-fi|\\$12/.test(document.querySelector('[data-choice-audit]').textContent)")
    assert page.evaluate("performance.getEntriesByType('resource').filter(e=>['fetch','xmlhttprequest','beacon'].includes(e.initiatorType)).length") == 0
    assert all(value not in page.evaluate("location.href") for value in values.values())

    page.call("Page.reload")
    time.sleep(1)
    wait_for(page, "!document.querySelector('[data-audit-returning]').hidden")
    page.evaluate("document.querySelector('[data-audit-continue]').click()")
    wait_for(page, "!document.querySelector('[data-audit-workspace]').hidden")
    persisted = json.loads(page.evaluate("JSON.stringify({then:document.querySelector('[data-temporal=then]').value,after:document.querySelector('[data-temporal=after]').value,now:document.querySelector('[data-temporal=now]').value,response:document.querySelector('[data-counterfactual-response]:checked')?.value,counterfactual:document.querySelector('[data-counterfactual-reflection]').value,supports:document.querySelector('[data-evidence=supports]').value,challenges:document.querySelector('[data-evidence=challenges]').value,alternatives:document.querySelector('[data-evidence=alternatives]').value,uncertainty:document.querySelector('[data-evidence=uncertainty]').value,preservation:document.querySelector('[data-preservation]').value,reflection:document.querySelector('[data-final-reflection]').value,revealed:!document.querySelector('[data-architecture-reveal]').hidden})"))
    expected = {
        "then": values["[data-temporal=then]"], "after": "", "now": values["[data-temporal=now]"],
        "response": "Maybe", "counterfactual": values["[data-counterfactual-reflection]"],
        "supports": values["[data-evidence=supports]"], "challenges": values["[data-evidence=challenges]"],
        "alternatives": values["[data-evidence=alternatives]"], "uncertainty": values["[data-evidence=uncertainty]"],
        "preservation": values["[data-preservation]"], "reflection": "I notice a relationship without asking the audit to interpret it", "revealed": True,
    }
    assert persisted == expected, persisted
    assert not page.evaluate("document.documentElement.scrollWidth > document.documentElement.clientWidth")
    page.ws.close()

    mobile = new_page(args.debug_port, width=390, height=844)
    navigate(mobile, args.url)
    assert not mobile.evaluate("document.documentElement.scrollWidth > document.documentElement.clientWidth")
    assert mobile.evaluate("getComputedStyle(document.querySelector('.choice-temporal')).gridTemplateColumns.split(' ').length") == 1
    mobile.ws.close()

    fallback = new_page(args.debug_port, indexeddb=False, width=390, height=844)
    navigate(fallback, args.url)
    wait_for(fallback, "!document.querySelector('[data-audit-field]').disabled")
    type_into(fallback, "[data-temporal=then]", "Session temporal reflection")
    type_into(fallback, "[data-final-reflection]", "Session final reflection")
    time.sleep(0.6)
    assert fallback.evaluate("document.querySelector('[data-temporal=then]').value") == "Session temporal reflection"
    assert fallback.evaluate("document.querySelector('[data-final-reflection]').value") == "Session final reflection"
    assert fallback.evaluate("!document.querySelector('[data-architecture-reveal]').hidden")
    assert fallback.evaluate("document.querySelector('[data-audit-save-status]').textContent") == "This audit could not be saved on this device. Your current work is still available in this session."
    fallback.ws.close()

    no_js = new_page(args.debug_port, width=390, height=844)
    no_js.call("Emulation.setScriptExecutionDisabled", {"value": True})
    navigate(no_js, args.url)
    assert no_js.evaluate("document.querySelectorAll('[data-temporal]').length===3 && document.querySelectorAll('[data-evidence]').length===4 && document.querySelector('[data-audit-field]').disabled")
    assert no_js.evaluate("document.querySelector('noscript a[href=\"/workshop/\"]')!==null")
    no_js.ws.close()

    print(json.dumps({
        "result": "Choice Audit CA-004 reflection architecture valid",
        "temporal_partial_round_trip": True,
        "counterfactual_round_trip": True,
        "evidence_fields_round_trip": 4,
        "preservation_round_trip": True,
        "final_reflection_round_trip": True,
        "reveal_threshold": "non-empty final reflection",
        "ten_map_sequence": True,
        "keyboard_entry": True,
        "reflection_network_requests": 0,
        "desktop_overflow": False,
        "mobile_390_overflow": False,
        "storage_failure_session_preserved": True,
        "no_javascript_semantics": True,
    }, indent=2))


if __name__ == "__main__":
    main()
