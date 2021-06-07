#!/usr/bin/env python3

# File carbon.py : a library to attack Qt using a text protocol,
#                  using the standard input and output.
#
#
# Usage :
#     python3 carbon.py
#     python3 carbon.py [-echo] [-echo_input] [-echo_output] [-file name]
#


# Step 1. Import necessary modules

import csv
import sys
import os
import threading
from PyQt5.QtWidgets import QApplication, QWidget, QLabel
from PyQt5.QtGui     import QPixmap
from PyQt5.Qt        import Qt



# Step 2. Set global variables by analyzing the command line arguments

script_args       = sys.argv[1:]                   # the list of arguments to the script
echo              = "-echo"        in script_args  # True or False
echo_input        = "-echo_input"  in script_args  # True or False
echo_output       = "-echo_output" in script_args  # True or False

input_file_name = ""                               # the name of the script to be played
if "-file" in script_args :
   f = script_args.index("-file")
   if f >= 0:
      input_file_name = script_args[f+1]

line_counter      = 0                              # a global counter for the lines received by the GUI server
PROTOCOL_PREFIX   = "CARBON-PROTOCOL "             # prefix for the protocol commands


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
        while answer == "OK" :
            answer = self.callback(input())

        if answer == "quit" :
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
    message = 'GUI [{:4d}] < {}'.format(line_counter, line.strip())
    dispatch_message(message)
    if line == "quit" :
        print("...quitting the Carbon-GUI server, bye...")
        return "quit"
    else :
        return "OK"


def read_input_file(name):
   """
   Read the given file, and send it line by line to the server
   """
   if name != "" :
      with open(name) as fp :
         for line in fp :
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



def dispatch_message(message):
   """
   Interprets the message with the Carbon Gui protocol.

   See the torture.txt file for some examples, or run the following command:
     python3 carbon.py -echo -file torture.txt
   """
   lines = message.splitlines()
   for line in lines :
      line = line.strip()
      occ = line.find(PROTOCOL_PREFIX)

      if occ < 0 :
         if echo or echo_input :
            print(bcolors.FAIL + line + bcolors.RESET)

      if occ >= 0 :
         lexems = csv_split(line[occ+len(PROTOCOL_PREFIX):len(line)])
         if len(lexems) > 0 :
            command = lexems[0]
            args    = lexems[1:]
            if echo or echo_output :
               print(bcolors.OK + "GUI [exec] >", command, args, bcolors.RESET)


def csv_split(s):
    """
    Like split(), but preserving spaces in double-quoted strings

    See explications in the following thread:
    https://stackoverflow.com/questions/79968/split-a-string-by-spaces-preserving-quoted-substrings-in-python
    """

    lexems = list(csv.reader([s], delimiter=' '))[0]
    return list(filter(lambda s: s != "", lexems))



class bcolors:
    """ A class to declare constants for colored ANSI Codes """

    OK = '\033[92m' #GREEN
    WARNING = '\033[93m' #YELLOW
    FAIL = '\033[91m' #RED
    RESET = '\033[0m' #RESET COLOR


class HelloWorldWindow(QWidget):
    """
    A class (in Qt) to demonstrate the creation of an "About box" window
    """

    def __init__(self) :
      """
        Constructor for the class
      """
      super().__init__()
      self.initializeUI()


    def initializeUI(self) :
      """
         Set the size and title of the window, and shows it
      """
      self.setGeometry(100,100,250,250)
      self.setWindowTitle('About box')
      self.displayLabels()
      self.show()


    def displayLabels(self) :
      """
      Displays a small text and an image in the window.
      """

      # Creates and display the text
      text = QLabel(self)
      text.setText("Hello")
      text.move(105, 15)

      # Check to see if image files exist, if yes show it, otherwise throw an exception
      image = "images/world.png"
      try :
         with open(image):
            world_image = QLabel(self)
            pixmap = QPixmap(image).scaledToHeight(200, Qt.SmoothTransformation)
            world_image.setPixmap(pixmap)
            world_image.move(25, 40)
      except FileNotFoundError:
         print("Image not found.")



# If run from the command line, the Python script will execute this code:

if __name__ == "__main__":

    # main app from Qt
    app = QApplication(sys.argv)

    # start the standard input thread
    input_thread = StandardInputThread(server_callback)

    # read the (optional) input file, which should contain
    # a sequence of lines using the CARBON-PROTOCOL
    read_input_file(input_file_name)

    # open the about box (this is programmed in Qt)
    window = HelloWorldWindow()

    # clean exit for the Qt app
    sys.exit(app.exec_())









    