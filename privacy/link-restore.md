---
layout: default
title: Link Restore Privacy
description: How Link Restore handles local browser access, settings, and browsing data.
permalink: /privacy/link-restore/
canonical_room: workshop
---

<div class="container">
  <article class="series-summary">
    <p class="semantic-kicker">Practical Tools / Privacy</p>
    <h1>Link Restore Privacy</h1>
    <p class="semantic-lede">Link Restore is designed to perform its function locally in your browser without sending browsing activity to FluxMintDigital.</p>

    <div class="prose">
      <section class="inside-the-work" aria-labelledby="privacy-basics-heading">
        <h2 id="privacy-basics-heading">Privacy at a glance</h2>
        <p>Link Restore does not require an account and does not use advertising, analytics, or behavioral tracking. It does not collect or store browsing history, and it does not sell user data.</p>
        <p>Link Restore does not transmit clicked URLs or browsing activity to FluxMintDigital. It does not use a FluxMintDigital backend or external API for normal operation, and it does not load remotely hosted executable code.</p>
        <p><strong>Local functional access ≠ collection or transmission to FluxMintDigital.</strong></p>
      </section>

      <section class="inside-the-work" aria-labelledby="privacy-local-heading">
        <h2 id="privacy-local-heading">What happens locally</h2>
        <p>Link Restore necessarily observes qualifying link interactions on ordinary HTTP and HTTPS webpages locally in the browser so it can determine whether standard browser link behavior needs to be restored. That local page and link access is used only to provide the extension’s stated functionality.</p>
        <p>Link Restore does not retain a browsing history or a history of those interactions. It does not send those interactions or their URLs to FluxMintDigital.</p>
      </section>

      <section class="inside-the-work" aria-labelledby="privacy-permissions-heading">
        <h2 id="privacy-permissions-heading">Permissions and Site Access</h2>
        <p>Link Restore requires access to ordinary webpages because its purpose is to detect cases where a website interferes with normal browser link-opening behavior involving:</p>
        <ul>
          <li>Ctrl/Cmd-click;</li>
          <li>Ctrl/Cmd+Shift-click;</li>
          <li>Shift-click;</li>
          <li>middle-click.</li>
        </ul>
        <p>This evaluation occurs locally in the browser for the purpose of restoring expected browser behavior.</p>
        <p><strong>Normal left-click behavior is not modified by Link Restore.</strong></p>
        <p>Chrome does not allow ordinary extensions to execute on some browser-controlled or otherwise restricted pages. Link Restore does not claim to operate on those pages.</p>
      </section>

      <section class="inside-the-work" aria-labelledby="privacy-settings-heading">
        <h2 id="privacy-settings-heading">Local Settings</h2>
        <p>The global enabled/disabled state is stored locally in the browser. Per-site exclusions are also stored locally in the browser. Those settings are not submitted to FluxMintDigital as part of normal extension operation, and Link Restore does not provide cloud synchronization.</p>
      </section>

      <section class="inside-the-work" aria-labelledby="privacy-changes-heading">
        <h2 id="privacy-changes-heading">Changes to This Privacy Notice</h2>
        <p>Material changes to Link Restore’s privacy practices or this notice will be reflected on this page and accompanied by an updated effective date.</p>
        <p><strong>Effective date: September 23, 2026</strong></p>
      </section>

      <section class="inside-the-work" aria-labelledby="privacy-contact-heading">
        <h2 id="privacy-contact-heading">Contact</h2>
        <p>For privacy or support questions, email <a href="mailto:{{ site.data.studio.owner.email | escape }}">{{ site.data.studio.owner.email }}</a> or use the <a href="{{ '/support/link-restore/' | relative_url }}">Link Restore Support page</a>.</p>
      </section>
    </div>
  </article>
</div>
