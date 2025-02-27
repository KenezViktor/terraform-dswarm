#/usr/bin/env bash

# Check parameters
# $1 should not exist --- should match output_directory
# $2 should exist --- final dest of OS image
# $3 --- should match vm_name
if [[ -d $1 ]]; then
    echo "$1 exists";
    exit 1;
fi;
if [[ ! -d $2 ]]; then
    echo "$2 not exists";
    exit 1;
fi;
if [[ -z $3 ]]; then
    echo "$3 not given";
    exit 1;
fi;

# Init packer
packer init .;

# Build image
packer build .;

# Copy from output dir to dest
sudo cp $1/$3 $2/$3;

# Remove temp dir to allow re-run
sudo rm -r $1;