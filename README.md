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
GNU GPL v3 compatible license. See .\bin\License.txt for details.

(2) About this program
Firefox Timelapse Recorder creates periodical screenshots of a
rectangle of a website opened in the Mozilla Firefox webbrowser.

The page will be reloaded periodically. After finishing recording,
all taken screenshots will be converted to an MPEG4 AVI file.

(3) System requirements
 - Microsoft Windows XP or never, 32 or 64 bit
 - Mozilla Firefox with plugin MozRepl installed and activated(!)
 - This program has been developed and testet under Windows 8 (64 Bit),
   Windows 7 (64 Bit) and Mozilla Firefox 25.0.1.

(4) Installation and usage
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

(5) Need help?
Have a look at the included source code, it´s easy to understand.
To compile the code you need AutoIt (http://www.autoitscript.com).

(6) Thanks
My thanks go to
- AutoIt Consulting Ltd.
- The ffmpeg team (http://ffmpeg.org/).
- ImageMagick Studio LLC (http://www.imagemagick.org).
- Thorsten Willert for FF.au3 (http://ff-au3.thorsten-willert.de/).
- hyperstruct for MozRepl (http://hyperstruct.net/).
- Ingress agent silbaer for the initial idea.
- The Open Icon Library (http://openiconlibrary.sourceforge.net/).

(7) Questions? - Answers!
Q: Will there be a version for Chrome/Opera/Safari/Internet Explorer?
A: Probably not.

Q: Will there be a version for Linux, MacOS, iOS, Android, ...?
A: Definately not.

(8) Version information
v0.1	11/20/2013	Initial semi-public beta release
v0.1.1	11/22/2013	Add an annotation to the video
					Add a logo to the video
					Convert the video to animated GIF