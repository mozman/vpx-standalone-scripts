' ***************************************************************************************************
' Cueball Wizard (Gottlieb 1992)
' by Vogliadicane
' Table history and credits:
' JPSalas (VP9 version) -> Rascal (conversion to VPX) -> Bigus (BigusMod) -> Psiomicron/Rawd (VR ROOM)
'
' Big thanks go to:
' *****Schreibi34 
' for his awsome insert images
' https://vpinball.com/VPBdownloads/prerenderd-insert-images/
' and most for creating all 8-Ball unit primitives for this table
' it was a great pleasure to work with you, mate!
' *****kds70 
' for some great help with scripting
' Thanks a lot my friend!
' *****@jipeji16 
' for letting me steal his code for LUT changing and saving. All LUTs used are from me, but you better look at the code, where he stole from (with permission.. at least he calimed so ;) )
' *****Thalamus 
' for checking and updating the script for SSF
' ***************************************************************************************************

' CHANGE LOG
'0.7.0 : Mod by Vogliadicane : https://vpuniverse.com/files/file/7487-cueball-wizard-gottlieb-1992-v-07/
'1.0.0 : VR ROOM by Psiomicron/Rawd from  Vogliadicane Mod : https://vpuniverse.com/files/file/6068-vr-room-cueball-wizard-gottlieb-1992-minimal/
'        Lighting, timer, and primitive tweaks by Sixtoe.
'        Dynamic lighting and Semi minimal room by Rawd
'        Semi Minimal Room and tweaks (dynamic shadows. I also did a physics tweak to the top of both slings) by Rawd.
'1.1.0 : Fleep mechanicals sounds, nFozzy physics, Roth Drop Targets, Slingshot correction, Ramp rolling (Mikcab)	
'1.1.1 : Center post removed like the real machine, Roth Stand-up Targets added (Mikcab)

Option Explicit
Randomize

On Error Resume Next
ExecuteGlobal GetTextFile("controller.vbs")
If Err Then MsgBox "You need the controller.vbs in order to run this table, available in the vp10 package"
On Error Goto 0


'*******************************************
'  User Options
'*******************************************

'----- General Sound Options -----
Const VolumeDial = 0.8			  'Overall Mechanical sound effect volume. Recommended values should be no greater than 1.
Const BallRollVolume = 0.5		  'Level of ball rolling volume. Value between 0 and 1
Const RampRollVolume = 0.5		  'Level of ramp rolling volume. Value between 0 and 1

'----- Shadow Options -----
Const DynamicBallShadowsOn = 1	  '0 = no dynamic ball shadow ("triangles" near slings and such), 1 = enable dynamic ball shadow
Const AmbientBallShadowOn = 1	   '0 = Static shadow under ball ("flasher" image, like JP's), 1 = Moving ball shadow ("primitive" object, like ninuzzu's) - This is the only one that behaves like a true shadow!, 2 = flasher image shadow, but it moves like ninuzzu's

'---- Options (Vogliadicane) ----
DisableLUTSelector = 0  ' Disables the ability to change LUT option with magna saves in game when set to 1
AcrylicUpperPlayfield = 1 '0:glass like, 1:worn out, 2:grunge

' change LUT with left and right magna save keys

'*******************************************
'  Constants and Global Variables
'*******************************************
Const BallSize = 54					'Ball size must be 50
Const BallMass = 1					'Ball mass must be 1
Const tnob = 4                      ' total number of balls
Const lob = 2						'Locked balls

Dim tablewidth: tablewidth = Table1.width
Dim tableheight: tableheight = Table1.height

'*******************************************
'  Timers
'*******************************************

' The game timer interval is 10 ms
Sub GameTimer_Timer()
	Cor.Update 						'update ball tracking (this sometimes goes in the RDampen_Timer sub)
	RollingUpdate					'update rolling sounds
	DoDTAnim 						'handle drop target animations
	DoSTAnim						'handle stand up target animations
End Sub

Dim FrameTime, InitFrameTime
InitFrameTime = 0
Sub FrameTimer_Timer() 'The frame timer interval should be -1, so executes at the display frame rate
	FrameTime = GameTime - InitFrameTime
	InitFrameTime = GameTime	'Count frametime
	WBallShadowUpdate
	LampTimer

	FlipperLSh.RotZ = LeftFlipper.currentangle
	FlipperRSh.RotZ = RightFlipper.currentangle
	LeftFlipperP.objRotZ = LeftFlipper.CurrentAngle-90
	RightFlipperP.objRotZ = RightFlipper.CurrentAngle-90

	If DynamicBallShadowsOn Or AmbientBallShadowOn Then DynamicBSUpdate 'update ball shadows
End Sub
'*******************************************


Dim Lspeed(7), Lbob(7), blobAng(7), blobRad(7), blobSiz(7), Blob, Bcnt   ' for VR Lavalamp

Const cGameName="cueball",UseSolenoids=2,UseLamps=0,UseGI=0,SSolenoidOn="",SSolenoidOff="", SCoin="", UseVPMDMD = True

LoadVPM "01570000", "gts3.vbs", 3.26

'----- VR Room Auto-Detect -----
Dim VRRoom, VR_Obj

If RenderingMode = 2 Then
	For Each VR_Obj in VRCabinet : VR_Obj.Visible = 1 : Next
	For Each VR_Obj in VRMainRoom : VR_Obj.Visible = 1 : Next
Else
	For Each VR_Obj in VRCabinet : VR_Obj.Visible = 0 : Next
	For Each VR_Obj in VRMainRoom : VR_Obj.Visible = 0 : Next
End If

Dim DesktopMode: DesktopMode = Table1.ShowDT

If DesktopMode = True Then ' Show Desktop components
	Pincab_Rails.visible = 1
	Pincab_Blades.visible = 1
	Primitive13.visible = 1
End If

Dim AcrylicUpperPlayfield
Dim MyPrefs_Brightness, MyPrefs_DisableBrightness, LUTBoxText

'*************************************************************
'Execute Options
'*************************************************************
Select Case AcrylicUpperPlayfield
  Case 0:Primitive006.Image = "Plexiwanne Textur 01"
  Case 1:Primitive006.Image = "Plexiwanne Textur 01_Vog"
  Case 2:Primitive006.Image = "Plexiwanne Textur 01_VogGrunge"
End Select

'**********************************************************
'*  LUT Options - Script Taken from The Flintstones       *
'* All lut examples taken from The Flintstones, TOTAN and *
'*       007 - Big Thanks for all the samples             *
'**********************************************************
Dim LUTmeUP:'LUTMeUp = 1 '0 = No LUT Initialized in the memory procedure
Dim DisableLUTSelector':DisableLUTSelector = 0  ' Disables the ability to change LUT option with magna saves in game when set to 1
Const MaxLut = 7
'********************************************************


'*************** LUT Memory by JPJ ****************
dim FileObj, File, LUTFile, Txt, TxtTF 'Dim for LUT Memory Outside Init's SUB
Set FileObj = CreateObject("Scripting.FileSystemObject")
If Not FileObj.FileExists(UserDirectory & "CBWLUT.txt") then
  MyPrefs_Brightness = 7:WriteLUT
End if
If FileObj.FileExists(UserDirectory & "CBWLUT.txt") then
  Set LUTFile=FileObj.GetFile(UserDirectory & "CBWLUT.txt")
  Set Txt=LUTFile.OpenAsTextStream(1,0) 'Number taken from the file
  TxtTF = cint(txt.readline)
  MyPrefs_Brightness = TxtTF
  if MyPrefs_Brightness >MaxLut or MyPrefs_Brightness <0 or MyPrefs_Brightness = Null Then
    MyPrefs_Brightness = 7
  End if
  SetLUT
End if
'****************************************************

'*************************************************************
'Solenoid Call backs
'**********************************************************************************************************

SolCallback(8) = "Solgate" 'Plunger Gate
SolCallback(9) = "SolDropUpRight" 'Drop Targets Right
SolCallback(10) = "SolShoot8Ball" 'Ball Shooter
SolCallback(11) = "bsBSaucer.SolOut" 'Bottom Left Upkicker
SolCallback(12) = "SolDropUpLeft" 'Drop Targets Left
SolCallback(13) = "bsLSaucer.SolOut" 'Top Left Upkicker
SolCallback(14) = "bsRSaucer.SolOut" 'Top Right Upkicker
SolCallback(15) = "SetLamp 151," 'Light box insert
SolCallback(16) = "SetLamp 152," 'Light Box insert
SolCallback(17) = "SetLamp 153," 'Light Strip 1
SolCallback(18) = "SetLamp 154," 'Light Strip 2
SolCallback(19) = "SetLamp 155," 'Light Strip 3
SolCallback(20) = "SetLamp 156," 'Shooter Playboard
SolCallback(21) = "SetLamp 157," 'Dome Left Ramp
SolCallback(22) = "SetLamp 158," 'Dome Right Ramp
SolCallback(25) = "RotateStart" 'motor relay
SolCallback(26) ="PFGI" 'Lightbox insert illum relay
SolCallback(28) = "bsTrough.SolOut" 'Ballrelease
SolCallback(29) = "bsTrough.SolIn" 'Outhole
SolCallback(30) = "vpmSolSound SoundFX(""Knocker"",DOFKnocker),"
' SolCallback(31) = "SolTilt" 'Tilt relay
' SolCallback(32) = "SolGameOver" 'Game Over relay

SolCallback(sLRFlipper) = "SolRFlipper"
SolCallback(sLLFlipper) = "SolLFlipper"


'******************************************************
' 					VR Setup
'******************************************************
Dim VarHidden
VarHidden = 1

Sub TimerVRPlunger_Timer
	If VR_Primary_plunger.Y < 1200 then
		VR_Primary_plunger.Y = VR_Primary_plunger.Y + 5
	End If
End Sub
Sub TimerVRPlunger2_Timer
	VR_Primary_plunger.Y = 20.68 + (5* Plunger.Position) -20
End Sub

'**********************************************************************************************************

'Solenoid Controlled toys
'**********************************************************************************************************

 Sub SolDropUpRight(Enable)
		DTRaise 23
		DTRaise 33
		DTRaise 24
		DTRaise 34
		DTRaise 25
		DTRaise 35
		DTRaise 36
		PlaySoundAt SoundFX(DTResetSound,DOFContactors), sw25p
End Sub

 Sub SolDropUpLeft(Enable)
		DTRaise 20
		DTRaise 30
		DTRaise 21
		DTRaise 31
		DTRaise 22
		DTRaise 32
		DTRaise 26
		PlaySoundAt SoundFX(DTResetSound,DOFContactors), sw22p
End Sub

Sub Solgate(Enabled)
  If Enabled Then
    PlungerGate.IsDropped=1
    PlaySound SoundFX("",DOFContactors)
  Else
    vpmtimer.addtimer 200,"PlungerGate.IsDropped=0 '"
  End If
End Sub

Sub SolTilt(Enabled)
  If Enabled Then
    vpmTimer.PulseSw 151
  Else
  End If
End Sub


'****************************************************************
'  Playfield GI
'****************************************************************
dim gilvl:gilvl = 1
Sub PFGI(Enabled)
	dim xx
	If enabled Then
		for each xx in GI:xx.state = 1:Next
		gilvl = 1
		Playsound "relay_on"
	Else
		for each xx in GI:xx.state = 0:Next	
		GITimer.enabled = True
		gilvl = 0
		Playsound "relay_off"
	End If
'	Sound_GI_Relay enabled, bumper1
End Sub

Sub GITimer_Timer()
	me.enabled = False
	PFGI 1
End Sub


'*******************************************
'	 Table Initialization and Exiting
'*******************************************

Dim bsTrough, bsBSaucer, bsLSaucer, bsRSaucer, dtLBank, dtRBank, mShooter
LUTBox.Visible = 0

Sub Table1_Init
  vpmInit Me
  On Error Resume Next
  With Controller
    .GameName = cGameName
    If Err Then MsgBox "Can't start Game" & cGameName & vbNewLine & Err.Description : Exit Sub
    .SplashInfoLine = ""&chr(13)&"You Suck"
    .HandleMechanics=0
    .HandleKeyboard=0
    .ShowDMDOnly=1
    .ShowFrame=0
    .ShowTitle=0
    .hidden = 0
    On Error Resume Next
    .Run GetPlayerHWnd
    If Err Then MsgBox Err.Description
    On Error Goto 0
  End With
  On Error Goto 0

  PinMAMETimer.Interval=PinMAMEInterval
  PinMAMETimer.Enabled=1
  vpmNudge.TiltSwitch = 151
  vpmNudge.Sensitivity = 2
  vpmNudge.TiltObj = Array(Bumper1, Bumper2, LeftSlingshot, RightSlingshot)

  Set bsTrough = New cvpmBallStack
  bsTrough.InitSw 40, 41, 0, 0, 0, 0, 0, 0
  bsTrough.InitKick BallRelease, 80, 6
  bsTrough.InitExitSnd SoundFX("ballrelease",DOFContactors), SoundFX("Solenoid",DOFContactors)
  bsTrough.Balls = 3

  Set bsBSaucer = New cvpmBallStack
  bsBSaucer.InitSaucer sw17, 17, 134, 15
  bsBSaucer.InitExitSnd SoundFX("Popper",DOFContactors), SoundFX("Solenoid",DOFContactors)
  bsBSaucer.KickAngleVar = 2
  bsBSaucer.KickForceVar = 4

  Set bsLSaucer = New cvpmBallStack
  bsLSaucer.InitSaucer sw27, 27, 225, 11
  bsLSaucer.InitExitSnd SoundFX("Popper",DOFContactors), SoundFX("Solenoid",DOFContactors)
  bsLSaucer.KickAngleVar = 2
  bsLSaucer.KickForceVar = 2

  Set bsRSaucer = New cvpmBallStack
  bsRSaucer.InitSaucer sw37, 37, 145, 11
  bsRSaucer.InitExitSnd SoundFX("Popper",DOFContactors), SoundFX("Solenoid",DOFContactors)
  bsRSaucer.KickAngleVar = 2
  bsRSaucer.KickForceVar = 2

'  set dtLBank = new cvpmdroptarget
' dtLBank.initdrop array(sw20, sw30, sw21, sw31, sw22, sw32, sw26), array(20, 30, 21, 31, 22, 32, 26)
'  dtLBank.initsnd SoundFX("DTDrop",DOFContactors),SoundFX("DTReset",DOFContactors)
'  dtLBank.CreateEvents "dtLBank"

'  set dtRBank = new cvpmdroptarget
'  dtRBank.initdrop array(sw23, sw33, sw24, sw34, sw25, sw35, sw36), array(23, 33, 24, 34, 25, 35, 36)
'  dtRBank.initsnd SoundFX("DTDrop",DOFContactors),SoundFX("DTReset",DOFContactors)
'  dtRBank.CreateEvents "dtRBank"

  Set mShooter = New cvpmMech
  With mShooter
    .MType = vpmMechOneSol + vpmMechReverse + vpmMechLinear
    .Sol1 = 25
    .Length = 80
    .Steps = 9
    .Callback = GetRef("UpdateShooter")
    .Start
  End With
  PlungerGate.IsDropped=0
  CreateBlackBall
  CreateWhiteBall
End Sub

Sub Table1_Paused:Controller.Pause = 1:End Sub
Sub Table1_unPaused:Controller.Pause = 0:End Sub


'*******************************************
'	 Key Press Handling
'*******************************************

Dim BIPL : BIPL=0
Sub Table1_KeyDown(ByVal Keycode)
	If Keycode = LeftFlipperKey Then FlipperActivate LeftFlipper, LFPress
	If Keycode = RightFlipperKey Then FlipperActivate RightFlipper, RFPress
  If keycode = LeftFlipperKey Then Controller.Switch(81) = 1
  If keycode = RightFlipperKey Then Controller.Switch(82) = 1
  If keycode = StartGameKey Then Controller.Switch(4) = 1

	If keycode = keyInsertCoin1 or keycode = keyInsertCoin2 or keycode = keyInsertCoin3 or keycode = keyInsertCoin4 Then
		Select Case Int(rnd*3)
			Case 0: PlaySound ("Coin_In_1"), 0, CoinSoundLevel, 0, 0.25
			Case 1: PlaySound ("Coin_In_2"), 0, CoinSoundLevel, 0, 0.25
			Case 2: PlaySound ("Coin_In_3"), 0, CoinSoundLevel, 0, 0.25
		End Select
	End If

  If keycode = PlungerKey Then 
	Plunger.Pullback:SoundPlungerPull()
	TimerVRPlunger.Enabled = True
	TimerVRPlunger2.Enabled = False
  End if

    if keycode=StartGameKey then soundStartButton()
	If keycode = LeftTiltKey Then Nudge 90, 1:SoundNudgeLeft()
	If keycode = RightTiltKey Then Nudge 270, 1:SoundNudgeRight()
	If keycode = CenterTiltKey Then Nudge 0, 2:SoundNudgeCenter()

  If Keycode = LeftFlipperKey Then
		
		FlipperButtonLeft.X = 2110.73 + 10
  End if
  If Keycode = RightFlipperKey Then
		FlipperButtonRight.X = 2158.063 - 10 
  End if

  If vpmKeyDown(keycode) Then Exit Sub
End Sub

Sub Table1_KeyUp(ByVal Keycode)
    If Keycode = LeftFlipperKey Then FlipperDeActivate LeftFlipper, LFPress
	If Keycode = RightFlipperKey Then FlipperDeActivate RightFlipper, RFPress
  If keycode = LeftFlipperKey Then Controller.Switch(81) = 0
  If keycode = RightFlipperKey Then Controller.Switch(82) = 0
  If keycode = StartGameKey Then Controller.Switch(4) = 0

  If keycode = PlungerKey Then 
	Plunger.Fire
                If BIPL = 1 Then
                        SoundPlungerReleaseBall()                        'Plunger release sound when there is a ball in shooter lane
                Else
                        SoundPlungerReleaseNoBall()                        'Plunger release sound when there is no ball in shooter lane
                End If
	TimerVRPlunger.Enabled = False
	TimerVRPlunger2.Enabled = True
	VR_Primary_plunger.Y = 20.68 
  End if

  If keycode = RightMagnaSave Then
    if MyPrefs_DisableBrightness = 0 then
      MyPrefs_Brightness = MyPrefs_Brightness + 1
      if MyPrefs_Brightness > MaxLut then MyPrefs_Brightness = 0
        SetLUT
        ShowLUT
        Playsound "button-click"
      end if
    end if
  If keycode = LeftMagnaSave Then
    if MyPrefs_DisableBrightness = 0 then
      MyPrefs_Brightness= MyPrefs_Brightness - 1
      if MyPrefs_Brightness < 0 then MyPrefs_Brightness = MaxLut
        SetLUT
        ShowLUT
        Playsound "button-clickOff"
      end if
    end if
If Keycode = LeftFlipperKey Then
		FlipperButtonLeft.X = 2110.73
	End if
	If keycode = RightFlipperKey Then
		FlipperButtonRight.X = 2158.063
	End If
  If vpmKeyUp(keycode) Then Exit Sub
End Sub


'*******************************************
'        Flippers
'*******************************************

Const ReflipAngle = 20

' Flipper Solenoid Callbacks (these subs mimics how you would handle flippers in ROM based tables)
Sub SolLFlipper(Enabled)
	If Enabled Then
		LF.Fire  'leftflipper.rotatetoend
		If leftflipper.currentangle < leftflipper.endangle + ReflipAngle Then 
			RandomSoundReflipUpLeft LeftFlipper
		Else 
			SoundFlipperUpAttackLeft LeftFlipper
			RandomSoundFlipperUpLeft LeftFlipper
		End If		
	Else
		LeftFlipper.RotateToStart 
		If LeftFlipper.currentangle < LeftFlipper.startAngle - 5 Then
			RandomSoundFlipperDownLeft LeftFlipper
		End If
		FlipperLeftHitParm = FlipperUpSoundLevel
	End If
End Sub

Sub SolRFlipper(Enabled)
	If Enabled Then
		RF.Fire 'rightflipper.rotatetoend

		If rightflipper.currentangle > rightflipper.endangle - ReflipAngle Then
			RandomSoundReflipUpRight RightFlipper
		Else 
			SoundFlipperUpAttackRight RightFlipper
			RandomSoundFlipperUpRight RightFlipper
		End If
	Else
		RightFlipper.RotateToStart
		If RightFlipper.currentangle > RightFlipper.startAngle + 5 Then
			RandomSoundFlipperDownRight RightFlipper
		End If	
		FlipperRightHitParm = FlipperUpSoundLevel
	End If
End Sub


' Flipper collide subs
Sub LeftFlipper_Collide(parm)
	CheckLiveCatch Activeball, LeftFlipper, LFCount, parm
	LeftFlipperCollide parm
End Sub

Sub RightFlipper_Collide(parm)
	CheckLiveCatch Activeball, RightFlipper, RFCount, parm
	RightFlipperCollide parm
End Sub


'******************************************************
'****  GNEREAL ADVICE ON PHYSICS
'******************************************************
'
' It's advised that flipper corrections, dampeners, and general physics settings should all be updated per these 
' examples as all of these improvements work together to provide a realistic physics simulation.
'
' Tutorial videos provided by Bord
' Flippers: 	https://www.youtube.com/watch?v=FWvM9_CdVHw
' Dampeners: 	https://www.youtube.com/watch?v=tqsxx48C6Pg
' Physics: 		https://www.youtube.com/watch?v=UcRMG-2svvE
'
'
' Note: BallMass must be set to 1. BallSize should be set to 50 (in other words the ball radius is 25) 
'
' Recommended Table Physics Settings
' | Gravity Constant             | 0.97      |
' | Playfield Friction           | 0.15-0.25 |
' | Playfield Elasticity         | 0.25      |
' | Playfield Elasticity Falloff | 0         |
' | Playfield Scatter            | 0         |
' | Default Element Scatter      | 2         |
'
' Bumpers
' | Force         | 9.5-10.5 |
' | Hit Threshold | 1.6-2    |
' | Scatter Angle | 2        |
' 
' Slingshots
' | Hit Threshold      | 2    |
' | Slingshot Force    | 4-5  |
' | Slingshot Theshold | 2-3  |
' | Elasticity         | 0.85 |
' | Friction           | 0.8  |
' | Scatter Angle      | 1    |



'******************************************************
'****  FLIPPER CORRECTIONS by nFozzy
'******************************************************
'
' There are several steps for taking advantage of nFozzy's flipper solution.  At a high level well need the following:
'	1. flippers with specific physics settings
'	2. custom triggers for each flipper (TriggerLF, TriggerRF)
'	3. an object or point to tell the script where the tip of the flipper is at rest (EndPointLp, EndPointRp)
'	4. and, special scripting
'
' A common mistake is incorrect flipper length.  A 3-inch flipper with rubbers will be about 3.125 inches long.  
' This translates to about 147 vp units.  Therefore, the flipper start radius + the flipper length + the flipper end 
' radius should  equal approximately 147 vp units. Another common mistake is is that sometimes the right flipper
' angle was set with a large postive value (like 238 or something). It should be using negative value (like -122).
'
' The following settings are a solid starting point for various eras of pinballs.
' |                    | EM's           | late 70's to mid 80's | mid 80's to early 90's | mid 90's and later |
' | ------------------ | -------------- | --------------------- | ---------------------- | ------------------ |
' | Mass               | 1              | 1                     | 1                      | 1                  |
' | Strength           | 500-1000 (750) | 1400-1600 (1500)      | 2000-2600              | 3200-3300 (3250)   |
' | Elasticity         | 0.88           | 0.88                  | 0.88                   | 0.88               |
' | Elasticity Falloff | 0.15           | 0.15                  | 0.15                   | 0.15               |
' | Fricition          | 0.8-0.9        | 0.9                   | 0.9                    | 0.9                |
' | Return Strength    | 0.11           | 0.09                  | 0.07                   | 0.055              |
' | Coil Ramp Up       | 2.5            | 2.5                   | 2.5                    | 2.5                |
' | Scatter Angle      | 0              | 0                     | 0                      | 0                  |
' | EOS Torque         | 0.3            | 0.3                   | 0.275                  | 0.275              |
' | EOS Torque Angle   | 4              | 4                     | 6                      | 6                  |
'


'******************************************************
' Flippers Polarity (Select appropriate sub based on era) 
'******************************************************

dim LF : Set LF = New FlipperPolarity
dim RF : Set RF = New FlipperPolarity

InitPolarity

'
''*******************************************
'' Late 70's to early 80's
'
'Sub InitPolarity()
'       dim x, a : a = Array(LF, RF)
'       for each x in a
'                x.AddPoint "Ycoef", 0, RightFlipper.Y-65, 1        'disabled
'                x.AddPoint "Ycoef", 1, RightFlipper.Y-11, 1
'                x.enabled = True
'                x.TimeDelay = 80
'        Next
'
'        AddPt "Polarity", 0, 0, 0
'        AddPt "Polarity", 1, 0.05, -2.7        
'        AddPt "Polarity", 2, 0.33, -2.7
'        AddPt "Polarity", 3, 0.37, -2.7        
'        AddPt "Polarity", 4, 0.41, -2.7
'        AddPt "Polarity", 5, 0.45, -2.7
'        AddPt "Polarity", 6, 0.576,-2.7
'        AddPt "Polarity", 7, 0.66, -1.8
'        AddPt "Polarity", 8, 0.743, -0.5
'        AddPt "Polarity", 9, 0.81, -0.5
'        AddPt "Polarity", 10, 0.88, 0
'
'        addpt "Velocity", 0, 0,         1
'        addpt "Velocity", 1, 0.16, 1.06
'        addpt "Velocity", 2, 0.41,         1.05
'        addpt "Velocity", 3, 0.53,         1'0.982
'        addpt "Velocity", 4, 0.702, 0.968
'        addpt "Velocity", 5, 0.95,  0.968
'        addpt "Velocity", 6, 1.03,         0.945
'
'        LF.Object = LeftFlipper        
'        LF.EndPoint = EndPointLp
'        RF.Object = RightFlipper
'        RF.EndPoint = EndPointRp
'End Sub
'
'
'
''*******************************************
'' Mid 80's
'
'Sub InitPolarity()
'        dim x, a : a = Array(LF, RF)
'        for each x in a
'                x.AddPoint "Ycoef", 0, RightFlipper.Y-65, 1        'disabled
'                x.AddPoint "Ycoef", 1, RightFlipper.Y-11, 1
'                x.enabled = True
'                x.TimeDelay = 80
'        Next
'
'        AddPt "Polarity", 0, 0, 0
'        AddPt "Polarity", 1, 0.05, -3.7        
'        AddPt "Polarity", 2, 0.33, -3.7
'        AddPt "Polarity", 3, 0.37, -3.7
'        AddPt "Polarity", 4, 0.41, -3.7
'        AddPt "Polarity", 5, 0.45, -3.7 
'        AddPt "Polarity", 6, 0.576,-3.7
'        AddPt "Polarity", 7, 0.66, -2.3
'        AddPt "Polarity", 8, 0.743, -1.5
'        AddPt "Polarity", 9, 0.81, -1
'        AddPt "Polarity", 10, 0.88, 0
'
'        addpt "Velocity", 0, 0,         1
'        addpt "Velocity", 1, 0.16, 1.06
'        addpt "Velocity", 2, 0.41,         1.05
'        addpt "Velocity", 3, 0.53,         1'0.982
'        addpt "Velocity", 4, 0.702, 0.968
'        addpt "Velocity", 5, 0.95,  0.968
'        addpt "Velocity", 6, 1.03,         0.945
'
'        LF.Object = LeftFlipper        
'        LF.EndPoint = EndPointLp
'        RF.Object = RightFlipper
'        RF.EndPoint = EndPointRp
'End Sub
'
'


'*******************************************
'  Late 80's early 90's

'Sub InitPolarity()
'	dim x, a : a = Array(LF, RF)
'	for each x in a
'		x.AddPoint "Ycoef", 0, RightFlipper.Y-65, 1        'disabled
'		x.AddPoint "Ycoef", 1, RightFlipper.Y-11, 1
'		x.enabled = True
'		x.TimeDelay = 60
'	Next
'
'	AddPt "Polarity", 0, 0, 0
'	AddPt "Polarity", 1, 0.05, -5
'	AddPt "Polarity", 2, 0.4, -5
'	AddPt "Polarity", 3, 0.6, -4.5
'	AddPt "Polarity", 4, 0.65, -4.0
'	AddPt "Polarity", 5, 0.7, -3.5
'	AddPt "Polarity", 6, 0.75, -3.0
'	AddPt "Polarity", 7, 0.8, -2.5
'	AddPt "Polarity", 8, 0.85, -2.0
'	AddPt "Polarity", 9, 0.9,-1.5
'	AddPt "Polarity", 10, 0.95, -1.0
'	AddPt "Polarity", 11, 1, -0.5
'	AddPt "Polarity", 12, 1.1, 0
'	AddPt "Polarity", 13, 1.3, 0
'
'	addpt "Velocity", 0, 0,         1
'	addpt "Velocity", 1, 0.16, 1.06
'	addpt "Velocity", 2, 0.41,         1.05
'	addpt "Velocity", 3, 0.53,         1'0.982
'	addpt "Velocity", 4, 0.702, 0.968
'	addpt "Velocity", 5, 0.95,  0.968
'	addpt "Velocity", 6, 1.03,         0.945
'
'	LF.Object = LeftFlipper        
'	LF.EndPoint = EndPointLp
'	RF.Object = RightFlipper
'	RF.EndPoint = EndPointRp
'End Sub



'
''*******************************************
'' Early 90's and after
'
Sub InitPolarity()
	dim x, a : a = Array(LF, RF)
	for each x in a
		x.AddPt "Ycoef", 0, RightFlipper.Y-65, 1 'disabled
		x.AddPt "Ycoef", 1, RightFlipper.Y-11, 1
		x.enabled = True
		x.TimeDelay = 60
		x.DebugOn=False ' prints some info in debugger

		x.AddPt "Polarity", 0, 0, 0
		x.AddPt "Polarity", 1, 0.05, -5.5
		x.AddPt "Polarity", 2, 0.4, -5.5
		x.AddPt "Polarity", 3, 0.6, -5.0
		x.AddPt "Polarity", 4, 0.65, -4.5
		x.AddPt "Polarity", 5, 0.7, -4.0
		x.AddPt "Polarity", 6, 0.75, -3.5
		x.AddPt "Polarity", 7, 0.8, -3.0
		x.AddPt "Polarity", 8, 0.85, -2.5
		x.AddPt "Polarity", 9, 0.9,-2.0
		x.AddPt "Polarity", 10, 0.95, -1.5
		x.AddPt "Polarity", 11, 1, -1.0
		x.AddPt "Polarity", 12, 1.05, -0.5
		x.AddPt "Polarity", 13, 1.1, 0
		x.AddPt "Polarity", 14, 1.3, 0

		x.AddPt "Velocity", 0, 0,	   1
		x.AddPt "Velocity", 1, 0.160, 1.06
		x.AddPt "Velocity", 2, 0.410, 1.05
		x.AddPt "Velocity", 3, 0.530, 1'0.982
		x.AddPt "Velocity", 4, 0.702, 0.968
		x.AddPt "Velocity", 5, 0.95,  0.968
		x.AddPt "Velocity", 6, 1.03,  0.945
	Next

	' SetObjects arguments: 1: name of object 2: flipper object: 3: Trigger object around flipper
	LF.SetObjects "LF", LeftFlipper, TriggerLF 
	RF.SetObjects "RF", RightFlipper, TriggerRF 
End Sub


' Flipper trigger hit subs
'Sub TriggerLF_Hit() : LF.Addball activeball : End Sub
'Sub TriggerLF_UnHit() : LF.PolarityCorrect activeball : End Sub
'Sub TriggerRF_Hit() : RF.Addball activeball : End Sub
'Sub TriggerRF_UnHit() : RF.PolarityCorrect activeball : End Sub


'******************************************************
'  FLIPPER CORRECTION FUNCTIONS
'******************************************************

' modified 2023 by nFozzy
' Removed need for 'endpoint' objects
' Added 'createvents' type thing for TriggerLF / TriggerRF triggers. 
' Removed AddPt function which complicated setup imo
' made DebugOn do something (prints some stuff in debugger) 
'   Otherwise it should function exactly the same as before
 
Class FlipperPolarity 
	Public DebugOn, Enabled
	Private FlipAt		'Timer variable (IE 'flip at 723,530ms...)
	Public TimeDelay		'delay before trigger turns off and polarity is disabled
	private Flipper, FlipperStart, FlipperEnd, FlipperEndY, LR, PartialFlipCoef
	Private Balls(20), balldata(20)
	private Name
 
	dim PolarityIn, PolarityOut
	dim VelocityIn, VelocityOut
	dim YcoefIn, YcoefOut
	Public Sub Class_Initialize 
		redim PolarityIn(0) : redim PolarityOut(0) : redim VelocityIn(0) : redim VelocityOut(0) : redim YcoefIn(0) : redim YcoefOut(0)
		Enabled = True : TimeDelay = 50 : LR = 1:  dim x : for x = 0 to uBound(balls) : balls(x) = Empty : set Balldata(x) = new SpoofBall : next 
	End Sub
 
	Public Sub SetObjects(aName, aFlipper, aTrigger) 
 
		if typename(aName) <> "String" then msgbox "FlipperPolarity: .SetObjects error: first argument must be a string (and name of Object). Found:" & typename(aName) end if
		if typename(aFlipper) <> "Flipper" then msgbox "FlipperPolarity: .SetObjects error: second argument must be a flipper. Found:" & typename(aFlipper) end if
		if typename(aTrigger) <> "Trigger" then msgbox "FlipperPolarity: .SetObjects error: third argument must be a trigger. Found:" & typename(aTrigger) end if
		if aFlipper.EndAngle > aFlipper.StartAngle then LR = -1 Else LR = 1 End If
		Name = aName
		Set Flipper = aFlipper : FlipperStart = aFlipper.x 
		FlipperEnd = Flipper.Length * sin((Flipper.StartAngle / 57.295779513082320876798154814105)) + Flipper.X ' big floats for degree to rad conversion
		FlipperEndY = Flipper.Length * cos(Flipper.StartAngle / 57.295779513082320876798154814105)*-1 + Flipper.Y
 
		dim str : str = "sub " & aTrigger.name & "_Hit() : " & aName & ".AddBall ActiveBall : End Sub'"
		ExecuteGlobal(str)
		str = "sub " & aTrigger.name & "_UnHit() : " & aName & ".PolarityCorrect ActiveBall : End Sub'"
		ExecuteGlobal(str)  
 
	End Sub
 
	Public Property Let EndPoint(aInput) :  : End Property ' Legacy: just no op 
 
	Public Sub AddPt(aChooseArray, aIDX, aX, aY) 'Index #, X position, (in) y Position (out) 
		Select Case aChooseArray
			case "Polarity" : ShuffleArrays PolarityIn, PolarityOut, 1 : PolarityIn(aIDX) = aX : PolarityOut(aIDX) = aY : ShuffleArrays PolarityIn, PolarityOut, 0
			Case "Velocity" : ShuffleArrays VelocityIn, VelocityOut, 1 :VelocityIn(aIDX) = aX : VelocityOut(aIDX) = aY : ShuffleArrays VelocityIn, VelocityOut, 0
			Case "Ycoef" : ShuffleArrays YcoefIn, YcoefOut, 1 :YcoefIn(aIDX) = aX : YcoefOut(aIDX) = aY : ShuffleArrays YcoefIn, YcoefOut, 0
		End Select
	End Sub 
 
	Public Sub AddBall(aBall) : dim x : for x = 0 to uBound(balls) : if IsEmpty(balls(x)) then set balls(x) = aBall : exit sub :end if : Next  : End Sub
 
	Private Sub RemoveBall(aBall)
		dim x : for x = 0 to uBound(balls)
			if TypeName(balls(x) ) = "IBall" then 
				if aBall.ID = Balls(x).ID Then
					balls(x) = Empty
					Balldata(x).Reset
				End If
			End If
		Next
	End Sub
 
	Public Sub Fire() 
		Flipper.RotateToEnd
		processballs
	End Sub
 
	Public Property Get Pos 'returns % position a ball. For debug stuff.
		dim x : for x = 0 to uBound(balls)
			if not IsEmpty(balls(x) ) then
				pos = pSlope(Balls(x).x, FlipperStart, 0, FlipperEnd, 1)
			End If
		Next				
	End Property
 
	Public Sub ProcessBalls() 'save data of balls in flipper range
		FlipAt = GameTime
		dim x : for x = 0 to uBound(balls)
			if not IsEmpty(balls(x) ) then
				balldata(x).Data = balls(x)
			End If
		Next
		PartialFlipCoef = ((Flipper.StartAngle - Flipper.CurrentAngle) / (Flipper.StartAngle - Flipper.EndAngle))
		PartialFlipCoef = abs(PartialFlipCoef-1)
	End Sub
	Private Function FlipperOn() : if gameTime < FlipAt+TimeDelay then FlipperOn = True : End If : End Function		'Timer shutoff for polaritycorrect
 
	Public Sub PolarityCorrect(aBall)
		if FlipperOn() then 
			dim tmp, BallPos, x, IDX, Ycoef : Ycoef = 1
 
			'y safety Exit
			if aBall.VelY > -8 then 'ball going down
				RemoveBall aBall
				exit Sub
			end if
 
			'Find balldata. BallPos = % on Flipper
			for x = 0 to uBound(Balls)
				if aBall.id = BallData(x).id AND not isempty(BallData(x).id) then 
					idx = x
					BallPos = PSlope(BallData(x).x, FlipperStart, 0, FlipperEnd, 1)
					if ballpos > 0.65 then  Ycoef = LinearEnvelope(BallData(x).Y, YcoefIn, YcoefOut)								'find safety coefficient 'ycoef' data
				end if
			Next
 
			If BallPos = 0 Then 'no ball data meaning the ball is entering and exiting pretty close to the same position, use current values.
				BallPos = PSlope(aBall.x, FlipperStart, 0, FlipperEnd, 1)
				if ballpos > 0.65 then  Ycoef = LinearEnvelope(aBall.Y, YcoefIn, YcoefOut)												'find safety coefficient 'ycoef' data
			End If
 
			'Velocity correction
			if not IsEmpty(VelocityIn(0) ) then
				Dim VelCoef
				VelCoef = LinearEnvelope(BallPos, VelocityIn, VelocityOut)
 
				if partialflipcoef < 1 then VelCoef = PSlope(partialflipcoef, 0, 1, 1, VelCoef)
 
				if Enabled then aBall.Velx = aBall.Velx*VelCoef
				if Enabled then aBall.Vely = aBall.Vely*VelCoef
			End If
 
			'Polarity Correction (optional now)
			if not IsEmpty(PolarityIn(0) ) then
				dim AddX : AddX = LinearEnvelope(BallPos, PolarityIn, PolarityOut) * LR
 
				if Enabled then aBall.VelX = aBall.VelX + 1 * (AddX*ycoef*PartialFlipcoef)
			End If
			if DebugOn then debug.print "PolarityCorrect" & " " & Name & " @ " & gametime & " " & Round(BallPos*100) & "%" & " AddX:" & Round(AddX,2) & " Vel%:" & Round(VelCoef*100)
		End If
		RemoveBall aBall
	End Sub
End Class


'******************************************************
'  FLIPPER POLARITY AND RUBBER DAMPENER SUPPORTING FUNCTIONS 
'******************************************************

' Used for flipper correction and rubber dampeners
Sub ShuffleArray(ByRef aArray, byVal offset) 'shuffle 1d array
	dim x, aCount : aCount = 0
	redim a(uBound(aArray) )
	for x = 0 to uBound(aArray)        'Shuffle objects in a temp array
		if not IsEmpty(aArray(x) ) Then
			if IsObject(aArray(x)) then 
				Set a(aCount) = aArray(x)
			Else
				a(aCount) = aArray(x)
			End If
			aCount = aCount + 1
		End If
	Next
	if offset < 0 then offset = 0
	redim aArray(aCount-1+offset)        'Resize original array
	for x = 0 to aCount-1                'set objects back into original array
		if IsObject(a(x)) then 
			Set aArray(x) = a(x)
		Else
			aArray(x) = a(x)
		End If
	Next
End Sub

' Used for flipper correction and rubber dampeners
Sub ShuffleArrays(aArray1, aArray2, offset)
	ShuffleArray aArray1, offset
	ShuffleArray aArray2, offset
End Sub

' Used for flipper correction, rubber dampeners, and drop targets
'Function BallSpeed(ball) 'Calculates the ball speed
'	BallSpeed = SQR(ball.VelX^2 + ball.VelY^2 + ball.VelZ^2)
'End Function

' Used for flipper correction and rubber dampeners
Function PSlope(Input, X1, Y1, X2, Y2)        'Set up line via two points, no clamping. Input X, output Y
	dim x, y, b, m : x = input : m = (Y2 - Y1) / (X2 - X1) : b = Y2 - m*X2
	Y = M*x+b
	PSlope = Y
End Function

' Used for flipper correction
Class spoofball 
	Public X, Y, Z, VelX, VelY, VelZ, ID, Mass, Radius 
	Public Property Let Data(aBall)
		With aBall
			x = .x : y = .y : z = .z : velx = .velx : vely = .vely : velz = .velz
			id = .ID : mass = .mass : radius = .radius
		end with
	End Property
	Public Sub Reset()
		x = Empty : y = Empty : z = Empty  : velx = Empty : vely = Empty : velz = Empty 
		id = Empty : mass = Empty : radius = Empty
	End Sub
End Class

' Used for flipper correction and rubber dampeners
Function LinearEnvelope(xInput, xKeyFrame, yLvl)
	dim y 'Y output
	dim L 'Line
	dim ii : for ii = 1 to uBound(xKeyFrame)        'find active line
		if xInput <= xKeyFrame(ii) then L = ii : exit for : end if
	Next
	if xInput > xKeyFrame(uBound(xKeyFrame) ) then L = uBound(xKeyFrame)        'catch line overrun
	Y = pSlope(xInput, xKeyFrame(L-1), yLvl(L-1), xKeyFrame(L), yLvl(L) )

	if xInput <= xKeyFrame(lBound(xKeyFrame) ) then Y = yLvl(lBound(xKeyFrame) )         'Clamp lower
	if xInput >= xKeyFrame(uBound(xKeyFrame) ) then Y = yLvl(uBound(xKeyFrame) )        'Clamp upper

	LinearEnvelope = Y
End Function


'******************************************************
'  FLIPPER TRICKS 
'******************************************************

RightFlipper.timerinterval=1
Rightflipper.timerenabled=True

sub RightFlipper_timer()
	FlipperTricks LeftFlipper, LFPress, LFCount, LFEndAngle, LFState
	FlipperTricks RightFlipper, RFPress, RFCount, RFEndAngle, RFState
	FlipperNudge RightFlipper, RFEndAngle, RFEOSNudge, LeftFlipper, LFEndAngle
	FlipperNudge LeftFlipper, LFEndAngle, LFEOSNudge,  RightFlipper, RFEndAngle
end sub

Dim LFEOSNudge, RFEOSNudge

Sub FlipperNudge(Flipper1, Endangle1, EOSNudge1, Flipper2, EndAngle2)
	Dim b, BOT
	BOT = GetBalls

	If Flipper1.currentangle = Endangle1 and EOSNudge1 <> 1 Then
		EOSNudge1 = 1
		'debug.print Flipper1.currentangle &" = "& Endangle1 &"--"& Flipper2.currentangle &" = "& EndAngle2
		If Flipper2.currentangle = EndAngle2 Then 
			For b = 0 to Ubound(BOT)
				If FlipperTrigger(BOT(b).x, BOT(b).y, Flipper1) Then
					'Debug.Print "ball in flip1. exit"
					exit Sub
				end If
			Next
			For b = 0 to Ubound(BOT)
				If FlipperTrigger(BOT(b).x, BOT(b).y, Flipper2) Then
					BOT(b).velx = BOT(b).velx / 1.3
					BOT(b).vely = BOT(b).vely - 0.5
				end If
			Next
		End If
	Else 
		If Abs(Flipper1.currentangle) > Abs(EndAngle1) + 30 then EOSNudge1 = 0
	End If
End Sub

'*****************
' Maths
'*****************
Dim PI: PI = 4*Atn(1)

Function dSin(degrees)
	dsin = sin(degrees * Pi/180)
End Function

Function dCos(degrees)
	dcos = cos(degrees * Pi/180)
End Function

Function Atn2(dy, dx)
	If dx > 0 Then
		Atn2 = Atn(dy / dx)
	ElseIf dx < 0 Then
		If dy = 0 Then 
			Atn2 = pi
		Else
			Atn2 = Sgn(dy) * (pi - Atn(Abs(dy / dx)))
		end if
	ElseIf dx = 0 Then
		if dy = 0 Then
			Atn2 = 0
		else
			Atn2 = Sgn(dy) * pi / 2
		end if
	End If
End Function

Function dAtn(degrees)
	dAtn = atn(degrees * Pi/180)
End Function

'*************************************************
' Check ball distance from Flipper for Rem
'*************************************************

Function Distance(ax,ay,bx,by)
	Distance = SQR((ax - bx)^2 + (ay - by)^2)
End Function

Function DistancePL(px,py,ax,ay,bx,by) ' Distance between a point and a line where point is px,py
	DistancePL = ABS((by - ay)*px - (bx - ax) * py + bx*ay - by*ax)/Distance(ax,ay,bx,by)
End Function

Function Radians(Degrees)
	Radians = Degrees * PI /180
End Function

Function AnglePP(ax,ay,bx,by)
	AnglePP = Atn2((by - ay),(bx - ax))*180/PI
End Function

Function DistanceFromFlipper(ballx, bally, Flipper)
	DistanceFromFlipper = DistancePL(ballx, bally, Flipper.x, Flipper.y, Cos(Radians(Flipper.currentangle+90))+Flipper.x, Sin(Radians(Flipper.currentangle+90))+Flipper.y)
End Function

Function FlipperTrigger(ballx, bally, Flipper)
	Dim DiffAngle
	DiffAngle  = ABS(Flipper.currentangle - AnglePP(Flipper.x, Flipper.y, ballx, bally) - 90)
	If DiffAngle > 180 Then DiffAngle = DiffAngle - 360

	If DistanceFromFlipper(ballx,bally,Flipper) < 48 and DiffAngle <= 90 and Distance(ballx,bally,Flipper.x,Flipper.y) < Flipper.Length Then
		FlipperTrigger = True
	Else
		FlipperTrigger = False
	End If        
End Function


'*************************************************
'  End - Check ball distance from Flipper for Rem
'*************************************************

dim LFPress, RFPress, LFCount, RFCount
dim LFState, RFState
dim EOST, EOSA,Frampup, FElasticity,FReturn
dim RFEndAngle, LFEndAngle

Const FlipperCoilRampupMode = 0   	'0 = fast, 1 = medium, 2 = slow (tap passes should work)

LFState = 1
RFState = 1
EOST = leftflipper.eostorque
EOSA = leftflipper.eostorqueangle
Frampup = LeftFlipper.rampup
FElasticity = LeftFlipper.elasticity
FReturn = LeftFlipper.return
'Const EOSTnew = 1 'EM's to late 80's
Const EOSTnew = 0.8 '90's and later
Const EOSAnew = 1
Const EOSRampup = 0
Dim SOSRampup
Select Case FlipperCoilRampupMode 
	Case 0:
		SOSRampup = 2.5
	Case 1:
		SOSRampup = 6
	Case 2:
		SOSRampup = 8.5
End Select

Const LiveCatch = 16
Const LiveElasticity = 0.45
Const SOSEM = 0.815
'Const EOSReturn = 0.055  'EM's
'Const EOSReturn = 0.045  'late 70's to mid 80's
Const EOSReturn = 0.035  'mid 80's to early 90's
'Const EOSReturn = 0.025  'mid 90's and later

LFEndAngle = Leftflipper.endangle
RFEndAngle = RightFlipper.endangle

Sub FlipperActivate(Flipper, FlipperPress)
	FlipperPress = 1
	Flipper.Elasticity = FElasticity

	Flipper.eostorque = EOST         
	Flipper.eostorqueangle = EOSA         
End Sub

Sub FlipperDeactivate(Flipper, FlipperPress)
	FlipperPress = 0
	Flipper.eostorqueangle = EOSA
	Flipper.eostorque = EOST*EOSReturn/FReturn


	If Abs(Flipper.currentangle) <= Abs(Flipper.endangle) + 0.1 Then
		Dim b, BOT
		BOT = GetBalls

		For b = 0 to UBound(BOT)
			If Distance(BOT(b).x, BOT(b).y, Flipper.x, Flipper.y) < 55 Then 'check for cradle
				If BOT(b).vely >= -0.4 Then BOT(b).vely = -0.4
			End If
		Next
	End If
End Sub

Sub FlipperTricks (Flipper, FlipperPress, FCount, FEndAngle, FState) 
	Dim Dir
	Dir = Flipper.startangle/Abs(Flipper.startangle)        '-1 for Right Flipper

	If Abs(Flipper.currentangle) > Abs(Flipper.startangle) - 0.05 Then
		If FState <> 1 Then
			Flipper.rampup = SOSRampup 
			Flipper.endangle = FEndAngle - 3*Dir
			Flipper.Elasticity = FElasticity * SOSEM
			FCount = 0 
			FState = 1
		End If
	ElseIf Abs(Flipper.currentangle) <= Abs(Flipper.endangle) and FlipperPress = 1 then
		if FCount = 0 Then FCount = GameTime

		If FState <> 2 Then
			Flipper.eostorqueangle = EOSAnew
			Flipper.eostorque = EOSTnew
			Flipper.rampup = EOSRampup                        
			Flipper.endangle = FEndAngle
			FState = 2
		End If
	Elseif Abs(Flipper.currentangle) > Abs(Flipper.endangle) + 0.01 and FlipperPress = 1 Then 
		If FState <> 3 Then
			Flipper.eostorque = EOST        
			Flipper.eostorqueangle = EOSA
			Flipper.rampup = Frampup
			Flipper.Elasticity = FElasticity
			FState = 3
		End If

	End If
End Sub

Const LiveDistanceMin = 30  'minimum distance in vp units from flipper base live catch dampening will occur
Const LiveDistanceMax = 114  'maximum distance in vp units from flipper base live catch dampening will occur (tip protection)

Sub CheckLiveCatch(ball, Flipper, FCount, parm) 'Experimental new live catch
	Dim Dir
	Dir = Flipper.startangle/Abs(Flipper.startangle)    '-1 for Right Flipper
	Dim LiveCatchBounce                                                                                                                        'If live catch is not perfect, it won't freeze ball totally
	Dim CatchTime : CatchTime = GameTime - FCount

	if CatchTime <= LiveCatch and parm > 6 and ABS(Flipper.x - ball.x) > LiveDistanceMin and ABS(Flipper.x - ball.x) < LiveDistanceMax Then
		if CatchTime <= LiveCatch*0.5 Then                                                'Perfect catch only when catch time happens in the beginning of the window
			LiveCatchBounce = 0
		else
			LiveCatchBounce = Abs((LiveCatch/2) - CatchTime)        'Partial catch when catch happens a bit late
		end If

		If LiveCatchBounce = 0 and ball.velx * Dir > 0 Then ball.velx = 0
		ball.vely = LiveCatchBounce * (32 / LiveCatch) ' Multiplier for inaccuracy bounce
		ball.angmomx= 0
		ball.angmomy= 0
		ball.angmomz= 0
    Else
        If Abs(Flipper.currentangle) <= Abs(Flipper.endangle) + 1 Then FlippersD.Dampenf Activeball, parm
	End If
End Sub


'******************************************************
'****  END FLIPPER CORRECTIONS
'******************************************************


'******************************************************
'   Drop Target Controls
'******************************************************

Sub sw36_hit
	DTHit 36
End Sub

Sub sw35_hit
	DTHit 35
End Sub

Sub sw25_hit
	DTHit 25
End Sub

Sub sw34_hit
	DTHit 34
End Sub

Sub sw24_hit
	DTHit 24
End Sub

Sub sw33_hit
	DTHit 33
End Sub

Sub sw23_hit
	DTHit 23
End Sub

Sub sw26_hit
	DTHit 26
End Sub

Sub sw32_hit
	DTHit 32
End Sub

Sub sw22_hit
	DTHit 22
End Sub

Sub sw31_hit
	DTHit 31
End Sub

Sub sw21_hit
	DTHit 21
End Sub

Sub sw30_hit
	DTHit 30
End Sub

Sub sw20_hit
	DTHit 20
End Sub

'********************************************
'  Stand Up Targets
'********************************************

Sub sw16o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw111o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw113o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw115o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw114o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw1140o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw93o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw930o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw94o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw95o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw950o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw960o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw97o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw970o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw112o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw1120o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw116o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw1160o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw117o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw1170o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw103o_Hit
	TargetBouncer Activeball, 1
End Sub

Sub sw1030o_Hit
	TargetBouncer Activeball, 1
End Sub



Sub sw16_Hit: STHit 16 :vpmTimer.PulseSw 16 : End Sub
Sub sw93_Hit: STHit 93 :vpmTimer.PulseSw 93:End Sub
Sub sw930_Hit: STHit 930 :vpmTimer.PulseSw 93:End Sub
Sub sw94_Hit: STHit 94 :vpmTimer.PulseSw 94:End Sub
Sub sw95_Hit: STHit 95 :vpmTimer.PulseSw 95:End Sub
Sub sw950_Hit: STHit 950 :vpmTimer.PulseSw 95:End Sub
Sub sw96_Hit: STHit 9 :vpmTimer.PulseSw 96:End Sub
Sub sw97_Hit: STHit 97 :vpmTimer.PulseSw 97:End Sub
Sub sw970_Hit: STHit 970 :vpmTimer.PulseSw 97:End Sub
Sub sw103_Hit: STHit 103 :vpmTimer.PulseSw 103:End Sub
Sub sw1030_Hit: STHit 1030 :vpmTimer.PulseSw 103:End Sub
Sub sw111_Hit: STHit 111 :vpmTimer.PulseSw 111:End Sub
Sub sw112_Hit: STHit 112 :vpmTimer.PulseSw 112:End Sub
Sub sw1120_Hit: STHit 1120 :vpmTimer.PulseSw 112:End Sub
Sub sw113_Hit: STHit 113 :vpmTimer.PulseSw 113:End Sub
Sub sw115_Hit: STHit 115 :vpmTimer.PulseSw 115:End Sub
Sub sw116_Hit: STHit 116 :vpmTimer.PulseSw 116:End Sub
Sub sw1160_Hit: STHit 1160 :vpmTimer.PulseSw 116:End Sub
Sub sw114_Hit: STHit 114 :vpmTimer.PulseSw 114:End Sub
Sub sw1140_Hit: STHit 1140 :vpmTimer.PulseSw 114:End Sub
Sub sw117_Hit: STHit 117 :vpmTimer.PulseSw 117:End Sub
Sub sw1170_Hit: STHit 1170 :vpmTimer.PulseSw 117:End Sub

'*******************************************
'	 Drain, Trough, and Ball Release
'*******************************************

' Drain & Holes
Sub Drain_Hit:bsTrough.addball me : RandomSoundDrain drain : End Sub
Sub BallRelease_UnHit : RandomSoundBallRelease BallRelease : End Sub


Sub sw17_Hit:bsBSaucer.AddBall 0 : SoundSaucerLock : End Sub
Sub sw17_UnHit : SoundSaucerKick 1, sw17 : End Sub
Sub sw27_Hit:bsLSaucer.AddBall 0 : SoundSaucerLock: End Sub
Sub sw27_UnHit : SoundSaucerKick 1, sw27 : End Sub
Sub sw37_Hit:bsRSaucer.AddBall 0 : SoundSaucerLock: End Sub
Sub sw37_UnHit : SoundSaucerKick 1, sw37 : End Sub

'wire triggers
Sub sw7_Hit:Controller.Switch(7) = 1 : End Sub
Sub sw7_UnHit:Controller.Switch(7) = 0:End Sub
Sub sw91_Hit:Controller.Switch(91) = 1 : End Sub
Sub sw91_UnHit:Controller.Switch(91) = 0:End Sub
Sub sw92_Hit:Controller.Switch(92) = 1 : End Sub
Sub sw92_UnHit:Controller.Switch(92) = 0:End Sub
Sub sw101_Hit:Controller.Switch(101) = 1 : End Sub
Sub sw101_UnHit:Controller.Switch(101) = 0:End Sub
Sub sw102_Hit:Controller.Switch(102) = 1 : End Sub
Sub sw102_UnHit:Controller.Switch(102) = 0:End Sub

'Scoring Rubbers
Sub sw12_Slingshot:vpmTimer.PulseSw 12 : RandomSoundSlingshotupLeft()  : End Sub
Sub sw13_SlingShot:vpmTimer.PulseSw 13 : RandomSoundSlingshotupRight() : End Sub

' Bumpers
Sub Bumper1_Hit:vpmTimer.PulseSw 10 : RandomSoundBumperTop bumper1: End Sub
Sub Bumper2_Hit:vpmTimer.PulseSw 11 : RandomSoundBumperMiddle bumper2: End Sub


'Ramp Triggers
'Sub sw80_Hit:Controller.Switch(80) = 1:PlaySoundAtVol "Wire Ramp", ActiveBall, 1:End Sub
'Sub sw80_UnHit:Controller.Switch(80) = 0:End Sub
Sub sw90_Hit:Controller.Switch(90) = 1:End Sub
Sub sw90_UnHit:Controller.Switch(90) = 0:End Sub

' Opto Sensors
Sub sw100_Hit:Controller.Switch(100) = 1:End Sub
Sub sw100_UnHit:Controller.Switch(100) = 0:End Sub
Sub sw110_Hit:Controller.Switch(110) = 1:End Sub
Sub sw110_UnHit:Controller.Switch(110) = 0:End Sub


'******************************************************
'  Ramp Triggers
'******************************************************

Sub ramptrigger01_hit()
	WireRampOn True 'Play Plastic Ramp Sound
End Sub

Sub ramptrigger001_hit()
	WireRampOn True 'Play Plastic Ramp Sound
End Sub

Sub sw80_hit()
	WireRampOff ' Turn off the Plastic Ramp Sound
Controller.Switch(80) = 1
End Sub

Sub sw80_unhit()
	WireRampOn False ' On Wire Ramp Play Wire Ramp Sound
Controller.Switch(80) = 0
End Sub

Sub Trigger1_hit()
	WireRampOff ' Exiting Wire Ramp Stop Playing Sound
End Sub

Sub Trigger1_unhit()
	PlaySoundAt "WireRamp_Stop", Trigger1
End Sub


 ' **************
 '   White Ball
 ' **************
Dim WBall

Sub CreateWhiteBall()
  Set WBall = kicker9.Createsizedball(55):WBall.Image = "CBallW":kicker9.Kick 0, 0
  WBall.X = 464
  WBall.Y = 1022
  WBall.Mass = 5
  WBall.BulbIntensityScale = 0.5
End Sub

Sub kicker9_UnHit()
  NewBallid
End Sub

Sub CaptiveHelp1_Hit
  If ActiveBall is WBall Then
    With ActiveBall
      .VelX = -.VelX / 3: .VelY = -.VelY / 3
    End With
    sw103_Hit
  End If
End Sub

Sub CaptiveHelp2_Hit
  If ActiveBall is WBall Then
    With ActiveBall
      .VelX = -.VelX / 3: .VelY = -.VelY / 3
    End With
    sw1030_Hit
  End If
End Sub

 ' **************
 '   Black Ball
 ' **************
Dim Bball

Sub CreateBlackBall()
  Set BBall = kicker10.Createsizedball(55)
  BBall.Image = "CBallB"
  BBall.FrontDecal = "Decal 8"
  BBall.Mass = 5
  BBall.BulbIntensityScale = 0.1
  kicker10.Kick 0, 0
End Sub

 '************************
 ' 8 Ball Platform Update
 '************************

 ' Init 8 Ball Shooter Platform

Dim ShooterPos, BallInShooter

' ShooterWalls1 = Array(pl11, pl21, pl31, pl41, pl51, pl61, pl71, pl81, pl91, pl91) 'Oberteil
' ShooterWalls2 = Array(pl12, pl22, pl32, pl42, pl52, pl62, pl72, pl82, pl92, pl92) 'Cue
' ShooterWalls3 = Array(pl13, pl23, pl33, pl43, pl53, pl63, pl73, pl83, pl93, pl93) 'Oberteil vorne?
'
' vpmSolWall ShooterWalls1, 0, 1
' vpmSolWall ShooterWalls2, 0, 1
' vpmSolWall ShooterWalls3, 0, 1

Sub UpdateShooter(aNewPos, aSpeed, aLastPos)
' Rotate.Enabled = 1
' ShooterWalls1(aLastPos).IsDropped = 1
' ShooterWalls2(aLastPos).IsDropped = 1
' ShooterWalls3(aLastPos).IsDropped = 1
' ShooterWalls1(aNewPos).IsDropped = 0
' ShooterWalls2(aNewPos).IsDropped = 0
' ShooterWalls3(aNewPos).IsDropped = 0
' ShooterPos = aNewPos
' CheckBallInShooter
End Sub

Sub SolShoot8Ball(Enabled)
  If Enabled AND BallInShooter Then
    Primitive004.collidable = 0
    Recollidable.Enabled = 1
    BBall.VelX = RotPos * (0.75)
    playsoundAtVol SoundFX("Popper",DOFContactors), Primitive004, 1
    BBall.VelY = 100
    ' Rotate.Enabled = 0
  End If
End Sub

Dim UARC
UARC = 0

Sub Recollidable_Timer(Enabled)
  If UARC = 0 Then
    UARC = UARC + 1
  Else
    Primitive004.collidable = 1
    UARC = 0
    Recollidable.enabled = 0
  End If
End Sub

Sub SwShooter_Hit:BallInShooter = 1:End Sub
Sub SwShooter_UnHit:BallInShooter = 0:End Sub

'************************************************************************************************
'Rotate Cue Unit (Vogliadicane)
'************************************************************************************************

Dim RotMin, RotMax, RotDelta, RotDir, RotPos

RotMin = -15
RotMax = 15
RotDelta = 0.2
RotDir = -1
RotPos = 0

Sub Rotate_Timer()

  RotPos = RotPos + (RotDir * RotDelta)
  Primitive004.RotZ = RotPos
  Primitive005.RotZ = RotPos
  Schraube1.RotZ = RotPos
  Schraube2.RotZ = RotPos
  RotShadow.RotZ = (RotPos-270)
  UpperCueShadow.RotZ = (RotPos-270)
  CueShadow.RotZ = (RotPos-270)

  If BBall.Y > 615 Then
    BBall.X = 472 + 2.67 * RotPos
  Else
  End If

  If RotPos < RotMin OR RotPos > RotMax Then
    RotDir = RotDir * (-1)
    StopSound "Motor_Trunc1"
    PlaySound "Motor_Trunc1", 0, 0.2, 0, 0.04, 8000 'Syntax Helper: PlaySound(string, int loopcount, float volume, float pan, float randompitch, int pitch, bool useexisting, bool restart, float front_rear_fade)
  Else
  End If
End Sub

Sub RotateStart(Enabled)
  If Enabled Then
    Rotate.Enabled = 1
  Else
    Rotate.Enabled = 0
    Primitive004.collidable = 1
  End If
End Sub


''***************** Writing file for LUT's memory JPJ **********
sub WriteLUT
  Set File = FileObj.createTextFile(UserDirectory & "CBWLUT.txt",True) 'write new file, and delete one if it exists
  File.writeline(MyPrefs_Brightness)
  File.close
End sub
'******************* LUT CHoice **************************

Sub SetLUT
  Select Case MyPrefs_Brightness
    Case 0:Table1.ColorGradeImage = "0 Neutral"
    Case 1:Table1.ColorGradeImage = "0 Warm"
    Case 2:Table1.ColorGradeImage = "20 Neutral"
    Case 3:Table1.ColorGradeImage = "20 Warm"
    Case 4:Table1.ColorGradeImage = "40 Neutral"
    Case 5:Table1.ColorGradeImage = "40 Warm"
    Case 6:Table1.ColorGradeImage = "50 Neutral"
    Case 7:Table1.ColorGradeImage = "50 Warm"
  end Select
  WriteLUT
end sub

Sub LUTBox_Timer
  LUTBox.TimerEnabled = 0
  LUTBox.Visible = 0
End Sub

Sub ShowLUT
  Select Case MyPrefs_Brightness
    Case 0:LUTBoxText = "0 Neutral"
    Case 1:LUTBoxText = "0 Warm"
    Case 2:LUTBoxText = "20 Neutral"
    Case 3:LUTBoxText = "20 Warm"
    Case 4:LUTBoxText = "40 Neutral"
    Case 5:LUTBoxText = "40 Warm"
    Case 6:LUTBoxText = "50 Neutral"
    Case 7:LUTBoxText = "50 Warm"
  end Select
  LUTBox.visible = 1
  LUTBox.text = "LUT: " & LUTBoxText
  LUTBox.TimerEnabled = 1
End Sub

' Thalamus : Exit in a clean and proper way
Sub Table1_exit()
  Controller.Pause = False
  Controller.Stop
End Sub


' Lavalamp code below.  Thank you STEELY!
Bcnt = 0
For Each Blob in Lspeed
	Lbob(Bcnt) = .2
	Lspeed(Bcnt) = Int((5 * Rnd) + 2) * .05
	Bcnt = Bcnt + 1
Next


Sub LavaTimer_Timer()
	Bcnt = 0
	For Each Blob in Lava
		If Blob.TransZ <= LavaBase.Size_Z * 1.5 Then 	'Change blob direction to up
			Lspeed(Bcnt) = Int((5 * Rnd) + 2) * .05		'travel speed
			blobAng(Bcnt) = Int((359 * Rnd) + 1)			'blob location/angle from center
			blobRad(Bcnt) = Int((40 * Rnd) + 10)			'blob distance from center, radius
			blobSiz(Bcnt) = Int((150 * Rnd) + 100)		'blob size
			Blob.Size_x = blobSiz(Bcnt):Blob.Size_y = blobSiz(Bcnt):Blob.Size_z = blobSiz(Bcnt)
			Blob.X = Round(Cos(blobAng(Bcnt)*0.0174533), 3) * blobRad(Bcnt) + LavaBase.X	'place blob
			Blob.Y = Round(Sin(blobAng(Bcnt)*0.0174533), 3) * blobRad(Bcnt) + LavaBase.Y
		End If

		If Blob.TransZ => LavaBase.Size_Z*5 Then		'Change blob direction to down
			blobAng(Bcnt) = Int((359 * Rnd) + 1)			'blob location/angle from center
			blobRad(Bcnt) = Int((40 * Rnd) + 10)			'blob distance from center,radius
			Blob.X = Round(Cos(blobAng(Bcnt)*0.0174533), 3) * blobRad(Bcnt) + LavaBase.X	'place blob
			Blob.Y = Round(Sin(blobAng(Bcnt)*0.0174533), 3) * blobRad(Bcnt) + LavaBase.Y
			Lspeed(Bcnt) = Int((8 * Rnd) + 5) * .05:Lspeed(Bcnt) = Lspeed(Bcnt) * -1				'travel speed
		End If

		'Make blob wobble
		If Blob.Size_x > blobSiz(Bcnt) + blobSiz(Bcnt)*.15 or Blob.Size_x < blobSiz(Bcnt) - blobSiz(Bcnt)*.15  Then Lbob(Bcnt) = Lbob(Bcnt) * -1
		Blob.Size_x = Blob.Size_x + Lbob(Bcnt)
		Blob.Size_y = Blob.Size_y + Lbob(Bcnt)
		Blob.Size_z = Blob.Size_Z - Lbob(Bcnt) * .66
		Blob.TransZ = Blob.TransZ + Lspeed(Bcnt)		'Move blob
		Bcnt = Bcnt + 1
	Next

End Sub


' make bubbles random Speed
Sub BeerTimer_Timer()

Randomize(21)
BeerBubble1.z = BeerBubble1.z + Rnd(1)*0.5
if BeerBubble1.z > -771 then BeerBubble1.z = -955

BeerBubble2.z = BeerBubble2.z + Rnd(1)*1
if BeerBubble2.z > -768 then BeerBubble2.z = -955

BeerBubble3.z = BeerBubble3.z + Rnd(1)*1
if BeerBubble3.z > -768 then BeerBubble3.z = -955

BeerBubble4.z = BeerBubble4.z + Rnd(1)*0.75
if BeerBubble4.z > -774 then BeerBubble4.z = -955

BeerBubble5.z = BeerBubble5.z + Rnd(1)*1
if BeerBubble5.z > -771 then BeerBubble5.z = -955

BeerBubble6.z = BeerBubble6.z + Rnd(1)*1
if BeerBubble6.z > -774 then BeerBubble6.z = -955

BeerBubble7.z = BeerBubble7.z + Rnd(1)*0.8
if BeerBubble7.z > -768 then BeerBubble7.z = -955

BeerBubble8.z = BeerBubble8.z + Rnd(1)*1
if BeerBubble8.z > -771 then BeerBubble8.z = -955
End Sub


Dim CurrentMinute ' for VR clock 
' VR Clock code below....
Sub ClockTimer_Timer()
	Pminutes.RotAndTra2 = (Minute(Now())+(Second(Now())/100))*6
	Phours.RotAndTra2 = Hour(Now())*30+(Minute(Now())/2)
    Pseconds.RotAndTra2 = (Second(Now()))*6
	CurrentMinute=Minute(Now())
End Sub


'***************************************************
'       JP's VP10 Fading Lamps & Flashers
'       Based on PD's Fading Light System
' SetLamp 0 is Off
' SetLamp 1 is On
' fading for non opacity objects is 4 steps
'***************************************************

Dim LampState(200), FadingLevel(200)
Dim FlashSpeedUp(200), FlashSpeedDown(200), FlashMin(200), FlashMax(200), FlashLevel(200)

InitLamps()             ' turn off the lights and flashers and reset them to the default parameters
'LampTimer.Interval = 5 'lamp fading speed
'LampTimer.Enabled = 1

' Lamp & Flasher Timers

Sub LampTimer()
  Dim chgLamp, num, chg, ii
  chgLamp = Controller.ChangedLamps
  If Not IsEmpty(chgLamp) Then
    For ii = 0 To UBound(chgLamp)
      LampState(chgLamp(ii, 0) ) = chgLamp(ii, 1)       'keep the real state in an array
      FadingLevel(chgLamp(ii, 0) ) = chgLamp(ii, 1) + 4 'actual fading step
    Next
  End If
  UpdateLamps
End Sub

Sub UpdateLamps()
  NFadeL 0, l0
  NFadeObjm 2, p2, "bulbcover1_greenON", "bulbcover1_green"
  NFadeL 2, l2 'Apron LED
  NFadeObjm 3, p3, "bulbcover1_greenON", "bulbcover1_green"
  NFadeL 3, l3 'Apron LED
  NFadeObjm 4, p4, "bulbcover1_greenON", "bulbcover1_green"
  NFadeL 4, l4 'Apron LED
  NFadeObjm 5, p5, "bulbcover1_greenON", "bulbcover1_green"
  NFadeL 5, l5 'Apron LED
  NFadeObjm 6, p6, "bulbcover1_greenON", "bulbcover1_green"
  NFadeL 6, l6 'Apron LED
  NFadeObjm 7, p7, "bulbcover1_greenON", "bulbcover1_green"
  NFadeL 7, l7 'Apron LED

  NFadeL 10, L10 'Bumper 1
  NFadeL 10, L10a 'Bumper 1
  NFadeL 11, L11 'Bumper 2
  NFadeL 11, L11a 'Bumper 2
  NFadeObjm 12, p12, "bulbcover1_redON", "bulbcover1_red"
  NFadeL 12, l12 'Apron LED
  NFadeObjm 13, p13, "bulbcover1_redON", "bulbcover1_red"
  NFadeL 13, l13 'Apron LED
  NFadeObjm 14, p14, "bulbcover1_redON", "bulbcover1_red"
  NFadeL 14, l14 'Apron LED
  NFadeObjm 15, p15, "bulbcover1_redON", "bulbcover1_red"
  NFadeL 15, l15 'Apron LED
  NFadeObjm 16, p16, "bulbcover1_redON", "bulbcover1_red"
  NFadeL 16, l16 'Apron LED
  NFadeObjm 17, p17, "bulbcover1_redON", "bulbcover1_red"
  NFadeL 17, l17 'Apron LED

  NFadeL 20, l20
  NFadeL 21, l21
  NFadeL 22, l22
  NFadeL 23, l23
  NFadeL 24, l24
  NFadeL 25, l25
  NFadeL 26, l26
  NFadeL 27, l27

  NFadeL 30, l30
  NFadeL 31, l31
  NFadeL 32, l32
  NFadeL 33, l33
  NFadeL 34, l34
  NFadeL 35, l35
  NFadeL 36, l36
  NFadeL 37, l37

  NFadeL 40, l40
  NFadeL 41, l41
  NFadeL 42, l42
  NFadeL 43, l43
  NFadeL 44, l44
  NFadeL 45, l45
  NFadeL 46, l46
  NFadeL 47, l47

  NFadeL 50, l50
  NFadeL 51, l51
  NFadeL 52, l52
  NFadeL 53, l53
  NFadeL 54, l54
  NFadeL 55, l55
  NFadeL 56, l56
  NFadeL 57, l57

  NFadeL 60, l60
  NFadeL 61, l61
  NFadeL 62, l62
  NFadeL 63, l63
  NFadeL 64, l64
  NFadeL 65, l65
  NFadeL 66, l66
  NFadeL 67, l67

  NFadeL 70, l70
  NFadeL 71, l71
  NFadeL 72, l72
  NFadeL 73, l73
  NFadeL 74, l74
  NFadeL 75, l75
  NFadeL 76, l76
  NFadeL 77, l77

  NFadeL 80, l80
  NFadeL 81, l81
  NFadeL 82, l82
  NFadeL 83, l83
  NFadeL 84, l84
  NFadeL 85, l85
  NFadeL 86, l86
  NFadeL 87, l87

  NFadeObjm 90, p90, "bulbcover1_redON", "bulbcover1_red"
  Flash 90, F90 'LED
  NFadeObjm 91, p91, "bulbcover1_redON", "bulbcover1_red"
  Flash 91, F91 'LED
  NFadeL 92, l92
  NFadeL 93, l93
  NFadeL 94, l94
  NFadeL 95, l95
  NFadeL 96, l96
  NFadeL 97, l97

  NFadeL 100, l100
  NFadeL 101, l101
  NFadeL 102, l102
  NFadeL 103, l103
  NFadeL 104, l104
  NFadeL 105, l105
  NFadeL 106, l106
  NFadeL 107, l107

  NFadeL 110, l110
  NFadeL 111, l111
  NFadeL 112, l112
  NFadeL 113, l113
  NFadeL 114, l114
  NFadeL 115, l115
  NFadeL 116, l116
  NFadeL 117, l117

  ' Solenoid Controlled
  Flashm 151, f151a
  Flashm 151, f151b
  Flashm 151, f151c
  Flash 151, f151d

  Flashm 152, f152a
  Flashm 152, f152b
  Flashm 152, f152c
  Flash 152, f152d

  Flashm 153, FlasherYellow
  Flashm 153, f153      'Y Dome
  flashm 153, L10a
  flash 153, L153b
  Flashm 154, FlasherBlue
  Flashm 154, f154
  flash 154, L154b      'B Dome
  Flashm 155, FlasherRed
  Flashm 155, f155      'R Dome
  Flashm 155, L11a
  flash 155, L155b

  Flashm 156, F156
  Flash 156, f156a
  Flashm 157, Flasherflash1
  Flash 157, F157      'Clear Dome
  'Flashm 158 ', 'Flasherflash2 nur zum Testen
  Flash 158, F158      'Clear Dome
End Sub

' div lamp subs

Sub InitLamps()
  Dim x
  For x = 0 to 200
    LampState(x) = 0        ' current light state, independent of the fading level. 0 is off and 1 is on
    FadingLevel(x) = 4      ' used to track the fading state
    FlashSpeedUp(x) = 0.4   ' faster speed when turning on the flasher
    FlashSpeedDown(x) = 0.2 ' slower speed when turning off the flasher
    FlashMax(x) = 1         ' the maximum value when on, usually 1
    FlashMin(x) = 0         ' the minimum value when off, usually 0
    FlashLevel(x) = 0       ' the intensity of the flashers, usually from 0 to 1
  Next
End Sub

Sub AllLampsOff
  Dim x
  For x = 0 to 200
    SetLamp x, 0
  Next
End Sub

Sub SetLamp(nr, value)
  If value <> LampState(nr) Then
    LampState(nr) = abs(value)
    FadingLevel(nr) = abs(value) + 4
  End If
End Sub

' Lights: used for VP10 standard lights, the fading is handled by VP itself

Sub NFadeL(nr, object)
  Select Case FadingLevel(nr)
    Case 4:object.state = 0:FadingLevel(nr) = 0
    Case 5:object.state = 1:FadingLevel(nr) = 1
  End Select
End Sub

Sub NFadeLm(nr, object) ' used for multiple lights
  Select Case FadingLevel(nr)
    Case 4:object.state = 0
    Case 5:object.state = 1
  End Select
End Sub

'Lights, Ramps & Primitives used as 4 step fading lights
'a,b,c,d are the images used from on to off

Sub FadeObj(nr, object, a, b, c, d)
  Select Case FadingLevel(nr)
    Case 4:object.image = b:FadingLevel(nr) = 6                   'fading to off...
    Case 5:object.image = a:FadingLevel(nr) = 1                   'ON
    Case 6, 7, 8:FadingLevel(nr) = FadingLevel(nr) + 1             'wait
    Case 9:object.image = c:FadingLevel(nr) = FadingLevel(nr) + 1 'fading...
    Case 10, 11, 12:FadingLevel(nr) = FadingLevel(nr) + 1         'wait
    Case 13:object.image = d:FadingLevel(nr) = 0                  'Off
  End Select
End Sub

Sub FadeObjm(nr, object, a, b, c, d)
  Select Case FadingLevel(nr)
    Case 4:object.image = b
    Case 5:object.image = a
    Case 9:object.image = c
    Case 13:object.image = d
  End Select
End Sub

Sub NFadeObj(nr, object, a, b)
  Select Case FadingLevel(nr)
    Case 4:object.image = b:FadingLevel(nr) = 0 'off
    Case 5:object.image = a:FadingLevel(nr) = 1 'on
  End Select
End Sub

Sub NFadeObjm(nr, object, a, b)
  Select Case FadingLevel(nr)
    Case 4:object.image = b
    Case 5:object.image = a
  End Select
End Sub

' Flasher objects

Sub Flash(nr, object)
  Select Case FadingLevel(nr)
    Case 4 'off
      FlashLevel(nr) = FlashLevel(nr) - FlashSpeedDown(nr)
      If FlashLevel(nr) < FlashMin(nr) Then
        FlashLevel(nr) = FlashMin(nr)
        FadingLevel(nr) = 0 'completely off
      End if
      Object.IntensityScale = FlashLevel(nr)
    Case 5 ' on
      FlashLevel(nr) = FlashLevel(nr) + FlashSpeedUp(nr)
      If FlashLevel(nr) > FlashMax(nr) Then
        FlashLevel(nr) = FlashMax(nr)
        FadingLevel(nr) = 1 'completely on
      End if
      Object.IntensityScale = FlashLevel(nr)
  End Select
End Sub

Sub Flashm(nr, object) 'multiple flashers, it just sets the flashlevel
  Object.IntensityScale = FlashLevel(nr)
End Sub

'**********Sling Shot Animations
' Rstep and Lstep  are the variables that increment the animation
'****************
Dim RStep, Lstep

Sub RightSlingShot_Slingshot
  vpmTimer.PulseSw 15
  RandomSoundSlingshotRight Sling1
  RSling.Visible = 0
  RSling1.Visible = 1
  sling1.rotx = 20
  RStep = 0
  RightSlingShot.TimerEnabled = 1
End Sub

Sub RightSlingShot_Timer
  Select Case RStep
    Case 3:RSLing1.Visible = 0:RSLing2.Visible = 1:sling1.rotx = 10
    Case 4:RSLing2.Visible = 0:RSLing.Visible = 1:sling1.rotx = 0:RightSlingShot.TimerEnabled = 0
  End Select
  RStep = RStep + 1
End Sub

Sub LeftSlingShot_Slingshot
  vpmTimer.PulseSw 14
  RandomSoundSlingshotLeft Sling2
  LSling.Visible = 0
  LSling1.Visible = 1
  sling2.rotx = 20
  LStep = 0
  LeftSlingShot.TimerEnabled = 1
End Sub

Sub LeftSlingShot_Timer
  Select Case LStep
    Case 3:LSLing1.Visible = 0:LSLing2.Visible = 1:sling2.rotx = 10
    Case 4:LSLing2.Visible = 0:LSLing.Visible = 1:sling2.rotx = 0:LeftSlingShot.TimerEnabled = 0
  End Select
  LStep = LStep + 1
End Sub


'******************************************************
'****  BALL ROLLING AND DROP SOUNDS
'******************************************************
'
' Be sure to call RollingUpdate in a timer with a 10ms interval see the GameTimer_Timer() sub

ReDim rolling(tnob)
InitRolling

Dim DropCount
ReDim DropCount(tnob)

Sub InitRolling
	Dim i
	For i = 0 to tnob
		rolling(i) = False
	Next
End Sub

Sub RollingUpdate()
	Dim BOT, b
	BOT = GetBalls

	' stop the sound of deleted balls
	For b = UBound(BOT) + 1 to tnob
		' Comment the next line if you are not implementing Dyanmic Ball Shadows
		If AmbientBallShadowOn = 0 Then BallShadowA(b).visible = 0
		rolling(b) = False
		StopSound("BallRoll_" & b)
	Next

	' exit the sub if no balls on the table
	If UBound(BOT) = -1 Then Exit Sub

	' play the rolling sound for each ball

	For b = 0 to UBound(BOT)
		If BallVel(BOT(b)) > 1 AND BOT(b).z < 30 Then
			rolling(b) = True
			PlaySound ("BallRoll_" & b), -1, VolPlayfieldRoll(BOT(b)) * BallRollVolume * VolumeDial, AudioPan(BOT(b)), 0, PitchPlayfieldRoll(BOT(b)), 1, 0, AudioFade(BOT(b))

		Else
			If rolling(b) = True Then
				StopSound("BallRoll_" & b)
				rolling(b) = False
			End If
		End If

		' Ball Drop Sounds
		If BOT(b).VelZ < -1 and BOT(b).z < 55 and BOT(b).z > 27 Then 'height adjust for ball drop sounds
			If DropCount(b) >= 5 Then
				DropCount(b) = 0
				If BOT(b).velz > -7 Then
					RandomSoundBallBouncePlayfieldSoft BOT(b)
				Else
					RandomSoundBallBouncePlayfieldHard BOT(b)
				End If				
			End If
		End If
		If DropCount(b) < 5 Then
			DropCount(b) = DropCount(b) + 1
		End If

		' "Static" Ball Shadows
		' Comment the next If block, if you are not implementing the Dyanmic Ball Shadows
		If AmbientBallShadowOn = 0 Then
			If BOT(b).Z > 30 Then
				BallShadowA(b).height=BOT(b).z - BallSize/4		'This is technically 1/4 of the ball "above" the ramp, but it keeps it from clipping
			Else
				BallShadowA(b).height=BOT(b).z - BallSize/2 + 5
			End If
			BallShadowA(b).Y = BOT(b).Y + Ballsize/5 + fovY
			BallShadowA(b).X = BOT(b).X
			BallShadowA(b).visible = 1
		End If
	Next
End Sub


'*****************************************
'	WHITE BALL SHADOW (Vog based on ninuzzu's BALL SHADOW)
'*****************************************

Sub WBallShadowUpdate()
  ' !!!!!!!!!!!!!! korrigieren
  If FadingLevel(156) = 0 Then
    WBallShadow.Visible = 0
  Else WBallShadow.Visible = 1
  End If
  WBallShadow.X = WBall.X
  WBallShadow.Y = WBall.Y
  WBallShadow.RotZ = 90 - (WBall.X - (Table1.Width - 50)/2) / 10
End Sub


'***************************************************************
'****  VPW DYNAMIC BALL SHADOWS by Iakki, Apophis, and Wylte
'***************************************************************

'****** INSTRUCTIONS please read ******

'****** Part A:  Table Elements ******
'
' Import the "bsrtx7" and "ballshadow" images
' Import the shadow materials file (3 sets included) (you can also export the 3 sets from this table to create the same file)
' Copy in the BallShadowA flasher set and the sets of primitives named BallShadow#, RtxBallShadow#, and RtxBall2Shadow#
'	* Count from 0 up, with at least as many objects each as there can be balls, including locked balls.  You'll get an "eval" warning if tnob is higher
'	* Warning:  If merging with another system (JP's ballrolling), you may need to check tnob math and add an extra BallShadowA# flasher (out of range error)
' Ensure you have a timer with a -1 interval that is always running
' Set plastic ramps DB to *less* than the ambient shadows (-10000) if you want to see the pf shadow through the ramp

' Create a collection called DynamicSources that includes all light sources you want to cast ball shadows
' It's recommended that you be selective in which lights go in this collection, as there are limitations:
' 1. The shadows can "pass through" solid objects and other light sources, so be mindful of where the lights would actually able to cast shadows
' 2. If there are more than two equidistant sources, the shadows can suddenly switch on and off, so places like top and bottom lanes need attention
' 3. At this time the shadows get the light on/off from tracking gilvl, so if you have lights you want shadows for that are on at different times you will need to either:
'	a) remove this restriction (shadows think lights are always On)
'	b) come up with a custom solution (see TZ example in script)
' After confirming the shadows work in general, use ball control to move around and look for any weird behavior

'****** End Part A:  Table Elements ******


'****** Part B:  Code and Functions ******

' *** Timer sub
' The "DynamicBSUpdate" sub should be called by a timer with an interval of -1 (framerate)
' Example timer sub:

'Sub FrameTimer_Timer()
'	If DynamicBallShadowsOn Or AmbientBallShadowOn Then DynamicBSUpdate 'update ball shadows
'End Sub

' *** These are usually defined elsewhere (ballrolling), but activate here if necessary
'Const tnob = 10 ' total number of balls
'Const lob = 0	'locked balls on start; might need some fiddling depending on how your locked balls are done
'Dim tablewidth: tablewidth = Table1.width
'Dim tableheight: tableheight = Table1.height

' *** User Options - Uncomment here or move to top for easy access by players
'----- Shadow Options -----
'Const DynamicBallShadowsOn = 1		'0 = no dynamic ball shadow ("triangles" near slings and such), 1 = enable dynamic ball shadow
'Const AmbientBallShadowOn = 1		'0 = Static shadow under ball ("flasher" image, like JP's)
'									'1 = Moving ball shadow ("primitive" object, like ninuzzu's) - This is the only one that shows up on the pf when in ramps and fades when close to lights!
'									'2 = flasher image shadow, but it moves like ninuzzu's

' *** This segment goes within the RollingUpdate sub, so that if Ambient...=0 and Dynamic...=0 the entire DynamicBSUpdate sub can be skipped for max performance
' *** Change BOT to BOT if using existing getballs code
' *** Includes lines commonly found there, for reference:
'	' stop the sound of deleted balls
'	For b = UBound(BOT) + 1 to tnob
'		If AmbientBallShadowOn = 0 Then BallShadowA(b).visible = 0
'		...rolling(b) = False
'		...StopSound("BallRoll_" & b)
'	Next
'
' ...rolling and drop sounds...

'		If DropCount(b) < 5 Then
'			DropCount(b) = DropCount(b) + 1
'		End If
'
'		' "Static" Ball Shadows
'		If AmbientBallShadowOn = 0 Then
'			If BOT(b).Z > 30 Then
'				BallShadowA(b).height=BOT(b).z - BallSize/4		'This is technically 1/4 of the ball "above" the ramp, but it keeps it from clipping the ramp
'			Else
'				BallShadowA(b).height=BOT(b).z - BallSize/2 + 5
'			End If
'			BallShadowA(b).Y = BOT(b).Y + Ballsize/5 + offsetY
'			BallShadowA(b).X = BOT(b).X + offsetX
'			BallShadowA(b).visible = 1
'		End If

' *** Required Functions, enable these if they are not already present elswhere in your table
Function max(a,b)
	if a > b then 
		max = a
	Else
		max = b
	end if
end Function

'Function Distance(ax,ay,bx,by)
'	Distance = SQR((ax - bx)^2 + (ay - by)^2)
'End Function

'Dim PI: PI = 4*Atn(1)

'Function Atn2(dy, dx)
'	If dx > 0 Then
'		Atn2 = Atn(dy / dx)
'	ElseIf dx < 0 Then
'		If dy = 0 Then 
'			Atn2 = pi
'		Else
'			Atn2 = Sgn(dy) * (pi - Atn(Abs(dy / dx)))
'		end if
'	ElseIf dx = 0 Then
'		if dy = 0 Then
'			Atn2 = 0
'		else
'			Atn2 = Sgn(dy) * pi / 2
'		end if
'	End If
'End Function

'Function AnglePP(ax,ay,bx,by)
'	AnglePP = Atn2((by - ay),(bx - ax))*180/PI
'End Function

'****** End Part B:  Code and Functions ******


'****** Part C:  The Magic ******

' *** These define the appearance of shadows in your table	***

'Ambient (Room light source)
Const AmbientBSFactor 		= 0.9	'0 to 1, higher is darker
Const AmbientMovement		= 2		'1 to 4, higher means more movement as the ball moves left and right
Const offsetX				= 0		'Offset x position under ball	(These are if you want to change where the "room" light is for calculating the shadow position,)
Const offsetY				= 0		'Offset y position under ball	 (for example 5,5 if the light is in the back left corner)
'Dynamic (Table light sources)
Const DynamicBSFactor 		= 0.95	'0 to 1, higher is darker
Const Wideness				= 20	'Sets how wide the dynamic ball shadows can get (20 +5 thinness is technically most accurate for lights at z ~25 hitting a 50 unit ball)
Const Thinness				= 5		'Sets minimum as ball moves away from source

' ***														***

' *** Trim or extend these to *match* the number of balls/primitives/flashers on the table!
dim objrtx1(5), objrtx2(5)
dim objBallShadow(5)
Dim BallShadowA
BallShadowA = Array (BallShadowA0,BallShadowA1,BallShadowA2,BallShadowA3,BallShadowA4)
Dim DSSources(30), numberofsources', DSGISide(30) 'Adapted for TZ with GI left / GI right

'Initialization
DynamicBSInit

sub DynamicBSInit()
	Dim iii, source

	for iii = 0 to tnob - 1								'Prepares the shadow objects before play begins
		Set objrtx1(iii) = Eval("RtxBallShadow" & iii)
		objrtx1(iii).material = "RtxBallShadow" & iii
		objrtx1(iii).z = 1 + iii/1000 + 0.01			'Separate z for layering without clipping
		objrtx1(iii).visible = 0

		Set objrtx2(iii) = Eval("RtxBall2Shadow" & iii)
		objrtx2(iii).material = "RtxBallShadow2_" & iii
		objrtx2(iii).z = 1 + iii/1000 + 0.02
		objrtx2(iii).visible = 0

		Set objBallShadow(iii) = Eval("BallShadow" & iii)
		objBallShadow(iii).material = "BallShadow" & iii
		UpdateMaterial objBallShadow(iii).material,1,0,0,0,0,0,AmbientBSFactor,RGB(0,0,0),0,0,False,True,0,0,0,0
		objBallShadow(iii).Z = 1 + iii/1000 + 0.04
		objBallShadow(iii).visible = 0

		BallShadowA(iii).Opacity = 100*AmbientBSFactor
		BallShadowA(iii).visible = 0
	Next

	iii = 0

	For Each Source in DynamicSources
		DSSources(iii) = Array(Source.x, Source.y)
'		If Instr(Source.name , "Left") > 0 Then DSGISide(iii) = 0 Else DSGISide(iii) = 1	'Adapted for TZ with GI left / GI right
		iii = iii + 1
	Next
	numberofsources = iii
end sub

Sub DynamicBSUpdate
	Dim falloff: falloff = 150 'Max distance to light sources, can be changed dynamically if you have a reason
	Dim ShadowOpacity1, ShadowOpacity2 
	Dim s, LSd, iii
	Dim dist1, dist2, src1, src2
	Dim BOT: BOT=getballs	'Uncomment if you're deleting balls - Don't do it! #SaveTheBalls

	'Hide shadow of deleted balls
	For s = UBound(BOT) + 1 to tnob - 1
		objrtx1(s).visible = 0
		objrtx2(s).visible = 0
		objBallShadow(s).visible = 0
		BallShadowA(s).visible = 0
	Next

	If UBound(BOT) < lob Then Exit Sub		'No balls in play, exit

'The Magic happens now
	For s = lob to UBound(BOT)

' *** Normal "ambient light" ball shadow
	'Layered from top to bottom. If you had an upper pf at for example 80 units and ramps even above that, your segments would be z>110; z<=110 And z>100; z<=100 And z>30; z<=30 And z>20; Else invisible

		If AmbientBallShadowOn = 1 Then			'Primitive shadow on playfield, flasher shadow in ramps
			If BOT(s).Z > 30 Then							'The flasher follows the ball up ramps while the primitive is on the pf
				If BOT(s).X < tablewidth/2 Then
					objBallShadow(s).X = ((BOT(s).X) - (Ballsize/10) + ((BOT(s).X - (tablewidth/2))/(Ballsize/AmbientMovement))) + offsetX + 5
				Else
					objBallShadow(s).X = ((BOT(s).X) + (Ballsize/10) + ((BOT(s).X - (tablewidth/2))/(Ballsize/AmbientMovement))) + offsetX - 5
				End If
				objBallShadow(s).Y = BOT(s).Y + BallSize/10 + offsetY
				objBallShadow(s).visible = 1

				BallShadowA(s).X = BOT(s).X + offsetX
				BallShadowA(s).Y = BOT(s).Y + BallSize/5
				BallShadowA(s).height=BOT(s).z - BallSize/4		'This is technically 1/4 of the ball "above" the ramp, but it keeps it from clipping the ramp
				BallShadowA(s).visible = 1
			Elseif BOT(s).Z <= 30 And BOT(s).Z > 20 Then	'On pf, primitive only
				objBallShadow(s).visible = 1
				If BOT(s).X < tablewidth/2 Then
					objBallShadow(s).X = ((BOT(s).X) - (Ballsize/10) + ((BOT(s).X - (tablewidth/2))/(Ballsize/AmbientMovement))) + offsetX + 5
				Else
					objBallShadow(s).X = ((BOT(s).X) + (Ballsize/10) + ((BOT(s).X - (tablewidth/2))/(Ballsize/AmbientMovement))) + offsetX - 5
				End If
				objBallShadow(s).Y = BOT(s).Y + offsetY
'				objBallShadow(s).Z = BOT(s).Z + s/1000 + 0.04		'Uncomment (and adjust If/Elseif height logic) if you want the primitive shadow on an upper/split pf
				BallShadowA(s).visible = 0
			Else											'Under pf, no shadows
				objBallShadow(s).visible = 0
				BallShadowA(s).visible = 0
			end if

		Elseif AmbientBallShadowOn = 2 Then		'Flasher shadow everywhere
			If BOT(s).Z > 30 Then							'In a ramp
				BallShadowA(s).X = BOT(s).X + offsetX
				BallShadowA(s).Y = BOT(s).Y + BallSize/5
				BallShadowA(s).height=BOT(s).z - BallSize/4		'This is technically 1/4 of the ball "above" the ramp, but it keeps it from clipping the ramp
				BallShadowA(s).visible = 1
			Elseif BOT(s).Z <= 30 And BOT(s).Z > 20 Then	'On pf
				BallShadowA(s).visible = 1
				If BOT(s).X < tablewidth/2 Then
					BallShadowA(s).X = ((BOT(s).X) - (Ballsize/10) + ((BOT(s).X - (tablewidth/2))/(Ballsize/AmbientMovement))) + offsetX + 5
				Else
					BallShadowA(s).X = ((BOT(s).X) + (Ballsize/10) + ((BOT(s).X - (tablewidth/2))/(Ballsize/AmbientMovement))) + offsetX - 5
				End If
				BallShadowA(s).Y = BOT(s).Y + Ballsize/10 + offsetY
				BallShadowA(s).height=BOT(s).z - BallSize/2 + 5
			Else											'Under pf
				BallShadowA(s).visible = 0
			End If
		End If

' *** Dynamic shadows
		If DynamicBallShadowsOn Then
			If BOT(s).Z < 30 And BOT(s).X < 850 Then	'Parameters for where the shadows can show, here they are not visible above the table (no upper pf) or in the plunger lane
				dist1 = falloff:
				dist2 = falloff
				For iii = 0 to numberofsources - 1 ' Search the 2 nearest influencing lights
					LSd = Distance(BOT(s).x, BOT(s).y, DSSources(iii)(0), DSSources(iii)(1)) 'Calculating the Linear distance to the Source
					If LSd < falloff And gilvl > 0 Then
'					If LSd < dist2 And ((DSGISide(iii) = 0 And Lampz.State(100)>0) Or (DSGISide(iii) = 1 And Lampz.State(104)>0)) Then	'Adapted for TZ with GI left / GI right
						dist2 = dist1
						dist1 = LSd
						src2 = src1
						src1 = iii
					End If
				Next
				ShadowOpacity1 = 0
				If dist1 < falloff Then
					objrtx1(s).visible = 1 : objrtx1(s).X = BOT(s).X : objrtx1(s).Y = BOT(s).Y
					'objrtx1(s).Z = BOT(s).Z - 25 + s/1000 + 0.01 'Uncomment if you want to add shadows to an upper/lower pf
					objrtx1(s).rotz = AnglePP(DSSources(src1)(0), DSSources(src1)(1), BOT(s).X, BOT(s).Y) + 90
					ShadowOpacity1 = 1 - dist1 / falloff
					objrtx1(s).size_y = Wideness * ShadowOpacity1 + Thinness
					UpdateMaterial objrtx1(s).material,1,0,0,0,0,0,ShadowOpacity1*DynamicBSFactor^3,RGB(0,0,0),0,0,False,True,0,0,0,0
				Else
					objrtx1(s).visible = 0
				End If
				ShadowOpacity2 = 0
				If dist2 < falloff Then
					objrtx2(s).visible = 1 : objrtx2(s).X = BOT(s).X : objrtx2(s).Y = BOT(s).Y + offsetY
					'objrtx2(s).Z = BOT(s).Z - 25 + s/1000 + 0.02 'Uncomment if you want to add shadows to an upper/lower pf
					objrtx2(s).rotz = AnglePP(DSSources(src2)(0), DSSources(src2)(1), BOT(s).X, BOT(s).Y) + 90
					ShadowOpacity2 = 1 - dist2 / falloff
					objrtx2(s).size_y = Wideness * ShadowOpacity2 + Thinness
					UpdateMaterial objrtx2(s).material,1,0,0,0,0,0,ShadowOpacity2*DynamicBSFactor^3,RGB(0,0,0),0,0,False,True,0,0,0,0
				Else
					objrtx2(s).visible = 0
				End If
				If AmbientBallShadowOn = 1 Then
					'Fades the ambient shadow (primitive only) when it's close to a light
					UpdateMaterial objBallShadow(s).material,1,0,0,0,0,0,AmbientBSFactor*(1 - max(ShadowOpacity1, ShadowOpacity2)),RGB(0,0,0),0,0,False,True,0,0,0,0
				Else
					BallShadowA(s).Opacity = 100 * AmbientBSFactor * (1 - max(ShadowOpacity1, ShadowOpacity2))
				End If
			Else 'Hide dynamic shadows everywhere else, just in case
				objrtx2(s).visible = 0 : objrtx1(s).visible = 0
			End If
		End If
	Next
End Sub
'****************************************************************
'****  END VPW DYNAMIC BALL SHADOWS by Iakki, Apophis, and Wylte
'****************************************************************









'******************************************************
'****  PHYSICS DAMPENERS
'******************************************************
'
' These are data mined bounce curves, 
' dialed in with the in-game elasticity as much as possible to prevent angle / spin issues.
' Requires tracking ballspeed to calculate COR

Sub dPosts_Hit(idx) 
	RubbersD.dampen Activeball
	TargetBouncer Activeball, 1
End Sub

Sub dSleeves_Hit(idx) 
	SleevesD.Dampen Activeball
	TargetBouncer Activeball, 0.7
End Sub

dim RubbersD : Set RubbersD = new Dampener        'frubber
RubbersD.name = "Rubbers"
RubbersD.debugOn = False        'shows info in textbox "TBPout"
RubbersD.Print = False        'debug, reports in debugger (in vel, out cor)
'cor bounce curve (linear)
'for best results, try to match in-game velocity as closely as possible to the desired curve
'RubbersD.addpoint 0, 0, 0.935        'point# (keep sequential), ballspeed, CoR (elasticity)
RubbersD.addpoint 0, 0, 1.1        'point# (keep sequential), ballspeed, CoR (elasticity)
RubbersD.addpoint 1, 3.77, 0.97
RubbersD.addpoint 2, 5.76, 0.967        'dont take this as gospel. if you can data mine rubber elasticitiy, please help!
RubbersD.addpoint 3, 15.84, 0.874
RubbersD.addpoint 4, 56, 0.64        'there's clamping so interpolate up to 56 at least

dim SleevesD : Set SleevesD = new Dampener        'this is just rubber but cut down to 85%...
SleevesD.name = "Sleeves"
SleevesD.debugOn = False        'shows info in textbox "TBPout"
SleevesD.Print = False        'debug, reports in debugger (in vel, out cor)
SleevesD.CopyCoef RubbersD, 0.85

'######################### Add new FlippersD Profile
'#########################    Adjust these values to increase or lessen the elasticity

dim FlippersD : Set FlippersD = new Dampener
FlippersD.name = "Flippers"
FlippersD.debugOn = False
FlippersD.Print = False	
FlippersD.addpoint 0, 0, 1.1	
FlippersD.addpoint 1, 3.77, 0.99
FlippersD.addpoint 2, 6, 0.99

Class Dampener
	Public Print, debugOn 'tbpOut.text
	public name, Threshold         'Minimum threshold. Useful for Flippers, which don't have a hit threshold.
	Public ModIn, ModOut
	Private Sub Class_Initialize : redim ModIn(0) : redim Modout(0): End Sub 

	Public Sub AddPoint(aIdx, aX, aY) 
		ShuffleArrays ModIn, ModOut, 1 : ModIn(aIDX) = aX : ModOut(aIDX) = aY : ShuffleArrays ModIn, ModOut, 0
		if gametime > 100 then Report
	End Sub

	public sub Dampen(aBall)
		if threshold then if BallSpeed(aBall) < threshold then exit sub end if end if
		dim RealCOR, DesiredCOR, str, coef
		DesiredCor = LinearEnvelope(cor.ballvel(aBall.id), ModIn, ModOut )
		RealCOR = BallSpeed(aBall) / (cor.ballvel(aBall.id)+0.0001)
		coef = desiredcor / realcor 
		if debugOn then str = name & " in vel:" & round(cor.ballvel(aBall.id),2 ) & vbnewline & "desired cor: " & round(desiredcor,4) & vbnewline & _
		"actual cor: " & round(realCOR,4) & vbnewline & "ballspeed coef: " & round(coef, 3) & vbnewline 
		if Print then debug.print Round(cor.ballvel(aBall.id),2) & ", " & round(desiredcor,3)

		aBall.velx = aBall.velx * coef : aBall.vely = aBall.vely * coef
		if debugOn then TBPout.text = str
	End Sub

	public sub Dampenf(aBall, parm) 'Rubberizer is handle here
		dim RealCOR, DesiredCOR, str, coef
		DesiredCor = LinearEnvelope(cor.ballvel(aBall.id), ModIn, ModOut )
		RealCOR = BallSpeed(aBall) / (cor.ballvel(aBall.id)+0.0001)
		coef = desiredcor / realcor 
		If abs(aball.velx) < 2 and aball.vely < 0 and aball.vely > -3.75 then 
			aBall.velx = aBall.velx * coef : aBall.vely = aBall.vely * coef
		End If
	End Sub

	Public Sub CopyCoef(aObj, aCoef) 'alternative addpoints, copy with coef
		dim x : for x = 0 to uBound(aObj.ModIn)
			addpoint x, aObj.ModIn(x), aObj.ModOut(x)*aCoef
		Next
	End Sub


	Public Sub Report()         'debug, reports all coords in tbPL.text
		if not debugOn then exit sub
		dim a1, a2 : a1 = ModIn : a2 = ModOut
		dim str, x : for x = 0 to uBound(a1) : str = str & x & ": " & round(a1(x),4) & ", " & round(a2(x),4) & vbnewline : next
		TBPout.text = str
	End Sub

End Class



'******************************************************
' 	 VPW TargetBouncer for targets and posts by Iaakki, Wrd1972, Apophis
'******************************************************

Const TargetBouncerEnabled = 1	  '0 = normal standup targets, 1 = bouncy targets
Const TargetBouncerFactor = 0.7	 'Level of bounces. Recommmended value of 0.7

Sub TargetBouncer(aBall,defvalue)
	Dim zMultiplier, vel, vratio
	If TargetBouncerEnabled = 1 And aball.z < 30 Then
		'   debug.print "velx: " & aball.velx & " vely: " & aball.vely & " velz: " & aball.velz
		vel = BallSpeed(aBall)
		If aBall.velx = 0 Then vratio = 1 Else vratio = aBall.vely / aBall.velx
		Select Case Int(Rnd * 6) + 1
			Case 1
			zMultiplier = 0.2 * defvalue
			Case 2
			zMultiplier = 0.25 * defvalue
			Case 3
			zMultiplier = 0.3 * defvalue
			Case 4
			zMultiplier = 0.4 * defvalue
			Case 5
			zMultiplier = 0.45 * defvalue
			Case 6
			zMultiplier = 0.5 * defvalue
		End Select
		aBall.velz = Abs(vel * zMultiplier * TargetBouncerFactor)
		aBall.velx = Sgn(aBall.velx) * Sqr(Abs((vel ^ 2 - aBall.velz ^ 2) / (1 + vratio ^ 2)))
		aBall.vely = aBall.velx * vratio
		'   debug.print "---> velx: " & aball.velx & " vely: " & aball.vely & " velz: " & aball.velz
		'   debug.print "conservation check: " & BallSpeed(aBall)/vel
	End If
End Sub

'Add targets or posts to the TargetBounce collection if you want to activate the targetbouncer code from them
Sub TargetBounce_Hit(idx)
	TargetBouncer activeball, 1
End Sub


'******************************************************
' 	  FLEEP MECHANICAL SOUNDS
'******************************************************

' This part in the script is an entire block that is dedicated to the physics sound system.
' Various scripts and sounds that may be pretty generic and could suit other WPC systems, but the most are tailored specifically for the TOM table

' Many of the sounds in this package can be added by creating collections and adding the appropriate objects to those collections.  
' Create the following new collections:
' 	Metals (all metal objects, metal walls, metal posts, metal wire guides)
' 	Apron (the apron walls and plunger wall)
' 	Walls (all wood or plastic walls)
' 	Rollovers (wire rollover triggers, star triggers, or button triggers)
' 	Targets (standup or drop targets, these are hit sounds only ... you will want to add separate dropping sounds for drop targets)
' 	Gates (plate gates)
' 	GatesWire (wire gates)
' 	Rubbers (all rubbers including posts, sleeves, pegs, and bands)
' When creating the collections, make sure "Fire events for this collection" is checked.  
' You'll also need to make sure "Has Hit Event" is checked for each object placed in these collections (not necessary for gates and triggers).  
' Once the collections and objects are added, the save, close, and restart VPX.
'
' Many places in the script need to be modified to include the correct sound effect subroutine calls. The tutorial videos linked below demonstrate 
' how to make these updates. But in summary the following needs to be updated:	
'	- Nudging, plunger, coin-in, start button sounds will be added to the keydown and keyup subs.
'	- Flipper sounds in the flipper solenoid subs. Flipper collision sounds in the flipper collide subs.
'	- Bumpers, slingshots, drain, ball release, knocker, spinner, and saucers in their respective subs
'	- Ball rolling sounds sub
'
' Tutorial vides by Apophis
' Part 1: 	https://youtu.be/PbE2kNiam3g
' Part 2: 	https://youtu.be/B5cm1Y8wQsk
' Part 3: 	https://youtu.be/eLhWyuYOyGg


'///////////////////////////////  SOUNDS PARAMETERS  //////////////////////////////
Dim GlobalSoundLevel, CoinSoundLevel, PlungerReleaseSoundLevel, PlungerPullSoundLevel, NudgeLeftSoundLevel
Dim NudgeRightSoundLevel, NudgeCenterSoundLevel, StartButtonSoundLevel, RollingSoundFactor

CoinSoundLevel = 1														'volume level; range [0, 1]
NudgeLeftSoundLevel = 1													'volume level; range [0, 1]
NudgeRightSoundLevel = 1												'volume level; range [0, 1]
NudgeCenterSoundLevel = 1												'volume level; range [0, 1]
StartButtonSoundLevel = 0.1												'volume level; range [0, 1]
PlungerReleaseSoundLevel = 0.8 '1 wjr											'volume level; range [0, 1]
PlungerPullSoundLevel = 1												'volume level; range [0, 1]
RollingSoundFactor = 1.1/5		

'///////////////////////-----Solenoids, Kickers and Flash Relays-----///////////////////////
Dim FlipperUpAttackMinimumSoundLevel, FlipperUpAttackMaximumSoundLevel, FlipperUpAttackLeftSoundLevel, FlipperUpAttackRightSoundLevel
Dim FlipperUpSoundLevel, FlipperDownSoundLevel, FlipperLeftHitParm, FlipperRightHitParm
Dim SlingshotSoundLevel, BumperSoundFactor, KnockerSoundLevel

FlipperUpAttackMinimumSoundLevel = 0.010           						'volume level; range [0, 1]
FlipperUpAttackMaximumSoundLevel = 0.635								'volume level; range [0, 1]
FlipperUpSoundLevel = 1.0                        						'volume level; range [0, 1]
FlipperDownSoundLevel = 0.45                      						'volume level; range [0, 1]
FlipperLeftHitParm = FlipperUpSoundLevel								'sound helper; not configurable
FlipperRightHitParm = FlipperUpSoundLevel								'sound helper; not configurable
SlingshotSoundLevel = 0.95												'volume level; range [0, 1]
BumperSoundFactor = 4.25												'volume multiplier; must not be zero
KnockerSoundLevel = 1 													'volume level; range [0, 1]

'///////////////////////-----Ball Drops, Bumps and Collisions-----///////////////////////
Dim RubberStrongSoundFactor, RubberWeakSoundFactor, RubberFlipperSoundFactor,BallWithBallCollisionSoundFactor
Dim BallBouncePlayfieldSoftFactor, BallBouncePlayfieldHardFactor, PlasticRampDropToPlayfieldSoundLevel, WireRampDropToPlayfieldSoundLevel, DelayedBallDropOnPlayfieldSoundLevel
Dim WallImpactSoundFactor, MetalImpactSoundFactor, SubwaySoundLevel, SubwayEntrySoundLevel, ScoopEntrySoundLevel
Dim SaucerLockSoundLevel, SaucerKickSoundLevel

BallWithBallCollisionSoundFactor = 3.2									'volume multiplier; must not be zero
RubberStrongSoundFactor = 0.055/5											'volume multiplier; must not be zero
RubberWeakSoundFactor = 0.075/5											'volume multiplier; must not be zero
RubberFlipperSoundFactor = 0.075/5										'volume multiplier; must not be zero
BallBouncePlayfieldSoftFactor = 0.025									'volume multiplier; must not be zero
BallBouncePlayfieldHardFactor = 0.025									'volume multiplier; must not be zero
DelayedBallDropOnPlayfieldSoundLevel = 0.8									'volume level; range [0, 1]
WallImpactSoundFactor = 0.075											'volume multiplier; must not be zero
MetalImpactSoundFactor = 0.075/3
SaucerLockSoundLevel = 0.8
SaucerKickSoundLevel = 0.8

'///////////////////////-----Gates, Spinners, Rollovers and Targets-----///////////////////////

Dim GateSoundLevel, TargetSoundFactor, SpinnerSoundLevel, RolloverSoundLevel, DTSoundLevel

GateSoundLevel = 0.5/5													'volume level; range [0, 1]
TargetSoundFactor = 0.0025 * 10											'volume multiplier; must not be zero
DTSoundLevel = 0.25														'volume multiplier; must not be zero
RolloverSoundLevel = 0.25                              					'volume level; range [0, 1]
SpinnerSoundLevel = 0.5                              					'volume level; range [0, 1]

'///////////////////////-----Ball Release, Guides and Drain-----///////////////////////
Dim DrainSoundLevel, BallReleaseSoundLevel, BottomArchBallGuideSoundFactor, FlipperBallGuideSoundFactor 

DrainSoundLevel = 0.8														'volume level; range [0, 1]
BallReleaseSoundLevel = 1												'volume level; range [0, 1]
BottomArchBallGuideSoundFactor = 0.2									'volume multiplier; must not be zero
FlipperBallGuideSoundFactor = 0.015										'volume multiplier; must not be zero

'///////////////////////-----Loops and Lanes-----///////////////////////
Dim ArchSoundFactor
ArchSoundFactor = 0.025/5													'volume multiplier; must not be zero


'/////////////////////////////  SOUND PLAYBACK FUNCTIONS  ////////////////////////////
'/////////////////////////////  POSITIONAL SOUND PLAYBACK METHODS  ////////////////////////////
' Positional sound playback methods will play a sound, depending on the X,Y position of the table element or depending on ActiveBall object position
' These are similar subroutines that are less complicated to use (e.g. simply use standard parameters for the PlaySound call)
' For surround setup - positional sound playback functions will fade between front and rear surround channels and pan between left and right channels
' For stereo setup - positional sound playback functions will only pan between left and right channels
' For mono setup - positional sound playback functions will not pan between left and right channels and will not fade between front and rear channels

' PlaySound full syntax - PlaySound(string, int loopcount, float volume, float pan, float randompitch, int pitch, bool useexisting, bool restart, float front_rear_fade)
' Note - These functions will not work (currently) for walls/slingshots as these do not feature a simple, single X,Y position
Sub PlaySoundAtLevelStatic(playsoundparams, aVol, tableobj)
	PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(tableobj), 0, 0, 0, 0, AudioFade(tableobj)
End Sub

Sub PlaySoundAtLevelExistingStatic(playsoundparams, aVol, tableobj)
	PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(tableobj), 0, 0, 1, 0, AudioFade(tableobj)
End Sub

Sub PlaySoundAtLevelStaticLoop(playsoundparams, aVol, tableobj)
	PlaySound playsoundparams, -1, aVol * VolumeDial, AudioPan(tableobj), 0, 0, 0, 0, AudioFade(tableobj)
End Sub

Sub PlaySoundAtLevelStaticRandomPitch(playsoundparams, aVol, randomPitch, tableobj)
	PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(tableobj), randomPitch, 0, 0, 0, AudioFade(tableobj)
End Sub

Sub PlaySoundAtLevelActiveBall(playsoundparams, aVol)
	PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(ActiveBall), 0, 0, 0, 0, AudioFade(ActiveBall)
End Sub

Sub PlaySoundAtLevelExistingActiveBall(playsoundparams, aVol)
	PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(ActiveBall), 0, 0, 1, 0, AudioFade(ActiveBall)
End Sub

Sub PlaySoundAtLeveTimerActiveBall(playsoundparams, aVol, ballvariable)
	PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(ballvariable), 0, 0, 0, 0, AudioFade(ballvariable)
End Sub

Sub PlaySoundAtLevelTimerExistingActiveBall(playsoundparams, aVol, ballvariable)
	PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(ballvariable), 0, 0, 1, 0, AudioFade(ballvariable)
End Sub

Sub PlaySoundAtLevelRoll(playsoundparams, aVol, pitch)
	PlaySound playsoundparams, -1, aVol * VolumeDial, AudioPan(tableobj), randomPitch, 0, 0, 0, AudioFade(tableobj)
End Sub

' Previous Positional Sound Subs

Sub PlaySoundAt(soundname, tableobj)
	PlaySound soundname, 1, 1 * VolumeDial, AudioPan(tableobj), 0,0,0, 1, AudioFade(tableobj)
End Sub

Sub PlaySoundAtVol(soundname, tableobj, aVol)
	PlaySound soundname, 1, aVol * VolumeDial, AudioPan(tableobj), 0,0,0, 1, AudioFade(tableobj)
End Sub

Sub PlaySoundAtBall(soundname)
	PlaySoundAt soundname, ActiveBall
End Sub

Sub PlaySoundAtBallVol (Soundname, aVol)
	Playsound soundname, 1,aVol * VolumeDial, AudioPan(ActiveBall), 0,0,0, 1, AudioFade(ActiveBall)
End Sub

Sub PlaySoundAtBallVolM (Soundname, aVol)
	Playsound soundname, 1,aVol * VolumeDial, AudioPan(ActiveBall), 0,0,0, 0, AudioFade(ActiveBall)
End Sub

Sub PlaySoundAtVolLoops(sound, tableobj, Vol, Loops)
	PlaySound sound, Loops, Vol * VolumeDial, AudioPan(tableobj), 0,0,0, 1, AudioFade(tableobj)
End Sub


'******************************************************
'  Fleep  Supporting Ball & Sound Functions
'******************************************************

Function AudioFade(tableobj) ' Fades between front and back of the table (for surround systems or 2x2 speakers, etc), depending on the Y position on the table. "table1" is the name of the table
  Dim tmp
    tmp = tableobj.y * 2 / tableheight-1

	if tmp > 7000 Then
		tmp = 7000
	elseif tmp < -7000 Then
		tmp = -7000
	end if

    If tmp > 0 Then
		AudioFade = Csng(tmp ^10)
    Else
        AudioFade = Csng(-((- tmp) ^10) )
    End If
End Function

Function AudioPan(tableobj) ' Calculates the pan for a tableobj based on the X position on the table. "table1" is the name of the table
    Dim tmp
    tmp = tableobj.x * 2 / tablewidth-1

	if tmp > 7000 Then
		tmp = 7000
	elseif tmp < -7000 Then
		tmp = -7000
	end if

    If tmp > 0 Then
        AudioPan = Csng(tmp ^10)
    Else
        AudioPan = Csng(-((- tmp) ^10) )
    End If
End Function

Function Vol(ball) ' Calculates the volume of the sound based on the ball speed
	Vol = Csng(BallVel(ball) ^2)
End Function

Function Volz(ball) ' Calculates the volume of the sound based on the ball speed
	Volz = Csng((ball.velz) ^2)
End Function

Function Pitch(ball) ' Calculates the pitch of the sound based on the ball speed
	Pitch = BallVel(ball) * 20
End Function

Function BallVel(ball) 'Calculates the ball speed
	BallVel = INT(SQR((ball.VelX ^2) + (ball.VelY ^2) ) )
End Function

Function VolPlayfieldRoll(ball) ' Calculates the roll volume of the sound based on the ball speed
	VolPlayfieldRoll = RollingSoundFactor * 0.0005 * Csng(BallVel(ball) ^3)
End Function

Function PitchPlayfieldRoll(ball) ' Calculates the roll pitch of the sound based on the ball speed
	PitchPlayfieldRoll = BallVel(ball) ^2 * 15
End Function

Function RndInt(min, max)
	RndInt = Int(Rnd() * (max-min + 1) + min)' Sets a random number integer between min and max
End Function

Function RndNum(min, max)
	RndNum = Rnd() * (max-min) + min' Sets a random number between min and max
End Function

'/////////////////////////////  GENERAL SOUND SUBROUTINES  ////////////////////////////
Sub SoundStartButton()
	PlaySound ("Start_Button"), 0, StartButtonSoundLevel, 0, 0.25
End Sub

Sub SoundNudgeLeft()
	PlaySound ("Nudge_" & Int(Rnd*2)+1), 0, NudgeLeftSoundLevel * VolumeDial, -0.1, 0.25
End Sub

Sub SoundNudgeRight()
	PlaySound ("Nudge_" & Int(Rnd*2)+1), 0, NudgeRightSoundLevel * VolumeDial, 0.1, 0.25
End Sub

Sub SoundNudgeCenter()
	PlaySound ("Nudge_" & Int(Rnd*2)+1), 0, NudgeCenterSoundLevel * VolumeDial, 0, 0.25
End Sub


Sub SoundPlungerPull()
	PlaySoundAtLevelStatic ("Plunger_Pull_1"), PlungerPullSoundLevel, Plunger
End Sub

Sub SoundPlungerReleaseBall()
	PlaySoundAtLevelStatic ("Plunger_Release_Ball"), PlungerReleaseSoundLevel, Plunger	
End Sub

Sub SoundPlungerReleaseNoBall()
	PlaySoundAtLevelStatic ("Plunger_Release_No_Ball"), PlungerReleaseSoundLevel, Plunger
End Sub


'/////////////////////////////  KNOCKER SOLENOID  ////////////////////////////
Sub KnockerSolenoid()
	PlaySoundAtLevelStatic SoundFX("Knocker_1",DOFKnocker), KnockerSoundLevel, KnockerPosition
End Sub

'/////////////////////////////  DRAIN SOUNDS  ////////////////////////////
Sub RandomSoundDrain(drainswitch)
	PlaySoundAtLevelStatic ("Drain_" & Int(Rnd*11)+1), DrainSoundLevel, drainswitch
End Sub

'/////////////////////////////  TROUGH BALL RELEASE SOLENOID SOUNDS  ////////////////////////////

Sub RandomSoundBallRelease(drainswitch)
	PlaySoundAtLevelStatic SoundFX("BallRelease" & Int(Rnd*7)+1,DOFContactors), BallReleaseSoundLevel, drainswitch
End Sub

'/////////////////////////////  SLINGSHOT SOLENOID SOUNDS  ////////////////////////////
Sub RandomSoundSlingshotLeft(sling)
	PlaySoundAtLevelStatic SoundFX("Sling_L" & Int(Rnd*10)+1,DOFContactors), SlingshotSoundLevel, Sling
End Sub

Sub RandomSoundSlingshotRight(sling)
	PlaySoundAtLevelStatic SoundFX("Sling_R" & Int(Rnd*8)+1,DOFContactors), SlingshotSoundLevel, Sling
End Sub

'/////////////////////////////  SLINGSHOT SOLENOID SOUNDS  ////////////////////////////
Const Cartridge_Slingshots				= "WS_WHD_REV01"
Dim Solenoid_Slingshot_SoundLevel
Solenoid_Slingshot_SoundLevel = 0.6
Sub RandomSoundSlingshotupLeft()
	PlaySoundAtLevelStatic SoundFX(Cartridge_Slingshots & "_Slingshot_Left_" & Int(Rnd*7)+1,DOFContactors), Solenoid_Slingshot_SoundLevel, Slingsw12
End Sub

Sub RandomSoundSlingshotupRight()
	PlaySoundAtLevelStatic SoundFX(Cartridge_Slingshots & "_Slingshot_Right_" & Int(Rnd*7)+1,DOFContactors), Solenoid_Slingshot_SoundLevel, Slingsw13
End Sub


'/////////////////////////////  BUMPER SOLENOID SOUNDS  ////////////////////////////
Sub RandomSoundBumperTop(Bump)
	PlaySoundAtLevelStatic SoundFX("Bumpers_Top_" & Int(Rnd*5)+1,DOFContactors), Vol(ActiveBall) * BumperSoundFactor, Bump
End Sub

Sub RandomSoundBumperMiddle(Bump)
	PlaySoundAtLevelStatic SoundFX("Bumpers_Middle_" & Int(Rnd*5)+1,DOFContactors), Vol(ActiveBall) * BumperSoundFactor, Bump
End Sub

Sub RandomSoundBumperBottom(Bump)
	PlaySoundAtLevelStatic SoundFX("Bumpers_Bottom_" & Int(Rnd*5)+1,DOFContactors), Vol(ActiveBall) * BumperSoundFactor, Bump
End Sub


'/////////////////////////////  SPINNER SOUNDS  ////////////////////////////
Sub SoundSpinner(spinnerswitch)
	PlaySoundAtLevelStatic ("Spinner"), SpinnerSoundLevel, spinnerswitch
End Sub


'/////////////////////////////  FLIPPER BATS SOUND SUBROUTINES  ////////////////////////////
'/////////////////////////////  FLIPPER BATS SOLENOID ATTACK SOUND  ////////////////////////////
Sub SoundFlipperUpAttackLeft(flipper)
	FlipperUpAttackLeftSoundLevel = RndNum(FlipperUpAttackMinimumSoundLevel, FlipperUpAttackMaximumSoundLevel)
	PlaySoundAtLevelStatic ("Flipper_Attack-L01"), FlipperUpAttackLeftSoundLevel, flipper
End Sub

Sub SoundFlipperUpAttackRight(flipper)
	FlipperUpAttackRightSoundLevel = RndNum(FlipperUpAttackMinimumSoundLevel, FlipperUpAttackMaximumSoundLevel)
	PlaySoundAtLevelStatic ("Flipper_Attack-R01"), FlipperUpAttackLeftSoundLevel, flipper
End Sub

'/////////////////////////////  FLIPPER BATS SOLENOID CORE SOUND  ////////////////////////////
Sub RandomSoundFlipperUpLeft(flipper)
	PlaySoundAtLevelStatic SoundFX("Flipper_L0" & Int(Rnd*9)+1,DOFFlippers), FlipperLeftHitParm, Flipper
End Sub

Sub RandomSoundFlipperUpRight(flipper)
	PlaySoundAtLevelStatic SoundFX("Flipper_R0" & Int(Rnd*9)+1,DOFFlippers), FlipperRightHitParm, Flipper
End Sub

Sub RandomSoundReflipUpLeft(flipper)
	PlaySoundAtLevelStatic SoundFX("Flipper_ReFlip_L0" & Int(Rnd*3)+1,DOFFlippers), (RndNum(0.8, 1))*FlipperUpSoundLevel, Flipper
End Sub

Sub RandomSoundReflipUpRight(flipper)
	PlaySoundAtLevelStatic SoundFX("Flipper_ReFlip_R0" & Int(Rnd*3)+1,DOFFlippers), (RndNum(0.8, 1))*FlipperUpSoundLevel, Flipper
End Sub

Sub RandomSoundFlipperDownLeft(flipper)
	PlaySoundAtLevelStatic SoundFX("Flipper_Left_Down_" & Int(Rnd*7)+1,DOFFlippers), FlipperDownSoundLevel, Flipper
End Sub

Sub RandomSoundFlipperDownRight(flipper)
	PlaySoundAtLevelStatic SoundFX("Flipper_Right_Down_" & Int(Rnd*8)+1,DOFFlippers), FlipperDownSoundLevel, Flipper
End Sub

'/////////////////////////////  FLIPPER BATS BALL COLLIDE SOUND  ////////////////////////////

Sub LeftFlipperCollide(parm)
	FlipperLeftHitParm = parm/10
	If FlipperLeftHitParm > 1 Then
		FlipperLeftHitParm = 1
	End If
	FlipperLeftHitParm = FlipperUpSoundLevel * FlipperLeftHitParm
	RandomSoundRubberFlipper(parm)
End Sub

Sub RightFlipperCollide(parm)
	FlipperRightHitParm = parm/10
	If FlipperRightHitParm > 1 Then
		FlipperRightHitParm = 1
	End If
	FlipperRightHitParm = FlipperUpSoundLevel * FlipperRightHitParm
	RandomSoundRubberFlipper(parm)
End Sub

Sub RandomSoundRubberFlipper(parm)
	PlaySoundAtLevelActiveBall ("Flipper_Rubber_" & Int(Rnd*7)+1), parm  * RubberFlipperSoundFactor
End Sub

'/////////////////////////////  ROLLOVER SOUNDS  ////////////////////////////
Sub RandomSoundRollover()
	PlaySoundAtLevelActiveBall ("Rollover_" & Int(Rnd*4)+1), RolloverSoundLevel
End Sub

Sub Rollovers_Hit(idx)
	RandomSoundRollover
End Sub

'/////////////////////////////  VARIOUS PLAYFIELD SOUND SUBROUTINES  ////////////////////////////
'/////////////////////////////  RUBBERS AND POSTS  ////////////////////////////
'/////////////////////////////  RUBBERS - EVENTS  ////////////////////////////
Sub Rubbers_Hit(idx)
	dim finalspeed
	finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
	If finalspeed > 5 then		
		RandomSoundRubberStrong 1
	End if
	If finalspeed <= 5 then
		RandomSoundRubberWeak()
	End If	
End Sub

'/////////////////////////////  RUBBERS AND POSTS - STRONG IMPACTS  ////////////////////////////
Sub RandomSoundRubberStrong(voladj)
	Select Case Int(Rnd*10)+1
		Case 1 : PlaySoundAtLevelActiveBall ("Rubber_Strong_1"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
		Case 2 : PlaySoundAtLevelActiveBall ("Rubber_Strong_2"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
		Case 3 : PlaySoundAtLevelActiveBall ("Rubber_Strong_3"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
		Case 4 : PlaySoundAtLevelActiveBall ("Rubber_Strong_4"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
		Case 5 : PlaySoundAtLevelActiveBall ("Rubber_Strong_5"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
		Case 6 : PlaySoundAtLevelActiveBall ("Rubber_Strong_6"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
		Case 7 : PlaySoundAtLevelActiveBall ("Rubber_Strong_7"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
		Case 8 : PlaySoundAtLevelActiveBall ("Rubber_Strong_8"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
		Case 9 : PlaySoundAtLevelActiveBall ("Rubber_Strong_9"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
		Case 10 : PlaySoundAtLevelActiveBall ("Rubber_1_Hard"), Vol(ActiveBall) * RubberStrongSoundFactor * 0.6*voladj
	End Select
End Sub

'/////////////////////////////  RUBBERS AND POSTS - WEAK IMPACTS  ////////////////////////////
Sub RandomSoundRubberWeak()
	PlaySoundAtLevelActiveBall ("Rubber_" & Int(Rnd*9)+1), Vol(ActiveBall) * RubberWeakSoundFactor
End Sub

'/////////////////////////////  WALL IMPACTS  ////////////////////////////
Sub Walls_Hit(idx)
	RandomSoundWall()      
End Sub

Sub RandomSoundWall()
	dim finalspeed
	finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
	If finalspeed > 16 then 
		Select Case Int(Rnd*5)+1
			Case 1 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_1"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 2 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_2"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 3 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_5"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 4 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_7"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 5 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_9"), Vol(ActiveBall) * WallImpactSoundFactor
		End Select
	End if
	If finalspeed >= 6 AND finalspeed <= 16 then
		Select Case Int(Rnd*4)+1
			Case 1 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_3"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 2 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_4"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 3 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_6"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 4 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_8"), Vol(ActiveBall) * WallImpactSoundFactor
		End Select
	End If
	If finalspeed < 6 Then
		Select Case Int(Rnd*3)+1
			Case 1 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_4"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 2 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_6"), Vol(ActiveBall) * WallImpactSoundFactor
			Case 3 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_8"), Vol(ActiveBall) * WallImpactSoundFactor
		End Select
	End if
End Sub

'/////////////////////////////  METAL TOUCH SOUNDS  ////////////////////////////
Sub RandomSoundMetal()
	PlaySoundAtLevelActiveBall ("Metal_Touch_" & Int(Rnd*13)+1), Vol(ActiveBall) * MetalImpactSoundFactor
End Sub

'/////////////////////////////  METAL - EVENTS  ////////////////////////////

Sub Metals_Hit (idx)
	RandomSoundMetal
End Sub

Sub ShooterDiverter_collide(idx)
	RandomSoundMetal
End Sub

'/////////////////////////////  BOTTOM ARCH BALL GUIDE  ////////////////////////////
'/////////////////////////////  BOTTOM ARCH BALL GUIDE - SOFT BOUNCES  ////////////////////////////
Sub RandomSoundBottomArchBallGuide()
	dim finalspeed
	finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
	If finalspeed > 16 then 
		PlaySoundAtLevelActiveBall ("Apron_Bounce_"& Int(Rnd*2)+1), Vol(ActiveBall) * BottomArchBallGuideSoundFactor
	End if
	If finalspeed >= 6 AND finalspeed <= 16 then
		Select Case Int(Rnd*2)+1
			Case 1 : PlaySoundAtLevelActiveBall ("Apron_Bounce_1"), Vol(ActiveBall) * BottomArchBallGuideSoundFactor
			Case 2 : PlaySoundAtLevelActiveBall ("Apron_Bounce_Soft_1"), Vol(ActiveBall) * BottomArchBallGuideSoundFactor
		End Select
	End If
	If finalspeed < 6 Then
		Select Case Int(Rnd*2)+1
			Case 1 : PlaySoundAtLevelActiveBall ("Apron_Bounce_Soft_1"), Vol(ActiveBall) * BottomArchBallGuideSoundFactor
			Case 2 : PlaySoundAtLevelActiveBall ("Apron_Medium_3"), Vol(ActiveBall) * BottomArchBallGuideSoundFactor
		End Select
	End if
End Sub

'/////////////////////////////  BOTTOM ARCH BALL GUIDE - HARD HITS  ////////////////////////////
Sub RandomSoundBottomArchBallGuideHardHit()
	PlaySoundAtLevelActiveBall ("Apron_Hard_Hit_" & Int(Rnd*3)+1), BottomArchBallGuideSoundFactor * 0.25
End Sub

Sub Aapron_Hit (idx)
	If Abs(cor.ballvelx(activeball.id) < 4) and cor.ballvely(activeball.id) > 7 then
		RandomSoundBottomArchBallGuideHardHit()
	Else
		RandomSoundBottomArchBallGuide
	End If
End Sub

'/////////////////////////////  FLIPPER BALL GUIDE  ////////////////////////////
Sub RandomSoundFlipperBallGuide()
	dim finalspeed
	finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
	If finalspeed > 16 then 
		Select Case Int(Rnd*2)+1
			Case 1 : PlaySoundAtLevelActiveBall ("Apron_Hard_1"),  Vol(ActiveBall) * FlipperBallGuideSoundFactor
			Case 2 : PlaySoundAtLevelActiveBall ("Apron_Hard_2"),  Vol(ActiveBall) * 0.8 * FlipperBallGuideSoundFactor
		End Select
	End if
	If finalspeed >= 6 AND finalspeed <= 16 then
		PlaySoundAtLevelActiveBall ("Apron_Medium_" & Int(Rnd*3)+1),  Vol(ActiveBall) * FlipperBallGuideSoundFactor
	End If
	If finalspeed < 6 Then
		PlaySoundAtLevelActiveBall ("Apron_Soft_" & Int(Rnd*7)+1),  Vol(ActiveBall) * FlipperBallGuideSoundFactor
	End If
End Sub

'/////////////////////////////  TARGET HIT SOUNDS  ////////////////////////////
Sub RandomSoundTargetHitStrong()
	PlaySoundAtLevelActiveBall SoundFX("Target_Hit_" & Int(Rnd*4)+5,DOFTargets), Vol(ActiveBall) * 0.45 * TargetSoundFactor
End Sub

Sub RandomSoundTargetHitWeak()		
	PlaySoundAtLevelActiveBall SoundFX("Target_Hit_" & Int(Rnd*4)+1,DOFTargets), Vol(ActiveBall) * TargetSoundFactor
End Sub

Sub PlayTargetSound()
	dim finalspeed
	finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
	If finalspeed > 10 then
		RandomSoundTargetHitStrong()
		RandomSoundBallBouncePlayfieldSoft Activeball
	Else 
		RandomSoundTargetHitWeak()
	End If	
End Sub

Sub Targets_Hit (idx)
	PlayTargetSound	
End Sub

'/////////////////////////////  BALL BOUNCE SOUNDS  ////////////////////////////
Sub RandomSoundBallBouncePlayfieldSoft(aBall)
	Select Case Int(Rnd*9)+1
		Case 1 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Soft_1"), volz(aBall) * BallBouncePlayfieldSoftFactor, aBall
		Case 2 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Soft_2"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.5, aBall
		Case 3 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Soft_3"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.8, aBall
		Case 4 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Soft_4"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.5, aBall
		Case 5 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Soft_5"), volz(aBall) * BallBouncePlayfieldSoftFactor, aBall
		Case 6 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Hard_1"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.2, aBall
		Case 7 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Hard_2"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.2, aBall
		Case 8 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Hard_5"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.2, aBall
		Case 9 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Hard_7"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.3, aBall
	End Select
End Sub

Sub RandomSoundBallBouncePlayfieldHard(aBall)
	PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Hard_" & Int(Rnd*7)+1), volz(aBall) * BallBouncePlayfieldHardFactor, aBall
End Sub

'/////////////////////////////  DELAYED DROP - TO PLAYFIELD - SOUND  ////////////////////////////
Sub RandomSoundDelayedBallDropOnPlayfield(aBall)
	Select Case Int(Rnd*5)+1
		Case 1 : PlaySoundAtLevelStatic ("Ball_Drop_Playfield_1_Delayed"), DelayedBallDropOnPlayfieldSoundLevel, aBall
		Case 2 : PlaySoundAtLevelStatic ("Ball_Drop_Playfield_2_Delayed"), DelayedBallDropOnPlayfieldSoundLevel, aBall
		Case 3 : PlaySoundAtLevelStatic ("Ball_Drop_Playfield_3_Delayed"), DelayedBallDropOnPlayfieldSoundLevel, aBall
		Case 4 : PlaySoundAtLevelStatic ("Ball_Drop_Playfield_4_Delayed"), DelayedBallDropOnPlayfieldSoundLevel, aBall
		Case 5 : PlaySoundAtLevelStatic ("Ball_Drop_Playfield_5_Delayed"), DelayedBallDropOnPlayfieldSoundLevel, aBall
	End Select
End Sub

'/////////////////////////////  BALL GATES AND BRACKET GATES SOUNDS  ////////////////////////////

Sub SoundPlayfieldGate()			
	PlaySoundAtLevelStatic ("Gate_FastTrigger_" & Int(Rnd*2)+1), GateSoundLevel, Activeball
End Sub

Sub SoundHeavyGate()
	PlaySoundAtLevelStatic ("Gate_2"), GateSoundLevel, Activeball
End Sub

Sub Gates_hit(idx)
	SoundHeavyGate
End Sub

Sub GatesWire_hit(idx)	
	SoundPlayfieldGate	
End Sub	

'/////////////////////////////  LEFT LANE ENTRANCE - SOUNDS  ////////////////////////////

Sub RandomSoundLeftArch()
	PlaySoundAtLevelActiveBall ("Arch_L" & Int(Rnd*4)+1), Vol(ActiveBall) * ArchSoundFactor
End Sub

Sub RandomSoundRightArch()
	PlaySoundAtLevelActiveBall ("Arch_R" & Int(Rnd*4)+1), Vol(ActiveBall) * ArchSoundFactor
End Sub


Sub Arch1_hit()
	If Activeball.velx > 1 Then SoundPlayfieldGate
	StopSound "Arch_L1"
	StopSound "Arch_L2"
	StopSound "Arch_L3"
	StopSound "Arch_L4"
End Sub

Sub Arch1_unhit()
	If activeball.velx < -8 Then
		RandomSoundRightArch
	End If
End Sub

Sub Arch2_hit()
	If Activeball.velx < 1 Then SoundPlayfieldGate
	StopSound "Arch_R1"
	StopSound "Arch_R2"
	StopSound "Arch_R3"
	StopSound "Arch_R4"
End Sub

Sub Arch2_unhit()
	If activeball.velx > 10 Then
		RandomSoundLeftArch
	End If
End Sub

'/////////////////////////////  SAUCERS (KICKER HOLES)  ////////////////////////////

Sub SoundSaucerLock()
	PlaySoundAtLevelStatic ("Saucer_Enter_" & Int(Rnd*2)+1), SaucerLockSoundLevel, Activeball
End Sub

Sub SoundSaucerKick(scenario, saucer)
	Select Case scenario
		Case 0: PlaySoundAtLevelStatic SoundFX("Saucer_Empty", DOFContactors), SaucerKickSoundLevel, saucer
		Case 1: PlaySoundAtLevelStatic SoundFX("Saucer_Kick", DOFContactors), SaucerKickSoundLevel, saucer
	End Select
End Sub

'/////////////////////////////  BALL COLLISION SOUND  ////////////////////////////
Sub OnBallBallCollision(ball1, ball2, velocity)
	Dim snd
	Select Case Int(Rnd*7)+1
		Case 1 : snd = "Ball_Collide_1"
		Case 2 : snd = "Ball_Collide_2"
		Case 3 : snd = "Ball_Collide_3"
		Case 4 : snd = "Ball_Collide_4"
		Case 5 : snd = "Ball_Collide_5"
		Case 6 : snd = "Ball_Collide_6"
		Case 7 : snd = "Ball_Collide_7"
	End Select

	PlaySound (snd), 0, Csng(velocity) ^2 / 200 * BallWithBallCollisionSoundFactor * VolumeDial, AudioPan(ball1), 0, Pitch(ball1), 0, 0, AudioFade(ball1)
End Sub


'///////////////////////////  DROP TARGET HIT SOUNDS  ///////////////////////////

'Sub RandomSoundDropTargetReset(obj)
'	PlaySoundAtLevelStatic SoundFX("Drop_Target_Reset_" & Int(Rnd*6)+1,DOFContactors), 1, obj
'End Sub

'Sub SoundDropTargetDrop(obj)
'	PlaySoundAtLevelStatic ("Drop_Target_Down_" & Int(Rnd*6)+1), 200, obj
'End Sub

'/////////////////////////////  GI AND FLASHER RELAYS  ////////////////////////////

Const RelayFlashSoundLevel = 0.315									'volume level; range [0, 1];
Const RelayGISoundLevel = 1.05									'volume level; range [0, 1];

Sub Sound_GI_Relay(toggle, obj)
	Select Case toggle
		Case 1
			PlaySoundAtLevelStatic ("Relay_GI_On"), 0.025*RelayGISoundLevel, obj
		Case 0
			PlaySoundAtLevelStatic ("Relay_GI_Off"), 0.025*RelayGISoundLevel, obj
	End Select
End Sub

Sub Sound_Flash_Relay(toggle, obj)
	Select Case toggle
		Case 1
			PlaySoundAtLevelStatic ("Relay_Flash_On"), 0.025*RelayFlashSoundLevel, obj			
		Case 0
			PlaySoundAtLevelStatic ("Relay_Flash_Off"), 0.025*RelayFlashSoundLevel, obj		
	End Select
End Sub

'/////////////////////////////////////////////////////////////////
'					End Mechanical Sounds
'/////////////////////////////////////////////////////////////////

'******************************************************
'****  FLEEP MECHANICAL SOUNDS
'******************************************************


'******************************************************
'                TRACK ALL BALL VELOCITIES
'                 FOR RUBBER DAMPENER AND DROP TARGETS
'******************************************************

dim cor : set cor = New CoRTracker

Class CoRTracker
	public ballvel, ballvelx, ballvely

	Private Sub Class_Initialize : redim ballvel(0) : redim ballvelx(0): redim ballvely(0) : End Sub 

	Public Sub Update()	'tracks in-ball-velocity
		dim str, b, AllBalls, highestID : allBalls = getballs

		for each b in allballs
			if b.id >= HighestID then highestID = b.id
		Next

		if uBound(ballvel) < highestID then redim ballvel(highestID)	'set bounds
		if uBound(ballvelx) < highestID then redim ballvelx(highestID)	'set bounds
		if uBound(ballvely) < highestID then redim ballvely(highestID)	'set bounds

		for each b in allballs
			ballvel(b.id) = BallSpeed(b)
			ballvelx(b.id) = b.velx
			ballvely(b.id) = b.vely
		Next
	End Sub
End Class

Function BallSpeed(ball) 'Calculates the ball speed
	BallSpeed = SQR(ball.VelX^2 + ball.VelY^2 + ball.VelZ^2)
End Function

'******************************************************
'  SLINGSHOT CORRECTION FUNCTIONS
'******************************************************
' To add these slingshot corrections:
' 	- On the table, add the endpoint primitives that define the two ends of the Slingshot
'	- Initialize the SlingshotCorrection objects in InitSlingCorrection
' 	- Call the .VelocityCorrect methods from the respective _Slingshot event sub


dim LS : Set LS = New SlingshotCorrection
dim RS : Set RS = New SlingshotCorrection

InitSlingCorrection

Sub InitSlingCorrection

	LS.Object = LeftSlingshot
	LS.EndPoint1 = EndPoint1LS
	LS.EndPoint2 = EndPoint2LS

	RS.Object = RightSlingshot
	RS.EndPoint1 = EndPoint1RS
	RS.EndPoint2 = EndPoint2RS

	'Slingshot angle corrections (pt, BallPos in %, Angle in deg)
	' These values are best guesses. Retune them if needed based on specific table research.
	AddSlingsPt 0, 0.00,	-4
	AddSlingsPt 1, 0.45,	-7
	AddSlingsPt 2, 0.48,	0
	AddSlingsPt 3, 0.52,	0
	AddSlingsPt 4, 0.55,	7
	AddSlingsPt 5, 1.00,	4

End Sub


Sub AddSlingsPt(idx, aX, aY)        'debugger wrapper for adjusting flipper script in-game
	dim a : a = Array(LS, RS)
	dim x : for each x in a
		x.addpoint idx, aX, aY
	Next
End Sub

'' The following sub are needed, however they may exist somewhere else in the script. Uncomment below if needed
'Dim PI: PI = 4*Atn(1)
'Function dSin(degrees)
'	dsin = sin(degrees * Pi/180)
'End Function
'Function dCos(degrees)
'	dcos = cos(degrees * Pi/180)
'End Function
'

' If Function RotPoint exist somewhere else in the script. Uncomment below if needed
'Function RotPoint(x,y,angle)
'    dim rx, ry
'   rx = x*dCos(angle) - y*dSin(angle)
'   ry = x*dSin(angle) + y*dCos(angle)
'    RotPoint = Array(rx,ry)
'End Function

Class SlingshotCorrection
	Public DebugOn, Enabled
	private Slingshot, SlingX1, SlingX2, SlingY1, SlingY2

	Public ModIn, ModOut
	Private Sub Class_Initialize : redim ModIn(0) : redim Modout(0): Enabled = True : End Sub 

	Public Property let Object(aInput) : Set Slingshot = aInput : End Property
	Public Property Let EndPoint1(aInput) : SlingX1 = aInput.x: SlingY1 = aInput.y: End Property
	Public Property Let EndPoint2(aInput) : SlingX2 = aInput.x: SlingY2 = aInput.y: End Property

	Public Sub AddPoint(aIdx, aX, aY) 
		ShuffleArrays ModIn, ModOut, 1 : ModIn(aIDX) = aX : ModOut(aIDX) = aY : ShuffleArrays ModIn, ModOut, 0
		If gametime > 100 then Report
	End Sub

	Public Sub Report()         'debug, reports all coords in tbPL.text
		If not debugOn then exit sub
		dim a1, a2 : a1 = ModIn : a2 = ModOut
		dim str, x : for x = 0 to uBound(a1) : str = str & x & ": " & round(a1(x),4) & ", " & round(a2(x),4) & vbnewline : next
		TBPout.text = str
	End Sub


	Public Sub VelocityCorrect(aBall)
		dim BallPos, XL, XR, YL, YR
		
		'Assign right and left end points
		If SlingX1 < SlingX2 Then 
			XL = SlingX1 : YL = SlingY1 : XR = SlingX2 : YR = SlingY2
		Else
			XL = SlingX2 : YL = SlingY2 : XR = SlingX1 : YR = SlingY1
		End If

		'Find BallPos = % on Slingshot
		If Not IsEmpty(aBall.id) Then 
			If ABS(XR-XL) > ABS(YR-YL) Then 
				BallPos = PSlope(aBall.x, XL, 0, XR, 1)
			Else
				BallPos = PSlope(aBall.y, YL, 0, YR, 1)
			End If
			If BallPos < 0 Then BallPos = 0
			If BallPos > 1 Then BallPos = 1
		End If

		'Velocity angle correction
		If not IsEmpty(ModIn(0) ) then
			Dim Angle, RotVxVy
			Angle = LinearEnvelope(BallPos, ModIn, ModOut)
			'debug.print " BallPos=" & BallPos &" Angle=" & Angle 
			'debug.print " BEFORE: aBall.Velx=" & aBall.Velx &" aBall.Vely" & aBall.Vely 
			RotVxVy = RotPoint(aBall.Velx,aBall.Vely,Angle)
			If Enabled then aBall.Velx = RotVxVy(0)
			If Enabled then aBall.Vely = RotVxVy(1)
			'debug.print " AFTER: aBall.Velx=" & aBall.Velx &" aBall.Vely" & aBall.Vely 
			'debug.print " " 
		End If
	End Sub

End Class


'******************************************************
'****  DROP TARGETS by Rothbauerw
'******************************************************
' This solution improves the physics for drop targets to create more realistic behavior. It allows the ball 
' to move through the target enabling the ability to score more than one target with a well placed shot.
' It also handles full drop target animation, including deflection on hit and a slight lift when the drop 
' targets raise, switch handling, bricking, and popping the ball up if it's over the drop target when it raises.
'
'Add a Timer named DTAnim to editor to handle drop & standup target animations, or run them off an always-on 10ms timer (GameTimer)
'DTAnim.interval = 10
'DTAnim.enabled = True

'Sub DTAnim_Timer
'	DoDTAnim
'	DoSTAnim
'End Sub

' For each drop target, we'll use two wall objects for physics calculations and one primitive for visuals and   
' animation. We will not use target objects.  Place your drop target primitive the same as you would a VP drop target. 
' The primitive should have it's pivot point centered on the x and y axis and at or just below the playfield 
' level on the z axis. Orientation needs to be set using Rotz and bending deflection using Rotx. You'll find a hooded 
' target mesh in this table's example. It uses the same texture map as the VP drop targets.


'******************************************************
'  DROP TARGETS INITIALIZATION
'******************************************************

Class DropTarget
  Private m_primary, m_secondary, m_prim, m_sw, m_animate, m_isDropped

  Public Property Get Primary(): Set Primary = m_primary: End Property
  Public Property Let Primary(input): Set m_primary = input: End Property

  Public Property Get Secondary(): Set Secondary = m_secondary: End Property
  Public Property Let Secondary(input): Set m_secondary = input: End Property

  Public Property Get Prim(): Set Prim = m_prim: End Property
  Public Property Let Prim(input): Set m_prim = input: End Property

  Public Property Get Sw(): Sw = m_sw: End Property
  Public Property Let Sw(input): m_sw = input: End Property

  Public Property Get Animate(): Animate = m_animate: End Property
  Public Property Let Animate(input): m_animate = input: End Property

  Public Property Get IsDropped(): IsDropped = m_isDropped: End Property
  Public Property Let IsDropped(input): m_isDropped = input: End Property

  Public default Function init(primary, secondary, prim, sw, animate, isDropped)
    Set m_primary = primary
    Set m_secondary = secondary
    Set m_prim = prim
    m_sw = sw
    m_animate = animate
    m_isDropped = isDropped

    Set Init = Me
  End Function
End Class


'Define a variable for each drop target
Dim DT36,DT35,DT25,DT34,DT24,DT33,DT23,DT20,DT30,DT21,DT31,DT22,DT32,DT26

'Set array with drop target objects
'
'DropTargetvar = Array(primary, secondary, prim, swtich, animate)
' 	primary: 			primary target wall to determine drop
'	secondary:			wall used to simulate the ball striking a bent or offset target after the initial Hit
'	prim:				primitive target used for visuals and animation
'							IMPORTANT!!! 
'							rotz must be used for orientation
'							rotx to bend the target back
'							transz to move it up and down
'							the pivot point should be in the center of the target on the x, y and at or below the playfield (0) on z
'	switch:				ROM switch number
'	animate:			Arrary slot for handling the animation instrucitons, set to 0
'
'	Values for annimate: 1 - bend target (hit to primary), 2 - drop target (hit to secondary), 3 - brick target (high velocity hit to secondary), -1 - raise target 
'       isDropped:  Boolean which determines whether a drop target is dropped. Set to false if they are initially raised, true if initially dropped.

' Drop Targets Right
Set DT36 = (new DropTarget)(sw36, sw36a, sw36p, 36, 0, false)
Set DT35 = (new DropTarget)(sw35, sw35a, sw35p, 35, 0, false)
Set DT25 = (new DropTarget)(sw25, sw25a, sw25p, 25, 0, false)
Set DT34 = (new DropTarget)(sw34, sw34a, sw34p, 34, 0, false)
Set DT24 = (new DropTarget)(sw24, sw24a, sw24p, 24, 0, false)
Set DT33 = (new DropTarget)(sw33, sw33a, sw33p, 33, 0, false)
Set DT23 = (new DropTarget)(sw23, sw23a, sw23p, 23, 0, false)

' Drop Targets Left
Set DT20 = (new DropTarget)(sw20, sw20a, sw20p, 20, 0, false)
Set DT30 = (new DropTarget)(sw30, sw30a, sw30p, 30, 0, false)
Set DT21 = (new DropTarget)(sw21, sw21a, sw21p, 21, 0, false)
Set DT31 = (new DropTarget)(sw31, sw31a, sw31p, 31, 0, false)
Set DT22 = (new DropTarget)(sw22, sw22a, sw22p, 22, 0, false)
Set DT32 = (new DropTarget)(sw32, sw32a, sw32p, 32, 0, false)
Set DT26 = (new DropTarget)(sw26, sw26a, sw26p, 26, 0, false)

Dim DTArray
DTArray = Array(DT36,DT35,DT25,DT34,DT24,DT33,DT23,DT20,DT30,DT21,DT31,DT22,DT32,DT26)

'Configure the behavior of Drop Targets.
Const DTDropSpeed = 80 'in milliseconds
Const DTDropUpSpeed = 40 'in milliseconds
Const DTDropUnits = 50 'VP units primitive drops so top of at or below the playfield
Const DTDropUpUnits = 10 'VP units primitive raises above the up position on drops up
Const DTMaxBend = 8 'max degrees primitive rotates when hit
Const DTDropDelay = 20 'time in milliseconds before target drops (due to friction/impact of the ball)
Const DTRaiseDelay = 40 'time in milliseconds before target drops back to normal up position after the solenoid fires to raise the target
Const DTBrickVel = 30 'velocity at which the target will brick, set to '0' to disable brick

Const DTEnableBrick = 0 'Set to 0 to disable bricking, 1 to enable bricking
Const DTHitSound = "" 'Drop Target Hit sound
Const DTDropSound = "DTDrop" 'Drop Target Drop sound
Const DTResetSound = "DTReset" 'Drop Target reset sound

Const DTMass = 0.2 'Mass of the Drop Target (between 0 and 1), higher values provide more resistance


'******************************************************
'  DROP TARGETS FUNCTIONS
'******************************************************

Sub DTHit(switch)
	Dim i
	i = DTArrayID(switch)

	PlayTargetSound
	DTArray(i).animate =  DTCheckBrick(Activeball,DTArray(i).prim)
	If DTArray(i).animate = 1 or DTArray(i).animate = 3 or DTArray(i).animate = 4 Then
		DTBallPhysics Activeball, DTArray(i).prim.rotz, DTMass
	End If
	DoDTAnim
End Sub

Sub DTRaise(switch)
	Dim i
	i = DTArrayID(switch)

	DTArray(i).animate = -1
	DoDTAnim
End Sub

Sub DTDrop(switch)
	Dim i
	i = DTArrayID(switch)

	DTArray(i).animate = 1
	DoDTAnim
End Sub

Function DTArrayID(switch)
	Dim i
	For i = 0 to uBound(DTArray) 
		If DTArray(i).sw = switch Then DTArrayID = i:Exit Function 
	Next
End Function


sub DTBallPhysics(aBall, angle, mass)
	dim rangle,bangle,calc1, calc2, calc3
	rangle = (angle - 90) * 3.1416 / 180
	bangle = atn2(cor.ballvely(aball.id),cor.ballvelx(aball.id))

	calc1 = cor.BallVel(aball.id) * cos(bangle - rangle) * (aball.mass - mass) / (aball.mass + mass)
	calc2 = cor.BallVel(aball.id) * sin(bangle - rangle) * cos(rangle + 4*Atn(1)/2)
	calc3 = cor.BallVel(aball.id) * sin(bangle - rangle) * sin(rangle + 4*Atn(1)/2)

	aBall.velx = calc1 * cos(rangle) + calc2
	aBall.vely = calc1 * sin(rangle) + calc3
End Sub


'Check if target is hit on it's face or sides and whether a 'brick' occurred
Function DTCheckBrick(aBall, dtprim) 
	dim bangle, bangleafter, rangle, rangle2, Xintersect, Yintersect, cdist, perpvel, perpvelafter, paravel, paravelafter
	rangle = (dtprim.rotz - 90) * 3.1416 / 180
	rangle2 = dtprim.rotz * 3.1416 / 180
	bangle = atn2(cor.ballvely(aball.id),cor.ballvelx(aball.id))
	bangleafter = Atn2(aBall.vely,aball.velx)

	Xintersect = (aBall.y - dtprim.y - tan(bangle) * aball.x + tan(rangle2) * dtprim.x) / (tan(rangle2) - tan(bangle))
	Yintersect = tan(rangle2) * Xintersect + (dtprim.y - tan(rangle2) * dtprim.x)

	cdist = Distance(dtprim.x, dtprim.y, Xintersect, Yintersect)

	perpvel = cor.BallVel(aball.id) * cos(bangle-rangle)
	paravel = cor.BallVel(aball.id) * sin(bangle-rangle)

	perpvelafter = BallSpeed(aBall) * cos(bangleafter - rangle) 
	paravelafter = BallSpeed(aBall) * sin(bangleafter - rangle)

	If perpvel > 0 and  perpvelafter <= 0 Then
		If DTEnableBrick = 1 and  perpvel > DTBrickVel and DTBrickVel <> 0 and cdist < 8 Then
			DTCheckBrick = 3
		Else
			DTCheckBrick = 1
		End If
	ElseIf perpvel > 0 and ((paravel > 0 and paravelafter > 0) or (paravel < 0 and paravelafter < 0)) Then
		DTCheckBrick = 4
	Else 
		DTCheckBrick = 0
	End If
End Function


Sub DoDTAnim()
	Dim i
	For i=0 to Ubound(DTArray)
		DTArray(i).animate = DTAnimate(DTArray(i).primary,DTArray(i).secondary,DTArray(i).prim,DTArray(i).sw,DTArray(i).animate)
	Next
End Sub

Function DTAnimate(primary, secondary, prim, switch,  animate)
	dim transz, switchid
	Dim animtime, rangle

	switchid = switch

	rangle = prim.rotz * PI / 180

	DTAnimate = animate

	if animate = 0  Then
		primary.uservalue = 0
		DTAnimate = 0
		Exit Function
	Elseif primary.uservalue = 0 then 
		primary.uservalue = gametime
	end if

	animtime = gametime - primary.uservalue

	If (animate = 1 or animate = 4) and animtime < DTDropDelay Then
		primary.collidable = 0
	If animate = 1 then secondary.collidable = 1 else secondary.collidable= 0
		prim.rotx = DTMaxBend * cos(rangle)
		prim.roty = DTMaxBend * sin(rangle)
		DTAnimate = animate
		Exit Function
		elseif (animate = 1 or animate = 4) and animtime > DTDropDelay Then
		primary.collidable = 0
		If animate = 1 then secondary.collidable = 1 else secondary.collidable= 0
		prim.rotx = DTMaxBend * cos(rangle)
		prim.roty = DTMaxBend * sin(rangle)
		animate = 2
		PlaySoundAt SoundFX(DTDropSound,DOFDropTargets), prim
	End If

	if animate = 2 Then
		transz = (animtime - DTDropDelay)/DTDropSpeed *  DTDropUnits * -1
		if prim.transz > -DTDropUnits  Then
			prim.transz = transz
		end if

		prim.rotx = DTMaxBend * cos(rangle)/2
		prim.roty = DTMaxBend * sin(rangle)/2

		if prim.transz <= -DTDropUnits Then 
			prim.transz = -DTDropUnits
			secondary.collidable = 0
			controller.Switch(Switchid) = 1
			primary.uservalue = 0
			DTAnimate = 0
			Exit Function
		Else
			DTAnimate = 2
			Exit Function
		end If 
	End If

	If animate = 3 and animtime < DTDropDelay Then
		primary.collidable = 0
		secondary.collidable = 1
		prim.rotx = DTMaxBend * cos(rangle)
		prim.roty = DTMaxBend * sin(rangle)
	elseif animate = 3 and animtime > DTDropDelay Then
		primary.collidable = 1
		secondary.collidable = 0
		prim.rotx = 0
		prim.roty = 0
		primary.uservalue = 0
		DTAnimate = 0
		Exit Function
	End If

	if animate = -1 Then
		transz = (1 - (animtime)/DTDropUpSpeed) *  DTDropUnits * -1

		If prim.transz = -DTDropUnits Then
			Dim BOT, b
			BOT = GetBalls

			For b = 0 to UBound(BOT)
				If InRotRect(BOT(b).x,BOT(b).y,prim.x, prim.y, prim.rotz, -25,-10,25,-10,25,25,-25,25) and BOT(b).z < prim.z+DTDropUnits+25 Then
					BOT(b).velz = 20
				End If
			Next
		End If

		if prim.transz < 0 Then
			prim.transz = transz
		elseif transz > 0 then
			prim.transz = transz
		end if

		if prim.transz > DTDropUpUnits then 
			DTAnimate = -2
			prim.transz = DTDropUpUnits
			prim.rotx = 0
			prim.roty = 0
			primary.uservalue = gametime
		end if
		primary.collidable = 0
		secondary.collidable = 1
		controller.Switch(Switchid) = 0

	End If

	if animate = -2 and animtime > DTRaiseDelay Then
		prim.transz = (animtime - DTRaiseDelay)/DTDropSpeed *  DTDropUnits * -1 + DTDropUpUnits 
		if prim.transz < 0 then
			prim.transz = 0
			primary.uservalue = 0
			DTAnimate = 0

			primary.collidable = 1
			secondary.collidable = 0
		end If 
	End If
End Function


'******************************************************
'  DROP TARGET
'  SUPPORTING FUNCTIONS 
'******************************************************


' Used for drop targets
'*** Determines if a Points (px,py) is inside a 4 point polygon A-D in Clockwise/CCW order
Function InRect(px,py,ax,ay,bx,by,cx,cy,dx,dy)
	Dim AB, BC, CD, DA
	AB = (bx*py) - (by*px) - (ax*py) + (ay*px) + (ax*by) - (ay*bx)
	BC = (cx*py) - (cy*px) - (bx*py) + (by*px) + (bx*cy) - (by*cx)
	CD = (dx*py) - (dy*px) - (cx*py) + (cy*px) + (cx*dy) - (cy*dx)
	DA = (ax*py) - (ay*px) - (dx*py) + (dy*px) + (dx*ay) - (dy*ax)

	If (AB <= 0 AND BC <=0 AND CD <= 0 AND DA <= 0) Or (AB >= 0 AND BC >=0 AND CD >= 0 AND DA >= 0) Then
		InRect = True
	Else
		InRect = False       
	End If
End Function

Function InRotRect(ballx,bally,px,py,angle,ax,ay,bx,by,cx,cy,dx,dy)
    Dim rax,ray,rbx,rby,rcx,rcy,rdx,rdy
    Dim rotxy
    rotxy = RotPoint(ax,ay,angle)
    rax = rotxy(0)+px : ray = rotxy(1)+py
    rotxy = RotPoint(bx,by,angle)
    rbx = rotxy(0)+px : rby = rotxy(1)+py
    rotxy = RotPoint(cx,cy,angle)
    rcx = rotxy(0)+px : rcy = rotxy(1)+py
    rotxy = RotPoint(dx,dy,angle)
    rdx = rotxy(0)+px : rdy = rotxy(1)+py

    InRotRect = InRect(ballx,bally,rax,ray,rbx,rby,rcx,rcy,rdx,rdy)
End Function

Function RotPoint(x,y,angle)
    dim rx, ry
    rx = x*dCos(angle) - y*dSin(angle)
    ry = x*dSin(angle) + y*dCos(angle)
    RotPoint = Array(rx,ry)
End Function

'******************************************************
'****  END DROP TARGETS
'******************************************************

'******************************************************
'		STAND-UP TARGET INITIALIZATION
'******************************************************

Class StandupTarget
  Private m_primary, m_prim, m_sw, m_animate

  Public Property Get Primary(): Set Primary = m_primary: End Property
  Public Property Let Primary(input): Set m_primary = input: End Property

  Public Property Get Prim(): Set Prim = m_prim: End Property
  Public Property Let Prim(input): Set m_prim = input: End Property

  Public Property Get Sw(): Sw = m_sw: End Property
  Public Property Let Sw(input): m_sw = input: End Property

  Public Property Get Animate(): Animate = m_animate: End Property
  Public Property Let Animate(input): m_animate = input: End Property

  Public default Function init(primary, prim, sw, animate)
    Set m_primary = primary
    Set m_prim = prim
    m_sw = sw
    m_animate = animate

    Set Init = Me
  End Function
End Class

'Define a variable for each stand-up target
Dim ST16, ST111, ST113, ST115, ST114, ST1140, ST93, ST930, ST94, ST95, ST950, ST96, ST97, ST970, ST112, ST1120, ST116, ST1160, ST117,ST1170, ST103, ST1030

'Set array with stand-up target objects
'
'StandupTargetvar = Array(primary, prim, swtich)
' 	primary: 			vp target to determine target hit
'	prim:				primitive target used for visuals and animation
'							IMPORTANT!!! 
'							transy must be used to offset the target animation
'	switch:				ROM switch number
'	animate:			Arrary slot for handling the animation instrucitons, set to 0
' 
'You will also need to add a secondary hit object for each stand up (name sw11o, sw12o, and sw13o on the example Table1)
'these are inclined primitives to simulate hitting a bent target and should provide so z velocity on high speed impacts

Set ST16 = (new StandupTarget)(sw16, sw16p,16, 0)
Set ST111 = (new StandupTarget)(sw111, psw111,111, 0)
Set ST113 = (new StandupTarget)(sw113, psw113,113, 0)
Set ST115 = (new StandupTarget)(sw115, psw115,115, 0)
Set ST114 = (new StandupTarget)(sw114, psw114,114, 0)
Set ST1140 = (new StandupTarget)(sw1140, psw1140,1140, 0)
Set ST93 = (new StandupTarget)(sw93, psw93,93, 0)
Set ST930 = (new StandupTarget)(sw930, psw930,930, 0)
Set ST94 = (new StandupTarget)(sw94, psw94,94, 0)
Set ST95 = (new StandupTarget)(sw95, psw95,95, 0)
Set ST950 = (new StandupTarget)(sw950, psw950,950, 0)
Set ST96 = (new StandupTarget)(sw96, psw96,96, 0)
Set ST97 = (new StandupTarget)(sw97, psw97,97, 0)
Set ST970 = (new StandupTarget)(sw970, psw970,970, 0)
Set ST112 = (new StandupTarget)(sw112, psw112,112, 0)
Set ST1120 = (new StandupTarget)(sw1120, psw1120,1120, 0)
Set ST116 = (new StandupTarget)(sw116, psw116,116, 0)
Set ST1160 = (new StandupTarget)(sw1160, psw1160,1160, 0)
Set ST117 = (new StandupTarget)(sw117, psw117,117, 0)
Set ST1170 = (new StandupTarget)(sw1170, psw1170,1170, 0)
Set ST103 = (new StandupTarget)(sw103, psw103,103, 0)
Set ST1030 = (new StandupTarget)(sw1030, psw1030,1030, 0)

'Add all the Stand-up Target Arrays to Stand-up Target Animation Array
' STAnimationArray = Array(ST1, ST2, ....)
Dim STArray
STArray = Array(ST16, ST111, ST113, ST115, ST114, ST1140, ST93, ST930, ST94, ST95, ST950, ST96, ST97, ST970, ST112, ST1120, ST116, ST1160, ST117,ST1170, ST103, ST1030)

'Configure the behavior of Stand-up Targets
Const STAnimStep =  1.5 				'vpunits per animation step (control return to Start)
Const STMaxOffset = 9 			'max vp units target moves when hit

Const STMass = 0.2				'Mass of the Stand-up Target (between 0 and 1), higher values provide more resistance

'******************************************************
'				STAND-UP TARGETS FUNCTIONS
'******************************************************

Sub STHit(switch)
	Dim i
	i = STArrayID(switch)

	PlayTargetSound
	STArray(i).animate =  STCheckHit(Activeball,STArray(i).primary)

	If STArray(i).animate <> 0 Then
		DTBallPhysics Activeball, STArray(i).primary.orientation, STMass
	End If
	DoSTAnim
End Sub

Function STArrayID(switch)
	Dim i
	For i = 0 to uBound(STArray) 
		If STArray(i).sw = switch Then STArrayID = i:Exit Function 
	Next
End Function

'Check if target is hit on it's face
Function STCheckHit(aBall, target) 
	dim bangle, bangleafter, rangle, rangle2, perpvel, perpvelafter, paravel, paravelafter
	rangle = (target.orientation - 90) * 3.1416 / 180	
	bangle = atn2(cor.ballvely(aball.id),cor.ballvelx(aball.id))
	bangleafter = Atn2(aBall.vely,aball.velx)

	perpvel = cor.BallVel(aball.id) * cos(bangle-rangle)
	paravel = cor.BallVel(aball.id) * sin(bangle-rangle)

	perpvelafter = BallSpeed(aBall) * cos(bangleafter - rangle) 
	paravelafter = BallSpeed(aBall) * sin(bangleafter - rangle)

	If perpvel > 0 and  perpvelafter <= 0 Then
		STCheckHit = 1
	ElseIf perpvel > 0 and ((paravel > 0 and paravelafter > 0) or (paravel < 0 and paravelafter < 0)) Then
		STCheckHit = 1
	Else 
		STCheckHit = 0
	End If
End Function

Sub DoSTAnim()
	Dim i
	For i=0 to Ubound(STArray)
		STArray(i).animate = STAnimate(STArray(i).primary,STArray(i).prim,STArray(i).sw,STArray(i).animate)
	Next
End Sub

Function STAnimate(primary, prim, switch,  animate)
	Dim animtime

	STAnimate = animate

	if animate = 0  Then
		primary.uservalue = 0
		STAnimate = 0
		Exit Function
	Elseif primary.uservalue = 0 then 
		primary.uservalue = gametime
	end if

	animtime = gametime - primary.uservalue

	If animate = 1 Then
		primary.collidable = 0
		prim.transy = -STMaxOffset
'		if UsingROM then 
'			vpmTimer.PulseSw switch
'		else
'			STAction switch
'		end if
		STAnimate = 2
		Exit Function
	elseif animate = 2 Then
		prim.transy = prim.transy + STAnimStep
		If prim.transy >= 0 Then
			prim.transy = 0
			primary.collidable = 1
			STAnimate = 0
			Exit Function
		Else 
			STAnimate = 2
		End If
	End If	
End Function

'Sub STAction(Switch)
'	Select Case Switch
'		Case 11:
'			Addscore 1000
'			Flash1 True								'Demo of the flasher
'			vpmTimer.AddTimer 150,"Flash1 False'"	'Disable the flash after short time, just like a ROM would do
'		Case 12:
'			Addscore 1000
'			Flash2 True								'Demo of the flasher
'			vpmTimer.AddTimer 150,"Flash2 False'"	'Disable the flash after short time, just like a ROM would do
'		Case 13:
'			Addscore 1000
'			Flash3 True								'Demo of the flasher
'			vpmTimer.AddTimer 150,"Flash3 False'"	'Disable the flash after short time, just like a ROM would do
'	End Select
'End Sub

'******************************************************
'		END STAND-UP TARGETS
'******************************************************






'******************************************************
'**** RAMP ROLLING SFX
'******************************************************

'Ball tracking ramp SFX 1.0
'   Reqirements:
'          * Import A Sound File for each ball on the table for plastic ramps.  Call It RampLoop<Ball_Number> ex: RampLoop1, RampLoop2, ...
'          * Import a Sound File for each ball on the table for wire ramps. Call it WireLoop<Ball_Number> ex: WireLoop1, WireLoop2, ...
'          * Create a Timer called RampRoll, that is enabled, with a interval of 100
'          * Set RampBAlls and RampType variable to Total Number of Balls
'	Usage:
'          * Setup hit events and call WireRampOn True or WireRampOn False (True = Plastic ramp, False = Wire Ramp)
'          * To stop tracking ball
'                 * call WireRampOff
'                 * Otherwise, the ball will auto remove if it's below 30 vp units
'

dim RampMinLoops : RampMinLoops = 4

' RampBalls
'      Setup:        Set the array length of x in RampBalls(x,2) Total Number of Balls on table + 1:  if tnob = 5, then RammBalls(6,2)
'      Description:  
dim RampBalls(6,2)
'x,0 = ball x,1 = ID,	2 = Protection against ending early (minimum amount of updates)
'0,0 is boolean on/off, 0,1 unused for now
RampBalls(0,0) = False

' RampType
'     Setup: Set this array to the number Total number of balls that can be tracked at one time + 1.  5 ball multiball then set value to 6
'     Description: Array type indexed on BallId and a values used to deterimine what type of ramp the ball is on: False = Wire Ramp, True = Plastic Ramp
dim RampType(6)	

Sub WireRampOn(input)  : Waddball ActiveBall, input : RampRollUpdate: End Sub
Sub WireRampOff() : WRemoveBall ActiveBall.ID	: End Sub


' WaddBall (Active Ball, Boolean)
'     Description: This subroutine is called from WireRampOn to Add Balls to the RampBalls Array
Sub Waddball(input, RampInput)	'Add ball
	' This will loop through the RampBalls array checking each element of the array x, position 1
	' To see if the the ball was already added to the array.
	' If the ball is found then exit the subroutine
	dim x : for x = 1 to uBound(RampBalls)	'Check, don't add balls twice
		if RampBalls(x, 1) = input.id then 
			if Not IsEmpty(RampBalls(x,1) ) then Exit Sub	'Frustating issue with BallId 0. Empty variable = 0
		End If
	Next

	' This will itterate through the RampBalls Array.
	' The first time it comes to a element in the array where the Ball Id (Slot 1) is empty.  It will add the current ball to the array
	' The RampBalls assigns the ActiveBall to element x,0 and ball id of ActiveBall to 0,1
	' The RampType(BallId) is set to RampInput
	' RampBalls in 0,0 is set to True, this will enable the timer and the timer is also turned on
	For x = 1 to uBound(RampBalls)
		if IsEmpty(RampBalls(x, 1)) then 
			Set RampBalls(x, 0) = input
			RampBalls(x, 1)	= input.ID
			RampType(x) = RampInput
			RampBalls(x, 2)	= 0
			'exit For
			RampBalls(0,0) = True
			RampRoll.Enabled = 1	 'Turn on timer
			'RampRoll.Interval = RampRoll.Interval 'reset timer
			exit Sub
		End If
		if x = uBound(RampBalls) then 	'debug
			Debug.print "WireRampOn error, ball queue is full: " & vbnewline & _
			RampBalls(0, 0) & vbnewline & _
			Typename(RampBalls(1, 0)) & " ID:" & RampBalls(1, 1) & "type:" & RampType(1) & vbnewline & _
			Typename(RampBalls(2, 0)) & " ID:" & RampBalls(2, 1) & "type:" & RampType(2) & vbnewline & _
			Typename(RampBalls(3, 0)) & " ID:" & RampBalls(3, 1) & "type:" & RampType(3) & vbnewline & _
			Typename(RampBalls(4, 0)) & " ID:" & RampBalls(4, 1) & "type:" & RampType(4) & vbnewline & _
			Typename(RampBalls(5, 0)) & " ID:" & RampBalls(5, 1) & "type:" & RampType(5) & vbnewline & _
			" "
		End If
	next
End Sub

' WRemoveBall (BallId)
'    Description: This subroutine is called from the RampRollUpdate subroutine 
'                 and is used to remove and stop the ball rolling sounds
Sub WRemoveBall(ID)		'Remove ball
	'Debug.Print "In WRemoveBall() + Remove ball from loop array"
	dim ballcount : ballcount = 0
	dim x : for x = 1 to Ubound(RampBalls)
		if ID = RampBalls(x, 1) then 'remove ball
			Set RampBalls(x, 0) = Nothing
			RampBalls(x, 1) = Empty
			RampType(x) = Empty
			StopSound("RampLoop" & x)
			StopSound("wireloop" & x)
		end If
		'if RampBalls(x,1) = Not IsEmpty(Rampballs(x,1) then ballcount = ballcount + 1
		if not IsEmpty(Rampballs(x,1)) then ballcount = ballcount + 1
	next
	if BallCount = 0 then RampBalls(0,0) = False	'if no balls in queue, disable timer update
End Sub

Sub RampRoll_Timer():RampRollUpdate:End Sub

Sub RampRollUpdate()		'Timer update
	dim x : for x = 1 to uBound(RampBalls)
		if Not IsEmpty(RampBalls(x,1) ) then 
			if BallVel(RampBalls(x,0) ) > 1 then ' if ball is moving, play rolling sound
				If RampType(x) then 
					PlaySound("RampLoop" & x), -1, VolPlayfieldRoll(RampBalls(x,0)) * RampRollVolume * VolumeDial, AudioPan(RampBalls(x,0)), 0, BallPitchV(RampBalls(x,0)), 1, 0, AudioFade(RampBalls(x,0))				
					StopSound("wireloop" & x)
				Else
					StopSound("RampLoop" & x)
					PlaySound("wireloop" & x), -1, VolPlayfieldRoll(RampBalls(x,0)) * RampRollVolume * VolumeDial, AudioPan(RampBalls(x,0)), 0, BallPitch(RampBalls(x,0)), 1, 0, AudioFade(RampBalls(x,0))
				End If
				RampBalls(x, 2)	= RampBalls(x, 2) + 1
			Else
				StopSound("RampLoop" & x)
				StopSound("wireloop" & x)
			end if
			if RampBalls(x,0).Z < 30 and RampBalls(x, 2) > RampMinLoops then	'if ball is on the PF, remove  it
				StopSound("RampLoop" & x)
				StopSound("wireloop" & x)
				Wremoveball RampBalls(x,1)
			End If
		Else
			StopSound("RampLoop" & x)
			StopSound("wireloop" & x)
		end if
	next
	if not RampBalls(0,0) then RampRoll.enabled = 0

End Sub

' This can be used to debug the Ramp Roll time.  You need to enable the tbWR timer on the TextBox
Sub tbWR_Timer()	'debug textbox
	me.text =	"on? " & RampBalls(0, 0) & " timer: " & RampRoll.Enabled & vbnewline & _
	"1 " & Typename(RampBalls(1, 0)) & " ID:" & RampBalls(1, 1) & " type:" & RampType(1) & " Loops:" & RampBalls(1, 2) & vbnewline & _
	"2 " & Typename(RampBalls(2, 0)) & " ID:" & RampBalls(2, 1) & " type:" & RampType(2) & " Loops:" & RampBalls(2, 2) & vbnewline & _
	"3 " & Typename(RampBalls(3, 0)) & " ID:" & RampBalls(3, 1) & " type:" & RampType(3) & " Loops:" & RampBalls(3, 2) & vbnewline & _
	"4 " & Typename(RampBalls(4, 0)) & " ID:" & RampBalls(4, 1) & " type:" & RampType(4) & " Loops:" & RampBalls(4, 2) & vbnewline & _
	"5 " & Typename(RampBalls(5, 0)) & " ID:" & RampBalls(5, 1) & " type:" & RampType(5) & " Loops:" & RampBalls(5, 2) & vbnewline & _
	"6 " & Typename(RampBalls(6, 0)) & " ID:" & RampBalls(6, 1) & " type:" & RampType(6) & " Loops:" & RampBalls(6, 2) & vbnewline & _
	" "
End Sub


Function BallPitch(ball) ' Calculates the pitch of the sound based on the ball speed
    BallPitch = pSlope(BallVel(ball), 1, -1000, 60, 10000)
End Function

Function BallPitchV(ball) ' Calculates the pitch of the sound based on the ball speed Variation
	BallPitchV = pSlope(BallVel(ball), 1, -4000, 60, 7000)
End Function

'******************************************************
'**** END RAMP ROLLING SFX
'******************************************************
