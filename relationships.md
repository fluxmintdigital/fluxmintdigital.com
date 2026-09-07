---
layout: default
title: Relationship Explorer
description: See how FluxMintDigital books, tools, frameworks, and people connect.
permalink: /relationships/
---
<section class="relationship-surface container">
  <header class="semantic-hero"><p class="semantic-kicker">Follow the threads</p><h1>Relationship Explorer</h1><p class="semantic-lede">See how books, tools, frameworks, series, and people connect across the Studio.</p></header>
  <p class="surface-panel">A connection shows how two pieces of work relate; it does not make them equally proven, equally available, or equally complete. An arrow shows the direction of the connection—not cause and effect.</p>
  <ol class="relationship-records">
    {% for relationship in site.data.relationships %}
      {% assign source = site.artifacts | where: 'artifact_id', relationship.source | first %}
      {% assign target = site.artifacts | where: 'artifact_id', relationship.target | first %}
      {% unless source %}{% assign source = site.posts | where: 'slug', relationship.source | first %}{% endunless %}
      {% unless target %}{% assign target = site.posts | where: 'slug', relationship.target | first %}{% endunless %}
      {% if relationship.target == site.data.studio.owner.id %}{% assign target_title = site.data.studio.owner.name %}{% assign target_url = '/meet-dj/' %}{% else %}{% assign target_title = target.title %}{% assign target_url = target.url %}{% endif %}
      {% if source and source.visibility == 'public' and target_title %}
      <li class="surface-card"><a href="{{ source.url | relative_url }}">{{ source.title }}</a><span class="relationship-record__type">{{ relationship.type | replace: '_', ' ' }}</span><a href="{{ target_url | relative_url }}">{{ target_title }}</a><small>{% if relationship.provenance == 'editorial' %}Editorial connection{% elsif relationship.provenance == 'authored' %}Authored explanation{% else %}Studio connection{% endif %}{% if relationship.metadata.sequence %} · Volume {{ relationship.metadata.sequence }}{% endif %}</small></li>
      {% endif %}
    {% endfor %}
  </ol>
  <nav class="relationship-exits" aria-label="Relationship Explorer exits"><a href="{{ '/search/' | relative_url }}">Search the Studio</a><a href="{{ '/studio/' | relative_url }}">Return to Main Studio</a></nav>
</section>
