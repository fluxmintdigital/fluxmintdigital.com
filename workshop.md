---
layout: default
title: Workshop
description: Applications, tools, instruments, and prototypes built at FluxMintDigital.
permalink: /workshop/
canonical_room: workshop
workspace_title: Build in the Workshop
---
{% include workshop-scene.html %}

<div class="workshop-orientation container">
  <section id="workshop-current-build" aria-labelledby="workshop-current-heading">
    <p class="semantic-kicker">On the workbench</p>
    <h2 id="workshop-current-heading">Current Build</h2>
    <p>This temporal Surface is selected from canonical Artifact placements. It does not redefine ownership, release identity, or availability.</p>
    <div class="artifact-list">
      {% assign current_build_placements = site.data.surface_placements | where: 'surface', 'workshop-current-build' | sort: 'order' %}
      {% for placement in current_build_placements %}
        {% assign current_build = site.artifacts | where: 'artifact_id', placement.artifact | first %}
        {% if current_build and current_build.visibility == 'public' %}{% include artifact-summary.html artifact=current_build %}{% endif %}
      {% endfor %}
    </div>
  </section>

  <section id="workshop-applications" aria-labelledby="workshop-applications-heading">
    <p class="semantic-kicker">Applications</p>
    <h2 id="workshop-applications-heading">Usable implementations</h2>
    <p>Applications are operational Artifacts. Their identity is separate from routine versions, releases, availability, and distribution channels.</p>
    <div class="artifact-list">
      {% assign application_placements = site.data.surface_placements | where: 'surface', 'workshop-applications' | sort: 'order' %}
      {% for placement in application_placements %}
        {% assign application = site.artifacts | where: 'artifact_id', placement.artifact | first %}
        {% if application and application.visibility == 'public' %}{% include artifact-summary.html artifact=application %}{% endif %}
      {% endfor %}
    </div>
  </section>

  <section id="workshop-tool-access" aria-labelledby="workshop-tools-heading">
    <p class="semantic-kicker">Curated workbench</p>
    <h2 id="workshop-tools-heading">Tools, instruments, and making experiments</h2>
    <p>No additional public Artifacts are currently represented in canonical Workshop data. Internal directories, unapproved projects, routine builds, and research evidence are not exposed here.</p>
    <ul class="workshop-collection-index">
      <li><strong>Companion tools</strong><span>No public Artifact currently listed</span></li>
      <li><strong>Instruments</strong><span>No public Artifact currently listed</span></li>
      <li><strong>Making experiments and prototypes</strong><span>No public Artifact currently listed</span></li>
    </ul>
  </section>

  <nav class="relationship-exits" aria-label="Workshop exits">
    <a href="{{ '/studio/' | relative_url }}">Return to Main Studio</a>
    <a href="{{ '/search/' | relative_url }}">Search this Studio</a>
  </nav>
</div>
