""" Interface with the VideoCapture library """

# Developed by Goel Biju (2016)
# https://github.com/GoelBiju/

import time
import os
import sys

# import Tkinter
# import Image, ImageTk

from VideoCapture import Device
# from subprocess import Popen, PIPE

# Webcam instance; must use "del cam" in this case to stop using the webcam.
cam = Device()

# tkpi = ImageTk.PhotoImage(cam.getImage())

##def button_click_exit_mainloop (event):
##    event.widget.quit() # this will cause mainloop to unblock.

# Basic Tkinter settings.
##root = Tkinter.Tk()
##root.bind("<Button>", button_click_exit_mainloop)
##root.geometry('+%d+%d' % (100,100))

#dirlist = os.listdir('.')
#old_label_image = None

# for f in dirlist:

##while True:
##    try:
##        # image1 = Image.open(f)
##        image1 = cam.getBuffer()
##        root.geometry('%dx%d' % (image1.size[0],image1.size[1]))
##        tkpi = ImageTk.PhotoImage(image1)
##        label_image = Tkinter.Label(root, image=tkpi)
##        label_image.place(x=0,y=0,width=image1.size[0],height=image1.size[1])
##        root.title('Live Webcam')
##        if old_label_image is not None:
##            old_label_image.destroy()
##        old_label_image = label_image
##        root.mainloop() # wait until user clicks the window
##    except Exception, e:
##        # This is used to skip anything not an image.
##        # Image.open will generate an exception if it cannot open a file.
##        # Warning, this will hide other errors as well.
##        pass



# Save an snapshot taken with the webcam.
cam.saveSnapshot('snapshot.jpg', only_show=True)

# Delete the webcam instance that was generated; this will free the camera from Python,
# if it is not deleted, the instance will remain until the script is restarted.
del cam

# The buffer that is generated from the image taken.
# buf, width, height = cam.getBuffer()

# cam.saveSnapshot(only_show=True)
# time.sleep(5)

# print  "Length of buffer:", len(buf), "Width of image:", width, "Height of image:", height

# args = ["ffmpeg.exe", "-y", "-f", "rawvideo", "-vcodec", "rawvideo", "-i", "-", "-an", "-vcodec", "mpeg"]

# pipe = Popen(args, stdin=PIPE, stderr=PIPE, stdout=PIPE)

# buf = str(buf)
# pipe.stdin.write(buf)