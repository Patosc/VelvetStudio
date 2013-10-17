

;/ABS\02631011010061001061004430044300443004430066101081
SBExtraBuffer	equ	0

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ SBP Variables ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

SB_MixerIndex	 dw	04h
SB_MixerData	 dw	05h
SB_Reset	 dw	06h
SB_ReadData	 dw	0ah
SB_WriteData	 dw	0ch
SB_DataAvailable dw	0eh
SB_16bIntAck	 dw	0fh
SB_MIDIPort	 dw	00h

; *** NOTE: Use higher latency rates for better keyboard synchronization.

DMALATENCYRATE	 equ	50	;DMA latency rate (in hertz)
DMABUFDIVSIZE	 equ	512	;DMA buffer and division sizes (in bytes)
DMABUFFERSIZE	 equ	8*DMABUFDIVSIZE

SB_DMABufferSize dd	0	;DMA buffer size (in bytes)
SB_DMABufferPtr  dd	0	;DMA buffer relative pointer (in bytes)

PlayFreq	 dd	45454	;The requested Hertz
RealPlayFreq	 dd	0	;The approx hertz supported by hardware
SB_Freq 	 dw	0
SB_Stereo	 db	0	;1 If to do Stereo output
SB_16Bits	 db	0	;1 If to do 16 Bits output

SB_StereoHW	 db	0	;1 If Stereo Supported by SoundCard
SB_16BitsHW	 db	0	;1 If 16 Bits output is supported by SC
SB_StereoAllowed db	1	;0 if to force MONO
SB_16BitsAllowed db	1	;0 if to force 8 bits
Amplification	 db	60h	;The amplification constant

DSPVersion	 dw	0	;SB DSP version number

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Procedures ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;Beep	Proc	Near
;	pushad
;	mov	V86R_AH,2
;	mov	V86R_DL,7
;	mov	al,21h
;	int	33h
;	popad
;	ret
;Beep	EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Set the Volume for a specific Channel
;Calls: EAX=Volume, EDI=Channel
;-------------------------------
SBP_SetVolume:
	push	eax
	shl	eax,9
	mov	[M_Volume+edi*4],eax
	pop	eax
	ret


;-------------------------------
;Set the Output level to Zero
;Calls: none
;-------------------------------
Global SBP_SetZeroVol:Near,SBP_SetOrigVol:Near
SBP_SetZeroVol:
;	call	DMAStop
	call	SB_ResetDSP

;Test
;	push	ax
;	mov	ah,[SoundCard_DMA1]	;Shut Down Play DMA
;	cmp	[SB_16Bits],0
;	je	@@Use8BitDMA
;	mov	ah,[SoundCard_DMA2]
;@@Use8BitDMA:
;	call	DMA_Shutdown
;	pop	ax
	jmp	SBP_SpeakerOff


;-------------------------------
;Set the Output level back to original
;Calls: none
;-------------------------------
SBP_SetOrigVol:
	pushad
	mov	esi,SoundCard
	call	SC_ChangeReplay
	popad
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Command #10h, Change Looping of playing sound
;ax=Command
;ebx=Sample
;edi=Channel
;-------------------------------
SBP_CMD10:
	cmp	al,2				;values above 2 aren't allowed
	ja	_ret
	cmp	al,1				;if to start bwd loop
	jz	@@Backwards
	cmp	al,2				;if to start bidi loop
	jz	@@PingPongOn

	btr	[PlayDirection],edi		;Forward
	btr	[PlayDirection+4],edi
	mov	eax,[SampleOffsetEnd+ebx*4]
	mov	[M_SampleEnd+edi*4],eax
	mov	eax,[M_SampleSpeed+edi*4]
	test	eax,eax
	jge	@@SetVoiceControl
	neg	eax
	mov	[M_SampleSpeed+edi*4],eax
	jmp	@@SetVoiceControl

@@Backwards:
	bts	[PlayDirection],edi		;Backward
	btr	[PlayDirection+4],edi
	mov	eax,[SampleOffsetStart+ebx*4]
	mov	[M_SampleEnd+edi*4],eax
	mov	eax,[M_SampleSpeed+edi*4]
	test	eax,eax
	jle	@@SetVoiceControl
	neg	eax
	mov	[M_SampleSpeed+edi*4],eax
	jmp	@@SetVoiceControl

@@PingPongOn:
	test	[VoiceControl+ebx],00001000b	;PingPong
	jz	_ret
	bts	[PlayDirection+4],edi

@@SetVoiceControl:
	mov	al,[M_VoiceControl+edi] 	;set looping bits
	and	al,10101111b
	xor	ah,ah
	bt	[PlayDirection],edi
	rcl	ah,2
	bt	[PlayDirection+4],edi
	rcl	ah,5
	or	al,ah
	mov	[M_VoiceControl+edi],al
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Command #E8, Break loop of current playing (looped) sample
;edi=Voice
;-------------------------------
SBP_CMDE8:
	and	[M_VoiceControl+edi*4],11110111b	;remove loop flag.
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Stops the playback of one voice
;Calls: ecx+1  = Voice to stop
;-------------------------------
SBP_StopOneVoice:
	push	ecx eax
	dec	ecx
	xor	eax,eax
	mov	[M_VoiceControl+ecx],al
	mov	[M_SampleSpeed+ecx*4],eax
	mov	[M_SampleFrac+ecx*4],eax
	mov	eax,[M_SampleEnd+ecx*4]
	mov	[M_SamplePtr+ecx*4],eax
	pop	eax ecx
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Sets the freq for specified voice
;calls: edi=chan
;-------------------------------
SBP_SetTheFreq:
	pushad

	cmp	LinFreq,1
	jz	SBP_LinearFreq

	movzx	ecx,[CurrNoteTable+edi]
	sub	ecx,2
	ConvertNote ecx ecx

	sub	cx,[VibPeriod+edi*2]		 ;428*4*8363*C2
	add	cx,[VibratoTable+edi*2] 	 ;--------------
	add	cx,[FineTuneTable+edi*2]	 ;16*8363*period
	add	ecx,[SlideTable+edi*4]
	jecxz	SBP_EndFreq

	imul	ecx,[RealPlayFreq]		;use 16.16 fixed point
	mov	eax,428*8363*16
	xor	edx,edx
	shld	edx,eax,16
	shl	eax,16
	div	ecx

	cmp	[M_SampleSpeed+edi*4],0
	setg	dl
	test	[M_VoiceControl+edi],01000000b
	sete	dh
	or	dl,dh
	jne	@@ForwardRepeat
	neg	eax
@@ForwardRepeat:
	mov	[M_SampleSpeed+edi*4],eax
SBP_EndFreq:
	popad
	ret


SBP_LinearFreq:
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
	mov	ebx,4000000h
	div	ebx

	xor	edx,edx 			;use 16.16 fixed point
	shld	edx,eax,16
	shl	eax,16
	mov	ebx,[RealPlayFreq]
	div	ebx

	cmp	[M_SampleSpeed+edi*4],0
	setg	dl
	test	[M_VoiceControl+edi],01000000b
	sete	dh
	or	dl,dh
	jne	@@ForwardRepeat
	neg	eax
@@ForwardRepeat:
	mov	[M_SampleSpeed+edi*4],eax
	popad
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Sets up needed info before playing a sample
;Calls: EBX = Sample #
;	EDI = Channel
;-------------------------------
SBP_PlayVoice:
	and	ebx,0fffh		;Check for sample 0
	jz	_ret			;if not, fall through to next proc.

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Same as SBP_PlayVoice but also used by Keyboard
;-------------------------------
SBP_KeyBoardPlayVoice:
	pushad

	mov	al,[VoiceControl+ebx]		;grab sample control bits
	xor	ah,ah
	btr	[PlayDirection],edi		;force backward?
	rcl	ah,2
	btr	[PlayDirection+4],edi		;force pingpong?
	rcl	ah,5
	or	al,ah
	mov	[__VoiceCtrl],al		;udubl6pp

	mov	eax,[SampleOffsetStart+ebx*4]	;grab sample start/end points
	mov	edx,[SampleOffsetEnd+ebx*4]
	test	[__VoiceCtrl],01000000b
	je	@@SetSamplePoints		;swap them for backward mode?
	xchg	eax,edx
@@SetSamplePoints:
	mov	[__SampleStart],eax
	mov	[__SampleEnd],edx

	mov	eax,[LoopStart+ebx*4]		;grab sample looping points
	mov	edx,[LoopEnd+ebx*4]
	mov	[__LoopStart],eax
	mov	[__LoopEnd],edx
	cmp	eax,edx 			;disable looping?
	sete	al
	btr	[SpecialBreakByte],edi
	setc	ah
	or	al,ah
	shl	al,3
	not	al
	and	[__VoiceCtrl],al

	mov	eax,[M_SampleSpeed+edi*4]	;grab channel sample speed
	test	eax,eax
	setl	cl
	test	[__VoiceCtrl],01000000b
	sete	ch
	xor	cl,ch
	jne	@@SetSampleSpeed		;need to change sign?
	neg	eax
@@SetSampleSpeed:
	mov	[__SampleSpeed],eax

	test	[SkipFlag+edi*2],00008h 	;set sample offset
	je	@@SetMixVariables
	test	[__VoiceCtrl],01000000b
	je	@@ChangeSampleStart
	mov	eax,[SampleOffsetStart+ebx*4]
	mov	[__SampleStart],eax
	mov	[__SampleEnd],eax
@@ChangeSampleStart:
	movzx	eax,[SampOffset+edi]
	shl	eax,8
	add	[__SampleStart],eax

@@SetMixVariables:
	CLI					;critical zone
	mov	al,[__VoiceCtrl]
	mov	[M_VoiceControl+edi],al
	mov	eax,[__SampleStart]
	mov	[M_SamplePtr+edi*4],eax
	mov	eax,[__SampleEnd]
	mov	[M_SampleEnd+edi*4],eax
	mov	eax,[__LoopStart]
	mov	[M_LoopStart+edi*4],eax
	mov	eax,[__LoopEnd]
	mov	[M_LoopEnd+edi*4],eax
	mov	eax,[__SampleSpeed]
	mov	[M_SampleSpeed+edi*4],eax
	STI

	btr	EnvPanCheck,edi
	jc	@@PanPotSet

	mov	ah,[FineTunes+ebx]
	and	ah,0f0h
	jz	@@ChanPanPot
	mov	[CurrentChannelPanPot+edi],ah
	jmp	@@PanPotSet

@@ChanPanPot:
	mov	ah,[PanPosition+edi]
	mov	[CurrentChannelPanPot+edi],ah

@@PanPotSet:
	bts	EnvPanCheck,edi

	mov	ecx,1
	call	ENV_NextChannel
	popad
	ret

__VoiceCtrl	db	?
__SampleStart	dd	?
__SampleEnd	dd	?
__LoopStart	dd	?
__LoopEnd	dd	?
__SampleSpeed	dd	?


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Activates all the Channels for playback
;-------------------------------
SBP_StartTheChannels:
	pushad
	movzx	ecx,Channels
	xor	edi,edi
@@StartChannels:
	btr	KBDPlayFlag,edi
	jc	@@StartKBD3

	test	[SkipFlag+edi*2],00004h
	jnz	@@SkipPlayVoice2

@@StartKBD3:
	movzx	ebx,CurrentSample
	cmp	[CurrSample+edi*2],bx
	jnz	@@SkipPlayVoice2
	mov	LastVoice,di
@@SkipPlayVoice2:
	or	[SkipFlag+edi*2],00004h
	inc	edi
	loop	@@StartChannels
	popad
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Sets the Panpot for the channel
;Calls:  ah=panpot
;	 edi=channel
;-------------------------------
SBP_SetPanPot:
	push	eax			; *** MODIFIED:
	shr	ah,4			; *** The previous code was swapping
	test	ah,8			; *** L/R channels and scaling up
	setne	al			; *** volume levels.
	add	al,ah
	mov	ah,[EnvPanPot+edi]
	shr	ah,4
	sub	ah,8
	add	al,ah
	jge	@@PanBel1
	xor	al,al
@@PanBel1:
	cmp	al,16
	jle	@@PanBel2
	mov	al,16
@@PanBel2:
	and	eax,1fh
	mov	[M_SamplePanR+edi*4],eax
	neg	eax
	add	eax,16
	mov	[M_SamplePanL+edi*4],eax
	pop	eax
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Sets up needed info for max # of channels
;-------------------------------
SBP_ChangeActiveVoices:
	jmp	CreateVolTable



;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
SBP_MainMixer:
IFE	Player
	pushad
	mov	SampleBits,dh
	mov	Stereo,dl
	mov	bp,ax
	shr	bh,4		;Volume
	shr	bx,4
	mov	ah,bl
	mov	al,6		;CD Vol
	call	SBP_Mixer
	mov	al,7		;Line In Vol
	call	SBP_Mixer
	shr	ah,5
	mov	al,8		;Mic Vol
	call	SBP_Mixer

	cmp	DSPVersion,400h
	jae	@@SB16
	xor	ax,ax		;Source
	cmp	ch,1		;MIC
	jz	@@DO
	add	ah,2
	cmp	bp,1		;CD
	jz	@@DO
	add	ah,4		;Line In
	cmp	cl,1
	jz	@@DO
	popad
	ret
@@DO:
	call	SBP_Mixer
	popad
	ret

@@SB16:
	mov	ax,bp		;CD In
	shl	ax,2
	shl	cl,4
	or	al,cl		;Line In
	mov	cl,al
	shr	cl,1
	or	al,ch		;Mic In. Left Inp
	or	cl,ch		;Mic In. Right Inp
	mov	ah,al
	mov	al,3dh		;Input Control Left
	call	WriteMixer
	mov	ah,cl
	mov	al,3eh		;Input Control Right
	call	WriteMixer
	and	cl,not 1
	shl	cl,1
	or	ah,cl
	mov	al,3ch		;Output control
	call	WriteMixer

;	mov	al,43h		;AGC
;	mov	ah,1
;	call	WriteMixer
	popad
ENDIF
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Mixer.
;ah=Data,al=Index
;Index:
;00h=ADC Source
;  00h=Mic 1
;  02h=CD
;  04h=Mic 2
;  06h=Line in
;
;01h=ADC Filter
;  00h=Low
;  08h=High
;  10h=No Filter
;
;02h=DAC Filter
;  00h=Filter On
;  20h=Filter Off
;
;03h=Master Volume
;  LRh=volume 0-15 L/R
;
;04h=DSP Volume
;  LRh=volume 0-15 L/R
;
;05h=FM Volume
;  LRh=volume 0-15 L/R
;
;06h=CD Volume
;  LRh=volume 0-15 L/R
;
;07h=Line in Volume
;  LRh=volume 0-15 L/R
;
;08h=Mic Volume
;  0M=volume 0-7 Mono

;Not yet supported:
;030h	    Master Volume Left				Read/Write  SB16*
;031h	    Master Volume Right 			Read/Write  SB16*
;032h	    DAC Level Left				Read/Write  SB16*
;033h	    DAC Level Right				Read/Write  SB16*
;034h	    FM Level Left				Read/Write  SB16*
;035h	    FM Level Right				Read/Write  SB16*
;036h	    CD Audio Level Left 			Read/Write  SB16*
;037h	    CD Audio Level Right			Read/Write  SB16*
;038h	    Line In Level Left				Read/Write  SB16*
;039h	    Line In Level Right 			Read/Write  SB16*
;03Ah	    Microphone Level				Read/Write  SB16
;03Bh	    PC Speaker Level				Read/Write  SB16
;03Ch	    Output Control				Read/Write  SB16
;03Dh	    Input Control Left				Read/Write  SB16
;03Eh	    Input Control Right 			Read/Write  SB16
;03Fh	    Input Gain Control Left			Read/Write  SB16
;040h	    Input Gain Control Right			Read/Write  SB16
;041h	    Output Gain Control Left			Read/Write  SB16
;042h	    Output Gain Control Right			Read/Write  SB16
;043h	    Automatic Gain Control (AGC)		Read/Write  SB16
;044h	    Treble Left 				Read/Write  SB16
;045h	    Treble Right				Read/Write  SB16
;046h	    Bass Left					Read/Write  SB16
;047h	    Bass Right					Read/Write  SB16
;-------------------------------
SBP_MixerTBL	db	0ch,0ch,0eh,22h,04h,26h,28h,2eh,0ah
SBP_Mixer:
	push	ebx
	movzx	ebx,al
	mov	bl,[SBP_MixerTBL+ebx]
	xchg	al,bl
	cmp	bl,0
	jz	SBP_ADCSource
	cmp	bl,1
	jz	SBP_ADCFilter
	mov	bl,2
	jz	SBP_DACFilter

WriteSBPMixer:
	call	WriteMixer
	pop	ebx
	ret

SBP_ADCSource:
	mov	bl,ah
	call	ReadMixer
	and	ah,11111001b
	or	ah,bl
	jmp	WriteSBPMixer
SBP_ADCFilter:
	mov	bl,ah
	call	ReadMixer
	and	ah,11000111b
	or	ah,bl
	jmp	WriteSBPMixer
SBP_DACFilter:
	mov	bl,ah
	call	ReadMixer
	and	ah,11011111b
	or	ah,bl
	jmp	WriteSBPMixer
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Init Sampling.
;-------------------------------
SBP_FixStartSample:
IFE	Player
	pushad
	mov	ecx,[AllocTable+1024*8+4]
	mov	SampleSize,ecx
	popad
ENDIF
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
; Init Sampling, Called at startup (Popup on)
; Calls: None
;-------------------------------
SBP_StartADC:
IFE	Player
	pushad
	cli

	call	SB_ResetDSP		;ShutDown Play DMA
	mov	ah,[SoundCard_DMA1]
	cmp	[SB_16Bits],0
	je	@@Use8BitDMA
	mov	ah,[SoundCard_DMA2]
@@Use8BitDMA:
	call	DMA_ShutDown

	mov	ah,[SoundCard_DMA1]	;ShutDown REC DMA
	cmp	[SampleBits],0
	je	@@Use8BitDMA2
	mov	ah,[SoundCard_DMA2]
@@Use8BitDMA2:
	call	DMA_ShutDown
;	call	SBP_SpeakerOn
	mov	SampleConvert,0

	mov	SamplingBuffOff,0
	mov	DMAPlay_TC,0

	call	SBP_ChangeSamplingFreq

	mov	ecx,GUS_RollOverDataSize
	shr	ecx,1
	mov	ebx,DMABuffer_Phys
	mov	al,01000100b		;DMA mode register (read)
	mov	ah,[SoundCard_DMA1]	;8 bits only
	call	DMA_setup		;Do it

	cmp	SoundCard,4		;Ordinary SB can't handle High Speed
	jz	@@NoHighSpeed

;	mov	al,Stereo		;Stereo/Mono Input, SB PRO Only
;	shl	al,3
;	or	al,0a0h
;	call	WriteDSP

	mov	ax,048h 		;DSP Command, >23KHz
	call	WriteDSP

	dec	ecx
	mov	al,cl
	call	WriteDSP		;LSB (xfer count-1)

	mov	al,ch
	call	WriteDSP		;MSB (xfer count-1)

	mov	ax,098h 		;Start
	call	WriteDSP
	sti
	popad
	ret

@@NoHighSpeed:
	mov	ax,024h 		;DSP Command, <23KHz
	call	WriteDSP

	dec	ecx
	mov	al,cl
	call	WriteDSP		;LSB (xfer count-1)

	mov	al,ch
	call	WriteDSP		;MSB (xfer count-1)
	sti
	popad
ENDIF
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
; Reset Sampling, Called at end (Big Popup off)
; Calls: None
;-------------------------------
SBP_StopADC:
IFE	Player
	pushad

	call	SB_ResetDSP
;	call	DMAStop

	mov	Sampling,0
	mov	DMAPlay_TC,0
	mov	ah,[SoundCard_DMA1]	;Shut Down REC DMA
	cmp	[SampleBits],0
	je	@@Use8BitDMA
	mov	ah,[SoundCard_DMA2]
@@Use8BitDMA:
	call	DMA_ShutDown

	mov	esi,SoundCard
	call	InitSCVariables
	jmp	SBP_ReInitSoundCard

	popad
ENDIF
	ret

;-------------------------------
; Init Sampling, Called at startup (Popup on)
; Calls: None
;-------------------------------
SB16_StartADC:
IFE	Player
	pushad
	cli

	call	SB_ResetDSP		;Shut Down Play DMA
	mov	ah,[SoundCard_DMA1]
	cmp	[SB_16Bits],0
	je	@@Use8BitDMA
	mov	ah,[SoundCard_DMA2]
@@Use8BitDMA:
	call	DMA_ShutDown

	mov	ah,[SoundCard_DMA1]	;Shut Down REC DMA
	cmp	[SB_16Bits],0
	je	@@Use8BitDMA2
	mov	ah,[SoundCard_DMA2]
@@Use8BitDMA2:
	call	DMA_ShutDown
;	call	SBP_SpeakerOn
	mov	SampleConvert,0

	mov	SamplingBuffOff,0
	mov	DMAPlay_TC,0

	mov	ecx,GUS_RollOverDataSize
	shr	ecx,1
	mov	ebx,DMABuffer_Phys
	mov	al,01010100b		;DMA mode register (read)
	mov	ah,[SoundCard_DMA1]
	cmp	[SampleBits],0
	je	@@Use8BitDMA3
	mov	ah,[SoundCard_DMA2]
@@Use8BitDMA3:
	call	DMA_setup		;Do it

	movzx	ax,SampleBits
	shl	ax,4
	xor	ax,10h
	add	ax,0b0h 		;DSP Command
	or	al,1010b
	call	WriteDSP

	mov	al,Stereo
	shl	al,5
	call	WriteDSP

	dec	ecx
	mov	al,cl
	call	WriteDSP		;LSB (xfer count-1)

	mov	al,ch
	call	WriteDSP		;MSB (xfer count-1)

	sti
	popad
ENDIF
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Change the Freq to sample with
;-------------------------------
Samp_Freq	dw	0
SBP_ChangeSamplingFreq:
IFE	Player
	pushad
	movzx	ebx,SampleFreq
	cmp	ebx,0
	jz	_retp

	mov	Samp_Freq,bx
	mov	GUSSampleFreq,bx

	cmp	SoundCard,3
	jz	@@NoTimeConstant

	call	SB_ResetDSP
	mov	eax,1000000		;(256 - 1000000 DIV (Channels*Freq));
	movzx	ebx,SampleFreq
	xor	edx,edx
	div	ebx
	mov	ebx,256
	sub	ebx,eax
	mov	Samp_Freq,bx

	mov	eax,1000000		;Get true replay speed
	movzx	ebx,SampleFreq
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	mov	eax,1000000
	xor	edx,edx
	div	ebx
	mov	GUSSampleFreq,ax

;	call	DMAStop 		;
	mov	al,40h
	call	WriteDSP
	mov	ax,Samp_Freq		;(256 - 1000000 DIV Freq)
	call	WriteDSP
;	call	DMAContinue		;
	jmp	@@ContStartDMA
@@NoTimeConstant:
	mov	al,42h
	call	WriteDSP
	mov	al,bh
	call	WriteDSP
	mov	al,bl
	call	WriteDSP
@@ContStartDMA:
	popad
ENDIF
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Gets the "Red Line" pos
;ax=voice
;-------------------------------
SBP_GetCurrAdd:
IFE	Player
	push	eax
	mov	eax,[M_SamplePtr+eax*4]
	mov	CurrAdd,eax
	pop	eax
ENDIF
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Sets the "Red Line" pos
;-------------------------------
SBP_SetCurrAdd:
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Update the sample loop pointers
;-------------------------------
SBP_SetSampleLoop:
	pushad
	movzx	edi,LastVoice
	movzx	ebx,CurrentSample

;	 cmp	 [M_PitchDec+edi*4],0
;	 jz	 _retp			 ;Not Running

	mov	eax,[LoopStart+ebx*4]
	mov	[M_LoopStart+edi*4],eax
	mov	eax,[LoopEnd+ebx*4]
	mov	[M_LoopEnd+edi*4],eax
	popad
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Move the TuneFork sample to Playing mem.
; calls:  EAX	- Destination
;	  EBX	- Source
;	  ECX	- Bytes to dump
;	   DL	- 128 = Conv, 0 = No Conv
;-------------------------------
SBP_MoveTuneForkSample:
IFE	Player
	pushad
	mov	esi,ebx
	mov	edi,eax
	rep	movsb
	popad
ENDIF
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
irq_stub_buf4	db	21 dup(?)
Old_PM_Vec4	df	0
Old_RM_Vec4	dd	0
;-------------------------------
;Initialization of the SoundCard
;calls:  None
;-------------------------------
SBP_InitSoundCard:
	pushad

	call	SB_GetVolumes

	mov	ax,SoundCard_BasePort
	add	SB_MixerIndex,ax
	add	SB_MixerData,ax
	add	SB_Reset,ax
	add	SB_ReadData,ax
	add	SB_WriteData,ax
	add	SB_DataAvailable,ax
	call	SB_ResetDSP
	jc	SoundCardError

	mov	ax,0E1h 		;Get DSP Version
	call	WriteDSP
	call	ReadDSP
	mov	byte ptr [DSPVersion+1],al
	call	ReadDSP
	mov	byte ptr [DSPVersion],al

	mov	esi,SoundCard
	call	InitSCVariables
	call	CalcTimerRate
	mov	TimerRate,ax

IF TRANVERSION		;\\
	mov	bl,SoundCard_IRQ	;Set New IRQ Vector  (PM)
	lea	edx,SBP_IRQ
	call	_setirqvect

	mov	bl,SoundCard_IRQ	;Set New IRQ Vector  (RM)
	lea	edx,SBP_IRQ
	lea	edi,irq_stub_buf4	;set real mode IRQ callback
	call	_rmpmirqset
	mov	Old_RM_Vec4,eax 	;store old real mode IRQ vector
ENDIF			;//

IF DOS32VERSION	OR PMODEWVERSION	;\\
	mov	bl,SoundCard_IRQ	;Set New IRQ Vector  (PM)
	call	_getirqvect
	mov	dword ptr Old_PM_Vec4,edx
	mov	word ptr Old_PM_Vec4+4,cx

	mov	bl,SoundCard_IRQ	;Set New IRQ Vector  (PM)
	lea	edx,SBP_IRQ
	mov	cx,cs
	call	_setirqvect
ENDIF			;//

	mov	bl,SoundCard_IRQ	;Enable IRQ
	xor	al,al
	call	_setirqmask

SBP_ReInitSoundCard:

	mov	eax,RealPlayFreq	;Set DMA buffer size in bytes
	mov	cl,SB_Stereo		;using proper block alignment
	add	cl,SB_16Bits
	shl	eax,cl
	xor	edx,edx
	mov	ebx,DMALATENCYRATE
	div	ebx
	add	eax,DMABUFDIVSIZE
	and	eax,-DMABUFDIVSIZE
	add	eax,eax
	cmp	eax,DMABUFFERSIZE
	jbe	@@SetBufferSize
	mov	eax,DMABUFFERSIZE
@@SetBufferSize:
	shr	eax,cl
	shl	eax,cl
	mov	SB_DMABufferSize,eax

	mov	edi,DMABuffer		;Clear DMA buffer
	mov	ecx,SB_DMABufferSize

	xor	al,al
	cmp	SB_16Bits,0		; *** MODIFIED:
	sete	al			; *** Clean using signed samples
	shl	al,7			; *** for 16-bit output mode.
	rep	stosb

	xor	eax,eax 		; *** MODIFIED:
	mov	SB_DMABufferPtr,eax	; *** Initialize buffer pointer.

	call	SBP_SpeakerOn
	call	SB_StartDMA		;Start the DMA Transfer
	popad
	clc
	ret

SoundCardError:
	popad
	stc
	ret


SB_MasterSave	db	0
SB_DSPSave	db	0
SB_FMSave	db	0
SB_CDSave	db	0
SB_LineSave	db	0
SB_MicSave	db	0

SB_GetVolumes	Proc	Near
	pushad
	mov	ax,0			;Reset Mixer
	call	WriteMixer

	mov	al,22h
	call	ReadMixer
	mov	SB_MasterSave,ah
	mov	al,04h
	call	ReadMixer
	mov	SB_DSPSave,ah
	mov	al,26h
	call	ReadMixer
	mov	SB_FMSave,ah
	mov	al,28h
	call	ReadMixer
	mov	SB_CDSave,ah
	mov	al,2eh
	call	ReadMixer
	mov	SB_LineSave,ah
	mov	al,0ah
	call	ReadMixer
	mov	SB_MicSave,ah
	popad
	ret
SB_GetVolumes	EndP

SB_SetVolumes	Proc	Near
	pushad
	mov	ax,0			;Reset Mixer
	call	WriteMixer

	mov	al,03h			;Set various Volumes
	mov	ah,SB_MasterSave
	call	SBP_Mixer
	mov	al,04h
	mov	ah,SB_DSPSave
	call	SBP_Mixer
	mov	al,05h
	mov	ah,SB_FMSave
	call	SBP_Mixer
	mov	al,06h
	mov	ah,SB_CDSave
	call	SBP_Mixer
	mov	al,07h
	mov	ah,SB_LineSave
	call	SBP_Mixer
	mov	al,08h
	mov	ah,SB_MicSave
	call	SBP_Mixer
	popad
	ret
SB_SetVolumes	EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Deinitializes the SoundCard
;calls:  none
;-------------------------------
SBP_DeInitSoundCard:
	pushad
	call	SB_ResetDSP
	call	SBP_SpeakerOff

IF TRANVERSION		;\\
	mov	bl,SoundCard_IRQ		;Set Old IRQ Vector
	mov	eax,Old_RM_Vec4 		;Restore old real mode IRQ vector
	call	_rmpmirqfree
ENDIF			;//


IF DOS32VERSION OR PMODEWVERSION		;\\
	mov	bl,SoundCard_IRQ		;Set Old IRQ Vector  (PM)
	mov	edx,dword ptr Old_PM_Vec4
	mov	cx,word ptr Old_PM_Vec4+4
	call	_setirqvect
ENDIF			;//

	mov	ah,[SoundCard_DMA1]		;Shut Down Play DMA
	cmp	[SB_16Bits],0
	je	@@Use8BitDMA
	mov	ah,[SoundCard_DMA2]
@@Use8BitDMA:
	call	DMA_shutdown

	call	SB_SetVolumes

	popad
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;The Interrupt handler
;calls:  none
;-------------------------------
;xxxxxxxxxxxxxxxxxxxxxxxxx
SBP_IRQ Proc	Near
	pushad
	pushfd
	push	gs ds es
	mov	ds,cs:_seldata
	mov	es,cs:_seldata
	mov	gs,cs:_selzero
	cld

	cmp	Sampling,0
	jnz	SB_SamplingReset

	mov	dx,SB_DataAvailable	; *** MODIFIED:
	add	dl,SB_16Bits		; *** The acknowledge of 16-bit
	in	al,dx			; *** transfers must use 2XFh.

;	mov	ecx,SB_DMABufferSize	; *** MODIFIED:
;	dec	ecx			; *** Play the whole DMA buffer.
	call	SBP_ReInitDMA

	jmp	SB_Exit_ISR
SB_SamplingReset:
	mov	dx,SB_DataAvailable	; *** MODIFIED:
	add	dl,SampleBits		; *** The acknowledge of 16-bit
	in	al,dx			; *** transfers must use 2XFh.

	mov	DMAPlay_TC,1

	cmp	Sampling,3
	jz	SB_Exit_Fnutte

	mov	ecx,GUS_RollOverDataSize
	shr	ecx,1
	xor	SamplingBuffOff,ecx

	mov	ebx,DMABuffer_Phys
	add	ebx,SamplingBuffOff
	mov	al,01010100b		;DMA mode register (read from SB)
	mov	ah,[SoundCard_DMA1]
	cmp	[SampleBits],0
	je	@@Use8BitDMA2
	mov	ah,[SoundCard_DMA2]
@@Use8BitDMA2:
	call	DMA_setup		;Do it

	cmp	DSPVersion,400h 	;SB 16
	jae	@@SB16

	cmp	SoundCard,2		;SB PRO is Auto Initializing
	jz	SB_Exit_ISR

	mov	ax,024h 		;DSP Command
	call	WriteDSP

	dec	ecx
	mov	al,cl
	call	WriteDSP		;LSB (xfer count-1)

	mov	al,ch
	call	WriteDSP		;MSB (xfer count-1)
	jmp	SB_Exit_ISR

@@SB16:
	movzx	ax,SampleBits
	shl	ax,4
	xor	ax,10h
	add	ax,0b0h 		;DSP Command
	or	al,1010b		;A/D,SC,FIFO=On
	call	WriteDSP

	mov	al,Stereo
	shl	al,5
	call	WriteDSP

	cmp	SampleBits,0
	jz	@@Skutt
	shr	ecx,1
@@Skutt:
	dec	ecx
	mov	al,cl
	call	WriteDSP		;LSB (xfer count-1)

	mov	al,ch
	call	WriteDSP		;MSB (xfer count-1)
	jmp	SB_Exit_ISR

SB_Exit_Fnutte:
	call	SBP_StopADC
	jmp	SB_Exit_ISR

SB_Exit_ISR:
	mov	al,020h 		;EOI to PICs
	out	0A0h,al
	out	020h,al

	pop	es ds gs
	popfd
	popad
	sti
	iRetD
SBP_IRQ EndP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-------------------------------
;Start the timer
;calls:  none
;-------------------------------
SBP_StartTimer:
	cmp	IntsON,1
	jz	_ret
	mov	IntsON,1
	jmp	StartInts

;-------------------------------
;Stop the timer
;calls:  none
;-------------------------------
SBP_StopTimer:
	cmp	IntsON,0
	jz	_ret
	mov	IntsON,0
	jmp	StopInts


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-----------------------------
;Write a byte to DSP.
;calls: al=Data
;-----------------------------
WriteDSP	Proc	Near
	push	ax dx
	push	ax
	mov	dx,SB_WriteData
Wait_SBDSP:
	in	al,dx
	test	al,80h
	jnz	Wait_SBDSP
	pop	ax
	out	dx,al
	pop	dx ax
	ret
WriteDSP	EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-----------------------------
;Write a byte to the Mixer.
;calls: ah=Data, al=Index
;-----------------------------
WriteMixer	Proc	Near
	push	ax dx
	mov	dx,SB_MixerIndex
	out	dx,al
	mov	dx,SB_MixerData
	mov	al,ah
	out	dx,al
	pop	dx ax
	ret
WriteMixer	EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-----------------------------
;Reads the Mixer.
;calls: al=Index
;out	ah=Data
;-----------------------------
ReadMixer	Proc	Near
	push	dx
	mov	dx,SB_MixerIndex
	out	dx,al
	mov	dx,SB_MixerData
	mov	ah,al
	in	al,dx
	xchg	ah,al
	pop	dx
	ret
ReadMixer	EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-----------------------------
;Read a byte from DSP.
;out: al=Data
;-----------------------------
ReadDSP Proc	Near
	push	dx
Wait_SBDSP2:
	mov	dx,SB_DataAvailable
	in	al,dx
	test	al,80h
	jz	Wait_SBDSP2
	mov	dx,SB_ReadData
	in	al,dx
	pop	dx
	ret
ReadDSP EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-----------------------------
;Turn the speaker on
;calls: none
;-----------------------------
SBP_SpeakerOn	Proc	Near
	push	ax
	mov	al,0D1h
	call	WriteDSP
	pop	ax
	ret
SBP_SpeakerOn	EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-----------------------------
;Turn the speaker off
;calls: none
;-----------------------------
SBP_SpeakerOff	Proc	Near
	push	ax
	mov	al,0D3h
	call	WriteDSP
	pop	ax
	ret
SBP_SpeakerOff	EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-----------------------------
;Stop DMA-transfer
;calls: none
;-----------------------------
DMAStop Proc	Near
	push	ax
	mov	al,0D0h
	call	WriteDSP
	pop	ax
	ret
DMAStop EndP


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-----------------------------
;Continue DMA-transfer
;calls: none
;-----------------------------
DMAContinue	Proc	Near
	push	ax
	mov	al,0D4h
	call	WriteDSP
	pop	ax
	ret
DMAContinue	EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-----------------------------
;Reset the DSP
;calls: none
;-----------------------------
SB_ResetDSP	Proc	near
	push	eax
	push	ebx
	push	ecx
	push	edx
	mov	ebx,64			;try to reset upto 64 times
sbresetl1:
	mov	dx,SB_Reset
	mov	al,1			;write 1 to the reset port (2X6h)
	out	dx,al

	xor	ah,ah			;wait at least 3 microseconds
sbresetl2:
	in	al,dx
	dec	ah
	jnz	sbresetl2

	xor	al,al			;write 0 to the reset port (2X6h)
	out	dx,al
	mov	dx,SB_DataAvailable

	mov	ecx,0400h		;wait until the data available
sbresetl0:				;status port (2XEh) bit 7 is set
	in	al,dx
	test	al,80h
	loopz	sbresetl0

	mov	dx,SB_ReadData		;read the read data port (2XAh)
	in	al,dx
	cmp	al,0AAh
	clc
	jz	sbresetd0		;check the ready byte value
	dec	ebx
	jnz	sbresetl1
	stc
sbresetd0:
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret
SB_ResetDSP	EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;-----------------------------
;Start the DMA-transfer
;calls: none
;-----------------------------
SB_StartDMA	Proc	Near
	pushad

	mov	ebx,DMABuffer_Phys
	mov	ecx,SB_DMABufferSize

	mov	al,01011000b		;DMA mode register (Write To Card)
	mov	ah,SoundCard_DMA1	;Channel number ( 0..7 )

	cmp	SB_16Bits,0		; *** MODIFIED:
	je	@@Use8BitDMA		; *** The high DMA channel must
	mov	ah,SoundCard_DMA2	; *** be used for 16-bit transfers.
@@Use8BitDMA:
	call	DMA_Setup		;Do it

	cmp	DSPVersion,400h
	jae	@@NoTimeConstant
	mov	al,40h
	call	WriteDSP
	mov	ax,SB_Freq		;(256 - 1000000 DIV Freq)
	call	WriteDSP
	jmp	ContStartDMA
@@NoTimeConstant:
	mov	al,41h
	call	WriteDSP
	mov	bx,SB_Freq
	mov	al,bh
	call	WriteDSP
	mov	al,bl
	call	WriteDSP

ContStartDMA:
	mov	eax,SB_DMABufferSize	; *** MODIFIED:
;;;	shr	eax,1			; *** The DMA buffer size is
	mov	cl,SB_16Bits		; *** given in samples to the
	shr	eax,cl			; *** SB DSP chip.
	mov	ecx,eax
	dec	ecx
	call	SBP_InitDMA

	popad
	ret
SB_StartDMA	EndP


;-----------------------------
;Initializes DMA transfer mode
;calls: ecx=size
;-----------------------------
SBP_InitDMA	Proc	Near
	pushad
	cmp	DSPVersion,400h
	jae	short @@SB16HighSpeed
	cmp	DSPVersion,200h
	jae	short @@SB20HighSpeed

	mov	al,14h			;normal DMA 8-bit DAC
	call	WriteDSP

	mov	al,cl
	call	WriteDSP		;LSB (xfer count-1)

	mov	al,ch
	call	WriteDSP		;MSB (xfer count-1)
	popad
	ret

@@SB20HighSpeed:			;high speed DMA setup (SB2.0 or up)

	mov	al,48h
	call	WriteDSP		;set block length

	mov	al,cl
	call	WriteDSP		;LSB (xfer count-1)

	mov	al,ch
	call	WriteDSP		;MSB (xfer count-1)

	mov	al,90h			;high-speed 8-bit DMA DAC
	call	WriteDSP

	popad
	ret

@@SB16HighSpeed:
	push	ecx			; *** MODIFIED:
	mov	eax,0b6c6h		; *** Select autoinit, 8/16-bit,
	mov	cl,SB_16Bits		; *** DAC, FIFO, high speed mode.
	shl	cl,3
	shr	eax,cl
	pop	ecx
	call	WriteDSP

	mov	al,SB_Stereo		; *** MODIFIED:
	shl	al,5			; *** Select mono/stereo and
	mov	ah,SB_16Bits		; *** signed/unsigned mode.
	shl	ah,4
	or	al,ah
	call	WriteDSP

	mov	al,cl
	call	WriteDSP		;LSB (xfer count-1)

	mov	al,ch
	call	WriteDSP		;MSB (xfer count-1)
	popad
	ret
SBP_InitDMA	EndP

;-----------------------------
;Re-Initializes DMA transfer mode
;calls: none
;-----------------------------
SBP_ReInitDMA	  Proc	  Near
	pushad
	cmp	DSPVersion,200h
	jae	_retp

	mov	al,14h			; normal DMA 8-bit DAC
	call	WriteDSP

	mov	al,cl
	call	WriteDSP		; LSB (xfer count-1)

	mov	al,ch
	call	WriteDSP		; MSB (xfer count-1)
	popad
	ret
SBP_ReInitDMA	  EndP

BlasterEnv	db	'BLASTER='
BlasterLen	equ	 $-BlasterEnv
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Read Environment
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;Reads the Environment variables
;
; Calls: None
;
; Out:
; Carry=1 No Variable found
; Caryy=0 Variable found
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

;BLASTER=Aa Ii Dd Hh Pp Tt
;  Aa - Base Address			 210,220,230,240,250,260,280
;  Ii - Interrupt Request		      2, 3, 5, 7, 10
;  Dd - DMA Channel, 8-bit			 0, 1, 3
;  Hh - DMA Channel, 16-bit			 5, 6, 7
;  Pp - Base MIDI Address			 300,330
;  Tt - Model			     1(1.x), 2(Pro), 3(2.0), 4(Pro2.0),
;					   5(ProMCV), 6(SB16, AWE32)
;
;NOTE: 16-bit DMA definition may actually refer to an 8-bit DMA alias.


SB_ModelTBL	db	0,4,2,4,2,2,3		; *** MODIFIED:
						; *** Assign identifier (4)
						; *** for SB10/SB20 cards.
SB_IRQTransl	db	0,10,2,3,0,5,0,7


IF TRANVERSION		;\\
AMS_GetSBEnv	Proc	Near
	pushad
	mov	edi,_pspa
	movzx	edi,word ptr gs:[edi+2Ch] ; Get the Environment segment value
	shl	edi,4
	lea	edx,BlasterEnv
@@CheckVar:
	mov	cl,BlasterLen
	mov	ebx,edx
@@ScanVar:
	mov	al,byte ptr gs:[edi]
	cmp	al,byte ptr [ebx]
	jnz	@@SkipVar
	inc	edi
	inc	ebx
	dec	cl
	jnz	@@ScanVar

@@ScanSBVar:
	mov	al,gs:[edi]
	cmp	al,'A'
	jz	@@GotBase
	cmp	al,'I'
	jz	@@GotIRQ
	cmp	al,'D'
	jz	@@GotDMA
	cmp	al,'H'
	jz	@@GotHDMA
	cmp	al,'P'
	jz	@@GotMIDI
	cmp	al,'T'
	jz	@@GotModel
	cmp	al,0
	jz	@@FoundSBVar
	inc	edi
	jmp	@@ScanSBVar

@@GotBase:
	inc	edi
	cmp	byte ptr gs:[edi],'2'
	jnz	@@GotBase
	movzx	ax,byte ptr gs:[edi+1]
	sub	ax,'0'
	shl	ax,4
	or	ax,200h
	mov	SoundCard_BasePort,ax
	jmp	@@ScanSBVar

@@GotIRQ:
	inc	edi
	mov	al,gs:[edi]
	cmp	al,'1'
	jb	@@GotIRQ
	cmp	al,'7'
	ja	@@GotIRQ
	sub	al,'0'
	and	eax,0fh
	mov	al,[SB_IRQTransl+eax]
	mov	SoundCard_IRQ,al
	jmp	@@ScanSBVar
@@GotDMA:
	inc	edi
	mov	al,gs:[edi]
	cmp	al,'0'
	jb	@@GotDMA
	cmp	al,'3'
	ja	@@GotDMA
	sub	al,'0'
	mov	SoundCard_DMA1,al
	jmp	@@ScanSBVar
@@GotHDMA:
	inc	edi
	mov	al,gs:[edi]
	cmp	al,'5'
	jb	@@GotHDMA
	cmp	al,'7'
	ja	@@GotHDMA
	sub	al,'0'
	mov	SoundCard_DMA2,al
	jmp	@@ScanSBVar
@@GotMIDI:
	inc	edi
	cmp	byte ptr gs:[edi],'3'
	jnz	@@GotBase
	movzx	ax,byte ptr gs:[edi+1]
	sub	ax,'0'
	shl	ax,4
	or	ax,300h
	mov	SB_MIDIPort,ax
	jmp	@@ScanSBVar
@@GotModel:
	inc	edi
	mov	al,gs:[edi]
	cmp	al,'1'
	jb	@@GotModel
	cmp	al,'6'
	ja	@@GotModel
	sub	al,'0'
	and	eax,0fh

	mov	SoundCardSub,0
	cmp	al,4
	jnz	NoSBP2
	mov	SoundCardSub,1
NoSBP2:
	cmp	al,1
	jnz	NoSB1
	mov	SoundCardSub,1
NoSB1:
	cmp	al,3
	jnz	NoSB2
	mov	SoundCardSub,2
NoSB2:
	movzx	eax,[SB_ModelTBL+eax]
	mov	SoundCard,eax
	jmp	@@ScanSBVar

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

@@FoundSBVar:
	cmp	SoundCard,0		; *** MODIFIED:
	jne	@@GotSCValue		; *** Set default SC identifier
	mov	SoundCard,4		; *** when Tn was not found.
@@GotSCValue:

	clc
	popad
	ret
AMS_GetSBEnv	EndP
ENDIF			;//




IF DOS32VERSION OR PMODEWVERSION		;\\
AMS_GetSBEnv	Proc	Near

IF	AUTODETECT_SC
	pushad
	mov	edi,_env
	lea	edx,BlasterEnv
@@CheckVar:
	mov	cl,BlasterLen
	mov	ebx,edx
@@ScanVar:
	mov	al,byte ptr [edi]
	cmp	al,byte ptr [ebx]
	jnz	@@SkipVar
	inc	edi
	inc	ebx
	dec	cl
	jnz	@@ScanVar

@@ScanSBVar:
	mov	al,[edi]
	cmp	al,'A'
	jz	@@GotBase
	cmp	al,'I'
	jz	@@GotIRQ
	cmp	al,'D'
	jz	@@GotDMA
	cmp	al,'H'
	jz	@@GotHDMA
	cmp	al,'P'
	jz	@@GotMIDI
	cmp	al,'T'
	jz	@@GotModel
	cmp	al,0
	jz	@@FoundSBVar
	inc	edi
	jmp	@@ScanSBVar

@@GotBase:
	inc	edi
	cmp	byte ptr [edi],'2'
	jnz	@@GotBase
	movzx	ax,byte ptr [edi+1]
	sub	ax,'0'
	shl	ax,4
	or	ax,200h
	mov	SoundCard_BasePort,ax
	jmp	@@ScanSBVar

@@GotIRQ:
	inc	edi
	mov	al,[edi]
	cmp	al,'1'
	jb	@@GotIRQ
	cmp	al,'7'
	ja	@@GotIRQ
	sub	al,'0'
	and	eax,0fh
	mov	al,[SB_IRQTransl+eax]
	mov	SoundCard_IRQ,al
	jmp	@@ScanSBVar
@@GotDMA:
	inc	edi
	mov	al,[edi]
	cmp	al,'0'
	jb	@@GotDMA
	cmp	al,'3'
	ja	@@GotDMA
	sub	al,'0'
	mov	SoundCard_DMA1,al
	jmp	@@ScanSBVar
@@GotHDMA:
	inc	edi
	mov	al,[edi]
	cmp	al,'5'
	jb	@@GotHDMA
	cmp	al,'7'
	ja	@@GotHDMA
	sub	al,'0'
	mov	SoundCard_DMA2,al
	jmp	@@ScanSBVar
@@GotMIDI:
	inc	edi
	cmp	byte ptr [edi],'3'
	jnz	@@GotBase
	movzx	ax,byte ptr [edi+1]
	sub	ax,'0'
	shl	ax,4
	or	ax,300h
	mov	SB_MIDIPort,ax
	jmp	@@ScanSBVar
@@GotModel:
	inc	edi
	mov	al,[edi]
	cmp	al,'1'
	jb	@@GotModel
	cmp	al,'6'
	ja	@@GotModel
	sub	al,'0'
	and	eax,0fh

	mov	SoundCardSub,0
	cmp	al,4
	jnz	NoSBP2
	mov	SoundCardSub,1
NoSBP2:
	cmp	al,1
	jnz	NoSB1
	mov	SoundCardSub,1
NoSB1:
	cmp	al,3
	jnz	NoSB2
	mov	SoundCardSub,2
NoSB2:
	movzx	eax,[SB_ModelTBL+eax]
	mov	SoundCard,eax
	jmp	@@ScanSBVar

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

@@FoundSBVar:
	cmp	SoundCard,0		; *** MODIFIED:
	jne	@@GotSCValue		; *** Set default SC identifier
	mov	SoundCard,4		; *** when Tn was not found.
@@GotSCValue:

	clc
	popad

ELSE
	stc
ENDIF
	ret
AMS_GetSBEnv	EndP
ENDIF			;//


;VolTable	dw	129*256 dup(0)	; *** MODIFIED:
;		db	512 dup(0)	; I allocate those buffers now
					; instead to save disk space
;PostTable	db	2048	dup(0)
PostTablePtr	dd	0

;-----------------------------
;Create the volume table
;calls: Channels
;-----------------------------
CreateVolTable	Proc	Near
	pushad
	mov	edi,VolTablePtr 	; *** MODIFIED:
	add	edi,511 		; *** The volume table is 512-byte
	and	edi,not 511		; *** aligned and adjusted for
	mov	VolTablePtr,edi 	; *** 8/16-bit playing modes.

	mov	eax,2047
	cmp	SB_16Bits,0
	je	@@GetVolumeInc
	mov	eax,65535
@@GetVolumeInc:
	xor	edx,edx
	shl	eax,8
	movzx	ebx,AllocChannels
	shl	ebx,7
	div	ebx
	mov	ebp,eax

	mov	ecx,129
	xor	ebx,ebx
	xor	eax,eax
@@BuildVolumeTable:
	push	eax
	movsx	eax,al
	imul	eax,ebx
	sar	eax,16
	stosw
	pop	eax
	inc	al
	jne	@@BuildVolumeTable
	add	ebx,ebp
	loop	@@BuildVolumeTable

	popad
	ret
CreateVolTable	EndP

Post_a		dd	0
Post_b		dd	0
Post_c		dd	0

;-----------------------------
;Creates the Post processing table
;calls: Amplification
;-----------------------------
CreatePostProcess	Proc	Near
	pushad
	cmp	SB_16Bits,1
	jz	SB_16Amp
	mov	edi,PostTablePtr

	mov	eax,2048*16		;2048*16/z
	xor	edx,edx
	movzx	ebx,Amplification
	div	ebx
	mov	ecx,eax 		;c
	mov	Post_c,eax
	mov	eax,2048
	sub	eax,ecx
	shr	eax,1			;a
	mov	Post_a,eax
	mov	Post_b,eax
	add	Post_b,ecx
	xor	ebp,ebp 		;x

	mov	ecx,2048
@@CreatePostLoop:
	xor	al,al
	cmp	ebp,Post_a
	jb	@@StorePost
	dec	al
	cmp	ebp,Post_b		; *** MODIFIED:
	jae	@@StorePost		; *** You must use JAE or you
	mov	eax,ebp 		; *** will hear small clicks.
	sub	eax,Post_a
	shl	eax,8
	mov	ebx,Post_c
	xor	edx,edx
	div	ebx
@@StorePost:
	stosb
	inc	ebp
	loop	@@CreatePostLoop

	popad
	ret
CreatePostProcess	EndP


SB_16Amp:
	mov	ah,1fh
	mov	al,3ch
	call	WriteMixer

	mov	ah,Amplification
	and	ah,11000000b
	mov	al,41h
	call	WriteMixer
	mov	al,42h
	call	WriteMixer

	and	ah,00000000b	;Input Gain
	mov	al,3fh
	call	WriteMixer
	mov	al,40h
	call	WriteMixer
	popad
	ret


HexTable	db	  '0123456789ABCDEF'
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Puts a Hex Value to text mode
;Calls:
;	EBX = Value to print
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

PutHex	Proc	Near
	Pushad
	mov	cl,8
	movzx	ecx,cl
	shl	ecx,2
	ror	ebx,cl
	shr	ecx,2
PutLoopen:
	xor	eax,eax
	shld	eax,ebx,4
	shl	ebx,4
	mov	dl,[HexTable+eax]
	mov	ah,2
	int	21h
;	inc	edi
	loop	PutLoopen

	mov	dl,'-'
	mov	ah,2
	int	21h

	mov	dl,'-'
	mov	ah,2
	int	21h

	Popad
	Ret
PutHex	EndP


Global	SBP_MixData:Near,M_SamplePtr:Dword:32,M_SampleEnd:Dword:32
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Mixing routine
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

;The following variables are the current values for each channel.

Align 4
PollRate	dw	0		;Counter for player update
PollRate_Init	dw	0		;Initial value
M_VoiceControl	db	32 dup(0)	;Control bits (udubl6pp)
M_SamplePtr	dd	32 dup(0)	;Sample pointer (integer part)
M_SampleFrac	dd	32 dup(0)	;Sample pointer (fractional part)
M_SampleSpeed	dd	32 dup(0)	;Sample speed (16.16 fixed point)
M_SampleEnd	dd	32 dup(0)	;Sample end point
M_LoopStart	dd	32 dup(0)	;Sample looping start point
M_LoopEnd	dd	32 dup(0)	;Sample looping end point
M_Volume	dd	32 dup(0)	;Sample volume
M_SamplePanL	dd	32 dup(0)	;Left panning (16 levels)
M_SamplePanR	dd	32 dup(0)	;Right panning (16 levels)


ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

Align 4
MixBuffer	dw	DMABUFDIVSIZE dup (?)	; 16-bit mixing buffer
MixBufSize	dd	?			; mixing buffer size
MixBufPtr	dd	?
MixSpinLock	dd	0
VolTablePtr	dd	?
MixSampleCount	dd	?
MixSampleProc	dd	offset MixMonoSample
		dd	offset MixStereoSample
		dd	offset MixMono16Sample
		dd	offset MixStereo16Sample

SetEntryOfs Macro Index
	Entry&Index = $
	EndM

GetEntryOfs Macro Index
	dd offset Entry&Index
	EndM

;----------------------------------------------------------------------------
; 8-bit mono sample mixing routine
; In:
;  EBX - channel number (x4)
;  EDI - mixing buffer address
;  ECX - number of samples
; Out:
;  EDI - mixing buffer address
;----------------------------------------------------------------------------
; WARNING: The lower 16-bits of the decimal overflow are unused.
;	   The volume table must be 512-byte aligned.
;----------------------------------------------------------------------------
MixMonoSample:
	push	ebx

	push	eax
	mov	eax,ecx
	and	eax,0fh
	shr	ecx,4
	lea	edi,[edi+eax*2-2*16]
	mov	eax,[MixMonoJumpTable+eax*4]
	mov	[esp],eax

	mov	esi,[M_SamplePtr+ebx]
	mov	eax,[M_SampleFrac+ebx]
	mov	ebp,[M_SampleSpeed+ebx]
	mov	edx,ebp
	sar	ebp,16
	shl	edx,16
	mov	ebx,[M_Volume+ebx]
	add	ebx,[VolTablePtr]
	shr	ebx,1
	retn

	Align 4
MixMonoSampleLoop:
	N=0
	REPT 16
	add	eax,edx
	mov	bl,[esi]
	adc	esi,ebp
	mov	ax,[ebx+ebx]
	add	[edi+2*N],ax
	SetEntryOfs %N
	N=N+1
	ENDM
	add	edi,2*16
	dec	ecx
	jge	MixMonoSampleLoop

	pop	ebx
	xor	ax,ax
	mov	[M_SamplePtr+ebx],esi
	mov	[M_SampleFrac+ebx],eax
	ret

	Align 4
MixMonoJumpTable label dword
	N=16
	REPT 16
	N=N-1
	GetEntryOfs %N
	ENDM

;----------------------------------------------------------------------------
; 8-bit stereo sample mixing routine
; In:
;  EBX - channel number (x4)
;  EDI - mixing buffer address
;  ECX - number of samples
; Out:
;  EDI - mixing buffer address
;----------------------------------------------------------------------------
; WARNING: The lower 16-bits of the decimal overflow are unused.
;	   The volume table must be 512-byte aligned.
;----------------------------------------------------------------------------
MixStereoSample:
	push	ebx

	push	eax
	mov	eax,ecx
	and	eax,0fh
	shr	ecx,4
	mov	[MixSampleCount],ecx
	lea	edi,[edi+eax*4-4*16]
	mov	eax,[MixStereoJumpTable+eax*4]
	mov	[esp],eax

	mov	esi,[M_SamplePtr+ebx]
	mov	eax,[M_SampleFrac+ebx]
	mov	ebp,[M_SampleSpeed+ebx]
	mov	edx,ebp
	sar	ebp,16
	shl	edx,16

	push	eax
	mov	eax,[M_Volume+ebx]
	imul	eax,[M_SamplePanR+ebx]
	shr	eax,4
	and	eax,not 511
	add	eax,[VolTablePtr]
	shr	eax,1
	mov	ecx,eax

	mov	eax,[M_Volume+ebx]
	imul	eax,[M_SamplePanL+ebx]
	shr	eax,4
	and	eax,not 511
	add	eax,[VolTablePtr]
	shr	eax,1
	mov	ebx,eax
	pop	eax
	retn

	Align 4
MixStereoSampleLoop:
	N=0
	REPT 16
	add	eax,edx
	mov	bl,[esi]
	adc	esi,ebp
	mov	ax,[ebx+ebx]
	add	[edi+4*N+0],ax
	mov	cl,bl
	mov	ax,[ecx+ecx]
	add	[edi+4*N+2],ax
	SetEntryOfs %N
	N=N+1
	ENDM
	add	edi,4*16
	dec	[MixSampleCount]
	jge	MixStereoSampleLoop

	pop	ebx
	xor	ax,ax
	mov	[M_SamplePtr+ebx],esi
	mov	[M_SampleFrac+ebx],eax
	ret

	Align 4
MixStereoJumpTable label dword
	N=16
	REPT 16
	N=N-1
	GetEntryOfs %N
	ENDM


;----------------------------------------------------------------------------
; 16-bit mono sample mixing routine
; In:
;  EBX - channel number (x4)
;  EDI - mixing buffer address
;  ECX - number of samples
; Out:
;  EDI - mixing buffer address
;----------------------------------------------------------------------------
; WARNING: The lower 16-bits of the decimal overflow are unused.
;	   The volume table must be 512-byte aligned.
;----------------------------------------------------------------------------
MixMono16Sample:
	push	ebx

	push	eax
	mov	eax,ecx
	and	eax,0fh
	shr	ecx,4
	lea	edi,[edi+eax*4-2*16]
	mov	eax,[MixMono16JumpTable+eax*4]
	mov	[esp],eax

	mov	esi,[M_SamplePtr+ebx]
	mov	eax,[M_SampleFrac+ebx]
	mov	ebp,[M_SampleSpeed+ebx]
	mov	edx,ebp
	sar	ebp,16
	shl	edx,16
	mov	ebx,[M_Volume+ebx]
	add	ebx,[VolTablePtr]
	shr	ebx,1
	retn

	Align 4
MixMono16SampleLoop:
	N=0
	REPT 16
	add	eax,edx
	mov	bl,[esi+esi+1]			; use MSB of 16-bit sample
	adc	esi,ebp
	mov	ax,[ebx+ebx]
	add	[edi+2*N],ax
	SetEntryOfs %N
	N=N+1
	ENDM
	add	edi,2*16
	dec	ecx
	jge	MixMono16SampleLoop

	pop	ebx
	xor	ax,ax
	mov	[M_SamplePtr+ebx],esi
	mov	[M_SampleFrac+ebx],eax
	ret

	Align 4
MixMono16JumpTable label dword
	N=16
	REPT 16
	N=N-1
	GetEntryOfs %N
	ENDM

;----------------------------------------------------------------------------
; 16-bit stereo sample mixing routine
; In:
;  EBX - channel number (x4)
;  EDI - mixing buffer address
;  ECX - number of samples
; Out:
;  EDI - mixing buffer address
;----------------------------------------------------------------------------
; WARNING: The lower 16-bits of the decimal overflow are unused.
;	   The volume table must be 512-byte aligned.
;----------------------------------------------------------------------------
MixStereo16Sample:
	push	ebx

	push	eax
	mov	eax,ecx
	and	eax,0fh
	shr	ecx,4
	mov	[MixSampleCount],ecx
	lea	edi,[edi+eax*4-4*16]
	mov	eax,[MixStereo16JumpTable+eax*4]
	mov	[esp],eax

	mov	esi,[M_SamplePtr+ebx]
	mov	eax,[M_SampleFrac+ebx]
	mov	ebp,[M_SampleSpeed+ebx]
	mov	edx,ebp
	sar	ebp,16
	shl	edx,16

	push	eax
	mov	eax,[M_Volume+ebx]
	imul	eax,[M_SamplePanR+ebx]
	shr	eax,4
	and	eax,not 511
	add	eax,[VolTablePtr]
	shr	eax,1
	mov	ecx,eax

	mov	eax,[M_Volume+ebx]
	imul	eax,[M_SamplePanL+ebx]
	shr	eax,4
	and	eax,not 511
	add	eax,[VolTablePtr]
	shr	eax,1
	mov	ebx,eax
	pop	eax
	retn

	Align 4
MixStereo16SampleLoop:
	N=0
	REPT 16
	add	eax,edx
	mov	bl,[esi+esi+1]			; use MSB of 16-bit sample
	adc	esi,ebp
	mov	ax,[ebx+ebx]
	add	[edi+4*N+0],ax
	mov	cl,bl
	mov	ax,[ecx+ecx]
	add	[edi+4*N+2],ax
	SetEntryOfs %N
	N=N+1
	ENDM
	add	edi,4*16
	dec	[MixSampleCount]
	jge	MixStereo16SampleLoop

	pop	ebx
	xor	ax,ax
	mov	[M_SamplePtr+ebx],esi
	mov	[M_SampleFrac+ebx],eax
	ret

	Align 4
MixStereo16JumpTable label dword
	N=16
	REPT 16
	N=N-1
	GetEntryOfs %N
	ENDM


;----------------------------------------------------------------------------
; Mixes all the channels into a 16-bit mixing buffer
; In:
;  EDI - mixing buffer address
;  ECX - number of samples
; Out:
;  EDI - mixing buffer address
;----------------------------------------------------------------------------
MixChannels:
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	ebp
	push	esi

	xor	ebx,ebx 			; starting channel number

MixNextChannel:
	push	ecx				; save mixing buffer
	push	edi				; address and length

MixChannelLoop:
	push	ebx				; save channel number
	push	ecx

	mov	al,[M_VoiceControl+ebx] 	; get sample control bits
	shl	ebx,2
	and	al,01011000b
	cmp	al,00000000b
	je	CheckForwardSample
	cmp	al,01000000b
	je	CheckBackwardSample
	cmp	al,00001000b
	je	CheckFwdLoopSample
	cmp	al,01001000b
	je	CheckBwdLoopSample
	jmp	CheckBidiLoopSample

CheckForwardSample:
	mov	esi,[M_SampleSpeed+ebx] 	; forward playing
	xor	eax,eax
	mov	edx,[M_SampleEnd+ebx]
	sub	eax,[M_SampleFrac+ebx]
	sbb	edx,[M_SamplePtr+ebx]
	ja	MixChannelSamples
	jmp	MixChannelDone

CheckBackwardSample:
	mov	esi,[M_SampleSpeed+ebx] 	; backward playing
	neg	esi
	mov	eax,[M_SampleFrac+ebx]
	mov	edx,[M_SamplePtr+ebx]
	sub	edx,[M_SampleEnd+ebx]
	ja	MixChannelSamples
	jmp	MixChannelDone

CheckFwdLoopSample:
	mov	esi,[M_SampleSpeed+ebx] 	; forward looped playing
CheckFwdLoopAgain:
	xor	eax,eax
	mov	edx,[M_LoopEnd+ebx]
	sub	eax,[M_SampleFrac+ebx]
	sbb	edx,[M_SamplePtr+ebx]
	ja	MixChannelSamples
	mov	eax,[M_LoopStart+ebx]
	sub	eax,[M_LoopEnd+ebx]
	jae	MixChannelDone			; (safety check)
	add	[M_SamplePtr+ebx],eax
	jmp	CheckFwdLoopAgain

CheckBwdLoopSample:
	mov	esi,[M_SampleSpeed+ebx] 	; backward looped playing
	neg	esi
CheckBwdLoopAgain:
	mov	eax,[M_SampleFrac+ebx]
	mov	edx,[M_SamplePtr+ebx]
	sub	edx,[M_LoopStart+ebx]
	ja	MixChannelSamples
	mov	eax,[M_LoopEnd+ebx]
	sub	eax,[M_LoopStart+ebx]
	jbe	MixChannelDone			; (safety check)
	add	[M_SamplePtr+ebx],eax
	jmp	CheckBwdLoopAgain

CheckBidiLoopSample:
	mov	esi,[M_SampleSpeed+ebx] 	; BIDI looped playing
	test	esi,esi
	jl	CheckBwdBidiLoopSample

CheckFwdBidiLoopSample:
	xor	eax,eax 			; BIDI loop forward
	mov	edx,[M_LoopEnd+ebx]
	sub	eax,[M_SampleFrac+ebx]
	sbb	edx,[M_SamplePtr+ebx]
	ja	MixChannelSamples
	xor	eax,eax
	mov	edx,[M_LoopEnd+ebx]
	cmp	edx,[M_LoopStart+ebx]		;(safety check)
	jbe	MixChannelDone
	sub	eax,[M_SampleFrac+ebx]
	sbb	edx,[M_SamplePtr+ebx]
	add	edx,[M_LoopEnd+ebx]
	mov	[M_SampleFrac+ebx],eax
	mov	[M_SamplePtr+ebx],edx
	neg	esi
	mov	[M_SampleSpeed+ebx],esi
	jmp	CheckBwdBidiLoopSample

CheckBwdBidiLoopSample:
	neg	esi
	mov	eax,[M_SampleFrac+ebx]		; BIDI loop backward
	mov	edx,[M_SamplePtr+ebx]
	sub	edx,[M_LoopStart+ebx]
	ja	MixChannelSamples
	xor	eax,eax
	mov	edx,[M_LoopStart+ebx]
	cmp	edx,[M_LoopEnd+ebx]		;(safety check)
	jae	MixChannelDone
	sub	eax,[M_SampleFrac+ebx]
	sbb	edx,[M_SamplePtr+ebx]
	add	edx,[M_LoopStart+ebx]
	mov	[M_SampleFrac+ebx],eax
	mov	[M_SamplePtr+ebx],edx
	mov	[M_SampleSpeed+ebx],esi
	jmp	CheckFwdBidiLoopSample

; ebx=channel edi=buffer ecx=count edx:eax=distance esi=speed
MixChannelSamples:
	test	ecx,ecx 			; no samples left?
	jle	MixChannelDone
	shrd	eax,edx,16
	shr	edx,16				; more than 64K samples?
	jne	MixChannelChunk
	mov	edx,ecx
	imul	edx,esi
	cmp	eax,edx 			; need to clip?
	jae	MixChannelChunk
	dec	eax				; clip sample counter
	xor	edx,edx
	add	eax,esi
	adc	edx,edx
	div	esi
	mov	ecx,eax

MixChannelChunk:
	push	ecx

	xor	eax,eax
	shr	ebx,2
	test	[M_VoiceControl+ebx],04h
	setne	al
	shl	ebx,2
	add	al,al
	or	al,[SB_Stereo]

	call	[MixSampleProc+eax*4]
	pop	ecx

MixChannelDone:
	mov	eax,ecx
	pop	ecx
	pop	ebx
	sub	ecx,eax
	test	eax,eax
	jg	MixChannelLoop

	pop	edi
	pop	ecx
	inc	ebx
	cmp	bl,[AllocChannels]
	jb	MixNextChannel

	mov	eax,ecx
	mov	cl,[SB_Stereo]
	shl	eax,cl
	add	edi,eax
	add	edi,eax

	pop	esi
	pop	ebp
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret


;----------------------------------------------------------------------------
; Main mixing routine used to update the output DMA buffer
;----------------------------------------------------------------------------
SBP_MixData Proc	Near
;	cmp	[SoundCard],2
;	jb	_ret
	pushad

	bts	[MixSpinLock],0 		; lock!
	jc	@@ExitMixBuffer

	mov	al,[SoundCard_DMA1]		; get DMA playing position
	mov	ah,[SoundCard_DMA2]
	cmp	[SB_16Bits],0
	sete	cl
	shl	cl,3
	shl	eax,cl
	call	DMA_GetCount
	neg	eax
	add	eax,[SB_DMABufferSize]

	sub	eax,[SB_DMABufferPtr]		; get number of DMA divisions
	jge	@@CheckBufSize			; that need to be filled.
	add	eax,[SB_DMABufferSize]
@@CheckBufSize:
	dec	eax
	and	eax,-DMABUFDIVSIZE
	jle	@@MixBufferDone
	mov	[MixBufSize],eax		; (multiple of DMABUFDIVSIZE)

@@MixBufferChunks:
	mov	eax,[DMABuffer] 		; get DMA buffer address
	add	eax,[SB_DMABufferPtr]		; and length in bytes
	mov	[MixBufPtr],eax

	lea	edi,[MixBuffer] 		; get aux buffer address
	mov	ecx,DMABUFDIVSIZE

	cmp	[SB_16Bits],0			; write directly on the DMA
	je	@@CleanMixBuffer		; buffer for 16-bit modes.
	mov	edi,[MixBufPtr]
	shr	ecx,1

@@CleanMixBuffer:
	push	ecx				; clean mixing buffer
	push	edi
	xor	eax,eax
	shr	ecx,1
	rep	stosd
	adc	ecx,ecx
	rep	stosw
	pop	edi
	pop	ecx

	mov	eax,ecx 			; start mixing process
	mov	cl,[SB_Stereo]
	shr	eax,cl
	mov	ecx,eax
	jecxz	@@MixBufferDone
@@MixBufferLoop:
	push	ecx
	movsx	eax,[PollRate]
	test	eax,eax 			; it's time to poll
	jg	@@DontUpdatePlayer		; the module player?
	pushad
	call	UpdatePlayer
	popad
	mov	ax,[PollRate_Init]
	add	[PollRate],ax
@@DontUpdatePlayer:
	movsx	eax,[PollRate]			; get number of samples to
	add	eax,15				; be mixed in this chunk
	and	eax,not 15			; (avoid very small chunks)
	cmp	eax,ecx
	jbe	@@MixChunkOfSamples
	mov	eax,ecx
@@MixChunkOfSamples:
	mov	ecx,eax
	call	MixChannels
	pop	ecx
	sub	[PollRate],ax
	sub	ecx,eax
	jg	@@MixBufferLoop

	cmp	[SB_16Bits],0			; skip post processing
	jne	@@MixBufferNext 		; for 16-bit output mode.

	lea	esi,[MixBuffer] 		; convert 16-bit to 8-bit
	mov	ecx,[MixBufSize]		; unsigned samples...
	mov	edi,[MixBufPtr]
	mov	ebx,PostTablePtr
	xor	eax,eax
	mov	dl,1024/256
@@PostProcessLoop:
	mov	ax,[esi]
	add	ah,dl
	mov	al,[ebx+eax]
	add	esi,2
	mov	[edi],al
	inc	edi
	dec	ecx
	jg	@@PostProcessLoop

@@MixBufferNext:
	mov	eax,[SB_DMABufferPtr]		; advance DMA buffer pointer
	add	eax,DMABUFDIVSIZE
	cmp	eax,[SB_DMABufferSize]
	jb	@@SetBufferPtr
	xor	eax,eax
@@SetBufferPtr:
	mov	[SB_DMABufferPtr],eax
	sub	[MixBufSize],DMABUFDIVSIZE	; more bytes?
	jg	@@MixBufferChunks

@@MixBufferDone:
	btr	[MixSpinLock],0 		; unlock!

@@ExitMixBuffer:
	popad
	ret
SBP_MixData EndP

ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

;in: esi=SoundCard
;    PlayFreq
;out: Sets Stereo/16bits/frequency variables
InitSCVariables:
	pushad
	cmp	esi,2			; *** MODIFIED:
	sete	al			; *** Enable stereo for SBPro/SB16
	cmp	esi,3			; *** and 16-bit for SB16 cards.
	sete	ah
	or	al,ah
	mov	SB_StereoHW,al
	cmp	SB_StereoAllowed,1
	sete	ah
	and	al,ah
	mov	SB_Stereo,al

	cmp	esi,3
	sete	al
	mov	SB_16BitsHW,al
	cmp	SB_16BitsAllowed,1
	sete	ah
	and	al,ah
	mov	SB_16Bits,al

	cmp	DSPVersion,400h
	jae	@@SB16
					;------------------------ SB PRO
	mov	ax,0			;Reset Mixer
	call	WriteMixer

	mov	al,0eh			;Set Stereo+No Filter
	mov	ah,SB_Stereo
	shl	ah,1			; bit 1: mono/stereo
	or	ah,00100000b		; bit 5: filter on/off
	call	WriteMixer

	mov	ax,0ff03h		 ;Set various Volumes
	call	SBP_Mixer
	mov	ax,0ff04h
	call	SBP_Mixer
	mov	ax,00005h
	call	SBP_Mixer
	mov	ax,00006h
	call	SBP_Mixer
	mov	ax,00007h
	call	SBP_Mixer
	mov	ax,00008h
	call	SBP_Mixer

	mov	eax,1000000		;(256 - 1000000 DIV (Channels*Freq));
	mov	ebx,PlayFreq
	mov	cl,SB_Stereo
	shl	ebx,cl			;Stereo = Double speed.
	xor	edx,edx
	div	ebx
	mov	ebx,256
	sub	ebx,eax
	mov	SB_Freq,bx

	mov	eax,1000000		;Get true replay speed
	mov	ebx,PlayFreq
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	mov	eax,1000000
	xor	edx,edx
	div	ebx
	mov	RealPlayFreq,eax
	jmp	ContInitSC


@@SB16: 				;------------------------ SB 16
	mov	eax,PlayFreq
	mov	RealPlayFreq,eax	; *** MODIFIED:
	mov	SB_Freq,ax		; *** Don't double speed for SB16.

	mov	ax,0			;Reset Mixer
	call	WriteMixer
	mov	ax,0ff03h		;Set various Volumes
	call	SBP_Mixer
	mov	ax,0ff04h
	call	SBP_Mixer

ContInitSC:

	mov	eax,RealPlayFreq
	mov	ebx,102
	xor	edx,edx
	div	ebx
	mov	PollRate,ax
	mov	PollRate_Init,ax

	call	CreateVolTable
	call	CreatePostProcess
	popad
	ret

;in esi=SoundCard
SC_ChangeReplay:
	cmp	esi,SoundCard
	jnz	_ret
	call	SB_ResetDSP
	call	SBP_SpeakerOff
	mov	ah,[SoundCard_DMA1]	;Shut Down Play DMA
	cmp	[SB_16Bits],0
	je	@@Use8BitDMA
	mov	ah,[SoundCard_DMA2]
@@Use8BitDMA:
	call	DMA_Shutdown
	call	StopTimer
	call	InitSCVariables
	call	CalcTimerRate
	mov	TimerRate,ax

	mov	eax,RealPlayFreq	;Set DMA buffer size in bytes
	mov	cl,SB_Stereo		;using proper block alignment
	add	cl,SB_16Bits
	shl	eax,cl
	xor	edx,edx
	mov	ebx,DMALATENCYRATE
	div	ebx
	add	eax,DMABUFDIVSIZE
	and	eax,-DMABUFDIVSIZE
	add	eax,eax
	cmp	eax,DMABUFFERSIZE
	jbe	@@SetBufferSize
	mov	eax,DMABUFFERSIZE
@@SetBufferSize:
	shr	eax,cl
	shl	eax,cl
	mov	SB_DMABufferSize,eax

	mov	edi,DMABuffer		;Clear DMA buffer
	mov	ecx,SB_DMABufferSize

	cmp	SB_16Bits,0
	sete	al
	shl	al,7
	rep	stosb

	xor	eax,eax
	mov	SB_DMABufferPtr,eax

	call	SBP_SpeakerOn
	call	StartTimer
	call	SB_StartDMA		;Start the DMA Transfer
	ret

SBMixFreq	dd	0
;out: eax=TimerRate
CalcTimerRate	Proc	Near
	push	ebx ecx edx
	mov	eax,RealPlayFreq
	mov	cl,SB_Stereo
	add	cl,SB_16Bits
	shl	eax,cl
	mov	ebx,(3*DMABUFDIVSIZE)/4
	xor	edx,edx
	div	ebx
	add	eax,10			;For safety
	mov	SBMixFreq,eax		;23-483 Hz
	cmp	eax,102
	jae	@@Skutt
	mov	eax,102 		;Minimize call rate to 102 Hz
@@Skutt:
	mov	ebx,eax

	xor	eax,eax 		;102*2^32
	mov	edx,102
	cmp	edx,ebx
	jnz	@@DivOk
	mov	MF_Add,-1
	jmp	@@Next
@@DivOk:
	div	ebx			;/Timer Freq
	mov	MF_Add,eax

@@Next:
	xor	eax,eax 		;SBMixFreq*2^32
	mov	edx,SBMixFreq
	cmp	edx,ebx
	jb	@@DivOk2
	mov	MX_Add,-1
	jmp	@@Next2
@@DivOk2:
	div	ebx			;/Timer Freq
	mov	MX_Add,eax

@@Next2:
	mov	eax,1234dch
	xor	edx,edx
	div	ebx
	pop	edx ecx ebx
	ret
CalcTimerRate	EndP


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls:
;
;eax=RollBits
;bl =RollNote
;ecx=RollSize
;edx=C4 Rate
;esi=RollPtr
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
RollOverPtr	dd	0
RollOverSize	dd	0
RollOverBits	dd	0
RollOverNote	db	0
SBP_SpeechEngine	Proc	Near
IF	PLAYER
	cmp	LoadFXEngine,0		;If not installed
	jz	_ret
ENDIF
	pushad
	mov	RollOverBits,eax
	mov	RollOverNote,bl
	mov	RollOverSize,ecx
	mov	Speech_C4Rate,dx
	mov	RollOverPtr,esi
	mov	ecx,RollOverBits
	shr	RollOverPtr,cl
	shr	RollOverSize,cl

	mov	ebx,1			;Use Sample 1
	mov	eax,RollOverBits
	shl	al,2
	mov	[VoiceControl+ebx],al	;0=8 bits,4=16 bits

	mov	esi,RollOverPtr
	mov	eax,esi
	add	eax,RollOverSize

	mov	[SampleOffsetStart+ebx*4],esi
	mov	[SampleOffsetEnd+ebx*4],eax
	mov	ax,Speech_C4Rate
	mov	[SampleRates+ebx*2],ax
	mov	[Volumes+ebx],127

	mov	edi,3
	mov	ah,RollOverNote
	mov	al,70h
	mov	cl,127
	call	FXEngine

	popad
	ret
SBP_SpeechEngine	EndP

SBP_StopSpeech	Proc	Near
IF	PLAYER
	cmp	LoadFXEngine,0		;If not installed
	jz	_ret
ENDIF
	push	ecx
	movzx	ecx,AllocChannels
	call	StopOneVoice
	pop	ecx
	ret
SBP_StopSpeech	EndP

;Checks if speech is stopped
;Out: CF=1 : YES, Stopped!
;     CF=0 : NO, not stopped!
SBP_CheckSpeech	Proc	Near
IF	PLAYER
	cmp	LoadFXEngine,0		;If not installed
	jz	_ret
ENDIF

	pushad
	movzx	ecx,AllocChannels
	dec	ecx
	mov	ebx,[M_SamplePtr+ecx*4]
	cmp	ebx,[M_SampleEnd+ecx*4]
	jnz	_Retp_clc
	jmp     _Retp_stc
SBP_CheckSpeech	EndP

