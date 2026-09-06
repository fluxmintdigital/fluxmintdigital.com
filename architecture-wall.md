---
layout: default
title: Architecture Wall
description: Frameworks, research programs, models, experiments, and evidence examined at FluxMintDigital.
permalink: /architecture-wall/
canonical_room: architecture-wall
workspace_title: Examine the Architecture
---
{% include architecture-wall-scene.html %}

<div class="wall-orientation container">
  <section id="public-examination" class="wall-boundary" aria-labelledby="public-examination-heading">
    <p class="semantic-kicker">Public research boundary</p>
    <h2 id="public-examination-heading">A view into the structure of inquiry</h2>
    <p>The website Architecture Wall and the deeper Architecture Wall application are related but distinct. No approved public application route is registered, so this Surface exposes only canonical public records.</p>
    <p>Canonical means this is the Studio’s authoritative representation of an Artifact. It does not mean scientifically true. Visual size, position, glow, or centrality conveys neither importance nor warrant.</p>
  </section>

  <section id="architecture-wall-frameworks" aria-labelledby="wall-frameworks-heading">
    <p class="semantic-kicker">Public Framework Artifacts</p>
    <h2 id="wall-frameworks-heading">Frameworks</h2>
    <p>Conceptual frameworks remain distinct from operational implementations and from claim-level evidence.</p>
    <div class="artifact-list">
      {% assign framework_placements = site.data.surface_placements | where: 'surface', 'architecture-wall-frameworks' | sort: 'order' %}
      {% for placement in framework_placements %}
        {% assign framework = site.artifacts | where: 'artifact_id', placement.artifact | first %}
        {% if framework and framework.visibility == 'public' %}{% include artifact-summary.html artifact=framework %}{% endif %}
      {% endfor %}
    </div>
  </section>

  <section id="architecture-wall-programs" aria-labelledby="wall-programs-heading">
    <p class="semantic-kicker">Research programs</p>
    <h2 id="wall-programs-heading">Public program records</h2>
    <p>No Research Program Artifact is currently approved for public visibility in canonical data.</p>
  </section>

  <section id="architecture-wall-evidence" aria-labelledby="wall-evidence-heading">
    <p class="semantic-kicker">Experiments and evidence</p>
    <h2 id="wall-evidence-heading">Public examination records</h2>
    {% assign research_records = site.data.research_contract.public_records %}
    <div class="research-record-counts" aria-label="Public research record counts">
      <p><strong>{{ research_records.claims.size }}</strong><span>Claims</span></p>
      <p><strong>{{ research_records.evidence.size }}</strong><span>Evidence records</span></p>
      <p><strong>{{ research_records.contradictions.size }}</strong><span>Contradictions</span></p>
      <p><strong>{{ research_records.validity_envelopes.size }}</strong><span>Validity envelopes</span></p>
    </div>
    <p>No claim, evidence, experiment, contradiction, confidence assessment, or validity envelope is currently approved for public display. Atmospheric papers and diagrams in the scene are not records.</p>
  </section>

  {% include aeg-assertion-kinds.html %}

  <section class="research-state-axes" aria-labelledby="research-state-heading">
    <p class="semantic-kicker">Orthogonal state</p>
    <h2 id="research-state-heading">State dimensions remain separate</h2>
    <dl>
      <div><dt>Lifecycle</dt><dd>Condition of an Artifact over time.</dd></div>
      <div><dt>Visibility</dt><dd>Who may discover or access the Artifact.</dd></div>
      <div><dt>Governance</dt><dd>Working, proposed, or canonical representation.</dd></div>
      <div><dt>Confidence</dt><dd>A claim-level assessment, not an Artifact lifecycle state.</dd></div>
      <div><dt>AEG warrant</dt><dd>Separate assertion-kind warrants; never a combined score.</dd></div>
      <div><dt>Proposal/review</dt><dd>Authorization workflow independent of warrant.</dd></div>
      <div><dt>Operational state</dt><dd>Runtime condition independent of identity and truth.</dd></div>
      <div><dt>Lineage and provenance</dt><dd>Where a record came from and how it relates, without inferring causation from direction.</dd></div>
    </dl>
  </section>

  <nav class="relationship-exits" aria-label="Architecture Wall exits">
    <a href="{{ '/studio/' | relative_url }}">Return to Main Studio</a>
    <a href="{{ '/search/' | relative_url }}">Search this Studio</a>
  </nav>
</div>
