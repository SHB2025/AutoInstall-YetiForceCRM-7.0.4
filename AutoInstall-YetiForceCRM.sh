#!/bin/bash

txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgre=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
bldwht=${txtbld}$(tput setaf 7) #  white
bldyel=${txtbld}$(tput setaf 11) #  yellow
txtrst=$(tput sgr0)             # Reset
info=${bldyel}*${txtrst}        # Feedback
pass=${bldblu}*${txtrst}
warn=${bldred}*${txtrst}
ques=${bldblu}?${txtrst}

function echoblue () {
  echo "${bldblu}$1${txtrst}"
}
function echored () {
  echo "${bldred}$1${txtrst}"
}
function echogreen () {
  echo "${bldgre}$1${txtrst}"
}
function echoyellow () {
  echo "${bldyel}$1${txtrst}"
}

function download_yeti() {
	wget https://api.yetiforce.eu/download/crm/doc/7.0.4-complete -O YetiForceCRM-7.0.4-complete.zip
}

function update_config() {
	orig=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 1 | head -n 1)
	origparm=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
		if [[ -z $origparm ]];then
			origparm=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 2 | head -n 1)
		fi
	dest=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 1 | head -n 1)
	destparm=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
		if [[ -z $destparm ]];then
			destparm=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 2 | head -n 1)
		fi
case ${dest} in
	\#${orig})
			sed -i "/^$dest.*$destparm/c\\${1}" $2
		;;
	\;${orig})
			sed -i "/^$dest.*$destparm/c\\${1}" $2
		;;
	${orig})
			if [[ $origparm != $destparm ]]; then
				sed -i "/^$orig/c\\${1}" $2
				else
					if [[ -z $(grep '[A-Z\_A-ZA-Z]$origparm' $2) ]]; then
						fullorigparm3=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
						fullorigparm4=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 4 | head -n 1)
						fullorigparm5=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 5 | head -n 1)
						fulldestparm3=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
						fulldestparm4=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 4 | head -n 1)
						fulldestparm5=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 5 | head -n 1)
						sed -i "/^$dest.*$fulldestparm3\ $fulldestparm4\ $fulldestparm5/c\\$orig\ \=\ $fullorigparm3\ $fullorigparm4\ $fullorigparm5" $2
					fi
			fi
		;;
		*)
			echo ${1} >> $2
		;;
	esac
}

clear
RELEASE=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -c18-30)

case "$RELEASE" in
    yammy)
        echoyellow "UBUNTU 22.04  Jammy Jellyfish"
	sleep 2
    ;;
    noble)
        echoyellow "UBUNTU 24.04 Noble Numbat"
	sleep 2
    ;;
    *)
        echored "Unsupported Ubuntu version / Nepodržana verzija Ubuntua."
		echogreen "Supported: Ubuntu Server 22.04 and 24.04 / Podržano: Ubuntu Server 22.04 i 24.04"
	sleep 2
	exit
    ;;
esac

clear
echoyellow "ADJUSTING REPOSITORIES / PRILAGOĐAVANJE REPOZITORIJA"
sleep 2
sed -i 's/\/archive/\/br.archive/g' /etc/apt/sources.list
sed -i 's/\/[a-z][a-z].archive/\/br.archive/g' /etc/apt/sources.list

clear
echoyellow "SETTING LANGUAGE / PODEŠAVANJE JEZIKA"
sleep 2
apt update && apt upgrade -y
apt --force-yes --yes install language-pack-gnome-bs language-pack-bs-base myspell-bs software-properties-common

clear
echoyellow "INSTALLING UNZIP / INSTALACIJA UNZIP-a"
sleep 2
apt update
apt --force-yes --yes install unzip

clear
echoyellow "INSTALLING MYSQL / INSTALACIJA MYSQL"
sleep 2
apt-get update
apt-get --force-yes --yes install mysql-server mysql-client

clear
echoyellow "SETTING MYSQL CONFIGURATION FOR YETIFORCE / PODEŠAVANJE MYSQL KONFIGURACIJE ZA YETIFORCE."

MYSQL_CNF="/etc/mysql/mysql.conf.d/mysqld.cnf"
if [ ! -f "$MYSQL_CNF" ]; then
  MYSQL_CNF="/etc/mysql/mariadb.conf.d/50-server.cnf"
fi

# A true backup / Pravi backup
cp "$MYSQL_CNF" "${MYSQL_CNF}.bak"

# Removes the existing sql_mode if any / Uklanja postojeće sql_mode ako postoji
sed -i '/^\s*sql-mode\s*=.*/d' "$MYSQL_CNF"

# Adds/modifies recommended settings / Dodaje/izmjenjuje preporučene postavke
grep -q "^\[mysqld\]" "$MYSQL_CNF" || echo "[mysqld]" >> "$MYSQL_CNF"

sed -i '/^\[mysqld\]/a \
sql_mode= ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION\
\ncharacter-set-server = utf8mb4\
\ncollation-server = utf8mb4_unicode_ci\
\ndefault-storage-engine = InnoDB\
\ninnodb_file_per_table = 1\
\nmax_allowed_packet = 128M\
\ntmp_table_size = 64M\
\nmax_heap_table_size = 64M\
\nwait_timeout = 600\
\ninteractive_timeout = 600\
\ntable_definition_cache = 4400\
\ninnodb_lock_wait_timeout = 600\
\nconnect_timeout = 60' "$MYSQL_CNF"

# Restart MySQL to apply the changes / Restart MySQL da se promjene primjene
sudo systemctl restart mysql

clear
echoyellow "MYSQL SET UP FOR YETIFORCE / MYSQL PODEŠEN ZA YETIFORCE."

clear
echoyellow "CREATION OF MYSQL BASE AND USERS / KREIRANJE MYSQL BAZE I KORISNIKA"
sleep 2
mysql -u root -e "CREATE USER 'yeti'@'localhost' IDENTIFIED BY 'yeti';"
mysql -u root -e "GRANT ALL PRIVILEGES ON yetiforce.* TO 'yeti'@'localhost' WITH GRANT OPTION;"
mysql -u root -e "CREATE DATABASE yetiforce;"
mysql -u root -e "FLUSH PRIVILEGES"
mysql -u root -e "ALTER DATABASE yetiforce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

clear
echoyellow "INSTALLING PHP AND APACHE / INSTALACIJA PHP-a I APACHE-a"
sleep 2
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y
sudo apt --force-yes --yes install apache2 php8.2 libapache2-mod-php8.2 php8.2-{curl,intl,gd,imagick,apcu,memcache,imap,mysql,ldap,tidy,xmlrpc,pspell,mbstring,xml,gd,intl,bcmath,soap,bz2,zip}
sudo a2enmod rewrite headers expires
sudo systemctl restart apache2

clear
echoyellow "INSTALLING COMPOSER / INSTALACIJA COMPOSER-a"
sleep 2
wget https://getcomposer.org/installer -O composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer

clear
echoyellow "CONFIGURING PHP AND MYSQL / KONFIGURISANJE PHP-a I MYSQL-a"
sleep 2
PHPPATH=/etc/php/8.2/apache2/php.ini
update_config 'allow_url_fopen = "On"' "$PHPPATH"
update_config 'allow_url_include = "Off"' "$PHPPATH"
update_config 'auto_detect_line_endings = "On"' "$PHPPATH"
update_config 'default_charset = "UTF-8"' "$PHPPATH"
update_config "default_socket_timeout = 3600" "$PHPPATH"
update_config "disable_functions = pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_get_handler,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,pcntl_async_signals,pcntl_unshare,shell_exec,exec,system,passthru,popen" "$PHPPATH"
update_config "display_errors = Off" "$PHPPATH"
update_config "display_startup_errors = Off" "$PHPPATH"
update_config "error_log = /var/log/php_error.log" "$PHPPATH"
update_config "error_reporting = E_ALL & ~E_NOTICE" "$PHPPATH"
update_config 'expose_php = "Off"' "$PHPPATH"
update_config 'file_uploads = "On"' "$PHPPATH"
update_config 'html_errors = "On"' "$PHPPATH"
update_config 'log_errors = "On"' "$PHPPATH"
update_config "max_execution_time = 3600" "$PHPPATH"
update_config "max_input_time = 3600" "$PHPPATH"
update_config "max_input_vars = 10000" "$PHPPATH"
update_config "mbstring.func_overload = 0" "$PHPPATH"
update_config "memory_limit = 1024M" "$PHPPATH"
update_config 'mysqlnd.collect_memory_statistics = "Off"' "$PHPPATH"
update_config 'mysqlnd.collect_statistics = "Off"' "$PHPPATH"
update_config 'opcache.enable = "On"' "$PHPPATH"
update_config 'opcache.enable_cli = "On"' "$PHPPATH"
update_config "opcache.fast_shutdown = 1" "$PHPPATH"
update_config "opcache.file_update_protection = 0" "$PHPPATH"
update_config "opcache.interned_strings_buffer = 100" "$PHPPATH"
update_config "opcache.max_accelerated_files = 40000" "$PHPPATH"
update_config "opcache.memory_consumption = 256" "$PHPPATH"
update_config "opcache.revalidate_freq = 0" "$PHPPATH"
update_config "opcache.save_comments = 0" "$PHPPATH"
update_config "opcache.validate_timestamps = 1" "$PHPPATH"
update_config "openssl.cafile=/etc/ssl/certs/ca-certificates.crt" "$PHPPATH"
update_config "openssl.capath=/etc/ssl/certs/" "$PHPPATH"
update_config 'output_buffering = "On"' "$PHPPATH"
update_config "post_max_size = 100M" "$PHPPATH"
update_config "realpath_cache_size = 4096k" "$PHPPATH"
update_config "realpath_cache_ttl = 600" "$PHPPATH"
update_config 'request_order = "GP"' "$PHPPATH"
update_config 'session.auto_start = "Off"' "$PHPPATH"
update_config 'session.cookie_httponly = "On"' "$PHPPATH"
update_config "session.gc_divisor = 500" "$PHPPATH"
update_config "session.gc_maxlifetime = 1440" "$PHPPATH"
update_config "session.gc_probability = 1" "$PHPPATH"
update_config 'session.name = "YTSID"' "$PHPPATH"
update_config 'session.use_only_cookies = "On"' "$PHPPATH"
update_config 'session.use_strict_mode = "On"' "$PHPPATH"
update_config 'session.use_trans_sid = "Off"' "$PHPPATH"
update_config 'short_open_tag = "On"' "$PHPPATH"
update_config "upload_max_filesize = 100M" "$PHPPATH"
update_config "user_ini.filename = " "$PHPPATH"
update_config 'variables_order = "GPCS"' "$PHPPATH"
update_config 'zlib.output_compression = "Off"' "$PHPPATH"
update_config "open_basedir = /var/www/html/yeti" "$PHPPATH"
PHPPATH=/etc/php/8.2/cli/php.ini
update_config 'allow_url_fopen = "On"' "$PHPPATH"
update_config 'allow_url_include = "Off"' "$PHPPATH"
update_config 'auto_detect_line_endings = "On"' "$PHPPATH"
update_config 'default_charset = "UTF-8"' "$PHPPATH"
update_config "default_socket_timeout = 3600" "$PHPPATH"
update_config "disable_functions = pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_get_handler,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,pcntl_async_signals,pcntl_unshare,shell_exec,exec,system,passthru,popen" "$PHPPATH"
update_config "display_errors = Off" "$PHPPATH"
update_config "display_startup_errors = Off" "$PHPPATH"
update_config "error_log = /var/log/php_error.log" "$PHPPATH"
update_config "error_reporting = E_ALL & ~E_NOTICE" "$PHPPATH"
update_config 'expose_php = "Off"' "$PHPPATH"
update_config 'file_uploads = "On"' "$PHPPATH"
update_config 'html_errors = "On"' "$PHPPATH"
update_config 'log_errors = "On"' "$PHPPATH"
update_config "max_execution_time = 3600" "$PHPPATH"
update_config "max_input_time = 3600" "$PHPPATH"
update_config "max_input_vars = 10000" "$PHPPATH"
update_config "mbstring.func_overload = 0" "$PHPPATH"
update_config "memory_limit = 1024M" "$PHPPATH"
update_config 'mysqlnd.collect_memory_statistics = "Off"' "$PHPPATH"
update_config 'mysqlnd.collect_statistics = "Off"' "$PHPPATH"
update_config 'opcache.enable = "On"' "$PHPPATH"
update_config 'opcache.enable_cli = "On"' "$PHPPATH"
update_config "opcache.fast_shutdown = 1" "$PHPPATH"
update_config "opcache.file_update_protection = 0" "$PHPPATH"
update_config "opcache.interned_strings_buffer = 100" "$PHPPATH"
update_config "opcache.max_accelerated_files = 40000" "$PHPPATH"
update_config "opcache.memory_consumption = 256" "$PHPPATH"
update_config "opcache.revalidate_freq = 0" "$PHPPATH"
update_config "opcache.save_comments = 0" "$PHPPATH"
update_config "opcache.validate_timestamps = 1" "$PHPPATH"
update_config "openssl.cafile=/etc/ssl/certs/ca-certificates.crt" "$PHPPATH"
update_config "openssl.capath=/etc/ssl/certs/" "$PHPPATH"
update_config 'output_buffering = "On"' "$PHPPATH"
update_config "post_max_size = 100M" "$PHPPATH"
update_config "realpath_cache_size = 4096k" "$PHPPATH"
update_config "realpath_cache_ttl = 600" "$PHPPATH"
update_config 'request_order = "GP"' "$PHPPATH"
update_config 'session.auto_start = "Off"' "$PHPPATH"
update_config 'session.cookie_httponly = "On"' "$PHPPATH"
update_config "session.gc_divisor = 500" "$PHPPATH"
update_config "session.gc_maxlifetime = 1440" "$PHPPATH"
update_config "session.gc_probability = 1" "$PHPPATH"
update_config 'session.name = "YTSID"' "$PHPPATH"
update_config 'session.use_only_cookies = "On"' "$PHPPATH"
update_config 'session.use_strict_mode = "On"' "$PHPPATH"
update_config 'session.use_trans_sid = "Off"' "$PHPPATH"
update_config 'short_open_tag = "On"' "$PHPPATH"
update_config "upload_max_filesize = 100M" "$PHPPATH"
update_config "user_ini.filename = " "$PHPPATH"
update_config 'variables_order = "GPCS"' "$PHPPATH"
update_config 'zlib.output_compression = "Off"' "$PHPPATH"
update_config "open_basedir = /var/www/html/yeti" "$PHPPATH"
touch /var/log/php_error.log
chmod 777 /var/log/php_error.log

clear
echoyellow "DOWNLOADING YETIFORCE / PREUZIMANJE YETIFORCE"
sleep 2
mkdir -p /var/www/html/yeti
cd /var/www/html/yeti
FILE=0
while [[ $FILE -lt 51460 ]]
do
download_yeti
if [[ -e /var/www/html/yeti/YetiForceCRM-7.0.4-complete.zip ]]
then
FILE=$(du --threshold=M /var/www/html/yeti/YetiForceCRM-7.0.4-complete.zip | cut -f 1)
else
FILE=0
fi
if [[ $FILE -gt 51460 ]]
then
	echoyellow "DOWNLOAD COMPLETED / PREUZIMANJE ZAVRŠENO"
	break
fi
echored "DOWNLOAD FAILED, STARTING AGAIN / PREUZIMANJE NIJE NEUSPELO, PONOVNO POČINJETE"
FILE=0
rm -rf /var/www/html/yeti/YetiForceCRM-7.0.4-complete.zip
done
unzip YetiForceCRM-7.0.4-complete.zip
rm -rf /var/www/html/yeti/YetiForceCRM-7.0.4-complete.zip
mkdir -p /var/www/html/yeti/config/Modules

clear
echoyellow "RUNNING COMPOSER / RUNNING COMPOSER"
sleep 2
cd /var/www/html/yeti
composer install

clear
echoyellow "ADJUSTING APACHE AND PHP / PRILAGOĐAVANJE APACHE-a I PHP-a"
sleep 2
cat << APADEF > /etc/apache2/sites-available/yeti.conf

<IfModule mod_ssl.c>
    <VirtualHost _default_:443>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/yeti/public_html

        <Directory /var/www/html/yeti>
            Options -Indexes +FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        SSLEngine on
        SSLCertificateFile      /etc/ssl/certs/ssl-cert-snakeoil.pem
        SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

        <FilesMatch "\.(cgi|shtml|phtml|php)$">
            SSLOptions +StdEnvVars
        </FilesMatch>

        <Directory /usr/lib/cgi-bin>
            SSLOptions +StdEnvVars
        </Directory>

        <IfModule mod_headers.c>
            Header always set Referrer-Policy "no-referrer"
            Header always set X-Frame-Options "SAMEORIGIN"
            Header always set X-Content-Type-Options "nosniff"
            Header always set X-Robots-Tag "none"
            Header always set X-Permitted-Cross-Domain-Policies "none"
            Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
            Header always set Expect-CT "enforce; max-age=3600"
            Header always set Access-Control-Allow-Methods "GET, POST"
            Header always set Access-Control-Allow-Origin "*"
        </IfModule>

    </VirtualHost>
</IfModule>

APADEF

mv /var/www/html/index.html /var/www/html/index.html.old

cat << INDEX2 > /var/www/html/index.html
<html>
<head>
<title>YETIFORCE</title>
</head>
<body>
</body>
<script type="text/javascript">
var loc = window.location.href+'';
if (loc.indexOf('http://')==0){
    window.location.href = loc.replace('http://','https://');
}
</script>
</html>

INDEX2

clear
echogreen "GRANT PERMISSIONS TO /VAR/WWW/HTML / DODJELA PERMISIJA NA /VAR/WWW/HTML"
chown -v -R www-data:www-data /var/www/html;
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;
a2enmod ssl rewrite
a2dissite default-ssl
a2ensite yeti
/etc/init.d/apache2 restart
/etc/init.d/mysql restart

clear
echogreen "ENABLE HEADER MODULE AND ADD SECURITY HEADERS TO VIRTUALHOST / OMOGUĆITE MODUL ZAGLAVLJA I DODAJTE SIGURNA ZAGLAVLJA U VIRTUALHOST"
a2enmod headers

clear
echogreen "Hide Apache version info / Sakrij informacije o verziji Apachea"
echo -e "
ServerSignature Off
ServerTokens Prod" >> /etc/apache2/apache2.conf

clear
echogreen "Restart Apache to apply all changes / Ponovo pokrenite Apache da primijenite sve promjene"
systemctl restart apache2

clear
echogreen "INSTALLATION COMPLETE, YETIFORCE INSTALLED, ACCESS THROUGH YOUR WEB BROWSER AT https://$(ip addr show | grep 'inet ' | grep brd | tr -s ' ' '|' | cut -d '|' -f 3 | cut -d '/' -f 1 | head -n 1) A MYSQL DATABASE HAS ALREADY BEEN CREATED ON HOST:localhost PORT:3306 NAME:yetiforce USER:yeti PASSWORD:yeti"
echogreen "INSTALACIJA KOMPLETNA, YETIFORCE INSTALIRAN, PRISTUP KROZ VAŠ WEB Browser NA https://$(ip addr show | grep 'inet ' | grep brd | tr -s ' ' '|' | cut -d '|' -f 3 | cut -d '/' -f 1 | head -n 1) | BAZA PODATAKA JE VEĆ KREIRANA NA HOST:localhost PORT:3306 IME:yetiforce KORISNIK:yeti LOZINKA:yeti"

echoyellow "=== Bosanski ==="
echogreen "NAPOMENA: Radi povećanja sigurnosti, preporučuje se kreiranje SQL baze i SQL korisnika sa nestandardnim nazivom i lozinkom."
echogreen "Za ovaj proces možete koristiti već pripremljenu skriptu 'yetiforce_db_setup.sh', koja će olakšati postavljanje baze."
echogreen "Ova radnja treba biti izvršena nakon pokretanja skripte 'AutoInstall-YetiForceCRM.sh', a prije početka finalnog procesa instalacije putem Web GUI."

echoyellow "=== English ==="
echogreen "NOTE: To enhance security, it is recommended to create an SQL database and an SQL user with a non-standard name and password."
echogreen "For this process, you can use the pre-prepared script 'yetiforce_db_setup.sh', which will facilitate database setup."
echogreen "This action should be performed after running the script 'AutoInstall-YetiForceCRM.sh' and before starting the final installation process via Web GUI."
