

;/ABS\01814007290038000140000040046702498022110195603181

;----------------------------- The Sampling ------------------------------
SampleNote		dd	62
SampleRate2		dd	16726

SampleNoteOrRate	db	1	;0=note 1=rate
SetCD			db	0	;
SetMic			db	0	;0=off	1=on
SetLinein		db	0	;0=off	1=on
SetEqualizer		db	1	;0=off	1=on
SetScopes		db	1	;0=off	1=on
Sample8or16bits 	db	0	;0=8bits 1=16bits
SampleStereo		db	0	;0=mono 1=stereo

EqualizermaxLeft	dd	0
EqualizermaxRight	dd	0
Leftequalizer		dd	0	;Left (mono)
Rightequalizer		dd	0	;Right
OldLeftequalizer	dd     -1
OldRightequalizer	dd     -1
Rednumber		dd	5	;Numbers of red in equalizers


Allow_Sample		db	0	;Allowed by hardware
Allow_StereoSamp	db	0
Allow_16Samp		db	0
Allow_LineInSamp	db	0
Max_SampleRate		dd	0
Max_SampleNote		dd	0




;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  CD Prepare
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;Input:
;	eax=Offset to main buffer
;	ebx=Offset to second buffer
;	ecx=Main buffer size in bytes
;	edx=Second buffer size in bytes (0=no second buffer)
;Output:
;	None

CD_MainBufferOffset	dd	0
CD_SecondBufferOffset	dd	0
CD_MainBufferSize	dd	0
CD_SecondBufferSize	dd	0
RealSecondSeg		dw	0
RealSecondOffset	dw	0
ProtectedOffset 	dd	0

CDPrepare	Proc	Near
	cmp	EnableCD,0
	jz	_ret
	pushad
	mov	CD_MainBufferOffset,eax
	mov	CD_SecondBufferOffset,ebx
	mov	CD_MainBufferSize,ecx
	mov	CD_SecondBufferSize,edx

IF DOS32VERSION
	xor	ecx,ecx
ENDIF

IF PMODEWVERSION
	mov	ecx,2000
ENDIF

	call 	DOSprepare
					;ax=segment till 8k buffer
					;ebx=start protectet mode k†d
	mov	ax,Real_DS
	mov	RealSecondSeg,ax
	mov	RealSecondOffset,1000	;Offset in real mode

	and	eax,0ffffh
	shl	eax,4
	mov	ProtectedOffset,eax

	popad
	ret

;**********************

;	pushad
;	mov	CD_MainBufferOffset,eax
;	mov	CD_SecondBufferOffset,ebx
;	mov	CD_MainBufferSize,ecx
;	mov	CD_SecondBufferSize,edx

;	mov	ax,0ee02h		;Get real mode info
;	int	31h
;					;ax=segment till 8k buffer
;					;ebx=start protectet mode k†d
;	mov	RealSecondSeg,ax
;	mov	RealSecondOffset,1000	;Offset in real mode
;	mov	Real_ES,ax
;	mov	Real_DS,ax

;	and	eax,0ffffh
;	shl	eax,4
;	sub	eax,ebx
;	mov	ProtectedOffset,eax

;	popad
;	ret

;**********************
CDprepare	endp


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       CD REAL MOVE
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;Input:
;	None
;Output:
;	RealSecondSeg	 = Segment to second buffer
;	RealSecondOffset = Offset to second buffer
CDRealMove	Proc	Near
	cmp	EnableCD,0
	jz	_ret
	pushad

	mov	edi,ProtectedOffset		;move main
	mov	esi,CD_MainBufferOffset
	mov	ecx,CD_MainBufferSize
	rep	movsb

	mov	edi,ProtectedOffset		;move second
	movzx	eax,RealSecondOffset
	add	edi,eax
	mov	esi,CD_SecondBufferOffset
	mov	ecx,CD_SecondBufferSize
	rep	movsb
	popad
	ret
CDRealMove	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  CD Int
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
CDInt		Proc	Near
	cmp	EnableCD,0
	jz	_ret
	push	2fh
	call	DOSInterrupt
	pushad

	mov	esi,ProtectedOffset
	mov	edi,CD_MainBufferOffset
	mov	ecx,CD_MainBufferSize
	rep	movsb

	mov	esi,ProtectedOffset
	movzx	eax,RealSecondOffset
	add	esi,eax
	mov	edi,CD_SecondBufferOffset
	mov	ecx,CD_SecondBufferSize
	jecxz	_retp
	rep	movsb

	popad
	ret
CDInt		Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  CD Control
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
CD_info 		db	1,1,0,0,0  ;TRACK,INDEX,MIN,SEC,Frames

					;------------ CD varibles
CD_DrvNo		db	0
CD_DrvChar		db	0

CD_LoTrk		db	0
CD_HiTrk		db	0
CD_EndAddrR		dd	0
CD_REDPos		dd	99	dup(0)
CD_EndAddrH		dd	0
CD_HSGPos		dd	99	dup(0)

CD_IOCtlBlk		db	20h	dup(0)
IOCtl			db	20h	dup(0)

DoorStatus		db	0	;1=Door open
PlayStatus		db	0	;0=Stop,1=Play,2=Pause,3=Sector Timeplay
CD_infoOLD		db	5	dup(0)
CD_on			db	1	;0=off 1=on

SectorTimeChange	dw	0
SectorToPlay		dd	0

SectorPosSave		dd	0
SectorInfoSave		db	5	dup(0)
TimeShow		db	0	;0=From begin 1=Time left on track
CD_VolumeOLD		dd	-1
CD_Volume		db	255
InputCDvolumeTemp	dd	0
DoorWait		dw	0
DoZeroStart		db	0
SampleCDsync:				;----------- Sample CD sync
	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	CD_on,0
	jz	_retp
	cmp	DoorStatus,1
	jz	_retp
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	cmp	PlayStatus,1
	jz	_retp
	cmp	PlayStatus,3
	jz	_retp
	call	CD_play2
	mov	DoZeroStart,1
	call	StartToSamp2
	_rp
CD_VolumeUP:				;----------- CD volume up
	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	Menu_Popup,13
	jnz	_retp
	cmp	CD_on,0
	jz	_retp
	cmp	DoorStatus,1
	jz	_retp
	call	Fixbutton
	cmp	CD_Volume,255
	jz	_retp
	inc	CD_Volume
	_rp
CD_VolumeDown:				;----------- CD volume down
	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	Menu_Popup,13
	jnz	_retp
	cmp	CD_on,0
	jz	_retp
	cmp	DoorStatus,1
	jz	_retp
	call	Fixbutton
	cmp	CD_Volume,0
	jz	_retp
	dec	CD_Volume
	_rp
UpdateCDvol:				;----------- Update CD vol
	cmp	EnableCD,0
	jz	_ret
	pushad
	mov	eax,[CD_volumen]
	mov	CD_volume,al
	call	ChangeCDvolume

	_rp
ShowCDvolume:				;----------- Show CD volume
	cmp	EnableCD,0
	jz	_ret
	pushad
	movzx	eax,CD_volume
	cmp	eax,CD_volumeOld
	jz	_retp
	mov	CD_volumeOld,eax
	mov	[CD_volumen],eax
	mov	dword ptr [CD_volumen+4],1
	call	ChangeCDvolume
	_rp

ChangeCDvolume: 			;------------ change CD volume
	cmp	EnableCD,0
	jz	_ret
	pushad
	call	clearCDblock
	mov	byte ptr [IOctl],3
	movzx	ebx,CD_volume
	mov	[IOctl+2],bl
	mov	[IOctl+4],bl
	mov	[IOctl+6],bl
	mov	[IOctl+8],bl
	call	SetIOCtl
	_rp
CD_repeat:				;----------- CD repeat
	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	PlayStatus,1
	jnz	_retp
	cmp	DoorStatus,1
	jz	_retp
	cmp	byte ptr [CD_info],-1
	jz	_retp
	cmp	byte ptr [CD_info+1],-1
	jz	_retp
	cmp	byte ptr [CD_info+2],-1
	jz	_retp
	cmp	byte ptr [CD_info+3],-1
	jz	_retp
	cmp	byte ptr [CD_info+4],-1
	jz	_retp
	movzx	eax,byte ptr [CD_info+2]
	mov	ebx,4500
	mul	ebx
	mov	ecx,eax
	movzx	eax,byte ptr [CD_info+3]
	mov	ebx,75
	mul	ebx
	add	eax,ecx
	movzx	ebx,[CD_info]
	add	eax,[CD_EndAddrH+ebx*4]
	mov	ecx,[CD_EndAddrH]

	add	eax,75
	cmp	eax,ecx
	jb	_retp
	call	MouseHourGlass
	call	Stop_cd
	mov	eax,[CD_endAddrH+4]
	mov	SectorToPlay,eax
	call	Play_CD_Sector
	mov	byte ptr [CD_info],1
	mov	byte ptr [CD_info+1],1
	mov	word ptr [CD_info+2],0
	mov	byte ptr [CD_info+4],0
	call	MouseArrow
	jmp	_retp
ClearCDdigits:				;------------ Clear CD digits
	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	Menu_popup,13
	jnz	_retp
	call	mouseoff
	planewrite 00001111b
	move	edi,0a0000h+88/8+129*80
	call	Clearit
	;move	 edi,0a0000h+120/8+129*80
	;call	 Clearit
	move	edi,0a0000h+152/8+129*80
	call	Clearit
	move	edi,0a0000h+176/8+129*80
	call	Clearit
	move	edi,0a0000h+200/8+129*80
	call	Clearit
	call	mouseon
	call	clearcdvol
	mov	dword ptr [CD_volumen+4],1
	mov	byte ptr [dragbarstatus+9],0
	mov	dword ptr [CD_infoOLD],-1
	mov	byte ptr [CD_infoOLD+4],-1
	mov	CD_VolumeOLD,-1
	jmp	_retp
Clearit:
	cmp	EnableCD,0
	jz	_ret
	pushad
	mov	ecx,12
LoopenCD:
	cmp	EnableCD,0
	jz	_ret
	mov	word ptr [edi],0
	add	edi,80
	loop	LoopenCD
	jmp	_retp

UpdateTimeFromSector:			;------------ Update time from sector
	cmp	EnableCD,0
	jz	_ret
	pushad
	lea	esi,CD_HSGpos		;Timeshow=0
	mov	eax,SectorToPlay
	xor	edx,edx
	movzx	ecx,CD_hitrk
	movzx	ebx,CD_lotrk
	sub	ecx,ebx
	inc	ecx
SearchCDtrack:
	cmp	eax,dword ptr [esi]
	jb	ThisTrack
	add	esi,4
	inc	edx
	loop	SearchCDTrack
ThisTrack:
	mov	[CD_info],dl
	cmp	TimeShow,0
	jz	TimeShow0
	mov	ebx,dword ptr [CD_HSGpos+edx*4]
	sub	ebx,eax
	mov	eax,ebx
	jmp	AfterTimeShow
TimeShow0:
	sub	eax,dword ptr [CD_HSGpos+edx*4-4]
AfterTimeShow:
	mov	ebx,4500
	xor	edx,edx
	div	ebx
	mov	[CD_info+2],al
	mov	eax,edx
	mov	ebx,75
	xor	edx,edx
	div	ebx
	mov	[CD_info+3],al
	mov	[CD_info+4],dl
	jmp	_retp
SectorPlay:				;--------------------- Sector Play
	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	PlayStatus,3
	jnz	_retp
	mov	ax,MasterFrequency
	sub	ax,SectorTimeChange
	cmp	ax,40
	jb	_retp
	mov	PlayStatus,1
	call	MouseHourGlass
	mov	ebx,SectorToPlay
	call	Play_CD_Sector
	call	MouseArrow
	jmp	_retp
CD_Text:				;------------------- CD_text

	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	Menu_popup,13
	jnz	_retp


	cmp	CD_on,0
	jz	_retp
	cmp	DoorStatus,1
	jz	_retp
	call	clearCDblock		;If no disc in drive no info
	mov	byte ptr [IOctl],6
	call	GetIOCtl
	mov	eax,dword ptr [IOctl+1]
	bt	eax,11
	jc	_retp

	;jmp	_retp

	call	ShowCDvolume
	mov	mousex1,87
	mov	mousey1,128
	mov	mousex2,215
	mov	mousey2,140
	movzx	ebx,[CD_info+0]
	cmp	bl,[CD_infoOLD+0]
	jz	SkipCDPutOut1
	mov	ah,01h
	mov	cl,2
	move	edi,0a0000h+88/8+129*80
	call	mouseoff
	mov	fontplane,1
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
SkipCDPutOut1:

	movzx	ebx,[CD_info+2]
	cmp	bl,[CD_infoOLD+2]
	jz	SkipCDPutOut3
	mov	ah,01h
	mov	cl,2
	move	edi,0a0000h+152/8+129*80
	call	mouseoff
	mov	fontplane,1
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
SkipCDPutOut3:
	movzx	ebx,[CD_info+3]
	cmp	bl,[CD_infoOLD+3]
	jz	SkipCDPutOut4
	mov	ah,01h
	mov	cl,2
	move	edi,0a0000h+176/8+129*80
	call	mouseoff
	mov	fontplane,1
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
SkipCDPutOut4:
	movzx	ebx,[CD_info+4]
	cmp	bl,[CD_infoOLD+4]
	jz	SkipCDPutOut5
	mov	ah,01h
	mov	cl,2
	move	edi,0a0000h+200/8+129*80
	call	mouseoff
	mov	fontplane,1
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
SkipCDPutOut5:
	call	mousereset
	mov	eax,dword ptr CD_info
	mov	dword ptr CD_infoOLD,eax
	mov	al,byte ptr [CD_info+4]
	mov	byte ptr [CD_infoOLD+4],al
	jmp	_retp

CDControl:			       ;------------ CD Control
	cmp	EnableCD,0
	jz	_ret
	cmp 	Menu_popup,13
	jz	jaaaaaaa
	cmp 	Menu_popup,14
	jz	jaaaaaaa
	ret
jaaaaaaa:
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	pushad
	call	GetCDInfo
	call	CheckDoorStatus
	call	SectorPlay
	call	CD_repeat

	jmp	_retp


CheckDoorStatus:		       ;------------ Check Door Status
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	Menu_popup,13
	jnz	_retp

	mov	ax,masterfrequency
	sub	ax,DoorWait
	cmp	ax,30
	jb	_retp
	mov	ax,masterfrequency
	mov	DoorWait,ax


;	*************************
;	lea	ebx,CD_IOCtlBlk
;	mov	byte ptr [ebx],10h
;	mov	byte ptr [ebx+2],03h
;	lea	edx,IOCtl
;	add	edx,_code32a
;	mov	eax,edx
;	shr	edx,4
;	and	ax,0fh
;	mov	word ptr [ebx+0eh],ax
;	mov	word ptr [ebx+10h],dx
;	mov	byte ptr [ebx+12h],6
;	mov	byte ptr [IOctl],9
;
;	add	ebx,_code32a
;	mov	eax,ebx
;	shr	ebx,4
;	and	ax,0fh
;	movzx	cx,CD_DrvNo
;	mov	v86r_bx,ax
;	mov	v86r_es,bx
;	mov	v86r_ax,1510h
;	mov	v86r_cx,cx
;	mov	al,2fh
;	int	33h
;	*************************
;---------------------------------
	pushad
	lea	eax,CD_IOCtlBlk
	lea	ebx,IOCtl
	mov	ecx,20h
	mov	edx,20h
	call	CDPrepare

	mov	dx,RealSecondSeg
	mov	ax,RealSecondOffset
	lea	ebx,CD_IOCtlBlk
	mov	byte ptr [ebx],10h
	mov	byte ptr [ebx+2],03h
	mov	word ptr [ebx+0eh],ax
	mov	word ptr [ebx+10h],dx
	mov	byte ptr [ebx+12h],6
	mov	byte ptr [IOctl],9
	call	CDRealMove

	xor	bx,bx
	movzx	cx,CD_DrvNo
	mov	ax,1510h
	call	CDInt
	popad
;---------------------------------

	cmp	byte ptr [IOctl+1],0ffh
	jnz	_retp

	call	clearCDblock		;If no disc in drive no info
	mov	byte ptr [IOctl],6
	call	GetIOCtl
	mov	eax,dword ptr [IOctl+1]
	bt	eax,11
	jc	SkipCD_init

	cmp	DoorStatus,1
	jz	SkipCD_init
	call	MouseHourGlass
	call	CD_init
	mov	byte ptr [CD_info],1
	mov	byte ptr [CD_info+1],1
	mov	word ptr [CD_info+2],0
	mov	byte ptr [CD_info+4],0
	call	MouseArrow
SkipCD_init:

	cmp	DoorStatus,1
	jz	CheckIfClosed
	call	clearCDblock
	mov	byte ptr [IOctl],6
	call	GetIOCtl
	mov	eax,dword ptr [IOctl+1]
	bt	eax,0
	jnc	_retp
	call	ClearCDdigits
	mov	PlayStatus,0
	mov	DoorStatus,1
	jmp	_retp

CheckIfClosed:
	call	clearCDblock
	mov	byte ptr [IOctl],6
	call	GetIOCtl
	lea	ebx,CD_IOCtlBlk
	mov	eax,dword ptr [IOctl+1]
	bt	eax,0
	jc	_retp


	mov	DoorStatus,0
	mov	PlayStatus,0
	jmp	_retp

SetIOCtl:				;------------ Set IOCtl
	cmp	EnableCD,0
	jz	_ret
	pushad
;	*************************
;	lea	ebx,CD_IOCtlBlk
;	mov	byte ptr [ebx],10h
;	mov	byte ptr [ebx+2],0Ch
;	lea	edx,IOCtl
;	add	edx,_code32a
;	mov	eax,edx
;	shr	edx,4
;	and	ax,0fh
;	mov	word ptr [ebx+0eh],ax
;	mov	word ptr [ebx+10h],dx
;	mov	byte ptr [ebx+12h],10
;
;	add	ebx,_code32a
;	mov	eax,ebx
;	shr	ebx,4
;	and	ax,0fh
;	mov	v86r_bx,ax
;	mov	v86r_es,bx
;	mov	v86r_ax,1510h
;	movzx	cx,CD_DrvNo
;	mov	v86r_cx,cx
;	mov	al,2fh
;	int	33h
;	*************************
;---------------------------------
	pushad
	lea	eax,CD_IOCtlBlk
	lea	ebx,IOCtl
	mov	ecx,20h
	mov	edx,20h
	call	CDPrepare

	mov	dx,RealSecondSeg
	mov	ax,RealSecondOffset
	lea	ebx,CD_IOCtlBlk
	mov	byte ptr [ebx],10h
	mov	byte ptr [ebx+2],0Ch
	mov	word ptr [ebx+0eh],ax
	mov	word ptr [ebx+10h],dx
	mov	byte ptr [ebx+12h],10
	call	CDRealMove

	xor	bx,bx
	movzx	cx,CD_DrvNo
	mov	ax,1510h
	call	CDInt
	popad
;---------------------------------

	jmp	_retp
GetIOCtl:				;------------ Get IOCtl
	cmp	EnableCD,0
	jz	_ret
	pushad
;---------------------------------
	pushad
	lea	eax,CD_IOCtlBlk
	lea	ebx,IOCtl
	mov	ecx,20h
	mov	edx,20h
	call	CDPrepare

	mov	dx,RealSecondSeg
	mov	ax,RealSecondOffset
	lea	ebx,CD_IOCtlBlk
	mov	byte ptr [ebx],10h
	mov	byte ptr [ebx+2],03h


	;movzx	ecx,RealSecondOffset
	;add	ecx,ProtectedOffset
	;mov	dword ptr [ebx+0eh],ecx
	mov	word ptr [ebx+0eh],ax
	mov	word ptr [ebx+10h],dx


	mov	byte ptr [ebx+12h],10
	call	CDRealMove

	xor	bx,bx
	movzx	cx,CD_DrvNo
	mov	ax,1510h
	call	CDInt
	popad
;---------------------------------

	jmp	_retp
ClearCDblock:				;------------ Clear CD Block
	cmp	EnableCD,0
	jz	_ret
	pushad
	lea	edi,CD_IOCtlBlk
	mov	ecx,20h+20h
	xor	ax,ax
	rep	stosb
	jmp	_retp
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
GetCDInfo:				;------------ Get CD info
	cmp	EnableCD,0
	jz	_ret
	pushad

	cmp	PlayStatus,0
	jz	_retp
	cmp	PlayStatus,2
	jz	_retp
	cmp	PlayStatus,3
	jz	_retp
	call	ClearCDblock

	;cmp	 TimeShow,0
	;jz	 ShowTime0a
	call	GetSectorPos              ;kkkkkkkkkkkk
	call	UpdateTimeFromSector
ShowTime0a:

	mov	dword ptr [CD_volumen+4],1
	mov	byte ptr [dragbarstatus+9],1
	mov	CD_on,1
	jmp	_retp
InfoError:
	mov	dword ptr [CD_volumen+4],1
	mov	byte ptr [dragbarstatus+9],0
	call	clearcdvol
	mov	CD_on,0
	jmp	_retp

GetSectorPos:				;------------- get sector pos
	cmp	EnableCD,0
	jz	_ret

	pushad
	call	clearCDblock
	mov	byte ptr [IOctl],1
	call	GetIOCtl
	mov	eax,dword ptr [IOctl+2]
	mov	SectorToPlay,eax
	jmp	_retp
ClearCDVol:				;clear cd vol
	pushad
	cmp	menu_popup,13
	jnz	_retp
	call	mouseoff
	planewrite 00001111b
	move	edi,0a0000h+128/8+209*80
	xor	eax,eax
	mov	ecx,8
loppen:
	stosd
	stosd
	add	edi,80-8
	loop	loppen

	planewrite 00000111b
	move	edi,0a0000h+128/8+209*80
	mov	eax,-1
	mov	ecx,8
loppen2:
	stosd
	stosd
	add	edi,80-8
	loop	loppen2
	call	mouseon
	_rp


CD_Init:				;------------ CD rom init
	cmp	EnableCD,0
	jz	_ret
	pushad
;Get CD-driver
;	*************************
;	mov	eax,3
;	call	clearCDblock
;	mov	v86r_ax,1500h
;	mov	v86r_bx,0
;	mov	v86r_cx,0
;	mov	al,2fh
;	int	33h
;	*************************
;---------------------------------
	mov	eax,3
	call	clearCDblock
	push	eax
	mov	ax,1500h
	mov	bx,0
	mov	cx,0
	int	2fh
	pop	eax

	or	bx,bx
	jz	End_CDoff
	mov	CD_DrvNo,cl
	add	cl,'A'
	mov	CD_DrvChar,cl
;---------------------------------

;Init the driver with function 9
;	*************************
;	lea	ebx,CD_IOCtlBlk
;	mov	byte ptr [ebx],10h
;	mov	byte ptr [ebx+2],03h
;	lea	edx,IOCtl
;	add	edx,_code32a
;	mov	eax,edx
;	shr	edx,4
;	and	ax,0fh
;	mov	word ptr [ebx+0eh],ax
;	mov	word ptr [ebx+10h],dx
;	mov	byte ptr [ebx+12h],6
;	mov	byte ptr [IOctl],9
;
;	add	ebx,_code32a
;	mov	eax,ebx
;	shr	ebx,4
;	and	ax,0fh
;	mov	v86r_bx,ax
;	mov	v86r_es,bx
;	mov	v86r_ax,1510h
;	movzx	cx,CD_DrvNo
;	mov	v86r_cx,cx
;	mov	al,2fh
;	int	33h
;	*************************
;---------------------------------
	pushad
	lea	eax,CD_IOCtlBlk
	lea	ebx,IOCtl
	mov	ecx,20h
	mov	edx,20h
	call	CDPrepare

	mov	dx,RealSecondSeg
	mov	ax,RealSecondOffset
	lea	ebx,CD_IOCtlBlk
	mov	byte ptr [ebx],10h
	mov	byte ptr [ebx+2],03h
	mov	word ptr [ebx+0eh],ax
	mov	word ptr [ebx+10h],dx
	mov	byte ptr [ebx+12h],6
	mov	byte ptr [IOctl],9
	call	CDRealMove

	xor	bx,bx
	movzx	cx,CD_DrvNo
	mov	ax,1510h
	call	CDInt
	popad
;---------------------------------

;Get low track, High track + end address (RED)
;	*************************
;	lea	ebx,CD_IOCtlBlk
;	mov	byte ptr [ebx],10h
;	mov	byte ptr [ebx+2],03h
;	lea	edx,IOCtl
;	add	edx,_code32a
;	mov	eax,edx
;	shr	edx,4
;	and	ax,0fh
;	mov	word ptr [ebx+0eh],ax
;	mov	word ptr [ebx+10h],dx
;	mov	byte ptr [ebx+12h],6
;	mov	byte ptr [IOctl],10
;
;	add	ebx,_code32a
;	mov	eax,ebx
;	shr	ebx,4
;	and	ax,0fh
;	mov	v86r_bx,ax
;	mov	v86r_es,bx
;	mov	v86r_ax,1510h
;	movzx	cx,CD_DrvNo
;	mov	v86r_cx,cx
;	mov	al,2fh
;	int	33h
;	*************************
;---------------------------------
	pushad
	lea	eax,CD_IOCtlBlk
	lea	ebx,IOCtl
	mov	ecx,20h
	mov	edx,20h
	call	CDPrepare

	mov	dx,RealSecondSeg
	mov	ax,RealSecondOffset
	lea	ebx,CD_IOCtlBlk
	mov	byte ptr [ebx],10h
	mov	byte ptr [ebx+2],03h
	mov	word ptr [ebx+0eh],ax
	mov	word ptr [ebx+10h],dx
	mov	byte ptr [ebx+12h],6
	mov	byte ptr [IOctl],10
	call	CDRealMove

	xor	bx,bx
	movzx	cx,CD_DrvNo
	mov	ax,1510h
	call	CDInt
	popad
;---------------------------------


	lea	ebx,CD_IOCtlBlk
	test	byte ptr [ebx+4],80h
	jnz	End_CDoff

	lea	edi,CD_LoTrk
	lea	esi,IOCtl
	inc	esi
	mov	ecx,3
	rep	movsw

;Get Track info
;	*************************
;	mov	dl,CD_LoTrk
;	lea	ecx,CD_IOCtlBlk
;	mov	ebx,ecx
;	add	ecx,_code32a
;	mov	eax,ecx
;	shr	ecx,4
;	and	ax,0fh
;	mov	v86r_bx,ax
;	mov	v86r_es,cx
;	mov	byte ptr [IOCtl],11
;	lea	edi,CD_RedPos
;NextTrack:
;	mov	v86r_ax,1510h
;	movzx	cx,CD_DrvNo
;	mov	v86r_cx,cx
;	mov	[IOCtl+1],dl
;	mov	al,2fh
;	int	33h
;	*************************
;---------------------------------
	mov	dl,CD_LoTrk
	lea	ecx,CD_IOCtlBlk
	mov	ebx,ecx
	mov	byte ptr [IOCtl],11
	lea	edi,CD_RedPos
NextTrack:

	pushad
	pushad
	lea	eax,CD_IOCtlBlk
	lea	ebx,IOCtl
	mov	ecx,20h
	mov	edx,20h
	call	CDPrepare
	popad

	;mov	 cx,RealSecondSeg
	;mov	 ax,RealSecondOffset
	;lea	 ebx,CD_IOCtlBlk
	;mov	 word ptr [ebx+0eh],ax
	;mov	 word ptr [ebx+10h],cx
	mov	[IOCtl+1],dl
	call	CDRealMove

	xor	bx,bx
	movzx	cx,CD_DrvNo
	mov	ax,1510h
	call	CDInt
	popad
;---------------------------------


	lea	ebx,CD_IOCtlBlk
	test	byte ptr [ebx+4],80h
	jnz	End_CDoff

	lea	esi,IOCtl
	add	esi,2
	movsd

	inc	dl
	cmp	dl,CD_HiTrk
	jbe	NextTrack

;RED to HSG
	lea	esi,CD_EndAddrR
	lea	edi,CD_EndAddrH
	movzx	ecx,CD_HiTrk
	movzx	ebx,CD_LoTrk
	sub	ecx,ebx
	add	ecx,2
Red2HSG:
	movzx	eax,word ptr [esi+2]
	mov	ebx,4500
	mul	ebx
	mov	ebp,eax
	movzx	eax,byte ptr [esi+1]
	mov	ebx,75
	mul	ebx
	add	eax,ebp
	movzx	ebx,byte ptr [esi]
	add	eax,ebx
	sub	eax,150
	mov	[edi],eax
	add	esi,4
	add	edi,4
	loop	Red2HSG
				;move endpos to end pos
	movzx	eax,CD_HITrk
	movzx	ebx,CD_LOTrk
	sub	eax,ebx
	add	eax,2
	mov	ebx,[CD_EndAddrH]
	mov	[eax*4+CD_EndAddrH],ebx

	call	stop_cd
	mov	PlayStatus,0
	mov	eax,[CD_HSGpos]
	mov	SectorToPlay,eax
	mov	SectorPosSave,eax
	mov	byte ptr [CD_info],1
	mov	byte ptr [CD_info+1],1
	mov	word ptr [CD_info+2],0
	mov	byte ptr [CD_info+4],0
	call	ChangeCDvolume
End_CDon:
	mov	dword ptr [CD_volumen+4],1
	mov	byte ptr [dragbarstatus+9],1
	mov	CD_on,1
	clc
	jmp	_retp
End_CDoff:
	mov	dword ptr [CD_volumen+4],1
	mov	byte ptr [dragbarstatus+9],0
	call	clearcdvol
	mov	CD_on,0
	stc
	jmp	_retp

Play_CD:				;Play_CD --------------------
	cmp	EnableCD,0
	jz	_ret			;Calls:
					;bx=3dtrack number
	pushad
	call	MouseHourGlass
	mov	ebx,SectorToPlay
	call	Play_CD_Sector
	call	MouseArrow
	jmp	_retp

	call	clearCDblock

;	*************************
;	and	ebx,0ffffh
;	shl	ebx,2
;	add	ebx,offset CD_EndAddrH
;	mov	eax,dword ptr [CD_EndAddrH]
;	sub	eax,dword ptr [ebx]
;	mov	dword ptr [CD_IOCtlBlk+12h],eax
;	mov	eax,dword ptr [ebx]
;	mov	dword ptr [CD_IOCtlBlk+0eh],eax
;	mov	byte ptr [CD_IOCtlBlk],16h
;	mov	byte ptr [CD_IOCtlBlk+2],84h
;	mov	v86r_ax,1510h
;	movzx	cx,byte ptr [CD_DrvNo]
;	mov	v86r_cx,cx
;	lea	ebx,CD_IOCtlBlk
;	add	ebx,_code32a
;	mov	eax,ebx
;	shr	ebx,4
;	and	ax,0fh
;	mov	v86r_bx,ax
;	mov	v86r_es,bx
;	mov	al,2fh
;	int	33h
;	*************************
;---------------------------------
	pushad
	pushad
	lea	eax,CD_IOCtlBlk
	lea	ebx,IOCtl
	mov	ecx,20h
	mov	edx,0
	call	CDPrepare
	popad

	and	ebx,0ffffh
	shl	ebx,2
	add	ebx,offset CD_EndAddrH
	mov	eax,dword ptr [CD_EndAddrH]
	sub	eax,dword ptr [ebx]
	mov	dword ptr [CD_IOCtlBlk+12h],eax
	mov	eax,dword ptr [ebx]
	mov	dword ptr [CD_IOCtlBlk+0eh],eax
	mov	byte ptr [CD_IOCtlBlk],16h
	mov	byte ptr [CD_IOCtlBlk+2],84h
	call	CDRealMove

	xor	bx,bx
	movzx	cx,CD_DrvNo
	mov	ax,1510h
	call	CDInt
	popad
;---------------------------------

	lea	ebx,CD_IOCtlBlk
	test	byte ptr [ebx+4],80h
	jnz	PlayErrorEnd
	mov	PlayStatus,1
	jmp	_retp
PlayErrorEnd:
	jmp	_retp
Play_CD_Sector: 			;Play_CD_Sector -------------
	cmp	EnableCD,0
	jz	_ret				;Calls:
					;ebx=sector offset
	pushad
	call	clearCDblock

;	*************************
;	mov	eax,dword ptr [CD_EndAddrH]
;	sub	eax,ebx
;	mov	dword ptr [CD_IOCtlBlk+12h],eax
;	mov	dword ptr [CD_IOCtlBlk+0eh],ebx
;	mov	byte ptr [CD_IOCtlBlk],16h
;	mov	byte ptr [CD_IOCtlBlk+2],84h
;
;	mov	v86r_ax,1510h
;	movzx	cx,byte ptr [CD_DrvNo]
;	mov	v86r_cx,cx
;	lea	ebx,CD_IOCtlBlk
;	add	ebx,_code32a
;	mov	eax,ebx
;	shr	ebx,4
;	and	ax,0fh
;	mov	v86r_bx,ax
;	mov	v86r_es,bx
;	mov	al,2fh
;	int	33h
;	*************************
;---------------------------------
	pushad
	pushad
	lea	eax,CD_IOCtlBlk
	lea	ebx,IOCtl
	mov	ecx,20h
	mov	edx,0
	call	CDPrepare
	popad

	mov	eax,dword ptr [CD_EndAddrH]
	sub	eax,ebx
	mov	dword ptr [CD_IOCtlBlk+12h],eax
	mov	dword ptr [CD_IOCtlBlk+0eh],ebx
	mov	byte ptr [CD_IOCtlBlk],16h
	mov	byte ptr [CD_IOCtlBlk+2],84h
	call	CDRealMove

	xor	bx,bx
	movzx	cx,CD_DrvNo
	mov	ax,1510h
	call	CDInt
	popad
;---------------------------------


	lea	ebx,CD_IOCtlBlk
	test	byte ptr [ebx+4],80h
	jnz	_retp
	mov	PlayStatus,1
	jmp	_retp

Stop_CD:				;Stop_CD --------------------
	cmp	EnableCD,0
	jz	_ret
	pushad
	call	ClearCDBlock
;	*************************
;	mov	v86r_ax,1510h
;	movzx	cx,byte ptr CD_DrvNo
;	mov	v86r_cx,cx
;
;	lea	ebx,CD_IOCtlBlk
;	mov	byte ptr [ebx],10h
;	mov	byte ptr [ebx+2],85h
;	add	ebx,_code32a
;	mov	eax,ebx
;	shr	ebx,4
;	and	ax,0fh
;	mov	v86r_bx,ax
;	mov	v86r_es,bx
;	mov	al,2fh
;	int	33h
;	*************************
;---------------------------------
	pushad
	lea	eax,CD_IOCtlBlk
	lea	ebx,IOCtl
	mov	ecx,20h
	mov	edx,0
	call	CDPrepare

	lea	ebx,CD_IOCtlBlk
	mov	byte ptr [ebx],10h
	mov	byte ptr [ebx+2],85h
	call	CDRealMove

	xor	bx,bx
	movzx	cx,CD_DrvNo
	mov	ax,1510h
	call	CDInt
	popad
;---------------------------------


	mov	PlayStatus,2
	jmp	_retp

CD_play2:
	cmp	EnableCD,0
	jz	_ret
	pushad
	jmp	CD_play2_
CD_play:				;CD_play ---------------------
	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	CD_on,0
	jz	_retp
	cmp	DoorStatus,1
	jz	_retp
	call	fixbutton
CD_play2_:
	cmp	PlayStatus,1
	jz	_retp
	cmp	PlayStatus,0
	jz	PlayFromStop
	jmp	GetOffPause
PlayFromStop:
	call	MouseHourGlass
	movzx	bx,byte ptr [CD_info]
	call	Play_CD
	call	MouseArrow
	jmp	_retp
CD_pause2:
	pushad
	jmp	NoFixas2
CD_pause:				;CD_pause --------------------
	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	CD_on,0
	jz	_retp
	cmp	DoorStatus,1
	jz	_retp
	call	fixbutton
NoFixas2:
	cmp	PlayStatus,0
	jz	_retp
	cmp	PlayStatus,2
	jz	GetOffPause
	call	MouseHourGlass
	call	Stop_CD
	call	GetSectorPos
	call	MouseArrow
	jmp	_retp
GetOffPause:
	call	MouseHourGlass
	call	Stop_cd
	mov	ebx,SectorToPlay
	call	Play_CD_Sector
	call	MouseArrow
	mov	PlayStatus,1
	jmp	_retp

CD_Stop2:
	cmp	EnableCD,0
	jz	_ret
	pushad
	jmp	NoFixas1
CD_stop:				;CD_stop ---------------------
	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	CD_on,0
	jz	_retp
	cmp	DoorStatus,1
	jz	_retp
	call	fixbutton
NoFixas1:
	call	MouseHourGlass
	call	stop_cd
	movzx	ebx,byte ptr [CD_info]
	dec	ebx
	mov	eax,dword ptr [ebx*4+CD_HSGpos]
	mov	SectorToPlay,eax
	call	MouseArrow
	mov	PlayStatus,0
	mov	byte ptr [CD_info+1],1
	mov	word ptr [CD_info+2],0
	mov	byte ptr [CD_info+4],0
	jmp	_retp
CD_skipback:				;CD_skipback -----------------
	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	CD_on,0
	jz	_retp
	cmp	DoorStatus,1
	jz	_retp
	call	fixbutton

	cmp	PlayStatus,1
	jnz	SkipStopppas
	call	MouseHourGlass
	call	Stop_CD
	mov	PlayStatus,3
	call	MouseArrow
SkipStopppas:
	cmp	byte ptr [CD_info],1
	jz	_retp

	cmp	PlayStatus,3
	jnz	NoDirekt
	mov	ax,MasterFrequency
	mov	SectorTimeChange,ax
NoDirekt:
	dec	byte ptr [CD_info]
	movzx	ebx,byte ptr [CD_info]
	mov	eax,dword ptr [CD_endAddrH+ebx*4]
	mov	SectorToPlay,eax
	cmp	PlayStatus,2
	jnz	noChangeStatus1
	mov	PlayStatus,0
NoChangeStatus1:
	mov	byte ptr [CD_info+1],1
	mov	word ptr [CD_info+2],0
	mov	byte ptr [CD_info+4],0
	jmp	_retp
CD_skipfwd:				;CD_skipfwd ------------------
	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	CD_on,0
	jz	_retp
	cmp	DoorStatus,1
	jz	_retp
	call	fixbutton

	cmp	PlayStatus,1
	jnz	SkipStop2
	call	MouseHourGlass
	call	Stop_CD
	mov	PlayStatus,3
	call	MouseArrow
SkipStop2:
	mov	al,CD_HiTrk
	cmp	byte ptr [CD_info],al
	jz	_retp

	cmp	PlayStatus,3
	jnz	NoDirekt2
	mov	ax,MasterFrequency
	mov	SectorTimeChange,ax
NoDirekt2:
	inc	byte ptr [CD_info]
	movzx	ebx,byte ptr [CD_info]
	mov	eax,dword ptr [CD_endAddrH+ebx*4]
	mov	SectorToPlay,eax
	cmp	PlayStatus,2
	jnz	noChangeStatus2
	mov	PlayStatus,0
NoChangeStatus2:
	mov	byte ptr [CD_info+1],1
	mov	word ptr [CD_info+2],0
	mov	byte ptr [CD_info+4],0
	jmp	_retp
CD_OpenClose:				;CD_openclose ----------------
	cmp	EnableCD,0
	jz	_ret
	pushad
	call	fixbutton
	cmp	DoorStatus,1
	jz	CLosedoor
	call	MouseHourGlass
	mov	PlayStatus,0
	call	clearCDblock
	mov	byte ptr [IOctl],0
	call	SetIOCtl
	call	MouseArrow
	jmp	_retp
CloseDoor:
	call	MouseHourGlass
	call	clearCDblock
	mov	byte ptr [IOctl],5
	call	SetIOCtl
	call	MouseArrow
	jmp	_retp
SaveCDpos:					;--------------- Save CD pos
	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	CD_on,0
	jz	_retp
	cmp	DoorStatus,1
	jz	_retp
	call	fixbutton
	cmp	PlayStatus,1
	jnz	NoGetCords
	call	GetSectorPos
NoGetCords:
	mov	eax,SectorToPlay
	mov	SectorPosSave,eax
	lea	edi,SectorInfoSave
	lea	esi,CD_Info
	mov	ecx,5
	rep	movsb
	jmp	_retp
JumpCDpos:					;--------------- Jump CD pos
	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	CD_on,0
	jz	_retp
	cmp	DoorStatus,1
	jz	_retp
	call	fixbutton
	mov	eax,SectorPosSave
	mov	SectorToPlay,eax
	lea	edi,CD_Info
	lea	esi,SectorInfoSave
	mov	ecx,5
	rep	movsb
	cmp	PlayStatus,1
	jnz	_retp

	call	MouseHourGlass
	call	Stop_cd
	mov	ebx,SectorToPlay
	call	Play_CD_Sector
	call	MouseArrow

	jmp	_retp
CD_rewback:				;CD_rewback ------------------
	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	CD_on,0
	jz	_retp
	cmp	DoorStatus,1
	jz	_retp
	call	fixbutton

	cmp	PlayStatus,1
	jnz	SkipStop_
	call	MouseHourGlass
	call	Stop_CD
	mov	PlayStatus,3
	call	GetSectorPos
	call	MouseArrow
SkipStop_:

	cmp	PlayStatus,3
	jnz	NoDirekt__
	mov	ax,MasterFrequency
	mov	SectorTimeChange,ax
NoDirekt__:
	sub	SectorToPlay,75
	mov	eax,dword ptr [CD_HSGpos]
	cmp	SectorToPlay,eax
	jge	NotResetSector
	mov	eax,dword ptr [CD_EndAddrh]
	mov	SectorToPlay,eax
NotResetSector:
	call	UpdateTimeFromSector
	jmp	_retp
CD_rewfwd:				;CD_rewfwd -------------------
	cmp	EnableCD,0
	jz	_ret
	pushad
	cmp	CD_on,0
	jz	_retp
	cmp	DoorStatus,1
	jz	_retp
	call	fixbutton

	cmp	PlayStatus,1
	jnz	SkipStop_2
	call	MouseHourGlass
	call	Stop_CD
	mov	PlayStatus,3
	call	GetSectorPos
	call	MouseArrow
SkipStop_2:

	cmp	PlayStatus,3
	jnz	NoDirekt__2
	mov	ax,MasterFrequency
	mov	SectorTimeChange,ax
NoDirekt__2:
	add	SectorToPlay,75
	mov	eax,dword ptr [CD_EndAddrh]
	cmp	SectorToPlay,eax
	jbe	NotResetSector2
	mov	eax,dword ptr [CD_EndAddrh+4]
	mov	SectorToPlay,eax
NotResetSector2:
	call	UpdateTimeFromSector
	_rp


CheckMedia:				;--------------- Check Media
	cmp	EnableCD,0
	jz	_ret
	pushad
;	*************************
;	lea	ebx,CD_IOCtlBlk
;	mov	byte ptr [ebx],10h
;	mov	byte ptr [ebx+2],03h
;	lea	edx,IOCtl
;	add	edx,_code32a
;	mov	eax,edx
;	shr	edx,4
;	and	ax,0fh
;	mov	word ptr [ebx+0eh],ax
;	mov	word ptr [ebx+10h],dx
;	mov	byte ptr [ebx+12h],6
;	mov	byte ptr [IOctl],9
;
;	add	ebx,_code32a
;	mov	eax,ebx
;	shr	ebx,4
;	and	ax,0fh
;	mov	v86r_bx,ax
;	mov	v86r_es,bx
;	mov	v86r_ax,1510h
;	movzx	cx,CD_DrvNo
;	mov	v86r_cx,cx
;	mov	al,2fh
;	int	33h
;	*************************
;---------------------------------
	pushad
	lea	eax,CD_IOCtlBlk
	lea	ebx,IOCtl
	mov	ecx,20h
	mov	edx,20h
	call	CDPrepare

	mov	dx,RealSecondSeg
	mov	ax,RealSecondOffset
	lea	ebx,CD_IOCtlBlk
	mov	byte ptr [ebx],10h
	mov	byte ptr [ebx+2],03h
	mov	word ptr [ebx+0eh],ax
	mov	word ptr [ebx+10h],dx
	mov	byte ptr [ebx+12h],6
	mov	byte ptr [IOctl],9
	call	CDRealMove

	xor	bx,bx
	movzx	cx,CD_DrvNo
	mov	ax,1510h
	call	CDInt
	popad
;---------------------------------
	cmp	byte ptr [IOctl+1],0ffh
	jnz	_retp
	call	MouseHourGlass
	call	CD_init
	mov	byte ptr [CD_info],1
	mov	byte ptr [CD_info+1],1
	mov	word ptr [CD_info+2],0
	mov	byte ptr [CD_info+4],0
	call	MouseArrow
	jmp	_retp
ChangeCDTime:				  ;---------- Change CD time
	pushad
	cmp	CD_on,0
	jz	_retp
	cmp	DoorStatus,1
	jz	_retp
	xor	TimeShow,1
	mov	dword ptr [CD_infoOLD],-1
	mov	byte ptr [CD_infoOLD+4],-1
	mov	CD_VolumeOLD,-1
	call	UpdateTimeFromSector
	_rp

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Start The Sample  (big popup)
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
StartTheSample	Proc	Near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	sampletheend
Start2:
	call	CheckIfShadow
	jc	_retp

	cmp	Allow_Sample,1
	jz	SampleIsAllowed
	lea	esi,SampleNotAllowed
	mov	Menu_Popup,16
	call	PopUpHandler
	jmp	sampletheend
SampleIsAllowed:


	mov	ax,1			;view note, rate
	mov	bx,0
	xor	al,SampleNoteOrRate
	xor	bl,SampleNoteOrRate
	xor	bl,1
	xor	al,1
	mov	word ptr [SmpNote+10],ax
	mov	word ptr [SmpRate+10],bx

	movzx	ax,byte ptr setmic
	xor	al,1
	mov	word ptr [SmpMic+10],ax

	movzx	ax,byte ptr setlinein

	xor	al,1
	mov	word ptr [SmpLine+10],ax

	movzx	ax,byte ptr SetCD
	xor	al,1
	mov	word ptr [SmpCD+10],ax

	movzx	ax,byte ptr setequalizer
	xor	al,1
	mov	word ptr [SmpEqu+10],ax
	movzx	ax,byte ptr setscopes
	xor	al,1
	mov	word ptr [SmpScop+10],ax

	;call	 unpackmasktext 	 ;view picture
	mov	menu_popup,13
	call	menuhandler

	mov	OldLeftEqualizer,-1
	mov	OldRightEqualizer,-1
	call	SetMonoAndBits		;Set buttons

	call	SetMicAndLine		;Set SoundCard Info
	call	InitSampling		;Init The Hardware
	call	SetFrequenzy		;Set Samp Freq

	mov	dword ptr CD_InfoOLD,-1
	mov	byte ptr [CD_InfoOLD+4],-1
	mov	CD_VolumeOLD,-1

	call	CheckMedia

	cmp	SampleNoteOrRate,0
	jz	PrintaNote
	call	PrintSampleRate
	jmp	AfterNota
PrintaNote:
	call	PrintSampleNote
AfterNota:

	mov	PeakMax,-1		;peak
	call	mouseoff
	mov	fontplane,1
	move	edi,0a0000h+304/8+158*80
	mov	ebx,'.'
	mov	ah,00000001b
	call	putcharacter
	move	edi,0a0000h+336/8+158*80
	mov	ebx,'%'
	mov	ah,00000001b
	call	putcharacter
	mov	fontplane,0
	call	mouseon

	call	MemReorganize


	mov	dword ptr [LeftInput+4],1
	mov	dword ptr [RightInput+4],1

sampletheend:
	popad
	ret
StartTheSample2:
	pushad
	jmp	start2
StartTheSample	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			 The Sample End (Big popup)
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
TheSampleEnd2:
	pushad
	jmp	jumpsamp
TheSampleEnd	proc	near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	sampletheend2

JumpSamp:
	cmp	EndSampleMode,0
	jz	SkipStoppas
	cmp	EndSampleMode,2
	jz	DoPause
	call	CD_Stop2
	jmp	SkipStoppas
DoPause:
	cmp	PlayStatus,2
	jz	SkipStoppas
	call	CD_Pause2
SkipStoppas:
	mov	menu_popup,0
	call	menuhandler

	call	DeInitSampling		;DeInit the Hardware

	call	PrintSampleInfo
	mov	oldcurrentinstname,-1

sampletheend2:
	popad
	ret
TheSampleEnd	endp

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;		       Start to samp... (small popup)
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampleON	db	0
StartToSamp	Proc	Near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	StartToSampEnd
StartaNow:

	movzx	eax,SampleBits
	mov	SampBits,eax

	mov	undosamplength,0
	mov	extraundolength,0
	mov	bx,0
	call	allocundolength

	mov	ClipBoardLength,0
	call	alloccliplength

	mov	eax,MemoryFree
	sub	eax,500+60000		;*** NOTE: CHECK THIS VALUE DAVID!!***
	jle	notenoughhimem

	mov	cl,Sample8or16bits


	shr	eax,cl
	mov	cl,SampleStereo
	shr	eax,cl



	cmp	SampleStereo,0
	jz	noclipboardalloc
	push	eax
	movzx	eax,SampleBits
	mov	ClipBoardBits,eax
	pop	eax
	mov	ClipBoardLength,eax
	call	alloccliplength
noclipboardalloc:

	mov	SampLength,eax
	call	AllocSampLength

	mov	SampLength,0
	mov	ClipBoardLength,0

	call	StartSampling		;Start The Hardware
	mov	ChooseMake,0
	mov	SampleOn,1
	;mov	 smallpopupmove,80*20
	;call	 savesmallpopup
	;mov	 smallpopupmove,0
	mov	SecondPopup,14
	call	MenuHandler
	mov	DrawPointer,0

starttosampend:
	popad
	ret
starttosamp2:
	pushad
	jmp	startanow
StartToSamp	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;		     End Start to samp... (Small Popup)
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
EndStartToSamp	proc	near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	endstarttosampend
EndStartStart:
	cmp	StartSample,1
	jz	EndStartToSampEnd
;	cmp	Sampling,2
;	jnz	EndStartToSampEnd
;	cmp	SampLength,10
;	jb	EndStartToSampEnd

	mov	Sampleon,0

	cmp	DoZeroStart,0
	jz	NotDoZero
	call	ClearZeroStart
NotDoZero:
	mov	DoZeroStart,0

	mov	SecondPopup,-1
	mov	menu_popup,13
	call	menuhandler

	call	StopSampling		;Stop The Hardware

	movzx	ebp,currentsample
	shl	ebp,2
	mov	eax,[ebp+sampleoffsetstart]
	mov	[ebp+loopstart],eax
	mov	[ebp+loopend],eax
	mov	PlayPegOff,0
	mov	FormSelect,0
	movzx	ebp,currentsample
	mov	al,byte ptr [VoiceControl+ebp]
	btr	ax,3
	btr	ax,4
	btr	ax,6
	mov	byte ptr [VoiceControl+ebp],al
	call	movethepegs

	mov	extrasamplength,0
	mov	ebx,0
	call	allocsamplength

	;call	 viewall2
	mov	eax,samplength
	mov	viewsamplength,eax
	mov	viewsampoffset,0
	call	viewsamp

	movzx	ebx,CurrentSample
	movzx	eax,GUSSampleFreq
	mov	CurrentSampRate,eax
	call	InsSampleRate

	lea	edi,oldputs
	mov	eax,-1
	mov	ecx,20
	rep	stosd

endstarttosampend:
	popad
	ret
endstarttosamp2:
	pushad
	jmp	endstartstart
EndStartToSamp	endp




;Called at Big Popup On
HaveSampled	db	0
InitSampling	Proc	Near
	pushad
	mov	TuneStopped,1		;Stop Tune
	call	ClearForPlay
	mov	RecMode,0
	mov	EditMode,0
	call	BackCol
	mov	PrintBlock,0
	mov	PatternPlay,0
	mov	OldInfoTextPtr,-1
	lea	edi,MIDIPriority
	mov	ecx,32
	mov	al,0
	rep	stosw
	call	StopAllVoices
	mov	HaveSampled,0
	mov	Sampling,1
	mov	StartSample,0
	mov	StopSample,0


	mov	edi,DMABuffer			;Clear DMA Buffer
	mov	ecx,GUS_RollOverDataSize
	xor	al,al
	rep	stosb


	call	StartADC
	popad
	ret
InitSampling	EndP

;Called at Big Popup off
DeInitSampling	Proc	Near
	pushad

	mov	Sampling,3
	cmp	HaveSampled,0
	jz	HaventSampled

	call	MouseHourGlass
	mov	ecx,35
@@WaitOpel:
	call	sync
	cmp	Sampling,0
	loopnz	@@WaitOpel

	call	UpdateSampleToGUS
	call	MouseArrow
	movzx	ebx,CurrentSample
	mov	[SampleRates+ebx*2],8363
	cmp	ResampleMode,1
	jnz	Reasmple1
	mov	ax,GUSSampleFreq
	mov	[Samplerates+ebx*2],ax
Reasmple1:
	mov	eax,[SampleOffsetStart+ebx*4]
	mov	[LoopStart+ebx*4],eax
	mov	[LoopEnd+ebx*4],eax
	mov	[FineTunes+ebx],0
	mov	[Relativenote+ebx],0
	mov	[Volumes+ebx],07fh
	mov	al,SampleBits
	shl	al,2
	mov	[VoiceControl+ebx],al
HaventSampled:

	push	word ptr Sample8or16bits
	mov	Sample8or16bits,0
	call	SetMicAndLine

	pop	word ptr Sample8or16bits

	popad
	ret
DeInitSampling	EndP

;Called at Small Popup On
SampPtr1	dd	0
SampPtr2	dd	0
StartSampling	Proc	Near
	pushad
	mov	edi,DMABuffer			;Clear DMA Buffer
	mov	ecx,GUS_RollOverDataSize
	xor	al,al
	rep	stosb
	mov	eax,[AllocTable+1024*8]
	mov	SampPtr1,eax
	mov	eax,[AllocTable+1026*8]
	mov	SampPtr2,eax

	mov	StartSample,1
	mov	HaveSampled,1
	call	FixStartSample
	popad
	ret
StartSampling	EndP

;Called at Small Popup Off
StopSampling	Proc	Near
	pushad
	mov	StopSample,1
	call	MouseHourGlass
StopLoop:
	call	ADCSample
	cmp	StopSample,0
	jnz	StopLoop
	call	MouseArrow
	popad
	ret
StopSampling	EndP
;Global SampPtrTest:Dword

SampleConvert	db	0	;128 if to convert when sampling
StartSample	db	0	;Set to 1 to start sampling
StopSample	db	0	;Set to 1 to stop sampling
SampStartOffs	dd	0	;StartOffset
SampleCount	dw	0	;Where DMA is
Sampling	db	0	;0=No Samp,1=Scope,2=Sampling,3=Stop Sampling
Stereo		db	0	;1=Stereo
SamplingBuffOff dd	0	;0 or GUS_RollOverDataSize/2
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Sampling update
; Calls: None
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ADCSample	Proc	Near
	cmp	Sampling,0
	jz	_ret
	pushad
	pushf
	cli
	mov	StackSave,esp

	cmp	SoundCard,1
	jz	@@GUS
	cmp	SoundCard,5
	jz	@@GUS

	mov	ah,[SoundCard_DMA1]
	cmp	[SampleBits],0
	je	@@Use8BitDMA2
@@GUS:
	mov	ah,[SoundCard_DMA2]
@@Use8BitDMA2:
	call	DMA_GetCount
	mov	SampleCount,ax
;......
;	movzx   eax,ax
;	mov     dnumber,0
;	mov     dbyte,eax
;	call    dbug
;......
	pushad
	mov	esi,DMABuffer
	mov	ebp,SamplingBuffOff
	mov	ecx,GUS_RollOverDataSize
	shr	ecx,1
	mov	ax,SampleCount		;Access every 4:th byte only.
	and	ax,not 3
	sub	cx,ax
	add	ebp,ecx

	movzx	eax,Sample8or16bits	;Get low byte if 16 bits
	add	ebp,eax

	mov	eax,128
	mov	cl,SampleStereo
	shl	eax,cl
	mov	cl,Sample8or16Bits

	shl	eax,cl
	sub	ebp,eax
	mov	ecx,128
	jge	MoveToScope
	add	ebp,GUS_RollOverDataSize
MoveToScope:
	push	ecx
	movzx	eax,byte ptr [esi+ebp]

	xor	al,SampleConvert
	mov	LeftEqualizer,eax

	cmp	SampleStereo,1
	jnz	@@Mono

	cmp	Sample8or16bits,1
	jz	Do16bits

	movzx	eax,byte ptr [esi+ebp+1]
	jmp	After16bits
Do16Bits:
	movzx	eax,byte ptr [esi+ebp+2]
After16bits:
	xor	al,SampleConvert
	mov	RightEqualizer,eax
@@Mono:
	call	InsertScopes
	mov	eax,1				;MONO & 8bits

	mov	cl,Sample8or16Bits		;16 bits

	shl	eax,cl
	mov	cl,SampleStereo 		;Stereo
	shl	eax,cl
	add	ebp,eax
	cmp	ebp,GUS_RollOverDataSize
	jb	NoMTS
	sub	ebp,GUS_RollOverDataSize
NoMTS:
	pop	ecx
	loop	MoveToScope
	popad

	cmp	StopSample,1
	jz	SampleStopped
	cmp	StartSample,0
	jz	NoStartOfSamp
	mov	Sampling,2
	mov	eax,GUS_RollOverDataSize
	shr	eax,1
	sub	ax,SampleCount
	mov	SampStartOffs,eax
	mov	StartSample,0
	jmp	NoStartOfSamp
SampleStopped:
	cmp	SampleSize,0
	jz	ForceStop
	mov	eax,GUS_RollOverDataSize
	shr	eax,1
	sub	ax,SampleCount
	mov	SampleSize,eax
NoStartOfSamp:

	cmp	DMAPlay_TC,0
	jz	SkipSampling
	mov	DMAPlay_TC,0
	sti


	cmp	Sampling,1
	jz	NoTransfer
	call	ResampleSample
	jnc	NoTransfer
ForceStop:
	mov	Sampling,1		;Stop Sampling via UpdateDifferentStuff
	mov	StopSample,0
NoTransfer:
	mov	SampStartOffs,0
SkipSampling:
	popf
	popad
	ret
ADCSample	EndP

SampleFreq	dw	0	;rate=(9878400/(16*freq))-2
SampleRate	db	0	;GUS rate
GUSSampleFreq	dw	0	;The faulty freq

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls: None
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ResampleTable	dd	Resamp_8M,Resamp_8S,Resamp_16M,Resamp_16S
ResampleSample	Proc	Near
	pushad
	mov	ecx,GUS_RollOverDataSize
	shr	ecx,1
	mov	esi,SamplingBuffOff
	xor	esi,ecx
	add	esi,DMABuffer
	add	esi,SampStartOffs

	mov	al,Sample8or16bits

	shl	al,1
	add	al,SampleStereo
	and	eax,0fh
	call	[ResampleTable+eax*4]
	popad
	ret
ResampleSample	EndP


Resamp_8M	Proc	Near
	mov	edi,SampPtr1
	movzx	eax,GUSSampleFreq
	shl	eax,16
	movzx	ebx,SampleFreq
	xor	edx,edx
	div	ebx

	sub	eax,65536
	mov	ebp,eax
	xor	edx,edx
	xor	ebx,ebx

	mov	ecx,GUS_RollOverDataSize
	shr	ecx,1
	sub	ecx,SampStartOffs
@@MoveNextByte:
	mov	al,[esi+ebx]
	xor	al,SampleConvert
	stosb
	dec	SampleSize
	jle	_ret_stc

	cmp	ResampleMode,0
	jnz	@@Reasmple2
	add	dx,bp
	adc	ebx,0
@@Reasmple2:
	inc	ebx
	cmp	ebx,ecx
	jb	@@MoveNextByte

	add	SampLength,ecx
	mov	SampPtr1,edi
	clc
	ret
Resamp_8M	EndP

Resamp_8S	Proc	Near
	bt	esi,0			;Align 2
	adc	esi,0
	movzx	eax,GUSSampleFreq
	shl	eax,16
	movzx	ebx,SampleFreq
	xor	edx,edx
	div	ebx

	sub	eax,65536
	mov	ebp,eax
	xor	edx,edx
	xor	ebx,ebx

	mov	ecx,GUS_RollOverDataSize
	shr	ecx,1
	sub	ecx,SampStartOffs
@@MoveNextByte:
	mov	al,[esi+ebx]
	xor	al,SampleConvert
	mov	edi,SampPtr1
	mov	[edi],al

	mov	al,[esi+ebx+1]
	xor	al,SampleConvert
	mov	edi,SampPtr2
	mov	[edi],al

	dec	SampleSize
	jle	_ret_stc

	cmp	ResampleMode,0
	jnz	@@Reasmple2
	add	dx,bp
	adc	ebx,0
@@Reasmple2:
	inc	SampPtr1
	inc	SampPtr2
	add	ebx,2
	cmp	ebx,ecx
	jb	@@MoveNextByte

	shr	ecx,1
	add	ClipBoardLength,ecx
	add	SampLength,ecx
	clc
	ret
Resamp_8S	EndP

Resamp_16M:
	bt	esi,0			;Align 2
	adc	esi,0
	mov	edi,SampPtr1
	movzx	eax,GUSSampleFreq
	shl	eax,16
	movzx	ebx,SampleFreq
	xor	edx,edx
	div	ebx

	sub	eax,65536
	mov	ebp,eax
	xor	edx,edx
	xor	ebx,ebx

	mov	ecx,GUS_RollOverDataSize
	shr	ecx,1
	sub	ecx,SampStartOffs
	shr	ecx,1
@@MoveNextByte:
	mov	ax,[esi+ebx*2]
	xor	ah,SampleConvert
	stosw
	sub	SampleSize,2
	jle	_ret_stc

	cmp	ResampleMode,0
	jnz	@@Reasmple2
	add	dx,bp
	jnc	@@Reasmple2
	add	ebx,2
@@Reasmple2:
	inc	ebx
	cmp	ebx,ecx
	jb	@@MoveNextByte

	add	SampLength,ecx
	mov	SampPtr1,edi
	clc
	ret



Resamp_16S:
	and	esi,not 3		;Align 4
	movzx	eax,GUSSampleFreq
	shl	eax,16
	movzx	ebx,SampleFreq
	xor	edx,edx
	div	ebx

	sub	eax,65536
	mov	ebp,eax
	xor	edx,edx
	xor	ebx,ebx

	mov	ecx,GUS_RollOverDataSize
	shr	ecx,1
	sub	ecx,SampStartOffs
	shr	ecx,1
@@MoveNextByte:
	mov	ax,[esi+ebx*2]
	xor	ah,SampleConvert
	mov	edi,SampPtr1
	mov	[edi],ax

	mov	ax,[esi+ebx*2+2]
	xor	ah,SampleConvert
	mov	edi,SampPtr2
	mov	[edi],ax

	sub	SampleSize,2
	jle	_ret_stc

	cmp	ResampleMode,0
	jnz	@@Reasmple2
	add	dx,bp
	jnc	@@Reasmple2
	add	ebx,2
@@Reasmple2:
	add	SampPtr1,2
	add	SampPtr2,2
	add	ebx,2
	cmp	ebx,ecx
	jb	@@MoveNextByte

	shr	ecx,1
	add	ClipBoardLength,ecx
	add	SampLength,ecx
	clc
	ret

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Clear Raten
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ClearRaten	proc	near
	pushad
	planewrite 00000001b

	move	edi,0a0000h+304/8+124*80
	mov	ecx,12
	xor	eax,eax
LoopenMedMens1:
	stosd
	stosb
	add	edi,80-5
	loop	LoopenMedMens1

	popad
	ret
ClearRaten	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Set Note
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SetTheNote	Proc	Near
	pushad
	cmp	samplenoteorrate,0
	jz	skipnote
	mov	SampleNoteOrRate,0

	mov	eax,SampleRate2
	cmp	eax,Max_SampleRate
	jbe	nosura
	mov	eax,Max_SampleRate
	mov	SampleRate2,eax
nosura:
	call	GetNoteFromSampleFreq
	add	eax,2
	cmp	eax,Max_SampleNote
	jbe	noboken
	mov	eax,Max_SampleNote
noboken:
	mov	SampleNote,eax

	mov	buttonX1,243
	mov	buttonY1,112
	mov	buttonX2,297
	mov	buttonY2,128
	mov	bl,0
	call	buttonupdown
	mov	buttonX1,243
	mov	buttonY1,129
	mov	buttonX2,297
	mov	buttonY2,145
	mov	bl,1
	call	buttonupdown
	call	setfrequenzy
	call	ClearRaten
	call	printsamplenote
skipnote:
	popad
	ret
SetTheNote	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Set Rate
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SetTheRate	Proc	Near
	pushad
	cmp	samplenoteorrate,1
	jz	skiprate

	mov	eax,SampleNote
	sub	eax,2
	mov	ebx,12
	xor	edx,edx
	div	ebx
	mov	edx,[Pt_PeriodTable+edx*4]
	mov	ecx,eax
	shr	edx,cl
	mov	ebx,edx

	mov	eax,428*8363*16
	xor	edx,edx
	div	ebx
	cmp	eax,Max_SampleRate
	jbe	noproba
	mov	eax,Max_SampleRate
noproba:

	mov	SampleRate2,eax

	mov	SampleNoteOrRate,1
	mov	buttonX1,243
	mov	buttonY1,112
	mov	buttonX2,297
	mov	buttonY2,128
	mov	bl,1
	call	buttonupdown
	mov	buttonX1,243
	mov	buttonY1,129
	mov	buttonX2,297
	mov	buttonY2,145
	mov	bl,0
	call	buttonupdown
	call	setfrequenzy
	call	ClearRaten
	call	printsamplerate
skiprate:
	popad
	ret
SetTheRate	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			  Put  input volume
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PutINputVolume:
	pushad

	cmp	Allow_LineInSamp,0
	jnz	allowit
	mov	[DragBarStatus+10],0
	mov	[DragBarStatus+11],0
	popad
	ret
Allowit:


	cmp	SampleStereo,0
	jz	justMONO
	lea	esi,SampVolStereo
	mov	DrawSpecial,1
	call	DrawPopup
	mov	dword ptr [LeftInput+4],1
	mov	dword ptr [RightInput+4],1
	popad
	ret
justMONO:
	lea	esi,SampVolMONO
	mov	DrawSpecial,1
	call	DrawPopup
	mov	dword ptr [LeftInput+4],1
	mov	dword ptr [RightInput+4],1
	popad
	ret

NoMONOorStereo:
	lea	esi,SampVolClear
	mov	DrawSpecial,1
	call	DrawPopup
	mov	dword ptr [LeftInput+4],1
	mov	dword ptr [RightInput+4],1
	popad
	ret

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			      Set Diffrent stuff
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampleSetCD:
	cmp	EnableCD,0
	jz	_ret
	pushad
	xor	setCD,1
	mov	buttonX1,431
	mov	buttonY1,204
	mov	buttonX2,443
	mov	buttonY2,215
	mov	bl,setCD
	xor	bl,1
	call	buttonupdown
	call	setmicandline
	popad
	ret
SampleSetMic:
	pushad
	xor	setmic,1
	mov	buttonX1,431
	mov	buttonY1,191
	mov	buttonX2,443
	mov	buttonY2,202
	mov	bl,setmic
	xor	bl,1
	call	buttonupdown
	call	setmicandline
	popad
	ret
SampleSetLinein:
	pushad
	xor	setlinein,1
	mov	buttonX1,431
	mov	buttonY1,178
	mov	buttonX2,443
	mov	buttonY2,189
	mov	bl,setlinein
	xor	bl,1
	call	buttonupdown
	call	setmicandline
	popad
	ret
SampleSetEqualizer:
	pushad
	xor	setequalizer,1
	mov	buttonX1,431
	mov	buttonY1,129
	mov	buttonX2,443
	mov	buttonY2,140
	mov	bl,setequalizer
	xor	bl,1
	call	buttonupdown
	mov	oldleftequalizer,-1
	mov	oldrightequalizer,-1
	cmp	setequalizer,0
	jnz	noblacknack
	mov	leftequalizer,0
	mov	rightequalizer,0
	mov	equalizermaxleft,0
	mov	equalizermaxright,0
	jmp	afterdoit
afterdoit:
	;mov	 setequalizer,1
	call	putequalizers
	;mov	 setequalizer,0
noblacknack:

	popad
	ret
SampleSetScopes:
	pushad
	xor	setscopes,1
	mov	buttonX1,431
	mov	buttonY1,116
	mov	buttonX2,443
	mov	buttonY2,127
	mov	bl,setscopes
	xor	bl,1
	call	buttonupdown
	cmp	setscopes,0
	jnz	noborka
	mov	setscopes,1
	mov	clearbyte,1
	call	putscopes
	mov	setscopes,0
noborka:
	popad
	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Set Frequenzy
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SetFrequenzy	proc	near
	pushad
	mov	eax,samplerate2
	cmp	samplenoteorrate,1
	jz	dosamplerate

	mov	eax,SampleNote
	sub	eax,2
	mov	ebx,12
	xor	edx,edx
	div	ebx
	mov	edx,[Pt_PeriodTable+edx*4]
	mov	ecx,eax
	shr	edx,cl
	mov	ebx,edx

	mov	eax,428*8363*16
	xor	edx,edx
	div	ebx

dosamplerate:
	cmp	SampleFreq,ax
	jz	_retp

	mov	SampleFreq,ax
	call	ChangeSamplingFreq
	cmp	SoundCard,5		;GUS MAX
	jz	@@ReInit
	cmp	SoundCard,2
	jz	@@ReInit
	cmp	SoundCard,4
	jnz	_retp
@@ReInit:
	call	StartADC		;Must reinit sampling on SB/SBPro

	popad
	ret
SetFrequenzy	endp


UpdateInpVol:
	call	SetMicAndLine
	ret

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       Set Mic And Line
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SetMicAndLine	Proc	Near
	pushad
	mov	al,SetCd
	mov	cl,SetLinein
	mov	ch,SetMic
	mov	dl,SampleStereo

	mov	dh,Sample8or16bits

	mov	bh,byte ptr LeftInput
	mov	bl,byte ptr RightInput
	cmp	dl,1
	jz	@@St
	mov	bl,bh
@@St:
	call	MainMixer
	popad
	ret
SetMicAndLine	Endp
;***************************************************************
; ** Mixer **
; Calls:
;	DL:	0=MONO,1=Stereo
;	DH:	0=8bit, 1=16bit
;	CL:	1=LineIn
;	CH:	1=Mic In
;	BX:	Volume:Line:LLRR, MIC: 00MM
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Save small popup
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SaveSmallPopup	   Proc    Near
	call	sara4
	ret
	Pushad
	call	mouseoff
	mov	edi,pcxbuffer
	add	edi,32000
	mov	ecx,4
	mov	savebajsWW,0
savepicloop1__WW:
	push	ecx
	mov	dx,3ceh 		;Set bitplane (read)
	mov	ah,savebajsWW
	mov	al,4
	out	dx,ax


	mov	cl,savebajsWW
	mov	ah,1
	shl	ah,cl
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax

	move	esi,0a0000h
	add	esi,92*80
	add	esi,smallpopupmove
	mov	ecx,80*63
	rep	movsb

	inc	savebajsWW
	pop	ecx
	loop	savepicloop1__WW
	call	mouseon
	Popad
	Ret
SavesmallPopup	EndP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			    Restore small popup
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
savebajsWW	db	0
smallpopupmove	dd	0
RestoreSmallPopup	Proc	Near
	Pushad
	call	mouseoff
	mov	esi,pcxbuffer
	add	esi,32000
	mov	ecx,4
	mov	savebajsWW,0
savepicloop1___WW:
	push	ecx
	mov	dx,3ceh 		;Set bitplane (read)
	mov	ah,savebajsWW
	mov	al,4
	out	dx,ax

	mov	cl,savebajsWW
	mov	ah,1
	shl	ah,cl
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax

	move	edi,0a0000h
	add	edi,92*80
	add	edi,smallpopupmove
	mov	ecx,80*63
	rep	movsb

	inc	savebajsWW
	pop	ecx
	loop	savepicloop1___WW
	call	mouseon
	Popad
	Ret
RestoreSmallPopup	EndP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Print Rate
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
printsamplerate   proc	  near
	pushad
	move	edi,0a0000h+304/8+124*80
	mov	ah,1
	mov	cl,5
	mov	ebx,samplerate2
	mov	FontPlane,1
	call	PutDecimal
	mov	FontPlane,0
	popad
	ret
PrintSampleRate endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Print Note
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
printsamplenote   proc	near
	pushad
	mov	esi,samplenote
	move	edi,0a0000h+312/8+124*80
	mov	bitplane,00000001b
	mov	FontPlane,1
	call	printperiod
	mov	FontPlane,0
	popad
	ret
printsamplenote endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			     Sample Note Up
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampleNoteUp	proc	near
	pushad
	call	fixbutton
	mov	eax,Max_SampleNote
	cmp	SampleNote,eax
	jae	skipdowna1
	inc	samplenote
	call	printsamplenote
	call	setfrequenzy
skipdowna1:
	popad
	ret
SampleNoteUp	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			     Sample Note Down
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampleNoteDown	proc	near
	pushad
	call	fixbutton
	cmp	samplenote,42
	jz	skipdowna2
	dec	samplenote
	call	printsamplenote
	call	setfrequenzy
skipdowna2:
	popad
	ret
SampleNoteDown	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			       The Rate Up
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
TheRateUp	proc	near
	cmp	SampleNoteOrRate,0
	jz	SampleNoteUp
	pushad
	call	fixbutton
	mov	eax,Max_SampleRate
	cmp	samplerate2,eax
	jz	skipit1
	add	samplerate2,10
	cmp	samplerate2,eax
	jbe	skipdowna1_
	mov	samplerate2,eax
skipdowna1_:
	call	printsamplerate
	call	setfrequenzy
skipit1:
	popad
	ret
TheRateUp	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 The Rate Down
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
TheRateDown	proc	near
	cmp	SampleNoteOrRate,0
	jz	SampleNoteDown
	pushad
	call	fixbutton
	cmp	samplerate2,5000
	jz	skipit2
	sub	samplerate2,10
	cmp	samplerate2,5000
	jae	skipdowna2_
	mov	samplerate2,5000
skipdowna2_:
	call	printsamplerate
	call	setfrequenzy

skipit2:
	popad
	ret
TheRateDown	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 The Rate Udrag
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
TheRateUdrag:
	cmp	SampleNoteOrRate,0
	jz	TheNoteUdrag
	pushad
	mov	UdragStatus,1
	mov	eax,Max_SampleRate
	mov	ebx,1024
	mul	ebx
	mov	ebx,40
	div	ebx
	mov	ValueProPixel,eax
	mov	eax,Max_SampleRate
	mov	UdragMaxValue,eax
	mov	UdragMiniValue,5000
	lea	eax,SampleRate2
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,RateUdragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
RateUdragMeanWhile:
	pushad
	call	printsamplerate
	call	setfrequenzy
	_rp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 The Note Udrag
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
TheNoteUdrag:
	pushad
	mov	UdragStatus,1
	mov	eax,Max_SampleNote
	mov	ebx,1024
	mul	ebx
	mov	ebx,30
	div	ebx
	mov	ValueProPixel,eax
	mov	eax,Max_SampleNote
	mov	UdragMaxValue,eax
	mov	UdragMiniValue,42
	lea	eax,SampleNote
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,3
	lea	eax,NoteUdragMeanWhile
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	_rp
NoteUdragMeanWhile:
	pushad
	call	printsamplenote
	call	setfrequenzy
	_rp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Rate Input
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RateInput	proc	near
	pushad
	cmp	SampleNoteOrRate,0
	jz	_retp
	move	edi,0a0000h+124*80+304/8
	mov	ecx,5
	mov	ax,0111h
	lea	ebp,samplerate2
	mov	ebx,5000
	mov	edx,Max_SampleRate
	lea	esi,RateUdragMeanWhile
	mov	Digitsize,3
	call	ZyricInput
	popad
	ret
RateInput	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			     volume arrows
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
VolLeft1:
	pushad
	cmp	Allow_LineInSamp,0
	jz	_retp
	call	fixbutton
	cmp	dword ptr [LeftInput],0
	jz	_retp
	dec	dword ptr [LeftInput]
	mov	dword ptr [LeftInput+4],1
	mov	dword ptr [RightInput+4],1
	call	updateinpvol
	_rp
VolRight1:
	pushad
	cmp	Allow_LineInSamp,0
	jz	_retp
	call	fixbutton
	cmp	dword ptr [LeftInput],255
	jz	_retp
	inc	dword ptr [LeftInput]
	mov	dword ptr [LeftInput+4],1
	mov	dword ptr [RightInput+4],1
	call	updateinpvol
	_rp
VolLeft2:
	pushad
	cmp	Allow_LineInSamp,0
	jz	_retp
	cmp	SampleStereo,0
	jz	_retp
	call	fixbutton
	cmp	dword ptr [RightInput],0
	jz	_retp
	dec	dword ptr [RightInput]
	mov	dword ptr [LeftInput+4],1
	mov	dword ptr [RightInput+4],1
	call	updateinpvol
	_rp
VolRight2:
	pushad
	cmp	Allow_LineInSamp,0
	jz	_retp
	cmp	SampleStereo,0
	jz	_retp
	call	fixbutton
	cmp	dword ptr [RightInput],255
	jz	_retp
	inc	dword ptr [RightInput]
	mov	dword ptr [LeftInput+4],1
	mov	dword ptr [RightInput+4],1
	call	updateinpvol
	_rp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;			    mono, stereo, 8bits, 16bits
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SampStereo_Mono:
	cmp	Allow_StereoSamp,0
	jz	_ret
	xor	SampleStereo,1
	call	SetMonoAndBits
	call	SetMicAndLine		;Set SoundCard Info
	mov	dword ptr [LeftInput+4],1
	mov	dword ptr [RightInput+4],1

	call	StartADC
	call	SetFrequenzy		;Set Samp Freq
	ret


Samp8_16bits:

	cmp	Allow_16Samp,0
	jz	_ret
	xor	Sample8or16bits,1
	call	SetMonoAndBits		;Update Screen
	call	SetMicAndLine		;Set SoundCard Info

	call	StartADC
	call	SetFrequenzy		;Set Samp Freq

	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Set mono and bits
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SetMonoAndBits	proc	near
	pushad
	call	mouseoff
	mov	bl,samplestereo


	xor	bl,1
	mov	[DragBarStatus+10],1
	mov	[DragBarStatus+11],0
	jnz	doMONO
	mov	[DragBarStatus+10],1
	mov	[DragBarStatus+11],1
DoMONO:

	mov	buttonx1,431
	mov	buttony1,147
	mov	buttonx2,443
	mov	buttony2,158
	call	buttonupdown
NoNO23:

	mov	bl,sample8or16bits
	xor	bl,1
	mov	buttonx1,431
	mov	buttony1,160
	mov	buttonx2,443
	mov	buttony2,171
	call	buttonupdown
	call	mouseon

	call	PutInputVolume
	popad
	ret
SetMonoAndBits	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Put equalizers
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
EQleft		dd	0
EQright 	dd	0
Putequalizers	proc	near
	pushad
	cmp	menu_popup,14
	jz	ocka
	cmp	menu_popup,13
	jnz	noputequalizers
ocka:
	mov	eax,equalizermaxleft	   ;make mono
	mov	ebx,equalizermaxright
	cmp	SetEqualizer,1
	jz	yes_equ
	xor	eax,eax
	xor	ebx,ebx
yes_equ:
	mov	equalizermaxleft,0
	mov	equalizermaxright,0
	cmp	samplestereo,1
	jz	nomononow
	mov	ebx,eax
nomononow:
	cmp	eax,oldleftequalizer	;check if change
	jnz	starttoputta
	cmp	ebx,oldrightequalizer
	jnz	starttoputta
	jmp	noputequalizers
starttoputta:
	mov	oldleftequalizer,eax
	mov	oldrightequalizer,ebx
	shr	eax,3
	shr	ebx,3
kkoo:
	mov	EQleft,eax
	mov	EQright,ebx

	move	edi,0a0000h+216/8+38*80
	mov	ebp,32
	sub	ebp,eax
	mov	MouseX1,216
	mov	MouseY1,38
	mov	MouseX2,256
	mov	MouseY2,102
	call	MouseOff
	call	theputtingham
	call	MouseOn
	call	MouseReset

	move	edi,0a0000h+376/8+38*80
	mov	ebp,32
	sub	ebp,EQright
	mov	MouseX1,376
	mov	MouseY1,38
	mov	MouseX2,416
	mov	MouseY2,102
	call	MouseOff
	call	theputtingham
	call	MouseOn
	call	MouseReset
	jmp	noputequalizers

Theputtingham:				;theputtingham ------------------
	mov	esi,rednumber
	mov	ecx,32
theputtlopp:
	push	ecx
	mov	ah,00000001b		;Set bitplane 0001
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	xor	eax,eax
	cmp	ebp,0
	jnz	justziro
	cmp	esi,0
	jz	justziro
	mov	eax,-1
justziro:
	mov	[edi],eax
	mov	[edi+4],al
	mov	ah,00000010b		;Set bitplane 0010
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	xor	eax,eax
	cmp	ebp,0
	jnz	justziro2
	cmp	esi,0
	jz	justziro2
	mov	eax,-1
justziro2:
	mov	[edi],eax
	mov	[edi+4],al

	mov	ah,00001000b		;Set bitplane 1000
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	xor	eax,eax
	cmp	ebp,0
	jnz	justziro3
	mov	eax,-1
justziro3:
	mov	[edi],eax
	mov	[edi+4],al

	cmp	esi,0
	jz	kkoo1
	dec	esi
kkoo1:
	cmp	ebp,0
	jz	kkoo2
	dec	ebp
kkoo2:
	add	edi,160
	pop	ecx
	loop	theputtlopp
	ret

noputequalizers:
	popad
	ret
PutEqualizers	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Put scopes
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Scopeleft	db	128	dup(32)
Scoperight	db	128	dup(32)
OldScopeleft	db	128	dup(32)
oldScoperight	db	128	dup(32)
ScopePointer	dd	0
clearbyte	db	0		;0=no clear 1=clear
PutScopes	proc	near
	pushad
	cmp	menu_popup,14
	jz	ocka2
	cmp	menu_popup,13
	jnz	noputscopes
ocka2:
	cmp	setscopes,1
	jnz	noputscopes

	move	edi,0a0000h+72/8+38*80
	lea	esi,scopeleft
	mov	MouseX1,72
	mov	MouseY1,38
	mov	MouseX2,200
	mov	MouseY2,102
	call	MouseOff
	call	putitnow
	call	MouseOn
	call	MouseReset

	move	edi,0a0000h+432/8+38*80
	lea	esi,scoperight
	mov	MouseX1,432
	mov	MouseY1,38
	mov	MouseX2,560
	mov	MouseY2,102
	call	MouseOff

	call	putitnow
	call	MouseOn
	call	MouseReset
	mov	clearbyte,0
noputscopes:
	popad
	ret

putitnow:				;------ put it now!
	pushad
	mov	ah,00000001b		;Set bitplane (write)
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	mov	dx,3ceh 		;Set bitplane (read)
	mov	ah,0
	mov	al,4
	out	dx,ax
	mov	bl,010000000b
	mov	bh,01111111b
	mov	ecx,128
	mov	bp,8
puttsaloopa:
	push	ecx
	mov	ecx,80
	movzx	eax,byte ptr [esi+256]
	mul	ecx
	and	byte ptr [edi+eax],bh
	movzx	eax,byte ptr [esi]
	mov	byte ptr [esi+256],al
	mul	ecx
	cmp	clearbyte,1
	jz	skopea
	or	byte ptr [edi+eax],bl
skopea:
	inc	esi
	ror	bh,1
	ror	bl,1
	dec	bp
	jnz	noincus
	inc	edi
	mov	bp,8
noincus:
	pop	ecx
	loop	puttsaloopa
	popad
	ret
putscopes	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Insert scopes
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
InsertScopes	proc	near
	pushad
	cmp	menu_popup,13
	jz	jaja
	cmp	menu_popup,14
	jnz	_retp
jaja:
	mov	ebp,scopepointer
	mov	eax,leftequalizer
	mov	ebx,rightequalizer
	cmp	samplestereo,1
	jz	nomojao
	mov	ebx,eax
nomojao:
	pushad
	add	al,128
	add	bl,128
	movsx	ecx,al
	mov	eax,ecx
	movsx	ecx,bl
	mov	ebx,ecx
	cmp	eax,0
	jge	noneggaj1
	neg	eax
noneggaj1:
	cmp	ebx,0
	jge	noneggaj2
	neg	ebx
noneggaj2:
	shl	eax,1
	shl	ebx,1
	cmp	equalizermaxleft,eax
	jae	skorsten1
	mov	equalizermaxleft,eax
skorsten1:
	cmp	equalizermaxright,ebx
	jae	skorsten2
	mov	equalizermaxright,ebx
skorsten2:
	cmp	eax,PeakMaxRight
	jbe	nocc1
	mov	PeakMaxRight,eax
nocc1:
	cmp	ebx,PeakMaxLeft
	jbe	nocc2
	mov	PeakMaxLeft,ebx
nocc2:
	popad
	cmp	DrawMax,eax
	jae	donotworry1
	mov	DrawMax,eax
donotworry1:
	cmp	DrawMini,eax
	jbe	donotworry2_
	mov	DrawMini,eax
donotworry2_:



	shr	eax,2
	shr	ebx,2
	mov	[scopeleft+ebp],al
	mov	[scoperight+ebp],bl
	inc	ebp
	and	ebp,127
	mov	scopepointer,ebp
	popad
	ret
InsertScopes	endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Insert peak
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PeakMaxRight	dd	0
PeakMaxLeft	dd	0
PeakMax 	dd	0
InsertPeak	Proc	Near
	pushad
	mov	eax,PeakMaxRight
	mov	ebx,PeakMaxLeft
	cmp	samplestereo,1
	jnz	nostereo
	cmp	eax,ebx
	jae	nostereo
	mov	eax,ebx
nostereo:
;	cmp	sample8or16bits,1
;	jz	skipthissa
	shl	eax,8
;skipthissa:
	mov	ebx,100000
	mul	ebx
	mov	ebx,65536
	div	ebx
	cmp	PeakMax,eax
	jge	_retp

	mov	PeakMax,eax
	xor	edx,edx
	mov	ebx,1000
	div	ebx
	mov	ebx,eax
	push	edx

	call	mouseoff
	mov	fontplane,1
	move	edi,0a0000h+280/8+158*80
	mov	ah,00000001b
	mov	cl,3
	call	PutDecimal
	move	edi,0a0000h+312/8+158*80
	mov	ah,00000001b
	mov	cl,3
	pop	ebx
	call	PutDecimal
	mov	fontplane,0
	call	mouseon

	popad
	ret
InsertPeak	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Peak Clear
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PeakClear	Proc	Near
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp
	mov	peakmax,0
	mov	peakmaxRight,0
	mov	peakmaxLeft,0
	call	mouseoff
	mov	fontplane,1
	move	edi,0a0000h+280/8+158*80
	mov	ah,00000001b
	mov	cl,3
	xor	ebx,ebx
	call	PutDecimal
	move	edi,0a0000h+312/8+158*80
	mov	ah,00000001b
	mov	cl,3
	xor	ebx,ebx
	call	PutDecimal
	mov	fontplane,0
	call	mouseon
	popad
	ret
PeakClear	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Draw sampling
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DrawPointer	db	0
DrawMax 	dd	0
DrawMini	dd	100000
DrawSampling	Proc	Near
	pushad
	cmp	Menu_popup,14
	jnz	_retp
	mov	eax,DrawMax
	cmp	eax,DrawMini
	jl	_retp
	mov	ebx,45
	mul	ebx
	mov	ebx,255
	div	ebx
	mov	DrawMax,eax
	mov	eax,DrawMini
	mov	ebx,45
	mul	ebx
	mov	ebx,255
	div	ebx
	mov	DrawMini,eax
	cmp	DrawMini,45
	ja	_retp
	cmp	DrawMax,45
	ja	_retp


	move	edi,0a0000h+112/8+120*80
	mov	eax,DrawMini
	mov	ebx,80
	mul	ebx
	add	edi,eax
	movzx	eax,DrawPointer
	xor	edx,edx
	mov	ebx,8
	div	ebx
	add	edi,eax
	mov	ecx,edx
	xor	eax,eax
	mov	al,10000000b
	shr	eax,cl
	push	ax
	call	mouseoff
	planewrite 00000001b
	planeread 0
	mov	ecx,DrawMax
	sub	ecx,DrawMini
	inc	ecx
	pop	ax
OraLoopa:
	or	[edi],al
	add	edi,80
	loop	OraLoopa
	call	mouseon

	mov	DrawMax,0
	mov	DrawMini,100000
	cmp	DrawPointer,255
	jnz	noclearoja		;clear
	call	mouseoff
	move	edi,0a0000h+112/8+120*80
	planewrite 00001111b
	mov	ecx,46
	xor	eax,eax
StosbaLoopa:
	push	ecx
	mov	ecx,8
	rep	stosd
	add	edi,80-32
	pop	ecx
	loop	StosbaLoopa
	call	mouseon
noclearoja:
					;print samplength
	call	mouseoff
	mov	fontplane,2
	move	edi,0a0000h+464/8+121*80
	mov	ah,1
	movzx	ebx,SampleCount
	neg	ebx
	add	ebx,8192
	mov	cl,SampleStereo
	shr	ebx,cl

	mov	cl,Sample8or16bits

	shr	ebx,cl
	add	ebx,SampLength
	mov	cl,8
	call	PutDecimal
	mov	fontplane,0
	call	mouseon

	inc	DrawPointer
	popad
	ret
DrawSampling	Endp


