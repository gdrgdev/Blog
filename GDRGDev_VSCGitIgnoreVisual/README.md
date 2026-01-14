# GitIgnore Visual ⦻

Instant visual indicators for files and folders ignored by `.gitignore` in VS Code.

## ✨ Features

- **Visual badge**: Ignored files display a distinctive **⦻** indicator
- **Informative tooltips**: Shows which `.gitignore` rule affects each item
- **Multi-workspace**: Supports multiple folders simultaneously
- **Auto-refresh**: Detects `.gitignore` changes in real-time
- **Zero configuration**: Install and it works

## 📖 Usage

The extension activates automatically. Requires a `.gitignore` file in the workspace root.

### Available command

- **GitIgnore Visual: Refresh** (`Ctrl+Shift+P`): Manually refresh decorations

## ⚙️ Configuration

### `gitignoreVisual.badgeIcon`

Customize the icon/emoji shown on ignored items.

- **Default**: `"⦻"`
- **How to change**: `Ctrl+,` → Search "gitignore badge"

**Alternative examples:**
```json
{
  "gitignoreVisual.badgeIcon": "🙈"  // Monkey
}
```

Other professional icons:
- `"∅"` - Empty set
- `"○"` - Empty circle  
- `"⊗"` - Circle with X
- `"◯"` - Large circle
- `"⊝"` - Circle with minus

## 🎯 Ideal for

- Node.js projects (`node_modules/`, `dist/`, `.env`)
- Business Central / AL (`.alpackages/`, `.snapshots/`)
- .NET (`bin/`, `obj/`, `*.user`)
- Any project with `.gitignore`

## 🔧 Development

```bash
git clone https://github.com/gdrgdev/Blog.git
cd Blog/GDRGDev_VSCGitIgnoreVisual
npm install
npm run compile
# Press F5 to debug
```

### Publish updates
```bash
npm run compile
vsce publish patch
```

## 📄 License

MIT License - Gerardo Rentería

## 🤝 Contributions

Contributions welcome! Visit the [source code](https://github.com/gdrgdev/Blog/tree/main/GDRGDev_VSCGitIgnoreVisual) on my blog.

---

⭐ **¿Te resultó útil?** Dale una estrella al [repositorio](https://github.com/gdrgdev/Blog)!
