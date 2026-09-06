(function () {
  'use strict';
  var form = document.getElementById('meeting-intake-form');
  if (!form) return;
  var errorBox = document.getElementById('meeting-form-errors');
  var result = document.getElementById('meeting-draft-result');
  function hideState() {
    errorBox.hidden = true;
    errorBox.textContent = '';
    result.hidden = true;
    form.removeAttribute('data-state');
  }
  form.addEventListener('submit', function (event) {
    event.preventDefault();
    hideState();
    var invalid = Array.prototype.slice.call(form.querySelectorAll(':invalid'));
    if (invalid.length) {
      form.setAttribute('data-state', 'error');
      errorBox.textContent = 'Please describe the problem and desired outcome, then choose one decision path.';
      errorBox.hidden = false;
      errorBox.focus();
      invalid[0].setAttribute('aria-invalid', 'true');
      return;
    }
    form.querySelectorAll('[aria-invalid="true"]').forEach(function (field) { field.removeAttribute('aria-invalid'); });
    form.setAttribute('data-state', 'ready');
    result.hidden = false;
    result.focus();
  });
  form.addEventListener('input', function (event) {
    event.target.removeAttribute('aria-invalid');
    if (form.getAttribute('data-state') === 'error') errorBox.hidden = true;
  });
  form.addEventListener('reset', function () { window.setTimeout(hideState, 0); });
}());
