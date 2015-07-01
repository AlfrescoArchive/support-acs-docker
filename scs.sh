# param1: db type
# param2: tag of the DB
# param3: instance name  (e.g. myalfresco or philalfresco5005)
# param4: image name: e.g. alfresco-5.0.1.a,alfresco5005, alfresco501
# param5: version eg: 5.0.1
# Example: bash ./scs.sh mariadb 10.0.15 toto alfresco-5.0.1.a 5.0.1
#          bash ./scs.sh mysql 5.6.17 titi alfresco-5.0.1.a 5.0.1
#          bash ./scs.sh postgres 9.3.5 titi alfresco-5.0.1.a 5.0.1
echo "You are starting with DB: $1, Instance name: $3, Docker Image: $4"

# create a volume sharing content that can be shared amongst cluster
# Note: Important for upgrade tests. 
#       For upgrades it is important to have a "stateless" deployement of alfresco.
#       Also deploying DB in a separate container.
#       It also make possible clustering testing that needs to share content.
echo "Creating volume /opt/alfresco-$5/alf_data shared under name alf_data-$3"
docker create -v /opt/alfresco-$5/alf_data --name alf_data-$3 $4 /bin/true


if [ "$1" == "mysql" ]; then
    	echo "Starting up with MySQL!"
        export CONTAINER_TO_LINK_TO="MySQL_$3"
        export CONTAINER_TO_LINK_TO_POSTFIXED="$CONTAINER_TO_LINK_TO:mysql"
	docker run --name $CONTAINER_TO_LINK_TO -e MYSQL_ROOT_PASSWORD=alfresco -d mysql:$2
        echo "If there is no database initialized when the container starts, then a default database will be created. While this is the expected "
        echo "behavior, this means that it will not accept incoming connections until such initialization"
        echo "Sleeping 30 secs waiting for initialization !!!" 
        sleep 30
	docker run -i --link $CONTAINER_TO_LINK_TO:mysql --rm mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"' < ./db_scripts/mysql/create.sql
        echo "Database created!"
        export DB_DRIVER='db.driver.EQ.org.gjt.mm.mysql.Driver'
	export DB_HOST='db.host.EQ.MYSQL_PORT_3306_TCP_ADDR'
	export DB_PORT='db.port.EQ.MYSQL_PORT_3306_TCP_PORT'
	export DB_USERNAME='db.username.EQ.alfresco'
	export DB_PASSWORD='db.password.EQ.alfresco'
	export DB_NAME='db.name.EQ.alfresco'
        export DB_URL='db.url.EQ.jdbc:mysql:\/\/${db.host}:${db.port}\/${db.name}?useUnicode=yes&characterEncoding=UTF-8'
        export DB_POOL_VALIDATE='db.pool.validate.query.EQ.select 1'
fi

if [ "$1" == "mariadb" ]; then
    	echo "Starting up with MariaDB!"
        export CONTAINER_TO_LINK_TO="MariaDB_$3"
        export CONTAINER_TO_LINK_TO_POSTFIXED="$CONTAINER_TO_LINK_TO:mysql"
	docker run --name $CONTAINER_TO_LINK_TO -e MYSQL_ROOT_PASSWORD=alfresco -d mariadb:$2
        echo "If there is no database initialized when the container starts, then a default database will be created. While this is the expected "
        echo "behavior, this means that it will not accept incoming connections until such initialization"
        echo "Sleeping 30 secs waiting for initialization !!!" 
        sleep 30
	docker run -i --link $CONTAINER_TO_LINK_TO:mysql --rm mariadb sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"' < ./db_scripts/mariadb/create.sql
        echo "Database created!"
        export DB_DRIVER='db.driver.EQ.org.gjt.mm.mysql.Driver'
	export DB_HOST='db.host.EQ.MYSQL_PORT_3306_TCP_ADDR'
	export DB_PORT='db.port.EQ.MYSQL_PORT_3306_TCP_PORT'
	export DB_USERNAME='db.username.EQ.alfresco'
	export DB_PASSWORD='db.password.EQ.alfresco'
	export DB_NAME='db.name.EQ.alfresco'
        export DB_URL='db.url.EQ.jdbc:mysql:\/\/${db.host}:${db.port}\/${db.name}?useUnicode=yes&characterEncoding=UTF-8'
        export DB_POOL_VALIDATE='db.pool.validate.query.EQ.select 1'
fi

if [ "$1" == "postgres" ]; then
    	echo "Starting up with postgres!"
        export CONTAINER_TO_LINK_TO="Postgres_$3"
        export CONTAINER_TO_LINK_TO_POSTFIXED="$CONTAINER_TO_LINK_TO:postgres"
        docker run --name $CONTAINER_TO_LINK_TO -e POSTGRES_PASSWORD=mysecretpassword -d postgres:$2
        sleep 30  
	docker run -i --link  $CONTAINER_TO_LINK_TO_POSTFIXED --rm postgres sh -c 'export PGPASSWORD=mysecretpassword;exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres' < ./db_scripts/postgres/create.sql
        export DB_DRIVER='org.postgresql.Driver'
	export DB_HOST='db.host.EQ.POSTGRES_PORT_5432_TCP_ADDR'
	export DB_PORT='db.port.EQ.5432'
	export DB_USERNAME='db.username.EQ.postgres'
	export DB_PASSWORD='db.password.EQ.mysecretpassword'
	export DB_NAME='db.name.EQ.alfresco'
        export DB_URL='db.url.EQ.jdbc:postgresql:\/\/${db.host}:${db.port}\/${db.name}'
        export DB_POOL_VALIDATE='db.pool.validate.query.EQ.select 1'
fi

if [ "$1" == "oracle" ]; then
    	echo "Starting up with Oracle!"
        export CONTAINER_TO_LINK_TO="Oracle_$3"
        export CONTAINER_TO_LINK_TO_POSTFIXED="$CONTAINER_TO_LINK_TO"
        docker run --name $CONTAINER_TO_LINK_TO -d  wnameless/oracle-xe-11g
# get the id of the container
        export CONTAINER_ORACLE_ID=`sudo docker ps | grep $CONTAINER_TO_LINK_TO | awk -F" " '{print $1}'`
        echo "CONTAINER_ORACLE_ID:$CONTAINER_ORACLE_ID"
        sleep 60
        echo "Finished sleeping!"
        docker exec  -i $CONTAINER_ORACLE_ID /bin/bash  < ./db_scripts/oracle/create.sql
        export DB_DRIVER='db.driver.EQ.oracle.jdbc.OracleDriver'
#The oracle address in the linked container structure is ORACLE_$3__PORT_1521_TCP_ADDR
        export CONTAINER_TO_LINK_TO_UPPER_CASE="${CONTAINER_TO_LINK_TO^^}"
        export STACK_NAME_TO_UPPER_CASE="${3^^}"
	export DB_HOST="db.host.EQ.ORACLE_${STACK_NAME_TO_UPPER_CASE}_PORT_1521_TCP_ADDR"
        echo "DB_HOST=$DB_HOST"
	export DB_PORT='db.port.EQ.1521'
	export DB_USERNAME='db.username.EQ.alfresco'
	export DB_PASSWORD='db.password.EQ.alfresco'
	export DB_NAME='db.name.EQ.XE'
        export DB_URL='db.url.EQ.jdbc:oracle:thin:@${db.host}:${db.port}:${db.name}'
        export DB_POOL_VALIDATE='db.pool.validate.query.EQ.select 1 from dual'
fi
sleep 5
echo "Starting Alfresco!"
# docker run -t -i -p 8443 --link $CONTAINER_TO_LINK_TO_POSTFIXED --name $3 \
docker run -d -p 8443 --link $CONTAINER_TO_LINK_TO_POSTFIXED --name $3 \
--volumes-from alf_data-$3 \
-d -e INITAL_PASS=admun \
-e ALF_1=mail.host.EQ.smtp.gmail.com \
-e ALF_2=mail.port.EQ.587 \
-e ALF_3=mail.username.EQ.pdubois824@gmail.com \
-e ALF_4=mail.password.EQ.Medira123$ \
-e ALF_5=mail.protocol.EQ.smtp \
-e ALF_6=mail.encoding.EQ.UTF-8 \
-e ALF_7=mail.from.default.EQ.pdubois824@gmail.com \
-e ALF_8=mail.smtp.starttls.enable.EQ.true \
-e ALF_9=mail.smtp.auth.EQ.true \
-e ALF_10=mail.smtp.debug.EQ.false \
-e ALF_11=mail.testmessage.send.EQ.true \
-e ALF_12=mail.testmessage.to.EQ.pdubois824@gmail.com \
-e ALF_13=mail.testmessage.subject.EQ."Outbound SMTP" \
-e ALF_14=mail.testmessage.text.EQ."The Outbound SMTP email subsystem is working." \
-e ALF_15=mail.smtp.socketFactory.port.EQ.587 \
-e ALF_16=mail.smtp.socketFactory.class.EQ.javax.net.ssl.SSLSocketFactory \
-e ALF_17=mail.smtp.socketFactory.fallback.EQ.false \
-e ALF_18=notification.email.siteinvite.EQ.true \
-e ALF_19=share.context.EQ.share \
-e ALF_20=share.host.EQ.localhost \
-e ALF_21=share.port.EQ.8443 \
-e ALF_22=share.protocol.EQ.https \
-e ALF_23=$DB_DRIVER \
-e ALF_24=$DB_HOST \
-e ALF_25=$DB_PORT \
-e ALF_26=$DB_USERNAME \
-e ALF_27=$DB_PASSWORD \
-e ALF_28=$DB_NAME \
-e ALF_29=$DB_URL \
-e ALF_30="$DB_POOL_VALIDATE" \
$4


