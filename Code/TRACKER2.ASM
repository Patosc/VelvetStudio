;/ACS\=s

;/ABS\03167006600000400004000040000402131020730215203328

OldisVoluminaris	db	32 dup(0)	;Ä¿DONT MOVE!!!! (procs, noprintti2)
UpdateVolumeValues	Proc	Near		;ÄÙDONT MOVE!!!!
	cmp	DisplayVolume,0
	jz	_Ret
	cmp	Menu_DownScreen,3		;Check
	ja	_Ret

	mov	MouseX1,39
	mov	MouseY1,243
	mov	MouseX2,63
	mov	MouseY2,255

	pushad
	movzx	ecx,Channels
	cmp	ecx,6
	jbe	Junta
	mov	ecx,6
Junta:
	cmp	Zoom,1
	jnz	NoZooom
	mov	ecx,1
NoZooom:
	move	edi,0a0000h+244*80+40/8
	movzx	ebp,CurrentChannel
Gunna:
	push	ecx ebp
	movzx	ebp,byte ptr [ChanPos+ebp]

	movzx	ebx,[Volume+ebp]
	movzx	eax,[ChannelMaster+ebp]
	mul	ebx
	mov	ebx,127
	div	ebx
	mov	ebx,eax
	cmp	bl,[OldisVoluminaris+ebp]
	jz	NoKisse
	mov	[OldisVoluminaris+ebp],bl
	call	MouseOff
	mov	ah,08h

	cmp	VolumeHexDec,1
	jz	Hexa
	mov	cl,3
	call	PutDecimal
	jmp	Knapp
Hexa:
	mov	cl,2
	call	Puthex
Knapp:
	call	MouseOn
NoKisse:
	add	edi,12
	pop	ebp ecx
	inc	ebp
	add	MouseX1,96
	add	MouseX2,96
	loop	Gunna
	call	MouseReset
	popad
	ret
UpdateVolumeValues	EndP


WaitMousePress2:
	call	sync
	in	al,60h
	and	al,80h
	jz	_ret
	call	MouseStat
	cmp	MouseB,0
	jz	WaitMousePress2
	ret

WaitMousePress:
	call	sync
	call	MouseStat
	cmp	MouseB,2
	jnz	WaitMousePress
WaitMousePressG:
	call	sync
	call	MouseStat
	cmp	MouseB,2
	jz	WaitMousePressG
	ret

Waitkey:
	pushad
	pushfd
gh:
	in	al,60h
	cmp	al,57
	jnz	gh
fh:
	in	al,60h
	cmp	al,57
	jz	fh
	popfd
	popad
	ret



;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Load Pcx Files
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

PicturesFileName	db	'TrackPic.pro',0
CurrentPath		db	64+13 dup(0)
CurrentTrackerName	db	13 dup(0),'$'

PcxSize 		dd   25129	;Patterndata v1 		; 0    1
			dd    4963	;Sample editor			; 4    2
			dd    7701	;Main buttons (e.g play)	; 8    3
			dd     408	;Top bar			;12    4
			dd    3153	;Position and arrows		;16    5
			dd    5734	;Sample, panpot m.m (and arrows);20    6
			dd   11176	;Disk op.			;24    7
			dd    4155	;Song Init (Spd/BPM/freq)	;28    8
			dd    5367	;Position Editor		;32    9
			dd    4612      ;Pitchtable			;36   10
			dd     275	;arr left			;40   11
			dd     276	;arr right			;44   12
			dd   16384      ;Sinetable			;48   13
			dd     703	;Plus, minus i effekt		;52   14
			dd     968	;loop on m.m. i effekt		;56   15
			dd    7495	;Equalizer			;60   16
			dd     486	;-				;64   17
			dd   11858	;description			;68   18
			dd   18435	;Zoomed PT pattern		;72   19
			dd     884	;-				;76   20
			dd	 0      ;-				;80   21
			dd	 0      ;-				;84   22
			dd     297	;Arrow up			;88   23
			dd     297	;Arrow down			;92   24
			dd    3439	;Song name etc. 		;96   25
			dd    5793	;Sample names			;100  26
			dd   17556	;Edit or effects or fourier	;104  27
			dd	 0      ;-				;108  28
			dd    1990	;ScreamTracker edit board	;112  29
			dd    1781	;ScreamTracker Zoom edit board	;116  30
			dd	 0      ;-				;120  31
			dd   16640      ;Font 2 			;124  32
			dd    5715	;CD-ROM 			;128  33
			dd     441	;Arrows 			;132  34
			dd	 0     	;-				;136  Efter 34
			dd	 0     	;-				;140
			dd   28310	;Envelope Editor		;144  35
			dd    5067	;PatternInfo			;148  36
			dd     510	;Vib waveform			;152  37
			dd     607	;Empty waveform 		;156  38
			dd	 0      ;-				;160  39
			dd    2823	;Piano				;164  40
			dd	-1

PcxOffsets		dd	0	;Pattern data v1
			dd	0	;Sample editor
			dd	0	;Main buttons (ex. play)
			dd	0	;Top bar
			dd	0	;Position and arrows
			dd	0	;Sample, panpot etc. (and arrows)
			dd	0	;Disk op.
			dd	0	;Big Pop up
			dd	0	;Pattern editor
			dd	0	;-
			dd	0	;Arr Left
			dd	0	;Arr Right
			dd	0	;-
			dd	0	;-
			dd	0	;-
			dd	0	;-
			dd	0	;-
			dd	0	;Desc
			dd	0	;PT Zoomed
			dd	0	;-
			dd	0	;-
			dd	0	;-
			dd	0	;Arrow up
			dd	0	;Arrow down
			dd	0	;Song name etc.
			dd	0	;Sample names
			dd	0	;Edit or effects or fourier
			dd	0	;Edit board (samp. ed.)
			dd	0	;ScreamTracker
			dd	0	;ScreamTracker Zoom
			dd	0	;-
			dd	0	;Font 2
			dd	0	;CD-ROM
			dd	0	;Arrows
			dd	0	;-
			dd	0	;-
			dd	0	;Env. Editor
			dd	0	;Pattern Info
			dd	0	;Vib Waveform
			dd	0	;Empty Waveform
			dd	0	;-
			dd	0	;Piano

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Menu Handler
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: MenuChanges
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

CurrentMenu		dw	5 dup(0)
Menu_Popup		dw	0
Menu_Popup_ptr		dd	0		;0 = No popup
			dd	ViewPop1	;Okay			1  *
			dd	ViewPop2	;Yes-No 		2  *
			dd	ViewPop3	;Yes,No,All,Cancel	3  *
			dd	ViewPop4	;Rename,Skip,Cancel	4  *
			dd	ViewInfoShit	;View some crap 	5  *
			dd	ClearPopsi	;Clear popup		6  *
			dd	_ret		;Pull down menu 	7  -
			dd	ViewKeys	;Config Keys		8  *
			dd	SplitPopup	;Split Keyboard 	9  *
			dd	ViewColors	;Config Colors		10 -
			dd	ViewOptiones	;Options		11 *
			dd	ViewPopuptext	;Text screen		12 *
			dd	ViewTheSample	;Sample popup		13 *
			dd	Viewstartsamp	;Start to samp		14 *
			dd	InfoPopup	;Show some info 	15 *
			dd	ViewPop16	;Okay (down)		16 -
			dd	ViewPop17	;Yes-No (Down)		17 -
			dd	ViewVolume	;Volume 		18 *
			dd	ViewMix 	;mixa			19 *
			dd	Viewpop20	;Yes-No-Cancel		20 -
			dd	Viewyfix	;yfix			21 *
			dd	ViewOptimPopup	;Optimize		22 *
			dd	_ret		;NewPulldown		23 -
			dd	ViewOptimSaved	;Opimize results	24 *
			dd	ViewYESNO	;Yes-No (UP left)	25 *
			dd	ViewNewVol	;New volume		26
			dd	ViewMark	;Mark			27
			dd	ViewSoundCardPopup ;Config		28
			dd	ViewEffects	;Effects		29
			dd	0		;			30
			dd	ViewEchoEditor	;Echo			31
			dd	ViewHelpPopup	;Help			32
			dd	ViewPattDefPopup;Pattern Defaults	33
			dd	ViewResample	;Resample		34
			dd	ViewEffectWait	;Effect wait		35
			dd	ViewConfigPaths ;Config Paths		36

			dd	ViewPop21	;Yes-No (effect popup)	37

			dd	ViewNewMulti	;New Multi (rename)	38
			dd	0		;Effect edit (env)	39
			dd	ViewPop22	;Yes-No-Cancel (effect) 40
			dd	0		;Effect edit (Time)	41
			dd	ViewEQEdit	;Equalizer editor	42

Menu_DownScreen 	dw	0
Menu_DownScreen_Ptr	dd	ViewPatternV1	;0 = PT Pattern
			dd	ViewPatternV3	;1 = ST Pattern
			dd	ViewPatternV2	;2 = Zoomed PT Pattern
			dd	ViewPatternV4	;3 = Zoomed ST Pattern
			dd	ViewSampEdit	;4 = Sample editor (Main)
			dd	0		;5 = Sample editor (Effects)
			dd	ViewDescEdit	;6 = Description editor
			dd	ViewEnvEdit	;7 = Envelope editor

Menu_UpperScreen	dw	0
Menu_UpperScreen_Ptr	dd	ViewMainSamp	;0 = MainButtons (Samples)
			dd	0		;1 = MainButtons (Equalizer 1)
			dd	0		;2 = MainButtons (Equalizer 2)
			dd	ViewDiskOp	;3 = Disc options

PianoScreen		dd	0		;0 = Songname m.m.
						;1 = Piano
						;2 = Equalizers
SampnameScreen		dd	0		;0 = Sampnames


Menu_UpperLeft		dw	2
Menu_UpperLeft_Ptr	dd	Viewsampinfo	;0 = Sample information
			dd	ViewPositionEd	;1 = Position ed.
			dd	Viewpattinfo	;2 = Pattern information
			dd	ViewSongCfg	;3 = Song Config

Menu_SampNames		dd	0	;0 = Samp names


check			db	0

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Set Area
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;	 PictureX = The x
;	    SetX1 = x1
;	    SetY1 = y1
;	    SetX2 = x2
;	    SetY2 = y2
;	 SetColor = Color
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PictureX	dd	0
SetX1		dd	0
SetY1		dd	0
SetX2		dd	0
SetY2		dd	0
SetColor	dd	0
SetBits 	dd	0
DumpSpecial1	db	0
SetAreaOffset	dd	0
SetArea 	Proc	Near
	Pushad

	mov	edi,pcxbuffer
	cmp	SetAreaOffset,0
	jz	nosetareas
	mov	edi,SetAreaOffset
nosetareas:
	mov	SetAreaOffset,0

	mov	eax,pictureX
	mov	ebx,Sety1
	mul	ebx
	shl	eax,2
	add	edi,eax

	mov	eax,SetX1
	shr	eax,5
	shl	eax,2
	add	edi,eax

	mov	ecx,sety2
	sub	ecx,sety1
	inc	ecx
Filllinebigloop:
	push	ecx

	mov	buttonplane,1
	mov	ecx,4
Filllineloop2GG:
	push	ecx
	push	edi

	mov	ebx,buttonplane
	mov	ecx,setcolor
	and	ebx,ecx
	mov	setbits,0
	cmp	ebx,0
	jna	dontset
	mov	setbits,1
dontset:

	mov	ebp,setx2
	sub	ebp,setx1
	inc	ebp
	mov	eax,setx1
	mov	buttonstartsave,eax
Filllineloop1GG:

	mov	ecx,buttonstartsave
	and	ecx,31
	mov	eax,0ffffffffh
	shr	eax,cl

	mov	ebx,ebp
	add	ebx,ecx
	cmp	ebx,32
	ja	morefillnowGG

	mov	ecx,32
	sub	ecx,ebx
	mov	ebx,0ffffffffh
	shl	ebx,cl
	and	eax,ebx
	ror	ax,8
	ror	eax,16
	ror	ax,8
	xor	eax,0ffffffffh
	and	[edi],eax

	cmp	setbits,0
	jz	skipor1
	xor	eax,0ffffffffh
	or	[edi],eax
skipor1:
	jmp	endfillloop1GG

morefillnowGG:
	ror	ax,8
	ror	eax,16
	ror	ax,8
	xor	eax,0ffffffffh
	and	[edi],eax
	cmp	setbits,0
	jz	skipor2
	xor	eax,0ffffffffh
	or	[edi],eax
skipor2:

	mov	eax,32
	sub	eax,ecx
	sub	ebp,eax
	add	buttonstartsave,eax
	add	edi,4
	jmp	filllineloop1GG
endfillloop1GG:

	shl	buttonplane,1
	pop	edi
	add	edi,pictureX
	pop	ecx
	loop	filllineloop2GG

	pop	ecx
	loop	filllinebigloop

	Popad
	Ret
SetArea 	EndP


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Menu piano
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MenuPiano		proc	near
	pushad
	cmp	menu_upperscreen,0
	jnz	_retp
	cmp	menu_popup,0
	jnz	_retp

	cmp	pianoscreen,1
	jz	thepiano2
	cmp	pianoscreen,2
	jz	TheEQ2
	mov	eax,[PcxOffsets+96]
	mov	pcxx,156
	mov	pcxy,185
	call	ShowThePcx
	call	PrintModName
	call	PrintComposer
	jmp	_retp
thepiano2:
	mov	eax,[PcxOffsets+164]
	mov	pcxx,156
	mov	pcxy,185
	call	ShowThePcx
	call	UpdateHiLo
	call	PrintPianoSplit
	jmp	_retp
TheEQ2:
	mov	eax,[PcxOffsets+60]
	mov	pcxx,156
	mov	pcxy,185
	call	ShowThePcx
	popad
	ret
MenuPiano		endp

SetHi:
	mov	HiLoOctave,1
	jmp	SetCont
SetLo:
	mov	HiLoOctave,0
SetCont:
	mov	eax,[PcxOffsets+164]
	mov	pcxx,156
	mov	pcxy,185
;	mov	fixproblem,1
	call	ShowThePcx
	call	UpdateHilo
	call	PrintPianoSplit
	ret

UpdateHiLo	Proc	Near
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,158
	mov	ButtonY1,187
	mov	ButtonX2,180
	mov	ButtonY2,203
	mov	bl,HiLoOctave
	xor	bl,1
	call	ButtonUpDown

	mov	ButtonY1,204
	mov	ButtonY2,220
	mov	bl,HiLoOctave
	call	ButtonUpDown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	ret
UpdateHiLo	EndP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Menu Viewers
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

ViewPop4:
	pushad
	lea	esi,Pop4Picture
	call	DrawPopUp

	push	esi
	mov	FontPlane,1
	mov	ah,1
	mov	cl,12
	move	edi,0a0000h+(112*80)+336/8
	lea	esi,RenFileName
	call	printtext
	mov	FontPlane,0
	pop	esi

	popad
	ret


ViewNewVol:
	pushad
	lea	esi,NewVolPicture
	call	DrawPopUp
	popad
	ret
ViewMark:
	pushad
	lea	esi,MarkPicture
	call	DrawPopUp
	popad
	ret
ViewEffects:
	pushad
	lea	esi,EffectChoosePicture
	call	DrawPopUp
	popad
	ret
ViewResample:
	pushad
	lea	esi,ResamplePicture
	call	DrawPopUp
	popad
	ret
ViewEffectWait:
	pushad
	lea	esi,WaitEffectPicture
	call	DrawPopUp
	popad
	ret

ViewPop16:
	pushad
	lea	esi,Pop16Picture
	call	DrawPopUp
	popad
	ret
ViewPop17:
	pushad
	lea	esi,Pop17Picture
	call	DrawPopUp
	popad
	ret
ViewPop21:
	pushad
	lea	esi,Pop21Picture
	call	DrawPopUp
	popad
	ret
ViewPop22:
	pushad
	lea	esi,Pop22Picture
	call	DrawPopUp
	popad
	ret

ViewNewMulti:
	pushad
	lea	esi,EffectNewMultiPicture
	call	DrawPopUp
	popad
	ret

ViewVolume:
	pushad
	lea	esi,OldVolumePicture
	call	DrawPopUp
	mov	FontPlane,1
	mov	ah,1
	mov	ebx,'%'
	move	edi,0a0000h+45+40*80
	call	putcharacter
	mov	ebx,'%'
	move	edi,0a0000h+45+61*80
	call	putcharacter
	mov	FontPlane,0
	popad
	ret
ViewPop20:
	pushad
	lea	esi,Pop20Picture
	call	DrawPopUp
	popad
	ret

ViewYESNO:
	pushad
	lea	esi,YesNoUpLeftPicture
	call	DrawPopUp
	popad
	ret


ViewMix:
	pushad
	lea	esi,MixPicture
	call	DrawPopUp
	mov	ah,1
	mov	ebx,'%'
	mov	FontPlane,1
	move	edi,0a0000h+31+274*80
	call	putcharacter
	mov	ebx,'%'
	move	edi,0a0000h+31+298*80
	call	putcharacter
	mov	FontPlane,0
	popad
	ret
ViewBreak:
	pushad
	call	SavePopup1
	mov	eax,[PcxOffsets+48]
	mov	pcxx,169-64
	mov	pcxy,92+168
	call	ShowThePcx
	mov	eax,[PcxOffsets+132]	 ;put arrows
	mov	pcxx,260
	mov	pcxy,295-11
	call	ShowThePcx
	mov	ah,1
	mov	ebx,'%'
	move	edi,0a0000h+31+(298-11)*80
	call	mouseoff
	call	putcharacter
	call	mouseon
	popad
	ret
Viewyfix:
	pushad
	lea	esi,YFixPicture
	call	DrawPopUp
	popad
	ret
ViewKeys:
	pushad
	lea	esi,KeysPicture
	call	DrawPopUp
	popad
	ret
NotRegisterMessName	db	"Lousy hacker, try to crack me!          "

Unreg	db	'UNREGISTERED VERSION.         '
InfoPopup:
	pushad

	lea	esi,InfoPictureGUS
	cmp	SoundCard,1
	jz	@@Gus
	cmp	SoundCard,5
	jz	@@Gus
	cmp	SoundCard,6
	jz	@@Gus
	lea	esi,InfoPicture
@@Gus:
	call	DrawPopUp
	call	mouseoff
	mov	FontPlane,1

	mov	ah,8
	cmp	SoundCard,5
	jz	@@Gus2
	cmp	SoundCard,6
	jz	@@Gus2
	cmp	SoundCard,1
	jnz	@@NoGus2
@@GUS2:
	move	edi,0a0000h+5*13*80+32
	mov	cl,8
	mov	ebx,GUS_DramSize2
	call	PutDecimal

	move	edi,0a0000h+6*13*80+32
	mov	cl,8
	mov	ebx,GUS_DramFree
	call	PutDecimal

	move	edi,0a0000h+7*13*80+32
	mov	cl,8
	mov	ebx,GUS_DramSize2
	sub	ebx,GUS_DramFree
	call	PutDecimal
@@NoGUS2:

	move	edi,0a0000h+9*13*80+32
	mov	cl,9
	mov	ebx,TotalXMS
	call	PutDecimal

	move	edi,0a0000h+10*13*80+32
	mov	cl,9
	mov	ebx,MemoryFree
	call	PutDecimal

	move	edi,0a0000h+11*13*80+32
	mov	cl,9
	mov	ebx,TotalXMS
	sub	ebx,MemoryFree
	call	PutDecimal

	move	edi,0a0000h+4*13*80+32
	cmp	SoundCard,1
	jz	PrintGUSVersions
	cmp	SoundCard,5
	jz	PrintGUSVersions
	cmp	SoundCard,6
	jz	PrintPNPVersions
	cmp	SoundCard,2
	jz	PrintSBPro
	cmp	SoundCard,3
	jz	PrintSB16
	cmp	SoundCard,4
	jz	PrintSB
	mov	cl,7
	lea	esi,NOS_Version1
	jmp	ThatsTheVersion

PrintSBPro:
	mov	cl,17
	lea	esi,SBP_Version1
	cmp	SoundCardSub,0
	jz	PrintDSPVersion
	mov	cl,22
	lea	esi,SBP_Version2
	jmp	PrintDSPVersion

PrintSB16:
	mov	cl,16
	lea	esi,SB16_Version1
	jmp	PrintDSPVersion

PrintSB:
	mov	cl,16
	lea	esi,SB_Version1
	cmp	SoundCardSub,1
	jz	PrintDSPVersion
	lea	esi,SB_Version2
	jmp	PrintDSPVersion

PrintDSPVersion:
	push	ecx edi esi
	and	ecx,0ffh
	add	edi,ecx
	inc	edi
	mov	cl,9
	lea	esi,SBDSP_Version
	call	PrintText

	add	edi,4
	movzx	ebx,byte ptr [DSPVersion+1]
	mov	cl,2
	call	PutDecimal

	add	edi,3
	movzx	ebx,byte ptr [DSPVersion]
	call	PutDecimal
	pop	esi edi ecx
	jmp	ThatsTheVersion

PrintPNPVersions:
	mov	cl,30
	lea	esi,PNP_Version
	jmp	ThatsTheVersion

PrintGUSVersions:
	mov	cl,30
	lea	esi,GUS_Version1
	cmp	SoundCardSub,255
	jz	ThatsTheVersion
	mov	cl,38
	lea	esi,GUS_Version2
	cmp	SoundCardSub,5
	jz	ThatsTheVersion
	mov	cl,33
	lea	esi,GUS_Version3
	cmp	SoundCardSub,10
	jb	ThatsTheVersion
	mov	cl,24
	lea	esi,GUS_Version4
ThatsTheVersion:
	call	PrintText
	mov	FontPlane,0

	call	mouseon
	popad
	ret

ViewTheSample:
	pushad
	lea	esi,SamplePicture
	call	DrawPopUp
	popad
	ret

ViewStartSamp:
	pushad
	lea	esi,StartSamplePicture
	call	DrawPopUp
	popad
	ret

ViewColors:
	pushad
	lea	esi,ColorsPicture
	call	DrawPopUp
	popad
	ret
viewoptiones:
	pushad
	lea	esi,ConfigOptionsPicture
	call	DrawPopUp
	popad
	ret

ViewOverViewEQ:
	pushad
	popad
	ret




skipput db	0
sampchooseFX	    dw	    3,66,28,98,0
		    dw	    -1
sampchooseED	    dw	    3,33,28,65,0
		    dw	    -1
skiptopsamp	    db	    0
makesamplechooseFX:
	pushad
	mov	sizex,80
	lea	esi,sampchooseFX
	call	setbuttonmore
	popad
	ret
makesamplechooseED:
	pushad
	mov	sizex,80
	lea	esi,sampchooseED
	call	setbuttonmore
	popad
	ret


ViewSampEdit:
	pushad

	mov	al,CurrentChannel
	mov	CurrentChannelSave,al

	cmp	sampform,1
	jz	sampform1

sampform0:
	;cmp	 skiptopsamp,1
	;jz	 skipptop1
	mov	eax,[PcxOffsets+4]
	mov	pcxx,0
	mov	pcxy,223
	mov	fastpic,1
	mov	choosemake,6
	call	ShowThePcx
skipptop1:
	mov	skiptopsamp,0
	mov	eax,[PcxOffsets+104]
	mov	pcxx,0
	mov	pcxy,372
	mov	fastpic,1
	call	ShowThePcx
	popad
	ret
sampform1:
	mov	menu_downscreen,5
	mov	[CurrentMenu+2],5
	;cmp	 skiptopsamp,1
	;jz	 skipptop2
	mov	eax,[PcxOffsets+4]
	mov	pcxx,0
	mov	pcxy,223
	mov	fastpic,1
	mov	choosemake,5
	call	ShowThePcx
skipptop2:
	mov	eax,[PcxOffsets+108]
	mov	pcxx,0
	mov	pcxy,372
	mov	fastpic,1
	call	ShowThePcx

	mov	skiptopsamp,0
	popad
	ret

Viewmainsamp:
	pushad
	call	mouseoff
	mov	eax,[PcxOffsets+8]
	mov	pcxx,156
	mov	pcxy,17
;	mov	fixproblem,1
	call	ShowThePcx
	call	RowAdd2

	cmp	Menu_sampnames,0
	jnz	notthat1
	mov	eax,[PcxOffsets+100]
	mov	pcxx,336
	mov	pcxy,17
	mov	fastpic,1
	call	ShowThePcx
notthat1:


;	cmp	pianoscreen,1
;	jz	thepiano
;	mov	eax,[PcxOffsets+96]
;	mov	pcxx,156
;	mov	pcxy,185
;	call	ShowThePcx
;	jmp	afterpiano
;thepiano:
;	mov	eax,[PcxOffsets+164]
;	mov	pcxx,156
;	mov	pcxy,185
;	call	ShowThePcx
;	call	UpdateHiLo
;	call	PrintPianoSplit
;afterpiano:
	call	MenuPiano
	call	PrintModName
	call	PrintComposer
	mov	OldCurrentInstName,-1
;	mov	oldpos,-1
;	mov	oldbpm,-1
;	mov	oldpatt,-1
;	mov	oldlen,-1
	mov	OldTime_Hour,-5
	mov	OldTime_Min,-1
	mov	OldTime_Sec,-1
;	mov	OldPatt,-1
;	mov	OldPatt2,-1
;	mov	OldPattName,-1
	mov	OldMasterVolume,-1
	mov	OldInfoTextPtr,-1
	cmp	PrintBlock,0
	jz	Knapper
	mov	ah,8
	mov	cl,15
	move	edi,0a0000h+170*80+160/8
	lea	esi,MarkText
	call	PrintText
Knapper:
	call	mouseon
	popad
	ret

FillScreen:
	move	edi,0a0000h
	mov	dx,3c4h 	;Write mask register
	mov	ax,0f02h
	out	dx,ax
	xor	eax,eax
	mov	ecx,80*400/4
	rep	stosd
	ret

PrintShit     Proc    Near
	Pushad
	lea	esi,AllocTable+1024*8
	mov	ecx,20
	move	edi,0a0000h+80*223
kaks:
	push	ecx
	lodsd
	mov	ebx,eax
	mov	ah,0fh
	mov	cl,10
	call	PutDecimal
	add	edi,11
	lodsd
	mov	ebx,eax
	mov	ah,0fh
	mov	cl,10
	call	PutDecimal
	add	edi,80-11+12*80
	pop	ecx
	loop	kaks

	lea	esi,FreeTable
	mov	ecx,20
	move	edi,0a0000h+80*223+24
laks:
	push	ecx
	lodsd
	mov	ebx,eax
	mov	ah,0fh
	mov	cl,10
	call	PutDecimal
	add	edi,11
	lodsd
	mov	ebx,eax
	mov	ah,0fh
	mov	cl,10
	call	PutDecimal
	add	edi,80-11+12*80
	pop	ecx
	loop	laks

	lea	esi,GUS_FreeTable
	mov	ecx,10
	move	edi,0a0000h+80*223+48
paks:
	push	ecx
	lodsd
	mov	ebx,eax
	mov	ah,0fh
	mov	cl,10
	call	PutDecimal
	add	edi,11
	lodsd
	mov	ebx,eax
	mov	ah,0fh
	mov	cl,10
	call	PutDecimal
	add	edi,80-11+12*80
	pop	ecx
	loop	paks


	Popad
	Ret
PrintShit  EndP

HiMemErrVar	dw	0
TrackerMemoryInit	Proc	Near
	mov	HiMemErrVar,ax
	mov	eax,HiMemPtr		;Allocate ViewBuffert
	mov	ViewBuffer,eax
	mov	eax,10000
	add	HiMemPtr,eax
	mov	ebx,HiMemPtr
	cmp	HiMemEnd,ebx
	jb	HighMemError

	mov	eax,HiMemPtr		;Allocate Temporary Channel (EditFunc)
	mov	TempChannel,eax
	mov	eax,8*2*256+2
	add	HiMemPtr,eax
	mov	ebx,HiMemPtr
	cmp	HiMemEnd,ebx
	jb	HighMemError

	mov	edi,TempChannel 	;Clear Temp Stuff
	mov	ecx,eax
	xor	al,al
	rep	stosb

	mov	eax,HiMemPtr		;Allocate Temporary Command (EditFunc)
	mov	TempCommand,eax
	mov	eax,7*2*256+2
	add	HiMemPtr,eax
	mov	ebx,HiMemPtr
	cmp	HiMemEnd,ebx
	jb	HighMemError

	mov	edi,TempCommand 	;Clear Temp Stuff
	mov	ecx,eax
	xor	al,al
	rep	stosb

;	 mov	 eax,HiMemPtr		 ;Allocate Temporary BlockBuff
;	 mov	 TempBlock,eax
;	 mov	 eax,8*2*256+2
;	 add	 HiMemPtr,eax
;	 mov	 ebx,HiMemPtr
;	 cmp	 HiMemEnd,ebx
;	 jb	 HighMemError

;	 mov	 edi,TempBlock		 ;Clear Temp Stuff
;	 mov	 ecx,eax
;	 xor	 al,al
;	 rep	 stosb

	mov	eax,HiMemPtr		;Allocate User def Env
	mov	UserDefEnv,eax
	mov	eax,2424
	add	HiMemPtr,eax
	mov	ebx,HiMemPtr
	cmp	HiMemEnd,ebx
	jb	HighMemError

	mov	edi,UserDefEnv		;Clear Stuff
	mov	ecx,eax
	xor	al,al
	rep	stosb

	ret
HighMemError:
	sub	HiMemPtr,eax
	mov	ax,HiMemErrVar
	jmp	ErrorHandler
LowMemError:
;	sub	LowMemPtr,eax
	mov	ax,LowMemFatalErr
	jmp	ErrorHandler
TrackerMemoryInit	EndP

AllocateInitialBuffers	Proc	Near
	pushad

	movzx	ebx,MaxFiles
	mov	eax,49
	mul	ebx
	mov	FileListMarkPtr,eax
	add	eax,ebx
	mov	ebp,1031
	mov	ebx,1
	call	MemAlloc
	mov	FileListPtr,eax
	add	FileListMarkPtr,eax
	popad				;Special stuff...

AllocateInitialBuffers2:
	pushad
	mov	al,DefaultChannels
	mov	Channels,al
	mov	al,DefaultCommands
	mov	Commands,al
	movzx	eax,DefaultRows
	mov	CurrPattLength,eax
	mov	CurrentSampName,16

	call	AllocateEmptyPattern	;Allocate Empty Pattern

	mov	eax,30
	mov	ebp,1029		;Allocate Inst. names
	mov	ebx,1
	call	MemAlloc
	mov	InstNamesPtr,eax

	mov	eax,22*16
	mov	ebp,1028		;Allocate Samp. names
	mov	ebx,1
	call	MemAlloc
	mov	SampleNamesPtr,eax

	mov	eax,716
	mov	ebp,1034		;Allocate Inst. Info
	mov	ebx,1
	call	MemAlloc
	mov	InstrumentInfo,eax

	call	SetInitialEnvelopes

	mov	eax,2
	mov	ebp,1030		;Allocate Positions
	mov	ebx,1
	call	MemAlloc
	mov	PatternOrderPtr,eax

	mov	eax,74
	mov	ebp,1027		;Allocate Desc
	mov	ebx,1
	call	MemAlloc
	mov	[DescTable+11*4],eax	;Ptr
	mov	[DescTable+12*4],74	;Len

	popad
	ret
AllocateInitialBuffers	EndP


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls:
;	EAX = Channel to Contract
;	EDX = Rows to Contract
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ContractChannel Proc	Near
	pushad
	cmp	RowAdder,0
	jz	SkipRest
	mov	FileEdited,1
	movzx	eax,byte ptr [ChanPos+eax]
	push	eax edx
	mov	edi,GUS_TempBuffPtr
	mov	ecx,RowSize
	shl	ecx,7
	xor	al,al
	rep	stosb
	pop	edx eax
	movzx	ebp,CurrRow
	mov	esi,ebp
	add	esi,edx
	cmp	esi,CurrPattLength
	jb	ContractNext
	mov	esi,CurrPattLength
	dec	esi
ContractNext:
	mov	ecx,ebp
	inc	ecx
	mov	ebx,GUS_TempBuffPtr
	call	Cut_Channel
	add	ebx,512
	call	Cut_Command
	dec	ecx
	mov	ebx,GUS_TempBuffPtr
	call	Paste_Channel
	add	ebx,512
	call	Paste_Command
	mov	ecx,ebp
	add	cl,RowAdder
	mov	ebp,ecx
	mov	ecx,CurrPattLength
	dec	ecx
	cmp	ebp,ecx
	jae	SkipRest
	cmp	ebp,esi
	jae	SkipRest
	jmp	ContractNext
SkipRest:
	popad
	ret
ContractChannel EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls:
;	EAX = Channel to Expand
;	EDX = Rows to Expand
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ExpandChannel Proc    Near
	pushad
	cmp	RowAdder,0
	jz	SkipRest2
	mov	FileEdited,1
	movzx	eax,byte ptr [ChanPos+eax]
	push	eax edx
	mov	edi,GUS_TempBuffPtr
	mov	ecx,RowSize
	shl	ecx,7
	xor	al,al
	rep	stosb
	pop	edx eax
	movzx	ebp,CurrRow
	mov	esi,ebp
	add	esi,edx
	cmp	esi,CurrPattLength
	jb	ExpandNext
	mov	esi,CurrPattLength
	dec	esi
ExpandNext:
	mov	ecx,ebp
	inc	ecx
	mov	ebx,GUS_TempBuffPtr
	call	Cut_Channel
	add	ebx,512
	call	Cut_Command
	add	cl,RowAdder
	cmp	ecx,CurrPattLength
	jae	SkipRest2
	mov	ebx,GUS_TempBuffPtr
	call	Paste_Channel
	add	ebx,512
	call	Paste_Command
	mov	ebp,ecx
	cmp	ebp,esi
	jae	SkipRest2
	jmp	ExpandNext
SkipRest2:
	popad
	ret
ExpandChannel EndP

testing db	'.$'
Config	Proc	Near
	pushad
	pushf
	mov	StackSave,esp
;	mov	eax,LowMemPtr		 ;Allocate FileBuffer
;	mov	_filebufloc,eax
;	mov	eax,4000h
;	add	LowMemPtr,eax
;	mov	ebx,LowMemEnd
;	cmp	ebx,LowMemPtr
;	jb	LowMemError

	push	esi
	lea	esi,testing
	call	printtext2
	pop	esi

comment %
	mov	eax,LowMemPtr		 ;Allocate DMABuffer
	mov	DMABuffer,eax
	mov	ecx,GUS_RollOverDataSize
	add	eax,_Code32a
	mov	ebx,eax
	add	ebx,0ffffh
	and	ebx,0ffff0000h
	sub	ebx,eax 		;Length to nearest 64K boundary
	cmp	ebx,GUS_RollOverDataSize
	jae	DMABuffFits
	add	DMABuffer,ebx
	add	ecx,ebx
DMABuffFits:
	mov	eax,ecx
	add	LowMemPtr,eax
	mov	ebx,LowMemEnd
	cmp	ebx,LowMemPtr
	jb	LowMemError
%

	push	esi
	lea	esi,testing
	call	printtext2
	pop	esi

	call	Loadpcxfiles

	push	esi
	lea	esi,testing
	call	printtext2
	pop	esi

	mov	ax,HiMemFatalErr
	call	MemoryInit			;Alloc Fixed Modplayer Memory
	jc	ErrorHandler

	push	esi
	lea	esi,testing
	call	printtext2
	pop	esi

	mov	SampLength,1
	mov	ax,HiMemFatalErr
	call	TrackerMemoryInit		;Alloc fixed memory

	push	esi
	lea	esi,testing
	call	printtext2
	pop	esi

	mov	eax,HiMemPtr			;Reset Freetable
	bt	ax,0				;to get even address
	adc	eax,0
	mov	[Freetable],eax
	mov	ebx,HiMemEnd
	sub	ebx,eax
	mov	[Freetable+4],ebx
	mov	MemoryFree,ebx

	push	esi
	lea	esi,testing
	call	printtext2
	pop	esi

	call	ReadConfig

	push	esi
	lea	esi,testing
	call	printtext2
	pop	esi

	call	LoadFonts
;	call	LoadInfoBlock

	push	esi
	lea	esi,testing
	call	printtext2
	pop	esi

	call	CPUpdatePaths

;	mov     MouseB,1
;	call    SetDrivePath2
;	mov     MouseB,0

	push	esi
	lea	esi,testing
	call	printtext2
	pop	esi

;	mov	ecx,255
;	mov	al,8
;GLoop: int	33h
;	loop	GLoop
;	mov	MouseB,0

;	push	esi
;	lea	esi,testing
;	call	printtext2
;	pop	esi

	popf
	popad
	ret
Config	EndP

ConfigTextSave	db	'ConfigFile v1.30',1ah
ConfigText	db	17 dup(0)

ConfigName	db	'VS.CFG',0

SaveTable	dd	ConfigText,17
		dd	CPPathBuffer,67*23
		dd	Composer,30
		dd	MasterVolume,1
		dd	GUS_RollOverDataSize,4
		dd	Menu_UpperLeft,2
		dd	PianoScreen,4
		dd	SoundCard,4
		dd	SoundCard_BasePort,2
		dd	SoundCard_BasePort2,2
		dd	SoundCard_IRQ,1
		dd	SoundCard_MIDIIRQ,1
		dd	SoundCard_DMA1,1
		dd	SoundCard_DMA2,1
		dd	PlayFreq,4
		dd	TimerSelect,1
		dd	SB_StereoAllowed,1
		dd	SB_16BitsAllowed,1
		dd	Amplification,1
		dd	AllowAutoLoad,1
		dd	AutoSave,1
		dd	MaxFiles,2
		dd	PanMax,1
		dd	DefaultChannels,1
		dd	DefaultCommands,1
		dd	DefaultRows,2
		dd	ColorSetupen,4*9
		dd	CurrentWildTBL,4
		dd	COD1,NUMBERSWITCHES
		dd	EchoEd_PreDef1TBL,6
		dd	EchoEd_PreDef2TBL,6
		dd	EchoEd_PreDef3TBL,6
		dd	-2,UserDefEnv,2424	;Hi Mem
		dd	-2,GUS_TempBuffPtr,2100+PlayKeysTBLLen	;Keyboard
		dd	EQShape,28*2
		dd	-1

SaveConfig	Proc	Near
	pushad
	lea	edx,ConfigName
	call	FixPathFile
	lea	edx,NewFileName
	call	_createfile
	mov	ax,CreateErr
	jc	ErrorHandler

	pushad
	call	EncodeKeyMap
	popad

	mov	ecx,[SaveTable+4]
	lea	edi,ConfigText
	lea	esi,ConfigTextSave
	rep	movsb

	lea	esi,SaveTable
SaveNext:
	lodsd
	cmp	eax,-1
	jz	NoMoreToSave
	cmp	eax,-2
	jnz	NoHiMemSave
	lodsd
	mov	eax,[eax]
NoHiMemSave:
	mov	edx,eax
	lodsd
	mov	ecx,eax
	call	_writefile
	mov	ax,WriteErr
	jc	ErrorHandler
	jmp	SaveNext
NoMoreToSave:
	call	_closefile
	mov	ax,CloseErr
	jc	ErrorHandler
	call	MouseHourGlass
	call	stoptimer
	mov	ecx,255
Plopp:	;int	8h
	loop	Plopp
	call	starttimer
	call	mousearrow
	popad
	ret
SaveConfig	EndP


ReadConfig	Proc	Near
	pushad
	lea	edx,ConfigName
	call	FixPathFile
	lea	edx,NewFileName
	call	_openfileR
	jc	SkipReadConfig

	lea	esi,SaveTable			;Config ver check
	lodsd
	mov	edx,eax
	lodsd
	mov	ecx,eax
	call	_readfile
	jc	SkipReadConfig

	mov	eax,-1
GurkanSattITalleGren:
	inc	eax
	mov	bl,[ConfigText+eax]
	cmp	bl,[ConfigTextSave+eax]
	loopz	GurkanSattITalleGren
	jz	ReadNext
	mov	ReqConfigErr,1
	jmp	SkipReadConfig

ReadNext:					;Read
	lodsd
	cmp	eax,-1
	jz	NoMoreToRead
	cmp	eax,-2
	jnz	NoHiMemRead
	lodsd
	mov	eax,[eax]
NoHiMemRead:
	mov	edx,eax
	lodsd
	mov	ecx,eax
	call	_readfile
	jc	SkipReadConfig
	jmp	ReadNext
NoMoreToRead:

	lea	edi,KeyBoardTable		;Fix KeyMap
	mov	esi,GUS_TempBuffPtr
	mov	ecx,2100
	rep	movsb

	mov	edi,GUS_TempBuffPtr
	mov	esi,edi
	add	esi,2100
	mov	ecx,184
	rep	movsb

	call	DecodeKeyMap

SkipReadConfig:
	call	_closefile

	call	FixKeyBoardLayout		;SW or US kbd
	mov	al,TrackerStyle
	mov	TrackerStyle2,al

	popad
	ret
ReadConfig	EndP

NewFileName	db	64+13 dup(0)
;EDX=ptr to filename
FixPathFile	proc	near
	pushad
	lea	edi,NewFileName
	lea	esi,CurrentPath
	mov	ebp,0
	mov	ecx,64
MovePath:
	lodsb
	cmp	al,0
	jz	ExitMove
	stosb
	loop	MovePath
ExitMove:
	cmp	ebp,1
	jz	Qwitall
	mov	ebp,1
	mov	esi,edx
	mov	ecx,13
	jmp	MovePath
Qwitall:
	mov	al,0
	stosb
	popad
	ret
FixPathFile	endp



;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Dump Screen
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DumpDownScreen proc    near
	pushad

	call	mouseoff
	mov	esi,pcxbuffer
	move	ebp,0a0000h
	add	ebp,223*80

	mov	ecx,258
movepicloop:
	push	ecx
	mov	ah,00000001b		;write plane 0
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,0
	mov	al,4
	out	dx,ax
	mov	ecx,20
	mov	edi,ebp
	rep	movsd
	mov	ah,00000010b		;write plane 1
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,1
	mov	al,4
	out	dx,ax
	mov	ecx,20
	mov	edi,ebp
	rep	movsd
	mov	ah,00000100b		;write plane 2
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,2
	mov	al,4
	out	dx,ax
	mov	ecx,20
	mov	edi,ebp
	rep	movsd
	mov	ah,00001000b		;write plane 3
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,3
	mov	al,4
	out	dx,ax
	mov	ecx,20
	mov	edi,ebp
	rep	movsd
	add	ebp,80
	pop	ecx
	loop	movepicloop

	call	mouseon
	popad
	ret
DumpDownScreen	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Save popup1
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Downindicate	db	0
Downpopup	dw	16,17,19,20,21
		dw	-1
SavePopup1     proc    near
	pushad
	call	mouseoff
	move	ebp,0a0000h
	mov	edi,ebp
	add	edi,80*640
	add	ebp,80*92+21
	push	esi
	push	eax
	lea	esi,downpopup
loopchecka:
	lodsw
	cmp	ax,-1
	jz	skippasettaspeciell16_
	cmp	menu_popup,ax
	jnz	loopchecka
	mov	downindicate,1
	move	ebp,0a0000h
	add	ebp,80*260+13
skippasettaspeciell16_:
	pop	eax
	pop	esi

	mov	ecx,63
movepicloop2:
	push	ecx
	mov	ah,00000001b		;write plane 0
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,0
	mov	al,4
	out	dx,ax
	mov	ecx,14
	mov	esi,ebp
	rep	movsd
	mov	ah,00000010b		;write plane 1
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,1
	mov	al,4
	out	dx,ax
	mov	ecx,14
	mov	esi,ebp
	rep	movsd
	mov	ah,00000100b		;write plane 2
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,2
	mov	al,4
	out	dx,ax
	mov	ecx,14
	mov	esi,ebp
	rep	movsd
	mov	ah,00001000b		;write plane 3
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,3
	mov	al,4
	out	dx,ax
	mov	ecx,14
	mov	esi,ebp
	rep	movsd
	add	ebp,80
	pop	ecx
	loop	movepicloop2
	call	mouseon
	popad
	ret
SavePopup1	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Load popup1
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LoadPopup1     proc    near
	pushad

	call	mouseoff
	move	ebp,0a0000h
	mov	esi,ebp
	add	esi,80*640
	add	ebp,80*92+21
	cmp	downindicate,0
	jz	skippasettaspeciell16_2
	mov	downindicate,0
	move	ebp,0a0000h
	add	ebp,80*260+13
skippasettaspeciell16_2:

	mov	ecx,63
movepicloop3:
	push	ecx
	mov	ah,00000001b		;write plane 0
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,0
	mov	al,4
	out	dx,ax
	mov	ecx,14
	mov	edi,ebp
	rep	movsd
	mov	ah,00000010b		;write plane 1
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,1
	mov	al,4
	out	dx,ax
	mov	ecx,14
	mov	edi,ebp
	rep	movsd
	mov	ah,00000100b		;write plane 2
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,2
	mov	al,4
	out	dx,ax
	mov	ecx,14
	mov	edi,ebp
	rep	movsd
	mov	ah,00001000b		;write plane 3
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,3
	mov	al,4
	out	dx,ax
	mov	ecx,14
	mov	edi,ebp
	rep	movsd
	add	ebp,80
	pop	ecx
	loop	movepicloop3
	call	mouseon
	popad
	ret
LoadPopup1	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Save popup2
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
edisava 	dd	0
SavePopup2     proc    near
	pushad
	mov	fastpic,1
	call	mouseoff
	move	ebp,0a0000h
	mov	edi,ebp
	add	edi,80*480
	add	ebp,80*30+8

	mov	ecx,180
movepicloop2__:
	push	ecx
	mov	edisava,edi
	mov	ah,00000001b		;write plane 0
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,0
	mov	al,4
	out	dx,ax
	mov	ecx,15
	mov	esi,ebp
	mov	edi,edisava
	rep	movsd
	movsw
	movsb
	mov	ah,00000010b		;write plane 1
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,1
	mov	al,4
	out	dx,ax
	mov	ecx,15
	mov	esi,ebp
	mov	edi,edisava
	rep	movsd
	movsw
	movsb
	mov	ah,00000100b		;write plane 2
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,2
	mov	al,4
	out	dx,ax
	mov	ecx,15
	mov	esi,ebp
	mov	edi,edisava
	rep	movsd
	movsw
	movsb
	mov	ah,00001000b		;write plane 3
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,3
	mov	al,4
	out	dx,ax
	mov	ecx,15
	mov	esi,ebp
	mov	edi,edisava
	rep	movsd
	movsw
	movsb
	add	ebp,80
	pop	ecx
	loop	movepicloop2__
	call	mouseon
	popad
	ret
SavePopup2	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Load popup2
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LoadPopup2     proc    near
	pushad

	call	mouseoff
	move	ebp,0a0000h
	mov	esi,ebp
	add	esi,80*480
	add	ebp,80*30+8

	mov	ecx,180
movepicloop3__:
	push	ecx
	mov	edisava,esi
	mov	ah,00000001b		;write plane 0
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,0
	mov	al,4
	out	dx,ax
	mov	ecx,15
	mov	edi,ebp
	mov	esi,edisava
	rep	movsd
	movsw
	movsb
	mov	ah,00000010b		;write plane 1
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,1
	mov	al,4
	out	dx,ax
	mov	ecx,15
	mov	edi,ebp
	mov	esi,edisava
	rep	movsd
	movsw
	movsb
	mov	ah,00000100b		;write plane 2
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,2
	mov	al,4
	out	dx,ax
	mov	ecx,15
	mov	edi,ebp
	mov	esi,edisava
	rep	movsd
	movsw
	movsb
	mov	ah,00001000b		;write plane 3
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,3
	mov	al,4
	out	dx,ax
	mov	ecx,15
	mov	edi,ebp
	mov	esi,edisava
	rep	movsd
	movsw
	movsb
	add	ebp,80
	pop	ecx
	loop	movepicloop3__
	call	mouseon
	popad
	ret
LoadPopup2	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Prepare arrows
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
arrowdownbuffer 	dd	60     dup(0)
arrowupbuffer		dd	60     dup(0)
PrepareArrows	proc	near
	pushad
	mov	eax,[PcxOffsets+88]	;unpack arrow up
	mov	skipput,1
	call	ShowThePcx
	mov	esi,pcxbuffer
	lea	edi,arrowupbuffer
	mov	ecx,15*4
arrowuploop:
	xor	eax,eax
	lodsb
	rol	ax,8
	lodsb
	shr	eax,4
	shl	eax,6
	ror	ax,8
	ror	eax,16
	ror	ax,8
	stosd
	loop	arrowuploop

	mov	eax,[PcxOffsets+92]	;unpack arrow down
	mov	skipput,1
	call	ShowThePcx
	mov	esi,pcxbuffer
	lea	edi,arrowdownbuffer
	mov	ecx,15*4
arrowdownloop:
	xor	eax,eax
	lodsb
	rol	ax,8
	lodsb
	shr	eax,4
	shl	eax,6
	ror	ax,8
	ror	eax,16
	ror	ax,8
	stosd
	loop	arrowdownloop
	popad
	ret
PrepareArrows	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Put arrow
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:	ebx = arrow angel (1=up 0=down)
;		edi = offset
;		ebp = width
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PutArrow	proc	near
	pushad

	mov	eax,60*4
	mul	ebx
	lea	esi,arrowdownbuffer
	add	esi,eax

	mov	ecx,15*4
movloop:
	lodsd
	and	dword ptr [edi],00111111000000001111110011111111b
	or	dword ptr [edi],eax
	add	edi,ebp
	loop	movloop

	popad
	ret
PutArrow	endp

; Load EDI with ptr to destination
ReadCommandLine Proc	Near
	pushad
	mov	esi,_pspa
	add	esi,80h

	movzx	ecx,byte ptr [esi]
	jecxz	NoCommandLine
	add	esi,2
;	lea	edi,ModName
CommandLineLoop:
	mov	al,[esi]
	cmp	al,13
	jnz	NoEnd
	mov	byte ptr [edi],0
	jmp	EndCommandLine
NoEnd:
	mov	[edi],al
	inc	edi
	inc	esi
	loop	CommandLineLoop
EndCommandLine:
	clc
	popad
	ret
NoCommandLine:
	stc
	popad
	ret
ReadCommandLine EndP

EQVol		db	32 dup(0)
Ekvalajser	db	8 dup(0)
UpdateEqualizers	Proc	Near
	pushad

	mov	edx,6
	cmp	Zoom,0
	jz	@@Duran
	mov	edx,1
@@Duran:

	mov	ecx,32				;Small Equ's
	xor	esi,esi
GetVolumes:
	movzx	eax,byte ptr [ChanPos+esi]
	cmp	[MIDIChanTable+eax],0
	jnz	UEQ
	cmp	[Mute+eax],1
	jz	NoEq
UEQ:
	mov	bl,[Vol+eax]
	cmp	bl,-1
	jz	NoEQ
	mov	[Vol+eax],-1

	movzx	edi,CurrentChannel
	cmp	esi,edi
	jb	NoEQ1
	add	edi,edx
	cmp	esi,edi
	jae	NoEQ1

	movzx	edi,CurrentChannel
	sub	edi,esi
	neg	edi
	mov	[Ekvalajser+edi],bl
NoEQ1:
	mov	[EQVol+esi],bl
NoEQ:
	inc	esi
	loop	GetVolumes

	popad
	ret
UpdateEqualizers	EndP
FlimmerTable	Label	Word
	dw	31,261,119,351
	dw	127,261,215,351
	dw	223,261,311,351
	dw	319,261,407,351
	dw	415,261,503,351
	dw	511,261,599,351

	dw	31,371,119,461
	dw	127,371,215,461
	dw	223,371,311,461
	dw	319,371,407,461
	dw	415,371,503,461
	dw	511,371,599,461
FixEqualizerFlimmer:			;-------------- FIX EQUALIZER FLIMMER --
;Calls: ebx=eq nr
	pushad
	movzx	eax,EquUpOrdown
	dec	eax
	mov	ecx,48
	mul	ecx
	mov	cx,[Flimmertable+eax+ebx*8]
	mov	mousex1,cx
	mov	cx,[Flimmertable+eax+ebx*8+6]
	movzx	dx,byte ptr [EquHigh+ebx]
	sub	cx,dx
	mov	mousey1,cx
	mov	cx,[Flimmertable+eax+ebx*8+4]
	mov	mousex2,cx
	mov	cx,[Flimmertable+eax+ebx*8+6]
	mov	mousey2,cx
	popad
	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Put equalizer
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;EquSizeX		 db	 2	 ;0=1 digit
					 ;1=3 digits
					 ;2=5 digits
					 ;3=7 digits
					 ;4=9 digits
					 ;5=11 digits
;EquSizeY		 db	 8	 ;0=10 dots
					 ;1=20 dots
					 ;2=30 dots
					 ;3=40 dots
					 ;4=50 dots
					 ;5=60 dots
					 ;6=70 dots
					 ;7=80 dots
					 ;8=90 dots
;EquUporDown		 db	 1	 ;0=None
					 ;1=Up
					 ;2=Down
;EquSpeedUp		 db	 3	 ;0=Immediate
					 ;1=Very fast
					 ;2=Fast
					 ;3=Normal
					 ;4=Slow
					 ;5=Very slow
;EquSpeedDown		 db	 2	 ;0=Very fast
					 ;1=Fast
					 ;2=Normal
					 ;3=Slow
					 ;4=Very slow
					 ;5=None

SizeYtabell		db	10,20,30,40,50,60,70,80,90
SizeXtabell		db	1,3,5,7,9,11
Speeduptabell		db	0,128,96,64,40,20
EqualizerInformation	db	6	dup(0)
EquHigh 		db	6	dup(0)
OldEquHigh		db	6	dup(0)
EqualizerChange 	db	0	;1=A change
SizeXequ		dd	0
speeddown1		db	0,0,0,1,2,0
speeddown2		db	4,2,1,1,1,0
waitbyte		db	0
equcount		dd	0
resetequ	proc	near
	mov	word ptr [ekvalajser],-1
	mov	dword ptr [ekvalajser+2],-1
	mov	word ptr [equalizerinformation],0
	mov	dword ptr [equalizerinformation+2],0
	mov	dword ptr [equhigh],0
	mov	dword ptr [equhigh+4],0
	mov	dword ptr [equhigh]+8,0
	ret
resetequ	endp
removeEQU	db	0


doremove		db	0
SkipEquPopupList	dw	11,8,32,-1
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
PutEqualizer	Proc	Near
	pushad


	mov	eax,eax

	cmp	Menu_popup,0
	jnz	nozerosa
	mov	removeEQU,0
nozerosa:

	lea	esi,SkipEquPopupList
	mov	ax,Menu_popup
	sub	esi,2
Nextus:
	add	esi,2
	cmp	word ptr [esi],-1
	jz	Nooa
	cmp	word ptr [esi],ax
	jnz	Nextus
	mov	doremove,0
	cmp	removeEQU,1
	jz	_retp
	mov	removeEQU,1
	mov	dword ptr [Equhigh],0
	mov	word ptr [Equhigh+4],0
	jmp	DoNow
Nooa:



	cmp	stacksaven,0
	jz	SkipMovaBort
	cmp	TheBarNumber,4
	ja	SkipMovaBort
	cmp	TheBarNumber,1
	jb	SkipMovaBort
	cmp	removeEQU,1
	jz	_retp
	mov	removeEQU,1
	mov	dword ptr [Equhigh],0
	mov	word ptr [Equhigh+4],0
	jmp	DoNow
SkipMovaBort:
	mov	removeEQU,0
DOnow:

	cmp	menu_downscreen,3
	ja	endequ



	lea	eax,equsizeX
	cmp	optionchangeoffset,eax
	jb	aftertheclear
	lea	eax,equspeeddown
	cmp	optionchangeoffset,eax
	ja	aftertheclear
	jmp	clearallequalizer
aftertheclear:
						;move on equalaisers
	cmp	equspeedup,0
	jnz	nosetekva__
	lea	esi,ekvalajser
	lea	edi,equalizerinformation
	mov	ecx,6
moveequloop:
	lodsb
	cmp	al,-1
	jz	jumper
	mov	[edi],al
jumper:
	inc	edi
	loop	moveequloop
	jmp	afterequadd
nosetekva__:					 ;add on equalizers
	movzx	ebx,equspeedup
	movzx	ebp,byte ptr [ebx+speeduptabell]
	lea	esi,ekvalajser
	lea	edi,equalizerinformation
	mov	ecx,6
addonloop:
	movzx	eax,byte ptr [esi]
	cmp	al,-1
	jz	skoja
	mul	ebp
	shr	eax,7
	movzx	ebx,byte ptr [edi]
	add	ebx,eax
	cmp	ebx,128
	jbe	skipmaxa
	mov	ebx,128
skipmaxa:
	mov	byte ptr [edi],bl
skoja:
	inc	edi
	inc	esi
	loop	addonloop
afterequadd:
	mov	word ptr [ekvalajser],-1
	mov	dword ptr [ekvalajser+2],-1

	move	edi,0a0000h
	add	edi,28084
	cmp	equupordown,0			;check if equalizer
	jz	endputequalizer

	cmp	equupordown,1			;move down
	jz	nodownhere
	add	edi,110*80
nodownhere:

	movzx	ebx,equsizeX			;center in x
	movzx	eax,byte ptr [ebx+SizexTabell]
	mov	sizeXequ,eax
	mov	ebx,11
	sub	ebx,eax
	shr	ebx,1
	add	edi,ebx

	cmp	removeEQU,1	;if pulldown puts down
	jz	skippathis_skit
	push	edi
	lea	esi,equalizerinformation	;calculate y high
	lea	edi,equhigh
	movzx	ebx,equsizey
	movzx	ebp,byte ptr [sizeytabell+ebx]
	mov	ecx,6
calcyloop:
	movzx	eax,byte ptr [esi]
	inc	esi
	mul	ebp
	mov	ebx,128
	div	ebx
	stosb
	loop	calcyloop
	pop	edi
skippathis_skit:

	mov	eax,dword ptr [equhigh]
	mov	bx,word ptr [equhigh+4]
	cmp	dword ptr [oldequhigh],eax
	jnz	noquitnow
	cmp	word ptr [oldequhigh+4],bx
	jnz	noquitnow
	jmp	downandquit
noquitnow:

	;call	 mouseoff
	mov	ah,00001000b			;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax

	cmp	equsizex,1
	jz	theequalizer2
	cmp	equsizex,2
	jz	theequalizer3
	cmp	equsizex,3
	jz	theequalizer4
	cmp	equsizex,4
	jz	theequalizer5
	cmp	equsizex,5
	jz	theequalizer6

theequalizer1:			       ;----------- set equalizer 1 ---------
	lea	esi,equhigh
	mov	ecx,6
	cmp	menu_downscreen,1
	jbe	notzoomed1
	mov	ecx,1
notzoomed1:
	mov	equcount,-1
PutEqualizerLoop:
	pushad
	inc	equcount
	call	mouseon
	mov	ebx,equcount
	call	FixEqualizerFlimmer
	call	mouseoff
	mov	ah,00001000b			;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	popad
	push	ecx
	push	edi
;***********************************************************
;***********************************************************
	movzx	ecx,byte ptr [esi]
	mov	edx,ecx
	jecxz	skipsetloop
	mov	eax,-1
settaloop:
	stosb		;Here
	sub	edi,81
	loop	settaloop
skipsetloop:
	movzx	ecx,byte ptr [esi+6]
	sub	ecx,edx
	cmp	ecx,0
	jle	skipclaloop
	xor	eax,eax
claarloop:
	stosb		;Here
	sub	edi,81
	loop	claarloop
skipclaloop:
	pop	edi
	pop	ecx
	add	edi,12
	inc	esi
	loop	putequalizerloop
	jmp	endputequalizer
theequalizer2:			       ;----------- set equalizer 2 ---------
	lea	esi,equhigh
	mov	ecx,6
	cmp	menu_downscreen,1
	jbe	notzoomed2
	mov	ecx,1
notzoomed2:
	mov	equcount,-1
PutEqualizerLoop2:
	pushad
	inc	equcount
	call	mouseon
	mov	ebx,equcount
	call	FixEqualizerFlimmer
	call	mouseoff
	mov	ah,00001000b			;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	popad
	push	ecx
	push	edi
;***********************************************************
;***********************************************************
	movzx	ecx,byte ptr [esi]
	mov	edx,ecx
	jecxz	skipsetloop2
	mov	eax,-1
settaloop2:
	rept 3		;Here
	stosb
	endm
	sub	edi,83
	loop	settaloop2
skipsetloop2:
	movzx	ecx,byte ptr [esi+6]
	sub	ecx,edx
	cmp	ecx,0
	jle	skipclaloop2
	xor	eax,eax
claarloop2:
	rept 3		;Here
	stosb
	endm
	sub	edi,83
	loop	claarloop2
skipclaloop2:
	pop	edi
	pop	ecx
	add	edi,12
	inc	esi
	loop	putequalizerloop2
	jmp	endputequalizer
theequalizer3:			       ;-----------set equalizer 3---------
	lea	esi,equhigh
	mov	ecx,6
	cmp	menu_downscreen,1
	jbe	notzoomed3
	mov	ecx,1
notzoomed3:
	mov	equcount,-1
PutEqualizerLoop3:
	pushad
	inc	equcount
	call	mouseon
	mov	ebx,equcount
	call	FixEqualizerFlimmer
	call	mouseoff
	mov	ah,00001000b			;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	popad

	push	ecx
	push	edi
	movzx	ecx,byte ptr [esi]
	mov	edx,ecx
	jecxz	skipsetloop3
	mov	eax,-1
settaloop3:
	rept 5		;Here
	stosb
	endm
	sub	edi,85
	loop	settaloop3
skipsetloop3:
	movzx	ecx,byte ptr [esi+6]
	sub	ecx,edx
	cmp	ecx,0
	jle	skipclaloop3
	xor	eax,eax
claarloop3:
	rept 5		;Here
	stosb
	endm
	sub	edi,85
	loop	claarloop3
skipclaloop3:
	pop	edi
	pop	ecx
	add	edi,12
	inc	esi
	loop	putequalizerloop3
	jmp	endputequalizer
theequalizer4:			       ;-----------set equalizer 4---------
	lea	esi,equhigh
	mov	ecx,6
	cmp	menu_downscreen,1
	jbe	notzoomed4
	mov	ecx,1
notzoomed4:
	mov	equcount,-1
PutEqualizerLoop4:
	pushad
	inc	equcount
	call	mouseon
	mov	ebx,equcount
	call	FixEqualizerFlimmer
	call	mouseoff
	mov	ah,00001000b			;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	popad
	push	ecx
	push	edi
;***********************************************************
;***********************************************************
	movzx	ecx,byte ptr [esi]
	mov	edx,ecx
	jecxz	skipsetloop4
	mov	eax,-1
settaloop4:
	rept 7		;Here
	stosb
	endm
	sub	edi,87
	loop	settaloop4
skipsetloop4:
	movzx	ecx,byte ptr [esi+6]
	sub	ecx,edx
	cmp	ecx,0
	jle	skipclaloop4
	xor	eax,eax
claarloop4:
	rept 7		;Here
	stosb
	endm
	sub	edi,87
	loop	claarloop4
skipclaloop4:
	pop	edi
	pop	ecx
	add	edi,12
	inc	esi
	loop	putequalizerloop4
	jmp	endputequalizer
theequalizer5:			       ;-----------set equalizer 5---------
	lea	esi,equhigh
	mov	ecx,6
	cmp	menu_downscreen,1
	jbe	notzoomed5
	mov	ecx,1
notzoomed5:
	mov	equcount,-1
PutEqualizerLoop5:
	pushad
	inc	equcount
	call	mouseon
	mov	ebx,equcount
	call	FixEqualizerFlimmer
	call	mouseoff
	mov	ah,00001000b			;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	popad
	push	ecx
	push	edi
;***********************************************************
;***********************************************************
	movzx	ecx,byte ptr [esi]
	mov	edx,ecx
	jecxz	skipsetloop5
	mov	eax,-1
settaloop5:
	rept 9		;Here
	stosb
	endm
	sub	edi,89
	loop	settaloop5
skipsetloop5:
	movzx	ecx,byte ptr [esi+6]
	sub	ecx,edx
	cmp	ecx,0
	jle	skipclaloop5
	xor	eax,eax
claarloop5:
	rept 9		;Here
	stosb
	endm
	sub	edi,89
	loop	claarloop5
skipclaloop5:
	pop	edi
	pop	ecx
	add	edi,12
	inc	esi
	loop	putequalizerloop5
	jmp	endputequalizer
theequalizer6:			       ;-----------set equalizer 6---------
	lea	esi,equhigh
	mov	ecx,6
	cmp	menu_downscreen,1
	jbe	notzoomed6
	mov	ecx,1
notzoomed6:
	mov	equcount,-1
PutEqualizerLoop6:
	pushad
	inc	equcount
	call	mouseon
	mov	ebx,equcount
	call	FixEqualizerFlimmer
	call	mouseoff
	mov	ah,00001000b			;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	popad
	push	ecx
	push	edi
;***********************************************************
;***********************************************************
	movzx	ecx,byte ptr [esi]
	mov	edx,ecx
	jecxz	skipsetloop6
	mov	eax,-1
settaloop6:
	rept 11 	;Here
	stosb
	endm
	sub	edi,91
	loop	settaloop6
skipsetloop6:
	movzx	ecx,byte ptr [esi+6]
	sub	ecx,edx
	cmp	ecx,0
	jle	skipclaloop6
	xor	eax,eax
claarloop6:
	rept 11
	stosb
	endm
	sub	edi,91
	loop	claarloop6
skipclaloop6:
	pop	edi
	pop	ecx
	add	edi,12
	inc	esi
	loop	putequalizerloop6
endputequalizer:				;end of equalizer
	call	mouseon
	call	mousereset


downandquit:
	mov	eax,dword ptr[equhigh]		;backup information
	mov	bx,word ptr[equhigh+4]
	mov	dword ptr [oldequhigh],eax
	mov	word ptr [oldequhigh+4],bx


	movzx	ebx,equspeeddown		;speed down
	mov	al,waitbyte
	cmp	al,[speeddown1+ebx]
	jbe	skipspeeddown
	mov	waitbyte,0
	movzx	edx,[speeddown2+ebx]
	lea	esi,equalizerinformation
	mov	ecx,6
speedsub:
	movzx	eax,byte ptr [esi]
	sub	eax,edx
	cmp	eax,0
	jge	skipsetta444
	xor	eax,eax
skipsetta444:
	mov	[esi],al
	inc	esi
	loop	speedsub
skipspeeddown:
	inc	waitbyte

endequ:
	popad
	ret
;---------------------------------- clear all equalizer -----------------
clearallequalizer:
	mov	optionchangeoffset,0
	call	mouseoff
	mov	ah,00001000b			;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	move	edi,0a0000h
	add	edi,28084
	xor	eax,eax
	mov	ecx,2
paja1:
	push	ecx
	push	edi

	mov	ecx,6
paja2:
	push	ecx
	push	edi

	mov	ecx,91
paja3:
	stosd
	stosd
	stosw
	stosb
	sub	edi,91
	loop	paja3

	pop	edi
	add	edi,12
	pop	ecx
	loop	paja2

	pop	edi
	add	edi,110*80
	pop	ecx
	loop	paja1

	call	mouseon
	jmp	aftertheclear
PutEqualizer	Endp

UpdateChannels	db	0
UpdateCommands	db	0
UpdateRows	dd	0
UpdateCurrRow	dw	0
UpdateArrowpointer db	0


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Updates the pattern to screen
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
UpdatePattern	  Proc	  Near
	Pushad
	lea	eax,ScreamTrackerHelpBars
	cmp	optionchangeoffset,eax
	jnz	NoFuckMyCousin
	mov	optionchangeoffset,0
	mov	oldrow,-1
NoFuckMyCousin:
	movzx	eax,CurrRow
	cmp	ax,OldRow
	jz	_retp
	mov	OldRow,ax

	cmp	Menu_DownScreen,3
	ja	_retp

	mov	PatternUpdate,2

	mov	MouseX1,607
	mov	MouseY1,276
	mov	MouseX2,616
	mov	MouseY2,446

	call	MouseOff
	xor	ebx,ebx 		;Update PatternDragbar
	mov	Dword Ptr [DragBarTable+ebx+10],eax
	mov	eax,CurrPattLength
	mov	Dword Ptr [DragBarTable+ebx+6],eax	;curr length

	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	mov	ExtraLength,1
	call	DragBarHandler
	mov	MouseOnDragBar,al
	call	MouseOn

	mov	MouseX1,0
	mov	MouseY1,261
	mov	MouseX2,639
	mov	MouseY2,274

	cmp	Menu_DownScreen,0
	jz	ProTrackerPattern
	cmp	Menu_DownScreen,2
	jz	ProTrackerPattern
	cmp	Menu_DownScreen,1
	jz	ScreamTrackerPattern
	cmp	Menu_DownScreen,3
	jz	ScreamTrackerPattern
	jmp	_retp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±± ProTrackerPattern ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ProTrackerPattern:
	call	CheckPatternStart_View
	mov	esi,PatternStart
	move	edi,0a0000h+80*262+1

	movzx	ebx,CurrRow
	sub	ebx,7

	mov	eax,ChRowSize
	imul	ebx
	add	esi,eax
;------------------------------------------ Upper Pattern Part
	mov	ecx,7
PrintPattern1:
	cmp	ebx,0
	jge	NoPUCP

	cmp	PatternMode,0
	jz	NoPUCP
	call	PrintUpperConnectPattern
	jnc	PUCP
NoPUCP:
	mov	al,Commands
	mov	UpdateCommands,al
	mov	al,Channels
	mov	UpdateChannels,al
	mov	eax,CurrPattLength
	mov	UpdateRows,eax
	mov	ax,CurrRow
	mov	UpdateCurrRow,ax
	mov	al,ArrowPointer
	mov	UpdateArrowpointer,al

	cmp	Menu_Popup,23		;PullDown
	jz	NoKutt
	movzx	eax,MouseY1
	cmp	[PopUpPlane1+12],eax
	jae	NoKutt
	mov	PatternUpdate,1
NoKutt:
	mov	BitPlane,07h
	mov	ah,07h			;Print RowNumber
	call	PrintOneRow_PT
PUCP:
	add	esi,ChRowSize
	inc	ebx
	add	edi,80*13
	loop	PrintPattern1

;------------------------------------------ Middle Pattern Part

	add	MouseY2,6

	mov	al,Commands
	mov	UpdateCommands,al
	mov	al,Channels
	mov	UpdateChannels,al
	mov	eax,CurrPattLength
	mov	UpdateRows,eax
	mov	ax,CurrRow
	mov	UpdateCurrRow,ax
	mov	al,ArrowPointer
	mov	UpdateArrowpointer,al

	add	edi,80*3

	cmp	Menu_Popup,23
	jz	Kutt2
	movzx	eax,MouseY1
	cmp	[PopUpPlane1+12],eax
	jae	Kutt2
	mov	PatternUpdate,1
Kutt2:

	mov	BitPlane,18h
	mov	ah,18h		       ;Print RowNumber
	call	PrintOneRow_PT
	add	edi,16*80

	add	MouseY1,6

	add	esi,ChRowSize
	inc	ebx

;------------------------------------------ Lower Pattern Part

	mov	ecx,7
PrintPattern2:				;Print last part
	cmp	ebx,CurrPattLength
	jbe	NoPUCP2

	cmp	PatternMode,0
	jz	NoPUCP2
	call	PrintLowerConnectPattern
	jnc	PUCP2
NoPUCP2:
	mov	al,Commands
	mov	UpdateCommands,al
	mov	al,Channels
	mov	UpdateChannels,al
	mov	eax,CurrPattLength
	mov	UpdateRows,eax
	mov	ax,CurrRow
	mov	UpdateCurrRow,ax
	mov	al,ArrowPointer
	mov	UpdateArrowpointer,al

	cmp	Menu_Popup,23
	jz	Kutt3
	movzx	eax,MouseY1
	cmp	[PopUpPlane1+12],eax
	jae	Kutt3
	mov	PatternUpdate,1 	;NoClipping
Kutt3:
	mov	BitPlane,07h
	mov	ah,07h			;Print RowNumber
	call	PrintOneRow_PT
PUCP2:
	add	esi,ChRowSize
	inc	ebx
	add	edi,80*13
	loop	PrintPattern2
	jmp	DoUpdatePattern


;±±±±±±±±±±±±±±±±±±±±±±±±±±± ScreamTrackerPattern ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
CursorRow	db	0	;ST Cursor
CurrentSTRow	db	0	;Row to display first at screen
ScreamTrackerPattern:

	mov	al,Commands
	mov	UpdateCommands,al
	mov	al,Channels
	mov	UpdateChannels,al
	mov	eax,CurrPattLength
	mov	UpdateRows,eax
	mov	ax,CurrRow
	mov	UpdateCurrRow,ax
	mov	al,ArrowPointer
	mov	UpdateArrowpointer,al

	mov	ax,CurrRow
	mov	CursorRow,al
	and	eax,0ffffh
	cmp	al,CurrentSTRow
	jae	GotThat1
	mov	CurrentSTRow,al
	jmp	GotThat
GotThat1:
	mov	al,CurrentSTRow
	add	al,14
	cmp	al,CursorRow
	jae	GotThat
	mov	al,CursorRow
	sub	al,14
	mov	CurrentSTRow,al
GotThat:
	call	CheckPatternStart_View
	mov	esi,PatternStart
	move	edi,0a0000h+80*262+1
	movzx	ebx,CurrentSTRow
	mov	eax,ChRowSize
	mul	ebx
	add	esi,eax

	mov	ecx,15
PrintSTPattern:

	cmp	Menu_Popup,23
	jz	Kutt4
	movzx	eax,MouseY1
	cmp	[PopUpPlane1+12],eax
	jae	Kutt4
	mov	PatternUpdate,1 	;No Clip
Kutt4:

	mov	BitPlane,07h
	mov	ah,07h			;Print RowNumber
	call	PrintOneRow_PT
	add	esi,ChRowSize
	add	edi,80*13
	inc	ebx
	loop	PrintSTPattern

DoUpdatePattern:
	mov	bl,0
	call	SetReset

	call	MouseOn
	call	MouseReset
	mov	PatternUpdate,0
	Popad
	Ret
UpdatePattern  EndP


PrintLowerConnectPattern:
	pushad
	cmp	ebx,CurrPattLength
	jz	PUCPQuit

	movzx	ebp,CurrPosition
	inc	ebp
	cmp	bp,Positions
	jz	PUCPQuit

	shl	ebp,1
	add	ebp,PatternOrderPtr
	movzx	ebp,word ptr [ebp]
	mov	eax,[AllocTable+ebp*8]
	cmp	eax,0
	jnz	NoEmptyPattern4
	mov	eax,EmptyPattern
NoEmptyPattern4:
	add	eax,12
	mov	esi,eax
	mov	al,[esi-1]
	mov	ah,al
	and	al,31
	shr	ah,5
	inc	al
	mov	UpdateChannels,al
	mov	UpdateCommands,ah
	movzx	eax,byte ptr [esi-2]
	mov	UpdateRows,eax
	inc	UpdateRows
	sub	ebx,CurrPattLength
	dec	ebx
	cmp	ebx,eax
	ja	PUCPQuit
	movzx	ebp,CurrPosition
	inc	ebp
	jmp	PCP


PrintUpperConnectPattern	Proc	Near
	pushad
	cmp	ebx,-1
	jz	PUCPQuit

	movzx	ebp,CurrPosition
	dec	ebp
	jl	PUCPQuit

	shl	ebp,1
	add	ebp,PatternOrderPtr
	movzx	ebp,word ptr [ebp]
	mov	eax,[AllocTable+ebp*8]
	cmp	eax,0
	jnz	NoEmptyPattern
	mov	eax,EmptyPattern
NoEmptyPattern:
	add	eax,12
	mov	esi,eax
	mov	al,[esi-1]
	mov	ah,al
	and	al,31
	shr	ah,5
	inc	al
	mov	UpdateChannels,al
	mov	UpdateCommands,ah
	movzx	eax,byte ptr [esi-2]
	mov	UpdateRows,eax
	inc	UpdateRows
	add	ebx,eax
	add	ebx,2
	cmp	ebx,0
	jl	PUCPQuit
PCP:
	movzx	ecx,UpdateChannels
	movzx	eax,UpdateCommands
	shl	eax,1
	add	eax,2
	mul	ecx
	mul	ebx
	add	esi,eax

	mov	ah,07h			;Print RowNumber
	mov	UpdateCurrRow,-1
	mov	UpdateArrowpointer,-1
	call	PrintOneRow_PT
	clc
	popad
	ret
PUCPQuit:
	stc
	popad
	ret
PrintUpperConnectPattern	EndP

Global SBP_SetZeroVol:Near,SBP_SetOrigVol:Near
Switch16Bit:
	ret

GetRunningFileName	Proc	Near
	pushad

	mov	esi,_env
	dec	esi
GetEnv:
	inc	esi
	cmp	byte ptr [esi],0
	jnz	GetEnv
	inc	esi
	cmp	byte ptr [esi],0
	jnz	GetEnv
	add	esi,3
	lea	edi,CurrentPath
FrusenFisk:
	mov	al,[esi]
	stosb
	inc	esi
	cmp	al,0
	jnz	FrusenFisk

	lea	esi,CurrentPath+64+13
	mov	ecx,64+13
SearchZero:
	dec	esi
	cmp	byte ptr [esi],'\'
	loopnz	SearchZero
	inc	esi

	xor	edi,edi
	mov	ecx,13
CropPath:
;------------
	mov	al,byte ptr [esi]
IF	MAKEEXE
	mov	byte ptr [PicturesFileName+edi],al
ENDIF
	mov	byte ptr [CurrentTrackerName+edi],al
	inc	edi
;------------
	mov	byte ptr [esi],0
	inc	esi
	loop	CropPath

	popad
	ret
GetRunningFileName	EndP

CDLCommand	db	0
CDLStartValue	dw	0
RampCommandData Proc	Near
	call	StoreUndoBuffer
	pushad
	push	word ptr CursorChannel
	mov	cl,MM_ChanStart
	mov	CursorChannel,cl
RampNextChannel:
	mov	ax,MM_RowEnd
	mov	bx,MM_RowStart
	movzx	ecx,ax			;Nr of rows-1
	sub	cx,bx
	jz	QuitRCD
	push	word ptr CurrRow

	mov	CurrRow,ax		;Get 2:nd value
	call	CalculateOffset
	movzx	ebp,[Cmd+edi]
	shl	ebp,1
	add	ebp,2
	mov	dx,[esi+ebp]
	and	edx,0ff00h

	mov	CurrRow,bx		;Get 1:st value
	call	CalculateOffset
	mov	ax,[esi+ebp]
	mov	CDLCommand,al
	and	eax,0ff00h
	mov	CDLStartValue,ax
	pop	word ptr CurrRow

	sub	edx,eax
	mov	eax,edx
	cdq
	idiv	ecx


	inc	ecx
FixCDLShit:
	mov	dx,CDLStartValue
	mov	dl,CDLCommand
	mov	[esi+ebp],dx
	add	esi,ChRowSize
	add	CDLStartValue,ax
	loopw	FixCDLShit

	inc	CursorChannel
	mov	cl,CursorChannel
	cmp	cl,MM_ChanEnd
	jbe	RampNextChannel

	mov	OldRow,-1
QuitRCD:
	pop	word ptr CursorChannel
	popad
	ret
RampCommandData EndP

ChangeInst	Proc	Near
	call	StoreUndoBuffer
	pushad
	push	word ptr CursorChannel
	mov	cl,MM_ChanStart
	mov	CursorChannel,cl
@@Loopen:
	mov	ax,MM_RowEnd
	mov	bx,MM_RowStart
	mov	cx,ax			;Nr of rows-1
	sub	cx,bx
	jz	@@Quit
	inc	cx

	push	word ptr CurrRow
	mov	CurrRow,bx
	call	CalculateOffset
	pop	word ptr CurrRow

@@Loopen2:
	cmp	byte ptr [esi+1],0
	jz	@@Skip
	mov	bl,CurrentInstrument
	mov	[esi+1],bl
@@Skip:
	add	esi,ChRowSize
	loopw	@@Loopen2

	inc	CursorChannel
	mov	cl,CursorChannel
	cmp	cl,MM_ChanEnd
	jbe	@@Loopen

	mov	OldRow,-1
@@Quit:
	pop	word ptr CursorChannel
	popad
	ret
ChangeInst	EndP


;-----------------------------------------------------------------------------
;			  -+*+- MIDI handler -+*+-
;-----------------------------------------------------------------------------
RowAdderTemp	db	0
;MIDIState	db	0	; 0=None / 1=NoteOn / 2=NoteOff
ParseCode	dd	0	; Code for parsing data

MIDIPriority	dw	32 dup(0)	;MIDI priority
Priority	dw	0

; Get a byte from the MIDI stream into AL
GetMIDIbyte macro
	movzx	eax,MIDIBuffPtrR
	mov	al,[MIDIBuffer+eax]
	endm

; Step to next byte in MIDI stream
StepMIDI macro
	inc	MIDIBuffPtrR
	and	MIDIBuffPtrR,31
	dec	MIDIBuffLen
	endm

UpdateMIDI proc	near
	pushad

parseMidi:
	cmp	MIDIBuffLen,0		; Any MIDI to parse?
	jz	NoMidi

	; Get byte from MIDI stream
	GetMIDIbyte

;	mov	al,81h	; Assume this input

	test	al,80h	; Status byte?
	jz	@@wasdata

	movzx	ebx,al
	and	bl,70h	; Filter out unused bits
	shr	bl,4-2	; Shift bits

	mov	ebx,[MIDILookUpTab+ebx]		; Get routine ptr
	test	ebx,ebx
	jz	M_Unknown			; Cancel status

	jmp	ebx

	; Data byte received
@@wasdata:
	mov	ebx,ParseCode	; Get ptr to code for parsing data
	test	ebx,ebx		; Unknown data?
	jz	StepNext	; In that case, just skip it

	jmp	ebx

;			  -+*+- STATUS BYTES -+*+-
M_NoteOn:
	lea	eax,M_NoteOnParse
	mov	ParseCode,eax
	jmp	StepNext
M_NoteOnParse:
	cmp	MIDIBuffLen,2	; Note+Velocity byte waiting for us?
	jb	NoMIDI		; If not, wait for it

	add	al,2
	movzx	edx,al		; Note in EDX

	StepMIDI		; Step to next byte
	GetMIDIbyte		; Get velocity
	call	PlayNote
	jmp	StepNext

M_NoteOff:
	lea	eax,M_NoteOffParse
	mov	ParseCode,eax
	jmp	StepNext
M_NoteOffParse:
	cmp	MIDIBuffLen,2	; Note+Velocity byte waiting for us?
	jb	NoMIDI		; If not, wait for it
	add	al,2
	movzx	edx,al
	StepMIDI
	GetMIDIbyte		; Get note off velocity (not really used)
	xor	al,al		; Set it to zero
	call	PlayNote
	jmp	StepNext

M_System:
	jmp	StepNext

M_Unknown:
	mov	ParseCode,0	; Entering unknown status, don't parse any data
	jmp	StepNext

NoMidi:	popad
	ret

; Step to next byte in MIDI stream
StepNext:StepMIDI
	jmp	parseMidi

UpdateMIDI endp

;                   -+*+- Play current instrument -+*+-
; EDX=Note
; AL=Volume
PlayNote proc	near
	cmp	Sampling,0
	jnz	@@exit

	pushad
        mov	ah,dl		; Routines requires note in AH too
	cmp	ah,121		; Notes above 121 are not wanted
	ja	@@ut
	push	word ptr CursorChannel
	mov	bl,RowAdder
	mov	RowAdderTemp,bl
	cmp	MIDIMode,1
	jz	NoNrmlkbd
	cmp	EditMode,1
	jz	NotKBD2CKH2
	cmp	MIDIMode,2
	jz	NoNrmlkbd
NotKBD2CKH2:
	cmp	al,0
	jz	ReleaseNormalKBD

;	call	NoMIDIStyle
	call	MousePlay	; Play note (not relative to octave)
	jmp	NoFreeToPlay
ReleaseNormalKBD:
	call	NormalKBDOff
	jmp	NoFreeToPlay
NoNrmlkbd:
	mov	RowAdder,0
	mov	bl,KeyboardMode
	mov	bh,MIDIMode
	mov	KeyboardMode,bh
	push	bx
	call	GetFreeChannel
	jc	NoFreeToPlay3
;	call	NoMIDIStyle
;	movzx	ebx,Octave
;	lea	ebx,[ebx+ebx*2]
;	shl	ebx,2
;	add	ebx,2
;	add	edx,ebx
	call	MousePlay	; Play note
NoFreeToPlay3:
	pop	bx
	mov	KeyboardMode,bl
NoFreeToPlay:
	mov	bl,RowAdderTemp
	mov	RowAdder,bl
	pop	word ptr CursorChannel
@@ut:	popad
@@exit:	ret
PlayNote endp


;		     -+*+- Initialize MIDI table -+*+-
InitMIDITables	proc	near
	pushad

	lea	esi,MIDIInitLut
	lea	ebp,MIDILookUpTab
	mov	edi,ebp
	xor	eax,eax
	mov	ecx,8
	rep	stosd		; Clear table (just for safety)

@@init:	lodsb			; Get command byte
	test	al,al		; End of table?
	jz	@@ut
	and	al,70h		; Only bits 4-6 used in status command
	shr	al,4-2		; Move bits to 0-2 (but then *4 for table size)
	movzx	ebx,al
	lodsd			; Get ptr to routine
	mov	[ebp+ebx],eax	; Store in lookup table
	jmp	@@init

@@ut:	popad
	ret
	endp

; MIDI status code lookup table
MIDILookUpTab	dd	8	dup(0)

MIDIInitLUT	db	090h	; Note On
		dd	M_NoteOn
		db	080h	; Note Off
		dd	M_NoteOff
		db	0f0h	; System messages
		dd	M_System
		db	0	; End of data

;			 -+*+- OLD MIDI CODE -+*+-
comment	%
BendValue	dw	0		;Used by PitchBend
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

UpdateMIDI	Proc	Near
	pushad
	cmp	MIDIBuffLen,0
	jz	NoMIDI
	movzx	ebx,MIDIBuffPtrR

	cmp	MIDIState,0
	jz	UpdateKeyPress
	cmp	MIDIState,1
	jz	UpdateProgramChange
	cmp	MIDIState,3
	jz	UpdatePitchBend
	jmp	NoMIDI

ChangeToKeyPress:
	inc	ebx
	and	bl,01fh
	mov	MIDIBuffPtrR,bl
	dec	MIDIBuffLen
UpdateKeyPress:
	mov	MIDIState,0
	cmp	MIDIBuffLen,2
	jb	NoMIDI
	mov	al,[MIDIBuffer+ebx]
	inc	ebx
	and	bl,01fh
	mov	MIDIBuffPtrR,bl
	dec	MIDIBuffLen

	mov	ah,al
	and	ah,0f0h
	cmp	ah,090h
	jz	UpdateKeyPress
	cmp	ah,0c0h
	jz	UpdateProgramChange
	cmp	ah,0e0h
	jz	UpdatePitchBend

	mov	ah,al			;Note
	sub	al,24h
	movzx	edx,al
	mov	al,[MIDIBuffer+ebx]	;volume
	cmp	Sampling,0
	jnz	SkipReadMIDI

	pushad
	push	word ptr CursorChannel
	mov	bl,RowAdder
	mov	RowAdderTemp,bl
	cmp	MIDIMode,1
	jz	NoNrmlkbd
	cmp	EditMode,1
	jz	NotKBD2CKH2
	cmp	MIDIMode,2
	jz	NoNrmlkbd
NotKBD2CKH2:
	cmp	al,0
	jz	ReleaseNormalKBD

	call	NoMIDIStyle
	jmp	NoFreeToPlay
ReleaseNormalKBD:
	call	NormalKBDOff
	jmp	NoFreeToPlay
NoNrmlkbd:
	mov	RowAdder,0
	mov	bl,KeyboardMode
	mov	bh,MIDIMode
	mov	KeyboardMode,bh
	push	bx
	call	GetFreeChannel
	jc	NoFreeToPlay3
	call	NoMIDIStyle
NoFreeToPlay3:
	pop	bx
	mov	KeyboardMode,bl
NoFreeToPlay:
	mov	bl,RowAdderTemp
	mov	RowAdder,bl
	pop	word ptr CursorChannel
	popad
SkipReadMIDI:

	inc	ebx
	and	bl,01fh
	mov	MIDIBuffPtrR,bl
	dec	MIDIBuffLen
	jz	NoMIDI
	jmp	UpDateKeyPress

UpdateProgramChange:
	mov	MIDIState,1
	mov	al,[MIDIBuffer+ebx]
	mov	ah,al
	and	ah,0f0h
	cmp	ah,90h
	jz	ChangeToKeyPress
	cmp	ah,0e0h
	jz	ChangeToPitchBend
	cmp	al,Samples
	ja	NoProgramChange
	mov	CurrentInstrument,al
	push	ax
	movzx	ax,al
	shl	ax,4
	mov	CurrentSample,ax
	mov	CurrentSampName,ax
	pop	ax
	cmp	al,0
	jz	NoProgramChange
	mov	cl,CurrentInstName
	cmp	al,cl
	ja	MIDISampleIsBelow
	dec	al
	mov	CurrentInstName,al
	jmp	MIDIQuitSS
MIDISampleIsBelow:
	add	cl,12
	cmp	al,cl
	jb	MIDIQuitSS
	sub	al,12
	mov	CurrentInstName,al
MIDIQuitSS:
	call	PrintSampleInfo
	call	SampleToRAM
	cmp	AutoName,0
	jz	NoProgramChange
	pushad
	call	Getname2
	popad
NoProgramChange:
	inc	ebx
	and	bl,01fh
	mov	MIDIBuffPtrR,bl
	dec	MIDIBuffLen
	jz	NoMIDI
	jmp	UpdateProgramChange

ChangeToPitchBend:
	inc	ebx
	and	bl,01fh
	mov	MIDIBuffPtrR,bl
	dec	MIDIBuffLen
UpdatePitchBend:
	mov	MIDIState,3
	cmp	MIDIBuffLen,2
	jb	NoMIDI
	mov	al,[MIDIBuffer+ebx]
	inc	ebx
	and	bl,01fh
	mov	MIDIBuffPtrR,bl
	dec	MIDIBuffLen
	mov	ah,al
	and	ah,0f0h
	cmp	ah,090h
	jz	UpdateKeyPress
	cmp	ah,0c0h
	jz	UpdateProgramChange
	mov	ah,al
	mov	al,[MIDIBuffer+ebx]
	rol	ax,8
	mov	BendValue,ax
	inc	ebx
	and	bl,01fh
	mov	MIDIBuffPtrR,bl

	pushad
	mov	edx,KeyBoardNote
	sub	edx,2
	ConvertNote edx edi
	mov	eax,12			;Bend range
	sub	BendValue,16384
	jg	BendOver
	neg	eax
BendOver:

	add	edx,eax 		;Range change
	jg	NoLowerProblem
	mov	edx,0
NoLowerProblem:
	cmp	edx,96
	jb	NoUpperProblem
	mov	edx,95
NoUpperProblem:
	ConvertNote edx eax
	cmp	BendValue,0
	jg	BendOverWhelmed
	sub	eax,edi
	neg	eax
	jmp	UnderWhelmed
BendOverWhelmed:
	sub	eax,edi
UnderWhelmed:
	movsx	ebx,BendValue
	imul	ebx
	sar	eax,14
	add	edi,eax

	movzx	ebx,CurrentInstrument
	mov	ax,[SampleRates+ebx*2]
	call	SetTheFreq
	popad

	dec	MIDIBuffLen
	jz	NoMIDI
	jmp	UpdatePitchBend

NoMIDI:
	popad
	ret
UpdateMIDI	EndP
	%

GetFreeChannel	Proc	Near
	cmp	al,0
	jnz	FindChan

	movzx	ecx,Channels
	mov	edi,-1
FindChannelToFree:
	inc	edi
	cmp	[MIDIChanTable+edi],ah
	loopnz	FindChannelToFree
	jnz	Flickor
	mov	[MIDIChanTable+edi],0
	mov	[KeyOffTable+edi],0
	mov	LastKeyPressed,0

	cmp	MultiChanPlay,1
	jnz	MultiAntiSkip1
	cmp	EditMode,0
	jz	MultiSkip1
MultiAntiSkip1:
	cmp	MultiChanPlay,2
	jz	MultiSkip1
	mov	[MIDIPriority+edi*2],0
MultiSkip1:

	mov	ecx,edi
	inc	ecx

	movzx	ebx,byte ptr [CurrInst+edi]
	GetOffset ebx,eax,ENV_Flags
	bt	word ptr [eax],2			;Check Envelope ON
	jc	DontBrutallyStopVoice
	cmp	SenseKeyOff,0
	jz	DontBrutallyStopVoice
	call	StopOneVoice
DontBrutallyStopVoice:

	movzx	ecx,Channels
FindChannelToFree2:
	cmp	[MIDIChanTable+ecx-1],0
	loopz	FindChannelToFree2
	jnz	Flickor
	jecxz	UpdateRowAdd
	stc
	ret

UpdateRowAdd:
	cmp	KeyBoardMode,2
	jz	Flickor

	cmp	MultiChanPlay,1
	jnz	MultiAntiSkip2
	cmp	EditMode,0
	jz	MultiSkip2
MultiAntiSkip2:
	cmp	MultiChanPlay,2
	jz	MultiSkip2
	mov	Priority,0
MultiSkip2:

	movzx	dx,RowAdderTemp
	mov	RowAdder,dl
	mov	OldRow,-1
	cmp	RecMode,1
	jz	Flickor
	cmp	EditMode,0
	jz	Flickor
	cmp	ArrowPointer,0
	jnz	Flickor
	mov	ax,CurrRow
	add	ax,dx
	call	AddXRows
Flickor:
	stc
	ret

FindChan:
	cmp	MultiChanPlay,1
	jnz	MultiAntiSkip3
	cmp	EditMode,0
	jz	NoFreeChannels
MultiAntiSkip3:
	cmp	MultiChanPlay,2
	jz	NoFreeChannels

	movzx	ecx,Channels
	sub	cl,CursorChannel
	movzx	ebx,CursorChannel
	dec	ebx
FindFreeChannel:
	jecxz	NoFreeChannels
	inc	ebx
	cmp	[MIDIChanTable+ebx],0
	loopnz	FindFreeChannel
	jnz	NoFreeChannels

	push	edx
	movzx	edx,byte ptr [ChanPos+ebx]
	cmp	[Mute+edx],2
	pop	edx
	jz	FindFreeChannel

FreeOkay:
	mov	[MIDIChanTable+ebx],ah
	inc	Priority
	mov	bp,Priority
	mov	[MIDIPriority+ebx*2],bp
	mov	[KeyOffTable+ebx],1
	mov	Cursorchannel,bl
	clc
	ret


NoFreeChannels:
	push	edx
	movzx	ecx,Channels
	sub	cl,CursorChannel
	jz	NoFreePriChannels
	movzx	ebx,CursorChannel
	mov	edx,-1
FindPriChannel:
	cmp	[Mute+ebx],2
	jz	NoLosLobos

	cmp	MultiChanPlay,0
	jz	MultiSkip3
	cmp	MultiChanPlay,1
	jnz	MultiAntiSkip4
	cmp	EditMode,1
	jz	MultiSkip3
MultiAntiSkip4:
	cmp	[MIDIChanTable+ebx],0
	jnz	NoLosLobos
MultiSkip3:

	cmp	dx,[MIDIPriority+ebx*2]
	jb	NoLosLobos
	mov	dx,[MIDIPriority+ebx*2]
	mov	ebp,ebx
NoLosLobos:
	inc	ebx
	loop	FindPriChannel

NoFreePriChannels:
	cmp	dx,-1
	pop	edx
	jz	NoFreeOkay
	mov	ebx,ebp
	jmp	FreeOkay
NoFreeOkay:
	stc
	ret
GetFreeChannel	EndP

Temp_Ax 	dw	0
TempSamples	dw	0
AddAnEmptySample	Proc	Near
	call	Fixbutton
AddAnEmptySample2:
	pushad
	mov	Temp_AX,1
	movzx	ax,Samples
	mov	TempSamples,ax

	inc	TempSamples
	cmp	TempSamples,256
	jb	NotTooManySamples2_j

;	mov	Samples,255
;	mov	CurrentInstName,255-12
;	mov	CurrentInstrument,255
;	mov	CurrentSample,0ff0h
;	mov	CurrentSampName,0ff0h
;	call	PrintSampleinfo
	mov	ax,SampleErr
	jmp	ErrorHandler
NotTooManySamples2_j:

	mov	Sample0,0
	movzx	eax,TempSamples
	push	eax
	mov	ebx,30
	mul	ebx
	mov	ebp,1029		;Allocate Inst. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstNamesPtr,eax

	movzx	eax,TempSamples
	mov	ebx,22*16
	mul	ebx
	mov	ebp,1028		;Allocate Samp. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampleNamesPtr,eax

	movzx	eax,TempSamples
	mov	ebx,716
	mul	ebx
	mov	ebp,1034		;Allocate Inst. Info
	mov	ebx,1
	cli
	call	MemAlloc
	mov	InstrumentInfo,eax
	sti
	jc	NotEnoughHiMem
	mov	FileEdited,1
	pop	eax
	mov	Samples,al

	push	ax
	mov	CurrentInstrument,al
	shl	ax,4
	mov	CurrentSample,ax
	mov	CurrentSampName,ax
	pop	ax

	cmp	Temp_AX,0
	jz	DoNotSetIt
	mov	ebp,eax
	shl	ebp,4

	mov	ecx,16
InitSamplesLoop:
	mov	[SampleOffsetStart+ebp*4],0
	mov	[LoopStart+ebp*4],0
	mov	[LoopEnd+ebp*4],0
	mov	[SampleOffsetEnd+ebp*4],0
	mov	[FineTunes+ebp],0
	mov	[RelativeNote+ebp],0
	mov	[SampleRates+ebp*2],8363
	mov	[Volumes+ebp],127
	mov	[VoiceControl+ebp],0
	inc	ebp
	loop	InitSamplesLoop

	call	SetInitialEnvelopes

DoNotSetIt:
	mov	bx,ax
	sub	bx,12
	jl	NoCyrrr
	mov	CurrentInstName,bl
NoCyrrr:
	call	PrintSampleinfo
	call	SampleToRAM

	popad
	ret
AddAnEmptySample	EndP

RemoveASample	Proc	Near
	pushad
	mov	OldCurrentInstName,-1
	call	Fixbutton
	movzx	ebp,Samples
	mov	TempSamples,bp
	shl	ebp,4
	call	CheckInstEmpty2
	jc	NoNoLimit

	cmp	ebp,16
	jz	NoNoLimit2
	dec	TempSamples
	mov	Temp_AX,0
	jmp	NotTooManySamples2_j
NoNoLimit:
	mov	ax,TempSamples
	mov	CurrentInstrument,al
	call	KillInstrument
	mov	Temp_AX,0
	cmp	PopupStatus,0
	jz	NoNoLimit2
	cmp	TempSamples,1
	jz	NotTooManySamples2_j
	dec	TempSamples
	jmp	NotTooManySamples2_j
NoNoLimit2:
	popad
	ret
RemoveASample	EndP

PrintMIDIShit	Proc	Near
	pushad
	move	edi,0a0000h+8
	xor	edx,edx
	mov	ecx,8
Rolle:
	push	ecx
	mov	ah,0fh
	add	edi,80*12-2*4

	mov	ecx,4
Ralle:
	push	ecx
	mov	cl,2
	movzx	ebx,[MIDIBuffer+edx]
	cmp	dl,MIDIBuffPtrR
	jnz	NoInverte
	mov	InvertText,-1
NoInverte:
	call	PutHex
	mov	InvertText,0
	add	edi,2
	inc	edx
	pop	ecx
	loop	Ralle

	pop	ecx
	loop	Rolle
	popad
	ret
PrintMIDIShit	EndP

PrintUsedChannels	Proc	Near
	pushad
	move	edi,0a0000h+8
	xor	edx,edx
	mov	ah,0fh
	mov	ecx,12
Rulle:
	push	ecx
	mov	cl,2
	movzx	ebx,[R_CurrNoteTable+edx]
	call	PutHex
	add	edi,3
	inc	edx
	pop	ecx
	loop	Rulle

	popad
	ret
PrintUsedChannels	EndP

MIDIStyle:
	pushad
	push	word ptr CursorChannel
	mov	bl,RowAdder
	mov	RowAdderTemp,bl

	cmp	KeyBoardMode,1
	jnz	DontSkipRowAdd
	mov	RowAdder,0
DontSkipRowAdd:
	mov	ah,al		;note
	add	ah,128
	mov	al,127
	call	CheckMIDIStyleNoRepeat
	jc	NoFreeToPlay2
	call	GetFreeChannel	;al=0: Free a channel, ah=note
	jc	NoFreeToPlay2
	call	NoMIDIStyle
NoFreeToPlay2:
	mov	bl,RowAdderTemp
	mov	RowAdder,bl
	pop	word ptr CursorChannel
	popad
	ret

CheckMIDIStyleNoRepeat	Proc	Near
	pushad
	movzx	ecx,Channels
FindelToFree:
	cmp	[MIDIChanTable+ecx-1],ah
	loopnz	FindelToFree
	jz	DoNoRepeat
	clc
	popad
	ret
DoNoRepeat:
	cmp	KeyBoardMode,2
	jnz	NoRepa
	cmp	EditMode,0
	jz	NoRepa
	mov	[MIDIChanTable+ecx],0
	clc
	popad
	ret
NoRepa:
	stc
	popad
	ret
CheckMIDIStyleNoRepeat	EndP

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			      Button up down mem
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;	 SizeX = size in x
;	 ButtonX1 = Target x1
;	 ButtonY1 = Target y1
;	 ButtonX2 = Target x2
;	 ButtonY2 = Target y2
;	       Bl = (1=Up 0=Down)
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SizeX			dd	0
SizeX2			dd	0
ButtonSetColor		db	0
ButtonNewOffset 	dd	0
ButtonUpDownMem Proc	Near
	pushad

	xor	bl,1
	cmp	ButtonSetColor,1
	jz	notsetthecolor
	mov	buttonC1,12
	mov	buttonC2,14
notsetthecolor:
	mov	ButtonSetColor,0
	mov	eax,sizex
	shl	eax,2
	mov	sizex2,eax

	cmp	bl,1
	jz	noflipphere2
	mov	al,buttonC1
	xchg	al,buttonC2
	mov	buttonC1,al
noflipphere2:

	mov	edi,pcxbuffer			;set edi
	cmp	ButtonNewOffset,0
	jz	skipnewoffset
	mov	edi,ButtonNewOffset
skipnewoffset:
	mov	ButtonNewOffset,0
	mov	eax,buttony1
	mov	ebx,sizeX
	mul	ebx
	shl	eax,2
	mov	ebx,buttonx1
	add	edi,eax

	call	mouseoff

	mov	eax,buttonx1			;fill first line
	mov	buttonxstart,eax
	mov	eax,buttonx2
	mov	buttonxend,eax
	movzx	eax,buttonC1
	mov	linecolor,eax
	call	filllinebutton2
	add	edi,sizeX2

	;mov	 eax,buttonx1			 ;fill second line
	;mov	 buttonxstart,eax
	;mov	 eax,buttonx2
	;dec	 eax
	;mov	 buttonxend,eax
	;movzx	 eax,buttonC1
	;mov	 linecolor,eax
	;call	 filllinebutton2

	;mov	 eax,buttonx2			 ;fill second line a dot
	;mov	 buttonxstart,eax
	;mov	 buttonxend,eax
	;movzx	 eax,buttonC2
	;mov	 linecolor,eax
	;call	 filllinebutton2
	;add	 edi,sizeX2

						;fill line down
			 ;------------------------------------
	push	edi
	mov	ebp,buttony2
	sub	ebp,buttony1
	sub	ebp,1
	mov	eax,buttonx1
	mov	ebx,eax
	shr	eax,3
	add	edi,eax
	and	ebx,7
	mov	cx,15
	sub	cx,bx
	mov	ax,0ffffh
	btr	ax,cx
	dec	cx
	;btr	 ax,cx
	ror	ax,8
	mov	bx,ax
	xor	bx,0ffffh
	mov	ecx,4
	xor	si,si
lineplanedown1:
	push	ecx
	push	edi

	movzx	dx,buttonc1
	bt	dx,si
	jc	loooop2

	mov	edx,sizex
	shl	edx,2
	mov	ecx,ebp
lineloopa:
	and	[edi],ax
	add	edi,edx
	loop	lineloopa
	jmp	aftertheloopa
loooop2:
	mov	edx,sizex
	shl	edx,2
	mov	ecx,ebp
lineloopa2:
	and	[edi],ax
	or	[edi],bx
	add	edi,edx
	loop	lineloopa2
aftertheloopa:

	pop	edi
	pop	ecx
	add	edi,sizex
	inc	si
	loop	lineplanedown1
	pop	edi
			 ;------------------------------------
	push	edi
	mov	ebp,buttony2
	sub	ebp,buttony1
	sub	ebp,1
	mov	eax,buttonx2
	dec	eax
	mov	ebx,eax
	shr	eax,3
	add	edi,eax
	and	ebx,7
	mov	cx,15
	sub	cx,bx
	mov	ax,0ffffh
	;btr	 ax,cx
	dec	cx
	btr	ax,cx
	ror	ax,8
	mov	bx,ax
	xor	bx,0ffffh
	mov	ecx,4
	xor	si,si
lineplanedown1__:
	push	ecx
	push	edi

	movzx	dx,buttonc2
	bt	dx,si
	jc	loooop2__

	mov	edx,sizex
	shl	edx,2
	mov	ecx,ebp
lineloopa__:
	and	[edi],ax
	add	edi,edx
	loop	lineloopa__
	jmp	aftertheloopa__
loooop2__:
	mov	edx,sizex
	shl	edx,2
	mov	ecx,ebp
lineloopa2__:
	and	[edi],ax
	or	[edi],bx
	add	edi,edx
	loop	lineloopa2__
aftertheloopa__:

	pop	edi
	pop	ecx
	add	edi,sizex
	inc	si
	loop	lineplanedown1__
	pop	edi


	mov	eax,buttony2
	sub	eax,buttony1
	sub	eax,1
	mov	ebx,sizex2
	mul	ebx
	add	edi,eax

			 ;------------------------------------

	;mov	 eax,buttonx1			 ;fill second from end dot
	;mov	 buttonxstart,eax
	;mov	 buttonxend,eax
	;movzx	 eax,buttonC1
	;mov	 linecolor,eax
	;call	 filllinebutton2

	;mov	 eax,buttonx1			 ;fill second from end line
	;inc	 eax
	;mov	 buttonxstart,eax
	;mov	 eax,buttonx2
	;mov	 buttonxend,eax
	;movzx	 eax,buttonC2
	;mov	 linecolor,eax
	;call	 filllinebutton2
	;add	 edi,sizex2

	mov	eax,buttonx1			;fill end line
	mov	buttonxstart,eax
	mov	eax,buttonx2
	mov	buttonxend,eax
	movzx	eax,buttonC2
	mov	linecolor,eax
	call	filllinebutton2

	call	mouseon
	popad
	ret


;	ButtonXstart = X start
;	  ButtonXend = X end
;	   LineColor = line color
;		 edi = filloffset (only y)
FillLineButton2:
	pushad
	mov	eax,buttonxstart		;Prepare edi
	shr	eax,5
	shl	eax,2
	add	edi,eax
	mov	buttonedisave,edi

	mov	buttonplane,1

	mov	ecx,4
Filllineloop2WW:
	push	ecx

	mov	edi,buttonedisave		;restore edi

	mov	eax,buttonplane 		;choose bitplane
	mov	ebx,eax
	mov	ecx,linecolor
	and	ebx,ecx
	mov	buttonsave,ebx
	shl	eax,8

	mov	ebp,buttonxend
	sub	ebp,buttonxstart
	inc	ebp
	mov	eax,buttonxstart
	mov	buttonstartsave,eax
Filllineloop1WW:

	mov	ecx,buttonstartsave		;fix the first dword
	and	ecx,31
	mov	eax,0ffffffffh
	shr	eax,cl

	mov	ebx,ebp 			;check if shorter then 32 pix
	add	ebx,ecx
	cmp	ebx,32
	ja	morefillnowWW

	mov	ecx,32				;fix of on the right
	sub	ecx,ebx 			;if just one dword
	mov	ebx,0ffffffffh
	shl	ebx,cl
	and	eax,ebx
	ror	ax,8
	ror	eax,16
	ror	ax,8
	xor	eax,0ffffffffh			;move out a dword to the screen
	and	[edi],eax
	cmp	buttonsave,0
	jz	buttonjump1WW
	xor	eax,0ffffffffh
	or	[edi],eax
buttonjump1WW:
	jmp	endfillloop1WW

morefillnowWW:
	ror	ax,8
	ror	eax,16
	ror	ax,8
	xor	eax,0ffffffffh			;move out a dword to the screen
	and	[edi],eax
	cmp	buttonsave,0
	jz	buttonjump2WW
	xor	eax,0ffffffffh
	or	[edi],eax
buttonjump2WW:

	mov	eax,32				;add some stuff it is
	sub	eax,ecx 			;the when next byte
	sub	ebp,eax
	add	buttonstartsave,eax
	add	edi,4
	jmp	filllineloop1WW

endfillloop1WW:

	shl	buttonplane,1
	mov	eax,sizex
	add	buttonedisave,eax
	pop	ecx
	loop	filllineloop2WW
	popad
	ret
ButtonUpDownMem Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			      Button up down mem 2
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;	 SizeX = size in x
;	 ButtonX1 = Target x1
;	 ButtonY1 = Target y1
;	 ButtonX2 = Target x2
;	 ButtonY2 = Target y2
;	       Bl = (1=Up 0=Down)
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;SizeX_2	   dd	   0
;SizeX2_2	   dd	   0
ButtonUpDownMem2 Proc	 Near
	pushad

	xor	bl,1
	mov	buttonC1,4
	mov	buttonC2,3

	mov	eax,sizex
	shl	eax,2
	mov	sizex2,eax

	cmp	bl,1
	jz	noflipphere2_2
	mov	al,buttonC1
	xchg	al,buttonC2
	mov	buttonC1,al
noflipphere2_2:

	mov	edi,pcxbuffer			;set edi
	cmp	ButtonNewOffset,0
	jz	SkippaNewOffset2
	mov	edi,ButtonNewOffset
SkippaNewOffset2:
	mov	ButtonNewOffset,0
	mov	eax,buttony1
	mov	ebx,sizeX
	mul	ebx
	shl	eax,2
	mov	ebx,buttonx1
	add	edi,eax

	call	mouseoff

	mov	eax,buttonx1			;fill first line
	mov	buttonxstart,eax
	mov	eax,buttonx2
	mov	buttonxend,eax
	movzx	eax,buttonC1
	mov	linecolor,eax
	call	filllinebutton2_2
	add	edi,sizeX2

	mov	eax,buttonx1			;fill second line
	mov	buttonxstart,eax
	mov	eax,buttonx2
	dec	eax
	mov	buttonxend,eax
	movzx	eax,buttonC1
	mov	linecolor,eax
	call	filllinebutton2_2

	mov	eax,buttonx2			;fill second line a dot
	mov	buttonxstart,eax
	mov	buttonxend,eax
	movzx	eax,buttonC2
	mov	linecolor,eax
	call	filllinebutton2_2
	add	edi,sizeX2

						;fill line down
			 ;------------------------------------
	push	edi
	mov	ebp,buttony2
	sub	ebp,buttony1
	sub	ebp,3
	mov	eax,buttonx1
	mov	ebx,eax
	shr	eax,3
	add	edi,eax
	and	ebx,7
	mov	cx,15
	sub	cx,bx
	mov	ax,0ffffh
	btr	ax,cx
	dec	cx
	btr	ax,cx
	ror	ax,8
	mov	bx,ax
	xor	bx,0ffffh
	mov	ecx,4
	xor	si,si
lineplanedown1_2:
	push	ecx
	push	edi

	movzx	dx,buttonc1
	bt	dx,si
	jc	loooop2_2

	mov	edx,sizex
	shl	edx,2
	mov	ecx,ebp
lineloopa_2:
	and	[edi],ax
	add	edi,edx
	loop	lineloopa_2
	jmp	aftertheloopa_2
loooop2_2:
	mov	edx,sizex
	shl	edx,2
	mov	ecx,ebp
lineloopa2_2:
	and	[edi],ax
	or	[edi],bx
	add	edi,edx
	loop	lineloopa2_2
aftertheloopa_2:

	pop	edi
	pop	ecx
	add	edi,sizex
	inc	si
	loop	lineplanedown1_2
	pop	edi
			 ;------------------------------------
	push	edi
	mov	ebp,buttony2
	sub	ebp,buttony1
	sub	ebp,3
	mov	eax,buttonx2
	dec	eax
	mov	ebx,eax
	shr	eax,3
	add	edi,eax
	and	ebx,7
	mov	cx,15
	sub	cx,bx
	mov	ax,0ffffh
	btr	ax,cx
	dec	cx
	btr	ax,cx
	ror	ax,8
	mov	bx,ax
	xor	bx,0ffffh
	mov	ecx,4
	xor	si,si
lineplanedown1___2:
	push	ecx
	push	edi

	movzx	dx,buttonc2
	bt	dx,si
	jc	loooop2___2

	mov	edx,sizex
	shl	edx,2
	mov	ecx,ebp
lineloopa___2:
	and	[edi],ax
	add	edi,edx
	loop	lineloopa___2
	jmp	aftertheloopa___2
loooop2___2:
	mov	edx,sizex
	shl	edx,2
	mov	ecx,ebp
lineloopa2___2:
	and	[edi],ax
	or	[edi],bx
	add	edi,edx
	loop	lineloopa2___2
aftertheloopa___2:

	pop	edi
	pop	ecx
	add	edi,sizex
	inc	si
	loop	lineplanedown1___2
	pop	edi


	mov	eax,buttony2
	sub	eax,buttony1
	sub	eax,3
	mov	ebx,sizex2
	mul	ebx
	add	edi,eax

			 ;------------------------------------

	mov	eax,buttonx1			;fill second from end dot
	mov	buttonxstart,eax
	mov	buttonxend,eax
	movzx	eax,buttonC1
	mov	linecolor,eax
	call	filllinebutton2_2

	mov	eax,buttonx1			;fill second from end line
	inc	eax
	mov	buttonxstart,eax
	mov	eax,buttonx2
	mov	buttonxend,eax
	movzx	eax,buttonC2
	mov	linecolor,eax
	call	filllinebutton2_2
	add	edi,sizex2

	mov	eax,buttonx1			;fill end line
	mov	buttonxstart,eax
	mov	eax,buttonx2
	mov	buttonxend,eax
	movzx	eax,buttonC2
	mov	linecolor,eax
	call	filllinebutton2_2

	call	mouseon
	popad
	ret


;	ButtonXstart = X start
;	  ButtonXend = X end
;	   LineColor = line color
;		 edi = filloffset (only y)
FillLineButton2_2:
	pushad
	mov	eax,buttonxstart		;Prepare edi
	shr	eax,5
	shl	eax,2
	add	edi,eax
	mov	buttonedisave,edi

	mov	buttonplane,1

	mov	ecx,4
Filllineloop2WW_2:
	push	ecx

	mov	edi,buttonedisave		;restore edi

	mov	eax,buttonplane 		;choose bitplane
	mov	ebx,eax
	mov	ecx,linecolor
	and	ebx,ecx
	mov	buttonsave,ebx
	shl	eax,8

	mov	ebp,buttonxend
	sub	ebp,buttonxstart
	inc	ebp
	mov	eax,buttonxstart
	mov	buttonstartsave,eax
Filllineloop1WW_2:

	mov	ecx,buttonstartsave		;fix the first dword
	and	ecx,31
	mov	eax,0ffffffffh
	shr	eax,cl

	mov	ebx,ebp 			;check if shorter then 32 pix
	add	ebx,ecx
	cmp	ebx,32
	ja	morefillnowWW_2

	mov	ecx,32				;fix of on the right
	sub	ecx,ebx 			;if just one dword
	mov	ebx,0ffffffffh
	shl	ebx,cl
	and	eax,ebx
	ror	ax,8
	ror	eax,16
	ror	ax,8
	xor	eax,0ffffffffh			;move out a dword to the screen
	and	[edi],eax
	cmp	buttonsave,0
	jz	buttonjump1WW_2
	xor	eax,0ffffffffh
	or	[edi],eax
buttonjump1WW_2:
	jmp	endfillloop1WW_2

morefillnowWW_2:
	ror	ax,8
	ror	eax,16
	ror	ax,8
	xor	eax,0ffffffffh			;move out a dword to the screen
	and	[edi],eax
	cmp	buttonsave,0
	jz	buttonjump2WW_2
	xor	eax,0ffffffffh
	or	[edi],eax
buttonjump2WW_2:

	mov	eax,32				;add some stuff it is
	sub	eax,ecx 			;the when next byte
	sub	ebp,eax
	add	buttonstartsave,eax
	add	edi,4
	jmp	filllineloop1WW_2

endfillloop1WW_2:

	shl	buttonplane,1
	mov	eax,sizex
	add	buttonedisave,eax
	pop	ecx
	loop	filllineloop2WW
	popad
	ret
ButtonUpDownMem2 Endp


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Fix dragbar
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Draggasize	dd	0
Draggapos	dd	0
XXold		dd     -1
YYold		dd     -1
dragbarmouse	dd	0
dragbarnumber	dd	0
dragbarspecial	db	0
dragbarcount	dd	0
dragbarselect	dd     -1
justcleared	db	25	dup(0)
FixDragbar	proc	near
	cmp	markstartx,-1
	jz	jepps
	ret
jepps:
	pushad
	cmp	pegsmoving,0
	jnz	quittadragbar
	cmp	pullmode,0
	jnz	quittadragbar
	cmp	mouseB,0
	jnz	skolastiken
	mov	dragbarmouse,0
skolastiken:

	mov	dragbarcount,0
	lea	ebp,dragbardata
NextDragbar:
	mov	eax,dragbarcount
	cmp	[eax+DragBarStatus],0
	jz	EndDragbar

	cmp	UdragStatus,0
	jz	SkipChecken
	lea	eax,dragbardata
	cmp	eax,ebp
	jz	EndDragbar
SkipChecken:
;--------------------------------------------- Part0: Check if right
	mov	eax,[ebp+8*4]
	cmp	eax,-1
	jz	skippablaja1
	cmp	ax,menu_popup
	jnz	EndDragbar
skippablaja1:
	mov	eax,[ebp+9*4]
	cmp	eax,-1
	jz	skippablaja2
	cmp	sampleon,0
	jz	nomatter
	cmp	ax,4
	jz	enddragbar
	cmp	ax,5
	jz	enddragbar
nomatter:
	cmp	ax,menu_downscreen
	jnz	EndDragbar
skippablaja2:
	mov	eax,[ebp+10*4]
	cmp	eax,-1
	jz	skippablaja3
	cmp	ax,menu_upperscreen
	jnz	EndDragbar
skippablaja3:
	mov	eax,[ebp+11*4]
	cmp	eax,-1
	jz	skippablaja4
	cmp	ax,menu_upperleft
	jnz	EndDragbar
skippablaja4:
;--------------------------------------------- Part 00: Clear if totalval = 0
	cmp	dword ptr [ebp+2*4],0
	jnz	NoZiroDrag
	mov	ebx,dragbarcount
	cmp	byte ptr [JustCleared+ebx],1
	jz	EndDragBar
	mov	byte ptr [JustCleared+ebx],1
	move	edi,0a0000h	;offset
	mov	eax,[ebp+5*4]
	mov	ebx,80
	mul	ebx
	mov	ebx,[ebp+4*4]
	shr	ebx,3
	add	eax,ebx
	add	edi,eax

	call	mouseoff
	planewrite 00001000b
	xor	eax,eax
	mov	ecx,[ebp+7*4]
ZiroFixLoop1:
	push	ecx
	mov	ecx,[ebp+6*4]
	shr	ecx,3
	mov	edx,80
	sub	edx,ecx
	rep	stosb
	add	edi,edx
	pop	ecx
	loop	ZiroFixLoop1
	call	mouseon

	jmp	EndDragbar
NoZiroDrag:
	mov	ebx,dragbarcount
	mov	byte ptr [JustCleared+ebx],0

;--------------------------------------------- Part1: Check mouse
	mov	eax,dragbarselect
	cmp	eax,-1
	jz	dragdontcare
	cmp	eax,dragbarcount
	jnz	aftercheckdragbar
dragdontcare:
	cmp	dragbarspecial,1
	jz	aftercheckdragbar
	cmp	dword ptr [ebp+2*4],0
	jz	specialnone
	cmp	dword ptr [ebp+3*4],0
	jz	specialnone

	cmp	dragbarmouse,0
	jz	ollele
	cmp	ebp,dragbarnumber
	jz	skipchecka
ollele:
	cmp	mouseB,0
	jz	aftercheckdragbar
				    ;checka cords
	mov	eax,[ebp+4*4]
	cmp	mouseX,ax
	jb	aftercheckdragbar
	add	eax,[ebp+6*4]
	cmp	mouseX,ax
	jae	aftercheckdragbar

	mov	eax,[ebp+5*4]
	cmp	mouseY,ax
	jb	aftercheckdragbar
	add	eax,[ebp+7*4]
	cmp	mouseY,ax
	jae	aftercheckdragbar

	mov	dragbarmouse,1
	mov	dragbarnumber,ebp
skipchecka:

	movzx	eax,mouseX
	movzx	ebx,mouseY
	cmp	eax,XXold
	jnz	lolla
	cmp	ebx,YYold
	jz	aftercheckdragbar
lolla:
	mov	XXold,eax
	mov	YYold,ebx

	mov	eax,[ebp+3*4]
	mov	ebx,[ebp+6*4]
	mul	ebx
	mov	ebx,[ebp+2*4]
	div	ebx
	mov	edi,eax
	mov	esi,eax
	shr	edi,1

	mov	ebx,[ebp+2*4]
	sub	ebx,[ebp+3*4]
	inc	ebx
	movzx	eax,mouseX
	sub	eax,[ebp+4*4]
	sub	eax,edi
	cmp	eax,0
	jge	nosettoziro
	mov	eax,0
nosettoziro:
	mul	ebx
	mov	ebx,[ebp+6*4]
	sub	ebx,esi
	cmp	ebx,0
	jg	nosettoziro2
	mov	ebx,1
nosettoziro2:
	div	ebx

	mov	ebx,[ebp+2*4]
	sub	ebx,[ebp+3*4]
	cmp	eax,ebx
	jbe	skipsettaslasslo
	mov	eax,ebx
skipsettaslasslo:

	mov	[ebp],eax
	mov	dword ptr [ebp+4],1
	call	dword ptr [ebp+12*4]

	mov	eax,dragbarcount
	mov	dragbarselect,eax
Aftercheckdragbar:
;--------------------------------------------- Part2: Fixdragbar data
	cmp	dword ptr [ebp+4],0
	jz	enddragbar
	mov	dword ptr [ebp+4],0

	mov	eax,[ebp+3*4]
	mov	ebx,[ebp+6*4]
	mul	ebx
	mov	ebx,[ebp+2*4]
	div	ebx
	cmp	eax,1
	jge	nononononono
	mov	eax,1
nononononono:
	mov	draggasize,eax

	mov	eax,[ebp]
	mov	ebx,[ebp+6*4]
	mul	ebx
	mov	ebx,[ebp+2*4]
	div	ebx
	mov	draggapos,eax
;--------------------------------------------- Part3: Update dragbar

	mov	eax,[ebp+4*4]
	mov	MouseX1,ax
	add	eax,[ebp+6*4]
	mov	MouseX2,ax
	mov	eax,[ebp+5*4]
	mov	MouseY1,ax
	add	eax,[ebp+7*4]
	mov	MouseY2,ax
	call	mouseoff

	mov	ah,00001000b		;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax

	move	edi,0a0000h
	mov	eax,[ebp+5*4]
	mov	ebx,80
	mul	ebx
	mov	ebx,[ebp+4*4]
	shr	ebx,3
	add	eax,ebx
	add	edi,eax

	mov	ecx,[ebp+7*4]
updatedragbarloop:
	push	ecx
	push	edi

;----------------------------- Normal fill
	mov	eax,draggapos
	cmp	eax,0
	jnz	vickan
	mov	ecx,0
	mov	edx,0
	jmp	ja_mera_mera
vickan:
	mov	ebx,8
	xor	edx,edx
	div	ebx
	mov	ecx,eax
	xor	al,al
	rep	stosb
	mov	ecx,edx
ja_mera_mera:

	add	edx,draggasize
	cmp	edx,0
	jz	nextline
	cmp	edx,8
	ja	nosmallfill
;----------------------------- Small fill
	mov	al,0ffh
	shr	al,cl
	mov	ecx,8
	sub	ecx,edx
	shr	al,cl
	shl	al,cl
	stosb
	jmp	fillend
nosmallfill:
	mov	al,0ffh
	shr	al,cl
	stosb

	mov	eax,draggasize
	mov	edx,8
	sub	edx,ecx
	sub	eax,edx
	mov	ebx,8
	xor	edx,edx
	div	ebx
	mov	ecx,eax
	mov	al,0ffh
	rep	stosb
	cmp	edx,0
	jz	fillend
	mov	ecx,edx
	mov	al,0ffh
	shr	al,cl
	xor	al,0ffh
	stosb
fillend:
	mov	ebx,draggasize
	add	ebx,draggapos
	shr	ebx,3
	cmp	edx,0
	jz	nooja
	inc	ebx
nooja:
	mov	ecx,[ebp+6*4]
	shr	ecx,3
	sub	ecx,ebx
	cmp	ecx,0
	jle	norep
	xor	al,al
	rep	stosb
norep:
;-----------------------------
nextline:
	pop	edi
	add	edi,80
	pop	ecx
	loop	updatedragbarloop

	call	mouseon
	call	MouseReset

;--------------------------------------------- End Dragbar
EndDragbar:

	add	ebp,52
	inc	dragbarcount
	cmp	dword ptr [ebp],-100
	jnz	nextdragbar
QuitFixdragbar:
	popad
	ret
;--------------------------------------------- Specialnone
specialnone:
	mov	eax,[ebp+4*4]
	mov	MouseX1,ax
	add	eax,[ebp+6*4]
	mov	MouseX2,ax
	mov	eax,[ebp+5*4]
	mov	MouseY1,ax
	add	eax,[ebp+7*4]
	mov	MouseY2,ax
	call	mouseoff

	mov	ah,00001000b		;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax

	move	edi,0a0000h
	mov	eax,[ebp+5*4]
	mov	ebx,80
	mul	ebx
	mov	ebx,[ebp+4*4]
	shr	ebx,3
	add	eax,ebx
	add	edi,eax

	mov	ecx,[ebp+7*4]
updatedragbarloop2:
	push	ecx
	push	edi
	mov	ecx,[ebp+6*4]
	shr	ecx,3
	xor	al,al
	rep	stosb
	pop	edi
	add	edi,80
	pop	ecx
	loop	updatedragbarloop2

	call	mouseon
	call	MouseReset
	jmp	enddragbar
quittadragbar:
	popad
	ret
FixDragbar	endp



;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls: EAX = Size Wanted
;Ret:	CY=1 if error
;	EAX = New Memptr
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MemoryFree	dd	0		;Total Free Memory (even fragmented)
FreeTable	dd	160 dup(0)	;Increase )?(
TableSize	equ	80		;Size of FreeTable
DidCompress	db	0		;set to 1 if a compress occured
Allocate	Proc	Near
	Pushad
	bt	ax,0
	adc	eax,0
	mov	ecx,TableSize
	lea	edi,FreeTable+4
SearchFree:
	cmp	[edi],eax
	jae	GotArea
	add	edi,8
	loop	SearchFree
	popad
	stc
	ret
GotArea:
	mov	ebx,[edi-4]
	sub	MemoryFree,eax
	sub	[edi],eax
	jnz	NotZeroAga
	mov	Dword Ptr [edi-4],0
	call	OptimizeTable
	call	SortTable
	mov	[esp+28],ebx
	Popad
	clc
	Ret

NotZeroAga:
	add	[edi-4],eax
	call	SortTable
	mov	[esp+28],ebx
	Popad
	clc
	Ret
Allocate	EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls: EAX = Size to Disalloc
;	ESI = Offset to Disalloc
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Disallocate	Proc	Near
	Pushad
	bt	ax,0
	adc	eax,0

	lea	edi,FreeTable-8
	mov	ecx,TableSize
SearchEnd:
	add	edi,8
	cmp	Dword ptr [edi],0
	jnz	Nofisk
	cmp	Dword ptr [edi+4],0	;This IS Correct!
Nofisk:
	loopnz	SearchEnd
	jnz	ErrorEnd		;Table too small!
	mov	[edi],esi
	mov	[edi+4],eax
	add	MemoryFree,eax
	call	SortTable
	clc
	Popad
CompressAgain:
	mov	DidCompress,0
	call	CompressTable
	cmp	DidCompress,1
	jz	CompressAgain
	call	OptimizeTable
	call	SortTable
	Ret
ErrorEnd:
	call	sara5	;4
	stc
	Popad
	Ret
Disallocate	EndP

Sara5	Proc	Near
	Pushad
	pushf
	mov	dx,3c8h
	xor	al,al
	out	dx,al
	inc	dx
	xor	al,al
	out	dx,al
	out	dx,al
	mov	al,63
	out	dx,al
	popf
	Popad
	Ret
Sara5	EndP

SortTable	Proc	Near			;Sort table
	Pushad
	lea	edi,FreeTable+4
	mov	esi,edi
	mov	ecx,TableSize
	dec	ecx
	mov	ebp,ecx
BigLoopen:
	push	ecx
	push	edi
	push	esi
	mov	ecx,ebp
	mov	eax,[edi]
SmallLoopen:
	add	esi,8
	cmp	[esi],eax
	jae	NoSwap
	cmp	dword ptr [esi],0
	jz	NoSwap
	mov	ebx,[edi]
	xchg	ebx,[esi]
	mov	[edi],ebx
	mov	eax,ebx
	mov	ebx,[edi-4]
	xchg	ebx,[esi-4]
	mov	[edi-4],ebx
NoSwap:
	loop	SmallLoopen
	pop	esi
	pop	edi
	pop	ecx
	dec	ebp
	add	esi,8
	add	edi,8
	loop	BigLoopen


	Popad
	Ret
SortTable	EndP

CompressTable	    Proc    Near		;Check Near areas
	Pushad
	mov	ecx,TableSize
	lea	edi,FreeTable
CompLoop:
	lea	esi,FreeTable
	push	ecx
	mov	eax,[edi]
	add	eax,[edi+4]
	mov	ecx,TableSize
CompLoop2:
	push	ecx
	cmp	eax,[esi]
	jnz	DontCompress
	cmp	eax,0
	jz	DontCompress
	mov	DidCompress,1
	mov	eax,[edi+4]
	add	eax,[esi+4]
	mov	[edi+4],eax
	mov	Dword Ptr [esi],0
	mov	Dword Ptr [esi+4],0
	pop	ecx
	jmp	QuitFirst
DontCompress:
	pop	ecx
	add	esi,8
	loop	CompLoop2
QuitFirst:
	pop	ecx
	add	edi,8
	loop	CompLoop
	Popad
	Ret
CompressTable	    EndP

OptimizeTable	Proc	Near			;Remove empty space
	Pushad
	lea	edi,FreeTable
	mov	ecx,TableSize

OptimTable:
	cmp	Dword ptr [edi],0
	jnz	NoSlisk
	cmp	Dword ptr [edi+4],0
	jnz	NoSlisk
	push	ecx edi
	dec	ecx
	shl	ecx,1
	mov	esi,edi
	add	esi,8
	rep	movsd
	mov	dword ptr [edi],0
	mov	dword ptr [edi+4],0
	pop	edi ecx
	sub	edi,8
NoSlisk:
	add	edi,8
	loop	OptimTable

	Popad
	Ret
OptimizeTable	EndP



;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			   Memory Allocation Routine
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;Calls:
;	EBP=Pointer nr
;	EAX=New mem size
;	EBX=1 to Clear new memory area
;Ret:
;	CF=0 - Allocation went fine
;	  EAX=Ptr to new location
;	CF=1 - Error
;	  EAX=?
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


;AllocTable	dd	1053*2 dup(0)	;BufferPtr | Buffer size
ClearBuffer	db	0
NewSize 	dd	0
ReOrg		db	0		;If mem reorganized

MemAlloc	Proc	Near
	cmp	eax,0
	jz	MemDisalloc
	pushad
	cld
	mov	ReOrg,0
	mov	ClearBuffer,bl
	mov	NewSize,eax
	call	SaveAllocBuffer

	cmp	[AllocTable+ebp*8+4],0
	jz	EmptyBuffer

	mov	esi,MemoryFree
	add	esi,[AllocTable+ebp*8+4]	;Total free mem
	cmp	esi,eax
	jb	ImVerySorry;NotEnoughHiMem

TryAllocAgain:
	mov	esi,[AllocTable+ebp*8]
	mov	eax,[AllocTable+ebp*8+4]
	call	Disallocate
EmptyBuffer:
	mov	eax,NewSize
	call	Allocate
	jc	NoMemAvailable
	mov	edi,eax 			;New Ptr

	mov	ecx,NewSize
	cmp	ecx,[AllocTable+ebp*8+4]
	jb	SmallestSize
	mov	ecx,[AllocTable+ebp*8+4]
SmallestSize:
	mov	esi,[AllocTable+ebp*8]		;Old Ptr
	mov	[AllocTable+ebp*8],edi		;New Ptr
	mov	eax,NewSize
	mov	[AllocTable+ebp*8+4],eax	;New Size

	cmp	edi,esi 			;Move mem to new location
	jz	DontMoveChunk
	push	ecx edi
	shr	ecx,1
	rep	movsw
	adc	ecx,0
	rep	movsb
	pop	edi ecx
DontMoveChunk:

	cmp	ClearBuffer,1
	jnz	DontClearChunk

	add	edi,ecx
	mov	eax,NewSize
	sub	eax,ecx
	mov	ecx,eax
	xor	ax,ax
	shr	ecx,1
	rep	stosw
	adc	ecx,0
	rep	stosb
DontClearChunk:
;	call	InitAllocStuff

	mov	eax,[AllocTable+ebp*8]
	mov	[esp+28],eax
	popad
	clc
	ret
NoMemAvailable:
	call	RestoreAllocBuffer
	cmp	ReOrg,1
	jz	ImVerySorry
	push	eax
	push	ecx
	mov	ah,ClearBuffer
	mov	ecx,NewSize
	call	MemReorganize
	mov	ClearBuffer,ah
	mov	NewSize,ecx
	pop	ecx
	pop	eax
	call	SaveAllocBuffer


	mov	ReOrg,1
	jmp	TryAllocAgain
ImVerySorry:
;	call	InitAllocStuff
	sti

;	lea	esi,HiMemError
;	mov	Menu_Popup,1
;	call	PopUpHandler

	popad
	stc
	ret
MemAlloc	EndP


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			  Memory Disallocation Routine
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;Calls:
;	EBP=Pointer nr
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MemDisalloc	Proc	Near
	pushad

	cmp	[AllocTable+ebp*8],0
	jnz	DoTheDisalloc
	cmp	[AllocTable+ebp*8+4],0
	jnz	DoTheDisalloc
	clc
	popad
	ret

DoTheDisalloc:

	mov	esi,[AllocTable+ebp*8]
	mov	eax,[AllocTable+ebp*8+4]
	call	Disallocate
	mov	[AllocTable+ebp*8],0
	mov	[AllocTable+ebp*8+4],0

	clc
	popad
	ret
MemDisalloc	EndP



FreeTable2	dd	160 dup(0)	;Increase )?(
FreeTable3	dd	160 dup(0)	;Increase )?(
Reorganizing	db	0
MemReorganize	Proc	Near
	pushad
	call	MouseHourGlass
	mov	Reorganizing,1
OrganizeAgain:
	lea	esi,FreeTable
	lea	edi,FreeTable2
	mov	ecx,TableSize
	shl	ecx,1
	rep	movsd
	call	SortTable2			;Sort Freetable

	mov	edx,[FreeTable2]
	add	edx,[FreeTable2+4]

	xor	ebp,ebp
	mov	ecx,1053
SearchOffsLoop:
	cmp	[AllocTable+ebp*8],edx
	jz	FoundOffset
	inc	ebp
	loop	SearchOffsLoop
	cmp	SoundCard,1			;GUS
	jz	MemoryOrganized
	cmp	SoundCard,5			;MAX
	jz	MemoryOrganized
	cmp	SoundCard,6			;MAX
	jz	MemoryOrganized

	mov	ebp,16
	mov	ecx,4096-16
SearchOffsLoop2:
	mov	eax,[SampleOffsetStart+ebp*4]	;In samples
;--..--
	push	ecx
	mov	cl,[VoiceControl+ebp]
	bt	cx,2
	setc	cl
	shl	eax,cl
	pop	ecx
;--..--
	cmp	eax,edx
	jz	FoundOffset2
	inc	ebp
	loop	SearchOffsLoop2
	jmp	MemoryOrganized

FoundOffset2:
	mov	eax,[SampleOffsetEnd+ebp*4]
	mov	esi,[SampleOffsetStart+ebp*4]
	sub	eax,esi
	push	eax
;--..--
	push	ecx
	mov	cl,[VoiceControl+ebp]
	bt	cx,2
	setc	cl
	shl	eax,cl		;Length in bytes
	shl	esi,cl		;Offset in bytes
	pop	ecx
;--..--
	mov	[AllocTable+1042*8],esi
	mov	[AllocTable+1042*8+4],eax
	pop	eax
	push	CurrentSample
	mov	CurrentSample,bp
	call	AllocSample
;	jnc	NoREOErr
;	call	FixAllocSampleError
;NoREOErr:
	pop	CurrentSample

	mov	esi,[SampleOffsetStart+ebp*4]	;old
	mov	edi,SampleOffsetMem
	mov	[SampleOffsetStart+ebp*4],edi
	sub	[SampleOffsetEnd+ebp*4],esi
	add	[SampleOffsetEnd+ebp*4],edi
	sub	[LoopStart+ebp*4],esi
	add	[LoopStart+ebp*4],edi
	sub	[LoopEnd+ebp*4],esi
	add	[LoopEnd+ebp*4],edi
	jmp	OrganizeAgain

FoundOffset:
	mov	eax,[AllocTable+ebp*8+4]
	xor	ebx,ebx
	call	MemAlloc
	jmp	OrganizeAgain
MemoryOrganized:

	call	InitAllocStuff

	movzx	ebx,CurrPatt2
	mov	eax,[AllocTable+ebx*4]
	cmp	eax,0
	jnz	@@NoEmpty
	mov	eax,EmptyPattern
@@NoEmpty:
	add	eax,12
	mov	PatternStart,eax
	mov	Reorganizing,0

	call	MouseArrow
	popad
	ret
MemReorganize	EndP

InitAllocStuff	Proc	Near
	pushad
	mov	eax,[AllocTable+1024*8]
	mov	SampMainOffset,eax
	mov	eax,[AllocTable+1025*8]
	mov	UndoBufferOffset,eax
	mov	UndoBaff,eax
	mov	eax,[AllocTable+1026*8]
	mov	ClipBoardOffset,eax
	mov	ClipBaff,eax
	mov	eax,[AllocTable+1028*8]
	mov	SampleNamesPtr,eax
	mov	eax,[AllocTable+1029*8]
	mov	InstNamesPtr,eax
	mov	eax,[AllocTable+1030*8]
	mov	PatternOrderPtr,eax
	mov	eax,[AllocTable+1031*8]
	mov	FileListPtr,eax
	mov	eax,[AllocTable+1032*8]
	mov	TempPattern,eax
	mov	eax,[AllocTable+1033*8]
	mov	EmptyPattern,eax
	mov	eax,[AllocTable+1034*8]
	mov	InstrumentInfo,eax
	mov	eax,[AllocTable+1035*8]
	mov	HelpTextPtr,eax
	mov	eax,[AllocTable+1037*8]
	mov	TempBufferPtr,eax
	popad
	ret
InitAllocStuff	EndP

SaveMemoryFree	dd	0
SaveAllocBuffer:
	pushad
	lea	esi,FreeTable
	lea	edi,FreeTable3
	mov	ecx,TableSize
	shl	ecx,1
	rep	movsd
	mov	eax,MemoryFree
	mov	SaveMemoryFree,eax
	popad
	ret

RestoreAllocBuffer:
	pushad
	lea	edi,FreeTable
	lea	esi,FreeTable3
	mov	ecx,TableSize
	shl	ecx,1
	rep	movsd
	mov	eax,SaveMemoryFree
	mov	MemoryFree,eax
	popad
	ret

SortTable2	Proc	Near
	Pushad
	lea	edi,FreeTable2
	mov	esi,edi
	mov	ecx,TableSize
	dec	ecx
	mov	ebp,ecx
BigLoopen2:
	push	ecx
	push	edi
	push	esi
	mov	ecx,ebp
	mov	eax,[edi]
SmallLoopen2:
	add	esi,8
	cmp	[esi],eax
	jae	NoSwap2
	cmp	dword ptr [esi],0
	jz	NoSwap2
	mov	ebx,[edi]
	xchg	ebx,[esi]
	mov	[edi],ebx
	mov	eax,ebx
	mov	ebx,[edi+4]
	xchg	ebx,[esi+4]
	mov	[edi+4],ebx
NoSwap2:
	loop	SmallLoopen2
	pop	esi
	pop	edi
	pop	ecx
	dec	ebp
	add	esi,8
	add	edi,8
	loop	BigLoopen2


	Popad
	Ret
SortTable2	EndP

IncreasePatternLength:
	call	fixbutton
	call	CheckPatternStart_Edit
	mov	eax,CurrPattLength
	inc	eax
	mov	TempDword,eax
	cmp	eax,257
	jnz	FixPatternLength
	ret

DecreasePatternLength:
	call	fixbutton
	call	CheckPatternStart_Edit
	mov	eax,CurrPattLength
	dec	eax
	mov	TempDword,eax
	jg	FixPatternLength
	ret

FixPatternLength:
	pushad
	call	MM_UnmarkBlock
	mov	ebx,TempDword
	mov	eax,ChRowSize
	mul	ebx
	add	eax,12
	movzx	ebp,CurrPatt2
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	ebx,TempDword
	mov	CurrPattLength,ebx
	dec	ebx
	mov	byte ptr [eax+10],bl
	mov	oldrow,-1
	mov	oldpatt2,-1
	mov	oldpatt,-1
	movzx	eax,CurrRow
	cmp	eax,CurrPattLength
	jb	CursorOnPatt
	mov	eax,CurrPattLength
	dec	eax
	mov	CurrRow,ax
CursorOnPatt:
	movzx	ebx,CurrPatt2
	call	PattInit
	popad
	ret

OldChannels	db	0
OldRowSize	dd	0
OldChRowSize	dd	0
CopySize	db	0
AllocNumber	dd	0


;ebx=alloc number
FixPatternWidth2:
	pushad

	call	MM_UnmarkBlock
	mov	AllocNumber,ebx
	jmp	FixPatternWidth3

FixPatternWidth:
	pushad

	call	MM_UnmarkBlock
	movzx	ebx,CurrPatt2
	mov	AllocNumber,ebx
FixPatternWidth3:
	mov	esi,[AllocTable+ebx*8]
	mov	ecx,[AllocTable+ebx*8+4]
	mov	edi,GUS_TempBuffPtr

	push	edi esi ecx
	shr	ecx,1
	jnc	Ulo
	movsb
Ulo:
	rep	movsw
	pop	ecx edi esi		;XCHG esi,edi

	push	esi edi
	add	edi,12
	sub	ecx,12
	xor	al,al
	rep	stosb
	pop	edi esi

	mov	al,[esi+11]
	mov	ah,al
	and	al,31
	inc	al
	mov	OldChannels,al
	shr	ah,5

	movzx	ecx,al		;Get RowSize and ChRowSize
	movzx	eax,ah
	shl	eax,1
	add	eax,2
	mov	OldRowSize,eax
	mul	ecx
	mov	OldChRowSize,eax

	movzx	eax,TempChannels
	movzx	ebx,TempCommands
	call	GetRowSize2

	movzx	ebx,byte ptr [esi+10]
	inc	ebx
	mov	eax,ChRowSize
	mul	ebx
	add	eax,12
	mov	ebp,AllocNumber
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	edi,eax
	mov	bl,TempChannels
	mov	bh,TempCommands
	dec	bl
	shl	bh,5
	or	bl,bh
	mov	byte ptr [eax+11],bl

	mov	eax,OldRowSize
	cmp	eax,RowSize
	jb	SmallestRS
	mov	eax,RowSize
SmallestRS:
	mov	CopySize,al


	mov	al,TempChannels
	cmp	al,OldChannels
	ja	SmallestC
	mov	OldChannels,al
SmallestC:
	movzx	ecx,byte ptr [esi+10]
	inc	ecx
	add	esi,12
	add	edi,12
FixWNextRow:
	push	ecx
	push	esi edi

	movzx	ecx,OldChannels
FixWNextCh:
	push	ecx edi esi
	movzx	ecx,CopySize
	rep	movsb
	pop	esi edi ecx
	add	esi,OldRowSize
	add	edi,RowSize
	loop	FixWNextCh

	pop	edi esi
	add	esi,OldChRowSize
	add	edi,ChRowSize
	pop	ecx
	loop	FixWNextRow

	movzx	ebx,CurrPatt2
	call	PattInit
	call	FixAllocChannels
	popad
	ret

FlipUpperLeft:
	cmp	MouseB,2
	jnz	_ret
	mov	al,Original
	mov	RightKeyWait,al
	mov	ax,menu_upperleft
	inc	al
	cmp	al,4
	jb	NoWrapUpperLeft
	mov	al,0
NoWrapUpperLeft:
	cmp	al,1
	jnz	NotUL1
	call	PositionEditor2
	ret
NotUL1:
	mov	menu_upperleft,ax
	call	menuhandler
	mov	OldPos2,-1
	mov	OldPattName,-1
	call	PrintPattInfo
	call	UpdateSongCfgScreen
	ret


FlipLower:
	cmp	MouseB,2
	jnz	_ret
	mov	al,Original
	mov	RightKeyWait,al
	mov	ax,Menu_DownScreen
	inc	al
	cmp	al,8
	jb	NoWrapDownScreen
	mov	al,TrackerStyle
	jmp	NotD2
NoWrapDownScreen:
	cmp	al,4
	ja	NotD1
	mov	al,4
NotD1:
	cmp	al,5
	jnz	NotD2
	mov	al,6
NotD2:
	cmp	al,1
	jbe	EnvelopeEnd3
	cmp	al,4
	jz	SampleEditor2_
	cmp	al,6
	jz	DescriptionStart2
	cmp	al,7
	jz	EnvelopeStart2
	ret

;SampleEditorExit		;0/1
;SampleEditor2_ 		;4
;DescriptionStart2		;6
;EnvelopeStart2 		;7




HelpExit	Proc	Near
	pushad
	mov	menu_upperScreen,0
	call	menuhandler

	mov	ebp,1035
	call	MemDisAlloc

	popad
	ret
HelpExit	Endp


UpperTbl	dd	HelpExit,_ret,_ret,DiskOpStart2
FlipUpper:
	cmp	MouseB,2
	jnz	_ret
	mov	al,Original
	mov	RightKeyWait,al
	mov	ax,Menu_UpperScreen
	inc	al
	cmp	al,3
	jae	NoFUFix
	add	al,2
NoFUFix:
	cmp	al,3
	jbe	NoFUFix2
	mov	al,0
NoFUFix2:
	and	eax,0ffh
	shl	eax,2
	call	[UpperTbl+eax]
	ret

ife	release
PrintInstInfo	proc	near
	pushad
	move	edi,0a0000h+80*13
	movzx	eax,CurrentInstrument
	dec	eax
	mov	ebx,716
	mul	ebx
	mov	esi,InstrumentInfo
	add	esi,eax

	mov	ecx,4
W_SplitLoop:
	push	edi
	push	ecx
	mov	ecx,24
Q_SplitLoop:
	push	ecx
	lodsb
	movzx	ebx,al

	mov	ah,0fh
	mov	cl,2

	call	PutHex
	add	edi,3
	pop	ecx
	loop	Q_SplitLoop
	pop	ecx
	pop	edi
	add	edi,13*80
	loop	W_SplitLoop

	lodsw
	movzx	ebx,ax
	mov	ah,0fh
	mov	cl,4
	call	PutHex
	add	edi,5

	lodsb
	movzx	ebx,al
	mov	ah,0fh
	mov	cl,2
	call	PutHex
	add	edi,3

	lodsw
	movzx	ebx,ax
	mov	ah,0fh
	mov	cl,4
	call	PutHex

	add	edi,80*13-8

	mov	ecx,3
T_VolLoop:
	push	ecx

	mov	ecx,5
R_VolLoop:
	push	ecx
	lodsb
	movzx	ebx,al
	mov	ah,0fh
	mov	cl,2
	call	PutHex
	add	edi,3
	pop	ecx
	loop	R_VolLoop
	add	edi,80*13-15

	mov	ecx,8
W_VolLoop:
	push	edi
	push	ecx
	mov	ecx,24
Q_VolLoop:
	push	ecx
	lodsb
	movzx	ebx,al
	mov	ah,0fh
	mov	cl,2
	call	PutHex
	add	edi,3
	pop	ecx
	loop	Q_VolLoop
	pop	ecx
	pop	edi
	add	edi,13*80
	loop	W_VolLoop
	pop	ecx
	loop	T_VolLoop


	popad
	ret
PrintInstInfo	Endp
endif

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Puts a Decimal Value in DOS
;Calls:
;	 CL = Nr of Digits
;	EBX = Value to print
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PutDecimalDOS	Proc	Near
	pushad
	movzx	ecx,cl
	dec	ecx
	jecxz	OnlyOneDOS

	mov	eax,ebx
	mov	ebp,ecx
	mov	ebx,10
PutLoopDOS:
	xor	edx,edx
	div	ebx
	push	dx
	loop	PutLoopDOS
	movzx	edx,ax
	add	dx,30h
	mov	ah,2
	int	21h
	mov	ecx,ebp
GetLoopDOS:
	pop	dx
OnlyOne_1DOS:
	add	dx,30h
	mov	ah,2
	int	21h
	loop	GetLoopDOS

	mov	dl,','
	mov	ah,2
	int	21h

	popad
	Ret
OnlyOneDOS:
	mov	ecx,1
	jmp	OnlyOne_1DOS
PutDecimalDOS	EndP

ShowMainPattern:
	mov	menu_downscreen,1
	cmp	TrackerStyle,1
	jz	E_ScStyle2
	mov	menu_downscreen,0
E_ScStyle2:
	movzx	ax,Zoom
	shl	ax,1
	add	menu_downscreen,ax
	call	menuhandler
	cmp	PianoScreen,0
	jz	NoPoa
	call	MenuPiano
NoPoa:
	ret

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Show Popup text
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;	 eax = textoffset
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±'
ShowPopupText	Proc	Near
	pushad

	mov	showtextoffset,eax
	mov	menu_popup,12
	call	menuhandler

	popad
	ret
ShowPopupText	Endp


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				View Popup text
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±'
ShowTextoffset	dd	0

ViewPopupText:
	ret



;-----------------------------------------------------------------------------
;                       -+*+- Put Version Text -+*+-
;-----------------------------------------------------------------------------
PutVersionText proc near
	pushad
	lea	esi,PrgVersionText
;	mov	FontPlane,1
	mov	ah,1001b
	move	edi,0a0000h+80-20+80*3
	mov	cl,19
	call	printtext
;	mov	FontPlane,0
	popad
	ret
	endp


