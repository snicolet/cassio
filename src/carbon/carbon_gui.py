#!/usr/bin/env python3

# carbon_gui.py

# Import necessary modules
import sys
import threading

from PyQt5.QtWidgets import QApplication, QWidget, QLabel
from PyQt5.QtGui     import QPixmap
from PyQt5.Qt        import Qt



class StandardInputThread(threading.Thread):
    """
    A class creating a thread to listen to the standard input in a non-blocking way.
    The user can provide a callback function to treat each line of the input in turn.
    """

    def __init__(self, callback = None, name='standard-input-thread'):
        self.callback = callback
        super(StandardInputThread, self).__init__(name=name)
        self.start()

    def run(self):
        answer = "OK"
        while answer == "OK" :
            answer = self.callback(input())  # waits to get input + Return


# a global counter for the messages of the GUI server
message_counter = 0 

def my_callback(message):
    """
    Evaluates the keyboard input. The convention is that the callback function should
    return "OK" on normal messages. Returning anything else (for instance "quit") will
    stop the message listening of the GUI server.
    """
    
    global message_counter
    message_counter += 1
    print('GUI [{}] < {}'.format(message_counter, message))
    if message == "quit" :
        return "quit"
    else :
        return "OK"


class HelloWorldWindow(QWidget):
  """
  A class to demonstrate the creation of an "About box" window
  """

  def __init__(self) :
    super().__init__()
    self.initializeUI()
    
  def initializeUI(self) :
    self.setGeometry(100,100,250,250)
    self.setWindowTitle('About box')
    self.displayLabels()
    self.show()

  def displayLabels(self) :
    """
    Check to see if image files exist, if not throw an exception
    """
    text = QLabel(self)
    text.setText("Hello")
    text.move(105, 15)
    
    image = "images/world.png"
    try:
        with open(image):
            world_image = QLabel(self)
            pixmap = QPixmap(image).scaledToHeight(200, Qt.SmoothTransformation)
            world_image.setPixmap(pixmap)
            world_image.move(25, 40)
    except FileNotFoundError:
        print("Image not found.")


if __name__ == "__main__":
    app = QApplication(sys.argv)

    # start the standard input thread
    input_thread = StandardInputThread(my_callback)

    # open the about box
    window = HelloWorldWindow()

    sys.exit(app.exec_())
    
    
    
    
    
    
    
    