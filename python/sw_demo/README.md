## Python Tools for Simulating Software Demos

### Setting Up Development Environment
Python packages and environments can easily be managed using a tool call `virtualenv` which creates a project specific environemnt to install Python packages into. The Python drawing tools use different packages and this is an easy way to keep track of them and easily be able to install any new packages added. First install `virtualenv`:

`$ pip install virtualenv`

Next, create a virtual environment in the top level of the repository using `python3` (which is specified by the binary following `-p` in the command):

`$ virtualenv -p python .env`

After creating the environment, source it to activate (after sourcing you should see a `(.env)` in the command line)

Windows:
`$ source .env/Scripts/activate`

macOS and Linux:
`$ source .env/bin/activate`

After sourcing, install the requirements from the text file in the `sw_demo` directory:

`$ cd python/sw_demo`
`$ pip install -r requirements.txt`

### Creating Demos
In the file `drawer.py`, there are three functions for drawing lines, circles, and ellipses. They can be used to generate sequences (examples in `line_demo.py` and `ellipse_demo.py`) to then be converted to C code. For the Python code, I recommend writing image files (either `.png` or `.gif`) to be converted to an animated `.gif` file.

There is an additional file called `gif_generator.py` which will convert all the images in a directory into an animated GIF. This uses a package called `ffmpeg-python` which wraps `ffmpeg` and both need to be installed. Right now, it is setup to create a sequence of images from a directory called `img` and store the resultant GIF in a directory called `out`. Additionally, there is a clean function which will delete all the images in the `img` directory if called.
