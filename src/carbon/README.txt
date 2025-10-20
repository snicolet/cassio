
Finding PyQt4 or PyQt5 on your system
-------------------------------------

To work, the 'carbon.py' librairy needs to access the PyQt4 or the PyQt5
module from Python. To see all your Python installations and find out
which ones have enough PyQt4 or PyQt5 support to use the carbon.py
library, you can use:

       python3 ./tools/pyqt-search.py

Once you have a working version of PyQt for a specific Python version,
you must edit the first line of the file 'carbon.py' (the shebang) to
always launch carbon.py with the right Python version.

Doing so avoid the problem where updating Python on your system breaks
PyQt4 or PyQt5, because PyQt4 or PyQt5 are not by default in the new
distribution of Python. If you get lost, run 'python3 pyqt-search.py' again.

Examples of shebang lines I have used in the past:

       #!/usr/bin/env python3
       #!/opt/local/bin/python3
       #!/opt/local/bin/python3.9
       #!/usr/local/bin/python3

It is always possible to create a Unix symbolic link in one of these locations
to point to another, working Python installation. For instance the following
command will install a symbolic link in /usr/local/bin/python3 pointing to
/opt/local/bin/python3.9 :

    ln -s /opt/local/bin/python3.9 /usr/local/bin/python3


Aliases for compiling cassio and running carbon.py
--------------------------------------------------

I have the following aliases in my .tcshrc file (they are using the tcsh
syntax because this is the default shell on my macs -- they probably need
translating to the bash alias syntax). Then I can type "carbon" and "cassio"
to test the carbon library and running cassio, respectively.

    alias ccd       "cd ~/Programmation/cassio/src/carbon"
    alias carbon    "./carbon.sh"
    alias ccassio   'fpc -Mobjfpc -Sh -k"-macosx_version_min 10.13" -ocassio.exe cassio.pas'
    alias cassio    "ccassio && ./cassio.exe"


Glitches on Mac OS 10.3 with qt4-mac
------------------------------------

Users experiencing graphics glitches on newer OS versions (10.13 and up) can
experiment with different graphics drawing systems that can be set in the
Interface tab of the /Applications/MacPorts/Qt4/qtconfig.app utility. Raster
mode is the preferred mode but is not compatible with all non-standard widget
styles. Keep an eye on the Fonts setting before saving!


Interesting documentation links
-------------------------------

https://doc.qt.io/qtforpython-5/overviews/qtwidgets-mainwindows-dockwidgets-example.html#dock-widgets-example