<p align="center">
  <img src="assets/railway-settings.png" alt="ARA TM" width="120"/>
</p>

<h1 align="center">ARA TM — Railway Ubuntu SSH Server 🚂</h1>

<p align="center">
  <b>Your own cloud workstation on Railway</b> — SSH in as <b>root</b>, with <b>Claude Code</b> pre-installed and ready to go.
  <br/>
  <b>ایستگاه کاری ابری مخصوص خودت روی Railway</b> — با دسترسی root از طریق SSH و Claude Code از پیش نصب‌شده.
</p>

<p align="center">
  🇬🇧 English &nbsp;·&nbsp; 🇮🇷 <a href="README.fa.md">فارسی</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Railway-blue" alt="Platform">
  <img src="https://img.shields.io/badge/Ubuntu-24.04-orange" alt="Ubuntu">
  <img src="https://img.shields.io/badge/SSH-OpenSSH-green" alt="SSH">
  <img src="https://img.shields.io/badge/Claude_Code-included-purple" alt="Claude Code">
  <img src="https://img.shields.io/badge/languages-English%20%2F%20Persian-important" alt="Languages">
  <img src="https://img.shields.io/badge/license-MIT-blue" alt="License">
</p>

<p align="center">
  <a href="https://railway.com/deploy/ubuntu-ssh-claude"><img src="https://railway.com/button.svg" alt="Deploy on Railway"></a>
</p>

---

A Docker image built for **Railway** that provides an **Ubuntu 24.04** base with an **SSH server (SSHD)** enabled, a **mandatory root password**, a full developer toolkit, and **Claude Code** pre-installed. Connect to your container over SSH and use it as a portable cloud workstation — or pair it with Claude Code for an AI-assisted terminal.

ایمیج داکری ساخته‌شده برای **Railway** که بر پایه **Ubuntu 24.04** با سرور **SSH (SSHD)** فعال، **رمز عبور اجباری root**، یک جعبه‌ابزار کامل توسعه و **Claude Code** از پیش نصب‌شده است. از طریق SSH به کانتینر خود متصل شوید و از آن به عنوان ایستگاه کاری ابری قابل‌حمل استفاده کنید — یا با Claude Code ترمینالی هوشمند داشته باشید.

## ✨ Features / ویژگی‌ها

- 🐧 **Ubuntu 24.04** base image / ایمیج پایه Ubuntu 24.04
- 🔑 **Root login enabled** — connect directly as `root` / ورود root فعال — مستقیماً با `root` وصل شوید
- 🛡️ **Mandatory root password** — deploy fails safely if `ROOT_PASSWORD` is missing / رمز عبور root **اجباری** — اگر ست نشده باشد دیپلوی ایمن متوقف می‌شود
- 👤 Optional secondary sudo user (`SSH_USERNAME` / `SSH_PASSWORD`) / کاربر sudo ثانویه اختیاری
- 🌐 Network & dev toolkit: `curl`, `wget`, `git`, `vim`, `nano`, `micro`, `htop`, `btop`, `ncdu`, `tmux`, `zsh`, Python 3, Node.js + npm / ابزارهای شبکه و توسعه
- 🧠 **Claude Code** (Anthropic official CLI) pre-installed, with a `cl` / `زم` command / **Claude Code** از پیش نصب‌شده با دستور `cl` / `زم`
- 🌍 English + Persian locales (`en_US.UTF-8`, `fa_IR.UTF-8`) / لوکِیل انگلیسی و فارسی
- 🎨 ARA TM welcome banner on login / بنر خوش‌آمد ARA TM هنگام ورود
- 🗣️ Bilingual runtime messages (`APP_LANG=fa` for Persian) / پیام‌های دوزبانه هنگام اجرا

## ⚠️ Important Notice / هشدار مهم

**Railway runs Docker containers, not a VPS!** Any data stored in the container is **lost on every redeploy** — files, installed packages, config changes and user data. For persistent storage use Railway Volume Mounts or external storage.

**Railway کانتینرهای داکر اجرا می‌کند، نه VPS!** هر داده‌ای در کانتینر هنگام هر بار redeploy **از دست می‌رود** — فایل‌ها، بسته‌ها، تغییرات پیکربندی و داده‌های کاربر. برای ذخیره‌سازی ماندگار از Volumeهای Railway استفاده کنید.

## 🚀 Deploy to Railway / دیپلوی روی Railway

1. Fork or clone this repository and connect it to a new **Railway** project.
   مخزن را Fork یا Clone کنید و به یک پروژه جدید **Railway** متصل کنید.
2. Go to **Settings → Variables** and set at least `ROOT_PASSWORD` (required).
   به **Settings → Variables** بروید و حداقل `ROOT_PASSWORD` (الزامی) را ست کنید.
3. Go to **Settings → Networking → Public Networking** and add a **TCP Proxy** on port `22`.
   به **Settings → Networking → Public Networking** بروید و یک **TCP Proxy** روی پورت `22` اضافه کنید.
4. **Redeploy**. Railway will give you a domain and port for SSH access.
   **Redeploy** کنید. Railway دامنه و پورتی برای دسترسی SSH در اختیار شما می‌گذارد.

## 📦 Railway Template / تمپلیت Railway

This repo ships two Railway config files so it can be deployed as a template:

این ریپو دو فایل کانفیگ Railway دارد تا به عنوان تمپلیت دیپلوی شود:

- **`railway.json`** — Railway project config (Dockerfile builder, start command, restart policy, healthcheck). Used automatically when you deploy this repo.
  کانفیگ پروژه Railway (سازنده Dockerfile، دستور اجرا، سیاست ری‌استارت، هلث‌چک). هنگام دیپلوی ریپو خودکار استفاده می‌شود.
- **`railway-template.json`** — a complete, shareable Railway template manifest: service definition, required/optional variables (with descriptions), and the **TCP Proxy on port 22** pre-configured.
  یک منیفست تمپلیت کامل و قابل اشتراک Railway: تعریف سرویس، متغیرهای اجباری/اختیاری (با توضیحات)، و **TCP Proxy روی پورت ۲۲** از پیش تنظیم‌شده.

**To deploy / برای دیپلوی:**
1. Connect this repo to a new Railway project (or import `railway-template.json`).
   این ریپو را به یک پروژه جدید Railway متصل کنید (یا `railway-template.json` را Import کنید).
2. Set `ROOT_PASSWORD` (required). The TCP proxy on port 22 is created automatically by the template.
   `ROOT_PASSWORD` (اجباری) را ست کنید. پروکسی TCP روی پورت ۲۲ توسط تمپلیت به طور خودکار ساخته می‌شود.
3. Redeploy and connect with `ssh root@<domain> -p <port>`.
   Redeploy کنید و با `ssh root@<domain> -p <port>` وصل شوید.

## 🌱 Environment Variables / متغیرهای محیطی

| Variable | Required | Default | Description |
|----------|:--------:|---------|-------------|
| `ROOT_PASSWORD` | ✅ Yes | — | Password for the **root** user. **Mandatory** — the container will not start without it. / رمز کاربر **root**. **الزامی** — بدون آن کانتینر اجرا نمی‌شود. |
| `SSH_USERNAME` | ⬜ No | — | Optional secondary sudo user. Must be set together with `SSH_PASSWORD`. / کاربر sudo ثانویه اختیاری. باید با `SSH_PASSWORD` ست شود. |
| `SSH_PASSWORD` | ⬜ No | — | Password for the optional user. / رمز کاربر اختیاری. |
| `AUTHORIZED_KEYS` | ⬜ No | — | SSH public key(s) for root key-based auth (password login stays on). / کلید(های) عمومی SSH برای root. |
| `ANTHROPIC_AUTH_TOKEN` | ⬜ No | — | Token for Claude Code (OpenRouter / Anthropic). Applied on every deploy. / توکن Claude Code. روی هر دیپلوی اعمال می‌شود. |
| `APP_LANG` | ⬜ No | `en` | Runtime message language: `en` or `fa`. / زبان پیام‌ها: `en` یا `fa`. |

> The Claude Code connection (`ANTHROPIC_BASE_URL`, model names, theme) is pre-configured in `claude-settings.json` and points to **OpenRouter** by default.
> اتصال Claude Code (آدرس پایه، نام مدل‌ها، تم) از پیش در `claude-settings.json` تنظیم شده و پیش‌فرض روی **OpenRouter** است.

## 🔌 Connect via SSH / اتصال از طریق SSH

Once deployed, connect directly as root:

```bash
ssh root@<your-railway-domain> -p <port>
```

When prompted, type `yes` to accept the host key, then enter your `ROOT_PASSWORD`.

## 🧠 Using Claude Code / استفاده از Claude Code

[Claude Code](https://github.com/anthropics/claude-code) is pre-installed. After connecting via SSH:

پس از اتصال از طریق SSH، Claude Code از پیش نصب شده است:

```bash
claude --version      # verify / بررسی نصب بودن
cl                    # or / یا:  زم   → opens a tmux session running Claude Code
```

The `cl` (also `زم`) command opens a **tmux** session named `claude` and runs Claude Code inside it. Press `Ctrl+B` then `D` to detach without closing.

دستور `cl` (و `زم`) یک نشست **tmux** به نام `claude` باز کرده و Claude Code را در آن اجرا می‌کند. برای جدا شدن `Ctrl+B` و سپس `D` را بزنید.

### Auth token / توکن احراز هویت

The token is **never baked into the image**. Provide it via:

توکن **هرگز داخل ایمیج بیک نمی‌شود**. آن را از طریق یکی از روش‌ها وارد کنید:

- **Build arg:** `docker build --build-arg ANTHROPIC_AUTH_TOKEN="sk-or-..." -t ara-ssh .`
- **Railway env var:** set `ANTHROPIC_AUTH_TOKEN` — it is rewritten into the settings on every container start, so editing it applies on the next deploy.
  **متغیر محیطی Railway:** `ANTHROPIC_AUTH_TOKEN` را ست کنید — روی هر اجرا در تنظیمات بازنویسی می‌شود، پس ویرایش آن روی دیپلوی بعدی اثر می‌گذارد.

## 📦 Included Packages / بسته‌های موجود

**Network / شبکه:** `curl`, `wget`, `iproute2`, `iputils-ping`, `net-tools`, `dnsutils`, `traceroute`, `whois`, `telnet`, `nmap`
**Editors / ویرایشگر:** `vim`, `nano`, `micro`
**Monitoring / مانیتورینگ:** `htop`, `btop`, `ncdu`, `neofetch`
**Terminal / ترمینال:** `tmux`, `screen`, `less`, `tree`, `bat`, `ripgrep`, `fd-find`, `jq`, `zsh`
**Archives / آرشیو:** `unzip`, `zip`, `tar`, `gzip`, `bzip2`, `xz-utils`, `p7zip-full`
**Dev / توسعه:** `git`, `build-essential`, `cmake`, `pkg-config`, `autoconf`, `automake`, `libtool`, `gcc`, `g++`, `python3`, `python3-pip`, `python3-venv`, `nodejs`, `npm`
**Locales / لوکِیل:** `locales`, `language-pack-en`, `language-pack-fa`

## 🔒 Security / امنیت

- **Root password is mandatory** — never deploy without `ROOT_PASSWORD`. / رمز root **الزامی** است.
- Change the default password after first login. / پس از اولین ورود رمز را تغییر دهید.
- The Claude Code token is **never** stored in the image — keep it private. / توکن Claude Code هرگز در ایمیج ذخیره نمی‌شود.
- Consider `AUTHORIZED_KEYS` for key-only access on top of the password. / برای دسترسی مبتنی بر کلید، `AUTHORIZED_KEYS` را در نظر بگیرید.

## 📦 Container Limitations / محدودیت‌های کانتینر

- **No persistent storage** — data is lost on redeploy. / بدون ذخیره‌سازی ماندگار.
- **Not a VPS** — it is a containerized environment. / VPS نیست، محیط کانتینری است.
- Use **Railway Volume Mount** for persistent data. / برای داده ماندگار از Volume استفاده کنید.

## 🩺 Troubleshooting / عیب‌یابی

- Ensure the TCP proxy is configured on port `22`. / TCP proxy روی پورت ۲۲ ست باشد.
- Verify the correct domain and port from the Railway dashboard. / دامنه و پورت صحیح را چک کنید.
- If the container crashes at start, check that `ROOT_PASSWORD` is set. / اگر کانتینر crash می‌کند، `ROOT_PASSWORD` ست شده باشد.
- Remember data loss on every redeploy. / فراموش نکنید داده‌ها روی هر دیپلوی پاک می‌شوند.

## 📄 License / مجوز

Released under the MIT License — see [LICENSE](LICENSE).

---

<p align="center">
  © ARA TM · Maintained by <b>Parham_7991</b> · Built for Railway 🚂
</p>
