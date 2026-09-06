(function () {
  'use strict';
  var form = document.getElementById('studio-search-form');
  var dataNode = document.getElementById('studio-search-data');
  if (!form || !dataNode) return;
  var input = document.getElementById('studio-search-query');
  var status = document.getElementById('search-status');
  var resultsNode = document.getElementById('search-results');
  var source = JSON.parse(dataNode.textContent);
  var records = source.rooms.concat(source.artifacts, source.observatory);

  function render(query) {
    resultsNode.replaceChildren();
    var normalized = query.trim().toLocaleLowerCase();
    if (!normalized) {
      status.textContent = 'Enter a word or phrase to search the Rooms, Artifacts, and Observatory writing shared here.';
      return;
    }
    var matches = records.filter(function (record) {
      return [record.title, record.description, record.type, record.room].join(' ').toLocaleLowerCase().includes(normalized);
    });
    status.textContent = matches.length ? matches.length + (matches.length === 1 ? ' result' : ' results') + ' for “' + query.trim() + '”.' : 'Nothing in the Studio matched “' + query.trim() + '”. Try a Room, title, form, or topic.';
    matches.forEach(function (record) {
      var article = document.createElement('article');
      article.className = 'surface-card search-result';
      var meta = document.createElement('p');
      meta.className = 'semantic-kicker';
      meta.textContent = record.type + ' · ' + record.room.replaceAll('-', ' ');
      var heading = document.createElement('h2');
      var link = document.createElement('a');
      link.href = record.url;
      link.textContent = record.title;
      heading.appendChild(link);
      var description = document.createElement('p');
      description.textContent = record.description;
      article.append(meta, heading, description);
      resultsNode.appendChild(article);
    });
  }

  form.addEventListener('submit', function (event) {
    event.preventDefault();
    render(input.value);
    var url = new URL(window.location.href);
    if (input.value.trim()) url.searchParams.set('q', input.value.trim()); else url.searchParams.delete('q');
    window.history.replaceState({}, '', url);
  });
  var initial = new URL(window.location.href).searchParams.get('q');
  if (initial) { input.value = initial; render(initial); }
}());
