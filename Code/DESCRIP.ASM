;/ABS\00001010310000100001000010000100001000010000100001


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				    Variables
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²



EndOfLineMessage	db	1	;1=Messege 0=No Message
EndOfLineText		db	' END OF LINE                                                              '
DescShowLineOld 	db     -1

TheCapsLock		db	0	;0=CapsLockOff

DescX			dd     -1
DescY			dd     -1
DescXOld		dd     -1
DescYOld		dd     -1
DescEditNumber		dd     -1

WordWrap		db	0
LineWrap		db	0

;-1=don't care (and end)
;0	1	   2	  3	 4     5     6		  7	     8	       9	      10	      11	       12	      13       14
;On/off,LineOffset,Xstart,Ystart,Xsize,Ysize,AllocPointer,Menu_popup,Menu_down,Menu_upperleft,Menu_UpperRight,DescBufferOffset,DescBufferSize,Reserved,Reserved
;1=Here
DescTable		dd	0,0,24,225,74,17,1027,0,6,-1,-1,0,0,0,0
			dd	-1		 ; 35	   -1	   4
DescTableSize		equ	15



;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       DescKeyboard
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SaveRow 	db	100	dup(0)
DescKeyboard	Proc	Near
	pushad

	call	ScanTable
	sub	edi,Offset KeyBoardTable
	push	eax edx
	mov	eax,edi
	mov	edi,20
	xor	edx,edx
	div	edi
	mov	edi,eax
	pop	edx eax

	cmp	edi,1		;ESC
	jz	ExitDesc
	cmp	edi,28		;ENTER
	jz	DescEnter
	cmp	edi,89		;ENTER
	jz	DescEnter
	cmp	edi,96		;Arrow Up
	jz	DescUp
	cmp	edi,72		;Arrow Up
	jz	DescUp
	cmp	edi,98		;Arrow Left
	jz	DescLeft
	cmp	edi,75		;Arrow Left
	jz	DescLeft
	cmp	edi,99		;Arrow Right
	jz	DescRight
	cmp	edi,77		;Arrow Right
	jz	DescRight
	cmp	edi,101 	;Arrow Down
	jz	DescDown
	cmp	edi,80		;Arrow Down
	jz	DescDown
	cmp	edi,95		;Home
	jz	DescHome
	cmp	edi,71		;Home
	jz	DescHome
	cmp	edi,100 	;End
	jz	DescEndan
	cmp	edi,79		;End
	jz	DescEndan
	cmp	edi,103 	;Insert
	jz	DescInsert
	cmp	edi,82		;Insert
	jz	DescInsert
	cmp	edi,104 	;Delete
	jz	DescDelete
	cmp	edi,83		;Insert
	jz	NoDesc
	cmp	edi,14		;BackSpace
	jz	DescBackSpace
	cmp	edi,15		;Tab
	jz	DescTab
	cmp	edi,73
	jz	DescPageUp	;Page Up
	cmp	edi,97
	jz	DescPageUp	;Page Up
	cmp	edi,81
	jz	DescPageDown	;Page Down
	cmp	edi,102
	jz	DescPageDown	;Page Down
	cmp	edi,32
	jz	DelLine1	;D (delline)
	cmp	edi,21
	jz	DelLine2	;Y (delline)
BackCheck:
	cmp	edi,46
	jz	DescCenter	;C (center)
BackFromCenter:

	cmp	byte ptr [Keys+58],1
	jnz	AfterCapslock
	call	ToggleCapsLock
AfterCapslock:
	mov	esi,KeyBoard_AltGR		;If ALT GR is pressed
	cmp	byte ptr [Keys+0b8h],1
	jz	SearchKey_

	mov	esi,KeyBoard_Table		;If SHIFT is pressed
	cmp	byte ptr [Keys+2ah],1
	jz	ShiftIsPressed_
	cmp	byte ptr [Keys+36h],0
	jz	NOShift
ShiftIsPressed_:
	call	CapsLockSkip
	jc	DoShift
	cmp	TheCapsLock,1
	jz	SearchKey_
Doshift:
	mov	esi,KeyBoard_Shift
	jmp	SearchKey_
NoShift:
	call	CapsLockSkip
	jc	SearchKey_
	cmp	TheCapsLock,1
	jz	DoShift
SearchKey_:
	movzx	eax,byte ptr [esi]
	cmp	eax,0
	jz	QuitNotPut
	add	esi,2
	cmp	eax,edi
	jnz	SearchKey_
	mov	al,[esi-1]

	cmp	Insert,1
	jz	PutInsOn
					;Putta tecken. Insert off--------
PutInsOff:

	mov	ecx,eax 		;put
	mov	eax,desceditnumber
	mov	ebx,desctablesize*4
	mul	ebx
	lea	ebp,DescTable
	add	ebp,eax

	mov	eax,DescY
	mov	ebx,dword ptr [ebp+4*4]
	mul	ebx
	add	eax,DescX
	mov	esi,dword ptr [ebp+11*4]
	add	esi,eax
	mov	byte ptr [esi],cl

	mov	eax,dword ptr [ebp+3*4]
	mov	ebx,80
	mul	ebx
	mov	ebx,dword ptr [ebp+2*4]
	shr	ebx,3
	add	eax,ebx
	move	edi,0a0000h
	add	edi,eax
	mov	eax,DescY
	sub	eax,dword ptr [ebp+1*4]
	mov	ebx,13*80
	mul	ebx
	add	eax,DescX
	add	edi,eax
	movzx	ebx,cl
	call	mouseoff
	mov	ah,00000001b
	call	PutCharacter
	call	mouseon

	mov	eax,DescX		;move
	inc	eax
	cmp	eax,dword ptr [ebp+4*4]
	jb	nomatternow
	call	rowandwordwrap
	jmp	NowNexta
nomatternow:
	inc	DescX
	mov	DescXOld,-1
	call	MoveDescCursor
NowNexta:
	jmp	afterputta
PutInsOn:				;put insert on ---------
	mov	ecx,eax 		;put
	mov	eax,desceditnumber
	mov	ebx,desctablesize*4
	mul	ebx
	lea	ebp,DescTable
	add	ebp,eax

	call	getdescrow
	push	ecx
	mov	edi,ebx
	add	edi,DescX
	inc	edi
	lea	esi,saverow
	add	esi,DescX
	mov	ecx,dword ptr [ebp+4*4]
	sub	ecx,DescX
	dec	ecx
	jecxz	nomovas
	rep	movsb
nomovas:
	pop	ecx

	mov	edi,ebx
	add	edi,DescX
	mov	byte ptr [edi],cl

	call	putdescrow

	mov	eax,DescX		;move
	inc	eax
	cmp	eax,dword ptr [ebp+4*4]
	jb	nomatternow_
	call	rowandwordwrap
	jmp	NowNexta_
nomatternow_:
	inc	DescX
	mov	DescXOld,-1
	call	MoveDescCursor
NowNexta_:

AfterPutta:
QuitNotPut:
	popad
	ret

EnterNotShow	db	0
CapsLockTable	db	2,3,4,5,6,7,8,9,10,11,12,13,27,43,51,52,53,86,255
CapsLockSkip	proc	near	;*************************** Caps Lock Skip ***
	pushad
	lea	esi,CapsLockTable
	xor	eax,eax
CapsLockLoopen:
	cmp	byte ptr [esi],255
	jz	NotSpecial
	mov	al,byte ptr [esi]
	cmp	eax,edi
	jz	SpecialKey
	inc	esi
	jmp	CapsLockLoopen
NotSpecial:
	popad
	clc
	ret
SpecialKey:
	popad
	stc
	ret
CapsLockSkip	Endp
RowAndWordWrap:;-----------------------------
	pushad
	call	getoffseten
	cmp	WordWrap,1
	jz	DoWordWrap
	cmp	LineWrap,1
	jnz	wordwrapnull
					;LineWrap ----
DoLineWrap:
	call	GetDescRow
	mov	DescX,0
	mov	eax,DescY
	call	DescDown3
	cmp	snullebit,1
	jz	AfterWrap
	cmp	eax,DescY
	jz	NewEnter
	jmp	AfterWrap
NewEnter:
	mov	eax,dword ptr [ebp+4*4]
	dec	eax
	mov	DescX,eax
	mov	esi,ebx
	add	esi,eax
	mov	cl,[esi]
	mov	EnterNotShow,1
	call	DescEnter2
	mov	EnterNotShow,0
	call	GetDescRow
	mov	byte ptr [ebx],' '
	mov	byte ptr [ebx-1],cl

	mov	DescNowOffset,ebp
	call	DrawDesc
	mov	DescXold,-1
	call	MoveDescCursor
	jmp	AfterWrap
snullebit db 0
DoWordWrap:				;WordWrap ----
;0	1	   2	  3	 4     5     6		  7	     8	       9	      10	      11	       12	      13       14
;On/off,LineOffset,Xstart,Ystart,Xsize,Ysize,AllocPointer,Menu_popup,Menu_down,Menu_upperleft,Menu_UpperRight,DescBufferOffset,DescBufferSize,Reserved,Reserved
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	mov	snullebit,0
	call	GetDescRow
	mov	esi,ebx
	add	esi,DescX
	cmp	byte ptr [esi],' '
	jz	DoLineWrap

					;enter if need --
	mov	eax,DescY
	call	DescDown3
	cmp	eax,DescY
	jz	NewEnter2
	mov	DescY,eax
	jmp	NowWordWrap
NewEnter2:
	mov	eax,dword ptr [ebp+4*4]
	dec	eax
	mov	DescX,eax
	mov	esi,ebx
	add	esi,eax
	mov	cl,[esi]
	mov	EnterNotShow,1
	call	DescEnter2
	call	GetDescRow
	mov	byte ptr [ebx-1],cl	;--
	mov	byte ptr [ebx],' '
	mov	EnterNotShow,0
	mov	eax,dword ptr [ebp+4*4]
	dec	eax
	mov	DescX,eax
	dec	DescY
	call	GetDescRow
	mov	esi,ebx
	add	esi,DescX
	mov	snullebit,1
NowWordWrap:
	call	GetDescRow

	mov	ecx,dword ptr [ebp+4*4] ;text search
	xor	eax,eax
SearchBacka:
	cmp	byte ptr [esi],' '
	jz	AfterSearchat
	dec	esi
	inc	eax
	loop	SearchBacka
	inc	DescY
	mov	DescX,0
	mov	DescNowOffset,ebp
	call	DrawDesc
	mov	DescXOld,-1
	call	MoveDescCursor
	jmp	AfterWrap
AfterSearchat:

	cmp	Insert,0	;Insert --
	jz	NoInsertOnNow
	mov	esi,ebx
	add	esi,dword ptr [ebp+4*4]
	add	esi,dword ptr [ebp+4*4]
	dec	esi
	mov	edi,esi
	sub	esi,eax
	mov	ecx,dword ptr [ebp+4*4]
	sub	ecx,eax
	std
	rep	movsb
	cld
NoInsertOnNow:			;--
				;Move Text
	mov	esi,ebx
	add	esi,DescX
	inc	esi
	mov	edi,esi
	sub	esi,eax
	mov	ecx,eax
	rep	movsb
				;Clear text
	mov	edi,ebx
	add	edi,DescX
	inc	edi
	sub	edi,eax
	mov	ecx,eax
	push	eax
	mov	al,' '
	rep	stosb
	pop	eax

	mov	DescX,eax
	call	DescDown2
	mov	DescNowOffset,ebp ;Update Text
	call	DrawDesc
	mov	DescXold,-1
	call	MoveDescCursor
AfterWrap:
	mov	snullebit,0
	popad
	ret
wordwrapnull:
	mov	DescXOld,-1
	call	MoveDescCursor
	jmp	afterwrap
DescKeyboard	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Small Things
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DescSpecial	dd	0
NoDesc:
	popad
	ret
PutDescRow:;---------------------------------
;In	Ebx=Offset to row
	pushad
	call	getoffseten
	mov	esi,ebx
	mov	eax,dword ptr [ebp+3*4]
	mov	ebx,80
	mul	ebx
	mov	ebx,dword ptr [ebp+2*4]
	shr	ebx,3
	add	eax,ebx
	move	edi,0a0000h
	add	edi,eax
	mov	eax,DescY
	sub	eax,dword ptr [ebp+1*4]
	mov	ebx,13*80
	mul	ebx
	add	edi,eax
	call	mouseoff
	mov	ecx,dword ptr [ebp+4*4]
PuttaRow:
	movzx	ebx,byte ptr [esi]
	inc	esi
	mov	ah,00000001b
	call	PutCharacter
	inc	edi
	loop	PuttaRow
	call	mouseon
	popad
	ret
GetDescRow:;---------------------------------
;out	ebx=Offset To row
	pushad
	call	getoffseten
	mov	eax,DescY
	mov	ebx,dword ptr [ebp+4*4]
	mul	ebx
	mov	esi,dword ptr [ebp+11*4]
	add	esi,eax
	mov	DescSpecial,esi
	lea	edi,saverow
	mov	ecx,dword ptr [ebp+4*4]
	rep	movsb
	popad
	mov	ebx,DescSpecial
	ret



PutDescChar:;------------------------------
	pushad
	call	getoffseten
	mov	eax,DescY
	mov	ebx,dword ptr [ebp+4*4]
	mul	ebx
	mov	esi,dword ptr [ebp+11*4]
	add	esi,eax
	add	esi,DescX
	movzx	ecx,byte ptr [esi]

	mov	eax,dword ptr [ebp+3*4]
	mov	ebx,80
	mul	ebx
	mov	ebx,dword ptr [ebp+2*4]
	shr	ebx,3
	add	eax,ebx
	move	edi,0a0000h
	add	edi,eax
	mov	eax,DescY
	sub	eax,dword ptr [ebp+1*4]
	mov	ebx,13*80
	mul	ebx
	add	eax,DescX
	add	edi,eax
	movzx	ebx,cl
	call	mouseoff
	mov	ah,00000001b
	call	PutCharacter
	call	mouseon
	popad
	ret
ExitDesc:;-----------------------------------
	mov	DescX,-1
	mov	DescY,-1
	call	MoveDescCursor
	mov	DescEditNumber,-1
	popad
	ret
DescInsert:;---------------------------------
	xor	Insert,1
	mov	UpdateIt,1
	call	MoveDescCursor
	popad
	ret
DescLeft:;-----------------------------------
	cmp	LineWrap,0
	jz	NoWrappas
	cmp	DescX,0
	jnz	NoWrappas
	call	getoffseten
	cmp	DescY,0
	jz	NoLeftas
	mov	eax,dword ptr [ebp+4*4]
	dec	eax
	mov	DescX,eax
	jmp	DescUp
NoWrappas:
	cmp	DescX,0
	jz	NoLeftas
	dec	DescX
	call	MoveDescCursor
NoLeftas:
	popad
	ret
DescRight:;-----------------------------------
	call	getoffseten
	cmp	LineWrap,0
	jz	NoWrappas2
	mov	eax,dword ptr [ebp+4*4]
	dec	eax
	cmp	DescX,eax
	jnz	NoWrappas2
	mov	eax,dword ptr [ebp+12*4]
	mov	ebx,dword ptr [ebp+4*4]
	xor	edx,edx
	div	ebx
	dec	eax
	cmp	DescY,eax
	jz	NoRightas
	mov	DescX,0
	jmp	DescDown
NoWrappas2:
	mov	eax,dword ptr [ebp+4*4]
	dec	eax
	cmp	DescX,eax
	jz	NoRightas
	inc	DescX
	call	MoveDescCursor
NoRightas:
	popad
	ret
DescUp2: Pushad
DescUp:;--------------------------------------
	cmp	byte ptr [Keys+29],1
	jz	DescUpCTRL
	cmp	byte ptr [Keys+9dh],1
	jz	DescUpCTRL

	cmp	DescY,0
	jz	NoMoreUp

	call	getoffseten
	mov	eax,dword ptr [ebp+1*4]
	cmp	eax,DescY
	jb	NotUpWindow
	cmp	dword ptr [ebp+1*4],0
	jz	NotUpWindow
	dec	dword ptr [ebp+1*4]
	mov	DescNowOffset,ebp
	call	DrawDesc
	mov	DescXold,-1
NotUpWindow:
	dec	DescY
	call	MoveDescCursor
NoMoreUp:
	popad
	ret
DescDown3: pushad
	   jmp	afterafter
DescDown2: pushad
DescDown:;------------------------------------
	cmp	byte ptr [Keys+29],1
	jz	DescDownCTRL
	cmp	byte ptr [Keys+9dh],1
	jz	DescDownCTRL
afterafter:
	call	GetOffseten
	mov	eax,dword ptr [ebp+12*4]
	mov	ebx,dword ptr [ebp+4*4]
	xor	edx,edx
	div	ebx
	dec	eax
	cmp	eax,DescY
	jz	NoDescDown
	mov	ebx,dword ptr [ebp+1*4]
	add	ebx,dword ptr [ebp+5*4]
	dec	ebx
	cmp	DescY,ebx
	jb	NoExtraMove
	cmp	eax,dword ptr [ebp+1*4]
	jz	NoExtraMove
	inc	dword ptr [ebp+1*4]
	mov	DescNowOffset,ebp
	call	DrawDesc
	mov	DescXold,-1
NoExtraMove:
	inc	DescY
	call	MoveDescCursor
NoDescDown:
	popad
	ret


DescBackSpace:;------------------------------
	cmp	DescX,0
	jnz	DoItAnyway
	cmp	DescY,0
	jz	SkipBackSpace
DoItAnyway:
	call	getoffseten
	cmp	DescX,0
	jz	BackSpaceNewRow
	cmp	Insert,1
	jz	BackSpaceInsertOn
	mov	eax,DescY
	mov	ebx,dword ptr [ebp+4*4]
	mul	ebx
	add	eax,DescX
	dec	eax
	mov	esi,dword ptr [ebp+11*4]
	add	esi,eax
	mov	byte ptr [esi],' '
	dec	DescX
	call	putdescchar
	call	MoveDescCursor
	jmp	SkipBackSpace

BackSpaceInsertOn:
	call	GetDescRow
	push	ebx
	mov	esi,ebx
	add	esi,DescX
	mov	edi,esi
	dec	edi
	mov	ecx,dword ptr [ebp+4*4]
	sub	ecx,DescX
	rep	movsb
	add	ebx,dword ptr [ebp+4*4]
	dec	ebx
	mov	byte ptr [ebx],' '
	pop	ebx
	call	PutDescRow
	dec	DescX
	call	MoveDescCursor
	jmp	SkipBackSpace

BackSpaceNewRow:			;backspace new row---
	call	GetDescRow		;skip part
	mov	edi,ebx
	xor	eax,eax
	mov	ecx,dword ptr [ebp+4*4]
LeftaSearch:
	dec	edi
	inc	eax
	cmp	byte ptr [edi],' '
	jnz	HereOff
	loop	LeftaSearch
	dec	edi
	inc	eax
HereOff:
	cmp	eax,1
	jz	nonodeca
	dec	eax
	inc	edi
nonodeca:
	mov	DescSpecial,eax
	mov	ecx,eax
	mov	esi,ebx
	rep	movsb
					;skip line
	mov	edi,ebx
	mov	esi,ebx
	add	esi,dword ptr [ebp+4*4]
	mov	eax,dword ptr [ebp+12*4]
	mov	ebx,dword ptr [ebp+4*4]
	xor	edx,edx
	div	ebx
	dec	eax
	sub	eax,DescY
	mov	ebx,dword ptr [ebp+4*4]
	mul	ebx
	mov	ecx,eax
	rep	movsb

	push	ebp
	mov	ebx,dword ptr [ebp+4*4] 	;disalloc mem
	sub	dword ptr [ebp+12*4],ebx
	mov	esi,ebp
	mov	ebp,dword ptr [esi+6*4]
	mov	eax,dword ptr [esi+12*4]
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	dword ptr [esi+11*4],eax
	pop	ebp

	mov	eax,dword ptr [ebp+4*4] 	;move cursor, update
	sub	eax,DescSpecial
	mov	DescX,eax
	call	DescUp2
	mov	DescNowOffset,ebp
	call	DrawDesc
	mov	DescXold,-1
	call	MoveDescCursor

SkipBackSpace:
	popad
	ret
DescDelete:;-----------------------------------
	call	GetOffseten
	call	GetDescRow		;skip part
	mov	edi,ebx
	add	edi,DescX
	mov	ecx,dword ptr [ebp+4*4]
	sub	ecx,DescX
DelSearch:
	cmp	byte ptr [edi],' '
	jnz	DelSearchHopp
	inc	edi
	loop	DelSearch
	jmp	DelNewRow
DelSearchHopp:
	mov	edi,ebx
	add	edi,DescX
	mov	esi,edi
	inc	esi
	mov	ecx,dword ptr [ebp+4*4]
	sub	ecx,DescX
	dec	ecx
	jecxz	NowClearByte
	rep	movsb
NowClearByte:
	mov	byte ptr [edi],' '
	call	putdescrow
	mov	DescXold,-1
	call	MoveDescCursor
	jmp	EndOfDescDel
DelNewRow:				;Del New row -----
	mov	DescSpecial,ebx
	mov	eax,dword ptr [ebp+12*4]
	mov	ebx,dword ptr [ebp+4*4]
	xor	edx,edx
	div	ebx
	dec	eax
	sub	eax,DescY
	cmp	eax,0
	jz	EndOfDescDel

	mov	esi,DescSpecial
	add	esi,dword ptr [ebp+4*4]
	mov	edi,DescSpecial
	add	edi,DescX
	mov	ecx,dword ptr [ebp+4*4]
	sub	ecx,DescX
	rep	movsb

					;skip line
	mov	edi,DescSpecial
	add	edi,dword ptr [ebp+4*4]
	mov	esi,edi
	add	esi,dword ptr [ebp+4*4]
	mov	eax,dword ptr [ebp+12*4]
	mov	ebx,dword ptr [ebp+4*4]
	xor	edx,edx
	div	ebx
	dec	eax
	sub	eax,DescY
	mov	ebx,dword ptr [ebp+4*4]
	mul	ebx
	mov	ecx,eax
	rep	movsb

	push	ebp
	mov	ebx,dword ptr [ebp+4*4] 	;disalloc mem
	sub	dword ptr [ebp+12*4],ebx
	mov	esi,ebp
	mov	ebp,dword ptr [esi+6*4]
	mov	eax,dword ptr [esi+12*4]
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	dword ptr [esi+11*4],eax
	pop	ebp

	mov	DescNowOffset,ebp
	call	DrawDesc
	mov	DescXold,-1
	call	MoveDescCursor

EndOfDescDel:
	popad
	ret
DescHome:;------------------------------------
	mov	DescX,0
	call	MoveDescCursor
	popad
	ret
DescEndan:;------------------------------------
	call	GetOffseten
	call	GetDescRow
	mov	ecx,dword ptr [ebp+4*4]
	mov	esi,ecx
DescEndSearch:
	dec	esi
	cmp	byte ptr [esi+ebx],' '
	jnz	AfterSearch
	loop	DescEndSearch
	dec	esi
AfterSearch:
	inc	esi
	mov	edx,dword ptr [ebp+4*4]
	dec	edx
	cmp	esi,edx
	jbe	NoMattor
	mov	esi,edx
NoMattor:
	mov	DescX,esi
	call	MoveDescCursor
	popad
	ret

;-----------------------------------
ToggleCapsLock:
	xor	TheCapsLock,1
	mov	bl,TheCapsLock
	shl	bl,2

l1:	in	al,64h
	test	al,2
	jnz	l1
	mov	al,0edh
	out	60h,al
l2:	in	al,64h
	test	al,2
	jnz	l2
	mov	al,bl
	out	60h,al
	ret
;--------------------------------------
DescTab:
	call	GetOffseten
	cmp	byte ptr [Keys+2ah],1
	jz	TabBack
	cmp	byte ptr [Keys+36h],1
	jz	TabBack

	mov	eax,DescX
	shr	eax,3
	inc	eax
	shl	eax,3
	mov	DescX,eax
	mov	eax,dword ptr [ebp+4*4]
	dec	eax
	cmp	DescX,eax
	jbe	noOka
	mov	DescX,eax
noOka:
	call	MoveDescCursor
	popad
	ret
TabBack:			;tab back
	mov	eax,DescX
	shr	eax,3
	cmp	eax,0
	jz	nono
	dec	eax
nono:
	shl	eax,3
	mov	DescX,eax
	call	MoveDescCursor
	popad
	ret
DescPageUp:;--------------------------------------
	call	GetOffseten
	cmp	dword ptr [ebp+1*4],0
	jz	NoUpdateUp
	mov	eax,dword ptr [ebp+5*4]
	sub	dword ptr [ebp+1*4],eax
	cmp	dword ptr [ebp+1*4],0
	jge	noojs
	mov	dword ptr [ebp+1*4],0
noojs:
	mov	ecx,dword ptr [ebp+5*4]
	sub	DescY,ecx
	cmp	DescY,0
	jge	NoDescYY
	mov	DescY,0
NoDescYY:
	mov	DescNowOffset,ebp
	call	DrawDesc
	mov	DescXold,-1
	call	MoveDescCursor
NoUpdateUp:
	popad
	ret
DescPageDown:;--------------------------------------
	call	GetOffseten
	mov	eax,dword ptr [ebp+12*4]
	mov	ebx,dword ptr [ebp+4*4]
	xor	edx,edx
	div	ebx
	dec	eax
	cmp	dword ptr [ebp+1*4],eax
	jz	NoDownas

	mov	ebx,dword ptr [ebp+5*4]
	add	dword ptr [ebp+1*4],ebx
	cmp	dword ptr [ebp+1*4],eax
	jbe	noSora
	mov	dword ptr [ebp+1*4],eax
noSora:
	mov	ecx,dword ptr [ebp+5*4]
	add	DescY,ecx
	cmp	DescY,eax
	jbe	noVickis
	mov	DescY,eax
noVickis:
;	 mov	 ebx,dword ptr [1*4]
;	 cmp	 DescY,ebx
;	 jae	 nohappend
 ;
;nohappend:

	mov	DescNowOffset,ebp
	call	DrawDesc
	mov	DescXold,-1
	call	MoveDescCursor
NoDownas:
	popad
	ret
DescEnter2: pushad
DescEnter:;----------------------------------
	call	GetOffseten

	pushad
	mov	ebx,dword ptr [ebp+4*4] 	;alloc mem
	add	dword ptr [ebp+12*4],ebx
	mov	esi,ebp
	mov	ebp,dword ptr [esi+6*4]
	mov	eax,dword ptr [esi+12*4]
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	dword ptr [esi+11*4],eax
	jc	nomoremem
	popad
	call	GetDescRow

	mov	edi,dword ptr [ebp+11*4]	;move text down
	add	edi,dword ptr [ebp+12*4]
	dec	edi
	mov	esi,edi
	sub	esi,dword ptr [ebp+4*4]
	mov	eax,DescY
	add	eax,2
	mov	ecx,dword ptr [ebp+4*4]
	mul	ecx
	mov	ecx,dword ptr [ebp+12*4]
	sub	ecx,eax
	std
	rep	movsb
	cld

	mov	edi,ebx 			;move down end row
	add	edi,dword ptr [ebp+4*4]
	mov	esi,ebx
	add	esi,DescX
	mov	ecx,dword ptr [ebp+4*4]
	sub	ecx,DescX
	rep	movsb

	mov	ecx,DescX			;clear rest row
	mov	al,' '
	rep	stosb

	mov	edi,ebx 			;clear first row
	add	edi,DescX
	mov	ecx,dword ptr [ebp+4*4]
	sub	ecx,DescX
	mov	al,' '
	rep	stosb

	mov	DescX,0
	call	DescDown2

	cmp	EnterNotShow,1
	jz	skipshowenter
	mov	DescNowOffset,ebp
	call	DrawDesc
	mov	DescXold,-1
	call	MoveDescCursor
skipshowenter:
	popad
	ret
NoMoreMem:
	popad
	popad
	ret
DelLine1:;-----------------------------------
	cmp	byte ptr [Keys+56],1
	jz	DelTheLine
	jmp	BackCheck
DelLine2:
	cmp	byte ptr [Keys+29],1
	jz	DelTheLine
	cmp	byte ptr [Keys+9dh],1
	jz	DelTheLine
	jmp	BackCheck
DelTheLine:				;DelLine
	call	GetOffseten
	call	GetDescRow

	mov	eax,dword ptr [ebp+12*4]
	mov	ecx,dword ptr [ebp+4*4]
	xor	edx,edx
	div	ecx
	dec	eax
	cmp	eax,DescY
	jz	DelCurrentLine
					;skip line
	mov	edi,ebx
	mov	esi,ebx
	add	esi,dword ptr [ebp+4*4]
	mov	eax,dword ptr [ebp+12*4]
	mov	ebx,dword ptr [ebp+4*4]
	xor	edx,edx
	div	ebx
	dec	eax
	sub	eax,DescY
	mov	ebx,dword ptr [ebp+4*4]
	mul	ebx
	mov	ecx,eax
	rep	movsb

	push	ebp
	mov	ebx,dword ptr [ebp+4*4] 	;disalloc mem
	sub	dword ptr [ebp+12*4],ebx
	mov	esi,ebp
	mov	ebp,dword ptr [esi+6*4]
	mov	eax,dword ptr [esi+12*4]
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	dword ptr [esi+11*4],eax
	pop	ebp
LineUpdate:				  ;update
	mov	DescNowOffset,ebp
	call	DrawDesc
	mov	DescXold,-1
	call	MoveDescCursor
SkipDelLine:
	popad
	ret
DelCurrentLine:
	mov	edi,ebx
	mov	ecx,dword ptr [ebp+4*4]
	mov	al,' '
	rep	stosb
	jmp	LineUpdate
DescCenter:;----------------------------------
	cmp	byte ptr [Keys+29],1
	jz	DoCenter
	cmp	byte ptr [Keys+9dh],1
	jz	DoCenter
	jmp	BackFromCenter
DoCenter:
	call	GetOffseten
	call	GetDescRow

	mov	esi,ebx 		;search first character
	mov	ecx,dword ptr [ebp+4*4]
SearchTexten:
	cmp	byte ptr [esi],' '
	jnz	NowCenter
	inc	esi
	loop	SearchTexten
	jmp	SkipToCenter
NowCenter:

	lea	edi,SaveRow
	push	ebx			;move text -> save
	mov	edx,ecx
	xor	ebx,ebx
MoveOver:
	lodsb
	inc	ebx
	cmp	al,' '
	jz	noresetta
	xor	ebx,ebx
noresetta:
	stosb
	loop	MoveOver

	mov	ecx,dword ptr [ebp+4*4]
	sub	ecx,edx
	add	ecx,ebx
	shr	ecx,1
	pop	edi
	lea	esi,SaveRow
	sub	edx,ebx
	mov	ebx,ecx
	mov	al,' '
	rep	stosb
	mov	ecx,edx
	add	ebx,ecx
	rep	movsb
	mov	ecx,dword ptr [ebp+4*4]
	sub	ecx,ebx
	mov	al,' '
	rep	stosb

	mov	DescNowOffset,ebp
	call	DrawDesc
	mov	DescXold,-1
	call	MoveDescCursor
SkipToCenter:
	popad
	ret
DescUpCTRL:;----------------------------------
	call	GetOffseten
	cmp	dword ptr [ebp+1*4],0
	jz	NotDescUpCTRL
	dec	dword ptr [ebp+1*4]
	dec	DescY

	mov	DescNowOffset,ebp
	call	DrawDesc
	mov	DescXold,-1
	call	MoveDescCursor
NotDescUpCTRL:
	popad
	ret
DescDownCTRL:;--------------------------------
	call	GetOffseten
	mov	eax,dword ptr [ebp+12*4]
	mov	ebx,dword ptr [ebp+4*4]
	xor	edx,edx
	div	ebx
	dec	eax
	cmp	eax,DescY
	jz	NotDescUpCTRL
	inc	dword ptr [ebp+1*4]
	inc	DescY
	mov	DescNowOffset,ebp
	call	DrawDesc
	mov	DescXold,-1
	call	MoveDescCursor
NotDescDownCTRL:
	popad
	ret
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
GetOffseten:;---------------------------------
	push	eax ebx ecx
	mov	ecx,eax
	mov	eax,desceditnumber
	mov	ebx,desctablesize*4
	mul	ebx
	lea	ebp,DescTable
	add	ebp,eax
	pop	ecx ebx eax
	ret
;0	1	   2	  3	 4     5     6		  7	     8	       9	      10	      11	       12	      13       14
;On/off,LineOffset,Xstart,Ystart,Xsize,Ysize,AllocPointer,Menu_popup,Menu_down,Menu_upperleft,Menu_UpperRight,DescBufferOffset,DescBufferSize,Reserved,Reserved
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       MoveDescCursor
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
UpdateIT	db	0
MoveDescCursor	Proc	Near
	pushad
	cmp	DescEditNumber,-1
	jz	EndItNowDesc

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	call	getoffseten		;kanta uppe
	mov	eax,dword ptr [ebp+1*4]
	cmp	DescY,eax
	jae	nokanta1
	mov	DescY,eax
nokanta1:				;kanta nere
	mov	eax,dword ptr [ebp+1*4]
	add	eax,dword ptr [ebp+5*4]
	dec	eax
	cmp	DescY,eax
	jbe	nokanta2
	mov	DescY,eax
nokanta2:


	lea	ebp,DescTable
	mov	eax,DescEditNumber
	mov	ebx,DescTableSize*4
	mul	ebx
	add	ebp,eax

	cmp	UpdateIT,1
	jz	NotSkippas
	mov	eax,DescY
	cmp	eax,DescYOld
	jnz	NotSkippas
	mov	eax,DescX
	cmp	eax,DescXOld
	jz	SkipAllMove
NotSkippas:
	mov	UpdateIT,0
	cmp	DescXOld,-1
	jz	SkipHideCursor
						;Hide Cursor
	mov	eax,dword ptr [ebp+3*4]
	mov	ebx,80
	mul	ebx
	mov	ebx,dword ptr [ebp+2*4]
	shr	ebx,3
	add	ebx,eax
	mov	eax,DescYOld
	sub	eax,dword ptr [ebp+1*4]
	mov	ecx,80*13
	mul	ecx
	add	eax,ebx
	add	eax,DescXOld
	move	edi,0a0000h
	add	edi,eax

	mov	esi,dword ptr [ebp+11*4]
	mov	eax,DescYOld
	mov	ebx,dword ptr [ebp+4*4]
	mul	ebx
	add	eax,DescXOld
	add	esi,eax
	movzx	ebx,byte ptr [esi]

	call	mouseoff
	mov	ah,00000001b
	call	PutCharacter
	call	mouseon
SkipHideCursor:

	cmp	DescX,-1
	jz	SkipShowCursor
						;Show Cursor
	mov	eax,dword ptr [ebp+3*4]
	mov	ebx,80
	mul	ebx
	mov	ebx,dword ptr [ebp+2*4]
	shr	ebx,3
	add	ebx,eax
	mov	eax,DescY
	sub	eax,dword ptr [ebp+1*4]
	mov	ecx,80*13
	mul	ecx
	add	eax,ebx
	add	eax,DescX
	move	edi,0a0000h
	add	edi,eax

	call	mouseoff
	mov	ah,00000001b		;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh 		;Set bitplane (read)
	mov	ah,0
	mov	al,4
	out	dx,ax

	mov	ecx,12
	mov	al,-1
	cmp	Insert,1
	jz	DoInserta
	mov	ecx,6
	add	edi,80*6
DoInserta:
	xor	byte ptr [edi],al
	add	edi,80
	loop	DoInserta
SkipShowCursor:
	call	mouseon
SkipAllMove:
	mov	eax,DescX
	mov	DescXOld,eax
	mov	eax,DescY
	mov	DescYOld,eax
EndItNowDesc:
	popad
	ret
MoveDescCursor	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Desc Handler
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DescCountern	dd	0
DescNowOffset	dd	0
DescSkipTable	dw	325,456,508,472
		dw	622,223,633,449
		dw	-1
DescHandler	Proc	Near
	pushad

						;Check each editor
	lea	esi,DescTable
	mov	DescCountern,0
CheckDesc:

	mov	ebp,1
	cmp	dword ptr [esi+7*4],-1
	jz	GoAndLoop1
	movzx	 eax,Menu_popup
	cmp	eax,[esi+7*4]
	jnz	NotSame
GoAndLoop1:
	cmp	dword ptr [esi+8*4],-1
	jz	GoAndLoop2
	movzx	eax,Menu_downscreen
	cmp	eax,[esi+8*4]
	jnz	NotSame
GoAndLoop2:
	cmp	dword ptr [esi+9*4],-1
	jz	GoAndLoop3
	movzx	eax,Menu_UpperLeft
	cmp	eax,[esi+9*4]
	jnz	NotSame
GoAndLoop3:
	cmp	dword ptr [esi+10*4],-1
	jz	GoAndLoop4
	movzx	eax,Menu_UpperScreen
	cmp	eax,[esi+10*4]
	jz	GoAndLoop4
NotSame:
	xor	ebp,ebp
GoAndLoop4:
	pushad

	cmp	ebp,0
	jz	NotSameHereFredrik
	mov	al,DescShowLine
	cmp	al,DescShowLineOld
	jz	NotSameHereFredrik
	call	DrawDesc
	cmp	Menu_Popup,0
	jnz	NotSameHereFredrik
	call	DrawDesc
NotSameHereFredrik:
				;------------------ Handler
	mov	DescNowOffset,esi		;put new
	cmp	dword ptr [esi],1
	jz	WindowIshere
	cmp	ebp,0
	jz	AfterNewRop
	mov	dword ptr [esi],1
	call	DrawDesc
	jmp	AfterNewRop
WindowIsHere:
	cmp	ebp,1
	jz	AfterNewRop
	mov	dword ptr [esi],0
AfterNewRop:

	cmp	MouseB,0			;mouse check
	jz	NoMouseDown
	cmp	ebp,0
	jz	NoMouseDown
	cmp	DescEditNumber,-1
	jz	SkopCheck
	mov	eax,DescCountern
	cmp	DescEditNumber,eax
	jnz	NoMouseDown
Skopcheck:
	movzx	eax,mouseX
	movzx	ebx,mouseY
	cmp	eax,dword ptr [esi+2*4]
	jb	MouseOutSide
	cmp	ebx,dword ptr [esi+3*4]
	jb	MouseOutSide
	mov	ecx,dword ptr [esi+4*4]
	shl	ecx,3
	push	eax
	push	ebx
	mov	eax,dword ptr [esi+5*4]
	mov	ebx,13
	mul	ebx
	mov	edx,eax
	pop	ebx
	pop	eax
	add	ecx,dword ptr [esi+2*4]
	add	edx,dword ptr [esi+3*4]
	cmp	eax,ecx
	jae	MouseOutSide
	cmp	ebx,edx
	jae	MouseOutSide

	mov	ecx,DescCountern
	mov	DescEditNumber,ecx
	sub	eax,dword ptr [esi+2*4]
	sub	ebx,dword ptr [esi+3*4]
	shr	eax,3
	mov	DescX,eax
	mov	eax,ebx
	mov	ebx,13
	xor	edx,edx
	div	ebx
	add	eax,dword ptr [esi+1*4]
	mov	ecx,eax
	mov	eax,dword ptr [esi+12*4]
	mov	ebx,dword ptr [esi+4*4]
	xor	edx,edx
	div	ebx
	dec	eax
	cmp	ecx,eax
	jbe	noSetMaxas
	mov	ecx,eax
noSetMaxas:
	mov	DescY,ecx
	call	MoveDescCursor
	jmp	NoMouseDown
MouseOutSide:
					;skiptable search xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	cmp	pullmode,0
	jnz	nomousedown
	lea	esi,descskiptable
	mov	ax,MouseX
	mov	bx,MouseY
searchspecial:
	cmp	word ptr [esi],-1
	jz	doitanyway22
	cmp	ax,[esi]
	jb	outas1
	cmp	ax,[esi+4]
	ja	outas1
	cmp	bx,[esi+2]
	jb	outas1
	cmp	bx,[esi+6]
	ja	outas1
	jmp	NoMouseDown
outas1:
	add	esi,8
	jmp	searchspecial
doitanyway22:
	mov	eax,DescCountern
	cmp	eax,DescEditNumber
	jnz	NoMouseDown
	mov	DescX,-1
	mov	DescY,-1
	call	MoveDescCursor
	mov	DescEditNumber,-1
NoMouseDown:


SkipThisEditor:
				;------------------

	cmp	Menu_Popup,0
	jnz	SnyggaJansson
	mov	al,DescShowLine
	mov	DescShowLineOld,al
SnyggaJansson:
	popad
	inc	DescCountern
	add	esi,DescTableSize*4
	cmp	dword ptr [esi],-1
	jnz	CheckDesc

	popad
	ret
DescHandler	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Init Desc
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
InitDesc	Proc	Near
	pushad

	lea	esi,DescTable
InitLoopen:
	cmp	dword ptr [esi],-1
	jz	AfterInitLoopen
	mov	ebx,dword ptr [esi+6*4]
	shl	ebx,3
	mov	eax,dword ptr [AllocTable+ebx]
	mov	dword ptr [esi+11*4],eax
	mov	eax,dword ptr [AllocTable+ebx+4]
	mov	dword ptr [esi+12*4],eax
	add	esi,DescTableSize*4
	jmp	InitLoopen
AfterInitLoopen:

	popad
	ret
InitDesc	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Move Desc Up
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: eax=descnumber
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MoveDescUp	Proc	Near
	pushad
	mov	ebx,DescTableSize*4
	mul	ebx
	lea	ebx,DescTable
	add	ebx,eax
	mov	DescNowOffset,ebx

	call	fixbutton
	cmp	dword ptr [ebx+4],0
	jz	EndItta
	dec	dword ptr [ebx+4]
	call	DrawDesc
	mov	DescXOld,-1
	call	MoveDescCursor
EndItta:
	popad
	ret
MoveDescUp	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Move Desc Down
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: eax=desc number
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MoveDescDown	Proc	Near
	pushad
	mov	ebx,DescTableSize*4
	mul	ebx
	lea	ebx,DescTable
	add	eax,ebx
	mov	esi,eax
	mov	DescNowOffset,eax

	call	fixbutton
	mov	eax,dword ptr [esi+12*4]
	xor	edx,edx
	mov	ebx,dword ptr [esi+4*4]
	div	ebx
	dec	eax
	cmp	dword ptr [esi+4],eax
	jae	EndItta2
	inc	dword ptr [esi+4]
	call	DrawDesc
	mov	DescXOld,-1
	call	MoveDescCursor
EndItta2:
	popad
	ret
MoveDescDown	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Desc Move
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
DescUp0:
	pushad
	mov	eax,0
	call	MoveDescUp
	popad
	ret
DescDown0:
	pushad
	mov	eax,0
	call	MoveDescDown
	popad
	ret
;DescUp1:
;	pushad
;	mov	eax,1
;	call	MoveDescUp
;	popad
;	ret
;DescDown1:
;	pushad
;	mov	eax,1
;	call	MoveDescDown
;	popad
;	ret


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Draw Desc
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ShowLines	dd	0
DrawDesc	Proc	Near
	pushad
	cmp	menu_downscreen,6
	jnz	_retp
	mov	ebp,DescNowOffset

	mov	eax,dword ptr [ebp+1*4]
	mov	ecx,dword ptr [ebp+4*4]
	mul	ecx
	mov	esi,dword ptr [ebp+11*4]
	add	esi,eax

	mov	eax,dword ptr [ebp+3*4]
	mov	ebx,80
	mul	ebx
	mov	ebx,dword ptr [ebp+2*4]
	shr	ebx,3
	add	eax,ebx
	move	edi,0a0000h
	add	edi,eax

	mov	eax,dword ptr [ebp+12*4]	;Draw text
	xor	edx,edx
	mov	ebx,dword ptr [ebp+4*4]
	div	ebx
	sub	eax,dword ptr [ebp+1*4]
	mov	ecx,eax
	cmp	ecx,dword ptr [ebp+5*4]
	jbe	NotOver
	mov	ecx,dword ptr [ebp+5*4]
NotOver:
	mov	ShowLines,ecx
	cmp	ecx,0
	jz	DrawItts
	call	mouseoff
	mov	ah,00000001b
DrawDescLoop0:
	push	ecx
	push	edi
	mov	ecx,dword ptr [ebp+4*4]
DrawDescLoop1:
	movzx	ebx,byte ptr [esi]
	inc	esi
	call	PutCharacter
	inc	edi
	loop	DrawDescLoop1
	pop	edi
	add	edi,80*13
	pop	ecx
	loop	DrawDescLoop0
DrawItts:
						;Draw end of line
	cmp	DescShowLine,0
	jz	NoLineNow
	mov	eax,dword ptr [ebp+5*4]
	cmp	ShowLines,eax
	jae	NoLineNow
	lea	esi,EndOfLineText

	mov	ah,00000001b		;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh 		;Set bitplane (read)
	mov	ah,0
	mov	al,4
	out	dx,ax
	mov	ah,00000001b
	push	edi
	mov	ecx,dword ptr [ebp+4*4]
DrawEndText:
	push	ecx
	movzx	ebx,byte ptr [esi]
	inc	esi
	call	PutCharacter
	mov	ecx,12
	xor	ebx,ebx
DrawMoreLoop:
	xor	byte ptr [ebx+edi],0ffh
	add	ebx,80
	loop	DrawMoreLoop

	inc	edi
	pop	ecx
	loop	DrawEndText
	pop	edi
	inc	ShowLines
	add	edi,80*13
NoLineNow:
					;Clear rest
	mov	eax,dword ptr [ebp+5*4]
	cmp	ShowLines,eax
	jae	AftertheClearas
	mov	ecx,dword ptr [ebp+5*4]
	sub	ecx,ShowLines
	xor	eax,eax
LineToClear:
	push	ecx
	mov	ecx,13
Clearas:
	push	ecx
	push	edi
	mov	ecx,dword ptr [ebp+4*4]
	rep	stosb
	pop	edi
	add	edi,80
	pop	ecx
	loop	Clearas
	pop	ecx
	loop	LineToClear

AftertheClearas:
	call	mouseon
NoDrawDesc:
	popad
	ret
DrawDesc	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Description Start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DescriptionStart2:
	pushad
	jmp	AfterDescStart
DescriptionStart	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	descend

AfterDescStart:
	mov	Zoom,0
	cmp	menu_downscreen,6
	jz	DescriptionEnd2

	mov	ebp,1024
	mov	eax,0
	call	memalloc
	mov	ebp,1025
	mov	eax,0
	call	memalloc

ollesskit:
	mov	menu_downscreen,6
	call	menuhandler
	cmp	PianoScreen,0
	jz	@@NoPoa3
	call	MenuPiano
@@NoPoa3:
	mov	PutDescXold,-2
	mov	PutDescYold,-2
	call	PutWrapStatus
	mov	OldCurrentDescLine,-1

descend:
	Popad
	Ret
DescriptionStart	 EndP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Description End
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DescriptionEnd		Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	descendofend
DescriptionEnd2:
	call	ShowMainPattern
descendofend:
	Popad
	Ret
DescriptionEnd		 EndP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Put Desc Cords
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PutDescXold	dd     -1
PutDescYold	dd     -1
PutDescCords	Proc	Near
	pushad
	cmp	Menu_DownScreen,6
	jnz	SkipDescCords
	cmp	Menu_Popup,0
	jnz	SkipDescCords
	cmp	DescEditNumber,-1
	jz	PutDescCords2
	cmp	DescEditNumber,0
	jnz	SkipDescCords
	mov	eax,DescX
	cmp	PutDescXold,eax
	jnz	DoItNowa
	mov	eax,DescY
	cmp	PutDescYold,eax
	jz	SkipDescCords
DoItNowa:
	call	mouseoff
	mov	ah,00001000b
	mov	cl,4
	move	edi,0a0000h+80*459+32/8
	mov	ebx,DescY
	call	PutDecimal
	mov	ah,00001000b
	mov	cl,4
	move	edi,0a0000h+80*459+88/8
	mov	ebx,DescX
	call	PutDecimal
	call	mouseon

	mov	eax,DescX
	mov	PutDescXold,eax
	mov	eax,DescY
	mov	PutDescYold,eax
SkipDescCords:
	popad
	ret
PutDescCords2:
	cmp	PutDescXold,-1
	jz	SkipDescCords
	mov	PutDescXold,-1
	mov	PutDescYold,-1
	call	mouseoff
	mov	ah,00001000b
	mov	cl,4
	move	edi,0a0000h+80*459+32/8
	mov	ebx,0
	call	PutDecimal
	mov	ah,00001000b
	mov	cl,4
	move	edi,0a0000h+80*459+88/8
	mov	ebx,0
	call	PutDecimal
	call	mouseon
	popad
	ret
PutDescCords	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Wrap things
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PutWrapStatus		Proc	Near	;--------------------------------
	pushad
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	call	mouseoff
	mov	ButtonX1,325	;LineWrap
	mov	ButtonY1,456
	mov	ButtonX2,416
	mov	ButtonY2,472
	mov	bl,LineWrap
	xor	bl,1
	call	ButtonUpDown

	mov	ButtonX1,417	;WordWrap
	mov	ButtonY1,456
	mov	ButtonX2,508
	mov	ButtonY2,472
	mov	bl,WordWrap
	xor	bl,1
	call	ButtonUpDown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	call	mouseon
	popad
	ret
PutWrapStatus		Endp
ChangeLineStatus	Proc	Near	;--------------------------------
	pushad
	xor	LineWrap,1
	call	PutWrapStatus
	popad
	ret
ChangeLineStatus	Endp
ChangeWordStatus	Proc	Near	;--------------------------------
	pushad
	xor	WordWrap,1
	call	PutWrapStatus
	popad
	ret
ChangeWordStatus	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       DescKeyboard
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DescClear	Proc	Near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	call	ClearDescription
	popad
	ret
DescClear	Endp
