---
layout: default
title: Relationship Explorer
description: Explore typed, directional relationships among public FluxMintDigital Artifacts and people.
permalink: /relationships/
---
<section class="relationship-surface container">
  <header class="semantic-hero"><p class="semantic-kicker">Studio utility</p><h1>Relationship Explorer</h1><p class="semantic-lede">Trace how public work belongs, expands, derives, and connects without treating direction as causation or visual prominence as importance.</p></header>
  <p class="surface-panel">Relationships are typed and directional canonical records. Their presence does not transfer lifecycle, availability, confidence, warrant, or scientific truth between connected records.</p>
  <ol class="relationship-records">
    {% for relationship in site.data.relationships %}
      {% assign source = site.artifacts | where: 'artifact_id', relationship.source | first %}
      {% assign target = site.artifacts | where: 'artifact_id', relationship.target | first %}
      {% if relationship.target == site.data.studio.owner.id %}{% assign target_title = site.data.studio.owner.name %}{% assign target_url = '/meet-dj/' %}{% else %}{% assign target_title = target.title %}{% assign target_url = target.url %}{% endif %}
      {% if source and source.visibility == 'public' and target_title %}
      <li class="surface-card"><a href="{{ source.url | relative_url }}">{{ source.title }}</a><span class="relationship-record__type">{{ relationship.type | replace: '_', ' ' }}</span><a href="{{ target_url | relative_url }}">{{ target_title }}</a><small>Provenance: {{ relationship.provenance }}{% if relationship.metadata.sequence %} · Sequence {{ relationship.metadata.sequence }}{% endif %}</small></li>
      {% endif %}
    {% endfor %}
  </ol>
  <nav class="relationship-exits" aria-label="Relationship Explorer exits"><a href="{{ '/search/' | relative_url }}">Search the Studio</a><a href="{{ '/studio/' | relative_url }}">Return to Main Studio</a></nav>
</section>
