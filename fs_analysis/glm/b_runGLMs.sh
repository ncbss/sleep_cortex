#!/bin/bash
# Setting environment

export FREESURFER_HOME=/Applications/freesurfer/7.1.1
export SUBJECTS_DIR=$PWD
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# Running GLMs
for study in  sleep_thickness
do
for predictor in # FGSD with predictor (e.g., sleep data) and covariates
  do
 for contrast in # Contrast matrix accounting for predictor + covariates and DOSS 
  do
    for hemi in lh rh
    do
      for  smoothing in 10
      do
        for  meas in thickness
          do
            mri_glmfit \
            --y a_cat_data/$hemi.$meas.$study.$smoothing.mgh \
            --fsgd a_fsgd/final/$predictor.fsgd doss\
            --C a_contrasts/$contrast.mtx \
            --surf fsaverage $hemi  \
            --cortex  \
            --glmdir a_glm_results/final/$hemi.$meas.$predictor.$smoothing.glmdir
            
            done
          done
        done
    done
  done
done