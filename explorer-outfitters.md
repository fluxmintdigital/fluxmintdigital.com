---
layout: default
title: Explorer Outfitters
description: Canonical FluxMintDigital Artifacts available through honest acquisition channels.
permalink: /explorer-outfitters/
canonical_room: explorer-outfitters
---
{% include explorer-outfitters-scene.html %}

{% assign outfitters_placements = site.data.surface_placements | where: 'surface', 'explorer-outfitters-discovery' | sort: 'order' %}
<div class="outfitters-orientation container">
  <section aria-labelledby="outfitters-discovery-heading">
    <p class="semantic-kicker">Cross-Studio discovery</p>
    <h2 id="outfitters-discovery-heading">Artifacts keep their home</h2>
    <p>Outfitters is an availability and acquisition lens. Every item below remains one canonical Artifact in its owning Room; appearing here creates neither a duplicate product record nor a new identity.</p>
    <div class="outfitters-listings">
      {% for placement in outfitters_placements %}
        {% assign artifact = site.artifacts | where: 'artifact_id', placement.artifact | first %}
        {% if artifact and artifact.visibility == 'public' %}{% include outfitters-listing.html artifact=artifact %}{% endif %}
      {% endfor %}
    </div>
  </section>

  <section id="outfitters-availability" class="surface-panel outfitters-empty" aria-labelledby="outfitters-availability-heading" role="status">
    <p class="semantic-kicker">Current acquisition state</p>
    <h2 id="outfitters-availability-heading">No approved acquisition channels are represented yet.</h2>
    <p>The public Artifacts remain available to understand through their canonical pages. No marketplace, price, purchase action, scarcity claim, or future availability is implied.</p>
  </section>

  <nav class="relationship-exits" aria-label="Explorer Outfitters exits"><a href="{{ '/library/' | relative_url }}">Visit the Library</a><a href="{{ '/workshop/' | relative_url }}">Visit the Workshop</a><a href="{{ '/studio/' | relative_url }}">Return to Main Studio</a><a href="{{ '/search/' | relative_url }}">Search this Studio</a></nav>
</div>
