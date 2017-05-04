#!/usr/bin/env bash
cd $(dirname $0)
niifile=nswuktm_rest_5.nii.gz 

### dealing with template space and dimensions
# how to get an atlas (nearest neighbor intrp) from FSL (MNI 6th) to newer MNI template (2009c)
warp1mmFSLto2009c() {
  # tmpldir has warp coef from script
  #  /opt/ni_tools/standard/atlas/fsl2mni_1mm.bash
  tmpldir="/opt/ni_tools/standard/atlas/mktmplt"
  atlas6th=$1
  atlas09c=$2
  applywarp \
    -w $tmpldir/fsl209c_1mm_warpcoef.nii.gz \
    -r $tmpldir/09c_1m.nii.gz \
    -i $atlas6th \
    -o $atlas09c --interp=nn 
}

# atlas into functional dimensions
resampleToFunc(){
  # resample to this func
  examplefunc=../subjs/10662_20150826/rest/$niifile
  3dresample -overwrite -rmode NN -master $examplefunc -inset $1 -prefix $2
}

### setup atlas

# Yeo 7 rois
Y7_1mm=~ni_tools/standard/atlas/mktmplt/Yeo7_MNI.nii.gz   
Y7_3mm=masks/Yeo7_MNI_samp2func.nii.gz
# make sure it exists
[ ! -r "$Y7_3mm" ] && resampleToFunc $Y7_1mm $Y7_3mm

# Yeo 17 rois
Y17_1mm_fsl=~/standard/atlas/Yeo/Yeo_JNeurophysiol11_MNI152/Yeo2011_17Networks_MNI152_FreeSurferConformed1mm.nii.gz
Y17_1mm=~ni_tools/standard/atlas/mktmplt/Yeo17_MNI.nii.gz   
Y17_3mm=masks/Yeo17_MNI_samp2func.nii.gz
# make sure it all exists
[ ! -r "$Y17_1mm" ] && warp1mmFSLto2009c $Y17_1mm_fsl $Y17_1mm 
[ ! -r "$Y17_3mm" ] && resampleToFunc    $Y17_1mm     $Y17_3mm


#######

roimask="$Y7_3mm"
tsname="Y7_3mm_roistats.txt"

#roimask="$Y7_3mm"
#tsname="Y7_3mm_roistats.txt"
for f in ../subjs/*/rest/$niifile; do
  [[ ! $f =~ [0-9]{5}_[0-9]{8} ]] && continue
  subj=$BASH_REMATCH
  d="../subjs/$subj/fALFF"
  roits="$d/$tsname"
  [ -r "$roits" -a $(wc -l < "$roits" ) -eq 300 ] && continue
  [ ! -d $d ] && mkdir $d
  3dROIstats -quiet -mask $roimask $f > $roits
done

