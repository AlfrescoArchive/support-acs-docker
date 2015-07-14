# param1: stack name
# param2: version


# stop alfresco if running
export running=`docker inspect -f '{{ .State.Running }}' $1`
echo $running
if [[ $running == 'true' ]]; then  
    echo "Stoping container name: $1"
    echo "Waiting 10 sec before killing!"
    docker stop --time=10 $1
fi


docker run -i --link MySQL_$1:mysql --rm mysql sh -c 'exec mysqldump -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" alfresco' > ./database.sql


docker run --rm=true --volumes-from $1 -v $(pwd):/backup -e stack=$1 -e version=$2 ubuntu tar cvf /backup/index.tar /opt/alfresco-$2/alf_data/solr4/index/


docker run --rm=true --volumes-from $1 -v $(pwd):/backup -e stack=$1 -e version=$2 ubuntu tar cvf /backup/content.tar /opt/alfresco-$2/alf_data/contentstore/



