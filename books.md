---
layout: page
title: Books
description: The FluxMintDigital Books Division — multi-domain books that make the world clearer through structure, compassion, and systems thinking, by DJ Boswell.
permalink: /books/
hero_title: "Books"
hero_sub: "Books that architect minds, systems, stories, and lives."
---

## Publishing Philosophy

Books should make the world clearer. Every book DJ writes is built from structure, clarity, and compassion — designed to help readers understand themselves, systems, and the world through architecture rather than advice. Across systems architecture, cognitive architecture, and personal development, each series aims for the same thing: structural clarity you can actually use.

<div class="feature-grid" markdown="0">
{% for book in site.data.books %}
  <div class="feature-card">
    <div class="feature-card-top">
      <h3>{{ book.name }}</h3>
      {% if book.status == "coming_soon" %}<span class="badge badge-soon">Coming Soon</span>{% endif %}
    </div>
    <p class="feature-tagline">{{ book.tagline }}</p>
    <p>{{ book.description }}</p>
  </div>
{% endfor %}
</div>

## Explore More

<div class="feature-grid" markdown="0">
  <a href="{{ '/tools/' | relative_url }}" class="feature-card">
    <h3>Related Tools</h3>
    <p>Frameworks like Atlas Brain and Compression Trees that pair with these books.</p>
  </a>
  <a href="{{ '/services/' | relative_url }}" class="feature-card">
    <h3>Related Services</h3>
    <p>Life Architecture and System Architecture consulting.</p>
  </a>
  <a href="{{ '/apps/' | relative_url }}" class="feature-card">
    <h3>Related Apps</h3>
    <p>Mint Pro and the Life Architecture App.</p>
  </a>
</div>
