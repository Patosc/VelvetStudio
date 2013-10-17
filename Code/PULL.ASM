;/ACS\=s
;/ABS\00996013290132901329013290132901329013290132901329
;±±±±±±±±±
;Procs:
;  WriteTopBar ----------------------------------------------------------
;		In:   Eax = BarNumber
;  ScanBoxData ----------------------------------------------------------
;		In:   Esi = PullDown Info Offset
;  GetKeyInfo -----------------------------------------------------------
;		In:   Eax = Offset to proc
;		Out:  Eax = Length of text
;		      KeyInfoText = The keytext
;  PutPullDownBox -------------------------------------------------------
;		In:   Edi = ScreenOffset
;		      Eax = Bar Select (-1 = No bar selected)
;

_retp:
EndPop:
popad
ret

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Variables
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

BoxesToClip	dd	0			;Number of boxes
BoxClip 	dd	4*4	  dup(-1)
		dd	-1
BoxClipByte	dd	4*4	  dup(-1)
		dd	-1
								   ;65535=don't care
;X1,Y1,X2,Y2,StartKey,Menu_popup,Menu_down,Menu_upperleft,Menu_UpperRight,pulldown
StartPullDown	dd	1,0,639,17,1,0,-1,-1,-1,PullDownMain	   ;10x4
		dd	3,226,19,257,2,0,0,-1,-1,Pull_Pattern
		dd	3,226,19,257,2,0,1,-1,-1,Pull_Pattern
		dd	3,226,19,257,2,0,2,-1,-1,Pull_Pattern
		dd	3,226,19,257,2,0,3,-1,-1,Pull_Pattern
		dd	3,226,19,257,2,0,4,-1,-1,PullDownSampEd
		dd	3,226,19,257,2,0,5,-1,-1,PullDownSampEd
		dd	3,226,19,257,2,0,6,-1,-1,Pull_Desc
		dd	3,226,19,257,2,0,7,-1,-1,Pull_Env

		dd	157,18,190,34,3,0,-1,-1,0,PullDownDiskOp
		dd	157,18,190,34,3,0,-1,-1,3,PullDownDiskOp
;		 dd	 157,18,190,34,3,0,-1,-1,4,PullDownConfig
;		 dd	 157,18,190,34,3,0,-1,-1,5,PullDownDiskOp

		dd	3,88,36,104,3,0,-1,0,-1,PosedScreen
		dd	3,88,36,104,3,0,-1,1,-1,PosedScreen
		dd	3,88,36,104,3,0,-1,2,-1,PosedScreen
		dd	3,88,36,104,3,0,-1,3,-1,PosedScreen

		dd	-1

PullDownMain	dw	0,0,0		   ;Windowpos,Barpos,MoreBarpos
		dw	0,0,640 	 ;Xpos,Ypos,Length
;MainPullText	db	" UPPER BLOCK | LOWER BLOCK | LEFT BLOCK | CLEAR | CONFIG | ABOUT | HELP ",0 ;TopText
MainPullText	db	" UPPER BLOCK | LOWER BLOCK | LEFT BLOCK | CLEAR | CONFIG | HELP ",0 ;TopText
MainPullTextLength equ $-MainPullText

BL1a		db    " Main Screen ",0,50,0,1
		dd    Biure
BL1b		db    " Disk Option ",0,50,1,1
		dd    DiskOpStart3
BL1e		db    " Toggle Piano ",0,50,0,1
		dd    dopiano
BL1f		db    " Toggle Equalizer ",0,50,1,1
		dd    ToggleEQ
		db    " DOS Shell     ",0,50,0,0
		dd    Shell
		db    " Exit Tracker ",0,50,0,0
		dd    TrackerEnd
		dd    -1
		db    -1

BL2a		db    " Protracker Pattern ",0,50,0,1              ;Windows
		dd    setprotracker
BL2b		db    " ScreamTracker Pattern ",0,50,1,1
		dd    setscreamtracker
BL2d		db    " Desc Editor        ",0,50,0,1
		dd    DescriptionStart2
BL2e		db    " Instrument Editor  ",0,50,0,1
		dd    EnvelopeStart2
BL2c		db    " Sample Editor      ",0,50,1,1
		dd    SampleEditor2_
BL2f		db    " Toggle Zoom        ",0,50,0,1
		dd    zoompattern
		dd    -1
		db    -1

BL3a		db     " Pattern Info ",0,50,0,1
		dd     Nooo
BL3c		db     " Position Editor",0,50,0,1
		dd     PositionEditor2
BL3b		db     " Sample Info ",0,50,0,1
		dd     Naaa
BL3d		db     " Song specific Settings",0,50,0,1
		dd     Gooo
		dd	-1
		db	-1

		db    "Channel names",0,50,0,1
		dd    Clearthetracknames
		db    "Current Instrument",0,50,0,1
		dd    KillInstrument
		db    "Description",0,50,0,1
		dd    ClearDescription
		db    "Everything",0,50,0,1
		dd    Clearallshit2
		db    "Inst. and Sample names",0,50,0,1
		dd    ClearInstNames
		db    "Instruments",0,50,0,1
		dd    Clearsamples2
		db    "Pattern names",0,50,0,1
		dd    ClearthePatternNames
		db    "Song data",0,50,0,1
		dd    Clearthesong2
		dd    -1
		db    -1

		db    " Color Setup...",0,50,0,1
		dd    _ColorsStart
		db    " Configure Paths...",0,50,0,1
		dd    ConfigPathStart
		db    " Configure SoundCard...",0,50,0,1
		dd    PutUpSCConfig
		db    " Equalizer Editor...",0,50,0,1
		dd    EQEditStart
		db    " Key Map...",0,50,0,1
		dd    KeysStart
		db    " Options...",0,50,0,1
		dd    OptionStart
		db    " Pattern Defaults...",0,50,1,1
		dd    PattDefStart
		db    " Save Config",0,50,0,1
		dd    ConfigSave
AutoSave	db    " AutoSave Config",0,50,0,1
		dd    AutoConfigSave
;		db    "Save Keys <- REMOVE",0,50,0,1
;		dd    SaveKeyConfig
		dd    -1
		db    -1

		db	"Contents",0,50,1,1
		dd	HelpStart2
		db	"About Velvet Studio...",0,50,0,1     ;Zero,MenuKey,1=Line,1=Enable Keyinfo
		dd	AboutTracker
		db	"About Velvet Dev...",0,50,0,1
		dd	AboutExtreme
		db	"Contact information...",0,50,0,1
		dd	ContactExtreme
		dd	-1
		db	-1
		dd	-1
		db	-1

PullDownSampEd	dw	1,0,0
		dw	0,223,640
		db	" WINDOWS ",0
		  db	"Protracker Pattern ",0,50,0,1              ;Windows
		  dd	setprotracker
		  db	"ScreamTracker Pattern ",0,50,1,1
		  dd	setscreamtracker
		  db	"Desc Editor        ",0,50,0,1
		  dd	DescriptionStart2
		  db	"Instrument Editor  ",0,50,0,1
		  dd	EnvelopeStart2
		  db	"Sample Editor      ",0,50,1,1
		  dd	SampleEditor2_
		  db	"Toggle Zoom        ",0,50,0,1
		  dd	zoompattern
		  dd	-1
		  db	-1
		dd	-1
		db	-1


PullDownDiskOp	dw	0,0,0
		dw	152,18,488
		db	" WINDOWS ",0
		  db	 " Main Screen ",0,50,0,1
		  dd	 Biure
		  db	 " Disk Option ",0,50,1,1
		  dd	 DiskOpStart3
PDDO1		  db	 " Toggle Piano ",0,50,0,1
		  dd	 dopiano
PDDO2		  db	 " Toggle Equalizer ",0,50,0,1
		  dd	ToggleEQ
		  dd	  -1
		  db	  -1
		  dd	  -1
		  db	  -1


Pull_Pattern	dw	0,0,0
		dw	0,223,640
		db	" WINDOWS | EDIT | BLOCK | TRANSPOSE | PLAY | MISC ",0;
		  db	"Protracker Pattern ",0,50,0,1              ;Windows
		  dd	setprotracker
		  db	"ScreamTracker Pattern ",0,50,1,1
		  dd	setscreamtracker
		  db	"Desc Editor        ",0,50,0,1
		  dd	DescriptionStart2
		  db	"Instrument Editor  ",0,50,0,1
		  dd	EnvelopeStart2
		  db	"Sample Editor      ",0,50,1,1
		  dd	SampleEditor2_
		  db	"Toggle Zoom        ",0,50,0,1
		  dd	zoompattern
		  dd	-1
		  db	-1
;		  db	"Protracker Pattern ",0,50,0,1
;		  dd	setprotracker
;		  db	"ScreamTracker Pattern ",0,50,0,1
;		  dd	setscreamtracker
;		  db	"Sample Editor      ",0,50,0,1
;		  dd	SampleEditor2_
;		  db	"Desc Editor        ",0,50,0,1
;		  dd	DescriptionStart2
;		  db	"Instrument Editor  ",0,50,1,1
;		  dd	EnvelopeStart2
;		  db	"Toggle Zoom        ",0,50,0,1
;		  dd	zoompattern
;		  dd	-1
;		  db	-1
		  db	"Cut ",0,50,0,1                        ;EDIT
		  dd	0
		    db	"Channel",0,50,0,1
		    dd	CutChannel
		    db	"Pattern",0,50,0,1
		    dd	CutPattern
		    db	"Command",0,50,0,1
		    dd	CutCommand
		    db	-1
		    dd	-1
		  db	"Copy ",0,50,0,1
		  dd	0
		    db	"Channel",0,50,0,1
		    dd	CopyChannel
		    db	"Pattern",0,50,0,1
		    dd	CopyPattern
		    db	"Command",0,50,0,1
		    dd	CopyCommand
		    db	-1
		    dd	-1
		  db	"Paste ",0,50,0,1
		  dd	0
		    db	"Channel",0,50,0,1
		    dd	PasteChannel
		    db	"Pattern",0,50,0,1
		    dd	PastePattern
		    db	"Command",0,50,0,1
		    dd	PasteCommand
		    db	-1
		    dd	-1
		  db	"Kill",0,50,0,1
		  dd	0
		    db	"Rest of channel",0,50,0,1
		    dd	KillToEnd
		    db	"Sample at channel",0,50,0,1
		    dd	KillSampleAtChannel
		    db	-1
		    dd	-1
		  db	"One Command Copy",0,50,0,1
		  dd	0
		    db	"Copy",0,50,0,1
		    dd	CopyOneAboveCommand
		    db	"Copy+Increase",0,50,0,1
		    dd	CopyOneAboveCommandInc
		    db	"Copy+Decrease",0,50,0,1
		    dd	CopyOneAboveCommandDec
		    db	-1
		    dd	-1
		  db	"All Command Copy",0,50,0,1
		  dd	0
		    db	"Copy",0,50,0,1
		    dd	CopyAllAboveCommand
		    db	"Copy+Increase",0,50,0,1
		    dd	CopyAllAboveCommandInc
		    db	"Copy+Decrease",0,50,0,1
		    dd	CopyAllAboveCommandDec
		    db	-1
		    dd	-1
		  db	"Contract",0,50,0,1
		  dd	0
		    db	"Channel",0,50,0,1
		    dd	ContractOneChannel
		    db	"Pattern",0,50,0,1
		    dd	ContractPattern
		    db	-1
		    dd	-1
		  db	"Expand",0,50,1,1
		  dd	0
		    db	"Channel",0,50,0,1
		    dd	ExpandOneChannel
		    db	"Pattern",0,50,0,1
		    dd	ExpandPattern
		    db	-1
		    dd	-1
		  db	"Toggle Editmode",0,50,0,1
		  dd	Space
		  dd	-1
		  db	-1

		  db	"Block Begin",0,50,0,1                 ;BLOCK
		  dd	MarkBlockBeg
		  db	"Block Cut",0,50,0,1
		  dd	CutBlock
		  db	"Block Copy",0,50,0,1
		  dd	CopyBlock
		  db	"Block Paste",0,50,0,1
		  dd	PasteBlock
		  db	"Block Insert",0,50,0,1
		  dd	InsertBlock
		  db	"Block Delete",0,50,0,1
		  dd	DeleteBlock
		  db	"Block Range",0,50,0,1
		  dd	RampCommandData
		  dd	-1
		  db	-1

		  db	"Sample/Channel",0,50,0,1              ;TRANSPOSE
		  dd	0
		    db	"Octave Up",0,50,0,1
		    dd	OctaveUpST
		    db	"Octave Down",0,50,0,1
		    dd	OctaveDownST
		    db	"Note Up",0,50,0,1
		    dd	NoteUpST
		    db	"Note Down",0,50,0,1
		    dd	NoteDownST
		    db	-1
		    dd	-1
		  db	"All/Channel",0,50,0,1
		  dd	0
		    db	"Octave Up",0,50,0,1
		    dd	OctaveUpAT
		    db	"Octave Down",0,50,0,1
		    dd	OctaveDownAT
		    db	"Note Up",0,50,0,1
		    dd	NoteUpAT
		    db	"Note Down",0,50,0,1
		    dd	NoteDownAT
		    db	-1
		    dd	-1
		  db	"Sample/Pattern",0,50,0,1
		  dd	0
		    db	"Octave Up",0,50,0,1
		    dd	OctaveUpSP
		    db	"Octave Down",0,50,0,1
		    dd	OctaveDownSP
		    db	"Note Up",0,50,0,1
		    dd	NoteUpSP
		    db	"Note Down",0,50,0,1
		    dd	NoteDownSP
		    db	-1
		    dd	-1
		  db	"All/Pattern",0,50,0,1
		  dd	0
		    db	"Octave Up",0,50,0,1
		    dd	OctaveUpAP
		    db	"Octave Down",0,50,0,1
		    dd	OctaveDownAP
		    db	"Note Up",0,50,0,1
		    dd	NoteUpAP
		    db	"Note Down",0,50,0,1
		    dd	NoteDownAP
		    db	-1
		    dd	-1
		  db	"Sample/Block",0,50,0,1
		  dd	0
		    db	"Octave Up",0,50,0,1
		    dd	OctaveUpSB
		    db	"Octave Down",0,50,0,1
		    dd	OctaveDownSB
		    db	"Note Up",0,50,0,1
		    dd	NoteUpSB
		    db	"Note Down",0,50,0,1
		    dd	NoteDownSB
		    db	-1
		    dd	-1
		  db	"All/Block",0,50,0,1
		  dd	0
		    db	"Octave Up",0,50,0,1
		    dd	OctaveUpAB
		    db	"Octave Down",0,50,0,1
		    dd	OctaveDownAB
		    db	"Note Up",0,50,0,1
		    dd	NoteUpAB
		    db	"Note Down",0,50,0,1
		    dd	NoteDownAB
		    db	-1
		    dd	-1
		  db	-1
		  dd	-1

		  db	"Play",0,50,0,1                        ;PLAY
		  dd	0
		    db	"Song",0,50,0,1
		    dd	StartMod
		    db	"Pattern",0,50,1,1
		    dd	StartPatt
		    db	"Current Row",0,50,0,1
		    dd	PlayRow
		    db	"One Row",0,50,0,1
		    dd	PlayRow_A
		    db	-1
		    dd	-1
		  db	"Record",0,50,0,1
		  dd	0
		    db	"Song",0,50,0,1
		    dd	RecSong
		    db	"Pattern",0,50,0,1
		    dd	RecPatt
		    db	-1
		    dd	-1
		  db	-1
		  dd	-1

		  db	"Mute/Lock Channel",0,50,0,1                 ;MISC
		  dd	MuteOne
		  db	"Mute All Channels",0,50,0,1
		  dd	MuteAll2
		  db	"Unmute All Channels",0,50,0,1
		  dd	UnMuteAll2
		  db	"Solo Channel",0,50,1,1
		  dd	SoloOne

		  db	"Go to stored row",0,50,0,1
		  dd	0
		    db	"Slot number 1",0,50,0,1
		    dd	JumpPattern1
		    db	"Slot number 2",0,50,0,1
		    dd	JumpPattern2
		    db	"Slot number 3",0,50,0,1
		    dd	JumpPattern3
		    db	"Slot number 4",0,50,0,1
		    dd	JumpPattern4
		    dd	  -1
		    db	  -1
		  db	"Store row",0,50,0,1
		  dd	0
		    db	"Slot number 1",0,50,0,1
		    dd	StorePattern1
		    db	"Slot number 2",0,50,0,1
		    dd	StorePattern2
		    db	"Slot number 3",0,50,0,1
		    dd	StorePattern3
		    db	"Slot number 4",0,50,0,1
		    dd	StorePattern4
		    dd	  -1
		    db	  -1
		  db	"Play from stored row",0,50,0,1
		  dd	0
		    db	"Slot number 1",0,50,0,1
		    dd	PlayPattern1
		    db	"Slot number 2",0,50,0,1
		    dd	PlayPattern2
		    db	"Slot number 3",0,50,0,1
		    dd	PlayPattern3
		    db	"Slot number 4",0,50,0,1
		    dd	PlayPattern4
		    dd	  -1
		    db	  -1
		  db	"Record from stored row",0,50,1,1
		  dd	0
		    db	"Slot number 1",0,50,0,1
		    dd	RecPattern1
		    db	"Slot number 2",0,50,0,1
		    dd	RecPattern2
		    db	"Slot number 3",0,50,0,1
		    dd	RecPattern3
		    db	"Slot number 4",0,50,0,1
		    dd	RecPattern4
		    dd	  -1
		    db	  -1
		  dd	-1
		  db	-1

		  db	-1
		  dd	-1

Pull_Desc	dw	0,0,0
		dw	0,223,640
		db	" WINDOWS ",0
		  db	"Protracker Pattern ",0,50,0,1              ;Windows
		  dd	setprotracker
		  db	"ScreamTracker Pattern ",0,50,1,1
		  dd	setscreamtracker
		  db	"Desc Editor        ",0,50,0,1
		  dd	DescriptionStart2
		  db	"Instrument Editor  ",0,50,0,1
		  dd	EnvelopeStart2
		  db	"Sample Editor      ",0,50,1,1
		  dd	SampleEditor2_
		  db	"Toggle Zoom        ",0,50,0,1
		  dd	zoompattern
		  dd	-1
		  db	-1
;		  db	 "Protracker Pattern ",0,50,0,1
;		  dd	 setprotracker
;		  db	 "ScreamTracker Pattern ",0,50,0,1
;		  dd	 setscreamtracker
;		  db	 "Sample Editor      ",0,50,0,1
;		  dd	 SampleEditor2_
;		  db	 "Desc Editor        ",0,50,0,1
;		  dd	 DescriptionStart2
;		  db	 "Instrument Editor  ",0,50,1,1
;		  dd	 EnvelopeStart2
;		  db	"Toggle Zoom        ",0,50,0,1
;		  dd	zoompattern
;		  dd	  -1
;		  db	  -1
		  dd	  -1
		  db	  -1

Pull_Env	dw	0,0,0
		dw	0,223,640
		db	" WINDOWS ",0
		  db	"Protracker Pattern ",0,50,0,1              ;Windows
		  dd	setprotracker
		  db	"ScreamTracker Pattern ",0,50,1,1
		  dd	setscreamtracker
		  db	"Desc Editor        ",0,50,0,1
		  dd	DescriptionStart2
		  db	"Instrument Editor  ",0,50,0,1
		  dd	EnvelopeStart2
		  db	"Sample Editor      ",0,50,1,1
		  dd	SampleEditor2_
		  db	"Toggle Zoom        ",0,50,0,1
		  dd	zoompattern
		  dd	-1
		  db	-1
;		  db	 "Protracker Pattern ",0,50,0,1
;		  dd	 setprotracker
;		  db	 "ScreamTracker Pattern ",0,50,0,1
;		  dd	 setscreamtracker
;		  db	 "Sample Editor      ",0,50,0,1
;		  dd	 SampleEditor2_
;		  db	 "Desc Editor        ",0,50,0,1
;		  dd	 DescriptionStart2
;		  db	 "Instrument Editor  ",0,50,1,1
;		  dd	 EnvelopeStart2
;		  db	"Toggle Zoom        ",0,50,0,1
;		  dd	zoompattern
;		  dd	  -1
;		  db	  -1
		  dd	  -1
		  db	  -1



PosedScreen	dw	0,0,0
		dw	0,88,156
		db	" WINDOWS ",0
		  db	 "Pattern Info ",0,50,0,1
		  dd	 Nooo
		  db	 "Position Editor",0,50,0,1
		  dd	 PositionEditor2
		  db	 "Sample Info ",0,50,0,1
		  dd	 Naaa
		  db	 "Song specific Settings",0,50,0,1
		  dd	 Gooo
		  dd	  -1
		  db	  -1
		  dd	  -1
		  db	  -1


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Write Top Bar
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:    eax=BarNumber
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
TheBarNumber	dd	0
WriteTopBar	Proc	Near
	pushad
	mov	TheBarNumber,eax
	mov	ebx,10*4			;Prepare ebp
	mul	ebx
	mov	ebp,[eax+36+StartPullDown]

	movzx	eax,word ptr [ebp+8]		;Prepare edi
	mov	ebx,80
	mul	ebx
	movzx	ebx,word ptr [ebp+6]
	shr	ebx,3
	add	eax,ebx
	move	edi,0a0000h
	add	edi,eax

	call	mouseoff			;put top bar
	planewrite 00001111b
	call	putblackline
	call	putwhiteline
	call	putwhiteline
	add	edi,80*12
	call	putwhiteline
	call	putblackline
	sub	edi,80*14
	call	writetoptext
	call	mouseon

	popad
	ret
WriteTopBar	Endp
PutWhiteLine	proc	near
	push	edi
	movzx	ecx,word ptr [ebp+10]		;Put WhiteLine --------------
	shr	ecx,3
	mov	al,01111111b
	stosb
	sub	ecx,2
	mov	al,-1
	rep	stosb
	mov	al,11111110b
	stosb
	pop	edi
	add	edi,80
	ret
PutWhiteLine	endp
PutBlackLine	proc	near
	movzx	ecx,word ptr [ebp+10]		;Put Black Line -------------
	shr	ecx,3
	push	edi
	mov	al,0
	rep	stosb
	pop	edi
	add	edi,80
	ret
PutBlackLine	endp
WinPos		dd	0
WinCount	dd	0
TheFirst	db	0
WriteTopText	proc	near			;Write Top Text -------------
	pushad
	movzx	ecx,word ptr [ebp+10]
	shr	ecx,3

	movzx	eax,word ptr [ebp]
	mov	winpos,eax
	mov	wincount,0
	mov	thefirst,1

	push	ebp			;put text
PuttaTexts:
	movzx	ebx,byte ptr [ebp+12]
	inc	ebp
	cmp	ebx,'|'
	jnz	nonewwin
	inc	wincount
	jmp	puttatexts
nonewwin:
	cmp	ebx,0
	jz	quittatexts


	mov	esi,[AllocTable+1040*8]
	lea	ebx,[ebx+ebx*2]
	lea	ebx,[ebx*4]
	add	esi,ebx


	mov	eax,winpos
	cmp	eax,wincount
	jz	putinvert

	push	edi		;put real
	mov	edx,12
PuttaChar:
	lodsb
	not	al
	cmp	thefirst,0
	jz	nononooj
	and	al,01111111b
nononooj:
	stosb
	add	edi,80-1
	dec	edx
	jnz	puttachar
	pop	edi
	jmp	afterinvert

putinvert:
	push	edi		;put invert
	mov	edx,12
PuttaChar2:
	movsb
	add	edi,80-1
	dec	edx
	jnz	puttachar2
	pop	edi
	mov	byte ptr [edi-80],0
	mov	byte ptr [edi-80*2],0
	mov	byte ptr [edi+80*12],0
afterinvert:
	mov	thefirst,0

	dec	ecx
	inc	edi
	jmp	puttatexts
quittatexts:
	pop	ebp

	dec	ecx
	cmp	ecx,0
	jle	skipwhiteit		;put white

	mov	edx,12
	mov	al,-1
	push	edi
whiteloop:
	pushad
	rep	stosb
	popad
	add	edi,80
	dec	edx
	jnz	whiteloop
skipwhiteit:
	pop	edi
	add	edi,ecx

	mov	al,11111110b		;put last
	mov	edx,12
	xor	esi,esi
PutLastHere:
	mov	[edi+esi],al
	add	esi,80
	dec	edx
	jnz	PutLastHere
	dec	ecx
	inc	edi


	popad
	add	edi,80*12
	ret
WriteTopText	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Scan Box Data
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:    esi=PullDown Info Offset
;	    eax=Box type 1=MainBix 2=MoreBox
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SaveBytes		db	5	dup(0)
PullDownTexts		db	50*30	dup(0)	 ;Text and byte info
PullDownKeyTexts	db	20*30	dup(0)
PullDownOffsets 	dd	30	dup(0)
TextNumbers		dw	0
MaxTextLength		dw	0
BoxType 		dd	0
thepullkeys		db	30	dup(0)
thepullkeyscount	dd	0
ScanBoxData	Proc	Near
	pushad
	mov	BoxType,eax
	mov	MaxTextLength,0
	mov	TextNumbers,0
	lea	edi,PullDownTexts
	lea	ebp,PullDownOffsets
	lea	edx,PullDownKeyTexts
	mov	thepullkeyscount,0

ScanBoxLoop:
	xor	cx,cx			;Search through text and copy...
ScanBox1:
	lodsb
	inc	cx
	stosb
	cmp	al,0
	jnz	ScanBox1
	push	eax
	push	ebx
	mov	al,byte ptr [esi]
	mov	ebx,thepullkeyscount
	mov	[ebx+thepullkeys],al
	inc	thepullkeyscount
	pop	ebx
	pop	eax
	movsw
	movsb

	cmp	dword ptr [esi],0	;Skip more if exist...
	jnz	NoMorePopUp
	add	esi,4
LoopSkipMore:
	lodsb
	cmp	al,-1
	jnz	LoopSkipMore
	cmp	dword ptr [esi],-1
	jnz	LoopSkipMore
	add	esi,4
	mov	dword ptr [ebp],0
	add	ebp,4
	mov	byte ptr [edx],0
	inc	edx
	add	cx,2
	cmp	cx,MaxTextLength
	jbe	CheckTheEnd
	mov	MaxTextLength,cx
	jmp	CheckTheEnd
NoMorePopUp:
					;Get Max Length
	lodsd
	mov	[ebp],eax
	add	ebp,4
	call	GetKeyInfo
	add	cx,ax
	cmp	cx,MaxTextLength
	jbe	NoChangeNow
	mov	MaxTextLength,cx
NoChangeNow:
					;Move Key texts
	movzx	ecx,ax
	jecxz	NoEcx
	push	esi
	lea	esi,KeyInfoText
MoveKeyTexts:
	lodsb
	mov	[edx],al
	inc	edx
	loop	MoveKeyTexts
	pop	esi
NoEcx:
	mov	byte ptr [edx],0
	inc	edx
CheckTheEnd:
	inc	TextNumbers		;Check if end
	cmp	byte ptr [esi],-1
	jnz	ScanBoxLoop
	cmp	dword ptr [esi+1],-1
	jnz	ScanBoxLoop

	cmp	boxtype,2		;copy boxtype
	jz	morebox
	mov	ecx,30*4+2+2
	lea	esi,PullDownOffsets
	lea	edi,MainPullDownOffsets
	rep	movsb
	popad
	ret
morebox:
	mov	ecx,30*4+2+2
	lea	esi,PullDownOffsets
	lea	edi,MorePullDownOffsets
	rep	movsb
	popad
	ret
ScanBoxData	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Get Key Info
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; In:  Eax=Offset to proc
; Out: Eax=Length of text
;      KeyInfoText=The keytext
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
KeyInfoText	db	25	dup(0)
InfoOutPut	dd	0
GetKeyInfo	Proc	Near
	pushad

	xor	esi,esi 		;Scan for used key
	mov	ecx,525
GetKeyInfoLoop:
	cmp	eax,[esi+KeyBoardTable]
	jz	AfterGetInfo
	add	esi,4
	loop	GetKeyInfoLoop
NoKeyNow:
	popad
	xor	eax,eax
	ret
AfterGetInfo:

					;Get MainKey and ShiftKey
	mov	eax,esi
	shr	eax,2
	mov	ebx,5
	xor	edx,edx
	div	ebx
	lea	edi,KeyInfoText

	lea	esi,specialkeys
Searchkeynow_:				 ;get key
	cmp	byte ptr [esi],-1
	jz	nokeysfound_
	cmp	byte ptr [esi],al
	jz	skipsearchnow_
addaloop_:
	inc	esi
	cmp	byte ptr [esi-1],0
	jnz	addaloop_
	jmp	searchkeynow_

nokeysfound_:				 ;get character and print a character
	mov	esi,keyboard_table
	mov	ecx,55
searchkeynow2_:
	cmp	byte ptr [esi],al
	jz	skipsearchnow2_
	add	esi,2
	loop	searchkeynow2_
	jmp	NoKeyNow
skipsearchnow2_:
	mov	ebp,1
	movzx	ebx,byte ptr [esi+1]
	mov	[edi],bl
	inc	edi
	jmp	nextpartofput_

skipsearchnow_: 				 ;print key
	inc	esi
	xor	ebp,ebp
printaloop_:
	movzx	ebx,byte ptr [esi]
	mov	[edi],bl
	inc	esi
	inc	edi
	inc	ebp
	cmp	byte ptr [esi],0
	jnz	printaloop_

nextpartofput_: 			       ;put nothing, shift, ctrl or alt
	cmp	edx,0
	jz	endofmainupdate_
putnothing_:				      ;put shift, ctrl, alt or capslock
	lea	esi,extratext
	cmp	edx,1
	jnz	noadd0____
	mov	ecx,6
	add	esi,0
noadd0____:
	cmp	edx,2
	jnz	noadd1____
	mov	ecx,5
	add	esi,6
noadd1____:
	cmp	edx,3
	jnz	noadd2____
	mov	ecx,4
	add	esi,11
noadd2____:
	cmp	edx,4
	jnz	noadd3____
	mov	ecx,6
	add	esi,15
noadd3____:
puttaloopa_:
	movzx	ebx,byte ptr [esi]
	mov	[edi],bl
	inc	ebp
	inc	esi
	inc	edi
	loop	puttaloopa_
endofmainupdate_:				 ;end of this put
	mov	InfoOutPut,ebp
	popad
	mov	eax,InfoOutPut
	ret
GetKeyInfo	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Put PullDown Box
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:    edi=ScreenOffset
;	    eax=Bar Select (-1 = No bar selected)
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
BarSelect		dd	0
PutPullDownBox	Proc	Near
	pushad
	mov	BarSelect,eax
	lea	esi,PullDownTexts
	xor	ebp,ebp
	lea	edx,PullDownKeyTexts

	call	mouseoff
	PlaneWrite 00001111b
	call	puttablack
;------------------------------------------------------------ Put Boxloop Start
	movzx	ecx,TextNumbers
PutBoxLoop:
	push	ecx
	call	puttatextline
	call	PuttaBoxText
	call	PuttaBorW
	inc	ebp
	pop	ecx
	loop	PutBoxLoop
;------------------------------------------------------------ Put Boxloop End
	call	puttablack
	call	mouseon
	mov	themovepeg,3
	mov	oldpegpos,-1
	call	MoveThePegs
	mov	themovepeg,0
	call	mouseon
	popad
	ret
PutPullDownBox	Endp
PuttaTextLine	proc	near ;------------------------------- Put text line
	cmp	ebp,barselect
	jz	puttheblack1
	pushad
	mov	al,01111111b
	stosb
	mov	al,-1
	movzx	ecx,MaxTextLength
	rep	stosb
	mov	al,11111110b
	stosb
	popad
	add	edi,80
	ret
puttheblack1:
	pushad
	mov	al,0
	movzx	ecx,MaxTextLength
	add	ecx,2
	rep	stosb
	popad
	add	edi,80
	ret
PuttaTextLine	endp
PuttaBlack	proc	near ;------------------------------- Put black
	pushad
	mov	al,0
	movzx	ecx,MaxTextLength
	add	ecx,2
	rep	stosb
	popad
	add	edi,80
	ret
PuttaBlack	endp
PuttaBorW	proc	near ;------------------------------- Put BorW
	mov	bx,bp
	inc	bx
	cmp	TextNumbers,bx
	jz	DoTheRet
	cmp	byte ptr [esi-2],1
	jz	puttheblack2
	pushad
	mov	al,01111111b
	stosb
	mov	al,-1
	movzx	ecx,MaxTextLength
	rep	stosb
	mov	al,11111110b
	stosb
	popad
	add	edi,80
DoTheRet:
	ret
puttheblack2:
	pushad
	mov	al,0
	movzx	ecx,MaxTextLength
	add	ecx,2
	rep	stosb
	popad
	add	edi,80
	ret
PuttaBorW	endp
MoreText	db	11000000b
		db	11100000b
		db	11110000b
		db	11111000b
		db	11111100b
		db	11111110b
		db	11111100b
		db	11111000b
		db	11110000b
		db	11100000b
		db	11000000b
		db	00000000b
XorSelect	db	0
OffsetOffset	dd	0
PuttaBoxText	proc	near ;------------------------------- Putta Box Text
	push	edi
	push	ebp
	mov	eax,ebp
	shl	eax,2
	mov	OffsetOffset,eax
	mov	XorSelect,-1		;Prepare XorSelect
	cmp	ebp,barselect
	jnz	NoSelect
	mov	XorSelect,0
NoSelect:
					;put first part
	push	edi
	mov	al,01111111b
	cmp	XorSelect,0
	jnz	PuttaFirstBlack
	mov	al,0
PuttaFirstBlack:
	mov	ecx,12
PutFirstParten:
	mov	[edi],al
	add	edi,80
	loop	PutFirstParten
	pop	edi
	inc	edi

					;Put Text First Text
	push	edi
	movzx	ecx,MaxTextLength
WriteText1Loop:
	movzx	ebx,byte ptr [esi]
	inc	esi
	cmp	bl,0
	jz	EndOfWriteLoop

	mov	ebp,[AllocTable+1040*8]
	lea	ebx,[ebx+ebx*2]
	lea	ebx,[ebx*4]
	add	ebp,ebx

	push	edi
	mov	ebx,12
WriteChar1:
	mov	al,[ebp]
	xor	al,XorSelect
	mov	[edi],al
	inc	ebp
	add	edi,80
	dec	ebx
	jnz	WriteChar1
	pop	edi
	inc	edi
	dec	ecx
	jmp	WriteText1Loop
EndOfWriteLoop:
	add	esi,3
	pop	edi
					;Put Last Part
	movzx	ebx,MaxTextLength
	add	edi,ebx
	push	edi
	push	ecx
	mov	al,11111110b
	cmp	XorSelect,0
	jnz	PuttaLastBlack
	mov	al,0
PuttaLastBlack:
	mov	ecx,12
PutLastParten:
	mov	[edi],al
	add	edi,80
	loop	PutLastParten
	pop	ecx
	pop	edi

	mov	eax,OffsetOffset	;Put More Symbol
	cmp	[eax+PullDownOffsets],0
	jnz	NoMoreSymbol
	dec	edi
	pushad
	mov	ecx,12
	lea	esi,MoreText
MoveSymbol:
	lodsb
	xor	al,XorSelect
	stosb
	add	edi,80-1
	loop	MoveSymbol
	popad
	dec	cx
NoMoreSymbol:
					;Put KeyText
WriteText2Loop:
	movzx	ebx,byte ptr [edx]
	inc	edx
	cmp	bl,0
	jz	EndOfWriteLoop2
	dec	edi

	mov	ebp,[AllocTable+1040*8]
	lea	ebx,[ebx+ebx*2]
	lea	ebx,[ebx*4]
	add	ebp,ebx

	push	edi
	mov	ebx,12
WriteChar2:
	mov	al,[ebp]
	xor	al,XorSelect
	mov	[edi],al
	inc	ebp
	add	edi,80
	dec	ebx
	jnz	WriteChar2
	pop	edi

	dec	ecx
	jmp	WriteText2Loop
EndOfWriteLoop2:
					;Put Last Space
	cmp	ecx,0
	jle	SkipPuttenWhite
	mov	al,XorSelect
SetRestLoop:
	push	ecx
	dec	edi
	push	edi

	mov	ecx,12
SetCharNow:
	mov	[edi],al
	add	edi,80
	loop	SetCharNow

	pop	edi
	pop	ecx
	loop	SetRestLoop
SkipPuttenWhite:

	pop	ebp
	pop	edi
	add	edi,12*80
	ret
PuttaBoxText	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Main Pull Down
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MainPullDown	Proc	Near
	pushad
	cmp	pullmode,0
	jnz	PullBackMain
	mov	PullMode,2
	mov	PullNumber,0
	mov	eax,[StartPullDown+9*4]
	mov	PullDownPointer,eax
	call	PullStart
	popad
	ret
PullBackMain:
	call	pullenden
	popad
	ret
MainPullDown	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       PullDownKey
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PullDownKey	Proc	Near
	pushad
	cmp	pullmode,0
	jnz	PullBackKey
	movzx	eax,MouseX
	movzx	ebx,MouseY
	cmp	Menu_popup,0
	jz	nopoppis
	mov	edi,5*4
	jmp	AfterChoosePart
nopoppis:
	cmp	ebx,16
	jbe	noPullDownKey
	cmp	ebx,223
	jb	noDown
	mov	edi,6*4
	jmp	AfterChoosePart
noDown:
	cmp	eax,156
	jb	noRight
	mov	edi,8*4
	jmp	AfterChoosePart
noRight:
	cmp	ebx,86
	jb	noLeft
	mov	edi,7*4
	jmp	AfterChoosePart
noLeft:
	jmp	noPullDownKey
AfterChoosePart:			;After choose part

	lea	esi,StartPullDown
	xor	ebp,ebp
SearchPullDown3:
	cmp	dword ptr [esi+edi],-1
	jz	NextPullis3
	cmp	dword ptr [esi+5*4],-1
	jz	SkipCheck1_
	movzx	eax,Menu_PopUp
	cmp	eax,[esi+5*4]
	jnz	NextPullis3
SkipCheck1_:
	cmp	dword ptr [esi+6*4],-1
	jz	SkipCheck2__
	movzx	eax,Menu_DownScreen
	cmp	eax,[esi+6*4]
	jnz	NextPullis3
SkipCheck2__:
	cmp	dword ptr [esi+7*4],-1
	jz	SkipCheck3_
	movzx	eax,Menu_UpperLeft
	cmp	eax,[esi+7*4]
	jnz	NextPullis3
SkipCheck3_:
	cmp	dword ptr [esi+8*4],-1
	jz	SkipCheck4_
	movzx	eax,Menu_UpperScreen
	cmp	eax,[esi+8*4]
	jnz	NextPullis3
SkipCheck4_:
	mov	PullMode,2
	mov	PullNumber,ebp
	mov	eax,[esi+9*4]
	mov	PullDownPointer,eax
	call	PullStart

NextPullis3:
	add	esi,10*4
	inc	ebp
	cmp	dword ptr [esi],-1
	jnz	SearchPullDown3

NoPullDownKey:
	popad
	ret
PullBackKey:
	call	pullenden
	popad
	ret
PullDownKey	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Pull Start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PopUpSave	dw	0,0
PullStart	proc	near
	pushad
	mov	ax,[CurrentMenu]
	mov	[PopUpSave],ax
	mov	ax,Menu_PopUp
	mov	[PopUpSave+2],ax
	mov	[CurrentMenu],23
	mov	Menu_PopUp,23



	call	getbox
	mov	eax,PullNumber
	call	WriteTopBar
					;fix windows max
	mov	esi,PullDownPointer
	add	esi,6*2
	mov	ecx,1
WinSearcha:
	lodsb
	cmp	al,'|'
	jnz	nospc
	inc	ecx
nospc:
	cmp	al,0
	jnz	WinSearcha
	mov	WindowMax,ecx

	mov	dword ptr [PosInfoOld],-1
	mov	word ptr [PosInfoOld+4],-1

	popad
	ret
PullStart	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Pull End
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PullEnden	  proc	  near
	pushad

PullBackKey_:
	call	putbox
	cmp	stacksaven,0
	jnz	PullBackKey_
	mov	PullMode,0

	mov	ax,[PopUpSave]
	mov	[CurrentMenu],ax
	mov	ax,[PopUpSave+2]
	mov	Menu_PopUp,ax
	mov	pullmode,0
	mov	boxestoclip,0
	popad
	ret
PullEnden	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Get Box
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
StackSaven	dd	0	;0=Topbar 1=MainBox 2=MoreBox1
BoxCords	dd	4*3	dup(0)
PicOffsets	dd	3	dup(0)
SaveOffset	dd	0
GetBox		Proc	Near
	pushad
	cmp	StackSaven,3
	jz	EndGetBox
	mov	HidePlayPeg,1
	mov	themovepeg,3
	call	MoveThePegs
	mov	themovepeg,0
	mov	HidePlayPeg,0

	call	mouseoff
	mov	eax,StackSaven
	cmp	eax,0
	jz	BoxType0
	cmp	eax,1
	jz	BoxType1
	cmp	eax,2
	jz	BoxType2

BoxType0:				;Top bar
	mov	ebp,PullDownPointer
	movzx	eax,word ptr [ebp+3*2]
	mov	[boxclip],eax
	mov	[BoxCords],eax
	movzx	ebx,word ptr [ebp+4*2]
	mov	[boxclip+1*4],ebx
	mov	[BoxCords+1*4],ebx
	movzx	ecx,word ptr [ebp+5*2]
	add	eax,ecx
	dec	eax
	mov	[boxclip+2*4],eax
	mov	[BoxCords+2*4],eax
	add	ebx,16
	mov	[boxclip+3*4],ebx
	mov	[BoxCords+3*4],ebx
	mov	boxestoclip,1
	mov	dword ptr [BoxClip+4*4],-1
	jmp	AfterBoxType
BoxType1:				;Main box
	mov	eax,[MainStartCords]
	mov	[BoxClip+(1*16)],eax
	mov	[BoxCords+(1*16)],eax
	mov	ebx,[MainStartCords+4]
	mov	[BoxClip+1*4+(1*16)],ebx
	mov	[BoxCords+1*4+(1*16)],ebx
	movzx	ecx,MainMaxTextLength
	add	ecx,2
	shl	ecx,3
	add	eax,ecx
	mov	[BoxClip+2*4+(1*16)],eax
	mov	[BoxCords+2*4+(1*16)],eax
	movzx	ecx,MainTextNumbers
	mov	eax,14
	mul	ecx

;	inc	eax		;du klipper fel!

	add	eax,ebx
	mov	[BoxClip+3*4+(1*16)],eax
	mov	[BoxCords+3*4+(1*16)],eax
	mov	boxestoclip,2
	mov	dword ptr [BoxClip+4*4+(1*16)],-1
	jmp	AfterBoxType
BoxType2:				;More box


;Ja tyckte inte detta st„mde, s† ja „ndrade... nu funkar de...
;Iaf klippningen... men buggen att more-popupen f”rsvinner har kommit tebaks...


	mov	eax,[MoreStartCords]
	 sub	 eax,2
	mov	[BoxClip+(2*16)],eax
;	sub	[BoxClip+(2*16)],8
	mov	[BoxCords+(2*16)],eax
	mov	ebx,[MoreStartCords+4]
	mov	[BoxClip+1*4+(2*16)],ebx
	mov	[BoxCords+1*4+(2*16)],ebx
	movzx	ecx,MoreMaxTextLength
	add	ecx,2
	shl	ecx,3
	add	eax,ecx
	mov	[BoxClip+2*4+(2*16)],eax
;	sub	[BoxClip+2*4+(2*16)],8
	mov	[BoxCords+2*4+(2*16)],eax
	movzx	ecx,MoreTextNumbers
	mov	eax,14
	mul	ecx
	inc	eax
	add	eax,ebx
	mov	[BoxClip+3*4+(2*16)],eax
	sub	[BoxClip+3*4+(2*16)],1
	mov	[BoxCords+3*4+(2*16)],eax
	mov	boxestoclip,3
	mov	dword ptr [BoxClip+4*4+(2*16)],-1
AfterBoxType:
						;Get Picture
	mov	ebp,StackSaven
	shl	ebp,4

	mov	ebx,[ebp+boxcords+2*4]		;x
	sub	ebx,[ebp+boxcords+0*4]
	inc	ebx
	shr	ebx,3

	mov	eax,[ebp+boxcords+3*4]		;*y
	sub	eax,[ebp+boxcords+1*4]
	inc	eax
	mul	ebx
	mov	edx,StackSaven
	mov	[PullSaveSize+edx*4],eax

	shl	eax,2				;*4
	mov	edx,StackSaven
	shl	edx,2
	mov	ebx,SaveOffset
	mov	[edx+PicOffsets],ebx

	add	SaveOffset,eax

	add	ebx,Gus_TempBuffPtr
	mov	edi,ebx

	move	esi,0a0000h
	mov	eax,[ebp+boxcords+1*4]
	mov	ebx,80
	mul	ebx
	mov	ebx,[ebp+boxcords+0*4]
	shr	ebx,3
	add	eax,ebx
	add	esi,eax

	mov	ecx,4
	mov	ah,0
GetLopp1:
	push	ecx
	push	esi
	mov	dx,3ceh 		;Set bitplane (read)
	mov	al,4
	out	dx,ax

	mov	ecx,[ebp+boxcords+3*4]
	sub	ecx,[ebp+boxcords+1*4]
	inc	ecx
GetPicloop:
	push	ecx

	push	esi
	mov	ecx,[ebp+boxcords+2*4]
	sub	ecx,[ebp+boxcords+0*4]
	inc	ecx
	shr	ecx,3
	rep	movsb
	pop	esi
	add	esi,80

	pop	ecx
	loop	GetPicLoop

	inc	ah
	pop	esi
	pop	ecx
	loop	GetLopp1

	call	mouseon
	inc	StackSaven
	xor	ebp,ebp
NextBoxConvert:
	mov	eax,[BoxClip+ebp*8]	;x
	cmp	eax,-1
	jz	EndBoxConvert
	shr	eax,3
	adc	eax,0
	mov	[BoxClipByte+ebp*8],eax
	mov	eax,[BoxClip+ebp*8+4]	;y
	mov	[BoxClipByte+ebp*8+4],eax
	inc	ebp
	jmp	NextBoxConvert
EndBoxConvert:
	mov	[BoxClipByte+ebp*8],eax


EndGetBox:
	popad
	ret
GetBox		Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Put Box
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PutBox		Proc	Near
	pushad
	cmp	StackSaven,0
	jz	EndPutBox
	dec	StackSaven
	call	mouseoff

	mov	eax,StackSaven		 ;esi
	shl	eax,2
	mov	esi,[picoffsets+eax]
	mov	SaveOffset,esi
	add	esi,Gus_TempBuffPtr

	mov	ebp,StackSaven		 ;edi
	shl	ebp,4
	move	edi,0a0000h
	mov	eax,[ebp+boxcords+1*4]
	mov	ebx,80
	mul	ebx
	mov	ebx,[ebp+boxcords+0*4]
	shr	ebx,3
	add	eax,ebx
	add	edi,eax

	mov	ecx,4
	mov	ah,00000001b		;Set bitplane (write)
SetLopp1:
	push	ecx
	push	edi
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax

	mov	ecx,[ebp+boxcords+3*4]
	sub	ecx,[ebp+boxcords+1*4]
	inc	ecx
SetPicloop:
	push	ecx

	push	edi
	mov	ecx,[ebp+boxcords+2*4]
	sub	ecx,[ebp+boxcords+0*4]
	inc	ecx
	shr	ecx,3
	rep	movsb
	pop	edi
	add	edi,80

	pop	ecx
	loop	SetPicLoop


	pushad
	mov	eax,stacksaven
	mov	boxestoclip,eax
	shl	eax,4
	mov	dword ptr [boxclip+eax],-1
	mov	oldrow,-1
	popad

	shl	ah,1
	pop	edi
	pop	ecx
	loop	SetLopp1
	call	mouseon

	mov	themovepeg,3
	mov	oldpegpos,-1
	call	MoveThePegs
	mov	themovepeg,0

EndPutBox:
	popad
	ret
PutBox		Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Search Text
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; In:		eax=Window
;		ebx=More Box  (bar select number in window
; Out:		esi=new offset
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

SearchWin	dd	0
SearchMore	dd	0
SearchText	Proc	Near
	pushad
	mov	SearchWin,eax
	mov	SearchMore,ebx
	mov	esi,pulldownpointer
	add	esi,6*2
LOOPEN1:
	lodsb
	cmp	al,0
	jnz	LOOPEN1
				;Search window ---------
	mov	ecx,SearchWin
	jecxz	afterwinsearch
SearchWindow:
LOOPEN2:
	lodsb
	cmp	al,0
	jnz	LOOPEN2
	add	esi,3
	lodsd
	cmp	eax,0
	jnz	noMOREpopup__
LOOPEN3:
	lodsb
	cmp	al,-1
	jnz	LOOPEN3
	cmp	dword ptr [esi],-1
	jnz	LOOPEN3
	add	esi,4
noMOREpopup__:
	cmp	byte ptr [esi],-1
	jnz	SearchWindow
	cmp	dword ptr [esi+1],-1
	jnz	SearchWindow
	loop	SearchWindow
	add	esi,5
afterwinsearch: 			;search more ----------

	mov	searchwin,esi
	popad
	mov	esi,searchwin
	ret
SearchText	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Show Boxes
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
comment &
PullMode	db	0	;0=No pulldown 1=Mouse 2=Key
PullNumber	dd	0	;Pull down number
PullDownPointer dd	0	;Offset to current pulldown

StackSaven	dd	0	;0=Topbar 1=MainBox 2=MoreBox1
BoxCords	dd	4*3	dup(0)
PicOffsets	dd	3	dup(0)
SaveOffset	dd	0

MainPullDownOffsets	dd	30	dup(0)
MainTextNumbers 	dw	0
MainMaxTextLength	dw	0
MainStartCords		dd	0,0	;x1,y1
MorePullDownOffsets	dd	30	dup(0)
MoreTextNumbers 	dw	0
MoreMaxTextLength	dw	0
MoreStartCords		dd	0,0	;x1,y1
PullDownSampEd	dw	0,0,0		   ;Windowpos,Barpos,MoreBarpos
		dw	0,223,640	   ;Xpos,Ypos,Length
		db	" MISC | ABOUT ",0 ;TopText
&

PosInfoOld	dw	-1,-1,-1
AdderTop	dd	0
ShowBoxes	Proc	Near
	pushad
;************************************************** Xor top bar if new window
	mov	esi,PullDownPointer
	mov	ax,[esi]
	cmp	ax,[PosInfoOld]
	jz	Wow
	cmp	stacksaven,1
	jbe	Wow
	movzx	ecx,word ptr [PosInfoOld]
	call	xortop
	movzx	ecx,word ptr [esi]
	call	xortop
Wow:
;************************************************** Remove Main and more if new
						    ;Window
	mov	esi,PullDownPointer
	mov	ax,[esi]
	cmp	ax,[PosInfoOld]
	jz	SkipRemoveBoxes
	mov	word ptr [esi+4],-1
LoopMoveRe:
	cmp	stacksaven,1
	jz	AfterLoopRe
	call	PutBox
	jmp	LoopMoveRe
AfterLoopRe:
SkipRemoveBoxes:
;************************************************** Change Main offset
	mov	esi,PullDownPointer
	mov	ax,[esi+2]
	cmp	ax,[PosInfoOld+2]
	jz	noChangeOffa
	cmp	stacksaven,1
	jbe	noChangeOffa
	mov	word ptr [esi+4],-1
	movsx	eax,word ptr [PosInfoOld+2]
	call	XorBoxMain
	movsx	eax,word ptr [esi+2]
	call	XorBoxMain
noChangeOffa:
;************************************************** Put Main Box and more if new
	cmp	stacksaven,1
	jnz	afterPutMainBox
	mov	esi,PullDownPointer
	movzx	ecx,word ptr [esi]
	movzx	eax,word ptr [esi+4*2]
	add	eax,17
	mov	[mainstartcords+4],eax
	add	esi,6*2
	xor	edx,edx
	jecxz	RightOffset
SearchOff:
	lodsb
	inc	edx
	cmp	al,0
	jz	ora1
	cmp	al,'|'
	jnz	SearchOff
ora1:
	dec	edx
	loop	SearchOff
RightOffset:
	mov	addertop,0
Addertoploop:
	lodsb
	inc	addertop
	cmp	al,0
	jz	ora2
	cmp	al,'|'
	jnz	addertoploop
ora2:
	mov	ecx,edx
	shl	edx,3
	mov	ebx,PullDownPointer
	movzx	eax,word ptr [ebx+3*2]
	push	eax
	add	edx,eax
	mov	[mainstartcords],edx

	mov	eax,[mainstartcords+4]
	mov	ebx,80
	mul	ebx
	add	eax,ecx
	pop	ecx
	shr	ecx,3
	add	eax,ecx
	move	edi,0a0000h
	add	edi,eax

	mov	ebx,pulldownpointer
	movzx	eax,word ptr [ebx]
	call	searchtext
	mov	eax,1
	call	scanboxdata

	movzx	ebx,mainmaxtextlength
	add	ebx,2
	shl	ebx,3
	add	ebx,dword ptr [mainstartcords]
	cmp	ebx,640
	jb	nothingtodo
	push	eax
	push	ecx
	mov	ebx,[mainstartcords]
	movzx	ecx,mainmaxtextlength
	add	ecx,2
	mov	eax,addertop
	dec	eax
	sub	edi,ecx
	add	edi,eax
	shl	eax,3
	shl	ecx,3
	add	ebx,eax
	sub	ebx,ecx
	mov	[mainstartcords],ebx
	pop	ecx
	pop	eax
nothingtodo:

	call	getbox
	mov	ebx,PullDownPointer
	movzx	eax,word ptr [ebx+2]
	call	putpulldownbox
AfterPutMainBox:
;************************************************** Remove More if new
						    ;Window
	mov	esi,PullDownPointer
	mov	ax,[esi+2]
	cmp	ax,[PosInfoOld+2]
	jz	SkipRemoveBoxes2
LoopMoveRe2:
	cmp	stacksaven,2
	jbe	AfterLoopRe2
	call	PutBox
	jmp	LoopMoveRe2
AfterLoopRe2:
SkipRemoveBoxes2:
;************************************************** Change More offset
	mov	esi,PullDownPointer
	mov	ax,[esi+4]
	cmp	ax,[PosInfoOld+4]
	jz	noChangeOffa2
	cmp	stacksaven,2
	jbe	noChangeOffa2
	movsx	eax,word ptr [PosInfoOld+4]
	cmp	ax,-1
	jz	Orka1
	call	XorBoxMore
ORka1:
	movsx	eax,word ptr [esi+4]
	cmp	ax,-1
	jz	Orka2
	call	XorBoxMore
Orka2:
noChangeOffa2:
;************************************************** Put More Box and more if new
	cmp	stacksaven,2
	jnz	afterPutMoreBox
	mov	esi,pulldownpointer
	movzx	eax,word ptr [esi+2]
	cmp	ax,-1
	jz	afterputmorebox
	shl	eax,2
	cmp	dword ptr [MainPullDownOffsets+eax],0
	jnz	afterputmoreBox

	shr	eax,2
	mov	ebx,14
	mul	ebx
	mov	ebx,[mainstartcords+4]
	add	eax,ebx
	mov	[morestartcords+4],eax

	mov	eax,[mainstartcords]
	movzx	ebx,MainMaxTextLength
	add	ebx,2
	shl	ebx,3
	add	eax,ebx
	add	eax,2
	mov	[MoreStartCords],eax

	move	edi,0a0000h
	mov	eax,[MoreStartCords+4]
	mov	ebx,80
	mul	ebx
	mov	ebx,[MoreStartCords]
	shr	ebx,3
	add	eax,ebx
	add	edi,eax

	mov	ebx,pulldownpointer
	movzx	eax,word ptr [ebx]
	call	searchtext
	mov	ebx,pulldownpointer
	movzx	ecx,word ptr [ebx+2]
	inc	ecx
OOOp1:
	lodsb
	cmp	al,0
	jnz	OOOp1
	add	esi,3+4
	cmp	ecx,1
	jz	skipchecknull
	cmp	dword ptr [esi-4],0
	jnz	skipchecknull
OOOp2:
	lodsb
	cmp	al,-1
	jnz	OOOp2
	cmp	dword ptr [esi],-1
	jnz	OOOp2
	add	esi,4
skipchecknull:
	loop	OOOp1

	mov	eax,2
	call	scanboxdata

	movzx	ebx,moremaxtextlength
	add	ebx,2
	shl	ebx,3
	add	ebx,dword ptr [morestartcords]
	cmp	ebx,640
	jb	nothingtodo2
	push	eax
	push	ecx
	mov	ebx,[morestartcords]
	movzx	ecx,moremaxtextlength
	add	ecx,2
	movzx	eax,mainmaxtextlength
	add	eax,2
	sub	edi,ecx
	sub	edi,eax
	shl	eax,3
	shl	ecx,3
	sub	ebx,eax
	sub	ebx,ecx
	mov	[morestartcords],ebx
	pop	ecx
	pop	eax
nothingtodo2:

	call	getbox
	mov	ebx,PullDownPointer
	movzx	eax,word ptr [ebx+4]
	call	putpulldownbox
AfterPutMoreBox:


endaas:
	mov	esi,PullDownPointer		;get old
	lea	edi,PosInfoOld
	movsd
	movsw
	popad
	ret
ShowBoxes	Endp
RNUM		dd	0
      ;  jmp	 endaas ;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
XorBoxMain	Proc	Near			;Xor Box Main -----------------
	cmp	ax,-1
	jz	_ret
	pushad
	mov	RNUM,eax
	call	mouseoff
	planewrite 00001111b
	planeread  0
	mov	eax,[MainStartCords+4]
	inc	eax
	mov	ebx,80
	mul	ebx
	mov	ebx,[MainStartCords]
	shr	ebx,3
	add	eax,ebx
	move	edi,0a0000h
	add	edi,eax
	mov	eax,RNUM
	mov	ebx,14*80
	mul	ebx
	add	edi,eax

	mov	ecx,13
	push	edi
LOSS1:
	mov	al,[edi]
	xor	al,01111111b
	mov	[edi],al
	add	edi,80
	loop	LOSS1
	pop	edi
	inc	edi

	movzx	ecx,MainMaxTextLength
LOJA:
	push	ecx
	mov	ecx,13
	push	edi
LOSS2:
	mov	al,[edi]
	xor	al,11111111b
	mov	[edi],al
	add	edi,80
	loop	LOSS2
	pop	edi
	inc	edi
	pop	ecx
	loop	LOJA

	mov	ecx,13
	push	edi
LOSS3:
	mov	al,[edi]
	xor	al,11111110b
	mov	[edi],al
	add	edi,80
	loop	LOSS3
	pop	edi
	call	mouseon
	popad
	ret
XorBoxMain	Endp
XorBoxMore	Proc	Near			;Xor Box More -----------------
	cmp	ax,-1
	jz	_ret
	pushad
	mov	RNUM,eax
	call	mouseoff
	planewrite 00001111b
	planeread  0
	mov	eax,[MoreStartCords+4]
	inc	eax
	mov	ebx,80
	mul	ebx
	mov	ebx,[MoreStartCords]
	shr	ebx,3
	add	eax,ebx
	move	edi,0a0000h
	add	edi,eax
	mov	eax,RNUM
	mov	ebx,14*80
	mul	ebx
	add	edi,eax

	mov	ecx,13
	push	edi
LOSS1_:
	mov	al,[edi]
	xor	al,01111111b
	mov	[edi],al
	add	edi,80
	loop	LOSS1_
	pop	edi
	inc	edi

	movzx	ecx,MoreMaxTextLength
LOJA_:
	push	ecx
	mov	ecx,13
	push	edi
LOSS2_:
	mov	al,[edi]
	xor	al,11111111b
	mov	[edi],al
	add	edi,80
	loop	LOSS2_
	pop	edi
	inc	edi
	pop	ecx
	loop	LOJA_

	mov	ecx,13
	push	edi
LOSS3_:
	mov	al,[edi]
	xor	al,11111110b
	mov	[edi],al
	add	edi,80
	loop	LOSS3_
	pop	edi
	call	mouseon
	popad
	ret
XorBoxMore	Endp
;In:	ecx=Number
XorTop		Proc	Near			;Xor Top ---------------------
	pushad
	push	ecx
	call	mouseoff
	planewrite 00001111b
	planeread  0
	pop	ecx
	mov	esi,PullDownPointer
	movzx	eax,word ptr [esi+4*2]
	inc	eax
	mov	ebx,80
	mul	ebx
	movzx	ebx,word ptr [esi+3*2]
	shr	ebx,3
	add	eax,ebx
	move	edi,0a0000h
	add	edi,eax
	add	esi,6*2
	jecxz	etete
SearchNumber:
	lodsb
	inc	edi
	cmp	al,'|'
	jnz	SearchNumber
	dec	edi
	loop	SearchNumber

	mov	al,-1
	jmp	nononull
etete:
	mov	al,01111111b
nononull:

	mov	ecx,15
	push	edi
LOOPENS1:
	mov	bl,byte ptr [edi]
	xor	bl,al
	mov	byte ptr [edi],bl
	add	edi,80
	loop	LOOPENS1
	pop	edi

	inc	edi
	lodsb
	mov	bl,-1
rightnumber:
	lodsb
	cmp	al,'|'
	jz	quittar
	cmp	al,0
	jz	quittar
	mov	ecx,15
	push	edi
LOOPENS2:
	mov	al,byte ptr [edi]
	xor	al,bl
	mov	byte ptr [edi],al
	add	edi,80
	loop	LOOPENS2
	pop	edi
	inc	edi
	jmp	rightnumber
quittar:
	call	mouseon
	popad
	ret
XorTop		Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Pull Down Handler
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PullMode	db	0	;0=No pulldown 1=Mouse 2=Key
PullNumber	dd	0	;Pull down number
PullDownPointer dd	0	;Offset to current pulldown
InSidePopUp	db	0	;0=mainpopup 1=morepopup


MainPullDownOffsets	dd	30	dup(0)
MainTextNumbers 	dw	0
MainMaxTextLength	dw	0
MainStartCords		dd	0,0	;x1,y1
MorePullDownOffsets	dd	30	dup(0)
MoreTextNumbers 	dw	0
MoreMaxTextLength	dw	0
MoreStartCords		dd	0,0	;x1,y1

WindowMax		dd	0

MainPullDownRightStatus db	0

PullDownHandler Proc	Near
	pushad

	cmp	stacksaven,3
	jz	nojas
	mov	InSidePopUp,0
nojas:

					;button release
	cmp	PullMode,1
	jnz	nobuttr
	cmp	MouseB,0
	jnz	nobuttr
	call	buttonrelease
nobuttr:

					;mouse mode on
	cmp	pullmode,2
	jnz	skippafittan

	cmp	MainPullDownRightStatus,0
	jz	skipthischeck

	cmp	mouseB,2
	jz	JustDoIt
skipthischeck:
	cmp	mouseB,1
	jnz	skippafittan
JustDoIt:

	mov	pullmode,1
skippafittan:


nokeynow2:


;	movzx	eax,insidepopup
;	mov	eax,stacksaven
	cmp	PullMode,1
	jz	PullMode1
	cmp	PullMode,2
	jz	PullMode2
;------------------------------------------------------ Check new pulldown
					;Mouse check ---------------------------
	cmp	MainPullDownRightStatus,0
	jz	skipthischeck2
	cmp	mouseB,2
	jz	JustDoIt2
skipthischeck2:
	cmp	MouseB,1
	jnz	PullHandlerExit
JustDoIt2:
	lea	esi,StartPullDown
	xor	ebp,ebp
SearchPullDown1:
	movzx	eax,MouseX
	movzx	ebx,MouseY
	cmp	eax,[esi+0*4]
	jb	NextPullis
	cmp	eax,[esi+2*4]
	ja	NextPullis
	cmp	ebx,[esi+1*4]
	jb	NextPullis
	cmp	ebx,[esi+3*4]
	ja	NextPullis
	cmp	dword ptr [esi+5*4],-1
	jz	SkipCheck1
	movzx	eax,Menu_PopUp
	cmp	eax,[esi+5*4]
	jnz	NextPullis
SkipCheck1:
	cmp	dword ptr [esi+6*4],-1
	jz	SkipCheck2_
	movzx	eax,Menu_DownScreen
	cmp	eax,[esi+6*4]
	jnz	NextPullis
SkipCheck2_:
	cmp	dword ptr [esi+7*4],-1
	jz	SkipCheck3
	movzx	eax,Menu_UpperLeft
	cmp	eax,[esi+7*4]
	jnz	NextPullis
SkipCheck3:
	cmp	dword ptr [esi+8*4],-1
	jz	SkipCheck4
	movzx	eax,Menu_UpperScreen
	cmp	eax,[esi+8*4]
	jnz	NextPullis
SkipCheck4:
	mov	PullMode,1		;Set PullMouse
	mov	PullNumber,ebp
	mov	eax,[esi+9*4]
					;special top pull down;'
	cmp	ebp,0
	jnz	NoSpecialTop
	pushad
	movzx	ecx,MouseX
	shr	ecx,3
	mov	ebx,eax
	add	ebx,2*6
	xor	edx,edx
	jecxz	afterloopas
loopasnow:
	cmp	byte ptr [ebx],'|'
	jnz	noincas
	inc	edx
	inc	ebx
	jmp	loopasnow
noincas:
	inc	ebx
	loop	loopasnow
afterloopas:
	mov	word ptr [eax],dx
	mov	dword ptr [eax+2],0
	popad
	jmp	AfterSpecialTop
NoSpecialTop:
	mov	dword ptr [eax],0
	mov	word ptr [eax+4],0
AfterSpecialTop:
	mov	PullDownPointer,eax
	call	PullStart
	popad
	ret

NextPullis:
	add	esi,10*4
	inc	ebp
	cmp	dword ptr [esi],-1
	jnz	SearchPullDown1
	popad
	ret
;------------------------------------------------------ PullMode 1 (Mouse)
PullMode1:
	call	showboxes

	mov	esi,pulldownpointer		;change window
	mov	bx,word ptr [esi+4*2]
	cmp	mouseY,bx
	jb	changemousewindow
	add	bx,16
	cmp	mouseY,bx
	ja	changemousewindow
	mov	bx,word ptr [esi+3*2]
	cmp	mouseX,bx
	jl	changemousewindow
	add	bx,word ptr [esi+5*2]
	cmp	mouseX,bx
	jae	changemousewindow
	movzx	eax,mouseX
	movzx	ebx,word ptr [esi+3*2]
	sub	eax,ebx
	shr	eax,3
	mov	ecx,eax
	xor	ebx,ebx
	add	esi,2*6
MouseSearch:
	lodsb
	cmp	al,0
	jz	changemousewindow
	cmp	al,'|'
	jnz	nomm
	inc	ebx
	jmp	mouseSearch
nomm:
	loop	mousesearch
	mov	esi,pulldownpointer
	mov	word ptr [esi],bx
	mov	word ptr [esi+1*2],0
	mov	word ptr [esi+2*2],-1
	jmp	nomainoffa
changemousewindow:
						;change more offset
	cmp	boxestoclip,3
	jb	nomainoffa_
	movzx	eax,mouseX
	movzx	ebx,mouseY
	mov	ecx,[BoxClip+0*4+(2*16)]
	;add	 ecx,7
	cmp	eax,ecx
	jb	setmainnull_
	mov	ecx,[BoxClip+2*4+(2*16)]
	;add	 ecx,7
	cmp	eax,ecx
	ja	setmainnull_
	cmp	ebx,[BoxClip+1*4+(2*16)]
	jb	setmainnull_
	cmp	ebx,[BoxClip+3*4+(2*16)]
	ja	setmainnull_
	sub	ebx,[BoxClip+1*4+(2*16)]
	mov	eax,ebx
	mov	ebx,14
	xor	edx,edx
	div	ebx
	mov	esi,pulldownpointer
	movzx	ebx,moretextnumbers
	dec	ebx
	cmp	eax,ebx
	jbe	nosettsave_
	mov	eax,ebx
nosettsave_:
	mov	word ptr [esi+2*2],ax
	jmp	nomainoffa
setmainnull_:
	mov	esi,pulldownpointer
	mov	word ptr [esi+2*2],-1
nomainoffa_:
						;change main offset
	cmp	boxestoclip,2
	jb	nomainoffa
	movzx	eax,mouseX
	movzx	ebx,mouseY
	cmp	eax,[BoxClip+0*4+(1*16)]
	jb	setmainnull
	cmp	eax,[BoxClip+2*4+(1*16)]
	ja	setmainnull
	cmp	ebx,[BoxClip+1*4+(1*16)]
	jb	setmainnull
	cmp	ebx,[BoxClip+3*4+(1*16)]
	ja	setmainnull
	sub	ebx,[BoxClip+1*4+(1*16)]
	mov	eax,ebx
	mov	ebx,14
	xor	edx,edx
	div	ebx
	mov	esi,pulldownpointer
	movzx	ebx,maintextnumbers
	dec	ebx
	cmp	eax,ebx
	jbe	nosettsave
	mov	eax,ebx
nosettsave:
	mov	word ptr [esi+1*2],ax
	jmp	nomainoffa
setmainnull:
	mov	esi,pulldownpointer
	mov	word ptr [esi+1*2],-1
nomainoffa:

	jmp	PullHandlerExit
;------------------------------------------------------ PullMode 2 (Key)
PullMode2:
	call	showboxes

PullHandlerExit:
	popad
	ret
PullDownHandler Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Key Move
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
WindowLeft:				;Left ------------------
	pushad
	cmp	pullmode,2
	jnz	EndPop
	cmp	insidepopup,1
	jz	EscMore
	mov	ebx,PullDownPointer
	mov	word ptr [ebx+2],0
	mov	eax,WindowMax
	dec	eax
	cmp	word ptr [ebx],0
	jnz	NormalDec
	mov	word ptr [ebx],ax
	jmp	EndPop
NormalDec:
	dec	word ptr [ebx]
	jmp	EndPop
WindowRight:				;Right ---------------------
	pushad
	cmp	stacksaven,3
	jnz	notrea
	cmp	insidepopup,0
	jz	JumpToPullMore
notrea:
	mov	insidepopup,0
	cmp	pullmode,2
	jnz	EndPop
	mov	ebx,PullDownPointer
	mov	word ptr [ebx+2],0
	mov	eax,WindowMax
	dec	eax
	cmp	word ptr [ebx],ax
	jnz	NormalInc
	mov	word ptr [ebx],0
	jmp	EndPop
NormalInc:
	inc	word ptr [ebx]
	jmp	EndPop
WindowUp:				;Up ------------------------
	pushad
	cmp	pullmode,2
	jnz	EndPop
	cmp	InsidePopup,1
	jz	MoreMove
	mov	esi,pulldownpointer
	mov	ax,maintextnumbers
	dec	ax
	cmp	word ptr [esi+2],0
	jnz	nospecialdec
	mov	word ptr [esi+2],ax
	jmp	EndPop
nospecialdec:
	dec	word ptr [esi+2]
	jmp	EndPop
MoreMove:			   ;more
	mov	esi,pulldownpointer
	mov	ax,moretextnumbers
	dec	ax
	cmp	word ptr [esi+4],0
	jnz	nospecialdec2
	mov	word ptr [esi+4],ax
	jmp	EndPop
nospecialdec2:
	dec	word ptr [esi+4]
	jmp	EndPop
WindowDown:
	pushad				;Down ----------------------
	cmp	pullmode,2
	jnz	EndPop
	cmp	InsidePopup,1
	jz	MoreMove2
	mov	esi,pulldownpointer
	mov	ax,maintextnumbers
	dec	ax
	cmp	word ptr [esi+2],ax
	jnz	nospecialdec_
	mov	word ptr [esi+2],0
	jmp	EndPop
nospecialdec_:
	inc	word ptr [esi+2]
	jmp	EndPop
MoreMove2:			   ;more
	mov	esi,pulldownpointer
	mov	ax,moretextnumbers
	dec	ax
	cmp	word ptr [esi+4],ax
	jnz	nospecialdec2_
	mov	word ptr [esi+4],0
	jmp	EndPop
nospecialdec2_:
	inc	word ptr [esi+4]
	jmp	EndPop
PullTheEnter:			       ;pull enter --------------
	pushad
	cmp	insidepopup,1
	jz	startinsidepop
	mov	esi,pulldownpointer
	movzx	ebx,word ptr [esi+2]
	shl	ebx,2
	mov	eax,[mainpulldownoffsets+ebx]
	cmp	eax,0
	jz	JumpToPullMore
	call	pullenden
	call	eax
	jmp	EndPop
JumpToPullMore:
	mov	insidepopup,1
	mov	esi,pulldownpointer
	mov	word ptr [esi+4],0
	jmp	EndPop
StartInsidePop:
	mov	esi,pulldownpointer
	movzx	ebx,word ptr [esi+4]
	shl	ebx,2
	mov	eax,[morepulldownoffsets+ebx]
	call	pullenden
	call	eax
	jmp	EndPop
PullEsc:				;Pull Esc --------------------
	pushad
	cmp	insidepopup,1
	jz	EscMore
	call	pullenden
EscMore:
	mov	esi,pulldownpointer
	mov	word ptr [esi+4],-1
	mov	insidepopup,0
	jmp	EndPop

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Button release
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ButtonRelease	Proc	Near
	pushad
	mov	esi,pulldownpointer		;change window
	mov	bx,word ptr [esi+4*2]
	cmp	mouseY,bx
	jb	changemousewindow_
	add	bx,16
	cmp	mouseY,bx
	ja	changemousewindow_
	mov	bx,word ptr [esi+3*2]
	cmp	mouseX,bx
	jl	changemousewindow_
	add	bx,word ptr [esi+5*2]
	cmp	mouseX,bx
	jae	changemousewindow_
	mov	word ptr [esi+1*2],0	;change
	mov	word ptr [esi+2*2],-1
	mov	pullmode,2
	jmp	EndPop
changemousewindow_:
	cmp	stacksaven,3
	jnz	nomorerun
	cmp	word ptr [esi+2*2],-1		;call more
	jz	nomorerun
	movzx	ebx,word ptr [esi+2*2]
	shl	ebx,2
	mov	eax,[morepulldownoffsets+ebx]
	call	pullenden
	call	eax
	jmp	EndPop
nomorerun:					;call main
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	cmp	word ptr [esi+1*2],-1
	jz	justquitpull
	movzx	ebx,word ptr [esi+1*2]
	shl	ebx,2
	mov	eax,[mainpulldownoffsets+ebx]
	call	pullenden
	cmp	eax,0
	jz	EndPop
	call	eax
	jmp	EndPop
justquitpull:					;quit pull
	mov	MainPullDownRightStatus,0
	mov	eax,pullnumber
	mov	ebx,10*4
	mul	ebx
	movzx	ecx,mouseX
	movzx	edx,mouseY
	cmp	ecx,[startpulldown+eax]
	jb	doitnow
	cmp	ecx,[startpulldown+eax+2*4]
	ja	doitnow
	cmp	edx,[startpulldown+eax+1*4]
	jb	doitnow
	cmp	edx,[startpulldown+eax+3*4]
	ja	doitnow
	mov	word ptr [esi+1*2],0	;change
	mov	word ptr [esi+2*2],-1
	mov	pullmode,2
	jmp	EndPop
doitnow:
	call	pullenden
	jmp	EndPop
ButtonRelease	Endp



Biure:
	mov	menu_upperscreen,0
	call	menuhandler
	ret

Naaa:
	mov	menu_upperleft,0
	call	menuhandler
	mov	OldPos2,-1
	mov	OldPattName,-1
	call	PrintPattInfo
	ret

Nooo:
	mov	menu_upperleft,2
	call	menuhandler
	mov	OldPos2,-1
	mov	OldPattName,-1
	call	PrintPattInfo
	ret

Gooo:
	mov	menu_upperleft,3
	call	menuhandler
	call	UpdateSongCfgScreen
	ret

setprotracker:
	pushad
;	lea	eax,equupordown
	mov	menu_downscreen,1
	movzx	ebx,Zoom
	shl	ebx,1
	add	menu_downscreen,bx
;	mov	optionchangeoffset,eax
;	mov	equupordown,1
	mov	trackerstyle2,0
	mov	trackerstyle,0
	jmp	updatepatterns
setscreamtracker:
	pushad
;	lea	eax,equupordown
	mov	menu_downscreen,0
	movzx	ebx,Zoom
	shl	ebx,1
	add	menu_downscreen,bx
;	mov	optionchangeoffset,eax
;	mov	equupordown,2
	mov	trackerstyle2,1
	mov	trackerstyle,1
	jmp	updatepatterns




About1		db	"                     About Velvet Studio                    "
		db	"                                                            "
		db	" Velvet Studio v2.01, Copyr. ",1," 1994-1997 Velvet Development."
		db	" ---------------------------------------------------------- "
		db	"                                                            "
		db	"                       Programming by                       "
		db	"               Patrik Oscarsson & David Broman              "
		db	"                                                            "
		db	"                   Additional programming                   "
		db	"                        Pontus Munck                        "
		db	"                                                            "

About2		db	"                  About Velvet Development                  "
		db	"                                                            "
		db	" Velvet Development is an old team with a new, fresh name.  "
		db	" We were formerly known as Extreme. When this program was   "
		db	" almost finished, we wanted to start a company, so that we  "
		db	" could sell it legaly. Unfortunately Extreme was already    "
		db	" taken, so we had to change names to Velvet Development.    "
		db	"                                                            "
		db	"                                                            "
		db	"                                                            "
		db	"                                                            "

About3		db	"                          Contact                           "
		db	"                                                            "
		db	"If you want to give comments, please contact us!            "
		db	"                                                            "
		db	"                                                            "
		db	"Mail:                                                       "
		db	"Velvet Development                                          "
		db	"Att. D.Broman                                               "
		db	"Hagafors                         e-mail:                    "
		db	"560 13 Hook                      i96davbr@island.liu.se     "
		db	"Sweden                                                      "
		db	"                                                            "

AboutTracker:
	pushad
	lea	esi,About1
	mov	menu_popup,5
	call	menuhandler
	popad
	ret
AboutExtreme:
	pushad
	lea	esi,About2
	mov	menu_popup,5
	call	menuhandler
	popad
	ret
ContactExtreme:
	pushad
	lea	esi,About3
	mov	menu_popup,5
	call	menuhandler
	popad
	ret

clearpatternnamestext	db	'Would you like to clear the pattern names?$'
clearthepatternnames:
	pushad
	lea	esi,clearpatternnamestext
	mov	menu_popup,2
	call	popuphandler
	cmp	popupstatus,0
	jz	_retp

	mov	ecx,1024
	xor	ebp,ebp
	xor	ax,ax
ClearPattNames:
	push	ecx
	mov	edi,[AllocTable+ebp*8]
	cmp	edi,0
	jz	NoPattAll
	mov	ecx,5
	rep	stosw			;Clear PatternNames
NoPattAll:
	pop	ecx
	inc	ebp
	loop	ClearPattNames

	mov	oldpattname,-1

	popad
	ret
cleartracknamestext   db      'Would you like to clear the channel names?$'
clearthetracknames:
	pushad
	lea	esi,cleartracknamestext
	mov	menu_popup,2
	call	popuphandler
	cmp	popupstatus,0
	jz	_retp
	mov	ecx,11*64
	mov	edi,ChannelNamesPtr	 ;Clear ChannelNames
	xor	al,al
	rep	stosb
	call	updatechannelinfo
	popad
	ret

clearthesong2:
	pushad
	call	clearthesong
	popad
	ret


clearsamples2:
	pushad
	call	clearsamples
	popad
	ret

clearallshit2:
	pushad
	call	clearallshit
	popad
	ret

ClearInstText	 db	 'Would you like to clear inst. and sample names?$'
ClearInstNames:
	pushad
	lea	esi,ClearInstText
	mov	menu_popup,2
	call	popuphandler
	cmp	popupstatus,0
	jz	_retp

	mov	ebp,1028		;clear samp names
	mov	edi,[AllocTable+ebp*8]
	mov	ecx,[AllocTable+ebp*8+4]
	xor	al,al
	rep	stosb

	mov	ebp,1029		;Clear inst. names
	mov	edi,[AllocTable+ebp*8]
	mov	ecx,[AllocTable+ebp*8+4]
	xor	al,al
	rep	stosb
	mov	OldCurrentInstName,-1
	popad
	ret

UpdateBlockBock:			;------------- Update block bock -----
	pushad
	mov	[BL1a],' '
	mov	[BL1b],' '
;	 mov	 [BL1c],' '
;	 mov	 [BL1d],' '
	mov	[BL1e],' '
	mov	[BL1f],' '
	mov	[BL2a],' '
	mov	[BL2b],' '
	mov	[BL2c],' '
	mov	[BL2d],' '
	mov	[BL2e],' '
	mov	[BL2f],' '
	mov	[BL3a],' '
	mov	[BL3b],' '
	mov	[BL3c],' '
	mov	[BL3d],' '
	mov	[PDDO1],' '
	mov	[PDDO2],' '

	cmp	Menu_upperscreen,0	;upper
	jnz	BlackBock1
	mov	[BL1a],2
BlackBock1:
	cmp	Menu_upperscreen,3
	jnz	BlackBock2
	mov	[BL1b],2
BlackBock2:
;	 cmp	 Menu_upperscreen,4
;	 jnz	 BlackBock3
;	 mov	 [BL1c],2
;BlackBock3:
;	 cmp	 Menu_upperscreen,5
;	 jnz	 BlackBock4
;	 mov	 [BL1d],2
;BlackBock4:
	cmp	PianoScreen,1
	jnz	BlackBock5
	mov	[BL1e],2
	mov	[PDDO1],2
BlackBock5:
	cmp	PianoScreen,2
	jnz	BlackBock51
	mov	[BL1f],2
	mov	[PDDO2],2
BlackBock51:
	cmp	Menu_downscreen,0      ;lower
	jnz	BlackBock6
	mov	[BL2a],2
BlackBock6:
	cmp	Menu_downscreen,1
	jnz	BlackBock7
	mov	[BL2b],2
BlackBock7:
	cmp	Menu_downscreen,4
	jnz	BlackBock8
	mov	[BL2c],2
BlackBock8:
	cmp	Menu_downscreen,6
	jnz	BlackBock9
	mov	[BL2d],2
BlackBock9:
	cmp	Menu_downscreen,7
	jnz	BlackBock10
	mov	[BL2e],2
BlackBock10:
	cmp	Menu_downscreen,2
	jnz	BlackBock11
	mov	[BL2a],2
	mov	[BL2f],2
BlackBock11:
	cmp	Menu_downscreen,3
	jnz	BlackBock11_5
	mov	[BL2b],2
	mov	[BL2f],2
BlackBock11_5:
	cmp	Menu_upperleft,2       ;Left
	jnz	BlackBock12
	mov	[BL3a],2
BlackBock12:
	cmp	Menu_upperleft,0
	jnz	BlackBock13
	mov	[BL3b],2
BlackBock13:
	cmp	Menu_upperleft,1       ;Left
	jnz	BlackBock14
	mov	[BL3c],2
BlackBock14:
	cmp	Menu_upperleft,3       ;Left
	jnz	BlackBock15
	mov	[BL3d],2
BlackBock15:
	jmp	_retp

AutoConfigSave:
	xor	AutoSave,34
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Puts a Text
;Calls:  AH = BitPlane
;	 CL = Nr of Letters
;	EDI = Scr. Position
;	ESI = Ptr to text
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintPullText	  Proc	  Near
	Pushad
	movzx	ecx,cl
TextLoopen:
	lodsb
	cmp	al,'|'
	jz	@@Text
	movzx	ebx,al
	call	PutCharacter
	inc	edi
@@Text:
	loop	TextLoopen
	Popad
	Ret
PrintPullText  EndP


