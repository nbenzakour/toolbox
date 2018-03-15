#!/bin/bash

# usage:
# script takes a nullarbor directory, runs the BAP pipeline and returns a BAP report
# also produces corrected output for incF typing

#==============================================================================

display_usage() {
	echo "This script runs BAP and generates reports."
	echo "Usage: <run_dir> <strain_file>." 
	echo -e "\nUsage:\n$0 <run_dir> <strain_file>.\n" 
	}

# if less than one arguments supplied, display usage 
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

# get strain names

dir=$1
filename="$2"

# Running BAP if not run already on strains listed in file provided

echo "Running BAP..."
echo ""

while read -r line; do
	if [ -d $line/BAP ]; 
		then echo "$line already processed"; 
		else echo "Processing $line..."; 
		docker run --rm -v /data/db/cge_databases:/databases -v $dir/$line:/input -v $dir/$line/BAP:/output cgetools BAP --wdir /output --fa /input/contigs.fa; 
		echo "$line processed";
	fi; 
done < "$filename"

echo "BAP run completed."
echo ""
echo "BAP reporting..."


# Generate combined report

echo ""
echo "strain	contigs_file	sequencing_size	genome_size	contigs	n50	depth	species	mlst	mlst_genes	resistance_genes	virulence_genes	plasmids	pmlsts"

while read -r line; do
	if [ -f $line/BAP/out.tsv ] ;
		then echo -n $line "	"; 
		tail -n 1 $line/BAP/out.tsv; 
	fi ;
done < "$filename"

# Generate results versus predictions for incF type

echo ""
echo "Generate compariosn between incF matches and prediction..."
echo ""

while read -r line; do 
	echo -n "$line : " ; echo -n " " `grep "fii_" $line/BAP/PlasmidFinder/pMLST_IncF/results_tab.txt | cut -f 6,2`; echo -n " " `grep "fia_" $line/BAP/PlasmidFinder/pMLST_IncF/results_tab.txt | cut -f 6,2`; echo -n " " `grep "fib_" $line/BAP/PlasmidFinder/pMLST_IncF/results_tab.txt | cut -f 6,2`; echo " done " `head -n 1 $line/BAP/PlasmidFinder/pMLST_IncF/results_tab.txt`; 
done < "$filename"
