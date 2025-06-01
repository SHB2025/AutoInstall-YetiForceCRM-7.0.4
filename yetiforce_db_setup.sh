#!/bin/bash

set -e

txtred='\033[1;31m'
txtgrn='\033[1;32m'
txtblu='\033[1;34m'
txtnc='\033[0m'

# Funkcija za validaciju lozinke
validate_password() {
    local passwd="$1"
    if [[ "$passwd" =~ [\$\'\"\\] ]]; then
        return 1
    fi
    return 0
}

# Provjera postoji li baza yetiforce
DB_TO_DROP="yetiforce"
USER_TO_DROP="yeti"
FOUND_DB=$(mysql -N -e "SHOW DATABASES LIKE '$DB_TO_DROP';")
FOUND_USER=$(mysql -N -e "SELECT user FROM mysql.user WHERE user='$USER_TO_DROP';")

if [[ -n "$FOUND_DB" || -n "$FOUND_USER" ]]; then
    echo -e "${txtblu}Pronađena je standardna YetiForce baza i/ili korisnik.${txtnc}"
    read -p "Želiš li obrisati bazu '$DB_TO_DROP' i korisnika '$USER_TO_DROP'? (y/n): " CONFIRM
    if [[ "$CONFIRM" == "y" ]]; then
        if [[ -n "$FOUND_DB" ]]; then
            mysql -e "DROP DATABASE \`$DB_TO_DROP\`;"
            echo -e "${txtgrn}Baza $DB_TO_DROP obrisana.${txtnc}"
        fi
        if [[ -n "$FOUND_USER" ]]; then
            mysql -e "DROP USER IF EXISTS '$USER_TO_DROP'@'localhost';"
            echo -e "${txtgrn}Korisnik $USER_TO_DROP obrisan.${txtnc}"
        fi
    else
        echo "Brisanje preskočeno."
    fi
else
    echo -e "${txtblu}Baza 'yetiforce' ili korisnik 'yeti' nisu pronađeni.${txtnc}"
    read -p "Želiš li unijeti naziv baze i korisnika za ručno brisanje? (y/n): " MANUAL
    if [[ "$MANUAL" == "y" ]]; then
        read -p "Naziv baze za brisanje: " DB_TO_DROP
        read -p "Naziv korisnika za brisanje: " USER_TO_DROP
        if [[ -n "$DB_TO_DROP" ]]; then
            FOUND_DB=$(mysql -N -e "SHOW DATABASES LIKE '$DB_TO_DROP';")
            if [[ -n "$FOUND_DB" ]]; then
                mysql -e "DROP DATABASE \`$DB_TO_DROP\`;"
                echo -e "${txtgrn}Baza $DB_TO_DROP obrisana.${txtnc}"
            else
                echo -e "${txtred}Baza $DB_TO_DROP nije pronađena.${txtnc}"
            fi
        fi
        if [[ -n "$USER_TO_DROP" ]]; then
            FOUND_USER=$(mysql -N -e "SELECT user FROM mysql.user WHERE user='$USER_TO_DROP';")
            if [[ -n "$FOUND_USER" ]]; then
                mysql -e "DROP USER IF EXISTS '$USER_TO_DROP'@'localhost';"
                echo -e "${txtgrn}Korisnik $USER_TO_DROP obrisan.${txtnc}"
            else
                echo -e "${txtred}Korisnik $USER_TO_DROP nije pronađen.${txtnc}"
            fi
        fi
    else
        echo "Brisanje preskočeno."
    fi
fi

echo -e "\n${txtblu}Sada kreiramo NOVOG korisnika i bazu za YetiForce.${txtnc}"
read -p "Unesite željeni naziv baze: " NEWDB
read -p "Unesite korisničko ime za bazu: " NEWUSER

# Unos i validacija lozinke
while true; do
    read -s -p "Unesite lozinku (dozvoljeni karakteri: slova, brojevi, !@#%^&*()-_=+): " NEWPASS
    echo
    if validate_password "$NEWPASS"; then
        break
    else
        echo -e "${txtred}Lozinka NE SMIJE sadržavati $, ', \", ili \\ ! Pokušajte ponovo.${txtnc}"
    fi
done

mysql -e "CREATE DATABASE IF NOT EXISTS \`$NEWDB\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS '$NEWUSER'@'localhost' IDENTIFIED BY '$NEWPASS';"
mysql -e "GRANT ALL PRIVILEGES ON \`$NEWDB\`.* TO '$NEWUSER'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo -e "${txtgrn}Baza '$NEWDB' i korisnik '$NEWUSER' su uspješno kreirani!${txtnc}"
