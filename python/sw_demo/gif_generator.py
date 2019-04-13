import os
import subprocess
import ffmpeg


class GIFGenerator(object):

    @staticmethod
    def create(filename):
        """
        Creates GIF from img direcotry and stores in out directory.
        :param filename: output filename for GIF file
        """
        stream = ffmpeg.input('img/img_%4d.png')
        stream = ffmpeg.filter(stream, 'fps', fps=30)
        stream = ffmpeg.output(stream, 'out/%s' % filename)
        ffmpeg.run(stream)

    @staticmethod
    def clean(dir_name='img', file_type='.png'):
        """
        Removes images from img directory after creating GIF.
        :param dir_name: directory to remove images from
        :param file_type: file type to remove from specified directory
        """
        subprocess.call(['rm', '{dn}/*{ft}'.format(dn=dir_name, ft=file_type)])
