

;/ABS\01438024170351900545017240048604753000010000101378

shl16		macro	bulle
		local	nosampbits
		cmp	sampbits,1
		jnz	nosampbits
		shl	bulle,1
nosampbits:
		endm

shr16		macro	bulle
		local	nosampbits2
		cmp	sampbits,1
		jnz	nosampbits2
		shr	bulle,1
nosampbits2:
		endm

shl16ef		macro	bulle
		local	nosampbits
		cmp	EffectBits,1
		jnz	nosampbits
		shl	bulle,1
nosampbits:
		endm

shr16ef		macro	bulle
		local	nosampbits2
		cmp	EffectBits,1
		jnz	nosampbits2
		shr	bulle,1
nosampbits2:
		endm



_rp	macro
	popad
	ret
	endm

bosse dd 0
olles db 0
olle  dd	0


LocalTable	Label 	Dword
		dd	ThePointUp
		dd	ThePointDown
		dd	ThePointUdrag
		dd	ThePointInput
		dd	SelectLoop
		dd	VoiceEnvPointUp
		dd	VoiceEnvPointDown
		dd	VoiceEnvPointUdrag
		dd	SetCurve0
		dd	SetCurve1
		dd	SetCurve2
		dd	TimeArrowUp
		dd	TimeArrowDown
		dd	TimeUdrag
		dd	EnvelopeArrowUp
		dd	EnvelopeArrowDown
		dd	EnvelopeUdrag
		dd	EnvLoopStartUp
		dd	EnvLoopStartDown
		dd	EnvLoopStartUdrag
		dd	LenLoopStartTextInput
		dd	EnvLoopendUp
		dd	EnvLoopEndDown
		dd	EnvLoopEndUdrag
		dd	LenLoopEndTextInput
		dd	EnvCurveArrowLeft
		dd	EnvCurveArrowRight
		dd	EnvCurveArrowUp
		dd	EnvCurveArrowDown
		dd	EnvCurveHorzZoomPlus
		dd	EnvCurveHorzZoomMinus
		dd	EnvCurveVertZoomPlus
		dd	EnvCurveVertZoomMinus
		dd	UpdateEnvCurveX
		dd	SelectEnvCurve
		dd	MasterCurveSelectFirst
		dd	SelectEnvCurveFirst
		dd	ShowMultiEffect
		dd 	ShowSingleEffect
		dd	ShowListEffect
		dd	ViewMasterCurve
		dd 	PutEnvelopeCurve
		dd	EffectApply
		dd	SetTimeVar
		dd	SetTimeInvar
		dd	VolFade1
		dd	VolFade2
		dd	VolFade3
		dd	VolFade4
		dd	VolFade5
		dd	VolFade6
		dd	EffectWaitCancel
		dd	EffectWaitCancel2
		dd	EffectAddMulti
		dd	thesampleend
		dd	SetTheNote
		dd	SetTheRate
		dd	VolLeft1
		dd	VolLeft2
		dd	VolRight1
		dd	VolRight2
		dd	SampleSetScopes
		dd	SampleSetEqualizer
		dd	SampStereo_Mono
		dd	Samp8_16Bits
		dd	SampleSetLinein
		dd	SampleSetMic
		dd	SampleSetCD
		dd	starttosamp
		dd	therateup
		dd	theratedown
		dd	rateinput
		dd	therateUdrag
		dd	CD_play
		dd	CD_pause
		dd	CD_stop
		dd	CD_rewback
		dd	CD_rewfwd
		dd	CD_skipback
		dd	CD_skipfwd
		dd	CD_openclose
		dd	JumpCDpos
		dd	SaveCDpos
		dd	ChangeCDtime
		dd	CD_volumeDown
		dd	CD_volumeUp
		dd	SampleCDsync
		dd	PeakClear
		dd	EndStartToSamp
		dd	StartTheSample
		dd	UpdateCDVol
		dd	UpdateInpVol
		dd	TheSampleEnd2
		dd	EndStartToSamp2
		dd	CD_INIT
		dd	PutEqualizers
		dd	PutScopes
		dd	CD_text
		dd	CDControl
		dd	InsertPeak
		dd	DrawSampling


EffText1	db	"Are you sure that you want@to save the effects?$"
EffText2	db	"Are you sure that you want@to delete the multieffect?$"
EffText3	db	"Do you want to save the change(s) on disk?$"
EffText4	db	"Type in the name of the multieffect.$"
EffText5	db	"Do you want to overwrite@current multieffect?$"
EffText6	db	"Do you want to delete the current effect?$"
EffText7	db	"Do you want to create a new effect@instead of overwriting current effect?$"
EffText8	db	"This effect won't be saved in the list,@continue anyway?$"
EffText9	db	"Changes not saved, exit anyway?$"

NowText		db	"You can't save effects in this demo version.@ Is that ok?$"

;to do:
; * 16 bits
; * smooth
; * time invariant
; * time compress c-4 ralated
; * real pitch c-4 ralated


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Effects code decription...
;
; (5)  word  Nr of voices
; (2)  byte  End status (0=End of samp length break,1=End of voice break)
; (3)  dword Voice break number or break samplength (% with 2 decimals)
; (7)  byte  Smooth (0=No,1= C-4 related length,2=Fixed length)
; (8)  word  Smooth length (2-65535)
; (10) byte  Time invariant speed.   0. Time variant
;				     1. After delay
;			             2. After pitch
;				     3. After volume
; (11) word  Time invariant voice nr.
;	   ** Code for each voice **
;	   .-.-.General.-.-.
;	   (0)  byte  Voice repeat on (0=off,1=on)
;	   (1)  byte  Reverb Kaos on (0=off,1=on)
;	   (2)	byte  Direction (0=Fwd,1=Bwd)
;	   (3)	word  Voice Offset (Procent with two decimals)
;	   (5)	byte  Time compress on (0=No,1= C-4 related length,2=Fixed length)
;	   (6)	word  Time compress: Readbyte(s) 1-65535
;	   (8)	word  Time compress: Skipbyte(s) 0-65535
;	   .-.-.Delay.-.-.
;	   (0)  dword Master delay (Micro seconds) (0 -> 350 000 000)
;	   (4)  byte  Loop on/off (0=off,1=on)
;   	   (5)  word  Loop start point
;	   (7)	word  Loop end point
;	   (9)	word  Nr of curve points
;	              ---- Curve Delay Code ----
;	              (0)  dword Timepos difference (Micro seconds)
;	              (4)  dword Relative delay (Micro seconds)
;	              (8)  byte  Curve type (0=Liner,1=Slow start,2=Slow end)
;	   .-.-.Pitch.-.-.
;	   (0)	dword Master pitch (Bromens negative,positive) (16b=1 note)
;						(-576 -> +576)
;	   (4)	byte  Real pitch on (0=off 1=Fixed length 2= C-4 related length)
;	   (5)	word  Pitch Buffser Size (in samples) 10-65535
;	   (7)  byte  Loop on/off (0=off,1=on)
;	   (8)	word  Loop start point
;	   (10) word  Loop end point
;	   (12) word  Nr of curve points
;	              ---- Curve Pitch Code ----
;	              (0)  dword Timepos difference (Micro seconds)
;	              (4)  dword Relative pitch (Bromens negative,positive)
;	              (8)  byte  Curve type (0=Liner,1=Slow start,2=Slow end,
;					    (3=Last dot)
;	   .-.-.Volume.-.-.
;	   (0)  dword Master Volume (procent with two decimals) (0 -> 60 000)
;	   (4)	byte  Loop on/off (0=off,1=on)
;	   (5)	word  Loop start point
;	   (7)	word  Loop end point
;	   (9)	word  Nr of curve points
;	              ---- Curve Volume Code ----
;	              (0)  dword Timepos difference (Micro seconds)
;	              (4)  dword Relative volume (procent with two decimals)
;	              (8)  byte  Curve type (0=Liner,1=Slow start,2=Slow end)


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;		              Multi Effects Engine
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: eax=Alloc nr to effecttable
;    	 ebx=Sample Frequency
;	 ecx=Sample Length
;	 edx=Samp bits (0=8bits,1=16bits)
;	 esi=Alloc nr to Source and target buffer
;	 edi=Offset for effecttable
;	 ebp=Alloc nr to Swap buffer
;	 EffectWaitPlane=Font plane when wait
;	 EffectBeforePlane=Font plane before wait
; Return:
;	 eax=New samp length
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

;Gus_TempBuffPtr:
MaxNumberOfVoices	equ	2500
Gus_VoiceEffectsPitchOffsets dd     0
Gus_VoiceEffectsPitchAdd     dd     MaxNumberOfVoices*1*4
Gus_DelayCurvepoint	     dd     MaxNumberOfVoices*3*4
Gus_PitchCurvepoint	     dd     MaxNumberOfVoices*4*4
Gus_VolumeCurvepoint	     dd     MaxNumberOfVoices*5*4
Gus_DelayTime		     dd     MaxNumberOfVoices*6*4
Gus_PitchTime		     dd     MaxNumberOfVoices*7*4
Gus_VolumeTime		     dd     MaxNumberOfVoices*8*4



;Init stuff
EffectTableOffset		dd	0
EffectTableNr			dd	0
EffectSourcerBuffer		dd	0
EffectSwapBuffer		dd	0
EffectSampleFrequency		dd	0
EffectSampLength		dd	0
EffectSampLengthOld		dd	0
BreakStatus			db	0
VoiceBreakNr			dd	0
EffectNextSampLength		dd	0
TimeInvariant			db	0
Effectbits	       		dd	0

;Effect tables
;VoiceEffectsPitchOffsets	 dd	 MaxNumberOfVoices     dup(0)
;VoiceEffectsPitchAdd		 dd	 MaxNumberOfVoices*2   dup(0)

;Effect switches
VoiceRepeatOn			db	0
ReverbKaosOn			db	0
EffectDirection 		db	0
TimeCon 			db	0
TimeCRead			dw	0
TimeCSkip			dw	0

;Voice changeing
RealPitchOn			db	0
PitchBuffer			dw	0

;Current changeing
CurrentVoice			dd	0
EffectSampCount 		dd	0
EffectVoiceDelay		dd	0
EffectMixValue			dd	0
EffectsNrOfVoices		dd	0

;Effect curve search
EffectLoopOnOff 		db	0
EffectLoopStart 		dw	0
EffectLoopEnd			dw	0
EffectLoopPoints		dw	0
EffectLastNum			dd	0
EffectExtraTime 		dd	0
EffectNr1a			dd	0
EffectNr2a			dd	0
EffectNr3a			db	0
EffectNr1b			dd	0
EffectNr2b			dd	0
EffectNr3b			db	0
EffectSave			dd	0
SearchTimeOffset		dd	0
SearchPointOffset		dd	0
CurveSearchForm 		db	0	;0=Digital delay
						;1=Pitch
						;2=Volume

						;digital smooth
SmoothStatus			db	0
SmoothLength			dw	0
TheRealSmoothLength		dd	0
SmoothStart			dd	0


TimeInvariantMaxTime		dd	0
TimeInvariantIndicate		db	0

;xxxxxxxxxxxxxxxx
MultiEffectsEngine	Proc	Near
	mov	olle,80
	pushad
	cmp	ecx,0
	jz	_retp

;Global fillscreen:Near
;	pushad
;	call	fillscreen
;	popad

	mov	EffectSampleFrequency,ebx
	mov	EffectSourcerBuffer,esi
	mov	EffectSwapBuffer,ebp
	mov	EffectTableNr,eax
	mov	EffectTableOffset,edi
	mov	EffectSampLength,ecx
	mov	EffectNextSampLength,ecx
	mov	EffectSampLengthOld,ecx
	mov	EffectBits,edx



;--------------------------------------------------- Scan next samplength ----
	mov	eax,EffectTableNr
	mov	esi,[eax*8+AllocTable]
	add	esi,EffectTableOffset
	cmp	byte ptr [esi+2],0
	jnz	AfterBreaken
	mov	eax,[esi+3]
	mov	ebx,EffectSampLength
	mul	ebx
	mov	ebx,10000
	div	ebx
	mov	EffectNextSampLength,eax
AfterBreaken:
;--------------------------------------------------- Smooth buffer = 0
	xor	eax,eax
	xor	ebx,ebx
	mov	ebp,1052
	call	memalloc
	jc	RemoveMemory

;*************************************************** 8 bits *****************

;--------------------------------------------------- Init Multi Effects -----
					;Time invartiant variabels
	pushad
	mov	TimeInvariantIndicate,0
	mov	ebx,EffectTableNr
	mov	esi,[AllocTable+ebx*8]
	add	esi,EffectTableOffset
 	cmp 	byte ptr [esi+10],0
	jz	noTimeInvariant

	mov	TimeInvariantIndicate,1
 	movzx	eax,word ptr [esi+11]
	movzx	ebx,byte ptr [esi+10]
	call	ScanEffect
	add	esi,11
	cmp	ebx,2
	jnz	noaddaskojja
	add	esi,3
Noaddaskojja:
 	xor	ebx,ebx
 	movzx	ecx,word ptr [esi-2]
TimeCounten:
	add	ebx,[esi]
	add	esi,9
	loop	TimeCounten
	cmp	ebx,0
	jnz	nozeroknulla
	mov	TimeInvariantIndicate,0
nozeroknulla:

	mov	TimeInvariantMaxTime,ebx
noTimeInvariant:
	popad
					;--------------------



	mov	edi,Gus_TempBuffPtr
	mov	eax,EffectTableNr
	mov	esi,[eax*8+AllocTable]
	add	esi,EffectTableOffset
	movzx	ecx,word ptr [esi]
	mov	EffectsNrOfVoices,eax
	mov	al,byte ptr [esi+2]
	mov	BreakStatus,al
	mov	eax,[esi+3]
	mov	VoiceBreakNr,eax
						;Digital smooth ----
	mov	al,byte ptr [esi+7]
	mov	SmoothStatus,al
	mov	ax,word ptr [esi+8]
	mov	SmoothLength,ax

	mov	al,byte ptr [esi+10]
	mov	TimeInvariant,al

	add	esi,13
ScanEffectsStartPos:
	push	ecx
	movzx	ebx,word ptr [esi+3]
	mov	eax,EffectSampLength
	dec	eax
	mul	ebx
	mov	ebx,10000
	div	ebx
	mov	dword ptr [edi],eax
	add	edi,4

	add	esi,21
	movzx	eax,word ptr [esi-2]
	lea	ebx,[eax*8+eax]
	add	esi,ebx
	add	esi,14
	movzx	eax,word ptr [esi-2]
	lea	ebx,[eax*8+eax]
	add	esi,ebx
	add	esi,11
	movzx	eax,word ptr [esi-2]
	lea	ebx,[eax*8+eax]
	add	esi,ebx
	pop	ecx
	loop	ScanEffectsStartPos

						;clear voice pitch buffer
	mov	edi,Gus_TempBuffPtr
	add	edi,Gus_VoiceEffectsPitchAdd
	xor	eax,eax
	mov	ecx,EffectsNrOfVoices
	shl	ecx,1
	rep	stosd
						;clear Curve points
	mov	edi,Gus_TempBuffPtr
	add	edi,Gus_DelayCurvePoint
	mov	ecx,EffectsNrOfVoices
	mov	eax,0 ;1
	rep	stosd
	mov	edi,Gus_TempBuffPtr
	add	edi,Gus_PitchCurvePoint
	mov	ecx,EffectsNrOfVoices
	mov	eax,0 ;1
	rep	stosd
	mov	edi,Gus_TempBuffPtr
	add	edi,Gus_VolumeCurvePoint
	mov	ecx,EffectsNrOfVoices
	mov	eax,0 ;1
	rep	stosd
						;clear curve times
	mov	edi,Gus_TempBuffPtr
	add	edi,Gus_DelayTime
	mov	ecx,EffectsNrOfVoices
	xor	eax,eax
	rep	stosd
	mov	edi,Gus_TempBuffPtr
	add	edi,Gus_PitchTime
	mov	ecx,EffectsNrOfVoices
	xor	eax,eax
	rep	stosd
	mov	edi,Gus_TempBuffPtr
	add	edi,Gus_VolumeTime
	mov	ecx,EffectsNrOfVoices
	xor	eax,eax
	rep	stosd

	mov	ebx,CurrentVoice
	shl	ebx,2
	add	eax,ebx
	add	eax,Gus_TempBuffPtr
	mov	ecx,eax
	add	eax,Gus_DelayTime
	mov	ebx,[eax]
	mov	EffectExtraTime,ebx


	cmp	Breakstatus,1			;Change Samp Length
	jz	nosampbreak
	cmp	TimeInvariantIndicate,1
	jz	nosampbreak
	mov	eax,VoiceBreakNr
	mov	ecx,EffectSampLength
	mul	ecx
	mov	ecx,10000
	div	ecx
	mov	ecx,eax
	mov	EffectSampLength,ecx
	jecxz	EndEffectNull
nosampbreak:
	mov	Onlyswap,1
	call	allocateeffect
	mov	Onlyswap,0

						;Clear swap buffer
	mov	eax,EffectSwapBuffer
	mov	edi,[eax*8+AllocTable]
	xor	ax,ax
	mov	ecx,EffectSampLength
	rep	stosw

;xxxxxxxxxxxxxxxx
;--------------------------------------------------- Init Multi Effects -----
	mov	EffectSampCount,0
	mov	ecx,EffectSampLength
	mov	eax,EffectSwapBuffer
	mov	edi,[eax*8+AllocTable]
SampleLoop:;---------------------------------------- Sample Loop Start ------
	push	ecx
	push	edi
	call	EffectWaitUpdate
	mov	EffectMixValue,0
	mov	eax,EffectTableNr
	mov	esi,[eax*8+AllocTable]
	add	esi,EffectTableOffset
	movzx	ecx,word ptr [esi]
	mov	EffectsNrOfVoices,ecx

	add	esi,13
	mov	CurrentVoice,0
VoiceLoop:;------------------------- Voice Loop Start --
	push	ecx
	mov	al,[esi]
	mov	VoiceRepeatOn,al
	mov	al,[esi+1]
	mov	ReverbKaosOn,al
	mov	al,[esi+2]
	mov	EffectDirection,al
	mov	al,[esi+5]
	mov	TimeCon,al
	movzx	eax,word ptr [esi+6]
	cmp	TimeCon,1
	jnz	NoC4relatedAA1
	push	ebx edx
	mov	ebx,EffectSampleFrequency
	mul	ebx
	mov	ebx,8363
	div	ebx
	pop	edx ebx
NoC4relatedAA1:
	mov	TimeCread,ax
	movzx	eax,word ptr [esi+8]
	cmp	TimeCon,1
	jnz	NoC4related2
	push	ebx edx
	mov	ebx,EffectSampleFrequency
	mul	ebx
	mov	ebx,8363
	div	ebx
	pop	edx ebx
NoC4related2:
	mov	TimeCskip,ax

	mov	ebx,[esi+10]			;Digital delay -----
	add	esi,14
	mov	CurveSearchForm,0
	call	EffectCurveSearch
	add	ebx,eax
	mov	eax,EffectSampleFrequency
	imul	ebx
	mov	ebx,1000000
	idiv	ebx
	mov	EffectVoiceDelay,eax
						;Pitch ----------
	mov	ebx,[esi]
	mov	al,[esi+4]
	mov	RealPitchOn,al
	mov	ax,[esi+5]
	mov	PitchBuffer,ax
	add	esi,7
	mov	CurveSearchForm,1
	call	EffectCurveSearch
	add	ebx,eax
	add	ebx,576
	cmp	ebx,0
	jge	noclip1_
	mov	ebx,0
noclip1_:
	cmp	ebx,576*2-1
	jle	noclip2_
	mov	ebx,576*2-1
noclip2_:
	mov	edx,[Pcxoffsets+9*4]
	mov	eax,[ebx*4+edx]     ;Bratable
	mov	edx,CurrentVoice
	mov	edi,Gus_TempBuffPtr

	push	ebx
	mov	ebx,Gus_TempBuffPtr
	add	ebx,Gus_VoiceEffectsPitchAdd
	add	dword ptr [edx*8+ebx],eax
	adc	dword ptr [edx*8+4+ebx],0
	pop	ebx

	cmp	RealPitchOn,0			;Real pitch -------
	jz	NoRealPitch_
	mov	eax,EffectSampCount
	movzx	ebx,PitchBuffer

	cmp	RealPitchOn,1
	jnz	noRelatedPitch
	push	eax edx
	mov	eax,ebx
	mov	ebx,EffectSampleFrequency
	mul	ebx
	mov	ebx,8363
	div	ebx
	mov	ebx,eax
	pop	edx eax
NoRelatedPitch:

	xor	edx,edx
	div	ebx
	cmp	edx,0
	jnz	NoRealPitch_
	call	SetSmoothCounter
	mov	eax,EffectSampCount
	mov	ebx,16384
	mul	ebx

	push	ebx
	mov	ebx,CurrentVoice
	shl	ebx,3
	add	ebx,Gus_TempBuffPtr
	add	ebx,Gus_VoiceEffectsPitchAdd
	mov	[ebx],eax
	mov	[ebx+4],edx
	pop	ebx
NoRealPitch_:
						;Get Sample now ------
	mov	edx,CurrentVoice	;Delay
	mov	eax,Gus_TempBuffPtr
	mov	ecx,[edx*4+eax]
	mov	eax,EffectVoiceDelay
	cmp	EffectDirection,0
	jz	JustForward
	neg	eax
JustForward:
	sub	ecx,eax
					;TimeCompress
;xxxxxxxxxxxxxxxx
	push	ebx
	cmp	TimeCon,0
	jz	NoTimeCompress_
	mov	eax,EffectSampCount
	cmp	eax,0
	jz	NoTimeCompress_
	movzx	ebx,TimeCread
	cmp	ebx,0
	jz	NoTimeCompress_
	xor	edx,edx
	div	ebx
	cmp	edx,0
	jnz	noknappen1
	cmp	EffectSampCount,0
	jz	noknappen1
	call	SetSmoothCounter
noknappen1:
	movzx	ebx,TimeCskip
	mul	ebx
	cmp	EffectDirection,0
	jz	JustFarrward2
	neg	eax
JustFarrward2:
	add	ecx,eax
NoTimeCompress_:
	pop	ebx
					;Pitch
	push	ecx
	mov	ecx,CurrentVoice
	shl	ecx,3
	add	ecx,Gus_TempBuffPtr
	add	ecx,Gus_VoiceEffectsPitchAdd
	mov	eax,[ecx]
	mov	ebx,[ecx+4]
	pop	ecx

	shrd	eax,ebx,14
	cmp	EffectDirection,0
	jz	JustForward2
	neg	eax
JustForward2:
	add	ecx,eax
ClipAgain:
	cmp	ecx,0			;clip botten
	jge	NoClipBotten
	cmp	BreakStatus,0	     ;voice break botten
	jz	NoVoiceBreak1
	cmp	EffectDirection,0
	jz	NoVoiceBreak1
	cmp	TimeInvariantIndicate,1
	jz	NoVoiceBreak1
	mov	eax,CurrentVoice
	cmp	eax,VoiceBreakNr
	jz	BreakVoiceEnd
NoVoiceBreak1:
	xor	eax,eax
	cmp	VoiceRepeatOn,0
	jz	AfterGetSample
	cmp	EffectDirection,0
	jz	AfterGetSample
	add	ecx,EffectSampLength
	jmp	ClipAgain
NoClipBotten:
	mov	ebx,EffectSampLengthOld    ;clip top
	dec	ebx
	cmp	ecx,ebx
	jle	GetTheSample
	cmp	BreakStatus,0	     ;voice break top
	jz	NoVoiceBreak2
	cmp	EffectDirection,1
	jz	NoVoiceBreak2
	mov	eax,CurrentVoice
	cmp	TimeInvariantIndicate,1
	jz	NoVoiceBreak2
	cmp	eax,VoiceBreakNr
	jz	BreakVoiceEnd
NoVoiceBreak2:
	xor	eax,eax
	cmp	VoiceRepeatOn,0
	jz	AfterGetSample
	cmp	EffectDirection,1
	jz	AfterGetSample
	sub	ecx,EffectSampLength
	jmp	NoClipBotten
GetTheSample:				;Get the sample
	cmp	ReverbKaosOn,1
	jz	KaosOn
	mov	eax,EffectSourcerBuffer

	cmp	effectbits,0
	jz	just8bits
	shl	ecx,1
	add	ecx,[eax*8+AllocTable]
	mov	bx,word ptr [ecx]
	add	bx,32768
	movsx	eax,bx
	jmp	AfterGetSample
just8bits:
	add	ecx,[eax*8+AllocTable]
	mov	bl,[ecx]
	add	bl,128
	movsx	eax,bl
	sal	eax,8
	jmp	AfterGetSample
KaosOn:
	shl	ecx,1
	mov	eax,EffectSwapBuffer
	add	ecx,[eax*8+AllocTable]
	movsx	eax,word ptr [ecx]
AfterGetSample:
						;Volume -------
	push	eax
	mov	ebx,[esi]
	add	esi,4
	mov	CurveSearchForm,2
	call	EffectCurveSearch
	add	ebx,eax
	pop	eax
	imul	ebx
	mov	ebx,150
	idiv	ebx
	add	EffectMixValue,eax

	inc	CurrentVoice
	pop	ecx
	loop	VoiceLoop;--------- Voice Loop End ----

	mov	eax,EffectMixValue
	cdq
	mov	ebx,100
	idiv	ebx
	mov	ebx,EffectsNrOfVoices
	cdq
	idiv	ebx
	pop	edi
	mov	[edi],ax
	add	edi,2
	inc	EffectSampCount

	;mov	 eax,EffectSampCount
	;mov	 EffectWait_Current,eax
	;call	 EffectWaitUpdate

	pop	ecx
	cmp	WaitStatus,1
	jz	PopAllRet
	loop	SampleLoop;------------------------- Sample Loop End --------
AfterSampLoopen:


	cmp	TimeInvariantIndicate,1
	jz	AfterVoiceBreak
	cmp	BreakStatus,1
	jnz	AfterVoiceBreak
	add	EffectSampLength,4096
	call	allocateeffect
	mov	eax,EffectSwapBuffer
	mov	edi,[eax*8+AllocTable]
	mov	eax,EffectSampCount
	shl	eax,1
	add	edi,eax
	mov	ecx,4096
	jmp	SampleLoop
BreakVoiceEnd:
	pop	ecx edi ecx
AfterVoiceBreak:
	mov	eax,EffectSampCount
	mov	EffectSampLength,eax
	call	allocateeffect

;--------------------------------------------------- Smooth in action --------
	mov	ebx,[alloctable+1051*8]
	cmp	byte ptr [ebx+7],0
	jz	DoNoSmooth
	cmp	[alloctable+1052*8+4],0
	jz	DoNoSmooth

	movzx	eax,word ptr [ebx+8]		;C-4 related
	mov	TheRealSmoothLength,eax
	cmp	byte ptr [ebx+7],1
	jnz	noC4Related
	mov	ebx,EffectSampleFrequency
	mul	ebx
	mov	ebx,8363
	div	ebx
	mov	TheRealSmoothLength,eax
noC4related:

	mov	eax,TheRealSmoothLength 	;clip
	shr	eax,1
	cmp	eax,EffectSampCount
	jbe	nopojkar1
	mov	eax,EffectSampCount
nopojkar1:
	mov	ebx,EffectSampLength
	sub	ebx,EffectSampCount
	dec	ebx
	cmp	eax,ebx
	jbe	nopojkar2
	mov	eax,ebx
nopojkar2:
	cmp	eax,0
	jle	_retp
	mov	TheRealSmoothLength,eax

	mov	eax,EffectSwapBuffer		;smooth loop
	mov	edi,[eax*8+AllocTable]
	mov	SmoothStart,edi
	mov	ecx,[alloctable+1052*8+4]
	mov	esi,[alloctable+1052*8]
	shr	ecx,2
SmoothLoopen:
	push	ecx edi
	mov	eax,[esi]
	shl	eax,1
	add	edi,eax
	mov	ebp,TheRealSmoothLength
	shl	ebp,1
	cmp	ebp,eax
	jge	NoMoreRightandleft

	mov	ecx,EffectSwapBuffer		;smooth loop
	mov	ecx,[ecx*8+AllocTable+4]
	sub	ecx,eax
	cmp	ebp,ecx
	jge	NoMoreRightandleft


	movsx	eax,word ptr [edi+ebp]
	neg	ebp
	movsx	ebx,word ptr [edi+ebp]
	neg	ebp
	sub	eax,ebx
	mov	ecx,2
	cdq
	idiv	ecx
	add	ebx,eax
	mov	[edi],bx

	mov	ecx,2
SmoothRightandleft:
	push	ecx
					;right
	movsx	eax,word ptr [edi+ecx]
	sub	eax,ebx
	imul	ecx
	idiv	ebp
	mov	edx,ebx
	add	edx,eax
	mov	[edi+ecx],dx
					;left
	neg	ecx
	movsx	eax,word ptr [edi+ecx]
	neg	ecx
	sub	eax,ebx
	imul	ecx
	idiv	ebp
	mov	edx,ebx
	add	edx,eax
	neg	ecx
	mov	[edi+ecx],dx
	neg	ecx

SkipThis:
	pop	ecx
	cmp	ecx,ebp
	jz	NoMoreRightandleft
	add	ecx,2
	jmp	SmoothRightandleft
NoMoreRightandleft:

	add	esi,4
	pop	edi ecx
	loop	SmoothLoopen

DoNoSmooth:
	xor	eax,eax 		;dealloc 1052
	xor	ebx,ebx
	mov	ebp,1052
	call	memalloc
	jc	RemoveMemory
;--------------------------------------------------- Effect wait init <Normalize>
			;-------------------------- Normalize volume ------

	cmp	EffectBits,1
	jz	Do16bitsnow
	mov	eax,EffectSwapBuffer
	mov	esi,[eax*8+AllocTable]
	mov	ecx,EffectSampLength
	mov	bx,32767
	mov	dx,-32768
NormVolSearch:			;search extreme values
	lodsw
	cmp	ax,bx
	jge	NoNoko1
	mov	bx,ax
NoNoKo1:
	cmp	ax,dx
	jle	NoNoko2
	mov	dx,ax
NoNoKo2:
	loop	NormVolSearch

	;mov	 EffectWait_Current,2500
	;call	 EffectWaitUpdate

	add	bx,32768
	mov	cx,32767
	sub	cx,dx
	mov	ax,cx
	add	ax,bx
	shr	ax,1
	and	eax,0ffffh
	and	ebx,0ffffh
	and	ecx,0ffffh
	mov	ebp,eax
	sub	ebp,ecx
	mov	ebx,32768
	sub	ebx,eax
	mov	eax,32767
	mov	ecx,32768
	mul	ecx
	div	ebx
	mov	ebx,eax

	mov	eax,EffectSwapBuffer
	mov	esi,[eax*8+AllocTable]
	mov	eax,EffectSourcerBuffer
	mov	edi,[eax*8+AllocTable]
	mov	ecx,EffectSampLength
NormChangeLoop:
	push	ecx
	movsx	eax,word ptr [esi]
	sub	eax,ebp
	add	esi,2
	imul	ebx
	mov	ecx,32768*256
	idiv	ecx
	add	al,128
	stosb
	pop	ecx
	loop	NormChangeLoop

	;mov	 EffectWait_Current,5000
	;call	 EffectWaitUpdate

	jmp	multieffectend

PopAllRet:
	pushad
	mov	ebp,EffectSwapBuffer
	xor	eax,eax
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory
	popad
	popad
	ret

;************************************************** 16 bits *****************
;************************************************** 16 bits *****************
;************************************************** 16 bits *****************
;************************************************** 16 bits *****************
;************************************************** 16 bits *****************
;--------------------------------------------------- Effect wait init <Normalize>
;--------------------------------------------------- Smooth in action --------
Do16BitsNow:
			;-------------------------- Normalize volume ------
	mov	eax,EffectSwapBuffer
	mov	esi,[eax*8+AllocTable]
	mov	ecx,EffectSampLength
	mov	bx,32767
	mov	dx,-32768
NormVolSearch_16_:		    ;search extreme values
	lodsw
	cmp	ax,bx
	jge	NoNoko1_16_
	mov	bx,ax
NoNoKo1_16_:
	cmp	ax,dx
	jle	NoNoko2_16_
	mov	dx,ax
NoNoKo2_16_:
	loop	NormVolSearch_16_

	;mov	 EffectWait_Current,2500
	;call	 EffectWaitUpdate

	add	bx,32768
	mov	cx,32767
	sub	cx,dx
	mov	ax,cx
	add	ax,bx
	shr	ax,1
	and	eax,0ffffh
	and	ebx,0ffffh
	and	ecx,0ffffh
	mov	ebp,eax
	sub	ebp,ecx
	mov	ebx,32768
	sub	ebx,eax
	mov	eax,32767
	mov	ecx,32768
	mul	ecx
	div	ebx
	mov	ebx,eax

	mov	eax,EffectSwapBuffer
	mov	esi,[eax*8+AllocTable]
	mov	eax,EffectSourcerBuffer
	mov	edi,[eax*8+AllocTable]
	mov	ecx,EffectSampLength
NormChangeLoop_16_:
	push	ecx
	movsx	eax,word ptr [esi]
	sub	eax,ebp
	add	esi,2
	imul	ebx
	mov	ecx,32768
	idiv	ecx
	add	ax,32768
	stosw
	pop	ecx
	loop	NormChangeLoop_16_

	;mov	 EffectWait_Current,5000
	;call	 EffectWaitUpdate

	jmp	multieffectend


;xxxxxxxxxxxxxxxx
EffectCurveSearch:;--------------------------------- Effect Curve Search ----
;Call:	 esi with offset loop on/off.
;Return: eax=relative value, esi=increased
	cmp	word ptr [esi+5],0
	jz	EndEffectZero
	cmp	word ptr [esi+5],1
	jz	EndEffectOne

	push	ebx ecx edx edi
	mov	al,[esi]		;save some values
	mov	EffectLoopOnOff,al
	mov	ax,[esi+1]
	mov	EffectLoopStart,ax
	mov	ax,[esi+3]
	mov	EffectLoopEnd,ax
	mov	ax,[esi+5]
	mov	EffectLoopPoints,ax
	add	esi,7
	xor	eax,eax

	movzx	eax,CurveSearchForm	;Get extra time
	mov	ebx,MaxNumberOfVoices*4
	mul	ebx
	mov	ebx,CurrentVoice
	shl	ebx,2
	add	eax,ebx
	add	eax,Gus_TempBuffPtr
	mov	ecx,eax
	add	eax,Gus_DelayTime
	mov	SearchTimeOffset,eax
	mov	ebx,[eax]
	mov	EffectExtraTime,ebx

	add	ecx,Gus_DelayCurvePoint ;Get curve point
	mov	SearchPointOffset,ecx
	mov	ebx,[ecx]



	cmp	TimeInvariantIndicate,0 	;Time Invariant
	jz	DoNormalVariant
	mov	eax,TimeInvariantMaxTime
	mov	ecx,EffectSampCount
	mul	ecx
	mov	ecx,EffectSampLength
	div	ecx
	mov	ebp,eax
	jmp	AfterInvariant
DONormalVariant:
	mov	eax,EffectSampCount	;search in curves
	mov	ecx,1000000
	mul	ecx
	mov	ecx,EffectSampleFrequency
	div	ecx
	mov	ebp,eax
AfterInvariant:

	mov	EffectLastNum,0
	mov	ecx,EffectExtraTime
	jmp	FirstTry
CurveSearchLoop:
	lea	eax,[ebx*8+ebx]
	mov	ecx,dword ptr [eax+esi]
	add	ecx,EffectExtraTime
	mov	EffectExtraTime,ecx
FirstTry:

NoLoopenBaja:

	cmp	ebp,ecx
	jb	NowInfo

	inc	ebx
	cmp	EffectLoopOnOff,0
	jz	LoopIsOff
	cmp	bx,EffectLoopEnd
	jbe	CurveSearchLoop
	movzx	ebx,EffectLoopStart
	inc	ebx
	jmp	CurveSearchLoop
LoopIsOff:

	movzx	eax,EffectLoopPoints
	dec	eax
	cmp	ebx,eax
	jbe	CurveSearchLoop
	mov	ebx,eax

	push	eax ecx 		;Save time and point pos
	mov	eax,SearchTimeOffset
	mov	ecx,EffectExtraTime
	mov	[eax],ecx
	mov	eax,SearchPointOffset
	mov	[eax],ebx
	pop	ecx eax

	lea	ecx,[ebx*8+ebx] 	;get info
	mov	eax,[ecx+esi-9]
	mov	EffectNr1a,eax
	mov	eax,[ecx+esi-5]
	mov	EffectNr2a,eax
	mov	al,[ecx+esi-1]
	mov	EffectNr3a,al
	mov	eax,[ecx+esi]
	mov	EffectNr1b,eax
	mov	eax,[ecx+esi+4]
	mov	EffectNr2b,eax
	mov	al,[ecx+esi+8]
	mov	EffectNr3b,al

	mov	ecx,EffectNr1b
	mov	effectsave,ecx
	jmp	enoja
ojojoj:


NowInfo:
	push	eax ecx 		;Save time and point pos
	mov	eax,SearchTimeOffset
	mov	ecx,EffectExtraTime
	mov	[eax],ecx
	mov	eax,SearchPointOffset
	mov	[eax],ebx
	pop	ecx eax

	lea	ecx,[ebx*8+ebx] 	;get info
	mov	eax,[ecx+esi-9]
	mov	EffectNr1a,eax
	mov	eax,[ecx+esi-5]
	mov	EffectNr2a,eax
	mov	al,[ecx+esi-1]
	mov	EffectNr3a,al
	mov	eax,[ecx+esi]
	mov	EffectNr1b,eax
	mov	eax,[ecx+esi+4]
	mov	EffectNr2b,eax
	mov	al,[ecx+esi+8]
	mov	EffectNr3b,al

	mov	eax,EffectExtraTime
	sub	eax,ebp
	mov	ecx,EffectNr1b
	sub	ecx,eax
	mov	effectsave,ecx

enoja:
	mov	eax,4095
	mul	ecx
	mov	ecx,EffectNr1b
	div	ecx


	cmp	EffectNr3a,0		;get curve data
	jz	EffectLiner
	cmp	EffectNr3a,2		;flip x
	jz	NoFlippen
	mov	ecx,4095
	sub	ecx,eax
	mov	eax,ecx
NoFlippen:
	shl	eax,2
	push	edx
	mov	edx,[Pcxoffsets+12*4]
	mov	eax,[eax+edx]
	pop	edx
	jmp	AfterLiner
EffectLiner:				;get line data
	mov	eax,65535
	mov	ecx,Effectsave
	mul	ecx
	mov	ecx,EffectNr1b
	div	ecx
AfterLiner:
					;flip y, compress, and add
	mov	ecx,EffectNr2b
	cmp	ecx,EffectNr2a
	jge	MakeDownToUp
					;Up To Down
	cmp	effectnr3a,1
	jz	NoFlipper2
	mov	ecx,65535
	sub	ecx,eax
	mov	eax,ecx
NoFlipper2:
	mov	ecx,EffectNr2a
	sub	ecx,EffectNr2b
	imul	ecx
	mov	ecx,65535
	idiv	ecx
	add	eax,EffectNr2b
	jmp	AfterAllStuff
MakeDownToUp:				;Down To Up
	cmp	effectnr3a,1
	jnz	NoFlipper1
	mov	ecx,65535
	sub	ecx,eax
	mov	eax,ecx
NoFlipper1:
	mov	ecx,EffectNr2b
	sub	ecx,EffectNr2a
	imul	ecx
	mov	ecx,65535
	idiv	ecx
	add	eax,EffectNr2a
AfterAllStuff:

EndcurveSearch:

	pop	edi edx ecx ebx
	push	ecx ebx
	movzx	ebx,word ptr [esi-2]	;add esi
	lea	ecx,[ebx*8+ebx]
	add	esi,ecx
	pop	ebx ecx
	ret
EndEffectZero:
	xor	eax,eax
	add	esi,7
	ret
EndEffectOne:
	mov	eax,[esi+11]
	add	esi,7+9
	ret
				;------------------ allocate effect
OnlySwap	db	0
AllocateEffect:
	pushad
	mov	ebp,EffectSwapBuffer
	mov	eax,EffectsampLength
	shl	eax,1
	xor	ebx,ebx
	call	memalloc
	jc	notmoremem
	cmp	OnlySwap,1
	jz	_retp
	mov	ebp,EffectSourcerBuffer
	mov	eax,Effectsamplength
	shl16ef eax
	xor	ebx,ebx
	call	memalloc
	jc	notmoremem
	popad
	ret
NotMoreMem:
			;plats f”r att plocka bort popup !!!!!!!!!!!!!

	mov	ebp,EffectSwapBuffer
	xor	eax,eax
	xor	ebx,ebx
	call	memalloc
	jmp	RemoveMemory
				;------------------ Effect curve search end --
Effect16Bits:


MultiEffectEnd:
	mov	ebp,EffectSwapBuffer	;disalloc swap buffer
	xor	eax,eax
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory
	popad
	mov	eax,EffectSampLength
	ret


EndEffectNull:
	mov	EffectSampLength,0
	call	AllocateEffect
	mov	ebp,EffectSwapBuffer	;disalloc swap buffer
	xor	eax,eax
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory
	popad
	mov	eax,EffectSampLength
	ret
MultiEffectsEngine	Endp
SetSmoothCounter:			;Set Smooth Counter ----------------
	pushad
	mov	esi,[alloctable+1051*8]
	cmp	byte ptr [esi+7],0
	jz	_retp

	mov	ebp,1052
	mov	eax,[alloctable+1052*8+4]
	add	eax,4
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory

	mov	eax,EffectSampCount
	mov	ecx,[alloctable+1052*8+4]
	sub	ecx,4
	add	ecx,[alloctable+1052*8]
	mov	[ecx],eax
	popad
	ret





;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Sample Effects
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;UndoPattern		 1044
;SineTable		 1045
;Effect Table	         1046
;Effect multi		 1048
;Effect single		 1049
;Effect editbuff	 1051
;Smooth buffer		 1052


EffectFile	db	"vs.eff",0
CurrentMulti	dd	0	;0=all (number is sorted effects)
CurrentSingle	dd	0
CurrentList	dd	0
PosMulti	dd	0
PosSingle	dd	0
PosList 	dd	0

EffectPosStart	dd	0	;offset to the effects (from table start)
EffectError	db	0
EffText 	db	"VS.EFF not found.@Effects engine disabled.$"
SpecialSelect	db	0	;0=No special
				;1=Move effect
EffectSaveNow	db	0	;if 1, there is a change made
MaxList 	equ	200
ListTable	dw	(MaxList+1)	dup(0)
ListTableNumber dd	0
NameMultiBuffer db	28	dup(0)

SampleEffectsStart:			;Sample Effects Start -------------
	pushad
	cmp	MouseB,2
	jz	DoEffectDirekt

	call	ButtonHandler
	cmp	eax,0
	jnz	_retp


	mov	curradd,0
	mov	playpegoff,0
	call	movethepegs
	call	SetSampOffset

	call	CheckIfNowFastPreview
	mov	TuneStopped,1		;Stop Tune
	call	ClearForPlay
	mov	RecMode,0
	mov	EditMode,0
	call	BackCol
	mov	PrintBlock,0
	mov	PatternPlay,0
	mov	OldInfoTextPtr,-1

	lea	edi,MIDIPriority
	mov	ecx,32
	mov	al,0
	rep	stosw
	call	StopAllVoices

	mov	OldPosMulti,-1
	mov	OldPosList,-1
	mov	OldPosSingle,-1

	call	CheckIfShadow
	jc	_retp
	cmp	effecterror,1
	jz	_retp

	mov	Menu_popup,29
	call	MenuHandler
	mov	EffectSaveNow,0

	call	InitEffects
	call	ShowMultiEffect
	call	ShowSingleEffect
	call	ShowListEffect

	_rp

SampleEffectsEnd2:			;Sample Effects End ---------------
	pushad
	jmp	SampleEffectsJump
SampleEffectsEnd:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
SampleEffectsJump:
	call	CheckSaveEffectsToDisk
	jc	_retp
	mov	Menu_popup,0
	call	MenuHandler
	mov	SpecialSelect,0
	mov	mousecursor,0
	mov	updatemouse,80h
	call	StopSpeech

	mov	curradd,0
	mov	playpegoff,0
	call	SetSampOffset


	call	CheckIfNowFastPreview
	_rp

SampLoadEffects:			;Samp load effects ----------------
	pushad

	lea	edx,EffectFile
	call	FixPathFile

	mov	EffectError,1
	lea	edx,NewFileName
	call	_openfileR
	jnc	NoError
YesError:
	mov	menu_popup,1
	lea	esi,EffText
	call	Popuphandler
	_rp
NoError:

	mov	ebp,1047
	xor	ebx,ebx
	call	_filesize
	jc	YesError
	push	eax
	call	memalloc
	jc	RemoveMemory


	mov	edx,eax
	pop	ecx
	call	_readfile
	jc	YesError
	call	_closefile
	jc	YesError
	mov	EffectError,0

	popad
	ret


nomulti db	0
InitEffects:				;Init Effects	-------------------
;nomuli=1 no move from multi to list
	pushad

	mov	esi,[AllocTable+1047*8] ;alloc multi
	movzx	eax,word ptr [esi+2]
	shl	eax,2
	mov	ebp,1048
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory

	mov	esi,[AllocTable+1047*8] ;alloc single
	movzx	eax,word ptr [esi+4]
	shl	eax,2
	mov	ebp,1049
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory

	mov	esi,[AllocTable+1047*8] ;copy multi
	mov	edi,[AllocTable+1048*8]
	mov	ebp,6
	movzx	ecx,word ptr [esi+2]
	jecxz	SkipCopyMulti
CopyMulti:
	mov	[edi],ebp
	add	edi,4
	add	ebp,28
CopySmall:
	mov	ax,[ebp+esi]
	add	ebp,2
	cmp	ax,-1
	jnz	CopySmall
	loop	CopyMulti
Skipcopymulti:

	mov	EffectPosStart,ebp

	mov	edi,[AllocTable+1049*8] ;copy single
	movzx	ecx,word ptr [esi+4]
	jecxz	SkipCopySingle
CopySingle:
	mov	[edi],ebp
	add	edi,4
	add	ebp,28+4
	loop	CopySingle
SkipCopySingle:

	mov	esi,[AllocTable+1047*8] ;sort multi
	movzx	ecx,word ptr [esi+2]
	jecxz	SkipSortMulti
	mov	edi,[AllocTable+1048*8]
	call	SortList
SkipSortMulti:

	mov	esi,[AllocTable+1047*8] ;sort single
	movzx	ecx,word ptr [esi+4]
	jecxz	SkipSortSingle
	mov	edi,[AllocTable+1049*8]
	call	SortList
SkipSortSingle:

	cmp	nomulti,1
	jz	skipmoven
	call	MoveMultiToList
skipmoven:
	mov	nomulti,0

	popad
	ret

SortList:				;Sort List ------------------------
;Calls: edi=List Pointer
;	ecx=Number of positions
	pushad
	cmp	ecx,1
	jz	_retp
	dec	ecx
	mov	esi,[AllocTable+1047*8]

SortLoop1:
	push	ecx

	mov	edx,4
SortLoop2:
	push	ecx

	xor	ecx,ecx
NextBlock:
	mov	eax,[edi]
	mov	ebx,[edi+edx]
	add	eax,ecx
	add	ebx,ecx
	mov	eax,[esi+eax]
	mov	ebx,[esi+ebx]
	ror	ax,8
	ror	eax,16
	ror	ax,8
	ror	bx,8
	ror	ebx,16
	ror	bx,8
	cmp	eax,ebx
	jb	nochange___
	jne	justflipp
	cmp	ecx,6*4
	jz	nochange___
	add	ecx,4
	jmp	NextBlock
justflipp:
	mov	eax,[edi]
	xchg	eax,[edi+edx]
	mov	[edi],eax
nochange___:

	add	edx,4
	pop	ecx
	loop	SortLoop2

	add	edi,4
	pop	ecx
	loop	SortLoop1

	popad
	ret
ShowCount	dd	0
ShowMultiEffect:			;Show multi effect ----------------
	pushad


	move	edi,0a0000h+72/8+55*80
	mov	ebp,[alloctable+1048*8]
	mov	eax,PosMulti
	mov	ShowCount,eax
	shl	eax,2
	add	ebp,eax
	mov	ecx,31
	call	mouseoff
	mov	fontplane,1
PutSingleLoop1:
	push	ecx edi

	mov	esi,[alloctable+1047*8] ;clear
	movzx	eax,word ptr [esi+2]
	cmp	ShowCount,eax
	jb	noclearjust
	mov	ecx,28
PutSingleLoopClear:
	push	ecx
	mov	ebx,' '
	mov	ah,00000001b
	call	putcharacter
	inc	edi
	pop	ecx
	loop	PutSingleLoopClear
	jmp	AfterPuttenNow
noclearjust:

	mov	eax,ShowCount		;put text
	cmp	eax,CurrentMulti
	jnz	nosettasa
	mov	InvertText,-1
nosettasa:
	mov	esi,[alloctable+1047*8]
	add	esi,[ebp]
	mov	ecx,28
PutSingleLoop2:
	push	ecx
	movzx	ebx,byte ptr [esi]
	mov	ah,00000001b
	call	putcharacter
	inc	edi
	inc	esi
	pop	ecx
	loop	PutSingleLoop2
	mov	InvertText,0

AfterPuttenNow:
	inc	ShowCount
	pop	edi ecx
	add	edi,80*12
	add	ebp,4
	loop	PutSingleLoop1

	mov	fontplane,0
	call	mouseon

	popad
	ret

ShowSingleEffect:			;Show single effect ----------------
	pushad

	move	edi,0a0000h+320/8+55*80
	mov	ebp,[alloctable+1049*8]
	mov	eax,PosSingle
	mov	ShowCount,eax
	shl	eax,2
	add	ebp,eax
	mov	ecx,12
	call	mouseoff
	mov	fontplane,1
PutSingleLoop1_:
	push	ecx edi

	mov	esi,[alloctable+1047*8] ;clear
	movzx	eax,word ptr [esi+4]

	cmp	ShowCount,eax
	jb	noclearjust_
	mov	ecx,28
PutSingleLoopClear_:
	push	ecx
	mov	ebx,' '
	mov	ah,00000001b
	call	putcharacter
	inc	edi
	pop	ecx
	loop	PutSingleLoopClear_
	jmp	AfterPuttenNow_
noclearjust_:

	mov	eax,ShowCount		;put text
	cmp	eax,CurrentSingle
	jnz	nosettasa_
	mov	InvertText,-1
nosettasa_:
	mov	esi,[alloctable+1047*8]
	add	esi,[ebp]
	mov	ecx,28
PutSingleLoop2_:
	push	ecx
	movzx	ebx,byte ptr [esi]
	mov	ah,00000001b
	call	putcharacter
	inc	edi
	inc	esi
	pop	ecx
	loop	PutSingleLoop2_
	mov	InvertText,0

AfterPuttenNow_:
	inc	ShowCount
	pop	edi ecx
	add	edi,80*12
	add	ebp,4
	loop	PutSingleLoop1_

	mov	fontplane,0
	call	mouseon

	popad
	ret

ShowListEffect: 			;Show List Effect -------------------
	pushad

	move	edi,0a0000h+320/8+254*80
	lea	ebp,ListTable
	mov	eax,PosList
	mov	ShowCount,eax
	shl	eax,1
	add	ebp,eax
	mov	ecx,10
	call	mouseoff
	mov	fontplane,1
PutSingleLoop1_S:
	push	ecx edi


	mov	eax,ListTableNumber
	cmp	ShowCount,eax
	jb	noclearjust_S
	mov	ecx,28
PutSingleLoopClear_S:
	push	ecx
	mov	ebx,' '
	mov	ah,00000001b
	call	putcharacter
	inc	edi
	pop	ecx
	loop	PutSingleLoopClear_S
	jmp	AfterPuttenNow_S
noclearjust_S:

	mov	eax,ShowCount		;put text
	cmp	eax,CurrentList
	jnz	nosettasa_S
	mov	InvertText,-1
nosettasa_S:
	movzx	esi,word ptr [ebp]
	shl	esi,5
	add	esi,EffectPosStart
	add	esi,[alloctable+1047*8]
	mov	ecx,28
PutSingleLoop2_S:
	push	ecx
	movzx	ebx,byte ptr [esi]
	mov	ah,00000001b
	call	putcharacter
	inc	edi
	inc	esi
	pop	ecx
	loop	PutSingleLoop2_S
	mov	InvertText,0

AfterPuttenNow_S:
	inc	ShowCount
	pop	edi ecx
	add	edi,80*12
	add	ebp,2
	loop	PutSingleLoop1_S

	mov	fontplane,0
	call	mouseon

	popad
	ret

EffectMultiArrowUp:			;Effect multi arrow up -------------
	pushad

	call	fixbutton
	cmp	PosMulti,0
	jz	_retp
	dec	PosMulti
	call	ShowMultiEffect
	popad
	ret

EffectMultiArrowDown:			;Effect multi arrow down -----------
	pushad
	call	fixbutton
	mov	eax,[Alloctable+1047*8]
	movzx	eax,word ptr [eax+2]
	sub	eax,30
	cmp	eax,0
	jle	_retp
	dec	eax
	cmp	eax,PosMulti
	jz	_retp
	inc	PosMulti
	call	ShowMultiEffect
	popad
	ret

EffectSingleArrowUp:			 ;Effect single arrow up -------------
	pushad
	call	fixbutton
	cmp	PosSingle,0
	jz	_retp
	dec	PosSingle
	call	ShowSingleEffect
	popad
	ret

EffectSingleArrowDown:			 ;Effect single arrow down -----------
	pushad
	call	fixbutton
	mov	eax,[Alloctable+1047*8]
	movzx	eax,word ptr [eax+4]
	sub	eax,11
	cmp	eax,0
	jle	_retp
	dec	eax
	cmp	eax,PosSingle
	jz	_retp
	inc	PosSingle
	call	ShowSingleEffect
	popad
	ret

EffectListArrowUp:			;Effect list arrow up ---------------
	pushad
	call	fixbutton
	cmp	PosList,0
	jz	_retp
	dec	PosList
	call	ShowListEffect
	popad
	ret
EffectListArrowDown:			;Effect list arrow down ------------
	pushad
	call	fixbutton
	mov	eax,ListTableNumber
	sub	eax,9
	cmp	eax,0
	jle	_retp
	dec	eax
	cmp	eax,PosList
	jz	_retp
	inc	PosList
	call	ShowListEffect
	popad
	ret

SelectMulti:				;Select multi ----------------------
	pushad
	mov	OldPosList,-1
	call	CheckIfNowFastPreview
	movzx	eax,MouseY
	sub	eax,55
	mov	ebx,12
	xor	edx,edx
	div	ebx
	mov	esi,[alloctable+1047*8]
	movzx	ebx,word ptr [esi+2]
	cmp	ebx,0
	jz	_retp
	dec	ebx
	add	eax,PosMulti
	cmp	eax,ebx
	jbe	donotworry
	mov	eax,ebx
DoNotWorry:
	mov	CurrentMulti,eax
	mov	CurrentList,0
	mov	PosList,0
	call	MoveMultiToList

;	 cmp	 MouseB,2
;	 jz	 nodubel
;	 cmp	 DoubleClick,1
;	 jz	 SampEffectsOkayDouble
;nodubel:

	call	ShowMultiEffect
	call	ShowListEffect

	cmp	MouseB,2
	jnz	NoSingleDirekt
	mov	LastBeforeUp,1
	mov	PreviewForm,0
	mov	PreviewStatus,0
	mov	PreviewStatusLength,0
	jmp	DoPreviewPop1
NoSingleDirekt:

	popad
	ret

SelectSingle:				;Select single ---------------------
	pushad
	call	CheckIfNowFastPreview
	movzx	eax,MouseY
	sub	eax,55
	mov	ebx,12
	xor	edx,edx
	div	ebx
	mov	esi,[alloctable+1047*8]
	movzx	ebx,word ptr [esi+4]
	cmp	ebx,0
	jz	_retp
	dec	ebx
	add	eax,PosSingle
	cmp	eax,ebx
	jbe	donotworry2
	mov	eax,ebx
DoNotWorry2:
	mov	CurrentSingle,eax
	call	ShowSingleEffect

	cmp	MouseB,2
	jnz	NoSingleDirektNu
	mov	PreviewForm,0
	mov	LastBeforeUp,1
	mov	PreviewStatus,1
	mov	PreviewStatusLength,0
	jmp	DoPreviewPop2
NoSingleDirektNu:

	cmp	DoubleClick,1
	jz	EffectAddEffectDouble

	popad
	ret
SelectList:				;Select list ----------------------
	pushad
	mov	OldPosList,-1
	call	CheckIfNowFastPreview
	movzx	eax,MouseY
	sub	eax,254
	mov	ebx,12
	xor	edx,edx
	div	ebx
	mov	ebx,ListTableNumber
	cmp	ebx,0
	jz	_retp
	dec	ebx
	add	eax,PosList
	cmp	eax,ebx
	jbe	donotworry3
	mov	eax,ebx
DoNotWorry3:
	mov	CurrentList,eax
	call	ShowListEffect

	cmp	DoubleClick,1
	jz	DelListan
	popad
	ret
DelMulti:				;Del multi ------------------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp

	mov	OldPosMulti,-1
	mov	OldPosList,-1
	mov	OldPosSingle,-1
	mov	esi,[alloctable+1047*8]
	cmp	word ptr [esi+2],0
	jz	_retp

	lea	esi,EffText2		;check popup
	mov	SpecialSecondPopup,1
	mov	SecondPopup,37
	mov	SpecialTextOffset,205*80+14
	call	popuphandler
	mov	SpecialTextOffset,0
	mov	SpecialSecondPopup,0
	movzx	eax,popupstatus
	cmp	eax,0
	jz	_retp

	call	CheckIfNowFastPreview
	mov	EffectSaveNow,1

	mov	ebp,[alloctable+1047*8]
	dec	word ptr [ebp+2]

	mov	edi,[alloctable+1048*8]
	mov	eax,currentmulti
	mov	esi,[eax*4+edi]
	add	esi,[alloctable+1047*8]
	mov	ecx,28
scanlengthen:
	add	ecx,2
	cmp	word ptr [esi+ecx-2],-1
	jnz	scanlengthen
	sub	esi,[alloctable+1047*8]
	mov	ebp,1047
	call	ChangeOffsetsDel
	call	DelAllocSpace

	mov	esi,[alloctable+1047*8]
	movzx	eax,word ptr [esi+2]
	dec	eax
	cmp	CurrentMulti,eax
	jbe	nosettcurri
	mov	CurrentMulti,eax
NoSettCurri:
	mov	CurrentList,0
	mov	PosList,0

	call	InitEffects
	call	MoveMultiToList
	call	ShowMultiEffect
	call	ShowListEffect

	popad
	ret
SaveEffectsToDisk:			;Save effects to disk -------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
Jumper:
	lea	esi,EffText1		;check popup
	mov	SpecialSecondPopup,1
	mov	SecondPopup,37
	mov	SpecialTextOffset,205*80+14
	call	popuphandler
	mov	SpecialTextOffset,0
	mov	SpecialSecondPopup,0
	movzx	eax,popupstatus
	cmp	eax,0
	jz	_retp

	mov	EffectSaveNow,0

	cli

	lea	edx,EffectFile
	call	fixpathfile
	lea	edx,newfilename
	call	_createfile

	mov	edx,[Alloctable+1047*8]
	mov	ecx,[Alloctable+1047*8+4]
	call	_writefile
	call	_closefile

	sti
	popad
	ret

EffectAddMulti:				;Effect add multi --------------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp

	mov	EffectSaveNow,1
	call	CheckIfNowFastPreview

	mov	edi,[alloctable+1047*8]
	cmp	word ptr [edi+2],65535
	jz	_retp
	mov	ebp,1047
	mov	esi,6
	mov	ecx,32
	call	ChangeOffsetsIns
	call	MakeAllocSpace

	mov	eax,CurrentSingle
	mov	esi,[AllocTable+1049*8]
	mov	esi,[eax*4+esi]
	add	esi,32
	add	esi,[AllocTable+1047*8]
	mov	edi,[alloctable+1047*8]
	inc	word ptr [edi+2]
	add	edi,6
	mov	ecx,28
	rep	movsb
	mov	eax,CurrentSingle
	mov	esi,[AllocTable+1049*8]
	mov	esi,[eax*4+esi]
	add	esi,32
	sub	esi,EffectPosStart
	shr	esi,5
	mov	word ptr [edi],si
	mov	word ptr [edi+2],-1
	call	InitEffects
	call	ShowMultiEffect
	popad
	ret

CheckSaveEffectsToDisk: 		;Check Save effects to disk ---------
;back	carry if not continue
	pushad
	cmp	EffectSaveNow,0
	jz	_retp

	lea	esi,EffText9		;check popup
	mov	SpecialSecondPopup,1
	mov	SecondPopup,37
	mov	SpecialTextOffset,205*80+14
	call	popuphandler
	mov	SpecialTextOffset,0
	mov	SpecialSecondPopup,0
	movzx	eax,popupstatus
	cmp	eax,0
	jz	settaC
	popad
	mov	EffectSaveNow,0
	clc
	ret
settaC:
	popad
	stc
	ret


ChangeOffsetsDel:			;Change offsets del ------------------'
;	esi=start offset
;	ecx=length
	pushad
	mov	edi,[alloctable+1047*8]
	cmp	word ptr [edi+4],0
	jz	_retp
	movzx	ebx,word ptr [edi+4]
	add	edi,EffectPosStart
	cmp	esi,effectposstart
	jae	Vickandenglade
	sub	effectposstart,ecx
VickanDenGlade:
	add	edi,28
	cmp	esi,[edi]
	jae	nodeca
	sub	[edi],ecx
nodeca:
	add	edi,4
	dec	ebx
	jnz	VickanDenGlade
	popad
	ret

ChangeOffsetsIns:			;Change offsets ins ------------------'
;	esi=start offset
;	ecx=length
	pushad
	mov	edi,[alloctable+1047*8]
	cmp	word ptr [edi+4],0
	jz	_retp
	movzx	ebx,word ptr [edi+4]
	add	edi,EffectPosStart
	cmp	esi,effectposstart
	ja	Vickandenglade2
	add	effectposstart,ecx
VickanDenGlade2:
	push	ebx
	add	edi,28
	cmp	esi,[edi]
	jae	nodeca2
	add	[edi],ecx
nodeca2:
	add	edi,4
	pop	ebx
	dec	ebx
	jnz	VickanDenGlade2
	popad
	ret

ChangeOffsetsIns2:			 ;Change offsets ins 2 ------------------'
;	esi=start offset
;	ecx=length
	pushad
	mov	edi,[alloctable+1047*8]
	cmp	word ptr [edi+4],0
	jz	_retp
	movzx	ebx,word ptr [edi+4]
	add	edi,EffectPosStart
	cmp	esi,effectposstart
	ja	Vickandenglade2_
	add	effectposstart,ecx
VickanDenGlade2_:
	push	ebx
	add	edi,28
	cmp	esi,[edi]
	ja	nodeca2_
	add	[edi],ecx
nodeca2_:
	add	edi,4
	pop	ebx
	dec	ebx
	jnz	VickanDenGlade2_
	popad
	ret
ChangeOffsetsIns3:			 ;Change offsets ins 3 ------------------'
;	esi=start offset
;	ecx=length
	pushad
	mov	edi,[alloctable+1047*8]
	cmp	word ptr [edi+4],0
	jz	_retp
	movzx	ebx,word ptr [edi+4]
	add	edi,EffectPosStart
	cmp	esi,effectposstart
	jae	Vickandenglade2_3
	add	effectposstart,ecx
VickanDenGlade2_3:
	push	ebx
	add	edi,28
	cmp	esi,[edi]
	ja	nodeca2_3
	add	[edi],ecx
nodeca2_3:
	add	edi,4
	pop	ebx
	dec	ebx
	jnz	VickanDenGlade2_3
	popad
	ret

DelAllocSpace:				;Del Alloc Space ---------------------
;Calls: ebp=alloc number
;	esi=start offset
;	ecx=length
	pushad
	cmp	ecx,0
	je	_retp
	jl	RemoveMemory

	push	ecx
	mov	edx,[alloctable+ebp*8+4]
	sub	edx,esi
	sub	edx,ecx
	add	esi,[alloctable+ebp*8]
	mov	edi,esi
	add	esi,ecx
	mov	ecx,edx
	rep	movsb
	pop	ecx

	xor	ebx,ebx
	mov	eax,[alloctable+ebp*8+4]
	sub	eax,ecx
	call	memalloc
	jc	RemoveMemory

	popad
	ret

MakeAllocSpace: 			;Make Alloc Space -------------------
;Calls: ebp=alloc number
;	esi=start offset
;	ecx=length
	pushad

	mov	eax,[alloctable+ebp*8+4]
	add	eax,ecx
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory

	mov	edx,ecx
	mov	edi,[alloctable+ebp*8+4]
	dec	edi
	add	edi,[alloctable+ebp*8]
	mov	ebx,[alloctable+ebp*8+4]
	sub	ebx,ecx
	sub	ebx,esi
	mov	ecx,ebx
	mov	esi,edi
	sub	esi,edx
	std
	rep	movsb
	cld

	popad
	ret

MoveMultiToList:			;Move multi to list -----------------
	pushad

	mov	OldPosList,-1
	mov	eax,[alloctable+1047*8]
	cmp	word ptr [eax+2],0
	jnz	nozerobaj
	mov	ListTableNumber,0
	popad
	ret
nozerobaj:
	mov	eax,[alloctable+1048*8]
	mov	ebx,currentmulti
	mov	esi,[eax+ebx*4]
	add	esi,[alloctable+1047*8]
	add	esi,28
	lea	edi,ListTable
	mov	ecx,-1
MoveLoopenM:
	lodsw
	stosw
	inc	ecx
	cmp	ax,-1
	jnz	MoveLoopenM
	mov	ListTableNumber,ecx

	popad
	ret

CopyStart	dd	0
CopyLength	dd	0
CopyTotalLength dd	0
SampEffectsOkay2:			;SampEffect okay --------------------
	pushad
	jmp	skipbutt

SampEffectsOkay:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
skipbutt:
SampEffectsOkayDouble:
	cmp	ListTableNumber,0
	jz	_retp

	call	CheckSaveEffectsToDisk		;check if save effects to disk
	jc	_retp

	call	CheckIfNowFastPreview
DoEffectDirekt:

	mov	ebp,1050
	mov	eax,0
	call	memalloc
	jc	RemoveMemory
	mov	Menu_popup,0                    ;remove popup
	call	MenuHandler

	mov	curradd,0
	mov	playpegoff,0
	call	SetSampOffset

	mov	SpecialSelect,0
	mov	mousecursor,0
	mov	updatemouse,80h

	cmp	SampLength,0
	jz	_retp
	cmp	ListTableNumber,0
	jz	_retp

	call	saveundo                ;undo

	call	StopSpeech
	call	EffectWaitStart

	mov	eax,SampLength
	mov	CopyStart,0
	cmp	sampmarkstart,-1                ;cut sample to buffer 1050
	jz	AfterLength_
	mov	eax,sampmarkend
	sub	eax,sampmarkstart
	mov	ebx,Sampmarkstart
	mov	copystart,ebx
AfterLength_:
	mov	copylength,eax
	shl16	eax
	cmp	eax,0
	jz	EndenWait


	mov	ebp,1050
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory
;;
	mov	esi,undobufferoffset            ;move samp
	mov	ecx,CopyStart
	shl16	ecx
	add	esi,ecx
	mov	edi,[alloctable+1050*8]
	mov	ecx,[alloctable+1050*8+4]
	rep	movsb

	mov	ecx,samplength
	mov	CopyTotalLength,ecx

	call	effectscanDC			;DC offset and volume
	call	effectcenter			;do center


	mov	samplength,0
	call	allocsamplength
						;centering

	mov	ecx,ListTableNumber
	mov	NrOfWaitEffects,ecx
	xor	ebp,ebp
EffectLoopen:					;effectloop
	push	ecx ebp

	pushad
	movzx	esi,word ptr [ebp+ListTable]
	shl	esi,5
	add	esi,EffectPosStart
	add	esi,[alloctable+1047*8]
	call	EffectWaitWriteName
	popad


	movzx	edi,word ptr [ebp+ListTable]
	shl	edi,5
	add	edi,EffectPosStart
	add	edi,[alloctable+1047*8]
	add	edi,28
	mov	edi,[edi]

	mov	ecx,[alloctable+1050*8+4]
	shr16	ecx
	mov	edx,sampbits

	movzx	ebx,CurrentSample
	call	GetSampleRate
	jnc	NoZeroNow__
	mov	eax,16768
NoZeroNow__:
	mov	ebx,eax
	mov	esi,1050
	mov	eax,1047
	mov	ebp,1037
	;mov	 EffectWaitPlane,0

	call	MultiEffectsEngine
	cmp	WaitStatus,1
	jz	WaitJump1

	inc	CurrentWaitEffect
	pop	ebp ecx
	add	ebp,2
	loop	EffectLoopen


	call	effectfixDC				;effect fix DC

							;paste sample
	mov	eax,[alloctable+1050*8+4]		;alloc samplength
	shr16	eax
	add	eax,undosamplength
	sub	eax,CopyLength
	mov	samplength,eax
	call	allocsamplength

	mov	edi,sampmainoffset			;move samp
	mov	esi,undobufferoffset
	mov	ecx,CopyStart
	shl16	ecx
	rep	movsb
	push	esi
	mov	esi,[alloctable+1050*8]
	mov	ecx,[alloctable+1050*8+4]
	rep	movsb
	pop	esi
	mov	ecx,CopyLength
	shl16	ecx
	add	esi,ecx
	mov	ecx,CopyTotalLength
	sub	ecx,CopyLength
	sub	ecx,CopyStart
	shl16	ecx
	rep	movsb

	jmp	nojumpen
WaitJump1:
	pop	ebp ecx
	mov	eax,undosamplength
	mov	samplength,eax
	call	allocsamplength
	mov	esi,undobufferoffset
	mov	edi,sampmainoffset
	mov	ecx,samplength
	shl16	ecx
	rep	movsb
NoJumpen:

	mov	ebp,1050
	xor	ebx,ebx
	xor	eax,eax
	call	memalloc
	jc	RemoveMemory

	mov	eax,SampLength
	mov	Viewsamplength,eax
	mov	extrasamplength,0


	call	EffectWaitEnd

	mov	SampMarkSTart,-1
	call	clippegs
	mov	viewsampoffset,0
	mov	sampmarkstart,-1
	call	viewsamp
	call	updatesampletogus

	mov	PlayForm,1
	call	UpdateSample

	lea	edi,oldputs
	mov	eax,-1
	mov	ecx,20
	rep	stosd

	popad
	ret
EndenWait:
	call	EffectWaitEnd
	popad
	ret


VolOfMax	dd	0
EffectScanDC:				;Effect Scan DC ---------------------
	pushad

	cmp	SampBits,1
	jz	do16yessa
	mov	esi,[alloctable+1050*8]
	mov	ecx,[alloctable+1050*8+4]
	mov	bx,00ffh
ScanLoopa:
	lodsb
	cmp	bl,al
	jbe	nouua1
	mov	bl,al
nouua1:
	cmp	bh,al
	jae	nouua2
	mov	bh,al
nouua2:
	loop	ScanLoopa
	movzx	ecx,bh
	movzx	edx,bl
	sub	ecx,edx
	mov	VolOfMax,ecx
	cmp	ecx,255
	jbe	_retp
	mov	VolOfMax,255
	popad
	ret

do16yessa:				   	;16bits
	mov	esi,[alloctable+1050*8]
	mov	ecx,[alloctable+1050*8+4]
	shr	ecx,1
	mov	bx,0ffffh
	xor	dx,dx
ScanLoopa_16_:
	lodsw
	cmp	bx,ax
	jbe	nouua1_16_
	mov	bx,ax
nouua1_16_:
	cmp	dx,ax
	jae	nouua2_16_
	mov	dx,ax
nouua2_16_:
	loop	ScanLoopa_16_
	movzx	ecx,dx
	movzx	ebp,bx
	sub	ecx,ebp
	mov	VolOfMax,ecx
	cmp	ecx,65536
	jbe	_retp
	mov	VolOfMax,65535
	popad
	ret


	popad
	ret
EffectFixDC:				;Effect fix DC -----------------------
	pushad

	cmp	SampBits,1			;change vol + DC
	jz	do16yessa2
	mov	esi,[alloctable+1050*8]
	mov	ecx,[alloctable+1050*8+4]
	mov	ebp,DCmove
	neg	ebp
	mov	ebx,VolOfMax
DoYessa2:
	push	ecx
	mov	dl,byte ptr [esi]
	add	dl,128
	movsx	eax,dl
	imul	ebx
	mov	ecx,255
	idiv	ecx
	add	al,128
	and	eax,0ffh
	add	eax,ebp
	cmp	eax,255
	jle	nopb1
	mov	eax,255
nopb1:
	cmp	eax,0
	jge	nopb2
	mov	eax,0
nopb2:
	mov	byte ptr [esi],al
	inc	esi
	pop	ecx
	loop	DoYessa2

	popad
	ret

Do16yessa2:		      			;16 bits
	mov	esi,[alloctable+1050*8]
	mov	ecx,[alloctable+1050*8+4]
	shr	ecx,1
	mov	ebp,DCmove
	neg	ebp
	mov	ebx,VolOfMax
DoYessa2_16_:
	push	ecx
	mov	dx,word ptr [esi]
	add	dx,32768
	movsx	eax,dx
	imul	ebx
	mov	ecx,65535
	idiv	ecx
	add	ax,32768
	and	eax,0ffffh
	add	eax,ebp
	cmp	eax,65535
	jle	nopb1_16_
	mov	eax,65535
nopb1_16_:
	cmp	eax,0
	jge	nopb2_16_
	mov	eax,0
nopb2_16_:
	mov	word ptr [esi],ax
	add	esi,2
	pop	ecx
	loop	DoYessa2_16_
	popad
	ret
					;Effect center -----------------------
DCmove		dd	0
yfixeffect_	db	0
centercount	dd	0
EffectCenter:
	pushad

	mov	edi,[alloctable+1050*8]
	mov	ecx,[alloctable+1050*8+4]
	shr16	ecx
	cmp	sampbits,1
	jz	center16bits
					;- center 8bits ---
	push	edi
	push	ecx
	xor	ebp,ebp
	mov	centercount,0
	mov	ebx,ecx

scancenterloop:
	mov	ecx,16777215
	mov	edx,ebx
	sub	ebx,16777215
	cmp	edx,16777215
	ja	skipknutyngve
	mov	ecx,edx
	xor	ebx,ebx
skipknutyngve:
	push	ecx
	xor	esi,esi
knoddas:
	movzx	eax,byte ptr [edi]
	add	esi,eax
	inc	edi
	loop	knoddas
	pop	ecx
	mov	eax,esi
	xor	edx,edx
	div	ecx
	add	ebp,eax
	inc	centercount
	cmp	ebx,0
	jnz	scancenterloop

	mov	eax,ebp
	mov	ebx,centercount
	xor	edx,edx
	div	ebx

	pop	ecx
	pop	edi

	mov	ebx,128
	sub	ebx,eax
	mov	DCmove,ebx

centerit:
	movzx	ax,byte ptr [edi]
	add	ax,bx
	cmp	ax,0
	jge	nosetboja1
	xor	ax,ax
nosetboja1:
	cmp	ax,255
	jbe	nosetbojja1
	mov	al,255
nosetbojja1:
	stosb
	loop	centerit

	jmp	fixaend4
					;- center 16bits ---
center16bits:

	push	edi
	push	ecx
	xor	ebp,ebp
	mov	centercount,0
	mov	ebx,ecx

scancenterloop_2:
	mov	ecx,65530
	mov	edx,ebx
	sub	ebx,65530
	cmp	edx,65530
	ja	skipknutyngve_2
	mov	ecx,edx
	xor	ebx,ebx
skipknutyngve_2:
	push	ecx
	xor	esi,esi
knoddas_2:
	movzx	eax,word ptr [edi]
	add	esi,eax
	add	edi,2
	loop	knoddas_2
	pop	ecx
	mov	eax,esi
	xor	edx,edx
	div	ecx
	add	ebp,eax
	inc	centercount
	cmp	ebx,0
	jnz	scancenterloop_2

	mov	eax,ebp
	mov	ebx,centercount
	xor	edx,edx
	div	ebx

	pop	ecx
	pop	edi

	mov	ebx,32768
	sub	ebx,eax
	mov	DCmove,ebx
centerit2:
	movzx	eax,word ptr [edi]
	add	eax,ebx
	cmp	eax,0
	jge	nosetboja12
	xor	eax,eax
nosetboja12:
	cmp	eax,65535
	jbe	nosetbojja12
	mov	ax,65535
nosetbojja12:
	stosw
	loop	centerit2

fixaend4:
	popad
	ret

EffectAddEffect:			;- Effect add effect ---------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
EffectAddEffectDouble:
	mov	OldPosList,-1
	mov	EffectSaveNow,1
	call	CheckIfNowFastPreview
	mov	eax,[alloctable+1047*8]
	cmp	word ptr [eax+4],0
	jz	_retp

	cmp	ListTableNumber,MaxList
	jz	_retp
	inc	ListTableNumber
	cmp	ListTableNumber,0
	jz	SkipMoveList

	lea	edi,ListTable
	mov	eax,ListTableNumber
	dec	eax
	shl	eax,1
	add	edi,eax
	mov	esi,edi
	sub	esi,2
	mov	ecx,ListTableNumber
	dec	ecx
	sub	ecx,CurrentList
	std
	rep	movsw
	cld

SkipMoveList:
	lea	edi,ListTable
	mov	eax,CurrentList
	shl	eax,1
	add	edi,eax
	mov	eax,CurrentSingle
	mov	ebx,[alloctable+1049*8]
	mov	eax,[eax*4+ebx]
	sub	eax,EffectPosStart
	shr	eax,5
	mov	[edi],ax

	call	ShowListEffect
	popad
	ret


EffectDelEffect:			;- Effect del effect ---------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp

DelListan:
	mov	OldPosList,-1
	mov	EffectSaveNow,1
	cmp	ListTableNumber,0
	jz	_retp
	call	CheckIfNowFastPreview
	dec	ListTableNumber

	lea	edi,ListTable
	mov	eax,CurrentList
	shl	eax,1
	add	edi,eax
	mov	esi,edi
	add	esi,2
	mov	ecx,ListTableNumber
	sub	ecx,CurrentList
	rep	movsw


	mov	eax,ListTableNumber
	cmp	eax,0
	jnz	NoZeroList
	mov	CurrentList,0
	mov	PosList,0
	jmp	EndOfDelen
NoZeroList:
	dec	eax
	cmp	CurrentList,eax
	jbe	Noprobbs1notta
	mov	CurrentList,eax
NoProbbs1notta:
	cmp	PosList,eax
	jbe	Noprobbs2notta
	mov	PosList,eax
NoProbbs2notta:
EndOfDelen:
	call	ShowListEffect
	popad
	ret

NameSelect	db	0		;0=New 1=Rename 2=Copy new
NewMultiPopup:				;New multi popup --------------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	call	CheckIfNowFastPreview
	mov	EffectSaveNow,1
	mov	OldPosMulti,-1
	mov	OldPosList,-1
	mov	OldPosSingle,-1

	lea	edi,NameMultiBuffer		;clear buffer
	mov	al,' '
	mov	ecx,28
	rep	stosb

	mov	NameSelect,0
	call	showmultiname

	popad
	ret

RenameMultiPopup:			;Rename multi popup -----------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	EffectSaveNow,1
	mov	OldPosMulti,-1
	mov	OldPosList,-1
	mov	OldPosSingle,-1

	mov	edi,[alloctable+1047*8]
	cmp	word ptr [edi+2],0
	jz	_retp

	call	CheckIfNowFastPreview
	lea	edi,NameMultiBuffer		;move name buffer
	mov	eax,[alloctable+1048*8]
	mov	ebx,CurrentMulti
	mov	esi,[eax+ebx*4]
	add	esi,[alloctable+1047*8]
	mov	ecx,28
	rep	movsb

	mov	NameSelect,1
	call	showmultiname

	popad
	ret

ShowMultiName:				;Show multi name ---------------------
	pushad
	mov	SecondPopup,38
	call	MenuHandler




	move	edi,0a0000h+208/8+255*80	;write name
	lea	esi,NameMultiBuffer
	call	mouseoff
	mov	fontplane,2
	mov	ecx,28
	mov	ah,1
PutTextLoop1__:
	push	ecx
	movzx	ebx,byte ptr [esi]
	inc	esi
	call	PutCharacter
	inc	edi
	pop	ecx
	loop	PutTextLoop1__

	move	edi,0a0000h+176/8+230*80	;write top text
	lea	esi,EffText4
	call	mouseoff
	mov	ah,8
PutTextLoop2__:
	movzx	ebx,byte ptr [esi]
	inc	esi
	call	PutCharacter
	inc	edi
	cmp	byte ptr [esi],'$'
	jnz	PutTextLoop2__
	mov	fontplane,0
	call	mouseon

	popad
	ret
CancelNewMultiEffect2:
	pushad
	jmp	Gurka1
CancelNewMultiEffect:			;Cancel new multi effect -----------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
Gurka1:
	call	CheckIfNowFastPreview
	mov	SecondPopup,-1
	call	MenuHandler


	popad
	ret

OkayNewMultiEffect2:
	pushad
	jmp	Gurka2
OkayNewMultiEffect:			;Okay new multi effect -------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
Gurka2:
	call	CheckIfNowFastPreview
	mov	SecondPopup,-1
	call	MenuHandler

	cmp	nameselect,0		;select new
	jnz	nonewa
	mov	edi,[alloctable+1047*8]
	cmp	word ptr [edi+2],65535
	jz	_retp
	mov	ebp,1047
	mov	esi,6
	mov	ecx,30
	call	ChangeOffsetsIns
	call	MakeAllocSpace
	lea	esi,NameMultiBuffer
	mov	edi,[alloctable+1047*8]
	inc	word ptr [edi+2]
	add	edi,6
	mov	ecx,28
	rep	movsb
	mov	word ptr [edi],-1
	call	InitEffects
	call	ShowMultiEffect
	popad
	ret
nonewa:

	cmp	nameselect,1		;select rename
	jnz	norename

	mov	eax,CurrentMulti
	mov	ebx,[alloctable+1048*8]
	mov	edi,[eax*4+ebx]
	add	edi,[alloctable+1047*8]
	mov	ecx,28
	lea	esi,NameMultiBuffer
	rep	movsb

	call	InitEffects
	call	ShowMultiEffect
	popad
	ret
norename:

	cmp	nameselect,2		;select new+listsave
	jnz	nonewa2
	mov	edi,[alloctable+1047*8]
	cmp	word ptr [edi+2],65535
	jz	_retp
	mov	ebp,1047
	mov	esi,6
	mov	ecx,30
	call	ChangeOffsetsIns
	call	MakeAllocSpace
	lea	esi,NameMultiBuffer
	mov	edi,[alloctable+1047*8]
	inc	word ptr [edi+2]
	add	edi,6
	mov	ecx,28
	rep	movsb
	mov	word ptr [edi],-1

	mov	nomulti,1
	call	InitEffects

	mov	ecx,[alloctable+1048*8+4]
	shr	ecx,2
	mov	edi,[alloctable+1048*8]
	xor	ebx,ebx
	jecxz	_retp
Loket:
	cmp	dword ptr [edi],6
	jz	ojakk
	inc	ebx
	add	edi,4
	loop	loket
	jmp	_retp
ojakk:
	mov	CurrentMulti,ebx
	call	DoTheListSave
	popad
	ret
nonewa2:

	popad
	ret
MultiNameInput: 			;Multi Name Input -----------------
	pushad

	mov	edi,208/8+255*80
	lea	esi,NameMultiBuffer
	mov	ecx,28
	mov	ax,0123h
	mov	InputVirtMax,28
	call	InputRoutine
	popad
	ret

EffectSaveList: 			;Effect save list ------------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	call	CheckIfNowFastPreview
	;cmp	 ListTableNumber,0
	;jz	 _retp
	mov	EffectSaveNow,1
	mov	edi,[alloctable+1047*8]
	cmp	word ptr [edi+2],0
	jz	StartNewa

	lea	esi,EffText5		;check popup
	mov	SpecialSecondPopup,1
	mov	SecondPopup,37
	mov	SpecialTextOffset,205*80+14
	call	popuphandler
	mov	SpecialTextOffset,0
	mov	SpecialSecondPopup,0
	movzx	eax,popupstatus
	cmp	eax,0
	jz	StartNewa
	call	DoTheListSave
	popad
	ret
StartNewa:
	lea	edi,NameMultiBuffer		;clear buffer
	mov	al,' '
	mov	ecx,28
	rep	stosb
	mov	NameSelect,2
	call	ShowMultiName
	popad
	ret
Oja1	dd	0
Oja2	dd	0
Oja3	dd	0

DoTheListSave:				;Do The Listsave -------------------
	pushad
	mov	EffectSaveNow,1

	mov	eax,CurrentMulti
	mov	ebx,[alloctable+1048*8]
	mov	eax,[ebx+eax*4]
	add	eax,28
	mov	ebx,-2
	mov	ecx,[alloctable+1047*8]
	sub	ecx,2
Scanna:
	add	ebx,2
	add	ecx,2
	cmp	word ptr [eax+ecx],-1
	jnz	Scanna

	mov	esi,eax
	mov	ebp,1047
	mov	ecx,ebx

	call	ChangeOffsetsDel
	call	DelAllocSpace

	mov	nomulti,1
	call	InitEffects

	mov	ecx,ListTableNumber
	shl	ecx,1

	call	ChangeOffsetsIns
	call	MakeAllocSpace

	mov	edi,esi
	add	edi,[alloctable+1047*8]
	lea	esi,ListTable
	mov	ecx,ListTableNumber
	rep	movsw

	call	InitEffects
	call	ShowMultiEffect
	call	ShowListEffect

	popad
	ret

TheNumber	dd	0
DelRealEffecten:			;Del Real Effecten -----------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp

	mov	OldPosMulti,-1
	mov	OldPosList,-1
	mov	OldPosSingle,-1

	mov	EffectSaveNow,1

	call	CheckIfNowFastPreview
	mov	eax,[alloctable+1047*8]
	cmp	word ptr [eax+4],0
	jz	_retp

	lea	esi,EffText6		;check popup
	mov	SpecialSecondPopup,1
	mov	SecondPopup,37
	mov	SpecialTextOffset,205*80+14
	call	popuphandler
	mov	SpecialTextOffset,0
	mov	SpecialSecondPopup,0
	movzx	eax,popupstatus
	cmp	eax,0
	jz	_retp



	mov	eax,CurrentSingle	;delete in multieffects
	mov	ebx,[alloctable+1049*8]
	mov	eax,[eax*4+ebx]
	mov	ebp,eax
	sub	eax,EffectPosStart
	shr	eax,5
	mov	TheNumber,eax
	mov	ebx,[alloctable+1047*8]
	movzx	ecx,word ptr [ebx+2]
	jecxz	NoMultiScan
	add	ebx,6
	mov	esi,6
ScanMultiScan:
	push	ecx
	add	ebx,28
	add	esi,28

OjaScan2:
	cmp	word ptr [ebx],-1
	jz	nothingnalle
	cmp	[ebx],ax
	jnz	nothis
	pushad
	mov	ebp,1047
	mov	ecx,2
	call	ChangeOffsetsDel
	call	DelAllocSpace
	popad
	sub	esi,2
nothis:
	add	esi,2
	mov	ebx,esi
	add	ebx,[alloctable+1047*8]
	cmp	word ptr [ebx],-1
	jnz	OjaScan2
nothingnalle:
	add	ebx,2
	add	esi,2
	pop	ecx
	loop	ScanMultiScan

NoMultiScan:

					;delete the effect data
	mov	NoMulti,1
	call	InitEffects
	mov	eax,CurrentSingle
	mov	ebx,[alloctable+1049*8]
	mov	esi,[eax*4+ebx]
	add	esi,[alloctable+1047*8]
	mov	esi,[esi+28]

	push	esi
	add	esi,[alloctable+1047*8]
	mov	eax,-1
	mov	ebx,0
	call	ScanEffect
	pop	esi

	mov	ebp,1047
	call	ChangeOffsetsDel
	call	DelAllocSpace
					;del effect name

	mov	eax,CurrentSingle
	mov	ebx,[alloctable+1049*8]
	mov	esi,[eax*4+ebx]
	mov	ecx,32
	mov	ebp,1047
	call	ChangeOffsetsDel
	call	DelAllocSpace

					;change effectnumber
					;in multieffect
	mov	eax,TheNumber
	mov	esi,[alloctable+1047*8]
	movzx	ecx,word ptr [esi+2]
	jecxz	nonamechange
	add	esi,6
ScannaJa:
	push	ecx
	add	esi,28
skoja1:
	cmp	word ptr [esi],-1
	jz	direkt
	cmp	[esi],ax
	jbe	nodiffa
	dec	word ptr [esi]
nodiffa:
	add	esi,2
	cmp	word ptr [esi],-1
	jnz	skoja1
direkt:
	add	esi,2
	pop	ecx
	loop	Scannaja

NoNameChange:


					;change pos
	mov	eax,[alloctable+1047*8]
	dec	word ptr [eax+4]
	movzx	eax,word ptr [eax+4]
	dec	eax
	cmp	CurrentSingle,eax
	jbe	notmatter1
	mov	CurrentSingle,eax
notmatter1:
	cmp	PosSingle,eax
	jbe	notmatter2
	mov	PosSingle,eax
notmatter2:

	call	InitEffects
	call	ShowSingleEffect
	call	ShowListEffect

	popad
	ret
Scan_voice	dd	0
Scan_pos	dd	0
Scan_oldEsi	dd	0
ScanEffect:				;scan effect -----------------------
;calls: 	esi=offset to effect
;		eax=voice number (-1=scan effect size)
;		ebx=pos in voice (0=General 1=Delay 2=Pitch 3=Volume)
;
;Back:		esi=New offset
;		ecx=scan size

	push	eax ebx edx edi ebp
	mov	Scan_Voice,eax
	mov	Scan_pos,ebx
	mov	Scan_oldESI,esi

	cmp	Scan_voice,-1		;get max
	jnz	noendscan
	mov	Scan_Pos,0
	movzx	eax,word ptr [esi]
	mov	Scan_Voice,eax
NoEndScan:
	xor	ebx,ebx 		;scan voice loopen
	add	esi,13
ScanLoppan:
	cmp	ebx,Scan_voice
	jz	ThisIsRightVoice
	add	esi,21
	movzx	eax,word ptr [esi-2]
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,14
	movzx	eax,word ptr [esi-2]
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,11
	movzx	eax,word ptr [esi-2]
	lea	eax,[eax*8+eax]
	add	esi,eax
	inc	ebx
	jmp	ScanLoppan
ThisIsRightVoice:			;scan pos loopen
	cmp	Scan_pos,0
	jz	ThisIsRightPos

	add	esi,10
	cmp	Scan_pos,1
	jz	ThisIsRightPos

	add	esi,11
	movzx	eax,word ptr [esi-2]
	lea	eax,[eax*8+eax]
	add	esi,eax
	cmp	Scan_pos,2
	jz	ThisIsRightPos

	add	esi,14
	movzx	eax,word ptr [esi-2]
	lea	eax,[eax*8+eax]
	add	esi,eax
	cmp	Scan_pos,3
	jz	ThisIsRightPos

	add	esi,11
	movzx	eax,word ptr [esi-2]
	lea	eax,[eax*8+eax]
	add	esi,eax

ThisIsRightPos:
	mov	ecx,esi
	sub	ecx,Scan_oldESI
	pop	ebp edi edx ebx eax
	ret


NewEffectData	    Label   Word;----------------------- New Effect Data
	dw	1	      		;86
	db	0
	dd	10000
	db	0    ;**
	dw	11   ;**
	db	0 ;---
	dw	0

NewEffectVoice	db	0,0,0      	;voice 1 73
	dw      0
	db	0
	dw	1024,1024

	dd	0
	db	0
	dw	0,0,1
		dd	0
		dd	0
		db	3

	dd	0
	db	0
	dw	1024
	db	0
	dw	0,0,1
		dd	0
		dd	0
		db	3

	dd	10000
	db	0
	dw	0,0,1
		dd	0
		dd	0
		db	3

		;84 bytes

;Ú¿ ÚÄ¿ ÚÄ¿ÚÄÄ¿ ÚÄ¿  ÚÄÄ¿ ÚÄÄ¿	ÚÄÄ¿ ÚÄ¿ ÚÄÄÄ¿	ÚÄÄ¿ÚÄÄ¿  ÚÄÄ¿	ÚÄÄÄ¿ÚÄ¿ ÚÄÄ¿
;ÃÅÄÅÄÅÄÅÄÅÅÄÄÅÄÅÄÅÄÄÅÄÄÅÄÅÄÄÅÄÄÅÄÄÅÄÅÄÅÄÅÄÄÄÅÄÄÅÄÄÅÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÄÅÅÄÅÄÅÄÄÅ
;³³ ³ ³ ³ ³ÃÄ ³ ³ ³  ³	³ ³  ³	³  ³ ³ ³ ³   ³	³  ³³  ³  ³  ³	³   ³³ ³ ³  À
; ÀÄÙ ÀÄÙ ÀÙ  ÀÄÙ ÀÄÄÙ	ÀÄÙ  ÀÄÄÙ  ÀÄÙ ÀÄÙ   ÀÄÄÙ  ÀÙ  ÀÄÄÙ  ÀÄÄÙ   ÀÙ ÀÄÙ
;
;
;
;			   E F F E C T	  E D I T
;
;
;Ú¿ ÚÄ¿ ÚÄ¿ÚÄÄ¿ ÚÄ¿  ÚÄÄ¿ ÚÄÄ¿	ÚÄÄ¿ ÚÄ¿ ÚÄÄÄ¿	ÚÄÄ¿ÚÄÄ¿  ÚÄÄ¿	ÚÄÄÄ¿ÚÄ¿ ÚÄÄ¿
;ÃÅÄÅÄÅÄÅÄÅÅÄÄÅÄÅÄÅÄÄÅÄÄÅÄÅÄÄÅÄÄÅÄÄÅÄÅÄÅÄÅÄÄÄÅÄÄÅÄÄÅÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÄÅÅÄÅÄÅÄÄÅ
;³³ ³ ³ ³ ³ÃÄ ³ ³ ³  ³	³ ³  ³	³  ³ ³ ³ ³   ³	³  ³³  ³  ³  ³	³   ³³ ³ ³  À
; ÀÄÙ ÀÄÙ ÀÙ  ÀÄÙ ÀÄÄÙ	ÀÄÙ  ÀÄÄÙ  ÀÄÙ ÀÄÙ   ÀÄÄÙ  ÀÙ  ÀÄÄÙ  ÀÄÄÙ   ÀÙ ÀÄÙ

EffectMasterSelect	dd  0		;0=delay,1=pitch,2=volume
EffectEnvelopeSelect	dd  0		;0=delay,1=pitch,2=volume,3=time etc.
LastEnvSelect		dd  0
TheEffectName		db  28 dup(' ')
StartEffectMode 	db  0		;0=new start,1=edit start
OldEffectSize		dd  0
VoiceEnvNumber		dd  0		;the voice
VoiceMastNumber 	dd  0		;the voice
VoiceBreakSwap		dd  0
VoiceInvarSwap		db  0

EnvelopePointNummer	dd  0		;Current point

MasterCurvePos		dd  0
MasterCurveYZoomSize	dd  0
MasterCurveYZoomPos	dd  0


ZoomCurveData		dd  5720,5720,333050,666500,334000,334000
ZoomEnvCurveDataY	dd  5720,5720,333050,666500,334000,334000
ZoomEnvCurveDataX	dd  10000,10000,10000


EnvelopeDotBuffer	dw  281*3	dup(0)	;X,Y,DotNr
EnvelopeDotBufferPtr	dd  0
EnvTimePos		dd  0
EnvTimeZoom		dd  10000	   ;1000 ->
EnvCurveYZoomPos	dd  14287
EnvCurveYZoomSize	dd  14286

ChooseBreaken		db	0	;0=Time variant,1=Time invariant


NewEffectEdit:		    		;New Effect Edit
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	call	CheckIfNowFastPreview
	mov	EffectSaveNow,1

	mov	ebp,1051
	xor	ebx,ebx
	mov	eax,86
	call	memalloc
	jc	RemoveMemory
	mov	edi,eax
	lea	esi,neweffectData
	mov	ecx,86
	rep	movsb

	lea	edi,TheEffectName
	mov	al,' '
	mov	ecx,28
	rep	stosb
	mov	StartEffectMode,0
	jmp	DoShowThings

EffectEdit:				;Effect Edit ------------------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	EffectSaveNow,1

	call	CheckIfNowFastPreview
	mov	eax,[alloctable+1047*8]
	cmp	word ptr [eax+4],0
	jz	_retp
						;load effect
	mov	ebx,[alloctable+1049*8]
	mov	eax,CurrentSingle
	mov	esi,[eax*4+ebx]
	add	esi,[alloctable+1047*8]
	lea	edi,TheEffectName
	mov	ecx,28
	rep	movsb
	mov	esi,[esi]
	mov	edi,esi
	add	esi,[alloctable+1047*8]
	mov	eax,-1
	mov	ebx,0
	call	ScanEffect
	mov	OldEffectSize,ecx
	mov	eax,ecx
	xor	ebx,ebx
	mov	ebp,1051
	call	memalloc
	jc	RemoveMemory
	add	edi,[alloctable+1047*8]
	mov	esi,eax
	xchg	edi,esi
	rep	movsb
	mov	StartEffectMode,1
DoShowThings:

	mov	VoiceEnvNumber,0
	mov	VoiceMastNumber,0
	mov	EnvelopePointNummer,0
	mov	MasterCurvePos,0
	mov	EffectMasterSelect,0
	mov	EffectEnvelopeSelect,0

	call	GetZoomDataEnv
	lea	esi,EffectEditMainPicture	;show things
	mov	DrawSpecial,2
	call	DrawPopUp
	mov	word ptr [currentmenu],39
	mov	menu_popup,39
	mov	eax,0
	mov	ebp,EffectMasterSelect
	call	SwitchZoomData
	mov	LastEnvSelect,3
	call	ShowEffectEnv
	call	PrintEffectName
	call	PrintTotalVoices
	mov	VoiceEnvNumber,0
	call	UpdateEnvelope
	call	UpdateMaster
	call	UpdateVoiceBreak

	mov	eax,[alloctable+1051*8]
	xor	ebx,ebx
	cmp	byte ptr [eax+2],0
	jz	noken
	mov	ebx,10000
noken:
	mov	VoiceBreakSwap,ebx

	xor	ebx,ebx
	cmp	byte ptr [eax+10],0
	jnz	noken2
	mov	ebx,1
noken2:
	mov	VoiceInvarSwap,bl

	call	PutSmooth
	call	ShowSmooth
	call	PutBreaken


	call	PutDragbarData

	mov	eax,[alloctable+1051*8]
	movzx	eax,word ptr [eax]
	mov	edx,35
	cmp	eax,35
	jae	noboka3
	mov	edx,eax
noboka3:

	mov	dword ptr [MastCurveHorz1+8],eax
	mov	dword ptr [MastCurveHorz2+8],eax
	mov	dword ptr [MastCurveHorz1+12],edx
	mov	dword ptr [MastCurveHorz2+12],edx
	mov	dword ptr [MastCurveHorz1+4],1
	mov	dword ptr [MastCurveHorz2+4],1

	popad
	ret

;******************************************************************************
;			     NAME AND TOTAL PART
;******************************************************************************
ChangeEffectName:			;Change effect name -----------------
	pushad
	mov	edi,168/8+39*80
	lea	esi,TheEffectName
	mov	ecx,28
	mov	ax,0113h
	mov	InputVirtMax,28
	call	InputRoutine
	popad
	ret
PrintEffectName:			;Print effect name ------------------
	pushad
	call	mouseoff
	mov	fontplane,1
	move	edi,0a0000h+168/8+39*80
	lea	esi,TheEffectName
	mov	ecx,28
PutEffName:
	push	ecx
	movzx	ebx,byte ptr [esi]
	mov	ah,00000001b
	call	putcharacter
	inc	edi
	inc	esi
	pop	ecx
	loop	PutEffName
	mov	fontplane,0
	call	mouseon
	popad
	ret
PrintTotalVoices:			;Print total voices ------------------
	pushad

	call	mouseoff
	mov	fontplane,1
	mov	eax,[alloctable+1051*8]
	movzx	ebx,word ptr [eax]
	mov	ah,1
	mov	cl,5
	move	edi,0a0000h+168/8+57*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon

	popad
	ret
CreateVoice:				;Create voice ----------------------
	pushad

	mov	eax,[alloctable+1051*8+4]
	mov	ebx,[alloctable+1051*8]
	cmp	word ptr [ebx],65535
	jz	_retp
	add	eax,73
	xor	ebx,ebx
	mov	ebp,1051
	call	memalloc
	jc	RemoveMemory
	mov	edi,[alloctable+1051*8+4]
	add	edi,eax
	sub	edi,73
	lea	esi,NewEffectVoice
	mov	ecx,73
	rep	movsb
	mov	eax,[alloctable+1051*8]
	inc	word ptr [eax]
	call	PrintTotalVoices
	mov	eax,[alloctable+1051*8]
	movzx	eax,word ptr [eax]
	mov	edx,35
	cmp	eax,35
	jae	noboka
	mov	edx,eax
noboka:

	mov	dword ptr [MastCurveHorz1+8],eax
	mov	dword ptr [MastCurveHorz2+8],eax
	mov	dword ptr [MastCurveHorz1+12],edx
	mov	dword ptr [MastCurveHorz2+12],edx
	mov	dword ptr [MastCurveHorz1+4],1
	mov	dword ptr [MastCurveHorz2+4],1

	popad
	ret
DeleteVoice:				;Delete voice -----------------------
	pushad

	mov	eax,[alloctable+1051*8]
	cmp	word ptr [eax],1
	jz	_retp
	dec	word ptr [eax]
	mov	esi,eax
	movzx	eax,word ptr [esi]
	xor	ebx,ebx
	call	scaneffect


	mov	eax,ecx
 	xor	ebx,ebx
 	mov	ebp,1051
 	call	memalloc
 	jc	RemoveMemory
	call	PrintTotalVoices
	mov	eax,[alloctable+1051*8]
	movzx	eax,word ptr [eax]
	mov	edx,35
	cmp	eax,35
	jae	noboka2
	mov	edx,eax
noboka2:

	mov	dword ptr [MastCurveHorz1+8],eax
	mov	dword ptr [MastCurveHorz2+8],eax
	mov	dword ptr [MastCurveHorz1+12],edx
	mov	dword ptr [MastCurveHorz2+12],edx
	mov	dword ptr [MastCurveHorz1+4],1
	mov	dword ptr [MastCurveHorz2+4],1

	popad
	ret
CheckVoiceUpdate:			;Check voice update -----------------
	pushad
	mov	eax,[alloctable+1051*8]
	movzx	eax,word ptr [eax]
	dec	eax
	cmp	VoiceMastNumber,eax
	jbe	noprobbs1
	mov	VoiceMastNumber,eax
	call	PrintVoiceMastNumber
noprobbs1:
	cmp	VoiceEnvNumber,eax
	jbe	noprobbs2
	mov	VoiceEnvNumber,eax
	call	PrintVoiceEnvNumber
	call	UpdateEnvelope
noprobbs2:
	mov	ebx,[alloctable+1051*8]
	cmp	byte ptr [ebx+2],0
	jz	noprobbs3
	mov	ebp,[ebx+3]
	cmp	ebp,eax
	jbe	noprobbs3
	mov	[ebx+3],eax
	call	PrintSizeAndNum
noprobbs3:
	mov	ebx,[alloctable+1051*8]
	cmp	[ebx+11],ax
	jbe	nognull1
	mov	[ebx+11],ax
	call	PrintSizeAndNum
nognull1:
	popad
	ret
TotalVoiceUp:				;Total Voice up ---------------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	call	createvoice
	call	ViewMasterCurve
	popad
	ret
TotalVoiceDown:				;Total Voice down -------------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	call	DeleteVoice
	call	checkvoiceupdate
	call	ViewMasterCurve
	popad
	ret
TotalVar	dd	0
TotalVoiceUdrag:			;Total voice udrag -----------------
	pushad

	call	CheckIfNowFastPreview
	mov	eax,[alloctable+1051*8]
	movzx	eax,word ptr [eax]
	mov	totalvar,eax

	mov	UdragStatus,1
	mov	eax,[alloctable+1051*8]
	mov	eax,10
	mov	ebx,1024*10
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	mov	eax,[alloctable+1051*8]
	movzx	eax,word ptr [eax]
	dec	eax
	mov	UdragMaxValue,65535
	mov	UdragMiniValue,1
	lea	eax,TotalVar
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,TotalMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret
TotalMeanWhile:
	pushad
	call	checkvoiceupdate
	mov	eax,[alloctable+1051*8]
	mov	ebx,totalvar
	cmp	bx,[eax]
	jz	_retp
	ja	createit
	mov	cx,[eax]
	sub	cx,bx
	and	ecx,0ffffh
delaloopa:
	call	deletevoice
	loop	delaloopa
	call	ViewMasterCurve
	popad
	ret
createit:
	mov	cx,bx
	mov	bx,[eax]
	sub	cx,bx
	and	ecx,0ffffh
delaloopa2:
	call	createvoice
	loop	delaloopa2
	call	ViewMasterCurve

	popad
	ret
TotalVoicesInput:			;Total voices input ------------------
	pushad

	call	CheckIfNowFastPreview
	mov	eax,[alloctable+1051*8]
	movzx	eax,word ptr [eax]
	mov	totalvar,eax
	move	edi,0a0000h+168/8+57*80
	mov	ax,0111h
	lea	ebp,Totalvar
	mov	ecx,5
	mov	ebx,0
	mov	edx,65535
	lea	esi,TotalMeanWhile
	mov	digitsize,3
	call	ZyricInput

	popad
	ret



;******************************************************************************
;				   SMOOTH
;******************************************************************************
ShowSmooth:				;Show Smooth
	pushad
	call	mouseoff
	mov	esi,[alloctable+1051*8]
	mov	al,[esi+7]

	mov	buttonX1,75
	mov	buttonY1,104
	mov	buttonX2,85
	mov	buttonY2,115
	mov	bl,1
	cmp	al,0
	jnz	bora1_A
	xor	bl,1
bora1_A:
	call	buttonupdown
	mov	buttonX1,75
	mov	buttonY1,117
	mov	buttonX2,85
	mov	buttonY2,127
	mov	bl,1
	cmp	al,1
	jnz	bora2_A
	xor	bl,1
bora2_A:
	call	buttonupdown
	mov	buttonX1,75
	mov	buttonY1,130
	mov	buttonX2,85
	mov	buttonY2,141
	mov	bl,1
	cmp	al,2
	jnz	bora3_A
	xor	bl,1
bora3_A:
	call	buttonupdown

	call	mouseon
	popad
	ret
NoSmooth:				;NoSmooth ---------------------------

	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	mov	byte ptr [esi+7],0
	call	ShowSmooth
	popad
	ret

C4Smooth:				;C4Smooth ---------------------------

	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	mov	byte ptr [esi+7],1
	call	ShowSmooth
	popad
	ret

FixedSmooth:				;FixedSmooth ---------------------------
	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	mov	byte ptr [esi+7],2
	call	ShowSmooth
	popad
	ret

PutSmooth:				;Put Smooth -----------------------

	pushad
	call	mouseoff
	mov	esi,[alloctable+1051*8]
	movzx	ebx,word ptr [esi+8]
	mov	ah,1
	mov	cl,5
	move	edi,0a0000h+88/8+161*80
	mov	fontplane,1
	call	PutDecimal
	mov	FontPlane,0
	call	mouseon
	call	mousereset
	call	mouseon
	popad
	ret

SmoothArrowUp:				;SmoothArrowUp ---------------------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	mov	esi,[alloctable+1051*8]
	cmp	word ptr [esi+8],65535
	jz	_retp
	inc	word ptr [esi+8]
	call	PutSmooth
	popad
	ret
SmoothArrowDown:			;SmoothArrowDown ---------------------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	mov	esi,[alloctable+1051*8]
	cmp	word ptr [esi+8],2
	jz	_retp
	dec	word ptr [esi+8]
	call	PutSmooth
	popad
	ret
SmoothUdrag:				;SmoothUdrag ---------------------------

	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	movzx	eax,word ptr [esi+8]
	mov	TimeVaren,eax

	mov	UdragStatus,1   		;udrag size
	mov	eax,2000
	mov	ebx,1024
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,65535
	mov	UdragMiniValue,2
	lea	eax,TimeVaren
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,SmoothUdragen
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret

SmoothUdragen:
	pushad
	mov	esi,[alloctable+1051*8]
	mov	eax,TimeVaren
	mov	word ptr [esi+8],ax
	call	PutSmooth
	popad
	ret
SmoothInput:				;SmoothInput ---------------------------
	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	movzx	eax,word ptr [esi+8]
	mov	TimeVaren,eax

	move	edi,0a0000h+88/8+161*80
	mov	ax,0111h
	lea	ebp,TimeVaren
	mov	ecx,5
	mov	ebx,2
	mov	edx,65535
	lea	esi,SmoothUdragen
	mov	digitsize,3
	call	ZyricInput
	popad
	ret


;******************************************************************************
;				VOICE BREAK
;******************************************************************************
PutBreaken:				;Put Breaken -------------------------

	pushad
	call	mouseoff
	mov	buttonX1,243
	mov	buttonY1,159
	mov	buttonX2,315
	mov	buttonY2,175
	mov	eax,[alloctable+1051*8]
	mov	bl,0
 	cmp	byte ptr [eax+10],0
	jz	nothissa
	xor	bl,1
nothissa:
	call	buttonupdown
	mov	buttonX1,316
	mov	buttonY1,159
	mov	buttonX2,402
	mov	buttonY2,175
	xor	bl,1
	call	buttonupdown
	call	mouseon
	popad
	ret

SetTimeVar:				;Set Time Var  -----------------------
	pushad
	mov	eax,[alloctable+1051*8]
 	cmp	byte ptr [eax+10],0
 	jz	_retp
	call	SwapInvar
	call	PutBreaken
	call	SetVoiceBreakButtons
	call	PrintSizeAndNum
	popad
	ret
SetTimeInvar:				;Set Time Invar ----------------------
	pushad
	mov	eax,[alloctable+1051*8]
 	cmp	byte ptr [eax+10],0
 	jnz	_retp
	call	SwapInvar
	call	PutBreaken
	call	SetVoiceBreakButtons
	call	PrintSizeAndNum
	popad
	ret

UpdateVoiceBreak:			;Update voice break ------------------
	pushad
	call	SetVoiceBreakButtons
	call	PrintSizeAndNum
	popad
	ret

SetVoiceBreakButtons:			;Set Voice Break Buttons ------------

	pushad
	call	mouseoff
	mov	ebx,[alloctable+1051*8]
	mov	ah,[ebx+2]
	mov	al,[ebx+10]
	mov	buttonX1,235
	mov	buttonY1,117
	mov	buttonX2,245
	mov	buttonY2,127
	mov	bl,1
	cmp	al,0
	jnz	noskolaboj0
	cmp	ah,0
	jnz	noskolaboj0
	xor	bl,1
noskolaboj0:
	call	buttonupdown
	mov	buttonX1,235
	mov	buttonY1,130
	mov	buttonX2,245
	mov	buttonY2,141
	mov	bl,1
	cmp	al,0
	jnz	noskolaboj1
	cmp	ah,1
	jnz	noskolaboj1
	xor	bl,1
noskolaboj1:
	call	buttonupdown
	mov	buttonX1,403
	mov	buttonY1,117
	mov	buttonX2,413
	mov	buttonY2,128
	mov	bl,1
	cmp	al,1
	jnz	noskolaboj2
	xor	bl,1
noskolaboj2:
	call	buttonupdown
	call	buttonupdown
	mov	buttonX1,403
	mov	buttonY1,130
	mov	buttonX2,413
	mov	buttonY2,141
	mov	bl,1
	cmp	al,2
	jnz	noskolaboj3
	xor	bl,1
noskolaboj3:
	call	buttonupdown
	call	buttonupdown
	mov	buttonX1,403
	mov	buttonY1,143
	mov	buttonX2,413
	mov	buttonY2,154
	mov	bl,1
	cmp	al,3
	jnz	noskolaboj4
	xor	bl,1
noskolaboj4:
	call	buttonupdown
	call	mouseon
	popad
	ret

SwapInvar:				;Swap Invar -------------------------
	pushad
	mov	eax,[alloctable+1051*8]
	mov	bl,VoiceInvarSwap
	xchg	bl,[eax+10]
	mov	VoiceInvarSwap,bl
	popad
	ret

SwapChecka:				;Swap checka ------------------------
	pushad
	mov	eax,[alloctable+1051*8]
	mov	ecx,VoiceBreakSwap
	xchg	ecx,[eax+3]
	mov	VoiceBreakSwap,ecx
nojanoja22:
	popad
	ret

BreakButtSamp:				;Break Butt Samp --------------------
	pushad
	call	CheckIfNowFastPreview
	mov	eax,[alloctable+1051*8]
 	cmp	byte ptr [eax+10],0
 	jnz	godiset1
 	cmp	byte ptr [eax+2],0
 	jz	_retp
 	jmp	knalloja_
godiset1:
	call	SwapInvar
knalloja_:
	cmp	byte ptr [eax+2],0
	jz	knalloja
 	mov	byte ptr [eax+2],0
 	call	SwapChecka
knalloja:
 	call	UpdateVoiceBreak
	call	PutBreaken
	call	SetVoiceBreakButtons
	call	PrintSizeAndNum
	popad
	ret
BreakButtVoice:				;Break Butt Voice -------------------
	pushad
	call	CheckIfNowFastPreview
	mov	eax,[alloctable+1051*8]
 	cmp	byte ptr [eax+10],0
 	jnz	godiset2
 	cmp	byte ptr [eax+2],1
 	jz	_retp
 	jmp	knalloja2_
godiset2:
	call	SwapInvar
knalloja2_:
	cmp	byte ptr [eax+2],1
	jz	knalloja2
 	mov	byte ptr [eax+2],1
 	call	SwapChecka
knalloja2:
 	call	UpdateVoiceBreak
	call	PutBreaken
	call	SetVoiceBreakButtons
	call	PrintSizeAndNum
	popad
	ret
BreakButtDelay:				;Break Butt Delay -------------------
	pushad
	call	CheckIfNowFastPreview
	mov	eax,[alloctable+1051*8]
 	mov	byte ptr [eax+10],1
	mov	VoiceInvarSwap,0
 	call	UpdateVoiceBreak
	call	PutBreaken
	call	SetVoiceBreakButtons
	call	PrintSizeAndNum
	popad
	ret
BreakButtPitch:				;Break Butt Pitch -------------------
	pushad
	call	CheckIfNowFastPreview
	mov	eax,[alloctable+1051*8]
 	mov	byte ptr [eax+10],2
	mov	VoiceInvarSwap,0
 	call	UpdateVoiceBreak
	call	PutBreaken
	call	SetVoiceBreakButtons
	call	PrintSizeAndNum
	popad
	ret
BreakButtVolume:			;Break Butt Volume ------------------
	pushad
	call	CheckIfNowFastPreview
	mov	eax,[alloctable+1051*8]
 	mov	byte ptr [eax+10],3
	mov	VoiceInvarSwap,0
 	call	UpdateVoiceBreak
	call	PutBreaken
	call	SetVoiceBreakButtons
	call	PrintSizeAndNum
	popad
	ret

PrintSizeAndNum:			;Print Size and num -----------------
	pushad
	mov	ebx,[alloctable+1051*8]
	mov	ah,[ebx+2]
	mov	al,[ebx+10]
	mov	ebp,[ebx+3]

	cmp	al,0
	jnz	DoVoiceaInvariant
 	cmp	ah,1
 	jz	DoVoicea
					;do sizea
	call	mouseoff
	mov	fontplane,1
 	move	edi,0a0000h+(408+8*3)/8+162*80
	mov	ebx,'.'
	mov	ah,1
	call    PutCharacter
 	move	edi,0a0000h+(408+8*6)/8+162*80
	mov	ebx,'%'
	mov	ah,1
	call    PutCharacter

	mov	eax,ebp
	mov	ebx,100
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	mov	ah,1
	mov	cl,3
 	move	edi,0a0000h+(408+8*0)/8+162*80
	call	PutDecimal
	mov	ebx,edx
	mov	ah,1
	mov	cl,2
 	move	edi,0a0000h+(408+8*4)/8+162*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
	popad
	ret
DoVoicea:			    	;do voicea
	call	mouseoff
	mov	fontplane,1
	mov	ebx,ebp
	mov	ah,1
	mov	cl,7
	move	edi,0a0000h+408/8+162*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
	popad
	ret
DoVoiceaInvariant:		      	;do voicea invariant
	call	mouseoff
	movzx	ebx,word ptr [ebx+11]
	mov	fontplane,1
	mov	ah,1
	mov	cl,7
	move	edi,0a0000h+408/8+162*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
	popad
	ret

VoiceBreakUp:				;Voice break up -------------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	mov	ebx,[alloctable+1051*8]
	mov	ah,[ebx+2]
	mov	al,[ebx+10]
	mov	ebp,[ebx+3]
	cmp	al,0
	jnz	UpVoicea2
 	cmp	ah,1
 	jz	UpVoicea
					;Up sizea
	add	ebp,1
	cmp	ebp,60000
	jbe	goja
     	mov	ebp,60000
goja:
	mov	[ebx+3],ebp
	call	PrintSizeAndNum
	popad
	ret
UpVoicea:				;Up voicea
	add	ebp,1
	movzx	ecx,word ptr [ebx]
	dec	ecx
	cmp	ebp,ecx
	jbe	goja2
     	mov	ebp,ecx
goja2:
	mov	[ebx+3],ebp
	call	PrintSizeAndNum
	popad
	ret
UpVoicea2:				;Up voicea2
	movzx	ebp,word ptr [ebx+11]
	add	ebp,1
	movzx	ecx,word ptr [ebx]
	dec	ecx
	cmp	ebp,ecx
	jbe	goja2_
     	mov	ebp,ecx
goja2_:
	mov	[ebx+11],bp
	call	PrintSizeAndNum
	popad
	ret
VoiceBreakDown:				;Voice break down -------------------

	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	mov	ebx,[alloctable+1051*8]
	mov	ah,[ebx+2]
	mov	al,[ebx+10]

	mov	ebp,[ebx+3]
	cmp	byte ptr [ebx+10],0
	jz	noknollen2
	movzx	ebp,word ptr [ebx+11]
noknollen2:
	dec	ebp

	cmp	byte ptr [ebx+10],0
	jnz	checkminstvoice
	cmp	byte ptr [ebx+2],1
	jz	checkminstvoice
	cmp	ebp,1
	jge	aftervoicen
	mov	ebp,1
	jmp	aftervoicen
checkminstvoice:
	cmp	ebp,0
	jge	aftervoicen
	mov	ebp,0
aftervoicen:

	cmp	byte ptr [ebx+10],0
	jz	noknollen
	mov	[ebx+11],bp
	jmp	afterknollen
noknollen:
	mov	[ebx+3],ebp
afterknollen:
	call	PrintSizeAndNum
	popad
	ret


BreakVar	dd	0
VoiceBreakUdrag:			 ;voice break udrag ------------------

	pushad
	call	CheckIfNowFastPreview
	mov	ebx,[alloctable+1051*8]
	mov	ah,[ebx+2]
	mov	al,[ebx+10]
	mov	ebp,[ebx+3]
	cmp	byte ptr [ebx+10],0
	jz	noknollen3
	movzx	ebp,word ptr [ebx+11]
noknollen3:
	mov	BreakVar,ebp
	cmp	al,0
	jnz	UdragVoice
 	cmp	ah,1
 	jz	UdragVoice

	mov	UdragStatus,1   		;udrag size
	mov	eax,60000
	mov	ebx,1024
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,60000
	mov	UdragMiniValue,1
	lea	eax,BreakVar
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,UpdateBreak
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret
UpdateBreak:
	pushad
	mov	ebx,[alloctable+1051*8]
	mov	eax,BreakVar
	cmp	byte ptr [ebx+10],0
	jz	noknollen5
	mov	[ebx+11],ax
	call	PrintSizeAndNum
	popad
	ret
noknollen5:
	mov	[ebx+3],eax
	call	PrintSizeAndNum
	popad
	ret
UdragVoice:
	mov	UdragStatus,1   		;udrag size
	movzx	ebp,word ptr [ebx]
	dec	ebp
	mov	eax,ebp
	mov	ebx,1024*10
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,ebp
	mov	UdragMiniValue,0
	lea	eax,BreakVar
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,UpdateBreak
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret


;******************************************************************************
;				 MASTER PART
;******************************************************************************
UpdateMaster:				;UpdateMaster --------------------
	pushad
	call	PrintVoiceMastNumber
	call	ShowEffectMast
	call	PrintMasterValue
	call	ViewMasterCurve
	;mov	OldPosMast,-1
	popad
	ret
PrintVoiceMastNumber:			  ;Print voice mast number -------------
	pushad
	call	mouseoff
	mov	fontplane,1
	mov	ebx,VoiceMastNumber
	mov	ah,1
	mov	cl,5
	move	edi,0a0000h+144/8+188*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
	popad
	ret
VoiceMastNumUp: 			 ;Voice mast num up ------------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	mov	eax,[alloctable+1051*8]
	movzx	eax,word ptr [eax]
	dec	eax
	cmp	VoiceMastNumber,eax
	jz	_retp
	inc	VoiceMastNumber
	call	UpdateMaster
	mov	eax,VoiceMastNumber
	popad
	ret
VoiceMastNumDown:			 ;Voice mast num down ----------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	cmp	VoiceMastNumber,0
	jz	_retp
	dec	VoiceMastNumber
	call	UpdateMaster
	mov	eax,VoiceMastNumber
	popad
	ret

VoiceMastUdrag: 			 ;voice mast udrag ------------------

	pushad
	call	CheckIfNowFastPreview
	mov	UdragStatus,1
	mov	eax,[alloctable+1051*8]
	movzx	eax,word ptr [eax]
	mov	ebx,1024*10
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	mov	eax,[alloctable+1051*8]
	movzx	eax,word ptr [eax]
	dec	eax
	mov	UdragMaxValue,eax
	mov	UdragMiniValue,0
	lea	eax,VoiceMastNumber
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,UpdateMaster
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret

VoiceMastInput: 			 ;VoiceMastInput -------------------
	pushad
	call	CheckIfNowFastPreview
	move	edi,0a0000h+144/8+188*80
	mov	ax,0111h
	lea	ebp,VoiceMastNumber
	mov	ecx,5
	mov	ebx,0
	mov	edx,[alloctable+1051*8]
	movzx	edx,word ptr [edx]
	dec	edx
	lea	esi,UpdateMaster
	mov	digitsize,3
	call	ZyricInput
	popad
	ret

ShowEffectMast: 			;Show effect Mast ---------------------

	pushad
	call	mouseoff                ;draw buttons
	mov	buttonX1,75
	mov	buttonY1,224
	mov	buttonX2,85
	mov	buttonY2,234
	mov	bl,1
	cmp	EffectMasterSelect,0
	jnz	noskola0_
	xor	bl,1
noskola0_:
	call	buttonupdown
	mov	buttonX1,75
	mov	buttonY1,237
	mov	buttonX2,85
	mov	buttonY2,247
	mov	bl,1
	cmp	EffectMasterSelect,1
	jnz	noskola1_
	xor	bl,1
noskola1_:
	call	buttonupdown
	mov	buttonX1,75
	mov	buttonY1,250
	mov	buttonX2,85
	mov	buttonY2,261
	mov	bl,1
	cmp	EffectMasterSelect,2
	jnz	noskola2_
	xor	bl,1
noskola2_:
	call	buttonupdown
	call	mouseon
	popad
	ret

					;Mouse select master -------------
MouseMastDelay: 			 ;Delay -----
	call	CheckIfNowFastPreview
	mov	MasterCurvePos,0
	mov	eax,1
	mov	ebp,0
	call	SwitchZoomData
	mov	EffectMasterSelect,0
	call	UpdateMaster
	ret
MouseMastPitch: 			 ;Pitch -----
	call	CheckIfNowFastPreview
	mov	MasterCurvePos,0
	mov	eax,1
	mov	ebp,1
	call	SwitchZoomData
	mov	EffectMasterSelect,1
	call	UpdateMaster
	ret
MouseMastVolume:			 ;Volume ----
	call	CheckIfNowFastPreview
	mov	MasterCurvePos,0
	mov	eax,1
	mov	ebp,2
	call	SwitchZoomData
	mov	EffectMasterSelect,2
	call	UpdateMaster
	ret
PrintMasterValue:			;Print Master Value --------------

	pushad
	call	ViewMasterCurve
	cmp	EffectMasterSelect,0	;Delay *********
	jnz	noprintDelay
	call	mouseoff
	mov	fontplane,1
 	move	edi,0a0000h+(128+8*7-8)/8+206*80
	mov	ebx,'s'
	mov	ah,1
	call    PutCharacter
 	move	edi,0a0000h+(128+8*3-8)/8+206*80
	mov	ebx,'.'
	mov	ah,1
	call    PutCharacter
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceMastNumber
	mov	ebx,1
	call	ScanEffect
	mov	eax,[esi]
	mov	ebx,1000
	xor	edx,edx
	div	ebx
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	mov	ah,1
	mov	cl,3
 	move	edi,0a0000h+(128+8*0-8)/8+206*80
	call	PutDecimal
	mov	ebx,edx
	mov	ah,1
	mov	cl,3
 	move	edi,0a0000h+(128+8*4-8)/8+206*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
	popad
	ret

noprintdelay:
	cmp	EffectMasterSelect,1	;Pitch ***********
	jnz	noprintPitch
	call	mouseoff
	mov	fontplane,1
 	move	edi,0a0000h+(128+8*6-8)/8+206*80
	mov	ebx,'h'
	mov	ah,1
	call    PutCharacter
 	move	edi,0a0000h+(128+8*7-8)/8+206*80
	mov	ebx,'n'
	mov	ah,1
	call    PutCharacter
 	move	edi,0a0000h+(128+8*3-8)/8+206*80
	mov	ebx,'.'
	mov	ah,1
	call    PutCharacter
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceMastNumber
	mov	ebx,2
	call	ScanEffect
	mov	eax,[esi]

	mov	ebx,' '
	cmp	eax,0
	jg	doplussa
	jz	afteraftermoj
	mov	ebx,'-'
	neg	eax
	jmp	afteraftermoj
doplussa:
	mov	ebx,'+'
afteraftermoj:
	push	eax
	move	edi,0a0000h+(128+8*0-8)/8+206*80
	mov	ah,1
	call    PutCharacter
	pop	eax
	mov	ebx,16
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	mov	ah,1
	mov	cl,2
 	move	edi,0a0000h+(128+8*1-8)/8+206*80
	call	PutDecimal
	mov	ebx,edx
	mov	ah,1
	mov	cl,2
 	move	edi,0a0000h+(128+8*4-8)/8+206*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
	popad
	ret
noprintPitch:
	cmp	EffectMasterSelect,2	;Volume **********
	jnz	noprintVolume
	call	mouseoff
	mov	fontplane,1
 	move	edi,0a0000h+(128+8*7-8)/8+206*80
	mov	ebx,'%'
	mov	ah,1
	call    PutCharacter
 	move	edi,0a0000h+(128+8*4-8)/8+206*80
	mov	ebx,'.'
	mov	ah,1
	call    PutCharacter
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceMastNumber
	mov	ebx,3
	call	ScanEffect
	mov	eax,[esi]
	mov	ebx,100
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	mov	ah,1
	mov	cl,4
 	move	edi,0a0000h+(128+8*0-8)/8+206*80
	call	PutDecimal
	mov	ebx,edx
	mov	ah,1
	mov	cl,2
 	move	edi,0a0000h+(128+8*5-8)/8+206*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
noprintVolume:
	popad
	ret
MasterArrowUp:				;Master arrow up -----------------
	call	CheckIfNowFastPreview
	pushad
	call	fixbutton
	cmp	EffectMasterSelect,1
	jz	DoUpPitch
	cmp	EffectMasterSelect,2
	jz	DoUpVolume
DoUpDelay:
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceMastNumber
	mov	ebx,1
	call	ScanEffect
	mov	eax,[esi]
	add	eax,1000
	cmp	eax,350000000
	jbe	nojka
	mov	eax,350000000
nojka:
	mov	[esi],eax
	call	PrintMasterValue
	popad
	ret
DoUpPitch:
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceMastNumber
	mov	ebx,2
	call	ScanEffect
	mov	eax,[esi]
	add	eax,1
	cmp	eax,576
	jle	nojka2
	mov	eax,576
nojka2:
	mov	[esi],eax
	call	PrintMasterValue
	popad
	ret
DoUpVolume:
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceMastNumber
	mov	ebx,3
	call	ScanEffect
	mov	eax,[esi]
	add	eax,1
	cmp	eax,60000
	jbe	nojka3
	mov	eax,60000
nojka3:
	mov	[esi],eax
	call	PrintMasterValue
	popad
	ret

MasterArrowDown:		       ;Master arrow down -----------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	cmp	EffectMasterSelect,1
	jz	DoDownPitch
	cmp	EffectMasterSelect,2
	jz	DoDownVolume
DoDownDelay:
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceMastNumber
	mov	ebx,1
	call	ScanEffect
	mov	eax,[esi]
	sub	eax,1000
	cmp	eax,0
	jge	nojka_
	mov	eax,0
nojka_:
	mov	[esi],eax
	call	PrintMasterValue
	popad
	ret
DoDownPitch:
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceMastNumber
	mov	ebx,2
	call	ScanEffect
	mov	eax,[esi]
	sub	eax,1
	cmp	eax,-576
	jge	nojka2_
	mov	eax,-576
nojka2_:
	mov	[esi],eax
	call	PrintMasterValue
	popad
	ret
DoDownVolume:
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceMastNumber
	mov	ebx,3
	call	ScanEffect
	mov	eax,[esi]
	sub	eax,1
	cmp	eax,0
	jge	nojka3_
	mov	eax,0
nojka3_:
	mov	[esi],eax
	call	PrintMasterValue
	popad
	ret
MasterDword	dd	0
MasterUdrag:				;Master Udrag ----------------------
	pushad
	call	CheckIfNowFastPreview
	cmp	EffectMasterSelect,1
	jz	DoDownPitch2
	cmp	EffectMasterSelect,2
	jz	DoDownVolume2
DoDownDelay2:				;delay *********
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceMastNumber
	mov	ebx,1
	call	ScanEffect
	mov	eax,[esi]
	mov	ebx,1000
	xor	edx,edx
	div	ebx
	mov	MasterDword,eax

	mov	UdragStatus,1
	mov	eax,MasterCurveYZoomSize
	mov	ebx,350*1024/200
	mul	ebx
	mov	ebx,1000
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,350000
	mov	UdragMiniValue,0
	lea	eax,MasterDword
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,MeanWhileMaster1
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret
MeanWhileMaster1:
	pushad
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceMastNumber
	mov	ebx,1
	call	ScanEffect
	mov	eax,MasterDword
	mov	ebx,1000
	mul	ebx
	mov	[esi],eax
	call	PrintMasterValue
	popad
	ret

DoDownPitch2:				;pitch ********
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceMastNumber
	mov	ebx,2
	call	ScanEffect
	mov	eax,[esi]
	add	eax,576
	mov	MasterDword,eax

	mov	UdragStatus,1
	mov	eax,MasterCurveYZoomSize
	mov	ebx,(576*2+1)*1024/200
	mul	ebx
	mov	ebx,1000000
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,576*2
	mov	UdragMiniValue,0
	lea	eax,MasterDword
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,MeanWhileMaster2
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret
MeanWhileMaster2:
	pushad
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceMastNumber
	mov	ebx,2
	call	ScanEffect
	mov	eax,MasterDword
	sub	eax,576
	mov	[esi],eax
	call	PrintMasterValue
	popad
	ret
DoDownVolume2:				;volume *******
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceMastNumber
	mov	ebx,3
	call	ScanEffect
	mov	eax,[esi]
	mov	MasterDword,eax

	mov	UdragStatus,1
	mov	eax,MasterCurveYZoomSize
	mov	ebx,60000*1024/200
	mul	ebx
	mov	ebx,1000000
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,60000
	mov	UdragMiniValue,0
	lea	eax,MasterDword
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,MeanWhileMaster3
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret
MeanWhileMaster3:
	pushad
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceMastNumber
	mov	ebx,3
	call	ScanEffect
	mov	eax,MasterDword
	mov	[esi],eax
	call	PrintMasterValue
	popad
	ret
;******************************************************************************
;			      MASTER CURVE SELECT
;******************************************************************************
PlaneSelect	db	0
NummerCount	dd	0
ViewMasterCurve:			;View master curve ----------------
	pushad

	call	mouseoff
	;mov 	OldPosMast,-1
	mov	esi,[alloctable+1051*8]
	movzx	ebp,word ptr [esi]

	move	edi,0a0000h+232/8+187*80
	mov	eax,MasterCurvePos
	mov	NummerCount,eax
	mov	ebx,EffectMasterSelect
	inc	ebx
	sub	ebp,eax
	mov	ecx,35

ViewCurveLoop:
	push	eax ebx ecx edi esi ebp

	push	eax
	mov	eax,NummerCount
	cmp	eax,VoiceMastNumber
	jz	PlaneWrite1
	mov	planeselect,0
	jmp	afterplanen
PlaneWrite1:
	mov	planeselect,1
AfterPlanen:
	pop	eax

	cmp	ebp,0
	jnz	skiponlyclear
	mov	edx,64
	mov	ebp,0
	jmp	DoThisDraw
SkipOnlyClear:
	call	ScanEffect
	mov	eax,[esi]

	cmp	ebx,1
	jnz	noDelayen
	mov	ebx,1000000
	mul	ebx
	mov	ebx,350000000
	div	ebx
noDelayen:
	cmp	ebx,2
	jnz	noPitchen
	add	eax,576
	mov	ebx,1000000
	mul	ebx
	mov	ebx,576*2+1
	div	ebx
noPitchen:
	cmp	ebx,3
	jnz	noVolumen
	mov	ebx,1000000
	mul	ebx
	mov	ebx,60000
	div	ebx
noVolumen:


	cmp	MasterCurveYZoomPos,eax
	ja	NoAllPut
	mov	edx,0
	mov	ebp,64
	jmp	DoThisDraw
NoAllPut:
	mov	ebx,MasterCurveYZoomPos
	sub	ebx,eax
	cmp	ebx,MasterCurveYZoomSize
	jb	nononeput
	mov	edx,64
	mov	ebp,0
	jmp	DoThisDraw
NoNonePut:
	mov	eax,64
	mul	ebx
	mov	ebx,MasterCurveYZoomSize
	div	ebx
	mov	edx,eax
	mov	ebp,64
	sub	ebp,eax
DoThisDraw:



	planewrite 00001111b
	mov	ecx,edx
	jecxz	AfterClearLoopen
DoClearLoopen:
	mov	byte ptr [edi],0
	add	edi,80
	loop	doClearLoopen
AfterClearLoopen:
	mov	ecx,ebp
	jecxz	AfterPutLoopen
	mov	al,01111110b
DoPutLoopen:
	planewrite 00001111b
	mov	byte ptr [edi],0
	cmp	planeselect,0
	jz	normalplane
	planewrite 00001011b
	jmp	afterplane
normalplane:
	planewrite 00000001b
afterplane:
	mov	[edi],al
	add	edi,80
	loop	DoPutLoopen
AfterPutLoopen:

	pop	ebp esi edi ecx ebx eax
	inc	edi
	inc	eax
	inc	NummerCount

	cmp	ebp,0
	jz	SkipDeccen
	dec	ebp
SkipDeccen:
	loop	ViewCurveLoop

	call	mouseon
	popad
	ret


MasterCurveLeft:			;Master Curve Left ---------------

	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	cmp	MasterCurvePos,0
	jz	_retp
	dec	MasterCurvePos
	call	ViewMasterCurve
	mov	eax,MasterCurvePos
	mov	dword ptr [MastCurveHorz1],eax
	mov	dword ptr [MastCurveHorz1+4],1
	mov	dword ptr [MastCurveHorz2],eax
	mov	dword ptr [MastCurveHorz2+4],1
	popad
	ret

MasterCurveRight:			;MasterCurveRight: ---------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	mov	eax,[alloctable+1051*8]
	movzx	eax,word ptr [eax]
	sub	eax,MasterCurvePos
	cmp	eax,35
	jle	_retp
	inc	MasterCurvePos
	call	ViewMasterCurve
	mov	eax,MasterCurvePos
	mov	dword ptr [MastCurveHorz1],eax
	mov	dword ptr [MastCurveHorz1+4],1
	mov	dword ptr [MastCurveHorz2],eax
	mov	dword ptr [MastCurveHorz2+4],1
	popad
	ret
MasterCurveUp:				;MasterCurveUp: ---------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	cmp	MasterCurveYZoomPos,1000000
	jz	_retp
	mov	eax,MasterCurveYZoomSize
	mov	ebx,100
	xor	edx,edx
	div	ebx
	cmp	eax,0
	jg	nojas
	mov	eax,1
nojas:
	add	MasterCurveYZoomPos,eax
	cmp	MasterCurveYZoomPos,1000000
	jbe	nojas2
	mov	MasterCurveYZoomPos,1000000
nojas2:
	call	ViewMasterCurve
	popad
	ret
MasterCurveDown:			;MasterCurveDown: ---------------

	pushad
	call	CheckIfNowFastPreview
	call	fixbutton

	cmp	MasterCurveYZoomPos,0
	jz	_retp
	mov	ebp,MasterCurveYZoomSize
	inc	ebp
	cmp	ebp,MasterCurveYZoomPos
	jz	_retp
	mov	eax,MasterCurveYZoomSize
	mov	ebx,100
	xor	edx,edx
	div	ebx
	cmp	eax,0
	jg	nojas3
	mov	eax,1
nojas3:
	sub	MasterCurveYZoomPos,eax
	cmp	MasterCurveYZoomPos,ebp
	jge	nojas4
	mov	MasterCurveYZoomPos,ebp
nojas4:
	call	ViewMasterCurve

	popad
	ret
MasterCurveZoomIn:			;MasterCurveZoomIn: ---------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	cmp	MasterCurveYZoomSize,2
	jz	_retp
	mov	eax,MasterCurveYZoomSize
	mov	ebp,eax
	mov	ebx,95
	mul	ebx
	mov	ebx,100
	div	ebx
	cmp	eax,2
	jge	nojas5
	mov	eax,2
nojas5:
	sub	ebp,eax
	shr	ebp,1
	sub	MasterCurveYZoomPos,ebp
	mov	MasterCurveYZoomSize,eax
	call	ViewMasterCurve
	popad
	ret
MasterCurveZoomOut:			;MasterCurveZoomOut: ---------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	cmp	MasterCurveYZoomSize,1000000
	jz	_retp
	mov	eax,MasterCurveYZoomSize
	mov	ebp,eax
	mov	ebx,100
	mul	ebx
	mov	ebx,95
	div	ebx
	cmp	eax,ebp
	jnz	nokvasEE
       	inc	eax
nokvasEE:
	cmp	eax,1000000
	jbe	nojas6AAEE
	mov	eax,1000000
nojas6AAEE:
	mov	MasterCurveYZoomSize,eax
	mov	ebx,eax
	sub	ebx,ebp
	shr	ebx,1
	add	MasterCurveYZoomPos,ebx
	inc	eax
	cmp	MasterCurveYZoomPos,eax
	jae	nojkabaEE
	mov	MasterCurveYZoomPos,eax
nojkabaEE:
	cmp	MasterCurveYZoomPos,1000000
	jbe	nokaAAEE
     	mov	MasterCurveYZoomPos,1000000
nokaAAEE:
	call	ViewMasterCurve
	popad
	ret
OldXY	dw	-1,-1
MasterCurveSelectFirst: 		;MasterCurveSelect first: ---------
	pushad
	call	CheckIfNowFastPreview
	mov	MouseOnDragBar,-5
	call	MasterCurveSelect
	popad
	ret
MasterCurveSelect:			;MasterCurveSelect: ---------------
	pushad
	call	CheckIfNowFastPreview
	mov	leftkeywait,1
	mov	rightkeywait,1
	mov	bothkeywait,1

	mov	ax,MouseX
	cmp	ax,[oldXY]
	jnz	nonewaboja
	mov	ax,MouseY
	cmp	ax,[oldXY+2]
	jz	_retp
nonewaboja:
	mov	ax,mouseX
	mov	[oldXY],ax
	mov	ax,mouseY
	mov	[oldXY+2],ax

	movzx	eax,MouseX
	cmp	eax,232
	jae	nokor1
       	mov	eax,232
nokor1:
	cmp	eax,511
	jbe	nokor2
       	mov	eax,511
nokor2:

	sub	eax,232
	shr	eax,3
	add	eax,MasterCurvePos
	mov	ebx,[alloctable+1051*8]
	movzx	ebx,word ptr [ebx]
	dec	ebx
	cmp	eax,ebx
	jbe	nopjas
	mov	eax,ebx
nopjas:
	mov	VoiceMastNumber,eax

	cmp	MouseB,2
	jz	Skipsetya
	mov	ebx,EffectMasterSelect
	inc	ebx
	mov	esi,[alloctable+1051*8]
	call	ScanEffect


	movzx	eax,mouseY
	cmp	eax,187
	jae	nokor3
       	mov	eax,187
nokor3:
	cmp	eax,250
	jbe	nokor4
       	mov	eax,250
nokor4:
	sub	eax,187
	mov	ebx,MasterCurveYZoomSize
	mul	ebx
	mov	ebx,63
	div	ebx
	mov	ebx,MasterCurveYZoomPos
	sub	ebx,eax

	cmp	ebx,1000000
	jbe	nohons
       	mov	ebx,1000000
nohons:

	cmp	EffectMasterSelect,1
	jz	DoThisPitch
	cmp	EffectMasterSelect,2
	jz	DoThisVolume
DoThisDelay:
	mov	eax,350
	mul	ebx
	jmp	endSelect
DoThisPitch:
	mov	eax,576*2
	mul	ebx
	mov	ebx,1000000
	div	ebx
	sub	eax,576
	jmp	endSelect
DoThisVolume:
	mov	eax,60000
	mul	ebx
	mov	ebx,1000000
	div	ebx
EndSelect:
	mov	[esi],eax
Skipsetya:

	call	UpdateMaster
	popad
	ret

UpdateMastCurveX1:			;Update mast curve X 1 --------------
	pushad
	mov	eax,dword ptr [MastCurveHorz1]
	mov	MasterCurvePos,eax
	call	ViewMasterCurve
	popad
	ret
UpdateMastCurveX2:			;Update mast curve X 2 --------------
	pushad
	mov	eax,dword ptr [MastCurveHorz2]
	mov	MasterCurvePos,eax
	call	ViewMasterCurve
	popad
	ret


SwitchZoomData: 			;Switch zoom data ------------------
;calls: ebp=new master select
;	eax=(0=nothing before,1=yes before)
	pushad

	cmp	eax,0
	jz	skippathissa
	mov	eax,EffectMasterSelect
	mov	ebx,MasterCurveYZoomSize
	mov	[ZoomCurveData+eax*8],ebx
	mov	ebx,MasterCurveYZoomPos
	mov	[ZoomCurveData+eax*8+4],ebx
skippathissa:
	mov	ebx,[ZoomCurveData+ebp*8]
	mov	MasterCurveYZoomSize,ebx
	mov	ebx,[ZoomCurveData+ebp*8+4]
	mov	MasterCurveYZoomPos,ebx
	popad
	ret

;******************************************************************************
;			      ENVELOPE SELECT
;******************************************************************************
UpdateEnvelope: 			;update envelope -----------------

	pushad
	call	PrintVoiceEnvNumber
	call	PrintVoiceOffset
	mov	noflipp,1
	call	VoiceRepeatOnOff
	call	VoiceReverbOnOff
	call	VoiceBWDOnOff
	mov	noflipp,0
	call	ShowLoopen
	call	PrintPointNr
	call 	PrintNrOfPoints
	call 	PrintEnvTime
	call 	PrintEnvValue
	call 	PrintEnvLoopStart
	call 	PrintEnvLoopEnd

	call	ShowEnvCurves
	call	UpdateEnvCurve
	call	ShowRealPitchen
	call	ShowTimeCompressen
	call	PutTimeCompressSkip
	call	PutTimeCompressRead
	call	PutRealPitch
	call	PuttaLoopa
	popad
	ret


GetZoomDataEnv:				;Get Zoom Data Env -------------------
	pushad
	mov	eax,EffectEnvelopeSelect
	cmp	eax,3
	jz	_retp
	mov	ebx,[ZoomEnvCurveDataY+eax*8+4]
	mov	EnvCurveYZoomPos,ebx
	mov	ebx,[ZoomEnvCurveDataY+eax*8]
	mov	EnvCurveYZoomSize,ebx
	mov	ebx,[ZoomEnvCurveDataX+eax*4]
	mov	EnvTimeZoom,ebx
	mov	EnvTimePos,0
	popad
	ret
PutZoomDataEnv:				;Put Zoom Data Env -------------------
	pushad
	mov	eax,EffectEnvelopeSelect
	cmp	eax,3
	jz	_retp
	mov	ebx,EnvCurveYZoomPos
	mov	[ZoomEnvCurveDataY+eax*8+4],ebx
	mov	ebx,EnvCurveYZoomSize
	mov	[ZoomEnvCurveDataY+eax*8],ebx
	mov	ebx,EnvTimeZoom
	mov	[ZoomEnvCurveDataX+eax*4],ebx
	popad
	ret
UpdateEnvCurve:				;update env Curve --------------------
	pushad
	call	PutEnvelopeCurve
	popad
	ret


ShowEffectEnv:				;Show effect env ----------------------
	pushad


	cmp	EffectEnvelopeSelect,3	;draw picture
	jnz	NoTime
	lea	esi,Time_effPicture
	mov	DrawSpecial,1
	call	DrawPopUp
	call	ShowRealPitchen
	call	ShowTimeCompressen
	call	PutTimeCompressSkip
	call	PutTimeCompressRead
	call	PutRealPitch
	jmp	AfterPicture
NoTime:
	cmp	LastEnvSelect,3
	jnz	afterpicture
	lea	esi,Envelope_effPicture
	mov	DrawSpecial,1
	call	DrawPopUp
afterpicture:
	mov	eax,EffectEnvelopeSelect
	mov	LastEnvSelect,eax

	call	mouseoff                ;draw buttons
	mov	buttonX1,75
	mov	buttonY1,295
	mov	buttonX2,85
	mov	buttonY2,306
	mov	bl,1
	cmp	EffectEnvelopeSelect,0
	jnz	noskola0
	xor	bl,1
noskola0:
	call	buttonupdown
	mov	buttonX1,75
	mov	buttonY1,308
	mov	buttonX2,85
	mov	buttonY2,318
	mov	bl,1
	cmp	EffectEnvelopeSelect,1
	jnz	noskola1
	xor	bl,1
noskola1:
	call	buttonupdown
	mov	buttonX1,75
	mov	buttonY1,321
	mov	buttonX2,85
	mov	buttonY2,331
	mov	bl,1
	cmp	EffectEnvelopeSelect,2
	jnz	noskola2
	xor	bl,1
noskola2:
	call	buttonupdown
	mov	buttonX1,75
	mov	buttonY1,334
	mov	buttonX2,85
	mov	buttonY2,344
	mov	bl,1
	cmp	EffectEnvelopeSelect,3
	jnz	noskola3
	xor	bl,1
noskola3:
	call	buttonupdown
	call	mouseon
	popad
	ret

					;Mouse select envelope -------------
MouseEnvDelay:				;Delay -----
	call	CheckIfNowFastPreview
	call	PutZoomDataEnv
	mov	EffectEnvelopeSelect,0
	call	GetZoomDataEnv
	mov	EnvelopePointNummer,0
	call	ShowEffectEnv
	call	UpdateEnvelope
	mov 	word ptr [CurrentMenu],39
	mov 	Menu_popup,39
	ret
MouseEnvPitch:				;Pitch -----
	call	CheckIfNowFastPreview
	call	PutZoomDataEnv
	mov	EffectEnvelopeSelect,1
	call	GetZoomDataEnv
	mov	EnvelopePointNummer,0
	call	ShowEffectEnv
	call	UpdateEnvelope
	mov 	word ptr [CurrentMenu],39
	mov 	Menu_popup,39
	ret
MouseEnvVolume: 			;Volume ----
	call	CheckIfNowFastPreview
	call	PutZoomDataEnv
	mov	EffectEnvelopeSelect,2
	call	GetZoomDataEnv
	mov	EnvelopePointNummer,0
	call	ShowEffectEnv
	call	UpdateEnvelope
	mov 	word ptr [CurrentMenu],39
	mov 	Menu_popup,39
	ret
MouseEnvTime:				;Time ------
	call	CheckIfNowFastPreview
	call	PutZoomDataEnv
	mov	EffectEnvelopeSelect,3
	mov	EnvelopePointNummer,0
	call	ShowEffectEnv
	call	UpdateEnvelope
	mov 	word ptr [CurrentMenu],41
	mov 	Menu_popup,41
	ret

PrintVoiceEnvNumber:			 ;Print voice env number -------------
	pushad
	call	mouseoff
	mov	fontplane,1
	mov	ebx,VoiceEnvNumber
	mov	ah,1
	mov	cl,5
	move	edi,0a0000h+152/8+277*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
	popad
	ret
VoiceEnvNumUp:				;Voice env num up ------------------
	call	CheckIfNowFastPreview
	pushad
	call	fixbutton
	mov	eax,[alloctable+1051*8]
	movzx	eax,word ptr [eax]
	dec	eax
	cmp	VoiceEnvNumber,eax
	jz	_retp
	inc	VoiceEnvNumber
	call	UpdateEnvelope
	mov	EnvelopePointNummer,0
	popad
	ret
VoiceEnvNumDown:			;Voice env num down ----------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	cmp	VoiceEnvNumber,0
	jz	_retp
	dec	VoiceEnvNumber
	call	UpdateEnvelope
	mov	EnvelopePointNummer,0
	popad
	ret

VoiceEnvUdrag:				;voice env udrag ------------------
	pushad
	call	CheckIfNowFastPreview
	mov	UdragStatus,1
	mov	eax,[alloctable+1051*8]
	movzx	eax,word ptr [eax]
	mov	ebx,1024*10
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	mov	eax,[alloctable+1051*8]
	movzx	eax,word ptr [eax]
	dec	eax
	mov	UdragMaxValue,eax
	mov	UdragMiniValue,0
	lea	eax,VoiceEnvNumber
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,UpdateEnvelope
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	mov	EnvelopePointNummer,0
	popad
	ret
VoiceEnvInput:				;VoiceEnvInput -------------------
	pushad
	call	CheckIfNowFastPreview
	move	edi,0a0000h+152/8+277*80
	mov	ax,0111h
	lea	ebp,VoiceEnvNumber
	mov	ecx,5
	mov	ebx,0
	mov	edx,[alloctable+1051*8]
	movzx	edx,word ptr [edx]
	dec	edx
	lea	esi,UpdateEnvelope
	mov	digitsize,3
	call	ZyricInput
	mov	EnvelopePointNummer,0
	popad
	ret
NoFlipp db	0
VoiceRepeatOnOff:			;Voice repeat On Off ---------------
	pushad
	call	CheckIfNowFastPreview
	call	mouseoff
	mov	buttonX1,243
	mov	buttonY1,275
	mov	buttonX2,253
	mov	buttonY2,286
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,0
	call	ScanEffect
	cmp	NoFlipp,1
	jz	skojas1
	xor	byte ptr [esi],1
skojas1:
	mov	bl,[esi]
	xor	bl,1
	call	buttonupdown
	call	mouseon
	popad
	ret
VoiceReverbOnOff:			;Voice reverb On Off ---------------

	call	CheckIfNowFastPreview
	pushad
	call	mouseoff
	mov	buttonX1,243
	mov	buttonY1,288
	mov	buttonX2,253
	mov	buttonY2,299
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,0
	call	ScanEffect
	cmp	NoFlipp,1
	jz	skojas2
	xor	byte ptr [esi+1],1
skojas2:
	mov	bl,[esi+1]
	xor	bl,1
	call	buttonupdown
	call	mouseon
	popad
	ret

VoiceBWDOnOff:				;Voice BWD On Off ------------------
	pushad
	call	CheckIfNowFastPreview
	call	mouseoff
	mov	buttonX1,243
	mov	buttonY1,301
	mov	buttonX2,253
	mov	buttonY2,312
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,0
	call	ScanEffect
	cmp	NoFlipp,1
	jz	skojas3
	xor	byte ptr [esi+2],1
skojas3:
	mov	bl,[esi+2]
	xor	bl,1
	call	buttonupdown
	call	mouseon
	popad
	ret
PrintVoiceOffset:			;Print Voice offset -------------

	pushad
	call	mouseoff
	mov	fontplane,1
 	move	edi,0a0000h+504/8+332*80
	mov	ebx,'%'
	mov	ah,1
	call    PutCharacter
 	move	edi,0a0000h+480/8+332*80
	mov	ebx,'.'
	mov	ah,1
	call    PutCharacter
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,0
	call	ScanEffect
	movzx	eax,word ptr [esi+3]
	mov	ebx,100
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	mov	ah,1
	mov	cl,3
	move	edi,0a0000h+456/8+332*80
	call	PutDecimal
	mov	ebx,edx
	mov	ah,1
	mov	cl,2
	move	edi,0a0000h+488/8+332*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
	popad
	ret

PrintVoiceOffUp:			;Print voice off up ---------------
	pushad
	call	fixbutton
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,0
	call	ScanEffect
	movzx	eax,word ptr [esi+3]
	add	eax,1
	cmp	eax,10000
	jbe	nomoja1
	mov	eax,10000
nomoja1:
	mov	word ptr [esi+3],ax
	call	PrintVoiceOffset
	popad
	ret
PrintVoiceOffDown:			;Print voice off down -------------
	pushad
	call	fixbutton
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,0
	call	ScanEffect
	movzx	eax,word ptr [esi+3]
	sub	eax,1
	cmp	eax,0
	jge	nomoja2
	xor	eax,eax
nomoja2:
	mov	word ptr [esi+3],ax
	call	PrintVoiceOffset
	popad
	ret
JustNuVar	dd	0
VoiceOffUdrag:				;Voice off udrag ------------------

	call	CheckIfNowFastPreview
	pushad
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,0
	call	ScanEffect
	movzx	eax,word ptr [esi+3]
	mov	JustNuVar,eax

	mov	UdragStatus,1
	mov	eax,3100
	mov	ebx,1024
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,10000
	mov	UdragMiniValue,0
	lea	eax,JustNuVar
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,AfterVoiceOff
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret
AfterVoiceOff:
	pushad
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,0
	call	ScanEffect
	mov	eax,JustNuVar
	mov	[esi+3],ax
	call	PrintVoiceOffset
	popad
	ret

NurShow	db	0
ShowLoopen:
      	mov	NurShow,1
SelectLoop:				;Select Loop -----------------------
	pushad
	call	CheckIfNowFastPreview
	cmp	EffectEnvelopeSelect,3
	jz	_retp

	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	cmp	word ptr [esi-2],1
	jz	_retp

 	cmp	ebx,2
 	jz	DoPitchen
 	cmp	NurShow,1
 	jz	skooo1
	xor	byte ptr [esi-7],1
skooo1:
	mov	bl,[esi+4]
	jmp	AfterPitchen
DoPitchen:
 	cmp	NurShow,1
 	jz	skooo2
	xor	byte ptr [esi-7],1
skooo2:
	mov	bl,[esi-7]
AfterPitchen:
	call	PuttaLoopa
	call	PutEnvelopeCurve
	popad
	ret
PuttaLoopa:				;PuttaLoopa ------------------------
	pushad
	cmp 	EffectEnvelopeSelect,3
	jz	_retp
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	mov	bl,[esi-7]
	xor	bl,1
	mov	buttonX1,532
	mov	buttonY1,372
	mov	buttonX2,564
	mov	buttonY2,389
	call	buttonupdown
	mov	NurShow,0
	popad
	ret

AddEsiSelect:				;Add esi select --------------------
	add	esi,11
	cmp	EffectEnvelopeSelect,1
	jnz	_ret
	add	esi,3
	ret
PrintPointNr:				;Print Point Nr --------------------
	pushad
	cmp     EffectEnvelopeSelect,3
	jz	_retp
	call	mouseoff
	mov	fontplane,1
	mov	ebx,EnvelopePointNummer
	mov	ah,1
	mov	cl,5
	move	edi,0a0000h+152/8+352*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
	popad
	ret
PrintNrOfPoints:			;Print Number of points ------------
	pushad
	cmp     EffectEnvelopeSelect,3
	jz	_retp
	call	mouseoff
	mov	fontplane,1
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	ebx,word ptr [esi-2]
	mov	ah,1
	mov	cl,5
	move	edi,0a0000h+152/8+370*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
	popad
	ret
PrintEnvTime:				;Print Env Time ---------------------

	pushad
	cmp     EffectEnvelopeSelect,3
	jz	_retp
	call	mouseoff
	mov	fontplane,1
 	move	edi,0a0000h+(128+8*3)/8+388*80
	mov	ebx,'.'
	mov	ah,1
	call    PutCharacter
 	move	edi,0a0000h+(128+8*7)/8+388*80
	mov	ebx,'s'
	mov	ah,1
	call    PutCharacter
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	mov	ebx,EnvelopePointNummer
	inc	ebx
	xor	eax,eax
TimeAddLoop:
	cmp	ebx,0
	jz	goforitOJAA
	add	eax,[esi]
	add	esi,9
	dec	ebx
	jmp	TimeAddLoop
goforitOJAA:
	mov	ebx,1000
	xor	edx,edx
	div	ebx
	mov	ebx,1000
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	mov	ah,1
	mov	cl,3
 	move	edi,0a0000h+(128+8*0)/8+388*80
	call	PutDecimal
	mov	ebx,edx
	mov	ah,1
	mov	cl,3
 	move	edi,0a0000h+(128+8*4)/8+388*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
	popad
	ret

PrintEnvelopeValue:
PrintEnvValue:				;Print Env value -------------------
	pushad
	cmp     EffectEnvelopeSelect,3
	jz	_retp
	cmp	EffectEnvelopeSelect,0	  ;Delay *********
	jnz	noprintDelay_
	call	mouseoff
	mov	fontplane,1
 	move	edi,0a0000h+(128+8*7)/8+406*80
	mov	ebx,'s'
	mov	ah,1
	call    PutCharacter
 	move	edi,0a0000h+(128+8*3)/8+406*80
	mov	ebx,'.'
	mov	ah,1
	call    PutCharacter
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,4
	mov	eax,[esi]
	mov	ebx,1000
	xor	edx,edx
	div	ebx
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	mov	ah,1
	mov	cl,3
 	move	edi,0a0000h+(128+8*0)/8+406*80
	call	PutDecimal
	mov	ebx,edx
	mov	ah,1
	mov	cl,3
 	move	edi,0a0000h+(128+8*4)/8+406*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
	popad
	ret
noprintdelay_:
	cmp	EffectEnvelopeSelect,1	  ;Pitch ***********
	jnz	noprintPitch_
	call	mouseoff
	mov	fontplane,1
 	move	edi,0a0000h+(128+8*6)/8+406*80
	mov	ebx,'h'
	mov	ah,1
	call    PutCharacter
 	move	edi,0a0000h+(128+8*7)/8+406*80
	mov	ebx,'n'
	mov	ah,1
	call    PutCharacter
 	move	edi,0a0000h+(128+8*3)/8+406*80
	mov	ebx,'.'
	mov	ah,1
	call    PutCharacter
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,4
	mov	eax,[esi]

	mov	ebx,' '
	cmp	eax,0
	jg	doplussa_
	jz	afteraftermoj_
	mov	ebx,'-'
	neg	eax
	jmp	afteraftermoj_
doplussa_:
	mov	ebx,'+'
afteraftermoj_:
	push	eax
	move	edi,0a0000h+(128+8*0)/8+406*80
	mov	ah,1
	call    PutCharacter
	pop	eax
	mov	ebx,16
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	mov	ah,1
	mov	cl,2
 	move	edi,0a0000h+(128+8*1)/8+406*80
	call	PutDecimal
	mov	ebx,edx
	mov	ah,1
	mov	cl,2
 	move	edi,0a0000h+(128+8*4)/8+406*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
	popad
	ret
noprintPitch_:
	cmp	EffectEnvelopeSelect,2	  ;Volume **********
	jnz	noprintVolume_
	call	mouseoff
	mov	fontplane,1
 	move	edi,0a0000h+(128+8*7)/8+406*80
	mov	ebx,'%'
	mov	ah,1
	call    PutCharacter
 	move	edi,0a0000h+(128+8*4)/8+406*80
	mov	ebx,'.'
	mov	ah,1
	call    PutCharacter
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,4
	mov	eax,[esi]
	mov	ebx,100
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	mov	ah,1
	mov	cl,4
 	move	edi,0a0000h+(128+8*0)/8+406*80
	call	PutDecimal
	mov	ebx,edx
	mov	ah,1
	mov	cl,2
 	move	edi,0a0000h+(128+8*5)/8+406*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
noprintVolume_:
	popad
	ret

PrintEnvLoopStart:			;Print env loop start ------------
	pushad
	cmp     EffectEnvelopeSelect,3
	jz	_retp
	call	mouseoff
	mov	fontplane,1
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	ebx,word ptr [esi-6]
	mov	ah,1
	mov	cl,5
	move	edi,0a0000h+152/8+424*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
	popad
	ret
PrintEnvLoopEnd:			;Print env loop end ---------------

	pushad
	cmp     EffectEnvelopeSelect,3
	jz	_retp
	call	mouseoff
	mov	fontplane,1
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	ebx,word ptr [esi-4]
	mov	ah,1
	mov	cl,5
	move	edi,0a0000h+152/8+442*80
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
	popad
	ret

VoiceEnvPointUp:			  ;Voice env Point up ------------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	eax,word ptr [esi-2]
	dec	eax
	cmp	EnvelopePointNummer,eax
	jz	_retp
	inc	EnvelopePointNummer
	call	UpdateEnvelope
	popad
	ret
VoiceEnvPointDown:			  ;Voice env Point down --------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	cmp	EnvelopePointNummer,0
	jz	_retp
	dec	EnvelopePointNummer
	call	UpdateEnvelope
	popad
	ret

VoiceEnvPointUdrag:			  ;voice env point udrag -------------
	pushad
	call	CheckIfNowFastPreview
	mov	UdragStatus,1
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	eax,word ptr [esi-2]
	dec	eax
	mov	UdragMaxValue,eax
	mov	ebx,1024*10
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMiniValue,0
	lea	eax,EnvelopePointNummer
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,UpdateEnvelope
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret

TimeArrowUp:				;Time Arrow Up -----------------------
	pushad
	call	fixbutton
	call	CheckIfNowFastPreview
	cmp	EnvelopePointNummer,0
	jz	_retp
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	ebp,word ptr [esi-2]
	dec	ebp
	cmp	ebp,EnvelopePointNummer
	jz	LastNummerNow

	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
 	cmp 	dword ptr [esi+9],1000
 	jz	_retp
	add	dword ptr [esi],1000
	sub	dword ptr [esi+9],1000
	call	UpdateEnvCurve
	call 	PrintEnvTime
	popad
	ret
LastNummerNow:
	push	esi
	mov	ebx,EnvelopePointNummer
	inc	ebx
	xor	eax,eax
Loja:
	add  	eax,[esi]
	add	esi,9
	dec	ebx
       	jnz	Loja
       	pop	esi
 	cmp	eax,999999000
 	jz	_retp
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	dword ptr [esi],1000
	call	UpdateEnvCurve
	call 	PrintEnvTime
	popad
	ret

TimeArrowDown:				;Time Arrow Down ---------------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	cmp	EnvelopePointNummer,0
	jz	_retp
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	ebp,word ptr [esi-2]
	dec	ebp
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
 	cmp 	dword ptr [esi],1000
 	jz	_retp
	sub	dword ptr [esi],1000
	cmp	ebp,EnvelopePointNummer
	jz	Skojaadden
	add	dword ptr [esi+9],1000
Skojaadden:
	call	UpdateEnvCurve
	call 	PrintEnvTime
	popad
	ret

TimeVar		dd	0
TimeUdrag:				 ;Time udrag -------------------------
	pushad
	call	CheckIfNowFastPreview
	cmp	EnvelopePointNummer,0
	jz	_retpb
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	ebp,word ptr [esi-2]
	dec	ebp
	cmp	ebp,EnvelopePointNummer
	jz	LastNummerUdrag

	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	mov	eax,[esi]
	mov	ecx,1000
	xor	edx,edx
	div	ecx
	mov	TimeVar,eax

	mov	UdragStatus,1
	mov	eax,[esi]
	add	eax,[esi+9]
	mov	ecx,1000
	xor	edx,edx
	div	ecx
	dec	eax
	mov	UdragMaxValue,eax
	mov	ebx,1024
	mul	ebx
	mov	ebx,100
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMiniValue,1
	lea	eax,TimeVar
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,TimeUdragMean
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret
LastNummerUdrag:
	push	esi
	mov	ebx,EnvelopePointNummer
	xor	eax,eax
Loja2:
	cmp	ebx,0
	jz	boja2
	add  	eax,[esi]
	add	esi,9
	dec	ebx
       	jmp	Loja2
boja2:
       	pop	esi
       	mov	ebx,1000
       	xor	edx,edx
       	div	ebx
       	mov	ebx,999999
       	sub	ebx,eax
	mov	UdragMaxValue,ebx

	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	mov	eax,[esi]
	mov	ecx,1000
	xor	edx,edx
	div	ecx
	mov	TimeVar,eax

	mov	UdragStatus,1
	mov	eax,400
	mov	ebx,1024
	mul	ebx
	mov	ebx,20
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMiniValue,1
	lea	eax,TimeVar
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,TimeUdragMean
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret

TimeUdragMean:
	pushad
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	ebp,word ptr [esi-2]
	dec	ebp
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	mov	eax,TimeVar
	mov	ebx,1000
	mul	ebx
	mov	ebx,[esi]
	sub	ebx,eax
	mov	[esi],eax
	cmp	ebp,EnvelopePointNummer
	jz	noskojas2
	add	[esi+9],ebx
noskojas2:
	call	UpdateEnvCurve
	call 	PrintEnvTime
	popad
	ret


EnvelopeArrowUp:			  ;Envelope arrow up -----------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	cmp	EffectEnvelopeSelect,1
	jz	DoUpPitchA
	cmp	EffectEnvelopeSelect,2
	jz	DoUpVolumeA
DoUpDelayA:
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,1
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,4
	mov	eax,[esi]
	add	eax,1000
	cmp	eax,350000000
	jbe	nojkaA
	mov	eax,350000000
nojkaA:
	mov	[esi],eax
	call	PrintEnvelopeValue
	call	PutEnvelopeCurve
	popad
	ret
DoUpPitchA:
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,2
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,4
	mov	eax,[esi]
	add	eax,1
	cmp	eax,576
	jle	nojka2A
	mov	eax,576
nojka2A:
	mov	[esi],eax
	call	PrintEnvelopeValue
	call	PutEnvelopeCurve
	popad
	ret
DoUpVolumeA:
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,3
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,4
	mov	eax,[esi]
	add	eax,1
	cmp	eax,60000
	jbe	nojka3A
	mov	eax,60000
nojka3A:
	mov	[esi],eax
	call	PrintEnvelopeValue
	call	PutEnvelopeCurve
	popad
	ret

EnvelopeArrowDown:			 ;Envelope arrow down -----------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	cmp	EffectEnvelopeSelect,1
	jz	DoDownPitchA
	cmp	EffectEnvelopeSelect,2
	jz	DoDownVolumeA
DoDownDelayA:
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,1
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,4
	mov	eax,[esi]
	sub	eax,1000
	cmp	eax,0
	jge	nojka_A
	mov	eax,0
nojka_A:
	mov	[esi],eax
	call	PrintEnvelopeValue
	call	PutEnvelopeCurve
	popad
	ret
DoDownPitchA:
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,2
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,4
	mov	eax,[esi]
	sub	eax,1
	cmp	eax,-576
	jge	nojka2_A
	mov	eax,-576
nojka2_A:
	mov	[esi],eax
	call	PrintEnvelopeValue
	call	PutEnvelopeCurve
	popad
	ret
DoDownVolumeA:
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,3
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,4
	mov	eax,[esi]
	sub	eax,1
	cmp	eax,0
	jge	nojka3_A
	mov	eax,0
nojka3_A:
	mov	[esi],eax
	call	PrintEnvelopeValue
	call	PutEnvelopeCurve
	popad
	ret
EnvelopeDword	  dd	  0
EnvelopeUdrag:				  ;Envelope Udrag ----------------------
	pushad
	call	CheckIfNowFastPreview
	cmp	EffectEnvelopeSelect,1
	jz	DoDownPitch2A
	cmp	EffectEnvelopeSelect,2
	jz	DoDownVolume2A
DoDownDelay2A:				 ;delay *********
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,1
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,4
	mov	eax,[esi]
	mov	ebx,1000
	xor	edx,edx
	div	ebx
	mov	EnvelopeDword,eax

	mov	UdragStatus,1
	mov	eax,350000
	mov	ebx,1024
	mul	ebx
	mov	ebx,900
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,350000
	mov	UdragMiniValue,0
	lea	eax,EnvelopeDword
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,MeanWhileEnvelope1A
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret
MeanWhileEnvelope1A:
	pushad
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,1
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,4
	mov	eax,EnvelopeDword
	mov	ebx,1000
	mul	ebx
	mov	[esi],eax
	call	PrintEnvelopeValue
	call	PutEnvelopeCurve
	popad
	ret

DoDownPitch2A:				 ;pitch ********
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,2
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,4
	mov	eax,[esi]
	add	eax,576
	mov	EnvelopeDword,eax

	mov	UdragStatus,1
	mov	eax,576*2
	mov	ebx,1024
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,576*2
	mov	UdragMiniValue,0
	lea	eax,EnvelopeDword
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,MeanWhileEnvelope2A
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret
MeanWhileEnvelope2A:
	pushad
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,2
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,4
	mov	eax,EnvelopeDword
	sub	eax,576
	mov	[esi],eax
	call	PrintEnvelopeValue
	call	PutEnvelopeCurve
	popad
	ret
DoDownVolume2A: 			 ;volume *******
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,3
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,4
	mov	eax,[esi]
	mov	EnvelopeDword,eax

	mov	UdragStatus,1
	mov	eax,60000
	mov	ebx,1024
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,60000
	mov	UdragMiniValue,0
	lea	eax,EnvelopeDword
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,MeanWhileEnvelope3A
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret
MeanWhileEnvelope3A:
	pushad
	mov	esi,[alloctable+1051*8]
	mov	eax,VoiceEnvNumber
	mov	ebx,3
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvelopePointNummer
	lea	eax,[eax*8+eax]
	add	esi,eax
	add	esi,4
	mov	eax,EnvelopeDword
	mov	[esi],eax
	call	PrintEnvelopeValue
	call	PutEnvelopeCurve
	popad
	ret








ShowEnvCurves:				;Show env curves ----------------------
	pushad
	cmp     EffectEnvelopeSelect,3
	jz	_retp
	call	mouseoff
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	ebx,word ptr [esi-2]
	dec	ebx
 	mov	eax,EnvelopePointNummer
	cmp	eax,ebx
	jnz	nodlmova
	mov	dl,3
	jmp	dlmova
nodlmova:
 	lea	eax,[eax*8+eax]
 	add	esi,eax
 	mov 	dl,[esi+8]
dlmova:

	mov	buttonX1,532
	mov	buttonY1,356
	mov	buttonX2,542
	mov	buttonY2,370
	mov	bl,1
	cmp	dl,0
	jnz	noskolabojkul0
	xor	bl,1
noskolabojkul0:
	call	buttonupdown
	mov	buttonX1,543
	mov	buttonY1,356
	mov	buttonX2,553
	mov	buttonY2,370
	mov	bl,1
	cmp	dl,2
	jnz	noskolabojkul1
	xor	bl,1
noskolabojkul1:
	call	buttonupdown
	mov	buttonX1,554
	mov	buttonY1,356
	mov	buttonX2,564
	mov	buttonY2,370
	mov	bl,1
	cmp	dl,1
	jnz	noskolabojkul2
	xor	bl,1
noskolabojkul2:
	call	buttonupdown
	call	mouseon
	popad
	ret
SetCurve0:				;Set curve 0 -----------------------
	pushad
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
 	mov	eax,EnvelopePointNummer
 	lea	eax,[eax*8+eax]
 	add	esi,eax
 	cmp	byte ptr [esi+8],3
 	jz	_retp
	mov	byte ptr [esi+8],0
	call	UpdateEnvelope
	popad
	ret
SetCurve1:				;Set curve 1 -----------------------
	pushad
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
 	mov	eax,EnvelopePointNummer
 	lea	eax,[eax*8+eax]
 	add	esi,eax
 	cmp	byte ptr [esi+8],3
 	jz	_retp
	mov	byte ptr [esi+8],2
	call	UpdateEnvelope
	popad
	ret
SetCurve2:				;Set curve 2 -----------------------
	pushad
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
 	mov	eax,EnvelopePointNummer
 	lea	eax,[eax*8+eax]
 	add	esi,eax
 	cmp	byte ptr [esi+8],3
 	jz	_retp
	mov	byte ptr [esi+8],1
	call	UpdateEnvelope
	popad
	ret


EnvLoopStartUp: 			 ;Env Loop Start up ------------------
	pushad
	call	fixbutton
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	cmp	word ptr [esi-2],1
	jz	_retp
	movzx	eax,word ptr [esi-4]
	dec	eax
	movzx	ebx,word ptr [esi-6]
	cmp	ebx,eax
	jz	_retp
	inc	word ptr [esi-6]
	call	UpdateEnvelope
	popad
	ret
EnvLoopStartDown:			 ;Env Loop Start Down --------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	cmp	word ptr [esi-2],1
	jz	_retp
	cmp	word ptr [esi-6],0
	jz	_retp
	dec	word ptr [esi-6]
	call	UpdateEnvelope
	popad
	ret

EnvUdragga	dd	0
EnvLoopStartUdrag:			 ;Env Loop Start Udrag -------------
	pushad
	call	CheckIfNowFastPreview
	mov	UdragStatus,1
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	cmp	word ptr [esi-2],1
	jz	_retpb
	movzx	eax,word ptr [esi-4]
	dec	eax
	movzx	ebx,word ptr [esi-6]
	mov	EnvUdragga,ebx
	mov	UdragMaxValue,eax
	mov	ebx,1024*10
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMiniValue,0
	lea	eax,EnvUdragga
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,ENvLoopaMean
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret
EnvLoopaMean:
	pushad
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvUdragga
	mov	[esi-6],ax
	call	UpdateEnvelope
	popad
	ret

_retpb:
	call	fixbutton
	popad
	ret

LenLoopStartTextInput:			 ;Env loop start Text Input --------
	ret
	pushad
	call	CheckIfNowFastPreview

	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	cmp	word ptr [esi-2],1
	jz	_retp
	movzx	eax,word ptr [esi-4]
	dec	eax
	mov	edx,eax
	movzx	ebx,word ptr [esi-6]
	mov	EnvUdragga,ebx

	move	edi,0a0000h+152/8+424*80
	mov	ax,0111h
	lea	ebp,EnvUdragga
	mov	ecx,5
	mov	ebx,0
	lea	esi,EnvLoopaMean
	mov	digitsize,3
	call	ZyricInput
	popad
	ret


EnvLoopendUp:			       ;Env Loop end up ------------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	cmp	word ptr [esi-2],1
	jz	_retp
	movzx	eax,word ptr [esi-2]
	dec	eax
	movzx	ebx,word ptr [esi-4]
	cmp	ebx,eax
	jz	_retp
	inc	word ptr [esi-4]
	call	UpdateEnvelope
	popad
	ret
EnvLoopEndDown: 		       ;Env Loop End Down --------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	cmp	word ptr [esi-2],1
	jz	_retp
	mov	bx,[esi-6]
	inc	bx
	cmp	word ptr [esi-4],bx
	jz	_retp
	dec	word ptr [esi-4]
	call	UpdateEnvelope
	popad
	ret

EnvLoopEndUdrag:		       ;Env Loop End Udrag -------------
	pushad
	call	CheckIfNowFastPreview
	mov	UdragStatus,1
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	cmp	word ptr [esi-2],1
	jz	_retpb
	movzx	eax,word ptr [esi-2]
	dec	eax
	movzx	ebx,word ptr [esi-4]
	mov	EnvUdragga,ebx
	mov	UdragMaxValue,eax
	mov	ebx,1024*10
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	movzx	eax,word ptr [esi-6]
	inc 	eax
	mov	UdragMiniValue,eax
	lea	eax,EnvUdragga
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,ENvLoopaMean2
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret
EnvLoopaMean2:
	pushad
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,EnvUdragga
	mov	[esi-4],ax
	call	UpdateEnvelope
	popad
	ret

LenLoopEndTextInput:		       ;Env loop end Text Input --------
	ret
	call	CheckIfNowFastPreview
	pushad

	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	eax,word ptr [esi-2]
	dec	eax
	mov	edx,eax
	movzx	ebx,word ptr [esi-4]
	inc	ebx
	mov	EnvUdragga,ebx

	move	edi,0a0000h+152/8+442*80
	mov	ax,0111h
	lea	ebp,EnvUdragga
	mov	ecx,5
	movzx	ebx,word ptr [esi-6]
	lea	esi,EnvLoopaMean
	mov	digitsize,3
	call	ZyricInput
	popad
	ret

SmallSave	dd	0
PointSave	dd	0
littleflag	db	0
CreatePoint:				;Create point --------------------
	pushad

	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	mov	eax,esi
	movzx	ebp,word ptr [esi-2]
	cmp	ebp,500
	jz	_retp

 	mov	ebx,EnvelopePointNummer
 	inc	ebx
	cmp 	ebp,ebx
	jz	skipfirstcall
	pushad
	dec	ebp
	sub	eax,[alloctable+1051*8]
	mov	PointSave,eax
 	mov	eax,EnvelopePointNummer
 	lea	eax,[eax*8+eax]
 	add	esi,eax
	mov	eax,[esi+9]
	cmp	eax,1000
	jg	ojakalla
	popad
	popad
	ret
ojakalla:
	popad
SkipFirstCall:
					;fix with loops
	pushad
 	mov	eax,EnvelopePointNummer
	cmp	word ptr [esi-6],ax
	jb	noloopchange1_
	inc	word ptr [esi-6]
noloopchange1_:
	cmp	word ptr [esi-4],ax
	jb	noloopchange2_
	inc	word ptr [esi-4]
noloopchange2_:
	popad


	cmp	ebp,1
	jnz	noonebaka
	mov	word ptr [esi-6],0
	mov	word ptr [esi-4],1
noonebaka:

	dec	ebp
	sub	eax,[alloctable+1051*8]
	mov	PointSave,eax
 	mov	eax,EnvelopePointNummer
 	lea	eax,[eax*8+eax]
 	add	esi,eax


	cmp     ebp,EnvelopePointNummer ;get time last
	jnz	doitmiddle
	mov	littleflag,1
	mov	edx,50000
	jmp	aftertimen
doitmiddle:
	mov	eax,[esi+9]
	cmp	eax,1000
	jle	_retp
	mov	littleflag,0
	mov	edx,[esi+9]		;get time middle
	shr	edx,1
	mov	eax,edx
	mov	ebx,1000
	xor	edx,edx
	div	ebx
	mul	ebx
	mov	edx,eax
	cmp	edx,1000
	jge	nokokakola
	mov	edx,1000
nokokakola:
aftertimen:

	sub	esi,[alloctable+1051*8]
	mov	ecx,9
	add	esi,9
	mov	ebp,1051
	call	MakeAllocSpace
	jc	_retp

	mov	edi,[alloctable+1051*8]
	mov	dword ptr [esi+edi],edx
	mov	eax,dword ptr [esi+edi-5]
 	mov	dword ptr [esi+edi+4],eax
	mov	al,byte ptr [esi+edi-1]
	cmp	al,3
	jnz	nochock
	mov	byte ptr [esi+edi-1],0
nochock:
  	mov	byte ptr [esi+edi+8],al
	cmp	littleflag,1
	jz	skipthiscode
	sub	dword ptr [esi+edi+9],edx
skipthiscode:
	mov	eax,pointsave
	inc	word ptr [eax+edi-2]

	call	UpdateEnvelope
	popad
	ret


DeletePoint:				;Delete point -----------------------
	pushad
	call	fixbutton
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	edx,word ptr [esi-2]
	cmp	edx,1
	jz	_retp

					;fix with loops
	pushad
 	mov	eax,EnvelopePointNummer
	cmp	word ptr [esi-4],ax
	jb	noloopchange1
	dec	word ptr [esi-4]
noloopchange1:
	cmp	word ptr [esi-6],ax
	jb	noloopchange2
	dec	word ptr [esi-6]
noloopchange2:
	popad


	cmp	edx,2
	jnz	nonumma2
	mov 	byte ptr [esi-7],0
  	mov	word ptr [esi-6],0
  	mov	word ptr [esi-4],0
nonumma2:


	pushad
	sub	edx,2
	cmp	edx,0
	jnz	nospecialzero
	mov	dword ptr [esi-6],0
	jmp	EndSpecialLoop
nospecialzero:
	cmp	word ptr [esi-4],dx
	jbe	skipsetenden
	mov	word ptr [esi-4],dx
skipsetenden:
	dec	dx
	cmp	word ptr [esi-6],dx
	jbe	endspecialloop
	mov	word ptr [esi-6],dx
EndSpecialLoop:
	popad

	dec	edx
	mov	smallsave,edx
	dec	word ptr [esi-2]
 	mov	eax,EnvelopePointNummer
 	lea	eax,[eax*8+eax]
 	add	esi,eax
	cmp	edx,EnvelopePointNummer
	jz	skippaslaget
	mov	eax,[esi]
	add  	[esi+9],eax
skippaslaget:
	cmp	EnvelopePointNummer,0
	jnz	noNumberNull
	cmp	edx,1
	jz	nonuber1
	mov	eax,[esi+9]
	add	[esi+9*2],eax
nonuber1:
	mov	dword ptr [esi+9],0
noNumberNull:

	cmp	byte ptr [esi+8],3
	jnz	nolasten
	mov	byte ptr [esi-1],3
nolasten:
	mov	ebp,1051
	sub	esi,[alloctable+1051*8]
	mov	ecx,9
	call	DelAllocSpace

	mov	eax,smallsave
	dec	eax
	cmp	EnvelopePointNummer,eax
	jbe	noprobbs
	mov	EnvelopePointNummer,eax
noprobbs:
	call	UpdateEnvelope
	popad
	ret



ThePointUp:				;ThePointUp -------------------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	call	createpoint
	popad
	ret

ThePointDown:				;The point down --------------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	call	deletepoint
	popad
	ret
ThePointUdrag:				;The point udrag ------------------
	pushad



	popad
	ret

ThePointInput:				;The point input -------------------
	pushad

	popad
	ret

;******************************************************************************
;				 ENVELOPE CURVE
;******************************************************************************

CurveVar	dd	0
EdiCurveAdd	dd	0
OldTimeLoop	dd	0
ollefirst	db	0

DoFirstDot	db	0
ClipIndicate	db	0
DoFirstY	db	0
FirstY		dd	0,0  		;Y,X
LastY		dd	0,0		;Y,X
CurrentPoint3	dd	0

SpecialFirst	db	0		;Fix first point in curve
PutEnvelopeCurve:			;Put Envelope curve ----------------
	pushad
	cmp  	EffectEnvelopeSelect,3
	jz	_retp

	call	PutDragbarData

	mov	eax,64*280/2	;alloc buffer
	xor	ebx,ebx
	mov	ebp,1037
	call	memalloc
	jc	RemoveMemory
				;clear buffer
	mov	edi,eax
	mov	ecx,64*280/2
	xor	eax,eax
	rep	stosb
				;draw curves ***


	mov	DoFirstDot,1
	mov	CurrentPoint3,0
	mov	EnvelopeDotBufferPtr,0

	mov	EdiCurveAdd,0
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	ebp,word ptr [esi-2]
	inc	ebp

	mov	EnvelopeDotBufferPtr,0

	xor	ebx,ebx 	;time pos
DrawCurveLoop:

LoopTimeSearch: 		;search new time
	dec	ebp
	jz	AfterDrawCurveLoop
	mov	OldTimeLoop,ebx
	add	ebx,[esi]			;<-------- Bug
	add	esi,9
	inc	CurrentPoint3
	cmp	ebx,EnvTimePos
	jb	LoopTimeSearch

	push	ebx ebp

	cmp	ebx,0 		;first special
	jnz	nofirstspecial
	push	esi
	add	esi,9
	mov	edx,0
	mov	SpecialFirst,1
	call	CalculateCurveValue
	mov	SpecialFirst,0
	pop	esi
	mov	eax,edx
	mov	ebx,0
	mov	ecx,1
	call	DrawCurveDot
	jmp	DoFirstSpecial
nofirstspecial: 		;Get pos in curve

	mov	edx,OldTimeLoop
	cmp	edx,EnvTimePos
	jb	MustFixen
	xor	ecx,ecx
	mov	ClipIndicate,0
	jmp	AlreadyInside
MustFixen:
	mov	ClipIndicate,1
	sub	ebx,EnvTimePos
	mov	eax,[esi-9]
	mov	ecx,eax
	sub	eax,ebx
	mov	ebx,16384/4-1
	mul	ebx
	div	ecx
	mov	ecx,eax
AlreadyInside:

	mov	eax,EnvTimeZoom
	mov	ebx,1462857
	mul	ebx
	mov	ebx,[esi-9]
	div	ebx
	mov	ebx,eax

	mov	DoFirstY,1

	mov	ollefirst,0
	mov	OldScreenVal,-2
	mov	CurveVar,0
PutCurveLoop:			;PutCurveLoop
	push	ebx ecx
	mov	eax,CurveVar
	mov	ebx,1000
	xor	edx,edx
	div	ebx
	add	ecx,eax
	cmp	ecx,16384/4
	jb	OjsanOlle
	cmp	ollefirst,1
	jz	EndThisCurvePut
	mov	ecx,16384/4-1
	mov	ollefirst,1
OjsanOlle:
	call	GetCurveValue
	call	CalculateCurveValue

	cmp	DoFirstY,1
	jnz	nofirstnow
	mov	DoFirstY,0
	mov	[FirstY],edx
	mov	eax,EdiCurveAdd
	mov	[FirstY+4],eax
nofirstnow:
	mov	[LastY],edx
	mov	eax,EdiCurveAdd
	mov	[LastY+4],eax

	call	PutEnvelopeCurveDot


	pop	ecx ebx
	add	CurveVar,ebx
	inc	EdiCurveAdd
	cmp	EdiCurveAdd,280
	jb	PutCurveLoop
	pop	ebp ebx
	jmp	AfterDrawCurveLoop
EndThisCurvePut:
	pop	ecx ebx
				;draw dots
	cmp	DoFirstDot,1
	jnz	nofirst
	cmp	ClipIndicate,1
	jz	NoFirst
	mov	DoFirstDot,0
	mov	eax,[FirstY]
	mov	ebx,[FirstY+4]
	mov	ecx,CurrentPoint3
	dec	ecx
	call	DrawCurveDot
	call	DrawLoopLines
nofirst:
	mov	eax,[LastY]
	mov	ebx,[LastY+4]
	mov	ecx,CurrentPoint3
	call	DrawCurveDot
	call	DrawLoopLines

DoFirstSpecial:
	pop	ebp ebx
	jmp	DrawCurveLoop
AfterDrawCurveLoop:


	call	mouseoff
				;View Curve on screen
	move	edi,0a0000h+232/8+352*80
	mov	esi,[alloctable+1037*8]
	mov	ecx,64
ViewLoppenEnvY:
	push	ecx esi

	mov	ax,1
	mov	ecx,4
PlaneLoopen:
	push	ecx edi
	planewrite al
	mov	ecx,35
	rep	movsb
	add	esi,35*63
	shl	ax,1
	pop	edi ecx
	loop	PlaneLoopen

	pop	esi ecx
	add	edi,80
	add	esi,35
	loop	ViewLoppenEnvY
endan:
	call	mouseon

	xor	eax,eax 	;dealloc buffer
	xor	ebx,ebx
	mov	ebp,1037
	call	memalloc
	jc	RemoveMemory

	popad
	ret
SelectNr	dd	0
SelectCords	dw	0,0 ;x,y
SelectEnvCurveFirst:			;Select Env Curve First -----------
	pushad

	call	CheckIfNowFastPreview
	movzx	eax,mouseX
	movzx	ebx,mouseY
	sub	eax,232
	sub	ebx,352
	lea	esi,EnvelopeDotBuffer
	mov	ecx,EnvelopeDotBufferPtr
	xor	ebp,ebp
	jecxz	_retp
CheckLoopCurve:
	push	ecx
	mov	cx,[esi]
	mov	dx,[esi+2]
	dec	cx
	dec	dx
	cmp	ax,cx
	jl	SkippaDennaPunkten
	cmp	bx,dx
	jl	SkippaDennaPunkten
	add	cx,4
	add	dx,4
	cmp	ax,cx
	jg	SkippaDennaPunkten
	cmp	bx,dx
	jg	SkippaDennaPunkten
	mov	dx,[esi]
	inc	dx
	sub	dx,ax
	sub	dx,bp
	mov	[SelectCords],dx
	mov	dx,[esi+2]
	inc	dx
	sub	dx,bx
	mov	[SelectCords+2],dx
	mov	ax,[esi+4]
	mov	SelectNr,eax
	jmp	AfterLoopenApa

SkippaDennaPunkten:
	inc	ebp
	add	esi,6
	pop	ecx
	loop	CheckLoopCurve
	popad
	ret
AfterLoopenApa:
	pop	ecx ebx eax

	mov	eax,SelectNr
	mov 	EnvelopePointNummer,eax

	mov	dword ptr [OldMouseCords],-1
	mov	MouseOnDragBar,-6
	call	SelectEnvCurve
	popad
	ret

OldMouseCords	dw	-1,-1
TheCurveX	dd	0
TheCurveY	dd	0
SelectEnvCurve:				;Select Env Curve ------------------
	pushad
	mov	leftkeywait,1
	mov	rightkeywait,1
	mov	bothkeywait,1

	movzx	eax,mouseX
	movzx	ebx,mouseY
	cmp	ax,[OldMouseCords]
	jnz	NotSampNow2
	cmp	bx,[OldMouseCords+2]
	jnz	NotSampNow2
 	popad
	ret
NotSampNOw2:			     	;get screen cords
	mov	[OldMouseCords],ax
	mov	[OldMouseCords+2],bx

	movsx	ecx,word ptr [SelectCords]
	add	eax,ecx
	movsx	ecx,word ptr [SelectCords+2]
	add	ebx,ecx

	cmp	eax,232
	jae	nogris1
	mov	eax,232
nogris1:
	cmp	eax,509
	jbe	nogris2
	mov	eax,509
nogris2:
	cmp	ebx,352
	jae	nogris3
	mov	ebx,352
nogris3:
	cmp	ebx,415
	jbe	nogris4
	mov	ebx,415
nogris4:
	sub	eax,232
	sub	ebx,352
	mov	TheCurveX,eax
	mov	TheCurveY,ebx


	mov	eax,EnvTimeZoom			;calc new time
	mov	ebx,100
	mul	ebx
	mov	ebx,TheCurveX
	mul	ebx
	mov	ebx,280
	div	ebx
	add	eax,EnvTimePos
	mov	ebx,1000
	xor	edx,edx
	div	ebx
	mul	ebx
	mov	ebp,eax


	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	edi,word ptr [esi-2]
	mov	ecx,SelectNr
	xor	ebx,ebx
	jecxz	afterTimeScan
ScanRightTime:
	add	ebx,[esi]
	add	esi,9
	loop	ScanRightTime
noloopen:
				;ebx=min
				;ecx=max
	mov	eax,SelectNr
	inc	eax
	cmp	eax,edi
	jz	LastPoint2
	mov	ecx,ebx
	add	ecx,[esi]
	add	ecx,[esi+9]
	jmp	AfterLastPoint
LastPoint2:
	mov	ecx,350000000
AfterLastPoint:

	add	ebx,1000
	sub	ecx,1000
			;clip
	cmp	ebp,ebx
	jae	NoSvin1
	mov	ebp,ebx
NoSvin1:
	cmp	mouseB,2
	jz	NoSvin2
	cmp	ebp,ecx
	jbe	NoSvin2
	mov	ebp,ecx
NoSvin2:
	sub	ebp,ebx
	add	ebp,1000

	cmp	MouseB,2        	;save new time
	jz	DoDotMoveAll
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	ecx,word ptr [esi-2]
	mov	ebx,SelectNr
	lea	eax,[ebx*8+ebx]
	add	esi,eax
	mov	ebx,[esi]
	mov	[esi],ebp
	mov	eax,SelectNr
	inc	eax
	cmp	eax,ecx
	jz	AfterMoving
	sub	ebx,ebp
	add	[esi+9],ebx
	jmp	AfterMoving
DoDotMoveAll:
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	ecx,word ptr [esi-2]
	mov	ebx,SelectNr
	lea	eax,[ebx*8+ebx]
	add	esi,eax
	mov	[esi],ebp
AfterMoving:

				      	;calculate value
AfterTimeScan:
	mov	eax,TheCurveY
	mov	ebx,EnvCurveYZoomSize
	cmp	ebx,EnvCurveYZoomPos
	jz	nobugfix1
	cmp	eax,63
	jnz	nobugfix1
	dec	eax
nobugfix1:

	mul	ebx
	mov	ebx,63
	div	ebx
	mov	ebx,EnvCurveYZoomPos
	sub	ebx,eax
	cmp	ebx,1000000
	jle	nopap1
       	mov	ebx,1000000
nopap1:
	cmp	ebx,0
	jge	nopap2
       	mov	ebx,0
nopap2:
	mov	eax,ebx

	cmp	EffectEnvelopeSelect,0
	jnz	noDelayen_BB
	mov	ebx,350000000
	mul	ebx
	mov	ebx,1000000
	div	ebx
	cmp	eax,350000000
	jbe	noDelayen_BB
	mov	eax,350000000
noDelayen_BB:
	cmp	EffectEnvelopeSelect,1
	jnz	noPitchen_BB
	mov	ebx,576*2+1
	mul	ebx
	mov	ebx,1000000
	div	ebx
	sub	eax,576
	cmp	eax,576
	jle	nomore55
	mov	eax,576
nomore55:
	cmp	eax,-576
	jge	nomore56
	mov	eax,-576
nomore56:

noPitchen_BB:
	cmp	EffectEnvelopeSelect,2
	jnz	noVolumen_BB
	mov	ebx,60000
	mul	ebx
	mov	ebx,1000000
	div	ebx
	cmp	eax,60000
	jbe	noVolumen_BB
	mov	eax,60000
noVolumen_BB:
	mov	ebp,eax

	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	ecx,word ptr [esi-2]
	mov	ebx,SelectNr
	lea	eax,[ebx*8+ebx]
	add	esi,eax
	mov	[esi+4],ebp

	call 	UpdateEnvelope

	popad
	ret


DrawLoopLines:				;Draw loop lines -------------------
	pushad
	dec	ecx
	mov	XposDot,ebx
	mov	YposDot,eax
	mov	DotNr,ecx

	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	cmp	byte ptr [esi-7],0
	jz	_retp

 	mov	eax,DotNr
 	cmp	word ptr [esi-6],ax
  	jz 	DoLineen
 	cmp	word ptr [esi-4],ax
  	jz 	DoLineen
  	jmp	_retp
DoLineen:

	mov	edi,[alloctable+1037*8]
	mov	eax,XposDot
	xor	edx,edx
	mov	ebx,8
	div	ebx
	add	edi,eax
	mov	cx,dx
	mov	ax,010000000b
	shr	ax,cl
	mov	ecx,32
DrawLoopa:
	or	[edi],al
	add	edi,70
	loop	DrawLoopa

	popad
	ret
;eax = Y pos
;ebx = X pos
;ecx = Current Dot
XposDot		dd	0
YposDot		dd	0
DotNr		dd	0
DrawCurveDot:				;Draw curve dot --------------------
	pushad
	cmp	eax,-1
	jz	_retp
	cmp	eax,-2
	jz	_retp
	cmp	eax,64
	jnz	NoSpecialKnullen
	mov	edx,EnvCurveYZoomPos
	cmp	edx,EnvCurveYZoomSize
	jnz	NoSpecialKnullen
	mov	eax,63
NoSpecialKnullen:
	cmp	eax,64
	jz	_retp
	cmp	eax,0
	jnz	nofixcord1
	mov	eax,1
nofixcord1:
	cmp	eax,63
	jnz	nofixcord2
	mov	eax,62
nofixcord2:
	cmp	ebx,0
	jnz	nofixcord3
	mov	ebx,1
nofixcord3:
	cmp	ebx,279
	jnz	nofixcord4
	mov	ebx,278
nofixcord4:
	dec	eax
	dec	ebx
	mov	XposDot,ebx
	mov	YposDot,eax
	dec	ecx
	mov	DotNr,ecx

	mov	eax,EnvelopeDotBufferPtr
	mov	ebx,6
	mul	ebx
	mov	ebx,XposDot
	mov	[eax+EnvelopeDotBuffer],bx
	mov	ebx,YposDot
	mov	[eax+EnvelopeDotBuffer+2],bx
	mov	ebx,DotNr
	mov	[eax+EnvelopeDotBuffer+4],bx
	inc	EnvelopeDotBufferPtr

	mov	edi,[alloctable+1037*8]
       	mov	ebx,280/8
	mov	eax,YposDot
       	mul	ebx
       	add	edi,eax
       	mov	eax,XposDot
	mov	ebx,16
	xor	edx,edx
	div	ebx
	shl	eax,1
	cmp	edx,12
	jbe	nobll
      	inc	eax
      	sub	edx,8
nobll:
	add	edi,eax
	mov	ax,7
	mov	cx,13
	sub	cx,dx
	shl	ax,cl
	ror	ax,8

	or	[edi],ax
	or	[edi+35],ax
	or	[edi+70],ax

	mov	ebx,EnvelopePointNummer
	cmp	ebx,DotNr
	jnz	noreddot
	or	[edi+(35*64*1)],ax
	or	[edi+35+(35*64*1)],ax
	or	[edi+70+(35*64*1)],ax
	or	[edi+(35*64*3)],ax
	or	[edi+35+(35*64*3)],ax
	or	[edi+70+(35*64*3)],ax
noreddot:
	popad
	ret



OldScreenVal	dd	-2
TheEdx		dd	0
PutEnvelopeCurveDot:			;Put Envelope Curve Dot -----------
;Input:  edx=Screen value
;OutPut: None
	pushad
	mov	theedx,edx
	cmp	OldScreenVal,-2
	jnz	noolderik
	mov	OldScreenVal,edx
noolderik:
	cmp	oldscreenval,-1
	jnz	skipenden1
	cmp	TheEdx,-1
	jz	EndPuttingHam
skipenden1:
	cmp	oldscreenval,64
	jnz	skipenden2
	cmp	TheEdx,64
	jz	EndPuttingHam
skipenden2:

	cmp	edx,-1
	jnz	nozolen1
	inc	edx
nozolen1:
	cmp	edx,64
	jnz	nozolen2
	dec	edx
nozolen2:

	mov	ebx,OldScreenVal

	cmp	ebx,-1
	jnz	nozolen1A
	inc	ebx
nozolen1A:
	cmp	ebx,64
	jnz	nozolen2A
	dec	ebx
nozolen2A:

	cmp	ebx,edx
	jnz	TheNewVal
	mov	ebp,edx
	mov	ecx,1
	jmp	DoPuttinghamSweden
TheNewVal:


	cmp	ebx,edx
	jle	norge
	sub	ebx,edx
	mov	ecx,ebx
	mov	ebp,edx
	jmp	afternorge
norge:
	mov	ecx,edx
	sub	ecx,ebx
	mov	ebp,ebx
	inc	ebp
afternorge:
DoPuttingHamSweden:
	mov	edi,[alloctable+1037*8]
	mov	eax,EdiCurveAdd
	xor	edx,edx
	mov	ebx,8
	div	ebx
	add	edi,eax
	push	ecx
	mov	ecx,edx
	mov	bx,010000000b
	ror	bx,cl
	pop	ecx
	mov	eax,35
	mul	ebp
	add	edi,eax
PuttenLoopen:
	or	[edi],bl
	add	edi,35
	loop	PuttenLoopen

EndPuttingHam:
	popad
	mov	OldScreenVal,edx
	ret
PutDragbarData: 			;PutDragbar DAta ----------------------
	pushad
	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	ecx,word ptr [esi-2]
	xor	ebx,ebx
AddaLoopa2:
	add	ebx,[esi]
	add	esi,9
	loop	AddaLoopa2
  	mov	eax,EnvTimePos
  	mov 	dword ptr [EnvCurveHorz],eax
  	mov	dword ptr [EnvCurveHorz+4],1
   	mov	eax,EnvTimeZoom
   	mov	ecx,100
   	mul	ecx
  	mov	dword ptr [EnvCurveHorz+12],eax
	add	ebx,eax
  	mov	dword ptr [EnvCurveHorz+8],ebx
	popad
	ret

CalculateCurveValue:			;Calculate curve value ------------
;Calls: edx=Old Value
;Back:	edx=Screen value in pixels (0-63) (up to down) (-1 or 64 if invisible)
	push	eax ebx ecx esi edi ebp
	mov	eax,[esi-9-(9)+4]
	call	ConvVallen

	mov	ebx,eax

	cmp	SpecialFirst,1
	jz	skippaskossan
	mov	eax,[esi-(9)+4]
	call	ConvVallen
	sub	eax,ebx
	mov	ecx,edx
	imul	ecx
	mov	ecx,65535
	idiv	ecx
	add	ebx,eax
skippaskossan:

	cmp	ebx,EnvCurveYZoomPos
	jbe	nooverclip
	mov	edx,-1
	jmp	EndCurveCalc
nooverclip:
	mov	eax,EnvCurveYZoomPos
	sub	eax,EnvCurveYZoomSize
	cmp	ebx,eax
	ja	nounderclip
	mov	edx,64
	jmp	EndCurveCalc
nounderclip:
	mov	eax,EnvCurveYZoomPos
	sub	eax,EnvCurveYZoomSize
	sub	ebx,eax
	mov	eax,ebx
	mov	ebx,63
	mul	ebx
	mov	ebx,EnvCurveYZoomSize
	div	ebx
	mov	edx,63
	sub	edx,eax
EndCurveCalc:

	mov	eax,EnvCurveYZoomPos
	dec	eax
	cmp	eax,EnvCurveYZoomSize
	jnz	noallview
	cmp	edx,64
	jnz	noallview
	mov	edx,63
noallview:

	pop	ebp edi esi ecx ebx eax
	ret


ConvVallen:				;Conv vallen ---------------
	push	ebx edx
	cmp	EffectEnvelopeSelect,0
	jnz	noDelayen_
	mov	ebx,1000000
	mul	ebx
	mov	ebx,350000000
	div	ebx
noDelayen_:
	cmp	EffectEnvelopeSelect,1
	jnz	noPitchen_
	add	eax,576
	mov	ebx,1000000
	mul	ebx
	mov	ebx,576*2+1
	div	ebx
noPitchen_:
	cmp	EffectEnvelopeSelect,2
	jnz	noVolumen_
	mov	ebx,1000000
	mul	ebx
	mov	ebx,60000
	div	ebx
noVolumen_:
	pop	edx ebx
	ret

GetCurveValue:				;Get Curve value -------------------
;calls: ecx=CurvePos
;back:	edx=Value
	push	eax ebx ecx ebp edi esi
	cmp	byte ptr [esi-10],1
	jz	FixSlowStart
	cmp	byte ptr [esi-10],2
	jz	FixSlowEnd

	mov	eax,65535
	mul	ecx
	mov	ebx,16384/4-1
	div	ebx
	mov	edx,eax
	jmp	AfterAllCurveFix
FixSlowStart:			;Fix slow start
	mov	eax,[Pcxoffsets+12*4]
	mov	edx,16384/4-1
	sub	edx,ecx
	mov	eax,[eax+edx*4]
	mov	edx,65535
	sub	edx,eax
	jmp	AfterAllCurveFix
FiXSlowEnd:			;Fix slow end
	mov	eax,[Pcxoffsets+12*4]
	mov	edx,[eax+ecx*4]
AfterAllCurveFix:
	pop	esi edi ebp ecx ebx eax
	ret


EnvCurveArrowLeft:			;EnvCurveArrowLeft ------------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton

	cmp	EnvTimePos,0
	jz	_retp

	mov	eax,EnvTimeZoom
	mov	ebx,100
	mul	ebx
	mov	ebx,280/2
	div	ebx
	sub	EnvTimePos,eax
	cmp	EnvTimePos,0
	jge	Noja
     	mov	EnvTimePos,0
noja:

	call	PutEnvelopeCurve
	popad
	ret
EnvCurveArrowRight:			;EnvCurveArrowRight ------------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton

	mov	eax,EnvTimeZoom
	mov	ebx,100
	mul	ebx
	mov	ebx,280/2
	div	ebx
	add	EnvTimePos,eax

	mov	esi,[alloctable+1051*8]
 	mov	eax,VoiceEnvNumber
	mov	ebx,EffectEnvelopeSelect
	inc	ebx
	call	ScanEffect
	call	AddEsiSelect
	movzx	ecx,word ptr [esi-2]
	xor	ebx,ebx
AddaLoopa:
	add	ebx,[esi]
	add	esi,9
	loop	AddaLoopa

	cmp	EnvTimePos,ebx
	jbe	Noja2
     	mov	EnvTimePos,ebx
noja2:

	call	PutEnvelopeCurve
	popad
	ret
EnvCurveArrowUp:			;EnvCurveArrowUp ------------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	cmp	EnvCurveYZoomPos,1000000
	jz	_retp
	mov	eax,EnvCurveYZoomSize
	mov	ebx,100/2
	xor	edx,edx
	div	ebx
	cmp	eax,0
	jg	nojasAA
	mov	eax,1
nojasAA:
	add	EnvCurveYZoomPos,eax
	cmp	EnvCurveYZoomPos,1000000
	jbe	nojas2AA
	mov	EnvCurveYZoomPos,1000000
nojas2AA:
	call	PutEnvelopeCurve

	popad
	ret
EnvCurveArrowDown:			;EnvCurveArrowDown ------------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton

	cmp	EnvCurveYZoomPos,0
	jz	_retp
	mov	ebp,EnvCurveYZoomSize
	;inc	 ebp
	cmp	ebp,EnvCurveYZoomPos
	jz	_retp
	mov	eax,EnvCurveYZoomSize
	mov	ebx,100/2
	xor	edx,edx
	div	ebx
	cmp	eax,0
	jg	nojas3AA
	mov	eax,1
nojas3AA:
	sub	EnvCurveYZoomPos,eax
	cmp	EnvCurveYZoomPos,ebp
	jge	nojas4AA
	mov	EnvCurveYZoomPos,ebp
nojas4AA:
	call	PutEnvelopeCurve
	popad
	ret
EnvCurveVertZoomPlus:			;EnvCurveVertZoomPlus ------------------
	pushad
	call	fixbutton
	call	CheckIfNowFastPreview
	cmp	EnvCurveYZoomSize,2
	jz	_retp
	mov	eax,EnvCurveYZoomSize
	mov	ebp,eax
	mov	ebx,95
	mul	ebx
	mov	ebx,100
	div	ebx
	cmp	eax,2
	jge	nojas5AA
	mov	eax,2
nojas5AA:
	sub	ebp,eax
	shr	ebp,1
	sub	EnvCurveYZoomPos,ebp
	mov	EnvCurveYZoomSize,eax
	call	PutEnvelopeCurve
	popad
	ret
EnvCurveVertZoomMinus:			;EnvCurveVertZoomMinus ------------------
	pushad
	call	fixbutton
	call	CheckIfNowFastPreview
	cmp	EnvCurveYZoomSize,1000000
	jz	_retp
	mov	eax,EnvCurveYZoomSize
	mov	ebp,eax
	mov	ebx,100
	mul	ebx
	mov	ebx,95
	div	ebx
	cmp	eax,ebp
	jnz	nokvas
       	inc	eax
nokvas:
	cmp	eax,1000000
	jbe	nojas6AA
	mov	eax,1000000
nojas6AA:
	mov	EnvCurveYZoomSize,eax
	mov	ebx,eax
	sub	ebx,ebp
	shr	ebx,1
	add	EnvCurveYZoomPos,ebx
	inc	eax
	cmp	EnvCurveYZoomPos,eax
	jae	nojkaba
	mov	EnvCurveYZoomPos,eax
nojkaba:
	cmp	EnvCurveYZoomPos,1000000
	jbe	nokaAA
     	mov	EnvCurveYZoomPos,1000000
nokaAA:
	call	PutEnvelopeCurve
	popad
	ret
EnvCurveHorzZoomPlus:			;EnvCurveHorzZoomPlus ------------------
	pushad
	call	fixbutton
	call	CheckIfNowFastPreview
	cmp	EnvTimeZoom,2
	jz	_retp
	mov	eax,EnvTimeZoom
	mov	ebp,eax
	mov	ebx,95
	mul	ebx
	mov	ebx,100
	div	ebx
	cmp	eax,2
	jge	nojas5AABALLA
	mov	eax,2
nojas5AABALLA:
	sub	ebp,eax
	shr	ebp,1
;	add	EnvTimePos,ebp
	mov	EnvTimeZoom,eax
	call	PutEnvelopeCurve
	popad
	ret
EnvCurveHorzZoomMinus:			;EnvCurveHorzZoomMinus ------------------
	pushad
	call	fixbutton
	call	CheckIfNowFastPreview
	cmp	EnvTimeZoom,1000000
	jz	_retp
	mov	eax,EnvTimeZoom
	mov	ebp,eax
	mov	ebx,100
	mul	ebx
	mov	ebx,95
	div	ebx
	cmp	eax,ebp
	jnz	nokvasGG
       	inc	eax
nokvasGG:
	cmp	eax,1000000
	jbe	nojas6AAGG
	mov	eax,1000000
nojas6AAGG:
	mov	EnvTimeZoom,eax
	mov	ebx,eax
	sub	ebx,ebp
	shr	ebx,1
;	sub	EnvTimePos,ebx
;	cmp	EnvTimePos,0
;	jge	nokaAAGG
;     	mov	EnvTimePos,0
;nokaAAGG:
	call	PutEnvelopeCurve

	popad
	ret

UpdateEnvCurveX:			;Update Env Curve X ------------------
	pushad
 	mov	eax,[EnvCurveHorz]
 	mov	EnvTimePos,eax
	call	PutEnvelopeCurve
	popad
	ret
;******************************************************************************
;				 Real pitch
;******************************************************************************
NoRealPitch:				;No Real Pitch -------------------
	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	mov	ebx,2
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	mov	byte ptr [esi+4],0
	call	ShowRealPitchen

	popad
	ret
C_4RealPitch:				;C-4 Real Pitch ----------------------
	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	mov	ebx,2
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	mov	byte ptr [esi+4],1
	call	ShowRealPitchen

	popad
	ret
FixedRealPitch: 			;Fixed Real pitch --------------------
	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	mov	ebx,2
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	mov	byte ptr [esi+4],2
	call	ShowRealPitchen

	popad
	ret

ShowRealPitchen:			;Show real pitchen
	pushad
	cmp	EffectEnvelopeSelect,3
	jnz	_retp
	call	mouseoff
	mov	esi,[alloctable+1051*8]
	mov	ebx,2
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	mov	al,[esi+4]

	mov	buttonX1,331
	mov	buttonY1,377
	mov	buttonX2,341
	mov	buttonY2,388
	mov	bl,1
	cmp	al,0
	jnz	bora1
	xor	bl,1
bora1:
	call	buttonupdown
	mov	buttonX1,331
	mov	buttonY1,390
	mov	buttonX2,341
	mov	buttonY2,401
	mov	bl,1
	cmp	al,1
	jnz	bora2
	xor	bl,1
bora2:
	call	buttonupdown
	mov	buttonX1,331
	mov	buttonY1,403
	mov	buttonX2,341
	mov	buttonY2,414
	mov	bl,1
	cmp	al,2
	jnz	bora3
	xor	bl,1
bora3:
	call	buttonupdown

	call	mouseon
	popad
	ret
PutRealPitch:				;Put Real Pitch ------------------
	pushad
	cmp	EffectEnvelopeSelect,3
	jnz	_retp

	call	mouseoff
	mov	esi,[alloctable+1051*8]
	mov	ebx,2
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	movzx	ebx,word ptr [esi+5]
	mov	ah,1
	mov	cl,5
	move	edi,0a0000h+424/8+419*80
	mov	fontplane,1
	call	PutDecimal
	mov	FontPlane,0
	call	mouseon
	call	mousereset
	call	mouseon

	popad
	ret
RealPitchArrowUp:			;RealPitchArrowUp ----------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	mov	esi,[alloctable+1051*8]
	mov	ebx,2
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	cmp	word ptr [esi+5],65535
	jz	_retp
	inc	word ptr [esi+5]
	call	PutRealPitch
	popad
	ret
RealPitchArrowDown:			;RealPitchArrowDown ----------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton
	mov	esi,[alloctable+1051*8]
	mov	ebx,2
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	cmp	word ptr [esi+5],10
	jz	_retp
	dec	word ptr [esi+5]
	call	PutRealPitch
	popad
	ret
RealVaren	dd	0
RealPitchUdrag: 			;RealPitchUdrag ----------------
	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	mov	ebx,2
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	movzx	eax,word ptr [esi+5]
	mov	RealVaren,eax

	mov	UdragStatus,1   		;udrag size
	mov	eax,2000
	mov	ebx,1024
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,65535
	mov	UdragMiniValue,10
	lea	eax,RealVaren
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,RealUdrag
	mov	UdragMeanWhile,eax
	call	ButtonHandler

	popad
	ret
RealUdrag:
	pushad
	mov	esi,[alloctable+1051*8]
	mov	ebx,2
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	mov	eax,RealVaren
	mov	word ptr [esi+5],ax
	call	PutRealPitch

	popad
	ret

RealPitchInput: 			;RealPitchInput ----------------
	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	mov	ebx,2
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	movzx	eax,word ptr [esi+5]
	mov	RealVaren,eax

	move	edi,0a0000h+424/8+419*80
	mov	ax,0111h
	lea	ebp,RealVaren
	mov	ecx,5
	mov	ebx,10
	mov	edx,65535
	lea	esi,RealUdrag
	mov	digitsize,3
	call	ZyricInput
	popad
	ret

;******************************************************************************
;				 Time Compress
;******************************************************************************
NoTimeCompress: 			;No time compress
	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	mov	ebx,0
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	mov	byte ptr [esi+5],0
	call	ShowTimeCompressen

	popad
	ret
C_4TimeCompress:			;C-4 Time Compress
	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	mov	ebx,0
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	mov	byte ptr [esi+5],1
	call	ShowTimeCompressen

	popad
	ret
FixedTimeCompress:			;Fixed Time Compress
	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	mov	ebx,0
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	mov	byte ptr [esi+5],2
	call	ShowTimeCompressen

	popad
	ret

ShowTimeCompressen:			;Show Time Compressen
	pushad
	cmp	EffectEnvelopeSelect,3
	jnz	_retp

	call	mouseoff
	mov	esi,[alloctable+1051*8]
	mov	ebx,0
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	mov	al,[esi+5]

	mov	buttonX1,75
	mov	buttonY1,377
	mov	buttonX2,85
	mov	buttonY2,388
	mov	bl,1
	cmp	al,0
	jnz	bora1_
	xor	bl,1
bora1_:
	call	buttonupdown
	mov	buttonX1,75
	mov	buttonY1,390
	mov	buttonX2,85
	mov	buttonY2,401
	mov	bl,1
	cmp	al,1
	jnz	bora2_
	xor	bl,1
bora2_:
	call	buttonupdown
	mov	buttonX1,75
	mov	buttonY1,403
	mov	buttonX2,85
	mov	buttonY2,413
	mov	bl,1
	cmp	al,2
	jnz	bora3_
	xor	bl,1
bora3_:
	call	buttonupdown

	call	mouseon
	popad
	ret
PutTimeCompressRead:			;Put time compress read -----------
	pushad
	cmp	EffectEnvelopeSelect,3
	jnz	_retp

	call	mouseoff
	mov	esi,[alloctable+1051*8]
	mov	ebx,0
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	movzx	ebx,word ptr [esi+6]
	mov	ah,1
	mov	cl,5
	move	edi,0a0000h+200/8+420*80
	mov	fontplane,1
	call	PutDecimal
	mov	FontPlane,0
	call	mouseon
	call	mousereset
	call	mouseon

	popad
	ret
PutTimeCompressSkip:			;Put time compress skip -----------
	pushad
	cmp	EffectEnvelopeSelect,3
	jnz	_retp

	call	mouseoff
	mov	esi,[alloctable+1051*8]
	mov	ebx,0
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	movzx	ebx,word ptr [esi+8]
	mov	ah,1
	mov	cl,5
	move	edi,0a0000h+200/8+438*80
	mov	fontplane,1
	call	PutDecimal
	mov	FontPlane,0
	call	mouseon
	call	mousereset
	call	mouseon

	popad
	ret
SampsToReadArrowUp:			;SampsToReadArrowUp ----------------
	pushad
	call	fixbutton
	call	CheckIfNowFastPreview

	mov	esi,[alloctable+1051*8]
	mov	ebx,0
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	cmp	word ptr [esi+6],65535
	jz	_retp
	inc	word ptr [esi+6]
	call	PutTimeCompressRead

	popad
	ret
SampsToReadArrowDown:			;SampsToReadArrowDown ----------------
	pushad
	call	fixbutton
	call	CheckIfNowFastPreview

	mov	esi,[alloctable+1051*8]
	mov	ebx,0
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	cmp	word ptr [esi+6],1
	jz	_retp
	dec	word ptr [esi+6]
	call	PutTimeCompressRead

	popad
	ret
TimeVaren	dd	0
SampsToReadUdrag:			;SampsToReadUdrag ----------------
	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	mov	ebx,0
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	movzx	eax,word ptr [esi+6]
	mov	TimeVaren,eax

	mov	UdragStatus,1   		;udrag size
	mov	eax,2000
	mov	ebx,1024
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,65535
	mov	UdragMiniValue,1
	lea	eax,TimeVaren
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,TimeUdragRead
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret
TimeUdragRead:
	pushad
	mov	esi,[alloctable+1051*8]
	mov	ebx,0
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	mov	eax,TimeVaren
	mov	word ptr [esi+6],ax
	call	PutTimeCompressRead
	popad
	ret
SampsToReadInput:			;SampsToReadInput ----------------
	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	mov	ebx,0
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	movzx	eax,word ptr [esi+6]
	mov	TimeVaren,eax

	move	edi,0a0000h+200/8+420*80
	mov	ax,0111h
	lea	ebp,TimeVaren
	mov	ecx,5
	mov	ebx,1
	mov	edx,65535
	lea	esi,TimeUdragRead
	mov	digitsize,3
	call	ZyricInput

	popad
	ret
SampsToSkipArrowUp:			;SampsToSkipArrowUp ----------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton

	mov	esi,[alloctable+1051*8]
	mov	ebx,0
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	cmp	word ptr [esi+8],65535
	jz	_retp
	inc	word ptr [esi+8]
	call	PutTimeCompressSkip

	popad
	ret
SampsToSkipArrowDown:			;SampsToSkipArrowDown ----------------
	pushad
	call	CheckIfNowFastPreview
	call	fixbutton

	mov	esi,[alloctable+1051*8]
	mov	ebx,0
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	cmp	word ptr [esi+8],0
	jz	_retp
	dec	word ptr [esi+8]
	call	PutTimeCompressSkip

	popad
	ret
SampsToSkipUdrag:			;SampsToSkipUdrag ----------------
	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	mov	ebx,0
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	movzx	eax,word ptr [esi+8]
	mov	TimeVaren,eax

	mov	UdragStatus,1   		;udrag size
	mov	eax,2000
	mov	ebx,1024
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,65535
	mov	UdragMiniValue,0
	lea	eax,TimeVaren
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,TimeUdragSkip
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret
TimeUdragSkip:
	pushad
	mov	esi,[alloctable+1051*8]
	mov	ebx,0
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	mov	eax,TimeVaren
	mov	word ptr [esi+8],ax
	call	PutTimeCompressSkip
	popad
	ret

	popad
	ret
SampsToSkipInput:			;SampsToSkipInput ----------------
	pushad
	call	CheckIfNowFastPreview
	mov	esi,[alloctable+1051*8]
	mov	ebx,0
	mov	eax,VoiceEnvNumber
	call	ScanEffect
	movzx	eax,word ptr [esi+8]
	mov	TimeVaren,eax

	move	edi,0a0000h+200/8+438*80
	mov	ax,0111h
	lea	ebp,TimeVaren
	mov	ecx,5
	mov	ebx,0
	mov	edx,65535
	lea	esi,TimeUdragSkip
	mov	digitsize,3
	call	ZyricInput
	popad
	ret

;******************************************************************************
;				 COMMAND PART
;******************************************************************************

SavePosen	dd	0
SavePosen2	dd	0
EffectCancel2:
	pushad
	jmp	OjHoppa
EffectCancel:				;Effect cancel ----------------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
OjHoppa:
	mov	OldPosMulti,-1
	mov	OldPosList,-1
	mov	OldPosSingle,-1
	call	PutZoomDataEnv
	call	CheckIfNowFastPreview
	lea	esi,EffectChoosePicture
	mov	DrawSpecial,2
	call	DrawPopUp
	mov	word ptr [currentmenu],29
	mov	menu_popup,29
	call	StopSpeech
	call	InitEffects
	call	ShowMultiEffect
	call	ShowSingleEffect
	call	ShowListEffect
	popad
	ret

EffectOkay:				;Effect okay ------------------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	call	PutZoomDataEnv

	call	CheckIfNowFastPreview
	mov	OldPosMulti,-1
	mov	OldPosSingle,-1
	mov	OldPosList,-1

	;lea	 esi,NowText		;check popup
	;mov	 SpecialSecondPopup,1
	;mov	 SecondPopup,37
	;mov	 SpecialTextOffset,205*80+14
	;call	 popuphandler
	;mov	 SpecialTextOffset,0
	;mov	 SpecialSecondPopup,0
	;popad
	;ret


	call	StopSpeech

	cmp	StartEffectMode,1
	jz	DoEditStart
DoNewStart:					;save new
	lea	esi,EffectChoosePicture
	mov	DrawSpecial,2
	call	DrawPopUp
	mov	word ptr [currentmenu],29
	mov	menu_popup,29

	mov	eax,[alloctable+1047*8]
	cmp	word ptr [eax+4],65535
	jz	okayend

	mov	ebp,1047
	mov	esi,EffectPosStart
	mov	eax,[alloctable+1047*8]
	movzx	eax,word ptr [eax+4]
	shl	eax,5
	add	esi,eax
	mov	ecx,32
	call	ChangeOffsetsIns2
	call	MakeAllocSpace
	mov	edi,esi

	add	edi,[alloctable+1047*8]

	lea	esi,TheEffectName
	mov	ecx,28
	rep	movsb

	mov	ebp,[alloctable+1047*8+4]
	mov	[edi],ebp
	mov	edx,ebp

	mov	eax,[alloctable+1051*8+4]
	add	eax,[alloctable+1047*8+4]
	xor	ebx,ebx
	mov	ebp,1047
	call	memalloc
	jc	RemoveMemory
	mov	edi,edx
	add	edi,[alloctable+1047*8]
	mov	esi,[alloctable+1051*8]
	mov	ecx,[alloctable+1051*8+4]
	rep	movsb


	mov	eax,[alloctable+1047*8]
	inc	word ptr [eax+4]

	jmp	okayend
DoEditStart:					;save edit
	lea	esi,EffText7		;check popup
	mov	SpecialSecondPopup,1
	mov	SecondPopup,40
	mov	SpecialTextOffset,205*80+14
	call	popuphandler
	mov	SpecialTextOffset,0
	mov	SpecialSecondPopup,0
	movzx	eax,popupstatus
	cmp	eax,1
	jz	DoNewStart
	cmp	eax,3
	jz	_retp

	lea	esi,EffectChoosePicture
	mov	DrawSpecial,2
	call	DrawPopUp
	mov	word ptr [currentmenu],29
	mov	menu_popup,29

	mov	eax,[alloctable+1049*8]
	mov	ebx,CurrentSingle
	mov	edi,[eax+ebx*4]
	add	edi,[alloctable+1047*8]
	lea	esi,TheEffectName
	mov	ecx,28
	rep	movsb

	mov	esi,[edi]
	moV	eax,edi
	sub	eax,[alloctable+1047*8]
	mov	SavePosen,eax
	mov	SavePosen2,esi
	mov	ebp,1047
	mov	ecx,OldEffectSize
	call	ChangeOffsetsDel ;?
	call	DelAllocSpace

	mov	ecx,[alloctable+1051*8+4]
	call	ChangeOffsetsIns3
	call	MakeAllocSpace

	mov	edi,SavePosen
	add	edi,[AllocTable+1047*8]
	mov	eax,SavePosen2
	mov	[edi],eax


	mov	edi,esi
	add	edi,[alloctable+1047*8]
	mov	esi,[alloctable+1051*8]
	mov	ecx,[alloctable+1051*8+4]
	rep	movsb

okayend:

	mov	ebp,1050
	xor	ebx,ebx
	xor	eax,eax
	call	memalloc
	mov	PreviewStatus,5
	mov	PreviewStatusLength,5
	call	InitEffects
	call	ShowMultiEffect
	call	ShowSingleEffect
	call	ShowListEffect
	popad
	ret

EffectApply:				;Effect apply --------------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp


	lea	esi,EffText8		;check popup
	mov	SpecialSecondPopup,1
	mov	SecondPopup,37
	mov	SpecialTextOffset,205*80+14
	call	popuphandler
	mov	SpecialTextOffset,0
	mov	SpecialSecondPopup,0
	movzx	eax,popupstatus
	cmp	eax,0
	jz	_retp

DoVolFade:

;	 call	 CheckSaveEffectsToDisk 	 ;check if save effects to disk


	mov	Menu_popup,0			;remove popup
	call	MenuHandler
	mov	curradd,0
	mov	playpegoff,0
	call	SetSampOffset

	mov	ebp,1050
	mov	eax,0
	call	memalloc
	jc	RemoveMemory
	mov	SpecialSelect,0
	mov	mousecursor,0
	mov	updatemouse,80h



	cmp	SampLength,0
	jz	EndenPrev

	call	EffectWaitStart
	mov	NrOfWaitEffects,1

	pushad
	lea	esi,TheEffectName
	call	EffectWaitWriteName
	popad

	mov	eax,SampLength
	mov	CopyStart,0
	cmp	sampmarkstart,-1                ;cut sample to buffer 1050
	jz	AfterLength_AA
	mov	eax,sampmarkend
	sub	eax,sampmarkstart
	mov	ebx,Sampmarkstart
	mov	copystart,ebx
AfterLength_AA:
	mov	copylength,eax
	shl16	eax
	cmp	eax,0
	jz	EndThisPrev


	;call	 EffectWaitStartAndInit  ;show wait popup
	call	saveundo                ;undo

	mov	ebp,1050
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory
;;
	mov	esi,undobufferoffset            ;move samp
	mov	ecx,CopyStart
	shl16	ecx
	add	esi,ecx
	mov	edi,[alloctable+1050*8]
	mov	ecx,[alloctable+1050*8+4]
	rep	movsb

	mov	ecx,samplength
	mov	CopyTotalLength,ecx

	call	effectscanDC			;DC offset and volume
	call	effectcenter			;do center


	mov	samplength,0
	call	allocsamplength
						;centering

	cmp	SkipWaiten,0
	jz	noglass1
	call	mousehourglass
noglass1:

	;mov	 EffectWaitStatus,0		 ;init waitpop
	;call	 EffectWaitInit
	;mov	 eax,EffectNextSampLength
	;mov	 EffectWait_All,eax



	xor	edi,edi

	mov	ecx,[alloctable+1050*8+4]
	shr16	ecx
	mov	edx,sampbits

	movzx	ebx,CurrentSample
	call	GetSampleRate
	jnc	NoZeroNow__AA
	mov	eax,16768
NoZeroNow__AA:
	mov	ebx,eax
	mov	esi,1050
	mov	eax,1051
	mov	ebp,1037
	;mov	 EffectWaitPlane,0

	call	MultiEffectsEngine

	cmp	WaitStatus,1
	jz 	WaitJump2


	call	effectfixDC				;effect fix DC

							;paste sample
	mov	eax,[alloctable+1050*8+4]		;alloc samplength
	shr16	eax
	add	eax,undosamplength
	sub	eax,CopyLength
	mov	samplength,eax
	call	allocsamplength

	mov	edi,sampmainoffset			;move samp
	mov	esi,undobufferoffset
	mov	ecx,CopyStart
	shl16	ecx
	rep	movsb
	push	esi
	mov	esi,[alloctable+1050*8]
	mov	ecx,[alloctable+1050*8+4]
	rep	movsb
	pop	esi
	mov	ecx,CopyLength
	shl16	ecx
	add	esi,ecx
	mov	ecx,CopyTotalLength
	sub	ecx,CopyLength
	sub	ecx,CopyStart
	shl16	ecx
	rep	movsb

	jmp	nojumpen2
WaitJump2:
	pop	ebp ecx
	mov	eax,undosamplength
	shr16	eax
	mov	samplength,eax
	mov	Viewsamplength,eax
	call	allocsamplength
	mov	esi,undobufferoffset
	mov	edi,sampmainoffset
	mov	ecx,samplength
	shl16	ecx
	rep	movsb
NoJumpen2:



	mov	ebp,1050
	xor	ebx,ebx
	xor	eax,eax
	call	memalloc
	jc	RemoveMemory

	call	EffectWaitEnd

	mov	eax,SampLength
	mov	Viewsamplength,eax
	mov	extrasamplength,0

	mov	SampMarkSTart,-1
	call	clippegs
	mov	viewsampoffset,0
	mov	sampmarkstart,-1
	call	viewsamp
	call	updatesampletogus

	mov	PlayForm,1
	call	UpdateSample

	cmp	SkipWaiten,0
	jz	noglass2
	call	mousearrow
noglass2:

	lea	edi,oldputs
	mov	eax,-1
	mov	ecx,20
	rep	stosd

	mov	SkipWaiten,0

	popad
	ret

EndThisPrev:
	mov	SkipWaiten,0
	mov	ebp,1050
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory

	call	EffectWaitEnd
	popad
	ret
EndenPrev:
	mov	ebp,1050
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory

	mov	SkipWaiten,0
	popad
	ret

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Previewer
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PreviewForm	db	0
LastBeforeUp	dd	0
PreviewStatus	dd	0	;0=Multi 1=Test single 2=Preview edit
PreviewStatusOld dd	0
PreviewStatusLength	dd 0	;0=normal preview 1=allpreview
PreviewStatusLengthOld	dd 0	;0=normal preview 1=allpreview
PreviewSingleEffect:			;Preview Single Effect ----------------
	mov	PreviewForm,0
DOCalculate:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	PreviewStatus,1

DoCalculate2:
	mov     PreviewStatusLength,0
	cmp	LastBeforeUp,2
	jnz	DoPreviewPop2
	mov     PreviewStatusLength,1
DoPreviewPop2:
	cmp	Menu_popup,29
	jnz	NoPreviewStop
	mov	eax,[alloctable+1047*8]
	cmp	word ptr [eax+4],0
	jz	_retp
NoPreviewStop:


	mov	ecx,PreviewStatusLength
	mov	ebx,PreviewStatus
	cmp	ecx,PreviewStatusLengthOld
	jnz	nostatt1
	cmp	ebx,PreviewStatusOld
	jnz	nostatt1
	call	StopSpeech
	cmp	[AllocTable+1050*8+4],0
	jnz	DoFastPreview1
nostatt1:
	call	StopSpeech
	mov	PreviewStatusOld,ebx
	mov	PreviewStatusLengthOld,ecx

	cmp	SampLength,0
	jz	_retp
	cmp	InitInput,0
	jnz	_retp

	call	StopSpeech

	call	EffectWaitStart
	mov	NrOfWaitEffects,1

	cmp 	PreviewForm,0
	jnz	notesten
	pushad
	mov	ebx,CurrentSingle
	mov	eax,[alloctable+1049*8]
	mov	esi,[eax+ebx*4]
	add	esi,[alloctable+1047*8]
	call	EffectWaitWriteName
	popad
	jmp	aftertesten
notesten:
	pushad
	lea	esi,TheEffectName
	call	EffectWaitWriteName
	popad
aftertesten:


	movzx	ebx,CurrentSample
	call	GetSampleRate
	jnc	NoZeroNow__3
	mov	eax,16768
NoZeroNow__3:
	movzx	ebx,PreviewTime
	inc	ebx
	mul	ebx
	shl16	eax

	mov	ebx,samplength
	cmp 	SampMarkStart,-1
	jz	nomarked
	mov	ebx,SampMarkEnd
	sub	ebx,SampMarkStart
	inc	ebx
nomarked:
	shl16	ebx

	cmp	LastBeforeUp,2
	jnz	noalla
	mov	eax,ebx
noalla:
	cmp	eax,ebx
	jbe	noproblemas
	mov	eax,ebx
noproblemas:
	xor	ebx,ebx
	mov	ebp,1050
	call	memalloc
	jc	RemoveMemory

	mov	edi,[alloctable+1050*8]
	mov	esi,[alloctable+1024*8]
	mov	eax,SampMarkSTart
	cmp	eax,-1
	jz	nomarkennow
	shl16	eax
	add	esi,eax
nomarkennow:
	mov	ecx,[alloctable+1050*8+4]
	rep	movsb

	cmp	PreviewForm,1
	jz	noballaur
	mov	eax,CurrentSingle
	mov	ebx,[alloctable+1049*8]
	mov	edi,[ebx+eax*4]
	add	edi,[alloctable+1047*8]
	add	edi,28
	mov	edi,[edi]
noballaur:

	mov	ecx,[alloctable+1050*8+4]
	shr16	ecx
	mov	edx,sampbits

	movzx	ebx,CurrentSample
	call	GetSampleRate
	jnc	NoZeroNow__2
	mov	eax,16768
NoZeroNow__2:
	mov	ebx,eax
	mov	esi,1050
	mov	eax,1047
	mov	ebp,1037

	cmp	PreviewForm,1
	jnz	noeditprev
	xor	edi,edi
	mov	eax,1051
noeditprev:

	call	MultiEffectsEngine

	cmp	WaitStatus,1
	jz	EndSinglePrev
					;convert
	cmp	sampbits,1
	jz	conv16a
	mov	ecx,[alloctable+1050*8+4]
	mov	edi,[alloctable+1050*8]
convloppan1:
	add	byte ptr [edi],128
	inc	edi
	loop	convloppan1
	jmp	after16a
conv16a:
	mov	ecx,[alloctable+1050*8+4]
	mov	edi,[alloctable+1050*8]
	shr	ecx,1
convloppan2:
	add	word ptr [edi],32768
	add	edi,2
	loop	convloppan2
After16a:

	call	EffectWaitEnd

DoPlay:
DoFastPreview1:
	movzx	ebx,CurrentSample
	call	GetSampleRate
	jnc	NoZeroNow__4
	mov	eax,16768
NoZeroNow__4:
	mov	edx,eax
	mov	eax,sampbits
	mov	bl,4*12
	mov	bh,0
	mov	ecx,[alloctable+1050*8+4]
	mov	esi,[alloctable+1050*8]
	call	SpeechEngine


	popad
	ret

PreviewMultiEffect:			;Preview multi effect ---------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp

	mov	PreviewStatus,0
	mov     PreviewStatusLength,0
	cmp	LastBeforeUp,2
	jnz	DoPreviewPop1
	mov     PreviewStatusLength,1

DoPreviewPop1:
	mov	eax,[alloctable+1047*8]
	cmp	word ptr [eax+2],0
	jz	_retp
	cmp	ListTableNumber,0
	jz	_retp

	mov	ecx,PreviewStatusLength
	mov	ebx,PreviewStatus
	cmp	ecx,PreviewStatusLengthOld
	jnz	nostatt2
	cmp	ebx,PreviewStatusOld
	jnz	nostatt2
	call	StopSpeech
	cmp	[AllocTable+1050*8+4],0
	jnz	DoFastPreview2
nostatt2:
	mov	PreviewStatusOld,ebx
	mov	PreviewStatusLengthOld,ecx
	call	StopSpeech



	cmp	SampLength,0
	jz	_retp
	cmp	InitInput,0
	jnz	_retp

	call	StopSpeech

	call	EffectWaitStart

	movzx	ebx,CurrentSample
	call	GetSampleRate
	jnc	NoZeroNow__3AA
	mov	eax,16768
NoZeroNow__3AA:
	movzx	ebx,PreviewTime
	inc	ebx
	mul	ebx
	shl16	eax

	mov	ebx,samplength
	cmp 	SampMarkStart,-1
	jz	nomarkedAA
	mov	ebx,SampMarkEnd
	sub	ebx,SampMarkStart
	inc	ebx
nomarkedAA:
	shl16	ebx

	cmp	LastBeforeUp,2
	jnz	noalla2
	mov	eax,ebx
noalla2:

	cmp	eax,ebx
	jbe	noproblemasAA
	mov	eax,ebx
noproblemasAA:
	xor	ebx,ebx
	mov	ebp,1050
	call	memalloc
	jc	RemoveMemory

	mov	edi,[alloctable+1050*8]
	mov	esi,[alloctable+1024*8]
	mov	eax,SampMarkSTart
	cmp	eax,-1
	jz	nomarkennow2
	shl16	eax
	add	esi,eax
nomarkennow2:
	mov	ecx,[alloctable+1050*8+4]
	rep	movsb

	mov	ecx,ListTableNumber
	mov	NrOfWaitEffects,ecx
	xor	ebp,ebp
EffectLoopenAA: 				  ;effectloop
	push	ecx ebp

	pushad
	movzx	esi,word ptr [ebp+ListTable]
	shl	esi,5
	add	esi,EffectPosStart
	add	esi,[alloctable+1047*8]
	call	EffectWaitWriteName
	popad

	movzx	edi,word ptr [ebp+ListTable]
	shl	edi,5
	add	edi,EffectPosStart
	add	edi,[alloctable+1047*8]
	add	edi,28
	mov	edi,[edi]

	mov	ecx,[alloctable+1050*8+4]
	shr16	ecx
	mov	edx,sampbits

	movzx	ebx,CurrentSample
	call	GetSampleRate
	jnc	NoZeroNow__2AA
	mov	eax,16768
NoZeroNow__2AA:
	mov	ebx,eax
	mov	esi,1050
	mov	eax,1047
	mov	ebp,1037

	cmp	PreviewForm,1
	jnz	noeditprevAA
	xor	edi,edi
	mov	eax,1051
noeditprevAA:

	call	MultiEffectsEngine
	cmp	WaitStatus,1
	jz	endmultiprev


	inc 	CurrentWaitEffect
	pop	ebp ecx
	add	ebp,2
	loop	EffectLoopenAA

					;convert
	cmp	sampbits,1
	jz	conv16aAA
	mov	ecx,[alloctable+1050*8+4]
	mov	edi,[alloctable+1050*8]
convloppan1AA:
	add	byte ptr [edi],128
	inc	edi
	loop	convloppan1AA
	jmp	after16aAA
conv16aAA:
	mov	ecx,[alloctable+1050*8+4]
	mov	edi,[alloctable+1050*8]
	shr	ecx,1
convloppan2AA:
	add	word ptr [edi],32768
	add	edi,2
	loop	convloppan2AA
After16aAA:

	call	EffectWaitEnd

DoFastPreview2:

	movzx	ebx,CurrentSample
	call	GetSampleRate
	jnc	NoZeroNow__4AA
	mov	eax,16768
NoZeroNow__4AA:
	mov	edx,eax
	mov	eax,sampbits
	mov	bl,4*12
	mov	bh,0
	mov	ecx,[alloctable+1050*8+4]
	mov	esi,[alloctable+1050*8]
	call	SpeechEngine



	popad
	ret
EndMultiPrev:
	pop	ebp ecx
EndSinglePrev:
	mov	ebp,1050
	xor	eax,eax
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory

	popad
	ret

PreviewEditEffect:			;Preview edit effect ---------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	PreviewForm,1
	mov	PreviewStatus,3
	jmp	DOCalculate2
LastKeyPress	db	-1
checkpreviewkeys:			;Check Preview keys ----------------
	ret ;Removed since in al,60h bugs out on certain machines...
	pushad
	cmp	MouseB,0
	jnz	_retp
	in	al,60h
	cmp	LastKeyPress,al
	jz	_retp
	mov	LastKeyPress,al
	cmp	al,20
	jnz	noTest
	cmp	Menu_popup,29
	jnz	notest
	mov	PreviewForm,0
	mov	LastBeforeUp,1
	mov	PreviewStatus,1
	mov	PreviewStatusLength,0
	jmp	DoPreviewPop2
noTest:
	cmp	al,25
	jnz	noPreview
	cmp	Menu_popup,29
	jnz	nopreviewpop1
	mov	LastBeforeUp,1
	mov	PreviewStatus,0
	mov	PreviewStatusLength,0
	jmp	DoPreviewPop1
nopreviewpop1:
	cmp	Menu_popup,39
	jz	dojan
	cmp	Menu_popup,41
	jnz	NoPreviewPop2
dojan:
	mov	PreviewForm,1
	mov	LastBeforeUp,1
	mov	PreviewStatus,2
	mov	PreviewStatusLength,0
	jmp	DoPreviewPop2
nopreviewpop2:
nopreview:
	popad
	ret
CheckIfNowFastPreview:			;Check If no fast preview ---------
	pushad

	mov	ebp,1050
	mov	eax,0
	call	memalloc
	jc	RemoveMemory

	popad
	ret



;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Volume Fade
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

VolFadeData1	Label	Word	;----------------------- Vol Fade Data 1
	dw	1
	db	0
	dd	10000
	db	0
	dw	11
	db	3
	dw	0

	db	0,0,0
	dw      0
	db	0
	dw	1024,1024

	dd	0
	db	0
	dw	0,0,1
		dd	0
		dd	0
		db	3

	dd	0
	db	0
	dw	1024
	db	0
	dw	0,0,1
		dd	0
		dd	0
		db	3

	dd	0
	db	0
	dw	0,0,2
		dd	0
		dd	10000
		db	0
		dd	10000000
		dd	0
		db	3
EndFade1:
VolFadeData2	Label	Word	;----------------------- Vol Fade Data 2
	dw	1
	db	0
	dd	10000
	db	0
	dw	11
	db	3
	dw	0

	db	0,0,0
	dw      0
	db	0
	dw	1024,1024

	dd	0
	db	0
	dw	0,0,1
		dd	0
		dd	0
		db	3

	dd	0
	db	0
	dw	1024
	db	0
	dw	0,0,1
		dd	0
		dd	0
		db	3

	dd	0
	db	0
	dw	0,0,2
		dd	0
		dd	0
		db	0
		dd	10000000
		dd	10000
		db	3
EndFade2:
VolFadeData3	Label	Word	;----------------------- Vol Fade Data 3
	dw	1
	db	0
	dd	10000
	db	0
	dw	11
	db	3
	dw	0

	db	0,0,0
	dw      0
	db	0
	dw	1024,1024

	dd	0
	db	0
	dw	0,0,1
		dd	0
		dd	0
		db	3

	dd	0
	db	0
	dw	1024
	db	0
	dw	0,0,1
		dd	0
		dd	0
		db	3

	dd	0
	db	0
	dw	0,0,2
		dd	0
		dd	10000
		db	2
		dd	10000000
		dd	0
		db	3
EndFade3:
VolFadeData4	Label	Word	;----------------------- Vol Fade Data 4
	dw	1
	db	0
	dd	10000
	db	0
	dw	11
	db	3
	dw	0

	db	0,0,0
	dw      0
	db	0
	dw	1024,1024

	dd	0
	db	0
	dw	0,0,1
		dd	0
		dd	0
		db	3

	dd	0
	db	0
	dw	1024
	db	0
	dw	0,0,1
		dd	0
		dd	0
		db	3

	dd	0
	db	0
	dw	0,0,2
		dd	0
		dd	0
		db	1
		dd	10000000
		dd	10000
		db	3
EndFade4:
VolFadeData5	Label	Word	;----------------------- Vol Fade Data 5
	dw	1
	db	0
	dd	10000
	db	0
	dw	11
	db	3
	dw	0

	db	0,0,0
	dw      0
	db	0
	dw	1024,1024

	dd	0
	db	0
	dw	0,0,1
		dd	0
		dd	0
		db	3

	dd	0
	db	0
	dw	1024
	db	0
	dw	0,0,1
		dd	0
		dd	0
		db	3

	dd	0
	db	0
	dw	0,0,2
		dd	0
		dd	10000
		db	1
		dd	10000000
		dd	0
		db	3
EndFade5:
VolFadeData6	Label	Word	;----------------------- Vol Fade Data 6
	dw	1
	db	0
	dd	10000
	db	0
	dw	11
	db	3
	dw	0

	db	0,0,0
	dw      0
	db	0
	dw	1024,1024

	dd	0
	db	0
	dw	0,0,1
		dd	0
		dd	0
		db	3

	dd	0
	db	0
	dw	1024
	db	0
	dw	0,0,1
		dd	0
		dd	0
		db	3

	dd	0
	db	0
	dw	0,0,2
		dd	0
		dd	0
		db	2
		dd	10000000
		dd	10000
		db	3
EndFade6:


VolFade1:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp

	mov	ebp,1051
	lea	eax,EndFade1
	lea	ebx,VolFadeData1
	sub	eax,ebx
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory
	mov	edi,eax
	lea	esi,VolFadeData1
	lea	ecx,EndFade1
	sub	ecx,esi
	rep	movsb
	mov	SkipWaiten,1
	jmp	DoVolFade

VoLFade2:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp

	mov	ebp,1051
	lea	eax,EndFade2
	lea	ebx,VolFadeData2
	sub	eax,ebx
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory
	mov	edi,eax
	lea	esi,VolFadeData2
	lea	ecx,EndFade2
	sub	ecx,esi
	rep	movsb
	mov	SkipWaiten,1
	jmp	DoVolFade
VoLFade3:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp

	mov	ebp,1051
	lea	eax,EndFade3
	lea	ebx,VolFadeData3
	sub	eax,ebx
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory
	mov	edi,eax
	lea	esi,VolFadeData3
	lea	ecx,EndFade3
	sub	ecx,esi
	rep	movsb
	mov	SkipWaiten,1
	jmp	DoVolFade
VoLFade4:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp

	mov	ebp,1051
	lea	eax,EndFade4
	lea	ebx,VolFadeData4
	sub	eax,ebx
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory
	mov	edi,eax
	lea	esi,VolFadeData4
	lea	ecx,EndFade4
	sub	ecx,esi
	rep	movsb
	mov	SkipWaiten,1
	jmp	DoVolFade
VoLFade5:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp

	mov	ebp,1051
	lea	eax,EndFade5
	lea	ebx,VolFadeData5
	sub	eax,ebx
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory
	mov	edi,eax
	lea	esi,VolFadeData5
	lea	ecx,EndFade5
	sub	ecx,esi
	rep	movsb
	mov	SkipWaiten,1
	jmp	DoVolFade
VoLFade6:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp

	mov	ebp,1051
	lea	eax,EndFade6
	lea	ebx,VolFadeData6
	sub	eax,ebx
	xor	ebx,ebx
	call	memalloc
	jc	RemoveMemory
	mov	edi,eax
	lea	esi,VolFadeData6
	lea	ecx,EndFade6
	sub	ecx,esi
	rep	movsb
	mov	SkipWaiten,1
	jmp	DoVolFade


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			        Effect Wait
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

PopupType		db	0	;0=First,1=Second
NrOfWaitEffects 	dd	0	;-1=
CurrentWaitLine		dd	0
CurrentWaitEffect	dd	0
SkipWaiten		db	0	;0=Do it 1=skip it

WaitStatus		db	0	;0=working 1=canceling
;EffectSampCount
;EffectSampLength

EffectWaitStart:			;Effect wait start ----------------
	pushad
	cmp	SkipWaiten,1
	jz	_retp
	mov	CurrentWaitEffect,0
	mov	CurrentWaitLine,0
	mov	WaitStatus,0
	cmp	Menu_popup,0
	jnz	DOSecondPopup
DoFirstPopup:
	mov	PopUpType,0
	mov	Menu_popup,35
	call	MenuHandler
	popad
	ret
DoSecondPopup:
	mov	PopUpType,1
	mov     SecondPopup,35
	call	MenuHandler

	popad
	ret


EffectWaitUpdate:			;Effect Wait Update --------------
	pushad
	cmp	SkipWaiten,1
	jz	_retp
	mov	ax,MasterFrequency
	cmp	ax,OldMasterFrequency
	jz	_retp
	mov	OldMasterFrequency,ax
	cmp	WaitStatus,1
	jz	_retp

	call	MouseStat
	call	UpdateDifferentStuff	;Updates DragBars and diff. Digits
	call	KeyBoardHandler 	;Handles all keystrokes
	call	MouseHandler		;Handles all MouseMovements

	cmp	WaitStatus,1
	jz	_retp
	mov	eax,EffectSampCount
	mov	ebx,392
	mul	ebx
	mov	ebx,EffectSampLength
	div	ebx
	cmp	eax,392
	jbe	nognuar
	mov	eax,392
nognuar:
	mov	ebx,NrOfWaitEffects
	xor	edx,edx
	div	ebx
	mov	ecx,eax
	mov	eax,392
	mov	ebx,CurrentWaitEffect
	mul	ebx
	mov	ebx,NrOfWaitEffects
	div	ebx
	add	eax,ecx

	cmp	eax,CurrentWaitLine
	jbe	_retp
	mov	CurrentWaitLine,eax

	call	mouseoff
	move	edi,0a0000h+120/8+260*80
	planewrite 00001111b
	mov	ebx,8
	xor	edx,edx
	div	ebx
	mov	ecx,eax
	jecxz	NoFill
FillAllLoop:
	push	edi ecx
	mov	ecx,29
Filly:
	mov	byte ptr [edi],0ffh
	add	edi,80
	loop	Filly
	pop	ecx edi
	inc	edi
	loop	FillAllLoop
NoFill:

	mov	ax,-1
	mov	ecx,edx
	jecxz	NoFill2
	shl	ax,cl
	shr	ax,cl
	shr	ax,8
	xor	al,-1
	mov	ecx,29
Filly2:
	mov	byte ptr [edi],al
	add	edi,80
	loop	Filly2
NoFill2:
	call	mouseon

	popad
	ret
EffectWaitWriteName:			;Effect Wait Write Name ----------
;esi=offset to name
	pushad
	cmp	SkipWaiten,1
	jz	_retp
	call	mouseoff
	movzx	eax,Popuptype
	inc	eax
	mov	fontplane,eax
	move	edi,0a0000h+216/8+303*80
	mov	ecx,28
WriteLoopen:
	movzx	ebx,byte ptr [esi]
	mov	ah,8
	call	putcharacter
	inc	edi
	inc	esi
	loop	WriteLoopen
	mov	fontplane,0
	call	mouseon
	popad
	ret
EffectWaitCancel2:
	pushad
	jmp	skipmousen

EffectWaitCancel:			;Effect Wait Cancel ----------------
	pushad
	cmp	SkipWaiten,1
	jz	_retp
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
SkipMousen:
	mov	WaitStatus,1

	jmp	DoEnden
EffectWaitEnd:				;Effect Wait end ---------------
	pushad
	cmp	SkipWaiten,1
	jz	_retp
	cmp	WaitStatus,1
	jz	_retp
Doenden:
	cmp	PopupType,1
	jz	DoSecondPopup2
	mov	Menu_popup,0
	call	MenuHandler
	popad
	ret
DoSecondPopup2:
	mov	SecondPopup,-1
	call	MenuHandler
	popad
	ret
RemoveMemory:				;Remove memory -----------------
RemoveMemory_16_:
	xor	eax,eax
	xor	ebx,ebx
	mov	ebp,1046
	call	memalloc
	xor	eax,eax
	xor	ebx,ebx
	mov	ebp,1047
	call	memalloc
	xor	eax,eax
	xor	ebx,ebx
	mov	ebp,1048
	call	memalloc
	xor	eax,eax
	xor	ebx,ebx
	mov	ebp,1049
	call	memalloc
	xor	eax,eax
	xor	ebx,ebx
	mov	ebp,1050
	call	memalloc
	xor	eax,eax
	xor	ebx,ebx
	mov	ebp,1051
	call	memalloc
	xor	eax,eax
	xor	ebx,ebx
	mov	ebp,1052
	call	memalloc
	jmp	NotEnoughHimem





