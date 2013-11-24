; Firefox Timelapse
; 2013 Markus Busche, elpatron@cepheus.uberspace.de
;
#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=camera-video_mount.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Fileversion=0.1.0.2
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_LegalCopyright=elpatron@cepheus.uberspace.de
#AutoIt3Wrapper_Run_After="D:\Program Files\7-Zip\7z" u fftl_%fileversion%.zip @filelist.txt
#AutoIt3Wrapper_Run_Tidy=y
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <FF.au3>
#include <File.au3>
#include <WindowsConstants.au3>
#include <ScreenCapture.au3>
#include <Misc.au3>
#include <Date.au3>

; Setting global hotkey Shift-Alt-s
HotKeySet("+!s", "_postprocessing")

; Coordinates of rectangle to be recorded
Global $iX1, $iY1, $iX2, $iY2, $fps

Global $title = "Firefox Timelapse Recorder v0.1.0.2"
Global $count = 0
Global $inifile = @ScriptDir & "\fftl.ini"
Global $logfile = @ScriptDir & "\fftl.log"

; Read values from INI file fftl.ini
; General Settings
Global $URL = IniRead($inifile, "settings", "url", "")
Global $reload = IniRead($inifile, "settings", "reload", "True")
Global $rlinterval = IniRead($inifile, "settings", "rlinterval", "4")
Global $tooltips = IniRead($inifile, "settings", "tooltips", "True")
Global $log = IniRead($inifile, "settings", "log", "False")
Global $captureinterval = IniRead($inifile, "settings", "captureinterval", "60") * 1000

; Files settings
Global $directory = IniRead($inifile, "files", "directory", @ScriptDir & "\")
Global $imagefilename = IniRead($inifile, "files", "imagefilename", "image_%d.jpg")
Global $videofilename = IniRead($inifile, "files", "videofilename", "fftlrec.avi")
Global $giffilename = IniRead($inifile, "files", "giffilename", "fftlrec.gif")

; Predefined rectangle
Global $iX1 = IniRead($inifile, "region", "X1", "")
Global $iY1 = IniRead($inifile, "region", "Y1", "")
Global $iX2 = IniRead($inifile, "region", "X2", "")
Global $iY2 = IniRead($inifile, "region", "Y2", "")
Global $fps = IniRead($inifile, "video", "fps", "5")

; Label settings
Global $addlabel = IniRead($inifile, "label", "addlabel", "False")
Global $caption = IniRead($inifile, "label", "caption", " Firefox Timelapse Recorder ")
Global $backgroud = IniRead($inifile, "label", "backgroud", "#0008")
Global $fill = IniRead($inifile, "label", "fill", "white")

; Logo Settings
Global $addlogo = IniRead($inifile, "logo", "addlogo", "False")
Global $logofile = IniRead($inifile, "logo", "logofile", "")

; Animated GIF
Global $anigif = IniRead($inifile, "gif", "convert2gif", "False")
Global $delay = IniRead($inifile, "gif", "delay", "5")
Global $colors = IniRead($inifile, "gif", "colors", "51")
Global $loop = IniRead($inifile, "gif", "loop", "0")

; check for correct filename
If Not StringInStr($imagefilename, "%d") Then
	$imagefilearr = StringSplit($imagefilename, ".")
	$imagefilename = $imagefilearr[0] & "_%d.jpg"
EndIf

; expand / create directory
If StringInStr($directory, "<TIMESTAMP>", 1) Then
	Local $ts = @YEAR & @MON & @MDAY & "_" & @HOUR & @MIN & "\"
	$directory = StringReplace($directory, "<TIMESTAMP>", $ts)
	DirCreate($directory)
	If @error Then
		MsgBox(0, $title, "Couldn´t create directory '" & $directory & "'!")
		_log2file("Couldn´t create directory '" & $directory & "'!")
		Exit
	EndIf
EndIf

; check directory
If $directory <> "" And Not FileExists($directory) Then
	MsgBox(0, $title, "Directory " & $directory & " doesn´t exist. I will terminate.")
	_log2file("Directory " & $directory & " doesn´t exist. Exit.")
	Exit
EndIf
If $directory = "" Then
	$directory = @ScriptDir & "\"
EndIf
If StringRight($directory, 1) <> "\" Then
	$directory = $directory & "\"
EndIf

; check for required binaries
_checkfiles()

; check logo file
If $addlogo = "True" And Not FileExists($logofile) Then
	MsgBox(0, $title, "Logo file not found: " & $logofile)
	_log2file("Logo file not found: " & $logofile & ". Exit.")
	Exit
EndIf

; get URL to open/connect
If $URL = "" Then
	$URL = InputBox($title, "Enter URL:", "http://example.com")
	If @error Then
		MsgBox(0, $title, "Empty URL or canceled. I will terminate.")
		_log2file("Empty URL or canceled. Exit.")
		Exit
	EndIf
EndIf

; connect to Firefox instance
If _FFConnect(Default, Default, 3000) Then
	_FFOpenURL($URL)
	_FFLoadWait()
	WinActivate("[CLASS:MozillaWindowClass]", "")
Else
	MsgBox(0, $title, "Error connecting to Mozilla Firefox. Start Firefox and /or Download and activate the MozRepl plugin.")
	_log2file("Error connecting to Mozilla Firefox.Exit.")
	Exit
EndIf

; wait 10 seconds
Sleep(10000)

; let the user draw a rectangle
If $iX1 = "" Then
	MsgBox(0, $title, "Now click 'Ok' and draw a rectangle to be captured. To stop recording, hit Alt-Shift-S.")
	_Mark_Rect()
EndIf

_log2file("--- Starting " & $title & "---")
_getscreenshots()
Exit

Func _getscreenshots()
	; set timer
	Local $begin = TimerInit()
	Local $rlcount = 0
	Local $countstr = ""
	Local $filename = ""
	Local $hBmp

	While 1
		Sleep(1000)
		$dif = TimerDiff($begin)
		If $dif > ($captureinterval) Then
			$count += 1
			Select
				Case $count < 10
					$countstr = "0000" & $count
				Case $count < 100
					$countstr = "000" & $count
				Case $count < 1000
					$countstr = "00" & $count
				Case $count < 10000
					$countstr = "0" & $count
			EndSelect
			; set filename
			$filename = $directory & StringReplace($imagefilename, "%d", $countstr)
			; capture selected region
			_log2file("Captured image: " & $filename)
			$hBmp = _ScreenCapture_Capture("", $iX1, $iY1, $iX2, $iY2, False)
			_ScreenCapture_SaveImage($filename, $hBmp)
			_WinAPI_DeleteObject($hBmp)
			$rlcount += 1
			If $tooltips = "True" Then
				TrayTip("", "Saved screenshot as " & $filename, 10, 1)
			EndIf

			; add label
			If $addlabel = "True" Then
				_addlabel($filename)
			EndIf

			; add logo
			If $addlogo = "True" Then
				_addlogo($filename)
			EndIf

			; reload page
			If $reload = "True" And $rlcount = $rlinterval Then
				$rlcount = 0
				_log2file("Reloading page.")
				_FFAction("Reload")
				If @error Then
					_log2file("Connection to Firefox lost.")
					_postprocessing()
				EndIf
			EndIf

			; reset timer
			$begin = TimerInit()
		EndIf
	WEnd
EndFunc   ;==>_getscreenshots

Func _Mark_Rect()
	Local $aMouse_Pos, $hMask, $hMaster_Mask, $iTemp
	Local $UserDLL = DllOpen("user32.dll")

	; Create transparent GUI with Cross cursor
	$hCross_GUI = GUICreate("Test", @DesktopWidth, @DesktopHeight - 20, 0, 0, $WS_POPUP, $WS_EX_TOPMOST)
	WinSetTrans($hCross_GUI, "", 8)
	GUISetState(@SW_SHOW, $hCross_GUI)
	GUISetCursor(3, 1, $hCross_GUI)
	Global $hRectangle_GUI = GUICreate("", @DesktopWidth, @DesktopHeight, 0, 0, $WS_POPUP, $WS_EX_TOOLWINDOW + $WS_EX_TOPMOST)
	GUISetBkColor(0x000000)

	; Wait until mouse button pressed
	While Not _IsPressed("01", $UserDLL)
		Sleep(10)
	WEnd

	; Get first mouse position
	$aMouse_Pos = MouseGetPos()
	$iX1 = $aMouse_Pos[0]
	$iY1 = $aMouse_Pos[1]

	; Draw rectangle while mouse button pressed
	While _IsPressed("01", $UserDLL)
		$aMouse_Pos = MouseGetPos()
		$hMaster_Mask = _WinAPI_CreateRectRgn(0, 0, 0, 0)
		$hMask = _WinAPI_CreateRectRgn($iX1, $aMouse_Pos[1], $aMouse_Pos[0], $aMouse_Pos[1] + 1) ; Bottom of rectangle
		_WinAPI_CombineRgn($hMaster_Mask, $hMask, $hMaster_Mask, 2)
		_WinAPI_DeleteObject($hMask)
		$hMask = _WinAPI_CreateRectRgn($iX1, $iY1, $iX1 + 1, $aMouse_Pos[1]) ; Left of rectangle
		_WinAPI_CombineRgn($hMaster_Mask, $hMask, $hMaster_Mask, 2)
		_WinAPI_DeleteObject($hMask)
		$hMask = _WinAPI_CreateRectRgn($iX1 + 1, $iY1 + 1, $aMouse_Pos[0], $iY1) ; Top of rectangle
		_WinAPI_CombineRgn($hMaster_Mask, $hMask, $hMaster_Mask, 2)
		_WinAPI_DeleteObject($hMask)
		$hMask = _WinAPI_CreateRectRgn($aMouse_Pos[0], $iY1, $aMouse_Pos[0] + 1, $aMouse_Pos[1]) ; Right of rectangle
		_WinAPI_CombineRgn($hMaster_Mask, $hMask, $hMaster_Mask, 2)
		_WinAPI_DeleteObject($hMask)
		; Set overall region
		_WinAPI_SetWindowRgn($hRectangle_GUI, $hMaster_Mask)
		If WinGetState($hRectangle_GUI) < 15 Then GUISetState()
		Sleep(10)
	WEnd

	; Get second mouse position
	$iX2 = $aMouse_Pos[0]
	$iY2 = $aMouse_Pos[1]

	; Set in correct order if required
	If $iX2 < $iX1 Then
		$iTemp = $iX1
		$iX1 = $iX2
		$iX2 = $iTemp
	EndIf
	If $iY2 < $iY1 Then
		$iTemp = $iY1
		$iY1 = $iY2
		$iY2 = $iTemp
	EndIf
	GUIDelete($hRectangle_GUI)
	GUIDelete($hCross_GUI)
	DllClose($UserDLL)
	_log2file("Selected rectangle: X1: " & $iX1 & ", Y1: " & $iY1 & ", X2: " & $iX2 & ", Y2: " & $iY2)
EndFunc   ;==>_Mark_Rect

Func _postprocessing()
	_log2file("Starting postprocessing.")
	; ffmpeg -r 5 -f image2 -i d:\ingress\fftl\image_%05d.jpg -qscale 0 d:\ingress\fftl\test.avi
	MsgBox(0, $title, "Finished recording " & $count & " images. Let´s invoke ffmpeg for video conversion.", 5)
	Local $infile = $directory & StringReplace($imagefilename, "%d", "%05d")
	Local $outfile = $directory & $videofilename
	Local $ffmpeg = @ScriptDir & "\ffmpeg.exe"
	Local $parms = "-r " & $fps & " -f image2 -i " & """" & $infile & """" & " -qscale 0 " & """" & $outfile & """"
	_log2file("AVI (ffmpeg): $parms = " & $parms)
	If FileExists($outfile) Then
		$answer = MsgBox(4, $title, "The video file '" & $outfile & "' does exist. Overwrite? (No = exit without conversion)")
		If $answer = 6 Then
			FileDelete($outfile)
		Else
			MsgBox(0, $title, "Exit without conversion.", 10)
			_log2file("Exit without conversion.")
			Exit
		EndIf
	EndIf

	; start ffmpeg
	ShellExecuteWait($ffmpeg, $parms, $directory, "", @SW_HIDE)
	If Not @error Then
		MsgBox(0, $title, "Sucessfully converted " & $count & " JPGs to AVI. Video file saved as " & $outfile & ".", 10)
		; if activated; convert to animated GIF
		If $anigif = "True" Then
			$giffile = StringReplace($videofilename, ".avi", ".gif")
			MsgBox(0, $title, "Convertig JPGs to animated GIF. This make take a while, please be patient.", 10)
			_converttogif($outfile, $directory & $giffile)
			MsgBox(0, $title, "Sucessfully converted AVI to animated GIF. GIF file saved as '" & $directory & $giffile & "'.", 10)
		EndIf
	Else
		MsgBox(0, $title, "Something went wrong. Sorry!", 10)
	EndIf
	_log2file("--- Regular exit ---")
	Exit
EndFunc   ;==>_postprocessing

Func _addlabel($imgfile)
	; http://www.imagemagick.org/Usage/annotating/
	; convert.exe" "image_00001.jpg" -fill white -undercolor "#00000080" -gravity South -annotate +0+5 " Resistance Kiel       11/21/2013 12:52 " anno_undercolor.jpg
	Local $convert = @ScriptDir & "\convert.exe"
	Local $outfile = $directory & "tmp.jpg"
	Local $text = $caption
	; replace placeholders with date/time
	; <MON>/<DAY>/<YEAR> <HH>:<MIN>:<SEC>
	$text = StringReplace($text, "<DAY>", @MDAY)
	$text = StringReplace($text, "<MON>", @MON)
	$text = StringReplace($text, "<YEAR>", @YEAR)
	$text = StringReplace($text, "<HH>", @HOUR)
	$text = StringReplace($text, "<MiN>", @MIN)
	$text = StringReplace($text, "<SEC>", @SEC)

	Local $parms = """" & $imgfile & """" & " -fill " & $fill & " -undercolor " & """" & $backgroud & """" & " -gravity South -annotate +0+5 " & """" & $text & """" & " " & """" & $outfile & """"
	_log2file("Label (convert): $parms = " & $parms)
	ShellExecuteWait($convert, $parms, $directory, "", @SW_HIDE)
	If FileExists($outfile) And FileGetSize($outfile) > 200 Then
		FileDelete($imgfile)
		FileMove($outfile, $imgfile)
	EndIf
EndFunc   ;==>_addlabel

Func _addlogo($imgfile)
	; composite.exe "re8ki_trans_76.png" "image_00001.jpg" "wmark.jpg"
	Local $composite = @ScriptDir & "\composite.exe"
	Local $outfile = $directory & "tmp.jpg"
	Local $parms = """" & $logofile & """" & " " & """" & $imgfile & """" & " " & """" & $outfile & """"
	_log2file("Logo (composite): $parms = " & $parms)
	ShellExecuteWait($composite, $parms, $directory, "", @SW_HIDE)
	If FileExists($outfile) And FileGetSize($outfile) > 200 Then
		FileDelete($imgfile)
		FileMove($outfile, $imgfile)
	EndIf
EndFunc   ;==>_addlogo

Func _converttogif($vidfile, $giffile)
	; convert -delay 4 -loop 0 -layers OptimizeFrame -colors 51 image*.jpg filename.gif
	; Convert .avi to animated gif(uncompressed)  ffmpeg -i video_origine.avi gif_anime.gif
	Local $convert = @ScriptDir & "\convert.exe"
	; Local $parms = "-i " & """" & $vidfile & """" & " " & """" & $giffile & """"
	Local $parms = "-delay " & $delay & " -loop " & $loop & " -layers OptimizeFrame -colors " & $colors & " " & """" & $directory & "*.jpg" & """" & " " & """" & $giffile & """"
	If FileExists($giffile) Then
		$answer = MsgBox(1, $title, "GIF file '" & $giffile & "' already exists. Overwrite it (Ok) or skip converting (Cancel)?")
		If $answer = 1 Then
			FileDelete($giffile)
		Else
			Return
		EndIf
	EndIf
	_log2file("GIF (convert): $parms = " & $parms)
	; start convert
	ShellExecuteWait($convert, $parms, $directory, "", @SW_HIDE)
EndFunc   ;==>_converttogif

Func _log2file($line)
	If $log = "True" Then
		Local $tCur = _Date_Time_GetLocalTime()
		Local $lf = FileOpen($logfile, 1)
		FileWriteLine($lf, _Date_Time_SystemTimeToDateTimeStr($tCur) & " " & $line & @CRLF)
		FileClose($lf)
	EndIf
EndFunc   ;==>_log2file

Func _checkfiles()
	Local $binfiles[3]
	Local $err = False
	$binfiles[0] = @ScriptDir & "\ffmpeg.exe"
	$binfiles[1] = @ScriptDir & "\convert.exe"
	$binfiles[2] = @ScriptDir & "\composite.exe"
	For $i = 0 To UBound($binfiles, 1) - 1
		If Not FileExists($binfiles[$i]) Then
			_log2file("Missing file : " & $binfiles[$i])
			MsgBox(0, $title, "Error, missing file: '" & $binfiles[$i] & "'!")
			$err = True
		EndIf
	Next
	If $err = True Then
		Exit
	Else
		_log2file("All required files are present.")
	EndIf
EndFunc   ;==>_checkfiles
