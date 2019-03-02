# import Image and the graphics package Tkinter
import Tkinter
import sys
import Image, ImageTk

image_file = open(sys.path[0] + '\\snapshot.jpg', 'r')
im = Image.open(image_file)

root = Tkinter.Tk()
# A root window for displaying objects

 # Convert the Image object into a TkPhoto
tkimage = ImageTk.PhotoImage(im)

Tkinter.Label(root, image=tkimage).pack()
# Put it in the display window

root.mainloop() # Start the GUI