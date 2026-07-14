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

# Install dependencies. Root login is enabled so you can connect directly as root.
# نصب وابستگی‌ها. ورود کاربر root فعال است تا بتوانید مستقیماً با کاربر root متصل شوید.
# Essential tooling is included: editors, monitoring, archive tools, git and Node.js (for Claude Code).
# ابزارهای اصلی شامل ویرایشگر، نظارت، آرشیو، git و Node.js (برای Claude Code) می‌شوند.
RUN apt-get update \
    && apt-get install -y \
        iproute2 iputils-ping openssh-server telnet sudo \
        curl wget git vim nano htop tmux less unzip zip ca-certificates build-essential \
        nodejs npm locales ncurses-term jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir -p /run/sshd \
    && chmod 755 /run/sshd \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    # Enable root login / فعال کردن ورود root
    && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# Generate the en_US.UTF-8 locale / تولید لوکِیل en_US.UTF-8
RUN locale-gen en_US.UTF-8

# Set locale and terminal environment / تنظیم لوکِیل و محیط ترمینال
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV TERM=xterm-256color

# Claude Code settings (ARA TM defaults). The auth token is NOT baked in — it
# must be supplied by the builder via the ANTHROPIC_AUTH_TOKEN build arg, or at
# runtime via the ANTHROPIC_AUTH_TOKEN environment variable (applied on every
# container start by ssh-user-config.sh).
# تنظیمات Claude Code (پیش‌فرض‌های ARA TM). توکن احراز هویت بیک نمی‌شود و باید
# توسط سازنده از طریق آرگومان ساخت ANTHROPIC_AUTH_TOKEN، یا در زمان اجرا از طریق
# متغیر محیطی ANTHROPIC_AUTH_TOKEN (اعمال‌شده روی هر اجرای کانتینر توسط ssh-user-config.sh) تامین شود.
ARG ANTHROPIC_AUTH_TOKEN=""
COPY claude-settings.json /root/.claude/settings.json
RUN sed -i "s|__ANTHROPIC_AUTH_TOKEN__|${ANTHROPIC_AUTH_TOKEN}|g" /root/.claude/settings.json

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

# Expose port 22 (default SSH port) / باز کردن پورت ۲۲ (پورت پیش‌فرض SSH)
EXPOSE 22

# Start the SSH server / راه‌اندازی سرور SSH
CMD ["/usr/local/bin/ssh-user-config.sh"]
