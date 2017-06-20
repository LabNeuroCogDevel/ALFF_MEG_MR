#!/usr/bin/env bash
cd $(dirname $0)
niifile=nswuktm_rest_5.nii.gz 
### setup atlas

# Yeo 7 rois
Y7_1mm=~ni_tools/standard/atlas/mktmplt/Yeo7_MNI.nii.gz   
Y7_3mm=masks/Yeo7_MNI_samp2func.nii.gz
# make sure it exists

# Yeo 17 rois
Y17_1mm_fsl=~/standard/atlas/Yeo/Yeo_JNeurophysiol11_MNI152/Yeo2011_17Networks_MNI152_FreeSurferConformed1mm.nii.gz
Y17_1mm=~ni_tools/standard/atlas/mktmplt/Yeo17_MNI.nii.gz   
Y17_3mm=masks/Yeo17_MNI_samp2func.nii.gz
# make sure it all exists
[ ! -r "$Y17_1mm" ] && echo "run maskavg.bash first" && exit 1
[ ! -r "$Y17_3mm" ] && echo "run maskavg.bash first" && exit 1

#######

roimask="$Y7_3mm"
tsname="Y7_3mm_roistats.txt"
#roimask="$Y7_3mm"
#tsname="Y7_3mm_roistats.txt"
for f in /home/montezdf/MotionTemplates/PCAMotionDecon/*/*_PCAMotionDeconResid+tlrc.HEAD; do
  [[ ! $f =~ [0-9]{5}_[0-9]{8} ]] && continue
  subj=$BASH_REMATCH
  d="/Volumes/Zeus/ALFF/full/subjs/$subj/fALFF"
  roits="$d/DM_$tsname"
  [ -r "$roits" -a $(cat "$roits"|wc -l ) -eq 300 ] && continue
  [ ! -d $d ] && mkdir $d
  3dROIstats -quiet -mask $roimask $f > $roits
done

