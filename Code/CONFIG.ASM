;/ABS\01212002210000100001000010000100001000010000101184


NrOfPaths	equ	23

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;				   Variables
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�


SaveConfigText	db	"Are you sure you want to save the configuration?$"

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;				 Config Save
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
; Calls: None
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
Configsave	Proc	Near
	pushad
	lea	esi,saveconfigtext
	mov	menu_popup,2
	call	popuphandler
	cmp	popupstatus,0
	jz	configsaveend
	call	saveconfig

configsaveend:
	popad
	ret
Configsave	Endp


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ConfigMaxCmdArrowUp:
	call	FixButton
	cmp	DefaultCommands,7
	jz	_ret
	inc	DefaultCommands
	jmp	SlobberySlime
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ConfigMaxChArrowUp:
	call	FixButton
	cmp	DefaultChannels,32
	jz	_ret
	inc	DefaultChannels
	jmp	SlobberySlime
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ConfigMaxRowArrowUp:
	call	FixButton
	cmp	DefaultRows,256
	jz	_ret
	inc	DefaultRows
	jmp	SlobberySlime
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ConfigMaxCmdArrowDn:
	call	FixButton
	cmp	DefaultCommands,1
	jz	_ret
	dec	DefaultCommands
	jmp	SlobberySlime
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ConfigMaxChArrowDn:
	call	FixButton
	cmp	DefaultChannels,1
	jz	_ret
	dec	DefaultChannels
	jmp	SlobberySlime
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ConfigMaxRowArrowDn:
	call	FixButton
	cmp	DefaultRows,1
	jz	_ret
	dec	DefaultRows

SlobberySlime:
	cli
	call	UpdatePattDefScreen
	call	AllocateEmptyPattern
	call	PrintPattInfo
	sti
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ConfigMaxCmdInput:
	mov	edi,85*80+312/8
	mov	ecx,1
	mov	ax,0111h
	lea	ebp,DefaultCommands
	movzx	ebx,DefaultCommands
	mov	DigitTarget,ebp
	mov	DigitSize,1
	mov	DigitLimit,7
	mov	DigitInput,15
	call	InputDigits
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ConfigMaxChInput:
	mov	edi,103*80+304/8
	mov	ecx,2
	mov	ax,0111h
	lea	ebp,DefaultChannels
	movzx	ebx,DefaultChannels
	mov	DigitTarget,ebp
	mov	DigitSize,1
	mov	DigitLimit,32
	mov	DigitInput,16
	call	InputDigits
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ConfigMaxRowInput:
	mov	edi,121*80+296/8
	mov	ecx,3
	mov	ax,0111h
	lea	ebp,DefaultRows
	movzx	ebx,DefaultRows
	mov	DigitTarget,ebp
	mov	DigitSize,2
	mov	DigitLimit,256
	mov	DigitInput,17
	call	InputDigits
	ret

ConfigMaxCmdUDrag:
	pushad
	mov	UdragStatus,1
	mov	ValueProPixel,1024/4
	mov	UdragMaxValue,7
	mov	UdragMiniValue,1
	lea	eax,DefaultCommands
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,1
	lea	eax,SlobberySlime
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret

ConfigMaxChUDrag:
	pushad
	mov	UdragStatus,1
	mov	ValueProPixel,1024
	mov	UdragMaxValue,32
	mov	UdragMiniValue,1
	lea	eax,DefaultChannels
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,1
	lea	eax,SlobberySlime
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret

ConfigMaxRowUDrag:
	pushad
	mov	UdragStatus,1
	mov	ValueProPixel,1024*2
	mov	UdragMaxValue,256
	mov	UdragMiniValue,1
	lea	eax,DefaultRows
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,2
	lea	eax,SlobberySlime
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret

PattDefStart:
	mov	Menu_popup,33
	call	MenuHandler
	ret

ViewPattDefPopup:
	lea	esi,PattDefPicture
	call	DrawPopup
	call	UpdatePattDefScreen
	ret

UpdatePattDefScreen	Proc	Near
	cmp	Menu_Popup,33
	jnz	_ret
	pushad
	mov	FontPlane,1
	call	mouseoff
	move	edi,0a0000h+85*80+312/8
	mov	ah,01h
	mov	cl,1
	movzx	ebx,DefaultCommands
	call	PutDecimal

	move	edi,0a0000h+103*80+304/8
	mov	ah,01h
	mov	cl,2
	movzx	ebx,DefaultChannels
	call	PutDecimal

	move	edi,0a0000h+121*80+296/8
	mov	ah,01h
	mov	cl,3
	movzx	ebx,DefaultRows
	cmp	RowsHexDec,1
	jz	PrintItHex
	call	PutDecimal
	jmp	DontPrintItHex
PrintItHex:
	call	PutHex
DontPrintItHex:
	mov	FontPlane,0
	call	mouseon
	popad
	ret
UpdatePattDefScreen	Endp



PutUpSCConfig:
	mov	Menu_popup,28
	call	MenuHandler
	ret

SC_Update:
	call	ButtonHandler
	cmp	eax,0
	jnz	_ret
	mov	menu_popup,0
	call	menuhandler

	lea	esi,RestartText
	mov	Menu_popup,2
	call	PopupHandler
	cmp	PopupStatus,0
	jz	_ret
	call	StopTimer
	mov	TuneStopped,1

	push	SoundCard
	push	SoundCard_BasePort
	push	SoundCard_BasePort2
	push	word ptr SoundCard_DMA1
	push	word ptr SoundCard_DMA2
	push	word ptr SoundCard_IRQ
	push	word ptr SoundCard_MIDIIRQ

	mov 	eax,NewSoundCard
	cmp	eax,5				;Only if GUS MAX
	jnz	@@NOMaxTransfer
	mov	bl,[SC_D1+eax]
	mov	[SC_D2+eax],bl
@@NOMaxTransfer:
	mov	SoundCard,eax
	mov	bx,[SC_BP+eax*2]
	mov	SoundCard_BasePort,bx

	mov	bx,[SC_BP2+eax*2]
	mov	SoundCard_BasePort2,bx

	mov	bl,[SC_D1+eax]
	mov	SoundCard_DMA1,bl
	mov	bl,[SC_D2+eax]
	mov	SoundCard_DMA2,bl
	mov	bl,[SC_I+eax]
	mov	SoundCard_IRQ,bl
	mov	bl,[SC_MI+eax]
	mov	SoundCard_MIDIIRQ,bl
	call	saveconfig

	pop	word ptr SoundCard_MIDIIRQ
	pop	word ptr SoundCard_IRQ
	pop	word ptr SoundCard_DMA2
	pop	word ptr SoundCard_DMA1
	pop	SoundCard_BasePort2
	pop	SoundCard_BasePort
	pop	SoundCard

	mov	ResetTracker,1
	jmp	QuickTrackerEnd


OldSoundCard	dw	0
NewSoundCard	dd	0
SoundCardSelect:
	pushad
	movzx	eax,MouseY
	sub	eax,93
	mov	ebx,14
	xor	edx,edx
	div	ebx
	cmp	eax,5			  ;# of supported cards
	ja	_retp
	cmp	ax,OldSoundCard
	jz	_retp
	mov	NewSoundCard,eax

	call	GetMaxHertz
	cmp	PlayFreq,ebx
	jbe	@@ThatsOkay
	mov	PlayFreq,ebx
@@ThatsOkay:

	mov	DrawSpecial,1
	mov	esi,NewSoundCard
	mov	esi,[SCInst+esi*4]
	call	Drawpopup
	call	UpdateSCScreen

	movzx	eax,OldSoundCard
	mov	bl,1
	call	SCButton

	mov	eax,NewSoundCard
	mov	OldSoundCard,ax
	mov	bl,0
	call	SCButton

	popad
	ret


SCinst	dd	NOSPicture,GUSPicture,SBPPicture,SB16Picture,SBPicture,MAXPicture,PNPPicture
ViewSoundCardPopup:
	pushad
	mov     eax,SoundCard
	mov	NewSoundCard,eax
	mov	OldSoundCard,ax
	lea	esi,SoundCardPicture
	call	Drawpopup
	mov	DrawSpecial,1
	mov	esi,NewSoundCard
	mov	esi,[SCInst+esi*4]
	call	Drawpopup
	mov	esi,NewSoundCard

	mov	bl,SB_StereoAllowed
	mov	[SC_But1+2],bl
	mov	[SC_But1+3],bl
	mov	bl,SB_16BitsAllowed
;	mov	[SC_But2+2],bl
	mov	[SC_But2+3],bl

	mov	bl,TimerSelect
	mov	[SC_But2+1],bl
	mov	[SC_But2+5],bl
	mov	[SC_But2+6],bl
	xor	bl,1
	mov	[SC_But1+1],bl
	mov	[SC_But1+5],bl
	mov	[SC_But1+6],bl

	mov	eax,NewSoundCard
	mov	bl,0
	call	SCButton
	mov	esi,NewSoundCard
	mov	ax,SoundCard_BasePort
	mov	[SC_BP+esi*2],ax
	mov	ax,SoundCard_BasePort2
	mov	[SC_BP2+esi*2],ax
	mov	al,SoundCard_DMA1
	mov	[SC_D1+esi],al
	mov	al,SoundCard_DMA2
	mov	[SC_D2+esi],al
	mov	al,SoundCard_IRQ
	mov	[SC_I+esi],al
	mov	al,SoundCard_MIDIIRQ
	mov	[SC_MI+esi],al
	call	UpdateSCScreen

	movzx	eax,Amplification
	sub	eax,16
	mov	[DragBarData+(13*4)*8+0],eax
	mov	[DragBarData+(13*4)*8+4],1
	popad
	ret

SCButton:
	mov	ButtonhandlerX1,136
	mov	ButtonhandlerY1,93
	mov	ButtonhandlerX2,148
	mov	ButtonhandlerY2,104
	mov	ecx,14
	mul	ecx
	add	ButtonhandlerY1,eax
	add	ButtonhandlerY2,eax
	call	MoveButtonCords
	call	ButtonUpDown
SCButton2:
	cmp	NewSoundCard,0
	jz 	_ret
	cmp	NewSoundCard,4
	jz 	_ret
	push	eax
	mov	ButtonX1,396
	mov	ButtonY1,93
	mov	ButtonX2,408
	mov	ButtonY2,104
	mov	eax,NewSoundCard
	mov	bl,[SC_But1+eax]
	xor	bl,1
	call	ButtonUpDown

	add	ButtonY1,14
	add	ButtonY2,14
	mov	bl,[SC_But2+eax]
	xor	bl,1
	pop	eax
	cmp	NewSoundCard,2
	jz	_ret
	call	ButtonUpDown
	ret

UpdateSCScreen:
	mov	FontPlane,1

	mov	esi,NewSoundCard
	mov	eax,[SC_UPD+esi*4]
	cmp	eax,0
	jz	@@SkipUPD
@@NextUpd:
	move	edi,0a0000h
	add	edi,[eax+4]
	mov	edx,[eax]
	cmp	edx,-1
	jz	@@SkipUPD
	pushad
	call	edx
	popad
	add	eax,8
	jmp	@@NextUpd

@@SkipUPD:
	mov	FontPlane,0
	ret



SC_PrintBase:
	mov	ah,01h
	mov	cl,3
	mov	esi,NewSoundCard
	movzx	ebx,[SC_BP+esi*2]
	call	PutHex
	ret

SC_PrintDMA1:
	mov	ah,01h
	mov	cl,3
	movzx	ebx,[SC_D1+esi]
	cmp	ebx,0
	jnz	@@PutValue
	push	esi
	lea	esi,Off+1
	call	PrintText
	pop	esi
	jmp	@@PutText
@@PutValue:
	call	PutHex
@@PutText:
	ret


SC_PrintFreq:
	mov	ah,01h
	mov	cl,5
	mov	ebx,PlayFreq
	call	PutDecimal
	ret

SC_PrintDMA2:
	mov	ah,01h
	mov	cl,3
	movzx	ebx,[SC_D2+esi]
	call	PutHex
	ret

SC_PrintIRQ:
	mov	ah,01h
	mov	cl,3
	movzx	ebx,[SC_I+esi]
	call	PutDecimal
	ret

SC_PrintIRQ2:
	mov	ah,01h
	mov	cl,3
	movzx	ebx,[SC_MI+esi]
	call	PutDecimal
	ret

SC_PrintBase2:
	mov	ah,01h
	mov	cl,3
	movzx	ebx,[SC_BP2+esi*2]
	call	PutHex
	ret


SelectMode3:
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,96	;Mode 1
	mov	ButtonY1,222
	mov	ButtonX2,109
	mov	ButtonY2,234
	mov	bl,1
	call	ButtonUpDown

	mov	ButtonX1,96	;Mode 2
	mov	ButtonY1,222+16
	mov	ButtonX2,109
	mov	ButtonY2,234+16
	mov	bl,1
	call	ButtonUpDown

	mov	ButtonX1,96	;Mode 3
	mov	ButtonY1,222+32
	mov	ButtonX2,109
	mov	ButtonY2,234+32
	mov	bl,0
	call	ButtonUpDown

	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	ret


		;NOS,GUS,SBP,SB16,SB,MAX,PNP
SC_BP	dw	0,0,0,0,0,0,0		;Base port
SC_D1	db	0,0,0,0,0,0,0		;DMA 1
SC_D2	db	0,0,0,0,0,0,0		;DMA 2
SC_I	db	0,0,0,0,0,0,0		;IRQ
SC_MI	db	0,0,0,0,0,0,0		;MIDI IRQ
SC_But1	db	0,0,0,0,0,0,0		;Upper button (timer, stereo etc)
SC_But2	db	0,0,0,0,0,0,0		;Lower Button
SC_BP2	dw	0,0,0,0,0,0,0		;Second BasePort (GUS MAX)


SCInfoTBL	dd	0,GUSInfo,SBPInfo,SB16Info,SBInfo,MAXInfo,PNPInfo

GUSInfo 	dd	GUS_BP,GUS_D1,GUS_D2,GUS_I,GUS_MI,0
SBPInfo 	dd	SBP_BP,SBP_D1,0,SBP_I,0
SB16Info	dd	SB16_BP,SB16_D1,SB16_D2,SB16_I,0
SBInfo		dd	SB_BP,SB_D1,0,SB_I,0
MAXInfo		dd	GUS_BP,GUS_D1,0,GUS_I,GUS_MI,GUS_16
PNPInfo		dd	PNP_BP,PNP_D1,0,PNP_I,PNP_MI,PNP_16

SC_UPD		dd	0,SC_UPD_GUS,SC_UPD_SBP,SC_UPD_SB16,SC_UPD_SB,SC_UPD_MAX,SC_UPD_PNP

SC_UPD_GUS	dd	SC_PrintBase, 80*93+320/8
		dd	SC_PrintDMA1, 80*111+320/8
		dd	SC_PrintDMA2, 80*129+320/8
		dd	SC_PrintIRQ,  80*147+320/8
		dd	SC_PrintIRQ2, 80*165+320/8
		dd	-1

SC_UPD_SBP	dd	SC_PrintBase, 80*93+320/8
		dd	SC_PrintDMA1, 80*111+320/8
		dd	SC_PrintIRQ,  80*129+320/8
		dd	SC_PrintFreq, 80*147+416/8
		dd	-1

SC_UPD_SB16	dd	SC_PrintBase, 80*93+320/8
		dd	SC_PrintDMA1, 80*111+320/8
		dd	SC_PrintDMA2, 80*129+320/8
		dd	SC_PrintIRQ,  80*147+320/8
		dd	SC_PrintFreq, 80*147+416/8
		dd	-1

SC_UPD_SB	dd	SC_PrintBase, 80*93+320/8
		dd	SC_PrintDMA1, 80*111+320/8
		dd	SC_PrintIRQ,  80*129+320/8
		dd	SC_PrintFreq, 80*147+416/8
		dd	-1

SC_UPD_MAX	dd	SC_PrintBase, 80*93+320/8
		dd	SC_PrintDMA1, 80*111+320/8
		dd	SC_PrintIRQ,  80*129+320/8
		dd	SC_PrintIRQ2, 80*147+320/8
		dd	SC_PrintBase2,80*165+320/8
		dd	-1

SC_UPD_PNP	dd	SC_PrintBase, 80*93+320/8
		dd	SC_PrintDMA1, 80*111+320/8
		dd	SC_PrintIRQ,  80*129+320/8
		dd	SC_PrintIRQ2, 80*147+320/8
		dd	SC_PrintBase2,80*165+320/8
		dd	-1


GUS_BP	dw	6, 210h,220h,230h,240h,250h,260h
GUS_D1	dw	6, 0,1,3,5,6,7
GUS_D2	dw	5, 1,3,5,6,7
GUS_I	dw	7, 2,3,5,7,11,12,15
GUS_MI	dw	7, 2,3,5,7,11,12,15
GUS_16	dw	16,30ch,31ch,32ch,33ch,34ch,35ch,36ch,37ch,38ch,39ch,3ach,3bch,3cch,3dch,3ech,3fch

SBP_BP	dw	2, 220h,240h
SBP_D1	dw	2, 1,3
;SBP_D2	dw	3, 5,6,7
SBP_I	dw	5, 2,3,5,7,10

SB16_BP dw	4, 220h,240h,260h,280h
SB16_D1 dw	2, 1,3
SB16_D2 dw	3, 5,6,7
SB16_I	dw	4, 2,5,7,10

SB_BP	dw	2, 220h,240h
SB_D1	dw	1, 1
SB_I	dw	5, 2,3,5,7,10

PNP_BP	dw	1, 0
PNP_D1	dw	2, 0,0
PNP_I	dw	1, 0
PNP_MI	dw	1, 0
PNP_16	dw	1, 0

SC_ArrUp_Butt	dd	0,SC_Arrup_GUS,SC_Arrup_SBP,SC_Arrup_SB16,SC_Arrup_SB,SC_Arrup_MAX,SC_Arrup_PNP
SC_UDrag_Butt	dd	0,SC_UDrag_GUS,SC_UDrag_SBP,SC_UDrag_SB16,SC_UDrag_SB,SC_UDrag_MAX,SC_UDrag_PNP
SC_ArrDn_Butt	dd	0,SC_ArrDn_GUS,SC_ArrDn_SBP,SC_ArrDn_SB16,SC_ArrDn_SB,SC_ArrDn_MAX,SC_ArrDn_PNP

SC_Arrup_GUS	dd	SC_PortArrUp
		dd	SC_DMA1ArrUp
		dd	SC_DMA2ArrUp
		dd	SC_IRQArrUp
		dd	SC_MIDIIRQArrUp
		dd	-1

SC_Arrup_SBP	dd	SC_PortArrUp
		dd	SC_DMA1ArrUp
		dd	SC_IRQArrUp
		dd	-1

SC_Arrup_SB16	dd	SC_PortArrUp
		dd	SC_DMA1ArrUp
		dd	SC_DMA2ArrUp
		dd	SC_IRQArrUp
		dd	-1

SC_Arrup_SB	dd	SC_PortArrUp
		dd	SC_DMA1ArrUp
		dd	SC_IRQArrUp
		dd	-1

SC_Arrup_MAX	dd	SC_PortArrUp
		dd	SC_DMA1ArrUp
		dd	SC_IRQArrUp
		dd	SC_MIDIIRQArrUp
		dd	SC_Port2ArrUp
		dd	-1

SC_Arrup_PNP	dd	_ret
		dd	SC_DMA1ArrUp
		dd	_ret
		dd	_ret
		dd	_ret
		dd	-1

;--------------------
SC_UDrag_GUS	dd	SC_PortUDrag
		dd	SC_DMA1UDrag
		dd	SC_DMA2UDrag
		dd	SC_IRQUDrag
		dd	SC_MIDIIRQUDrag
		dd	-1

SC_UDrag_SBP	dd	SC_PortUDrag
		dd	SC_DMA1UDrag
		dd	SC_IRQUDrag
		dd	-1

SC_UDrag_SB16	dd	SC_PortUDrag
		dd	SC_DMA1UDrag
		dd	SC_DMA2UDrag
		dd	SC_IRQUDrag
		dd	-1

SC_UDrag_SB	dd	SC_PortUDrag
		dd	SC_DMA1UDrag
		dd	SC_IRQUDrag
		dd	-1

SC_UDrag_MAX	dd	SC_PortUDrag
		dd	SC_DMA1UDrag
		dd	SC_IRQUDrag
		dd	SC_MIDIIRQUDrag
		dd	SC_Port2UDrag
		dd	-1

SC_UDrag_PNP	dd	_ret
		dd	SC_DMA1UDrag
		dd	_ret
		dd	_ret
		dd	_ret
		dd	-1
;--------------------
SC_ArrDn_GUS	dd	SC_PortArrDn
		dd	SC_DMA1ArrDn
		dd	SC_DMA2ArrDn
		dd	SC_IRQArrDn
		dd	SC_MIDIIRQArrDn
		dd	-1

SC_ArrDn_SBP	dd	SC_PortArrDn
		dd	SC_DMA1ArrDn
		dd	SC_IRQArrDn
		dd	-1

SC_ArrDn_SB16	dd	SC_PortArrDn
		dd	SC_DMA1ArrDn
		dd	SC_DMA2ArrDn
		dd	SC_IRQArrDn
		dd	-1

SC_ArrDn_SB	dd	SC_PortArrDn
		dd	SC_DMA1ArrDn
		dd	SC_IRQArrDn
		dd	-1

SC_ArrDn_MAX	dd	SC_PortArrDn
		dd	SC_DMA1ArrDn
		dd	SC_IRQArrDn
		dd	SC_MIDIIRQArrDn
		dd	SC_Port2ArrDn
		dd	-1

SC_ArrDn_PNP	dd	_ret
		dd	SC_DMA1ArrDn
		dd	_ret
		dd	_ret
		dd	_ret
		dd	-1

SC_ArrUp:
	mov	esi,NewSoundCard
	mov	esi,[SC_ArrUp_Butt+esi*4]
	jmp	JumpIt
SC_UDrag:
	mov	esi,NewSoundCard
	mov	esi,[SC_UDrag_Butt+esi*4]
	jmp	JumpIt
SC_ArrDn:
	mov	esi,NewSoundCard
	mov	esi,[SC_ArrDn_Butt+esi*4]

JumpIt:
	cmp	esi,0
	jz	_ret
	mov	ButtonhandlerY1,90
	mov	ButtonhandlerY2,106
	movzx	eax,MouseY
	sub	eax,90
	mov	ebx,18
	xor	edx,edx
	div	ebx
	push	eax
	mov	ebx,18
	mul	ebx
	add	ButtonhandlerY1,eax
	add	ButtonhandlerY2,eax
	pop	edx
	xor	ebx,ebx
@@Nxt:
	lodsd
	cmp	eax,-1
	jz	_ret
	cmp	ebx,edx
	jnz	@@Skip
	call	eax
	ret
@@Skip:
	inc	ebx
	jmp	@@Nxt

SC_Butt_Butt1	dd	_ret,PCTimerSel,ToggleStereo,ToggleStereo,_ret,PCTimerSel,PCTimerSel
SC_Butt_Butt2	dd	_ret,GUSTimerSel,_ret,Toggle16bits,_ret,GUSTimerSel,GUSTimerSel

SC_Button1:
	mov	esi,NewSoundCard
	mov	esi,[SC_Butt_Butt1+esi*4]
	jmp	esi

SC_Button2:
	mov	esi,NewSoundCard
	mov	esi,[SC_Butt_Butt2+esi*4]
	jmp	esi


SC_PortArrUp:
	call	Fixbutton
	mov	ebp,NewSoundCard
	mov	ax,[SC_BP+ebp*2]
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+0*4]
	call	SearchSCTBL

	cmp	di,[esi]
	jz	_ret
	mov	ax,[esi+edi*2+2]
	mov	[SC_BP+ebp*2],ax
	call	UpdateSCScreen
	ret

SC_PortUDrag:
	mov	UdragStatus,1
	mov	ValueProPixel,1024/4
	mov	ebp,NewSoundCard
	mov	ax,[SC_BP+ebp*2]
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+0*4]		;!
	call	SearchSCTBL

	mov	TempDword,edi
	movzx	eax,word ptr [esi]
	mov	UdragMaxValue,eax
	mov	UdragMiniValue,1
	lea	eax,TempDword
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,SC_PortUDragMeanwhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	ret

SC_PortUDragMeanwhile:
	pushad
	mov	ebp,NewSoundCard
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+0*4]
	mov	eax,TempDword
	mov	ax,[esi+eax*2]
	mov	[SC_BP+ebp*2],ax
	call	UpdateSCScreen
	popad
	ret

SC_PortArrDn:
	call	Fixbutton
	mov	ebp,NewSoundCard
	mov	ax,[SC_BP+ebp*2]
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+0*4]
	call	SearchSCTBL
	cmp	di,1
	jz	_ret
	mov	ax,[esi+edi*2-2]
	mov	[SC_BP+ebp*2],ax
	call	UpdateSCScreen
	ret


SC_Port2ArrUp:
	call	Fixbutton
	mov	ebp,NewSoundCard
	mov	ax,[SC_BP2+ebp*2]
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+5*4]
	call	SearchSCTBL

	cmp	di,[esi]
	jz	_ret
	mov	ax,[esi+edi*2+2]
	mov	[SC_BP2+ebp*2],ax
	call	UpdateSCScreen
	ret

SC_Port2UDrag:
	mov	UdragStatus,1
	mov	ValueProPixel,1024/4
	mov	ebp,NewSoundCard
	mov	ax,[SC_BP2+ebp*2]
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+5*4]		;!
	call	SearchSCTBL

	mov	TempDword,edi
	movzx	eax,word ptr [esi]
	mov	UdragMaxValue,eax
	mov	UdragMiniValue,1
	lea	eax,TempDword
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,SC_Port2UDragMeanwhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	ret

SC_Port2ArrDn:
	call	Fixbutton
	mov	ebp,NewSoundCard
	mov	ax,[SC_BP2+ebp*2]
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+5*4]
	call	SearchSCTBL
	cmp	di,1
	jz	_ret
	mov	ax,[esi+edi*2-2]
	mov	[SC_BP2+ebp*2],ax
	call	UpdateSCScreen
	ret



SC_Port2UDragMeanwhile:
	pushad
	mov	ebp,NewSoundCard
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+5*4]
	mov	eax,TempDword
	mov	ax,[esi+eax*2]
	mov	[SC_BP2+ebp*2],ax
	call	UpdateSCScreen
	popad
	ret

SC_DMA1ArrUp:
	call	Fixbutton
	mov	ebp,NewSoundCard
	movzx	ax,[SC_D1+ebp]
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+1*4]
	call	SearchSCTBL
	cmp	di,[esi]
	jz	_ret
	mov	ax,[esi+edi*2+2]
	mov	[SC_D1+ebp],al
	cmp	al,0
	setnz	al
	mov	DMAOnOff,al
	call	UpdateSCScreen
	ret
SC_DMA1UDrag:
	mov	UdragStatus,1
	mov	ValueProPixel,1024/4
	mov	ebp,NewSoundCard
	movzx	ax,[SC_D1+ebp]			;!
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+1*4]			;!
	call	SearchSCTBL

	mov	TempDword,edi
	movzx	eax,word ptr [esi]
	mov	UdragMaxValue,eax
	mov	UdragMiniValue,1
	lea	eax,TempDword
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,SC_DMA1UDragMeanwhile	;!
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	ret

SC_DMA1UDragMeanwhile:				;!
	pushad
	mov	ebp,NewSoundCard
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+1*4]			;!
	mov	eax,TempDword
	mov	ax,[esi+eax*2]
	mov	[SC_D1+ebp],al			;!
	cmp	al,0
	setnz	al
	mov	DMAOnOff,al
	call	UpdateSCScreen
	popad
	ret
SC_DMA1ArrDn:
	call	Fixbutton
	mov	ebp,NewSoundCard
	movzx	ax,[SC_D1+ebp]
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+1*4]
	call	SearchSCTBL
	cmp	di,1
	jz	_ret
	mov	ax,[esi+edi*2-2]
	mov	[SC_D1+ebp],al
	cmp	al,0
	setnz	al
	mov	DMAOnOff,al
	call	UpdateSCScreen
	ret

SC_DMA2ArrUp:
	call	Fixbutton
	mov	ebp,NewSoundCard
	movzx	ax,[SC_D2+ebp]
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+2*4]
	call	SearchSCTBL
	cmp	di,[esi]
	jz	_ret
	mov	ax,[esi+edi*2+2]
	mov	[SC_D2+ebp],al
	call	UpdateSCScreen
	ret
SC_DMA2UDrag:
	mov	UdragStatus,1
	mov	ValueProPixel,1024/4
	mov	ebp,NewSoundCard
	movzx	ax,[SC_D2+ebp]			;!
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+2*4]			;!
	call	SearchSCTBL

	mov	TempDword,edi
	movzx	eax,word ptr [esi]
	mov	UdragMaxValue,eax
	mov	UdragMiniValue,1
	lea	eax,TempDword
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,SC_DMA2UDragMeanwhile	;!
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	ret

SC_DMA2UDragMeanwhile:				;!
	pushad
	mov	ebp,NewSoundCard
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+2*4]			;!
	mov	eax,TempDword
	mov	ax,[esi+eax*2]
	mov	[SC_D2+ebp],al			;!
	call	UpdateSCScreen
	popad
	ret
SC_DMA2ArrDn:
	call	Fixbutton
	mov	ebp,NewSoundCard
	movzx	ax,[SC_D2+ebp]
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+2*4]
	call	SearchSCTBL
	cmp	di,1
	jz	_ret
	mov	ax,[esi+edi*2-2]
	mov	[SC_D2+ebp],al
	call	UpdateSCScreen
	ret

SC_IRQArrUp:
	call	Fixbutton
	mov	ebp,NewSoundCard
	movzx	ax,[SC_I+ebp]
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+3*4]
	call	SearchSCTBL
	cmp	di,[esi]
	jz	_ret
	mov	ax,[esi+edi*2+2]
	mov	[SC_I+ebp],al
	call	UpdateSCScreen
	ret
SC_IRQUDrag:
	mov	UdragStatus,1
	mov	ValueProPixel,1024/4
	mov	ebp,NewSoundCard
	movzx	ax,[SC_I+ebp]			;!
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+3*4]			;!
	call	SearchSCTBL

	mov	TempDword,edi
	movzx	eax,word ptr [esi]
	mov	UdragMaxValue,eax
	mov	UdragMiniValue,1
	lea	eax,TempDword
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,SC_IRQUDragMeanwhile	;!
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	ret

SC_IRQUDragMeanwhile:				;!
	pushad
	mov	ebp,NewSoundCard
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+3*4]			;!
	mov	eax,TempDword
	mov	ax,[esi+eax*2]
	mov	[SC_I+ebp],al			;!
	call	UpdateSCScreen
	popad
	ret

SC_IRQArrDn:
	call	Fixbutton
	mov	ebp,NewSoundCard
	movzx	ax,[SC_I+ebp]
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+3*4]
	call	SearchSCTBL
	cmp	di,1
	jz	_ret
	mov	ax,[esi+edi*2-2]
	mov	[SC_I+ebp],al
	call	UpdateSCScreen
	ret


SC_MIDIIRQArrUp:
	call	Fixbutton
	mov	ebp,NewSoundCard
	movzx	ax,[SC_MI+ebp]
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+4*4]
	call	SearchSCTBL
	cmp	di,[esi]
	jz	_ret
	mov	ax,[esi+edi*2+2]
	mov	[SC_MI+ebp],al
	call	UpdateSCScreen
	ret
SC_MIDIIRQUDrag:
	mov	UdragStatus,1
	mov	ValueProPixel,1024/4
	mov	ebp,NewSoundCard
	movzx	ax,[SC_MI+ebp]			;!
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+4*4]			;!
	call	SearchSCTBL

	mov	TempDword,edi
	movzx	eax,word ptr [esi]
	mov	UdragMaxValue,eax
	mov	UdragMiniValue,1
	lea	eax,TempDword
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,SC_MIDIIRQUDragMeanwhile	;!
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	ret

SC_MIDIIRQUDragMeanwhile:			;!
	pushad
	mov	ebp,NewSoundCard
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+4*4]			;!
	mov	eax,TempDword
	mov	ax,[esi+eax*2]
	mov	[SC_MI+ebp],al			;!
	call	UpdateSCScreen
	popad
	ret
SC_MIDIIRQArrDn:
	call	Fixbutton
	mov	ebp,NewSoundCard
	movzx	ax,[SC_MI+ebp]
	mov	esi,[SCInfoTBL+ebp*4]
	mov	esi,[esi+4*4]
	call	SearchSCTBL
	cmp	di,1
	jz	_ret
	mov	ax,[esi+edi*2-2]
	mov	[SC_MI+ebp],al
	call	UpdateSCScreen
	ret

GUSTimerSel:
	cmp	TimerSelect,1
	jz	_ret
	mov	TimerSelect,1
	push	eax
	mov	eax,NewSoundCard
	mov	[SC_But1+eax],0
	mov	[SC_But2+eax],1
	pop	eax
	jmp	SkipSett
PCTimerSel:
	cmp	TimerSelect,0
	jz	_ret
	mov	TimerSelect,0
	push	eax
	mov	eax,NewSoundCard
	mov	[SC_But1+eax],1
	mov	[SC_But2+eax],0
	pop	eax
SkipSett:
	cli
	call	StopTimer
	call	StartTimer
	sti
	call	SCButton2
	ret

Toggle16bits:
	pushad
	mov	eax,NewSoundCard
	xor	[SC_But2+eax],1
	mov	bl,[SC_But2+eax]
	mov	SB_16BitsAllowed,bl
	call	SCButton2
	mov	esi,NewSoundCard
	call	SC_ChangeReplay
	popad
	ret

ToggleStereo:
	pushad
	mov	eax,NewSoundCard
	xor	[SC_But1+eax],1
	mov	bl,[SC_But1+eax]
	mov	SB_StereoAllowed,bl
	call	SCButton2

	mov	eax,NewSoundCard
	call	GetMaxHertz
	cmp	PlayFreq,ebx
	jbe	@@ThatsOkay
	mov	PlayFreq,ebx
	call    UpdateSCScreen
@@ThatsOkay:
	mov	esi,NewSoundCard
	call	SC_ChangeReplay
	popad
	ret

;in : esi=ptr to search-table
;   : ax= value to search for
;out: edi=Pos in table
SearchSCTBL:
	push	esi
	movzx	ecx,word ptr [esi]
	xor	edi,edi
;	cmp	ax,0
;	jz	GetSCFirst
SearchSCAgain:
	add	esi,2
	inc	edi
	cmp	[esi],ax
	loopnz	SearchSCAgain
	jz	GetSCFirst
	xor	edi,edi
GetSCFirst:
	pop	esi
	ret


SC_HertzArrUp:
	cmp	NewSoundCard,0
	jz	_ret
	call	fixbutton
	mov	eax,NewSoundCard
	call	GetMaxHertz
	mov	eax,PlayFreq
	add	eax,100
	cmp	eax,ebx
	jbe	ThatsOkay
	mov	eax,ebx
ThatsOkay:
	mov	PlayFreq,eax
	call    UpdateSCScreen
ThatsOkay2:
	mov	esi,NewSoundCard
	call	SC_ChangeReplay
	ret

SC_HertzUDrag:
	cmp	NewSoundCard,0
	jz	_ret
	pushad
	mov	UdragStatus,1
	mov	ValueProPixel,1024*500
	mov	eax,NewSoundCard
	call	GetMaxHertz
	mov	UdragMaxValue,ebx
	mov	UdragMiniValue,5000
	lea	eax,PlayFreq
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,UpdateSCScreen
	mov	UdragMeanWhile,eax
	lea	eax,ThatsOkay2
	mov	UdragAfter,eax
	call	ButtonHandler
	popad
	ret

SC_HertzArrDn:
	cmp	NewSoundCard,0
	jz	_ret
	call	FixButton
	mov	eax,PlayFreq
	sub	eax,100
	cmp     eax,5000
	jae	ThatsOkay
	mov	eax,5000
	jmp	ThatsOkay

SC_HertzInput:
	cmp	NewSoundCard,0
	jz	_ret
	mov	edi,147*80+416/8
	mov	ecx,5
	lea	ebp,PlayFreq
	mov	DigitTarget,ebp
	mov	DigitSize,3
	mov	eax,NewSoundCard
	call	GetMaxHertz
	mov	DigitLimit,ebx
	mov	ebx,PlayFreq
	mov	DigitInput,18
	mov	ax,0111h
	call	InputDigits
	ret

ConfigPathStart:
	mov	Menu_popup,36
	call	MenuHandler
	ret

ViewConfigPaths:
	lea	esi,ConfigPathPicture
	call	DrawPopup
UpdateCP:
	mov	DrawSpecial,1
	mov	esi,CPCurrentType
	mov	esi,[CPTBL+esi*4]
	call	DrawPopup
	call	UpdatePathScreen
	ret

CPTBL		dd	ConfigPathSong,ConfigPathInst,ConfigPathSamp,ConfigPathPatt
OCPCurrentType	dd	0
CPCurrentType	dd	0
CPCurrentPath	dd	0

CPPathBuffer	db	67*NrOfPaths	dup(0)		;Nr of paths

CPTBL0	dd	CPTBL1,CPTBL2,CPTBL3,CPTBL4
CPTBL1	db	1,2,5,7,10,21,22,13		;Path Numbers
CPTBL2	db	9,8,12,14
CPTBL3	db	20,3,11,4,6,15
CPTBL4	db	17,18,19,16

CPMax		db	8,4,6,4			;Max nr of paths

CPChoice:
	movzx	eax,MouseY
	sub	eax,77
	xor	edx,edx
	mov	ebx,17
	div	ebx
	cmp	eax,OCPCurrentType
	jz	_ret
	mov	CPCurrentType,eax
	jmp	UpdateCP

CPPath:
	movzx	eax,MouseY
	sub	eax,74
	xor	edx,edx
	mov	ebx,18
	div	ebx
	mov	ebx,CPCurrentType
	cmp	al,[CPMax+ebx]
	jae	_ret
	mov	CPCurrentPath,eax
	mov	ebx,18
	mul	ebx
;	push	ButtonhandlerX1
;	push	ButtonhandlerY1
;	push	ButtonhandlerX2
;	push	ButtonhandlerY2
	mov	ButtonhandlerX1,269
	mov	ButtonhandlerY1,74
	mov	ButtonhandlerX2,297
	mov	ButtonhandlerY2,90
	add	ButtonhandlerY1,eax
	add	ButtonhandlerY2,eax
	call	fixbutton
;	pop	ButtonhandlerY2
;	pop	ButtonhandlerX2
;	pop	ButtonhandlerY1
;	pop	ButtonhandlerX1

	mov	eax,CPCurrentType
	mov	eax,[CPTBL0+eax*4]
	add	eax,CPCurrentPath
	movzx	eax,byte ptr [eax]
	mov	esi,[CurrPathTable+eax*4]
	mov	ebx,67
	mul	ebx
	lea	edi,CPPathBuffer
	add	edi,eax
	mov	ecx,67

	push	ecx edi
	xor	al,al
	rep	stosb
	pop	edi ecx
@@PLoop:
	cmp	byte ptr [esi+ecx-1],'\'
	jz	FoundPath
	loop	@@PLoop
FoundPath:
	rep	movsb
	jmp	UpdatePathScreen

UpdatePathScreen:
	mov	eax,OCPCurrentType
	mov	ebx,17
	mul	ebx
	mov	ButtonX1,192
	mov	ButtonX2,204
	mov	ButtonY1,77
	mov	ButtonY2,88
	add     ButtonY1,eax
	add     ButtonY2,eax
	mov	bl,1
	call	ButtonUpDown

	mov	eax,CPCurrentType
	mov	OCPCurrentType,eax
	mov	ebx,17
	mul	ebx
	mov	ButtonX1,192
	mov	ButtonX2,204
	mov	ButtonY1,77
	mov	ButtonY2,88
	add     ButtonY1,eax
	add     ButtonY2,eax
	mov	bl,0
	call	ButtonUpDown

	call	mouseoff
	mov	FontPlane,1
	mov	eax,CPCurrentType
	movzx	ecx,[CPMax+eax]
	mov	ebp,[CPTBL0+eax*4]
	move	edi,0a0000h+(77*80)+304/8
@@Bxt:
	push	ecx
	mov	cl,16
	movzx	esi,byte ptr [ebp]
	mov	eax,67
	mul	esi
	lea	esi,CPPathBuffer
	add	esi,eax

	mov	ah,1h
	call	printtext
	inc	ebp
	add	edi,18*80
	pop	ecx
	loop	@@Bxt
	mov	FontPlane,0
	call	mouseon
	ret



CPInput:
	movzx	eax,MouseY
	sub	eax,74
	mov	ebx,18
	xor	edx,edx
	div	ebx
	mov	ebx,CPCurrentType
	cmp	al,[CPMax+ebx]
	jae	_ret

	mov	ebx,[CPTBL0+ebx*4]
	add	ebx,eax
	mov	ebp,eax
	movzx	eax,byte ptr [ebx]
	mov	ebx,67
	mul	ebx
	lea	esi,CPPathBuffer
	add	esi,eax

	mov	eax,ebp
	mov	ebx,18*80
	mul	ebx
	mov	edi,77*80+304/8
	add	edi,eax

	mov	ecx,16
	mov	ax,0113h
	mov	InputVirtMax,67
	call	InputRoutine
	ret

CPUpdatePaths	Proc	Near
	pushad
	lea	esi,CPPathBuffer
	mov	ebp,0
	mov	ecx,NrOfPaths
@@Loop:
	cmp	byte ptr [esi],0
	jz	@@Nope
	cmp	byte ptr [esi+1],':'
	jnz	@@Nope
	cmp	byte ptr [esi+2],'\'
	jnz	@@Nope

	mov	edi,[CurrPathTable+ebp*4]
	pushad
	mov	ecx,67
@@Loop2:
	lodsb
	cmp	al,0
	jnz	@@NoEnd
	cmp	byte ptr [esi-2],'\'
	jz	@@AllEnd
	mov	al,'\'
	stosb
	jmp	@@AllEnd
@@NoEnd:
	stosb
	loop	@@Loop2
@@AllEnd:
	popad
@@Nope:
	add	esi,67
	inc	ebp
	loop	@@Loop

	popad
	ret
CPUpdatePaths	EndP


RemovePathSpaces:
	pushad
	lea	esi,CPPathBuffer
	mov	ecx,NrOfPaths
@@RemoveSpace:
	push	ecx

	mov	ecx,67
@@Removeit:
	lodsb
	cmp	al,' '
	jnz	@@NoSpace
	dec	esi
	mov	edi,esi
	xor	al,al
	rep	stosb
	inc	ecx
@@NoSpace:
	loop	@@Removeit

	pop	ecx
	loop	@@RemoveSpace
	popad
	ret

CP_Exit:				;popup okay (Mouse)
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	call	RemovePathSpaces
	mov	PopOk,0
	mov	menu_popup,0
	call	menuhandler
	Popad
	Ret

