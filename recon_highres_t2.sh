#!/bin/bash

year=2011 # what year data is?
s=11454078 # what your subject # is?

SUBJECTS_DIR=/ifs/scratch/pimri/posnerlab/1anal/IDP/fs

#IMPATH=/ifs/scratch/pimri/posnerlab/1anal/IDP/${year}/${s}
IMPATH=/ifs/scratch/pimri/posnerlab/1anal/IDP/data/${s}
EXPERTOPT=$SUBJECTS_DIR/expert.opt
FLAIR=`ls $IMPATH/flair*nii*`
T1=`ls $IMPATH/t1*nii*`
SUBJECT=${s}_1mm_flair
CMD=/ifs/scratch/pimri/posnerlab/1anal/IDP/code/idp/job/cmd.${s}
recon=/ifs/scratch/pimri/posnerlab/1anal/IDP/code/idp/job/recon.${s}

cat<<EOC >$recon
#!/bin/bash
FREESURFER_HOME=/ifs/home/msph/epi/jep2111/app/freesurfer/
source $FREESURFER_HOME/SetUpFreeSurfer.sh
SUBJECTS_DIR=/ifs/scratch/pimri/posnerlab/1anal/IDP/fs
echo NOW PERFORMING RECON-ALL
#recon-all -all -s ${SUBJECT}.test_mpi128 -hires -i $T1 -expert $EXPERTOPT -FLAIR $FLAIR -FLAIRpial -hippocampal-subfields-T1 -openmp 64 
#recon-all -all -s ${SUBJECT}_1mm_mpi12 -i $T1 -expert $EXPERTOPT -FLAIR $FLAIR -FLAIRpial -hippocampal-subfields-T1T2 $FLAIR flair -openmp 12
recon-all -all -s ${SUBJECT}_1mm_mpi8_smp -i $T1 -FLAIR $FLAIR -FLAIRpial -hippocampal-subfields-T1T2 $FLAIR flair -parallel -openmp 8
EOC

chmod +x $recon


cat<<-EOM >$CMD
#!/bin/bash
#$ -V
#$ -cwd -S /bin/bash -N recon
#$ -l mem=2G,time=12::
#$ -pe smp 8
##$ -pe orte 16
##$ -l infiniband=TRUE
#$ -o /ifs/scratch/pimri/posnerlab/1anal/IDP/code/idp/job -e /ifs/scratch/pimri/posnerlab/1anal/IDP/code/idp/job 
source /ifs/home/msph/epi/jep2111/.bashrc
. /nfs/apps/openmpi/current/setenv.sh
$recon
EOM

qsub $CMD
