
FontFileSize	equ	115200	;Also in TRACKER.ASM



;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;				 Show the pcx
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
; Calls:
;	 Eax  = Offset to pcx
;	 PcxX = Target X
;	 PcxY = Target Y
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�


PcxX		dd	0			;target x
PcxY		dd	0			;target y
pcxbuffer	dd	0			;offset to pcxbuffer
pcxplanes	dd	4			;number of planes used
pcxstartand	db	0			;byte to and start of x
pcxendand	db	0			;byte to and end of x
startedi	dd	0			;offset to and pcxstartand
endedi		dd	0			;offset to and pcxendand
pcxesisave	dd	0			;offset to pic
pcxedisave	dd	0			;offset to the screen
pcxecx		dd	0			;number to move in x
pcxbittar	db	0			;bits to xor with one byte
pcxysave	dd	0			;save pcxy
pcxs_x1 	dd	0			;pcx x1
pcxs_y1 	dd	0			;pcx y2
pcxs_x2 	dd	0			;pcx x1
pcxs_y2 	dd	0			;pcx y2
fastpic 	dd	0			;1=faster picput
dwordmove	dd	0
bytemove	dd	0
DatFileSize	dd	0			;Size of DAT file

;savebuggar	 db	 10	 dup(0)
copysavebuff	db	19*4	dup(0)
pcxtable1	db	00000000b,10000000b,11000000b,11100000b
		db	11110000b,11111000b,11111100b,11111110b
pcxtable2	db	01111111b,00111111b,00011111b,00001111b
		db	00000111b,00000011b,00000001b,00000000b



blacktable  dw	8,8,135,71,152,8,191,71,312,8,351,71,368,8,495,71
	    dw	415,89,455,101,415,106,455,118,431,123,455,135,431,140,455,152

PcxXsize	dd	0
ShowThePcx	Proc	Near
	pushad

	mov	esi,eax 			;save source
	movzx	eax,word ptr [esi+4]
	mov	pcxs_x1,eax
	movzx	eax,word ptr [esi+6]
	mov	pcxs_y1,eax
	movzx	eax,word ptr [esi+8]
	mov	pcxs_x2,eax
	movzx	eax,word ptr [esi+10]
	mov	pcxs_y2,eax
	movzx	eax,word ptr [esi+42h]
	mov	pcxXsize,eax




	mov	ecx,pcxs_y2
	sub	ecx,pcxs_y1
	inc	ecx
	add	esi,128
	mov	edi,pcxbuffer

NextUnpack_:
	push	ecx
	mov	ebp,pcxXsize			;UNPACK the picture
	shl	ebp,2
	add	ebp,edi
PcxUnpack_:
	lodsb
	bt	ax,7
	jnc	NotPacked_
	bt	ax,6
	jc	Packed_
NotPacked_:
	stosb
	cmp	edi,ebp
	jz	endpack_
	jmp	PcxUnpack_
Packed_:
	and	al,63
	movzx	ecx,al
	lodsb
	rep	stosb
	cmp	edi,ebp
	jnz	PcxUnpack_
endpack_:
	pop	ecx
	loop	NextUnpack_

	cmp	skipput,0		;skip put
	jz	skipputtanow
	mov	skipput,0
	popad
	ret
skipputtanow:
	cmp	fastpic,1
	jnz	nofastpic
	mov	eax,pcxXsize
	mov	ebx,eax
	shr	eax,2
	mov	dwordmove,eax
	shl	eax,2
	sub	ebx,eax
	mov	bytemove,ebx

	move	ebp,0a0000h
	mov	eax,pcxY
	mov	ebx,80
	mul	ebx
	add	ebp,eax
	mov	eax,pcxX
	shr	eax,3
	add	ebp,eax
	mov	esi,pcxbuffer

	call	mouseoff
	mov	ecx,pcxs_y2
	sub	ecx,pcxs_y1
	inc	ecx
movepicloop__2:
	push	ecx
	mov	ax,0102h		;write plane 0
	mov	dx,3c4h
	out	dx,ax
	mov	ecx,dwordmove
	mov	edi,ebp
	rep	movsd
	mov	ecx,bytemove
	rep	movsb

	mov	ax,0202h		;write plane 1
	mov	dx,3c4h
	out	dx,ax
	mov	ecx,dwordmove
	mov	edi,ebp
	rep	movsd
	mov	ecx,bytemove
	rep	movsb

	mov	ax,0402h		;write plane 2
	mov	dx,3c4h
	out	dx,ax
	mov	ecx,dwordmove
	mov	edi,ebp
	rep	movsd
	mov	ecx,bytemove
	rep	movsb

	mov	ax,0802h		;write plane 3
	mov	dx,3c4h
	out	dx,ax
	mov	ecx,dwordmove
	mov	edi,ebp
	rep	movsd
	mov	ecx,bytemove
	rep	movsb

	add	ebp,80
	pop	ecx
	loop	movepicloop__2
	mov	fastpic,0
	call	mouseon
	popad
	ret
nofastpic:

	mov	eax,pcxy		       ;Save pcxy
	mov	ebx,80
	mul	ebx
	mov	pcxysave,eax

	mov	eax,pcxs_x2			;Prepare ecx
	mov	ebx,pcxx
	mov	ecx,ebx
	shr	ecx,3
	add	ebx,eax
	shr	ebx,3
	sub	ebx,ecx
	dec	ebx
	mov	pcxecx,ebx

	cmp	ebx,0				;Prepare single byte
	jge	noonlyone
	mov	eax,pcxs_x2
	mov	ebx,pcxx
	mov	ecx,ebx
	add	ecx,eax
	mov	eax,ebx
	shr	ebx,3
	shl	ebx,3
	sub	eax,ebx
	mov	ebx,ecx
	shr	ebx,3
	shl	ebx,3
	sub	ecx,ebx
	sub	ecx,eax
	inc	ecx

	mov	bx,7
	sub	bx,ax
	mov	ax,bx
	xor	bx,bx

pcxmakebits:					;Make single xor byte
	bts	bx,ax
	dec	ax
	loop	pcxmakebits
	xor	bl,0ffh
	mov	pcxbittar,bl
noonlyone:

	mov	eax,pcxx		     ;Prepare the shifts
	mov	ebx,eax
	shr	ebx,3
	shl	ebx,3
	sub	eax,ebx
	mov	ebx,eax
	add	eax,32
	add	ebx,8
	mov	byte ptr [ror1+2],al
	mov	byte ptr [ror2+2],al
	mov	byte ptr [ror3+2],al
	mov	byte ptr [rol1+2],bl

	mov	eax,pcxy			;Prepare edi
	mov	ebx,80
	mul	ebx
	mov	ebx,pcxx
	shr	ebx,3
	add	eax,ebx
	move	ebx,0a0000h
	add	eax,ebx
	mov	pcxedisave,eax

	mov	eax,pcxx		     ;Prepare startdots
	mov	ebx,eax
	shr	eax,3
	move	ecx,0a0000h
	add	ecx,eax
	mov	startedi,ecx
	shl	eax,3
	sub	ebx,eax
	mov	al,[ebx+pcxtable1]
	mov	pcxstartand,al

	mov	eax,pcxs_x2			;Prepare enddots
	sub	eax,pcxs_x1
	add	eax,pcxx
	mov	ebx,eax
	shr	eax,3
	move	ecx,0a0000h
	add	ecx,eax
	mov	endedi,ecx
	shl	eax,3
	sub	ebx,eax
	mov	al,[ebx+pcxtable2]
	mov	pcxendand,al

	call	mouseoff

	mov	esi,pcxbuffer

	mov	ecx,pcxs_y2			;Main row loop
	inc	ecx
PcxMoveMainLoop:
	push	ecx


	xor	ebp,ebp 			;Main plane loop
	mov	ecx,pcxplanes
PcxMovePlanes:
	push	ecx
	push	esi

	mov	ah,1				;Set bitplane (write)
	mov	cx,bp
	shl	ah,cl
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax

	mov	dx,3ceh 			;Set bitplane (read)
	mov	ax,bp
	shl	ax,8
	mov	al,4
	out	dx,ax

	mov	edi,pcxedisave			;Set edi

	cmp	pcxecx,0			;Check if one byte
	jl	PutOneByte

	mov	ebx,startedi			;Clear edistart
	add	ebx,pcxysave
	mov	al,pcxstartand
	and	[ebx],al

	mov	ebx,endedi			;Clear ediend
	add	ebx,pcxysave
	mov	al,pcxendand
	and	[ebx],al

	xor	eax,eax 			;Prepare picture move loop
	lodsw
	ror	ax,8
ror1:	ror	eax,99
	mov	bl,pcxstartand
	xor	bl,0ffh
	and	ah,bl
	or	[edi],ah
	inc	edi
	mov	ecx,pcxecx
	cmp	ecx,0
	jz	PcxMoreJump

PcxMoveScreenLoop:				;Picture move loop
rol1:	rol	eax,99
	lodsb
ror2:	ror	eax,99
	mov	[edi],ah
	inc	edi
	loop	PcxMoveScreenLoop
PcxMoreJump:

	mov	bl,pcxendand			;Or the last byte
	xor	bl,0ffh
	and	al,bl
	or	[edi],al

AfterAByte:
	inc	ebp				;Loops the planes
	pop	esi
	pop	ecx
	add	esi,PcxXsize
	loop	PcxMovePlanes

	add	PcxYsave,80			;Loops the row
	add	PcxEdiSave,80
	pop	ecx
	loop	PcxMoveMainLoop

	call	mouseon

	popad
	ret
PutOneByte:					;Ands one byte
	mov	bl,pcxbittar
	and	[edi],bl
	xor	bl,0ffh

	lodsw					;Ors one byte
	ror	ax,8
ror3:	ror	eax,99
	and	ah,bl
	or	[edi],ah
	jmp	AfterAByte
ShowThePcx	EndP

LoadPcxFiles	Proc	Near
	pushad
	mov	eax,320*260		;allocate pcxbuffer
	call	_getmemtwo
	jc	error
	mov	pcxbuffer,eax

	xor	eax,eax 		;check pcx summa bytes
	lea	esi,pcxsize
SummaLoop:
	mov	ebx,[esi]
	cmp	ebx,-1
	jz	nomoresumma
	add	eax,ebx
	add	esi,4
	jmp	summaloop
nomoresumma:
	mov	DatFileSize,eax
	mov	ebx,eax

	lea	edx,picturesfilename	;open file
	call	FixPathFile
	lea	edx,NewFileName
	call	_openfileR
	jc	error

	call	_filesize
	sub	eax,ebx

	mov	bl,0			;seek to the first pcx
	call	_lseekfile
	jc	error

	lea	ebp,pcxsize
	lea	edi,pcxoffsets
LoadFile:
	cmp	dword ptr [ebp],-1	;allocate pcx
	jz	nomoreloadfile
	mov	eax,[ebp]

	call	_getmemtwo
	jc	error
	mov	[edi],eax

	mov	edx,eax 		;read from file
	mov	ecx,[ebp]
	call	_readfile
	jc	error

	add	ebp,4
	add	edi,4
	jmp	loadfile
nomoreloadfile:

	call	_closefile		;close file
error:
	popad
	ret
_getmemtwo:
	push	ebx

;	mov	ebx,lowmemptr
;	add	ebx,eax
;	cmp	ebx,lowmemend
;	jbe	nowallocated1

	mov	ebx,himemptr
	add	ebx,eax
	cmp	ebx,himemend
	jbe	nowallocated2

	pop	ebx
	stc
	ret
;nowallocated1:
;	mov	eax,lowmemptr
;	mov	lowmemptr,ebx
;	pop	ebx
;	clc
;	ret
nowallocated2:
	mov	eax,himemptr
	mov	himemptr,ebx
	pop	ebx
	clc
	ret
LoadPcxFiles	Endp

SecondPopup	dd	0	;-1=calls for none
PopupSave	dw	2	dup(0)
MenuHandler	Proc	Near
	pushad
	cmp	SecondPopup,-1
	jnz	NoPopSecond
	call	poppart
	mov	ax,[PopupSave+2]
	mov	[CurrentMenu],ax
	mov	ax,[PopupSave]
	mov	Menu_Popup,ax
	mov	SecondPopup,0
	call	updateblockbock
	popad
	ret
NoPopSecond:
	cmp	SecondPopup,0
	jz	Noseconda
	mov	ax,Menu_Popup
	mov	[PopupSave],ax
	mov	ax,[CurrentMenu]
	mov	[PopupSave+2],ax
	mov	[CurrentMenu],0
	mov	eax,SecondPopup
	mov	Menu_Popup,ax
Noseconda:

	mov	ax,Menu_Popup			;check if same popup
	cmp	ax,[CurrentMenu]
	jnz	fixpopup

	mov	ax,Menu_DownScreen		;check if MenuDownScreen
	cmp	ax,[CurrentMenu+2]
	jnz	fixMenuDownScreen

	mov	ax,Menu_UpperScreen		;check if MenuUpperScreen
	cmp	ax,[CurrentMenu+4]
	jnz	fixMenuUpperScreen

	mov	ax,Menu_UpperLeft		;check if MenuUpperLeft
	cmp	ax,[CurrentMenu+6]
	jnz	fixMenuUpperLeft

	call	updateblockbock
	popad
	ret
FixMenuDownScreen:				;fix menu down screen
	movzx	ebx,Menu_DownScreen
	shl	ebx,2
	mov	ebp,dword ptr [ebx+Menu_DownScreen_ptr]
	call	ebp
	jmp	menuhandlerend

FixMenuUpperScreen:				 ;fix menu upper screen
	movzx	ebx,Menu_UpperScreen
	shl	ebx,2
	mov	ebp,dword ptr [ebx+Menu_UpperScreen_ptr]
	call	ebp
	jmp	menuhandlerend

FixMenuUpperLeft:				 ;fix menu upper screen
	movzx	ebx,Menu_UpperLeft
	shl	ebx,2
	mov	ebp,dword ptr [ebx+Menu_UpperLeft_ptr]
	call	ebp
	call	PrintSampleInfo
	jmp	menuhandlerend

Fixpopup:					;fix popups

	cmp	Menu_Popup,0
	jnz	Putup_popup

	call	poppart
	jmp	menuhandlerend


noviewpos:

	jmp	menuhandlerend
putup_popup:			    ;put out pop
	call	PutEqualizer
	movzx	ebx,ax
	mov	ebp,[Menu_popup_ptr+ebx*4]
	call	ebp

MenuHandlerEnd: 				;quit Menu Handler
	mov	ax,Menu_Popup
	mov	[CurrentMenu],ax
	mov	ax,Menu_DownScreen
	mov	[CurrentMenu+2],ax
	mov	ax,Menu_UpperScreen
	mov	[CurrentMenu+4],ax
	mov	ax,Menu_UpperLeft
	mov	[CurrentMenu+6],ax

	call	updateblockbock
	popad
	ret
MenuHandler	Endp

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;				 Menu Viewers
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
; Calls: esi=offset to text
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
ViewInfoShit:
	pushad
	push	esi
	lea	esi,ShitPicture
	call	DrawPopUp
	pop	esi

	call	mouseoff
	mov	FontPlane,1
;	lea	esi,
	move	edi,0a0000h
	add	edi,(72)/8+(35)*80
	mov	ecx,11
PutTextLoop1:
	push	ecx

	push	edi
	mov	ecx,60
Puttextloop2:
	push	ecx
	lodsb
	movzx	ebx,al
	mov	ah,00001000b
	call	putcharacter
	inc	edi
	pop	ecx
	loop	puttextloop2

	pop	edi
	add	edi,80*13
	pop	ecx
	loop	puttextloop1
	mov	FontPlane,0
	call	mouseon

	popad
	ret

MemErrorStatus	db	0;1=Mem error popup
ViewPop1:
	pushad
	mov	MemErrorStatus,1
	lea	esi,PopUp1Picture
	call	DrawPopUp
	popad
	ret
ViewPop2:
	pushad
	mov	MemErrorStatus,1
	lea	esi,PopUp2Picture
	call	DrawPopUp
	popad
	ret
ViewPop3:
	pushad
	lea	esi,Pop3Picture
	call	DrawPopUp
	popad
	ret


ClearPopsi:
	pushad
	lea	esi,ClearPicture
	call	DrawPopUp
	popad
	ret

SplitPopup:
	pushad
	lea	esi,SplitPopupPicture
	call	DrawPopUp

	popad
	ret

OptimBits	dw	0

ViewOptimPopup:
	pushad
	lea	esi,OptimPicture
	call	DrawPopUp
	call	SetOptimButtons
	popad
	ret


XMSSaveText	db	'XMS memory Saved:'
GUSSaveText	db	'Sample mem Saved:'
ViewOptimSaved:
	call	ViewPop1
	mov	fontplane,1
	mov	ah,8
	mov	cl,17
	move	edi,0a0000h+80*97+35
	lea	esi,XMSSaveText
	call	printtext
	add	edi,80*12
	lea	esi,GUSSaveText
	call	printtext

	move	edi,0a0000h+80*97+35+18
	mov	cl,8
	mov	ebx,O_MemoryFree
	call	PutDecimal
	add	edi,80*12
	mov	cl,8
	mov	ebx,O_GUS_DramFree
	call	PutDecimal
	mov	fontplane,0
	ret

OptimChanRem:
	btc	OptimBits,0
	jmp	SetOptimButtons
OptimCommRem:
	btc	OptimBits,1
	jmp	SetOptimButtons
OptimPattRem:
	btc	OptimBits,2
	jmp	SetOptimButtons
OptimInstRem:
	btc	OptimBits,3
	jmp	SetOptimButtons
OptimChanCom:
;	btc	OptimBits,4
	jmp	SetOptimButtons
OptimCommCom:
	btc	OptimBits,5
	jmp	SetOptimButtons
OptimPattCom:
	btc	OptimBits,6
	jmp	SetOptimButtons
OptimInstCom:
	btc	OptimBits,7
	jmp	SetOptimButtons

OptimSelAll:
	call	fixbutton
	or	OptimBits,11101111b
	jmp	SetOptimButtons
OptimSelNone:
	call	fixbutton
	and	OptimBits,0f00h
	jmp	SetOptimButtons
OptimSelPatt:
	bts	OptimBits,8
	jmp	SetOptimButtons
OptimSelSong:
	btr	OptimBits,8
	jmp	SetOptimButtons

SetOptimButtons Proc	near
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,204	;Chan Rem
	mov	ButtonX2,258
	mov	ButtonY1,61
	mov	ButtonY2,79
	bt	OptimBits,0
	setnc	bl
	call	ButtonUpDown

	mov	ButtonY1,87	;Comm Rem
	mov	ButtonY2,105
	bt	OptimBits,1
	setnc	bl
	call	ButtonUpDown

	mov	ButtonY1,113	;Patt Rem
	mov	ButtonY2,131
	bt	OptimBits,2
	setnc	bl
	call	ButtonUpDown

	mov	ButtonY1,152	;Inst Rem
	mov	ButtonY2,170
	bt	OptimBits,3
	setnc	bl
	call	ButtonUpDown

	mov	ButtonX1,260	;Chan Com
	mov	ButtonX2,331
;	mov	ButtonY1,61
;	mov	ButtonY2,79
;	bt	OptimBits,4
;	setnc	bl
;	call	ButtonUpDown

	mov	ButtonY1,87	;Comm Com
	mov	ButtonY2,105
	bt	OptimBits,5
	setnc	bl
	call	ButtonUpDown

	mov	ButtonY1,113	;Patt Com
	mov	ButtonY2,131
	bt	OptimBits,6
	setnc	bl
	call	ButtonUpDown

	mov	ButtonY1,152	;Inst Com
	mov	ButtonY2,170
	bt	OptimBits,7
	setnc	bl
	call	ButtonUpDown

	mov	ButtonX1,447	;Patt
	mov	ButtonX2,498
	mov	ButtonY1,113
	mov	ButtonY2,131
	bt	OptimBits,8
	setnc	bl
	call	ButtonUpDown

	mov	ButtonX1,499	;Song
	mov	ButtonX2,555
	bt	OptimBits,8
	setc	bl
	call	ButtonUpDown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	ret
SetOptimButtons EndP



ViewPositionEd:
	pushad
	mov	eax,[PcxOffsets+32]
	mov	pcxx,0
	mov	pcxy,86
	call	ShowThePcx
	popad
	ret
ViewPosition:
	pushad
	mov	eax,[PcxOffsets+16]
	mov	pcxx,0
	mov	pcxy,17
	call	ShowThePcx
	popad
	ret
ViewPatternV1:
	pushad
	call	resetequ
	mov	dword ptr [equalizerinformation],0
	mov	word ptr [equalizerinformation+4],0
	mov	eax,[PcxOffsets]
	mov	pcxx,0
	mov	pcxy,223
;	mov	fastpic,1
	mov	skipput,1
	call	ShowThePcx
;	mov	fastpic,0
	mov	skipput,0
	call	dumpdownscreen
ContinueOnV1:
	mov	OldRow,-1
	mov	OldCurrentChannel,-1
	mov	OldPos,-1
	mov	OldPos2,-1
	mov	OldPatt,-1
	mov	bh,CurrentChannelSave
	mov	bl,Channels
	add	bh,6
	cmp	bl,bh
	jae	QuitKila
	sub	bl,6
	jge	HubbeSkop
	mov	bl,0
HubbeSkop:
	mov	CurrentChannel,bl
QuitKila:
	mov	bl,Channels
	dec	bl
	cmp	bl,CursorChannel
	jae	QuitKila2
	mov	CursorChannel,bl
QuitKila2:

	lea	eax,ArrowsPTUnZoom
	mov	ArrowPositions,eax
	mov	ArrowPointer,0
	mov	Word Ptr [DragBarTable+3*24+4],6
	popad
	ret

ViewPatternV3:
	pushad
	call	resetequ

	mov	eax,[PcxOffsets]
	mov	pcxx,0
	mov	pcxy,223
	mov	skipput,1
	call	ShowThePcx
	mov	skipput,0
	call	dumpdownscreen

	mov	eax,[PcxOffsets+112]
	mov	pcxx,0
	mov	pcxy,352
	call	ShowThePcx
	jmp	ContinueOnV1

ViewPatternV2:
	pushad
	mov	eax,[PcxOffsets+72]
	mov	pcxx,16*8-3
	mov	pcxy,223
	call	ShowThePcx
	mov	skipput,0
	mov	OldRow,-1
	mov	OldCurrentChannel,-1
	mov	OldPos,-1
	mov	OldPos2,-1
	mov	OldPatt,-1
	popad
	ret

ViewPatternV4:
	pushad
	mov	eax,[PcxOffsets+72]
	mov	pcxx,16*8-3
	mov	pcxy,223
	call	ShowThePcx
	mov	skipput,0

	mov	eax,[PcxOffsets+116]
	mov	pcxx,0
	mov	pcxy,352
	call	ShowThePcx

	mov	OldRow,-1
	mov	OldCurrentChannel,-1
	mov	OldPos,-1
	mov	OldPos2,-1
	mov	OldPatt,-1

	mov	dx,3c4h
	mov	ax,0f02h
	out	dx,ax
	mov	ecx,13*15+6
	move	edi,0a0000h+80*261+4
	xor	eax,eax
ClearBuffel:
	stosb
	stosw
	stosd
	stosd
	add	edi,80-11
	loop	ClearBuffel
	popad
	ret

ViewDescEdit:
	pushad
	mov	al,CurrentChannel
	mov	CurrentChannelSave,al
	mov	fastpic,1
	mov	eax,[PcxOffsets+68]
	mov	pcxx,0
	mov	pcxy,223
	call	ShowThePcx
	popad
	ret
ViewEnvEdit:
	pushad
	mov	al,CurrentChannel
	mov	CurrentChannelSave,al
	mov	fastpic,1
	mov	eax,[PcxOffsets+144]
	mov	pcxx,0
	mov	pcxy,223
	call	ShowThePcx
	popad
	ret
ViewTopBar:
	pushad
	mov	eax,[PcxOffsets+12]
	mov	pcxx,0
	mov	pcxy,0
	call	ShowThePcx
	popad
	ret
ViewSampInfo:
	pushad
	mov	eax,[PcxOffsets+20]
	mov	pcxx,0
	mov	pcxy,86
	call	ShowThePcx
	call	printsampleinfo
	popa
	ret
ViewPattInfo:
	pushad
	mov	eax,[PcxOffsets+148]
	mov	pcxx,0
	mov	pcxy,86
	call	ShowThePcx
	popa
	ret
ViewSongCfg:
	pushad
	mov	eax,[PcxOffsets+28]
	mov	pcxx,0
	mov	pcxy,86
	call	ShowThePcx
	popa
	ret
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;				    Dump Pcx
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
; Calls:
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
PcxDumpName	Db 'dumpen.pcx',0
PcxHeader2	Db 10,5,1,1,0,0,0,0,127,2,223,1,128,2,224,1,0,0,0,199,199,199,39,127,171,63,111,155,83,103,139,47,51,87,151,155,191,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,4,80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
PcxLine 	Db 640	dup(0)
DumpEsi 	Dd	0
DumpEcx 	Dd	0
DumpPcx Proc	Near
	pushad
	mov	esi,pcxoffsets		;write header
	lea	edi,pcxheader2
	mov	ecx,128
	rep	movsb
	mov	word ptr [pcxheader2+8],639
	mov	word ptr [pcxheader2+10],479

	lea	edi,pcxheader2
	add	edi,16
	lea	esi,TheColorTable
	mov	ecx,16*3
repmovaloop:
	lodsb
	shl	al,2
	stosb
	loop	repmovaloop

	lea	edx,pcxdumpname 	;create file
	call	_createfile
	jc	dumperror

	lea	edx,pcxheader2
	mov	ecx,128
	call	_writefile
	jc	dumperror

	move	esi,0a0000h
	mov	dumpesi,esi
	mov	ecx,480 		;LineLoop
Dumppcx1:
	push	ecx

	mov	dumpecx,0
	lea	edi,pcxline
	xor	ebp,ebp
	mov	ecx,4
Dumppcx2:				;Plane loop
	push	ecx

	mov	dx,3ceh
	mov	ax,bp
	shl	ax,8
	mov	al,4
	out	dx,ax

	mov	esi,dumpesi
	mov	ecx,80
Dumppcx3:
	lodsb
	bt	ax,7
	jnc	NoPacking
	bt	ax,6
	jc	Packing
NoPacking:
	stosb
	inc	dumpecx
	jmp	packend
Packing:
	mov	ah,193
	ror	ax,8
	stosw
	add	dumpecx,2
Packend:
	loop	dumppcx3

	inc	ebp
	pop	ecx
	loop	dumppcx2

	lea	edx,pcxline
	mov	ecx,dumpecx
	call	_writefile
	jc	dumperror
	add	dumpesi,80
	pop	ecx
	loop	dumppcx1

	call	_closefile

;	call	stoptimer
;	mov	ecx,255
;GLoop:	;int	8h
;	loop	GLoop
;	call	starttimer

dumperror:
	popad
	ret
DumpPcx Endp


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;				 Set Pcx Palette
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
; Calls:
;	eax - pcxoffset
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
Mode_10tab	db	0,1,2,3,4,5,20,7,56,57,58,59,60,61,62,63 ;also 12h
setpcxpal	proc	near
	pushad
	mov	esi,eax

	lea	ebp,mode_10tab
	mov	ecx,16
setloopen:
	mov	dx,3c8h
	mov	al,[ebp]
	out	dx,al
	inc	dx
	lodsb
	out	dx,al
	lodsb
	out	dx,al
	lodsb
	out	dx,al
	inc	ebp
	loop	setloopen

	popad
	ret
setpcxpal	endp


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;				 Popup Handler
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
; Calls:
;	Esi = TextOffset	($=End of text @=New row)
;	Menu_Popup = Popup to display
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
PopupStatus	db	0	;0=No 1=Yes 2=All 3=Cancel
Therow		dd	0
PopOk		db	0	;1=Waiting 0=NoPop-up
SpecialTextOffset	dd	0
SpecialSecondPopup	db	0
TempMouseB	db	0
PopupHandler	Proc	Near
	call	menuhandler
PopupHandler2:
	Pushad
	mov	PopOk,1
	call	mouseoff
	mov	therow,0
errorokayloop:

	mov	ebp,esi
	xor	ecx,ecx
scanrowloop:				;scan bytes in row
	mov	al,[ebp]
	cmp	al,'@'
	jz	endofrow
	cmp	al,'$'
	jz	endofrow
	inc	ebp
	inc	ecx
	jmp	scanrowloop
endofrow:

	move	edi,0a0000h+80*97+22	;prepare edi
	cmp	SpecialTextOffset,0
	jz	NoSpecial
	move	edi,0a0000h
	add	edi,SpecialTextOffset
NoSpecial:
	cmp	menu_popup,16
	jz	settaspeciell16
	cmp	menu_popup,20
	jz	settaspeciell16
	cmp	menu_popup,17
	jnz	skippasettaspeciell16
settaspeciell16:
	move	edi,0a0000h+80*267+14	 ;prepare edi
skippasettaspeciell16:
	add	edi,therow
	mov	eax,53
	sub	eax,ecx
	shr	eax,1
	add	edi,eax
movecharacter:				;move character
	movzx	ebx,byte ptr [esi]
	inc	esi
	cmp	ebx,0
	jnz	Notssdsfds
	mov	ebx,' '
Notssdsfds:
	mov	ah,00001000b
	mov	FontPlane,1
	cmp	SpecialSecondPopup,0
	jz	NoNewPlane
	mov	FontPlane,2
NoNewPlane:
	call	putcharacter
	inc	edi
	loop	movecharacter

	add	therow,80*14
	inc	esi
	cmp	byte ptr [esi-1],'@'
	jz	errorokayloop
	mov	FontPlane,0
	call	mouseon
	mov	ax,MouseB
	mov	TempMouseB,al
TrackerMain2:				;A small main
	cmp	IntsOn,0
	jz	GurraG
	mov	ax,MasterFrequency
	cmp	ax,OldMasterFrequency
	jz	TrackerMain2
GurraG:
	mov	OldMasterFrequency,ax
	cmp	DClickCounter,0
	jz	NoDclickFix2
	dec	DClickCounter
	jg	NoDclickFix2
	mov	DClickCounter,0
	mov	MouseOnceReleased,0
	mov	DoubleClickExpired,1
NoDclickFix2:
	cmp	popok,0
	jz	skipmain
	call	MouseStat
	call	UpdatePattern		;Update the pattern to screen
	call	UpdateDifferentStuff	;Updates DragBars and diff. Digits
	call	KeyBoardHandler 	;Handles all keystrokes
	cmp	TempMouseB,0
	jnz	CheckMouseB
	call	MouseHandler		;Handles all MouseMovements
	jmp	TrackerMain2
SkipMain:
	mov	DClickCounter,0
	Popad
	Ret

CheckMouseB:
	cmp	MouseB,0
	jnz	TrackerMain2
	mov	TempMouseB,0
	jmp	TrackerMain2

Popup_okay:				;popup okay (Mouse)
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
FotFolk:
	mov	PopOk,0
	cmp	SpecialSecondPopup,0
	jz	@@Spec1
	mov	SecondPopup,-1
	call	menuhandler
	mov	PopupStatus,1
	jmp	_retp
@@Spec1:
	mov	menu_popup,0
	call	menuhandler
	mov	PopupStatus,1
	Popad
	Ret

Popup_okay2:				;popup okay2 (Keyboard)
	Pushad
	jmp	FotFolk

Popup_okay3:				;Mouse
	call	Popup_okay
	cmp	menu_popup,0
	jnz	_ret
	call	UpdateInstNames
	ret

Popup_okay4:				;KBD
	call	Popup_okay2
	cmp	menu_popup,0
	jnz	_ret
	call	UpdateInstNames
	ret


Pop_up_yes:				;popup yes (Mouse)
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	nopopupyes

	mov	popok,0
	cmp	SpecialSecondPopup,0
	jz	Spec1
	mov	SecondPopup,-1
	call	menuhandler
	mov	PopupStatus,1
	jmp	_retp
Spec1:

	mov	menu_popup,0
	call	menuhandler
	mov	PopupStatus,1
Nopopupyes:
	popad
	ret

Pop_up_yes2:				;popup yes (Keyboard)
	pushad
	mov	popok,0
	cmp	SpecialSecondPopup,0
	jz	Spec2
	mov	SecondPopup,-1
	call	menuhandler
	mov	PopupStatus,1
	jmp	_retp
Spec2:
	mov	menu_popup,0
	call	menuhandler
	mov	PopupStatus,1
	popad
	ret

Pop_up_no:				;popup no (Mouse)
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	nopopupno

	mov	popok,0
	cmp	SpecialSecondPopup,0
	jz	Spec3
	mov	SecondPopup,-1
	call	menuhandler
	mov	PopupStatus,0
	jmp	_retp
Spec3:
	mov	menu_popup,0
	call	menuhandler
	mov	PopupStatus,0
Nopopupno:
	popad
	ret

Pop_up_no2:				;popup no (Keyboard)
	pushad
	mov	popok,0
	cmp	SpecialSecondPopup,0
	jz	Spec4
	mov	SecondPopup,-1
	call	menuhandler
	mov	PopupStatus,0
	jmp	_retp
Spec4:
	mov	menu_popup,0
	call	menuhandler
	mov	PopupStatus,0
	popad
	ret
Pop_up_cancel:				;popup cancel (Mouse)
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	nopopupno__


	cmp	SpecialSecondPopup,0
	jz	Spec5
	mov	SecondPopup,-1
	call	menuhandler
	mov	PopupStatus,3
	jmp	_retp
Spec5:

	mov	popok,0
	mov	menu_popup,0
	call	menuhandler
	mov	PopupStatus,3
Nopopupno__:
	popad
	ret


Pop_up_cancel2: 			 ;popup cancel (Keyboard)
	pushad
	mov	popok,0

	cmp	SpecialSecondPopup,0
	jz	Spec6
	mov	SecondPopup,-1
	call	menuhandler
	mov	PopupStatus,3
	jmp	_retp
Spec6:

	mov	menu_popup,0
	call	menuhandler
	mov	PopupStatus,3
	popad
	ret
PopupHandler	EndP


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;				 Fade up pal
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
; Calls: ESI = Buffer
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
Fadeupbuff	db	16*3	dup(0)
FadeUpPal	Proc	Near
	Pushad
	mov	setornot,1
	call	settrackerpal
	mov	setornot,0

	mov	ecx,16
Fadeuploop:
	push	esi
	push	ecx

	lea	edi,fadeupbuff
;	lea	esi,colorpal
	mov	ecx,16*3
changeloop:
	lodsb
	add	byte ptr [edi],4
	cmp	byte ptr [edi],al
	jna	noinc
	mov	byte ptr [edi],al
noinc:
	inc	edi
	loop	changeloop

	mov	dx,3dah
@l1__:
	in	al,dx
	test	al,8
	jne	@l1__
@l2__:
	in	al,dx
	test	al,8
	je	@l2__

	lea	eax,fadeupbuff
	call	setpcxpal
	pop	ecx
	pop	esi
	loop	fadeuploop

	Popad
	Ret
FadeUpPal	EndP
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;				 Fade down pal
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
; Calls: EDI = Buffer
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
FadeDownPal	Proc	Near
	Pushad

	mov	ecx,16
Fadeuploop2:
	push	ecx
	push	edi

;	lea	edi,colorpal
	mov	ecx,16*3
changeloop2:
	sub	byte ptr [edi],4
	jnl	noinc2
	mov	byte ptr [edi],0
noinc2:
	inc	edi
	loop	changeloop2

	mov	dx,3dah
@l1__2:
	in	al,dx
	test	al,8
	jne	@l1__2
@l2__2:
	in	al,dx
	test	al,8
	je	@l2__2

	pop	edi
	mov	eax,edi
	call	setpcxpal
	pop	ecx
	loop	fadeuploop2

	mov	dx,3c4h 	;Write mask register
	mov	ax,0f02h
	out	dx,ax

	move	edi,0a0000h
	xor	eax,eax
	mov	ecx,65536/8
	rep	stosd

	Popad
	Ret
FadeDownPal	EndP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;	EAX = Value to add (Transpose)
;	EBX = Channel
;	ECX = Row to Start at
;	EDX = Rows to Transpose
;	EBP = Inst/All (0=inst, 1=all)
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Transpose	Proc	Near
	pushad
	push	word ptr CurrRow
	push	word ptr CursorChannel
	mov	CurrRow,cx
	mov	CursorChannel,bl
	call	CalculateOffset
	mov	bl,CurrentInstrument
TransposeMore:
	cmp	bp,1
	jz	TransposeAll
	cmp	bl,[esi+1]
	jnz	NoTranspose
TransposeAll:
	cmp	byte ptr [esi],2
	jb	NoTranspose
	movzx	cx,byte ptr [esi]
	add	cx,ax
	cmp	cx,2
	jl	TransBottom
	cmp	cx,121
	jb	TransposeIt
	mov	cx,121
	jmp	TransposeIt
TransBottom:
	mov	cx,2
TransposeIt:
	mov	[esi],cl
NoTranspose:
	add	esi,ChRowSize
	dec	edx
	jnz	TransposeMore

	pop	word ptr CursorChannel
	pop	word ptr CurrRow
	popad
	ret
Transpose	Endp

CaugthDragbar	db	0
OldDragPos	dd	0
OldMousePos	dw	0
AmigaLength	dd	0
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;Calls: EBX = # on DragBar to Update
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DragBarHandler	   Proc    Near
	Pushad
	cmp	MouseOnDragBar,0
	jz	NoAmigaDragbar
	cmp	CaugthDragbar,1
	jz	NioFuck
	cmp	AmigaDragbar,0
	jz	NioFuck

	mov	dx,3ceh 	;Read mask register
	mov	ax,0304h
	out	dx,ax
	move	edi,0a0000h
	movzx	eax,MouseY
	dec	ax
	mov	cx,80
	mul	cx
	add	edi,eax
	movzx	eax,MouseX
	shr	eax,3
	add	edi,eax
	test	byte ptr [edi],1
	jz	NoDragbarUnder
	mov	CaugthDragbar,1
	jmp	NioFuck
NoDragbarUnder:
	cmp	AmigaOkay,0
	jz	SkipDragbar2
NioFuck:
	mov	AmigaOkay,0
	movzx	eax,MouseY

	cmp	OldMousePos,ax
	jz	SkipDragBar2
	mov	OldMousePos,ax

	mov	ebp,Dword Ptr [DragBarTable+ebx+10]	;Save Old Pos
	mov	OldDragPos,ebp

	mov	ebp,dword ptr [DragBarTable+ebx+14]	;DLen
	shr	ebp,7+1
	adc	ebp,0

	mov	dx,word ptr [DragBarTable+ebx+22]
	sub	dx,bp
	cmp	ax,dx
	jae	SetToLastValue

	mov	dx,[DragBarTable+ebx+20]		;YStart
	add	dx,bp
	sub	ax,dx
	jle	SetToFirstValue

	mov	ebp,dword ptr [DragBarTable+ebx+6]	;Total
	sub	ebp,ExtraLength
	mul	ebp

	movzx	ebp,word ptr [DragBarTable+ebx+2]	;YLen
	mov	ecx,dword ptr [DragBarTable+ebx+14]	;DLen
	shr	ecx,7
	adc	ecx,0
	sub	ebp,ecx
	jle	SetToFirstValue
	xor	edx,edx
	div	ebp
	mov	Dword Ptr [DragBarTable+ebx+10],eax	;Pos
	jmp	NoNewPos

SetToFirstValue:
	mov	Dword Ptr [DragBarTable+ebx+10],0	;Pos
	jmp	NoNewPos

SetToLastValue:
	mov	eax,dword ptr [DragBarTable+ebx+6]	;Tot V
	sub	eax,ExtraLength
	mov	Dword Ptr [DragBarTable+ebx+10],eax	;Pos

NoNewPos:
	mov	eax,Dword Ptr [DragBarTable+ebx+10]
	cmp	CaugthDragbar,1
	jz	NoAmigaDragBar
	cmp	AmigaDragbar,0
	jz	NoAmigaDragbar
	mov	eax,OldDragPos
	cmp	eax,Dword Ptr [DragBarTable+ebx+10]	;Pos
	jz	NoAmigaDragbar
	ja	DecreaseDragbar
	add	eax,AmigaLength;ExtraLength
	cmp	eax,Dword Ptr [DragBarTable+ebx+6]	;Total
	jbe	NoStartFix3
	mov	eax,Dword Ptr [DragBarTable+ebx+6]	;Total
	sub	eax,AmigaLength;Extralength
	jmp	NoStartFix3

DecreaseDragbar:
	sub	eax,AmigaLength;ExtraLength
	jge	NoStartFix2
	mov	eax,0
NoStartFix2:
	cmp	eax,Dword Ptr [DragBarTable+ebx+10]	;Pos
	jb	NoAmigaDragbar
	mov	Dword Ptr [DragBarTable+ebx+10],eax	;Pos
	jmp	NoAmigaDragbar
NoStartFix3:
	cmp	eax,Dword Ptr [DragBarTable+ebx+10]	;Pos
	ja	NoAmigaDragbar
	mov	Dword Ptr [DragBarTable+ebx+10],eax	;Pos
NoAmigaDragbar:
	movzx	ecx,word ptr [DragBarTable+ebx+2]	;Compute DLen
	movzx	eax,word ptr [DragBarTable+ebx+4]
	shl	eax,7
	mul	ecx
	mov	ecx,dword ptr [DragBarTable+ebx+6]
	div	ecx
	mov	ecx,eax
	movzx	ebp,word ptr [DragBarTable+ebx+2]
	shl	ebp,7
	cmp	ecx,ebp
	jbe	NoFix
	movzx	ecx,word ptr [DragBarTable+ebx+2]
	shl	ecx,7
NoFix:
	cmp	ecx,128*8
	ja	Nope
	mov	ecx,128*8
Nope:
	mov	Dword ptr [DragBarTable+ebx+14],ecx

	movzx	eax,word ptr [DragBarTable+ebx+2]	;Compute Pos
	shl	eax,7
	sub	eax,ecx
	mov	ebp,dword ptr [DragBarTable+ebx+10]
	mul	ebp
	mov	ebp,dword ptr [DragBarTable+ebx+6]
	sub	ebp,ExtraLength
	jle	Ooops
	div	ebp
	jmp	NoOoops
Ooops:
	mov	eax,0
NoOoops:
	shr	eax,7
	adc	eax,0
	mov	ebp,eax
	shl	eax,6
	shl	ebp,4
	add	eax,ebp
	mov	[DragBarTable+ebx+18],ax		;DPos

	call	MouseOff

	mov	dx,3c4h 	;Write mask register
	mov	ax,0802h
	out	dx,ax

	move	eax,0a0000h
	movzx	edi,word ptr [DragBarTable+ebx+0]	;ScrPos
	add	edi,eax

	movzx	eax,word ptr [DragBarTable+ebx+18]	;DPos
	mov	ecx,80
	xor	edx,edx
	div	ecx
	mov	ecx,eax

	movzx	ebp,word ptr [DragBarTable+ebx+2]	;Slot Length
	sub	ebp,ecx
	jecxz	DontClearTop
	xor	al,al
ClearDragBarTop:
	stosb
	add	edi,80-1
	Loop	ClearDragBarTop
DontClearTop:
	mov	eax,dword ptr [DragBarTable+ebx+14]	;DLen
	shr	eax,7
	adc	eax,0
;	 cmp	 eax,5
;	 ja	 Nope
;	 mov	 eax,5
;Nope:
	sub	ebp,eax
	jg	NoSuneFix
	mov	ebp,0
NoSuneFix:
	mov	ecx,eax
	mov	al,-1
PutDragBar:
	stosb
	add	edi,80-1
	Loop	PutDragBar

	mov	ecx,ebp
	inc	ecx
	jecxz	SkipDragBar
	xor	al,al
ClearDragBarBottom:
	stosb
	add	edi,80-1
	Loop	ClearDragBarBottom

SkipDragBar:
	call	MouseOn
SkipDragBar2:
	Popad
	Ret
DragBarHandler	EndP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ArrowUp:
	cmp	PrintBlock,1
	jz	MarkUp
ArrowUp2:
	call	fixbutton
	mov	ax,CurrRow
	dec	ax
	jge	Nubbe2
	xor	ax,ax
	jmp	UpdateNub
Flipper:
	mov	ax,word ptr CurrPattLength
	dec	ax
Nubbe2:
	mov	CurrRow,ax
	mov	GotoRow,ax
	movzx	ebx,CurrPatt2
	call	PattInit
	ret
UpdateNub:
	cmp	WrapPatt,4
	jz	StayAt0
	cmp	WrapPatt,0
	jz	Flipper
	cmp	WrapPatt,3
	jz	NeverWrap
	cmp	WrapPatt,1
	jnz	Wr_NotPlay
	cmp	TuneStopped,0
	jz	Flipper
	jmp	NeverWrap
Wr_NotPlay:
	cmp	TuneStopped,1
	jz	Flipper
NeverWrap:
	movzx	ebx,CurrPosition
	dec	bx
	jge	Nebbe2
	mov	bx,Positions
	dec	bx
Nebbe2:
	mov	CurrPosition,bx
	shl	ebx,1
	add	ebx,PatternOrderPtr
	movzx	ebx,word ptr [ebx]
	mov	ebx,[AllocTable+ebx*8]
	cmp	ebx,0
	jnz	NoEmptyPattern
	mov	ebx,EmptyPattern
NoEmptyPattern:
	movzx	dx,byte ptr [ebx+10]
	sub	dx,ax
	jge	NoUpFix
	mov	dx,0
NoUpFix:
	mov	CurrRow,dx
	mov	GotoRow,dx
	call	PosInit
	mov	oldrow,-1
	ret
StayAt0:
	xor	ax,ax
	jmp	Nubbe2

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ArrowDown:
	cmp	PrintBlock,1
	jz	MarkDn
ArrowDown2:
	call	fixbutton
	mov	ax,CurrRow
	mov	GotoRow,ax
	inc	CurrRow
	mov	oldrow,-1
	call	CheckPattEnd
	mov	ax,CurrRow
	mov	GotoRow,ax
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
StartPatt2:
	call	FixButton
	cmp	MouseB,2
	jz	Dummy
	cmp	MouseB,3
	jz	StartPatt3
StartPatt:
	mov	CurrRow,0
StartPatt3:
	mov	ax,CurrRow
	mov	GotoRow,ax
	mov	ANewSecond,-1
	mov	TuneStopped,1
	call	StopAllVoices
	call	ClearForPlay
	mov	PatternPlay,1
	mov	EditMode,0
	mov	RecMode,0
	call	BackCol
	mov	TuneStopped,0
	mov	OldRow,-1
	mov	OldPattName,-1
	mov	OldPos,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
StartMod2:
	call	FixButton
	cmp	MouseB,2
	jz	Dummy
	cmp	MouseB,3
	jz	StartMod3
StartMod:
	mov	CurrRow,0
StartMod3:
	call	PosInit
	mov	ax,CurrRow
	mov	GotoRow,ax
	and	eax,0ffffh
	mov	nisse,eax
	mov	ANewSecond,-1
	mov	TuneStopped,1
	call	StopAllVoices
	call	ClearForPlay
	mov	PatternPlay,0
	mov	EditMode,0
	mov	RecMode,0
	call	BackCol
	mov	TuneStopped,0
	mov	OldRow,-1
	mov	OldPos,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
StopMod2:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
StopMod:
SampleEdStop:
	mov	TuneStopped,1
	call	StopAllVoices
	call	ClearForPlay
	mov	al,RowAddersav
	mov	RowAdder,al
	mov	RecMode,0
	mov	PrintBlock,0
	mov	PatternPlay,0
	mov	OldInfoTextPtr,-1

	lea	edi,MIDIPriority
	mov	ecx,32
	mov	ax,0
	rep	stosw
	mov	Priority,0

	lea	edi,ChannelMaster		;Reset MasterVols
	mov	ecx,32
	mov	al,127
	rep	stosb
	mov	GlobalVolume,127
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
EditMod:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
	mov	TuneStopped,1
Space:
	cmp	TuneStopped,0
	jz	StopMod
	cmp	Menu_DownScreen,4
	jz	StopMod
	cmp	Menu_DownScreen,6
	jz	StopMod
	cmp	Menu_DownScreen,7
	jz	StopMod
Spc2:	xor	EditMode,1
	call	BackCol
	jmp	StopMOD
Spc3:

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
RecMode db	0
RecSong2:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
RecSong:
	cmp	Menu_DownScreen,4
	jz	Dummy
	cmp	InitInput,0
	jnz	Dummy
	mov	ANewSecond,-1
	mov	TuneStopped,1
	mov	RecMode,1
	mov	RowAdder,0
	call	StopAllVoices
	call	ClearForPlay
	mov	EditMode,1
	call	BackCol
	mov	CurrRow,0
	mov	GotoRow,0
	call	PosInit
	mov	TuneStopped,0
	mov	PatternPlay,0
	mov	OldPos,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
RecPatt2:
;	call	ButtonHandler
;	cmp	eax,0
;	jnz	Dummy
	call	FixButton
	cmp	MouseB,2
	jz	Dummy
	cmp	MouseB,3
	jz	RecPatt3
RecPatt:
	mov	CurrRow,0
RecPatt3:
	mov	ax,CurrRow
	mov	GotoRow,ax
	movzx	ebx,CurrPatt2
	call	PattInit
	cmp	Menu_DownScreen,4
	jz	Dummy
	cmp	Menu_DownScreen,6
	jz	Dummy
	cmp	InitInput,0
	jnz	Dummy
	mov	ANewSecond,-1
	mov	TuneStopped,1
	mov	RecMode,1
	mov	RowAdder,0
	call	StopAllVoices
	call	ClearForPlay
	mov	EditMode,1
	call	BackCol
	mov	TuneStopped,0
	mov	PatternPlay,1
	mov	OldPos,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SampleUp:
	call	fixbutton
SampleUp2:
	mov	ax,CurrentSample
	and	ax,0fh
	cmp	ax,0fh
	jz	_ret
	inc	ax

	movzx	bx,CurrentInstrument
	shl	bx,4
	add	ax,bx
	mov	CurrentSample,ax

	call	SampleToRAM
	mov	bx,CurrentSampName
	add	bx,8
	cmp	ax,bx
	jnz	IDontIncreaseCSN_f
	inc	CurrentSampName
IDontIncreaseCSN_f:
	mov	OldCurrentSampName,-1
	call	PrintSampleInfo
	cmp	AutoName,0
	jz	Dummy
	call	Getname2
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SampleDn:
	call	fixbutton
SampleDn2:
	mov	ax,CurrentSample
	and	ax,0fh
	jz	_ret
	dec	ax

	movzx	bx,CurrentInstrument
	shl	bx,4
	add	ax,bx
	mov	CurrentSample,ax

	call	SampleToRAM
	mov	bx,CurrentSampName
	dec	bx
	cmp	ax,bx
	jnz	IDontDecreaseCSN_f
	dec	CurrentSampName
IDontDecreaseCSN_f:
	mov	OldCurrentSampName,-1
	call	PrintSampleInfo
	cmp	AutoName,0
	jz	Dummy
	call	Getname2
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
InstUp:
	call	fixbutton
InstUp2:
	cmp	Sample0,1
	jnz	OFuckSake
	mov	CurrentInstrument,0
OFuckSake:
	mov	Sample0,0
	inc	CurrentInstrument
	cmp	CurrentInstrument,0
	jnz	IAjusde
	dec	CurrentInstrument
	ret
IAjusde:
	mov	al,Samples
	cmp	al,CurrentInstrument
	jae	NotInstMax
	dec	CurrentInstrument
	call	CheckInstEmpty
	jc	Notemp
	ret
Notemp:
	call	AddAnEmptySample2
	ret
NotInstMax:
	mov	al,CurrentInstrument
	push	ax
	movzx	ax,al
	shl	ax,4
	mov	CurrentSample,ax
	mov	CurrentSampName,ax
	pop	ax
	call	SampleToRAM
ScrollInstDn:
	mov	ah,CurrentInstName
	add	ah,13
	cmp	al,ah
	jnz	IDontIncreaseCSN
	inc	CurrentInstName
IDontIncreaseCSN:
	mov	OldCurrentInstName,-1
	call	PrintSampleInfo
	cmp	AutoName,0
	jz	Dummy
	call	Getname2
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
InstDn:
	call	fixbutton
InstDn2:
	movzx	ax,CurrentInstrument
	dec	ax
	jl	_ret
	jg	NotInstZero
	mov	OldCurrentInstrument,-1
	mov	Sample0,1
	jmp	IDontDecreaseCSN
NotInstZero:
	mov	Sample0,0
	mov	CurrentInstrument,al
	push	ax
	movzx	ax,al
	shl	ax,4
	mov	CurrentSample,ax
	mov	CurrentSampName,ax
	pop	ax
ScrollInstUp:
	call	SampleToRAM
	cmp	CurrentInstrument,0
	jz	IDontDecreaseCSN
	mov	ah,CurrentInstName
	cmp	al,ah
	jnz	IDontDecreaseCSN
	dec	CurrentInstName
IDontDecreaseCSN:
	mov	OldCurrentInstName,-1
	call	PrintSampleInfo
	cmp	AutoName,0
	jz	Dummy
	call	Getname2
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
IncreasePosition:
	call	fixbutton
IncreasePosition2:
	mov	ax,CurrPosition
	inc	ax
	cmp	ax,Positions
	jz	_ret
	inc	CurrPosition
	jmp	Contpos
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DecreasePosition:
	call	fixbutton
DecreasePosition2:
	movzx	eax,CurrPosition
	cmp	ax,0
	jz	Dummy
	dec	CurrPosition
ContPos:
	mov	OldPos,-1
	cmp	ProTrackerEditing,0
	jz	NoPT
	cmp	TuneStopped,0
	jz	NoPT
	movzx	ebx,CurrPosition
	shl	ebx,1
	add	ebx,PatternOrderPtr
	movzx	ebx,word ptr [ebx]
	mov	CurrPatt,bx
	jmp	Dummy
NoPT:
	mov	OldRow,-1
	mov	OldPatt,-1
	mov	OldPatt2,-1
	mov	OldPattName,-1

	cmp	JumpToStart,0
	jz	OrdPos
	mov	ax,CurrRow
	mov	GotoRow,ax
	call	PosInit
	ret
OrdPos:
	call	StopAllVoices
	call	ClearForPlay
	mov	CurrRow,0
	call	PosInit
	mov	GotoRow,0
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DecreaseInstNames:
	call	fixbutton
	mov	al,CurrentInstName
	cmp	al,0
	jz	Dummy
	dec	al
	mov	CurrentInstName,al
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
IncreaseInstNames:
	call	fixbutton
	movzx	ax,CurrentInstName
	movzx	bx,Samples
	sub	bx,12
	jl	Dummy
	cmp	ax,bx
	jae	Dummy
	inc	ax
	mov	CurrentInstName,al
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴


TrackerEnd:
	cmp	AutoSave,32
	jz	@@NoSaveCfg
	call	saveconfig
@@NoSaveCfg:
	lea	esi,ExitTracker
	cmp	FileEdited,0
	jz	Nosrils
	lea	esi,SongEdited2
Nosrils:
	mov	Menu_Popup,2
	call	PopUpHandler
	cmp	PopupStatus,0
	jz	Dummy
QuickTrackerEnd:
	cmp	EndSampleModeAll,0
	jz	SkipStoppas2
	call	CD_Stop2
SkipStoppas2:
	call	StopTimer
	call	DeInitSoundCard
	call	RestoreVector24
	call	SetOldInt9
	call	SetDrivePath
	lea	edi,TheColorTable
	call	fadedownpal

	mov	ax,3h		;Set Text Mode
	int	10h
	cmp	ResetTracker,1
	jz	ContQuickReset

	lea	edx,EndText2	;Endtext Print -------------------
	mov	ah,9
	int	21h

	lea	esi,EndText
	mov	ecx,81
	mov	ah,01fh
	move	edi,0b8000h
@@PutTextLoop:
	lodsb
	stosw
	loop	@@PutTextLoop

	mov	ah,01eh
	mov	ecx,78
@@PutTextLoop2:
	lodsb
	stosw
	loop	@@PutTextLoop2

	mov	ah,01fh
	mov	ecx,9*80+1	;Final
@@PutTextLoop3:
	lodsb
	stosw
	loop	@@PutTextLoop3



ContQuickReset:
	mov	ax,gs:[41ah]	;Clear KBD buffer
	mov	gs:[41ch],ax

	mov	byte ptr gs:[417h],0;Depress Ctrl+Alt
	mov	byte ptr gs:[418h],0

l5:	in	al,64h			;Turn Off Kbd LED
	test	al,2
	jnz	l5
	mov	al,0edh
	out	60h,al
l6:	in	al,64h
	test	al,2
	jnz	l6
	mov	al,0
	out	60h,al

	cmp	ResetTracker,1
	jz	Reset

	jmp	_exit
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MouseOnDragBar	db	0
PatternDrag:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PositionDrag:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,2
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SampleNamesDrag:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,3
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ChannelDrag:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,4
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DiscOpDrag:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,5
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MasterVolumeDrag:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,6
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Sampeditdrag:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,7
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Desceditdrag:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,9
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Optiondrag1:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,38
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Optiondrag2:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,39
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
keyconfigdrag:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,10
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag11:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,11
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag12:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,12
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag13:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,13
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag14:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,14
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag15:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,15
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag16:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,16
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag17:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,17
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag18:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,18
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag19:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,19
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag20:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,20
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag21:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,21
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag22:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,22
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag23:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,23
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag24:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,24
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag25:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,25
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag26:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,26
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag27:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,27
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag28:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,28
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag29:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,29
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ColorsDrag30:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,30
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PositionEdPositionDrag:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,8
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
EnvEdSampleDrag:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,40
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
HelpScreenDrag:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,41
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MasterVolumeArrowDn:
	call	fixbutton
	mov	al,Mastervolume
	dec	al
	jl	Dummy
	dec	Mastervolume
	mov	EnvVolCheck,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MasterVolumeArrowUp:
	call	fixbutton
	mov	al,Mastervolume
	inc	al
	and	al,127
	jz	Dummy
	inc	Mastervolume
	mov	EnvVolCheck,-1
	ret


CtrlPress	db	0
ShiftPress	db	0
AltPress	db	0
PressCheck	db	0
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
InstNameSquare:
	movzx	eax,MouseY
	sub	eax,20
	mov	ebx,12
	xor	edx,edx
	div	ebx
	inc	eax
	movzx	ebx,CurrentInstName
	add	ebx,eax
	cmp	bl,Samples
	ja	_ret

	mov	LeftKeyWait,3
	cmp	Sample0,1
	jz	SqDoit
	cmp	CurrentInstrument,bl
	jz	ContInst
SqDoit:
	mov	LeftKeyWait,2
	mov	Sample0,0
	mov	CurrentInstrument,bl
	mov	[DragBarData+(13*4)*6+0],0	;Clear Env Pos
	mov	[DragBarData+(13*4)*7+0],0
	push	ax
	movzx	ax,bl
	shl	ax,4
	mov	CurrentSample,ax
	mov	CurrentSampName,ax
	mov	OldCurrentInstName,-1
	pop	ax
ContInst:
	cmp	[DragNumber+8],2	;Samp
	jz	NoDragInstCopy
	cmp	[DragNumber+8],1	;Inst
	jz	CopyMoveInst

	mov	cl,[Keys+1dh]
	mov	CtrlPress,cl
	mov	ch,cl
	mov	cl,[Keys+2ah]
	mov	ShiftPress,cl
	or	ch,cl
	mov	cl,[Keys+38h]
	mov	AltPress,cl
	or	ch,cl
	mov	PressCheck,ch
ContInst2:
	cmp	ShiftPress,1
	jnz	NoDragInstMove
	and	ebx,0ffh
	mov	[DragNumber],1		;Move
	mov	[DragNumber+4],ebx	;Nr
	mov	[DragNumber+8],1	;Inst
	mov	LeftKeyWait,100
NoDragInstMove:
	cmp	CtrlPress,1
	jnz	NoDragInstCopy
	and	ebx,0ffh
	mov	[DragNumber],2		;Copy
	mov	[DragNumber+4],ebx	;Nr
	mov	[DragNumber+8],1	;Inst
	mov	LeftKeyWait,100
NoDragInstCopy:
	cmp	AltPress,1
	jnz	NoDragShadow
	and	ebx,0ffh
	mov	[DragNumber],3		;Shadow
	mov	[DragNumber+4],ebx	;Nr
	mov	[DragNumber+8],1	;Inst
	mov	LeftKeyWait,100

NoDragShadow:
	cmp	LeftKeyWait,2
	jnz	DontDoitInst
	call	SampleToRAM
	call	PrintSampleInfo
	mov	UpdateMouse,80h
DontDoitInst:
	cmp	MouseB,2
	jnz	Dummy

	mov	OldCurrentInstrument,bl
	mov	bl,CurrentInstName
	mov	OldCurrentInstName,bl

	mov	InstNameInput,1
	call	UpdateInstNames
	dec	eax
	mov	ebx,12*80
	mul	ebx
	add	eax,21*80+376/8
	mov	edi,eax
	mov	esi,InstNamesPtr
	movzx	eax,CurrentInstrument
	GetOffset eax,ebx,ENV_Shadow
	cmp	byte ptr [ebx],0

	pushf
	dec	eax
	mov	ebx,30
	mul	ebx
	add	esi,eax
	mov	ax,0103h
	popf
	jz	@@NoShadow
	mov	ax,0703h
@@NoShadow:
	mov	ecx,30
	call	InputRoutine
	ret

Temp_Eax	dd	0
CopyMoveInst:
	mov	ShiftPress,0
	mov	CtrlPress,0
	mov	AltPress,0
	mov	PressCheck,0
	cmp	[DragNumber],2
	jz	CopyInst
	cmp	[DragNumber],3
	jz	ShadowInst		;Shadow

	mov	ebp,[DragNumber+4]
	mov	edx,ebx
	cmp	ebp,edx
	jz	QuitCopyMoveInst
	GetOffset ebp,eax,ENV_Shadow
	cmp	byte ptr [eax],bl
	jz	QuitCopyMoveInst
	call	UpdateEnvelopeScreen
	call	PrintSampleInfo

	push	ebx edx ebp
	mov	O_InProgress,1
	call	AskKillInst
	mov	O_InProgress,0
	pop	ebp edx ebx
	jc	QuitCopyMoveInst

	call	CopyInstrument		;ebp->edx
	call	UpdateEnvelopeScreen


	push	edx ebp
	mov	DontDisallocSample,1
	mov	edx,ebp
	mov	CurrentInstrument,dl
	push	ebx
	mov	O_InProgress,1
	call	KillInst2
	call	SetInitialEnvelopes
	mov	O_InProgress,0
	pop	ebx
	mov	CurrentInstrument,bl
	and	bx,0ffh
	shl	bx,4
	mov	CurrentSample,bx
	mov	DontDisallocSample,0
	pop	ebp edx

	call	MoveShadows
	call	UpdateShadows

	jmp	QuitCopyMoveInst

ShadowInst:
	mov	ebp,[DragNumber+4]
	GetOffset ebp,eax,ENV_Shadow
	cmp	byte ptr [eax],bl
	jz	QuitCopyMoveInst

CopyInst:
	mov	ebp,[DragNumber+4]
	cmp	ebp,ebx
	jz	QuitCopyMoveInst
	call	UpdateEnvelopeScreen
	call	PrintSampleInfo

	push	ebx ebp
	mov	O_InProgress,1
	push	DragNumber
	call	AskKillInst
	pop	DragNumber
	mov	O_InProgress,0
	pop	ebp ebx
	mov	edx,ebx
	jc	QuitCopyMoveInst
	call	CopyInstrument
	call	UpdateEnvelopeScreen

	cmp	[DragNumber],3
	jz	QuitShadowSample

	call	MouseHourGlass
	mov	ebp,ebx
	shl	ebp,4
	mov	ecx,16
CopyInstLoopen:
	push	ecx
	mov	CurrentSample,bp
	mov	ecx,[SampleOffsetEnd+ebp*4]
	sub	ecx,[SampleOffsetStart+ebp*4]
	jz	DontCopyThisSample

;--..--
	push	ecx
	mov	eax,ecx
	mov	cl,[VoiceControl+ebp]
	bt	cx,2
	setc	cl
	shl	eax,cl
	pop	ecx
;--..-- 			;ecx=samples, eax=bytes
	mov	Temp_Eax,ecx

	push	ebp
	mov	ebp,1024
	xor	ebx,ebx
	call	MemAlloc
	pop	ebp
	jc	MemFullErrs

	mov	ebx,eax
	mov	eax,[SampleOffsetStart+ebp*4]
	mov	dx,128		;Convert
	call	GetSampleFromDRAM

	mov	eax,[SampleOffsetStart+ebp*4]
	mov	[SampleOffsetStart+ebp*4],0
	sub	[LoopStart+ebp*4],eax
	sub	[LoopEnd+ebp*4],eax
	mov	eax,Temp_EAX
	mov	[SampleOffsetEnd+ebp*4],eax

	mov	ebx,ebp
	call	AllocSample
	jc	MemFullErrs
	mov	edx,128
	call	MoveSample

DontCopyThisSample:
	inc	ebp
	pop	ecx
	loop	CopyInstLoopen
	call	MouseArrow
	movzx	ebp,CurrentInstrument
	shl	ebp,4
	mov	CurrentSample,bp

	mov	ebp,1024
	call	MemDisalloc

QuitCopyMoveInst:
	mov	[DragNumber],0		;No Action
	mov	[DragNumber+4],0	;Nr
	mov	[DragNumber+8],0	;Nothing
	mov	MouseCursor,0
	mov	LeftKeyWait,100
	call	SampleToRAM
	mov	UpdateMouse,80h
	call	PrintSampleInfo
	mov	OldCurrentInstName,-1
	ret

QuitShadowSample:
	GetOffset ebp,eax,ENV_Shadow
	cmp	byte ptr [eax],0
	jz	@@NoShadow
	movzx	bp,byte ptr [eax]
@@NoShadow:
	GetOffset ebx,eax,ENV_Shadow
	mov	bx,bp
	mov	byte ptr [eax],bl
	jmp	QuitCopyMoveInst

MemFullErrs:
	mov	DontDisallocSample,1
	call	KillInst2
	mov	DontDisallocSample,0
	mov	ax,GUSDramErr
	jmp	ErrorHandler

ButtonCopyInst:
	cmp	MouseB,1
	jz	@@Good
	mov	MouseB,1
@@Good:
	call	fixbutton
	movzx	eax,CurrentInstrument
	mov	ebx,eax
	call	CheckForShadow
	jc	_ret
	mov	CtrlPress,1
	mov	LeftKeyWait,3
	cmp	[DragNumber+8],2	;Samp
	jz	NoDragInstCopy
	cmp	[DragNumber+8],1	;Inst
	jz	CopyMoveInst
	jmp	ContInst2

ButtonMoveInst:
	cmp	MouseB,1
	jz	@@Good
	mov	MouseB,1
@@Good:
	call	fixbutton
	mov	ShiftPress,1
	mov	LeftKeyWait,3
	movzx	ebx,CurrentInstrument
	cmp	[DragNumber+8],2	;Samp
	jz	NoDragInstCopy
	cmp	[DragNumber+8],1	;Inst
	jz	CopyMoveInst
	jmp	ContInst2

ButtonShadowInst:
	cmp	MouseB,1
	jz	@@Good
	mov	MouseB,1
@@Good:
	call	fixbutton
	mov	AltPress,1
	mov	LeftKeyWait,3
	movzx	ebx,CurrentInstrument
	cmp	[DragNumber+8],2	;Samp
	jz	NoDragInstCopy
	cmp	[DragNumber+8],1	;Inst
	jz	CopyMoveInst
	jmp	ContInst2

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
IncreasePattern3:
	call	fixbutton
IncreasePattern2:
;	cmp	TuneStopped,0
;	jz	Dummy
	movzx	eax,CurrPatt2
	inc	ax
	cmp	ax,1024
	jnz	ContPlutt
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DecreasePattern3:
	call	fixbutton
DecreasePattern2:
;	cmp	TuneStopped,0
;	jz	Dummy
	movzx	eax,CurrPatt2
	cmp	ax,0
	jz	Dummy
	dec	ax
ContPlutt:
	mov	CurrPatt2,ax
ContPlutt2:
	mov	ax,CurrPatt2
	cmp	TuneStopped,0
	jz	ItsRunning
	movzx	ebx,ax
	call	PattInit
	jmp	SkipGr

ItsRunning:
	mov	ah,PatternPlay
	mov	PatternPlay,1
	mov	ax,CurrRow
	mov	GotoRow,ax
WaitGR: cmp	GotoRow,-1
	jnz	WaitGR
	mov	PatternPlay,ah
SkipGr:
	mov	OldRow,-1
	mov	OldPos,-1
	mov	OldPos2,-1
	mov	OldPattName,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
IncreasePattern:
	call	fixbutton
	movzx	ebx,CurrPosition
	shl	ebx,1
	add	ebx,PatternOrderPtr
	mov	ax,[ebx]
	inc	ax
	cmp	ax,1024
	jz	Dummy
	jmp	ContPatt
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DecreasePattern:
	call	fixbutton
	movzx	ebx,CurrPosition
	shl	ebx,1
	add	ebx,PatternOrderPtr
	mov	ax,[ebx]
	cmp	ax,0
	jz	Dummy
	dec	ax
ContPatt:
	mov	CurrPatt,ax
	mov	word ptr [ebx],ax
ContPatt2:
	mov	FileEdited,1
	mov	OldPos,-1
	mov	OldPos2,-1
	cmp	TuneStopped,0
	jz	SkipPTChecken
	cmp	ProTrackerEditing,1
	jz	_ret
SkipPTChecken:
	mov	OldPattName,-1
	mov	OldRow,-1
	mov	CurrRow,0
	mov	GotoRow,0
	call	PosInit
	cmp	TuneStopped,1
	jz	Dummy
	call	StopAllVoices
	call	ClearForPlay
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
IncreaseLength:
	call	fixbutton
	mov	ax,Positions
	inc	ax
	cmp	ax,0
	jz	Dummy
	mov	FileEdited,1
	mov	OldRow,-1
	mov	OldPos,-1
	mov	OldPos2,-1

	push	eax
	movzx	eax,ax
	shl	eax,1
	mov	ebp,1030		;Allocate Positions
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	PatternOrderPtr,eax
	pop	eax
	mov	Positions,ax
	ret

TempDword	dd	0
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DecreaseLength:
	call	fixbutton
DecreaseLength2:
	movzx	eax,Positions
	cmp	ax,1
	jz	CheckNext
	dec	ax
	mov	TempDword,eax
ContLen:
	mov	eax,TempDword

	mov	OldRow,-1
	mov	OldPos,-1
	mov	OldPos2,-1
	mov	FileEdited,1

	push	eax
	movzx	eax,ax
	shl	eax,1
	mov	ebp,1030		;Allocate Positions
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	PatternOrderPtr,eax
	pop	eax
	mov	Positions,ax

	cmp	ax,CurrPosition
	ja	CheckNext
	dec	CurrPosition
	call	PosInit
CheckNext:
	mov	ax,Positions
	sub	ax,8
	jg	MoreThan8
	mov	ax,0
MoreThan8:
	cmp	ax,CurrStartPosition
	ja	Dummy
	dec	CurrStartPosition
	jge	Dummy
	mov	CurrStartPosition,0
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
IncreaseRepBeg2:
	call	fixbutton
	cmp	FormSelect,0
	jz	_ret
IncreaseRepBeg:
	call	fixbutton
	movzx	ebp,CurrentSample
	mov	ebx,[LoopStart+ebp*4]
	inc	ebx
	cmp	EndOrLen,1
	jz	IncreaseRepBeg_Len
	cmp	ebx,[LoopEnd+ebp*4]
	ja	Dummy
	mov	FileEdited,1
	mov	[LoopStart+ebp*4],ebx
	call	PrintSampleInfo
	call	SetSampleLoop
	mov	themovepeg,1
	mov	peghide,0
	call	movethepegs
	ret
IncreaseRepBeg_Len:
	mov	eax,[LoopEnd+ebp*4]
	cmp	eax,[SampleOffsetEnd+ebp*4]
	jae	Dummy
	inc	[LoopEnd+ebp*4]
	mov	[LoopStart+ebp*4],ebx
	call	PrintSampleInfo
	call	SetSampleLoop
	mov	themovepeg,2
	mov	peghide,0
	call	movethepegs
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DecreaseRepBeg2:
	call	fixbutton
	cmp	FormSelect,0
	jz	_ret
DecreaseRepBeg:
	call	fixbutton
	movzx	ebp,CurrentSample
	mov	ebx,[LoopStart+ebp*4]
	dec	ebx
	cmp	ebx,[SampleOffsetStart+ebp*4]
	jl	Dummy
	mov	FileEdited,1
	mov	[LoopStart+ebp*4],ebx
	cmp	EndOrLen,0
	jz	SkipDecreaseRepBeg_Len
	dec	[LoopEnd+ebp*4]
SkipDecreaseRepBeg_Len:
	call	PrintSampleInfo
	call	SetSampleLoop
	mov	peghide,0
	mov	themovepeg,1
	call	movethepegs
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
IncreaseRepEnd2:
	call	fixbutton
	cmp	FormSelect,0
	jz	_ret
IncreaseRepEnd:
	call	fixbutton
	movzx	ebp,CurrentSample
	mov	ebx,[LoopEnd+ebp*4]
	cmp	ebx,[SampleOffsetEnd+ebp*4]
	jae	Dummy
	inc	ebx
	mov	FileEdited,1
	mov	[LoopEnd+ebp*4],ebx
;	or	[VoiceControl+ebp],00001000b
	call	PrintSampleInfo
	call	SetSampleLoop
	mov	themovepeg,2
	mov	peghide,0
	call	movethepegs
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DecreaseRepEnd2:
	call	fixbutton
	cmp	FormSelect,0
	jz	_ret
DecreaseRepEnd:
	call	fixbutton
	movzx	ebp,CurrentSample
	mov	ebx,[LoopEnd+ebp*4]
	dec	ebx
	jl	NoRepeat
	cmp	ebx,[LoopStart+ebp*4]
	jb	NoRepeat
	mov	FileEdited,1
	mov	[LoopEnd+ebp*4],ebx
	jz	NoRepeat
	call	PrintSampleInfo
	call	SetSampleLoop
	mov	peghide,0
	mov	themovepeg,2
	call	movethepegs
	ret
NoRepeat:
	call	PrintSampleInfo
	call	SetSampleLoop
	mov	peghide,0
	call	movethepegs
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
IncreaseC2Rate:
	call	fixbutton
	movzx	ebp,CurrentSample
	cmp	C2Mode,1
	jz	IncreaseC2Rate_2
	cmp	[SampleRates+ebp*2],65525
	jbe	NoC2Fix1
	mov	[SampleRates+ebp*2],65525
NoC2Fix1:
	add	[SampleRates+ebp*2],10
NoC2Fix3:
	mov	FileEdited,1
	call	PrintSampleInfo
	ret
IncreaseC2Rate_2:

	call	GetCurrC2RateInPeriod
	inc	esi
	ConvertNote esi ebx
	mov	eax,428*8363*16
	xor	edx,edx
	div	ebx
	cmp	eax,0ffffh
	ja	NoC2Fix3
	mov	[SampleRates+ebp*2],ax

	call	GetCurrC2RateInPeriod
	add	esi,2
	move	edi,0a0000h+157*80+(80/8)+2
	mov	BitPlane,8
	mov	FileEdited,1
	cmp	Menu_UpperLeft,0
	jnz	_ret
	call	PrintPeriod
	ret


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DecreaseC2Rate:
	call	fixbutton
	movzx	ebp,CurrentSample
	cmp	C2Mode,1
	jz	DecreaseC2Rate_2
	cmp	[SampleRates+ebp*2],522+10
	jae	NoC2Fix2
	mov	[SampleRates+ebp*2],522+10
NoC2Fix2:
	sub	[SampleRates+ebp*2],10
NoC2Fix4:
	mov	FileEdited,1
	call	PrintSampleInfo
	ret
DecreaseC2Rate_2:
	call	GetCurrC2RateInPeriod
	sub	esi,1
	jl	_ret
	ConvertNote esi ebx
	mov	eax,428*8363*16
	xor	edx,edx
	div	ebx
	mov	[SampleRates+ebp*2],ax

	call	GetCurrC2RateInPeriod
	add	esi,2
	move	edi,0a0000h+157*80+(80/8)+2
	mov	BitPlane,8
	mov	FileEdited,1
	cmp	Menu_UpperLeft,0
	jnz	_ret
	call	PrintPeriod
	ret


;out: ax=Period
;     si=Note
GetCurrC2RateInPeriod	Proc	Near
	movzx	ebx,[SampleRates+ebp*2]
	cmp	ebx,0
	jnz	Olofsson
	mov	ebx,522
Olofsson:
	mov	eax,428*8363*16
	xor	edx,edx
	div	ebx
	cmp	eax,57
	jae	NoBiGDeal2
	mov	eax,57
NoBiGDeal2:
	pushad
	mov	ebx,428*8363*16
	xchg	eax,ebx
	xor	edx,edx
	div	ebx
	mov	[SampleRates+ebp*2],ax
	popad

	xor	ecx,ecx
	xor	esi,esi
	mov	edx,10
OuterSearchLoop:
	push	edx
	xor	edi,edi
	mov	edx,12
InnerSearchLoop:
	mov	ebx,[pt_PeriodTable+edi*4]
	shr	ebx,cl
	cmp	eax,ebx
	jae	FoundIt
	inc	esi
	inc	edi
	dec	edx
	jnz	InnerSearchLoop
	inc	ecx
	pop	edx
	dec	edx
	jnz	OuterSearchLoop
	ret
FoundIt:
	pop	ecx
	ret
GetCurrC2RateInPeriod	EndP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
IncreaseFineTune:
	call	fixbutton
	movzx	ebp,CurrentSample
	movzx	ebx,[FineTunes+ebp]
	shl	bx,4
	shr	bl,4
	inc	bl
	cmp	bl,8
	jz	Dummy
	shl	bl,4
	shr	bx,4
	mov	FileEdited,1
	mov	[FineTunes+ebp],bl
	call	PrintSampleInfo
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DecreaseFineTune:
	call	fixbutton
	movzx	ebp,CurrentSample
	movzx	ebx,[FineTunes+ebp]
	shl	bx,4
	shr	bl,4
	dec	bl
	cmp	bl,7
	jz	Dummy
	cmp	bl,0
	jge	Skip6
	add	bl,16
	cmp	bl,8
	jz	Dummy
Skip6:
	shl	bl,4
	shr	bx,4
	mov	FileEdited,1
	mov	[FineTunes+ebp],bl
	call	PrintSampleInfo
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
IncreasePanPot:
	call	fixbutton
	movzx	ebp,CurrentSample
	movzx	ebx,[FineTunes+ebp]
	shl	bx,4
	inc	bh
	cmp	bh,16
	jz	Dummy
	shr	bx,4
	mov	FileEdited,1
	mov	[FineTunes+ebp],bl
	call	PrintSampleInfo
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DecreasePanPot:
	call	fixbutton
	movzx	ebp,CurrentSample
	movzx	ebx,[FineTunes+ebp]
	shl	bx,4
	dec	bh
	jl	Dummy
	shr	bx,4
	mov	FileEdited,1
	mov	[FineTunes+ebp],bl
	call	PrintSampleInfo
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
IncreaseVolume:
	call	fixbutton
	movzx	ebp,CurrentSample
	movzx	ebx,[Volumes+ebp]
	inc	ebx
	and	ebx,127
	jz	Dummy
	mov	FileEdited,1
	mov	[Volumes+ebp],bl
	call	PrintSampleInfo
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DecreaseVolume:
	call	fixbutton
	movzx	ebp,CurrentSample
	movzx	ebx,[Volumes+ebp]
	dec	ebx
	jl	Dummy
	mov	FileEdited,1
	mov	[Volumes+ebp],bl
	call	PrintSampleInfo
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
IncreaseBPM:
	call	fixbutton
	cmp	TempoDisabled,1
	jz	Dummy
	mov	ax,ModTempo
	inc	ah
	cmp	ah,0
	jz	Dummy
	mov	ModTempo,ax
	mov	HertzAdder,ax
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DecreaseBPM:
	call	fixbutton
	cmp	TempoDisabled,1
	jz	Dummy
	mov	ax,ModTempo
	dec	ah
	cmp	ah,32
	jb	Dummy
	mov	ModTempo,ax
	mov	HertzAdder,ax
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
IncChannel:
	call	fixbutton
	cmp	Zoom,1
	jz	IncZoomChannel
	mov	al,CurrentChannel
	mov	ah,Channels
	add	ah,MIDIChannels
	sub	ah,6
	jl	Dummy
	cmp	ah,al
	jz	Dummy
	inc	CurrentChannel
	mov	OldRow,-1
	ret
IncZoomChannel:
	mov	al,CurrentChannel
	mov	ah,Channels
	add	ah,MIDIChannels
	dec	ah
	cmp	ah,al
	jz	Dummy
	inc	CurrentChannel
	inc	CursorChannel
	mov	ArrowPointer,0
	movzx	ebx,CursorChannel
	mov	[Cmd+ebx],0
	mov	OldRow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DecChannel:
	call	fixbutton
	cmp	Zoom,1
	jz	DecZoomChannel
	mov	al,CurrentChannel
	dec	al
	jl	Dummy
	dec	CurrentChannel
	mov	OldRow,-1
	ret
DecZoomChannel:
	mov	al,CurrentChannel
	dec	al
	jl	Dummy
	dec	CurrentChannel
	dec	CursorChannel
	mov	ArrowPointer,0
	movzx	ebx,CursorChannel
	mov	[Cmd+ebx],0
	mov	OldRow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SoloOne:
	movzx	ebx,CursorChannel
	inc	ebx
	jmp	Solo
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MuteOne:
	movzx	ebx,CursorChannel
	jmp	Muted
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Mute1:
	mov	ebx,1
	jmp	Mute7
Mute2:
	mov	ebx,2
	jmp	Mute7
Mute3:
	mov	ebx,3
	jmp	Mute7
Mute4:
	mov	ebx,4
	jmp	Mute7
Mute5:
	mov	ebx,5
	jmp	Mute7
Mute6:
	mov	ebx,6
Mute7:
	cmp	Zoom,0
	jz	NoDisCheck2
	cmp	ebx,1
	jnz	Dummy
NoDisCheck2:
	mov	dl,bl
	add	bl,CurrentChannel
	cmp	bl,Channels
	ja	Dummy

MutePress:
	cmp	MouseB,2
	jz	Solo
	dec	ebx
Muted:
	movzx	ecx,byte ptr [ChanPos+ebx]
	inc	[Mute+ecx]
	cmp	[Mute+ecx],1
	jz	DisableVoice
	cmp	LockEnabled,0
	jz	MuteKoo
	cmp	[Mute+ecx],2
	jz	EnableVoice
MuteKoo:
	mov	[Mute+ecx],0
DisableVoice:
	inc	ecx
	call	StopOneVoice
EnableVoice:
	call	UpdateChannelInfo
	ret
Solo:
	lea	edi,Mute
	mov	ecx,32
	mov	al,1
	rep	stosb

	dec	ebx
	movzx	ecx,byte ptr [ChanPos+ebx]
	mov	[Mute+ecx],0
	mov	eax,ecx
	mov	edx,32
	xor	ecx,ecx
Mutete:
	cmp	eax,ecx
	jz	NoStoppp
	push	ax
	mov	al,Original
	mov	RightKeyWait,al
	pop	ax
	inc	ecx
	call	StopOneVoice
	dec	ecx
NoStoppp:
	inc	ecx
	dec	edx
	jnz	Mutete
	call	UpdateChannelInfo
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

DecreaseAllCmdNr:
	mov	MouseB,2
	jmp	DoAllChannels
IncreaseAllCmdNr:
	mov	MouseB,1
	jmp	DoAllChannels


DecreaseCmdNr:
	mov	MouseB,2
	jmp	Fluffy
IncreaseCmdNr:
	mov	MouseB,1
Fluffy:
	movzx	ebx,CursorChannel
	mov	al,CurrentChannel
	sub	bl,al
	jl	QuitVoice2
	add	al,6
	cmp	bl,al
	jae	QuitVoice2
	inc	ebx
	jmp	IncreaseCmdNr7
IncreaseCmdNr1:
	mov	ebx,1
	jmp	IncreaseCmdNr7
IncreaseCmdNr2:
	mov	ebx,2
	jmp	IncreaseCmdNr7
IncreaseCmdNr3:
	mov	ebx,3
	jmp	IncreaseCmdNr7
IncreaseCmdNr4:
	mov	ebx,4
	jmp	IncreaseCmdNr7
IncreaseCmdNr5:
	mov	ebx,5
	jmp	IncreaseCmdNr7
IncreaseCmdNr6:
	mov	ebx,6
IncreaseCmdNr7:
	cmp	Zoom,1
	jz	QuitVoice2
	mov	dl,bl
	add	bl,CurrentChannel
	cmp	bl,Channels
	ja	QuitVoice2
	dec	ebx
	movzx	ebx,byte ptr [ChanPos+ebx]
	movzx	ecx,byte ptr [Cmd+ebx]
	cmp	MouseB,1
	jz	LeftMB
	push	ax
	mov	al,Original
	mov	RightKeyWait,al
	mov	BothKeyWait,al
	pop	ax
	dec	ecx
	jge	NoMaxChange
	movzx	ecx,Commands
	dec	ecx
	jmp	NoMaxChange
LeftMB:
	inc	ecx
	cmp	cl,Commands
	jb	NoMaxChange
	mov	cl,0
NoMaxChange:
	mov	[Cmd+ebx],cl
	call	UpdateChannelInfo
QuitVoice2:
	mov	MouseB,0
	mov	OldRow,-1
	ret


DoAllChannels:
	cmp	Zoom,1
	jz	QuitVoice2
	xor	ebp,ebp
	movzx	ecx,Channels
ChangeAllChannels:
	push	ecx
	movzx	ebp,byte ptr [ChanPos+ebp]
	movzx	ecx,byte ptr [Cmd+ebp]
	cmp	MouseB,1
	jz	LeftMB2
	mov	al,Original
	mov	RightKeyWait,al
	mov	BothKeyWait,al
	dec	ecx
	jge	NoMaxChange2
	movzx	ecx,Commands
	dec	ecx
	jmp	NoMaxChange2
LeftMB2:
	inc	ecx
	cmp	cl,Commands
	jb	NoMaxChange2
	mov	cl,0
NoMaxChange2:
	mov	[Cmd+ebp],cl
	inc	ebp
	pop	ecx
	loop	ChangeAllChannels
	call	UpdateChannelInfo
	mov	MouseB,0
	mov	OldRow,-1
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
InputModName:
	mov	edi,189*80+376/8
	mov	ecx,30
	mov	ax,0103h
	lea	esi,SongName
	call	InputRoutine
	mov	FileEdited,1
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
InputComposer:
	mov	edi,207*80+376/8
	mov	ecx,30
	mov	ax,0103h
	lea	esi,Composer
	call	InputRoutine
	mov	FileEdited,1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ChanNameInputSlot	db	-1
ChannelName0:
	mov	ebx,1
	mov	edi,226*80+4
	jmp	ChannelName7
ChannelName1:
	mov	ebx,2
	mov	edi,226*80+16
	jmp	ChannelName7
ChannelName2:
	mov	ebx,3
	mov	edi,226*80+28
	jmp	ChannelName7
ChannelName3:
	mov	ebx,4
	mov	edi,226*80+40
	jmp	ChannelName7
ChannelName4:
	mov	ebx,5
	mov	edi,226*80+52
	jmp	ChannelName7
ChannelName5:
	mov	ebx,6
	mov	edi,226*80+64
ChannelName7:
	cmp	Zoom,0
	jz	NoDisCheck1
	cmp	ebx,1
	jnz	Dummy
NoDisCheck1:
	add	bl,CurrentChannel
	cmp	bl,Channels
	ja	Dummy
	dec	ebx
	mov	ChanNameInputSlot,bl
	movzx	ebp,byte ptr [ChanPos+ebx]
	mov	eax,11
	mul	ebp
	add	eax,ChannelNamesPtr
	mov	esi,eax
	mov	ax,0103h
	mov	ecx,11
	call	InputRoutine
	mov	FileEdited,1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PosititonPatternName:
	mov	PatternNameInput,1
	call	CheckPatternStart_Edit
	mov	esi,PatternStart
	sub	esi,12
	mov	edi,208*80+32/8
	mov	ax,0103h
	mov	ecx,10
	call	InputRoutine
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PositionInput:
	mov	edi,21*80+80/8
	mov	ecx,5
	mov	ax,0801h
	movzx	ebx,CurrPosition
	lea	ebp,CurrPosition
	mov	DigitTarget,ebp
	mov	DigitSize,2
	movzx	ebp,Positions
	dec	ebp
	mov	DigitLimit,ebp
	mov	DigitInput,1
	call	InputDigits
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PatternInput:
	mov	edi,38*80+88/8
	mov	ecx,4
	mov	ax,0801h
	movzx	ebx,CurrPatt
	movzx	ebp,CurrPosition
	shl	ebp,1
	add	ebp,PatternOrderPtr
	mov	DigitTarget,ebp
	mov	DigitSize,2
	mov	DigitLimit,1023
	mov	DigitInput,2
	call	InputDigits
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴	;Pattern Info
InputPattern:
	cmp	TuneStopped,0
	jz	Dummy
	mov	edi,191*80+88/8
	mov	ecx,4
	mov	ax,0801h
	movzx	ebx,CurrPatt2
	lea	ebp,CurrPatt2
	mov	DigitTarget,ebp
	mov	DigitSize,2
	mov	DigitLimit,1023
	mov	DigitInput,11
	call	InputDigits
	ret

TempPositions	dw	0
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
LengthInput:
	mov	edi,55*80+80/8
	mov	ecx,5
	mov	ax,0801h
	movzx	ebx,Positions
	mov	TempPositions,bx
	lea	ebp,TempPositions
	mov	DigitTarget,ebp
	mov	DigitSize,2
	mov	DigitLimit,65535
	mov	DigitInput,3
	call	InputDigits
	ret

TempModTempo	dw	0
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
BPMInput:
	cmp	TempoDisabled,1
	jz	Dummy

	movzx	eax,ModTempo	;Decimal part
	and	eax,0ffh
	mov	ecx,26
	xor	edx,edx
	div	ecx
	mov	ebx,eax

	movzx	eax,ModTempo	;Integer part
	shr	eax,8
	mov	ecx,10
	mul	ecx
	add	ebx,eax
	mov	TempModTempo,bx

	mov	DecimalPoint,1
	mov	edi,72*80+10
	mov	ecx,4
	mov	ax,0801h
	lea	ebp,TempModTempo
	mov	DigitTarget,ebp
	mov	DigitSize,2
	mov	DigitLimit,2559
	mov	DigitInput,4
	call	InputDigits
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ToggleBPM:
	cmp	EditMode,1
	jz	InsertBPM
	xor	TempoDisabled,1
	mov	OldBpm,1
	ret
InsertBPM:
	cmp	TempoDisabled,1
	jz	Dummy
	call	CalculateOffset
	movzx	eax,[Cmd+edi]
	shl	eax,1
	add	esi,eax
	add	esi,2
	mov	byte ptr [esi],0fh
	mov	ax,ModTempo
	mov	[esi+1],ah
	mov	oldrow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SampNrInput2:
	mov	edi,106*80+96/8
	jmp	SampNrInput3
SampNrInput:
	mov	edi,89*80+96/8
SampNrInput3:
	mov	ecx,3
	mov	ax,0801h
	add	al,SampHexDec
	movzx	ebx,CurrentInstrument
	mov	Sample0,bl
	lea	ebp,CurrentInstrument
	mov	DigitTarget,ebp
	mov	DigitSize,1
	movzx	ebp,Samples
	mov	DigitLimit,ebp
	mov	DigitInput,5
	call	InputDigits
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
RepBegInput:
	mov	edi,123*80+64/8
	mov	ecx,7
	mov	ax,0801h
	add	al,LenHexDec
	movzx	ebp,CurrentSample
	cmp	EndOrLen,1
	jz	RepBegInput_Len
	mov	ebx,[LoopEnd+ebp*4]
	sub	ebx,[SampleOffsetStart+ebp*4]
;	dec	ebx
;	jg	NoBegFix
;	mov	ebx,0
NoBegFix:
	mov	DigitLimit,ebx
	mov	ebx,[LoopStart+ebp*4]
	sub	ebx,[SampleOffsetStart+ebp*4]
	lea	ebp,LoopStart+ebp*4
	mov	DigitTarget,ebp
	mov	DigitSize,3
	mov	DigitInput,6
	call	InputDigits
	ret
RepBegInput_Len:
	mov	esi,[LoopEnd+ebp*4]
	sub	esi,[LoopStart+ebp*4]
	mov	RepeatLengthSave,esi
;	dec	esi
	mov	ebx,[SampleOffsetEnd+ebp*4]
	sub	ebx,esi
	jg	NoBegFix
	mov	ebx,0
	jmp	NoBegFix
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
RepEndInput:
	mov	edi,140*80+64/8
	mov	ecx,7
	mov	ax,0801h
	add	al,LenHexDec
	movzx	ebp,CurrentSample
	mov	ebx,[SampleOffsetEnd+ebp*4]
	cmp	EndOrLen,1
	jz	RepEndInput_Len
	sub	ebx,[SampleOffsetStart+ebp*4]
;	inc	ebx
	mov	DigitLimit,ebx
	mov	ebx,[LoopEnd+ebp*4]
	sub	ebx,[SampleOffsetStart+ebp*4]
	lea	ebp,LoopEnd+ebp*4
	mov	DigitTarget,ebp
	mov	DigitSize,3
	mov	DigitInput,7
	call	InputDigits
	ret
RepEndInput_Len:
	sub	ebx,[LoopStart+ebp*4]
	inc	ebx
	mov	DigitLimit,ebx
	mov	ebx,[LoopEnd+ebp*4]
	sub	ebx,[LoopStart+ebp*4]
	lea	ebp,LoopEnd+ebp*4
	mov	DigitTarget,ebp
	mov	DigitSize,3
	mov	DigitInput,7
	call	InputDigits
	ret


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
C2RateInput:
	cmp	C2Mode,1
	jz	InputKeybaaa
	mov	edi,157*80+80/8
	mov	ecx,5
	mov	ax,0801h
	movzx	ebp,CurrentSample
	movzx	ebx,word ptr [SampleRates+ebp*2]
	lea	ebp,SampleRates+ebp*2
	mov	DigitTarget,ebp
	mov	DigitSize,2
	mov	DigitInput,8
	mov	DigitLimit,65535
	call	InputDigits
	ret

InputKeybaaa:
	mov	ah,8
	mov	cl,5
	move	edi,0a0000h+157*80+80/8
	lea	esi,Spaces
	call	mouseoff
	call	printtext
	call	mouseon
	mov	KBD4Request,1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
VolumeInput:
	mov	edi,208*80+96/8
	mov	ecx,3
	mov	ax,0801h
	add	al,VolumeHexDec
	movzx	ebp,CurrentSample
	movzx	ebx,[Volumes+ebp]
	lea	ebp,Volumes+ebp
	mov	DigitTarget,ebp
	mov	DigitSize,1
	mov	DigitLimit,127
	mov	DigitInput,10
	call	InputDigits
	ret
Global opel:near
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ArrowPositions	dd	ArrowsPTUnZoom
ArrowsPTUnZoom	db	32/8,64/8,72/8,88/8,96/8,104/8,112/8
ArrowsPTZoom	db	4,8,9 ,11,12,13,14 ,16,17,18,19 ,21,22,23,24 ,26,27,28,29 ,31,32,33,34 ,36,37,38,39 ,41,42,43,44
ArrowPointer	db	0

ArrowLeft:
	cmp	zoom,1
	jz	ArrowLeftPTZoom
	movzx	eax,ArrowPointer
	dec	eax
	jl	ChangeChannel1
	mov	ArrowPointer,al
	mov	oldrow,-1
	ret

ChangeChannel2:
	cmp	zoom,1
	jz	ChangePTZoom2
	mov	ArrowPointer,0
	jmp	Tabbe
ChangeChannel1:
	mov	ArrowPointer,6
Tabbe:
	mov	al,CursorChannel
	dec	al
	jge	NoCursFix1
	mov	al,Channels
	dec	al
	mov	CursorChannel,al
	sub	al,5
	jg	NoMinChanFix
	mov	al,0
NoMinChanFix:
	mov	CurrentChannel,al
	mov	oldrow,-1
	ret
NoCursFix1:
	cmp	al,CurrentChannel
	jae	NoCurrChanFix1
	dec	CurrentChannel
NoCurrChanFix1:
	dec	CursorChannel
	mov	oldrow,-1
	ret

ArrowLeftPTZoom:
	dec	ArrowPointer
	mov	al,ArrowPointer
	jge	NoLastCommand
	movzx	eax,Commands
	shl	eax,2
	add	eax,3
	add	al,ArrowPointer
	mov	ArrowPointer,al
NoLastCommand:
	sub	al,3
	jg	Knusprig1
	mov	al,0
Knusprig1:
	shr	al,2
	movzx	edi,CursorChannel
	mov	[cmd+edi],al
	call	UpdateChannelInfo
	mov	oldrow,-1
	ret

ChangePTZoom2:
	cmp	ArrowPointer,0
	jz	CommandFlurk3
	cmp	ArrowPointer,1
	jz	ArrowLeftPTZoom
	cmp	ArrowPointer,2
	ja	CommandFlurk2
	dec	ArrowPointer
	jmp	ArrowLeftPTZoom
CommandFlurk2:
	sub	ArrowPointer,3
	cmp	ArrowPointer,3
	ja	ArrowLeftPTZoom
	mov	ArrowPointer,1
	jmp	ArrowLeftPTZoom
CommandFlurk3:
	sub	ArrowPointer,3
	jmp	ArrowLeftPTZoom

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

ArrowRight:
	cmp	zoom,1
	jz	ArrowRightPTZoom
	movzx	eax,ArrowPointer
	inc	eax
	cmp	eax,7
	jz	ChangeChannel
	mov	ArrowPointer,al
	mov	oldrow,-1
	ret

ChangeChannel:
	cmp	zoom,1
	jz	ChangePTZoom1
	mov	ArrowPointer,0
	mov	al,CursorChannel
	inc	al
	cmp	al,Channels
	jb	NoCursFix
	mov	CursorChannel,0
	mov	CurrentChannel,0
	mov	oldrow,-1
	ret
NoCursFix:
	mov	ah,CurrentChannel
	add	ah,6
	cmp	al,ah
	jb	NoCurrChanFix
	inc	CurrentChannel
NoCurrChanFix:
	inc	CursorChannel
	mov	oldrow,-1
	ret

ArrowRightPTZoom:
	movzx	ebx,Commands
	shl	ebx,2
	add	ebx,2
	movzx	eax,ArrowPointer
	inc	eax
	cmp	eax,ebx
	jbe	NoFirstCommand
	mov	ArrowPointer,0
	movzx	edi,CursorChannel
	mov	[cmd+edi],0
	call	UpdateChannelInfo
	mov	oldrow,-1
	ret
NoFirstCommand:
	mov	ArrowPointer,al
	sub	al,3
	jg	Knusprig2
	mov	al,0
Knusprig2:
	shr	al,2
	movzx	edi,CursorChannel
	mov	[cmd+edi],al
	mov	oldrow,-1
	call	UpdateChannelInfo
	ret
ChangePTZoom1:
	cmp	ArrowPointer,2
	jz	ArrowRightPTZoom
	cmp	ArrowPointer,2
	ja	CommandFlurk1
	inc	ArrowPointer
	cmp	ArrowPointer,2
	jz	ArrowRightPTZoom
	inc	ArrowPointer
	jmp	ArrowRightPTZoom
CommandFlurk1:
	add	ArrowPointer,3
	jmp	ArrowRightPTZoom

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; in:  CurrRow = Row to calculate offset to
;      CursorChannel = Channel
; out: ESI = Offset
;      EDI = Channel
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CalculateOffset:
	push	eax ebx edx
	call	CheckPatternStart_Edit
	mov	esi,PatternStart
	movzx	eax,CurrRow
	mov	ebx,ChRowSize
	mul	ebx
	add	esi,eax
	movzx	edi,CursorChannel
	movzx	edi,byte ptr [ChanPos+edi]
	mov	eax,RowSize
	mul	edi
	add	esi,eax
	pop	edx ebx eax
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DelNote:
	cmp	EditMode,0
	jz	Dummy
	call	CalculateOffset
	mov	word ptr [esi],0
	movzx	dx,RowAdder
	mov	OldRow,-1
	cmp	RecMode,1
	jz	Dummy
	mov	ax,CurrRow
	mov	GotoRow,ax
	add	CurrRow,dx
	call	CheckPattEnd
	mov	ax,CurrRow
	mov	GotoRow,ax
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DelAll:
	cmp	EditMode,0
	jz	Dummy
	call	CalculateOffset
	mov	ecx,RowSize
	mov	edi,esi
	mov	al,0
	rep	stosb
	movzx	dx,RowAdder
	mov	OldRow,-1
	cmp	RecMode,1
	jz	Dummy
	mov	ax,CurrRow
	mov	GotoRow,ax
	add	CurrRow,dx
	call	CheckPattEnd
	mov	ax,CurrRow
	mov	GotoRow,ax
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DelAllCmd:
	cmp	EditMode,0
	jz	Dummy
	call	CalculateOffset
	movzx	ecx,Commands
	shl	ecx,1
	add	esi,2
	mov	edi,esi
	mov	al,0
	rep	stosb
	movzx	dx,RowAdder
	mov	OldRow,-1
	cmp	RecMode,1
	jz	Dummy
	mov	ax,CurrRow
	mov	GotoRow,ax
	add	CurrRow,dx
	call	CheckPattEnd
	mov	ax,CurrRow
	mov	GotoRow,ax
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DelCmd:
	cmp	[Keys+1dh],1
	jnz	NoReset1
	cmp	[Keys+38h],1
	jnz	NoReset1
	jmp	Reboot
NoReset1:
	cmp	EditMode,0
	jz	Dummy
	call	CalculateOffset
	movzx	eax,[Cmd+edi]
	shl	eax,1
	add	esi,eax
	mov	word ptr [esi+2],0
	movzx	dx,RowAdder
	mov	OldRow,-1
	cmp	RecMode,1
	jz	Dummy
	mov	ax,CurrRow
	mov	GotoRow,ax
	add	CurrRow,dx
	call	CheckPattEnd
	mov	ax,CurrRow
	mov	GotoRow,ax
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
RowAdderTbl	db	0,1,2,4,8,16,-1,10 dup(0)	;max 16 slots
RowAdder	db	0	;Rows to add after inserting a note
RowAdderSav	db	0
RowAdderPtr	dd	0
RowSub:
	call	fixbutton
RowSubKey:
	dec	RowAdderPtr
	jge	RowSubOk
	lea	eax,RowAdderTbl
SearchEndRowSub:
	inc	eax
	cmp	byte ptr [eax-1],-1
	jnz	SearchEndRowSub
	sub	eax,Offset RowAdderTbl+2
	mov	RowAdderPtr,eax
RowSubOk:
	mov	ebx,RowAdderPtr
	mov	al,[RowAdderTbl+ebx]
	jmp	RowAddOk

RowAdd:
	call	fixbutton
RowAddKey:
	inc	RowAdderPtr
RowAdd2:
	mov	ebx,RowAdderPtr
	mov	al,[RowAdderTbl+ebx]
	cmp	al,-1
	jnz	RowAddOk
	mov	RowAdderPtr,0
	mov	al,[RowAdderTbl]
RowAddOk:
	mov	RowAdder,al
	mov	RowAddersav,al
PrintRowAdd:
	cmp	Menu_UpperScreen,0
	ja	_ret
	mov	al,RowAdder
	mov	ah,01h
	mov	cl,2
	move	edi,0a0000h+170*80+296/8
	movzx	ebx,al
	call	mouseoff
	call	PutDecimal
	call	mouseon
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ChangeOctave:
	cmp	MouseB,1
	jz	OctaveUp
	mov	al,Original
	mov	RightKeyWait,al
	cmp	MouseB,2
	jz	OctaveDn
	jmp	dummy
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OctaveDn:
	mov	al,Octave
	cmp	al,0
	jz	Dummy
	dec	Octave
	mov	OldInfoTextPtr,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OctaveUp:
	mov	al,Octave
	cmp	al,8
	jz	Dummy
	inc	Octave
	mov	OldInfoTextPtr,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CutPattern:
	call	StoreUndoBuffer
	call	CheckPatternStart_Edit
	mov	esi,PatternStart
	sub	esi,12

	movzx	ebx,CurrPatt2
	mov	eax,[AllocTable+ebx*8+4]
	mov	ecx,eax

	mov	ebp,1032
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	TempPattern,eax

	mov	edi,eax
	push	esi ecx
	rep	movsb
	pop	ecx esi

	mov	edi,esi
	xor	al,al
	push	ecx
	mov	ecx,10
	rep	stosb
	pop	ecx
	sub	ecx,12
	add	edi,2
	rep	stosb
	mov	OldRow,-1
	mov	oldpatt2,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CopyPattern:
	call	CheckPatternStart_View
	mov	esi,PatternStart
	sub	esi,12
	movzx	ebx,CurrPatt2
	mov	eax,[AllocTable+ebx*8+4]
	mov	ecx,eax

	mov	ebp,1032
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	TempPattern,eax

	mov	edi,eax
	rep	movsb

	mov	OldRow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PastePattern:
	cmp	TempPattern,0
	jz	_ret
	call	StoreUndoBuffer
	call	CheckPatternStart_Edit
	mov	esi,TempPattern

	movzx	ecx,byte ptr [esi+10]	;PattLen
	inc	ecx

	movzx	eax,byte ptr [esi+11]	;Chan+Cmd
	mov	ebx,eax
	and	al,31
	inc	al
	shr	bl,5

	call	GetPatternSize2

	push	eax ebx
	mov	eax,PatternSize2
	add	eax,12

	movzx	ebp,CurrPatt2
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	pop	ebx eax
	mov	Channels,al
	mov	Commands,bl
	mov	CurrPattLength,ecx

	movzx	ebx,Currpatt2
	mov	edi,[AllocTable+ebx*8]
	mov	ecx,[AllocTable+ebx*8+4]
	rep	movsb

	movzx	ebx,CurrPatt2
	call	PattInit
	mov	OldPatt2,-1
	mov	OldRow,-1
	call	FixAllocChannels
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CutChannel:
	call	StoreUndoBuffer
	movzx	eax,CursorChannel
	mov	ecx,0
	mov	edx,CurrPattLength
	mov	ebx,TempChannel
	call	Cut_Channel
	add	ebx,512
	call	Cut_Command
	mov	OldRow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CopyChannel:
	movzx	eax,CursorChannel
	mov	ecx,0
	mov	edx,CurrPattLength
	mov	ebx,TempChannel
	call	Copy_Channel
	add	ebx,512
	call	Copy_Command
	mov	OldRow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PasteChannel:
	call	StoreUndoBuffer
	movzx	eax,CursorChannel
	mov	ecx,0
	mov	edx,CurrPattLength
	mov	ebx,TempChannel
	call	Paste_Channel
	add	ebx,512
	call	Paste_Command
	mov	OldRow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CutCommand:
	call	StoreUndoBuffer
	movzx	eax,CursorChannel
	mov	ecx,0
	mov	edx,CurrPattLength
	mov	ebx,TempCommand
	call	Cut_Command
	mov	OldRow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CopyCommand:
	movzx	eax,CursorChannel
	mov	ecx,0
	mov	edx,CurrPattLength
	mov	ebx,TempCommand
	call	Copy_Command
	mov	OldRow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PasteCommand:
	call	StoreUndoBuffer
	movzx	eax,CursorChannel
	mov	ecx,0
	mov	edx,CurrPattLength
	mov	ebx,TempCommand
	call	Paste_Command
	mov	OldRow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
InsNote4:
InsNote1:
	cmp	EditMode,0
	jz	Dummy
	movzx	eax,CursorChannel
InsNote3:
	mov	ecx,CurrPattLength
	dec	ecx
	cmp	cx,CurrRow
	jz	_ret

	movzx	ecx,CurrRow
	mov	edx,CurrPattLength
	mov	ebx,GUS_TempBuffPtr
	call	Cut_Channel
	add	ebx,512
	call	Cut_Command

	inc	ecx
	mov	edx,CurrPattLength
	mov	ebx,GUS_TempBuffPtr
	call	Paste_Channel
	add	ebx,512
	call	Paste_Command
	mov	OldRow,-1
	cmp	InsertAdd,2
	jb	Dummy
	inc	CurrRow
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
InsNote5:
	nop
InsNote2:
	cmp	EditMode,0
	jz	Dummy
	movzx	eax,CursorChannel
	movzx	ecx,CurrRow

	cmp	InsertAdd,0
	jz	FoAdd
	cmp	InsertAdd,2
	jz	FoAdd
	cmp	ecx,0
	jz	Dummy
FoAdd:
	cmp	InsertAdd,1
	jz	DoAdd
	cmp	InsertAdd,3
	jz	DoAdd
	inc	ecx
DoAdd:
	mov	edx,CurrPattLength
	mov	ebx,GUS_TempBuffPtr
	call	Cut_Channel
	add	ebx,512
	call	Cut_Command

	dec	ecx
	mov	ebx,GUS_TempBuffPtr
	call	Paste_Channel
	add	ebx,512
	call	Paste_Command
	call	CheckPatternStart_Edit
	mov	edi,PatternStart	;Clear
	mov	ebx,RowSize
	movzx	eax,CursorChannel
	mul	ebx
	add	edi,eax
	mov	ebx,ChRowSize
	mov	eax,CurrPattLength
	dec	eax
	mul	ebx
	add	edi,eax
	mov	ecx,RowSize
	xor	al,al
	rep	stosb
	mov	OldRow,-1
	cmp	InsertAdd,0
	jz	Dummy
	cmp	InsertAdd,2
	jz	Dummy
	dec	CurrRow
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PlayRow:
	mov	SkipClickRemoval,1
	mov	PatternPlay,1
	mov	PatternDelay,0
	mov	TuneStopped,1
	movzx	ebx,CurrPatt2
	call	PattInit
	mov	ax,CurrRow
	mov	GotoRow,ax
	mov	pt_counter,0
	mov	TuneStopped,0
ole:
	mov	ah,ModSpeed
	cmp	TuneStopped,1
	jz	brum
	dec	ah
	cmp	ah,pt_counter
	jnz	Ole
	mov	TuneStopped,1
brum:
	mov	SkipClickRemoval,0
	mov	PatternPlay,0
	ret

PlayRow_A:
	mov	SkipClickRemoval,1
	mov	PatternDelay,0
	mov	PatternPlay,1
	mov	TuneStopped,1
	movzx	ebx,CurrPatt2
	call	PattInit
	mov	ax,CurrRow
	mov	GotoRow,ax
	mov	dx,SubFrequency
	mov	pt_counter,0
	mov	TuneStopped,0
ole2:
	mov	ah,ModSpeed
	cmp	TuneStopped,1
	jz	brum2
	dec	ah
	cmp	ah,pt_counter
	jnz	Ole2
	cmp	dx,SubFrequency
	jz	Ole2
brum2:
	mov	PatternPlay,0
	mov	TuneStopped,1
	mov	SkipClickRemoval,0
	mov	ax,CurrRow
	mov	GotoRow,ax
	inc	CurrRow
	call	CheckPattEnd
	mov	ax,CurrRow
	mov	GotoRow,ax
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DumpIt:
	call	DumpPcx
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PositionEditorIns:
	mov	FileEdited,1
	call	fixbutton
	call	PatternEditorInsert
	call	ShowPosList
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PositionEditorDel:
	mov	FileEdited,1
	call	fixbutton
	call	PatternEditorDelete
	call	ShowPosList
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PopUp_Yes:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
PopUp_Yes2:
	mov	popok,0
	mov	PopupStatus,1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PopUp_No:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
PopUp_No2:
	mov	popok,0
	mov	PopupStatus,0
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PopUp_Song:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
PopUp_Song2:
	mov	popok,0
	mov	menu_popup,0
	call	menuhandler
	mov	PopupStatus,0
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PopUp_Samp:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
PopUp_Samp2:
	mov	popok,0
	mov	menu_popup,0
	call	menuhandler
	mov	PopupStatus,4
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PopUp_All:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
PopUp_All2:
	mov	popok,0
	mov	menu_popup,0
	call	menuhandler
	mov	PopupStatus,2
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PopUp_Cancel3:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
PopUp_Cancel4:
	mov	al,CurrInstSave
	mov	CurrentInstrument,al
	push	ax
	movzx	ax,al
	shl	ax,4
	mov	CurrentSample,ax
	mov	CurrentSampName,ax
	pop	ax
	mov	SplitPlay,0
	call	PopUp_Cancel2
	call	PrintSampleInfo
	mov	OldCurrentInstName,-1
	ret
PopUp_Cancel:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
PopUp_Cancel2:
	mov	popok,0
	mov	menu_popup,0
	call	menuhandler
	mov	PopupStatus,3
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

TempChannels	db	0
TempCommands	db	0
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ChannelInput:
	call	CheckPatternStart_Edit
	mov	edi,140*80+104/8
	mov	ecx,2
	mov	ax,0801h
	mov	ebx,PatternStart
	mov	bl,[ebx-1]
	and	ebx,31
	inc	ebx
	lea	ebp,TempChannels
	mov	DigitTarget,ebp
	mov	DigitSize,1
	mov	DigitLimit,32
	mov	DigitInput,13
	call	InputDigits
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ChannelArrowUp:
	call	fixbutton
	call	CheckPatternStart_Edit

	mov	ebx,PatternStart
	mov	al,[ebx-1]
	and	al,31

	cmp	al,31
	jz	Dummy
	add	al,2
	mov	TempChannels,al
	mov	ah,Commands
	mov	TempCommands,ah
	call	FixPatternWidth
	mov	Channels,al

	call	PrintPattInfo
	mov	Oldrow,-1
	mov	OldCurrentChannel,-1
	cmp	al,5
	ja	_ret
	movzx	eax,al
	mov	[DragBarData+116],eax
	mov	[DragBarData+168],eax
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ChannelArrowDn:
	call	fixbutton
	call	CheckPatternStart_Edit

	mov	ebx,PatternStart
	mov	al,[ebx-1]
	and	al,31
	jz	Dummy

	mov	TempChannels,al
	mov	ah,Commands
	mov	TempCommands,ah
	call	FixPatternWidth
	mov	Channels,al
	mov	ah,al

	cmp	CursorChannel,al
	jb	NoDecCursChan
	dec	CursorChannel
NoDecCursChan:
	sub	al,5
	jg	MoreThan6
	mov	al,0
MoreThan6:
	cmp	al,CurrentChannel
	ja	DontDeccas
	dec	CurrentChannel
	jge	DontDeccas
	mov	CurrentChannel,0
DontDeccas:
	call	PrintPattInfo
	mov	Oldrow,-1
	mov	OldCurrentChannel,-1
	movzx	eax,ah
	cmp	al,5
	ja	_ret
	mov	[DragBarData+116],eax
	mov	[DragBarData+168],eax
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CommandsArrowUp:
	call	fixbutton
	call	CheckPatternStart_Edit

	mov	ebx,PatternStart
	mov	al,[ebx-1]
	shr	al,5

	cmp	al,7
	jz	Dummy
	inc	al
	mov	TempCommands,al
CommandCont:
	mov	ah,Channels
	mov	TempChannels,ah
	call	FixPatternWidth
	mov	Commands,al

	call	PrintPattInfo
	mov	Oldrow,-1
	mov	OldCurrentChannel,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CommandsArrowDn:
	call	fixbutton
	call	CheckPatternStart_Edit

	mov	ebx,PatternStart
	mov	al,[ebx-1]
	shr	al,5

	cmp	al,1
	jz	Dummy
	dec	al
	mov	TempCommands,al
	mov	ah,Channels
	mov	TempChannels,ah
	call	FixPatternWidth
	mov	Commands,al

	call	PrintPattInfo
	mov	Oldrow,-1
	mov	OldCurrentChannel,-1
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
BlockStartRow	db	0
BlockEndRow	db	0
PrintBlock	db	0	;If to print BlockInfo
MarkBlockBeg:
	cmp	PrintBlock,1
	jz	MM_UnmarkBlock

	mov	ax,CurrRow
	mov	BlockStartRow,al
	mov	BlockEndRow,al

	call	MM_UnmarkBlock
	movzx	ax,BlockStartRow
	mov	CurrRow,ax

	mov	al,ArrowPointer
	mov	ArrowPointer,0
	call	StartKBDMark
	mov	ArrowPointer,al

	movzx	ax,BlockEndRow
	mov	CurrRow,ax

	mov	PrintBlock,1
	cmp	Menu_UpperScreen,0
	jnz	DO_CalcRow
	push	ax
	mov	ah,8
	mov	cl,14
	move	edi,0a0000h+170*80+160/8
	lea	esi,MarkText
	call	mouseoff
	call	PrintText
	call	mouseon
	mov	OldRow,-1
	pop	ax
DO_CalcRow:
	mov	bl,ArrowPointer
	mov	ArrowPointer,3
	cmp	Zoom,0
	jz	@@NoZ
	mov	bh,Commands
	shl	bh,2
	add	bh,2
	mov	ArrowPointer,bh
@@NoZ:
	pushad
	call	MM_CalcRow
	popad
	mov	ArrowPointer,bl
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CutBlock:
	call	StoreUndoBuffer
	mov	PrintBlock,0
	mov	OldRow,-1
	mov	OldInfoTextPtr,-1
	jmp	CutNewBlock
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CopyBlock:
	mov	PrintBlock,0
	mov	OldRow,-1
	mov	OldInfoTextPtr,-1
	jmp	CopyNewBlock
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PasteBlock:
	call	StoreUndoBuffer
	jmp	PasteNewBlock

JoinPaste	db	0
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
JoinPasteBlock:
	call	StoreUndoBuffer
	jmp	JoinPasteNewBlock
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
InsertBlock:
	call	StoreUndoBuffer
	jmp	InsNewBlock
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
KillToEnd:
	call	StoreUndoBuffer
	movzx	eax,CursorChannel
	movzx	ecx,CurrRow
	mov	edx,CurrPattLength
	sub	edx,ecx
	call	Kill_Channel
	mov	OldRow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
KillSampleAtChannel:
	call	StoreUndoBuffer
	movzx	eax,CursorChannel
	mov	ecx,0
	mov	edx,CurrPattLength
	call	Kill_SampleChannel
	mov	OldRow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ContractOneChannel:
	call	StoreUndoBuffer
	movzx	eax,CursorChannel
	mov	edx,CurrPattLength
	call	ContractChannel
	mov	OldRow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ContractPattern:
	call	MouseHourGlass
	call	StoreUndoBuffer
	movzx	eax,Channels
	dec	eax
ContractMore:
	mov	edx,CurrPattLength
	call	ContractChannel
	dec	eax
	jge	ContractMore
	mov	OldRow,-1
	call	MouseArrow
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ExpandOneChannel:
	call	StoreUndoBuffer
	movzx	eax,CursorChannel
	mov	edx,CurrPattLength
	call	ExpandChannel
	mov	OldRow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ExpandPattern:
	call	MouseHourGlass
	call	StoreUndoBuffer
	movzx	eax,Channels
	dec	eax
ExpandMore:
	mov	edx,CurrPattLength
	call	ExpandChannel
	dec	eax
	jge	ExpandMore
	call	MouseArrow
	mov	OldRow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
GoFirstRow:
	cmp	PrintBlock,1
	jz	MarkHOME
GoFirstRow2:
	mov	OldRow,-1
	cmp	CurrRow,0
	mov	GotoRow,0
	jz	GoFirstChannel
	mov	CurrRow,0
	movzx	ebx,CurrPatt2
	call	PattInit
	ret
GoFirstChannel:
	mov	CursorChannel,0
	mov	CurrentChannel,0
	mov	ArrowPointer,0
	cmp	PrintBlock,0
	jz	_ret
	jmp	MarkBlockBeg
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
GoLastRow:
	cmp	PrintBlock,1
	jz	MarkEND
GoLastRow2:
	mov	eax,CurrPattLength
	dec	eax
	mov	CurrRow,ax
	mov	GotoRow,ax
	movzx	ebx,CurrPatt2
	call	PattInit
	mov	OldRow,-1
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ArrowXDown:
	cmp	STArrow,0
	jz	ArrowDown
	mov	ax,CurrRow
	add	al,RowAdder
	adc	ax,0
	cmp	PrintBlock,1
	jz	Mark_PGDN
	jmp	AddXRows
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ArrowXUp:
	cmp	STArrow,0
	jz	ArrowUp
	movzx	ax,RowAdder
	cmp	PrintBlock,1
	jz	Mark_PGUP
	jmp	SubXRows
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Add32Rows:
	mov	ax,CurrRow
	add	ax,32
	cmp	PrintBlock,1
	jz	Mark_PGDN
	jmp	AddXRows
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Add16Rows:
	mov	ax,CurrRow
	add	ax,16
	cmp	PrintBlock,1
	jz	Mark_PGDN
	jmp	AddXRows
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Add8Rows:
	mov	ax,CurrRow
	add	ax,8
	cmp	PrintBlock,1
	jz	Mark_PGDN
	jmp	AddXRows
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
AddXRows:
	mov	bx,CurrRow
	mov	GotoRow,bx
	mov	CurrRow,ax
	call	CheckPattEnd
	mov	ax,CurrRow
	mov	GotoRow,ax
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Sub32Rows:
	mov	ax,32
	cmp	PrintBlock,1
	jz	Mark_PGUP
	jmp	SubXRows
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Sub16Rows:
	mov	ax,16
	cmp	PrintBlock,1
	jz	Mark_PGUP
	jmp	SubXRows
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Sub8Rows:
	mov	ax,8
	cmp	PrintBlock,1
	jz	Mark_PGUP
	jmp	SubXRows
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SubXRows:
	sub	CurrRow,ax
	jge	Duffy
	neg	CurrRow
	mov	ax,CurrRow
	dec	ax
	cmp	PatternPlay,1
	jz	Duffy
;	cmp	PatternMode,1
	jmp	UpDateNub
Duffy:

	mov	ax,CurrRow
	mov	GotoRow,ax
	movzx	ebx,CurrPatt2
	call	PattInit
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MuteAll:
	call	Fixbutton
MuteAll2:
	lea	edi,Mute
	mov	ecx,32
	mov	al,1
	rep	stosb
	call	StopAllVoices
	call	UpdateChannelinfo
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
UnMuteAll:
	call	Fixbutton
UnMuteAll2:
	lea	edi,Mute
	mov	ecx,32
UnMuteAllLoopen:
	cmp	byte ptr [edi],2
	jz	ChLock
	mov	byte ptr [edi],0
ChLock:
	inc	edi
	loop	UnMuteAllLoopen
	call	UpdateChannelinfo
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DontDisallocSample	db	0


AskKillInst:
	lea	esi,OverWriteInstText
	call	CheckInstEmpty
	jc	KillInst3
	jmp	KillInst2
_ret_stc:
	stc
	ret

KillInstrument2:
	call	FixButton
KillInstrument:
	cmp	Sample0,1
	jz	Dummy

	lea	esi,KillInstText
KillInst3:
	mov	Menu_Popup,2
	call	PopUpHandler
	cmp	PopupStatus,0
	jz	_ret_stc
KillInst2:
	mov	FileEdited,1
	movzx	ebx,CurrentInstrument
	mov	edi,ebx

	shl	ebx,4
	mov	ecx,16
KillNextSample:
	mov	CurrentSample,bx
	mov	esi,[SampleOffsetStart+ebx*4]
	mov	eax,[SampleOffsetEnd+ebx*4]
	sub	eax,esi
	jle	NoSampleHere3
	cmp	DontDisallocSample,1
	jz	NoSampleHere3
	GetOffset edi,ebp,ENV_Shadow
	cmp	byte ptr [ebp],0
	jnz	NoSampleHere3
	call	DisallocSample
NoSampleHere3:
	mov	[SampleOffsetStart+ebx*4],0
	mov	[LoopStart+ebx*4],0
	mov	[LoopEnd+ebx*4],0
	mov	[SampleOffsetEnd+ebx*4],0
	mov	[FineTunes+ebx],0
	mov	[Relativenote+ebx],0
	mov	[SampleRates+ebx*2],8363
	mov	[Volumes+ebx],127
	mov	[VoiceControl+ebx],0
	call	DelSampleRate
	inc	ebx
	loop	KillNextSample

	GetOffset edi,ebp,ENV_Shadow
	mov	byte ptr [ebp],0

	cmp	DontDisallocSample,1
	jz	@@Plupp
	call	UpdateShadows
@@Plupp:

	mov	edi,SampleNamesPtr
	movzx	eax,CurrentInstrument
	mov	CurrentSample,ax
	shl	CurrentSample,4
	dec	eax
	mov	ebx,22*16
	mul	ebx
	add	edi,eax
	mov	ecx,22*16
	xor	ax,ax
	rep	stosb

	mov	edi,InstNamesPtr
	movzx	eax,CurrentInstrument
	dec	eax
	mov	esi,30
	mul	esi
	add	edi,eax
	mov	ecx,30
	xor	ax,ax
	rep	stosb
	cmp	O_InProgress,1
	jz	_ret_clc

	mov	OldCurrentInstName,-1
	mov	OldCurrentSample,-1
	call	PrintSampleInfo
	mov	SampLength,0
	call	SetInitialEnvelopes
	call	UpdateEnvelopeScreen

	call	ViewAll2
_ret_clc:
	clc
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

AskKillSamp:
	movzx	esi,CurrentSample
	mov	eax,[SampleOffsetEnd+esi*4]
	sub	eax,[SampleOffsetStart+esi*4]
	lea	esi,OverWriteSampText
	jle	KillSample2
	jmp	KillSample4

KillSample3:
	call	FixButton
KillSample:
	movzx	eax,CurrentInstrument
	call	CheckForShadow
	jc	_ret

	cmp	Sample0,1
	jz	Dummy
	lea	esi,KillSampleText
KillSample4:
	mov	Menu_Popup,2
	call	PopUpHandler
	cmp	PopupStatus,0
	jz	_ret_stc
KillSample2:
	mov	FileEdited,1
	movzx	eax,CurrentSample
	mov	esi,[SampleOffsetStart+eax*4]
	mov	eax,[SampleOffsetEnd+eax*4]
	sub	eax,esi
	jle	NoSampleHere2
	cmp	DontDisallocSample,1
	jz	NoSampleHere2
	call	DisallocSample
NoSampleHere2:
	movzx	ebx,CurrentSample
	mov	[SampleOffsetStart+ebx*4],0
	mov	[LoopStart+ebx*4],0
	mov	[LoopEnd+ebx*4],0
	mov	[SampleOffsetEnd+ebx*4],0
	mov	[FineTunes+ebx],0
	mov	[SampleRates+ebx*2],8363
	mov	[Relativenote+ebx],0
	mov	[Volumes+ebx],127
	mov	[VoiceControl+ebx],0
	mov	edi,SampleNamesPtr
	call	DelSampleRate
	sub	ebx,16
	mov	eax,22
	mul	ebx
	add	edi,eax
	mov	ecx,22
	xor	ax,ax
	rep	stosb

	mov	OldCurrentInstName,-1
	mov	OldCurrentSample,-1
	call	PrintSampleInfo
	mov	samplength,0
	call	viewsamp
	clc
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ClearGadget:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
	lea	esi,ClearShitty
	mov	Menu_Popup,6
	call	PopUpHandler
	movzx	eax,PopupStatus
	cmp	PopupStatus,3
	jz	Dummy
	mov	FileEdited,1
	cmp	PopupStatus,0
	jz	ClearSong
	cmp	PopupStatus,2
	jz	ClearAllShit
	cmp	PopupStatus,4
	jz	ClearSamples
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
InfoGadget:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
	mov	Menu_Popup,15
	call	menuhandler
	ret

ClearSong:
	call	ClearTheSong
	ret

clearalltext	db	'Would you like to clear everything?$'
ClearAllShit:
	lea	esi,clearalltext
	mov	menu_popup,2
	call	popuphandler
	cmp	popupstatus,0
	jz	_ret

	call	ClearSamples3
	call	ClearTheSong3
	call	ClearDescription2
	mov	OldCurrentInstName,-1
	call	PrintSampleInfo

	lea	edi,SongName		;Clear Song Name
	mov	ecx,30
	xor	al,al
	rep	stosb
	call	PrintModname
	mov	edi,ChannelNamesPtr	;Clear ChannelNames
	mov	ecx,11*64
	xor	al,al
	rep	stosb
	mov	FileEdited,0
	mov	ModSpeed,6
	mov	ModTempo,07d00h
 	mov	InitBPM,07d00h
 	mov	InitSpeed,6
;	mov	HertzMain,0
	mov	HertzAdder,07d00h

	ret

clearsamptext	 db	 'Would you like to clear the instruments?$'
ClearSamples:
	lea	esi,clearsamptext
	mov	menu_popup,2
	call	popuphandler
	cmp	popupstatus,0
	jz	_ret

ClearSamples3:
	call	ClearTheSamples
	mov	SampLength,0
	call	ViewAll2
	mov	CurrentInstrument,1
	mov	CurrentSample,16
	mov	CurrentInstName,1
	mov	CurrentSampName,16
	mov	OldCurrentInstrument,-1

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
	call	PrintSampleInfo
	mov	OldCurrentSampName,-1
	ret

ClearDescText	 db	 'Would you like to clear the Description?$'
ClearDescription:
	lea	esi,ClearDescText
	mov	menu_popup,2
	call	popuphandler
	cmp	popupstatus,0
	jz	_ret
ClearDescription2:
	mov	eax,74			;Clear Desc!
	mov	ebp,1027		;Allocate Desc
	call	MemDisAlloc
	mov	ebx,1
	call	MemAlloc
	mov	dword ptr [DescTable+1*4],0    ;Ptr
	mov	[DescTable+11*4],eax	;Ptr
	mov	[DescTable+12*4],74	;Len
	ret


clearsongtext	 db	 'Would you like to clear the song?$'
ClearTheSong:
	lea	esi,ClearSongText
	mov	menu_popup,2
	call	popuphandler
	cmp	popupstatus,0
	jz	_ret

ClearTheSong3:

	mov	ecx,1024
	xor	ebp,ebp
DisallocAll2:
	call	MemDisalloc
	inc	ebp
	loop	DisallocAll2

	mov	eax,2
	mov	ebp,1030		;Allocate one Position
	mov	ebx,1
	call	MemAlloc
	mov	PatternOrderPtr,eax
	mov	word ptr [eax],0	;Clear 1:st pos

	lea	edi,SongName		;Clear Song Name
	mov	ecx,30
	xor	al,al
	rep	stosb
	call	PrintModname
	mov	edi,ChannelNamesPtr	;Clear ChannelNames
	mov	ecx,11*64
	xor	al,al
	rep	stosb

	mov	al,DefaultCommands
	mov	Commands,al
	mov	al,DefaultChannels
	mov	Channels,al
	mov	AllocChannels,al
	movzx	eax,DefaultRows
	mov	CurrPattLength,eax
	mov	OldRow,-1
	mov	OldPatt,-1
	mov	OldPattName,-1
	mov	OldCurrentChannel,-1
	mov	Positions,1
	mov	OldPos2,-1
	mov	OldPos,-1
	mov	CurrCursorPosition,0
	mov	CurrStartPosition,0
	mov	CurrPosition,0
	mov	CurrPatt,0
	mov	CurrPatt2,0
	call	PosInit
	call	PrintPattInfo
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MouseTBL1	db	0,0,0,0,1,2,2,3,4,5,6,6
MouseTBL2	db	0,0,0,0,1,2,2, 3,4,5,6,6, 7,8,9,10,10, 11,12,13,14,14, 15,16,17,18,18, 19,20,21,22,22, 23,24,25,26,26, 27,28,29,30,30
MouseOnPattern:
	cmp	MouseB,1
	jnz	MM_Mark
	cmp	MM_ChanPress,-1
	jnz	MM_CheckMore
	cmp	PressedOnce,1
	jz	_ret
	mov	PressedOnce,1
	jmp	MM_Mark
MM_CheckMore:
	cmp	PressedOnce,1
	jz	MM_Mark
	mov	PressedOnce,1
MM_UnMarkBlock:
	mov	MM_ChanPress,-1
	mov	MM_ChanStart,-1
	mov	MM_ChanEnd,-1
	mov	MM_Press,-1
	mov	MM_Start,-1
	mov	MM_End,-1
	mov	MM_Zoom,-1
	mov	KBDMark,0
	mov	OldQM,-1
	mov	OldMCP,-1
	mov	PrintBlock,0
	mov	OldInfoTextPtr,-1

	mov	MM_RowPress,-1
	mov	MM_RowStart,-1
	mov	MM_RowEnd,-1
	mov	OldRow,-1
	ret
MM_Mark:
	mov	al,Original
	mov	RightKeyWait,al
	cmp	Menu_DownScreen,0
	jz	MouseOnPTPattern
	cmp	Menu_DownScreen,1
	jz	MouseOnSTPattern
	cmp	Menu_DownScreen,2
	jz	MouseOnPTPattern
	cmp	Menu_DownScreen,3
	jz	MouseOnSTPattern
	ret


MouseOnPTpattern:
	cmp	MouseY,351
	jbe	TopPart
	cmp	MouseY,371
	jae	BottomPart
	mov	ax,CurrRow
	cmp	MouseB,1
	jz	MM_CalcRow
	jmp	Skiptschy
FixXShitschky:
	mov	ax,CurrRow
	mov	GotoRow,ax
	movzx	ebx,CurrPatt2
	call	PattInit
Skiptschy:
	cmp	KBDMark,0
	jz	MouseMark
	movzx	ecx,CursorChannel
	mov	al,ArrowPointer
	call	MM_CalcChan
	mov	KBDMark,1
	mov	OldRow,-1
	ret
MouseMark:
	cmp	Zoom,1
	jz	MouseonZoomedPTPattern
	movzx	eax,MouseX
	sub	eax,31
	mov	ebp,eax
	mov	ebx,96
	xor	edx,edx
	div	ebx
	add	al,CurrentChannel
	cmp	al,Channels
	jae	Dummy
	cmp	MouseB,1
	jz	NoCursorMove
	mov	CursorChannel,al
NoCursorMove:
	mov	ecx,eax
	sub	al,CurrentChannel
	mov	ebx,96
	mul	ebx
	mov	ebx,eax
	xchg	eax,ebp
	sub	eax,ebx
	shr	eax,3
	mov	al,[MouseTBL1+eax]
	cmp	MouseB,1
	jz	MM_Instead
	mov	ArrowPointer,al
	mov	OldRow,-1
	ret
MM_Instead:
	mov	LeftKeyWait,3
	call	MM_CalcChan
	mov	MouseOnDragBar,-3
	mov	OldRow,-1
	ret

MouseonZoomedPTPattern:
	movzx	eax,MouseX
	cmp	eax,46*8
	jae	_ret
	sub	eax,31
	shr	eax,3
	movzx	ecx,CursorChannel
	mov	al,[MouseTBL2+eax]
	movzx	ebx,Commands
	shl	ebx,2
	add	ebx,2
	cmp	bl,al
	jae	NoFusk
	mov	al,bl
NoFusk:
	cmp	MouseB,1
	jz	MM_Instead
	mov	ArrowPointer,al
	sub	al,3
	jg	Knusprig3
	mov	al,0
Knusprig3:
	shr	al,2
	movzx	edi,CursorChannel
	mov	[cmd+edi],al
	call	UpdateChannelInfo
	mov	OldRow,-1
	ret

TopPart:
	movzx	eax,MouseY
	sub	eax,261
	mov	ebx,13
	xor	edx,edx
	div	ebx
	mov	ebx,7
	sub	ebx,eax
	movzx	eax,CurrRow
	sub	eax,ebx
	jl	Stummy1
	cmp	MouseB,1
	jz	MM_CalcRow
	sub	CurrRow,bx
	jmp	FixXShitschky
Stummy1:
	cmp	MouseB,1
	jz	MM_CalcRow
	mov	CurrRow,0
	jmp	FixXShitschky

BottomPart:
	movzx	eax,MouseY
	sub	eax,371
	mov	ebx,13
	xor	edx,edx
	div	ebx
	inc	eax
	movzx	ebx,CurrRow
	add	ebx,eax
	xchg	eax,ebx
	cmp	ax,Word ptr CurrPattLength
	jae	Stummy2
	cmp	MouseB,1
	jz	MM_CalcRow
	add	CurrRow,bx
	jmp	FixXShitschky
Stummy2:
	mov	ax,word ptr CurrPattLength
	dec	ax
	cmp	MouseB,1
	jz	MM_CalcRow
	mov	CurrRow,ax
	jmp	FixXShitschky

MouseOnSTPattern:
	movzx	eax,MouseY
	sub	eax,261
	mov	ebx,13
	xor	edx,edx
	div	ebx
	add	al,CurrentSTRow
	cmp	MouseB,1
	jz	MM_CalcRow
	mov	CurrRow,ax
	jmp	FixXShitschky

MM_CalcRow:
	cmp	ax,0
	jge	MM_Great
	mov	ax,0
MM_Great:
	cmp	MouseOnDragBar,-3
	jz	MM_RowCmp
	cmp	KBDMark,1
	jz	MM_RowCmp
	mov	MM_RowStart,ax
	mov	MM_RowEnd,ax
	mov	MM_RowPress,ax
	mov	al,Zoom
	mov	MM_Zoom,al
	jmp	Skiptschy

MM_RowCmp:
	mov	bx,MM_RowPress
	cmp	ax,bx
	jb	@@NoFlip1
	xchg	ax,bx
@@NoFlip1:
	mov	MM_RowStart,ax
	mov	MM_RowEnd,bx
	jmp	Skiptschy


MM_CalcChan:
	cmp	MouseOnDragBar,-3
	jz	MM_ChanCmp
	cmp	KBDMark,1
	jz	MM_ChanCmp
	mov	MM_ChanStart,cl
	mov	MM_ChanEnd,cl
	mov	MM_ChanPress,cl
	cmp	al,2
	ja	MM_NoNote
	mov	MM_Start,0
	mov	MM_End,0
	mov	MM_Press,0
	ret
MM_NoNote:
	inc	al
	shr	al,2
	mov	MM_Start,al
	mov	MM_Press,al
	mov	al,Commands
	mov	MM_End,al
	ret
MM_ChanCmp:
	mov	bl,MM_ChanPress
	cmp	cl,bl
	jb	@@NoFlip1
	xchg	cl,bl
@@NoFlip1:
	mov	MM_ChanStart,cl
	mov	MM_ChanEnd,bl

;	cmp	cl,MM_ChanStart
;	jae	MM_NoStart3
;	mov	MM_ChanStart,cl
;	jmp	MM_DoRestChan
;MM_NoStart3:
;	cmp	cl,MM_ChanEnd
;	jbe	MM_NoEnd2
;	mov	MM_ChanEnd,cl
;	jmp	MM_DoRestChan
;MM_NoEnd2:
;	cmp	cl,MM_ChanPress
;	ja	MM_NoStart4
;	mov	MM_ChanStart,cl
;MM_NoStart4:
;	cmp	cl,MM_ChanPress
;	jb	MM_DoRestChan
;	mov	MM_ChanEnd,cl
MM_DoRestChan:
	cmp	al,2
	ja	MM_NoNote2
	mov	al,0

	mov	bl,MM_ChanStart
	cmp	bl,MM_ChanEnd
	jz	MM_EqualChan
	cmp	bl,MM_ChanPress
	jz	MM_AlterEnd
	mov	MM_Start,al
	ret

MM_AlterEnd:
	mov	MM_End,al
	ret

MM_EqualChan:
	cmp	MM_Press,0
	jnz	MM_PressCmd
	mov	MM_Start,al
	mov	MM_End,al
	ret

MM_PressCmd:
	mov	MM_Start,0
	ret

MM_NoNote2:
	inc	al
	shr	al,2
	cmp	MM_Zoom,1
	jz	MM_FixZoom

	mov	bl,MM_ChanStart
	cmp	bl,MM_ChanEnd
	jz	MM_EqualChan2
	cmp	bl,MM_ChanPress
	jz	MM_AlterEnd2
	mov	MM_Start,al
	ret

MM_AlterEnd2:
	mov	al,Commands
	mov	MM_End,al
	ret

MM_EqualChan2:
	cmp	MM_Press,0
	jnz	MM_PressCmd2
	mov	al,Commands
	mov	MM_End,al
	ret

MM_PressCmd2:
	mov	MM_Start,al
	mov	al,Commands
	mov	MM_End,al
	ret

MM_FixZoom:
	cmp	al,MM_Press
	ja	MM_PutInEnd
	mov	MM_Start,al
	je	MM_PutInEnd
	ret
MM_PutInEnd:
	mov	MM_End,al
	ret

MM_ChanPress	db	-1
MM_ChanStart	db	-1
MM_ChanEnd	db	-1
MM_Press	db	-1
MM_Start	db	-1
MM_End		db	-1

MM_RowPress	dw	-1
MM_RowStart	dw	-1
MM_RowEnd	dw	-1
MM_Zoom 	db	-1
KBDMark 	db	0

MarkUp:
	call	StartKBDMark
	call	ArrowUp2
ContMark:
	mov	ax,CurrRow
	cmp	PrintBlock,0
	jz	MM_CalcRow
	mov	bl,ArrowPointer
	mov	ArrowPointer,3
	cmp	Zoom,0
	jz	@@NoZ
	mov	bh,Commands
	shl	bh,2
	add	bh,2
	mov	ArrowPointer,bh
@@NoZ:
	pushad
	call	MM_CalcRow
	popad
	mov	ArrowPointer,bl
	ret
MarkDn:
	call	StartKBDMark
	call	ArrowDown2
	jmp	ContMark

MarkLt:
	call	StartKBDMark
	call	Arrowleft
	mov	ax,CurrRow
	jmp	MM_CalcRow

MarkRt:
	call	StartKBDMark
	call	ArrowRight
	mov	ax,CurrRow
	jmp	MM_CalcRow

MarkPGUP:
	mov	ax,8
Mark_PGUP:
	call	StartKBDMark
	call	SubXRows
	jmp	ContMark

MarkPGDN:
	mov	ax,CurrRow
	add	ax,8
Mark_PGDN:
	call	StartKBDMark
	call	AddXRows
	jmp	ContMark
MarkEnd:
	call	StartKBDMark
	call	GoLastRow2
	jmp	ContMark
MarkHOME:
	call	StartKBDMark
	call	GoFirstRow2
	jmp	ContMark


OldQM	dw	-1
QMRows	dw	0
QuickMark:
	mov	ax,CurrRow
	cmp	ax,OldQM
	jnz	@@DoThat
	mov	bl,CursorChannel
	cmp	bl,MM_ChanPress
	jz	Next_QM
@@DoThat:
	call	MM_UnMarkBlock
	mov	OldQM,ax
	mov	al,ArrowPointer
	mov	ArrowPointer,0
	call	StartKBDMark
	mov	ArrowPointer,al
	mov	QMRows,4
Next_QM:
	movzx	eax,QMRows
	shl	QMRows,1
	add	ax,CurrRow
	dec	ax
	cmp	eax,CurrPattLength
	jb	DoCalcRow
	mov	eax,CurrPattLength
	dec	eax
DoCalcRow:
	mov	bl,ArrowPointer
;	 mov	 ArrowPointer,3
;	 cmp	 Zoom,0
;	 jz	 @@NoZ
	mov	bh,Commands
	shl	bh,2
	add	bh,2
	mov	ArrowPointer,bh
;@@NoZ:
	pushad
	call	MM_CalcRow
	popad
	mov	ArrowPointer,bl
	ret

	movzx	ebx,Commands
	shl	ebx,2
	add	ebx,2

StartKBDMark:
	cmp	KBDMark,1
	jz	_ret
	pushad
	mov	ax,CurrRow		;MM_CalcRow conversion
	mov	MM_RowStart,ax
	mov	MM_RowEnd,ax
	mov	MM_RowPress,ax
	mov	al,Zoom
	mov	MM_Zoom,al
	mov	KBDMark,2		;2=Init Phase
	call	Skiptschy
	popad
	ret

OldMCP	db	-1
MarkChanPatt:
	mov	al,CursorChannel
	cmp	al,OldMCP
	jz	Next_MCP
	call	MM_UnMarkBlock
	mov	OldMCP,al

	mov	al,ArrowPointer
	mov	bx,CurrRow
	mov	CurrRow,0
	mov	ArrowPointer,0
	call	StartKBDMark
	mov	CurrRow,bx
	mov	ArrowPointer,al

	mov	eax,CurrPattLength
	dec	eax
	mov	bl,ArrowPointer
;	 mov	 ArrowPointer,3
;	 cmp	 Zoom,0
;	 jz	 @@NoZ
	mov	bh,Commands
	shl	bh,2
	add	bh,2
	mov	ArrowPointer,bh
;@@NoZ:
	pushad

	call	MM_CalcRow
	popad
	mov	ArrowPointer,bl
	ret

Next_MCP:
	call	MM_UnMarkBlock

	mov	al,ArrowPointer
	mov	bx,CurrRow
	mov	cl,CursorChannel
	mov	CurrRow,0
	mov	ArrowPointer,0
	mov	CursorChannel,0
	call	StartKBDMark
	mov	CursorChannel,cl
	mov	CurrRow,bx
	mov	ArrowPointer,al

	mov	eax,CurrPattLength
	dec	eax
	mov	bl,ArrowPointer
;	 mov	 ArrowPointer,3
;	 cmp	 Zoom,0
;	 jz	 @@NoZ
	mov	bh,Commands
	shl	bh,2
	add	bh,2
	mov	ArrowPointer,bh
;@@NoZ:
	mov	cl,CursorChannel
	pushad
	mov	ch,Channels
	dec	ch
	mov	CursorChannel,ch
	call	MM_CalcRow
	popad
	mov	CursorChannel,cl
	mov	ArrowPointer,bl
	ret


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
JumpPattern1M:
	movzx	ax,[JumpTable+0]
	jmp	JumpPatternM
JumpPattern2M:
	movzx	ax,[JumpTable+1]
	jmp	JumpPatternM
JumpPattern3M:
	movzx	ax,[JumpTable+2]
	jmp	JumpPatternM
JumpPattern4M:
	movzx	ax,[JumpTable+3]
	jmp	JumpPatternM
JumpPattern5M:
	movzx	ax,[JumpTable+4]
JumpPatternM:
	call	StartKBDMark
	call	JumpPattern
	jmp	ContMark
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
JumpTable	db	0,16,32,48,63
JumpPattern1:
	movzx	ax,[JumpTable+0]
	jmp	JumpPattern
JumpPattern2:
	movzx	ax,[JumpTable+1]
	jmp	JumpPattern
JumpPattern3:
	movzx	ax,[JumpTable+2]
	jmp	JumpPattern
JumpPattern4:
	movzx	ax,[JumpTable+3]
	jmp	JumpPattern
JumpPattern5:
	movzx	ax,[JumpTable+4]

JumpPattern:
	mov	CurrRow,ax
	movzx	ebx,CurrPatt2
	call	PattInit
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
StorePattern1:
	mov	ax,CurrRow
	mov	[JumpTable+0],al
	ret
StorePattern2:
	mov	ax,CurrRow
	mov	[JumpTable+1],al
	ret
StorePattern3:
	mov	ax,CurrRow
	mov	[JumpTable+2],al
	ret
StorePattern4:
	mov	ax,CurrRow
	mov	[JumpTable+3],al
	ret
StorePattern5:
	mov	ax,CurrRow
	mov	[JumpTable+4],al
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PlayPattern1:
	movzx	ax,[JumpTable+0]
	jmp	PlayPatt
PlayPattern2:
	movzx	ax,[JumpTable+1]
	jmp	PlayPatt
PlayPattern3:
	movzx	ax,[JumpTable+2]
	jmp	PlayPatt
PlayPattern4:
	movzx	ax,[JumpTable+3]
	jmp	PlayPatt
PlayPattern5:
	movzx	ax,[JumpTable+4]
PlayPatt:
	mov	CurrRow,ax
	movzx	ebx,CurrPatt2
	call	PattInit
	jmp	StartPatt3
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
RecPattern1:
	movzx	ax,[JumpTable+0]
	jmp	RecPattern
RecPattern2:
	movzx	ax,[JumpTable+1]
	jmp	RecPattern
RecPattern3:
	movzx	ax,[JumpTable+2]
	jmp	RecPattern
RecPattern4:
	movzx	ax,[JumpTable+3]
	jmp	RecPattern
RecPattern5:
	movzx	ax,[JumpTable+4]
RecPattern:
	mov	CurrRow,ax
	movzx	ebx,CurrPatt2
	call	PattInit
	jmp	RecPatt3
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ChannelNr1:
	mov	ebx,1
	jmp	ChannelNr7
ChannelNr2:
	mov	ebx,2
	jmp	ChannelNr7
ChannelNr3:
	mov	ebx,3
	jmp	ChannelNr7
ChannelNr4:
	mov	ebx,4
	jmp	ChannelNr7
ChannelNr5:
	mov	ebx,5
	jmp	ChannelNr7
ChannelNr6:
	mov	ebx,6
ChannelNr7:
	mov	edx,ebx
	dec	edx

	add	bl,CurrentChannel

	cmp	bl,Channels
	ja	Dummy
	dec	ebx

	mov	edi,244*80+72/8
	mov	eax,96/8
	mul	edx
	add	edi,eax
	lea	ebp,[ChanPos+ebx]
	mov	DigitTarget,ebp
	movzx	ebx,byte ptr [ChanPos+ebx]
	mov	ecx,2
	mov	ax,0101h
	mov	DigitSize,1
	movzx	ebp,Channels
	dec	ebp
	mov	DigitLimit,ebp
	mov	DigitInput,14
	call	InputDigits
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SplitPlay	db	0
SplitOnOff	db	16 dup(0)
SplitTable	db	16*16*4 dup(1)
CurrentSplit	db	0
CurrentZone	db	0
CurrentSplitOffset	dd	0
KBD1Request	db	0
KBD2Request	db	0
KBD3Request	db	0
KBD4Request	db	0
KBD5Request	db	0
CurrInstSave	db	0
PutSplitPopUpToScreen:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
Putsplit2:
	mov	EditMode,0
	mov	RecMode,0
	call	BackCol
	mov	SplitPlay,1
	mov	al,CurrentInstrument
	mov	CurrInstSave,al
	mov	Menu_Popup,9
	call	menuhandler
	call	UpdateSplitStatus
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Split_SwitchActive:
	movzx	ebx,CurrentSplit
	xor	[SplitOnOff+ebx],1
	call	UpdateSplitStatus
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Split_SplitArrowUp:
	call	FixButton
	inc	CurrentSplit
	cmp	CurrentSplit,16
	jb	NoSplitPos
	mov	CurrentSplit,15
NoSplitPos:
	mov	CurrentZone,0
	call	UpdateSplitStatus
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Split_SplitArrowDn:
	call	FixButton
	dec	CurrentSplit
	jge	NoSplitNeg
	mov	CurrentSplit,0
NoSplitNeg:
	mov	CurrentZone,0
	call	UpdateSplitStatus
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Split_ZoneArrowUp:
	call	FixButton
	inc	CurrentZone
	cmp	CurrentZone,16
	jb	NoZonePos
	mov	CurrentZone,15
NoZonePos:
	call	UpdateSplitStatus
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Split_ZoneArrowDn:
	call	FixButton
	dec	CurrentZone
	jge	NoZoneNeg
	mov	CurrentZone,0
NoZoneNeg:
	call	UpdateSplitStatus
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Split_KBD1ArrowUp:
	call	FixButton
	mov	edx,CurrentSplitOffset
	mov	al,[SplitTable+edx+1]
	cmp	al,121
	jz	Dummy
	cmp	al,0
	jnz	Skal
	inc	[SplitTable+edx+1]
Skal:
	inc	[SplitTable+edx+1]
	call	UpdateSplitStatus
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Split_KBD1ArrowDn:
	call	FixButton
	mov	edx,CurrentSplitOffset
	mov	al,[SplitTable+edx+1]
	cmp	al,2
	jbe	Dummy
	dec	[SplitTable+edx+1]
	call	UpdateSplitStatus
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Split_KBD2ArrowUp:
	call	FixButton
	mov	edx,CurrentSplitOffset
	mov	al,[SplitTable+edx+2]
	cmp	al,121
	jz	Dummy
	cmp	al,0
	jnz	Skal2
	inc	[SplitTable+edx+2]
Skal2:
	inc	[SplitTable+edx+2]
	call	UpdateSplitStatus
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Split_KBD2ArrowDn:
	call	FixButton
	mov	edx,CurrentSplitOffset
	mov	al,[SplitTable+edx+2]
	cmp	al,2
	jbe	Dummy
	dec	[SplitTable+edx+2]
	call	UpdateSplitStatus
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Split_SampleArrowUp:
	call	FixButton
	mov	edx,CurrentSplitOffset
	mov	al,[SplitTable+edx]
	cmp	al,Samples
	jz	Dummy
	inc	[SplitTable+edx]
	inc	CurrentInstrument

	movzx	ax,CurrentInstrument
	shl	ax,4
	mov	CurrentSample,ax
	mov	CurrentSampName,ax
	call	UpdateSplitStatus
	mov	al,CurrentInstrument
	jmp	ScrollInstDn
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Split_SampleArrowDn:
	call	FixButton
	mov	edx,CurrentSplitOffset
	mov	al,[SplitTable+edx]
	cmp	al,1
	jz	Dummy
	dec	[SplitTable+edx]
	dec	CurrentInstrument
	movzx	ax,CurrentInstrument
	shl	ax,4
	mov	CurrentSample,ax
	mov	CurrentSampName,ax
	call	UpdateSplitStatus
	mov	al,CurrentInstrument
	jmp	ScrollInstUp
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PopUp_KBD1:
	mov	FontPlane,1
	mov	ah,1
	mov	cl,3
	move	edi,0a0000h+100*80+376/8
	lea	esi,Spaces
	call	mouseoff
	call	printtext
	call	mouseon
	mov	FontPlane,0
	mov	KBD1Request,1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PopUp_KBD2:
	mov	FontPlane,1
	mov	ah,1
	mov	cl,3
	move	edi,0a0000h+117*80+376/8
	lea	esi,Spaces
	call	mouseoff
	call	printtext
	call	mouseon
	mov	FontPlane,0
	mov	KBD2Request,1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PopUp_BaseNote:
	mov	FontPlane,1
	mov	ah,1
	mov	cl,3
	move	edi,0a0000h+134*80+376/8
	lea	esi,Spaces
	call	mouseoff
	call	printtext
	call	mouseon
	mov	FontPlane,0
	mov	KBD3Request,1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Split_ClearAll:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
	xor	eax,eax
	lea	edi,SplitOnOff
	mov	ecx,16
	rep	stosb
	mov	eax,01010101h
	lea	edi,SplitTable
	mov	ecx,16*16
	rep	stosd
	mov	CurrentSplit,0
	mov	CurrentZone,0
	mov	CurrentSplitOffset,0
	call	UpdateSplitStatus
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Split_KBDStartArrowUp:
	call	FixButton
	mov	edx,CurrentSplitOffset
	mov	al,[SplitTable+edx+3]
	cmp	al,121
	jz	Dummy
	cmp	al,0
	jnz	Skal3
	inc	[SplitTable+edx+3]
Skal3:
	inc	[SplitTable+edx+3]
	call	UpdateSplitStatus
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Split_KBDStartArrowDn:
	call	FixButton
	mov	edx,CurrentSplitOffset
	mov	al,[SplitTable+edx+3]
	cmp	al,2
	jbe	Dummy
	dec	[SplitTable+edx+3]
	call	UpdateSplitStatus
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Zoom	db	0	;1=Zoom
CurrentChannelSave	db	0
ZoomPattern:
	cmp	Menu_DownScreen,3
	ja	Dummy
	xor	Zoom,1
	jz	UnZoomed
	mov	al,CurrentChannel
	mov	CurrentChannelSave,al
	mov	al,CursorChannel
	mov	CurrentChannel,al
	add	Menu_DownScreen,2
	lea	eax,ArrowsPTZoom
	mov	ArrowPositions,eax
	movzx	edi,CursorChannel
	cmp	ArrowPointer,2
	ja	Flumpse
	mov	[cmd+edi],0
Flumpse:
	mov	al,[cmd+edi]
	shl	al,2
	add	ArrowPointer,al

;	mov	Word Ptr [DragBarTable+3*24+4],1
	call	MenuHandler
	ret
UnZoomed:
	mov	al,CurrentChannelSave
	mov	CurrentChannel,al
	sub	Menu_DownScreen,2
	lea	eax,ArrowsPTUnZoom
	mov	ArrowPositions,eax
	mov	ArrowPointer,0
;	mov	Word Ptr [DragBarTable+3*24+4],6
	call	MenuHandler
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
RestoreFPositions:
	mov	Byte ptr [Jumptable+0],0
	mov	Byte ptr [Jumptable+1],16
	mov	Byte ptr [Jumptable+2],32
	mov	Byte ptr [Jumptable+3],48
	mov	Byte ptr [Jumptable+4],63
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CommandTable	dw	10*8 dup(0)	;Gotta be 8!
StoreCommand0:
	nop
StoreCommand1:
	nop
StoreCommand2:
	nop
StoreCommand3:
	nop
StoreCommand4:
	nop
StoreCommand5:
	nop
StoreCommand6:
	nop
StoreCommand7:
	nop
StoreCommand8:
	nop
StoreCommand9:
	nop
	cmp	EditMode,0
	jz	Dummy
	call	CalculateOffset
	add	esi,2
	mov	edi,KeyBoardPress
	sub	edi,2
	shl	edi,4
	add	edi,Offset CommandTable
	mov	ecx,RowSize
	sub	ecx,2
	rep	movsb
	mov	oldrow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
InsertAllCommands0:
	nop
InsertAllCommands1:
	nop
InsertAllCommands2:
	nop
InsertAllCommands3:
	nop
InsertAllCommands4:
	nop
InsertAllCommands5:
	nop
InsertAllCommands6:
	nop
InsertAllCommands7:
	nop
InsertAllCommands8:
	nop
InsertAllCommands9:
	cmp	EditMode,0
	jz	Dummy
	call	CalculateOffset
	add	esi,2
	mov	edi,esi
	mov	esi,KeyBoardPress
	sub	esi,2
	shl	esi,4
	add	esi,Offset CommandTable
	mov	ecx,RowSize
	sub	ecx,2
	rep	movsb
	movzx	dx,RowAdder
	mov	OldRow,-1
	cmp	RecMode,1
	jz	Dummy
	mov	ax,CurrRow
	mov	GotoRow,ax
	add	CurrRow,dx
	call	CheckPattEnd
	mov	ax,CurrRow
	mov	GotoRow,ax
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
InsertOneCommand0:
	nop
InsertOneCommand1:
	nop
InsertOneCommand2:
	nop
InsertOneCommand3:
	nop
InsertOneCommand4:
	nop
InsertOneCommand5:
	nop
InsertOneCommand6:
	nop
InsertOneCommand7:
	nop
InsertOneCommand8:
	nop
InsertOneCommand9:
	nop
	cmp	EditMode,0
	jz	Dummy
	call	CalculateOffset
	movzx	eax,[Cmd+edi]
	mov	edi,esi
	shl	eax,1
	add	edi,eax
	add	edi,2
	mov	esi,KeyBoardPress
	sub	esi,2
	shl	esi,4
	add	esi,Offset CommandTable
	add	esi,eax
	movsw
	movzx	dx,RowAdder
	mov	OldRow,-1
	cmp	RecMode,1
	jz	Dummy
	mov	ax,CurrRow
	mov	GotoRow,ax
	add	CurrRow,dx
	call	CheckPattEnd
	mov	ax,CurrRow
	mov	GotoRow,ax
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CopyAllAboveCommandInc:
	mov	dh,1
	jmp	CopyAllAboveCommand2
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CopyAllAboveCommandDec:
	mov	dh,-1
	jmp	CopyAllAboveCommand2
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CopyOneAboveCommandInc:
	mov	dh,1
	jmp	CopyOneAboveCommand2
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CopyOneAboveCommandDec:
	mov	dh,-1
	jmp	CopyOneAboveCommand2
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CopyAllAboveCommand:
	mov	dh,0
CopyAllAboveCommand2:
	cmp	EditMode,0
	jz	Dummy
	cmp	CurrRow,0
	jz	ArrowDown
	dec	CurrRow
	call	CalculateOffset
	add	esi,2
	mov	ebx,esi
	inc	CurrRow
	call	CalculateOffset
	add	esi,2
	mov	edi,esi
	mov	esi,ebx
	movzx	ecx,Commands
CAACLoopen:
	lodsw
	add	ah,dh
	jge	CAACOk
	mov	al,0
CAACOk:
	stosw
	loop	CAACLoopen
	jmp	ArrowDown
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CopyOneAboveCommand:
	mov	dh,0
CopyOneAboveCommand2:
	cmp	EditMode,0
	jz	Dummy
	cmp	CurrRow,0
	jz	ArrowDown
	call	CalculateOffset
	movzx	eax,[Cmd+edi]
	mov	ebx,esi
	shl	eax,1
	add	ebx,eax
	add	ebx,2
	dec	CurrRow
	call	CalculateOffset
	inc	CurrRow
	movzx	eax,[Cmd+edi]
	shl	eax,1
	add	esi,eax
	add	esi,2
	mov	edi,ebx
	lodsw
	add	ah,dh
	stosw
	jmp	ArrowDown

OctaveUpSB:
	mov	eax,12
	mov	ebp,0
	jmp	TransposeBlock
OctaveUpAB:
	mov	eax,12
	mov	ebp,1
	jmp	TransposeBlock
OctaveDownSB:
	mov	eax,-12
	mov	ebp,0
	jmp	TransposeBlock
OctaveDownAB:
	mov	eax,-12
	mov	ebp,1
	jmp	TransposeBlock
NoteUpSB:
	mov	eax,1
	mov	ebp,0
	jmp	TransposeBlock
NoteUpAB:
	mov	eax,1
	mov	ebp,1
	jmp	TransposeBlock
NoteDownSB:
	mov	eax,-1
	mov	ebp,0
	jmp	TransposeBlock
NoteDownAB:
	mov	eax,-1
	mov	ebp,1
	jmp	TransposeBlock

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OctaveDownST:
	mov	eax,-12
	mov	ebp,0
	jmp	TransposeChannel
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OctaveDownSP:
	mov	eax,-12
	mov	ebp,0
	jmp	TransposePattern
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OctaveDownAT:
	mov	eax,-12
	mov	ebp,1
	jmp	TransposeChannel
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OctaveDownAP:
	mov	eax,-12
	mov	ebp,1
	jmp	TransposePattern
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OctaveUpST:
	mov	eax,12
	mov	ebp,0
	jmp	TransposeChannel
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OctaveUpSP:
	mov	eax,12
	mov	ebp,0
	jmp	TransposePattern
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OctaveUpAT:
	mov	eax,12
	mov	ebp,1
	jmp	TransposeChannel
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OctaveUpAP:
	mov	eax,12
	mov	ebp,1
	jmp	TransposePattern
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
NoteDownST:
	mov	eax,-1
	mov	ebp,0
	jmp	TransposeChannel
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
NoteDownSP:
	mov	eax,-1
	mov	ebp,0
	jmp	TransposePattern
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
NoteDownAT:
	mov	eax,-1
	mov	ebp,1
	jmp	TransposeChannel
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
NoteDownAP:
	mov	eax,-1
	mov	ebp,1
	jmp	TransposePattern
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
NoteUpST:
	mov	eax,1
	mov	ebp,0
	jmp	TransposeChannel
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
NoteUpSP:
	mov	eax,1
	mov	ebp,0
	jmp	TransposePattern
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
NoteUpAT:
	mov	eax,1
	mov	ebp,1
	jmp	TransposeChannel
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
NoteUpAP:
	mov	eax,1
	mov	ebp,1
	jmp	TransposePattern
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
TransposeChannel:
	movzx	ebx,CursorChannel
	mov	ecx,0
	mov	edx,CurrPattLength
	call	Transpose
	mov	oldrow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
TransposeBlock:
	cmp	MM_Start,-1
	jz	_ret
	movzx	ebx,MM_ChanStart
	movzx	ecx,MM_RowStart
	movzx	edx,MM_RowEnd
	sub	edx,ecx
	inc	edx
@@TransposeAgain:
	call	Transpose
	inc	ebx
	cmp	bl,MM_ChanEnd
	jbe	@@TransposeAgain
	mov	oldrow,-1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
TransposePattern:
	xor	ebx,ebx
TransposePatternLoop:
	mov	ecx,0
	mov	edx,CurrPattLength
	call	Transpose
	inc	ebx
	cmp	bl,Channels
	jnz	TransposePatternLoop
	mov	oldrow,-1
	ret
;;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;TransposeSong:
;	 xor	 ebx,ebx
;TransposeSongLoop:
;	 mov	 ecx,0
;	 mov	 edx,64
;	 call	 Transpose
;	 inc	 ebx
;	 cmp	 bl,Channels
;	 jnz	 TransposePatternLoop
;	 mov	 oldrow,-1
;	 ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SelectSampleShift:
	mov	ebx,30
	jmp	SelectSample2
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SelectSampleCtrl:
	mov	ebx,45
	jmp	SelectSample2
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SelectSampleAlt:
	mov	ebx,60
	jmp	SelectSample2
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SelectSampleCL:
	mov	ebx,15
	jmp	SelectSample2
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SampleKeyTable	db	0,69,91,55,74,71,72,73,78,75,76,77,79,80,81,89
SelectSample:
	mov	ebx,0
SelectSample2:
	cmp	KeyBoardPress,82
	jnz	NotSample0
	mov	Sample0,1
	mov	OldCurrentInstrument,-1
	jmp	QuitSS
NotSample0:
	mov	Sample0,0
	mov	ecx,15
	mov	eax,KeyBoardPress
SearchSampleLoop:
	cmp	[SampleKeyTable+ecx],al
	loopnz	SearchSampleLoop
	inc	ecx
	add	ecx,ebx
	cmp	cl,Samples
	ja	Dummy
	mov	CurrentInstrument,cl
InstCont:
	mov	cl,CurrentInstrument

	movzx	ax,cl
	shl	ax,4
	mov	CurrentSample,ax
	mov	CurrentSampName,ax
	mov	al,CurrentInstName
	cmp	cl,al
	ja	SampleIsBelow
	dec	cl
	mov	CurrentInstName,cl
	jmp	QuitSS
SampleIsBelow:
	add	al,12
	cmp	cl,al
	jb	QuitSS
	sub	cl,12
	mov	CurrentInstName,cl
QuitSS:
	mov	OldCurrentInstName,-1
	call	PrintSampleInfo
	call	SampleToRAM
	cmp	AutoName,0
	jz	Dummy
	call	Getname2
	ret

CheckPatternStart_Edit:
	pushad
	mov	FileEdited,1
	mov	eax,PatternStart
	sub	eax,12
	cmp	eax,EmptyPattern
	jnz	_retp

	movzx	ebp,CurrPatt2
	movzx	eax,DefaultChannels
	mov	TempChannels,al
	movzx	ebx,DefaultCommands
	mov	TempCommands,al
	movzx	ecx,DefaultRows
	mov	CurrPattLength,ecx

	call	GetRowSize2
	call	GetPatternSize2
	mov	eax,PatternSize2
	add	eax,12
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem

	movzx	edx,DefaultRows
	dec	dx
	mov	byte ptr [eax+10],dl
	mov	dl,DefaultCommands
	mov	Commands,dl
	mov	dh,DefaultChannels
	mov	Channels,dh
	shl	dl,5
	dec	dh
	or	dl,dh
	mov	byte ptr [eax+11],dl
	add	eax,12
	mov	PatternStart,eax
	popad
	ret

CheckPatternStart_View:
	pushad
	cmp	PatternStart,12
	ja	PatternIsAllocated

	mov	eax,EmptyPattern
	add	PatternStart,eax
PatternIsAllocated:
	popad
	ret

CheckPattEnd:
	mov	ax,CurrRow
	cmp	ax,word ptr CurrPattLength
	jb	SkipNextPatt
	sub	ax,word ptr CurrPattLength
	mov	CurrRow,ax
	cmp	PatternPlay,1
	jz	SkipNextPatt

;	cmp	PatternMode,1
;	jnz	SkipNextPatt

	cmp	WrapPatt,4
	jz	StopDown
	cmp	WrapPatt,0
	jz	SkipNextPatt
	cmp	WrapPatt,3
	jz	NeverWrap2
	cmp	WrapPatt,1
	jnz	Wr_NotPlay2
	cmp	TuneStopped,0
	jz	SkipNextPatt
	jmp	NeverWrap2
Wr_NotPlay2:
	cmp	TuneStopped,1
	jz	SkipNextPatt
NeverWrap2:
	inc	CurrPosition
	call	PosInit
	ret
StopDown:
	mov	ax,GotoRow;word ptr CurrPattLength
;	dec	ax
	mov	CurrRow,ax
;	mov	GotoRow,ax
SkipNextPatt:
	movzx	ebx,CurrPatt2
	call	PattInit
	ret


;---------------------------------------------------- Optimize
O_InProgress	db	0
O_MemoryFree	dd	0
O_GUS_DramFree	dd	0

ViewOptimizePopup:
	call	ButtonHandler
	cmp	eax,0
	jnz	_ret
	mov	eax,MemoryFree
	mov	O_MemoryFree,eax
	mov	eax,GUS_DramFree
	mov	O_GUS_DramFree,eax

	mov	Menu_Popup,22
	call	MenuHandler
	ret


SaveSamples	db	0
OptimOkay:
	call	ButtonHandler
	cmp	eax,0
	jnz	_ret
OptimOkay2:

	mov	TuneStopped,1	;Stop tune
	mov	O_InProgress,1

	mov	menu_popup,0
	call	menuhandler

	call	MouseHourGlass

;---------------------------------------------------- Start Optimizing

	bt	OptimBits,2	;Pattern Remove
	jnc	O_Skip1
	movzx	ebp,CurrPatt2
	mov	ecx,1
	bt	OptimBits,8	;Affect Patt
	jc	RemoveNextPattern
	mov	ebp,0
	mov	ecx,1024
RemoveNextPattern:
	push	ecx
	call	O_RemovePattern
	pop	ecx
	inc	ebp
	loop	RemoveNextPattern
O_Skip1:
	bt	OptimBits,6	;Pattern Compress
	jnc	O_Skip_1
	call	O_CompressPattern
O_Skip_1:
;----------------------------------------------------
	bt	OptimBits,0	;Channels Remove
	jnc	O_Skip2
	movzx	ebp,CurrPatt2
	mov	ecx,1
	bt	OptimBits,8	;Affect Patt
	jc	RemoveNextChannel
	mov	ebp,0
	mov	ecx,1024
RemoveNextChannel:
	push	ecx
	push	ebp
	call	O_RemoveChannel
	pop	ebp
	pop	ecx
	inc	ebp
	loop	RemoveNextChannel
O_Skip2:
;----------------------------------------------------
	bt	OptimBits,1	;Commands Remove
	jc	GOA
	bt	OptimBits,5	;Commands Compress
	jnc	O_Skip3
GOA:
	movzx	ebp,CurrPatt2
	mov	ecx,1
	bt	OptimBits,8	;Affect Patt
	jc	RemoveNextCommand
	mov	ebp,0
	mov	ecx,1024
RemoveNextCommand:
	push	ecx
	push	ebp
	call	O_RemoveCommand
	pop	ebp
	pop	ecx
	inc	ebp
	loop	RemoveNextCommand
O_Skip3:
;----------------------------------------------------
	test	OptimBits,10001000b
	jz	O_NoInstCompress
	mov	edi,GUS_TempBuffPtr
	mov	ecx,768/4
	mov	eax,-1
	rep	stosd

	mov	esi,GUS_TempBuffPtr
	add	esi,512
	mov	eax,1
	movzx	ecx,Samples
O_CheckUsedInst:
	mov	CurrentInstrument,al
	call	CheckInstEmpty
	jnc	O_UsedInst1		;No Inst
	mov	byte ptr [esi+eax],0	;Used Inst
O_UsedInst1:
	inc	eax
	loop	O_CheckUsedInst


	mov	ebp,0
	mov	ecx,1024
O_CheckNextPatt_Inst:
	push	ecx
	push	ebp
	call	O_CheckInst
	pop	ebp
	pop	ecx
	inc	ebp
	loop	O_CheckNextPatt_Inst

	bt	OptimBits,3		;Inst Remove
	jnc	O_NoInstRemove

	movzx	ecx,Samples
	mov	esi,GUS_TempBuffPtr
	mov	eax,1
O_NextInst:
	cmp	word ptr [esi+eax*2],0
	jz	O_UsedInst

	mov	CurrentInstrument,al
	call	CheckInstEmpty
	jnc	O_UsedInst		;No inst

	pushad
	call	KillInst2
	popad
	mov	word ptr [esi+eax*2],-1
O_UsedInst:
	inc	eax
	loop	O_NextInst
	mov	CurrentInstrument,1

O_NoInstRemove:
	bt	OptimBits,7	;Inst Compress
	jnc	O_NoInstCompress

	mov	esi,GUS_TempBuffPtr
	movzx	ecx,Samples
	mov	eax,1
	mov	word ptr [esi],0
O_NextInst2:
	cmp	word ptr [esi+eax*2],0
	jnz	O_FoundEmpty
	mov	word ptr [esi+eax*2],ax
	jmp	O_LoopNext
O_FoundEmpty:

	mov	edx,ecx
	mov	ebp,eax
	mov	ebx,eax 		;Store
O_NextInst3:
	inc	ebp
	cmp	word ptr [esi+ebp*2],0
	loopnz	O_NextInst3
	jnz	O_InstCompress
	mov	word ptr [esi+ebp*2],bx
	mov	ecx,edx

O_LoopNext:
	inc	eax
	loop	O_NextInst2

O_InstCompress:
	mov	ebp,0
	mov	ecx,1024
O_CheckNextPatt_Inst2:
	push	ecx
	push	ebp
	call	O_ChangeInstPatt
	pop	ebp
	pop	ecx
	inc	ebp
	loop	O_CheckNextPatt_Inst2

	mov	esi,GUS_TempBuffPtr
	mov	ebp,1
	xor	edx,edx
	movzx	ecx,Samples
	mov	SaveSamples,cl
	mov	Samples,1
O_MoveInstLoop:
	mov	dx,[esi+ebp*2]
	cmp	dx,-1
	jz	O_NoNew
	cmp	edx,ebp
	jz	O_SamePos

	call	CopyInstrument

	push	edx ebp
	mov	eax,ebp
	mov	CurrentInstrument,al
	pushad
	mov	DontDisallocSample,1
	call	KillInst2
	mov	DontDisallocSample,0
	popad
	pop	ebp edx

	push	eax
	mov	al,Samples
	mov	ah,SaveSamples
	mov	Samples,ah
	call	MoveShadows
;	call	UpdateShadows
	mov	Samples,al
	pop	eax


O_SamePos:
	cmp	dl,Samples
	jbe	O_NoNew
	mov	Samples,dl
O_NoNew:
	inc	ebp
	loop	O_MoveInstLoop

	movzx	eax,Samples
	mov	ebx,30
	mul	ebx
	mov	ebp,1029		;Allocate Inst. names
	mov	ebx,1
	call	MemAlloc
	mov	InstNamesPtr,eax

	movzx	eax,Samples
	shl	eax,4
	mov	ebx,22
	mul	ebx
	mov	ebp,1028		;Allocate Samp. names
	mov	ebx,1
	call	MemAlloc
	mov	SampleNamesPtr,eax

	movzx	eax,Samples
	mov	ebx,716
	mul	ebx
	mov	ebp,1034		;Allocate Inst. Info
	mov	ebx,1
	call	MemAlloc
	mov	InstrumentInfo,eax

	lea	edi,CurrSample		;Clear Curr
	mov	ecx,32
	xor	eax,eax
	rep	stosw
	lea	edi,CurrInst
	mov	ecx,32
	rep	stosb
	mov	OldCurrentSampName,-1
	mov	OldCurrentInstName,-1
	mov	CurrentInstrument,1
	mov	CurrentSample,16
	mov	CurrentSampName,16

O_NoInstCompress:
	mov	O_InProgress,0
	mov	CurrPosition,0
	mov	CurrRow,0
	call	PosInit
	mov	OldRow,-1
	mov	OldPatt2,-1
	call	SampleToRAM
	call	PrintSampleInfo
;	call	SetInitialEnvelopes
	call	UpdateEnvelopeScreen
	call	MouseArrow

	mov	eax,MemoryFree
	sub	O_MemoryFree,eax
	neg	O_MemoryFree
	mov	eax,GUS_DramFree
	sub	O_GUS_DramFree,eax
	neg	O_GUS_DramFree
	movzx	eax,Samples
	mov	dword ptr [DragbarTable+2*24+6],eax
	mov	dword Ptr [DragbarTable+2*24+10],0
	mov	CurrentInstName,0
	mov	menu_popup,24
	call	menuhandler
	ret
OptimEnd:
	mov	menu_popup,0
	call	menuhandler
	ret


;--------------------------------------------------------- END
;--------------------
;Calls:
;EBP=Pattern to check
;--------------------
O_RemovePattern:
	mov	edi,PatternOrderPtr
	movzx	ecx,Positions
	sub	edi,2
O_RCLoop:
	add	edi,2
	cmp	[edi],bp
	loopnz	O_RCLoop
	jz	_ret
	call	MemDisalloc
	ret


OldRowSize	dd	0
OldChRowSize	dd	0
O_RemoveChannel:
	cmp	Channels,1
	jz	_ret
	push	word ptr Channels
	push	word ptr Commands
	push	CurrPatt2
	mov	CurrPatt2,bp

	mov	edi,[AllocTable+ebp*8]
	cmp	edi,0
	jz	O_RemoveChannelFinish
	mov	al,byte ptr [edi+11]
	mov	ah,al
	and	al,31
	inc	al
	mov	Channels,al
	shr	ah,5
	mov	Commands,ah

	movzx	ecx,al		;Get RowSize and ChRowSize
	movzx	eax,ah
	shl	eax,1
	add	eax,2
	mov	OldRowSize,eax
	mul	ecx
	mov	OldChRowSize,eax

	movzx	ebp,byte ptr [edi+10]
	inc	ebp
	add	edi,12
	mov	eax,OldRowSize
	movzx	ecx,Channels
	dec	ecx
	mul	ecx
	add	edi,eax

CheckNextChan:
	push	ecx
	push	edi
	sub	edi,OldChRowSize
	mov	ecx,ebp
CheckEmptyChan:
	add	edi,OldChRowSize
	push	ecx
	push	edi

	mov	ecx,OldRowSize
	dec	edi
CheckEmptyRow:
	inc	edi
	cmp	byte ptr [edi],0
	loopz	CheckEmptyRow

	pop	edi
	pop	ecx
	loopz	CheckEmptyChan

	pop	edi
	pop	ecx
	jnz	ChannelsChecked
	dec	Channels
	sub	edi,OldRowSize
	loop	CheckNextChan

ChannelsChecked:
	mov	al,Channels
	mov	TempChannels,al
	mov	al,Commands
	mov	TempCommands,al
	call	FixPatternWidth


O_RemoveChannelFinish:
	pop	CurrPatt2
	pop	word ptr Commands
	pop	word ptr Channels
	ret

CmdTable	dd	7 dup(0)
CountedCommands db	0
O_RemoveCommand:
	push	word ptr Channels
	push	word ptr Commands
	push	CurrPatt2
	mov	CurrPatt2,bp
	mov	CountedCommands,1

	mov	edi,[AllocTable+ebp*8]
	cmp	edi,0
	jz	O_RemoveCommandFinish
	mov	al,byte ptr [edi+11]
	mov	ah,al
	and	al,31
	inc	al
	mov	Channels,al
	shr	ah,5
	mov	Commands,ah

	movzx	ecx,al		;Get RowSize and ChRowSize
	movzx	eax,ah
	shl	eax,1
	add	eax,2
	mov	OldRowSize,eax
	mul	ecx
	mov	OldChRowSize,eax

	movzx	ebp,byte ptr [edi+10]
	inc	ebp
	add	edi,12
	movzx	ecx,Channels

CheckNextChan2:
	push	ecx
	push	edi
	sub	edi,OldChRowSize
	mov	ecx,ebp
CheckEmptyComm:
	add	edi,OldChRowSize
	push	ecx
	push	edi

;--------------------------
	bt	OptimBits,5
	jnc	NoCmdCompress

	xor	ebx,ebx
	xor	edx,edx
	push	edi

	push	edi		;Clear table
	lea	edi,CmdTable
	mov	ecx,7
	xor	eax,eax
	rep	stosd
	pop	edi

	movzx	ecx,Commands
CheckEmptyCommRow:
	add	edi,2
	cmp	word ptr [edi],0
	jnz	CmdExists
	mov	[CmdTable+ebx*4],edi
	inc	ebx
	jmp	LeaveCmd
CmdExists:
	cmp	[CmdTable+edx*4],0
	jz	LeaveCmd
	mov	esi,[CmdTable+edx*4]
	mov	ax,[edi]
	mov	[esi],ax
	mov	word ptr [edi],0
	inc	edx
	mov	[CmdTable+ebx*4],edi
	inc	ebx
LeaveCmd:
	loop	CheckEmptyCommRow
	pop	edi

NoCmdCompress:
;--------------------------
	bt	OptimBits,1
	jnc	NoCmdRemove
	push	edi
	movzx	ecx,Commands
CheckEmptyCommRow2:
	add	edi,2
	cmp	word ptr [edi],0
	loopz	CheckEmptyCommRow2
	jz	CmdEnd
	movzx	eax,Commands
	sub	eax,ecx
	cmp	al,CountedCommands
	jbe	CmdEnd2
	mov	CountedCommands,al
CmdEnd2:
	cmp	ecx,0
	jnz	CheckEmptyCommRow2
CmdEnd:
	pop	edi
NoCmdRemove:
;--------------------------

	pop	edi
	pop	ecx
	loop	CheckEmptyComm

	pop	edi
	pop	ecx
	add	edi,OldRowSize
	loop	CheckNextChan2

	bt	OptimBits,1
	jnc	NoCmdRemove2
	mov	al,CountedCommands
	mov	Commands,al
	mov	al,Channels
	mov	TempChannels,al
	mov	al,Commands
	mov	TempCommands,al
	call	FixPatternWidth
NoCmdRemove2:

O_RemoveCommandFinish:
	pop	CurrPatt2
	pop	word ptr Commands
	pop	word ptr Channels
	ret

O_CompressPattern:

	mov	edi,GUS_TempBuffPtr
	mov	esi,edi
	mov	ecx,1024*3/4
	xor	eax,eax
	rep	stosd

	mov	ebx,PatternOrderPtr
	mov	ebp,0
	movzx	ecx,Positions
O_DeterminePattLoopen:
	movzx	eax,word ptr [ebx+ebp*2]
	mov	byte ptr [esi+eax],1
	inc	ebp
	loop	O_DeterminePattLoopen

	mov	ebp,0
	mov	ecx,1024
O_DeterminePattLoopen2:
	cmp	dword ptr [AllocTable+ebp*8],0
	jz	NotAll
	mov	byte ptr [esi+ebp],1
NotAll:
	inc	ebp
	loop	O_DeterminePattLoopen2

	xor	dx,dx		;counter
	mov	ebx,esi
	add	ebx,1024	;ptr to new table
	mov	ecx,1024
	xor	ebp,ebp 	;table counter
O_FixTablePattLoopen:
	cmp	byte ptr [esi+ebp],1
	jnz	NoPattHerte
	mov	[ebx+ebp*2],dx
	inc	dx
NoPattHerte:
	inc	ebp
	loop	O_FixTablePattLoopen

	mov	esi,PatternOrderPtr
	xor	ebp,ebp
	movzx	ecx,Positions
O_CompressPattLoopen:
	movzx	eax,word ptr [esi+ebp*2]
	mov	ax,[ebx+eax*2]
	mov	word ptr [esi+ebp*2],ax
	inc	ebp
	loop	O_CompressPattLoopen

	xor	ebp,ebp
	xor	ecx,ecx
O_CompressPattLoopen2:
	cmp	dword ptr [AllocTable+ebp*8],0
	jz	NotAll2
	mov	edx,[AllocTable+ebp*8]
	mov	edi,[AllocTable+ebp*8+4]
	mov	[AllocTable+ebp*8],0
	mov	[AllocTable+ebp*8+4],0
	mov	cx,[ebx+ebp*2]
	mov	[AllocTable+ecx*8],edx
	mov	[AllocTable+ecx*8+4],edi
NotAll2:
	inc	ebp
	cmp	bp,1024
	jnz	O_CompressPattLoopen2
	ret

;--------------------------------
O_CheckInst:
	push	word ptr Channels
	push	word ptr Commands
	push	CurrPatt2
	mov	CurrPatt2,bp

	mov	edi,[AllocTable+ebp*8]
	cmp	edi,0
	jz	O_RemoveChannelFinish
	mov	al,byte ptr [edi+11]
	mov	ah,al
	and	al,31
	inc	al
	mov	Channels,al
	shr	ah,5
	mov	Commands,ah

	movzx	ecx,al		;Get RowSize and ChRowSize
	movzx	eax,ah
	lea	eax,[eax*2+2]
	mov	OldRowSize,eax
	mul	ecx
	mov	OldChRowSize,eax

	movzx	ebp,byte ptr [edi+10]
	inc	ebp
	add	edi,12

	xor	eax,eax
	mov	esi,GUS_TempBuffPtr
O_InstRemRowLoop:
	movzx	ecx,Channels
O_InstRemChanLoop:
	mov	al,[edi+1]
	cmp	byte ptr [esi+eax+512],0
	jz	O_ItExists

	cmp	byte ptr [edi],1		;Check for Note Off
	jz	O_DontExist
	cmp	byte ptr [edi+1],0		;Erase from patt
	jz	O_DontExist
	mov	word ptr [edi],0
	jmp	O_DontExist
O_ItExists:
	mov	word ptr [esi+eax*2],0

        GetOffset eax,ebx,ENV_Shadow		;Check if a shad.
	cmp	byte ptr [ebx],0
	jz	O_DontExist
        mov	al,byte ptr [ebx]
	mov	word ptr [esi+eax*2],0
O_DontExist:
	add	edi,OldRowSize
	loop	O_InstRemChanLoop
	dec	ebp
	jnz	O_InstRemRowLoop

	jmp	O_RemoveChannelFinish

;----------------------------
O_ChangeInstPatt:
	push	word ptr Channels
	push	word ptr Commands
	push	CurrPatt2
	mov	CurrPatt2,bp

	mov	edi,[AllocTable+ebp*8]
	cmp	edi,0
	jz	O_RemoveChannelFinish
	mov	al,byte ptr [edi+11]
	mov	ah,al
	and	al,31
	inc	al
	mov	Channels,al
	shr	ah,5
	mov	Commands,ah

	movzx	ecx,al		;Get RowSize and ChRowSize
	movzx	eax,ah
	lea	eax,[eax*2+2]
	mov	OldRowSize,eax
	mul	ecx
	mov	OldChRowSize,eax

	movzx	ebp,byte ptr [edi+10]
	inc	ebp
	add	edi,12

	xor	eax,eax
	mov	esi,GUS_TempBuffPtr
O_InstCompRowLoop:
	movzx	ecx,Channels
O_InstCompChanLoop:
	mov	al,[edi+1]
	mov	ax,word ptr [esi+eax*2]
	mov	[edi+1],al
	add	edi,OldRowSize
	loop	O_InstCompChanLoop
	dec	ebp
	jnz	O_InstCompRowLoop

	jmp	O_RemoveChannelFinish



;EBP from inst/samp
;EDX to inst/samp

CopySample:
	pushad

	push	edx
	mov	esi,SampleNamesPtr	;Copy Sample Name
	mov	eax,ebp
	sub	eax,16
	mov	ebx,22
	mul	ebx
	add	esi,eax
	pop	eax

	push	eax
	mov	edi,SampleNamesPtr
	sub	eax,16
	mov	ebx,22
	mul	ebx
	add	edi,eax
	pop	edx

	mov	ecx,22
	rep	movsb

	mov	esi,ebp
	mov	edi,edx
	mov	ecx,1
	jmp	Copy_CopySampInfo

CopyInstrument	Proc	Near
	pushad

	push	edx			;Copy Inst Name
	mov	esi,InstNamesPtr
	mov	eax,ebp
	dec	eax
	mov	ebx,30
	mul	ebx
	add	esi,eax
	pop	eax

	push	eax
	mov	edi,InstNamesPtr
	dec	eax
	mov	ebx,30
	mul	ebx
	add	edi,eax
	pop	edx

	mov	ecx,30
	rep	movsb

	push	edx
	mov	esi,SampleNamesPtr	;Copy Sample Name
	mov	eax,ebp
	dec	eax
	mov	ebx,22*16
	mul	ebx
	add	esi,eax
	pop	eax

	push	eax
	mov	edi,SampleNamesPtr
	dec	eax
	mov	ebx,22*16
	mul	ebx
	add	edi,eax
	pop	edx

	mov	ecx,22*16
	rep	movsb

	push	edx
	mov	esi,InstrumentInfo
	mov	eax,ebp
	dec	eax
	mov	ebx,716
	mul	ebx
	add	esi,eax
	pop	eax

	push	eax
	mov	edi,InstrumentInfo
	dec	eax
	mov	ebx,716
	mul	ebx
	add	edi,eax
	pop	edx

	mov	ecx,716
	rep	movsb

	mov	esi,ebp
	shl	esi,4
	mov	edi,edx
	shl	edi,4

	mov	ecx,16
Copy_CopySampInfo:
	mov	eax,[SampleOffsetStart+esi*4]
	mov	[SampleOffsetStart+edi*4],eax

	mov	eax,[LoopStart+esi*4]
	mov	[LoopStart+edi*4],eax

	mov	eax,[LoopEnd+esi*4]
	mov	[LoopEnd+edi*4],eax

	mov	eax,[SampleOffsetEnd+esi*4]
	mov	[SampleOffsetEnd+edi*4],eax

	mov	al,[FineTunes+esi]
	mov	[FineTunes+edi],al

	mov	ax,[SampleRates+esi*2]
	mov	[SampleRates+edi*2],ax

	mov	al,[Relativenote+esi]
	mov	[Relativenote+edi],al

	mov	al,[Volumes+esi]
	mov	[Volumes+edi],al

	mov	al,[VoiceControl+esi]
	mov	[VoiceControl+edi],al
	inc	esi
	inc	edi
	loop	Copy_CopySampInfo

	popad
	ret
CopyInstrument	EndP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;Prints a number with help from int 21h (DWORD)
;Calls: ebx = Number to print
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PrintNumber2	Proc	Near
	pushad
	xor	edi,edi
	xor	edx,edx
	mov	eax,1000000000
	mov	ecx,10
_dloopen:
	jmp	_db
_da:	inc	edx
_db:	mov	esi,ebx
	sub	ebx,eax
	jnb	_da
	mov	ebx,esi
	add	edx,'0'
	cmp	edi,1
	jz	_dc
	cmp	edx,'0'
	jz	_dd
_dc:
	mov	edi,1
	push	eax
	mov	ah,2
	int	21h
	pop	eax
_dd:
	push	ebx
	xor	edx,edx
	mov	ebx,10
	div	ebx
	pop	ebx
	xor	edx,edx

	loop	_dloopen
	mov	ecx,1
	mov	edx,'0'
	cmp	edi,0
	jz	_dc
	popad
	ret
PrintNumber2 endp

ReText1 db	"Velvet BIOS (C)1995 Velvet Development",10,13
	db	"BIOS Version 2.99.10.X3",10,10,10,13,"       KB",13,"$"
ReText2 db	10,10,13,"Please Wait...",7,10,10,13,"$"
ReText3 db	"KeyBoard.....Detected",10,10,10,13,"$"
ReText4 db	"DOS Already loaded, skipping...",10,13,"$"
Reboot:
	call	StopTimer
	call	DeInitSoundCard
	call	RestoreVector24
	call	SetOldInt9
	call	SetDrivePath
	mov	ax,3
	int	10h

	lea	edx,ReText1
	mov	ah,9
	int	21h

	xor	ebx,ebx
	mov	ecx,128
w1:	call	sync
	push	ecx
	add	ebx,128
	call	PrintNumber2
	mov	ah,2
	mov	dl,13
	int	21h
	pop	ecx
	loop	w1

l1:	in	al,64h			;Light KBD
	test	al,2
	jnz	l1
	mov	al,0edh
	out	60h,al
l2:	in	al,64h
	test	al,2
	jnz	l2
	mov	al,7
	out	60h,al

	mov	ecx,15
w5:	call	sync
	loop	w5

	lea	edx,ReText2
	mov	ah,9
	int	21h

l3:	in	al,64h			;Turn Off KbdLight
	test	al,2
	jnz	l3
	mov	al,0edh
	out	60h,al
l4:	in	al,64h
	test	al,2
	jnz	l4
	mov	al,0
	out	60h,al

	mov	ecx,70
w2:	call	sync
	loop	w2

	lea	edx,ReText3
	mov	ah,9
	int	21h

	mov	ecx,70
w3:	call	sync
	loop	w3

	lea	edx,ReText4
	mov	ah,9
	int	21h

	mov	ecx,70
w4:	call	sync
	loop	w4

	mov	ax,gs:[41ah]	;Clear KBD buffer
	mov	gs:[41ch],ax

	mov	byte ptr gs:[417h],0
	mov	byte ptr gs:[418h],0
	jmp	_exit

ResetTracker	db	0
Reset:
	mov	ah,0eh		;set origdrive
	lea	edx,CurrentPath
	mov	dl,[edx]
	sub	dl,'A'
	int	21h

	lea	edx,CurrentPath 	;set origpath
	mov	ecx,64+12
@@Scan:
	cmp	byte ptr [edx+ecx],'\'
	loopnz	@@Scan
	jnz	@@NoBackslash
	mov	byte ptr [edx+ecx+1],0
@@NoBackslash:

	mov	ah,3bh
	int	21h

	mov	ResetTracker,0
	movzx	edi,byte ptr gs:[480h]
	mov	ebx,edi
	add	edi,400h

	lea	esi,CurrentTrackerName
	xor	ecx,ecx
@@NxtChar:
	mov	al,[esi]
	cmp	al,0
	jz	@@LastChar
	mov	gs:[edi],al
	add	edi,2
	inc	esi
	inc	ecx
	jmp	@@NxtChar
@@LastChar:
	mov	byte ptr gs:[edi],13

	lea	ecx,[ecx*2+2]
	mov	gs:[41ah],bl
	add	bl,cl
	mov	gs:[41ch],bl
	jmp	_exit



StopAllVoices	Proc	Near
	push	ecx
	movzx	ecx,AllocChannels
StopVoices:
	cmp	cl,TuneChannelON
	jz	ATuneChannel
	call	StopOneVoice
ATuneChannel:
	loop	StopVoices
	pop	ecx
	ret
StopAllVoices	EndP


SineTune	Db 0,8,16,23,31,39,47,54,61,68,75,81,87,93,98,103,108,112,115,119,121,123,125,126,127,127,127,126,125,123,121,119,115,112,108,103,98,93,87,81,75,68,61,54,47,39,31,23,16,8,0,247,239,232,224,216,208,201,194,187,180,174,168,162,157,152,147,143,140,136,134,132,130,129,128,128,128,129,130,132,134,136,140,143,147,152,157,162,168,174,180,187,194,201,208,216,224,232,239,247,0,8,16,23
MuteSave	db	0
TuneNote	db	72-3
TuneChannel	db	0
TuneChannelON	db	-1
TuneForkOn:
	pushad
	mov	si,CurrentSample
	push	si

	mov	eax,100 		;100 bytes
	mov	ebx,1			;Use Sample 1
	mov	CurrentSample,bx
	mov	[VoiceControl+ebx],8	;8 bits, Loop
	call	AllocSample
	mov	[SampleOffsetStart+ebx*4],eax
	mov	[LoopStart+ebx*4],eax
	add	eax,100
	mov	[SampleOffsetEnd+ebx*4],eax
	mov	[LoopEnd+ebx*4],eax
	mov	[SampleRates+ebx*2],8363
	mov	[Volumes+ebx],7fh
	mov	[FineTunes+ebx],80h

	sub	eax,100
	lea	ebx,SineTune
	mov	ecx,104
	xor	edx,edx
	call	MoveTuneForkSample

	movzx	edx,TuneChannel
	mov	edi,edx
	mov	al,[Mute+edx]
	mov	MuteSave,al
	mov	[Mute+edx],2
	inc	dl
	mov	TuneChannelON,dl

	mov	ebx,1
	movzx	eax,TuneNote
	mov	edx,eax
	call	PlaySample

	pop	si
	mov	CurrentSample,si
	popad
	ret

TuneForkOff:
	pushad
	mov	si,CurrentSample
	push	si

	mov	eax,100 		;100 bytes
	mov	ebx,1			;Use Sample 1
	mov	CurrentSample,bx
	mov	esi,[SampleOffsetStart+ebx*4]
	call	DisAllocSample
	movzx	ecx,TuneChannel
	mov	al,MuteSave
	mov	[Mute+ecx],al
	inc	ecx
	call	StopOneVoice
	mov	TuneChannelON,-1

	pop	si
	mov	CurrentSample,si
	popad
	ret

PosUDrag:
	pushad
	mov	UdragStatus,1
	mov	ValueProPixel,0ffffh/32
	movzx	eax,Positions
	dec	eax
	mov	UdragMaxValue,eax
	mov	UdragMiniValue,0h
	lea	eax,CurrPosition
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,2
	lea	eax,ContPos
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret

PattUDrag:
	pushad
	lea	eax,CurrPatt
	mov	UdragVariableOffset,eax
	mov	UdragStatus,1
	mov	ValueProPixel,1024
	mov	UdragMaxValue,1023
	mov	UdragMiniValue,0
	mov	UdragVariableSize,2
	lea	eax,PattUDragmeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret

PattUDragmeanWhile:
	movzx	ebx,CurrPosition
	shl	ebx,1
	add	ebx,PatternOrderPtr
	mov	word ptr [ebx],ax
	jmp	ContPatt2

LenUDrag:
	pushad
	movzx	eax,Positions
	mov	TempDword,eax
	mov	UdragStatus,1
	mov	ValueProPixel,1024*2
	mov	UdragMaxValue,0ffffh
	mov	UdragMiniValue,1
	lea	eax,TempDword		;Positions
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,ContLen
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret

BPMUDrag:
	cmp	TempoDisabled,1
	jz	_ret
	pushad
	mov	UdragStatus,1
	mov	ValueProPixel,2*1024
	mov	UdragMaxValue,255
	mov	UdragMiniValue,32
	lea	eax,ModTempo+1
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,1
	lea	eax,BPMMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret

BPMMeanWhile:
	push	ax
	mov	ax,ModTempo
	mov	HertzAdder,ax
	pop	ax
	ret

InstUDrag:
	pushad
	mov	UdragStatus,1
	mov	ValueProPixel,1024/2
	movzx	eax,Samples
	mov	UdragMaxValue,eax
	mov	UdragMiniValue,1
	lea	eax,CurrentInstrument
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,1
	lea	eax,InstCont
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret

Patt3UDrag:
	pushad
	lea	eax,CurrPatt2
	mov	UdragVariableOffset,eax
	mov	UdragStatus,1
	mov	ValueProPixel,1024
	mov	UdragMaxValue,1023
	mov	UdragMiniValue,0
	mov	UdragVariableSize,2
	lea	eax,ContPlutt2
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret
PattLenUDrag:
	pushad
	call	CheckPatternStart_Edit
	mov	eax,CurrPattLength
	mov	TempDword,eax
	lea	eax,TempDword
	mov	UdragVariableOffset,eax
	mov	UdragStatus,1
	mov	ValueProPixel,1024
	mov	UdragMaxValue,255
	mov	UdragMiniValue,1
	mov	UdragVariableSize,3
	lea	eax,PattLenUDragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret
PattLenUDragMeanWhile:
	call	FixPatternLength
	ret

ChannelUDrag:
	pushad
	call	CheckPatternStart_Edit
	mov	al,Channels
	mov	TempChannels,al
	lea	eax,TempChannels
	mov	UdragVariableOffset,eax
	mov	UdragStatus,1
	mov	ValueProPixel,1024/4
	mov	UdragMaxValue,32
	mov	UdragMiniValue,1
	mov	UdragVariableSize,1
	lea	eax,ChanUDragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret

ChanUDragMeanWhile:
	pushad
	jmp	ChanUDragMeanWhile2

CommandsUDrag:
	pushad
	call	CheckPatternStart_Edit
	mov	al,Commands
	mov	TempCommands,al
	lea	eax,TempCommands
	mov	UdragVariableOffset,eax
	mov	UdragStatus,1
	mov	ValueProPixel,1024/8
	mov	UdragMaxValue,7
	mov	UdragMiniValue,1
	mov	UdragVariableSize,1
	lea	eax,CommandCont
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret

;	movzx	eax,Channels	;Get PatternSize
;	movzx	ebx,Commands
;	mov	ecx,CurrPattLength
GetPatternSize2  Proc	 Near
	pushad
	shl	ebx,1
	add	ebx,2
	mul	ebx
	mul	ecx
	mov	PatternSize2,eax
	popad
	ret
GetPatternSize2  EndP

;	movzx	eax,Channels	;Get RowSize and ChRowSize
;	movzx	ebx,Commands
GetRowSize2	 Proc	 Near
	pushad
	shl	ebx,1
	add	ebx,2
	mov	RowSize,ebx
	mul	ebx
	mov	ChRowSize,eax
	popad
	ret
GetRowSize2	 EndP


UndoPatt	dw	-1
StoreUndoBuffer Proc	Near
	pushad
	mov	ax,CurrPatt2
	mov	UndoPatt,ax
	call	CheckPatternStart_View
	mov	esi,PatternStart
	sub	esi,12
	cmp	esi,EmptyPattern
	jnz	NotTheEmptyPatt

	movzx	eax,DefaultChannels
	mov	TempChannels,al
	movzx	ebx,DefaultCommands
	mov	TempCommands,al
	movzx	ecx,DefaultRows

	call	GetRowSize2
	call	GetPatternSize2
	mov	ecx,PatternSize2
	add	ecx,12
	jmp	TheEmptyPattCont

NotTheEmptyPatt:
	movzx	ebx,CurrPatt2
	mov	ecx,[AllocTable+ebx*8+4]

TheEmptyPattCont:
	mov	eax,ecx
	mov	ebp,1044
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	edi,eax
	rep	movsb

	popad
	ret
StoreUndoBuffer EndP

SwapUndoBuffer	Proc	Near
	pushad

	call	CheckPatternStart_View
	mov	esi,PatternStart
	sub	esi,12
	cmp	esi,EmptyPattern
	jz	_retp

	cmp	UndoPatt,-1
	jz	_retp
	movzx	ebp,UndoPatt;CurrPatt2
	mov	eax,[AllocTable+ebp*8]
	mov	ebx,[AllocTable+ebp*8+4]
	xchg	[AllocTable+1044*8],eax
	xchg	[AllocTable+1044*8+4],ebx
	mov	[AllocTable+ebp*8],eax
	mov	[AllocTable+ebp*8+4],ebx

	mov	OldRow,-1
	mov	OldPatt2,-1

	cmp	bp,CurrPatt2
	jnz	_retp

	movzx	ecx,byte ptr [eax+10]	;PattLen
	inc	ecx

	mov	dl,[eax+11]		;Chan+Cmd
	mov	dh,dl
	and	dl,31
	inc	dl
	shr	dh,5
	mov	Channels,dl
	mov	Commands,dh
	mov	CurrPattLength,ecx

	add	eax,12
	mov	PatternStart,eax

	movzx	eax,Channels	;Get RowSize and ChRowSize
	movzx	ebx,Commands
	call	GetRowSize2

	mov	eax,CurrPattLength
	cmp	ax,CurrRow
	ja	_retp
	dec	ax
	mov	CurrRow,ax
	mov	GotoRow,ax

	popad
	ret
SwapUndoBuffer	EndP

;ebp->edx
MoveShadows:
	pushad
	movzx	ecx,Samples
	mov	ebx,ebp
	mov	ebp,1

@@NxtShadow:
	GetOffset ebp,eax,ENV_Shadow
	cmp	byte ptr [eax],bl
	jnz	@@NoShadow

	mov	byte ptr [eax],dl
@@NoShadow:
	inc	ebp
	loop	@@NxtShadow
	popad
	ret


;/ABS\02229022290254707436000020000200002000020397601851
