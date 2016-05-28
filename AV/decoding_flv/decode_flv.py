#!/usr/bin/env python2
# -*- coding: utf-8 -*-

#-------------------------------------------------------------------------------
# Name:          Decoding FLV files via FFVideo
# Purpose:
#
# Author(s):      
# PyPi Official: https://pypi.python.org/pypi/FFVideo
# Edited:        Goel (2016)
# Copyright:     (c) (no need for copyright under MIT license ...)
# Licence:       MIT <Place MIT licence here>
#-------------------------------------------------------------------------------

################################################################################
#def main():
#    pass
################################################################################

# Annotated ffvideo.pyx is avaiable at:
# https://bitbucket.org/zakhar/ffvideo/src/8ab403fc7286b66020814e8e498b0d9f605c3c5c/ffvideo/ffvideo.pyx?at=default&fileviewer=file-view-default

# avcodec_decode_video2 attributes at:
# https://ffmpeg.org/doxygen/2.7/group__lavc__decoding.html#ga99ee61b6dcffb7817a275d39da58cc74

################################################################################
# Some notes:
# Flow of data: VideoStream decodes frame ---> returns VideoFrame function variables
#               which contains other procedures e.g. image/ndarray to convert data further.
# Hence all the frames are decoded individually though returned as VideoFrame function variables.
# Possibility of editing the ffvideo.pyx to return decoded data individually straight away.
################################################################################

import ffvideo

# Possible ideas:
# • Manipulate decode next frame function to allow modify the encoded data which is decoded and returned as
# a VideoFrame attribute.
# • Create blank flv and 'pump' data into it whilst decoding next frame?

file_name = 'flvs/american_football.flv'

for frame in ffvideo.VideoStream(file_name):
    # Note: VideoStream frames all return VideoFrame frames where all the data has 
    #       been decoded in VideoStream.
    
    # Need to access VideoStream decoding functions and manipulate it to allow
    # for decoding of a single frame of data.
    
    # Accessible variables returned (from VideoFrame via VideoStream).
    # print frame.data # Please use with some caution; may cause interpreter crash.
    
    # Prints out the basic information from the VideoFrame that was generated, the data inside is
    # decoded and is in RGB format ready to be converted to an image using the PIL library.
    print "Frame dimensions (w/h/s): ", frame.width, frame.height, frame.size
    print "Frame mode:", frame.mode
    print "Frame timestamp:", frame.timestamp
    print "Frame number:", frame.frameno
    
    
    # Generate Image with PIL library in VideoFrame from this single frame data.
    frame.image().save('framenow.jpg')
    

################################################################################
#if __name__ == '__main__':
#    main()
################################################################################