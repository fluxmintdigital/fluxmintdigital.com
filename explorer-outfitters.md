---
layout: default
title: Explorer Outfitters
description: Books, tools, and other useful things from around the Studio.
permalink: /explorer-outfitters/
canonical_room: explorer-outfitters
---
{% include explorer-outfitters-scene.html %}

{% assign outfitters_placements = site.data.surface_placements | where: 'surface', 'explorer-outfitters-discovery' | sort: 'order' %}
<div class="outfitters-orientation container">
  <section aria-labelledby="outfitters-discovery-heading">
    <p class="semantic-kicker">From around the Studio</p>
    <h2 id="outfitters-discovery-heading">Find something to take with you</h2>
    <p>Browse books from the Library and tools from the Workshop. Each item still belongs to the Room where it was made and explained.</p>
    <h3 class="outfitters-group-heading">Available to take</h3>
    <div class="outfitters-listings" data-availability-group="available">
      {% for placement in outfitters_placements %}
        {% assign artifact = site.artifacts | where: 'artifact_id', placement.artifact | first %}
        {% assign availability = site.data.availability.records | where: 'artifact', artifact.artifact_id | first %}
        {% if artifact and artifact.visibility == 'public' and availability.status == 'available' %}{% include outfitters-listing.html artifact=artifact %}{% endif %}
      {% endfor %}
    </div>
    <h3 class="outfitters-group-heading">Not available yet</h3>
    <div class="outfitters-listings outfitters-listings--future" data-availability-group="unavailable">
      {% for placement in outfitters_placements %}
        {% assign artifact = site.artifacts | where: 'artifact_id', placement.artifact | first %}
        {% assign availability = site.data.availability.records | where: 'artifact', artifact.artifact_id | first %}
        {% unless availability and availability.status == 'available' %}
          {% if artifact and artifact.visibility == 'public' %}{% include outfitters-listing.html artifact=artifact %}{% endif %}
        {% endunless %}
      {% endfor %}
    </div>
  </section>

  <nav class="relationship-exits" aria-label="Explorer Outfitters exits"><a href="{{ '/library/' | relative_url }}">Visit the Library</a><a href="{{ '/workshop/' | relative_url }}">Visit the Workshop</a><a href="{{ '/studio/' | relative_url }}">Return to Main Studio</a><a href="{{ '/search/' | relative_url }}">Search this Studio</a></nav>
</div>
