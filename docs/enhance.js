/* Ashes of Dereliction — comportements ajoutés (s'ajoute à script.js, qui garde le téléchargement). */
(() => {
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const fine = matchMedia('(pointer:fine)').matches;
  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => [...r.querySelectorAll(s)];

  // --- Progression de lecture + léger parallaxe de l'accueil ---
  const bar = $('.progress'), hero = $('.hero'), heroImg = $('.hero-img');
  let ticking = false;
  const onScroll = () => {
    if (ticking) return;
    ticking = true;
    requestAnimationFrame(() => {
      const d = document.documentElement;
      const max = d.scrollHeight - d.clientHeight;
      if (bar && max > 0) bar.style.transform = `scaleX(${d.scrollTop / max})`;
      if (heroImg && hero && !reduce) {
        const y = Math.min(d.scrollTop, hero.offsetHeight);
        heroImg.style.setProperty('--py', `${(y * 0.14).toFixed(1)}px`);
      }
      ticking = false;
    });
  };
  addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  if (hero && heroImg && !reduce && fine) {
    hero.addEventListener('pointermove', e => {
      const r = hero.getBoundingClientRect();
      heroImg.style.setProperty('--mx', `${(-((e.clientX - r.left) / r.width - 0.5) * 20).toFixed(1)}px`);
      heroImg.style.setProperty('--my', `${(-((e.clientY - r.top) / r.height - 0.5) * 12).toFixed(1)}px`);
    }, { passive: true });
  }

  // --- Numéro de version affiché dans l'accueil (copié depuis le bloc de téléchargement) ---
  const version = $('#version'), heroVersion = $('#hero-version-text');
  if (version && heroVersion) {
    const sync = () => {
      const m = version.textContent.trim().match(/^Version\s*:\s*(.+)$/i);
      if (m) heroVersion.textContent = `Version de test ${m[1]} disponible`;
    };
    new MutationObserver(sync).observe(version, { childList: true, characterData: true, subtree: true });
    sync();
  }

  // --- Lien actif dans le menu ---
  const links = new Map($$('.nav a[href^="#"]').map(a => [a.getAttribute('href').slice(1), a]));
  if ('IntersectionObserver' in window) {
    const spy = new IntersectionObserver(entries => {
      entries.forEach(en => {
        if (!en.isIntersecting) return;
        links.forEach(a => a.classList.remove('active'));
        links.get(en.target.id)?.classList.add('active');
      });
    }, { rootMargin: '-45% 0px -50% 0px' });
    links.forEach((_, id) => { const s = document.getElementById(id); if (s) spy.observe(s); });
  }

  // --- Barres de statistiques : elles se remplissent quand la carte apparaît ---
  const cards = $$('.hero-card');
  if ('IntersectionObserver' in window) {
    const io = new IntersectionObserver(entries => entries.forEach(en => {
      if (en.isIntersecting) { en.target.classList.add('on'); io.unobserve(en.target); }
    }), { threshold: 0.35 });
    cards.forEach(c => io.observe(c));
  } else cards.forEach(c => c.classList.add('on'));

  // --- Bande-annonce : la vidéo ne se charge qu'au clic ---
  const player = $('#player');
  const startTrailer = () => {
    if (!player || $('video', player)) return;
    const v = document.createElement('video');
    v.src = player.dataset.src;
    v.controls = true;
    v.autoplay = true;
    v.playsInline = true;
    v.poster = $('img', player)?.src || '';
    v.setAttribute('aria-label', 'Bande-annonce d’Ashes of Dereliction');
    player.classList.add('playing');
    player.appendChild(v);
    v.play?.().catch(() => {});
    v.focus?.();
  };
  $('.play', player)?.addEventListener('click', startTrailer);
  $('#watch-trailer')?.addEventListener('click', () => {
    $('#trailer')?.scrollIntoView({ behavior: reduce ? 'auto' : 'smooth', block: 'start' });
    setTimeout(startTrailer, reduce ? 0 : 700);
  });

  // --- Galerie : fenêtre d'agrandissement au clavier et à la souris ---
  const shots = $$('.shot');
  const dlg = $('#lightbox');
  if (dlg && shots.length) {
    const img = $('#lightbox-img'), cap = $('#lightbox-caption');
    let i = 0;
    const show = n => {
      i = (n + shots.length) % shots.length;
      const s = shots[i];
      img.src = s.dataset.full;
      img.alt = $('img', s).alt;
      cap.textContent = $('span', s).textContent;
    };
    shots.forEach((s, n) => s.addEventListener('click', () => { show(n); dlg.showModal(); }));
    $('.lb-next', dlg).addEventListener('click', () => show(i + 1));
    $('.lb-prev', dlg).addEventListener('click', () => show(i - 1));
    $('.lb-close', dlg).addEventListener('click', () => dlg.close());
    dlg.addEventListener('click', e => { if (e.target === dlg) dlg.close(); });
    dlg.addEventListener('keydown', e => {
      if (e.key === 'ArrowRight') show(i + 1);
      if (e.key === 'ArrowLeft') show(i - 1);
    });
  }
})();
