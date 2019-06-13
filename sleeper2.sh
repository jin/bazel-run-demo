#/bin/bash

sleep $1 &
for job in `jobs -p`
do
  echo $BASHPID also told $job to go to sleep for $1 seconds
done

sleep $1
echo $BASHPID has woken up
