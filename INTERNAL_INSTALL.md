# Internal Installation Guide

This guide is for installing **wlan-autoroam** from a private GitHub repository.

## Prerequisites

- Linux system (Debian-based distros recommended)
- GitHub account with access to this repository
- `sudo` access on your system

## Step 1: Accept Repository Invitation

You should have received an email invitation to collaborate on this repository.

1. Open the invitation email from GitHub
2. Click **"View invitation"**
3. Click **"Accept invitation"**
4. You now have read access to the repository

## Step 2: Create GitHub Personal Access Token

Since this is a private repository, you need a Personal Access Token (PAT) to download releases.

### 2.1 Generate the Token

1. Go to: **https://github.com/settings/tokens/new**
2. Fill out the form:
   - **Note**: `wlan-autoroam installer` (or any name you prefer)
   - **Expiration**: Choose expiration (recommend 90 days or "No expiration" for convenience)
   - **Select scopes**: Check **`repo`** (Full control of private repositories)
     - This is the only scope needed
3. Click **"Generate token"** at the bottom
4. **IMPORTANT**: Copy the token immediately (it starts with `ghp_`)
   - You won't be able to see it again!
   - If you lose it, you'll need to generate a new one

### 2.2 Save the Token (Optional but Recommended)

Add the token to your shell profile so you don't have to enter it each time:

**For bash users:**
```bash
echo 'export GITHUB_TOKEN="ghp_your_token_here"' >> ~/.bashrc
source ~/.bashrc
```

**For zsh users:**
```bash
echo 'export GITHUB_TOKEN="ghp_your_token_here"' >> ~/.zshrc
source ~/.zshrc
```

Replace `ghp_your_token_here` with your actual token.

## Step 3: Install wlan-autoroam

### Option A: Using saved token (if you completed Step 2.2)

```bash
curl -H "Authorization: token $GITHUB_TOKEN" \
  -fsSL https://raw.githubusercontent.com/jwil007/wlan-autoroam-release/main/install.sh \
  -o /tmp/install-wlan.sh && \
sudo bash /tmp/install-wlan.sh && \
rm /tmp/install-wlan.sh
```

The `-E` flag preserves your environment variables (including `GITHUB_TOKEN`).

### Option B: Inline token (one-time install)

```bash
curl -H "Authorization: token ghp_your_token_here" \
  -fsSL https://raw.githubusercontent.com/jwil007/wlan-autoroam-release/main/install.sh \
  -o /tmp/install-wlan.sh && \
sudo bash /tmp/install-wlan.sh && \
rm /tmp/install-wlan.sh
```

Replace `ghp_your_token_here` with your actual token.

### What the Installer Does

The script will:
1. ✅ Detect your system architecture (AMD64, ARM64, or ARMv7)
2. ✅ Download the latest release binary for your platform
3. ✅ Install to `/usr/local/bin/wlan-autoroam`
4. ✅ Make it executable and accessible system-wide

## Step 4: Run wlan-autoroam

Once installed, launch the application:

```bash
sudo wlan-autoroam
```

### First-Time Setup

On first run, you'll be guided through:
1. Creating a web UI username and password
2. Selecting your wireless interface
3. Configuring basic settings

### Access the Web UI

Open your browser to: **https://localhost:8443**

- Default credentials: `admin` / `admin` (change after first login)
- From another device: `https://<your-ip>:8443` (e.g., `https://10.0.10.58:8443`)

> **Note**: The certificate is self-signed, so you'll need to click through your browser's security warning.

## Troubleshooting

### "Failed to fetch latest release version"

**Cause**: Token is invalid or doesn't have the right permissions.

**Solution**:
1. Verify your token is correct (starts with `ghp_`)
2. Check that you selected the `repo` scope when creating it
3. Confirm you've accepted the repository invitation
4. Try generating a new token

### "Failed to download binary"

**Cause**: Token authentication failed during download.

**Solution**:
1. Make sure you're using `sudo -E` (preserves environment variables)
2. Verify `GITHUB_TOKEN` is set: `echo $GITHUB_TOKEN`
3. If using inline token, check for typos

### "Neither curl nor wget found"

**Cause**: Missing download utilities.

**Solution**:
```bash
sudo apt-get update
sudo apt-get install curl wget
```

### Permission Denied

**Cause**: Not running with sudo.

**Solution**: The installer needs root access for system-wide installation:
```bash
sudo -E bash  # Don't forget -E to preserve GITHUB_TOKEN
```

## Updating to Latest Version

To update to the latest release:

```bash
# If token is saved in your profile
curl -H "Authorization: token $GITHUB_TOKEN" \
  -fsSL https://raw.githubusercontent.com/jwil007/wlan-autoroam-release/main/install.sh \
  -o /tmp/install-wlan.sh && \
sudo bash /tmp/install-wlan.sh && \
rm /tmp/install-wlan.sh

# Or with inline token
curl -H "Authorization: token ghp_your_token_here" \
  -fsSL https://raw.githubusercontent.com/jwil007/wlan-autoroam-release/main/install.sh \
  -o /tmp/install-wlan.sh && \
sudo bash /tmp/install-wlan.sh && \
rm /tmp/install-wlan.sh
```

The installer automatically detects if you have an older version and upgrades it.

## Uninstalling

To remove wlan-autoroam:

```bash
sudo rm /usr/local/bin/wlan-autoroam
```

## Security Best Practices

### Token Storage
- ✅ **DO**: Store tokens in your shell profile or a password manager
- ✅ **DO**: Use tokens with minimal required scopes (`repo` only)
- ✅ **DO**: Set expiration dates if your organization requires it
- ❌ **DON'T**: Commit tokens to git repositories
- ❌ **DON'T**: Share tokens with others (each person needs their own)
- ❌ **DON'T**: Store tokens in plain text files in shared directories

### Token Rotation
If you suspect your token has been compromised:
1. Go to: https://github.com/settings/tokens
2. Find your token and click **"Delete"**
3. Generate a new token (Step 2 above)
4. Update your shell profile with the new token

## Support

If you encounter issues not covered in this guide:

1. Check the main [README.md](README.md) for general usage help
2. Review the [CHANGELOG.md](CHANGELOG.md) for recent changes
3. Contact the repository owner

---

**Quick Reference Commands:**

```bash
# Install (with saved token)
curl -H "Authorization: token $GITHUB_TOKEN" \
  -fsSL https://raw.githubusercontent.com/jwil007/wlan-autoroam-release/main/install.sh \
  -o /tmp/install-wlan.sh && \
sudo bash /tmp/install-wlan.sh && \
rm /tmp/install-wlan.sh

# Run
sudo wlan-autoroam

# Update
curl -H "Authorization: token $GITHUB_TOKEN" \
  -fsSL https://raw.githubusercontent.com/jwil007/wlan-autoroam-release/main/install.sh \
  -o /tmp/install-wlan.sh && \
sudo bash /tmp/install-wlan.sh && \
rm /tmp/install-wlan.sh

# Uninstall
sudo rm /usr/local/bin/wlan-autoroam
```
