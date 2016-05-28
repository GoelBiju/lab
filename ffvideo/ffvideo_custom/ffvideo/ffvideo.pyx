# ffvideo.pyx
#
# Copyright (C) 2009 Zakhar Zibarov <zakhar.zibarov@gmail.com>
# Copyright (C) 2006-2007 James Evans <jaevans@users.sf.net>
#
# Annotated/edited version by Goel (2016)
#
# Was under GNU Public licence (v2+)


# Import from ffmpeg.pyd file.

from ffmpeg cimport *

cdef extern from "Python.h":
    object PyBuffer_New(int)
    object PyBuffer_FromObject(object, int, int)
    int PyObject_AsCharBuffer(object, char **, Py_ssize_t *) except -1

# Initialise libavformat and register all the muxers, demuxers and protocols.
# Set logging level.
av_register_all()
av_log_set_level(AV_LOG_ERROR);


class FFVideoError(Exception):
    pass

class DecoderError(FFVideoError):
    pass

class FFVideoValueError(FFVideoError, ValueError):
    pass

class NoMoreData(StopIteration):
    pass


FAST_BILINEAR = SWS_FAST_BILINEAR
BILINEAR = SWS_BILINEAR
BICUBIC = SWS_BICUBIC

# Set frame modes possible.
FRAME_MODES = {
    'RGB': PIX_FMT_RGB24,
    'L': PIX_FMT_GRAY8,
    'YUV420P': PIX_FMT_YUV420P
}


# TODO: Make custom class to handle decoding of a single frame of FLV1 data.

# Possibly retrieve codec by just "feeding" a sample file and then proceeding to decode a 
# single from using the codec context and AVPacket(?)

# General decoding in C (camviewer.c licensed to tc_client - https://ion.nu/): 
# https://gist.github.com/TechWhizZ199/08db731364c80cb365a1109c21d818bb

# VideoSingleFrameDecode to take custom video data (in FLV1 format) and decode it
# afterwards passing it to VideoFrame for further conversion.

# The allocation of codec(s)/context(s)/packet(s)/frame(s) in avcodec.c example:
# https://gist.github.com/TechWhizZ199/0774fab336f7d05929edeefb99cbfc3e


cdef class VideoSingleFrameDecode:
    """Class represents a single video data decoding process;
        in which the resulting frame can be passed on to VideoFrame"""
    
    ## Private ##
    # Context variables
    # We might not need the FormatContext as this is not a stream.
    # cdef AVFormatContext *format_ctx
    
    #################################
    cdef AVCodec *codec
    cdef AVCodecContext *codec_ctx
    #################################
    
    # Streams (unlikely we will need this since we are not using a file, 
    # instead just decoding a single AVPacket)
    # cdef int streamno
    # cdef AVStream *input_stream
    
    ##################################
    # Packet/Frame variables
    cdef AVPacket avpkt
    # Our custom video data; in_buf
    cdef uint8_t in_buf
    cdef int frame, got_picture, len
    cdef AVFrame *picture
    ##################################
    
    # We may not require the use of these variables
    # cdef int frameno
    # cdef int64_t _frame_pts
    
    # cdef int ffmpeg_frame_mode
    # cdef object __frame_mode
    
    ## Public ##
    cdef readonly object codec_name
    
    cdef readonly int width
    cdef readonly int height
    
    cdef readonly frame_width
    cdef readonly frame_height
    
    cdef public int scale_mode
    
    # Not sure if we actually need these two properties for what we are trying to acheive.
    property frame_mode:
        def __set__(self, mode):
            if mode not in FRAME_MODES:
                raise FFVideoValueError("Not supported frame mode")
            self.__frame_mode = mode
            self.ffmpeg_frame_mode = FRAME_MODES[mode]

        def __get__(self):
            return self.__frame_mode

    property frame_size:
        def __set__(self, size):
            try:
                fw, fh = size
            except (TypeError, ValueError), e:
                raise FFVideoValueError("frame_size must be a tuple (int, int)")
            if fw is None and fh is None:
                raise FFVideoValueError("both width and height cannot be None")

            if fw is None:
                self.frame_width = round(fh * <float>self.width / self.height / 2.0) * 2
                self.frame_height = round(fh / 2.0) * 2
            elif fh is None:
                self.frame_width = round(fw / 2.0) * 2
                self.frame_height = round(fw * <float>self.height / self.width / 2.0) * 2
            else:
                self.frame_width = round(fw / 2.0) * 2
                self.frame_height = round(fh / 2.0) * 2

        def __get__(self):
            return (self.frame_width, self.frame_height)
            
    # Initialise the required C variables
    def __cinit__(self, filename, frame_size=None, frame_mode='RGB',
                  scale_mode=BICUBIC):
                  
        # self.format_ctx = NULL
        self.codec_ctx = NULL
        self.picture = avcodec_alloc_frame() # Allocate frame here to save output that is decoded later.
        # self.duration = 0
        self.width = 0
        self.height = 0
        # self.frameno = 0
        # self.streamno = -1
    
    
    
# VideoStream to load the file and decode the frames appropriately.

cdef class VideoStream:
    """Class represents video stream"""

    # Private; internal
    cdef AVCodec *codec
    cdef AVFormatContext *format_ctx
    cdef AVCodecContext *codec_ctx
    
    # Testing variables
    cdef AVCodec *test_codec
    cdef AVCodecContext *test_codec_ctx
    cdef AVPacket test_packet
    cdef AVFrame *picture
    cdef uint8_t data

    cdef int streamno
    cdef AVStream *stream

    cdef AVPacket packet

    cdef int frameno
    cdef AVFrame *frame
    cdef int64_t _frame_pts

    cdef int ffmpeg_frame_mode
    cdef object __frame_mode

    # Public; passed on to other functions
    cdef readonly object filename
    cdef readonly object codec_name

    cdef readonly int bitrate # the average bitrate 
    cdef readonly double framerate
    cdef readonly double duration
    cdef readonly int width
    cdef readonly int height

    cdef readonly int frame_width
    cdef readonly int frame_height

    cdef public int scale_mode

    property frame_mode:
        def __set__(self, mode):
            if mode not in FRAME_MODES:
                raise FFVideoValueError("Not supported frame mode")
            self.__frame_mode = mode
            self.ffmpeg_frame_mode = FRAME_MODES[mode]

        def __get__(self):
            return self.__frame_mode

    property frame_size:
        def __set__(self, size):
            try:
                fw, fh = size
            except (TypeError, ValueError), e:
                raise FFVideoValueError("frame_size must be a tuple (int, int)")
            if fw is None and fh is None:
                raise FFVideoValueError("both width and height cannot be None")

            if fw is None:
                self.frame_width = round(fh * <float>self.width / self.height / 2.0) * 2
                self.frame_height = round(fh / 2.0) * 2
            elif fh is None:
                self.frame_width = round(fw / 2.0) * 2
                self.frame_height = round(fw * <float>self.height / self.width / 2.0) * 2
            else:
                self.frame_width = round(fw / 2.0) * 2
                self.frame_height = round(fh / 2.0) * 2

        def __get__(self):
            return (self.frame_width, self.frame_height)

    # Initialise the required C variables
    def __cinit__(self, filename, frame_size=None, frame_mode='RGB',
                  scale_mode=BICUBIC):
                  
        self.format_ctx = NULL
        self.codec_ctx = NULL
        self.frame = avcodec_alloc_frame() # Allocate frame here to save output that is decoded later.
        self.duration = 0
        self.width = 0
        self.height = 0
        self.frameno = 0
        self.streamno = -1

        # test variables intialisation
        self.test_codec_ctx = NULL
        self.picture = avcodec_alloc_frame()

    # Initialise everything else normally (ENTRY POINT)
    def __init__(self, filename, frame_size=None, frame_mode='RGB',
                 scale_mode=BICUBIC):
                 
        cdef int ret
        cdef int i
        
        # AVPacket general information regarding functions associated with it: 
        # https://ffmpeg.org/doxygen/2.8/group__lavc__packet.html

        # General file information settings
        self.filename = filename

        self.frame_mode = frame_mode
        self.scale_mode = scale_mode


        # Open the file for reading
        ret = avformat_open_input(&self.format_ctx, filename, NULL, NULL)
        if ret != 0:
            raise DecoderError("Unable to open file %s" % filename)

        # Get the stream information and place it into format_ctx
        ret = avformat_find_stream_info(self.format_ctx, NULL)
        if ret < 0:
            raise DecoderError("Unable to find stream info: %d" % ret)
            
        # See if there is actually a video stream present in the stream information
        for i in xrange(self.format_ctx.nb_streams):
            if self.format_ctx.streams[i].codec.codec_type == AVMEDIA_TYPE_VIDEO:
                self.streamno = i
                break
        else:
            raise DecoderError("Unable to find video stream")
            
        print "Located Stream Number (used for codec assignment):", self.streamno


        # AVStream object is created to store our stream
        self.stream = self.format_ctx.streams[self.streamno]
        self.framerate = av_q2d(self.stream.r_frame_rate)
        
        print "Located framerate:", self.framerate

        if self.stream.duration == 0 or self.stream.duration == AV_NOPTS_VALUE:
            self.duration = self.format_ctx.duration / <double>AV_TIME_BASE
        else:
            self.duration = self.stream.duration * av_q2d(self.stream.time_base)
            
        print "The duration of the file in the stream:", self.duration

        # Set the appropriate codec context, in this case flv
        self.codec_ctx = self.stream.codec
        self.codec = avcodec_find_decoder(22)
        # avcodec_find_decoder(self.codec_ctx.codec_id)
        
        # allocation test variables; FLV codec.
        # av_init_packet(&self.test_packet)
        # self.test_codec = avcodec_find_decoder(22)
        # self.test_codec_ctx = avcodec_alloc_context()

        if self.codec == NULL:
            raise DecoderError("Unable to get decoder")

        if self.frame_mode in ('L', 'F'):
            self.codec_ctx.flags |= CODEC_FLAG_GRAY

        self.width = self.codec_ctx.width
        self.height = self.codec_ctx.height


        # Open codec
        ret = avcodec_open2(self.codec_ctx, self.codec, NULL)
        if ret < 0:
            raise DecoderError("Unable to open codec")

        # For some videos, avcodec_open2 will set these to 0,
        # so we will only be using it if it is not 0, otherwise,
        # we rely on the resolution provided by the header.
        if self.codec_ctx.width != 0 and self.codec_ctx.height !=0:
            self.width = self.codec_ctx.width
            self.height = self.codec_ctx.height

        if self.width <= 0 or self.height <= 0:
            raise DecoderError("Video width/height is 0; cannot decode")

        if frame_size is None:
            self.frame_size = (self.width, self.height)
        else:
            self.frame_size = frame_size

        self.codec_name = self.codec.name
        self.bitrate = self.format_ctx.bit_rate
        
        
        # custom debugging (might work)
        print "The decoding starts here and is only intiated once."
        print "Decoding next ... <--- Proof that the pyx can be edited and then installed again."
        print "File name:", self.filename
        print "Codec name:", self.codec_name
        print "---> __decode_next_frame()\n"
        self.__decode_next_frame()

    def __dealloc__(self):
        if self.packet.data:
            av_free_packet(&self.packet)

        av_free(self.frame)
        if self.codec:
            avcodec_close(self.codec_ctx)
            self.codec_ctx = NULL
        if self.format_ctx:
            avformat_close_input(&self.format_ctx)

    def dump(self):
        print "max_b_frames=%s" % self.codec_ctx.max_b_frames
        av_log_set_level(AV_LOG_VERBOSE);
        av_dump_format(self.format_ctx, 0, self.filename, 0);
        av_log_set_level(AV_LOG_ERROR);
 
    # KEY FUNCTION
    def __decode_next_frame(self):
        cdef int ret
        cdef int frame_finished = 0
        cdef int64_t pts
        
        # custom vars (it might work)
        cdef int loop_count

        print "---> loop frame_finished"
        
        ########################################################################
        # KEY AREA
        while not frame_finished:
            loop_count += 1
            print "Loop decodes:", loop_count
            
            
            ret = av_read_frame(self.format_ctx, &self.packet)
            if ret < 0:
                raise NoMoreData("Unable to read frame. [%d]" % ret)
            
            if self.packet.stream_index == self.streamno:
                print "---> avcodec decode video2 initiated (decoding data in frame)"
                with nogil:
                    # AVPacket reference: https://ffmpeg.org/doxygen/2.8/structAVPacket.html
                    # Info on the variables that are passed to avcodec_decode_video2 function:
                    # self.codec_ctx is the codec context
                    # self.frame is the AVFrame in which the decoded frame is stored to
                    # Data inside an AVPacket is stored as uint8_t
                    # &self.packet is the input AVPacket containing the input buffer. You can create such packet with av_init_packet() and by then setting data and size.
                    
                    # Decode the FLV data in AVPacket (self.packet) using avcodec_decode_video2
                    # and store its output in an AVFrame (self.frame)
                    
                    ret = avcodec_decode_video2(self.codec_ctx, self.frame,
                                               &frame_finished, &self.packet)
                                               
                print "---> avcodec decode video2 completed (decoded data in frame)"
                
                if ret < 0:
                    av_free_packet(&self.packet)
                    raise IOError("Unable to decode video picture: %d" % ret)

                if self.packet.pts == AV_NOPTS_VALUE:
                    pts = self.packet.dts
                else:
                    pts = self.packet.pts

            print "---> Now freeing AVPacket (self.packet) with av_free_packet()"
            av_free_packet(&self.packet)
        ########################################################################

        # Print some information regarding the AVFrame that was generated.
        print "frame>> pict_type=%s" % "*IPBSip"[self.frame.pict_type],
        print "pts=%s, dts=%s, frameno=%s" % (pts, self.packet.dts, self.frameno),
        print "ts=%.3f" % av_q2d(av_mul_q(AVRational(pts-self.stream.start_time, 1), self.stream.time_base))

        self.frame.pts = av_rescale_q(pts-self.stream.start_time,
                                      self.stream.time_base, AV_TIME_BASE_Q)
        self.frame.display_picture_number = <int>av_q2d(
            av_mul_q(av_mul_q(AVRational(pts - self.stream.start_time, 1),
                              self.stream.r_frame_rate),
                     self.stream.time_base)
        )
        return self.frame.pts
        

    def dump_next_frame(self):
        pts = self.__decode_next_frame()
        print "pts=%d, frameno=%d" % (pts, self.frameno)
        print "f.pts=%s, " % (self.frame.pts,)
        print "codec_ctx.frame_number=%s" % self.codec_ctx.frame_number
        print "f.coded_picture_number=%s, f.display_picture_number=%s" % \
              (self.frame.coded_picture_number, self.frame.display_picture_number)

    def current(self):
        cdef AVFrame *scaled_frame
        cdef Py_ssize_t buflen
        cdef char *data_ptr
        cdef SwsContext *img_convert_ctx

        scaled_frame = avcodec_alloc_frame()
        if scaled_frame == NULL:
            raise MemoryError("Unable to allocate new frame")

        buflen = avpicture_get_size(self.ffmpeg_frame_mode,
                                    self.frame_width, self.frame_height)
        data = PyBuffer_New(buflen)
        PyObject_AsCharBuffer(data, &data_ptr, &buflen)

        # Image formatting
        with nogil:
            avpicture_fill(<AVPicture *>scaled_frame, <uint8_t *>data_ptr,
                       self.ffmpeg_frame_mode, self.frame_width, self.frame_height)

            img_convert_ctx = sws_getContext(
                self.width, self.height, self.codec_ctx.pix_fmt,
                self.frame_width, self.frame_height, self.ffmpeg_frame_mode,
                self.scale_mode, NULL, NULL, NULL)

            sws_scale(img_convert_ctx,
                self.frame.data, self.frame.linesize, 0, self.height,
                scaled_frame.data, scaled_frame.linesize)

            sws_freeContext(img_convert_ctx)
            av_free(scaled_frame)

        return VideoFrame(data, self.frame_size, self.frame_mode,
                          timestamp=<double>self.frame.pts/<double>AV_TIME_BASE,
                          frameno=self.frame.display_picture_number)

    def get_frame_no(self, frameno):
        cdef int64_t gpts = av_rescale(frameno,
                                      self.stream.r_frame_rate.den*AV_TIME_BASE,
                                      self.stream.r_frame_rate.num)
        return self.get_frame_at_pts(gpts)

    def get_frame_at_sec(self, float timestamp):
        return self.get_frame_at_pts(<int64_t>(timestamp * AV_TIME_BASE))

    def get_frame_at_pts(self, int64_t pts):
        cdef int ret
        cdef int64_t stream_pts

        stream_pts = av_rescale_q(pts, AV_TIME_BASE_Q, self.stream.time_base) + \
                    self.stream.start_time
        ret = av_seek_frame(self.format_ctx, self.streamno, stream_pts,
                            AVSEEK_FLAG_BACKWARD)
        if ret < 0:
            raise FFVideoError("Unable to seek: %d" % ret)
        avcodec_flush_buffers(self.codec_ctx)

        # if we hurry it we can get bad frames later in the GOP
        self.codec_ctx.skip_idct = AVDISCARD_BIDIR
        self.codec_ctx.skip_frame = AVDISCARD_BIDIR

        #self.codec_ctx.hurry_up = 1
        hurried_frames = 0
        while self.__decode_next_frame() < pts:
            pass

        #self.codec_ctx.hurry_up = 0

        self.codec_ctx.skip_idct = AVDISCARD_DEFAULT
        self.codec_ctx.skip_frame = AVDISCARD_DEFAULT

        return self.current()

    def __iter__(self):
        # rewind
        ret = av_seek_frame(self.format_ctx, self.streamno,
                            self.stream.start_time, AVSEEK_FLAG_BACKWARD)
        if ret < 0:
            raise FFVideoError("Unable to rewind: %d" % ret)
        avcodec_flush_buffers(self.codec_ctx)
        return self

    def __next__(self):
        self.__decode_next_frame()
        return self.current()

    def __getitem__(self, frameno):
        return self.get_frame_no(frameno)

    def __repr__(self):
        return "<VideoStream '%s':%.4f>" % (self.filename, <double>self.frame.pts/<double>AV_TIME_BASE)





# VideoFrame to store the AVFrame data that was decoded in VideoStream.

cdef class VideoFrame:
    cdef readonly int width
    cdef readonly int height
    cdef readonly object size
    cdef readonly object mode

    cdef readonly int frameno
    cdef readonly double timestamp

    cdef readonly object data

    def __init__(self, data, size, mode, timestamp=0, frameno=0):
        self.data = data
        self.width, self.height = size
        self.size = size
        self.mode = mode
        self.timestamp = timestamp
        self.frameno = frameno

    def image(self):
        if self.mode not in ('RGB', 'L', 'F'):
            raise FFVideoError('Cannot represent this color mode into PIL Image')

        try:
            import Image
        except ImportError:
            from PIL import Image
        return Image.frombuffer(self.mode, self.size, self.data, 'raw', self.mode, 0, 1)

    def ndarray(self):
        if self.mode not in ('RGB', 'L'):
            raise FFVideoError('Cannot represent this color mode into PIL Image')

        import numpy
        if self.mode == 'RGB':
            shape = (self.height, self.width, 3)
        elif self.mode == 'L':
            shape = (self.height, self.width)
        return numpy.ndarray(buffer=self.data, dtype=numpy.uint8, shape=shape)



