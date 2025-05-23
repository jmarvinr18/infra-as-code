#!/bin/bash

# for FILE in *;

# do 
# echo """
# ##########################
# ##    Opening $FILE     ##
# ##########################
# """
# if [ -f $FILE ] 

# then
#     echo "This is a file"
# elif [ -d $FILE ] 

# then 

#     for 
#     echo "This is a directory"

# fi

# ls -la $FILE; 


# done
commmand=($(find . -type f -name "*.tfvars"))
$commmand

for element in $my_array; do
    echo "$element"
done