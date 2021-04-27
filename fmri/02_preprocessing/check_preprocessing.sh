# Move to data 
cd /projects/crunchie/hipp/wavepain

# Collect folders
folders=$(ls)
run_folders="run000/mrt run001/mrt  run002/mrt"

for folder in $folders; do
    # Move in 
    cd $folder    
    echo "__________________
    $folder"
    
    for run_folder in $run_folders; do
	    if [[ "sub005sub013" == *$folder* ]];
            then
              continue 
    	    fi
	    cd $run_folder
	    echo "$run_folder"
	    echo $(ls -sh)
	    cd ../../
    done
    echo  "________________
    "
    cd ../
    
done

