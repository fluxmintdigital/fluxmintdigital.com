import { FORCE_KEYS, STORAGE_FAILURE_MESSAGE, createAuditRepository } from "./choice-audit-model.js";

const FORCE_NAMES = Object.freeze({
  desire: "Desire",
  expectation: "Expectation",
  security: "Security",
  opportunity: "Opportunity",
  identity: "Identity",
  obligation: "Obligation",
  fearAvoidance: "Fear & Avoidance",
  possibility: "Possibility"
});
const INFLUENCE_NAMES = Object.freeze({ 1: "Present", 2: "Significant", 3: "Dominant" });

class ChoiceAuditController {
  constructor(root, repository = createAuditRepository()) {
    this.root = root;
    this.repository = repository;
    this.audit = null;
    this.saveTimer = 0;
    this.saveVersion = 0;
    this.field = root.querySelector("[data-audit-field]");
    this.workspace = root.querySelector("[data-audit-workspace]");
    this.returning = root.querySelector("[data-audit-returning]");
    this.saveStatus = root.querySelector("[data-audit-save-status]");
    this.relationshipMessage = root.querySelector("[data-relationship-message]");
    this.compactMedia = window.matchMedia("(max-width: 767px)");
    this.activeForce = null;
    this.handleInput = this.handleInput.bind(this);
    this.handleClick = this.handleClick.bind(this);
    this.handleVisibility = this.handleVisibility.bind(this);
    this.handlePageHide = this.handlePageHide.bind(this);
    this.handleBreakpoint = this.handleBreakpoint.bind(this);
    this.handleBeforePrint = this.handleBeforePrint.bind(this);
    this.handleAfterPrint = this.handleAfterPrint.bind(this);
  }

  async initialize() {
    await this.repository.ready;
    this.root.addEventListener("input", this.handleInput);
    this.root.addEventListener("change", this.handleInput);
    this.root.addEventListener("click", this.handleClick);
    document.addEventListener("visibilitychange", this.handleVisibility);
    window.addEventListener("pagehide", this.handlePageHide);
    window.addEventListener("beforeprint", this.handleBeforePrint);
    window.addEventListener("afterprint", this.handleAfterPrint);
    this.compactMedia.addEventListener("change", this.handleBreakpoint);
    this.handleBreakpoint();
    this.root.querySelectorAll("[data-audit-new], [data-audit-continue]").forEach((control) => { control.disabled = false; });
    this.root.querySelector("[data-audit-print]").disabled = false;
    const audits = await this.repository.list();
    if (audits.length) {
      this.audit = audits[0];
      this.returning.hidden = false;
      this.workspace.hidden = true;
    } else {
      await this.startNewAudit(false);
    }
    this.showStorageState();
  }

  async startNewAudit(focusChoice = true) {
    await this.flushSave();
    this.audit = await this.repository.create();
    this.renderAudit();
    this.returning.hidden = true;
    this.workspace.hidden = false;
    this.field.disabled = false;
    this.showStorageState();
    if (focusChoice) this.root.querySelector("[data-audit-choice]").focus();
  }

  continueAudit() {
    this.renderAudit();
    this.returning.hidden = true;
    this.workspace.hidden = false;
    this.field.disabled = false;
    this.showStorageState();
    this.root.querySelector("[data-audit-choice]").focus();
  }

  renderAudit() {
    this.root.querySelector("[data-audit-choice]").value = this.audit.choice;
    this.root.querySelectorAll("[data-force]").forEach((region) => {
      const entry = this.audit.forces[region.dataset.force];
      region.querySelector("[data-force-reflection]").value = entry.reflection;
      region.querySelectorAll("[data-force-classification]").forEach((control) => {
        control.checked = entry.classifications.includes(control.value);
      });
      region.querySelectorAll("[data-force-influence]").forEach((control) => {
        control.checked = Number(control.value) === entry.influence;
      });
      this.updateForceState(region);
    });
    this.renderRelationships();
    Object.entries(this.audit.temporal).forEach(([key, value]) => {
      this.root.querySelector(`[data-temporal="${key}"]`).value = value;
    });
    this.root.querySelector("[data-counterfactual-reflection]").value = this.audit.counterfactual.reflection;
    this.root.querySelectorAll("[data-counterfactual-response]").forEach((control) => {
      control.checked = control.value === this.audit.counterfactual.response;
    });
    Object.entries(this.audit.evidence).forEach(([key, value]) => {
      this.root.querySelector(`[data-evidence="${key}"]`).value = value;
    });
    this.root.querySelector("[data-preservation]").value = this.audit.preservation;
    this.root.querySelector("[data-final-reflection]").value = this.audit.reflection;
    this.updateArchitectureReveal();
  }

  readAuditFromField() {
    this.audit.choice = this.root.querySelector("[data-audit-choice]").value;
    this.root.querySelectorAll("[data-force]").forEach((region) => {
      const entry = this.audit.forces[region.dataset.force];
      entry.reflection = region.querySelector("[data-force-reflection]").value;
      entry.classifications = [...region.querySelectorAll("[data-force-classification]:checked")].map((control) => control.value);
      const selectedInfluence = region.querySelector("[data-force-influence]:checked");
      entry.influence = selectedInfluence ? Number(selectedInfluence.value) : null;
      this.updateForceState(region);
    });
    this.root.querySelectorAll("[data-temporal]").forEach((control) => { this.audit.temporal[control.dataset.temporal] = control.value; });
    const counterfactualResponse = this.root.querySelector("[data-counterfactual-response]:checked");
    this.audit.counterfactual.response = counterfactualResponse ? counterfactualResponse.value : "";
    this.audit.counterfactual.reflection = this.root.querySelector("[data-counterfactual-reflection]").value;
    this.root.querySelectorAll("[data-evidence]").forEach((control) => { this.audit.evidence[control.dataset.evidence] = control.value; });
    this.audit.preservation = this.root.querySelector("[data-preservation]").value;
    this.audit.reflection = this.root.querySelector("[data-final-reflection]").value;
    this.updateArchitectureReveal();
  }

  handleInput(event) {
    if (!this.audit || !event.target.closest("[data-audit-field]")) return;
    if (!event.target.matches("textarea, [data-force-classification], [data-force-influence], [data-counterfactual-response]")) return;
    this.readAuditFromField();
    if (event.type === "change" && event.target.matches("[data-force-classification], [data-force-influence]")) {
      this.announceForceState(event.target.closest("[data-force]"));
    }
    this.scheduleSave();
  }

  async handleClick(event) {
    if (event.target.closest("[data-audit-print]")) {
      await this.printCurrentAudit();
      return;
    }
    const newButton = event.target.closest("[data-audit-new]");
    if (newButton) {
      await this.startNewAudit();
      return;
    }
    if (event.target.closest("[data-audit-continue]")) {
      this.continueAudit();
      return;
    }
    const clearButton = event.target.closest("[data-force-clear-influence]");
    if (clearButton) {
      const region = clearButton.closest("[data-force]");
      region.querySelectorAll("[data-force-influence]").forEach((control) => { control.checked = false; });
      this.readAuditFromField();
      this.announceForceState(region);
      this.scheduleSave();
      return;
    }
    const openButton = event.target.closest("[data-force-open]");
    if (openButton) {
      this.focusForce(openButton.dataset.forceOpen);
      return;
    }
    if (event.target.closest("[data-force-return]")) {
      this.showWholeMap();
      return;
    }
    if (event.target.closest("[data-counterfactual-clear]")) {
      this.root.querySelectorAll("[data-counterfactual-response]").forEach((control) => { control.checked = false; });
      this.readAuditFromField();
      this.scheduleSave();
      return;
    }
    if (event.target.closest("[data-relationship-add]")) {
      this.addRelationship();
      return;
    }
    const removeButton = event.target.closest("[data-relationship-remove]");
    if (removeButton) this.removeRelationship(Number(removeButton.dataset.relationshipRemove));
  }

  addRelationship() {
    const fromControl = this.root.querySelector("[data-relationship-from]");
    const toControl = this.root.querySelector("[data-relationship-to]");
    const from = fromControl.value;
    const to = toControl.value;
    if (!FORCE_KEYS.includes(from) || !FORCE_KEYS.includes(to) || from === to) {
      this.relationshipMessage.textContent = "Choose two different forces.";
      return;
    }
    const exists = this.audit.relationships.some((relationship) =>
      (relationship.from === from && relationship.to === to) || (relationship.from === to && relationship.to === from));
    if (exists) {
      this.relationshipMessage.textContent = "That interaction is already present.";
      return;
    }
    this.audit.relationships.push({ type: "interaction", from, to });
    fromControl.value = "";
    toControl.value = "";
    this.relationshipMessage.textContent = `${FORCE_NAMES[from]} and ${FORCE_NAMES[to]} are now connected by an interaction.`;
    this.renderRelationships();
    this.scheduleSave();
  }

  removeRelationship(index) {
    const relationship = this.audit.relationships[index];
    if (!relationship) return;
    this.audit.relationships.splice(index, 1);
    this.relationshipMessage.textContent = `${FORCE_NAMES[relationship.from]} and ${FORCE_NAMES[relationship.to]} are no longer connected.`;
    this.renderRelationships();
    this.scheduleSave();
  }

  renderRelationships() {
    const list = this.root.querySelector("[data-relationship-list]");
    list.replaceChildren();
    this.audit.relationships.forEach((relationship, index) => {
      const item = document.createElement("li");
      const description = document.createElement("span");
      description.textContent = `${FORCE_NAMES[relationship.from]} ↔ ${FORCE_NAMES[relationship.to]} · Interaction`;
      const button = document.createElement("button");
      button.type = "button";
      button.dataset.relationshipRemove = String(index);
      button.textContent = "Remove";
      button.setAttribute("aria-label", `Remove interaction between ${FORCE_NAMES[relationship.from]} and ${FORCE_NAMES[relationship.to]}`);
      item.append(description, button);
      list.append(item);
    });
  }

  updateArchitectureReveal() {
    const reveal = this.root.querySelector("[data-architecture-reveal]");
    reveal.hidden = !this.audit.reflection.trim();
  }

  updateForceState(region) {
    const entry = this.audit.forces[region.dataset.force];
    const inhabited = Boolean(entry.reflection || entry.classifications.length || entry.influence);
    region.classList.toggle("choice-force--inhabited", inhabited);
    const indexState = this.root.querySelector(`[data-force-index-state="${region.dataset.force}"]`);
    if (indexState) indexState.hidden = !inhabited;
  }

  announceForceState(region) {
    const entry = this.audit.forces[region.dataset.force];
    const parts = [];
    if (entry.reflection) parts.push("reflection added");
    if (entry.classifications.length) parts.push(`participation ${entry.classifications.join(", ")}`);
    if (entry.influence) parts.push(`influence ${INFLUENCE_NAMES[entry.influence]}`);
    region.querySelector("[data-force-announcement]").textContent = `${FORCE_NAMES[region.dataset.force]}: ${parts.length ? parts.join("; ") : "blank, and still valid"}.`;
  }

  scheduleSave() {
    window.clearTimeout(this.saveTimer);
    const version = ++this.saveVersion;
    this.saveStatus.textContent = this.repository.status().persistent ? "Saving locally…" : STORAGE_FAILURE_MESSAGE;
    this.saveTimer = window.setTimeout(() => this.persist(version), 300);
  }

  async persist(version = ++this.saveVersion) {
    if (!this.audit) return;
    window.clearTimeout(this.saveTimer);
    this.saveTimer = 0;
    const saved = await this.repository.save(this.audit);
    if (version < this.saveVersion) return;
    this.audit = saved;
    this.showStorageState();
  }

  async flushSave() {
    if (!this.audit || (!this.saveTimer && !this.root.contains(document.activeElement))) return;
    this.readAuditFromField();
    await this.persist();
  }

  showStorageState() {
    const state = this.repository.status();
    this.saveStatus.textContent = state.persistent ? "Saved on this device" : STORAGE_FAILURE_MESSAGE;
  }

  handleVisibility() {
    if (document.visibilityState === "hidden") this.flushSave();
  }

  handlePageHide() {
    this.flushSave();
  }

  handleBeforePrint() {
    if (!this.audit) return;
    this.readAuditFromField();
    this.renderPrintAudit();
    document.documentElement.classList.add("choice-audit-printing");
  }

  handleAfterPrint() {
    document.documentElement.classList.remove("choice-audit-printing");
  }

  async printCurrentAudit() {
    this.readAuditFromField();
    await this.flushSave();
    this.renderPrintAudit();
    window.print();
  }

  renderPrintAudit() {
    const output = this.root.querySelector("[data-audit-print-output]");
    output.replaceChildren();
    const add = (parent, tag, text, className = "") => {
      const node = document.createElement(tag);
      node.textContent = text;
      if (className) node.className = className;
      parent.append(node);
      return node;
    };
    const section = (title, value, className = "") => {
      const node = document.createElement("section");
      if (className) node.className = className;
      add(node, "h2", title);
      add(node, "p", value || "", "choice-audit-print__response");
      output.append(node);
      return node;
    };

    const header = document.createElement("header");
    add(header, "p", "FluxMintDigital · Workshop · Free browser instrument", "choice-audit-print__eyebrow");
    add(header, "h1", "The Choice Audit");
    add(header, "p", "What participated in this choice?");
    add(header, "p", `Printed locally on ${new Intl.DateTimeFormat(undefined, { dateStyle: "long" }).format(new Date())}. Nothing was uploaded to prepare this copy.`, "choice-audit-print__context");
    output.append(header);
    section("THE CHOICE", this.audit.choice, "choice-audit-print__choice");

    const forces = document.createElement("section");
    forces.className = "choice-audit-print__forces";
    add(forces, "h2", "Forces");
    FORCE_KEYS.forEach((key) => {
      const entry = this.audit.forces[key];
      const force = document.createElement("section");
      force.className = "choice-audit-print__force";
      add(force, "h3", FORCE_NAMES[key]);
      add(force, "p", entry.reflection || "", "choice-audit-print__response");
      add(force, "p", `Participation: ${entry.classifications.length ? entry.classifications.join(" · ") : "—"}`);
      add(force, "p", `Influence: ${entry.influence ? `${"•".repeat(entry.influence)} ${INFLUENCE_NAMES[entry.influence]}` : "—"}`);
      forces.append(force);
    });
    output.append(forces);

    const relationships = document.createElement("section");
    relationships.className = "choice-audit-print__relationships";
    add(relationships, "h2", "Interactions between forces");
    if (this.audit.relationships.length) {
      const list = document.createElement("ul");
      this.audit.relationships.forEach((relationship) => add(list, "li", `${FORCE_NAMES[relationship.from]} ↔ ${FORCE_NAMES[relationship.to]} · Interaction`));
      relationships.append(list);
    } else add(relationships, "p", "");
    output.append(relationships);

    const temporal = document.createElement("section");
    temporal.className = "choice-audit-print__temporal";
    add(temporal, "h2", "Then / After / Now");
    [["Then", this.audit.temporal.then], ["After", this.audit.temporal.after], ["Now", this.audit.temporal.now]].forEach(([title, value]) => {
      const item = document.createElement("section"); add(item, "h3", title); add(item, "p", value || "", "choice-audit-print__response"); temporal.append(item);
    });
    output.append(temporal);

    const counterfactual = section("What might have changed the choice?", this.audit.counterfactual.reflection, "choice-audit-print__counterfactual");
    add(counterfactual, "p", `Response: ${this.audit.counterfactual.response || "—"}`);
    const evidence = document.createElement("section");
    evidence.className = "choice-audit-print__evidence";
    add(evidence, "h2", "BEFORE YOU DECIDE WHAT IT MEANS");
    [["What supports this?", "supports"], ["What might challenge it?", "challenges"], ["What else could explain it?", "alternatives"], ["What remains uncertain?", "uncertainty"]].forEach(([title, key]) => {
      const item = document.createElement("section"); add(item, "h3", title); add(item, "p", this.audit.evidence[key] || "", "choice-audit-print__response"); evidence.append(item);
    });
    add(evidence, "p", "Hindsight check: Am I reconstructing the decision differently because I know what happened afterward?", "choice-audit-print__hindsight");
    output.append(evidence);
    section("What here appears worth preserving?", this.audit.preservation, "choice-audit-print__preservation");
    section("WHAT DO YOU NOTICE?", this.audit.reflection, "choice-audit-print__noticing");
    const footer = document.createElement("footer");
    add(footer, "strong", "FluxMintDigital");
    add(footer, "span", "Your map is yours. Influence, not score.");
    output.append(footer);
  }

  handleBreakpoint() {
    this.root.classList.toggle("choice-audit--compact", this.compactMedia.matches);
    if (!this.compactMedia.matches) this.showWholeMap(false);
    else this.syncForceDisclosure();
  }

  focusForce(forceKey) {
    if (!FORCE_KEYS.includes(forceKey)) return;
    const region = this.root.querySelector(`[data-force="${forceKey}"]`);
    if (!region) return;
    this.activeForce = forceKey;
    this.syncForceDisclosure();
    region.scrollIntoView({ block: "start", behavior: "auto" });
    region.querySelector("[data-force-reflection]").focus({ preventScroll: true });
  }

  showWholeMap(moveFocus = true) {
    this.activeForce = null;
    this.syncForceDisclosure();
    if (moveFocus && this.compactMedia.matches) {
      const index = this.root.querySelector("[data-force-index]");
      index.scrollIntoView({ block: "start", behavior: "auto" });
      index.querySelector("[data-force-open]").focus({ preventScroll: true });
    }
  }

  syncForceDisclosure() {
    const compact = this.compactMedia.matches;
    this.root.querySelectorAll("[data-force]").forEach((region) => {
      const active = compact && region.dataset.force === this.activeForce;
      region.classList.toggle("choice-force--active", active);
      const body = region.querySelector("[data-force-body]");
      body.hidden = compact && !active;
      const openButton = region.querySelector(".choice-force__open");
      openButton.hidden = !compact || active;
      openButton.setAttribute("aria-expanded", String(active));
    });
    this.root.querySelectorAll("[data-force-index] [data-force-open]").forEach((button) => {
      button.setAttribute("aria-expanded", String(compact && button.dataset.forceOpen === this.activeForce));
    });
  }

  destroy() {
    window.clearTimeout(this.saveTimer);
    this.root.removeEventListener("input", this.handleInput);
    this.root.removeEventListener("change", this.handleInput);
    this.root.removeEventListener("click", this.handleClick);
    document.removeEventListener("visibilitychange", this.handleVisibility);
    window.removeEventListener("pagehide", this.handlePageHide);
    window.removeEventListener("beforeprint", this.handleBeforePrint);
    window.removeEventListener("afterprint", this.handleAfterPrint);
    this.compactMedia.removeEventListener("change", this.handleBreakpoint);
    this.repository.close();
  }
}

const root = document.querySelector("[data-choice-audit]");
if (root) {
  const controller = new ChoiceAuditController(root);
  controller.initialize().catch(() => {
    root.querySelector("[data-audit-returning]").hidden = true;
    root.querySelector("[data-audit-workspace]").hidden = false;
    root.querySelector("[data-audit-save-status]").textContent = STORAGE_FAILURE_MESSAGE;
  });
}

export { ChoiceAuditController };
