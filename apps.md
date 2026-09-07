---
layout: redirect
redirect_to: /workshop/
redirect_label: the Workshop
title: Apps
description: Visit the Workshop to explore the applications and tools DJ is building at FluxMintDigital.
permalink: /apps/
sitemap: false
robots: noindex, follow
eyebrow: Room / Studio Map — The Workshop
subhead: 'One room, two divisions: the tool wall holds Tools, the shelf holds Apps.'
room_image: /assets/images/rooms/workshop.jpg
room_alt: A wood-paneled workshop with a wall of hand tools, a desk with a computer, a shelf labeled Products in Progress, and a foreground drafting table with an open sketchbook.
room_caption: WORKSHOP — APPS & TOOLS
hotspots:
- key: tools
  label: Tool wall
  x: 23
  y: 10
  w: 27
  h: 32
- key: apps
  label: Products in Progress
  x: 81
  y: 5
  w: 18
  h: 63
- key: drafting-table
  label: Drafting table
  x: 5
  y: 58
  w: 53
  h: 39
- key: nav-studio
  label: → Main Studio
  x: 1
  y: 8
  w: 18
  h: 64
  nav: true
content_data:
  tools:
    eyebrow: The tool wall
    title: Frameworks built from architecture — not opinion.
    badge: Tools division
    tabs:
    - label: Cognitive
      body: Tools that help people understand themselves, navigate decisions, reduce drift, and maintain clarity — identity architecture models, drift detection frameworks, cognitive contradiction engines.
    - label: Math & Science
      body: Tools that compress scientific or mathematical concepts into structured, usable systems. Currently in development.
    - label: Historical & Cultural
      body: Tools that compress large historical or cultural patterns into teachable structures — the Cultural Signature System, the Origin Story Engine, Compression Trees.
  apps:
    eyebrow: On the shelf
    title: Products in Progress
    badge: Apps division
    tabs:
    - label: Mint Pro
      body: Vellum-class book publishing for Android tablets — clean templates, structured formatting, instant previews, and reliable EPUB/PDF generation.
    - label: Life Architecture
      body: A deterministic, offline personal evolution engine that tracks everyday life through a structured state vector and singularity kernel.
    - label: FluxAssist
      body: A clarity-first personal assistant designed to help disabled users organize tasks, simplify decisions, and maintain structure in daily life.
    - label: Bid Master
      body: A lightweight, fast, contractor-focused bidding tool for quick estimates, job organization, and field-ready clarity.
  drafting-table:
    eyebrow: The drafting table
    title: Where it all gets built
    badge: Overview
    body: Everything on this table — the open sketchbook, the rolled blueprints, the notes — is where an idea turns into a working app or tool. Nothing ships without going through here first.
  nav-studio:
    eyebrow: Through the doorway
    title: Main Studio
    badge: Navigate
    body: Head back to the Main Studio to reach the rest of the map.
    links:
    - href: /#scene-main-studio
      label: Go there →
prev_href: /books/
prev_label: The Library
next_href: /tools/
next_label: The Workshop (Tools)
---

## Overview

FluxMintDigital apps are built from deterministic architecture, clarity-first design, and real-world utility. The tools behind them compress complexity into usable, teachable, repeatable structures.

<div class="room-series-grid" markdown="0">
{% for app in site.data.apps %}
  <div class="room-series-card"><h3>{{ app.name }}</h3><p>{{ app.description }}</p></div>
{% endfor %}
</div>
