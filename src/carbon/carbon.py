#!/opt/local/bin/python3.9

####   note : this file needs the PyQt4 module for python to be installed.
####          However, updating Python may break PyQt4, and you may need to
####          re-install PyQt4 for the new version of Python. Once you have
####          a working version of the PyQt4 module for a good enough Python
####          version, you may edit the first line of this file (shebang) to
####          always launch carbon.py with the good Python version.
####              
####          To see all your Python installations, you can use:
####
####              ls -al /opt/local/bin/ 
####          
####          To check if a specific Python version has PyQt4, you can launch
####          it and then try to open the PyQt4 module:
####
####                /opt/local/bin/python3.9
####                import PyQt4.QtGui
####
####          Examples of shebang lines I have used in the past:
####
####                #!/usr/bin/env python3
####                #!/opt/local/bin/python3
####                #!/opt/local/bin/python3.9



# File carbon.py: a library to attack Qt using a text protocol,
#                  using the standard input and output.
#
#
# Usage :
#     ./carbon.py
#     ./carbon.py [-file name] [-echo] [-echo_input] [-echo_output] [-colored]
#


#   Note : qt4-mac has the following notes:
#   Users experiencing graphics glitches on newer OS versions (10.13 and up) can
#   experiment with different graphics drawing systems that can be set in the Interface
#   tab of the /Applications/MacPorts/Qt4/qtconfig.app utility. Raster mode is the
#   preferred mode but is not compatible with all non-standard widget styles. Keep an
#   eye on the Fonts setting before saving!


######################################################################################
# Section 1. Import necessary modules
######################################################################################

import csv
import sys
import os
import threading
import time
import traceback

# from PyQt4.QtGui import QApplication
# from PyQt4.QtGui import QWidget
# from PyQt4.QtGui import QLabel
# from PyQt4.QtGui import QPixmap
# from PyQt4.QtGui import QCursor
# from PyQt4.Qt    import Qt

from PyQt5.QtWidgets import QApplication
from PyQt5.QtWidgets import QWidget
from PyQt5.QtWidgets import QLabel
from PyQt5.QtGui     import QPixmap
from PyQt5.QtGui     import QCursor
from PyQt5.Qt        import Qt


#######################################################################################
# Section 2. Define a couple of helpers to deal with time and scheduling repeated tasks
#######################################################################################

starting_time = time.time()  # a global to to store the the starting time of the library

def now():
  """
  number of seconds since the start of the server
  """
  return time.time() - starting_time


def every(delay, job):
  """
  schedule a "job" function every "delay" seconds.
  usage : threading.Thread(target=lambda: every(5, foo)).start()
  """
  next_time = now() + delay
  while True:
      time.sleep(max(0, next_time - now()))
      try:
          job()
      except Exception:
          # in production code you might want to have this instead of course:
          # logger.exception("Problem while executing repetitive task.")
          traceback.print_exc()

      # skip tasks if we are behind schedule:
      next_time += (now() - next_time) // delay * delay + delay


#######################################################################################
# Section 3. Set global variables, in particular analyzing command line arguments
#######################################################################################

script_args       = sys.argv[1:]                   # the list of arguments to the script
echo              = "-echo"        in script_args  # flag to echo both input and output
echo_input        = "-echo_input"  in script_args  # flag to echo only input
echo_output       = "-echo_output" in script_args  # flag to echo only output
colored           = "-colored"     in script_args  # flag to use colored echo (need a Terminal with ANSI support)
keep_alive        = "-keep_alive"  in script_args  # flag to close the server after one minute

input_file_name   = ""                             # the name of the script to be played
if "-file" in script_args:
   f = script_args.index("-file")
   if f >= 0:
      input_file_name = script_args[f+1]


class colors:
    """ A class to declare constants for colored ANSI Codes """

    OK      = '\033[92m'  # GREEN
    WARNING = '\033[93m'  # YELLOW
    FAIL    = '\033[91m'  # RED
    RESET   = '\033[0m'   # RESET COLOR


#######################################################################################
# Section 4. Let's program the server
#######################################################################################

last_command_time = now()     # a global with the time of the last received command
communication_dead = False    # a global to force quit the server, if necessary

def check_alive() :
    s = "{"+str(line_counter)+"} "
    s = s + " now = "+ str(now())
    s = s + " , last_command_time = "+ str(last_command_time)
    if (keep_alive) :
        print(s , flush=True)
    
    global communication_dead
    if (keep_alive and (now() - last_command_time > 63)) :
        communication_dead = True;
        os._exit(0)


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
        
        global last_command_time
        last_command_time = now()
        
        self.start()


    def run(self):
        """
        This is the main loop of the server thread
        """

        answer = "OK"

        # loop and wait to get input + Return
        while answer == "OK":
            answer = self.callback(input())

        if (answer == "quit") or communication_dead :
            # hard exit of the whole process without calling
            # cleanup handlers, flushing stdio buffers, etc.
            os._exit(0)


line_counter = 0   # a global counter for the lines received by the GUI server


def server_callback(line):
    """
    Evaluates the keyboard input. The convention is that the callback function should
    return "OK" on normal lines. Returning anything else (for instance "quit") will
    stop the line listening of the GUI server.
    """

    global line_counter
    line_counter += 1
    
    global last_command_time
    last_command_time = now()
    check_alive()

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



#######################################################################################
# Section 5. Implement the CARBON-PROTOCOL
#######################################################################################


PROTOCOL_PREFIX = "CARBON-PROTOCOL "    # prefix for the protocol commands

def simulate_carbon_gui(line):
   """
   Simulates the entry of a line on the standard input,
   with the "CARBON-PROTOCOL " prefix.
   """
   server_callback(PROTOCOL_PREFIX + line.strip())
   

def get_mouse(id, command, args):
   """
   Write the current mouse position on the standard output
   """
   where = QCursor.pos()
   print("{} {} => {} {}".format(id, command, where.x(), where.y()), flush=True)
   
   
def execute_carbon_protocol(id, command, args):
    """
    This is the core of the library, which transforms the commands of the
    CARBON-PROTOCOL into real Qt objects and calls
    """

    # A lambda to tag a command as not implemented yet.
    def not_implemented() :
       if colored:
           print(colors.OK + "GUI [exec] > {} NOT IMPLEMENTED: {}".format(id, command), colors.RESET, flush=True)
       else:
           print("GUI [exec] > {} NOT IMPLEMENTED: {}".format(id, command), flush=True)

    # Should we echo each line?
    if echo or echo_output:
        if colored:
           print(colors.OK + "GUI [exec] ? {} {} {}".format(id, command, args), colors.RESET, flush=True)
        else:
           print("GUI [exec] ? {} {} {}".format(id, command, args), "\n", flush=True)

    # A long switch for the various commands, implementing each command with Qt.
    #
    # Note: most common commands should be near the top for better performance.
    if command == "get-mouse"    :
       get_mouse(id, command, args)
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


def csv_split(s):
    """
    Like split(), but preserving spaces in double-quoted strings

    See explications in the following thread:
    https://stackoverflow.com/questions/79968/split-a-string-by-spaces-preserving-quoted-substrings-in-python
    """

    lexems = list(csv.reader([s], delimiter=' '))[0]
    return list(filter(lambda s: s != "", lexems))


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

               id      = lexems[0]
               command = lexems[1]
               args    = lexems[2:]
               execute_carbon_protocol(id, command, args)


#######################################################################################
# Section 6. Program something in PyQT to learn the syntax of that library :-)
#######################################################################################

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



##########################################################################################
# Section 7. Main : if run from the command line, the Python script will execute this code
##########################################################################################

if __name__ == "__main__":

    # main app from Qt
    app = QApplication(sys.argv)

    # start the standard input thread
    input_thread = StandardInputThread(server_callback)
    
    # schedule a job every 5 seconds to check keep_alive
    threading.Thread(target=lambda: every(5, check_alive)).start()

    # read the (optional) input file
    read_input_file(input_file_name)

    # open the about box (this is programmed in Qt)
    window = HelloWorldWindow()

    # clean exit for the Qt app
    res = app.exec_()
    sys.exit(res)









    