#!/usr/bin/env bash
pkg_list=(php[[:digit:]]. php[[:digit:]].-bz2 php[[:digit:]].-ctype php[[:digit:]].-curl php[[:digit:]].-dba php[[:digit:]].-dom php[[:digit:]].-exif php[[:digit:]].-extensions php[[:digit:]].-fileinfo php[[:digit:]].-filter php[[:digit:]].-ftp php[[:digit:]].-gd php[[:digit:]].-gettext php[[:digit:]].-gmp php[[:digit:]].-hash php[[:digit:]].-iconv php[[:digit:]].-imap php[[:digit:]].-intl php[[:digit:]].-json php[[:digit:]].-mbstring php[[:digit:]].-mysqli php[[:digit:]].-opcache php[[:digit:]].-openssl php[[:digit:]].-pdo php[[:digit:]].-pdo_mysql php[[:digit:]].-pdo_pgsql php[[:digit:]].-pdo_sqlite php[[:digit:]].-pecl-imagick php[[:digit:]].-pecl-memcache php[[:digit:]].-pecl-pdflib php[[:digit:]].-phar php[[:digit:]].-posix php[[:digit:]].-session php[[:digit:]].-simplexml php[[:digit:]].-sockets php[[:digit:]].-sqlite3 php[[:digit:]].-tokenizer php[[:digit:]].-wddx php[[:digit:]].-xml php[[:digit:]].-xmlreader php[[:digit:]].-xmlwriter php[[:digit:]].-xsl php[[:digit:]].-zip php[[:digit:]].-zlib php[[:digit:]].-pecl-mongodb)

for i in ${pkg_list[@]}
do
    now=`pkg info | grep ${i}`
    if [ -z "${now}" ]
        then
            echo "no install $i"
    fi
done

