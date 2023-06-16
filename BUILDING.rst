=============
Building NCPA
=============

*This document is a work in progress for Python 3 and NCPA 3.*

* `Building on Windows <#building-on-windows>`_
* `Building on Linux <#building-on-linux>`_
* `Building on Mac OS X <#building-on-mac-os-x>`_

Building on Windows
===================

*WARNING: DO THIS ON A VM OR A NON-PRODUCTION SYSTEM.*
*THE BUILD SCRIPT WILL MAKE CHANGES TO YOUR SYSTEM THAT MAY BREAK EXISTING SOFTWARE*

Prerequisites
-------------

* `Git for Windows <https://git-scm.com/download/win>`_
* `Python 3.11.x <https://www.python.org/downloads/>`_
* `NSIS 3 <http://nsis.sourceforge.net/Download>`_ *(Requires admin rights)*

Configure the Build Environment
-------------------------------

Install Prerequisites
~~~~~~~~~~~~~~~~~~~~~

* Python

  1. Download and install Python 3.x. (`see prerequisites <#prerequisites>`_)
  2. Execute the installer as usual, making sure to check the box to add Python to your PATH (on the first page).

* NSIS

  1. Download and run the installer. (`see prerequisites <https://github.com/NagiosEnterprises/ncpa/blob/master/BUILDING.rst#prerequisites>`_)

* pip

  * Pip is installed by default but should be updated before continuing::

      py -m pip install --upgrade pip

Note: py should be the command to run python 3. If it is not, you may need to use the full path to the python executable.

Build NCPA
----------

In your Git Bash terminal (or cmd.exe with ``C:\Program Files\Git\usr\bin`` added to your PATH), run the following commands:

Navigate to your desired build directory and clone the repository::

  cd /c/desired/build/directory
  git clone https://github.com/NagiosEnterprises/ncpa.git

In a Command Prompt/Terminal (cmd.exe) with admin rights, run the following commands::

  cd C:\desired\build\directory\ncpa
  py build\build_windows.py

This will create a file called ``ncpa-<version>.exe`` in the ``build`` directory.
This is the installer for NCPA and can be used to install NCPA on a Windows system.


Building on Linux
=================

Building from most Linux distros is much less complicated than Windows. We have a
couple helpful scripts that make it much easier. *We will assume you have wget and git installed*

*WARNING: DO THIS ON A VM OR A NON-PRODUCTION SYSTEM*
*THE BUILD SCRIPT WILL MAKE CHANGES TO YOUR SYSTEM THAT MAY BREAK EXISTING SOFTWARE*

To start, clone the repository in your directory::

  cd ~
  git clone https://github.com/NagiosEnterprises/ncpa

Now run the setup scripts to install the requirements::

  cd ncpa/build
  ./build.sh

Follow the prompts to setup the system. When running the build.sh script it will setup
the system and build the ncpa binary.


Building on Mac OS X
====================

Working on this section. It's basically the same as Linux, however you may need to
install the libraries and python differently, due to it being macOS. You must have
python3 installed prior to running it. You'll also have to use the following command
to build the dmg::

  cd ncpa/build
  ./build.sh
