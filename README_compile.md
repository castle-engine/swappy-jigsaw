# General

You can compile the source simply by opening *.lpi in Lazarus IDE (version 1.9 and above) and pushing F9 to compile&run.

# Requirements

This version requires at least 6.5 Castle Game Engine version to compile (at least 20.11.2018 GIT version). You can download it here https://github.com/castle-engine/castle-engine and follow installation instructions here https://castle-engine.io/documentation.php#section_installation

FreePascal compiler at least version 3.1.1 is required.

I recommend using FPC+Lazarus trunk (SVN) version (best after 2018-07-01) due to better Generics.Collections support in recent CodeTools patches. However, if you're not going to use CodeTools (i.e. you don't need a convenient way to change the code), then you should be perfectly fine with earlier versions of FPC 3.1.1 & Lazarus 1.9.

You can easily install latest Lazarus+FPC+cross-compilation tools with fpcupdeluxe. See https://github.com/castle-engine/castle-engine/wiki/fpcupdeluxe for more info.

## Linux

You need both normal and development versions of the libraries required for Castle Game Engine to run properly. These are (Debian/Ubuntu package reference):

libopenal1

libopenal-dev

libpng16-16

libpng-dev

zlib1g

zlib1g-dev

libvorbis0a

libvorbis-dev

libfreetype6

libfreetype6-dev

libgtkglext1

libgtkglext1-dev

You will also need dev version of OpenGL drivers for your video card. Usually it is libgl1-mesa-dev.

Note: the libraries versions may change and not every library has a meta-package.

A soft GTK dependency (to get rid of a warning) is libatk-adaptor.

## Windows

Specific DLL libraries (32 bit / 64 bit) are required in case of Windows. These may be downloaded here: http://castle-engine.sourceforge.net/engine.php.

The DLLs must be placed in the exe folder.

# Command-line compilation

You can compile the game without Lazarus IDE using Castle Game Engine build-tool https://github.com/castle-engine/castle-engine/wiki/Build-Tool.

# Known issues

If the buttons background is not transparent, apply a FPC patch from `fpc-patch` folder, see `readme.txt` for more details.
