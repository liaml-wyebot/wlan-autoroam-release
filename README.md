# wlan-autoroam

Automated Wi-Fi roaming testing and analysis with an agentic AI assistant. Validate mobility performance, visualize results, or just hang out with RoamBot. 
> [!IMPORTANT]
> **AI Features Require Your Own API Key**: RoamBot needs an LLM provider (OpenAI, Anthropic, OpenRouter, or local Ollama/LM Studio). Basic roaming tests work without AI. See the [AI analysis section](#ai-analysis-roambot) for configuration.

<img width="1249" height="1342" alt="localhost_8443_ (2)-crop" src="https://github.com/user-attachments/assets/2a416268-d989-4c9e-85f6-e2291d7630a7" />

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
## Features

<details>
<summary>Click to expand</summary>
   
* **🤖 Agentic AI Assistant (RoamBot)** - Natural language interface for roaming analysis. Ask questions, run tests, compare results, and get insights—AI autonomously uses tools to analyze your data (supports OpenAI, Anthropic, OpenRouter, or local LLMs)
* **Automated Roaming Tests** - Uses native Linux tools (`iw`, `wpa_cli`) to perform round-robin roam tests across APs in your area with detailed phase timing
* **Phase Timing Breakout** - Measures auth, reassoc, EAP, and 4-way handshake duration from the client perspective
* **Mobility Score** - Single metric for roaming readiness based on security, WiFi generation, and capabilities ([learn more](MOBILITY_SCORE.md))
* **Failed Roam Diagnostics** - Auto-saves log snippets with detailed error context for troubleshooting
* **Interactive Web UI** - Real-time test execution, result management, and multi-run comparison
* **REST API** - Programmatic access to all test and analysis functions
</details>


---

## Supported Hardware
This was built to run on Linux systems, primarily tested on Debian based distros (Debian, Raspberry Pi OS, Ubuntu, Kali, etc). Core utilities needed are `iw`, `wpa_cli`, and `journalctl`.

You need a Wi-Fi radio with an active connection to an SSID. Most testing has been done on Intel radios (common in laptops) and Broadcom radios (built into Raspberry Pi).
> [!NOTE]
> Other radios should work, but have not been tested. Messages in the user-space logging (wpa_supplicant) vary slightly between vendors, and can cause problems with log parsing. If you find a quirk with a radio I haven't tested, open an [issue](https://github.com/jwil007/wlan-autoroam-release/issues) with details.

Binaries are built for `AMD64`, `ARM64`, and `ARMv7` architectures. The one-line install linked below will automatically select the right one for your system.

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

RoamBot is an **agentic AI assistant** that autonomously analyzes your roaming tests. Unlike chatbots that just answer questions, RoamBot takes action: it runs tests, fetches data, compares results, and provides insights—all from natural language requests.

**Example:**
> "Run a test and compare it to yesterday's results"

RoamBot will:
1. Start a new roam test
2. Wait for completion
3. Fetch yesterday's test data
4. Compare performance metrics
5. Explain the differences

No clicking buttons or navigating the dashboard needed.

### Setup

**You need an LLM provider** (your API key, your usage):
- **OpenAI** ([get key](https://platform.openai.com/api-keys)) - GPT
- **Anthropic** ([get key](https://console.anthropic.com/)) - Claude 
- **OpenRouter** ([get key](https://openrouter.ai/)) - 200+ models from one API
- **Ollama** (local/free) - `curl -fsSL https://ollama.ai/install.sh | sh`

Configure via **AI Settings** button in the web UI. Basic roaming tests work without AI.

> **Recommendation:** Claude 4.5 Haiku via Anthropic has the best price to performance ratio in my testing. I've also been impressed with Grok Code Fast 1 via OpenRouter. Experiment to find what works best for you!

### Example Prompts
<details>
<summary><b>Expand to see examples</b></summary>


**Running tests:**
- "Run a roaming test"
- "Test with RSSI threshold of -70 and save results"
- "Run a few tests and tell me if there are any trends"

**Analysis:**
- "What failed in this test?"
- "Why did roam #3 take 400ms?"
- "Are there configuration issues with these APs?"

**Multi-run comparison:**
- "Compare the last two Wilson-Corp runs"
- "Has performance improved since last week?"
- "Which network has better roaming?"

**Network audit:**
- "Are all APs configured consistently?"
- "Do I have co-channel interference?"

</details>


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

---

## Full UI Screenshot
<img width="1350" height="2052" alt="localhost_8443_ (2)" src="https://github.com/user-attachments/assets/22e9ed7d-0a43-4e0e-8fe9-5f976f9be5ee" />

---

## License

Free to use. See [LICENSE](LICENSE) for details.

---

**Built with:** Python, Flask, FastMCP, and the Model Context Protocol
