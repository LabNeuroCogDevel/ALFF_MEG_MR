#!/usr/bin/env bash

set -e 

MAXJOBS=5
SLEEPTIME=30

njobs() { jobs -p | wc -l; }
waitjobs() {
   count=1
   while [ -z "$MAXJOBS" -o $MAXJOBS -le $(njobs) ]; do
      echo "($count|$(njobs)/$MAXJOBS jobs) waiting $SLEEPTIME"
      jobs | sed 's/^/	/;'
      sleep $SLEEPTIME
      let count++
   done
}

cd $(dirname $0)
# run all subject through pipeline
cat txt/subj_date.txt | while read subj_date; do
 echo $subj_date
 (./preproc.bash $subj_date || echo $subj_date failed) &
 waitjobs
done

wait
