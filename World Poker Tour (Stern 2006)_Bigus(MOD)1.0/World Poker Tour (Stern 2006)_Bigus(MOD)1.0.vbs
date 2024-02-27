 Option Explicit
   Randomize
 
On Error Resume Next
ExecuteGlobal GetTextFile("controller.vbs")
If Err Then MsgBox "You need the controller.vbs in order to run this table, available in the vp10 package"
On Error Goto 0
 
'******************* Options *********************
' DMD/BAckglass Controller Setting
Const GIOnDuringAttractMode     = 1                 '1 - GI on during attract, 0 - GI off during attract
dim DivValue:DivValue           = 2                 ' Change Value to 4 if LED array does not display properly on your system
 
Const UseVPMColoredDMD = true
Const UseVPMDMD = 0


' ***************************************************************************
'                          DAY & NIGHT FUNCTIONS AND DATASETS
' ****************************************************************************
' Emmessive blocking dampeners/highteners
'-1= 0.5x  emmissive de-block increase
' 0= (default)full emmisive blocking
' 1= Half of full
' 2= Quarter of full 
' 3= 8'th of full
' 4= 16'th of full
' 5= 32'nd of full
' 6 = full emmision

Const GILevel = 3
Const FLLevel = 3
Const BTLevel = 3

Const cUSESHADOW = 1
Const cUSECOLORGRADE = 1
Const cUSECCUPBOOST = 1
Const cUSELITEBOOST = 0
Const cUSEBACKGLASS = 1
Const cDYNPINBALL = 1
Const cDYNGAMEBLADES =0
Const cSHADOWBLADES =0
Const cUSEBGLASSHIGH =0
Const cUSETOPPER =0
Const cUSEBACKLIGHT =1
Const cUSEBGLASSCCX =1
Const cUSEBGLASSREFL =1
Const cUSEDUALRAMPS =0

Dim nxx, DNS
DNS = Table.NightDay

Dim DivLevel: DivLevel = 35
Dim DNSVal: DNSVal = Round(DNS/10)
Dim DNShift: DNShift = 1

'Dim OPSValues: OPSValues=Array (100,50,20,10 ,5,4 ,3 ,2 ,1, 0,0)
'Dim DNSValues: DNSValues=Array (1.0,0.5,0.1,0.05,0.01,0.005,0.001,0.0005,0.0001, 0.00005,0.00000)
Dim OPSValues: OPSValues=Array (100,50,20,10 ,9,8 ,7 ,6 ,5, 4,3,2,1,0)
Dim OPS2: OPS2  =Array (1.0,0.95,0.90,0.85,0.80,0.75,0.70,0.65,0.60,0.55,0.50,0.50)
Dim OPSValues2: OPSValues2=Array (100*OPS2(DNSVal),50*OPS2(DNSVal),20*OPS2(DNSVal),10*OPS2(DNSVal),9*OPS2(DNSVal),8*OPS2(DNSVal),7*OPS2(DNSVal),6*OPS2(DNSVal),5*OPS2(DNSVal), 4*OPS2(DNSVal),3*OPS2(DNSVal),2*OPS2(DNSVal),1*OPS2(DNSVal),0*OPS2(DNSVal))
Dim OPS3: OPS3 =Array (1.0,0.93,0.85,0.78,0.70,0.65,0.55,0.48,0.40,0.33,0.25,0.25)
Dim OPSValues3: OPSValues3=Array (100*OPS3(DNSVal),50*OPS3(DNSVal),20*OPS3(DNSVal),10*OPS3(DNSVal),9*OPS3(DNSVal),8*OPS3(DNSVal),7*OPS3(DNSVal),6*OPS3(DNSVal),5*OPS3(DNSVal),4*OPS3(DNSVal),3*OPS3(DNSVal),2*OPS3(DNSVal),1*OPS3(DNSVal),0*OPS3(DNSVal))
Dim OPS4: OPS4 =Array (1.0,0.91,0.82,0.74,0.65,0.56,0.47,0.38,0.30,0.21,0.12,0.12)
Dim OPSValues4: OPSValues4=Array (100*OPS4(DNSVal),50*OPS4(DNSVal),20*OPS4(DNSVal),10*OPS4(DNSVal),9*OPS4(DNSVal),8*OPS4(DNSVal),7*OPS4(DNSVal),6*OPS4(DNSVal),5*OPS4(DNSVal),4*OPS4(DNSVal),3*OPS4(DNSVal),2*OPS4(DNSVal),1*OPS4(DNSVal),0*OPS4(DNSVal))
Dim OPS5: OPS5 =Array (1.0,0.91,0.83,0.72,0.63,0.55,0.44,0.35,0.25,0.16,0.07,0.07)
Dim OPSValues5: OPSValues5=Array (100*OPS5(DNSVal),50*OPS5(DNSVal),20*OPS5(DNSVal),10*OPS5(DNSVal),9*OPS5(DNSVal),8*OPS5(DNSVal),7*OPS5(DNSVal),6*OPS5(DNSVal),5*OPS5(DNSVal),4*OPS5(DNSVal),3*OPS5(DNSVal),2*OPS5(DNSVal),1*OPS5(DNSVal),0*OPS5(DNSVal))
Dim OPS6: OPS6 =Array (1.0,0.90,0.81,0.71,0.62,0.52,0.42,0.33,0.23,0.14,0.04,0.04)
Dim OPSValues6: OPSValues6=Array (100*OPS6(DNSVal),50*OPS6(DNSVal),20*OPS6(DNSVal),10*OPS5(DNSVal),9*OPS6(DNSVal),8*OPS6(DNSVal),7*OPS6(DNSVal),6*OPS6(DNSVal),5*OPS6(DNSVal),4*OPS6(DNSVal),3*OPS6(DNSVal),2*OPS6(DNSVal),1*OPS6(DNSVal),0*OPS6(DNSVal))

Dim OPS1: OPS1 = 0.01 '0.25
Dim OPSValues1: OPSValues1=Array (100*OPS1,50*OPS1,20*OPS1,10*OPS1,9*OPS1,8*OPS1,7*OPS1,6*OPS1,5*OPS1,4*OPS1,3*OPS1,2*OPS1,1*OPS1,0*OPS1)

Dim DNSValues: DNSValues=Array (1.0,0.5,0.1,0.05,0.01,0.005,0.001,0.0005,0.0001, 0.00005,0.00001, 0.000005, 0.000001)
Dim SysDNSVal: SysDNSVal=Array (1.0,0.9,0.8,0.7,0.6,0.5,0.5,0.5,0.5, 0.5,0.5)
Dim DivValues: DivValues =Array (1,2,4,8,16,32,32,32,32, 32,32)
Dim DivValues2: DivValues2 =Array (1,1.5,2,2.5,3,3.5,4,4.5,5, 5.5,6)
Dim DivValues3: DivValues3 =Array (1,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,2.0,2.1)

Dim DIV4: DIV4 =Array (1.0,0.95,0.90,0.85,0.80,0.75,0.70,0.65,0.60,0.55,0.50,0.50)
Dim DivValues4: DivValues4 =Array (1*DIV4(DNSVal),1.1*DIV4(DNSVal),1.2*DIV4(DNSVal),1.3*DIV4(DNSVal),1.4*DIV4(DNSVal),1.5*DIV4(DNSVal),1.6*DIV4(DNSVal),1.7*DIV4(DNSVal),1.8*DIV4(DNSVal),1.9*DIV4(DNSVal),2.0*DIV4(DNSVal),2.1*DIV4(DNSVal))
Dim DIV5: DIV5 =Array (1.0,0.93,0.85,0.78,0.70,0.65,0.55,0.48,0.40,0.33,0.25,0.25)
Dim DivValues5: DivValues5 =Array (1*DIV5(DNSVal),1.1*DIV5(DNSVal),1.2*DIV5(DNSVal),1.3*DIV5(DNSVal),1.4*DIV5(DNSVal),1.5*DIV5(DNSVal),1.6*DIV5(DNSVal),1.7*DIV5(DNSVal),1.8*DIV5(DNSVal),1.9*DIV5(DNSVal),2.0*DIV5(DNSVal),2.1*DIV5(DNSVal))
Dim DIV6: DIV6 =Array (1.0,0.91,0.82,0.74,0.65,0.56,0.47,0.38,0.30,0.21,0.12,0.12)
Dim DivValues6: DivValues6 =Array (1*DIV6(DNSVal),1.1*DIV6(DNSVal),1.2*DIV6(DNSVal),1.3*DIV6(DNSVal),1.4*DIV6(DNSVal),1.5*DIV6(DNSVal),1.6*DIV6(DNSVal),1.7*DIV6(DNSVal),1.8*DIV6(DNSVal),1.9*DIV6(DNSVal),2.0*DIV6(DNSVal),2.1*DIV6(DNSVal))
Dim DIV7: DIV7 =Array (1.0,0.91,0.83,0.72,0.63,0.55,0.44,0.35,0.25,0.16,0.07,0.07)
Dim DivValues7: DivValues7 =Array (1*DIV7(DNSVal),1.1*DIV7(DNSVal),1.2*DIV7(DNSVal),1.3*DIV7(DNSVal),1.4*DIV7(DNSVal),1.5*DIV7(DNSVal),1.6*DIV7(DNSVal),1.7*DIV7(DNSVal),1.8*DIV7(DNSVal),1.9*DIV7(DNSVal),2.0*DIV7(DNSVal),2.1*DIV7(DNSVal))
Dim DIV8: DIV8 =Array (1.0,0.90,0.81,0.71,0.62,0.52,0.42,0.33,0.23,0.14,0.04,0.04)
Dim DivValues8: DivValues8 =Array (1*DIV8(DNSVal),1.1*DIV8(DNSVal),1.2*DIV8(DNSVal),1.3*DIV8(DNSVal),1.4*DIV8(DNSVal),1.5*DIV8(DNSVal),1.6*DIV8(DNSVal),1.7*DIV8(DNSVal),1.8*DIV8(DNSVal),1.9*DIV8(DNSVal),2.0*DIV8(DNSVal),2.1*DIV8(DNSVal))

Dim MUL1: MUL1 =Array (1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0)' 1.1
Dim MulValues1: MulValues1 =Array (1*MUL1(DNSVal),1.1*MUL1(DNSVal),1.2*MUL1(DNSVal),1.3*MUL1(DNSVal),1.4*MUL1(DNSVal),1.5*MUL1(DNSVal),1.6*MUL1(DNSVal),1.7*MUL1(DNSVal),1.8*MUL1(DNSVal),1.9*MUL1(DNSVal),2.0*MUL1(DNSVal),2.1*MUL1(DNSVal))


Dim RValUP: RValUP=Array (30,60,90,120,150,180,210,240,255,255,255,255)
Dim GValUP: GValUP=Array (30,60,90,120,150,180,210,240,255,255,255,255)
Dim BValUP: BValUP=Array (30,60,90,120,150,180,210,240,255,255,255,255)
Dim RValDN: RValDN=Array (255,210,180,150,120,90,60,30,10,10,10)
Dim GValDN: GValDN=Array (255,210,180,150,120,90,60,30,10,10,10)
Dim BValDN: BValDN=Array (255,210,180,150,120,90,60,30,10,10,10)
Dim FValUP: FValUP=Array (35,40,45,50,55,60,65,70,75,80,85,90,95,100,105)
Dim FValDN: FValDN=Array (100,85,80,75,70,65,60,55,50,45,40,35,30)
Dim MVSAdd: MVSAdd=Array (0.9,0.9,0.8,0.8,0.7,0.7,0.6,0.6,0.5,0.5,0.4,0.3,0.2,0.1)
Dim ReflDN: ReflDN=Array (60,55,50,45,40,35,30,28,26,24,22,20,19,18,16,15,14,13,12,11,10)
Dim DarkUP: DarkUP=Array (1,2,3,4,5,6,6,6,6,6,6,6,6,6,6,6,6,6)

' PLAYFIELD GENERAL OPERATIONAL and LOCALALIZED GI ILLUMINATION
Dim aAllFlashers: aAllFlashers=Array(f22c,f23c,f25c,f26c,f27c,f28c,f29c,f30c,f31c,_
Flasher7,Flasher8,Flasher9,Flasher10,Flasher11,Flasher12,Flasher13,Flasher14,Flasher15,Flasher16,_
Flasher17,Flasher18,Flasher19, Flasher20,Flasher21,Flasher22)
Dim aGiLights: aGiLights=array(Light80 ,Light1,Light2,Light3,Light4,Light5,Light6,Light7,Light8,_
Light9,Light10,Light11,Light12,Light13,Light14,Light15,Light16,Light17,Light18,Light19,Light20,_
Light21,Light22,Light23,Light24,Light25,Light26)
Dim BloomLights: BloomLights=array(f22a,f22b,f22d,f23a,f23b,f23d,f26a,f26d,f27a,f27d,f28a,f28d,_
f29a,f29d,f30a,f30d,f31a,f31d)
Dim TargetDropGi: TargetDropGi = array()


' PLAYFIELD GLOBAL INTENSITY ILLUMINATION FLASHERS
Flasher3.opacity = OPSValues(DNSVal + DNShift) / DivValues(DNSVal)
Flasher3.intensityscale = DNSValues(DNSVal + DNShift) /DivValues(DNSVal)
Flasher4.opacity = OPSValues(DNSVal + DNShift) /DivValues(DNSVal)
Flasher4.intensityscale = DNSValues(DNSVal + DNShift) /DivValues(DNSVal)
Flasher5.opacity = OPSValues(DNSVal + DNShift) /DivValues(DNSVal)
Flasher5.intensityscale = DNSValues(DNSVal + DNShift) /DivValues(DNSVal)
'Flasher6.opacity = OPSValues(DNSVal + DNShift) /DivValues(DNSVal)
'Flasher6.intensityscale = DNSValues(DNSVal + DNShift) /DivValues(DNSVal)

if cUSELITEBOOST then
Dim LiteUP: LiteUP=Array (10,6,5,4,4,4,4,3,3,3,2,2,1,0.5,0.4,0.3,0.2,0.1)
Flasher5.Color = RGB(RValUP(DNSVal)/LiteUP(DNSVal),GValUP(DNSVal)/LiteUP(DNSVal),BValUP(DNSVal)/LiteUP(DNSVal))
end if 'cUSELITEBOOST

'BACKBOX & BACKGLASS ILLUMINATION
if cUSEBACKGLASS then
BGDark.ModulateVsAdd = MVSAdd(DNSVal)
BGDark.Color = RGB(RValUP(DNSVal),GValUP(DNSVal),BValUP(DNSVal))
BGDark.Amount = FValUP(DNSVal) / DivValues(DNSVal)
BGHigh.Color = RGB(RValDN(DNSVal),GValDN(DNSVal),BValDN(DNSVal))
BGHigh.Amount = FValDN(DNSVal)  / DivValues(DNSVal)
BGHigh1.Color = RGB(RValDN(DNSVal),GValDN(DNSVal),BValDN(DNSVal))
BGHigh1.Amount = FValDN(DNSVal) / DivValues(DNSVal)

if cUSETOPPER > 0 then ' add (TopHigh,TopHigh1,TopHigh2,) to aAllFlashers array, or enable code for to adjust brightness
TopDark.ModulateVsAdd = MVSAdd(DNSVal)
TopDark.Color = RGB(RValUP(DNSVal)-25,GValUP(DNSVal)-25,BValUP(DNSVal)-25)
'TopHigh.Color = RGB(RValDN(DNSVal),GValDN(DNSVal),BValDN(DNSVal))

if cUSETOPPER > 1 then
TopHigh.amount = TopHigh.amount / DivValues3(DNSVal)
TopHigh.opacity = TopHigh.opacity * OPSValues(DNSVal) / DivLevel
if cUSETOPPER > 2 then
TopHigh1.amount = TopHigh1.amount / DivValues3(DNSVal)
TopHigh1.opacity = TopHigh1.opacity * OPSValues(DNSVal) / DivLevel
if cUSETOPPER > 3 then
TopHigh2.amount = TopHigh2.amount / DivValues3(DNSVal)
TopHigh2.opacity = TopHigh2.opacity * OPSValues(DNSVal) / DivLevel
end if 'cUSETOPPER 3
end if 'cUSETOPPER 2
end if 'cUSETOPPER 1
end if 'cUSETOPPER 0

if cUSEBACKLIGHT then
Const nBACKBoost = 5
FloodLightLeft.Color = RGB(RValDN(DNSVal),GValDN(DNSVal),BValDN(DNSVal))
FloodLightLeft.Amount = FValDN(DNSVal)  * nBACKBoost
'FloodLightLeft.opacity = OPSValues(DNSVal+ DNShift) /DivValues(DNSVal)
FloodLightRight.Color = RGB(RValDN(DNSVal),GValDN(DNSVal),BValDN(DNSVal))
FloodLightRight.Amount = FValDN(DNSVal) * nBACKBoost
'FloodLightRight.opacity = OPSValues(DNSVal+ DNShift) /DivValues(DNSVal)
end if 'cUSEBACKLIGHT

BGframe.ModulateVsAdd = MVSAdd(DNSVal) * 0.2
BGframe.Color = RGB(RValUP(DNSVal),GValUP(DNSVal),BValUP(DNSVal))
BGframe.Amount = FValUP(DNSVal) * DivValues(DNSVal)

' Use on arcade backgrounds
'Dim DarkDN: DarkDN=Array (1.5,1.0,0.8,0.75,0.7,0.68,0.66,0.64,0.62,0.60,0.59,0.58,0.57,0.56,0.55,0.54,0.53,0.52)

'Flasher12.opacity = OPSValues(DNSVal) 
'Flasher12.intensityscale = DarkDN(DNSVal) * 4.0
'Flasher12.Color = RGB(RValUP(DNSVal) / 2.0,GValUP(DNSVal)/ 2.0,BValUP(DNSVal)/ 2.0)
'Flasher19.opacity = OPSValues(DNSVal) 
'Flasher19.intensityscale = DarkDN(DNSVal ) * 4.0
'Flasher19.Color = RGB(RValUP(DNSVal)/ 2.0,GValUP(DNSVal)/ 2.0,BValUP(DNSVal)/ 2.0)

BGHigh.intensityscale = 0.6
BGHigh1.intensityscale = 0.5
BGDark.intensityscale = 0.5
BGframe.intensityscale = 0.5

BGHigh2.intensityscale = 1.2

if cUSEBGLASSHIGH then ' GBGHigh3 is _defhorz flasher, Additive, AMT:100, OP:2, DB:8000, MOD:1 

GBGHigh3.intensityscale = 0.2
Dim ReflUP: ReflUP=Array (0.3,0.4,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9)
GBGDark.intensityscale = ReflUP(DNSVal)

end if 'cUSEBGLASSHIGH


Dim tMaskFill: tMaskFill = Array(Empty,BGFrameMaskFill2,BGFrameMaskFill3,Empty,Empty)
' Fill with: BGFrameMaskFill1,BGFrameMaskFill2,BGFrameMaskFill3,BGFrameMaskFill4,BGFrameMaskFill5
if cUSEBGLASSREFL then

Dim ReflFill: ReflFill=Array (10,10,20,20,30,30,30,30,40,40,40)
Dim ReflImg: ReflImg=Array (160,200,300,400,500,600,700,800,900,1000,1000)
Dim FillMag: FillMag=Array (0.8,0.8,0.7,0.7,0.6,0.6,0.55,0.55,0.54,0.54,0.53)

'playfield glass reflections
if NOT IsEmpty(tMaskFill(1)) then: tMaskFill(1).opacity= ReflFill(DNSVal)*2: end if' IMG:full table, def glass trans, FLTR:screen,AMT:900,OP:50, AB=off, RGB=0,0,32, DB=-10000,MOD=1
if NOT IsEmpty(tMaskFill(2)) then: tMaskFill(2).opacity= ReflFill(DNSVal)*3: end if' IMG:top half, def glass trans, FLTR:screen,AMT:900,OP:50, AB=off, RGB=0,0,32, DB=-10000,MOD=1
if NOT IsEmpty(tMaskFill(3)) then: tMaskFill(3).opacity= ReflImg(DNSVal): end if' IMG:backglass,   FLTR:screen,AMT:300,OP:1000,AB=on, RBG=16,16,32, DB=-1000,MOD=0.3

if NOT IsEmpty(tMaskFill(1)) then: tMaskFill(1).intensityscale= 0.5: end if
if NOT IsEmpty(tMaskFill(2)) then: tMaskFill(2).intensityscale= 0.5: end if
'backbox glass reflections
if NOT IsEmpty(tMaskFill(0)) then: tMaskFill(0).opacity= ReflFill(DNSVal) +40: end if ' IMG:black mask fill, FLTR:screen,AMT:500,OP:90, AB=off, RGB=0,0,32, DB=-10000,MOD=1
'background reflective image usually __default_screen_space_reflection.png
if NOT IsEmpty(tMaskFill(4)) then: tMaskFill(4).opacity= ReflImg(DNSVal) / 3 : end if' IMG:Def SS Refl, FLTR:screen,AMT:100,OP:1000,AB=on, RBG=10,10,10, DB=-10000,MOD=0.5
Else

if NOT IsEmpty(tMaskFill(0)) then: tMaskFill(0).visible =0: end if
if NOT IsEmpty(tMaskFill(1)) then: tMaskFill(1).visible =0: end if
if NOT IsEmpty(tMaskFill(2)) then: tMaskFill(2).visible =0: end if
if NOT IsEmpty(tMaskFill(3)) then: tMaskFill(3).visible =0: end if
if NOT IsEmpty(tMaskFill(4)) then: tMaskFill(4).visible =0: end if
end if 'cUSEBGLASSREFL

end If ' cUSEBACKGLASS



if cSHADOWBLADES then
' import shadowblade materials.mat to work, duplicate or import _default_gameblades and scale apropriately 
Dim ShadeBladeVals: ShadeBladeVals=Array ("Shadow with an image0","Shadow with an image1",_
"Shadow with an image2","Shadow with an image3", "Shadow with an image3",_
"Shadow with an image4","Shadow with an image4",_
"Shadow with an image5","Shadow with an image5","Shadow with an image5","Shadow with an image5","Shadow with an image5")

ShadowBlades.material = ShadeBladeVals(DNSVal)
end if 'cSHADOWBLADES

if cUSEDUALRAMPS > 0 then ' import both default ramp materials, and default ramp texture
' lightened ramps
Dim RampsVals: RampsVals=Array ("rampsshine9","rampsshine9",_
"rampsshine8","rampsshine8", "rampsshine7","rampsshine7", _
"rampsshine6","rampsshine6", "rampsshine5","rampsshine5", _
"rampsshine4","rampsshine4")
Dim RampBias: RampBias=Array (-1000,-2000,-3000, -4000,-5000,-6000,-7000, -8000,-9000, -10000,-10000,-10000)
'darkened ramps
Dim RampVals: RampVals=Array ("rampshine9","rampshine9",_
"rampshine8","rampshine8", "rampshine7","rampshine7", _
"rampshine6","rampshine6", "rampshine5","rampshine5", _
"rampshine4","rampshine4")

'lightened ramp
if cUSEDUALRAMPS > 1 then
Primitive2.material = RampsVals(DNSVal)
Primitive2.depthBias = RampBias(DNSVal)

' darkened ramp
if cUSEDUALRAMPS > 2 then
Primitive1.material = RampVals(DNSVal)
Primitive1.depthBias = RampBias(DNSVal)
end if 'cUSEDUALRAMPS 2
end if 'cUSEDUALRAMPS 1
end if 'cUSEDUALRAMPS 0


' color grade transition
if cUSECOLORGRADE then
Const nCGDiv = 1.0 ' increase when gets to understaturated at higher light settings
Const rSHIFT = 0 ' increase too saturated at lower light settings
Dim ColValues: ColValues=Array ("_ColorGrade_9_Lite","_ColorGrade_8_Lite","_ColorGrade_7_Lite","_ColorGrade_6_Lite", _
"_ColorGrade_5_Lite","_ColorGrade_4_Lite","_ColorGrade_3_Lite","_ColorGrade_2_Lite","_ColorGrade_1_Lite","_ColorGrade_0_Lite","_ColorGrade_0_Lite","_ColorGrade_0_Lite",_
"_ColorGrade_0_Lite","_ColorGrade_0_Lite","_ColorGrade_0_Lite","_ColorGrade_0_Lite","_ColorGrade_0_Lite","_ColorGrade_0_Lite")

table.ColorGradeImage = ColValues((int)((DNSVal+rSHIFT)/nCGDiv))
end if 'cUSECOLORGRADE


Table.PlayfieldReflectionStrength = ReflDN(DNSVal + 4)

If GILevel = 0 then ' default = Real
For each nxx in aGiLights:nxx.intensity = nxx.intensity * SysDNSVal(DNSVal) /DivValues3(DNSVal) :Next
elseif GILevel = 1 then ' half of real reduced
For each nxx in aGiLights:nxx.intensity = nxx.intensity * SysDNSVal(DNSVal) /DivValues4(DNSVal) :Next
elseif GILevel = 2 then' 1/4 of real reduced
For each nxx in aGiLights:nxx.intensity = nxx.intensity * SysDNSVal(DNSVal) /DivValues5(DNSVal) :Next
elseif GILevel = 3 then' 1/8'th of real reduced
For each nxx in aGiLights:nxx.intensity = nxx.intensity * SysDNSVal(DNSVal) /DivValues6(DNSVal) :Next
elseif GILevel = 4 then' 1/16'th of real reduced
For each nxx in aGiLights:nxx.intensity = nxx.intensity * SysDNSVal(DNSVal) /DivValues7(DNSVal) :Next
elseif GILevel = 5 then' 1/32'th of real reduced
For each nxx in aGiLights:nxx.intensity = nxx.intensity * SysDNSVal(DNSVal) /DivValues8(DNSVal) :Next
end if


If FLLevel = 0 then ' default = Real
For each nxx in aAllFlashers:nxx.amount = nxx.amount / DivValues3(DNSVal):Next
For each nxx in aAllFlashers:nxx.opacity = nxx.opacity * OPSValues(DNSVal) / DivLevel:Next
elseif FLLevel = 1 then ' half of real reduced
For each nxx in aAllFlashers:nxx.amount = nxx.amount / DivValues4(DNSVal):Next
For each nxx in aAllFlashers:nxx.opacity = nxx.opacity * OPSValues2(DNSVal) / DivLevel:Next
elseif FLLevel = 2 then ' 1/4 of real reduced
For each nxx in aAllFlashers:nxx.amount = nxx.amount / DivValues5(DNSVal):Next
For each nxx in aAllFlashers:nxx.opacity = nxx.opacity * OPSValues3(DNSVal) / DivLevel:Next
elseif FLLevel = 3 then ' 1/8'th of real reduced
For each nxx in aAllFlashers:nxx.amount = nxx.amount / DivValues6(DNSVal):Next
For each nxx in aAllFlashers:nxx.opacity = nxx.opacity * OPSValues4(DNSVal) / DivLevel:Next
elseif FLLevel = 4 then ' 1/16'th of real reduced
For each nxx in aAllFlashers:nxx.amount = nxx.amount / DivValues7(DNSVal):Next
For each nxx in aAllFlashers:nxx.opacity = nxx.opacity * OPSValues5(DNSVal) / DivLevel:Next
elseif FLLevel = 5 then ' 1/32'th of real reduced
For each nxx in aAllFlashers:nxx.amount = nxx.amount / DivValues8(DNSVal):Next
For each nxx in aAllFlashers:nxx.opacity = nxx.opacity * OPSValues6(DNSVal) / DivLevel:Next
end If

If BTLevel = 0 then ' default = Real
For each nxx in BloomLights:nxx.intensity = nxx.intensity *SysDNSVal(DNSVal)/DivValues3(DNSVal):Next
For each nxx in TargetDropGi:nxx.intensity = nxx.intensity *SysDNSVal(DNSVal)/DivValues3(DNSVal):Next
elseif BTLevel = 1 then ' half of real reduced
For each nxx in BloomLights:nxx.intensity = nxx.intensity *SysDNSVal(DNSVal)/DivValues4(DNSVal):Next
For each nxx in TargetDropGi:nxx.intensity = nxx.intensity *SysDNSVal(DNSVal)/DivValues4(DNSVal):Next
elseif BTLevel = 2 then' 1/4 of real reduced
For each nxx in BloomLights:nxx.intensity = nxx.intensity *SysDNSVal(DNSVal)/DivValues5(DNSVal):Next
For each nxx in TargetDropGi:nxx.intensity = nxx.intensity *SysDNSVal(DNSVal)/DivValues5(DNSVal):Next
elseif BTLevel = 3 then' 1/8'th of real reduced
For each nxx in BloomLights:nxx.intensity = nxx.intensity *SysDNSVal(DNSVal)/DivValues6(DNSVal):Next
For each nxx in TargetDropGi:nxx.intensity = nxx.intensity *SysDNSVal(DNSVal)/DivValues6(DNSVal):Next
elseif BTLevel = 4 then' 1/16'th of real reduced
For each nxx in BloomLights:nxx.intensity = nxx.intensity *SysDNSVal(DNSVal)/DivValues7(DNSVal):Next
For each nxx in TargetDropGi:nxx.intensity = nxx.intensity *SysDNSVal(DNSVal)/DivValues7(DNSVal):Next
elseif BTLevel = 5 then' 1/32'th of real reduced
For each nxx in BloomLights:nxx.intensity = nxx.intensity *SysDNSVal(DNSVal)/DivValues8(DNSVal):Next
For each nxx in TargetDropGi:nxx.intensity = nxx.intensity *SysDNSVal(DNSVal)/DivValues8(DNSVal):Next
end if


if cDYNPINBALL then
Dim DynPinVals: DynPinVals=Array ("_defballHDR0","_defballHDR0", _
"_defballHDR1","_defballHDR1", "_defballHDR1", _
"_defballHDR2","_defballHDR2", _
"_defballHDR3","_defballHDR3","_defballHDR4","_defballHDR4","_defballHDR4")

Table.ballImage = DynPinVals(DNSVal)
end if 'cDYNPINBALL

if cDYNGAMEBLADES then
Dim DynBladeVals: DynBladeVals=Array ("_defgbladeswoodblack0","_defgbladeswoodblack0",_
"_defgbladeswoodblack1","_defgbladeswoodblack1", "_defgbladeswoodblack1",_
"_defgbladeswoodblack2","_defgbladeswoodblack2",_
"_defgbladeswoodblack3","_defgbladeswoodblack3","_defgbladeswoodblack3","_defgbladeswoodblack3","_defgbladeswoodblack3")

Primitive5.image = DynBladeVals(DNSVal)
Primitive6.image = DynBladeVals(DNSVal)
end if 'cDYNGAMEBLADES


Sub SetSMLiDNS(object, enabled)
	If enabled > 0 then
	object.intensity = enabled * SysDNSVal(DNSVal) /DivValues2(DNSVal)
	Else
	object.intensity =0
	end if	
End Sub

Sub SetSMFlDNS(object, enabled)

	If enabled > 0 then
	object.opacity = enabled / DivValues2(DNSVal) 
	else 
	object.opacity = 0
	end if
End Sub


Sub SetSLiDNS(object, enabled)
	If enabled then
	object.intensity = 1 * SysDNSVal(DNSVal) /DivValues2(DNSVal)
	Else
	object.intensity =0
	end if	
End Sub

Sub SetSFlDNS(object, enabled)

	If enabled then
	object.opacity = 1 * OPSValues(DNSVal) / DivLevel
	else 
	object.opacity = 0
	end if
End Sub


Sub SetDNSFlash(nr, object)
    Select Case LightState(nr)
        Case 0 'off
            FlashLevel(nr) = FlashLevel(nr) - FlashSpeedDown(nr)
            If FlashLevel(nr) < FlashMin(nr) Then
                FlashLevel(nr) = FlashMin(nr)
                LightState(nr) = -1 'completely off, so stop the fading loop
            End if
            Object.IntensityScale = FlashLevel(nr) * SysDNSVal(DNSVal) /DivValues2(DNSVal)
        Case 1 ' on
            FlashLevel(nr) = FlashLevel(nr) + FlashSpeedUp(nr)
            If FlashLevel(nr) > FlashMax(nr) Then
                FlashLevel(nr) = FlashMax(nr)
                LightState(nr) = -1 'completely on, so stop the fading loop
            End if
            Object.IntensityScale = FlashLevel(nr) * SysDNSVal(DNSVal) /DivValues2(DNSVal)
    End Select
End Sub


Sub SetDNSFlashm(nr, object) 'multiple flashers, it just sets the intensity
    Object.IntensityScale = FlashLevel(nr) * SysDNSVal(DNSVal) /DivValues2(DNSVal)
End Sub

Sub SetDNSFlashex(object, value) 'it just sets the intensityscale for non system lights
    Object.IntensityScale = value * SysDNSVal(DNSVal) /DivValues2(DNSVal)
End Sub

' usage: fnColorGradeImage step, nCGDiv
Sub fnColorGradeImage(step, div)
Dim ii
	if cUSECOLORGRADE then
		'table1.ColorGradeImage = ColValues((int)(DNSVal/nCGDiv))
		
			If step = -1 Then
			Table.ColorGradeImage =ColValues((int)((DNSVal+rSHIFT)/nCGDiv)) ' default state
			else
			if (DNSVal - 4) < 0 then '0,1,2
				if step+1 > 5 then 
				ii =2
				elseif  step+1 > 2 then
				ii =1
				Else	
				ii =0
				end if
			Table.ColorGradeImage = ColValues((int)(ii/div)) ' very dark
			Else
				If DNSVal <= 7 then  '3,4,5
					if step+1 > 5 then 
					ii =5
					elseif  step+1 > 2 then
					ii =4
					Else	
					ii =3
					end if
				Table.ColorGradeImage = ColValues((int)(ii/div)) ' average dark
				else 
			
					if step+1 > 5 then 
					ii =8
					elseif  step+1 > 2 then
					ii =7
					Else	
					ii =6
					end if
				table.ColorGradeImage = ColValues((int)(ii/div))
				end if
			end if
			end if
	end if
End Sub

'**************************************************************************************
'               [CC Color Correction] Textures must be CC corrected to work
'**************************************************************************************
Const UseMixGtoB = 1
Dim FlGlobals : FlGlobals=Array (1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.0,5.0)

Dim DivGlobal: DivGlobal = FlGlobals(DNSVal) * 0.7 ' multiply between 1.0 to 0.75, 1.0 = default  
Dim DivClrCor: DivClrCor = 1.2

Dim BlueDiv:BlueDiv  = 1.0* DivGlobal
Dim RedDiv:RedDiv  = 0.9* DivGlobal
Dim RedGreenDiv:RedGreenDiv  = 1.0* DivGlobal
Dim FullSpecDiv:FullSpecDiv  = 0.1* DivGlobal
Dim CCFull: CCFull = 1.3 * DivClrCor
Dim CCBlue: CCBlue = 1.35 * DivClrCor
Dim CCRedGreen: CCRedGreen = 0.9 * DivClrCor
Dim CCRed: CCRed = 0.9 * DivClrCor

' original values depricated
'Dim FlValues : FlValues=Array (1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0)
'Dim AMTValues: AMTValues=Array (500,3000,4000,8000,16000,32000,64000,128000,128000,128000,128000,128000)
'Dim BiasValues: BiasValues=Array (-100,-90,-80,-70,-60,-50,-40,-30,-20,-10,-9,-8)
'Dim MixBlueChan: MixBlueChan=Array (8.0*BlueDiv, 16.0*BlueDiv, 34.0*BlueDiv, 64.0*BlueDiv, 72.0*BlueDiv, 80.0*BlueDiv, 84.0*BlueDiv, 82.0*BlueDiv, 80.0*BlueDiv, 78.0*BlueDiv, 76.0*BlueDiv)  
'Dim MixRedChan: MixRedChan=Array (16.0 * RedDiv, 16.0* RedDiv, 34.0* RedDiv, 64.0* RedDiv, 72.0* RedDiv, 80.0* RedDiv, 84.0* RedDiv, 82.0* RedDiv, 80.0* RedDiv, 78.0* RedDiv, 76.0* RedDiv)  
'Dim MixRedGreenChan: MixRedGreenChan=Array (8.0*RedGreenDiv, 16.0*RedGreenDiv, 34.0*RedGreenDiv, 64.0*RedGreenDiv, 72.0*RedGreenDiv, 80.0*RedGreenDiv, 84.0*RedGreenDiv, 82.0*RedGreenDiv, 80.0*RedGreenDiv, 78.0*RedGreenDiv, 76.0*RedGreenDiv)  
'Dim MixFullSpectrum: MixFullSpectrum=Array (8.0*FullSpecDiv, 16.0*FullSpecDiv, 34.0*FullSpecDiv, 64.0*FullSpecDiv, 72.0*FullSpecDiv, 73.0*FullSpecDiv, 74.0*FullSpecDiv, 74.0*FullSpecDiv, 74.0*FullSpecDiv, 74.0*FullSpecDiv, 74.0*FullSpecDiv)  
'Dim CCFSValues: CCFSValues=Array (100.0*CCFull, 1.0*CCFull, 0.1*CCFull, 0.01*CCFull, 0.001*CCFull, 0.0001*CCFull, 0.0001*CCFull, 0.0001*CCFull, 0.0001*CCFull,0.0001*CCFull,0.0001*CCFull)  
'Dim CCBlueValues: CCBlueValues=Array (0.9*CCBlue, 1.0*CCBlue, 1.2*CCBlue, 1.4*CCBlue, 1.5*CCBlue, 1.55*CCBlue, 1.56*CCBlue, 1.565*CCBlue, 1.568*CCBlue, 1.569*CCBlue, 1.569*CCBlue)  
'Dim MixGtoB : MixGtoB=Array (1,1,2,2,3,4,5,6,7,8,9,10)

'new values
Dim FlValues : FlValues             =Array (1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0)
Dim AMTValues: AMTValues            =Array (500,3000,4000,8000,16000,32000,64000,80000,90000,100000,128000,128000)
Dim BiasValues: BiasValues          =Array (-100,-90,-80,-70,-60,-50,-40,-30,-20,-10,-9,-8)
Dim MixBlueChan: MixBlueChan        =Array (8.0*BlueDiv    , 16.0*BlueDiv    , 19.0*BlueDiv    , 20.0*BlueDiv    , 30.0*BlueDiv    , 60.0*BlueDiv    , 21.0*BlueDiv    , 52.0*BlueDiv    , 70.5*BlueDiv    , 100.0*BlueDiv    , 100.0*BlueDiv)  
Dim MixRedChan: MixRedChan          =Array (8.0*RedDiv     , 16.0* RedDiv    , 19.0* RedDiv    , 20.0* RedDiv    , 30.0* RedDiv    , 60.0* RedDiv    , 21.0* RedDiv    , 52.0* RedDiv    , 70.5* RedDiv    , 100.0* RedDiv    , 100.0* RedDiv)  
'                                                            |                                                                       |                                                                       |
Dim MixRedGreenChan: MixRedGreenChan=Array (8.0*RedGreenDiv, 16.0*RedGreenDiv, 19.0*RedGreenDiv, 20.0*RedGreenDiv, 30.0*RedGreenDiv, 60.0*RedGreenDiv, 21.0*RedGreenDiv, 52.0*RedGreenDiv, 70.5*RedGreenDiv, 100.0*RedGreenDiv, 100.0*RedGreenDiv)  
Dim MixFullSpectrum: MixFullSpectrum=Array (8.0*FullSpecDiv, 16.0*FullSpecDiv, 19.0*FullSpecDiv, 20.0*FullSpecDiv, 30.0*FullSpecDiv, 60.0*FullSpecDiv, 20.0*FullSpecDiv, 52.0*FullSpecDiv, 70.5*FullSpecDiv, 100.0*FullSpecDiv, 100.0*FullSpecDiv)  
Dim CCFSValues: CCFSValues          =Array (100.0*CCFull   , 1.0*CCFull      , 0.1*CCFull      , 0.01*CCFull     , 0.001*CCFull    , 0.0001*CCFull   , 0.0001*CCFull   , 0.0001*CCFull   , 0.0001*CCFull   , 0.0001*CCFull    , 0.0001*CCFull)  
Dim CCBlueValues: CCBlueValues      =Array (0.9*CCBlue     , 1.0*CCBlue      , 1.2*CCBlue      , 1.4*CCBlue      , 1.5*CCBlue      , 1.55*CCBlue     , 1.56*CCBlue     , 1.565*CCBlue    , 1.568*CCBlue    , 1.569*CCBlue     , 1.569*CCBlue)  
Dim MixGtoB : MixGtoB=Array (1,1,2,2,3,4,5,6,7,8,9,10)

Dim FlData : FlData=Array (Flasher3,Flasher4,Flasher5,Flasher6,FlBGBlueSpec,FlBGRedGreenSpec,Empty,Empty)

'Full blue channel
FlData(0).amount = AMTValues(DNSVal ) * DivValues3(DNSVal)
FlData(0).DepthBias = BiasValues(DNSVal) * 100.0
FlData(0).intensityscale = FlData(0).intensityscale * MixBlueChan(DNSVal) '0.0008'
FlData(0).opacity = CCBlueValues(DNSVal) '* CCFSValues(DNSVal)'

'Full blue channel
if UseMixGtoB then
FlData(0).Color = RGB(0, MixGtoB(DNSVal), 20)
end if

'Half red channel
FlData(1).amount = AMTValues(DNSVal ) * DivValues3(DNSVal)
FlData(1).DepthBias = BiasValues(DNSVal) * 100.0
FlData(1).intensityscale = FlData(1).intensityscale * (MixRedChan(DNSVal) * SysDNSVal(DNSVal)) '0.0008'
FlData(1).opacity = CCRed
'Full red/green channel
FlData(2).amount = AMTValues(DNSVal ) * DivValues3(DNSVal)
FlData(2).DepthBias = BiasValues(DNSVal) * 100.0
FlData(2).intensityscale = FlData(2).intensityscale * MixRedGreenChan(DNSVal) '0.0008'
FlData(2).opacity = CCRedGreen
'Full Spectrum
FlData(3).amount = AMTValues(DNSVal ) * (DivValues3(DNSVal) * 0.1)
FlData(3).DepthBias = BiasValues(DNSVal) * 100.0
'FlData(3).intensityscale = FlData(3).intensityscale * MixFullSpectrum(DNSVal) '0.0008'
'FlData(3).opacity = FlData(3).opacity * CCFSValues(DNSVal)

Const USEBGBLUE = 1
Const USEBGREDGREEN = 1
Const nDAMPNBLUE = 1
Const nDAMPNREDGREEN = 1

Dim nbChan: nbChan = 1.0
Dim bCCXDN : bCCXDN=Array (0.1*nbChan,0.2*nbChan,0.3*nbChan,0.4*nbChan,0.5*nbChan,0.6*nbChan,0.7*nbChan,0.8*nbChan,0.9*nbChan,1.0*nbChan,1.0*nbChan,1.0*nbChan,1.0*nbChan,1.0*nbChan)
Dim nrgChan: nrgChan = 1.0
Dim rgCCXDN : rgCCXDN=Array (0.1*nrgChan,0.2*nrgChan,0.3*nrgChan,0.4*nrgChan,0.5*nrgChan,0.6*nrgChan,0.7*nrgChan,0.8*nrgChan,0.9*nrgChan,1.0*nrgChan,1.0*nrgChan,1.0*nrgChan,1.0*nrgChan,1.0*nrgChan)
Dim nnn 

if cUSEBGLASSCCX then

' when too much blue influence dampen blue chan
if nDAMPNBLUE then 
nnn=0
	For each nxx in MixBlueChan
	MixBlueChan(nnn) = MixBlueChan(nnn) * bCCXDN(nnn)
	nnn = nnn +1
	Next
end If 'nDAMPNBLUE

' when too much red/green influence dampen blue chan
if nDAMPNREDGREEN then 
nnn=0
	For each nxx in MixRedGreenChan
	MixRedGreenChan(nnn) = MixRedGreenChan(nnn) * rgCCXDN(nnn)
	nnn = nnn +1
	Next
end if 'nDAMPNREDGREEN

' add (FlBGBlueSpec,FlBGRedGreenSpec) to FlData Array and set indexes correctly
Dim BGCCXVals : BGCCXVals=Array (1.6,1.5,1.4,1.3,1.1,1.03,1.01,1.008,1.005,1.003 , 1.001, 1.0005)
Dim nOff: nOff = 0

if USEBGBLUE then 
FlData(4+nOff).visible = 1
end if
if USEBGREDGREEN then 
FlData(5+nOff).visible = 1
end if

FlData(4+nOff).opacity = OPSValues(DNSVal + DNShift) / DivValues(DNSVal)
FlData(4+nOff).intensityscale = DNSValues(DNSVal + DNShift) /DivValues(DNSVal)


FlData(5+nOff).opacity = OPSValues(DNSVal + DNShift) /DivValues(DNSVal)
FlData(5+nOff).intensityscale = DNSValues(DNSVal + DNShift) /DivValues(DNSVal)


' blue chan
FlData(4+nOff).amount = AMTValues(DNSVal ) * (DivValues3(DNSVal) * BGCCXVals(DNSVal) )' 0.001)
FlData(4+nOff).DepthBias = BiasValues(DNSVal) * 100.0
FlData(4+nOff).intensityscale = FlData(4+nOff).intensityscale * MixBlueChan(DNSVal) '0.0008'
FlData(4+nOff).opacity = CCBlueValues(DNSVal)  '* CCFSValues(DNSVal)'
' red green chan
FlData(5+nOff).amount = AMTValues(DNSVal ) * (DivValues3(DNSVal) * BGCCXVals(DNSVal) ) '0.001)
FlData(5+nOff).DepthBias = BiasValues(DNSVal) * 100.0
FlData(5+nOff).intensityscale = FlData(5+nOff).intensityscale * MixRedGreenChan(DNSVal) '0.0008'
FlData(5+nOff).opacity = CCRedGreen 

end if 'cUSEBGLASSCCX

if cUSECCUPBOOST then
Dim DivCCUP: DivCCUP = 0.8

'original values depricated
'Dim CCUPValues : CCUPValues=Array (1.0*DivCCUP,1.0*DivCCUP,1.0*DivCCUP,1.5*DivCCUP,2.5*DivCCUP,5.0*DivCCUP,10.0*DivCCUP,20.0*DivCCUP,30.0*DivCCUP,40.0*DivCCUP,40.0*DivCCUP)
'new values
Dim CCUPValues : CCUPValues=Array (1.0*DivCCUP,1.0*DivCCUP,1.0*DivCCUP,1.5*DivCCUP,2.5*DivCCUP,5.0*DivCCUP,10.0*DivCCUP,12.0*DivCCUP,20.0*DivCCUP,40.0*DivCCUP,40.0*DivCCUP)

FlData(3).intensityscale = FlData(3).intensityscale * MixFullSpectrum(DNSVal) * CCUPValues(DNSVal)'0.0008'
FlData(3).opacity = FlData(3).opacity * CCFSValues(DNSVal) * CCUPValues(DNSVal)
Else
FlData(3).intensityscale = FlData(3).intensityscale * MixFullSpectrum(DNSVal) '0.0008'
FlData(3).opacity = FlData(3).opacity * CCFSValues(DNSVal)
end if 'cUSECCUPBOOST


FlValues(0) = FlData(0).intensityscale
FlValues(1) = FlData(1).intensityscale
FlValues(2) = FlData(2).intensityscale
FlValues(3) = FlData(3).intensityscale

' ***************************************************************************
' TABLE surface and reflexion shifting for CC and D&N 
' ***************************************************************************
Const Forward = 170 ' 150
Const Height = 250 '250
Const RotX = -5 ' -5
'Full
FlData(0).y = FlData(0).y + Forward
FlData(0).Height = Height
FlData(0).RotX = Rotx
' upper half
FlData(1).y = FlData(1).y + Forward
FlData(1).Height = Height + 50
FlData(1).RotX = Rotx
'full
FlData(2).y = FlData(2).y + Forward
FlData(2).Height = Height
FlData(2).RotX = Rotx
' half
FlData(3).y = FlData(3).y + Forward
FlData(3).Height = Height+ 50
FlData(3).RotX = Rotx

if NOT IsEmpty(FlData(4)) then
FlData(4).y = FlData(4).y + Forward
FlData(4).Height = Height
FlData(4).RotX = Rotx
End if

'BGMirror.y = FlData().y + Forward
'BGMirror.Height = Height
'BGMirror.RotX = Rotx

' ***************************************************************************


LoadVPM "01560000", "sam.VBS", 3.10
 
'********************
'Standard definitions
'********************
 
    Const cGameName = "wpt_140a" 'change the romname here
 
     Const UseSolenoids = 1
     Const UseLamps = 0
     Const UseSync = 1
     Const HandleMech = 0
 
     'Standard Sounds
     Const SSolenoidOn = "Solenoid"
     Const SSolenoidOff = ""
     Const SCoin = "coin"
 
'************
' Table init.
'************
   'Variables
    Dim xx
    Dim Bump1,Bump2,Bump3,Mech3bank,bsTrough,bsVUK,visibleLock,bsTEject,bsSVUK,bsRScoop
    Dim dtUDrop,dtLDropLower,dtLDropUpper,dtRDrop
    Dim PlungerIM
    Dim PMag



'***** INIT *****
  Sub Table_Init

    With Controller
        .GameName = cGameName
        If Err Then MsgBox "Can't start Game " & cGameName & vbNewLine & Err.Description:Exit Sub
        .SplashInfoLine = "WPT"
        .HandleKeyboard = 0
        .ShowTitle = 0
        .ShowDMDOnly = 1
        .ShowFrame = 0
        .HandleMechanics = 1
        .Hidden = 0
        .Games(cGameName).Settings.Value("sound") = 1
        On Error Resume Next
        .Run GetPlayerHWnd
        If Err Then MsgBox Err.Description
    End With
 
 
    On Error Goto 0
 
    Const IMPowerSetting = 50
    Const IMTime = 0.6
    Set plungerIM = New cvpmImpulseP
    With plungerIM
        .InitImpulseP swplunger, IMPowerSetting, IMTime
        .Switch 23
        .Random 1.5
        .InitExitSnd SoundFX("plunger",DOFContactors), SoundFX("plunger",DOFContactors)
        .CreateEvents "plungerIM"
    End With
 
'**Trough
    Set bsTrough = New cvpmBallStack
    bsTrough.InitSw 0, 21, 20, 19, 18, 0, 0, 0
    bsTrough.InitKick BallRelease, 90, 8
    bsTrough.InitExitSnd SoundFX("ballrelease",DOFContactors), SoundFX("Solenoid",DOFContactors)
    bsTrough.Balls = 4
 
    Set bsSVUK=New cvpmBallStack
    bsSVUK.InitSw 0,3,0,0,0,0,0,0
    bsSVUK.InitKick TopLaneKicker,0,20
    bsSVUK.InitExitSnd SoundFX("warehousekick",DOFContactors), SoundFX("wireramp",DOFContactors)
 
    Set bsVUK=New cvpmBallStack
    bsVUK.InitSw 0,55,0,0,0,0,0,0
    bsVUK.InitKick LeftVUKTop,180,12
    bsVUK.InitExitSnd SoundFX("scoopexit",DOFContactors), SoundFX("rail",DOFContactors)
 
    Set bsRScoop=New cvpmBallStack
    bsRScoop.InitSw 0,49,0,0,0,0,0,0   
    bsRScoop.InitKick sw49,270,32
    bsRScoop.InitExitSnd SoundFX("popperball",DOFContactors), SoundFX("rail",DOFContactors)
   
'**Nudging
'       vpmNudge.TiltSwitch=-7
'       vpmNudge.Sensitivity=1
'       vpmNudge.TiltObj=Array(Bumper1b,Bumper2b,Bumper3b,LeftSlingshot,RightSlingshot)
 
     Set dtLDropLower = new cvpmDropTarget
     With dtLDropLower
          .Initdrop Array(sw33, sw34, sw35, sw36), Array(33, 34, 35, 36)
          .InitSnd SoundFX("DTL",DOFDropTargets),SoundFX("DTResetL",DOFDropTargets)
      End With
 
     Set dtLDropUpper = new cvpmDropTarget
     With dtLDropUpper
          .Initdrop Array(sw37, sw38, sw39, sw40), Array(37, 38, 39, 40)
          .InitSnd SoundFX("DTL",DOFDropTargets),SoundFX("DTResetL",DOFDropTargets)
      End With
 
     Set dtUDrop = new cvpmDropTarget
     With dtUDrop
          .Initdrop Array(sw10, sw11, sw12, sw13), Array(10, 11, 12, 13)
          .InitSnd SoundFX("DTL",DOFDropTargets),SoundFX("DTResetL",DOFDropTargets)
      End With
 
     Set dtRDrop = new cvpmDropTarget
     With dtRDrop
          .Initdrop Array(sw4, sw5, sw6, sw7), Array(4, 5, 6, 7)
          .InitSnd SoundFX("DTR",DOFDropTargets),SoundFX("DTResetR",DOFDropTargets)
      End With
 
      '**Main Timer init
    PinMAMETimer.Interval = PinMAMEInterval
    PinMAMETimer.Enabled = 1
 
    If GIOnDuringAttractMode = 1 Then GI_AllOn
 

	InitVpmFFlipsSAM

	setup_backglass()


  End Sub
 
' ***************************************************************************
'                    BASIC FSS(DMD,SS,EM) SETUP CODE
' ****************************************************************************

const USEEM = 0
const USESS = 0 
const nUSEDMD =1 ' 0=no DMD, 1= DMD 2= DMD +mirror DMD

Dim xoff,yoff,zoff,xrot,zscale, xcen,ycen

sub setup_backglass()

xoff =500
yoff =0
zoff =850
xrot = -90

if cUSEBACKGLASS then
bgdark.x = xoff
bgdark.y = yoff
bgdark.height = zoff
bgdark.rotx = xrot

bgHigh.x = xoff
bgHigh.y = yoff
bgHigh.height = zoff
bgHigh.rotx = xrot
	
bgHigh1.x = xoff
bgHigh1.y = yoff
bgHigh1.height = zoff
bgHigh1.rotx = xrot

bgHigh2.x = xoff
bgHigh2.y = yoff 
bgHigh2.height = zoff
bgHigh2.rotx = xrot

bgFrame.x = xoff
bgFrame.y = yoff 
bgFrame.height = zoff
bgFrame.rotx = xrot

if 1 then
BGFrameMask.x = xoff
BGFrameMask.y = yoff 
BGFrameMask.height = zoff
BGFrameMask.rotx = xrot


BGFrameMaskFill.x = xoff 
BGFrameMaskFill.y = yoff 
BGFrameMaskFill.height = zoff 
BGFrameMaskFill.rotx = xrot
end if

if cUSEBGLASSREFL then

' the mask fill image
if NOT IsEmpty(tMaskFill(0)) then 
BGFrameMaskFill1.x = xoff
BGFrameMaskFill1.y = yoff 
BGFrameMaskFill1.height = zoff+10
BGFrameMaskFill1.rotx = xrot
end If
' the background reflective image usually __default_screen_space_reflection.png
if NOT IsEmpty(tMaskFill(4)) then
BGFrameMaskFill5.x = xoff
BGFrameMaskFill5.y = yoff 
BGFrameMaskFill5.height = zoff-250 ' adjust value to correct vertical 
BGFrameMaskFill5.rotx = xrot
end if
end if 'cUSEBGLASSREFL


if cUSEBGLASSCCX then
FlBGRedGreenSpec.x = xoff
FlBGRedGreenSpec.y = yoff
FlBGRedGreenSpec.height = zoff
FlBGRedGreenSpec.rotx = xrot

FlBGBlueSpec.x = xoff
FlBGBlueSpec.y = yoff
FlBGBlueSpec.height = zoff
FlBGBlueSpec.rotx = xrot
end if ' cUSEBGLASSCCX
end if  'cUSEBACKGLASS

' ********************************
'           TOPPER SCRIPT
' ********************************

if cUSETOPPER then

Dim topoff

' the topper
	topoff = 590
If Table.inclination >= 65.0 then

	TopDark.x = xoff
	TopDark.y = yoff
	TopDark.height = zoff +topoff
	TopDark.rotx = xrot

	TopHigh.x = xoff
	TopHigh.y = yoff
	TopHigh.height = zoff +topoff
	TopHigh.rotx = xrot

	TopHigh1.x = xoff
	TopHigh1.y = yoff
	TopHigh1.height = zoff +topoff
	TopHigh1.rotx = xrot


	TopHigh2.x = xoff
	TopHigh2.y = yoff
	TopHigh2.height = zoff +(topoff)
	TopHigh2.rotx = xrot
	
else
end if
end if ' cUSETOPPER

	if nUSEDMD >= 1 then
	DMD.x = xoff
	DMD.y = yoff
	DMD.height = zoff - 330
	DMD.rotx = xrot

	'DMD mirror
		if nUSEDMD > 1 then
		DMD1.x = xoff
		DMD1.y = yoff + 250
		DMD1.height = zoff - 500
		DMD1.rotx = xrot +180
		DMD1.visible =1
		end if
	end if 'nUSEDMD
	
	
center_graphix()
'center_digits()
'center_objects() 'always calllast

	if USEEM = 1 then
	For  ix =0 to 4
	SetDrum ix, 1 , 0 
	SetDrum ix, 2 , 0  
	SetDrum ix, 3 , 0  
	SetDrum ix, 4 , 0  
	SetDrum ix, 5 , 0  
	Next 

	cred =reels(4, 0)
	reels(4, 0) = 0
	SetDrum -1,0,  0
	
	SetReel 0,-1,  Credit
	reels(4, 0) = Credit
	end if 'USEEM
	
end sub

' ********************* POSITION IMAGES(flashers) ON BACKGLASS *************************

Dim BGArr 
BGArr=Array(Flasher7,Flasher8,Flasher9,Flasher10,_
Flasher11,Flasher12,Flasher13,Flasher14,Flasher15,Flasher16,_
Flasher17,Flasher18,Flasher19, Flasher20,Flasher21,Flasher22) 


Sub center_graphix()
Dim xx,yy,yfact,xfact,xobj
zscale = 0.00000001

xcen =(1053 /2) - (147 / 2)
ycen = (1026 /2 ) + (155 /2)


yfact =0 'y fudge factor (ycen was wrong so fix)
xfact =0

	For Each xobj In BGArr
	if Not IsEmpty(xobj) then
	xx =xobj.x 
		
	xobj.x = (xoff -xcen) + xx +xfact
	yy = xobj.y ' get the yoffset before it is changed
	xobj.y =yoff 

		If(yy < 0.) then
		yy = yy * -1
		end if

	
	xobj.height =( zoff - ycen) + yy - (yy * zscale) + yfact
	
	xobj.rotx = xrot
	xobj.visible =1 ' for testing
	end if
	Next
end sub

Sub center_graphix_ex(nobj, nyo, nyf, nxf, nzs)
Dim xx,yy,yfact,xfact,xobj
zscale = nzs'0.13
'xrot = xrot +10
yoff =nyo'0
xcen =(1028 /2) - (2 / 2)
ycen = (1411 /2 ) + (35 /2)


yfact =nyf 'y fudge factor (ycen was wrong so fix)
xfact =nxf

	For Each xobj In nobj
	xx =xobj.x 
		
	xobj.x = (xoff -xcen) + xx +xfact
	yy = xobj.y ' get the yoffset before it is changed
	xobj.y =yoff 

		If(yy < 0.) then
		yy = yy * -1
		end if

	
	xobj.height =( zoff - ycen) + yy - (yy * zscale) + yfact
	
	xobj.rotx = xrot
	xobj.visible =1 ' for testing
	Next
end sub


'*****Keys
Sub Table_KeyDown(ByVal Keycode)
 
 
    If Keycode = LeftFlipperKey then
 
    End If
    If Keycode = RightFlipperKey then
 
    End If
    If keycode = PlungerKey Then Plunger.Pullback:playsound "plungerpull"
    If keycode = LeftTiltKey Then nudgebobble(keycode):End If
    If keycode = RightTiltKey Then nudgebobble(keycode):End If
   'If keycode = CenterTiltKey Then CenterNudge 0, 1, 25 End If
   If vpmKeyDown(keycode) Then Exit Sub
End Sub
   
 
 
Sub Table_KeyUp(ByVal keycode)
    If vpmKeyUp(keycode) Then Exit Sub
    If Keycode = LeftFlipperKey then
 
    End If
    If Keycode = RightFlipperKey then
 
    End If
    If Keycode = StartGameKey Then Controller.Switch(16) = 0
    If keycode = PlungerKey Then
        Plunger.Fire
        playsound "plunger"
'        If(BallinPlunger = 1) then 'the ball is in the plunger lane
'            PlaySound SoundFX("Plunger2")
'        else
'            PlaySound "Plunger"
'        end if
    End If
End Sub
 
   'Solenoids
SolCallback(1) = "solTrough"
SolCallback(2) = "solAutofire"
SolCallback(3) = "bsSVUK.SolOut"
SolCallback(4) = "bSVUK.SolOut"
SolCallback(5) = "dtLDropLower.SolDropUp"
SolCallback(6) = "dtLDropUpper.SolDropUp"  
SolCallback(7) = "dtUDrop.SolDropUp"
SolCallback(8) = "dtRDrop.SolDropUp"
''SolCallback(9) = "SolLeftPop" 'left pop bumper
''SolCallback(10) = "SolRightPop" 'right pop bumper
''SolCallback(11) = "SolBottomPop" 'top pop bumper
SolCallback(12) = "SolJailUp"
'SolCallback(13) = "SolULFlipper" ' commented out for SAM fastflips
'SolCallback(14) = "SolURFlipper" ' commented out for SAM fastflips
SolCallback(15) = "SolLFlipper"
SolCallback(16) = "SolRFlipper"
''SolCallBack(13)="vpmSolFlipper UpLeftFlipper,Nothing,"'Upper PF Left Flipper
''SolCallBack(14)="vpmSolFlipper UpRightFlipper,Nothing,"'Upper PF Right Flipper
''SolCallBack(15)="vpmSolFlipper LeftFlipper,Nothing,"'Left Flipper
''SolCallBack(16)="vpmSolFlipper RightFlipper,Flipper2,"'Right Flipper
'
''SolCallback(17) = 'left slingshot
''SolCallback(18) = 'right slingshot
SolCallback(19) = "SolJailLatch" 'jail latch
SolCallback(20) = "LRPost"
'SolCallBack(21) = "bsRScoop.SolOut"
SolCallback(21) = "ScoopOut"
SolCallback(22) = "LeftSlingFlash" 'left slingshot flasher
SolCallback(23) = "RightSlingFlash" 'right slingshot flasher
'
''SolCallback(24) = "vpmSolSound SoundFX(""knocker""),"
SolCallback(25) = "FlashLeft" 'flash left spinner
SolCallback(26) = "BackPanel1" 'back panel 1 left
SolCallback(27) = "BackPanel2" 'back panel 2
SolCallback(28) = "BackPanel3" 'back panel 3
SolCallback(29) = "BackPanel4" 'back panel 4
SolCallback(30) = "BackPanel5" 'back panel 5 right
SolCallback(31) = "FlashVUK" 'right vuk flash
SolCallback(32) = "RRDownPost" 'right ramp post
''SolCallback(sLLFlipper)="vpmSolFlipper LeftFlipper,UpLeftFlipper,"
''SolCallback(sLRFlipper)="vpmSolFlipper RightFlipper,UpRightFlipper,"
 
 
Sub SolLFlipper(Enabled)
     If Enabled Then
        PlaySound SoundFXDOF("flipperupleft",102,DOFOn,DOFFlippers)
        LeftFlipper.RotateToEnd
        UpLeftFlipper.RotateToEnd
     Else
        PlaySound SoundFXDOF("flipperdown",102,DOFOff,DOFFlippers)
        LeftFlipper.RotateToStart
        UpLeftFlipper.RotateToStart
     End If
 End Sub
 
Sub SolRFlipper(Enabled)
     If Enabled Then
         PlaySound SoundFXDOF("flipperupright",103,DOFOn,DOFFlippers)
         RightFlipper.RotateToEnd
         UpRightFlipper.RotateToEnd
     Else
         PlaySound SoundFXDOF("flipperdown",103,DOFOff,DOFFlippers)
         RightFlipper.RotateToStart
         UpRightFlipper.RotateToStart
    End If
 End Sub
 
Sub SolULFlipper(Enabled)
     If Enabled Then
         PlaySound SoundFXDOF("flipperupleft",102,DOFOn,DOFFlippers)
         UpLeftFlipper.RotateToEnd
     Else
         PlaySound SoundFXDOF("flipperdown",102,DOFOff,DOFFlippers)
         UpLeftFlipper.RotateToStart
     End If
 End Sub
 
Sub SolURFlipper(Enabled)
     If Enabled Then
         PlaySound SoundFXDOF("flipperupright",103,DOFOn,DOFFlippers)
         UpRightFlipper.RotateToEnd
     Else
         PlaySound SoundFXDOF("flipperdown",103,DOFOff,DOFFlippers)
         UpRightFlipper.RotateToStart
    End If
 End Sub  
 
Sub ScoopOut(enabled)
    If Enabled Then
        sw49.kick 270, 32
        Controller.Switch(49) = 0
        playsound SoundFX("popper_ball",DOFContactors)
    End If
End Sub
 
Sub LeftSlingFlash(Enabled)
    If Enabled Then
        SetLamp 122, 1
        SetFlash 132, 1
        'LFLogo.image = "flipper-l2red"
    Else
        SetLamp 122, 0
        SetFlash 132, 0
        'if GI_TroughCheck < 4 then LFLogo.image = "flipper-l2" else LFLogo.image = "flipper-l2off"
    End If
End Sub
 
Sub RightSlingFlash(Enabled)
    If Enabled Then
        SetLamp 123, 1
        SetFlash 133, 1
        'RFLogo.image = "flipper-r2red"
    Else
        SetLamp 123, 0
        SetFlash 133, 0
        'if GI_TroughCheck < 4 then RFLogo.image = "flipper-r2" else RFLogo.image = "flipper-r2off"
    End If
End Sub
 
Sub FlashLeft(Enabled)
    If Enabled Then
        SetLamp 125, 1
        SetFlash 135, 1
    Else
        SetLamp 125, 0
        SetFlash 135, 0
    End If
End Sub
 
Sub BackPanel1(Enabled)
    If Enabled Then
        SetLamp 126, 1
        SetFlash 136, 1
        'LFLogo1.image = "flipper-l2red"
    Else
        SetLamp 126, 0
        SetFlash 136, 0
        'if GI_TroughCheck < 4 then LFLogo1.image = "flipper-l2" else LFLogo1.image = "flipper-l2off"
    End If
End Sub
 
Sub BackPanel2(Enabled)
    If Enabled Then
        SetLamp 127, 1
        SetFlash 137, 1
        'LFLogo1.image = "flipper-l2red"
        'RFLogo1.image = "flipper-r2red"
    Else
        SetLamp 127, 0
        SetFlash 137, 0
        'if GI_TroughCheck < 4 then LFLogo1.image = "flipper-l2" else LFLogo1.image = "flipper-l2off"
        'if GI_TroughCheck < 4 then RFLogo1.image = "flipper-r2" else RFLogo1.image = "flipper-r2off"
    End If
End Sub
 
Sub BackPanel3(Enabled)
    If Enabled Then
        SetLamp 128, 1
        SetFlash 138, 1
        'LFLogo1.image = "flipper-l2red"
        'RFLogo1.image = "flipper-r2red"
    Else
        SetLamp 128, 0
        SetFlash 138, 0
        'if GI_TroughCheck < 4 then LFLogo1.image = "flipper-l2" else LFLogo1.image = "flipper-l2off"
        'if GI_TroughCheck < 4 then RFLogo1.image = "flipper-r2" else RFLogo1.image = "flipper-r2off"
    End If
End Sub
 
Sub BackPanel4(Enabled)
    If Enabled Then
        SetLamp 129, 1
        SetFlash 139, 1
        'LFLogo1.image = "flipper-l2red"
        'RFLogo1.image = "flipper-r2red"
    Else
        SetLamp 129, 0
        SetFlash 139, 0
        'if GI_TroughCheck < 4 then LFLogo1.image = "flipper-l2" else LFLogo1.image = "flipper-l2off"
        'if GI_TroughCheck < 4 then RFLogo1.image = "flipper-r2" else RFLogo1.image = "flipper-r2off"
    End If
End Sub
 
Sub BackPanel5(Enabled)
    If Enabled Then
        SetLamp 130, 1
        SetFlash 140, 1
        'RFLogo1.image = "flipper-r2red"
    Else
        SetLamp 130, 0
        SetFlash 140, 0
        'if GI_TroughCheck < 4 then RFLogo1.image = "flipper-r2" else RFLogo1.image = "flipper-r2off"
    End If
End Sub
 
Sub FlashVUK(Enabled)
    If Enabled Then
        SetLamp 131, 1
        SetFlash 141, 1
    Else
        SetLamp 131, 0
        SetFlash 141, 0
    End If
End Sub
'
Sub SolJailLatch(Enabled)
    If Enabled Then 'close jail
        JailDiv.IsDropped = false
        JailDiv1.IsDropped = false
        JailDiv2.IsDropped = false
        Controller.Switch(63)=0
    End If
End Sub
 
Sub SolJailUp(Enabled)
    If Enabled Then
        JailDiv.IsDropped = true
        JailDiv1.IsDropped = true
        JailDiv2.IsDropped = true
        Controller.Switch(63)=1
    End If
End Sub
 
Sub RRDownPost(Enabled)
    If Enabled Then
        RightPost.IsDropped = False
    Else
        RightPost.IsDropped = True
    End If
End Sub
 
Sub LRPost(Enabled)
    If Enabled Then
        LeftPost.IsDropped = False
    Else
        LeftPost.IsDropped = True
    End If
End Sub
 
Sub solTrough(Enabled)
    If Enabled Then
        bsTrough.ExitSol_On
        vpmTimer.PulseSw 22
    End If
 End Sub
 
Sub solAutofire(Enabled)
    If Enabled Then
        PlungerIM.AutoFire
    End If
 End Sub
 
 
Sub LeftSlingShot_Slingshot
    'Leftsling = True
    Controller.Switch(26) = 1
    PlaySound Soundfx("left_slingshot",DOFContactors):LeftSlingshot.TimerEnabled = 1
    left1f.rotatetoend
    left2f.rotatetoend
    left3f.rotatetoend
  End Sub
 
'Dim Leftsling:Leftsling = False
 
'Sub LS_Timer()
    'If Leftsling = True and Left1.ObjRotZ < -7 then Left1.ObjRotZ = Left1.ObjRotZ + 2
    'If Leftsling = False and Left1.ObjRotZ > -20 then Left1.ObjRotZ = Left1.ObjRotZ - 2
    'If Left1.ObjRotZ >= -7 then Leftsling = False
    'If Leftsling = True and Left2.ObjRotZ > -212.5 then Left2.ObjRotZ = Left2.ObjRotZ - 2
    'If Leftsling = False and Left2.ObjRotZ < -199 then Left2.ObjRotZ = Left2.ObjRotZ + 2
    'If Left2.ObjRotZ <= -212.5 then Leftsling = False
    'If Leftsling = True and Left3.TransZ > -23 then Left3.TransZ = Left3.TransZ - 4
    'If Leftsling = False and Left3.TransZ < -0 then Left3.TransZ = Left3.TransZ + 4
    'If Left3.TransZ <= -23 then Leftsling = False
    'If Leftsling = True then left1f.rotatetoend
    'If Leftsling = False then left1f.rotatetostart
    'If Leftsling = True then left2f.rotatetoend
    'If Leftsling = False then left2f.rotatetostart
    'If left1f.currentangle = -212 then Leftsling = False
'   Left1.ObjRotZ = left1f.currentangle
'   Left2.ObjRotZ = left2f.currentangle
'   Left3.TransZ = left3f.currentangle
'End Sub
 
 Sub LeftSlingShot_Timer:Me.TimerEnabled = 0:Controller.Switch(26) = 0:left1f.rotatetostart:left2f.rotatetostart:left3f.rotatetostart:End Sub
 
 Sub RightSlingShot_Slingshot
    'Rightsling = True
    Controller.Switch(27) = 1
    PlaySound Soundfx("right_slingshot",DOFContactors):RightSlingshot.TimerEnabled = 1
    right1f.rotatetoend
    right2f.rotatetoend
    right3f.rotatetoend
  End Sub
 
 'Dim Rightsling:Rightsling = False
 
'Sub RS_Timer()
'   If Rightsling = True and Right1.ObjRotZ > 7 then Right1.ObjRotZ = Right1.ObjRotZ - 2
'   If Rightsling = False and Right1.ObjRotZ < 20 then Right1.ObjRotZ = Right1.ObjRotZ + 2
'   If Right1.ObjRotZ <= 7 then Rightsling = False
'   If Rightsling = True and Right2.ObjRotZ < 212.5 then Right2.ObjRotZ = Right2.ObjRotZ + 2
'   If Rightsling = False and Right2.ObjRotZ > 199 then Right2.ObjRotZ = Right2.ObjRotZ - 2
'   If Right2.ObjRotZ >= 212.5 then Rightsling = False
'   If Rightsling = True and Right3.TransZ > -23 then Right3.TransZ = Right3.TransZ - 4
'   If Rightsling = False and Right3.TransZ < -0 then Right3.TransZ = Right3.TransZ + 4
'   If Right3.TransZ <= -23 then Rightsling = False
'End Sub
 
 Sub RightSlingShot_Timer:Me.TimerEnabled = 0:Controller.Switch(27) = 0:right1f.rotatetostart:right2f.rotatetostart:right3f.rotatetostart:End Sub
 
      Sub Bumper1b_Hit
      vpmTimer.PulseSw 30
      PlaySound SoundFX("bumperright",DOFContactors)
        End Sub
     
 
      Sub Bumper2b_Hit
      vpmTimer.PulseSw 31
      PlaySound SoundFX("bumperright",DOFContactors)
       End Sub
 
      Sub Bumper3b_Hit
      vpmTimer.PulseSw 32
      PlaySound SoundFX("bumperright",DOFContactors)
       End Sub
 
 
 
Sub LaneKicker_Hit:
    bsSVUK.AddBall Me:
    playsound "safehousehit"
End Sub
 
Sub LeftVUK_Hit:   
    'GI_AllOff 1000
	PlaySound "kicker_enter_center"
    bsVUK.AddBall Me:
End Sub
 
Sub LeftVUKTop_Hit:
	PlaySound "kicker_enter_center"
    bsVUK.AddBall Me:
End Sub
 
Sub ScoopTrigger_Hit:Controller.Switch(54) = 1:playsound SoundFX("scoopleft",DOFContactors):End Sub
Sub ScoopTrigger_UnHit:Controller.Switch(54) = 0:End Sub
 
Sub ScoopUp_Hit
    ScoopUp.TimerEnabled = true
    'Controller.Switch(54) = true
 
    ScoopUp.Enabled = false
    PlaySound SoundFX("scoopleft",DOFContactors)
    'ScoopUp.KickZ 0, 35, 1, 1
    ScoopUp.Kick 0, 30, 90
End Sub
 
Sub ScoopUp_Timer:Me.TimerEnabled = false:ScoopUp.Enabled = true:End Sub'Controller.Switch(54) = false:End Sub
 
Dim BallInJail:BallInJail=FALSE
Sub JailDiv_Hit
    If BallInJail=TRUE Then
        Controller.Switch(58)=0
        sw58.TimerEnabled=1
    Else
        vpmTimer.PulseSw 57
    End If
End Sub
 
Sub sw58_Hit
    BallInJail=TRUE
    Controller.Switch(58)=1
    'FlasherJail.Alpha = 255
End Sub
 
Sub sw58_unHit
    BallInJail=FALSE
    Controller.Switch(58)=0
    'FlasherJail.Alpha = 0
End Sub
 
Sub sw58_Timer
    sw58.TimerEnabled=0
    If BallInJail=TRUE Then Controller.Switch(58)=1
End Sub
 
Sub BallJailT_Timer()
    if BallInJail = true then
        'FlasherJail.Alpha = 255
    Else
        'FlasherJail.Alpha = 0
    End If
End Sub
 
Sub sw8s_Spin:vpmTimer.PulseSw 8:   PlaySound "fx_spinner",0,.25,0,0.25:End Sub
Sub sw53s_Spin: PlaySound "fx_spinner",0,.25,0,0.25:End Sub
Sub sw44s_Spin: PlaySound "fx_spinner",0,.25,0,0.25:End Sub
Sub leftramps_Spin: PlaySound "fx_spinner",0,.25,0,0.25:End Sub
Sub sw50s_Spin: PlaySound "fx_spinner",0,.25,0,0.25:End Sub
Sub sw51s_Spin: PlaySound "fx_spinner",0,.25,0,0.25:End Sub
 
Sub sw24_Hit:Me.TimerEnabled = 1:Controller.Switch(24) = 1:PlaySound "rollover":End Sub
Sub sw24_Timer:Me.TimerEnabled = 0:Controller.Switch(24) = 0:End Sub
Sub sw25_Hit:Me.TimerEnabled = 1:Controller.Switch(25) = 1:PlaySound "rollover":End Sub
Sub sw25_Timer:Me.TimerEnabled = 0:Controller.Switch(25) = 0:End Sub
Sub sw28_Hit:Me.TimerEnabled = 1:Controller.Switch(28) = 1:PlaySound "rollover":End Sub
Sub sw28_Timer:Me.TimerEnabled = 0:Controller.Switch(28) = 0:End Sub
Sub sw29_Hit:Me.TimerEnabled = 1:Controller.Switch(29) = 1:PlaySound "rollover":End Sub
Sub sw29_Timer:Me.TimerEnabled = 0:Controller.Switch(29) = 0:End Sub
 
Sub sw33_Hit:Me.TimerEnabled = 1:dtLDropLower.Hit 1:End Sub
Sub sw33_Timer:Me.TimerEnabled = 0:End Sub
Sub sw34_Hit:Me.TimerEnabled = 1:dtLDropLower.Hit 2:End Sub
Sub sw34_Timer:Me.TimerEnabled = 0:End Sub
Sub sw35_Hit:Me.TimerEnabled = 1:dtLDropLower.Hit 3:End Sub
Sub sw35_Timer:Me.TimerEnabled = 0:End Sub
Sub sw36_Hit:Me.TimerEnabled = 1:dtLDropLower.Hit 4:End Sub
Sub sw36_Timer:Me.TimerEnabled = 0:End Sub
 
Sub sw37_Hit:Me.TimerEnabled = 1:dtLDropUpper.Hit 1:End Sub
Sub sw37_Timer:Me.TimerEnabled = 0:End Sub
Sub sw38_Hit:Me.TimerEnabled = 1:dtLDropUpper.Hit 2:End Sub
Sub sw38_Timer:Me.TimerEnabled = 0:End Sub
Sub sw39_Hit:Me.TimerEnabled = 1:dtLDropUpper.Hit 3:End Sub
Sub sw39_Timer:Me.TimerEnabled = 0:End Sub
Sub sw40_Hit:Me.TimerEnabled = 1:dtLDropUpper.Hit 4:End Sub
Sub sw40_Timer:Me.TimerEnabled = 0:End Sub
 
Sub sw9_Hit  : Controller.Switch(9) = 1: End Sub 'right ramp enter
Sub sw9_UnHit: Controller.Switch(9) = 0: End Sub
 
Sub sw10_Hit:Me.TimerEnabled = 1:dtUDrop.Hit 1:End Sub
Sub sw10_Timer:Me.TimerEnabled = 0:End Sub
Sub sw11_Hit:Me.TimerEnabled = 1:dtUDrop.Hit 2:End Sub
Sub sw11_Timer:Me.TimerEnabled = 0:End Sub
Sub sw12_Hit:Me.TimerEnabled = 1:dtUDrop.Hit 3:End Sub
Sub sw12_Timer:Me.TimerEnabled = 0:End Sub
Sub sw13_Hit:Me.TimerEnabled = 1:dtUDrop.Hit 4:End Sub
Sub sw13_Timer:Me.TimerEnabled = 0:End Sub
Sub sw14_Hit:vpmTimer.PulseSw 14:End Sub
 
Sub sw4_Hit:Me.TimerEnabled = 1:dtRDrop.Hit 1:End Sub
Sub sw4_Timer:Me.TimerEnabled = 0:End Sub
Sub sw5_Hit:Me.TimerEnabled = 1:dtRDrop.Hit 2:End Sub
Sub sw5_Timer:Me.TimerEnabled = 0:End Sub
Sub sw6_Hit:Me.TimerEnabled = 1:dtRDrop.Hit 3:End Sub
Sub sw6_Timer:Me.TimerEnabled = 0:End Sub
Sub sw7_Hit:Me.TimerEnabled = 1:dtRDrop.Hit 4:End Sub
Sub sw7_Timer:Me.TimerEnabled = 0:End Sub
 
Sub sw41_Hit:vpmTimer.PulseSw 41:End Sub
Sub sw42_Hit  : vpmTimer.PulseSw 42:Me.TimerEnabled = 1:sw42p.TransX = -4: playsound SoundFX("fx_chapa",DOFTargets): End Sub
Sub sw42_Timer:Me.TimerEnabled = 0:sw42p.TransX = 0:End Sub
Sub sw45_Hit  : vpmTimer.PulseSw 45:Me.TimerEnabled = 1:sw45p.TransX = -4: playsound SoundFX("fx_chapa",DOFTargets): End Sub
Sub sw45_Timer:Me.TimerEnabled = 0:sw45p.TransX = 0:End Sub
Sub sw46_Hit  : vpmTimer.PulseSw 46:Me.TimerEnabled = 1:sw46p.TransX = -4: playsound SoundFX("fx_chapa",DOFTargets): End Sub
Sub sw46_Timer:Me.TimerEnabled = 0:sw46p.TransX = 0:End Sub
Sub sw47_Hit  : vpmTimer.PulseSw 47:Me.TimerEnabled = 1:sw47p.TransX = -4: playsound SoundFX("fx_chapa",DOFTargets): End Sub
Sub sw47_Timer:Me.TimerEnabled = 0:sw47p.TransX = 0:End Sub
Sub sw48_Hit  : vpmTimer.PulseSw 48:Me.TimerEnabled = 1:sw48p.TransX = -4: playsound SoundFX("fx_chapa",DOFTargets): End Sub
Sub sw48_Timer:Me.TimerEnabled = 0:sw48p.TransX = 0:End Sub
Sub sw60_Hit  : vpmTimer.PulseSw 60:Me.TimerEnabled = 1:sw60p.TransX = -4: playsound SoundFX("fx_chapa",DOFTargets): End Sub
Sub sw60_Timer:Me.TimerEnabled = 0:sw60p.TransX = 0:End Sub
Sub sw61_Hit  : vpmTimer.PulseSw 61:Me.TimerEnabled = 1:sw61p.TransX = -4: playsound SoundFX("fx_chapa",DOFTargets): End Sub
Sub sw61_Timer:Me.TimerEnabled = 0:sw61p.TransX = 0:End Sub
Sub sw62_Hit  : vpmTimer.PulseSw 62:Me.TimerEnabled = 1:sw62p.TransX = -4: playsound SoundFX("fx_chapa",DOFTargets): End Sub
Sub sw62_Timer:Me.TimerEnabled = 0:sw62p.TransX = 0:End Sub
 
'Sub sw63_Hit  : vpmTimer.PulseSw 63:Me.TimerEnabled = 1:sw63p.TransX = -4: playsound SoundFX("fx_chapa"): End Sub
'Sub sw63_Timer:Me.TimerEnabled = 0:sw63p.TransX = 0:End Sub
 
Sub sw43s_Spin:vpmTimer.PulseSw 43:End Sub
 
Sub sw44_Hit  : Controller.Switch(44) = 1: End Sub 'left orbit made
Sub sw44_UnHit: Controller.Switch(44) = 0: End Sub
 
'Sub sw49a_Hit:bsRScoop.AddBall Me:End Sub
Dim aBall, aZpos
 
 
 
Sub sw49a_Hit
    Set aBall = ActiveBall
    aZpos = 50
    sw49a.TimerInterval = 2
    sw49a.TimerEnabled = 1
    Controller.Switch(49) = 1
    playsound "kicker_enter_center"
End Sub
 
 
 
Sub sw49a_Timer
    aBall.Z = aZpos
    aZpos = aZpos-2
    If aZpos <0 Then
        sw49a.TimerEnabled = 0
        sw49a.DestroyBall
        sw49.CreateBall
        sw49a.Enabled = 0
        unhittimer.Enabled = 1
    End If
End Sub
 
Sub unhittimer_timer
    unhittimer.enabled = 0
End Sub
 
Sub k3trig_hit
    sw49a.enabled = 1
end sub
 
Sub k3trig_unHit
    'BallInPlunger = 0
End Sub
 
Sub sw50_Hit  : Controller.Switch(50) = 1: End Sub 'right orbit made
Sub sw50_UnHit: Controller.Switch(50) = 0: End Sub
Sub sw51_Hit  : Controller.Switch(51) = 1: End Sub 'bssvuk exit
Sub sw51_UnHit: Controller.Switch(51) = 0: End Sub
Sub sw52_Hit  : Controller.Switch(52) = 1: End Sub'GI_AllOff 1000:End Sub 'right ramp made
Sub sw52_UnHit: Controller.Switch(52) = 0: End Sub
Sub sw53_Hit  : Controller.Switch(53) = 1: End Sub 'middle ramp
Sub sw53_UnHit: Controller.Switch(53) = 0: End Sub
Sub sw54_Hit  : Controller.Switch(54) = 1: End Sub 'left ramp opto
Sub sw54_UnHit: Controller.Switch(54) = 0: End Sub
 
Sub sw56_Hit  : Controller.Switch(56) = 1: End Sub 'leftvuk opto
Sub sw56_UnHit: Controller.Switch(56) = 0: End Sub
 
Sub sw59_Hit()
'Controller.Switch(59) = 1
Light27.state = 1
vpmTimer.PulseSw 59
vpmTimer.AddTimer 100, "BallDropSound"
of.enabled = 1
End Sub 'transfer tube

Sub of_timer()
Light27.State = 0
me.enabled = 0
End Sub
'Sub sw59_UnHit: Controller.Switch(59) = 0: End Sub
 
Sub sw23_Hit  : Controller.Switch(23) = 1: Playsound "rollover": GI_TroughCheck: End Sub ' shooter lane
Sub sw23_UnHit: Controller.Switch(23) = 0: End Sub
 
dim MotorCallback
Set MotorCallback = GetRef("GameTimer")
Sub GameTimer
    UpdateFlipperLogos
End Sub
 
Sub UpdateFlipperLogo_Timer
    LFLogo.RotY = LeftFlipper.CurrentAngle
    RFlogo.RotY = RightFlipper.CurrentAngle
    LFLogo1.RotY = UpLeftFlipper.CurrentAngle
    RFlogo1.RotY = UpRightFlipper.CurrentAngle
    LeftFlipperShadow.RotZ = LeftFlipper.CurrentAngle - 122
    RightFlipperShadow.RotZ = RightFlipper.CurrentAngle -238
End Sub
 
Sub RLS_Timer()
    sw8p.RotX = -(sw8s.currentangle) +90
    sw43p.RotX = -(sw43s.currentangle) +90
    sw44p.RotX = -(sw44s.currentangle) +90
    sw50p.RotX = -(sw50s.currentangle) +90
    sw53p.RotX = -(sw53s.currentangle) +90
    sw51p.RotX = -(sw51s.currentangle) +90
    leftrampp.RotX = -(leftramps.currentangle) +90
    Left1.ObjRotZ = left1f.currentangle +198
    Left2.ObjRotZ = left2f.currentangle +162
    Left3.TransZ = left3f.currentangle
    Right1.ObjRotZ = Right1f.currentangle +162
    Right2.ObjRotZ = Right2f.currentangle +198
    Right3.TransZ = Right3f.currentangle
End Sub
 
Dim sw33up, sw34up, sw35up, sw36up, sw37up, sw38up, sw39up, sw40up, sw10up, sw11up, sw12up, sw13up, sw7up, sw6up, sw5up, sw4up
Dim Jaildown, RPDown, LPUp
Dim PrimT
 
Sub PrimT_Timer
    if sw33.IsDropped = True then sw33up = False else sw33up = True
    if sw34.IsDropped = True then sw34up = False else sw34up = True
    if sw35.IsDropped = True then sw35up = False else sw35up = True
    if sw36.IsDropped = True then sw36up = False else sw36up = True
    if sw37.IsDropped = True then sw37up = False else sw37up = True
    if sw38.IsDropped = True then sw38up = False else sw38up = True
    if sw39.IsDropped = True then sw39up = False else sw39up = True
    if sw40.IsDropped = True then sw40up = False else sw40up = True
    if sw10.IsDropped = True then sw10up = False else sw10up = True
    if sw11.IsDropped = True then sw11up = False else sw11up = True
    if sw12.IsDropped = True then sw12up = False else sw12up = True
    if sw13.IsDropped = True then sw13up = False else sw13up = True
    if sw7.IsDropped = True then sw7up = False else sw7up = True
    if sw6.IsDropped = True then sw6up = False else sw6up = True
    if sw5.IsDropped = True then sw5up = False else sw5up = True
    if sw4.IsDropped = True then sw4up = False else sw4up = True
    if JailDiv.IsDropped = true then Jaildown = False else Jaildown = True
    if RightPost.IsDropped = true then RPDown = False else RPDown = True
    if LeftPost.IsDropped = true then LPUp = False else LPUp = True
End Sub
 
Sub DT_Timer()
    If sw33up = True and sw33p.z < 25 then sw33p.z = sw33p.z + 3
    If sw34up = True and sw34p.z < 25 then sw34p.z = sw34p.z + 3
    If sw35up = True and sw35p.z < 25 then sw35p.z = sw35p.z + 3
    If sw36up = True and sw36p.z < 25 then sw36p.z = sw36p.z + 3
    If sw37up = True and sw37p.z < 25 then sw37p.z = sw37p.z + 3
    If sw38up = True and sw38p.z < 25 then sw38p.z = sw38p.z + 3
    If sw39up = True and sw39p.z < 25 then sw39p.z = sw39p.z + 3
    If sw40up = True and sw40p.z < 25 then sw40p.z = sw40p.z + 3
    If sw10up = True and sw10p.z < 25 then sw10p.z = sw10p.z + 3
    If sw11up = True and sw11p.z < 25 then sw11p.z = sw11p.z + 3
    If sw12up = True and sw12p.z < 25 then sw12p.z = sw12p.z + 3
    If sw13up = True and sw13p.z < 25 then sw13p.z = sw13p.z + 3
    If Jaildown = true and Jail1.z > 160 then Jail1.z = Jail1.z - 3
    If Jaildown = true and Jail2.z > 160 then Jail2.z = Jail2.z - 3
    If RPDown = true and RPPrim.z > 160 then RPPrim.z = RPPrim.z - 3
    If LPUp = true and LeftPostPrim.z < 0 then LeftPostPrim.z = LeftPostPrim.z + 3
    If sw7up = True and sw7p.z < 25 then sw7p.z = sw7p.z + 3
    If sw6up = True and sw6p.z < 25 then sw6p.z = sw6p.z + 3
    If sw5up = True and sw5p.z < 25 then sw5p.z = sw5p.z + 3
    If sw4up = True and sw4p.z < 25 then sw4p.z = sw4p.z + 3
    If sw33up = False and sw33p.z > -20 then sw33p.z = sw33p.z - 3
    If sw34up = False and sw34p.z > -20 then sw34p.z = sw34p.z - 3
    If sw35up = False and sw35p.z > -20 then sw35p.z = sw35p.z - 3
    If sw36up = False and sw36p.z > -20 then sw36p.z = sw36p.z - 3
    If sw37up = False and sw37p.z > -20 then sw37p.z = sw37p.z - 3
    If sw38up = False and sw38p.z > -20 then sw38p.z = sw38p.z - 3
    If sw39up = False and sw39p.z > -20 then sw39p.z = sw39p.z - 3
    If sw40up = False and sw40p.z > -20 then sw40p.z = sw40p.z - 3
    If sw10up = False and sw10p.z > -20 then sw10p.z = sw10p.z - 3
    If sw11up = False and sw11p.z > -20 then sw11p.z = sw11p.z - 3
    If sw12up = False and sw12p.z > -20 then sw12p.z = sw12p.z - 3
    If sw13up = False and sw13p.z > -20 then sw13p.z = sw13p.z - 3
    If Jaildown = False and Jail1.z < 210 then Jail1.z = Jail1.z + 3
    If Jaildown = False and Jail2.z < 210 then Jail2.z = Jail2.z + 3
    If RPDown = False and RPPrim.z < 210 then RPPrim.z = RPPrim.z + 3
    If LPUp = False and LeftPostPrim.z > -50 then LeftPostPrim.z = LeftPostPrim.z - 3
    If sw7up = False and sw7p.z > -20 then sw7p.z = sw7p.z - 3
    If sw6up = False and sw6p.z > -20 then sw6p.z = sw6p.z - 3
    If sw5up = False and sw5p.z > -20 then sw5p.z = sw5p.z - 3
    If sw4up = False and sw4p.z > -20 then sw4p.z = sw4p.z - 3
    If sw33p.z >= -20 then sw33up = False
    If sw34p.z >= -20 then sw34up = False
    If sw35p.z >= -20 then sw35up = False
    If sw36p.z >= -20 then sw36up = False
    If sw37p.z >= -20 then sw37up = False
    If sw38p.z >= -20 then sw38up = False
    If sw39p.z >= -20 then sw39up = False
    If sw40p.z >= -20 then sw40up = False
    If sw10p.z >= -20 then sw10up = False
    If sw11p.z >= -20 then sw11up = False
    If sw12p.z >= -20 then sw12up = False
    If sw13p.z >= -20 then sw13up = False
    If Jail1.z <= 210 then Jaildown = false
    If Jail2.z <= 210 then Jaildown = false
'   f RPPrim.z <= 210 then RPDown = false
    If sw7p.z >= -20 then sw7up = False
    If sw6p.z >= -20 then sw6up = False
    If sw5p.z >= -20 then sw5up = False
    If sw4p.z >= -20 then sw4up = False
End Sub
 
 
'Sub LampTimer_Timer()
'    Dim chgLamp, num, chg, ii
'    chgLamp = Controller.ChangedLamps
'    If Not IsEmpty(chgLamp) Then
'        For ii = 0 To UBound(chgLamp)
'            LampState(chgLamp(ii, 0) ) = chgLamp(ii, 1)
'            FadingLevel(chgLamp(ii, 0) ) = chgLamp(ii, 1) + 4
'           FlashState(chgLamp(ii, 0) ) = chgLamp(ii, 1)
'
'        Next
'    End If
'
'    UpdateLamps
'End Sub
 
 
'***********************************************
'***********************************************
                    ' Lamps
'***********************************************
'***********************************************
 
 
 
 Dim LampState(570), FadingLevel(570), FadingState(570)
Dim FlashState(570), FlashLevel(570)
Dim FlashSpeedUp, FlashSpeedDown
Dim x
 
AllLampsOff()
LampTimer.Interval = 40 'lamp fading speed
LampTimer.Enabled = 1
'
FlashInit()
FlasherTimer.Interval = 10 'flash fading speed
FlasherTimer.Enabled = 1
 
Sub LampTimer_Timer()
    Dim chgLamp, num, chg, ii
    chgLamp = Controller.ChangedLamps
    If Not IsEmpty(chgLamp) Then
        For ii = 0 To UBound(chgLamp)
            LampState(chgLamp(ii, 0) ) = chgLamp(ii, 1)
            FadingLevel(chgLamp(ii, 0) ) = chgLamp(ii, 1) + 4
            FlashState(chgLamp(ii, 0) ) = chgLamp(ii, 1)
 
            'GI_CheckWalkerLights chgLamp(ii, 0), chgLamp(ii, 1)
        Next
    End If
 
    UpdateLamps
End Sub
 
Sub FlashInit
    Dim i
    For i = 0 to 200
        FlashState(i) = 0
        FlashLevel(i) = 0
    Next
 
    FlashSpeedUp = 500   ' fast speed when turning on the flasher
    FlashSpeedDown = 100 ' slow speed when turning off the flasher, gives a smooth fading
    AllFlashOff()
End Sub
 
Sub AllFlashOff
    Dim i
    For i = 0 to 200
        FlashState(i) = 0
    Next
End Sub
 
 Sub UpdateLamps()

 NFadeL 3, l3
    NFadeL 4, l4
    NFadeL 5, l5
    NFadeL 6, l6
    NFadeL 7, l7
    NFadeL 8, l8
    NFadeL 9, l9
    NFadeL 10, l10
    NFadeL 11, l11
    NFadeL 12, l12
    NFadeL 13, l13
    NFadeL 14, l14
    NFadeL 15, l15
    NFadeL 16, l16
    NFadeL 17, l17
    NFadeL 18, l18
    NFadeL 19, l19
    NFadeL 20, l20
    NFadeL 21, l21
    NFadeL 22, l22
    NFadeL 23, l23
    NFadeL 24, l24
    NFadeL 25, l25
    NFadeL 26, l26
    NFadeL 27, l27
    NFadeL 28, l28
    NFadeL 29, l29
    NFadeL 30, l30
    NFadeL 31, l31
    NFadeL 32, l32
    NFadeL 33, l33
    NFadeL 34, l34
    NFadeL 35, l35
    NFadeL 36, l36
    NFadeL 37, l37
    NFadeL 38, l38
    NFadeL 39, l39
    NFadeL 40, l40
    NFadeL 41, l41
    NFadeL 42, l42
    NFadeL 43, l43
    NFadeL 44, l44
    NFadeL 45, l45
    NFadeL 46, l46
    NFadeL 47, l47
    NFadeL 48, l48
    NFadeL 49, l49
    NFadeL 50, l50
    NFadeL 51, l51
    NFadeL 52, l52
    NFadeL 53, l53
    NFadeL 54, l54
    NFadeL 55, l55
    NFadeL 56, l56
    NFadeL 57, l57
    NFadeL 58, l58
    NFadeL 59, l59
    NFadeL 60, l60
    NFadeL 61, l61
    NFadeL 62, l62
    NFadeL 63, l63
    NFadeL 64, l64
    NFadeL 65, l65
    NFadeL 66, l66
 
NFadeL 67, L67
 NFadeL 68, L68
 NFadeL 75, L75
 NFadeL 76, L76

    NFadeL 69, l69
    NFadeL 70, l70
    NFadeL 71, l71
    NFadeL 72, l72
    NFadeL 73, l73
    NFadeL 74, l74
    NFadeL 78, l78
    NFadeL 79, l79
    NFadeL 80, l80
    NFadeLm 122, f22a
    NFadeLm 122, f22b
    NFadeL 122, f22d
    NFadeLm 123, f23a
    NFadeLm 123, f23b
    NFadeL 123, f23d
    NFadeLm 126, f26a
    NFadeLm 126, f26b
    NFadeL 126, f26d
    NFadeLm 127, f27a
    NFadeLm 127, f27b
    NFadeL 127, f27d
    NFadeLm 128, f28a
    NFadeLm 128, f28b
    NFadeL 128, f28d
    NFadeLm 129, f29a
    NFadeLm 129, f29b
    NFadeL 129, f29d
    NFadeLm 130, f30a
    NFadeLm 130, f30b
    NFadeL 130, f30d
    NFadeLm 131, f31a
    NFadeLm 131, f31b
    NFadeL 131, f31d
	NFadeLm 125, F25
    NFadeL 125, F25a
	'Flash 125, f25c
	f25c.visible = F25.state


'   FlashAR 122, f122b, "rf_on", "rf_a", "rf_b", Refresh 'left slingshot flash
'   FlashAR 123, f123b, "rf_on", "rf_a", "rf_b", Refresh 'right slingshot flash
'   FlashAR 125, f125b, "rf_on", "rf_a", "rf_b", Refresh 'flash left spinner
'   FlashAR 126, f126b, "rf_on", "rf_a", "rf_b", Refresh 'back panel 1 left
'   FlashAR 127, f127b, "rf_on", "rf_a", "rf_b", Refresh 'back panel 2
'   FlashAR 128, f128b, "rf_on", "rf_a", "rf_b", Refresh 'back panel 3
'   FlashAR 129, f129b, "rf_on", "rf_a", "rf_b", Refresh 'back panel 4
'   FlashAR 130, f130b, "rf_on", "rf_a", "rf_b", Refresh 'back panel 5 right
'   FlashAR 131, f131b, "rf_on", "rf_a", "rf_b", Refresh 'flash right vuk
 
End Sub
 
Sub FadePrim(nr, pri, a, b, c, d)
    Select Case FadingLevel(nr)
        Case 2:pri.image = d:FadingLevel(nr) = 0
        Case 3:pri.image = c:FadingLevel(nr) = 1
        Case 4:pri.image = b:FadingLevel(nr) = 2
        Case 5:pri.image = a:FadingLevel(nr) = 3
    End Select
End Sub
 
''Lights
 
Sub NFadeL(nr, a)
    Select Case FadingLevel(nr)
        Case 4:a.state = 0:FadingLevel(nr) = 0
        Case 5:a.State = 1:FadingLevel(nr) = 1
    End Select
End Sub
 
Sub NFadeLm(nr, a)
    Select Case FadingLevel(nr)
        Case 4:a.state = 0
        Case 5:a.State = 1
    End Select
End Sub
 
Sub Flash(nr, object)
    Select Case FlashState(nr)
        Case 0 'off
            FlashLevel(nr) = FlashLevel(nr) - FlashSpeedDown
            If FlashLevel(nr) < 0 Then
                FlashLevel(nr) = 0
                FlashState(nr) = -1 'completely off
            End if
            Object.opacity = FlashLevel(nr)
        Case 1 ' on
            FlashLevel(nr) = FlashLevel(nr) + FlashSpeedUp
            If FlashLevel(nr) > 1000 Then
                FlashLevel(nr) = 1000
                FlashState(nr) = -2 'completely on
            End if
            Object.opacity = FlashLevel(nr)
    End Select
End Sub
 
Sub Flashm(nr, object) 'multiple flashers, it doesn't change the flashstate
    Select Case FlashState(nr)
        Case 0         'off
            Object.opacity = FlashLevel(nr)
        Case 1         ' on
            Object.opacity = FlashLevel(nr)
    End Select
End Sub
 
 Sub AllLampsOff():For x = 1 to 200:LampState(x) = 4:FadingLevel(x) = 4:Next:UpdateLamps:UpdateLamps:Updatelamps:End Sub
 
 
Sub SetLamp(nr, value)
    If value = 0 AND LampState(nr) = 0 Then Exit Sub
    If value = 1 AND LampState(nr) = 1 Then Exit Sub
    LampState(nr) = abs(value) + 4
FadingLevel(nr ) = abs(value) + 4: FadingState(nr ) = abs(value) + 4
End Sub
 
Sub SetFlash(nr, stat)
    FlashState(nr) = ABS(stat)
End Sub
 
Sub FlasherTimer_Timer()
 
'Flash 3, f3
'Flash 4, f4
'Flash 5, f5
'Flash 6, f6
'Flash 7, f7
'Flash 8, f8
'Flash 9, f9
'Flash 10, f10
'Flash 11, f11
'Flash 12, f12
'Flash 13, f13
'Flash 14, f14
'Flash 15, f15
'Flash 16, f16
'Flash 17, f17
'Flash 18, f18
'Flash 19, f19
'Flash 20, f20
'Flash 21, f21
'Flash 22, f22
'Flash 23, f23
'Flash 24, f24
'Flash 25, f25
'Flash 26, f26
'Flash 27, f27
'Flash 28, f28
'Flash 29, f29
'Flash 30, f30
'Flash 31, f31
'Flash 32, f32
'Flash 33, f33
'Flash 34, f34
'Flash 35, f35
'Flash 36, f36
'Flash 37, f37
'Flash 38, f38
'Flash 39, f39
'Flash 40, f40
'Flash 41, f41
'Flash 42, f42
'Flash 43, f43
'Flash 44, f44
'Flash 45, f45
'Flash 46, f46
'Flash 47, f47
'Flash 48, f48
'Flash 49, f49
'Flash 50, f50
'Flash 51, f51
'Flash 52, f52
'Flash 53, f53
'Flash 54, f54
'Flash 55, f55
'Flash 56, f56
'Flash 57, f57
'Flash 58, f58
'Flash 59, f59
'Flash 60, f60
'Flash 61, f61
'Flash 62, f62 'left pop
'Flash 63, f63
'Flash 64, f64
'Flash 65, f65
'Flash 66, f66
'Flash 67, f67
'Flash 68, f68
'Flash 69, f69
'Flash 70, f70 'right pop
'Flash 71, f71
'Flash 72, f72
'Flash 73, f73
'Flash 74, f74
'Flash 75, f75
'Flash 76, f76
'Flash 77, f77
'Flash 78, f78 'bottom pop
'Flash 79, f79
'Flash 80, f80
'
Flash 132, f22c
Flash 133, f23c
'Flash 135, f125a
'Flash 136, f126a
'Flash 137, f127a
'Flash 138, f128a
'Flash 139, f129a
'Flash 140, f130a

Flash 136, f26c
Flash 137, f27c
Flash 138, f28c
Flash 139, f29c
Flash 140, f30c
Flash 141, f31c
 
 
 End Sub
 
 
''***** GI routines
 
Sub Drain_Hit
    PlaySound "balltruhe"
    bsTrough.AddBall Me
    Drain.TimerInterval = 200
    Drain.TimerEnabled = 1
End Sub
 
 
Sub Drain_Timer
    'Debug.print GI_TroughCheck & " " & Lampstate(4) & " " & Ballsavelight
    If GI_TroughCheck = 4 And LampState(3) = 0 Then
        GI_AllOff 0
    End If
    If GI_TroughCheck = 3 And BallInJail = True And LampState(3) = 0 Then
        GI_AllOff 0
    End If
    Drain.TimerEnabled = False
End Sub
 
Sub BallRelease_UnHit(): GI_AllOn: End Sub
 
Dim ballsavelight
 
Dim MultiballFlag
 
   
Sub GI_AllOff (time) 'Turn GI Off
    debug.print "gioff"
    DOF 101, DOFOff
    'debug.print "GI OFF " & time
    'UpdateGI 0,0
    'RampsOff
    'FlippersOff
    dim xx
    for each xx in GILights
    xx.state = 0
    Next
    If time > 0 Then
        GI_AllOnT.Interval = time
        GI_AllOnT.Enabled = 0
        GI_AllOnT.Enabled = 1
    End If
End Sub
 
Sub GI_AllOn 'Turn GI On
    debug.print "gion"
    DOF 101, DOFOn
    'UpdateGI 0,8
    'RampsOn
    'FlippersOn
    dim xx
    for each xx in GILights
    xx.state = 1
    Next
End Sub
 
Sub GI_AllOnT_Timer 'Turn GI On timer
    'UpdateGI 0,8
    'RampsOn
    'FlippersOn
    dim xx
    for each xx in GILights
    xx.state = 1
    Next
    GI_AllOnT.Enabled = 0
End Sub
 
Function GI_TroughCheck
    Dim Ballcount:  Ballcount = 0
    If Controller.Switch(18) = TRUE then Ballcount = Ballcount + 1
    If Controller.Switch(19) = TRUE then Ballcount = Ballcount + 1
    If Controller.Switch(20) = TRUE then Ballcount = Ballcount + 1
    If Controller.Switch(21) = TRUE then Ballcount = Ballcount + 1
    If Ballcount < 3 Then 'Keep track of multiball mode
        MultiballFlag = 1
    Else
        MultiballFlag = 0
    End If
 
    GI_TroughCheck = Ballcount
 
    'debug.print "Troughcheck " & ballcount & " Multiball " & MultiballFlag
 
    If ballcount = 4 then
        GameOverTimerCheck.Enabled = 1 'no ball in play
        'debug.print timer & "Game Over?"
    Else
        GameOverTimerCheck.Enabled = 0 'ball in play
        'debug.print timer & "Game Not Over"
    End If
 
End Function   
 
GameOverTimerCheck.Interval = 30000
Sub GameOverTimerCheck_Timer
    debug.print timer & "Game Over!"
    If GIOnDuringAttractMode = 1 Then GI_AllOn
    GameOverTimerCheck.Enabled = 0
End Sub
 
 
 Dim LED(69)
 
LED(0)=Array(D1,D2,D3,D4,D5,D6,D7                       )
LED(1)=Array(D8,D9,D10,D11,D12,D13,D14                  )
LED(2)=Array(D15,D16,D17,D18,D19,D20,D21                )
LED(3)=Array(D22,D23,D24,D25,D26,D27,D28                )
LED(4)=Array(D29,D30,D31,D32,D33,D34,D35                )
LED(5)=Array(D36,D37,D38,D39,D40,D41,D42                )
LED(6)=Array(D43,D44,D45,D46,D47,D48,D49                )
LED(7)=Array(D50,D51,D52,D53,D54,D55,D56                )
LED(8)=Array(D57,D58,D59,D60,D61,D62,D63                )
LED(9)=Array(D64,D65,D66,D67,D68,D69,D70                )
LED(10)=Array(D71,D72,D73,D74,D75,D76,D77               )
LED(11)=Array(D78,D79,D80,D81,D82,D83,D84               )
LED(12)=Array(D85,D86,D87,D88,D89,D90,D91               )
LED(13)=Array(D92,D93,D94,D95,D96,D97,D98               )
LED(14)=Array(D99,D100,D101,D102,D103,D104,D105         )
LED(15)=Array(D106,D107,D108,D109,D110,D111,D112        )
LED(16)=Array(D113,D114,D115,D116,D117,D118,D119        )
LED(17)=Array(D120,D121,D122,D123,D124,D125,D126        )
LED(18)=Array(D127,D128,D129,D130,D131,D132,D133        )
LED(19)=Array(D134,D135,D136,D137,D138,D139,D140        )
LED(20)=Array(D141,D142,D143,D144,D145,D146,D147        )
LED(21)=Array(D148,D149,D150,D151,D152,D153,D154        )
LED(22)=Array(D155,D156,D157,D158,D159,D160,D161        )
LED(23)=Array(D162,D163,D164,D165,D166,D167,D168        )
LED(24)=Array(D169,D170,D171,D172,D173,D174,D175        )
LED(25)=Array(D176,D177,D178,D179,D180,D181,D182        )
LED(26)=Array(D183,D184,D185,D186,D187,D188,D189        )
LED(27)=Array(D190,D191,D192,D193,D194,D195,D196        )
LED(28)=Array(D197,D198,D199,D200,D201,D202,D203        )
LED(29)=Array(D204,D205,D206,D207,D208,D209,D210        )
LED(30)=Array(D211,D212,D213,D214,D215,D216,D217        )
LED(31)=Array(D218,D219,D220,D221,D222,D223,D224        )
LED(32)=Array(D225,D226,D227,D228,D229,D230,D231        )
LED(33)=Array(D232,D233,D234,D235,D236,D237,D238        )
LED(34)=Array(D239,D240,D241,D242,D243,D244,D245        )
LED(35)=Array(D246,D247,D248,D249,D250,D251,D252        )
LED(36)=Array(D253,D254,D255,D256,D257,D258,D259        )
LED(37)=Array(D260,D261,D262,D263,D264,D265,D266        )
LED(38)=Array(D267,D268,D269,D270,D271,D272,D273        )
LED(39)=Array(D274,D275,D276,D277,D278,D279,D280        )
LED(40)=Array(D281,D282,D283,D284,D285,D286,D287        )
LED(41)=Array(D288,D289,D290,D291,D292,D293,D294        )
LED(42)=Array(D295,D296,D297,D298,D299,D300,D301        )
LED(43)=Array(D302,D303,D304,D305,D306,D307,D308        )
LED(44)=Array(D309,D310,D311,D312,D313,D314,D315        )
LED(45)=Array(D316,D317,D318,D319,D320,D321,D322        )
LED(46)=Array(D323,D324,D325,D326,D327,D328,D329        )
LED(47)=Array(D330,D331,D332,D333,D334,D335,D336        )
LED(48)=Array(D337,D338,D339,D340,D341,D342,D343        )
LED(49)=Array(D344,D345,D346,D347,D348,D349,D350        )
LED(50)=Array(D351,D352,D353,D354,D355,D356,D357        )
LED(51)=Array(D358,D359,D360,D361,D362,D363,D364        )
LED(52)=Array(D365,D366,D367,D368,D369,D370,D371        )
LED(53)=Array(D372,D373,D374,D375,D376,D377,D378        )
LED(54)=Array(D379,D380,D381,D382,D383,D384,D385        )
LED(55)=Array(D386,D387,D388,D389,D390,D391,D392        )
LED(56)=Array(D393,D394,D395,D396,D397,D398,D399        )
LED(57)=Array(D400,D401,D402,D403,D404,D405,D406        )
LED(58)=Array(D407,D408,D409,D410,D411,D412,D413        )
LED(59)=Array(D414,D415,D416,D417,D418,D419,D420        )
LED(60)=Array(D421,D422,D423,D424,D425,D426,D427        )
LED(61)=Array(D428,D429,D430,D431,D432,D433,D434        )
LED(62)=Array(D435,D436,D437,D438,D439,D440,D441        )
LED(63)=Array(D442,D443,D444,D445,D446,D447,D448        )
LED(64)=Array(D449,D450,D451,D452,D453,D454,D455        )
LED(65)=Array(D456,D457,D458,D459,D460,D461,D462        )
LED(66)=Array(D463,D464,D465,D466,D467,D468,D469        )
LED(67)=Array(D470,D471,D472,D473,D474,D475,D476        )
LED(68)=Array(D477,D478,D479,D480,D481,D482,D483        )
LED(69)=Array(D484,D485,D486,D487,D488,D489,D490        )
 
 
'Dim FlasherLED(69)
'FlasherLED(0)=Array(a1,a2,a3,a4,a5,a6,a7                       )
'FlasherLED(1)=Array(a8,a9,a10,a11,a12,a13,a14                  )
'FlasherLED(2)=Array(a15,a16,a17,a18,a19,a20,a21                )
'FlasherLED(3)=Array(a22,a23,a24,a25,a26,a27,a28                )
'FlasherLED(4)=Array(a29,a30,a31,a32,a33,a34,a35                )
'FlasherLED(5)=Array(a36,a37,a38,a39,a40,a41,a42                )
'FlasherLED(6)=Array(a43,a44,a45,a46,a47,a48,a49                )
'FlasherLED(7)=Array(a50,a51,a52,a53,a54,a55,a56                )
'FlasherLED(8)=Array(a57,a58,a59,a60,a61,a62,a63                )
'FlasherLED(9)=Array(a64,a65,a66,a67,a68,a69,a70                )
'FlasherLED(10)=Array(a71,a72,a73,a74,a75,a76,a77               )
'FlasherLED(11)=Array(a78,a79,a80,a81,a82,a83,a84               )
'FlasherLED(12)=Array(a85,a86,a87,a88,a89,a90,a91               )
'FlasherLED(13)=Array(a92,a93,a94,a95,a96,a97,a98               )
'FlasherLED(14)=Array(a99,a100,a101,a102,a103,a104,a105         )
'FlasherLED(15)=Array(a106,a107,a108,a109,a110,a111,a112        )
'FlasherLED(16)=Array(a113,a114,a115,a116,a117,a118,a119        )
'FlasherLED(17)=Array(a120,a121,a122,a123,a124,a125,a126        )
'FlasherLED(18)=Array(a127,a128,a129,a130,a131,a132,a133        )
'FlasherLED(19)=Array(a134,a135,a136,a137,a138,a139,a140        )
'FlasherLED(20)=Array(a141,a142,a143,a144,a145,a146,a147        )
'FlasherLED(21)=Array(a148,a149,a150,a151,a152,a153,a154        )
'FlasherLED(22)=Array(a155,a156,a157,a158,a159,a160,a161        )
'FlasherLED(23)=Array(a162,a163,a164,a165,a166,a167,a168        )
'FlasherLED(24)=Array(a169,a170,a171,a172,a173,a174,a175        )
'FlasherLED(25)=Array(a176,a177,a178,a179,a180,a181,a182        )
'FlasherLED(26)=Array(a183,a184,a185,a186,a187,a188,a189        )
'FlasherLED(27)=Array(a190,a191,a192,a193,a194,a195,a196        )
'FlasherLED(28)=Array(a197,a198,a199,a200,a201,a202,a203        )
'FlasherLED(29)=Array(a204,a205,a206,a207,a208,a209,a210        )
'FlasherLED(30)=Array(a211,a212,a213,a214,a215,a216,a217        )
'FlasherLED(31)=Array(a218,a219,a220,a221,a222,a223,a224        )
'FlasherLED(32)=Array(a225,a226,a227,a228,a229,a230,a231        )
'FlasherLED(33)=Array(a232,a233,a234,a235,a236,a237,a238        )
'FlasherLED(34)=Array(a239,a240,a241,a242,a243,a244,a245        )
'FlasherLED(35)=Array(a246,a247,a248,a249,a250,a251,a252        )
'FlasherLED(36)=Array(a253,a254,a255,a256,a257,a258,a259        )
'FlasherLED(37)=Array(a260,a261,a262,a263,a264,a265,a266        )
'FlasherLED(38)=Array(a267,a268,a269,a270,a271,a272,a273        )
'FlasherLED(39)=Array(a274,a275,a276,a277,a278,a279,a280        )
'FlasherLED(40)=Array(a281,a282,a283,a284,a285,a286,a287        )
'FlasherLED(41)=Array(a288,a289,a290,a291,a292,a293,a294        )
'FlasherLED(42)=Array(a295,a296,a297,a298,a299,a300,a301        )
'FlasherLED(43)=Array(a302,a303,a304,a305,a306,a307,a308        )
'FlasherLED(44)=Array(a309,a310,a311,a312,a313,a314,a315        )
'FlasherLED(45)=Array(a316,a317,a318,a319,a320,a321,a322        )
'FlasherLED(46)=Array(a323,a324,a325,a326,a327,a328,a329        )
'FlasherLED(47)=Array(a330,a331,a332,a333,a334,a335,a336        )
'FlasherLED(48)=Array(a337,a338,a339,a340,a341,a342,a343        )
'FlasherLED(49)=Array(a344,a345,a346,a347,a348,a349,a350        )
'FlasherLED(50)=Array(a351,a352,a353,a354,a355,a356,a357        )
'FlasherLED(51)=Array(a358,a359,a360,a361,a362,a363,a364        )
'FlasherLED(52)=Array(a365,a366,a367,a368,a369,a370,a371        )
'FlasherLED(53)=Array(a372,a373,a374,a375,a376,a377,a378        )
'FlasherLED(54)=Array(a379,a380,a381,a382,a383,a384,a385        )
'FlasherLED(55)=Array(a386,a387,a388,a389,a390,a391,a392        )
'FlasherLED(56)=Array(a393,a394,a395,a396,a397,a398,a399        )
'FlasherLED(57)=Array(a400,a401,a402,a403,a404,a405,a406        )
'FlasherLED(58)=Array(a407,a408,a409,a410,a411,a412,a413        )
'FlasherLED(59)=Array(a414,a415,a416,a417,a418,a419,a420        )
'FlasherLED(60)=Array(a421,a422,a423,a424,a425,a426,a427        )
'FlasherLED(61)=Array(a428,a429,a430,a431,a432,a433,a434        )
'FlasherLED(62)=Array(a435,a436,a437,a438,a439,a440,a441        )
'FlasherLED(63)=Array(a442,a443,a444,a445,a446,a447,a448        )
'FlasherLED(64)=Array(a449,a450,a451,a452,a453,a454,a455        )
'FlasherLED(65)=Array(a456,a457,a458,a459,a460,a461,a462        )
'FlasherLED(66)=Array(a463,a464,a465,a466,a467,a468,a469        )
'FlasherLED(67)=Array(a470,a471,a472,a473,a474,a475,a476        )
'FlasherLED(68)=Array(a477,a478,a479,a480,a481,a482,a483        )
'FlasherLED(69)=Array(a484,a485,a486,a487,a488,a489,a490        )
 
 
Function CheckLED (num)
    Dim tot,ii,specialcase
    if num = 13 then specialcase = 1
    For ii = (num*5 - 5) to (num*5 - 1 - specialcase)
        tot = tot + CheckLEDColumn(ii)
    Next
    'debug.print Timer & "LED " & num & " = " & tot
    CheckLED = tot
End Function
 
Function CheckLEDColumn (num)
    Dim tot, obj,i
    i = 1
    For each obj in LED(num)
        tot = tot + obj.State * i
        i = i * 2
    Next
    'debug.print Timer & "LEDColumn " & num & " = " & tot
    CheckLEDColumn = tot
End Function
 
 
 
Sub SetLED14toL
    Dim ii, src, dest, iii, obj
    For each obj in LED(65)
        obj.state = 1
    Next
    For ii = 66 to 69
        For each obj in LED(ii)
            obj.state = 1
            Exit For
        Next
    Next
 
'   For each obj in FlasherLED(65)
'       obj.alpha = 255
'   Next
'   For ii = 66 to 69
'       For each obj in FlasherLED(ii)
'           obj.alpha = 255
'           Exit For
'       Next
'   Next
End Sub
 
Sub SetLED14toT
    Dim ii, src, dest, iii, obj
 
    D462.state = 255
    D469.state = 255
    D470.state = 255
    D471.state = 255
    D472.state = 255
    D473.state = 255
    D474.state = 255
    D475.state = 255
    D476.state = 255
    D483.state = 255
    D490.state = 255
 
'   a462.alpha = 255
'   a469.alpha = 255
'   a470.alpha = 255
'   a471.alpha = 255
'   a472.alpha = 255
'   a473.alpha = 255
'   a474.alpha = 255
'   a475.alpha = 255
'   a476.alpha = 255
'   a483.alpha = 255
'   a490.alpha = 255
End Sub
 
Sub SetLED14toLED9
    D456.state=D281.state
    D457.state=D282.state
    D458.state=D283.state
    D459.state=D284.state
    D460.state=D285.state
    D461.state=D286.state
    D462.state=D287.state
    D463.state=D288.state
    D464.state=D289.state
    D465.state=D290.state
    D466.state=D291.state
    D467.state=D292.state
    D468.state=D293.state
    D469.state=D294.state
    D470.state=D295.state
    D471.state=D296.state
    D472.state=D297.state
    D473.state=D298.state
    D474.state=D299.state
    D475.state=D300.state
    D476.state=D301.state
    D477.state=D302.state
    D478.state=D303.state
    D479.state=D304.state
    D480.state=D305.state
    D481.state=D306.state
    D482.state=D307.state
    D483.state=D308.state
    D484.state=D309.state
    D485.state=D310.state
    D486.state=D311.state
    D487.state=D312.state
    D488.state=D313.state
    D489.state=D314.state
    D490.state=D315.state
'   a456.Alpha=a281.Alpha
'   a457.Alpha=a282.Alpha
'   a458.Alpha=a283.Alpha
'   a459.Alpha=a284.Alpha
'   a460.Alpha=a285.Alpha
'   a461.Alpha=a286.Alpha
'   a462.Alpha=a287.Alpha
'   a463.Alpha=a288.Alpha
'   a464.Alpha=a289.Alpha
'   a465.Alpha=a290.Alpha
'   a466.Alpha=a291.Alpha
'   a467.Alpha=a292.Alpha
'   a468.Alpha=a293.Alpha
'   a469.Alpha=a294.Alpha
'   a470.Alpha=a295.Alpha
'   a471.Alpha=a296.Alpha
'   a472.Alpha=a297.Alpha
'   a473.Alpha=a298.Alpha
'   a474.Alpha=a299.Alpha
'   a475.Alpha=a300.Alpha
'   a476.Alpha=a301.Alpha
'   a477.Alpha=a302.Alpha
'   a478.Alpha=a303.Alpha
'   a479.Alpha=a304.Alpha
'   a480.Alpha=a305.Alpha
'   a481.Alpha=a306.Alpha
'   a482.Alpha=a307.Alpha
'   a483.Alpha=a308.Alpha
'   a484.Alpha=a309.Alpha
'   a485.Alpha=a310.Alpha
'   a486.Alpha=a311.Alpha
'   a487.Alpha=a312.Alpha
'   a488.Alpha=a313.Alpha
'   a489.Alpha=a314.Alpha
'   a490.Alpha=a315.Alpha
 
End Sub
Sub ClearLED14
    Dim ii, src, dest, iii, obj
    For ii = 65 to 69
        For each obj in LED(ii)
            obj.state = 0
        Next
    Next
'   For ii = 65 to 69
'       For each obj in FlasherLED(ii)
'           obj.alpha = 0
'       Next
'   Next
 
End Sub
 
Sub DisplayTimer_Timer
    Dim ChgLED, ii, num, chg, stat, obj
    If B2SOn = False Then 'If B2S not enabled, use 128 bit LED mode
        ChgLed = Controller.ChangedLEDs (&HFFFFFFFF, &HFFFFFFFF, &HFFFFFFFF, &HFFFFFFFF) 'displays both rows, dupe leds
        If Not IsEmpty (ChgLED) Then
 
            For ii = 0 To UBound (chgLED)
                'LEDs
                num = chgLED (ii, 0) : chg = chgLED (ii, 1) : stat = chgLED (ii, 2)
                For Each obj In LED (num)
                    If chg And 1 Then obj.State = stat And 1
                    chg = chg \ DivValue : stat = stat \ DivValue
                Next
 
                'Flashers (thanks gtxjoe!)
'               num = chgLED (ii, 0) : chg = chgLED (ii, 1) : stat = chgLED (ii, 2)
'               For Each obj In FlasherLED (num)
'                   If chg And 1 Then obj.alpha = (stat And 1)*255
'                   chg = chg \ DivValue : stat = stat \ DivValue
'               Next
            Next
        End If
 
    Else 'B2S enabled use 64 bit ChangedLED mode with last LED simulated
        ChgLed = Controller.ChangedLEDs (&Hffffffff, &Hffffffff) 'displays both rows, dupe leds
        If Not IsEmpty (ChgLED) Then
 
            For ii = 0 To UBound (chgLED)
                'LEDs
                num = chgLED (ii, 0) : chg = chgLED (ii, 1) : stat = chgLED (ii, 2)
                For Each obj In LED (num)
                    If chg And 1 Then obj.State = stat And 1
                    chg = chg \ DivValue : stat = stat \ DivValue
                Next
 
                'Flashers (thanks gtxjoe!)
'               num = chgLED (ii, 0) : chg = chgLED (ii, 1) : stat = chgLED (ii, 2)
'               For Each obj In FlasherLED (num)
'                   If chg And 1 Then obj.alpha = (stat And 1)*255
'                   chg = chg \ DivValue : stat = stat \ DivValue
'               Next
            Next
 
 
            'This hack fixes LED 13 last column
            Dim LED13value
            LED13value = CheckLED(13)
            Select Case LED13value  
                Case 130:       'If 'set to L', fix the L
                    D449.State = 1 'L set 449
'                   a449.Alpha = 255
                Case 126: 'diamond 134- 8=126 452(449-455)
                    D452.State = 1
'                   a452.Alpha = 255
                Case 133: 'spade   145-12=133 451,452
                    D451.State = 1
                    D452.State = 1
'                   a451.Alpha = 255
'                   a452.Alpha = 255
                Case 174: 'heart   198-24=174 452,453
                    D452.State = 1
                    D453.State = 1
'                   a452.Alpha = 255
'                   a453.Alpha = 255
                Case 197: 'club    209-12=197 451,452
                    D451.State = 1
                    D452.State = 1
'                   a451.Alpha = 255
'                   a452.Alpha = 255
                Case 257: 'Letter O
                    D449.State = 0
                    D450.State = 1
                    D451.State = 1
                    D452.State = 1
                    D453.State = 1
                    D454.State = 1
                    D455.State = 0
'                   a449.Alpha = 0
'                   a450.Alpha = 255
'                   a451.Alpha = 255
'                   a452.Alpha = 255
'                   a453.Alpha = 255
'                   a454.Alpha = 255
'                   a455.Alpha = 0
                Case 285: 'Number 0
                    D449.State = 0
                    D450.State = 1
                    D451.State = 1
                    D452.State = 1
                    D453.State = 1
                    D454.State = 1
                    D455.State = 0
'                   a449.Alpha = 0
'                   a450.Alpha = 255
'                   a451.Alpha = 255
'                   a452.Alpha = 255
'                   a453.Alpha = 255
'                   a454.Alpha = 255
'                   a455.Alpha = 0
                Case Else:
                    D449.State = 0
                    D450.State = 0
                    D451.State = 0
                    D452.State = 0
                    D453.State = 0
                    D454.State = 0
                    D455.State = 0
'                   a449.Alpha = 0
'                   a450.Alpha = 0
'                   a451.Alpha = 0
'                   a452.Alpha = 0
'                   a453.Alpha = 0
'                   a454.Alpha = 0
'                   a455.Alpha = 0
            End Select
 
            'This hack fills LED14 with the suit from LED8
            Dim LED7value
            LED7value = CheckLED(7)
            Select Case LED7value  
                Case 0: 'If 7th LED is blank and 13th LED is L then set 14th LED to L
                    If LED13value = 130 Then 'L=130
                        SetLED14toL
                    ElseIf LED13value = 257 Then'If 7th LED is blank and 13th LED is O(257) then set 14th LED to L
                        SetLED14toT
                    Else 'Set 14th LED blank
                        ClearLED14
                    End if
                Case Else: 'If 7th LED is card, then set 14th LED to the 9th LED suit (25% of being correct)
                    SetLED14toLED9
            End Select
        End If
    End If
End Sub
 
Sub Table_exit()
    If B2SOn Then Controller.Stop
End Sub
 
Dim leftdrop:leftdrop = 0
Sub leftdrop1_Hit:leftdrop = 1:playsound "wireramp":End Sub
Sub leftdrop2_Hit:
    If leftdrop = 1 then
        PlaySound "balldrop"
        leftdrop = 0
    End If
    StopSound "wireramp"
    'leftdrop = 0
End Sub
 
Dim rightdrop:rightdrop = 0
Sub rightdrop1_Hit:rightdrop = 1:playsound "wireramp":End Sub
Sub rightdrop2_Hit
    If rightdrop = 1 then
        PlaySound "balldrop"
        rightdrop = 0
    End If
    StopSound "wireramp"
    'rightdrop = 0
End Sub
 
'''*****************************************************************************************
'''*freneticamnesic level nudge script, based on rascals nudge bobble with help from gtxjoe*
'''*     add timers and "Nudgebobble(keycode)" to left and right tilt keys to activate     *
'''*****************************************************************************************
Dim bgcharctr:bgcharctr = 2
Dim centerlocation:centerlocation = 90
Dim bgdegree:bgdegree = 7 'move +/- 7 degrees
Dim bgdurationctr:bgdurationctr = 0
 
Sub LevelT_Timer()
    Dim loopctr
    Level.RotAndTra7 = Level.RotAndTra7 + bgcharctr  'change rotation value by bgcharctr
    'debug.print "Degrees: " & Level.RotAndTra7 & " Max degree offset: " & bgdegree & " Cycle count: " & bgdurationctr ''debug print
    If Level.RotAndTra7 >= bgdegree + centerlocation then bgcharctr = -1:bgdurationctr = bgdurationctr + 1   'if level moves past max degrees, change direction and increate durationctr
    If Level.RotAndTra7 <= -bgdegree + centerlocation then bgcharctr = 1  'if level moves past min location, change direction
    If bgdurationctr = 4 then bgdegree = bgdegree - 2:bgdurationctr = 0 'if level has moved back and forth 5 times, decrease amount of movement by -2 and repeat by resetting durationctr
    If bgdegree <= 0 then LevelT.Enabled = False:bgdegree = 7 'if amount of movement is 0, turn off LevelT timer and reset movement back to max 7 degrees
End Sub
 
 
Sub Nudgebobble(keycode)
    If keycode = LeftTiltKey then bgcharctr = -1  'if nudge left, move in - direction
    If keycode = RightTiltKey then bgcharctr = 1  'if nudge left, move in + direction
    If keycode = CenterTiltKey then         'if nudge center, generate random number 1 or 2.  If 1 change it to -2.  use this number for initial direction
        Dim randombobble:randombobble = Int(2 * Rnd + 1)
        If randombobble = 1 then randombobble = -2
        bgcharctr = randombobble
    End If
    LevelT.Enabled = True:bgdurationctr = 0:bgdegree = 7
End Sub
 
Sub bobblesome_Timer()  'This looks like a free running timer that 1 out of ten times will start movement
    Dim chance
    chance = Int(10*Rnd+1)
    If chance = 5 then Nudgebobble(CenterTiltKey)
End Sub
 
' *********************************************************************
'                      Supporting Ball & Sound Functions
' *********************************************************************
 
Function Vol(ball) ' Calculates the Volume of the sound based on the ball speed
    Vol = Csng(BallVel(ball) ^2 / 50)
End Function
 
Function Pan(ball) ' Calculates the pan for a ball based on the X position on the table. "table" is the name of the table
    Dim tmp
    tmp = ball.x * 2 / table.width-1
    If tmp > 0 Then
        Pan = Csng(tmp ^10)
    Else
        Pan = Csng(-((- tmp) ^10) )
    End If
End Function
 
Function Pitch(ball) ' Calculates the pitch of the sound based on the ball speed
    Pitch = BallVel(ball) * 20
End Function
 
Function BallVel(ball) 'Calculates the ball speed
    BallVel = INT(SQR((ball.VelX ^2) + (ball.VelY ^2) ) )
End Function
 
'*****************************************
'      JP's VP10 Rolling Sounds
'*****************************************
 
Const tnob = 5 ' total number of balls
ReDim rolling(tnob)
InitRolling
 
Sub InitRolling
    Dim i
    For i = 0 to tnob
        rolling(i) = False
    Next
End Sub
 
Sub RollingTimer_Timer()
    Dim BOT, b
    BOT = GetBalls
 
    ' stop the sound of deleted balls
    For b = UBound(BOT) + 1 to tnob
        rolling(b) = False
        StopSound("fx_ballrolling" & b)
    Next
 
    ' exit the sub if no balls on the table
    If UBound(BOT) = -1 Then Exit Sub
 
    ' play the rolling sound for each ball
    For b = 0 to UBound(BOT)
        If BallVel(BOT(b) ) > 1 AND BOT(b).z < 30 Then
            rolling(b) = True
            PlaySound("fx_ballrolling" & b), -1, Vol(BOT(b) ), Pan(BOT(b) ), 0, Pitch(BOT(b) ), 1, 0
        Else
            If rolling(b) = True Then
                StopSound("fx_ballrolling" & b)
                rolling(b) = False
            End If
        End If
    Next
End Sub
 
'**********************
' Ball Collision Sound
'**********************
 
Sub OnBallBallCollision(ball1, ball2, velocity)
    PlaySound("fx_collide"), 0, Csng(velocity) ^2 / 2000, Pan(ball1), 0, Pitch(ball1), 0, 0
End Sub
 
 
 
'************************************
' What you need to add to your table
'************************************
 
' a timer called RollingTimer. With a fast interval, like 10
' one collision sound, in this script is called fx_collide
' as many sound files as max number of balls, with names ending with 0, 1, 2, 3, etc
' for ex. as used in this script: fx_ballrolling0, fx_ballrolling1, fx_ballrolling2, fx_ballrolling3, etc
 
 
'******************************************
' Explanation of the rolling sound routine
'******************************************
 
' sounds are played based on the ball speed and position
 
' the routine checks first for deleted balls and stops the rolling sound.
 
' The For loop goes through all the balls on the table and checks for the ball speed and
' if the ball is on the table (height lower than 30) then then it plays the sound
' otherwise the sound is stopped, like when the ball has stopped or is on a ramp or flying.
 
' The sound is played using the VOL, PAN and PITCH functions, so the volume and pitch of the sound
' will change according to the ball speed, and the PAN function will change the stereo position according
' to the position of the ball on the table.
 
 
'**************************************
' Explanation of the collision routine
'**************************************
 
' The collision is built in VP.
' You only need to add a Sub OnBallBallCollision(ball1, ball2, velocity) and when two balls collide they
' will call this routine. What you add in the sub is up to you. As an example is a simple Playsound with volume and paning
' depending of the speed of the collision.
 
 
Sub Pins_Hit (idx)
    PlaySound "pinhit_low", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0
End Sub
 
Sub Targets_Hit (idx)
    PlaySound "target", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0
End Sub
 
Sub Metals_Thin_Hit (idx)
    PlaySound "metalhit_thin", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
End Sub
 
Sub Metals_Medium_Hit (idx)
    PlaySound "metalhit_medium", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
End Sub
 
Sub Metals2_Hit (idx)
    PlaySound "metalhit2", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
End Sub
 
Sub Gates_Hit (idx)
    PlaySound "gate4", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
End Sub
 
Sub Spinner_Spin
    PlaySound "fx_spinner",0,.25,0,0.25
End Sub
 
Sub Rubbers_Hit(idx)
    dim finalspeed
    finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
    If finalspeed > 20 then
        PlaySound "fx_rubber2", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
    End if
    If finalspeed >= 6 AND finalspeed <= 20 then
        RandomSoundRubber()
    End If
End Sub
 
Sub Posts_Hit(idx)
    dim finalspeed
    finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
    If finalspeed > 16 then
        PlaySound "fx_rubber2", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
    End if
    If finalspeed >= 6 AND finalspeed <= 16 then
        RandomSoundRubber()
    End If
End Sub
 
Sub RandomSoundRubber()
    Select Case Int(Rnd*3)+1
        Case 1 : PlaySound "rubber_hit_1", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
        Case 2 : PlaySound "rubber_hit_2", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
        Case 3 : PlaySound "rubber_hit_3", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
    End Select
End Sub
 
Sub LeftFlipper_Collide(parm)
    RandomSoundFlipper()
End Sub
 
Sub RightFlipper_Collide(parm)
    RandomSoundFlipper()
End Sub
 
Sub RandomSoundFlipper()
    Select Case Int(Rnd*3)+1
        Case 1 : PlaySound "flip_hit_1", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
        Case 2 : PlaySound "flip_hit_2", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
        Case 3 : PlaySound "flip_hit_3", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
    End Select
End Sub


Sub trigger1_Hit()
vpmTimer.AddTimer 100, "BallDropSound"
End Sub

Sub BallDropSound(dummy):PlaySound "BallDrop":End Sub

'EOF