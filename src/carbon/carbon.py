#!/usr/bin/env python3

# File carbon.py: a library to attack Qt using a text protocol,
#                  using the standard input and output.
#
#
# Usage:
#     python3 carbon.py
#     python3 carbon.py [-file name] [-echo] [-echo_input] [-echo_output] [-colored]
#


#   Note : qt4-mac has the following notes:
#   Users experiencing graphics glitches on newer OS versions (10.13 and up) can
#   experiment with different graphics drawing systems that can be set in the Interface
#   tab of the /Applications/MacPorts/Qt4/qtconfig.app utility. Raster mode is the
#   preferred mode but is not compatible with all non-standard widget styles. Keep an
#   eye on the Fonts setting before saving!


# Step 1. Import necessary modules

import csv
import sys
import os
import threading

from PyQt4.QtGui import QApplication
from PyQt4.QtGui import QWidget
from PyQt4.QtGui import QLabel
from PyQt4.QtGui import QPixmap
from PyQt4.Qt    import Qt


# Step 2. Set global variables by analyzing the command line arguments

script_args       = sys.argv[1:]                   # the list of arguments to the script
echo              = "-echo"        in script_args  # flag to echo both input and output
echo_input        = "-echo_input"  in script_args  # flag to echo only input
echo_output       = "-echo_output" in script_args  # flag to echo only output
colored           = "-colored"     in script_args  # flag to use colored echo (need a Terminal with ANSI support)

input_file_name = ""                               # the name of the script to be played
if "-file" in script_args:
   f = script_args.index("-file")
   if f >= 0:
      input_file_name = script_args[f+1]

line_counter      = 0                              # a global counter for the lines received by the GUI server
PROTOCOL_PREFIX   = "CARBON-PROTOCOL "             # prefix for the protocol commands


class colors:
    """ A class to declare constants for colored ANSI Codes """

    OK      = '\033[92m'  # GREEN
    WARNING = '\033[93m'  # YELLOW
    FAIL    = '\033[91m'  # RED
    RESET   = '\033[0m'   # RESET COLOR



# Step 3. Let's program the server

class StandardInputThread(threading.Thread):
    """
    A class creating a thread to listen to the standard input in a non-blocking way.
    The user can provide a callback function to treat each line of the input in turn.
    """

    def __init__(self,
                 callback = None,
                 name='standard-input-thread'):
        """
        Constructor for the server. The server will run in its own separate thread.
        """

        self.callback = callback
        super(StandardInputThread, self).__init__(name=name)
        self.start()


    def run(self):
        """
        This is the main loop of the server thread
        """

        answer = "OK"

        # loop and wait to get input + Return
        while answer == "OK":
            answer = self.callback(input())

        if answer == "quit":
            # hard exit of the whole process without calling
            # cleanup handlers, flushing stdio buffers, etc.
            os._exit(0)



def server_callback(line):
    """
    Evaluates the keyboard input. The convention is that the callback function should
    return "OK" on normal lines. Returning anything else (for instance "quit") will
    stop the line listening of the GUI server.
    """

    global line_counter
    line_counter += 1

    line = line.strip()

    if line != "":
        dispatch_message('GUI [{:4d}] < {}'.format(line_counter, line))
        if line == "quit":
            print("...quitting the Carbon-GUI server, bye...", flush=True)
            return "quit"

    return "OK"


def read_input_file(name):
   """
   Read the given file, and send it line by line to the server
   """
   if name != "":
      with open(name) as fp:
         for line in fp:
            simulate_server_line(line)


def simulate_server_line(message):
   """
   Simulates the entry of a line on the standard input
   """
   server_callback(message.strip())



def simulate_carbon_gui(line):
   """
   Simulates the entry of a line on the standard input,
   with the "CARBON-PROTOCOL " prefix.
   """
   server_callback(PROTOCOL_PREFIX + line.strip())



def execute_carbon_protocol(command, args):
    """
    This is the core of the library, which transforms the commands of the
    CARBON-PROTOCOL into real Qt objects and calls
    """

    # A lambda to tag a command as not implemented yet.
    def not_implemented() :
       if colored:
           print(colors.OK + "GUI [exec] > NOT IMPLEMENTED: {}".format(command), colors.RESET, flush=True)
       else:
           print("GUI [exec] > NOT IMPLEMENTED: {}".format(command), flush=True)

    # Should we echo each line?
    if echo or echo_output:
        if colored:
           print(colors.OK + "GUI [exec] ? {} {}".format(command, args), colors.RESET, flush=True)
        else:
           print("GUI [exec] ? {} {}".format(command, args), "\n", flush=True)

    # A long switch for the various commands, implementing each command with Qt.
    #
    # Note: most common commands should be near the top for better performance.
    if command == "get-mouse"    :
       not_implemented()
    elif command == "new-window" :
       not_implemented()
    elif command == "set-window-title"  :
       not_implemented()
    elif command == "set-window-geometry"  :
       not_implemented()
    elif command == "show-window"  :
       not_implemented()
    else:
       not_implemented()


def dispatch_message(message):
   """
   Interprets the message with the Carbon Gui protocol.

   See the torture.txt file for some examples, or run the following command:
         python3 carbon.py -file torture.txt -echo -colored
   """
   lines = message.splitlines()
   for line in lines:
      line = line.strip()
      if line != "":
         occ = line.find(PROTOCOL_PREFIX)

         if occ < 0:
            if echo or echo_input:
               if colored:
                  print(colors.FAIL + line + colors.RESET, flush=True)
               else:
                  print(line, flush=True)

         if occ >= 0:
            lexems = csv_split(line[occ+len(PROTOCOL_PREFIX):len(line)])
            if len(lexems) > 0:

               command = lexems[0]
               args    = lexems[1:]
               execute_carbon_protocol(command, args)


def csv_split(s):
    """
    Like split(), but preserving spaces in double-quoted strings

    See explications in the following thread:
    https://stackoverflow.com/questions/79968/split-a-string-by-spaces-preserving-quoted-substrings-in-python
    """

    lexems = list(csv.reader([s], delimiter=' '))[0]
    return list(filter(lambda s: s != "", lexems))


class HelloWorldWindow(QWidget):
    """
    A class (in Qt) to demonstrate the creation of an "About box" window
    """

    def __init__(self):
      """
        Constructor for the class
      """
      super().__init__()
      self.initializeUI()


    def initializeUI(self):
      """
         Set the size and title of the window, and shows it
      """
      self.setGeometry(100,100,250,250)
      self.setWindowTitle('About box')
      self.displayLabels()
      self.show()


    def displayLabels(self):
      """
      Displays a small text and an image in the window.
      """

      # Creates and display the text
      text = QLabel(self)
      text.setText("Hello")
      text.move(105, 15)

      # Check to see if image files exist, if yes show it, otherwise throw an exception
      image = "images/world.png"
      try:
         with open(image):
            pixmap = QPixmap(image).scaledToHeight(200, Qt.SmoothTransformation)

            world_image = QLabel(self)
            world_image.setPixmap(pixmap)
            world_image.move(25, 40)

      except FileNotFoundError:
         print("Image not found.", flush=True)



# If run from the command line, the Python script will execute this code:

if __name__ == "__main__":

    # main app from Qt
    app = QApplication(sys.argv)

    # start the standard input thread
    input_thread = StandardInputThread(server_callback)

    # read the (optional) input file
    read_input_file(input_file_name)

    # open the about box (this is programmed in Qt)
    window = HelloWorldWindow()

    # clean exit for the Qt app
    res = app.exec_()
    sys.exit(res)









    