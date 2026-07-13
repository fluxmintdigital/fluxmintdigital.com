---
layout: page
title: Science
description: The FluxMintDigital Science Division — scientific models, physical frameworks, and testable hypotheses built from structural clarity and falsifiable architecture.
permalink: /science/
hero_title: "Science"
hero_sub: "Scientific frameworks built from structure, not speculation."
---

## Overview

The Science Division contains only frameworks that meet strict criteria:

- Falsifiable
- Testable
- Measurable
- Structurally grounded
- Non-metaphorical
- Non-speculative

This lane represents the intersection of architecture and empirical reality.

## Featured Scientific Frameworks

<div class="feature-grid" markdown="0">
{% for model in site.data.science %}
  <div class="feature-card">
    <div class="feature-card-top">
      <h3>{{ model.name }}</h3>
      <span class="badge badge-dev">In Development</span>
    </div>
    <p>Details, diagrams, and testability criteria for this model are being written up and will be published here.</p>
  </div>
{% endfor %}
</div>

## Explore More

<div class="feature-grid" markdown="0">
  <a href="{{ '/books/' | relative_url }}" class="feature-card">
    <h3>Related Books</h3>
    <p>The Architecture Series.</p>
  </a>
  <a href="{{ '/tools/' | relative_url }}" class="feature-card">
    <h3>Related Tools</h3>
    <p>EPA and Compression Trees.</p>
  </a>
  <a href="{{ '/apps/' | relative_url }}" class="feature-card">
    <h3>Related Apps</h3>
    <p>The Life Architecture App.</p>
  </a>
</div>
