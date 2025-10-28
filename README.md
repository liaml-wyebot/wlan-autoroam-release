# wlan-autoroam

Automated Wi-Fi roaming testing and analysis with an agentic AI assistant. Validate mobility performance, visualize results, or just hang out with RoamBot. 
> [!IMPORTANT]
> **AI Features Require Your Own API Key**: RoamBot needs an LLM provider (OpenAI, Anthropic, OpenRouter, or local Ollama/LM Studio). Basic roaming tests work without AI. See the [AI analysis section](#ai-analysis-roambot) for configuration.

<img width="1249" height="1342" alt="localhost_8443_ (2)-crop" src="https://github.com/user-attachments/assets/2a416268-d989-4c9e-85f6-e2291d7630a7" />



## Features

* **🤖 Agentic AI Assistant (RoamBot)** - Natural language interface for roaming analysis. Ask questions, run tests, compare results, and get insights—AI autonomously uses tools to analyze your data (supports OpenAI, Anthropic, OpenRouter, or local LLMs)
* **Automated Roaming Tests** - Uses native Linux tools (`iw`, `wpa_cli`) to perform round-robin roam tests across APs in your area with detailed phase timing
* **Phase Timing Breakout** - Measures auth, reassoc, EAP, and 4-way handshake duration from the client perspective
* **Mobility Score** - Single metric for roaming readiness based on security, WiFi generation, and capabilities ([learn more](MOBILITY_SCORE.md))
* **Failed Roam Diagnostics** - Auto-saves log snippets with detailed error context for troubleshooting
* **Interactive Web UI** - Real-time test execution, result management, and multi-run comparison
* **REST API** - Programmatic access to all test and analysis functions

## Quick Start

### 🚀 One-Line Install (Recommended)

**Automatically download and install for your platform:**

**If you have curl:**
```bash
curl -fsSL https://raw.githubusercontent.com/jwil007/wlan-autoroam-release/main/install.sh | sudo bash
```

**If you have wget instead:**
```bash
wget -qO- https://raw.githubusercontent.com/jwil007/wlan-autoroam-release/main/install.sh | sudo bash
```

This will:
- ✅ Detect your architecture (AMD64, ARM64, ARMv7)
- ✅ Download the latest release
- ✅ Install to `/usr/local/bin/wlan-autoroam` (accessible system-wide)
- ✅ Make it executable and ready to use

Then simply run:
```bash
sudo wlan-autoroam
```

Open your browser to `https://localhost:8443` and start testing!

---

### 📦 Manual Installation

<details>
<summary>Click to expand manual installation steps</summary>

#### Prerequisites

**System Requirements:**
- Linux (Debian/Ubuntu or similar)
- Active Wi-Fi connection
- Root/sudo access (required for wireless tools: `iw`, `wpa_cli`)

**Your system needs:**
- `wpa_supplicant` and `wpa_cli`
- `iw` (wireless tools)
- `journalctl` (systemd)
- `ip` (iproute2)

Most modern Linux distributions have these installed by default.

#### Installation Steps

1. **Download the binary** from the [latest release](../../releases/latest)

2. **Make it executable:**
   ```bash
   # Replace * with the version for your binary (i.e. wlan-autoroam-amd64)
   chmod +x wlan-autoroam-*
   ```

3. **Run the setup wizard:**
   ```bash
   # Replace * with the version for your binary (i.e. wlan-autoroam-amd64)
   sudo ./wlan-autoroam-*
   ```

   On first run, the wizard will:
   - Check for required system utilities
   - Detect your wireless interface(s)
   - Prompt for web UI username and password
   - Generate secure configuration files
   - Launch the web UI at https://localhost:8443

4. **Access the web interface:**
   - Open https://localhost:8443
   - Login with your configured credentials
   - Accept the self-signed certificate warning (or provide your own certs)

</details>

---

### Configuration Files

After setup, your configuration lives in:
- **Config**: `~/.config/wlan-autoroam/`
  - `.env` - Web UI credentials
  - `user_prefs.json` - Default interface and RSSI threshold
  - `certs/` - SSL certificates (replaceable)
  - `ai_settings.json` - AI provider configuration (via web UI)

- **Data**: `~/.local/share/wlan-autoroam/`
  - `runs/` - Test results and saved runs
  - `roam.log` - Application logs

---

## AI Analysis (RoamBot)

RoamBot is an agentic AI assistant that can run tests, analyze results, compare networks, and answer questions about your Wi-Fi infrastructure. It uses the Model Context Protocol (MCP) to access tools and data autonomously.

**What makes it "agentic"?** RoamBot decides which actions to take based on your question. Ask to "run a test and compare it to yesterday's run" - it'll start the test, wait for completion, fetch the historical data, and provide a comparison. No button clicking required.

> [!TIP]
> In my testing Claude Haiku 4.5 (Anthropic) has been best for price/performance. The MCP implementation makes is easy to swap out models so experiment to find what works best for you. To easily try different public models, check out OpenRouter. Local LLMs via Ollama like Qwen3 do work but YMMV.

### Setup

1. Click **AI Settings** (top bar icon) and configure your provider:
   - **OpenAI**: Get API key from https://platform.openai.com/api-keys. Endpoint: `https://api.openai.com/v1`.
   - **Anthropic**: Get API key from https://console.anthropic.com/. Endpoint: `https://api.anthropic.com/v1`.
   - **OpenRouter** (multi-model): Get API key from https://openrouter.ai/. Endpoint: `https://openrouter.ai/api/v1`. Supports Claude, GPT-4, Gemini, and 200+ models.
   - **Ollama** (local): Install with `curl -fsSL https://ollama.ai/install.sh | sh`, pull a model (`ollama pull llama3.2`), set endpoint to `http://localhost:11434/v1`.
   - **LM Studio** (local): Download from https://lmstudio.ai/, start the server, set endpoint to `http://localhost:1234/v1`.

2. Save settings and start chatting. RoamBot will introduce itself.

**Token usage:** The AI panel header shows token consumption. Agentic mode can pull significant data when comparing runs - watch your usage carefully. You generally get what you pay for, but I've tried to make the prompt engineering explicit enough to make "dumb" models "smart". For free usage, go local with Ollama - bring a big GPU.

**Privacy:** Your credentials and test data are only sent when you request analysis. Use local providers (Ollama/LM Studio) for complete privacy.


> [!NOTE]
> AI settings (API key, endpoint, model) are stored locally in `webui/server/ai_settings.json`. Your preferred interface is saved in `webui/server/user_prefs.json` - tell RoamBot once and it remembers.

### Example Prompts

**Running tests:**
- "Run a roam test on wlp0s20f3"
- "Test my network and save the results"
- "Run a test with RSSI threshold of -70"

**Analysis:**
- "What were the failures in this test?"
- "Why did roam #3 take so long?"
- "Are there any configuration issues with these APs?"

**Multi-run comparison:**
- "Compare the last two Wilson-Corp runs"
- "Show me all IoT tests from this week"
- "Has performance improved since yesterday?"
- "Which network has better roaming performance?"
- "What's the trend in association times?"

**Network audit:**
- "Are all my APs configured consistently?"
- "Which APs are overloaded?"
- "Do I have co-channel interference?"

---

## REST API

Full REST API documentation available at `https://localhost:8443/api/docs` (Swagger UI - button in the web interface after login).

API calls require `X-API-Key` header with the key from `~/.config/wlan-autoroam/api_key.txt`.

---

## Documentation

- **[CHANGELOG.md](CHANGELOG.md)** - Version history and release notes
- **[MOBILITY_SCORE.md](MOBILITY_SCORE.md)** - Understanding the mobility score

## Usage

```bash
# Start the web UI (requires sudo for wireless tools)
sudo wlan-autoroam

# Specify a different port
sudo wlan-autoroam -p 10443

# Force re-run the setup wizard
sudo wlan-autoroam --setup
```

The web interface will be available at https://localhost:8443 (or your chosen port).

## Support

**Issues and Questions:**
- Found a bug? [Open an issue](../../issues)
- Have a question? [Start a discussion](../../discussions)

**Security Note:**
Always run wlan-autoroam with `sudo` as it requires root privileges to access wireless utilities (`iw`, `wpa_cli`). Config files are created with secure permissions (600/644).

## License

Free to use. See [LICENSE](LICENSE) for details.

## Full UI Screenshot
<img width="1350" height="2052" alt="localhost_8443_ (2)" src="https://github.com/user-attachments/assets/22e9ed7d-0a43-4e0e-8fe9-5f976f9be5ee" />

---

**Built with:** Python, Flask, FastMCP, and the Model Context Protocol
