#!/bin/bash

# Boje za izlaz
txtbld=$(tput bold)
bldred=${txtbld}$(tput setaf 1)
bldgrn=${txtbld}$(tput setaf 2)
bldblu=${txtbld}$(tput setaf 4)
txtrst=$(tput sgr0)

# Odabir jezika
echo "Select language / Odaberite jezik:"
echo "1) English"
echo "2) Bosanski"
read -p "Choice / Izbor [1-2]: " lang

if [[ "$lang" == "2" ]]; then
  # Bosanski
  title="📦 YetiForce DB Postavka za verziju 7.0.4"
  no_mysql="❌ MySQL server nije dostupan. Provjerite pristup."
  confirm_remove="🗑️  Da li želite ukloniti defaultnu bazu 'yetiforce' i korisnika 'yeti'? (da/ne): "
  removed_success="✅ Defaultna baza i korisnik su uklonjeni. Backup spremljen."
  enter_db="📛 Unesite naziv nove baze: "
  invalid_db="❌ Naziv baze može sadržavati samo slova, brojeve i donje crte."
  enter_user="👤 Unesite ime novog korisnika: "
  enter_pass="🔑 Unesite lozinku za korisnika: "
  confirm_pass="🔁 Potvrdite lozinku: "
  mismatch="❌ Lozinke se ne podudaraju."
  success="✅ Baza '%s' i korisnik '%s' uspješno kreirani."
else
  # English
  title="📦 YetiForce DB Setup for version 7.0.4"
  no_mysql="❌ MySQL server is not available. Check access."
  confirm_remove="🗑️  Do you want to remove the default database 'yetiforce' and user 'yeti'? (yes/no): "
  removed_success="✅ Default database and user removed. Backup created."
  enter_db="📛 Enter new database name: "
  invalid_db="❌ Database name may only contain letters, numbers, and underscores."
  enter_user="👤 Enter new username: "
  enter_pass="🔑 Enter password for user: "
  confirm_pass="🔁 Confirm password: "
  mismatch="❌ Passwords do not match."
  success="✅ Database '%s' and user '%s' created successfully."
fi

echo "${bldblu}$title${txtrst}"

# Provjera MySQL konekcije
if ! mysqladmin ping -u root --silent; then
    echo "${bldred}$no_mysql${txtrst}"
    exit 1
fi

# Brisanje postojeće baze i korisnika
DEFAULT_DB="yetiforce"
DEFAULT_USER="yeti"

read -p "$confirm_remove" CONFIRM
if [[ "$CONFIRM" =~ ^(da|yes)$ ]]; then
    mysqldump -u root ${DEFAULT_DB} > "${DEFAULT_DB}_backup_$(date +%F_%T).sql"
    mysql -u root -e "DROP DATABASE IF EXISTS ${DEFAULT_DB};"
    mysql -u root -e "DROP USER IF EXISTS '${DEFAULT_USER}'@'localhost';"
    echo "${bldgrn}$removed_success${txtrst}"
fi

# Unos podataka
read -p "$enter_db" NEW_DB
if [[ ! "$NEW_DB" =~ ^[a-zA-Z0-9_]+$ ]]; then
  echo "${bldred}$invalid_db${txtrst}"
  exit 1
fi

read -p "$enter_user" NEW_USER
read -s -p "$enter_pass" NEW_PASS
echo
read -s -p "$confirm_pass" CONFIRM_PASS
echo
if [[ "$NEW_PASS" != "$CONFIRM_PASS" ]]; then
    echo "${bldred}$mismatch${txtrst}"
    exit 1
fi

# Kreiranje baze i korisnika
mysql -u root -e "CREATE DATABASE \`${NEW_DB}\`;"
mysql -u root -e "CREATE USER '${NEW_USER}'@'localhost' IDENTIFIED BY '${NEW_PASS}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON \`${NEW_DB}\`.* TO '${NEW_USER}'@'localhost' WITH GRANT OPTION;"
mysql -u root -e "FLUSH PRIVILEGES;"
mysql -u root -e "ALTER DATABASE \`${NEW_DB}\` CHARACTER SET utf8 COLLATE utf8_unicode_ci;"

printf "${bldgrn}$success${txtrst}\n" "$NEW_DB" "$NEW_USER"
