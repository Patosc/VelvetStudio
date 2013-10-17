;/ABS\00131001310013100131001310013100131001310013100131
HelpAddX	EQU	-78
HelpAddY	EQU	5


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Help start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
HelpStart2:
	pushad
	jmp	HelpStart3
HelpStart	Proc	Near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	HelpEnd
HelpStart3:

	call	LoadHelpFile

	mov	SearchLine,0
	call	BrowseHelpText
	mov	TotalHelpLines,dx

	mov	Menu_popup,32
	call	MenuHandler

	mov	OldCurrentHelpLine,-1
HelpEnd:
	popad
	ret
HelpStart   Endp

HelpTextFile		db	'vs.hlp',0
TotalHelpLines		dw	0
CurrentHelpLine 	dw	0
OldCurrentHelpLine	dw	0
LoadHelpFile	Proc	Near
	pushad

	lea	edx,HelpTextFile
	call	FixPathFile

	lea	edx,NewFileName
	mov	ax,HelpFileErr
	call	_openfiler
	jc	ErrorHandler

	call	_FileSize
	mov	ecx,eax
	mov	ax,SizeErr
	jc	ErrorHandler
	mov	eax,ecx

	mov	ebp,1035		;Allocate Help Text
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem

	mov	HelpTextPtr,eax
	mov	edx,eax
	call	_readfile
	mov	ax,ReadErr
	jc	ErrorHandler
	call	_closefile
	mov	ax,CloseErr
	jc	ErrorHandler

	popad
	ret
LoadhelpFile	EndP

SearchLine	db	0
BrowseHelpText	Proc	Near
	mov	esi,HelpTextPtr
	xor	edx,edx

SearchNextLine:
	cmp	SearchLine,0
	jz	NoLineCheck
	cmp	dx,CurrentHelpLine
	jz	EndOfFile

NoLineCheck:
	lodsb
	cmp	al,0dh
	jz	AnotherEOL
	cmp	al,0ah
	jz	AnotherEOL
	cmp	al,01ah
	jz	EndOfFile
	jmp	NoLineCheck

AnotherEOL:
	cmp	byte ptr [esi],0ah
	jz	Knaprig
	cmp	byte ptr [esi],0dh
	jnz	TrueEOL
Knaprig:
	lodsb
TrueEOL:
	inc	edx
	jmp	SearchNextLine

EndOfFile:
	ret
BrowseHelpText	EndP





HelpColor	db	0
HelpTextPtr	dd	0


UpdateHelpText:
	mov	SearchLine,1
	call	BrowseHelpText
	call	BackColorScan

	mov	MouseX1,80
	mov	MouseY1,44
	mov	MouseX2,539
	mov	MouseY2,394
	call	MouseOff

	mov	FontPlane,1
	mov	ecx,13+13
	move	ebx,0a0000h+(3*12*80+11*80+HelpAddY*80)+19+HelpAddX/8
NxtLine:
	push	ecx
	mov	edi,GUS_TempBuffPtr
	mov	ecx,57*2
	mov	al,' '
	rep	stosb

	mov	edi,GUS_TempBuffPtr
	xor	edx,edx
NxtChar:
	lodsb
	cmp	al,0ah
	jz	SkipRestLine
	cmp	al,0dh
	jz	SkipRestLine
	stosb
	jmp	NxtChar
SkipRestLine:
	cmp	byte ptr [esi],0ah
	jz	Yes1
	cmp	byte ptr [esi],0dh
	jnz	No1
Yes1:
	lodsb
No1:
	push	esi edi
	mov	esi,GUS_TempBuffPtr
	mov	edi,ebx
	mov	ah,1
	mov	cl,57
	call	printhelptext
	add	ebx,13*80
	pop	edi esi
	pop	ecx
	loop	NxtLine

	mov	bl,0
	call	SetReset

	mov	FontPlane,0

	call	MouseOn
	call	MouseReset
	ret

HelpScreenArrUp:
	call	fixbutton
HelpScreenArrUp2:
	mov	ax,CurrentHelpLine
	dec	ax
	jl	_ret
	mov	CurrentHelpLine,ax
	ret
HelpScreenArrDn:
	call	fixbutton
HelpScreenArrDn2:
	mov	ax,CurrentHelpLine
	inc	ax
	mov	bx,ax
	add	bx,26
	cmp	bx,TotalHelpLines
	ja	_ret
	mov	CurrentHelpLine,ax
	ret

HelpPGUP:
	mov	ax,CurrentHelpLine
	sub	ax,26
	jg	@@Buff
	xor	ax,ax
@@Buff:
	mov	CurrentHelpLine,ax
	ret

HelpPGDN:
	mov	ax,CurrentHelpLine
	add	ax,26
	mov	bx,ax
	add	bx,26
	cmp	bx,TotalHelpLines
	jb	@@Buff
	mov	ax,TotalHelpLines
	sub	ax,26
@@Buff:
	mov	CurrentHelpLine,ax
	ret


ModeVariable3	db	0
HelpText	db	11 dup(0)
SearchOnce	db	0
FoundTextOffs	dd	0
FoundTextLine	dw	0
NotFoundText	db	'String not found$'
HelpSearchInput:
	mov	edi,(21*80+HelpAddY*80)+(208+HelpAddX)/8
	mov	ecx,10
	mov	ax,0113h
	lea	esi,HelpText
	call	InputRoutine
	mov	SearchOnce,0
	ret
HelpSearch:
	call	fixbutton
HelpSearch2:
	mov	esi,HelpTextPtr
	mov	SearchOnce,1
	mov	FoundTextLine,0
	jmp	Search
HelpSearchNext:
	call	fixbutton
HelpSearchNext2:
	cmp	SearchOnce,0
	jz	_ret
	mov	esi,FoundTextOffs
Search:
	xor	edi,edi
	xor	edx,edx
CompareNext:
	cmp	byte ptr [esi],1ah
	jz	EndOfSearch
	cmp	byte ptr [esi],0ah
	jz	SkipRestLine2
	cmp	byte ptr [esi],0dh
	jz	SkipRestLine2
	jmp	NoEOL
SkipRestLine2:
	inc	edx
	cmp	byte ptr [esi+1],0ah
	jz	Yes2
	cmp	byte ptr [esi+1],0dh
	jnz	Compare2
Yes2:
	inc	esi
	jmp	Compare2
NoEOL:
	mov	al,[HelpText+edi]
	call	GetLowerCase
	mov	bl,al
	mov	al,[esi]
	call	GetLowerCase
	cmp	al,bl
	jnz	Compare2
	inc	edi
	cmp	[HelpText+edi],0
	jz	TextFound
	inc	esi
	jmp	CompareNext

Compare2:
	xor	edi,edi
	inc	esi
	jmp	CompareNext

TextFound:
	inc	esi
	mov	FoundTextOffs,esi
	mov	ax,FoundTextLine
	add	dx,ax
	mov	ax,dx
	add	ax,26
	cmp	ax,TotalHelpLines
	jb	NoMaxHelp
	mov	dx,TotalHelpLines
	sub	dx,26
NoMaxHelp:
	mov	CurrentHelpLine,dx
	mov	FoundTextLine,dx
	call	UpdateHelpText
	ret
EndOfSearch:
	mov	FontPlane,2
	mov	SpecialSecondPopup,1
	mov	SecondPopup,1
	lea	esi,NotFoundText
	call	PopUpHandler
	mov	SpecialSecondPopup,0
	mov	FontPlane,0
	ret

GetLowerCase:
	cmp	al,'A'
	jb	_ret
	cmp	al,'Z'
	ja	_ret
	add	al,32
	ret

PrintHelpText	Proc    Near
	Pushad
	movzx	ecx,cl
@@TextLoopen:
	lodsb
	cmp	al,'^'
	jnz	@@OrdChar
	lodsb
	cmp	al,'c'
	jz	@@ChangeColor
	cmp	al,'l'
	jz 	@@Label
	cmp	al,'h'
	jnz	@@OrdChar

@@Hyper:
	lodsb
	cmp	al,']'
	jnz	@@Hyper
	mov	HelpColor,8
	jmp	@@TextLoopen

@@Label:
	lodsb
	cmp	al,':'
	jnz	@@label
	jmp	@@TextLoopen
@@ChangeColor:
	lodsb
	sub	al,'0'
	cmp	al,9
	jbe	Decimal
	add	al,'0'
	sub	al,'a'
	add	al,10
Decimal:
	mov	ah,al
	mov	HelpColor,ah
	jmp	@@TextLoopen
@@OrdChar:
	mov	bl,HelpColor
	not	bl
	call	SetReset

	mov	ah,0fh
	movzx	ebx,al
	call	PutCharacter
	inc	edi
	loop	@@TextLoopen
	Popad
	Ret
PrintHelpText	EndP


BackColorScan	Proc	Near
	pushad
@@ScanNext:
	dec	esi
	cmp	esi,HelpTextPtr
	jb	@@NoMoreScan
	cmp	byte ptr [esi],'^'
	jnz	@@ScanNext
	cmp	byte ptr [esi+1],'c'
	jnz	@@ScanNext
	mov	al,byte ptr [esi+2]
	mov	HelpColor,al
@@NoMoreScan:
	popad
	ret
BackColorScan	EndP

LabelBuffer	db	10 dup(0)
ScanForLabel	Proc	Near
	pushad

	call	FlipIt
	mov	esi,HelpTextPtr
	mov	FoundTextLine,0
	call	Search
	popad

FlipIt:
	pushad
	lea	esi,LabelBuffer
	lea	edi,HelpText
	mov	ecx,10
@@XchgNxt:
	mov	al,[esi]
	xchg	al,[edi]
	mov	[esi],al
	inc	esi
	inc	edi
	loop	@@XchgNxt
	popad
	ret
ScanForLabel	EndP

FoundHyper	db	0
HelpHyperText	Proc	Near
	pushad
	mov	FoundHyper,0
	movzx	eax,MouseY
	sub	eax,47+HelpAddY
	mov	ebx,13
	xor	edx,edx
	div	ebx
	add	ax,CurrentHelpLine
	mov	ecx,eax

	mov	esi,HelpTextPtr
	jecxz	ScanForHyperTxt
@@NoLineCheck:
	lodsb
	cmp	al,0dh
	jz	@@AnotherEOL
	cmp	al,0ah
	jz	@@AnotherEOL
	cmp	al,01ah
	jz	_retp
	jmp	@@NoLineCheck

@@AnotherEOL:
	cmp	byte ptr [esi],0ah
	jz	@@Knaprig
	cmp	byte ptr [esi],0dh
	jnz	@@TrueEOL
@@Knaprig:
	lodsb
@@TrueEOL:
	loop	@@NoLineCheck

ScanForHyperTxt:
	movzx	ecx,MouseX
	sub	ecx,159+HelpAddX
	shr	ecx,3
	inc	ecx

@@TextLoopen:
	lodsb
	cmp	al,'^'
	jnz	@@OrdChar
	lodsb
	cmp	al,'c'
	jz	@@ChangeColor
	cmp	al,'l'
	jz 	@@Label
	cmp	al,'h'
	jnz	@@OrdChar

	push	ecx
	lea	edi,LabelBuffer
	mov	ecx,10
	xor	al,al
	rep	stosb
	lea	edi,LabelBuffer
	lodsb
@@Hyper:
	lodsb
	cmp	al,']'
	jz	@@Finish
	stosb
	loop	@@Hyper
@@Finish:
	mov	al,':'
	stosb
	pop	ecx
	mov	FoundHyper,1
	jmp	@@TextLoopen
@@Label:
	lodsb
	cmp	al,':'
	jnz	@@label
	jmp	@@TextLoopen
@@ChangeColor:
	mov	FoundHyper,0
	lodsb
	jmp	@@TextLoopen
@@OrdChar:
	loop	@@TextLoopen
	cmp	FoundHyper,0
	jz	_retp
	call	PushHelpLine
	call 	ScanForLabel
	popad
	ret
HelpHyperText	EndP

IndexTxt	db	'index:'
HelpIndex:
	call	fixbutton
HelpIndex2:
	lea	edi,LabelBuffer
	mov	ecx,10
	xor	al,al
	rep	stosb

	lea	edi,LabelBuffer
	lea	esi,IndexTxt
	mov	ecx,6
	rep	movsb
	call	ScanForLabel
	ret
HelpBack:
	call	fixbutton
HelpBack2:
	call	PopHelpLine
	ret

BackStack	dw	20 dup(0)
BackStackPtr	dd	0
PushHelpLine	Proc	Near
	pushad

@@NextTry:
	mov	ax,CurrentHelpLine
	mov	edi,BackStackPtr
	cmp	edi,20
	jz	@@StackFull
	mov	[BackStack+edi*2],ax
	inc	BackStackPtr
	popad
	ret
@@StackFull:
	lea	esi,BackStack+1
	mov	edi,esi
	dec	edi
	mov	ecx,20
	rep	movsb
	dec	BackStackPtr
	jmp	@@NextTry

	popad
	ret
PushHelpLine	EndP

PopHelpLine	Proc	Near
	pushad
	dec	BackStackPtr
	jl	@@StackEmpty
	mov	edi,BackStackPtr
	mov	ax,[BackStack+edi*2]
	mov	CurrentHelpLine,ax
	call	BrowseHelpText
	popad
	ret
@@StackEmpty:
	mov	BackStackPtr,0
	popad
	ret
PopHelpLine	EndP



ViewHelpPopup:
	lea	esi,HelpPicture
	call	DrawPopup

	mov	FontPlane,1
	move	edi,0a0000h+(21*80+HelpAddY*80)+((208+HelpAddX)/8)
	mov	ecx,10
	mov	ah,01h
	lea	esi,HelpText
	call	PrintText
	mov	FontPlane,0
	ret




