
# File pyqt-search.py : search all your Python installations in /opt/local/bin/ , then
#                       check for each one if the module PyQt4 or the module PyQt5 is
#                       installed.
#
# Usage :
#     python pyqt-search.py
#
#



import os
import re

# Get the list of the potential Python binaries on my system
cmd = "ls -a /opt/local/bin/ | grep python3 > list-of-python-installations.txt"
value = os.system(cmd)

print()

with open("list-of-python-installations.txt", "r") as input: 
   for line in input :
   
      if (line.find("-config") >= 0) :
          pass

      else :
              
          pos = line.find("@")
          if (pos > 0) :
              line = line[0:pos]

          line = re.sub("[^a-z0-9-.]+","", line, flags=re.IGNORECASE)
          
          # print name of Python executable
          print(line)
          
          # call that Python executable with pyqt-check.py
          value = os.system(line + " pyqt-check.py  -PyQt4 ")
          value = os.system(line + " pyqt-check.py  -PyQt5 ")
         
print()
