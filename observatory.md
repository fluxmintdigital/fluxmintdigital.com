---
layout: default
title: Observatory
description: Essays, field notes, discoveries, and exploratory interpretation from FluxMintDigital.
permalink: /observatory/
canonical_room: observatory
workspace_title: Notice from the Observatory
---
{% include observatory-scene.html %}

<div class="observatory-orientation container">
  <section class="observatory-posture" aria-labelledby="observatory-posture-heading">
    <p class="semantic-kicker">A place to wonder</p>
    <h2 id="observatory-posture-heading">Notice, question, and explore</h2>
    <p>These pieces share observations, interpretations, and ideas in motion. When a question needs formal evidence and examination, it belongs on the Architecture Wall.</p>
  </section>

  <section aria-labelledby="featured-observations-heading">
    <p class="semantic-kicker">Selected observations</p>
    <h2 id="featured-observations-heading">From the Observatory</h2>
    <div class="observatory-grid">
      {% for featured_url in site.data.observatory.featured %}
        {% assign featured_post = site.posts | where: 'url', featured_url | first %}
        {% if featured_post and featured_post.visibility == 'public' %}
          {% assign is_current = false %}{% if featured_post.url == site.data.observatory.current_observation %}{% assign is_current = true %}{% endif %}
          {% include observatory-card.html post=featured_post current=is_current %}
        {% endif %}
      {% endfor %}
    </div>
  </section>

  <section aria-labelledby="observatory-forms-heading">
    <p class="semantic-kicker">Four ways to notice</p>
    <h2 id="observatory-forms-heading">Ways of noticing</h2>
    <div class="observatory-forms">
      {% for form in site.data.observatory.forms %}
        {% assign form_posts = site.posts | where: 'visibility', 'public' | where: 'artifact_type', form.artifact_type %}
        <article id="observatory-{{ form.id }}" class="surface-card">
          <h3>{{ form.label }}</h3><p>{{ form.description }}</p><span>{{ form_posts.size }} public {% if form_posts.size == 1 %}piece{% else %}pieces{% endif %}</span>
        </article>
      {% endfor %}
    </div>
  </section>

  <section aria-labelledby="observatory-topics-heading">
    <p class="semantic-kicker">Follow your curiosity</p>
    <h2 id="observatory-topics-heading">Topics</h2>
    <p>Topics offer another way to follow an idea across essays, discoveries, Field Notes, and Workshop Notes.</p>
    <ul class="topic-list">
      {% assign sorted_topics = site.tags | sort %}
      {% for topic in sorted_topics %}<li><span>{{ topic[0] }}</span><small>{{ topic[1].size }} pieces</small></li>{% endfor %}
    </ul>
  </section>

  <nav class="relationship-exits" aria-label="Observatory exits">
    <a href="{{ '/studio-blog/' | relative_url }}">Browse archive and history</a>
    <a href="{{ '/studio/' | relative_url }}">Return to Main Studio</a>
    <a href="{{ '/search/' | relative_url }}">Search this Studio</a>
  </nav>
</div>
