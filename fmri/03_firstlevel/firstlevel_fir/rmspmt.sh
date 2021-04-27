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
	    if [[ "sub013/" == *$folder* ]];
            then
              continue 
    	    fi
	    cd $run_folder
	    echo "$run_folder"

        # Do stuff
	    rm  spmT*  -r -f	    I
	    cd ../ # leave run_folder
    done
    echo  "________________
    "
    cd ../ # leave sub_folder
    
done

