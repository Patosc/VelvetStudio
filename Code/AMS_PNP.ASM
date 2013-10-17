



;/ABS\01046020010207000007000070000700007020700207001415

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� PNP Stuff 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 Tables 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�



;#######################################################################
;
;   IRQ Data Structure Type. This type holds information
;   relevant to each IRQ channel in the PICs.
;
;#######################################################################
IRQ	STRUC
	imask		db	0	;Mask for particular channel
	ispec_eoi	db	0	;Specific End of Interrupt
	iocr		db	0	;Operation Cmd Register Address
	iimr		db	0	;0x21 for master, 0xA1 for slave
IRQ	ENDS

;#######################################################################
;   DMA Data Structure Type. This type holds data relevant to
;   DMA transfers between the InterWave and the PC.
;#######################################################################
DMA	STRUC
	iflags		dw	0	;status pending DMA requests
	ipage		dw	0	;page port location
	iaddr     	dw	0	;addr port location
	icount    	dw	0	;count port location
	isingle		dw	0	;single mode port location
	imode     	dw	0	;mode port location
	iclear_ff 	dw	0	;clear flip-flop port location
	idisable  	db	0	;bits to disable dma channel
	ienable   	db	0	;bits to enable dma channel
	iwrite    	db	0	;bits for write transfer
	iread     	db	0	;bits for read transfer
	icur_mode 	db	0	;current mode
	icur_page 	dw	0	;current page of transfer
	icur_addr 	dw	0	;current transfer address
	iamnt_sent	dw	0	;current amnt sent
	icur_size 	dw	0	;size of current transfer
	inxt_page 	dw	0	;next page
	inxt_addr 	dw	0	;next address
	inxt_size 	dw	0	;size of next buffer
	icur_control	db	0	;applies to InterWave's DMA Ctrl Reg
	ichannel  	db	0	;DMA channel number
	itype     	db	0	;Type of DMA transfer
	ipcram    	dd	0	;Address of Data in PC RAM
	ilocal    	dd	0	;Address of Data in LM
DMA	ENDS
TimerRate	dw	0

;#######################################################################
;
;	IWAVE Type. This type holds information about the configuration
;	and operation modes of the InterWave hardware.
;
;#######################################################################
Iwave STRUC
	flags		dw	0	;InterWave stat flags
	pcodar		dw	0	;Base Port for Codec
	pcdrar		dw	0	;Base Port for Ext Device
	p2xr		dw	0	;Compatibility Base Port
	p3xr		dw	0	;MIDI and Synth Base Port
	p401ar		dw	0	;Gen Purpose Reg. 1 address
	p201ar		dw	0	;Game Ctrl normally at 0x201
	pataar		dw	0	;Base Address for ATAPI I/O Space
	p388ar		dw	0	;Base Port for AdLib. It should be 388h
	pnprdp		dw	0	;PNP read data port
	igidxr		dw	0	;Gen Index Reg at P3XR+0x03
	i16dp		dw	0	;16-bit data port at P3XR+0x04
	i8dp		dw	0	;8-bit data port at P3XR+0x05
	svsr		dw	0	;Synth Voice Select at P3XR+0x02
	cdatap		dw	0	;Codec Indexed Data Port at PCODAR+0x01
	csr1r		dw	0	;Codec Stat Reg 1 at PCODAR+0x02
	cxdr		dw	0	;Play or Record Data Reg at PCODAR+0x03
	gmxr		dw	0	;GMCR or GMSR at P3XR+0x00
	gmxdr		dw	0	;GMTDR or GMRDR at P3XR+0x01
	lmbdr		dw	0	;LMBDR at P3XR+0x07
	csn		db	0	;Card Select Number
	cmode		db	0	;Codec Operation Mode
	dma1_chan	dw	0	;DMA channel 1 (local DMA & codec rec)
	dma2_chan	dw	0	;DMA channel 2 (codec play)
	ext_chan	dw	0	;Ext Dev DMA channel
	voices		db	0	;Number of active voices
	vendor		dd 	0	;Vendor ID and Product Identifier
	dma1		db	0	;Chan 1 DMA structure 			***** !!!
	dma2		db	0	;Chan 2 DMA structure                   ***** !!!
	ext_dma		db	0	;Pointer to Ext Dev Chan DMA structure  ***** !!!
	synth_irq	dw 	0	;Synth IRQ number
	midi_irq	dw 	0	;MIDI IRQ number
	ext_irq		dw	0	;Ext Dev IRQ
	mpu_irq		dw	0	;MPU401 Dev IRQ
	emul_irq	dw	0	;Sound Blaster/AdLib Dev IRQ
	synth		db	0	;Pointer to Synth IRQ structure         ***** !!!
	midi		db	0	;Pointer to MIDI IRQ structure          ***** !!!
	ext		db	0	;Pointer to Ext Dev IRQ structure       ***** !!!
	free_mem	dd	0	;Address of First Free LM Block
	reserved_mem	dd	0	;Amount of LM reserved by app.
	smode		db	0	;Synth Mode
	size_mem	dd	0	;Total LM in Kbytes
	old_synth_rvec	dd 	0
	old_midi_rvec	dd	0
	old_synth_vec	dd	0	;Old Synth Interrupt Address
	old_midi_vec	dd	0	;Old MIDI Interrupt Vector
	midi_xmit_func	dd	0
	midi_rcv_func	dd	0
	timer1_func	dd	0
	timer2_func	dd	0
	wavetable_func	dd	0
	volume_func	dd	0
	play_dma_func	dd	0
	rec_dma_func	dd	0
	ext_dma_func	dd	0
	codec_timer_func dd	0
	codec_play_func	dd	0
	codec_rec_func	dd	0
IWAVE	ENDS


;#######################################################################
;
;   IRQ Data
;
;#######################################################################
IW_IRQ1	IRQ <0,\			;Mask for particular channel
	0,\			;Specific End of Interrupt
	0,\			;Operation Cmd Register Address
	0>			;0x21 for master, 0xA1 for slave

IW_IRQ2	IRQ <0,\			;Mask for particular channel
	0,\			;Specific End of Interrupt
	0,\			;Operation Cmd Register Address
	0>			;0x21 for master, 0xA1 for slave


;#######################################################################
;   DMA Data Structure Type.
;#######################################################################
IW_DMA1	DMA <0,\		;status pending DMA requests
	0,\			;page port location
	0,\			;addr port location
	0,\			;count port location
	0,\			;single mode port location
	0,\			;mode port location
	0,\			;clear flip-flop port location
	0,\			;bits to disable dma channel
	0,\			;bits to enable dma channel
	0,\			;bits for write transfer
	0,\			;bits for read transfer
	0,\			;current mode
	0,\			;current page of transfer
	0,\			;current transfer address
	0,\			;current amnt sent
	0,\			;size of current transfer
	0,\			;next page
	0,\			;next address
	0,\			;size of next buffer
	0,\			;applies to InterWave's DMA Ctrl Reg
	0,\			;DMA channel number
	0,\			;Type of DMA transfer
	0,\			;Address of Data in PC RAM
	0>			;Address of Data in LM

IW_DMA2	DMA <0,\		;status pending DMA requests
	0,\			;page port location
	0,\			;addr port location
	0,\			;count port location
	0,\			;single mode port location
	0,\			;mode port location
	0,\			;clear flip-flop port location
	0,\			;bits to disable dma channel
	0,\			;bits to enable dma channel
	0,\			;bits for write transfer
	0,\			;bits for read transfer
	0,\			;current mode
	0,\			;current page of transfer
	0,\			;current transfer address
	0,\			;current amnt sent
	0,\			;size of current transfer
	0,\			;next page
	0,\			;next address
	0,\			;size of next buffer
	0,\			;applies to InterWave's DMA Ctrl Reg
	0,\			;DMA channel number
	0,\			;Type of DMA transfer
	0,\			;Address of Data in PC RAM
	0>			;Address of Data in LM

;#############################################################################
;
;  Remarks: This files defines DDK variable "iw" which is to hold resource
;	    data and operational data for DDK applications. This variable
;	    is of type IWAVE. The data stored here will be IO space, DMA
;	    and IRQ information and vectors to callback functions registered
;	    by a DDK application. This variable "iw" is the heart of a
;	    DDK application. It is initialized here to default values that
;	    correspond to the old Gravis UltraMax board. The codec is based
;	    at 0x32C, the synth at 0x320, sound blaster base is at 0x220,
;	    the record and play dma channels are defaulted to 1, the synth
;	    IRQ line is defaulted to 11, the MIDI IRQ line is defaulted to
;	    5. All callback vectors are set to point to the default function.
;
;#############################################################################
iw	IWAVE <0,\		; InterWave stat flags
	032Ch,\			; Default Base Port for Codec
	0170h,\			; Default Base Port for External Device
	0220h,\			; Default Compatibility Base Port
	0320h,\			; MIDI and Synth Base Port (P3XR)
	0300h,\			; Gen Purpose Reg. 1 Address Register (P401AR)
	0201h,\			; Game Ctrl normally at 0x201
	0376h,\			; Base for ATAPI I/O Space
	0388h,\			; Base port for AdLib. It should be 0x388
	0203h,\			; Default PnP read data port
	0323h,\			; Default Gen Index Reg at P3XR+0x03
	0324h,\			; Default 16-bit data port at P3XR+0x04
	0325h,\			; Default 8-bit data port at P3XR+0x05
	0322h,\			; Synth Voice Select at P3XR+0x02
	032Dh,\			; Codec Indexed Data Port at PCODAR+0x01
	032Eh,\			; Codec Stat Reg 1 at PCODAR+0x02
	032Fh,\			; Playback or Record Data Reg at PCODAR+0x03
	0320h,\			; GMCR or GMSR at P3XR+0x00
	0321h,\			; GMTDR or GMRDR at P3XR+0x01
	0327h,\			; LMBDR at P3XR+0x07 (LMBDR)
	0,\			; Card Select Number
	06Ch,\			; Codec Operation Mode
	1,\			; DMA Chan 1 (local mem/sys & codec record)
	1,\			; DMA Chan 2 (codec play)
	0,\			; Ext Dev DMA channel
	14,\			; Number of voices
	0,\			; Vendor ID and Product Identifier
	0,\			; Pointer to Chan 1 DMA structure
	0,\			; Pointer to Chan 2 DMA structure
	0,\			; Pointer to Ext Dev Chan DMA structure
	7,\			; Synth IRQ number
	5,\			; MIDI IRQ number
	15,\			; Ext Dev IRQ
	0,\			; MPU401 Dev IRQ number
	0,\			; Blaster/AdLib IRQ number
	0,\			; Pointer to Synth IRQ structure
	0,\			; Pointer to MIDI IRQ structure
	0,\			; Pointer to Ext Dev IRQ structure
	0,\			; Address of First Free LM Block
	0,\			; Amount of LM reserved by app.
	0,\			; Synth Mode
	0,\			; Total LM in Kbytes
	0,\			; Old synth real-mode vector
	0,\			; Old midi real-mode vector
	0,\			; midi_mx_func vector
	0,\			; midi_rcv_func vector
	0,\			; timer1_func vector
	0,\			; timer2_func vector
	0,\			; wavetable_func vector
	0,\			; volume_func vector
	0,\			; play_dma_func vector
	0,\			; rec_dma_func vector
	0,\			; ext_dma_func vector
	0,\			; codec_timer_func vector
	0,\			; codec_play_func vector
	0>			; codec_rec_func vector



;#######################################################################
;
;     Generic defines
;
;#######################################################################
AUDIO		equ	0
CODEC_MODE3	equ	06Ch	;Enhanced Mode
ENH_MODE	equ	01h	;SGMI[0]=1
ON		equ	1
OFF		equ	0
PNP_DATA_RDY	equ	1	;PRESSI[0]
RAM_STEP	equ	262144;65536
_CFIG3I		equ	011h
_CMODEI		equ	0Ch	;index for CMODEI
_LMCI		equ	053h
_PIDXR		equ	0279h
_PNPWRP		equ	0A79h
_PWAKEI		equ	03h	;Index for PWAKEI
_PLDNI		equ	07h
_LMALI		equ	043h
_LMAHI		equ	044h
DRAM_IO		equ	04Dh	;DRAM I/O cycles - LMCI[1]=0
AUTOI		equ	001h	;LMCI[0]=1
_SUAI_RD	equ	090h
_SUAI_WR	equ	010h
_SACI_RD	equ	080h
_SACI_WR	equ	000h
_SALI_RD	equ	08Bh
_SALI_WR	equ	00Bh
_SAHI_RD	equ	08Ah
_SAHI_WR	equ	00Ah
_SASHI_RD	equ	082h
_SASHI_WR	equ	002h
_SASLI_RD	equ	083h
_SASLI_WR	equ	003h
_SVCI_RD	equ	08Dh
_SVCI_WR	equ	00Dh
_SAEHI_RD	equ	084h
_SAEHI_WR	equ	004h
_SAELI_RD	equ	085h
_SAELI_WR	equ	005h
_SMSI_RD	equ	095h
_SMSI_WR	equ	015h
_SVLI_RD	equ	089h
_SVLI_WR	equ	009h
_SROI_RD	equ	08Ch
_SROI_WR	equ	00Ch
_SLOI_RD	equ	093h
_SLOI_WR	equ	013h
_SFCI_RD	equ	081h
_SFCI_WR	equ	001h
;#######################################################################
;
;	  Power-Mode Control Defines
;
;#######################################################################
_CROAI		equ	01Bh
_CLOAI		equ	019h

;#######################################################################
;
;	     Synthesizer-related defines
;
;#######################################################################
GF1_SET		equ	01h	;URSTI[0]
_URSTI		equ	04Ch	;URSTI index
VC_ROLLOVER	equ	04h	;SVCI[2]
VC_IRQ_ENABLE	equ	020h	;SACI[5] or SVCI[5]
VOICE_STOP	equ	002h	;SACI[1]
VOICE_STOPPED	equ	001h	;SACI[0]


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� Macros 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴


_poke	MACRO   port, value
	push	ax dx
	mov	dx,port 	;; Write a byte to port 'port'
	mov	al,value
	out	dx,al
	pop	dx ax
ENDM

_pokew	MACRO   port, value
	push	ax dx
	mov	dx,port 	;; Write a byte to port 'port'
	mov	ax,value
	out	dx,ax
	pop	dx ax
ENDM

_peek	MACRO   port
	push	dx
	mov	dx,port 	;; Write a byte to port 'port'
	in	al,dx
	pop	dx
ENDM

_peekw	MACRO   port
	push	dx
	mov	dx,port 	;; Write a byte to port 'port'
	in	ax,dx
	pop	dx
ENDM

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� Procedures 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

;irq_stub_buf2	db	21 dup(?)
;irq_stub_buf3	db	21 dup(?)
;Old_PM_Vec2	df	0
;Old_PM_Vec3	df	0
;Old_RM_Vec2	dd	0
;Old_RM_Vec3	dd	0
;MixerSave	db	0

PNP_InitSoundCard	Proc	Near
	Pushad
	pushf
	mov	StackSave,esp

	call	IwaveOpen
	call	IwaveSetInterface

IF TRANVERSION				;\\
	mov	bl,SoundCard_IRQ		;Set New IRQ Vector  (PM)
	mov	edx,offset PNP_IRQ
	call	_setirqvect

	mov	bl,SoundCard_IRQ		;Set New IRQ Vector  (RM)
	mov	edx,offset PNP_IRQ
	mov	edi,offset irq_stub_buf2	;set real mode IRQ callback
	call	_rmpmirqset
	mov	Old_RM_Vec2,eax 		;store old real mode IRQ vector
ENDIF					;//


IF DOS32VERSION OR PMODEWVERSION	;\\
	mov	bl,SoundCard_IRQ		;Get old IRQ Vector  (PM)
	call	_getirqvect
	mov	dword ptr Old_PM_Vec2,edx
	mov	word ptr Old_PM_Vec2+4,cx

	mov	bl,SoundCard_IRQ		;Set New IRQ Vector  (PM)
	lea	edx,PNP_IRQ
	mov	cx,cs
	call	_setirqvect
ENDIF					;//


	mov	eax,GUS_DramSize
	sub	eax,32				;1:st byte fix!!!!
	sub	eax,GUS_RollOverDataSize
	mov	GUS_DramFree,eax
	mov	[GUS_FreeTable+4],eax
	mov	eax,GUS_RollOverDataSize
	add	eax,32
	mov	[GUS_FreeTable],eax		;1:st byte fix!!!!

	mov	TimerRate,11652 		;102.4 Hz

	popf
	Popad
	Ret
PNP_InitSoundCard	EndP

StartPNPTimer	Proc	Near
	pushad
	cli
;;;
	sti
	popad
	ret
StartPNPTimer	EndP

StopPNPTimer	Proc	Near
	pushad
	cli
;;;
	sti
	popad
	ret
StopPNPTimer	EndP



PNP_DeInitSoundCard	Proc	Near

	mov	ah,SoundCard_DMA1		;Shut Down DMA
	call	DMA_shutdown

	mov	ah,SoundCard_DMA2		;Shut Down DMA
	call	DMA_shutdown


IF TRANVERSION		;\\
	mov	bl,SoundCard_IRQ		;Set Old IRQ Vector
	mov	eax,Old_RM_Vec2 		;Restore old real mode IRQ vector
	call	_rmpmirqfree

ENDIF			;//

IF DOS32VERSION OR PMODEWVERSION		;\\
	mov	bl,SoundCard_IRQ		;Set old IRQ Vector  (PM)
	mov	edx,dword ptr Old_PM_Vec2
	mov	cx,word ptr Old_PM_Vec2+4
	call	_setirqvect

ENDIF			;//

	call	IwaveClose


	ret
PNP_DeInitSoundCard	EndP

;AX-Mixer control
;bit 0: 0=Enable LineIn
;bit 1: 0=Enable LineOut
;bit 2: 1=Enable Mic
;bit 3: 1=Enable Latches
PNP_Mixer	Proc	Near
	push	dx ax
;;
	pop	ax dx
	ret
PNP_Mixer	EndP

;-------------------------------
; ** Main Mixer ** (Record)
; Calls:
;	DL:	0=MONO,1=Stereo
;	DH:	0=8bit, 1=16bit
;	CL:	1=LineIn
;	CH:	1=Mic In
;	AL:	1=CD In
;	BX:	Volume:Line:LLRR, MIC: MM00
;-------------------------------
PNP_MainMixer:
	ret

;GUSVersion	db	0
GetPNPVersion	Proc	Near
	ret
GetPNPVersion	EndP

PNP_ChangeActiveVoices Proc Near
;	Pushad
;	cli
;;;
;	sti
;	Popad
	Ret
PNP_ChangeActiveVoices EndP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;Calls:
;EBX=SampleNr
;[AllocTable+1024*8]=Source
;SampleOffsetMem=Destination
;EDX=128 - conv
;EDX=0	 - no conv
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
PNP_MoveSample	Proc	Near
	pushad
	pushf
;	mov	StackSave,esp

	and	ebx,0fffh
	mov	cl,[VoiceControl+ebx]
	bt	cx,2			;Test if 16 bit
	setc	cl
	movzx	ax,cl
	shl	ax,6
	or	dx,ax

	push	ebx			;Resize Buffer
	mov	ebp,1024
	mov	eax,GF1BUGFIX
	shl	eax,cl
	add	eax,ds:[AllocTable+ebp*8+4]
	xor	ebx,ebx
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	esi,eax
	mov	edi,eax
	pop	ebx

	mov	eax,[SampleOffsetEnd+ebx*4]
	push	esi
	shl	eax,cl		;in bytes
	add	edi,eax
	cmp	[LoopEnd+ebx*4],0
	jz	PNP_NoLisebergsLoopen
	mov	eax,[LoopStart+ebx*4]
	shl	eax,cl
	add	esi,eax
	push	ecx
	mov	eax,GF1BUGFIX
	shl	eax,cl
	mov	ecx,eax
	rep	movsb
	pop	ecx
	jmp	PNP_LisebergsLoopen
PNP_NoLisebergsLoopen:
	push	ecx
	mov	ecx,GF1BUGFIX
	mov	al,[edi-1]
	rep	stosb
	pop	ecx
PNP_LisebergsLoopen:
	pop	esi

	mov	eax,[SampleOffsetEnd+ebx*4]
	add	eax,GF1BUGFIX
	shl	eax,cl
	mov	ecx,eax

	mov	eax,SampleOffsetMem
	mov	[SampleOffsetStart+ebx*4],eax
	add	[SampleOffsetEnd+ebx*4],eax
	add	[LoopStart+ebx*4],eax
	add	[LoopEnd+ebx*4],eax

	push	ecx
	mov	cl,[VoiceControl+ebx]
	bt	cx,2
	setc	cl
	shl	eax,cl
	mov	SampleOffsetMem,eax
	pop	ecx


	push	ebx
	mov	ThisSpecialCase,ebx
	mov	ebx,esi

	movzx	ebp,DMAOnOff
	call	ds:[PNP_DMAorNot+ebp*4]
	pop	ebx

	mov	cl,[VoiceControl+ebx]		;Resize
	bt	cx,2
	setc	cl
	mov	ebp,1024
	mov	eax,[SampleOffsetEnd+ebx*4]
	sub	eax,[SampleOffsetStart+ebx*4]
	shl	eax,cl
	xor	ebx,ebx
	call	MemAlloc
	jc	NotEnoughHiMem

	popf
	popad
	ret
PNP_MoveSample	EndP
PNP_DMAorNot	dd	PNP_DumpSampleToDRAM,PNP_DumpSampleToDRAM,PNP_DMASampleToDram

;-----------------------------------
; calls:  EAX	- Destination
;	  EBX	- Source
;	  ECX	- Bytes to dump
;	   DL	- 128 = Conv, 0 = No Conv
;-----------------------------------
PNP_MoveTuneForkSample	Proc	Near
IFE	PLAYER
	pushad
	mov	ecx,104
	movzx	ebp,DMAOnOff
	call	ds:[PNP_DMAorNot+ebp*4]
	popad
ENDIF
	ret
PNP_MoveTuneForkSample	EndP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;Calls EAX = Address in GUS to put/get sample
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Start_PNP_Dma	Proc	Near
	pushad
	popad
	ret
Start_PNP_Dma	EndP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; Dump sample to GUS
; calls:  EAX	- Offset (in GUS) to dump to
;	  EBX	- Offset (in PC MEM) to sample
;	  ECX	- Bytes to dump
;	   DL	- 128 = Conv, 0 = No Conv
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;ThisSpecialCase dd	0	;Current Sample

PNP_DumpSampleToDRAM	Proc	Near

;--..--
	push	ecx
	mov	ecx,ThisSpecialCase
	mov	cl,[VoiceControl+ecx]
	test	cx,00000100b
	pop	ecx
	jnz	PNP_DumpSampleToDRAM16
;--..--
	pushad

;###################################################
;  Set up LM address counter
;###################################################
	cli
	_poke	iw.igidxr,_LMALI	;select LMALI
	_pokew	iw.i16dp,ax		;Lower 16 bits of addr.
	_poke	iw.igidxr,_LMAHI	;select LMAHI
	shr	eax,16
	_poke	iw.i8dp,al

	_poke	iw.igidxr,_LMCI		;select LMCI
	_peek	iw.i8dp
	mov	dh,al
	or	al,AUTOI                ;set LMCI
	and	al,DRAM_IO
	_poke	iw.i8dp,al

	mov	esi,ebx
@@DumpLoopen:
	lodsb
	xor	al,dl
       	_poke	iw.lmbdr,al
       	loop	@@DumpLoopen

	_poke	iw.i8dp,dh		;restore LMCI
	sti


	popad
	ret
PNP_DumpSampleToDRAM	EndP

PNP_DumpSampleToDRAM16	Proc	Near
	pushad

	shr	ecx,1			;samples, not bytes!

	mov	bp,dx
	shl	bp,8
	and	bp,8000h

	cli
	_poke	iw.igidxr,_LMCI		;select LMCI
	_peek	iw.i8dp
	mov	dh,al
	or	al,AUTOI
	and	al,DRAM_IO
	_poke	iw.i8dp,al		;set LMCI

;############################################
; Set up LM Address Counter
;############################################

	_poke	iw.igidxr,_LMALI	;select LMALI
	_pokew	iw.i16dp,ax		;Lower 16 bits of addr.
	_poke	iw.igidxr,_LMAHI	;select LMAHI
	shr	eax,16
	_poke	iw.i8dp,al

	_poke	iw.igidxr,051h		;select LMSBAI

	mov	esi,ebx
@@DumpLoopen:
	lodsw
	xor	ax,bp
	_pokew	iw.i16dp,ax
	loop	@@DumpLoopen

	_poke	iw.igidxr,_LMCI		;select LMCI
	_poke	iw.i8dp,dh		;restore LMCI

	sti


	popad
	ret
PNP_DumpSampleToDRAM16	EndP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; Get GUS memory
; calls:  EAX	- Offset (in GUS) to dump from
;	  EBX	- Offset (in PC MEM) to buffer
;	  ECX	- Samples to get
;	   DL	- 128 if convert, 0 if not
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;Convert 	db	0
;TransferBits	db	0
PNP_GetSampleFromDRAM	Proc	Near

;	cmp	DMAOnOff,1
;	jz	PNP_DMASampleFromDRAM


;--..--
	push	ecx
	movzx	ecx,CurrentSample
	mov	cl,[VoiceControl+ecx]
	test	cx,00000100b
	pop	ecx
	jnz	PNP_GetSampleFromDRAM16
;--..--

	cli

;###############################################
;  Set up LM address counter
;###############################################

	_poke	iw.igidxr,_LMALI	;select LMALI
	_pokew	iw.i16dp,ax		;Lower 16 bits of addr.
	_poke	iw.igidxr,_LMAHI	;select LMAHI
	shr	eax,16
	_poke	iw.i8dp,al

	_poke	iw.igidxr,_LMCI		;select LMCI
	_peek	iw.i8dp
	or	al,AUTOI
	and	al,DRAM_IO
	mov	dh,al
	_poke	iw.i8dp,al

	mov	edi,ebx
@@GetLoopen:
	_peek	iw.lmbdr
	xor	al,dl
	stosb
	loop	@@GetLoopen

	_poke	iw.i8dp,dh		;restore LMCI

	sti

	pushad
	popad
	ret
PNP_GetSampleFromDRAM	EndP


PNP_GetSampleFromDRAM16	Proc	Near
	pushad

	mov	bp,dx
	shl	bp,8
	and	bp,8000h

	cli
	_poke	iw.igidxr,_LMCI		;select LMCI
	_peek	iw.i8dp
	mov	dh,al
	or	al,AUTOI
	and	al,DRAM_IO
	_poke	iw.i8dp,al		;set LMCI

;############################################
;  Set up Address Counter
;############################################

	_poke	iw.igidxr,_LMALI	;select LMALI
	_pokew	iw.i16dp,ax		;Lower 16 bits of addr.
	_poke	iw.igidxr,_LMAHI	;select LMAHI
	shr	eax,16
	_poke	iw.i8dp,al

	_poke	iw.igidxr,051h		;Select LMSBAI

	mov	edi,ebx
@@GetLoopen:
	_peekw	iw.i16dp
	xor	ax,bp
	stosw
	loop	@@GetLoopen

	_poke	iw.igidxr,_LMCI		;select LMCI
	_poke	iw.i8dp,dh		;restore LMCI

	sti
	popad
	ret
PNP_GetSampleFromDRAM16	EndP



;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; Dump Sample to GUS
; calls:  SampleOffsetMem  - Offset (in DRAM) to dump to
;	  EBX	- Offset (in memory) to sample
;	  ECX	- Bytes to dump
;	   DL	- 128 = Conv, 0 = No Conv
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;SampPtr 	dd	0
;SampleSize	dd	0
;TransferSize	dd	0
PNP_DMASampleToDram	Proc	Near
	pushad
	mov	Convert,dl
	mov	SampPtr,ebx
	mov	SampleSize,ecx
@@NextChunk:
	mov	esi,SampPtr
	mov	edi,DMABuffer
	mov	ecx,GUS_RollOverDataSize
	mov	TransferSize,ecx
	rep	movsb
	mov	SampPtr,esi
	mov	ecx,TransferSize

	push	ecx
	mov	ebx,DMABuffer_Phys
	mov	al,01011000b		;DMA mode register (Write To GUS)
	mov	ah,SoundCard_DMA1	;Channel number ( 0..7 )
	call	DMA_setup		;Do it

	mov	eax,SampleOffsetMem
	add	SampleOffsetMem,ecx
	call	Start_PNP_Dma

	mov	ecx,70*2
@@WaitTC: call	sync
	cmp	DMAPlay_TC,0
	loopz	@@WaitTC
	jz	PNP_TimoutERROR
	mov	DMAPlay_TC,0

	pop	ecx
	sub	SampleSize,ecx
	jnz	@@NextChunk

;	 mov	 al,041h		 ;Stop DMA
;	 mov	 cl,00000000b		 ;Stop IRQ's
;	 call	 PNP_B

	mov	ah,SoundCard_DMA1	;Channel number ( 0..7 )
	call	DMA_shutdown

	Popad
	Ret
PNP_TimoutERROR:

;	 mov	 al,041h		 ;Stop DMA
;	 mov	 cl,00000000b		 ;Stop IRQ's
;	 call	 PNP_B

	mov	ah,SoundCard_DMA1	;Channel number ( 0..7 )
	call	DMA_shutdown

	mov	VolumeRampHit,0
	mov	DMAPlay_TC,0
	mov	ax,TimeOutErr
	jmp	ErrorHandler
PNP_DMASampleToDram  EndP



;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; Get GUS memory via DMA
; calls:  EAX	- Offset (in DRAM) to get from
;	  EBX	- Offset (in memory) to buffer
;	  ECX	- Bytes to get
;	   DL	- 128 if convert, 0 if not
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
PNP_DMASampleFromDRAM	Proc	Near
	pushad
	mov	Convert,dl
	or	Convert,2
;--..--
	mov	edx,ecx
	movzx	ecx,CurrentSample
	mov	cl,[VoiceControl+ecx]
	bt	cx,2
	setc	cl

	push	dx			;16 or 8 bits sample transfer
	movzx	dx,cl
	shl	dx,6
	or	Convert,dl
	pop	dx

	shl	edx,cl
	shl	eax,cl
	mov	ecx,edx
;--..--

	mov	SampleOffsetMem,eax
	mov	SampPtr,ebx
	mov	SampleSize,ecx

@@NextChunk2:
	mov	ecx,GUS_RollOverDataSize
	call	CalcTransferSize
	mov	TransferSize,ecx
	push	ecx
	mov	ebx,DMABuffer_Phys
	mov	al,01010100b		;DMA mode register (read)
	mov	ah,SoundCard_DMA1	;Channel number (0..7)
	call	DMA_setup		;Do it

	mov	eax,SampleOffsetMem
	call	Start_PNP_Dma

	mov	ecx,70*2
@@WaitT2: call	sync
	cmp	DMAPlay_TC,0
	loopz	@@WaitT2
	jz	PNP_TimoutERROR
	mov	DMAPlay_TC,0
	pop	ecx


	test	Convert,40h
	jnz	@@Convert16Bits

	push	ecx			;Convert 8 Bits
	mov	ah,Convert
	and	ah,128
	mov	edi,SampPtr
	mov	esi,DMABuffer
@@ConvertGetLoopen:
	lodsb
	xor	al,ah
	stosb
	loop	@@ConvertGetLoopen
	mov	SampPtr,edi
	pop	ecx
	jmp	@@FinishConcert

@@Convert16Bits:			;Convert 16 Bits
	push	ecx edx
	shr	ecx,1
	mov	dh,Convert
	and	dh,128
	mov	edi,SampPtr
	mov	esi,DMABuffer
@@ConvertGetLoopen2:
	lodsw
	xor	ah,dh
	stosw
	loop	@@ConvertGetLoopen2
	mov	SampPtr,edi
	pop	edx ecx
@@FinishConcert:

	add	SampleOffsetMem,ecx
	sub	SampleSize,ecx
	jnz	@@NextChunk2

;	 mov	 al,041h		 ;Stop DMA
;	 mov	 cl,00000000b		 ;Stop IRQ's
;	 call	 PNP_B


	popad
	ret
PNP_DMASampleFromDRAM	EndP



;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;Calls: EBX = Sample #
;	EDI = Channel
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
PNP_PlayVoice Proc  Near
	and	ebx,0fffh
	jz	_ret

PNP_KeyBoardPlayVoice:
	pushad

;########################################################################
; 16-bit data requires an address translation in GUS
; compatible mode.
;########################################################################

	mov     eax,[SampleOffsetStart+ebx*4]
	call    PNP_Convert16Bit
	mov     SampleOffsetStart2,eax

	mov     eax,[SampleOffsetEnd+ebx*4]
	call    PNP_Convert16Bit
	mov     SampleOffsetEnd2,eax

	mov     eax,[LoopStart+ebx*4]
	call    PNP_Convert16Bit
	mov     LoopStart2,eax

	mov     eax,[LoopEnd+ebx*4]
	call    PNP_Convert16Bit
	mov     LoopEnd2,eax

	cli

	mov	ax,di
	_poke	iw.svsr,al		;select voice
	_poke	iw.igidxr,_SUAI_WR
	mov	eax,SampleOffsetStart2  ;select local mem bank
	shr	eax,22
	and	al,3
	_poke	iw.i8dp,al
	_poke	iw.igidxr,_SACI_RD	;select SACI for reading
	_peek	iw.i8dp                 ;read SACI
	and	al,0BFh
;	or	al,VC_DIRECT		;Backward Direction
	_poke	iw.igidxr,_SACI_WR	;select SACI for writing
	_poke	iw.i8dp,al

;##############################################################
; Set up Synth Address registers which point to the
; location in Local Memory where the Synth fetches data
; from. These registers are SAHI and SALI.
;##############################################################
	_poke	iw.igidxr,_SALI_WR	;select SALI (write)
	mov	eax,SampleOffsetStart2
	_pokew	iw.i16dp,ax
	_poke	iw.igidxr,_SAHI_WR	;select SAHI (write)
	shr	eax,16
	_pokew	iw.i16dp,ax



;##############################################################
; Set up Synth Address Start registers which point to a
; boundary address or start address of a sample buffer
; These registers are SASHI and SASLI.
;##############################################################

	_poke	iw.igidxr,_SASLI_WR	;select SASLI (write)
	mov	eax,SampleOffsetStart2
	_pokew	iw.i16dp,ax
	_poke	iw.igidxr,_SASHI_WR	;select SASHI (write)
	shr	eax,16
	_pokew	iw.i16dp,ax

;##############################################################
; Set up Synth Address End registers which point to a
; boundary address or end address of a sample buffer
; These registers are SAEHI and SAELI.
;##############################################################
	_poke	iw.igidxr,_SAELI_WR	;select SAELI (write)
	mov	eax,SampleOffsetEnd2
	_pokew	iw.i16dp,ax
	_poke	iw.igidxr,_SAEHI_WR	;select SAEHI (write)
	shr	eax,16
	_pokew	iw.i16dp,ax

	sti

	mov	ecx,1
	call	ENV_NextChannel
	popad
	ret
PNP_PlayVoice EndP

;in ebx=SampleNr
;   eax=offset
PNP_Convert16Bit:
	push	ebx
	mov	bl,[VoiceControl+ebx]
	bt	bx,2
	jnc	@@No16bitTweak
	shr	eax,1
@@No16bitTweak:
	pop	ebx
	ret

;Calls: cx+1  = Voice to stop
sxci	db	0
PNP_StopOneVoice    Proc    Near
	pushad
	cli
	dec	cx
	_poke	iw.svsr,cl		;select voice
	_poke	iw.igidxr,_SVCI_RD	;select SVCI to read from
	_peek	iw.i8dp			;read SVCI
	mov	sxci,al
	and	sxci,NOT VC_ROLLOVER	;turn rollover off
	_poke	iw.igidxr,_SVCI_WR	;select SVCI to write to
	_poke	iw.i8dp,sxci		;write SVCI
	_poke	iw.igidxr,_SACI_RD	;select SACI to read from
	_peek	iw.i8dp			;read SACI
	mov	sxci,al
	and	sxci,NOT VC_IRQ_ENABLE	;disable IRQ: SACI[5]=0
	or	sxci,VOICE_STOPPED OR VOICE_STOP	;stop voice: SACI[1:0]=(1,1)
	_poke	iw.igidxr,_SACI_WR	;select SACI to write to
	_poke	iw.i8dp,sxci		;write SACI

	_poke	iw.igidxr,_SMSI_RD
	_peek	iw.i8dp
	or	al,02h
	_poke	iw.igidxr,_SMSI_WR
	_poke	iw.i8dp,al
	sti
	popad
	ret
PNP_StopOneVoice    EndP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;Calls: EAX = Size Wanted (in samples)
;	CurrentSample
;Ret:	CY=1 if error
;	EAX = Offset to dump sample
;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;SizeAllocated	dd	0
;AllocFailed	db	0
;GUS_DramFree	 dd	 0		 ;Total Free Dram (even fragmented)
;GUS_FreeTable	 dd	 160 dup(0)	 ;Increase )?(
;GUS_TableSize	 equ	 80		 ;Size of FreeTable
;DidCompress	db	0		;set to 1 if a compress occured
;AllocBits	db	0		;Bits of sample
PNP_Alloc	Proc	Near
	Pushad
	mov	SizeAllocated,eax	;Assume allocation went ok.
	add	eax,GF1BUGFIX
;--..--
	movzx	ecx,CurrentSample
	mov	cl,[VoiceControl+ecx]
	bt	cx,2
	setc	cl
	mov	AllocBits,cl
	shl	eax,cl			;eax=bytes
;--..--
	mov	ecx,GUS_TableSize
	lea	edi,GUS_FreeTable+4
@@SearchFree:
	cmp	[edi],eax
	jae	@@GotArea
	add	edi,8
	loop	@@SearchFree

	mov	ecx,GUS_TableSize		;Search for biggest free size
	lea	edi,GUS_FreeTable-8
	cmp	dword ptr [edi+8],0
	jz	@@NoMemLeft			;if 0 mem left
@@SearchZero:
	add	edi,8
	cmp	dword ptr [edi],0
	loopnz	@@SearchZero
	sub	edi,4
	mov	eax,[edi]			;Get size
	dec	eax
	and	eax,not 1
	mov	AllocFailed,1
	jmp	@@GotArea
@@NoMemLeft:
	mov	SizeAllocated,0
	mov	AllocFailed,1
	popad
	stc
	ret

@@GotArea:
	test	eax,1		;eax=size
	jz	@@Aligned1
	and	eax,not 1	;Align even
	add	eax,2
@@Aligned1:
	mov	ebx,[edi-4]	;ebx=offset
	test	ebx,1
	jz	@@Aligned2
	and	ebx,not 1	;Align even
	add	ebx,2
@@Aligned2:
	sub	GUS_DramFree,eax
	sub	[edi],eax
	jnz	@@OfTheWorld
	mov	Dword Ptr [edi-4],0
	jmp	@@ILoveYou
@@OfTheWorld:
	add	[edi-4],eax
@@ILoveYou:
	call	PNP_OptimizeTable
	call	PNP_SortTable

;--..--
	mov	cl,AllocBits
	shr	ebx,cl
;--..--
	mov	SampleOffsetMem,ebx

	shr	eax,cl
	sub	eax,GF1BUGFIX
	jge	@@Fine
	xor	eax,eax
@@Fine:

	mov	SizeAllocated,eax

;...
;	mov	eax,DumPtr
;	mov	[DumTable+eax*4],ebx
;	inc	DumPtr
;...
	mov	[esp+28],ebx
	mov	al,AllocFailed		;Set carry if needed
	rcr	al,1
	Popad
	Ret
PNP_Alloc	EndP

;Global  DumTable:Dword:100
;DumPtr 	 dd	 0
;DumTable	 dd	 100 dup(0)

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;Calls: EAX = Size to Disalloc (in samples)
;	ESI = Offset to Disalloc
;	CurrentSample
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PNP_Disalloc	 Proc	 Near
	Pushad
	add	eax,GF1BUGFIX
;--..--
	movzx	ecx,CurrentSample
	mov	cl,[VoiceControl+ecx]
	bt	cx,2
	setc	cl
	shl	eax,cl
	shl	esi,cl
;--..--
	lea	edi,GUS_FreeTable-8
	mov	ecx,GUS_TableSize
@@SearchEnd:
	add	edi,8
	cmp	Dword ptr [edi],0
	jnz	@@Nofisk
	cmp	Dword ptr [edi+4],0	;This IS Correct!
@@Nofisk:
	loopnz	@@SearchEnd
	jnz	@@ErrorEnd
	mov	[edi],esi
	test	eax,1
	jz	@@Aligned3
	and	eax,not 1		;Align even
	add	eax,2
@@Aligned3:
	mov	[edi+4],eax
	add	GUS_DramFree,eax
	call	GUS_SortTable
	clc
	Popad
@@CompressAgain:
	mov	DidCompress,0
	call	PNP_CompressTable
	cmp	DidCompress,1
	jz	@@CompressAgain
	call	OptimizeTable
	call	GUS_SortTable
	Ret
@@ErrorEnd:
	call	sara4
	stc
	Popad
	Ret
PNP_Disalloc	EndP

PNP_SortTable	Proc	Near			;Sort table
	Pushad
	lea	edi,GUS_FreeTable+4
	mov	esi,edi
	mov	ecx,GUS_TableSize
	dec	ecx
	mov	ebp,ecx
@@BigLoopen:
	push	ecx
	push	edi
	push	esi
	mov	ecx,ebp
	mov	eax,[edi]
@@SmallLoopen:
	add	esi,8
	cmp	[esi],eax
	jae	@@NoSwap
	cmp	dword ptr [esi],0
	jz	@@NoSwap
	mov	ebx,[edi]
	xchg	ebx,[esi]
	mov	[edi],ebx
	mov	eax,ebx
	mov	ebx,[edi-4]
	xchg	ebx,[esi-4]
	mov	[edi-4],ebx

@@NoSwap:
	loop	@@SmallLoopen
	pop	esi
	pop	edi
	pop	ecx
	dec	ebp
	add	esi,8
	add	edi,8
	loop	@@BigLoopen


	Popad
	Ret
PNP_SortTable	EndP

PNP_CompressTable	Proc	Near		;Check near areas
	Pushad
	mov	ecx,GUS_TableSize
	lea	edi,GUS_FreeTable
@@CompLoop:
	lea	esi,GUS_FreeTable
	push	ecx
	mov	eax,[edi]
	add	eax,[edi+4]
	mov	ecx,GUS_TableSize
@@CompLoop2:
	push	ecx
	cmp	eax,[esi]
	jnz	@@DontCompress
	cmp	eax,0
	jz	@@DontCompress
	mov	DidCompress,1
	mov	eax,[edi+4]
	add	eax,[esi+4]
	mov	[edi+4],eax
	mov	Dword Ptr [esi],0
	mov	Dword Ptr [esi+4],0
	pop	ecx
	jmp	@@QuitFirst
@@DontCompress:
	pop	ecx
	add	esi,8
	loop	@@CompLoop2
@@QuitFirst:
	pop	ecx
	add	edi,8
	loop	@@CompLoop
	Popad
	Ret
PNP_CompressTable	EndP

PNP_OptimizeTable	Proc	Near		;Removes spaces in table
	Pushad
	lea	edi,GUS_FreeTable
	mov	ecx,GUS_TableSize

@@OptimTable:
	cmp	Dword ptr [edi],0
	jnz	@@NoSlisk
	cmp	Dword ptr [edi+4],0
	jnz	@@NoSlisk
	push	ecx edi
	dec	ecx
	shl	ecx,1
	mov	esi,edi
	add	esi,8
	rep	movsd
	mov	dword ptr [edi],0
	mov	dword ptr [edi+4],0
	pop	edi ecx
	sub	edi,8
@@NoSlisk:
	add	edi,8
	loop	@@OptimTable

	Popad
	Ret
PNP_OptimizeTable	EndP

;xxxxxxxxxxxxxxxxxxxxxxxxx
;WaveTableHit	 dd	 0
;VolumeRampHit	 dd	 0
;UpdateChannels	db	0	;Set to 1 if to call AMSPLAY
PNP_IRQ     Proc    Near
	pushad
	pushfd
	push	gs ds es
	mov	ds,cs:_seldata
	mov	gs,cs:_selzero
	cld

;	 mov	 WaveTableHit,0
;	 mov	 VolumeRampHit,0

;;


	cmp	UpdateChannels,1
	jz	AMSPLAY2

	mov	al,020h 		;EOI to PICs
	out	0A0h,al
	out	020h,al
	pop	es ds gs
	popfd
	popad
	sti
	iRetD
PNP_IRQ  EndP


;calls: ESI=Table to read from
PNP_RampDownNeededChannels	Proc	Near
	Pushad
	popad
	ret
PNP_RampDownNeededChannels	EndP

PNP_SetZeroVol	   Proc    Near
	Pushad
	cli
	sti
	Popad
	Ret
PNP_SetZeroVol	EndP

PNP_SetOrigVol	   Proc    Near
	Pushad
	cli
	sti
	Popad
	Ret
PNP_SetOrigVol	EndP

;Calls: EAX=Volume, EDI=Channel
PNP_SetVolume	Proc	Near
	pushad
	cli
	mov	ebx,edi
	_poke	iw.svsr,bl		;select voice
	_poke	iw.igidxr,_SVLI_WR	;select SVLI to write to
	shl	eax,5
	mov	eax,4095	;NONONONO
	_pokew	iw.i16dp,ax		;write SVLI[15:4]
	sti
	popad
	ret
PNP_SetVolume	EndP

;edi=chan
PNP_SetTheFreq	Proc	Near
	pushad

	cmp	LinFreq,1
	jz	PNP_LinearFreq

	movzx	ecx,[CurrNoteTable+edi]
	sub	ecx,2
	ConvertNote ecx ecx

	sub	cx,[VibPeriod+edi*2]		 ;428*4*8363*C2
	add	cx,[VibratoTable+edi*2] 	 ;--------------
	add	cx,[FineTuneTable+edi*2]	 ;16*8363*period
	add	ecx,[SlideTable+edi*4]
	jecxz	PNP_EndFreq

	mov	eax,428*8363*16
	xor	edx,edx
	div	ecx

	shl	eax,10				;fc=(((freq<<10)+22050)/44100)<<1 = 10 fractional bits in SFCI
	mov	ecx,22050
	add	eax,ecx
	xor	edx,edx
	div	ecx

	mov	bx,di
	cli
	_poke	iw.svsr,bl		;select voice
	_poke	iw.igidxr,_SFCI_WR	;select Synth Freq Control register
	_pokew	iw.i16dp,ax
	sti

PNP_EndFreq:
	popad
	ret


PNP_LinearFreq:
	popad
	ret
;!!!!!!!!!
	movzx	ebx,[CurrNoteTable+edi]
	sub	ebx,2

	xor	eax,eax
	sub	ax,[VibPeriod+edi*2]
	add	ax,[VibratoTable+edi*2]
	add	ax,[FineTuneTable+edi*2]
	cwde
	add	eax,[SlideTable+edi*4]
	sar	eax,4
	cdq
	mov	ecx,16
	idiv	ecx
	sub	ebx,eax
	shl	ebx,4
	sub	ebx,edx
	mov	eax,[LinFreqTable+ebx*4]

	movzx	ebx,word ptr [CurrSample+edi*2]
	movzx	ebx,word ptr [SampleRates+ebx*2]
	mul	ebx
	movzx	ebx,GUS_Divisor
	shl	ebx,16
	div	ebx
	mov	si,ax

	mov	dx,GUS_Command
	mov	al,1
	out	dx,al
	inc	dx
	mov	ax,si
	out	dx,ax

	popad
	ret
PNP_SetTheFreq	EndP

PNP_StartTheChannels	Proc	near
	pushad
	movzx	ecx,AllocChannels
	xor	edi,edi
PNP_StartChannels:
	btr	KBDPlayFlag,edi
	jc	@@StartKBD3

	test	[SkipFlag+edi*2],00004h
	jnz	@@SkipPlayVoice2

@@StartKBD3:
	movzx	ebx,CurrentSample
	cmp	[CurrSample+edi*2],bx
	jnz	@@NotLastVoice
	mov	LastVoice,di
@@NotLastVoice:

	cli
	mov	ax,di
	_poke	iw.svsr,al		;select voice
	_poke	iw.igidxr,_SACI_RD	;select SACI to read from
	_peek	iw.i8dp
	and	al,NOT (VOICE_STOPPED OR VOICE_STOP)
	_poke	iw.igidxr,_SACI_WR	;select SACI to write to
	_poke	iw.i8dp,al		;this also clears IRQs

	_poke	iw.igidxr,_SMSI_RD
	_peek	iw.i8dp
	and	al,NOT 02h
	_poke	iw.igidxr,_SMSI_WR
	_poke	iw.i8dp,al

	sti

;	 mov	 dx,GUS_Voice
;	 mov	 ax,di			 ;Voice #
;	 out	 dx,al

;	 mov	 dx,GUS_Command
;	 mov	 al,0			 ;Voice Control
;	 out	 dx,al
;	 add	 dx,2			 ;105
;	 mov	 al,[PlayInfo+edi]
;	 out	 dx,al			 ;Voice Control Register

@@SkipPlayVoice2:
	or	[SkipFlag+edi*2],00004h
	inc	edi
	loop	PNP_StartChannels
	popad
	ret
PNP_StartTheChannels	EndP

;Calls:  ah=panpot
;	 di=channel
PNP_SetPanpot	    Proc    Near
	pushad

	cli

	mov	bx,di
	shr	ax,8
	and	al,0f0h
	_poke	iw.svsr,bl		;select voice

;	_poke	iw.igidxr,_SMSI_RD	;select SMSI to read from
;	_peek(iw.i8dp)
	_poke	iw.igidxr,_SLOI_WR	;select SLOI to write to
	_pokew	iw.i16dp,ax		;set left balance
	mov	bx,15
	sub	bx,ax
	_poke	iw.igidxr,_SROI_WR	;select SROI to write to
	_pokew	iw.i16dp,bx		;set right balance (SROI)


	sti
	popad
	ret
PNP_SetPanpot	    EndP


PNP_ClearTheSamples:
	xor	eax,eax
	lea	edi,SampleOffsetStart
	mov	ecx,22*MaxSamples/4
	rep	stosd
	mov	samples,1
	lea	edi,GUS_FreeTable
	mov	ecx,GUS_TableSize
	xor	al,al
	rep	stosb

IF	PLAYER
	mov	ebx,32
	cmp	LoadFXEngine,0
	jz	@@NoFX
ENDIF
	mov	ebx,GUS_RollOverDataSize
	add	ebx,32
@@NoFX:

	mov	eax,GUS_DramSize2
	sub	eax,ebx 			;1:st byte fix!!!!
	mov	GUS_DramFree,eax
	mov	[GUS_FreeTable+4],eax
	mov	eax,ebx 			;1:st byte fix!!!!
	mov	SampleOffsetMem,eax
	mov	[GUS_FreeTable],eax


	mov	ebp,1043
	call	MemDisalloc
	mov	ebp,1028
	call	MemDisalloc
	mov	ebp,1029
	call	MemDisalloc
	mov	ebp,1034
	call	MemDisalloc
	ret

;--------------------------------------------------------------- 10
PNP_CMD10:
	ret

;--------------------------------------------------------------- E8
PNP_CMDE8:
	ret


;Ultrasnd	 db	 'ULTRASND='
;UltraLen	 equ	  $-ultrasnd


IF TRANVERSION		;\\
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;				Read Environment
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;Reads the Environment variables
;
; Calls: None
;
; Out:
; Carry=1 No Variable found
; Carry=0 Variable found
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
AMS_GetPNPEnv	Proc	Near
	pushad
IFNDEF WATCOM
	mov	edi,_pspa
	movzx	edi,word ptr gs:[edi+2Ch] ; Get the Environment segment value
	shl	edi,4
ELSE
	mov	edi,_env
ENDIF
	lea	edx,Ultrasnd
@@CheckVar:
	mov	cl,UltraLen
	mov	ebx,edx
@@ScanVar:
	mov	al,byte ptr gs:[edi]
	cmp	al,byte ptr [ebx]
	jnz	@@SkipVar
	inc	edi
	inc	ebx
	dec	cl
	jnz	@@ScanVar

	mov	SoundCard,6

	xor	ebx,ebx
	mov	cl,3
@@GetGUSPort:
	shl	bx,4
	mov	dl,byte ptr gs:[edi]
	inc	edi
	sub	dl,'0'
	or	bl,dl
	dec	cl
	jnz	@@GetGUSPort

	mov	SoundCard_BasePort,bx
	inc	edi			;skip past comma

@@GetGUSDMA:
	mov	bl,byte ptr gs:[edi]
	sub	bl,'0'
	mov	SoundCard_DMA1,bl
	add	edi,2			;skip past comma

	mov	bl,byte ptr gs:[edi]
	sub	bl,'0'
	mov	SoundCard_DMA2,bl
	add	edi,2			;skip past comma

@@GetGUSIRQ:
	cmp	byte ptr gs:[edi+2],','
	jz	@@GUSIRQ1x
	mov	bl,byte ptr gs:[edi]
	sub	bl,'0'
	mov	SoundCard_IRQ,bl
	add	edi,2
	jmp	@@GetGUSMIDIIRQ
@@GUSIRQ1x:
	mov	bl,byte ptr gs:[edi+1]
	sub	bl,'0'
	add	bl,10
	mov	SoundCard_IRQ,bl
	add	edi,3
@@GetGUSMIDIIRQ:
	cmp	byte ptr gs:[edi+1],0
	jnz	@@GUSIRQ1x2
	mov	bl,byte ptr gs:[edi]
	sub	bl,'0'
	mov	SoundCard_MIDIIRQ,bl
	jmp	@@ExitGUS
@@GUSIRQ1x2:
	mov	bl,byte ptr gs:[edi+1]
	sub	bl,'0'
	add	bl,10
	mov	SoundCard_MIDIIRQ,bl
	jmp	@@ExitGUS
@@SkipVar:
	inc	edi			;Env space is terminated with "0,0"
	mov	al,gs:[edi]
	cmp	al,0
	jnz	@@SkipVar
	inc	edi
	mov	al,gs:[edi]
	cmp	al,0
	jnz	@@CheckVar

	stc
	popad
	ret
@@ExitGUS:
	clc
	popad
	ret
AMS_GetPNPEnv	EndP
ENDIF			;//


IF DOS32VERSION OR PMODEWVERSION	;\\

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;				Read Environment
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;Reads the Environment variables
;
; Calls: None
;
; Out:
; Carry=1 No Variable found
; Carry=0 Variable found
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
AMS_GetPNPEnv	Proc	Near

	; Don't detect a PNP
	stc
	ret

IF	AUTODETECT_SC
	pushad
	mov	edi,_env
	lea	edx,Ultrasnd
@@CheckVar:
	mov	cl,UltraLen
	mov	ebx,edx
@@ScanVar:
	mov	al,byte ptr [edi]
	cmp	al,byte ptr [ebx]
	jnz	@@SkipVar
	inc	edi
	inc	ebx
	dec	cl
	jnz	@@ScanVar

	mov	SoundCard,6

	xor	ebx,ebx
	mov	cl,3
@@GetGUSPort:
	shl	bx,4
	mov	dl,byte ptr [edi]
	inc	edi
	sub	dl,'0'
	or	bl,dl
	dec	cl
	jnz	@@GetGUSPort

	mov	SoundCard_BasePort,bx
	inc	edi			;skip past comma

@@GetGUSDMA:
	mov	bl,byte ptr [edi]
	sub	bl,'0'
	mov	SoundCard_DMA1,bl
	add	edi,2			;skip past comma

	mov	bl,byte ptr [edi]
	sub	bl,'0'
	mov	SoundCard_DMA2,bl
	add	edi,2			;skip past comma

@@GetGUSIRQ:
	cmp	byte ptr [edi+2],','
	jz	@@GUSIRQ1x
	mov	bl,byte ptr [edi]
	sub	bl,'0'
	mov	SoundCard_IRQ,bl
	add	edi,2
	jmp	@@GetGUSMIDIIRQ
@@GUSIRQ1x:
	mov	bl,byte ptr [edi+1]
	sub	bl,'0'
	add	bl,10
	mov	SoundCard_IRQ,bl
	add	edi,3
@@GetGUSMIDIIRQ:
	cmp	byte ptr [edi+1],0
	jnz	@@GUSIRQ1x2
	mov	bl,byte ptr [edi]
	sub	bl,'0'
	mov	SoundCard_MIDIIRQ,bl
	jmp	@@ExitGUS
@@GUSIRQ1x2:
	mov	bl,byte ptr [edi+1]
	sub	bl,'0'
	add	bl,10
	mov	SoundCard_MIDIIRQ,bl
	jmp	@@ExitGUS
@@SkipVar:
	inc	edi			;Env space is terminated with "0,0"
	mov	al,[edi]
	cmp	al,0
	jnz	@@SkipVar
	inc	edi
	mov	al,[edi]
	cmp	al,0
	jnz	@@CheckVar

	stc
	popad
	ret
@@ExitGUS:
	clc
	popad

ELSE
	stc
ENDIF
	ret
AMS_GetPNPEnv	EndP
ENDIF			;//


PNP_TurnOnSoundCard:
	push	ax
	pop	ax
	ret

PNP_StartTimer	    Proc    Near
	pushad

	cmp	IntsOn,1
	jz	@@SkipTStart

	cmp	TimerSelect,0
	jz	@@UseThePC

	mov	PC_GUSTimer,1
	call	StartPNPTimer
	jmp	@@SkipTStart

@@UseThePC:
	mov	PC_GUSTimer,0
	call	StartInts

@@SkipTStart:
	mov	IntsOn,1
	popad
	ret
PNP_StartTimer	    EndP


PNP_StopTimer	    Proc    Near
	pushad
	cmp	IntsOn,0
	jz	@@SkipTStop

	cmp	PC_GUSTimer,0
	jz	@@StopThePC

	call	StopPNPTimer
	jmp	@@SkipTStop

@@StopThePC:
	call	StopInts
@@SkipTStop:
	mov	IntsOn,0
	popad
	ret
PNP_StopTimer	    EndP


;ax=voice, ebx=sample #
PNP_GetCurrAdd	    Proc    Near
	pushad
	cli
	_poke	iw.svsr,al		;select voice
	_poke	iw.igidxr,_SAHI_RD	;select SAHI to read
	_peekw	iw.i16dp
	movzx	ebx,ax
	shl	ebx,7			;get high portion of addr.

	_poke	iw.igidxr,_SALI_RD	;select SALI to read
	_peekw	iw.i16dp
	and	eax,0ffffh
	shr	eax,9			;get low portion of addr.
	or	ebx,eax

;	_poke	iw.igidxr,_SACI_RD	;select SACI to read
;	mode = _peek(iw.i8dp);
	_poke	iw.igidxr,_SUAI_RD
	_peek	iw.i8dp
	and	eax,3
	shl	eax,22
	or	ebx,eax
	mov	CurrAdd,ebx

;...
	mov	dnumber,3
	mov	dbyte,ebx
	call	dbug
;...


	sti

	popad
	ret
PNP_GetCurrAdd	    EndP

;di=Voice
PNP_SetCurrAdd	    Proc    Near
	pushad
	popad
	ret
PNP_SetCurrAdd	    EndP


;EDI=Channel
PNP_SetSampleLoop   Proc    Near
	pushad
	movzx	edi,LastVoice
	movzx	ebx,CurrentSample

	popad
	ret
PNP_SetSampleLoop   EndP


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;				 Sampling part
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�

PNP_ChangeSamplingFreq:
IFE	PLAYER
	pushad
	popad
ENDIF
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; Start the ADC, Called at startup (Big Popup on)
; Calls: None
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
PNP_StartADC	Proc	Near
IFE	PLAYER
	pushad
	cli

	mov	ah,SoundCard_DMA1	;Shut down playing DMA
	call	DMA_ShutDown

	mov	ah,SoundCard_DMA2	;Shut down Rec DMA
	call	DMA_ShutDown

	mov	SamplingBuffOff,0
	mov	DMAPlay_TC,0

	mov	SampleConvert,128
	mov	ecx,GUS_RollOverDataSize
	shr	ecx,1
	mov	ebx,DMABuffer_Phys
	mov	al,01010100b		;DMA mode register (read)
	mov	ah,SoundCard_DMA2	;Channel number ( 0..7 )
	call	DMA_setup		;Do it

;	 mov	 dx,GUS_Command
;	 mov	 al,49h 		 ;Sampling Control Register
;	 out	 dx,al
;	 mov	 dx,GUS_Data_High
;	 mov	 al,Stereo		 ;Stereo
;	 shl	 al,1
;	 or	 al,00100001b		 ;GO + IRQ Enable
;	 mov	 ah,SoundCard_DMA2	 ;8/16 Bits
;	 and	 ah,100b
;	 or	 al,ah
;	 out	 dx,al
	sti
	popad
ENDIF
	ret
PNP_StartADC	EndP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; Stop the ADC, Called at end (Big Popup off)
; Calls: None
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
PNP_StopADC	Proc	Near
IFE	PLAYER
	pushad
	cli

;	 mov	 dx,GUS_Command
;	 mov	 al,49h 	 ;Sampling Control Register
;	 out	 dx,al
;	 mov	 dx,GUS_Data_High
;	 xor	 al,al
;	 out	 dx,al

	mov	Sampling,0
	mov	DMAPlay_TC,0
	mov	ah,SoundCard_DMA2
	call	DMA_ShutDown

	sti
	popad
ENDIF
	ret
PNP_StopADC   EndP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;Calls: None
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
PNP_FixStartSample  Proc    Near
IFE	PLAYER
	pushad
	mov	ebx,[AllocTable+1024*8]
	mov	SampPtr,ebx
	mov	ecx,[AllocTable+1024*8+4]
	mov	SampleSize,ecx

	xor	ebp,ebp
@@SearrchArgain:
	add	ebp,8
	cmp	dword ptr ds:[GUS_FreeTable+ebp],0	 ;Get Biggest free GUS chunk.
	jnz	@@SearrchArgain

	mov	ecx,ds:[GUS_FreeTable+ebp-4]

	cmp	SampleSize,ecx
	jbe	@@NoProblemosNow
	mov	SampleSize,ecx
@@NoProblemosNow:
	popad
ENDIF
	ret
PNP_FixStartSample  EndP





;cl=8 - Looping On, cl=0 - Looping Off
;LoopMode	Proc	Near
;	pushad
;	popad
;	ret
;LoopMode	EndP


;eax=offset in GUS
;ecx=bytes to transfer
;PadWord dw	0
PNP_MoveRollOverSample	Proc	Near
	cmp	RollSize,0
	jz	_ret
	pushad
	push	eax
	mov	ebx,ecx
	mov	edi,DMABuffer

	pushad				;Clear DMA Buffer
	mov	al,0
	rep	stosb
	popad

	mov	esi,RollPtr
	cmp	ecx,RollSize
	jbe	@@Okay2
	mov	ecx,RollSize
@@Okay2:
	mov	LastRollPos,ecx
	add	LastRollPos,eax

	sub	RollSize,ecx
	add	RollPtr,ecx
	push	ecx
	rep	movsb
	pop	ecx

	cmp	RollPos,0
	jz	@@WritePad
	mov	esi,DMABuffer
	mov	ax,[esi]
	mov	PadWord,ax
	jmp	@@SkipPad
@@WritePad:
	mov	edi,DMABuffer
	mov	ax,PadWord
	mov	[edi+8192],ax
	add	ecx,2
@@SkipPad:
	mov	ebx,DMABuffer_Phys
	mov	al,01011000b		;DMA mode register (Write To GUS)
	mov	ah,SoundCard_DMA1	;Channel number ( 0..7 )
	call	DMA_setup		;Do it

	mov	al,RollConvert
	mov	Convert,al
	pop	eax
	call	Start_PNP_DMA

	popad
	ret
PNP_MoveRollOverSample	EndP
;TimerRate	 dw	 0
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;Calls:
;
;eax=RollBits
;bl =RollNote
;ecx=RollSize
;edx=C4 Rate
;esi=RollPtr
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;EnableWaveIRQ		db	0
;RollPtr 		dd	0		;Ptr to speech sample
;RollSize		dd	0		;Size of SpeechSample
;RollSampPos		dd	8192,0
;RollPos 		dd	0
;RollBits		dd	0		;1=16 bits sample
;RollNote		db	0
;RollHitCounter		dd	-1		;Nr of 8k blocks
;TmpRollHitCounter	dd	0
;RollConvert		db	0

;Speech_C4Rate		dw	0
PNP_SpeechEngine	Proc	Near
IF	PLAYER
	cmp	LoadFXEngine,0			;If not installed
	jz	_ret
ENDIF

	call	PNP_StopSpeech

	mov	RollOverPos,8192
	mov	Speech_C4Rate,dx

	pushad
	mov	RollSize,ecx
	mov	RollPtr,esi
	mov	RollBits,eax
	mov	RollNote,bl
	mov	RollConvert,0
	mov	eax,ecx
	shr	eax,13
	mov	TmpRollHitCounter,eax

	mov	eax,RollBits		;11000000b if 16 bit conversion
	shl	al,6
	or	RollConvert,al

	movzx	di,AllocChannels
	dec	di
	mov	CurrAdd,0
	call	PNP_SetCurrAdd

	mov	DMAPlay_TC,0
	mov	eax,0				;Offset In GUS
	mov	ecx,8192			;Fill whole buffer 1:st time
	mov	RollPos,1
	call	PNP_MoveRollOverSample

	mov	ecx,70*2			;Wait for finish
@@Wait: call	sync
	cmp	DMAPlay_TC,0
	loopz	@@Wait
	mov	DMAPlay_TC,0

	mov	eax,8192
	mov	ecx,8192
	mov	RollPos,0
	call	PNP_MoveRollOverSample

	cmp	TmpRollHitCounter,0
	jnz	@@NotSmall
	mov	eax,LastRollPos
	mov	RollOverPos,eax
@@NotSmall:
	mov	ebx,1				;Use Sample nr 1

	mov	eax,RollBits
	shl	al,2
		  ;-d-bl6--
	or	al,00001000b
	mov	[VoiceControl+ebx],al

	mov	[SampleOffsetStart+ebx*4],0
	mov	[LoopStart+ebx*4],0
	mov	eax,16384
	mov	ecx,RollBits
	shr	eax,cl
	mov	[SampleOffsetEnd+ebx*4],eax
	mov	[LoopEnd+ebx*4],eax
	mov	ax,Speech_C4Rate
	mov	[SampleRates+ebx*2],ax
	mov	[Volumes+ebx],127

	mov	edi,3				;Chan 0-3
	mov	al,70h				;Pan
	mov	ah,RollNote			;Note
	mov	cl,127				;Vol
	call	FXEngine

	mov	eax,TmpRollHitCounter
	mov	RollHitCounter,eax

	popad
	ret
PNP_SpeechEngine	EndP

;LastRollPos	dd	0
;RollOverPos	dd	8192
PNP_PollRollOverPos Proc	Near
	cmp	RollHitCounter,0
	jl	_ret
	mov	ecx,RollOverPos
	movzx	eax,AllocChannels
	dec	eax
	mov	ebx,1
	call	GetCurrAdd

	push	ecx
	mov	ecx,RollBits
	shl	CurrAdd,cl
	pop	ecx

	cmp	RollPos,0
	jz	@@Firstpart
	cmp	CurrAdd,ecx
	ja	@@NoHit
	jmp	@@Hit
@@Firstpart:
	cmp	CurrAdd,ecx
	jb	@@NoHit
@@Hit:
	dec	RollHitCounter
	jg	@@NoLastTime
	call	PNP_LoopModeOff
	mov	eax,LastRollPos 	;Play Last Part
	call	PNP_SetEndAddress
	mov	RollHitCounter,-1
	mov	DMAPlay_TC,0
	ret

@@NoLastTime:
	xor	RollPos,1
	mov	eax,RollPos
	mov	ecx,8192
	mov	eax,[RollSampPos+eax*4]
	call	PNP_MoveRollOverSample

@@NoHit:
	ret
PNP_PollRollOverPos EndP

PNP_StopSpeech	Proc	Near
	pushad
	mov	RollHitCounter,-1
	mov	ah,SoundCard_DMA1	;Channel number ( 0..7 )
	call	DMA_ShutDown
	mov	DMAPlay_TC,0
	movzx	ecx,AllocChannels
	call	StopOneVoice
	popad
	ret
PNP_StopSpeech	EndP

PNP_CheckSpeech Proc	Near
	pushad
	cmp	RollHitCounter,-1
	jnz	_Retp_clc
	jmp	_Retp_stc
PNP_CheckSpeech EndP

;_Retp_clc:
;	popad
;	clc
;	ret
;_Retp_stc:
;	popad
;	stc
;	ret

PNP_LoopModeOff	Proc	Near
	pushad
	popad
	ret
PNP_LoopModeOff	EndP

;eax=end addy
PNP_SetEndAddress	Proc	Near
	pushad
	popad
	ret
PNP_SetEndAddress	EndP


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;			       PnP Procedures
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�



;#########################################################################
;
; FUNCTION: IwaveOpen
;
; PROFILE: This function sets up the IWAVE structure variable "iw" defined
;	   by the DDK and necessary to creating applications for the
;	   InterWave. The function also initializes the DMA and IRQ
;	   structures for the interface to the sound board. The InterWave
;	   IC is initialized as follows:
;
;	   1. The selected mode of operation of the synth is programmed.
;	   2. Interrupts and DMA requests are enabled onto ISA bus.
;	   2. Line in and mic are disabled. Line out is enabled.
;
;	   The "iw" variable contains pointers to the DMA and IRQ
;	   structures and these must be initialized prior to calling
;	   IwaveOpen. If no DMA or IRQ structures are needed by the
;	   particular application, these pointers should be set to NULL.
;
;#########################################################################
IwaveOpen	Proc	Near
	pushad

; char *ptr;
; if ((ptr=getenv("IWAVEID"))==NULL)
;     return(FALSE);
; sscanf(ptr,"%lx",&iw.vendor);

	mov	eax,iw.vendor
	call	IwavePnpPing
	mov	iw.csn,al

	call	IwavePnpKey

	mov	al,iw.csn
	call	IwavePnpWake

 	call	IwavePnpGetCfg

	mov	ax,iw.pcodar
	inc	ax
	mov	iw.cdatap,ax

	mov	ax,iw.pcodar
	add	ax,2
	mov	iw.csr1r,ax

	mov	ax,iw.pcodar
	add	ax,3
	mov	iw.cxdr,ax		;CPDR or CRDR

	mov	ax,iw.p3xr
	mov	iw.gmxr,ax

	mov	ax,iw.p3xr
	inc	ax
	mov	iw.gmxdr,ax		;GMTDR or GMRDR

	mov	ax,iw.p3xr
	add	ax,2
	mov	iw.svsr,ax

	mov	ax,iw.p3xr
	add	ax,3
	mov	iw.igidxr,ax

	mov	ax,iw.p3xr
	add	ax,4
	mov	iw.i16dp,ax

	mov	ax,iw.p3xr
	add	ax,5
	mov	iw.i8dp,ax

	mov	ax,iw.p3xr
	add	ax,7
	mov	iw.lmbdr,ax

	mov	al,32	;voices!!!!
	mov	iw.voices,al

	call	IwaveGusReset		;Place InterWave in GUS Mode
	mov	al,CODEC_MODE3
	call	IwaveCodecMode		;Default codec mode


	_poke	iw.igidxr,99h
	_peek	iw.i8dp
	mov	iw.smode,al

	_poke	iw.igidxr,19h
	mov	al,iw.smode
	or	al,ENH_MODE
	_poke	iw.i8dp,al


	xor	eax,eax
	mov	iw.smode,ENH_MODE		;Synth Mode
	call	IwaveMemSize
	mov	iw.size_mem,eax		;Bytes of RAM in this mode

	mov	GUS_DramSize,eax
	mov	GUS_DramSize2,eax

	mov	ah,0
	mov	al,_CLOAI
	call	IwaveLineLevel

	mov	ah,0
	mov	al,_CROAI
	call	IwaveLineLevel

	mov	ah,OFF
	mov	al,_CLOAI
	call	IwaveLineMute

	mov	ah,OFF
	mov	al,_CROAI
	call	IwaveLineMute

	_poke	iw.pcodar,_CFIG3I OR 20h
	_poke	iw.cdatap,0C2h		;Enable Mode 3 IRQs & Synth
	_poke	iw.p2xr,0Bh		;Disable line in, mic and line out
	_poke	iw.igidxr,_URSTI
	_poke	iw.i8dp,GF1_SET OR GF1_OUT_ENABLE OR GF1_IRQ_ENABLE
	popad
	ret
IwaveOpen	EndP


;########################################################################
;
; FUNCTION: IwavePnpPing
;
; PROFILE: This function allows the caller to detect an InterWave based
;	   adapter board and will return its asigned CSN so that an
;	   an application can access its PnP interface and determine the
;	   borad's current configuration. In conducting its search for
;	   the InterWave IC, the function will use the first 32 bits of
;	   the Serial Identifier called the vendor ID in the PnP ISA
;	   spec. The last 4 bits in the Vendor ID represent a revision
;	   number for the particular product and will not be included
;	   in the search. The function will return the Vendor ID and the
;	   calling application should check the revision bits to make
;	   sure they are compatible with the board.
;
;in : EAX=vendor id
;out: AL =CSN
;########################################################################
IwavePnpPing	Proc	Near
	push	ebx ecx edx edi esi ebp

	mov	esi,eax
	and	esi,0FFFFFFF0h		;reset 4 least significant bits
	call	IwavePnpKey		;Key to access PnP Interface

@@NextPort:
	mov	ecx,10
	mov	eax,1
@@Loopen:
	call	IwavePnpWake		;Select card, eax=csn

	push	ecx
	mov	dx,iw.pnprdp
	mov	ecx,4
	lea	edi,iw.vendor
	call	IwavePnpPeek		;get vendor ID
	pop	ecx

;	mov	ebx,iw.vendor
;	and	ebx,0FFFFFFF0h
;	cmp	esi,ebx
;	jnz	@@NoCard

;...
	cmp	iw.pnprdp,20bh
	jnz     @@NoCard
;...

	_poke	_PIDXR,02h		;Place all cards in wait-for-key state
	_poke	0A79h,02h

@@_ret_clc:
	pop	ebp esi edi edx ecx ebx
	clc
	ret

@@NoCard:
	inc	eax
	loop	@@Loopen
	add	iw.pnprdp,4
	cmp	iw.pnprdp,23Fh
	jbe	@@NextPort

@@_ret_stc:
	_poke	_PIDXR,02h		;Place all cards in wait-for-key state
	_poke	0A79h,02h
	pop	ebp esi edi edx ecx ebx
	stc
	ret
IwavePnpPing	EndP

;########################################################################
;
; FUNCTION: IwavePnpKey
;
; PROFILE: This function issues the initiation key that places the PNP
;	   logic into configuration mode. The PNP logic is quiescent at
;	   power up and must be enabled by software. This function will
;	   do 32 I/O writes to the PIDXR (0x0279). The function will
;	   first reset the LFSR to its initial value by a sequence of two
;	   write cycles of 0x00 to PIDXR before issuing the key.
;
;########################################################################
CodeTbl	db	06ah,0b5h,0dah,0edh,0f6h,0fbh,07dh,0beh,0dfh,06fh,037h,01bh,0dh,086h,0c3h,061h,0b0h,058h,02ch,016h,08bh,045h,0a2h,0d1h,0e8h,074h,03ah,09dh,0ceh,0e7h,073h,039h

IwavePnpKey	Proc	Near
	pushad

;###############################################
;  Reset Linear Feedback Shift Reg.
;###############################################
	_poke	0279h,0
	_poke	0279h,0

	lea	esi,CodeTbl
	mov	ecx,32

@@Loopen:
	lodsb
	_poke	0279h,al

	loop	@@Loopen

	popad
	ret
IwavePnpKey	EndP


;########################################################################
;
; FUNCTION: IwavePnpWake
;
; PROFILE: This function issues a WAKE[CSN] command to the InterWave. If
;	   the CSN matches the PNP state machine will enter the
;	   configuration state. Otherwise it will enter the sleep mode.
;
;	   It is assumed that the PNP state machine is not in the
;	   "wait for key" state.
;
;in: al=csn
;########################################################################
IwavePnpWake	Proc	Near
	pushad
	cli
	_poke	_PIDXR,_PWAKEI		;select PWAKEI
	_poke	_PNPWRP,al		;write csn
	sti
	popad
	ret
IwavePnpWake	EndP

;#########################################################################
;
; FUNCTION: IwavePnpGetCfg
;
; PROFILE: This function reads the PnP registers of the InterWave card
;	   with the specified CSN and fills the configuration members of
;	   an variable "iw". This function is called at the start of
;	   a InterWave sound application to query the InterWave IC for
;	   configuration of I/O space, DMA and IRQ channels.
;
;	   This function assumes that the card has been properly
;	   configured and that it is in the configuration mode so that
;	   its configuration registers can be read.
;
;#########################################################################
IwavePnpGetCfg	Proc	Near
	pushad
	cli

;#########################################################################
; Read in the I/O space, DMA and IRQ configurations for the audio device.
;#########################################################################

	mov	al,AUDIO
	call	IwavePnpDevice

	_poke	_PIDXR,60h			;select P2X0HI
	_peek	iw.pnprdp			;get P2XR[9:8]
	shl	ax,8
	_poke	_PIDXR,61h			;select P2XRLI
	_peek	iw.pnprdp			;get P2XR[7:4]
	mov	iw.p2xr,ax
	mov	SoundCard_BasePort,ax

	_poke	_PIDXR,62h			;select P3X0HI
	_peek	iw.pnprdp			;get P3XR[9:8]
	shl	ax,8
	_poke	_PIDXR,63h			;select P3X0LI
	_peek	iw.pnprdp			;get P3XR[7:3]
	mov	iw.p3xr,ax

	_poke	_PIDXR,64h			;select PHCAI
	_peek	iw.pnprdp
	shl	ax,8				;get PCODAR[9:8]
	_poke	_PIDXR,65h			;select PLCAI
	_peek	iw.pnprdp
	mov	iw.pcodar,ax			;get PCODAR[7:2]
	mov	SoundCard_BasePort2,ax

	_poke	_PIDXR,70h			;select PUI1SI
	_peek	iw.pnprdp			;Synth IRQ number
	and	ax,0Fh
	mov	iw.synth_irq,ax
	mov	SoundCard_IRQ,al


	_poke	_PIDXR,72h			;select PUI2SI
	_peek	iw.pnprdp
	and	ax,0Fh				;MIDI IRQ number
	mov	iw.midi_irq,ax
	mov	SoundCard_MIDIIRQ,al

	_poke	_PIDXR,74h			;select PUD1SI
	_peek	iw.pnprdp
	and	ax,07h				;DMA1 chan (LMC/Codec Rec)
	mov	iw.dma1_chan,ax
	mov	SoundCard_DMA1,al

	_poke	_PIDXR,75h			;select PUD2SI
	_peek	iw.pnprdp
	and	ax,07h				;DMA2 chan (codec play)
	mov	iw.dma2_chan,ax
	mov	SoundCard_DMA2,al


;######################################################
; To get External Device resource configuration
; select the External Device.
;#######################################################
comment %
  IwavePnpDevice(EXT);			     /* select external device */
  _poke(_PIDXR,0x60);			     /* select PRAHI */
  val = ((WORD)_peek(iw.pnprdp))<<8;	     /* get PCDRAR[9:8] */
  _poke(_PIDXR,0x61);			     /* select PRALI */
  iw.pcdrar=val+(WORD)_peek(iw.pnprdp);      /* get PCDRAR[7:4] */
  _poke(_PIDXR,0x62);			     /* select PATAHI */
  val = ((WORD)_peek(iw.pnprdp))<<8;	     /* get PATAAR[9:8] */
  _poke(_PIDXR,0x63);			     /* select PATALI */
  iw.pataar=val+(WORD)_peek(iw.pnprdp);      /* get PATAAR[7:1] */

  _poke(_PIDXR,0x70);			     /* select PRISI */
  iw.ext_irq=(WORD)(_peek(iw.pnprdp)&0x0F);  /* Ext Dev IRQ number */

  _poke(_PIDXR,0x74);			     /* select PRDSI */
  iw.ext_chan=_peek(iw.pnprdp)&0x07;	     /* Ext Dev DMA channel */

  IwavePnpDevice(MPU401);		     /* Select MPU401 Device */
  _poke(_PIDXR,0x60);			     /* select P401HI */
  val = ((WORD)_peek(iw.pnprdp))<<8;	     /* get P401AR[9:8] */
  _poke(_PIDXR,0x61);			     /* select P401LI */
  iw.p401ar=val+(WORD)_peek(iw.pnprdp);      /* get P401AR[7:1] */

  _poke(_PIDXR,0x70);			     /* select PMISI */
  iw.mpu_irq=(WORD)(_peek(iw.pnprdp)&0x0F);  /* MPU401 Dev IRQ number */

  IwavePnpDevice(GAME); 		     /* Select GAME logical Device */
	_poke(_PIDXR,0x60);                       /* select P201HI */
  val = ((WORD)_peek(iw.pnprdp))<<8;	     /* get P201AR[9:8] */
  _poke(_PIDXR,0x61);			     /* select P201LI */
  iw.p201ar=val+(WORD)_peek(iw.pnprdp);      /* get P201AR[7:6] */

  IwavePnpDevice(EMULATION);		     /* Select SB and ADLIB Device */
  _poke(_PIDXR,0x60);			     /* select P388HI */
  val=((WORD)_peek(iw.pnprdp))<<8;	     /* get P388AR[9:8] */
  _poke(_PIDXR,0x61);			     /* select P388LI */
  iw.p388ar=val+_peek(iw.pnprdp);	     /* get P388AR[7:6] */
  _poke(_PIDXR,0x70);			     /* select PSBISI */
  iw.emul_irq=(WORD)(_peek(iw.pnprdp)&0x0F); /* emulation Dev IRQ number */
  LEAVE_CRITICAL;
%

 	sti
	popad
	ret
IwavePnpGetCfg	EndP

;#########################################################################
;
; FUNCTION: IwaveGusReset
;
; PROFILE: This function resets the InterWave to place it in GUS
;	   mode. The following registers are affected as indicated:
;
;	   1. SGMI[0]=0. GUS Compatible mode.
;	   2. LDICI, LDMACI, UASRR, UASBCI, LMFSI are all reset.
;	   3. URSTI[2:1], LMCI[1:0], UADR[7:5,1:0] are reset.
;
;	   Also, interrupts associated with a write to UI2XCR,
;	   with a write to UADR (UISR[4]) and all synthesizer
;	   interrupts.
;#########################################################################
IwaveGusReset	Proc	Near
	pushad

	_poke	iw.igidxr,_URSTI	;Pull reset
	_poke	iw.i8dp,0
	mov	al,1
	call	IwaveDelay
	_poke	iw.i8dp,01		;Release reset
	mov	al,1
	call	IwaveDelay

	popad
	ret
IwaveGusReset	EndP

;########################################################################
;
; FUNTION : IwaveCodecMode
;
; PROFILE: This function allows to switch between the diferent modes
;	   of codec operation. The following calls illustrate the
;	   usage: IwaveCodecMode(CODEC_MODE3) puts the codec in mode 3.
;
;in al=mode
;########################################################################
IwaveCodecMode	Proc	Near
	pushad
	cli
	mov	bl,al
	_peek	iw.pcodar
	and	al,0E0h
	or	al,_CMODEI
	_poke	iw.pcodar,al		;select CMODEI
	_poke	iw.cdatap,bl
	sti
	mov	iw.cmode,bl

	popad
	ret
IwaveCodecMode	EndP

;########################################################################
;
;  FUNCTION: IwaveMemSize
;
;  PROFILE: This function returns the number of Kbytes available as
;	    local memory attached to the InterWave IC. The value returned
;	    by this function reflects the actual amount of DRAM that can
;	    be accessed based on the mode of operation of the InterWave.
;	    This is determined by SGMI[ENH].
;
;out eax=memsize
;
;########################################################################
IwaveMemSize	Proc	Near
	push	ebx edi

	mov	bl,55h		;BYTE datum = 0x55;
	xor	edi,edi		;ADDRESS local = 0L;

	_poke	iw.igidxr,_LMCI
	_peek	iw.i8dp
	and	al,0FDh
	_poke	iw.i8dp,al		;DRAM I/O cycles selected

@@Again:
	call	IwaveMemPoke		;poke bl
	call	IwaveMemPeek		;peek al
	cmp	al,bl
	jnz	@@NoMoreRam

	inc	bl
	inc	edi

	call	IwaveMemPoke		;poke bl
	call	IwaveMemPeek		;peek al
	dec	edi
	cmp	al,bl
	jnz	@@NoMoreRam

	add	edi,RAM_STEP
	jmp	@@Again

@@NoMoreRam:
;	shr	edi,10
	mov	eax,edi

	pop	edi ebx
	ret
IwaveMemSize	EndP


;########################################################################
;
; FUNTION : IwaveLineLevel
;
; PROFILE: This function allows the calling program to control the level
;	   of attenuation or gain for inputs or outputs to or from the
;	   InterWave IC:
;
;	   - the AUX1/Synth line input (left and right)
;	   - the AUX2 line input (left and right)
;	   - the left and right line outputs
;	   - the left and right line inputs
;
;	   The first argument is a boolean type of argument. Set it to
;	   the desired level of gain or attenuation. The second argument
;	   is an index to a register. Set it to any of the following:
;
;	   - _CLAX1I or LEFT_AUX1_INPUT    (All modes)
;	   - _CRAX1I or RIGHT_AUX1_INPUT
;	   - _CLAX2I or LEFT_AUX2_INPUT    (All modes)
;	   - _CRAX2I or RIGHT_AUX2_INPUT
;	   - _CLOAI or LEFT_LINE_OUT	   (Mode 3 only)
;	   - _CROAI or RIGHT_LINE_OUT
;	   - _CLMICI or LEFT_MIC_IN	   (Mode 3 only)
;	   - _CRMICI or RIGHT_MIC_IN
;	   - _CLLICI or LEFT_LINE_IN	   (Modes 2 and 3)
;	   - _CRLICI or RIGHT_LINE_IN
;in:
;ah=level
;al=index
;
;########################################################################
IwaveLineLevel	Proc	Near
	pushad

	mov	bx,ax

	and	bh,01Fh

	cli
	_peek	iw.pcodar
	and	al,0E0h
	or	al,bl
	_poke	iw.pcodar,al			;select register
	_peek	iw.cdatap
	and	al,080h
	or	al,bh
	_poke	iw.cdatap,al			;set level

	sti
	popad
	ret
IwaveLineLevel	EndP

;########################################################################
;
; FUNTION : IwaveLineMute
;
; PROFILE: This function allows the calling program to mute or unmute
;	   the following inputs or outputs to/from the InterWave IC:
;
;	   - the AUX1/Synth line input (left and right)
;	   - the AUX2 line input
;	   - the left and right line outputs
;	   - the left and right line inputs
;
;	   The first argument is a boolean type of argument. Set it to
;	   ON to mute or OFF to unmute. The second argument is an index
;	  to a register. Set it to any of the following:
;
;	   - _CLAX1I or LEFT_AUX1_INPUT  (All modes)
;	   - _CRAX1I or RIGHT_AUX1_INPUT
;	   - _CLAX2I or LEFT_AUX2_INPUT  (All modes)
;	   - _CRAX2I or RIGHT_AUX2_INPUT
;	   - _CLOAI or LEFT_LINE_OUT	 (Mode 3 only)
;	   - _CROAI or RIGHT_LINE_OUT
;	   - _CLMICI or LEFT_MIC_IN	 (Mode 3 only)
;	   - _CRMICI or RIGHT_MIC_IN
;	   - _CLLICI or LEFT_LINE_IN	 (Modes 2 & 3)
;	   - _CRLICI or RIGHT_LINE_IN
;	   - _CLDACI or LEFT_DAC	 (All modes)
;	   - _CRDACI or RIGHT_DAC
;
;in:
;ah=mute
;al=index
;
;########################################################################
IwaveLineMute	Proc	Near
	pushad

	mov	bx,ax
	cli

	_peek	iw.pcodar
	and	al,0E0h
	or	al,bl
	_poke	iw.pcodar,al			;select register

	cmp	bh,ON
	jnz	@@noOn
	_peek	iw.cdatap
	or	al,080h
	_poke	iw.cdatap,al			;mute
	jmp	@@noOff
@@noOn:
	_peek	iw.cdatap
	and	al,07Fh				;unmute
	_poke	iw.cdatap,al
@@noOff:
	sti
	popad
	ret
IwaveLineMute	EndP

;########################################################################
;
; FUNCTION: IwavePnpPeek
;
; PROFILE: This function will return the number of specified bytes of
;	   resource data from the serial EEPROM. The function will NOT
;	   reset the serial EEPROM logic to allow reading the entire
;	   EEPROM by issuing repeated calls. The caller must supply a
;	   pointer to where the data are to be stored.
;	   It is assumed that the InterWave is not in either "sleep"
;	   or "wait for key" states. Note that on the first call, if
;	   the caller means to read from the beginning of data the
;	   serial EEPROM logic must be reset. For this, the caller
;	   should issue a WAKE[CSN] command
;
;dx=port
;ecx=bytes
;[edi]=buffer
;########################################################################
;(PORT pnprdp, WORD bytes, BYTE *data)
IwavePnpPeek	Proc	Near
	pushad

@@BigLoopen:
	_poke	_PIDXR,05h		;select PRESSI

@@Loopen:				;wait til new data byte is ready
	_peek	dx
	test	al,PNP_DATA_RDY
	jz	@@Loopen

	_poke	_PIDXR,04h		;select PRESDI
	_peek	dx			;read resource byte
	stosb
	loop	@@BigLoopen

	popad
	ret
IwavePnpPeek	EndP

;########################################################################
;   FUNCTION : IwaveMemPoke
;
;   PROFILE  : This function writes a byte of data to local memory (LM)
;	       in an expansion card containing the InterWave IC.
;bl=datum
;edi=addr
;########################################################################
;(ADDRESS addr, BYTE datum)
IwaveMemPoke	Proc	Near
	pushad
	mov	ecx,edi

	_poke	iw.igidxr,43h		;Select LMALI
	_pokew	iw.i16dp,cx		;Lower 16 bits of LM
	_poke	iw.igidxr,44h		;Select LMAHI
	shr	ecx,16
	_poke	iw.i8dp,cl		;Upper 8 bits of LM
	_poke	iw.lmbdr,bl		;Write byte to LMBDR

	popad
	ret
IwaveMemPoke	EndP

;########################################################################
;
;	FUNCTION: IwaveDelay
;
;	PROFILE:  This function can be called to cause a delay of up to
;	     52 milliseconds during program execution. The argument
;	     specifies the number of milliseconds to block and should
;	     be a value in the range 1 to 52.
;
;al=delay
;########################################################################
IwaveDelay	Proc	Near
	pushad

	and	ax,0ffh			;count
	mov	bx,1193
	mul	bx
	mov	cx,ax			;count
	mov	dx,ax			;last count

	_peek	61h
	and	al,0FCh
	mov	bl,al			;portb

	_poke	061h,bl			;disable counter
	_poke	043h,0B0h		;load LSB first then MSB
	_poke	042h,cl
	_poke	042h,ch
	mov	bh,bl
	or	bh,1
	_poke	061h,bh			;enable counter

@@Again:
	_poke	043h,080h		;latch counter
	_peek	042h			;read latched value, lsb
	shl	ax,8
	_peek	042h                    ;read latched value, msb
	rol	ax,8			;cur_cnt

	cmp	ax,dx			;cur_cnt,last
	ja	@@Break
	mov	dx,ax			;last,cur_cnt
	cmp	ax,cx			;cur_cnt,count
	jbe	@@Again

@@Break:
	_poke	061h,bl			;disable counter

	popad
	ret
IwaveDelay	EndP


;########################################################################
;
; FUNCTION: IwavePnpDevice
;
; PROFILE: This function allows the caller to select between five
;	   logical devices available on the InterWave.It is assumed
;	   that the PNP state machine is in configuration mode.
;IN al=dev
;
;
;########################################################################
;void IwavePnpDevice(BYTE dev)
IwavePnpDevice	Proc	Near
	cli
	_poke	_PIDXR,_PLDNI		;select PLDNI
	_poke	_PNPWRP,al		;write PLDNI
	sti
	ret
IwavePnpDevice	EndP


;########################################################################
;
;   FUNCTION : IwaveMemPeek
;
;   PROFILE  : This function reads a byte of data from local memory in a
;	       card containing the InterWave IC. It does so via LMBDR and
;	       the user must specify a local memery address to read from
;	       via argument "addr".
;IN:  edi=addr
;OUT: al=value
;
;########################################################################
;BYTE IwaveMemPeek(ADDRESS addr)
IwaveMemPeek	Proc	Near
	push	ebx

	mov	ebx,edi

	_poke	iw.igidxr,043h		;Select LMALI
	_pokew	iw.i16dp,bx		;Lower 16 bits of LM
	_poke	iw.igidxr,044h		;Select LMAHI
	shr	ebx,16
	_poke	iw.i8dp,bl		;Upper 8 bits of LM
	_peek	iw.lmbdr		;return byte from LMBDR

	pop	ebx
	ret
IwaveMemPeek	EndP







;#########################################################################
;
; FUNCTION: IwaveSetInterface
;
; PROFILE: This function initializes DMA and IRQ structures defined by
;	   the application for interrupt handling and DMA transfers. The
;	   function takes pointers to such structures. If the application
;	   will not use a particular interrupt or dma service the
;	   respective pointer should be set to NULL.
;
;
;#########################################################################
;void IwaveSetInterface(DMA *dma1,DMA *dma2,IRQ *irq1,IRQ *irq2)
;udci	db	0
;uici	db	0
IwaveSetInterface	Proc	Near
comment �

 IRQ *irq_ptr;
 DMA *dma_ptr;
 int irq_no;
 int dma_chan;

	cli
	_poke	iw.igidxr,_IVERI
	_peek	iw.i8dp
	or	al,09h
	_poke	iw.i8dp,al		;enable access & reads

	_peek	iw.p2xr
	or	al,40h
	_poke	iw.p2xr,al		;set UMCR[6]=1

	mov	bx,iw.p2xr
	add	bx,0fh
	_peek	bx
	and	al,0F8h
	mov	bx,iw.p2xr
	add	bx,0Fh			;URCR[2:0]=0
	_poke	bx,al

	mov	bx,iw.p2xr
	add	bx,0Bh
	_peek	bx			;read UICI
	mov	uici,al

	_peek	iw.p2xr
	and	al,0BFh
	_poke	iw.p2xr,al		;set UMCR[6]=0

	mov	bx,iw.p2xr
	add	bx,0Bh			;read UDCI
	_peek	bx
	mov	udci,al

	_peek	iw.i8dp
	and	al,0F6h
	_poke	iw.i8dp,al		;disable access & reads
	sti


 if(uici&0x40 && udci&0x80)		       /* all sources to IRQ2 */
	{
	  if (irq2!=(IRQ *)NULL)
			irq1=irq2;
	  else
			irq2=irq1;
	  iw.synth_irq=iw.midi_irq;
	}
 else
	if (uici&0x40)                               /* all sources to IRQ1 */
		{
			  if (irq1!=(IRQ *)NULL)
					irq2=irq1;
			  else
					irq1=irq2;
			  iw.midi_irq=iw.synth_irq;
		}

 if(udci&0x40)			  /* all sources to DMA chan 1 */
	{
	  if (dma1!=(DMA *)NULL)
			dma2=dma1;
	  else
			dma1=dma2;
	  iw.dma2_chan=iw.dma1_chan;
	}

 iw.synth=irq1; 		 /* init pointers to structures */
 iw.midi=irq2;
 iw.dma1=dma1;
 iw.dma2=dma2;

//#########################################################
//  Now initialize IRQ structures if applicable.
//#########################################################

 for (i=1; i<=2; i++)
 {
	if(i==1)
	 {
	  irq_no = iw.synth_irq;
	  irq_ptr = iw.synth;
	 }
	else
	 {
	  irq_no = iw.midi_irq;
	  irq_ptr = iw.midi;
	 }

	if (irq_ptr!=(IRQ *)NULL)
	 {
	  if (irq_no > 7)
		  {
			irq_ptr->imr=IMR2;
			irq_ptr->ocr=OCR2;
		  }
	  else
		  {
			irq_ptr->imr=IMR1;
			irq_ptr->ocr=OCR1;
		  }

	  irq_ptr->spec_eoi=0x60+(irq_no&0x07);
	  irq_ptr->mask=~(1<<(irq_no&0x07));

	}
 }
//###########################################################
//  Now initialize DMA structures if applicable.
//###########################################################
 for (i=1; i<=2; i++)
 {
  if(i==1)
	 {
	  dma_chan = iw.dma1_chan;
	  dma_ptr = iw.dma1;
	 }
  else
	 {
	  dma_chan = iw.dma2_chan;
	  dma_ptr = iw.dma2;
	 }

  if (dma_ptr!=(DMA *)NULL)
	{
	 BYTE channel;
	 channel = dma_chan&0x03;
	 dma_ptr->flags=0x00;
	 dma_ptr->channel=dma_chan;
	 dma_ptr->enable = channel;
	 dma_ptr->disable= channel|DMA_SET_MASK;
	 dma_ptr->cur_mode=channel;
	 dma_ptr->write= channel|0x44;           /* upload mode */
	 dma_ptr->read=channel|0x48;             /* download mode */
	 dma_ptr->cur_control=0x00;

	 if (dma_chan < 3)
	  {
		 dma_ptr->single= DMA1_SNGL;
		 dma_ptr->mode = DMA1_MODE;
		 dma_ptr->clear_ff=DMA1_CLRFF;
	  }
	 else
	  {
		 dma_ptr->single= DMA2_SNGL;
		 dma_ptr->mode = DMA2_MODE;
		 dma_ptr->clear_ff=DMA2_CLRFF;
	  }

	 switch(dma_chan)
	 {
		case 0:
		dma_ptr->addr=DMA0_ADDR;
		dma_ptr->page=DMA0_PAGE;
		dma_ptr->count=DMA0_CNT;
		break;
		case 1:
		dma_ptr->addr=DMA1_ADDR;
		dma_ptr->page=DMA1_PAGE;
		dma_ptr->count=DMA1_CNT;
		break;
		case 2:
		dma_ptr->addr=DMA2_ADDR;
		dma_ptr->page=DMA2_PAGE;
		dma_ptr->count=DMA2_CNT;
		break;
		case 3:
		dma_ptr->addr=DMA3_ADDR;
		dma_ptr->page=DMA3_PAGE;
		dma_ptr->count=DMA3_CNT;
		break;
		case 4:
		dma_ptr->addr=DMA4_ADDR;
		dma_ptr->page=DMA4_PAGE;
		dma_ptr->count=DMA4_CNT;
		break;
		case 5:
		dma_ptr->addr=DMA5_ADDR;
		dma_ptr->page=DMA5_PAGE;
		dma_ptr->count=DMA5_CNT;
		break;
		case 6:
		dma_ptr->addr=DMA6_ADDR;
		dma_ptr->page=DMA6_PAGE;
		dma_ptr->count=DMA6_CNT;
		break;
		case 7:
		dma_ptr->addr=DMA7_ADDR;
		dma_ptr->page=DMA7_PAGE;
		dma_ptr->count=DMA7_CNT;
		break;
	 }
  }
 }
 IwaveSetIvt();
 IwaveUmaskIrqs();



�
	ret
IwaveSetInterface	EndP





;#########################################################################
;
; FUNCTION: IwaveClose
;
; PROFILE: This function closes down a DDK application. It disables the
;	   sound output, line in and mic input. It also restores the
;	   PC's interrupt vector table.
;
;#########################################################################
IwaveClose	Proc	Near
	pushad

	mov	al,CODEC_MODE3
	call	IwaveCodecMode
	_poke	iw.pcodar,_CFIG3I OR 0x20
	_poke	iw.cdatap,0C2h		;Enable Mode 3 IRQs & Synth

	mov	ah,0
	mov	al,_CLOAI
	call	IwaveLineLevel

	mov	ah,0
	mov	al,_CROAI
	call	IwaveLineLevel

	mov	ah,ON
	mov	al,_CLOAI
	call	IwaveLineMute

	mov	ah,ON
	mov	al,_CROAI
	call	IwaveLineMute

	_poke	iw.p2xr,03h		;Disable inputs and mute outputs
	call	IwaveGusReset		;Reset InterWave board back to GUS Mode
;	call	IwaveMaskIrqs
;  if (iw.flags&IW_HANDLERS_ON)
;      IwaveResetIvt();
;  return(TRUE);

	popad
	ret
IwaveClose	EndP




