#!/usr/bin/env bash
set -e
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited with error $e" >&2' EXIT

sd=$1
[ -z "$sd" ] && echo "USAGE: $0 subj_date" >&2 && exit 1
sd=$(basename $sd)

for dir in /Volumes/Zeus/ALFF/full/subjs_test_retest/$sd/[12]_*; do
  cd $dir
  [ -r .preprocessFunctional_complete ] && continue
  [ ! -r structuralFiles.txt ] && echo "$sid: no $(pwd)/structuralFiles.txt file!" >&2 && continue
  read bet warp < structuralFiles.txt
  [ -z "$bet" -o -z "$warp" ] && echo "$sid: no $(pwd)/structuralFiles.txt does not have bet and warp!" >&2 && continue  
  [ ! -r "$bet" -o ! -r "$warp" ] && echo "$sid: missing bet/warp $bet/$warp" >&2 && continue  
  
  #[ -r .preproc_cmd ] && rm .preproc_cmd
  yes | preprocessFunctional \
   -tr 1.5 \
   -4d rest[12].nii.gz \
   -mprage_bet $bet \
   -warpcoef $warp \
   -4d_slice_motion \
   -custom_slice_times /Volumes/Phillips/mMR_PETDA/scripts/sliceTimings.1D \
   -template_brain MNI_2.3mm \
   -no_hp \
   -nuisance_compute 6motion,rx,ry,rz,tx,ty,tz,wm,csf,gs,d6motion,drx,dry,drz,dtx,dty,dtz,dwm,dcsf,dgs
  
done
