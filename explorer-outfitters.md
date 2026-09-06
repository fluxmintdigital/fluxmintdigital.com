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
    <div class="outfitters-listings">
      {% for placement in outfitters_placements %}
        {% assign artifact = site.artifacts | where: 'artifact_id', placement.artifact | first %}
        {% if artifact and artifact.visibility == 'public' %}{% include outfitters-listing.html artifact=artifact %}{% endif %}
      {% endfor %}
    </div>
  </section>

  {% assign available_items = site.data.availability.records | where: 'status', 'available' %}
  <section id="outfitters-availability" class="surface-panel outfitters-empty" aria-labelledby="outfitters-availability-heading">
    {% if available_items.size > 0 %}
    <p class="semantic-kicker">Available now</p>
    <h2 id="outfitters-availability-heading">Real ways to take something with you</h2>
    <p>When a book or tool has an approved place to get it, you’ll find that option beside the item above.</p>
    {% else %}
    <p class="semantic-kicker">Not on the shelf yet</p>
    <h2 id="outfitters-availability-heading">Nothing is available to purchase here right now.</h2>
    <p>You can still explore each book or tool in its home Room. Purchase options will appear only when there is a real place to get them.</p>
    {% endif %}
  </section>

  <nav class="relationship-exits" aria-label="Explorer Outfitters exits"><a href="{{ '/library/' | relative_url }}">Visit the Library</a><a href="{{ '/workshop/' | relative_url }}">Visit the Workshop</a><a href="{{ '/studio/' | relative_url }}">Return to Main Studio</a><a href="{{ '/search/' | relative_url }}">Search this Studio</a></nav>
</div>
