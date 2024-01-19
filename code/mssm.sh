#!/bin/bash

#############################################################
# Run all MSSM steps in parallel mode
#
# Arguments: 1) SUBJECST_DIR, 2) nCPU (logical cores)
#            3) SUBSTRING (dir name pattern) 4) FWHM
#
# Usage example: bash mssm-all.sh 
#                /vast/bandlab/studies/ADNI/recons 16 *acc* 10
#
# Note: suggested FHWM range: 5 ~ 20
#   
#############################################################


SUBJECTS_DIR=$1
nCPU=$2
SUBSTRING=$3
FWHM=$4

nPARALLEL_1=8
nPARALLEL_2GWR=14
nPARALLEL_2thick=2 
nPARALLEL_3GWR=14
nPARALLEL_3thick=2

nJOBS_1=$$(( (nCPU/nPARALLEL_1)*nPARALLEL_1 ))
nJOBS_2GWR=$$(( (nCPU/nPARALLEL_2GWR)*nPARALLEL_2GWR ))
nJOBS_2thick=$$(( (nCPU/nPARALLEL_2thick)*nPARALLEL_2thick ))
nJOBS_3GWR=$$(( (nCPU/nPARALLEL_3GWR)*nPARALLEL_3GWR ))
nJOBS_3thick=$$(( (nCPU/nPARALLEL_3thick)*nPARALLEL_3thick ))

bash step1_generate_GM_WM_GWR.sh $SUBJECTS_DIR $nJOBS_1 $SUBSTRING && \
bash step2_reg_surf2fsaverage_GWR.sh $SUBJECTS_DIR $nJOBS_2GWR $SUBSTRING && \
bash step2_reg_surf2fsaverage_thickness.sh $SUBJECTS_DIR $nJOBS_2thick $SUBSTRING && \
bash step3_smooth_registered_GWR.sh $SUBJECTS_DIR $nJOBS_3GWR $SUBSTRING $FWHM && \
bash step3_smooth_registered_thickness.sh $SUBJECTS_DIR $nJOBS_3thick $SUBSTRING $FWHM && \
bash step4_check_results.sh $SUBJECTS_DIR $SUBSTRING $FWHM

echo "All done!!"
