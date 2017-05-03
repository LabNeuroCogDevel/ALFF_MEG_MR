#!/usr/bin/env bash
cd $(dirname $0)
niifile=nswuktm_rest_5.nii.gz 
# resample mask
examplefunc=../subjs/10662_20150826/rest/$niifile

Y7_1mm=~ni_tools/standard/atlas/mktmplt/Yeo7_MNI.nii.gz   
Y7_3mm=Yeo7_MNI_samp2func.nii.gz
[ ! -r "$Y7_3mm" ] && 3dresample -rmode NN -master $examplefunc -inset $Y7_1mm -prefix $Y7_3mm


roimask="$Y7_3mm"
for f in ../subjs/*/rest/$niifile; do
  [[ ! $f =~ [0-9]{5}_[0-9]{8} ]] && continue
  subj=$BASH_REMATCH
  d="../subjs/$subj/fALFF"
  roits="$d/Y7_3mm_roistat.txt"
  [ -r "$roits" -a $(wc -l < "$roits" ) -eq 300 ] && continue
  [ ! -d $d ] && mkdir $d
  3dROIstats -quiet -mask $roimask $f > $roits
done

