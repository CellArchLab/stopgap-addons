# stopgap-addons
A set of add-ons for enhancing the [STOPGAP](https://github.com/wan-lab-vanderbilt/STOPGAP) experience.

## Installation instructions
0. Install dependencies:
  * [STOPGAP](https://github.com/wan-lab-vanderbilt/STOPGAP) obviously. Please refer to the STOPGAP manual for installation and configuration details.
  * [IMOD](https://bio3d.colorado.edu/imod/)
  * [gnuplot](http://www.gnuplot.info/) (possibly already available in your Linux system or HPC environment)
  * There is one script (`sgstar2bild`) that relies on [pyem](https://github.com/asarnow/pyem) being available
1. Clone this repo:
```
git clone https://github.com/CellArchLab/stopgap-addons.git
```
2. Configure environment variables as follows (for example, in your `~/.bashrc` file):
```
export STOPGAP_ADDONS_HOME=/path/to/stopgap-addons/
export PATH=${STOPGAP_ADDONS_HOME}/bash:$PATH
export PATH=${STOPGAP_ADDONS_HOME}/utils:$PATH
```
### Lua modulefile suggestion
If you are managing your packages through [Lmod](https://lmod.readthedocs.io/), here is an idea for a modulefile definition:
```
local about = [==[
Description
===========
A set of utilities for enhancing the STOPGAP experience.

More information
================
    - Homepage: https://github.com/CellArchLab/stopgap-addons
]==]

help(about)
whatis(about)

depends_on("gnuplot")
depends_on("IMOD")
depends_on("STOPGAP")

local root = "/path/to/stopgap-addons/"

setenv("STOPGAP_ADDONS_HOME", root)
prepend_path("PATH", pathJoin(root, "bash"))
prepend_path("PATH", pathJoin(root, "utils"))

```
## Known issues
The scripts provided here mostly lack documentation or even a proper description of the input parameter. I plan to add them over time. User at your own risk. Please open an [issue](https://github.com/CellArchLab/stopgap-addons/issues) if you encounter problems.
