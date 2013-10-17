
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				   Variables
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

;oldoptionpos		 dd	 0

;optionconfigpos	 dd	 1

;theselect		 dd	 0
;oldtheselect		 dd	 0
;selecten		 dd	 0
;switchoffset		 dd	 0
OptionChangeOffset	dd	0	;offset to variable that changes

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Option Start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
OptionStart:
	mov	menu_popup,11
	call	menuhandler
	call	UpdateOptionScreen
	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Option End
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
OptionEnd	Proc	Near
	Pushad
	call	ButtonHandler
	cmp	eax,0
	jz	ophopp
	popad
	ret
ophopp:
	mov	menu_popup,0
	call	menuhandler
	call	FixkeyboardLayout
	mov	al,TrackerStyle
	mov	TrackerStyle2,al
updatepatterns:
	cmp	PianoScreen,0
	jz	NoPoan
	call	MenuPiano
NoPoan:
	cmp	TrackerStyle,0
	jz	ProStyle
	cmp	TrackerStyle,1
	jz	ScreamStyle
	jmp	QuitSTPTShit
ProStyle:
	cmp	Menu_DownScreen,1
	jz	DecDS
	cmp	Menu_DownScreen,3
	jz	DecDS2
	jmp	QuitSTPTShit
ScreamStyle:
	cmp	Menu_DownScreen,0
	jz	IncDS
	cmp	Menu_DownScreen,2
	jz	IncDS
	jmp	QuitSTPTShit

DecDS2:
	mov	Menu_DownScreen,0
	call	MenuHandler
	mov	Menu_DownScreen,2
	call	MenuHandler
	jmp	QuitSTPTShit
DecDS:
	dec	Menu_DownScreen
	call	MenuHandler
	jmp	QuitSTPTShit
IncDS:
	inc	Menu_DownScreen
	call	MenuHandler
	jmp	QuitSTPTShit
QuitSTPTShit:

	mov	oldrow,-1
	mov	oldpos,-1
	mov	OldLen,-1
	mov	OldBPM,-1
	mov	OldSpeed,-1
	mov	OldCurrentFileName,-1
	mov	OldCurrentInstName,-1
	mov	oldpos2,-1
	mov	OldTime_Hour,-1
	mov	OldTime_Min,-1
	mov	OldTime_Sec,-1
	mov	OldPatt,-1
	mov	OldPatt2,-1
	mov	OldPattName,-1
	mov	OldCurrentChannel,-1
	mov	OldInfoTextPtr,-1

	lea	edi,oldputs
	mov	eax,-1
	mov	ecx,20
	rep	stosd

;	call	RowSub
;	call	RowAddKey
	call	PrintSampleInfo
	call	PrintModName
	call	UpdatePattDefScreen
	;call	 ViewDescText

optionends:
	call	UpdateChannelInfo
	mov	OldRow,-1
	popad
	ret
Optionend2:
	pushad
	jmp	ophopp
OptionEnd	Endp


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Option Arrow up
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Optionarrowup	Proc	Near
	pushad
	call	fixbutton
	cmp	CurrentOptionList,0
	jz	_retp
	dec	CurrentOptionList
	call	UpdateOptionText1
	popad
	ret
Optionarrowup	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Option Arrow down
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Optionarrowdown	Proc    Near
	pushad
	call	fixbutton
	mov	eax,NrOption
	sub	eax,16
	jle	_retp

	cmp	CurrentOptionList,eax
 	jz	_retp

	inc	CurrentOptionList
	call	UpdateOptionText1
	popad
	ret
Optionarrowdown	Endp

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       SectionSelect
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
OptionSelected		dd	0	;Layout, Edit, etc
OldOptionSelected	dd	0
SectionSelect	Proc    Near
	pushad
	movzx	eax,mouseY
	sub	eax,45
	mov	ebx,15
	xor	edx,edx
	div	ebx
	cmp	eax,NUMBEROPTIONS
	jae	_retp
	cmp	OptionSelected,eax
	jz	_retp

	mov	OptionSelected,eax
	mov	bl,0
	call	COButton
	mov	eax,OldOptionSelected
	mov	bl,1
	call	COButton
	mov	eax,OptionSelected
	mov	OldOptionSelected,eax
	mov	CurrentOption,0
	mov	CurrentOptionList,0
	mov	CurrentHelpList,0
	call	GetCurrentSwitch
	call	UpdateOptionScreen
	popad
	ret
SectionSelect	Endp

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Option Select
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

OptionSelect	Proc    Near
	pushad
	movzx	eax,MouseY
	sub	eax,46
	mov	ebx,13
	xor	edx,edx
	div	ebx
	cmp	eax,NrOption
	jae	_retp
	add	eax,CurrentOptionList
	mov	CurrentOption,eax
	call	GetCurrentSwitch
	mov	CurrentHelpList,0
	call	UpdateOptionScreen
	popad
	ret
OptionSelect	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				HelpText Up
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Option_up	Proc	Near
	pushad
	call	fixbutton
	cmp	CurrentHelpList,0
	jz	_retp
	dec	CurrentHelpList
	call	UpdateOptionText3
	popad
	ret
Option_up	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				HelpText Dn
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Option_down	Proc	Near
	pushad
	call	fixbutton
	mov	eax,NrHelp
	sub	eax,7
	jle	_retp

	cmp	CurrentHelpList,eax
 	jz	_retp

	inc	CurrentHelpList
	call	UpdateOptionText3
	popad
	ret
Option_down	Endp

SwitchSelect	Proc    Near
	pushad
	movzx	eax,MouseY
	sub	eax,46
	mov	ebx,13
	xor	edx,edx
	div	ebx
	cmp	eax,NrSwitch
	jae	_retp
	mov	CurrentSwitch,eax
	call	SetCurrentSwitch
	call	UpdateOptionScreen
	popad
	ret
SwitchSelect	EndP

COButton:
	push	eax ebx
	mov	ButtonX1,89
	mov	ButtonY1,45
	mov	ButtonX2,101
	mov	ButtonY2,56
	mov	ecx,15
	mul	ecx
	add	ButtonY1,eax
	add	ButtonY2,eax
	call	ButtonUpDown
	pop	ebx eax
	ret

UpdateOptionScreen	Proc	Near
	pushad
	mov	eax,OptionSelected
	mov	bl,0
	call	COButton
	call	UpdateOptionText1
	call	UpdateOptionText2
	call	UpdateOptionText3
	mov	OldCurrentOptionList,-1
	mov	OldCurrentHelpList,-1
	popad
	ret
UpdateOptionScreen	EndP


NrOption		dd	0
CurrentOption		dd	0		;Option Choice
CurrentOptionList	dd	0		;1:st in list
OldCurrentOptionList	dd	-1
UpdateOptionText1	Proc	Near
	call	MouseOff
	mov	ScanLength,16
	move	edi,0a0000h+(46*80)+240/8
	mov	ah,1
	mov	FontPlane,1
	mov	esi,OptionSelected
	mov	esi,[OptionListTBL+esi*4]
	call	ScanLen
	mov	NrOption,ecx
	mov	Dword Ptr [DragBarTable+37*24+6],ecx	;New Pos
	mov	ecx,CurrentOptionList
	mov	ebx,ecx
	shl	ecx,4
	add	esi,ecx

	mov	ecx,16
@@Next:
	push	ecx
	cmp	byte ptr [esi],-1
	jz	@@End
@@NoEnd:
	cmp	ebx,CurrentOption
	jnz	@@Skutt
	mov	InvertText,-1
@@Skutt:
	mov	ecx,16
	call	PrintText
	mov	InvertText,0
	add	esi,ecx
	add	edi,80*13
	inc	ebx
	pop	ecx
	loop	@@Next
	mov	FontPlane,0
	call	MouseOn
	ret

@@End:
	pop	ecx
	lea	esi,Spaces
@@End2:
	push	ecx
	mov	ecx,16
	call	PrintText
	add	edi,80*13
	pop	ecx
	loop	@@End2
	mov	FontPlane,0
	call	MouseOn
	ret
UpdateOptionText1	EndP

NrSwitch	dd	0
CurrentSwitch	dd	0
UpdateOptionText2	Proc	Near
	call	MouseOff
	mov	ScanLength,16
	move	edi,0a0000h+(46*80)+400/8
	mov	ah,1
	mov	FontPlane,1
	mov	esi,OptionSelected
	mov	esi,[SwitchListTBL+esi*4]
	mov	ecx,CurrentOption
	call	ScanSwitch
	call	ScanLen
	mov	NrSwitch,ecx

	xor	ebx,ebx
	mov	ecx,16
@@Next:
	push	ecx
	cmp	byte ptr [esi],-1
	jz	@@End
@@NoEnd:
	cmp	ebx,CurrentSwitch
	jnz	@@Skutt
	mov	InvertText,-1
@@Skutt:
	mov	ecx,16
	call	PrintText
	mov	InvertText,0
	add	esi,ecx
	add	edi,80*13
	inc	ebx
	pop	ecx
	loop	@@Next
	mov	FontPlane,0
	call	MouseOn
	ret

@@End:
	pop	ecx
	lea	esi,Spaces
@@End2:
	push	ecx
	mov	ecx,16
	call	PrintText
	add	edi,80*13
	pop	ecx
	loop	@@End2
	mov	FontPlane,0
	call	MouseOn
	ret
UpdateOptionText2	EndP

NrHelp			dd	0
CurrentHelpList		dd	0
OldCurrentHelpList	dd	-1
UpdateOptionText3	Proc	Near
	call	MouseOff
	mov	ScanLength,35
	move	edi,0a0000h+(274*80)+240/8
	mov	FontPlane,1
	mov	esi,OptionSelected
	mov	esi,[HelpListTBL+esi*4]
	mov	ecx,CurrentOption
	call	ScanSwitch
	call	ScanLen
	mov	NrHelp,ecx
	mov	Dword Ptr [DragBarTable+38*24+6],ecx	;New Pos
	mov	ecx,CurrentHelpList
	mov	eax,35
	mul	ecx
	add	esi,eax

	mov	ah,1
	mov	ecx,7
@@Next:
	push	ecx
	cmp	byte ptr [esi],-1
	jz	@@End
@@NoEnd:
	mov	ecx,35
	call	PrintText
	add	esi,ecx
	add	edi,80*13
	inc	ebx
	pop	ecx
	loop	@@Next
	mov	FontPlane,0
	call	MouseOn
	ret

@@End:
	pop	ecx
	lea	esi,Spaces
@@End2:
	push	ecx
	mov	ecx,35
	call	PrintText
	add	edi,80*13
	pop	ecx
	loop	@@End2
	mov	FontPlane,0
	call	MouseOn
	ret
UpdateOptionText3	EndP

;IN: esi=Offset
;    ecx=Count
;OUT esi=New Offset
ScanLength	dd	0
ScanSwitch:
	jecxz	_ret
	push	ecx edx
	sub	esi,ScanLength
@@Scan:
	add	esi,ScanLength
	cmp	byte ptr [esi],-1
	jnz	@@Scan
	inc	esi
	loop	@@Scan
	pop	edx ecx
	ret

;IN: esi=Offset
;OUT:ecx=table len
ScanLen:
	mov	ecx,ScanLength
	neg	ecx
@@SL:
	add	ecx,ScanLength
	cmp	byte ptr [esi+ecx],-1
	jnz	@@SL
	push	eax edx
	mov	eax,ecx
	mov	ecx,ScanLength
	xor	edx,edx
	div	ecx
	mov	ecx,eax
	pop	edx eax
	ret

GetCurrentSwitch:
	mov	esi,OptionSelected
	mov	esi,[DataListTBL+esi*4]
	add	esi,CurrentOption
	movzx	eax,byte ptr [esi]
	mov	CurrentSwitch,eax
	ret

SetCurrentSwitch:
	mov	esi,OptionSelected
	mov	esi,[DataListTBL+esi*4]
	add	esi,CurrentOption
	mov	eax,CurrentSwitch
	mov	OptionChangeOffset,esi
	mov	[esi],al
	ret




;/ABS\00200000010000100019000010000100001000010000100001
