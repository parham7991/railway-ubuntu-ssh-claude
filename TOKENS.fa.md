# 🔑 ARA TM · دریافت توکن‌های شما
### راهنمای گام‌به‌گام و خفن برای وصل کردن GitHub و OpenRouter

> 💡 **چرا دو تا توکن؟**
> - **توکن GitHub** → پوشه `/root/src` شما به صورت خودکار در یک مخزن **خصوصی** پشتیبان‌گیری شده و روی هر بازسازی بازیابی می‌شود (کار شما با بازسازی کانتینر از دست نمی‌رود).
> - **توکن OpenRouter** → قدرت **Claude Code** را داخل کانتینر فراهم می‌کند (چت، کد، ایجنت).
>
> هر دو **اختیاری** هستند اما شدیداً توصیه می‌شوند. هیچ‌کدام هرگز در ایمیج ذخیره نمی‌شوند — شما آن‌ها را به عنوان متغیرهای محیطی Railway ست می‌کنید.

---

## ۱️⃣ توکن GitHub — برای بک‌آپ خودکار `src`

این توکن به کانتینر اجازه می‌دهد یک مخزن خصوصی `ara-tm-src-<id>` بسازد و فایل‌های شما را همگام کند.

### 🚀 لینک مستقیم (یک کلیک)
[➡️ ساخت توکن دسترسی شخصی GitHub](https://github.com/settings/tokens/new?description=ARA%20TM%20src-sync&scopes=repo)

### 🪜 مراحل
۱. لینک بالا ⬆️ را باز کنید (یا **GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)**).
۲. یک نام بدهید، مثلاً `ARA TM src-sync`.
۳. **مدت انقضا** را تنظیم کنید (مثلاً *۹۰ روز* یا *بدون انقضا*).
۴. ✅ تیک **`repo`** را بزنید (دسترسی کامل به مخازن خصوصی).
۵. به پایین اسکرول کنید → **Generate token**.
۶. 📋 توکن را **کپی** کنید (با `ghp_` شروع می‌شود!). **دیگر آن را نخواهید دید!**

### 📥 کجا بچسبانیدش
در Railway، این متغیر محیطی را اضافه کنید:

```bash
GITHUB_TOKEN = ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

همین‌قدر — در دیپلوی بعدی، کانتینر مخزن خصوصی را می‌سازد و همگام‌سازی را خودکار شروع می‌کند.

> 🔒 توکن فقط **داخل خود کانتینر** ذخیره می‌شود (`/var/lib/ara/github-token`، `chmod 600`) و از طریق HTTPS استفاده می‌شود. آن را مخفی نگه دارید؛ هر زمان خواستید می‌توانید از GitHub لغوش کنید.

---

## ۲️⃣ توکن OpenRouter — برای Claude Code

این توکن به کانتینر دسترسی به مدل‌های Claude از طریق OpenRouter می‌دهد (تأمین‌کننده پیش‌فرض در `claude-settings.json`).

### 🚀 لینک مستقیم (یک کلیک)
[➡️ ساخت کلید API در OpenRouter](https://openrouter.ai/keys)

### 🪜 مراحل
۱. لینک بالا ⬆️ را باز کنید (یا **openrouter.ai → Keys**).
۲. روی **Create Key** کلیک کنید.
۳. یک نام بدهید، مثلاً `ARA TM cloud`.
۴. 📋 کلید را **کپی** کنید (با `sk-or-` شروع می‌شود).

### 📥 کجا بچسبانیدش
در Railway، این متغیر محیطی را اضافه کنید:

```bash
ANTHROPIC_AUTH_TOKEN = sk-or-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

سپس با SSH وارد شوید و اجرا کنید:

```bash
cl          # یا:  زم   → راه‌اندازی Claude Code داخل یک نشست tmux
```

> 💡 اتصال (آدرس OpenRouter، نام مدل‌ها، تم) **از پیش تنظیم شده** است. فقط کلید را وارد می‌کنید. ویرایش آن روی دیپلوی بعدی اثر می‌گذارد.

---

## 🧾 رفرنس سریع

| توکن | متغیر | scope / نوع | لینک مستقیم |
|------|-------|------------|-------------|
| 🟣 GitHub | `GITHUB_TOKEN` | `repo` (classic PAT) | [github.com/settings/tokens/new](https://github.com/settings/tokens/new?scopes=repo) |
| 🟠 OpenRouter | `ANTHROPIC_AUTH_TOKEN` | API Key | [openrouter.ai/keys](https://openrouter.ai/keys) |

---

## 🩺 عیب‌یابی

- **`src-sync: GITHUB_TOKEN not set`** وقتی دستی `src-sync --status` را اجرا می‌کنید؟
  → فایل توکن در **راه‌اندازی** کانتینر نوشته می‌شود. بعد از ست کردن متغیر یک بار **Redeploy** کنید، سپس دوباره تلاش کنید.
- **`src-sync` می‌گوید "failed to create repo (check token scope = repo)"**؟
  → توکن شما scopeی `repo` ندارد، یا یک توکن *fine‑grained* بدون دسترسی repo است. آن را با scopeی `repo` دوباره بسازید.
- **Claude Code می‌گوید "not authenticated"**؟
  → `ANTHROPIC_AUTH_TOKEN` خالی یا نامعتبر است. کلید OpenRouter را دوباره بچسبانید و redeploy کنید.

---

<p align="center">
  <b>© ARA TM</b> · نگهداری توسط <b>Parham_7991</b><br>
  ☁ Railway Ubuntu SSH + Claude Code
</p>
