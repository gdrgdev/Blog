# BC Telemetry Buddy — Extension Lifecycle Events Reference

Reference for the BC Extension Health skill.
Uses **BC Telemetry Buddy MCP** (`mcp_bc-telemetry-_*`) to analyze the 6 most critical lifecycle events for a Business Central extension.

---

## Prerequisites

- BC Telemetry Buddy MCP must be installed and configured with at least one profile (Application Insights connection)
- Azure CLI must be authenticated and set to the **same subscription** where the Application Insights resource lives. Check `.vscode/.bctb-config.json` → `kustoClusterUrl` to identify the correct subscription ID, then run: `az account set --subscription "<subscriptionId>"`
- `extensionId` is taken from `app.json → id` (already extracted in Step 1 of the skill)
- Default time range: **last 30 days** unless the user specifies otherwise

---

## Workflow

### 1. Select the correct profile

Use `mcp_bc-telemetry-_list_profiles` to see available profiles.
If multiple profiles exist, ask the user which client/tenant to analyze, then switch with `mcp_bc-telemetry-_switch_profile`.

```
Tool: mcp_bc-telemetry-_list_profiles

Tool: mcp_bc-telemetry-_switch_profile
Parameters:
  profileName: <selected profile>
```

---

### 2. Resolve tenant mapping (optional but recommended)

Use `mcp_bc-telemetry-_get_tenant_mapping` to resolve company names to `aadTenantId`.
This ensures filtering is done by tenant GUID, not by company name string (more reliable).

```
Tool: mcp_bc-telemetry-_get_tenant_mapping
```

---

### 3. Verify event IDs exist in the data

Use `mcp_bc-telemetry-_get_event_catalog` to confirm which of the 6 monitored events are actually present in the Application Insights data for this profile.

```
Tool: mcp_bc-telemetry-_get_event_catalog
```

Only query events that appear in the catalog. Skip those with no data and note them as `— (no data)` in the output.

---

### 4. Query telemetry — single broad query

Use `mcp_bc-telemetry-_query_telemetry` with a **single query** to retrieve counts for all monitored events at once. This is more efficient than one query per event.

**Summary query (run first):**
```kql
traces
| where timestamp > ago(30d)
| where tostring(customDimensions.extensionId) == '<id from app.json>'
| where customDimensions.eventId in ('LC0010', 'LC0011', 'LC0016', 'LC0017', 'LC0022', 'LC0023')
| summarize count() by eventId = tostring(customDimensions.eventId), environmentName = tostring(customDimensions.environmentName), result = tostring(customDimensions.result)
| order by eventId asc
```

**Detail query (run only if failure events are found):**
```kql
traces
| where timestamp > ago(30d)
| where tostring(customDimensions.extensionId) == '<id from app.json>'
| where customDimensions.eventId in ('LC0011', 'LC0017', 'LC0023')
| project timestamp, eventId = tostring(customDimensions.eventId), environmentName = tostring(customDimensions.environmentName), failureReason = tostring(customDimensions.failureReason)
| order by timestamp desc
```

The per-event KQL templates in the **Monitored Event Catalog** below remain available as drill-down queries for deeper investigation.

```
Tool: mcp_bc-telemetry-_query_telemetry
Parameters:
  query: <summary query above, with extensionId filled in>
```

---

### 5. Save useful queries

If a query proves valuable, persist it for future reuse:

```
Tool: mcp_bc-telemetry-_save_query
Parameters:
  name: bc-extension-health-<eventId>
  query: <KQL used>
```

---

## Monitored Event Catalog

### Event 1 — LC0010 · Extension installed successfully

| Field | Value |
|---|---|
| Category | Extension Lifecycle |
| Signal | Extension was installed successfully in an environment |
| Why monitor | Confirms successful deployments |
| Severity | Informational |

**KQL template:**
```kql
traces
| where timestamp > ago(30d)
| where customDimensions has 'LC0010'
| where customDimensions.eventId == 'LC0010'
| where tostring(customDimensions.extensionId) == '<id from app.json>'
| summarize count() by tostring(customDimensions.environmentName), bin(timestamp, 1d)
| order by timestamp desc
```

**Action:** No action needed if count is as expected. Cross-reference with the YAMPI version table.

---

### Event 2 — LC0011 · Extension failed to install

| Field | Value |
|---|---|
| Category | Extension Lifecycle |
| Signal | Extension installation failed |
| Why monitor | Critical failure — extension not available to users |
| Severity | 🚨 Critical |

**KQL template:**
```kql
traces
| where timestamp > ago(30d)
| where customDimensions has 'LC0011'
| where customDimensions.eventId == 'LC0011'
| where tostring(customDimensions.extensionId) == '<id from app.json>'
| project timestamp, environmentName = tostring(customDimensions.environmentName), failureReason = tostring(customDimensions.failureReason)
| order by timestamp desc
```

**Action:** Investigate `failureReason`. Check for dependency conflicts or schema issues.

---

### Event 3 — LC0022 · Extension updated successfully

| Field | Value |
|---|---|
| Category | Extension Lifecycle |
| Signal | Extension was updated to a new version |
| Why monitor | Confirms update deployments completed without errors |
| Severity | Informational |

**KQL template:**
```kql
traces
| where timestamp > ago(30d)
| where customDimensions has 'LC0022'
| where customDimensions.eventId == 'LC0022'
| where tostring(customDimensions.extensionId) == '<id from app.json>'
| summarize count() by extensionVersion = tostring(customDimensions.extensionVersion), environmentName = tostring(customDimensions.environmentName)
| order by extensionVersion desc
```

**Action:** Verify versions match the YAMPI deployment table.

---

### Event 4 — LC0023 · Extension failed to update

| Field | Value |
|---|---|
| Category | Extension Lifecycle |
| Signal | Extension update failed |
| Why monitor | Critical failure — environment may be running an outdated version |
| Severity | 🚨 Critical |

**KQL template:**
```kql
traces
| where timestamp > ago(30d)
| where customDimensions has 'LC0023'
| where customDimensions.eventId == 'LC0023'
| where tostring(customDimensions.extensionId) == '<id from app.json>'
| project timestamp
    , environmentName = tostring(customDimensions.environmentName)
    , extensionVersion = tostring(customDimensions.extensionVersion)
    , failureReason = tostring(customDimensions.failureReason)
| order by timestamp desc
```

**Action:** Review `failureReason`. Common causes: breaking schema changes, missing upgrade codeunit, data migration errors.

---

### Event 5 — LC0016 · Extension un-installed successfully

| Field | Value |
|---|---|
| Category | Extension Lifecycle |
| Signal | Extension was uninstalled from an environment |
| Why monitor | Detects intentional or unexpected removals |
| Severity | Informational |

**KQL template:**
```kql
traces
| where timestamp > ago(30d)
| where customDimensions has 'LC0016'
| where customDimensions.eventId == 'LC0016'
| where tostring(customDimensions.extensionId) == '<id from app.json>'
| project timestamp, environmentName = tostring(customDimensions.environmentName), extensionVersion = tostring(customDimensions.extensionVersion)
| order by timestamp desc
```

**Action:** If unexpected, check whether the uninstall was deliberate. Correlate with YAMPI — the extension should no longer appear in that environment.

---

### Event 6 — LC0017 · Extension failed to un-install

| Field | Value |
|---|---|
| Category | Extension Lifecycle |
| Signal | Extension uninstallation failed |
| Why monitor | Indicates a blocked removal (e.g., dependent extensions or data conflicts) |
| Severity | 🚨 Critical |

**KQL template:**
```kql
traces
| where timestamp > ago(30d)
| where customDimensions has 'LC0017'
| where customDimensions.eventId == 'LC0017'
| where tostring(customDimensions.extensionId) == '<id from app.json>'
| project timestamp, environmentName = tostring(customDimensions.environmentName), failureReason = tostring(customDimensions.failureReason)
| order by timestamp desc
```

**Action:** Investigate `failureReason`. Common causes: dependent extensions still installed, data deletion conflicts.

---

## Status Logic

| Condition | Status |
|---|---|
| 0 occurrences of failure events (LC0011, LC0017, LC0023) | 🟢 |
| 1+ occurrences of any failure event | 🚨 |
| Only success events present | 🟢 |
| Event not present in catalog (no data) | ➖ |

---

## Output Table

```markdown
| Event ID | Description                        | Occurrences (30d) | Status |
|----------|------------------------------------|-------------------|--------|
| LC0010   | Extension installed successfully   | 2                 | 🟢     |
| LC0011   | Extension failed to install        | 0                 | 🟢     |
| LC0016   | Extension un-installed successfully | 0                 | 🟢     |
| LC0017   | Extension failed to un-install      | 0                 | 🟢     |
| LC0022   | Extension updated successfully      | 3                 | 🟢     |
| LC0023   | Extension failed to update          | 1                 | 🚨     |
```

---

## Fallback

If `mcp_bc-telemetry-_*` tools are unavailable or return an error:
- Inform the user: *"BC Telemetry Buddy MCP is not available. Skipping telemetry analysis."*  
- Continue with or present only the YAMPI section
- Do not block the full report
