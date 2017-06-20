#!/usr/bin/env bash

set -ex

sd=$1
[ -z "$sd" ] && echo "USAGE: $0 subj_date" >&2 && exit 1
sd=$(basename $sd)

prevdir=/Volumes/Phillips/MMY4_Switch/subjs/$sd/preproc/
[ ! -d "$prevdir" ] && echo "'$sd' has no dir like '$prevdir'" >&2 && exit 1

# find resting state
mbpatt="/Volumes/Phillips/Raw/MRprojects/MultiModal/multiband/WPC5640*$sd*/ep2d_MB_rest_*hdr"
restimgs=($(ls $mbpatt ))
[ ${#restimgs[@]} -ne 2 ] && echo "'$sd' has ${#restimgs[@]} !=2 in $mbpatt " >&2 && exit 1

# find fm and mprage
for d in $prevdir/{fm,mprage} ; do
  [ ! -d "$d" ] && echo "'$sd' missing '$d'" >&2 && exit 1
done

echo $sd ${restimgs[@]}

SUBJDIR=$(dirname $0)/../subjs
[ ! -d $SUBJDIR ] && mkdir -p $SUBJDIR
cd $SUBJDIR

[ -r $sd/rest/.preprocessFunctional_complete ] && exit 0
#[ -r $sd/rest/.preprocessFunctional_incomplete ] && echo "remove $sd/rest/.preprocessFunctional_incomplete" && exit 1

#[ -d "$sd" ] && rm -r $sd

[ ! -d "$sd" ] && mkdir $sd 
cd $sd

# get fieldmap and anatomical
for prereq in $prevdir/{fm,mprage}; do
   n=$(basename $prereq)
   [ ! -L $n -a ! -d $n ] && ln -s $prereq ./
done

[ ! -d rest ] && mkdir rest
cd rest

for img in ${restimgs[@]}; do
  outname=$(basename $img|sed 's/ep2d_MB_//;s/.hdr$/.nii.gz/; s/_MB//;')
  [ ! -r $outname ] && 3dcopy $img $outname
done

#[ -r .preproc_cmd ] && rm .preproc_cmd
yes | preprocessFunctional \
 -4d rest.nii.gz -func_refimg rest_ref.nii.gz \
 -mprage_bet ../mprage/mprage_bet.nii.gz \
 -warpcoef ../mprage/mprage_warpcoef.nii.gz \
 -fm_magnitude '../fm/mag/MR*' \
 -fm_phase '../fm/phase/MR*' \
 -custom_slice_times /Volumes/Phillips/MMY4_Switch/scripts/sliceTimings.1D \
 -fm_cfg clock \
 -4d_slice_motion -tr 1 \
 -no_hp \
 -nuisance_compute 6motion,rx,ry,rz,tx,ty,tz,wm,csf,gs,d6motion,drx,dry,drz,dtx,dty,dtz,dwm,dcsf,dgs

 #-wavelet_despike \
 #-no_smooth  \
 #-compute_warp_only \

