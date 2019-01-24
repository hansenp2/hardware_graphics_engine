# Circle Drawing Algorithm
# https://en.wikipedia.org/wiki/Midpoint_circle_algorithm

import numpy as np
import scipy.misc

ON = 255

def draw_circle(image_array, x0, y0, radius, verbose=False):
    x = radius
    y = 0

    dx = 1 - (radius << 1)
    dy = 1
    e  = 0

    if verbose:
        print('x\ty\tdx\tdy\te')
        print('{}\t{}\t{}\t{}\t{}'.format(x,y,dx,dy,e))

    # Draw octants
    while x >= y:
        image_array[y0 + y][x0 + x] = ON
        image_array[y0 + x][x0 + y] = ON
        image_array[y0 + x][x0 - y] = ON
        image_array[y0 + y][x0 - x] = ON
        image_array[y0 - y][x0 - x] = ON
        image_array[y0 - x][x0 - y] = ON
        image_array[y0 - x][x0 + y] = ON
        image_array[y0 - y][x0 + x] = ON

        # Will either move left (-x) or down (+y) depending on error
        if (((e + dy) << 1) + dx) > 0:
            x  -= 1
            e  += dx
            dx += 2
        else:
            y  += 1
            e  += dy
            dy += 2

        if verbose:
            print('{}\t{}\t{}\t{}\t{}'.format(x,y,dx,dy,e))

if __name__ == '__main__':
    
    # Define image
    IMAGE_HGT = 240
    IMAGE_WDT = 320 
    IMAGE_ARR = np.zeros([IMAGE_HGT, IMAGE_WDT])

    # Draw a circle (image_array, x0, y0, radius)
    IMAGE_ARR[100][100] = ON
    draw_circle(IMAGE_ARR, 100, 100, 10) 

    # Save Image
    scipy.misc.imsave('img/circle.png', IMAGE_ARR)