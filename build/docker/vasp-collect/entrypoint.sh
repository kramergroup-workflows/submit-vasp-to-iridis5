#!/bin/sh

# The first parameter passed to the script is taken as the 
# subpath containing the VASP input files
SUBPATH=$1

# Allow to override the jobname, but use the sub-path as default
export JOB_NAME=${JOB_NAME:-$SUBPATH}

# Define the job directory - this is cluster dependent as 
# different clusters have different layouts - as a fallback
# we use a subfolder of the $HOME directory
export JOBDIR="~/$BASEDIR/$JOB_NAME"
case $CLUSTER in 
iridis5) 
  export JOBDIR="/scratch/$USERNAME/$BASEDIR/$JOB_NAME"
  ;;
michael) 
  export JOBDIR="/home/$USERNAME/Scratch/$BASEDIR/$JOB_NAME"
  ;;
thomas)
  export JOBDIR="/home/$USERNAME/scratch/$BASEDIR/$JOB_NAME"
  ;;
esac

echo "Copying VASP output files"
cd /data/vasp/$SUBPATH
ssh -i /ssh/id_rsa -oStrictHostKeyChecking=no $USERNAME@$HOSTNAME "tar czf - --exclude=vasp --exclude=vasp-driver.pyz --exclude=qscript -C $JOBDIR ." | tar xzf -

if [ $REMOVE = "yes" ];
then
  echo "Removing files from server"
  ssh -i /ssh/id_rsa -oStrictHostKeyChecking=no $USERNAME@$HOSTNAME "rm -rf /scratch/$USERNAME/$BASEDIR/$JOB_NAME"
fi

echo "Compressing intermediate runs"
for f in $(find . -type d -name "run.[0-9]*");
do
  tar czf $f.tar.gz $f && rm -rf $f
done

echo "Checking job completion"
python3 /assets/vasp-driver.pyz check