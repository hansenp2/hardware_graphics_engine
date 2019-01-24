# Ellipse Drawing Algorithm
# "An Efficient Ellipse-Drawing Algorithm" by Jerry R. Van Aken (TI)

# J. R. Van Aken, "An Efficient Ellipse-Drawing Algorithm," in IEEE Computer Graphics and Applications, vol. 4, no. 9, pp. 24-35, Sept. 1984.
# doi: 10.1109/MCG.1984.275994

import numpy as np
import scipy.misc

ON = 255

def draw_ellipse(image_array, x0, y0, a, b, verbose=False):
    # Starting Point
    x = a 
    y = 0 

    # Temporary Variables
    t1 = a ** 2
    t2 = t1 << 1
    t3 = t2 << 1

    t4 = b ** 2
    t5 = t4 << 1
    t6 = t5 << 1

    t7 = a * t5 
    t8 = 2 * t7 
    t9 = 0

    # Decision variables
    d1 = (t2 - t7 + t4) >> 1
    d2 = (t1 >> 1) - t8 + t5  

    # Region 1
    while d2 < 0:                       
        image_array[y0+y][x0+x] = ON 
        image_array[y0-y][x0+x] = ON 
        image_array[y0+y][x0-x] = ON 
        image_array[y0-y][x0-x] = ON 
        if verbose:
            print('*', x, y, d1, d2, t8, t9)

        y = y + 1                           # always increment y in region 1
        t9 = t9 + t3 
        if d1 < 0:                          # step to pixel D
            d1 = d1 + t9 + t2 
            d2 = d2 + t9
        else:                               # step to pixel C
            x = x - 1
            t8 = t8 - t6 
            d1 = d1 - t8 + t9 + t2 
            d2 = d2 - t8 + t5 + t9 
        
    # Region 2
    while x >= 0:                            
        image_array[y0+y][x0+x] = ON 
        image_array[y0-y][x0+x] = ON 
        image_array[y0+y][x0-x] = ON 
        image_array[y0-y][x0-x] = ON 
        if verbose:
            print('**', x, y, d1, d2, t8, t9)

        x = x - 1                           # always decrement x in region 2
        t8 = t8 - t6 
        if d2 < 0:                          # step to pixel C
            y = y + 1
            t9 = t9 + t3 
            d2 = d2 - t8 + t5 + t9 
        else:                               # step to pixel D
            d2 = d2 - t8 + t5

if __name__ == '__main__':
    
    # Define image
    IMAGE_HGT = 240
    IMAGE_WDT = 320 
    IMAGE_ARR = np.zeros([IMAGE_HGT, IMAGE_WDT])

    # Draw an ellipse (image_array, x0, y0, a, b)
    IMAGE_ARR[100][100] = ON
    draw_ellipse(IMAGE_ARR, 100, 100, 20, 10) 

    # Save Image
    scipy.misc.imsave('img/ellipse.png', IMAGE_ARR)