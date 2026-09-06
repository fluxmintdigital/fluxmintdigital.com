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
    <p class="semantic-kicker">Exploratory posture</p>
    <h2 id="observatory-posture-heading">Published noticing, not evidentiary warrant</h2>
    <p>Observatory pieces may observe, interpret, or speculate. Publication makes them public Artifacts; it does not make them evidence, scientific truth, or an Architecture Wall confidence or AEG-warrant record.</p>
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
    <p class="semantic-kicker">Artifact forms</p>
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
    <p class="semantic-kicker">Cross-cutting lens</p>
    <h2 id="observatory-topics-heading">Topics</h2>
    <p>Topics connect pieces across forms. They do not replace the Observatory, its Artifact types, or canonical Rooms.</p>
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
