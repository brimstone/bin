#!/bin/bash
#

SUM=0
OVERALL=0

cd /proc
for PID in [0-9]* ; do
  PROGNAME=$(ps -p $PID -o comm --no-headers)
  for SWAP in $(awk '/Swap/ { print $2 }' $PID/smaps 2>/dev/null); do
    let SUM=$SUM+$SWAP
  done
  [ $SUM -gt 0 ] && echo "${SUM}K - $PID - $PROGNAME"
  SUM=0
done | sort -nr
