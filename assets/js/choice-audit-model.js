const SCHEMA_VERSION = 1;
const DATABASE_NAME = "fmd-choice-audit";
const DATABASE_VERSION = 1;
const STORE_NAME = "audits";
const DATA_CLASSIFICATION = "LOCAL_REFLECTION_DATA";

const FORCE_KEYS = Object.freeze([
  "desire",
  "expectation",
  "security",
  "opportunity",
  "identity",
  "obligation",
  "fearAvoidance",
  "possibility"
]);
const CLASSIFICATIONS = Object.freeze(["W", "E", "N", "P", "?"]);
const INFLUENCE_VALUES = Object.freeze([1, 2, 3]);
const COUNTERFACTUAL_RESPONSES = Object.freeze(["Yes", "No", "Maybe", "Unknown"]);
const STORAGE_FAILURE_MESSAGE = "This audit could not be saved on this device. Your current work is still available in this session.";

function clone(value) {
  return typeof structuredClone === "function"
    ? structuredClone(value)
    : JSON.parse(JSON.stringify(value));
}

function text(value) {
  return typeof value === "string" ? value : "";
}

function timestamp(now) {
  const value = now();
  return value instanceof Date ? value.toISOString() : new Date(value).toISOString();
}

function blankForce() {
  return { reflection: "", classifications: [], influence: null };
}

function normalizeForce(value) {
  const source = value && typeof value === "object" ? value : {};
  const classifications = Array.isArray(source.classifications)
    ? [...new Set(source.classifications.filter((item) => CLASSIFICATIONS.includes(item)))]
    : [];
  return {
    reflection: text(source.reflection),
    classifications,
    influence: INFLUENCE_VALUES.includes(source.influence) ? source.influence : null
  };
}

function normalizeRelationships(value) {
  if (!Array.isArray(value)) return [];
  return value.flatMap((relationship) => {
    if (!relationship || typeof relationship !== "object") return [];
    const from = relationship.from;
    const to = relationship.to;
    if (!FORCE_KEYS.includes(from) || !FORCE_KEYS.includes(to) || from === to) return [];
    return [{ type: "interaction", from, to }];
  });
}

function normalizeAudit(source) {
  if (!source || typeof source !== "object" || typeof source.id !== "string" || !source.id) return null;
  const forces = {};
  FORCE_KEYS.forEach((key) => { forces[key] = normalizeForce(source.forces && source.forces[key]); });
  const createdAt = text(source.createdAt);
  const updatedAt = text(source.updatedAt);
  if (!createdAt || !updatedAt || Number.isNaN(Date.parse(createdAt)) || Number.isNaN(Date.parse(updatedAt))) return null;

  return {
    schemaVersion: SCHEMA_VERSION,
    id: source.id,
    createdAt,
    updatedAt,
    title: text(source.title),
    choice: text(source.choice),
    forces,
    relationships: normalizeRelationships(source.relationships),
    temporal: {
      then: text(source.temporal && source.temporal.then),
      after: text(source.temporal && source.temporal.after),
      now: text(source.temporal && source.temporal.now)
    },
    counterfactual: {
      reflection: text(source.counterfactual && source.counterfactual.reflection),
      response: COUNTERFACTUAL_RESPONSES.includes(source.counterfactual && source.counterfactual.response) ? source.counterfactual.response : ""
    },
    evidence: {
      supports: text(source.evidence && source.evidence.supports),
      challenges: text(source.evidence && source.evidence.challenges),
      alternatives: text(source.evidence && source.evidence.alternatives),
      uncertainty: text(source.evidence && source.evidence.uncertainty)
    },
    preservation: text(source.preservation),
    reflection: text(source.reflection)
  };
}

function migrateAudit(source) {
  if (!source || typeof source !== "object") return null;
  const version = Number.isInteger(source.schemaVersion) ? source.schemaVersion : 0;
  if (version > SCHEMA_VERSION || version < 0) return null;

  // Version 0 was the pre-release shape used by early local fixtures. Its
  // known fields normalize directly into v1; unknown fields are discarded.
  if (version === 0) return normalizeAudit({ ...source, schemaVersion: SCHEMA_VERSION });
  return normalizeAudit(source);
}

function requestResult(request) {
  return new Promise((resolve, reject) => {
    request.addEventListener("success", () => resolve(request.result), { once: true });
    request.addEventListener("error", () => reject(request.error || new Error("IndexedDB request failed")), { once: true });
  });
}

function transactionDone(transaction) {
  return new Promise((resolve, reject) => {
    transaction.addEventListener("complete", resolve, { once: true });
    transaction.addEventListener("abort", () => reject(transaction.error || new Error("IndexedDB transaction aborted")), { once: true });
    transaction.addEventListener("error", () => reject(transaction.error || new Error("IndexedDB transaction failed")), { once: true });
  });
}

function openDatabase(indexedDBFactory) {
  return new Promise((resolve, reject) => {
    if (!indexedDBFactory || typeof indexedDBFactory.open !== "function") {
      reject(new Error("IndexedDB unavailable"));
      return;
    }
    let request;
    try {
      request = indexedDBFactory.open(DATABASE_NAME, DATABASE_VERSION);
    } catch (error) {
      reject(error);
      return;
    }
    request.addEventListener("upgradeneeded", () => {
      const database = request.result;
      if (!database.objectStoreNames.contains(STORE_NAME)) {
        const store = database.createObjectStore(STORE_NAME, { keyPath: "id" });
        store.createIndex("updatedAt", "updatedAt", { unique: false });
      }
    });
    request.addEventListener("success", () => resolve(request.result), { once: true });
    request.addEventListener("error", () => reject(request.error || new Error("IndexedDB could not open")), { once: true });
    request.addEventListener("blocked", () => reject(new Error("IndexedDB upgrade blocked")), { once: true });
  });
}

function defaultId() {
  if (globalThis.crypto && typeof globalThis.crypto.randomUUID === "function") return globalThis.crypto.randomUUID();
  throw new Error("A secure audit identifier could not be created");
}

class AuditRepository {
  constructor(options = {}) {
    this.indexedDB = Object.prototype.hasOwnProperty.call(options, "indexedDB") ? options.indexedDB : globalThis.indexedDB;
    this.now = options.now || (() => new Date());
    this.idFactory = options.idFactory || defaultId;
    this.memory = new Map();
    this.database = null;
    this.mode = "initializing";
    this.failureMessage = "";
    this.ready = this.initialize();
  }

  async initialize() {
    try {
      this.database = await openDatabase(this.indexedDB);
      this.mode = "indexeddb";
    } catch (_error) {
      this.useMemoryFallback();
    }
    return this.status();
  }

  useMemoryFallback() {
    if (this.database) this.database.close();
    this.database = null;
    this.mode = "memory";
    this.failureMessage = STORAGE_FAILURE_MESSAGE;
  }

  status() {
    return Object.freeze({
      mode: this.mode,
      persistent: this.mode === "indexeddb",
      message: this.failureMessage
    });
  }

  async create(initial = {}) {
    await this.ready;
    const now = timestamp(this.now);
    const forces = {};
    FORCE_KEYS.forEach((key) => { forces[key] = blankForce(); });
    const audit = normalizeAudit({
      title: "",
      choice: "",
      forces,
      relationships: [],
      temporal: { then: "", after: "", now: "" },
      counterfactual: { reflection: "", response: "" },
      evidence: { supports: "", challenges: "", alternatives: "", uncertainty: "" },
      preservation: "",
      reflection: "",
      ...initial,
      schemaVersion: SCHEMA_VERSION,
      id: this.idFactory(),
      createdAt: now,
      updatedAt: now
    });
    return this.save(audit, { preserveUpdatedAt: true });
  }

  async save(value, options = {}) {
    await this.ready;
    const migrated = migrateAudit(value);
    if (!migrated) throw new TypeError("Invalid Choice Audit record");
    const audit = normalizeAudit({
      ...migrated,
      updatedAt: options.preserveUpdatedAt ? migrated.updatedAt : timestamp(this.now)
    });
    this.memory.set(audit.id, clone(audit));
    if (this.mode === "indexeddb") {
      try {
        const transaction = this.database.transaction(STORE_NAME, "readwrite");
        transaction.objectStore(STORE_NAME).put(clone(audit));
        await transactionDone(transaction);
      } catch (_error) {
        this.useMemoryFallback();
      }
    }
    return clone(audit);
  }

  async get(id) {
    await this.ready;
    if (this.memory.has(id)) return clone(this.memory.get(id));
    if (this.mode !== "indexeddb") return null;
    try {
      const transaction = this.database.transaction(STORE_NAME, "readonly");
      const stored = await requestResult(transaction.objectStore(STORE_NAME).get(id));
      const audit = migrateAudit(stored);
      if (audit) this.memory.set(audit.id, clone(audit));
      return audit ? clone(audit) : null;
    } catch (_error) {
      this.useMemoryFallback();
      return null;
    }
  }

  async list() {
    await this.ready;
    if (this.mode === "indexeddb") {
      try {
        const transaction = this.database.transaction(STORE_NAME, "readonly");
        const stored = await requestResult(transaction.objectStore(STORE_NAME).getAll());
        stored.map(migrateAudit).filter(Boolean).forEach((audit) => this.memory.set(audit.id, clone(audit)));
      } catch (_error) {
        this.useMemoryFallback();
      }
    }
    return [...this.memory.values()].map(clone).sort((a, b) => b.updatedAt.localeCompare(a.updatedAt));
  }

  async duplicate(id) {
    const source = await this.get(id);
    if (!source) return null;
    const now = timestamp(this.now);
    return this.save({ ...source, id: this.idFactory(), createdAt: now, updatedAt: now }, { preserveUpdatedAt: true });
  }

  async delete(id) {
    await this.ready;
    const existed = this.memory.delete(id);
    if (this.mode === "indexeddb") {
      try {
        const transaction = this.database.transaction(STORE_NAME, "readwrite");
        transaction.objectStore(STORE_NAME).delete(id);
        await transactionDone(transaction);
      } catch (_error) {
        this.useMemoryFallback();
      }
    }
    return existed;
  }

  close() {
    if (this.database) this.database.close();
    this.database = null;
  }
}

function createAuditRepository(options) {
  return new AuditRepository(options);
}

export {
  AuditRepository,
  CLASSIFICATIONS,
  COUNTERFACTUAL_RESPONSES,
  DATA_CLASSIFICATION,
  FORCE_KEYS,
  INFLUENCE_VALUES,
  SCHEMA_VERSION,
  STORAGE_FAILURE_MESSAGE,
  createAuditRepository,
  migrateAudit,
  normalizeAudit
};
