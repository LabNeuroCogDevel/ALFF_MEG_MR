# ALFF on MEG and fMRI
20170502 SM WF

also known as rhea:/Volumes/Zeus/ALFF/full/scripts

## current state 
reviewed 2018-01-05 WF + DM


### Original MR data
  - resting state scans preprocessed with `preproc.bash` (`-no_hp`,`-nuisance_compute` only. final output `nswuktm_rest_5.nii.gz`)
  - network based roi (`Yeo2011 7Networks MNI152`) time series extracted by `maskavg.bash` into `../subjs/*/fALFF/Y7_3mm_roistat.txt`

### MotReg and PC MR data
both from DM `~montezdf/MotionTemplates/PCAMotionDecon/*/`
 * MotReg from `maskavg_simplemotion.bash` using `*_SimpleDeconResid+tlrc.HEAD`
 * PC from `maskavg_dm.bash` using `*_PCAMotionDeconResid+tlrc.HEAD`

### Stats
  - MR read in by `readMR.m`
  - alf and summary metrics calcuated in `runme.m`
    - summaries by `spectrumMR.m` + `calc_allflux.m` and compaired between modality with `calc_corrs.m`
    - plotted with `plot_roi_band.m` and `plot_band_band_roi.m`

## collect data
`runall.bash`

## analyze
`runme.m`
