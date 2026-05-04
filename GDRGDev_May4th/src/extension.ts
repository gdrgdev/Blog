import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext) {
    const command = vscode.commands.registerCommand('mayTheFourth.showCrawl', () => {
        showCrawl(context);
    });
    context.subscriptions.push(command);

    const today = new Date();
    const isMayFourth = today.getMonth() === 4 && today.getDate() === 4;

    if (isMayFourth) {
        (globalThis as typeof globalThis & { setTimeout: typeof setTimeout }).setTimeout(() => showCrawl(context), 2000);
    }
}

async function showCrawl(context: vscode.ExtensionContext) {
    const stats = await getWorkspaceStats();

    const panel = vscode.window.createWebviewPanel(
        'mayTheFourth',
        '⚔️ May the 4th Be With You',
        vscode.ViewColumn.One,
        { enableScripts: true, retainContextWhenHidden: false }
    );

    const es = vscode.env.language.startsWith('es');
    const shareText = buildShareText(stats, es);
    panel.webview.html = getHtml(stats, shareText, es);

    panel.webview.onDidReceiveMessage(async msg => {
        if (msg.command === 'copy') {
            await vscode.env.clipboard.writeText(shareText);
            const notification = es
                ? 'Crawl copiado. ¡Compártelo, joven Padawan! ⚔️'
                : 'Crawl copied! Share it, young Padawan ⚔️';
            vscode.window.showInformationMessage(notification);
        }
    }, undefined, context.subscriptions);
}

interface LangStat {
    lang: string;
    count: number;
}

interface WorkspaceStats {
    folderNames: string[];       // todos los nombres de carpeta
    langStats: LangStat[];       // top lenguajes con conteo
    totalFiles: number;
}

async function getWorkspaceStats(): Promise<WorkspaceStats> {
    const folders = vscode.workspace.workspaceFolders ?? [];
    const folderNames = folders.map(f => f.name);

    const langDefs = [
        { glob: '**/*.al',   lang: 'AL' },
        { glob: '**/*.ts',   lang: 'TypeScript' },
        { glob: '**/*.js',   lang: 'JavaScript' },
        { glob: '**/*.cs',   lang: 'C#' },
        { glob: '**/*.py',   lang: 'Python' },
        { glob: '**/*.java', lang: 'Java' },
        { glob: '**/*.go',   lang: 'Go' },
        { glob: '**/*.rs',   lang: 'Rust' },
        { glob: '**/*.cpp',  lang: 'C++' },
        { glob: '**/*.php',  lang: 'PHP' },
        { glob: '**/*.ps1',  lang: 'PowerShell' },
    ];

    const langMap: Record<string, number> = {};

    for (const { glob, lang } of langDefs) {
        try {
            const files = await vscode.workspace.findFiles(glob, '**/node_modules/**', 2000);
            if (files.length > 0) {
                langMap[lang] = (langMap[lang] ?? 0) + files.length;
            }
        } catch { /* continúa */ }
    }

    const langStats: LangStat[] = Object.entries(langMap)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 3)
        .map(([lang, count]) => ({ lang, count }));

    const totalFiles = Object.values(langMap).reduce((s, n) => s + n, 0);

    return { folderNames, langStats, totalFiles };
}

function buildShareText({ folderNames, langStats, totalFiles }: WorkspaceStats, es: boolean): string {
    const isSingle = folderNames.length === 1;

    const repoBlock = isSingle
        ? es
            ? `${folderNames[0].toUpperCase()}\n\n${folderNames[0]} existe solo en la galaxia,\nun faro de código en la oscuridad.`
            : `${folderNames[0].toUpperCase()}\n\n${folderNames[0]} stands alone in the galaxy,\na beacon of code in the darkness.`
        : es
            ? `THE DEVELOPER ALLIANCE\n\nLa Alianza Rebelde abarca ${folderNames.length} repositorios:\n${folderNames.join(', ')}.\nUnidos en su misión contra el Lado Oscuro de la deuda técnica.`
            : `THE DEVELOPER ALLIANCE\n\nThe Rebel Alliance spans ${folderNames.length} repositories:\n${folderNames.join(', ')}.\nUnited in their mission against the Dark Side of technical debt.`;

    let statsBlock: string;
    if (totalFiles === 0) {
        statsBlock = es
            ? `La galaxia espera su primer commit.\nLa Fuerza no necesita un conteo de archivos.`
            : `The galaxy awaits its first commit.\nThe Force does not require a file count.`;
    } else if (langStats.length === 1) {
        statsBlock = es
            ? `${langStats[0].count} archivos ${langStats[0].lang} custodian la galaxia,\ndispersos como estrellas en el vacío.`
            : `${langStats[0].count} ${langStats[0].lang} files guard the galaxy,\nscattered like stars across the void.`;
    } else {
        const parts = langStats.map(l => `${l.count} ${l.lang}`).join(', ');
        statsBlock = es
            ? `${parts} archivos listos para la batalla.\n${totalFiles} archivos en total, dispersos por la galaxia como estrellas.`
            : `${parts} files stand ready.\n${totalFiles} files in total, scattered across the galaxy like stars.`;
    }

    const p1 = es
        ? [`Armados únicamente con cafeína, Stack Overflow,`,
           `y una ventana de VS Code parpadeante, nuestros valientes`,
           `desarrolladores enfrentan otro día de pull requests`,
           `y misteriosos conflictos de merge.`]
        : [`Armed with nothing but caffeine, Stack Overflow,`,
           `and a flickering VS Code window, our brave`,
           `developers face another day of pull requests`,
           `and mysterious merge conflicts.`];

    const p2 = es
        ? [`El camino a producción está lleno de`,
           `advertencias de linting, punto y coma olvidados,`,
           `y un README.md que no se ha tocado`,
           `desde las Guerras Clon.`]
        : [`The path to production is fraught with`,
           `linting warnings, forgotten semicolons, and`,
           `a README.md that has not been touched`,
           `since the Clone Wars.`];

    const p3 = es
        ? [`Pero la esperanza persiste. La Fuerza fluye`,
           `a través de cada variable bien nombrada.`,
           `Cada prueba que pasa es un golpe`,
           `contra el Lado Oscuro.`]
        : [`But hope remains. The Force flows through`,
           `every well-named variable. Every passing test`,
           `is a strike against the Dark Side.`];

    const ending = es ? `Que la Fuerza te acompañe, siempre. ⚔️` : `May the 4th be with you, always. ⚔️`;
    const header = es ? `⚔️ ¡Que la Fuerza te acompañe! #StarWarsDay` : `⚔️ May the 4th Be With You! #StarWarsDay`;
    const intro  = es ? `Hace mucho tiempo, en un repositorio muy, muy lejano....` : `A long time ago, in a repository far, far away....`;

    return [
        header, ``, intro, ``, repoBlock, ``, statsBlock, ``,
        ...p1, ``, ...p2, ``, ...p3, ``, ending, ``,
        `#MayThe4thBeWithYou #VSCode #DevLife #StarWarsDay`,
    ].join('\n');
}

function escapeHtml(str: string): string {
    return str
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

function getHtml({ folderNames, langStats, totalFiles }: WorkspaceStats, _shareText: string, es: boolean): string {
    const episode = Math.floor(Math.random() * 9) + 1;
    const isSingle = folderNames.length === 1;

    const titleHtml = isSingle
        ? escapeHtml(folderNames[0].toUpperCase())
        : `THE DEVELOPER ALLIANCE`;

    const repoHtml = isSingle
        ? es
            ? `El repositorio <em>${escapeHtml(folderNames[0])}</em> existe solo en la galaxia,
               un faro de código en la oscuridad.`
            : `The repository <em>${escapeHtml(folderNames[0])}</em> stands alone
               in the galaxy, a beacon of code in the darkness.`
        : es
            ? `La Alianza Rebelde abarca <strong>${folderNames.length} repositorios</strong>:<br>
               <em>${folderNames.map(escapeHtml).join('</em>, <em>')}</em>.<br>
               Unidos en su misión contra el Lado Oscuro de la deuda técnica.`
            : `The Rebel Alliance spans <strong>${folderNames.length} repositories</strong>:<br>
               <em>${folderNames.map(escapeHtml).join('</em>, <em>')}</em>.<br>
               United in their mission against the Dark Side of technical debt.`;

    let statsHtml: string;
    if (totalFiles === 0) {
        statsHtml = es
            ? `La galaxia espera su primer commit.<br>La Fuerza no necesita un conteo de archivos.`
            : `The galaxy awaits its first commit.<br>The Force does not require a file count.`;
    } else if (langStats.length === 1) {
        statsHtml = es
            ? `<strong>${langStats[0].count} archivos ${langStats[0].lang}</strong> custodian la galaxia,
               dispersos como estrellas en el vacío.`
            : `<strong>${langStats[0].count} ${langStats[0].lang} files</strong>
               guard the galaxy, scattered like stars across the void.`;
    } else {
        const parts = langStats.map(l => `<strong>${l.count} ${l.lang}</strong>`).join(', ');
        statsHtml = es
            ? `${parts} archivos listos para la batalla.<br>
               <strong>${totalFiles} archivos</strong> en total, dispersos por la galaxia como estrellas.`
            : `${parts} files stand ready.<br>
               <strong>${totalFiles} files</strong> in total, scattered across the galaxy like stars.`;
    }

    const introText  = es ? 'Hace mucho tiempo, en un repositorio muy, muy lejano....' : 'A long time ago, in a repository far, far away....';
    const logoSub    = es ? 'que la Fuerza te acompañe' : 'be with you';
    const p1Text     = es
        ? `Armados únicamente con cafeína, Stack Overflow,<br>
           y una ventana de VS Code parpadeante, nuestros valientes<br>
           desarrolladores enfrentan otro día de pull requests<br>
           y misteriosos conflictos de merge.`
        : `Armed with nothing but caffeine, Stack Overflow,<br>
           and a flickering VS Code window, our brave<br>
           developers face another day of pull requests<br>
           and mysterious merge conflicts.`;
    const p2Text     = es
        ? `El camino a producción está lleno de<br>
           advertencias de linting, punto y coma olvidados,<br>
           y un README.md que no se ha tocado<br>
           desde las Guerras Clon.`
        : `The path to production is fraught with<br>
           linting warnings, forgotten semicolons, and<br>
           a README.md that has not been touched<br>
           since the Clone Wars.`;
    const p3Text     = es
        ? `Pero la esperanza persiste. La Fuerza fluye<br>
           a través de cada variable bien nombrada.<br>
           Cada prueba que pasa es un golpe<br>
           contra el Lado Oscuro.`
        : `But hope remains. The Force flows through<br>
           every well-named variable. Every passing test<br>
           is a strike against the Dark Side.`;
    const endText    = es ? 'Que la Fuerza te acompañe, siempre. ⚔️' : 'May the 4th be with you, always. ⚔️';
    const btnLabel   = es ? '⚔️ Copiar Crawl' : '⚔️ Copy Crawl';

    return /* html */`<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline';">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }

  body {
    background: #000;
    color: #FFE81F;
    font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif;
    overflow: hidden;
    height: 100vh;
  }

  canvas#stars {
    position: fixed;
    top: 0; left: 0;
    width: 100%; height: 100%;
    z-index: 0;
  }

  /* ---- INTRO ---- */
  #intro {
    position: absolute;
    width: 100%;
    text-align: center;
    font-size: 1.6em;
    letter-spacing: 0.35em;
    color: #ffffff;
    top: 50%;
    transform: translateY(-50%);
    z-index: 10;
    animation: introFade 4s ease-in-out forwards;
  }
  @keyframes introFade {
    0%   { opacity: 0; }
    25%  { opacity: 1; }
    75%  { opacity: 1; }
    100% { opacity: 0; }
  }

  /* ---- LOGO ---- */
  #logo {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    text-align: center;
    z-index: 10;
    opacity: 0;
    animation: logoAnim 3.5s ease-in-out 4s forwards;
  }
  #logo .main { font-size: 4.8em; font-weight: 900; letter-spacing: 0.06em; display: block; line-height: 1; }
  #logo .sub  { font-size: 1.1em; letter-spacing: 0.5em; text-transform: uppercase; display: block; margin-top: 0.4em; }
  @keyframes logoAnim {
    0%   { opacity: 1; transform: translate(-50%, -50%) scale(1); }
    100% { opacity: 0; transform: translate(-50%, -50%) scale(0.03); }
  }

  /* ---- CRAWL ---- */
  #crawl-wrap {
    position: absolute;
    inset: 0;
    perspective: 420px;
    overflow: hidden;
    opacity: 0;
    animation: fadeIn 0.8s linear 7.5s forwards;
    z-index: 5;
  }
  @keyframes fadeIn { to { opacity: 1; } }

  #crawl {
    position: absolute;
    width: 58%;
    left: 21%;
    top: 100%;
    text-align: center;
    transform-origin: 50% 100%;
    transform: rotateX(22deg);
    animation: scroll 90s linear 7.5s forwards;
  }
  @keyframes scroll {
    from { top: 100%; }
    to   { top: -400%; }
  }

  .ep-label  { display: block; font-size: 1.7em; letter-spacing: 0.6em; text-align: center; margin-bottom: 0.9em; }
  .ep-title  { font-size: 3.4em; font-weight: 900; letter-spacing: 0.13em; text-align: center; text-transform: uppercase; line-height: 1.2; margin-bottom: 1.8em; }
  .crawl-p   { font-size: 2.0em; line-height: 2.2; margin-bottom: 1.6em; text-align: center; }
  .crawl-end { text-align: center; margin-top: 4em; font-style: italic; font-size: 2.2em; letter-spacing: 0.06em; }

  /* ---- SHARE BUTTON ---- */
  .btn-bar {
    position: fixed;
    bottom: 22px;
    right: 22px;
    z-index: 20;
    display: flex;
    gap: 10px;
    opacity: 0;
    animation: fadeIn 0.5s ease 9s forwards;
  }
  .btn-bar button {
    background: #FFE81F;
    color: #000;
    border: none;
    padding: 11px 22px;
    font-size: 1em;
    font-weight: 700;
    font-family: inherit;
    letter-spacing: 0.05em;
    cursor: pointer;
    border-radius: 3px;
    transition: background 0.15s;
  }
  .btn-bar button:hover { background: #fff9a0; }
</style>
</head>
<body>

<canvas id="stars"></canvas>

<div id="intro">${introText}</div>

<div id="logo">
  <span class="main">⚔️ MAY THE 4TH</span>
  <span class="sub">${logoSub}</span>
</div>

<div id="crawl-wrap">
  <div id="crawl">
    <span class="ep-label">EPISODE ${episode}</span>
    <div class="ep-title">${titleHtml}</div>

    <p class="crawl-p">
      ${repoHtml}
    </p>

    <p class="crawl-p">
      ${statsHtml}
    </p>

    <p class="crawl-p">${p1Text}</p>

    <p class="crawl-p">${p2Text}</p>

    <p class="crawl-p">${p3Text}</p>

    <p class="crawl-end">${endText}</p>
  </div>
</div>

<div class="btn-bar">
  <button onclick="copyShare()">${btnLabel}</button>
</div>

<script>
  const canvas = document.getElementById('stars');
  const ctx = canvas.getContext('2d');
  function resize() {
    canvas.width  = window.innerWidth;
    canvas.height = window.innerHeight;
    drawStars();
  }
  const stars = Array.from({ length: 260 }, () => ({
    x: Math.random(), y: Math.random(),
    r: Math.random() * 1.6 + 0.3,
    o: Math.random() * 0.7 + 0.3
  }));
  function drawStars() {
    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    stars.forEach(s => {
      ctx.beginPath();
      ctx.arc(s.x * canvas.width, s.y * canvas.height, s.r, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(255,255,255,' + s.o + ')';
      ctx.fill();
    });
  }
  resize();
  window.addEventListener('resize', resize);

  const vscode = acquireVsCodeApi();
  function copyShare() {
    vscode.postMessage({ command: 'copy' });
  }

  // Unlock AudioContext on first user gesture (Chromium autoplay policy)
  let _ac = null;
  function getAC() {
    if (!_ac) {
      _ac = new (window.AudioContext || window.webkitAudioContext)();
    }
    return _ac;
  }
  function unlockAudio() {
    try { const ac = getAC(); if (ac.state === 'suspended') ac.resume(); } catch(e) {}
  }
  document.addEventListener('mousemove', unlockAudio, { once: true });
  document.addEventListener('click',     unlockAudio, { once: true });

  function scheduleNotes(ac) {
    const master = ac.createGain();
    master.gain.value = 0.32;
    master.connect(ac.destination);

    const filter = ac.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.value = 2200;
    filter.connect(master);

    function note(freq, t, dur, vol) {
      const osc  = ac.createOscillator();
      const osc2 = ac.createOscillator();
      const g    = ac.createGain();
      osc.type  = 'sawtooth';
      osc2.type = 'sawtooth';
      osc.frequency.value  = freq;
      osc2.frequency.value = freq * 1.004;
      g.gain.setValueAtTime(0, t);
      g.gain.linearRampToValueAtTime(vol, t + 0.05);
      g.gain.setValueAtTime(vol * 0.75, t + dur * 0.35);
      g.gain.linearRampToValueAtTime(0, t + dur);
      osc.connect(g);  osc2.connect(g);  g.connect(filter);
      osc.start(t);  osc.stop(t + dur);
      osc2.start(t); osc2.stop(t + dur);
    }

    const n = ac.currentTime;
    note(392, n + 0.00, 0.30, 0.42);
    note(392, n + 0.28, 0.16, 0.38);
    note(587, n + 0.43, 0.38, 0.46);
    note(784, n + 0.80, 1.30, 0.52);
    note(494, n + 2.20, 0.45, 0.28);
    note(784, n + 2.60, 0.90, 0.32);
  }

  function playFanfare() {
    try {
      const ac = getAC();
      if (ac.state === 'suspended') {
        ac.resume().then(() => scheduleNotes(ac));
      } else {
        scheduleNotes(ac);
      }
    } catch(e) { /* audio not available */ }
  }

  // plays when the crawl fades in (7.5 s after load)
  setTimeout(playFanfare, 7500);
</script>
</body>
</html>`;
}

export function deactivate() {}
