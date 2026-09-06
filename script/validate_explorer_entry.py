#!/usr/bin/env python3
"""Exercise Explorer Entry progressive-enhancement lifecycle through Chrome CDP."""

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
        return self.call("Runtime.evaluate", {"expression": expression, "returnByValue": True})["result"].get("value")


def new_page(port):
    request = urllib.request.Request(f"http://127.0.0.1:{port}/json/new?about:blank", method="PUT")
    with urllib.request.urlopen(request) as response:
        target = json.load(response)
    page = CDP(target["webSocketDebuggerUrl"])
    page.call("Page.enable")
    page.call("Runtime.enable")
    page.call("Network.enable")
    page.call("Page.addScriptToEvaluateOnNewDocument", {"source": """
      (() => {
        const activeTimeouts = new Set();
        const activeFrames = new Set();
        const nativeTimeout = window.setTimeout.bind(window);
        const nativeClearTimeout = window.clearTimeout.bind(window);
        const nativeFrame = window.requestAnimationFrame.bind(window);
        const nativeCancelFrame = window.cancelAnimationFrame.bind(window);
        window.setTimeout = (callback, delay, ...args) => {
          let id = nativeTimeout((...callbackArgs) => { activeTimeouts.delete(id); callback(...callbackArgs); }, delay, ...args);
          activeTimeouts.add(id); return id;
        };
        window.clearTimeout = id => { activeTimeouts.delete(id); nativeClearTimeout(id); };
        window.requestAnimationFrame = callback => {
          let id = nativeFrame(time => { activeFrames.delete(id); callback(time); });
          activeFrames.add(id); return id;
        };
        window.cancelAnimationFrame = id => { activeFrames.delete(id); nativeCancelFrame(id); };
        window.__explorerTimerCounts = () => ({timeouts: activeTimeouts.size, frames: activeFrames.size});
      })();
    """})
    page.call("Emulation.setDeviceMetricsOverride", {"width": 390, "height": 844, "deviceScaleFactor": 1, "mobile": True})
    return page


def state(page):
    return json.loads(page.evaluate("JSON.stringify((()=>{const r=document.querySelector('[data-explorer-idle]');return {state:r.dataset.animationState||'',hidden:r.hidden,src:r.querySelector('img').currentSrc}})())"))


def navigate(page):
    page.call("Page.navigate", {"url": "http://127.0.0.1:4010/"})
    time.sleep(1.5)


def main():
    page = new_page(9223)
    navigate(page)
    initial_frames = page.evaluate("performance.getEntriesByType('resource').filter(r=>r.name.includes('EXPLORERENTRY_DJ_IDLE')).length")
    assert initial_frames <= 1, f"idle sequence loaded before approach: {initial_frames} resources"
    page.evaluate("document.querySelector('#explorer-entry').scrollIntoView({block:'start'})")
    time.sleep(5.5)
    approached = state(page)
    assert approached["state"] in ("ready", "playing", "paused"), approached
    loaded = page.evaluate("new Set(performance.getEntriesByType('resource').filter(r=>r.name.includes('EXPLORERENTRY_DJ_IDLE')).map(r=>r.name)).size")
    assert 12 <= loaded <= 13, f"unexpected selected delivery load count: {loaded}"

    page.evaluate("window.scrollTo(0,0)")
    time.sleep(0.5)
    offscreen = state(page)
    assert offscreen["state"] == "paused", offscreen
    held_src = offscreen["src"]
    time.sleep(2)
    assert state(page)["src"] == held_src, "offscreen frame continued changing"

    page.evaluate("document.querySelector('#explorer-entry').scrollIntoView({block:'start'})")
    time.sleep(0.5)
    page.evaluate("Object.defineProperty(document,'visibilityState',{configurable:true,get:()=> 'hidden'});document.dispatchEvent(new Event('visibilitychange'))")
    time.sleep(0.2)
    assert state(page)["state"] == "paused", state(page)
    page.evaluate("Object.defineProperty(document,'visibilityState',{configurable:true,get:()=> 'visible'});document.dispatchEvent(new Event('visibilitychange'))")
    time.sleep(0.2)
    assert state(page)["state"] in ("ready", "paused"), state(page)
    for _ in range(4):
        page.evaluate("window.scrollTo(0,0)")
        time.sleep(0.15)
        page.evaluate("document.querySelector('#explorer-entry').scrollIntoView({block:'start'})")
        time.sleep(0.15)
    timer_counts = json.loads(page.evaluate("JSON.stringify(window.__explorerTimerCounts())"))
    assert timer_counts["timeouts"] <= 1 and timer_counts["frames"] <= 1, timer_counts
    page.ws.close()

    failed = new_page(9223)
    failed.call("Network.setBlockedURLs", {"urls": ["*FMD_CHAR_EXPLORERENTRY_DJ_IDLE_F06_320W_v001.webp"]})
    navigate(failed)
    failed.evaluate("document.querySelector('#explorer-entry').scrollIntoView({block:'start'})")
    time.sleep(2)
    failed_state = state(failed)
    assert failed_state["state"] == "static" and not failed_state["hidden"], failed_state
    failed.ws.close()

    slow = new_page(9223)
    slow.call("Network.emulateNetworkConditions", {
        "offline": False,
        "latency": 500,
        "downloadThroughput": 200 * 1024 / 8,
        "uploadThroughput": 20 * 1024 / 8,
        "connectionType": "cellular3g"
    })
    navigate(slow)
    for _ in range(20):
        if slow.evaluate("Boolean(document.querySelector('[data-explorer-idle]'))"):
            break
        time.sleep(0.5)
    assert slow.evaluate("Boolean(document.querySelector('[data-explorer-idle]'))"), "slow-network DOM did not become available"
    for _ in range(40):
        styled = slow.evaluate("(()=>{const r=document.querySelector('[data-explorer-idle]');return getComputedStyle(r).position==='absolute' && r.getBoundingClientRect().width<250})()")
        if styled:
            break
        time.sleep(0.5)
    assert styled, "Explorer reserved layout CSS did not become available"
    slow.evaluate("document.querySelector('#explorer-entry').scrollIntoView({block:'start'})")
    time.sleep(0.5)
    before = json.loads(slow.evaluate("JSON.stringify((()=>{const r=document.querySelector('[data-explorer-idle]').getBoundingClientRect();return {x:r.x,y:r.y,width:r.width,height:r.height}})())"))
    time.sleep(2)
    after = json.loads(slow.evaluate("JSON.stringify((()=>{const r=document.querySelector('[data-explorer-idle]').getBoundingClientRect();return {x:r.x,y:r.y,width:r.width,height:r.height}})())"))
    assert before["width"] == after["width"] and before["height"] == after["height"], {"before": before, "after": after}
    slow.ws.close()

    print(json.dumps({
        "lazy_initial_resources": initial_frames,
        "selected_sequence_resources": loaded,
        "approach_state": approached,
        "offscreen_state": offscreen,
        "failed_frame_state": failed_state,
        "active_work_after_repeated_visibility": timer_counts,
        "slow_network_layout_rect": after,
        "result": "Explorer lifecycle valid"
    }, indent=2))


if __name__ == "__main__":
    main()
