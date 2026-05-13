# Asyura Quality Tracker — Deployment Guide

## Struktur File
```
asyura-quality-tracker/
├── index.html              ← Aplikasi utama (single file, semua sudah di sini)
├── .htaccess               ← Config Apache — untuk shared hosting / cPanel
├── nginx.conf              ← Config Nginx  — untuk Tencent VPS / CVM
├── deploy-tencent.sh       ← Script deploy otomatis ke Tencent CVM
└── README.md               ← Panduan ini
```

---

## OPSI A — Shared Hosting (cPanel / Niagahoster / Dewaweb / Hostinger)

Cara paling mudah, tidak perlu setup server.

1. Login cPanel → **File Manager**
2. Masuk ke folder `public_html`
3. Upload `index.html` dan `.htaccess`
4. Akses di `https://namadomain.com`

> Jika ingin di subdomain (misal `qa.namadomain.com`):
> - Buat subdomain di cPanel → **Subdomains**
> - Upload ke folder subdomain tersebut

---

## OPSI B — Tencent Cloud CVM / Lighthouse (VPS)

### Prasyarat
- Server Ubuntu 20.04 / 22.04
- Port 80 & 443 terbuka di Security Group Tencent

### Deploy Manual (SSH)

```bash
# Di laptop kamu — upload file
scp index.html root@SERVER_IP:/var/www/asyura-quality-tracker/

# Masuk ke server
ssh root@SERVER_IP

# Install Nginx (jika belum)
apt update && apt install -y nginx

# Copy config
nano /etc/nginx/sites-available/asyura-quality-tracker
# (paste isi nginx.conf, ganti your-domain.com)

# Aktifkan site
ln -s /etc/nginx/sites-available/asyura-quality-tracker \
      /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

### Deploy Otomatis (Script)

```bash
# Edit konfigurasi dulu
nano deploy-tencent.sh
# Isi: SERVER_IP, SERVER_USER, SSH_KEY, DOMAIN

# Jalankan
chmod +x deploy-tencent.sh
./deploy-tencent.sh
```

### Tambah SSL Gratis (Let's Encrypt)

```bash
# Di dalam server
apt install certbot python3-certbot-nginx -y
certbot --nginx -d namadomain.com -d www.namadomain.com
# Ikuti instruksi, pilih redirect HTTP→HTTPS
```

Auto-renew sudah berjalan otomatis via systemd timer.

---

## OPSI C — Tencent COS (Object Storage Static Hosting)

Alternatif paling murah, tanpa VPS.

1. Masuk **Tencent Cloud Console** → **COS**
2. Buat bucket → pilih region **ap-singapore** (terdekat dari Indonesia)
3. Tab **Permission** → set **Public Read**
4. Upload `index.html`
5. Tab **Basic Configuration** → aktifkan **Static Website**
6. Set Index Document: `index.html`
7. (Opsional) Tab **Custom Domain** → bind domain kamu
8. Akses lewat endpoint COS atau domain custom

Biaya: ~$0.02/GB storage, nyaris gratis untuk file sekecil ini.

---

## Checklist Security Tencent CVM

- [ ] Ganti password root → buat user non-root
- [ ] Disable password login SSH, pakai SSH key
- [ ] Buka port 22, 80, 443 di **Security Group** — tutup port lainnya
- [ ] Pasang SSL (certbot)
- [ ] Enable UFW firewall: `ufw allow 22,80,443/tcp && ufw enable`

---

## Catatan Teknis

- Aplikasi ini **100% static** — tidak butuh PHP, Node.js, atau database
- Data disimpan di **localStorage browser** — per perangkat, tidak sync antar user
- Ukuran file: ~35KB — loading sangat cepat
- Untuk kebutuhan multi-user / sync data, perlu backend tambahan (misal Supabase)
