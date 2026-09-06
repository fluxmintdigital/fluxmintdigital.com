---
layout: default
title: Studio View Unavailable
description: A technical fallback for FluxMintDigital visual scene failures.
permalink: /technical-fallback/
---
<section class="system-state container" aria-labelledby="fallback-heading">
  <p class="semantic-kicker">A clearer path</p><h1 id="fallback-heading">The visual path is unavailable, but the Studio remains open.</h1>
  <p>The scenery did not load, but every Room is still within reach. Choose where you would like to go.</p>
  {% include room-navigation.html %}
  <nav class="relationship-exits" aria-label="Technical fallback options"><a href="{{ '/search/' | relative_url }}">Search the Studio</a><a href="{{ '/studio/' | relative_url }}">Try Main Studio again</a></nav>
</section>
