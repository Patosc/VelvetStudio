
GUSPNP = 0 ; Enable the soundcardconfig for the gus pnp

;dw PopUp,X,Y,X-size,Y-size
;dw Fill,X1,Y1,X2,Y2,Color
;dw BigBorder,X1,Y1,X2,Y2,Status(0=Down,1=Up)
;dw SmallBorder,X1,Y1,X2,Y2,Status(0=Down,1=Up)
;dw Button,X1,Y1,X2,Y2,Status(0=Down,1=Up)
;dw Picture,X,Y,Pcxnumber,Buggfix
;dw Text,X,Y,Font(0=Font on background,1=Font on button)
; db "The whole text$"

;OBS! If you put a picture it MUST come directly after POPUP.

PopUp		equ	0
Fill		equ	1
BigBorder	equ	2
SmallBorder	equ	3
Button		equ	4
Picture 	equ	5
Text		equ	6
EndCode 	equ    -1

CodeCallTable	dd     _ret
		dd	FillCode
		dd	BigBorderCode
		dd	SmallBorderCode
		dd	ButtonCode
		dd     _ret
		dd	TextCode


WaitEffectPicture	Label	Word
	dw	Popup,104,232,424,100
	dw	Fill,16,28,407,56,0
	dw	BigBorder,14,26,409,58,0
	dw	Button,353,68,414,84,1
	dw	Text,360,71,1
	  db	"CANCEL$"
	dw	Text,8,71,0
	  db	"Calculating:$"
	dw	Text,176,8,0
	  db	"Processing...$"
	dw	EndCode




Time_effPicture Label	Word
	dw	Popup,64,348,504,108
	dw	Picture,179-0,69,34,0
	dw	Picture,179-0,87,34,0
	dw	Picture,403-0,67+1,34,0
	dw	Fill,135,71,175,83,0
	dw	Fill,135,89,175,101,0
	dw	Fill,359,69+1,399,81+1,0
	dw	BigBorder,133,69,177,85,0
	dw	BigBorder,133,87,177,103,0
	dw	BigBorder,357,67+1,401,83+1,0
	dw	Button,11,29,21,40,1
	dw	Button,11,42,21,53,1
	dw	Button,11,55,21,65,1
	dw	Button,267,29,277,40,1
	dw	Button,267,42,277,53,1
	dw	Button,267,55,277,66,1
	dw	Button,253,89,351,105,1
	dw	Button,352,89,411,105,1
	dw	Button,412,89,497,105,1
	dw	SmallBorder,1,2,250,105,1
	dw	SmallBorder,253,2,502,86,1
	dw	Text,80,10,0
	  db	"Time Compress$"
	dw	Text,24,29,0
	  db	"No time compress$"
	dw	Text,24,42,0
	  db	"C-4 related$"
	dw	Text,24,55,0
	  db	"Fixed length$"
	dw	Text,8,72,0
	  db	"Samples to read$"
	dw	Text,8,90,0
	  db	"Samples to skip$"
	dw	Text,344,10,0
	  db	"Real Pitch$"
	dw	Text,280,29,0
	  db	"No real pitch$"
	dw	Text,280,42,0
	  db	"C-4 related$"
	dw	Text,280,55,0
	  db	"Fixed length$"
	dw	Text,264,70+1,0
	  db	"Buffer size$"
	dw	Text,280,92,1
	  db	"PREVIEW$"
	dw	Text,368,92,1
	  db	"OKAY$"
	dw	Text,432,92,1
	  db	"CANCEL$"
	dw	EndCode




Envelope_effPicture Label   Word
	dw	Popup,64,348,504,108
	dw	Picture,131-0,1,34,0
	dw	Picture,131-0,19,34,0
	dw	Picture,131-0,37,34,0
	dw	Picture,131-0,55,34,0
	dw	Picture,131-0,73,34,0
	dw	Picture,131-0,90,34,0
	dw	Picture,468-0,55,14,0
	dw	Picture,468-0,2,15,0
	dw	Picture,166-0,71,11,0
	dw	Picture,429-0,71,12,0
	dw	Picture,454-0,2,23,0
	dw	Picture,454-0,55,24,0
	dw	Fill,87,3,127,15,0
	dw	Fill,87,21,127,33,0
	dw	Fill,71-8,39,127,51,0
	dw	Fill,71-8,57,127,69,0
	dw	Fill,87,75,127,87,0
	dw	Fill,87,93,127,105,0
	dw	Fill,168,4,447,67,0
	dw	BigBorder,85,1,129,17,0
	dw	BigBorder,85,19,129,35,0
	dw	BigBorder,69-8,37,129,53,0
	dw	BigBorder,69-8,55,129,71,0
	dw	BigBorder,85,73,129,89,0
	dw	BigBorder,85,91,129,107,0
	dw	BigBorder,166,2,449,69,0
	dw	BigBorder,190,70,425,82,0
	dw	BigBorder,454,18,465,53,0
	dw	Button,253,89,351,105,1
	dw	Button,352,89,411,105,1
	dw	Button,412,89,497,105,1
	dw	Button,187,89,252,105,1
	dw	Text,8,4,0
	  db	"Point Nr$"
	dw	Text,8,22,0
	  db	"Nr of pt$"
	dw	Text,8,40,0
	  db	"Time$"
	dw	Text,8,58,0
	  db	"Value$"
	dw	Text,8,76,0
	  db	"LoopStart$"
	dw	Text,8,94,0
	  db	"Loopend$"
	dw	Text,280,92,1
	  db	"PREVIEW$"
	dw	Text,368,92,1
	  db	"OKAY$"
	dw	Text,432,92,1
	  db	"CANCEL$"
	dw	Text,200,92,1
	  db	"APPLY$"
	dw	EndCode

EffectEditMainPicture	Label	Word
	dw	PopUp,60,17,520,446
	dw	Picture,155-4,37,34,0
	dw	Picture,75-4,141,34,0
	dw	Picture,131-4,168,34,0
	dw	Picture,131-4,186,34,0
	dw	Picture,139-4,257,34,0
	dw	Picture,411-4,142,34,0
	dw	Picture,459-4,312,34,0
	dw	Picture,174-4,237,11,0
	dw	Picture,437-4,237,12,0
	dw	Picture,462-4,168,23,0
	dw	Picture,462-4,221,24,0
	dw	Picture,476-4,221,17,0
	dw	Fill,111,21,335,33,0
	dw	Fill,111,39,151,51,0
	dw	Fill,31,143,71,155,0
	dw	Fill,87,170,127,182,0
	dw	Fill,71-8,188,127,200,0
	dw	Fill,95,259,135,271,0
	dw	Fill,367-16,144,407,156,0
	dw	Fill,176,170,455,233,0
	dw	Fill,399,314,455,326,0
	dw	SmallBorder,6,64,137,160,1
	dw	SmallBorder,140,64,513,160,1
	dw	SmallBorder,6,163,513,251,1
	dw	SmallBorder,6,254,513,439,1
	dw	SmallBorder,6,330,513,439,1
	dw	BigBorder,109,19,337,35,0
	dw	BigBorder,109,37,153,53,0
	dw	BigBorder,29,141,73,157,0
	dw	BigBorder,85,168,129,184,0
	dw	BigBorder,69-8,186,129,202,0
	dw	BigBorder,93,257,137,273,0
	dw	BigBorder,397,312,457,328,0
	dw	BigBorder,365-16,142,409,158,0
	dw	BigBorder,174,168,457,235,0
	dw	BigBorder,198,237,433,248,0
	dw	BigBorder,462,184,473,219,0
	dw	Button,19,87,29,98,1
	dw	Button,19,100,29,110,1
	dw	Button,19,113,29,124,1
	dw	Button,19,207,29,217,1
	dw	Button,19,220,29,230,1
	dw	Button,19,233,29,244,1
	dw	Button,19,278,29,289,1
	dw	Button,19,291,29,301,1
	dw	Button,19,304,29,314,1
	dw	Button,19,317,29,327,1
	dw	Button,179,100,189,110,1
	dw	Button,179,113,189,124,1
	dw	Button,347,100,357,111,1
	dw	Button,347,113,357,124,1
	dw	Button,347,126,357,137,1
	dw	Button,187,258,197,269,1
	dw	Button,187,271,197,282,1
	dw	Button,187,284,197,295,1
	dw	Button,187,142,259,158,1
	dw	Button,260,142,346,158,1
	dw	Text,200,5,0
	  db	"Effect Edit$"
	dw	Text,16,22,0
	  db	"Effect Name$"
	dw	Text,8,40,0
	  db	"Total Voices$"
	dw	Text,40,68,0
	  db	"Smooth$"
	dw	Text,32,87,0
	  db	"No Smooth$"
	dw	Text,32,100,0
	  db	"C-4 related$"
	dw	Text,32,113,0
	  db	"Fixed length$"
	dw	Text,24,128,0
	  db	"Smooth length$"
	dw	Text,280,68,0
	  db	"Voice Break$"
	dw	Text,192,86,0
	  db	"Time Variant$"
	dw	Text,192,100,0
	  db	"End of samp$"
	dw	Text,192,113,0
	  db	"End of voice$"
	dw	Text,360,86,0
	  db	"Time Invariant$"
	dw	Text,360,100,0
	  db	"After delay$"
	dw	Text,360,113,0
	  db	"After pitch$"
	dw	Text,360,126,0
	  db	"After volume$"
	dw	Text,16,171,0
	  db	"Voice Nr$"
	dw	Text,16,189,0
	  db	"Value$"
	dw	Text,32,207,0
	  db	"Master delay$"
	dw	Text,32,220,0
	  db	"Master pitch$"
	dw	Text,32,233,0
	  db	"Master volume$"
	dw	Text,16,260,0
	  db	"Voice Nr$"
	dw	Text,32,278,0
	  db	"Delay env.$"
	dw	Text,32,291,0
	  db	"Pitch env.$"
	dw	Text,32,304,0
	  db	"Volume env.$"
	dw	Text,32,317,0
	  db	"Time comp./Real pitch$"
	dw	Text,200,258,0
	  db	"Voice repeat$"
	dw	Text,200,271,0
	  db	"Feed back$"
	dw	Text,200,284,0
	  db	"Bwd Direction$"
	dw	Text,256,315,0
	  db	"Voice Startoffset$"
	dw	Text,192,145,1
	  db	"TIME VAR$"
	dw	Text,264,145,1
	  db	"TIME INVAR$"
	dw	EndCode



EffectNewMultiPicture	Label	Word
	dw	Popup,104,207,432,100
	dw	Fill,103,47,327,59,0
	dw	BigBorder,101,45,329,61,0
	dw	Button,272,73,331,89,1
	dw	Button,332,73,417,89,1
	dw	Text,288,76,1
	  db	"OKAY$"
	dw	Text,352,76,1
	  db	"CANCEL$"
	dw	EndCode

SampVolStereo		Label	Word
	dw	Popup,232,186,168,29
	dw	Picture,48,0,11,0
	dw	Picture,48,17,11,0
	dw	Picture,139,0,12,0
	dw	Picture,139,17,12,0
	dw	BigBorder,70,0,137,11,0
	dw	BigBorder,70,17,137,28,0
	dw	Text,8,0,0
	  db	"Left$"
	dw	Text,0,17,0
	  db	"Right$"
	dw	EndCode
SampVolMono		Label	Word
	dw	Popup,232,186,168,29
	dw	Picture,48,0,11,0
	dw	Picture,139,0,12,0
	dw	BigBorder,70,0,137,11,0
	dw	Text,8,0,0
	  db	"MONO$"
	dw	EndCode

SampVolClear		Label	Word
	dw	Popup,232,186,160,29
	dw	EndCode

EffectChoosePicture	Label	Word
	dw	PopUp,60,17,520,446
	dw	Picture,246-4,35,23,0
	dw	Picture,494-4,35,23,0
	dw	Picture,494-4,234,23,0
	dw	Picture,246-4,398,24,0
	dw	Picture,494-4,170,24,0
	dw	Picture,494-4,345,24,0
	dw	Fill,15,37,239,410,0
	dw	Fill,263,37,487,181,0
	dw	Fill,263,236,487,356,0
	dw	BigBorder,13,35,241,412,0
	dw	BigBorder,261,35,489,183,0
	dw	BigBorder,261,234,489,358,0
	dw	BigBorder,246,51,257,396,0
	dw	BigBorder,494,51,505,168,0
	dw	BigBorder,494,250,505,343,0
	dw	Button,13,415,75,431,1
	dw	Button,76,415,138,431,1
	dw	Button,261,186,315,202,1
	dw	Button,316,186,366,202,1
	dw	Button,367,186,439,202,1
	dw	Button,451,186,505,202,1
	dw	Button,451,203,505,219,1
	dw	Button,261,361,371,377,1
	dw	Button,372,361,421,377,1
	dw	Button,360,398,505,414,1
	dw	Button,261,415,359,431,1
	dw	Button,360,415,419,431,1
	dw	Button,420,415,505,431,1
	dw	Button,139,415,219,431,1
	dw	Button,261,203,355,219,1
	dw	Text,72,14,0
	  db	"MULTI EFFECTS$"
	dw	Text,352,14,0
	  db	"EFFECTS$"
	dw	Text,368,218,0
	  db	"LIST$"
	dw	Text,32,418,1
	  db	"NEW$"
	dw	Text,96,418,1
	  db	"DEL$"
	dw	Text,272,189,1
	  db	"TEST$"
	dw	Text,328,189,1
	  db	"DEL$"
	dw	Text,384,189,1
	  db	"ADD L$"
	dw	Text,464,189,1
	  db	"NEW$"
	dw	Text,464,206,1
	  db	"EDIT$"
	dw	Text,272,364,1
	  db	"<-SAVE LIST$"
	dw	Text,384,364,1
	  db	"DEL$"
	dw	Text,384,401,1
	  db	"SAVE TO DISK$"
	dw	Text,288,418,1
	  db	"PREVIEW$"
	dw	Text,376,418,1
	  db	"OKAY$"
	dw	Text,440,418,1
	  db	"CANCEL$"
	dw	Text,152,418,1
	  db	"RENAME$"
	dw	Text,272,206,1
	  db	"ADD MULTI$"
	dw	EndCode

ResamplePicture 	Label	Word
	dw	Popup,132,248,376,86
	dw	Picture,324,31,34,0
	dw	Picture,148,31,34,0
	dw	Picture,148,52,34,0
	dw	Fill,295,33,319,45,0
	dw	Fill,119,33,143,45,0
	dw	Fill,119,54,143,66,0
	dw	Bigborder,117,31,145,47,0
	dw	Bigborder,117,52,145,68,0
	dw	Bigborder,293,31,321,47,0
	dw	Button,214,52,280,68,1
	dw	Button,283,52,357,68,1
	dw	Text,152,11,0
	  db	"RESAMPLE$"
	dw	Text,16,34,0
	  db	"CURRENT NOTE$"
	dw	Text,8,55,0
	  db	"RESAMPLE NOTE$"
	dw	Text,192,34,0
	  db	"REL. H. NOTE$"
	dw	Text,232,55,1
	  db	"OKAY$"
	dw	Text,296,55,1
	  db	"CANCEL$"
	dw	EndCode


MarkPicture		Label	Word
	dw	PopUp,60,100,512,210
	dw	Picture,124,40,34,0
	dw	Picture,124,61,34,0
	dw	Picture,124,125,34,0
	dw	Picture,124,146,34,0
	dw	SmallBorder,10,32,164,109,0
	dw	SmallBorder,11,33,163,108,1
	dw	SmallBorder,10,117,164,194,0
	dw	SmallBorder,11,118,163,193,1
	dw	BigBorder,61,40,121,56,0
	dw	BigBorder,61,61,121,77,0
	dw	BigBorder,61,125,121,141,0
	dw	BigBorder,61,146,121,162,0
	dw	Fill,63,42,119,54,0
	dw	Fill,63,63,119,75,0
	dw	Fill,63,127,119,139,0
	dw	Fill,63,148,119,160,0
	dw	Button,39,86,145,102,1
	dw	Button,39,171,145,187,1
	dw	Button,172,32,324,48,1
	dw	Button,172,50,324,66,1
	dw	Button,172,68,324,84,1
	dw	Button,172,86,324,102,1
	dw	Button,172,104,324,120,1
	dw	Button,332,32,500,48,1
	dw	Button,332,50,500,66,1
	dw	Button,332,68,500,84,1
	dw	Button,332,86,500,102,1
	dw	Button,431,184,496,200,1
	dw	Text,232,11,0
	  db	"MARK$"
	dw	Text,16,43,0
	  db	"START$"
	dw	Text,32,64,0
	  db	"END$"
	dw	Text,16,128,0
	  db	"START$"
	dw	Text,32,149,0
	  db	"END$"
	dw	Text,48,89,1
	  db	"MARK OFFSET$"
	dw	Text,56,174,1
	  db	"MARK TIME$"
	dw	Text,184,35,1
	  db	"START TO REPBEG$"
	dw	Text,192,53,1
	  db	"REPEND TO END$"
	dw	Text,184,71,1
	  db	"REPBEG TO REPEND$"
	dw	Text,184,89,1
	  db	"START TO PLAYPEG$"
	dw	Text,192,107,1
	  db	"PLAYPEG TO END$"
	dw	Text,344,35,1
	  db	"START TO MARKSTART$"
	dw	Text,352,53,1
	  db	"START TO MARKEND$"
	dw	Text,352,71,1
	  db	"MARKSTART TO END$"
	dw	Text,360,89,1
	  db	"MARKEND TO END$"
	dw	Text,440,187,1
	  db	"CANCEL$"
	dw	EndCode

NewVolPicture		Label	Word
	dw	PopUp,108,232,424,112
	dw	Picture,100,38,34,0
	dw	Picture,100,57,34,0
	dw	Picture,196,38,34,0
	dw	Picture,354,36,20,0
	dw	SmallBorder,10,32,141,102,0
	dw	SmallBorder,11,33,140,101,1
	dw	SmallBorder,145,32,247,102,0
	dw	SmallBorder,146,33,246,101,1
	dw	SmallBorder,251,32,348,102,0
	dw	SmallBorder,252,33,347,101,1
	dw	BigBorder,61,38,97,54,0
	dw	BigBorder,61,57,97,73,0
	dw	BigBorder,157,38,193,54,0
	dw	Fill,63,40,95,52,0
	dw	Fill,63,59,95,71,0
	dw	Fill,159,40,191,52,0
	dw	Button,32,80,127,96,1
	dw	Button,152,80,240,96,1
	dw	Button,257,80,342,96,1
	dw	Button,353,80,414,96,1
	dw	Button,257,57,334,73,1
	dw	Button,13,38,58,54,1
	dw	Button,13,57,58,73,1
	dw	Text,176,12,0
	  db	"VOLUME$"
	dw	Text,16,41,1
	  db	"START$"
	dw	Text,24,60,1
	  db	"END$"
	dw	Text,40,83,1
	  db	"SET VOLUME$"
	dw	Text,160,83,1
	  db	"BREAK VOL$"
	dw	Text,264,83,1
	  db	"NORMALIZE$"
	dw	Text,360,83,1
	  db	"CANCEL$"
	dw	Text,264,60,1
	  db	"MAXIMIZE$"
	dw	EndCode

YesNoUpLeftPicture	Label	Word
	dw	PopUp,88,92,432,64
	dw	Button,159,36,217,54,1
	dw	Button,218,36,272,54,1
	dw	Text,176,40,1
	  db	"YES$"
	dw	Text,240,40,1
	  db	"NO$"
	dw	EndCode

ColorSpecial1	Label	Word
	dw	PopUp,288,108,232,14
	dw	EndCode

ColorSpecial2	Label	Word
	dw	PopUp,288,108,232,14
	dw	Picture,79,0,11,0
	dw	Picture,204,0,12,0
	dw	BigBorder,102,0,201,11,0
	dw	Text,8,0,0
	  db	"CONTRAST$"
	dw	EndCode

ColorSpecial3	Label	Word
	dw	PopUp,288,108,232,14
	dw	Picture,79,0,11,0
	dw	Picture,204,0,12,0
	dw	BigBorder,102,0,201,11,0
	dw	Text,24,0,0
	  db	"SHADOW$"
	dw	EndCode

ColorSpecial4	Label	Word
	dw	PopUp,288,108,232,14
	dw	Picture,79,0,11,0
	dw	Picture,204,0,12,0
	dw	BigBorder,102,0,201,11,0
	dw	Text,0,0,0
	  db	"INTENSITY$"
	dw	EndCode

ColorsPicture	Label	Word
	dw	PopUp,112,32,416,172
	dw	Picture,255,34,11,0
	dw	Picture,255,48,11,0
	dw	Picture,255,62,11,0
	dw	Picture,380,34,12,0
	dw	Picture,380,48,12,0
	dw	Picture,380,62,12,0
	dw	Button,8,34,19,45,1
	dw	Button,8,48,19,59,1
	dw	Button,8,62,19,73,1
	dw	Button,8,76,19,87,1
	dw	Button,8,90,19,101,1
	dw	Button,8,104,19,115,1
	dw	Button,8,118,19,129,1
	dw	Button,8,132,19,143,1
	dw	Button,8,146,19,157,1
	dw	Button,253,119,266,136,1
	dw	Button,269,119,283,136,1
	dw	Button,285,119,298,136,1
	dw	Button,301,119,314,136,1
	dw	Button,231,147,288,164,1
	dw	Button,289,147,349,164,1
	dw	Button,350,147,400,164,1
	dw	BigBorder,278,34,377,45,0
	dw	BigBorder,278,48,377,59,0
	dw	BigBorder,278,62,377,73,0
	dw	Text,24,34,0
	  db	"BACKGROUND$"
	dw	Text,24,48,0
	  db	"BUTTON$"
	dw	Text,24,62,0
	  db	"SURFACE$"
	dw	Text,24,76,0
	  db	"FONT ON BACKGROUND$"
	dw	Text,24,90,0
	  db	"FONT ON SURFACE$"
	dw	Text,24,104,0
	  db	"PEG IN SAMPED$"
	dw	Text,24,118,0
	  db	"EQUALIZER$"
	dw	Text,24,132,0
	  db	"MOUSE$"
	dw	Text,24,146,0
	  db	"BARS IN PATT.$"
	dw	Text,176,12,0
	  db	"COLORS$"
	dw	Text,240,34,0
	  db	"R$"
	dw	Text,240,48,0
	  db	"G$"
	dw	Text,240,62,0
	  db	"B$"
	dw	Text,184,122,0
	  db	"PRE.DEF.$"
	dw	Text,240,150,1
	  db	"RESET$"
	dw	Text,360,150,1
	  db	"OKAY$"
	dw	Text,296,150,1
	  db	"CANCEL$"
	dw	Text,256,122,1
	  db	"1$"
	dw	Text,272,122,1
	  db	"2$"
	dw	Text,288,122,1
	  db	"3$"
	dw	Text,304,122,1
	  db	"4$"
	dw	EndCode

StartSamplePicture	Label	Word
	dw	PopUp,104,112,432,63
	dw	Fill,8,8,263,53,0
	dw	Fill,359,8,424,20,0
	dw	BigBorder,6,6,265,55,0
	dw	BigBorder,357,6,426,22,0
	dw	Button,371,39,425,57,1
	dw	Text,320,9,0
	  db	"SIZE$"
	dw	Text,384,43,1
	  db	"STOP$"
	dw	EndCode

Pop20Picture	Label	Word
	dw	PopUp,104,260,432,64
	dw	Button,119,36,177,54,1
	dw	Button,178,36,232,54,1
	dw	Button,233,36,310,54,1
	dw	Text,136,40,1
	  db	"YES$"
	dw	Text,200,40,1
	  db	"NO$"
	dw	Text,248,40,1
	  db	"CANCEL$"
	dw	EndCode

Pop16Picture	Label	Word
	dw	PopUp,104,260,432,64
	dw	Button,189,36,245,54,1
	dw	Text,200,40,1
	  db	"OKAY$"
	dw	EndCode

Pop17Picture	Label	Word
	dw	PopUp,104,260,432,64
	dw	Button,159,36,217,54,1
	dw	Button,218,36,272,54,1
	dw	Text,176,40,1
	  db	"YES$"
	dw	Text,240,40,1
	  db	"NO$"
	dw	EndCode

Pop21Picture	Label	Word
	dw	PopUp,104,200,432,64
	dw	Button,159,36,217,54,1
	dw	Button,218,36,272,54,1
	dw	Text,176,40,1
	  db	"YES$"
	dw	Text,240,40,1
	  db	"NO$"
	dw	EndCode

Pop22Picture	Label	Word
	dw	PopUp,104,200,432,64
	dw	Button,119,36,177,54,1
	dw	Button,178,36,232,54,1
	dw	Button,233,36,310,54,1
	dw	Text,136,40,1
	  db	"YES$"
	dw	Text,200,40,1
	  db	"NO$"
	dw	Text,248,40,1
	  db	"CANCEL$"
	dw	EndCode


ShitPicture	Label	Word
	dw	PopUp,64,30,504,180
	dw	Button,221,152,274,170,1
	dw	Text,232,156,1
	  db	"OKAY$"
	dw	EndCode

TextPicture	Label	Word
	dw	PopUp,64,30,504,180
	dw	Button,437,152,491,171,1	;Okay
;	dw	Button,32,192,45,204,0		;Mode 1
;	dw	Button,32,208,45,220,1		;Mode 2
;	dw	Button,32,224,45,236,1		;Mode 3
;	dw	Text,48,192,0
;	  db	"TestMode. Save Disabled$"
;	dw	Text,48,208,0
;	  db	"PatternEditMode. SampEd, InstEd Disabled$"
;	dw	Text,48,224,0
;	  db	"InstrumentMode. PatternEdit Disabled$"
	dw	Text,448,156,1
	  db	"OKAY$"
	dw	EndCode

OldVolumePicture	Label	Word
	dw	PopUp,64,30,504,180
	dw	Picture,307,7,34,1
	dw	Picture,307,28,34,1
	dw	Fill,8,9,207,162,0
	dw	Fill,271,9,303,21,0
	dw	Fill,271,30,303,42,0
	dw	BigBorder,6,7,209,164,0
	dw	BigBorder,269,7,305,23,0
	dw	BigBorder,269,28,305,44,0
	dw	Button,346,7,482,23,1
	dw	Button,388,137,482,153,1
	dw	Button,388,154,482,170,1
	dw	Text,224,10,0
	  db	"START$"
	dw	Text,240,31,0
	  db	"END$"
	dw	Text,352,10,1
	  db	"SET END TO START$"
	dw	Text,400,140,1
	  db	"CALCULATE$"
	dw	Text,416,157,1
	  db	"CANCEL$"
	dw	EndCode

MixPicture	Label	Word
	dw	PopUp,104,260,432,63
	dw	Picture,156,11,34,1
	dw	Picture,156,35,34,1
	dw	Button,260,38,337,54,1
	dw	Button,338,38,417,54,1
	dw	Fill,118,13,150,25,0
	dw	Fill,118,37,150,49,0
	dw	BigBorder,116,11,152,27,0
	dw	BigBorder,116,35,152,51,0
	dw	Text,64,14,0
	  db	"SAMPLE$"
	dw	Text,40,38,0
	  db	"CLIPBOARD$"
	dw	Text,288,41,1
	  db	"MIX$"
	dw	Text,352,41,1
	  db	"CANCEL$"
	dw	EndCode


PopUp2Picture	Label	Word
	dw	PopUp,168,92,432,64
	dw	Button,159,36,217,54,1
	dw	Button,218,36,272,54,1
	dw	Text,176,40,1
	  db	"YES$"
	dw	Text,240,40,1
	  db	"NO$"
	dw	EndCode

PopUp1Picture	Label	Word
	dw	PopUp,168,92,432,64
	dw	Button,189,36,245,54,1
	dw	Text,200,40,1
	  db	"OKAY$"
	dw	EndCode

Comment %
OptionPicture	Label	Word
	dw	PopUp,64,30,504,180
	dw	Picture,398,92,23,-2
	dw	Picture,398,159,24,-1
	dw	Picture,486,5,23,1
	dw	Picture,486,72,24,2
	dw	Button,421,156,489,172,1
	dw	Fill,7,7,479,84,0
	dw	Fill,7,94,391,171,0
	dw	BigBorder,5,5,481,86,0
	dw	BigBorder,5,92,393,173,0
	dw	BigBorder,398,108,409,157,0
	dw	BigBorder,486,21,497,70,0
	dw	Text,440,159,1
	  db	"EXIT$"
	dw	EndCode
%

KeysPicture	Label	Word
	dw	PopUp,0,7,640,268
	dw	Picture,614,23,23,0
	dw	Picture,614,220,24,0
	dw	Button,557,239,625,255,1	;Exit
	dw	Button,445,239,475,255,1	;VS1
	dw	Button,477,239,507,255,1	;FT2
	dw	Button,509,239,539,255,1	;ST3
	dw	Button,9,25,21,36,1		;1
	dw	Button,9,40,21,51,1		;2
	dw	Button,9,55,21,66,1		;3
	dw	Button,9,70,21,81,1		;4
	dw	Button,9,85,21,96,1		;5
	dw	Button,9,100,21,111,1		;6
	dw	Button,9,115,21,126,1		;7
	dw	Button,9,130,21,141,1		;8
	dw	Button,9,145,21,156,1		;9
	dw	Button,9,160,21,171,1		;10
	dw	Button,9,175,21,186,1		;11
	dw	Button,9,190,21,201,1		;12
	dw	Button,9,205,21,216,1		;13
	dw	Button,9,220,21,231,1		;14
	dw	BigBorder,141,22,609,233,0
	dw	BigBorder,614,39,625,218,0
	dw	Fill,143,24,607,231,0
	dw	Text,576,242,1
	  db	"EXIT$"
	dw	Text,448,242,1
	  db	"VS$"
	dw	Text,480,242,1
	  db	"FT2$"
	dw	Text,512,242,1
	  db	"ST3$"
	dw	Text,264,6,0
	  db	"CONFIGURE KEYS$"

	dw	Text,24,25,0
	  db	"Menu Select$"
	dw	Text,24,40,0
	  db	"Slot Commands$"
	dw	Text,24,55,0
	  db	"Transpose$"
	dw	Text,24,70,0
	  db	"Play$"
	dw	Text,24,85,0
	  db	"Record$"
	dw	Text,24,100,0
	  db	"Misc Edit$"
	dw	Text,24,115,0
	  db	"Mute/Lock$"
	dw	Text,24,130,0
	  db	"Patt. Navig.$"
	dw	Text,24,145,0
	  db	"Song. Navig.$"
	dw	Text,24,160,0
	  db	"Ins/Del$"
	dw	Text,24,175,0
	  db	"Edit func.$"
	dw	Text,24,190,0
	  db	"Block func.$"
	dw	Text,24,205,0
	  db	"Stored Pos.$"
	dw	Text,24,220,0
	  db	"Inst. specific$"

	dw	EndCode





SamplePicture	Label	Word
	dw	PopUp,64,30,504,224
	dw	Picture,7,76,33,0
	dw	Picture,283,91,34,0
SmpNote dw	Button,179,82,233,98,1
SmpRate dw	Button,179,99,233,115,1
	dw	Button,283,125,317,141,1
	dw	Button,260,199,353,215,1
	dw	Button,254,199,353,215,1
	dw	Button,354,199,430,215,1
	dw	Button,431,199,493,215,1
SmpScop dw	Button,367,86 ,379,97 ,1
SmpEqu	dw	Button,367,99 ,379,110,1
	dw	Button,367,117,379,128,1
	dw	Button,367,130,379,141,1
SmpLine dw	Button,367,148,379,159,1
SmpMic	dw	Button,367,161,379,172,1
SmpCD	dw	Button,367,174,379,185,1
	dw	Fill,8,8,135,71,0
	dw	Fill,152,8,191,71,0
	dw	Fill,312,8,351,71,0
	dw	Fill,368,8,495,71,0
	dw	Fill,239,93,279,105,0
	dw	Fill,215,127,279,139,0
	dw	BigBorder,6,6,137,73,0
	dw	BigBorder,150,6,193,73,0
	dw	BigBorder,310,6,353,73,0
	dw	BigBorder,366,6,497,73,0
	dw	BigBorder,237,91,281,107,0
	dw	BigBorder,213,125,281,141,0
	dw	SmallBorder,168,76,327,120,0
	dw	SmallBorder,168,119,327,147,0
	dw	SmallBorder,340,76,497,194,0
	dw	SmallBorder,169,77,326,119,1
	dw	SmallBorder,169,120,326,146,1
	dw	SmallBorder,341,77,496,193,1
	dw	Text,192,85,1
	  db	"NOTE$"
	dw	Text,192,102,1
	  db	"RATE$"
	dw	Text,288,128,1
	  db	"CLR$"
	dw	Text,272,202,1
	  db	"SAMPLE CD$"
	dw	Text,368,202,1
	  db	"SAMPLE$"
	dw	Text,448,202,1
	  db	"EXIT$"
	dw	Text,224,16,0
	  db	"SAMPLE$"
	dw	Text,176,128,0
	  db	"PEAK$"
	dw	Text,384,86,0
	  db	"SCOPES$"
	dw	Text,384,99,0
	  db	"EQUALIZER$"
	dw	Text,384,117,0
	  db	"STEREO$"
	dw	Text,384,130,0
	  db	"16 BITS$"
	dw	Text,384,148,0
	  db	"LINE IN$"
	dw	Text,384,161,0
	  db	"MIC$"
	dw	Text,384,174,0
	  db	"CD INPUT$"
	dw	EndCode


comment &
;SamplePicture	Label	Word
	dw	PopUp,64,30,504,180
	dw	Picture,7,75,33,0
	dw	Picture,459,96,34,1
	dw	Button,204,25,299,41,1
	dw	Button,204,42,299,58,1
	dw	Button,204,59,299,75,1
	dw	Button,168,87,251,103,1
	dw	Button,168,104,251,120,1
SmpMic	dw	Button,168,121,251,137,1
SmpEqu	dw	Button,168,138,251,154,1
	dw	Button,252,87,335,103,1
	dw	Button,252,104,335,120,1
SmpLine dw	Button,252,121,335,137,1
SmpScop dw	Button,252,138,335,154,1
SmpNote dw	Button,355,87,409,103,1
SmpRate dw	Button,355,104,409,120,1
	dw	Button,429,156,497,172,1
	dw	Button,459,130,493,146,1
	dw	Fill,8,8,135,71,0
	dw	Fill,152,8,191,71,0
	dw	Fill,312,8,351,71,0
	dw	Fill,368,8,495,71,0
	dw	Fill,415,98,455,110,0
	dw	Fill,391,132,455,144,0
	dw	BigBorder,6,6,137,73,0
	dw	BigBorder,150,6,193,73,0
	dw	BigBorder,310,6,353,73,0
	dw	BigBorder,366,6,497,73,0
	dw	BigBorder,413,96,457,112,0
	dw	BigBorder,389,130,457,146,0
	dw	SmallBorder,348,81,497,125,0
	dw	SmallBorder,349,82,496,124,1
	dw	SmallBorder,348,124,497,152,0
	dw	SmallBorder,349,125,496,151,1
	dw	Text,224,10,0
	  db	"SAMPLE$"
	dw	Text,224,28,1
	  db	"CD SYNC$"
	dw	Text,216,45,1
	  db	"LEVEL SYNC$"
	dw	Text,232,62,1
	  db	"DIRECT$"
	dw	Text,192,90,1
	  db	"MONO$"
	dw	Text,184,107,1
	  db	"8 BITS$"
	dw	Text,200,124,1
	  db	"MIC$"
	dw	Text,176,141,1
	  db	"EQUALIZER$"
	dw	Text,272,90,1
	  db	"STEREO$"
	dw	Text,272,107,1
	  db	"16 BITS$"
	dw	Text,272,124,1
	  db	"LINE IN$"
	dw	Text,272,141,1
	  db	"SCOPES$"
	dw	Text,368,90,1
	  db	"NOTE$"
	dw	Text,368,107,1
	  db	"RATE$"
	dw	Text,448,159,1
	  db	"EXIT$"
	dw	Text,464,133,1
	  db	"CLR$"
	dw	Text,352,133,0
	  db	"PEAK$"
	dw	EndCode

&




Pop4Picture	Label	Word
	dw	PopUp,168,92,432,64
	dw	Button,128,36,191,54,1
	dw	Button,192,36,241,54,1
	dw	Button,242,36,301,54,1
	dw	Fill,166,19,263,32,0
	dw	BigBorder,165,18,264,33,0
	dw	Text,136,40,1
	  db	"RENAME$"
	dw	Text,200,40,1
	  db	"SKIP$"
	dw	Text,248,40,1
	  db	"CANCEL$"
	dw	EndCode

Pop3Picture	Label	Word
	dw	PopUp,168,92,432,64
	dw	Button,104,36,160,54,1
	dw	Button,161,36,217,54,1
	dw	Button,218,36,270,54,1
	dw	Button,271,36,331,54,1
	dw	Text,120,40,1
	  db	"YES$"
	dw	Text,184,40,1
	  db	"NO$"
	dw	Text,232,40,1
	  db	"ALL$"
	dw	Text,280,40,1
	  db	"CANCEL$"
	dw	EndCode

InfoPicture	Label	Word
	dw	PopUp,64,30,504,180
	dw	Button,418,156,492,172,1
	dw	Text,440,159,1
	  db	"EXIT$"
	dw	Text,8,22,0
	  db	"Soundcard:$"
	dw	Text,8,87,0
	  db	"Total XMS memory:$"
	dw	Text,8,100,0
	  db	"Total free XMS memory:$"
	dw	Text,8,113,0
	  db	"XMS memory in use:$"
	dw	EndCode

InfoPictureGUS	Label	Word
	dw	PopUp,64,30,504,180
	dw	Button,418,156,492,172,1
	dw	Text,440,159,1
	  db	"EXIT$"
	dw	Text,8,22,0
	  db	"Soundcard:$"
	dw	Text,8,35,0
	  db	"Total GUS memory:$"
	dw	Text,8,48,0
	  db	"Total free GUS memory:$"
	dw	Text,8,61,0
	  db	"GUS memory in use:$"
	dw	Text,8,87,0
	  db	"Total XMS memory:$"
	dw	Text,8,100,0
	  db	"Total free XMS memory:$"
	dw	Text,8,113,0
	  db	"XMS memory in use:$"
	dw	Text,264,48,0
	  db	"(may be fragmented)$"
	dw	EndCode

OptimPicture	Label	Word
	dw	PopUp,64,30,504,180
	dw	Button,140,31,194,49,1
	dw	Button,140,57,194,75,1
	dw	Button,140,83,194,101,1
	dw	Button,140,122,194,140,1
;	dw	Button,196,31,267,49,1
	dw	Button,196,57,267,75,1
	dw	Button,196,83,267,101,1
	dw	Button,196,122,267,140,1
	dw	Button,383,83,434,101,1
	dw	Button,435,83,491,101,1
	dw	Button,435,122,491,140,1
	dw	Button,435,156,491,174,1
	dw	Button,383,122,434,140,1
	dw	Button,383,156,434,174,1
	dw	Text,226,9,0
	  db	"OPTIMIZE$"
	dw	Text,8,35,0
	  db	"UNUSED CHANNEL:$"
	dw	Text,8,61,0
	  db	"UNUSED COMMANDS:$"
	dw	Text,8,87,0
	  db	"UNUSED PATTERNS:$"
	dw	Text,32,126,0
	  db	"UNUSED INST.:$"
	dw	Text,320,87,0
	  db	"AFFECT:$"
	dw	Text,144,35,1
	  db	"REMOVE$"
	dw	Text,144,61,1
	  db	"REMOVE$"
	dw	Text,144,87,1
	  db	"REMOVE$"
	dw	Text,144,126,1
	  db	"REMOVE$"
;	dw	Text,200,35,1
;	  db	"COMPRESS$"
	dw	Text,200,61,1
	  db	"COMPRESS$"
	dw	Text,200,87,1
	  db	"COMPRESS$"
	dw	Text,200,126,1
	  db	"COMPRESS$"
	dw	Text,392,87,1
	  db	"PATT$"
	dw	Text,400,126,1
	  db	"ALL$"
	dw	Text,392,160,1
	  db	"OKAY$"
	dw	Text,448,87,1
	  db	"SONG$"
	dw	Text,448,126,1
	  db	"NONE$"
	dw	Text,440,160,1
	  db	"CANCEL$"
	dw	EndCode

ClearPicture	Label	Word
	dw	PopUp,168,92,432,64
	dw	Button,108,36,147,54,1
	dw	Button,148,36,243,54,1
	dw	Button,244,36,275,54,1
	dw	Button,276,36,331,54,1
	dw	Text,112,40,1
	  db	"SONG$"
	dw	Text,152,40,1
	  db	"INSTRUMENT$"
	dw	Text,248,40,1
	  db	"ALL$"
	dw	Text,280,40,1
	  db	"CANCEL$"
	dw	EndCode

SplitPopupPicture	Label	Word
	dw	PopUp,168,92,432,64
	dw	Picture,72,6,23,0
	dw	Picture,72,23,23,0
	dw	Picture,72,40,23,0
	dw	Picture,107,6,24,0
	dw	Picture,107,23,24,0
	dw	Picture,115,40,24,0
	dw	Picture,192,6,23,0
	dw	Picture,192,23,23,0
	dw	Picture,192,40,23,0
	dw	Picture,235,6,24,0
	dw	Picture,235,23,24,0
	dw	Picture,235,40,24,0
	dw	Button,349,5,423,21,1
	dw	Button,349,23,423,38,1
	dw	Button,349,41,423,57,1
	dw	Fill,87,7,103,19,0
	dw	Fill,87,24,103,36,0
	dw	Fill,87,41,110,53,0
	dw	Fill,207,7,231,19,0
	dw	Fill,207,24,231,36,0
	dw	Fill,207,41,231,53,0
	dw	BigBorder,85,5,105,21,0
	dw	BigBorder,85,22,105,38,0
	dw	BigBorder,85,39,112,55,0
	dw	BigBorder,205,5,233,21,0
	dw	BigBorder,205,22,233,38,0
	dw	BigBorder,205,39,233,55,0
	dw	Text,24,8,0
	  db	"SPLIT$"
	dw	Text,32,25,0
	  db	"ZONE$"
	dw	Text,16,42,0
	  db	"SAMPLE$"
	dw	Text,144,8,0
	  db	"BEGIN$"
	dw	Text,160,25,0
	  db	"END$"
	dw	Text,152,42,0
	  db	"BASE$"
	dw	Text,352,8,1
	  db	"CLR. ALL$"
	dw	Text,360,25,1
	  db	"ACTIVE$"
	dw	Text,368,44,1
	  db	"EXIT$"
	dw	EndCode


YFixPicture	Label	word
	dw	PopUp,104,260,432,63
	dw	Picture,147,22,34,1
	dw	Fill,103,24,143,36,0
	dw	BigBorder,101,22,145,38,0
	dw	SmallBorder,7,8,185,54,0
	dw	SmallBorder,8,9,184,53,1
	dw	Button,13,14,89,30,1
	dw	Button,13,31,89,47,1
	dw	Button,193,22,252,38,1
	dw	Button,266,22,341,38,1
	dw	Button,356,22,418,38,1
	dw	Text,24,17,1
	  db	"MOVE UP$"
	dw	Text,16,34,1
	  db	"MOVE DOWN$"
	dw	Text,208,25,1
	  db	"FLIP$"
	dw	Text,280,25,1
	  db	"CENTER$"
	dw	Text,360,25,1
	  db	"CANCEL$"
	dw	EndCode

DiskOpPictureSong   Label   word
	dw	PopUp,284,188,288,34
	dw	Button,  0,0, 55,16,1
	dw	Button, 56,0,111,16,1
	dw	Button,112,0,167,16,1
	dw	Button,168,0,223,16,1
	dw	Button,  0,17,55,33,1
	dw	Button, 56,17,111,33,1
	dw	Button,112,17,167,33,1
	dw	Text,8,3,1
	  db	"*.AMS$"
	dw	Text,64,3,1
	  db	"*.MOD$"
	dw	Text,120,3,1
	  db	"*.S3M$"
	dw	Text,176,3,1
	  db	"*.STM$"
	dw	Text,8,20,1
	  db	"*.XM$"
	dw	Text,64,20,1
	  db	"*.MTM$"
	dw	Text,120,20,1
	  db	"*.ULT$"

	dw	Button,227,0,282,16,1	;*.*
	dw	Button,227,17,282,33,1	 ;ALL
	dw	Text,240,3,1
	  db	"*.*$"
	dw	Text,232,20,1
	  db	"MIXED$"
	dw	EndCode

DiskOpPictureInst   Label   word
	dw	PopUp,284,188,288,34
	dw	Button,  0,0, 55,16,1
	dw	Button, 56,0,111,16,1
	dw	Button,112,0,167,16,1
	dw	Text,8,3,1
	  db	"*.AIS$"
	dw	Text,64,3,1
	  db	"*.XI$"
	dw	Text,120,3,1
	  db	"*.PAT$"

	dw	Button,227,0,282,16,1	;*.*
	dw	Button,227,17,282,33,1	 ;ALL
	dw	Text,240,3,1
	  db	"*.*$"
	dw	Text,232,20,1
	  db	"MIXED$"
	dw	EndCode

DiskOpPictureSamp   Label   word
	dw	PopUp,284,188,288,34
	dw	Button,  0,0, 55,16,1
	dw	Button, 56,0,111,16,1
	dw	Button,112,0,167,16,1
	dw	Button,168,0,223,16,1
	dw	Button,  0,17,55,33,1
	dw	Text,8,3,1
	  db	"*.ASE$"
	dw	Text,64,3,1
	  db	"*.SMP$"
	dw	Text,120,3,1
	  db	"*.WAV$"
	dw	Text,176,3,1
	  db	"*.IFF$"
	dw	Text,8,20,1
	  db	"*.S3I$"

	dw	Button,227,0,282,16,1	;*.*
	dw	Button,227,17,282,33,1	 ;ALL
	dw	Text,240,3,1
	  db	"*.*$"
	dw	Text,232,20,1
	  db	"MIXED$"
	dw	EndCode

DiskOpPicturePatt   Label   word
	dw	PopUp,284,188,288,34
	dw	Button,  0,0, 55,16,1
	dw	Button, 56,0,111,16,1
	dw	Button,112,0,167,16,1
;	dw	Button,168,0,223,16,1
	dw	Text,8,3,1
	  db	"*.ACS$"
	dw	Text,64,3,1
	  db	"*.APS$"
	dw	Text,120,3,1
	  db	"*.XP$"
;	dw	Text,176,3,1
;	  db	"*.XT$"
	dw	Button,227,0,282,16,1	;*.*
	dw	Button,227,17,282,33,1	 ;ALL
	dw	Text,240,3,1
	  db	"*.*$"
	dw	Text,232,20,1
	  db	"MIXED$"
	dw	EndCode

SoundCardPicture	Label Word
	dw	Popup,120,50,400,200
	dw	Picture,86,176,11,0
	dw	Picture,214,176,12,0
	dw	BigBorder,110,176,209,187,0
	dw	Button,16,43,28,54,1
	dw	Button,16,57,28,68,1
	dw	Button,16,71,28,82,1
	dw	Button,16,85,28,96,1
	dw	Button,16,99,28,110,1
	dw	Button,16,113,28,124,1
IF GUSPNP
	dw	Button,16,127,28,138,1
ENDIF
	dw	Button,256,174,319,189,1
	dw	Button,320,174,382,189,1

	dw	Text,136,8,0
	  db	"Soundcard Config$"
	dw	Text,32,43,0
	  db	"Nosound$"
	dw	Text,32,57,0
	  db	"GUS$"
	dw	Text,32,71,0
	  db	"SB PRO$"
	dw	Text,32,85,0
	  db	"SB 16$"
	dw	Text,32,99,0
	  db	"SB$"
	dw	Text,32,113,0
	  db	"GUSMAX$"
IF GUSPNP
	dw	Text,32,127,0
	  db	"GUS PnP$"
ENDIF
	dw	Text,24,176,0
	  db	"SB Amp.$"
	dw	Text,264,176,1
	  db	"UPDATE$"
	dw	Text,328,176,1
	  db	"CANCEL$"
	dw	EndCode

NOSPicture		Label Word
	dw	PopUp,256,90,240,108
	dw	EndCode

GUSPicture		Label Word
	dw	PopUp,256,90,240,108
	dw	Picture,93,0,34,0
	dw	Picture,93,18,34,0
	dw	Picture,93,36,34,0
	dw	Picture,93,54,34,0
	dw	Picture,93,72,34,0
;	dw	Picture,93,90,34,0
	dw	Button,140,3,152,14,1
	dw	Button,140,17,152,28,1
	dw	BigBorder,61,0,89,16,0
	dw	BigBorder,61,18,89,34,0
	dw	BigBorder,61,36,89,52,0
	dw	BigBorder,61,54,89,70,0
	dw	BigBorder,61,72,89,88,0
;	dw	BigBorder,61,90,89,106,0
	dw	Fill,63,2,87,14,0
	dw	Fill,63,20,87,32,0
	dw	Fill,63,38,87,50,0
	dw	Fill,63,56,87,68,0
	dw	Fill,63,74,87,86,0
;	dw	Fill,63,92,87,104,0
	dw	Text,24,3,0
	  db	"Port$"
	dw	Text,0,21,0
	  db	"PlayDMA$"
	dw	Text,8,39,0
	  db	"RecDMA$"
	dw	Text,32,57,0
	  db	"IRQ$"
	dw	Text,0,75,0
	  db	"MIDIIRQ$"
;	dw	Text,0,93,0
;	  db	"GUS MAX$"

	dw	Text,160,3,0
	  db	"PC Timer$"
	dw	Text,160,17,0
	  db	"GUS Timer$"
	dw	EndCode

MAXPicture		Label Word
	dw	PopUp,256,90,240,108
	dw	Picture,93,0,34,0
	dw	Picture,93,18,34,0
	dw	Picture,93,36,34,0
	dw	Picture,93,54,34,0
	dw	Picture,93,72,34,0
;	dw	Picture,93,90,34,0
	dw	Button,140,3,152,14,1
	dw	Button,140,17,152,28,1
	dw	BigBorder,61,0,89,16,0
	dw	BigBorder,61,18,89,34,0
	dw	BigBorder,61,36,89,52,0
	dw	BigBorder,61,54,89,70,0
	dw	BigBorder,61,72,89,88,0
;	dw	BigBorder,61,90,89,106,0
	dw	Fill,63,2,87,14,0
	dw	Fill,63,20,87,32,0
	dw	Fill,63,38,87,50,0
	dw	Fill,63,56,87,68,0
	dw	Fill,63,74,87,86,0
;	dw	Fill,63,92,87,104,0
	dw	Text,24,3,0
	  db	"Port$"
	dw	Text,32,21,0
	  db	"DMA$"
	dw	Text,32,39,0
	  db	"IRQ$"
	dw	Text,0,57,0
	  db	"MIDIIRQ$"
	dw	Text,16,75,0
	  db	"CODEC$"
;	dw	Text,0,93,0
;	  db	"GUS MAX$"

	dw	Text,160,3,0
	  db	"PC Timer$"
	dw	Text,160,17,0
	  db	"GUS Timer$"
	dw	EndCode

PNPPicture		Label Word
	dw	PopUp,256,90,240,108
	dw	Picture,93,0,34,0
	dw	Picture,93,18,34,0
	dw	Picture,93,36,34,0
	dw	Picture,93,54,34,0
	dw	Picture,93,72,34,0
;	dw	Picture,93,90,34,0
	dw	Button,140,3,152,14,1
	dw	Button,140,17,152,28,1
	dw	BigBorder,61,0,89,16,0
	dw	BigBorder,61,18,89,34,0
	dw	BigBorder,61,36,89,52,0
	dw	BigBorder,61,54,89,70,0
	dw	BigBorder,61,72,89,88,0
;	dw	BigBorder,61,90,89,106,0
	dw	Fill,63,2,87,14,0
	dw	Fill,63,20,87,32,0
	dw	Fill,63,38,87,50,0
	dw	Fill,63,56,87,68,0
	dw	Fill,63,74,87,86,0
;	dw	Fill,63,92,87,104,0
	dw	Text,24,3,0
	  db	"Port$"
	dw	Text,32,21,0
	  db	"DMA$"
	dw	Text,32,39,0
	  db	"IRQ$"
	dw	Text,0,57,0
	  db	"MIDIIRQ$"
	dw	Text,16,75,0
	  db	"CODEC$"
;	dw	Text,0,93,0
;	  db	"GUS MAX$"

	dw	Text,160,3,0
	  db	"PC Timer$"
	dw	Text,160,17,0
	  db	"GUS Timer$"
	dw	EndCode

SBPPicture		Label Word
	dw	PopUp,256,90,240,108
	dw	Picture,93,0,34,0
	dw	Picture,93,18,34,0
	dw	Picture,93,36,34,0
;	dw	Picture,93,54,34,0
	dw	Picture,205,54,34,0		;!
	dw	Button,140,3,152,14,1
	dw	BigBorder,61,0,89,16,0
	dw	BigBorder,61,18,89,34,0
	dw	BigBorder,61,36,89,52,0
;	dw	BigBorder,61,54,89,70,0
	dw	BigBorder,157,54,201,70,0	;!
	dw	Fill,63,2,87,14,0
	dw	Fill,63,20,87,32,0
	dw	Fill,63,38,87,50,0
;	dw	Fill,63,56,87,68,0
	dw	Fill,159,56,199,68,0		;!
	dw	Text,24,3,0
	  db	"Port$"
	dw	Text,32,21,0
	  db	"DMA$"
;	dw	Text,0,39,0
;	  db	"16B DMA$"
	dw	Text,32,39,0
	  db	"IRQ$"
	dw	Text,160,3,0
	  db	"Stereo$"
	dw	Text,136,57,0			;!
	  db	"Hz$"
	dw	EndCode

SB16Picture	Label Word
	dw	PopUp,256,90,240,108
	dw	Picture,93,0,34,0
	dw	Picture,93,18,34,0
	dw	Picture,93,36,34,0
	dw	Picture,93,54,34,0
	dw	Picture,205,54,34,0		;!
	dw	Button,140,3,152,14,1
	dw	Button,140,17,152,28,1
	dw	BigBorder,61,0,89,16,0
	dw	BigBorder,61,18,89,34,0
	dw	BigBorder,61,36,89,52,0
	dw	BigBorder,61,54,89,70,0
	dw	BigBorder,157,54,201,70,0	;!
	dw	Fill,63,2,87,14,0
	dw	Fill,63,20,87,32,0
	dw	Fill,63,38,87,50,0
	dw	Fill,63,56,87,68,0
	dw	Fill,159,56,199,68,0		;!
	dw	Text,24,3,0
	  db	"Port$"
	dw	Text,32,21,0
	  db	"DMA$"
	dw	Text,0,39,0
	  db	"16B DMA$"
	dw	Text,32,57,0
	  db	"IRQ$"
	dw	Text,160,3,0
	  db	"Stereo$"
	dw	Text,160,17,0
	  db	"16 bit$"
	dw	Text,136,57,0			;!
	  db	"Hz$"
	dw	EndCode

SBPicture	Label Word
	dw	PopUp,256,90,232,108
	dw	Picture,93,0,34,0
	dw	Picture,93,18,34,0
	dw	Picture,93,36,34,0
	dw	Picture,205,54,34,0		;!
	dw	BigBorder,61,0,89,16,0
	dw	BigBorder,61,18,89,34,0
	dw	BigBorder,61,36,89,52,0
	dw	BigBorder,157,54,201,70,0	;!
	dw	Fill,63,2,87,14,0
	dw	Fill,63,20,87,32,0
	dw	Fill,63,38,87,50,0
	dw	Fill,159,56,199,68,0		;!
	dw	Text,24,3,0
	  db	"Port$"
	dw	Text,32,21,0
	  db	"DMA$"
	dw	Text,32,39,0
	  db	"IRQ$"
	dw	Text,136,57,0			;!
	  db	"Hz$"
	dw	EndCode

EchoEditorPicture	Label	Word
	dw	Popup,177,28,272,158
	dw	Picture,84,42,34,0
	dw	Picture,84,60,34,0
	dw	Picture,84,78,34,0
	dw	Picture,84,96,34,0
	dw	Picture,212,42,34,0
	dw	Picture,228,78,34,0
	dw	Picture,228,96,34,0
	dw	Fill,63,44,79,56,0
	dw	Fill,63,62,79,74,0
	dw	Fill,63,80,79,92,0
	dw	Fill,63,98,79,110,0
	dw	Fill,191,44,207,56,0
	dw	Fill,191,80,223,92,0
	dw	Fill,191,98,223,110,0
	dw	BigBorder,61,42,81,58,0
	dw	BigBorder,61,60,81,76,0
	dw	BigBorder,61,78,81,94,0
	dw	BigBorder,61,96,81,112,0
	dw	BigBorder,189,42,209,58,0
	dw	BigBorder,189,78,225,94,0
	dw	BigBorder,189,96,225,112,0
	dw	Button,20,134,34,150,1
	dw	Button,36,134,50,150,1
	dw	Button,52,134,65,150,1
	dw	Button,73,134,117,150,1
	dw	Button,163,134,203,150,1
	dw	Button,204,134,261,150,1
	dw	Text,96,12,0
	  db	"Echo Editor$"
	dw	Text,16,45,0
	  db	"From:$"
	dw	Text,16,63,0
	  db	"Chan:$"
	dw	Text,8,81,0
	  db	"Delay:$"
	dw	Text,16,99,0
	  db	"Rate:$"
	dw	Text,24,137,1
	  db	"1$"
	dw	Text,40,137,1
	  db	"2$"
	dw	Text,56,137,1
	  db	"3$"
	dw	Text,80,137,1
	  db	"Wrap$"
	dw	Text,168,137,1
	  db	"Okay$"
	dw	Text,208,137,1
	  db	"Cancel$"
	dw	Text,160,45,0
	  db	"To:$"
	dw	Text,136,81,0
	  db	"Decay:$"
	dw	Text,136,99,0
	  db	"Decay:$"
	dw	EndCode

HelpPicture	Label	Word
	dw	Popup,72,16,496,410
	dw	Picture,470,28,23,0
	dw	Picture,470,365,24,0		;Arr dn
	dw	BigBorder,5,28,467,379,0	;Help text
	dw	BigBorder,53,7,137,23,0
	dw	BigBorder,470,44,481,363,0	;Drag
	dw	Fill,55,9,135,21,0
	dw	Fill,7,30,465,377,0		;Help text
	dw	Button,140,7,195,23,1
	dw	Button,203,7,299,23,1
	dw	Button,308,7,355,23,1
	dw	Button,356,7,395,23,1
	dw	Button,430,383,481,399,1	;Exit
	dw	Text,148,10,1
	  db	"Search$"
	dw	Text,208,10,1
	  db	"Search Next$"
	dw	Text,312,10,1
	  db	"Index$"
	dw	Text,360,10,1
	  db	"Back$"
	dw	Text,440,386,1
	  db	"EXIT$"
	dw	EndCode

PattDefPicture	Label	Word
	dw	Popup,184,40,208,138
	dw	Picture,141,42,34,0
	dw	Picture,141,60,34,0
	dw	Picture,141,78,34,0
	dw	BigBorder,109,42,137,58,0
	dw	BigBorder,109,60,137,76,0
	dw	BigBorder,109,78,137,94,0
	dw	Fill,111,44,135,56,0
	dw	Fill,111,62,135,74,0
	dw	Fill,111,80,135,92,0
	dw	Button,98,111,174,127,1
	dw	Text,48,13,0
	  db	"Default Settings$"
	dw	Text,32,44,0
	  db	"Commands:$"
	dw	Text,32,62,0
	  db	"Channels:$"
	dw	Text,64,81,0
	  db	"Rows:$"
	dw	Text,120,114,1
	  db	"EXIT$"
	dw	EndCode

ConfigPathPicture	Label	Word
	dw	Popup,184,40,264,215
	dw	Button,8,37,20,48,1
	dw	Button,8,54,20,65,1
	dw	Button,8,71,20,82,1
	dw	Button,8,88,20,99,1
	dw	Button,196,188,249,204,1
	dw	Text,112,10,0
	  db	"PATHS$"
	dw	Text,24,37,0
	  db	"SONG$"
	dw	Text,24,54,0
	  db	"INST$"
	dw	Text,24,71,0
	  db	"SAMP$"
	dw	Text,24,88,0
	  db	"PATT$"
	dw	Text,208,191,1
	  db	"EXIT$"
	dw	EndCode

ConfigPathSong	Label	Word
	dw	Popup,264,74,176,143
	dw	Button,5,0,33,16,1
	dw	Button,5,18,33,34,1
	dw	Button,5,36,33,52,1
	dw	Button,5,54,33,70,1
	dw	Button,5,72,33,88,1
	dw	Button,5,90,33,106,1
	dw	Button,5,108,33,124,1
	dw	Button,5,126,33,142,1
	dw	Fill,39,2,167,14,0
	dw	Fill,39,20,167,32,0
	dw	Fill,39,38,167,50,0
	dw	Fill,39,56,167,68,0
	dw	Fill,39,74,167,86,0
	dw	Fill,39,92,167,104,0
	dw	Fill,39,110,167,122,0
	dw	Fill,39,128,167,140,0
	dw	BigBorder,37,0,169,16,0
	dw	BigBorder,37,18,169,34,0
	dw	BigBorder,37,36,169,52,0
	dw	BigBorder,37,54,169,70,0
	dw	BigBorder,37,72,169,88,0
	dw	BigBorder,37,90,169,106,0
	dw	BigBorder,37,108,169,124,0
	dw	BigBorder,37,126,169,142,0
	dw	Text,8,3,1
	  db	"AMS$"
	dw	Text,8,21,1
	  db	"MOD$"
	dw	Text,8,39,1
	  db	"S3M$"
	dw	Text,8,57,1
	  db	"STM$"
	dw	Text,8,75,1
	  db	"XM$"
	dw	Text,8,93,1
	  db	"MTM$"
	dw	Text,8,111,1
	  db	"ULT$"
	dw	Text,8,129,1
	  db	"mix$"
	dw	EndCode


ConfigPathPatt	Label	Word
	dw	Popup,264,74,176,143
	dw	Button,5,0,33,16,1
	dw	Button,5,18,33,34,1
	dw	Button,5,36,33,52,1
	dw	Button,5,54,33,70,1
	dw	Fill,39,2,167,14,0
	dw	Fill,39,20,167,32,0
	dw	Fill,39,38,167,50,0
	dw	Fill,39,56,167,68,0
	dw	BigBorder,37,0,169,16,0
	dw	BigBorder,37,18,169,34,0
	dw	BigBorder,37,36,169,52,0
	dw	BigBorder,37,54,169,70,0
	dw	Text,8,3,1
	  db	"ACS$"
	dw	Text,8,21,1
	  db	"APS$"
	dw	Text,8,39,1
	  db	"XP$"
	dw	Text,8,57,1
	  db	"mix$"
	dw	EndCode

ConfigPathInst	Label	Word
	dw	Popup,264,74,176,143
	dw	Button,5,0,33,16,1
	dw	Button,5,18,33,34,1
	dw	Button,5,36,33,52,1
	dw	Button,5,54,33,70,1
	dw	Fill,39,2,167,14,0
	dw	Fill,39,20,167,32,0
	dw	Fill,39,38,167,50,0
	dw	Fill,39,56,167,68,0
	dw	BigBorder,37,0,169,16,0
	dw	BigBorder,37,18,169,34,0
	dw	BigBorder,37,36,169,52,0
	dw	BigBorder,37,54,169,70,0
	dw	Text,8,3,1
	  db	"AIS$"
	dw	Text,8,21,1
	  db	"XI$"
	dw	Text,8,39,1
	  db	"PAT$"
	dw	Text,8,57,1
	  db	"mix$"
	dw	EndCode

ConfigPathSamp	Label	Word
	dw	Popup,264,74,176,143
	dw	Button,5,0,33,16,1
	dw	Button,5,18,33,34,1
	dw	Button,5,36,33,52,1
	dw	Button,5,54,33,70,1
	dw	Button,5,72,33,88,1
	dw	Button,5,90,33,106,1
	dw	Fill,39,2,167,14,0
	dw	Fill,39,20,167,32,0
	dw	Fill,39,38,167,50,0
	dw	Fill,39,56,167,68,0
	dw	Fill,39,74,167,86,0
	dw	Fill,39,92,167,104,0
	dw	BigBorder,37,0,169,16,0
	dw	BigBorder,37,18,169,34,0
	dw	BigBorder,37,36,169,52,0
	dw	BigBorder,37,54,169,70,0
	dw	BigBorder,37,72,169,88,0
	dw	BigBorder,37,90,169,106,0
	dw	Text,8,3,1
	  db	"ASE$"
	dw	Text,8,21,1
	  db	"SMP$"
	dw	Text,8,39,1
	  db	"WAV$"
	dw	Text,8,57,1
	  db	"IFF$"
	dw	Text,8,75,1
	  db	"S3I$"
	dw	Text,8,93,1
	  db	"mix$"
	dw	EndCode

ConfigOptionsPicture	Label	Word
	dw	Popup,80,20,480,391
	dw	Picture,294,23,23,0
	dw	Picture,294,220,24,0
	dw	Picture,454,251,23,0
	dw	Picture,454,331,24,0
	dw	Button,397,358,464,374,1
	dw	Button,9,25,21,36,1		;Layout
	dw	Button,9,40,21,51,1		;Edit
	dw	Button,9,55,21,66,1		;Messages
	dw	Button,9,70,21,81,1		;Disk Op
	dw	Button,9,85,21,96,1		;PLayer
	dw	Button,9,100,21,111,1		;Samped
	dw	Button,9,115,21,126,1		;Eq
	dw	Button,9,130,21,141,1		;Desk
	dw	Button,9,145,21,156,1		;Inst Ed
	dw	BigBorder,157,23,289,234,0
	dw	BigBorder,294,39,305,218,0
	dw	BigBorder,317,23,449,234,0
	dw	BigBorder,157,251,449,345,0
	dw	BigBorder,454,267,465,329,0
	dw	Fill,159,25,287,232,0
	dw	Fill,319,25,447,232,0
	dw	Fill,159,253,447,343,0
	dw	Text,208,6,0
	  db	"Options$"
	dw	Text,416,361,1
	  db	"EXIT$"
	dw	Text,24,25,0
	  db	"Layout$"
	dw	Text,24,40,0
	  db	"Edit$"
	dw	Text,24,55,0
	  db	"Messages$"
	dw	Text,24,70,0
	  db	"Disk Op$"
	dw	Text,24,85,0
	  db	"Player$"
	dw	Text,24,100,0
	  db	"Samp.ed$"
	dw	Text,24,115,0
	  db	"Equalizer$"
	dw	Text,24,130,0
	  db	"Desc. ed$"
	dw	Text,24,145,0
	  db	"Inst. ed$"
	dw	EndCode

EQEditPicture	Label	Word
	dw	Popup,195,20,240,264
	dw	SmallBorder,7,27,112,252,0
	dw	SmallBorder,119,27,133,56,0
	dw	Fill,8,28,111,251,0
	dw	Fill,120,28,132,55,0
	dw	Button,120,236,168,252,1	;Okay
	dw	Button,169,236,232,252,1	;Cancel
	dw	Button,120,211,224,227,1	;Def
	dw	Button,120,187,176,203,1	;Clear
	dw	Button,177,187,224,203,1	;Fill
	dw	Text,128,239,1
	  db	"OKAY$"
	dw	Text,176,239,1
	  db	"CANCEL$"
	dw	Text,128,214,1
	  db	"SET DEFAULT$"
	dw	Text,128,190,1
	  db	"CLEAR$"
	dw	Text,184,190,1
	  db	"FILL$"
	dw	EndCode


;********************************* DRAW POP UP *********************************
;Calls: Esi=Offset to picture code
;	DrawSpecial=(0=None 1=No border, and no popup push,2=just no popup push)
PopUpInfo	dw	4	dup(0)
DrawOffset	dd	0
TempPictureOff	dd	0
DrawSpecial	dd	0
DrawPopUp	Proc	Near
	pushad
	cmp	word ptr [esi],0
	jnz	ErrorCreatePopUp

	cmp	CurrentPlane,1
	jz	NoHidePeg
	mov	HidePlayPeg,1
	call	MoveThePegs
	mov	HidePlayPeg,0
NoHidePeg:

	mov	DrawOffset,esi			;Save code picture offset
	add	esi,2

	mov	eax,dword ptr [esi]		;Save popup cords
	mov	ebx,dword ptr [esi+4]
	mov	dword ptr [PopUpInfo],eax
	mov	dword ptr [PopUpInfo+4],ebx
	add	esi,8
						;Alloc Picture
	mov	ebp,1037
	movzx	eax,word ptr [PopUpInfo+6]
	movzx	ebx,word ptr [PopUpInfo+4]
	shr	ebx,1
	mul	ebx
	xor	ebx,ebx

	cmp	MemErrorStatus,0
	jz	NoMemError3
	mov	eax,Gus_TempBuffPtr
	add	eax,20000
	jmp	AfterMemError3
NoMemError3:
	call	MemAlloc
	jc	ErrorCreatePopup
AfterMemError3:
	mov	TempPictureOff,eax
						;Fill popup fast
	mov	edi,eax
	movzx	ecx,word ptr [PopUpInfo+6]
FillBackFast:
	push	ecx
	mov	al,-1
	movzx	ecx,word ptr [PopUpInfo+4]
	shr	ecx,3
	mov	edx,ecx
	shl	ecx,1
	add	ecx,edx
	rep	stosb
	mov	al,0
	movzx	ecx,word ptr [PopUpInfo+4]
	shr	ecx,3
	rep	stosb
	pop	ecx
	loop	FillBackFast

	cmp	DrawSpecial,1
	jz	SkipBorder
						;Draw main border
	mov	eax,TempPictureOff
	mov	ButtonNewOffset,eax
	mov	ButtonX1,0
	mov	ButtonY1,0
	movzx	eax,word ptr [PopUpInfo+4]
	dec	eax
	mov	ButtonX2,eax
	movzx	eax,word ptr [PopUpInfo+6]
	dec	eax
	mov	ButtonY2,eax
	mov	bl,0
	movzx	eax,word ptr [PopUpInfo+4]
	shr	eax,3
	mov	SizeX,eax
	call	ButtonUpDownMem2

	mov	eax,TempPictureOff
	mov	ButtonNewOffset,eax
	mov	ButtonX1,3
	mov	ButtonY1,3
	movzx	eax,word ptr [PopUpInfo+4]
	sub	eax,4
	mov	ButtonX2,eax
	movzx	eax,word ptr [PopUpInfo+6]
	sub	eax,4
	mov	ButtonY2,eax
	mov	bl,1
	mov	ButtonSetColor,1
	mov	ButtonC1,4
	mov	ButtonC2,3
	movzx	eax,word ptr [PopUpInfo+4]
	shr	eax,3
	mov	SizeX,eax
	call	ButtonUpDownMem
SkipBorder:

SkipPictureLoop:				;Skip Pictures now
	cmp	word ptr [esi],-1
	jz	SaveBackgroundToBuffer
	cmp	word ptr [esi],5
	jnz	AfterPictureSkipLoop
	add	esi,10
	jmp	SkipPictureLoop
AfterPictureSkipLoop:

DrawCodeLoop:					;Draw Code
	cmp	word ptr [esi],-1
	jz	AfterDrawCode
	movzx	ebx,word ptr [esi]
	mov	eax,[CodeCallTable+ebx*4]
	call	eax
	jmp	DrawCodeLoop
AfterDrawCode:

SaveBackgroundToBuffer: 			;Save background to buffer
	cmp	DrawSpecial,1
	jz	SkipPusha
	cmp	DrawSpecial,2
	jz	SkipPusha
	movzx	eax,word ptr [PopUpInfo+0*2]
	movzx	ebx,word ptr [PopUpInfo+1*2]
	movzx	ecx,word ptr [PopUpInfo+2*2]
	movzx	edx,word ptr [PopUpInfo+3*2]
	add	ecx,eax
	add	edx,ebx
	dec	ecx
	dec	edx
	call	PushPart
	jc	ErrorCreatePopup
SkipPusha:

PutOutPictureOnScreen:				;Put out picture on screen
	move	edi,0a0000h
	movzx	eax,word ptr [PopUpInfo+2]
	mov	ebx,80
	mul	ebx
	movzx	ebx,word ptr [PopUpInfo]
	shr	ebx,3
	add	eax,ebx
	add	edi,eax

	mov	esi,TempPictureOff
	call	mouseoff
	movzx	ecx,word ptr [PopUpInfo+6]
MoveDataToScreen_:
	push	ecx edi

	mov	ecx,4
	mov	bl,1
DifferentPlanes_:
	push	ecx edi
	planewrite bl
	movzx	ecx,word ptr [PopUpInfo+4]
	shr	ecx,3
	rep	movsb
	pop	edi ecx
	shl	bl,1
	loop	DifferentPlanes_

	pop	edi ecx
	add	edi,80
	loop	MoveDataToScreen_
						;Put Out Pictures on screen
	mov	ebp,DrawOffset
	add	ebp,10
PutPictureLoop:
	cmp	word ptr [ebp],-1
	jz	AfterPutPictureLoop
	cmp	word ptr [ebp],5
	jnz	AfterPutPictureLoop
	push	ebp
	movzx	ebx,word ptr [ebp+6]
	dec	ebx
	mov	eax,[pcxoffsets+ebx*4]
	movzx	ebx,word ptr [ebp+2]
	movzx	ecx,word ptr [PopUpInfo]
	add	ebx,ecx
	mov	PcxX,ebx
	movzx	ebx,word ptr [ebp+4]
	movzx	ecx,word ptr [PopUpInfo+2]
	add	ebx,ecx
	mov	PcxY,ebx
;	movzx	ebx,word ptr [ebp+8]
;	mov	fixproblem,ebx
	call	ShowThePcx
	pop	ebp
	add	ebp,10
	jmp	PutPictureLoop
AfterPutPictureLoop:
	call	mouseon

	xor	eax,eax 			;Dealloc mem
	xor	ebx,ebx
	mov	ebp,1037
	call	MemAlloc

EndDrawPopUp:					;End draw popup
	mov	themovepeg,3
	mov	oldpegpos,-1
	call	MoveThePegs
	mov	themovepeg,0
	mov	DrawSpecial,0
	popad
	ret
ErrorCreatePopUp:				;Error create popup
	mov	DrawSpecial,0
	mov	Menu_popup,0
	mov	word ptr [CurrentMenu],0
	call	poppart
	call	poppart
	jmp	NotEnoughHimem
DrawPopUp	Endp
;**************************************** Different codes *****************
FillCode	Proc	Near
	pushad
	mov	eax,TempPictureOff
	mov	SetAreaOffset,eax
	movzx	eax,word ptr [esi+2]
	mov	SetX1,eax
	movzx	eax,word ptr [esi+4]
	mov	SetY1,eax
	movzx	eax,word ptr [esi+6]
	mov	SetX2,eax
	movzx	eax,word ptr [esi+8]
	mov	SetY2,eax
	movzx	eax,word ptr [esi+10]
	mov	SetColor,eax
	movzx	eax,word ptr [PopUpInfo+4]
	shr	eax,3
	mov	PictureX,eax
	call	SetArea
	popad
	add	esi,12
	ret
FillCode	Endp
BigBorderCode	Proc	Near
	pushad
	mov	eax,TempPictureOff
	mov	ButtonNewOffset,eax
	movzx	eax,word ptr [esi+2]
	mov	ButtonX1,eax
	movzx	eax,word ptr [esi+4]
	mov	ButtonY1,eax
	movzx	eax,word ptr [esi+6]
	mov	ButtonX2,eax
	movzx	eax,word ptr [esi+8]
	mov	ButtonY2,eax
	movzx	ebx,word ptr [esi+10]
	xor	bl,1
	movzx	eax,word ptr [PopUpInfo+4]
	shr	eax,3
	mov	SizeX,eax
	call	ButtonUpDownMem2
	popad
	add	esi,12
	ret
BigBorderCode	Endp
SmallBorderCode Proc	Near
	pushad
	mov	eax,TempPictureOff
	mov	ButtonNewOffset,eax
	movzx	eax,word ptr [esi+2]
	mov	ButtonX1,eax
	movzx	eax,word ptr [esi+4]
	mov	ButtonY1,eax
	movzx	eax,word ptr [esi+6]
	mov	ButtonX2,eax
	movzx	eax,word ptr [esi+8]
	mov	ButtonY2,eax
	movzx	ebx,word ptr [esi+10]
	xor	bl,1
	mov	ButtonSetColor,1
	mov	ButtonC1,4
	mov	ButtonC2,3
	movzx	eax,word ptr [PopUpInfo+4]
	shr	eax,3
	mov	SizeX,eax
	call	ButtonUpDownMem
	popad
	add	esi,12
	ret
SmallBorderCode Endp
ButtonCode	Proc	Near
	pushad
	mov	eax,TempPictureOff
	mov	SetAreaOffset,eax
	movzx	eax,word ptr [esi+2]
	inc	eax
	mov	SetX1,eax
	movzx	eax,word ptr [esi+4]
	inc	eax
	mov	SetY1,eax
	movzx	eax,word ptr [esi+6]
	dec	eax
	mov	SetX2,eax
	movzx	eax,word ptr [esi+8]
	dec	eax
	mov	SetY2,eax
	mov	SetColor,6
	movzx	eax,word ptr [PopUpInfo+4]
	shr	eax,3
	mov	PictureX,eax
	call	SetArea

	mov	eax,TempPictureOff
	mov	ButtonNewOffset,eax
	movzx	eax,word ptr [esi+2]
	mov	ButtonX1,eax
	movzx	eax,word ptr [esi+4]
	mov	ButtonY1,eax
	movzx	eax,word ptr [esi+6]
	mov	ButtonX2,eax
	movzx	eax,word ptr [esi+8]
	mov	ButtonY2,eax
	movzx	ebx,word ptr [esi+10]
	xor	bl,1
	movzx	eax,word ptr [PopUpInfo+4]
	shr	eax,3
	mov	SizeX,eax
	call	ButtonUpDownMem
	popad
	add	esi,12
	ret
ButtonCode	Endp
TextCode	Proc	Near
	push	eax ebx ecx edx edi ebp

	mov	edi,TempPictureOff
	movzx	eax,word ptr [esi+4]
	movzx	ebx,word ptr [PopUpInfo+4]
	shr	ebx,1
	mul	ebx
	movzx	ebx,word ptr [esi+2]
	shr	ebx,3
	add	eax,ebx
	add	edi,eax

	mov	ebp,esi
	mov	esi,[pcxoffsets+124]
	movzx	eax,word ptr [ebp+6]
	mov	ebx,13*2*4*80
	mul	ebx
	add	esi,eax
	add	ebp,8

DrawFontLoop:
	movzx	eax,byte ptr [ebp]
	inc	ebp
	cmp	al,'$'
	jz	AfterFontLoop

	push	edi esi
	mov	ebx,80
	xor	edx,edx
	div	ebx
	mov	ecx,edx
	mov	ebx,80*4*13
	mul	ebx
	add	eax,ecx
	add	esi,eax
	mov	ebx,80-1
	movzx	edx,word ptr [PopUpInfo+4]
	shr	edx,3
	dec	edx
	mov	ecx,13*4
MoveCharacter:
	movsb
	add	esi,ebx
	add	edi,edx
	loop	MoveCharacter
	pop	esi edi
	inc	edi
	jmp	DrawFontLoop
AfterFontLoop:
	mov	esi,ebp
	pop	ebp edi edx ecx ebx eax
	ret
TextCode	Endp
;********************************** PUSH PART **********************************
CurrentPlane		dd	0
PopUpPlane1		dd	4	dup(0),-1
PopUpPlane2		dd	4	dup(0),-1
PopUpPlane1Width	dd	0
PopUpPlane2Width	dd	0
PopUpPlane1High 	dd	0
PopUpPlane2High 	dd	0
PopUpPlane1Size 	dd	0
PopUpPlane2Size 	dd	0

LocalX1		dd	0
LocalX2		dd	0
;Calls:  eax=X1
;	 ebx=Y1
;	 ecx=X2
;	 edx=Y2
;Back:	 Cf=if error
PushPart	Proc	Near		;Push Part !!!!!!!!!!!!!!!!!!!!!!!!!!
	pushad
	cmp	CurrentPlane,2
	jz	_retp

	mov	LocalX1,eax
	mov	LocalX2,ecx

	inc	ecx
	shr	eax,3
	shr	ecx,3

	cmp	CurrentPlane,2
	jae	ErrorPusha
	cmp	CurrentPlane,1
	jz	DoPlane2
	mov	[PopUpPlane1],eax
	mov	[PopUpPlane1+1*4],ebx
	mov	[PopUpPlane1+2*4],ecx
	mov	[PopUpPlane1+3*4],edx
	lea	edi,PopUpPlane1
	jmp	AfterPlanes
DoPlane2:
	mov	[PopUpPlane2],eax
	mov	[PopUpPlane2+1*4],ebx
	mov	[PopUpPlane2+2*4],ecx
	mov	[PopUpPlane2+3*4],edx
	lea	edi,PopUpPlane2
AfterPlanes:
	move	esi,0a0000h	;esi offset
	mov	eax,[edi+4]
	mov	ebx,80
	mul	ebx
	mov	ebx,[edi]
	add	eax,ebx
	add	esi,eax

	mov	ecx,CurrentPlane
	shl	ecx,2

	mov	eax,[edi+3*4]	;alloc buffer
	sub	eax,[edi+1*4]
	inc	eax
	mov	[PopUpPlane1High+ecx],eax
	mov	ebx,LocalX2 ;[edi+2*4]
	sub	ebx,LocalX1 ;[edi]
	inc	ebx
	shr	ebx,3

	mov	[PopUpPlane1Width+ecx],ebx
	mul	ebx
	mov	[PopUpPlane1Size+ecx],eax
	xor	ebx,ebx
	mov	ebp,1039
	cmp	CurrentPlane,1
	jz	Nr1039
	mov	ebp,1038
Nr1039:
	shl	eax,2


	cmp	MemErrorStatus,0
	jz	NoMemError1
	call	MemDisalloc
	mov	[AllocTable+ebp*8+4],eax
	mov	eax,Gus_TempBuffPtr
	mov	[AllocTable+ebp*8],eax
	jmp	AfterMemError1
NoMemError1:
	call	MemAlloc
	jc	ErrorPusha

AfterMemError1:

	pushad
	mov	edi,eax
	call	mouseoff
	mov	ebp,CurrentPlane
	shl	ebp,2
	mov	ecx,4
	mov	bl,0
MovePictureLoop:
	push	ecx esi
	PlaneRead bl
	mov	ecx,[PopUpPlane1High+ebp]
MovePicY:
	push	ecx esi
	mov	ecx,[PopUpPlane1Width+ebp]
	rep	movsb
	pop	esi ecx
	add	esi,80
	loop	MovePicY
	inc	bl
	pop	esi ecx
	loop	MovePictureLoop
	call	mouseon
	popad

	inc	CurrentPlane
EndPusha:
	popad
	clc
	ret
ErrorPusha:
	popad
	stc
	ret
PushPart	Endp
;************************************* POP PART ********************************
;calls: none
PopPart 	Proc	Near
	pushad
	cmp	CurrentPlane,0
	jz	EndPopPart
	dec	CurrentPlane

	lea	esi,PopUpPlane2
	cmp	CurrentPlane,1
	jz	Do1039
	lea	esi,PopUpPlane1
Do1039:

	move	edi,0a0000h	;prepare edi
	mov	eax,[esi+4]
	mov	ebx,80
	mul	ebx
	mov	ebx,[esi]
	add	eax,ebx
	add	edi,eax


	mov	ebx,1039*8	;prepare esi
	cmp	CurrentPlane,1
	jz	Do1039_2
	mov	ebx,1038*8
Do1039_2:
	cmp	MemErrorStatus,0
	jz	NoMemError2
	mov	esi,Gus_TempBuffPtr
	jmp	AfterMemError2
NoMemError2:
	mov	esi,[AllocTable+ebx]
AfterMemError2:


	call	mouseoff
	mov	ebp,CurrentPlane
	shl	ebp,2
	mov	ecx,[PopUpPlane1High+ebp]
MoveDataToScreen:
	push	ecx edi esi

	mov	ecx,4
	mov	bl,1
DifferentPlanes:
	push	ecx edi esi
	planewrite bl
	mov	ecx,[PopUpPlane1Width+ebp]
	rep	movsb
	pop	esi edi ecx
	add	esi,[PopUpPlane1Size+ebp]
	shl	bl,1
	loop	DifferentPlanes

	pop	esi edi ecx
	add	esi,[PopUpPlane1Width+ebp]
	add	edi,80
	loop	MoveDataToScreen

	call	mouseon


	mov	ebp,1039
	cmp	CurrentPlane,1
	jz	Do1039_
	mov	ebp,1038
Do1039_:
	xor	eax,eax
	xor	ebx,ebx
	cmp	MemErrorStatus,1
	jz	SkipDealloc
	call	MemAlloc
	jmp	aftersetvar
SkipDealloc:
	mov	[AllocTable+ebp*8],eax
	mov	[AllocTable+ebp*8+4],eax
	mov	MemErrorStatus,0
AfterSetvar:



EndPopPart:
	cmp	CurrentPlane,0	;set peg
	jnz	NoSetPeg2
	mov	UpdateAllPlayPeg,1
	mov	themovepeg,0
	mov	oldpegpos,-1
	call	MoveThePegs
	mov	UpdateAllPlayPeg,0
NoSetPeg2:
	popad
	ret
PopPart 	Endp




;/ABS\01631015880158801588015880158801588015880158801588
