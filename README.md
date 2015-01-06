Light-weight MATLAB package for segmentation using GridCut 
[http://gridcut.com/]
(http://gridcut.com/). [1]

It minimizes functions given on the form:

* Data_term + weight*|boundary length|.


Getting started
===


1. Get MATLAB and a compatible _C++_ compiler: [http://se.mathworks.com/support/compilers/](http://se.mathworks.com/support/compilers/).

2. Setup the C++ compiler in MATLAB using "mex -setup".

3. Review the [GridCut license](http://gridcut.com/licensing.php), it is free to use in research.

4. Download the [source code](http://www.gridcut.com/) and place it inside /gridcut/.

5. Run examples/example.m.



The code has been tested on
* MATLAB 2013a with GCC 4.8 on Ubuntu 14.04.
* MATLAB 2013a with Visual Studio 2013 on Windows 7.

Limitations
===

### Connectivity ###

The GridCut implementation has limited connectivity support:


For 2D data
* 4-connectivity
* 8-connectivity

For 3D data
* 6-connectivity
* 26-connectivity


### C++ ###

In order to stay C++98 compatible the current wrapper does not support the multi-threaded version of GridCut.

### Data types ###

The data term must either be in double or single-precession (float).


References
===
1. 
Jamriska, Ondrej, Daniel Sykora, and Alexander Hornung.
_Cache-efficient graph cuts on structured grids._
Computer Vision and Pattern Recognition (CVPR), 2012.




