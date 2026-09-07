#!/usr/bin/env python3
"""Validate Choice Audit persistence in a real browser without public UI."""

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


def new_page(port):
    request = urllib.request.Request(f"http://127.0.0.1:{port}/json/new?about:blank", method="PUT")
    with urllib.request.urlopen(request) as response:
        target = json.load(response)
    page = CDP(target["webSocketDebuggerUrl"])
    page.call("Page.enable")
    page.call("Runtime.enable")
    page.call("Network.enable")
    return page


def navigate(page, url):
    page.call("Page.navigate", {"url": url})
    time.sleep(0.5)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True)
    parser.add_argument("--debug-port", type=int, default=9224)
    args = parser.parse_args()

    page = new_page(args.debug_port)
    blocked = []
    navigate(page, f"{args.url}?run=ca002")
    result = page.evaluate("window.choiceAuditModelResult", await_promise=True)
    assert result and result.get("ok"), result

    url_after = page.evaluate("location.href")
    assert "private" not in url_after.lower(), url_after
    entries = page.evaluate("performance.getEntriesByType('resource').map(entry => entry.name)")
    assert not any("private" in entry.lower() for entry in entries), entries

    reflection_requests = page.evaluate("performance.getEntriesByType('resource').filter(entry => ['fetch', 'xmlhttprequest', 'beacon'].includes(entry.initiatorType)).length")
    assert reflection_requests == 0, reflection_requests

    # Reload into a retrieval-only fixture so no create/save call can mask a
    # persistence failure.
    navigate(page, f"{args.url}?verify={result['id']}")
    returning = page.evaluate("window.choiceAuditModelResult", await_promise=True)
    assert returning and returning.get("ok") and returning.get("returning"), returning

    page.ws.close()
    print(json.dumps({
        "result": "Choice Audit local model valid",
        "schema_version": result["schemaVersion"],
        "force_count": result["forces"],
        "indexeddb_reload": True,
        "fallback": result["fallback"],
        "reflection_network_requests": reflection_requests,
        "reflection_in_url": False,
    }, indent=2))


if __name__ == "__main__":
    main()
