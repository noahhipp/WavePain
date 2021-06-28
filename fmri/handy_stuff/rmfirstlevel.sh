#!/bin/bash

# Move to data 
cd /mnt/e/wavepain/data/fmri_sample/fmri

# Housekeeping
ANADIR=canonical_pmodV4
folders=$(ls -d sub*/)

for folder in $folders; do
	
    # Skip some subs
    if [[ "sub013/ " == *$folder* ]]; # leave this as example for old ones
    then
	    echo "__________________
	    $folder is skipped"
	    continue
    fi
    # Move in sub folder
    cd $folder    
    echo "__________________
    $folder"
    
    # Remove analysis dir
    rm $ANADIR -r

    cd ../ # leave sub_folder
    
done

