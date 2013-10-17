
;/ABS\01003010870000200002000020000200002000020000200798
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Variables
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

KeyLinePoint		dd	0	;points at the key
OldKeyLinePoint 	dd     -1
NumberOfKeyLines	dd	0
DoublePopup		db	0
NUMBERKEYOPTIONS	equ	14

KeysStuff	dd	MenuSel,SlotComm,Transp,Playkeys,RecKeys,MiscEdit,MuteLock,PattNav,SongNav,InsDelStuff,EditFunc,Blockfunc,StoredPos,InstSpec

MenuSel		db	'Main pulldown menu .......................'
		dd	MainPullDown
		db	'Block pulldown menu ......................'
		dd	PullDownKey
		db	'Exit the tracker .........................'
		dd	TrackerEnd

		db	'Disk options (Upper block) ...............'
		dd	DiskOpStart3

		db	'Position editor (Left block) .............'
		dd	PositionEditor2
		db	'Zoom/Unzoom track ........................'
		dd	ZoomPattern
		db	'Toggle Piano .............................'
		dd	DoPiano

		db	'Description editor (Lower block) .........'
		dd	DescriptionStart2
		db	'Sample editor (Lower block) ..............'
		dd	SampleEditor2_
		db	'Instrument editor (Lower block) ..........'
		dd	EnvelopeStart2

		db	'Restore Mainscreen .......................'
		dd	RestoreMainScreen

		db	'Help! (Popup).............................'
		dd	HelpStart2
		db	'Echo Editor (Popup).......................'
		dd	PutUpEchoEditor2

		db	'Load next selected song ..................'
		dd	LoadModuleKey
		db	-1

; save/restore slotcommands

SlotComm	db	'Store commands to slot 1 .................'
		dd	StoreCommand1
		db	'Store commands to slot 2 .................'
		dd	StoreCommand2
		db	'Store commands to slot 3 .................'
		dd	StoreCommand3
		db	'Store commands to slot 4 .................'
		dd	StoreCommand4
		db	'Store commands to slot 5 .................'
		dd	StoreCommand5
		db	'Store commands to slot 6 .................'
		dd	StoreCommand6
		db	'Store commands to slot 7 .................'
		dd	StoreCommand7
		db	'Store commands to slot 8 .................'
		dd	StoreCommand8
		db	'Store commands to slot 9 .................'
		dd	StoreCommand9
		db	'Store commands to slot 10 ................'
		dd	StoreCommand0

		db	'Insert one command from slot 1 ...........'
		dd	InsertOneCommand1
		db	'Insert one command from slot 2 ...........'
		dd	InsertOneCommand2
		db	'Insert one command from slot 3 ...........'
		dd	InsertOneCommand3
		db	'Insert one command from slot 4 ...........'
		dd	InsertOneCommand4
		db	'Insert one command from slot 5 ...........'
		dd	InsertOneCommand5
		db	'Insert one command from slot 6 ...........'
		dd	InsertOneCommand6
		db	'Insert one command from slot 7 ...........'
		dd	InsertOneCommand7
		db	'Insert one command from slot 8 ...........'
		dd	InsertOneCommand8
		db	'Insert one command from slot 9 ...........'
		dd	InsertOneCommand9
		db	'Insert one command from slot 10 ..........'
		dd	InsertOneCommand0

		db	'Insert all commands from slot 1 ..........'
		dd	InsertAllCommands1
		db	'Insert all commands from slot 2 ..........'
		dd	InsertAllCommands2
		db	'Insert all commands from slot 3 ..........'
		dd	InsertAllCommands3
		db	'Insert all commands from slot 4 ..........'
		dd	InsertAllCommands4
		db	'Insert all commands from slot 5 ..........'
		dd	InsertAllCommands5
		db	'Insert all commands from slot 6 ..........'
		dd	InsertAllCommands6
		db	'Insert all commands from slot 7 ..........'
		dd	InsertAllCommands7
		db	'Insert all commands from slot 8 ..........'
		dd	InsertAllCommands8
		db	'Insert all commands from slot 9 ..........'
		dd	InsertAllCommands9
		db	'Insert all commands from slot 10 .........'
		dd	InsertAllCommands0
		db	-1


; transposing keys

Transp		db	'Transpose track up one note (inst) .......'
		dd	NoteUpST
		db	'Transpose inst/track down one note .......'
		dd	NoteDownST
		db	'Transpose inst/pattern up one note .......'
		dd	NoteUpSP
		db	'Transpose inst/pattern down one note .....'
		dd	NoteDownSP
		db	'Transpose inst/block up one note .........'
		dd	NoteUpSB
		db	'Transpose inst/block down one note .......'
		dd	NoteDownSB

		db	'Transpose inst/track up one octave .......'
		dd	OctaveUpST
		db	'Transpose inst/track down one octave .....'
		dd	OctaveDownST
		db	'Transpose inst/pattern up one octave .....'
		dd	OctaveUpSP
		db	'Transpose inst/pattern down one octave ...'
		dd	OctaveDownSP
		db	'Transpose inst/block up one octave .......'
		dd	OctaveUpSB
		db	'Transpose inst/block down one octave .....'
		dd	OctaveDownSB

		db	'Transpose track up one note ..............'
		dd	NoteUpAT
		db	'Transpose track down one note ............'
		dd	NoteDownAT
		db	'Transpose pattern up one note ............'
		dd	NoteUpAP
		db	'Transpose pattern down one note ..........'
		dd	NoteDownAP
		db	'Transpose block up one note ..............'
		dd	NoteUpAB
		db	'Transpose block down one note ............'
		dd	NoteDownAB

		db	'Transpose track up one octave ............'
		dd	OctaveUpAT
		db	'Transpose track down one octave ..........'
		dd	OctaveDownAT
		db	'Transpose pattern up one octave ..........'
		dd	OctaveUpAP
		db	'Transpose pattern down one octave ........'
		dd	OctaveDownAP
		db	'Transpose block up one octave ............'
		dd	OctaveUpAB
		db	'Transpose block down one octave ..........'
		dd	OctaveDownAB
		db	-1

; playing keys

Playkeys	db	'Play current row .........................'
		dd	PlayRow
		db	'Play current row/advance .................'
		dd	PlayRow_A
		db	'Start song from current pattern ..........'
		dd	StartMod
		db	'Start song from current row ..............'
		dd	StartMod3
		db	'Loop pattern .............................'
		dd	StartPatt
		db	'Loop pattern from current row ............'
		dd	StartPatt3
		db	-1

; recording

RecKeys		db	'Record pattern ...........................'
		dd	Recpatt
		db	'Record pattern from current row ..........'
		dd	RecPatt3
		db	'Record song ..............................'
		dd	Recsong
		db	-1

; misc. editing keys

MiscEdit	db	'Toggle edit mode / stop music ............'
		dd	Space
		db	'Decrease base octave .....................'
		dd	OctaveDn
		db	'Increase base octave .....................'
		dd	OctaveUp
		db	'Note Off..................................'
		dd	NoteOff
		db	-1

; channel muting/locking

MuteLock	db	'Mute current track .......................'
		dd	MuteOne
		db	'Solo current track .......................'
		dd	SoloOne
		db	'Mute all tracks ..........................'
		dd	MuteAll2
		db	'Unmute all tracks ........................'
		dd	UnMuteAll2
		db	-1

; pattern navigation

PattNav		db	'Cursor up (using rowskip, if enabled) ....'
		dd	ArrowXUp
		db	'Cursor down (using rowskip, if enabled)...'
		dd	ArrowXDown
		db	'Cursor up, always one step ...............'
		dd	ArrowUp
		db	'Cursor down, always one step .............'
		dd	ArrowDown
		db	'Cursor left ..............................'
		dd	ArrowLeft
		db	'Cursor right .............................'
		dd	ArrowRight

		db	'8 rows up ................................'
		dd	Sub8Rows
		db	'8 rows down ..............................'
		dd	Add8Rows
		db	'16 rows up ...............................'
		dd	Sub16Rows
		db	'16 rows down .............................'
		dd	Add16Rows

		db	'32 rows up ...............................'
		dd	Sub32Rows
		db	'32 rows down .............................'
		dd	Add32Rows

		db	'Toggle arrowkeys using rowskip/onerow.....'
		dd	ToggleSTArrow

;		db	'Cursor up (fast) .........................'
;		dd	FasterArrowUp
;		db	'Cursor up (v.fast) .......................'
;		dd	FastestArrowUp
;		db	'Cursor down (fast) .......................'
;		dd	FasterArrowDown
;		db	'Cursor down (v.fast) .....................'
;		dd	FastestArrowDown

		db	'Next channel .............................'
		dd	ChangeChannel
		db	'Previous channel .........................'
		dd	ChangeChannel2

		db	'Jump to first row ........................'
		dd	GoFirstRow
		db	'Jump to last row .........................'
		dd	GoLastRow

		db	'Increase row adder .......................'
		dd	RowAddKey
		db	'Decrease row adder .......................'
		dd	RowSubKey
		db	-1

; moving through song

SongNav		db	'Decrease position ........................'
		dd	DecreasePosition2
		db	'Increase position ........................'
		dd	IncreasePosition2
		db	'Decrease pattern .........................'
		dd	DecreasePattern2
		db	'Increase pattern .........................'
		dd	IncreasePattern2
		db	-1

; insert/delete stuff in pattern

InsDelStuff	db	'Insert note, push track down .............'
		dd	InsNote1
		db	'Insert command, push others down .........'
		dd	InsCmd1
		db	'Insert row, push pattern down ............'
		dd	InsPatt1
		db	'Delete note above cursor, move track up ..'
		dd	InsNote2
		db	'Delete cmd above cursor, move others up ..'
		dd	InsCmd2
		db	'Delete row above cursor, move pattern up .'
		dd	InsPatt2
		db	'Delete everything at CursorPos ...........'
		dd	DelAll
		db	'Delete one command at CursorPos ..........'
		dd	DelCmd
		db	'Delete all commands at CursorPos .........'
		dd	DelAllCmd

	   ; same thing?!?!?!

		db	'Insert note, push others down ............'
		dd	InsNote4
		db	'Delete cmd above cursor, move others up ..'
		dd	InsNote5
		db	'Delete note at cursor position ...........'
		dd	DelNote
		db	-1

; editing functions

EditFunc	db	'View previous command number (one channel)'
		dd	DecreaseCmdNr
		db	'View next command number (one channel)....'
		dd	IncreaseCmdNr

		db	'View prev. command number (all channels)..'
		dd	DecreaseAllCmdNr
		db	'View next command number (all channels)...'
		dd	IncreaseAllCmdNr

		db	'Expand (double) track from CursorPos .....'
		dd	ExpandOneChannel
		db	'Expand (double) pattern from CursorPos ...'
		dd	ExpandPattern
		db	'Contract (halve) track from CursorPos ....'
		dd	ContractOneChannel
		db	'Contract (halve) pattern from CursorPos ..'
		dd	ContractPattern

		db	'Restore F6-F10 ...........................'
		dd	RestoreFPositions

		db	'Kill CursorPos to end of track ...........'
		dd	KillToEnd
		db	'Kill CursorPos to end of track (inst) ....'
		dd	KillSampleAtChannel
		db	'Double C4 Rate ...........................'
		dd	DoubleC4
		db	'Halve C4 Rate ............................'
		dd	HalveC4
		db      'Undo last major change ...................'
		dd	SwapUndoBuffer
		db	'Backup Pattern to undo buffer ............'
		dd	StoreUndoBuffer
		db	-1

; block cut/copy/paste

Blockfunc	db	'Begin mark block .........................'
		dd	MarkBlockBeg
		db      'Quick mark a block .......................'
		dd	QuickMark
		db      'Quick mark channel/pattern................'
		dd	MarkChanPatt
		db      'Mark to Stored position 1 ................'
		dd	JumpPattern1M
		db      'Mark to Stored position 2 ................'
		dd	JumpPattern2M
		db      'Mark to Stored position 3 ................'
		dd	JumpPattern3M
		db      'Mark to Stored position 4 ................'
		dd	JumpPattern4M
		db      'Mark to Stored position 5 ................'
		dd	JumpPattern5M
		db      'Mark to First row ........................'
		dd	MarkHOME
		db      'Mark to Last row .........................'
		dd	MarkEND
		db	'Mark Page UP .............................'
		dd	MarkPGUP
		db	'Mark Page DN .............................'
		dd	MarkPGDN
		db	'Mark One Step Up .........................'
		dd	MarkUp
		db	'Mark One Step Down........................'
		dd	MarkDn
		db	'Mark One Step Left........................'
		dd	MarkLt
		db      'Mark One Step Right.......................'
		dd	MarkRt

		db	'Unmark block .............................'
		dd	MM_UnmarkBlock
;		 db	 'Remark last block ........................'
;		 dd	 RemarkBlockBeg
		db	'Cut marked block .........................'
		dd	CutBlock
		db	'Copy marked block ........................'
		dd	CopyBlock
		db	'Paste block ..............................'
		dd	PasteBlock
		db	'Join-Paste block (mix)....................'
		dd	JoinPasteBlock
		db	'Insert (paste/push down) block ...........'
		dd	InsertBlock
		db	'Delete marked block ......................'
		dd	DeleteBlock
		db	'Ramp (interpolate) commanddata in block ..'
		dd	RampCommandData
		db	'Copy current inst.nr to block ............'
		dd	ChangeInst

		db	'Cut track ................................'
		dd	CutChannel
		db	'Copy track ...............................'
		dd	CopyChannel
		db	'Paste track ..............................'
		dd	PasteChannel

		db	'Cut pattern ..............................'
		dd	CutPattern
		db	'Copy pattern .............................'
		dd	CopyPattern
		db	'Paste pattern ............................'
		dd	PastePattern

		db	'Cut command ..............................'
		dd	CutCommand
		db	'Copy command .............................'
		dd	CopyCommand
		db	'Paste command ............................'
		dd	PasteCommand

		db	'Copy one command above cursor ............'
		dd	CopyOneAboveCommand
		db	'Copy one command above cursor, decrease ..'
		dd	CopyOneAboveCommandDec
		db	'Copy one command above cursor, increase ..'
		dd	CopyOneAboveCommandInc
		db	'Copy all commands above cursor ...........'
		dd	CopyAllAboveCommand
		db	'Copy all commands above cursor, decrease .'
		dd	CopyAllAboveCommandDec
		db	'Copy all commands above cursor, increase .'
		dd	CopyAllAboveCommandInc
		db	-1

; stored positions

StoredPos	db	'Goto stored position 1 ...................'
		dd	JumpPattern1
		db	'Store current position 1 .................'
		dd	StorePattern1
		db	'Record from stored position 1 ............'
		dd	RecPattern1
		db	'Play pattern from stored position 1 ......'
		dd	PlayPattern1
		db	'Goto stored position 2 ...................'
		dd	JumpPattern2
		db	'Store current position 2 .................'
		dd	StorePattern2
		db	'Record from stored position 2 ............'
		dd	RecPattern2
		db	'Play pattern from stored position 2 ......'
		dd	PlayPattern2
		db	'Goto stored position 3 ...................'
		dd	JumpPattern3
		db	'Store current position 3 .................'
		dd	StorePattern3
		db	'Record from stored position 3 ............'
		dd	RecPattern3
		db	'Play pattern from stored position 3 ......'
		dd	PlayPattern3
		db	'Goto stored position 4 ...................'
		dd	JumpPattern4
		db	'Store current position 4 .................'
		dd	StorePattern4
		db	'Record from stored position 4 ............'
		dd	RecPattern4
		db	'Play pattern from stored position 4 ......'
		dd	PlayPattern4
		db	'Goto stored position 5 ...................'
		dd	JumpPattern5
		db	'Store current position 5 .................'
		dd	StorePattern5
		db	'Record from stored position 5 ............'
		dd	RecPattern5
		db	'Play pattern from stored position 5 ......'
		dd	PlayPattern5
		db	-1

; changing instruments/deleting instruments

InstSpec	db	'Decrease current instrument ..............'
		dd	InstDn2
		db	'Increase current instrument ..............'
		dd	InstUp2
		db	'Decrease current sample ..................'
		dd	SampleDn2
		db	'Increase current sample ..................'
		dd	SampleUp2
		db	'Kill current instrument ..................'
		dd	KillInstrument
		db	'Kill current sample ......................'
		dd	KillSample
		db	-1


ExtraText	db	'-tfihS'
		db	'-lrtC'
		db	'-tlA'
		db	'-LspaC'

SpecialKeys	label byte
		db	 1,'csE',0              ;Esc
		db	59,'1F',0               ;F1
		db	60,'2F',0               ;F2
		db	61,'3F',0               ;F3
		db	62,'4F',0               ;F4
		db	63,'5F',0               ;F5
		db	64,'6F',0               ;F6
		db	65,'7F',0               ;F7
		db	66,'8F',0               ;F8
		db	67,'9F',0               ;F9
		db	68,'01F',0              ;F10
		db	87,'11F',0              ;F11
		db	88,'21F',0              ;F12
		db	92,'StnirP',0           ;PrintS
		db	70,'kcoLllorcS',0       ;ScrollLock
		db	41,"`",0                ;BWSQ
		db	14,'ecapskcaB',0        ;Backspace
		db     103,'tresnI',0           ;Insert
		db	95,'emoH',0             ;Home
		db	97,'pUegaP',0           ;PageUp
		db	69,'kcoLmuN',0          ;NumLock
		db	91,'/ yarG',0           ;Gray /
		db	55,'* yarG',0           ;Gray *
		db	74,'- yarG',0           ;Gray -
		db	15,'baT',0              ;Tab
		db	28,'retnE',0            ;Enter
		db     104,'eteleD',0           ;Delete
		db     100,'dnE',0              ;End
		db     102,'nwoDegaP',0         ;PageDown
		db	71,'7daPyeK',0          ;KeyPad7
		db	72,'8daPyeK',0          ;KeyPad8
		db	73,'9daPyeK',0          ;KeyPad9
		db	78,'+ yarG',0           ;Gray +
		db	75,'4daPyeK',0          ;KeyPad4
		db	76,'5daPyeK',0          ;KeyPad5
		db	77,'6daPyeK',0          ;KeyPad6
		db	54,'tfihSthgiR',0       ;RightShift
		db	96,'pUworrA',0          ;ArrowUp
		db	79,'1daPyeK',0          ;KeyPad1
		db	80,'2daPyeK',0          ;KeyPad2
		db	81,'3daPyeK',0          ;KeyPad3
		db	89,'retnEyerG',0        ;GreyEnter
		db	57,'ecapS',0            ;Space
		db	94,'rGtlA',0            ;AltGr
		db	90,'lrtCthgiR',0        ;RightCtrl
		db	98,'tfeLworrA',0        ;ArrowLeft
		db     101,'nwoDworrA',0        ;ArrowDown
		db	99,'thgiRworrA',0       ;ArrowRight
		db	82,'0daPyeK',0          ;KeyPad0
		db	83,'leDdaPyeK',0        ;KeyPadDel
		db	-1

NoKeyText	db	'No Key'
KeybText	db	'Keyboard'
NoteText	db	'Note Off'
KeyText1	db	'Press a key combination to replace!'
KeysText1	db	'The key is already used,@'
		db	'would you like to replace it?$'


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Keys start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Keysstart2:
KeysStart	Proc	Near
	pushad

	mov	oldkeylinepoint,-1
	call	updatedifferentstuff

	mov	menu_popup,8
	call	menuhandler

	mov	eax,KeyOptionSelected
	mov	bl,0
	call	KOButton

	call	calckeylines

	call	updatekeytext

	popad
	ret
KeysStart	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Keys end
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
KeysEnd 	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	menu_popup,0
	call	menuhandler
	Popad
	Ret
KeysEnd 	EndP



;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  CalcKeyLines
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
CalcKeyLines		Proc	Near
	Pushad
	mov	esi,KeyOptionSelected
	mov	esi,[KeysStuff+esi*4]
	xor	eax,eax
CalcLoppan:
	inc	eax
	add	esi,46
	cmp	byte ptr [esi],-1
	jnz	CalcLoppan
	mov	NumberOfKeyLines,eax
	Popad
	Ret
CalcKeyLines		EndP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Keys arrow up
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Keysarrowup	Proc	Near
	Pushad
	call	FixButton
	cmp	KeyLinePoint,0
	jz	_retp
	dec	KeyLinePoint
	call	UpdateKeyText
	Popad
	Ret
Keysarrowup	EndP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Keys arrow down
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
KeysArrowDown	Proc	Near
	Pushad
	call	FixButton
	mov	eax,NumberOfKeyLines
	sub	eax,16
	sub	eax,KeyLinePoint
	cmp	eax,0
	jle	_retp
	inc	KeyLinePoint
	call	UpdateKeyText
	Popad
	Ret
KeysArrowDown	EndP


SelectMode2:
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
	mov	bl,0
	call	ButtonUpDown

	mov	ButtonX1,96	;Mode 3
	mov	ButtonY1,222+32
	mov	ButtonX2,109
	mov	ButtonY2,234+32
	mov	bl,1
	call	ButtonUpDown

	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	ret


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  Update keytext
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
NrToClear	dd	0
UpdateKeyText		Proc	Near
	Pushad
	call	MouseOff

	move	edi,0a0000h+(31*80)+144/8
	mov	eax,KeyLinePoint
	mov	ebx,46
	mul	ebx
	mov	esi,KeyOptionSelected
	mov	esi,[KeysStuff+esi*4]
	add	esi,eax
	mov	ecx,NumberOfKeyLines
	mov	NrToClear,16
	sub     NrToClear,ecx
	cmp	ecx,16
	jbe	MainKeyUpdate
	mov	ecx,16
	mov	NrToClear,0
MainKeyUpdate:
	push	ecx
	push	edi
	push	esi

	mov	ah,1h
	mov	cl,42
	mov	FontPlane,1
	call	PrintText
	mov	FontPlane,0
	add	esi,42

	mov	eax,[esi]			;search for key
	add	edi,42+15
	lea	esi,KeyBoardTable
	xor	edx,edx
	mov	ecx,525
SearchLoop2:
	cmp	eax,[esi]
	jz	EndSearch
	add	esi,4
	inc	edx
	loop	SearchLoop2
NoKeyP:

	mov	ecx,46				;Scan in special table
	xor	esi,esi
@@ScanTBL3:
	cmp	dword ptr [PlayKeysTBL+esi+1],eax
	jz	@@Yesp3
	add	esi,6
	loop	@@ScanTBL3
	jmp	@@Nepz3
@@Yesp3:
	mov	al,byte ptr [PlayKeysTBL+esi]
	xor	edx,edx
	jmp	BetaMusic

@@Nepz3:
	mov	ecx,6				;print no key
	lea	esi,NoKeyText
	mov	ah,1
	mov	FontPlane,1
	sub	edi,5
	call	PrintText
	mov	FontPlane,0
	dec	edi
	mov	ecx,10
	call	ClearTexten
	jmp	EndOfMainUpdate

EndSearch:					;print keys
	mov	eax,edx
	xor	edx,edx
	mov	ecx,5
	div	ecx

BetaMusic:
	lea	esi,SpecialKeys
SearchKeyNow:					;get key
	cmp	byte ptr [esi],-1
	jz	NoKeysFound
	cmp	byte ptr [esi],al
	jz	SkipSearchNow
AddaLoop:
	inc	esi
	cmp	byte ptr [esi-1],0
	jnz	AddaLoop
	jmp	SearchKeyNow

NoKeysFound:					;get character and print a character
	mov	esi,Keyboard_Table
	mov	ecx,55
SearchKeyNow2:
	cmp	byte ptr [esi],al
	jz	SkipSearchNow2
	add	esi,2
	loop	SearchKeyNow2
	jmp	NoKeyP


SkipSearchNow2:
	mov	ebp,15
	movzx	ebx,byte ptr [esi+1]
	mov	ah,1
	mov	FontPlane,1
	call	PutCharacter
	mov	FontPlane,0
	dec	edi
	jmp	NextPartOfPut
SkipSearchNow:					;print key
	inc	esi
	mov	ebp,16
PrintaLoop:
	movzx	ebx,byte ptr [esi]
	mov	ah,1
	mov	FontPlane,1
	call	PutCharacter
	mov	FontPlane,0
	inc	esi
	dec	edi
	dec	ebp
	cmp	byte ptr [esi],0
	jnz	PrintaLoop
NextPartOfPut:					;put nothing, shift, ctrl or alt
	cmp	edx,0
	jnz	PutNothing
	mov	ecx,ebp 			;put nothing
	call	ClearTexten
	jmp	EndOfMainUpdate
PutNothing:					;put shift, ctrl, alt or capslock
	lea	esi,ExtraText
	cmp	edx,1
	jnz	NoAdd0___
	mov	ecx,6
	add	esi,0
NoAdd0___:
	cmp	edx,2
	jnz	NoAdd1___
	mov	ecx,5
	add	esi,6
NoAdd1___:
	cmp	edx,3
	jnz	noadd2___
	mov	ecx,4
	add	esi,11
NoAdd2___:
	cmp	edx,4
	jnz	NoAdd3___
	mov	ecx,6
	add	esi,15
NoAdd3___:
PuttaLoopa:
	movzx	ebx,byte ptr [esi]
	mov	ah,1
	mov	FontPlane,1
	call	PutCharacter
	mov	FontPlane,0
	dec	ebp
	inc	esi
	dec	edi
	loop	PuttaLoopa
	mov	ecx,ebp 			;put nothing
	call	ClearTexten

EndOfMainUpdate:				;end of this put
	pop	esi
	pop	edi
	pop	ecx
	add	esi,46
	add	edi,80*13
;	pushad
;	sub	edi,80
;	mov	al,0				;clear a line
;	mov	ecx,58
;	rep	stosb
;	popad
	loop	MainKeyUpdate

	mov	ecx,NrToClear
	jecxz	@@Balle
	mov	FontPlane,1
	lea	esi,Spaces
	mov	ah,1
@@ClearIt:
	push	ecx
	mov	cl,29
	call	PrintText
	add	edi,29
	call	PrintText
	add	edi,(80*13)-29
	pop	ecx
	loop	@@ClearIt
	mov	FontPlane,0
@@Balle:
	call	mouseon
	Popad
	Ret

UpdateKeyText		EndP
						;clear text (ecx bytes to clear)
ClearTexten:
	cmp	ecx,0
	jle	SkipClear
	mov	FontPlane,1
	mov	ebx,' '
	mov	ah,1
	call	PutCharacter
	dec	edi
	dec	ecx
	jecxz	SkipClear
	mov	ebx,'.'
	mov	ah,1
ClearaLoopa:
	call	PutCharacter
	dec	edi
	loop	ClearaLoopa
SkipClear:
	mov	FontPlane,0
	ret

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Change key
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
CurrentOffset	dd	0
BackupOffset	dd	0
BackupESI	dd	0
ConfigKeysRead	db	0
ChangeKey	Proc	Near
	Pushad

	movzx	eax,MouseY			;fix new offset
	sub	eax,31
	mov	ebx,13
	xor	edx,edx
	div	ebx
	add	eax,KeyLinePoint
	cmp	eax,NumberOfKeyLines
	jae	_retp

	mov	ebx,46
	mul	ebx
	add	eax,42
	mov	ebp,KeyOptionSelected
	mov	ebp,[KeysStuff+ebp*4]
	add	ebp,eax

	call	MouseOff
	mov	eax,[ebp]			;Clear Old Key
	mov	CurrentOffset,eax
	lea	esi,KeyBoardTable
SearchNowHereYes:
	cmp	dword ptr [esi],-1
	jz	NextPartOfKey
	cmp	[esi],eax
	jz	YesFound
	add	esi,4
	jmp	SearchNowHereYes
YesFound:
	mov	BackupOffset,eax
	mov	BackupESI,esi
	lea	eax,Dummy
	mov	[esi],eax
	jmp	Besame

Decreaser	db	0
NextPartOfKey:				;Check Special Table
	mov	ecx,46
	xor	esi,esi
@@ScanTBL:
	cmp	dword ptr [PlayKeysTBL+esi+1],eax
	jz	@@Yesp
	add	esi,6
	loop	@@ScanTBL
	jmp	Besame
@@Yesp:
	add	esi,Offset PlayKeysTBL+1
	mov	BackupOffset,eax
	mov	BackupESI,esi
	mov	dword ptr [esi],0
	jmp	Besame2
Besame:
	mov	eax,Offset Dummy
	mov	BackupOffset,eax
Besame2:
	call	MouseOff
	mov	moff,1
	lea	esi,KeyText1			;Change to popup !!!!!
	call	WriteTheText
	mov	ConfigKeysRead,1

	xor	ebp,ebp                         ;Check Keys
	xor	eax,eax
CheckKeyLoop:
	mov	ax,MasterFrequency
	cmp	ax,OldMasterFrequency
	jz	CheckKeyLoop
	mov	OldMasterFrequency,ax
	cmp	DClickCounter,0
	jz	NoDclickFix___
	dec	DClickCounter
	jg	NoDclickFix___
	mov	DClickCounter,0
	mov	MouseOnceReleased,0
	mov	DoubleClickExpired,1
NoDclickFix___:
	pushad
;	call	MouseStat
	call	UpdatePattern		;Update the pattern to screen
	call	UpdateDifferentStuff	;Updates DragBars and diff. Digits
	call	KeyBoardHandler 	;Handles all keystrokes
;	call	MouseHandler		;Handles all MouseMovements
	popad

	mov	eax,LastKeyPressed
	cmp	eax,0
	jz	SetZero44
	mov	Decreaser,1
	cmp	eax,89
	jb	NoChangeOfKey
	lea	esi,ExtendedKeys
LoadLoop:
	mov	bl,[esi]
	inc	esi
	cmp	al,0
	jz	CheckKeyLoop
	cmp	bl,al
	jnz	NotThatKey
	lodsb
	jmp	NoChangeOfKey
NotThatKey:
	inc	esi
	jmp	LoadLoop
NoChangeOfKey:

	cmp	al,42
	jz	SetShift
	cmp	al,29
	jz	SetCTRL
	cmp	al,56
	jz	SetALT
	cmp	al,58
	jz	SetCapsLock
	cmp	al,104
	ja	CheckKeyLoop
	cmp	ebp,0
	jnz	@@Nepz

	mov	ecx,46				;Scan in special table
	xor	esi,esi
@@ScanTBL2:
	cmp	byte ptr [PlayKeysTBL+esi],al
	jz	@@Yesp2
	add	esi,6
	loop	@@ScanTBL2
	jmp	@@Nepz
@@Yesp2:
	add	esi,Offset PlayKeysTBL+1
	cmp	dword ptr [esi],0
	jnz	SameKey
	jmp     NoSameKey

@@Nepz:
	lea	esi,KeyBoardTable		;Get offset in table
	and	eax,0ffh
	mov	ebx,20
	mul	ebx
	add	eax,ebp
	add	esi,eax
	lea	ebx,Dummy
	cmp	ebx,[esi]
	jz	NoSameKey
SameKey:
	pushad
;	mov	saveabyten,1
	mov	moff,0
	call	MouseOn
	lea	esi,KeysText1
	mov	SecondPopUp,25
	mov	SpecialSecondPopup,1
	mov	ConfigKeysRead,0
	mov	SpecialTextOffset,97*80+96/8
	mov	DoublePopup,1
	call	PopupHandler
	mov	SpecialTextOffset,0
	mov	SpecialSecondPopup,0
;	mov	ConfigKeysRead,1
	mov	DoublePopup,0
	call	MouseOff
;	mov	SaveaByten,0
	popad

	cmp	PopupStatus,0
	jnz	NoSamekey
	mov	eax,BackupOffset
	cmp	eax,Offset Dummy
	jz      SkipMova
	mov	esi,BackupESI
	mov	[esi],eax
	jmp	SkipMova


NoSameKey:
	mov	eax,CurrentOffset
	mov	[esi],eax
SkipMova:
	call	UpdateKeyText
	lea	esi,Spaces			;Remove text
	call	WriteTheText

	mov	ConfigKeysRead,0
	mov	moff,0
	call	mouseon
	Popad
	Ret
SetZero44:				;Set...
	dec	Decreaser
	jz      CheckKeyLoop
	mov	ebp,0
	jmp	CheckKeyLoop
SetShift:
	mov	ebp,4
	jmp	CheckKeyLoop
SetCTRL:
	mov	ebp,8
	jmp	CheckKeyLoop
SetALT:
	mov	ebp,12
	jmp	CheckKeyLoop
SetCapsLock:
	mov	ebp,16
	jmp	CheckKeyLoop
ChangeKey	EndP

WriteTheText:				;write the text
	pushad
	mov	ah,8h
	mov	cl,35
	move	edi,0a0000h+(252*80+18)
	mov	FontPlane,1
	call	PrintText
	mov	FontPlane,0
	popad
	ret

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       SectionSelect
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
KeyOptionSelected	dd	0	;Layout, Edit, etc
OldKeyOptionSelected	dd	0
KeySectionSelect	Proc    Near
	pushad
	movzx	eax,mouseY
	sub	eax,32
	mov	ebx,15
	xor	edx,edx
	div	ebx
	cmp	eax,NUMBERKEYOPTIONS
	jae	_retp
	cmp	KeyOptionSelected,eax
	jz	_retp

	mov	KeyOptionSelected,eax
	mov	bl,0
	call	KOButton
	mov	eax,OldKeyOptionSelected
	mov	bl,1
	call	KOButton
	mov	eax,KeyOptionSelected
	mov	OldKeyOptionSelected,eax
	call	CalcKeyLines
	mov	KeyLinePoint,0
	call	UpdateKeyText
	mov	OldKeyLinePoint,-1
	call	UpdateDifferentStuff
	popad
	ret
KeySectionSelect	Endp

KOButton:
	push	eax ebx
	mov	ButtonX1,9
	mov	ButtonY1,32
	mov	ButtonX2,21
	mov	ButtonY2,43
	mov	ecx,15
	mul	ecx
	add	ButtonY1,eax
	add	ButtonY2,eax
	call	ButtonUpDown
	pop	ebx eax
	ret

PlayKeysTBL	df	2,3,4,5,6,7,8,9,10,11,12,13,16,17,18,19,20,21,22,23,24,25,26,27,30,31,32,33,34,35,36,37,38,39,40,43,44,45,46,47,48,49,50,51,52,53
PlayKeysTBLLen	equ $-PlayKeysTBL



FT2KeyMap:
	call	FixButton
	mov	KeyMapSelect,1
	call	LoadKeyMap
	call	updatekeytext
	ret
ST3KeyMap:
	call	FixButton
	mov	KeyMapSelect,2
	call	LoadKeyMap
	call	updatekeytext
	ret
VSKeyMap:
	call	FixButton
	mov	KeyMapSelect,0
	call	LoadKeyMap
	call	updatekeytext
	ret





