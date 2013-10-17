;/ABS\00113001130011300113001130011300113001130011300113
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			      Position editor Start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PositionEditor2:
	pushad
	jmp	PositionEditor3
PositionEditor	  Proc	  Near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	PosEdEnd
PositionEditor3:
	cmp	menu_upperleft,1
	jz	PositionEditorExit3

	mov	menu_upperleft,1
	call	menuhandler
	call	ShowPosList

PosEdend:
	popad
	ret
PositionEditor	 Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Position editor Exit
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PositionEditorExit	 Proc	 Near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	PosExitEnd
PositionEditorExit3:
	mov	menu_upperleft,2
	call	menuhandler
	mov	OldPos2,-1
	mov	OldPattName,-1
	call	PrintPattInfo

PosExitEnd:
	popad
	ret
PositionEditorExit	 Endp

PosEditorSquare:
	movzx	eax,MouseY
	sub	eax,117
	mov	ebx,12
	xor	edx,edx
	div	ebx
	movzx	ebx,CurrStartPosition
	add	ebx,eax
	cmp	bx,Positions
	jae	Dummy
	mov	CurrCursorPosition,bx
	mov	al,100
	mov	LeftKeyWait,al
	call	ShowPosList

PosEditorInput2:
	movzx	eax,CurrCursorPosition
	mov	ebx,eax
	call	GoToPosition

	sub	ax,CurrStartPosition
	mov	OldPattName,-1
	shl	ebx,1
	add	ebx,PatternOrderPtr
	mov	ebp,ebx
	movzx	ebx,word ptr [ebx]
	mov	CurrPatt,bx
	mov	CurrPatt2,bx

	cmp	MouseB,1
	jz	NoInputt
	push	ebx
	mov	ebx,12*80
	mul	ebx
	mov	edi,118*80+56/8
	add	edi,eax
	pop	ebx

	mov	ecx,4
	mov	ax,0101h
	mov	DigitTarget,ebp
	mov	DigitSize,2
	mov	DigitLimit,1023
	mov	DigitInput,12
	call	InputDigits
	mov	PosedInput,1
	ret
NoInputt:
	call	ShowPosList
	ret

PatternEditorDelete:
	movzx	ecx,Positions
	movzx	edi,CurrCursorPosition
	dec	ecx
	jecxz	NoMoreDeletePatt
	sub	ecx,edi

	shl	edi,1
	add	edi,PatternOrderPtr
	mov	esi,edi
	add	esi,2
	rep	movsw
	movzx	ebx,CurrCursorPosition
	call    GoToPosition
	jmp	DecreaseLength2
NoMoreDeletePatt:
	ret
PatternEditorInsert:
	movzx	ecx,Positions
	movzx	eax,CurrCursorPosition
	inc	cx
	cmp	ecx,0
	jz	NoMoreInsertPatt
	mov	edi,ecx
	shl	edi,1
	sub	ecx,eax

	push	eax
	mov	eax,edi
	mov	ebp,1030		;Allocate Positions
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	PatternOrderPtr,eax
	pop	eax

	inc	Positions

	add	edi,PatternOrderPtr
	mov	esi,edi
	sub	esi,2
	std
	rep	movsw
	cld
	cmp	CopyPosEdInsert,1
	jz	OkLetsDoIt
	mov	word ptr [edi],0
OkLetsDoIt:
	call	ShowPosList
	mov	OldPos,-1
	mov	OldPos2,-1
NoMoreInsertPatt:
	ret


PosEditorSquarePositions:
	movzx	eax,MouseY
	sub	eax,96+24
	mov	ebx,12
	xor	edx,edx
	div	ebx
	movzx	ebx,CurrStartPosition
	add	ebx,eax
	cmp	bx,Positions
	jae	Dummy
	call	GoToPosition
	call	ShowPosList
	mov	al,100
	mov	LeftKeyWait,al
	ret

GoToPosition	Proc	Near
	pushad
	call	ClearForPlay
	mov	CurrPosition,bx
	call	PosInit
	mov	OldRow,-1
	mov	OldPos,-1
	mov	OldPatt,-1
	mov	OldPatt2,-1
	mov	OldPattName,-1
	cmp	ProTrackerEditing,1
	jz	Stamme
	mov	CurrRow,0
	mov	GotoRow,0
	call	PosInit
Stamme:
	popad
	ret
GoToPosition	EndP

PosedInput		db	0
CurrStartPosition	dw	0
CurrCursorPosition	dw	0
ShowPosList:
	cmp	Menu_UpperLeft,1
	jnz	_ret
	pushad
	mov	OldPattName,-1

	call	mouseoff
	move	edi,0a0000h+118*80+1
	mov	edx,7

	mov	bp,Positions
	dec	bp
	cmp	bp,CurrCursorPosition
	ja	Nicht
	mov	CurrCursorPosition,bp
Nicht:
	movzx	ebp,CurrStartPosition
	shl	ebp,1
	add	ebp,PatternOrderPtr
	movzx	ebx,CurrStartPosition
PrintPosLoopen:
	mov	ah,1
	mov	cl,5
	call	PutDecimal
	push	ebx

	cmp	bx,CurrCursorPosition
	jnz	NoCursor1
	cmp	PosedInput,0
	jnz	NoCursor1
	mov	InvertText,-1
NoCursor1:
	movzx	ebx,word ptr [ebp]
	add	edi,6
	mov	cl,4
	call	PutDecimal
	mov	InvertText,0
	pop	ebx

	add	ebp,2
	add	edi,80-6+11*80
	inc	ebx
	cmp	bx,Positions
	jz	SkipPositions
	dec	edx
	jnz	PrintPosLoopen
	jmp	PrintFinished

SkipPositions:
	dec	edx
	jle	PrintFinished
	lea	esi,Spaces
	xor	ebx,ebx
	mov	ah,1
SkipPositions2:
	mov	cl,5
	call	PrintText
	add	edi,6
	mov	cl,4
	call	PrintText
	add	edi,80-6+11*80
	dec	edx
	jnz	SkipPositions2
PrintFinished:
	call	mouseon
	cmp	PosedInput,1
	jz	PrintInputText
	popad
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
IncreaseStartPosition:
	call	fixbutton
	mov	ax,CurrStartPosition
	add	ax,7
	cmp	ax,Positions
	jae	Dummy
	inc	CurrStartPosition
	mov	OldPos2,-1
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DecreaseStartPosition:
	call	fixbutton
	mov	ax,CurrStartPosition
	cmp	ax,0
	jz	Dummy
	dec	CurrStartPosition
	mov	OldPos2,-1
	ret


