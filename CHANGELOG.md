# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2025-10-25

### Added
- **One-line installer script** - `curl | sudo bash` for automatic platform detection and installation
- **Comprehensive mobility scoring system** - 6 categories (Infrastructure, Consistency, RF Health, Technology, Security, Performance)
- **Warning system** - 26 unique category-specific warnings with UI display
- **LLM-UI state synchronization** - `/api/get_ui_loaded_run` endpoint and `get_ui_loaded_run()` MCP tool
- **Performance multiplier** - 0.0-1.0 scalar applied to base score (prevents hiding config issues with good performance)
- **Normalized percentage-based penalties** - Prevents large deployment bias in scoring
- **Warnings UI box** - Scrollable display above metrics with category-specific diagnostics
- **System-wide installation** - Installer puts binary in `/usr/local/bin` (no `./` prefix needed)
- **Auto-update support** - Re-run installer to upgrade to latest version
- **Internal whitepaper** - Complete mobility scoring documentation with formulas (source repo only)
- **Public whitepaper** - Sanitized version for public consumption

### Changed
- **Mobility scoring algorithm** - Reworked to use weighted categories with normalized penalties
- **Consistency priorities** - Security (6pts) > Width (6pts) > Protocol (5pts) > Rate (3pts)
- **Technology scoring** - Now uses `phy_types` field from candidate data (matches AP table)
- **Technology tooltip** - Shows actual `security_tier` instead of hardcoded "WPA2/older"
- **Scoring output** - Rounded to 1 decimal place for clean display
- **Deprecated tools** - Marked `get_latest_summary()` and `get_latest_run_dir()` as deprecated
- **Recommended workflow** - Updated to `get_ui_loaded_run()` + `list_runs_by_ssid()` pattern
- **System prompt** - Added comprehensive AVAILABLE TOOLS reference section

### Fixed
- Technology scoring bug where SHA-256/SHA-384 detection would fail
- F-string format error in system prompt (curly braces in JSON examples)
- Technology tooltip showing wrong security tier information
- Warning deduplication - each warning now appears in only one category

### Documentation
- Updated OpenAPI spec to v1.1.0
- Added `/api/get_ui_loaded_run` endpoint documentation
- Created MOBILITY_SCORE.md with v1.1.0 scoring system
- Added installer README and usage documentation
- Updated MCP tool documentation with new workflow patterns

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
