---
name: bc-extension-health
description: "Analyze the health of the current Business Central extension across all client environments. Combines YAMPI (d365bc-admin MCP) for environment and version data, and BC Telemetry Buddy for lifecycle event analysis. USE FOR: extension health check, check extension in production, how is my extension deployed, extension version across environments, extension telemetry analysis, extension install failures, extension update errors, analiza mi extensión, cómo está mi extensión en producción. DO NOT USE FOR: writing AL code (use default), creating environments (use d365bc-admin directly), general BC telemetry not related to the current extension."
---

# BC Extension Health

> **AUTHORITATIVE GUIDANCE — MANDATORY COMPLIANCE**
>
> This skill orchestrates YAMPI (d365bc-admin MCP) and BC Telemetry Buddy to produce a unified health report for the extension currently open in the workspace.

## Requirements

This skill depends on two MCP servers. Each section degrades gracefully if the MCP is not available, but full functionality requires both.

| MCP | Purpose | Install |
|---|---|---|
| **YAMPI** — `@demiliani/d365bc-admin-mcp` | Environment list, installed app versions, available updates | `npm install -g @demiliani/d365bc-admin-mcp` — [docs](https://www.demiliani.com/2025/01/14/a-model-context-protocol-server-for-business-central-administration/) |
| **BC Telemetry Buddy** | Lifecycle telemetry via Application Insights (no KQL needed) | Available via VS Code MCP marketplace — [docs](https://www.waldo.be/2025/04/bc-telemetry-buddy-mcp/) |

After installing, register each server in your VS Code `mcp.json` (File → Preferences → MCP Servers).

## Triggers

Activate this skill when the user asks to:
- Check how their extension is deployed across environments
- Verify which version is installed in production vs sandbox
- Detect installation or update failures for their extension
- Analyze telemetry events related to their extension
- Get a health summary of their extension
- Phrases: "extension health", "cómo está mi extensión", "analiza mi extensión", "check my extension in production", "extension version matrix"

## Rules

1. Always read `app.json` first — the `id`, `name`, `publisher`, and `version` fields are mandatory context for all subsequent steps
2. Run the YAMPI and Buddy analyses in order: environments first, then telemetry
3. Filter all queries strictly by the extension `id` from `app.json` — never by name alone (names can collide across publishers)
4. Present both results as Markdown tables in a single unified report
5. If YAMPI or Buddy MCP is not available, inform the user and skip that section — do not fail the entire report

## Orchestration Flow

### Step 1 — Read workspace extension context
Read `app.json` from the workspace root and extract:
- `id` → used as `extensionId` / `appId` filter in all queries
- `name` → display label
- `publisher` → display label
- `version` → current local version (baseline for comparison)

### Step 2 — Environment & version analysis (YAMPI)
Follow the full workflow in [yampi-environments-reference.md](yampi-environments-reference.md).

Output: Markdown table showing each environment, installed version, update availability, and status emoji.

### Step 3 — Telemetry lifecycle analysis (BC Telemetry Buddy)
Follow the full workflow in [buddy-telemetry-reference.md](buddy-telemetry-reference.md).

Output: Markdown table showing event ID, description, occurrences in the last 30 days, and status emoji.

### Step 4 — Unified report
Present both tables under a single header:

```
## Extension Health Report: {name} by {publisher}
### Local version: {version}  |  App ID: {id}

### 🌍 Environments (via YAMPI)
<table from Step 2>

### 📊 Telemetry Events — last 30 days (via BC Telemetry Buddy)
<table from Step 3>
```

## References

- [YAMPI environment workflow](yampi-environments-reference.md)
- [Buddy — Telemetry events reference](buddy-telemetry-reference.md)
