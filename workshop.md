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
  <section id="workshop-applications" aria-labelledby="workshop-current-heading">
    <p class="semantic-kicker">On the workbench</p>
    <h2 id="workshop-current-heading">Applications taking shape</h2>
    <p>Work in progress—real applications, but not release or availability promises.</p>
    <div class="artifact-list">
      {% assign application_placements = site.data.surface_placements | where: 'surface', 'workshop-applications' | sort: 'order' %}
      {% for placement in application_placements %}
        {% assign application = site.artifacts | where: 'artifact_id', placement.artifact | first %}
        {% if application and application.visibility == 'public' and application.lifecycle == 'on_the_workbench' %}{% include artifact-summary.html artifact=application %}{% endif %}
      {% endfor %}
    </div>
  </section>

  <section id="workshop-tool-access" aria-labelledby="workshop-tools-heading">
    <p class="semantic-kicker">Released instruments</p>
    <h2 id="workshop-tools-heading">Things ready to use</h2>
    <p>Structured instruments for looking more closely at a choice and the larger architecture around it.</p>
    <div class="artifact-list">
      {% assign instrument_placements = site.data.surface_placements | where: 'surface', 'workshop-instruments' | sort: 'order' %}
      {% for placement in instrument_placements %}
        {% assign instrument = site.artifacts | where: 'artifact_id', placement.artifact | first %}
        {% if instrument and instrument.visibility == 'public' %}{% include artifact-summary.html artifact=instrument %}{% endif %}
      {% endfor %}
    </div>
    <ul class="workshop-collection-index">
      <li><strong>Companion tools</strong><span>Nothing shared yet</span></li>
      <li><strong>Making experiments and prototypes</strong><span>Nothing shared yet</span></li>
    </ul>
  </section>

  <nav class="relationship-exits" aria-label="Workshop exits">
    <a href="{{ '/studio/' | relative_url }}">Return to Main Studio</a>
    <a href="{{ '/search/' | relative_url }}">Search this Studio</a>
  </nav>
</div>
