# Line Drawing Algorithm
# https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm

import numpy as np
import scipy.misc

ON = 255

def draw_line(image_array, start_point, end_point):

    # Change in x & y
    dx = abs(start_point[0] - end_point[0])
    dy = abs(start_point[1] - end_point[1])

    # x-axis is the Driving Axis (DA)
    # y-axis is the Passive Axis (PA)
    if dx >= dy:
        # Properly Order Points
        if start_point[0] <= end_point[0]:
            x1 = int(start_point[0])
            y1 = int(start_point[1])
            x2 = int(end_point[0])
            y2 = int(end_point[1])
        else:
            x1 = int(end_point[0])
            y1 = int(end_point[1])
            x2 = int(start_point[0])
            y2 = int(start_point[1])
    
        i = y1 
        e = dy - dx
        for j in range(x1, (x2 + 1)):
            image_array[i][j] = ON
            if e >= 0:
                if y1 >= y2:
                    i -= 1
                else:
                    i += 1
                e -= dx
            e += dy
            print(j, i, e)

    # y-axis is the Driving Axis (DA)
    # x-axis is the Passive Axis (PA)
    else:
        # Properly Order Points
        if start_point[1] <= end_point[1]:
            x1 = int(start_point[0])
            y1 = int(start_point[1])
            x2 = int(end_point[0])
            y2 = int(end_point[1])
        else:
            x1 = int(end_point[0])
            y1 = int(end_point[1])
            x2 = int(start_point[0])
            y2 = int(start_point[1])

        j = x1
        e = dx - dy
        for i in range(y1, (y2 + 1)):
            image_array[i][j] = ON
            if e >= 0:
                if x1 >= x2:
                    j -= 1
                else:
                    j += 1
                e -= dy
            e += dx