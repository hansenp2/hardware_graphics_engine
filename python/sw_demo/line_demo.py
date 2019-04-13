import numpy as np
import scipy.misc
from PIL import Image

from drawer import Drawer
from gif_generator import GIFGenerator

IMG_HGT = 240
IMG_WDT = 320
IMAGE_ARR = np.zeros([IMG_HGT, IMG_WDT, 3])

REGION = IMG_HGT // 3
COLOR_DEPTH = 12


class LineDemo(object):

    @staticmethod
    def run():

        x1, y1 = 0, (IMG_HGT - 1)
        x2, y2 = 0, 0

        color = 0

        # Draw here (will be an infinite loop)
        for n in range(1280):

            i = n % (4 * REGION)

            # Change color here
            r = (color >> 8) & 0xf
            g = (color >> 4) & 0xf
            b = (color >> 0) & 0xf

            Drawer.draw_line(IMAGE_ARR, (x1, y1), (x2, y2), (r, g, b))

            if i < REGION:
                x2 = (x2 + 4) % IMG_WDT if x2 < IMG_WDT - 4 else IMG_WDT - 1
                y1 = y1 - 3 if y1 > 3 else 0
            elif i > REGION and i < (2 * REGION):
                x1 = (x1 + 4) % IMG_WDT
                y2 = (y2 + 3) % IMG_HGT
            elif i > (2 * REGION) and i < (3 * REGION):
                x2 = x2 - 4 if x2 > 4 else 0
                y1 = (y1 + 3) % IMG_HGT
            elif i > (2 * REGION) and i < (4 * REGION):
                x1 = x1 - 4 if x1 > 4 else 0
                y2 = y2 - 3 if y2 > 3 else 0

            color = (color + 1) % (1 << COLOR_DEPTH)

            # Save image
            scipy.misc.imsave('img/img_%04d.png' % n, IMAGE_ARR)


if __name__ == '__main__':
    LineDemo.run()
    GIFGenerator.create('demo_line.gif')
    GIFGenerator.clean()
