# YAMPI — Environment & Version Analysis

Reference for the BC Extension Health skill.
Uses the **d365bc-admin MCP** (YAMPI) to discover all active environments for a tenant and check the installed version of the current extension in each one.

---

## Prerequisites

- YAMPI MCP (`d365bc-admin`) must be installed and authenticated
- `tenantId` must be provided by the user (Microsoft Entra tenant GUID)
- `appId` is taken from `app.json → id` (already extracted in Step 1 of the skill)

---

## Workflow

### 1. Get all active environments

Use `mcp_d365bc-admin_get_environment_informations` to retrieve all environments for the tenant.

```
Tool: mcp_d365bc-admin_get_environment_informations
Parameters:
  tenantId: <tenantId provided by user>
```

From the response, collect: `environmentName`, `type` (Production / Sandbox), `status`.
Filter: only environments with `status == Active`.

---

### 2. Get installed apps per environment

For each active environment, call `mcp_d365bc-admin_get_installed_apps`.

```
Tool: mcp_d365bc-admin_get_installed_apps
Parameters:
  tenantId: <tenantId>
  environmentName: <environmentName>
```

Filter the result by `appId == <id from app.json>`.
Capture `version` and `appType` (possible values: `dev`, `perTenant`, `AppSource`).
If the app is not found in an environment, record it as `— (not installed)`.

---

### 3. Check for available updates

For each environment where the extension is installed, call `mcp_d365bc-admin_get_available_app_updates`.

```
Tool: mcp_d365bc-admin_get_available_app_updates
Parameters:
  tenantId: <tenantId>
  environmentName: <environmentName>
```

Filter by `appId == <id from app.json>`.
If an update is available, capture `availableVersion`.

---

## Status Logic

| Condition | Status |
|---|---|
| Installed, version matches local `app.json` version, no update pending | 🟢 |
| Installed, version differs from local `app.json` version | ⚠️ |
| Installed, update available | ⚠️ |
| Installed, `appType = dev` (developer deployment, not via Admin Center) | ⚠️ |
| Not installed in this environment | ➖ |

---

## Output Table

Present results as a Markdown table using the columns below.
Environment names, count, and versions are **fully dynamic** — populated from YAMPI's response at runtime.

**Example output** *(names and versions will vary per tenant)*:

```markdown
| Environment      | Type       | Installed Version | Available Update | App Type  | Status |
|------------------|------------|-------------------|------------------|-----------|--------|
| Production       | Production | 1.0.0.0           | —                | perTenant | 🟢     |
| Sandbox-UAT      | Sandbox    | 1.0.0.0           | —                | perTenant | 🟢     |
| Sandbox-Dev      | Sandbox    | 0.9.8.0           | 1.0.0.0          | dev       | ⚠️     |
| Sandbox-Old      | Sandbox    | —                 | —                | —         | ➖     |
```

> Never hardcode environment names. Always use the list returned by `mcp_d365bc-admin_get_environment_informations`.

---

## Fallback

If `mcp_d365bc-admin_*` tools are unavailable or return an error:
- Inform the user: *"YAMPI MCP (d365bc-admin) is not available. Skipping environment analysis."*
- Continue with the telemetry section
- Do not block the full report
