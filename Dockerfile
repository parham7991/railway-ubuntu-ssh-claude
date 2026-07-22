# ============================================================
# ARA TM — Railway Ubuntu SSH Server
# Developer / توسعه‌دهنده: Parham_7991
# ============================================================
# A Docker image that provides an Ubuntu 24.04 base with an SSH server
# (SSHD) enabled, so you can connect to your Railway container via SSH.
# ایمیج داکری بر پایه Ubuntu 24.04 با سرور SSH (SSHD) فعال،
# برای اتصال از طریق SSH به کانتینر Railway شما.

FROM ubuntu:24.04

# The official Ubuntu 24.04 docker image ships a default "ubuntu" user with UID/GID 1000.
# Remove it so UID/GID 1000 is free for our own SSH user.
# ایمیج رسمی اوبونتو 24.04 کاربر پیش‌فرض "ubuntu" با UID/GID 1000 دارد.
# آن را حذف می‌کنیم تا این شناسه برای کاربر SSH خودمان آزاد باشد.
RUN userdel -r ubuntu 2>/dev/null || true

# Enable the "universe" repository so we can install extra tooling
# فعال‌سازی مخزن "universe" برای نصب ابزارهای بیشتر
RUN sed -i 's/^Components: .*/Components: main restricted universe/' /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || true

# Install dependencies. Root login is enabled so you can connect directly as root.
# نصب وابستگی‌ها. ورود کاربر root فعال است تا بتوانید مستقیماً با کاربر root متصل شوید.
# A full cloud-workstation toolkit: networking, editors, monitoring, archives,
# dev tools, Python, Node.js (for Claude Code) and Persian/English locales.
# یک جعبه‌ابزار کامل ایستگاه کاری ابری: شبکه، ویرایشگر، مانیتورینگ، آرشیو،
# ابزار توسعه، پایتون، Node.js (برای Claude Code) و لوکِیل فارسی/انگلیسی.
RUN apt-get update \
    && apt-get install -y \
        ca-certificates gnupg apt-transport-https software-properties-common \
        openssh-server \
        curl wget \
        iproute2 iputils-ping net-tools dnsutils traceroute whois telnet nmap \
        vim nano micro \
        htop btop ncdu neofetch \
        tmux screen less tree bat ripgrep fd-find jq zsh \
        unzip zip tar gzip bzip2 xz-utils p7zip-full \
        git build-essential cmake pkg-config autoconf automake libtool gcc g++ \
        python3 python3-pip python3-venv python3-dev \
        nodejs npm \
        locales ncurses-term language-pack-en language-pack-fa \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir -p /run/sshd \
    && chmod 755 /run/sshd \
    && ssh-keygen -A \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    # Enable root login / فعال کردن ورود root
    && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# Generate English and Persian locales / تولید لوکِیل‌های انگلیسی و فارسی
RUN locale-gen en_US.UTF-8 fa_IR.UTF-8

# ARA TM welcome banner shown on interactive SSH login
# بنر خوش‌آمد ARA TM که هنگام ورود تعاملی SSH نمایش داده می‌شود
COPY ara-welcome.sh /etc/profile.d/ara-welcome.sh
RUN chmod +x /etc/profile.d/ara-welcome.sh

# Set locale and terminal environment / تنظیم لوکِیل و محیط ترمینال
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV TERM=xterm-256color

# ============================================================
# Claude Code settings (ARA TM defaults)
# تنظیمات Claude Code (پیش‌فرض‌های ARA TM)
# ============================================================
# The auth token is NOT baked into the image at build time — that would
# fail BuildKit's SecretsUsedInArgOrEnv check on Railway.
# The token is injected at RUNTIME by ssh-user-config.sh, which reads the
# ANTHROPIC_AUTH_TOKEN env var (set as a Railway Variable) and patches
# /root/.claude/settings.json with `jq`.
#
# توکن احراز هویت در زمان build در ایمیج بیک نمی‌شود — این کار check
# BuildKit با نام SecretsUsedInArgOrEnv را در Railway fail می‌کند.
# توکن در زمان RUNTIME توسط ssh-user-config.sh تزریق می‌شود که
# متغیر محیطی ANTHROPIC_AUTH_TOKEN (تنظیم‌شده به عنوان Railway Variable)
# را می‌خواند و با jq فایل /root/.claude/settings.json را patch می‌کند.
# ============================================================

# Copy the default Claude Code settings. The ANTHROPIC_AUTH_TOKEN placeholder
# (__ANTHROPIC_AUTH_TOKEN__) is replaced at runtime by ssh-user-config.sh
# only if the env var is set; otherwise the field is patched to an empty
# string by the same script.
# کپی تنظیمات پیش‌فرض Claude Code. placeholder مربوط به ANTHROPIC_AUTH_TOKEN
# (__ANTHROPIC_AUTH_TOKEN__) در زمان runtime توسط ssh-user-config.sh فقط در
# صورتی که env var ست شده باشد جایگزین می‌شود؛ در غیر این صورت همین اسکریپت
# فیلد را به رشته خالی patch می‌کند.
COPY claude-settings.json /root/.claude/settings.json

# Install Claude Code (official CLI by Anthropic) globally
# نصب سراسری Claude Code (رابط خط فرمان رسمی Anthropic)
RUN npm install -g @anthropic-ai/claude-code

# Copy ssh user config to configure the user's password and authorized keys
# کپی اسکریپت تنظیم کاربر SSH برای پیکربندی رمز عبور و کلیدهای مجاز
COPY ssh-user-config.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/ssh-user-config.sh

# Copy the "cl" helper command (opens a tmux session running Claude Code) and
# expose it under both "cl" and "زم".
# کپی دستور کمکی "cl" (باز کردن نشست tmux با Claude Code) و در دسترس قرار دادن
# آن با نام‌های "cl" و "زم".
COPY cl /usr/local/bin/cl
RUN chmod +x /usr/local/bin/cl \
    && ln -sf /usr/local/bin/cl /usr/local/bin/زم

# Copy the "usage" command (Railway trial credit + uptime monitor)
# کپی دستور «usage» (مانیتور اعتبار تریال و زمان بیداری Railway)
COPY usage /usr/local/bin/usage
RUN chmod +x /usr/local/bin/usage

# Copy the "src-sync" command (/root/src ⇄ private GitHub repo for persistence)
# کپی دستور «src-sync» (همگام‌سازی پوشه src با مخزن خصوصی GitHub برای پایداری داده‌ها)
COPY src-sync.sh /usr/local/bin/src-sync
RUN chmod +x /usr/local/bin/src-sync \
    && mkdir -p /root/src

# Expose port 22 (default SSH port) / باز کردن پورت ۲۲ (پورت پیش‌فرض SSH)
EXPOSE 22

# Start the SSH server / راه‌اندازی سرور SSH
CMD ["/usr/local/bin/ssh-user-config.sh"]
