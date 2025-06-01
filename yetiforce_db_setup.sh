#!/bin/bash

set -e

txtred='\033[1;31m'
txtgrn='\033[1;32m'
txtblu='\033[1;34m'
txtnc='\033[0m'

# Funkcija za validaciju lozinke / Password validation function
validate_password() {
    local passwd="$1"
    if [[ "$passwd" =~ [\$\'\"\\] ]]; then
        return 1
    fi
    return 0
}

# Provjera postoji li baza yetiforce / Checking if the yetiforce base exists
DB_TO_DROP="yetiforce"
USER_TO_DROP="yeti"
FOUND_DB=$(mysql -N -e "SHOW DATABASES LIKE '$DB_TO_DROP';")
FOUND_USER=$(mysql -N -e "SELECT user FROM mysql.user WHERE user='$USER_TO_DROP';")

if [[ -n "$FOUND_DB" || -n "$FOUND_USER" ]]; then
    echo -e "${txtblu}Pronađena je standardna YetiForce baza i/ili korisnik. / A standard YetiForce database and/or user was found.${txtnc}"
    read -p "Želiš li obrisati bazu '$DB_TO_DROP' i korisnika '$USER_TO_DROP'? / Do you want to delete database '$DB_TO_DROP' and user '$USER_TO_DROP'? (y/n): " CONFIRM
    if [[ "$CONFIRM" == "y" ]]; then
        if [[ -n "$FOUND_DB" ]]; then
            mysql -e "DROP DATABASE \`$DB_TO_DROP\`;"
            echo -e "${txtgrn}Baza $DB_TO_DROP obrisana. / Database $DB_TO_DROP deleted.${txtnc}"
        fi
        if [[ -n "$FOUND_USER" ]]; then
            mysql -e "DROP USER IF EXISTS '$USER_TO_DROP'@'localhost';"
            echo -e "${txtgrn}Korisnik $USER_TO_DROP obrisan. / User $USER_TO_DROP deleted.${txtnc}"
        fi
    else
        echo "Brisanje preskočeno. / Deletion skipped."
    fi
else
    echo -e "${txtblu}Baza 'yetiforce' ili korisnik 'yeti' nisu pronađeni. / Database 'yetiforce' or user 'yeti' not found.${txtnc}"
    read -p "Želiš li unijeti naziv baze i korisnika za ručno brisanje? / Do you want to enter the database and user name for manual deletion? (y/n): " MANUAL
    if [[ "$MANUAL" == "y" ]]; then
        read -p "Naziv baze za brisanje / The name of the database to delete: " DB_TO_DROP
        read -p "Naziv korisnika za brisanje / Username to delete: " USER_TO_DROP
        if [[ -n "$DB_TO_DROP" ]]; then
            FOUND_DB=$(mysql -N -e "SHOW DATABASES LIKE '$DB_TO_DROP';")
            if [[ -n "$FOUND_DB" ]]; then
                mysql -e "DROP DATABASE \`$DB_TO_DROP\`;"
                echo -e "${txtgrn}Baza $DB_TO_DROP obrisana. / Database $DB_TO_DROP deleted.${txtnc}"
            else
                echo -e "${txtred}Baza $DB_TO_DROP nije pronađena. / Database $DB_TO_DROP not found.${txtnc}"
            fi
        fi
        if [[ -n "$USER_TO_DROP" ]]; then
            FOUND_USER=$(mysql -N -e "SELECT user FROM mysql.user WHERE user='$USER_TO_DROP';")
            if [[ -n "$FOUND_USER" ]]; then
                mysql -e "DROP USER IF EXISTS '$USER_TO_DROP'@'localhost';"
                echo -e "${txtgrn}Korisnik $USER_TO_DROP obrisan. / User $USER_TO_DROP deleted.${txtnc}"
            else
                echo -e "${txtred}Korisnik $USER_TO_DROP nije pronađen. / User $USER_TO_DROP not found.${txtnc}"
            fi
        fi
    else
        echo "Brisanje preskočeno. / Deletion skipped."
    fi
fi

echo -e "\n${txtblu}Sada kreiramo NOVOG korisnika i bazu za YetiForce. / Now we create a NEW user and base for YetiForce.${txtnc}"
read -p "Unesite željeni naziv baze / Enter the desired database name: " NEWDB
read -p "Unesite korisničko ime za bazu / Enter a username for the database: " NEWUSER

# Unos i validacija lozinke / Enter and validate password
while true; do
    read -s -p "Unesite lozinku (dozvoljeni karakteri: slova, brojevi, !@#%^&*()-_=+) / Enter password (allowed characters: letters, numbers, !@#%^&*()-_=+): " NEWPASS
    echo
    if validate_password "$NEWPASS"; then
        break
    else
        echo -e "${txtred}Lozinka NE SMIJE sadržavati $, ', \", ili \\ ! Pokušajte ponovo. / Password MUST NOT contain $, ', \", or \\ ! Please try again.${txtnc}"
    fi
done

mysql -e "CREATE DATABASE IF NOT EXISTS \`$NEWDB\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS '$NEWUSER'@'localhost' IDENTIFIED BY '$NEWPASS';"
mysql -e "GRANT ALL PRIVILEGES ON \`$NEWDB\`.* TO '$NEWUSER'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo -e "${txtgrn}Baza '$NEWDB' i korisnik '$NEWUSER' su uspješno kreirani! / Database '$NEWDB' and user '$NEWUSER' have been successfully created!${txtnc}"
