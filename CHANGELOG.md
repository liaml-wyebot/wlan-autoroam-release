# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.4] - 2025-10-26

### Added
- **LLM Context Awareness**: AI assistant now always knows which run is displayed in UI
  - Injected via user message: `[Currently viewing: run_name]`
  - Eliminates "this result" ambiguity in follow-up questions
  - No HTTP calls - uses Flask global `_current_ui_loaded_run` directly
  - Cache-friendly design: system message stays constant, UI context in user message
- **OpenAI Prompt Caching**: Optimized for cost savings with automatic caching
  - System message always cached after first call (≥1024 tokens)
  - Conversation history fully cacheable (prefix-matching)
  - Achieved 91-96% cache hit rates on follow-up questions in testing
  - 50% cost reduction on cached tokens
- **SSL Error Suppression**: Clean terminal logs with harmless browser disconnect errors filtered
  - Suppresses ssl.SSLError, BrokenPipeError, ConnectionResetError
  - Applied to werkzeug and root loggers via custom filter

### Changed
- **MCP Tool Consolidation**: Reduced from 13 tools → 8 tools via unification
  - **Removed**: `list_saved_runs()` → use `list_runs(saved_only=True)`
  - **Removed**: `list_runs_by_ssid()` → use `list_runs(ssid="...")`
  - **Removed**: `get_latest_summary()` → use `list_runs()[0]` + `get_current_roam_data()`
  - **Removed**: `notify_ui_load_results()` → automatic side effect in `get_current_roam_data()`
  - **Removed**: `analyze_with_ai()` → legacy tool, LLM orchestration moved to client
  - All functionality preserved, simpler API surface, less cognitive load for LLMs
- **Mobility Score Redesign**: 5-tier system using full 0-100 range (not academic grading)
  - **86-100**: Excellent (●●●●●) - Purple
  - **71-85**: Good (●●●●○) - Green
  - **51-70**: Fair (●●●○○) - Gray
  - **21-50**: Poor (●●○○○) - Yellow
  - **0-20**: Awful (●○○○○) - Red
  - Previous academic grading (90/80/70/60 breakpoints) was misleading
  - 59% showed as "F" but represents Fair performance
  - New breakpoints better reflect actual network quality
- **Tier Indicators**: Switched from ASCII bars to Unicode dots
  - Filled dots (●) in tier color, unfilled dots (○) dimmed to 25% opacity
  - All same size for perfect alignment (previous bars/squares had sizing issues)
  - Clean, minimal visual design
- **Architecture Refactor**: Centralized streaming logic in `mcp_client.py`
  - Eliminated 250+ lines of duplicate code from `app.py`
  - New `chat_stream()` generator handles SSE streaming with tool execution
  - `/api/chat_stream` endpoint simplified to ~100 lines (was ~350)
  - Clean separation: app.py = HTTP transport, mcp_client = orchestration

### Fixed
- **Cache Performance Tracking**: Suppress misleading cache logs for OpenRouter
  - OpenRouter doesn't expose cache stats in API (though caching works)
  - Grok has 90% cache discount but stats not visible
  - Validated cache functionality with OpenAI (confirmed 91-96% hit rates)

## [1.1.3] - 2025-10-26

### Added
- **Fuzzy Matching for run_dir**: Backend safety net recovers from LLM hallucinations
  - Catches SSID typos with 80% similarity matching (e.g., "WPA3-SAE-Testt" → "WPA3-SAE-Test")
  - Catches date hallucinations via exact SSID matching (e.g., "2025-02-30" → "2025-10-26")
  - Returns helpful 404 suggestion: "Did you mean 'X'?"
  - MCP tools surface suggestions as ValueError instead of generic HTTPError
  - Confidence scores prevent false positives (0.6 threshold)
- **Auto-Synced Mobility Scores**: UI now uses `data.run_dir` instead of dropdown value
  - Mobility score always matches currently displayed run
  - Fixes desync when LLM loads results via `notify_ui_load_results()`
- **Complete OpenAPI Documentation**: All MCP-used and user-facing endpoints now documented
  - `/api/list_runs` - Primary run listing endpoint with filtering
  - `/api/compare_runs` - Multi-run comparison with mobility scores
  - `/api/analyze_with_ai` - AI-powered roam analysis
  - `/api/chat_followup` - Context-aware chat
  - `/api/chat_followup_agentic` - Tool-calling enabled chat
  - Marked `/api/list_saved_runs` as deprecated
- **Bundled LICENSE**: Legal terms now included in binary for stronger legal protection

### Fixed
- **LICENSE Wording**: Synced with release repo for improved legal clarity
  - Added "prior" to "written permission"
  - Added "EXPRESS OR IMPLIED" to warranty disclaimer
- **Input Validation**: Enhanced MCP tool robustness for local LLMs (Qwen, etc.)
  - `compare_roam_runs()`: Type-check run_dirs before join() to prevent TypeError
  - `list_runs()`: Validate limit >= 0 to prevent silent negative value ignore
  - `save_results()`: Wrap 404 errors with helpful recovery hints
  - All error messages include actionable guidance (e.g., "Use list_runs() to see available runs")
  - Discovered via Haiku 4.5 stress testing

### Changed
- **Simplified Prompt Guidance**: Reduced verbose run_dir warning to single clear rule
  - "Extract run_dir from list_runs() output - never construct it yourself"
  - Fuzzy matcher remains invisible backend safety net

## [1.1.2] - 2025-10-25

### Added
- **Smart Log Tailing**: `download_log()` MCP tool with intelligent size presets to prevent context overflow
  - `size="quick"` (50 lines) - Default, safe for most analysis
  - `size="normal"` (200 lines) - More context for complex issues
  - `size="full"` - Complete log with warnings (can be 100KB+)
  - Tool returns recommendations for escalation ("call again with size='normal'")
  - Logs always end at disconnect, so tail-based approach captures critical failure context
- **UI State Synchronization**: `/api/set_ui_loaded_run` POST endpoint
  - Called automatically by `renderCycleSummary()` to sync backend with displayed run
  - Fixes bug where `get_ui_loaded_run()` returned stale/incorrect run_dir
  - Backend now always knows which run user is viewing
- **Deauth/Disassoc Reason Code Capture**: Universal regex pattern captures all disconnect events
  - Pattern: `r"\* reason \d+ \([A-Z0-9_]+\)"` works with any WiFi interface name
  - Smart phase assignment based on timestamp matching
  - Reason codes appear in correct phase chronologically
- **Chronological Error Log Sorting**: Phase errors now sorted earliest-to-latest
  - Errors appear in UI in the order they occurred
  - Makes failure timeline analysis easier
- **Proactive LLM Behavior Guidance**: Enhanced prompt engineering for autonomous helpful behavior
  - Encourages quick log scans for vague error codes (status 1, reason 0)
  - Suggests mobility score calculation when analyzing test results
  - Recommends saving runs with good descriptive notes
  - Example workflows demonstrate proactive tool usage

### Fixed
- **CRITICAL**: Mobility Score RF Health - Fixed field name bug `"frequency"` → `"freq"`
  - Was always None, causing RF health to score perfect 20/20 regardless of channel width
  - Now properly penalizes 80 MHz channels and 2.4 GHz overlap
- **Mobility Score QBSS Field**: Fixed field name `qbss_load_pct` → `qbss_util_prct`
- **Mobility Score Channel Width**: Added regex parsing for string format "80 MHz" → integer 80
- **Mobility Score 2.4 GHz Overlap**: Fixed detection logic (only channels 1/6/11 non-overlapping)
- **Mobility Score Duplicate Code**: Removed duplicate QBSS penalty calculation
- **Prompt Engineering f-string**: Fixed syntax error with escaped curly braces (was crashing chat)
- **MCP Tool Decorator**: Removed duplicate `@mcp.tool()` on `download_log()` function
- **UI State Tracking**: Fixed `get_ui_loaded_run()` returning most recent run instead of displayed run

### Changed
- **Prompt Engineering Cleanup**: Reduced from 478 lines → 317 lines (34% reduction)
  - Consolidated 7 verbose rules into 4 concise categories
  - Merged duplicate proactive behavior guidance
  - Created quick-reference tool listing
  - Simplified workflow examples with standard patterns
- **Log Analysis Messaging**: Changed from discouraging ("use sparingly") to encouraging
  - "Log Analysis (smart tailing - safe to use!)" instead of "Logs (use sparingly)"
  - Emphasized 50-line quick scans are lightweight and helpful
  - LLM can now confidently offer/perform log analysis without hesitation
- **Proactive Log Scans**: LLM encouraged to scan logs for unusual failures
  - Can either offer: "I can check the logs..." or just do it: "Checking logs... I see..."
  - Workflow: Start with quick → escalate to normal → only use full if necessary

### Technical
- Added `import re` to mobility_score.py for channel width regex parsing
- Enhanced `_assign_deauth_to_phase()` with timestamp-based phase matching
- Added `_extract_timestamp()` helper for log line timestamp parsing
- Improved error log sorting via simple string sort (chronological by nature)
- Updated OpenAPI spec to v1.1.2 with new endpoints documented

## [1.1.1] - 2025-10-25

### Fixed
- **Dependency Pinning**: Pin `fastmcp` to `2.12.5` to avoid breaking OAuth dependencies introduced in `2.13.0`
  - Version 2.13+ added OAuth support with hard dependencies on `diskcache` and `py-key-value-aio`
  - These dependencies are not needed for wlan-autoroam's use case
  - Prevents future breaking changes from upstream fastmcp updates
- **Early Sudo Check**: Add root privilege check at top of `start_autoroam_ui.py`
  - Shows clean error message when run without sudo
  - Prevents cryptic PyInstaller PKG extraction errors
- **Installer Binary Naming**: Fix installer script to match GitHub release artifact names
  - Changed from `wlan-autoroam-linux-{arch}` to `wlan-autoroam-{arch}`
  - One-line installer now works correctly with GitHub releases

### Changed
- **README Cleanup**: Remove broken QUICKSTART.md reference and elevate REST API section

## [1.1.0] - 2025-10-25

### Added
- **UI State Tracking**: New `/api/get_ui_loaded_run` endpoint returns currently loaded run directory
  - Enables AI to understand which test results user is viewing
  - MCP tool `get_ui_loaded_run()` queries this endpoint for context-aware responses
- **Improved Tool Guidance**: Enhanced system prompt with "AVAILABLE TOOLS" section
  - Documents when to use each MCP tool with workflow examples
  - Marks deprecated tools (`get_latest_summary`, `get_latest_run_dir`) with preferred alternatives
  - Guides AI to use `get_ui_loaded_run()` → `get_current_roam_data()` workflow

### Fixed
- **Mobility Scoring**: Technology scoring now correctly uses `phy_types` field from candidate data
  - Fixes WiFi 6/6E/7 generation detection
  - Improves WPA3 Enterprise detection (SHA-256 in auth suite)
  - UI tooltip now displays actual `security_tier` from scoring instead of hardcoded labels

### Changed
- **OpenAPI Spec**: Updated to version 1.1.0 with new `/api/get_ui_loaded_run` endpoint documentation


## [1.0.2] - 2025-10-25

### Added
- **MAJOR**: `/api/chat_stream` SSE streaming endpoint with real-time tool execution progress
  - Streams tool start/progress/completion events as they happen
  - Shows "thinking..." animation while waiting for LLM responses
  - Eliminates timeout anxiety for long-running operations
  - Event types: `tool_start`, `tool_progress`, `tool_complete`, `llm_token`, `complete`, `error`
- **Tool Progress Streaming**: `execute_tool_with_progress()` method in MCPClient for real-time updates
  - Special handling for `start_roam` tool to stream progress events from `/api/start_roam_stream`
  - Intelligent progress filtering with `_format_roam_progress()` - converts raw CLI output to polished chat messages
  - Emoji indicators for different progress stages (🔍 scanning, 🔄 testing, ✓ complete)
- **Thinking Animation**: Dynamic "thinking..." indicator in chat UI
  - Shows when waiting for LLM response after tool completion
  - Hides during active tool execution
  - Tracks `toolsInProgress` counter for proper state management
- **Analyze Button Streaming**: Refactored to use `sendMessage()` for consistent streaming UX
  - Shows user the actual prompt being sent (educational)
  - Displays tool execution progress in real-time
  - No more blocking spinner - uses streaming architecture
- **UI Auto-Refresh Events**: `broadcast_ui_event('load_results')` after roam completion and save
  - Automatically loads new results in UI when roam completes via chat
  - Shows notes immediately after saving results
  - Replaced `refresh_dropdown` with more comprehensive `load_results` event
- **Swagger/OpenAPI UI**: Fixed implementation with proper Flask-CORS and template rendering
  - Interactive API documentation at `/api/docs`
  - "Try it out" functionality works from any IP/hostname
  - No servers specified in OpenAPI spec to avoid certificate errors
- Comprehensive user-friendly error messages for all HTTP status codes (400, 401, 403, 404, 405, 429, 500+)
- `docs/TIMEOUTS.md` - Comprehensive timeout documentation with rationale and testing guidance
- Early AI config validation in `/api/chat_stream` before attempting API calls
- Mobility score display in chat with thin vertical bar separator (`B+ │ 87.6`)
  - Grade and score in dynamic color based on performance
  - Separator in muted color for visual hierarchy

### Changed
- **CRITICAL**: Extended MCPClient timeout from 180s to 600s (10 minutes) to support long roam tests (200s+ cycles)
- **CRITICAL**: Fixed FastMCP HTTP_OPTS timeout from 30s to 600s - would have killed any chat-initiated roam test >30s
- **Chat Architecture**: Unified streaming workflow for both UI and programmatic access
  - All chat interactions now use SSE streaming by default
  - Old blocking `/api/chat` endpoint remains for backward compatibility
  - Tool execution progress visible in real-time instead of black-box waiting
- **Tool Documentation**: Updated `start_roam()` to accurately reflect blocking + streaming behavior
  - Removed outdated background/polling pattern references
  - Documents that progress is automatically streamed to UI
  - Example shows blocking call that returns complete results
- **Frontend SSE Handling**: Improved error event processing
  - Error events now properly throw and display in UI
  - Re-throw mechanism distinguishes parse errors from intentional error events
  - Thinking animation properly cleans up on errors
- **Token Streaming**: Simplified LLM response handling
  - Token-by-token streaming doesn't work with tool calls (API limitation)
  - Send full response as single event instead
  - Thinking animation provides visual feedback during generation
- Updated OpenAPI spec to v1.0.2 with comprehensive `/api/chat_stream` documentation
  - Added SSE event format examples
  - Documented all event types with sample payloads
  - Updated architecture description to reflect streaming improvements

### Fixed
- Error messages now properly display in chat UI instead of only appearing in console logs
  - Fixed inner try-catch that was swallowing error events
  - Error events checked before entering switch statement
  - Proper error re-throwing for UI display
- Thinking animation now properly hides when errors occur
  - Uses querySelectorAll to find and remove all thinking indicators
  - Handles both dynamic and initial thinking indicators
- Early validation check for missing/empty AI configuration prevents cryptic 401 errors
  - Checks for empty strings and whitespace-only API keys
  - Returns friendly "AI settings not configured" message before attempting API call
- Fixed JavaScript scope error in error handler (`hideThinking` not accessible in outer catch)
- UI refresh after save_results now shows notes immediately
  - Changed from dropdown-only refresh to full results reload
  - Ensures notes display is updated with saved content
- Analyze button now uses streaming endpoint instead of old blocking API
  - Removed loading spinner class manipulation
  - Consistent UX with chat interface
  - Shows real-time progress during analysis

### Removed
- Deprecated `check_roam_progress()` MCP tool (legacy polling pattern, no longer needed)
- Token streaming code from `/api/chat_stream` (doesn't work with tool calls)
  - Simplified to send full LLM response as single event
  - Updated docstrings to explain API limitation
- Old blocking spinner animation from Analyze button
- Outdated background/polling workflow references from documentation and tool docstrings

### Documentation
- Updated `start_roam()` MCP tool documentation to accurately reflect blocking + streaming behavior
- Added comprehensive timeout matrix in `TIMEOUTS.md` explaining all timeout values and their rationale
- Documented best practices for timeout configuration and testing
- Added SSE event type examples to OpenAPI spec for `/api/chat_stream`

## [1.0.0] - 2025-10-23

### Changed
- **BREAKING**: `/api/start_roam` now blocks until completion and returns full results (previously returned immediately)
- Replaced all polling architecture with Server-Sent Events (SSE) for real-time updates
- Simplified MCP workflow - `start_roam()` now auto-broadcasts UI updates
- Overhauled prompt engineering rules to remove confusing MANDATORY language
- Simplified path handling - backend now accepts both full paths and basenames

### Added
- `/api/start_roam_stream` endpoint for SSE-based streaming (preferred for UI)
- `/api/ui_events` SSE endpoint for push notifications to connected clients
- `/api/notify_ui` endpoint for MCP tools to push notifications
- `/api/mobility_score` endpoint for mobility scoring
- `/api/user_prefs` endpoint for user preferences
- `/api/chat` MCP-based chat endpoint
- `/api/ai_settings` GET/POST endpoints for LLM configuration
- `/api/ai_test` endpoint for LLM health checks
- `broadcast_ui_event()` function for SSE push notifications
- Interface validation in `/api/start_roam` (validates with `iw dev`)

### Removed
- `wait_for_roam_completion()` MCP tool (polling-based, no longer needed)
- UI notification polling (replaced with SSE push)
- `roam_done.flag` file mechanism
- Deprecated `/server/{filename}` endpoint

### Fixed
- `user_prefs.json` now saved in correct location (user's home directory)
- Fixed double-nested `runs/runs/` directory bug
- Corrected all MCP tool docstrings to reflect new blocking workflow

### Documentation
- Updated `docs/MCP_EXPLAINER.md` with new single-call workflow
- Updated `docs/openapi.yaml` to v1.1.0 with all new endpoints
- Added architecture notes explaining polling elimination

## [1.0.0] - 2025-10-14

### Added
- Initial release
- Web UI for WiFi roaming tests
- CLI tool for automated roaming
- MCP server integration
- Basic API endpoints
- Roam analysis and visualization
