#!/bin/bash
# param1: cluster member name
for member in $(docker ps | grep "$1-" | cut -d" " -f50-)
do
  echo "Stop member $member ..."
  ./stopalf.sh $member
done

