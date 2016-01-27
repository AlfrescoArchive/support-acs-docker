#!/bin/bash
# param1: cluster member name
docker exec -i -t  $1 /bin/bash  -c 'cd /opt;`find -name alfresco.sh` status '
