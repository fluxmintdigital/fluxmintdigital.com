---
layout: default
title: Link Restore Support
description: Practical support and problem reports for Link Restore.
permalink: /support/link-restore/
canonical_room: workshop
---

<div class="container">
  <article class="series-summary">
    <p class="semantic-kicker">Practical Tools / Support</p>
    <h1>Link Restore Support</h1>
    <p class="semantic-lede">Link Restore is intended to restore expected browser behavior when a website interferes with Ctrl/Cmd-click, Ctrl/Cmd+Shift-click, Shift-click, or middle-click.</p>

    <div class="prose">
      <section class="inside-the-work" aria-labelledby="support-checks-heading">
        <h2 id="support-checks-heading">Link Restore appears not to work on a site</h2>
        <p>Open the extension’s existing interface and verify that Link Restore is enabled globally. Then check whether the current domain is excluded and, if it is, re-enable Link Restore for that site. The extension works on ordinary HTTP and HTTPS webpages and only responds to supported modified-link interactions.</p>
      </section>

      <section class="inside-the-work" aria-labelledby="support-unexpected-heading">
        <h2 id="support-unexpected-heading">A site behaves unexpectedly</h2>
        <p>Websites implement links and click handling differently. Link Restore is intended to restore the documented browser behavior when a site interferes with it; it cannot and should not override every possible website behavior. A reproducible problem can be reported for examination.</p>
      </section>

      <section class="inside-the-work" aria-labelledby="support-global-heading">
        <h2 id="support-global-heading">Link Restore is disabled globally</h2>
        <p>Open Link Restore’s existing popup interface and verify the global <strong>Link Restore enabled</strong> control. Turn it back on there if you want Link Restore to evaluate supported interactions again.</p>
      </section>

      <section class="inside-the-work" aria-labelledby="support-site-heading">
        <h2 id="support-site-heading">Link Restore is disabled for the current site</h2>
        <p>Open the extension popup while viewing the affected domain. Check the current site’s <strong>Enabled on this site</strong> control. If the domain is excluded, enable it there to remove the per-site exclusion.</p>
      </section>

      <section class="inside-the-work" aria-labelledby="support-restricted-heading">
        <h2 id="support-restricted-heading">Restricted browser pages</h2>
        <p>Chrome and Chromium-based browsers restrict extensions from operating on certain browser-controlled or protected pages. Link Restore cannot run on those pages; this is a browser restriction, not a Link Restore malfunction.</p>
      </section>

      <section class="inside-the-work" aria-labelledby="support-report-heading">
        <h2 id="support-report-heading">Report a reproducible problem</h2>
        <p>Use the existing FluxMintDigital contact method and provide only:</p>
        <ul>
          <li>browser and version;</li>
          <li>operating system;</li>
          <li>website or domain where the issue occurs;</li>
          <li>interaction used: Ctrl/Cmd-click, Ctrl/Cmd+Shift-click, Shift-click, or middle-click;</li>
          <li>expected behavior;</li>
          <li>observed behavior.</li>
        </ul>
        <p>Do not send browsing history, private or authenticated URLs, usernames or passwords, account credentials, cookies, authentication tokens, sensitive page contents, or other unnecessary private information.</p>
        <p><a class="button button--quiet" href="mailto:{{ site.data.studio.owner.email | escape }}">Email Link Restore support</a></p>
      </section>
    </div>
  </article>
</div>
