chek_replication () 
{
good_Last_IO_Errno=0 # значение что всё в порядке.
good_Last_Errno=0 # значение что всё в порядке.
now_Last_IO_Errno=`mysql -uroot  -e 'SHOW SLAVE STATUS\G' | grep Last_Errno | awk '{print $2}'` # Текущее состояние.
now_Last_Errno=`mysql -uroot  -e 'SHOW SLAVE STATUS\G' | grep Last_IO_Errno | awk '{print $2}'` # Текущее состояние.
now_run=`mysql -uroot  -e 'SHOW SLAVE STATUS\G' | grep Seconds_Behind_Master | awk '{print $2}'` # Текущее отставание реплики.
if [ ${now_Last_IO_Errno} != 2003 ] #  Игнорировать недоступность основного сервера.
 	then
	        if [ "${good_Last_Errno}" != "${now_Last_Errno}" ]
        		then
			echo "recover_replication.sh ${master_db}" # Запустить скрипт перезапуск репликации. 
		fi
		if [ "$good_Last_IO_Errno" != "$now_Last_IO_Errno" ] 
		then
			echo "recover_replication.sh ${master_db}" # Запустить скрипт перезапуск репликации. 
		fi
  
		if [ "$now_run" = "NULL" ]
			then
				mysql -uroot  -e 'START SLAVE' # Если по каким либо причинам реплика была не запущена. Например после перезагрузки реплика автоматически не запускается. 
		fi
fi
}
chek_replication

