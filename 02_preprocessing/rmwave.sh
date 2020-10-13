#!/bin/bash

# Move to data 
cd /projects/crunchie/hipp/wavepain

# Collect folders
folders=$(ls)
run_folders="run000/mrt/mean_epi"

for folder in $folders; do
    # Move in 
    cd $folder    
    echo "__________________
    $folder"
    
    for run_folder in $run_folders; do
	    if [[ "sub013" == *$folder* ]];
            then
              continue 
    	    fi
	    cd $run_folder
	    echo "$run_folder"

        # Do stuff
	    rm *skull* -I
	    cd ../../
    done
    echo  "________________
    "
    cd ../
    
done

