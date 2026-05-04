# May the 4th Be With You ⚔️

> *A long time ago, in a repository far, far away...*

A VS Code extension that celebrates **Star Wars Day** (May 4th) by turning your workspace into its own **Opening Crawl** — automatically, every year, without asking anything from you.

![May the 4th Opening Crawl](https://raw.githubusercontent.com/gdrgdev/Blog/main/GDRGDev_May4th/images/crawl-preview.png)

---

## Features

### Opening Crawl — Automatic on Every May 4th

Every year on **May 4th**, the classic yellow-text perspective crawl appears 2 seconds after VS Code starts — no configuration, no popups, no interruptions.

The crawl reads your workspace silently and builds a unique story:

- **Single workspace** — the repository becomes the hero of its own episode
- **Multi-root workspace** — the repositories unite as *The Developer Alliance*, each named in the crawl
- **File counts by language** — top 3 languages detected across all folders
- **Random episode number** — a different episode every time
- **Bilingual** — automatically in Spanish if VS Code is set to Spanish, English otherwise

### Animated Starfield

Stars rendered on canvas behind the crawl. Because every galaxy needs stars.

### Epic Fanfare

A short brass fanfare plays when the crawl appears — synthesized entirely with the Web Audio API, no audio files, no copyright issues.

### Copy Your Crawl

The **⚔️ Copy Crawl** button copies the full crawl text to your clipboard, identical to what you see on screen — ready to share on any platform.

### Available Year-Round

Missed May 4th? Run it any day from the Command Palette:

`Ctrl+Shift+P` → `Show Opening Crawl ⚔️`

---

## How It Works

| Situation | Behavior |
|---|---|
| May 4th, any VS Code launch | Crawl opens automatically after 2 seconds |
| Any other day | Silent. No interruptions. |
| Command palette (any day) | Crawl opens on demand |

---

## Commands

| Command | Description |
|---|---|
| `May the 4th: Show Opening Crawl ⚔️` | Manually trigger the Opening Crawl |

---

## Requirements

- VS Code **1.85.0** or higher
- No other dependencies

---

## Release Notes

### 0.1.0 — May 4th, 2026

- Automatic Opening Crawl on every May 4th startup
- Multi-root workspace support: all folder names appear in the crawl
- Top 3 languages detected across all workspace folders
- Animated starfield background
- Brass fanfare via Web Audio API (no audio files)
- Copy crawl text to clipboard
- Random episode number on each run
- Bilingual: Spanish or English based on VS Code display language

---

## License

[MIT](https://github.com/gdrgdev/Blog/blob/main/GDRGDev_May4th/LICENSE) — Gerardo Rentería

---

## Contributions

Contributions and ideas are welcome. Find the source code on GitHub.

If this extension brightened your May 4th, consider buying me a coffee:

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/gdrenteria)

---

⭐ [Star the repository](https://github.com/gdrgdev/Blog) if you found it useful.

May the 4th be with you. Always. ⚔️
