#!/bin/bash
now=`date +%Y-%m-%d` # Текущая дата 
pg_probackup=/opt/pgpro/std-13/bin/pg_probackup # путь к утелите pg_probackup
pg_ctl=/opt/pgpro/std-13/bin/pg_ctl # Путь к утелите управления кластером
dir_copy=/home/pg_probackup/backup # дириктория с бэкапами
log=/var/lib/postgresql/backup.log # файл логов
echo "start `date`" >> ${log} # записать когда начался процесс загрузки бэкапа
where_restore_id() # Функция для определения свежего id инстанса
{
id=`${pg_probackup} show -B ${dir_copy} | grep ${now} | grep $1 | awk '{print$3}'`
}
port_old () # Функция по определению текущиго порта postgresql
{
port_old=`grep -Eo 54[0-9]{2} ${dir_copy}backups/${instance}/${id}/backup.control`
}

dump_load () # Функия загрузки дампа которой нужно передать параметры
{
instance=${1} # Имя инстанса
dir_out=${2} # Кэда развернуть кластер
conf=${dir_out}/postgresql.conf # Путь к конфигу кластера
where_restore_id ${instance} # Определения свежего id инстанса
port_old # Текущий используемый порт сервером
port_new=${3} # Новый порт на случай поднятия на текущем сервере или несколько копий на отдельном сервере
${pg_ctl} stop -D ${dir_out} -m f # Останавливаем кластер если он существует для перезаливания букапа
sleep 10 # пауза на 10 секунд
rm -rf ${dir_out} # удаление кластера если он существовал
${pg_probackup} restore -B ${dir_copy} -D ${dir_out} -j 1 --no-validate --instance ${instance} -i ${id} # Разворачивание кластера
sed -i -e "s/port = ${port_old}/port = ${port_new}/" -e "s/archive_mode = always/archive_mode = off/" -e "/archive_command/d" ${conf} #изменение порта кластера
${pg_ctl} start -D ${dir_out} # запуск кластера
}

# пример dump_load zup '/var/lib/pgpro/zup-dump1/data' 5437
# пример dump_load trade '/var/lib/pgpro/trade-dump1/data' 5438
# пример dump_load trade '/var/lib/pgpro/trade-dump2/data' 5439
