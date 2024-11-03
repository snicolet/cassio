#!/opt/local/bin/python3.9

# File carbon.py: a library to attack Qt using a text protocol,
#                  using the standard input and output.
#
# Usage:     ./carbon.py
#
#            ./carbon.py [-file filename]
#                        [-echo] [-echo_input] [-echo_output] [-colored]
#                        [-pyqt5] [-pyqt4]
#                        [-keep_alive]


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

    s = ""
    s += "\n==========================================="
    s += "\nCARBON-PROTOCOL lines : " + fmt(total)
    s += "\nimplemented           : " + fmt(implemented)     + pct(implemented)
    s += "\npartialy implemented  : " + fmt(partial)         + pct(partial)
    s += "\nnot implemented       : " + fmt(not_implemented) + pct(not_implemented)
    s += "\n===========================================\n"
    print(s, flush=True)


################################################################################
# Section 4. Implement the CARBON-PROTOCOL
################################################################################


if pyqt5 :
    from PyQt5.QtCore    import pyqtSignal, QThread, QPoint, QRect
    from PyQt5.QtWidgets import QApplication
    from PyQt5.QtWidgets import QWidget
    from PyQt5.QtWidgets import QLabel
    from PyQt5.QtWidgets import QFileDialog
    from PyQt5.QtWidgets import QTextEdit
    from PyQt5.QtGui     import QPixmap
    from PyQt5.QtGui     import QCursor
    from PyQt5.QtGui     import QPainter, QColor, QPen, QFont
    from PyQt5.Qt        import Qt
elif pyqt4 :
    from PyQt4.QtCore    import pyqtSignal, QThread
    from PyQt4.QtGui     import QApplication
    from PyQt4.QtGui     import QWidget
    from PyQt4.QtGui     import QLabel
    from PyQt4.QtGui     import QFileDialog
    from PyQt4.QtGui     import QTextEdit
    from PyQt4.QtGui     import QPixmap
    from PyQt4.QtGui     import QCursor
    from PyQt4.Qt        import Qt



PROTOCOL_PREFIX = "CARBON-PROTOCOL "  # prefix for the protocol commands
windows = {}                          # dictionary of existent windows
current_port = None                   # the current active grafport for drawing


class CarbonWindow(QWidget):
    """ 
    CarbonWindow is just a normal Qt window with a name
    """
    def __init__(self, name):
        super().__init__()
        self.setObjectName(name)
        self.modified = True
        self.currentPixmap = QPixmap()
        self.localPainter = None;
        self.localPixmap = None;
    
    def startPainter(self) :
        self.localPixmap = QPixmap(self.size())
        self.localPixmap.fill(Qt.white)
        self.localPainter = QPainter(self.localPixmap)
        self.localPainter.drawPixmap(0, 0, self.currentPixmap)
        return self.localPainter
    
    def endPainter(self) :
        self.currentPixmap = self.localPixmap
        self.update()

    def paintEvent(self, event):

        print("inside paintEvent()")
        
        
        painter = QPainter()
        painter.begin(self)
        
        painter.drawPixmap(0, 0, self.currentPixmap)
        
        #pen = QPen(QColor("#E00C0C"))
        #painter.setFont(QFont("Helvetica", 15))
        #painter.setPen(pen)
        #painter.drawText(int(h), int(v), text)
        
        painter.end()

def find_window(name) :
    """
    Find window by name in our list of open windows.
    The function returns the window if found, or None if not found.
    """
    global windows
    if name and (name in windows) :
        return windows[name]
    else :
        return None


def get_port(args):
   """
   Returns the name of the current grafport
   """

   global current_port
   try :
      ref = current_port.objectName()
   except Exception :
      ref = None

   return str(ref)


def set_port(args):
   """
   Set the current grafport
   """

   global current_port
   name = find_named_parameter("name", args, 0)
   window = find_window(name)
   if window :
      current_port = window

   return


def new_window(args):
   """
   Create a new window, and make it the current port
   """
   name = find_named_parameter("name", args, 0)

   if find_window(name) :
       error = "ERROR (new-window) : window with name '{}' already exists".format(name)
       return error
   else :
       # create a new window
       window = CarbonWindow(name)

       # add the window to the 'windows' directory, and set the current port
       global windows, current_port
       windows[name] = window
       current_port = window

   return


def set_window_title(args):
   """
   Set the title of a window
   """

   name  = find_named_parameter("name", args, 0)
   title = find_named_parameter("title", args, 1)

   window = find_window(name)
   if window and title:
       window.setWindowTitle(title)

   return


def set_window_geometry(args):
   """
   Set the geometry of a window
   """

   name      = find_named_parameter("name",   args, 0)
   left      = find_named_parameter("left",   args, 1)
   top       = find_named_parameter("top",    args, 2)
   width     = find_named_parameter("width",  args, 3)
   height    = find_named_parameter("height", args, 4)

   window = find_window(name)
   if window and left and top and width and height :
       window.setGeometry(int(left), int(top), int(width), int(height))

   return


def draw_text_at(args):
   """
   draw text at the given position
   """

   text = find_named_parameter("text", args, 0)
   h    = find_named_parameter("h", args, 1)
   v    = find_named_parameter("v", args, 2)

   window = current_port
   
   if window and text and h and v :

       painter = window.startPainter()

       pen = QPen(QColor("#000000"))
       painter.setFont(QFont("Helvetica", 15))
       painter.setPen(pen)
       painter.setRenderHint(QPainter.SmoothPixmapTransform, True);
       painter.drawText(int(h), int(v), text)
       
       
       text = "Don't look behind you"
       h = 105
       v = 35
        
       pen = QPen(QColor("#E00C0C"))
       painter.setFont(QFont("Helvetica", 15))
       painter.setPen(pen)
       painter.setRenderHint(QPainter.SmoothPixmapTransform, True);
       painter.drawText(int(h), int(v), text)
       
       window.endPainter()
       
       #label = QLabel(current_port)
       #label.setText(text)
       #label.move(int(h), int(v))
       
       #current_port.show()

   return
   

def show_window(args):
   """
   Show a window on the screen
   """

   name = find_named_parameter("name", args, 0)

   window = find_window(name)
   if window :
       window.show()

   return


def close_window(args):
   """
   Close a window (and all the widgets inside the window)
   """

   global current_port
   name = find_named_parameter("name", args, 0)

   window = find_window(name)
   if window :
       # close window
       window.close()

       # remove window from the "windows" directory
       windows.pop(name)
       if current_port.objectName() == name :
           current_port = None

   return


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


def dump(args):
    """
    Dump the content of the global variables
    """

    global windows, current_port

    s = ""
    s = s + "\n" + "windows = "      + str(windows)
    s = s + "\n" + "current_port = " + str(current_port)

    return s


def GUI_exec_to_str(s) :
    s = "[server] " + s
    if colored:
        s = colors.OK + s + " " + colors.RESET
    return s


def call(id, command, args):
    """
    This is the core of the library, which transforms the commands of the
    CARBON-PROTOCOL into real Qt objects and graphic calls, while also
    returning the answer to be written by the server on the standard output.

    The answer string can have the following format:

       {id} command-name => value              : the command returned a value
       {id} OK                                 : the command returned nothing
       {id} NOT IMPLEMENTED (command-name)     : the command is not implemented

    """

    stats.total = stats.total + 1

    # function to tag a command as not implemented yet
    def not_implemented(id, command) :
       stats.not_implemented = stats.not_implemented + 1
       return GUI_exec_to_str("!! {} NOT IMPLEMENTED ({})".format(id, command))

    # function to use when a command returns a result
    def format_result(result) :
       return "{} {} => {}".format(id, command, result)

    # function to use when a command is a procedure returning no result
    def acknowledge(id, command) :
       return "{} OK".format(id)

    # Should we echo each line?
    if echo_output:
        print(GUI_exec_to_str("?? {} {} {}".format(id, command, args)), flush=True)

    # A long switch for the various commands, implementing each command with Qt.
    # Note: most common commands should be near the top for better performance.

    result = None
    unknown = False

    if   command == "get-mouse"           :  result = get_mouse(args)
    elif command == "draw-text-at"        :  result = draw_text_at(args)
    elif command == "get-port"            :  result = get_port(args)
    elif command == "set-port"            :  result = set_port(args)
    elif command == "open-file-dialog"    :  result = open_file_dialog(args)
    elif command == "new-window"          :  result = new_window(args)
    elif command == "set-window-title"    :  result = set_window_title(args)
    elif command == "set-window-geometry" :  result = set_window_geometry(args)
    elif command == "show-window"         :  result = show_window(args)
    elif command == "close-window"        :  result = close_window(args)
    elif command == "init"                :  result = init(args)
    elif command == "dump"                :  result = dump(args)
    elif command == "quit"                :  result = quit(args)
    else :
       unknown = True

    if result != None :
       answer = format_result(result)
    elif unknown :
       answer = not_implemented(id, command)
    else :
       answer = acknowledge(id, command)

    return answer


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
    Like split(), but preserving spaces in double-quoted strings.
    See explications and examples in the following thread:
    https://stackoverflow.com/questions/79968/split-a-string-by-spaces-preserving-quoted-substrings-in-python
    """
    return [strip_quotes(p).replace('\\"', '"').replace("\\'", "'") \
            for p in re.findall(r'(?:[^"\s]*"(?:\\.|[^"])*"[^"\s]*)+|(?:[^\'\s]*\'(?:\\.|[^\'])*\'[^\'\s]*)+|[^\s]+', s)]


def find_named_parameter(name, args, index=-1) :
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

    if (len(args) > 0) and (index >= 0) :
        return args[index]

    return None


def execute_carbon_protocol(message):
   """
   This function parses and executes a message with the Carbon GUI protocol.
   See the torture.txt file for some examples, or run the following command:
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

               # call the graphical functions in Qt
               answer = call(id, command, args)

               # report result to the standard output stream
               print(answer, flush=True)


class GUI(QWidget):
    """
    This class is a GUI context in Qt (in the main thread)
    """

    def __init__(self, server=None):
        """
        Constructor for the class
        """
        super().__init__()
        server.jobsReady.connect(self.execute_from_main_thread)

        # dummy invisible window to keep Qt happy
        self.setGeometry(100,100,0,0)
        self.show()

    def execute_from_main_thread(self) :
        """
        This function execute the commands in the 'jobs' queue.

        The flow of control is as follow:
          1) the server listens to the standart input
          2) the server puts each line in the 'jobs' queue
          3) the server signals on 'jobsReady' after each line
          4) the GUI context (this class) listen the 'jobsReady' signal
          5) on receiving 'jobsReady', the GUI context eats each available
             line in the 'jobs' queue, execute it and sends the answer on
             the standard output.

        It is important for all the graphic manipulations to be done by Qt
        in the main thread, hence the communication between the two threads.
        """

        loop = True
        while loop:
            try:
                line = jobs.get(block=False)
            except queue.Empty :
                line = ""
                loop = False

            if line :
                execute_carbon_protocol(line)


################################################################################
# Section 5. Let's program the text server !
################################################################################

last_command_time = now()  # time of the last received command
KEEP_ALIVE_DELAY  = 60     # delay before kill of the server (needs -keep_alive)
READY            = "ready" # constant string

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


class StandardInputThread(QThread):
    """
    A thread listening to the standard input in a non-blocking way.
    The user can provide a callback function to treat each line of the input.
    """

    jobsReady = pyqtSignal(int)

    def __init__(self, callback = None) :
        """
        Constructor. The server will run in its own separate thread.
        """

        self.callback = callback
        super().__init__()
        global last_command_time
        last_command_time = now()

        self.start()


    def run(self):
        """
        This is the main loop of the server thread
        """

        answer = READY

        # loop and wait to get input + Return
        while answer == READY:
            try :
                line = input()
            except EOFError :
                line = ""
            answer = self.callback(line)

        if answer == "quit" :
            # hard exit of the whole process without calling
            # cleanup handlers, flushing stdio buffers, etc.
            os._exit(0)


line_counter = 0   # global counter for the lines received by the server


def server_callback(line):
    """
    Evaluates the keyboard input. The convention is that the callback function
    should return "ready" on normal lines, while returning anything else (for
    instance "quit") will stop the line listening of the server.
    """

    global line_counter
    line_counter += 1

    global last_command_time
    last_command_time = now()
    check_alive()

    line = line.strip()

    if line :

        if line[0] == '@' and line[1] == ' ' :
           line = PROTOCOL_PREFIX + "{" + str(line_counter) + "}" + line[1:]

        job = '[stdi]   << {}'.format(line)

        jobs.put(job)
        input_thread.jobsReady.emit(1)

        if line == "quit":
            print("...quitting the Carbon-GUI server, bye...", flush=True)
            print_stats()
            app.exit(0)
            os._exit(0)
            return "quit"

    return READY


def simulate_server_line(message):
   """
   Simulates the entry of a line on the standard input
   """
   line = message.strip()
   if line :
       server_callback(line)


def simulate_carbon_gui(message):
   """
   Simulates the entry of a line but with the "CARBON-PROTOCOL " prefix
   """
   line = message.strip()
   if line :
      server_callback(PROTOCOL_PREFIX + line)


def read_input_file(name):
   """
   Read the given file, and send it line by line to the server
   """
   if name != "":
      with open(name) as fp:
         for line in fp:
            if (len(line) > 2) and (line[0] != '#') :
                if line[0] == '@' and line[1] == ' ' :
                    line = PROTOCOL_PREFIX + "{" + str(line_counter) + "}" + line[1:]
                simulate_server_line(line)


################################################################################
# Section 6. Program something in PyQT to get familiar with the library :-)
################################################################################


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



################################################################################
# Section 7. Main : if run from the command line, the script will start here
################################################################################

if __name__ == "__main__":

    app = QApplication(sys.argv)
    jobs = queue.Queue()

    # start the standard input thread
    input_thread = StandardInputThread(server_callback)

    # schedule a job every 5 seconds to check keep_alive
    if (keep_alive) :
        daemon = threading.Thread(daemon=True, target=lambda: every(5, check_alive))
        daemon.start()

    # create the GUI context in the main thread
    gui = GUI(server=input_thread)

    # open the Hello World window (programmed in pure Qt)
    # window = HelloWorldWindow()

    # read the (optional) input file
    if (input_file_name != "") :
        read_input_file(input_file_name)

    # clean exit for the Qt app
    res = app.exec_()
    print("clean exit from Qt app with value :", res);

    simulate_server_line("quit")

    sys.exit(res)








