---
layout: default
title: Relationship Explorer
description: See how FluxMintDigital books, tools, frameworks, and people connect.
permalink: /relationships/
---
<section class="relationship-surface container">
  <header class="semantic-hero"><p class="semantic-kicker">Follow the threads</p><h1>Relationship Explorer</h1><p class="semantic-lede">See how books, tools, frameworks, series, and people connect across the Studio.</p></header>
  <p class="surface-panel">A connection shows how two pieces of work relate; it does not make them equally proven, equally available, or equally complete. An arrow shows the direction of the connection—not cause and effect.</p>
  <div class="relationship-explorer" data-relationship-explorer hidden>
    <section aria-labelledby="explore-by-work-heading">
      <p class="semantic-kicker">Explore by work</p>
      <h2 id="explore-by-work-heading">Start with one piece</h2>
      <label for="relationship-work">Show its immediate relationships</label>
      <select id="relationship-work" data-relationship-work>
        <option value="">Choose a work</option>
        {% assign public_artifacts = site.artifacts | where: 'visibility', 'public' | sort: 'title' %}
        {% for artifact in public_artifacts %}<option value="{{ artifact.artifact_id }}">{{ artifact.title }}</option>{% endfor %}
        {% assign public_posts = site.posts | where: 'visibility', 'public' | sort: 'title' %}
        {% for post in public_posts %}<option value="{{ post.slug }}">{{ post.title }}</option>{% endfor %}
        <option value="{{ site.data.studio.owner.id }}">{{ site.data.studio.owner.name }}</option>
      </select>
    </section>
    <section aria-labelledby="explore-by-thread-heading">
      <p class="semantic-kicker">Explore by thread</p>
      <h2 id="explore-by-thread-heading">Follow a known kind of connection</h2>
      <label for="relationship-thread">Show one relationship thread</label>
      <select id="relationship-thread" data-relationship-thread>
        <option value="">Choose a thread</option>
        {% assign relationship_types = site.data.relationships | map: 'type' | uniq | sort %}
        {% for relationship_type in relationship_types %}<option value="{{ relationship_type }}">{{ relationship_type | replace: '_', ' ' | capitalize }}</option>{% endfor %}
      </select>
    </section>
    <button class="button button--quiet" type="button" data-relationship-all>Show all relationships</button>
  </div>
  <p class="relationship-filter-status" data-relationship-status role="status" aria-live="polite">All canonical relationships are shown.</p>
  <h2 class="relationship-ledger-heading" data-relationship-heading>All relationships</h2>
  <ol class="relationship-records">
    {% for relationship in site.data.relationships %}
      {% assign source = site.artifacts | where: 'artifact_id', relationship.source | first %}
      {% assign target = site.artifacts | where: 'artifact_id', relationship.target | first %}
      {% unless source %}{% assign source = site.posts | where: 'slug', relationship.source | first %}{% endunless %}
      {% unless target %}{% assign target = site.posts | where: 'slug', relationship.target | first %}{% endunless %}
      {% if relationship.target == site.data.studio.owner.id %}{% assign target_title = site.data.studio.owner.name %}{% assign target_url = '/meet-dj/' %}{% else %}{% assign target_title = target.title %}{% assign target_url = target.url %}{% endif %}
      {% if source and source.visibility == 'public' and target_title %}
      <li class="surface-card" data-relationship-record data-source="{{ relationship.source }}" data-target="{{ relationship.target }}" data-type="{{ relationship.type }}"><a href="{{ source.url | relative_url }}">{{ source.title }}</a><span class="relationship-record__type">{{ relationship.type | replace: '_', ' ' }}</span><a href="{{ target_url | relative_url }}">{{ target_title }}</a><small>{% include relationship-context.html type=relationship.type %}{% if relationship.metadata.sequence %} · Volume {{ relationship.metadata.sequence }}{% endif %}</small></li>
      {% endif %}
    {% endfor %}
  </ol>
  <nav class="relationship-exits" aria-label="Relationship Explorer exits"><a href="{{ '/search/' | relative_url }}">Search the Studio</a><a href="{{ '/studio/' | relative_url }}">Return to Main Studio</a></nav>
</section>
<script src="{{ '/assets/js/relationship-explorer.js' | relative_url }}" defer></script>
