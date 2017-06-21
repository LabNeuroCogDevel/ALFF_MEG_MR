#!/usr/bin/env bash

set -e
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited with error $e" >&2' EXIT

SROOT=$(cd $(dirname $0); pwd)/../subjs_test_retest
[ ! -d $SROOT ] && mkdir $SROOT
SROOT=$(cd $SROOT; pwd)

previd=0
sqlite3 -separator " " /opt/ni_tools/mrpoto_sql/db '
  select 
    id,date,sessionname,seqno,dir 
  from mrinfo 
  where 
   study like "pet" and 
   Name like "e%rest%" and 
   ndcm>200 and 
   id like "B%" 
  group by id,sessionname
  having min(seqno)' |
 while read id date session seqno dir; do

   lunadate8=$(grep $id -i /Volumes/Phillips/mMR_PETDA/scripts/txt/subjinfo_agesexids.tsv|cut -f1,2 | sed 's/\t/_/')
   #[ -z "$lunadate8" ] && echo "no lunaid for $id ($dir)" >&2 && continue
   # continue b/c we dont have a mprage

   if [ $previd != "${id}_$date" ];then
     count=1
     restfile=/Volumes/Phillips/mMR_PETDA/subjs/$lunadate8/func/resting/1/func_resting_1.nii.gz
   else
     let count++
     # more than 2 for B0097 b/c scanner crash/restart?
     [ $count -gt 2 ] && echo "ERROR: [$id] $lunadate8: has more than 2 ($count: $dir)">&2 && continue
   fi
   previd=${id}_$date

   [ -z "$lunadate8" ] && echo "ERROR: [$id] has no lunaid in /Volumes/Phillips/mMR_PETDA/scripts/txt/subjinfo_agesexids.tsv " >&2 && continue
   [ ! -r $restfile ] && echo "ERROR: [$id] $lunadate8: no data ($restfile)" >&2 && continue
   bet=$(realpath $(dirname $restfile)/mprage_bet.nii.gz)
   [ ! -r $bet ] && echo "ERROR: [$id] $lunadate8: missing bet, not preproced? $(dirname $restfile)" >&2 && continue
   warp=$(dirname $bet)/mprage_warpcoef.nii.gz
   [ ! -r $warp ] && echo "ERROR: [$id] $lunadate8: no warp ($warp) but have bet" >&2 && continue

   # 
   savedir="$SROOT/$lunadate8/${count}_${session}_${seqno}"
   [ ! -d "$savedir" ] && mkdir -p  "$savedir"
   outname=rest${count}.nii.gz 
   [ -r "$savedir/$outname" ] && continue

   echo "$bet $warp" > $savedir/structuralFiles.txt

   cmd="dcmstack  '$dir' \
    --dest-dir '$savedir' -o '$(basename $outname .nii.gz)' \
    --include '.*' --file-ext 'MR*' \
    --embed-meta"
   echo $cmd
   eval $cmd
   3dNotes -h "$cmd" $savedir/$outname
  done
