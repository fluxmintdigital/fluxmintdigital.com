---
layout: default
title: Search
description: Search public FluxMintDigital Rooms, Artifacts, and Observatory writing.
permalink: /search/
---
<section class="search-surface container">
  <header class="semantic-hero">
    <p class="semantic-kicker">Studio utility</p>
    <h1>Search the Studio</h1>
    <p class="semantic-lede">Find public work without losing its Room, type, or history.</p>
  </header>
  <form class="studio-search" id="studio-search-form" role="search" action="{{ '/search/' | relative_url }}" method="get">
    <label for="studio-search-query">What are you looking for?</label>
    <div><input id="studio-search-query" name="q" type="search" autocomplete="off"><button type="submit">Search</button></div>
  </form>
  <p class="search-status" id="search-status" role="status">Enter a word or phrase to search public Rooms, Artifacts, and Observatory writing.</p>
  <div class="search-results" id="search-results" aria-live="polite"></div>
  <noscript><p class="surface-panel">Search requires JavaScript. All Rooms remain available through the Studio navigation, and public writing remains available through the Observatory archive.</p></noscript>
</section>
<script id="studio-search-data" type="application/json">
{
  "rooms": [{% for room in site.data.rooms %}{"title":{{ room.name | jsonify }},"description":{{ room.description | jsonify }},"type":"Room","room":{{ room.id | jsonify }},"url":{{ room.route | jsonify }}}{% unless forloop.last %},{% endunless %}{% endfor %}],
  "artifacts": [{% assign public_artifacts = site.artifacts | where: 'visibility', 'public' %}{% for artifact in public_artifacts %}{"title":{{ artifact.title | jsonify }},"description":{{ artifact.description | jsonify }},"type":{{ artifact.artifact_type | jsonify }},"room":{{ artifact.canonical_room | jsonify }},"url":{{ artifact.url | jsonify }}}{% unless forloop.last %},{% endunless %}{% endfor %}],
  "observatory": [{% assign public_posts = site.posts | where: 'visibility', 'public' %}{% for post in public_posts %}{"title":{{ post.title | jsonify }},"description":{{ post.description | jsonify }},"type":{{ post.artifact_type | jsonify }},"room":"observatory","url":{{ post.url | jsonify }}}{% unless forloop.last %},{% endunless %}{% endfor %}]
}
</script>
<script src="{{ '/assets/js/studio-search.js' | relative_url }}" defer></script>
