import numpy as np
import scipy.misc
from PIL import Image

from drawer import Drawer
from gif_generator import GIFGenerator

IMG_HGT = 240
IMG_WDT = 320
IMAGE_ARR = np.zeros([IMG_HGT, IMG_WDT, 3])
COLOR_DEPTH = 12


class EllipseDemo(object):

    @staticmethod
    def run():

        x0, y0 = (IMG_WDT // 2) - 1, (IMG_HGT // 2) - 1
        a0, b0 = 0, 0

        color = 0
        state = 0

        for i in range(1280):

            # Change color here
            r = (color >> 8) & 0xf
            g = (color >> 4) & 0xf
            b = (color >> 0) & 0xf

            Drawer.draw_ellipse(IMAGE_ARR, x0, y0, a0, b0, (r, g, b))

            if phase == 0:
                if a0 == (IMG_WDT // 2) - 4:
                    state = 1
                else:
                    a0 += 4
                    b0 += 3
            else:
                if a0 == 0:
                    state = 0
                else:
                    a0 -= 4
                    b0 -= 3

            color = (color + 1) % (1 << COLOR_DEPTH)

            # Save image
            scipy.misc.imsave('img/img_%04d.png' % i, IMAGE_ARR)


if __name__ == '__main__':
    EllipseDemo.run()
    GIFGenerator.create('demo_ellipse.gif')
    GIFGenerator.clean()
