DISABLESAVE	=	0		;Set to 1 if the save function should
					;be disabled.

Global Dnumber:Byte,MIDIBuffLen:Byte,MIDIBuffPtrR:Byte,MIDIBuffPtrW:Byte,MIDIState:Byte,IntsOn:Byte
Global Sampling:Byte,Pt_Counter:Byte,PatternPlay:Byte,TuneStoppedSave:Byte,IntsOn:Byte,CurrentInstName:Byte
Global ProTrackerEditing:Byte,PanMax:Byte,MIDIChanTable:Byte:32,CursorRow:Byte,Midi_Status:Byte,StartSample:Byte,StopSample:Byte
Global CurrentInstrument:Byte,ErrorLoadSample:Byte,LoadFTLoop:Byte,LoadSampleConvert:Byte,CursorChannel:Byte
Global PlaySample0:Byte,ChanPos:Byte,PackingByte:Byte,DestroySample:Byte,ResampleMode:Byte
Global EnvSine:Byte,amshdr:Byte,aishdr:Byte,AllocChannels:Byte,DefaultChannels:Byte,DefaultCommands:Byte,LinFreq:Byte
Global SaveMODOctaves:Byte,O_InProgress:Byte,SkipClickRemoval:Byte,acshdr:byte,apshdr:byte,asehdr:byte
Global DMA_CLRFF:Byte,DMA_CNT:Byte,DMAPlay_TC:Byte,Stereo:Byte,SampleRate:Byte,Allow_LineInSamp:Byte
Global SampleConvert:Byte,SampleBits:Byte,Allow_Sample:Byte,Allow_StereoSamp:Byte,Allow_16Samp:Byte
Global Sample0:Byte

Global Modname:Byte:13
Global MIDIBuffer:Byte:32,Volumes:Byte:4096,ChannelMaster:Byte:32,DetectBuffer:Byte:144
Global CurrInst:Byte:32,Volumes:Byte:4096,Relativenote:Byte:4096
Global FineTunes:Byte:4096,Header:Byte:7,RampDownTable:Byte:32,R_CurrNoteTable:Byte:32
Global EnvVolume:byte:32,EnvPanPot:Byte:32,KeyOffTable:byte:32

Global DefaultRows:Word,GUS_Command:Word,GUS_Data_High:Word,GUSSampleFreq:Word
Global HertzAdder:Word,SampleFreq:Word,DSPVersion:Word
Global CurrSample:Word:32,SampleRates:Word:4096

Global PatternSize2:Dword,PatternOffset:Dword,pt_PeriodTable:DWord,Max_SampleNote:Dword
Global RowSize:Dword,ChRowSize:Dword,SaveName:Dword,Nisse:Dword,CurrentWildCard:Dword
Global CurrAdd:Dword,SampLength:Dword,leftequalizer:dword,rightequalizer:dword
Global CurrPattLength:Dword,DescTable:Dword,Dbyte:Dword,Max_SampleRate:Dword
Global UndoSampLength:Dword,SampleSize:Dword,SampPtr:Dword,SamplingBuffOff:Dword

Global GUS_FreeTable:Dword:160


Global PlaySample:Near,DisallocSample:Near,MoveSample:Near,MoveTuneForkSample:Near
Global GetSampleFromDRAM:Near,ClearTheSamples:Near,SetTheFreq:Near,SetFineTune:Near,GetPatternSize:Near
Global GetRowSize:Near,CheckFileFormat:Near,viewall2:Near,Opel:Near,insertscopes:Near,getsplitcurrsample:near
Global posinit:Near,pattinit:Near,setinitialenvelopes:Near,GetSampOffset:Near,SetSampOffset:Near
Global Dbug:Near,SaveMod:Near,ADCSample:Near,StartADC:Near,StopADC:Near,FixStartSample:Near
Global Mixer:Near,GUS_Search:Near,SetSampleLoop:Near,GetNoteFromSampleFreq:Near
Global AskContLoad:Near,ChangeSamplingFreq:Near,KillInst2:Near,SaveACS:Near,SaveAPS:Near
Global DelSampleRate:Near,InsSampleRate:near,PutSampleRate:Near,GetSampleRate:near
Global Writefile:Near,KillSample2:Near,SampleToRAM:Near,Justconvert:Near,MainMixer:Near
Global InfoBlockBuffer1:byte:700,InfoBlockBuffer2:byte:1232


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls: EAX = Note (unsplitted)
;	EBX = Sample
;	EDX = Note (splitted)
;	EDI = Channel
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PlaySample	Proc	Near
	Pushad
	pushf

	mov	[Note+edi],dl
	mov	[R_CurrNoteTable+edi],al
	mov	[CurrNoteTable+edi],dl
	mov	[VibratoTable+edi*2],0

	mov	[ENV_PSpdCounter+edi],-1
	mov	[ENV_PInterPol+edi*2],-1
	mov	[ENV_CurrPPoint+edi],0
	mov	[ENV_PanInfo+edi*4],0
	mov	[EnvPanPot+edi],128

	mov	[ENV_BSpdCounter+edi],-1
	mov	[ENV_BInterPol+edi*2],-1
	mov	[ENV_CurrBPoint+edi],0
	mov	[ENV_VibInfo+edi*4],0
	mov	[VibPeriod+edi*2],0
	mov	[SlideTable+edi*4],0

	mov	[ENV_SpdCounter+edi],-1
	mov	[ENV_VInterPol+edi*2],-1
	mov	[ENV_CurrVPoint+edi],0
	mov	[ENV_VolInfo+edi*4],0
	mov	[ENV_FadeCounter+edi*4],0ffffh

	mov	[CurrSample+edi*2],bx
	mov	ax,bx
	shr	ax,4
	mov	[CurrInst+edi],al

	call	SetFineTune

	mov	al,[Volumes+ebx]
	mov	[CurrVolume+edi],al
	mov	[Volume+edi],al
	mov	[Vol+edi],al

	bts	EnvVolCheck,edi
	bts	KBDPlayFlag,edi
	bts	EnvVibCheck,edi

	cmp	PlaySample0,0
	jz	NoZeroDusan
	mov	ebx,0
NoZeroDusan:
	call	KeyBoardPlayVoice

	popf
	clc
	popad
	Ret
PlaySample	EndP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;				    Save AMS
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

LastWasEmpty	db	0
UsedCommands	db	0
;Calls: Asciiz name in SaveName
SaveMod Proc	Near
IFE	DISABLESAVE

	cmp	CurrentWildCard,12
	jz	SaveProTracker
	cmp	CurrentWildCard,18
	jz	SaveSMP
	cmp	CurrentWildCard,30
	jz	SaveS3M
	cmp	CurrentWildCard,60
	jz	SaveXM
        cmp	CurrentWildCard,66
	jz	SaveWAV
	cmp	CurrentWildCard,54
	jz	SaveAIS
	cmp	CurrentWildCard,102
	jz	SaveACS
	cmp	CurrentWildCard,108
	jz	SaveAPS
	cmp	CurrentWildCard,120
	jz	SaveASE

	stc
	cmp	word ptr [opel],0850fh
	jnz	_ret

	Pushad
	Pushf
	mov	StackSave,esp
	mov	edx,SaveName		;Create File
	call	_CreateFile
	mov	ax,CreateErr
	jc	ErrorHandler
	mov	edi,GUS_TempBuffPtr

	lea	esi,AMShdr		;Move AMShdr
	mov	ecx,7
	rep	movsb


	lea	esi,SongName
	mov	ecx,30
	call	ScanNameBackWrds
	mov	al,cl
	stosb				;Save ModName Length
	rep	movsb			;Save ModName
	mov	ax,AMSVersion
	stosw				;Store version
	mov	al,Samples
	stosb				;Store # of Instruments

	call	GetUsedPatterns
	stosw				;Store # of patterns
	mov	Patterns,ax
	mov	ax,Positions

	stosw				;Store Positions
	mov	ax,InitBPM
	stosw				;Store Initial BPM
	mov	al,InitSpeed
	stosb				;Store Initial Speed
	mov	al,0
	stosb				;Store Def Channels
	stosb                           ;Store Def Commands
	stosb                           ;Store Def Rows
	mov	ax,TuneFlags
	and	ax,10111111b
	mov	dl,LinFreq
	shl	dl,6
	or	al,dl
	stosw				;Store Some flags

	mov	edx,GUS_TempBuffPtr	;Save Header
	mov	ecx,edi
	sub	ecx,edx
	call	writefile
	mov	ebp,1
	movzx	ecx,Samples
	jecxz	NoFuckingInstruments
SaveInstrumentLoopen:
	push	ecx
	mov	edi,GUS_TempBuffPtr
	call	SaveInst		;Save the Instrumentinfo
	pop	ecx
	inc	ebp
	loop	SaveInstrumentLoopen

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Save Text

	mov	edi,GUS_TempBuffPtr

	lea	esi,Composer
	mov	ecx,30
	call	ScanNameBackWrds
	mov	al,cl
	stosb				;Store Composer Length
	rep	movsb			;Store Composer

	mov	ecx,32			;Save Channel Names
	mov	esi,ChannelNamesPtr
ChannelFlaskor:
	push	ecx esi
	mov	ecx,11
	call	ScanNameBackWrds
	mov	al,cl
	stosb				;Store Channel name length
	rep	movsb			;Store Channel name
	pop	esi ecx
	add	esi,11
	loop	ChannelFlaskor

	mov	edx,GUS_TempBuffptr
	mov	ecx,edi
	sub	ecx,edx
	call	writefile

	mov	esi,[AllocTable+1027*8]
	mov	ecx,[AllocTable+1027*8+4]
	mov	eax,ecx
	mov	ebp,1037
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	edi,eax
	mov	edx,eax
	mov	ax,0100h
	call	ExtremePacker
;	rep	movsb
	call	WriteFile

	mov	ebp,1037
	call	MemDisAlloc

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Positions

	mov	edx,PatternOrderPtr
	movzx	ecx,Positions

	shl	ecx,1
	call	writefile


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Patterns

	movzx	ecx,Patterns
	xor	ebp,ebp
ConvertPatternLoopen2:
	push	ecx
	push	esi
	push	ebp
	mov	esi,[AllocTable+ebp*8]
	cmp	esi,0
	jnz	NoEmptyPattern
	mov	esi,EmptyPattern
NoEmptyPattern:
	mov	edi,GUS_TempBuffPtr
	add	edi,4			;Skip PatternSize for now

	movzx	ecx,byte ptr [esi+10]
	mov	al,cl
	stosb				;Store Pattern Length

	mov	al,[esi+11]
	stosb				;Store Channels + Commands
	mov	ah,al
	and	al,31
	inc	al
	mov	Channels,al
	shr	ah,5
	mov	Commands,ah
	call	GetRowSize

	push	ecx esi
	mov	ecx,10
	call	ScanNameBackWrds
	mov	al,cl
	stosb				;Save Pattern name length
	rep	movsb			;Save Pattern name
	pop	esi ecx

	add	esi,12
	inc	ecx
PackRowLoop:
	push	ecx
	push	esi
	movzx	ecx,Channels
	xor	bx,bx
	mov	InfoByte12,0
PackChannel:
	push	ecx
	push	esi
PackOneChunk:
	mov	ecx,RowSize
CheckEmptyChunk:
	cmp	byte ptr [esi+ecx-1],0
	loopz	CheckEmptyChunk
	jz	ChunkIsEmpty
	mov	InfoByte12,1
	mov	al,bl
	mov	ebp,edi 	;Store InfoByte Location
	stosb			;InfoByte
	cmp	word ptr [esi],0
	jnz	StoreIt
	or	byte ptr [ebp],01000000b
	add	esi,2
	jmp	Construct3
StoreIt:
	movsb			;Note
	movsb			;InstNr
Construct3:
	cmp	cl,2
	jb	ChunkIsEmpty
	shr	cl,1
	mov	edx,ebp
	inc	edx
	test	byte ptr [ebp],01000000b
	jnz	Flambering
PackCommand:
	or	byte ptr [edx],80h
Flambering:
	lodsw
	cmp	al,0ch
	jnz	NoPackVolume
	cmp	ah,7fh
	jbe	NoCrashTest
	mov	ah,7fh
NoCrashTest:
	test	ah,1
	jnz	NoPackVolume
	shr	ax,9
	or	al,40h
	mov	edx,edi
	stosb
	loop	PackCommand
	jmp	ChunkIsEmpty
NoPackVolume:
	mov	edx,edi
	stosw
	loop	PackCommand

ChunkIsEmpty:
	pop	esi
	pop	ecx
	add	esi,RowSize
	inc	bx
	loop	PackChannel
	cmp	InfoByte12,1
	jz	NoEmptyPackRow
	mov	al,-1
	mov	ebp,edi
	stosb
NoEmptyPackRow:
	or	byte ptr [ebp],80h

	pop	esi
	pop	ecx
	add	esi,ChRowSize
	loop	PackRowLoop

	mov	edx,Gus_TempBuffPtr
	sub	edi,edx 		;write converted pattern
	mov	ecx,edi 		;total nr of bytes to write
	sub	edi,4			;PatternLength (1:st 4 bytes, remember?)
	mov	[edx],edi
	call	WriteFile

	pop	ebp
	pop	esi
	pop	ecx
	inc	ebp
	add	esi,PatternSize2
	loop	ConvertPatternLoopen2

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Samples
	movzx	ecx,Samples
	shl	ecx,4
	jecxz	NoFuckingSaveSamples
	mov	ebp,16

SaveAISinInst:
	push	ebp
	mov	ebp,1037
	call	MemDisalloc
	mov	ebp,1025
	call	MemDisalloc
	pop	ebp
	mov	AShadow,0

SaveSampleLoopen:
	mov	CurrentSample,bp
	push	ecx

	test	bp,0fh			;Inst?
	jnz	@@SaveAIS
	cmp	CurrentWildCard,54	;Save Shadow Sample data if an AIS.
	jz	@@SaveAIS
	mov	eax,ebp
	shr	eax,4
	GetOffset eax,eax,ENV_Shadow	;A Shadow
	cmp	byte ptr [eax],0
	setnz	AShadow
@@SaveAIS:
	cmp	AShadow,1
	jz	AnotherLabel

	mov	eax,[SampleOffsetEnd+ebp*4]
	sub	eax,[SampleOffsetStart+ebp*4]
	mov	edx,eax
	jle	AnotherLabel
	mov	cl,[VoiceControl+ebp]
	bt	cx,2
	setc	cl
	shl	eax,cl
	mov	ecx,eax 	;ecx=bytes, eax=samples
	mov	eax,edx

	pushad
	mov	eax,ecx
	mov	ebp,1025
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	UndoBaff,eax

	mov	eax,ecx
	mov	ebp,1037
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	TempBufferPtr,eax
	popad

	push	ecx
	mov	ecx,eax
	mov	eax,[SampleOffsetStart+ebp*4]
	xor	edx,edx
	mov	ebx,TempBufferPtr
	mov	esi,ebx 		;packing
	call	GetSampleFromDRAM
	pop	ecx
	mov	edx,TempBufferPtr
	test	[VoiceControl+ebp],3
	jz	NoFuckinPack
	mov	edx,UndoBaff
	mov	edi,edx
	call	packmethod1
NoFuckinPack:
	call	WriteFile

	push	ebp
	mov	ebp,1037
	call	MemDisalloc
	mov	ebp,1025
	call	MemDisalloc
	mov	UndoSampLength,0
	pop	ebp

AnotherLabel:
	pop	ecx
	inc	ebp
	loop	SaveSampleLoopen


NoFuckingSaveSamples:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ End Convert

	call	_CloseFile
	mov	ax,CloseErr
	jc	ErrorHandler

	call	WaitDiskReady

	Popf
	clc
	Popad
ENDIF
	Ret
SaveMod EndP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;				    Load IFF
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

MoveDosSampleName	db	0	;1 if to use DOS name
LoadIFFSample:
	cmp	Sample0,1
	jz	_ret2
	call	_FileSize
	mov	edx,eax
	mov	ax,SizeErr
	jc	ErrorHandler
	lea	edi,DetectBuffer+12
ScanIFFSample:
	mov	eax,[edi+4]
	rol	ax,8
	rol	eax,16
	rol	ax,8
	cmp	[edi],'YDOB'
	jz	LoadIFF
	cmp	[edi],'EMAN'
	jz	GotIFFName
	cmp	[edi],'RDHV'
	jz	GotIFFSample
Griupme:
	add	edi,eax
	add	edi,8
	jmp	ScanIFFSample
GotIFFName:
	push	edi
	push	eax
	mov	esi,edi
	add	esi,8
	mov	edi,SampleNamesPtr
	movzx	eax,CurrentSample
	sub	eax,16
	mov	ebx,22
	mul	ebx
	add	edi,eax
	xor	al,al
	push	edi
	mov	ecx,22
	rep	stosb
	pop	edi
	pop	eax
	mov	ecx,eax
	rep	movsb
	pop	edi
	mov	MoveDosSampleName,0
	jmp	Griupme
GotIFFSample:
	mov	Loop_Start,0
	mov	Loop_End,0
	cmp	dword ptr [edi+12],0
	jz	Griupme
	push	eax
	mov	eax,[edi+8]
	rol	ax,8
	rol	eax,16
	rol	ax,8
	mov	Loop_Start,eax
	mov	ebx,[edi+12]
	rol	bx,8
	rol	ebx,16
	rol	bx,8
	add	eax,ebx
	mov	Loop_End,eax
	pop	eax
	jmp	Griupme
LoadIFF:
	mov	edx,eax
	mov	Samp_End,eax
	mov	eax,8
	add	eax,edi
	sub	eax,offset DetectBuffer
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler
	jmp	SkipGetSize

LoadSample:
	cmp	Sample0,1
	jz	_ret2
	mov	eax,0
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler
	call	_FileSize
	mov	edx,eax
	mov	ax,SizeErr
	jc	ErrorHandler
	mov	Loop_Start,0
	mov	Loop_End,0
	mov	Samp_End,edx

	push	edx
	cmp	LoadFTLoop,1
	jz	NoRepeatHere

	mov	ax,5700h
	int	21h
	movzx	ecx,CX	;Start
	movzx	edx,DX	;Length
	add	edx,ecx
	cmp	edx,Samp_End
	ja	NoRepeatHere
	cmp	ecx,Samp_End
	ja	NoRepeatHere
	mov	Loop_Start,ecx
	cmp	edx,2
	ja	BiggerAndBetterAndRougherAndTougher
	mov	edx,0
BiggerAndBetterAndRougherAndTougher:
	mov	Loop_End,edx
NoRepeatHere:
	mov	MoveDosSampleName,1
	pop	edx

SkipGetSize:
	push	edx
	movzx	eax,CurrentSample
	mov	esi,[SampleOffsetStart+eax*4]
	mov	eax,[SampleOffsetEnd+eax*4]
	sub	eax,esi
	jbe	NoSampleHere
	call	DisallocSample
NoSampleHere:
	movzx	ebx,CurrentSample
	mov	[SampleOffsetStart+ebx*4],0
	mov	eax,Loop_Start
	mov	[LoopStart+ebx*4],eax
	mov	eax,Loop_End
	mov	[LoopEnd+ebx*4],eax
	mov	eax,Samp_End
	mov	[SampleOffsetEnd+ebx*4],eax
	mov	[FineTunes+ebx],0
	mov	[SampleRates+ebx*2],8363
	mov	[Volumes+ebx],127
	mov	al,0
	cmp	Loop_End,0
	jz	NoIFFLoop
	mov	al,8
NoIFFLoop:
	mov	[VoiceControl+ebx],al
	pop	edx
	mov	eax,edx
	call	AllocSample
	jnc	NoSMPErr
	call	FixAllocSampleError
NoSMPErr:
	pushad
	mov	eax,edx
	mov	ebp,1024
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampMainOffset,eax
	popad

	mov	ecx,edx
	push	edx
	mov	edx,SampMainOffset
	call	ReadFile
	pop	edx
	mov	ax,ReadErr
	jc	ErrorHandler
	movzx	ebx,CurrentSample

	push	edx
	mov	edx,0
	cmp	LoadSampleConvert,1
	jz	GurkOst
	cmp	TypeFile,0
	jnz	GurkOst
	mov	edx,128
GurkOst:
	call	MoveSample
	pop	edx

	call	_CloseFile
	mov	ax,CloseErr
	jc	ErrorHandler

	cmp	MoveDosSampleName,0
	jz	DontPrintDosSampleName
	mov	edi,SampleNamesPtr
	movzx	eax,CurrentSample
	sub	eax,16
	mov	ebx,22
	mul	ebx
	add	edi,eax
	xor	al,al
	push	edi
	mov	ecx,22
	rep	stosb
	pop	edi
	lea	esi,ModName
	mov	ecx,8
MoveSampleNameLoopen:
	lodsb
	cmp	al,0
	jz	NoMoreName1
	cmp	al,'.'
	jz	NoMoreName1
	stosb
	loop	MoveSampleNameLoopen
NoMoreName1:


DontPrintDosSampleName:
_ret2:
	Popf
	Popad
	clc
	Ret


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;				    Save SMP
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

SaveSMP Proc	Near
	Pushad
	Pushf
	mov	StackSave,esp
	mov	edx,SaveName		;Create File
	call	_CreateFile
	mov	ax,CreateErr
	jc	ErrorHandler

	movzx	ebp,CurrentSample
	mov	ecx,[SampleOffsetEnd+ebp*4]
	sub	ecx,[SampleOffsetStart+ebp*4]
	jle	AnotherLabel2

	mov	eax,ecx
;--..--
	push	ecx
	mov	cl,[VoiceControl+ebp]
	bt	cx,2
	setc	cl
	shl	eax,cl
	pop	ecx
;--..--
	xchg	ecx,eax 	;ecx=bytes, eax=samples

	push	eax
	push	ebp
	mov	eax,ecx
	mov	ebp,1037
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	TempBufferPtr,eax
	mov	ebx,eax
	pop	ebp
	pop	eax

	push	ecx
	mov	ecx,eax
	mov	eax,[SampleOffsetStart+ebp*4]
	xor	edx,edx
	call	GetSampleFromDRAM
	pop	ecx

	mov	edx,ebx
	call	WriteFile

	push	ebp
	mov	ebp,1037
	call	MemDisalloc
	pop	ebp

	mov	ecx,[LoopStart+ebp*4]
	mov	edx,[LoopEnd+ebp*4]
	sub	ecx,[SampleOffsetStart+ebp*4]
	sub	edx,[SampleOffsetStart+ebp*4]
	sub	edx,ecx
	mov	eax,ecx

;--..--
	mov	cl,[VoiceControl+ebp]
	bt	cx,2
	setc	cl
	shl	eax,cl
	shl	edx,cl
;--..--

	mov	cx,ax
	mov	ax,5701h
	int	21h
AnotherLabel2:

	call	_CloseFile
	mov	ax,CloseErr
	jc	ErrorHandler

	call	WaitDiskReady

	Popf
	clc
	Popad
	Ret
SaveSMP EndP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;				    Save S3M
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

SampleParaPtr	dd	0		;Relative SaveBuffer
PatternParaPtr	dd	0               ;Relative SaveBuffer
S3MSaveSize	dd	0		;Size of SaveBuffer

S3MInstHdrPtr	dd	0		;Relative SaveBuffer
S3MRowSize	dd	0
S3MChRowSize	dd	0
S3MChannels	db	0
S3MCommands	db	0
;S3MChanSett	db	0,8,9,1,2,10,11,3,4,12,13,5,6,14,15,7,0,8,9,1,2,10,11,3,4,12,13,5,6,14,15,7

SaveS3M	Proc	Near
	pushad
	pushf
	mov	StackSave,esp

	mov	edx,SaveName		;Create File
	call	_CreateFile
	mov	ax,CreateErr
	jc	ErrorHandler

	xor	eax,eax
	call	GetUsedPatterns		;Allocate for PatternParaPtrs
	cmp	ax,99
	jbe	@@S3MOkay3
	mov	ax,99
@@S3MOkay3:
	movzx	ebx,Samples		;Allocate for Inst ParaPtrs
	cmp	bx,99
	jbe	@@S3MOkay2
	mov	bx,99
@@S3MOkay2:
	mov	PatternParaPtr,ebx
	shl	PatternParaPtr,1
	add	ax,bx
	shl	eax,1

	push	ebx

	movzx	ebx,Positions		;Allocate for OrdNum
	bt	bx,0
	jc	Odd3
	inc	bx
Odd3:
	inc	bx
	cmp	bx,256
	jb	@@S3MOkay1
	mov	bx,256
@@S3MOkay1:
	add	PatternParaPtr,ebx
	add	PatternParaPtr,60h
	add	ax,bx
	add	ax,60h			;Header

	test	eax,0fh
	jz	S3MAligned2
	and	eax,not 0fh
	add	eax,10h
S3MAligned2:

	mov	S3MInstHdrPtr,eax	;Points at Inst Header (relative)
	pop	ebx

	push	eax edx			;Allocate for Inst Headers
	mov	eax,50h
	mul	ebx
	mov	ebx,eax
	pop	edx eax

	add	eax,ebx

	mov	S3MSaveSize,eax

	mov	ebp,1037
	mov	ebx,1
	call	MemAlloc		;Alloc Header
	jc	NotEnoughHiMem
	mov	TempBufferPtr,eax
	mov	edi,eax

	lea	esi,SongName		;Save SongName
	mov	ecx,28
	rep	movsb

	mov	ax,101ah		;Save 1ah, TYP
	stosw

	add	edi,2			;Add for xx

	mov	ax,Positions		;Save OrdNum
	bt	ax,0
	jc	Odd2
	inc	ax
Odd2:
	inc	ax
	cmp	ax,256
	jb	@@S3MOkay
	mov	ax,256
@@S3MOkay:
	stosw

	movzx	ax,Samples		;Save InsNum
	cmp	ax,99
	jbe	@@S3MOkay22
	mov	ax,99
@@S3MOkay22:
	stosw

	call	GetUsedPatterns		;Save PatNum
	cmp	ax,99
	jbe	@@S3MOkay4
	mov	ax,99
@@S3MOkay4:
	stosw

	add	edi,2			;Add for Flags

	mov	ax,1320h		;Save Cwt/V
	stosw

	mov	ax,2			;Save Ffv
	stosw

	mov	eax,'MRCS'		;Save SCRM
	stosd

	mov	al,40h			;Save g.v
	stosb

	mov	al,InitSpeed		;Save i.s
	stosb

	mov	al,byte ptr InitBPM+1	;Save i.t
	stosb

 	mov	al,0b0h			;Save m.v
 	stosb

	add	edi,12			;Add for xxxx and Special

	mov	dx,32			;Save Channel Settings
	call	GetUsedChannels
	mov	cx,ax
	sub	dx,cx
	lea	esi,PanPosition_Orig
	xor	bx,bx
@@ChSettings:
	lodsb
	cmp	al,80h
	jb	@@Left
	mov	al,8
	add	al,bl
	stosb
	inc	bl
	and	bl,7
	jmp	@@Nxt
@@Left:
	mov	al,0
	add	al,bh
	stosb
	inc	bh
	and	bh,7
@@Nxt:
	loop	@@ChSettings
	mov	cx,dx
	mov	al,-1
	rep	stosb

	mov	esi,PatternOrderPtr	;Save Orders
	movzx	ecx,Positions
@@ReadPos:
	lodsw
	cmp	ax,99
	jb	@@S3MOkay5
	mov	al,254
@@S3MOkay5:
	stosb
	loop	@@ReadPos

	mov	bx,Positions		;Fix even
	bt	bx,0
	jc	Odd
	mov	al,254
	stosb
Odd:
	mov	al,255			;EndByte
	stosb

	movzx	ecx,Samples		;Save ParaPtrs to insts.
	jecxz	@@NoS3MSamp
	cmp	cx,99
	jbe	@@S3MOkay6
	mov	cx,99
@@S3MOkay6:
	mov	ebx,S3MInstHdrPtr
@@NextSamp:
	mov	ax,bx
	shr	ax,4
	stosw
	add	bx,50h
	loop	@@NextSamp
@@NoS3MSamp:

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Instruments
	mov	edi,S3MInstHdrPtr
	add	edi,TempBufferPtr

	mov	SampleParaPtr,edi
	add	SampleParaPtr,12
	mov	ecx,TempBufferPtr
	sub     SampleParaPtr,ecx

	movzx	ecx,Samples		;Save SampleInfo
	cmp	cx,99
	jbe	@@S3MOkay7
	mov	cx,99
@@S3MOkay7:
	jecxz	NoS3MSamp
	mov	ebp,16
S3MSampleInfo:
	push	ecx

	mov	eax,[SampleOffsetEnd+ebp*4]
	sub	eax,[SampleOffsetStart+ebp*4]
	jle	SkipS3MSampo
	cmp	eax,65535
	jbe	@@Small1
	mov	eax,65535
@@Small1:

	push	ax
	mov	al,1			;Save [T]
	stosb
	add	edi,15			;Skip DOS name+MemSeg
	pop	ax

	stosd					;Save Samplelength

	mov	eax,[LoopStart+ebp*4]		;Save LoopBegin
	sub	eax,[SampleOffsetStart+ebp*4]
	cmp	eax,65535
	jbe	@@Small2
	mov	eax,65535
@@Small2:
	stosd

	mov	eax,[LoopEnd+ebp*4]		;Save LoopEnd
	sub	eax,[SampleOffsetStart+ebp*4]
	cmp	eax,65535
	jbe	@@Small3
	mov	eax,65535
@@Small3:
	stosd

	mov	al,[Volumes+ebp]		;Save Volume
	shr	al,1
	adc	al,0
	stosb
	add	edi,2				;Skip x and [P]

	mov     al,[VoiceControl+ebp]		;Save Flags (16 bits+loop)
	mov	ah,al
	and	al,4
 	shr	ah,3
 	and	ah,1
 	or	al,ah
 	stosb

	movzx	ebx,[SampleRates+ebp*2]		;Save C2Spd+FineTune
	mov	al,[FineTunes+ebp]
	and	eax,0fh
	cmp	al,8
	jb	@@PositiveFT

; Finetune: -1 -2 -3 -4 -5 -6 -7 -8
;    Value:  F	E  D  C  B  A  9  8
;	     1  2  3  4  5  6  7  8

	mov	eax,47
	call	GetAPeriod
	mov	edx,eax
	mov	eax,48
	call	GetAPeriod
	sub	edx,eax
	mov	ebx,eax

	mov	al,[FineTunes+ebp]
	and	eax,0fh
	neg	eax
	add	eax,16
	mul	edx
	shr	eax,3
	adc	eax,0

	add	ebx,eax
	mov	eax,428*8363*16
	xor	edx,edx
	div	ebx
	jmp	@@StoreFT

; Finetune: +7 +6 +5 +4 +3 +2 +1  0
;    Value:  7	6  5  4  3  2  1  0
@@PositiveFT:
	mov	eax,48
	call	GetAPeriod
	mov	edx,eax
	mov	eax,49
	call	GetAPeriod
	mov	ebx,edx
	sub	edx,eax

	mov	al,[FineTunes+ebp]
	and	eax,0fh
	mul	edx
	shr	eax,3
	adc	eax,0
	neg	eax

	add	ebx,eax
	mov	eax,428*8363*16
	xor	edx,edx
	div	ebx
@@StoreFT:
	stosd
	add	edi,12

	mov	[edi+28],'SRCS'
	jmp	ItsAS3MSamp


;In: eax=Note, ebx=SampleRate
;Out eax=Period
GetAPeriod	Proc	Near
	push	ebx ecx edx
	mov	ecx,12
	xor	edx,edx
	div	ecx
	mov	edx,[Pt_PeriodTable+edx*4]
	mov	ecx,eax
	shr	edx,cl
	mov	eax,edx
	mov	ecx,8363
	mul	ecx
	cmp	ebx,0
	jnz	NoC4Zero
	mov	ebx,8363
NoC4Zero:
	div	ebx
	pop	edx ecx ebx
	ret
GetAPeriod	EndP



SkipS3MSampo:
	add	edi,30h

ItsAS3MSamp:
	mov	esi,InstNamesPtr		;Save InstName
	mov	eax,30
	push	ebp
	shr	ebp,4
	dec	ebp
	mul	ebp
	add	esi,eax
	mov	ecx,28
	rep	movsb
	pop	ebp

	add	edi,4

	pop	ecx
	add	ebp,16
	loop	S3MSampleInfo
NoS3MSamp:

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Patterns

	xor	ebp,ebp
	call	GetUsedPatterns		;Save PatNum
	cmp	ax,99
	jbe	@@S3MOkay9
	mov	ax,99
@@S3MOkay9:
	movzx	ecx,ax
SaveS3MPatternsLoop:
	push	ecx
	push	ebp
	push	edi
	mov	edi,GUS_TempBuffPtr
	add	edi,2
	mov	esi,[AllocTable+ebp*8]
	cmp	esi,0
	jnz	@@NoEmptyPattern2
	mov	esi,EmptyPattern
@@NoEmptyPattern2:

	mov	al,[esi+11]			;Get channels+cmds in patt
	mov	ah,al
	and	al,31
	inc	al
	mov	S3MChannels,al
	shr	ah,5
	mov	S3MCommands,ah

	movzx	ecx,S3MChannels		;Get S3MRowSize and S3MChRowSize
	movzx	eax,S3MCommands
	shl	eax,1
	add	eax,2
	mov	S3MRowSize,eax
	mul	ecx
	mov	S3MChRowSize,eax

	add	esi,12
	movzx	ecx,byte ptr [esi-2]
	inc	ecx
	mov	ShortPatternLength,cx
	cmp	ecx,64
	mov	ecx,64
	jae	SaveS3MPatternLoop
	mov	cx,ShortPatternLength

SaveS3MPatternLoop:				;Save Pattern
	push	ecx
	push	esi

	movzx	ecx,S3MChannels			;Save One row
	xor	ebx,ebx
SaveS3MRowLoop:
	push	ecx
	push	esi

	call	SaveS3MData			;Save one channel in row

	pop	esi
	pop	ecx
	add	esi,S3MRowSize
	inc	ebx
	loop	SaveS3MRowLoop
	mov	al,0				;EOR
	stosb

	pop	esi
	pop	ecx
	add	esi,S3MChRowSize
	loop	SaveS3MPatternLoop

	cmp	ShortPatternLength,64
	jae	NoS3MPatternFill
	mov	ecx,64
	sub	cx,ShortPatternLength
	xor	al,al				;More EOR
	rep	stosb

NoS3MPatternFill:
	mov	ecx,edi				;Save Patt Size
	mov	edx,GUS_TempBuffPtr
	sub	ecx,edx
	mov	[edx],cx

	pop	edi
	push	ecx

	mov	edx,PatternParaPtr		;Save Patt ParaPtr
	add	edx,TempBufferPtr
	mov	eax,edi
	sub     eax,TempBufferPtr
	shr	eax,4
	mov	word ptr [edx],ax
	add	PatternParaPtr,2

	test	ecx,0fh
	jz	S3MAligned3
	and	ecx,not 0fh
	add	ecx,10h
S3MAligned3:
	add	ecx,S3MSaveSize
	mov	S3MSaveSize,ecx
	mov	eax,ecx
	mov	ebp,1037
	mov	ebx,1
	call	MemAlloc			;Alloc Pattern
	jc	NotEnoughHiMem
	mov	TempBufferPtr,eax

	pop	ecx
	test	ecx,0fh
	jz	S3MAligned4
	and	ecx,not 0fh
	add	ecx,10h
S3MAligned4:
	mov	edi,eax				;New Write Ptr
	add	edi,S3MSaveSize
	sub	edi,ecx
	mov	esi,GUS_TempBuffptr		;Read Ptr
	rep	movsb

	pop	ebp
	pop	ecx
	inc	ebp
	loop	SaveS3MPatternsLoop
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Sample ParaPointers

	mov	eax,S3MSaveSize		;First ParaPtr

	mov	edi,SampleParaPtr	;Write
	add	edi,TempBufferPtr

	movzx	ecx,Samples		;Save SampleInfo
	cmp	cx,99
	jbe	@@S3MOkay8
	mov	cx,99
@@S3MOkay8:
	jecxz	NoS3MSamp2
	mov	ebp,16
S3MSampleParaPtr:
	push	ecx

	mov	edx,eax
	shr	edx,4
	rol	edx,16
	rol	dx,8
	and	edx,0ffffff00h
	or	[edi],edx

	mov	edx,[SampleOffsetEnd+ebp*4]
	sub	edx,[SampleOffsetStart+ebp*4]

	cmp	edx,65535
	jbe	@@Small5
	mov	edx,65535
@@Small5:

	test	edx,0fh
	jz	S3MAligned5
	and	edx,not 0fh
	add	edx,10h
S3MAligned5:
	add	eax,edx

	add	edi,50h
	add	ebp,16
	pop	ecx
	loop	S3MSampleParaPtr
NoS3MSamp2:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Save Header+Patterns
	mov	ecx,S3MSaveSize
	mov	edx,TempBufferPtr	;Save Header+Patt
	call	writefile
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Save Samples

	movzx	ecx,Samples
	cmp	ecx,99
	jbe	NoSampleS3MCut
	mov	ecx,99
NoSampleS3MCut:
	jecxz	NoFuckingS3MSaveSamples
	mov	ebp,16

SaveS3MSampleLoopen:
	mov	CurrentSample,bp
	mov	ebx,ebp
	push	ecx
	mov	eax,[SampleOffsetEnd+ebp*4]
	sub	eax,[SampleOffsetStart+ebp*4]
	jle	AnotherS3MLabel

	cmp	eax,65535
	jbe	@@Small4
	mov	eax,65535
@@Small4:

	test	eax,0fh
	jz	S3MAligned
	and	eax,not 0fh
	add	eax,10h
S3MAligned:
	mov	ecx,eax
;--..--
	push	ecx
	mov	cl,[VoiceControl+ebx]
	bt	cx,2
	setc	cl
	shl	eax,cl
	pop	ecx
;--..-- 			;eax=bytes, ecx=samples
	push	eax
	push	ebp
	mov	ebp,1037
	xor	ebx,ebx
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	TempBufferPtr,eax
	mov	ebx,eax
	mov	edx,eax
	pop	ebp

	push	edx
	mov	eax,[SampleOffsetStart+ebp*4]
	mov	edx,80h
	call	GetSampleFromDRAM
	pop	edx

	pop	ecx	;eax
	call	WriteFile
AnotherS3MLabel:
	pop	ecx
	add	ebp,16
	loop	SaveS3MSampleLoopen

NoFuckingS3MSaveSamples:
	mov	ebp,1037
	call	MemDisalloc

	call	_CloseFile
	mov	ax,CloseErr
	jc	ErrorHandler

	call	WaitDiskReady
	popf
	clc
	popad
	ret
SaveS3M	EndP

IndexPtr	dd	0
S3MVolPtr	dd	0
S3MCmdPtr	dd	0
S3MIndex	db	0
S3MCmdTable	db	-1,-1,0bh,0dh,0ah,02h,01h,03h,04h,-1,0,06h,05h,-1,-1,09h,-1,13h,07h,-1,-1,-1,2ch,0
S3MCmdTableLen	equ	$-S3MCmdTable
S3MCmdSTable	db	0,0,0,1,3,2,0bh,4,0,0,0,0,0ch,0dh,0eh,0
SaveS3MData	Proc	Near
	push	ebx
	mov	S3MIndex,0
	mov	IndexPtr,edi
	inc	edi

	lodsw			;Read Period+InstNr
	cmp	ax,0
	jz	NoS3MNote1
	cmp	al,1
	jz	S3MNoteOff
	mov	dl,-1
	sub	al,2
	jl	GotS3MPeriod
	xor	dx,dx
	cmp	al,95		;Max Note
	ja	NoS3MNote1
	push	ax
	mov	bl,12
	xor	ah,ah
	div	bl
	shl	al,4
	or	al,ah
	mov	dl,al
	pop	ax
	jmp	GotS3MPeriod
S3MNoteOff:
	mov	dl,0feh
GotS3MPeriod:
	or	S3MIndex,32
	mov	al,dl
	stosb

	mov	al,ah
	cmp	al,99
	jbe	NoS3MInst
	mov	al,0
NoS3MInst:
	stosb
NoS3MNote1:

	movzx	ecx,S3MCommands
ScanS3MCommands:
	lodsw                   ;Command
	cmp	al,0ch
	jz	AS3MVol
	cmp	ax,0
	jz	AS3MCmd
	test    S3MIndex,128
	jnz     AS3MCmd
	mov	S3MCmdPtr,esi
	or	S3MIndex,128
	jmp	AS3MCmd
AS3MVol:
	test    S3MIndex,64
	jnz     AS3MCmd
	mov	S3MVolPtr,esi
	or	S3MIndex,64
AS3MCmd:
	mov	al,S3MIndex
	and	al,0c0h
	cmp	al,0c0h
	loopnz	ScanS3MCommands

	test	S3MIndex,64
	jz	NoS3MVol
	mov	edx,S3MVolPtr
	mov	ax,[edx-2]
	shr	ah,1
	adc	ah,0
	mov	[edi],ah
	inc	edi
NoS3MVol:

	test	S3MIndex,128
	jz	NoS3MCmd

	mov	edx,S3MCmdPtr
	mov	ax,[edx-2]
;-----------------------------------------
	xor	ebx,ebx
	mov	ecx,S3MCmdTableLen
@@LoopS3MSearch:
	cmp	al,[S3MCmdTable+ebx]
	jz	OrdinaryS3MCmd
	inc	ebx
	loop	@@LoopS3MSearch

	cmp	al,8h			;Some Special conversions
	jz	ConvertS3M_8
	cmp	al,0fh
	jz	ConvertS3M_F
	cmp	al,21h
	jz	ConvertS3M_21
	cmp	al,22h
	jz	ConvertS3M_22
	cmp	al,11h
	jz	ConvertS3M_11
	cmp	al,12h
	jz	ConvertS3M_12

	cmp	al,0eh			;Convert E commands
	jnz	NoValidS3MCmd
	mov	bl,ah
	and	bl,0f0h
	cmp	bl,090h
	jnz	@@Skip0
	and	ah,0fh			;Cmd E9x -> Q0x
	mov	al,11h
	jmp	@@NoSkip
@@Skip0:
	cmp	bl,0b0h
	jnz	@@Skip1
	or	ah,0f0h			;Cmd EBx -> DFx
	mov	al,4
	jmp	@@NoSkip
@@Skip1:
	cmp	bl,0a0h
	jnz	@@Skip2
	or	ah,0f0h			;Cmd EAx -> DxF
	rol	ah,4
	mov	al,4
	jmp	@@NoSkip
@@Skip2:
	cmp	bl,020h
	jnz	@@Skip3
	or	ah,0f0h			;Cmd E2x -> EFx
	mov	al,5
	jmp	@@NoSkip
@@Skip3:
	cmp	bl,010h
	jnz	@@Skip4
	or	ah,0f0h			;Cmd E1x -> FFx
	mov	al,6
	jmp	@@NoSkip
@@Skip4:

	shr	bl,4			;S commands
	and	ebx,0fh
	mov	bh,[S3MCmdSTable+ebx]
	cmp	bh,0
	jz	NoValidS3MCmd
	shl	bh,4
	and	ah,00fh
	or	ah,bh
	mov	al,13h
@@NoSkip:
	stosw
	jmp	NoS3MCmd

ConvertS3M_21:
	mov	bl,6
	jmp	OrdinaryS3MCmd
ConvertS3M_22:
	mov	bl,5
	jmp	OrdinaryS3MCmd
ConvertS3M_11:
	and	ah,00fh
	or	ah,0e0h			;Cmd 21xx -> FEx
	mov	bl,6
	jmp	OrdinaryS3MCmd
ConvertS3M_12:
	and	ah,00fh
	or	ah,0e0h			;Cmd 22xx -> EEx
	mov	bl,5
	jmp	OrdinaryS3MCmd
ConvertS3M_8:
	and	ah,00fh
	or	ah,080h
	mov	bl,13h
	jmp	OrdinaryS3MCmd
ConvertS3M_F:
	mov	bl,1h
	cmp	ah,1fh
	jbe	OrdinaryS3MCmd
	mov	bl,14h
	jmp	OrdinaryS3MCmd
;--------------------------
OrdinaryS3MCmd:
	mov	al,bl
	stosw
	jmp	NoS3MCmd
NoValidS3MCmd:
	and	S3MIndex,7fh		;Clear Command bit
NoS3MCmd:
	pop	ebx
	cmp     S3MIndex,0
	jz	@@Nothing
	or	S3MIndex,bl
	mov	edx,IndexPtr
	mov	al,S3MIndex
	mov	[edx],al
	ret
@@Nothing:
	dec	edi
	ret
SaveS3MData	EndP


;out ax=patterns
GetUsedPatterns	Proc	Near
	push	esi ecx
	mov	esi,PatternOrderPtr	;Check for Nr of Used Patterns
	movzx	ecx,Positions
	xor	eax,eax
PattNrLoop2:
	cmp	[esi],ax
	jbe	NoChange3
	mov	ax,[esi]
NoChange3:
	add	esi,2
	loop	PattNrLoop2
	inc	ax
	pop	ecx esi
	ret
GetUsedPatterns	EndP



XM_TrackerName	db	1ah,'Velvet Studio 1.0   ',04,01
XM_Channels	dd	0		;Max Channels in song
XM_CurrChannels	dd	0		;Current Pattern
XM_CurrCommands	dd	0
XM_Index	dw	0
XM_Struc	db	5 dup(0)
XM_StrucPtr	dd	0
XM_VCMD		dd	0		;Where VOL Cmd was found
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;				    Save XM
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SaveXM:
	Pushad
	Pushf
	mov	StackSave,esp
	mov	edx,SaveName		;Create File
	call	_CreateFile
	mov	ax,CreateErr
	jc	ErrorHandler

	mov	edi,GUS_TempBuffPtr

	lea	esi,XM_Determ		;Move XM header
	mov	ecx,17
	rep	movsb
	lea	esi,SongName		;Move SongName

	mov	ecx,20
	rep	movsb

	lea	esi,XM_TrackerName	;Move TrackerName
	mov	ecx,23
	rep	movsb

	mov	eax,114h		;Header Length
	stosd

	mov	ax,Positions            ;Store SongLength
	cmp	ax,256
	jbe	@@XMFine
	mov	ax,256
@@XMFine:
	stosw

	xor	ax,ax			;Store RestartPos
	stosw

	call	GetUsedChannels
	bt	ax,0
	adc	ax,0			;Only even # channels Allowed.
	stosw				;Store # of Channels
	mov	XM_Channels,eax

 	call	GetUsedPatterns         ;Store # of patterns
	stosw

 	movzx	ax,Samples              ;Store # of Instruments
 	cmp	ax,128
 	jbe	@@XMFine1
	mov	ax,128
@@XMFine1:
	stosw

	movzx	ax,LinFreq              ;Store Flags
	stosw

	movzx	ax,InitSpeed            ;Store Initial Speed
	stosw

	mov	ax,InitBPM              ;Store Initial BPM
	shr	ax,8
	stosw

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Positions

	mov	esi,PatternOrderPtr	;Save Orders
	movzx	ecx,Positions
@@ReadPos:
	lodsw
	cmp	ax,256
	jb	@@XMOkay
	mov	al,0
@@XMOkay:
	stosb
	loop	@@ReadPos

	mov	ecx,256
	sub	cx,Positions
	xor	al,al
	rep	stosb

	mov	edx,GUS_TempBuffPtr
	mov	ecx,edi
	sub	ecx,edx
	call	writefile

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Patterns

	xor	ebp,ebp
 	call	GetUsedPatterns         ;Get # of patterns
	movzx	ecx,ax
XMPatt:					;----------------------- Patt
	push	ecx ebp

	mov	esi,[AllocTable+ebp*8]
	cmp	esi,0
	jnz	@@NoEmptyPattern
	mov	esi,EmptyPattern
@@NoEmptyPattern:

	mov	edi,GUS_TempBuffPtr

	mov	eax,9			;Header Size
	stosd

	xor	ax,ax			;Packing Type
	stosb

	mov	al,[esi+10]		;Rows in Pattern
	inc	ax
	movzx	ecx,ax
	stosw

	mov	al,[esi+11]		;Channels in Pattern
	mov	bl,al
	and	eax,31
	inc	eax
	mov	XM_CurrChannels,eax
	shr	ebx,5
	and	ebx,7
	mov	XM_CurrCommands,ebx

	add	esi,12

	add	edi,2			;Save space for Packed Size

XMRows:					;----------------------- Rows
	push	ecx

	mov	ecx,XM_CurrChannels
XMChannels:				;----------------------- Channels
	push	ecx

	mov	XM_StrucPtr,0
	mov	XM_Index,0
	mov	XM_VCMD,-1

	lodsb				;Read Note
	cmp	al,0
	jz	@@XMNoNote
	cmp	al,97
	jbe	@@Gutt
	mov	al,1
	jmp	@@XMNoNoteOff
@@Gutt:
	cmp	al,1
	jnz	@@XMNoNoteOff
	mov	al,98
@@XMNoNoteOff:
	dec	al
	bts	XM_Index,0
	mov	ebx,XM_StrucPtr
	mov	[XM_Struc+ebx],al
	inc	XM_StrucPtr
@@XMNoNote:

	lodsb				;Read Inst
	cmp	al,0
	jz	@@XMNoInst
	cmp	al,128
	jbe	@@XMNoMaxInst
	mov	al,0
@@XMNoMaxInst:
	bts	XM_Index,1
	mov	ebx,XM_StrucPtr
	mov	[XM_Struc+ebx],al
	inc	XM_StrucPtr
@@XMNoInst:

	mov	ecx,XM_CurrCommands	;Check for a VOL cmd
	mov	ebx,-2
@@XMCommands:
	add	ebx,2
	cmp	byte ptr [esi+ebx],0ch
	loopnz	@@XMCommands
	jnz	@@NoXMVol

	mov	al,byte ptr [esi+ebx+1]
	shr	al,1
	add	al,10h
	bts	XM_Index,2
	mov	ebx,XM_StrucPtr
	mov	[XM_Struc+ebx],al
	inc	XM_StrucPtr
	jmp	XMOrdinaryCMD
@@NoXMVol:

	mov	ecx,XM_CurrCommands	;Check for a VOL column cmd
	xor	ebx,ebx
@@XMCommands2:
	cmp	byte ptr [esi+ebx],03h
	jz	@@XMGotACmd_3
	cmp	byte ptr [esi+ebx],04h
	jz	@@XMGotACmd_4
	cmp	byte ptr [esi+ebx],08h
	jz	@@XMGotACmd_8
	cmp	byte ptr [esi+ebx],0ah
	jz	@@XMGotACmd_a
	cmp	byte ptr [esi+ebx],18h
	jz	@@XMGotACmd_18
	cmp	byte ptr [esi+ebx],0eh
	jnz	@@XMNoECmd
	mov	al,byte ptr [esi+ebx+1]
	and	al,0f0h
	cmp	al,0a0h
	jz	@@XMGotACmd_EA
	cmp	al,0b0h
	jz	@@XMGotACmd_EB
@@XMNoECmd:
	add	ebx,2
	loop	@@XMCommands2
	jmp	@@NoXMVolCmd

@@XMGotACmd_3:
	mov	al,byte ptr [esi+ebx+1]
	test	al,0fh
	jnz	@@XMNoECmd
	shr	al,4
	or	al,0f0h
	jmp	@@XMGotACmd


@@XMGotACmd_4:
	mov	al,byte ptr [esi+ebx+1]
	test	al,0fh
	jz	@@Up2
	test	al,0f0h
	jnz	@@XMNoECmd

	and	al,0fh
	or	al,0b0h
	jmp	@@XMGotACmd
@@Up2:
	shr	al,4
	or	al,0a0h
	jmp	@@XMGotACmd


@@XMGotACmd_8:
	mov	al,byte ptr [esi+ebx+1]
	and	al,0fh
	or	al,0c0h
	jmp	@@XMGotACmd


@@XMGotACmd_A:
	mov	al,byte ptr [esi+ebx+1]
	test	al,0fh
	jz	@@Up
	and	al,0fh
	or	al,60h
	jmp	@@XMGotACmd
@@Up:
	shr	al,4
	or	al,70h
	jmp	@@XMGotACmd



@@XMGotACmd_18:
	mov	al,byte ptr [esi+ebx+1]
	test	al,0fh
	jz	@@Up3
	and	al,0fh
	or	al,0e0h
	jmp	@@XMGotACmd
@@Up3:
	shr	al,4
	or	al,0d0h
	jmp	@@XMGotACmd

@@XMGotACmd_EA:
	mov	al,byte ptr [esi+ebx+1]
	and	al,0fh
	or	al,090h
	jmp	@@XMGotACmd


@@XMGotACmd_EB:
	mov	al,byte ptr [esi+ebx+1]
	and	al,0fh
	or	al,080h
	jmp	@@XMGotACmd

@@XMGotACmd:
	mov	XM_VCMD,ebx
	bts	XM_Index,2
	mov	ebx,XM_StrucPtr
	mov	[XM_Struc+ebx],al
	inc	XM_StrucPtr
@@NoXMVolCmd:

XMOrdinaryCMD:
	mov	ecx,XM_CurrCommands	;Check for an ordinary cmd
	xor	ebx,ebx
@@XMCommands2:
	cmp	XM_VCMD,ebx		;Check if cmd is in VOL column
	jz	@@XMNoECmd
	cmp	byte ptr [esi+ebx],0ch
	jz	@@XMNoECmd
	cmp	word ptr [esi+ebx],0
	jz	@@XMNoECmd
	mov	al,byte ptr [esi+ebx]
	cmp	al,0
	jz	@@NoXMEType
	cmp	al,0fh
	jbe	@@XMNoEnhanced

	cmp	al,01Eh				;Check Special 1E1x
	jnz	@@NoX_E2
	mov	ah,byte ptr [esi+ebx+1]
	and	ah,0f0h
	cmp	ah,010h
	jnz	@@NoX_E1
	mov	al,0eh
	jmp	@@XMNoEnhanced
@@NoX_E1:
	cmp	ah,020h
	jnz	@@NoX_E2
	mov	al,0eh
	jmp	@@XMNoEnhanced
@@NoX_E2:

	cmp	al,21h				;Check Special 21xx
	jnz	@@NoX_21
	mov	al,1
	jmp	@@XMNoEnhanced
@@NoX_21:

	cmp	al,22h				;Check Special 22xx
	jnz	@@NoX_22
	mov	al,2
	jmp	@@XMNoEnhanced
@@NoX_22:

	push	ecx
	mov	ecx,18
@@XAgain:
	cmp	[XMCmdTbl+ecx],al
	jz	@@XMGotcha
	dec	ecx
	jge	@@XAgain
	pop	ecx
	jmp	@@XMNoECmd

@@XMGotcha:
	cmp	cl,17
	jz	@@XM_X1
	cmp	cl,18
	jz	@@XM_X2
	add	cl,10h
	mov	al,cl
	pop	ecx
	jmp	@@XMNoEnhanced
@@XM_X1:
	add	cl,10h
	mov	al,cl
	bts	XM_Index,3
	mov	edx,XM_StrucPtr
	mov	[XM_Struc+edx],al
	inc	XM_StrucPtr
	mov	al,byte ptr [esi+ebx+1]
	and	al,0fh
	or	al,010h
	bts	XM_Index,4
	mov	edx,XM_StrucPtr
	mov	[XM_Struc+edx],al
	inc	XM_StrucPtr
	pop	ecx
	jmp	@@XMNoECmd
@@XM_X2:
	add	cl,10h-1
	mov	al,cl
	bts	XM_Index,3
	mov	edx,XM_StrucPtr
	mov	[XM_Struc+edx],al
	inc	XM_StrucPtr
	mov	al,byte ptr [esi+ebx+1]
	and	al,0fh
	or	al,020h
	bts	XM_Index,4
	mov	edx,XM_StrucPtr
	mov	[XM_Struc+edx],al
	inc	XM_StrucPtr
	pop	ecx
	jmp	@@XMNoECmd

@@XMNoEnhanced:
	bts	XM_Index,3
	mov	edx,XM_StrucPtr
	mov	[XM_Struc+edx],al
	inc	XM_StrucPtr
@@NoXMEType:
	mov	al,byte ptr [esi+ebx+1]
	cmp	al,0
	jz	@@NoXMEParm
	bts	XM_Index,4
	mov	edx,XM_StrucPtr
	mov	[XM_Struc+edx],al
	inc	XM_StrucPtr
	cmp	[XM_Struc+edx-1],010h
	jnz	@@XMNo_2c
	shr	[XM_Struc+edx],1
@@XMNo_2c:
	jmp	@@NoXMEParm

@@XMNoECmd:
	add	ebx,2
	loop	@@XMCommands2

@@NoXMEParm:
	mov	ecx,XM_CurrCommands	;Add to next channel
	shl	ecx,1
	add	esi,ecx

	mov	ax,XM_Index
;	cmp	ax,15
;	jz	@@XMNoPack
	cmp	ax,31
	jz	@@XMNoPack
	or	ax,80h
	stosb				;Store Pack Byte
@@XMNoPack:
	mov	ecx,XM_StrucPtr
	push	esi
	lea	esi,XM_Struc
	rep	movsb
	pop	esi

	pop	ecx
	loop	XMChannels		;^-^-^-^-^-^-^-^-^-^-^-^ Channels

	mov	ecx,XM_Channels		;Fill out channels
	sub	ecx,XM_CurrChannels
	mov	al,80h
	rep	stosb

	pop	ecx
	loop	XMRows			;^-^-^-^-^-^-^-^-^-^-^-^ Rows


	mov	ecx,edi			;Write Pattern
	mov	edx,GUS_TempBuffPtr
	sub	ecx,edx
	sub	ecx,9
	mov	word ptr [edx+7],cx
	add	ecx,9
	call	WriteFile

	pop	ebp ecx
	inc	ebp
	loop	XMPatt			;^-^-^-^-^-^-^-^-^-^-^-^ Patt

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Instruments

	mov	ebp,1
	movzx	ecx,Samples
	jecxz	XMNoFuckingInstruments
XMSaveInstrumentLoopen:
	push	ecx

	mov	edi,GUS_TempBuffPtr	;Clear buffer
	mov	ecx,50000/4
	xor	eax,eax
	rep	stosd

	mov	edi,GUS_TempBuffPtr
	add	edi,4

	mov	eax,30			;Store Inst. name
	mul	ebp
	sub	eax,30
	mov	esi,eax
	add	esi,InstNamesPtr
	mov	ecx,22
	rep	movsb

	mov	al,0			;Store Inst Type
	stosb

	mov	esi,17			;Store Nr of Samples in inst.
	mov	ecx,16
	mov	ebx,ebp
	shl	ebx,4
@@NxtSmp:
	mov	eax,[SampleOffsetEnd+ebx*4]
	cmp	eax,[SampleOffsetStart+ebx*4]
	jbe	@@NoSmp
	mov	esi,ecx
@@NoSmp:
	inc	ebx
	loop	@@NxtSmp

	mov	ecx,17
	sub	ecx,esi
	mov	ax,cx
	stosw

	mov	ax,40			;Sample Header Size
	stosd

	jecxz	XMNoFuckingSamples1	;No samples in Inst


	push	ecx

	GetOffset ebp,esi,ENV_SplitKBD  ;Store SplitInfo
	mov	ecx,96
	rep	movsb

;--------
	push	edi
	xor	ebx,ebx
	GetOffset ebp,edx,ENV_NrVolPoints	;# of Volume Points
	movzx	ecx,byte ptr [edx]
	inc	ecx
	cmp	ecx,12
	jbe	@@XMNoVolEnvProbb
	mov	ecx,12
@@XMNoVolEnvProbb:
	GetOffset ebp,esi,ENV_VolPoints		;Store Volume Points
@@XMNextVolPoint:
	lodsw
	and	ax,511
	add	bx,ax
	mov	ax,bx
	cmp	ax,324
	ja	@@XMVolProbb
	stosw
	lodsb
	shr	al,1
	and	ax,0ffh
	stosw
	loop	@@XMNextVolPoint
@@XMVolProbb:
	pop	edi
	add	edi,48

;--------
	push	edi
	xor	ebx,ebx
	GetOffset ebp,edx,ENV_NrPanPoints	;# of Pan Points
	movzx	ecx,byte ptr [edx]
	inc	ecx
	cmp	ecx,12
	jbe	@@XMNoPanEnvProbb
	mov	ecx,12
@@XMNoPanEnvProbb:
	GetOffset ebp,esi,ENV_PanPoints		;Store Panning Points
@@XMNextPanPoint:
	lodsw
	and	ax,511
	add	bx,ax
	mov	ax,bx
	cmp	ax,324
	ja	@@XMPanProbb
	stosw
	lodsb
	shr	al,2
	and	ax,0ffh
	stosw
	loop	@@XMNextPanPoint
@@XMPanProbb:
	pop	edi
	add	edi,48
;--------

	GetOffset ebp,edx,ENV_NrVolPoints	;# of Volume Points
	mov	al,[edx]
	inc	al
	stosb

	GetOffset ebp,edx,ENV_NrPanPoints	;# of Pan Points
	mov	al,[edx]
	inc	al
	stosb

	GetOffset ebp,edx,ENV_VolSustPoint	;Store Volume sustain point
	mov	al,[edx]
	stosb
	GetOffset ebp,edx,ENV_VolStart		;Store Volume loop start point
	mov	al,[edx]
	stosb
	GetOffset ebp,edx,ENV_VolEnd		;Store Volume loop end point
	mov	al,[edx]
	stosb

	GetOffset ebp,edx,ENV_PanSustPoint	;Store Pan sustain point
	mov	al,[edx]
	stosb
	GetOffset ebp,edx,ENV_PanStart		;Store Pan loop start point
	mov	al,[edx]
	stosb
	GetOffset ebp,edx,ENV_PanEnd		;Store Pan loop end point
	mov	al,[edx]
	stosb

;--------
	xor	ax,ax                           ;Store Vol flags
	GetOffset ebp,edx,ENV_Flags
	mov	bx,[edx]
	bt	bx,0
	rcl	ax,1
	bt	bx,1
	rcl	ax,1
	bt	bx,2
	rcl	ax,1
	stosb

	xor	ax,ax				;Store Pan flags
	bt	bx,3
	rcl	ax,1
	bt	bx,4
	rcl	ax,1
	bt	bx,5
	rcl	ax,1
	stosb

	xor	eax,eax				;Store Vib info
	stosd


	GetOffset ebp,edx,ENV_VolFade
	mov	ax,[edx]
	stosw					;Store Vol fade

	xor	ax,ax				;Reserved
	stosw

	mov	edx,GUS_TempBuffPtr		;Write Inst Header
	mov	dword ptr [edx],107h		;Store Inst header Size
	mov	ecx,edi
	sub	ecx,edx
	add	ecx,20				;Some Stupid Pad
	call	writefile


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Save Samples in Inst.
	pop	ecx				;# of samples


	push	ebp ecx
	shl	ebp,4
XMSaveSampleInfoLoopen:
	push	ecx
	mov	edi,GUS_TempBuffPtr

	mov	cl,[VoiceControl+ebp]		;16 bits?
	bt	cx,2
	setc	cl
	mov	ebx,[SampleOffsetStart+ebp*4]	;Store Sample Length

	mov	eax,[SampleOffsetEnd+ebp*4]
	sub	eax,ebx
	shl	eax,cl
	stosd

	mov	eax,[LoopStart+ebp*4]		;Store LoopStart
	sub	eax,ebx
	shl	eax,cl
	stosd

	mov	eax,[LoopEnd+ebp*4]		;Store Loop Length
	sub	eax,[LoopStart+ebp*4]
	shl	eax,cl
	stosd

	mov	al,[Volumes+ebp]		;Store Volume
	shr	al,1
	stosb

	call	XMCalcC4Rate
	mov	al,[FineTunes+ebp]		;Store FineTune
	and	al,0fh
	cmp	al,8
	setae	bl

	sub	al,XMFineTuneAdd
	jge	@@Great
	add	al,16
	cmp	al,15
	jbe	@@Great
	mov	al,15
@@Great:
	cmp	al,8
	setbe	bh
	and	bl,bh
	jz	@@NoWrap
	mov	al,8
@@NoWrap:
	shl	al,4
	stosb

	xor	ax,ax
	mov	bl,[VoiceControl+ebp]		;Store Flags
	bt	bx,3
	jnc	@@XMNoLoop
	mov	al,1
	bt	bx,4
	jnc	@@XMNoLoop
	mov	al,2
@@XMNoLoop:
	and	bl,4
	shl	bl,2
	or	al,bl
	stosb

	mov	al,[FineTunes+ebp]		;Store PanPot
	and	al,0f0h
	jnz	@@NoCHSettings
	mov	al,80h
@@NoCHSettings:
	cmp	al,70h
	ja	NoXiPanFix2
	sub	al,10h
NoXiPanFix2:
	stosb

	mov	al,[RelativeNote+ebp]		;Store Relative Note
	add	al,XMRelNoteAdd
	stosb

	xor	al,al				;Reserved
	stosb

	mov	ecx,ebp				;Store Sample Name
	sub	ecx,16
	mov	eax,22
	mul	ecx
	add	eax,SampleNamesPtr
	mov	esi,eax
	mov	ecx,22
	rep	movsb

	mov	edx,GUS_TempBuffPtr		;Write Samp Header
	mov	ecx,edi
	sub	ecx,edx
	call	writefile

	pop	ecx
	inc	ebp
	loop	XMSaveSampleInfoLoopen
	pop	ecx ebp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Save Sample Data
	push	ebp
	shl	ebp,4
XMSaveSampleDataLoopen:
	push	ecx
	mov	CurrentSample,bp

	mov	eax,[SampleOffsetEnd+ebp*4]
	sub	eax,[SampleOffsetStart+ebp*4]
	mov	edx,eax
	jle	XMAnotherLabel
	mov	cl,[VoiceControl+ebp]
	bt	cx,2
	setc	cl
	shl	eax,cl
	mov	ecx,eax
	mov	eax,edx		;ecx=bytes, eax=samples

	pushad
	mov	eax,ecx
	mov	ebp,1037
	mov	ebx,0
	call	MemAlloc
	mov	TempBufferPtr,eax
	jc	NotEnoughHiMem
	popad

	push	ecx eax
	mov	ecx,eax
	mov	eax,[SampleOffsetStart+ebp*4]
	xor	edx,edx
	mov	ebx,TempBufferPtr
	call	GetSampleFromDRAM
	pop	eax ecx

	pushad
	mov	ecx,eax
	mov	bl,[VoiceControl+ebp]
	bt	bx,2
	jc	@@XMDelta16

@@XMDelta8:
	mov	esi,TempBufferPtr
	mov	edi,esi
	lodsb
	mov	bl,al
	stosb
@@XMDelta8Loop:
	lodsb
	mov	bh,al
	sub	al,bl
	mov	bl,bh
	stosb
	loop	@@XMDelta8Loop
	jmp	@@XMDelta

@@XMDelta16:
	mov	esi,TempBufferPtr
	mov	edi,esi
	lodsw
	mov	bx,ax
	stosw
@@XMDelta16Loop:
	lodsw
	mov	dx,ax
	sub	ax,bx
	mov	bx,dx
	stosw
	loop	@@XMDelta16Loop
@@XMDelta:
	popad

	mov	edx,TempBufferPtr
	call	WriteFile

	push	ebp
	mov	ebp,1037
	call	MemDisalloc
	pop	ebp

XMAnotherLabel:
	pop	ecx
	inc	ebp
	loop	XMSaveSampleDataLoopen
	pop	ebp
	jmp	XMFuckingSamples1

XMNoFuckingSamples1:
	mov	edx,GUS_TempBuffPtr		;Write Inst Header
	mov	dword ptr [edx],21h		;Store Inst header Size
	mov	ecx,edi
	sub	ecx,edx
	call	writefile

XMFuckingSamples1:
	pop	ecx
	inc	ebp
	loop	XMSaveInstrumentLoopen

XMNoFuckingInstruments:


	call	_CloseFile
	mov	ax,CloseErr
	jc	ErrorHandler

	call	WaitDiskReady

	Popf
	clc
	Popad
	Ret

;out eax=max # of channels used
GetUsedChannels	Proc	Near
	push	ebx ecx ebp esi

	xor	ebp,ebp
	call	GetUsedPatterns
	movzx	ecx,ax

	xor	eax,eax
	xor	ebx,ebx
@@NextPatt:
	mov	esi,[AllocTable+ebp*8]
	cmp	esi,0
	jnz	@@NoEmptyPattern2
	mov	esi,EmptyPattern
@@NoEmptyPattern2:
	mov	bl,[esi+11]			;Get channels+cmds in patt
	and	bl,31
	inc	bl
	cmp	ebx,eax
	jbe	@@Skip
	mov	eax,ebx
@@Skip:
	inc	ebp
	loop	@@NextPatt

	pop	esi ebp ecx ebx
	ret
GetUsedChannels	EndP

XMFineTuneAdd	db	0
XMRelNoteAdd	db	0
FoundLast	dd	0
XMCalcC4Rate	Proc	Near
	pushad
	movzx	ebx,[SampleRates+ebp*2]
	cmp	ebx,0
	jnz	XMOlofsson
	mov	ebx,522
	mov	[SampleRates+ebp*2],bx
	mov	FoundLast,ebx
XMOlofsson:
	mov	eax,428*8363*16
	xor	edx,edx
	div	ebx
	cmp	eax,57
	jae	XMNoBiGDeal2
	mov	eax,57
XMNoBiGDeal2:
	xor	ecx,ecx
	xor	esi,esi
	mov	edx,10
XMOuterSearchLoop:
	push	edx

	xor	edi,edi
	mov	edx,12
XMInnerSearchLoop:
	mov	ebx,[pt_PeriodTable+edi*4]
	shr	ebx,cl
	cmp	eax,ebx
	jae	XMFoundIt
	mov	FoundLast,ebx
	inc	esi
	inc	edi
	dec	edx
	jnz	XMInnerSearchLoop

	inc	ecx
	pop	edx
	dec	edx
	jnz	XMOuterSearchLoop
	popad
	ret
XMFoundIt:
	mov	ax,si
	sub	ax,48
	mov	XMRelNoteAdd,al

	push	ebx
	mov	ebx,FoundLast
	mov	eax,428*8363*16		;Found
	xor	edx,edx
	div	ebx
	mov	FoundLast,eax
	pop	ebx

	mov	eax,428*8363*16		;Found
	xor	edx,edx
	div	ebx

	movzx	ebx,[SampleRates+ebp*2]	;True
	push	eax
	sub	eax,ebx			;Found - True
	shl	eax,3			;*8
	pop	ebx
	sub	ebx,FoundLast		;Found - Last
	xor	edx,edx
	div	ebx			;Divide
	mov	XMFineTuneAdd,al

	pop	ecx
	popad
	ret
XMCalcC4Rate	EndP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;				    Load S3I
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
LoadDigiPlayer3:
	cmp	Sample0,1
	jz	_ret2
	mov	edx,dword ptr [DetectBuffer+10h]
	push	edx
	movzx	eax,CurrentSample
	mov	esi,[SampleOffsetStart+eax*4]
	mov	eax,[SampleOffsetEnd+eax*4]
	sub	eax,esi
	jbe	NoSampleHere2
	call	DisallocSample
NoSampleHere2:

	movzx	ebx,CurrentSample
	lea	esi,DetectBuffer
	mov	[SampleOffsetStart+ebx*4],0
	movzx	eax,word ptr [esi+10h]
	mov	[SampleOffsetEnd+ebx*4],eax
	movzx	eax,word ptr [esi+14h]
	mov	[LoopStart+ebx*4],eax
	movzx	eax,word ptr [esi+18h]
	mov	[LoopEnd+ebx*4],eax
	mov	[FineTunes+ebx],0
	movzx	eax,word ptr [esi+20h]
	mov	[SampleRates+ebx*2],ax
	movzx	eax,byte ptr [esi+1ch]
	shl	al,1
	cmp	al,128
	jb	Guru2
	mov	al,127
Guru2:
	mov	[Volumes+ebx],al
	mov	al,0
	cmp	byte ptr [esi+1fh],0
	jz	NoDP3Loop
	mov	al,8
NoDP3Loop:
	mov	[VoiceControl+ebx],al
	add	esi,30h

	pop	edx
	mov	eax,edx
	call	AllocSample
	jnc	NoDP3Err
	call	FixAllocSampleError
NoDP3Err:

	push	edx
	mov	edi,SampleNamesPtr
	movzx	eax,CurrentSample
	sub	eax,16
	mov	ebx,22
	mul	ebx
	add	edi,eax
	xor	al,al
	mov	ecx,22
	push	edi
	rep	stosb
	pop	edi
	mov	ecx,22
	rep	movsb
	pop	edx

	mov	eax,dword ptr [DetectBuffer+0ch]
	rol	ax,8
	rol	eax,16
	and	eax,0ffffffh
	shl	eax,4
	mov	bl,0
	call	_Lseekfile

	pushad
	mov	eax,edx
	mov	ebp,1024
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampMainOffset,eax
	popad

	mov	ecx,edx
	push	edx
	mov	edx,SampMainOffset
	call	ReadFile
	pop	edx
	mov	ax,ReadErr
	jc	ErrorHandler
	movzx	ebx,CurrentSample

	push	edx
	mov	edx,128
	call	MoveSample
	pop	edx

;	mov	ebp,1024
;	call	MemDisalloc

	call	_CloseFile
	mov	ax,CloseErr
	jc	ErrorHandler

;	lea	edi,DetectBuffer		;Clear Tmp Buffer
;	xor	al,al
;	mov	ecx,144/4
;	rep	stosd

	call	WaitDiskReady
	Popf
	Popad
	clc
	Ret

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;				    Load XI
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

LoadXIsample:
	cmp	Sample0,1
	jz	_ret2
	mov	O_InProgress,1
	call	KillInst2
	call	SetInitialEnvelopes
	mov	O_InProgress,0

	mov	ErrorLoadSample,0
	mov	eax,42h
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler

	lea	esi,DetectBuffer+21		;Get Name
	push	edx
	mov	edi,InstNamesPtr
	movzx	eax,CurrentInstrument
	dec	eax
	mov	ebx,30
	mul	ebx
	add	edi,eax
	xor	al,al
	mov	ecx,30
	push	edi
	rep	stosb
	pop	edi
	mov	ecx,22
	rep	movsb
	pop	edx

	movzx	ebx,CurrentInstrument		;Inst Nr

	GetOffset ebx,edx,ENV_SplitKBD		;Load Split data
	mov	ecx,96
	call	ReadFile
	mov	ax,ReadErr
	jc	ErrorHandler

	lea	edx,DetectBuffer		;Load rest of Header
	mov	ecx,136
	call	ReadFile
	mov	ax,ReadErr
	jc	ErrorHandler

	mov	ax,word ptr [DetectBuffer+134]
	mov	NrOfWaveForms,ax		;Load nr of samples in inst.
	mov	SampHeaderSize,40
	call	LoadXIData

EndOfInstLoad:
	call	_CloseFile
	mov	ax,CloseErr
	jc	ErrorHandler

	call	WaitDiskReady

	Popf
	Popad
	clc
	Ret


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;				    Load AIS
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


LoadAIS:
	cmp	Sample0,1
	jz	_ret2
	mov	eax,7
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler

	lea	edx,AISVer
	mov	ecx,1
	call	ReadFile
	mov	ax,ReadErr
	jc	ErrorHandler

	cmp	byte ptr AISVer,0aah
	jz	NewAIS

	mov	AISVer,0
	mov	eax,7
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler
	jmp	OldAIS3
NewAIS:
	lea	edx,AISVer
	mov	ecx,2
	call	ReadFile
	mov	ax,ReadErr
	jc	ErrorHandler

	cmp	AISVer,AISVersion
	mov	ax,BadVersionErr
	ja	ErrorHandler
OldAIS3:
;	 pushad
;	 mov	 ecx,16
;	 movzx	 ebp,CurrentInstrument
;	 shl	 ebp,4
;DisallAIS:
;	 push	 ecx
;	 mov	 CurrentSample,bp
;	 mov	 esi,[SampleOffsetStart+ebp*4]
;	 mov	 eax,[SampleOffsetEnd+ebp*4]
;	 sub	 eax,esi
;	 jle	 NoAISSampleHere
;	 call	 DisallocSample
;NoAISSampleHere:
;	 mov	 [SampleOffsetStart+ebp*4],0
;	 mov	 [LoopStart+ebp*4],0
;	 mov	 [LoopEnd+ebp*4],0
;	 mov	 [SampleOffsetEnd+ebp*4],0
;	 mov	 [FineTunes+ebp],0
;	 mov	 [SampleRates+ebp*2],8363
;	 mov	 [Volumes+ebp],127
;	 mov	 [VoiceControl+ebp],0
;
;	 mov	 ecx,ebp
;	 sub	 ecx,16
;	 mov	 eax,22
;	 mul	 ecx
;	 add	 eax,SampleNamesPtr
;	 mov	 edi,eax
;	 mov	 ecx,22
;	 xor	 al,al
;	 rep	 stosb
;
;	 inc	 ebp
;	 pop	 ecx
;	 loop	 DisallAIS
;	 popad

	mov	O_InProgress,1
	call	KillInst2
	call	SetInitialEnvelopes
	mov	O_InProgress,0

	movzx	ebp,CurrentInstrument
	mov	ecx,1
	call	LoadAISInInstrument
	movzx	ebx,CurrentInstrument
	GetOffset ebx,edx,ENV_Shadow	;Erase Shadow Info
	mov	byte ptr [edx],0
	shl	ebx,4
	mov	ecx,16
	call	LoadAISSampleData
	jmp	EndOfInstLoad

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;				    Load WAV
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

LoadWAV:
	cmp	Sample0,1
	jz	_ret2
	mov	eax,12
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler
	movzx	ebx,CurrentSample

NextWAVBlock:
	mov	edx,GUS_TempBuffPtr
	mov	ecx,8
	call	ReadFile
	mov	ax,ReadErr
	jc	ErrorHandler
	cmp	dword ptr [edx],' tmf'
	jz	WAV_fmt
	cmp	dword ptr [edx],'atad'
	jz	WAV_data
	jmp	NextWAVBlock

WAV_fmt:
	mov	ecx,[edx+4]
	call	ReadFile
	mov	ax,ReadErr
	jc	ErrorHandler

	cmp	word ptr [edx],1	;Check RAW
	mov	ax,BadVersionErr
	jnz	ErrorHandler

	cmp	word ptr [edx+2],1	;Check MONO
	mov	ax,BadVersionErr
	jnz	ErrorHandler
	movzx	eax,CurrentSample
	mov	esi,[SampleOffsetStart+eax*4]
	mov	eax,[SampleOffsetEnd+eax*4]
	sub	eax,esi
	jbe	NoSampleHere3
	call	DisallocSample
NoSampleHere3:

	mov	eax,dword ptr [edx+4]	;Sampling Rate
	call	InsSampleRate

	mov	dx,word ptr [edx+0eh]	;Bits
	cmp	dx,12
	mov	ax,BadVersionErr
	jz	ErrorHandler

	shr	dl,2
	and	dl,4
	mov	[VoiceControl+ebx],dl

	mov	[SampleOffsetStart+ebx*4],0
	mov	[LoopStart+ebx*4],0
	mov	[LoopEnd+ebx*4],0
	mov	[FineTunes+ebx],0
	mov	[SampleRates+ebx*2],8363
	mov	[RelativeNote+ebx],0
	mov	[Volumes+ebx],7fh

	mov	ecx,ebx 		;Clear Sample Name
	sub	ecx,16
	mov	eax,22
	mul	ecx
	add	eax,SampleNamesPtr
	mov	edi,eax
	mov	ecx,22
	xor	al,al
	rep	stosb

	jmp	NextWAVBlock

WAV_data:
	mov	eax,[edx+4]
	mov	ecx,eax
;--..--
	push	ecx
	mov	cl,[VoiceControl+ebx]
	bt	cx,2
	setc	cl
	shr	eax,cl
	pop	ecx
;--..-- 			;ecx=bytes, eax=samples
	mov	[SampleOffsetEnd+ebx*4],eax
	push	ebx eax
	mov	eax,ecx
	mov	ebp,1024
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampMainOffset,eax
	pop	eax ebx

	push	eax
	mov	edx,SampMainOffset
	call	ReadFile
	pop	eax

	call	AllocSample
	jnc	NoWAVErr
	call	FixAllocSampleError
NoWAVErr:

	mov	dx,0
	mov	cl,[VoiceControl+ebx]
	bt	cx,2
	jc	WAV16
	mov	dx,128
WAV16:
	call	MoveSample
	jmp	EndOfInstLoad


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;				    Load PAT
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LoadPAT:
	cmp	Sample0,1
	jz	_ret2
	mov	O_InProgress,1
	call	KillInst2
	call	SetInitialEnvelopes
	mov	O_InProgress,0

	mov	eax,83h
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler

	movzx	eax,CurrentInstrument
	dec	eax
	mov	ebx,30
	mul	ebx
	mov	edx,InstNamesPtr
	add	edx,eax
;	mov	edx,edi
;	xor	al,al
;	mov	ecx,30
;	rep	stosb
	mov	ecx,16
	call	ReadFile
	mov	ax,ReadErr
	jc	ErrorHandler

	mov	eax,0c6h
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler

	mov	NrOfWaveForms,0
	lea	edx,NrOfWaveForms
	mov	ecx,1
	call	ReadFile
	mov	ax,ReadErr
	jc	ErrorHandler

	mov	eax,0efh
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler

	movzx	ebp,CurrentInstrument
	shl	ebp,4
	movzx	ecx,NrOfWaveForms
LoadPATWaveForm:
	push	ecx
	push	ebp
	mov	edx,GUS_TempBuffPtr
	mov	ecx,96
	call	ReadFile
	mov	ax,ReadErr
	jc	ErrorHandler

	mov	CurrentSample,bp

	push	edx
	mov	ecx,ebp 		;Load Sample Name
	sub	ecx,16
	mov	eax,22
	mul	ecx
	pop	edx
	add	eax,SampleNamesPtr
	mov	edi,eax
	mov	esi,edx
	mov	ecx,7
	rep	movsb

	mov	al,[edx+55]		;Fix Flags
	bt	ax,1
	setc	ah
	ror	ah,1
	mov	Convert,ah
	xor	ah,ah
	bt	ax,4
	rcl	ah,2
	bt	ax,3
	rcl	ah,1
	bt	ax,2
	rcl	ah,1
	bt	ax,0
	rcl	ah,3
	mov	[VoiceControl+ebp],ah
	shr	ax,8
	bt	ax,2
	setc	cl

	mov	[SampleOffsetStart+ebp*4],0	;Loop
	mov	eax,[edx+8]
	shr	eax,cl
	mov	[SampleOffsetEnd+ebp*4],eax
	mov	eax,[edx+12]
	shr	eax,cl
	mov	[LoopStart+ebp*4],eax
	mov	eax,[edx+16]
	shr	eax,cl
	mov	[LoopEnd+ebp*4],eax

	movzx	eax,word ptr [edx+20]		;SAMPLE RATE
	mov	ebx,ebp
	call	InsSampleRate
	call	GetNoteFromSampleFreq
	mov	ebx,eax

	mov	eax,[edx+30]			;Root
	call	GetNoteFromFreq
	sub	ebx,eax
	mov	[RelativeNote+ebp],bl

	movzx	ebx,CurrentInstrument		;Inst Nr
	GetOffset ebx,edi,ENV_SplitKBD

	mov	eax,[edx+22]			;Low
	call	GetNoteFromFreq
	add	edi,eax
	mov	ecx,eax

	mov	eax,[edx+26]			;High
	call	GetNoteFromFreq
	sub	eax,ecx
	mov	ecx,eax
	mov	ax,bp
	and	al,0fh
	rep	stosb

	mov	al,[edx+36]			;Pan
	shl	al,4
	mov	[FineTunes+ebp],al

	mov	[SampleRates+ebp*2],8363
	mov	[Volumes+ebp],7fh

	mov	eax,[SampleOffsetEnd+ebp*4]
	mov	ecx,eax
;--..--
	push	ecx
	mov	cl,[VoiceControl+ebp]
	bt	cx,2
	setc	cl
	shl	eax,cl
	pop	ecx
;--..--
	xchg	ecx,eax 	;ecx=bytes, eax=samples


	push	ebp eax
	mov	eax,ecx
	mov	ebp,1024
	xor	ebx,ebx
	call	MemAlloc
	mov	edx,eax
	pop	eax ebp
	jc	NotEnoughHiMem

	push	eax
	call	ReadFile
	pop	eax

	push	eax
	call	AllocSample
	jnc	NoPATErr
	call	FixAllocSampleError
NoPATErr:
	pop	ecx

	mov	ebx,ebp
	movzx	edx,Convert
	call	MoveSample

	mov	ebp,1024
	call	MemDisAlloc

	pop	ebp
	pop	ecx
	inc	ebp
	loop	LoadPATWaveForm

	jmp	EndOfInstLoad

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Pack sample method 1
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Input:
;	  esi = input offset
;	  edi = output offset
;	  ecx = input size
; Output:
;	  ecx = output size
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Inputoffset		dd	0
outputoffset		dd	0
Inputsize		dd	0
outputmax		dd	0
packcharacter		db	255
scanbuffer		db	256	dup(0)
PackMethod1	Proc	Near
	pushad
	mov	inputoffset,esi
	mov	outputoffset,edi
	mov	inputsize,ecx

	mov	edi,outputoffset	  ;delta split
	mov	ecx,inputsize
	xor	dl,dl
deltasplitloop:
	lodsb
	xchg	al,dl
	sub	al,dl
	cmp	al,0
	jge	neggahere
	neg	al
	or	al,10000000b
neggahere:
	stosb
	loop	deltasplitloop



	mov	edi,inputoffset
	mov	ecx,inputsize
	xor	eax,eax 		;clear
	mov	edx,ecx
	shr	ecx,2
	rep	stosd
	mov	ecx,edx
	and	ecx,3
	rep	stosb

	mov	ecx,inputsize		;bit split
	mov	edi,inputoffset
	mov	esi,outputoffset
	mov	eax,esi
	add	eax,inputsize
	mov	outputmax,eax
	mov	dl,10000000b
bitloop1:
	push	ecx

	mov	ecx,8
	xor	dh,dh
	xor	bl,bl
bitloop2:
	lodsb
	and	al,dl
	add	cl,dh
	rol	al,cl
	sub	cl,dh
	or	bl,al
	cmp	outputmax,esi
	jne	notrestart
	mov	esi,outputoffset
	ror	dl,1
	inc	dh
notrestart:
	loop	bitloop2

	mov	[edi],bl
	inc	edi
	pop	ecx
	loop	bitloop1

					;scan for pack character
	lea	edi,scanbuffer
	mov	ecx,64
	xor	eax,eax
	rep	stosd

	mov	esi,inputoffset
	mov	ecx,inputsize
	xor	eax,eax
scanaloop1:
	lodsb
	cmp	byte ptr [eax+scanbuffer],255
	jz	notinca
	inc	byte ptr [eax+scanbuffer]
notinca:
	loop	scanaloop1

	mov	ecx,256
	lea	esi,scanbuffer
	mov	bx,0ffffh
	xor	dl,dl
scanloop2:
	lodsb
	cmp	al,bh
	jae	notsetbajsa
	mov	bh,al
	mov	bl,dl
notsetbajsa:
	inc	dl
	loop	scanloop2
	mov	packcharacter,bl

					;header
					;0  Unpacked size
					;4  Packed size
					;8  Packcharacter
					;9 Packed data...
					;packing
	mov	esi,inputoffset
	mov	edi,outputoffset
	mov	ebp,esi
	add	ebp,inputsize
	mov	ecx,inputsize
	mov	dword ptr [edi],ecx
	mov	al,packcharacter
	mov	byte ptr [edi+8],al
	add	edi,9
packingloop:
	cmp	esi,ebp
	jz	afterpacking
	lodsb
storeloop:
	cmp	esi,ebp
	jz	storeafterpacking
	mov	bl,al
	lodsb
	cmp	bl,al
	jz	packingon
	cmp	bl,packcharacter
	jnz	nopackc
	mov	byte ptr [edi],bl
	mov	byte ptr [edi+1],0
	add	edi,2
	jmp	storeloop
nopackc:
	mov	byte ptr [edi],bl
	inc	edi
	jmp	storeloop

packingon:
	mov	ecx,2
packingonloop:
	cmp	esi,ebp
	jz	soonendofpack
	cmp	ecx,255
	jz	soonendofpack
	lodsb
	inc	ecx
	cmp	al,bl
	jz	packingonloop
	dec	esi
	dec	ecx
soonendofpack:
	cmp	ecx,2
	jbe	storetwo
	mov	al,packcharacter
	mov	byte ptr [edi],al
	mov	byte ptr [edi+1],cl
	mov	byte ptr [edi+2],bl
	add	edi,3
	jmp	packingloop
storetwo:
	mov	al,bl
	cmp	bl,packcharacter
	jz	packpackcharacter
	stosb
	stosb
	jmp	packingloop
packpackcharacter:
	mov	ah,0
	stosw
	stosw
	jmp	packingloop
storeafterpacking:
	stosb
afterpacking:

	mov	ebp,outputoffset
	sub	edi,outputoffset
	mov	inputoffset,edi
	sub	edi,9
	mov	dword ptr [ebp+4],edi

	popad
	mov	ecx,inputoffset
	ret
PackMethod1	Endp


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;			      Save Protracker
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

ShortPatternLength	dw	0
SaveProTracker	Proc	Near
	pushad
	pushf
	mov	StackSave,esp

	mov	edx,SaveName		;Create File
	call	_CreateFile
	mov	ax,CreateErr
	jc	ErrorHandler

	mov	edi,GUS_TempBuffPtr
	mov	ecx,1084/4
	xor	eax,eax
	rep	stosd

	mov	edi,GUS_TempBuffPtr	;Save ModName
	lea	esi,SongName
	mov	ecx,20
	rep	movsb
	pushad
	mov	ecx,20
	sub	edi,20
	call	FixLoChars
	popad

	mov	ecx,31			;Save SampleInfo
	mov	ebp,16
PTSampleInfo:
	push	ecx
	mov	esi,InstNamesPtr      ;Save Samplename
	mov	eax,30
	push	ebp
	shr	ebp,4
	dec	ebp
	mul	ebp
	add	esi,eax
	mov	ecx,22
	inc	ebp
	mov	eax,ebp
	cmp	al,Samples
	jbe	SampleExists
	xor	al,al
	rep	stosb
SampleExists:
	rep	movsb
	pop	ebp

	pushad
	mov	ecx,22
	sub	edi,22
	call	FixLoChars
	popad

	mov	eax,[SampleOffsetEnd+ebp*4]	    ;Save Samplelength
	sub	eax,[SampleOffsetStart+ebp*4]
	shr	eax,1
	cmp	eax,07fffh
	jbe	PTSampleFits
	mov	eax,07fffh
PTSampleFits:
	xchg	al,ah
	stosw

	mov	al,[FineTunes+ebp]	;Save FineTune
	and	al,0fh
	stosb

	mov	al,[Volumes+ebp]	;Save Volume
	shr	al,1
	adc	al,0
	stosb

	mov	eax,[LoopStart+ebp*4]	    ;Save LoopStart
	sub	eax,[SampleOffsetStart+ebp*4]
	shr	eax,1
	cmp	eax,07fffh
	jbe	PTSampleFits1
	mov	eax,0
PTSampleFits1:
	xchg	al,ah
	stosw

	mov	eax,[LoopEnd+ebp*4]	    ;Save LoopLength
	sub	eax,[LoopStart+ebp*4]
	shr	eax,1
	cmp	eax,07fffh
	jbe	PTSampleFits2
	mov	eax,1
PTSampleFits2:
	cmp	eax,0
	jnz	NoStupidAmigaFix
	mov	eax,1
NoStupidAmigaFix:
	xchg	al,ah
	stosw

	pop	ecx
	add	ebp,16
	loop	PTSampleInfo

	mov	ax,Positions		;Save Positions
	cmp	ax,128
	jbe	PTPosFits
	mov	ax,128
PTPosFits:
	stosb
	mov	al,127			;Store Repeat byte
	stosb

	push	edi			;Clear Pos order
	mov	ecx,128
	mov	al,0
	rep	stosb
	pop	edi

	push	edi
	mov	ebp,'.K.M'
	movzx	ecx,Positions		;Save PositionOrder
	mov	esi,PatternOrderPtr
PTPosLoop:
	lodsw
	cmp	ax,63
	jbe	PTPattFits
	cmp	ax,99
	ja	PTPattFits2
	mov	ebp,'!K!M'
	jmp	PTPattFits
PTPattFits2:
	mov	al,0
PTPattFits:
	stosb
	loop	PTPosLoop
	pop	edi
	add	edi,128

	cmp	Channels,4
	jz	GotSaveChannels
	mov	al,Channels

	mov	ebp,'NHC0'
	cmp	al,10
	jb	FewChannels
	mov	ebp,'HC00'

	mov	bl,al
	aam
	shr	ax,8
	mov	cl,6
	mul	cl
	add	al,bl
	mov	bl,al

	shr	al,4
	add	al,'0'
	mov	cx,bp
	mov	cl,al
	mov	bp,cx

	mov	al,bl
	and	al,0fh
	mov	bx,bp
	add	al,'0'
	mov	bh,al
	mov	bp,bx
	jmp	GotSaveChannels
FewChannels:
	mov	bx,bp
	add	al,'0'
	mov	bl,al
	mov	bp,bx

GotSaveChannels:
	mov	eax,ebp 		;Store filetype
	stosd


	mov	edx,GUS_TempBuffPtr	;Save header
	mov	ecx,1084
	call	writefile
;---------------------------- Convert Patterns

	mov	esi,GUS_TempBuffPtr	;Check for Highest PatternNumber
	add	esi,952
	mov	ecx,128
	xor	eax,eax
PTPattNrLoop:
	cmp	byte ptr [esi],al
	jbe	PTNoChange
	mov	al,byte ptr [esi]
PTNoChange:
	inc	esi
	loop	PTPattNrLoop
	inc	al
	and	ax,0ffh
	mov	Patterns,ax

	xor	ebp,ebp
	movzx	ecx,Patterns
SavePTPatternsLoop:
	push	ecx
	push	esi
	push	ebp
	mov	esi,[AllocTable+ebp*8]
	cmp	esi,0
	jnz	NoEmptyPattern2
	mov	esi,EmptyPattern
NoEmptyPattern2:
	add	esi,12
	movzx	ecx,byte ptr [esi-2]
	inc	ecx
	mov	ShortPatternLength,cx
	cmp	ecx,64
	mov	ecx,64
	jae	PatternLengthOkay
	mov	cx,ShortPatternLength

PatternLengthOkay:
	mov	edi,GUS_TempBuffPtr
	add	edi,1084
SavePTPatternLoop:
	push	ecx
	push	esi

	movzx	ecx,Channels
SavePTRowLoop:
	push	ecx
	push	esi
	push	ebp

	cmp	SaveMODOctaves,0
	jz	MOD3Oct

	mov	bl,26
	mov	bh,85
	jmp	MODPer

MOD3Oct:
	mov	bl,38
	mov	bh,73

MODPer:
	xor	edx,edx
	lodsb			;Period
	cmp	al,bh
	ja	GotPTPeriod
	cmp	al,bl
	jb	GotPTPeriod

	movzx	edx,al
	sub	edx,26
	mov	dx,[Periods+edx*2]
GotPTPeriod:
	lodsb			;Sample Nr
	cmp	al,31
	jbe	GotPTSamp
	mov	al,0
GotPTSamp:
	movzx	ebx,al
	lodsw
	xchg	al,ah		;Command
	cmp	ah,0fh
	jbe	NoCommandCut
	mov	ax,0
NoCommandCut:
	cmp	ah,0ch
	jnz	NoPTVol
	shr	al,1
	adc	al,0
NoPTVol:
	shl	edx,16
	ror	bx,4
	ror	ebx,4
	shl	bx,4
	or	edx,ebx
	or	dx,ax
	mov	eax,edx
	ror	ax,8
	ror	eax,16
	ror	ax,8
	mov	ecx,4
Stora:
	stosb
	shr	eax,8
	loop	Stora

	pop	ebp
	pop	esi
	pop	ecx
	add	esi,RowSize
	loop	SavePTRowLoop

	pop	esi
	pop	ecx
	add	esi,ChRowSize
	loop	SavePTPatternLoop

	cmp	ShortPatternLength,64
	jae	NoPatternFill
	mov	ecx,64
	sub	cx,ShortPatternLength
	mov	eax,ChRowsize
	mul	ecx
	xor	al,al
	rep	stosb

NoPatternFill:
	mov	edx,GUS_TempBuffPtr	;Save one pattern
	add	edx,1084
	mov	ecx,edi
	sub	ecx,edx
	call	writefile

	pop	ebp
	pop	esi
	pop	ecx
	inc	ebp
	add	esi,PatternSize2
	loop	SavePTPatternsLoop

;------------------------------ Save Samples

	movzx	ecx,Samples
	cmp	ecx,31
	jbe	NoSamplePTCut
	mov	ecx,31
NoSamplePTCut:
	jecxz	NoFuckingPTSaveSamples
	mov	ebp,16

SavePTSampleLoopen:
	mov	CurrentSample,bp
	push	ecx
	mov	eax,[SampleOffsetEnd+ebp*4]
	sub	eax,[SampleOffsetStart+ebp*4]
	jle	AnotherPTLabel
	mov	ecx,eax
;--..--
	push	ecx
	mov	cl,[VoiceControl+ebx]
	bt	cx,2
	setc	cl
	shl	eax,cl
	pop	ecx
;--..-- 			;eax=bytes, ecx=samples
	push	ebp
	mov	ebp,1037
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	TempBufferPtr,eax
	mov	ebx,eax
	mov	edx,eax
	pop	ebp

	cmp	ecx,0fffeh
	jbe	NoSamplePTCut2
	mov	ecx,0fffeh
NoSamplePTCut2:
	and	ecx,not 1
	push	edx
	mov	eax,[SampleOffsetStart+ebp*4]
	xor	edx,edx
	call	GetSampleFromDRAM
	pop	edx

	bt	word ptr [VoiceControl+ebp],2
	jnc	NoMOD16Conv

	mov	esi,edx
	mov	edi,edx
	push	ecx
NextConv:
	lodsw
	mov	al,ah
	stosb
	loop	NextConv
	pop	ecx
NoMOD16Conv:

	cmp	DestroySample,0
	jz	EiDestroit
	mov	word ptr [ebx],0
EiDestroit:

	call	WriteFile
AnotherPTLabel:
	pop	ecx
	add	ebp,16
	loop	SavePTSampleLoopen

	mov	ebp,1037
	call	MemDisalloc

NoFuckingPTSaveSamples:


	call	_CloseFile
	mov	ax,CloseErr
	jc	ErrorHandler

	call	WaitDiskReady

	popf
	popad
	ret
SaveProTracker	EndP


IFE	DISABLESAVE
SaveAIS Proc	Near
	Pushad
	Pushf
	mov	StackSave,esp
	mov	edx,SaveName		;Create File
	call	_CreateFile
	mov	ax,CreateErr
	jc	ErrorHandler
	mov	edi,GUS_TempBuffPtr

	lea	esi,AIShdr		;Move AIShdr
	mov	ecx,7
	rep	movsb
	mov	al,0aah
	stosb
	mov	ax,AISVersion
	stosw

	movzx	ebp,CurrentInstrument
	call	SaveInst
	movzx	ebp,CurrentInstrument
	shl	ebp,4
	mov	ecx,16
	jmp	SaveAISinInst
SaveAIS EndP

SaveWAV	Proc	Near
	pushad
	pushf
	mov	StackSave,esp
	mov	edx,SaveName		;Create File
	call	_CreateFile
	mov	ax,CreateErr
	jc	ErrorHandler
	mov	edi,GUS_TempBuffPtr
	movzx	ebp,CurrentSample

	mov	dword ptr [edi],'FFIR'		;RIFF
	mov	dword ptr [edi+8],'EVAW'	;WAVE
	mov	dword ptr [edi+12],' tmf'	;fmt
	mov     dword ptr [edi+16],16		;Block Size

	mov	word ptr [edi+20+0],1		;PCM
	mov	word ptr [edi+20+2],1		;MONO
	mov	ebx,ebp
	call	GetSampleRate
	mov     dword ptr [edi+20+4],eax	;Sampling Rate
	mov     dword ptr [edi+20+8],eax	;Average bytes/sec
	mov	word ptr [edi+20+0ch],0		;Word Alignment

	mov	ebx,[SampleOffsetStart+ebp*4]	;Sample Size
	mov	ecx,[SampleOffsetEnd+ebp*4]
	sub	ecx,ebx

	mov	ax,8
	mov	bl,[VoiceControl+ebp]
	and	bl,4
	jz	@@8Bit
	mov	ax,16
	shl	ecx,1				;Convert to bytes
@@8Bit:
	mov	word ptr [edi+20+0eh],ax	;Bits/Sample
	add	ecx,44				;Header Size
	mov	dword ptr [edi+4],ecx		;Block Size inclusive header

	sub	ecx,44
	mov	dword ptr [edi+36],'atad'	;Sample Data
	mov	dword ptr [edi+36+4],ecx	;Sample Block Size

	mov	edx,GUS_TempBuffPtr
	sub	edi,edx
	mov	ecx,44
	call	writefile			;Write Header

	mov	eax,[SampleOffsetEnd+ebp*4]	;Save Sample Data
	sub	eax,[SampleOffsetStart+ebp*4]
	mov	edx,eax
	jle	@@QuitWAV
	mov	cl,[VoiceControl+ebp]
	bt	cx,2
	setc	cl
	shl	eax,cl
	mov	ecx,eax 	;ecx=bytes, eax=samples
	mov	eax,edx

	pushad
	mov	eax,ecx
	mov	ebp,1037
	xor	ebx,ebx
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	TempBufferPtr,eax
	popad

	push	ecx
	mov	ecx,eax
	mov	eax,[SampleOffsetStart+ebp*4]
	movzx	edx,[VoiceControl+ebp]
	and	edx,4
	xor	edx,4
	shl	edx,5
	mov	ebx,TempBufferPtr
	call	GetSampleFromDRAM
	pop	ecx
	mov	edx,TempBufferPtr
	call	WriteFile

	mov	ebp,1037
	call	MemDisalloc

@@QuitWAV:
	call	_CloseFile
	mov	ax,CloseErr
	jc	ErrorHandler
	popf
	popad
	ret
SaveWAV	EndP


SaveInst	Proc	near
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ;Save Instruments
	mov	eax,30
	mul	ebp
	sub	eax,30
	mov	esi,eax
	add	esi,InstNamesPtr
	mov	ecx,30
	call	ScanNameBackWrds
	mov	al,cl
	stosb				;Store Inst. name Length
	rep	movsb			;Store Inst. name

	mov	esi,17
	mov	ecx,16
	mov	ebx,ebp
	shl	ebx,4
NxtSmp:
	mov	eax,[SampleOffsetEnd+ebx*4]
	cmp	eax,[SampleOffsetStart+ebx*4]
	jbe	NoSmp
	mov	esi,ecx
NoSmp:
	inc	ebx
	loop	NxtSmp

	mov	ecx,17
	sub	ecx,esi
	mov	al,cl
	stosb				;Store Nr of Samples in inst.
	jecxz	NoFuckingSamples1	;No samples in Inst

	push	ecx

	GetOffset ebp,esi,ENV_SplitKBD
	mov	ecx,120
	rep	movsb			;Store SplitInfo

;--------
	GetOffset ebp,edx,ENV_VolSpeed
	mov	al,[edx]
	stosb				;Store Volume Speed
	GetOffset ebp,edx,ENV_VolSustPoint
	mov	al,[edx]
	stosb				;Store Volume sustain point
	GetOffset ebp,edx,ENV_VolStart
	mov	al,[edx]
	stosb				;Store Volume loop start point
	GetOffset ebp,edx,ENV_VolEnd
	mov	al,[edx]
	stosb				;Store Volume loop end point
	GetOffset ebp,edx,ENV_NrVolPoints
	mov	al,[edx]
	inc	al
	stosb				;Store # of Volume Points

	movzx	ecx,al
	lea	ecx,[ecx+ecx*2]
	GetOffset ebp,esi,ENV_VolPoints
	rep	movsb			;Store Volume Points

;--------
	GetOffset ebp,edx,ENV_PanSpeed
	mov	al,[edx]
	stosb				;Store Pan Speed
	GetOffset ebp,edx,ENV_PanSustPoint
	mov	al,[edx]
	stosb				;Store Pan sustain point
	GetOffset ebp,edx,ENV_PanStart
	mov	al,[edx]
	stosb				;Store Pan loop start point
	GetOffset ebp,edx,ENV_PanEnd
	mov	al,[edx]
	stosb				;Store Pan loop end point
	GetOffset ebp,edx,ENV_NrPanPoints
	mov	al,[edx]
	inc	al
	stosb				;Store # of Pan Points

	movzx	ecx,al
	lea	ecx,[ecx+ecx*2]
	GetOffset ebp,esi,ENV_PanPoints
	rep	movsb			;Store Pan Points

;--------
	GetOffset ebp,edx,ENV_VibSpeed
	mov	al,[edx]
	stosb				;Store Vib Speed
	GetOffset ebp,edx,ENV_VibSustPoint
	mov	al,[edx]
	stosb				;Store Vib sustain point
	GetOffset ebp,edx,ENV_VibStart
	mov	al,[edx]
	stosb				;Store Vib loop start point
	GetOffset ebp,edx,ENV_VibEnd
	mov	al,[edx]
	stosb				;Store Vib loop end point
	GetOffset ebp,edx,ENV_NrVibPoints
	mov	al,[edx]
	inc	al
	stosb				;Store # of Vib Points

	movzx	ecx,al
	lea	ecx,[ecx+ecx*2]
	GetOffset ebp,esi,ENV_VibPoints
	rep	movsb			;Store Vib Points

;--------
	GetOffset ebp,edx,ENV_Shadow
	mov	al,[edx]
	stosb				;Store Shadow Info
	GetOffset ebp,edx,ENV_VolFade
	mov	ax,[edx]
	stosw				;Store Vol fade
	GetOffset ebp,edx,ENV_Flags
	mov	ax,[edx]
	stosw				;Store flags

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Save Samples in Inst.
	pop	ecx

	push	ebp
	shl	ebp,4
SaveSampleInfoLoopen:
	push	ecx

	mov	ecx,ebp
	sub	ecx,16
	mov	eax,22
	mul	ecx
	add	eax,SampleNamesPtr
	mov	esi,eax
	mov	ecx,22
	call	ScanNameBackWrds
	mov	al,cl
	stosb				;Store Sample name Length
	rep	movsb			;Store Sample Name

	mov	ebx,[SampleOffsetStart+ebp*4]
	mov	eax,[SampleOffsetEnd+ebp*4]
	sub	eax,ebx

;	pushf
;	bt	[VoiceControl+ebp],2
;	setc	cl
;	shl	eax,cl
;	popf

	stosd
	jz	SkipSaveThisSample	;No Sample

	mov	eax,[LoopStart+ebp*4]
	sub	eax,ebx
	stosd
	mov	eax,[LoopEnd+ebp*4]
	sub	eax,ebx
	stosd
	push	ebx
	mov	ebx,ebp					;THE SAMPLERATE
	call	GetSampleRate
	pop	ebx
	jnc	@@Okay
	xor	ax,ax
@@Okay:
	stosw
	mov	al,[FineTunes+ebp]
	stosb
	mov	ax,[SampleRates+ebp*2]
	stosw
	mov	al,[RelativeNote+ebp]
	stosb
	mov	al,[Volumes+ebp]
	stosb
	mov	al,[VoiceControl+ebp]
	and	al,11111100b
	mov	ah,PackingByte
	bt	ax,2
	jnc	@@Skip
	xor	ah,ah		;=16 bits sample, No pack
@@Skip:
	or	al,ah
	mov	[VoiceControl+ebp],al
	stosb

SkipSaveThisSample:
	pop	ecx
	inc	ebp
	loop	SaveSampleInfoLoopen
	pop	ebp

NoFuckingSamples1:

	mov	edx,GUS_TempBuffPtr
	mov	ecx,edi
	sub	ecx,edx
	call	writefile

NoFuckingInstruments:
	ret
SaveInst	EndP

ENDIF


WriteFile:
	push	ecx ebx
	call	_WriteFile
	pushf
	mov	ebx,eax
	mov	ax,DiskFullErr
	cmp	ecx,ebx
	jnz	ErrorHandler
	popf
	mov	ax,WriteErr
	jc	ErrorHandler
	pop	ebx ecx
	ret

;*******************************************************************************
;			     Extreme packer v1.0
;*******************************************************************************
;
;InPuts:     al = Preprocessor
;	     ah = Packing method
;	    esi = Source buffer
;	    edi = Destination buffer
;	    ecx = Unpacked size
;
;OutPut:    ecx = Packed size
;
;Header:
;	     (0)  PackedSize (including header)
;	     (4)  Unpacked size
;	     (8)  Version
;	     (9)  Preprocessing
;				 0=None
;	    (10)  Packing method
;				 0=Stored
;				 1=Pure RLE
;
;*******************************************************************************
;PackInfo:
;
;Pure RLE:
;	     (0)  PackCharacter
;	     (1)  Character
;	     (2)  Length
;*******************************************************************************

PackingCharacter equ		 255
PackVersion	 equ		 0
UnpackedSize	 dd		 0
PackingJump	 dd		 StoreData
		 dd		 RLEpack
ExtremePacker	 Proc		 Near
	pushad

;--------------------------------------------------------- Header
	mov	ebp,edi
	mov	UnpackedSize,ecx

	mov	[edi+4],ecx
	mov	byte ptr [edi+8],PackVersion
	mov	[edi+9],ax
	add	edi,11
	movzx	ebx,ah
	jmp	[ebx*4+PackingJump]

;--------------------------------------------------------- Store
StoreData:
	jmp	QuitPacking

;--------------------------------------------------------- Pure RLE
RLEpack:
	mov	al,byte ptr [esi]
	cmp	al,PackingCharacter
	jz	OnlyPackChar
	mov	ecx,1
	mov	ebx,UnpackedSize
	dec	ebx
	jz	PackIT
PackSearch:
	cmp	ecx,254
	jz	PackIT
	cmp	al,[esi+ecx]
	jnz	PackIT
	inc	ecx
	dec	ebx
	jnz	PackSearch
PackIT:
	cmp	ecx,4
	jb	JustStoreIT
	mov	byte ptr [edi],PackingCharacter
	inc	edi
	stosb
	mov	byte ptr [edi],cl
	inc	edi
	add	esi,ecx
	sub	UnPackedSize,ecx
	jz	QuitPacking
	jmp	RLEPack

JustStoreIt:
	sub	UnPackedSize,ecx
	rep	movsb
	cmp	UnPackedSize,0
	jz	QuitPacking
	jmp	RLEPack

OnlyPackChar:
	inc	esi
	stosb
	stosb
	dec	UnpackedSize
	jz	QuitPacking
	jmp	RLEPack


;--------------------------------------------------------- Quit Packing
QuitPacking:
	sub	edi,ebp
	mov	UnpackedSize,edi
	mov	dword ptr [ebp],edi
	popad
	mov	ecx,UnpackedSize
	ret
ExtremePacker	Endp

GetSampOffset	proc	Near
	pushad
	movzx	eax,LastVoice		 ;Voice #
	movzx	ebx,CurrentSample
	cmp	bx,[CurrSample+eax*2]
	jnz	DontGetAddy
	call	GetCurrAdd
	mov	eax,[SampleOffsetStart+ebx*4]
	sub	CurrAdd,eax
DontGetAddy:
	popad
	ret
GetSampOffset	EndP

SetSampOffset	proc	Near
	pushad
	movzx	edi,LastVoice		 ;Voice #
	movzx	ebx,CurrentSample
	cmp	bx,[CurrSample+edi*2]
	jnz	DontSetAddy
	mov	eax,[SampleOffsetStart+ebx*4]
	call	Convert16Bit
	add	CurrAdd,eax
	call	SetCurrAdd
	sub	CurrAdd,eax
DontSetAddy:
	popad
	ret
SetSampOffset	EndP

CurrAdd dd	0


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;In:
;	ECX = Length to scan
;	ESI = Buffer to Scan in
;Out:
;	ECX = Bytes of value
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ScanNameBackWrds	Proc	Near
	push	esi
	add	esi,ecx
	dec	esi
ScanBackWrdsLoopen:
	cmp	byte ptr [esi],0
	jz	NextLetter
	cmp	byte ptr [esi],32
	jz	NextLetter
	pop	esi
	ret
NextLetter:
	dec	esi
	loop	ScanBackWrdsLoopen
	pop	esi
	Ret
ScanNameBackWrds	EndP




GetNoteFromSampleFreq:
	pushad
	jmp	GNFF

;in: eax=freq
;out: eax=note
GetNoteFromFreq:
	pushad
	xor	edx,edx
	shld	edx,eax,27
	shl	eax,27
	mov	ebx,4120283517
	div	ebx
GNFF:
	mov	ebx,eax
	cmp	ebx,0
	jnz	Olofsson
	mov	ebx,522
Olofsson:
	mov	eax,428*8363*16
	xor	edx,edx
	div	ebx
	cmp	eax,57
	jae	NoBiGDeal2
	mov	eax,57
NoBiGDeal2:

	xor	ecx,ecx
	xor	esi,esi
	mov	edx,10
OuterSearchLoop:
	push	edx

	xor	edi,edi
	mov	edx,12
InnerSearchLoop:
	mov	ebx,[pt_PeriodTable+edi*4]
	shr	ebx,cl
	cmp	eax,ebx
	jae	FoundNote
	inc	esi
	inc	edi
	dec	edx
	jnz	InnerSearchLoop

	inc	ecx
	pop	edx
	dec	edx
	jnz	OuterSearchLoop
	ret
FoundNote:
	pop	edx
	mov	[esp+28],esi
	popad
	ret

;--------------------------
;Calls: eax=SampleRate
;	ebx=SampleNr
;--------------------------
GetSampleRate	Proc	Near
	pushad
	call	SearchSampleRate
	jc	_retp
	movzx	eax,Word Ptr [edi+2]
	mov	[esp+28],eax
_retp:
	popad
	ret
GetSampleRate	EndP

PutSampleRate	Proc	Near
	pushad
	call	SearchSampleRate
	jc	_retp
PutSampleRate2:
	mov	Word Ptr [edi+2],ax
	popad
	ret
PutSampleRate	EndP

InsSampleRate	Proc	Near
	pushad
	call	SearchSampleRate		;check if sample already exists
	jnc	PutSampleRate2			;if so, don't insert
	push	ebx eax
	mov	eax,[AllocTable+1043*8+4]
	add	eax,4
	xor	ebx,ebx
	mov	ebp,1043
	call	MemAlloc
	pop	eax ebx
	jc	_retp
	mov	edx,[AllocTable+1043*8]
	add	edx,[AllocTable+1043*8+4]
	mov	[edx-4],bx
	mov	[edx-2],ax
	clc
	popad
	ret
InsSampleRate	EndP

DelSampleRate	Proc	Near
	pushad				;   d	 s
	call	SearchSampleRate	;xxxx xxxx xxxx
	jc	_retp
	mov	esi,edi
	add	esi,4
	mov	eax,[AllocTable+1043*8]
	sub	eax,esi
	neg	eax
	mov	ecx,[AllocTable+1043*8+4]
	sub	ecx,eax
	rep	movsb
	mov	eax,[AllocTable+1043*8+4]
	sub	eax,4
	xor	ebx,ebx
	mov	ebp,1043
	call	MemAlloc
	popad
	ret
DelSampleRate	EndP

;In: ebx=SampleNr
;out:edi=Offset in TBL
SearchSampleRate   Proc    Near
	mov	edi,[AllocTable+1043*8]
	mov	ecx,[AllocTable+1043*8+4]
	shr	ecx,2
	jecxz	SearchSRErr
SearchSRLoop:
	cmp	[edi],bx
	jz	FoundTheSR
	add	edi,4
	loop	SearchSRLoop
SearchSRErr:
	stc
	ret
FoundTheSR:
	clc
	ret
SearchSampleRate   EndP

SaveACS Proc	Near
	pushad
	pushf
	mov	StackSave,esp

	cmp	dword ptr [AllocTable+1036*8+4],0
	jz	NoSaveACS

	mov	edx,SaveName		;Create File
	call	_CreateFile
	mov	ax,CreateErr
	jc	ErrorHandler

	lea	edx,ACShdr		;Save ACShdr
	mov	ecx,7
	call	writefile

	mov	edx,[AllocTable+1036*8]
	mov	ecx,[AllocTable+1036*8+4]
	call	writefile

	call	_CloseFile
	mov	ax,CloseErr
	jc	ErrorHandler
NoSaveACS:
	popf
	popad
	ret
SaveACS EndP


SaveAPS Proc	Near
	pushad
	pushf
	mov	StackSave,esp

	movzx	ebp,CurrPatt2
	cmp	[AllocTable+ebp*8+4],0
	jz	NoSaveAPS

	mov	edx,SaveName		;Create File
	call	_CreateFile
	mov	ax,CreateErr
	jc	ErrorHandler

	lea	edx,APShdr		;Save APShdr
	mov	ecx,7
	call	writefile

	mov	edx,[AllocTable+ebp*8]
	mov	ecx,[AllocTable+ebp*8+4]
	call	writefile

	call	_CloseFile
	mov	ax,CloseErr
	jc	ErrorHandler
NoSaveAPS:
	popf
	popad
	ret
SaveAPS EndP

SaveASE Proc	Near
	pushad
	pushf
	mov	StackSave,esp

	movzx	ebp,CurrentSample

	mov	edx,SaveName		;Create File
	call	_CreateFile
	mov	ax,CreateErr
	jc	ErrorHandler

	lea	edx,ASEhdr		;Save ASEhdr
	mov	ecx,7
	call	writefile

	mov	edi,GUS_TempBuffPtr
	mov	word ptr [edi],ASEVersion
	add	edi,2

	mov	ecx,ebp
	sub	ecx,16
	mov	eax,22
	mul	ecx
	add	eax,SampleNamesPtr
	mov	esi,eax
	mov	ecx,22
	call	ScanNameBackWrds
	mov	al,cl
	stosb				;Store Sample name Length
	rep	movsb			;Store Sample Name

	mov	ebx,[SampleOffsetStart+ebp*4]
	mov	eax,[SampleOffsetEnd+ebp*4]
	sub	eax,ebx
	stosd
	jz	@@SkipSaveThisSample	;No Sample

	mov	eax,[LoopStart+ebp*4]
	sub	eax,ebx
	stosd
	mov	eax,[LoopEnd+ebp*4]
	sub	eax,ebx
	stosd
	push	ebx
	mov	ebx,ebp
	call	GetSampleRate                           ;THE SAMPLERATE
	pop	ebx
	stosw
	mov	al,[FineTunes+ebp]
	stosb
	mov	ax,[SampleRates+ebp*2]
	stosw
	mov	al,[RelativeNote+ebp]
	stosb
	mov	al,[Volumes+ebp]
	stosb
	mov	al,[VoiceControl+ebp]
	and	al,11111100b
	mov	ah,PackingByte
	bt	ax,2
	jnc	@@Skip
	xor	ah,ah		;=16 bits sample, No pack
@@Skip:
	or	al,ah
	mov	[VoiceControl+ebp],al
	stosb

@@SkipSaveThisSample:

	mov	edx,GUS_TempBuffPtr
	mov	ecx,edi
	sub	ecx,edx
	call	writefile

	push	ebp
	mov	ebp,1037
	call	MemDisalloc
	mov	ebp,1025
	call	MemDisalloc
	pop	ebp

	mov	eax,[SampleOffsetEnd+ebp*4]
	sub	eax,[SampleOffsetStart+ebp*4]
	mov	edx,eax
	jle	@@QuitASE
	mov	cl,[VoiceControl+ebp]
	bt	cx,2
	setc	cl
	shl	eax,cl
	mov	ecx,eax 	;ecx=bytes, eax=samples
	mov	eax,edx

	pushad
	mov	eax,ecx
	mov	ebp,1025
	xor	ebx,ebx
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	UndoBaff,eax

	mov	eax,ecx
	mov	ebp,1037
	xor	ebx,ebx
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	TempBufferPtr,eax
	popad

	push	ecx
	mov	ecx,eax
	mov	eax,[SampleOffsetStart+ebp*4]
	xor	edx,edx
	mov	ebx,TempBufferPtr
	mov	esi,ebx 		;packing
	call	GetSampleFromDRAM
	pop	ecx
	mov	edx,TempBufferPtr
	test	[VoiceControl+ebp],3
	jz	NoFuckinPack2
	mov	edx,UndoBaff
	mov	edi,edx

	call	packmethod1

NoFuckinPack2:
	call	WriteFile

	mov	ebp,1037
	call	MemDisalloc
	mov	ebp,1025
	call	MemDisalloc
	mov	UndoSampLength,0

@@QuitASE:
	call	_CloseFile
	mov	ax,CloseErr
	jc	ErrorHandler
	popf
	popad
	ret
SaveASE EndP

LoadACS:
	call	_filesize
	mov	ecx,eax
	mov	ax,SizeErr
	jc	ErrorHandler
	sub	ecx,7

	mov	eax,7
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler

	mov	eax,ecx
	xor	ebx,ebx
	mov	ebp,1036
	call	MemAlloc
	mov	[AllocTable+1036*8],eax
	mov	edx,eax
	call	readfile

	jmp	EndOfInstLoad

LoadAPS:
	call	_filesize
	mov	ecx,eax
	mov	ax,SizeErr
	jc	ErrorHandler
	sub	ecx,7

	mov	eax,7
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler

	mov	eax,ecx
	xor	ebx,ebx
	movzx	ebp,CurrPatt2
	call	MemAlloc
	mov	edx,eax
	call	readfile
	movzx	ebx,CurrPatt2
	call	PattInit
	jmp	EndOfInstLoad

LoadASE:
	cmp	Sample0,1
	jz	_ret2

	pushad
	call	KillSample2
	popad

	mov	eax,7
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler

	mov	edx,GUS_TempBuffPtr
	mov	ecx,3
	call	readfile
	cmp	word ptr [edx],ASEVersion
	mov	ax,BadVersionErr
	ja	ErrorHandler

	movzx	ebp,CurrentSample
	push	edx
	mov	ecx,ebp 		;Load Sample Name
	sub	ecx,16
	mov	eax,22
	mul	ecx
	add	eax,SampleNamesPtr
	pop	edx
	movzx	ecx,byte ptr [edx+2]
	mov	edx,eax
	call	ReadFile

	mov	edx,GUS_TempBuffPtr
	mov	ecx,20
	call	ReadFile

	mov	esi,edx
	lodsd
	cmp	eax,0
	jz	EndOfInstLoad

	mov	[SampleOffsetStart+ebp*4],0
	mov	[SampleOffsetEnd+ebp*4],eax

	lodsd
	mov	[LoopStart+ebp*4],eax
	lodsd
	mov	[LoopEnd+ebp*4],eax
	lodsw						;THE SAMPLERATE
	mov	ebx,ebp
	and	eax,0ffffh
	call	InsSampleRate
	lodsb
	mov	[FineTunes+ebp],al
	lodsw
	mov	[SampleRates+ebp*2],ax
	lodsb
	mov	[RelativeNote+ebp],al
	lodsb
	mov	[Volumes+ebp],al
	lodsb
	mov	[VoiceControl+ebp],al

	and	al,3
	mov	PackMeth,al

	mov	ecx,1
	movzx	ebx,CurrentSample
	call	LoadAISSampleData
	call	SampleToRAM
	call	justconvert
	jmp	EndOfInstLoad


LoadXP:
	call	_filesize
	mov	ecx,eax
	mov	ax,SizeErr
	jc	ErrorHandler

	xor	eax,eax
	xor	bl,bl
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler

	mov	ebp,1037
	xor	ebx,ebx
	mov	eax,ecx
	call	MemAlloc
	mov	esi,eax
	mov	edx,eax
	call	readfile
	movzx	ebp,CurrPatt2
	mov	Channels,32
	movzx	eax,word ptr [esi+2]
	mov	CurrPattLength,eax
	mov	Commands,2
	add	esi,4
	call	ParseXMPatt

	mov	ebp,1037
	call	MemDisAlloc
	jmp	EndOfInstLoad


AllowTBL	dd	SUB_NOS,SUB_GUS,SUB_SBP,SUB_SB16,SUB_SB,SUB_MAX

SUB_NOS		dd	A_NOS
SUB_GUS		dd	A_GUS
SUB_SBP		dd	A_SBP
SUB_SB16	dd	A_SB16
SUB_SB		dd	A_SB1,A_SB1,A_SB2
SUB_MAX		dd	A_MAX

;Sample,16Samp,StereoSamp,LineInSamp,SampleRate,SampleNote
A_NOS		dd	0,0,0,0,0,0
A_GUS		dd      1,0,1,0,44100,78
A_MAX		dd      1,1,1,1,48000,80
A_SBP		dd      1,0,0,1,45454,79
A_SB16		dd      1,1,1,1,45454,79
A_SB1		dd      1,0,0,0,11111,54
A_SB2		dd      1,0,0,0,15151,60

;     Freq
;LOG ------
;    C4Rate
;--------------*12 + 50 =  Note
;     LOG 2

CheckSoundCardAllowSample	Proc	Near
	push	eax ebx
	mov	eax,SoundCard
	mov	eax,[AllowTBL+eax*4]
	mov	ebx,SoundCardSub

	cmp	SoundCard,1                     ;Normal GUS
	jz	@@GUS
	cmp	SoundCard,5                     ;GUS MAX
	jnz	@@NoCodec
@@GUS:
	mov	ebx,0
@@NoCodec:

	mov	eax,[eax+ebx*4]
	mov	ebx,[eax+4*0]
	mov	Allow_Sample,bl
	mov	ebx,[eax+4*1]
	mov	Allow_16Samp,bl
	mov	ebx,[eax+4*2]
	mov	Allow_StereoSamp,bl
	mov	ebx,[eax+4*3]
	mov	Allow_LineInSamp,bl
	mov	ebx,[eax+4*4]
	mov	Max_SampleRate,ebx
	mov	ebx,[eax+4*5]
 	mov	Max_SampleNote,ebx

	cmp	SoundCard,1
	jz	@@AGUS
	cmp	SoundCard,5
	jnz	@@NoGUS
@@AGUS:
	cmp	SoundCard_DMA2,0
	jnz     @@NoGUS
	mov	Allow_Sample,0
@@NoGUS:

	pop	ebx eax
	ret
CheckSoundCardAllowSample	EndP







;/ABS\03843041650250802621049080490804908049080425500544
