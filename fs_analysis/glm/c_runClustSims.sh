#!/bin/bash
cd ..
# Setting environment
export FREESURFER_HOME=/Applications/freesurfer/7.1.1
export SUBJECTS_DIR=$PWD
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# Running cluster-thresholding
for predictor in # Predictor matching a_glm_<dir>
do
  for hemi in lh rh
  do
    for smoothing in 10
    do
       for  meas in thickness
       do
        for dir in a_glm_results/final/$hemi.$meas.$predictor.$smoothing.glmdir
        do        
            mri_glmfit-sim \
            --glmdir $dir \
            --cache 1.3 abs \
            --cwp 0.05 \
            --2spaces
        done   
      done        
    done      
  done    
done
