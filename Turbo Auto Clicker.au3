#include <AutoItConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <misc.au3>
#include <MouseOnEvent.au3>

#RequireAdmin
Break(0)							;Prevents right click close operation
Opt("GUIOnEventMode", 1)			;Allows GUI events
HotKeySet("{F10}", "_Terminate")	;Finish both script and GUI
SRandom(@SEC)						;Sets seed

;Var
Global $listen = True				;Event listener status
Global $state = False				;Mouse button status
Global $dll = DllOpen("user32.dll")
Global $freq = 50					;Click frequency
Global $keyStr = "78"				;Turn on/off key: F9 default
Global $waitFreq = 150				;Sleep time
Global $kPressed = False			;Turn on/off key press log

;GUI
Func _CreateGui()
   Local $RStr = ""	;Random window name
   For $i = 1 To 15
	  $RStr &= Chr(Random(48, 122, 1))
   Next
   Global $gui = GUICreate($RStr, 300, 260)
   GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseGui")	;Close GUI, keep script
   Local $lblFreq = GUICtrlCreateLabel("Frequency (ms): ", 40, 30)
   Global $freqIn = GUICtrlCreateInput($freq, 145, 28, 20, 20, $ES_NUMBER)	;$ES_READONLY
   GUICtrlSetLimit(-1, 2)
   Local $lblKey = GUICtrlCreateLabel("Turn ON/OFF key: ", 40, 65)
   Global $keyIn = GUICtrlCreateInput($keyStr, 145, 63, 20, 20)
   GUICtrlSetLimit(-1, 2)
   Local $btnChg = GUICtrlCreateButton("Apply", 193, 43, 60, 25)
   GUICtrlSetOnEvent(-1, "_ApplyChanges")
   Local $lblCls = GUICtrlCreateLabel("Closing the window will not finish the process!" & @CRLF & "Press F10 to finish properly.", 40, 120)
   Local $btnDnt = GUICtrlCreateButton("Donate", 160, 180, 60, 25)
   GUICtrlSetOnEvent(-1, "_OpenDonate")
   Local $btnTrd = GUICtrlCreateButton("Thread", 80, 180, 60, 25)
   GUICtrlSetOnEvent(-1, "_OpenThread")
   Local $lblCls = GUICtrlCreateLabel("v1.102.01 - 01/04/2022", 175, 240)
   GUISetState(@SW_SHOW, $gui)
EndFunc

Func _OpenDonate()
   Local $url = "https://pastebin.com/1t3uDVpR"
   RunWait(@ComSpec & " /c start " & $url)
EndFunc

Func _OpenThread()
   Local $url = "https://www.mpgh.net/forum/forumdisplay.php?f=175"
   RunWait(@ComSpec & " /c start " & $url)
EndFunc

;Main
Call("_CreateGui")
While True
   If $state Then	;Click being held
	  Sleep($freq)
	  MouseClick($MOUSE_CLICK_LEFT)
   Else	;Check for key status, prevents stuck at working state error
	  If _IsPressed($keyStr, $dll) Then
		 Beep(500, 250)
		 $kPressed = Not $kPressed	;Updates key press log
		 Call("_TurnOnOff")
		 While _IsPressed($keyStr, $dll)
			Sleep(250)
		 WEnd
	  EndIf
   EndIf
   Sleep($waitFreq)	;Prevents high CPU usage
WEnd

Func _TurnOnOff()
	  If $listen Then		;Enable listener
		 _MouseSetOnEvent($MOUSE_PRIMARYDOWN_EVENT, "_StateChange")
		 _MouseSetOnEvent($MOUSE_PRIMARYUP_EVENT, "_StateChange")
		 $waitFreq = 10							;Active sleep time
	  Else					;Disable listener
		 _MouseSetOnEvent($MOUSE_PRIMARYDOWN_EVENT)
		 _MouseSetOnEvent($MOUSE_PRIMARYUP_EVENT)
		 $waitFreq = 150						;Stand-by sleep time
	  EndIf
	  $listen = Not $listen		;Update listener status
EndFunc

Func _StateChange()
   If $kPressed Then			;Prevents 'ghost key press' bug
	  $state = Not $state		;Update Mouse button status
   Else							;Correct state
	  $listen = False
	  Call("_TurnOnOff")
   EndIf
EndFunc

Func _ApplyChanges()
   $keyStr = GUICtrlRead($keyIn)
   $freq = Int(GUICtrlRead($freqIn), 1)
EndFunc

Func _CloseGui()
   GUIDelete($gui)
EndFunc

Func _Terminate()		;Special close
   DllClose($dll)
   GUIDelete($gui)
   Exit 0
EndFunc