# Create Memory Initilization - Senior Project

import numpy as np
from PIL import Image
import matplotlib.pyplot as plt 

# Image File to Read In
IMG_FILE = './img/hello_world.png'

# Output Image Size 
IMG_WDT  = 640
IMG_HGT  = 480

# Open Image
image       = Image.open(IMG_FILE).convert('RGB')
(wdt, hgt)  = image.size  

# Resize Image (if needed)
if wdt != IMG_WDT or hgt != IMG_HGT:
    image   = image.resize((IMG_WDT,IMG_HGT), Image.ANTIALIAS)

# Convert Image to Numpy Array
image_np    = np.array(image.getdata()).reshape((IMG_HGT, IMG_WDT, 3)).astype(np.uint8)

# Size of BRAM Model
bram_model = np.zeros([int(IMG_WDT*IMG_HGT*3/8),8])
bram_addr  = 0

px_count = 1
cur_pxs  = [0] * 8
for i in range(IMG_HGT):
    for j in range(IMG_WDT):
        
        if   px_count % 8 == 1:
            cur_pxs[0] = image_np[i][j]
        elif px_count % 8 == 2:
            cur_pxs[1] = image_np[i][j]
        elif px_count % 8 == 3:
            cur_pxs[2] = image_np[i][j]
        elif px_count % 8 == 4:
            cur_pxs[3] = image_np[i][j]
        elif px_count % 8 == 5:
            cur_pxs[4] = image_np[i][j]
        elif px_count % 8 == 6:
            cur_pxs[5] = image_np[i][j]
        elif px_count % 8 == 7:
            cur_pxs[6] = image_np[i][j]
        elif px_count % 8 == 0:
            cur_pxs[7] = image_np[i][j]

        if px_count % 8 == 0:
            
            for k in range(8):
                bram_model[bram_addr+0][k] = (cur_pxs[7-k][0]) >> 4
                bram_model[bram_addr+1][k] = (cur_pxs[7-k][1]) >> 4
                bram_model[bram_addr+2][k] = (cur_pxs[7-k][2]) >> 4
                
            bram_addr += 3 

        px_count += 1

output_file = open('mem_layout.coe', 'w')
output_file.write('memory_initialization_radix=16;\n')
output_file.write('memory_initialization_vector=')

for i in range(len(bram_model)):
    to_write = ''
    for j in range(len(bram_model[0])):
        if (i == len(bram_model) - 1) and (j == len(bram_model[0]) - 1):
            to_write += '{:1x};'.format( int(bram_model[i][j]) ) 
        else:
            to_write += '{:1x}'.format( int(bram_model[i][j]) )

    output_file.write(to_write + ' ')
   

output_file.close()

# Display Image 
plt.imshow(image)
plt.show()