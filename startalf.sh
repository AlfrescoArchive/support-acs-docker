#!/bin/bash
# param1: cluster member name
docker exec -d $1 /bin/bash -c '/entry.sh && alfresco=`find . -name alfresco.sh` && $alfresco start && while true; do ps -a; sleep 5; done'


