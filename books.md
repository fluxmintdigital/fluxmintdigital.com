---
layout: redirect
redirect_to: /library/
redirect_label: the Library
title: Books
description: Visit the Library to explore FluxMintDigital books, publications, and their series.
permalink: /books/
eyebrow: Room / Studio Map — The Library
subhead: Every journey of understanding leaves behind field notes. Take your time. Browse the shelves. Follow your curiosity.
room_image: /assets/images/rooms/library.jpg
room_alt: A warm wood-paneled library with tall bookshelves labeled Systems, Humanity, Nature, History, and Exploration, a leather reading chair, and a foreground table stacked with books.
room_caption: LIBRARY — BOOKS DIVISION
hotspots:
- key: books
  label: Book stack
  x: 68
  y: 62
  w: 16
  h: 30
- key: reading-nook
  label: Reading nook
  x: 2
  y: 48
  w: 22
  h: 44
- key: nav-observatory
  label: → Observatory
  x: 36
  y: 12
  w: 11
  h: 56
  nav: true
- key: nav-studio
  label: → Main Studio
  x: 68
  y: 8
  w: 30
  h: 64
  nav: true
content_data:
  books:
    eyebrow: The shelves
    title: Curiosity begins here.
    badge: Coming soon
    tabs:
    - label: 'Shelf One: Field Guide'
      body: Curiosity begins here. The DJ Field Guide Series introduces science, systems, history, nature, technology, and countless other subjects through approachable explanations, memorable illustrations, and the spirit of exploration. Designed for curious children. Equally enjoyable for curious adults.
    - label: 'Shelf Two: Wild Side'
      body: Sometimes the best way to understand an idea is to laugh first. Walk on the Wild Side explores philosophy, psychology, science, and culture through humor, storytelling, and playful perspective shifts. Curiosity doesn't always wear a lab coat. Sometimes it wears a backwards hat.
    - label: 'Shelf Three: Architecture Series'
      body: The intellectual foundation of FluxMintDigital. A five-volume series exploring the structures that shape human beings, organizations, knowledge, systems, and reality itself — how humans become themselves, how systems hold together and fall apart, and how humanity emerges between people.
  reading-nook:
    eyebrow: The reading chair
    title: Where do I continue learning?
    badge: Overview
    body: The Library is the public archive of everything FluxMintDigital creates — organized not as a store, but as an inviting place of exploration. Every book, application, framework, and future release belongs to one coherent ecosystem.
  nav-observatory:
    eyebrow: Through the doorway
    title: The Observatory
    badge: Navigate
    body: This leads to the Blog division.
    links:
    - href: /blog/
      label: Go there →
  nav-studio:
    eyebrow: Through the doorway
    title: Main Studio
    badge: Navigate
    body: Head back to the Main Studio to reach the rest of the map.
    links:
    - href: /#scene-main-studio
      label: Go there →
prev_href: /
prev_label: Main Studio
next_href: /apps/
next_label: The Workshop (Apps & Tools)
---

## The Shelves

The Library is organized into collections. Each shelf represents a different way of exploring architecture — but they all share the same purpose: helping people better understand themselves and the world around them.

**Shelf One — DJ Field Guide Series.** Curiosity begins here. An educational universe introducing science, systems, history, nature, and technology through approachable explanations and memorable illustrations. Designed for curious children. Equally enjoyable for curious adults.

**Shelf Two — Walk on the Wild Side With DJ.** Sometimes the best way to understand an idea is to laugh first. Philosophy, psychology, science, and culture explored through humor, storytelling, and playful perspective shifts.

<img src="{{ '/assets/images/books/field-guide-wild-side-banner.jpg' | relative_url }}" alt="Promotional artwork for the DJ Field Guide Series and Walk on the Wild Side With DJ, showing DJ the explorer between two illustrated series cards." style="width:100%; border-radius: var(--radius); border: 1px solid var(--border); margin: 0.5rem 0 1.5rem;">

**Shelf Three — The Architecture Series.** The intellectual foundation of the studio. A five-volume series exploring the structures that shape human beings, organizations, knowledge, systems, and reality itself.

<img src="{{ '/assets/images/books/architecture-series-banner.jpg' | relative_url }}" alt="Promotional artwork for The Architecture Series showing all five volume covers alongside DJ the explorer in a lab coat." style="width:100%; border-radius: var(--radius); border: 1px solid var(--border); margin: 0.5rem 0 1.5rem;">


<div class="room-series-grid" markdown="0">
{% for book in site.data.books %}
  <div class="room-series-card"><h3>{{ book.name }}</h3><p>{{ book.description }}</p></div>
{% endfor %}
</div>
