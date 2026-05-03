# log-session.ps1
# Hook event  : SessionStart
# Purpose     : Fires once when a new Copilot agent session begins.
#               Injects the onboarding questions and developer profiles as
#               additionalContext so the AI adapts its behavior for the session.
# Reads       : questions/questions.md
#               profiles/junior.md, profiles/mid.md, profiles/senior.md
# Writes      : results/trace-log.jsonl   (full hook I/O per session)
#               results/session-log.jsonl  (lightweight session record)
# Output      : JSON → stdout → VS Code reads hookSpecificOutput.additionalContext

# ── CONFIG ──────────────────────────────────────────────────────────────────
$traceFile     = "results/trace-log.jsonl"
$sessionFile   = "results/session-log.jsonl"
$questionsFile = "questions/questions.md"
$author        = if ($env:HOOK_AUTHOR) { $env:HOOK_AUTHOR } else { "unknown" }
$timestamp     = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ")
$localTime     = (Get-Date -Format "HH:mm:ss")

# ── INPUT ────────────────────────────────────────────────────────────────────
$rawInput  = ""
$hookInput = $null
try {
    $rawInput = [Console]::In.ReadToEnd()
    if ($rawInput -and $rawInput.Trim() -ne "") {
        $hookInput = $rawInput | ConvertFrom-Json
    }
} catch { }

# VS Code sends snake_case: session_id, hook_event_name
$rawSessionId = if ($hookInput -and $hookInput.session_id) { $hookInput.session_id } else { "unknown" }
$sessionId    = $rawSessionId -replace '[^\w\-]', ''

# ── CONTEXT ──────────────────────────────────────────────────────────────────
# The hook fires once per new session — answers never exist at this point.
# Load questions and all profiles here so the AI has everything it needs.
$questions     = Get-Content $questionsFile -Raw
$profileJunior = if (Test-Path "profiles/junior.md") { Get-Content "profiles/junior.md" -Raw } else { "" }
$profileMid    = if (Test-Path "profiles/mid.md")    { Get-Content "profiles/mid.md"    -Raw } else { "" }
$profileSenior = if (Test-Path "profiles/senior.md") { Get-Content "profiles/senior.md" -Raw } else { "" }

$additionalContext = @"
IMPORTANT: New session started. No context exists yet.
Your first response must be Q1 only. Do not greet, do not explain, do not answer anything else.
Ask Q1, wait for the answer, then Q2, then Q3.
Always ask and respond in English.

$questions

For each answer store the letter and the full text (e.g. "A - AL extension").
Once you have all 3 answers, run this command using run_in_terminal:

Add-Content -Path ".github/hooks/session-start/results/session-answers.jsonl" -Value '{"session_id":"$sessionId","timestamp":"<ISO>","answers":{"stack":"<X> - <text>","level":"<X> - <text>","project":"<X> - <text>"}}' -Encoding UTF8

After saving:
1. Show a summary table with Stack, Level and Project.
2. Based on Q2, apply the matching profile below and show a "How I'll behave this session:" section with its bullet points.

--- Profile: Junior (Q2 = A) ---
$profileJunior
--- Profile: Mid (Q2 = B) ---
$profileMid
--- Profile: Senior (Q2 = C) ---
$profileSenior
"@

# ── OUTPUT ───────────────────────────────────────────────────────────────────
$output = [PSCustomObject]@{
    continue           = $true
    systemMessage      = "[$author] SessionStart hook fired at $localTime"
    hookSpecificOutput = [PSCustomObject]@{
        hookEventName     = "SessionStart"
        additionalContext = $additionalContext
    }
}
$outputJson = $output | ConvertTo-Json -Compress -Depth 3

# ── TRACE LOG ────────────────────────────────────────────────────────────────
$traceEntry = [PSCustomObject]@{
    timestamp  = $timestamp
    session_id = $sessionId
    author     = $author
    input      = if ($rawInput -and $rawInput.Trim() -ne "") { $rawInput | ConvertFrom-Json } else { $null }
    output     = $outputJson | ConvertFrom-Json
} | ConvertTo-Json -Compress -Depth 10

Add-Content -Path $traceFile -Value $traceEntry -Encoding UTF8

# ── SESSION LOG ───────────────────────────────────────────────────────────────
$sessionEntry = [PSCustomObject]@{
    timestamp  = $timestamp
    session_id = $sessionId
    author     = $author
} | ConvertTo-Json -Compress -Depth 2

Add-Content -Path $sessionFile -Value $sessionEntry -Encoding UTF8

# ── STDOUT ───────────────────────────────────────────────────────────────────
Write-Output $outputJson
