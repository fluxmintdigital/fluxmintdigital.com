---
layout: default
title: Meeting Table
description: Collaboration and problem clarification with DJ Boswell.
permalink: /meeting-table/
canonical_room: meeting-table
---
{% include meeting-table-scene.html %}

<div class="meeting-orientation container">
  <section id="meeting-process" aria-labelledby="meeting-process-heading">
    <p class="semantic-kicker">How the Table works</p>
    <h2 id="meeting-process-heading">Describe → clarify → scope → decide</h2>
    <ol class="meeting-stages">
      {% for stage in site.data.meeting_table.stages %}<li><span>{{ forloop.index }}</span><div><h3>{{ stage.label }}</h3><p>{{ stage.description }}</p></div></li>{% endfor %}
    </ol>
  </section>

  <section id="meeting-intake" aria-labelledby="meeting-intake-heading">
    <p class="semantic-kicker">Private working draft</p>
    <h2 id="meeting-intake-heading">Start with what is actually happening</h2>
    <p class="meeting-intake__lede">You do not need a polished brief. This interface helps structure an inquiry locally; it does not transmit or save what you enter.</p>
    <form class="meeting-intake surface-panel" id="meeting-intake-form" novalidate data-backend-configured="false">
      <div class="form-status" id="meeting-form-errors" role="alert" tabindex="-1" hidden></div>
      <div class="form-field"><label for="meeting-problem">What problem, opportunity, or decision brought you here?</label><textarea id="meeting-problem" name="problem" rows="6" required aria-describedby="meeting-problem-hint"></textarea><p id="meeting-problem-hint">Describe it in your own words. Avoid private credentials, regulated data, or confidential material.</p></div>
      <div class="form-field"><label for="meeting-outcome">What would becoming clearer make possible?</label><textarea id="meeting-outcome" name="outcome" rows="4" required></textarea></div>
      <div class="form-field"><label for="meeting-constraints">What constraints or context already matter?</label><textarea id="meeting-constraints" name="constraints" rows="4"></textarea></div>
      <fieldset class="form-field">
        <legend>Which decision path best describes what you need today?</legend>
        {% for decision in site.data.meeting_table.decisions %}<label class="decision-option" for="decision-{{ decision.id }}"><input id="decision-{{ decision.id }}" type="radio" name="decision" value="{{ decision.id }}" required><span><strong>{{ decision.label }}</strong><small>{{ decision.description }}</small></span></label>{% endfor %}
      </fieldset>
      <div class="form-actions"><button class="button" type="submit">Review my draft</button><button class="button button--quiet" type="reset">Clear draft</button></div>
      <p class="meeting-privacy">Nothing entered here is sent, stored, published, or converted into a public Artifact. No submission backend is configured.</p>
      <div class="meeting-draft-result" id="meeting-draft-result" role="status" tabindex="-1" hidden><p class="semantic-kicker">Draft ready for your review</p><h3>Your local intake draft is structurally complete.</h3><p>This confirms only that the required fields are present. It does not submit an inquiry, promise an engagement, or create an implementation scope.</p></div>
    </form>
  </section>

  <section id="meeting-outcomes" aria-labelledby="meeting-outcomes-heading">
    <p class="semantic-kicker">What you may leave with</p><h2 id="meeting-outcomes-heading">Clarity before commitment</h2>
    <div class="meeting-boundaries">{% for boundary in site.data.meeting_table.boundaries %}<article class="surface-card"><h3>{{ boundary.title }}</h3><p>{{ boundary.description }}</p></article>{% endfor %}</div>
  </section>

  <section id="implementation-decision" class="surface-panel meeting-decision" aria-labelledby="implementation-decision-heading">
    <p class="semantic-kicker">A deliberate branch</p><h2 id="implementation-decision-heading">Architecture does not automatically become implementation</h2>
    <p>A collaboration can conclude with architectural guidance, move to a separately agreed Workshop scope, or stop because there is no fit. The Workshop is available as a possible continuation only after that decision.</p>
    <a class="button button--quiet" href="{{ '/workshop/' | relative_url }}">Understand the Workshop boundary</a>
  </section>

  <nav class="relationship-exits" aria-label="Meeting Table exits"><a href="{{ '/studio/' | relative_url }}">Return to Main Studio</a><a href="{{ '/workshop/' | relative_url }}">Workshop (optional continuation)</a><a href="{{ '/search/' | relative_url }}">Search this Studio</a></nav>
</div>
<script src="{{ '/assets/js/meeting-table-intake.js' | relative_url }}" defer></script>
