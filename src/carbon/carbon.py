#!/opt/local/bin/python3.9

####  Note : this librairy needs the PyQt4 or the PyQt5 module for python to be
####         installed. However, updating Python on your system may break PyQt4
####         or PyQt5, and you may need to re-install PyQt4 or PyQt5 for the new
####         distribution of Python. Once you have a working version of PyQt for
####         a specific Python version, you may edit the first line of this file
####         (shebang) to always launch carbon.py with the good Python version.
####
####         To see all your Python installations and find out which ones have
####         enough PyQt4 or PyQt5 support to use the carbon.py library, use:
####
####                python3 pyqt-search.py
####
####         Examples of shebang lines I have used in the past:
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


#  Note : qt4-mac has the following notes:
#  Users experiencing graphics glitches on newer OS versions (10.13 and up) can
#  experiment with different graphics drawing systems that can be set in the
#  Interface tab of the /Applications/MacPorts/Qt4/qtconfig.app utility. Raster
#  mode is the preferred mode but is not compatible with all non-standard widget
#  styles. Keep an eye on the Fonts setting before saving!


################################################################################
# Section 1. Import necessary modules
################################################################################

import csv
import sys
import os
import queue
import re
import threading
import time
import traceback
from pathlib import Path




################################################################################
# Section 2. Analyzing command line arguments
################################################################################

# Parse command line arguments
script_args  = sys.argv[1:]                   # list of arguments to the script

echo         = "-echo"        in script_args  # echo both input and output
echo_input   = "-echo_input"  in script_args  # echo only input
echo_output  = "-echo_output" in script_args  # echo only output
colored      = "-colored"     in script_args  # use colored echo in Terminal
keep_alive   = "-keep_alive"  in script_args  # close server after one minute
pyqt5        = "-pyqt5"       in script_args  # use PyQt5 (default)
pyqt4        = "-pyqt4"       in script_args  # use PyQt4

# -echo implies both -echo_input and -echo_output
if echo :
    echo_input = True
    echo_output = True

# name of the script to be played
input_file_name   = ""                             #
if "-file" in script_args:
    f = script_args.index("-file")
    if f >= 0:
       input_file_name = script_args[f+1]

# default values
if not(pyqt5) and not(pyqt4) :
    pyqt5 = True


if pyqt5 :
    from PyQt5.QtCore    import pyqtSignal, QThread
    from PyQt5.QtWidgets import QApplication
    from PyQt5.QtWidgets import QWidget
    from PyQt5.QtWidgets import QLabel
    from PyQt5.QtWidgets import QFileDialog
    from PyQt5.QtWidgets import QTextEdit
    from PyQt5.QtGui     import QPixmap
    from PyQt5.QtGui     import QCursor
    from PyQt5.Qt        import Qt
elif pyqt4 :
    from PyQt4.QtCore    import QObject, pyqtSignal
    from PyQt4.QtGui     import QApplication
    from PyQt4.QtGui     import QWidget
    from PyQt4.QtGui     import QLabel
    from PyQt4.QtGui     import QFileDialog
    from PyQt4.QtGui     import QTextEdit
    from PyQt4.QtGui     import QPixmap
    from PyQt4.QtGui     import QCursor
    from PyQt4.Qt        import Qt


################################################################################
# Section 3. Define a couple of helpers (time, scheduling, encodings, stats...)
################################################################################

starting_time = time.time()  # starting time of the library

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


def is_main_thread() :
    return threading.current_thread() is threading.main_thread()


def my_url_encode(s) :
    """
    my_url_encode() encodes space, quotes and newline caracters in the given
    string into their url-encoding equivalents. Useful when sending strings
    with our server, since the protocol is a textual, line by line protocol.
    """
    s = s.replace( ' '        , "%20" )
    s = s.replace( '"'        , "%22" )
    s = s.replace( "'"        , "%27" )
    s = s.replace( os.linesep , "%0A" )   # linefeed
    return s


def my_url_decode(s) :
    """
    my_url_decode() is the reverse of my_url_encode()
    """
    s = s.replace( "%0A" , os.linesep )   # linefeed
    s = s.replace( "%27" ,        "'" )
    s = s.replace( "%22" ,        '"' )
    s = s.replace( "%20" ,        ' ' )
    return s


class colors:
    """
    A class to declare constants for colored ANSI Codes
    """

    OK      = '\033[92m'  # GREEN
    WARNING = '\033[93m'  # YELLOW
    FAIL    = '\033[91m'  # RED
    RESET   = '\033[0m'   # RESET COLOR

class stats:
    """
    a class to print some stats about the commands received, implemented, etc.
    """

    total                = 0
    not_implemented      = 0
    partialy_implemented = 0

def print_stats():
    total           = stats.total
    not_implemented = stats.not_implemented
    partial         = stats.partialy_implemented
    implemented     = total - not_implemented - partial

    def pct(n) :
        if total <= 0 :
            return ""
        return " (" + str(round(100 * n / total, 2)) + " %)"

    fmt = lambda x: "{: 5d}".format(x)

    print("===========================================")
    print("CARBON-PROTOCOL lines : ", fmt(total))
    print("implemented           : ", fmt(implemented),     pct(implemented))
    print("partialy implemented  : ", fmt(partial),         pct(partial))
    print("not implemented       : ", fmt(not_implemented), pct(not_implemented))
    print("===========================================")



################################################################################
# Section 4. Let's program the server !
################################################################################

last_command_time = now()  # time of the last received command
KEEP_ALIVE_DELAY = 60      # delay before killing the server (needs -keep_alive)


def check_alive() :
    """
    This function can be scheduled every 5 seconds (say) to send a beat to the
    standard output, telling the outer world that our server is still alive.
    Reciprocally, this function will also try to kill the server if the server
    has not received any command during the last 60 seconds (KEEP_ALIVE_DELAY)
    """

    if (keep_alive) :
        s = "{"+str(line_counter)+"} "
        s = s + " now = "+ (str(now())[0:8])
        s = s + " , last_command_time = "+ (str(last_command_time)[0:8])
        print(s , flush=True)

    if (keep_alive and (now() - last_command_time > KEEP_ALIVE_DELAY + 3)) :
        #app.exit(0)
        os._exit(-1)


#class StandardInputThread(threading.Thread):
class StandardInputThread(QThread):
    """
    A thread listening to the standard input in a non-blocking way.
    The user can provide a callback function to treat each line of the input.
    """

    protocolSignal = pyqtSignal(int)

    def __init__(self,
                 callback = None) :
        """
        Constructor. The server will run in its own separate thread.
        """

        self.callback = callback

        #super(StandardInputThread, self).__init__(name=name)
        super().__init__()

        global last_command_time
        last_command_time = now()

        self.start()


    def run(self):
        """
        This is the main loop of the server thread
        """

        answer = "ready"

        self.protocolSignal.emit(0)

        # loop and wait to get input + Return
        while answer == "ready":
            answer = self.callback(input())

        if answer == "quit" :
            # hard exit of the whole process without calling
            # cleanup handlers, flushing stdio buffers, etc.
            os._exit(0)


line_counter = 0   # global counter for the lines received by the GUI server


def server_callback(line):
    """
    Evaluates the keyboard input. The convention is that the callback function
    should return "ready" on normal lines, while returning anything else (for
    instance "quit") will stop the line listening of the GUI server.
    """

    global line_counter
    line_counter += 1

    global last_command_time
    last_command_time = now()
    check_alive()

    line = line.strip()

    if line != "":
        line2 = 'GUI [{:4d}] < {}'.format(line_counter, line)
        tasks.put(line2)
        input_thread.protocolSignal.emit(0)

        if line == "quit":
            print("...quitting the Carbon-GUI server, bye...", flush=True)
            print_stats()
            app.exit(0)
            os._exit(0)
            return "quit"

    return "ready"


def simulate_server_line(message):
   """
   Simulates the entry of a line on the standard input
   """
   line = message.strip()
   if line :
       server_callback(line)


def read_input_file(name):
   """
   Read the given file, and send it line by line to the server
   """
   if name != "":
      with open(name) as fp:
         for line in fp:
            if (len(line) > 0) and (line[0] != '#') :
                if line[0] == '@' :
                    line = PROTOCOL_PREFIX + "{" + str(line_counter) + "}" + line[1:]
                simulate_server_line(line)



################################################################################
# Section 5. Implement the CARBON-PROTOCOL
################################################################################


# prefix for the protocol commands
PROTOCOL_PREFIX = "CARBON-PROTOCOL "

def simulate_carbon_gui(line):
   """
   Simulates the entry of a line on the standard input,
   with the "CARBON-PROTOCOL " prefix.
   """
   server_callback(PROTOCOL_PREFIX + line.strip())


def init(args):
   """
   Init the carbon.py process
   """
   return

def get_mouse(args):
   """
   Returns the current mouse position as a string
   """
   where = QCursor.pos()
   return str(where.x()) + " " + str(where.y())


def quit(args):
   """
   Clean up the carbon.py process
   """
   simulate_server_line("quit")
   return


def open_file_dialog(args):
    """
    Blocking call, showing the usual system dialog for file selection. The
    returned value is the complete path of the file selected by the user, or
    the empty string if the user has canceled the dialog.
    """
    stats.partialy_implemented = stats.partialy_implemented + 1

    options = QFileDialog.Options()
    # options |= QFileDialog.DontUseNativeDialog

    caption   = find_named_parameter("prompt", args)
    directory = find_named_parameter("dir", args)
    filter    = find_named_parameter("filter", args)

    if caption   is None : caption   = args[0]
    if directory is None : directory = args[1]
    if filter    is None : filter    = args[2]

    caption   = my_url_decode(caption)
    directory = my_url_decode(directory)
    filter    = my_url_decode(filter)

    filename = QFileDialog.getOpenFileName(
            parent    = None,
            caption   = caption,
            directory = directory,
            filter    = filter,
            options   = options )

    if (type(filename) is tuple) :   # pyqt5 returns a couple, pyqt4 not
        filename = filename[0]

    result = ""
    if filename :
        result = my_url_encode(str(Path(filename)))

    return ("\"{}\"".format(result))


def GUI_execution_to_string(s) :
    s = "GUI [exec] " + s
    if colored:
        s = colors.OK + s + " " + colors.RESET
    return s


def interpret_carbon_protocol(id, command, args):
    """
    This is the core of the library, which transforms the commands of the
    CARBON-PROTOCOL into real Qt objects and calls.
    """

    stats.total = stats.total + 1

    # function to tag a command as not implemented yet
    def not_implemented(id, command) :
       stats.not_implemented = stats.not_implemented + 1
       return GUI_execution_to_string("> {} NOT IMPLEMENTED: {}".format(id, command))

    # function to use when a command is a function returning a result
    def send_result(result) :
       return "{} {} => {}".format(id, command, result)

    # function to use when a command is a procedure returning no result
    def acknowledge(id, command) :
       return "{} OK".format(id)

    # Should we echo each line?
    if echo_output:
        print(GUI_execution_to_string("? {} {} {}".format(id, command, args)), flush=True)

    # A long switch for the various commands, implementing each command with Qt.
    # Note: most common commands should be near the top for better performance.

    result = None
    unknown = False

    if   command == "get-mouse"           :  result = get_mouse(args)
    elif command == "open-file-dialog"    :  result = open_file_dialog(args)
    elif command == "quit"                :  result = quit(args)
    elif command == "init"                :  result = init(args)
    else :
       unknown = True

    if result != None :
       return send_result(result)
    elif unknown :
       return not_implemented(id, command)
    else :
       return acknowledge(id, command)


def strip_quotes(s):
    """
    Removes one pair of quotes around the string, if any
    """
    if s and (s[0] == '"' or s[0] == "'") and s[0] == s[-1] :
        return s[1:-1]
    else :
        return s

def quoted_split(s):
    """
    Like split(), but preserving spaces in double-quoted strings. See
    explications and examples in the following thread:
    https://stackoverflow.com/questions/79968/split-a-string-by-spaces-preserving-quoted-substrings-in-python
    """
    return [strip_quotes(p).replace('\\"', '"').replace("\\'", "'") \
            for p in re.findall(r'(?:[^"\s]*"(?:\\.|[^"])*"[^"\s]*)+|(?:[^\'\s]*\'(?:\\.|[^\'])*\'[^\'\s]*)+|[^\s]+', s)]


def find_named_parameter(name, args) :
    """
    Search a parameter called 'name' in the given list (syntax: 'name="value"').
    If the name is found, the function removes the parameter from the list and
    returns the value. If the name is not found, the function returns None.
    """
    for arg in args :
       (param , sep , value) = arg.partition('=')
       if (param == name) and (sep == '=') :
           args.remove(arg)
           return strip_quotes(value)
    return None


def parse_carbon_protocol(message):
   """
   Interprets the message with the Carbon Gui protocol. See the torture.txt
   file for some examples, or run the following command:
         python3 carbon.py -file torture.txt -echo -colored
   """
   lines = message.splitlines()
   for line in lines:
      line = line.strip()
      if (line != "") :
         occ = line.find(PROTOCOL_PREFIX)

         if occ < 0:
            if echo_input:
               if colored:
                  print(colors.FAIL + line + colors.RESET, flush=True)
               else:
                  print(line, flush=True)

         if occ >= 0:
            lexems = quoted_split(line[occ+len(PROTOCOL_PREFIX):len(line)])
            if len(lexems) > 0:

               id      = lexems[0]
               command = lexems[1]
               args    = lexems[2:]

               answer = interpret_carbon_protocol(id, command, args)
               print(answer, flush=True)



################################################################################
# Section 6. Program something in PyQT to get familiar with the library :-)
################################################################################

class HelloWorldWindow(QWidget):
    """
    A class (in Qt) to demonstrate the creation of an "About box" window
    """

    def __init__(self, server=None):
        """
        Constructor for the class
        """
        super().__init__()
        self.initializeUI()

        server.protocolSignal.connect(self.execute_from_main_thread)

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

        # Create a text editor
        textEditor = QTextEdit(self)
        textEditor.setText("Bienvenue dans Cassio…")
        textEditor.append("tapez du texte :-)")
        textEditor.show()

        # Check to see if image files exist and show it (can throw exception)
        image = "images/world.png"
        try:
            with open(image):
                pixmap = QPixmap(image).scaledToHeight(200, Qt.SmoothTransformation)
                world_image = QLabel(self)
                world_image.setPixmap(pixmap)
                world_image.move(25, 40)

        except FileNotFoundError:
            print("Image not found.", flush=True)


    def execute_from_main_thread(self) :
        while True:
            next_task = ""
            try:
                next_task = tasks.get(block=False)
            except queue.Empty:
                next_task== ""

            if next_task :
                result = parse_carbon_protocol(next_task)
            else :
               break



################################################################################
# Section 7. Main : if run from the command line, the script will start here
################################################################################

if __name__ == "__main__":

    app = QApplication(sys.argv)
    
    tasks = queue.Queue()

    # start the standard input thread
    input_thread = StandardInputThread(server_callback)
    
    # open the about box (this is programmed in Qt)
    window = HelloWorldWindow(server=input_thread)

    # schedule a job every 5 seconds to check keep_alive
    if (keep_alive) :
        threading.Thread(daemon=True, target=lambda: every(5, check_alive)).start()

    # read the (optional) input file
    if (input_file_name != "") :
        read_input_file(input_file_name)

    # clean exit for the Qt app
    res = app.exec_()
    sys.exit(res)








