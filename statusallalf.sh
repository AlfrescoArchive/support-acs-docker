#!/bin/bash
# param1: cluster member name
for member in $(docker ps | grep "$1-" | awk -F " " '{print $NF}')
do
  echo "Status member $member ..."
  ./statusalf.sh $member
done

