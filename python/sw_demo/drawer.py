import numpy as np
import scipy.misc
from PIL import Image


class Drawer(object):

    @staticmethod
    def draw_line(image_arr, start_point, end_point, color):
        """
        Draw line from start to end point of specified color.
        :param image_arr: image array to write to
        :param start_point: starting (x, y) coordinate of line
        :param end_point: ending (x, y) coordinate of line
        :param color: 3-tuple containg RGB color values to be drawn
        """
        Drawer._draw_line(image_arr[:, :, 0], start_point, end_point, color[0])
        Drawer._draw_line(image_arr[:, :, 1], start_point, end_point, color[1])
        Drawer._draw_line(image_arr[:, :, 2], start_point, end_point, color[2])

    @staticmethod
    def draw_circle(image_array, x0, y0, radius, color):
        """
        Draw circle at specified center point with specified radius.
        :param image_arr: image array to write to
        :param x0: x-coordinate of circle center
        :param y0: y-coordinate of circle center
        :param radius: radius of circle
        :param color: 3-tuple containg RGB color values to be drawn
        """
        Drawer._draw_circle(image_arr[:, :, 0], x0, y0, radius, color[0])
        Drawer._draw_circle(image_arr[:, :, 1], x0, y0, radius, color[1])
        Drawer._draw_circle(image_arr[:, :, 2], x0, y0, radius, color[2])

    @staticmethod
    def draw_ellipse(image_arr, x0, y0, a, b, color):
        """
        Draw ellipse at center point with horizontal and vertical radii.
        :param image_arr: image array to write to
        :param x0: x-coordinate of circle center
        :param y0: y-coordinate of circle center
        :param a: horizontal radius of ellipse
        :param b: vertical radius of ellipse
        :param color: 3-tuple containg RGB color values to be drawn
        """
        Drawer._draw_ellipse(image_arr[:, :, 0], x0, y0, a, b, color[0])
        Drawer._draw_ellipse(image_arr[:, :, 1], x0, y0, a, b, color[1])
        Drawer._draw_ellipse(image_arr[:, :, 2], x0, y0, a, b, color[2])

    @staticmethod
    def _draw_line(image_array, start_point, end_point, color):

        # Change in x & y
        dx = abs(start_point[0] - end_point[0])
        dy = abs(start_point[1] - end_point[1])

        # x-axis is the Driving Axis (DA), y-axis is the Passive Axis (PA)
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
                image_array[i][j] = color << 4
                if e >= 0:
                    if y1 >= y2:
                        i -= 1
                    else:
                        i += 1
                    e -= dx
                e += dy

        # y-axis is the Driving Axis (DA), x-axis is the Passive Axis (PA)
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
                image_array[i][j] = color << 4
                if e >= 0:
                    if x1 >= x2:
                        j -= 1
                    else:
                        j += 1
                    e -= dy
                e += dx

    @staticmethod
    def _draw_circle(image_array, x0, y0, radius, color):
        x = radius
        y = 0

        dx = 1 - (radius << 1)
        dy = 1
        e = 0

        # Draw octants
        while x >= y:
            image_array[y0 + y][x0 + x] = color << 4
            image_array[y0 + x][x0 + y] = color << 4
            image_array[y0 + x][x0 - y] = color << 4
            image_array[y0 + y][x0 - x] = color << 4
            image_array[y0 - y][x0 - x] = color << 4
            image_array[y0 - x][x0 - y] = color << 4
            image_array[y0 - x][x0 + y] = color << 4
            image_array[y0 - y][x0 + x] = color << 4

            # Will either move left (-x) or down (+y) depending on error
            if (((e + dy) << 1) + dx) > 0:
                x -= 1
                e += dx
                dx += 2
            else:
                y += 1
                e += dy
                dy += 2

    @staticmethod
    def _draw_ellipse(image_array, x0, y0, a, b, color):
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
            image_array[y0 + y][x0 + x] = color << 4
            image_array[y0 - y][x0 + x] = color << 4
            image_array[y0 + y][x0 - x] = color << 4
            image_array[y0 - y][x0 - x] = color << 4

            y = y + 1
            t9 = t9 + t3
            if d1 < 0:
                d1 = d1 + t9 + t2
                d2 = d2 + t9
            else:
                x = x - 1
                t8 = t8 - t6
                d1 = d1 - t8 + t9 + t2
                d2 = d2 - t8 + t5 + t9

        # Region 2
        while x >= 0:
            image_array[y0 + y][x0 + x] = color << 4
            image_array[y0 - y][x0 + x] = color << 4
            image_array[y0 + y][x0 - x] = color << 4
            image_array[y0 - y][x0 - x] = color << 4

            x = x - 1
            t8 = t8 - t6
            if d2 < 0:
                y = y + 1
                t9 = t9 + t3
                d2 = d2 - t8 + t5 + t9
            else:
                d2 = d2 - t8 + t5
