import {
  CLASSIFICATIONS,
  DATA_CLASSIFICATION,
  FORCE_KEYS,
  SCHEMA_VERSION,
  STORAGE_FAILURE_MESSAGE,
  createAuditRepository,
  migrateAudit
} from "/assets/js/choice-audit-model.js";

const assert = (condition, message) => {
  if (!condition) throw new Error(message);
};

async function run() {
  const suffix = new URL(location.href).searchParams.get("run") || "fixture";
  const verificationId = new URL(location.href).searchParams.get("verify");
  if (verificationId) {
    const returningRepository = createAuditRepository();
    await returningRepository.ready;
    const returning = await returningRepository.get(verificationId);
    returningRepository.close();
    assert(returning && returning.choice === "A private test choice that must stay local", "returning audit was not retrieved after reload");
    return { returning: true, id: verificationId };
  }
  let idSequence = 0;
  const repository = createAuditRepository({ idFactory: () => `audit-${suffix}-${++idSequence}` });
  await repository.ready;
  assert(DATA_CLASSIFICATION === "LOCAL_REFLECTION_DATA", "privacy classification changed");
  assert(repository.status().mode === "indexeddb", "IndexedDB did not initialize");

  const created = await repository.create();
  assert(created.schemaVersion === SCHEMA_VERSION, "schema version missing");
  assert(Object.keys(created.forces).join("|") === FORCE_KEYS.join("|"), "canonical forces missing or reordered");
  assert(FORCE_KEYS.every((key) => created.forces[key].reflection === "" && created.forces[key].classifications.length === 0 && created.forces[key].influence === null), "blank force defaults invalid");

  created.choice = "A private test choice that must stay local";
  created.forces.desire.reflection = "private desire reflection";
  created.forces.desire.classifications = [...CLASSIFICATIONS];
  created.forces.desire.influence = 3;
  created.forces.security.classifications = ["W", "P"];
  created.forces.security.influence = 1;
  created.relationships = [{ type: "interaction", from: "desire", to: "security" }];
  created.temporal = { then: "then private", after: "after private", now: "now private" };
  created.counterfactual = { reflection: "counterfactual private", response: "response private" };
  created.evidence = { supports: "support private", challenges: "challenge private", alternatives: "alternative private", uncertainty: "uncertain private" };
  created.preservation = "preserve private";
  created.reflection = "notice private";
  const saved = await repository.save(created);
  const loaded = await repository.get(saved.id);
  assert(JSON.stringify(loaded) === JSON.stringify(saved), "full schema did not round-trip");
  assert(loaded.forces.desire.classifications.length === 5, "overlapping classifications did not round-trip");
  assert(loaded.forces.desire.influence === 3 && loaded.forces.security.influence === 1, "influence did not round-trip");
  assert(loaded.forces.identity.reflection === "", "blank forces are not valid");

  const duplicate = await repository.duplicate(saved.id);
  assert(duplicate && duplicate.id !== saved.id && duplicate.choice === saved.choice, "duplicate failed");
  assert((await repository.list()).length >= 2, "list failed");
  assert(await repository.delete(duplicate.id), "delete failed");
  assert(await repository.get(duplicate.id) === null, "deleted record remained");

  const future = migrateAudit({ ...saved, schemaVersion: SCHEMA_VERSION + 1 });
  assert(future === null, "future schema must fail safely");
  assert(migrateAudit({ schemaVersion: 1, id: "malformed" }) === null, "malformed record must fail safely");
  const migratedV0 = migrateAudit({ ...saved, schemaVersion: 0 });
  assert(migratedV0 && migratedV0.schemaVersion === SCHEMA_VERSION, "known stale schema did not migrate");

  const failingWrite = createAuditRepository({ idFactory: () => `failing-${suffix}` });
  await failingWrite.ready;
  const originalDatabase = failingWrite.database;
  failingWrite.database = {
    close: () => originalDatabase.close(),
    transaction: () => { throw new Error("forced write failure"); }
  };
  const preserved = await failingWrite.create({ choice: "preserve after persistent write failure" });
  assert(failingWrite.status().mode === "memory", "write failure did not activate memory fallback");
  assert((await failingWrite.get(preserved.id)).choice === "preserve after persistent write failure", "write failure discarded current-session work");

  const memory = createAuditRepository({ indexedDB: null, idFactory: () => `memory-${suffix}` });
  await memory.ready;
  assert(memory.status().mode === "memory" && memory.status().message === STORAGE_FAILURE_MESSAGE, "memory fallback contract changed");
  const sessionAudit = await memory.create({ choice: "session-only private reflection" });
  sessionAudit.forces.possibility.reflection = "still present after storage failure";
  await memory.save(sessionAudit);
  assert((await memory.get(sessionAudit.id)).forces.possibility.reflection === "still present after storage failure", "session fallback lost current work");
  assert((await memory.list()).length === 1, "memory list failed");

  repository.close();
  failingWrite.close();
  memory.close();
  return { id: saved.id, persistent: true, schemaVersion: SCHEMA_VERSION, forces: FORCE_KEYS.length, fallback: "memory" };
}

window.choiceAuditModelResult = run()
  .then((result) => ({ ok: true, ...result }))
  .catch((error) => ({ ok: false, error: error.message }));
