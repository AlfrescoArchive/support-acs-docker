#!/bin/bash
# param1: cluster member name
for member in $(docker ps | grep "$1-" | awk -F " " '{print $NF}')
do
  echo "Start member $member ..."
  ./startalf.sh $member
done

