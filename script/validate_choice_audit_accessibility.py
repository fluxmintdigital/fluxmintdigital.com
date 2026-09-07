#!/usr/bin/env python3
"""Adversarial accessibility and privacy checks for the Choice Audit route."""

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
        result = self.call("Runtime.evaluate", {
            "expression": expression,
            "returnByValue": True,
            "awaitPromise": await_promise,
        })
        return result["result"].get("value")


def new_page(port, width=1440, height=1000):
    request = urllib.request.Request(f"http://127.0.0.1:{port}/json/new?about:blank", method="PUT")
    with urllib.request.urlopen(request) as response:
        target = json.load(response)
    page = CDP(target["webSocketDebuggerUrl"])
    page.call("Page.enable")
    page.call("Runtime.enable")
    page.call("Network.enable")
    page.call("Accessibility.enable")
    page.call("Emulation.setDeviceMetricsOverride", {
        "width": width, "height": height, "deviceScaleFactor": 1, "mobile": width < 768,
    })
    return page


def navigate(page, url):
    page.call("Page.navigate", {"url": url})
    for _ in range(50):
        time.sleep(0.1)
        if page.evaluate("document.querySelector('[data-audit-field]') && (!document.querySelector('[data-audit-field]').disabled || !document.querySelector('[data-audit-returning]').hidden)"):
            break
    if page.evaluate("!document.querySelector('[data-audit-returning]').hidden"):
        page.evaluate("document.querySelector('[data-audit-continue]').click()")
        time.sleep(0.2)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True)
    parser.add_argument("--debug-port", type=int, default=9225)
    args = parser.parse_args()
    page = new_page(args.debug_port)
    navigate(page, args.url)

    semantics = page.evaluate("""(()=>({
      main:document.querySelectorAll('main').length,
      forceOrder:[...document.querySelectorAll('[data-force]')].map(n=>n.dataset.force),
      fieldsets:document.querySelectorAll('[data-choice-audit] fieldset').length,
      legends:[...document.querySelectorAll('[data-choice-audit] fieldset>legend')].map(n=>n.textContent.trim()).filter(Boolean),
      unlabeled:[...document.querySelectorAll('[data-choice-audit] textarea,[data-choice-audit] select,[data-choice-audit] input')].filter(n=>!n.labels?.length).length,
      checkboxes:document.querySelectorAll('[data-force-classification][type=checkbox]').length,
      influenceRadios:document.querySelectorAll('[data-force-influence][type=radio]').length,
      counterfactualRadios:document.querySelectorAll('[data-counterfactual-response][type=radio]').length,
      currentStep:document.querySelectorAll('[aria-current=step]').length,
      liveRegions:document.querySelectorAll('[aria-live]').length,
      remoteForms:document.querySelectorAll('[data-choice-audit] form[action]').length
    }))()""")
    assert semantics["main"] == 1
    assert semantics["forceOrder"] == ["desire", "expectation", "security", "opportunity", "identity", "obligation", "fearAvoidance", "possibility"]
    assert semantics["unlabeled"] == 0
    assert semantics["checkboxes"] == 40 and semantics["influenceRadios"] == 24 and semantics["counterfactualRadios"] == 4
    assert semantics["currentStep"] == 1 and semantics["remoteForms"] == 0

    page.call("Emulation.setDeviceMetricsOverride", {"width": 360, "height": 740, "deviceScaleFactor": 1, "mobile": True})
    time.sleep(0.3)
    disclosure = page.evaluate("""(()=>{
      const button=document.querySelector('[data-force-index] [data-force-open=desire]');button.click();
      const body=document.querySelector('#force-desire-body');
      const local=document.querySelector('[data-force=desire] .choice-force__open');
      return {index:button.getAttribute('aria-expanded'),local:local.getAttribute('aria-expanded'),hidden:body.hidden,focus:document.activeElement.matches('[data-force=desire] textarea')};
    })()""")
    assert disclosure == {"index": "true", "local": "true", "hidden": False, "focus": True}, disclosure

    marker = "PRIVATE_CA008_REFLECTION_TOKEN"
    page.evaluate(f"""(()=>{{const n=document.querySelector('[data-audit-choice]');n.value='{marker}';n.dispatchEvent(new Event('input',{{bubbles:true}}));}})()""")
    time.sleep(0.7)
    privacy = page.evaluate(f"""(()=>{{
      const resources=performance.getEntriesByType('resource').map(e=>e.name);
      return {{url:location.href.includes('{marker}'),resource:resources.some(n=>n.includes('{marker}')),storage:(localStorage.length+sessionStorage.length),cookie:document.cookie.includes('{marker}'),network:performance.getEntriesByType('resource').filter(e=>['fetch','xmlhttprequest','beacon'].includes(e.initiatorType)).length}};
    }})()""")
    assert privacy == {"url": False, "resource": False, "storage": 0, "cookie": False, "network": 0}, privacy

    page.evaluate("document.documentElement.style.fontSize='200%'")
    time.sleep(0.3)
    text_stress = page.evaluate("(()=>({overflow:document.documentElement.scrollWidth>innerWidth,clipped:[...document.querySelectorAll('[data-choice-audit] button')].some(n=>n.scrollWidth>n.clientWidth+1)}))()")
    assert not text_stress["overflow"] and not text_stress["clipped"], text_stress

    ax = page.call("Accessibility.getFullAXTree").get("nodes", [])
    names = [node.get("name", {}).get("value", "") for node in ax]
    for expected in ("Write the decision, direction, or moment here.", "Download the printable Choice Audit", "Print My Current Audit"):
        assert expected in names, expected

    page.ws.close()
    print(json.dumps({
        "result": "Choice Audit CA-008 accessibility/privacy hardening valid",
        "native_labels": True,
        "classification_checkboxes": semantics["checkboxes"],
        "influence_radios": semantics["influenceRadios"],
        "counterfactual_radios": semantics["counterfactualRadios"],
        "compact_disclosure_state": True,
        "accessible_names": True,
        "enlarged_text_overflow": False,
        "reflection_network_requests": privacy["network"],
        "reflection_url_or_web_storage_leakage": False,
    }, indent=2))


if __name__ == "__main__":
    main()
