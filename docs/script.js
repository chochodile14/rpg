(() => {
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  // Chargement de la dernière release GitHub avec un vrai lien de secours.
  const version = document.getElementById('version');
  const notes = document.getElementById('notes');
  const download = document.getElementById('download');
  const hint = document.getElementById('download-hint');
  const releaseUrl = 'https://api.github.com/repos/chochodile14/rpg/releases/latest';

  fetch(releaseUrl)
    .then(response => {
      if (!response.ok) throw new Error('Release indisponible');
      return response.json();
    })
    .then(release => {
      version.textContent = `Version : ${release.tag_name || 'version non précisée'}`;
      notes.textContent = release.body?.trim() || 'Aucune note de version publiée pour le moment.';
      const asset = release.assets?.find(item => item.name.endsWith('.zip')) || release.assets?.[0];
      if (asset?.browser_download_url) {
        download.href = asset.browser_download_url;
        download.setAttribute('download', '');
        hint.textContent = `Fichier : ${asset.name}`;
      } else {
        download.href = release.html_url || 'https://github.com/chochodile14/rpg/releases/latest';
        hint.textContent = 'Ouvrir la page de la release pour choisir un fichier.';
      }
    })
    .catch(() => {
      version.textContent = 'Versions disponibles sur GitHub';
      notes.textContent = 'Impossible de récupérer automatiquement les informations. Consultez la page des releases pour voir les fichiers disponibles.';
      download.href = 'https://github.com/chochodile14/rpg/releases/latest';
      hint.textContent = 'Ouvrir les versions du jeu sur GitHub.';
    });

  // Navigation mobile.
  const menuToggle = document.getElementById('menu-toggle');
  const nav = document.getElementById('nav');
  menuToggle?.addEventListener('click', () => {
    const open = nav.classList.toggle('open');
    menuToggle.setAttribute('aria-expanded', String(open));
    menuToggle.setAttribute('aria-label', open ? 'Fermer le menu' : 'Ouvrir le menu');
    menuToggle.textContent = open ? '×' : '☰';
  });
  nav?.querySelectorAll('a').forEach(link => link.addEventListener('click', () => {
    nav.classList.remove('open');
    menuToggle?.setAttribute('aria-expanded', 'false');
    if (menuToggle) { menuToggle.textContent = '☰'; menuToggle.setAttribute('aria-label', 'Ouvrir le menu'); }
  }));

  // Apparition progressive au défilement.
  const revealItems = document.querySelectorAll('.reveal');
  if ('IntersectionObserver' in window && !reduceMotion) {
    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.13 });
    revealItems.forEach(item => observer.observe(item));
  } else revealItems.forEach(item => item.classList.add('visible'));

  // Halo discret qui suit la souris.
  const glow = document.querySelector('.cursor-glow');
  if (glow && !reduceMotion && matchMedia('(pointer:fine)').matches) {
    window.addEventListener('pointermove', event => {
      glow.style.left = `${event.clientX}px`;
      glow.style.top = `${event.clientY}px`;
    }, { passive: true });
  }

  // Inclinaison légère des cartes au survol.
  if (!reduceMotion && matchMedia('(pointer:fine)').matches) {
    document.querySelectorAll('[data-tilt]').forEach(card => {
      card.addEventListener('pointermove', event => {
        const rect = card.getBoundingClientRect();
        const x = (event.clientX - rect.left) / rect.width;
        const y = (event.clientY - rect.top) / rect.height;
        card.style.transform = `perspective(900px) rotateX(${(0.5-y)*4}deg) rotateY(${(x-0.5)*5}deg) translateY(-3px)`;
      });
      card.addEventListener('pointerleave', () => { card.style.transform = ''; });
    });
  }

  // Particules de braises légères, sans dépendance externe.
  const canvas = document.getElementById('embers');
  const ctx = canvas?.getContext('2d');
  if (!canvas || !ctx || reduceMotion) return;
  let width = 0, height = 0, particles = [];
  const count = Math.min(65, Math.floor(window.innerWidth / 22));
  function resize() {
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    width = window.innerWidth; height = window.innerHeight;
    canvas.width = width * dpr; canvas.height = height * dpr;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    particles = Array.from({length: count}, () => ({
      x: Math.random()*width, y: Math.random()*height,
      r: Math.random()*1.6+.35, speed: Math.random()*.42+.12,
      drift: (Math.random()-.5)*.35, alpha: Math.random()*.5+.12,
      phase: Math.random()*Math.PI*2
    }));
  }
  function draw() {
    ctx.clearRect(0, 0, width, height);
    particles.forEach(p => {
      p.y -= p.speed; p.x += p.drift + Math.sin(p.phase)*.12; p.phase += .015;
      if (p.y < -8) { p.y = height+8; p.x = Math.random()*width; }
      if (p.x < -8) p.x = width+8;
      if (p.x > width+8) p.x = -8;
      ctx.beginPath(); ctx.arc(p.x, p.y, p.r, 0, Math.PI*2);
      ctx.fillStyle = `rgba(239, ${90+Math.floor(p.r*15)}, 43, ${p.alpha})`; ctx.fill();
    });
    requestAnimationFrame(draw);
  }
  resize();
  window.addEventListener('resize', resize, {passive:true});
  draw();
})();