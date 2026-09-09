---
layout: default
title: Architecture Wall
description: Ways of thinking, methods in use, research programs, experiments, and evidence examined at FluxMintDigital.
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

  <section id="architecture-wall-ways" aria-labelledby="wall-ways-heading">
    <p class="semantic-kicker">Ways of Thinking</p>
    <h2 id="wall-ways-heading">Ways to look beneath the surface</h2>
    <p>Ways of thinking help organize inquiry. They are not the same as working software, and they do not count as evidence for their own claims.</p>
    <div class="artifact-list">
      {% assign way_placements = site.data.surface_placements | where: 'surface', 'architecture-wall-ways-of-thinking' | sort: 'order' %}
      {% for placement in way_placements %}
        {% assign way = site.artifacts | where: 'artifact_id', placement.artifact | first %}
        {% if way and way.visibility == 'public' %}{% include artifact-summary.html artifact=way %}{% endif %}
      {% endfor %}
    </div>
  </section>

  <section id="architecture-wall-methods" aria-labelledby="wall-methods-heading">
    <p class="semantic-kicker">Methods in Use</p>
    <h2 id="wall-methods-heading">Methods for deliberate work</h2>
    <div class="artifact-list">
      {% assign method_placements = site.data.surface_placements | where: 'surface', 'architecture-wall-methods' | sort: 'order' %}
      {% for placement in method_placements %}
        {% assign method = site.artifacts | where: 'artifact_id', placement.artifact | first %}
        {% if method and method.visibility == 'public' %}{% include artifact-summary.html artifact=method %}{% endif %}
      {% endfor %}
    </div>
  </section>

  {% assign program_placements = site.data.surface_placements | where: 'surface', 'architecture-wall-research-programs' | sort: 'order' %}
  {% if program_placements.size > 0 %}<section id="architecture-wall-programs" aria-labelledby="wall-programs-heading">
    <p class="semantic-kicker">Research Programs</p>
    <h2 id="wall-programs-heading">Research under formal examination</h2>
    <div class="artifact-list">{% for placement in program_placements %}{% assign program = site.artifacts | where: 'artifact_id', placement.artifact | first %}{% if program and program.visibility == 'public' %}{% include artifact-summary.html artifact=program %}{% endif %}{% endfor %}</div>
  </section>{% endif %}

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
