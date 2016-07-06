#!/usr/bin/python
# -*- coding: utf-8 -*-

""" CSD Decoder - experimental """

import requests
from urllib import unquote


def csd_decode(raw_data, response_object=None):
    """
    Reads the raw response returned by the POST request.
    NOTE: This decodes the whole response taking into account any unicode encoding.

    
    :param response_object: requests response object.
    :return: str the response that was decoded.
    """
    decoded_content = ''
    all_bytes = []
    try:
        if response_object is not None:
            for byte in response_object.iter_content(decode_unicode=False):
                all_bytes.append(byte)
        else:
            for byte in raw_data:
                all_bytes.append(byte)
                
        sum_value = 0
            
        for piece in xrange(len(all_bytes)):
            buf = all_bytes[piece]
            if type(buf) is not int:
                buf = buf.strip()
                if len(buf) is not 0:
                    csd = ord(buf)
                    #print "CSD Value:", csd
                    individual = unichr(csd)
                    #print "Individual Value:", [individual]
                    sum_value += csd
                    decoded_content += ''.join([individual])
                    
        for x in xrange(len(decoded_content)):
            pass
                
        # Urllib unquoting.
        #decoded_content = unquote(content)
        print "Sum CSD:", sum_value
        return decoded_content
        
    # We really shouldn't be expecting any Unicode errors, however we shall handle for the eventuality.
    except UnicodeDecodeError:
        return None
        
# Lossless PNG
data_store = open('random-image-14.png').read()
print "To decode:", [data_store]
decoded_data = csd_decode(data_store)

ranfile = open('test.png', 'w+')
ranfile.write(decoded_data)

print(data_store)
print(ranfile.read())

ranfile.close()