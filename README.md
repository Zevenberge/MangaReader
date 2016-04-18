# MangaReader
A very basic application for reading image files written in D using DSFML as the graphical engine.

## Features
1. Intuitive navigation – up and down move the page, left and right swap pages, escape escapes.
2. Fully utilizes the width of the screen by sizing the page as widely as possible.
3. Remembers the last manga and page you were reading.

## Getting started

### Ubuntu
Get dub and dmd 2.070 using

    sudo apt-get install dub
on Ubuntu 16.04. Lower versions require the d-apt repository (http://d-apt.sourceforge.net/).
Download the DSFML-C dynamic library from http://dsfml.com/downloads.html. Place the binaries themselves in a folder in the library path (ex. in /usr/lib) and reconfig your libraries.
Clone the repository in your favorite folder. Open a terminal window and navigate to your folder. Type the complex command

    dub
and enjoy your read.

### Windows
Install Ubuntu and follow the Ubuntu steps.
As of current, Windows is not supported due to its weird file system.

### Mac
Although it is untested, it might just work out of the box.
