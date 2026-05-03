# reinject-profile.ps1
# Hook event  : PreCompact
# Purpose     : Fires before VS Code compacts the conversation context.
#               Re-injects the active developer profile so the AI retains
#               its configured behavior after compaction.
# Reads       : results/session-answers.jsonl  (to resolve the session profile)
#               profiles/junior.md | mid.md | senior.md  (active profile)
# Writes      : results/trace-log.jsonl  (PreCompact event record)
# Output      : JSON → stdout → VS Code reads hookSpecificOutput.additionalContext

# ── CONFIG ───────────────────────────────────────────────────────────────────
$answersFile = "results/session-answers.jsonl"
$traceFile   = "results/trace-log.jsonl"

# ── INPUT ────────────────────────────────────────────────────────────────────
$rawInput  = ""
$hookInput = $null
try {
    $rawInput = [Console]::In.ReadToEnd()
    if ($rawInput -and $rawInput.Trim() -ne "") {
        $hookInput = $rawInput | ConvertFrom-Json
    }
} catch { }

$rawSessionId = if ($hookInput -and $hookInput.session_id) { $hookInput.session_id } else { "" }
$sessionId    = $rawSessionId -replace '[^\w\-]', ''
$timestamp    = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ")

# ── FIND SESSION ANSWERS ─────────────────────────────────────────────────────
$answers = $null
if ($sessionId -ne "" -and (Test-Path $answersFile)) {
    Get-Content $answersFile | ForEach-Object {
        try {
            $entry = $_ | ConvertFrom-Json
            if ($entry.session_id -eq $sessionId) {
                $answers = $entry.answers
            }
        } catch { }
    }
}

# ── BUILD CONTEXT ─────────────────────────────────────────────────────────────
if ($null -eq $answers) {
    # Session not found — pass through silently
    $traceEntry = [PSCustomObject]@{
        timestamp       = $timestamp
        hook            = "PreCompact"
        session_id      = $sessionId
        profile_restored = $null
        note            = "session not found in answers — passthrough"
    } | ConvertTo-Json -Compress -Depth 2
    Add-Content -Path $traceFile -Value $traceEntry -Encoding UTF8

    Write-Output '{"continue":true}'
    exit 0
}

# Map level letter to profile file
$levelLetter = if ($answers.level -match '^([A-C])') { $Matches[1] } else { "" }
$profileMap  = @{ "A" = "profiles/junior.md"; "B" = "profiles/mid.md"; "C" = "profiles/senior.md" }
$profileFile = $profileMap[$levelLetter]

$profileContent = ""
if ($profileFile -and (Test-Path $profileFile)) {
    $profileContent = Get-Content $profileFile -Raw
}

$additionalContext = @"
[PreCompact context restore]
Session profile (already answered — do NOT ask again):
- Stack:   $($answers.stack)
- Level:   $($answers.level)
- Project: $($answers.project)

Active developer profile:
$profileContent
"@

# ── OUTPUT ────────────────────────────────────────────────────────────────────
$output = [PSCustomObject]@{
    continue           = $true
    hookSpecificOutput = [PSCustomObject]@{
        hookEventName     = "PreCompact"
        additionalContext = $additionalContext
    }
}

# ── TRACE LOG ─────────────────────────────────────────────────────────────────
$traceEntry = [PSCustomObject]@{
    timestamp        = $timestamp
    hook             = "PreCompact"
    session_id       = $sessionId
    profile_restored = $levelLetter
    stack            = $answers.stack
    level            = $answers.level
    project          = $answers.project
} | ConvertTo-Json -Compress -Depth 2
Add-Content -Path $traceFile -Value $traceEntry -Encoding UTF8

Write-Output ($output | ConvertTo-Json -Compress -Depth 3)
