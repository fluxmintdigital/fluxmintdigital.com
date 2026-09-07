#!/usr/bin/env python3
"""Exercise the CA-003 working field in a real browser."""

import argparse
import json
import time
import urllib.parse
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
        result = self.call("Runtime.evaluate", {
            "expression": expression,
            "returnByValue": True,
            "awaitPromise": await_promise,
        })
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
    page.call("Emulation.setDeviceMetricsOverride", {
        "width": width,
        "height": height,
        "deviceScaleFactor": 1,
        "mobile": width < 768,
    })
    if not indexeddb:
        page.call("Page.addScriptToEvaluateOnNewDocument", {
            "source": "Object.defineProperty(globalThis, 'indexedDB', { configurable: false, value: null });"
        })
    return page


def navigate(page, url):
    page.call("Page.navigate", {"url": url})
    time.sleep(1)


def wait_for(page, expression, attempts=30):
    for _ in range(attempts):
        if page.evaluate(expression):
            return
        time.sleep(0.1)
    raise AssertionError(f"Timed out: {expression}")


def key(page, value, code):
    page.call("Input.dispatchKeyEvent", {"type": "keyDown", "key": value, "code": code})
    page.call("Input.dispatchKeyEvent", {"type": "keyUp", "key": value, "code": code})


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True)
    parser.add_argument("--debug-port", type=int, default=9225)
    args = parser.parse_args()
    parsed = urllib.parse.urlparse(args.url)
    origin = f"{parsed.scheme}://{parsed.netloc}"

    page = new_page(args.debug_port)
    navigate(page, args.url)
    wait_for(page, "document.querySelector('[data-audit-field]') && (!document.querySelector('[data-audit-field]').disabled || !document.querySelector('[data-audit-returning]').hidden)")
    page.evaluate("import('/assets/js/choice-audit-model.js').then(async m=>{const r=m.createAuditRepository();await r.ready;for(const audit of await r.list())await r.delete(audit.id);r.close();return true})", await_promise=True)
    page.call("Page.reload")
    time.sleep(1)
    wait_for(page, "!document.querySelector('[data-audit-field]').disabled")

    structure = json.loads(page.evaluate("JSON.stringify((()=>{const r=document.querySelector('[data-choice-audit]');return {forces:[...r.querySelectorAll('[data-force]')].map(n=>n.dataset.force),reflections:r.querySelectorAll('[data-force-reflection]').length,classifications:r.querySelectorAll('[data-force-classification]').length,influences:r.querySelectorAll('[data-force-influence]').length,privacy:r.querySelector('[aria-label=\"Privacy receipt\"]')?.textContent,progress:r.querySelector('progress,[role=progressbar]')!==null,acquisition:/Gumroad|Ko-fi|\\$12/.test(r.textContent)}})())"))
    assert structure["forces"] == ["desire", "expectation", "security", "opportunity", "identity", "obligation", "fearAvoidance", "possibility"], structure
    assert structure["reflections"] == 8 and structure["classifications"] == 40 and structure["influences"] == 24, structure
    assert "Your map is yours" in structure["privacy"] and not structure["progress"] and not structure["acquisition"], structure

    # Use normal DOM input events, then activate native controls from the
    # keyboard to verify their built-in semantics remain available.
    page.evaluate("(()=>{const set=(selector,value)=>{const n=document.querySelector(selector);n.value=value;n.dispatchEvent(new Event('input',{bubbles:true}))};set('[data-audit-choice]','Private reload test');set('[data-force=desire] [data-force-reflection]','A local desire');const w=document.querySelector('[data-force=desire] [value=W]');w.checked=true;w.dispatchEvent(new Event('change',{bubbles:true}));})()")
    page.evaluate("document.querySelector('[data-force=desire] [value=P]').focus()")
    key(page, " ", "Space")
    assert page.evaluate("document.querySelector('[data-force=desire] [value=P]').checked") is True
    page.evaluate("document.querySelector('[data-force=desire] [value=\"3\"]').focus()")
    key(page, " ", "Space")
    assert page.evaluate("document.querySelector('[data-force=desire] [value=\"3\"]').checked") is True

    page.evaluate("(()=>{document.querySelector('[data-relationship-from]').value='desire';document.querySelector('[data-relationship-to]').value='security';document.querySelector('[data-relationship-add]').focus()})()")
    key(page, " ", "Space")
    wait_for(page, "document.querySelectorAll('[data-relationship-list] li').length===1")
    time.sleep(0.6)
    assert page.evaluate("document.querySelector('[data-audit-save-status]').textContent") == "Saved on this device"
    assert page.evaluate("performance.getEntriesByType('resource').filter(e=>['fetch','xmlhttprequest','beacon'].includes(e.initiatorType)).length") == 0
    assert "Private reload test" not in page.evaluate("location.href")

    page.call("Page.reload")
    time.sleep(1)
    wait_for(page, "!document.querySelector('[data-audit-returning]').hidden")
    assert "Your previous map is still here on this device" in page.evaluate("document.querySelector('[data-audit-returning]').textContent")
    page.evaluate("document.querySelector('[data-audit-continue]').focus()")
    key(page, " ", "Space")
    wait_for(page, "!document.querySelector('[data-audit-workspace]').hidden")
    reloaded = json.loads(page.evaluate("JSON.stringify({choice:document.querySelector('[data-audit-choice]').value,reflection:document.querySelector('[data-force=desire] [data-force-reflection]').value,w:document.querySelector('[data-force=desire] [value=W]').checked,p:document.querySelector('[data-force=desire] [value=P]').checked,influence:document.querySelector('[data-force=desire] [value=\"3\"]').checked,relationships:document.querySelectorAll('[data-relationship-list] li').length})"))
    assert reloaded == {"choice": "Private reload test", "reflection": "A local desire", "w": True, "p": True, "influence": True, "relationships": 1}, reloaded

    page.evaluate("document.querySelector('[data-relationship-remove]').focus()")
    key(page, " ", "Space")
    wait_for(page, "document.querySelectorAll('[data-relationship-list] li').length===0")
    time.sleep(0.6)
    page.evaluate("document.querySelector('.choice-audit__toolbar [data-audit-new]').focus()")
    key(page, " ", "Space")
    wait_for(page, "document.querySelector('[data-audit-choice]').value==='' && document.querySelector('[data-audit-choice]')===document.activeElement")
    records = page.evaluate("import('/assets/js/choice-audit-model.js').then(async m=>{const r=m.createAuditRepository();await r.ready;const a=await r.list();r.close();return {count:a.length,removed:a.find(x=>x.choice==='Private reload test')?.relationships.length}})", await_promise=True)
    assert records == {"count": 2, "removed": 0}, records
    overflow = page.evaluate("document.documentElement.scrollWidth > document.documentElement.clientWidth")
    assert not overflow
    page.ws.close()

    mobile = new_page(args.debug_port, width=390, height=844)
    navigate(mobile, args.url)
    assert not mobile.evaluate("document.documentElement.scrollWidth > document.documentElement.clientWidth")
    assert mobile.evaluate("getComputedStyle(document.querySelector('[data-audit-forces]')).gridTemplateColumns.split(' ').length") == 1
    mobile.ws.close()

    fallback = new_page(args.debug_port, indexeddb=False, width=390, height=844)
    navigate(fallback, args.url)
    wait_for(fallback, "!document.querySelector('[data-audit-field]').disabled")
    assert fallback.evaluate("document.querySelector('[data-audit-save-status]').textContent") == "This audit could not be saved on this device. Your current work is still available in this session."
    fallback.evaluate("(()=>{const n=document.querySelector('[data-audit-choice]');n.value='Session-only reflection';n.dispatchEvent(new Event('input',{bubbles:true}))})()")
    time.sleep(0.6)
    assert fallback.evaluate("document.querySelector('[data-audit-choice]').value") == "Session-only reflection"
    assert fallback.evaluate("performance.getEntriesByType('resource').filter(e=>['fetch','xmlhttprequest','beacon'].includes(e.initiatorType)).length") == 0
    fallback.ws.close()

    no_js = new_page(args.debug_port, width=390, height=844)
    no_js.call("Emulation.setScriptExecutionDisabled", {"value": True})
    navigate(no_js, args.url)
    no_js_state = json.loads(no_js.evaluate("JSON.stringify({forces:document.querySelectorAll('[data-force]').length,disabled:document.querySelector('[data-audit-field]').disabled,workspaceHidden:document.querySelector('[data-audit-workspace]').hidden,mapLink:!!document.querySelector('noscript a[href=\"/workshop/personal-architecture-map/\"]'),workshopLink:!!document.querySelector('noscript a[href=\"/workshop/\"]')})"))
    assert no_js_state == {"forces": 8, "disabled": True, "workspaceHidden": False, "mapLink": True, "workshopLink": True}, no_js_state
    no_js.ws.close()

    print(json.dumps({
        "result": "Choice Audit CA-003 working field valid",
        "force_regions": 8,
        "reload_round_trip": True,
        "relationship_create_remove": True,
        "distinct_local_audits": records["count"],
        "keyboard_controls": True,
        "desktop_overflow": False,
        "mobile_390_overflow": False,
        "storage_failure_session_preserved": True,
        "no_javascript_semantics": True,
        "reflection_network_requests": 0,
    }, indent=2))


if __name__ == "__main__":
    main()
