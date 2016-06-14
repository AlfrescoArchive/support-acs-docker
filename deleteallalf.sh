#!/bin/bash
# param1: cluster member name


# stop first all active members
for member in $(docker ps | grep "$1" | awk -F " " '{print $NF}')
do
  echo "Stoping member $member ..."
  docker stop $member
done

#remove all the members
for member in $(docker ps -a | grep "$1" | awk -F " " '{print $NF}')
do
  echo "Removing member $member ..."
  docker rm -v $member
done

# delete the network
echo "Deleting network $1 ..."
docker network rm $1
