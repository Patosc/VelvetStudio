
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Variables
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
then		equ	63
colorsnew	dd	theN-23,theN-23,theN-36,theN-38
		dd	theN-0 ,theN-0,theN-0
		dd	theN-39,theN-38,theN-41
		dd	theN-63,theN-63,theN-63,theN-38
		dd	theN-25,theN-25,theN-30
		dd	theN-0 ,theN-0 ,theN-09
		dd	theN-50,theN-0 ,theN-0
		dd	theN-20,theN-50,theN-25,theN-35
marble		dd	16,61,38,86
colorpal	db	16*3	dup(0)



comment	#
colorinca	dd	0
colorsold	dd	27	dup(-1)
colorsavebuff	dd	27	dup(0)
			;colors 2,3,4,?,?,7
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Colors Start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Colorindik	db	0
colorsstart2:
	pushad
	jmp	colorhoppa
ColorsStart	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	colorsendofstart
colorhoppa:
	lea	esi,colorsnew
	lea	edi,colorsavebuff
	mov	ecx,27
	rep	movsd

	mov	colorindik,1
	mov	menu_popup,10
	call	menuhandler

colorsendofstart:
	Popad
	ret
ColorsStart	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Colors End
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ColorsEnd	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	colorsendofend


	mov	menu_popup,0
	call	menuhandler

colorsendofend:
	Popad
	ret
ColorsEnd	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Inc Color
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IncColor1:
	push	ebx
	mov	ebx,0
	jmp	incacolor
IncColor2:
	push	ebx
	mov	ebx,4
	jmp	incacolor
IncColor3:
	push	ebx
	mov	ebx,8
	jmp	incacolor
IncColor4:
	push	ebx
	mov	ebx,12
	jmp	incacolor
IncColor5:
	push	ebx
	mov	ebx,16
	jmp	incacolor
IncColor6:
	push	ebx
	mov	ebx,20
	jmp	incacolor
IncColor7:
	push	ebx
	mov	ebx,24
	jmp	incacolor
IncColor8:
	push	ebx
	mov	ebx,28
	jmp	incacolor
IncColor9:
	push	ebx
	mov	ebx,32
	jmp	incacolor
IncColor10:
	push	ebx
	mov	ebx,36
	jmp	incacolor
IncColor11:
	push	ebx
	mov	ebx,40
	jmp	incacolor
IncColor12:
	push	ebx
	mov	ebx,44
	jmp	incacolor
IncColor13:
	push	ebx
	mov	ebx,48
	jmp	incacolor
IncColor14:
	push	ebx
	mov	ebx,52
	jmp	incacolor
IncColor15:
	push	ebx
	mov	ebx,56
	jmp	incacolor
IncColor16:
	push	ebx
	mov	ebx,60
	jmp	incacolor
IncColor17:
	push	ebx
	mov	ebx,64
	jmp	incacolor
IncColor18:
	push	ebx
	mov	ebx,68
	jmp	incacolor
IncColor19:
	push	ebx
	mov	ebx,72
	jmp	incacolor
IncColor20:
	push	ebx
	mov	ebx,76
	jmp	incacolor
IncColor21:
	push	ebx
	mov	ebx,80
	jmp	incacolor
IncColor22:
	push	ebx
	mov	ebx,84
	jmp	incacolor
IncColor23:
	push	ebx
	mov	ebx,88
	jmp	incacolor
IncColor24:
	push	ebx
	mov	ebx,92
	jmp	incacolor
IncColor25:
	push	ebx
	mov	ebx,96
	jmp	incacolor
IncColor26:
	push	ebx
	mov	ebx,100
	jmp	incacolor
IncColor27:
	push	ebx
	mov	ebx,104
	jmp	incacolor
Incacolor:
	call	fixbutton
	cmp	[ebx+colorsnew],63
	jz	skipincanow
	inc	[ebx+colorsnew]
skipincanow:
	pop	ebx
	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Dec Color
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DecColor1:
	push	ebx
	mov	ebx,0
	jmp	decacolor
DecColor2:
	push	ebx
	mov	ebx,4
	jmp	decacolor
DecColor3:
	push	ebx
	mov	ebx,8
	jmp	decacolor
DecColor4:
	push	ebx
	mov	ebx,12
	jmp	decacolor
DecColor5:
	push	ebx
	mov	ebx,16
	jmp	decacolor
DecColor6:
	push	ebx
	mov	ebx,20
	jmp	decacolor
DecColor7:
	push	ebx
	mov	ebx,24
	jmp	decacolor
DecColor8:
	push	ebx
	mov	ebx,28
	jmp	decacolor
DecColor9:
	push	ebx
	mov	ebx,32
	jmp	decacolor
DecColor10:
	push	ebx
	mov	ebx,36
	jmp	decacolor
DecColor11:
	push	ebx
	mov	ebx,40
	jmp	decacolor
DecColor12:
	push	ebx
	mov	ebx,44
	jmp	decacolor
DecColor13:
	push	ebx
	mov	ebx,48
	jmp	decacolor
DecColor14:
	push	ebx
	mov	ebx,52
	jmp	decacolor
DecColor15:
	push	ebx
	mov	ebx,56
	jmp	decacolor
DecColor16:
	push	ebx
	mov	ebx,60
	jmp	decacolor
DecColor17:
	push	ebx
	mov	ebx,64
	jmp	decacolor
DecColor18:
	push	ebx
	mov	ebx,68
	jmp	decacolor
DecColor19:
	push	ebx
	mov	ebx,72
	jmp	decacolor
DecColor20:
	push	ebx
	mov	ebx,76
	jmp	decacolor
DecColor21:
	push	ebx
	mov	ebx,80
	jmp	decacolor
DecColor22:
	push	ebx
	mov	ebx,84
	jmp	decacolor
DecColor23:
	push	ebx
	mov	ebx,88
	jmp	decacolor
DecColor24:
	push	ebx
	mov	ebx,92
	jmp	decacolor
DecColor25:
	push	ebx
	mov	ebx,96
	jmp	decacolor
DecColor26:
	push	ebx
	mov	ebx,100
	jmp	decacolor
DecColor27:
	push	ebx
	mov	ebx,104
	jmp	decacolor
Decacolor:
	call	fixbutton
	cmp	[ebx+colorsnew],0
	jz	skipdecanow
	dec	[ebx+colorsnew]
skipDecanow:
	pop	ebx
	ret

				;drags -------------------------------
comment %
ColorsDrag31:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,31
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ColorsDrag32:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,32
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ColorsDrag33:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,33
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ColorsDrag34:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,34
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ColorsDrag35:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,35
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ColorsDrag36:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,36
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ColorsDrag37:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,37
	ret

%
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Colors Reset
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ColorsReset	Proc	Near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	colorsresetend


	lea	esi,colorsavebuff
	lea	edi,colorsnew
	mov	ecx,27
	rep	movsd

	lea	edi,colorsold
	mov	ecx,27
	mov	eax,-1
	rep	stosd

colorsresetend:
	popad
	ret
ColorsReset	Endp
#

setornot	db	0	;0=set 1=not set
ColorsEnd2:
	pushad
	mov	menu_popup,0
	call	menuhandler
	popad
	ret

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Set Tracker Pal
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

SetTrackerPal	Proc	Near
	pushad
	mov	eax,63					;move background
	sub	eax,dword ptr [colorsnew+(4*4)]
	mov	byte ptr [colorpal+0],al
	mov	eax,63
	sub	eax,dword ptr [colorsnew+(5*4)]
	mov	byte ptr [colorpal+1],al
	mov	eax,63
	sub	eax,dword ptr [colorsnew+(6*4)]
	mov	byte ptr [colorpal+2],al

	mov	eax,63
	sub	eax,dword ptr [colorsnew+(7*4)] 	;move text1
	mov	byte ptr [colorpal+3],al
	mov	eax,63
	sub	eax,dword ptr [colorsnew+(8*4)]
	mov	byte ptr [colorpal+4],al
	mov	eax,63
	sub	eax,dword ptr [colorsnew+(9*4)]
	mov	byte ptr [colorpal+5],al

	xor	ebp,ebp 				;set marble pal
	lea	edi,colorpal
	add	edi,3*4
	mov	ecx,4
palmarble:
	push	ecx
	mov	eax,63
	sub	eax,dword ptr [colorsnew+(3*4)]
	mov	ebx,ebp
	shl	ebx,2
	mov	edx,[ebx+marble]
	mov	ecx,100
	sub	ecx,edx
	mul	ecx
	mov	ebx,63
	div	ebx
	mov	ecx,100
	sub	ecx,eax
	xor	esi,esi
rgbloop:
	mov	ebx,esi
	shl	ebx,2
	mov	eax,63
	sub	eax,dword ptr [colorsnew+ebx]
	mul	ecx
	mov	ebx,100
	div	ebx
	stosb
	inc	esi
	cmp	esi,3
	jnz	rgbloop
	inc	ebp
	pop	ecx
	loop	palmarble
							;set block1
	mov	eax,63
	sub	eax,dword ptr [colorsnew+(17*4)]
	mov	byte ptr [colorpal+(3*3)],al
	mov	eax,63
	sub	eax,dword ptr [colorsnew+(18*4)]
	mov	byte ptr [colorpal+(3*3)+1],al
	mov	eax,63
	sub	eax,dword ptr [colorsnew+(19*4)]
	mov	byte ptr [colorpal+(3*3)+2],al
							;set block2
	mov	eax,63
	sub	eax,dword ptr [colorsnew+(14*4)]
	mov	byte ptr [colorpal+(2*3)],al
	mov	eax,63
	sub	eax,dword ptr [colorsnew+(15*4)]
	mov	byte ptr [colorpal+(2*3)+1],al
	mov	eax,63
	sub	eax,dword ptr [colorsnew+(16*4)]
	mov	byte ptr [colorpal+(2*3)+2],al

							;set text2
	lea	edi,colorpal
	mov	esi,edi
	add	esi,3*4
	add	edi,3*12
	mov	ecx,4
barcolor:
	push	ecx

	xor	ebx,ebx
	mov	ecx,3
rgbbar:
	push	ecx
	xor	eax,eax
	lodsb
	mov	ecx,dword ptr [colorsnew+(13*4)]
	mul	ecx
	mov	ecx,63
	div	ecx
	mov	ebp,eax
	mov	eax,63
	sub	eax,dword ptr [colorsnew+ebx+(10*4)]
	mov	ecx,63
	sub	ecx,dword ptr [colorsnew+(13*4)]
	mul	ecx
	mov	ecx,63
	div	ecx
	add	eax,ebp
	stosb
	add	ebx,4
	pop	ecx
	loop	rgbbar
	pop	ecx
	loop	barcolor
							;set equalizer
	lea	edi,colorpal
	mov	esi,edi
	add	edi,3*8
	mov	ecx,3
barcolor_:
	push	ecx

	xor	ebx,ebx
	mov	ecx,3
rgbbar_:
	push	ecx
	xor	eax,eax
	lodsb
	mov	ecx,dword ptr [colorsnew+(26*4)]
	mul	ecx
	mov	ecx,63
	div	ecx
	mov	ebp,eax
	mov	eax,63
	sub	eax,dword ptr [colorsnew+ebx+(23*4)]
	mov	ecx,63
	sub	ecx,dword ptr [colorsnew+(26*4)]
	mul	ecx
	mov	ecx,63
	div	ecx
	add	eax,ebp
	stosb
	add	ebx,4
	pop	ecx
	loop	rgbbar_
	pop	ecx
	loop	barcolor_
							;set playpegpal
	lea	esi,colorsnew
	add	esi,20*4
	lea	edi,colorpal
	add	edi,3*11
	mov	ecx,3
movecolorloop:
	lodsd
	mov	bl,63
	sub	bl,al
	mov	al,bl
	stosb
	loop	movecolorloop

	cmp	setornot,1			;palette
	jz	skipset5555
	lea	esi,colorpal
	lea	ebp,mode_10tab
	mov	ecx,16
setloopen2:
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
	loop	setloopen2
skipset5555:

	popad
	ret
SetTrackerPal	Endp