#!/bin/bash
# param1: cluster member name
for member in $(docker ps | grep "$1-" | cut -d" " -f50-)
do
  echo "Start member $member ..."
  ./startalf.sh $member
done

