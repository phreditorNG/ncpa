Installing NCPA

Note:
This installer requires that the Xcode Command Line Tools be installed on the server.
The installer will prompt you to do this installation if the tools aren't available.

Installing NCPA:
    1. Download MacOS archive (https://www.nagios.org/ncpa/#downloads)
    2. Double click open the disk image file to mount it
    3. Find the installer volume name in the terminal:
         ls /Volumes
         Look for NCPA-<version> (e.g. NCPA-2.4.0)

    4. Run the installer, and follow any user prompts:
         sudo zsh /Volumes/NCPA-<version>/install.sh

Note: if you already have NCPA installed, the installer will upgrade the NCPA software, and retain your configuration.

Uninstalling  NCPA
    1. On the command line, enter: sudo zsh /usr/local/ncpa/uninstall.sh
