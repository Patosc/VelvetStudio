;/ABS\00001000010000100001000010000100001000010000100216
EnableInternal	=	0	;If to enable internal speaker support

NOS_SetVolume:
NOS_CMD10:
NOS_CMDE8:
NOS_StartTheChannels:
NOS_SetPanPot:
NOS_SetZeroVol:
NOS_SetOrigVol:
NOS_ChangeActiveVoices:
NOS_Mixer:
NOS_TurnOnSoundCard:
NOS_DeInitSoundCard:
NOS_FixStartSample:
NOS_StartADC:
NOS_StopADC:
NOS_ChangeSamplingFreq:
NOS_GetCurrAdd:
NOS_SetCurrAdd:
NOS_SetSampleLoop:
NOS_MoveTuneForkSample:
NOS_MainMixer:
NOS_SpeechEngine:
NOS_StopSpeech:
NOS_CheckSpeech:
	ret

NOS_StopOneVoice:
IF	ENABLEINTERNAL
	pusha
	in	al,61h		;Read PortB
	and	al,not 3	;Disable Speaker
	out	61h,al		;Write PortB
	popa
ENDIF
	ret


;-------------------------------
;Sets the freq for specified voice
;calls: edi=chan
;-------------------------------
Notetable	dw	33488,35480,37589,39824,42192,44701,47360,50176,53158,56320,59669,63218
NOS_SetTheFreq:
IF	ENABLEINTERNAL
	pushad
	movzx	eax,[CurrNoteTable+edi]
	sub	eax,2
	mov	ebx,12
	xor	edx,edx
	div	ebx
	cmp	ax,2
	ja	@@Oky
	mov	ax,2
@@Oky:
	cmp	ax,8
	jb	@@Oky2
	mov	ax,8
@@Oky2:
	mov	bx,[NoteTable+edx*2]
	sub	ax,8
	neg	ax
	mov	cx,ax
	shr	bx,cl
	shr	bx,4		;/16

	mov	al,10110110b	;Timer control
	out	43h,al
	mov	dx,012h
	mov	ax,34dch	;1234dch/Freq=Rate
	div	bx
	out	42h,al		;Program Timer
	shr	ax,8
	out	42h,al

	popad
ENDIF
	ret

;-------------------------------
;Sets up needed info before playing a sample
;Calls: EBX = Sample #
;	EDI = Channel
;-------------------------------
NOS_PlayVoice:
	and	ebx,0fffh		;Check for sample 0
	jz	_ret			;if not, fall through to next proc.

NOS_KeyBoardPlayVoice:
IF	ENABLEINTERNAL
	pusha
	in	al,61h		;Read PortB
	or	al,3		;Enable Speaker
	out	61h,al		;Write PortB
	popa
ENDIF
	ret


NOS_InitSoundCard:
	mov	TimerRate,11652 		;102.4 Hz
	ret

NOS_ClearTheSamples:
	pushad
	push	CurrentSample
	;xor	ebx,ebx
	mov	ebx,16
	;xor	edi,edi
	mov	edi,1
	mov	ecx,MaxSamples-16
DisallocTheSamples:
	mov	CurrentSample,bx
	mov	eax,[SampleOffsetEnd+ebx*4]
	cmp	eax,0
	jz	DisAllocNextSample
	mov	esi,[SampleOffsetStart+ebx*4]
	sub	eax,esi
	jle	DisAllocNextSample
	GetOffset edi,ebp,ENV_Shadow	;ENABLE
	cmp	byte ptr [ebp],0
	jnz	DisAllocNextSample
	call	NOS_DisAlloc
DisAllocNextSample:
	inc	ebx
	mov	edi,ebx
	;and	edi,0fffffff0h
	shr	edi,4
	loop	DisallocTheSamples

	mov	ebp,1028
	call	MemDisalloc
	mov	ebp,1029
	call	MemDisalloc
	mov	ebp,1034
	call	MemDisalloc
        mov     ebp,1043
        call    MemDisalloc

	xor	eax,eax
	lea	edi,SampleOffsetStart
	mov	ecx,22*MaxSamples/4
	rep	stosd
	mov	samples,1
	pop	CurrentSample
	popad
	ret

NOS_StartTimer:
	cmp	IntsON,1
	jz	_ret
	mov	IntsON,1
	jmp	StartInts
NOS_StopTimer:
	cmp	IntsON,0
	jz	_ret
	mov	IntsON,0
	jmp	StopInts

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Get sample memory
; calls:  EAX	- Source Offset (in samples)
;	  EBX	- Dest Offset (in bytes)
;	  ECX	- Samples to get
;	   DL	- 128 if convert, 0 if not
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NOS_GetSampleFromDRAM:
	pushad
	and	dl,128
	mov	ebp,ecx
;--..--
	movzx	ecx,CurrentSample
	mov	cl,[VoiceControl+ecx]
	bt	cx,2
	setc	cl
;--..--
	mov	esi,eax
	shl	esi,cl
	mov	edi,ebx
	jmp	CopySample
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls:
;EBX=SampleNr
;[AllocTable+1024*8]=Source
;SampleOffsetMem=Destination buffer (in samples)
;EDX=128 - conv
;EDX=0	 - no conv
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NOS_MoveSample:
	pushad
	and	dl,128
	mov	cl,[VoiceControl+ebx]
	bt	cx,2
	setc	cl

	mov	ebp,[SampleOffsetEnd+ebx*4]

	mov	esi,[AllocTable+1024*8]
	mov	edi,SampleOffsetMem
	mov	[SampleOffsetStart+ebx*4],edi
	add	[SampleOffsetEnd+ebx*4],edi
	add	[LoopStart+ebx*4],edi
	add	[LoopEnd+ebx*4],edi
	shl	edi,cl

CopySample:
	cmp	cl,1
	jz	MoveTheSampleLoop16

MoveTheSampleLoop8:
	lodsb
	xor	al,dl
	stosb
	dec	ebp
	jnz	MoveTheSampleLoop8
	 mov	 al,0		       ;!
	 mov	 ecx,SBExtraBuffer
	 rep	 stosb
	popad
	ret
MoveTheSampleLoop16:
	lodsw
	xor	ah,dl
	stosw
	dec	ebp
	jnz	MoveTheSampleLoop16
	popad
	ret


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls: EAX = Size Wanted (in samples)
;Ret:	CY=1 if error
;	EAX = Offset to dump sample
;	CurrentSample
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SampleOffsetMem dd	0
Safety		db	0
NOS_Alloc:
	pushad
	mov	Safety,0
	mov	SizeAllocated,eax	;Assume allocation went ok.
	add	eax,SBExtraBuffer
;--..--
	movzx	ecx,CurrentSample
	movzx	ecx,[VoiceControl+ecx]
	bt	cx,2
	setc	cl
	shl	eax,cl
;--..--
TryAgain:
	mov	ebp,1042
	xor	ebx,ebx
	call	MemAlloc
	jc	AllErr
	shr	eax,cl
	mov	SampleOffsetMem,eax
	mov	[AllocTable+1042*8],0	;reset allocation
	mov	[AllocTable+1042*8+4],0

	mov	[esp+28],eax
	Popad
	clc
	ret
AllErr:
	cmp	Safety,1
	jz	NoMemLeft
	mov	Safety,1
	mov	eax,MemoryFree
	push	eax
	shr	eax,cl
	mov	SizeAllocated,eax	;In samples
	pop	eax
	jmp	TryAgain

	popad
	stc
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls: EAX = Size to Disalloc (in samples)
;	ESI = Offset to Disalloc (in samples)
;	CurrentSample
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NOS_DisAlloc:
	push	esi eax ebp ecx
	add	eax,SBExtraBuffer
;--..--
	movzx	ecx,CurrentSample
	mov	cl,[VoiceControl+ecx]
	bt	cx,2
	setc	cl
	shl	eax,cl
	shl	esi,cl
;--..--
	mov	[AllocTable+1042*8],esi 	;set allocation
	mov	[AllocTable+1042*8+4],eax
	mov	ebp,1042
	call	MemDisalloc
	pop	ecx ebp eax esi
	ret

