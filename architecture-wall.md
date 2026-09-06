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
    <p class="semantic-kicker">A public view</p>
    <h2 id="public-examination-heading">A window into the work of inquiry</h2>
    <p>This room offers a public glimpse of the deeper Architecture Wall research system. Only work DJ has chosen to share appears here.</p>
    <p>Being part of the Studio’s current body of work does not make an idea scientifically true. A large, bright, or central object is not automatically more important or better supported.</p>
  </section>

  <section id="architecture-wall-frameworks" aria-labelledby="wall-frameworks-heading">
    <p class="semantic-kicker">Ways of thinking</p>
    <h2 id="wall-frameworks-heading">Frameworks</h2>
    <p>Frameworks help organize thought. They are not the same as working software, and they do not count as evidence for their own claims.</p>
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
    <h2 id="wall-programs-heading">Research programs</h2>
    <p>No research programs are ready to share here yet.</p>
  </section>

  <section id="architecture-wall-evidence" aria-labelledby="wall-evidence-heading">
    <p class="semantic-kicker">Experiments and evidence</p>
    <h2 id="wall-evidence-heading">What has been examined</h2>
    <p>No formal claims, evidence, experiments, contradictions, confidence assessments, or validity limits are ready for public display. The papers and diagrams in the room are atmosphere, not research findings.</p>
  </section>

  {% include aeg-assertion-kinds.html %}

  <details class="research-state-axes surface-panel">
    <summary id="research-state-heading">How research states stay separate</summary>
    <dl>
      <div><dt>Stage</dt><dd>Where a piece of work is in its life.</dd></div>
      <div><dt>Access</dt><dd>Who can discover or open it.</dd></div>
      <div><dt>Review</dt><dd>Whether it is working, proposed, or accepted as the Studio’s current version.</dd></div>
      <div><dt>Confidence</dt><dd>How strongly a particular claim is supported—not how finished its container looks.</dd></div>
      <div><dt>AEG warrant</dt><dd>Separate assertion-kind warrants; never a combined score.</dd></div>
      <div><dt>Proposal and review</dt><dd>Who has considered and authorized a change.</dd></div>
      <div><dt>Working condition</dt><dd>Whether a tool is running, separate from whether its ideas are true.</dd></div>
      <div><dt>Origins and connections</dt><dd>Where something came from and how it relates to other work, without mistaking direction for causation.</dd></div>
    </dl>
  </details>

  <nav class="relationship-exits" aria-label="Architecture Wall exits">
    <a href="{{ '/studio/' | relative_url }}">Return to Main Studio</a>
    <a href="{{ '/search/' | relative_url }}">Search this Studio</a>
  </nav>
</div>
