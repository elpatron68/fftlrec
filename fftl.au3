#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=camera-video_mount.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Fileversion=0.1.0.1
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_LegalCopyright=elpatron@cepheus.uberspace.de
#AutoIt3Wrapper_Run_Tidy=y
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
; Firefox Timelapse
; 2013 Markus Busche, m.busche+fftl@gmail.com
;
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
Global $count = 0

; Read values from INI file fftl.ini
Global $URL = IniRead("fftl.ini", "settings", "url", "")
Global $directory = IniRead("fftl.ini", "files", "directory", @ScriptDir & "\")
Global $imagefilename = IniRead("fftl.ini", "files", "imagefilename", "image_%d.jpg")
Global $videofilename = IniRead("fftl.ini", "files", "videofilename", "fftl-video.avi")
Global $reload = IniRead("fftl.ini", "settings", "reload", "60") * 1000
Global $tooltips = IniRead("fftl.ini", "settings", "tooltips", "True")
Global $log = IniRead("fftl.ini", "settings", "log", "False")
; Rectangle
Global $iX1 = IniRead("fftl.ini", "region", "X1", "")
Global $iY1 = IniRead("fftl.ini", "region", "Y1", "")
Global $iX2 = IniRead("fftl.ini", "region", "X2", "")
Global $iY2 = IniRead("fftl.ini", "region", "Y2", "")
Global $fps = IniRead("fftl.ini", "video", "fps", "5")
Global $title = "Firefox Timelapse v0.1"
; Label settings
Global $addlabel = IniRead("fftl.ini", "label", "addlabel", "False")
Global $caption = IniRead("fftl.ini", "label", "caption", " Firefox Timelapse ")
Global $backgroud = IniRead("fftl.ini", "label", "backgroud", "#0008")
Global $fill = IniRead("fftl.ini", "label", "fill", "white")
; Logo Settings
Global $addlogo = IniRead("fftl.ini", "logo", "addlogo", "False")
Global $logo = IniRead("fftl.ini", "logo", "logo", "")
; Animated GIF
Global $anigif = IniRead("fftl.ini", "gif", "convert2gif", "False")

If $URL = "" Then
	$URL = InputBox($title, "Enter URL:", "http://example.com")
	If @error Then
		MsgBox(0, $title, "Empty URL or canceled. I will terminate.")
		Exit
	EndIf
EndIf

; check for correct filename
If Not StringInStr($imagefilename, "%d") Then
	$imagefilearr = StringSplit($imagefilename, ".")
	$imagefilename = $imagefilearr[0] & "_%d.jpg"
EndIf

; check directory
If $directory <> "" And Not FileExists($directory) Then
	MsgBox(0, $title, "Directory " & $directory & " doesn´t exist. I will terminate.")
	Exit
EndIf

If $directory = "" Then
	$directory = @ScriptDir & "\"
EndIf

If StringRight($directory, 1) <> "\" Then
	$directory = $directory & "\"
EndIf

; connect to Firefox instance
If _FFConnect(Default, Default, 3000) Then
	_FFOpenURL($URL)
	_FFLoadWait()
	WinActivate("[CLASS:MozillaWindowClass]", "")
Else
	MsgBox(0, $title, "Error connecting to Mozilla Firefox. Start Firefox and /or Download and activate the MozRepl plugin.")
	Exit
EndIf

Sleep(10000)

If $iX1 = "" Then
	MsgBox(0, $title, "Now click 'Ok' and draw a rectangle to be captured. To stop recording, hit Alt-Shift-S.")
	_Mark_Rect()
	;MsgBox(0,"",$iX1 & ", " & $iy1 & ", " & $iX2 & ", " & $iy2)
EndIf

_getscreenshots()
Exit

Func _getscreenshots()
	; set timer
	Local $begin = TimerInit()
	Local $countstr = ""
	Local $filename = ""
	While 1
		Sleep(1000)
		$dif = TimerDiff($begin)
		If $dif > ($reload) Then
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
			_log2file("Captured " & $filename)
			_ScreenCapture_Capture($filename, $iX1, $iY1, $iX2, $iY2, False)
			If $tooltips = "True" Then
				TrayTip("", "Saved screenshot " & $filename, 10, 1)
			EndIf

			; add label
			If $addlabel = "True" Then
				_addlabel($filename)
			EndIf

			; add logo
			If $addlogo = "True" Then
				_addlogo($filename)
			EndIf

			$StillRunning = _FFAction("Reload")
			_FFLoadWait()
			If $StillRunning <> "" Then
				_postprocessing()
				Exit
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
	_log2file('@@ Debug(' & @ScriptLineNumber & ') Selected rectangle: X1: " & $iX1 & ", Y1: " & $iY1 & ", X2: " & $iX2 & ", Y2: " & $iY2)
EndFunc   ;==>_Mark_Rect

Func _postprocessing()
	; ffmpeg -r 5 -f image2 -i d:\ingress\fftl\image_%05d.jpg -qscale 0 d:\ingress\fftl\test.avi
	MsgBox(0, $title, "Finished recording " & $count & " images. Let´s invoke ffmpeg for video conversion.", 5)

	Local $infile = $directory & StringReplace($imagefilename, "%d", "%05d")
	Local $outfile = $directory & $videofilename
	Local $ffmpeg = @ScriptDir & "\ffmpeg.exe"
	Local $parms = "-r " & $fps & " -f image2 -i " & """" & $infile & """" & " -qscale 0 " & """" & $outfile & """"
	_log2file('@@ Debug(' & @ScriptLineNumber & ') : $parms = ' & $parms & @CRLF & '>Error code: ' & @error) ;### Debug Console

	If FileExists($outfile) Then
		$answer = MsgBox(4, $title, "The video file '" & $outfile & "' does exist. Overwrite? (No = exit without conversion)")
		If $answer = 6 Then
			FileDelete($outfile)
		Else
			MsgBox(0, $title, "Exit without conversion.", 10)
			Exit
		EndIf
	EndIf

	; start ffmpeg
	ShellExecuteWait($ffmpeg, $parms, $directory, "", @SW_HIDE)
	If Not @error Then
		MsgBox(0, $title, "Sucessfully converted " & $count & " JPGs to AVI. Video file saved as " & $outfile & ".", 10)
		If $anigif = "True" Then
			$giffile = StringReplace($videofilename, ".avi", ".gif")
			_converttogif($outfile, $directory & $giffile)
			MsgBox(0, $title, "Sucessfully converted AVI to animated GIF. GIF file saved as " & $directory & $giffile & ".", 10)
		EndIf
	Else
		MsgBox(0, $title, "Something went wrong. Sorry!", 10)
	EndIf
	Exit
EndFunc   ;==>_postprocessing

Func _addlabel($imgfile)
	; http://www.imagemagick.org/Usage/annotating/
	; convert.exe" "image_00001.jpg" -fill white -undercolor "#00000080" -gravity South -annotate +0+5 " Resistance Kiel       11/21/2013 12:52 " anno_undercolor.jpg
	Local $convert = @ScriptDir & "\convert.exe"
	Local $outfile = $directory & "tmp.jpg"
	; replace placeholders with date/time
	$caption = StringReplace($caption, "<DAY>", @MDAY)
	$caption = StringReplace($caption, "<MON>", @MON)
	$caption = StringReplace($caption, "<YEAR>", @YEAR)
	$caption = StringReplace($caption, "<HH>", @HOUR)
	$caption = StringReplace($caption, "<MIN>", @MIN)
	$caption = StringReplace($caption, "<SEC>", @SEC)
	Local $parms = """" & $imgfile & """" & " -fill " & $fill & " -undercolor " & """" & $backgroud & """" & " -gravity South -annotate +0+5 " & """" & $caption & """" & " " & """" & $outfile & """"
	_log2file('@@ Debug(' & @ScriptLineNumber & ') : $parms = ' & $parms & @CRLF & '>Error code: ' & @error) ;### Debug Console
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
	Local $parms = """" & $logo & """" & " " & """" & $imgfile & """" & " " & """" & $outfile & """"
	_log2file('@@ Debug(' & @ScriptLineNumber & ') : $parms = ' & $parms & @CRLF & '>Error code: ' & @error) ;### Debug Console
	ShellExecuteWait($composite, $parms, $directory, "", @SW_HIDE)
	If FileExists($outfile) And FileGetSize($outfile) > 200 Then
		FileDelete($imgfile)
		FileMove($outfile, $imgfile)
	EndIf
EndFunc   ;==>_addlogo

Func _converttogif($vidfile, $giffile)
	; Convert .avi to animated gif(uncompressed)  ffmpeg -i video_origine.avi gif_anime.gif
	Local $ffmpeg = @ScriptDir & "\ffmpeg.exe"
	Local $parms = "-i " & """" & $vidfile & """" & " " & """" & $giffile & """"
	_log2file('@@ Debug(' & @ScriptLineNumber & ') : $parms = ' & $parms & @CRLF & '>Error code: ' & @error) ;### Debug Console
	; start ffmpeg
	ShellExecuteWait($ffmpeg, $parms, $directory, "", @SW_HIDE)
EndFunc   ;==>_converttogif

Func _log2file($line)
	if $log = "True" Then
		Local $tCur = _Date_Time_GetLocalTime()
		Local $logfile = FileOpen(@ScriptDir & "\fftl.log", 1)
		FileWriteLine($logfile, _Date_Time_SystemTimeToDateTimeStr($tCur) & " " & $line & @CRLF)
		FileClose($logfile)
	EndIf
EndFunc   ;==>_log2file
