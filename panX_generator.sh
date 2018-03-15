#!/bin/bash

#title           :panX_generator.sh
#description     :This script will run panX pan-genome analysis and push to the pan-genome visualisation folder.
#author          :Nouri L. Ben Zakour
#date            :20180315
#version         :0.1
#usage           :panX_generator.sh <metadata_file> <gbk_dir> <run_name> <run_dir> <vis_dir> <nullarbor>
#=======================================================================================================

display_usage() {

	echo "This script will run panX pan-genome analysis and push to the pan-genome visualisation folder."
	echo "Usage: panX_generator.sh <metadata_file> <nullarbor_run> <run_name> <run_dir> <vis_dir>"
	echo "	<metadata_file> 	metadata file in tab delimited format with full path. "
	echo "				first field has to be named 'accession' for successful metadata linking."
	echo "	<gbk_dir>		full path to folder containing gbk"
	echo "	<run_name>		name of the run"
	echo "	<run_dir>		full path to running directory"
	echo "	<vis_dir>		full path to visualisation directory, typically /your/path/pan-genome-visualisation/public/datasets..."
	echo "	<nullarbor>		yes, if genbank data are to be retrieved from a nullarbor run. No, otherwise."
	}

# if less than 6 arguments supplied, display usage
   if [  $# -le 5 ]
   then
      display_usage
      exit 1
   fi

# check whether user had supplied -h or --help . If yes display usage
   if [[ ( $# == "--help") ||  $# == "-h" ]]
   then
      display_usage
      exit 0
   fi
   
# check whether user has supplied appropriate value for Nullarbor run. If different display usage
   if [[ $6 != "yes" && $6 != "no" && $6 != "y" && $6 != "n" ]]
   then
      display_usage
      exit 0
   fi

metadata_file=$1
gbk_dir=$2
run_name=$3
run_dir=$4
vis_dir=$5
nullarbor=$6


## set up
echo "Setting up running folder..."
if [ ! -d $run_dir ]; 
then
	mkdir $run_dir
	cd $run_dir
	mkdir input_GenBank
fi

echo "Importing Genbank files..."	
cd $run_dir/input_GenBank

if [[ $nullarbor == "yes" || $nullarbor == "y" ]];
then 
	cp $gbk_dir/*/prokka/*UNION.gbk .
	for f in *; 
		do rename .UNION.gbk .gbk $f; 
		done
else
	cp $gbk_dir/*gbk .
fi


ls *gbk | cut -f 1 -d "." > ../$run_name.txt
cat ../$run_name.txt
cd $run_dir


## run
echo "Running PanX pan-genome analysis..."
python /opt/sw/pan-genome-analysis/panX.py -fn . -st 1 2 3 5 6 7 8 9 10 11 -mi $metadata_file -sl $run_name.txt -t 32 1> $run_name.log 2> $run_name.err
cat $run_name.err

## transfer results to visualisation folder, typically /your/path/pan-genome-visualisation/public/datasets"
## Pan-genome analysis is successfully accomplished

echo "Copying results to visualisation folder"
if [ ! -d $vis_dir/$run_name ]; 
then
	mkdir $vis_dir/$run_name
fi
	
cp -rf vis/* $vis_dir/$run_name
cd $vis_dir
bash add-new-pages-repo.sh $run_name wide

echo "PanX analysis completed and transferred, ready for visualisation"
