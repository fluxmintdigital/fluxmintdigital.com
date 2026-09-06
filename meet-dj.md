---
layout: default
title: Meet DJ
description: Meet D.J. Boswell, the author, builder, researcher, collaborator, and steward behind FluxMintDigital.
permalink: /meet-dj/
---
{% include meet-dj-scene.html %}

{% assign dj = site.data.studio.owner %}
<article class="person-surface dj-orientation container">
  <section aria-labelledby="about-dj-heading">
    <p class="semantic-kicker">The person behind the Studio</p>
    <h2 id="about-dj-heading">Curious across forms, responsible in each one</h2>
    <div class="prose">
      <p>FluxMintDigital grew from a persistent question: <em>what architecture produced this?</em> {{ dj.public_name }} explores that question through writing, software, research, design, and collaborative problem-solving.</p>
      <p>The work takes different forms, but authorship and responsibility stay with the real person behind them. This page is an introduction—not a résumé, credential list, or claim of authority.</p>
    </div>
  </section>

  <section aria-labelledby="dj-roles-heading">
    <p class="semantic-kicker">How DJ participates</p>
    <h2 id="dj-roles-heading">Three practical roles</h2>
    <div class="dj-role-grid">
      <article class="surface-card"><h3>Author</h3><p>Writes and structures published work in the Library, where each publication retains its own canonical Artifact identity and lineage.</p><a href="{{ '/library/' | relative_url }}">Read in the Library</a></article>
      <article class="surface-card"><h3>Builder</h3><p>Develops applications and tools in the Workshop, where ideas become usable things without confusing a project with its releases.</p><a href="{{ '/workshop/' | relative_url }}">Visit the Workshop</a></article>
      <article class="surface-card"><h3>Collaborator</h3><p>Works with people at the Meeting Table to describe real problems, clarify objectives, scope possibilities, and make deliberate decisions.</p><a href="{{ '/meeting-table/' | relative_url }}">Meet at the Table</a></article>
    </div>
  </section>

  <section class="surface-panel dj-identity-boundary" aria-labelledby="dj-explorer-heading">
    <p class="semantic-kicker">Real person and character expression</p>
    <h2 id="dj-explorer-heading">DJ is not replaced by the Explorer</h2>
    <p>Explorer DJ is the Studio’s stylized guide: an expression of curiosity, orientation, and learning alongside visitors. The realistic DJ represents the person in authorship, building, collaboration, and identity contexts. Explorer supplements the experience; it does not inherit authorship, authority, or responsibility.</p>
  </section>

  <section aria-labelledby="dj-studio-relationships-heading">
    <p class="semantic-kicker">Studio relationships</p>
    <h2 id="dj-studio-relationships-heading">One person, distinct Studio identities</h2>
    <p>FluxMintDigital is this Studio. ForgeSpark Studios, when referenced, is a sibling studio—not a FluxMintDigital Room and not a replacement identity for this work.</p>
  </section>

  <nav class="relationship-exits" aria-label="Meet DJ pathways"><a href="mailto:fluxmintdigital@gmail.com">Contact DJ</a><a href="{{ '/library/' | relative_url }}">Authored work</a><a href="{{ '/workshop/' | relative_url }}">Built work</a><a href="{{ '/meeting-table/' | relative_url }}">Collaborate</a><a href="{{ '/studio/' | relative_url }}">Return to Main Studio</a></nav>
</article>
