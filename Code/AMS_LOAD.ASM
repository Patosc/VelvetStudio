


;-----------------
;LOADOFFSET in S3M and Determ. code...
;-----------------

;/ABS\00682032840380400677006770067700677006770300603216
;Calls: EAX = Type of file (Check DiskOp.asm, proc GetFileList) or auto....
Mods		db	'TDZ1TDZ2TDZ3M.K.M!K!FLT4FLT8OCTA'
Loadmod Proc Near
	Pushad
	pushf
	mov	StackSave,esp
	clc
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Check Format ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov	edx,ModNamePtr
	call	_OpenFileR
	mov	ax,OpenErr
	jc	ErrorHandler
	call	CheckFileFormat
	movzx	eax,TypeFile

IFE	PLAYER
	cmp	TypeFile,0
	jz	LoadSample
	cmp	TypeFile,03h
	jz	LoadDigiPlayer3
	cmp	TypeFile,04h
	jz	LoadIFFsample
	cmp	TypeFile,05h
	jz	LoadXIsample
	cmp	TypeFile,06h
	jz	LoadAIS
	cmp	TypeFile,07h
	jz	LoadWAV
	cmp	TypeFile,08h
	jz	LoadPAT
	cmp	TypeFile,40h
	jz	LoadACS
	cmp	TypeFile,41h
	jz	LoadAPS
	cmp	TypeFile,42h
	jz	LoadASE
	cmp	TypeFile,43h
	jz	LoadXP
ENDIF

IFE LITEVERSION
	cmp	TypeFile,0ah
	jz	OwnFormat
	cmp	TypeFile,0bh
	jz	LoadProtracker
	cmp	TypeFile,0ch
	jz	LoadScreamTracker3
	cmp	TypeFile,0dh
	jz	LoadScreamTracker2
	cmp	TypeFile,10h
	jz	LoadMTM
	cmp	TypeFile,11h
	jz	LoadULT
ENDIF
	cmp	TypeFile,0eh
	jz	NewAMSFormat
IFE LITEVERSION
	cmp	TypeFile,0fh
	jz	FastTracker2
ENDIF
	mov	ax,NoModuleErr
	jmp	ErrorHandler

PackMeth	db	0
LoadOffset	dd	0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;			      AMS 2.0-2.2 Loading
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

NewAMSFormat:
	call	ClearMod

	call	FixLoadOffset

	mov	edx,GUS_TempBuffPtr
	mov	ecx,8
	call	ReadFile

	movzx	ecx,byte ptr [edx+7]
	jcxz	NoFuckingModnamet
	lea	edx,SongName		 ;Load ModName
	call	ReadFile
NoFuckingModnamet:

	mov	edx,GUS_TempBuffPtr	;Load Version
	mov	ecx,2
	call	ReadFile
	mov	ax,word ptr [edx]
	mov	FormatVer,ax

IFE LITEVERSION
	cmp	ax,AMSVersion		;Check If correct Version
	mov	ax,BadVersionErr
	ja	ErrorHandler
ELSE
	cmp	ax,AMSVersion		;Check If correct Version
	mov	ax,BadVersionErr
	jnz	ErrorHandler
ENDIF
	mov	ecx,13
	cmp	FormatVer,0202h
	jae	NewerForm
	mov	ecx,8
NewerForm:
	mov	edx,GUS_TempBuffPtr	;Load Rest of Heather Locklear
	call	ReadFile

	mov	AISVer,0
	cmp	FormatVer,0200h
	jz	OldAIS2
	mov	AISVer,AISVersion
OldAIS2:
IFE LITEVERSION
	cmp	FormatVer,0202h
	jae	NewerForm2
	sub	edx,2
	mov	al,[edx+2]
	mov	Samples,al		;Get nr of instruments
	mov	ax,[edx+3]
	mov	Patterns,ax		;Get nr of patterns
	mov	ax,[edx+5]
	mov	Positions,ax		;Get nr of positions
	mov	ah,[edx+7]
	and	ax,0ff00h
;	mov	ModTempo,ax		;Get initial BPM
	mov	InitBPM,ax
;	mov	HertzAdder,ax
	mov	al,[edx+8]
	mov	ModSpeed,al		;Get initial Speed
	mov	InitSpeed,al
	movzx	ax,byte ptr [edx+9]	;Flags
	mov	TuneFlags,ax
	bt	ax,6
	setc	LinFreq
	jmp	ContLoadOld
NewerForm2:
ENDIF

	sub	edx,2
	mov	al,[edx+2]		;Get nr of instruments
	mov	Samples,al
	mov	ax,[edx+3]		;Get nr of patterns
	mov	Patterns,ax
	mov	ax,[edx+5]		;Get nr of positions
	mov	Positions,ax
	mov	ax,[edx+7]		;Get initial BPM
	mov	ModTempo,ax
	mov	InitBPM,ax
	mov	HertzAdder,ax
	mov	al,[edx+9]		;Get initial Speed
	mov	ModSpeed,al
	mov	InitSpeed,al		;Get Flags
	mov	al,[edx+10]		;Get Def Channels
	mov	al,[edx+11]		;Get Def Commands
	mov	al,[edx+12]		;Get Def Rows
	mov	ax,[edx+13]
	mov	TuneFlags,ax
	bt	ax,6
	setc	LinFreq

ContLoadOld:
	movzx	eax,Samples
	mov	ebx,30
	mul	ebx
	mov	ebp,1029		;Allocate Inst. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstNamesPtr,eax

	movzx	eax,Samples
	shl	eax,4
	mov	ebx,22
	mul	ebx
	mov	ebp,1028		;Allocate Samp. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampleNamesPtr,eax

	movzx	eax,Samples
	mov	ebx,716
	mul	ebx
	mov	ebp,1034		;Allocate Inst. Info
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstrumentInfo,eax

	movzx	eax,Positions
	shl	eax,1
	mov	ebp,1030		;Allocate Positions
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	PatternOrderPtr,eax


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ;Load Instruments
	mov	ebp,1
	movzx	ecx,Samples
	jecxz	NoFuckingInstrumentsLoad
LoadInstrumentLoopen:
	call	LoadAISInInstrument
	inc	ebp
	loop	LoadInstrumentLoopen
NoFuckingInstrumentsLoad:

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Load Text

	mov	edx,GUS_TempBuffPtr
	mov	ecx,1
	call	ReadFile
	movzx	ecx,byte ptr [edx]
	jecxz	NoComposerField 		;Load Composer
	lea	edx,Composer
	call	ReadFile
NoComposerField:

	mov	edi,ChannelNamesPtr
	mov	ecx,32
	mov	ShitLength,11
	call	NameLoop
	mov	DescLength,0

IFE LITEVERSION
IFE SPECIALVERSION
	cmp	FormatVer,0201h
	jb	OlderDescFormat
ENDIF
ENDIF

	mov	ecx,4
	lea	edx,DescLength
	call	ReadFile

	mov	eax,DescLength		;Packed Size
	mov	ecx,eax
	sub	ecx,4
	mov	ebp,1037
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	esi,eax
	mov	edx,DescLength
	mov	[eax],edx
	add	eax,4
	mov	edx,eax
	call	ReadFile

	mov	eax,[esi+4]		;Desc Length
IFE	PLAYER
	mov	[DescTable+12*4],eax	;Len
ENDIF
	mov	ebp,1027
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
IFE	PLAYER
	mov	[DescTable+11*4],eax	;Ptr
ENDIF
	mov	edi,eax
	call	ExtremeUnPacker
	jmp	DescFinish1

IFE LITEVERSION
OlderDescFormat:
	mov	ecx,2
	mov	edx,GUS_TempBuffPtr
	call	ReadFile

	movzx	ecx,word ptr [edx]
	mov	eax,ecx
	cmp	eax,0
	jnz	DescNotZero2
	mov	eax,74
DescNotZero2:
	push	eax
	mov	edx,GUS_TempBuffptr
	call	ReadFile
	pop	eax

	call	ScanOldDescLength
IFE	PLAYER
	mov	[DescTable+12*4],eax	;Len
ENDIF

	mov	ebp,1027
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
IFE	PLAYER
	mov	[DescTable+11*4],eax	;Ptr
ENDIF
	mov	esi,GUS_TempBuffPtr
	mov	edi,eax
	call	UnPackOld
ENDIF
DescFinish1:
	mov	ebp,1037
	call	MemDisAlloc

	mov	edx,PatternOrderPtr	;PatternOrder
	movzx	ecx,Positions
	shl	ecx,1
	call	ReadFile

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Load Patterns
	xor	ebp,ebp
	movzx	ecx,Patterns
LoadPatternLoopen20:
	push	ecx
	push	edi
	push	ebp

	lea	edx,PatternSize 	;Load Patterns
	mov	ecx,4
	call	ReadFile

	mov	edx,GUS_TempBuffPtr	;Load a Pattern
	mov	ecx,PatternSize
	call	ReadFile
	mov	esi,GUS_TempBuffPtr

	mov	al,[esi+1]
	mov	ChanCMD,al
	mov	Channels,al
	and	Channels,31		;Remove Nr Of Commands
	inc	Channels
	shr	al,5
	mov	Commands,al

	movzx	eax,Commands		;Get width
	shl	eax,1
	add	eax,2
	movzx	ecx,Channels
	mul	ecx
	movzx	ecx,byte ptr [esi]	;Get Length
	inc	ecx
	mul	ecx

	add	eax,12			;Allocate one pattern
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	edi,eax
	call	GetRowSize

	jmp	Format20
EndPatternLoop20:
	pop	ebp
	pop	edi
	pop	ecx
	inc	ebp
	loop	LoadPatternLoopen20

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Load Sample Data

	movzx	ecx,Samples
	jecxz	QuitLoad
	shl	ecx,4
	mov	ebx,16
	call	LoadAISSampleData
	jmp	QuitLoad

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Format 2.0
Format20:
	lodsb				;Dummy Pattern Len.
	lodsb				;Dummy ChanCMD
	lodsb				;Load PatternName length

	push	edi ecx
	movzx	ecx,al
	rep	movsb			;Move PattName
	pop	ecx edi
	add	edi,10

	mov	al,cl
	dec	al
	stosb				;Store PatternLength
	mov	al,ChanCMD
	stosb				;Store Channels+CMD

RowLoopen20:
	push	ecx
	push	edi

GetNextChunk20:
	push	edi
	lodsb
	mov	InfoByte12,al
	cmp	al,-1			;Empty row
	jz	NoCommand20

	and	eax,1fh
	mov	ebx,RowSize
	mul	ebx
	add	edi,eax 		;Got channel

	test	InfoByte12,01000000b
	jz	Construct20
	add	edi,2
	jmp	Construct20_2
Construct20:
	lodsb				;Load period
	mov	cl,al
	and	al,7fh

	cmp	FormatVer,0200h
	jnz	NewAMS
	cmp	al,1
	jbe	NewAMS
	add	al,14
NewAMS:
	stosb				;Store Period

	movsb				;Sample Nr

	test	cl,80h
	jz	NoCommand20
Construct20_2:
GetNexztCmd20:
	lodsb				;Command Nr
	mov	cl,al
	and	al,3fh
	test	cl,40h
	jz	NoSpecialVolume20
	mov	ah,0ch
	shl	al,1
	jmp	SpecialVolume20
NoSpecialVolume20:
	mov	ah,al
	lodsb
SpecialVolume20:
	xchg	al,ah
	stosb
	mov	al,ah
	stosb
	test	cl,80h
	jz	NoCommand20
	jmp	GetNexztCmd20

NoCommand20:
	pop	edi
	test	InfoByte12,80h
	jz	GetNextChunk20

	pop	edi
	pop	ecx
	add	edi,ChRowSize
	loop	RowLoopen20
	jmp	EndPatternLoop20

LoadAISInInstrument	Proc	Near
	push	ecx

	mov	edx,GUS_TempBuffPtr	;Load Inst. name length
	mov	ecx,1
	call	ReadFile
	movzx	ecx,byte ptr [edx]	;Length
	mov	eax,30
	mul	ebp
	sub	eax,30
	mov	edx,eax
	add	edx,InstNamesPtr
	pushad
	mov	edi,edx
	mov	ecx,30
	xor	al,al
	rep	stosb
	popad
	call	ReadFile

	mov	edx,GUS_TempBuffPtr
	mov	ecx,1
	call	ReadFile

	movzx	ecx,byte ptr [edx]
	jecxz	NoFuckingSamples1Load	;No samples in Inst

	push	ecx

	GetOffset ebp,edx,ENV_SplitKBD
	mov	ecx,96
	cmp	AISVer,0
	jz	OldAIS
	mov	ecx,120
OldAIS:
	call	ReadFile

;---------
	mov	edx,GUS_TempBuffPtr
	mov	esi,edx
	mov	ecx,5
	call	ReadFile

	lodsb				;Load Volume Speed
	GetOffset ebp,edx,ENV_VolSpeed
	mov	[edx],al
	lodsb				;Load Volume sustain point
	GetOffset ebp,edx,ENV_VolSustPoint
	mov	[edx],al
	lodsb				;Load Volume loop start point
	GetOffset ebp,edx,ENV_VolStart
	mov	[edx],al
	lodsb				;Load Volume loop end point
	GetOffset ebp,edx,ENV_VolEnd
	mov	[edx],al
	lodsb				;Load nr of points
	GetOffset ebp,edx,ENV_NrVolPoints
	movzx	ecx,al
	lea	ecx,[ecx+ecx*2]
	dec	al
	mov	[edx],al

	GetOffset ebp,edx,ENV_VolPoints
	call	ReadFile
;---------
	mov	edx,GUS_TempBuffPtr
	mov	esi,edx
	mov	ecx,5
	call	ReadFile

	lodsb				;Load Pan Speed
	GetOffset ebp,edx,ENV_PanSpeed
	mov	[edx],al
	lodsb				;Load Pan sustain point
	GetOffset ebp,edx,ENV_PanSustPoint
	mov	[edx],al
	lodsb				;Load Pan loop start point
	GetOffset ebp,edx,ENV_PanStart
	mov	[edx],al
	lodsb				;Load Pan loop end point
	GetOffset ebp,edx,ENV_PanEnd
	mov	[edx],al
	lodsb				;Load nr of points
	GetOffset ebp,edx,ENV_NrPanPoints
	movzx	ecx,al
	lea	ecx,[ecx+ecx*2]
	dec	al
	mov	[edx],al

	GetOffset ebp,edx,ENV_PanPoints
	call	ReadFile
;---------
	mov	edx,GUS_TempBuffPtr
	mov	esi,edx
	mov	ecx,5
	call	ReadFile

	lodsb				;Load Vib Speed
	GetOffset ebp,edx,ENV_VibSpeed
	mov	[edx],al
	lodsb				;Load Vib sustain point
	GetOffset ebp,edx,ENV_VibSustPoint
	mov	[edx],al
	lodsb				;Load Vib loop start point
	GetOffset ebp,edx,ENV_VibStart
	mov	[edx],al
	lodsb				;Load Vib loop end point
	GetOffset ebp,edx,ENV_VibEnd
	mov	[edx],al
	lodsb				;Load nr of points
	GetOffset ebp,edx,ENV_NrVibPoints
	movzx	ecx,al
	lea	ecx,[ecx+ecx*2]
	dec	al
	mov	[edx],al

	GetOffset ebp,edx,ENV_VibPoints
	call	ReadFile
;---------
	mov	edx,GUS_TempBuffPtr
	mov	esi,edx
	mov	ecx,5
	call	ReadFile

	lodsb
	GetOffset ebp,edx,ENV_Shadow	;Load Shadow Info
	mov	[edx],al

	lodsw
	GetOffset ebp,edx,ENV_VolFade	;Load Vol fade
	mov	[edx],ax
	lodsw
	GetOffset ebp,edx,ENV_Flags	;Load flags
	mov	[edx],ax

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Load Samples in Inst.
	pop	ecx

	push	ebp
	shl	ebp,4
LoadSampleInfoLoopen:
	push	ecx

	mov	edx,GUS_TempBuffPtr
	mov	ecx,1
	call	ReadFile

	push	edx
	mov	ecx,ebp 		;Load Sample Name
	sub	ecx,16
	mov	eax,22
	mul	ecx
	add	eax,SampleNamesPtr
	pop	edx
	movzx	ecx,byte ptr [edx]
	mov	edx,eax
;	pushad
;	mov	edi,eax
;	mov	ecx,22
;	xor	al,al
;	rep	stosb
;	popad
	call	ReadFile

	mov	edx,GUS_TempBuffPtr
	mov	ecx,20
	call	ReadFile

	mov	esi,edx
	lodsd
	cmp	eax,0
	jz	SkipLoadThisSample

	mov	[SampleOffsetStart+ebp*4],0
	mov	[SampleOffsetEnd+ebp*4],eax
	lodsd
	mov	[LoopStart+ebp*4],eax
	lodsd
	mov	[LoopEnd+ebp*4],eax
	lodsw						;THE SAMPLERATE
	mov	ebx,ebp
	call	InsSampleRate
	lodsb
	mov	[FineTunes+ebp],al
	lodsw
;	 cmp	 AISVer,0
;	 jnz	 NewAIS1
;	 shl	 ax,2
;NewAIS1:
	mov	[SampleRates+ebp*2],ax
	lodsb
	mov	[RelativeNote+ebp],al
	lodsb
	mov	[Volumes+ebp],al
	lodsb
	mov	[VoiceControl+ebp],al

;	and	al,3
;	mov	PackMeth,al

SkipLoadThisSample:
	pop	ecx
	inc	ebp
	loop	LoadSampleInfoLoopen
	pop	ebp

NoFuckingSamples1Load:

	pop	ecx
	ret
LoadAISInInstrument	EndP

AShadow db	0
LoadAISSampleData	Proc	Near
	mov	AShadow,0
GUS_Samplenghts4:
	mov	CurrentSample,bx
	push	ecx

	cmp	FormatVer,202h
	jb	@@LoadAIS		;Skip This
	test	bx,0fh			;Inst?
	jnz	@@LoadAIS
IFE	PLAYER
	cmp	CurrentWildCard,54	;Load Shadow Sample data if an AIS.
	jz	@@LoadAIS
ENDIF
	mov	eax,ebx
	shr	eax,4
	GetOffset eax,eax,ENV_Shadow	;A Shadow
	cmp	byte ptr [eax],0
	setnz	AShadow

@@LoadAIS:
	cmp	AShadow,1		;It's a shadow inst.
	jz	GUS_NoSample4

	mov	eax,[SampleOffsetEnd+ebx*4]
	cmp	eax,0
	jz	GUS_NoSample4
	mov	ecx,eax
;--..--
	push	ecx
	mov	cl,[VoiceControl+ebx]
	bt	cx,2
	setc	cl
	shl	eax,cl
	pop	ecx
;--..--
	xchg	ecx,eax 	;ecx=bytes, eax=samples

	push	ebx eax
	mov	eax,ecx
	mov	ebp,1024
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampMainOffset,eax
	pop	eax ebx

	test	[VoiceControl+ebx],3
	jnz	UnpackData

	push	eax
	mov	edx,SampMainOffset
	call	ReadFile
	pop	eax

	push	eax
	call	AllocSample
;	mov	ax,GUSDramErr
;	jc	ErrorHandler
	jnc	NoAISErr
	call	FixAllocSampleError
NoAISErr:
	pop	eax

	mov	ecx,eax
	mov	edx,0
	call	MoveSample
	jmp	UnpackedData

UnpackData:
	push	ebx
	mov	eax,ecx
	mov	ebp,1025
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	UndoBaff,eax
	pop	ebx

	mov	ecx,9
	mov	edx,UndoBaff
	call	ReadFile

	mov	edx,UndoBaff
	mov	ecx,[edx+4]		;Packed Size
	add	edx,9
	call	ReadFile
	mov	eax,UndoBaff
	mov	eax,[eax]		;UnPacked Size

;--..--
	push	ecx
	mov	cl,[VoiceControl+ebx]
	bt	cx,2
	setc	cl
	shr	eax,cl			;ecx=bytes, eax=samples
	pop	ecx
;--..--
	push	eax
	call	AllocSample
;	mov	ax,GUSDramErr
;	jc	ErrorHandler
	jnc	NoAISErr1
	call	FixAllocSampleError
NoAISErr1:
	pop	eax

	mov	edx,0
	mov	esi,UndoBaff
	mov	edi,SampMainOffset

;!!!!!!!!!!

;	mov	dbyte,ebx
;	call	dbug
;	call	waitkey
;	cmp	ebx,352
;	jz	prutt


;!!!!!!!!!!
	call	UnPackMethod1


	mov	ecx,eax
	call	MoveSample
prutt:
	mov	ebp,1025
	call	MemDisAlloc
IFE	PLAYER
	mov	UndoSampLength,0
ENDIF
UnpackedData:
	mov	ebp,1024
	call	MemDisAlloc

GUS_NoSample4:
	pop	ecx
	inc	ebx
	loop	GUS_Samplenghts4
	ret
LoadAISSampleData	EndP





ChanCMD 	db	0
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;			      AMS pre 2.0 Loading
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IFE LITEVERSION
OwnFormat:
	mov	LinFreq,0

	call	ClearMod

	call	FixLoadOffset

	lea	edx,Header		;Load Header
	mov	ecx,18
	call	ReadFile

	cmp	FormatVer,AMSVersion	;Check If correct Version
	mov	ax,BadVersionErr
	ja	ErrorHandler

	mov	al,Channels
	mov	ChanCMD,al
	and	Channels,31		;Remove Nr Of Commands
	inc	Channels
	shr	al,5
	mov	Commands,al
	call	GetRowSize

	mov	CurrPattLength,64
	movzx	ecx,Patterns		;Allocate all patterns
	call	GetPatternSize
	xor	ebp,ebp
AllocateThePatterns:
	mov	eax,PatternSize2
	add	eax,12
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	inc	ebp
	loop	AllocateThePatterns

	movzx	eax,Samples
	mov	ebx,30
	mul	ebx
	mov	ebp,1029		;Allocate Inst. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstNamesPtr,eax

	movzx	eax,Samples
	shl	eax,4
	mov	ebx,22
	mul	ebx
	mov	ebp,1028		;Allocate Samp. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampleNamesPtr,eax

	movzx	eax,Samples
	mov	ebx,716
	mul	ebx
	mov	ebp,1034		;Allocate Inst. Info
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstrumentInfo,eax

	movzx	eax,Positions
	shl	eax,1
	mov	ebp,1030		;Allocate Positions
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	PatternOrderPtr,eax

	movzx	ecx,Samples
	jcxz	NoMoreSample
	mov	edi,16
LoadSampleInfo:
	push	ecx
	lea	edx,TmpSampInfo
	mov	ecx,17
	call	ReadFile

	lea	esi,TmpSampInfo
	lodsd
	mov	[SampleOffsetEnd+edi*4],eax
	lodsd
	mov	[LoopStart+edi*4],eax
	lodsd
	mov	[LoopEnd+edi*4],eax
	lodsb
	mov	[FineTunes+edi],al
	lodsw
	mov	[SampleRates+edi*2],ax
	lodsb
	mov	[Volumes+edi],al
	lodsb
	mov	PackMeth,al
	and	PackMeth,3
	mov	[VoiceControl+edi],al
	mov	eax,[LoopEnd+edi*4]
	sub	eax,[LoopStart+edi*4]
	push	cx
	setnz	cl
	shl	cl,3
	and	[VoiceControl+edi],11110111b
	or	[VoiceControl+edi],cl
	pop	cx
	add	edi,16
	pop	ecx
	loop	LoadSampleInfo
NoMoreSample:

	lea	edx,SongName		 ;ModName Length
	mov	ecx,1
	call	ReadFile

	lea	edx,SongName		 ;ModName

	movzx	ecx,byte ptr SongName
	jcxz	NoFuckingModname
	call	ReadFile
NoFuckingModname:

	mov	edi,InstNamesPtr
	movzx	ecx,Samples
	jecxz	NoFuckingSamples
	mov	ShitLength,30
	call	NameLoop
NoFuckingSamples:
	mov	edi,ChannelNamesPtr
	movzx	ecx,Channels
	mov	ShitLength,11
	call	NameLoop

	xor	ebp,ebp 		;Load PatternNames
	movzx	ecx,Patterns
PNameLoop:
	push	ecx
	mov	edi,[AllocTable+ebp*8]
	lea	edx,TmpSampInfo
	mov	ecx,1
	call	ReadFile

	movzx	ecx,Byte ptr [edx]
	jcxz	NoPName
	mov	edx,edi 		 ;Name
	call	ReadFile
NoPName:
	pop	ecx
	inc	ebp
	loop	PNameLoop

	jmp	NoCall
ENDIF

NameLoop	Proc	Near
	push	ecx
	mov	edx,edi 		 ;Name Length
	mov	ecx,1
	call	ReadFile

	movzx	ecx,Byte ptr [edi]
	jcxz	NoName
	mov	edx,edi 		 ;Name

	movzx	ecx,Byte ptr [edi]
	call	ReadFile
NoName:
	add	edi,ShitLength
	pop	ecx
	loop	NameLoop
	ret
NameLoop	EndP

IFE LITEVERSION

FixLoChars	Proc	Near
	cmp	byte ptr [edi],32
	jae	Gurre
	cmp	byte ptr [edi],0
	jnz	Garre
	mov	byte ptr [edi],20h
	jmp	Gurre
Garre:
	add	byte ptr [edi],128
Gurre:
	inc	edi
	loop	FixLoChars
	ret
FixLoChars	EndP


NoCall:
	mov	ecx,2
	mov	edx,GUS_TempBuffPtr
	call	ReadFile

	movzx	ecx,word ptr [edx]
	mov	eax,ecx
	cmp	eax,0
	jnz	DescNotZero
	mov	eax,74
DescNotZero:
	push	eax
	mov	edx,GUS_TempBuffptr
	call	ReadFile
	pop	eax

	call	ScanOldDescLength
IFE	PLAYER
	mov	[DescTable+12*4],eax	;Len
ENDIF

	mov	ebp,1027
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
IFE	PLAYER
	mov	[DescTable+11*4],eax	;Ptr
ENDIF
	mov	esi,GUS_TempBuffPtr
	mov	edi,eax
	call	UnPackOld


	mov	edx,PatternOrderPtr	;PatternOrder
	movzx	ecx,Positions
	shl	ecx,1
	call	ReadFile

	xor	ebp,ebp
	movzx	ecx,Patterns
LoadPatternLoopen:
	push	ecx
	push	edi
	push	ebp
	mov	edi,[AllocTable+ebp*8]
	mov	byte ptr [edi+10],63	;Pattern Length
	mov	al,ChanCMD
	mov	byte ptr [edi+11],al	;Channels+Commands
	add	edi,12

	lea	edx,PatternSize 	;Load Patterns
	mov	ecx,4
	call	ReadFile

	mov	edx,GUS_TempBuffPtr	;Load a Pattern
	mov	ecx,PatternSize
	call	ReadFile

	mov	esi,GUS_TempBuffPtr
	cmp	FormatVer,0120h
	jb	Format10and11
	jmp	Format12and13
EndPatternLoop:
	pop	ebp
	pop	edi
	pop	ecx
	inc	ebp
	loop	LoadPatternLoopen

	jmp	LoadAllSamples

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Format 1.0 and 1.1
Format10and11:

	movzx	ecx,Channels
ChannelLoopen:
	push	ecx
	push	edi

	mov	ecx,64
RowLoopen:
	push	ecx
	push	edi

	cmp	NrOfPackedRows,0
	jz	NoPacking
	dec	NrOfPackedRows
	jmp	NoCommands
NoPacking:				;Unpack
	lodsb				;Period
	cmp	FormatVer,0110h
	jz	Version11

Version10:
	cmp	al,0ah
	jnz	NoRowPack
	lodsb
	mov	NrOfPackedRows,al
	jmp	NoCommands

Version11:
	test	al,80h
	jz	NoRowPack
	and	al,7fh
	mov	NrOfPackedRows,al
	jmp	NoCommands

NoRowPack:
	cmp	FormatVer,0100h
	jz	Version10_1

	cmp	al,0
	jz	SkipLo1
	add	al,14
SkipLo1:
	stosb				;Period
	movsb				;Samp
	lodsb				;Command Nr
	cmp	al,0
	jz	NoCommands
	mov	cl,al
	shr	cl,6
	and	al,3fh
	stosb
	movsb				;CommandByte1
	cmp	cl,1
	jz	NoCommands
GetNexztCmd:
	lodsb
	mov	ch,al
	lodsb
	mov	ah,al
	mov	al,ch
	and	al,3fh
	stosb
	mov	al,ah
	stosb
	test	ch,40h
	jz	NoCommands
	jmp	GetNexztCmd

Version10_1:
	mov	bl,al
	and	al,7fh			;Remove Nr of Commands
	jz	SkipLo2
	add	al,14
SkipLo2:
	stosb				;Period
	shr	bl,7
	shl	bl,2
	movsb				;Samp
	lodsb				;Command Nr
	mov	ah,al
	and	al,3fh
	stosb
	shr	ah,6
	or	bl,ah
	cmp	bl,0
	jz	NoCommands
	movsb				;CommandByte1
	dec	bl
	movzx	ecx,bl
	rep	movsw			;Rest Of CommandBytes
NoCommands:
	pop	edi
	pop	ecx
	add	edi,ChRowSize
	loop	RowLoopen

	pop	edi
	pop	ecx
	add	edi,RowSize
	loop	ChannelLoopen
	jmp	EndPatternLoop
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Format 1.2 and 1.3
ENDIF

InfoByte12	db	0
LSConvert	db	0

IFE LITEVERSION
Format12and13:
	mov	ecx,64
RowLoopen12:
	push	ecx
	push	edi

GetNextChunk:
	push	edi
	lodsb
	mov	InfoByte12,al
	cmp	al,-1			;Empty row
	jz	NoCommand12
	cmp	FormatVer,0120h
	jz	Format_12

	and	eax,1fh
	mov	ebx,RowSize
	mul	ebx
	add	edi,eax 		;Got channel

	test	InfoByte12,01000000b
	jz	Construct
	add	edi,2
	jmp	Construct2

Format_12:
	and	al,7fh
	movzx	eax,al
	mov	ebx,RowSize
	mul	ebx
	add	edi,eax 		;Got channel

Construct:
	lodsb				;Load period
	mov	cl,al
	and	al,7fh
	jz	SkipLo3
	add	al,14
SkipLo3:
	stosb				;Store Period

	movsb				;Sample Nr

	test	cl,80h
	jz	NoCommand12
Construct2:
GetNexztCmd12:
	lodsb				;Command Nr
	mov	cl,al
	and	al,3fh
	test	cl,40h
	jz	NoSpecialVolume
	mov	ah,0ch
	shl	al,1
	jmp	SpecialVolume
NoSpecialVolume:
	mov	ah,al
	lodsb
SpecialVolume:
	xchg	al,ah
	stosb
	mov	al,ah
	stosb
	test	cl,80h
	jz	NoCommand12
	jmp	GetNexztCmd12

NoCommand12:
	pop	edi
	test	InfoByte12,80h
	jz	GetNextChunk

	pop	edi
	pop	ecx
	add	edi,ChRowSize
	loop	RowLoopen12
	jmp	EndPatternLoop
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Load Samples
LoadAllSamples:
	mov	LSConvert,0
	cmp	PackMeth,0
	jz	LoadTheSamples

	movzx	ecx,Samples
	jecxz	QuitLoad
	mov	ebx,16
	mov	CurrentInstrument,0
GUS_Samplenghts3:
	inc	CurrentInstrument
	call	SetInitialEnvelopes
	mov	CurrentSample,bx
	push	ecx
	mov	eax,[SampleOffsetEnd+ebx*4]
	cmp	eax,0
	jz	GUS_NoSample3

	push	ebx
	push	eax
	mov	ebp,1025
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	UndoBaff,eax
	pop	eax

	mov	ebp,1024
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampMainOffset,eax
	pop	ebx

	mov	ecx,9
	mov	edx,UndoBaff
	call	ReadFile

	mov	edx,UndoBaff
	mov	ecx,[edx+4]
	add	edx,9
	call	ReadFile
	mov	ecx,UndoBaff
	mov	eax,[ecx]
	call	AllocSample
;	mov	ax,GUSDramErr
;	jc	ErrorHandler
	jnc	NoALLErr
	call	FixAllocSampleError
NoALLErr:
	mov	edx,0
	mov	esi,UndoBaff
	mov	edi,SampMainOffset
	call	UnPackMethod1

	call	MoveSample

	mov	ebp,1024
	call	MemDisAlloc
	mov	ebp,1025
	call	MemDisAlloc
IFE	PLAYER
	mov	UndoSampLength,0
ENDIF

GUS_NoSample3:
	pop	ecx
	add	ebx,16
	loop	GUS_Samplenghts3

ENDIF

QuitLoad:
	call	_CloseFile
	mov	ax,CloseErr
	jc	ErrorHandler

	call	WaitDiskReady

	mov	CurrRow,0
	mov	CurrPosition,0

	movzx	ebx,CurrPosition	;init a pattern+row
	shl	ebx,1
	add	ebx,PatternOrderPtr
	movzx	ebx,word ptr [ebx]
	mov	eax,[AllocTable+ebx*8]
	add	eax,12
	mov	PatternOffset,eax
	mov	PatternStart,eax

	call	UpdateShadows
	popf
	popad
	clc
	Ret
Loadmod Endp


IFE LITEVERSION
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;				Load Protracker
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LoadProTracker:
	mov	LinFreq,0
	call	ClearMod
	mov	eax,GRR_PatternSize
	mov	PatternSize,eax
	mov	al,GRR_Channels
	mov	Channels,al
	dec	al
	mov	ChanCMD,al
	or	ChanCMD,00100000b
	mov	Commands,1
	call	GetRowSize

	call	FixLoadOffset
	mov	edx,GUS_TempBuffPtr	;Load Header
	mov	ecx,1084
	call	ReadFile
	mov	FormatVer,AMSVersion	;Store Version
	mov	esi,GUS_TempBuffPtr

	mov	MIDIChannels,0	;No MIDI in a .MOD file

	mov	Samples,0
FixNrOfSamples: 		;Count Nr of used samples
	mov	esi,GUS_TempBuffPtr
	add	esi,42
	mov	ecx,31
	xor	edx,edx
FixNOSLoop:
	cmp	word ptr [esi],0
	jz	SEmpty
	cmp	word ptr [esi],0100h
	jz	SEmpty
	inc	Samples
SEmpty:
	add	esi,30
	loop	FixNOSLoop
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Samples
	mov	esi,GUS_TempBuffPtr
	add	esi,20
	mov	ecx,31		;SampleLoop
	xor	eax,eax
	mov	ebp,16
SampLoop:
	mov	ax,[esi+22]	;Length of sample
	xchg	ah,al
	shl	ax,1
	cmp	ax,2
	jbe	NoSample
	mov	[SampleOffsetEnd+ebp*4],eax ;Store End of sample
	mov	ax,[esi+26]			;Repeat Point
	xchg	ah,al
	shl	ax,1
	mov	[LoopStart+ebp*4],eax	    ;Store Repeat Start
	mov	bx,[esi+28]			;Repeat Length
	xchg	bh,bl
	shl	bx,1
	cmp	bx,2
	ja	NotZero2
	mov	bx,0
NotZero2:
	add	ax,bx		;Add with Rep Point to get End
	cmp	eax,[SampleOffsetEnd+ebp*4]
	jbe	NoBelowed
	mov	eax,[SampleOffsetEnd+ebp*4]
NoBelowed:
	mov	[LoopEnd+ebp*4],eax ;Store Repeat End
	mov	al,[esi+24]		;FineTune
	and	al,0fh			;Clear PanPot for safety
	mov	[FineTunes+ebp],al	;Store FineTune
	mov	[SampleRates+ebp*2],8363;SampleRate
	mov	al,[esi+25]		;Volume
	shl	al,1
	cmp	al,128
	jb	NoDec
	dec	al			;Only values below 128 are allowed
NoDec:
	mov	[Volumes+ebp],al	;Store Volume
	mov	eax,[LoopEnd+ebp*4]
	sub	eax,[LoopStart+ebp*4]
	push	cx
	setnz	cl
	shl	cl,3
	and	[VoiceControl+ebp],11110111b
	or	[VoiceControl+ebp],cl
	pop	cx
	jmp	ASample
NoSample:
	mov	bx,31		;Check if empty SampleSpace
	sub	bl,Samples
	cmp	bx,cx
	jz	NoMoreSamples
	inc	Samples 	;Empty sample
ASample:
	add	esi,30
	add	ebp,16
	loop	SampLoop

NoMoreSamples:
	cmp	LoadAllPTSamples,0
	jz	NoLoadalla
	mov	Samples,31
NoLoadalla:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Names
	mov	eax,20		;Max 20 bytes
	mov	esi,GUS_TempBuffPtr
	call	ScanLength	;Get length of name
	lea	edi,SongName
	call	CopyString	;Store Name

	movzx	ecx,Samples
	jecxz	NoFuckingSamples3

	movzx	eax,Samples
	mov	ebx,30
	mul	ebx
	mov	ebp,1029		;Allocate Inst. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstNamesPtr,eax

	movzx	eax,Samples
	shl	eax,4
	mov	ebx,22
	mul	ebx
	mov	ebp,1028		;Allocate Samp. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampleNamesPtr,eax

	movzx	eax,Samples
	mov	ebx,716
	mul	ebx
	mov	ebp,1034		;Allocate Inst. Info
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstrumentInfo,eax

	mov	esi,GUS_TempBuffPtr
	add	esi,20
	mov	edi,InstNamesPtr
SampNameLoop:
	mov	eax,22		;Copy 22 bytes
	call	ScanLength	;Get Length of name
	call	CopyString	;Store Name
	add	esi,30
	add	edi,30
	loop	SampNameLoop

NoFuckingSamples3:
	mov	esi,GUS_TempBuffPtr	;Check for Highest PatternNumber
	add	esi,952
	mov	ecx,128
	xor	eax,eax
PattNrLoop:
	cmp	byte ptr [esi],al
	jbe	NoChange
	mov	al,byte ptr [esi]
NoChange:
	inc	esi
	loop	PattNrLoop
	inc	al
	movzx	ax,al
	mov	Patterns,ax

	mov	CurrPattLength,64
	movzx	ecx,ax			;Allocate all patterns
	call	GetPatternSize
	xor	ebp,ebp
AllocateThePatterns2:
	mov	eax,PatternSize2
	add	eax,12
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	inc	ebp
	loop	AllocateThePatterns2


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PatternOrder

	mov	esi,GUS_TempBuffPtr	;Nr Of Positions
	add	esi,950
	movzx	ax,byte ptr [esi]
	mov	Positions,ax
	movzx	ecx,ax			;Patterns

	mov	eax,ecx
	shl	eax,1
	mov	ebp,1030		;Allocate Positions
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	PatternOrderPtr,eax

	mov	edi,PatternOrderPtr	;PatternOrder
	add	esi,2
	xor	eax,eax
PatternLoop:
	lodsb
	stosw
	loop	PatternLoop

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Patterns
	movzx	ecx,Patterns
	xor	ebp,ebp
ConvertPatternLoopen:
	push	ecx
	push	ebp
	mov	edi,[AllocTable+ebp*8]
	mov	byte ptr [edi+10],63	;Pattern Length
	mov	al,ChanCMD
	mov	byte ptr [edi+11],al	;Pattern Width
	add	edi,12

	mov	esi,GUS_TempBuffPtr
	mov	edx,esi 		;Read One Pattern
	mov	ecx,PatternSize
	call	ReadFile

	mov	ecx,64
RowLoopen2:
	push	edi
	push	ecx

	movzx	ecx,Channels
ChannelLoop:				;Each Channel
	push	edi
	push	ecx
	lodsb				;Read One row
	shl	eax,8
	lodsb
	shl	eax,8
	lodsb
	shl	eax,8
	lodsb
	movzx	ebx,ax			;Command Data
	and	ebx,00000fffh		;clear low 4 bits of samp.nr
	shr	eax,12
	ror	ax,4
	ror	eax,12			;Samp Nr in al
	shl	ebx,16
	shrd	ebx,eax,8
	shr	eax,20

	push	esi			;Get Period
	lea	esi,Periods
	mov	ecx,5*12
PeriodLoop:
	cmp	ax,[esi]
	ja	SkipLoop
	add	esi,2
	loop	PeriodLoop
	mov	ax,0
	jmp	Snuffel
SkipLoop:
	mov	cx,[esi-2]
	cmp	ax,cx
	jz	GotExact
	sub	cx,ax
	sub	ax,[esi]
	cmp	cx,ax
	jb	GotExact
	add	esi,2
GotExact:
	sub	esi,Offset Periods+2
	shr	esi,1
	add	esi,2+24
	mov	ax,si
Snuffel:
	xor	ecx,ecx
	pop	esi
	shrd	ebx,eax,8
	mov	eax,ebx 		;ebx contains converted row
	rol	eax,8
	stosb				;Store Period into Row
	rol	eax,8
	stosb				;Store Sample Number
	rol	eax,8
	mov	ah,al			;Check command
	mov	bl,al
	and	bl,3fh
	cmp	bl,0ch			;Is it a VOL command?
	jnz	NoVolume
	mov	cl,1			;VOL*2
NoVolume:
	stosb				;Store Command Nr
	rol	eax,8
	cmp	cl,0
	jz	NoChange2
	shl	al,1
	cmp	al,128			;Too Loud?
	jb	NoChange2
	mov	al,127
NoChange2:
	stosb				;Store Command
	pop	ecx
	pop	edi
	add	edi,RowSize
	loop	ChannelLoop

	pop	ecx
	pop	edi
	add	edi,ChRowSize
	loop	RowLoopen2

	pop	ebp
	pop	ecx
	inc	ebp
	loop	ConvertPatternLoopen
	mov	LSConvert,0
;---------------------------------------------- Load samples
LoadTheSamples:
	movzx	ecx,Samples
	jecxz	QuitLoad
	mov	ebx,16
	mov	CurrentInstrument,0
GUS_Samplenghts1:
	push	ecx
	inc	CurrentInstrument
	call	SetInitialEnvelopes
	mov	CurrentSample,bx
	mov	ecx,[SampleOffsetEnd+ebx*4]
	mov	eax,ecx
	cmp	ecx,0
	jz	GUS_NoSample
;--..--
	push	ecx
	mov	cl,[VoiceControl+ebx]
	bt	cx,2
	setc	cl
	shl	eax,cl			;eax=bytes, ecx=samples
	pop	ecx
;--..--
	push	ebx eax
	mov	ebp,1024
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampMainOffset,eax
	pop	eax ebx

	xchg	eax,ecx                 ;ecx=bytes, eax=samples
	mov	edx,SampMainOffset
	push	eax
	call	ReadFile
	pop	eax

	call	AllocSample
;	mov	ax,GUSDramErr
;	jc	ErrorHandler
	jnc	NoTHEErr
	call	FixAllocSampleError
NoTHEErr:

	movzx	edx,LSConvert
	call	MoveSample

	mov	ebp,1024
	call	MemDisAlloc
GUS_NoSample:
	pop	ecx
	add	ebx,16
	loop	GUS_Samplenghts1

	jmp	QuitLoad
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ End Convert


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;			   Load FastTracker 2 Module
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FastTracker2:
	call	ClearMod
	call	FixLoadOffset
	mov	edx,GUS_TempBuffPtr	;Read Dummy
	mov	ecx,17
	call	ReadFile

	mov	ecx,20
	lea	edx,SongName		;Load ModName
	call	ReadFile

	mov	edx,GUS_TempBuffPtr	;Load Rest of Heather Locklear
	mov	ecx,27
	call	ReadFile

	cmp	word ptr [edx+21],0102h
	jnz	NewXM
	mov	ax,OldXMErr
	jmp	ErrorHandler

NewXM:
	cmp	word ptr [edx+21],0104h ;Check If correct Version
	mov	ax,BadVersionErr
	jnz	ErrorHandler

	mov	ecx,[edx+23]
	sub	ecx,4
	mov	edx,GUS_TempBuffPtr	;Load Rest of Heather Locklear
	call	ReadFile
	sub	edx,4
	mov	ax,[edx+4]		;Get nr of positions
	mov	Positions,ax
	mov	ax,[edx+8]		;Get nr of Channels
	mov	Channels,al
	mov	ax,[edx+10]
	mov	Patterns,ax		;Get nr of patterns
	mov	ax,[edx+12]
;	inc	al
	mov	Samples,al		;Get nr of Instruments
	mov	ax,[edx+14]
	mov	LinFreq,al		;Get Freq type
	mov	ax,[edx+16]
	mov	ModSpeed,al		;Get initial Speed
	mov	InitSpeed,al
	mov	ah,[edx+18]
	and	ax,0ff00h
	mov	ModTempo,ax		;Get initial BPM
	mov	InitBPM,ax
	mov	HertzAdder,ax
	mov	Commands,2		;Set nr of Commands to 2
	mov	esi,edx
	add	esi,20

	movzx	eax,Samples
	mov	ebx,30
	mul	ebx
	mov	ebp,1029		;Allocate Inst. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstNamesPtr,eax

	movzx	eax,Samples
	shl	eax,4
	mov	ebx,22
	mul	ebx
	mov	ebp,1028		;Allocate Samp. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampleNamesPtr,eax

	movzx	eax,Samples
	mov	ebx,716
	mul	ebx
	mov	ebp,1034		;Allocate Inst. Info
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstrumentInfo,eax

	movzx	eax,Positions
	shl	eax,1
	mov	ebp,1030		;Allocate Positions
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	PatternOrderPtr,eax

	mov	edi,eax
	xor	ax,ax
	movzx	ecx,Positions
ConvPos:
	lodsb
	stosw
	loop	ConvPos

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Patterns

	lea	edi,DetectBuffer
	mov	ecx,144
	xor	al,al
	rep	stosb

	movzx	ecx,Patterns
	xor	ebp,ebp
LoadXMPatternLoop:
	push	ecx ebp

	mov	edx,GUS_TempBuffPtr	;Load Header Length
	mov	ecx,4
	call	ReadFile

	mov	ecx,[edx]		;Load Header
	sub	ecx,4
	add	edx,4
	call	ReadFile
	sub	edx,4
	movzx	eax,word ptr [edx+5]
	mov	CurrPattLength,eax

	movzx	ecx,word ptr [edx+7]	;Load patterndata size
	jecxz	NextXMPattern
	mov	edx,GUS_TempBuffPtr
	call	ReadFile
	mov	esi,GUS_TempBuffPtr
	call	ParseXMPatt

NextXMPattern:
	pop	ebp ecx
	inc	ebp
	loop	LoadXMPatternLoop

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Instruments
	movzx	ecx,Samples
;	dec	ecx
	jz	QuitLoad
	mov	CurrentInstrument,1
LoadXILoop:
	push	ecx

	mov	edx,GUS_TempBuffPtr		;Load Inst header
	mov	ecx,33
	call	_ReadFile
	mov	ax,ReadErr
	jc	ErrorHandler

	sub	dword ptr [edx],33+96
	mov	ax,word ptr [edx+27]
	mov	NrOfWaveForms,ax		;Load nr of samples in inst.
	mov	eax,dword ptr [edx+29]
	mov	SampHeaderSize,eax		;Load sampl header size

	mov	esi,GUS_TempBuffPtr		;Get Name
	add	esi,4
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
	cmp	dword ptr [edx],0
	jle	NextXMInstr

	movzx	ebx,CurrentInstrument		;Inst Nr
	GetOffset ebx,edx,ENV_SplitKBD		;Load Split data
	mov	ecx,96
	call	_ReadFile
	mov	ax,ReadErr
	jc	ErrorHandler

	lea	edx,DetectBuffer		;Load rest of Header
	mov	ecx,GUS_TempBuffPtr
	mov	ecx,[ecx]
	cmp	ecx,144
	jbe	NoXIGillestuga
	mov	ax,BadVersionErr
	jmp	ErrorHandler
NoXIGillestuga:
	call	_ReadFile
	mov	ax,ReadErr
	jc	ErrorHandler

	call	LoadXIData

NextXMInstr:
	inc	CurrentInstrument
	pop	ecx
	loop	LoadXILoop
	jmp	QuitLoad


XMVolCmdTbl	dw	0ah,0ah,0b00eh,0a00eh,04h,04h,08h,18h,18h,03h
FixXMVolCmd:
	push	ebx edx
	xor	bx,bx
	shl	ax,8
	cmp	ah,0
	jz	NormalVolume
	cmp	ah,60h
	jae	VolEffect
	sub	ah,10h
	mov	bh,ah
	mov	bl,0ch
	shl	bh,1
	cmp	bh,128
	jnz	NormalVolume
	dec	bh
	jmp	NormalVolume
VolEffect:
	sub	ah,60h
	mov	al,ah
	shr	ah,4
	and	al,0fh
	movzx	ebx,ah
	mov	bx,[XMVolCmdTbl+ebx*2]
	cmp	ah,0
	jz	LowBits
	cmp	ah,2
	jz	LowBits
	cmp	ah,3
	jz	LowBits
	cmp	ah,5
	jz	LowBits
	cmp	ah,6
	jz	LowBits
	cmp	ah,8
	jz	LowBits
	shl	al,4
LowBits:
	or	bh,al

NormalVolume:
	mov	[edi],bx
	pop	edx ebx
	ret

		       ;  g   h i j k	l   m n o p   q r   s t u v w x	  x2(special)
XMCmdTbl	db	2ch,2ah,0,0,20h,23h,0,0,0,18h,0,13h,0,0,0,0,0,11h,12h
FixXMCmd:
	push	ebx edx
	cmp	al,0fh
	jbe	NormalCommand
	sub	al,10h
	movzx	ebx,al
	mov	al,[XMCmdTbl+ebx]
	cmp	ebx,17
	jz	Cmd11
	cmp	ebx,4
	jz	Cmd20
	cmp	ebx,1
	jz	Cmd2a
	cmp	ebx,0
	jz	Cmd2c

	jmp	NormalCommand
Cmd2a:
	shl	ah,1
	jmp	RepeatingCmd
Cmd2c:
	shl	ah,1
	cmp	ah,127
	jbe	NoRepeatingCmd
	mov	ah,127
	jmp	NoRepeatingCmd
Cmd20:
	mov	ah,00h
	jmp	NoRepeatingCmd
Cmd11:
	mov	bl,ah
	and	ah,0fh
	shr	bl,4
	cmp	bl,1
	jz	NormalCommand
	inc	al
NormalCommand:
	cmp	al,1
	jz	XM1_2Cmd
	cmp	al,2
	jz	XM1_2Cmd
	cmp	al,5
	jz	RepeatingCmd
	cmp	al,6
	jz	RepeatingCmd
	cmp	al,8
	jz	XM8Cmd
	cmp	al,0ch
	jz	XMCCmd
	cmp	al,0ah
	jz	RepeatingCmd
	cmp	al,11h
	jz	RepeatingCmd
	cmp	al,12h
	jz	RepeatingCmd
	cmp	al,18h
	jz	XMPCmd

	cmp	al,0eh
	jnz	NoRepeatingCmd
	mov	bl,ah
	shr	bl,4
	cmp	bl,0ah
	jz	RepeatingCmd
	cmp	bl,0bh
	jz	RepeatingCmd
	cmp	bl,1
	jz	XME1_2Cmd
	cmp	bl,2
	jz	XME1_2Cmd
	jmp	NoRepeatingCmd
XMPCmd:
	rol	ah,4
	jmp	RepeatingCmd
XM1_2Cmd:
	or	al,20h
	jmp	RepeatingCmd
XME1_2Cmd:
	or	al,10h
	jmp	RepeatingCmd
XM8Cmd:
	shr	ah,4
	jmp	NoRepeatingCmd
XMCCmd:
	shl	ah,1
	cmp	ah,127
	jbe	NoRepeatingCmd
	mov	ah,127
	jmp	NoRepeatingCmd

RepeatingCmd:
	mov	bl,al
	and	bl,0fh
	cmp	bl,0eh
	jnz	NoSpecialETreat
	mov	bl,ah
	and	bl,0fh
	jnz	StoreShitsky
	mov	ah,[DetectBuffer+ebp]
	jmp	StoreShitsky

NoSpecialETreat:
	cmp	ah,0
	jnz	StoreShitsky
	mov	ah,[DetectBuffer+ebp]
StoreShitsky:
	mov	[DetectBuffer+ebp],ah
NoRepeatingCmd:
	mov	[edi],ax
	pop	edx ebx
	ret


TempShit	dd	16 dup(0)

LoadXIData:
	cmp	[DetectBuffer+96],2		;fix # of points, vol
	jae	NiXiPribb1
	mov	[DetectBuffer+96],2
NiXiPribb1:
	cmp	[DetectBuffer+96],12
	jbe	NiXiPribb2
	mov	[DetectBuffer+96],12
NiXiPribb2:

	cmp	[DetectBuffer+97],2		;pan
	jae	NiXiPribb3
	mov	[DetectBuffer+97],2
NiXiPribb3:
	cmp	[DetectBuffer+97],12
	jbe	NiXiPribb4
	mov	[DetectBuffer+97],12
NiXiPribb4:

	mov	al,[DetectBuffer+96]		;fix loopend, vol
	dec	al
	jg	@@ah1
	mov	al,1
@@ah1:
	cmp	al,[DetectBuffer+100]
	jae	NiXiPribb5
	mov	[DetectBuffer+100],al
NiXiPribb5:

	mov	al,[DetectBuffer+97]		;pan
	dec	al
	jg	@@ah1
	mov	al,1
@@ah1:
	cmp	al,[DetectBuffer+103]
	jae	NiXiPribb6
	mov	[DetectBuffer+103],al
NiXiPribb6:
	mov	al,[DetectBuffer+100]	 	;fix loopstart, vol
	cmp	al,[DetectBuffer+99]
	ja	NiXiPribb7
	dec	al
	jge	@@ah1
	mov	al,0
@@ah1:
	mov	[DetectBuffer+99],al
NiXiPribb7:

	mov	al,[DetectBuffer+103]		;pan
	cmp	al,[DetectBuffer+102]
	ja	NiXiPribb8
	dec	al
	jge	@@ah1
	mov	al,0
@@ah1:
	mov	[DetectBuffer+102],al
NiXiPribb8:
	movzx	ecx,[DetectBuffer+96]		;Nr of Vol Points
	lea	esi,DetectBuffer

	movzx	edi,CurrentInstrument
	GetOffset edi,edi,ENV_VolPoints
	mov	bx,0
FixVolPLoop:
	lodsw
	mov	bp,ax	;save offs
	sub	ax,bx
	mov	bx,bp	;store old offs
	mov	[edi],ax
	lodsw
	shl	al,1
	cmp	al,80h
	jb	FVPLSkip
	mov	al,7fh
FVPLSkip:
	mov	[edi+2],al
	add	edi,3
	loop	FixVolPLoop

	movzx	ecx,[DetectBuffer+97]		;Nr of Pan Points
	lea	esi,DetectBuffer+48
	movzx	edi,CurrentInstrument
	GetOffset edi,edi,ENV_PanPoints
	mov	bx,0
FixPanPLoop:
	lodsw
	mov	bp,ax	;save offs
	sub	ax,bx
	mov	bx,bp	;store old offs
	mov	[edi],ax
	lodsw
	shl	al,2
	mov	[edi+2],al
	add	edi,3
	loop	FixPanPLoop

	lea	esi,DetectBuffer+96
	movzx	edi,CurrentInstrument

	lodsb
	dec	al
	GetOffset edi,edx,ENV_NrVolPoints
	mov	[edx],al

	lodsb
	dec	al
	GetOffset edi,edx,ENV_NrPanPoints
	mov	[edx],al

	lodsb
	GetOffset edi,edx,ENV_VolSustPoint
	mov	[edx],al

	lodsb
	GetOffset edi,edx,ENV_VolStart
	mov	[edx],al

	lodsb
	GetOffset edi,edx,ENV_VolEnd
	mov	[edx],al

	lodsb
	GetOffset edi,edx,ENV_PanSustPoint
	mov	[edx],al

	lodsb
	GetOffset edi,edx,ENV_PanStart
	mov	[edx],al

	lodsb
	GetOffset edi,edx,ENV_PanEnd
	mov	[edx],al

	lodsb
	xor	bl,bl
	rcr	al,1
	rcl	bl,1
	rcr	al,1
	rcl	bl,1
	rcr	al,1
	rcl	bl,1
	lodsb
	xor	bh,bh
	rcr	al,1
	rcl	bh,1
	rcr	al,1
	rcl	bh,1
	rcr	al,1
	rcl	bh,1
	shl	bh,3
	or	bl,bh
	lodsb
	shl	al,6
	or	bl,al
	and	bx,03fh

	GetOffset edi,ebp,ENV_Flags
	mov	[ebp],bx
	lodsb					;Dummy read
	GetOffset edi,edx,ENV_Shadow
	mov	byte ptr [edx],0		;No Shadow
	lodsw	;Dummy Read
;	jmp	ContXiLoad

comment %
	or	word ptr [ebp],101000000b
	lodsb				;VIB Depth
	and	eax,0fh
	lea	eax,[eax+eax*2]
	shl	eax,3
	mov	ebx,15
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	mov	bh,bl
	neg	bh
	add	bx,8080h

	lodsb				;VIB Rate
	and	eax,03fh
	mov	ebp,230
	mul	ebp
	mov	ebp,63
	xor	edx,edx
	div	ebp
	mov	ebp,231
	sub	ebp,eax


	movzx	edi,CurrentInstrument
	GetOffset edi,edi,ENV_VibPoints

	mov	word ptr [edi],0
	mov	byte ptr [edi+2],80h

	mov	[edi+3],bp
	or	byte ptr [edi+4],00000010b
	mov	[edi+5],bl

	mov	[edi+6],bp
	or	byte ptr [edi+7],00000100b
	mov	byte ptr [edi+8],80h

	mov	[edi+9],bp
	or	byte ptr [edi+10],00000010b
	mov	[edi+11],bh

	mov	[edi+12],bp
	or	byte ptr [edi+13],00000100b
	mov	byte ptr [edi+14],80h


	movzx	edi,CurrentInstrument

	GetOffset edi,edx,ENV_NrVibPoints
	mov	byte ptr [edx],4

	GetOffset edi,edx,ENV_VibSustPoint
	mov	byte ptr [edx],0

	GetOffset edi,edx,ENV_VibStart
	mov	byte ptr [edx],0

	GetOffset edi,edx,ENV_VibEnd
	mov	byte ptr [edx],4

%
ContXiLoad:
	lodsw
	GetOffset edi,edx,ENV_VolFade
	mov	[edx],ax
	GetOffset edi,edx,ENV_VibSpeed
	mov	byte ptr [edx],0
	GetOffset edi,edx,ENV_VolSpeed
	mov	byte ptr [edx],0
	GetOffset edi,edx,ENV_VibSpeed
	mov	byte ptr [edx],0

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Samples
	movzx	ecx,NrOfWaveForms
	movzx	ebp,CurrentInstrument
	shl	ebp,4					;Current Sample

XReadSampleLoop:
	push	ecx
	mov	CurrentSample,bp

	lea	edx,DetectBuffer
	mov	ecx,SampHeaderSize
	call	_ReadFile
	mov	ax,ReadErr
	jc	ErrorHandler

	mov	eax,dword ptr [DetectBuffer]
	mov	Samp_End,eax
	cmp	eax,0
	jz	ClearThisSample
	mov	eax,dword ptr [DetectBuffer+4]
	mov	Loop_Start,eax
	mov	eax,dword ptr [DetectBuffer+8]
	add	eax,Loop_Start
	mov	Loop_End,eax

	mov	cl,[DetectBuffer+14]
	bt	cx,4
	setc	cl
	shr	Loop_Start,cl
	shr	Loop_End,cl
	shr	Samp_End,cl

;	mov	[VoiceControl+ebp],0
	shl	cl,2
	mov	[VoiceControl+ebp],cl
;	shr	cl,2

	mov	[SampleOffsetStart+ebp*4],0
	mov	eax,Loop_Start
	mov	[LoopStart+ebp*4],eax
	mov	eax,Loop_End
	mov	[LoopEnd+ebp*4],eax
	mov	eax,Samp_End
	mov	[SampleOffsetEnd+ebp*4],eax

	mov	ecx,ebp
	and	ecx,0fh
	mov	[TempShit+ecx*4],-1

	call	AllocSample
	mov	Samp_Start,eax
	jnc	NoLoadXISampleError
	mov	eax,SizeAllocated
	mov	[TempShit+ecx*4],eax

	cmp	eax,0
	jnz	NoLoadXISampleError
	mov	Samp_Start,0
;	mov	ErrorLoadSample,1
;	lea	esi,NotLoaded
;	jmp	MoveXIName
NoLoadXISampleError:
	mov	eax,Samp_Start
	mov	[SampleOffsetStart+ebp*4],eax		;Temporary

	mov	al,[DetectBuffer+13]
	shr	al,4
	mov	[FineTunes+ebp],al
	mov	al,[DetectBuffer+16]
	mov	[RelativeNote+ebp],al
	mov	[SampleRates+ebp*2],8363
	mov	al,[DetectBuffer+12]
	shl	al,1
	cmp	al,80h
	jb	AnotherOner
	mov	al,7fh
AnotherOner:
	mov	[Volumes+ebp],al

	mov	al,[DetectBuffer+14]
	mov	ah,al
	shr	ah,2
	and	ah,4
	shl	al,3
	and	al,00011000b
	or	al,ah
	test	al,00011000b
	jz	NoVAL
	bts	ax,3
NoVAL:
	mov	[VoiceControl+ebp],al

	mov	al,[DetectBuffer+15]
	and	al,0f0h
	cmp	al,70h
	ja	NoXiPanFix
	add	al,10h
NoXiPanFix:
	or	[FineTunes+ebp],al
	lea	esi,DetectBuffer+18

MoveXiName:
	mov	ecx,ebp
	sub	ecx,16
	mov	eax,22
	mul	ecx
	add	eax,SampleNamesPtr
	mov	edi,eax
	mov	ecx,22
	rep	movsb

ClearThisSample:
	pop	ecx
	inc	ebp
	loop	XReadSampleLoop

;-----------------------------------		;Sample Data Read
	movzx	ecx,NrOfWaveForms
	movzx	ebp,CurrentInstrument
	shl	ebp,4				;Current Sample
XReadSampleDataLoop:
	push	ecx
	mov	CurrentSample,bp
	mov	edx,[SampleOffsetEnd+ebp*4]	;Sample size
	cmp	edx,0
	jz	HeyItsNotASample
;--..--
	mov	cl,[VoiceControl+ebp]
	bt	cx,2
	setc	cl
	shl	edx,cl
	mov	ecx,edx
;--..--
	pushad
	mov	eax,ecx
	mov	ebp,1024
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampMainOffset,eax
	popad

	mov	edx,SampMainOffset
	call	_ReadFile
	mov	ax,ReadErr
	jc	ErrorHandler

	mov	edi,SampMainOffset
	mov	esi,edi
	xor	bx,bx

	mov	ecx,[SampleOffsetEnd+ebp*4]
	mov	al,[VoiceControl+ebp]
	bt	ax,2
	jc	ConvertDelta16
ConvertDelta:
	lodsb
	add	al,bl
	stosb
	mov	bl,al
	loop	ConvertDelta
	jmp	EndCD
ConvertDelta16:
	lodsw
	add	ax,bx
	stosw
	mov	bx,ax
	loop	ConvertDelta16
EndCD:
	mov	eax,[SampleOffsetStart+ebp*4]
	mov	[SampleOffsetStart+ebp*4],0
	mov	SampleOffsetMem,eax

	mov	ebx,ebp
	mov	ecx,ebp
	and	ecx,0fh
	mov	ecx,[TempShit+ecx*4]
	cmp	ecx,-1
	jz	@@NoErr
	mov	SizeAllocated,ecx
	call	FixAllocSampleError		;If AllocErrors
@@NoErr:
	mov	edx,0
	call	MoveSample

HeyItsNotASample:
	pop	ecx
	inc	ebp
	loop	XReadSampleDataLoop

	mov	ebp,1024
	call	MemDisalloc
	ret
;---------------------------------


;ebp=pattern number
;esi=ptr to temp buffer
;Channels,CurrPattLength,Commands must be set
ParseXMPatt	Proc	Near
	call	GetPatternSize		;Alloc one pattern
	mov	eax,PatternSize2
	add	eax,12
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	edi,eax
	mov	al,Channels
	dec	al
	or	al,01000000b
	mov	[edi+11],al

	mov	eax,CurrPattLength
	dec	al
	mov	[edi+10],al

	add	edi,12

	mov	ecx,CurrPattLength
GetXMPattRow:
	push	ecx

	xor	ebp,ebp
	movzx	ecx,Channels
GetXMChan:
	push	ecx
	lodsb
	mov	bl,al
	bt	bx,7
	jc	XMPack
	cmp	al,0
	jnz	@@NoZero
	mov	al,-1
@@NoZero:
	cmp	al,97
	jnz	NoXMKeyOff1
	mov	al,0
NoXMKeyOff1:
	inc	al		;get note
	stosb
	movsb			;get inst nr
	lodsb			;get VOL
	call	FixXMVolCmd
	add	edi,2
	lodsw
	call	FixXMCmd
	add	edi,2
	jmp	NoXMPack
XMPack:
	bt	bx,0
	jnc	NoXMNote
	lodsb
	cmp	al,97
	jnz	NoXMKeyOff2
	mov	al,0
NoXMKeyOff2:
	inc	al
	mov	[edi],al
NoXMNote:
	inc	edi

	bt	bx,1
	jnc	NoXMInst
	lodsb
	mov	[edi],al
NoXMInst:
	inc	edi

	bt	bx,2
	jnc	NoXMVOL
	lodsb
	call	FixXMVolCmd
NoXMVOL:
	add	edi,2

	bt	bx,3
	jnc	NoXMCMD
	lodsb
	mov	[edi],al
NoXMCMD:
	inc	edi

	bt	bx,4
	jnc	NoXMEff
	lodsb
	mov	[edi],al
NoXMEff:
	inc	edi

	sub	edi,2
	mov	ax,[edi]
	call	FixXMCmd
	add	edi,2

NoXMPack:
	pop	ecx
	inc	ebp
	loop	GetXMChan

	pop	ecx
	loop	GetXMPattRow
	ret
ParseXMPatt	EndP




ScanLength	Proc	Near
	push	ecx esi
	mov	ecx,eax
	mov	eax,0
	dec	esi
ScanLoop:
	inc	esi
	inc	eax
	cmp	byte ptr [esi],0
	jz	NoStrip
	cmp	byte ptr [esi],32
	jb	Strip
	cmp	byte ptr [esi],-1
	jz	Strip
;	cmp	byte ptr [esi],128
;	jb	NoStrip
;	and	byte ptr [esi],127
	jmp	NoStrip
Strip:
	mov	byte ptr [esi],32
NoStrip:
	cmp	byte ptr [esi],0
	loopnz	ScanLoop
	pop	esi ecx
	Ret
ScanLength	EndP

CopyString	Proc	Near
	push	ecx esi edi
	mov	ecx,eax
	rep	movsb
	pop	edi esi ecx
	Ret
CopyString	EndP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;			    ScreamTracker 3 Loading
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


LoadScreamTracker3:
	mov	LinFreq,0
	call	ClearMod
	call	FixLoadOffset

	mov	eax,60h
	mov	bl,1
	call	_LseekFile

	movzx	ecx,word ptr [Detectbuffer+20h]
	mov	edx,GUS_TempBuffPtr	;Load Positions
	call	ReadFile

	movzx	ax,byte ptr [Detectbuffer+20h]
	mov	Positions,ax
	mov	ax,word ptr [Detectbuffer+22h]
	mov	Samples,al
	mov	ax,word ptr [Detectbuffer+24h]
	mov	Patterns,ax
	mov	ax,word ptr [Detectbuffer+26h]
	shr	ax,4
	and	eax,1
	mov	eax,[S3MCommandTbl+eax*4]
	mov	S3MCommand,eax

;	mov	al,[Detectbuffer+30h]
;	mov	GlobalVolume,al
	mov	al,[Detectbuffer+31h]		;Init Speed
	mov	ModSpeed,al
	mov	InitSpeed,al
	movzx	ax,byte ptr [Detectbuffer+32h]	;Init BPM
	cmp	al,32
	jae	NoShottkyFix
	mov	al,32
NoShottkyFix:
	shl	ax,8
	mov	ModTempo,ax
	mov	InitBPM,ax
	mov	HertzAdder,ax

	mov	Channels,0
	lea	edi,Mute
	lea	esi,DetectBuffer
	add	esi,40h
	xor	ecx,ecx
GetChSettings:
	mov	al,[esi+ecx]
	cmp	al,0ffh
	jz	ChDisabled
	test	al,080h
	jnz	ChDisabled
	mov	byte ptr [edi+ecx],1
	cmp	al,16
	jae	ChDisabled
	mov	ah,30h
	cmp	al,8
	jb	SetS3MPan
	mov	ah,0c0h
SetS3MPan:
	mov	[CurrentChannelPanPot+ecx],ah
	mov	[PanPosition_Orig+ecx],ah
	mov	[PanPosition+ecx],ah
	cmp	Channels,cl
	ja	ChDisabled
	mov	Channels,cl
ChDisabled:
	inc	ecx
	cmp	ecx,32
	jb	GetChSettings
	inc	Channels
	mov	Commands,2
	call	GetRowSize
	mov	al,Channels
	dec	al
	or	al,40h
	mov	ChanCMD,al

	mov	CurrPattLength,64
	movzx	ecx,Patterns		;Allocate all patterns
	call	GetPatternSize
	xor	ebp,ebp
AllocateThePatterns3:
	mov	eax,PatternSize2
	add	eax,12
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	inc	ebp
	loop	AllocateThePatterns3

	movzx	eax,Samples
	mov	ebx,30
	mul	ebx
	mov	ebp,1029		;Allocate Inst. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstNamesPtr,eax

	movzx	eax,Samples
	shl	eax,4
	mov	ebx,22
	mul	ebx
	mov	ebp,1028		;Allocate Samp. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampleNamesPtr,eax

	movzx	eax,Samples
	mov	ebx,716
	mul	ebx
	mov	ebp,1034		;Allocate Inst. Info
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstrumentInfo,eax

	movzx	eax,Positions
	shl	eax,1
	mov	ebp,1030		;Allocate Positions
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	PatternOrderPtr,eax

	movzx	ecx,Positions
	mov	edi,PatternOrderPtr	;PatternOrder
	mov	esi,GUS_TempBuffPtr
	xor	eax,eax
	xor	bx,bx
PatternLoop2:
	lodsb
	cmp	al,-1
	jz	SkipMore
	cmp	al,-2
	jz	SkipMore
	stosw
	inc	bx
SkipMore:
	loop	PatternLoop2
	cmp	bx,0
	jnz	OxeSaft
	mov	bx,1
OxeSaft:
	mov	Positions,bx

	mov	FormatVer,AMSVersion	;Store Version
	mov	MIDIChannels,0		;No MIDI in a .S3M file
;	mov	Channels,1

	lea	esi,DetectBuffer
	lea	edi,SongName
	mov	eax,27
	call	CopyString	;Store Name

	movzx	ecx,word ptr [DetectBuffer+22h]
	shl	ecx,1
	movzx	eax,word ptr [DetectBuffer+24h]
	shl	eax,1
	add	ecx,eax
	mov	edx,GUS_TempBuffPtr	;Load Inst. + Patt. ParaPointers
	call	ReadFile

	movzx	ecx,Samples
	jcxz	NoMoreSample2
	mov	edi,16
	xor	ebp,ebp
	mov	ebx,GUS_TempBuffPtr
LoadSampleInfo2:
	push	ecx

	push	ebx
	movzx	eax,word ptr [ebx]
	shl	eax,4
	add	eax,LoadOffset

	mov	bl,0
	call	_LseekFile
	pop	ebx

	lea	edx,TmpSampInfo
	mov	esi,edx
	mov	ecx,50h
	call	ReadFile
	cmp	byte ptr [esi],1
	jnz	NoSample2

	push	ebp edi
	shr	edi,4
	mov	ebp,GUS_TempBuffPtr
	add	ebp,98000
	mov	eax,dword ptr [esi+0ch]
	mov	dword ptr [ebp+edi*4],eax
	pop	edi ebp

	mov	eax,[esi+10h]
	mov	[SampleOffsetEnd+edi*4],eax
	cmp	byte ptr [esi+1fh],0
	jz	NoOffsetFix
	mov	eax,[esi+14h]
	mov	[LoopStart+edi*4],eax
	mov	eax,[esi+18h]
;	 cmp	 eax,0
;	 jz	 Ggga2
;	 dec	 eax			 ;ST3 fix
;Ggga2:
	mov	[LoopEnd+edi*4],eax
	cmp	eax,[LoopStart+edi*4]
	jnz	NoOffsetFix
	mov	[LoopStart+edi*4],0
	mov	[LoopEnd+edi*4],0
NoOffsetFix:
	mov	[FineTunes+edi],0
	movzx	eax,word ptr [esi+20h]
	mov	[SampleRates+edi*2],ax
	movzx	eax,byte ptr [esi+1ch]
	shl	al,1
	cmp	al,128
	jb	Guru
	mov	al,127
Guru:
	mov	[Volumes+edi],al
	push	cx
	cmp	byte ptr [esi+1fh],0
	setnz	cl
	shl	cl,3
	and	[VoiceControl+edi],11110111b
	or	[VoiceControl+edi],cl
	pop	cx
NoSample2:
	add	esi,30h
	push	edi
	mov	edi,InstNamesPtr
	add	edi,ebp
	mov	ecx,27
	rep	movsb
	pop	edi

	add	edi,16
	add	ebx,2
	add	ebp,30
	pop	ecx
	loop	LoadSampleInfo2
NoMoreSample2:

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Patterns ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	lea	edi,DetectBuffer	;Clear temp buff
	mov	ecx,144
	xor	al,al
	rep	stosb

	xor	ebp,ebp
	movzx	ecx,Patterns
	mov	PatternSize,0
S3MPatternConvert:
	push	ecx
	push	ebp

	mov	edi,[AllocTable+ebp*8]
	mov	byte ptr [edi+10],63	;Pattern Length
	mov	al,ChanCMD
	mov	byte ptr [edi+11],al	;Channels+CMD
	add	edi,12

	movzx	eax,word ptr [ebx]
	cmp	eax,0
	jz	StrangePattern

	shl	eax,4
	add	eax,LoadOffset

	push	ebx
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler
	pop	ebx

	lea	edx,PatternSize 	;Load Patterns
	mov	ecx,2
	call	ReadFile

	mov	edx,GUS_TempBuffPtr
	add	edx,1000
	mov	ecx,PatternSize
	sub	ecx,2			;Size is included
	call	ReadFile

	pushad
	mov	ecx,64
	mov	esi,GUS_TempBuffPtr
	add	esi,1000
	xor	eax,eax
ConvertS3MLoopen:
	push	ecx
	push	edi
	mov	ebp,edi
	jmp	ConvertS3MRowLoopen

ConvertS3MRowLoopen2:		;Disabled Channel
	bt	cx,5
	pushf
	adc	esi,0
	popf
	adc	esi,0
	bt	cx,6
	adc	esi,0
	bt	cx,7
	pushf
	adc	esi,0
	popf
	adc	esi,0
ConvertS3MRowLoopen:
	mov	edi,ebp
	lodsb
	cmp	al,0
	jz	OneS3MRowFinished
	mov	cl,al
	and	al,31
	movzx	eax,al
	cmp	[Mute+eax],1
	jnz	ConvertS3MRowLoopen2

	mov	S3MChannel,eax
	mov	ebx,RowSize
	mul	ebx
	add	edi,eax
	bt	cx,5
	jnc	NoS3MNote
	lodsb
	cmp	al,0feh
	jnz	Grease
	mov	byte ptr [esi],0
	mov	byte ptr [edi],1
	jmp	NoGrease2
Grease:
	cmp	al,0ffh
	jz	NoGrease2
	movzx	eax,al
	mov	ebx,16
	xor	edx,edx
	div	ebx
	push	cx
	mov	ecx,edx
	mov	ebx,12
	mul	ebx
	add	eax,ecx
	add	eax,2
	mov	[edi],al
	pop	cx
NoGrease2:
	lodsb
	mov	[edi+1],al
NoS3MNote:
	bt	cx,6
	jnc	NoS3MVolume
NoVOLvo:
	lodsb
	shl	al,1
	cmp	al,128
	jb	Nois
	mov	al,127
Nois:
	mov	ah,0ch
	rol	ax,8
	mov	[edi+4],ax
NoS3MVolume:
	bt	cx,7
	jnc	NoS3MCommand
	lodsb				;Command Number
	movzx	eax,al

	push	eax
	add	eax,S3MCommand
	mov	bh,[eax]
	pop	eax

	mov	ah,al
	lodsb				;Command byte
	cmp	ah,0
	jz	FixS3MNoCommand
	cmp	ah,1
	jz	FixS3MCommandA
	cmp	ah,4
	jz	FixS3MCommandD
	cmp	ah,5
	jz	FixS3MCommandE
	cmp	ah,6
	jz	FixS3MCommandF
	cmp	ah,13h
	jz	FixS3MCommandS
	cmp	ah,14h
	jz	FixS3MCommandT
	cmp	ah,24
	jz	FixS3MCommandX

	cmp	ah,9
	jz	FixS3MCommandSave
	cmp	ah,0ah
	jz	FixS3MCommandSave
	cmp	ah,0bh
	jz	FixS3MCommandSave
	cmp	ah,0ch
	jz	FixS3MCommandSave
	cmp	ah,11h
	jz	FixS3MCommandSave
WriteS3MCommand:
	mov	byte ptr [edi+2],bh
	mov	byte ptr [edi+3],al
	jmp	ConvertS3MRowLoopen
FixS3MNoCommand:
	mov	al,0
	jmp	WriteS3MCommand
FixS3MCommandT:
	cmp	al,20h
	jae	WriteS3MCommand
	mov	al,20h
	jmp	WriteS3MCommand
FixS3MCommandA:
	cmp	al,0
	jnz	@@NoSpeak
	mov	bh,0
@@NoSpeak:
	cmp	al,1fh
	jbe	WriteS3MCommand
	mov	al,1fh
	jmp	WriteS3MCommand
FixS3MCommandX:
	shr	al,3
	cmp	al,0fh
	jbe	WriteS3MCommand
	mov	al,0fh
	jmp	WriteS3MCommand
FixS3MCommandD:
	call	FixS3MCommandSave2
	mov	ah,al
	cmp	ah,0fh
	jz	SpecialThing
	and	ah,0fh
	cmp	ah,0fh
	jz	FVU
	mov	ah,al
SpecialThing:
	and	ah,0f0h
	cmp	ah,0f0h
	jnz	WriteS3MCommand
	mov	bh,0eh
	and	al,0fh
	or	al,0b0h
	jmp	WriteS3MCommand
FVU:
	mov	bh,0eh
	shr	al,4
	or	al,0a0h
	jmp	WriteS3MCommand

FixS3MCommandE:
	call	FixS3MCommandSave2
	mov	ah,al
	and	ah,0f0h
	cmp	ah,0e0h
	jz	ExtraFSD
	cmp	ah,0f0h
	jnz	WriteS3MCommand
	mov	bh,0eh
	and	al,2fh
	jmp	WriteS3MCommand
ExtraFSD:
	mov	bh,12h
	and	al,0fh
	jmp	WriteS3MCommand
FixS3MCommandF:
	call	FixS3MCommandSave2
	mov	ah,al
	and	ah,0f0h
	cmp	ah,0e0h
	jz	ExtraFSU
	cmp	ah,0f0h
	jnz	WriteS3MCommand
	mov	bh,0eh
	and	al,1fh
	jmp	WriteS3MCommand
ExtraFSU:
	mov	bh,11h
	and	al,0fh
	jmp	WriteS3MCommand

FixS3MCommandS:
	mov	bh,0eh
	mov	cl,al
	shr	cl,4
	cmp	cl,8
	jnz	NoPanPot
	mov	bh,08h
	and	al,0fh
	jmp	WriteS3MCommand

NoPanPot:
	movzx	ecx,cl
	mov	cl,[S3M_SCommand+ecx]
	cmp	cl,0
	jz      ConvertS3MRowLoopen
	and	al,0fh
	or	al,cl
	jmp	WriteS3MCommand
NoS3MCommand:
	jmp	ConvertS3MRowLoopen

FixS3MCommandSave:
	push	edi
	mov	edi,S3MChannel
	cmp	al,0
	jnz	StoreShit
	mov	al,[DetectBuffer+edi]
StoreShit:
	mov	[DetectBuffer+edi],al
	pop	edi
	jmp	WriteS3MCommand

FixS3MCommandSave2:
	push	edi
	mov	edi,S3MChannel
	cmp	al,0
	jnz	StoreShit2
	mov	al,[DetectBuffer+edi]
StoreShit2:
	mov	[DetectBuffer+edi],al
	pop	edi
	ret


S3MChannel	dd 0
S3MCommandTbl	dd S3MCmds,S3MCmds2
S3MCommand	dd 0
S3MCmds		db 0,0fh,0bh,0dh,0ah,22h,21h,03h,04h,0,0h,06h,05h,0,0,09h,0,13h,07h,0eh,0fh,0,2ch,0,8,0,0,0,0,0
S3MCmds2	db 0,0fh,0bh,0dh,0ah,02h,01h,03h,04h,0,0h,06h,05h,0,0,09h,0,13h,07h,0eh,0fh,0,2ch,0,8,0,0,0,0,0
S3M_SCommand	db 0,030h,050h,040h,070h,0,0,0,0,0,0,060h,0c0h,0d0h,0e0h,0


OneS3MRowFinished:
	pop	edi
	pop	ecx
	add	edi,ChRowSize
	loop	ConvertS3MLoopen
	popad

StrangePattern:
	pop	ebp
	pop	ecx
	inc	ebp
	add	ebx,2
	add	edi,PatternSize2
	loop	S3MPatternConvert



;---------------------------------------- Samples
	movzx	ecx,Samples
	jecxz	QuitLoad
	mov	ebx,16
	mov	CurrentInstrument,0
GUS_Samplenghts2:
	inc	CurrentInstrument
	call	SetInitialEnvelopes

	mov	CurrentSample,bx
	push	ebx
	mov	ebp,GUS_TempBuffPtr
	add	ebp,98000
	push	ebx
	shr	ebx,4
	mov	eax,dword ptr [ebp+ebx*4]
	pop	ebx
	rol	ax,8
	rol	eax,16
	and	eax,0ffffffh
	shl	eax,4
	add	eax,LoadOffset
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler
	pop	ebx

	push	ecx
	mov	ecx,[SampleOffsetEnd+ebx*4]
	cmp	ecx,0
	jz	GUS_NoSample2

	mov	eax,ecx
	push	ebx
	mov	ebp,1024
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampMainOffset,eax
	pop	ebx

	mov	edx,SampMainOffset
	call	ReadFile
	mov	eax,ecx
	call	AllocSample
;	mov	ax,GUSDramErr
;	jc	ErrorHandler
	jnc	NoS3MErr
	call	FixAllocSampleError
NoS3MErr:

	mov	edx,128
	call	MoveSample
GUS_NoSample2:
	pop	ecx
	add	ebx,16
	loop	GUS_Samplenghts2

	mov	ebp,1024
	call	MemDisAlloc

	lea	edi,Mute
	mov	ecx,96
	xor	al,al
	rep	stosb
	jmp	QuitLoad

STMCommands	db	0,0fh,0bh,0dh,0ah,02h,01h,03h,04h,0eh,0
MaxSTMVol	db	0

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;			    ScreamTracker 2 Loading
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

LoadScreamTracker2:
	mov	LinFreq,0
	call	ClearMod
	call	FixLoadOffset
	mov	edx,GUS_TempBuffPtr	;Load Header
	mov	ecx,1168
	call	ReadFile
	mov	FormatVer,AMSVersion	;Store Version
	mov	esi,GUS_TempBuffPtr
	mov	Channels,4
	mov	Commands,2
	call	GetRowSize

	mov	PatternSize,1024

	mov	MIDIChannels,0	;No MIDI in a .STM file

	mov	Samples,0
FixNrOfSamples2:		 ;Count Nr of used samples
	mov	esi,GUS_TempBuffPtr
	add	esi,64
	mov	ecx,31
	xor	edx,edx
FixNOSLoop2:
	cmp	word ptr [esi],0
	jz	SEmpty2
	cmp	word ptr [esi],0001h
	jz	SEmpty2
	cmp	word ptr [esi-2],0
	jz	SEmpty2
	inc	Samples
SEmpty2:
	add	esi,32
	loop	FixNOSLoop2

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Samples
	mov	esi,GUS_TempBuffPtr
	add	esi,48
	mov	ecx,31		;SampleLoop
	xor	eax,eax
	mov	ebp,16
SampLoop2:
	mov	ax,[esi+16]	;Length of sample
	cmp	ax,1
	jbe	NoSample2STM
	cmp	word ptr [esi+14],0
	jz	NoSample2STM
	mov	[SampleOffsetEnd+ebp*4],eax ;Store End of sample
	mov	ax,[esi+18]			;Repeat Point
	mov	[LoopStart+ebp*4],eax	    ;Store Repeat Start
	mov	ax,[esi+20]			;Repeat End
	cmp	ax,-1
	jnz	NoBelowed2
	mov	ax,0
NoBelowed2:
	mov	[LoopEnd+ebp*4],eax ;Store Repeat End
	mov	ax,[esi+24]		;C2 Rate
	mov	[SampleRates+ebp*2],ax	;SampleRate
	mov	al,[esi+22]		;Volume
	shl	al,1
	cmp	al,128
	jb	NoDec2
	dec	al			;Only values below 128 are allowed
NoDec2:
	mov	[Volumes+ebp],al	;Store Volume
	mov	eax,[LoopEnd+ebp*4]
	sub	eax,[LoopStart+ebp*4]
	push	cx
	setnz	cl
	shl	cl,3
	and	[VoiceControl+ebp],11110111b
	or	[VoiceControl+ebp],cl
	pop	cx
	jmp	ASample2
NoSample2STM:
	mov	bx,31		;Check if empty SampleSpace
	sub	bl,Samples
	cmp	bx,cx
	jz	NoMoreSamples2
	inc	Samples 	;Empty sample
ASample2:
	add	esi,32
	add	ebp,16
	loop	SampLoop2

NoMoreSamples2:

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Names
	mov	eax,20		;Max 20 bytes
	mov	esi,GUS_TempBuffPtr
	call	ScanLength	;Get length of name
	lea	edi,SongName
	call	CopyString	;Store Name

	movzx	ecx,Samples
	jecxz	NoFuckingSamples4

	movzx	eax,Samples
	mov	ebx,30
	mul	ebx
	mov	ebp,1029		;Allocate Inst. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstNamesPtr,eax

	movzx	eax,Samples
	shl	eax,4
	mov	ebx,22
	mul	ebx
	mov	ebp,1028		;Allocate Samp. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampleNamesPtr,eax

	movzx	eax,Samples
	mov	ebx,716
	mul	ebx
	mov	ebp,1034		;Allocate Inst. Info
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstrumentInfo,eax

	mov	esi,GUS_TempBuffPtr
	add	esi,48
	mov	edi,InstNamesPtr
SampNameLoop2:
	mov	eax,12		;Copy 12 bytes
	call	ScanLength	;Get Length of name
	call	CopyString	;Store Name
	add	esi,32
	add	edi,30
	loop	SampNameLoop2

NoFuckingSamples4:
	mov	esi,GUS_TempBuffPtr	;Check for Highest PatternNumber
	movzx	ax,byte ptr [esi+33]
	mov	Patterns,ax
	mov	al,[esi+32]		;Initial Tempo?
	shr	al,4
	mov	ModSpeed,al
	mov	InitSpeed,al
	mov	al,[esi+34]		;Max Volume
	mov	MaxSTMVol,al

	mov	CurrPattLength,64
	movzx	ecx,Patterns		;Allocate all patterns
	call	GetPatternSize
	xor	ebp,ebp
AllocateThePatterns4:
	mov	eax,PatternSize2
	add	eax,12
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	inc	ebp
	loop	AllocateThePatterns4

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PatternOrder

	mov	eax,128 		;Allocate 128 positions first...
	shl	eax,1
	mov	ebp,1030		;Allocate Positions
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	PatternOrderPtr,eax

	mov	esi,GUS_TempBuffPtr	;Nr Of Positions
	add	esi,1040

	mov	Positions,0
	mov	ecx,128 		;Patterns
	mov	edi,PatternOrderPtr	;PatternOrder
	xor	eax,eax
PatternLoop2STM:
	lodsb
	cmp	al,63h
	jz	NoMorePos
	inc	Positions

	stosw
	loop	PatternLoop2STM
NoMorePos:

	movzx	eax,Positions		;...Then resize
	shl	eax,1
	mov	ebp,1030		;Allocate Positions
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	PatternOrderPtr,eax

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Patterns
	movzx	ecx,Patterns
	xor	ebp,ebp
ConvertPatternLoopenSTM:
	push	ecx
	push	ebp
	mov	edi,[AllocTable+ebp*8]
	mov	byte ptr [edi+10],63	;Pattern Length
	mov	byte ptr [edi+11],43h	;Channel+Commands
	add	edi,12

	mov	esi,GUS_TempBuffPtr
	mov	edx,esi 		;Read One Pattern
	mov	ecx,PatternSize
	call	ReadFile

	mov	ecx,64
RowLoopen2STM:
	push	edi
	push	ecx

	movzx	ecx,Channels
ChannelLoopSTM: 			;Each Channel
	push	edi
	push	ecx
	lodsb				;Period
	cmp	al,-1
	jnz	ANoteSTM
	mov	al,0
ANoteSTM:
	mov	cl,al
	shr	al,4
	mov	bl,12
	mul	bl
	and	cl,0fh
	add	al,cl
	cmp	al,0
	jz	Flipper
	add	al,2+24
Flipper:
	stosb				;Store Period

	lodsb				;Inst + vol
	mov	cl,al
	shr	al,3
	stosb				;Store Instrument

	lodsb				;Vol + cmd
	and	cl,7
	mov	ch,al
	and	ch,0fh
	shr	al,1
	and	al,not 7
	or	al,cl
	xchg	al,ch
	movzx	eax,al
	cmp	eax,0
	jnz	NoAntiArp
	mov	byte ptr [esi],0
NoAntiArp:
	mov	al,[STMCommands+eax]
	stosb				;Store command
	cmp	al,0fh
	jnz	Krusifajd
	shr	byte ptr [esi],4
Krusifajd:
	movsb				;Store Data
	cmp	ch,MaxSTMVol
	ja	NoSTMVol
	shl	ch,1
	cmp	ch,127
	jbe	NoVolCutSTM
	mov	ch,127
NoVolCutSTM:
	mov	cl,0ch
	mov	ax,cx
	stosw				;Store volume
NoSTMVol:
	pop	ecx
	pop	edi
	add	edi,RowSize
	loop	ChannelLoopSTM

	pop	ecx
	pop	edi
	add	edi,ChRowSize
	loop	RowLoopen2STM

	pop	ebp
	pop	ecx
	inc	ebp
	loop	ConvertPatternLoopenSTM
;---------------------------------------------- Load samples
LoadTheSamplesSTM:
	movzx	ecx,Samples
	jecxz	QuitLoad
	mov	ebx,16
	mov	CurrentInstrument,0
GUS_Samplenghts1STM:
	inc	CurrentInstrument
	call	SetInitialEnvelopes

	mov	CurrentSample,bx
	push	ecx
	mov	eax,[SampleOffsetEnd+ebx*4]
	mov	ecx,eax
	mov	ebp,eax
	cmp	eax,0
	jz	GUS_NoSampleSTM

	pushad
	mov	ebp,1024
	mov	ebx,0
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampMainOffset,eax
	popad

	mov	edx,SampMainOffset
	call	ReadFile
	mov	eax,ebp
	call	AllocSample
;	mov	ax,GUSDramErr
;	jc	ErrorHandler
	jnc	NoSTMErr
	call	FixAllocSampleError
NoSTMErr:
	mov	edx,0
	call	MoveSample

	and	ecx,1111b		;Pad bytes
	jz	GUS_NoSampleSTM
	sub	ecx,16
	neg	ecx
	mov	edx,SampMainOffset
	call	_ReadFile
	mov	ax,ReadErr
	jc	ErrorHandler

GUS_NoSampleSTM:
	pop	ecx
	add	ebx,16
	loop	GUS_Samplenghts1STM

	mov	ebp,1024
	call	MemDisAlloc

	jmp	QuitLoad



;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;				MTM Loading
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

MTMTracks	dw	0
MTMPatt		db	0
MTMComment	dw	0
LoadMTM:
	mov	LinFreq,0
	call	ClearMod
	mov	Commands,1
	mov	CurrPattLength,64
	call	FixLoadOffset
	mov	edx,GUS_TempBuffPtr	;Load Header
	mov	ecx,66
	call	ReadFile
	mov	FormatVer,AMSVersion	;Store Version
	mov	esi,GUS_TempBuffPtr
	mov	MIDIChannels,0		;No MIDI in an .MTM file

	mov	esi,GUS_TempBuffPtr
	add	esi,4
	lea	edi,SongName
	mov	eax,20			;Max 20 bytes
	call	CopyString		;Store Name

	mov	esi,GUS_TempBuffPtr
	mov	ax,[esi+24]
	mov	MTMTracks,ax
	mov	al,[esi+26]
	inc	al
	mov	MTMPatt,al
	mov     al,[esi+27]
	inc	al
	and	ax,0ffh
	mov	Positions,ax
	mov	ax,[esi+28]
	mov	MTMComment,ax
	mov	al,[esi+30]
	mov	Samples,al

	add	esi,34
	xor	ecx,ecx
@@Again:
	shl	byte ptr [esi+ecx],4
	inc	ecx
	cmp	ecx,33
	jnz	@@Again

	push	esi
	lea	edi,PanPosition
	mov	ecx,8
	rep	movsd
	pop	esi

	lea	edi,CurrentChannelPanPot
	mov	ecx,8
	rep	movsd
	mov	EnvPanCheck,-1

	movzx	eax,Samples
	mov	ebx,30
	mul	ebx
	mov	ebp,1029		;Allocate Inst. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstNamesPtr,eax

	movzx	eax,Samples
	shl	eax,4
	mov	ebx,22
	mul	ebx
	mov	ebp,1028		;Allocate Samp. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampleNamesPtr,eax

	movzx	eax,Samples
	mov	ebx,716
	mul	ebx
	mov	ebp,1034		;Allocate Inst. Info
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstrumentInfo,eax

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ	Samples

	mov	edx,GUS_TempBuffPtr	;Load Instrument data
	mov	esi,edx
	movzx	ecx,Samples
	push	edx
	mov	eax,37
	mul	ecx
	mov	ecx,eax
	pop	edx
	call	ReadFile

	movzx	ecx,Samples
	mov	ebp,16
MTMSampLoop:
	push	ecx
	mov	eax,30
	mov	ebx,ebp
	shr	ebx,4
	dec	ebx
	mul	ebx
	mov	edi,eax
	add	edi,InstNamesPtr
	mov	eax,22			;Copy 22 bytes
	call	ScanLength		;Get Length of name
	call	CopyString		;Store Name

	mov	cl,[esi+36]		;8 or 16 bits
	and	cl,1			;For Safety

	mov	eax,[esi+22]		;Length of sample
	shr	eax,cl
	mov	[SampleOffsetEnd+ebp*4],eax ;Store End of sample

	mov	eax,[esi+26]		;Repeat Point
	shr	eax,cl
	mov	[LoopStart+ebp*4],eax	;Store Repeat Start

	mov	eax,[esi+30]		;Repeat end
	shr	eax,cl
	cmp	eax,[SampleOffsetEnd+ebp*4]
	jbe	NoMTMBelowed
	mov	eax,[SampleOffsetEnd+ebp*4]
NoMTMBelowed:
	mov	[LoopEnd+ebp*4],eax	;Store Repeat End

	mov	al,[esi+34]		;FineTune
	and	al,0fh			;Clear PanPot for safety
	mov	[FineTunes+ebp],al	;Store FineTune

	mov	al,[esi+35]		;Volume
	shl	al,1
	cmp	al,128
	jb	NoMTMDec
	dec	al			;Only values below 128 are allowed
NoMTMDec:
	mov	[Volumes+ebp],al	;Store Volume

	shl	cl,2			;16 bits
	mov	[VoiceControl+ebp],cl

	mov	eax,[LoopEnd+ebp*4]	;Loop
	sub	eax,[LoopStart+ebp*4]
	cmp	eax,2
	seta	cl
	shl	cl,3
	or	[VoiceControl+ebp],cl

	mov	[SampleRates+ebp*2],8363

	add	esi,37
	add	ebp,16
	pop	ecx
	loop	MTMSampLoop

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PatternOrder

	mov	edx,GUS_TempBuffPtr	;Load Pattern Order
	mov	esi,edx
	mov	ecx,128
	call	ReadFile

	movzx	eax,Positions
	shl	eax,1
	mov	ebp,1030		;Allocate Positions
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	PatternOrderPtr,eax

	mov	edi,eax			;PatternOrder
	xor	eax,eax
MTMPatternLoop:
	lodsb
	stosw
	loop	MTMPatternLoop

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Patterns

	movzx	eax,MTMTracks		;Alloc TrackData
	mov	ebx,192
	mul	ebx
	push	eax
	mov	ebp,1037
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	TempBufferPtr,eax

	mov	edx,eax			;Load TrackData
	pop	ecx
	call	ReadFile

	movzx	ecx,MTMPatt		;Read Sequencing Data
	shl	ecx,6
	mov	edx,GUS_TempBuffPtr
	call	ReadFile

	mov	esi,GUS_TempBuffPtr
	movzx	ecx,MTMPatt
	xor	ebp,ebp
ParseMTMPattLoop:
	push	esi
	push	ecx

	mov	ecx,32
CheckMTMChan:
	cmp	word ptr [esi+ecx*2-2],0
	loopz	CheckMTMChan
	jz	EmptyMTMPatt
	inc	cl

	mov	Channels,cl
	dec	cl
	mov	ChanCMD,cl
	or	ChanCMD,00100000b

	call	GetPatternSize
	mov	eax,PatternSize2
	add	eax,12
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem

	mov	edi,[AllocTable+ebp*8]
	mov	byte ptr [edi+10],63	;Pattern Length
	mov	al,ChanCMD
	mov	byte ptr [edi+11],al	;Pattern Width
	add	edi,12

	call	GetRowSize

	movzx	ecx,Channels
ParseTrack:
	push	ecx
	push	edi
	xor	eax,eax
	lodsw				;Read Track Nr
	cmp	ax,0
	jz	EmptyMTMTrack
	dec	ax
	mov	ebx,192			;Get offset
	mul	ebx
	add	eax,TempBufferPtr
	mov	ecx,64
ParseRow:
	mov	bl,[eax]		;Note
	shr	bl,2
	cmp	bl,0
	jz	NoMTMAdd
	add	bl,2+24
NoMTMAdd:
	mov	[edi],bl

	mov	bl,[eax]		;Inst Nr
	and	bl,3
	shl	bl,4
	mov	bh,[eax+1]
	shr	bh,4
	or	bl,bh
	mov	[edi+1],bl

	mov	bh,[eax+1]		;Effect
	and	bh,0fh
	mov	[edi+2],bh

	mov	bl,[eax+2]
	mov	[edi+3],bl

	cmp	bh,8			;Check Illegal cmd
	jnz	NoMTMRemove
	mov     word ptr [edi+2],0
NoMTMRemove:

	and	bx,0ff0h		;Check for cmd E8
	cmp	bx,0e80h
	jnz	NoMTMPanChange
	mov	byte ptr [edi+2],08h
	and	byte ptr [edi+3],0fh
NoMTMPanChange:
	add	eax,3
	add	edi,ChRowSize

	loop	ParseRow
EmptyMTMTrack:
	pop	edi
	pop	ecx
	add	edi,4
	loop	ParseTrack

EmptyMTMPatt:
	pop	ecx
	pop	esi
	add	esi,32*2
	inc	ebp
	loop	ParseMTMPattLoop

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Desc
	mov	edx,GUS_TempBuffPtr	;Load Description
	mov	esi,edx
	mov	edi,edx
	movzx	ecx,MTMComment
	add	edi,ecx
	call	ReadFile

	mov	edx,ecx
ParseMTMDesc:
	mov	ecx,edx
	cmp	ecx,40
	jbe	@@Skip
	mov	ecx,40
@@Skip:
	push	ecx
	rep	movsb
	pop	ecx
	push	ecx
	neg	ecx
	add	ecx,74
	mov	al,0
	rep	stosb
	pop	ecx
	sub	edx,ecx
	jz	@@Ut
	jg	ParseMTMDesc
	neg	edx
	jmp	ParseMTMDesc
@@Ut:
	movzx	eax,MTMComment
	mov	ecx,edi
	sub	ecx,eax
	sub	ecx,GUS_TempBuffPtr

	push	eax
	mov	eax,ecx			;Desc Length
IFE	PLAYER
	mov	[DescTable+12*4],eax	;Len
ENDIF
	mov	ebp,1027
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
IFE	PLAYER
	mov	[DescTable+11*4],eax	;Ptr
ENDIF
	mov	edi,eax
	mov	esi,GUS_TempBuffPtr
	pop	eax
	add	esi,eax
	rep	movsb

	mov	ebp,1037
	call	MemDisAlloc

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Samples

	mov	LSConvert,128
	jmp	LoadTheSamples


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;				ULT Loading
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ULTVersion	db	0
ULTPatt		db	0
ULTFileSize	dd	0
LoadULT:
	call	_Filesize
	mov	ULTFileSize,eax
	mov	LinFreq,0
	call	ClearMod
	mov	Commands,2
	mov	CurrPattLength,64
	call	FixLoadOffset
	mov	edx,GUS_TempBuffPtr	;Load part of Header
	mov	ecx,48
	sub	ULTFileSize,ecx
	call	ReadFile
	mov	FormatVer,AMSVersion	;Store Version
	mov	esi,GUS_TempBuffPtr
	mov	MIDIChannels,0		;No MIDI in an .ULT file
	mov	al,[esi+14]
	sub	al,30h
	mov	ULTVersion,al

	mov	eax,30			;Max 20 bytes
	add	esi,15
	call	ScanLength		;Get length of name
	lea	edi,SongName
	call	CopyString		;Store Name

	movzx	ecx,byte ptr [esi+47-15];Read Song Text
	shl	ecx,5
	mov	MTMComment,cx
	inc	ecx			;Also load NOS

	cmp	ULTVersion,2
	jae	ULTVersion_1
	mov	ecx,1
ULTVersion_1:
	mov	edx,GUS_TempBuffPtr
	sub	ULTFileSize,ecx
	call	ReadFile

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Desc
	cmp	ULTVersion,2
	jb	ULTVersion_11
	push	ecx
	mov	edi,edx
	mov	esi,edx
	add	edi,ecx


	mov	edx,ecx
	dec	edx
ParseULTDesc:
	mov	ecx,edx
	cmp	ecx,32
	jbe	@@Skip
	mov	ecx,32
@@Skip:
	push	ecx
	rep	movsb
	pop	ecx
	push	ecx
	neg	ecx
	add	ecx,74
	mov	al,0
	rep	stosb
	pop	ecx
	sub	edx,ecx
	jz	@@Ut
	jg	ParseULTDesc
	neg	edx
	jmp	ParseULTDesc
@@Ut:
	movzx	eax,MTMComment
	mov	ecx,edi
	sub	ecx,eax
	sub	ecx,GUS_TempBuffPtr

	push	eax
	mov	eax,ecx			;Desc Length
IFE	PLAYER
	mov	[DescTable+12*4],eax	;Len
ENDIF
	mov	ebp,1027
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
IFE	PLAYER
	mov	[DescTable+11*4],eax	;Ptr
ENDIF
	mov	edi,eax
	mov	esi,GUS_TempBuffPtr
	pop	eax
	add	esi,eax
	inc	esi
	rep	movsb
	pop	ecx
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ	Sample info
ULTVersion_11:

	mov	esi,GUS_TempBuffPtr
	movzx	ecx,byte ptr [esi+ecx-1];Get NOS
	mov	Samples,cl
	mov	eax,64
	cmp	ULTVersion,4
	jnz	ULTVersion_2
	add	eax,2
ULTVersion_2:
	mul	ecx
	mov	ecx,eax
	mov	edx,esi			;Read Sample Struct
	sub	ULTFileSize,ecx
	call	ReadFile


	movzx	eax,Samples
	mov	ebx,30
	mul	ebx
	mov	ebp,1029		;Allocate Inst. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstNamesPtr,eax

	movzx	eax,Samples
	shl	eax,4
	mov	ebx,22
	mul	ebx
	mov	ebp,1028		;Allocate Samp. names
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	SampleNamesPtr,eax

	movzx	eax,Samples
	mov	ebx,716
	mul	ebx
	mov	ebp,1034		;Allocate Inst. Info
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	InstrumentInfo,eax


	movzx	ecx,Samples
	mov	ebp,16
ULTSampLoop:
	push	ecx
	mov	eax,30
	mov	ebx,ebp
	shr	ebx,4
	dec	ebx
	mul	ebx
	mov	edi,eax
	add	edi,InstNamesPtr
	mov	eax,30			;Copy 30 bytes
	call	ScanLength		;Get Length of name
	call	CopyString		;Store Name

	mov	cl,[esi+61]		;8 or 16 bits
	and	cl,28			;Isolate 16 bits + looping
	mov	[VoiceControl+ebp],cl	;Save Control
	shr	cl,2			;to get 16 bits bit
	and	cl,1

	mov	eax,[esi+56]		;Length of sample
	sub	eax,[esi+52]
	mov	[SampleOffsetEnd+ebp*4],eax ;Store End of sample

	shl	eax,cl
	sub	ULTFileSize,eax

	mov	eax,[esi+44]		;Repeat Point
	mov	[LoopStart+ebp*4],eax	;Store Repeat Start

	mov	eax,[esi+48]		;Repeat end
	cmp	eax,[SampleOffsetEnd+ebp*4]
	jbe	NoULTBelowed
	mov	eax,[SampleOffsetEnd+ebp*4]
NoULTBelowed:
	mov	[LoopEnd+ebp*4],eax	;Store Repeat End

;	mov	al,[esi+34]		;FineTune
;	and	al,0fh			;Clear PanPot for safety
;	mov	[FineTunes+ebp],al	;Store FineTune

	mov	al,[esi+60]		;Volume
	shr	al,1
	mov	[Volumes+ebp],al	;Store Volume

	mov	[SampleRates+ebp*2],8363
	cmp	ULTVersion,4
	jnz     ULTVersion_3
	mov	ax,[esi+64]		;C2 Freq
	mov	[SampleRates+ebp*2],ax
ULTVersion_3:

	add	esi,64
	cmp	ULTVersion,4
	jnz     ULTVersion_4
	add	esi,2
ULTVersion_4:
	add	ebp,16
	pop	ecx
	loop	ULTSampLoop

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PatternOrder

	mov	edx,GUS_TempBuffPtr	;Load Pattern Order
	mov	esi,edx
	mov	ecx,256+2		;Also read NOC and NOP
	sub	ULTFileSize,ecx
	call	ReadFile
	mov	al,[esi+256]
	inc	al
	mov	Channels,al
	mov	al,[esi+257]
	inc	al
	mov	ULTPatt,al
	mov	Positions,0
	xor	ecx,ecx
ULTCheckPos:
	cmp	byte ptr [esi+ecx],-1
	jz	ULTFound
	inc	Positions
	inc	ecx
	cmp	ecx,257
	jnz	ULTCheckPos
ULTFound:

	movzx	eax,Positions
	shl	eax,1
	mov	ebp,1030		;Allocate Positions
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	PatternOrderPtr,eax

	mov	edi,eax			;PatternOrder
	xor	eax,eax
ULTPatternLoop:
	lodsb
	stosw
	loop	ULTPatternLoop

	cmp	ULTVersion,3
	jb	ULTVersion_5
	movzx	ecx,Channels
	mov	edx,GUS_TempBuffPtr
	sub	ULTFileSize,ecx
	call	ReadFile

	xor	ecx,ecx
@@Again:
	shl	byte ptr [edx+ecx],4
	inc	ecx
	cmp	cl,Channels
	jnz	@@Again

	push	esi
	lea	edi,PanPosition
	movzx	ecx,Channels
	rep	movsb
	pop	esi

	lea	edi,CurrentChannelPanPot
	movzx	ecx,Channels
	rep	movsb
	mov	EnvPanCheck,-1

ULTVersion_5:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Patterns

	mov	ecx,ULTFileSize		;PattSize
	mov	eax,ecx
	mov	ebp,1037
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	TempBufferPtr,eax
	mov	esi,eax
	mov	edx,eax
	call	ReadFile

	mov	cl,Channels
	dec	cl
	mov	ChanCMD,cl
	or	ChanCMD,01000000b
	call	GetPatternSize
	call	GetRowSize


	movzx	ecx,ULTPatt		;Alloc All Patterns
	xor	ebp,ebp
AllocULTPatt:
	mov	eax,PatternSize2
	add	eax,12
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem

	mov	edi,[AllocTable+ebp*8]
	mov	byte ptr [edi+10],63	;Pattern Length
	mov	al,ChanCMD
	mov	byte ptr [edi+11],al	;Pattern Width

	inc	ebp
	loop	AllocULTPatt

	xor	ebx,ebx
	movzx	ecx,Channels
ParseULTChanLoop:
	push	ecx
	push	ebx

	movzx	ecx,UltPatt
	xor	ebp,ebp
ParseULTPattLoop:
	push	ecx

	mov	edi,[AllocTable+ebp*8]
	add	edi,12
	add	edi,ebx			;Add to right Channel

	mov	edx,64
ParseULTRowLoop:
	mov	ecx,1
	cmp	byte ptr [esi],0fch
	jnz	NoULTRepeat
	lodsb				;Dummy
	lodsb
	movzx	ecx,al
NoULTRepeat:
	mov	al,[esi]
	cmp	al,0
	jz	NoULTAdd
	add	al,24+1
NoULTAdd:
	mov	[edi],al		;Note

	mov	al,[esi+1]		;Samp Nr
	mov	[edi+1],al

	mov	al,[esi+2]		;Effects
	mov	ah,al
	and	al,00fh
	shr	ah,4
	mov	[edi+2],ah
	mov	[edi+4],al

	mov	ax,[esi+3]
	mov	[edi+3],ah
	mov	[edi+5],al

	push	esi
	cmp	byte ptr [edi+2],0bh		;Convert Pan
	jnz	ResumeULT3
	mov	byte ptr [edi+2],08h
ResumeULT3:
	cmp	byte ptr [edi+4],0bh
	jnz	ResumeULT4
	mov	byte ptr [edi+4],08h
ResumeULT4:
	cmp	byte ptr [edi+2],0ch		;Convert Vol
	jnz	ResumeULT5
	shr	byte ptr [edi+3],1
ResumeULT5:
	cmp	byte ptr [edi+4],0ch
	jnz	ResumeULT6
	shr	byte ptr [edi+5],1
ResumeULT6:
	mov	ax,word ptr [edi+2]		;Convert Patt Delay
	mov	si,ax
	and	ax,0f00fh
	cmp	ax,0800eh
	jnz	ResumeULT7
	and	si,00f00h
	or	si,0e00eh
	mov	word ptr [edi+2],si
ResumeULT7:
	mov	ax,word ptr [edi+4]
	mov	si,ax
	and	ax,0f00fh
	cmp	ax,0800eh
	jnz	ResumeULT8
	and	si,00f00h
	or	si,0e00eh
	mov	word ptr [edi+4],si
ResumeULT8:
	mov	esi,edi
	add	esi,2
	cmp	byte ptr [edi+2],5
	jnz	ResumeULT1
	call	FixULTCmd5
ResumeULT1:
	mov	esi,edi				;Convert Special Commands (5)
	add	esi,4
	cmp	byte ptr [edi+4],5
	jnz	ResumeULT2
	call	FixULTCmd5
ResumeULT2:
	pop	esi

	add	edi,ChRowSize
	dec	edx
	loop	NoULTRepeat

	add	esi,5
	cmp	edx,0
	jnz	ParseULTRowLoop

	pop	ecx
	inc	ebp
	loop	ParseULTPattLoop

	pop	ebx
	pop	ecx
	add	ebx,RowSize
	loop	ParseULTChanLoop
	jmp	LoadULTSamples




FixULTCmd5:
	cmp	byte ptr [esi+1],1
	jnz	@@Skip1
	mov	word ptr [esi],800eh
	ret
@@Skip1:
	cmp	byte ptr [esi+1],2
	jnz	@@Skip2
	mov	word ptr [esi],0110h
	ret
@@Skip2:
	cmp	byte ptr [esi+1],0ch
	jnz	@@Skip3
	mov	word ptr [esi],800eh
@@Skip3:
	ret


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Samples
LoadULTSamples:

	mov	ebp,1037
	call	MemDisAlloc

	mov	LSConvert,0
	jmp	LoadTheSamples






ENDIF
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GRR_Channels	db	0
GRR_PatternSize dd	0
WildCardXP_	db	'XP',0
CheckFileFormat Proc	near
	pushad
	call	FixLoadOffset
	lea	edx,DetectBuffer
	mov	ecx,144
	call	_ReadFile
	mov	ax,ReadErr
	jc	ErrorHandler

IFE LITEVERSION
	mov	TypeFile,0ah
	mov	edi,-1				;Check .AMS
	mov	ecx,7
CheckLoop2:
	inc	edi
	mov	al,byte ptr [Extreme+edi]
	cmp	al,byte ptr [DetectBuffer+edi]
	loopz	CheckLoop2
	jz	FormatDetermined
ENDIF

	mov	TypeFile,0eh
	mov	edi,-1				;Check .AMS v2.0
	mov	ecx,7
CheckLoop4:
	inc	edi
	mov	al,byte ptr [AMShdr+edi]
	cmp	al,byte ptr [DetectBuffer+edi]
	loopz	CheckLoop4
	jz	FormatDetermined
	mov	TypeFile,0

IFE LITEVERSION
	mov	TypeFile,40h
	mov	edi,-1				;Check .ACS
	mov	ecx,7
@@CheckLoop4:
	inc	edi
	mov	al,byte ptr [ACShdr+edi]
	cmp	al,byte ptr [DetectBuffer+edi]
	loopz	@@CheckLoop4
	jz	FormatDetermined

	mov	TypeFile,41h
	mov	edi,-1				;Check .APS
	mov	ecx,7
@@CheckLoop5:
	inc	edi
	mov	al,byte ptr [APShdr+edi]
	cmp	al,byte ptr [DetectBuffer+edi]
	loopz	@@CheckLoop5
	jz	FormatDetermined

	mov	TypeFile,42h
	mov	edi,-1				;Check .ASE
	mov	ecx,7
@@CheckLoop7:
	inc	edi
	mov	al,byte ptr [ASEhdr+edi]
	cmp	al,byte ptr [DetectBuffer+edi]
	loopz	@@CheckLoop7
	jz	FormatDetermined

	mov	TypeFile,43h
	mov	edi,ModNamePtr			;Check .XT
@@Again:
	cmp	byte ptr [edi],'.'
	jz	@@Found
	cmp	byte ptr [edi],0
	jz	NotAnXPFile
	inc	edi
	jmp	@@Again
@@Found:
	mov	ecx,3
	mov	edx,-1
	mov	esi,edi
@@CheckLoop6:
	inc	edi
	inc	edx
	mov	al,byte ptr [WildCardXP_+edx]
	cmp	al,byte ptr [edi]
	loopz	@@CheckLoop6
	jz	FormatDetermined
NotAnXPFile:


	mov	TypeFile,0ch			;Check S3M
	cmp	Dword ptr [DetectBuffer+2ch],'MRCS'
	jz	FormatDetermined

	mov	TypeFile,03h
	cmp	Dword ptr [DetectBuffer+4ch],'SRCS'
	jz	FormatDetermined

	mov	TypeFile,04h			;Check .IFF
	lea	edi,DetectBuffer
	cmp	[edi],'MROF'
	jnz	NotAnIFFSample
	cmp	[edi+8],'XVS8'
	jz	FormatDetermined
NotAnIFFSample:

	mov	TypeFile,0dh			;Check .STM
	lea	edi,DetectBuffer
	cmp	[edi+20],'rcS!'
	jnz	NotAnSTMFile
	cmp	[edi+24],'!mae'
	jnz	NotAnSTMFile
	cmp	byte ptr [edi+29],2
	jz	FormatDetermined
NotAnSTMFile:

	mov	TypeFile,05h			;Check XI
	mov	edi,-1
	mov	ecx,21
CheckXI:
	inc	edi
	mov	al,[DetectBuffer+edi]
	cmp	al,[XI_Determ+edi]
	loopz	CheckXI
	jz	FormatDetermined

	mov	TypeFile,06h			;Check .AIS
	mov	edi,-1
	mov	ecx,7
CheckLoop5:
	inc	edi
	mov	al,byte ptr [AIShdr+edi]
	cmp	al,byte ptr [DetectBuffer+edi]
	loopz	CheckLoop5
	jz	FormatDetermined

	mov	TypeFile,0fh
	mov	edi,-1				;Check XM
	mov	ecx,17
CheckXM:
	inc	edi
	mov	al,[DetectBuffer+edi]
	cmp	al,[XM_Determ+edi]
	loopz	CheckXM
	jz	FormatDetermined

	mov	TypeFile,7			;Check WAV
	cmp	dword ptr [DetectBuffer+edi],'FFIR'
	jnz	CheckThePAT
	cmp	dword ptr [DetectBuffer+edi+8],'EVAW'
	jz	FormatDetermined

CheckThePAT:
	mov	TypeFile,08h			;Check PAT
	mov	edi,-1
	mov	ecx,11
CheckPAT:
	inc	edi
	mov	al,[PAT_Determ+edi]
	cmp	al,[DetectBuffer+edi]
	loopz	CheckPAT
	jz	FormatDetermined

CheckTheMTM:					;Check MTM
	mov	TypeFile,10h
	cmp	Dword Ptr [DetectBuffer],'MTM'
	jz	FormatDetermined

CheckTheULT:					;Check ULT
	mov	TypeFile,11h
	mov	edi,-1
	mov	ecx,14
CheckULT:
	inc	edi
	mov	al,[ULT_Determ+edi]
	cmp	al,[DetectBuffer+edi]
	loopz	CheckULT
	jz	FormatDetermined

CheckMOD:
	mov	TypeFile,0bh
	mov	eax,0
	mov	bl,2
	call	_LseekFile
	sub	eax,LoadOffset
	cmp	eax,2108
	jb	AbsolutelyNoMOD

	mov	eax,1080			;Check .MOD
	add	eax,LoadOffset
	mov	bl,0
	call	_LseekFile

	mov	ax,SeekErr
	jc	ErrorHandler
	lea	edx,DetectBuffer
	mov	ecx,4
	call	ReadFile

	mov	ecx,8
	xor	ebp,ebp
CheckLoop3:
	push	ecx ebp
	xor	edi,edi
	mov	ecx,4
CheckLoop:
	mov	al,byte ptr [Mods+ebp]
	cmp	al,byte ptr [DetectBuffer+edi]
	jnz	NoMOD
	inc	edi
	inc	ebp
	loop	CheckLoop
	pop	ebp ecx
	jmp	ModFormatDetermined
NoMOD:
	pop	ebp ecx
	add	ebp,4
	loop	CheckLoop3
	mov	eax,dword ptr [DetectBuffer]
	shr	eax,8
	cmp	eax,'NHC'
	jz	ModFormatDetermined
	shr	eax,8
	cmp	eax,'HC'
	jz	ModFormatDetermined
AbsolutelyNoMOD:
	mov	TypeFile,0
	jmp	FormatDetermined

ModFormatDetermined:

	mov	GRR_Channels,8		;Get # of Channels
	mov	GRR_PatternSize,2048
	cmp	dword ptr [DetectBuffer],'ATCO'
	jz	GotChannels
	cmp	dword ptr [DetectBuffer],'8TLF'
	jz	GotChannels
	mov	GRR_Channels,4
	mov	GRR_PatternSize,1024
	cmp	dword ptr [DetectBuffer],'.K.M'
	jz	GotChannels
	cmp	dword ptr [DetectBuffer],'!K!M'
	jz	GotChannels
	cmp	dword ptr [DetectBuffer],'4TLF'
	jz	GotChannels
	mov	GRR_Channels,1
	mov	GRR_PatternSize,256
	cmp	dword ptr [DetectBuffer],'1ZDT'
	jz	GotChannels
	mov	GRR_Channels,2
	mov	GRR_PatternSize,512
	cmp	dword ptr [DetectBuffer],'2ZDT'
	jz	GotChannels
	mov	GRR_Channels,3
	mov	GRR_PatternSize,768
	cmp	dword ptr [DetectBuffer],'3ZDT'
	jz	GotChannels
	mov	eax,dword ptr [DetectBuffer]
	cmp	ah,'C'
	jnz	MoreThan9
	shl	ax,8
	mov	al,'0'
MoreThan9:
	movzx	bx,ah
	xor	ah,ah
	sub	ax,'0'
	sub	bx,'0'
	mov	cx,10
	mul	cx
	add	ax,bx
	mov	GRR_Channels,al
	and	eax,0ffffh
	shl	eax,8
	mov	GRR_PatternSize,eax
GotChannels:
ENDIF

FormatDetermined:

	popad
	ret
CheckFileFormat EndP

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			      UnPack sample method 1
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Input:
;	  esi = input offset, points at header
;	  edi = output offset
; Output:
;	  ecx = output size
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
UnPackMethod1	Proc	Near
	pushad
	mov	inputoffset,esi
	mov	outputoffset,edi
					  ;unpacking
	mov	ecx,dword ptr [esi]
	mov	inputsize,ecx
	mov	ecx,dword ptr [esi+4]
	mov	al,byte ptr [esi+8]
	mov	packcharacter,al
	add	esi,9
unpackloop:
	lodsb
	cmp	al,packcharacter
	jz	unpacka
	stosb
	loop	unpackloop
	jmp	endofunpack
unpacka:
	lodsb
	dec	ecx
	cmp	al,0
	jz	putpackcharacter
	push	ecx
	movzx	ecx,al
	lodsb
	rep	stosb
	pop	ecx
	dec	ecx
	loop	unpackloop
	jmp	endofunpack
putpackcharacter:
	mov	al,packcharacter
	stosb
	loop	unpackloop
endofunpack:

	mov	edi,inputoffset 	;clear
	mov	ecx,inputsize
	xor	eax,eax
	mov	edx,ecx
	shr	ecx,2
	rep	stosd
	mov	ecx,edx
	and	ecx,3
	rep	stosb

	mov	edi,inputoffset 		;unpack bit split
	mov	esi,outputoffset
	mov	ebp,edi
	mov	ecx,inputsize
	add	ebp,ecx
	mov	dl,10000000b
bitunpackloop:
	push	ecx

	xor	dh,dh
	lodsb
	mov	ecx,8
bitunpack2:
	mov	bl,al
	and	bl,dl
	add	cl,dh
	ror	bl,cl
	sub	cl,dh
	ror	dl,1
	or	byte ptr [edi],bl
	inc	edi
	cmp	edi,ebp
	jnz	notsettaback
	mov	edi,inputoffset
	inc	dh
notsettaback:
	loop	bitunpack2
	mov	cl,dh
	ror	dl,cl

	pop	ecx
	loop	bitunpackloop

						;delta unpack
	mov	esi,inputoffset
	mov	edi,outputoffset
	mov	ecx,inputsize
	xor	bl,bl
deltaunpack:
	lodsb
	cmp	al,128
	jz	notnegative
	test	al,10000000b
	jz	notnegative
	and	al,01111111b
	neg	al
notnegative:
	sub	bl,al
	mov	byte ptr [edi],bl
	inc	edi
	loop	deltaunpack

	sub	edi,outputoffset
	mov	inputoffset,edi
	popad
	mov	ecx,inputoffset
	ret
UnPackMethod1	Endp

ReadFile:
	push	eax ecx ebx
	call	_ReadFile
	mov	ebx,eax
	mov	ax,ReadErr
	jc	ErrorHandler
	cmp	ecx,ebx
	jnz	FileCorrupt
ContLoad:
	pop	ebx ecx eax
	ret
FileCorrupt:
;		mov	esp,StackSave
;		jmp	QuitLoad
	mov	ax,FileErrorErr
	call	AskContLoad
	jc	ErrorHandler
	jmp	ContLoad


IFE LITEVERSION
;Input:  edx = Offset
;	 ecx = packed length
;Output: eax = unpacked length
ScanOldDescLength	Proc	Near
	cmp	ecx,0
	jz	_ret
	push	ebx ecx edx
	xor	eax,eax
ScanLoopen:
	mov	bl,[edx]
	inc	edx
	bt	bx,7
	jc	fastscan
	inc	eax
	jmp	endscan
fastscan:
	and	ebx,7fh
	add	eax,ebx
endscan:
	loop	ScanLoopen
	push	eax
	mov	ebx,76/2
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	pop	eax
	sub	eax,ebx
	pop	edx ecx ebx
	cmp	eax,74
	jae	_ret
	mov	eax,74
	ret
ScanOldDescLength	Endp

;-------------------------------------
;InPuts:
;	    esi = Source buffer
;	    edi = Destination buffer
;	    ecx = Packed size
;
;OutPut:    ecx = Unpacked size
;	  carry = (0=went fine, 1=error)
;-------------------------------------
UnPackOld	Proc	Near
	cmp	ecx,0
	jz	_ret

	push	eax ebx ebp edi esi
	xor	ebp,ebp
UnPackOldLoop:
	lodsb
	bt	ax,7
	jc	unpackspace
	cmp	ebp,74
	jz	notta
	cmp	ebp,75
	jz	notta
	stosb
notta:
	inc	ebp
	cmp	ebp,76
	jnz	noziroa
	xor	ebp,ebp
noziroa:
	jmp	nextbyte
unpackspace:
	push	ecx
	and	al,7fh
	movzx	ecx,al
	mov	al,' '
spaceloppan:
	cmp	ebp,74
	jz	notta2
	cmp	ebp,75
	jz	notta2
	stosb
notta2:
	inc	ebp
	cmp	ebp,76
	jnz	noziroa2
	xor	ebp,ebp
noziroa2:
	loop	spaceloppan
	pop	ecx
nextbyte:
	loop	UnPackOldLoop
	mov	ecx,edi
	pop	esi edi ebp ebx eax
	sub	ecx,edi
	ret
UnPackOld	Endp
ENDIF
;*******************************************************************************
;			    Extreme unpacker v1.0
;*******************************************************************************
;
;InPuts:
;	    esi = Source buffer
;	    edi = Destination buffer
;
;OutPut:    ecx = Unpacked size
;	  carry = (0=went fine, 1=error)
;
;*******************************************************************************
UnPackCharacter 	equ	255
UnPackingVersion	equ	0
UnPackingJumps		dd	ReadData
			dd	RLEunpack
PackedSize		dd	0
PackHeaderSize		db	11
ExtremeUnpacker Proc	Near
	pushad

;--------------------------------------------------------- Header
	mov	ebp,edi
	movzx	ebx,Byte Ptr [esi+8]
	cmp	bl,UnPackingVersion
	ja	UnPackError
	mov	eax,[esi]
	movzx	ebx,[PackHeaderSize+ebx]
	sub	eax,ebx
	mov	PackedSize,eax
	movzx	edx,Byte Ptr [esi+10]
	add	esi,ebx
	jmp	[UnPackingJumps+edx*4]

;--------------------------------------------------------- RLEunpack
ReadData:
	jmp	QuitUnpack

;--------------------------------------------------------- RLEunpack
RLEunpack:
	lodsb
	cmp	al,UnPackCharacter
	jz	UnpackRLE
	stosb
	dec	PackedSize
	jnz	RLEunpack
	jmp	QuitUnpack
UnpackRLE:
	lodsb
	cmp	al,UnpackCharacter
	jnz	UnpackNow
	stosb
	dec	PackedSize
	jnz	RLEunpack
	jmp	QuitUnpack
UnPackNow:
	movzx	ecx,byte ptr [esi]
	inc	esi
	rep	stosb
	sub	PackedSize,3
	jg	RLEunpack
	jmp	QuitUnpack

;--------------------------------------------------------- Quit Unpacking
QuitUnpack:
	sub	edi,ebp
	mov	PackedSize,edi
	popad
	mov	ecx,PackedSize
	clc
	ret
UnPackError:
	popad
	stc
	ret
ExtremeUnpacker 	Endp

FixLoadOffset	Proc	Near
	pushad
	mov	eax,LoadOffset
	cmp	eax,0
	jz	ResetFP
	neg	eax
	mov	bl,2
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler
	popad
	ret
ResetFP:
	xor	eax,eax
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler
	popad
	ret

FixLoadOffset	EndP
