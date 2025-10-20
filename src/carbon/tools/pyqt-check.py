
# File pyqt-check.py : check if the current python (called PYTHON-BINARY in the following)
#                      has access to a PyQt module. This may be useful if you have many
#                      python environments installed on your system.
#
# Usage :
#     PYTHON-BINARY pyqt-check.py -PyQt4
#     PYTHON-BINARY pyqt-check.py -PyQt5    (default)
#

import sys
args  = sys.argv[1:]                   # the list of arguments to the script

lib = "PyQt5"                          # by default we search for PyQt5
if (len(args) > 0) :
   lib   = args[0]


if (lib.find("PyQt4") >= 0) :
	try :
   		from PyQt4.QtGui import QApplication
   		print("    --->   installed : PyQt4 ")
	except :
   		pass

if (lib.find("PyQt5") >= 0) :
	try :
   		from PyQt5.QtWidgets import QApplication
   		print("    --->   installed : PyQt5 ")
	except :
   		pass