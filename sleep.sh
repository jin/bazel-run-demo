#!/bin/bash

FAIL=0

echo Parent process is $BASHPID

./sleeper.sh 10 &
./sleeper.sh 20 &
./sleeper.sh 30 &

for job in `jobs -p`
do
  wait $job
done
