# 🔑 ARA TM · Get Your Tokens
### Step‑by‑step, fancy guide to wiring up GitHub & OpenRouter

> 💡 **Why two tokens?**
> - **GitHub token** → your `/root/src` folder is auto‑backed up to a **private** repo and restored on every redeploy (your work survives container rebuilds).
> - **OpenRouter token** → powers **Claude Code** inside the container (chat, code, agents).
>
> Both are **optional** but highly recommended. Neither is ever baked into the image — you set them as Railway environment variables.

---

## 1️⃣ GitHub Token — for automatic `src` backup

This token lets the container create a private `ara-tm-src-<id>` repo and sync your files.

### 🚀 Direct link (one click)
[➡️ Create a GitHub Personal Access Token](https://github.com/settings/tokens/new?description=ARA%20TM%20src-sync&scopes=repo)

### 🪜 Steps
1. Open the link above ⬆️ (or **GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)**).
2. Give it a name, e.g. `ARA TM src-sync`.
3. Set **Expiration** (e.g. *90 days* or *No expiration*).
4. ✅ Check the **`repo`** checkbox (full control of private repositories).
5. Scroll down → **Generate token**.
6. 📋 **Copy** the token (starts with `ghp_`). **You won't see it again!**

### 📥 Where to paste it
In Railway, add this environment variable:

```bash
GITHUB_TOKEN = ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

That's it — on the next deploy the container creates the private repo and starts syncing automatically.

> 🔒 The token is stored **only inside the container** (`/var/lib/ara/github-token`, `chmod 600`) and used over HTTPS. Keep it secret; you can revoke it anytime from GitHub.

---

## 2️⃣ OpenRouter Token — for Claude Code

This token gives the container access to Claude models via OpenRouter (the default provider in `claude-settings.json`).

### 🚀 Direct link (one click)
[➡️ Create an OpenRouter API Key](https://openrouter.ai/keys)

### 🪜 Steps
1. Open the link above ⬆️ (or **openrouter.ai → Keys**).
2. Click **Create Key**.
3. Name it, e.g. `ARA TM cloud`.
4. 📋 **Copy** the key (starts with `sk-or-`).

### 📥 Where to paste it
In Railway, add this environment variable:

```bash
ANTHROPIC_AUTH_TOKEN = sk-or-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Then SSH in and run:

```bash
cl          # or:  زم   → launches Claude Code inside a tmux session
```

> 💡 The connection (OpenRouter URL, model names, theme) is **pre‑configured**. You only supply the key. Editing it takes effect on the next deploy.

---

## 🧾 Quick reference

| Token | Variable | Scope / Type | Direct link |
|-------|----------|--------------|-------------|
| 🟣 GitHub | `GITHUB_TOKEN` | `repo` (classic PAT) | [github.com/settings/tokens/new](https://github.com/settings/tokens/new?scopes=repo) |
| 🟠 OpenRouter | `ANTHROPIC_AUTH_TOKEN` | API Key | [openrouter.ai/keys](https://openrouter.ai/keys) |

---

## 🩺 Troubleshooting

- **`src-sync: GITHUB_TOKEN not set`** when you run `src-sync --status` manually?
  → The token file is written at container **startup**. **Redeploy once** after setting the variable, then retry.
- **`src-sync` says "failed to create repo (check token scope = repo)"**?
  → Your token is missing the `repo` scope, or is a *fine‑grained* token without repo access. Re‑create it with `repo` scope.
- **Claude Code shows "not authenticated"**?
  → `ANTHROPIC_AUTH_TOKEN` is empty or invalid. Re‑paste the OpenRouter key and redeploy.

---

<p align="center">
  <b>© ARA TM</b> · Maintained by <b>Parham_7991</b><br>
  ☁ Railway Ubuntu SSH + Claude Code
</p>
