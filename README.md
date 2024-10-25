# Cassio

A nice but old [Othello program](http://cassio.free.fr), revisited?

## The current state of Cassio (October 2024)

The source code for Cassio 8.4 is a huge set (~400.000 lines) of Pascal code,
cross-compiling to x86-64 using GNU Pascal on the Macintosh, where GNU Pascal
was running as a plug-in for Metrowerks CodeWarrior, which is a PowerPC binary.
Cassio uses the Quickdraw/Carbon library by Apple for the user interface and
other OS-related stuff.

The current situation is that Cassio development is dead, because:

1. **Compiler**: the GNU Pascal compiler is no longer maintained since 2005
2. **Workflow**: CodeWarrior does not run on new Macs because Apple has dropped
support for PowerPC emulation (Rosetta) in MacOS X 10.7 in 2010
3. **Execution**: Cassio itself has stopped working on newer Mac in 2020 because
Apple has decided that Quickdraw/Carbon programs could no longer be run in
MacOS X 10.14.

What follows is a tentative plan to port Cassio to newer technologies.

It would be a nice bonus if Cassio became cross-platform at the same time (MacOS,
Windows, Linux) :blush:

## Choosing the tools

I would like to keep the Pascal codebase, because rewriting everything in C++
or in Python would take me another lifetime. Given this constraint, we address
the points of the previous section like so:

1. **Compiler**: the most active Pascal compiler at the moment is FreePascal
( http://https://www.freepascal.org )
2. **Workflow**: no longer project IDE, everything from the command line + Github
for versioning system + new code in Python for portability.
3. **Graphic library**: I would like to define a pure text protocol, so that Cassio
is able to use its standard input/output to talk to a minimal graphic library emulating
the behavior of the simple Quickdraw graphic primitives of 1984 (windows, menus, mouse,
dialogs, drawing text, drawing jpeg, sound, and that's about all I need).

## Preliminary work: implementing an abstract graphical protocol

- The minimal graphic library could be written in Python, using the PyQt bridge
to Qt4. This is quite portable, as Python and Qt are available everywhere. See
the [carbon.py file](https://github.com/snicolet/cassio/blob/master/src/carbon/carbon.py)
for the current state of the library.
- The text protocol could be similar to the examples in [torture.txt](https://github.com/snicolet/cassio/blob/master/src/carbon/torture.txt),
for instance. The protocol has the same flavor as [The Othello Engine Protocol](http://cassio.free.fr/engine-protocol.htm) already
used in Cassio for Cassio<->engine communications.
- Cassio would have to be able to connect to the standard input/output in an
efficient way, as there may be thousands of graphic primitives per second.

## Installing the necessary compilers and librairies

To build Cassio, you will need a recent version of the FreePascal compiler
and a working Python 3 environment with the PyQt4 module. The PyQt4 module
provides the necessary interfaces to use Qt4 from Python 3.

##### General instructions for installation:

- **FreePascal**: see the instructions on the [FreePascal wiki](https://wiki.freepascal.org/Installing_the_Free_Pascal_Compiler)
- **Python 3**: see https://www.python.org/downloads/
- **PyQt4**: see https://doc.qt.io/archives/qt-4.8/installation.html

##### Installing Python 3 (short version)

Follow the instructions on https://www.python.org/downloads/

##### Installing the FreePascal compiler for MacOS (short version)

- Make sure that you already have XCode downloaded from the App Store
- Install the FreePascal compiler version 3.2.0 (or later), for instance
with one of the following commands:
```
brew install fpc   (for Homebrew)
port install fpc   (for Macports)
```
##### Installing PyQt4 for MacOS (short version)

- Make sure that you already have XCode downloaded from the App Store
- Download PyQt4, for instance with one of the following commands:
```
pip3 install pyqt4 pyqt4-tools     (for pip3)
brew install pyqt4                 (for Homebrew)
port install py39-qtpy4            (for MacPorts)
```
- Check that PyQt downloaded properly by opening up the Python3 interpreter
and typing the following command:
```
import PyQt4.QtGui
```
_TODO: suggestions welcome for short instructions on how to install FreePascal+
Python3+PyQt4 on Windows or Linux_



## References

Possible sources for inspiration (in no particular order)

- The FreePascal website: https://www.freepascal.org
- The Qt4 documentation: https://doc.qt.io/archives/qt-4.8/installation.html
- A PyQt5 tutorial: https://www.pythonguis.com/pyqt5/
- https://courspython.com
- Ingemar Ragnemalm in Trabskell 5 has the file QDCG.pas, which is quite a complete
reference for the obsolete QuickDraw API from Apple. Probably a bit overkill for my
needs, probably, but still useful. https://twokinds.se/yh/transskel5/
- Roland Chastain has written several chess programs (both chess engines and chess
graphical user interfaces) in FreePascal. Quite active, and he speeks french! His Github
is a good central place for Pascal chess-related stuff: https://github.com/rchastain