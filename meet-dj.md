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
      <p>The work takes different forms, but the person behind it stays the same. This is simply a place to meet DJ and see how he works.</p>
    </div>
  </section>

  <section aria-labelledby="dj-roles-heading">
    <p class="semantic-kicker">How DJ participates</p>
    <h2 id="dj-roles-heading">Three practical roles</h2>
    <div class="dj-role-grid">
      <article class="surface-card"><h3>Author</h3><p>Writes and shapes books for the Library, following each idea through the larger series it belongs to.</p><a href="{{ '/library/' | relative_url }}">Read in the Library</a></article>
      <article class="surface-card"><h3>Builder</h3><p>Develops applications and tools in the Workshop, where ideas become things people can actually use.</p><a href="{{ '/workshop/' | relative_url }}">Visit the Workshop</a></article>
      <article class="surface-card"><h3>Collaborator</h3><p>Works with people at the Meeting Table to describe real problems, clarify objectives, scope possibilities, and make deliberate decisions.</p><a href="{{ '/meeting-table/' | relative_url }}">Meet at the Table</a></article>
    </div>
  </section>

  <section class="surface-panel dj-identity-boundary" aria-labelledby="dj-explorer-heading">
    <p class="semantic-kicker">DJ and the Explorer</p>
    <h2 id="dj-explorer-heading">DJ is not replaced by the Explorer</h2>
    <p>Explorer DJ is a playful guide through the Studio—curious, observant, and always ready to look around the next corner. The real DJ is the author, builder, and collaborator responsible for the work itself.</p>
  </section>

  <section aria-labelledby="dj-studio-relationships-heading">
    <p class="semantic-kicker">Studio relationships</p>
    <h2 id="dj-studio-relationships-heading">One person, distinct Studio identities</h2>
    <p>FluxMintDigital is this Studio. ForgeSpark Studios is a sibling studio with its own identity and work.</p>
  </section>

  <nav class="relationship-exits" aria-label="Meet DJ pathways"><a href="mailto:fluxmintdigital@gmail.com">Contact DJ</a><a href="{{ '/library/' | relative_url }}">Authored work</a><a href="{{ '/workshop/' | relative_url }}">Built work</a><a href="{{ '/meeting-table/' | relative_url }}">Collaborate</a><a href="{{ '/studio/' | relative_url }}">Return to Main Studio</a></nav>
</article>
