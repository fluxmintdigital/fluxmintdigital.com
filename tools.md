---
layout: page
title: Tools
description: The FluxMintDigital Tools Division — cognitive, math, and historical frameworks that help people think clearly, solve problems, and navigate complexity.
permalink: /tools/
hero_title: "Tools"
hero_sub: "Frameworks built from architecture — not opinion."
---

## Overview

FluxMintDigital tools are multi-domain frameworks built from deterministic architecture, structural clarity, and cross-disciplinary synthesis. Each tool is designed to compress complexity into usable, teachable, repeatable structures.

<div class="feature-grid" markdown="0">
{% for tool in site.data.tools %}
  <div class="feature-card">
    <h3>{{ tool.name }}</h3>
    <p>{{ tool.description }}</p>
    <ul>
      {% for example in tool.examples %}<li>{{ example }}</li>{% endfor %}
    </ul>
  </div>
{% endfor %}
</div>

## Explore More

<div class="feature-grid" markdown="0">
  <a href="{{ '/books/' | relative_url }}" class="feature-card">
    <h3>Related Books</h3>
    <p>The Architecture Series and Field Guides these tools support.</p>
  </a>
  <a href="{{ '/apps/' | relative_url }}" class="feature-card">
    <h3>Related Apps</h3>
    <p>The Life Architecture App and Mint Pro.</p>
  </a>
  <a href="{{ '/services/' | relative_url }}" class="feature-card">
    <h3>Related Services</h3>
    <p>Life Architecture and System Architecture consulting.</p>
  </a>
</div>
