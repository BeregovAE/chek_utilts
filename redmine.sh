#!/usr/bin/env bash
domain=redmine.unixskills.ru
dbhost=localhost
gen_pass ()
{
echo "генерация пароля для пользователя баз данны"
pass=`date +%s | sha256 | base64 | head -c 32`
read -p "Нажмите ENTER для продолжения"
echo $pass > /root/redmine.pass
}

create_db ()
{
echo "Создание пользователя redmine"
echo psql -Upostgres -c "CREATE ROLE redmine LOGIN ENCRYPTED PASSWORD "\'${pass}\'" NOINHERIT VALID UNTIL 'infinity';"
psql -Upostgres -c "CREATE ROLE redmine LOGIN ENCRYPTED PASSWORD "\'${pass}\'" NOINHERIT VALID UNTIL 'infinity';"
read -p "Нажмите ENTER для продолжения"
echo 'psql -Upostgres -c "CREATE DATABASE redmine WITH ENCODING='UTF8' OWNER=redmine;"'
psql -Upostgres -c "CREATE DATABASE redmine WITH ENCODING='UTF8' OWNER=redmine;"
read -p "Нажмите ENTER для продолжения"
}

pkg_install ()
{
echo "обновим пакеты и порты"
read -p "Нажмите ENTER для продолжения"
echo "pkg upgrade -y && portsanp auto"
pkg upgrade -y && portsnap auto
echo "установка пакетов"
read -p "Нажмите ENTER для продолжения"
echo "pkg install nginx redmine42"
pkg install -y nginx redmine42
read -p "Нажмите ENTER для продолжения"
echo "подключаем поддержку postgresql"
echo "cd /usr/ports/www/redmine42 && make OPTIONS_FILE_SET+=POSTGRESQL missing"
read -p "Нажмите ENTER для продолжения"
cd /usr/ports/www/redmine42 && make OPTIONS_FILE_SET+=POSTGRESQL missing
echo "устанавливаем недостающие пакеты"
read -p "Нажмите ENTER для продолжения"
echo "pkg install -y `make OPTIONS_FILE_SET+=POSTGRESQL missing`"
read -p "Нажмите ENTER для продолжения"
pkg install -y `make OPTIONS_FILE_SET+=POSTGRESQL missing`
read -p "Нажмите ENTER для продолжения"
echo "собираем порт чтобы включить поддержку postgreslq"
read -p "Нажмите ENTER для продолжения"
echo "make OPTIONS_FILE_SET+=POSTGRESQL BATCH=yes deinstall install clean"
make OPTIONS_FILE_SET+=POSTGRESQL BATCH=yes deinstall install clean
read -p "Нажмите ENTER для продолжения"
}


db_connect ()
{
echo "настройка подключенния к базе"
cat  << EOF > /usr/local/www/redmine/config/database.yml
production:
  adapter: postgresql
  database: redmine
  host: $dbhost
  port: 5432
  username: redmine
  password: "$pass"
  encoding: utf8
EOF
echo "cat  << EOF > /usr/local/www/redmine/config/database.yml"
cat /usr/local/www/redmine/config/database.yml
echo EOF
}

redmine_load ()
{
echo "первоначальная настройка приложения"
read -p "Нажмите ENTER для продолжения"
echo "cd /usr/local/www/redmine/"
cd /usr/local/www/redmine/
read -p "Нажмите ENTER для продолжения"
echo "rake generate_secret_token"
rake generate_secret_token
read -p "Нажмите ENTER для продолжения"
echo "rake db:migrate RAILS_ENV=production"
rake db:migrate RAILS_ENV=production
read -p "Нажмите ENTER для продолжения"
echo "rake redmine:load_default_data RAILS_ENV=production REDMINE_LANG=ru"
rake redmine:load_default_data RAILS_ENV=production REDMINE_LANG=ru
read -p "Нажмите ENTER для продолжения"
echo "rake tmp:cache:clear RAILS_ENV=production"
rake tmp:cache:clear RAILS_ENV=production
read -p "Нажмите ENTER для продолжения"
echo "service redmine enable"
service redmine enable
read -p "Нажмите ENTER для продолжения"
echo "service redmine start"
service redmine start
read -p "Нажмите ENTER для продолжения"

}

nginx_conf ()
{
echo "настройка nginx"
read -p "Нажмите ENTER для продолжения"
echo "cat << EOF > /usr/local/etc/nginx/nginx.conf"
cat << EOF > /usr/local/etc/nginx/nginx.conf
worker_processes  auto;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    gzip  on;
    include conf.d/*.conf;
}
EOF
cat  /usr/local/etc/nginx/nginx.conf
echo "EOF"
read -p "Нажмите ENTER для продолжения"
echo "mkdir /usr/local/etc/nginx/conf.d"
mkdir /usr/local/etc/nginx/conf.d
read -p "Нажмите ENTER для продолжения"
echo "cat  << EOF > /usr/local/etc/nginx/conf.d/redmine.conf"
cat  << EOF > /usr/local/etc/nginx/conf.d/redmine.conf
upstream redmine {
    server 127.0.0.1:3000;
}
server {
    listen 80;
    server_name $domain;
        location / {
        proxy_pass http://redmine;
        proxy_send_timeout 300;
        proxy_read_timeout 300;
        send_timeout 300;
                }
}
EOF
cat /usr/local/etc/nginx/conf.d/redmine.conf
echo "EOF"
read -p "Нажмите ENTER для продолжения"
echo "service nginx enable"
service nginx enable
read -p "Нажмите ENTER для продолжения"
echo "service nginx start"
service nginx start
read -p "Нажмите ENTER для продолжения"
}

finish ()
{
echo "установка завершена."
}

main ()
{
gen_pass
create_db
pkg_install
db_connect
redmine_load
nginx_conf
finish
}
main
