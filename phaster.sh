#!/bin/bash

#title           :phaster.sh
#description     :This script will run PHASTER via the API and update output as required.
#author          :Nouri L. Ben Zakour
#date            :20170206
#version         :0.1
#usage           :phaster.sh <strain_file> <run_status> <run_dir> <contigs|pseudogenome>
#dependency      :save_page_as
#==============================================================================

display_usage() {
   echo "This script runs PHASTER via the API on a list of strains."
   echo "Usage: <strain_file> <run_status> <run_dir>."
   echo "       <strain_file>   contains the list of strain to run phaster on "
   echo "                       i.e. isolates.txt as produced by Nullarbor."
   echo "       <command>    set to 'run' to run phaster"
   echo "                       set to 'update' to update current phaster jobs"
   echo "                       set to 'download' to download finished phaster jobs"
   echo "       <run_dir>       directory where phaster jobs will be stored"
   echo "       <-p>            run on pseudogenomes instead of contigs (if available)"
}

# if less than two arguments supplied, display usage
   if [  $# -le 1 ]
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

# check whether user had supplied appropriate command. If different display usage
   if [[ $2 != "run" && $2 != "update" && $2 != "download" ]]
   then
      display_usage
      exit 0
   fi

# get strain names

filename="$1"
echo $1

# run PHASTER for first time

if [ $2 == "run" ]
  then
    mkdir $3;
    echo "Sending phaster jobs...";
    while read -r line; do
      echo $line;
      # add condition if pseudogenome option is ticked
      if [ $4 == "-p" ]
        then
          union -sequence $line/prokka/$line.UNION.gbk -sformat genbank -outseq $line.UNION.fa -osformat fasta;
          mv $line.UNION.fa $line/prokka/$line.UNION.fa;
          wget --post-file="$line/prokka/$line.UNION.fa" "http://phaster.ca/phaster_api?contigs=1" -O PHASTER_$line;
        else
          wget --post-file="$line/contigs.fa" "http://phaster.ca/phaster_api?contigs=1" -O PHASTER_$line;
      fi
      mv PHASTER_$line $3/;
    done < "$filename"
fi

# retrieve PHASTER status

if [ $2 == "update" ]
  then
    echo "Updating phaster jobs...";
    while read -r line; do
      echo "Updating phaster job $line...";
      out=$(grep job $3/PHASTER_$line | cut -d "\"" -f 4);
      wget "http://phaster.ca/phaster_api?acc=$out" -O PHASTER-res_$line;
      mv PHASTER-res_$line $3/;
    done < "$filename"
fi

# download PHASTER data

if [ $2 == "download" ]
  then
    echo "Downloading phaster jobs...";
    while read -r line; do
      echo "Dowloading phaster job $line...";
      out=$(grep job $3/PHASTER_$line | cut -d "\"" -f 4);
      wget "http://phaster.ca/submissions/$out.zip" -O PHASTER-res_$line.zip;
      save_page_as "http://phaster.ca/submissions/$out" -d PHASTER-res_$line.html;
      mv PHASTER-res_$line* $3/;
    done < "$filename"
fi
