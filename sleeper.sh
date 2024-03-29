#/bin/bash

set -m

./sleeper2.sh $1 &

for job in `jobs -p`
do
  echo $BASHPID also told $job to go to sleep for $1 seconds
done

echo $BASHPID is going to sleep for $1 seconds
sleep $1
echo $BASHPID has woken up
