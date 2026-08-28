---
title: Gaussian Elimination
parent: Materials
nav_order: 2
---

# Gaussian elimination, one step at a time

Drag the two sliders to move through the two loops of the forward elimination
phase. `k` is the outer loop (which column we are clearing), `i` is the inner
loop (which row we are clearing it from).

{::nomarkdown}
<div id="ge-demo">
  <div class="ge-controls">
    <label>
      <span class="ge-lbl">Outer loop <code>k</code> = <b id="ge-kval">1</b></span>
      <input type="range" id="ge-k" min="1" value="1" step="1">
    </label>
    <label>
      <span class="ge-lbl">Inner loop <code>i</code> = <b id="ge-ival">2</b></span>
      <input type="range" id="ge-i" min="2" value="2" step="1">
    </label>
    <label class="ge-nsize">
      <span class="ge-lbl">Size <code>n</code> = <b id="ge-nval">5</b></span>
      <input type="range" id="ge-n" min="3" max="8" value="5" step="1">
    </label>
    <span class="ge-steps">
      <button type="button" id="ge-prev" aria-label="previous step">&#9664; step</button>
      <button type="button" id="ge-next" aria-label="next step">step &#9654;</button>
    </span>
  </div>

  <div class="ge-stage">
    <div class="ge-block">
      <div class="ge-name">A</div>
      <div class="ge-grid" id="ge-A"></div>
    </div>
    <div class="ge-block">
      <div class="ge-name">b</div>
      <div class="ge-grid ge-vec" id="ge-b"></div>
    </div>
  </div>

  <p class="ge-sentence" id="ge-sentence"></p>

  <pre class="ge-code" id="ge-code"></pre>
</div>

<style>
#ge-demo {
  --ge-green:  #1a8f4c;
  --ge-blue:   #1667c8;
  --ge-purple: #8b3fc4;
  --ge-green-bg:  #d8f2e2;
  --ge-blue-bg:   #d6e6fb;
  --ge-purple-bg: #ecdcfa;
  margin: 1.5rem 0 2rem;
}
#ge-demo .ge-controls {
  display: flex;
  flex-wrap: wrap;
  gap: 1.25rem 2rem;
  align-items: flex-end;
  margin-bottom: 1.25rem;
}
#ge-demo .ge-controls label { display: block; }
#ge-demo .ge-lbl { display: block; font-size: .8rem; margin-bottom: .25rem; }
#ge-demo .ge-controls input[type=range] { width: 11rem; display: block; }
#ge-demo .ge-nsize { opacity: .75; }
#ge-demo .ge-steps button {
  font: inherit;
  font-size: .8rem;
  padding: .25rem .6rem;
  cursor: pointer;
  border: 1px solid #ccc;
  border-radius: 4px;
  background: #f7f7f7;
}
#ge-demo .ge-steps button:hover { background: #ececec; }

#ge-demo .ge-stage { display: flex; align-items: flex-start; gap: 1.75rem; }
#ge-demo .ge-name {
  font-style: italic;
  font-weight: 700;
  font-size: 1.1rem;
  text-align: center;
  margin-bottom: .35rem;
}
#ge-demo .ge-grid {
  display: grid;
  gap: 3px;
  padding: .4rem;
  border-left: 3px solid #999;
  border-right: 3px solid #999;
  border-radius: 3px;
}
#ge-demo .ge-cell {
  width: 2.2rem;
  height: 2.2rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  background: #eef0f2;
  color: #7b8288;
  font-size: .95rem;
  transition: background-color .12s ease, color .12s ease;
}
#ge-demo .ge-cell.zero { background: #f7f8f9; color: #c3c8cc; }
#ge-demo .ge-cell.green  { background: var(--ge-green-bg);  color: var(--ge-green);  }
#ge-demo .ge-cell.blue   { background: var(--ge-blue-bg);   color: var(--ge-blue);   }
#ge-demo .ge-cell.purple {
  background: var(--ge-purple-bg);
  color: var(--ge-purple);
  box-shadow: inset 0 0 0 2px var(--ge-purple);
  font-weight: 700;
}
#ge-demo .ge-sentence {
  margin-top: 1.25rem;
  font-size: 1.05rem;
  line-height: 1.7;
}
#ge-demo .ge-sentence .g { color: var(--ge-green);  background: var(--ge-green-bg);  padding: .1rem .35rem; border-radius: 4px; }
#ge-demo .ge-sentence .b { color: var(--ge-blue);   background: var(--ge-blue-bg);   padding: .1rem .35rem; border-radius: 4px; }
#ge-demo .ge-sentence .p { color: var(--ge-purple); background: var(--ge-purple-bg); padding: .1rem .35rem; border-radius: 4px; }
#ge-demo .ge-code {
  margin-top: 1rem;
  padding: .75rem 1rem;
  background: #f5f6f7;
  border-radius: 4px;
  font-size: .85rem;
  line-height: 1.5;
  overflow-x: auto;
}
#ge-demo .ge-code .hl { background: #fff3bf; border-radius: 3px; }
</style>

<script>
(function () {
  var A = document.getElementById('ge-A'),
      bEl = document.getElementById('ge-b'),
      kIn = document.getElementById('ge-k'),
      iIn = document.getElementById('ge-i'),
      nIn = document.getElementById('ge-n'),
      sentence = document.getElementById('ge-sentence'),
      code = document.getElementById('ge-code');

  var n = +nIn.value, k = 1, i = 2;

  function build() {
    A.style.gridTemplateColumns = 'repeat(' + n + ', 2.2rem)';
    bEl.style.gridTemplateColumns = '2.2rem';
    A.innerHTML = '';
    bEl.innerHTML = '';
    for (var r = 1; r <= n; r++) {
      for (var c = 1; c <= n; c++) {
        var d = document.createElement('div');
        d.className = 'ge-cell';
        d.dataset.r = r;
        d.dataset.c = c;
        A.appendChild(d);
      }
      var v = document.createElement('div');
      v.className = 'ge-cell';
      v.dataset.r = r;
      bEl.appendChild(v);
    }
  }

  // Cells in column c below the diagonal that the algorithm has already
  // zeroed by the time we are at step (k, i).
  function isZeroed(r, c) {
    if (r <= c) return false;
    if (c < k) return true;
    return c === k && r < i;
  }

  function render() {
    kIn.max = Math.max(1, n - 1);
    if (k > +kIn.max) k = +kIn.max;
    iIn.min = k + 1;
    iIn.max = n;
    if (i < k + 1) i = k + 1;
    if (i > n) i = n;
    kIn.value = k; iIn.value = i; nIn.value = n;
    document.getElementById('ge-kval').textContent = k;
    document.getElementById('ge-ival').textContent = i;
    document.getElementById('ge-nval').textContent = n;

    A.querySelectorAll('.ge-cell').forEach(function (d) {
      var r = +d.dataset.r, c = +d.dataset.c, cls = 'ge-cell', txt = '×';
      if (isZeroed(r, c)) { cls += ' zero'; txt = '0'; }
      else if (r === i && c === k) { cls += ' purple'; }
      else if (r === k && c >= k) { cls += ' green'; }
      else if (r === i && c > k) { cls += ' blue'; }
      d.className = cls;
      d.textContent = txt;
    });
    bEl.querySelectorAll('.ge-cell').forEach(function (d) {
      var r = +d.dataset.r, cls = 'ge-cell';
      if (r === k) cls += ' green';
      else if (r === i) cls += ' blue';
      d.className = cls;
      d.textContent = '×';
    });

    sentence.innerHTML =
      'Subtract <i>f</i> &times; <span class="g">row ' + k + '</span> from ' +
      '<span class="b">row ' + i + '</span> to eliminate ' +
      '<span class="p">a<sub>' + i + k + '</sub></span>, ' +
      'where <i>f</i> = a<sub>' + i + k + '</sub> / a<sub>' + k + k + '</sub>.';

    code.innerHTML =
      'for k = 1 &hellip; n-1          <span class="hl">k = ' + k + '</span>\n' +
      '    for i = k+1 &hellip; n      <span class="hl">i = ' + i + '</span>\n' +
      '        f = A[i,k] / A[k,k]\n' +
      '        A[i,k:n] -= f * A[k,k:n]\n' +
      '        b[i]     -= f * b[k]';
  }

  function stepBy(d) {
    var flat = [];
    for (var kk = 1; kk <= n - 1; kk++)
      for (var ii = kk + 1; ii <= n; ii++) flat.push([kk, ii]);
    var at = flat.findIndex(function (p) { return p[0] === k && p[1] === i; });
    at = Math.min(flat.length - 1, Math.max(0, at + d));
    k = flat[at][0]; i = flat[at][1];
    render();
  }

  kIn.addEventListener('input', function () { k = +kIn.value; if (i < k + 1) i = k + 1; render(); });
  iIn.addEventListener('input', function () { i = +iIn.value; render(); });
  nIn.addEventListener('input', function () { n = +nIn.value; build(); render(); });
  document.getElementById('ge-prev').addEventListener('click', function () { stepBy(-1); });
  document.getElementById('ge-next').addEventListener('click', function () { stepBy(1); });

  build();
  render();
})();
</script>
{:/}

Every cell marked `0` was cleared by an earlier pass of the inner loop; the
grey cells are untouched so far. Note that the row operation only touches
columns `k` through `n` --- everything to the left is already zero, so there is
no reason to compute on it.
