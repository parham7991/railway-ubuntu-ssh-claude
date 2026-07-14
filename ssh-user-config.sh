#!/bin/bash

# ============================================================
# ARA TM — SSH User Configuration Script
# Developer / توسعه‌دهنده: Parham_7991
# ============================================================
# This script configures the SSH user, password and authorized keys
# inside the Railway Ubuntu container and then launches the SSH server.
# این اسکریپت کاربر SSH، رمز عبور و کلیدهای مجاز را داخل کانتینر
# اوبونتوی Railway تنظیم کرده و سپس سرور SSH را اجرا می‌کند.

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

# Set SSH_USERNAME and SSH_PASSWORD by default or from environment variables
# مقدار پیش‌فرض SSH_USERNAME و SSH_PASSWORD را تنظیم می‌کند یا از متغیرهای محیطی می‌خواند
: ${SSH_USERNAME:="myuser"}
: ${SSH_PASSWORD:="mypassword"}

# Set root password and enable direct root login by default
# تنظیم رمز عبور root و فعال‌سازی ورود مستقیم با کاربر root به صورت پیش‌فرض
: ${ROOT_PASSWORD:="rootpassword"}
echo "root:$ROOT_PASSWORD" | chpasswd
msg "Root password set" "رمز کاربر root تنظیم شد"

# Set authorized keys if applicable
# در صورت وجود، کلیدهای مجاز را تنظیم می‌کند
: ${AUTHORIZED_KEYS:=""}

# Set Claude Code auth token (overrides the built-in default at runtime)
# تنظیم توکن احراز هویت Claude Code (در زمان اجرا پیش‌فرض داخلی را بازنویسی می‌کند)
: ${ANTHROPIC_AUTH_TOKEN:=""}

# Check if SSH_USERNAME or SSH_PASSWORD is empty and raise an error
# بررسی خالی نبودن SSH_USERNAME و SSH_PASSWORD و صدور خطا در غیر این صورت
if [ -z "$SSH_USERNAME" ] || [ -z "$SSH_PASSWORD" ]; then
    if [ "$APP_LANG" = "fa" ]; then
        echo "خطا: باید SSH_USERNAME و SSH_PASSWORD تنظیم شوند." >&2
    else
        echo "Error: SSH_USERNAME and SSH_PASSWORD must be set." >&2
    fi
    exit 1
fi

# Create the user with the provided username and set the password
# ایجاد کاربر با نام کاربری داده‌شده و تنظیم رمز عبور آن
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

# Apply Claude Code settings (and inject the auth token if provided)
# اعمال تنظیمات Claude Code (و تزریق توکن احراز هویت در صورت وجود)
configure_claude_settings

# Set the authorized keys from the AUTHORIZED_KEYS environment variable (if provided)
# تنظیم کلیدهای مجاز از متغیر محیطی AUTHORIZED_KEYS (در صورت وجود)
if [ -n "$AUTHORIZED_KEYS" ]; then
    mkdir -p /home/$SSH_USERNAME/.ssh
    echo "$AUTHORIZED_KEYS" > /home/$SSH_USERNAME/.ssh/authorized_keys
    chown -R $SSH_USERNAME:$SSH_USERNAME /home/$SSH_USERNAME/.ssh
    chmod 700 /home/$SSH_USERNAME/.ssh
    chmod 600 /home/$SSH_USERNAME/.ssh/authorized_keys
    msg "Authorized keys set for user $SSH_USERNAME" "کلیدهای مجاز برای کاربر $SSH_USERNAME تنظیم شد"
    # Disable password authentication if authorized keys are provided
    # در صورت ارائه کلیدهای مجاز، احراز هویت با رمز عبور غیرفعال می‌شود
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
else
    msg "Authorized keys not set" "کلیدهای مجاز تنظیم نشدند"
fi

# Start the SSH server / راه‌اندازی سرور SSH
msg "Starting SSH server..." "در حال راه‌اندازی سرور SSH..."
exec /usr/sbin/sshd -D
