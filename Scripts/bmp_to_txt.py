import struct
import sys
import os
from os.path import isfile, join

BYTE_SIZE = 8
HEADER_SIZE = 54

FILES_PATH = sys.argv[1]
bmp_files = [f for f in os.listdir(FILES_PATH) if isfile(join(FILES_PATH, f))]
print(bmp_files)
counter = 0


for img in bmp_files:
    counter += 1
    with open(FILES_PATH + '\\' + img, 'rb') as f:
        bmp = f.read()
        output_file = FILES_PATH + '\\' + 'out' + '\\' + img[:-4] + '.txt'
        os.makedirs(os.path.dirname(output_file), exist_ok=True)
        output_bmp = open(output_file, "wb+")

        #output_brightness = FILES_PATH + '\\' + 'out' + '\\' + img[:-4] + '_br.txt'
        #os.makedirs(os.path.dirname(output_brightness), exist_ok=True)
        #output_bmp_br = open(output_brightness, "wb+")
        #output_threshold = FILES_PATH + '\\' + 'out' + '\\' + img[:-4] + '_th.txt'
        #os.makedirs(os.path.dirname(output_threshold), exist_ok=True)
        #output_bmp_br = open(output_threshold, "wb+")

        print('--------------------')
        # Extract the image size
        f.seek(2)
        img_size = struct.unpack('I', f.read(4))[0]
        print('Image Size (bytes): %s' % img_size)
        f.seek(0)
        # Extract the image width
        f.seek(18)
        img_width = struct.unpack('I', f.read(4))[0]
        print('Image Width: %s' % img_width)
        f.seek(0)
        # Extract the image height
        f.seek(22)
        img_height = struct.unpack('I', f.read(4))[0]
        print('Image Height: %s' % img_height)
        f.seek(0)

        # Calculate the padding size
        padding_size = (4 - ((img_width * 3) % 4)) % 4    # size in bytes
        print("Padding Size (byte):", padding_size)

        # Calculate the new file size
        new_img_size = img_size + 2 - (img_height * padding_size)
        print("New Image Size (bytes):", new_img_size)

        # Extract the header and pixel data
        header = bmp[:2] + (new_img_size).to_bytes(4, byteorder='big') + bmp[6:HEADER_SIZE]
        pixel_data = bmp[HEADER_SIZE:]

        # Add 2 zero bytes between the HEADER (54bytes) and the rest of Data
        new_data = header + (0).to_bytes(2, byteorder='big')

        # Remove the padding from the pixel data
        new_pixel_data = bytes()
        i = 0
        while i < len(pixel_data):     # len in bytes
            # If reached to padding bytes, just skip them
            if i != 0 and (i % (img_width * 3)) == 0 and padding_size != 0:
                i += padding_size
            else:
                new_pixel_data += pixel_data[i].to_bytes(1, byteorder='big')
                i += 1
        new_data += new_pixel_data

        print("Pixel Data Size (bytes):", len(pixel_data))
        print("New Pixel Data Size (bytes):", len(new_pixel_data))

        # Write to output file
        output_bmp.write(new_data)

        # Close File
        output_bmp.close()
        print('DONE:', img)
    """
    print('Type:', bmp.read(2).decode())
    print('Size: %s' % struct.unpack('I', bmp.read(4)))
    print('Reserved 1: %s' % struct.unpack('H', bmp.read(2)))
    print('Reserved 2: %s' % struct.unpack('H', bmp.read(2)))
    print('Offset: %s' % struct.unpack('I', bmp.read(4)))

    print('DIB Header Size: %s' % struct.unpack('I', bmp.read(4)))
    print('Width: %s' % struct.unpack('I', bmp.read(4)))
    print('Height: %s' % struct.unpack('I', bmp.read(4)))
    print('Colour Planes: %s' % struct.unpack('H', bmp.read(2)))
    print('Bits per Pixel: %s' % struct.unpack('H', bmp.read(2)))
    print('Compression Method: %s' % struct.unpack('I', bmp.read(4)))
    print('Raw Image Size: %s' % struct.unpack('I', bmp.read(4)))
    print('Horizontal Resolution: %s' % struct.unpack('I', bmp.read(4)))
    print('Vertical Resolution: %s' % struct.unpack('I', bmp.read(4)))
    print('Number of Colours: %s' % struct.unpack('I', bmp.read(4)))
    print('Important Colours: %s' % struct.unpack('I', bmp.read(4)))
    print('--------------------')
    print()
"""