#!/bin/bash

# Setting environment

export FREESURFER_HOME=/Applications/freesurfer/7.1.1
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export SUBJECTS_DIR=$PWD

mkdir a_aseg_parc_stats # Directory to save volumetric and thickness data in table format
dir=a_aseg_parc_stats

asegstats2table --subjectsfile=subjects.txt --meas volume --skip --statsfile wmparc.stats --all-segs --tablefile $dir/wmparc_stats.txt
asegstats2table --subjectsfile=subjects.txt --meas volume --skip --tablefile $dir/aseg_stats.txt
aparcstats2table --subjectsfile=subjects.txt --hemi lh --meas volume --skip --tablefile $dir/aparc_volume_lh.txt
aparcstats2table --subjectsfile=subjects.txt --hemi rh --meas volume --skip --tablefile $dir/aparc_volume_rh.txt
aparcstats2table --subjectsfile=subjects.txt --hemi lh --meas thickness --skip --tablefile $dir/aparc_thickness_lh.txt
aparcstats2table --subjectsfile=subjects.txt --hemi rh --meas thickness --skip --tablefile $dir/aparc_thickness_rh.txt
