/**
 * main.js — Tab active state highlighting
 *
 * Reads the current page filename from window.location.pathname
 * and adds the "terminal__tab--active" class to the matching tab.
 *
 * Note: Each HTML file already hard-codes the active class for its
 * own tab (so this works without JS too). This script is a fallback
 * and handles any edge cases (e.g. index.html redirecting to aboutme.html).
 */
// Disable browser scroll restoration so refresh always starts at the top
if ('scrollRestoration' in history) {
  history.scrollRestoration = 'manual';
}
window.scrollTo(0, 0);

(function () {
  'use strict';

  // Get the current filename from the URL path (e.g. "education.html")
  var path = window.location.pathname;
  var filename = path.split('/').pop() || 'aboutme.html';

  // Treat root / and index.html as the about page
  if (filename === '' || filename === 'index.html') {
    filename = 'aboutme.html';
  }

  // Find all tabs and mark the one matching the current page as active
  var tabs = document.querySelectorAll('.terminal__tab');
  tabs.forEach(function (tab) {
    var href = tab.getAttribute('href') || '';
    var tabFile = href.split('/').pop();
    if (tabFile === filename) {
      tab.classList.add('terminal__tab--active');
    }
  });
}());
