# Move to data 
cd /projects/crunchie/hipp/wavepain

# Collect folders
folders=$(ls)
run_folders = "run001/mrt/ run002/mrt/"

for folder in $folders; do
    # Move in 
    cd $folder    
    echo "__________________
    $folder"
    
    for run_folder in $run_folders; do
	    cd $run_folder
	    echo "$run_folder"
	    ls
	    cd ../../
    done
    cd ../
    
done

