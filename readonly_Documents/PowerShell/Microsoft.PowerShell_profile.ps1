oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/atomic.omp.json" | Invoke-Expression

# Run Claude Code against the local Ollama model via claude-code-router.
# Disables extended thinking, which the local model doesn't support.
function ccrl {
	$env:MAX_THINKING_TOKENS = "0"
	$env:CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING = "1"
	ccr code @args
}
