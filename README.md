fftlrec
=======

Firefox Timelapse Recorder

(c) 2013 by elpatron (elpatron@cepheus.uberspace.de)


(1) License
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

The included program 'ffmpeg' is free software licensed under the
GNU Lesser General Public License (LGPL) version 2.1. Read here
for details: http://ffmpeg.org/legal.html.

The included program ImageMagick is free software licensed under a
GNU GPL v3 compatible license. See ImageMagick_License.txt for details.

(2) Purpose
Firefox Timelapse Recorder creates periodical screenshots of a
rectangle of a website opened in Mozilla´s Firefox webbrowser.

The page will be reloaded periodically. After finishing recording,
the screenshots will be converted to an MPEG4 AVI file.

A caption and a graphical logo can be added to the video.

Demonstration of fftlrec: http://youtu.be/CZ2QtJADNCM

Also, an animated GIF file can be generated (experimental).

(3) Latest version of this script
Get the latest version of fftlrec from
    (a) https://github.com/elpatron68/fftlrec.git (source only)
        (a.1) Download ImageMagick from http://www.imagemagick.org/
              (Win32 or Win64 static at 16 bits-per-pixel).
              From the archive extract 'convert.exe',
              'composite.exe' and 'vcomp100.dll' into your fftlrec
              directory.
        (a.2) Download ffmpeg from http://ffmpeg.zeranoe.com/builds/
              (select the newest Win32- or Win64-Static build).
              From the archive extract 'ffmpeg.exe' into you fftlrec
              directory.
    (b) Download fftlrec from http://goo.gl/maKBjs (binary and
        source, ffmpeg and Imagemagick included)

(4) System requirements
 - Microsoft Windows XP or never, 32 or 64 bit
 - Mozilla Firefox with plugin MozRepl installed and activated(!)
 - This program has been developed and testet under Windows 8 (64 Bit),
   Windows 7 (64 Bit) and Mozilla Firefox 25.0.1.

(5) Installation and usage
- Install the Firefox plugin MozRepl from
  https://addons.mozilla.org/de/firefox/addon/mozrepl/.
- Activate MozRepl via Tools -> MozRepl -> Start.
- Extract the content of this archive into a folder of your choice.
- Optional: open the settings file 'fftl.ini' with a text editor and
  change the settings according to your needs.
- Start 'fftl.exe'
- Wait some seconds until a message requests you to draw a rectangle.
  This rectangle will define the recorded screen area.
- The programm will now start to take screenshots. It will not stop
  until you enter the global hotkey Alt-Shift-S.
- During recording, make sure that your Firefox window isn´t covered
  by other windows.
- After stopping the recording progress by hitting Alt-Shift-S, all
  screenshots (JPG) will be put together to an MPEG4 video file (AVI).

(6) Need help?
Have a look at the included source code, it´s easy to understand.
To compile the code you need AutoIt (http://www.autoitscript.com).

(7) Thanks
My thanks go to
- AutoIt Consulting Ltd.
- The ffmpeg team (http://ffmpeg.org/).
- ImageMagick Studio LLC (http://www.imagemagick.org).
- Thorsten Willert for FF.au3 (http://ff-au3.thorsten-willert.de/).
- hyperstruct for MozRepl (http://hyperstruct.net/).
- Ingress agent silbaer for the initial idea.
- The Open Icon Library (http://openiconlibrary.sourceforge.net/).

(8) Questions? - Answers!
Q: Will there be a version for Chrome/Opera/Safari/Internet Explorer?
A: Probably not.

Q: Will there be a version for Linux, MacOS, iOS, Android, ...?
A: Probably not.

(9) Limitations
In some (especially my) multiscreen environments fftlrec cannot
determine the coordinates of the rectangle to grab when positioned
on the secondary screen. Workaround: grab it on your primary screen
or edit the coordinates in fftl.ini.

(10) Version information
v0.1        11/20/2013  Initial semi-public beta release
v0.1.0.2    11/22/2013  Add an annotation (label) to the video
                        Add a logo to the video
                        Convert the video to animated GIF
                        Added logging
                        Added many more options to fftl.ini
v0.1.0.3    11/25/2013  Fixed bug concerning directory creation

