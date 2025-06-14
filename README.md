# AutoInstall-YetiForceCRM-7.0.4
Skripta za automatsku instalaciju YetiForce CRM 7.0.4 / YetiForce CRM 7.0.4 Auto Install Script

# 🧩 YetiForce CRM 7.0.4 Automatizirana Instalacija

Ovaj repozitorij sadrži dvije skripte koje omogućavaju **potpunu i sigurnu instalaciju** YetiForce CRM 7.0.4 sistema na **Ubuntu Server 22.04 ili 24.04**.
This repository contains two scripts that enable a **complete and secure installation** of the YetiForce CRM 7.0.4 system on **Ubuntu Server 22.04 or 24.04**.
---

## 📥 Preuzimanje / Download

    sudo wget https://raw.githubusercontent.com/SHB2025/AutoInstall-YetiForceCRM-7.0.4/refs/heads/main/AutoInstall-YetiForceCRM.sh
    sudo wget https://raw.githubusercontent.com/SHB2025/AutoInstall-YetiForceCRM-7.0.4/refs/heads/main/yetiforce_db_setup.sh
---
# Pokretanje YetiForce CRM 7.0.4 instalacijske skripte
# NAPOMENA: Za instalaciju uvijek koristite ENGLESKI jezik, a nakon izvršene instalacije odaberite i instalirajte željeni jezik za YetiForce.
# Running the YetiForce CRM 7.0.4 installation script
# NOTE: Always use the ENGLISH language for installation, and after installation, select and install the desired language for YetiForce.
    sudo chmod +x AutoInstall-YetiForceCRM.sh
    sudo ./AutoInstall-YetiForceCRM.sh
---
# Pokretanje YetiForce SQL Setup skripte
# Running the YetiForce SQL Setup script
    sudo chmod +x yetiforce_db_setup.sh
    sudo ./yetiforce_db_setup.sh


---

## 🇧🇦 BOSANSKI

### 1️⃣ AutoInstall-YetiForceCRM.sh

Automatski instalira:

- Apache2 + PHP 8.2 + potrebne PHP ekstenzije
- MySQL server i početnu bazu (`yetiforce`)
- Composer
- YetiForce CRM 7.0.4 u `/var/www/html/yeti`
- SSL konfiguraciju sa self-signed certifikatom
- Sigurnosna Apache zaglavlja
- Prava pristupa i konfiguraciju `php.ini`, `mysql.cnf`, `apache2.conf`
- Startni ekran koji automatski preusmjerava HTTP → HTTPS

> 🟡 Nakon izvršavanja ove skripte, sistem je spreman za završnu web instalaciju putem preglednika.

---

### 2️⃣ yetiforce_db_setup.sh

Pokreće se **nakon prve skripte**, ali **prije pokretanja instalacije kroz web preglednik**. Omogućava:

- Uklanjanje defaultne baze `yetiforce` i korisnika `yeti`
- Unos novog imena baze, korisničkog imena i lozinke
- Kreiranje baze i korisnika u skladu s preporukama YetiForce CRM 7.0.4
- Backup defaultne baze prije brisanja

> 🔐 Preporučuje se za dodatnu sigurnost i personalizaciju sistema.

---

## 🌍 ENGLISH

### 1️⃣ AutoInstall-YetiForceCRM.sh

Automatically installs:

- Apache2 + PHP 8.2 + required PHP extensions
- MySQL server and initial database (`yetiforce`)
- Composer
- YetiForce CRM 7.0.4 in `/var/www/html/yeti`
- SSL with self-signed certificate
- Security headers in Apache
- Permission & config adjustments (`php.ini`, `mysql.cnf`, `apache2.conf`)
- Landing page that redirects HTTP → HTTPS

> 🟡 After this script, the system is ready for the final web GUI installation step.

---

### 2️⃣ yetiforce_db_setup.sh

Should be run **after the first script** and **before launching the web installer**. It allows you to:

- Remove the default `yetiforce` DB and `yeti` user
- Input new DB name, user and password
- Create secure database and user per YetiForce 7.0.4 requirements
- Automatically back up the default database

> 🔐 Recommended for security and project-specific configurations.

---

## 📺 YouTube tutorijal

Detaljna video uputstva dostupna na kanalu [SolutionHub Bosnia](https://www.youtube.com/@SolutionHubBosnia)

---

## 📌 Napomena

- Skripte su testirane na čistim instalacijama **Ubuntu Server 22.04 i 24.04**
- Nisu podržane druge distribucije
- Preporučuje se da se pokreću sa root privilegijama
