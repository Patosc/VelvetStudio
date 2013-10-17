
CheckType	db	100 dup(0)	  ;Temp Buffer for Type determination
DiscFree	dd	0
CurrentWildCard dd	0
ShowAllFiles	db	0
WildCardAll	db	'*.*',0,0,0  ;0
WildCardAMS	db	'*.AMS',0    ;6
WildCardMOD	db	'*.MOD',0    ;12
WildCardSMP	db	'*.SMP',0    ;18
WildCardIFF	db	'*.IFF',0    ;24
WildCardS3M	db	'*.S3M',0    ;30
WildCardS3I	db	'*.S3I',0    ;36
WildCardSTM	db	'*.STM',0    ;42
WildCardXI	db	'*.XI',0,0   ;48
WildCardAIS	db	'*.AIS',0    ;54
WildCardXM	db	'*.XM',0,0   ;60
WildCardWAV	db	'*.WAV',0    ;66
WildCardPAT	db	'*.PAT',0    ;72
		db	6 dup(0)     ;78
		db	6 dup(0)     ;84
		db	6 dup(0)     ;90
		db	6 dup(0)     ;96
WildCardACS	db	'*.ACS',0    ;102
WildCardAPS	db	'*.APS',0    ;108
WildCardXP	db	'*.XP',0,0   ;114
WildCardASE	db	'*.ASE',0    ;120
WildCardMTM	db	'*.MTM',0    ;126
WildCardULT	db	'*.ULT',0    ;132

WildCardMix	dd	WildCardSong,WildCardInst,WildCardSamp,WildCardPatt
WildCardSong	db	'*.AMS',0,'*.MOD',0,'*.S3M',0,'*.STM',0,'*.XM',0,0,'*.MTM',0,'*.ULT',0,255
WildCardInst	db	'*.AIS',0,'*.PAT',0,'*.XI',0,0,255
WildCardSamp	db	'*.ASE',0,'*.SMP',0,'*.IFF',0,'*.S3I',0,'*.WAV',0,255
WildCardPatt	db	'*.ACS',0,'*.APS',0,'*.XP',0,0,255

Mods		db	'TDZ1TDZ2TDZ3M.K.M!K!FLT4FLT8OCTA'
Drive		db	'[ :]'
Drive2		db	'<Drive>'
DontReadFileList db	0	;Set to 0 if to read the FileList
CurrentPathPtr	dd	0
CurrPathTable	dd	CurrPath0,CurrPath1,CurrPath2,CurrPath3,CurrPath4,CurrPath5,CurrPath6,CurrPath7,CurrPath8,CurrPath9,CurrPath10,CurrPath11,CurrPath12,CurrPath13,CurrPath14,CurrPath15,CurrPath16,CurrPath17,CurrPath18,CurrPath19,CurrPath20,CurrPath21,CurrPath22
CurrPath0	db	'P:\',64+12 dup(0),'UNTITLED.*',0,0,0	;Current Paths
CurrPath1	db	'P:\',64+12  dup(0),'UNTITLED.AMS',0
CurrPath2	db	'P:\',64+12  dup(0),'UNTITLED.MOD',0
CurrPath3	db	'P:\',64+12  dup(0),'UNTITLED.SMP',0
CurrPath4	db	'P:\',64+12  dup(0),'UNTITLED.IFF',0
CurrPath5	db	'P:\',64+12  dup(0),'UNTITLED.S3M',0
CurrPath6	db	'P:\',64+12  dup(0),'UNTITLED.S3I',0
CurrPath7	db	'P:\',64+12  dup(0),'UNTITLED.STM',0
CurrPath8	db	'P:\',64+12  dup(0),'UNTITLED.XI',0,0
CurrPath9	db	'P:\',64+12  dup(0),'UNTITLED.AIS',0
CurrPath10	db	'P:\',64+12  dup(0),'UNTITLED.XM',0,0
CurrPath11	db	'P:\',64+12  dup(0),'UNTITLED.WAV',0
CurrPath12	db	'P:\',64+12  dup(0),'UNTITLED.PAT',0
CurrPath13	db	'P:\',64+12  dup(0),'UNTITLED.*',0,0,0
CurrPath14	db	'P:\',64+12  dup(0),'UNTITLED.*',0,0,0
CurrPath15	db	'P:\',64+12  dup(0),'UNTITLED.*',0,0,0
CurrPath16	db	'P:\',64+12  dup(0),'UNTITLED.*',0,0,0
CurrPath17	db	'P:\',64+12  dup(0),'UNTITLED.ACS',0
CurrPath18	db	'P:\',64+12  dup(0),'UNTITLED.APS',0
CurrPath19	db	'P:\',64+12  dup(0),'UNTITLED.XP',0,0
CurrPath20	db	'P:\',64+12  dup(0),'UNTITLED.ASE',0
CurrPath21	db	'P:\',64+12  dup(0),'UNTITLED.MTM',0,0
CurrPath22	db	'P:\',64+12  dup(0),'UNTITLED.ULT',0

		;Change in GETDRIVEPATH if you add more paths

;Enable  equ	 00001001b
;Disable equ	 00001011b

XI_Determ	db	'Extended Instrument: '
XM_Determ	db	'Extended Module: '
PAT_Determ	db	'GF1PATCH110',0
ULT_Determ	db	'MAS_UTrack_V00'

NoSaveAllowed	db	"Sorry, but saving that format isn't supported$"
Only20Pos	db	"Sorry, but only 20 positions will be saved in@this unregistered version$"

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;			       Disk Options Start
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
; Calls: None
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�

SpecialSet	db	0
CurrentFileType 	dd	0
DiskOpPictureTBL	dd	DiskOpPictureSong,DiskOpPictureInst,DiskOpPictureSamp,DiskOpPicturePatt
InitialSpecial		db	0
DiskOpStart3:
	pushad
	cmp	menu_upperscreen,3
	jnz	afterpush
	jmp	DiskOpExit2
DiskOpStart	Proc	Near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	diskendstart
AfterPush:

	mov	InitialSpecial,1		;To avoid a bug...
	mov	SongFinished,0
	mov	menu_upperscreen,3
	call	menuhandler

	mov	bl,0
	call	ReleaseLastButton

	mov	eax,CurrentFileType
	mov	esi,[DiskOpPictureTBL+eax*4]
	mov     DrawSpecial,1
	call    DrawPopUp

	movzx	esi,[CurrentWildTBL+eax]
	mov     eax,[Wild_TBL+eax*4]
	movzx   esi,byte ptr [esi+eax+1]
	mov	CurrentWildCard,esi

 	call	PressWildButton

	mov	SpecialSet,1
	mov	MouseB,1
	call	SetDrivePath2
	mov	MouseB,0
	mov	SpecialSet,0

	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	bl,LoadSampleConvert
	mov	ButtonX1,580
	mov	ButtonY1,55
	mov	ButtonX2,592
	mov	ButtonY2,66
	call	Buttonupdown

	mov	bl,LoadFTLoop
	mov	ButtonX1,580
	mov	ButtonY1,68
	mov	ButtonX2,592
	mov	ButtonY2,79
	call	Buttonupdown

	mov	bl,PackingByte
	xor	bx,1
	mov	ButtonX1,580
	mov	ButtonY1,81
	mov	ButtonX2,592
	mov	ButtonY2,92
	call	Buttonupdown

	mov	bl,ShowRealModName
	xor	bx,1
	mov	ButtonX1,580
	mov	ButtonY1,94
	mov	ButtonX2,592
	mov	ButtonY2,105
	call	Buttonupdown

	mov	bl,AllowAutoLoad
	xor	bx,1
	mov	ButtonX1,580
	mov	ButtonY1,107
	mov	ButtonX2,592
	mov	ButtonY2,118
	call	Buttonupdown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1

	cmp	DontReadFileList,1
	jz	DontRead
	cmp	DontReadFileList,2
	jz	DontChap
	mov	FileListStart,1
DontChap:

	call	GetFileList

	mov	DontReadFileList,1
	call	GetCurrPath

DontRead:

	mov	OldCurrentFileName,-1
	cmp	AutoName,0
	jz	NoAutoName
	call	Getname2
NoAutoName:

diskendstart:
	popad
	ret
DiskOpStart2:
	pushad
	jmp	afterpush
DiskOpStart	Endp
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;			       Disk Options Exit
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
; Calls: None
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
DiskOpExit2:
	mov	menu_upperscreen,0
	call	menuhandler
	call	UpdateChannelInfo

diskendexit:

	popad
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;FileList is built up:
;12 bytes - Real FileName
;30 bytes - ModName/SampleName
; 6 bytes - FileLength
; 1 byte  - FileType
;	    0 - FT raw Sample
;	    1 - Directory
;	    2 - Drive
;	    3 - S3I
;	    4 - IFF
;	    5 - XI
;	    6 - AIS
;	    7 - WAV
;	    8 - PAT
;
;	  0ah - .AMS
;	  0bh - .MOD
;	  0ch - .S3M
;	  0dh - .STM
;	  0eh - .AMS v2.0
;	  0fh - .XM
;	  10h - .MTM
;	  11h - .ULT
;	  40h - .ACS
;	  41h - .APS
;	  42h - .ASE
;	  43h - .XP
;	  77h - Undefined
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

CurrentFileName dw	0	;FileName to put first on screen
NrOfFiles	dw	0
FileListOffset	dd	0	;Offset in FileList
FileListStart	db	0
GetFileList	Proc	Near
	mov	ax,CurrentFileName
	mov	OldCurrentFileName,ax
	call	MouseHourGlass

	call	GetCurrPath
	mov	ax,3600h	;Get DiscSize
	mov	dl,0
	int	21h
	movzx	eax,ax
	movzx	ebx,bx
	movzx	ecx,cx
	mul	ebx
	mul	ecx
	mov	DiscFree,eax

	Pushad
	mov	ShowAllFiles,0
	mov	NrOfFiles,0
	mov	edi,FileListPtr
	mov	FileListOffset,edi
	movzx	eax,MaxFiles		;Clear FileList
	mov	ebx,49
	mul	ebx
	mov	ecx,eax
	xor	al,al
	rep	stosb
;----------------------------------------------- Drives
	mov	ecx,28
	xor	eax,eax
DriveLoopen:
	push	ecx
	cmp	[Drives+eax],0fh
	jz	NoValidDrive
	mov	ecx,66h
	cmp	al,1
	ja	_2Discs
	cmp	NrOfDiscDrives,2
	jz	_2Discs
	cmp	[Drives+eax],0
	jnz	_2Discs
	cmp	al,PhantomDrive
	jnz	NoValidDrive
_2Discs:
	call	MoveNameToList
NoValidDrive:
	inc	eax
	pop	ecx
	loop	DriveLoopen

	mov	ecx,FileListOffset
	mov	SortOffset,ecx
	movzx	ecx,NrOfFiles
	mov	NrOfSorts,ecx
;----------------------------------------------- Directories

	mov	al,4eh
GetNextDirectory:
	mov	ecx,10h
	lea	edi,WildCardAll
	lea	edx,ModName
	call	_findfile
	jc	NoMoreDirectorys
;
;	pushad
;	mov	esi,_DTA
;	mov	ah,0fh
;	move	edi,0a0000h+3*80+10
;	mov	cl,40
;	call	PrintText
;	call	waitkey
;	popad
;
	and	cx,10h			;Search for Directorys Only
	jz	NotADirectory
	call	MoveNameToList
NotADirectory:
	mov	ax,MaxFiles
	cmp	ax,NrOfFiles
	jnz	EvenMoreFiles
	lea	esi,FileLimit
	call	MouseArrow
	mov	Menu_Popup,1
	call	PopUpHandler
	call	MouseHourGlass
;	mov	bl,0
;	call	ReleaseLastButton
	jmp	NoMoreFiles;Directorys
EvenMoreFiles:
	mov	al,4fh
	jmp	GetNextDirectory

;----------------------------------------------- Sort Directories
NoMoreDirectorys:

	movzx	ecx,NrOfFiles
	sub	ecx,NrOfSorts
	call	SortFileList
	mov	ecx,FileListOffset
	mov	SortOffset,ecx
	movzx	ecx,NrOfFiles
	mov	NrOfSorts,ecx

;----------------------------------------------- Files
	cmp	CurrentWildCard,78
	jb	OrdinaryStuff
	cmp	CurrentWildCard,96
	ja	OrdinaryStuff
	mov	ShowAllFiles,1
	mov	eax,CurrentWildCard
	sub	eax,78
	mov	ebx,6
	xor	edx,edx
	div	ebx
	mov	edi,[WildCardMix+eax*4]
	mov	al,4eh
	jmp	GetNextFileName
OrdinaryStuff:
	mov	al,4eh
	lea	edi,WildCardAll
	add	edi,CurrentWildCard
GetNextFileName:
	mov	ecx,0			 ;Dont Search for Directorys
	lea	edx,ModName
	cmp	byte ptr [edi],255
	jz	OrdinaryStuff2
	call	_findfile
	jc	NoMoreFiles

	call	MoveNameToList
	mov	ax,MaxFiles
	cmp	ax,NrOfFiles
	jnz	EvenMoreFiles2
	lea	esi,FileLimit
	call	MouseArrow
	mov	Menu_Popup,1
	call	PopupHandler
	call	MouseHourGlass
;	mov	bl,0
;	call	ReleaseLastButton
	jmp	NoMoreFiles
EvenMoreFiles2:
	mov	al,4fh
	jmp	GetNextFileName

;----------------------------------------------- Sort Files
NoMoreFiles:

	cmp	ShowAllFiles,0
	jz	OrdinaryStuff2
	add	edi,6
	mov	al,4eh
	cmp	SortType,0
	jz	GetNextFileName
	pushad
	movzx	ecx,NrOfFiles
	sub	ecx,NrOfSorts
	call	SortFileList
	mov	ecx,FileListOffset
	mov	SortOffset,ecx
	movzx	ecx,NrOfFiles
	mov	NrOfSorts,ecx
	popad
	jmp	GetNextFileName

OrdinaryStuff2:
	movzx	ecx,NrOfFiles
	sub	ecx,NrOfSorts
	call	SortFileList
	movzx	eax,NrOfFiles
	mov	Dword Ptr [DragBarTable+4*24+6],eax  ;Max Pos
	Popad

	mov	edi,SaveName
	mov	ecx,12
GetExtension:
	cmp	byte ptr [edi],'.'
	jz	GotADot
	cmp	byte ptr [edi],0
	jz	GotADot
	inc	edi
	loop	GetExtension
GotADot:
	lea	esi,WildCardAll+1
	add	esi,CurrentWildCard
	mov	ecx,4
	rep	movsb

	call	GetCurrPath

;	call	PauseMusic
;	mov	ecx,255
;TLoop:	int	8h
;	loop	TLoop

	call	MouseArrow
;	call	UnPauseMusic

	cmp	FileListStart,0
	jz	Skipss
	mov	CurrentFileName,0
Skipss:
	cmp	CurrentFileName,0
	jz	SkipFixFileList
	mov	ax,CurrentFileName
	add	ax,12
	cmp	ax,NrOfFiles
	jbe	SkipFixFileList
	mov	ax,NrOfFiles
	sub	ax,12
	jg	NoNegg
	mov	ax,0
NoNegg:
	mov	CurrentFileName,ax
SkipFixFileList:
	Ret
GetFileList  EndP

MoveNameToList	   Proc    Near
	Pushad
	lea	esi,ModName
	mov	edi,FileListOffset
	cmp	cx,10h
	jz	A_Directory
	cmp	cx,66h
	jnz	NoDir		;Indicate Drive
	mov	byte ptr [edi+48],2
	lea	esi,Drive
	mov	ecx,4
	rep	movsb
	add	al,41h
	mov	[edi-3],al
	add	edi,13-4
	lea	esi,Drive2
	mov	ecx,7
	rep	movsb
	add	FileListOffset,49
	inc	NrOfFiles
	popad
	ret
A_Directory:
	mov	al,1		;Indicate Dir
	push	edi esi
	add	edi,13
	lea	esi,DirText
	mov	ecx,11
	rep	movsb
	pop	esi edi
	jmp	GetTheName
NoDir:
	mov	al,77h
	cmp	ShowRealModName,0
	jz	DontShowRealName2
	push	edi esi
	lea	edx,ModName
	call	_OpenFileR
	jc	ErrorShit
	lea	edx,CheckType
	mov	ecx,100
	call	_ReadFile
	jc	ErrorShit
	mov	edi,-1			;Check For 'Extreme'
	mov	ecx,7
CheckLoop2:
	inc	edi
	mov	al,byte ptr [Extreme+edi]
	cmp	al,byte ptr [CheckType+edi]
	loopz	CheckLoop2
	jnz	NotAnOldAMSFile
	movzx	eax,byte ptr [CheckType+10]	;Samples
	mov	ebx,17
	mul	ebx
	movzx	ebx,byte ptr [CheckType+15]	;MIDIChannels
	add	eax,ebx
	movzx	ebx,word ptr [CheckType+16]	;Extra Bytes
	add	eax,ebx
	add	eax,18
	mov	bl,0
	call	_LseekFile
	jc	ErrorShit
	lea	edx,CheckType
	mov	esi,edx
	mov	ecx,31
	call	_ReadFile
	jc	ErrorShit
	lodsb
	movzx	ecx,al
	mov	edi,FileListOffset
	add	edi,12
	rep	movsb
	mov	al,0ah
	jmp	DontShowRealName
ErrorShit:
	jmp	DontShowRealName

NotAnOldAMSFile:
	mov	edi,-1			;Check For 'AMShdr'
	mov	ecx,7
CheckLoop4:
	inc	edi
	mov	al,byte ptr [AMShdr+edi]
	cmp	al,byte ptr [CheckType+edi]
	loopz	CheckLoop4
	jnz	NotAnAMSFile
	lea	esi,CheckType+7
	lodsb
	movzx	ecx,al
	mov	edi,FileListOffset
	add	edi,12
	rep	movsb
	mov	al,0eh
	jmp	DontShowRealName

ClipText	db	'<Clipfile>'
NotAnAMSFile:
	mov	edi,-1			;Check For 'ACShdr'
	mov	ecx,7
@@CheckLoop4:
	inc	edi
	mov	al,byte ptr [ACShdr+edi]
	cmp	al,byte ptr [CheckType+edi]
	loopz	@@CheckLoop4
	jnz	NotAnACSFile
	lea	esi,ClipText
	mov	ecx,10
	mov	edi,FileListOffset
	add	edi,12
	rep	movsb
	mov	al,40h
	jmp	DontShowRealName

NotAnACSFile:
	mov	edi,-1			;Check For 'APShdr'
	mov	ecx,7
@@CheckLoop5:
	inc	edi
	mov	al,byte ptr [APShdr+edi]
	cmp	al,byte ptr [CheckType+edi]
	loopz	@@CheckLoop5
	jnz	NotAnAPSFile
	lea	esi,CheckType+7
	mov	ecx,10
	mov	edi,FileListOffset
	add	edi,12
	rep	movsb
	mov	al,41h
	jmp	DontShowRealName
NotAnAPSFile:

	mov	edi,-1			;Check For 'ASEhdr'
	mov	ecx,7
@@CheckLoop7:
	inc	edi
	mov	al,byte ptr [ASEhdr+edi]
	cmp	al,byte ptr [CheckType+edi]
	loopz	@@CheckLoop7
	jnz	NotAnASEFile
	lea	esi,CheckType+10
	movzx	ecx,byte ptr [esi-1]
	mov	edi,FileListOffset
	add	edi,12
	rep	movsb
	mov	al,42h
	jmp	DontShowRealName
NotAnASEFile:


	lea	edi,ModName			;Check .XP
@@Again:
	cmp	byte ptr [edi],'.'
	jz	@@Found
	cmp	byte ptr [edi],0
	jz	NotAnXPFile
	inc	edi
	jmp	@@Again
@@Found:
	mov	ecx,3
	mov	edx,1
	mov	esi,edi
@@CheckLoop6:
	inc	edi
	inc	edx
	mov	al,byte ptr [WildCardXP+edx]
	cmp	al,byte ptr [edi]
	loopz	@@CheckLoop6
	mov	al,43h
	jz 	DontShowRealName
NotAnXPFile:

	lea	edi,CheckType           ;Check IFF sample
	cmp	[edi],'MROF'
	jnz	NotAnIFFSample
	cmp	[edi+8],'XVS8'
	jnz	NotAnIFFSample
	add	edi,12
ScanIFFSample:
	cmp	[edi],'YDOB'
	jz	NotAnIFFSample
	mov	eax,[edi+4]
	rol	ax,8
	rol	eax,16
	rol	ax,8
	cmp	[edi],'EMAN'
	jz	GotIFFSampleName
	add	edi,eax
	add	edi,8
	jmp	ScanIFFSample
GotIFFSampleName:
	mov	ecx,eax
	add	edi,8
	mov	esi,edi
	mov	edi,FileListOffset
	add	edi,12
	rep	movsb
	mov	al,4
	jmp	DontShowRealName
NotAnIFFSample:
	lea	edi,CheckType			;Check S3M
	cmp	dword ptr [edi+2ch],'MRCS'
	jnz	NoS3M
	cmp	byte ptr [edi+1dh],10h
	jnz	NoS3M
	mov	esi,edi
	mov	edi,FileListOffset
	add	edi,12
	mov	ecx,28
	rep	movsb
	mov	al,0ch
	jmp	DontShowRealName
NoS3M:
	lea	edi,CheckType			;Check S3I
	cmp	dword ptr [edi+4ch],'SRCS'
	jnz	NoS3I
	mov	esi,edi
	add	esi,30h
	mov	edi,FileListOffset
	add	edi,12
	mov	ecx,28
	rep	movsb
	mov	al,03h
	jmp	DontShowRealName
NoS3I:
	lea	edi,CheckType			;Check STM
	cmp	[edi+20],'rcS!'
	jnz	NoSTM
	cmp	[edi+24],'!mae'
	jnz	NoSTM
	cmp	byte ptr [edi+29],2
	jnz	NoSTM
	mov	esi,edi
	mov	edi,FileListOffset
	add	edi,12
	mov	ecx,20
	rep	movsb
	mov	al,0dh
	jmp	DontShowRealName


NoSTM:
	mov	edi,-1
	mov	ecx,21
CheckXI:
	inc	edi				;Check XI
	mov	al,[Checktype+edi]
	cmp	al,[XI_Determ+edi]
	jnz	NoXI
	loopz	CheckXI

	inc	edi
	mov	esi,edi
	add	esi,offset Checktype
	mov	edi,FileListOffset
	add	edi,12
	mov	ecx,22
	rep	movsb
;	pushad
;	sub	edi,22
;	mov	ecx,22
;	call	FixHiChars
;	popad

	mov	al,05h
	jmp	DontShowRealName


NoXI:

	mov	edi,-1
	mov	ecx,17
CheckXM:				;Check XM
	inc	edi
	mov	al,[Checktype+edi]
	cmp	al,[XM_Determ+edi]
	jnz	NoXM
	loopz	CheckXM

	cmp	word ptr [CheckType+58],0104h
	jnz	NoXM

	inc	edi
	mov	esi,edi
	add	esi,offset Checktype
	mov	edi,FileListOffset
	add	edi,12
	mov	ecx,20
	rep	movsb
;	pushad
;	sub	edi,20
;	mov	ecx,20
;	call	FixHiChars
;	popad

	mov	al,0fh
	jmp	DontShowRealName
NoXM:

	mov	edi,-1			;Check For 'AISHdr'
	mov	ecx,7
CheckLoop5:
	inc	edi
	mov	al,byte ptr [AIShdr+edi]
	cmp	al,byte ptr [CheckType+edi]
	loopz	CheckLoop5
	jnz	NotAnAISFile
	lea	esi,CheckType+7
	lodsb
	cmp	al,0aah
	jnz	OldAIS4
	add	esi,2
	lodsb
OldAIS4:
	movzx	ecx,al
	mov	edi,FileListOffset
	add	edi,12
	rep	movsb
	mov	al,06h
	jmp	DontShowRealName

NotAnAISFile:
	mov	edi,-1			;Check For 'GF1PATCH110',0
	mov	ecx,11
CheckLoop6:
	inc	edi
	mov	al,byte ptr [PAT_Determ+edi]
	cmp	al,byte ptr [CheckType+edi]
	loopz	CheckLoop6
	jnz	NotAPATFile

	mov	eax,83h
	mov	bl,0
	call	_LseekFile

	mov	ecx,16
	mov	edx,FileListOffset
	add	edx,12
	call	_ReadFile
	jc	ErrorShit

	mov	al,08h
	jmp	DontShowRealName

NotAPATFile:				;Check For MTM
	cmp	dword ptr [CheckType],'MTM'
	jnz	NotAnMTMFile

	lea	esi,CheckType+4
	mov	edi,FileListOffset
	add	edi,12
	mov	ecx,20
	rep	movsb

	mov	al,10h
	jmp	DontShowRealName

NotAnMTMFile:
	mov	edi,-1			;Check For ULT
	mov	ecx,14
CheckLoop7:
	inc	edi
	mov	al,byte ptr [ULT_Determ+edi]
	cmp	al,byte ptr [CheckType+edi]
	loopz	CheckLoop7
	jnz	NotAnULTFile

	lea	esi,CheckType+15
	mov	edi,FileListOffset
	add	edi,12
	mov	ecx,30
	rep	movsb

	mov	al,11h
	jmp	DontShowRealName


NotAnULTFile:
	mov	eax,0			;Check MOD
	mov	bl,2
	call	_LseekFile
	cmp	eax,2108
	jb	AbsolutelyNoMOD

	mov	eax,1080
	mov	bl,0
	call	_LseekFile
	jc	ErrorShit
	lea	edx,CheckType
	mov	ecx,4
	call	_ReadFile
	jc	ErrorShit

	mov	ecx,8
	xor	ebp,ebp
CheckLoop3:
	push	ecx ebp
	xor	edi,edi
	mov	ecx,4
CheckLoop:
	mov	al,byte ptr [Mods+ebp]
	cmp	al,byte ptr [CheckType+edi]
	jnz	NoMOD
	inc	edi
	inc	ebp
	loop	CheckLoop
	pop	ebp ecx
	jmp	AModFile
NoMOD:
	pop	ebp ecx
	add	ebp,4
	loop	CheckLoop3
	mov	eax,dword ptr [CheckType]
	shr	eax,8
	cmp	eax,'NHC'
	jz	AModFile
	shr	eax,8
	cmp	eax,'HC'
	jz	AModFile
AbsolutelyNoMOD:
	mov	al,0
	jmp	DontShowRealName

AModFile:
	mov	eax,0
	mov	bl,0
	call	_LseekFile
	lea	edx,CheckType
	mov	esi,edx
	mov	ecx,20
	call	_ReadFile
	jc	ErrorShit
	mov	edi,FileListOffset
	add	edi,12
	rep	movsb
	mov	al,0bh
DontShowRealName:
	pop	esi edi
	call	_CloseFile
DontShowRealName2:
	push	edi esi eax
IF DOS32VERSION		;\\
	mov	eax,_pspa
	mov	eax,dword ptr [eax+154]
ENDIF			;//
IF PMODEWVERSION	;\\
	mov	eax,_DTA
	mov	eax,dword ptr [eax+1ah]
ENDIF			;//
	cmp	eax,999999
	jb	Below1MB
	mov	byte ptr [edi+47],'K'
	cmp	eax,99999999
	jb	Below100MB
	mov	byte ptr [edi+47],'M'
	shr	eax,20
	adc	eax,0
	dec	edi
	jmp	Below1MB
Below100MB:
	shr	eax,10
	adc	eax,0
	dec	edi
Below1MB:

	xor	ecx,ecx
PutLoop2e:
	xor	edx,edx
	mov	ebx,10
	div	ebx
	push	dx
	inc	ecx
	cmp	ax,0
	jnz	PutLoop2e
	cmp	dx,0
	jnz	PutLoop2e
	add	edi,49
	sub	edi,ecx
	cmp	ecx,1
	jnz	Kroka
	dec	edi
	jmp	GetLoop2e
Kroka:
	dec	ecx
	pop	ax
GetLoop2e:
	pop	ax
	add	ax,30h
	stosb
	loop	GetLoop2e
	pop	eax esi edi
GetTheName:
	mov	[edi+48],al
	mov	ecx,12
GetNameLoopen:
	lodsb
	cmp	al,0
	jz	NoMoreName
	stosb
	loop	GetNameLoopen
NoMoreName:


	add	FileListOffset,49
	inc	NrOfFiles
	Popad
	Ret
MoveNameToList	EndP

FixHiChars	Proc	Near
	and	byte ptr [edi],127
	inc	edi
	loop	FixHiChars
	ret
FixHiChars	EndP

UpdateFileList	   Proc    Near
	cmp	menu_upperscreen,3
	jnz	dummy
	Pushad
;	mov	bl,0
;	call	ReleaseLastButton
	mov	ebx,DiscFree
	mov	ah,1
	mov	cl,10
	move	edi,0a0000h+21*80+552/8
	mov	MouseX1,415
	mov	MouseX2,247
	mov	MouseY1,617
	mov	MouseY2,343

	call	MouseOff
	call	PutDecimal
	call	MouseOn

	mov	MouseX1,159
	mov	MouseY1,18
	mov	MouseX2,561
	mov	MouseY2,185
	call	MouseOff

	mov	esi,CurrentPathPtr
	mov	ah,1
	mov	cl,40
	add	esi,CurrPathStart
	move	edi,0a0000h+21*80+25
	call	PrintText

	move	edi,0a0000h+41*80+160/8
	mov	esi,FileListPtr
	movzx	eax,CurrentFileName
	mov	ebx,49
	mul	ebx
	add	esi,eax
	mov	ah,1
	mov	ecx,12

	push	ax
	mov	dx,3c4h 	;Write mask register
	mov	ax,0102h
	out	dx,ax
	mov	dx,3ceh 	;Read mask register
	mov	ax,0004h
	out	dx,ax
	pop	ax

asta:
	push	ecx
	mov	InvertText,0
	mov	cl,[esi+48]
	rcl	cl,1
	jnc	NoMark
	mov	InvertText,-1
NoMark:

	push	edi
	mov	cl,12
	call	PrintText
	add	edi,12
	mov	ebx,' '
	call	PutCharacter
	inc	edi
	add	esi,12
	mov	cl,30
	call	PrintText
	add	edi,30
	mov	ebx,' '
	call	PutCharacter
	inc	edi
	add	esi,30
	mov	cl,6
	call	PrintText
	add	esi,7
	pop	edi
	add	edi,12*80
	pop	ecx
	loop	asta
	call	MouseOn
	call	MouseReset
	mov	InvertText,0
	Popad
	Ret
UpdateFileList	EndP

TypeFile	db	0
GetLoadName	Proc	Near
	Pushad
	mov	esi,FileListPtr
	add	esi,48
	movzx	ecx,NrOfFiles
SeachLoadNameLoopen:
	mov	al,byte ptr [esi]
	and	al,80h
	jz	NotMarked
	xor	byte ptr [esi],80h
	mov	al,byte ptr [esi]
	mov	TypeFile,al
	sub	esi,48
	lea	edi,ModName
	mov	ecx,12
	rep	movsb
	xor	al,al
	stosb
	jmp	GotAFileName
NotMarked:
	add	esi,49
	loop	SeachLoadNameLoopen
	Popad
	stc
	Ret
GotAFileName:
	cmp	ShowRealModName,1
	jz	GotIt2
	lea	edx,ModName
	call	_OpenFileR
	mov	ax,OpenErr
	jc	ErrorHandler
	call	CheckFileFormat
	call	_CloseFile
	mov	ax,CloseErr
	jc	ErrorHandler

GotIt2:
_retp_clc:
	Popad
	clc
	Ret
GetLoadName  EndP

CheckLoadName	Proc	Near
	Pushad
	mov	esi,FileListPtr
	add	esi,48
	movzx	ecx,NrOfFiles
SeachLoadNameLoopen1:
	test	byte ptr [esi],80h
	jnz	_retp_clc
	add	esi,49
	loop	SeachLoadNameLoopen1
	Popad
	stc
	Ret
CheckLoadName  EndP

SvenJunga	db	0
GetCurrPath2:
	pushad
	mov	CurrPathStart,0
;	mov	esi,CurrentPathPtr
;	add	esi,3
	mov	SvenJunga,1
	jmp	SearchForDirEnd

CurrPathStart	dd	0
GetCurrPath	Proc	Near
	Pushad
	mov	SvenJunga,0
	cmp	Menu_UpperScreen,3
	jnz	_retp
	mov	CurrPathStart,0

	mov	edi,CurrentPathPtr
	mov	ah,19h		     ;get drive
	int	21h
	add	al,41h
	mov	[edi],al
	mov	CurrentDrive,al
	add	edi,3

	push	edi
	mov	ecx,64+12
	xor	al,al
	rep	stosb
	pop	esi
	mov	ah,47h		     ;get current directory
	mov	dl,0
	int	21h

SearchForDirEnd:
	mov	esi,CurrentPathPtr
	mov	ecx,63+3
Flax:
	mov	al,[esi+ecx]
	cmp	al,':'
	jz	RootDir
	cmp	al,'\'
	jz	RootDir
	cmp	SvenJunga,0
	jz	VenJung
	loop	Flax
VenJung:
	cmp	al,0
	loopz	Flax
	mov	byte ptr [esi+ecx+2],'\'
	add	ecx,2
RootDir:
	inc	ecx
	add	esi,ecx
	cmp	ecx,64-43+13-5	;29
	jb	NoStartFix
	sub	ecx,64-43+12-5
	mov	CurrPathStart,ecx
NoStartFix:
	mov	edi,esi
	push	edi
	mov	ecx,12/4
	xor	eax,eax
	rep	stosd
	pop	edi
	mov	esi,Savename
	mov	ecx,12
	rep	movsb
	Popad
	Ret
GetCurrPath  EndP

NrOfSorts	dd	0
SortOffset	dd	0
SortFileList	Proc	near
	pusha
	dec	ecx
	jle	QuitSort
	mov	edi,SortOffset
	mov	esi,edi
BigSortLoopen:
	push	ecx
	push	esi
SortLoopen:
	mov	eax,[edi]
	rol	ax,8
	rol	eax,16
	rol	ax,8
	add	esi,49
	mov	ebx,[esi]
	rol	bx,8
	rol	ebx,16
	rol	bx,8
	cmp	eax,ebx
	jb	DontSort
	je	CheckLower
	cmp	ebx,2e2e0000h
	jz	DontSort
	cmp	ebx,2e000000h
	jz	DontSort
	cmp	eax,2e2e0000h
	jz	DontSort
	cmp	eax,2e000000h
	jz	DontSort
	call	SwapBuffers
	jmp	DontSort
CheckLower:
	mov	eax,[edi+4]
	mov	ebx,[esi+4]
	rol	ax,8
	rol	eax,16
	rol	ax,8
	rol	bx,8
	rol	ebx,16
	rol	bx,8
	cmp	eax,ebx
	jbe	DontSort
	call	SwapBuffers
	jmp	DontSort
DontSort:
	loop	SortLoopen
	pop	esi
	pop	ecx
	add	esi,49
	add	edi,49
	loop	BigSortLoopen
QuitSort:
	popa
	ret
SortFileList	EndP

SwapBuffers	Proc	Near
	Pushad
	push	edi esi
	lea	edi,CheckType
	mov	ecx,49
	rep	movsb
	pop	edi esi
	push	esi edi
	mov	ecx,49
	rep	movsb
	pop	esi edi
	lea	esi,CheckType
	mov	ecx,49
	rep	movsb
	Popad
	Ret
SwapBuffers  EndP

RealNameOnOff:
	xor	ShowRealModName,1
	mov	bl,ShowRealModName
	btc	bx,0
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,580
	mov	ButtonY1,94
	mov	ButtonX2,592
	mov	ButtonY2,105
	call	Buttonupdown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1

	mov	FileListStart,0
	call	GetFileList
	mov	DontReadFileList,1
	call	GetCurrPath
	mov	OldCurrentFileName,-1
	cmp	AutoName,0
	jz	_ret
	call	Getname2
	ret

PackSampOnOff:
	xor	PackingByte,1
	mov	bl,PackingByte
	btc	bx,0
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,580
	mov	ButtonY1,81
	mov	ButtonX2,592
	mov	ButtonY2,92
	call	Buttonupdown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	ret

AutoLoad:
	mov	bl,AllowAutoLoad
	xor	AllowAutoLoad,1
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,580
	mov	ButtonY1,107
	mov	ButtonX2,592
	mov	ButtonY2,118
	call	Buttonupdown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	ret

dummyfile	db	'd',0
LastDrive	db	0
CurrentDrive	db	0
FileListMarkPtr dd	0
FirstFileName	dd	0
PressedOnce	db	0
MarkUnMark	db	0
LastFileName	dd	0
FileListSquare:
	cmp	MouseB,1
	ja	ClearAllFileMarks

	cmp	DoubleClick,1
	jz	NejTack
	mov	MouseOnDragbar,-1
NejTack:
	cmp	MouseY,42
	jb	DiscOpDragArrowUp2
	cmp	MouseY,183
	ja	DiscOpDragArrowDn2

	movzx	eax,MouseY
ContDiskOp:
	sub	eax,40
	mov	ebx,12
	xor	edx,edx
	div	ebx
	movzx	ebx,CurrentFileName
	add	ebx,eax
	cmp	bx,NrOfFiles
	jae	Dummy
	mov	eax,49
	mul	ebx
	mov	esi,FileListPtr
	add	esi,eax

	cmp	byte ptr [esi+48],1
	jz	ChangeDirectory
	cmp	byte ptr [esi+48],2
	jz	ChangeDrive

	mov	LeftKeyWait,2
	cmp	PressedOnce,0
	jz	NoPress1
	cmp	esi,LastFileName
	mov	LastFileName,esi
	jz	Dummy
	mov	PressedOnce,2

	pushad
	movzx	ecx,NrOfFiles
	mov	esi,FileListMarkPtr
	mov	edi,FileListPtr
MoveMarkInfo2:
	add	edi,48
	movsb
	loop	MoveMarkInfo2
	popad

	pushad
	mov	edi,FirstFileName
	cmp	esi,edi
	jb	NoMarkChange
	xchg	esi,edi
NoMarkChange:
	and	byte ptr [esi+48],0fh
	mov	al,MarkUnMark
	or	byte ptr [esi+48],al
	add	esi,49
	cmp	esi,edi
	jbe	NoMarkChange
	popad
	jmp	Press1
NoPress1:
	mov	PressedOnce,1
	xor	byte ptr [esi+48],80h
	mov	al,byte ptr [esi+48]
	and	al,0f0h
	mov	MarkUnMark,al
	mov	FirstFileName,esi

	pushad
	movzx	ecx,NrOfFiles
	mov	edi,FileListMarkPtr
	mov	esi,FileListPtr
MoveMarkInfo:
	add	esi,48
	movsb
	loop	MoveMarkInfo
	popad
Press1:
	push	esi
	mov	edi,SaveName
	mov	ecx,12
	rep	movsb
	call	GetCurrPath2
	call	UpdateFileList
	pop	esi
	cmp	esi,LastFileName
	mov	LastFileName,esi
	jnz	Dummy
	cmp	DoubleClick,0
	jz	Dummy
	movzx	eax,byte ptr [esi+48]
	and	al,07fh
	mov	TypeFile,al
	mov	esi,SaveName
	lea	edi,ModName
	mov	ecx,12
	rep	movsb
	jmp	LoadNext2
ChangeDrive:
	cmp	PressedOnce,0
	jnz	DummyDiskOp
ChangeDrive2:
	call	MouseHourGlass
	mov	al,CurrentDrive
	mov	LastDrive,al

	mov	dl,byte ptr [esi+1]
	mov	CurrentDrive,dl
	mov	esi,CurrentPathPtr

@@CritRetry:
	mov	Crit_Error,-1
	mov	[esi],dl
	sub	dl,41h
	cmp	dl,1
	ja	@@NoDDrive
	and	edx,0ffh
	cmp	[Drives+edx],0
	jnz     @@NoDDrive
	cmp	dl,PhantomDrive
	jz	@@NoDDrive
	mov	dl,PhantomDrive
@@NoDDrive:
	mov	ah,0eh				;set Drive
	int	21h

	push	FileHandle
	lea	edx,DummyFile			;Dummy read
	call	_OpenFileR
	jc	@@ThougtSo
	call	_CloseFile

@@ThougtSo:
	pop	FileHandle

	cmp	Crit_Error,-1
	jz	@@NoCritErr
	cmp     Crit_Error,3
	jz	@@CritRetry
@@Pah:
	mov	dl,LastDrive
	mov	CurrentDrive,dl

	mov	[esi],dl
	sub	dl,41h
	mov	ah,0eh				;set Drive
	int	21h

;	call	PauseMusic
;	mov	ecx,255         		;Turn off diskdrive
;@@ILoop:
;	int	8h
;	loop	@@ILoop
;	call	UnPauseMusic

	call	MouseArrow
	ret

@@NoCritErr:
	mov	FileListStart,1
	cmp	DiaParma,1
	jz	_ret
	call	GetFileList
	mov	OldCurrentFileName,-1
	call	MouseArrow
	ret


ClearAllFileMarks:
	movzx	ebx,MouseB
	dec	ebx
	mov	[LeftKeyWait+ebx],20
	mov	esi,FileListPtr
	sub	esi,1
	movzx	ecx,NrOfFiles
CheckMarkLoopen:
	add	esi,49
	mov	al,byte ptr [esi]
	and	al,80h
	loopz	CheckMarkLoopen
	jnz	ClearFilemarks

	mov	esi,FileListPtr
	add	esi,48
	movzx	ecx,NrOfFiles
SetMarkLoopen:
	cmp	byte ptr [esi],1
	jz	NoSet
	cmp	byte ptr [esi],2
	jz	NoSet
	or	byte ptr [esi],80h
NoSet:
	add	esi,49
	loop	SetMarkLoopen
	call	UpdateFileList
	ret

ClearFilemarks:
	mov	esi,FileListPtr
	add	esi,48
	movzx	ecx,NrOfFiles
ClearMarkLoopen:
	and	byte ptr [esi],07fh
	add	esi,49
	loop	ClearMarkLoopen
	call	UpdateFileList
	ret
ChangeDirectory:
	mov	LeftKeyWait,255
	cmp	PressedOnce,0
	jnz	DummyDiskOp
	lea	edi,ModName
	mov	ecx,12
	rep	movsb
	xor	al,al
	stosb
	lea	edx,Modname
ChangePath:
	mov	ah,3bh
	int	21h
	pushf
	popf
	jc	_ret
	mov	FileListStart,1
	cmp	DiaParma,1
	jz	_ret_clc
	call	GetFileList
	mov	OldCurrentFileName,-1
	clc
	Ret

DummyDiskop:
	mov	LeftKeyWait,2
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DiscOpDragArrowUp2:
	cmp	CurrentFileName,0
	jz	Dummy
	dec	CurrentFileName
	mov	eax,45
	jmp	ContDiskOp
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DiscOpDragArrowUp:
	call	fixbutton
	cmp	CurrentFileName,0
	jz	Dummy
	dec	CurrentFileName
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DiscOpDragArrowDn2:
	mov	ax,CurrentFileName
	add	ax,12
	cmp	ax,NrOfFiles
	jae	Dummy
	inc	CurrentFileName
	mov	eax,180
	jmp	ContDiskOp

DiscOpDragArrowDn:
	call	fixbutton
	mov	ax,CurrentFileName
	add	ax,12
	cmp	ax,NrOfFiles
	jae	Dummy
	inc	CurrentFileName
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
WILD_ALL:
	cmp	CurrentWildCard,0
	jz	_ret
	mov	CurrentWildCard,0
	mov	esi,CurrentFileType
	mov	[CurrentWildTBL+esi],8
	jmp	SetTheWC
WILD_MIX:
	mov	eax,CurrentFileType
	mov	esi,eax
	lea	eax,[eax*2+eax]
	shl	eax,1
	add	eax,78
	cmp	CurrentWildCard,eax
	jz	_ret
	mov	CurrentWildCard,eax
	mov	[CurrentWildTBL+esi],9
	jmp	SetTheWC
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OldWildTBL	db	0,0,0,8
CurrentWildTBL	db	0,0,0,8
SetSong:
	cmp	CurrentFileType,0
	jz	_ret
	mov	CurrentFileType,0
	mov	ButtonhandlerX1,164
	mov	ButtonhandlerY1,191
	mov	ButtonhandlerX2,176
	mov	ButtonhandlerY2,202
	jmp	SetIt
SetInst:
	cmp	CurrentFileType,1
	jz	_ret
	mov	CurrentFileType,1
	mov	ButtonhandlerX1,164
	mov	ButtonhandlerY1,208
	mov	ButtonhandlerX2,176
	mov	ButtonhandlerY2,219
	jmp	SetIt
SetSamp:
	cmp	CurrentFileType,2
	jz	_ret
	mov	CurrentFileType,2
	mov	ButtonhandlerX1,222
	mov	ButtonhandlerY1,208
	mov	ButtonhandlerX2,234
	mov	ButtonhandlerY2,219
	jmp	SetIt
SetPatt:
	cmp	CurrentFileType,3
	jz	_ret
	mov	CurrentFileType,3
	mov	ButtonhandlerX1,222
	mov	ButtonhandlerY1,191
	mov	ButtonhandlerX2,234
	mov	ButtonhandlerY2,202
	jmp	SetIt
SetIt:
	mov	bl,1
	call	ReleaseLastButton
	call	MoveButtonCords2
	mov	bl,0
	call	ButtonUpDown
	mov	eax,CurrentFileType
	mov	esi,[DiskOpPictureTBL+eax*4]
	mov	DrawSpecial,1
	call	DrawPopUp
	movzx	esi,[CurrentWildTBL+eax]
	mov	eax,[Wild_TBL+eax*4]
	movzx	esi,byte ptr [esi+eax+1]
	mov	CurrentWildCard,esi
	jmp	SetTheWC



Wild_TBL	dd	Wild_Song,Wild_Inst,Wild_Samp,Wild_Patt
			;Nr of buttons, wildcard number...
Wild_Song	db	7,  6, 12, 30, 42, 60, 126, 132, 0, 0, 78
Wild_Inst	db	3, 54, 48, 72,	0,  0,   0,   0, 0, 0, 84
Wild_Samp	db	5,120, 18, 66, 24, 36,   0,   0, 0, 0, 90
Wild_Patt	db	3,102,108,114,	0,  0,   0,   0, 0, 0, 96
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SetWildCard:
	movzx	eax,MouseY
	sub	ax,188
	mov	bx,17
	xor	dx,dx
	div	bx
	shl	ax,2
	movzx	ecx,ax

	mov	ax,MouseX
	sub	ax,280
	mov	bx,56
	xor	dx,dx
	div	bx
	and	eax,0ffh
	add	eax,ecx
	mov	esi,CurrentFileType
	mov	ebp,[Wild_TBL+esi*4]
	cmp	al,[ebp]
	jae	_ret
	mov	[CurrentWildTBL+esi],al
	movzx	eax,byte ptr [ebp+eax+1]
;	cmp	CurrentWildCard,eax
;	jz	_ret
	mov	LeftkeyWait,255
	mov	RightKeyWait,255
	mov	CurrentWildCard,eax
SetTheWC:
	call	PressWildButton

	call	SetDrivePath2
	mov	FileListStart,1
	call	GetFileList
	mov	OldCurrentFileName,-1
	cmp	AutoName,0
	jz	Dummy
	call	Getname2
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
FileNameInput	db	0
FileNameSquare:

	call	ParsePath
	call	UpdateFileList

	mov	edi,21*80+25
	mov	esi,CurrentPathPtr
	mov	ecx,40
	mov	ax,0103h
	mov	FileNameInput,1
	mov	InputVirtMax,66+12
	call	InputRoutine
	mov	ax,CurrentFileName
	mov	OldCurrentFileName,ax

	mov	ebx,4*24			;Check FileNamesDragBar
	mov	ExtraLength,12
	mov	Dword Ptr [DragBarTable+ebx+10],0	;New Pos
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	call	DragBarHandler
	mov	MouseOnDragBar,al
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Delete:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
	lea	esi,DeleteFile
	mov	PopupStatus,-1
DeleteNext:
	call	GetLoadName
	jc	AllDeleted
	cmp	PopupStatus,2
	jz	DeleteAll

	push	esi
	lea	esi,ModName
	lea	edi,DelFileName
	mov	ecx,12
	rep	movsb
	pop	esi
	cmp	PopupStatus,-1
	jnz	NotFirstTime
	mov	menu_popup,3
	call	PopupHandler
	jmp	FirstTime
NotFirstTime:
	mov	menu_popup,3
	call	PopupHandler2
FirstTime:
	cmp	PopupStatus,0
	jz	DeleteNext
	cmp	PopupStatus,3
	jz	AllDeleted
DeleteAll:
	lea	edx,ModName
	call	_DeleteFile
	jc	DelError
	jmp	DeleteNext
AllDeleted:
	cmp	PopupStatus,-1
	jz	AllDeleted2
	mov	FileListStart,0
	call	GetFileList
AllDeleted2:
	cmp	PopUpstatus,1
	ja	Holly
	mov	menu_popup,0
	call	menuhandler
Holly:
	call	UpdateFileList
	ret
DelError:
	mov	menu_popup,0
	call	menuhandler
	mov	FileListStart,0
	call	GetFileList
	call	UpdateFileList
	mov	ax,DeleteErr
	jmp	ErrorHandler
	ret

Rename:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
	lea	esi,RenameFile
	mov	PopupStatus,-1
RenameNext:
	call	GetLoadName
	jc	AllRenamed

	call	UpdateFileList
	push	esi
	lea	esi,ModName
	lea	edi,RenFileName
	mov	ecx,12
	rep	movsb
	pop	esi
	cmp	PopupStatus,-1
	jnz	NotFirstTime2

	mov	menu_popup,4
	call	PopupHandler
	jmp	FirstTime2
NotFirstTime2:
	push	esi
	mov	FontPlane,1
	mov	ah,1
	mov	cl,12
	move	edi,0a0000h+(112*80)+336/8
	lea	esi,RenFileName
	call	printtext
	mov	FontPlane,0
	pop	esi
	call	PopupHandler2
FirstTime2:
	cmp	PopupStatus,0
	jz	RenameNext
	cmp	PopupStatus,3
	jz	AllRenamed

	lea	edx,ModName
	lea	edi,RenFileName
	mov	byte ptr [edi+12],0
	call	_renfile
	mov	byte ptr [edi+12],'$'
	jc	RenameErrorHandler
	jmp	RenameNext
AllRenamed:
	cmp	PopupStatus,-1
	jz	AllRenamed2
	mov	FileListStart,0
	call	GetFileList
AllRenamed2:
	mov	menu_popup,0
	call	menuhandler
	call	UpdateFileList
	ret
PopUp_RenameInput:
	mov	edi,112*80+336/8
	mov	ecx,12
	mov	ax,0113h
	lea	esi,RenFileName
	call	InputRoutine
	ret
RenameErrorHandler:
	mov	menu_popup,0
	call	menuhandler
	call	UpdateFileList
	mov	ax,RenameErr
	jmp	ErrorHandler

SaveModule:
	cmp	CurrentWildCard,0		;ALL
	jz	_ret

	cmp	CurrentWildCard,6		;AMS
	jz	IWannaSave

	cmp	CurrentWildCard,12		;MOD
	jz	IWannaSave2

	cmp	CurrentWildCard,18		;SMP
	jz	IWannaSave2

	cmp	CurrentWildCard,30		;S3M
	jz	IWannaSave2

	cmp	CurrentWildCard,54		;AIS
	jz	IWannaSave

	cmp	CurrentWildCard,60		;XM
	jz	IWannaSave2

	cmp	CurrentWildCard,66		;WAV
	jz	IWannaSave2

	cmp	CurrentWildCard,102		;ACS
	jz	IWannaSave

	cmp	CurrentWildCard,108		;APS
	jz	IWannaSave

	cmp	CurrentWildCard,120		;ASE
	jz	IWannaSave

	lea	esi,NoSaveAllowed
	mov	Menu_Popup,1
	call	PopUpHandler
	ret

IWannaSave2:
IWannaSave:
	call	ButtonHandler
	cmp	eax,0
opel:	jnz	Dummy
	call	FixSaveName	;Add Extension if none present
	mov	edx,SaveName
	call	_OpenFileR
	jc	DontExist
	call	_CloseFile
	lea	esi,FileExists
	mov	Menu_Popup,2
	call	PopUpHandler
	call	GetCurrPath
	clc
	cmp	PopupStatus,1
	jz	DontExist
	ret

DontExist:
	cmp	CurrentWildCard,30
	jz	S3MMess
	cmp	CurrentWildCard,60
	jz	S3MMess
	cmp	CurrentWildCard,12
	jnz	SkipMODMess
S3MMess:
	cmp	SkipMODSaveMess,0
	jz	SkipMODMess
	lea	esi,savemodmess
	mov	Menu_Popup,2
	call	PopUpHandler
	cmp	PopupStatus,1
	jnz	Dummy
SkipMODMess:

	call	MouseHourGlass
	call	PauseMusic
	call	SaveMod
	pushf
	push	ax
	call	PosInit
	mov	ax,CurrRow
	mov	GotoRow,ax
	call	UnPauseMusic
	pop	ax
	popf

	jc	SaveError
	mov	FileListStart,0
	call	GetFileList
	mov	OldCurrentFileName,-1
	mov	FileEdited,0
	call	MouseArrow
	movzx	ax,CurrentInstrument
	shl	ax,4
	mov	CurrentSample,ax
	ret
SaveError:
	push	ax
	mov	edx,SaveName
	call	_DeleteFile
	mov	FileListStart,0
	call	GetFileList
	call	MouseArrow
	pop	ax
	jmp	ErrorHandler

FixSaveName	Proc	Near
	pusha
	cmp	AutoExtension,0
	jz	GotExtension
	mov	edi,SaveName
	mov	ecx,9
CheckFSNLoop:
	cmp	byte ptr [edi],'.'
	jz	GotExtension
	cmp	byte ptr [edi],' '
	jz	FixExtension
	cmp	byte ptr [edi],0
	jz	FixExtension
	inc	edi
	loop	CheckFSNLoop
	dec	edi
FixExtension:
	lea	esi,WildCardAll+1
	add	esi,CurrentWildCard
	movsd
GotExtension:
	popa
	ret
FixSaveName	EndP


ViewDiskOp:
	pushad
	mov	eax,[PcxOffsets+24]
	mov	pcxx,156
	mov	pcxy,17
;	mov	fixproblem,1
	call	ShowThePcx
;	mov	oldpos,-1
;	mov	oldbpm,-1
;	mov	oldpatt,-1
;	mov	oldlen,-1
	popad
	ret

RootDirr	db	0,0
OrigDrive	db	0,0		;StartUp Drive
OrigRoot	db	05ch,0
OrigPath	db	64	dup(0)	;StartUp Dir
Drives		db	28	dup(0)	;0=DiscDrive,1=HD,2=Remote,3=Subst,4=Other,5=Unknown,15=NoDrive
GetDrivePath	Proc	Near
	pushad
	mov	ah,19h		     ;get drive
	int	21h
	mov	OrigDrive,al
	mov	CurrentDrive,al
	add	al,41h
	mov	CurrPath0,al
	mov	CurrPath1,al
	mov	CurrPath2,al
	mov	CurrPath3,al
	mov	CurrPath4,al
	mov	CurrPath5,al
	mov	CurrPath6,al
	mov	CurrPath7,al
	mov	CurrPath8,al
	mov	CurrPath9,al
	mov	CurrPath10,al
	mov	CurrPath11,al
	mov	CurrPath12,al
	mov	CurrPath13,al
	mov	CurrPath14,al
	mov	CurrPath15,al
	mov	CurrPath16,al
	mov	CurrPath17,al
	mov	CurrPath18,al
	mov	CurrPath19,al
	mov	CurrPath20,al
	mov	CurrPath21,al
	mov	CurrPath22,al

	mov	ah,47h		     ;get path
	mov	dl,0
	lea	esi,OrigPath
	int	21h

	mov	ecx,28
	mov	bx,1
	xor	esi,esi
GetDrivesLoopen:
	mov	ax,4408h
	int	21h
	mov	PhantomDrive,al
	mov	ah,al
;	jnc	NextDrive
	cmp	ah,0fh
	jz	NextDrive
	mov	ax,4409h
	int	21h
	mov	ah,5
	jc	NextDrive
	mov	ah,2
	test	dx,1000h
	jnz	NextDrive
	mov	ah,3
	test	dx,8000h
	jnz	NextDrive
	mov	ah,PhantomDrive
NextDrive:
	mov	[Drives+esi],ah
	inc	esi
	inc	bx
	loop	GetDrivesLoopen
NoMoreDrives:
	mov	al,gs:[410h]
	mov	bl,al
	and	bl,1
	jz	NoDiscDrive
	shr	al,6
	inc	al
	mov	NrOfDiscDrives,al
NoDiscDrive:
	mov	al,gs:[504h]
	mov	PhantomDrive,al


	mov	eax,CurrentWildCard		;Init it
	mov	ebx,6
	xor	edx,edx
	div	ebx
	mov	esi,[CurrPathTable+eax*4]
	mov	CurrentPathPtr,esi
	add	esi,67+12
	mov	SaveName,esi

	popad
	ret
GetDrivePath Endp

SetDrivePath	Proc	Near
	pushad
	mov	ah,0eh		;set origdrive
	mov	dl,OrigDrive
	int	21h

	lea	edx,OrigRoot		;Set Root
	mov	ah,3bh
	int	21h

	lea	edx,Origpath		 ;set origpath
	mov	ah,3bh
	int	21h

	popad
	ret
SetDrivePath	EndP

TempPath	db	67 dup(0)

SetDrivePath2	Proc	Near
	pushad
	call	MouseHourGlass
	mov	eax,CurrentWildCard
	mov	ebx,6
	xor	edx,edx
	div	ebx
	mov	esi,[CurrPathTable+eax*4]
	mov	CurrentPathPtr,esi
	mov	SaveName,esi
	add	SaveName,67+12
	cmp	MouseB,1
	jnz	SkipSetCurrPath

	cmp	SpecialSet,1			;When entering Diskop
	jz	@@NoKidding

	cmp	DiskOpDefPath,0
	jz	@@NoKidding
	pushad
	mov	edi,esi
	lea	esi,CPPathBuffer
	mov	ebx,67
	mul	ebx
	add	esi,eax
	test	byte ptr [esi],NOT 020h		;Check for Space and Zero
	jz	@@Polay
	mov	ecx,67
	push	edi
	rep	movsb
	pop	edi
	add	edi,3
	mov	ecx,63
@@FittLoopen:
	cmp	byte ptr [edi+ecx],0
	jz	@@Ole
	cmp	byte ptr [edi+ecx],20h
@@Ole:
	loopz	@@FittLoopen
	jz	@@Polay
	cmp	byte ptr [edi+ecx+1],'\'
	jz	@@Polay
	mov	byte ptr [edi+ecx+2],'\'
	mov	byte ptr [edi+ecx+3],0
@@Polay:
	popad
@@NoKidding:

	mov	ah,0eh		;set drive
	mov	dl,[esi]
	cmp	dl,'Z'
	jbe	NOPathProbb
	sub	dl,32
NOPathProbb:
	mov	CurrentDrive,dl
	sub	dl,41h
	int	21h

	lea	edx,OrigRoot		;Set Root
	mov	ah,3bh
	int	21h

	lea	edi,TempPath
	mov	ecx,67
	rep	movsb

	lea	edi,TempPath+3
	push	edi
	mov	ecx,63
FittLoopen:
	cmp	byte ptr [edi+ecx],'\'		;Check for Zero
	loopnz	FittLoopen
	mov	byte ptr [edi+ecx+1],0
	pop	edx

;.
;	pushad
;	mov	ah,0fh
;	move	edi,0a0000h+5*80
;	mov	cl,40
;	lea	esi,TempPath
;	call	PrintText
;	popad
;.

	mov	ah,3bh
	int	21h

SkipSetCurrPath:
	call	MouseArrow
	popad
	ret
SetDrivePath2	EndP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
GetName:
	call	fixbutton
GetName2:
	mov	edi,SaveName
	mov	ecx,12
	xor	al,al
	rep	stosb
	mov	edi,SaveName
	cmp	CurrentWildCard,6
	jz	GetSongName
	cmp	CurrentWildCard,12
	jz	GetSongName
	cmp	CurrentWildCard,30
	jz	GetSongName
	cmp	CurrentWildCard,60
	jz	GetSongName

	cmp	CurrentWildCard,54
	jz	GetInstName
	cmp	CurrentWildCard,102
	jz	GetClipName
	cmp	CurrentWildCard,108
	jz	GetPattName
	cmp	CurrentWildCard,18
	jz	GetSampName
	cmp	CurrentWildCard,120
	jz	GetSampName

	ret
ForbiddenForest db '"?:=</.*>\;+[],',0
MaxCount	dd	0

GetClipName:
	lea	esi,spaces
	mov	MaxCount,1
	jmp	MoveTheName

GetPattName:
	mov	MaxCount,10
	mov	esi,PatternStart
	sub	esi,12
	jmp	MoveTheName

GetSongName:
	lea	esi,SongName
	mov	MaxCount,30
	jmp	MoveTheName

GetSampName:
	cmp	CurrentInstrument,0
	jz	SkipName
	mov	MaxCount,22
	mov	esi,SampleNamesPtr
	movzx	eax,CurrentSample
	sub	eax,16
	mov	ebx,22
	mul	ebx
	add	esi,eax
	jmp	MoveTheName

GetInstName:
	cmp	CurrentInstrument,0
	jz	SkipName
	mov	MaxCount,30
	mov	esi,InstNamesPtr
	movzx	eax,CurrentInstrument
	dec	eax
	mov	ebx,30
	mul	ebx
	add	esi,eax

MoveTheName:
	mov	ecx,8
	xor	edx,edx
MoveNameLoopen:
	lodsb
	inc	edx
	cmp	al,33
	jb	ItsForbidden
	lea	ebp,ForbiddenForest-1
CheckForbiddenLoop:
	inc	ebp
	cmp	byte ptr [ebp],0
	jz	CharIsAllRight
	cmp	al,[ebp]
	jnz	CheckForbiddenLoop
	jmp	ItsForbidden
CharIsAllRight:
	stosb
	loop	MoveNameLoopen
	call	FixSaveName
	call	GetCurrPath2
	call	UpdateFileList
	ret
ItsForbidden:
	cmp	edx,MaxCount
	jb	MoveNameLoopen
SkipName:
	call	FixSaveName
	call	GetCurrPath2
	call	UpdateFileList
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ConvertSigned:
	xor	LoadSampleConvert,1
	mov	bl,LoadSampleConvert
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	bl,LoadSampleConvert
	mov	ButtonX1,580
	mov	ButtonY1,55
	mov	ButtonX2,592
	mov	ButtonY2,66
	call	buttonupdown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
FTLoop:
	xor	LoadFTLoop,1
	mov	bl,LoadFTLoop
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,580
	mov	ButtonY1,68
	mov	ButtonX2,592
	mov	ButtonY2,79
	call	buttonupdown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
FileEdited	db	0
LoadModule:
	call	ButtonHandler
	cmp	eax,0
	jnz	Dummy
LoadModuleKey:
	mov	SongFinished,0
	call	GetLoadName
	jc	Dummy
	jmp	FileIsDefined
LoadNext2:
	cmp	TypeFile,77h
	jnz	FileIsDefined
	lea	edx,ModName
	call	_OpenFileR
	mov	ax,OpenErr
	jc	ErrorHandler
	call	CheckFileFormat
	call	_CloseFile
	mov	ax,CloseErr
	jc	ErrorHandler
FileIsDefined:
	movzx	eax,TypeFile

	cmp	TypeFile,05h
	jz	LoadInstrument
	cmp	TypeFile,06h
	jz	LoadInstrument
	cmp	TypeFile,08h
	jz	LoadInstrument
	cmp	TypeFile,40h
	jz	LoadPatt
	cmp	TypeFile,41h
	jz	LoadPatt
	cmp	TypeFile,43h
	jz	LoadPatt
	cmp	TypeFile,42h
	jz	LoadSample
	cmp	TypeFile,0ah
	jb	LoadSample
	cmp	AskAbandonSong,0
	jz	NoQuestion
	cmp	FileEdited,0
	jz	NoQuestion
	lea	esi,SongEdited
	mov	Menu_Popup,2
	call	PopUpHandler
	cmp	PopupStatus,1
	jnz	Dummy
	mov	FileEdited,0
NoQuestion:
	call	StopAllVoices
	call	MouseHourGlass
	call	PauseMusic
	call	LoadMod

	pushf
	push	ax
	mov	OldRow,-1
	mov	OldPos,-1
	mov	OldPos2,-1
	mov	OldPattName,-1
	mov	OldPatt,-2
	mov	OldPatt2,-2
	mov	OldBPM,-1
	mov	OldCurrentInstrument,-1
	mov	OldCurrentInstName,-1
	mov	OldCurrentSampName,-1
	mov	OldCurrentChannel,-1
	mov	OldTime_Min,-1
	mov	OldTime_Sec,-1
	mov	TuneChannelON,-1
	mov	CurrentInstrument,1
	mov	CurrentSampName,16
	mov	CurrentSample,16
	mov	CurrentInstName,0
	mov	CurrentChannel,0
	mov	CursorChannel,0
	mov	ArrowPointer,0
	mov	CurrStartPosition,0
	mov	CurrCursorPosition,0
	mov	SongFinished,0
	mov	[DragBarData+(13*4)*6+0],0
	mov	[DragBarData+(13*4)*7+0],0
	movzx	ebx,CurrPosition
	shl	ebx,1
	add	ebx,PatternOrderPtr
	movzx	eax,word ptr [ebx]
	mov	CurrPatt2,ax
	pop	ax
	popf
	jnc	NoErrorHandler

	push	ax
	call	ClearMod
	mov	AllocFailed,0
	mov	TuneStopped,1
	mov	TuneStoppedSave,1
	call	UnPauseMusic
	call	AllocateInitialBuffers2
	call	FixAllocChannels
	call	PosInit
	mov	samples,1
	call	PrintSampleInfo
	call	PrintComposer
	call	PrintModName
	mov	dword ptr [desctable+1*4],0
	lea	eax,desctable
	mov	DescNowOffset,eax
	call	DrawDesc
	call	mousearrow
	pop	ax
	jmp	ErrorHandler
NoErrorHandler:
	call	PosInit
	push	ax
	call	sampletoram

	movzx	eax,Channels
	cmp	al,6
	jbe	NesCafe
	mov	al,6
NesCafe:
	mov	[DragBarData+116],eax
	mov	[DragBarData+168],eax

	call	mouseoff
	call	PrintSampleInfo
	call	PrintComposer
	call	PrintModName
	call	UpdateChannelInfo
	call	UpdateFileList
	call	UpdateSongCfgScreen
	mov	dword ptr [desctable+1*4],0
	lea	eax,desctable
	mov	DescNowOffset,eax
	call	DrawDesc

	cmp	QuitFileRequester,0
	jz	DontRemoveDO
	mov	menu_upperscreen,0
	call	menuhandler
DontRemoveDO:
	pop	ax
	call	FixAllocChannels
	call	UnPauseMusic
	cmp	TuneStopped,1
	jz	NoStartTheMod
	call	StartMod
NoStartTheMod:
	call	mousearrow
	ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
LoadInstrument:
	cmp	Sample0,1
	jz	_ret
	call	MouseHourGlass
LoadInst2:
	cmp	OneSampleLoaded,0
	jz	NotFirstInstYet
	movzx	ecx,Samples
	xor	ebx,ebx
GetEmptyInstLoop:
	call	CheckInstEmpty
	jnc	NotFirstInstYet
	inc	CurrentInstrument
	loop	GetEmptyInstLoop
	call	AddAnEmptySample2
NotFirstInstYet:
	cmp	CurrentInstrument,0
	jz	QuitLoadInst
	cmp	OneSampleLoaded,1
	jz	LoadInstOkay
	call	CheckInstEmpty
	jnc	LoadInstOkay
	cmp	AskReplaceInst,0
	jz	LoadInstOkay
	lea	esi,InstExists
	mov	Menu_Popup,2
	call	MouseArrow
	mov	al,DoubleClick
	call	PopUpHandler
	mov	DoubleClick,al
	call	MouseHourGlass
	cmp	PopupStatus,1
	jnz	NoVofflor
LoadInstOkay:
	lea	edx,ModName
	call	PauseMusic
	call	LoadMod 	;An inst.


	pushf
	mov	[DragBarData+(13*4)*6+0],0
	mov	[DragBarData+(13*4)*7+0],0
	call	UnPauseMusic
	popf
	jnc	NoVofflor
	pushad
	mov	DontDisallocSample,1
	call	KillInst2
	mov	DontDisallocSample,0
	popad
	mov	SampLength,0
	mov	ebp,1024
	call	MemDisAlloc
	mov	ebp,1025
	call	MemDisAlloc
	call	UpdateSampNames
	call	UpdateFileList
	call	MouseArrow
	jmp	ErrorHandler
NoVofflor:
	mov	OneSampleLoaded,1
LoadNextInst:
	call	MouseOff
	call	PrintSampleInfo
	call	MouseOn
	call	UpdateFileList
	cmp	DoubleClick,1
	jz	QuitLoadInst
	call	GetLoadName
	jc	QuitLoadInst
	cmp	TypeFile,05h
	jb	LoadNextInst
	cmp	TypeFile,08h
	ja	LoadNextInst
	cmp	TypeFile,07h
	jz	LoadNextInst
	mov	al,CurrentInstrument
	cmp	al,Samples
	jnz	LoadInst2
	call	AddAnEmptySample2
	jmp	LoadInst2

QuitLoadInst:
	movzx	eax,CurrentInstrument
	shl	ax,4
	mov	CurrentSample,ax
	mov	CurrentSampName,ax
	mov	ecx,[SampleOffsetEnd+eax*4]
	sub	ecx,[SampleOffsetStart+eax*4]
	mov	SampLength,ecx
	call	SampleToRam
	call	viewall2

QuitSampInst:
;	call	PauseMusic
;	mov	ecx,255         ;Turn off diskdrive
;ILoop:	;int	8h
;	loop	ILoop
;	call	UnPauseMusic
	call	mousearrow
	mov	OneSampleLoaded,0
	mov	OldCurrentInstrument,-1
	mov	OldCurrentSampName,-1
	call	PrintSampleInfo
	call	UpdateFileList
	cmp	Menu_DownScreen,4
	jz	DontDisallocIt
	mov	ebp,1024
	call	MemDisAlloc
DontDisallocIt:
	cmp	ErrorLoadSample,1
	jnz	_ret
	mov	ax,GUSMemErr
	jmp	errorhandler
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OneLoaded	db	0
OneSampleLoaded db	0
LoadSampAsInst2 db	0
LoadSample:
	cmp	Sample0,1
	jz	_ret
	call	MouseHourGlass

	mov	al,LoadSampAsInst
	mov	LoadSampAsInst2,al
	mov	OneLoaded,0
LoadSample2:
	cmp	OneSampleLoaded,0
	jz	NotFirstYet

	cmp	LoadSampAsInst2,0
	jz	LoadAsSamples1

	movzx	ecx,Samples
	xor	ebx,ebx
GetEmptyInstLoop2:
	call	CheckInstEmpty
	jnc	NotFirstYet2
	inc	CurrentInstrument
	loop	GetEmptyInstLoop2
	call	AddAnEmptySample2

NotFirstYet2:
	movzx	ax,CurrentInstrument
	shl	ax,4
	mov	CurrentSample,ax
	jmp	NotFirstYet
LoadAsSamples1:
	mov	ecx,16
	movzx	ebx,CurrentInstrument
	shl	ebx,4
	dec	ebx
GetEmptySampleLoop:
	inc	ebx
	mov	eax,[SampleOffsetEnd+ebx*4]
	sub	eax,[SampleOffsetStart+ebx*4]
	loopnz	GetEmptySampleLoop
	jnz	QuitSampInst
	mov	CurrentSample,bx
NotFirstYet:
	cmp	CurrentInstrument,0
	jz	QuitSampInst
	cmp	OneSampleLoaded,1
	jz	LoadOkay
	movzx	ebp,CurrentSample
	mov	eax,[SampleOffsetEnd+ebp*4]
	sub	eax,[SampleOffsetStart+ebp*4]
	jz	LoadOkay
	cmp	AskReplaceSample,0
	jz	LoadOkay
	lea	esi,SampleExists
	mov	Menu_Popup,2
	call	MouseArrow
	mov	al,DoubleClick
	call	PopUpHandler
	mov	DoubleClick,al
	call	MouseHourGlass
	cmp	PopupStatus,1
	jnz	NoTofflor
LoadOkay:
	lea	edx,ModName
;	 call	 SetZeroVol
;	 call	 stoptimer

	call	LoadMod 	;A sample
	pushf
	cmp	LoadSampAsInst2,0
	jz	LoadAsSamples2
	mov	[DragBarData+(13*4)*6+0],0
	mov	[DragBarData+(13*4)*7+0],0
LoadAsSamples2:
;	 call	 starttimer
;	 call	 SetOrigVol
	popf
	jnc	NoTofflor
	pushad
	mov	DontDisallocSample,1
	call	KillSample2
	mov	DontDisallocSample,0
	popad
	mov	ebp,1024
	call	MemDisalloc
	mov	ebp,1025
	call	MemDisalloc
	call	UpdateSampNames
	call	UpdateInstNames
	call	UpdateFileList
	call	MouseArrow
	jmp	ErrorHandler
NoTofflor:
	mov	OneSampleLoaded,1
	movzx	eax,CurrentSample
	mov	ecx,[SampleOffsetEnd+eax*4]
	sub	ecx,[SampleOffsetStart+eax*4]
	mov	SampLength,ecx

	mov	SampBits,0
	cmp	TypeFile,3
	jz	NotConvert
	cmp	TypeFile,7
	jnz	NoWAV
	bt	word ptr [VoiceControl+eax],2
	jnc	NotConvert
	mov	SampBits,1
NoWAV:
	cmp	TypeFile,42h
	jnz	NoASE
	bt	word ptr [VoiceControl+eax],2
	jnc	DoConvert
	mov	SampBits,1
	jmp	DoConvert
NoASE:
	cmp	TypeFile,0
	jnz	DoConvert
	cmp	LoadSampleConvert,0
	jz	notconvert
DoConvert:
	call	justconvert
NotConvert:

	mov	ebp,1025
	call	MemDisalloc
	mov	UndoSampLength,0
	call	viewall2

	mov	ax,CurrentSample
	test	ax,0fh
	jnz	LoadNextSample
	movzx	eax,CurrentInstrument
	dec	eax
	mov	ebx,30
	mul	ebx
	add	eax,InstNamesPtr
	mov	edi,eax
	mov	ecx,30
	xor	al,al
	rep	stosb
	sub	edi,30

	movzx	eax,CurrentInstrument
	dec	eax
	shl	eax,4
	mov	ebx,22
	mul	ebx
	add	eax,SampleNamesPtr
	mov	esi,eax
	mov	ecx,22
	rep	movsb
LoadNextSample:
	call	MouseOff
	call	PrintSampleInfo
	call	UpdateSampNames
	call	UpdateInstNames
	call	MouseOn

	cmp	DoubleClick,1
	jz	QuitSampInst
	call	GetLoadName
	jc	QuitSampInst
	call	UpdateFileList

	cmp	TypeFile,42h
	jz	@@Skutt
	cmp	TypeFile,0ah
	jae	LoadNextSample
	cmp	TypeFile,05h
	jz	LoadNextSample
	cmp	TypeFile,06h
	jz	LoadNextSample
	cmp	TypeFile,08h
	jz	LoadNextSample
@@Skutt:
	cmp	OneLoaded,1
	jz	NotFirst
	mov	OneLoaded,1
	cmp	LoadSampAsInst2,2
	jnz	NotFirst
	lea	esi,LoadAsInst
	mov	Menu_Popup,2
	call	MouseArrow
	mov	al,DoubleClick
	call	PopUpHandler
	mov	DoubleClick,al
	call	MouseHourGlass
	mov	LoadSampAsInst2,0
	cmp	PopupStatus,1
	jnz	NotFirst
	mov	LoadSampAsInst2,1
NotFirst:
	cmp	LoadSampAsInst2,0
	jz	LoadSample2
	mov	al,CurrentInstrument
	cmp	al,Samples
	jnz	LoadSample2
	call	AddAnEmptySample2
	jmp	LoadSample2

PressWildButton:
	pushad
	mov	esi,CurrentFileType
	movzx	eax,[OldWildTBL+esi]


	call	PWB
	mov	bl,1

	call	ButtonUpDown

	mov	esi,CurrentFileType
	movzx	eax,[CurrentWildTBL+esi]
	mov	[OldWildTBL+esi],al

	call	PWB
	mov	bl,0

	call	ButtonUpDown
	popad
	ret
PWB:
	cmp	eax,8
	jnz	NotWildAll
	mov	ecx,0
	mov	eax,227
	jmp	CalcButtPos
NotWildAll:
	cmp	eax,9
	jnz	NotWildMix
	mov	ecx,1
	mov	eax,227
	jmp	CalcButtPos
NotWildMix:
	xor	edx,edx
	mov	bx,4
	div	bx
	mov	ecx,eax
	mov	eax,edx
	mov	ebx,56
	mul	ebx
CalcButtPos:
	mov	ButtonX1,280
	mov	ButtonX2,280+55
	mov	ButtonY1,188
	mov	ButtonY2,188+16
	add	ButtonX1,eax
	add	ButtonX2,eax
	shl	ecx,4
	bt	cx,4
	adc	ecx,0
	add	ButtonY1,ecx
	add	ButtonY2,ecx
	ret

LoadPatt:
	call	StopAllVoices
	call	MouseHourGlass
	call	PauseMusic
	call	LoadMod
	pushf
	push	ax
	mov	FileEdited,1
	mov	OldRow,-1
	mov	OldPos,-1
	mov	OldPos2,-1
	mov	OldPattName,-1
	mov	OldPatt,-2
	mov	OldPatt2,-2
	mov	OldCurrentChannel,-1
	mov	TuneChannelON,-1
	mov	CurrentChannel,0
	mov	CursorChannel,0
	mov	ArrowPointer,0
	call	FixAllocChannels
	pop	ax
	popf
	jc	ErrorHandler

	movzx	ebx,CurrPatt2
	call	PattInit
	call	UpdateChannelInfo
	call	UpdateFileList
	call	UnPauseMusic
	call	mousearrow
	cmp	TuneStopped,1
	jz	_ret
	call	StartMod
	ret

;Correct drive and path is set
DiaParma	db	0
Root		db	'\',0
ParsePath	Proc	Near
	pushad
	mov	esi,CurrentPathPtr
	lea	edi,TempPath
	mov	ecx,67
	rep	movsb

	mov	edi,CurrentPathPtr
	push	edi
	mov	al,0
	mov	ecx,67+12
	rep	stosb
	pop	edi
	lea	esi,TempPath

	mov	DiaParma,1
	cmp	byte ptr [esi+1],':'		;Check if to change drive
	jz	DriveNow
	mov	al,CurrentDrive
	mov	byte ptr [edi],al
	mov     byte ptr [edi+1],':'
	mov     byte ptr [edi+2],'\'
	add	edi,3
	jmp	NoDriveChange
DriveNow:
	mov	al,byte ptr [esi]
	cmp	al,'a'
	jb	NoCorr
	sub	al,32
	mov	byte ptr [esi],al
NoCorr:
	mov	byte ptr [edi],al
	mov	byte ptr [edi+1],':'
	mov	byte ptr [edi+2],'\'
	add	edi,3
	add	esi,2
	cmp	al,CurrentDrive
	jz	NoDriveChange
	sub	esi,3
	push	esi
	call	ChangeDrive2
	pop	esi
	add	esi,3
NoDriveChange:

	mov	ecx,67
	xor	ebx,ebx
Snutt:
	cmp	byte ptr [esi+ebx],'\'
	jz	FoundOne
	cmp	byte ptr [esi+ebx],0
	jz	ChangeIt
	inc	ebx
	dec	ecx
	jnz	Snutt
	jmp	Wooh
FoundOne:
	inc	ebx
FoundTwo:
	mov	al,[esi]
	mov	[edi],al
	inc	esi
	inc	edi
	dec	ebx
	jnz	FoundTwo
	dec	ecx
	jnz	Snutt
	jmp	Wooh

ChangeIt:
	push	edi
	mov	edi,SaveName		;Move Pathname to SaveName
	mov	ecx,12
	rep	movsb
	pop	edi

	lea	edx,Root
	call	ChangePath

	mov	al,byte ptr [edi-1]
	mov	byte ptr [edi-1],0
	mov	edx,CurrentPathPtr
	add	edx,3
	push	ax
	call	ChangePath
	pop	ax
	mov	byte ptr [edi-1],al
	cmp	al,':'
	jnz	Wooh
	mov	byte ptr [edi],'\'
Wooh:
	mov	FileListStart,1
	call	GetFileList
	mov	OldCurrentFileName,-1
	mov	DiaParma,0
	popad
	ret
ParsePath	EndP

PauseMusic	Proc	Near
	call	StopTimer
	call	SetZeroVol
	ret
PauseMusic	EndP

UnPauseMusic	Proc	Near
	call	StartTimer
	call	SetOrigVol
	ret
UnPauseMusic	Endp


;/ABS\01481008150231002310023100231002310012670166101875
