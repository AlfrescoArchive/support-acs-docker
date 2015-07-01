# Alfresco on docker


Scripts helping to generate and run `alfresco` stacks on docker. The goal is to quickly get up an running those stacks.

## Description


The design is based on specializing containers forming together a stack running `alfresco`. It also uses the concept of [linking containers together](https://docs.docker.com/userguide/dockerlinks/) and [docker volumes](https://docs.docker.com/userguide/dockervolumes/).
If you do not want to install `docker` directly on your local machine you have the possibility to install docker inside a virtual machine (tested on ubunu 14.0.4 LTS). Specializing containers offers required flexibility in terms of testing, upgrading and deploying stacks. The container running `alfresco` is stateless making possible its replacement while upgrading or reconfiguring.

At this moment a stack is composed so far of:

   1. A specialized container dedicated to content storage. Content will be stored into this paticular container and keep separate from the container that will be used to run `alfresco`. This container will expose a volume to other containers. This container will be build from the same image running `alfresco` but won't be "running" in the "common" sense. This container is used to share data amongst containers forming a stack. It will also be useful for deploying clusters in the future.
   2. A database container running the required database flavor and version. The image will be pulled automatically from [docker hub](https://registry.hub.docker.com) if not present in your local repository. The databases supported so far in this project are [MySQL](https://registry.hub.docker.com/_/mysql/tags/manage/), [Postgres](https://registry.hub.docker.com/_/postgres/tags/manage/) and [MariaDB](https://registry.hub.docker.com/_/mariadb/tags/manage/)
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

