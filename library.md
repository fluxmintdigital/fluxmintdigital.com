---
layout: default
title: Library
description: Authored knowledge, publications, and series inside FluxMintDigital.
permalink: /library/
canonical_room: library
workspace_title: Read in the Library
---
{% include library-scene.html %}

<div class="library-orientation container">
  <section aria-labelledby="library-series-heading">
    <p class="semantic-kicker">Books and series</p>
    <h2 id="library-series-heading">Explore the series</h2>
    <p>Each series keeps related books together and makes their reading order clear.</p>
    <div class="series-list">
      {% assign series_placements = site.data.surface_placements | where: 'surface', 'library-series-access' | sort: 'order' %}
      {% for placement in series_placements %}
        {% assign series = site.artifacts | where: 'artifact_id', placement.artifact | first %}
        {% if series and series.visibility == 'public' %}{% include series-summary.html artifact=series %}{% endif %}
      {% endfor %}
    </div>
  </section>

  <section aria-labelledby="library-publications-heading">
    <p class="semantic-kicker">Published work</p>
    <h2 id="library-publications-heading">Read in the Library</h2>
    <div class="artifact-list">
      {% assign publication_placements = site.data.surface_placements | where: 'surface', 'library-primary-workspace' | sort: 'order' %}
      {% for placement in publication_placements %}
        {% assign publication = site.artifacts | where: 'artifact_id', placement.artifact | first %}
        {% if publication and publication.visibility == 'public' %}{% include artifact-summary.html artifact=publication %}{% endif %}
      {% endfor %}
    </div>
  </section>

  <nav class="relationship-exits" aria-label="Library exits">
    <a href="{{ '/studio/' | relative_url }}">Return to Main Studio</a>
    <a href="{{ '/search/' | relative_url }}">Search this Studio</a>
  </nav>
</div>
