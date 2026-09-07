#!/usr/bin/env python3
"""Validate CA-006 canonical PDF delivery and local current-audit printing."""

import argparse
import base64
import json
import pathlib
import subprocess
import tempfile
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


def command(*args):
    return subprocess.run(args, check=True, capture_output=True, text=True).stdout


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True)
    parser.add_argument("--debug-port", type=int, default=9225)
    parser.add_argument("--site", default="_site")
    args = parser.parse_args()
    site = pathlib.Path(args.site)
    free_pdf = site / "assets/downloads/FluxMintDigital_Choice_Audit_Free_v1.pdf"
    source_pdf = pathlib.Path("FluxMintDigital_Website_Canonical_Package/Assets/source/FluxMintDigital_The_Personal_Architecture_Map_v1.pdf")
    source_cover = pathlib.Path("FluxMintDigital_Website_Canonical_Package/Assets/source/FMD_PERSONAL_ARCHITECTURE_MAP_COVER_v1.png")
    assert free_pdf.is_file()
    info = command("pdfinfo", str(free_pdf))
    assert "Pages:           3" in info and "Page size:       612 x 792 pts (letter)" in info, info
    pdf_text = command("pdftotext", str(free_pdf), "-")
    normalized_pdf_text = " ".join(pdf_text.split())
    for phrase in ("What participated in this choice?", "A choice can belong to you without having originated only from you.", "Influence is qualitative, not a score or causal measurement.", "What here appears worth preserving?", "BEFORE YOU DECIDE WHAT IT MEANS"):
        assert phrase in normalized_pdf_text, phrase
    assert not any(term in pdf_text for term in ("Gumroad", "Ko-fi", "checkout", "$12"))
    assert command("sha256sum", str(source_pdf)).split()[0] == "abc22d32ff9596a5f36302f1c2080cd0c4b71c31955e434e08d580d7e34796cd"
    assert command("sha256sum", str(source_cover)).split()[0] == "914a1f69bf8085c467548386e378024130b37e76cf1ea9c87f3228bd9fd37c28"
    assert not (site / source_pdf).exists() and not (site / source_cover).exists()

    request = urllib.request.Request(f"http://127.0.0.1:{args.debug_port}/json/new?about:blank", method="PUT")
    with urllib.request.urlopen(request) as response:
        target = json.load(response)
    page = CDP(target["webSocketDebuggerUrl"])
    page.call("Page.enable")
    page.call("Runtime.enable")
    page.call("Emulation.setDeviceMetricsOverride", {"width": 1440, "height": 1000, "deviceScaleFactor": 1, "mobile": False})
    page.call("Page.navigate", {"url": args.url})
    for _ in range(30):
        time.sleep(.1)
        if page.evaluate("document.querySelector('[data-audit-field]') && (!document.querySelector('[data-audit-field]').disabled || !document.querySelector('[data-audit-returning]').hidden)"):
            break
    if page.evaluate("!document.querySelector('[data-audit-returning]').hidden"):
        page.evaluate("document.querySelector('[data-audit-continue]').click()")
    for _ in range(30):
        if page.evaluate("!document.querySelector('[data-audit-print]').disabled"):
            break
        time.sleep(.1)
    assert page.evaluate("!document.querySelector('[data-audit-print]').disabled")
    labels = page.evaluate("[...document.querySelectorAll('.choice-audit__print-options :is(a,button)')].map(n=>n.textContent.trim())")
    assert labels == ["Download the printable Choice Audit", "Print My Current Audit"], labels

    # Empty and partial maps retain all eight force regions without completion language.
    page.evaluate("document.querySelector('.choice-audit__toolbar [data-audit-new]').click()")
    time.sleep(.4)
    page.evaluate("dispatchEvent(new Event('beforeprint'))")
    empty_print = page.evaluate("document.querySelector('[data-audit-print-output]').innerText")
    assert page.evaluate("document.querySelectorAll('[data-audit-print-output] .choice-audit-print__force').length") == 8
    assert "incomplete" not in empty_print.lower() and "remaining" not in empty_print.lower()
    page.evaluate("(()=>{const n=document.querySelector('[data-force=identity] [data-force-reflection]');n.value='One partial reflection';n.dispatchEvent(new Event('input',{bubbles:true}));dispatchEvent(new Event('beforeprint'))})()")
    partial_print = page.evaluate("document.querySelector('[data-audit-print-output]').innerText")
    assert "One partial reflection" in partial_print and page.evaluate("document.querySelectorAll('[data-audit-print-output] .choice-audit-print__force').length") == 8

    # Dense local-only fixture exercises every static conversion path.
    page.evaluate("""(()=>{
      const set=(selector,value)=>{const n=document.querySelector(selector);n.value=value;n.dispatchEvent(new Event('input',{bubbles:true}))};
      set('[data-audit-choice]','A private dense choice for print validation');
      document.querySelectorAll('[data-force]').forEach((r,i)=>{set(`[data-force="${r.dataset.force}"] [data-force-reflection]`,`Private reflection ${i+1} `.repeat(8));const c=r.querySelectorAll('[data-force-classification]');c[i%5].checked=true;c[(i+2)%5].checked=true;c[i%5].dispatchEvent(new Event('change',{bubbles:true}));const influence=r.querySelector(`[data-force-influence][value="${i%3+1}"]`);influence.checked=true;influence.dispatchEvent(new Event('change',{bubbles:true}))});
      document.querySelector('[data-relationship-from]').value='desire';document.querySelector('[data-relationship-to]').value='identity';document.querySelector('[data-relationship-add]').click();
      set('[data-temporal=then]','Private then');set('[data-temporal=after]','Private after');set('[data-temporal=now]','Private now');
      const cf=document.querySelector('[data-counterfactual-response][value=Maybe]');cf.checked=true;cf.dispatchEvent(new Event('change',{bubbles:true}));set('[data-counterfactual-reflection]','Private counterfactual');
      set('[data-evidence=supports]','Private support');set('[data-evidence=challenges]','Private challenge');set('[data-evidence=alternatives]','Private alternative');set('[data-evidence=uncertainty]','Private uncertainty');set('[data-preservation]','Private preservation');set('[data-final-reflection]','Private noticing');
      dispatchEvent(new Event('beforeprint'));
    })()""")
    printed = page.evaluate("document.querySelector('[data-audit-print-output]').innerText")
    for phrase in ("A private dense choice", "W · N", "• Present", "•• Significant", "••• Dominant", "Desire ↔ Identity · Interaction", "Private then", "Maybe", "Private support", "Private preservation", "Private noticing"):
        assert phrase in printed, phrase
    assert not any(term in printed for term in ("Gumroad", "Ko-fi", "$12", "Saving locally", "Start another audit", "Contains material"))
    reflection_requests = page.evaluate("performance.getEntriesByType('resource').filter(e=>['fetch','xmlhttprequest','beacon'].includes(e.initiatorType)).length")
    assert reflection_requests == 0
    assert "private" not in page.evaluate("location.href").lower()

    page.call("Emulation.setEmulatedMedia", {"media": "print"})
    print_layout = page.evaluate("(()=>{const n=document.querySelector('[data-audit-print-output]'),f=n.firstElementChild,s=getComputedStyle(f);return {output:getComputedStyle(n).display,choice:getComputedStyle(n.closest('.choice-audit')).display,prose:getComputedStyle(n.closest('.prose')).display,content:getComputedStyle(n.closest('.artifact-detail__content')).display,artifact:getComputedStyle(n.closest('.artifact-detail')).display,main:getComputedStyle(n.closest('main')).display,height:n.getBoundingClientRect().height,children:n.children.length,first:s.display,firstPosition:s.position,firstHeight:f.getBoundingClientRect().height,visibility:s.visibility}})()")
    assert print_layout["output"] != "none" and print_layout["height"] > 0, print_layout
    result = page.call("Page.printToPDF", {"printBackground": True, "preferCSSPageSize": True})
    with tempfile.NamedTemporaryFile(suffix=".pdf") as temporary:
        temporary.write(base64.b64decode(result["data"]))
        temporary.flush()
        current_info = command("pdfinfo", temporary.name)
        current_text = command("pdftotext", temporary.name, "-")
        with tempfile.TemporaryDirectory() as grayscale_directory:
            grayscale_target = pathlib.Path(grayscale_directory) / "current-audit-gray"
            subprocess.run(["pdftoppm", "-gray", "-f", "1", "-singlefile", "-png", temporary.name, str(grayscale_target)], check=True, capture_output=True)
            assert grayscale_target.with_suffix(".png").stat().st_size > 0
    normalized_current_text = " ".join(current_text.split())
    assert "Pages:" in current_info and "A private dense choice" in normalized_current_text, {"info": current_info, "text": normalized_current_text[:1000]}
    assert "FluxMintDigital" in normalized_current_text and "Your map is yours" in normalized_current_text
    assert not any(term in current_text for term in ("Studio Library Workshop", "Gumroad", "Ko-fi", "$12", "Start another audit", "Add ↔ Interaction"))

    print(json.dumps({
        "result": "Choice Audit CA-006 print/export valid",
        "canonical_pdf_pages": 3,
        "canonical_pdf_letter": True,
        "current_audit_print_pages": int(next(line.split(":", 1)[1] for line in current_info.splitlines() if line.startswith("Pages:"))),
        "static_state_conversion": True,
        "empty_partial_dense": True,
        "grayscale_render": True,
        "reflection_network_requests": 0,
        "source_pdf_excluded": True,
        "source_hashes_preserved": True,
    }, indent=2))


if __name__ == "__main__":
    main()
