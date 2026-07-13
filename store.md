---
layout: page
title: Store
description: The FluxMintDigital Store — the central hub for all books, apps, and digital products created by DJ Boswell.
permalink: /store/
hero_title: "Store"
hero_sub: "One studio. All products. Clear access."
---

## Overview

The FluxMintDigital Store organizes all products into clear categories — books, apps, and future digital downloads. Each product will link to its official marketplace listing once live, so purchasing always stays secure and platform-compatible.

## Books

<div class="feature-grid" markdown="0">
{% for book in site.data.books %}
  <div class="feature-card">
    <div class="feature-card-top">
      <h3>{{ book.name }}</h3>
      <span class="badge badge-soon">Coming Soon</span>
    </div>
    <p>{{ book.tagline }}</p>
  </div>
{% endfor %}
</div>

<p><em>Books will be available on Amazon, with direct digital downloads planned for the future.</em></p>

## Apps

<div class="feature-grid" markdown="0">
{% for app in site.data.apps %}
  <div class="feature-card">
    <div class="feature-card-top">
      <h3>{{ app.name }}</h3>
      <span class="badge badge-soon">Coming Soon</span>
    </div>
    <p>{{ app.tagline }}</p>
  </div>
{% endfor %}
</div>

<p><em>Apps will be available on the Google Play Store, with the Apple App Store and direct APK downloads planned for the future.</em></p>

## Digital Downloads (Future)

- EPUB versions of books
- PDF versions
- Framework diagrams
- Architecture templates
- Worksheets, guides, and toolkits

## Explore More

<div class="feature-grid" markdown="0">
  <a href="{{ '/books/' | relative_url }}" class="feature-card">
    <h3>Books Division</h3>
    <p>Full descriptions of every series.</p>
  </a>
  <a href="{{ '/apps/' | relative_url }}" class="feature-card">
    <h3>Apps Division</h3>
    <p>Full descriptions of every app.</p>
  </a>
</div>
