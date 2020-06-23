#! /usr/bin/bash
echo "hello world"

# This bash script is used to update file structure according to cbs suggestion
# Activate with chmod.exe script.sh -+x, call with ./ script.sh oder bash script.sh

# Move to data 
cd /projects/crunchie/hipp/wavepain


folders=$(ls)
for folder in $folders; do
    # move in 
    cd $folder
    echo "arranging $folder"

    # change stuff
    # run000
    echo "$folder run000"
    cd run000/mrt/
    mv 1*/* .
    rmdir 1*   

    # run001
    echo "$folder run001"
    cd ../../run001/mrt/
    mv 1*/* .
    rmdir 1*

    mv FM_2TE/1*/* FM_2TE/
    rmdir FM2TE/1*

    mv FM_diff/1*/* FM_diff/
    rmdir FM_diff/1*    

    # run002    
    echo "$folder run002"
    cd ../../run002/mrt/
    mv 1*/* .
    rmdir 1*

    mv FM_2TE/1*/* FM_2TE/
    rmdir FM2TE/1*

    mv FM_diff/1*/* FM_diff/
    rmdir FM_diff/1*    

    # move out
    cd ../../../    
    echo "$folder done
    "
done

