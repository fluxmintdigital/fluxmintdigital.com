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
    <p class="meeting-intake__lede">You do not need a polished brief. Use this private worksheet to find the shape of what you want to discuss.</p>
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
      <p class="meeting-privacy">This draft stays on your device. Nothing you type here is sent anywhere.</p>
      <div class="meeting-draft-result" id="meeting-draft-result" role="status" tabindex="-1" hidden><p class="semantic-kicker">Ready to review</p><h3>You have the beginnings of a useful conversation.</h3><p>Your answers are still only a private draft. Nothing has been submitted, and no work has been promised.</p><div class="meeting-human-handoff"><h4>Ready to bring it to the table?</h4><p>This worksheet has not been sent and stays on this device. If you want to continue, contact DJ separately and choose what, if anything, you share.</p><a class="button button--quiet" href="mailto:fluxmintdigital@gmail.com">Contact DJ</a></div></div>
    </form>
  </section>

  <section id="meeting-outcomes" aria-labelledby="meeting-outcomes-heading">
    <p class="semantic-kicker">What you may leave with</p><h2 id="meeting-outcomes-heading">Clarity before commitment</h2>
    <div class="meeting-boundaries">{% for boundary in site.data.meeting_table.boundaries %}<article class="surface-card"><h3>{{ boundary.title }}</h3><p>{{ boundary.description }}</p></article>{% endfor %}</div>
  </section>

  <section id="implementation-decision" class="surface-panel meeting-decision" aria-labelledby="implementation-decision-heading">
    <p class="semantic-kicker">Choose the next step</p><h2 id="implementation-decision-heading">A clear plan does not automatically become a build</h2>
    <p>A conversation may end with guidance, continue into separately agreed Workshop work, or simply reveal that another path is better. Building is always a separate decision.</p>
    <a class="button button--quiet" href="{{ '/workshop/' | relative_url }}">See what happens in the Workshop</a>
  </section>

  <nav class="relationship-exits" aria-label="Meeting Table exits"><a href="{{ '/studio/' | relative_url }}">Return to Main Studio</a><a href="{{ '/workshop/' | relative_url }}">Visit the Workshop</a><a href="{{ '/search/' | relative_url }}">Search this Studio</a></nav>
</div>
<script src="{{ '/assets/js/meeting-table-intake.js' | relative_url }}" defer></script>
