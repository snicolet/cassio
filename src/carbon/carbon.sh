#!/bin/bash

# Script to launch carbon.py as a graphic interface using the Carbon protocol
#
# usage : carbon.sh

# change directory to the path of the script
SCRIPTPATH=${0%/*}
cd "$SCRIPTPATH"

# launch carbon.py
#./carbon.py -echo -file torture.txt
#./carbon.py -file torture.txt -echo -colored
#./carbon.py -file torture.txt -echo -colored -keep_alive 

./carbon.py -file torture.txt -echo -colored 


