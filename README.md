# Alfresco on docker


Scripts helping to generate and run `alfresco` stacks on docker. The goal is to quickly get up an running those stacks.

## Description


The design is based on specializing containers forming together a stack running `alfresco`. It also uses the concept of [linking containers together](https://docs.docker.com/userguide/dockerlinks/) and [docker volumes](https://docs.docker.com/userguide/dockervolumes/).
If you do not want to install `docker` directly on your local machine you have the possibility to install docker inside a virtual machine (tested on ubunu 14.0.4 LTS). Specializing containers offers required flexibility in terms of testing, upgrading and deploying stacks. The container running `alfresco` is stateless making possible its replacement while upgrading or reconfiguring.

At this moment a stack is composed so far of:

   1. A specialized container dedicated to content storage. Content will be stored into this paticular container and keep separate from the container that will be used to run `alfresco`. This container will expose a volume to other containers. This container will be build from the same image running `alfresco` but won't be "running" in the "common" sense. This container is used to share data amongst containers forming a stack. It will also be useful for deploying clusters in the future.
   2. A database container running the required database flavor and version. The image will be pulled automatically from [docker hub](https://registry.hub.docker.com) if not present in your local repository. The databases supported so far in this project are [MySQL](https://registry.hub.docker.com/_/mysql/tags/manage/), [Postgres](https://registry.hub.docker.com/_/postgres/tags/manage/), [MariaDB](https://registry.hub.docker.com/_/mariadb/tags/manage/) and [oracle 11g](https://registry.hub.docker.com/u/wnameless/oracle-xe-11g/)  
   3. A container running an `alfresco` instance. This container will link to 2. and mount the volume published on 1. 
   
To run a stack to phases are applied:
  A. Generate the necessary files and scripts for image building.
  B. Generate the docker image from the generated files.
  C. Running the stack using the generated file in A.
 
## Project structure


./db_scripts/&lt;db dialect&gt;/create.sql: contains the DB creation scrips organized by dialect.

./installers/alfresco-enterprise-&lt;version&gt;-installer-linux-x64: contains the installers.

./jdbcs/&lt;versions>/&lt;jdbc jar&gt;: contains the jdbcs organized by version. All the jars for a given version are located in the same folder.

./licenses/&lt;version>/&lt;license files&gt;: contains the *.lic files organized by versions. I.e: ./licenses/5.0.0.5/Alfresco-ent50-AlfrescoInternalPhilippeDubois50.lic

./modeules/server: contains the server tier modules that will be installed

./modules/share: contains the share tier modules that will be installed

./templates/ : contains a generic version of Dockerfile. The &#95;&#95;version&#95;&#95; place holder will be replaced by the actual version during the generation phase.

./generated : contains the files generated during the generate phase.

Note: Licences and installers are not checked in the project.

## Generating


To generate for s specific `alfresco` version, use: ./generate.sh &lt;version&gt;

Example: 

./generate.sh 5.0.1

## Building the image

docker build -t &lt;image name&gt; ./generated



## Running the stack


./scs.sh &lt;param1> &lt;param2&gt; &lt;param3&gt; &lt;param4&gt; &lt;param5&gt;

Prameter description:

*  param1: db type
*  param2: tag of the DB
*  param3: instance name  (e.g. myalfresco or philalfresco5005)
*  param4: image name: e.g. alfresco-5.0.1.a,alfresco5005, alfresco501
*  param5: version eg: 5.0.1
  
Examples: 

* `bash ./scs.sh mariadb 10.0.15 toto alfresco-5.0.1.a 5.0.1`
* `bash ./scs.sh mysql 5.6.17 titi alfresco-5.0.1.a 5.0.1`
* `bash ./scs.sh postgres 9.3.5 titi alfresco-5.0.1.a 5.0.1`
* `bash ./scs.sh oracle 11g titi alfresco-5.0.1.a 5.0.1`

Note: only oracle 11g is available

## Verifying that your stack is up and running

```

$sudo docker ps
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                     NAMES
42bb34baae8c        alfresco5011        "/bin/sh -c '/entry.   45 minutes ago      Up 45 minutes       0.0.0.0:32771->8443/tcp   deamon
54dadba305ea        postgres:9.3.5      "/docker-entrypoint.   45 minutes ago      Up 45 minutes       5432/tcp                  Postgres_deamon
``` 
 
 You can observe that 2 containers are runnig, `42bb34baae8c` is used to run `alfresco`, `54dadba305ea` is used to to run `postgres`
 
### Ho can I connect to my alfresco instance using browser?

From the above output, you can observe that alfresco ssl port 8443 is mapped to port 32771 on your host. By browing "https://<your host>:32771/share you will get login to share.

### How can I obtain full information set in json of my running containsers?

```

$ sudo docker inspect 42bb34baae8c
[
{
    "Id": "42bb34baae8cabaf0ec9457082384349c1dc587a5084cdf0a0a46356afb87ab1",
    "Created": "2015-07-01T01:34:08.8153281Z",
    "Path": "/bin/sh",
    "Args": [
        "-c",
        "/entry.sh;/opt/alfresco-5.0.1/alfresco.sh start;while true; do ps -a; sleep 5; done"
    ],
    "State": {
        "Running": true,
        "Paused": false,
        "Restarting": false,
        "OOMKilled": false,
        "Dead": false,
        "Pid": 49638,
        "ExitCode": 0,
        "Error": "",
        "StartedAt": "2015-07-01T01:34:09.342686165Z",
        "FinishedAt": "0001-01-01T00:00:00Z"
    },
    "Image": "27ae52d443b5408ff2179d8886983ad617065385eb376dd244d85f6f64edd770",
    "NetworkSettings": {
        "Bridge": "",
 "LinkLocalIPv6PrefixLen": 0,
        "MacAddress": "02:42:ac:11:00:a6",
        "NetworkID": "cd84417120e19444a38d653f24d73ae1a36bc55cdd3453196bfec02274ccc836",
        "PortMapping": null,
        "Ports": {
            "8443/tcp": [
                {
                    "HostIp": "0.0.0.0",
                    "HostPort": "32771"
                }
            ]
        },
        "SandboxKey": "/var/run/docker/netns/42bb34baae8c",
        "SecondaryIPAddresses": null,
        "SecondaryIPv6Addresses": null
    },

...

            "ALF_28=db.name.EQ.alfresco",
            "ALF_29=db.url.EQ.jdbc:postgresql:\\/\\/${db.host}:${db.port}\\/${db.name}",
            "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        ],
        "Cmd": null,
        "Image": "alfresco5011",
        "Volumes": null,
        "VolumeDriver": "",
        "WorkingDir": "",
        "Entrypoint": [
            "/bin/sh",
            "-c",
            "/entry.sh;/opt/alfresco-5.0.1/alfresco.sh start;while true; do ps -a; sleep 5; done"
        ],
        "NetworkDisabled": false,
        "MacAddress": "",
        "OnBuild": null,
        "Labels": {}
    }
}
]
```


 
### How to connect to the alfresco container using using shell command on a TTY?
 
  `$ sudo docker exec -i -t 42bb34baae8c /bin/bash`
  
 `[sudo] password for philippe:`
  
 `root@42bb34baae8c:/# ps -eaf`
 
 `UID        PID  PPID  C STIME TTY          TIME CMD`
 
 `root         1     0  0 01:34 ?        00:00:00 /bin/sh -c /entry.sh;/opt/alfresco-5.0.1/alfresco.sh start;while true; do ps -a; sleep 5; done`
 
 `root       515     1 19 01:35 ?        00:12:29 /opt/alfresco-5.0.1/java/bin/java -Djava.util.logging.config.file=/opt/alfresco-5.0.1/tomcat/conf/logging.properties -Djava.util.lo`
 
 `root       647   515  0 01:36 ?        00:00:07 /opt/alfresco-5.0.1/libreoffice/program/.soffice.bin --accept=socket,host=127.0.0.1,port=8100;urp; -env:UserInstallation=file:///op`
 
 `root      2595     0  0 02:38 ?        00:00:00 /bin/bash`
 
 `root      2611     1  0 02:38 ?        00:00:00 sleep 5`
 
 `root      2612  2595  0 02:38 ?        00:00:00 ps -eaf`

 You can observe that an alfresco process it up and running 

## Disk space management, caveat!!

Using docker and creating many containers might be space consuming even if containers are stopped and deleted. The solution is to use the option **_-v_** when removing containers in order to recuperate disk space space.

Example:

```

philippe@ubuntu:~/on-docker-mogwaii3/on-docker$ sudo bash ./scs.sh mariadb 10.0.15 iphone5 alfresco5014 5.0.1
[sudo] password for philippe: 
You are starting with DB: mariadb, Instance name: iphone5, Docker Image: alfresco5014
Creating volume /opt/alfresco-5.0.1/alf_data shared under name alf_data-iphone5
86a21bcf231d2a3b9c1a8881db78798f7f16ccf29a9450b1a968001aaad9f785
Starting up with MariaDB!
5e6f80fc2bd8b5951a45c2e007c155c688fe74818ae04dfc75710bc91d5bb541
If there is no database initialized when the container starts, then a default database will be created. While this is the expected 
behavior, this means that it will not accept incoming connections until such initialization
Sleeping 30 secs waiting for initialization !!!
Database
information_schema
mysql
performance_schema
Database
alfresco
information_schema
mysql
performance_schema
Database created!
Starting Alfresco!
d7c22b29e94ebf98ef4f0ef90cd0741ad4700b63cb995edee442f646d6652b03
philippe@ubuntu:~/on-docker-mogwaii3/on-docker$ sudo docker ps -a
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                     NAMES
d7c22b29e94e        alfresco5014        "/bin/sh -c '/entry.   15 seconds ago      Up 14 seconds       0.0.0.0:32798->8443/tcp   iphone5             
5e6f80fc2bd8        mariadb:10.0.15     "/docker-entrypoint.   50 seconds ago      Up 50 seconds       3306/tcp                  MariaDB_iphone5     
86a21bcf231d        alfresco5014        "/bin/sh -c '/entry.   51 seconds ago                                                    alf_data-iphone5    
philippe@ubuntu:~/on-docker-mogwaii3/on-docker$ 
philippe@ubuntu:~/on-docker-mogwaii3/on-docker$ sudo docker stop d7c22b29e94e 5e6f80fc2bd8
d7c22b29e94e
5e6f80fc2bd8
philippe@ubuntu:~/on-docker-mogwaii3/on-docker$ sudo docker rm -v 86a21bcf231d 5e6f80fc2bd8 d7c22b29e94e
86a21bcf231d
5e6f80fc2bd8
d7c22b29e94e
```

Why is is necessary to use the **_-v_** option?
The explanation can be found [here](https://docs.docker.com/userguide/dockervolumes/)

Please note paragraph “Creating and mounting a data volume container” and the note that is associated to. (see also: [pull request #8484](https://github.com/docker/docker/pull/8484 ))


### Where are your index and content located and how to find it in your file system?

Answer: 

Your content and index are located in a “data volume” in when the “stack” is started using command “/scs.sh” ommiting options $6 and $7 (ommiting $6 and $7 is ommiting any preferate location). Data volume are containers
dedicated to data storage. The choice made in this project is to not run data volumes, they are created using the "docker create" command. To understand more about data volumes, please refer to [docker volumes](https://docs.docker.com/userguide/dockervolumes/)

Assume that you have a running stack:

```

$ sudo docker ps -a
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                     NAMES
7b1431672f5a        alfresco5013        "/bin/sh -c '/entry.   About an hour ago   Up About an hour    0.0.0.0:32824->8443/tcp   garlic              
5873c7f73e1b        postgres:9.3.5      "/docker-entrypoint.   About an hour ago   Up About an hour    5432/tcp                  Postgres_garlic     
c09fedb3135d        alfresco5013        "/bin/sh -c '/entry.   About an hour ago                                                 alf_data-garlic     
root@ubuntu:/var/lib/docker# 
```

Searching for the volumes used by your “alfresco” container being part of the running stack can be done as follows:

```

$ sudo docker inspect -f {{.Volumes}} 7b1431672f5a
map[/opt/alfresco-5.0.1.3/alf_data/solr4/index:/var/lib/docker/volumes/f127e8b86b306fd9c0a87a6b5b91427ef9f166823e9b92a5dd2ff26b2f109ea3/_data /opt/alfresco-5.0.1.3/alf_data/contentstore:/var/lib/docker/volumes/32cbfe33e0e9dfbbd862cea89fa963e8ad78f11368d0eb216fe8911ff4df3ca0/_data]
```

Alternatively, the container name “garlic” to identify the volumes location on disk.

```

$ sudo docker inspect -f {{.Volumes}} garlic
map[/opt/alfresco-5.0.1.3/alf_data/contentstore:/var/lib/docker/volumes/32cbfe33e0e9dfbbd862cea89fa963e8ad78f11368d0eb216fe8911ff4df3ca0/_data /opt/alfresco-5.0.1.3/alf_data/solr4/index:/var/lib/docker/volumes/f127e8b86b306fd9c0a87a6b5b91427ef9f166823e9b92a5dd2ff26b2f109ea3/_data]
```

You can observe that /opt/alfresco-5.0.1.3/alf_data/solr4/index from inside your container is mapped to /var/lib/docker/volumes/f127e8b86b306fd9c0a87a6b5b91427ef9f166823e9b92a5dd2ff26b2f109ea3/_data

and 

/opt/alfresco-5.0.1.3/alf_data/contentstore

is mapped to /var/lib/docker/volumes/32cbfe33e0e9dfbbd862cea89fa963e8ad78f11368d0eb216fe8911ff4df3ca0/_data


It can also be cross checked by doing the “ls” ot the 2 directories:

```

$ ls -la /var/lib/docker/volumes/f127e8b86b306fd9c0a87a6b5b91427ef9f166823e9b92a5dd2ff26b2f109ea3/_data
total 16
drwxr-xr-x 4 root root 4096 Jul  4 00:55 .
drwxr-xr-x 3 root root 4096 Jul  4 00:54 ..
drwxr-xr-x 3 root root 4096 Jul  4 00:55 archive
drwxr-xr-x 3 root root 4096 Jul  4 00:55 workspace
```

```

$ ls -la /var/lib/docker/volumes/32cbfe33e0e9dfbbd862cea89fa963e8ad78f11368d0eb216fe8911ff4df3ca0/_data
total 12
drwxr-xr-x 3 root root 4096 Jul  4 00:57 .
drwxr-xr-x 3 root root 4096 Jul  4 00:54 ..
drwxr-xr-x 3 root root 4096 Jul  4 00:57 2015
```

### How content and index can be on different locations?

It is common with Alfresco to locate index on fast local disk and content on slower network drives. The specific locations can be 
specified respectively by providing optional parameters $6 and $7

Example:

```

# sudo bash ./scs.sh postgres 9.3.5 carot alfresco5013 5.0.1.3 /home/philippe/my_content_store /home/philippe/my_index
```

In the example above, the index will be located under  “/home/philippe/my_index” and the content will be located under “/home/philippe/my_index”.

Note: If you decide to remove the “alfresco” container or the “content container” referencing “/home/philippe/my_index” and “/home/philippe/my_index” using “sudo rm -v <container name or container location>”, data in it will be preserved.


## Installion guide of docker on RHEL 7.1

### installing docker

Complete description for docker installation can be found here: https://access.redhat.com/articles/881893 and here https://docs.docker.com/installation/rhel/

  `# sudo subscription-manager register --username=rhnuser --password=rhnpasswd`
 
  `# sudo subscription-manager list --available  Find pool ID for RHEL subscription`
 
  `# sudo subscription-manager attach --pool=pool_id`
 
  `# sudo subscription-manager repos --enable=rhel-7-server-extras-rpms`
 
  `# sudo subscription-manager repos --enable=rhel-7-server-optional-rpms`
 
  `# sudo suyum install docker docker-registry`
 
  `# sudo yum install device-mapper-libs device-mapper-event-libs`
 
  `# sudo systemctl stop firewalld.service`
  
  `# sudo systemctl disable firewalld.service`
  
Start docker:

  `# sudo systemctl start docker.service`
  
Enable docker:
  `# sudo systemctl enable docker.service`

Check docker status:

  `# sudo systemctl status docker.service`

You should see the following output:

    docker.service - Docker Application Container Engine
       Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled)
       Active: active (running) since Thu 2014-10-23 11:32:11 EDT; 14s ago
         Docs: http://docs.docker.io
     Main PID: 2068 (docker)
       CGroup: /system.slice/docker.service
               └─2068 /usr/bin/docker -d --selinux-enabled -H fd://
    ...


Testing installation :

  `sudo docker run ubuntu /bin/echo hello world`
  

### Installing git :

  `sudo yum install git`
  
### Checking out the project :

  `git clone https://<your git uid>:<your git credentials>@github.com/Alfresco/on-docker.git`
  


## Possible developments


* Deploy on the cloud allowing different providers, see: [tutum](https://www.tutum.co/) and [deploying alfresco with tutum](https://registry.hub.docker.com/u/pdubois/docker-alfresco/)
* Automate more complex deployments. i.e. clustering, sso, separate solr servers, ...
* Using [docker compose](https://docs.docker.com/compose/) and [yml](https://tutum.freshdesk.com/support/solutions/articles/5000583471) 

