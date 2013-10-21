
;/ABS\02917032550566511442000021060800002082460030000002

;				   Variables
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
Swap1		dd	0
Swap2		dd	0
Swap3		dd	0
Swap4		dd	0
Swap5		dd	0
SampForm		db	0	;0=Samp edit
					;1=Samp effects
					;2=Samp fourieranalys
					;
;---------------------------------------------------------------------------
sampmax 		dd	99999999
clipboardmax		dd	99999999
SampLength		dd	0	;* ;In samples
Sampbits		dd	0	;0=8bits 1=16bits


teststring		db	20,80,130,180,240
;---------------------------------------------------------------------------

Undosamplength		dd	0
ClipBoardOffset 	dd	0
ClipBoardLength 	dd	0
UndoBufferOffset	dd	0
SampMainOffset		dd	0	;*


SampMarkStart		dd     -1	;If -1, then there is no mark
SampMarkEnd		dd	0	;
viewsampoffset		dd	0	;*
viewsampoffsetOld	dd     -1
viewsamplength		dd	0	;*
PlayForm		db	1	;1=All, 2=Area, 3=Screen, 4=Offset
PlayLoop		db	0	;0=Off, 1=On
playpegoff		dd	0	; --- " ----
playoffold		dd     -1
undobaff		dd     -1
clipbaff		dd	0
ClipBoardBits		dd	0	;Bits of clipboards buffer

SampText1		db	'Are you sure that you want to clear the sample?$'
SampText2		db	'Are you sure that you want to zero the whole sample?$'
SampText3		db	'The clipboard is too small!$'
SampText5		db	'Are you sure that you want to cut the whole sample?$'
SampText6		db	'The clipboard is empty!$'
SampText7		db	'The clipboard will bee cut off while@'
SampText4		db	'The samplebuffer is too small!$'
SampText8		db	'The samplebuffer is empty!$'
SampText9		db	'Would you also like to convert sample data?$'
SampText10		db	'Error! the sample has got 8 bits@and the clipboard 16 bits$'
SampText11		db	'Error! the sample has got 16 bits@and the clipboard 8 bits$'
SampText12		db	'You must select repeat on before using this tool.$'
SampText13		db	'You must mark an area before using this tool.$'
SampText14		db	'The repeat start peg should not be at offset zero.$'
SampText15		db	'The repeat end peg should not be@in the end of the sample$'
SampText16		db	'The repeat end and repeat start peg@should not be at the same offset$'
SampText17		db	'The playpeg should not be at offset zero.$'
SampText18		db	'The playpeg should not be in the end of the sample$'
SampText19		db	'The mark should not start at offset zero.$'
SampText20		db	'The mark should not end in the end of the sample$'
SampText21		db	'You must mark an area,@to indicate the fix size.$'
SampText22		db	'Change will be saved in the@config file, continue anyway?$'
SampText23		db	"You can't edit a shadow sample!$"
;----------------------------- The Volume --------------------------------
volume_start		dd	100
volume_end		dd	100
oldvolume_start 	dd     -1
oldvolume_end		dd     -1
oldvolume_start2	dd     -1
oldvolume_end2		dd     -1

;----------------------------- The Mix -----------------------------------
mixasample		dd	100
mixaclip		dd	100

;----------------------------- Break sample ------------------------------
Breaksmp		dd	100

;--------------------------------- Y-Fix ---------------------------------
YmoveUp 		dd	0
YmoveDown		dd	0
OldYmoveUp		dd	0
OldYmoveDown		dd	0


_Bretp:
	call	buttonhandler
	popad
	ret
_Bret:
	call	buttonhandler
	ret

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Sample Editor Start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampleEditor2_:
	pushad
	jmp	AfterSampStart
SampleEditor	Proc	Near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	sampleedend
AfterSampStart:
	mov	word ptr [justcleared],0
	mov	Zoom,0
	mov	oldpegpos,-1
	mov	oldrepstartpos,-1

	mov	oldrependpos,-1
	cmp	menu_downscreen,4
;	mov	ProtectSerialCrash,93
	jz	SampleEditorExit2
	cmp	menu_downscreen,5
	jz	SampleEditorExit2

	lea	edi,oldputs
	mov	eax,-1
	mov	ecx,20
	rep	stosd
	mov	dword ptr [dragbardata+4],1
	mov	dword ptr [dragbardata+4+13*4],1

	mov	TuneForkStatus,0

	mov	EditMode,0
	mov	RecMode,0
	call	BackCol
	mov	menu_downscreen,4
	call	menuhandler
	cmp	PianoScreen,0
	jz	NoPoa2
	call	MenuPiano
NoPoa2:
	call	sampletoram

sampleedend:
	call	GetTheForm
	call	GoOnForm
	mov	clearflag,0

	popad
	ret
SampleEditorNumber2:
	pushad
	jmp	aftersampstart
SampleEditor	Endp
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Sample Editor Exit
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampleEditorExit	Proc	Near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	sampleexitnow
SampleEditorExit2:
	call	ShowMainPattern


	mov	ebp,1024
	mov	eax,0
	call	memalloc
	mov	ebp,1025
	mov	eax,0
	call	memalloc

sampleexitnow:
	popad
	ret
	pushad
	jmp	sampleeditorexit2
SampleEditorExit	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Sample editor quick start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampleEditorQuickStart Proc    Near
	pushad
	mov	sampform,0
	mov	menu_downscreen,4
	mov	[CurrentMenu+2],4
	mov	eax,[PcxOffsets+104]
	mov	pcxx,0
	mov	pcxy,372
	mov	fastpic,1
	call	ShowThePcx

	call	mouseoff
	mov	buttonX1,3
	mov	buttonY1,256
	mov	buttonX2,28
	mov	buttonY2,288
	mov	bl,0
	call	buttonupdown
	mov	buttonX1,3
	mov	buttonY1,289
	mov	buttonX2,28
	mov	buttonY2,321
	mov	bl,1
	call	buttonupdown
	call	mouseon

	call	GoOnForm
	lea	edi,oldputs
	mov	eax,-1
	mov	ecx,20
	rep	stosd

	mov	clearflag,0
	popad
	ret
SampleEditorQuickStart	  Endp

NowVaren	dd	0
SampleRateInput	Proc	Near		;------------------ Sample rate input --
	pushad


	cmp	SampLength,0
	jz	_retp
	cmp	SampRateStatus,1
	jz	_retp

	movzx	ebx,CurrentSample
	call	GetSampleRate
 	jnc	nosetc5
	mov	eax,16726
nosetc5:
	mov	NowVaren,eax
	move	edi,0a0000h+416/8+460*80
	mov	ah,1h
	mov	al,1h
	lea	ebp,NowVaren
	mov	ecx,5
	mov	ebx,522
	mov	edx,50148
	lea	esi,AfterRateinput
	mov	Digitsize,3
	call	ZyricInput

	popad
	ret
SampleRateInput	Endp
AfterRateInput:
	pushad
	mov	eax,NowVaren
	mov	CurrentSampRate,eax
	movzx	ebx,CurrentSample
	call	PutSampleRate
	popad
	ret

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				View Sampand mark
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;	SampOffset = Sample offset
;      Samplength2 = Sample length
;	 MarkStart = Mark start
;	MarkLength = Mark length (If Zero, then there is no mark)
;	  SampBits = 0=8bits 1=16bits
;     NotWriteSamp = 0=Write samp to screen, 1=NOT!
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ViewBuffer	dd	0		;buffer for curve
Sampoffset	dd	0		;sample offset
samplength2	dd	0		;sample length
markstart	dd	0		;mark start
marklength	dd	0		;mark length (0=no marked
sampebxsave	dd	0		;save ebx
fillmarkaxstart dd	0		;start on screen xmark
fillmarkaxend	dd	0		;end on screen xmark
markastartsave	dd	0		;save the start
addadadda	dd	0
notwritesamp	db	0
ViewSamp	Proc	Near
	pushad
	cmp	menu_downscreen,5
	jz	skipcheck2
	cmp	menu_downscreen,4
	jnz	endofview2
skipcheck2:
	cmp	samplength,0
	jz	viewnosamp2


;------------------------------------------ Sample rate put
	pushad
	movzx	ebx,CurrentSample
	call	GetSampleRate
 	jnc	nosetrate
	mov	eax,16726
	call 	InsSampleRate
	jc	NotEnoughHimem
	mov	CurrentSampRate,16726
	lea	edi,oldputs
	mov	eax,-1
	mov	ecx,20
	rep	stosd
	jmp	afteroj
nosetrate:
	cmp	eax,522
	jge	AfterOj
	mov	eax,16726
	call 	PutSampleRate
	jc	NotEnoughHimem
	mov	CurrentSampRate,16726
	lea	edi,oldputs
	mov	eax,-1
	mov	ecx,20
	rep	stosd
Afteroj:
	popad
;------------------------------------------


	mov	skippapegs,0
	mov	eax,viewsampoffset	;change some registers
	shl16	eax
	add	eax,sampmainoffset
	mov	sampoffset,eax
	mov	eax,viewsamplength
	mov	samplength2,eax

	mov	eax,viewsampoffset	;fix marks

	cmp	eax,sampmarkend
	ja	viewsampnocurve
	mov	ebx,sampmarkstart
	sub	ebx,eax
	cmp	ebx,0
	jge	nozirofix1
	mov	ebx,0
nozirofix1:
	mov	markstart,ebx

	mov	ecx,eax
	add	ecx,viewsamplength
	cmp	ecx,sampmarkstart
	jb	viewsampnocurve
	mov	ebx,sampmarkend
	cmp	ebx,ecx
	jbe	nooverfix1
	mov	ebx,ecx
NoOverfix1:
	sub	ebx,eax
	sub	ebx,markstart
	inc	ebx
	mov	marklength,ebx
	jmp	viewnow

ViewSampNoCurve:
	mov	marklength,0
ViewNow:
	cmp	samplength,0
	jz	nowsetline

	cmp	sampbits,1	       ;test if 16bits samp
	jz	scansamp16

	mov	eax,samplength2
	shl	eax,7
	mov	ebx,600
	xor	edx,edx
	div	ebx

	mov	sampebxsave,0
	xor	ebp,ebp
	xor	ebx,ebx 		;scan samp 8bits
	lea	edi,viewtable
	mov	ecx,600
MainSampScan:
	push	ecx
	add	ebx,eax
	mov	esi,sampebxsave
	add	ebp,edx
	cmp	ebp,600
	jb	nonopoj
	sub	ebp,600
	inc	ebx
nonopoj:

	mov	ecx,esi
	inc	ecx
	cmp	ecx,samplength2
	jb	nodiff
	mov	esi,samplength2
	dec	esi
	xor	ecx,ecx
	jmp	afterdiff
nodiff:
	mov	ecx,ebx
	shr	ecx,7
	mov	sampebxsave,ecx
	sub	ecx,esi
afterdiff:

	inc	ecx
nosaveme:
	push	eax ebx edx

	add	esi,sampoffset
	mov	edx,SampMainoffset
	add	edx,SampLength
	mov	bh,0ffh
	mov	bl,0h
loopmax_min:
	cmp	esi,edx
	jae	noloada1
	lodsb
noloada1:
	cmp	al,bl
	jna	checkmax
	mov	bl,al
checkmax:
	cmp	al,bh
	jnb	checkmin
	mov	bh,al
checkmin:
	loop	loopmax_min

	shr	bl,1
	shr	bh,1
	mov	[edi],bl
	mov	[edi+1],bh
	add	edi,2
	pop	edx ebx eax
	pop	ecx
	loop	mainsampscan

	jmp	nowclearsamp

scansamp16:
	mov	eax,samplength2
	shl	eax,7
	mov	ebx,600
	xor	edx,edx
	div	ebx

	mov	sampebxsave,0
	xor	ebp,ebp
	xor	ebx,ebx 		;scan samp 16bits
	lea	edi,viewtable
	mov	ecx,600
MainSampScan_:
	push	ecx
	add	ebx,eax
	mov	esi,sampebxsave
	add	ebp,edx
	cmp	ebp,600
	jb	nonopoj_
	sub	ebp,600
	inc	ebx
nonopoj_:

	mov	ecx,esi
	inc	ecx
	cmp	ecx,samplength2
	jb	nodiff_
	mov	esi,samplength2
	dec	esi
	xor	ecx,ecx
	jmp	afterdiff_
nodiff_:
	mov	ecx,ebx
	shr	ecx,7
	mov	sampebxsave,ecx
	sub	ecx,esi
afterdiff_:

	inc	ecx
nosaveme_:
	push	eax ebx edx ebp

	shl16	esi
	add	esi,sampoffset
	mov	ebp,SampLength
	shl16	ebp
	add	ebp,SampMainoffset
	;push	edx
	mov	bx,0ffffh
	mov	dx,0h
loopmax_min_:
	cmp	esi,ebp
	jae 	noloada2
	lodsw
noloada2:
	cmp	ax,dx
	jna	checkmax_
	mov	dx,ax
checkmax_:
	cmp	ax,bx
	jnb	checkmin_
	mov	bx,ax
checkmin_:
	loop	loopmax_min_

	shr	bx,9
	shr	dx,9
	mov	[edi],dl
	mov	[edi+1],bl
	;pop	edx
	add	edi,2
	pop	ebp edx ebx eax
	pop	ecx
	loop	mainsampscan_
	jmp	nowclearsamp


Nowsetline:				;set white line when no curve
	mov	edi,viewbuffer
	xor	eax,eax
	mov	ecx,75*64
	rep	stosb
	mov	al,0ffh
	mov	ecx,75
	rep	stosb
	xor	eax,eax
	mov	ecx,75*63
	rep	stosb
	jmp	skipmark
Nowclearsamp:

	mov	edi,viewbuffer		;clear curve
	xor	eax,eax
	mov	ecx,2496
	rep	stosd

	lea	esi,viewtable		;fix curve
	mov	edi,viewbuffer
	mov	ecx,75
	mov	bl,128
Samplines:
	push	ecx

	mov	ecx,8
sampdots:
	push	ecx
	movzx	eax,byte ptr [esi+1]
	mov	ebp,75
	mul	ebp
	mov	ebp,eax
	add	ebp,edi

	movzx	ecx,byte ptr [esi]
	push	ebx
	movzx	ebx,byte ptr [esi+1]
	sub	ecx,ebx
	pop	ebx
	inc	ecx
setbitsloop:
	or	[ebp],bl
	add	ebp,75
	loop	setbitsloop

	add	esi,2
	ror	bl,1
	pop	ecx
	loop	sampdots

	inc	edi
	pop	ecx
	loop	samplines
						;fix mark
	cmp	marklength,0
	jnz	notskipmark
	mov	currentmarkxstart,-1
	jmp	skipmark
notskipmark:
	mov	eax,markstart
	mov	ebx,599
	mul	ebx
	mov	ebx,samplength2
	div	ebx
	mov	fillmarkaxstart,eax
	add	eax,32 ; ;??
	mov	currentmarkxstart,eax

	mov	eax,markstart
	add	eax,marklength
	dec	eax
	mov	ebx,599
	mul	ebx
	mov	ebx,samplength2
	div	ebx
	mov	fillmarkaxend,eax
	inc	fillmarkaxend
	add	eax,32 ; ;24  ;??
	mov	currentmarkxend,eax

	mov	edi,viewbuffer
	mov	ecx,128
fixmarkloop:
	push	ecx
	push	edi

	mov	eax,fillmarkaxstart
	shr	eax,5
	shl	eax,2
	add	edi,eax

	mov	ebp,fillmarkaxend
	sub	ebp,fillmarkaxstart
	;inc	 ebp
	mov	eax,fillmarkaxstart
	mov	markastartsave,eax
Filllineloop1_:

	mov	ecx,markastartsave
	and	ecx,31
	mov	eax,0ffffffffh
	shr	eax,cl

	mov	ebx,ebp
	add	ebx,ecx
	cmp	ebx,32
	ja	morefillnow_

	mov	ecx,32
	sub	ecx,ebx
	mov	ebx,0ffffffffh
	shl	ebx,cl
	and	eax,ebx
	ror	ax,8
	ror	eax,16
	ror	ax,8
	xor	[edi],eax
	jmp	endfillloop1_

morefillnow_:
	ror	ax,8
	ror	eax,16
	ror	ax,8
	xor	[edi],eax

	mov	eax,32
	sub	eax,ecx
	sub	ebp,eax
	add	markastartsave,eax
	add	edi,4
	jmp	filllineloop1_

endfillloop1_:
	pop	edi
	add	edi,75
	pop	ecx
	loop	fixmarkloop

skipmark:
	cmp	notwritesamp,1
	jz	skipwritesamp
	mov	peghide,1
	call	movethepegs
	call	mouseoff
	mov	ah,00001111b		;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh 		;Set bitplane (read)
	mov	ah,0
	mov	al,4
	out	dx,ax

	mov	bl,00001110b
	call	setreset

	move	edi,0a0000h		;dump curve on the screen
	add	edi,(225*80)+4



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	;--------------------------------------- dump if sample popup
	;jmp	 afterspecialdump
	cmp	menu_popup,13
	jz	DumpCurveSpecial
	cmp	menu_popup,14
	jnz	afterspecialdump

DumpCurveSpecial:			;if sample popup
	push	ebp
	mov	esi,viewbuffer
	mov	edx,128
	xor	ebp,ebp
	mov	ebx,[alloctable+1038*8]
	add	ebx,195*63
linemovesamploop2:
	movsd
	cmp	ebp,29
	jb	nouta
	mov	ecx,15
	rep	movsd
	movsw
	movsb
	jmp	afteruta
nouta:
	add	edi,63
	xchg	ebx,edi
	mov	ecx,15
	rep	movsd
	movsw
	movsb
	xchg	edi,ebx
afteruta:
	movsd
	movsd
	add	edi,5
	inc	ebp

	dec	edx
	jnz	linemovesamploop2
	pop	ebp
	jmp	afterdumpen
	;-------------------------------------- normal dump -----------

afterspecialdump:			;normal view

	mov	esi,viewbuffer
	mov	edx,128
linemovesamploop:
	mov	ecx,18
	rep	movsd
	movsw
	movsb
	add	edi,5
	dec	edx
	jnz	linemovesamploop
afterdumpen:


	mov	bl,0
	call	setreset

	call	mouseon

	call	clippegs
	mov	oldpegpos,-1
	mov	oldrepstartpos,-1
	mov	oldrependpos,-1
	mov	peghide,0
	call	movethepegs


endofview:

	call	DrawSampLine
						;draw the line

						  ;update pegs
	;mov	peghide,0
	;call	movethepegs


skipwritesamp:
endofview2:
	call	printsampleinfo

	popad
	ret

DrawSampLine	Proc	Near
	pushad
	cmp	Menu_popup,0
	jnz	_retp
	cmp	Menu_downscreen,4
	jnz	_retp
	move	edi,0a0000h+289*80+32/8
	mov	ah,00001001b		;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	ax,0ffffh
	mov	ecx,80-5
	rep	stosb
	popad
	ret
DrawSampLine	Endp

;---------------------------------------- View no samp ---------------------
viewnosamp2:
	mov	peghide,1
	call	movethepegs
	mov	skippapegs,1
	mov	oldpegpos,-1
	mov	oldrepstartpos,-1
	mov	oldrependpos,-1
	call	mouseoff
	mov	ah,00001111b		;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	move	edi,0a0000h
	add	edi,225*80+3
	xor	eax,eax
	mov	ecx,8
loopups:
	push	ecx
	mov	ecx,77
	rep	stosb
	add	edi,3
	pop	ecx
	loop	loopups

	inc	edi
	mov	ecx,120
clearloop:
	push	ecx
	mov	ecx,75
	rep	stosb
	add	edi,5
	pop	ecx
	loop	clearloop

	move	edi,0a0000h
	add	edi,282*80+35
	lea	esi,samptext
	mov	ecx,9
movetext1:
	push	ecx
	lodsb
	movzx	ebx,al
	mov	ah,00000001b
	call	putcharacter
	inc	edi
	pop	ecx
	loop	movetext1

	call	mouseon
quitnowview:
	popad
	ret
samptext	db	'NO SAMPLE'
ViewSamp	Endp
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Xor Block
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;	 Eax = X start
;	 Ebx = X end
;   Xorplane = Bitplane
;  XorYstart = Y start
;    XorYend = Y end
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
XorPlane	db	0
XorYstart	dd	0
XorYend 	dd	0
xornomouse	db	0	;0=mouseon 1=mouseoff
xadder2 	dd	0
XorBlock	Proc	Near
	Pushad

	call	mouseoff
	move	edi,0a0000h+(225*80)
	mov	xadder2,80
	call	xoranow
	call	mouseon
	mov	edi,viewbuffer
	mov	xadder2,75
	sub	eax,32
	sub	ebx,32
	call	xoranow
	mov	oldpegpos,-1
	mov	oldrepstartpos,-1
	mov	oldrependpos,-1
	mov	peghide,0
	call	movethepegs
	popad
	ret

xoranow:
	pushad
	mov	fillmarkaxstart,eax
	mov	fillmarkaxend,ebx

	mov	cl,xorplane
	mov	ah,00000001b		;Set bitplane (write)
	shl	ah,cl
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh 		;Set bitplane (read)
	mov	ah,xorplane
	mov	al,4
	out	dx,ax

	mov	eax,xorystart
	mov	ebx,80
	mul	ebx
	add	edi,eax
	mov	ecx,xoryend
	sub	ecx,xorystart
	inc	ecx
fixmarkloopBB:
	push	ecx
	push	edi

	mov	eax,fillmarkaxstart
	shr	eax,5
	shl	eax,2
	add	edi,eax

	mov	ebp,fillmarkaxend
	sub	ebp,fillmarkaxstart
	inc	ebp
	mov	eax,fillmarkaxstart
	mov	markastartsave,eax
Filllineloop1_BB:

	mov	ecx,markastartsave
	and	ecx,31
	mov	eax,0ffffffffh
	shr	eax,cl

	mov	ebx,ebp
	add	ebx,ecx
	cmp	ebx,32
	ja	morefillnow_BB

	mov	ecx,32
	sub	ecx,ebx
	mov	ebx,0ffffffffh
	shl	ebx,cl
	and	eax,ebx
	ror	ax,8
	ror	eax,16
	ror	ax,8
	xor	[edi],eax
	jmp	endfillloop1_BB

morefillnow_BB:
	ror	ax,8
	ror	eax,16
	ror	ax,8
	xor	[edi],eax

	mov	eax,32
	sub	eax,ecx
	sub	ebp,eax
	add	markastartsave,eax
	add	edi,4
	jmp	filllineloop1_BB

endfillloop1_BB:
	pop	edi
	add	edi,xadder2
	pop	ecx
	loop	fixmarkloopBB

	Popad
	Ret
XorBlock	EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			     Mark Screen Start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ScreenMarking	db	0
xposa		dw	0
markfirst	db	0
fixrightbug	db	0
peggamove	db	0	;If 1 the peg will always be called

SetThePeg:
	pushad
	jmp	settapegga

MarkScreenStart 	Proc	Near
	pushad
	cmp	DrawStatus,1
	jz	_retp
	cmp	xposa,1
	jz	popandret2

	cmp	samplength,0
	jz	popandret2
	cmp	mouseB,0
	jz	popandret2
	cmp	mouseB,2
	jnz	setpegganot
Settapegga:
	mov	peggamove,1

	cmp	sampmarkstart,-1
	jz	skippathis
	call	unmarkall2
	cmp	movecursorornot,0
	jz	popandret2
	mov	xposa,1
	jmp	popandret2
skippathis:
	call	setoffsetpeg
	jmp	popandret2
setpegganot:
	cmp	screenmarking,1
	jz	popandret2
	;call	 ChangeMark
	;jc	 popandret
	call	CheckRepeatStartandPlay 	;check repeat, play m.m
	jc	popandret

					;check on already created mark
	;cmp	SampMarkStart,-1
	;jz	NoKeepon
	;mov	eax,SampMarkStart      ;start mark
	;sub	eax,ViewSampoffset
	;mov	ebx,600
	;imul	ebx
	;mov	ebx,ViewSampLength
	;idiv	ebx
	;cmp	eax,0
	;jl	endmarktest
	;cmp	eax,600
	;jge	endmarktest
	;movzx	ebx,MouseX
	;sub	ebx,24+(15)  ;check area
	;cmp	ebx,eax
	;jg	endmarktest
	;add	ebx,2*(15)
	;cmp	ebx,eax
	;jl	endmarktest
	;mov	screenmarking,1
	;mov	eax,SampMarkEnd
	;sub	eax,viewsampoffset
	;mov	xoldsave,eax
	;mov	ebx,600
	;imul	ebx
	;mov	ebx,viewsamplength
	;idiv	ebx
	;add	eax,24
	;mov	 currentmarkxend,eax
	mov	eax,ViewSampLength
	movzx	ebx,mouseX
	sub	ebx,32
	jge	@@j1
	xor	ebx,ebx
@@j1:
	mov	fixrightbug,0
	cmp	ebx,600
	jbe	@@j2
	mov	ebx,600
	mov	fixrightbug,1
@@j2:
	mul	ebx
	mov	ebx,600
	div	ebx


	mov	ebx,ViewSampLength
	dec	ebx
	cmp	eax,ebx
	jbe	@@j3
	mov	eax,ebx
@@j3:
	mov	markoffX,eax
	mov	ebp,eax
	mov	ebx,599
	mul	ebx
	mov	ebx,ViewSampLength
	div	ebx
	add	eax,32
NewFix:
	mov	markstartx,eax
	mov	markfirst,1
	;mov	eax,SampMarkStart
	;sub	eax,ViewSampoffset
	;mov	ebx,600
	;imul	ebx
	;mov	ebx,ViewSampLength
	;idiv	ebx
	;add	eax,24
	;;mov	 currentmarkxstart,eax
	;jmp	popandret2
endmarktest:


NoKeepon:

	mov	checkaplay,2
	call	checkautoplayform

	mov	screenmarking,1
popandret2:
	popad
	Ret
MarkScreenStart 	EndP

oldx			dd     -1
SetOffsetPeg	Proc	Near
	pushad
	cmp	samplength,0
	jz	skipsettanu
	movzx	eax,mouseX
	cmp	eax,oldx
	jz	skipsettanu

	mov	checkaplay,4
	call	checkautoplayform

	mov	oldx,eax
	sub	eax,32			     ;............................
	cmp	eax,0
	jge	skipzira_
	mov	eax,0
skipzira_:
	cmp	eax,599
	jbe	skipzira2_
	mov	eax,599
skipzira2_:

	mov	ebx,viewsamplength
	mul	ebx
	mov	ebx,600
	div	ebx
	add	eax,viewsampoffset
	;mov	 curradd,eax
	cmp	eax,samplength
	jb	skiii
	mov	eax,samplength
	dec	eax
skiii:
	mov	playpegoff,eax
	mov	peghide,0
	mov	themovepeg,3
	call	movethepegs
skipsettanu:
	popad
	ret
SetOffsetPeg	Endp
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Mark Screen
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
CurrentMarkXstart	dd     -1	;Start (If -1 then no marked)
CurrentMarkXend 	dd	0	;End
MarkStartX		dd	0	;Mark start (If -1 then marked is finished)
MarkNowX		dd	0
MarkOffX		dd	0
addextra		dd	0
xxsave			dd	0
xoldsave		dd	0
MarkScreen	Proc	Near
	Pushad



	cmp	samplength,0
	jz	markabsolutend
	cmp	mouseB,2			;quit if wrong button
	jz	unmarkall
	cmp	mouseB,3
	jz	justquitmark

	cmp	pegsmoving,0			;check if peg is moving
	jz	nospecialpeg
popandret:
	popad
	ret
nospecialpeg:


	cmp	sampmarkstart,-1
	jnz	skipthis
	mov	currentmarkxstart,-1
skipthis:

	movzx	ebp,mouseX			;prepare x
	sub	ebp,32
	jge	@@j1
	xor	ebp,ebp
@@j1:
	cmp	ebp,600
	jbe	@@j2
	mov	ebp,600
@@j2:
;-------------------------------------------------------
	mov	eax,viewsamplength
	mul	ebp
	mov	ebx,600
	div	ebx
	mov	ebx,ViewSampLength
	dec	ebx
	cmp	eax,ebx
	jbe	@@j3
	mov	eax,ebx
@@j3:
	cmp	eax,markoffx
	jb	noincs
	inc	eax
noincs:
	mov	marknowx,eax


	cmp	currentmarkxstart,-1
	jnz	nosettas1
	mov	xoldsave,eax
	jmp	settas1
nosettas1:
	cmp	xoldsave,eax
	jnz	settas1
	;inc	eax
settas1:


	mov	ebx,599
	mul	ebx
	mov	ebx,viewsamplength
	div	ebx
	mov	ebp,eax
	add	ebp,32
	mov	xxsave,ebp

;-------------------------------------------------------


	cmp	currentmarkXstart,-1		;check if markstart
	jz	setmarkstartandclear
	cmp	MarkStartX,-1
	jz	setmarkstartandclear
	cmp	MarkFirst,1
	jz	setmarkstartandclear


	cmp	currentmarkxstart,ebp
	jnz	nofastmarkquit
	cmp	currentmarkxend,ebp
	jz	justquitmark
nofastmarkquit:

	cmp	ebp,markStartx			;check if mark left or right
	jb	markaleft

markaright:
	mov	eax,markstartx			;fill more right
	cmp	eax,currentmarkxstart
	jnz	nomark1
	cmp	ebp,currentmarkxend
	jbe	nomark1
	mov	eax,currentmarkxend
	inc	eax
	mov	ebx,ebp
	mov	currentmarkxend,ebp
	mov	xorplane,0
	mov	xorystart,0
	mov	xoryend,127
	call    xorblock
	jmp	justquitmark
nomark1:					;remove more right
	mov	eax,markstartx
	cmp	eax,currentmarkxstart
	jnz	nomark2
	cmp	ebp,currentmarkxend
	jae	nomark2
	mov	ebx,currentmarkxend
	mov	eax,ebp
	inc	eax
	mov	currentmarkxend,ebp
	mov	xorplane,0
	mov	xorystart,0
	mov	xoryend,127
	call	xorblock
	jmp	justquitmark
nomark2:					;remove left and write right
	mov	eax,markstartx
	cmp	eax,currentmarkxend
	jnz	justquitmark
	mov	eax,currentmarkxstart
	mov	ebx,currentmarkxend
	dec	ebx
	mov	xorplane,0
	mov	xorystart,0
	mov	xoryend,127
	call	xorblock
	mov	eax,markstartx
	mov	currentmarkxstart,eax
	inc	eax
	mov	ebx,ebp
	mov	currentmarkxend,ebx
	mov	xorplane,0
	mov	xorystart,0
	mov	xoryend,127
	call	xorblock
	jmp	justquitmark

markaleft:
	mov	eax,markstartx			;fill more left
	cmp	eax,currentmarkxend
	jnz	nomark4
	cmp	ebp,currentmarkxstart
	jae	nomark4
	mov	ebx,currentmarkxstart
	dec	ebx
	mov	eax,ebp
	mov	currentmarkxstart,ebp
	mov	xorplane,0
	mov	xorystart,0
	mov	xoryend,127
	call	xorblock
	jmp	justquitmark
nomark4:					;remove more right
	mov	eax,markstartx
	cmp	eax,currentmarkxend
	jnz	nomark5
	cmp	ebp,currentmarkxstart
	jbe	nomark5
	mov	eax,currentmarkxstart
	mov	ebx,ebp
	dec	ebx
	mov	currentmarkxstart,ebp
	mov	xorplane,0
	mov	xorystart,0
	mov	xoryend,127
	call	xorblock
	jmp	justquitmark
nomark5:					;remove right and write left
	mov	eax,markstartx
	cmp	eax,currentmarkxstart
	jnz	justquitmark
	mov	eax,currentmarkxstart
	inc	eax
	mov	ebx,currentmarkxend
	mov	xorplane,0
	mov	xorystart,0
	mov	xoryend,127
	call	xorblock
	mov	ebx,markstartx
	mov	currentmarkxend,ebx
	dec	ebx
	mov	eax,ebp
	mov	currentmarkxstart,ebp
	mov	xorplane,0
	mov	xorystart,0
	mov	xoryend,127
	call	xorblock

Justquitmark:
	jmp	markscreenend

SetMarkStartAndClear:				;Set mark start and clear
	mov	markfirst,0
	mov	eax,currentmarkXstart
	cmp	eax,-1
	jz	nothingmarked2
	mov	ebx,currentmarkXend
	mov	xorplane,0
	mov	xorystart,0
	mov	xoryend,127
	call	xorblock
	mov	currentmarkXstart,-1
nothingmarked2:
	mov	eax,markstartx
	mov	ebx,ebp
	cmp	eax,ebx
	jbe	ggj3
	xchg	eax,ebx
ggj3:
	mov	currentmarkXstart,eax
	mov	currentmarkXend,ebx
	mov	xorplane,0
	mov	xorystart,0
	mov	xoryend,127
	call	xorblock
	jmp	markscreenend

unmarkall2:					 ;Unmark
	pushad
unmarkall:					;Unmark
	mov	eax,currentmarkXstart
	cmp	eax,-1
	jz	nothingmarked
	mov	ebx,currentmarkXend
	mov	xorplane,0
	mov	xorystart,0
	mov	xoryend,127
	call	xorblock
	mov	currentmarkXstart,-1

	mov	sampmarkstart,-1
	call	chooseplayform ;* * *


						;setoffset
nothingmarked:
	cmp	movecursorornot,1
	jz	setpegganot__
	mov	checkaplay,4
	call	checkautoplayform
	mov	oldx,-1
	call	setoffsetpeg
setpegganot__:

MarkScreenend:
					;mark screen end
	cmp	currentmarkxstart,-1
	jnz	yes_acurve
	mov	sampmarkstart,-1
	jmp	markabsolutend
yes_acurve:

	mov	eax,Markoffx
	mov	ebx,MarkNowX
	cmp	eax,ebx
	jbe	noflippas
	xchg	eax,ebx
noflippas:
	add	eax,viewsampoffset
	add	ebx,viewsampoffset
	mov	sampmarkstart,eax
	mov	sampmarkend,ebx
	cmp	fixrightbug,0
	jz	skippafixa
	mov	eax,samplength
	mov	sampmarkend,eax
skippafixa:

MarkAbsolutend:
	Popad
	Ret
MarkScreen	EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Update sample
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
UpdateSample	Proc	Near
	Pushad
	call	viewsamp		;view curve

	cmp	playform,1		;view all
	jnz	noall
	call	playformall
noall:
	cmp	playform,2		;view area
	jnz	noarea
	call	playformarea
noarea:
	cmp	playform,3		;view screen
	jnz	noscreen
	call	playformscreen
noscreen:
	cmp	playform,4		;view offset
	jnz	nooffset
	call	playformoffset
nooffset:
	mov	invertbyte,0

	mov	buttonX1,64		;view loop on/off
	mov	buttonY1,406
	mov	buttonX2,84
	mov	buttonY2,473
	mov	bl,playloop
	xor	bl,1
	call	ButtonUpDown

	Popad
	Ret
UpdateSample	EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Zoom Area
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ZoomBufferoffset	dd	0
ZoomArea2:
	pushad
	jmp	sss4
ZoomArea	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	ZoomAreaEnd
sss4:
	cmp	samplength,0
	jz	zoomareaend
	mov	checkaplay,3

	cmp	sampmarkstart,-1
	jz	errormesset

	cmp	zoombufferoffset,8*150		 ;zoom buffers
	jz	skipsavebuffer
	mov	ebx,zoombufferoffset
	mov	eax,sampmarkstart
	mov	[ebx+zoombuffer],eax
	mov	eax,sampmarkend
	add	ebx,4
	mov	[ebx+zoombuffer],eax
	add	zoombufferoffset,8
skipsavebuffer:

	mov	eax,sampmarkstart
	mov	viewsampoffset,eax
	mov	eax,sampmarkend
	sub	eax,sampmarkstart
	;inc	 eax
	mov	viewsamplength,eax
	cmp	mark_zoomarea,1
	jz	skipremove2
	mov	sampmarkstart,-1
skipremove2:
	call	chooseplayform ;checkautoplayform
	call	viewsamp
	;;;mov	   eax,viewsamplength
	;;;mov	   undoviewlength,eax
	;;;mov	   eax,viewsampoffset
	;;;mov	   undoviewoff,eax

errormesset:
ZoomAreaEnd:
	Popad
	Ret
ZoomArea	EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  View All
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ViewAll2:
	cmp	menu_downscreen,5
	jz	skipthiscmp
	cmp	menu_downscreen,4
	jnz	_ret
skipthiscmp:
	movzx	ebx,CurrentSample
	call	GetSampleRate
	jnc	NoZeroNow
	xor	eax,eax
NoZeroNow:
	mov	CurrentSampRate,eax
	mov	SampRateStatus,0
	Pushad
	jmp	ContView
ViewAll3:
	pushad
	jmp	Oopsa


ViewAll 	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	ViewAllEnd

	mov	eax,samplength
	cmp	eax,Viewsamplength
	jz	viewallend
Oopsa:

	cmp	samplength,0
	jz	viewallend
ContView:
	call	GetTheForm
	call	GoOnForm
	mov	checkaplay,1
	call	checkautoplayform
	mov	zoombufferoffset,0
	mov	eax,sampmainoffset
	mov	viewsampoffset,0
	mov	eax,samplength
	mov	viewsamplength,eax
	cmp	mark_viewall,1
	jz	skipremove1
	mov	sampmarkstart,-1
skipremove1:
	call	viewsamp
	;;;mov	   eax,viewsamplength
	;;;mov	   undoviewlength,eax
	;;;mov	   eax,viewsampoffset
	;;;mov	   undoviewoff,eax

ViewAllEnd:
	Popad
	Ret
ViewAll 	EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Zoom Out
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ZoomOut2:
	pushad
	jmp	sss5
ZoomOut 	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	ZoomOutEnd
sss5:
	cmp	samplength,0
	jz	zoomoutend

	mov	eax,viewsamplength
	mov	undoviewlength,eax
	mov	eax,viewsampoffset
	mov	undoviewoff,eax
	mov	ebx,zoombufferoffset
	sub	ebx,16
	cmp	ebx,0
	jl	errorzoomingout
	sub	zoombufferoffset,8
	mov	eax,[ebx+zoombuffer]
	mov	ecx,eax
	mov	viewsampoffset,eax

	add	ebx,4
	mov	eax,[ebx+zoombuffer]
	sub	eax,ecx
	inc	eax
;*	  cmp	  sampbits,1
;*	  jnz	  no16bits2
;*	  inc	  eax
;*no16bits2:
	mov	viewsamplength,eax
	cmp	mark_zoomout,1
	jz	skipremove3
	mov	sampmarkstart,-1
skipremove3:
	call	viewsamp
	mov	eax,viewsamplength
	mov	undoviewlength,eax
	mov	eax,viewsampoffset
	mov	undoviewoff,eax

ZoomOutEnd:
	Popad
	Ret

errorzoomingout:
	mov	checkaplay,1
	call	checkautoplayform
	mov	zoombufferoffset,0
	mov	eax,sampmainoffset
	mov	viewsampoffset,0
	mov	eax,samplength
	mov	viewsamplength,eax
	call	viewsamp
	;;;mov	   eax,viewsamplength
	;;;mov	   undoviewlength,eax
	;;;mov	   eax,viewsampoffset
	;;;mov	   undoviewoff,eax

	Popad
	Ret
ZoomOut 	EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Move Curve Left
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MoveCurveLeft		Proc	Near
	Pushad
	cmp	samplength,0
	jz	movecurveleftend

	call	fixbutton
	mov	eax,samplength
	cmp	eax,viewsamplength
	jz	movecurveleftend
	mov	eax,samplength
	mov	ebx,viewsamplength
	xor	edx,edx
	div	ebx
	mov	ebx,10
	mul	ebx

	sub	viewsampoffset,24 ;eax
	mov	eax,sampmainoffset
	cmp	viewsampoffset,0
	jge	nothingtofix
	mov	viewsampoffset,0
nothingtofix:
	call	viewsamp
	;;;mov	   eax,viewsamplength
	;;;mov	   undoviewlength,eax
	;;;mov	   eax,viewsampoffset
	;;;mov	   undoviewoff,eax

movecurveleftend:
	Popad
	Ret

MoveCurveLeft		EndP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Move Curve Right
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MoveCurveRight		Proc	Near
	Pushad
	cmp	samplength,0
	jz	movecurverightend

	call	fixbutton
	mov	eax,samplength
	cmp	eax,viewsamplength
	jz	movecurverightend
	mov	eax,samplength
	mov	ebx,viewsamplength
	xor	edx,edx
	div	ebx
	mov	ebx,10
	mul	ebx

	add	viewsampoffset,24 ;eax
	mov	eax,samplength
	sub	eax,viewsamplength
	cmp	viewsampoffset,eax
	jbe	nothingtofix2
	mov	viewsampoffset,eax
nothingtofix2:
	call	viewsamp
	;;;mov	   eax,viewsamplength
	;;;mov	   undoviewlength,eax
	;;;mov	   eax,viewsampoffset
	;;;mov	   undoviewoff,eax


movecurverightend:
	Popad
	Ret
MoveCurveRight		EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Invert Loop
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
InvertByte	db	0
InvertLoop	Proc	Near
	Pushad
	cmp	invertbyte,1
	jz	invertloopend
	mov	invertbyte,1

	xor	playloop,1

	mov	buttonX1,64
	mov	buttonY1,406
	mov	buttonX2,84
	mov	buttonY2,473
	mov	bl,playloop
	xor	bl,1
	call	ButtonUpDown

InvertLoopEnd:
	Popad
	Ret
InvertLoop	EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				PlayForm All
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PlayFormAll	Proc	Near
	Pushad
	cmp	invertbyte,1
	jz	Playformend1
	mov	invertbyte,1

	mov	playform,1

	mov	buttonX1,5		;all
	mov	buttonY1,406
	mov	buttonX2,63
	mov	buttonY2,422
	mov	bl,0
	call	ButtonUpDown
	mov	buttonX1,5		;Area
	mov	buttonY1,423
	mov	buttonX2,63
	mov	buttonY2,439
	mov	bl,1
	call	ButtonUpDown
	mov	buttonX1,5		;Screen
	mov	buttonY1,440
	mov	buttonX2,63
	mov	buttonY2,456
	mov	bl,1
	call	ButtonUpDown
	mov	buttonX1,5		;Offset
	mov	buttonY1,457
	mov	buttonX2,63
	mov	buttonY2,473
	mov	bl,1
	call	ButtonUpDown

PlayFormEnd1:
	Popad
	Ret
PlayFormAll	EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				PlayForm Area
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PlayFormArea	Proc	Near
	Pushad
	cmp	invertbyte,2
	jz	Playformend2
	mov	invertbyte,2

	mov	playform,2

	mov	buttonX1,5		;all
	mov	buttonY1,406
	mov	buttonX2,63
	mov	buttonY2,422
	mov	bl,1
	call	ButtonUpDown
	mov	buttonX1,5		;Area
	mov	buttonY1,423
	mov	buttonX2,63
	mov	buttonY2,439
	mov	bl,0
	call	ButtonUpDown
	mov	buttonX1,5		;Screen
	mov	buttonY1,440
	mov	buttonX2,63
	mov	buttonY2,456
	mov	bl,1
	call	ButtonUpDown
	mov	buttonX1,5		;Offset
	mov	buttonY1,457
	mov	buttonX2,63
	mov	buttonY2,473
	mov	bl,1
	call	ButtonUpDown

PlayFormEnd2:
	Popad
	Ret
PlayFormArea	EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				PlayForm Screen
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PlayFormScreen	Proc	Near
	Pushad
	cmp	invertbyte,3
	jz	Playformend3
	mov	invertbyte,3

	mov	playform,3

	mov	buttonX1,5		;all
	mov	buttonY1,406
	mov	buttonX2,63
	mov	buttonY2,422
	mov	bl,1
	call	ButtonUpDown
	mov	buttonX1,5		;Area
	mov	buttonY1,423
	mov	buttonX2,63
	mov	buttonY2,439
	mov	bl,1
	call	ButtonUpDown
	mov	buttonX1,5		;Screen
	mov	buttonY1,440
	mov	buttonX2,63
	mov	buttonY2,456
	mov	bl,0
	call	ButtonUpDown
	mov	buttonX1,5		;Offset
	mov	buttonY1,457
	mov	buttonX2,63
	mov	buttonY2,473
	mov	bl,1
	call	ButtonUpDown

PlayFormEnd3:
	Popad
	Ret
PlayFormScreen	EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				PlayForm Offset
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PlayFormOffset	Proc	Near
	Pushad
	cmp	invertbyte,4
	jz	Playformend4
	mov	invertbyte,4

	mov	playform,4

	mov	buttonX1,5		;all
	mov	buttonY1,406
	mov	buttonX2,63
	mov	buttonY2,422
	mov	bl,1
	call	ButtonUpDown
	mov	buttonX1,5		;Area
	mov	buttonY1,423
	mov	buttonX2,63
	mov	buttonY2,439
	mov	bl,1
	call	ButtonUpDown
	mov	buttonX1,5		;Screen
	mov	buttonY1,440
	mov	buttonX2,63
	mov	buttonY2,456
	mov	bl,1
	call	ButtonUpDown
	mov	buttonX1,5		;Offset
	mov	buttonY1,457
	mov	buttonX2,63
	mov	buttonY2,473
	mov	bl,0
	call	ButtonUpDown

PlayFormEnd4:
	Popad
	Ret
PlayFormOffset	EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			    Normalize volume
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
CenterValue	dd	0

Normalizen:
	mov	NormalizeCenter,0
	jmp     NormalizeVolume
Maximizen:
	mov	NormalizeCenter,1
	jmp     NormalizeVolume

NormalizeCenterProc:				    ;Normalize center -----
	pushad
	mov	CenterValue,0
	cmp	NormalizeCenter,0
	jz	_retp
	cmp	Sampbits,1
	jz	NormCenter16
	call	getecxedi
	mov	esi,edi
	xor	edx,edx
	mov	ebx,-1
	xor	eax,eax
NormScan8:
	lodsb
	cmp	al,dl
	jbe	noch1
	mov	dl,al
noch1:
	cmp	al,bl
	jae	noch2
	mov	bl,al
noch2:
	loop	NormScan8
	mov	al,-1
	sub	al,dl
	add	al,bl
	shr	al,1
	jnc	NoCentval
	mov	CenterValue,1
NoCentVal:
	sub	al,bl
	call	getecxedi
MoveLoopen8:
	add	byte ptr [edi],al
	inc	edi
	loop	MoveLoopen8
	_rp
NormCenter16:				;16 bits
	call	getecxedi
	mov	esi,edi
	xor	edx,edx
	mov	ebx,-1
	xor	eax,eax
NormScan16:
	lodsw
	cmp	ax,dx
	jbe	noch1_16
	mov	dx,ax
noch1_16:
	cmp	ax,bx
	jae	noch2_16
	mov	bx,ax
noch2_16:
	loop	NormScan16
	mov	ax,-1
	sub	ax,dx
	add	ax,bx
	shr	ax,1
	jnc	NoCentval_16
	mov	CenterValue,1
NoCentVal_16:
	sub	ax,bx
	call	getecxedi
MoveLoopen16:
	add	word ptr [edi],ax
	add	edi,2
	loop	MoveLoopen16
	_rp
NormalizeCenter 	db	0	;0=No center, 1=Center
NormalizeVolume2:
	pushad
	jmp	hora2
NormalizeVolume 	Proc	Near  ;------------- Normalize volume
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	NormalizeVolumeEnd
hora2:
	mov	Menu_popup,0
	call	MenuHandler

	cmp	samplength,0
	jz	normalizevolumeend

	call	saveundo
	call	NormalizeCenterProc

	cmp	sampbits,1	       ;check if 16 bits
	jz	normalize16

	mov	esi,sampmainoffset	;fix offsets to scan
	mov	ecx,samplength
	cmp	sampmarkstart,-1
	jz	nomarkchange
	mov	esi,sampmainoffset
	add	esi,sampmarkstart
	mov	ecx,sampmarkend
	sub	ecx,sampmarkstart
	;inc	 ecx
nomarkchange:

	push	ecx
	push	esi
	xor	ebx,ebx 		;get max of curve
scanmaxvolume:
	lodsb
	xor	al,128
	cmp	al,0
	jnl	notneg
	neg	al
notneg:
	cmp	al,bl
	jb	nothingchange
	mov	bl,al
nothingchange:
	loop	scanmaxvolume
	cmp	bl,127
	jae	NormalizeVolumeEnd2
	cmp	ebx,0
	jz	NormalizeVolumeEnd2

	mov	eax,127*60000		;fix konstant
	and	ebx,0ffh
	xor	edx,edx
	div	ebx
	mov	ebx,eax

	pop	esi			;change volume
	pop	ecx
ChangeVolume:
	mov	dl,[esi]
	xor	dl,128
	movsx	eax,dl
	sal	eax,1
	add	eax,CenterValue
	imul	ebx
	mov	ebp,60000*2
	idiv	ebp
	xor	al,128
	mov	[esi],al
	inc	esi
	loop	changevolume

	cmp	mark_normvol,1
	jz	skipremove10
	mov	sampmarkstart,-1
skipremove10:
	call	viewsamp
	call	updatesampletogus
	call	chooseplayform
	jmp	NormalizeVolumeEnd

Normalize16:				;Normalize 16 ----------------
	mov	esi,sampmainoffset	;fix offsets to scan
	mov	ecx,samplength
	cmp	sampmarkstart,-1
	jz	nomarkchange_
	mov	esi,sampmainoffset
	mov	eax,sampmarkstart
	shl16	eax
	add	esi,eax
	mov	ecx,sampmarkend
	sub	ecx,sampmarkstart
	;inc	 ecx
nomarkchange_:

	push	ecx
	push	esi
	xor	ebx,ebx 		;get max of curve
scanmaxvolume_:
	lodsw
	xor	ax,1000000000000000b
	cmp	ax,0
	jnl	notneg_
	neg	ax
notneg_:
	cmp	ax,bx
	jb	nothingchange_
	mov	bx,ax
nothingchange_:
	loop	scanmaxvolume_
	cmp	bx,32767
	jae	NormalizeVolumeEnd2
	cmp	bx,0
	jz	NormalizeVolumeEnd2

	mov	eax,32767*60000 	;fix konstant
	and	ebx,0ffffh
	xor	edx,edx
	div	ebx
	mov	ebx,eax

	pop	esi			;change volume
	pop	ecx
ChangeVolume_:
	mov	dx,[esi]
	xor	dx,1000000000000000b
	movsx	eax,dx
	imul	ebx
	mov	ebp,60000
	idiv	ebp
	xor	ax,1000000000000000b
	mov	[esi],ax
	add	esi,2
	loop	changevolume_

	cmp	mark_normvol,1
	jz	skipremove10_5
	mov	sampmarkstart,-1
skipremove10_5:
	call	viewsamp
	call	updatesampletogus
	call	chooseplayform


NormalizeVolumeEnd:
	Popad
	Ret
NormalizeVolumeEnd2:
	pop	eax
	pop	eax
	Popad
	Ret
NormalizeVolume 	EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Samp Undo
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
UndoViewOff	dd	0
UndoViewLength	dd	0
UndoPlayPeg	dd	0
UndoRepStart	dd	0
UndoRepEnd	dd	0

SampUndo	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	SampUndoEnd

	cmp	undosamplength,0
	jz	sampundoend2


	mov	eax,[alloctable+1024*8]
	mov	ebx,[alloctable+1024*8+4]
	xchg	[alloctable+1025*8],eax
	xchg	[alloctable+1025*8+4],ebx
	mov	[alloctable+1024*8],eax
	mov	[alloctable+1024*8+4],ebx


	mov	eax,[alloctable+1024*8]
	mov	sampmainoffset,eax

	mov	eax,samplength
	xchg	eax,undosamplength
	mov	samplength,eax

	mov	eax,viewsamplength
	xchg	undoviewlength,eax
	mov	viewsamplength,eax

	mov	eax,viewsampoffset
	xchg	eax,undoviewoff
	mov	viewsampoffset,eax

	mov	eax,playpegoff
	xchg	undoplaypeg,eax
	mov	playpegoff,eax

	movzx	ebp,currentsample
	mov	eax,[ebp*4+loopstart]
	sub	eax,[ebp*4+sampleoffsetstart]
	xchg	UndoRepStart,eax
	add	eax,[ebp*4+sampleoffsetstart]
	mov	[ebp*4+loopstart],eax

	mov	eax,[ebp*4+loopend]
	sub	eax,[ebp*4+sampleoffsetstart]
	xchg	UndoRepEnd,eax
	add	eax,[ebp*4+sampleoffsetstart]
	mov	[ebp*4+loopend],eax

	call	SetSampOffset
	;mov	 eax,samplength
	;cmp	 eax,undosamplength
	;jz	 notdifferent
	;mov	 eax,samplength
	;mov	 viewsamplength,eax
	;mov	 eax,sampmainoffset
	;mov	 viewsampoffset,0
	mov	sampmarkstart,-1
	;mov	 zoombufferoffset,0
notdifferent:
	lea	edi,oldputs
	mov	eax,-1
	mov	ecx,20
	rep	stosd

	call	updatesampletogus

	call	ViewSamp

	mov	PlayForm,1
	call	UpdateSample

	mov	oldcurrentinstname,-1
	call	printsampleinfo

SampUndoEnd:
SampUndoEnd2:
	Popad
	Ret
SampUndo	EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Undo Start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
UndoStart	Proc	Near
Saveundo:
	Pushad
	mov	eax,samplength
	mov	undosamplength,eax

	mov	eax,viewsampoffset
	mov	undoviewoff,eax

	mov	eax,viewsamplength
	mov	undoviewlength,eax

	mov	eax,playpegoff
	mov	undoplaypeg,eax

	movzx	ebp,currentsample
	mov	eax,[ebp*4+loopstart]
	sub	eax,[ebp*4+sampleoffsetstart]
	mov	UndoRepStart,eax

	mov	eax,[ebp*4+loopend]
	sub	eax,[ebp*4+sampleoffsetstart]
	mov	UndoRepEnd,eax

	mov	eax,samplength
	mov	undosamplength,eax
	call	allocundolength

	mov	esi,sampmainoffset
	mov	edi,undobufferoffset
	mov	ecx,samplength
	shl16	ecx
	rep	movsb

	Popad
	Ret
UndoStart	EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Undo Start 2 (just copy)
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
UndoStart2	Proc	Near
Saveundo2:
	Pushad
	mov	eax,samplength
	mov	undosamplength,eax
	call	allocundolength

	mov	esi,sampmainoffset
	mov	edi,undobufferoffset
	mov	ecx,samplength
	shl16	ecx
	rep	movsb

	Popad
	Ret
UndoStart2	EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Zero Sample
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ZeroSample2:
	pushad
	jmp	sss11
ZeroSample	Proc	Near

	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	ZeroSampleEnd
sss11:
	call	CheckIfShadow
	jc	_retp
	cmp	samplength,0
	jz	zerosampleend

	call	saveundo		;save undo

	cmp	sampbits,1	       ;check if 16 bits
	jz	zerosample16

					;fix offsets to scan
	mov	edi,sampmainoffset
	mov	ecx,samplength
	cmp	sampmarkstart,-1
	jz	nomarkchange2
	mov	edi,sampmainoffset
	add	edi,sampmarkstart
	mov	ecx,sampmarkend
	sub	ecx,sampmarkstart
	cmp	ecx,0
	jnz	nomarkchange2_
	inc	ecx
	jmp	nomarkchange2_
nomarkchange2:
	lea	esi,samptext2
	mov	menu_popup,17 ;2
	call	popuphandler
	cmp	popupstatus,0
	jz	zerosampleend
nomarkchange2_:
	mov	al,128			;zero routine
	rep	stosb

	cmp	mark_zero,1
	jz	skipremove8
	mov	sampmarkstart,-1
skipremove8:
	call	viewsamp
	call	updatesampletogus
	jmp	zerosampleend

zerosample16:				;zero sample 16bits -----------
	mov	edi,sampmainoffset
	mov	ecx,samplength
	cmp	sampmarkstart,-1
	jz	nomarkchange3
	mov	edi,sampmarkstart
	shl16	edi
	add	edi,sampmainoffset
	mov	ecx,sampmarkend
	sub	ecx,sampmarkstart
	cmp	ecx,0
	jnz	nomarkchange3
	inc	ecx
nomarkchange3:
	mov	ax,32768		;zero routine
	rep	stosw

	cmp	mark_zero,1
	jz	skipremove8_5
	mov	sampmarkstart,-1
skipremove8_5:
	call	updatesampletogus
	call	viewsamp

ZeroSampleEnd:
	call	chooseplayform
	Popad
	Ret
ZeroSample	EndP
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Preserve Sample
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PreserveSample2:
	pushad
	jmp	sss12
PreserveSample	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	PreserveSampleEnd
sss12:
	call	CheckIfShadow
	jc	_retp
	cmp	samplength,0
	jz	preservesampleend
	cmp	sampmarkstart,-1
	jz	preservesampleend

	call	undostart

	mov	esi,undobufferoffset
	mov	undobufferoffset,esi ;undosampmainoffset,esi
	mov	edx,sampmarkstart
	shl16	edx
	add	esi,edx
	mov	edi,sampmainoffset

	mov	ecx,sampmarkend
	sub	ecx,sampmarkstart
	;inc	 ecx
	mov	samplength,ecx
	mov	viewsamplength,ecx
	shl16	ecx
	rep	movsb

	mov	viewsampoffset,0
	mov	sampmarkstart,-1 ;??????
	mov	eax,samplength
	dec	eax
	mov	sampmarkend,eax
	cmp	mark_preserve,1
	jz	skipremove9
	mov	sampmarkstart,-1
skipremove9:
	mov	eax,playpegoff
	cmp	eax,samplength
	jb	skipsettas
	mov	eax,samplength
	dec	eax
	mov	playpegoff,eax
skipsettas:
	call	allocsamplength
	call	chooseplayform
	mov	oldcurrentinstname,-1
	call	printsampleinfo
	call	viewsamp
	call	updatesampletogus
PreserveSampleEnd:
	Popad
	Ret
PreserveSample	EndP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Clear Sample
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ClearSample2:
	pushad
	jmp	hora4
ClearSample	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	ClearSampleEnd
hora4:
	call	CheckIfShadow
	jc	_retp
	cmp	samplength,0
	jz	clearsampleend
	call	saveundo
	cmp	sampmarkstart,-1
	jz	clearall
	call	moveviewinfo

		    ;***********************************
	mov	edi,sampmainoffset
	xor	ebp,ebp


	mov	ecx,sampmarkstart	;save first part of curve
	cmp	ecx,0
	jz	savenopart1
	mov	esi,undobufferoffset
	add	ebp,ecx
	shl16	ecx
	rep	movsb
savenopart1:

	mov	esi,sampmarkend
	mov	ebx,samplength
	cmp	esi,ebx
	jae	savenopart2
	shl16	esi
	add	esi,undobufferoffset
	mov	ecx,samplength
	sub	ecx,sampmarkend
	add	ebp,ecx
	shl16	ecx
	rep	movsb
savenopart2:
	cmp	ebp,0
	jz	clearall

	cmp	playpegoff,ebp
	jb	nosettathis2
	mov	playpegoff,ebp
	dec	playpegoff
nosettathis2:
	mov	samplength,ebp


	call	changeviewinfo
	mov	sampmarkstart,-1
	call	allocsamplength
	call	viewsamp
	call	updatesampletogus
	call	chooseplayform
	mov	oldcurrentinstname,-1
	call	printsampleinfo
ClearSampleEnd:
	Popad
	Ret

ClearAll:

	lea	esi,samptext1
	mov	menu_popup,17	;2
	call	popuphandler
	cmp	popupstatus,0
	jz	notclear
	mov	playpegoff,0
	mov	samplength,0
	mov	viewsamplength,0
	mov	eax,sampmainoffset
	mov	viewsampoffset,0
	mov	zoombufferoffset,0

	movzx	ebp,currentsample
	shl	ebp,2
	mov	eax,[ebp+sampleoffsetstart]
	mov	[ebp+loopstart],eax
	mov	[ebp+loopend],eax
	mov	playpegoff,0

	mov	sampmarkstart,-1
	call	allocsamplength
	call	viewsamp
	call	updatesampletogus
	mov	oldcurrentinstname,-1
	call	printsampleinfo
	call	chooseplayform
notclear:
	Popad
	Ret
ClearSample	EndP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			    Check Repeat Start and Play
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
pegsmoving	db	0	;0=nopegs moving 1=repeat start
				;2=repeat end	 3=play peg
CheckRepeatStartandPLay Proc	Near
	Pushad
	cmp	mouseY,225
	jb	quitrepeatend
	cmp	mouseY,232
	ja	quitrepeatend

	movzx	ebp,currentsample
	shl	ebp,2
					;check repeat left
	;lea	 ebp,repstart		 ;get repstart offset ******
	mov	eax,[ebp+loopstart]
	sub	eax,[ebp+sampleoffsetstart]
	mov	ebx,viewsampoffset
	sub	eax,ebx
	jl	quitrepeatstart
	cmp	eax,viewsamplength
	ja	quitrepeatstart

	mov	ebx,599
	mul	ebx
	mov	ebx,viewsamplength
	div	ebx
	;add	 eax,24 ;? ?

	movzx	ebx,mousex
	sub	ebx,32 ;24
	cmp	ebx,eax
	jg	quitrepeatstart
	sub	eax,8
	cmp	ebx,eax
	jle	quitrepeatstart
	mov	pegsmoving,1
	jmp	quitplaypegstart

QuitRepeatStart:
					;check repeat end
	;lea	 ebp,repend		 ;get repend offset ******
	movzx	ebp,currentsample
	shl	ebp,2
	mov	eax,[ebp+loopend]
	sub	eax,[ebp+sampleoffsetstart]
	mov	ebx,viewsampoffset
	sub	eax,ebx
	jl	quitrepeatend
	cmp	eax,viewsamplength
	ja	quitrepeatend

	mov	ebx,599
	mul	ebx
	mov	ebx,viewsamplength
	div	ebx
	add	eax,32 ;24 ;? ?


	movzx	ebx,mousex
	sub	ebx,1
	cmp	ebx,eax
	jb	quitrepeatend
	add	eax,8
	cmp	ebx,eax
	jae	quitrepeatend
	mov	pegsmoving,2
	jmp	quitplaypegstart

QuitRepeatEnd:
	jmp	quitplaypegstart2

quitplaypegstart:
	Popad
	stc
	Ret
quitplaypegstart2:

	Popad
	clc
	Ret
CheckRepeatStartandPLay Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				    Move Pegs
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

OldXX		dd	0
MovePegs	Proc	Near
	Pushad
	movzx	eax,mouseX
	cmp	eax,oldXX
	jz	movepegend
	mov	oldXX,eax
	;cmp	 pegsmoving,1
	;jz	 nosubba
	sub	eax,32
nosubba:
	cmp	eax,0
	jge	skipzira
	mov	eax,0
skipzira:
	cmp	eax,600
	jbe	skipzira2
	mov	eax,600
skipzira2:

	mov	ebx,viewsamplength
	mul	ebx
	mov	ebx,600
	div	ebx

	mov	ebx,viewsampoffset
	add	ebx,eax

	cmp	sampbits,1	       ;make 16bits
	jnz	nosamp16
	and	ebx,-2
nosamp16:

	cmp	pegsmoving,2
	jz	movepeg2

	movzx	ebp,currentsample
	shl	ebp,2
	movzx	edi,currentsample
	shl	edi,2
	mov	eax,[edi+loopend]
	sub	eax,[edi+sampleoffsetstart]
	cmp	ebx,eax
	jna	changesome
	mov	ebx,eax
changesome:
	;cmp	 ebx,samplength
	;jb	 nochangelength1
	;mov	 ebx,samplength
	;dec	 ebx
nochangelength1:
	mov	[ebp+loopstart],ebx
	mov	eax,[ebp+sampleoffsetstart]
	add	[ebp+loopstart],eax
	call	SetSampleLoop
	call	PrintSampleInfo
	mov	al,pegsmoving
	mov	themovepeg,al
	mov	peghide,0
	call	movethepegs
	jmp	movepegend

movepeg2:
	movzx	ebp,currentsample
	shl	ebp,2
	movzx	edi,currentsample
	shl	edi,2
	mov	eax,[edi+loopstart]
	sub	eax,[edi+sampleoffsetstart]
	cmp	eax,ebx
	jna	changesome2
	mov	ebx,eax
changesome2:
	;cmp	 ebx,samplength
	;jb	 nochangelength2
	;mov	 ebx,samplength
	;dec	 ebx
nochangelength2:
	mov	[ebp+loopend],ebx
	mov	eax,[ebp+sampleoffsetstart]
	add	[ebp+loopend],eax
	call	SetSampleLoop
	call	PrintSampleInfo
	mov	al,pegsmoving
	mov	themovepeg,al
	mov	peghide,0
	call	movethepegs

movepegend:
	Popad
	Ret
MovePegs	EndP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Samp Convert
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampConvert2:
	pushad
	jmp	sss16
SampConvert	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	SampConvertEnd
sss16:
	cmp	samplength,0
	jz	SampConvertEnd

	call	CheckIfShadow
	jc	_retp

	call	saveundo

	cmp	sampbits,1
	jz	convert16

	mov	edi,viewsampoffset	;convert 8bits
	add	edi,sampmainoffset
	mov	ecx,viewsamplength
	cmp	sampmarkstart,-1
	jz	nothingmarked1
	mov	edi,sampmainoffset
	add	edi,sampmarkstart
	mov	ecx,sampmarkend
	sub	ecx,sampmarkstart
	;inc	 ecx
nothingmarked1:

convertloop8:
	xor	byte ptr [edi],128
	inc	edi
	loop	convertloop8
	cmp	mark_convert,1
	jz	skipremove4
	mov	sampmarkstart,-1
skipremove4:
	call	viewsamp
	call	updatesampletogus
	call	chooseplayform
	jmp	sampconvertend

convert16:
	mov	edi,viewsampoffset	;convert 16bits
	shl16	edi
	add	edi,sampmainoffset
	mov	ecx,viewsamplength
	cmp	sampmarkstart,-1
	jz	nothingmarked3
	mov	edi,sampmarkstart
	shl16	edi
	add	edi,sampmainoffset
	mov	ecx,sampmarkend
	sub	ecx,sampmarkstart
	;inc	 ecx
nothingmarked3:
convertloop16:
	xor	word ptr [edi],32768
	add	edi,2
	loop	convertloop16
	cmp	mark_convert,1
	jz	skipremove4_5
	mov	sampmarkstart,-1
skipremove4_5:
	call	viewsamp
	call	updatesampletogus
	call	chooseplayform

SampConvertEnd:
	Popad
	Ret
SampConvert	EndP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				    Samp Cut
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampCut2:
	pushad
	jmp	sss9
SampCut 	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	SampCutEnd
sss9:
	call	CheckIfShadow
	jc	_retp

	cmp	samplength,0
	jz	sampcutend
	cmp	sampmarkstart,-1
	jz	sampcutall

	mov	eax,sampmarkend
	sub	eax,sampmarkstart
	;inc	 eax
	cmp	eax,samplength
	jae	sampcutall
	call	moveviewinfo

	mov	eax,sampmarkend
	sub	eax,sampmarkstart
	;inc	 eax
	mov	clipboardlength,eax
	call	alloccliplength

	cmp	eax,clipboardmax
	ja	sampcuterror


	call	saveundo

	mov	edi,sampmainoffset	;save first part
	mov	esi,undobufferoffset
	mov	ecx,sampmarkstart
	mov	ebp,ecx
	shl16	ecx
	rep	movsb

	push	edi			;save to clip board
	mov	edi,clipboardoffset
	mov	ecx,sampmarkend
	sub	ecx,sampmarkstart
	cmp	ecx,0
	jnz	nozerooj
	mov	ecx,1
nozerooj:
	mov	clipboardlength,ecx
	shl16	ecx
	rep	movsb
	pop	edi

	mov	edx,ebp 		;save last part
	add	edx,clipboardlength
	mov	ecx,samplength
	sub	ecx,edx
	add	ebp,ecx
	shl16	ecx
	rep	movsb



	mov	samplength,ebp
	mov	ecx,SampBits
	mov	ClipBoardBits,ecx
	call	allocsamplength

	call	clippegs
	call	changeviewinfo

	mov	sampmarkstart,-1
	call	viewsamp
	call	updatesampletogus

	call	chooseplayform
	mov	oldcurrentinstname,-1
	call	printsampleinfo

	jmp	sampcutend
Sampcutall:					;sampcutall-----------------
	mov	eax,samplength
	mov	clipboardlength,eax
	call	alloccliplength
	mov	eax,samplength
	cmp	eax,clipboardmax
	ja	sampcuterror

	lea	esi,samptext5
	mov	menu_popup,17 ;2
	call	popuphandler
	cmp	popupstatus,0
	jz	sampcutend

	call	saveundo

	mov	edi,clipboardoffset
	mov	esi,sampmainoffset
	mov	ecx,samplength
	mov	clipboardlength,ecx
	shl16	ecx
	rep	movsb

	mov	samplength,0
	mov	viewsamplength,0
	mov	viewsampoffset,0
	mov	zoombufferoffset,0

	mov	ecx,SampBits
	mov	ClipBoardBits,ecx
	movzx	ebp,currentsample
	shl	ebp,2
	mov	eax,[ebp+sampleoffsetstart]
	mov	[ebp+loopstart],eax
	mov	[ebp+loopend],eax
	mov	playpegoff,0
	mov	sampmarkstart,-1
	call	allocsamplength
       	call	viewsamp
       	call	updatesampletogus
       	mov	oldcurrentinstname,-1
	call	printsampleinfo
Sampcutend:
	popad
	ret
SampCutError:					;error
	lea	esi,samptext3
	mov	menu_popup,16 ;1
	call	popuphandler
	Popad
	Ret
SampCut 	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				    Samp Copy
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampCopy2:
	pushad
	jmp	sss8
SampCopy	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	SampCopyEnd
sss8:
	cmp	samplength,0
	jz	SampCopyEnd
	cmp	sampmarkstart,-1
	jz	sampcopyend

	mov	ecx,sampmarkend 	;check if clipboard too small
	sub	ecx,sampmarkstart
	;inc	 ecx
	mov	clipboardlength,ecx
	call	alloccliplength
	shl16	ecx
	cmp	ecx,clipboardmax
	ja	sampcopyerror

	mov	edi,clipboardoffset
	mov	esi,sampmarkstart
	shl16	esi
	add	esi,sampmainoffset
	rep	movsb

	mov	ecx,SampBits
	mov	ClipBoardBits,ecx
	cmp	mark_copy,1
	jz	skipremove6
	mov	sampmarkstart,-1
skipremove6:
	call	viewsamp
	call	chooseplayform


SampCopyEnd:
	Popad
	Ret
SampCopyerror:
	lea	esi,samptext3
	mov	menu_popup,16 ;1
	call	popuphandler
	Popad
	Ret
SampCopy	EndP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				    Samp Paste
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampPaste2:
	pushad
	jmp	sss10
SampPaste	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	SampPasteEnd
sss10:
	call	CheckIfShadow
	jc	_retp
	cmp	clipboardlength,0
	jz	samppasteend
	cmp	samplength,0
	jz	pasteall

	mov	eax,Sampbits
	cmp	eax,ClipBoardBits
	jz	thesamea
	cmp	al,0
	jz	PasteError1
	jmp	PasteError2
thesamea:

	call	moveviewinfo

	mov	eax,clipboardlength
	mov	extrasamplength,eax
	call	allocsamplength

	add	eax,samplength
	shl16	eax
	cmp	eax,sampmax
	ja	samppasteerror

	call	saveundo

	mov	edi,sampmainoffset	;save fist bit
	mov	esi,undobufferoffset
	mov	ecx,playpegoff
	shl16	ecx
	rep	movsb

	push	esi			;paste
	mov	esi,clipboardoffset
	mov	ecx,clipboardlength
	shl16	ecx
	rep	movsb
	pop	esi

	mov	ecx,samplength		;save second bit
	sub	ecx,playpegoff
	shl16	ecx
	rep	movsb

	sub	edi,sampmainoffset
	shr16	edi
	mov	samplength,edi		;fix and view samp
	call	changeviewinfo
	call	viewsamp
	call	updatesampletogus
	call	chooseplayform
	mov	oldcurrentinstname,-1
	call	printsampleinfo

SampPasteEnd:
	Popad
	Ret
SampPasteerror: 				;error
	lea	esi,samptext4
	mov	menu_popup,16 ;1
	call	popuphandler
	Popad
	Ret
Pasteall:					;paste all
	mov	eax,ClipBoardBits
	mov	SampBits,eax
	mov	eax,clipboardlength
	mov	extrasamplength,eax
	call	allocsamplength
	cmp	eax,sampmax
	ja	samppasteerror
	call	saveundo

	mov	edi,sampmainoffset
	mov	esi,clipboardoffset
	mov	ecx,clipboardlength
	mov	samplength,ecx
	mov	viewsamplength,ecx
	shl16	ecx
	rep	movsb

	mov	eax,sampmainoffset
	mov	viewsampoffset,0

	mov	eax,[ebp+sampleoffsetstart]
	mov	[ebp+loopstart],eax
	mov	[ebp+loopend],eax
	mov	playpegoff,0
	mov	sampmarkstart,-1
	call	viewsamp
	call	updatesampletogus
	mov	oldcurrentinstname,-1
	call	printsampleinfo

	Popad
	Ret
SampPaste	EndP

PasteError1:
	lea	esi,samptext10
	mov	menu_popup,16
	call	popuphandler
	_rp
PasteError2:
	lea	esi,samptext11
	mov	menu_popup,16
	call	popuphandler
	_rp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       UpdateSampletoGus
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
notchange	db	0
UpdateSampleToGus	Proc	Near
	pushad
	mov	notchange,1
	call	sampletogus
	mov	notchange,0

	call	clippegs
	call	PrintSampleInfo

	comment &
						;fix mark when changes
	mov	ebx,sampbits
	inc	ebx
skipmarktest:
	mov	eax,samplength
	mov	edx,eax
	sub	edx,ebx
	movzx	edi,currentsample
	shl	edi,2

	mov	ecx,[edi+loopstart]
	sub	ecx,[edi+SampleOffsetstart]
	cmp	eax,ecx
	jae	skipsetta1
	mov	ebx,edx
	add	ebx,[edi+sampleoffsetstart]
	mov	[edi+loopstart],ebx
skipsetta1:
	mov	ecx,[edi+loopend]
	sub	ecx,[edi+sampleoffsetstart]
	cmp	eax,ecx
	jae	skipsetta2
	mov	ebx,edx
	add	ebx,[edi+sampleoffsetstart]
	mov	[edi+loopend],ebx
skipsetta2:
	&

	popad
	ret
UpdateSampleToGus	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       MoveThePegs
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;	 peghide 1=hiding 0=moving
;     skippapegs 0=not skippa 1=skippa
;    themovepeg  0=no particular 1=repeat startpeg 2=repeat end peg 3=offsetpeg
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

themovepeg		db	0
skippapegs		db	0
peghide 		db	0
pegcolor		dw	11
repeatcolor		dw	8
savaadd 		db	0
saveebpadd		db	0

OldPegPos		dd     -1
oldrepstartpos		dd     -1
oldrependpos		dd     -1
PegPos2 		dd	0
repstartpos2		dd	0
rependpos2		dd	0
PegPos			dd	0
repstartpos		dd	0
rependpos		dd	0
PegPosScreen		dd	0
repstartposScreen	dd	0
rependposScreen 	dd	0
OldPegPosScreen 	dd	0
OldrepstartposScreen	dd	0
OldrependposScreen	dd	0
OldPegPosScreenL	dd	0
OldrepstartposScreenL	dd	0
OldrependposScreenL	dd	0


pegandinfo		db	0
pegorinfo		db	0
repstartandinfo1	dw	0
repstartorinfo1 	dw	0
repstartandinfo2	db	0
repstartorinfo2 	db	0
rependandinfo1		dw	0
rependorinfo1		dw	0
rependandinfo2		db	0
rependorinfo2		db	0

oldpegandinfo		db	0
oldrepstartandinfo1	dw	0
oldrepstartandinfo2	db	0
oldrependandinfo1	dw	0
oldrependandinfo2	db	0


Justnowsave1		dd	0
Justnowsave2		dd	0

ClipPegStart		dd	80*1000; 10*1000=no clio
ClipPegEnd		dd	80*1000
ClipPegStartOld 	dd	80*1000
ClipPegEndOld		dd	80*1000
TopClipSpecial		dd	0
TopClipSpecialOld	dd	0

HidePlayPeg		db	0
UpdateAllPlayPeg	db	0

MouseDo 		db	0

MoveThePegs	Proc	Near
	;cmp	 pullmode,0
	;jnz	 endofmove

	cmp	Menu_popup,39

	jz	_ret
	cmp	Menu_popup,41
	jz	_ret
	cmp	Menu_popup,29
	jz	_ret
	cmp	Menu_popup,35
	jz	_ret
	cmp	Menu_popup,38
	jz	_ret

	cmp	menu_downscreen,5
	jz	skipcheck
	cmp	menu_downscreen,4
	jnz	endofmove
skipcheck:

	cmp	skippapegs,0
	jz	noquitmove
	ret
noquitmove:
	pushad
	move	edi,0a0000h			;set edi
	add	edi,225*80  ;???




	cmp	peghide,0			;hide the pegs
	jz	nohiding
	mov	PegPos,-1
	mov	repstartpos,-1
	mov	rependpos,-1
	jmp	afterhidething
nohiding:
						;get peg offset on screen
	mov	eax,playpegoff
	;add	 eax,sampmainoffset
	sub	eax,viewsampoffset
	cmp	eax,0
	jl	hidepeg_
	mov	ebx,599
	mul	ebx
	mov	ebx,viewsamplength
	div	ebx
;	 cmp	 eax,600
;	 jb	 skille2
;	 mov	 eax,600
;skille2:
	cmp	eax,599
	ja	hidepeg_
	add	eax,32
	mov	pegpos,eax
	shr	eax,3
	add	eax,edi
	mov	pegposScreen,eax
	jmp	afterhidepeg
hidepeg_:
	mov	pegpos,-1
afterhidepeg:
				      ;-------------------- Clip Peg 1
	pushad
	mov	TopClipSpecial,0
	mov	ClipPegStart,80*1000
	mov	ClipPegEnd,80*1000
	cmp	Menu_popup,23
	jz	SkipThat
	cmp	Menu_popup,0
	jnz	ClipPopup
SkipThat:
	mov	eax,PegPos
	lea	ebp,BoxClip
	add	ebp,4*4

	cmp	BoxesToClip,0
	jz	AfterClipPeg
	mov	TopClipSpecial,80*16

	cmp	eax,[ebp]		;First box
	jb	NextBoxas
	cmp	eax,[ebp+8]
	ja	NextBoxas
	cmp	dword ptr [ebp+4],352
	ja	NextBoxas
	cmp	dword ptr [ebp+12],225
	jb	NextBoxas
	mov	ClipPegStart,0*80
	cmp	dword ptr [ebp+4],225
	jbe	JustClipUp
	mov	eax,dword ptr [ebp+4]
	sub	eax,225
	mov	ebx,80
	mul	ebx
	mov	ClipPegStart,eax
JustClipUp:
	mov	ClipPegEnd,127*80
	cmp	dword ptr [ebp+12],352
	jae	JustClipDown
	mov	eax,dword ptr [ebp+12]
	sub	eax,225
	mov	ebx,80
	mul	ebx
	mov	ClipPegEnd,eax
JustClipDown:
	jmp	AfterClipPeg


NextBoxas:				;Next box
	cmp	BoxesToClip,2
	jbe	AfterClipPeg
	add	ebp,16
	mov	eax,PegPos
	cmp	eax,[ebp]
	jb	AfterClipPeg
	cmp	eax,[ebp+8]
	ja	AfterClipPeg
	cmp	dword ptr [ebp+4],352
	ja	AfterClipPeg
	cmp	dword ptr [ebp+12],225
	jb	AfterClipPeg
	mov	ClipPegStart,0*80
	cmp	dword ptr [ebp+4],225
	jbe	JustClipUp2
	mov	eax,dword ptr [ebp+4]
	sub	eax,225
	mov	ebx,80
	mul	ebx
	mov	ClipPegStart,eax
JustClipUp2:
	mov	ClipPegEnd,127*80
	cmp	dword ptr [ebp+12],352
	jae	JustClipDown2
	mov	eax,dword ptr [ebp+12]
	sub	eax,225
	mov	ebx,80
	mul	ebx
	mov	ClipPegEnd,eax
JustClipDown2:
	jmp	AfterClipPeg
ClipPopUp:					;Popup
	mov	eax,PegPos
	lea	ebp,PopUpPlane1
	mov	ebx,[ebp]
	shl	ebx,3
	cmp	eax,ebx
	jb	AfterClipPeg
	mov	ebx,[ebp+8]
	shl	ebx,3
	cmp	eax,ebx
	ja	AfterClipPeg
	cmp	dword ptr [ebp+4],352
	ja	AfterClipPeg
	cmp	dword ptr [ebp+12],225
	jb	AfterClipPeg
	mov	ClipPegStart,0*80
	cmp	dword ptr [ebp+4],225
	jbe	JustClipUp3
	mov	eax,dword ptr [ebp+4]
	sub	eax,225
	mov	ebx,80
	mul	ebx
	mov	ClipPegStart,eax
JustClipUp3:
	mov	ClipPegEnd,127*80
	cmp	dword ptr [ebp+12],352
	jae	JustClipDown3
	mov	eax,dword ptr [ebp+12]
	sub	eax,225
	mov	ebx,80
	mul	ebx
	mov	ClipPegEnd,eax
JustClipDown3:
AfterClipPeg:
	popad

				      ;--------------------


	movzx	ebp,currentsample		     ;Hide rep pegs
	mov	al,byte ptr [VoiceControl+ebp]
	bt	ax,3
	jc	NoHidePegs
	mov	ebp,repstartpos
	mov	justnowsave1,ebp
	mov	ebp,rependpos
	mov	justnowsave2,ebp
	mov	repstartpos,-1
	mov	rependpos,-1
	jmp	afterhidething2
NoHidePegs:


						;get repeat start offset on screen
	movzx	ebp,currentsample
	shl	ebp,2
	mov	eax,[ebp+loopstart]
	sub	eax,[ebp+sampleoffsetstart]
	movzx	ebp,currentsample
	shl	ebp,2
	;add	 eax,sampmainoffset
	sub	eax,viewsampoffset
	cmp	eax,0
	jl	hiderepstart_
	mov	ebx,599
	mul	ebx
	mov	ebx,viewsamplength
	div	ebx
	cmp	eax,599
	ja	hiderepstart_
	add	eax,32	;;;
	mov	repstartpos,eax
	shr	eax,3
	add	eax,edi
	mov	repstartposScreen,eax
	jmp	afterhiderepstart
hiderepstart_:
	mov	repstartpos,-1
afterhiderepstart:
						;get repeat end offset on screen
	movzx	ebp,currentsample
	shl	ebp,2
	mov	eax,[ebp+loopend]
	sub	eax,[ebp+sampleoffsetstart]
	;add	 eax,sampmainoffset
	sub	eax,viewsampoffset
	cmp	eax,0
	jl	hiderepend_
	mov	ebx,599
	mul	ebx
	mov	ebx,viewsamplength
	div	ebx
	inc	eax
	cmp	eax,599
	jnz	skille
	mov	eax,599
skille:
	cmp	eax,605
	ja	hiderepend_
	cmp	eax,599
	jbe	hiddas1
	mov	eax,599
hiddas1:
	add	eax,32 ;;;
	mov	rependpos,eax
	shr	eax,3
	add	eax,edi
	mov	rependposScreen,eax
	jmp	afterhiderepend
hiderepend_:
	mov	rependpos,-1
afterhiderepend:

	cmp	Menu_popup,0
	jz	NoQuittas
	mov	eax,rependpos
	cmp	eax,pegpos
	jz	_retp
	mov	eax,repstartpos
	cmp	eax,pegpos
	jz	_retp
	mov	oldrepstartpos,-1
	mov	oldrependpos,-1
	mov	repstartpos,-1
	mov	rependpos,-1
NoQuittas:

	mov	eax,repstartpos 		;repstart write information
	and	eax,7
	mov	ebx,7
	sub	ebx,eax
	xor	ax,ax
	bts	ax,bx
	mov	ah,al
	xor	ah,0ffh
	mov	repstartandinfo2,ah
	mov	repstartorinfo2,al
	mov	ecx,repstartpos
	and	ecx,7
	mov	bx,0FF00h
	inc	cl
	shr	bx,cl
	ror	bx,8
	mov	ax,bx
	xor	ax,0ffffh
	mov	repstartandinfo1,ax
	mov	repstartorinfo1,bx

	mov	eax,rependpos			 ;repend write information
	and	eax,7
	mov	ebx,7
	sub	ebx,eax
	xor	ax,ax
	bts	ax,bx
	mov	ah,al
	xor	ah,0ffh
	mov	rependandinfo2,ah
	mov	rependorinfo2,al
	mov	ecx,rependpos
	sub	ecx,32 ;***
	and	ecx,7
	mov	bx,0FF00h
	shr	bx,cl
	ror	bx,8
	mov	ax,bx
	xor	ax,0ffffh
	mov	rependandinfo1,ax
	mov	rependorinfo1,bx

Afterhidething2:
	mov	eax,pegpos			;peg write information
	and	eax,7
	mov	ebx,7
	sub	ebx,eax
	xor	ax,ax
	bts	ax,bx
	mov	ah,al
	xor	ah,0ffh
	mov	pegandinfo,ah
	mov	pegorinfo,al

afterhidething:
	mov	eax,oldpegpos			;calculate old screenpos
	push	eax
	sub	eax,32
	shr	eax,3
	mov	oldpegposscreenL,eax
	pop	eax

	shr	eax,3
	add	eax,edi
	mov	oldpegposscreen,eax
	mov	eax,oldrepstartpos
	push	eax
	sub	eax,32
	shr	eax,3
	mov	oldrepstartposscreenL,eax
	pop	eax

	shr	eax,3
	add	eax,edi
	mov	oldrepstartposscreen,eax
	mov	eax,oldrependpos
	push	eax
	sub	eax,32
	shr	eax,3
	mov	oldrependposscreenL,eax
	pop	eax

	shr	eax,3
	add	eax,edi
	mov	oldrependposscreen,eax
						;speed up and skip some pegs
						;if possible
	mov	eax,pegpos
	mov	pegpos2,eax
	mov	eax,repstartpos
	mov	repstartpos2,eax
	mov	eax,rependpos
	mov	rependpos2,eax
	cmp	themovepeg,0
	jz	noparticular
	cmp	themovepeg,2
	jz	movepeg2_
	cmp	themovepeg,3
	jz	movepeg3_
							;repeat start peg
	mov	eax,repstartposscreen ;hide offsetpeg
	cmp	eax,pegposscreen
	jb	dohideoffset
	mov	ebx,eax
	sub	ebx,1
	cmp	ebx,pegposscreen
	jbe	nohideoffset
dohideoffset:
	mov	eax,oldrepstartposscreen
	cmp	eax,pegposscreen
	jb	dohideoffset_
	mov	ebx,eax
	sub	ebx,1
	cmp	ebx,pegposscreen
	jbe	nohideoffset
dohideoffset_:
	mov	pegpos,-1
	mov	oldpegpos,-1
nohideoffset:
	mov	rependpos,-1
	mov	oldrependpos,-1
	jmp	noparticular
							;repeat end peg
movepeg2_:
	mov	eax,rependposscreen ;hide offsetpeg
	cmp	eax,pegposscreen
	ja	dohideoffset2
	mov	ebx,eax
	add	ebx,1
	cmp	ebx,pegposscreen
	jae	nohideoffset2
dohideoffset2:
	mov	eax,oldrependposscreen
	cmp	eax,pegposscreen
	ja	dohideoffset2_
	mov	ebx,eax
	add	ebx,1
	cmp	ebx,pegposscreen
	jae	nohideoffset2
dohideoffset2_:
	mov	pegpos,-1
	mov	oldpegpos,-1
nohideoffset2:
	mov	repstartpos,-1
	mov	oldrepstartpos,-1
	jmp	noparticular

							;offsetpeg
movepeg3_:
	mov	eax,pegposscreen      ;hide start
	cmp	eax,repstartposscreen
	ja	dohidestart
	mov	ebx,repstartposscreen
	sub	ebx,1
	cmp	eax,ebx
	jae	nohidestart
dohidestart:
	mov	eax,oldpegposscreen
	cmp	eax,repstartposscreen
	ja	dohidestart_
	mov	ebx,repstartposscreen
	sub	ebx,1
	cmp	eax,ebx
	jae	nohidestart
dohidestart_:
	mov	repstartpos,-1
	mov	oldrepstartpos,-1
nohidestart:
	mov	eax,pegposscreen    ;hide end
	cmp	eax,rependposscreen
	jb	dohideend
	mov	ebx,rependposscreen
	add	ebx,1
	cmp	eax,ebx
	jbe	nohideend
dohideend:
	mov	eax,oldpegposscreen
	cmp	eax,rependposscreen
	jb	dohideend_
	mov	ebx,rependposscreen
	add	ebx,1
	cmp	eax,ebx
	jbe	nohideend
dohideend_:
	mov	rependpos,-1
	mov	oldrependpos,-1
nohideend:
noparticular:

	cmp	pegpos,-1
	jz	skolas
	mov	ebp,pegpos
	dec	ebp
	;mov	 mouseX1,bp
	add	bp,3
	;mov	 mouseX2,bp
	;mov	 mousey1,225
	;mov	 mousey2,352
skolas:

	mov	mousedo,0
	cmp	TheMovePeg,3
	jnz	DoMouseNow
	cmp	mouseY,225-16
	jb	NoMouseNow
	cmp	mouseY,352
	ja	NoMouseNow
	mov	ecx,PegPos
	movzx	ebp,MouseX
	cmp	ebp,ecx
	ja	NoMouseNowTRORJAG
	add	ebp,16
	cmp	ebp,ecx
	jb	NoMouseNowTRORJAG
	jmp	DoMouseNow
NoMouseNowTRORJAG:
	mov	ecx,OldPegPos
	movzx	ebp,MouseX
	cmp	ebp,ecx
	ja	NoMouseNow
	add	ebp,16
	cmp	ebp,ecx
	jb	NoMouseNow
DoMouseNow:
	mov	MouseDo,1
	call	mouseoff
NoMouseNow:
	xor	ebp,ebp
	xor	esi,esi
	mov	ecx,128
megaputtaloop1:
	push	ecx

	mov	savaadd,0
	mov	saveebpadd,1
	mov	ecx,3
megaloopa2:
	cmp	savaadd,2
	jnz	notspeedup
	inc	savaadd
	shl	saveebpadd,1
notspeedup:
	mov	ah,saveebpadd			;set bitplanes
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh
	mov	ah,savaadd
	mov	al,4
	out	dx,ax

	cmp	saveebpadd,1			;restore bit plane 0
	jnz	noplane1

	mov	eax,75
	mul	esi
	add	eax,viewbuffer

	cmp	oldpegpos,-1		;peg
	jz	norestore1
	cmp	ebp,TopClipSpecialOld
	jb	norestore1
	cmp	ClipPegStartOld,80*1000
	jz	DOIT1
	cmp	ebp,ClipPegStartOld
	jb	DOIT1
	cmp	ebp,ClipPegEndOld
	jbe	NoRestore1
DOIT1:
	mov	ebx,eax
	add	ebx,oldpegposscreenL
	;sub	 ebx,32
	mov	dl,[ebx]
	mov	ebx,oldpegposscreen
	add	ebx,ebp
	mov	dh,oldpegandinfo
	and	[ebx],dh
	xor	dh,0ffh
	and	dl,dh
	or	[ebx],dl
norestore1:

	cmp	oldrepstartpos,-1	;repstart
	jz	norestore2
	cmp	esi,8
	jb	restoretheword2
	mov	ebx,eax
	add	ebx,oldrepstartposscreenL
	;sub	 ebx,32
	mov	dl,[ebx]
	mov	ebx,oldrepstartposscreen
	add	ebx,ebp
	mov	dh,oldrepstartandinfo2
	and	[ebx],dh
	xor	dh,0ffh
	and	dl,dh
	or	[ebx],dl
	jmp	norestore2
restoretheword2:
	cmp	oldrepstartposscreenL,1
	ja	nospecialrestore2
	mov	ebx,eax
	add	ebx,oldrepstartposscreenL
	;sub	 ebx,32
	dec	ebx
	mov	dx,[ebx]
	mov	ebx,oldrepstartposscreen
	dec	ebx
	add	ebx,ebp
	xor	dl,dl
	push	cx
	mov	cx,oldrepstartandinfo1
	and	[ebx],cx
	xor	cx,0ffffh
	and	dx,cx
	or	[ebx],dx
	pop	cx
	jmp	norestore2
nospecialrestore2:
	mov	ebx,eax
	add	ebx,oldrepstartposscreenL
	dec	ebx
	mov	dx,[ebx]
	mov	ebx,oldrepstartposscreen
	dec	ebx
	add	ebx,ebp
	push	cx
	mov	cx,oldrepstartandinfo1
	and	[ebx],cx
	xor	cx,0ffffh
	and	dx,cx
	or	[ebx],dx
	pop	cx
norestore2:

	cmp	oldrependpos,-1       ;repend
	jz	norestore3
	cmp	esi,8
	jb	restoretheword3
	mov	ebx,eax
	add	ebx,oldrependposscreenL
	mov	dl,[ebx]
	mov	ebx,oldrependposscreen
	add	ebx,ebp
	mov	dh,oldrependandinfo2
	and	[ebx],dh
	xor	dh,0ffh
	and	dl,dh
	or	[ebx],dl
	jmp	norestore3
restoretheword3:
	cmp	oldrependposscreenL,75 ;8
	jb	nospecialrestore3
	mov	ebx,eax
	add	ebx,oldrependposscreenL
	mov	dx,[ebx]
	mov	ebx,oldrependposscreen
	add	ebx,ebp
	xor	dh,dh
	push	cx
	mov	cx,oldrependandinfo1
	and	[ebx],cx
	xor	cx,0ffffh
	and	dx,cx
	or	[ebx],dx
	pop	cx
	jmp	norestore3
nospecialrestore3:
	mov	ebx,eax
	add	ebx,oldrependposscreenL
	mov	dx,[ebx]
	mov	ebx,oldrependposscreen
	add	ebx,ebp
	push	cx
	mov	cx,oldrependandinfo1
	and	[ebx],cx
	xor	cx,0ffffh
	and	dx,cx
	or	[ebx],dx
	pop	cx
norestore3:
	jmp	aftertherestore
noplane1:
						;restore bitplane 1,2,3
	cmp	oldpegpos,-1	  ;peg
	jz	skiprestore1
	cmp	ebp,TopClipSpecialOld
	jb	skiprestore1
	cmp	ClipPegStartOld,80*1000
	jz	DOIT1_5
	cmp	ebp,ClipPegStartOld
	jb	DOIT1_5
	cmp	ebp,ClipPegEndOld
	jbe	skiprestore1
DOIT1_5:
	mov	ebx,oldpegposscreen
	add	ebx,ebp
	mov	dl,oldpegandinfo
	and	byte ptr [ebx],dl
skiprestore1:

	cmp	oldrepstartpos,-1   ;repstart
	jz	skiprestore2
	mov	ebx,oldrepstartposscreen
	add	ebx,ebp
	cmp	esi,8
	jb	restoreword2
	mov	dl,oldrepstartandinfo2
	and	byte ptr [ebx],dl
	jmp	skiprestore2
restoreword2:
	dec	ebx
	mov	dx,oldrepstartandinfo1
	and	word ptr [ebx],dx
skiprestore2:

	cmp	oldrependpos,-1       ;repend
	jz	skiprestore3
	mov	ebx,oldrependposscreen
	add	ebx,ebp
	cmp	esi,8
	jb	restoreword3
	mov	dl,oldrependandinfo2
	and	byte ptr [ebx],dl
	jmp	skiprestore3
restoreword3:
	mov	dx,oldrependandinfo1
	and	word ptr [ebx],dx
skiprestore3:
aftertherestore:

					;update new pegs!!!!!!
					;show peg
					;show repstart
	cmp	repstartpos,-1
	jz	notshow2
	mov	ebx,repstartposscreen
	add	ebx,ebp
	movzx	dx,savaadd
	cmp	esi,8
	jb	showword2
	mov	al,repstartandinfo2
	and	[ebx],al
	bt	repeatcolor,dx
	jnc	notshow2
	mov	al,repstartorinfo2
	or	[ebx],al
	jmp	notshow2
showword2:
	mov	ax,repstartandinfo1
	dec	ebx
	and	[ebx],ax
	bt	repeatcolor,dx
	jnc	notshow2
	mov	ax,repstartorinfo1
	or	[ebx],ax
notshow2:
					;show repend
	cmp	rependpos,-1
	jz	notshow3
	mov	ebx,rependposscreen
	add	ebx,ebp
	movzx	dx,savaadd
	cmp	esi,8
	jb	showword3
	mov	al,rependandinfo2
	and	[ebx],al
	bt	repeatcolor,dx
	jnc	notshow3
	mov	al,rependorinfo2
	or	[ebx],al
	jmp	notshow3
showword3:
	mov	ax,rependandinfo1
	and	[ebx],ax
	bt	repeatcolor,dx
	jnc	notshow3
	mov	ax,rependorinfo1
	or	[ebx],ax
notshow3:

	cmp	UpdateAllPlayPeg,1
	jnz	SkipDOit
	mov	ClipPegStart,80*1000
	mov	ClipPegEnd,80*1000
	jmp	DOIT2
SkipDOit:
	cmp	ebp,TopClipSpecial
	jb	NotShow1
	cmp	HidePlayPeg,1
	jz	NotShow1
	cmp	pegpos,-1
	jz	notshow1
	cmp	ClipPegStart,80*1000
	jz	DOIT2
	cmp	ebp,ClipPegStart
	jb	DOIT2
	cmp	ebp,ClipPegEnd
	jbe	notShow1
DOIT2:
	mov	ebx,pegposscreen
	add	ebx,ebp
	movzx	dx,savaadd
	mov	al,pegandinfo
	and	[ebx],al
	bt	pegcolor,dx
	jnc	notshow1
	mov	al,pegorinfo
	or	[ebx],al
notshow1:
	mov	UpdateAllPlaypeg,0

	shl	saveebpadd,1
	inc	savaadd
	loop	megaloopa2

	inc	esi
	add	ebp,80
	pop	ecx
	loop	megaputtaloop1
	cmp	Mousedo,0
	jz	noMon
	call	mouseon
noMon:
	;call	 mousereset

	mov	eax,ClipPegStart
	mov	ClipPegStartOld,eax
	mov	eax,ClipPegEnd
	mov	ClipPegEndOld,eax
	mov	eax,TopClipSpecial
	mov	TopClipSpecialOld,eax

	comment &
	cmp	themovepeg,3
	jnz	skippa1_
	mov	al,pegandinfo
	mov	oldpegandinfo,al
	mov	eax,pegpos
	mov	oldpegpos,eax
skippa1_:
	cmp	themovepeg,1
	jnz	skippa2_
	mov	ax,repstartandinfo1
	mov	oldrepstartandinfo1,ax
	mov	al,repstartandinfo2
	mov	oldrepstartandinfo2,al
	mov	eax,repstartpos
	mov	oldrepstartpos,eax
skippa2_:
	cmp	themovepeg,2
	jnz	skippa3_
	mov	ax,rependandinfo1
	mov	oldrependandinfo1,ax
	mov	al,rependandinfo2
	mov	oldrependandinfo2,al
	mov	eax,rependpos
	mov	oldrependpos,eax
skippa3_:
	cmp	themovepeg,0
	jnz	skippa4_
	&

	mov	al,pegandinfo
	mov	oldpegandinfo,al
	mov	ax,repstartandinfo1
	mov	oldrepstartandinfo1,ax
	mov	al,repstartandinfo2
	mov	oldrepstartandinfo2,al
	mov	ax,rependandinfo1
	mov	oldrependandinfo1,ax
	mov	al,rependandinfo2
	mov	oldrependandinfo2,al
	mov	eax,pegpos2
	mov	oldpegpos,eax
	cmp	HidePlayPeg,1
	jnz	nohideit
	mov	OldPegPos,-1
nohideit:
	mov	eax,repstartpos2
	mov	oldrepstartpos,eax
	mov	eax,rependpos2
	mov	oldrependpos,eax
skippa4_:
	mov	themovepeg,0
	popad
endofmove:
	movzx	ebp,currentsample		     ;Hide rep pegs
	mov	al,byte ptr [VoiceControl+ebp]
	bt	ax,3
	jc	RestoreSpecial
	mov	ebp,justnowsave1
	mov	repstartpos,ebp
	mov	ebp,justnowsave2
	mov	rependpos,ebp
RestoreSpecial:


	call	mouseoff
	call	DrawSampLine

	ret
MoveThePegs	Endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Sample Play
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SamplePlay2:
	pushad
	jmp	SSS1
SamplePlay	Proc	Near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	sampleplayend
SSS1:
	movzx	edi,CursorChannel	;Current Channel
	movzx	edi,byte ptr [ChanPos+edi]
	movzx	ebx,CurrentSample	;Current Sample
	call	SampleEditorKeyBoardPlay
sampleplayend:
	popad
	ret
SamplePlay	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Sample Stop
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampleStop2:
	pushad
	jmp	sss2
SampleStop	Proc	Near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	samplestopend
sss2:
	call	sampleedstop

samplestopend:
	popad
	ret
SampleStop	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Just Convert
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
JustConvert	Proc	Near
	Pushad
	cmp	samplength,0
	jz	SampConvertEndDD

	cmp	sampbits,1
	jz	convert16DD



	mov	edi,sampmainoffset	;convert 8bits
	mov	ecx,samplength
convertloop8DD:
	xor	byte ptr [edi],128
	inc	edi
	loop	convertloop8DD
	jmp	sampconvertendDD

convert16DD:
	mov	edi,sampmainoffset	;convert 16bits
	mov	ecx,samplength
convertloop16DD:
	xor	word ptr [edi],32768
	add	edi,2
	loop	convertloop16DD

SampConvertEndDD:
	Popad
	Ret
JustConvert	EndP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Unpack Mask Text
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FontBuffer	dd	0
FontAdd 	equ	60000
;TextMaskBuffer db	1920	dup(0)
Skippasample	db	0
UnpackMaskText	Proc	Near
	pushad
	mov	eax,pcxbuffer
	mov	fontbuffer,eax

	mov	skipput,1			;packar upp fonten
	mov	eax,[pcxoffsets+124]
	call	showthepcx

	mov	esi,pcxbuffer
	mov	edi,fontbuffer
	add	edi,fontadd
	mov	ecx,80*12*2*4
	rep	movsb
						;make textmaskbuffet
	mov	esi,fontbuffer
	add	esi,fontadd
	mov	ecx,24
maskmakeloop:
	push	ecx

	mov	ecx,80
maskaloppamake:
	mov	al,[esi]
	and	al,[esi+80]
	and	al,[esi+160]
	and	al,[esi+240]
	stosb
	inc	esi
	loop	maskaloppamake

	add	esi,320-80
	pop	ecx
	loop	maskmakeloop
						;mask font
	mov	edi,fontbuffer
	add	edi,fontadd
	mov	esi,edi
	add	esi,1920*4
	mov	ecx,24
maskafonten:
	push	ecx

	mov	ecx,80
maskfonten2:
	lodsb
	xor	al,0ffh
	and	[edi],al
	and	[edi+80],al
	and	[edi+160],al
	and	[edi+240],al
	inc	edi
	loop	maskfonten2

	add	edi,320-80
	pop	ecx
	loop	maskafonten

	popad
	ret
UnpackMaskText	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Write Mask Text
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;	 esi = text offset (End with the letter $)
;      MaskX = Xpos
;      MaskY = Ypos
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MaskX		dd	0
MaskY		dd	0
WriteMaskText	Proc	Near
	pushad

	mov	edi,pcxbuffer
	mov	eax,maskY
	mov	ebx,sizeX
	shl	ebx,2
	mul	ebx
	add	eax,maskx
	add	edi,eax


TextMaskLoopen:

	lodsb
	cmp	al,'$'
	jz	endofmaska
	push	edi
	push	esi
	and	eax,0ffh
	xor	edx,edx
	mov	ebx,80
	div	ebx
	mov	ecx,edx
	mov	ebx,12*80
	mul	ebx
	mov	ebp,eax
	shl	eax,2
	add	eax,ecx
	add	ebp,ecx

	mov	esi,fontbuffer
	add	esi,fontadd
	add	ebp,esi
	add	ebp,1920*4
	add	esi,eax

	mov	ebx,sizeX

	mov	ecx,12
maskatextloppan:
	push	ecx
	mov	ah,[ebp]
	add	ebp,80
	mov	ecx,4
masklopp:
	and	[edi],ah
	mov	al,[esi]
	or	[edi],al
	add	esi,80
	add	edi,ebx
	loop	masklopp
	pop	ecx
	loop	maskatextloppan

	pop	esi
	pop	edi
	inc	edi
	jmp	textmaskloopen
endofmaska:
	popad
	ret
WriteMaskText	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Clear zero start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ClearZeroStart		Proc	Near
	pushad
	cmp	SampBits,1
	jz	ClearZeroStart16
	mov	esi,SampMainOffset
	mov	ecx,SampLength
	xor	edx,edx
	mov	ah,[esi]
SearchZeroLoop1:
	lodsb
	cmp	al,ah
	jnz	AfterSS
	inc	edx
	loop	SearchZeroLoop1
AfterSS:
	cmp	edx,1
	jbe	_retp
	mov	edi,SampMainOffset
	mov	esi,edi
	add	esi,edx
	mov	ecx,SampLength
	sub	ecx,edx
	rep	movsb
	sub	SampLength,edx
	_rp
ClearZeroStart16:
	_rp
ClearZeroStart		Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			Zyric Input
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:	edi=Screen offset
;		 ah= 1h=1bits font on bitplane 0
;		     8h=2bits font
;		    18h=1bits font on bitplane 3
;		 al= 1h=Decimal in fontplane 0
;		     2h=Hex in fontplane 0
;		    11h=Decimal in Fontplane 1
;		    12h=Hex in Fontplane 1
;		    21h=Decimal in Fontplane 2
;		    22h=Hex in Fontplane 2
;		ebp=Offset to variable
;		ecx=Number of digits
;		ebx=Mini size
;		edx=Max size
;		esi=Proc to call after input
;	  DigitSize=1=Byte 2=Word 3=Dword
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
AfterInputCall	dd	0
ZyricEDI	dd	0
ZyricECX	dd	0
ZyricAX 	dw	0
ZyricEBX	dd	0
ZyricEBP	dd	0
ZyricInput	Proc	Near
	pushad
	mov	AfterInputCall,esi
	mov	ZyricEDI,edi
	mov	ZyricECX,ecx
	mov	ZyricAX,ax
	mov	ZyricEBX,ebx
	mov	ZyricEBP,ebp

	move	esi,0a0000h
	sub	edi,esi
	mov	DigitTarget,ebp
	mov	DigitLimit,edx
	mov	DigitInput,29

	cmp	DigitSize,1
	jnz	NotDS1
	movzx	ebx,byte ptr [ebp]
NotDS1:
	cmp	DigitSize,2
	jnz	NotDS2
	movzx	ebx,word ptr [ebp]
NotDS2:
	cmp	DigitSize,3
	jnz	NotDS3
	mov	ebx,dword ptr [ebp]
NotDS3:
	call	InputDigits
	_rp
AfterZyricInput:
	pushad
	mov	ebp,ZyricEBP
	cmp	DigitSize,1
	jnz	NotDS1_
	movzx	ebx,byte ptr [ebp]
NotDS1_:
	cmp	DigitSize,2
	jnz	NotDS2_
	movzx	ebx,word ptr [ebp]
NotDS2_:
	cmp	DigitSize,3
	jnz	NotDS3_
	mov	ebx,dword ptr [ebp]
NotDS3_:
	mov	eax,ZyricEBX
	cmp	ebx,eax
	jb	DOSmallCLip
	mov	eax,ebx
DOsmallCLIP:
	cmp	DigitSize,1
	jnz	NotDS1_2
	mov	byte ptr [ebp],al
NotDS1_2:
	cmp	DigitSize,2
	jnz	NotDS2_2
	mov	word ptr [ebp],ax
NotDS2_2:
	cmp	DigitSize,3
	jnz	NotDS3_2
	mov	dword ptr [ebp],eax
NotDS3_2:
	mov	ebx,eax
	mov	edi,ZyricEDI
	mov	ecx,ZyricECX
	mov	ax,ZyricAX
	movzx	edx,al
	shr	edx,4
	mov	FontPlane,edx
	call	PutDecimal
	mov	FontPlane,0
EndExtraZyric:
	call	[AfterInputCall]
	_rp
ZyricInput	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Input Values
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampInputTemp	dw	0
InputValueTemp	dw	0
SampSizeTemp	dd	0
SampMarkTemp	dd	0
RepBegTemp	dd	0
RepEndTemp	dd	0
SampInputen:				;------------- Samp Input
	pushad
	mov	ax,CurrentSample
	and	ax,0fh
	mov	SampInputTemp,ax
	move	edi,0a0000h+440/8+375*80
	mov	ah,1h
	mov	al,1h
	cmp	SampHexDec,0
	jz	Deca
	mov	al,2h
Deca:
	lea	ebp,SampInputTemp
	mov	ecx,2
	xor	ebx,ebx
	mov	edx,15
	lea	esi,AfterSampInputen
	mov	Digitsize,2
	call	ZyricInput
	_rp
AfterSampInputen:
	pushad
	mov	ax,CurrentSample
	mov	bx,SampInputTemp
	and	ax,not 0fh
	or	ax,bx
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
	_rp
PosInputen:				;------------- Pos input
	pushad
	cmp	SampLength,0
	jz	_retp
	move	edi,0a0000h+400/8+392*80
	mov	ah,1h
	mov	al,1h
	lea	ebp,PlayPegOff
	mov	ecx,7
	xor	ebx,ebx
	mov	edx,SampLength
	dec	edx
	lea	esi,AfterPosInputen
	mov	Digitsize,3
	call	ZyricInput
	_rp
AfterPosInputen:
	pushad
	mov	themovepeg,3
	call	movethepegs
	_rp
ValueInputen:				;------------- Value input
	pushad
	cmp	SampLength,0
	jz	_retp
	call	CheckIfShadow2
	jc	_retp

	cmp	SampBits,1
	jz	InputVal16

	mov	eax,PlayPegOff
	add	eax,SampMainOffset
	movzx	bx,byte ptr [eax]
	mov	InputValueTemp,bx
	move	edi,0a0000h+416/8+409*80
	mov	ah,1h
	mov	al,1h
	lea	ebp,InputValueTemp
	mov	ecx,5
	xor	ebx,ebx
	mov	edx,255
	lea	esi,AfterValInput8
	mov	Digitsize,2
	call	ZyricInput
	_rp
InputVal16:
	mov	eax,PlayPegOff
	shl	eax,1
	add	eax,SampMainOffset
	mov	bx,word ptr [eax]
	mov	InputValueTemp,bx
	move	edi,0a0000h+416/8+409*80
	mov	ah,1h
	mov	al,1h
	lea	ebp,InputValueTemp
	mov	ecx,5
	xor	ebx,ebx
	mov	edx,65535
	lea	esi,AfterValInput16
	mov	Digitsize,2
	call	ZyricInput
	_rp
AfterValInput8:
	pushad
	mov	ebx,PlayPegOff
	add	ebx,SampMainOffset
	mov	ax,InputValueTemp
	mov	[ebx],al
	call	ViewSamp
	call	updatesampletogus
	_rp
AfterValInput16:
	pushad
	mov	ebx,PlayPegOff
	shl	ebx,1
	add	ebx,SampMainOffset
	mov	ax,InputValueTemp
	mov	[ebx],ax
	call	ViewSamp
	call	updatesampletogus
	_rp
SmpSizeInputen: 			;------------- Smp size input
	pushad
	cmp	SampLength,0
	jz	_retp
	call	CheckIfShadow2
	jc	_retp
	mov	eax,SampLength
	mov	SampSizeTemp,eax
	move	edi,0a0000h+400/8+426*80
	mov	ah,1h
	mov	al,1h
	lea	ebp,SampSizeTemp
	mov	ecx,7
	xor	ebx,ebx
	mov	edx,99999999
	lea	esi,AfterSmpSizeInputen
	mov	Digitsize,3
	call	ZyricInput
	_rp
AfterSmpSizeInputen:
	pushad
	call	saveundo

	mov	eax,SampSizeTemp
	mov	ebx,SampLength
	mov	SampLength,eax

Arrowjump:
	call	AllocSampLength

	cmp	PlayPegOff,eax
	jbe	NoPegCh
	mov	PlayPegOff,eax
NoPegCh:

	cmp	eax,ebx
	jbe	noclearas_2

	cmp	SampBits,1
	jz	cls16_2
	sub	eax,ebx
	mov	ecx,eax
	mov	edi,SampMainOffset
	add	edi,ebx
	mov	al,128
	rep	stosb
	jmp	noclearas_2
cls16_2:
	mov	edi,SampMainOffset
	sub	eax,ebx
	mov	ecx,eax
	shl	ebx,1
	add	edi,ebx
	mov	ax,32768
	rep	stosw
noclearas_2:
	call	ViewAll2
	call	updatesampletogus
	_rp
SampSizeArrowUp:			;------------- Samp size arrow up
	pushad
	call	FixButton
	call	CheckIfShadow2
	jc	_retp
	cmp	samplength,0
	jz	_retp
	mov	undosamplength,0
	mov	eax,SampLength
	mov	ebx,eax
	inc	eax
	inc	SampLength
	jmp	ArrowJump
SampSizeArrowDown:			;------------- Samp size arrow down
	pushad
	call	FixButton
	call	CheckIfShadow2
	jc	_retp
	cmp	samplength,0
	jz	_retp
	mov	undosamplength,0
	mov	eax,SampLength
	mov	ebx,eax
	dec	eax
	dec	SampLength
	jmp	ArrowJump
MarkSizeInputen:			;------------- Mark Size Input
	pushad
	cmp	SampLength,0
	jz	_retp
	cmp	SampMarkStart,-1
	jz	_retp
	mov	eax,SampMarkEnd
	sub	eax,SampMarkStart
	mov	SampMarkTemp,eax
	move	edi,0a0000h+400/8+443*80
	mov	ah,1h
	mov	al,1h
	lea	ebp,SampMarkTemp
	mov	ecx,7
	mov	ebx,1
	mov	edx,SampLength
	sub	edx,SampMarkStart
	lea	esi,AfterMarkInputen
	mov	Digitsize,3
	call	ZyricInput
	_rp
AfterMarkInputen:
	pushad
	mov	eax,SampMarkTemp
	add	eax,SampMarkStart
	mov	SampMarkEnd,eax
	call	ViewSamp
	_rp
MarkSizeArrowUp:			;------------- Mark Size Arrow Up
	pushad
	call	fixbutton
	cmp	SampLength,0
	jz	_retp
	cmp	SampMarkStart,-1
	jz	_retp
	mov	eax,SampLength
	cmp	SampMarkEnd,eax
	jz	_retp
	inc	SampMarkEnd
	call	ViewSamp
	_rp
MarkSizeArrowDown:			;------------- Mark Size Arrow Down
	pushad
	call	fixbutton
	cmp	SampLength,0
	jz	_retp
	cmp	SampMarkStart,-1
	jz	_retp
	mov	eax,SampMarkStart
	inc	eax
	cmp	SampMarkEnd,eax
	jz	_retp
	dec	SampMarkEnd
	call	ViewSamp
	_rp
RepBegInputen:				;------------- Rep Beg Input
	pushad
	cmp	SampLength,0
	jz	_retp
	movzx	ebp,currentsample
	mov	al,byte ptr [VoiceControl+ebp]
	bt	ax,3
	jnc	_retp

	movzx	esi,currentsample
	mov	eax,[esi*4+loopstart]
	sub	eax,[esi*4+sampleoffsetstart]
	mov	RepBegTemp,eax
	move	edi,0a0000h+536/8+375*80
	mov	ah,1h
	mov	al,1h
	add	al,LenHexDec
	lea	ebp,RepBegTemp
	mov	ecx,7
	xor	ebx,ebx
	mov	edx,[esi*4+loopend]
	sub	edx,[esi*4+sampleoffsetstart]
	lea	esi,AfterRepBegInputen
	mov	Digitsize,3
	call	ZyricInput
	_rp
AfterRepBegInputen:
	pushad
	movzx	esi,currentsample
	mov	eax,RepBegTemp
	add	eax,[esi*4+sampleoffsetstart]
	mov	[esi*4+loopstart],eax
	mov	themovepeg,1
	call	MoveThePegs
	_rp
RepEndInputen:				;------------- Rep End Input
	pushad
	cmp	SampLength,0
	jz	_retp
	movzx	ebp,currentsample
	mov	al,byte ptr [VoiceControl+ebp]
	bt	ax,3
	jnc	_retp

	movzx	esi,currentsample
	mov	eax,[esi*4+loopend]
	sub	eax,[esi*4+sampleoffsetstart]
	mov	RepEndTemp,eax
	move	edi,0a0000h+536/8+392*80
	mov	ah,1h
	mov	al,1h
	add	al,LenHexDec
	lea	ebp,RepEndTemp
	mov	ecx,7
	mov	ebx,[esi*4+loopstart]
	sub	ebx,[esi*4+sampleoffsetstart]
	mov	edx,SampLength
	lea	esi,AfterRepEndInputen
	mov	Digitsize,3
	call	ZyricInput
	_rp
AfterRepEndInputen:
	pushad
	movzx	esi,currentsample
	mov	eax,RepEndTemp
	add	eax,[esi*4+sampleoffsetstart]
	mov	[esi*4+loopEnd],eax
	mov	themovepeg,2
	call	MoveThePegs
	_rp
C4RateInputen:				;------------- C4 Rate Input
	pushad
	cmp	SampLength,0
	jz	_retp
	cmp	C2mode,1
	jz	_retp

	move	edi,0a0000h+552/8+409*80
	mov	ah,1h
	mov	al,1h
	movzx	ebp,CurrentSample
	shl	ebp,1
	lea	esi,SampleRates
	add	ebp,esi
	mov	ecx,5
	mov	ebx,522
	mov	edx,65535
	lea	esi,_ret
	mov	Digitsize,2
	call	ZyricInput
	_rp
VolumeInputen:				;------------- Volume Input
	pushad
	cmp	SampLength,0
	jz	_retp
	move	edi,0a0000h+568/8+460*80
	mov	ah,1h
	mov	al,VolumeHexDec
	inc	al
	lea	ebp,Volumes
	movzx	esi,CurrentSample
	add	ebp,esi
	mov	ecx,3
	xor	ebx,ebx
	mov	edx,7fh
	lea	esi,_ret
	mov	Digitsize,1
	call	ZyricInput
	_rp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Update Values
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
oldputs 	dd	20	 dup(-1)
olddatas	db	6	 dup(-1)
clearflag	db	0
clearflagbig	db	0
UpdateValues	proc	near
	pushad
	cmp	menu_popup,14
	jz	_retp
	cmp	Menu_popup,39
	jz	_retp
	cmp	Menu_popup,41
	jz	_retp
	cmp	Menu_popup,29
	jz	_retp
	cmp	Menu_popup,35
	jz	_retp
	cmp	Menu_popup,38
	jz	_retp

	;jmp	 puttasa
	mov	mousex1,397
	mov	mousey1,372
	mov	mousex2,456
	mov	mousey2,473

	move	edi,0a0000h		;put samp
	add	edi,50+80*375+5
	mov	ah,1
	mov	cl,2
	movzx	ebx,CurrentSample
	and	ebx,15
	cmp	ebx,[oldputs]
	jz	skippaputta1
	cmp	SampHexDec,0
	jz	PDec
	call	mouseoff
	call	PutHex
	call	mouseon
	jmp	skippaputta1
Pdec:
	call	mouseoff
	call	PutDecimal
	call	mouseon
skippaputta1:
	mov	[oldputs],ebx


	cmp	SampLength,0		;clear all if no samp
	jnz	NoClearas

	call	mousereset
	cmp	ClearFlagBig,1
	jz	LastUpdate
	mov	clearflagbig,1
	call	MouseOff
	move	edi,0a0000h+536/8+80*375
	planewrite 00001111b
	mov	ecx,6
Ojloop2:
	push	edi
	push	ecx
	mov	ecx,12
Clearbl2:
	mov	dword ptr [edi],0
	mov	word ptr [edi+4],0
	mov	byte ptr [edi+6],0
	add	edi,80
	loop	clearbl2
	pop	ecx
	pop	edi
	add	edi,17*80
	loop	Ojloop2

	move	edi,0a0000h+400/8+80*392
	planewrite 00001111b
	mov	ecx,5
Ojloop2_:
	push	edi
	push	ecx
	mov	ecx,12
Clearbl2_:
	mov	dword ptr [edi],0
	mov	word ptr [edi+4],0
	mov	byte ptr [edi+6],0
	add	edi,80
	loop	clearbl2_
	pop	ecx
	pop	edi
	add	edi,17*80
	loop	Ojloop2_

	move	edi,0a0000h+288/8+80*460
	mov	ecx,12
LoopenCCC:
	mov	word ptr [edi],0
	add	edi,80
	loop	LoopenCCC
	call	MouseOn
	call	mousereset
	jmp	LastUpdate
NoClearas:
	mov	clearflagbig,0

	move	edi,0a0000h		;put pegpos
	add	edi,50+80*392
	mov	ah,1
	mov	cl,7
	mov	ebx,playpegoff
	cmp	ebx,[oldputs+1*4]
	jz	skippaputta2
	call	mouseoff
	call	PutDecimal
	call	mouseon
skippaputta2:
	mov	[oldputs+1*4],ebx

	move	edi,0a0000h		;put value
	add	edi,50+80*409+2
	mov	ah,1
	mov	cl,5
	mov	ebx,playpegoff
	shl16	ebx
	add	ebx,sampmainoffset
	movzx	edx,byte ptr [ebx]
	cmp	sampbits,0
	jz	skip16bits
	movzx	edx,word ptr [ebx]
skip16bits:
	mov	ebx,edx
	cmp	ebx,[oldputs+2*4]
	jz	skippaputta3
	call	mouseoff
	call	PutDecimal
	call	mouseon
skippaputta3:
	mov	[oldputs+2*4],ebx

	move	edi,0a0000h		;put sampsize
	add	edi,50+80*426
	mov	ah,1
	mov	cl,7
	mov	ebx,samplength
	cmp	ebx,[oldputs+3*4]
	jz	skippaputta4
	call	mouseoff
	call	PutDecimal
	call	mouseon
skippaputta4:
	mov	[oldputs+3*4],ebx

	move	edi,0a0000h		;put marksize
	add	edi,50+80*443
	mov	ah,1
	mov	cl,7
	mov	ebx,sampmarkend
	sub	ebx,sampmarkstart
	cmp	sampmarkstart,-1
	jnz	skippathis5
	mov	ebx,0
skippathis5:
	cmp	ebx,[oldputs+4*4]
	jz	skippaputta5
	call	mouseoff
	call	PutDecimal
	call	mouseon
skippaputta5:
	mov	[oldputs+4*4],ebx


	call	mousereset
	move	edi,0a0000h		;put samp bits
	add	edi,288/8+460*80
	mov	ah,1
	mov	cl,2
	mov	ebx,sampbits
	inc	ebx
	shl	ebx,3
	cmp	samplength,0
	jnz	skippathis6
	mov	ebx,0
skippathis6:
	cmp	ebx,[oldputs+5*4]
	jz	skippaputta6
	call	mouseoff
	call	PutDecimal
	call	mouseon
skippaputta6:
	mov	[oldputs+5*4],ebx
	call	mousereset

	call	mouseon
	mov	mousex1,532
	mov	mousey1,372
	mov	mousex2,593
	mov	mousey2,473


	movzx	ebp,currentsample	;rep begin
	shl	ebp,2
	mov	ebx,[ebp+loopstart]
	sub	ebx,[ebp+sampleoffsetstart]
	move	edi,0a0000h
	add	edi,536/8+80*375

			;clear --

	movzx	ebp,currentsample
	mov	al,byte ptr [VoiceControl+ebp]
	bt	ax,3
	jc	nottacleara1
	cmp	ClearFlag,1
	jz	Skippaputta8
	mov	clearflag,1
	planewrite 00001111b
	mov	ecx,2
Ojloop:
	push	ecx
	mov	ecx,12
Clearbl:
	mov	dword ptr [edi],0
	mov	word ptr [edi+4],0
	mov	byte ptr [edi+6],0
	add	edi,80
	loop	clearbl
	pop	ecx
	move	edi,0a0000h
	add	edi,536/8+80*392
	loop	Ojloop
	mov	ebx,-1
	mov	[oldputs+6*4],ebx
	mov	[oldputs+7*4],ebx
	jmp	skippaputta8
nottacleara1:
	mov	clearflag,0
			;--
	mov	ah,1
	mov	cl,7
	mov	ch,lenhexdec
	cmp	ch,[olddatas]
	jnz	nojs1
nojs1:
	cmp	ebx,[oldputs+6*4]
	jz	skippaputta7
	cmp	lenhexdec,1
	jz	puthexa1
	call	mouseoff
	call	PutDecimal
	call	mouseon
	jmp	afterhexa1
puthexa1:
	call	mouseoff
	call	PutHex
	call	mouseon
afterhexa1:
skippaputta7:
	mov	[oldputs+6*4],ebx
	mov	ch,lenhexdec
	mov	[olddatas],ch

puttasa:
	cmp	EndOrLen,1		;rep end or length
	jz	putlengtha
	movzx	ebp,currentsample
	shl	ebp,2
	mov	ebx,[ebp+loopend]
	sub	ebx,[ebp+sampleoffsetstart]
	jmp	afterputlengtha
putlengtha:
	movzx	ebp,currentsample
	shl	ebp,2
	mov	ebx,[ebp+loopend]
	sub	ebx,[ebp+loopstart]
afterputlengtha:
	move	edi,0a0000h
	add	edi,536/8+80*392
	mov	ah,1
	mov	cl,7
	mov	ch,lenhexdec
	cmp	ch,[olddatas+1]
	jnz	nojs2
nojs2:
	cmp	ebx,[oldputs+7*4]
	jz	skippaputta8
	cmp	lenhexdec,1
	jz	puthexa2
	call	mouseoff
	call	PutDecimal
	call	mouseon
	jmp	afterhexa2
puthexa2:
	call	mouseoff
	call	PutHex
	call	mouseon
afterhexa2:
skippaputta8:
	mov	[oldputs+7*4],ebx

	movzx	ebp,CurrentSample
	cmp	C2Mode,0
	jz	PrintC2Numbers_

	call	GetCurrC2RateInPeriod
	add	esi,2
	shl	eax,16
	mov	ax,si
	cmp	[OldPuts+17*4],eax
	jz	AfterOld1
	mov	[OldPuts+17*4],eax

	call	mouseoff
	mov	ah,1
	mov	cl,4
	move	edi,0a0000h+409*80+536/8
	lea	esi,Spaces
	call	PrintText

	call	GetCurrC2RateInPeriod
	add	esi,2
	move	edi,0a0000h+409*80+(536/8)+4
	mov	BitPlane,1
	call	PrintPeriod
	call	mouseon
AfterOld1:
	jmp	SkipC2Print_

PrintC2Numbers_:
	mov	ah,1
	mov	cl,5
	move	edi,0a0000h+409*80+536/8+2
	movzx	ebx,[SampleRates+ebp*2]
	cmp	ebx,[oldputs+8*4]
	jz	skippaputta9
	call	mouseoff
	call	PutDecimal			;Print SampleRate
	call	mouseon
SkipC2Print_:
skippaputta9:
	mov	[oldputs+8*4],ebx

	mov	ah,1
	mov	cl,1
	move	edi,0a0000h+426*80+536/8+5
	movzx	ebx,[FineTunes+ebp]
	and	ebx,0fh
	cmp	ebx,0
	jz	PutSpace_
	cmp	ebx,8
	jb	PutPositive1_
	mov	ebx,'-'
	jmp	PutMore_
PutPositive1_:
	mov	ebx,'+'
	jmp	PutMore_
PutSpace_:
	mov	ebx,' '
PutMore_:
	cmp	ebx,[oldputs+9*4]
	jz	skippaputta9_1
	call	mouseoff
	call	PutCharacter			;print + or -
	call	mouseon
skippaputta9_1:
	mov	[oldputs+9*4],ebx

	mov	cl,1
	move	edi,0a0000h+426*80+536/8+6
	movzx	ebx,[FineTunes+ebp]
	and	ebx,0fh
	cmp	ebx,8
	jb	PutPositive_
	sub	bl,16
	neg	bl
PutPositive_:
	cmp	ebx,[oldputs+10*4]
	jz	skippaputta10
	call	mouseoff
	call	PutHex				;Put Finetune
	call	mouseon
skippaputta10:
	mov	[oldputs+10*4],ebx

	mov	cl,1
	move	edi,0a0000h+443*80+536/8+5
	movzx	ebx,[FineTunes+ebp]
	shr	ebx,4
	cmp	ebx,8
	jz	PutSpace2_
	ja	PutPositive12_
	cmp	ebx,0
	jz	ChannelPanPot_
	mov	[oldputs+13*4],-1
	mov	[oldputs+16*4],-1
	mov	ebx,'-'
	jmp	PutMore2_
PutPositive12_:
	mov	ebx,'+'
	jmp	PutMore2_
PutSpace2_:
	mov	ebx,' '
PutMore2_:
	cmp	ebx,[oldputs+11*4]
	jz	skippaputta11
	call	mouseoff
	call	PutCharacter			;print + or -
	call	mouseon
skippaputta11:
	mov	[oldputs+11*4],ebx

	mov	cl,1
	move	edi,0a0000h+443*80+536/8+6
	movzx	ebx,[FineTunes+ebp]
	shr	ebx,4
	cmp	ebx,8
	ja	PutPositive2_
	sub	bl,16
	neg	bl
PutPositive2_:
	sub	ebx,8
	cmp	ebx,[oldputs+12*4]
	jz	skippaputta12
	call	mouseoff
	call	PutHex				;Put PanPot
	call	mouseon
skippaputta12:
	mov	[oldputs+12*4],ebx
	jmp	Volly_
ChannelPanPot_:
	mov	ebx,'C'
	cmp	ebx,[oldputs+16*4]
	jz	skippaputta16
	call	mouseoff
	call	PutCharacter
	call	mouseon
skippaputta16:
	mov	[oldputs+16*4],ebx
	inc	edi
	mov	ebx,'h'
	cmp	ebx,[oldputs+13*4]
	jz	skippaputta13
	call	mouseoff
	call	PutCharacter
	call	mouseon
skippaputta13:
	mov	[oldputs+13*4],ebx

	mov	dword ptr [oldputs+11*4],-1
	mov	dword ptr [oldputs+12*4],-1
Volly_:
	mov	cl,3
	move	edi,0a0000h+460*80+536/8+4
	movzx	ebx,[Volumes+ebp]
	cmp	VolumeHexDec,0
	jz	PutDec6_
	cmp	ebx,[oldputs+15*4]
	jz	skippaputta15
	call	mouseoff
	call	PutHex
	call	mouseon
Skippaputta15:
	mov	[oldputs+15*4],ebx
	jmp	PutHex6_
PutDec6_:
	cmp	ebx,[oldputs+14*4]
	jz	skippaputta14
	call	mouseoff
	call	PutDecimal			;Put Volume
	call	mouseon
skippaputta14:
	mov	[oldputs+14*4],ebx
PutHex6_:



	mov	eax,CurrentSampRate
	cmp	[OldPuts+18*4],eax
	jz	AfterOld1AA
	mov	[OldPuts+18*4],eax

	movzx	ebp,CurrentSample		;Put The Samp Rate
	cmp	SampRateStatus,0
	jz	PrintC2Numbers_AA

	call	mouseoff
	mov	ah,1
	mov	cl,4
	move	edi,0a0000h+460*80+400/8
	lea	esi,Spaces
	call	PrintText

	push	eax
	mov	eax,CurrentSampRate
	mov	esi,1
	cmp	eax,0
	jz	YesASampRate
	call	GetNoteFromSampleFreq
	mov	esi,eax
	add	esi,2
YesASampRate:
	pop	eax
	move	edi,0a0000h+460*80+(400/8)+4
	mov	BitPlane,1
	call	PrintPeriod
	call	mouseon
	jmp	SkipC2Print_AA

PrintC2Numbers_AA:
	mov	ebx,CurrentSampRate
	move	edi,0a0000h+460*80+400/8+2
	mov	ah,1
	mov	cl,5
	cmp	ebx,[oldputs+19*4]
	jz	skippaputta9AA
	mov	[oldputs+19*4],ebx
	call	mouseoff
	call	PutDecimal
	call	mouseon
AfterOld1AA:
SkipC2Print_AA:
skippaputta9AA:


LastUpdate:
	mov	ch,lenhexdec
	mov	[olddatas+1],ch
	call	mousereset
	popad
	ret
UpdateValues	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Convert8_16
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Convert8_16nr2:
	pushad
	jmp	sss17
Convert8_16	proc	near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	convert8_16end
sss17:

	call	CheckIfShadow
	jc	_retp

	cmp	samplength,0
	jz	convert8_16end

	cmp	sampbits,1
	jz	convert16to8
convert8to16:

	lea	esi,samptext9
	mov	menu_popup,20
	call	popuphandler
	cmp	popupstatus,1
	jz	_8_16change
	cmp	popupstatus,3
	jz	convert8_16end
;---------------------------------------------- Convert 8to16 (no samp change)
	mov	sampbits,1
	shr	samplength,1

	movzx	ebp,currentsample
	shl	ebp,2
	mov	eax,[ebp+loopstart]
	sub	eax,[ebp+sampleoffsetstart]
	shr	eax,1
	add	eax,[ebp+sampleoffsetstart]
	mov	[ebp+loopstart],eax
	mov	eax,[ebp+loopend]
	sub	eax,[ebp+sampleoffsetstart]
	shr	eax,1
	add	eax,[ebp+sampleoffsetstart]
	mov	[ebp+loopend],eax
	shr	PlayPegOff,1

	call	viewall2
	call	updatesampletogus
	mov	oldcurrentinstname,-1
	call	printsampleinfo
	popad
	ret
;---------------------------------------------- Convert 8to16 (change samp!)
_8_16change:
	mov	ecx,samplength
	mov	eax,ecx
	shl	eax,1
	call	saveundo
	mov	extrasamplength,ecx
	cmp	eax,sampmax
	ja	toosmallbuffer
	call	allocsamplength
	mov	sampbits,1

	mov	esi,undobufferoffset
	mov	edi,sampmainoffset
convertaloopa1:
	lodsb
	shl	ax,8
	stosw
	loop	convertaloopa1

	mov	undosamplength,0
	call	allocundolength
	mov	undosamplength,0
	mov	clipboardlength,0
mojaska1:
	call	viewall2
	call	updatesampletogus
	mov	oldcurrentinstname,-1
	call	printsampleinfo
	popad
	ret

convert16to8:					;16 bits

	lea	esi,samptext9
	mov	menu_popup,20
	call	popuphandler
	cmp	popupstatus,1
	jz	_16_8change
	cmp	popupstatus,3
	jz	convert8_16end

;---------------------------------------------- Convert 16to8 (no samp change)
	mov	sampbits,0
	shl	samplength,1
	movzx	ebp,currentsample
	shl	ebp,2
	mov	eax,[ebp+loopstart]
	sub	eax,[ebp+sampleoffsetstart]
	shl	eax,1
	add	eax,[ebp+sampleoffsetstart]
	mov	[ebp+loopstart],eax
	mov	eax,[ebp+loopend]
	sub	eax,[ebp+sampleoffsetstart]
	shl	eax,1
	add	eax,[ebp+sampleoffsetstart]
	mov	[ebp+loopend],eax
	shl	PlayPegOff,1
	call	viewall2
	call	updatesampletogus
	mov	oldcurrentinstname,-1
	call	printsampleinfo
	popad
	ret
;---------------------------------------------- Convert 16to8 (samp change)
_16_8change:
	mov	eax,samplength
	shr	eax,1
	neg	eax
	call	saveundo
	mov	extrasamplength,eax
	call	allocsamplength
	mov	sampbits,0

	mov	ecx,samplength
	mov	esi,undobufferoffset
	mov	edi,sampmainoffset
convertaloopa2:
	lodsw
	shr	ax,8
	stosb
	loop	convertaloopa2

	mov	undosamplength,0
	call	allocundolength
	mov	undosamplength,0
	mov	clipboardlength,0

	call	viewall2
	call	updatesampletogus
	mov	oldcurrentinstname,-1
	call	printsampleinfo

	popad
	ret


toosmallbuffer: 			    ;too small buffer
	lea	esi,samptext4
	mov	menu_popup,16 ;1
	call	popuphandler
convert8_16end:
	popad
	ret
Convert8_16	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Check auto playform
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Checkaplay: 1=All, 2=Area, 3=Screen, 4=Offset
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Checkaplay	dd	0
CheckAutoPlayForm	proc	near
	pushad
	mov	ebx,checkaplay
	mov	eax,ebx
	dec	ebx
	cmp	byte ptr [autoall+ebx],1
	jz	noooll
	mov	playform,al
	cmp	al,1
	jnz	skipallnow
	call	playformall
skipallnow:
	cmp	al,2
	jnz	skipareanow
	call	playformarea
skipareanow:
	cmp	al,3
	jnz	skipscreennow
	call	playformscreen
skipscreennow:
	cmp	al,4
	jnz	skipoffsetnow
	call	playformoffset
skipoffsetnow:

noooll:
	popad
	ret
CheckAutoPlayForm	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Choose playform
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Checkaplay: 1=All, 2=Area, 3=Screen, 4=Offset
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ChoosePlayform	proc	near
	pushad

	cmp	sampmarkstart,-1		;area
	jz	skiparean
	cmp	byte ptr [autoall+1],1
	jz	skiparean
	mov	playform,2
	call	playformarea
	jmp	afterchoose
skiparean:
	mov	eax,samplength			;screen
	cmp	eax,viewsamplength
	jz	skipscreenen
	cmp	byte ptr [autoall+2],1
	jz	skipscreenen
	mov	playform,3
	call	playformscreen
	jmp	afterchoose
skipscreenen:
	cmp	byte ptr [autoall],1		;all
	jz	afterchoose
	mov	playform,1
	call	playformall
afterchoose:
	popad
	ret
ChoosePlayform	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Change viewinfo
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

_SampLength		 dd	 0	 ;* ;In bytes
_viewsampoffset 	 dd	 0	 ;*
_viewsamplength 	 dd	 0	 ;*
ChangeViewinfo	proc	near
	pushad
	cmp	ViewSampLength,1
	jnz	nospecialview
        mov	eax,SampLength
        dec	eax
        cmp	ViewSampOffset,eax
        jbe	noprobba
        mov	ViewSampOffset,eax
noprobba:
	popad
	ret
nospecialview:


	cmp	_viewsamplength,-1
	jz	setviewlength
	mov	eax,_viewsamplength
	mov	ebx,samplength
	mul	ebx
	mov	ebx,_samplength
	div	ebx
	mov	viewsamplength,eax

	push	eax
	mov	eax,_viewsampoffset
	mov	ebx,samplength
	mul	ebx
	mov	ebx,_samplength
	div	ebx
	mov	viewsampoffset,eax
	pop	eax

	add	eax,_viewsampoffset
	cmp	eax,samplength
	jbe	skipfixoffset
	mov	eax,samplength
	sub	eax,viewsamplength
	;add	 eax,sampmainoffset
	mov	viewsampoffset,eax
skipfixoffset:
	popad
	ret
setviewlength:
	mov	eax,sampmainoffset
	mov	viewsampoffset,0
	mov	eax,samplength
	mov	viewsamplength,eax
	jmp	skipfixoffset
ChangeViewinfo	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Move viewinfo
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MoveViewinfo	proc	near
	pushad
	mov	eax,SampLength
	mov	_SampLength,eax
	mov	eax,viewsampoffset
	;add	 eax,sampmainoffset
	mov	_viewsampoffset,eax
	mov	eax,viewsamplength
	mov	_viewsamplength,eax
	popad
	ret
MoveViewinfo	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			      Mark Repend to end
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MarkRependToEnd proc	near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	markrependendend
	cmp	samplength,0
	jz	markrependendend

	movzx	ebp,currentsample
	shl	ebp,2
	mov	eax,[ebp+loopend]
	sub	eax,[ebp+sampleoffsetstart]
	mov	ebx,samplength
	dec	ebx
	cmp	eax,ebx
	jae	markrependendend
	mov	sampmarkstart,eax
	mov	sampmarkend,ebx
	call	viewsamp
markrependendend:
	popad
	ret
MarkRependToEnd endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Set area more
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
; Esi	    = offset to info
; Picture X = x size (big=64 small=54)
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SetAreaMore	proc	near
	pushad
areasetloop:
	xor	eax,eax
	lodsw
	cmp	ax,-1
	jz	endathis
	mov	SetX1,eax
	lodsw
	mov	SetY1,eax
	lodsw
	mov	SetX2,eax
	lodsw
	mov	SetY2,eax
	lodsw
	mov	SetColor,eax
	call	setarea
	jmp	areasetloop
endathis:
	popad
	ret
SetAreaMore	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Set button more
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Esi = offset to info bytes
; sizex = x size (big=64 small=54)  (1=up 0=down)
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SetButtonMore	proc	near
	pushad
setbuttonloop:
	xor	eax,eax
	lodsw
	cmp	ax,-1
	jz	endabutta
	mov	ButtonX1,eax
	lodsw
	mov	ButtonY1,eax
	lodsw
	mov	ButtonX2,eax
	lodsw
	mov	ButtonY2,eax
	lodsw
	mov	bl,al
	xor	bl,1
	call	buttonupdownmem
	jmp	setbuttonloop
endabutta:
	popad
	ret
SetButtonMore	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Set text more
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Esi = offset to info bytes
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SetTextmore	proc	near
	pushad
Textputtaloop_:
	xor	eax,eax
	lodsw
	mov	maskx,eax
	lodsw
	mov	masky,eax
	add	esi,2
	call	writemasktext
	movzx	eax,word ptr [esi-2]
	add	esi,eax
	cmp	word ptr [esi],-1
	jnz	textputtaloop_
	popad
	ret
SetTextMore	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Volume Start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
VolumeStart2:
	pushad
	jmp	sss14
VolumeStart	proc	near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	volumestartend
sss14:
	call	CheckIfShadow
	jc	_retp
	;call	 unpackmasktext 	 ;view picture
	mov	choosemake,1
	mov	menu_popup,18
	call	menuhandler


volumestartend:
	popad
	ret
VolumeStart	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Volume End
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
VolumeEnd	proc	near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	volumeendend
voljump:

	mov	menu_popup,0
	call	menuhandler

Volumeendend:
	popad
	ret

VolumeEnd2:
	pushad
	jmp	voljump
VolumeEnd	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Volume Calculate
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
vol_s		dd	0
vol_e		dd	0
VolumeCalculate proc	near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	volumecalculateend
volcalcjump:
	cmp	samplength,0
	jz	volumecalculateend
	call	undostart

	cmp	sampbits,1
	jz	sampvol16
						;8 -------------
	mov	ecx,samplength
	mov	edi,sampmainoffset
	cmp	sampmarkstart,-1
	jz	skipmarker
	mov	ecx,sampmarkend
	sub	ecx,sampmarkstart
	;inc	 ecx
	add	edi,sampmarkstart
skipmarker:
	mov	eax,volume_start
	mov	ebx,16777216
	mul	ebx
	mov	ebx,100
	div	ebx
	mov	vol_s,eax
	mov	eax,volume_end
	mov	ebx,16777216
	mul	ebx
	mov	ebx,100
	div	ebx
	mov	vol_e,eax
	sub	eax,vol_s
	cdq
	idiv	ecx
	mov	ebp,eax
	mov	ebx,vol_s

volumemake1:
	mov	dl,byte ptr [edi]
	sub	dl,128
	movsx	eax,dl
	imul	ebx
	mov	esi,16777216
	idiv	esi
	cmp	eax,-128
	jge	fskolan1
	mov	eax,-128
fskolan1:
	cmp	eax,127
	jle	fskolan2
	mov	eax,127
fskolan2:
	sub	al,128
	mov	byte ptr [edi],al
	inc	edi
	add	ebx,ebp
	loop	volumemake1

	mov	menu_popup,0
	call	menuhandler
	call	viewsamp
	call	updatesampletogus
	jmp	volumecalculateend
sampvol16:					;16 ------------
	mov	ecx,samplength
	mov	edi,sampmainoffset
	cmp	sampmarkstart,-1
	jz	skipmarkerWW
	mov	ecx,sampmarkend
	sub	ecx,sampmarkstart
	;inc	 ecx
	mov	eax,sampmarkstart
	shl16	eax
	add	edi,eax
skipmarkerWW:
	mov	eax,volume_start
	mov	ebx,4290000 ;16777216
	mul	ebx
	mov	vol_s,eax
	mov	eax,volume_end
	mov	ebx,4290000 ;16777216
	mul	ebx
	mov	vol_e,eax
	sub	eax,vol_s
	cdq
	idiv	ecx
	mov	ebp,eax
	mov	ebx,vol_s

volumemake1WW:
	mov	dx,word ptr [edi]
	xor	dx,8000h
	movsx	eax,dx
	imul	ebx
;	cdq
	mov	esi,4290000*100 ;6777216
	idiv	esi

	cmp	edx,4290000*50
	jl	NoIncata
	inc	eax
NoIncata:
	cmp	edx,-4290000*50
	jg	NoIncata2
	dec	eax
NoIncata2:

	cmp	eax,-32768
	jge	fskolan1WW
	mov	eax,-32768
fskolan1WW:
	cmp	eax,32767
	jle	fskolan2WW
	mov	eax,32767
fskolan2WW:
	;sar	eax,8
	;sal	eax,8
	xor	ax,8000h
	mov	word ptr [edi],ax
	add	edi,2
	add	ebx,ebp
	loop	volumemake1WW

	mov	menu_popup,0
	call	menuhandler
	call	viewsamp
	call	updatesampletogus

VolumeCalculateend:
	popad
	ret

VolumeCalculate2:
	pushad
	jmp	volcalcjump
VolumeCalculate endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Set volume
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
NewVolSetStart:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	eax,volume_end
	mov	volume_start,eax
	call	UpdateVolume
	popad
	ret

NewVolSetEnd:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	eax,volume_start
	mov	volume_end,eax
	call	UpdateVolume
	popad
	ret




;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Updatevolume
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
UpdateVolume	proc	near
	pushad
	cmp	menu_popup,26
	jnz	endofupdatea
	xor	ebp,ebp
	mov	eax,volume_start
	cmp	eax,oldvolume_start
	jz	skippasupdate1
	mov	ebp,1
	mov	oldvolume_start,eax
	move	edi,0a0000h+168/8+273*80
	mov	ah,01h
	mov	cl,3
	mov	ebx,volume_start
	mov	FontPlane,1
	call	mouseoff
	call	PutDecimal
	call	mouseon
	mov	FontPlane,0
skippasupdate1:
	mov	eax,volume_end
	cmp	eax,oldvolume_end
	jz	skippasupdate2
	mov	ebp,1
	mov	oldvolume_end,eax
	move	edi,0a0000h+168/8+292*80
	mov	ah,01h
	mov	cl,3
	mov	ebx,volume_end
	call	mouseoff
	mov	FontPlane,1
	call	PutDecimal
	mov	FontPlane,0
	call	mouseon
skippasupdate2:
	cmp	ebp,0
	jz	endofupdatea			;update curve

Endofupdatea:
	popad
	ret
UpdateVolume	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Volume arrows
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
VolumeStartUp:
	call	fixbutton
	cmp	volume_start,500
	jz	skopa1
	inc	volume_start
skopa1: ret
VolumeStartDown:
	call	fixbutton
	cmp	volume_start,0
	jz	skopa2
	dec	volume_start
skopa2: ret
VolumeEndUp:
	call	fixbutton
	cmp	volume_end,500
	jz	skopa3
	inc	volume_end
skopa3: ret
VolumeEndDown:
	call	fixbutton
	cmp	volume_end,0
	jz	skopa4
	dec	volume_end
skopa4: ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			    Volume set end to start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
VolumeSetEndToStart	proc	near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	endtostartend
	mov	eax,volume_start
	mov	volume_end,eax
endtostartend:
	popad
	ret
VolumeSetEndToStart	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Start the Mix
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
StartTheMix	proc	near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	mixaenda1
hora:
	call	CheckIfShadow
	jc	_retp
	;call	 unpackmasktext 	 ;view picture
	mov	choosemake,2
	mov	menu_popup,19
	call	menuhandler
	call	updatemixa

mixaenda1:
	popad
	ret

StartTheMix2:
	pushad
	jmp	hora
StartTheMix	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Cancel the Mix
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
CancelTheMix	proc	near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	mixaenda2
jumpcancel:
	mov	menu_popup,0
	call	menuhandler

mixaenda2:
	popad
	ret
Cancelthemix2:
	pushad
	jmp	jumpcancel
CancelTheMix	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Update mixa
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
UpdateMixa	proc	near
	pushad
	call	mouseoff
	mov	FontPlane,1
	move	edi,0a0000h+28+80*274
	mov	ah,01h
	mov	cl,3
	mov	ebx,mixasample
	call	PutDecimal
	move	edi,0a0000h+28+80*298
	mov	ah,01h
	mov	cl,3
	mov	ebx,mixaclip
	call	PutDecimal
	mov	FontPlane,0
	call	mouseon
	popad
	ret
UpdateMixa	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Mixa Udrag
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MixSampleStartUdrag:
	pushad
	mov	UdragStatus,1
	mov	eax,500
	mov	ebx,1024
	mul	ebx
	mov	ebx,100
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,500
	mov	UdragMiniValue,0
	lea	eax,MixaSample
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,UpdateMixa
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
MixSampleEndUdrag:
	pushad
	mov	UdragStatus,1
	mov	eax,500
	mov	ebx,1024
	mul	ebx
	mov	ebx,100
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,500
	mov	UdragMiniValue,0
	lea	eax,MixaClip
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,UpdateMixa
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Input mixa
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
InputMixaSamp:
	pushad
	move	edi,0a0000h+224/8+274*80
	mov	ah,1h
	mov	al,11h
	lea	ebp,MixaSample
	mov	ecx,3
	xor	ebx,ebx
	mov	edx,500
	lea	esi,_ret
	mov	Digitsize,3
	call	ZyricInput
	_rp
InputMixaClip:
	pushad
	move	edi,0a0000h+224/8+298*80
	mov	ah,1h
	mov	al,11h
	lea	ebp,MixaClip
	mov	ecx,3
	xor	ebx,ebx
	mov	edx,500
	lea	esi,_ret
	mov	Digitsize,3
	call	ZyricInput
	_rp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Mixa up and down
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MixSampleUp:
	call	fixbutton
	cmp	mixasample,500
	jz	kjolen1
	inc	mixasample
kjolen1:
	call	updatemixa
	ret
MixSampledown:
	call	fixbutton
	cmp	mixasample,0
	jz	kjolen2
	dec	mixasample
kjolen2:
	call	updatemixa
	ret
MixClipUp:
	call	fixbutton
	cmp	mixaclip,500
	jz	kjolen3
	inc	mixaclip
kjolen3:
	call	updatemixa
	ret
MixClipDown:
	call	fixbutton
	cmp	mixaclip,0
	jz	kjolen4
	dec	mixaclip
kjolen4:
	call	updatemixa
	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Makemixpopup
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MixArea 	dw	118,13,150,25,0
		dw	118,37,150,49,0
		dw	-1
Mixbutton	dw	116,11,152,27,0
		dw	116,35,152,51,0
		dw	260,38,337,54,1
		dw	338,38,417,54,1
		dw	-1
Mixtext 	dw	64/8,14,7
		db	'SAMPLE$'
		dw	40/8,38,10
		db	'CLIPBOARD$'
		dw	288/8,41,4
		db	'MIX$'
		dw	356/8,41,7
		db	'CANCEL$'
		dw	-1
MakeMixpopup	proc	near
	pushad
	mov	pictureX,54
	lea	esi,mixarea
	call	setareamore

	mov	sizex,54
	lea	esi,mixbutton
	call	setbuttonmore

	lea	esi,mixtext
	call	settextmore

	popad
	ret
MakeMixpopup	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Mixa the Mix
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MixaTheMix	proc	near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	mixamixa2

	mov	menu_popup,0
	call	menuhandler

	cmp	clipboardlength,0
	jz	mixamess1
	cmp	samplength,0
	jz	mixamess2

	mov	eax,SampBits
	cmp	eax,ClipBoardBits
	jz	thesamea2
	cmp	al,0
	jz	PasteError1
	jmp	PasteError2
thesamea2:


	mov	eax,clipboardlength
	mov	extrasamplength,eax
	call	allocsamplength

	mov	eax,playpegoff
	add	eax,clipboardlength
	cmp	eax,sampmax
	jbe	skipmessa
	lea	esi,samptext7
	mov	menu_popup,16
	call	popuphandler
skipmessa:
	cmp	sampbits,1
	jz	mixa16bits
					;--------------- Mixa 8bits -------
	call	undostart
	call	moveviewinfo
	mov	eax,playpegoff		;fix if clipboard efter samplength
	add	eax,clipboardlength
	mov	ebx,eax
	sub	eax,samplength
	cmp	eax,0
	jle	skipreppa
	cmp	ebx,sampmax
	jb	nonewlength
	mov	eax,sampmax
	sub	eax,samplength
	inc	eax
nonewlength:
	mov	extrasamplength,eax
	call	allocsamplength
	mov	ecx,eax
	mov	edi,sampmainoffset
	add	edi,samplength
	mov	al,128
	rep	stosb
skipreppa:

	mov	ecx,clipboardlength
	mov	eax,playpegoff
	add	eax,ecx
	cmp	eax,sampmax
	jb	skojare
	mov	ecx,sampmax
	sub	ecx,playpegoff
skojare:
	mov	edi,sampmainoffset
	add	edi,playpegoff
	mov	ebp,undobufferoffset
	add	ebp,playpegoff
	mov	esi,clipboardoffset
mixaloopa:
	mov	bl,byte ptr [edi]
	sub	bl,128
	movsx	eax,bl
	inc	ebp
	mov	ebx,mixasample
	imul	ebx
	push	eax
	mov	bl,byte ptr [esi]
	sub	bl,128
	movsx	eax,bl
	inc	esi
	mov	ebx,mixaclip
	imul	ebx
	pop	ebx
	add	eax,ebx
	mov	ebx,100
	cdq
	idiv	ebx
	cmp	eax,-128
	jge	skolan1
	mov	eax,-128
skolan1:
	cmp	eax,127
	jle	skolan2
	mov	eax,127
skolan2:
	sub	al,128
	stosb
	loop	mixaloopa

	mov	eax,playpegoff
	add	eax,clipboardlength
	cmp	eax,samplength
	jbe	lengthcheck
	mov	samplength,eax
	cmp	eax,sampmax
	jb	lengthcheck
	mov	eax,sampmax
	mov	samplength,eax
lengthcheck:

	call	changeviewinfo
	call	allocsamplength
	call	ViewSamp
	call	updatesampletogus
	mov	oldcurrentinstname,-1
	call	printsampleinfo
	jmp	mixamixa2
mixa16bits:				;--------------- Mixa 16bits ------
	call	undostart
	call	moveviewinfo
	mov	eax,playpegoff		;fix if clipboard efter samplength
	add	eax,clipboardlength
	mov	ebx,eax
	sub	eax,samplength
	cmp	eax,0
	jle	skipreppaWW
	cmp	ebx,sampmax
	jb	nonewlengthWW
	mov	eax,sampmax
	sub	eax,samplength
	inc	eax
nonewlengthWW:
	mov	extrasamplength,eax
	call	allocsamplength
	mov	ecx,eax
	mov	edi,samplength
	shl16	edi
	add	edi,sampmainoffset
	mov	ax,32768
	rep	stosw
skipreppaWW:

	mov	ecx,clipboardlength
	mov	eax,playpegoff
	add	eax,ecx
	cmp	eax,sampmax
	jb	skojareWW
	mov	ecx,sampmax
	sub	ecx,playpegoff
skojareWW:
	mov	edi,playpegoff
	shl16	edi
	add	edi,sampmainoffset
	mov	ebp,playpegoff
	shl16	ebp
	add	ebp,undobufferoffset
	mov	esi,clipboardoffset
mixaloopaWW:
	mov	bx,word ptr [edi]
	sub	bx,32768
	movsx	eax,bx
	inc	ebp
	mov	ebx,mixasample
	imul	ebx
	push	eax
	mov	bx,word ptr [esi]
	sub	bx,32768
	movsx	eax,bx
	add	esi,2
	mov	ebx,mixaclip
	imul	ebx
	pop	ebx
	add	eax,ebx
	mov	ebx,100
	cdq
	idiv	ebx
	cmp	eax,-32768
	jge	skolan1WW
	mov	eax,-32768
skolan1WW:
	cmp	eax,32767
	jle	skolan2WW
	mov	eax,32767
skolan2WW:
	sub	ax,32768
	stosw
	loop	mixaloopaWW

	mov	eax,playpegoff
	add	eax,clipboardlength
	cmp	eax,samplength
	jbe	lengthcheckWW
	mov	samplength,eax
	cmp	eax,sampmax
	jb	lengthcheckWW
	mov	eax,sampmax
	mov	samplength,eax
lengthcheckWW:

	call	changeviewinfo
	call	allocsamplength
	call	ViewSamp
	call	updatesampletogus
	mov	oldcurrentinstname,-1
	call	printsampleinfo

mixamixa2:
	popad
	ret
Mixamess1:				 ;---------- mess ----
	lea	esi,samptext6
	mov	menu_popup,16
	call	popuphandler
	popad
	ret
Mixamess2:
	lea	esi,samptext8
	mov	menu_popup,16
	call	popuphandler
	popad
	ret
MixaTheMix	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Break it
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
BreakIt 	proc	near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	breakitend
breakjump:

	mov	menu_popup,0
	call	menuhandler

	cmp	samplength,0
	jz	mixamess2

	cmp	sampbits,1
	jz	break16bits
					;--------------- Break 8bits -------
	call	undostart
	mov	edi,sampmainoffset	;fix offsets to scan
	mov	ecx,samplength
	cmp	sampmarkstart,-1
	jz	nomarkchange22
	mov	edi,sampmainoffset
	add	edi,sampmarkstart
	mov	ecx,sampmarkend
	sub	ecx,sampmarkstart
	;inc	 ecx
nomarkchange22:
	mov	eax,128
	mov	ebx,breaksmp
	mul	ebx
	mov	ebx,100
	div	ebx
	mov	ebp,eax
	mov	esi,eax
	neg	esi
checkbreakloop:
	mov	bl,[edi]
	sub	bl,128
	movsx	eax,bl
	cmp	eax,ebp
	jle	skipbreaka1
	mov	eax,ebp
skipbreaka1:
	cmp	eax,esi
	jge	skipbreaka2
	mov	eax,esi
skipbreaka2:
	sub	al,128
	stosb
	loop	checkbreakloop

	call	viewsamp
	call	updatesampletogus
	jmp	breakitend

break16bits:				;--------- break 16bits --------
	call	undostart
	mov	edi,sampmainoffset	;fix offsets to scan
	mov	ecx,samplength
	cmp	sampmarkstart,-1
	jz	nomarkchange22WW
	mov	edi,sampmarkstart
	shl16	edi
	add	edi,sampmainoffset
	mov	ecx,sampmarkend
	sub	ecx,sampmarkstart
	;inc	 ecx
nomarkchange22WW:
	mov	eax,32768
	mov	ebx,breaksmp
	mul	ebx
	mov	ebx,100
	div	ebx
	mov	ebp,eax
	mov	esi,eax
	neg	esi
checkbreakloopWW:
	mov	bx,[edi]
	sub	bx,32768
	movsx	eax,bx
	cmp	eax,ebp
	jle	skipbreaka1WW
	mov	eax,ebp
skipbreaka1WW:
	cmp	eax,esi
	jge	skipbreaka2WW
	mov	eax,esi
skipbreaka2WW:
	sub	ax,32768
	stosw
	loop	checkbreakloopWW

	call	viewsamp
	call	updatesampletogus

breakitend:
	popad
	ret
Breakitk:
	pushad
	jmp	breakjump
BreakIt 	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Cancel the Break
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
CancelTheBreak	proc	near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	breakitcancelend
breakjump2:

	mov	menu_popup,0
	call	menuhandler

	call	viewsamp

breakitcancelend:
	popad
	ret
Cancelthebreakk:
	pushad
	jmp	breakjump2
CancelTheBreak	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Break up and down
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
BreakUp:
	pushad
	call	fixbutton
	cmp	breaksmp,100
	jz	skipbreak1
	inc	breaksmp
	call	updatebreak
skipbreak1:
	popad
	ret
BreakDown:
	pushad
	call	fixbutton
	cmp	breaksmp,0
	jz	skipbreak2
	dec	breaksmp
	call	updatebreak
skipbreak2:
	popad
	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Update break
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
UpdateBreak	proc	near
	pushad
	move	edi,0a0000h+264/8+273*80
	mov	ah,01h
	mov	cl,3
	mov	ebx,breaksmp
	mov	fontplane,1
	call	mouseoff
	call	PutDecimal
	call	mouseon
	mov	fontplane,0
	popad
	ret
UpdateBreak	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Updatesampthings
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Updatesampthings	proc	near
	pushad
	cmp	menu_downscreen,5
	jz	sampeff
	mov	eax,samplength
	cmp	eax,Viewsamplength
	jz	_retp

	mov	eax,dword ptr [dragbardata]
	;add	 eax,sampmainoffset
	mov	viewsampoffset,eax
	call	viewsamp
	popad
	ret
sampeff:
	mov	eax,dword ptr [dragbardata+(13*4)]
	;add	 eax,sampmainoffset
	mov	viewsampoffset,eax
	call	viewsamp
	popad
	ret
Updatesampthings	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Move Sampledata
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
OldSamplength		dd	-1
oldviewpos		dd	-1
oldviewsamplength	dd	-1
MoveSampleData	proc	near
	pushad

	mov	eax,samplength
	cmp	eax,oldsamplength
	jz	snutfan1
	mov	oldsamplength,eax
	mov	dword ptr [dragbardata+2*4],eax
	mov	dword ptr [dragbardata+2*4+(13*4)],eax
	mov	dword ptr [dragbardata+4],1
	mov	dword ptr [dragbardata+4+(13*4)],1
snutfan1:
	mov	eax,viewsampoffset
	;sub	 eax,sampmainoffset
	cmp	eax,oldviewpos
	jz	snutfan2
	mov	oldviewpos,eax
	mov	dword ptr [dragbardata],eax
	mov	dword ptr [dragbardata+(13*4)],eax
	mov	dword ptr [dragbardata+4],1
	mov	dword ptr [dragbardata+4+(13*4)],1
snutfan2:
	mov	eax,viewsamplength
	cmp	eax,oldviewsamplength
	jz	snutfan3
	mov	oldviewsamplength,eax
	mov	dword ptr [dragbardata+3*4],eax
	mov	dword ptr [dragbardata+3*4+(13*4)],eax
	mov	dword ptr [dragbardata+4],1
	mov	dword ptr [dragbardata+4+(13*4)],1
snutfan3:
	popad
	ret
MoveSampleData	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Makeyfixpopup
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
YfixArea	dw	14,13,54,25,0
		dw	102,13,142,25,0
		dw	-1

Yfixbutton	dw	13,34,89,50,1
		dw	101,34,177,50,1
		dw	193,34,252,50,1
		dw	266,34,341,50,1
		dw	356,34,418,50,1
		dw	12,11,56,27,0
		dw	100,11,144,27,0
		dw	-1
Yfixtext	dw	24/8,37,8
		db	'MOVE UP$'
		dw	104/8,37,10
		db	'MOVE DOWN$'
		dw	208/8,37,5
		db	'FLIP$'
		dw	280/8,37,7
		db	'CENTER$'
		dw	364/8,37,7
		db	'CANCEL$'
		dw	-1
Makeyfixpopup	 proc	 near
	pushad
	mov	pictureX,54
	lea	esi,yfixarea
	call	setareamore

	mov	sizex,54
	lea	esi,yfixbutton
	call	setbuttonmore

	lea	esi,yfixtext
	call	settextmore

	popad
	ret
Makeyfixpopup	 endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   y-fix start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Y_fixstart2:
	pushad
	jmp	sss15
Y_fixstart	proc   near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	y_fixend__
;aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
sss15:
	call	CheckIfShadow
	jc	_retp
	;call	 unpackmasktext 	 ;view picture
	;mov	 choosemake,4
	mov	menu_popup,21
	call	menuhandler
	call	updateynumbers

y_fixend__:
	popad
	ret
y_fixstart	endp
;-------------------------------------------------- UpdateYnumbers -------
UpdateYnumbers:
	pushad
	call	mouseoff
	mov	ah,1
	mov	cl,5
	move	edi,0a0000h+208/8+285*80
	mov	ebx,ymoveup
	mov	FontPlane,1
	call	PutDecimal
	mov	FontPlane,0
	call	mouseon
	popad
	ret
;------------------------------------------------------ Incynumber up ------------
Incynumberup:
	pushad
	call	fixbutton
	cmp	SampBits,1
	jz	a16a1
	cmp	ymoveup,255
	jz	noooj1
	inc	ymoveup
noooj1:
	popad
	ret
a16a1:
	cmp	ymoveup,65535
	jz	noooj1_
	inc	ymoveup
noooj1_:
	popad
	ret
;------------------------------------------------------ Decynumber up ------------
Decynumberup:
	pushad
	call	fixbutton
	cmp	ymoveup,0
	jz	noooj2
	dec	ymoveup
noooj2:
	popad
	ret
;------------------------------------------------------ Input y up ------------
InputYup:
	cmp	SampBits,1
	jz	Inna16
	mov	edi,208/8+285*80
	mov	ecx,5
	mov	ax,0111h
	mov	ebx,ymoveup
	lea	ebp,ymoveup
	mov	DigitTarget,ebp
	mov	DigitSize,5
	mov	DigitLimit,255
	mov	DigitInput,21
	call	InputDigits
	ret
Inna16:
	mov	edi,208/8+285*80
	mov	ecx,5
	mov	ax,0111h
	mov	ebx,ymoveup
	lea	ebp,ymoveup
	mov	DigitTarget,ebp
	mov	DigitSize,5
	mov	DigitLimit,65535
	mov	DigitInput,21
	call	InputDigits
	ret
;----------------------------------------------------- YfixUdrag -----------
YfixUdrag:
	pushad
	cmp	SampBits,1
	jz	Yfixudrag16_
	mov	UdragStatus,1
	mov	eax,255
	mov	ebx,1024
	mul	ebx
	mov	ebx,100
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,255
	mov	UdragMiniValue,0
	lea	eax,YmoveUp
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	call	ButtonHandler
	_rp
YfixUdrag16_:
	mov	UdragStatus,1
	mov	eax,65535
	mov	ebx,1024
	mul	ebx
	mov	ebx,100
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,65535
	mov	UdragMiniValue,0
	lea	eax,YmoveUp
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	call	ButtonHandler
	_rp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   y-fix end
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
y_fixend	proc   near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	y_fixend_
yjump:

	mov	menu_popup,0
	call	menuhandler

y_fixend_:
	popad
	ret
y_fixend2:
	pushad
	jmp	yjump
y_fixend	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				get ecx edi
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
getecxedi:
	mov	edi,sampmainoffset
	mov	ecx,samplength
	cmp	sampmarkstart,-1
	jz	nomarkchange22_1_2__1XX
	mov	edi,sampmarkstart
	shl16	edi
	add	edi,sampmainoffset
	mov	ecx,sampmarkend
	sub	ecx,sampmarkstart
	;inc	 ecx
nomarkchange22_1_2__1XX:
	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				y-fix procs
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

;-------------------------------------- YfixMoveup --------------------------
YfixMoveup:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	fixaend1

	mov	menu_popup,0
	call	menuhandler

	cmp	samplength,0
	jz	fixaend1

	cmp	sampbits,1
	jz	moveup16bits
					;- move up 8bits ---
	call	undostart
	call	getecxedi
	mov	ebx,ymoveup
movealoopa:
	movzx	ax,byte ptr [edi]
	sub	ax,bx
	cmp	ax,0
	jge	nojagoja1
	xor	ax,ax
nojagoja1:
	stosb
	loop	movealoopa

	call	viewsamp
	call	updatesampletogus
	jmp	fixaend1
					;-- move up 16bits ----
moveup16bits:
	call	undostart
	call	getecxedi
	mov	ebx,ymoveup
movealoopa2:
	movzx	eax,word ptr [edi]
	sub	eax,ebx
	cmp	eax,0
	jge	nojagoja2
	xor	ax,ax
nojagoja2:
	stosw
	loop	movealoopa2

	call	viewsamp
	call	updatesampletogus

fixaend1:
	popad
	ret
;-------------------------------------- Yfix Movedown --------------------------
YfixMoveDown:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	fixaend2
	mov	menu_popup,0
	call	menuhandler
	cmp	samplength,0
	jz	fixaend2
	cmp	sampbits,1
	jz	movedown16bits
					;- move down 8bits ---
	call	undostart
	call	getecxedi
	mov	ebx,ymoveup
movealoopa_2:
	movzx	ax,byte ptr [edi]
	add	ax,bx
	cmp	ax,255
	jbe	nojagoja1_2
	mov	ax,255
nojagoja1_2:
	stosb
	loop	movealoopa_2

	call	viewsamp
	call	updatesampletogus
	jmp	fixaend2
					;-- move down 8bits ----
movedown16bits:
	call	undostart
	call	getecxedi
	mov	ebx,ymoveup
movealoopa2_2:
	movzx	eax,word ptr [edi]
	add	eax,ebx
	cmp	eax,65535
	jbe	nojagoja2_2
	mov	ax,65535
nojagoja2_2:
	stosw
	loop	movealoopa2_2

	call	viewsamp
	call	updatesampletogus
fixaend2:
	popad
	ret

;-------------------------------------- Yfix flip --------------------------
Yfixflip2:
	pushad
	jmp	sss19
YfixFlip:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	fixaend3
sss19:
	mov	menu_popup,0
	call	menuhandler
	cmp	samplength,0
	jz	fixaend3
	cmp	sampbits,1
	jz	flip16bits
					;- move down 8bits ---
	call	undostart
	call	getecxedi

fliploopa:
	mov	bl,[edi]
	mov	al,255
	sub	al,bl
	stosb
	loop	fliploopa
	call	viewsamp
	call	updatesampletogus
	jmp	fixaend3

flip16bits:				;- flip 16bits ---
	call	undostart
	call	getecxedi
fliploopa2:
	mov	bx,[edi]
	mov	ax,65535
	sub	ax,bx
	stosw
	loop	fliploopa2
	call	viewsamp
	call	updatesampletogus
fixaend3:
	popad
	ret

;-------------------------------------- Yfix center --------------------------
yfixeffect	db	0
centercount	dd	0
Yfixcenter2:
	pushad
	jmp	sss20
Yfixcenter:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	fixaend4
sss20:

	mov	menu_popup,0
	call	menuhandler
	cmp	samplength,0
	jz	fixaend4
skippatriss:
	call	undostart


	call	getecxedi
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

	call	viewsamp
	call	updatesampletogus
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

	call	viewsamp
	call	updatesampletogus
fixaend4:
	popad
	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 input volumes
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Inputstartvolume:
	mov	edi,40*80+336/8
	mov	ecx,3
	mov	ax,0101h
	mov	ebx,volume_start
	lea	ebp,volume_start
	mov	DigitTarget,ebp
	mov	DigitSize,3
	mov	DigitLimit,600
	mov	DigitInput,23
	call	InputDigits
	ret
Inputendvolume:
	mov	edi,61*80+336/8
	mov	ecx,3
	mov	ax,0101h
	mov	ebx,volume_end
	lea	ebp,volume_end
	mov	DigitTarget,ebp
	mov	DigitSize,3
	mov	DigitLimit,600
	mov	DigitInput,24
	call	InputDigits
	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Zoom plus and minus
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ZoomPlus2:
	pushad
	jmp	sss6
ZoomPlus: ;-------------------------------------- Zoom plus --------
	pushad
	call	fixbutton
sss6:
	cmp	samplength,0
	jz	zoomplusend

	mov	eax,viewsamplength
	mov	undoviewlength,eax
	mov	eax,viewsampoffset
	mov	undoviewoff,eax

	cmp	viewsamplength,1
	jz	zoomplusend
	mov	eax,viewsamplength
	mov	ebp,eax
	mov	ebx,9
	mul	ebx
	mov	ebx,10
	div	ebx
	cmp	eax,1
	jge	nonollas
	mov	eax,1
nonollas:
	mov	viewsamplength,eax
	sub	ebp,eax
	shr	ebp,1
	cmp	ebp,0
	jnz	nonollas2
	mov	ebp,1
nonollas2:
	mov	eax,viewsampoffset
	add	eax,ebp
	mov	viewsampoffset,eax

	cmp	zoombufferoffset,8*150		 ;zoom buffers
	jz	skipsavebuffer1
	mov	ebx,zoombufferoffset
	mov	eax,viewsampoffset
	mov	[ebx+zoombuffer],eax
	add	eax,viewsamplength
	add	ebx,4
	mov	[ebx+zoombuffer],eax
	add	zoombufferoffset,8
skipsavebuffer1:

	call	viewsamp
zoomplusend:
	popad
	ret
ZoomMinus2:
	pushad
	jmp	sss7
ZoomMinus: ;-------------------------------------- Zoom minus --------
	pushad
	call	fixbutton
sss7:
	cmp	samplength,0
	jz	zoomminusend
	mov	eax,viewsamplength
	mov	undoviewlength,eax
	mov	eax,viewsampoffset
	mov	undoviewoff,eax

	mov	eax,samplength
	cmp	eax,viewsamplength
	jz	zoomminusend

	mov	eax,viewsamplength
	mov	ebp,eax
	mov	ebx,10
	mul	ebx
	mov	ebx,9
	div	ebx

	cmp	eax,10
	ja	ojojsa
	inc	eax
ojojsa:
	cmp	eax,samplength
	jbe	neja3
	mov	eax,samplength
neja3:
	mov	viewsamplength,eax
	sub	eax,ebp
	shr	eax,1
	mov	ebx,viewsampoffset
	sub	ebx,eax
	cmp	ebx,0
	jge	neja4
	xor	ebx,ebx
neja4:
	mov	ebp,viewsamplength
	add	ebp,ebx
	cmp	ebp,samplength
	jbe	neja5
	sub	ebp,samplength
	sub	ebx,ebp
neja5:
	;add	 ebx,sampmainoffset
	mov	viewsampoffset,ebx

	cmp	zoombufferoffset,8*150		 ;zoom buffers
	jz	skipsavebuffer2
	mov	ebx,zoombufferoffset
	mov	eax,viewsampoffset
	mov	[ebx+zoombuffer],eax
	add	eax,viewsamplength
	add	ebx,4
	mov	[ebx+zoombuffer],eax
	add	zoombufferoffset,8
skipsavebuffer2:

	call	viewsamp
zoomminusend:
	popad
	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Move volume
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
skojaren	db	0
MoveVolume	proc	near
	pushad
	cmp	mouseB,0
	jnz	kukka
	mov	skojaren,0
kukka:
	cmp	menu_popup,18
	jnz	quitmovevolume2
	cmp	skojaren,1
	jz	movestart
	cmp	skojaren,2
	jz	moveend
	cmp	mouseB,0
	jz	quitmovevolume
	cmp	mouseY,39
	jb	quitmovevolume
	cmp	mouseY,189
	ja	quitmovevolume
	cmp	mouseX,72-16
	jb	quitmovevolume
	cmp	mouseX,271+16
	ja	quitmovevolume
	cmp	mouseX,271-16
	jae	moveend
	cmp	mouseX,72+16
	jbe	movestart
	jmp	quitmovevolume
Movestart:
	mov	skojaren,1
	movzx	eax,mouseY
	sub	eax,39
	shl	eax,2
	mov	ebx,600
	sub	ebx,eax
	cmp	ebx,600
	jle	fjong1
	mov	ebx,600
fjong1:
	cmp	ebx,0
	jge	fjong2
	mov	ebx,0
fjong2:
	mov	volume_start,ebx
	mov	oldvolume_start,-1
	jmp	quitmovevolume
moveEnd:
	mov	skojaren,2
	movzx	eax,mouseY
	sub	eax,39
	shl	eax,2
	mov	ebx,600
	sub	ebx,eax
	cmp	ebx,600
	jle	fjong3
	mov	ebx,600
fjong3:
	cmp	ebx,0
	jge	fjong4
	mov	ebx,0
fjong4:
	mov	volume_end,ebx
	mov	oldvolume_end,-1
quitmovevolume:
	call	puttadottaand

quitmovevolume2:
	popad
	ret
PuttadottaAND:	 ;--------------- putta dotta AND -----------------
	pushad
	mov	eax,volume_start
	cmp	eax,oldvolume_start2
	jnz	keepon__
	mov	eax,volume_end
	cmp	eax,oldvolume_end2
	jnz	keepon__
	jmp	endastenda

keepon__:
						;set line
	pushad
	mov	onscreenx1,76
	mov	eax,600
	sub	eax,volume_start
	shr	eax,2
	add	eax,41
	mov	onscreeny1,eax
	mov	onscreenx2,267
	mov	eax,600
	sub	eax,volume_end
	shr	eax,2
	add	eax,41
	mov	onscreeny2,eax
	lea	esi,gardellen
	mov	linescreensize,80
	mov	linescreenpos,0
	mov	clearservice,1
	mov	clipx1,76
	mov	clipx2,300
	call	mouseoff
	call	updateline
	call	mouseon
	popad

	call	mouseoff
	move	edi,0a0000h+39*80+72/8		;remove start
	mov	eax,600
	sub	eax,oldvolume_start2
	shr	eax,2
	mov	ebx,80
	mul	ebx
	add	edi,eax

	mov	bx,0100h
	call	setbittars
	call	andanow1
	mov	bx,0201h
	call	setbittars
	call	andanow1
	mov	bx,0803h
	call	setbittars
	call	andanow1

	move	edi,0a0000h+39*80+72/8		;put start
	mov	eax,600
	sub	eax,volume_start
	shr	eax,2
	mov	ebx,80
	mul	ebx
	add	edi,eax

	mov	bx,0100h
	call	setbittars
	call	oranow1
	mov	bx,0201h
	call	setbittars
	call	oranow1
	mov	bx,0803h
	call	setbittars
	call	oranow1

	move	edi,0a0000h+39*80+264/8 	 ;remove end
	mov	eax,600
	sub	eax,oldvolume_end2
	shr	eax,2
	mov	ebx,80
	mul	ebx
	add	edi,eax

	mov	bx,0100h
	call	setbittars
	call	andanow2
	mov	bx,0201h
	call	setbittars
	call	andanow2
	mov	bx,0803h
	call	setbittars
	call	andanow2

	move	edi,0a0000h+39*80+264/8 	 ;put end
	mov	eax,600
	sub	eax,volume_end
	shr	eax,2
	mov	ebx,80
	mul	ebx
	add	edi,eax

	mov	bx,0100h
	call	setbittars
	call	oranow2
	mov	bx,0201h
	call	setbittars
	call	oranow2
	mov	bx,0803h
	call	setbittars
	call	oranow2
	call	mouseon

	mov	eax,volume_start
	mov	oldvolume_start2,eax
	mov	eax,volume_end
	mov	oldvolume_end2,eax
endastenda:
	popad
	ret
andanow1:
	and	byte ptr [edi],00001111b
	and	byte ptr [edi+80],00001111b
	and	byte ptr [edi+80*2],00001111b
	and	byte ptr [edi+80*3],00001111b
	ret
oranow1:
	or	byte ptr [edi],11110000b
	or	byte ptr [edi+80],11110000b
	or	byte ptr [edi+80*2],11110000b
	or	byte ptr [edi+80*3],11110000b
	ret
andanow2:
	and	byte ptr [edi],11100001b
	and	byte ptr [edi+80],11100001b
	and	byte ptr [edi+80*2],11100001b
	and	byte ptr [edi+80*3],11100001b
	ret
oranow2:
	or	byte ptr [edi],00011110b
	or	byte ptr [edi+80],00011110b
	or	byte ptr [edi+80*2],00011110b
	or	byte ptr [edi+80*3],00011110b
	ret

setbittars:	   ;bh=write bl=read
	push	dx
	push	ax
	mov	ah,bh			;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh 		;Set bitplane (read)
	mov	ah,bl
	mov	al,4
	out	dx,ax
	pop	ax
	pop	dx
	ret
MoveVolume	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Update Line
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;	  ClipX1 = Start x clip
;	  ClipX2 = End x clip
;	     Esi = Offset to olddotsbuffer [size(bytes) = 5*(ClipX2-ClipX1+1)]
;     OnScreenX1 = X1	(X1 has too be to the left of X2)
;     OnScreenY1 = Y1
;     OnScreenX2 = X2
;     OnScreenY2 = Y2
; LineScreenSize = Screen size (Fullscreen = 80)
;  LineScreenPos = Offset to put (0 = Screen)
;   ClearService = 0=no clear 1=clear
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ClipX1		dd	0
ClipX2		dd	0
OnScreenX1	dd	0
OnScreenY1	dd	0
OnScreenX2	dd	0
OnScreenY2	dd	0

decimaladder	dd	0
ottocount	db	0
oldebppos	dd	0
oldebpsize	dd	0
linescreensize	dd	0
linescreenpos	dd	0
clearservice	db	0
Fixdownup	db	0
UpdateLine	proc	near
	pushad
	mov	eax,onscreenx1
	cmp	eax,onscreenx2
	je	lineloda
	jl	flopsa
	xchg	eax,onscreenx2
	mov	onscreenx1,eax
	mov	eax,onscreeny1
	xchg	eax,onscreeny2
	mov	onscreeny1,eax
flopsa:

	mov	eax,clipx1
	cmp	onscreenx2,eax
	jb	endoftheline
	mov	eax,clipx2
	cmp	onscreenx1,eax
	ja	endoftheline

	mov	ah,00000001b		;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh 		;Set bitplane (read)
	mov	ah,0
	mov	al,4
	out	dx,ax

	mov	fixdownup,0
	mov	eax,onscreenY2
	cmp	onscreenY1,eax
	jle	ojojjo
	mov	fixdownup,1
ojojjo:
					;-- line up and down --
	cmp	fixdownup,0
	jz	kula1
	mov	eax,onscreenY1
	sub	eax,onscreenY2
	jmp	afterkula1
kula1:
	sub	eax,onscreenY1
afterkula1:
	inc	eax
	mov	ebx,65537
	mul	ebx
	mov	ebx,onscreenX2
	sub	ebx,onscreenx1
	inc	ebx
	xor	edx,edx
	div	ebx
	mov	decimaladder,eax

	mov	edi,linescreenpos
	cmp	edi,0
	jnz	no0a0000h
	move	edi,0a0000h
no0a0000h:
	mov	eax,onscreeny1
	mov	ebx,linescreensize
	mul	ebx
	add	edi,eax
	mov	eax,onscreenx1
	mov	ebx,8
	cdq
	idiv	ebx
	add	edi,eax
	mov	ottocount,8
	sub	ottocount,dl
	mov	bl,010000000b
	mov	ecx,edx
	ror	bl,cl
	mov	bh,bl
	xor	bh,0ffh

	mov	eax,onscreenx1
	sub	eax,clipx1
	mov	ecx,5
	imul	ecx
	add	esi,eax

	mov	ecx,onscreenx2
	cmp	ecx,clipx2
	jbe	noslurkas
	mov	ecx,clipx2
noslurkas:
	sub	ecx,onscreenx1
	inc	ecx

	xor	ebp,ebp
	mov	oldebppos,0
	mov	oldebpsize,0
linedrawloopen1:		      ;-------------------------------------
	push	ecx
	add	ebp,decimaladder

	cmp	clearservice,0
	jz	skipputblacka
	mov	eax,clipx1
	cmp	onscreenx1,eax
	jl	skipputblacka

	mov	edx,[esi]
	cmp	edx,0
	jz	skipputblacka
	movzx	ecx,byte ptr [esi+4]
andasloop:
	and	byte ptr [edx],bh
	add	edx,linescreensize
	loop	andasloop
afterkula5:
skipputblacka:

	mov	eax,ebp
	shr	eax,16
	mov	ecx,eax
	sub	ecx,oldebpsize
	cmp	ecx,0
	jnz	hejas
	inc	ecx
hejas:
	mov	oldebpsize,eax

	mov	edx,eax
	shl	eax,6
	shl	edx,4
	add	eax,edx
	mov	edx,oldebppos
	mov	oldebppos,eax

	mov	eax,clipx1
	cmp	onscreenx1,eax
	jl	noputkossa

	cmp	clearservice,0
	jz	mojas
	mov	[esi],edi
	cmp	fixdownup,0
	jz	kula2
	sub	[esi],edx
	pushad
	mov	eax,linescreensize
	dec	ecx
	mul	ecx
	sub	[esi],eax
	popad
	jmp	afterkula2
kula2:
	add	[esi],edx
afterkula2:
	mov	byte ptr [esi+4],cl

mojas:
	cmp	fixdownup,0
	jz	kula3
	push	edi
	sub	edi,edx
	xor	edx,edx
orasloop2:
	or	[edi+edx],bl
	sub	edx,linescreensize
	loop	orasloop2
	pop	edi
	jmp	afterkula3
kula3:
orasloop:
	or	[edi+edx],bl
	add	edx,linescreensize
	loop	orasloop
afterkula3:

noputkossa:

	dec	ottocount
	jnz	nonewaddas
	inc	edi
	mov	ottocount,8
nonewaddas:
	ror	bh,1
	ror	bl,1
	add	esi,5
	inc	onscreenx1
	pop	ecx
	loop	linedrawloopen1

	popad
	ret
endoftheline:
	popad
	ret
Lineloda:		; --- line loda ----
	mov	eax,clipx1
	cmp	onscreenx2,eax
	jb	endoftheline
	mov	eax,clipx2
	cmp	onscreenx1,eax
	ja	endoftheline

	mov	ah,00000001b		;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh 		;Set bitplane (read)
	mov	ah,0
	mov	al,4
	out	dx,ax

	mov	edi,linescreenpos
	cmp	edi,0
	jnz	no0a0000h__2
	move	edi,0a0000h
no0a0000h__2:
	mov	eax,onscreeny1
	mov	ebx,linescreensize
	mul	ebx
	add	edi,eax
	mov	eax,onscreenx1
	mov	ebx,8
	cdq
	idiv	ebx
	add	edi,eax
	mov	bl,010000000b
	mov	ecx,edx
	ror	bl,cl
	mov	bh,bl
	xor	bh,0ffh

	mov	eax,onscreenx1
	sub	eax,clipx1
	mov	ecx,5
	imul	ecx
	add	esi,eax

	cmp	clearservice,0
	jz	nocleara
	mov	eax,[esi]
	movzx	ecx,byte ptr [esi+4]
andaloopas:
	and	byte ptr [eax],bh
	add	eax,linescreensize
	loop	andaloopas
nocleara:
	mov	ecx,onscreeny2
	sub	ecx,onscreeny1
	cmp	ecx,0
	jnl	nolessas
	neg	ecx
nolessas:
	inc	ecx
	mov	[esi],edi
	mov	[esi+4],cl
oraloopas:
	or	byte ptr [edi],bl
	add	edi,linescreensize
	loop	oraloopas

	popad
	ret
UpdateLine	endp
;-------------------------------------------- pluring -------------
pluring:
       mov     ah,0fh
       mov     cl,8
       move    edi,0a0000h+80*12*0
       mov     ebx,sampmarkstart
       call    PutDecimal

       mov     ah,0fh
       mov     cl,8
       move    edi,0a0000h+80*12*1
       mov     ebx,sampmarkend
       call    PutDecimal

       mov     ah,0fh
       mov     cl,8
       move    edi,0a0000h+80*12*2
       mov     ebx,viewsampoffset
       call    PutDecimal

       mov     ah,0fh
       mov     cl,8
       move    edi,0a0000h+80*12*3
       mov     ebx,viewsampoffsetold
       call    PutDecimal

       mov     ah,0fh
       mov     cl,8
       move    edi,0a0000h+80*12*4
       mov     ebx,viewsamplength
       call    PutDecimal

       mov     ah,0fh
       mov     cl,8
       move    edi,0a0000h+80*12*5
       mov     ebx,samplength
       call    PutDecimal

       mov     ah,0fh
       mov     cl,8
       move    edi,0a0000h+80*12*6
       mov     ebx,clipboardlength
       call    PutDecimal

       mov     ah,0fh
       mov     cl,8
       move    edi,0a0000h+80*12*7
       mov     ebx,sampbits
       call    PutDecimal

       mov     ah,0fh
       mov     cl,8
       move    edi,0a0000h+80*12*8
       movzx   ebx,playform
       call    PutDecimal

       mov     ah,0fh
       mov     cl,8
       move    edi,0a0000h+80*12*9
       movzx   ebx,playloop
       call    PutDecimal

       mov     ah,0fh
       mov     cl,8
       move    edi,0a0000h+80*12*10
       mov     ebx,playpegoff
       call    PutDecimal
       ret
;-------------------------------------------- kluring -------------
kluring:
       mov     ah,0fh
       mov     cl,11
       move    edi,0a0000h+80*12*0
       mov     ebx,[alloctable+1024*8]
       call    PutDecimal

       mov     ah,0fh
       mov     cl,11
       move    edi,0a0000h+80*12*1
       mov     ebx,[alloctable+1025*8]
       call    PutDecimal

       mov     ah,0fh
       mov     cl,11
       move    edi,0a0000h+80*12*0+15
       mov     ebx,[alloctable+1024*8+4]
       call    PutDecimal

       mov     ah,0fh
       mov     cl,11
       move    edi,0a0000h+80*12*1+15
       mov     ebx,[alloctable+1025*8+4]
       call    PutDecimal
       ret


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Allocate
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ExtraSampLength 	dd	0
ExtraUndoLength 	dd	0
ExtraClipLength 	dd	0

Allocsamplength:
	pushad
	;cmp	 samplength,0
	;jz	 noallocas1
	mov	eax,samplength
	add	eax,extrasamplength
	shl16	eax
	mov	ebp,1024
	xor	ebx,ebx

	call	memalloc
	jc	DeallocSamp

	mov	eax,[AllocTable+1024*8]
	mov	sampmainoffset,eax
	mov	eax,[AllocTable+1025*8]
	mov	undobufferoffset,eax
	mov	eax,[AllocTable+1026*8]
	mov	clipboardoffset,eax
	mov	extrasamplength,0
noallocas1:
	popad
	ret

Allocundolength:
	pushad
	;cmp	undosamplength,0
	;jle	noallocas3
	mov	eax,undosamplength
	add	eax,extraundolength
	shl16	eax
	mov	ebp,1025
	xor	ebx,ebx
	call	memalloc
	jc	DeallocSamp
	mov	eax,[AllocTable+1024*8]
	mov	sampmainoffset,eax
	mov	eax,[AllocTable+1025*8]
	mov	undobufferoffset,eax
	mov	eax,[AllocTable+1026*8]
	mov	clipboardoffset,eax
	mov	extraundolength,0
noallocas3:
	popad
	ret
AllocClipLength:
	pushad
	;cmp	 clipboardlength,0
	;jz	 noallocas2
	mov	eax,clipboardlength
	add	eax,extracliplength
	shl16	eax
	mov	ebp,1026
	xor	ebx,ebx
	call	memalloc
	jc	DeallocSamp
	mov	eax,[AllocTable+1024*8]
	mov	sampmainoffset,eax
	mov	eax,[AllocTable+1025*8]
	mov	undobufferoffset,eax
	mov	eax,[AllocTable+1026*8]
	mov	clipboardoffset,eax
	mov	extracliplength,0
noallocas2:
	popad
	ret



DeallocSamp:

	xor	eax,eax
	xor	ebx,ebx
	mov	ebp,1051	;sampbuff extra
	call	memalloc
	xor	eax,eax
	xor	ebx,ebx
	mov	ebp,1049
	call	memalloc	;delay buffers
	jmp	notenoughhimem



;	  ClipX1 = Start x clip
;	  ClipX2 = End x clip
;	     Esi = Offset to olddotsbuffer [size(bytes) = 5*(ClipX2-ClipX1+1)]
;     OnScreenX1 = X1	(X1 has too be to the left of X2)
;     OnScreenY1 = Y1
;     OnScreenX2 = X2
;     OnScreenY2 = Y2
; LineScreenSize = Screen size (Fullscreen = 80)
;  LineScreenPos = Offset to put (0 = Screen)
;   ClearService = 0=no clear 1=clear
Uppas	proc	near
	ret
	pushad
	lea	edi,updatebuffa
	mov	ecx,32*100
	xor	eax,eax
	rep	stosb

	mov	clipx1,0
	mov	clipx2,256
	mov	onscreenx1,128
	mov	onscreeny1,10
	mov	onscreeny2,90
	movzx	eax,mouseX
	mov	onscreenx2,eax
	mov	linescreensize,32
	lea	edi,updatebuffa
	mov	linescreenpos,edi
	mov	clearservice,0
	call	updateline

	call	mouseoff
	mov	ah,00001111b		;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax

	move	edi,0a0000h
	lea	esi,updatebuffa
	mov	ecx,100
rapsloop:
	push	ecx
	mov	ecx,32
	rep	movsb
	add	edi,80-32
	pop	ecx
	loop	rapsloop

	call	mouseon
	popad
	ret
Uppas	endp

MaketestSamp:
	pushad
	mov	samplength,5
	mov	viewsamplength,5
	mov	eax,clipboardlength
	mov	extrasamplength,eax
	call	allocsamplength
	mov	edi,sampmainoffset
	lea	esi,teststring
	mov	ecx,5
	rep	movsb
	call	viewall2
	popad
	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Samppos and value
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampPosUp:			;----------- Samp Pos Up
	pushad
	call	fixbutton
	cmp	samplength,0
	jz	EndSampPosUp
	mov	eax,samplength
	dec	eax
	cmp	eax,PlayPegOff
	jz	EndSampPosUp
	inc	PlayPegOff
	call	movethepegs
EndSampPosUp:
	popad
	ret
SampPosDown:			;----------- Samp Pos Down
	pushad
	call	fixbutton
	cmp	samplength,0
	jz	EndSampPosDown
	cmp	PlayPegOff,0
	jz	EndSampPosDown
	dec	PlayPegOff
	call	movethepegs
EndSampPosDown:
	popad
	ret
ValueUp:			;----------- Value Up
	pushad
	call	fixbutton
	call	CheckIfShadow2
	jc	_retp
	cmp	samplength,0
	jz	EndValueUp
	mov	eax,playpegoff
	shl16	eax
	add	eax,sampmainoffset
	cmp	sampbits,1
	jz	Valle16
	cmp	byte ptr [eax],255
	jz	EndValueUp
	inc	byte ptr [eax]
	call	viewsamp
	jmp	EndValueUp
Valle16:
	cmp	word ptr [eax],65535
	jz	EndValueUp
	inc	word ptr [eax]
	call	viewsamp
	call	updatesampletogus
EndValueUp:
	popad
	ret

ValueDown:			;----------- Value Down
	pushad
	call	fixbutton
	call	CheckIfShadow2
	jc	_retp
	cmp	samplength,0
	jz	EndValueDown
	mov	eax,playpegoff
	shl16	eax
	add	eax,sampmainoffset
	cmp	sampbits,1
	jz	Valle16_2
	cmp	byte ptr [eax],0
	jz	EndValueUp
	dec	byte ptr [eax]
	call	viewsamp
	jmp	EndValueDown
Valle16_2:
	cmp	word ptr [eax],0
	jz	EndValueDown
	dec	word ptr [eax]
	call	viewsamp
	call	updatesampletogus
EndValueDown:
	popad
	ret
Classic:		;********************** CLASSIC ********
	pushad

	popad
	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Change mark
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ChangeMark	Proc	Near
	pushad



ChangePositiv:
	popad
	stc
	ret
ChangeNegativ:
	popad
	clc
	ret
ChangeMark	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Sample Repeat
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FormSelect	db	0
OldForm 	db	0
SetNOREP:
	cmp	FormSelect,0
	jz	_ret
	mov	FormSelect,0

	call	SetTheForm
	call	MoveThePegs
	call	GoOnForm
	ret
SetFWDREP:
	cmp	FormSelect,1
	jz	_ret
	mov	ClearFlag,0
	mov	dword ptr [oldputs+6*4],-1
	mov	dword ptr [oldputs+7*4],-1
	mov	al,FormSelect
	mov	OldForm,al
	mov	FormSelect,1
	call	SetTheForm
	call	NoREPret
	call	GoOnForm
	ret
SetBWDREP:
	cmp	FormSelect,2
	jz	_ret
	mov	ClearFlag,0
	mov	dword ptr [oldputs+6*4],-1
	mov	dword ptr [oldputs+7*4],-1
	mov	al,FormSelect
	mov	OldForm,al
	mov	FormSelect,2
	call	SetTheForm
	call	NoREPret
	call	GoOnForm
	ret
SetBIDIfREP:
	cmp	FormSelect,3
	jz	_ret
	mov	ClearFlag,0
	mov	dword ptr [oldputs+6*4],-1
	mov	dword ptr [oldputs+7*4],-1
	mov	al,FormSelect
	mov	OldForm,al
	mov	FormSelect,3
	call	SetTheForm
	call	NoREPret
	call	GoOnForm
	ret
SetBIDIbREP:
	cmp	FormSelect,4
	jz	_ret
	mov	ClearFlag,0
	mov	dword ptr [oldputs+6*4],-1
	mov	dword ptr [oldputs+7*4],-1
	mov	al,FormSelect
	mov	OldForm,al
	mov	FormSelect,4
	call	SetTheForm
	call	NoREPret
	call	GoOnForm
	ret


NoREPret:
	cmp	OldForm,0
	jnz	_ret
	pushad
	mov	oldpegpos,-1
	mov	oldrepstartpos,-1
	mov	oldrependpos,-1
	call	movethepegs
	popad
	ret

;						  ;u=unused,d=direction,b=bidi
;						  ;l=loop,6=16bit,p=pack
GetTheForm: ;-----------------------------------
	pushad
	mov	saverepstart,0
	mov	saverepend,0
	movzx	ebp,currentsample
	mov	al,byte ptr [VoiceControl+ebp]
	bt	ax,3
	jc	YesLoop
	mov	FormSelect,0
	jmp	_retp
YesLoop:
	bt	ax,4
	jnc	NoBIDI
	mov	FormSelect,3
	bt	ax,6
	jnc	_retp
	mov	FormSelect,4
	jmp	_retp
noBIDI:
	bt	ax,6
	jc	NoForward
	mov	FormSelect,1
	jmp	_retp
NoForward:
	mov	FormSelect,2
	jmp	_retp

SetTheForm: ;-----------------------------------
	pushad
	movzx	cx,FormSelect
	movzx	ebp,currentsample
	cmp	cx,0
	jnz	Nono0
	mov	al,byte ptr [VoiceControl+ebp]
	btr	ax,3
	btr	ax,4
	btr	ax,6
	mov	byte ptr [VoiceControl+ebp],al
	jmp	_retp
Nono0:
	cmp	cx,1
	jnz	Nono1
	mov	al,byte ptr [VoiceControl+ebp]
	bts	ax,3
	btr	ax,4
	btr	ax,6
	mov	byte ptr [VoiceControl+ebp],al
	jmp	_retp
Nono1:
	cmp	cx,2
	jnz	Nono2
	mov	al,byte ptr [VoiceControl+ebp]
	bts	ax,3
	btr	ax,4
	bts	ax,6
	mov	byte ptr [VoiceControl+ebp],al
	jmp	_retp
Nono2:
	cmp	cx,3
	jnz	Nono3
	mov	al,byte ptr [VoiceControl+ebp]
	bts	ax,3
	bts	ax,4
	btr	ax,6
	mov	byte ptr [VoiceControl+ebp],al
	jmp	_retp
Nono3:
	cmp	cx,4
	jnz	_retp
	mov	al,byte ptr [VoiceControl+ebp]
	bts	ax,3
	bts	ax,4
	bts	ax,6
	mov	byte ptr [VoiceControl+ebp],al
	jmp	_retp


SaveRepstart	dd	0
SaveRepend	dd	0
viewsampen	db	0
GoOnForm: ;------------------------------------
	pushad
	cmp	menu_downscreen,4
	jnz	_retp
	movzx	cx,FormSelect

	mov	bl,1		;Form 0
	cmp	cx,0
	jnz	Form0
	xor	bl,1
				;obs! keine sample
				;obs end
Form0:
	call	mouseoff
	mov	ButtonX1,299-4
	mov	ButtonY1,385-5
	mov	ButtonX2,305-4
	mov	ButtonY2,391-5
	call	ButtonUpDown

	mov	bl,1		;Form 1
	cmp	cx,1
	jnz	Form1
	xor	bl,1
Form1:
	mov	ButtonX1,299-4
	mov	ButtonY1,396-5
	mov	ButtonX2,305-4
	mov	ButtonY2,402-5
	call	ButtonUpDown

	mov	bl,1		;Form 2
	cmp	cx,2
	jnz	Form2
	xor	bl,1
Form2:
	mov	ButtonX1,299-4
	mov	ButtonY1,407-5
	mov	ButtonX2,305-4
	mov	ButtonY2,413-5
	call	ButtonUpDown

	mov	bl,1		;Form 3
	cmp	cx,3
	jnz	Form3
	xor	bl,1
Form3:
	mov	ButtonX1,299-4
	mov	ButtonY1,418-5
	mov	ButtonX2,305-4
	mov	ButtonY2,424-5
	call	ButtonUpDown
	call	mouseon

	mov	bl,1		;Form 4
	cmp	cx,4
	jnz	Form4
	xor	bl,1
Form4:
	mov	ButtonX1,295
	mov	ButtonY1,424
	mov	ButtonX2,301
	mov	ButtonY2,430
	call	ButtonUpDown
	call	mouseon
	popad
	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  NEW VOLUME
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
NewVolumeStart: 			;New Volume Start --------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp

	call	CheckIfShadow
	jc	_retp

	mov	menu_popup,26
	call	menuhandler
	mov	fontplane,1
	move	edi,0a0000h+192/8+273*80
	mov	ebx,'%'
	mov	ah,00000001b
	call	PutCharacter
	move	edi,0a0000h+192/8+292*80
	mov	ebx,'%'
	mov	ah,00000001b
	call	PutCharacter
	move	edi,0a0000h+288/8+273*80
	mov	ebx,'%'
	mov	ah,00000001b
	call	PutCharacter
	mov	fontplane,0
	mov	oldvolume_start,-1
	mov	oldvolume_end,-1
	mov	oldvolume_start2,-1
	mov	oldvolume_end2,-1

	call	updatebreak
	jmp	_retp
NewVolumeEnd2:
	pushad
	jmp	SkipVolumeMouse
NewVolumeEnd:				;New Volume End ----------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
SkipVolumeMouse:
	mov	menu_popup,0
	call	menuhandler
	jmp	_retp
VolumePopStartUdrag:			;Volume Pop Start Udrag --------
	pushad
	mov	UdragStatus,1
	mov	eax,500
	mov	ebx,1024
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,500
	mov	UdragMiniValue,0
	lea	eax,Volume_start
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	call	ButtonHandler
	_rp
VolumePopEndUdrag:			;Volume Pop End Udrag --------
	pushad
	mov	UdragStatus,1
	mov	eax,500
	mov	ebx,1024
	mul	ebx
	mov	ebx,90
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,500
	mov	UdragMiniValue,0
	lea	eax,Volume_end
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	call	ButtonHandler
	_rp
VolumePopBreakUdrag:			;Volume Pop Break Udrag --------
	pushad
	mov	UdragStatus,1
	mov	eax,100
	mov	ebx,1024
	mul	ebx
	mov	ebx,80
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,100
	mov	UdragMiniValue,0
	lea	eax,Breaksmp
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,VolumeBreakMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
VolumeBreakMeanWhile:
	pushad
	call	updatebreak
	_rp
VolumeStartInput:			;Volume Start Input ----------------
	pushad
	move	edi,0a0000h+168/8+273*80
	mov	ah,1h
	mov	al,11h
	lea	ebp,Volume_start
	mov	ecx,3
	xor	ebx,ebx
	mov	edx,500
	lea	esi,_ret
	mov	Digitsize,3
	call	ZyricInput
	_rp
VolumeEndInput: 			;Volume End Input ------------------
	pushad
	move	edi,0a0000h+168/8+292*80
	mov	ah,1h
	mov	al,11h
	lea	ebp,Volume_end
	mov	ecx,3
	xor	ebx,ebx
	mov	edx,500
	lea	esi,_ret
	mov	Digitsize,3
	call	ZyricInput
	_rp
VolumeBreakInput:			;Volume Break Input ----------------
	pushad
	move	edi,0a0000h+264/8+273*80
	mov	ah,1h
	mov	al,11h
	lea	ebp,BreakSmp
	mov	ecx,3
	xor	ebx,ebx
	mov	edx,100
	lea	esi,_ret
	mov	Digitsize,3
	call	ZyricInput
	_rp


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Samp Reverse
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampReverse2:
	pushad
	jmp	sss18
SampReverse	Proc	Near
	pushad
	call	buttonhandler
	cmp	eax,0
	jnz	sampreverseend
sss18:
	cmp	samplength,0
	jz	sampreverseend

	call	undostart		;prepare esi,edi,ecx
	mov	ecx,samplength
	mov	esi,undobufferoffset
	mov	edi,sampmainoffset
	mov	eax,samplength
	shl16	eax
	add	esi,eax
	cmp	sampmarkstart,-1
	jz	nomarkedhere
	mov	ecx,sampmarkend
	sub	ecx,sampmarkstart
	mov	esi,undobufferoffset
	mov	edi,sampmainoffset
	mov	eax,sampmarkend
	shl16	eax
	add	esi,eax
	mov	eax,sampmarkstart
	shl16	eax
	add	edi,eax
nomarkedhere:
	cmp	sampbits,1
	jz	reverse16

					;reverse the curve 8 bits
reverseloop:
	dec	esi
	mov	al,[esi]
	stosb
	loop	reverseloop

	cmp	mark_reverse,1
	jz	skipremove11
	mov	sampmarkstart,-1
skipremove11:
	call	viewsamp
	call	updatesampletogus
	call	chooseplayform
	jmp	sampreverseend

reverse16:				;reverse the curve 8 bits
reverseloop2:
	sub	esi,2
	mov	ax,[esi]
	stosw
	loop	reverseloop2
	cmp	mark_reverse,1
	jz	skipremove11_5
	mov	sampmarkstart,-1
skipremove11_5:
	call	viewsamp
	call	updatesampletogus

SampReverseEnd:
	popad
	ret
SampReverse	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Udrag
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
UdragStatus		db	0	;1=Udrag is on 2=Udrag is working
					;0=Udrag is off
ValueProPixel		dd	0	;1024=1value
UdragMaxValue		dd	0
UdragMiniValue		dd	0
UdragVariableOffset	dd	0
UdragVariableSize	db	0	;  1=Byte,2=Word,3=Dword
UdragAfter		dd   _ret	;Offset to proc to do after
UdragMeanWhile		dd   _ret	;Offset to proc to do meanwhile

UdragYsave		dd	0
UdragY			dd	0
UdragYold		dd	0
UdragStartValue 	dd	0
UdragCurrentValue	dd	0

UdragTest		dd	0
UdragControl:				;Udrag Control ---------------
	pushad
	cmp	ButtonHandlerStatus,0
	jz	QuitTheUdrag
	cmp	UdragStatus,0
	jz	_retp
	cmp	UdragStatus,1
	jz	InitUdrag
					;Check Ydrag
	movzx	eax,MouseY
	mov	UdragY,eax
	cmp	UdragYold,eax
	jz	_retp
	mov	UdragYold,eax
					;Change Value
	mov	eax,UdragYsave
	sub	eax,UdragY
	mov	ebx,ValueProPixel
	imul	ebx
	mov	ebx,1024
	idiv	ebx
	mov	ebx,UdragStartValue
	mov	UdragTest,ebx
	add	ebx,eax
					;Clip value
	cmp	ebx,UdragMaxValue
	jle	NoUdragClip1
	mov	ebx,UdragMaxValue
NoUdragClip1:
	cmp	ebx,UdragMiniValue
	jge	NoUdragClip2
	mov	ebx,UdragMiniValue
NoUdragClip2:
					;Put value to variable
	mov	eax,ebx
	mov	UdragCurrentValue,eax
	call	PutUdragValue
	call	[UdragMeanWhile]
	_rp
InitUdrag:				;Init udrag -----------------
	mov	UpdateMouse,80h
	mov	MouseCursor,5
	mov	UdragStatus,2
	movzx	eax,MouseY
	mov	UdragYsave,eax
	mov	UdragYold,-1
	call	GetUdragValue
	mov	UdragStartValue,eax
	cmp	ValueProPixel,0
	jnz	NOvalzero
	inc	ValueProPixel
NOvalzero:
	_rp
QuitTheUdrag:				;Quit the Udrag -------------
	cmp	UdragStatus,0
	jz	_retp
	call	[UdragAfter]
	lea	eax,_ret
	mov	UdragAfter,eax
	mov	UdragMeanWhile,eax
	mov	UpdateMouse,80h
	mov	MouseCursor,0
	mov	UdragStatus,0
	_rp
GetUdragValue:				;Get udrag value ------------
;Return:eax=value
	push	ebx
	mov	ebx,UdragVariableOffset
	cmp	UdragVariableSize,2
	jz	GetUdragWord
	cmp	UdragVariableSize,3
	jz	GetUdragDWord
GetUdragByte:
	movzx	eax,byte ptr [ebx]
	pop	ebx
	ret
GetUdragWord:
	movzx	eax,word ptr [ebx]
	pop	ebx
	ret
GetUdragDWord:
	mov	eax,dword ptr [ebx]
	pop	ebx
	ret
PutUdragValue:				;Put udrag value ------------
;Call:	eax=value
	push	ebx
	mov	ebx,UdragVariableOffset
	cmp	UdragVariableSize,2
	jz	PutUdragWord
	cmp	UdragVariableSize,3
	jz	PutUdragDWord
PutUdragByte:
	mov	byte ptr [ebx],al
	pop	ebx
	ret
PutUdragWord:
	mov	word ptr [ebx],ax
	pop	ebx
	ret
PutUdragDWord:
	mov	dword ptr [ebx],eax
	pop	ebx
	ret


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				New Mark
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MarkOffsetStart 	dd	0
MarkOffsetEnd		dd	0
MarkTimeStart		dd	0
MarkTimeEnd		dd	0
MarkOffsetStartOLD	dd	0
MarkOffsetEndOLD	dd	0
MarkTimeStartOLD	dd	0
MarkTimeEndOLD		dd	0

TimeSampEnd		dd	0
NewMarkStart:				;New Mark Start ---------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	menu_popup,27
	call	menuhandler

	cmp	SampLength,0
	jz	_retp
				  ;calc Time samp end
	mov	eax,SampLength
	mov	ebx,100
	mul	ebx
	mov	ebx,16768	  ;<<<------ SampRate
	push	eax
	movzx	ebx,CurrentSample
	call	GetSampleRate
	mov	ebx,eax
	pop	eaX
	div	ebx
	mov	TimeSampEnd,eax

	cmp	SampMarkStart,-1
	jnz	SkipMarkReset
	mov	MarkOffsetStart,0
	mov	MarkOffsetEnd,1
	mov	MarkTimeStart,0
	mov	MarkTimeEnd,1
	jmp	AfterSettasMark
SkipMarkReset:
				  ;calc MarkTimeSTart ,end
	mov	eax,SampMarkStart
	mov	MarkOffsetStart,eax
	mov	ebx,100
	mul	ebx
				  ;<<<------ SampRate
	push	eax
	movzx	ebx,CurrentSample
	call	GetSampleRate
	mov	ebx,eax
	pop	eaX
	div	ebx
	mov	MarkTimeStart,eax
	mov	eax,SampMarkEnd
	mov	MarkOffsetEnd,eax
	mov	ebx,100
	mul	ebx
				  ;<<<------ SampRate
	push	eax
	movzx	ebx,CurrentSample
	call	GetSampleRate
	mov	ebx,eax
	pop	eaX
	div	ebx
	mov	MarkTimeEnd,eax
AfterSettasMark:
	mov	MarkOffsetStartOLD,-1
	mov	MarkOffsetEndOLD,-1
	mov	MarkTimeStartOLD,-1
	mov	MarkTimeEndOLD,-1
	jmp	_retp
NewMarkEnd2:
	pushad
	jmp	SkipMarkMouse
NewMarkEnd:				;New Mark End ----------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
SkipMarkMouse:
	mov	menu_popup,0
	call	menuhandler
	jmp	_retp

ErrorREPBEG:				;Error RepBeg ----------------
	lea	esi,samptext12
	mov	menu_popup,16
	call	popuphandler
	_rp
ErrorMARK:				;Error Mark ------------------
	lea	esi,samptext13
	mov	menu_popup,16
	call	popuphandler
	_rp
M_StartToRepBeg:			;Start to Repbeg -------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	menu_popup,0
	call	menuhandler
	cmp	SampLength,0
	jz	_retp

	movzx	ebp,currentsample
	mov	al,byte ptr [VoiceControl+ebp]
	bt	ax,3
	jnc	ErrorREPBEG

	movzx	ebp,currentsample
	mov	eax,[ebp*4+loopstart]
	sub	eax,[ebp*4+sampleoffsetstart]
	cmp	eax,0
	jz	ErrorM1
	mov	SampMarkStart,0
	mov	SampMarkEnd,eax
	call	viewsamp
	_rp
ErrorM1:
	lea	esi,samptext14
	mov	menu_popup,16
	call	popuphandler
	_rp
M_RependToEnd:				;Repend To End ---------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	menu_popup,0
	call	menuhandler
	cmp	SampLength,0
	jz	_retp
	movzx	ebp,currentsample
	mov	al,byte ptr [VoiceControl+ebp]
	bt	ax,3
	jnc	ErrorREPBEG

	movzx	ebp,currentsample
	mov	eax,[ebp*4+loopend]
	sub	eax,[ebp*4+sampleoffsetstart]
	cmp	eax,SampLength
	jz	ErrorM2

	mov	SampMarkStart,eax
	mov	eax,SampLength
	mov	SampMarkEnd,eax
	call	ViewSamp
	_rp
ErrorM2:
	lea	esi,samptext15
	mov	menu_popup,16
	call	popuphandler
	_rp
M_RepbegToRepend:			;Repbeg To Repend ------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	menu_popup,0
	call	menuhandler
	cmp	SampLength,0
	jz	_retp
	movzx	ebp,currentsample
	mov	al,byte ptr [VoiceControl+ebp]
	bt	ax,3
	jnc	ErrorREPBEG

	movzx	ebp,currentsample
	mov	eax,[ebp*4+loopstart]
	sub	eax,[ebp*4+sampleoffsetstart]
	mov	ebx,[ebp*4+loopend]
	sub	ebx,[ebp*4+sampleoffsetstart]
	cmp	eax,ebx
	jz	ErrorM3

	mov	SampMarkStart,eax
	mov	SampMarkEnd,ebx
	call	ViewSamp
	_rp
ErrorM3:
	lea	esi,samptext16
	mov	menu_popup,16
	call	popuphandler
	_rp
M_StartToPlaypeg:			;Start To Playpeg ------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	menu_popup,0
	call	menuhandler
	cmp	SampLength,0
	jz	_retp

	mov	eax,PlayPegoff
	cmp	eax,0
	jz	ErrorM4

	mov	SampMarkStart,0
	mov	SampMarkEnd,eax
	call	ViewSamp
	_rp
ErrorM4:
	lea	esi,samptext17
	mov	menu_popup,16
	call	popuphandler
	_rp
M_PlaypegToEnd: 			;Playpeg To End --------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	menu_popup,0
	call	menuhandler
	cmp	SampLength,0
	jz	_retp

	mov	eax,PlayPegoff
	mov	ebx,samplength
	cmp	eax,ebx
	jz	ErrorM5

	mov	SampMarkStart,eax
	mov	SampMarkEnd,ebx
	call	ViewSamp
	_rp
ErrorM5:
	lea	esi,samptext18
	mov	menu_popup,16
	call	popuphandler
	_rp
M_StartToMarkstart:			;Start To Markstart ----------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	menu_popup,0
	call	menuhandler
	cmp	SampLength,0
	jz	_retp
	cmp	SampMarkStart,-1
	jz	ErrorMark

	cmp	SampMarkStart,0
	jz	ErrorM6

	mov	eax,SampMarkStart
	mov	SampMarkStart,0
	mov	SampMarkEnd,eax
	call	ViewSamp
	_rp
ErrorM6:
	lea	esi,samptext19
	mov	menu_popup,16
	call	popuphandler
	_rp
M_StartToMarkend:			;Start To Markend ------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	menu_popup,0
	call	menuhandler
	cmp	SampLength,0
	jz	_retp
	cmp	SampMarkStart,-1
	jz	ErrorMark

	cmp	SampMarkStart,0
	jz	ErrorM6

	mov	SampMarkStart,0
	call	ViewSamp
	_rp
M_MarkstartToEnd:			;Markstart To End ------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	menu_popup,0
	call	menuhandler
	cmp	SampLength,0
	jz	_retp
	cmp	SampMarkStart,-1
	jz	ErrorMark

	mov	eax,SampLength
	cmp	SampMarkEnd,eax
	jz	ErrorM7

	mov	SampMarkEnd,eax
	call	ViewSamp
	_rp
ErrorM7:
	lea	esi,samptext20
	mov	menu_popup,16
	call	popuphandler
	_rp
M_MarkendToEnd: 			;Markend To End --------------
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	menu_popup,0
	call	menuhandler
	cmp	SampLength,0
	jz	_retp
	cmp	SampMarkStart,-1
	jz	ErrorMark

	mov	eax,SampLength
	cmp	SampMarkEnd,eax
	jz	ErrorM7

	mov	ebx,SampMarkEnd
	mov	SampMarkStart,ebx
	mov	SampMarkEnd,eax
	call	ViewSamp
	_rp
PrintMarkDigits:			;Print mark digits --------------
	pushad
	cmp	Menu_popup,27
	jnz	_retp
	cmp	SampLength,0
	jz	_retp

	mov	eax,MarkOffsetStart
	cmp	eax,MarkOffsetStartOLD
	jz	NoMarkP1
	mov	MarkOffsetStartOLD,eax
	move	edi,0a0000h+120/8+143*80
	mov	ah,1
	mov	cl,7
	mov	ebx,MarkOffsetStart
	mov	FontPlane,1
	call	mouseoff
	call	PutDecimal
	call	mouseon
	mov	FontPlane,0
NoMarkP1:
	mov	eax,MarkOffsetEnd
	cmp	eax,MarkOffsetEndOLD
	jz	NoMarkP2
	mov	MarkOffsetEndOld,eax
	move	edi,0a0000h+120/8+164*80
	mov	ah,1
	mov	cl,7
	mov	ebx,MarkOffsetEnd
	mov	FontPlane,1
	call	mouseoff
	call	PutDecimal
	call	mouseon
	mov	FontPlane,0
NoMarkP2:
	mov	eax,MarkTimeStart
	cmp	eax,MarkTimeStartOLD
	jz	NoMarkP3
	mov	MarkTimeStartOLD,eax
	move	edi,0a0000h+120/8+228*80+6
	mov	ebx,'s'
	mov	ah,1
	mov	FontPlane,1
	call	PutCharacter
	mov	FontPlane,0
	move	edi,0a0000h+120/8+228*80+3
	mov	ebx,'.'
	mov	ah,1
	mov	FontPlane,1
	call	PutCharacter
	mov	FontPlane,0
	move	edi,0a0000h+120/8+228*80
	mov	eax,MarkTimeStart
	mov	ebx,100
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	mov	ah,1
	mov	cl,3
	mov	FontPlane,1
	call	mouseoff
	call	PutDecimal
	call	mouseon
	mov	FontPlane,0
	move	edi,0a0000h+120/8+228*80+4
	mov	ebx,edx
	mov	ah,1
	mov	cl,2
	mov	FontPlane,1
	call	mouseoff
	call	PutDecimal
	call	mouseon
	mov	FontPlane,0
NoMarkP3:
	mov	eax,MarkTimeEnd
	cmp	eax,MarkTimeEndOLD
	jz	NoMarkP4
	mov	MarkTimeEndOLD,eax
	move	edi,0a0000h+120/8+249*80+6
	mov	ebx,'s'
	mov	ah,1
	mov	FontPlane,1
	call	PutCharacter
	mov	FontPlane,0
	move	edi,0a0000h+120/8+249*80+3
	mov	ebx,'.'
	mov	ah,1
	mov	FontPlane,1
	call	PutCharacter
	mov	FontPlane,0
	move	edi,0a0000h+120/8+249*80
	mov	eax,MarkTimeEnd
	mov	ebx,100
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	mov	ah,1
	mov	cl,3
	mov	FontPlane,1
	call	mouseoff
	call	PutDecimal
	call	mouseon
	move	edi,0a0000h+120/8+249*80+4
	mov	ebx,edx
	mov	ah,1
	mov	cl,2
	mov	FontPlane,1
	call	mouseoff
	call	PutDecimal
	call	mouseon
	mov	FontPlane,0
NoMarkP4:
	_rp
MarkOffsetStartUp:			;Mark Offset Start Up ----------
	pushad
	call	Fixbutton
	cmp	SampLength,0
	jz	_retp
	add	MarkOffsetStart,1
	mov	eax,MarkOffsetend
	dec	eax
	cmp	MarkOffsetStart,eax
	jbe	_retp
	mov	MarkOffsetStart,eax
	_rp
MarkOffsetStartDown:			;Mark Offset Start Down --------
	pushad
	call	Fixbutton
	cmp	SampLength,0
	jz	_retp
	sub	MarkOffsetStart,1
	cmp	MarkOffsetStart,0
	jge	_retp
	mov	MarkOffsetStart,0
	_rp
MarkOffsetEndUp:			;Mark Offset End Up ------------
	pushad
	call	Fixbutton
	cmp	SampLength,0
	jz	_retp
	add	MarkOffsetEnd,1
	mov	eax,SampLength
	cmp	MarkOffsetEnd,eax
	jbe	_retp
	mov	MarkOffsetEnd,eax
	_rp
MarkOffsetEndDown:			;Mark Offset End Down ----------
	pushad
	call	Fixbutton
	cmp	SampLength,0
	jz	_retp
	sub	MarkOffsetEnd,1
	mov	eax,MarkOffsetStart
	inc	eax
	cmp	MarkOffsetEnd,eax
	jge	_retp
	mov	MarkOffsetEnd,eax
	_rp
MarkTimeStartUp:			;Mark Time Start Up ------------
	pushad
	call	Fixbutton
	cmp	SampLength,0
	jz	_retp
	add	MarkTimeStart,1
	mov	eax,MarkTimeend
	dec	eax
	cmp	MarkTimeStart,eax
	jbe	_retp
	mov	MarkTimeStart,eax
	_rp
MarkTimeStartDown:			;Mark Time Start Down ----------
	pushad
	call	Fixbutton
	cmp	SampLength,0
	jz	_retp
	sub	MarkTimeStart,1
	cmp	MarkTimeStart,0
	jge	_retp
	mov	MarkTimeStart,0
	_rp
MarkTimeEndUp:				;Mark Time End Up --------------
	pushad
	call	Fixbutton
	cmp	SampLength,0
	jz	_retp
	add	MarkTimeEnd,1
	mov	eax,TimeSampEnd
	cmp	MarkTimeEnd,eax
	jbe	_retp
	mov	MarkTimeEnd,eax
	_rp
MarkTimeEndDown:			;Mark Time End Down ------------
	pushad
	call	Fixbutton
	cmp	SampLength,0
	jz	_retp
	sub	MarkTimeEnd,1
	mov	eax,MarkTimeStart
	inc	eax
	cmp	MarkTimeEnd,eax
	jge	_retp
	mov	MarkTimeEnd,eax
	_rp
MarkOffsetStartUdrag:			;Mark Offset Start Udrag ------
	pushad
	cmp	SampLength,0
	jz	_retp
	mov	UdragStatus,1
	mov	eax,SampLength
	mov	ebx,1024
	mul	ebx
	mov	ebx,120
	div	ebx
	mov	ValueProPixel,eax
	mov	eax,SampLength
	mov	eax,MarkOffsetEnd
	dec	eax
	mov	UdragMaxValue,eax
	mov	UdragMiniValue,0
	lea	eax,MarkOffsetStart
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	call	ButtonHandler
	_rp
MarkOffsetEndUdrag:			;Mark Offset End Udrag --------
	pushad
	cmp	SampLength,0
	jz	_retp
	mov	UdragStatus,1
	mov	eax,SampLength
	mov	ebx,1024
	mul	ebx
	mov	ebx,120
	div	ebx
	mov	ValueProPixel,eax
	mov	eax,SampLength
	mov	UdragMaxValue,eax
	mov	eax,MarkOffsetStart
	inc	eax
	mov	UdragMiniValue,eax
	lea	eax,MarkOffsetEnd
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	call	ButtonHandler
	_rp
MarkTimeStartUdrag:			;Mark Time Start Udrag --------
	pushad
	cmp	SampLength,0
	jz	_retp
	mov	UdragStatus,1
	mov	eax,TimeSampEnd
	mov	ebx,1024
	mul	ebx
	mov	ebx,120
	div	ebx
	mov	ValueProPixel,eax
	mov	eax,MarkTimeEnd
	dec	eax
	mov	UdragMaxValue,eax
	mov	UdragMiniValue,0
	lea	eax,MarkTimeStart
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	call	ButtonHandler
	_rp
MarkTimeEndUdrag:			;Mark Time End Udrag ----------
	pushad
	cmp	SampLength,0
	jz	_retp
	mov	UdragStatus,1
	mov	eax,TimeSampEnd
	mov	ebx,1024
	mul	ebx
	mov	ebx,120
	div	ebx
	mov	ValueProPixel,eax
	mov	eax,TimeSampEnd
	mov	UdragMaxValue,eax
	mov	eax,MarkTimeStart
	inc	eax
	mov	UdragMiniValue,eax
	lea	eax,MarkTimeEnd
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	call	ButtonHandler
	_rp
MarkOffsetStartInput:			;Mark Offset Start Input -----
	pushad
	cmp	SampLength,0
	jz	_retp
	move	edi,0a0000h+120/8+143*80
	mov	ah,1h
	mov	al,11h
	lea	ebp,MarkOffsetStart
	mov	ecx,7
	xor	ebx,ebx
	mov	edx,MarkOffsetEnd
	dec	edx
	lea	esi,_ret
	mov	Digitsize,3
	call	ZyricInput
	_rp
MarkOffsetEndInput:			;Mark Offset End Input -------
	pushad
	cmp	SampLength,0
	jz	_retp
	move	edi,0a0000h+120/8+164*80
	mov	ah,1h
	mov	al,11h
	lea	ebp,MarkOffsetEnd
	mov	ecx,7
	mov	ebx,MarkOffsetStart
	inc	ebx
	mov	edx,SampLength
	lea	esi,_ret
	mov	Digitsize,3
	call	ZyricInput
	_rp
MarkTimeStartInput:			;Mark Time Start Input -------
	pushad
	cmp	SampLength,0
	jz	_retp
	move	edi,0a0000h+120/8+228*80
	mov	ah,1h
	mov	al,11h
	lea	ebp,MarkTimeStart
	mov	ecx,5
	xor	ebx,ebx
	mov	edx,MarkTimeEnd
	dec	edx
	lea	esi,AfterMarkTimeStart
	mov	Digitsize,3
	mov	DecimalPoint,2
	call	ZyricInput
	_rp
AfterMarkTimeStart:
	pushad
	mov	DecimalPoint,0
	_rp
MarkTimeEndInput:			;Mark Time End Input ---------
	pushad
	cmp	SampLength,0
	jz	_retp
	move	edi,0a0000h+120/8+249*80
	mov	ah,1h
	mov	al,11h
	lea	ebp,MarkTimeEnd
	mov	ecx,5
	mov	ebx,MarkTimeStart
	inc	ebx
	mov	ebx,TimeSampEnd
	lea	esi,AfterMarkTimeEnd
	mov	Digitsize,3
	mov	DecimalPoint,2
	call	ZyricInput
	_rp
AfterMarkTimeEnd:
	pushad
	mov	DecimalPoint,0
	_rp

MarkOffsetCalc: 			;Mark Offset Calc ------------
	pushad
	call	buttonhandler
	cmp	eax,0
	jnz	_retp
	mov	menu_popup,0
	call	menuhandler
	cmp	SampLength,0
	jz	_retp
	mov	eax,MarkOffsetStart
	mov	SampMarkStart,eax
	mov	eax,MarkOffsetEnd
	mov	SampMarkEnd,eax
	call	ViewSamp
	_rp
MarkTimeCalc:				;Mark Time Calc --------------
	pushad
	call	buttonhandler
	cmp	eax,0
	jnz	_retp
	mov	menu_popup,0
	call	menuhandler
	cmp	SampLength,0
	jz	_retp

	mov	eax,MarkTimeStart
				  ;<<<------ SampRate
	push	eax
	movzx	ebx,CurrentSample
	call	GetSampleRate
	mov	ebx,eax
	pop	eax
	mul	ebx
	mov	ebx,100
	div	ebx
	mov	SampMarkStart,eax

	mov	eax,MarkTimeEnd
	cmp	eax,TimeSampEnd
	jnz	NoEndMark
	mov	eax,SampLength
	mov	SampMarkEnd,eax
	jmp	AfterMarkEndMark
NoEndMark:
				  ;<<<------ SampRate
	push	eax
	movzx	ebx,CurrentSample
	call	GetSampleRate
	mov	ebx,eax
	pop	eaX
	mul	ebx
	mov	ebx,100
	div	ebx
	mov	SampMarkEnd,eax
AfterMarkEndMark:
	call	ViewSamp
	_rp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Different Udrags
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
TempVar 	dd	0
TestVar 	dd	0
SampleUdrag:				;Sample Udrag -----------------
	pushad
	mov	UdragStatus,1
	movzx	eax,CurrentSample
	and	eax,0fh
	mov	TempVar,eax
	mov	eax,16
	mov	ebx,1024
	mul	ebx
	mov	ebx,40
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,15
	mov	UdragMiniValue,0
	lea	eax,TempVar
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,SampleUdragAfter
	mov	UdragAfter,eax
	lea	eax,SampleUdragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
SampleUdragMeanWhile:
	pushad
	mov	eax,TempVar
	mov	bx,CurrentSample
	and	bx,0fff0h
	or	bx,ax
	mov	CurrentSample,bx
	call	PrintSampleInfo
	_rp
SampleUdragAfter:
	pushad
	call	SampleToRAM
	call	PrintSampleInfo
	cmp	AutoName,0
	jz	_retp
	call	Getname2
	_rp
SampPosUdrag:				;Samp Pos Udrag ---------------
	pushad
	cmp	SampLength,0
	jz	_Bretp
	mov	UdragStatus,1
	mov	eax,ViewSampLength
	mov	ebx,1024
	mul	ebx
	mov	ebx,70
	div	ebx
	mov	ValueProPixel,eax
	mov	eax,SampLength
	dec	eax
	mov	UdragMaxValue,eax
	mov	UdragMiniValue,0
	lea	eax,PlayPegOff
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,SampPosUdragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
SampPosUdragMeanWhile:
	pushad
	mov	themovepeg,3
	call	movethepegs
	_rp
ValueUdrag:				;Value Udrag ------------------
	pushad
	cmp	SampLength,0
	jz	_Bretp

	call	CheckIfShadow2
	jc	_retp
	mov	UdragStatus,1

	cmp	SampBits,1
	jz	ValueUdrag16
	mov	ValueProPixel,4369
	mov	UdragMaxValue,255
	mov	UdragMiniValue,0
	mov	eax,PlayPegOff
	mov	ebx,SampMainOffset
	add	ebx,eax
	mov	UdragVariableOffset,ebx
	mov	UdragVariableSize,1
	lea	eax,SampValue8UdragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
ValueUdrag16:
	mov	ValueProPixel,1118481
	mov	UdragMaxValue,65535
	mov	UdragMiniValue,0
	mov	eax,PlayPegOff
	shl	eax,1
	mov	ebx,SampMainOffset
	add	ebx,eax
	mov	UdragVariableOffset,ebx
	mov	UdragVariableSize,2
	lea	eax,SampValue16UdragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
SampValue8UdragMeanWhile:
	pushad
	call	ViewSamp
	call	UpdateSampleToGus
	mov	eax,PlayPegOff
	mov	ebx,SampMainOffset
	add	ebx,eax
	mov	UdragVariableOffset,ebx
	_rp
SampValue16UdragMeanWhile:
	pushad
	call	ViewSamp
	call	UpdateSampleToGus
	mov	eax,PlayPegOff
	shl	eax,1
	mov	ebx,SampMainOffset
	add	ebx,eax
	mov	UdragVariableOffset,ebx
	_rp
SampSizeSave	dd	0
SampSizeUdrag:				;Samp Size Udrag --------------
	pushad
	cmp	SampLength,0
	jz	_Bretp

	call	CheckIfShadow2
	jc	_retp
	mov	eax,SampLength
	mov	SampSizeSave,eax
	mov	UdragStatus,1
	mov	eax,SampLength
	mov	ebx,1024
	mul	ebx
	mov	ebx,60*12
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,99999999
	mov	UdragMiniValue,0
	lea	eax,SampLength
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,SampSizeUdragAfter
	mov	UdragAfter,eax
	call	ButtonHandler
	_rp
SampSizeUdragAfter:
	pushad
	mov	undosamplength,0
	mov	eax,SampLength
	mov	ebx,SampSizeSave
	jmp	ArrowJump
	_rp
MarkSizeUdrag:				;Mark Size Udrag --------------
	pushad
	cmp	SampLength,0
	jz	_Bretp
	cmp	SampMarkStart,-1
	jz	_Bretp
	mov	UdragStatus,1
	mov	eax,SampLength
	sub	eax,SampMarkStart
	mov	ebx,1024
	mul	ebx
	mov	ebx,60
	div	ebx
	mov	ValueProPixel,eax
	mov	eax,SampLength
	dec	eax
	mov	UdragMaxValue,eax
	mov	eax,SampMarkStart
	inc	eax
	mov	UdragMiniValue,eax
	lea	eax,SampMarkEnd
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,SampMarkSizeUdragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
SampMarkSizeUdragMeanWhile:
	pushad
	call	ViewSamp
	_rp

RepBegUdrag:				;Repbeg Udrag -----------------
	cmp	SampLength,0
	jz	_Bret
	pushad
	movzx	ebp,currentsample
	mov	al,byte ptr [VoiceControl+ebp]
	bt	ax,3
	jnc	_Bretp

	movzx	esi,currentsample
	mov	eax,[esi*4+loopstart]
	sub	eax,[esi*4+sampleoffsetstart]
	mov	TempVar,eax
	mov	UdragStatus,1
	mov	eax,[esi*4+loopEnd]
	sub	eax,[esi*4+sampleoffsetstart]
	mov	ebx,1024
	mul	ebx
	mov	ebx,70
	div	ebx
	mov	ValueProPixel,eax
	mov	eax,[esi*4+loopEnd]
	sub	eax,[esi*4+sampleoffsetstart]
	mov	UdragMaxValue,eax
	mov	UdragMiniValue,0
	lea	eax,TempVar
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,RepBegUdragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
RepBegUdragMeanWhile:
	pushad
	mov	ebx,TempVar
	movzx	esi,currentsample
	add	ebx,[esi*4+sampleoffsetstart]
	mov	[esi*4+loopstart],ebx
	mov	themovepeg,1
	call	MoveThePegs
	call	PrintSampleInfo
	call	SetSampleLoop
	_rp

RepEndUdrag:				;RepEnd Udrag -----------------
	cmp	SampLength,0
	jz	_Bret
	pushad
	movzx	ebp,currentsample
	mov	al,byte ptr [VoiceControl+ebp]
	bt	ax,3
	jnc	_Bretp

	movzx	esi,currentsample
	mov	eax,[esi*4+loopEnd]
	sub	eax,[esi*4+sampleoffsetstart]
	mov	TempVar,eax
	mov	UdragStatus,1
	mov	eax,[esi*4+sampleoffsetend]
	sub	eax,[esi*4+sampleoffsetstart]
	mov	UdragMaxValue,eax
	mov	ebx,[esi*4+loopstart]
	sub	ebx,[esi*4+sampleoffsetstart]
	mov	UdragMiniValue,ebx
	sub	eax,ebx
	mov	ebx,1024
	mul	ebx
	mov	ebx,70
	div	ebx
	mov	ValueProPixel,eax
	lea	eax,TempVar
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,RepEndUdragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
RepEndUdragMeanWhile:
	pushad
	mov	ebx,TempVar
	movzx	esi,currentsample
	add	ebx,[esi*4+sampleoffsetstart]
	mov	[esi*4+loopEnd],ebx
	mov	themovepeg,2
	call	MoveThePegs
	call	PrintSampleInfo
	call	SetSampleLoop
	_rp
C4RateUdrag:				;C4 Rate Udrag ----------------
	cmp	SampLength,0
	jz	_Bret
C4RateUdrag2:
	pushad
	cmp	C2Mode,1
	jz	ChangeUdragNote

	mov	UdragStatus,1
	mov	eax,65525-522
	mov	ebx,1024
	mul	ebx
	mov	ebx,60
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,65535
	mov	UdragMiniValue,522
	movzx	ebx,CurrentSample
	lea	eax,SampleRates
	shl	ebx,1
	add	eax,ebx
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,2
	lea	eax,C4UdragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
C4UdragMeanWhile:
	pushad
	call	PrintSampleInfo
	_rp
ChangeUdragNote:			;note
	movzx	ebp,CurrentSample
	call	GetCurrC2RateInPeriod
	mov	TempVar,esi

	mov	UdragStatus,1
	mov	eax,124
	mov	ebx,1024
	mul	ebx
	mov	ebx,60
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,125
	mov	UdragMiniValue,0
	lea	eax,TempVar
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,C4UdragMeanWhile2
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
C4UdragMeanWhile2:
	pushad
	movzx	ebp,CurrentSample
	call	GetCurrC2RateInPeriod
	mov	esi,TempVar
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
	jnz	_retp
	call	PrintPeriod
	call	PrintSampleInfo
	_rp


FineTuneUdrag:				;Fine Tune Udrag --------------
	cmp	SampLength,0
	jz	_Bret
FineTuneUdrag2:
	pushad
	movzx	ebx,CurrentSample
	movzx	eax,byte ptr [FineTunes+ebx]
	and	eax,0fh
	xor	al,8
	mov	TempVar,eax
	mov	UdragStatus,1
	mov	eax,0fh
	mov	ebx,1024
	mul	ebx
	mov	ebx,60
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,0fh
	mov	UdragMiniValue,0h
	lea	eax,TempVar
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,FineTuneUdragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
FineTuneUdragMeanWhile:
	pushad
	mov	eax,TempVar
	and	al,0fh
	xor	al,8
	movzx	ebx,CurrentSample
	and	[FineTunes+ebx],0f0h
	or	[FineTunes+ebx],al
	call	PrintSampleInfo
	_rp
PanPotUdrag:				;PanPotUdrag ------------------
	cmp	SampLength,0
	jz	_Bret
PanPotUdrag2:
	pushad
	movzx	ebx,CurrentSample
	movzx	eax,byte ptr [FineTunes+ebx]
	and	eax,0f0h
	shr	eax,4
	mov	TempVar,eax
	mov	UdragStatus,1
	mov	eax,0fh
	mov	ebx,1024
	mul	ebx
	mov	ebx,60
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,0fh
	mov	UdragMiniValue,0h
	lea	eax,TempVar
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,PanPotUdragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
PanPotUdragMeanWhile:
	pushad
	mov	eax,TempVar
	and	al,0fh
	shl	al,4
	movzx	ebx,CurrentSample
	and	[FineTunes+ebx],0fh
	or	[FineTunes+ebx],al
	call	PrintSampleInfo
	_rp
VolumeUdrag:				;Volume Udrag -----------------
	cmp	SampLength,0
	jz	_Bret
VolumeUdrag2:
	pushad
	mov	UdragStatus,1
	mov	eax,07fh
	mov	ebx,1024
	mul	ebx
	mov	ebx,45
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,07fh
	mov	UdragMiniValue,0h
	movzx	ebx,CurrentSample
	lea	eax,Volumes
	add	eax,ebx
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,1
	lea	eax,C4UdragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   ToneFork
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
TuneForkStatus	db	0	;1=On
ToggleTuneFork: 			;Toggle Tone Fork -----------------
	pushad

	xor	TuneForkStatus,1
	call	mouseoff
	mov	buttonX1,5
	mov	buttonY1,389
	mov	buttonX2,84
	mov	buttonY2,405
	mov	bl,TuneForkStatus
	xor	bl,1
	call	buttonupdown
	call	mouseon

	cmp	TuneForkStatus,0
	jz	TuneForkOff2
	call	TuneForkOn
	_rp
TuneForkOff2:
	call	TuneForkOff
	_rp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Samp Rate
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampRateStatus	db	0	;0=rate,1=note
CurrentSampRate dd	0
SampRateUp:				;Samp Rate Up ------------------
	pushad
	call	FixButton
	cmp	SampLength,0
	jz	_retp
	cmp	SampRateStatus,1
	jz	DoNote2
	cmp	CurrentSampRate,50148
	jz	_retp
	inc	CurrentSampRate
	mov	eax,CurrentSampRate
	movzx	ebx,CurrentSample
	call	PutSampleRate
	jnc	_retp
	call	InsSampleRate
	jc	NotEnoughHimem
	call	PutSampleRate
	_rp
DoNote2:
	mov	eax,CurrentSampRate
	cmp	CurrentSampRate,0
	jz	IncSampRateZero
	call	GetNoteFromSampleFreq
	inc	eax
	call	GetSampleFreqFromNote
	cmp	eax,50148
	ja	_retp
	mov	CurrentSampRate,eax
	movzx	ebx,CurrentSample
	call	PutSampleRate
	jnc	_retp
	call	InsSampleRate
	jc	NotEnoughHimem
	call	PutSampleRate
	_rp
IncSampRateZero:
	xor	eax,eax
	call	GetSampleFreqFromNote
	mov	CurrentSampRate,eax
	movzx	ebx,CurrentSample
	call	PutSampleRate
	jnc	_retp
	call	InsSampleRate
	jc	NotEnoughHimem
	call	PutSampleRate
	_rp
SampRateDown:				;Samp Rate Down ----------------
	pushad
	call	FixButton
	cmp	SampLength,0
	jz	_retp
	cmp	SampRateStatus,1
	jz	DoNote1
	cmp	CurrentSampRate,522 ;0
	jz	_retp
	dec	CurrentSampRate
	cmp	CurrentSampRate,0
	jz	KillRatePos
	mov	eax,CurrentSampRate
	movzx	ebx,CurrentSample
	call	PutSampleRate
	jnc	_retp
	call	InsSampleRate
	jc	NotEnoughHimem
	call	PutSampleRate
	_rp
DoNote1:
	mov	eax,CurrentSampRate
	cmp	eax,522 ;0
	jz	_retp
	call	GetNoteFromSampleFreq
	cmp	eax,522 ;0
	jz	_retp ;KillRatePos
	dec	eax
	call	GetSampleFreqFromNote
	mov	CurrentSampRate,eax
	movzx	ebx,CurrentSample
	call	PutSampleRate
	jnc	_retp
	call	InsSampleRate
	jc	NotEnoughHimem
	call	PutSampleRate
	_rp
SampRateUdrag:				;Samp Rate Udrag ---------------
	pushad
	cmp	SampLength,0
	jz	_Bretp
	cmp	SampRateStatus,1
	jz	DoNote3
	mov	UdragStatus,1
	mov	eax,50148
	mov	ebx,1024
	mul	ebx
	mov	ebx,35
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,50148
	mov	UdragMiniValue,522 ;0
	lea	eax,CurrentSampRate
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,SampRatenUdragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
SampRatenUdragMeanWhile:
	pushad
	mov	eax,CurrentSampRate
	cmp	eax,0
	jz	KillRatePos
	movzx	ebx,CurrentSample
	call	PutSampleRate
	jnc	_retp
	call	InsSampleRate
	jc	NotEnoughHimem
	call	PutSampleRate
	_rp
DoNote3:
	mov	eax,CurrentSampRate
	call	GetNoteFromSampleFreq
	mov	TempVar,eax
	mov	UdragStatus,1
	mov	eax,80
	mov	ebx,1024
	mul	ebx
	mov	ebx,35
	div	ebx
	mov	ValueProPixel,eax
	mov	UdragMaxValue,80
	mov	UdragMiniValue,0
	lea	eax,TempVar
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,SampRatenUdragMeanWhile2
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
SampRatenUdragMeanWhile2:
	pushad
	mov	eax,TempVar
	call	GetSampleFreqFromNote
	mov	CurrentSampRate,eax
	cmp	eax,0
	jz	KillRatePos
	movzx	ebx,CurrentSample
	call	PutSampleRate
	jnc	_retp
	call	InsSampleRate
	jc	NotEnoughHimem
	call	PutSampleRate
	_rp
SampRateChange: 			;Samp Rate Change --------------
	pushad
	xor	SampRateStatus,1
	mov	dword ptr [OldPuts+18*4],-1
	mov	dword ptr [OldPuts+19*4],-1
	cmp	SampRateStatus,0
	jz	_retp
	mov	eax,CurrentSampRate
	cmp	eax,0
	jz	_retp
	call	GetNoteFromSampleFreq
	call	GetSampleFreqFromNote
	mov	CurrentSampRate,eax
	_rp
KillRatePos:				;Del rate pos ----------------
	movzx	ebx,CurrentSample
	call	DelSampleRate
	_rp
; In: eax=Note number
;Out: eax=Frequency
GetSampleFreqFromNote:			;Get Sample Freq From Note ----
	pushad
	mov	ebx,12
	xor	edx,edx
	div	ebx
	mov	ecx,eax
	mov	eax,8363*16*428
	mov	ebx,[edx*4+pt_periodtable]
	shr	ebx,cl
	xor	edx,edx
	div	ebx
	mov	[esp+28],eax
	_rp

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 SAMPLE PLAY NU
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SamplePlayNU	Proc	Near
	pushad
	cmp	PlayStatusen,1
	jz	StopNU

PlayNU:
	mov	eax,KeyboardNote
	cmp	eax,0
	jnz	skipnu
	mov	eax,62
skipnu:

	mov	edx,eax
	movzx	edi,CursorChannel
	mov	[keyofftable+edi],1
	call	mouseplay
	popad
	ret

StopNU:
	call	StopAllVoices
	popad
	ret
SamplePlayNU	Endp
OldCurrAdd	dd	0
PlayStatusen	db	0	;1=playing
NowPlayCheck	db	0
PlayCheck	Proc	Near		;--------- PlayCheck
	pushad
	cmp	Menu_downscreen,4
	jnz	_retp
	cmp	SampLength,0
	jz	_retp
	xor	NowPlayCheck,1
	cmp	NowPlayCheck,0
	jz	_retp

	mov	eax,Curradd
	mov	ebx,OldCurradd
	mov	OldCurrAdd,eax
	cmp	eax,ebx
	jz	NotPlaying



	cmp	PlayStatusen,1
	jz	_retp
	cmp	Menu_popup,0
	jnz	_retp
	mov	PlayStatusen,1
	mov	ButtonX1,5
	mov	ButtonY1,372
	mov	ButtonX2,84
	mov	ButtonY2,388
	mov	bl,0
	call	ButtonUpDown
	popad
	ret
NotPlaying:
	cmp	PlayStatusen,0
	jz	_retp
	cmp	Menu_popup,0
	jnz	_retp
	mov	PlayStatusen,0
	mov	ButtonX1,5
	mov	ButtonY1,372
	mov	ButtonX2,84
	mov	ButtonY2,388
	mov	bl,1
	call	ButtonUpDown
	popad
	ret
PlayCheck	Endp


NewEffDown:
	ret


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 DRAW SAMP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DrawStatus	db	0	;0=Off 1=On
DrawingStatus	db	0	;0=Off 1=On
FirstDraw	db	0

DrawSamp	Proc	Near
	pushad
	cmp	Menu_downscreen,4
	jnz	_retp

	xor	DrawStatus,1


	cmp	DrawStatus,0
	jz	notfirst
	mov	FirstDraw,1
notfirst:
	mov	mousecursor,0
	mov	updatemouse,80h
	cmp	DrawStatus,0
	jz	noonnas
	mov	mousecursor,7
	mov	updatemouse,80h
noonnas:

	mov	ButtonX1,85
	mov	ButtonY1,457
	mov	ButtonX2,157
	mov	ButtonY2,473
	mov	bl,DrawStatus
	xor	bl,1
	call	ButtonUpDown
	popad
	ret
DrawSamp	Endp
DrawingLastPointX	dd	0
DrawingLastPointY	dd	0
DrawPointX1		dd	0
DrawPointX2		dd	0
DrawPointY1		dd	0
DrawPointY2		dd	0
DrawMain	Proc	Near		;--------------- Draw Main ----------
	pushad
	cmp	Menu_downscreen,4
	jnz	NoDownscreen4
	cmp	Menu_popup,0
	jnz	_retp

	cmp	DrawStatus,0
	jz	_retp
	cmp	stacksaven,0
	jnz	_retp


	cmp	MouseB,0
	jz	DoDrawingOff
	cmp	MouseX,32
	jb	DoDrawingOff
	cmp	MouseX,631
	ja	DoDrawingOff
	cmp	MouseY,225
	jb	DoDrawingOff
	cmp	MouseY,352
	ja	DoDrawingOff
	cmp	DrawingStatus,1
	jz	DoDrawing

	call	CheckIfShadow
	jc	_retp

	mov	DrawingStatus,1
	call	SaveUndo
	movzx	eax,MouseX
	mov	DrawingLastPointX,eax
	movzx	eax,MouseY
	mov	DrawingLastPointY,eax
	cmp	SampLength,0
	jz	GetSizen
				;Do Drawing
DoDrawing:
	movzx	eax,MouseX			;flip
	mov	ebx,DrawingLastPointX
	movzx	ecx,MouseY
	mov	edx,DrawingLastPointY
	cmp	FirstDraw,1
	jz	nosamenow
	cmp	eax,ebx
	jnz	nosamenow
	cmp	ecx,edx
	jnz	nosamenow
	popad
	ret
nosamenow:
	mov	FirstDraw,0

	sub	eax,32
	sub	ebx,32
	sub	ecx,225
	sub	edx,225
	cmp	eax,ebx
	jbe	noflippas1
	xchg	eax,ebx
	xchg	ecx,edx
noflippas1:
	mov	DrawPointX1,eax
	mov	DrawPointX2,ebx
	mov	DrawPointY1,ecx
	mov	DrawPointY2,edx
	movzx	eax,MouseX
	mov	DrawingLastPointX,eax
	movzx	eax,MouseY
	mov	DrawingLastPointY,eax

	cmp	sampbits,1		;increase y points
	jz	do16draw
	shl	DrawPointY1,1
	shl	DrawPointY2,1
	jmp	after16draw
do16draw:
	shl	DrawPointY1,9
	shl	DrawPointY2,9
after16draw:

	mov	eax,viewsamplength	;edi
	mov	ebx,DrawPointX1
	mul	ebx
	mov	ebx,600
	div	ebx
	add	eax,viewsampoffset
	shl16	eax
	add	eax,sampmainoffset
	mov	edi,eax

	mov	eax,viewsamplength	;ecx
	mov	ebx,DrawPointX2
	mul	ebx
	mov	ebx,600
	div	ebx
	mov	ecx,eax
	mov	eax,viewsamplength	;ecx
	mov	ebx,DrawPointX1
	mul	ebx
	mov	ebx,600
	div	ebx
	sub	ecx,eax
	cmp	ecx,0
	jnz	nozero__
	mov	ecx,1
nozero__:
	mov	esi,ecx

	cmp	sampbits,1
	jz	Do16drawas
	mov	ebp,DrawPointY2
	sub	ebp,DrawPointY1
	xor	ebx,ebx
DrawCurveChangeLoop:
	mov	eax,ebx
	imul	ebp
	idiv	esi
	add	eax,DrawPointY1
	mov	[edi],al
	inc	edi
	inc	ebx
	loop	DrawCurveChangeLoop
	call	viewsamp
	popad
	ret
Do16Drawas:				;16 drawas
	mov	ebp,DrawPointY2
	sub	ebp,DrawPointY1
	xor	ebx,ebx
DrawCurveChangeLoop2:
	mov	eax,ebx
	imul	ebp
	idiv	esi
	add	eax,DrawPointY1
	mov	[edi],ax
	add	edi,2
	inc	ebx
	loop	DrawCurveChangeLoop2
	call	viewsamp
	popad
	ret
DoDrawingOff:			;Do drawing off
	cmp	DrawingStatus,0
	jz	_retp
	mov	FirstDraw,1
	call	updatesampletogus
	mov	DrawingStatus,0
	popad
	ret
NoDownScreen4:
	cmp	DrawStatus,0
	jz	_retp
	mov	DrawStatus,0
	mov	mousecursor,0
	cmp	Menu_downscreen,4
	jnz	_retp
	mov	ButtonX1,85
	mov	ButtonY1,457
	mov	ButtonX2,157
	mov	ButtonY2,473
	mov	bl,DrawStatus
	xor	bl,1
	call	ButtonUpDown
	popad
	ret
GetSizen:
	mov	samplength,10
	call	allocsamplength
	mov	sampbits,0
	mov	al,128
	mov	edi,sampmainoffset
	mov	ecx,10
	rep	stosb
	mov	viewsamplength,10
	mov	viewsampoffset,0
	call	viewsamp
	call	updatesampletogus
	call	printsampleinfo

	popad
	ret
DrawMain	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				RESAMPLE START
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ResampleStart:			;------------- Resample start
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp


	cmp	samplength,0
	jnz 	@@j1
	mov	ResampCurrentNote,0
	mov	ResampResampNote,0
	mov	ResampRelHnote,0
@@j1:

	call	CheckIfShadow
	jc	_retp
	mov	OldResampCurrentNote,-1
	mov	OldResampResampNote,-1
	mov	OldResampRelHnote,-1

	movzx	ebx,CurrentSample
	call	GetSampleRate
	jnc	NoZeroNow__
	mov	eax,20
	jmp	YesASampRate_3
NoZeroNow__:
	mov	esi,1
	cmp	eax,0
	jz	YesASampRate_3
	call	GetNoteFromSampleFreq
	mov	esi,eax
	add	esi,2
YesASampRate_3:
	mov	ResampCurrentNote,esi
	mov	ResampResampNote,esi
	mov	ResampRelHnote,0

	mov	Menu_popup,34
	call	MenuHandler
	_rp

ResampleEnd2:			;------------- Resample end
	pushad
	jmp	Jmpa2
ResampleEnd:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
Jmpa2:
	mov	Menu_popup,0
	call	MenuHandler
	_rp
ResampCurrentNote	dd	0
ResampResampNote	dd	0
ResampRelHnote		dd	0
OldResampCurrentNote	dd	0
OldResampResampNote	dd	0
OldResampRelHnote	dd	0
ResampleMain:			;--------------- Resample main
	pushad
	cmp	Menu_popup,34
	jnz	_retp
	mov	eax,ResampCurrentNote
	cmp	eax,OldResampCurrentNote
	jz	NoResampChange1
	mov	OldResampCurrentNote,eax
	mov	esi,eax
	move	edi,0a0000h+248/8+282*80
	mov	bitplane,00000001b
	mov	FontPlane,1
	call	mouseoff
	call	printperiod
	call	mouseon
	mov	FontPlane,0
NoResampChange1:
	mov	eax,ResampResampNote
	cmp	eax,OldResampResampNote
	jz	NoResampChange2
	mov	OldResampResampNote,eax
	mov	esi,eax
	move	edi,0a0000h+248/8+303*80
	mov	bitplane,00000001b
	mov	FontPlane,1
	call	printperiod
	mov	FontPlane,0
NoResampChange2:
	mov	eax,ResampRelHNote
	cmp	eax,OldResampRelHNote
	jz	NoResampChange3
	mov	OldResampRelHNote,eax
	mov	esi,eax
	move	edi,0a0000h+432/8+282*80
	mov	ah,1
	mov	cl,2
	mov	ebx,ResampRelHnote
	cmp	ebx,0
	jge	noneggas
	neg	ebx
noneggas:
	mov	FontPlane,1
	call	mouseoff
	call	PutDecimal
	call	mouseon
	mov	FontPlane,0
	mov	ebx,' '
	cmp	ResampRelHNote,0
	jle	NoGreat
	mov	ebx,'+'
NoGreat:
	cmp	ResampRelHNote,0
	jge	NoLesson
	mov	ebx,'-'
NoLesson:
	move	edi,0a0000h+424/8+282*80
	mov	ah,00000001b
	mov	Fontplane,1
	call	mouseoff
	call	putcharacter
	call	mouseon
	mov	Fontplane,0
NoResampChange3:
	_rp
					;-- Curr Up
CurrUp:
	pushad
	call	fixbutton
	cmp	samplength,0
	jz	_retp
	cmp	ResampCurrentNote,79
	jz	_retp
	mov	eax,ResampCurrentNote
	sub	eax,ResampResampNote
	cmp	eax,3*12
	jge	_retp
	inc	ResampCurrentNote
	dec	ResampRelHnote
	_rp
					;-- Curr Down
CurrDown:
	pushad
	call	fixbutton
	cmp	samplength,0
	jz	_retp
	cmp	ResampCurrentNote,2
	jz	_retp
	mov	eax,ResampResampNote
	sub	eax,ResampCurrentNote
	cmp	eax,3*12
	jge	_retp
	dec	ResampCurrentNote
	inc	ResampRelHnote
	_rp
					;-- Curr Udrag
CurrUdrag:
	pushad
	cmp	samplength,0
	jz	_retp
	mov	UdragStatus,1
	mov	eax,3*12
	mov	ebx,1024
	mul	ebx
	mov	ebx,120
	div	ebx
	mov	ValueProPixel,eax
	mov	eax,ResampResampNote
	add	eax,3*12
	cmp	eax,79
	jle	nojas1
	mov	eax,79
nojas1:
	mov	UdragMaxValue,eax
	mov	eax,ResampResampNote
	sub	eax,3*12
	cmp	eax,2
	jge	nojas2
	mov	eax,2
nojas2:
	mov	UdragMiniValue,eax
	lea	eax,ResampCurrentNote
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,UpdateUdragCurr
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
UpdateUdragCurr:
	pushad
	mov	eax,ResampResampNote
	sub	eax,ResampCurrentNote
	mov	ResampRelHNote,eax
	_rp
					;-- Res Up
ResUp:
	pushad
	call	fixbutton
	cmp	samplength,0
	jz	_retp
	cmp	ResampResampNote,79
	jz	_retp
	mov	eax,ResampResampNote
	sub	eax,ResampCurrentNote
	cmp	eax,3*12
	jge	_retp
	inc	ResampResampNote
	inc	ResampRelHnote
	_rp
					;-- Res Down
ResDown:
	pushad
	call	fixbutton
	cmp	samplength,0
	jz	_retp
	cmp	ResampResampNote,2
	jz	_retp
	mov	eax,ResampCurrentNote
	sub	eax,ResampResampNote
	cmp	eax,3*12
	jge	_retp
	dec	ResampResampNote
	dec	ResampRelHnote
	_rp
					;-- Res Udrag
ResUdrag:
	pushad
	cmp	samplength,0
	jz	_retp
	mov	UdragStatus,1
	mov	eax,3*12
	mov	ebx,1024
	mul	ebx
	mov	ebx,120
	div	ebx
	mov	ValueProPixel,eax
	mov	eax,ResampCurrentNote
	add	eax,3*12
	cmp	eax,79
	jle	nojas1_
	mov	eax,79
nojas1_:
	mov	UdragMaxValue,eax
	mov	eax,ResampCurrentNote
	sub	eax,3*12
	cmp	eax,2
	jge	nojas2_
	mov	eax,2
nojas2_:
	mov	UdragMiniValue,eax
	lea	eax,ResampResampNote
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,UpdateUdragRes
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
UpdateUdragRes:
	pushad
	mov	eax,ResampResampNote
	sub	eax,ResampCurrentNote
	mov	ResampRelHNote,eax
	_rp
					;-- Rel Up
RelUp:
	pushad
	call	fixbutton
	cmp	samplength,0
	jz	_retp
	cmp	ResampResampNote,79
	jz	_retp
	cmp	ResampRelHnote,3*12
	jge	_retp
	inc	ResampRelHnote
	inc	ResampResampNote
	_rp
					;-- Rel Down
RelDown:
	pushad
	call	fixbutton
	cmp	samplength,0
	jz	_retp
	cmp	ResampResampNote,2
	jz	_retp
	cmp	ResampRelHnote,-3*12
	jle	_retp
	dec	ResampRelHnote
	dec	ResampResampNote
	_rp
					;-- Rel Udrag
FuskVar dd	0
RelUdrag:
	pushad
	cmp	samplength,0
	jz	_retp
	mov	UdragStatus,1
	mov	eax,ResampRelHnote
	add	eax,3*12
	mov	FuskVar,eax
	mov	eax,3*12
	mov	ebx,1024
	mul	ebx
	mov	ebx,100
	div	ebx
	mov	ValueProPixel,eax
	mov	eax,79
	sub	eax,ResampCurrentNote
	cmp	eax,3*12
	jbe	nosk1
	mov	eax,3*12
nosk1:
	add	eax,3*12
	mov	UdragMaxValue,eax
	mov	eax,ResampCurrentNote
	sub	eax,2
	cmp	eax,3*12
	jbe	nosk2
	mov	eax,3*12
nosk2:
	mov	ebx,3*12
	sub	ebx,eax
	mov	UdragMiniValue,ebx
	lea	eax,FuskVar
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,UpdateUdragRelH
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
UpdateUdragRelH:
	pushad
	mov	eax,FuskVar
	sub	eax,3*12
	mov	ResampRelHnote,eax
	mov	ebx,ResampCurrentNote
	add	ebx,eax
	mov	ResampResampNote,ebx
	_rp
OkaySamp		dd	0
ResampleOkay:			;------------- Resample Okay
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	Menu_popup,0
	call	MenuHandler

	cmp	samplength,0
	jz	_retp
	call	saveundo
NoExtraStor:
	mov	eax,ResampRelHnote
	add	eax,3*12
	mov	ecx,3*12*2
	sub	ecx,eax
	shl	ecx,4
	shl	eax,4
	mov	edx,[Pcxoffsets+9*4]
	mov	ebx,[edx+ecx*4]
	mov	eax,[edx+eax*4]

	push	ebx
	mov	ebx,SampLength
	mov	OkaySamp,ebx
	mul	ebx
	mov	ebx,16384
	div	ebx
	mov	SampLength,eax
	add	eax,2000
	call	AllocSampLength
	pop	ebx

	cmp	Sampbits,1
	jz	Resamp16			;-------- 8
	xor	eax,eax
	xor	edx,edx
	xor	ebp,ebp
	mov	edi,SampMainOffset
ResampLoopen:
	push	eax edx
	shrd	eax,edx,14
	cmp	eax,OkaySamp
	jae	AfterResampen
	add	eax,UndoBufferOffset
	mov	cl,[eax]
	mov	[edi],cl
	inc	edi
	inc	ebp
	pop	edx eax
	add	eax,ebx
	adc	edx,0
	jmp	ResampLoopen
AfterResampen:
	pop	edx eax
	mov	SampLength,ebp
	call	AllocSampLength

	mov	eax,SampLength
	mov	ebx,OkaySamp
	call	modpegs
	mov	sampmarkstart,-1
	mov	eax,SampLength
	mov	ViewSampLength,eax
	mov	viewsampoffset,0
	call	chooseplayform
	call	updatesampletogus
	call	viewsamp
	_rp
Resamp16:					;------16
	xor	eax,eax
	xor	edx,edx
	xor	ebp,ebp
	mov	edi,SampMainOffset
ResampLoopen2:
	push	eax edx
	shrd	eax,edx,14
	cmp	eax,OkaySamp
	jae	AfterResampen2
	shl	eax,1
	add	eax,UndoBufferOffset
	mov	cx,[eax]
	mov	[edi],cx
	add	edi,2
	inc	ebp
	pop	edx eax
	add	eax,ebx
	adc	edx,0
	jmp	ResampLoopen2
AfterResampen2:
	pop	edx eax
	mov	SampLength,ebp
	call	AllocSampLength

	mov	eax,SampLength
	mov	ebx,OkaySamp
	call	modpegs
	mov	sampmarkstart,-1
	mov	eax,SampLength
	mov	ViewSampLength,eax
	mov	viewsampoffset,0
	call	chooseplayform
	call	updatesampletogus
	call	viewsamp
	_rp

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   MOD PEGS
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Calls:  eax=New samplength
;	  ebx=Old samplength
;
OldSampL	dd	0
NewSampL	dd	0
ModPegs:
	pushad
	mov	OldSampL,ebx
	mov	NewSampL,eax

	mov	ecx,playpegoff
	mul	ecx
	div	ebx
	mov	playpegoff,eax

	movzx	ebp,currentsample
	mov	eax,[ebp*4+loopstart]
	sub	eax,[ebp*4+sampleoffsetstart]
	mov	ebx,NewSampL
	mul	ebx
	mov	ebx,OldSampL
	div	ebx
	add	eax,[ebp*4+sampleoffsetstart]
	mov	[ebp*4+loopstart],eax

	movzx	ebp,currentsample
	mov	eax,[ebp*4+loopend]
	sub	eax,[ebp*4+sampleoffsetstart]
	mov	ebx,NewSampL
	mul	ebx
	mov	ebx,OldSampL
	div	ebx
	add	eax,[ebp*4+sampleoffsetstart]
	mov	[ebp*4+loopend],eax
	popad
	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   CLIP PEGS
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ClipPegs:
	pushad
	mov	ebp,SampLength
	cmp	playpegoff,ebp
	jb	nosettathis2__
	mov	playpegoff,ebp
	dec	playpegoff
nosettathis2__:
	movzx	ebp,currentsample
	mov	ebx,Samplength
	mov	eax,[ebp*4+loopstart]
	sub	eax,[ebp*4+sampleoffsetstart]
	cmp	eax,ebx
	jbe	noskilla1
	mov	eax,ebx
	add	eax,[ebp*4+sampleoffsetstart]
	mov	[ebp*4+loopstart],eax
noskilla1:
	mov	eax,[ebp*4+loopend]
	sub	eax,[ebp*4+sampleoffsetstart]
	cmp	eax,ebx
	jbe	noskilla2
	mov	eax,ebx
	add	eax,[ebp*4+sampleoffsetstart]
	mov	[ebp*4+loopend],eax
noskilla2:
	popad
	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Fix loop
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DoFixLoopSize	dd	0
FixLoop 	Proc	Near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp

	call	CheckIfShadow
	jc	_retp

	cmp	SampLength,0
	jz	_retp
	cmp	FormSelect,0
	jz	_retp

	cmp	sampmarkstart,-1
	jz	_FixErrorMess


	mov	eax,SampMarkEnd
	sub	eax,SampMarkStart
	inc	eax

	movzx	ebx,currentsample
	mov	ebp,sampmainoffset
	mov	ecx,[ebx*4+loopstart]
	sub	ecx,[ebx*4+sampleoffsetstart]
	cmp	eax,ecx
	jbe	DontMatter1
	mov	eax,ecx
DontMatter1:
	mov	ecx,[ebx*4+loopend]
	sub	ecx,[ebx*4+sampleoffsetstart]
	mov	ebx,SampLength
	sub	ebx,eax
	cmp	eax,ebx
	jbe	DontMatter2
	mov	eax,ebx
DontMatter2:
	cmp	eax,0
	jz	_retp

	mov	DofixloopSize,eax

	call	saveundo
	call	FixIt


	mov	PlayForm,1
	call	PlayFormAll
	mov	SampMarkStart,-1
	call	viewsamp
	call	updatesampletogus

	popad
	ret

_FixErrorMess:
	lea	esi,SampText21
	mov	menu_popup,16
	call	popuphandler
	popad
	ret
FixLoop 	Endp
FixIndicate	dd	0
StartFix	dd	0
SaveFix 	dd	0
FixIt	Proc	Near		; ---------------------- Fix it -------------
	pushad			; ------ 8 bits

	cmp	sampbits,1
	jz	FixIt16

	movzx	ebx,currentsample
	mov	ebp,sampmainoffset
	mov	eax,[ebx*4+loopstart]
	sub	eax,[ebx*4+sampleoffsetstart]
	add	ebp,eax
	mov	esi,UndoBufferOffset
	mov	edi,esi
	add	esi,eax
	mov	eax,[ebx*4+loopend]
	sub	eax,[ebx*4+sampleoffsetstart]
	add	edi,eax
	mov	FixIndicate,-1
	call	DoFixSide
	movzx	ebx,currentsample
	mov	ebp,sampmainoffset
	mov	eax,[ebx*4+loopstart]
	sub	eax,[ebx*4+sampleoffsetstart]
	add	ebp,eax
	mov	esi,UndoBufferOffset
	mov	edi,esi
	add	esi,eax
	mov	eax,[ebx*4+loopend]
	sub	eax,[ebx*4+sampleoffsetstart]
	add	edi,eax
	mov	FixIndicate,1
	call	DoFixSide
	movzx	ebx,currentsample
	mov	ebp,sampmainoffset
	mov	eax,[ebx*4+loopend]
	sub	eax,[ebx*4+sampleoffsetstart]
	add	ebp,eax
	mov	esi,UndoBufferOffset
	mov	edi,esi
	add	esi,eax
	mov	eax,[ebx*4+loopstart]
	sub	eax,[ebx*4+sampleoffsetstart]
	add	edi,eax
	mov	FixIndicate,-1
	call	DoFixSide
	movzx	ebx,currentsample
	mov	ebp,sampmainoffset
	mov	eax,[ebx*4+loopend]
	sub	eax,[ebx*4+sampleoffsetstart]
	add	ebp,eax
	mov	esi,UndoBufferOffset
	mov	edi,esi
	add	esi,eax
	mov	eax,[ebx*4+loopstart]
	sub	eax,[ebx*4+sampleoffsetstart]
	add	edi,eax
	mov	FixIndicate,1
	call	DoFixSide
	popad
	ret
DoFixSide:
	movzx	eax,byte ptr [esi]
	movzx	ebx,byte ptr [edi]
	add	eax,ebx
	shr	eax,1
	mov	StartFix,eax
	xor	ebx,ebx
	mov	ecx,DoFixLoopSize
FixaLoopen:
	push	ecx
	movzx	eax,byte ptr [edi]
	sub	eax,StartFix
	mov	ecx,DoFixLoopSize
	sub	ecx,ebx
	imul	ecx
	mov	SaveFix,eax
	movzx	eax,byte ptr [esi]
	sub	eax,StartFix
	mov	ecx,DoFixLoopSize
	add	ecx,ebx
	imul	ecx
	add	eax,SaveFix
	mov	ecx,DoFixLoopSize
	shl	ecx,1
	cdq
	idiv	ecx
	mov	ecx,StartFix
	add	ecx,eax
	mov	[ebp],cl
	inc	ebx
	add	ebp,FixIndicate
	add	esi,FixIndicate
	add	edi,FixIndicate
	pop	ecx
	loop	FixaLoopen
	ret

FixIt16:			; ------ 16 bits

	movzx	ebx,currentsample
	mov	ebp,sampmainoffset
	mov	eax,[ebx*4+loopstart]
	sub	eax,[ebx*4+sampleoffsetstart]
	shl16	eax
	add	ebp,eax
	mov	esi,UndoBufferOffset
	mov	edi,esi
	add	esi,eax
	mov	eax,[ebx*4+loopend]
	sub	eax,[ebx*4+sampleoffsetstart]
	shl16	eax
	add	edi,eax
	mov	FixIndicate,-2
	call	DoFixSide2
	movzx	ebx,currentsample
	mov	ebp,sampmainoffset
	mov	eax,[ebx*4+loopstart]
	sub	eax,[ebx*4+sampleoffsetstart]
	shl16	eax
	add	ebp,eax
	mov	esi,UndoBufferOffset
	mov	edi,esi
	add	esi,eax
	mov	eax,[ebx*4+loopend]
	sub	eax,[ebx*4+sampleoffsetstart]
	shl16	eax
	add	edi,eax
	mov	FixIndicate,2
	call	DoFixSide2
	movzx	ebx,currentsample
	mov	ebp,sampmainoffset
	mov	eax,[ebx*4+loopend]
	sub	eax,[ebx*4+sampleoffsetstart]
	shl16	eax
	add	ebp,eax
	mov	esi,UndoBufferOffset
	mov	edi,esi
	add	esi,eax
	mov	eax,[ebx*4+loopstart]
	sub	eax,[ebx*4+sampleoffsetstart]
	shl16	eax
	add	edi,eax
	mov	FixIndicate,-2
	call	DoFixSide2
	movzx	ebx,currentsample
	mov	ebp,sampmainoffset
	mov	eax,[ebx*4+loopend]
	sub	eax,[ebx*4+sampleoffsetstart]
	shl16	eax
	add	ebp,eax
	mov	esi,UndoBufferOffset
	mov	edi,esi
	add	esi,eax
	mov	eax,[ebx*4+loopstart]
	sub	eax,[ebx*4+sampleoffsetstart]
	shl16	eax
	add	edi,eax
	mov	FixIndicate,2
	call	DoFixSide2
	popad
	ret
DoFixSide2:
	movzx	eax,word ptr [esi]
	movzx	ebx,word ptr [edi]
	add	eax,ebx
	shr	eax,1
	mov	StartFix,eax
	xor	ebx,ebx
	mov	ecx,DoFixLoopSize
FixaLoopen2:
	push	ecx
	movzx	eax,word ptr [edi]
	sub	eax,StartFix
	mov	ecx,DoFixLoopSize
	sub	ecx,ebx
	imul	ecx
	mov	SaveFix,eax
	movzx	eax,word ptr [esi]
	sub	eax,StartFix
	mov	ecx,DoFixLoopSize
	add	ecx,ebx
	imul	ecx
	add	eax,SaveFix
	mov	ecx,DoFixLoopSize
	shl	ecx,1
	cdq
	idiv	ecx
	mov	ecx,StartFix
	add	ecx,eax
	mov	[ebp],cx
	inc	ebx
	add	ebp,FixIndicate
	add	esi,FixIndicate
	add	edi,FixIndicate
	pop	ecx
	loop	FixaLoopen2
	ret



	popad
	ret
FixIt	Endp



CheckIfShadow	Proc	Near
	pushad
	movzx	eax,CurrentInstrument
	GetOffset eax,ebx,ENV_Shadow
	cmp	byte ptr [ebx],0
	jz	_retp_clc
	lea	esi,samptext23
	mov	menu_popup,16
	call	popuphandler
	stc
	popad
	ret
CheckIfShadow	EndP

CheckIfShadow2	Proc	Near
	pushad
	movzx	eax,CurrentInstrument
	GetOffset eax,ebx,ENV_Shadow
	cmp	byte ptr [ebx],0
	jz	_retp_clc
	stc
	popad
	ret
CheckIfShadow2	EndP

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Make reverb
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;
;		 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;Input ÄÄÂÄÄÄÄÄÄÄ´  -D1- DELAY	     ³
;	 ³	 ÀÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÙ
;	 ³	ÚÄÄ´   ÚÄÄ´   ÚÄÄ´
;	 ³	³ ÚÁ¿  ³ ÚÁ¿  ³ ÚÁ¿
;	 ³	V4³D³  V4³D³  V4³D³
;	 ³	³ ³E³  ³ ³E³  ³ ³E³
;	 ³	ÀÄ´L³  ÀÄ´L³  ÀÄ´L³
;	 ³	  ³A³	 ³A³	³A³
;	 ³	D3³Y³  D3³Y³  D3³Y³ D3...
;	 ³	  ÀÂÙ	 ÀÂÙ	ÀÂÙ
;	 ³	   ³	  ³	 ³
;	 ³	   ³	  ³	 ³
;	 ³	   ³	  ³	 ³
;	 ³	   ÀÄÄÄÄÄÄÅÄÄÄÄÄÄÙ
;	 ³		  ³
;	 ³	       ÚÄÄ´
;	 V1	       ³ ÚÁ¿
;	 ³	       V3³D³
;	 ³	       ³ ³E³
;	 ³	       ÀÄ´L³
;	 ³		 ³A³
;	 ³	       D2³Y³
;	 ³		 ÀÂÙ
;	 ³		  ³
;	 ³		  ³
;	 ³		  ³
;	 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ OutPut
;
;
ReverbVol1		dd	5000	;0-10000
ReverbVol3		dd	4000	;0-10000
ReverbVol4		dd	3000	;0-10000
ReverbDelay1		dd	2000	 ;10-10000
ReverbDelay2		dd	4000	;10-10000
ReverbDelay3		dd	4000	 ;10-10000
ReverbNrOfComb		dd	4	;1-19
ReverbSampSize		dd	15000	;10-60000  (10000 = 100%)

DelayPointerStartList	dd	20 dup(0)
DelayPointerList	dd	20 dup(0)
ReverbMixValue		dd	0
ReverbOutValue		dd	0
ReverbNewSize		dd	0


MakeReverb	Proc	Near
	pushad

	cmp	sampbits,1
	jz	Do16Bits

	mov	eax,samplength		;new size
	mov	ebx,ReverbSampSize
	mul	ebx
	mov	ebx,10000
	div	ebx
	mov	ReverbNewSize,eax

					;alloc delaybuffers

	lea	edi,DelayPointerStartList
	xor	eax,eax
	mov	ecx,40
	rep	stosd
	mov	ebp,ReverbDelay2
	mov	ecx,ReverbNrOfComb
	xor	ebx,ebx
CombAllocLoop:
	mov	[DelayPointerStartList+4+ebx],ebp
	add	ebp,ReverbDelay3
	add	ebx,4
	loop	CombAllocLoop

	mov	eax,ebp
	shl	eax,1
	xor	ebx,ebx
	mov	ebp,1049
	call	memalloc
	jc      MakeReverbError

	call	saveundo		;Save undo

					;alloc sampbuff extra
	mov	eax,ReverbNewSize
	shl	eax,1
	xor	ebx,ebx
	mov	ebp,1051
	call	memalloc
	jc      MakeReverbError
					;clear samp buff
	mov	edi,[AllocTable+1051*8]
	mov	ecx,[AllocTable+1051*8+4]
	shr	ecx,1
	mov	ax,0
	rep	stosw
					;clear delay buffers
	mov	edi,[AllocTable+1049*8]
	mov	ecx,[AllocTable+1049*8+4]
	shr	ecx,1
	mov	ax,0
	rep	stosw
					;BIG REVERB LOOP
							   ;esi=sample
							   ;edi=new 16bits samp
	mov	ecx,ReverbNewSize
	mov	esi,[AllocTable+1024*8]
	mov	edi,[AllocTable+1051*8]
BigReverbLoop:
	push	ecx

	mov	edx,esi
	xor	ebp,ebp
	mov	ReverbMixValue,0
	mov	ecx,ReverbNrOfComb
InsertComFilter:				;fix combfilter
	push	ecx
	sub	edx,ReverbDelay1
	push	edx
	mov	ecx,[AllocTable+1024*8]
	cmp	edx,ecx
	jb	DoSilent
	add	ecx,SampLength
	cmp	edx,ecx
	jbe	NotOutSide
DoSilent:
	mov	eax,128
	jmp	AfterOutSide
NotOutside:
	movzx	eax,byte ptr [edx]
AfterOutside:
	add	al,128
	movsx	ebx,al
	sal	ebx,4
	mov	eax,ebx
	mov	ebx,[alloctable+1049*8]
	add	ebx,[DelayPointerStartList+4+ebp*4]
	add	ebx,[DelayPointerList+4+ebp*4]
	mov	ecx,ReverbDelay3
	sub	ecx,2
	cmp	ecx,[DelayPointerList+4+ebp*4]
	jz	DoEndBufferSpecial

	push	eax
	movsx	eax,word ptr [ebx+2]
	add	ReverbMixValue,eax
	mov	ecx,ReverbVol4
	imul	ecx
	mov	ecx,10000
	idiv	ecx
	pop	ecx

	push	eax
	mov	eax,ecx
	mov	ecx,10000
	sub	ecx,ReverbVol4
	;imul	 ecx
	mov	ecx,10000
	;idiv	 ecx
	pop	ecx

	add	eax,ecx
	mov	word ptr [ebx],ax
	add	[DelayPointerList+4+ebp*4],2
	jmp	AfterBufferSpecial
DoEndBufferSpecial:
	push	eax
	mov	ecx,[alloctable+1049*8]
	add	ecx,[DelayPointerStartList+4+ebp*4]
	movsx	eax,word ptr [ecx]
	add	ReverbMixValue,eax
	mov	ecx,ReverbVol4
	imul	ecx
	mov	ecx,10000
	idiv	ecx
	pop	ecx

	push	eax
	mov	eax,ecx
	mov	ecx,10000
	sub	ecx,ReverbVol4
	;imul	 ecx
	mov	ecx,10000
	;idiv	 ecx
	pop	ecx

	add	eax,ecx
	mov	word ptr [ebx],ax
	mov	[DelayPointerList+4+ebp*4],0
AfterBufferSpecial:

	inc	ebp
	pop	edx
	pop	ecx
	loop	InsertComFilter

						;Last delaybox & mix
	mov	eax,ReverbMixValue
	mov	ebx,ReverbNrOfComb
	cdq
	idiv	ebx

	mov	ebx,ReverbDelay2
	sub	ebx,2
	cmp	ebx,[DelayPointerList]
	jz	DoEndBufferSpecial2

	push	eax
	mov	ebx,[DelayPointerList]
	add	ebx,[alloctable+1049*8]
	movsx	eax,word ptr [ebx+2]
	mov	ReverbOutValue,eax
	mov	ecx,ReverbVol3
	imul	ecx
	mov	ecx,10000
	idiv	ecx
	pop	ecx

	push	eax
	mov	eax,ecx
	mov	ecx,10000
	sub	ecx,ReverbVol3
	;imul	 ecx
	mov	ecx,10000
	;idiv	 ecx
	pop	ecx

	add	eax,ecx
	mov	word ptr [ebx],ax
	add	[DelayPointerList],2
	jmp	AfterBufferSpecial2

DoEndBufferSpecial2:
	mov	ebx,[DelayPointerList]
	add	ebx,[alloctable+1049*8]
	push	eax
	mov	ecx,[alloctable+1049*8]
	movsx	eax,word ptr [ecx]
	mov	ReverbOutValue,eax
	mov	ecx,ReverbVol3
	imul	ecx
	mov	ecx,10000
	idiv	ecx
	pop	ecx

	push	eax
	mov	eax,ecx
	mov	ecx,10000
	sub	ecx,ReverbVol3
	;imul	 ecx
	mov	ecx,10000
	;idiv	 ecx
	pop	ecx

	add	eax,ecx
	mov	word ptr [ebx],ax
	mov	[DelayPointerList],0
AfterBufferSpecial2:
						;mix value
	mov	eax,[Alloctable+1024*8]
	cmp	esi,eax
	jb	DoSilent2
	add	eax,SampLength
	cmp	esi,eax
	jb	NoSilent2
DoSilent2:
	xor	eax,eax
	jmp	AfterSilent2
NoSilent2:
	mov	bl,byte ptr [esi]
	add	bl,128
	movsx	eax,bl
	sal	eax,4
	mov	ebx,ReverbVol1
	imul	ebx
	mov	ebx,10000
	idiv	ebx
AfterSilent2:

	push	eax
	mov	eax,ReverbOutValue
	mov	ebx,10000
	sub	ebx,ReverbVol1
	imul	ebx
	mov	ebx,10000
	idiv	ebx
	pop	ebx
	add	eax,ebx

	mov	[edi],ax
	add	edi,2
	inc	esi

	pop	ecx
	loop	BigReverbLoop



					;alloc samplength
	mov	eax,ReverbNewSize
	mov	samplength,eax
	call	allocsamplength
					;scale to samp
	mov	ecx,ReverbNewSize
	mov	edi,[AllocTable+1024*8]
	mov	esi,[AllocTable+1051*8]
MoveLoopenTest:
	mov	bx,word ptr [esi]
	sar	bx,4
	add	bl,128
	mov	byte ptr [edi],bl
	add	esi,2
	inc	edi
	loop	MoveLoopenTest

	jmp	MakeReverbEnd
Do16bits:			;------------- 16bits


MakeReverbEnd:
	xor	eax,eax
	mov	ebp,1051
	call	memalloc
	xor	eax,eax
	mov	ebp,1049
	call	memalloc

       	call	viewall2
       	call	updatesampletogus
	popad
	ret


MakeReverbError:
	xor	eax,eax
	xor	ebx,ebx
	mov	ebp,1051	;sampbuff extra
	call	memalloc
	xor	eax,eax
	xor	ebx,ebx
	mov	ebp,1049
	call	memalloc	;delay buffers
	jmp     NotEnoughHimem

MakeReverb	Endp





















