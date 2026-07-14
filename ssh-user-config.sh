#!/bin/bash

# ============================================================
# ARA TM — SSH User Configuration Script
# Developer / توسعه‌دهنده: Parham_7991
# ============================================================
# This script configures the root password (required), an optional sudo user,
# optional SSH authorized keys and the Claude Code auth token, then launches
# the SSH server. Connect directly as root after deploy.
# این اسکریپت رمز عبور root (الزامی)، یک کاربر sudo اختیاری، کلیدهای مجاز
# اختیاری و توکن Claude Code را تنظیم کرده و سپس سرور SSH را اجرا می‌کند.
# پس از دیپلوی مستقیماً با کاربر root متصل شوید.

# Display language / زبان نمایش
# Default is English. Set APP_LANG=fa for Persian.
# پیش‌فرض انگلیسی است. برای فارسی مقدار fa=APP_LANG را تنظیم کنید.
: ${APP_LANG:="en"}

# Bilingual message helper / تابع نمایش پیام دوزبانه
# Usage: msg "english text" "متن فارسی"
msg() {
    local en="$1"
    local fa="$2"
    if [ "$APP_LANG" = "fa" ]; then
        echo "$fa"
    else
        echo "$en"
    fi
}

# ---------------------------------------------------------------
# ROOT PASSWORD (MANDATORY) / رمز عبور root (الزامی)
# ---------------------------------------------------------------
# Root login is always enabled in the Dockerfile. A root password MUST be
# supplied at deploy time — the container refuses to start without it.
# ورود root همیشه در Dockerfile فعال است. باید حتماً رمز عبور root در زمان
# دیپلوی ست شود؛ در غیر این صورت کانتینر اجازه راه‌اندازی نمی‌یابد.
: ${ROOT_PASSWORD:=""}
if [ -z "$ROOT_PASSWORD" ]; then
    if [ "$APP_LANG" = "fa" ]; then
        echo "خطا: متغیر محیطی ROOT_PASSWORD الزامی است. لطفاً یک رمز عبور برای root ست کنید." >&2
    else
        echo "Error: ROOT_PASSWORD is required. Please set a root password before deploying." >&2
    fi
    exit 1
fi
echo "root:$ROOT_PASSWORD" | chpasswd
msg "Root password set — you can now connect as root" \
    "رمز عبور root تنظیم شد — اکنون می‌توانید با کاربر root متصل شوید"

# ---------------------------------------------------------------
# OPTIONAL SUDO USER / کاربر sudo اختیاری
# ---------------------------------------------------------------
# A regular user is no longer required. Provide both SSH_USERNAME and
# SSH_PASSWORD only if you also want a secondary sudo user.
# کاربر عادی دیگر الزامی نیست. فقط در صورتی که می‌خواهید یک کاربر sudo
# ثانویه داشته باشید، SSH_USERNAME و SSH_PASSWORD را با هم ست کنید.
: ${SSH_USERNAME:=""}
: ${SSH_PASSWORD:=""}

if [ -n "$SSH_USERNAME" ] && [ -n "$SSH_PASSWORD" ]; then
    if id "$SSH_USERNAME" &>/dev/null; then
        msg "User $SSH_USERNAME already exists" "کاربر $SSH_USERNAME از قبل وجود دارد"
    else
        useradd -ms /bin/bash "$SSH_USERNAME"
        echo "$SSH_USERNAME:$SSH_PASSWORD" | chpasswd
        # Add user to sudo group / افزودن کاربر به گروه sudo
        usermod -aG sudo "$SSH_USERNAME"
        msg "User $SSH_USERNAME created with the provided password and added to sudo group" \
            "کاربر $SSH_USERNAME با رمز عبور داده‌شده ایجاد و به گروه sudo اضافه شد"
    fi
elif [ -n "$SSH_USERNAME" ] || [ -n "$SSH_PASSWORD" ]; then
    # Only one of the pair was provided — ignore and warn / فقط یکی ست شده — نادیده گرفته و هشدار
    msg "SSH_USERNAME and SSH_PASSWORD must be set together; skipping extra user creation" \
        "SSH_USERNAME و SSH_PASSWORD باید با هم ست شوند؛ ایجاد کاربر اضافه رد شد"
fi

# ---------------------------------------------------------------
# OPTIONAL AUTHORIZED KEYS / کلیدهای مجاز اختیاری
# ---------------------------------------------------------------
# Set SSH public keys for key-based authentication (does not disable password login).
# کلیدهای عمومی SSH را برای احراز هویت مبتنی بر کلید ست می‌کند (ورود با رمز غیرفعال نمی‌شود).
: ${AUTHORIZED_KEYS:=""}
if [ -n "$AUTHORIZED_KEYS" ]; then
    mkdir -p /root/.ssh
    echo "$AUTHORIZED_KEYS" > /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
    msg "Authorized keys set for root" "کلیدهای مجاز برای root تنظیم شد"
else
    msg "Authorized keys not set" "کلیدهای مجاز تنظیم نشدند"
fi

# ---------------------------------------------------------------
# OPTIONAL CLAUDE CODE AUTH TOKEN / توکن اختیاری Claude Code
# ---------------------------------------------------------------
# The token is NOT baked in. Supply it via the ANTHROPIC_AUTH_TOKEN build arg
# or (recommended) as a Railway environment variable — it is applied on every
# container start, so editing it takes effect on the next deploy.
# توکن بیک نمی‌شود. آن را از طریق آرگومان ساخت ANTHROPIC_AUTH_TOKEN یا
# (توصیه می‌شود) به عنوان متغیر محیطی Railway ست کنید — روی هر اجرا اعمال
# می‌شود، بنابراین ویرایش آن روی دیپلوی بعدی اثر می‌گذارد.
: ${ANTHROPIC_AUTH_TOKEN:=""}

# Configure Claude Code settings and inject the auth token (if provided)
# پیکربندی تنظیمات Claude Code و تزریق توکن احراز هویت (در صورت وجود)
configure_claude_settings() {
    local token="$ANTHROPIC_AUTH_TOKEN"
    # Home directories that should have Claude Code settings
    # دایرکتوری‌های خانه که باید تنظیمات Claude Code را داشته باشند
    local homes="/root"
    if [ -n "$SSH_USERNAME" ] && [ -d "/home/$SSH_USERNAME" ]; then
        homes="$homes /home/$SSH_USERNAME"
    fi
    for home in $homes; do
        local claude_dir="$home/.claude"
        local settings="$claude_dir/settings.json"
        mkdir -p "$claude_dir"
        if [ ! -f "$settings" ]; then
            # Fallback to the baked root template if this user has no settings yet
            # در صورت نبود تنظیمات، از قالب آماده root استفاده می‌کنیم
            cp /root/.claude/settings.json "$settings" 2>/dev/null || continue
        fi
        if [ -n "$token" ] && command -v jq >/dev/null 2>&1; then
            # Overwrite only the token; everything else stays as the default
            # فقط توکن بازنویسی می‌شود؛ بقیه مقادیر پیش‌فرض باقی می‌مانند
            jq --arg t "$token" '.env.ANTHROPIC_AUTH_TOKEN = $t' "$settings" > "$settings.tmp" \
                && mv "$settings.tmp" "$settings"
        fi
        # Fix ownership so the user can read/write their own settings
        # اصلاح مالکیت تا کاربر بتواند تنظیمات خود را بخواند و بنویسد
        chown -R "$(stat -c '%U:%G' "$home" 2>/dev/null)" "$claude_dir" 2>/dev/null || true
    done
    if [ -n "$token" ]; then
        msg "Claude Code auth token applied" "توکن احراز هویت Claude Code اعمال شد"
    else
        msg "Claude Code auth token not set — provide ANTHROPIC_AUTH_TOKEN to use Claude Code" \
            "توکن احراز هویت Claude Code تنظیم نشد — برای استفاده از Claude Code مقدار ANTHROPIC_AUTH_TOKEN را وارد کنید"
    fi
}

configure_claude_settings

# ---------------------------------------------------------------
# START SSH SERVER / راه‌اندازی سرور SSH
# ---------------------------------------------------------------
msg "Starting SSH server..." "در حال راه‌اندازی سرور SSH..."
exec /usr/sbin/sshd -D
