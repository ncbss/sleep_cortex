#!/bin/bash

# Setting environment
export FREESURFER_HOME=/Applications/freesurfer/7.1.1
export SUBJECTS_DIR=$PWD
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# Running MrisPreproc
for study in # list of subjects (text file named with study name)
do
  for hemi in lh rh 
  do
    for smoothing in 10 
    do
      for meas in thickness 
      do
           mris_preproc --f $study \
            --cache-in $meas.fwhm$smoothing.fsaverage  \
            --target fsaverage \
            --hemi $hemi \
            --out a_cat_data/$hemi.$meas.$study.$smoothing.mgh
        done
    done
  done
done