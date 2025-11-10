document.addEventListener('DOMContentLoaded', function () {
  // Add copy buttons
  document.querySelectorAll('pre > code').forEach(function(code) {
    var pre = code.parentElement;
    var btn = document.createElement('button');
    btn.className = 'copy-code';
    btn.type = 'button';
    btn.setAttribute('aria-label', 'Copy code');
    btn.textContent = 'Copy';
    btn.addEventListener('click', async function(){
      try {
        await navigator.clipboard.writeText(code.innerText);
        btn.textContent = 'Copied';
        setTimeout(function(){ btn.textContent = 'Copy'; }, 1500);
      } catch(e) {
        btn.textContent = 'Oops';
        setTimeout(function(){ btn.textContent = 'Copy'; }, 1500);
      }
    });
    pre.appendChild(btn);
  });

  // Add visible anchors to h2/h3
  Array.from(document.querySelectorAll('h2, h3')).forEach(function(h) {
    if (!h.id) return;
    var a = document.createElement('a');
    a.href = '#' + h.id;
    a.className = 'anchor';
    a.textContent = '▣';
    a.setAttribute('aria-label', 'Link to this section');
    a.setAttribute('title', 'Link to this section');
    h.appendChild(a);
  });
});
