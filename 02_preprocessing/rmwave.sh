#!/bin/bash

# Move to data 
cd /projects/crunchie/hipp/wavepain

# Collect folders
folders=$(ls -d sub*/)
run_folders="fir"

for folder in $folders; do
    # Move in 
    cd $folder    
    echo "__________________
    $folder"
    
    for run_folder in $run_folders; do
	    if [[ "sub013/" == *$folder* ]]; # leave this as example for old ones
            then
              continue 
    	    fi
#	    cd $run_folder
#	    echo "$run_folder"

        # Do stuff
	    cd canonical_pmodV3
	    rm s6* -f
	    cd ../

#	    cd ../ # leave run_folder
    done
    echo  "________________
    "
    cd ../ # leave sub_folder
    
done

