#!/bin/bash

# this just swaps the output redirect to append
cd /apps/aspace/archivesspace/
sed -i 's/$startup_cmd &> /$startup_cmd \&>> /g' archivesspace.sh 
