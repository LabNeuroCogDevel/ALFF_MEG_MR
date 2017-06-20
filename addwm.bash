#!/usr/bin/env bash
cd $(dirname $0)
scriptdir=$(pwd)
# code copied from MH preproc
stddir="/opt/ni_tools/standard/"
[ ! -r .template_wm_prob_3mm.nii.gz ] && 
  fslmaths "$stddir/mni_icbm152_nlin_asym_09c/mni_icbm152_wm_tal_nlin_asym_09c_3mm" -thr 0.9 -bin -eroF .template_wm_prob_3mm
[ ! -r .template_wm_prob_2.3mm.nii.gz ] && 
  fslmaths "$stddir/mni_icbm152_nlin_asym_09c/mni_icbm152_wm_tal_nlin_asym_09c_2.3mm" -thr 0.9 -bin -eroF .template_wm_prob_2.3mm

func_ts=wuktm_rest.nii.gz #func_ts="${postWarp}"
wmmask=$scriptdir/.template_wm_prob_3mm.nii.gz 
set -x
for f in $scriptdir/../subjs/*/rest/$func_ts; do 
  cd $(dirname $f)
  [ -r .wm_ts ] && continue
  pwd
  3dmaskSVD -vnorm -mask $wmmask -sval 6 -polort 3 ${func_ts} > .wm_ts
  1d_tool.py -overwrite -infile .wm_ts -demean -write .wm_ts #demean     
  1d_tool.py -overwrite -infile .wm_ts -derivative -demean -write .wm_ts_deriv #compute derivative
done

