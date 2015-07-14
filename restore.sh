# param1: stack name
# param2: version

# stop alfresco if running

export running=`docker inspect -f '{{ .State.Running }}' $1`
if [[ $running == 'true' ]]; then  
    echo "Stoping container name: $1"
    echo "Waiting 10 sec before killing!"
    docker stop --time=10 $1
fi

# empty index and content before restoring
docker run --rm=true -i  --volumes-from $1 ubuntu find /opt/alfresco-$2/alf_data/contentstore/ -mindepth 1 -maxdepth 1 -exec rm -rf {} \;
docker run --rm=true -i  --volumes-from $1 ubuntu find /opt/alfresco-$2/alf_data/solr4/index/ -mindepth 1 -maxdepth 1 -exec rm -rf {} \;


docker run --rm=true -i  --volumes-from $1 -v $(pwd):/backup ubuntu tar xvf /backup/index.tar
docker run --rm=true -i  --volumes-from $1 -v $(pwd):/backup ubuntu tar xvf /backup/content.tar

docker run -i --link MySQL_$1:mysql --rm=true mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"' <<EOF
drop database alfresco;
exit
EOF

docker run -i  --link MySQL_$1:mysql --rm=true mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'<<EOF2  
create database IF NOT EXISTS alfresco default character set utf8 collate utf8_bin;
exit
EOF2

# restore DB
docker run -i --link MySQL_$1:mysql --rm=true mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" alfresco' < ./database.sql 
