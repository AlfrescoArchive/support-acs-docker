#!/bin/bash
# param1: mamber name
docker exec -i -t $1 /bin/bash -c '/entry.sh && alfresco=`find . -name alfresco.sh` && $alfresco stop'
