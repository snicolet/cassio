
# File pyqt-search.py : this script lists all your Python installations in your 
#                       system, then for each Python binary found, it checks if the 
#                       PyQt4 module or the PyQt5 module is installed (and usable).
#
# Usage :
#     python pyqt-search.py
#
#

import os
import re

tested = []

def check_binaries(filename, remove_alias) :

    with open(filename, "r") as input: 
        for line in input :
   
            if (line.find("-config") >= 0) :
                continue

            if (remove_alias) :
                pos = line.find("@")
                if (pos > 0) :
                    line = line[0:pos]

            binary = re.sub("[^a-z0-9-./@]+","", line, flags=re.IGNORECASE)
            
            binary = path + binary
            
            # print("binary = ", binary)
            # print("line = ", line)
            
            if (binary.find("/bin/") < 0) :
                continue
            
            if (binary.find("/bin/python3") < 0) :
                continue
            
            if not(os.path.exists(binary)) :
                continue
            
            if binary in tested :
                continue
            else :
                tested.append(binary)
            
            # print name of Python binary
            print(binary)
          
            # call that Python executable with pyqt-check.py
            value = os.system(binary + " pyqt-check.py  -PyQt4 ")
            value = os.system(binary + " pyqt-check.py  -PyQt5 ")
            
            if os.path.exists(filename):
                 os.remove(filename)

print()

# Get the list of the potential Python binaries on my system,
# using some traditionnal locations
paths = [ "/usr/local/lib/", "/opt/local/bin/" ]

for path in paths :
    filename = "list-of-python-installations.txt"
    cmd = "ls -a " + path + " | grep python3 > " + filename
    value = os.system(cmd)
    check_binaries(filename, True)

# Get the list of the potential Python binaries on my system,
# using the locate function (if available)
filename = "list-of-python-installations-locate.txt"
path = ""
value = os.system("which locate > " + filename)
if (value == 0) :
    cmd = "locate python3 | grep /bin/ > " + filename
    value = os.system(cmd)
    check_binaries(filename, False)


print()