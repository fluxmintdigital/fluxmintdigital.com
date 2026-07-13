---
layout: page
title: Apps
description: The FluxMintDigital Apps Division — practical, structured, architecture-driven tools designed to help people work smarter and organize their lives.
permalink: /apps/
hero_title: "Apps"
hero_sub: "Apps built from architecture — not trends."
---

## Overview

FluxMintDigital apps are built from deterministic architecture, clarity-first design, and real-world utility. Each app is engineered to solve a specific problem with structure, simplicity, and precision — no fluff, no noise, no drift.

<div class="feature-grid" markdown="0">
{% for app in site.data.apps %}
  <div class="feature-card">
    <div class="feature-card-top">
      <h3>{{ app.name }}</h3>
      {% if app.status == "coming_soon" %}<span class="badge badge-soon">Coming Soon</span>{% endif %}
    </div>
    <p class="feature-tagline">{{ app.tagline }}</p>
    <p>{{ app.description }}</p>
  </div>
{% endfor %}
</div>

## Explore More

<div class="feature-grid" markdown="0">
  <a href="{{ '/books/' | relative_url }}" class="feature-card">
    <h3>Related Books</h3>
    <p>The Architecture Series and DJ Field Guide Series.</p>
  </a>
  <a href="{{ '/tools/' | relative_url }}" class="feature-card">
    <h3>Related Tools</h3>
    <p>The frameworks these apps are built on.</p>
  </a>
  <a href="{{ '/services/' | relative_url }}" class="feature-card">
    <h3>Related Services</h3>
    <p>App Architecture consulting for your own build.</p>
  </a>
</div>
