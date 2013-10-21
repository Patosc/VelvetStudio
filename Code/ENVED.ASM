;/ABS\00001000010000100001000010000100001000010000100001


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;			     Envelope Editor Start
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
; Calls: None
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
EnvelopeStart2:
	pushad
	jmp	AfterEnvStart
EnvelopeStart	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	EnvEnd

AfterEnvStart:
	mov	Zoom,0
	cmp	menu_downscreen,7
	jz	EnvelopeEnd2

	mov	ebp,1024
	xor	eax,eax
	call	memalloc
	mov	ebp,1025
	xor	eax,eax
	call	memalloc
;CrashCompare:

	mov	menu_downscreen,7
	call	menuhandler
	mov	CurrentVolPoint,0
	mov	CurrentPanPoint,0

	call	UpdateEnvelopeScreen
	mov	OldCurrentSampName,-1
	mov	EditMode,0
	mov	RecMode,0
	call	BackCol
	cmp	AutoPiano,0
	jz	EnvEnd
	mov	PianoScreen,1
	call	UpdateBlockBock
	call	MenuPiano
EnvEnd:
	Popad
	Ret
EnvelopeStart	EndP

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;			       Envelope Ed End
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
; Calls: None
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
EnvelopeEnd3:
	pushad
	jmp	EnvelopeEnd2
EnvelopeEnd	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	EnvEndOfEnd
EnvelopeEnd2:
	call	ShowMainPattern
	cmp	AutoPiano,2
	jnz	EnvEnd
	mov	PianoScreen,0
	call	UpdateBlockBock
	call	MenuPiano
EnvEndOfEnd:
	Popad
	Ret
EnvelopeEnd	EndP

PrintNames	Proc	Near
	cmp	menu_downscreen,7
	jnz	_ret
	pushad
	call	MouseOff
	mov	ah,8
	mov	cl,15
	move	edi,0a0000h+(224*80)+5
	lea	esi,VolEnvText
	call	PrintText

	mov	cl,16
	move	edi,0a0000h+((224+127)*80)+5
	lea	esi,PanEnvText
	cmp	PanOrVib,0
	jz	ItsThePan
	lea	esi,VibEnvText
ItsThePan:
	call	PrintText


	move	edi,0a0000h+(224*80)+5
	mov	bl,not 4
	call	SetReset

 	mov	ax,0f02h
	mov	dx,3c4h 	;Write mask register
	out	dx,ax

	mov	al,-1
	mov	ecx,15
	rep	stosb

	mov	bl,0
	call	SetReset

	call	MouseOn
	popad
	ret
PrintNames	Endp


UpdateEnvelopeScreen	Proc   near
	call	PrintPianoSplit
	cmp	menu_downscreen,7
	jnz	_ret

	mov	KBD4Request,0
	call	PrintNames
UpdateEnvelopeScreen2:
	mov	[DragBarData+(13*4)*6+4],1
	mov	[DragBarData+(13*4)*7+4],1
	mov	OldPanEnvStartCoord,-1
	mov	OldVolEnvStartCoord,-1

	mov	al,CurrentVolPoint
	mov	CurrentPoint,al
	mov	Envelope,0		;0=Vol,1=Pan
	call	PutEnvelope

	mov	al,CurrentPanPoint
	mov	CurrentPoint,al
	mov	Envelope,1		;0=Vol,1=Pan
	call	PutEnvelope

	call	PrintAllEnvelopeNumbers
	call	mouseoff
	call	SetAllEnvelopeButtons
	mov	ax,CurrentSampName
	cmp	OldCurrentSampName,ax
	jz	Dontupdatesampnames2
	mov	OldCurrentSampName,ax
	call	UpdateSampNames
Dontupdatesampnames2:

	call	PrintShadowNR
	ret
UpdateEnvelopeScreen	EndP

PrintShadowNR	Proc	Near
	cmp	menu_downscreen,7
	jnz	_ret
	pushad

	move	edi,0a0000h+412*80+608/8
	mov	ah,08h

	movzx	ebx,CurrentInstrument
	GetOffset ebx,edx,ENV_Shadow
	movzx	ebx,byte ptr [edx]

	cmp	ebx,0
	jnz	@@AShadow
	mov	ebx,'-'
	call	PutCharacter
	inc	edi
	mov	ebx,'-'
	call	PutCharacter
	inc	edi
	mov	ebx,'-'
	call	PutCharacter
	jmp	@@PutHex1
@@AShadow:
 	mov	cl,3
	cmp	SampHexDec,0
	jz	@@PutDec1
	call	PutHex
	jmp	@@PutHex1
@@PutDec1:
	call	PutDecimal
@@PutHex1:
	call	Mouseon
	popad
	ret
PrintShadowNR	EndP


VolEnvEnable:
	mov	FileEdited,1
	mov	Envelope,0
	movzx	edi,CurrentInstrument
	GetOffset edi,edx,ENV_Flags
	btc	word ptr [edx],2
	rcl	bl,1
	and	bl,1
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,270
	mov	ButtonY1,245
	mov	ButtonX2,284
	mov	ButtonY2,261
	call	ButtonUpDown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	mov	[EnvVolume+edi],7fh
	ret

PanEnvEnable:
	mov	FileEdited,1
	mov	Envelope,1
	movzx	edi,CurrentInstrument
	GetOffset edi,edx,ENV_Flags
	movzx	ecx,PanOrVib
	lea	ecx,[ecx+ecx*2]
	add	ecx,5
	btc	word ptr [edx],cx
	rcl	bl,1
	and	bl,1
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,270
	mov	ButtonY1,245+127
	mov	ButtonX2,284
	mov	ButtonY2,261+127
	call	ButtonUpDown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	mov	[EnvPanPot+edi],80h
	ret

VolEnvLoopOnOff:
	mov	FileEdited,1
	mov	Envelope,0
	movzx   edi,CurrentInstrument
	GetOffset edi,edx,ENV_Flags
	btc	word ptr [edx],0
	rcl	bl,1
	and	bl,1
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,270
	mov	ButtonY1,303
	mov	ButtonX2,284
	mov	ButtonY2,319
	call	ButtonUpDown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	GetOffset edi,edx,ENV_VolEnd
	cmp	byte ptr [edx],0
	jnz	Svett1
	mov	byte ptr [edx],1
	call	PrintLoop
Svett1:
	mov	al,CurrentVolPoint
	mov	CurrentPoint,al
	mov	Envelope,0		;0=Vol,1=Pan
	call	PutEnvelope
	ret

VolEnvBreakLoopOnOff:
	mov	FileEdited,1
	mov	Envelope,0
	movzx	edi,CurrentInstrument
	GetOffset edi,edx,ENV_Flags
	btc	word ptr [edx],9
	rcl	bl,1
	and	bl,1
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,270
	mov	ButtonY1,332
	mov	ButtonX2,284
	mov	ButtonY2,348
	call	ButtonUpDown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	ret


PanEnvLoopOnOff:
	mov	FileEdited,1
	mov	Envelope,1		;0=Vol,1=Pan
	movzx	edi,CurrentInstrument
	GetOffset edi,edx,ENV_Flags
	movzx	ecx,PanOrVib
	lea	ecx,[ecx+ecx*2]
	add	ecx,3
	btc	word ptr [edx],cx
	rcl	bl,1
	and	bl,1
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,270
	mov	ButtonY1,303+127
	mov	ButtonX2,284
	mov	ButtonY2,319+127
	call	ButtonUpDown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	GetOffset edi,edx,ENV_VolEnd
	cmp	byte ptr [edx],0
	jnz	Svett2
	mov	byte ptr [edx],1
	call	PrintLoop
Svett2:
	mov	al,CurrentPanPoint
	mov	CurrentPoint,al
	call	PutEnvelope
	ret

PanEnvBreakLoopOnOff:
	mov	FileEdited,1
	mov	Envelope,1		;0=Vol,1=Pan
	movzx	edi,CurrentInstrument
	GetOffset edi,edx,ENV_Flags
	movzx	ecx,PanOrVib
	add	ecx,0ah
	btc	word ptr [edx],cx
	rcl	bl,1
	and	bl,1
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,270
	mov	ButtonY1,332+127
	mov	ButtonX2,284
	mov	ButtonY2,348+127
	call	ButtonUpDown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	ret


VolEnvLoopStartArrUp:
	mov	Envelope,0
	jmp	LoopStartArrUp
PanEnvLoopStartArrUp:
	mov	Envelope,1
LoopStartArrUp:
	mov	FileEdited,1
	call	FixButton
	movzx	edi,CurrentInstrument
	GetOffset edi,edx,ENV_VolStart
	mov	al,[edx]
	inc	al
	cmp	al,[edx+1]
	jae	_ret
	inc	byte ptr [edx]
	call	PrintLoop
	call	PutEnvelope
	ret

VolEnvLoopStartArrDn:
	mov	Envelope,0
	jmp	LoopStartArrDn
PanEnvLoopStartArrDn:
	mov	Envelope,1
LoopStartArrDn:
	mov	FileEdited,1
	call	FixButton
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_VolStart
	cmp	byte ptr [ebx],0
	jz	_ret
	dec	byte ptr [ebx]
	call	PrintLoop
	call	PutEnvelope
	ret

VolEnvLoopEndArrUp:
	mov	Envelope,0
	jmp	LoopEndArrUp
PanEnvLoopEndArrUp:
	mov	Envelope,1
LoopEndArrUp:
	mov	FileEdited,1
	call	FixButton
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_VolEnd
	GetOffset edi,edx,ENV_NrVolPoints
	mov	al,[ebx]
	cmp	al,[edx]
	jz	_ret
	inc	byte ptr [ebx]
	call	PrintLoop
	call	PutEnvelope
	ret

VolEnvLoopEndArrDn:
	mov	Envelope,0
	jmp	LoopEndArrDn
PanEnvLoopEndArrDn:
	mov	Envelope,1
LoopEndArrDn:
	mov	FileEdited,1
	call	FixButton
	movzx	edi,CurrentInstrument
	GetOffset edi,edx,ENV_VolStart
	mov	al,[edx+1]
	dec	al
	jl	_ret
	cmp	al,[edx]
	jz	_ret
	dec	byte ptr [edx+1]
	call	PrintLoop
	call	PutEnvelope
	ret

VolEnvelopeSpeedUp:
	mov	Envelope,0
	jmp	SpeedUp
PanEnvelopeSpeedUp:
	mov	Envelope,1
SpeedUp:
	mov	FileEdited,1
	call	FixButton
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_VolSpeed
	cmp	byte ptr [ebx],255
	jz	_ret
	inc	byte ptr [ebx]
	call	PrintSpeed
	ret

VolEnvelopeSpeedDn:
	mov	Envelope,0
	jmp	SpeedDn
PanEnvelopeSpeedDn:
	mov	Envelope,1
SpeedDn:
	mov	FileEdited,1
	call	FixButton
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_VolSpeed
	cmp	byte ptr [ebx],0
	jz	_ret
	dec	byte ptr [ebx]
	call	PrintSpeed
	ret

VolEnvCoordTbl	dw	64*4 dup (0),-1
PanEnvCoordTbl	dw	64*4 dup (0),-1
EnvCoordPTR	dd	0
EnvWindowPos	dd	0
EnvShifter	db	0
MaxEnvY 	dd	0
HandleX 	dw	0
HandleY 	dw	0
PutHandle	Proc	Near
	pushad
	movzx	eax,si
	mov	bp,3
	xor	dx,dx
	div	bp
	mov	esi,eax
	xor	ebp,ebp
	cmp	CurrentPoint,al
	jnz	NotTheCurrent
	mov	ebp,1
NotTheCurrent:
	push	eax

	shl	esi,3
	add	esi,EnvCoordPTR

	mov	eax,MaxEnvY
	sub	ax,HandleY
	mov	cl,EnvShifter
	shr	eax,cl
	mov	[esi+2],ax
	mov	[esi+6],ax
	shl	eax,5
	mov	edi,GUS_TempBuffPtr
	add	edi,eax

	movzx	eax,HandleX
	mov	[esi+0],ax
	mov	[esi+4],ax
	mov	ebx,8
	xor	edx,edx
	div	ebx
	add	edi,eax
	mov	bx,7
	sub	bx,dx
	xor	dx,dx
	bts	dx,bx
	shl	dx,8
	mov	ax,dx
	shr	ax,1
	or	dx,ax
	shr	ax,1
	or	dx,ax
	ror	dx,8

FiskAgain:
	push	edi
	or	es:[edi],dx
	add	edi,32
	or	es:[edi],dx
	add	edi,32
	or	es:[edi],dx
	pop	edi
	add	edi,2144
	dec	ebp
	jz	FiskAgain

	mov	eax,EnvWindowPos
	add	word ptr [esi+0],7
	sub	word ptr [esi+2],1
	add	word ptr [esi+2],ax
	add	word ptr [esi+4],11
	add	word ptr [esi+6],3
	add	word ptr [esi+6],ax
	mov	word ptr [esi+8],-1

	pop	edx			;eax
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_Flags
	GetOffset edi,ebp,ENV_VolSustPoint

	movzx	ecx,Envelope
	jecxz	NMo1
	add	cl,PanOrVib
	lea	ecx,[ecx+ecx*2]
NMo1:
	inc	ecx
	mov	ax,[ebx]				;Check Sustain ON
	bt	ax,cx
	jnc	PegNoSustain

	cmp	dl,[ebp]				;Check Sustain Point
	jnz	PegNoSustain
	mov	ecx,2
	call	PutEnvPeg
PegNoSustain:
	mov	ax,[ebx]				;Check Loop ON
	movzx	ecx,Envelope
	jecxz	NMo2
	add	cl,PanOrVib
	lea	ecx,[ecx+ecx*2]
NMo2:
	bt	ax,cx
	jnc	PegNoLoop
	GetOffset edi,ebx,ENV_VolStart

	cmp	dl,[ebx]				;Check Loop Start
	jnz	PegNoStart
	mov	ecx,1
	call	PutEnvPeg
	jmp	PegNoLoop
PegNoStart:
	cmp	dl,[ebx+1]				;Check Loop End
	jnz	PegNoLoop
	mov	ecx,1
	call	PutEnvPeg
PegNoLoop:

	popad
	ret
PutHandle	EndP
;컴컴컴컴컴컴컴컴컴컴컴컴컴�
;Calls ECX=bpls (1 or 2)
;      HandleX=Xcoord
;컴컴컴컴컴컴컴컴컴컴컴컴컴�
PutEnvPeg	Proc	Near
	pushad
	mov	edi,GUS_TempBuffPtr

	movzx	eax,HandleX
	inc	eax
	mov	ebx,8
	xor	edx,edx
	div	ebx
	add	edi,eax
	mov	bx,7
	sub	bx,dx
	xor	dx,dx
	bts	dx,bx

	mov	ebx,ecx
	shr	ebx,1
	shl	ebx,5
	add	edi,ebx

BplPegLoop:
	push	ecx
	push	edi
	mov	ecx,33
LinePegLoop:
	or	[edi],dl
	add	edi,64
	loop	LinePegLoop
	pop	edi
	pop	ecx
	add	edi,2144
	loop	BplPegLoop

	popad
	ret
PutEnvPeg	EndP



Envelope		db	0
EnvStartCoord		dw	0		;1:st coord
VolEnvStartCoord	dw	0		;	 "
PanEnvStartCoord	dw	0		;	 "
OldVolEnvStartCoord	dw	0
OldPanEnvStartCoord	dw	0
PutEnvelope	Proc	Near
	pushad
	movzx	ebx,CurrentInstrument
	cmp	Envelope,1
	jz	PanEnv

	mov	MouseX1,8
	mov	MouseY1,266
	mov	MouseX2,264
	mov	MouseY2,332

	mov	al,CurrentVolPoint
	mov	CurrentPoint,al
	lea	edi,VolEnvCoordTbl
	mov	EnvCoordPTR,edi
	mov	ax,VolEnvStartCoord
	mov	EnvStartCoord,ax
	mov	ecx,64*2
	xor	eax,eax
	rep	stosd
	mov	MaxEnvY,127
	mov	EnvShifter,1
	mov	EnvWindowPos,266
	jmp	ContEnv
PanEnv:
	mov	MouseX1,8
	mov	MouseY1,266+127
	mov	MouseX2,264
	mov	MouseY2,460

	mov	al,CurrentPanPoint
	mov	CurrentPoint,al
	lea	edi,PanEnvCoordTbl
	mov	EnvCoordPTR,edi
	mov	ax,PanEnvStartCoord
	mov	EnvStartCoord,ax
	mov	ecx,64*2
	xor	eax,eax
	rep	stosd
	mov	MaxEnvY,255
	mov	EnvShifter,2
	mov	EnvWindowPos,393
ContEnv:
	GetOffset ebx,ebp,ENV_VolPoints
	GetOffset ebx,eax,ENV_NrVolPoints
	movzx	ecx,byte ptr [eax]

	mov	FirstLine,0
	pushad			;Clear
	mov	edi,GUS_TempBuffPtr
	xor	eax,eax
	mov	ecx,1072
	rep	stosd
	popad

	inc	ecx

	xor	esi,esi
	mov	HandleX,0
	mov	ax,EnvStartCoord
	sub	HandleX,ax
NextPoint:
	movzx	dx,byte ptr [ebp+esi+2]
	mov	HandleY,dx
	mov	dx,[ebp+esi]
	and	dx,511

	cmp	Envelope,0
	jz	NoVibZoom2
	cmp	PanOrVib,0
	jz	NoVibZoom2
	shl	dx,2			;!!!!!!!!!
NoVibZoom2:
	add	HandleX,dx

	mov	dx,word ptr [ebp+esi]
	shr	dx,9
	mov	CurveType,dx

	call	PutCurve
	cmp	HandleX,0
	jl	GotoNext
	cmp	HandleX,252
	ja	GotoNext

	call	PutHandle
GotoNext:
	add	esi,3
	loop	NextPoint

	call	MouseOff
	call	UpdateEnvelopeToScreen
	call	mousereset
	call	MouseOn

	popad
	ret
PutEnvelope	EndP

FirstLine	db	0
OldHandleX	dw	0
OldHandleY	dw	0
PutCurve	Proc	Near
	pushad
	cmp	FirstLine,0
	jz	SkipCurve
	mov	CurveClip1,0		;Start x clip
	mov	CurveClip2,256		;End x clip

	mov	ax,OldHandleX
	mov	CurveX1,ax		;X1

	mov	eax,MaxEnvY
	sub	ax,OldHandleY
	mov	cl,EnvShifter
	shr	eax,cl
	inc	ax
	mov	CurveY1,ax		;Y1

	mov	ax,HandleX
	add	ax,1
	mov	CurveX2,ax		;X2

	mov	eax,MaxEnvY
	sub	ax,HandleY
	mov	cl,EnvShifter
	shr	eax,cl
	inc	ax
	mov	CurveY2,ax		;Y2

	mov	CurveScrWidth,32	;Screen size (Fullscreen = 80)
	mov	eax,GUS_TempBuffPtr
	mov	CurveOffset,eax 	;Offset to put
	call	DrawCurve
SkipCurve:
	mov	FirstLine,1
	mov	ax,HandleX
	mov	OldHandleX,ax
	mov	ax,HandleY
	mov	OldHandleY,ax
	popad
	ret
PutCurve	EndP



UpdateEnvelopeToScreen:
	pushad
	mov	esi,GUS_TempBuffPtr
	mov	eax,EnvWindowPos
	mov	ebx,80
	mul	ebx
	move	edi,0a0000h+1
	add	edi,eax

	mov	ecx,67
EnvRowLoop:
	push	ecx

	mov	ax,0102h
	mov	dx,3c4h 	;Write mask register
	out	dx,ax

	xor	ebp,ebp
	mov	ecx,16
ERL1:
	mov	ax,[esi+ebp]
	mov	[edi+ebp],ax
	add	ebp,2
	loop	ERL1

	mov	ax,0a02h
	mov	dx,3c4h 	;Write mask register
	out	dx,ax

	add	esi,2144
	xor	ebp,ebp
	mov	ecx,16
ERL2:
	mov	ax,[esi+ebp]
	mov	[edi+ebp],ax
	add	ebp,2
	loop	ERL2

	pop	ecx
	add	edi,80
	add	esi,32-2144
	loop	EnvRowLoop
	popad
	ret




PrintShitTable	proc	Near
	pushad
	mov	ecx,5
	move	edi,0a0000h
	mov	ah,0fh
	lea	esi,VolEnvCoordTbl
ffaf:
	push	ecx
	mov	cl,3
	movzx	ebx,word ptr [esi]
	call	PutDecimal
	add	edi,4
	movzx	ebx,word ptr [esi+2]
	call	PutDecimal
	add	edi,4
	movzx	ebx,word ptr [esi+4]
	call	PutDecimal
	add	edi,4
	movzx	ebx,word ptr [esi+6]
	call	PutDecimal
	add	esi,8
	add	edi,80*12-12
	pop	ecx
	loop	ffaf

	popad
	ret
PrintShitTable	endp


EnvYCoord	dw	0
CurrentVolPoint db	0
CurrentPanPoint db	0
CurrentPoint	db	0
VolumeEnvSquare Proc	Near
	pushad
	mov	Envelope,0
	lea	esi,VolEnvCoordTbl
	call	GetPoint
	mov	EnvYCoord,266
	mov	MaxEnvY,127
	mov	EnvShifter,1
	mov	ax,VolEnvStartCoord
	mov	EnvStartCoord,ax
	call	GetEnvOffset
	mov	al,CurrentPoint
	cmp	al,-1
	jnz	Minus1_1
	mov	al,CurrentVolPoint
	mov	CurrentPoint,al
Minus1_1:
	mov	CurrentVolPoint,al
	call	PrintEnv
	call	PrintPoint
	call	PutEnvelope
	popad
	ret
VolumeEnvSquare Endp

PanningEnvSquare Proc	 Near
	pushad
	mov	Envelope,1
	lea	esi,PanEnvCoordTbl
	call	GetPoint
	mov	EnvYCoord,266+127
	mov	MaxEnvY,255
	mov	EnvShifter,2
	mov	ax,PanEnvStartCoord
	mov	EnvStartCoord,ax
	call	GetEnvOffset
	mov	al,CurrentPoint
	cmp	al,-1
	jnz	Minus1_2
	mov	al,CurrentPanPoint
	mov	CurrentPoint,al
Minus1_2:
	mov	CurrentPanPoint,al
	call	PrintEnv
	call	PrintPoint
	call	PutEnvelope
	popad
	ret
PanningEnvSquare Endp

ScrollEnv	dw	0
LastXPoint	dw	0
CurrXPoint	dw	0
NextXPoint	dw	0

ENV_Points	dd	0
ENV_NrPoints	dd	0

MovePoint:
	mov	FileEdited,1
	mov	LeftKeyWait,1
	mov	RightKeyWait,1
	mov	ax,MouseY
	add	ax,EnvMouseY
	dec	ax
	sub	ax,EnvYCoord
	jae	NotEnvBelow
	mov	ax,0
NotEnvBelow:
	cmp	ax,63
	jbe	NotEnvAbove
	mov	ax,63
NotEnvAbove:
	mov	cl,EnvShifter
	shl	ax,cl
	mov	ebx,MaxEnvY
	sub	bx,ax			;BX=New Vol/Pan
	dec	bx

	mov	CurrXPoint,0
	xor	cx,cx
	xor	edi,edi
	mov	ebp,ENV_Points
AddNextPoint:
	mov	dx,[ebp+edi]
	and	dx,511
	add	CurrXPoint,dx
	inc	cx
	add	edi,3
	cmp	cl,CurrentPoint
	jbe	AddNextPoint

	mov	ebp,ENV_NrPoints
	cmp	cl,[ebp]
	jbe	NotLastPoint
	mov	ax,CurrXPoint
	add	ax,512
	mov	NextXPoint,ax
	jmp	LastPoint
NotLastPoint:
	mov	ax,CurrXPoint
	mov	NextXPoint,ax
	mov	ebp,ENV_Points
	mov	dx,[ebp+edi]
	and	dx,511
	dec	dx
	add	NextXPoint,dx
LastPoint:
	cmp	cx,1
	jnz	NotFirstPoint
	mov	LastXPoint,0
	mov	NextXPoint,0
	jmp	FirstPoint
NotFirstPoint:
	mov	ax,CurrXPoint
	mov	LastXPoint,ax
	mov	ebp,ENV_Points
	mov	dx,[ebp+edi-3]
	and	dx,511
	dec	dx
	sub	LastXPoint,dx
FirstPoint:

	mov	ScrollEnv,0
	mov	ax,MouseX
	add	ax,EnvMouseX
	sub	ax,9
	jge	NoShit
;	mov	ScrollEnv,-1
	mov	ax,0
	jmp	NoShit2
NoShit:
;	 cmp	 ax,261-9
;	 jbe	 NoShit2
;	 mov	 ScrollEnv,1
NoShit2:
	add	ax,EnvStartCoord
	cmp	Envelope,0
	jz	NoVibZoom1
	cmp	PanOrVib,0
	jz	NoVibZoom1
	shr	ax,2			;!!!!!!!!!
NoVibZoom1:
	cmp	ax,LastXPoint
	ja	NotAtLastPoint
	mov	ax,LastXPoint
	jmp	GotXPoint
NotAtLastPoint:
	cmp	NextXPoint,0
	jz	OldPop
	cmp	MouseB,2
	jz	GotXPoint
OldPop:
	cmp	ax,NextXPoint
	jb	GotXPoint
	mov	ax,NextXPoint
GotXPoint:

	movzx	edi,CurrentPoint
	lea	edi,[edi+edi*2]

	sub	ax,CurrXPoint

	mov	ebp,ENV_Points
	mov	si,[ebp+edi]
	and	si,511
	mov	dx,si
	mov	cx,[ebp+edi+3]
	and	cx,511
	add	si,cx

	add	dx,ax
	mov	cx,bx
	cmp	dx,511
	jbe	NoChopChop
	mov	dx,511
NoChopChop:
	mov	ebp,ENV_Points
	mov	bx,[ebp+edi]
	and	bx,511
	cmp	bx,dx
	jnz	AlsoY
	mov	ch,[ebp+edi+2]
	cmp	ch,cl
	jz	_ret
AlsoY:
	and	word ptr [ebp+edi],not 511
	or	word ptr [ebp+edi],dx

	mov	[ebp+edi+2],cl

	cmp	MouseB,2
	jz	MauTseTung
	sub	si,dx
	mov	dx,si
	cmp	dx,511
	jbe	NoChopChop2
	mov	dx,511
NoChopChop2:
	and	word ptr [ebp+edi+3],not 511
	or	word ptr [ebp+edi+3],dx
MauTseTung:
	call	PrintEnv
	call	PrintPoint
	call	MoveEnvData
	call	PutEnvelope
	ret

EnvMouseX	dw	0
EnvMouseY	dw	0
GetPoint	Proc	Near
	mov	CurrentPoint,-1
	sub	esi,8
NextMouse2:
	inc	CurrentPoint
	add	esi,8
	mov	ax,[esi]
	cmp	ax,-1
	jz	NoMoreEnvSearch

	cmp	ax,MouseX
	ja	NextMouse2
	add	ax,2
	sub	ax,MouseX
	mov	EnvMouseX,ax

	mov	ax,[esi+2]
	cmp	ax,MouseY
	ja	NextMouse2
	add	ax,2
	sub	ax,MouseY
	mov	EnvMouseY,ax

	mov	ax,[esi+4]
	cmp	ax,MouseX
	jb	NextMouse2

	mov	ax,[esi+6]
	cmp	ax,MouseY
	jb	NextMouse2

	mov	MouseOnDragBar,-2
	mov	LeftKeyWait,1
	ret
NoMoreEnvSearch:
	mov	CurrentPoint,-1
	ret
GetPoint	EndP


ScrollVolEnvelopeLeft:
	pushad
	call	fixbutton
	mov	esi,-4
	jmp	ScrollVolEnvelope

ScrollPanEnvelopeLeft:
	pushad
	call	fixbutton
	mov	esi,-4
	jmp	ScrollPanEnvelope

ScrollVolEnvelopeRight:
	pushad
	call	fixbutton
	mov	esi,4
	jmp	ScrollVolEnvelope

ScrollPanEnvelopeRight:
	pushad
	call	fixbutton
	mov	esi,4
	jmp	ScrollPanEnvelope

ScrollVolEnvelope:
	mov	Envelope,0
	mov	al,CurrentVolPoint
	mov	CurrentPoint,al
	call	GetEnvOffset
	mov	ax,VolEnvStartCoord
	mov	EnvStartCoord,ax
	call	ScrollEnvelope
	movzx	eax,EnvStartCoord
	mov	VolEnvStartCoord,ax
	mov	[DragBarData+(13*4)*6+0],eax
	mov	[DragBarData+(13*4)*6+4],1
	mov	OldVolEnvStartCoord,-1
	call	PutEnvelope
	mov	al,Original+1
	mov	LeftKeyWait,al
	popad
	ret

ScrollPanEnvelope:
	mov	Envelope,1
	mov	al,CurrentPanPoint
	mov	CurrentPoint,al
	call	GetEnvOffset
	mov	ax,PanEnvStartCoord
	mov	EnvStartCoord,ax
	call	ScrollEnvelope
	mov	ax,EnvStartCoord
	mov	PanEnvStartCoord,ax
	mov	[DragBarData+(13*4)*7+0],eax
	mov	[DragBarData+(13*4)*7+4],1
	mov	OldPanEnvStartCoord,-1
	call	PutEnvelope
	mov	al,Original+1
	mov	LeftKeyWait,al
	popad
	ret

ScrollEnvelope	Proc	Near
	xor	ax,ax
	xor	cx,cx
	xor	edi,edi
AddNextPoint2:
	mov	ebp,ENV_Points
	mov	dx,[ebp+edi]
	and	dx,511
	cmp	Envelope,0
	jz	NoVibZoom3
	cmp	PanOrVib,0
	jz	NoVibZoom3
	shl	dx,2			;!!!!!!!!!
NoVibZoom3:
	add	ax,dx
	inc	cx
	add	edi,3
	mov	ebp,ENV_NrPoints
	cmp	cl,[ebp]
	jbe	AddNextPoint2
	cmp	ScrollEnv,0
	jz	NoSpecCheck
	mov	ax,CurrXPoint
	sub	ax,252
	mov	ScrollEnv,0
NoSpecCheck:
	add	EnvStartCoord,si
	jg	CheckOver
	mov	EnvStartCoord,0
CheckOver:
	cmp	EnvStartCoord,ax
	jb	_ret
	mov	EnvStartCoord,ax
	ret
ScrollEnvelope	EndP

PrintAllEnvelopeNumbers Proc	Near
	cmp	menu_downscreen,7
	jnz	_ret
	pushad
	mov	Envelope,0
	mov	ecx,2
agaim:	push	ecx
	call	PrintEnv
	call	PrintLoop
	call	PrintSpeed
	call	PrintPoints
	call	PrintSustain
	call	PrintPoint
	inc	Envelope
	pop	ecx
	loop	agaim

	call	PrintRelNote
	call	PrintFadeOut
	call	PrintVibAmp
;	call	PrintVibSweep
	popad
	ret
PrintAllEnvelopeNumbers EndP

SetAllEnvelopeButtons	Proc	Near
	pushad
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	movzx	edi,CurrentInstrument			;VolEnvelope On/Off

	GetOffset edi,edx,ENV_Flags			;Volume
	bt	word ptr [edx],0
	setnc	bl
	mov	ButtonX1,270				;Loop
	mov	ButtonY1,303
	mov	ButtonX2,284
	mov	ButtonY2,319
	call	ButtonUpDown

	bt	word ptr [edx],1
	setnc	bl
	mov	ButtonX1,270
	mov	ButtonY1,274
	mov	ButtonX2,284
	mov	ButtonY2,290
	call	ButtonUpDown

	bt	word ptr [edx],2
	setnc	bl
	mov	ButtonX1,270
	mov	ButtonY1,245
	mov	ButtonX2,284
	mov	ButtonY2,261
	call	ButtonUpDown

	bt	word ptr [edx],9
	setnc	bl
	mov	ButtonX1,270
	mov	ButtonY1,332
	mov	ButtonX2,284
	mov	ButtonY2,348
	call	ButtonUpDown


	movzx	ecx,PanOrVib				;Pan/Vib
	lea	ecx,[ecx+ecx*2]
	add	ecx,3
	bt	word ptr [edx],cx			;Loop
	setnc	bl
	mov	ButtonX1,270
	mov	ButtonY1,303+127
	mov	ButtonX2,284
	mov	ButtonY2,319+127
	call	ButtonUpDown

	inc	cx
	bt	word ptr [edx],cx			;sust
	setnc	bl
	mov	ButtonX1,270
	mov	ButtonY1,274+127
	mov	ButtonX2,284
	mov	ButtonY2,290+127
	call	ButtonUpDown

	inc	cx
	bt	word ptr [edx],cx			;Env on
	setnc	bl
	mov	ButtonX1,270
	mov	ButtonY1,245+127
	mov	ButtonX2,284
	mov	ButtonY2,261+127
	call	ButtonUpDown

	movzx	ecx,PanOrVib				;Break
	add	ecx,0ah
	bt	word ptr [edx],cx
	setnc	bl
	mov	ButtonX1,270
	mov	ButtonY1,332+127
	mov	ButtonX2,284
	mov	ButtonY2,348+127
	call	ButtonUpDown

	mov	bl,PanOrVib
	xor	bl,1
	mov	ButtonX1,2
	mov	ButtonY1,355
	mov	ButtonX2,30
	mov	ButtonY2,371
	call	ButtonUpDown

	mov	bl,PanOrVib
	mov	ButtonX1,2
	mov	ButtonY1,372
	mov	ButtonX2,30
	mov	ButtonY2,388
	call	ButtonUpDown

	mov	eax,152
	cmp	PanOrVib,1
	jz	Orangutang
	mov	eax,156
Orangutang:
	mov	eax,[PcxOffsets+eax]
	mov	pcxx,343
	mov	pcxy,430
	call	ShowThePcx

	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	popad
	ret
SetAllEnvelopeButtons	EndP


PrintEnv:
	cmp	Envelope,0
	jz	PrintEnvVol
	jmp	PrintEnvPan

PrintEnvVol:
	movzx	edi,CurrentInstrument
	GetOffset edi,eax,ENV_VolPoints
	movzx	esi,CurrentVolPoint
	lea	esi,[esi+esi*2]
	add	eax,esi

	mov	dx,word ptr [eax]
	and	dx,511
	movzx	ebx,byte ptr [eax+2]

	mov	MouseX1,111
	mov	MouseY1,247
	mov	MouseX2,136
	mov	MouseY2,260
	call	MouseOff

	mov	ah,01h
	mov	cl,3
	move	edi,0a0000h+248*80+112/8
	cmp	VolumeHexDec,0
	jz	EnvPutDec6
	call	PutHex
	jmp	EnvPutHex6
EnvPutDec6:
	call	PutDecimal			;Put Volume
EnvPutHex6:
	call	MouseOn

	mov	MouseX1,167
	mov	MouseY1,247
	mov	MouseX2,191
	mov	MouseY2,260
	call	MouseOff

	movzx	ebx,dx
	move	edi,0a0000h+248*80+168/8
	call	PutDecimal			;Put Time
	call	MouseOn
	call	MouseReset
	ret


PrintEnvPan:
	movzx	edi,CurrentInstrument
	GetOffset edi,eax,ENV_VolPoints
	movzx	esi,CurrentPanPoint
	lea	esi,[esi+esi*2]
	add	eax,esi
	mov	dx,word ptr [eax]
	and	dx,511
	movzx	ebx,byte ptr [eax+2]

	mov	MouseX1,47+64
	mov	MouseY1,374
	mov	MouseX2,71+64
	mov	MouseY2,386
	call	MouseOff

	mov	ah,01h
	mov	cl,2
	move	edi,0a0000h+375*80+112/8
	pushad
	mov	edx,ebx
	sub	edx,80h
	mov	ebx,'+'
	jg	EnvPanGreat
	mov	ebx,'-'
	neg	edx
EnvPanGreat:
	cmp	edx,0
	jnz	NoEnvZero
	mov	ebx,' '
NoEnvZero:
	call	PutCharacter
	mov	ebx,edx
	inc	edi
	call	PutHex
	call	MouseOn
	popad

	mov	MouseX1,167
	mov	MouseY1,374
	mov	MouseX2,191
	mov	MouseY2,386
	call	MouseOff

	mov	cl,3
	movzx	ebx,dx
	move	edi,0a0000h+375*80+168/8
	call	PutDecimal			;Put Time
	call	MouseOn
	call	MouseReset
	ret


PrintLoop:
	cmp	Envelope,0
	jz	PrintEnvVolLoop
	jmp	PrintEnvPanLoop

PrintEnvVolLoop:
	mov	Envelope,0
	movzx	ebx,CurrentInstrument
	GetOffset ebx,ebx,ENV_VolStart
	movzx	ebx,byte ptr [ebx]

	mov	MouseX1,304
	mov	MouseY1,305
	mov	MouseX2,320
	mov	MouseY2,317
	call	MouseOff
	mov	ah,01h
	mov	cl,2
	move	edi,0a0000h+306*80+304/8
	call	PutDecimal
	call	MouseOn
	mov	MouseX1,304
	mov	MouseY1,333
	mov	MouseX2,320
	mov	MouseY2,345
	move	edi,0a0000h+335*80+304/8
	jmp	PEL

PrintEnvPanLoop:
	mov	Envelope,1
	movzx	ebx,CurrentInstrument
	GetOffset ebx,ebx,ENV_VolStart
	movzx	ebx,byte ptr [ebx]

	mov	MouseX1,304
	mov	MouseY1,305+127
	mov	MouseX2,320
	mov	MouseY2,317+127
	call	MouseOff
	mov	ah,01h
	mov	cl,2
	move	edi,0a0000h+(306+127)*80+304/8
	call	PutDecimal
	call	MouseOn
	mov	MouseX1,304
	mov	MouseY1,333+128
	mov	MouseX2,320
	mov	MouseY2,345+128
	move	edi,0a0000h+(334+128)*80+304/8
PEL:
	movzx	ebx,CurrentInstrument
	GetOffset ebx,ebx,ENV_VolEnd
	movzx	ebx,byte ptr [ebx]
	call	MouseOff
	mov	ah,01h
	mov	cl,2
	call	PutDecimal
	call	MouseOn
	call	MouseReset
	ret

IncRelNote:
	call	fixbutton
	movzx	esi,CurrentSample
	movsx	eax,[Relativenote+esi]
	inc	eax
	jl	IncRNOk
	cmp	eax,71
	ja	_ret
IncRNOk:
	mov	FileEdited,1
	mov	[Relativenote+esi],al
	call	PrintRelNote
	ret

DecRelNote:
	call	fixbutton
	movzx	esi,CurrentSample
	movsx	eax,[Relativenote+esi]
	dec	eax
	jg	DecRNOk
	cmp	eax,-48
	jl	_ret
DecRNOk:
	mov	FileEdited,1
	mov	[Relativenote+esi],al
	call	PrintRelNote
	ret

PrintRelNote:
	cmp	Menu_DownScreen,7
	jnz	_ret
	mov	MouseX1,568
	mov	MouseY1,360
	mov	MouseX2,568+3*8
	mov	MouseY2,360+13
	call	MouseOff

	movzx	esi,CurrentSample
	movsx	esi,[Relativenote+esi]
	add	esi,50
	move	edi,0a0000h+359*80+568/8
	mov	BitPlane,1
	call	PrintPeriod
	call	MouseOn
	call	MouseReset
	ret

BPMtext db	'BPM'
PrintSpeed:
	cmp	Envelope,0
	jz	PrintEnvVolSpeed
	jmp	PrintEnvPanSpeed

PrintEnvVolSpeed:
	mov	Envelope,0
	move	edi,0a0000h+248*80+48/8
	mov	MouseX1,47
	mov	MouseY1,247
	mov	MouseX2,71
	mov	MouseY2,259
	jmp	PES

PrintEnvPanSpeed:
	mov	Envelope,1
	move	edi,0a0000h+(248+127)*80+48/8
	mov	MouseX1,47
	mov	MouseY1,247+127
	mov	MouseX2,71
	mov	MouseY2,259+127
PES:
	mov	ah,01h
	mov	cl,3
	call	MouseOff
	movzx	ebx,CurrentInstrument
	GetOffset ebx,ebx,ENV_VolSpeed
	movzx	ebx,byte ptr [ebx]
	cmp	ebx,0
	jnz	PrintOrdPan
	lea	esi,BPMText
	call	PrintText
	call	MouseOn
	call	MouseReset
	ret
PrintOrdPan:
	call	PutDecimal
	call	MouseOn
	call	MouseReset
	ret

PrintPoints:
	cmp	Envelope,0
	jz	PrintEnvVolPoints
	jmp	PrintEnvPanPoints

PrintEnvVolPoints:
	mov	MouseX1,303
	mov	MouseY1,247
	mov	MouseX2,319
	mov	MouseY2,259
	move	edi,0a0000h+248*80+304/8
	jmp	PPP

PrintEnvPanPoints:
	mov	MouseX1,303
	mov	MouseY1,247+127
	mov	MouseX2,319
	mov	MouseY2,259+127
	move	edi,0a0000h+(248+127)*80+304/8
PPP:
	call	MouseOff
	movzx	ebx,CurrentInstrument
	GetOffset ebx,ebx,ENV_NrVolPoints
	movzx	ebx,byte ptr [ebx]
	inc	ebx
	mov	ah,01h
	mov	cl,2
	call	PutDecimal
	call	MouseOn
	call	MouseReset
	ret

PrintPoint:
	cmp	Envelope,0
	jz	PrintEnvVolPoint
	jmp	PrintEnvPanPoint

PrintEnvVolPoint:
	mov	MouseX1,231
	mov	MouseY1,247
	mov	MouseX2,255
	mov	MouseY2,259
	movzx	ebx,CurrentVolPoint
	move	edi,0a0000h+248*80+232/8
	jmp	PVP

PrintEnvPanPoint:
	mov	MouseX1,231
	mov	MouseY1,247+127
	mov	MouseX2,255
	mov	MouseY2,259+127
	movzx	ebx,CurrentPanPoint
	move	edi,0a0000h+(248+127)*80+232/8
PVP:
	call	MouseOff
	mov	ah,01h
	mov	cl,2
	call	PutDecimal
	call	MouseOn
	call	MouseReset
	ret

PrintSustain:
	cmp	Envelope,0
	jz	PrintEnvVolSustain
	jmp	PrintEnvPanSustain

PrintEnvVolSustain:
	mov	Envelope,0
	mov	MouseX1,303
	mov	MouseY1,276
	mov	MouseX2,319
	mov	MouseY2,288
	move	edi,0a0000h+277*80+304/8
	jmp	PVS

PrintEnvPanSustain:
	mov	Envelope,1
	mov	MouseX1,303
	mov	MouseY1,276+127
	mov	MouseX2,319
	mov	MouseY2,288+127
	move	edi,0a0000h+(277+127)*80+304/8
PVS:
	call	MouseOff
	movzx	ebx,CurrentInstrument
	GetOffset ebx,ebx,ENV_VolSustPoint
	movzx	ebx,byte ptr [ebx]
	mov	ah,01h
	mov	cl,2
	call	PutDecimal
	call	MouseOn
	call	MouseReset
	ret

PrintFadeOut:
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_VolFade
	mov	bx,word ptr [ebx]
	and	ebx,0fffh

	mov	MouseX1,567
	mov	MouseY1,333+42
	mov	MouseX2,591
	mov	MouseY2,345+42
	call	MouseOff
	mov	ah,01h
	mov	cl,3
	move	edi,0a0000h+(334+42)*80+568/8
	call	PutHex
	call	MouseOn
	call	MouseReset
	ret

comment #
PrintVibSweep:
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_VibSweep
	movzx	ebx,byte ptr [ebx]
	mov	MouseX1,567
	mov	MouseY1,350+42
	mov	MouseX2,591
	mov	MouseY2,382+42
	call	MouseOff
	mov	ah,01h
	mov	cl,2
	move	edi,0a0000h+(351+42)*80+576/8
	call	PutHex
	call	MouseOn
	call	MouseReset
	ret
#

PrintVibSpeed:		;Fix VolFadeInput.
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_VolFade
	mov	ax,[ebx]
	and	ax,00fffh
	or	ax,FadeOutSave
	mov	[ebx],ax
	ret

VolEnvVolArrUp:
	mov	FileEdited,1
	call	fixbutton
	mov	al,CurrentVolPoint
	mov	CurrentPoint,al
	mov	Envelope,0
	movzx	edi,CurrentInstrument
	GetOffset edi,edi,ENV_VolPoints
	movzx	esi,CurrentPoint
	lea	esi,[esi+esi*2]
	add	edi,esi
	mov	bl,[edi+2]
	inc	bl
	cmp	bl,7fh
	jbe	VEVAUOk
	mov	bl,7fh
VEVAUOk:
	mov	[edi+2],bl
	call	PrintEnv
	call	PutEnvelope
	ret

PanEnvPanArrUp:
	mov	FileEdited,1
	call	fixbutton
	mov	al,CurrentPanPoint
	mov	CurrentPoint,al
	mov	Envelope,1
	movzx	edi,CurrentInstrument
	GetOffset edi,edi,ENV_VolPoints
	movzx	esi,CurrentPoint
	lea	esi,[esi+esi*2]
	add	edi,esi
	mov	bl,[edi+2]
	cmp	bl,0ffh
	jz	_ret
	inc	bl
	mov	[edi+2],bl
	call	PrintEnv
	call	PutEnvelope
	ret

VolEnvVolArrDn:
	mov	Envelope,0
	mov	al,CurrentVolPoint
	mov	CurrentPoint,al
	jmp	ArrDn

PanEnvPanArrDn:
	mov	Envelope,1
	mov	al,CurrentPanPoint
	mov	CurrentPoint,al
ArrDn:
	mov	FileEdited,1
	call	fixbutton
	movzx	edi,CurrentInstrument
	GetOffset edi,edi,ENV_VolPoints
	movzx	esi,CurrentPoint
	lea	esi,[esi+esi*2]
	add	edi,esi
	mov	bl,[edi+2]
	cmp	bl,0
	jz	_ret
	dec	bl
	mov	[edi+2],bl
	call	PrintEnv
	call	PutEnvelope
	ret


VolEnvTimeArrUp:
	mov	al,CurrentVolPoint
	mov	CurrentPoint,al
	mov	Envelope,0
	mov	ax,1
	jmp	EnvTimeArr

VolEnvTimeArrDn:
	mov	al,CurrentVolPoint
	mov	CurrentPoint,al
	mov	Envelope,0
	mov	ax,-1
	jmp	EnvTimeArr

PanEnvTimeArrUp:
	mov	al,CurrentPanPoint
	mov	CurrentPoint,al
	mov	Envelope,1
	mov	ax,1
	jmp	EnvTimeArr

PanEnvTimeArrDn:
	mov	al,CurrentPanPoint
	mov	CurrentPoint,al
	mov	Envelope,1
	mov	ax,-1
	jmp	EnvTimeArr


EnvTimeArr:
	mov	FileEdited,1
	call	fixbutton
	movzx	edi,CurrentInstrument
	GetOffset edi,ecx,ENV_NrVolPoints
	movzx	ecx,byte ptr [ecx]
	GetOffset edi,edi,ENV_VolPoints
	movzx	esi,CurrentPoint
	lea	esi,[esi+esi*2]
	add	edi,esi
	mov	dx,word ptr [edi]
	mov	bp,dx
	and	bp,not 511
	and	dx,511
	jz	SkpETA
	mov	bx,dx
	add	dx,ax
	jle	SkpETA
	cmp	dx,511
	ja	SkpETA
	cmp	cl,CurrentPoint
	jz	NotEndETA
	mov	si,word ptr [edi+3]
	and	si,511
	add	bx,si
	cmp	dx,bx
	jae	SkpETA
NotEndETA:
	or	dx,bp
	mov	word ptr [edi],dx

	cmp	cl,CurrentPoint
	jz	SkpETA2

	mov	dx,word ptr [edi+3]
	mov	bp,dx
	and	bp,not 511
	and	dx,511
	sub	dx,ax
	jl	SkpETA
	cmp	dx,511
	ja	SkpETA
	or	dx,bp
	mov	word ptr [edi+3],dx
SkpETA2:
	call	PrintEnv
	call	PutEnvelope
SkpETA:
	ret

VolEnvPointsArrUp:
	mov	Envelope,0
	mov	al,CurrentVolPoint
	mov	CurrentPoint,al
	mov	[DragBarData+(13*4)*6+4],1
	mov	OldVolEnvStartCoord,-1
	jmp	EnvPointsArrUp


PanEnvPointsArrUp:
	mov	Envelope,1
	mov	al,CurrentPanPoint
	mov	CurrentPoint,al
	mov	[DragBarData+(13*4)*7+4],1
	mov	OldPanEnvStartCoord,-1

EnvPointsArrUp:
	mov	FileEdited,1
	call	fixbutton
	call	GetEnvOffset
	mov	eax,ENV_NrPoints
	cmp	byte ptr [eax],63
	jz	_ret

	mov	ecx,62
	sub	cl,CurrentPoint

	mov	ebp,ENV_Points
	mov	esi,62*3
	add	esi,ebp
	movzx	edi,CurrentPoint
	lea	edi,[edi+edi*2]

	jecxz	NoVolMove

	mov	ax,[ebp+edi+3]
	and	ax,511
	cmp	ax,1
	jz	_ret

	mov	ebp,ENV_NrPoints
	inc	byte ptr [ebp]

	movzx	eax,CurrentPoint
	inc	ax
	cmp	al,[ebp]
	jz	NoVolMove

ILikeToMoveVol:
	mov	ax,[esi]
	mov	[esi+3],ax
	mov	al,[esi+2]
	mov	[esi+5],al
	sub	esi,3
	loop	ILikeToMoveVol

	mov	ebp,ENV_Points
	mov	bx,[ebp+edi+6]
	mov	dx,bx
	and	dx,not 511
	and	bx,511
	shr	bx,1
	mov	cx,bx
	adc	bx,0
	or	bx,dx
	or	cx,dx
	mov	[ebp+edi+3],bx
	mov	[ebp+edi+6],cx

	movzx	bx,[ebp+edi+5]
	movzx	dx,[ebp+edi+2]
	add	bx,dx
	shr	bx,1
	mov	[ebp+edi+5],bl
	jmp	VolMove

NoVolMove:
	mov	ebp,ENV_Points
	mov	bx,[ebp+edi]
	and	bx,511
	mov	bl,10
	mov	[ebp+edi+3],bx
	mov	bl,byte ptr [ebp+edi+2]
	mov	byte ptr [ebp+edi+5],bl

VolMove:

	movzx	edi,CurrentInstrument
	GetOffset edi,edi,ENV_VolSustPoint
	mov	bl,CurrentPoint
	cmp	bl,byte ptr [edi]
	jae	NoSustAdd
	inc	byte ptr [edi]
NoSustAdd:
	cmp	bl,byte ptr [edi+1]
	jae	NoLoopStartAdd
	inc	byte ptr [edi+1]
NoLoopStartAdd:
	cmp	bl,byte ptr [edi+2]
	jae	NoLoopEndAdd
	inc	byte ptr [edi+2]
NoLoopEndAdd:

	call	PrintLoop
	call	PrintPoints
	call	PrintPoint
	call	PrintSustain
	call	PutEnvelope
	ret

VolEnvPointsArrDn:
	mov	Envelope,0
	mov	al,CurrentVolPoint
	mov	CurrentPoint,al
	call	GetEnvOffset
	call	EnvPointsArrDn
	mov	al,CurrentPoint
	mov	CurrentVolPoint,al
	call	PrintEnv
	call	PrintLoop
	call	PrintPoints
	call	PrintPoint
	call	PrintSustain
	call	PutEnvelope
	mov	[DragBarData+(13*4)*6+4],1
	mov	OldVolEnvStartCoord,-1
	ret

PanEnvPointsArrDn:
	mov	Envelope,1
	mov	al,CurrentPanPoint
	mov	CurrentPoint,al
	call	GetEnvOffset
	call	EnvPointsArrDn
	mov	al,CurrentPoint
	mov	CurrentPanPoint,al
	call	PrintEnv
	call	PrintLoop
	call	PrintPoints
	call	PrintPoint
	call	PrintSustain
	call	PutEnvelope
	mov	[DragBarData+(13*4)*7+4],1
	mov	OldPanEnvStartCoord,-1
	ret

EnvPointsArrDn:
	mov	FileEdited,1
	call	fixbutton
	mov	ebp,ENV_NrPoints
	cmp	byte ptr [ebp],1
	jle	_ret
	dec	byte ptr [ebp]

	movzx	edi,CurrentPoint
	lea	edi,[edi+edi*2]
	mov	esi,edi
	mov	ebp,ENV_Points
	add	esi,ebp

	mov	bx,[esi]
	and	bx,511
	mov	ax,[esi+3]
	and	ax,511
	add	ax,bx

	cmp	ax,511
	jbe	NoSugga
	mov	ax,511
NoSugga:
	and	word ptr [esi+3],not 511
	or	[esi+3],ax

	cmp	CurrentPoint,0
	jnz	NotFirstP

	mov	ax,[esi+3]
	and	ax,511
	mov	bx,[esi+6]
	and	bx,511
	add	ax,bx
	cmp	ax,511
	jbe	NoSugga2
	mov	ax,511
NoSugga2:
	and	word ptr [esi+6],not 511
	or	[esi+6],ax
	mov	bx,0
	mov	[esi+3],bx
NotFirstP:

	mov	ecx,63
	sub	cl,CurrentPoint
	jecxz	NoVolMove2
ILikeToMoveVol2:
	mov	ax,[esi+3]
	mov	[esi],ax
	mov	al,[esi+5]
	mov	[esi+2],al
	add	esi,3
	loop	ILikeToMoveVol2
NoVolMove2:

	mov	ebp,ENV_NrPoints
	mov	al,[ebp]
	cmp	al,CurrentPoint
	jae	Cheta
	mov	CurrentPoint,al
Cheta:
	movzx	edi,CurrentInstrument
	GetOffset edi,edi,ENV_VolSustPoint
	mov	bl,CurrentPoint
	cmp	bl,byte ptr [edi]
	jae	NoSustSub
	dec	byte ptr [edi]
NoSustSub:
	cmp	bl,byte ptr [edi+1]
	jae	NoLoopStartSub
	dec	byte ptr [edi+1]
NoLoopStartSub:
	cmp	bl,byte ptr [edi+2]
	jae	NoLoopEndSub
	dec	byte ptr [edi+2]
NoLoopEndSub:



	ret

VolEnvSustainArrUp:
	mov	Envelope,0		;0=Vol,1=Pan
	jmp	SustainArrUp

PanEnvSustainArrUp:
	mov	Envelope,1		;0=Vol,1=Pan

SustainArrUp:
	mov	FileEdited,1
	call	fixbutton
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_VolSustPoint
	GetOffset edi,edx,ENV_NrVolPoints
	mov	al,[ebx]
	cmp	al,[edx]
	jz	_ret
	inc	byte ptr [ebx]
	call	PrintSustain
	call	PutEnvelope
	ret


VolEnvSustainArrDn:
	mov	Envelope,0		;0=Vol,1=Pan
	jmp	SustainArrDn

PanEnvSustainArrDn:
	mov	Envelope,1		;0=Vol,1=Pan

SustainArrDn:
	mov	FileEdited,1
	call	fixbutton
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_VolSustPoint
	mov	al,[ebx]
	dec	al
	jl	_ret
	mov	[ebx],al
	call	PrintSustain
	call	PutEnvelope
	ret

VolSustainEnable:
	mov	FileEdited,1
	mov	Envelope,0		;0=Vol,1=Pan
	movzx	edi,CurrentInstrument
	GetOffset edi,edi,ENV_Flags
	btc	word ptr [edi],1
	rcl	bl,1
	and	bl,1
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,270
	mov	ButtonY1,274
	mov	ButtonX2,284
	mov	ButtonY2,290
	call	ButtonUpDown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	call	PutEnvelope
	ret


PanEnvSustainEnable:
	mov	FileEdited,1
	mov	Envelope,1		;0=Vol,1=Pan
	movzx	edi,CurrentInstrument
	GetOffset edi,edi,ENV_Flags
	movzx	ecx,PanOrVib
	lea	ecx,[ecx+ecx*2]
	add	ecx,4
	btc	word ptr [edi],cx
	rcl	bl,1
	and	bl,1
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,270
	mov	ButtonY1,274+127
	mov	ButtonX2,284
	mov	ButtonY2,290+127
	call	ButtonUpDown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	call	PutEnvelope
	ret


FadeOutArrUp:
	mov	FileEdited,1
	call	fixbutton
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_VolFade
	mov	ax,[ebx]
	mov	bp,ax
	and	bp,0f000h
	and	ax,00fffh
	cmp	ax,00fffh
	jz	_ret
	inc	ax
	or	ax,bp
	mov	[ebx],ax
	call	PrintFadeOut
	ret

FadeOutArrDn:
	mov	FileEdited,1
	call	fixbutton
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_VolFade
	mov	ax,[ebx]
	mov	bp,ax
	and	bp,0f000h
	and	ax,00fffh
	jz	_ret
	dec	ax
	or	ax,bp
	mov	[ebx],ax
	call	PrintFadeOut
	ret


VibSweepArrUp:
	ret
Comment #
	mov	FileEdited,1
	call	fixbutton
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_VibSweep
	cmp	byte ptr [ebx],0ffh
	jz	_ret
	inc	byte ptr [ebx]
	call	PrintVibSweep
	ret
#
VibSweepArrDn:
	ret
Comment #
	mov	FileEdited,1
	call	fixbutton
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_VibSweep
	cmp	byte ptr [ebx],0
	jz	_ret
	dec	byte ptr [ebx]
	call	PrintVibSweep
	ret
#
MoveEnvData	Proc	Near
	pushad

	call	GetEnvOffset

	xor	eax,eax
	xor	ecx,ecx
	xor	edi,edi
AddNextPointG:
	mov	ebp,ENV_Points
	mov	dx,[ebp+edi]
	and	dx,511
	cmp	Envelope,0
	jz	NoVibZoom4
	cmp	PanOrVib,0
	jz	NoVibZoom4
	shl	dx,2			;!!!!!!!!!
NoVibZoom4:
	add	ax,dx
	inc	cx
	add	edi,3
	mov	ebp,ENV_NrPoints
	cmp	cl,[ebp]
	jbe	AddNextPointG
	add	eax,255
	push	eax
	mov	eax,13*4
	movzx	ebx,Envelope
	add	ebx,6
	mul	ebx
	mov	ebp,eax
	pop	eax

	cmp	[DragBarData+ebp+8],eax
	jz	DontUpdateVolDragBar
	mov	[DragBarData+ebp+4],1
	mov	[DragBarData+ebp+8],eax

	movzx	ebx,VolEnvStartCoord
	cmp	Envelope,0
	jz	Joda
	movzx	ebx,PanEnvStartCoord
Joda:
	add	ebx,255
	cmp	ebx,eax
	jbe	DontUpdateVolDragBar
	sub	eax,256
	mov	[DragBarData+ebp+0],eax
	cmp	Envelope,0
	jz	ENV_VollUpd
	mov	PanEnvStartCoord,ax
	jmp	DontUpdateVolDragBar
ENV_VollUpd:
	mov	VolEnvStartCoord,ax
DontUpdateVolDragBar:

	popad
	ret
MoveEnvData	EndP

UpdateEnvVolDrag:
	push	eax
	mov	eax,[DragBarData+(13*4)*6+0]
	mov	VolEnvStartCoord,ax
	mov	Envelope,0
	call	PutEnvelope
	pop	eax
	ret

UpdateEnvPanDrag:
	push	eax
	mov	eax,[DragBarData+(13*4)*7+0]
	mov	PanEnvStartCoord,ax
	mov	Envelope,1
	call	PutEnvelope
	pop	eax
	ret

VolumeSpeedInput:
	mov	FileEdited,1
	mov	Envelope,0
	mov	edi,248*80+48/8 	;Screen Pos
	mov	ecx,3			;Max Len
	mov	ax,0101h		;Ah=BPL, AL:1=Dec,2=Hex
	movzx	ebp,CurrentInstrument
	GetOffset ebp,ebp,ENV_VolSpeed
	movzx	ebx,byte ptr [ebp]
	mov	DigitTarget,ebp 	;Where to put result
	mov	DigitSize,1		;1=byte,2=word,3=dword
	mov	DigitLimit,255		;Max nr allowed
	mov	DigitInput,25		;Info
	call	InputDigits
	ret

PanSpeedInput:
	mov	FileEdited,1
	mov	Envelope,1
	mov	edi,(248+127)*80+48/8
	mov	ecx,3
	mov	ax,0101h
	movzx	ebp,CurrentInstrument
	GetOffset ebp,ebp,ENV_VolSpeed
	movzx	ebx,byte ptr [ebp]
	mov	DigitTarget,ebp
	mov	DigitSize,1
	mov	DigitLimit,255
	mov	DigitInput,26
	call	InputDigits
	ret

FadeOutSave	dw	0
FadeOutInput:
	mov	FileEdited,1
	mov	edi,376*80+568/8
	mov	ecx,3

	movzx	ebp,CurrentInstrument
	GetOffset ebp,ebp,ENV_VolFade
	mov	bx,word ptr [ebp]
	mov	ax,bx
	and	bx,00fffh
	and	ax,0f000h
	mov	FadeOutSave,ax
	mov	DigitTarget,ebp
	mov	DigitSize,2
	mov	DigitLimit,0fffh
	mov	DigitInput,27
	mov	ax,0102h
	call	InputDigits
	ret

InputRelNote:
	mov	ah,1
	mov	cl,5
	move	edi,0a0000h+359*80+71
	lea	esi,Spaces
	call	mouseoff
	call	printtext
	call	mouseon
	mov	KBD5Request,1
	ret

CurrentSampName dw	0
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;Updates the SampleNames
;Calls: CurrentSampName
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
UpdateSampNames     Proc    Near
	cmp	Menu_DownScreen,7		;Check
	jnz	_ret
	Pushad

	move	edi,0a0000h+248*80+416/8
	mov	esi,SampleNamesPtr

	movzx	eax,CurrentSampName
	sub	eax,16
	mov	ebx,22
	mul	ebx
	add	esi,eax

	mov	MouseX1,415
	mov	MouseY1,247
	mov	MouseX2,617
	mov	MouseY2,343
	call	MouseOff

	movzx	ebp,CurrentSampName
	mov	edx,8
	mov	ah,1
PrintSampLoopen:
	cmp	SampleNameInput,1
	jz	NoSampInv
	cmp	bp,CurrentSample
	jnz	NoSampInv
	mov	InvertText,-1
NoSampInv:
	push	edi
	mov	cl,2
	mov	ebx,ebp
	and	ebx,0fh
	cmp	SampHexDec,0
	jz	PutDec11
	call	PutHex
	jmp	PutHex11
PutDec11:
	call	PutDecimal
PutHex11:

	add	edi,2
	mov	ebx,[SampleOffsetEnd+ebp*4]
	sub	ebx,[SampleOffsetStart+ebp*4]
	mov	ebx,' '
	jle	Fyfasikern
	mov	ebx,3
Fyfasikern:
	call	putcharacter
	inc	edi
	mov	cl,22
	call	printtext
	mov	InvertText,0
	add	esi,22
	pop	edi
	add	edi,12*80
	add	ebp,1
	dec	edx
	jnz	PrintSampLoopen
	call	PrintRelNote

	call	MouseReset
	call	MouseOn
	Popad
	Ret
UpdateSampNames  EndP

CurrVolPointUp:
	mov	Envelope,0
	call	FixButton
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_NrVolPoints
	mov	al,CurrentVolPoint
	cmp	al,[ebx]
	jz	_ret
	inc	CurrentVolPoint
	jmp	CVPD
CurrVolPointDn:
	call	FixButton
	mov	Envelope,0
	cmp	CurrentVolPoint,0
	jz	_ret
	dec	CurrentVolPoint
CVPD:
	call	PrintPoint
	call	PrintEnv
	call	PutEnvelope
	ret

CurrPanPointUp:
	mov	Envelope,1
	call	FixButton
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_NrVolPoints
	mov	al,CurrentPanPoint
	cmp	al,[ebx]
	jz	_ret
	inc	CurrentPanPoint
	jmp	CPPD
CurrPanPointDn:
	call	FixButton
	mov	Envelope,1
	cmp	CurrentPanPoint,0
	jz	_ret
	dec	CurrentPanPoint
CPPD:
	call	PrintPoint
	call	PrintEnv
	call	PutEnvelope
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DecreaseSampleNames:
	call	fixbutton
	mov	ax,CurrentSampName
	and	ax,0fh
	jz	Dummy
	dec	CurrentSampName
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
IncreaseSampleNames:
	call	fixbutton
	mov	ax,CurrentSampName
	and	ax,0fh
	cmp	ax,8
	jz	Dummy
	inc	CurrentSampName
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Temp_ecx	dd	0
SampleNameSquare:
	mov	LeftKeyWait,2
	movzx	eax,MouseY
	sub	eax,248
	mov	ebx,12
	xor	edx,edx
	div	ebx
	movzx	ebx,CurrentSampName
	add	ebx,eax
	cmp	bx,CurrentSample
	jz	ContSamp

	mov	CurrentSample,bx
	mov	OldCurrentSampName,-1
	cmp	AutoName,0
	jz	ContSamp
	pushad
	call	Getname2
	popad
ContSamp:
	cmp	[DragNumber+8],1	;Inst
	jz	NoDragSampCopy
	cmp	[DragNumber+8],2	;Samp
	jz	CopyMoveSamp

	mov	cl,[Keys+1dh]
	mov	CtrlPress,cl
	mov	ch,[Keys+2ah]
	mov	ShiftPress,ch
	or	cl,ch
	mov	PressCheck,cl
ContSamp2:
	cmp	ShiftPress,1
	jnz	NoDragSampMove
	and	ebx,4095
	mov	[DragNumber],1		;Move
	mov	[DragNumber+4],ebx	;Nr
	mov	[DragNumber+8],2	;Samp
	mov	UpdateMouse,80h
	mov	LeftKeyWait,100
NoDragSampMove:
	cmp	CtrlPress,1
	jnz	NoDragSampCopy
	and	ebx,4095
	mov	[DragNumber],2		;Copy
	mov	[DragNumber+4],ebx	;Nr
	mov	[DragNumber+8],2	;Samp
	mov	UpdateMouse,80h
	mov	LeftKeyWait,100
NoDragSampCopy:
	cmp	OldCurrentSampName,-1
	jnz	DontDoitSamp
	call	PrintSampleInfo
DontDoitSamp:

	cmp	MouseB,2
	jnz	Dummy

	mov	dx,CurrentSampName
	mov	OldCurrentSampName,dx

	mov	OldCurrentSample,bx
	mov	SampleNameInput,1
	call	UpdateSampNames
	mov	ebx,12*80
	mul	ebx
	add	eax,248*80+440/8
	mov	edi,eax
	mov	esi,SampleNamesPtr
	movzx	eax,CurrentSample
	sub	eax,16
	mov	ebx,22
	mul	ebx
	add	esi,eax
	mov	ax,0103h
	mov	ecx,22
	mov	FileEdited,1
	call	InputRoutine
	ret
CopyMoveSamp:
	mov	ShiftPress,0
	mov	CtrlPress,0
	mov	PressCheck,0
	mov	OldCurrentInstName,-1
	mov	OldCurrentSampName,-1
	cmp	[DragNumber],2
	jz	CopySamp
	mov	ebp,[DragNumber+4]
	mov	edx,ebx
	cmp	ebp,edx
	jz	QuitCopyMoveSamp

	push	ebx edx
	call	AskKillSamp;le2
	pop	edx ebx
	jc      QuitCopyMoveSamp

	call	CopySample
	mov	DontDisallocSample,1
	mov	edx,ebp
	mov	CurrentSample,dx
	push	ebx
	call	KillSample2
	pop	ebx

	mov	CurrentSample,bx
	mov	DontDisallocSample,0
	jmp	QuitCopyMoveSamp

CopySamp:					;!!!!!!!!!!!!!!!!!!
	mov	ebp,[DragNumber+4]
	cmp	ebp,ebx
	jz	QuitCopyMoveSamp

	mov	ecx,[SampleOffsetEnd+ebp*4]
	sub	ecx,[SampleOffsetStart+ebp*4]
	jz	QuitCopyMoveSamp

	mov	esi,[SampleOffsetEnd+ebx*4]
	sub	esi,[SampleOffsetStart+ebx*4]
	jz	@@CopyOkay
	lea	esi,OverWriteSampText
	mov	Menu_Popup,2
	call	PopUpHandler
	cmp	PopupStatus,0
	jz	QuitCopyMoveSamp
@@CopyOkay:

;--..--
	push	ecx
	mov	eax,ecx
	mov	cl,[VoiceControl+ebp]
	bt	cx,2
	setc	cl
	shl	eax,cl
	pop	ecx
;--..-- 			;ecx=samples, eax=bytes
	mov	Temp_ecx,ecx

	call	MouseHourGlass
	push	ebx
	push	ebp
	mov	ebp,1024
	xor	ebx,ebx
	call	MemAlloc
	pop	ebp
	jc	MemFullErrs2

	push	CurrentSample
	mov	ebx,eax
	mov     CurrentSample,bp
	mov	eax,[SampleOffsetStart+ebp*4]
	xor	edx,edx
	call	GetSampleFromDRAM
	pop	CurrentSample
	pop	ebx

	mov	esi,[SampleOffsetStart+ebx*4]
	mov	eax,[SampleOffsetEnd+ebx*4]
	sub	eax,esi
	jz	NothingToDisalloc
	call	DisallocSample
NothingToDisalloc:
	mov	edx,ebx
	call	CopySample
	mov	eax,[SampleOffsetStart+ebx*4]

	mov	[SampleOffsetStart+ebx*4],0
	sub	[LoopStart+ebx*4],eax
	sub	[LoopEnd+ebx*4],eax
	mov	eax,Temp_ecx
	mov	[SampleOffsetEnd+ebx*4],eax

	call	AllocSample
;	jc	MemFullErrs2
	jnc	NoCOPErr
	call	FixAllocSampleError
NoCOPErr:

	xor	edx,edx
	call	MoveSample
	call	MouseArrow
	mov	ebp,1024
	call	MemDisalloc

QuitCopyMoveSamp:
	mov	[DragNumber],0		;No Action
	mov	[DragNumber+4],0	;Nr
	mov	[DragNumber+8],0	;Nothing
	mov	UpdateMouse,80h
	mov	MouseCursor,0
	mov	LeftKeyWait,100
	call	PrintSampleInfo
	mov	OldCurrentSampName,-1
	ret

MemFullErrs2:
	mov	DontDisallocSample,1
	call	KillSample2
	mov	DontDisallocSample,0
	mov	ax,GUSDramErr
	jmp	ErrorHandler


ButtonCopySamp:
	cmp	MouseB,1
	jz	@@Good
	mov	MouseB,1
@@Good:
	call	fixbutton
	movzx   eax,CurrentInstrument
	call	CheckForShadow
	jc	_ret
	mov	CtrlPress,1
	movzx	ebx,CurrentSample
	cmp	[DragNumber+8],1	;Inst
	jz	NoDragSampCopy
	cmp	[DragNumber+8],2	;Samp
	jz	CopyMoveSamp
	jmp	ContSamp2
ButtonMoveSamp:
	cmp	MouseB,1
	jz	@@Good
	mov	MouseB,1
@@Good:
	call	fixbutton
	movzx   eax,CurrentInstrument
	call	CheckForShadow
	jc	_ret
	mov	ShiftPress,1
	movzx	ebx,CurrentSample
	cmp	[DragNumber+8],1	;Inst
	jz	NoDragSampCopy
	cmp	[DragNumber+8],2	;Samp
	jz	CopyMoveSamp
	jmp	ContSamp2

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PanOrVib	db	0
SelectPanEnvelope:
	mov	PanOrVib,0
	mov	CurrentPanPoint,0
	call	UpdateEnvelopeScreen
	ret

SelectVibEnvelope:
	mov	PanOrVib,1
	mov	CurrentPanPoint,0
	call	UpdateEnvelopeScreen
	ret

PreDefVol0:
	mov	PrevChoice,0
	jmp	PreDefVol
PreDefVol1:
	mov	PrevChoice,1
	jmp	PreDefVol
PreDefVol2:
	mov	PrevChoice,2
	jmp	PreDefVol
PreDefVol3:
	mov	PrevChoice,3
	jmp	PreDefVol
PreDefVol:
	mov	[DragBarData+(13*4)*6+0],0	;Clear
	mov	Envelope,0
	mov	FileEdited,1
	call	SetPreDefined
	mov	PrevChoice,0
	mov	VolEnvStartCoord,0
	mov	OldVolEnvStartCoord,-1
	mov	CurrentVolPoint,0
	call	UpdateEnvelopeScreen
	call	fixbutton
	ret

PreDefPan0:
	mov	PrevChoice,0
	jmp	PreDefPan
PreDefPan1:
	mov	PrevChoice,1
	jmp	PreDefPan
PreDefPan2:
	mov	PrevChoice,2
	jmp	PreDefPan
PreDefPan3:
	mov	PrevChoice,3
	jmp	PreDefPan
PreDefPan:
	mov	[DragBarData+(13*4)*7+0],0	;Clear
	mov	Envelope,1
	mov	FileEdited,1
	call	SetPreDefined
	mov	PrevChoice,0
	mov	PanEnvStartCoord,0
	mov	OldVolEnvStartCoord,-1
	mov	CurrentPanPoint,0
	call	UpdateEnvelopeScreen
	call	fixbutton
	ret

ScaleVolXSub:
	mov	Envelope,0
	mov	ax,-1
	mov	bx,0
	jmp	ScaleEnv
ScaleVolXAdd:
	mov	Envelope,0
	mov	ax,1
	mov	bx,0
	jmp	ScaleEnv
ScaleVolYSub:
	mov	Envelope,0
	mov	ax,0
	mov	bx,-1
	jmp	ScaleEnv
ScaleVolYAdd:
	mov	Envelope,0
	mov	ax,0
	mov	bx,1
	jmp	ScaleEnv
ScalePanXSub:
	mov	Envelope,1
	mov	ax,-1
	mov	bx,0
	jmp	ScaleEnv
ScalePanXAdd:
	mov	Envelope,1
	mov	ax,1
	mov	bx,0
	jmp	ScaleEnv
ScalePanYSub:
	mov	Envelope,1
	mov	ax,0
	mov	bx,-1
	jmp	ScaleEnv
ScalePanYAdd:
	mov	Envelope,1
	mov	ax,0
	mov	bx,1

ScaleEnv:
	mov	FileEdited,1
	call	fixbutton
	call	GetEnvOffset
	mov	ecx,ENV_NrPoints
	movzx	ecx,byte ptr [ecx]
	mov	edi,ENV_Points
	inc	ecx
FixScaleLoopen:
	mov	dx,word ptr [edi]
	mov	bp,dx
	and	bp,not 511
	and	dx,511
	jz	FirstPo
	add	dx,ax
	jle	SkipThisPart
	cmp	dx,511
	ja	SkipThisPart
	or	dx,bp
	mov	word ptr [edi],dx
FirstPo:
	movzx	dx,byte ptr [edi+2]
	cmp	Envelope,0
	jz	ScaleYVol
	mov	bp,0ffh
	cmp	dx,128
	jz	SkipThisPart
	ja	Addit
	jmp	SubIt
ScaleYVol:
	mov	bp,07fh
	cmp	dx,64
	jz	SkipThisPart
	ja	Addit
SubIt:
	sub	dx,bx
	jl	SkipThisPart
	jmp	GoForIt
AddIt:
	add	dx,bx
	jl	SkipThisPart
GoForIt:
	cmp	dx,bp
	ja	SkipThisPart
	mov	byte ptr [edi+2],dl
SkipThisPart:
	add	edi,3
	loop	FixScaleLoopen
	call	PrintEnv
	call	PutEnvelope
	call	MoveEnvData
	ret

LineVol:
	mov	al,CurrentVolPoint
	mov	CurrentPoint,al
	mov	Envelope,0
	mov	dx,0
	jmp	SetEnvCurve
Sine1Vol:
	mov	al,CurrentVolPoint
	mov	CurrentPoint,al
	mov	Envelope,0
	mov	dx,1
	jmp	SetEnvCurve
Sine2Vol:
	mov	al,CurrentVolPoint
	mov	CurrentPoint,al
	mov	Envelope,0
	mov	dx,2
	jmp	SetEnvCurve

LinePan:
	mov	al,CurrentPanPoint
	mov	CurrentPoint,al
	mov	Envelope,1
	mov	dx,0
	jmp	SetEnvCurve
Sine1Pan:
	mov	al,CurrentPanPoint
	mov	CurrentPoint,al
	mov	Envelope,1
	mov	dx,1
	jmp	SetEnvCurve
Sine2Pan:
	mov	al,CurrentPanPoint
	mov	CurrentPoint,al
	mov	Envelope,1
	mov	dx,2

SetEnvCurve:
	mov	FileEdited,1
	call	GetEnvOffset
	mov	edi,ENV_Points
	movzx	ebx,CurrentPoint
	inc	ebx
	lea	ebx,[ebx+ebx*2]
	mov	ax,word ptr [edi+ebx]
	and	ax,511
	shl	dx,9
	or	ax,dx
	mov	word ptr[edi+ebx],ax
	call	fixbutton
	call	PutEnvelope
	ret



CurveClip1	dw	0
CurveClip2	dw	0
CurveX1 	dw	0
CurveX2 	dw	0
CurveY1 	dw	0
CurveY2 	dw	0
CurveScrWidth	dd	0
CurveOffset	dd	0
DeltaX		dw	0
DeltaY		dw	0
BitPattern	db	0
CurveType	dw	0	;1 or 2
Lasth		dd	0
XCounter	dw	0
DrawCurve	Proc	Near
	pushad
	mov	Lasth,0
	mov	edi,CurveOffset
	mov	eax,CurveScrWidth
	movzx	ebx,CurveY1
	mul	bx
	add	edi,eax

	mov	ax,CurveX1
	cmp	ax,0
	jge	NoKansas

	inc	ax
	dec	edi

	mov	bx,8
	cwd
	idiv	bx
	cwde
	add	edi,eax

	neg	dx
	mov	ax,dx
	jmp	AskMe

NoKansas:
	mov	bx,8
	xor	dx,dx
	div	bx
	add	edi,eax
	mov	ax,7
	sub	ax,dx
AskMe:
	xor	dx,dx
	bts	dx,ax
	mov	BitPattern,dl
	mov	ax,CurveX1
	mov	XCounter,ax
	sub	CurveX2,ax
	mov	CurveX1,0

	mov	ax,CurveX2
	mov	DeltaX,ax

	mov	ax,CurveY2
	mov	DeltaY,ax
	mov	ax,CurveY1
	sub	DeltaY,ax

	cmp	DeltaY,0
	jg	CurveDown2
	neg	CurveScrWidth
	sub	DeltaY,2
CurveDown2:
	inc	DeltaY
CurveDown:
	cmp	CurveType,0
	jnz	Sine

	movsx	eax,DeltaY
	movzx	ebp,DeltaX
	movzx	esi,CurveX1
	imul	esi
	idiv	ebp
	cmp	eax,0
	jge	GoForTit
	neg	eax
	jmp	GoForTit
Sine:
	movzx	eax,CurveX1				;Interpol
	shl	eax,9
	movzx	ebp,DeltaX				;Delta X
	xor	edx,edx
	div	ebp
	movzx	ecx,byte ptr [EnvSine+eax]

	bt	CurveType,0
	jc	Sine1
	neg	eax
	add	eax,512
	movzx	eax,byte ptr [EnvSine+eax]
	mov	ecx,255
	sub	ecx,eax
Sine1:
	mov	eax,ecx
	movsx	ebp,DeltaY				;Delta Y
	cmp	ebp,0
	jg	CurvePozit
	neg	ebp
CurvePozit:
	mul	ebp
	shr	eax,8
GoForTit:
	mov	ecx,eax
	sub	ecx,Lasth
	mov	Lasth,eax
	mov	ebp,CurveScrWidth
	cmp	ecx,0
	jnz	PutOutPixel2
	mov	ecx,1
	mov	ebp,0

PutOutPixel2:
	mov	ax,CurveClip1	;Clip
	cmp	ax,XCounter
	jg	ClipTheCurve

	mov	ax,CurveClip2	;Clip
	cmp	ax,XCounter
	jg	PutOutPixel

ClipTheCurve:
	mov	eax,ecx
	imul	ebp
	add	edi,eax
	jmp	NextPoo
PutOutPixel:
	mov	al,BitPattern
	or	[edi],al
	add	edi,ebp
	loop	PutOutPixel
NextPoo:
	ror	BitPattern,1
	adc	edi,0
	inc	XCounter
	inc	CurveX1
	mov	ax,CurveX1
	cmp	ax,CurveX2
	jbe	CurveDown

	popad
	ret
DrawCurve	EndP


GetEnvOffset	Proc	near
	push	eax
	movzx	edi,CurrentInstrument
	GetOffset edi,eax,ENV_VolPoints
	mov	ENV_Points,eax
	GetOffset edi,eax,ENV_NrVolPoints
	mov	ENV_NrPoints,eax
	pop	eax
	ret
GetEnvOffset	EndP

PrevChoice		dd	0
PreDefinedVolEnv	dd	PreDefinedVolEnv1,PreDefinedVolEnv2,PreDefinedVolEnv3,PreDefinedVolEnv4
PreDefinedPanEnv	dd	PreDefinedPanEnv1,PreDefinedPanEnv2,PreDefinedPanEnv3,PreDefinedPanEnv4
PreDefinedVibEnv	dd	PreDefinedVibEnv1,PreDefinedVibEnv2,PreDefinedVibEnv3,PreDefinedVibEnv4

;			       Flag,Shadow, volfade, spd,points,sust,loop st,loop end
PreDefinedVolEnv1	db    02h,0, -1,   0,   0, 125, 3,0,0, 1,000h,000h,07fh,015h,002h,0010h,015h,002h,015h,015h,004h,000h
PreDefinedVolEnv2	db	0,0, -1,   0,   0, 125, 1,0,0, 1,000h,000h,07fh,010h,000h,0000h
PreDefinedVolEnv3	db    03h,0, -1,0e9h,001h, 125, 3,0,1, 3,000h,000h,07fh,014h,002h,0020h,00fh,004h,038h,00fh,002h,020h
PreDefinedVolEnv4	db    03h,0, -1,080h,001h, 125, 5,2,3, 5,000h,000h,060h,004h,000h,007fh,004h,000h,058h,006h,000h,010h,00ah,000h,02ch,008h,000h,010h

PreDefinedPanEnv1	db	0,0, -1,  -1,  -1, 125,11,0,0, 1,000h,000h,080h,005h,000h,00ffh,00ah,000h,000h,00ah,000h,0e0h,00ah,000h,020h,00ah,000h,0c0h,00ah,000h,040h,00ah,000h,0a0h,00ah,000h,060h,00ah,000h,090h,00ah,000h,070h,00ah,000h,080h
PreDefinedPanEnv2	db    08h,0, -1,  -1,  -1, 125,11,0,9,11,000h,000h,080h,00ah,000h,0090h,00ah,000h,070h,00ah,000h,098h,00ah,000h,068h,00ah,000h,0a0h,00ah,000h,060h,00ah,000h,0c0h,00ah,000h,040h,00ah,000h,0e0h,00ah,000h,020h,00ah,000h,0e0h
PreDefinedPanEnv3	db    08h,0, -1,  -1,  -1, 125, 4,0,0, 4,000h,000h,080h,01eh,002h,00e0h,01eh,004h,080h,01eh,002h,020h,01eh,004h,080h
PreDefinedPanEnv4	db	0,0, -1,  -1,  -1, 125, 5,0,0, 1,000h,000h,080h,00ah,000h,00a0h,014h,000h,060h,014h,000h,080h,00ah,000h,080h,00ah,000h,080h

PreDefinedVibEnv1	db    40h,0, -1,   0, 10h, 125, 4,0,0, 4,000h,000h,080h,002h,002h,008fh,002h,004h,080h,002h,002h,0071h,002h,004h,080h
PreDefinedVibEnv2	db    40h,0, -1,   0, 10h, 125, 3,0,0, 3,000h,000h,08fh,003h,000h,008fh,001h,000h,071h,003h,000h,0071h
PreDefinedVibEnv3	db    40h,0, -1,   0, 10h, 125, 3,0,0, 3,000h,000h,080h,004h,000h,00a6h,001h,000h,05ah,004h,000h,0080h
PreDefinedVibEnv4	db    40h,0, -1,   0, 10h, 125, 3,0,0, 3,000h,000h,080h,004h,000h,005ah,001h,000h,0a6h,004h,000h,0080h

SetPreDefined	Proc	Near
	pushad
	movzx	edi,CurrentInstrument
	GetOffset edi,edi,ENV_VolSpeed
	lea	esi,PreDefinedVolEnv
	mov	bx,1111110111111100b
	cmp	Envelope,0
	jz	OhYes
	lea	esi,PreDefinedPanEnv
	mov	bx,1111101111100111b
	cmp	PanOrVib,0
	jz	OhYes
	lea	esi,PreDefinedVibEnv
	mov	bx,1111011100111111b
OhYes:
	mov	eax,PrevChoice
	mov	esi,[esi+eax*4]

	movzx	eax,CurrentInstrument
	dec	eax
	mov	ecx,716
	mul	ecx
	add	eax,InstrumentInfo
	mov	ecx,eax

	lodsw
	and	word ptr [ecx+120],bx
	or	word ptr [ecx+120],ax

	lodsb
;	cmp	al,-1
;	jz	KK_Skip1
;	mov	byte ptr [ecx+122],al
;KK_Skip1:
	lodsw
	cmp	ax,-1
	jz	KK_Skip2
	cmp	Envelope,0	;Vol
	jz	PreserveAmp
	cmp	PanOrVib,0	;Pan
	jz	KK_Skip2
	and	ax,0f000h	;Vib
	and     word ptr [ecx+123],0fffh
	or	word ptr [ecx+123],ax
	jmp	KK_Skip2
PreserveAmp:
	and	ax,0fffh
	and     word ptr [ecx+123],0f000h
	or	word ptr [ecx+123],ax
KK_Skip2:

	mov	cl,[esi+1]
	inc	cl
	and	ecx,0ffh
	lea	ecx,[ecx+ecx*2]
	add	ecx,5
	rep	movsb

	mov	[DragBarData+(13*4)*6+4],1
	mov	[DragBarData+(13*4)*7+4],1
	mov	OldPanEnvStartCoord,-1
	mov	OldVolEnvStartCoord,-1

	popad
	ret
SetPreDefined EndP

SetInitialEnvelopes	Proc	Near
	push	word ptr PanOrVib
	mov	Envelope,0
	call	SetPreDefined
	mov	PanOrVib,0
	mov	Envelope,1
	call	SetPreDefined
	mov	PanOrVib,1
	mov	Envelope,1
	call	SetPreDefined

	pushad
	movzx	eax,CurrentInstrument
	dec	eax
	mov	ecx,716
	mul	ecx
	add	eax,InstrumentInfo
	mov	edi,eax
	mov	al,0
	mov	ecx,120
	rep	stosb
	popad

	pop	word ptr PanOrVib
	ret
SetInitialEnvelopes	EndP



;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;				     Piano
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;컴컴컴컴컴컴컴컴컴�
;Calls: ebx=Number
;	edi=Offset
;컴컴컴컴컴컴컴컴컴�
PrintBlackNumber	Proc	Near
	push	eax edx esi
	lea	ebx,[ebx+ebx*2] 	;Get offset to char
	lea	esi,[ebx*4+3+4*12]
	add	esi,[AllocTable+1040*8]

	mov	dx,3c4h 		;Write mask register
	mov	ax,0102h
	out	dx,ax

	mov	dx,3ceh 		;Read Mask
	mov	ax,0004h
	out	dx,ax

	Kalle=0
	Rept 6
	or	byte ptr [edi+80*Kalle],01111100b
	mov	al,[esi+Kalle]	       ;00100100b
	xor	al,0ffh 	       ;11011011b
	and	byte ptr [edi+80*Kalle],al
	Kalle=Kalle+1
	endm

	pop	esi edx eax
	ret
PrintBlackNumber	EndP

;컴컴컴컴컴컴컴컴컴�
;Calls: ebx=Number
;	edi=Offset
;컴컴컴컴컴컴컴컴컴�
PrintWhiteNumber	Proc	Near
	push	eax edx esi

	lea	ebx,[ebx+ebx*2] 	;Get offset to char
	lea	esi,[ebx*4+3+4*12]
	add	esi,[AllocTable+1040*8]

	mov	dx,3c4h 		;Write mask register
	mov	ax,0102h
	out	dx,ax
					;Read mask
	mov	dx,3ceh
	mov	ax,0004h
	out	dx,ax

	xor	ax,ax

	Kalle=0
	Rept 6
	mov	ah,[esi+Kalle]
	rol	ax,4
	and	word ptr [edi+80*Kalle],0011111111111000b
	or	[edi+80*Kalle],ax
	and	ax,0
	Kalle=Kalle+1
	endm

	pop	esi edx eax
	ret
PrintWhiteNumber	EndP

BlackWhiteTable db	0,1,0,1,0,0,1,0,1,0,1,0

PrintPianoSplit Proc	Near
	cmp	Menu_UpperScreen,0
	jnz	_ret
	cmp	PianoScreen,1
	jnz	_ret
	cmp	Menu_DownScreen,7
	jnz	_ret

	call	Mouseoff
	pushad
	movzx	ebp,CurrentInstrument
	GetOffset ebp,esi,ENV_SplitKBD
	movzx	edx,HiLoOctave
	shl	edx,3
	lea	edx,[edx+edx*2]
	add	esi,edx

	move	edx,0a0000h+210*80+23	;White Keys
	move	ebp,0a0000h+193*80+23	;Black Keys
	xor	eax,eax
	xor	ecx,ecx
	xor	ebx,ebx
PrintPSplitLoopen:

	push	eax ecx edx
	mov	eax,ecx
	mov	ecx,12
	xor	edx,edx
	div	ecx
	mov	cl,[BlackWhiteTable+edx]
	rcr	cl,1
	pop	edx ecx eax
	jc	PrintBlackKey

	mov	edi,edx
	add	edi,eax
	mov	bl,[esi+ecx]
	call	PrintBlackNumber
	inc	eax
	jmp	SkipPi
PrintBlackKey:

	mov	edi,ebp
	add	edi,eax
	dec	edi
	mov	bl,[esi+ecx]
	call	PrintWhiteNumber
SkipPi:
	inc	ecx
	cmp	ecx,96
	jnz	PrintPSplitLoopen
	call	mouseon
	popad
	ret
PrintPianoSplit EndP

WhitePressed0	db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	11000110b
		db	01111100b

WhitePressed1	db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	11000110b
		db	01111100b

WhitePressed2	db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	11000110b
		db	01111100b

BlackPressed0	db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	01111100b
		db	00111000b




BlackKeyTable	db	0,0,0,1,1,2,2,3,3,4,4,4,5,5,5,6,6,7,7,8,8,9,9,0ah,0ah,0bh,0bh,0bh
WhiteKeyTable	db	0,2,4,5,7,9,0bh
LastPianoMouse	dd	0
PianoPressed:
	movzx	eax,MouseX
	sub	ax,183
	mov	ebx,56
	xor	edx,edx
	div	ebx
	shr	edx,1
	lea	esi,BlackKeyTable
	cmp	MouseY,208
	jb	BlackKeyPressed
	lea	esi,WhiteKeyTable
	shr	edx,2
BlackKeyPressed:
	lea	eax,[eax+eax*2]
	lea	eax,[eax*4]
	add	al,[esi+edx]

	cmp	Menu_DownScreen,7
	jz	EnvelopeIsUp
PlayOnPianoAnyway:
	and	eax,0ffh
	mov	edx,eax
	add	edx,2

	movzx	ebx,HiLoOctave
	shl	ebx,3
	lea	ebx,[ebx+ebx*2]
	add	edx,ebx

	mov	RightKeyWait,1
	mov	LeftKeyWait,1
	cmp	edx,LastPianoMouse
	jz	_ret
	mov	LastPianoMouse,edx
	movzx	ebx,CursorChannel
	mov	[KeyOffTable+ebx],1
	call	MousePlay
	ret


EnvelopeIsUp:
	mov	FileEdited,1

	movzx	ebp,CurrentInstrument
	GetOffset ebp,esi,ENV_SplitKBD

	movzx	edx,HiLoOctave
	shl	edx,3
	lea	edx,[edx+edx*2]
	add	esi,edx

	cmp	PianoStyle,1
	jz	FTStyledPiano

	cmp	MouseB,1
	jz	IncSplit
	cmp	MouseB,3
	jz	_ret
	mov	bl,byte ptr [esi+eax]
	dec	bl
	jl	_ret
	mov	byte ptr [esi+eax],bl
	call	PrintPianoSplit
	mov	al,Original
	mov	RightKeyWait,al
	ret
IncSplit:
	mov	bl,byte ptr [esi+eax]
	inc	bl
	cmp	bl,10h
	jz	_ret
	mov	byte ptr [esi+eax],bl
	call	PrintPianoSplit
	ret

FTStyledPiano:
	cmp	MouseB,1
	ja	PlayOnPianoAnyway
	mov	bx,CurrentSample
	and	bx,0fh
	mov	byte ptr [esi+eax],bl
	call	PrintPianoSplit
	mov	LeftKeyWait,2
	ret

HiLoOctave		db	1
OldCurrNoteTable	db	32 dup(0)
OldKeyOffTable		db	32 dup(0)
PianoNotePriority	db	122 dup(0)
PianoPress		db	0
UpdatePianoPress	Proc	Near
	cmp	menu_popup,0
	jz	ContPiano
	cmp	menu_popup,23
	jz	ContPiano

	mov	[CheckTable],23
	mov	[CheckTable+4],187
	mov	[CheckTable+8],80
	mov	[CheckTable+12],221
	call	CheckAgainstPopup
	jc	_ret
ContPiano:
	pushad
	mov	ecx,32
UpdateNextPress:
	mov	al,[KeyOffTable+ecx-1]
	mov	PianoPress,al

	cmp	al,1
	jz	Piano_KeyPress

	cmp	[OldKeyOffTable+ecx-1],0
	jz	NoUPPUpdate
	mov	[OldKeyOffTable+ecx-1],0
	jmp	Piano_KeyRelease
Piano_KeyPress:
	cmp	[MIDIChanTable+ecx-1],0
	jnz	PlayKBD2
	cmp	[Mute+ecx-1],1
	jz	NoUPPUpdate
PlayKBD2:


	mov	[OldKeyOffTable+ecx-1],1
	movzx	eax,[R_CurrNoteTable+ecx-1]
	cmp	al,0
	jz	Piano_KeyRelease
	cmp	al,[OldCurrNoteTable+ecx-1]
	jz	NoUPPUpdate
	mov	PianoPress,1
	call	UpdateKeys
	inc	[PianoNotePriority+eax]
Piano_KeyRelease:
	movzx	eax,[OldCurrNoteTable+ecx-1]
	cmp	al,0
	jz	Piano_DontRelease
	mov	PianoPress,0
	dec	[PianoNotePriority+eax]
	jnz	Piano_DontRelease2
	call	UpdateKeys
Piano_DontRelease2:
	cmp	[KeyOffTable+ecx-1],1
	jz	Piano_DontRelease
	mov	[OldCurrNoteTable+ecx-1],0
	jmp	NoUPPUpdate

Piano_DontRelease:
	mov	al,[R_CurrNoteTable+ecx-1]
	mov	[OldCurrNoteTable+ecx-1],al

NoUPPUpdate:
	loop	UpdateNextPress
	popad
	ret
UpdatePianoPress	EndP


BWTable 	db	0,9,1,9,2,0,9,1,9,1,9,2
WhiteOffsTable	dd	0,0,1,1,2,3,3,4,4,5,5,6
WhitePressed	dd	WhitePressed0,WhitePressed1,WhitePressed2
UpdateKeys:
	mov	MouseX1,156
	mov	MouseY1,186
	mov	MouseX2,638
	mov	MouseY2,222
	call	MouseOff
	push	eax
	sub	al,2
	and	eax,0ffh

	movzx	edx,HiLoOctave
	shl	edx,3
	lea	edx,[edx+edx*2]
	sub	eax,edx
	jl	DontPress
	cmp	eax,05fh
	ja	DontPress

	mov	ebx,12
	xor	edx,edx
	div	ebx
	mov	edi,eax
	lea	eax,[eax*4]
	lea	edi,[edi+edi*2]
	add	edi,eax
	movzx	eax,[BWTable+edx]
	cmp	al,9
	jz	ItsABlackOne
	mov	esi,[WhitePressed+eax*4]
	add	edi,[WhiteOffsTable+edx*4]
	cmp	PianoPress,1
	jz	WhPress
	call	RemWhiteKey
	pop	eax
	call	MouseReset
	call	MouseOn
	ret
WhPress:
	call	PutWhiteKey
	pop	eax
	call	MouseReset
	call	MouseOn
	ret
ItsABlackOne:
	lea	esi,BlackPressed0
	add	edi,[WhiteOffsTable+edx*4]
	cmp	PianoPress,1
	jz	BlPress
	call	RemBlackKey
	pop	eax
	call	MouseReset
	call	MouseOn
	ret
BLPress:
	call	PutBlackKey
DontPress:
	pop	eax
	call	MouseReset
	call	MouseOn
	ret


PutWhiteKey	Proc	Near
	pushad
	move	eax,0a0000h+80*185+183
	add	edi,eax

	mov	dx,3c4h 		;Write mask register
	mov	ax,0202h
	out	dx,ax			;Read mask
	mov	dx,3ceh
	mov	ax,0104h
	out	dx,ax

	Kalle=0
	rept	33
	mov	al,[esi+Kalle]
	or	[edi+Kalle*80],al
	Kalle=Kalle+1
	endm

	popad
	ret
PutWhiteKey	EndP

RemWhiteKey	Proc	Near
	pushad
	move	eax,0a0000h+80*185+183
	add	edi,eax


	mov	dx,3c4h 		;Write mask register
	mov	ax,0202h
	out	dx,ax			;Read mask
	mov	dx,3ceh
	mov	ax,0104h
	out	dx,ax

	Kalle=0
	rept	33
	mov	al,[esi+Kalle]
	not	al
	and	[edi+Kalle*80],al
	Kalle=Kalle+1
	endm

	popad
	ret
RemWhiteKey	EndP

PutBlackKey	Proc	Near
	pushad
	move	eax,0a0000h+80*185+183
	add	edi,eax

	mov	dx,3c4h 		;Write mask register
	mov	ax,0202h
	out	dx,ax			;Read mask
	mov	dx,3ceh
	mov	ax,0104h
	out	dx,ax

	Kalle=0
	rept	21
	mov	ah,[esi+Kalle]
	mov	al,0
	rol	ax,4
	or	[edi+Kalle*80],ax
	Kalle=Kalle+1
	endm

	popad
	ret
PutBlackKey	EndP

RemBlackKey	Proc	Near
	pushad
	move	eax,0a0000h+80*185+183
	add	edi,eax

	mov	dx,3c4h 		;Write mask register
	mov	ax,0202h
	out	dx,ax			;Read mask
	mov	dx,3ceh
	mov	ax,0104h
	out	dx,ax

	Kalle=0
	rept	21
	mov	ah,[esi+Kalle]
	mov	al,0
	rol	ax,4
	not	ax
	and	[edi+Kalle*80],ax
	Kalle=Kalle+1
	endm

	popad
	ret
RemBlackKey	EndP

;2424: (64*3+10)*4*3

UseDefVol0:
	mov	esi,202*0
	jmp	UseDefVol
UseDefVol1:
	mov	esi,202*1
	jmp	UseDefVol
UseDefVol2:
	mov	esi,202*2
	jmp	UseDefVol
UseDefVol3:
	mov	esi,202*3
	jmp	UseDefVol
UseDefVol:
	mov	[DragBarData+(13*4)*6+0],0
	add	esi,UserDefEnv
	mov	Envelope,0
	mov	FileEdited,1
	call	SetUseDefined
	mov	OldVolEnvStartCoord,-1
	cmp	MouseB,1
	ja	NoUltra
	mov	VolEnvStartCoord,0
	mov	CurrentVolPoint,0
NoUltra:
	call	UpdateEnvelopeScreen
	call	fixbutton
	ret


UseDefPan0:
	mov	esi,202*4
	jmp	UseDefPan
UseDefPan1:
	mov	esi,202*5
	jmp	UseDefPan
UseDefPan2:
	mov	esi,202*6
	jmp	UseDefPan
UseDefPan3:
	mov	esi,202*7
	jmp	UseDefPan
UseDefPan:
	mov	[DragBarData+(13*4)*7+0],0
	add	esi,UserDefEnv
	mov	Envelope,1
	mov	FileEdited,1
	call	SetUseDefined
	mov	OldPanEnvStartCoord,-1
	cmp	MouseB,1
	ja	NoUltra2
	mov	CurrentPanPoint,0
	mov	PanEnvStartCoord,0
NoUltra2:
	call	UpdateEnvelopeScreen
	call	fixbutton
	ret



SetUseDefined	Proc	Near
	cmp	MouseB,1
	ja	GetUseDefined
	pushad
	movzx	eax,CurrentInstrument
	GetOffset eax,edi,ENV_VolSpeed
	mov	bx,1111110111111100b
	cmp	Envelope,0
	jz	YesUltra
	mov	bx,1111101111100111b
	cmp	PanOrVib,0
	jz	YesUltra
	add	esi,202*4
	mov	bx,1111011100111111b
YesUltra:
	dec	eax
	mov	ecx,716
	mul	ecx
	add	eax,InstrumentInfo
	mov	ecx,eax

	lodsw
	and	word ptr [ecx+120],bx
	or	word ptr [ecx+120],ax

	lodsb
;	cmp	al,-1
;	jz	KK_Skip3
;	mov	byte ptr [ecx+122],al
;KK_Skip3:
	lodsw
	cmp	ax,-1
	jz	KK_Skip4
	cmp	Envelope,0	;Vol
	jz	PreserveAmp2
	cmp	PanOrVib,0	;Pan
	jz	KK_Skip4
	and	ax,0f000h	;Vib
	and     word ptr [ecx+123],0fffh
	or	word ptr [ecx+123],ax
	jmp	KK_Skip4
PreserveAmp2:
	and	ax,0fffh
	and     word ptr [ecx+123],0f000h
	or	word ptr [ecx+123],ax
KK_Skip4:

	mov	cl,[esi+1]
	inc	cl
	and	ecx,0ffh
	lea	ecx,[ecx+ecx*2]
	add	ecx,5
	rep	movsb

	mov	[DragBarData+(13*4)*6+4],1
	mov	[DragBarData+(13*4)*7+4],1
	mov	OldPanEnvStartCoord,-1
	mov	OldVolEnvStartCoord,-1
	popad
	ret
SetUseDefined EndP

GetUseDefined	Proc	Near
	pushad
	movzx	edi,CurrentInstrument
	GetOffset edi,edi,ENV_VolSpeed
	mov	bx,0000001000000011b
	cmp	Envelope,0
	jz	YesUltra2
	mov	bx,0000010000011000b
	cmp	PanOrVib,0
	jz	YesUltra2
	add	esi,202*4
	mov	bx,0000100011000000b
YesUltra2:
	xchg	esi,edi
	movzx	eax,CurrentInstrument
	dec	eax
	mov	ecx,716
	mul	ecx
	add	eax,InstrumentInfo
	mov	ecx,eax

	mov	ax,word ptr [ecx+120]
	and	ax,bx
	stosw
	mov	al,byte ptr [ecx+122]
	stosb
	mov	ax,word ptr [ecx+123]
	stosw

	mov	cl,[esi+1]
	inc	cl
	and	ecx,0ffh
	lea	ecx,[ecx+ecx*2]
	add	ecx,5
	rep	movsb

	mov	[DragBarData+(13*4)*6+4],1
	mov	[DragBarData+(13*4)*7+4],1
	mov	OldPanEnvStartCoord,-1
	mov	OldVolEnvStartCoord,-1

	popad
	ret
GetUseDefined EndP

CheckTable	dd	0,0,0,0
CheckAgainstPopup	Proc	Near
	pushad
	mov	eax,[CheckTable]
	cmp	[PopUpPlane1+8],eax
	jbe	NoClipAgain
	mov	eax,[CheckTable+8]
	cmp	[PopUpPlane1],eax
	jae	NoClipAgain
CheckA_Y:
	mov	eax,[CheckTable+4]
	cmp	[PopUpPlane1+12],eax
	jbe	NoClipAgain

	mov	eax,[CheckTable+12]
	cmp	[PopUpPlane1+4],eax
	jae	NoClipAgain

	stc
	popad
	ret
NoClipAgain:
	clc
	popad
	ret
CheckAgainstPopup	EndP

PrintVibAmp:
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_VolFade
	movzx	ebx,word ptr [ebx]
	shr	ebx,12

	mov	MouseX1,424
	mov	MouseY1,462
	mov	MouseX2,440
	mov	MouseY2,474
	call	MouseOff
	mov	ah,01h
	mov	cl,2
	move	edi,0a0000h+462*80+424/8
	call	PutHex
	call	MouseOn
	call	MouseReset
	ret

VibAmpArrowUp:
	mov	FileEdited,1
	call	fixbutton
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_VolFade
	mov	ax,[ebx]
	mov	bp,ax
	and	bp,0f000h
	and	ax,00fffh
	cmp	bp,03000h
	jz	_ret
	add	bp,01000h
	or	ax,bp
	mov	[ebx],ax
	call	PrintVibAmp
	ret
VibAmpArrowDn:

	mov	FileEdited,1
	call	fixbutton
	movzx	edi,CurrentInstrument
	GetOffset edi,ebx,ENV_VolFade
	mov	ax,[ebx]
	mov	bp,ax
	and	ax,00fffh
	and	bp,0f000h
	jz	_ret
	sub	bp,01000h
	or	ax,bp
	mov	[ebx],ax
	call	PrintVibAmp
	ret

TempUDrag	dd	0
RelNoteUDrag:
	push	eax
	movzx	eax,CurrentSample
	movsx	eax,[RelativeNote+eax]
	add	eax,48
	mov	TempUDrag,eax

	mov	UdragStatus,1
	mov	ValueProPixel,1024*2
	mov	UdragMaxValue,119
	mov	UdragMiniValue,0
	lea	eax,TempUDrag
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,RelNoteUDragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	pop	eax
	ret

RelNoteUDragMeanWhile:
	push	eax ebx
	mov	eax,TempUDrag
	sub	eax,48
	movzx	ebx,CurrentSample
	mov	[RelativeNote+ebx],al
	call	PrintRelNote
	pop	ebx eax
	ret


FadeOutUDrag:
	push	eax
	movzx	ebx,CurrentInstrument
	GetOffset ebx,ebx,ENV_VolFade
	mov	bx,word ptr [ebx]
	and	ebx,0fffh
	mov	TempUDrag,ebx

	mov	UdragStatus,1
	mov	ValueProPixel,1024*14
	mov	UdragMaxValue,0fffh
	mov	UdragMiniValue,0
	lea	eax,TempUDrag
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,FadeOutUDragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	pop	eax
	ret

FadeOutUDragMeanWhile:
	push	eax ebx
	movzx	ebx,CurrentInstrument
	GetOffset ebx,eax,ENV_VolFade
	mov	bx,word ptr [eax]
	and	ebx,0f000h
	or	ebx,TempUDrag
	mov	word ptr [eax],bx
	call	PrintFadeOut
	pop	ebx eax
	ret

VibSweepUDrag:
	ret
Comment #
	push	eax
	movzx	ebx,CurrentInstrument
	GetOffset ebx,ebx,ENV_VibSweep
	mov	UdragVariableOffset,ebx

	mov	UdragStatus,1
	mov	ValueProPixel,1024*3
	mov	UdragMaxValue,0ffh
	mov	UdragMiniValue,0
	mov	UdragVariableSize,1
	call	ButtonHandler
	lea	eax,VibSweepUDragMeanWhile
	mov	UdragMeanWhile,eax
	pop	eax
	ret
VibSweepUDragMeanWhile:
	call	PrintVibSweep
	ret
#
