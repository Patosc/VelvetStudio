;/ACS\=s
;/ABS\00207000020000200002003620000200002000020000200002

ColorButtonSelect	dd	0

;-------------------------------------------------------------

ColorSetupen		db	0,0,0,-100	;Background	     0*
			db	29,27,27,25	;Button 	     1*
			db	22,25,22,25	;Surface	     2*
			db	57,57,57,-100	;Font on background  3*
			db	59,61,59,0	;Font on surface     4*
			db	50,49,33,-100	;Peg in samped	     5*
			db	34,12,21,40	;EQUALIZER	     6
			db	59,59,59,-100	;Mouse		     7*
			db	40,40,40,-100	;Bars in patt.	     8*



TheColorTable		db	16*3	   dup(0)
ResetBuffer		db	9*4	   dup(0)


DefTable	label
			; (Orginal bl†)
;			db	0,0,0,-100		;1
;			db	18,22,30,25
;			db	16,19,31,25
;			db	55,56,60,-100
;			db	51,52,56,0
;			db	63,0,0,-100
;			db	13,45,17,41
;			db	59,59,59,-100
;			db	43,46,56,-100

			; Gammal? (Bl† med gr† knappar)
			db	0,0,0,-100	;Background	     0*
			db	29,29,29,25	;Button 	     1*
			db	22,22,26,25	;Surface	     2*
			db	55,56,60,-100	;Font on background  3*
			db	51,52,56,0	;Font on surface     4*
			db	40,0,0,-100	;Peg in samped	     5*
			db	34,26,17,50	;EQUALIZER	     6
			db	59,59,59,-100	;Mouse		     7*
			db	40,40,40,-100	;Bars in patt.	     8*

			; Gul/Brun
			db	0,0,0,-100		;2
			db	31,27,22,25
			db	34,30,23,25
			db	55,56,54,-100
			db	55,55,51,0
			db	63,0,0,-100
			db	46,47,22,47
			db	59,59,59,-100
			db	43,46,41,-100

			; Cyan
			db	0,0,0,-100		;3
			db	29,32,28,23
			db	26,33,30,27
			db	55,57,54,-100
			db	55,56,51,0
			db	63,0,0,-100
			db	46,15,1,47
			db	59,59,59,-100
			db	43,46,41,-100

			; R”d
			db	0,0,0,-100		;4
			db	35,21,23,30
			db	38,19,22,29
			db	55,57,54,-100
			db	59,56,51,0
			db	0,0,63,-100
			db	18,27,1,52
			db	59,59,59,-100
			db	43,40,41,-100



;	     ColorTable:
;	     0	Black (hole)
;	     1	Font on background and dragbar
;	     2	Bars in patterndata
;	     3	Border to surface (dark), shadow to font on surface
;	     4	Border to surface (light), font on surface
;	     5	Writeable font on surface
;	     6	Background to button
;	     7	Background to surface
;	     8	Colors to equalizer and reppegs
;	     9	Colors to equalizer and reppegs
;	     10 Colors to equalizer and reppegs
;	     11 Offset peg in samped
;	     12 Border to button (light) and text on button
;	     13 Shadow to write able font on surface
;	     14 Border to button (dark) and text on button
;	     15 Mousecolor
;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Colors Start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
_colorsstart2:
_ColorsStart	 Proc	 Near
	Pushad

	mov	menu_popup,10
	call	menuhandler
	call	SaveReset
	call	ColorButtons
	call	SetColorDragbarSpecial

colorsendofstart_:
	Popad
	ret
_ColorsStart	 Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Colors End
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
_ColorsEnd	 Proc	 Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	colorsendofend_

	call	DragbarToTable
	mov	menu_popup,0
	call	menuhandler

colorsendofend_:
	Popad
	ret
_ColorsEnd2:
	pushad
	mov	menu_popup,0
	call	menuhandler
	popad
	ret
_ColorsEnd	 Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Colors End Cancel
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
_ColorsEndCancel Proc	 Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	colorsendofend__

	call	DoReset2
	mov	menu_popup,0
	call	menuhandler

colorsendofend__:
	Popad
	ret
_ColorsEndCancel2:
	pushad
	mov	menu_popup,0
	call	menuhandler
	popad
	ret
_ColorsEndCancel Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Diffrent procs
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ColorButtons:;------------------------------- Color buttons
	pushad
	mov	ButtonX1,120
	mov	ButtonY1,66
	mov	ButtonX2,131
	mov	ButtonY2,77
	xor	ebp,ebp
	mov	ecx,9
	call	mouseoff
ButtonLoopen:
	push	ecx
	xor	bx,bx
	cmp	ebp,ColorButtonSelect
	jz	UpDownSelect
	mov	bx,1
UpDownSelect:
	call	ButtonUpDown
	add	ButtonY1,14
	add	ButtonY2,14
	inc	bp
	pop	ecx
	loop	ButtonLoopen
	call	mouseon
	popad
	ret
ColorSelect:;---------------------------------- Color Select
	pushad
	movzx	eax,MouseY
	sub	eax,65
	mov	ebx,14
	xor	edx,edx
	div	ebx

	cmp	ColorButtonSelect,eax
	jz	_retp
	call	DragBarToTable
	mov	ColorButtonSelect,eax
	call	ColorButtons
	call	SetColorDragbarSpecial
	popad
	ret
PopSpecialTable db	0,1,1,0,2,0,3,0,0
PopUpCallTable	dd	ColorSpecial1,ColorSpecial2,ColorSpecial3,ColorSpecial4
SetColorDragbarSpecial:;---------------------- Set Color Dragbar Special
	pushad
	mov	ebx,ColorButtonSelect
	movzx	eax,byte ptr [ebx+PopSpecialTable]
	call	TableToDragbar
	mov	esi,[eax*4+PopUpCallTable]
	mov	DrawSpecial,1
	call	DrawPopup
	mov	DrawSpecial,0
	popad
	ret
;--------------------------------------------- Color Arrows
ColorLeft1:
	pushad
	call	fixbutton
	cmp	dword ptr [SDBAR1],0
	jz	_retp
	dec	dword ptr [SDBAR1]
	mov	dword ptr [SDBAR1+4],1
	call	DragbarToTable
	call	UpdateTheColors
	jmp	_retp
ColorLeft2:
	pushad
	call	fixbutton
	cmp	dword ptr [SDBAR2],0
	jz	_retp
	dec	dword ptr [SDBAR2]
	mov	dword ptr [SDBAR2+4],1
	call	DragbarToTable
	call	UpdateTheColors
	jmp	_retp
ColorLeft3:
	pushad
	call	fixbutton
	cmp	dword ptr [SDBAR3],0
	jz	_retp
	dec	dword ptr [SDBAR3]
	mov	dword ptr [SDBAR3+4],1
	call	DragbarToTable
	call	UpdateTheColors
	jmp	_retp
ColorLeft4:
	pushad
	cmp	dword ptr [SDBAR4],-100
	jz	_retp
	call	fixbutton
	cmp	dword ptr [SDBAR4],0
	jz	_retp
	dec	dword ptr [SDBAR4]
	mov	dword ptr [SDBAR4+4],1
	call	DragbarToTable
	call	UpdateTheColors
	jmp	_retp
ColorRight1:
	pushad
	call	fixbutton
	cmp	dword ptr [SDBAR1],63
	jz	_retp
	inc	dword ptr [SDBAR1]
	mov	dword ptr [SDBAR1+4],1
	call	DragbarToTable
	call	UpdateTheColors
	jmp	_retp
ColorRight2:
	pushad
	call	fixbutton
	cmp	dword ptr [SDBAR2],63
	jz	_retp
	inc	dword ptr [SDBAR2]
	mov	dword ptr [SDBAR2+4],1
	call	DragbarToTable
	call	UpdateTheColors
	jmp	_retp
ColorRight3:
	pushad
	call	fixbutton
	cmp	dword ptr [SDBAR3],63
	jz	_retp
	inc	dword ptr [SDBAR3]
	mov	dword ptr [SDBAR3+4],1
	call	DragbarToTable
	call	UpdateTheColors
	jmp	_retp
ColorRight4:
	pushad
	cmp	dword ptr [SDBAR4],-100
	jz	_retp
	call	fixbutton
	cmp	dword ptr [SDBAR4],63
	jz	_retp
	inc	dword ptr [SDBAR4]
	mov	dword ptr [SDBAR4+4],1
	call	DragbarToTable
	call	UpdateTheColors
	jmp	_retp
SaveReset:;------------------------------------ Save Reset
	pushad
	lea	edi,ResetBuffer
	lea	esi,ColorSetupen
	mov	ecx,9
	rep	movsd
	jmp	_retp
DoReset2:
	pushad
	jmp	ResettaCol
DoReset:;------------------------------------- Do Reset
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
ResettaCol:
	lea	esi,ResetBuffer
	lea	edi,ColorSetupen
	mov	ecx,9
	rep	movsd
	call	TableToDragbar
	call	UpdateTheColors
	jmp	_retp



DragbarToTable:;------------------------------- Dragbar To Table
	pushad
	mov	ebx,ColorButtonSelect
	mov	ecx,[SDBAR1]
	mov	[ColorSetupen+ebx*4],cl
	mov	ecx,[SDBAR2]
	mov	[ColorSetupen+ebx*4+1],cl
	mov	ecx,[SDBAR3]
	mov	[ColorSetupen+ebx*4+2],cl
	mov	ecx,[SDBAR4]
	mov	[ColorSetupen+ebx*4+3],cl
	jmp	_retp
TableToDragbar:;------------------------------- Table To Dragbar
	pushad
	mov	ebx,ColorButtonSelect
	movsx	ecx,byte ptr [ColorSetupen+ebx*4]
	mov	[SDBAR1],ecx
	mov	[SDBAR1+4],1
	movsx	ecx,byte ptr [ColorSetupen+ebx*4+1]
	mov	[SDBAR2],ecx
	mov	[SDBAR2+4],1
	movsx	ecx,byte ptr [ColorSetupen+ebx*4+2]
	mov	[SDBAR3],ecx
	mov	[SDBAR3+4],1
	movsx	ecx,byte ptr [ColorSetupen+ebx*4+3]
	mov	[SDBAR4],ecx
	mov	[SDBAR4+4],1
	jmp	_retp

UpdateColorsNotPalette	db	0
UpdateTheColors2:
	call	DragbarToTable
UpdateTheColors:;----------------------------- Update colors
	pushad
						;Background
	mov	ax,word ptr [ColorSetupen]
	mov	word ptr [TheColorTable],ax
	mov	al,byte ptr [ColorSetupen+2]
	mov	byte ptr [TheColorTable+2],al
						;Peg in samped
	mov	ax,word ptr [5*4+ColorSetupen]
	mov	word ptr [11*3+TheColorTable],ax
	mov	al,byte ptr [5*4+ColorSetupen+2]
	mov	byte ptr [11*3+TheColorTable+2],al
						;Mouse color
	mov	ax,word ptr [7*4+ColorSetupen]
	mov	word ptr [15*3+TheColorTable],ax
	mov	al,byte ptr [7*4+ColorSetupen+2]
	mov	byte ptr [15*3+TheColorTable+2],al
						;Bars in patt.
	mov	ax,word ptr [8*4+ColorSetupen]
	mov	word ptr [2*3+TheColorTable],ax
	mov	al,byte ptr [8*4+ColorSetupen+2]
	mov	byte ptr [2*3+TheColorTable+2],al
						;Font on background
	mov	ax,word ptr [3*4+ColorSetupen]
	mov	word ptr [1*3+TheColorTable],ax
	mov	al,byte ptr [3*4+ColorSetupen+2]
	mov	byte ptr [1*3+TheColorTable+2],al
						;Button
	mov	ax,word ptr [1*4+ColorSetupen]
	mov	word ptr [6*3+TheColorTable],ax
	mov	al,byte ptr [1*4+ColorSetupen+2]
	mov	byte ptr [6*3+TheColorTable+2],al
	mov	ecx,3
	xor	ebp,ebp
ColorButton:
	movzx	eax,byte ptr [1*4+ColorSetupen+ebp]
	movzx	ebx,byte ptr [1*4+3+ColorSetupen]
	add	eax,ebx
	cmp	eax,63
	jbe	nozir1
	mov	eax,63
nozir1:
	mov	byte ptr [12*3+TheColorTable+ebp],al
	inc	ebp
	loop	ColorButton

	mov	ecx,3
	xor	ebp,ebp
ColorButton2:
	movzx	eax,byte ptr [1*4+ColorSetupen+ebp]
	movzx	ebx,byte ptr [1*4+3+ColorSetupen]
	sub	eax,ebx
	cmp	eax,0
	jge	nozir2
	mov	eax,0
nozir2:
	mov	byte ptr [14*3+TheColorTable+ebp],al
	inc	ebp
	loop	ColorButton2
						;Surface
	mov	ax,word ptr [ColorSetupen+2*4]
	mov	word ptr [TheColorTable+7*3],ax
	mov	al,byte ptr [ColorSetupen+2*4+2]
	mov	byte ptr [TheColorTable+7*3+2],al
	mov	ecx,3
	xor	ebp,ebp
SurfaceLoopen:
	movzx	eax,byte ptr [ColorSetupen+2*4+ebp]
	mov	ebx,eax
	movzx	edx,byte ptr [ColorSetupen+2*4+3]
	add	eax,edx
	sub	ebx,edx
	cmp	eax,63
	jbe	nocha
	mov	eax,63
nocha:
	cmp	ebx,0
	jge	nocha2
	mov	ebx,0
nocha2:
	mov	byte ptr [TheColorTable+4*3+ebp],al
	mov	byte ptr [TheColorTable+3*3+ebp],bl
	inc	ebp
	loop	SurfaceLoopen
							;Font on surface
	mov	ax,word ptr [4*4+ColorSetupen]
	mov	word ptr [5*3+TheColorTable],ax
	mov	al,byte ptr [4*4+ColorSetupen+2]
	mov	byte ptr [5*3+TheColorTable+2],al
	mov	ecx,3
	xor	ebp,ebp
FontLoopen:
	movzx	eax,byte ptr [2*4+ColorSetupen+ebp]
	movzx	ebx,byte ptr [4*4+3+ColorSetupen]
	mul	ebx
	mov	ebx,63
	div	ebx
	mov	byte ptr [TheColorTable+13*3+ebp],al
	inc	ebp
	loop	FontLoopen

							;equalizer
	xor	edi,edi
	mov	ecx,3
DoDiffrent1:
	push	ecx

	xor	ebp,ebp
	mov	ecx,3
DoDiffrent2:
	movzx	eax,byte ptr [ColorSetupen+6*4+ebp]
	movzx	ebx,byte ptr [ColorSetupen+6*4+3]
	mul	ebx
	mov	ebx,63
	div	ebx
	push	eax
	movzx	eax,byte ptr [TheColorTable+edi]
	movzx	edx,byte ptr [ColorSetupen+6*4+3]
	mov	ebx,63
	sub	ebx,edx
	mul	ebx
	mov	ebx,63
	div	ebx
	pop	ebx
	add	eax,ebx
	mov	byte ptr [TheColorTable+8*3+edi],al
	inc	ebp
	inc	edi
	loop	DoDiffrent2

	pop	ecx
	loop	DoDiffrent1

	cmp	updatecolorsnotpalette,1
	jz	_retp
	lea	eax,TheColorTable
	call	SetPcxPal

	popad
	ret
ColorPreDef:
	pushad
	call	FixButton
	movzx	eax,MouseX
	sub	eax,365
	cmp	eax,16*4
	jae	_retp			;Special code
	mov	ebx,16
	xor	edx,edx
	div	ebx
	cmp	edx,13
	ja	_retp
	mov	ebx,4*9
	mul	ebx
	lea	esi,DefTable
	add	esi,eax
	lea	edi,ColorSetupen
	mov	ecx,9
	rep	movsd
	call	TableToDragbar
	call	UpdateTheColors
	jmp	_retp
