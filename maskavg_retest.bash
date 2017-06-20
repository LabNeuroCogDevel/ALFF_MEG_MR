#!/usr/bin/env bash
set -e
cd $(dirname $0)

# Yeo 7 rois
Y7_1mm=~ni_tools/standard/atlas/mktmplt/Yeo7_MNI.nii.gz   
Y7_3mm=masks/Yeo7_MNI_samp2func.nii.gz
Y7_23mm=masks/Yeo7_MNI_samp2func2.3mm.nii.gz
resampleToFunc(){
  # resample to this func
  examplefunc="../subjs_test_retest/11228_20160212/1_2016.02.12-08.51.45_7/nswktm_mean_func_5.nii.gz"
  3dresample -overwrite -rmode NN -master $examplefunc -inset $1 -prefix $2
}

[ ! -r $Y7_3mm ] && echo "run maskavg.bash first!" >&2 && exit 1
[ ! -r "$Y7_23mm" ] && resampleToFunc $Y7_1mm $Y7_23mm


#######

roimask="$Y7_23mm"
tsname="Y7_3mm_roistats.txt"

#roimask="$Y7_3mm"
#tsname="Y7_3mm_roistats.txt"
for f in ../subjs_test_retest/1*_2*/[12]*/nswktm_rest[12]_5.nii.gz; do
  [[ ! $f =~ ([0-9]{5}_[0-9]{8})/([12]) ]] && continue
  subj=${BASH_REMATCH[1]}
  run=${BASH_REMATCH[2]}
  d="../subjs_test_retest/$subj/fALFF"
  roits="$d/${run}_$tsname"
  [ -r "$roits" -a $(cat "$roits" |wc -l  ) -eq 320 ] && continue
  [ ! -d $d ] && mkdir $d
  3dROIstats -quiet -mask $roimask $f > $roits
done

