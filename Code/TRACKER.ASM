;;;;	call	checkpreviewkeys ;17B

;oO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0Oo
;-----------------------------------------------------------------------------
;                      -+*+- Velvet Studio v2.1 -+*+-
;-----------------------------------------------------------------------------
;oO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0OoO0Oo

;/ACS\=s


; New flag for v2.0 and above?? - Vic


DOS32VERSION	=	0
PMODEWVERSION	=	1


IF RELEASE
PrintDebug = 0 	;0
ELSE
PrintDebug = 1	;1
ENDIF

PrintColorInfo = 0

FontFileSize	equ	115200	;Also in PROCS1.ASM
KeyMapFileSize	equ	2284*3

IF DOS32VERSION		;\\
.386p
.model flat
.stack 2048					; Define a 65Kb stack
.code
Include dos32.inc
IF DEBUGON
EXTRN	Debug_run:Near,Debug:Near		; Define external symbol
ENDIF
ENDIF			;//


IF PMODEWVERSION	;\\
.386p

_stack	 segment para stack 'STACK'
	 db 4096 dup(?)
_stack	 ends

_TEXT	segment use32 dword public 'CODE'
	assume	cs:_TEXT,ds:_TEXT
Include PMW.inc

_main:
	jmp	start

ENDIF			;//

Jumps
Locals
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Envelope Stuff ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ENV_SplitKBD		equ	0
ENV_Flags		equ	120		 ;FLAGS: fedcba9876543210
							;³³³³³³³³³³³³³³³À Volume :Loop on
							;³³³³³³³³³³³³³³ÀÄ Volume :Sustain on
							;³³³³³³³³³³³³³ÀÄÄ Volume :Envelope on
							;³³³³³³³³³³³³ÀÄÄÄ Panning:Loop on
							;³³³³³³³³³³³ÀÄÄÄÄ Panning:Sustain on
							;³³³³³³³³³³ÀÄÄÄÄÄ Panning:Envelope on
							;³³³³³³³³³ÀÄÄÄÄÄÄ Vibrato:Loop on
							;³³³³³³³³ÀÄÄÄÄÄÄÄ Vibrato:Sustain on
							;³³³³³³³ÀÄÄÄÄÄÄÄÄ Vibrato:Envelope on
							;³³³³³³ÀÄÄÄÄÄÄÄÄÄ Volume :Break Loop
							;³³³³³ÀÄÄÄÄÄÄÄÄÄÄ Panning:Break Loop
							;³³³³ÀÄÄÄÄÄÄÄÄÄÄÄ Vibrato:Break Loop
							;ÀÁÁÁÄÄÄÄÄÄÄÄÄÄÄÄ Reserved
ENV_Shadow		equ	122		;Vibrato sweep
ENV_VolFade		equ	123		;Volume fadeout


ENV_VolSpeed		equ	125		;Speed of Vol envelope
ENV_NrVolPoints 	equ	126		;Nr of Vol Points
ENV_VolSustPoint	equ	127		;Volume sustain point
ENV_VolStart		equ	128		;Volume loop start point
ENV_VolEnd		equ	129		;Volume loop end point
ENV_VolPoints		equ	130		;VolumePoints

ENV_PanSpeed		equ	322		;Speed of Pan envelope
ENV_NrPanPoints 	equ	323		;Nr of Pan Points
ENV_PanSustPoint	equ	324		;Panning sustain point
ENV_PanStart		equ	325		;Panning loop start point
ENV_PanEnd		equ	326		;Panning loop end point
ENV_PanPoints		equ	327		;PanningPoints

ENV_VibSpeed		equ	519		;Speed of Pan envelope
ENV_NrVibPoints 	equ	520		;Nr of Pan Points
ENV_VibSustPoint	equ	521		;Panning sustain point
ENV_VibStart		equ	522		;Panning loop start point
ENV_VibEnd		equ	523		;Panning loop end point
ENV_VibPoints		equ	524		;PanningPoints

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° Macros °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Int3		Macro
IF	DEBUGON
	cli
	int	3
ENDIF

EndM

ConvertNote	Macro In,Out
	push	eax
	mov	eax,In
	call	Getperiod
	mov	Out,eax
	pop	eax
	endm


_rp	macro
	popad
	ret
	endm

GetOffset Macro inst,out,off
	push	ebx ebp
	mov	ebx,inst
	mov	ebp,off
	call	GO
	pop	ebp ebx
	mov	out,TempOffs
	endm

shl16		macro	bulle
		local	nosampbits
		cmp	sampbits,1
		jnz	nosampbits
		shl	bulle,1
nosampbits:
		endm

shr16		macro	bulle
		local	nosampbits2
		cmp	sampbits,1
		jnz	nosampbits2
		shr	bulle,1
nosampbits2:
		endm


PlaneWrite	macro	theplane
	push	ax
	push	dx
	mov	ah,theplane
	call	planewriteproc
	pop	dx
	pop	ax
	endm
PlaneRead	macro	theplane
	push	ax
	push	dx
	mov	ah,theplane
	call	planereadproc
	pop	dx
	pop	ax
	endm

;Calls: eax=Note
GetPeriod	Proc	Near
	push	ebx ecx edx
	mov	ebx,12
	xor	edx,edx
	div	ebx
	mov	edx,[Pt_PeriodTable+edx*4]
	mov	ecx,eax
	shr	edx,cl
	mov	eax,edx
	pop	edx ecx ebx
	ret
GetPeriod	EndP

TempOffs	dd	0
GO:	push	eax edx
	cmp	ebp,124
	jbe	@@Skip
	cmp	Envelope,0
	jz	@@Skip
	add	ebp,197
	cmp	PanOrVib,0
	jz	@@Skip
	add	ebp,197
@@Skip:
	add	ebp,InstrumentInfo
	mov	eax,716
	dec	ebx
	mul	ebx
	add	ebp,eax
	mov	TempOffs,ebp
	pop	edx eax
	ret







;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ErrorCodes
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SwapFileErr	equ	01h
LowMemFatalErr	equ	02h
NoMouseErr	equ	03h
HiMemFatalErr	equ	04h

HiMemErr	equ	0ah	;ModPlayerErrorCodes
GUSMemErr	equ	0bh
DiskFullErr	equ	0ch
FileErrorErr	equ	0dh
HelpFileErr	equ	0eh
HiMemErrNF	equ	0fh
GUSDramErr	equ	10h
OpenErr 	equ	11h
SeekErr 	equ	12h
ReadErr 	equ	13h
NoModuleErr	equ	14h
BadVersionErr	equ	15h
CreateErr	equ	16h
WriteErr	equ	17h
CloseErr	equ	18h
SizeErr 	equ	19h
DeleteErr	equ	1ah
SampleErr	equ	1bh
RenameErr	equ	1ch
OldXMErr	equ	1dh
TimeOutErr	equ	1eh
FREE3		equ	1fh
ConfigErr	equ	20h



;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; DATA
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Public _main

Global Force_SC_Config:Byte
Global MIDIBuffLen:Byte,MIDIBuffPtrR:Byte,MIDIBuffPtrW:Byte,MIDIState:Byte,Midi_Status:Byte
Global Vol:Byte,Volume:Byte,Volumes:Byte,PanMax:Byte,Amplification:Byte,SB_16BitsAllowed:Byte,SB_StereoAllowed:Byte
Global PatternPlay:Byte,SkipPanPot:Byte
Global SoundCard_IRQ:Byte,SoundCard_MIDIIRQ:Byte,SoundCard_DMA1:Byte,SoundCard_DMA2:Byte,DMAOnOff:Byte
Global SongName:Byte,InfoByte:Byte,Samples:byte,Mute:Byte,RampDownTable:byte
Global Relativenote:Byte,FineTunes:Byte,StartSample:Byte,StopSample:Byte
Global IntsOn:Byte,Pt_counter:Byte,SampleBits:Byte

Global SoundCard_BasePort:Word,DSPVersion:Word,SoundCard_BasePort2:Word

Global GUS_FreeTable:Dword,GUS_DramSize:Dword,GUS_DramSize2:Dword,GUS_RollOverDataSize:Dword
Global DMABuffer:Dword,DMABuffer_Phys:Dword,ModNamePtr:Dword,SampleNamesPtr:Dword,ChannelNamesPtr:Dword,InstNamesPtr:Dword
Global PatternOrderPtr:Dword,PatternOffset:Dword,RowSize:Dword,ChRowSize:Dword,PatternStart:Dword

Global InitSoundCard:Near,Mixer:Near,StartADC:Near,StopADC:Near
Global MemoryInit:Near,AskContLoad:Near,GetSampOffset:Near,MainMixer:Near
Global StopAllVoices:Near,StopOneVoice:Near,PlaySample:Near,IndicateTime:Near
Global SetTheFreq:Near,SetFineTune:Near,CreatePostProcess:near

Global DetectSoundCard:Near,InitJumpTable:Near

Global EnvVolume:byte:32,EnvPanPot:Byte:32,KeyOffTable:byte:32,MIDIChanTable:Byte:32
Global R_CurrNoteTable:Byte:32,CurrInst:Byte:32,Note:Byte:32,MIDIBuffer:Byte:16,KBDBuffer:Byte:32

Global CurrSample:Word:32


Global oldcurrentchannel:byte,kbd1request:byte,kbd2request:byte,kbd3request:byte,kbd4request:byte,kbd5request:byte
Global splitonoff:byte:16,currentzone:byte,splitplay:byte,arrowpointer:byte,commandcut:byte,updatearrowpointer:byte
Global mouseondragbar:byte,cursorchannel:byte,lenhexdec:byte,inputrepeatfix:byte,intson:byte
Global finetunes:byte,volumes:byte,volumehexdec:byte,zoom:byte,CaugthDragbar:byte,STArrow:byte
Global samp:byte,protrackerediting:byte,LoadSampleConvert:byte,jumptostart:byte
Global pt_counter:byte,endorlen:byte,voicecontrol:byte,relativenote:byte,TheCapsLock:byte
Global keys:byte:257,keynumpress:byte,SongName:byte,samples:byte,samphexdec:byte
Global splittable:byte:1024,spaces:byte:35,currentsample:word,currentinstname:byte,instnameinput:byte,channels:byte
Global currentchannel:byte,midichannels:byte,sampchannels:byte,chanpos:byte,samplenameinput:byte
Global midi:byte,mute:byte,cmd:byte:96,oldpattname:byte,posedinput:byte,rowshexdec:byte
Global insert:byte,patternnameinput:byte,currentsplit:byte,LoadFTLoop:Byte,ShowRealModName:Byte,PackingByte:Byte
Global nrofdiscdrives:byte,phantomdrive:byte,modname:byte:13,blockendrow:byte,cursorrow:byte
Global filelimit:byte,popupstatus:byte,copyposedinsert:byte,dirtext:byte,modspeed:byte
Global extreme:byte,pressedonce:byte,printblock:byte,SkipClickRemoval:Byte,CurrentTrackerName:Byte:13
Global digitinput:byte,digitsize:byte,initinput:byte,drives:byte:28,errorloadsample:byte
Global typefile:byte,currpath3:byte,currpath4:byte,currpath5:byte,currpath6:byte,currpath7:byte,rowadder:byte
Global moff:byte,currpath0:byte,currpath1:byte,currpath2:byte,currentstrow:byte,currpath8:byte
Global setpopbyte:byte,dumpspecial1:byte,editmode:byte,amigadragbar:byte,amigaokay:byte,currpath9:byte
Global picturesfilename:byte,infoshit:byte,suppclearall:byte,LoadAsInst:byte,O_InProgress:Byte
Global active:byte,currpath10:byte,currpath11:byte,currpath12:byte,UdragStatus:Byte,UdragVariableSize:Byte
Global recmode:byte,octave:byte,fileedited:byte,PatternUpdate:byte,CtrlPress:Byte,ShiftPress:Byte
Global setornot:byte,colorpal:byte:48,RightKeyWait:Byte,Original:Byte,PressCheck:Byte,AltPress:Byte
Global rootdirr:byte,popok:byte,buttoncheck:byte,mode_10tab:byte,buttonhandlerstatus:byte
Global tunestopped:byte,patternplay:byte,endtext:byte,mastervolume:byte,tempodisabled:byte
Global bothkeywait:byte,tunestoppedsave:byte,oldcurrentinstname:byte,oldtime_min:byte,currpath17:byte,currpath18:byte,currpath19:byte,currpath20:byte
Global oldtime_sec:byte,quitfilerequester:byte,doubleclick:byte,CurrentPath:byte:77,currpath21:byte,currpath22:byte
Global autoextension:byte,leftkeywait:byte,deletefile:byte,delfilename:byte:12,envsine:byte
Global renamefile:byte,renfilename:byte:12,marktext:byte,blockstartrow:byte,autoname:byte
Global fileexists:byte,blockpasteforward:byte,killsampletext:byte,fileliststart:byte
Global clearshitty:byte,songedited2:byte,trackerstyle:byte,trackerstyle2:byte,SongFinished:Byte
Global mouseonoff:byte,autoaccept:byte,insertadd:byte,savemodmess:byte,skipmodsavemess:byte
Global bitplane:byte,screamtrackerhelpbars:byte,updatechannels:byte,updatecommands:byte
Global c2mode:byte,destroysample:byte,dontreadfilelist:byte,allocchannels:byte,wrappatt:byte
Global playform:byte,playloop:byte,resamplemode:byte,inverttext:byte,lockenabled:byte
Global keyboardmode:byte,MIDImode:byte,patternmode:byte,displayvolume:byte,currentchannelsave:byte
Global loadallptsamples:byte,playsample0:byte,sensekeyoff:byte,sample0:byte,updatemouse:byte
Global currentinstrument:byte,oldcurrentinstrument:byte,killinsttext:byte,timerselect:byte
Global composer:byte,aishdr:byte,amshdr:byte,commands:byte,defaultcommands:byte,defaultchannels:byte
Global CurrentVolPoint:byte,CurrentPanPoint:byte,askreplacesample:byte,sampleexists:byte
Global askabandonsong:byte,songedited:byte,askreplaceinst:byte,instexists:byte,newfilename:byte:77
Global MM_ChanPress:Byte,MM_ChanStart:Byte,MM_ChanEnd:Byte,MM_Start:Byte,MM_End:Byte,MM_Zoom:Byte
Global ExtendedKeys:Byte,MouseOnceReleased:Byte,DClickCounter:Byte,SaveMODOctaves:Byte
Global LinFreq:Byte,DoubleClickExpired:Byte,LoadSampAsInst:Byte,CurrentWildTBL:Byte
Global MouseCursor:byte,DontDisallocSample:byte,ChannelMaster:Byte,GlobalVolume:Byte
Global KBDBuffPtrR:Byte,KBDBuffPtrW:Byte,KBDBufferFull:Byte,DecimalPoint:Byte,SortType:Byte
Global TempChannels:Byte,TempCommands:Byte,currpath13:byte,currpath14:byte,currpath12:byte,currpath15:byte,currpath16:byte
Global PatternDelay:Byte,ResetTracker:Byte,overwriteinsttext:byte,overwritesamptext:byte
Global InitSpeed:Byte,acshdr:byte,apshdr:byte,asehdr:byte,InputVirtMax:Byte,ShowZero:Byte
Global AllowAutoLoad:Byte,HourGlass:Byte,DMA_CLRFF:Byte,DMA_CNT:Byte,DMAPlay_TC:Byte
Global Stereo:Byte,SampleRate:Byte,InitialSpecial:Byte,envelope:Byte,panorvib:Byte,hilooctave:Byte
Global Autopiano:Byte,VolEnvText:byte,PanEnvText:byte,VibEnvText:byte,PianoStyle:Byte
Global Allow_Sample:Byte,Allow_StereoSamp:Byte,Allow_16Samp:Byte,Allow_LineInSamp:Byte
Global AutoSave:Byte,DemoVersion:Byte
Global AllocFailed:Byte,CPPathBuffer:Byte:67*23,DiskOpDefPath:Byte,oldtime_hour:byte
Global Shelling:Byte


Global MM_RowPress:Word,MM_RowStart:Word,MM_RowEnd:Word,GUSSampleFreq:Word,modtempo:word
Global mousey:word,mousex:word,mouseb:word,e0flag:word,keyboarddelay:word,oldbpm:word
Global menu_upperscreen:word,menu_downscreen:word,currstartposition:word,OldMousePos:word
Global currcursorposition:word,positions:word,currposition:word,positionjump:word
Global oldpos:word,oldpos2:word,currpatt2:word,hertzadder:word,KeyBoardDelayI:Word
Global menu_upperleft:word,dragbartable:word,samplerates:word,InitBPM:Word
Global oldcurrentfilename:word,maxfiles:word,oldpatt:word,oldcurrentsampname:word
Global oldpatt2:word,currpatt:word,currentsampname:word,defaultrows:word,TempModTempo:Word
Global menu_popup:word,nroffiles:word,currentfilename:word,keyboardrepeatI:word
Global currentmenu:word:5,oldcurrentsample:word,oldrow:word,Priority:Word,Real_ES:Word,Real_DS:Word
Global oldlen:word,masterfrequency:word,oldmasterfrequency:word,SubFrequency:Word
Global samplefreq:word,mousex1:word,mousex2:word,mousey1:word,mousey2:word
Global PanEnvStartCoord:word,VolEnvStartCoord:word,OptimBits:word,currrow:word,updatecurrrow:word
Global keyboardrepeat2:word,keyboardrepeat:word,keyboardrepeat1:word,midipriority:word:32
Global DiskOpPictureSong:Word,DiskOpPictureInst:Word,DiskOpPictureSamp:Word,DiskOpPicturePatt:Word
Global oldvolenvstartcoord:Word,oldpanenvstartcoord:Word,GotoRow:Word,ShitPicture:Word

Global oldint9real:dword,lastkeypressed:dword,samplenamesptr:dword,sampleoffsetend:dword
Global sampleoffsetstart:dword,channelnamesptr:dword,keyboardtable:dword,pt_PeriodTable:Dword
Global keyboard_altgr:dword,keyboard_table:dword,keyboard_shift:dword,instnamesptr:dword
Global patternorderptr:dword,patternsize2:dword,patternoffset:dword,instrumentinfo:dword
Global patternstart:dword,loopstart:dword,repeatlengthsave:dword,loopend:dword,TempDword:Dword
Global rowsize:dword,chrowsize:dword,menu_popup_ptr:dword,pcxx:dword,pcxy:dword
Global currentsplitoffset:dword,keyboardnote:dword,samplength:dword,sampmainoffset:dword
Global arrowpositions:dword,buttonx1:dword,buttony1:dword,currpattlength:dword,CurrAdd:DWord
Global buttonx2:dword,buttony2:dword,SampleOffsetMem:dword,extralength:dword,PullSaveSize:dword
Global filelistptr:dword,savename:dword,nisse:dword,filelistmarkptr:dword,EnvVolCheck:Dword
Global currentwildcard:dword,digittarget:dword,digitlimit:dword,updaterows:dword
Global currentpathptr:dword,currpathstart:dword,desctable:dword,descnowoffset:dword
Global pianoscreen:dword,gus_dramfree:dword,memoryfree:dword,DragNumber:dword,UndoSampLength:dword
Global picturex:dword,setx1:dword,sety1:dword,setx2:dword,sety2:dword,setcolor:dword
Global pcxsize:dword,pcxoffsets:dword,lowmemptr:dword,lowmemend:dword,himemptr:dword
Global himemend:dword,menu_downscreen_ptr:dword,menu_upperscreen_ptr:dword,menu_upperleft_ptr:dword
Global buttonhandlerx1:dword,buttonhandlery1:dword,buttonhandlerx2:dword,datfilesize:dword
Global buttonhandlery2:dword,pcxbuffer:dword,buttonplane:dword,buttonstartsave:dword
Global oldinfotextptr:dword,keyboardpress:dword,emptypattern:dword,anewsecond:dword
Global temppattern:dword,tempchannel:dword,tempcommand:dword,gus_tempbuffptr:dword
Global oldx:dword,sampmarkstart:dword,sampmarkend:dword,PicOffsets:dword:3,PlayFreq:Dword
Global viewsampoffset:dword,viewsamplength:dword,playpegoff:dword,dragbardata:dword
Global leftequalizer:dword,rightequalizer:dword,sampbits:dword,alloctable:dword:1053*2
Global currentplane:dword,PopUpPlane1:dword:4,PopUpPlane2:dword:4,PopUpPlane1Width:dword,PopUpPlane1Size:dword,FontPlane:dword
Global TempBufferPtr:Dword,AmigaLength:Dword,SoundCard:Dword,DrawSpecial:Dword,SoundCardSub:Dword
Global ValueProPixel:Dword,UdragMaxValue:Dword,UdragMiniValue:Dword,UdragVariableOffset:Dword,UdragAfter:Dword,UdragMeanWhile:Dword
Global CurrPathTable:Dword,DOS_segs:Dword,SampleSize:Dword,SampPtr:Dword,SamplingBuffOff:Dword
Global UserDefEnv:Dword,Max_SampleRate:Dword,LastPianomouse:Dword,CheckTable:Dword
Global Max_SampleNote:Dword,SizeAllocated:Dword

Global PlayKeysTBL:Fword

Global backcol:near,setdrivepath:near,fadedownpal:near,dumppcx:near,movebuttoncords2:near,movebuttoncords:near
Global setdrivepath2:near,popuphandler2:near,showthepcx:near,popup_okay:near,printcursor:near
Global pop_up_yes:near,pop_up_no:near,popup_okay2:near,pop_up_yes2:near,pop_up_no2:near,popup_okay3:near,popup_okay4:near
Global loadpcxfiles:near,getdrivepath:near,fadeupbuff:byte:48,setpcxpal:near,fadeuppal:near
Global buttonhandler2:near,fixbutton2:near,viewpop1:near,infogadget:near,checkpatternstart_edit:near,checkpatternstart_view:near
Global viewpop2:near,viewpop3:near,viewpop4:near,viewinfoshit:near,clearpopsi:near
Global rowadd2:near,setarea:near,savepopscreen1:near,savepopscreen2:near,printinputtext:near
Global getkeys:near,diskopstart:near,positioneditor:near,descriptionstart:near,printrelnote:near
Global positioneditorexit:near,poseditorsquarepositions:near,poseditorsquare:near
Global updatesampletogus:near,descriptionend:near,drawdesc:near,copysample:near,killsample3:near
Global positioneditor2:near,diskopstart3:near,mouseinit:near,midistyle:near,killsample2:near
Global setnewint9:near,setvector24:near,getmousebackground:near,puthex:near,getfreechannel:near
Global printtext2:near,putmousebackground:near,putmouse:near,printperiod:near,SetSampOffset:Near
Global movecursorposition:near,calccursorpos:near,_retp:near,CheckInstEmpty2:near
Global mousearrow:near,sampletoram:near,inputdigits:near,updateinstnames:near,updatesampnames:near
Global printsampleinfo:near,restorevector24:near,setoldint9:near,inputroutine:near
Global updatechannelinfo:near,mouseoff:near,putcharacter:near,mouseon:near,mousereset:near
Global menuhandler:near,releaselastbutton:near,posinit:near,pattinit:near,KillInst2:Near
Global fixbutton:near,updatedifferentstuff:near,decreaselength2:near,starttimer:near,stoptimer:near
Global buttonupdown:near,getsamplefromdram:near,viewall2:near,buttonhandler:near
Global DisallocSample:near,AllocSample:near,movesample:near,dragbarhandler:near,AMS_GetGUSEnv:near
Global stopallvoices:near,clearforplay:near,showposlist:near,poseditorinput2:near
Global dummy:near,errorhandler:near,scantable:near,getpatternsize:near,getrowsize:near
Global sara4:near,popuphandler:near,fixpatternwidth:near,inputpattern:near,FixAllocSampleError:Near
Global getloadname:near,getcurrpath2:near,patterneditorinsert:near,ChangeSamplingFreq:Near
Global patterneditordelete:near,diskopstart2:near,updatefilelist:near,splitkeyboard:near
Global kill_channel:near,mousehourglass:near,getcurrpath:near,decreasepattern3:near,increasepattern3:near
Global getfilelist:near,putdecimal:near,cut_channel:near,cut_command:near,copy_channel:near
Global copy_command:near,paste_channel:near,paste_command:near,printpattinfo:near
Global printtext:near,printmodname:near,updatesplitstatus:near,updatepattern:near
Global mousestat:near,keyboardhandler:near,mousehandler:near,settrackerpal:near,ViewSongCfg:near
Global splitpopup:near,viewpatternv1:near,viewpatternv2:near,viewpatternv3:near,viewpatternv4:near,viewdescedit:near,viewenvedit:near
Global viewdiskop:near,viewsampinfo:near,viewpositioned:near,cleardescription:near
Global RealMouseOff:near,RealMouseOn:near,printshit:near,savemod:near,clearthesamples:near
Global stoponevoice:near,exittracker:byte,DeInitSoundCard:near,setzerovol:near,loadmod:near
Global setorigvol:near,clearmod:near,playsample:near,transpose:near,viewpattinfo:near
Global decreaseposition2:near,increaseposition2:near,cutchannel:near,copychannel:near
Global pastechannel:near,octaveup:near,octavedn:near,space:near,recpatt:near,recpatt3:near,playrow_a:near
Global killsample:near,jumppattern1:near,jumppattern2:near,jumppattern3:near,addanemptysample2:near
Global jumppattern4:near,jumppattern5:near,pasteblock:near,trackerend:near,popup_yes:near
Global popup_all:near,popup_cancel:near,popup_yes:near,popup_no:near,popup_cancel4:near
Global popup_renameinput:near,popup_song:near,getsplitcurrsample:near,envedsampledrag:near
Global popup_samp:near,keyconfigdrag:near,updatevolumevalues:near,commandsarrowdn:near,commandsarrowup:near
Global split_splitarrowup:near,split_splitarrowdn:near,split_zonearrowup:near,viewoptimpopup:near
Global split_zonearrowdn:near,split_samplearrowup:near,split_samplearrowdn:near,helpscreendrag:near
Global split_kbd1arrowup:near,split_kbd1arrowdn:near,split_kbd2arrowup:near,optimokay:near,optimokay2:near,optimend:near
Global split_kbd2arrowdn:near,split_kbdstartarrowup:near,split_kbdstartarrowdn:near,viewoptimsaved:near
Global split_clearall:near,split_switchactive:near,popup_cancel3:near,popup_kbd1:near
Global popup_kbd2:near,popup_basenote:near,GetRowSize2:Near,JoinPasteBlock:Near,increaseposition:near,loadnext2:near
Global decreaseposition:near,increasepattern:near,decreasepattern:near,wild_all:near,wild_mix:near
Global increaselength:near,decreaselength:near,increasebpm:near,decreasebpm:near,QuickTrackerEnd:Near
Global togglebpm:near,positioninput:near,patterninput:near,lengthinput:near,viewoptimizepopup:near
Global bpminput:near,filelistsquare:near,filenamesquare:near,discopdrag:near,fixpathfile:near
Global discopdragarrowup:near,discopdragarrowdn:near,rename:near,delete:near,menupiano:near
Global savemodule:near,loadmodule:near,loadmodulekey:near,setwildcard:near,MoveTuneForkSample:Near
Global startmod2:near,startmod3:near,startpatt2:near,startpatt3:near,SetSong:near,SetPatt:near,SetInst:near,SetSamp:near
Global recsong:near,recsong2:near,recpatt2:near,stopmod2:near,editmod:near,cleargadget:near,mastervolumedrag:near
Global mastervolumearrowup:near,mastervolumearrowdn:near,samplenamesdrag:near,decreaseinstnames:near
Global increaseinstnames:near,instnamesquare:near,inputmodname:near,setinitialenvelopes:near
Global channelinput:near,channelarrowup:near,channelarrowdn:near,allocateemptypattern:near
Global putsplitpopuptoscreen:near,changeoctave:near,positioneditorins:near,positioneditordel:near
Global positionedpositiondrag:near,decreasestartposition:near,increasestartposition:near
Global posititonpatternname:near,sampleup:near,sampledn:near,increaserepbeg:near,increaserepbeg2:near
Global decreaserepbeg:near,increaserepend:near,decreaserepend:near,increasec2rate:near,decreaserepbeg2:near,increaserepend2:near,decreaserepend2:near
Global decreasec2rate:near,increasefinetune:near,decreasefinetune:near,increasepanpot:near
Global decreasepanpot:near,increasevolume:near,decreasevolume:near,sampnrinput:near,sampnrinput2:near
Global repbeginput:near,rependinput:near,c2rateinput:near,volumeinput:near,sampeditdrag:near
Global channelnr1:near,channelnr2:near,channelnr3:near,channelnr4:near,desceditdrag:near
Global channelnr5:near,channelnr6:near,mute1:near,mute2:near,mute3:near,mute4:near
Global mute5:near,mute6:near,decreasecmdnr:near,increasecmdnr:near,increasecmdnr1:near,increasecmdnr2:near,increasecmdnr3:near
Global increasecmdnr4:near,increasecmdnr5:near,increasecmdnr6:near,channelname0:near
Global channelname1:near,channelname2:near,channelname3:near,channelname4:near,channelname5:near
Global mouseonpattern:near,patterndrag:near,positiondrag:near,channeldrag:near,arrowup:near
Global arrowdown:near,incchannel:near,decchannel:near,rowadd:near,muteall:near,unmuteall:near
Global zoompattern:near,popup_yes2:near,popup_no2:near,popup_all2:near,popup_cancel2:near
Global popup_song2:near,popup_samp2:near,killsampleatchannel:near,SetSampleLoop:Near
Global keyboard:near,playrow:near,changechannel:near,killtoend:near,selectsample:near
Global cutcommand:near,copycommand:near,pastecommand:near,storepattern1:near,storepattern2:near
Global storepattern3:near,storepattern4:near,storepattern5:near,rowaddkey:near,rowsubkey:near
Global startmod:near,startpatt:near,sub8rows:near,arrowleft:near,arrowright:near
Global add8rows:near,insnote1:near,delnote:near,calculateoffset:near,fixsavename:near
Global changechannel2:near,muteall2:near,unmuteall2:near,notedownsp:near,notedownat:near,soloone:near
Global restorefpositions:near,muteone:near,octaveupsp:near,dumpit:near,octaveupap:near
Global octavedownst:near,cutblock:near,copyblock:near,octavedownap:near,markblockbkg:near
Global copyoneabovecommand:near,copyoneabovecommandinc:near,copyoneabovecommanddec:near
Global selectsampleshift:near,cutpattern:near,copypattern:near,pastepattern:near
Global recpattern1:near,recpattern2:near,recpattern3:near,recpattern4:near,recpattern5:near
Global rowsub:near,sampledn2:near,sampleup2:near,insnote2:near,delall:near,getname2:near
Global notedownst:near,notedownap:near,octaveupst:near,insertblock:near,addxrows:near
Global octaveupat:near,octavedownsp:near,octavedownat:near,markblockbeg:near,MM_UnmarkBlock:Near
Global copyallabovecommand:near,copyallabovecommandinc:near,copyallabovecommanddec:near
Global selectsamplectrl:near,playpattern1:near,playpattern2:near,playpattern3:near
Global playpattern4:near,playpattern5:near,decreasepattern2:near,increasepattern2:near
Global delcmd:near,selectsamplealt:near,delallcmd:near,beginfine:near,instup:near,instdn:near,instup2:near,instdn2:near
Global noteupst:near,noteupsp:near,noteupat:near,noteupap:near,selectsamplecl:near
Global expandonechannel:near,contractonechannel:near,deleteblock:near,gofirstrow:near,golastrow:near
Global contractchannel:near,expandchannel:near,expandpattern:near,contractpattern:near
Global insnote3:near,inspatt1:near,inspatt2:near,inscmd1:near,inscmd2:near,inputcomposer:near
Global checkfileformat:near,printonerow_pt:near,showmainpattern:near,arrowxdown:near,arrowxup:near
Global OctaveUpSB:Near,OctaveUpAB:Near,OctaveDownSB:Near,OctaveDownAB:Near,NoteUpSB:Near,NoteUpAB:Near,NoteDownSB:Near,NoteDownAB:Near
Global storecommand1:near,insertallcommands1:near,insertonecommand1:near,CapsLockSkip:Near
Global storecommand2:near,insertallcommands2:near,insertonecommand2:near,ToggleCapsLock:Near
Global storecommand3:near,insertallcommands3:near,insertonecommand3:near,ButtonCopyInst:Near,ButtonMoveInst:Near
Global storecommand4:near,insertallcommands4:near,insertonecommand4:near,NotEnoughHiMem:Near
Global storecommand5:near,insertallcommands5:near,insertonecommand5:near,KillInstrument2:Near
Global storecommand6:near,insertallcommands6:near,insertonecommand6:near,MarkUp:Near,MarkDn:Near,MarkLt:Near,MarkRt:Near
Global storecommand7:near,insertallcommands7:near,insertonecommand7:near,QuickMark:Near
Global storecommand8:near,insertallcommands8:near,insertonecommand8:near,MarkPGUP:Near,MarkPGDN:Near,MarkEnd:Near,MarkHOME:Near
Global storecommand9:near,insertallcommands9:near,insertonecommand9:near,MM_CalcRow:Near
Global storecommand0:near,insertallcommands0:near,insertonecommand0:near,MarkChanPatt:Near
Global realnameonoff:near,packsamponoff:near,updatepattdefscreen:near,fixclipmem:near
Global sampleeditorkeyboardplay:near,nomidistyle:near,updateenvelopescreen:near,ButtonShadowInst:Near
Global insertscopes:near,killinstrument:near,printenvvolspeed:near,printenvpanspeed:near
Global printvibspeed:near,printfadeout:near,printcomposer:near,memalloc:near,memdisalloc:near
Global insnote4:near,insnote5:near,fixallocchannels:near,allocateinitialbuffers2:near,justconvert:near
Global OptimChanRem:Near,OptimCommRem:Near,OptimPattRem:Near,OptimInstRem:Near,OptimChanCom:Near,OptimCommCom:Near
Global OptimPattCom:Near,OptimInstCom:Near,OptimSelAll:Near,OptimSelNone:Near,OptimSelPatt:Near,OptimSelSong:Near
Global fasterarrowup:near,fastestarrowup:near,fasterarrowdown:near,fastestarrowdown:near
Global convertsigned:near,getname:near,ftloop:near,switchc2mode:near,mouseplay:near
Global cutnewblock:near,copynewblock:near,pastenewblock:near,normalkbdoff:near
Global GetCurrC2RateInPeriod:near,PopPart:near,PushPart:near,DrawPopup:near,UpdateBlockBock:near
Global Pop_Up_Cancel:near,Pop_Up_Cancel2:near,SetFrequenzy:Near,FixPatternLength:Near
Global TurnOnSoundCard:Near,Stop_CD:near,CheckReleaseKeys:near,TuneForkOn:Near,TuneForkOff:Near
Global CD_stop2:Near,AfterZyricInput:near,BPMUDrag:Near,LenUDrag:Near,PattUDrag:Near,PosUDrag:Near,BPMUDrag:Near
Global DelSampleRate:Near,InsSampleRate:near,PutSampleRate:Near,GetSampleRate:near,InstUDrag:Near
Global Patt3UDrag:Near,PattLenUDrag:Near,CommandsUDrag:Near,ChannelUDrag:Near,SetReset:Near
Global StoreUndoBuffer:Near,SwapUndoBuffer:Near,CheckForShadow:Near,UpdateSCScreen:Near
Global SC_ChangeReplay:Near,SBP_MixData:Near,AskKillSamp:Near,UpdateSongCfgScreen:near
Global SaveACS:Near,SaveAPS:Near,Writefile:Near,GetMaxHertz:Near,Sub16Rows:Near,Sub32Rows:Near,Add16Rows:Near,Add32Rows:Near
Global AutoLoad:Near,DOSPrepare:Near,DOSInterrupt:Near,PrintRowAdd:Near,UpdateShadows:Near
Global jumppattern1M:near,jumppattern2M:near,jumppattern3M:near,jumppattern4M:near,jumppattern5M:near
Global NoteOff:Near,DecreaseAllCmdNr:Near,IncreaseAllCmdNr:Near,UpdateEnvelopeScreen2:Near
Global printpianosplit:Near,envelopeend3:Near,envelopestart2:Near,pianopressed:Near,volumeenvsquare:Near
Global scrollvolenvelopeleft:Near,scrollvolenveloperight:Near,volenvvolarrup:Near,volenvvolarrdn:Near
Global volenvtimearrup:Near,volenvtimearrdn:Near,volenvenable:Near,volenvlooponoff:Near
Global volenvbreaklooponoff:Near,volenvloopstartarrup:Near,volenvloopstartarrdn:Near,volenvloopendarrup:Near
Global volenvloopendarrdn:Near,volenvelopespeedup:Near,volenvelopespeeddn:Near,volenvpointsarrup:Near
Global volenvpointsarrdn:Near,volenvsustainarrup:Near,volenvsustainarrdn:Near,volsustainenable:Near
Global currvolpointup:Near,currvolpointdn:Near,panningenvsquare:Near,scrollpanenvelopeleft:Near
Global scrollpanenveloperight:Near,panenvpanarrup:Near,panenvpanarrdn:Near,panenvtimearrup:Near
Global panenvtimearrdn:Near,panenvenable:Near,panenvlooponoff:Near,panenvbreaklooponoff:Near
Global panenvloopstartarrup:Near,panenvloopstartarrdn:Near,panenvloopendarrup:Near,panenvloopendarrdn:Near
Global panenvelopespeedup:Near,panenvelopespeeddn:Near,panenvpointsarrup:Near,panenvpointsarrdn:Near
Global panenvsustainarrup:Near,panenvsustainarrdn:Near,panenvsustainenable:Near,currpanpointup:Near
Global currpanpointdn:Near,increlnote:Near,decrelnote:Near,relnoteudrag:Near,fadeoutarrup:Near
Global fadeoutarrdn:Near,fadeoutudrag:Near,vibsweeparrup:Near,vibsweeparrdn:Near,vibsweepudrag:Near
Global volumespeedinput:Near,panspeedinput:Near,fadeoutinput:Near,inputrelnote:Near,increasesamplenames:Near
Global decreasesamplenames:Near,samplenamesquare:Near,selectvibenvelope:Near,selectpanenvelope:Near
Global linevol:Near,sine1vol:Near,sine2vol:Near,usedefvol0:Near,usedefvol1:Near,usedefvol2:Near
Global usedefvol3:Near,predefvol0:Near,predefvol1:Near,predefvol2:Near,predefvol3:Near,linepan:Near
Global sine1pan:Near,sine2pan:Near,usedefpan0:Near,usedefpan1:Near,usedefpan2:Near,usedefpan3:Near
Global predefpan0:Near,predefpan1:Near,predefpan2:Near,predefpan3:Near,scalevolxsub:Near
Global scalevolxadd:Near,scalevolysub:Near,scalevolyadd:Near,scalepanxsub:Near,scalepanxadd:Near
Global scalepanysub:Near,scalepanyadd:Near,buttoncopysamp:Near,buttonmovesamp:Near,vibamparrowup:Near
Global vibamparrowdn:Near,updateenvvoldrag:Near,updateenvpandrag:Near,movepoint:Near,updatepianopress:Near
Global checkagainstpopup:Near,moveenvdata:Near,SaveConfig:Near,NoSetRate:Near,SkipMODMess:Near
Global Start2:Near,IWannaSave:Near,ThatsOkayThen:Near,Spc2:Near,Spc3:Near,SpeechEngine:Near,StopSpeech:Near
Global CheckLoadName:Near,PrintAllEnvelopeNumbers:Near,PrintNames:Near,PrintShadowNR:Near,CheckSpeech:Near
Global MutePress:Near

Public Skipput,sizex
Global Loadpopup1:near,Savepopup1:near,dumpdownscreen:near,buttonupdownmem:near
Extrn  Buttonx1:dword,Buttony1:dword,Buttonx2:dword,Buttony2:dword
Extrn  ButtonC1:byte,Buttonc2:byte,ButtonXstart:dword,ButtonXend:dword,LineColor:dword,Buttonedisave:dword,buttonstartsave:dword,buttonplane:dword,buttonsave:dword,fastpic:dword
Global check:byte
Global loadpopup2:near,savepopup2:near,PutArrow:near
Global optiondrag1:near,optiondrag2:near,sampletogus:near
Global viewsamp:near,addpiccy:dword,samplechange:near,updateplayform:near
Global nomouseon:byte,equalizerinformation:byte:6,movethepegs:near,peghide:byte
Global Rowwrap:byte,themovepeg:byte
Global sampleedstop:near,resetequ:near
Global samplength:dword,saveundo:near,putsplit2:near,
Global clearthesong:near,clearsamples:near,clearallshit:near
global	skippasample:byte,ramtable:word,samplefreq:word,samplength:dword
global	printsamplerate:near,samplerate2:dword
global	choosemake:dword,makepicture:dword
global	buttonspecial:byte,undobufferoffset:dword,allocsamplength:near,alloccliplength:near
global	thecolortable:byte:16*3,FormSelect:byte
Global EndSampleModeAll:Byte,GetNoteFromSampleFreq:near


global	maskx:dword,masky:dword,unpackmasktext:near,writemasktext:near
global pcxs_x1:dword,pcxs_x2:dword,pcxs_y1:dword,pcxs_y2:dword,pullmode:byte
Global BoxClipByte:Dword:16
;global testnewpal:byte
Global SplitPopupPicture:word,ClearPicture:word,OptimPicture:word,Pop3Picture:word,Popup1Picture:word,Popup2Picture:word,TextPicture:word,SecondPopup:dword,KeysPopupSpecial:byte
global SpecialTextOffset:dword,SpecialSecondPopup:byte,OldPuts:dword:20,MemErrorStatus:byte
global _bretp:near,_bret:near
Include global.asm

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				  INCLUDES AND DUPS
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
CRCCheck1Start: 					;CRC Check!

Include Tracker2.asm
Include Keys.Asm
Include SampEd.asm
Include Config.Asm
Include Colors.Asm
Include Option.Asm
Include Help.asm
Include Pull.Asm
Include Descrip.Asm
Include PopData.Asm
Include Col.Asm


PlaneWriteProc	proc	near
	mov	al,02h
	mov	dx,3c4h
	out	dx,ax
	ret
PlaneWriteProc	endp
PlaneReadProc	proc	near
	mov	dx,3ceh 		;Set bitplane (read)
	mov	al,4
	out	dx,ax
	ret
PlaneReadProc	endp

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° Text °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

EndText 	db	"ÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸"
		db	"³      Velvet Studio v2.01 PRO, (C) Copyright 1994-1997 Velvet Development     ³"
		db	"ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´"
		db	"³                    Shareware version. Released:  ",??date,"                    ³"
		db	"³                                                                              ³"
		db	"³                                Programmed by:                                ³"
		db	"³                        David Broman & Patrik Oscarsson                       ³"
		db	"³                                                                              ³"
		db	"³                   Support the evergrowing pulsating brain,                   ³"
		db	"³                 please send us $15 and feel like a humanoid.                 ³"
		db	"ÔÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¾"
		db	'$'

EndText2	db	13	dup(13,10)
		db	'$'
EndText3	db	49	dup(13,10)
		db	'$'

ErrorCodeTable	dd	Undefined,SwapFileError,LowMemFatalError,NoMouseError,HiMemFatalError,Undefined,Undefined,Undefined
		dd	Undefined,Undefined,HiMemError,GUSMemError,DiskFullError,FileErrorError,HelpFileError,HiMemErrorNF
		dd	GUSDramError,OpenError,SeekError,ReadError,NoModuleError,BadVersionError,CreateError,WriteError
		dd	CloseError,SizeError,DeleteError,SampleError,RenameError,OldXMError,TimeOutError
		dd	Undefined,ConfigError

Undefined	db	'Undefined Error!!!$'

ShadowText	db	"Sorry, but you can't do that on a Shadow Instrument$"

SwapFileError	db	'Swapfile corrupted!!!$'
LowMemFatalError db	'Sorry, but You need about 600 KB free CONTINUOUS XMS Memory$'
NoMouseError	db	'You Must Have a Mouse installed!$'
HiMemFatalError db	'Sorry, but you need about 600 KB free CONTINUOUS XMS memory!',10,13,"$"

HiMemError	db	'Not Enough Memory!!@'
		db	'The tracker may now crash :($'
GUSMemError	db	'Not Enough GUS Memory! some samples@'
		db	'are NOT loaded$'
DiskFullError	db	'Disk is full!$'
FileErrorError	db	'Did not load file!$'
HelpFileError	db	'VS.HLP not found$'
HiMemErrorNF	db	'Not Enough Memory!!$'
GUSDramError	db	'Not Enough GUS Memory$'
OpenError	db	'Error Opening File$'
SeekError	db	'Error Seeking in File$'
ReadError	db	'Error Reading File$'
NoModuleError	db	'No Loadable Module$'
BadVersionError db	'Unknown File type$'
CreateError	db	'Error Creating File$'
WriteError	db	'Error Writing File$'
CloseError	db	'Error Closing File$'
SizeError	db	'Error in Size of File$'
DeleteError	db	'Error Deleting File$'
SampleError	db	'Sorry, but 255 instruments is the limit!$'
RenameError	db	'Error Renaming file!$'
OldXMError	db	'OLD XM format, re-save in FT2!$'
TimeOutError	db	'FATAL ERROR! DMA-IRQ Failure@'
		db	'Disable DMA in the config$'
ConfigError	db	'Old config-file found: NOT used!$'

CommandCut	db	"The number of commands doesn't match.@"
		db	"Do you want to adjust the command width?$"
VolEnvText	db	'Volume Envelope'
PanEnvText	db	'Panning Envelope'
VibEnvText	db	'Vibrato Envelope'
KillSampleText	db	'Kill sample?$'
KillInstText	db	'Kill Instrument?$'
OverwriteInstText	db	'Overwrite Instrument?$'
OverwriteSampText	db	'Overwrite Sample?$'
ClearShitty	db	'What do you want to clear?$'
ExitTracker	db	'Really exit?$'
FileExists	db	'File already exists, Overwrite?$'
SampleExists	db	'Overwrite sample?$'
LoadAsInst	db	'Load Samples as Instruments?$'
InstExists	db	'Overwrite instrument?$'
SongEdited	db	'Abandon current song?$'
SongEdited2	db	'Current song not saved! Exit?$'
SaveMODMess	db	'WARNING!!! Saving this format@'
		db	'will strip off all extra features! SAVE?$'
;LoadAMSMess	 db	 'ATTENTION! Remember that you cannot save this file!$'
;LoadOnceMess	 db	 'ATTENTION! Remember that you only can save ONCE!$'

XMSMemError	db	'Not Enough Sample Memory! Sample(s)@'
		db	'cut or NOT loaded$'
FileLimit	db	"All files aren't displayed!@"
		db	"Wait for the next version for bugfix!$"
DeleteFile	db	'Delete the file?@'
DelFileName	db	12 dup(0),'$'
RenameFile	db	'Rename the file:$'
RenFileName	db	12 dup(0),'$'
NOS_Version1	db	"Nosound"
GUS_Version1	db	"GUS Classic. "
GUS_Version2	db	"GUS Ver 3.7, ICS Mixer with flip Bug. "
GUS_Version3	db	"GUS Ver 3.7 or above, ICS Mixer. "
GUS_Version4	db	"GUS MAX. CS4231 present."
SBP_Version1	db	"SoundBlaster PRO,"
SBP_Version2	db	"SoundBlaster PRO v2.0,"
SB16_Version1	db	"SoundBlaster 16,"
SB_Version1	db	"SoundBlaster v1,"
SB_Version2	db	"SoundBlaster v2,"
SBDSP_Version	db	"DSP xx.xx"
PNP_Version	db	"Gravis UltraSound PnP         "


RestartText	db	'The tracker will save the config and restart without@saving your work. Restart?$'
FileErrorMess	db	'File is corrupted! Load Anyway?$'
SampleNotAllowed db	"Sorry, but the current SoundCard settings@"
		db	"doesn't allow sampling$"
DemoVersion	db	"Sorry, but that isn't allowed in the@unregistered version$"
PROVersion	db	"Sorry, but that is only available in the PRO version$"
Spaces		db	35 dup (' ')
Off		db	' Off '
AllRightText	db	'Oct:  Note:   '
MarkText	db	'Frm:    to    '
Samp		db	'SAMP'
MIDI		db	'MIDI'
DirText 	db	'<Directory>'
Extreme 	db	'Extreme'
SuppClearAll	db	'Clr. all'
Active		db	'Active'
ChooseMake	dd     -1
TrackerStyle2	db	0	;dummy byte
ReqConfigErr	db	0
Typematic	dw	0	;0-1d,0-3
NotFound	db	0
TempMasterVolume db	0

ShitString      db      12,12,23,12,88,54,12,12,42,95
                db      54,63,53,43,68,16,14,12,52,33
                db      23,24,53,77,58,16,32,32,27,14
                db      31,82,23,35,81,74,13,13,68,37
TheNameCrypt	db	50 dup(0)
TestCryptString	 db	20 dup(' ')



DOS_segs LABEL DWORD
Real_ES     DW	?
Real_DS     DW	?

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° Variables °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

CommandLine		db	256 dup(?)	; Commandline copied here
ModName 		db	13 dup(0)    ;The actual Modname
SaveName		dd	0	;Ptr to ModName to save
LowMemPtr		dd	0	;Ptr to Start of Low Memory
HiMemPtr		dd	0	;Ptr to Start of High Memory
LowMemEnd		dd	0	;Ptr to End of Low Memory
HiMemEnd		dd	0	;Ptr to End of High Memory
FileListPtr		dd	0	;Pointer to FileList
TempPattern		dd	0	;Clipboard PatternBuff for Cut/Copy/Paste
TempCommand		dd	0	;Clipboard CommandBuff
TempChannel		dd	0	;Clipboard ChannelBuff
TempBufferPtr		dd	0	;Temporary Buffer
UserDefEnv		dd	0	;User Def Env.

StackSave		dd	0	;The Saved StackPtr (for errorhandler)

Keys			db 257 dup(0)	;Key Table /MUST BE TOGETHER/
E0Flag			dw	0	;A flag 		   /WITH/
KeyNumPress		db	0	;Numbers of keys pressed       /THIS/
LastKeyPressed		dd	0
DragNumber		dd	0,0,0	;Drag and Drop System. Action/Nr/Info

OldInt9Real		dd	0	;INT9Save In Real Mode
CurrentSample		dw	16	;Current Sample in Tracker
CurrentInstrument	db	1	;Current Instrument In tracker
ExtraLength		dd	0	;Used in DragBarHandler
CurrentChannel		db	0	;Ptr in ChanPos (first visible channel)
OldMasterFrequency	dw	0	;Needed for Timing
Time_Hour		db	0	;Current time hour
Time_Min		db	0	;Current time min
Time_Sec		db	0	;Current time sec
KeyBoardPress		dd	0	;The Key Pressed
InfoTextPtr		dd	0	;ptr to test to print

PatternNameInput	db	0	;1 if PatternName is being updated
InstNameInput		db	0	;1 if SampleName is being updated
SampleNameInput 	db	0
RepeatLengthSave	dd	0	;Save for RepLen
Insert			db	0	;1 if insert is ON
CurrPattLength		dd	0	;Length for Current pattern.
NrOfDiscDrives		db	0	;Nr of DiscDrives Installed
PhantomDrive		db	0	;1=A, 2=B
TotalXMS		dd	0	;Total Memory
AllowAutoLoad		db	0	;Allow auto load if multiselect


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° Options °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
GUS_RollOverDataSize	dd	16384	;Size of Sample Ed GUS Buffer
MaxFiles		dw	1500	;Max nr of files in FileList
PanMax			db	15	;Only Stupid fools uses 128... (15)
KeyMapSelect		db	0

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° Switches °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

COD1			label	byte
EndOrLen		db	0	;Repeat LENGTH
VolumeHexDec		db	1	;Print Volume in hex
SampHexDec		db	1	;Print Sample # in hex
LenHexDec		db	0	;Print SampLen/Beg/End in hex
RowsHexDec		db	0	;Print rows in hex
DisplayVolume		db	1	;Display Current Volume
ShowZero		db	0	;Display dot instead of 0
ScreamTrackerHelpBars	db	0	;Space between HelpBars
TrackerStyle		db	0	;Use ScreamTrackers PatternStyle
FontSelect		db	7	;1BPL Font nr
FontSelect2		db	7	;2BPL Font nr

					;±±±±± EDIT ±±±±±
COD2			label	byte
ProTrackerEditing	db	0	;Use ProTracker's Edit style
AmigaDragBar		db	0	;Use Amiga style Dragbar
CopyPosEdInsert 	db	1	;Copy the current pattern at Insert
InsertAdd		db	3	;Change row after an insert
BlockPasteForward	db	1	;Change row after a block paste
AutoAccept		db	2	;Accept input automatically at end
KeyboardMode		db	1	;MIDI styled keyboard
MIDIMode		db	1	;MIDI styled MIDI Device
MultiChanPlay		db	1	;MultiChannel KeyJazz
SenseKeyOff		db	1	;Sense keyoff when no Envelope
PatternMode		db	1	;Connect Patterns
JumptoStart		db	0	;Jump to start when change pos
WrapPatt		db	3	;Wrap Pattern
STArrow 		db	0	;Scream Tracker ArrowHandling
PianoStyle		db	0	;FT2/ET style
LockEnabled		db	1	;Enable Channel Lock functions
KeyBoardLayout		db	0	;SV, US etc.
FlipButtons		db	0	;1=LeftHanded Mouse

					;±±±±± MESSAGES ±±±±±
COD3			label	byte
AskAbandonSong		db	1	;Ask if to Abandon the current song
AskReplaceInst		db	0	;Ask if to Replace the current sample
AskReplaceSample	db	0	;Ask if to Replace the current sample
SkipMODSaveMess 	db	1	;Skip Warning Message when saving MOD

					;±±±±± FILE REQ ±±±±±
COD4			label	byte
DiskOpDefPath		db	0	;Use Config Default with LBM
ShowRealModName 	db	1	;Show Real ModName in FileRequester
AutoExtension		db	1	;Insert extension if none supplied
LoadFTLoop		db	0	;Load FT Loop
LoadSampleConvert	db	1	;Auto Convert sample when loading
QuitFileRequester	db	1	;Quit diskop after load.
AutoName		db	1	;Automatically Inserts Name
PackingByte		db	1	;Packing Method
DestroySample		db	0	;Destroy sample when saving MOD
SaveMODOctaves		db	0	;Save 3 or 5 octaves
LoadAllPTSamples	db	1	;Loads all [empty] samples in a .MOD
LoadSampAsInst		db	2	;Load multiple samples as inst.
SortType		db	1	;Sort Name or Extension

					;±±±±± PLAYER ±±±±±
COD5			label	byte
SkipPanPot		db	0	;Skip all PanpotCommands
LinFreq 		db	0	;Linear Freq

					;±±±±± SAMP.ED.±±±±±
COD6			label	byte
MoveCursorOrNot 	db	1	;Move cursor when unmarking in samped
AutoAll 		db	0	;Automatic all
AutoArea		db	0	;Automatic area
AutoScreen		db	1	;Automatic screen
AutoOffset		db	1	;Automatic offset
ResampleMode		db	1	;0=Resample sample, 1=Change C2Rate, 2 nothing
EndSampleMode		db	1	;0=Not stop CD,1=Stop CD,2=pause CD
EndSampleModeAll	db	1	;0=Not stop CD,1=Stop CD
Mark_viewall		db	1	;Remove mark 0=yes 1=no
Mark_zoomarea		db	0	;Remove mark 0=yes 1=no
Mark_zoomout		db	1	;Remove mark 0=yes 1=no
Mark_convert		db	1	;Remove mark 0=yes 1=no
Mark_copy		db	0	;Remove mark 0=yes 1=no
Mark_zero		db	0	;Remove mark 0=yes 1=no
Mark_preserve		db	0	;Remove mark 0=yes 1=no
Mark_normvol		db	1	;Remove mark 0=yes 1=no
Mark_reverse		db	1	;Remove mark 0=yes 1=no
PreviewTime		db	2	;Preview time
EnableCD		db	1	;Enable CD

					;±±±±± EQUALIZERS ±±±±±
COD7			label	byte
EquSizeX		db	5	;X size for equalizer
EquSizeY		db	8	;Y size for equalizer
EquUporDown		db	2	;Equalizer location
EquSpeedUp		db	2	;Equalizer speed up
EquSpeedDown		db	1	;Equalizer speed down

					;±±±±± Desc editor ±±±±±
COD8			label	byte
RowWrap 		db	1	;Row Wrap
InsertStart		db	1	;InsertStart
DescShowLine		db	1	;InsertStart

					;±±±±± Inst editor ±±±±±
COD9			label	byte
AutoPiano		db	1	;Automatically show Piano

NUMBERSWITCHES	equ	$-COD1

DataListTBL	dd	COD1,COD2,COD3,COD4,COD5,COD6,COD7,COD8,COD9
SwitchListTBL	dd	COS1,COS2,COS3,COS4,COS5,COS6,COS7,COS8,COS9
HelpListTBL	dd	COH1,COH2,COH3,COH4,COH5,COH6,COH7,COH8,COH9

OptionListTBL	dd	CO1,CO2,CO3,CO4,CO5,CO6,CO7,CO8,CO9
NUMBEROPTIONS	equ	($-OptionListTBL)/4

;************************** CHECK PROCS.ASM for texts **************************



;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° Tables °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°


BlockTable	dw	0,0,155,85,0,4		;Pos info
		dw	0,86,155,222,1,3	;Upper Left
		dw	0,223,640,480,2,1	;Lower
		dw	156,0,340,185,3,2	;Upper middle
		dw	156,186,640,222,4,2	;Piano
		dw	341,0,640,185,5,2	;Sample
		dw	-1

SubMenuTBL	dd	UpperCorner,LeftUpperScreen,LowerScreen,UpperScreen,Piano_Screen,SampleScreen
UpperCorner	dd	MouseTable
LeftUpperScreen dd	SampleInfo,PosEditor,PattInfo,SongCfg
LowerScreen	dd	pt_Pattern1,st_Pattern1,pt_pattern2,st_pattern2,SampleEditor1,SampleEditor2,CommentsEditor,EnvelopEd
UpperScreen	dd	MainSquare,Equalizer1,Equalizer2,DiscOp
Piano_Screen	dd	MainSquare,PianoSquare,EQSquare
SampleScreen	dd	MainSquare,SampleSquare

;POPPIS
PopUpTable	dd	PopUp1,PopUp2,PopUp3,PopUp4,ViewInfoShit2,Clearasfmk,Pulldownpopup,Popupkeys,Splitpop,PopupColors,MouseOption,ViewTextMouse,Viewthesample2,Dosamplemouse,InfoButtMouse,viewpop16M,viewpop17M,viewvolumeM,viewmixM,viewpop20M,yfixM,OptimPop,NewPullDownMouse,OptimSaved,YESNOUPMUS,NewVolMouse,NewMarkMouse,SoundcardCfg,EffectsPopupMouse,0,EchoEditorPopup,HelpPopup,PattDefPopup,ResamplePopupMouse,EffectwaitPopupMouse,ConfigPathPopup,viewpop21M,viewnewmultipopup,vieweffecteditmouse,viewpop22M,vieweffecteditmouse2,EQEdPopup
PopUp1		dw	357,128,413,146
		dd	Popup_Okay
		dw	-1
PopUp2		dw	327,128,385,146
		dd	Pop_up_Yes
		dw	386,128,440,146
		dd	Pop_up_No
		dw	-1
PopUp3		dw	272,128,328,146
		dd	PopUp_Yes
		dw	329,128,385,146
		dd	PopUp_No
		dw	386,128,438,146
		dd	PopUp_All
		dw	439,128,499,146
		dd	PopUp_Cancel
		dw	-1
PopUp4		dw	296,128,359,146
		dd	PopUp_Yes	;Rename
		dw	360,128,409,146
		dd	PopUp_No	;Skip
		dw	410,128,469,146
		dd	PopUp_Cancel
		dw	336,111,429,123
		dd	PopUp_RenameInput
		dw	-1
ViewInfoShit2	dw	285,182,338,200
		dd	Popup_okay
		dw	-1
Clearasfmk	dw	276,128,315,146
		dd	PopUp_Song		;Pos  1
		dw	316,128,411,146
		dd	PopUp_Samp		;Samp 4
		dw	412,128,443,146
		dd	PopUp_All		;All  2
		dw	444,128,499,146
		dd	PopUp_Cancel		;Cancel 3
		dw	-1

InfoButtMouse	dw	482,186,556,202
		dd	Keysend 		;EXIT
		dw	-1
Viewpop16M	dw	293,296,349,314
		dd	Popup_Okay
		dw	-1
ViewPop17M	dw	263,296,321,314
		dd	Pop_up_Yes
		dw	322,296,376,314
		dd	Pop_up_No
		dw	-1
ViewPop21M	dw	263,236,321,254
		dd	Pop_up_Yes
		dw	322,236,376,254
		dd	Pop_up_No
		dw	-1
viewnewmultipopup	label word
		dw	436,280,521,296
		dd	CancelNewMultiEffect
		dw	376,280,435,296
		dd	OkayNewMultiEffect
		dw	205,252,433,268
		dd	MultiNameInput
		dw	-1
vieweffecteditmouse	label word
		dw	195,367,208,383
		dd	ThePointUp
		dw	215,367,228,383
		dd	ThePointDown
		dw	209,367,214,383
		dd	ThePointUdrag
		dw	149,367,193,383
		dd	ThePointInput
		dw	532,372,564,389
		dd	SelectLoop
		dw	195,349,208,365
		dd	VoiceEnvPointUp
		dw	215,349,228,365
		dd	VoiceEnvPointDown
		dw	209,349,214,365
		dd	VoiceEnvPointUdrag
		dw	532,356,542,370
		dd	SetCurve0
		dw	543,356,553,370
		dd	SetCurve1
		dw	554,356,564,370
		dd	SetCurve2
		dw	195,385,208,401
		dd	TimeArrowUp
		dw	215,385,228,401
		dd	TimeArrowDown
		dw	209,385,214,401
		dd	TimeUdrag
		dw	195,403,208,419
		dd	EnvelopeArrowUp
		dw	215,403,228,419
		dd	EnvelopeArrowDown
		dw	209,403,214,419
		dd	EnvelopeUdrag
		dw	195,421,208,437
		dd	EnvLoopStartUp
		dw	215,421,228,437
		dd	EnvLoopStartDown
		dw	209,421,214,437
		dd	EnvLoopStartUdrag
		dw	149,421,193,437
		dd	LenLoopStartTextInput
		dw	195,438,208,454
		dd	EnvLoopendUp
		dw	215,438,228,454
		dd	EnvLoopEndDown
		dw	209,438,214,454
		dd	EnvLoopEndUdrag
		dw	149,439,193,455
		dd	LenLoopEndTextInput
		dw	230,419,250,430
		dd	EnvCurveArrowLeft
		dw	493,419,513,430
		dd	EnvCurveArrowRight
		dw	518,350,529,364
		dd	EnvCurveArrowUp
		dw	518,403,529,417
		dd	EnvCurveArrowDown
		dw	542,403,552,417
		dd	EnvCurveHorzZoomPlus
		dw	553,403,563,417
		dd	EnvCurveHorzZoomMinus
		dw	542,418,552,432
		dd	EnvCurveVertZoomPlus
		dw	553,418,563,432
		dd	EnvCurveVertZoomMinus
		dw	232,350,512,416
		dd	SelectEnvCurveFirst
		dw	520,368,527,399
		dd	EnvelopeDragbar
		dw	251,437,316,453
		dd	EffectApply



		dw	243,159,315,175
		dd	SetTimeVar
		dw	316,159,402,175
		dd	SetTimeInvar
		dw	520,203,527,234
		dd	MasterDragbar
		dw	75,104,85+90,115
		dd	NoSmooth
		dw	75,117,85+90,127
		dd	C4Smooth
		dw	75,130,85+90,141
		dd	FixedSmooth
		dw	131,158,144,174
		dd	SmoothArrowUp
		dw	151,158,164,174
		dd	SmoothArrowDown
		dw	145,158,150,174
		dd	SmoothUdrag
		dw	85,158,129,174
		dd	SmoothInput
		dw	317,437,415,453
		dd	PreviewEditEffect
		dw	230,254,250,265
		dd	MasterCurveLeft
		dw	493,254,513,265
		dd	MasterCurveRight
		dw	518,185,529,199
		dd	MasterCurveUp
		dw	518,238,529,252
		dd	MasterCurveDown
		dw	542,253,552,267
		dd	MasterCurveZoomIn
		dw	553,253,563,267
		dd	MasterCurveZoomOut
		dw	232,187,511,250
		dd	MasterCurveSelectFirst
		dw	211,54,224,70
		dd	TotalVoiceUp
		dw	231,54,244,70
		dd	TotalVoiceDown
		dw	225,54,230,70
		dd	TotalVoiceUdrag
		dw	165,54,209,70
		dd	TotalVoicesInput
		dw	68,295,195,307
		dd	MouseEnvDelay
		dw	68,308,195,320
		dd	MouseEnvPitch
		dw	68,321,195,333
		dd	MouseEnvVolume
		dw	68,334,195,345
		dd	MouseEnvTime
		dw	476,437,561,453
		dd	EffectCancel
		dw	416,437,475,453
		dd	EffectOkay
		dw	165,36,393,52
		dd	ChangeEffectName
		dw	195,274,208,290
		dd	VoiceEnvNumUp
		dw	215,274,228,290
		dd	VoiceEnvNumDown
		dw	209,274,214,290
		dd	VoiceEnvUdrag
		dw	148,274,193,290
		dd	VoiceEnvInput
		dw	240,275,360,287
		dd	VoiceRepeatOnOff
		dw	243,288,360,299
		dd	VoiceReverbOnOff
		dw	243,301,360,312
		dd	VoiceBWDOnOff
		dw	515,329,528,345
		dd	PrintVoiceOffUp
		dw	535,329,548,345
		dd	PrintVoiceOffDown
		dw	529,329,534,345
		dd	VoiceOffUdrag
		dw	187,185,200,201
		dd	VoiceMastNumUp
		dw	207,185,220,201
		dd	VoiceMastNumDown
		dw	201,185,206,201
		dd	VoiceMastUdrag
		dw	71,223,220,235
		dd	MouseMastDelay
		dw	71,236,220,248
		dd	MouseMastPitch
		dw	71,250,220,261
		dd	MouseMastVolume
		dw	141,185,185,201
		dd	VoiceMastInput
		dw	187,203,200,219
		dd	MasterArrowUp
		dw	207,203,220,219
		dd	MasterArrowDown
		dw	201,203,206,219
		dd	MasterUdrag
		dw	233,115,344,128
		dd	BreakButtSamp
		dw	233,129,344,142
		dd	BreakButtVoice
		dw	402,116,527,128
		dd	BreakButtDelay
		dw	402,129,527,141
		dd	BreakButtPitch
		dw	402,142,527,155
		dd	BreakButtVolume
		dw	467,159,480,175
		dd	VoiceBreakUp
		dw	487,159,500,175
		dd	VoiceBreakDown
		dw	481,159,486,175
		dd	VoiceBreakUdrag
		dw	-1

vieweffecteditmouse2	 label word

		dw	317,437,415,453
		dd	PreviewEditEffect
		dw	230,254,250,205
		dd	MasterCurveLeft
		dw	493,254,513,265
		dd	MasterCurveRight
		dw	518,185,529,199
		dd	MasterCurveUp
		dw	518,238,529,252
		dd	MasterCurveDown
		dw	542,253,552,267
		dd	MasterCurveZoomIn
		dw	553,233,563,267
		dd	MasterCurveZoomOut
		dw	232,187,511,250
		dd	MasterCurveSelect
		dw	211,54,224,70
		dd	TotalVoiceUp
		dw	231,54,244,70
		dd	TotalVoiceDown
		dw	225,54,230,70
		dd	TotalVoiceUdrag
		dw	165,54,209,70
		dd	TotalVoicesInput
		dw	331,377,341+100,388
		dd	NoRealPitch
		dw	331,390,341+100,401
		dd	C_4RealPitch
		dw	331,403,341+100,414
		dd	FixedRealPitch
		dw	75,377,85+100,388
		dd	NoTimeCompress
		dw	75,390,85+100,401
		dd	C_4TimeCompress
		dw	75,403,85+100,413
		dd	FixedTimeCompress
		dw	243,417,256,433
		dd	SampsToReadArrowUp
		dw	263,417,276,433
		dd	SampsToReadArrowDown
		dw	257,417,262,433
		dd	SampsToReadUdrag
		dw	197,417,241,433
		dd	SampsToReadInput
		dw	243,435,256,451
		dd	SampsToSkipArrowUp
		dw	263,435,276,451
		dd	SampsToSkipArrowDown
		dw	257,435,262,451
		dd	SampsToSkipUdrag
		dw	197,435,241,451
		dd	SampsToSkipInput
		dw	467,416,480,432
		dd	RealPitchArrowUp
		dw	487,416,500,432
		dd	RealPitchArrowDown
		dw	481,416,486,432
		dd	RealPitchUdrag
		dw	421,416,465,432
		dd	RealPitchInput


		dw	243,159,315,175
		dd	SetTimeVar
		dw	316,159,402,175
		dd	SetTimeInvar
		dw	520,203,527,234
		dd	MasterDragbar
		dw	75,104,85+90,115
		dd	NoSmooth
		dw	75,117,85+90,127
		dd	C4Smooth
		dw	75,130,85+90,141
		dd	FixedSmooth
		dw	131,158,144,174
		dd	SmoothArrowUp
		dw	151,158,164,174
		dd	SmoothArrowDown
		dw	145,158,150,174
		dd	SmoothUdrag
		dw	85,158,129,174
		dd	SmoothInput
		dw	68,295,195,307
		dd	MouseEnvDelay
		dw	68,308,195,320
		dd	MouseEnvPitch
		dw	68,321,195,333
		dd	MouseEnvVolume
		dw	68,334,195,345
		dd	MouseEnvTime
		dw	476,437,561,453
		dd	EffectCancel
		dw	416,437,475,453
		dd	EffectOkay
		dw	165,36,393,52
		dd	ChangeEffectName
		dw	195,274,208,290
		dd	VoiceEnvNumUp
		dw	215,274,228,290
		dd	VoiceEnvNumDown
		dw	209,274,214,290
		dd	VoiceEnvUdrag
		dw	148,274,193,290
		dd	VoiceEnvInput
		dw	240,275,360,287
		dd	VoiceRepeatOnOff
		dw	243,288,360,299
		dd	VoiceReverbOnOff
		dw	243,301,360,312
		dd	VoiceBWDOnOff
		dw	515,329,528,345
		dd	PrintVoiceOffUp
		dw	535,329,548,345
		dd	PrintVoiceOffDown
		dw	529,329,534,345
		dd	VoiceOffUdrag
		dw	187,185,200,201
		dd	VoiceMastNumUp
		dw	207,185,220,201
		dd	VoiceMastNumDown
		dw	201,185,206,201
		dd	VoiceMastUdrag
		dw	71,223,220,235
		dd	MouseMastDelay
		dw	71,236,220,248
		dd	MouseMastPitch
		dw	71,250,220,261
		dd	MouseMastVolume
		dw	141,185,185,201
		dd	VoiceMastInput
		dw	187,203,200,219
		dd	MasterArrowUp
		dw	207,203,220,219
		dd	MasterArrowDown
		dw	201,203,206,219
		dd	MasterUdrag
		dw	233,115,344,128
		dd	BreakButtSamp
		dw	233,129,344,142
		dd	BreakButtVoice
		dw	402,116,527,128
		dd	BreakButtDelay
		dw	402,129,527,141
		dd	BreakButtPitch
		dw	402,142,527,155
		dd	BreakButtVolume
		dw	467,159,480,175
		dd	VoiceBreakUp
		dw	487,159,500,175
		dd	VoiceBreakDown
		dw	481,159,486,175
		dd	VoiceBreakUdrag

		dw	-1


;ViewVolumeM	 dw	 -1 ;452,184,546,200
;		 dd	 volumeend
;		 dw	 452,167,546,183
;		 dd	 volumecalculate
;		 dw	 371,37,384,53
;		 dd	 volumestartup
;		 dw	 391,37,404,53
;		 dd	 volumestartdown
;		 dw	 385,37,390,53
;		 dd	 VolumePopStartUdrag
;		 dw	 371,58,384,74
;		 dd	 volumeendup
;		 dw	 391,58,404,74
;		 dd	 volumeenddown
;		 dw	 385,58,390,74
;		 dd	 VolumePopEndUdrag
;		 dw	 410,37,546,53
;		 dd	 volumesetendtostart
;		 dw	 333,37,369,53
;		 dd	 inputstartvolume
;		dw	333,58,369,74
;		 dd	 inputendvolume
;		dw	-1
ViewVolumeM	dw	452,184,546,200
		dd	volumeend
		dw	452,167,546,183
		dd	volumecalculate
		dw	371,37,387,53
		dd	volumestartup
		dw	388,37,404,53
		dd	volumestartdown
		dw	371,58,387,74
		dd	volumeendup
		dw	388,58,404,74
		dd	volumeenddown
		dw	410,37,546,53
		dd	volumesetendtostart
		dw	333,37,369,53
		dd	inputstartvolume
		dw	333,58,369,74
		dd	inputendvolume
		dw	-1
ViewMixM	dw	364,298,441,314
		dd	mixathemix
		dw	442,298,521,314
		dd	cancelthemix
		dw	260,271,273,287
		dd	mixsampleup
		dw	280,271,293,287
		dd	mixsampledown
		dw	274,271,279,287
		dd	MixSampleStartUdrag
		dw	260,295,273,311
		dd	mixclipup
		dw	280,295,293,311
		dd	mixclipdown
		dw	274,295,279,311
		dd	MixSampleEndUdrag
		dw	220,271,256,287
		dd	InputMixaSamp
		dw	220,295,256,311
		dd	InputMixaClip
		dw	-1

ViewPop20M	dw	223,296,281,314
		dd	Pop_up_yes
		dw	282,296,336,314
		dd	Pop_up_no
		dw	337,296,414,314
		dd	Pop_up_cancel
		dw	-1

ViewPop22M	dw	223,236,281,254
		dd	Pop_up_yes
		dw	282,236,336,254
		dd	Pop_up_no
		dw	337,236,414,254
		dd	Pop_up_cancel
		dw	-1

PullDownPopUp	dw	-1

PopUpKeys	dw	557,246,625,262
		dd	Keysend
		dw	614, 30,625, 44
		dd	KeysarrowUp
		dw	614,227,625,241
		dd	KeysarrowDown
		dw	616, 48,623,223
		dd	KeyConfigDrag
		dw	143, 31,607,238
		dd	ChangeKey
		dw	9,32,138,238
		dd	KeySectionSelect
		dw	445,246,475,262
		dd	VSKeyMap
		dw	477,246,507,262
		dd	FT2KeyMap
		dw	509,246,539,262
		dd	ST3KeyMap
		dw	-1

SplitPop	dw	240, 98,251,112
		dd	Split_SplitArrowUp
		dw	275, 98,286,112
		dd	Split_SplitArrowDn
		dw	240,115,251,129
		dd	Split_ZoneArrowUp
		dw	275,115,286,129
		dd	Split_ZoneArrowDn
		dw	240,132,251,146
		dd	Split_SampleArrowUp
		dw	283,132,294,146
		dd	Split_SampleArrowDn

		dw	360, 98,371,112
		dd	Split_KBD1ArrowUp
		dw	403, 98,414,112
		dd	Split_KBD1ArrowDn
		dw	360,115,371,129
		dd	Split_KBD2ArrowUp
		dw	403,115,414,129
		dd	Split_KBD2ArrowDn
		dw	360,132,371,146
		dd	Split_KBDStartArrowUp
		dw	403,132,414,146
		dd	Split_KBDStartArrowDn

		dw	517, 97,591,113
		dd	Split_ClearAll
		dw	517,115,591,131
		dd	Split_SwitchActive
		dw	517,133,591,149
		dd	PopUp_Cancel3

		dw	376,100,398,110
		dd	PopUp_KBD1
		dw	376,117,398,127
		dd	PopUp_KBD2
		dw	376,134,398,144
		dd	PopUp_BaseNote
		dw	-1

PopupColors	dw	401,179,461,196
		dd	_ColorsendCancel
		dw	343,179,400,196
		dd	DoReset
		dw	365,151,378,168
		dd	ColorPreDef
		dw	381,151,395,168
		dd	ColorPreDef
		dw	397,151,410,168
		dd	ColorPreDef
		dw	413,151,426,168
		dd	ColorPreDef
		dw	462,179,512,196
		dd	_Colorsend
		dw	115,66,280,189
		dd	ColorSelect
		dw	367,66,387,77
		dd	ColorLeft1
		dw	367,80,387,91
		dd	ColorLeft2
		dw	367,94,387,105
		dd	ColorLeft3
		dw	367,108,387,119
		dd	ColorLeft4
		dw	492,66,512,77
		dd	ColorRight1
		dw	492,80,512,91
		dd	ColorRight2
		dw	492,94,512,105
		dd	ColorRight3
		dw	492,108,512,119
		dd	ColorRight4
		dw	-1

CoX		equ	80
CoY		equ	20
MouseOption	dw	CoX+397,Coy+358,CoX+464,CoY+374
		dd	OptionEnd
		dw	CoX+294,Coy+39 ,CoX+305,CoY+218
		dd	OptionDrag1
		dw	CoX+453,Coy+267,CoX+464,CoY+329
		dd	OptionDrag2
		dw	CoX+294,Coy+23 ,CoX+305,CoY+37
		dd	OptionArrowup
		dw	CoX+294,Coy+220,CoX+305,CoY+234
		dd	OptionArrowdown
		dw	CoX+157,Coy+25 ,CoX+289,CoY+232
		dd	OptionSelect
		dw	CoX+454,Coy+251,CoX+465,CoY+265
		dd	Option_Up
		dw	CoX+454,Coy+331,CoX+465,CoY+345
		dd	Option_Down
		dw	CoX+317,Coy+25 ,CoX+449,CoY+232
		dd	SwitchSelect
		dw	89,45,206,392
		dd	SectionSelect
		dw	-1

ViewTextMouse	dw	501,182,555,200
		dd	Popup_okay
		dw	-1

ViewTheSample2	dw	495,229,557,245
		dd	thesampleend
		dw	243,112,297,128
		dd	SetTheNote
		dw	243,129,297,145
		dd	SetTheRate

		dw	280,186,300,197
		dd	VolLeft1
		dw	280,203,300,214
		dd	VolLeft2
		dw	371,186,391,197
		dd	VolRight1
		dw	371,203,391,214
		dd	VolRight2

		dw	431,116,543,127
		dd	SampleSetScopes
		dw	431,129,543,140
		dd	SampleSetEqualizer
		dw	431,148,543,158
		dd	SampStereo_Mono
		dw	431,160,543,171
		dd	Samp8_16Bits
		dw	431,178,543,189
		dd	SampleSetLinein
		dw	431,191,543,202
		dd	SampleSetMic
		dw	431,204,543,215
		dd	SampleSetCD

		dw	418,229,494,245
		dd	starttosamp
		dw	347,121,360,137
		dd	therateup
		dw	367,121,380,137
		dd	theratedown
		dw	304,124,344,137
		dd	rateinput
		dw	361,121,366,137
		dd	therateUdrag

		dw	74,147,121,163
		dd	CD_play
		dw	122,147,169,163
		dd	CD_pause
		dw	170,147,217,163
		dd	CD_stop
		dw	74,164,109,180
		dd	CD_rewback
		dw	110,164,145,180
		dd	CD_rewfwd
		dw	146,164,181,180
		dd	CD_skipback
		dw	182,164,217,180
		dd	CD_skipfwd
		dw	74,181,91,201
		dd	CD_openclose
		dw	 92,181,153,201
		dd	JumpCDpos
		dw	154,181,217,201
		dd	SaveCDpos
		dw	149,107,218,125
		dd	ChangeCDtime
		dw	104,207,124,218
		dd	CD_volumeDown
		dw	195,207,215,218
		dd	CD_volumeUp
		dw	318,229,417,245
		dd	SampleCDsync
		dw	347,155,381,171
		dd	PeakClear
		dw	-1

dosamplemouse	dw	475,151,529,169
		dd	endstarttosamp
		dw	-1

yfixM		dw	460,282,522,298
		dd	y_fixend
		dw	251,282,264,298
		dd	incynumberup
		dw	271,282,284,298
		dd	decynumberup
		dw	265,282,270,298
		dd	yfixudrag
		dw	205,282,249,298
		dd	inputyup
		dw	117,274,193,290
		dd	yfixmoveup
		dw	117,291,193,307
		dd	yfixmovedown
		dw	297,282,356,298
		dd	yfixflip
		dw	370,282,445,298
		dd	yfixcenter
		dw	-1

OptimPop	dw	204,61,258,79
		dd	OptimChanRem
		dw	204,87,258,105
		dd	OptimCommRem
		dw	204,113,258,131
		dd	OptimPattRem
		dw	204,152,258,170
		dd	OptimInstRem
		dw	260,61,331,79
		dd	OptimChanCom
		dw	260,87,331,105
		dd	OptimCommCom
		dw	260,113,331,131
		dd	OptimPattCom
		dw	260,152,331,170
		dd	OptimInstCom

		dw	447,152,498,170
		dd	OptimSelAll
		dw	499,152,555,170
		dd	OptimSelNone
		dw	447,113,498,131
		dd	OptimSelPatt
		dw	499,113,555,131
		dd	OptimSelSong

		dw	447,186,498,204
		dd	OptimOkay
		dw	499,186,555,204
		dd	Popup_cancel
		dw	-1


NewPullDownMouse dw	-1

OptimSaved	dw	357,128,413,146
		dd	Popup_Okay3
		dw	-1

NewVolMouse	dw	457,312,518,328
		dd	NewVolumeEnd
		dw	361,289,438,305
		dd	Maximizen
		dw	361,312,446,328
		dd	Normalizen
		dw	256,312,344,328
		dd	BreakIt
		dw	304,270,317,286
		dd	BreakUp
		dw	324,270,337,286
		dd	BreakDown
		dw	318,270,323,286
		dd	VolumePopBreakUdrag
		dw	136,312,231,328
		dd	VolumeCalculate
		dw	208,270,221,286
		dd	VolumeStartUp
		dw	228,270,241,286
		dd	VolumeStartDown
		dw	222,270,227,286
		dd	VolumePopStartUdrag
		dw	208,289,221,305
		dd	VolumeEndUp
		dw	228,289,241,305
		dd	VolumeEndDown
		dw	222,289,227,305
		dd	VolumePopEndUdrag
		dw	165,270,201,286
		dd	VolumeStartInput
		dw	165,289,201,305
		dd	VolumeEndInput
		dw	261,270,297,286
		dd	VolumeBreakInput
		dw	117,270,162,286
		dd	NewVolSetStart
		dw	117,289,162,305
		dd	NewVolSetEnd
		dw	462,268,476,284
		dd	VolFade1
		dw	477,268,491,284
		dd	VolFade2
		dw	492,268,506,284
		dd	VolFade3
		dw	507,268,521,284
		dd	VolFade4
		dw	462,285,476,301
		dd	VolFade5
		dw	477,285,491,301
		dd	VolFade6
		dw	-1

NewMarkMouse	dw	487,284,552,300
		dd	NewMarkEnd
		dw	228,132,380,148
		dd	M_StartToRepbeg
		dw	228,150,380,166
		dd	M_RependToEnd
		dw	228,168,380,184
		dd	M_RepbegToRepend
		dw	228,186,380,202
		dd	M_StartToPlaypeg
		dw	228,204,380,220
		dd	M_PlaypegToEnd
		dw	388,132,556,148
		dd	M_StartToMarkstart
		dw	388,150,556,166
		dd	M_StartToMarkend
		dw	388,168,556,184
		dd	M_MarkstartToEnd
		dw	388,186,556,202
		dd	M_MarkendToEnd
		dw	184,140,197,156
		dd	MarkOffsetStartUp
		dw	204,140,217,156
		dd	MarkOffsetStartDown
		dw	184,161,197,177
		dd	MarkOffsetEndUp
		dw	204,161,217,177
		dd	MarkOffsetEndDown
		dw	184,225,197,241
		dd	MarkTimeStartUp
		dw	204,225,217,241
		dd	MarkTimeStartDown
		dw	184,246,197,262
		dd	MarkTimeEndUp
		dw	204,246,217,262
		dd	MarkTimeEndDown
		dw	198,140,203,156
		dd	MarkOffsetStartUdrag
		dw	198,161,203,177
		dd	MarkOffsetEndUdrag
		dw	198,225,203,241
		dd	MarkTimeStartUdrag
		dw	198,246,203,262
		dd	MarkTimeEndUdrag
		dw	117,140,177,156
		dd	MarkOffsetStartInput
		dw	117,161,177,177
		dd	MarkOffsetEndInput
		dw	117,225,177,241
		dd	MarkTimeStartInput
		dw	117,246,177,262
		dd	MarkTimeEndInput
		dw	95,186,201,202
		dd	MarkOffsetCalc
		dw	95,271,201,287
		dd	MarkTimeCalc
		dw	-1
SoundcardCfg	dw	136,93,214,187
		dd	SoundCardSelect
		dw	376,224,439,239
		dd	SC_Update
		dw	440,224,502,239
		dd	Popup_Okay

		dw	349,90,362,196
		dd	SC_ArrUp

		dw	363,90,368,196
		dd	SC_UDrag

		dw	369,90,382,196
		dd	SC_ArrDn

		dw	396,93,490,104
		dd	SC_Button1
		dw	396,107,490,118
		dd	SC_Button2

		dw	461,144,474,160
		dd	SC_HertzArrUp
		dw	475,144,480,160
		dd	SC_HertzUDrag
		dw	481,144,494,160
		dd	SC_HertzArrDn
		dw	416,144,455,160
		dd	SC_HertzInput

		dw	206,226,226,237
		dd	DecAm
		dw	334,226,354,237
		dd	IncAm

		dw	-1

EffectsPopupMouse	Label	Word
		dw	476,432,561,448
		dd	SampleEffectsEnd
		dw	302,52,313,66
		dd	EffectMultiArrowUp
		dw	302,415,313,429
		dd	EffectMultiArrowDown
		dw	550,52,561,66
		dd	EffectSingleArrowUp
		dw	550,187,561,201
		dd	EffectSingleArrowDown
		dw	550,251,561,265
		dd	EffectListArrowUp
		dw	550,362,561,376
		dd	EffectListArrowDown
		dw	71,55,295,427
		dd	SelectMulti
		dw	319,55,543,198
		dd	SelectSingle
		dw	132,432,194,448
		dd	DelMulti
		dw	416,415,561,431
		dd	SaveEffectsToDisk
		dw	319,254,543,373
		dd	SelectList
		dw	416,432,475,448
		dd	SampEffectsOkay
		dw	423,203,495,219
		dd	EffectAddEffect
		dw	428,378,477,394
		dd	EffectDelEffect
		dw	69,432,131,448
		dd	NewMultiPopup
		dw	195,432,275,448
		dd	RenameMultiPopup
		dw	317,378,427,394
		dd	EffectSaveList
		dw	372,203,422,219
		dd	DelRealEffecten
		dw	507,220,561,236
		dd	EffectEdit
		dw	507,203,561,219
		dd	NewEffectEdit
		dw	317,203,371,219
		dd	PreviewSingleEffect
		dw	317,432,415,448
		dd	PreviewMultiEffect
		dw	304,70,311,411
		dd	MultiDragbar
		dw	552,70,559,183
		dd	SingleDragbar
		dw	552,269,559,357
		dd	ListDragbar
		dw	317,220,411,236
		dd	EffectAddMulti
		dw	-1


EchoEditorPopup dw	249,162,293,178
		dd	EchoEd_Wrap
		dw	339,162,379,178
		dd	EchoEd_Okay
		dw	380,162,437,178
		dd	EchoEd_Cancel

		dw	261,70,274,86
		dd	EchoEd_FromArrUp
		dw	281,70,294,86
		dd	EchoEd_FromArrDn
		dw	275,70,280,86
		dd	EchoEd_FromUDrag

		dw	389,70,402,86
		dd	EchoEd_ToArrUp
		dw	409,70,422,86
		dd	EchoEd_ToArrDn
		dw	403,70,408,86
		dd	EchoEd_ToUDrag

		dw	261,88,274,104
		dd	EchoEd_ChanArrUp
		dw	281,88,294,104
		dd	EchoEd_ChanArrDn
		dw	275,88,280,104
		dd	EchoEd_ChanUDrag

		dw	261,106,274,122
		dd	EchoEd_DelayArrUp
		dw	281,106,294,122
		dd	EchoEd_DelayArrDn
		dw	275,106,280,122
		dd	EchoEd_DelayUDrag

		dw	261,124,274,140
		dd	EchoEd_RateArrUp
		dw	281,124,294,140
		dd	EchoEd_RateArrDn
		dw	275,124,280,140
		dd	EchoEd_RateUDrag

		dw	405,106,418,122
		dd	EchoEd_Decay1ArrUp
		dw	425,106,438,122
		dd	EchoEd_Decay1ArrDn
		dw	419,106,424,122
		dd	EchoEd_Decay1UDrag

		dw	405,124,418,140
		dd	EchoEd_Decay2ArrUp
		dw	425,124,438,140
		dd	EchoEd_Decay2ArrDn
		dw	419,124,424,140
		dd	EchoEd_Decay2UDrag

		dw	196,162,210,178
		dd	EchoEd_PreDef1
		dw	212,162,226,178
		dd	EchoEd_PreDef2
		dw	228,162,241,178
		dd	EchoEd_PreDef3
ResamplePopupMouse	Label	Word
		dw	411,300,485,316
		dd	ResampleEnd
		dw	342,300,408,316
		dd	ResampleOkay
		dw	280,279,293,295
		dd	CurrUp
		dw	300,279,313,295
		dd	CurrDown
		dw	294,279,299,295
		dd	CurrUdrag
		dw	280,300,293,316
		dd	ResUp
		dw	300,300,313,316
		dd	ResDown
		dw	294,300,299,316
		dd	ResUdrag
		dw	456,279,469,295
		dd	RelUp
		dw	476,279,489,295
		dd	RelDown
		dw	470,279,475,295
		dd	RelUdrag
		dw	-1

EffectWaitPopupMouse	Label	Word
		dw	457,300,518,316
		dd	EffectWaitCancel
		dw	-1

HelpPopup	dw	205+HelpAddX,18+HelpAddY,284+HelpAddX,34+HelpAddY
		dd	HelpSearchInput
		dw	212,18+HelpAddY,267,34+HelpAddY
		dd	HelpSearch
		dw	275,18+HelpAddY,371,34+HelpAddY
		dd	HelpSearchNext
		dw	622+HelpAddX,57+HelpAddY,630+HelpAddX,373+HelpAddY
		dd	HelpScreenDrag
		dw	620+HelpAddX,39+HelpAddY,631+HelpAddX,53+HelpAddY
		dd	HelpScreenArrUp
		dw	620+HelpAddX,376+HelpAddY,631+HelpAddX,390+HelpAddY
		dd	HelpScreenArrDn
		dw	159+HelpAddX,47+HelpAddY,614+HelpAddX,384+HelpAddY
		dd	HelpHyperText
		dw	458+HelpAddX,18+HelpAddY,505+HelpAddX,34+HelpAddY
		dd	HelpIndex
		dw	506+HelpAddX,18+HelpAddY,545+HelpAddX,34+HelpAddY
		dd	HelpBack
		dw	502,399,553,415
		dd	Popup_Okay
		dw	-1

PattDefPopup	Label	Dword
		dw	325,82,338,98
		dd	ConfigMaxCmdArrowUp
		dw	339,82,344,98
		dd	ConfigMaxCmdUDrag
		dw	345,82,358,98
		dd	ConfigMaxCmdArrowDn

		dw	325,100,338,116
		dd	ConfigMaxChArrowUp
		dw	339,100,344,116
		dd	ConfigMaxChUDrag
		dw	345,100,358,116
		dd	ConfigMaxChArrowDn

		dw	325,118,338,134
		dd	ConfigMaxRowArrowUp
		dw	339,118,344,134
		dd	ConfigMaxRowUDrag
		dw	345,118,358,134
		dd	ConfigMaxRowArrowDn

		dw	296,85,319,96
		dd	ConfigMaxCmdInput
		dw	296,103,319,114
		dd	ConfigMaxChInput
		dw	296,121,319,132
		dd	ConfigMaxRowInput

		dw	282,151,358,167
		dd	Popup_Okay
		dw	-1

ConfigPathPopup dw	380,228,433,244
		dd	CP_Exit
		dw	192,77,243,141
		dd	CPChoice
		dw	269,74,297,216
		dd	CPPath
		dw	301,74,433,216
		dd	CPInput
		dw	-1

EQEdPopup	dw	312,256,360,272
		dd	EQ_Okay
		dw	361,256,424,272
		dd	EQ_Cancel
		dw	312,231,416,247
		dd	EQ_SetDef
		dw	200,48,303,271
		dd	EQEdSquare
		dw	312,207,368,223
		dd	EQEdClear
		dw	369,207,416,223
		dd	EQEdFill
		dw	-1


MouseTable	dw	  0,  0,  1,  1
		dd	TrackerEnd
		dw	  0,  0,638, 16
		dd	RightMousePullPress
		dw	122, 18,135, 34
		dd	IncreasePosition
		dw	142, 18,155, 34
		dd	DecreasePosition
		dw	136, 18,141, 34
		dd	PosUDrag
		dw	122, 35,135, 51
		dd	IncreasePattern
		dw	142, 35,155, 51
		dd	DecreasePattern
		dw	136, 35,141, 51
		dd	PattUDrag
		dw	122, 52,135, 68
		dd	IncreaseLength
		dw	142, 52,155, 68
		dd	DecreaseLength
		dw	136, 52,141, 68
		dd	LenUDrag
		dw	122, 69,135, 85
		dd	IncreaseBPM
		dw	142, 69,155, 85
		dd	DecreaseBPM
		dw	136, 69,141, 85
		dd	BPMUDrag

		dw	  0, 69, 48, 85
		dd	IncDecSpd
		dw	 50, 69, 77, 85
		dd	ToggleBPM
		dw	 80, 18,118, 34
		dd	PositionInput
		dw	 80, 35,118, 51
		dd	PatternInput
		dw	 80, 52,118, 68
		dd	LengthInput
		dw	 80, 69,120, 85
		dd	BPMInput
		dw	-1

Equalizer1	Label	Dword
Equalizer2	Label	Dword
DiscOp		Label	Dword
		dw	  0, 0,638,16
		dd	RightMousePullPress
		dw	157,18,190,34
		dd	FlipUpper
		dw	160,42,558,183
		dd	FileListSquare
		dw	157,18,525,34
		dd	FileNameSquare
		dw	568,57,575,168
		dd	DiscOpDrag
		dw	566,39,577,53
		dd	DiscOpDragArrowUp
		dw	566,172,577,186
		dd	DiscOpDragArrowDn
		dw	580,35,633,51
		dd	GetName
		dw	580,55,633,66
		dd	ConvertSigned
		dw	580,68,633,79
		dd	FTLoop
		dw	580,81,633,92
		dd	PackSampOnOff
		dw	580,94,633,105
		dd	RealNameOnOff
		dw	580,107,633,118
		dd	AutoLoad
		dw	580,120,633,136
		dd	Rename
		dw	580,137,633,153
		dd	Delete
		dw	580,154,633,170
		dd	SaveModule
		dw	580,171,633,187
		dd	LoadModule
;		dw	580,188,633,204
;		dd	LoadModule
;		dw	580,205,633,221
;		dd	DiskOpExit

		dw	159,189,216,205
		dd	SetSong
		dw	160,189,272,205
		dd	SetPatt
		dw	159,206,216,222
		dd	SetInst
		dw	160,206,272,222
		dd	SetSamp

		dw	280,188,503,221
		dd	SetWildCard
		dw	507,188,562,204
		dd	Wild_All
		dw	507,205,562,221
		dd	Wild_Mix
		dw	-1

Config2 	Label	Dword
MainSquare	Label	Dword
		dw	  0, 0,638,16
		dd	RightMousePullPress
		dw	157,18,190,34
		dd	FlipUpper

		dw	156, 35,232, 51
		dd	PutSplitPopUpToScreen
		dw	156, 52,232, 68
		dd	ClearGadget
		dw	156, 69,232, 85
		dd	ViewOptimizePopup
		dw	156, 86,232,102
		dd	PutUpEchoEditor
		dw	156,103,232,119
		dd	InfoGadget
		dw	156,120,232,136
		dd	UndoGadget
		dw	156,137,232,153
		dd	TogglePiano
		dw	233,137,309,153
		dd	ToggleEQMouse

		dw	233, 35,309, 51
		dd	StartMod2
		dw	233, 52,309, 68
		dd	StartPatt2
		dw	233, 69,309, 85
		dd	RecSong2
		dw	233, 86,309,102
		dd	RecPatt2
		dw	233,103,309,119
		dd	StopMod2
		dw	233,120,309,136
		dd	EditMod

		dw	320, 53,327,118
		dd	MasterVolumeDrag
		dw	318, 35,329, 49
		dd	MasterVolumeArrowUp
		dw	318,122,329,136
		dd	MasterVolumeArrowDn
		dw	157,167,274,183
		dd	ChangeOctave
		dw	280,168,291,182
		dd	RowAdd
		dw	315,168,326,182
		dd	RowSub

		dw	624, 36,639,150
		dd	SampleNamesDrag
		dw	622, 18,633,32
		dd	DecreaseInstNames
		dw	622,154,633,168
		dd	IncreaseInstNames
		dw	341, 20,617,163
		dd	InstNameSquare
		dw	582,168,600,184
		dd	RemoveASample
		dw	601,168,619,184
		dd	AddAnEmptySample
		dw	411,170,436,182
		dd	ButtonShadowInst
		dw	437,170,462,182
		dd	ButtonCopyInst
		dw	463,170,489,182
		dd	ButtonMoveInst
		dw	490,170,516,182
		dd	KillInstrument2

		dw	376,186,615,202
		dd	InputModName
		dw	376,204,615,216
		dd	InputComposer
		dw	-1

PianoSquare	Label	Byte
		dw	184,187,631,220
		dd	PianoPressed
		dw	158,187,180,203
		dd	SetHi
		dw	158,204,180,220
		dd	SetLo
		dw	-1

EQSquare	Label	Byte
		dw	157,192,635,221
		dd	PressEQ
		dw	-1

SampleSquare	Label	Byte
		dw	  0, 0,638,16
		dd	RightMousePullPress
		dw	-1

PosEditor	Label Dword
		dw	116,115,155,131
		dd	PositionEditorIns
		dw	116,132,155,148
		dd	PositionEditorDel
		dw	96,133,103,184
		dd	PositionEdPositionDrag
		dw	94,115,105,129
		dd	DecreaseStartPosition
		dw	94,188,105,202
		dd	IncreaseStartPosition
		dw	  8,117, 48,199
		dd	PosEditorSquarePositions
		dw	 56,117, 88,199
		dd	PosEditorSquare
		dw	 32,206,111,220
		dd	PosititonPatternName
		dw	3,88,36,104
		dd	FlipUpperLeft
		dw	-1

SongCfg 	Label	Word
		dw	3,88,36,104
		dd	FlipUpperLeft
		dw	12,115,124,126
		dd	SetLinFreq
		dw	12,129,124,140
		dd	SetAmFreq
		dw	117,152,130,168
		dd	InitSpdArrUp
		dw	131,152,136,168
		dd	InitSpdUDrag
		dw	137,152,150,168
		dd	InitSpdArrDn
		dw	117,171,130,187
		dd	InitBPMArrUp
		dw	131,171,136,187
		dd	InitBPMUDrag
		dw	137,171,150,187
		dd	InitBPMArrDn
		dw	72,155,110,166
		dd	InitSpeedInput
		dw	72,173,110,184
		dd	InitBPMInput
		dw	-1

SampleInfo	Label Dword
		dw	122, 86,135,102
		dd	InstUp
		dw	142, 86,155,102
		dd	InstDn
		dw	136, 86,141,102
		dd	InstUDrag
		dw	122,120,135,136
		dd	IncreaseRepBeg
		dw	142,120,155,136
		dd	DecreaseRepBeg
		dw	136,120,141,136
		dd	RepBegUdrag
		dw	122,137,135,153
		dd	IncreaseRepEnd
		dw	142,137,155,153
		dd	DecreaseRepEnd
		dw	136,137,141,153
		dd	RepEndUdrag
		dw	122,154,135,170
		dd	IncreaseC2Rate
		dw	142,154,155,170
		dd	DecreaseC2Rate
		dw	136,154,141,170
		dd	C4RateUdrag2
		dw	122,171,135,187
		dd	IncreaseFineTune
		dw	142,171,155,187
		dd	DecreaseFineTune
		dw	136,171,141,187
		dd	FineTuneUdrag2
		dw	122,188,135,204
		dd	IncreasePanPot
		dw	142,188,155,204
		dd	DecreasePanPot
		dw	136,188,141,204
		dd	PanPotUdrag2
		dw	122,205,135,221
		dd	IncreaseVolume
		dw	142,205,155,221
		dd	DecreaseVolume
		dw	136,205,141,221
		dd	VolumeUdrag2

		dw	 96, 86,118,102
		dd	SampNrInput
		dw	 64,120,118,136
		dd	RepBegInput
		dw	 64,137,118,153
		dd	RepEndInput
		dw	  0,154, 73,170
		dd	SwitchC2Mode
		dw	 80,154,118,170
		dd	C2RateInput
		dw	 96,205,118,221
		dd	VolumeInput
		dw	3,88,36,104
		dd	FlipUpperLeft
		dw	-1


PattInfo	dw	122,103,135,119
		dd	InstUp
		dw	142,103,155,119
		dd	InstDn
		dw	136,103,141,119
		dd	InstUDrag

		dw	122,120,135,136
		dd	SampleUp
		dw	142,120,155,136
		dd	SampleDn
		dw	136,120,141,136
		dd	SampleUdrag

		dw	122,137,135,153
		dd	ChannelArrowUp
		dw	142,137,155,153
		dd	ChannelArrowDn
		dw	136,137,141,153
		dd	ChannelUDrag
		dw	122,154,135,170
		dd	CommandsArrowUp
		dw	142,154,155,170
		dd	CommandsArrowDn
		dw	136,154,141,170
		dd	CommandsUDrag
		dw	122,171,135,187
		dd	IncreasePatternLength
		dw	142,171,155,187
		dd	DecreasePatternLength
		dw	136,171,141,187
		dd	PattLenUDrag
		dw	122,188,135,204
		dd	IncreasePattern3
		dw	142,188,155,204
		dd	DecreasePattern3
		dw	136,188,141,204
		dd	Patt3UDrag

		dw	88,191,120,204
		dd	InputPattern
		dw	 32,206,111,220
		dd	PosititonPatternName
		dw	 96,105,118,121
		dd	SampNrInput2
		dw	104,137,120,153
		dd	ChannelInput
		dw	3,88,36,104
		dd	FlipUpperLeft
		dw	-1

YesNoUpMus	dw	247,128,305,146
		dd	Pop_up_Yes
		dw	306,128,360,146
		dd	Pop_up_No
		dw	-1

SampleEditor1	Label	Dword
		dw	3,226,19,257
		dd	FlipLower
		;dw	 3,289,28,321
		;dd	 SampEffectsStart

		dw	211,372,284,388  ;sample raw
		dd	StartTheSample
		dw	211,389,284,405
		dd	ResampleStart
		dw	211,406,284,422
		dd	NewVolumeStart
		dw	211,423,284,439
		dd	SampleEffectsStart
		dw	211,440,284,456
		dd	FixLoop
		dw	211,457,246,473
		dd	StartTheMix
		dw	247,457,284,473
		dd	Y_fixstart

		dw	85,457,157,473
		dd	DrawSamp
		dw	5,372,84,388
		dd	SamplePlayNU
		dw	3,226,19,257
		dd	_ret
		dw	297-4,383-5,347-4,394-5
		dd	SetNOREP
		dw	297-4,395-5,347-4,405-5
		dd	SetFWDREP
		dw	297-4,406-5,347-4,416-5
		dd	SetBWDREP
		dw	297-4,417-5,347-4,427-5
		dd	SetBIDIfREP
		dw	293,423,349,433
		dd	SetBIDIbREP
		dw	85,389,157,405
		dd	ZoomArea
		dw	85,372,157,388
		dd	ViewAll
		dw	85,406,157,422
		dd	ZoomOut
		dw	85,423,157,439
		dd	SampUndo
		dw	30,356,50,367
		dd	MoveCurveLeft
		dw	5,406,63,422
		dd	PlayFormAll
		dw	5,423, 63,439
		dd	PlayFormArea
		dw	5,440, 63,456
		dd	PlayFormScreen
		dw	5,457, 63,473
		dd	PlayFormOffset
		dw	613,356,633,367
		dd	MoveCurveRight
		;dw	 64,406,84,473
		;dd	 InvertLoop
		;dw	 211,372,282,388
		;dd	 NormalizeVolume
		dw	158,440,210,456
		dd	ZeroSample
		dw	158,457,210,473
		dd	PreserveSample
		dw	158,423,210,439
		dd	ClearSample
		dw	85,440,157,456
		dd	SampConvert
		dw	158,372,210,388
		dd	SampCut
		dw	158,389,210,405
		dd	SampCopy
		dw	158,406,210,422
		dd	SampPaste
		dw	5,372,84,388
		dd	SamplePlay
		dw	306,457,355,473
		dd	Convert8_16
		dw	285,440,355,456
		dd	NewMarkStart
		;dw	 211,389,282,405
		;dd	 volumestart
		;dw	 211,440,284,456
		;dd	 startthemix
		;dw	 211,423,284,439
		;dd	 y_fixstart
		dw	64,406,84,439
		dd	zoomplus
		dw	64,440,84,473
		dd	zoomminus
		dw	594,372,607,388
		dd	IncreaseRepBeg2
		dw	614,372,627,388
		dd	DecreaseRepBeg2
		dw	608,372,613,388
		dd	RepBegUdrag
		dw	594,389,607,405
		dd	IncreaseRepEnd2
		dw	614,389,627,405
		dd	DecreaseRepEnd2
		dw	608,389,613,405
		dd	RepEndUdrag
		dw	594,406,607,422
		dd	IncreaseC2Rate
		dw	614,406,627,422
		dd	DecreaseC2Rate
		dw	608,406,613,422
		dd	C4RateUdrag
		dw	594,423,607,439
		dd	IncreaseFineTune
		dw	614,423,627,439
		dd	DecreaseFineTune
		dw	608,423,613,439
		dd	FineTuneUdrag
		dw	594,440,607,456
		dd	IncreasePanPot
		dw	614,440,627,456
		dd	DecreasePanPot
		dw	608,440,613,456
		dd	PanpotUdrag
		dw	594,457,607,473
		dd	IncreaseVolume
		dw	614,457,627,473
		dd	DecreaseVolume
		dw	608,457,613,473
		dd	VolumeUdrag
		dw	458,372,471,388
		dd	SampleUp
		dw	478,372,491,388
		dd	SampleDn
		dw	472,372,477,388
		dd	SampleUdrag
		dw	458,389,471,405
		dd	SampPosUp
		dw	478,389,491,405
		dd	SampPosDown
		dw	472,389,477,405
		dd	SampPosUdrag
		dw	458,406,471,422
		dd	ValueUp
		dw	478,406,491,422
		dd	ValueDown
		dw	472,406,477,422
		dd	ValueUdrag
		dw	492,406,532,422
		dd	SwitchC2Mode
		dw	0,225,639,352
		dd	MarkScreenStart
		dw	397,372,457,388
		dd	SampInputen
		dw	397,389,457,405
		dd	PosInputen
		dw	397,406,457,422
		dd	ValueInputen
		dw	397,423,457,439
		dd	SmpSizeInputen
		dw	397,440,457,456
		dd	MarkSizeInputen
		dw	533,372,593,388
		dd	RepBegInputen
		dw	533,389,593,405
		dd	RepEndInputen
		dw	533,406,593,422
		dd	C4RateInputen
		dw	533,457,593,473
		dd	VolumeInputen
		dw	458,423,471,439
		dd	SampSizeArrowUp
		dw	478,423,491,439
		dd	SampSizeArrowDown
		dw	472,423,477,439
		dd	SampSizeUdrag
		dw	458,440,471,456
		dd	MarkSizeArrowUp
		dw	478,440,491,456
		dd	MarkSizeArrowDown
		dw	472,440,477,456
		dd	MarkSizeUdrag
		dw	5,389,84,405
		dd	ToggleTuneFork
		dw	458,457,471,473
		dd	SampRateUp
		dw	472,457,477,473
		dd	SampRateUdrag
		dw	478,457,491,473
		dd	SampRateDown
		dw	356,457,396,473
		dd	SampRateChange
		dw	397,457,457,473
		dd	SampleRateInput
		dw	-1


SampleEditor2	Label	Dword
		dw	-1
comment &
		dw	3,256,28,288
		dd	SampleEditorQuickStart
		dw	85,423,121,439
		dd	zoomplus
		dw	122,423,157,439
		dd	zoomminus
		dw	85,457,157,473
		dd	SampConvert
		dw	613,356,633,367
		dd	MoveCurveRight
		dw	85,372,157,388
		dd	ViewAll
		dw	85,406,157,422
		dd	ZoomOut
		dw	85,440,157,456
		dd	SampUndo
		dw	30,356,50,367
		dd	MoveCurveLeft
		dw	560,457,633,473
		dd	SampleEditorExit
		dw	85,389,157,405
		dd	ZoomArea
		dw	5,406, 63,422
		dd	PlayFormAll
		dw	  5,423, 63,439
		dd	PlayFormArea
		dw	  5,440, 63,456
		dd	PlayFormScreen
		dw	  5,457, 63,473
		dd	PlayFormOffset
		dw	 64,406, 84,473
		dd	InvertLoop
;		dw	 30,358,608,365
;		dd	Sampeditdrag
		dw	158,372,240,388
		dd	SampReverse
		dw	5,372,84,388
		dd	SamplePlay
		dw	5,389,84,405
		dd	SampleStop
		dw	168,389,250,405
		dd	samplecrossfade
		dw	21,225,639,352
		dd	MarkScreenStart
		dw	-1
&
CommentsEditor	Label	Dword
		dw	3,226,19,257
		dd	FlipLower
		dw	622,223,633,237
		dd	DescUp0
		dw	622,435,633,449
		dd	DescDown0
		dw	325,456,416,472
		dd	ChangeLineStatus
		dw	417,456,508,472
		dd	ChangeWordStatus
		dw	624,241,631,431
		dd	Desceditdrag
		dw	541,456,617,472
		dd	DescClear
		dw	-1

PT_Pattern1	Label	Dword
ST_Pattern1	Label	Dword
		dw	3,226,19,257
		dd	FlipLower
		dw	167,243,183,255
		dd	ChannelNr2
		dw	263,243,279,255
		dd	ChannelNr3
		dw	359,243,375,255
		dd	ChannelNr4
		dw	455,243,471,255
		dd	ChannelNr5
		dw	551,243,567,255
		dd	ChannelNr6
		dw	184,243,206,255
		dd	Mute2
		dw	280,243,302,255
		dd	Mute3
		dw	376,243,398,255
		dd	Mute4
		dw	472,243,494,255
		dd	Mute5
		dw	568,243,590,255
		dd	Mute6
		dw	207,243,216,255
		dd	IncreaseCmdNr2
		dw	303,243,312,255
		dd	IncreaseCmdNr3
		dw	399,243,408,255
		dd	IncreaseCmdNr4
		dw	495,243,504,255
		dd	IncreaseCmdNr5
		dw	591,243,600,255
		dd	IncreaseCmdNr6
		dw	128,223,216,239
		dd	ChannelName1
		dw	224,223,312,239
		dd	ChannelName2
		dw	320,223,408,239
		dd	ChannelName3
		dw	416,223,504,239
		dd	ChannelName4
		dw	512,223,600,239
		dd	ChannelName5

PT_Pattern2	Label	Dword
ST_Pattern2	Label	Dword
		dw	3,226,19,257
		dd	FlipLower
		dw	 71,243, 87,255
		dd	ChannelNr1
		dw	 88,243,110,255
		dd	Mute1
		dw	111,243,120,255
		dd	IncreaseCmdNr1
		dw	 32,223,120,239
		dd	ChannelName0
		dw	 31,261,599,461
		dd	MouseOnPattern


		dw	608,277,615,445
		dd	PatternDrag
		dw	624,277,631,445
		dd	PositionDrag
		dw	 31,466,599,479
		dd	ChannelDrag
		dw	622,259,633,273
		dd	DecreasePosition
		dw	622,449,633,463
		dd	IncreasePosition
		dw	606,259,617,273
		dd	ArrowUp
		dw	606,449,617,463
		dd	ArrowDown
		dw	606,465,626,476
		dd	IncChannel
		dw	  5,465, 25,476
		dd	DecChannel
		dw	606,223,634,239
		dd	MuteAll
		dw	606,241,634,257
		dd	UnMuteAll
		dw	-1


EnvelopEd	Label	Dword
		dw	3,226,19,257
		dd	FlipLower
		dw	8,266,264,331
		dd	VolumeEnvSquare
		dw	6,337,26,348
		dd	ScrollVolEnvelopeLeft
		dw	245,337,265,348
		dd	ScrollVolEnvelopeRight
		dw	96,245,107,261
		dd	VolEnvVolArrUp
		dw	139,245,150,261
		dd	VolEnvVolArrDn
		dw	152,245,163,261
		dd	VolEnvTimeArrUp
		dw	195,245,206,261
		dd	VolEnvTimeArrDn
		dw	270,245,284,261
		dd	VolEnvEnable
		dw	270,303,283,319
		dd	VolEnvLoopOnOff
		dw	270,332,283,348
		dd	VolEnvBreakLoopOnOff
		dw	288,303,299,319
		dd	VolEnvLoopStartArrUp
		dw	323,303,334,319
		dd	VolEnvLoopStartArrDn
		dw	288,332,299,348
		dd	VolEnvLoopEndArrUp
		dw	323,332,334,348
		dd	VolEnvLoopEndArrDn
		dw	32,245,43,261
		dd	VolEnvelopeSpeedUp
		dw	75,245,86,261
		dd	VolEnvelopeSpeedDn
		dw	288,245,299,261
		dd	VolEnvPointsArrUp
		dw	323,245,334,261
		dd	VolEnvPointsArrDn
		dw	288,274,299,290
		dd	VolEnvSustainArrUp
		dw	323,274,334,290
		dd	VolEnvSustainArrDn
		dw	270,274,284,290
		dd	VolSustainEnable
		dw	216,245,227,261
		dd	CurrVolPointUp
		dw	251,245,262,261
		dd	CurrVolPointDn

		dw	8,266+127,264,331+128
		dd	PanningEnvSquare
		dw	6,336+128,26,347+128
		dd	ScrollPanEnvelopeLeft
		dw	245,336+128,265,347+128
		dd	ScrollPanEnvelopeRight
		dw	96,245+127,107,261+127
		dd	PanEnvPanArrUp
		dw	139,245+127,150,261+127
		dd	PanEnvPanArrDn
		dw	152,245+127,163,261+127
		dd	PanEnvTimeArrUp
		dw	195,245+127,206,261+127
		dd	PanEnvTimeArrDn
		dw	270,245+127,284,261+128
		dd	PanEnvEnable
		dw	270,303+127,283,319+127
		dd	PanEnvLoopOnOff
		dw	270,332+127,283,348+127
		dd	PanEnvBreakLoopOnOff
		dw	288,303+127,299,319+127
		dd	PanEnvLoopStartArrUp
		dw	323,303+127,334,319+127
		dd	PanEnvLoopStartArrDn
		dw	288,331+128,299,347+128
		dd	PanEnvLoopEndArrUp
		dw	323,331+128,334,347+128
		dd	PanEnvLoopEndArrDn
		dw	32,245+127,43,261+127
		dd	PanEnvelopeSpeedUp
		dw	75,245+127,86,261+127
		dd	PanEnvelopeSpeedDn
		dw	288,245+127,299,261+127
		dd	PanEnvPointsArrUp
		dw	323,245+127,334,261+127
		dd	PanEnvPointsArrDn
		dw	288,274+127,299,290+127
		dd	PanEnvSustainArrUp
		dw	323,274+127,334,290+127
		dd	PanEnvSustainArrDn
		dw	270,274+127,284,290+127
		dd	PanEnvSustainEnable
		dw	216,245+127,227,261+127
		dd	CurrPanPointUp
		dw	251,245+127,262,261+127
		dd	CurrPanPointDn

		dw	596,356,609,372
		dd	IncRelNote
		dw	616,356,629,372
		dd	DecRelNote
		dw	610,356,615,372
		dd	RelNoteUDrag
		dw	596,331+42,609,347+42
		dd	FadeOutArrUp
		dw	616,331+42,629,347+42
		dd	FadeOutArrDn
		dw	610,331+42,615,347+42
		dd	FadeOutUDrag

;		dw	596,348+42,609,364+42
;		dd	VibSweepArrUp
;		dw	616,348+42,629,364+42
;		dd	VibSweepArrDn
;		dw	610,348+42,615,364+42
;		dd	VibSweepUDrag

		dw	47,247,71,259
		dd	VolumeSpeedInput
		dw	47,247+127,71,259+127
		dd	PanSpeedInput
		dw	567,375,591,387
		dd	FadeOutInput
		dw	565,356,593,372
		dd	InputRelNote
		dw	622,331,634,345
		dd	IncreaseSampleNames
		dw	622,245,634,259
		dd	DecreaseSampleNames
		dw	624,263,672,327
		dd	EnvEdSampleDrag
		dw	415,248,617,343
		dd	SampleNameSquare

		dw	2,355,30,371
		dd	SelectVibEnvelope
		dw	2,372,30,388
		dd	SelectPanEnvelope
		dw	343,245,357,261
		dd	LineVol
		dw	358,245,372,261
		dd	Sine1Vol
		dw	373,245,387,261
		dd	Sine2Vol
		dw	343,274,357,290
		dd	UseDefVol0
		dw	358,274,372,290
		dd	UseDefVol1
		dw	373,274,387,290
		dd	UseDefVol2
		dw	388,274,402,290
		dd	UseDefVol3
		dw	343,303,357,319
		dd	PreDefVol0
		dw	358,303,372,319
		dd	PreDefVol1
		dw	373,303,387,319
		dd	PreDefVol2
		dw	388,303,402,319
		dd	PreDefVol3
		dw	343,245+127,357,261+127
		dd	LinePan
		dw	358,245+127,372,261+127
		dd	Sine1Pan
		dw	373,245+127,387,261+127
		dd	Sine2Pan
		dw	343,274+127,357,290+127
		dd	UseDefPan0
		dw	358,274+127,372,290+127
		dd	UseDefPan1
		dw	373,274+127,387,290+127
		dd	UseDefPan2
		dw	388,274+127,402,290+127
		dd	UseDefPan3
		dw	343,303+127,357,319+127
		dd	PreDefPan0
		dw	358,303+127,372,319+127
		dd	PreDefPan1
		dw	373,303+127,387,319+127
		dd	PreDefPan2
		dw	388,303+127,402,319+127
		dd	PreDefPan3
		dw	343,332,357,348
		dd	ScaleVolXSub
		dw	358,332,372,348
		dd	ScaleVolXAdd
		dw	373,332,387,348
		dd	ScaleVolYSub
		dw	388,332,402,348
		dd	ScaleVolYAdd
		dw	343,332+127,357,348+127
		dd	ScalePanXSub
		dw	358,332+127,372,348+127
		dd	ScalePanXAdd
		dw	373,332+127,387,348+127
		dd	ScalePanYSub
		dw	388,332+127,402,348+127
		dd	ScalePanYAdd

		dw	413,347,438,359
		dd	ButtonCopySamp
		dw	439,347,465,359
		dd	ButtonMoveSamp
		dw	466,347,492,359
		dd	KillSample3

		dw	408,459,419,475
		dd	VibAmpArrowUp
		dw	443,459,454,475
		dd	VibAmpArrowDn

		dw	-1
		       ; 0	   1	   2	     3		 4	     5		 6	       7	    8	       9		 10		   11		  12
		      ; :PosinVal :Change :Totalval :Visibleval :ScreenposX :ScreenposY :Screenlength :Screenhigh :menu_popup :menu_downscreen :menu_upperscreen :menu_upperleft :proc_after_newoffset
DragBarData	dd	 0,	   1,	   5,	     2, 	 56,	     358,	 553,	       8,	    0,	       4,		-1,		  -1,		  updatesampthings	;Sample editor
		dd	 0,	   1,	   0,	     0, 	 56,	     358,	 553,	       8,	    0,	       5,		-1,		  -1,		  updatesampthings	;Sample effects
		dd	 0,	   1,	   0,	     6, 	 32,	     467,	 569,	       8,	    0,	       0,		-1,		  -1,		  UpdatePattDrag	;PatternDrag 1
		dd	 0,	   1,	   0,	     6, 	 32,	     467,	 569,	       8,	    0,	       1,		-1,		  -1,		  UpdatePattDrag	;PatternDrag 2
		dd	 0,	   1,	   0,	     1, 	 32,	     467,	 569,	       8,	    0,	       2,		-1,		  -1,		  UpdatePattDrag	;PatternDrag 3
		dd	 0,	   1,	   0,	     1, 	 32,	     467,	 569,	       8,	    0,	       3,		-1,		  -1,		  UpdatePattDrag	;PatternDrag 4
		dd	 0,	   1,	   0,	   256, 	 32,	     339,	 209,	       8,	    0,	       7,		-1,		  -1,		  UpdateEnvVolDrag	;Vol Envelope
		dd	 0,	   1,	   0,	   256, 	 32,	     466,	 209,	       8,	    0,	       7,		-1,		  -1,		  UpdateEnvPanDrag	;Pan Envelope
		dd	 0,	   1,	   240+15,    16,	 232,	     228,	 97,	       8,	   28,	      -1,		-1,		  -1,		  UpdateAmplify 	;Amplify
CD_volumen	dd	 255,	   1,	   256+50,    51,	 128,	     209,	 65,	       8,	   13,	      -1,		-1,		  -1,		  UpdateCDVol		;volume for cd
 LeftInput	dd	 128,	   1,	   256+50,    51,	 304,	     188,	 65,	       8,	   13,	      -1,		-1,		  -1,		  UpdateInpVol		;left input vol (MONO)
RightInput	dd	 128,	   1,	   256+50,    51,	 304,	     205,	 65,	       8,	   13,	      -1,		-1,		  -1,		  UpdateInpVol		;right input vol
MastCurveHorz1	dd	 0,	   1,	   1,	      35,	 256,	     256,	 233,	       8,	   39,	      -1,		-1,		  -1,		  UpdateMastCurveX1	;master curve x with env
MastCurveHorz2	dd	 0,	   1,	   1,	      35,	 256,	     256,	 233,	       8,	   41,	      -1,		-1,		  -1,		  UpdateMastCurveX2	;master curve x with time c.
EnvCurveHorz	dd	 0,	   1,	   1,	      35,	 256,	     421,	 233,	       8,	   39,	      -1,		-1,		  -1,		  UpdateEnvCurveX	;envelope curve x with time c.

		;This must be in the end of the table.
SDBAR1		dd	 0,	   1,  64+11,	    12, 	 392,	      68,	  96,	       8,	   10,	      -1,		-1,		  -1,		  UpdateTheColors2	 ;R in colors
SDBAR2		dd	 0,	   1,  64+11,	    12, 	 392,	      82,	  96,	       8,	   10,	      -1,		-1,		  -1,		  UpdateTheColors2	 ;R in colors
SDBAR3		dd	 0,	   1,  64+11,	    12, 	 392,	      96,	  96,	       8,	   10,	      -1,		-1,		  -1,		  UpdateTheColors2	 ;R in colors
SDBAR4		dd	 0,	   1,  64+11,	    12, 	 392,	     110,	  96,	       8,	   10,	      -1,		-1,		  -1,		  UpdateTheColors2	 ;R in colors
		dd	-100

DragbarStatus	db	25 dup(1)

			;0           2   4       6         10  14         18        20     22
		       	;Scr.Pos    |Len|Vis.Val|Tot. Val.|Pos|DB Len*128|DB ScrPos|Ystart|YEnd
DragbarTable	dw	277*80+608/8,169,15, 64,0,   0,0, 0,0, 1, 277,445  ;Pattern
		dw	277*80+624/8,169, 1,  0,0,   0,0, 0,0, 1, 277,445  ;Positions
		dw	 36*80+624/8,115,12,  0,0,   0,0, 0,0, 1,  36,150  ;SampleNames
		dw	 467*80+32/8,568, 6,  0,0,   0,0, 0,0, 1,  31,598  ;Channels
		dw	 57*80+568/8,112,12,  0,0,   0,0, 0,0, 1,  57,168  ;FileNames
		dw	 53*80+320/8, 66, 1,127,0, 127,0, 0,0, 1,  53,119  ;MasterVolume
		dw	 358*80+30/8,519, 0,  0,0,   0,0, 0,0, 1,  30,608  ;SampleEdit
		dw	 133*80+96/8, 52, 7,  0,0,   0,0, 0,0, 1, 133,184  ;PosEdPositions
		dw	241*80+624/8,191,17,  0,0,   0,0, 0,0, 1, 241,431  ;Desc editor
		dw	 48*80+616/8,176,16,  0,0,   0,0, 0,0, 1,  48,223  ;Keys Config
		dw	 70*80+10,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+12,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+14,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+16,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+18,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+20,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+22,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+24,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+26,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+28,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+30,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+32,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+34,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+36,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+38,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+40,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+42,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+44,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+46,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+48,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+50,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+52,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+54,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+56,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+58,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+60,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	 70*80+62,98,barsize,64+barsize-1,0,0,0,0,0,1,70,167
		dw	61*80+376/8 ,176,16,  0,0,  0,0,  0,0, 1,  61,236		;Option bar 1
		dw	289*80+536/8, 59, 7,  0,0,  0,0,  0,0, 1, 289,347		;Option bar 2
		dw	263*80+624/8, 64, 8,  0,0,  0,0,  0,0, 1, 263,327		;SampleNames
;		dw	57*80+616/8+(HelpAddY*80+HelpAddX/8),147,13,  0,0,   0,0, 0,0, 1, 57+HelpAddY,203+HelpAddY  ;Help
		dw	57*80+616/8+(HelpAddY*80+HelpAddX/8),316,26,  0,0,   0,0, 0,0, 1, 57+HelpAddY,372+HelpAddY  ;Help
	     ;Scr.Pos|Len|Visible Values|Total Values|Pos in Val.|DB Len*128|DB ScrPos|Ystart|YEnd
		dw	304/8+70*80, 342, 31, 0,0,  0,0,  0,0, 1, 70, 411
		dw	552/8+70*80, 114, 12, 0,0,  0,0,  0,0, 1, 70, 183
		dw	552/8+269*80, 89, 10, 0,0,  0,0,  0,0, 1, 269,357
		dw	520/8+203*80, 32, 0,  62500,0,	0,0,  0,0, 1, 203,234
		dw	520/8+368*80, 32, 0,  62500,0,	0,0,  0,0, 1, 368,399
barsize 	equ	20

KeyBoardLayout1 dd	SV_KBD,US_KBD
KeyBoardLayout2 dd	SV_SHF,US_SHF
KeyBoardLayout3 dd	SV_AGR,US_AGR

Keyboard_Table	dd	SV_KBD
Keyboard_Shift	dd	SV_SHF
Keyboard_AltGR	dd	SV_AGR


SV_KBD	db	02,"1",03,"2",04,"3",05,"4",06,"5",07,"6",08,"7",09,"8",10,"9"
	db	11,"0",12,"+",13,"'",16,"q",17,"w",18,"e",19,"r",20,"t",21,"y"
	db	22,"u",23,"i",24,"o",25,"p",26,"†",27,"^",30,"a",31,"s",32,"d"
	db	33,"f",34,"g",35,"h",36,"j",37,"k",38,"l",39,"”",40,"„",43,"'"
	db	44,"z",45,"x",46,"c",47,"v",48,"b",49,"n",50,"m",51,",",52,"."
	db	53,"-",57," ",86,"<",41,"",0

SV_SHF	db	02,"!",03,'"',04,"#",05,"$",06,"%",07,"&",08,"/",09,"(",10,")"
	db	11,"=",12,"?",13,"`",16,"Q",17,"W",18,"E",19,"R",20,"T",21,"Y"
	db	22,"U",23,"I",24,"O",25,"P",26,"",27,"^",30,"A",31,"S",32,"D"
	db	33,"F",34,"G",35,"H",36,"J",37,"K",38,"L",39,"™",40,"Ž",43,"*"
	db	44,"Z",45,"X",46,"C",47,"V",48,"B",49,"N",50,"M",51,";",52,":"
	db	53,"_",57," ",86,">",41,"«",0

SV_AGR	db	03,"@",04,"œ",05,"$",08,"{",09,"[",10,"]",11,"}",12,"\",0

US_KBD	db	02,"1",03,"2",04,"3",05,"4",06,"5",07,"6",08,"7",09,"8",10,"9"
	db	11,"0",12,"-",13,"=",16,"q",17,"w",18,"e",19,"r",20,"t",21,"y"
	db	22,"u",23,"i",24,"o",25,"p",26,"[",27,"]",30,"a",31,"s",32,"d"
	db	33,"f",34,"g",35,"h",36,"j",37,"k",38,"l",39,";",40,"'",43,"\"
	db	44,"z",45,"x",46,"c",47,"v",48,"b",49,"n",50,"m",51,",",52,"."
	db	53,"/",57," ",86,"<",41,"`",0

US_SHF	db	02,"!",03,'@',04,"#",05,"$",06,"%",07,"^",08,"&",09,"*",10,"("
	db	11,")",12,"_",13,"+",16,"Q",17,"W",18,"E",19,"R",20,"T",21,"Y"
	db	22,"U",23,"I",24,"O",25,"P",26,"{",27,"}",30,"A",31,"S",32,"D"
	db	33,"F",34,"G",35,"H",36,"J",37,"K",38,"L",39,":",40,'"',43,"\"
	db	44,"Z",45,"X",46,"C",47,"V",48,"B",49,"N",50,"M",51,"<",52,">"
	db	53,"?",57," ",86,">",41,"~",0
US_AGR	db	0

PopUpTableKeys	dd	PopUpKeys1,PopUpKeys2,PopUpKeys3,PopUpKeys4,Popupinfoshit3,PopupClearKeys,Pulldownkeys,PopUpKeys1,Splitkeys,PopupColors2,KeyOption,ViewTextKey,Popupthesample,dosamplekeys,PopUpKeys1,Viewpop16K,Viewpop17K,ViewvolumeK,viewmixK,viewpop20K,yfixK,OptimKey,NewPullDownKey,OptimSavedKey,PopUpkeys2,NewVolKeys,NewMarkKeys,PopUpKeys1,EffectsPopupKeys,0,EchoEditorPopupKeys,HelpPopupKeys,PattDefPopupKeys,ResamplePopupKeys,EffectWaitPopupKeys,ConfigPathPopupKeys,Viewpop17K,viewnewmultikeys,effecteditkeys,viewpop22K,effecteditkeys2,EQEdPopupKeys

PopUpKeys1	db	28
		dd	Popup_okay2
		db	89
		dd	Popup_okay2
		db	 1
		dd	PopUp_okay2
		db	-1

PopUpKeys2	db	28
		dd	Pop_up_yes2
		db	89
		dd	Pop_up_yes2
		db	21
		dd	Pop_up_yes2
		db	 1
		dd	Pop_up_no2
		db	49
		dd	Pop_up_no2
		db	-1

PopUpKeys3	db	28
		dd	PopUp_Yes2
		db	89
		dd	PopUp_Yes2
		db	21
		dd	PopUp_Yes2
		db	49
		dd	PopUp_No2
		db	30
		dd	PopUp_All2
		db	 1
		dd	PopUp_Cancel2
		db	46
		dd	PopUp_Cancel2
		db	-1

PopUpKeys4	db	28
		dd	PopUp_Yes2   ;Rename
		db	89
		dd	PopUp_Yes2
		db	19
		dd	PopUp_Yes2
		db	31
		dd	PopUp_No2    ;Skip
		db	 1
		dd	PopUp_Cancel2
		db	46
		dd	PopUp_Cancel2
		db	-1

PopupInfoShit3	db	28
		dd	Popup_okay2
		db	89
		dd	PopUp_okay2
		db	 1
		dd	PopUp_okay2
		db	-1

PopupClearKeys	db	28
		dd	PopUp_Cancel2
		db	89
		dd	PopUp_Cancel2
		db	 1
		dd	PopUp_Cancel2
		db	31
		dd	PopUp_Song2
		db	30
		dd	PopUp_All2
		db	31
		dd	PopUp_Samp2
		db	-1

PulldownKeys	db	-1

SplitKeys	db	1
		dd	PopUp_Cancel4
		db	28
		dd	PopUp_Cancel4
		db	89
		dd	PopUp_Cancel4
		db	59
		dd	OctaveDn
		db	60
		dd	OctaveUp
		db	-1

PopupColors2	db	 1
		dd	ColorsEnd2
		db	-1

KeyOption	db	 1
		dd	Optionend2
		db	-1

ViewTextKey	db	28
		dd	Popup_okay2
		db	89
		dd	Popup_okay2
		db	 1
		dd	PopUp_okay2
		db	-1

PopUptheSample	db	1
		dd	thesampleend2
		db	-1

dosamplekeys	db	1
		dd	endstarttosamp2
		db	-1
Viewpop16K	db	28
		dd	Popup_okay2
		db	89
		dd	Popup_okay2
		db	 1
		dd	PopUp_okay2
		db	-1

Viewpop17K	db	28
		dd	Pop_up_yes2
		db	89
		dd	Pop_up_yes2
		db	21
		dd	Pop_up_yes2
		db	 1
		dd	Pop_up_no2
		db	49
		dd	Pop_up_no2
		db	-1

viewnewmultikeys db	28
		dd	OkayNewMultiEffect2
		db	89
		dd	OkayNewMultiEffect2
		db	1
		dd	CancelNewMultiEffect2
		db	-1

effecteditkeys	db	1
		dd	EffectCancel2
		db	-1

effecteditkeys2 db	1
		dd	EffectCancel2
		db	-1

EQEdPopupKeys	db	1
		dd	Pop_up_no2
		db	28
		dd	Popup_okay2
		db	89
		dd	PopUp_okay2
		db	-1

ViewVolumeK	db	28
		dd	VolumeCalculate2
		db	89
		dd	VolumeCalculate2
		db	1
		dd	VolumeEnd2
		db	-1

ViewmixK	db	28
		dd	mixathemix
		db	89
		dd	mixathemix
		db	1
		dd	cancelthemix2
		db	-1
Viewpop20K	db	28
		dd	Pop_up_yes2
		db	89
		dd	Pop_up_yes2
		db	21
		dd	Pop_up_yes2
		db	49
		dd	Pop_up_no2
		db	1
		dd	Pop_up_cancel2
		db	-1

Viewpop22K	db	28
		dd	Pop_up_yes2
		db	89
		dd	Pop_up_yes2
		db	21
		dd	Pop_up_yes2
		db	49
		dd	Pop_up_no2
		db	1
		dd	Pop_up_cancel2
		db	-1

YfixK		db	1
		dd	y_fixend2
		db	-1

OptimKey	db	1ch
		dd	OptimOkay2
		db	1
		dd	OptimEnd
		db	-1

NewPullDownKey	db	62h
		dd	WindowLeft
		db	63h
		dd	WindowRight
		db	60h
		dd	WindowUp
		db	65h
		dd	WindowDown
		db	1
		dd	PullEsc
		db	28
		dd	PullTheEnter
		db	-1

OptimSavedKey	db	28
		dd	Popup_okay4
		db	89
		dd	Popup_okay4
		db	 1
		dd	PopUp_okay4
		db	-1

NewVolKeys	db	1
		dd	NewVolumeEnd2
		db	-1

NewMarkKeys	db	1
		dd	NewMarkEnd2
		db	-1

EffectsPopupKeys db	1
		 dd	SampleEffectsEnd2
		 db	-1

EchoEditorPopupKeys	db	28
		dd	Pop_up_yes2
		db	89
		dd	Pop_up_yes2
		db	21
		dd	Pop_up_yes2
		db	 1
		dd	Pop_up_no2
		db	49
		dd	Pop_up_no2
		db	-1

HelpPopupKeys	db	28
		dd	Pop_up_yes2
		db	1
		dd	Pop_up_yes2
		db	89
		dd	Pop_up_yes2
		db	96
		dd	HelpScreenArrUp2
		db	101
		dd	HelpScreenArrDn2
		db	97
		dd	HelpPGUP
		db	102
		dd	HelpPGDN
		db	48
		dd	HelpBack2
		db	23
		dd	HelpIndex2
		db	31
		dd	HelpSearch2
		db	49
		dd	HelpSearchNext2
		db	-1

PattDefPopupKeys	db	28
		dd	Pop_up_yes2
		db	1
		dd	Pop_up_yes2
		db	89
		dd	Pop_up_yes2
		db	-1
ResamplePopupKeys db	1
		 dd	ResampleEnd2
		 db	-1
EffectWaitPopupKeys db	  1
		 dd	EffectWaitCancel2
		 db	-1


ConfigPathPopupKeys	db	28
		dd	Pop_up_yes2
		db	1
		dd	Pop_up_yes2
		db	89
		dd	Pop_up_yes2
		db	-1

KeyBoardTable	label dword
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;	Not Shifted    Shift + Key	  Ctrl + Key		  Alt +  Key		  CapsLock+Key
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 dd	Dummy,	       Dummy,		  Dummy,		  Dummy,		  Dummy
 ife	Release
 dd	MainPullDown,  MouseInit,	  PrintShit,		  FillScreen,		  Switch16Bit;ESC
 else
 dd	MainPullDown,  Dummy,		  Dummy,		  Dummy,		  Dummy ;ESC
 endif
 dd	KeyBoard,      StoreCommand1,	  InsertOneCommand1,	  InsertAllCommands1,	  NoteUpST	 ;1
 dd	KeyBoard,      StoreCommand2,	  InsertOneCommand2,	  InsertAllCommands2,	  NoteUpSP	 ;2
 dd	KeyBoard,      StoreCommand3,	  InsertOneCommand3,	  InsertAllCommands3,	  NoteUpAT	 ;3
 dd	KeyBoard,      StoreCommand4,	  InsertOneCommand4,	  InsertAllCommands4,	  NoteUpAP	 ;4
 dd	KeyBoard,      StoreCommand5,	  InsertOneCommand5,	  InsertAllCommands5,	  NoteUpSB	 ;5
 dd	KeyBoard,      StoreCommand6,	  InsertOneCommand6,	  InsertAllCommands6,	  NoteUpAB	 ;6
 dd	KeyBoard,      StoreCommand7,	  InsertOneCommand7,	  InsertAllCommands7,	  Dummy 	 ;7
 dd	KeyBoard,      StoreCommand8,	  InsertOneCommand8,	  InsertAllCommands8,	  Dummy 	 ;8
 dd	KeyBoard,      StoreCommand9,	  InsertOneCommand9,	  InsertAllCommands9,	  Dummy 	 ;9
 dd	KeyBoard,      StoreCommand0,	  InsertOneCommand0,	  InsertAllCommands0,	  Dummy 	 ;0
 dd	KeyBoard,      Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;MINUS
 dd	KeyBoard,      Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;EQUAL
 dd	PlayRow,       InsNote2,	  InsCmd2,		  InsPatt2,		  Dummy 	 ;BACKSPACE
 dd	ChangeChannel, ChangeChannel2,	  Dummy,		  Dummy,		  Dummy 	 ;TAB
 dd	KeyBoard,      Dummy,		  UnMuteAll2,		  ToggleEQ,		  NoteDownST	 ;Q
 dd	KeyBoard,      DecreaseAllCmdNr,  DecreaseCmdNr,	  Dummy,		  NoteDownSP	 ;W
 dd	KeyBoard,      IncreaseAllCmdNr,  IncreaseCmdNr,	  DescriptionStart2,	  NoteDownAT	 ;E
 dd	KeyBoard,      Dummy,		  RestoreFPositions,	  RestoreMainScreen,	  NoteDownAP	 ;R
 dd	KeyBoard,      Dummy,		  ToggleSTArrow,	  Dummy,		  NoteDownSB	 ;T
 dd	KeyBoard,      Dummy,		  ChangeInst,		  Dummy,		  NoteDownAB	 ;Y
 dd	KeyBoard,      Dummy,		  MM_UnmarkBlock,	  SwapUndoBuffer,	  Dummy 	 ;U
 dd	KeyBoard,      Dummy,		  InsertBlock,		  EnvelopeStart2,	  Dummy 	 ;I
 dd	KeyBoard,      Dummy,		  ContractOneChannel,	  ContractPattern,	  Dummy 	 ;O
 dd	KeyBoard,      Dummy,		  PasteBlock,		  PositionEditor2,	  Dummy 	 ;P
 dd	KeyBoard,      Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;LBRACKET
 dd	KeyBoard,      Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;RBRACKET
 dd	PlayRow_A,     InsNote1,	  InsCmd1,		  InsPatt1,		  Dummy 	 ;ENTER
 dd	Dummy,	       Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;LEFTCTRL
 dd	KeyBoard,      Dummy,		  MuteOne,		  PutUpEchoEditor2,	  OctaveUpST	 ;A
 dd	KeyBoard,      Dummy,		  SoloOne,		  SampleEditor2_,	  OctaveUpSP	 ;S
 dd	KeyBoard,      Dummy,		  DeleteBlock,		  DiskOpStart3, 	  OctaveUpAT	 ;D
 dd	KeyBoard,      Dummy,		  QuickMark,		  Dummy,		  OctaveUpAP	 ;F
 dd	KeyBoard,      Dummy,		  Dummy,		  DoPiano,		  OctaveUpSB	 ;G
 dd	KeyBoard,      Dummy,		  Dummy,		  HelpStart2,		  OctaveUpAB	 ;H
 dd	KeyBoard,      Dummy,		  JoinPasteBlock,	  Dummy,		  Dummy 	 ;J
 dd	KeyBoard,      Dummy,		  KillToEnd,		  KillSampleAtChannel,	  Dummy 	 ;K
 dd	KeyBoard,      Dummy,		  MarkChanPatt, 	  Dummy,		  Dummy 	 ;L
 dd	KeyBoard,      Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;SEMICOLON
 dd	KeyBoard,      Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;TICK (Ž)
 dd	NoteOff,       Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;APOSTROPHE
 dd	Dummy,	       Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;LEFTSHIFT
 dd	KeyBoard,      Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;BACKSLASH
 dd	KeyBoard,      Dummy,		  MuteAll2,		  ZoomPattern,		  OctaveDownST	 ;Z
 dd	KeyBoard,      Dummy,		  CutBlock,		  TrackerEnd,		  OctaveDownSP	 ;X
 dd	KeyBoard,      Dummy,		  CopyBlock,		  Dummy,		  OctaveDownAT	 ;C
 dd	KeyBoard,      Dummy,		  ExpandOneChannel,	  ExpandPattern,	  OctaveDownAP	 ;V
 dd	KeyBoard,      Dummy,		  MarkBlockBeg, 	  StoreUndoBuffer,	  OctaveDownSB	 ;B
 dd	KeyBoard,      Dummy,		  Dummy,		  LoadModuleKey,	  OctaveDownAB	 ;N
 dd	KeyBoard,      Dummy,		  RampCommandData,	  Dummy,		  Dummy 	 ;M
 dd	KeyBoard,      Dummy,		  CopyOneAboveCommand,	  CopyAllAboveCommand,	  DoubleC4	 ;COMMA
 dd	KeyBoard,      Dummy,		  CopyOneAboveCommandInc, CopyAllAboveCommandInc, HalveC4	 ;PERIOD
 dd	KeyBoard,      Dummy,		  CopyOneAboveCommandDec, CopyAllAboveCommandDec, Dummy 	 ;SLASH
 dd	Recpatt,       RecSong, 	  RecPatt3,		  Dummy,		  Dummy 	 ;RIGHTSHIFT
 dd	SelectSample,  SelectSampleShift, SelectSampleCtrl,	  SelectSampleAlt,	  SelectSampleCL ;KEYPADSTAR
 dd	Dummy,	       Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;LEFTALT
 dd	Space,	       Dummy,		  Dummy,		  PullDownKey,		  Dummy 	 ;SPACE
 dd	Dummy,	       Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;CAPSLOCK
 dd	OctaveDn,      Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;F1
 dd	OctaveUp,      Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;F2
 dd	Dummy,	       CutChannel,	  CutCommand,		  CutPattern,		  Dummy 	 ;F3
 dd	Dummy,	       CopyChannel,	  CopyCommand,		  CopyPattern,		  Dummy 	 ;F4
 dd	Dummy,	       PasteChannel,	  PasteCommand, 	  PastePattern, 	  Dummy 	 ;F5
 dd	JumpPattern1,  StorePattern1,	  RecPattern1,		  PlayPattern1, 	  JumpPattern1M  ;F6
 dd	JumpPattern2,  StorePattern2,	  RecPattern2,		  PlayPattern2, 	  JumpPattern2M  ;F7
 dd	JumpPattern3,  StorePattern3,	  RecPattern3,		  PlayPattern3, 	  JumpPattern3M  ;F8
 dd	JumpPattern4,  StorePattern4,	  RecPattern4,		  PlayPattern4, 	  JumpPattern4M  ;F9
 dd	JumpPattern5,  StorePattern5,	  RecPattern5,		  PlayPattern5, 	  JumpPattern5M  ;F10
 dd	SelectSample,  SelectSampleShift, SelectSampleCtrl,	  SelectSampleAlt,	  SelectSampleCL ;NUMLOCK
 dd	Dummy,	       Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;SCROLLLOCK
 dd	SelectSample,  SelectSampleShift, SelectSampleCtrl,	  SelectSampleAlt,	  SelectSampleCL ;KEYPAD7
 dd	SelectSample,  SelectSampleShift, SelectSampleCtrl,	  SelectSampleAlt,	  SelectSampleCL ;KEYPAD8
 dd	SelectSample,  SelectSampleShift, SelectSampleCtrl,	  SelectSampleAlt,	  SelectSampleCL ;KEYPAD9
 dd	SelectSample,  SelectSampleShift, SelectSampleCtrl,	  SelectSampleAlt,	  SelectSampleCL ;KEYPADMINUS
 dd	SelectSample,  SelectSampleShift, SelectSampleCtrl,	  SelectSampleAlt,	  SelectSampleCL ;KEYPAD4
 dd	SelectSample,  SelectSampleShift, SelectSampleCtrl,	  SelectSampleAlt,	  SelectSampleCL ;KEYPAD5
 dd	SelectSample,  SelectSampleShift, SelectSampleCtrl,	  SelectSampleAlt,	  SelectSampleCL ;KEYPAD6
 dd	SelectSample,  SelectSampleShift, SelectSampleCtrl,	  SelectSampleAlt,	  SelectSampleCL ;KEYPADPLUS
 dd	SelectSample,  SelectSampleShift, SelectSampleCtrl,	  SelectSampleAlt,	  SelectSampleCL ;KEYPAD1
 dd	SelectSample,  SelectSampleShift, SelectSampleCtrl,	  SelectSampleAlt,	  SelectSampleCL ;KEYPAD2
 dd	SelectSample,  SelectSampleShift, SelectSampleCtrl,	  SelectSampleAlt,	  SelectSampleCL ;KEYPAD3
 dd	SelectSample,  SelectSampleShift, SelectSampleCtrl,	  SelectSampleAlt,	  SelectSampleCL ;KEYPAD0
 dd	KillInstrument,KillSample,	  Dummy,		  Dummy,		  Dummy 	 ;KEYPADDEL
 dd	Dummy,	       Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;SYSREQ
 dd	Dummy,	       Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;DUMMY!!!
 dd	RowAddKey,     RowSubKey,	  Dummy,		  Dummy,		  Dummy 	 ;<>
 dd	PlayLong,      Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;F11
 ife	Release
 dd	StopSpeech,    BSFilter,	  ToggleMouse,		  MemReorganize,	  PrintInstInfo  ;F12
 else
 dd	Dummy,	       Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;F12
 endif
 dd	SelectSample,  SelectSampleShift, SelectSampleCtrl,	  SelectSampleAlt,	  SelectSampleCL ;KEYPADENTER
 dd	StartMod,      Dummy,		  StartMod3,		  Dummy,		  Dummy 	 ;RIGHTCTRL
 dd	SelectSample,  SelectSampleShift, SelectSampleCtrl,	  SelectSampleAlt,	  SelectSampleCL ;KEYPADSLASH
 dd	Dummy,	       Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;CTRLPRTSC
 dd	Dummy,	       Dummy,		  Dummy,		  Dummy,		  Dummy 	 ;SHIFTPRTSC
 dd	StartPatt,     Dummy,		  StartPatt3,		  Dummy,		  Dummy 	 ;RIGHTALT
 dd	GoFirstRow,    Dummy,		  Dummy,		  Dummy,		  MarkHOME	 ;HOME
 dd	ArrowXUp,      Dummy,		  Dummy,		  ArrowUp,		  MarkUp	 ;UARROW
 dd	Sub8Rows,      Dummy,		  Sub16Rows,		  Sub32Rows,		  MarkPGUP	 ;PGUP
 dd	ArrowLeft,     DecreasePosition2, InstDn2,		  DecreasePattern2,	  MarkLt	 ;LARROW
 dd	ArrowRight,    IncreasePosition2, InstUp2,		  IncreasePattern2,	  MarkRt	 ;RARROW
 dd	GoLastRow,     Dummy,		  Dummy,		  Dummy,		  MarkEND	 ;END
 dd	ArrowXDown,    Dummy,		  Dummy,		  ArrowDown,		  MarkDn	 ;DARROW
 dd	Add8Rows,      Dummy,		  Add16Rows,		  Add32Rows,		  MarkPGDN	 ;PGDN
 dd	InsNote4,      InsNote5,	  Dummy,		  Dummy,		  Dummy 	 ;INS
 dd	DelNote,       DelAll,		  DelCmd,		  DelAllCmd,		  Dummy 	 ;DEL
 dd	-1


AllProcedures	Label	Dword
	dd	Dummy,MainPullDown,KeyBoard,PlayRow,ChangeChannel,PlayRow_A,NoteOff
	dd	Recpatt,SelectSample,Space,OctaveDn,OctaveUp,JumpPattern1,JumpPattern2
	dd	JumpPattern3,JumpPattern4,JumpPattern5,KillInstrument,RowAddKey
	dd	StartMod,StartPatt,GoFirstRow,ArrowXUp,Sub8Rows,ArrowLeft,ArrowRight
	dd	GoLastRow,ArrowXDown,Add8Rows,InsNote4,DelNote,StoreCommand1
	dd	StoreCommand2,StoreCommand3,StoreCommand4,StoreCommand5,StoreCommand6,StoreCommand7
	dd	StoreCommand8,StoreCommand9,StoreCommand0,InsNote2,ChangeChannel2,InsNote1
	dd	RecSong,SelectSampleShift,CutChannel,CopyChannel,PasteChannel,StorePattern1
	dd	StorePattern2,StorePattern3,StorePattern4,StorePattern5,KillSample,RowSubKey
	dd	FasterArrowUp,DecreasePosition2,IncreasePosition2,FasterArrowDown,InsNote5
	dd	DelAll,InsertOneCommand1,InsertOneCommand2,InsertOneCommand3
	dd	InsertOneCommand4,InsertOneCommand5,InsertOneCommand6,InsertOneCommand7
	dd	InsertOneCommand8,InsertOneCommand9,InsertOneCommand0,InsCmd2,UnMuteAll2
	dd	DecreaseCmdNr,IncreaseCmdNr,RestoreFPositions,ToggleSTArrow,ChangeInst
	dd	MM_UnmarkBlock,InsertBlock,ContractOneChannel,PasteBlock,InsCmd1,MuteOne
	dd	SoloOne,DeleteBlock,QuickMark,JoinPasteBlock,KillToEnd,MarkChanPatt
	dd	MuteAll2,CutBlock,CopyBlock,ExpandOneChannel,MarkBlockBeg,RampCommandData
	dd	CopyOneAboveCommand,CopyOneAboveCommandInc,CopyOneAboveCommandDec,RecPatt3
	dd	SelectSampleCtrl,CutCommand,CopyCommand,PasteCommand,RecPattern1,RecPattern2
	dd	RecPattern3,RecPattern4,RecPattern5,StartMod3,StartPatt3
	dd	FastestArrowUp,Sub16Rows,InstDn2,InstUp2,FastestArrowDown,Add16Rows
	dd	DelCmd,InsertAllCommands1,InsertAllCommands2,InsertAllCommands3
	dd	InsertAllCommands4,InsertAllCommands5,InsertAllCommands6,InsertAllCommands7
	dd	InsertAllCommands8,InsertAllCommands9,InsertAllCommands0,InsPatt2,DescriptionStart2
	dd	RestoreMainScreen,SwapUndoBuffer,EnvelopeStart2,ContractPattern,PositionEditor2
	dd	InsPatt1,PutUpEchoEditor2,SampleEditor2_,DiskOpStart3,DoPiano,HelpStart2
	dd	KillSampleAtChannel,ZoomPattern,TrackerEnd,ExpandPattern,StoreUndoBuffer
	dd	LoadModuleKey,CopyAllAboveCommand,CopyAllAboveCommandInc,CopyAllAboveCommandDec
	dd	SelectSampleAlt,PullDownKey,CutPattern,CopyPattern,PastePattern,PlayPattern1
	dd	PlayPattern2,PlayPattern3,PlayPattern4,PlayPattern5,ArrowUp,Sub32Rows
	dd	DecreasePattern2,IncreasePattern2,ArrowDown,Add32Rows,DelAllCmd
	dd	NoteUpST,NoteUpSP,NoteUpAT,NoteUpAP,NoteUpSB,NoteUpAB,NoteDownST,NoteDownSP
	dd	NoteDownAT,NoteDownAP,NoteDownSB,NoteDownAB,OctaveUpST,OctaveUpSP,OctaveUpAT
	dd	OctaveUpAP,OctaveUpSB,OctaveUpAB,OctaveDownST,OctaveDownSP,OctaveDownAT
	dd	OctaveDownAP,OctaveDownSB,OctaveDownAB,DoubleC4,HalveC4,SelectSampleCL
	dd	JumpPattern1M,JumpPattern2M,JumpPattern3M,JumpPattern4M,JumpPattern5M
	dd	MarkHOME,MarkUp,MarkPGUP,MarkLt,MarkRt,MarkEND,MarkDn,MarkPGDN
	dd	DecreaseAllCmdNr,IncreaseAllCmdNr,ToggleEQ
NrAllProcedures equ ($-AllProcedures)/4


ExtendedKeys	db	09Ch,89,09Dh,90,0B5h,91,0B7h,92,0B7h,93,0B8h,94,0C7h,95
		db	0C8h,96,0C9h,97,0CBh,98,0CDh,99,0CFh,100,0D0h,101,0D1h
		db	102,0D2h,103,0D3h,104
		db	0


;Channel Positions
ChanPos 	db	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
		db	17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
		db	32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47
		db	48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63
		db	64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79
		db	80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95


PrgVersionText	db	'Velvet Studio v2.01 PRO',10,13
		db	'(c)Copyright 1994-1997 by Velvet development. All rights reserved.',10,10,13
		db	'$'
CmdHelpText	db	'Syntax: VS.EXE [flag(s)]',10,10,13
		db	'Available flags:',10,10,13
		db	'/f - Forces manual soundcard configuration',10,13
		db	'$'

InitPrintText1	db	'Allocating memory...',10,13,'$'
InitPrintText2	db	'Redirecting INT 24...',10,13,'$'
InitPrintText3	db	'Determining filename...',10,13,'$'
InitPrintText4	db	'Getting current path...',10,13,'$'
InitPrintText5	db	'Initializing tables...',10,13,'$'
InitPrintText6	db	'Reading Config File...$'
InitPrintText7	db	10,13,'Initializing CDROM...',10,13,'$'
InitPrintText8	db	'Ready. Changing video mode...',10,13,'$'

InsertDisk	db	10,13,10,'Velvet Studio protection system activated',13,10
		db	'Please start VS from the installation directory (unless you already did) and',10,13
		db	'Insert Install Disk #1 in drive $'
InsertDisk1	db	10,13,'Please Insert the correct disk! $'
InsertDisk2	db	10,13,'Press any key to continue...',10,13,'$'

NoGUSInstalled	db	0
CmdLineFlag	db	0
Force_SC_Config	db	0	; Force Soundcard configuration

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; CODE
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

	align	4
IF PMODEWVERSION	;\\		;PMODEW
Start:
ENDIF			;//
IF DOS32VERSION		;\\
_Main:
ENDIF			;//

IFDEF	DEBUGON				;Only DOS32
IF	DEBUGON
	call	debug
ENDIF
ENDIF
	sti
	call	SetupSystem

	mov	byte ptr gs:[417h],0;Depress Ctrl+Alt+Caps etc.
	mov	byte ptr gs:[418h],0

	call	GetRunningFileName

	lea	esi,PrgVersionText
	call	printtext2

	xor	eax,eax 		;check pcx summa bytes
	lea	esi,pcxsize
SummaLoop_:
	mov	ebx,[esi]
	cmp	ebx,-1
	jz	nomoresumma_
	add	eax,ebx
	add	esi,4
	jmp	summaloop_
nomoresumma_:

	mov	DatFileSize,eax

;	call	LoadInfoBlock1

NoErrorWow:
	mov	StackSave,esp

	; Check if anything in command line
	lea	edi,CommandLine
	call	ReadCommandLine
	jc	@@nocmdline

;-----------------------------------------------------------------------------
	; * Parse command line for options *
;-----------------------------------------------------------------------------
	lea	esi,commandline
@@parse:lodsb
	test	al,al		; End of commandline?
	jz	@@cmdlineOk
	cmp	al,'/'		; Parameter switch?
	jz	@@chkparam
	cmp	al,'-'		; Parameter switch?
	jnz	@@parse
@@chkparam:
	mov	al,[esi]	; Get flag
	cmp	al,'f'		; Force soundcard config
	jz	@@f_flag
	jmp	@@parse

	; FLAG: Disable autodetection
@@f_flag:mov	Force_SC_Config,1
	mov	cmdlineflag,1	; Valid param found
	inc	esi
	jmp	@@parse

@@cmdlineOk:
	cmp	cmdlineflag,0	; If zero, no valid parameters were found
	jnz	@@nocmdline	; Resume program load

	lea	esi,cmdhelptext
	call	printtext2
	jmp	_exit


	; * Command line parsing finished *
@@nocmdline:
	call	MouseInit
	lea	esi,InitPrintText1
	call	printtext2

;----------
IF DOS32VERSION		;\\
	pushad
	call	_getlomem		;Alloc DMA Buffer
	mov	DMABuffer,edx
	mov	DMABuffer_Phys,ebx
	jc	LowMemError
	popad
ENDIF			;//

IF PMODEWVERSION	;\\
	mov	eax,8000h		;Alloc 32k for DMA buffer
	call	_getlomem
	jc	LowMemError
	mov	DMABuffer,eax

	mov	ecx,16384
	mov	GUS_RollOverDataSize,ecx
	mov	ebx,eax
	add	ebx,0ffffh
	and	ebx,0ffff0000h
	sub	ebx,eax 		;Length to nearest 64K boundary
	cmp	ebx,GUS_RollOverDataSize
	jae	DMABuffFits
	add	DMABuffer,ebx
DMABuffFits:
	mov	eax,DMABuffer
	add	eax,_Code32a
	mov	DMABuffer_Phys,eax
ENDIF			;//

IF PMODEWVERSION 	;\\
	call	_himemsize		;Allocate ALL High Memory
	mov	ebx,eax
	mov	TotalXMS,eax
	call	_gethimem
	mov	HiMemPtr,eax
	add	ebx,eax
	mov	HiMemEnd,ebx
ENDIF			;//

IF DOS32VERSION		;\\
	mov	eax,-1			;alloc all mem...
	call	_gethimem
	cmp	eax,600*1024		;MIN SIZE
	jb	LowMemError

	push	eax			;save size
	mov	ax,0ee40h
	int	31h			;free the memory
	pop	eax

	sub	eax,600*1024		;allocate 600Kb less than maximum
	call	_gethimem
	mov	TotalXMS,eax
	mov	HiMemPtr,edx

	mov	eax,600*1024		;allocate DOS Shell Memory
	call	_gethimem
	mov	DosShellSize,eax
	mov	DosShellPtr,edx

	add	TotalXMS,eax		;include DOS shell mem
	add	edx,eax
	mov	HiMemEnd,edx
ENDIF			;//

;----------

	lea	esi,InitPrintText2
	call	printtext2

	call	SetVector24

	lea	esi,InitPrintText3
	call	printtext2

	lea	esi,InitPrintText4
	call	printtext2

	call	GetDrivePath

	lea	esi,InitPrintText5
	call	printtext2

	call	InitMIDItables		; Initialize sum MIDI stuph

	mov	SoundCard,0
	call	InitJumpTable		;Init for NO sound at first...

	lea	esi,InitPrintText6
	call	printtext2

	call	Config

	lea	esi,InitPrintText7
	call	printtext2
	call	CD_init

	mov	ax,0305h		;Set Typematic Rate+Delay
	mov	bx,Typematic
	int	16h

	lea	esi,InitPrintText8
	call	printtext2

	mov	ax,12h			;Set Screen Mode
	int	10h

	call	mouseon
	call	SetNewInt9

	lea	eax,fadeupbuff
	call	setpcxpal

	call	ClearMod
	call	AllocateInitialBuffers

	call	preparearrows
	mov	al,insertstart
	mov	insert,al

	lea	eax,ModName
	mov	ModNamePtr,eax


;	mov	esi,offset InfoBlockBuffer1 + 3245
;	sub	esi,3245
;	mov	edi,offset InfoBlockBuffer2 - 333
;	add	edi,333
;	mov	ecx,1232
;	rep	movsb

	mov	eax,[PcxOffsets+12]	;Put Top Bar
	mov	pcxx,0
	mov	pcxy,0
	call	ShowThePcx
	mov	eax,[PcxOffsets+16]	;Put Position/BPM etc
	mov	pcxx,0
	mov	pcxy,17
	call	ShowThePcx

	mov	Menu_DownScreen,0	;Put DownScreen
	cmp	TrackerStyle,0
	jz	GundeSvan
	mov	Menu_DownScreen,1
GundeSvan:
	mov	[CurrentMenu+2],-1
	call	MenuHandler

	mov	menu_upperscreen,0	;Put UpperScreen
	mov	[CurrentMenu+4],-1
	call	menuhandler

	mov	[CurrentMenu+6],-1	;Put LeftScreen
	call	menuhandler

	mov	OldPos2,-1		;Update numbers
	mov	OldPattName,-1
	call	PrintPattInfo
	call	PrintSampleInfo
	call	UpdateSongCfgScreen
	call	ShowPosList

	call	UpdateBlockBock 	;Put Piano
	call	menupiano

	mov	samples,1

	call	mouseoff
	push	esi
	mov	ah,18h
	mov	cl,MainPullTextLength
	move	edi,0a0000h+(3*80)
	lea	esi,MainPullText
	call	PrintPullText
	call	PutVersionText		; Update version on menu bar
	pop	esi


	call	GetMouseBackGround
	call	InitDesc
	call	MouseArrow
	mov	Positions,1
	lea	eax,AllRightText
	mov	InfoTextPtr,eax
	call	PrintModName
	call	PrintComposer
	call	PrintSampleInfo
	call	PrintPattInfo
	call	UpdateChannelInfo
	call	StoreUndoBuffer

	mov	OldTime_Hour,-5

	call	UpdateDifferentStuff	;Updates DragBars and diff. Digits
	call	UpdatePattern		;Update the pattern to screen
	call	RowAdd

	mov	Updatecolorsnotpalette,1
	call	UpdateTheColors
	mov	updatecolorsnotpalette,0
	lea	esi,TheColorTable
	call	fadeuppal		;fade up pal
;	call	CRCCheck1End

	call	StartTimer
	call	DetectSoundCard
	jnc	FoundCard
	mov	Menu_Popup,28
	call	MenuHandler
	mov	NotFound,1
FoundCard:
	call	StopTimer
	call	InitJumpTable

	call	InitSoundCard
	mov	eax,SoundCard
	mov	OldSoundCard,ax
	call	StartTimer

	call	SampLoadEffects

	mov	ax,ConfigErr
	cmp	ReqConfigErr,1
	jz	Errorhandler

	cmp	NotFound,1
	jz	@@Skjip
	cmp	EffectError,1
	jz	@@Skjip


@@Skjip:
	xor	al,al			;Enable All IRQ's
	out	21h,al
	out	0a1h,al
	mov	StackSave,esp


;Global SamplePtr:Dword:32
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± Main Loop ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;Xxxxxxxxxxxxxxxxxxxxxxxxxtra ball!
	align	4
TrackerMain:
	mov	ax,MasterFrequency
	cmp	ax,OldMasterFrequency
	jz	TrackerMain
	mov	OldMasterFrequency,ax
	cmp	DClickCounter,0
	jz	NoDclickFix
	dec	DClickCounter
	jg	NoDclickFix
	mov	DClickCounter,0
	mov	MouseOnceReleased,0
	mov	DoubleClickExpired,1
NoDclickFix:

if PrintDebug

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov	ah,0fh
	mov	cl,3
	move	edi,0a0000h+80-8+80*3
	movzx	ebx,MouseX
	call	PutDecimal

	mov	ah,0fh
	mov	cl,3
	move	edi,0a0000h+80-4+80*3
	movzx 	ebx,MouseY
	call	PutDecimal
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;	mov	ah,0fh
;	move	edi,0a0000h
;	mov	cl,80
;	lea	esi,InfoBlockBuffer1+5
;	call	PrintText

;	mov	ah,0fh
;	mov	cl,10
;	move	edi,0a0000h+80*3
;	call	GetSampOffset
;	mov	ebx,CurrAdd
;	call	PutDecimal

;	call	PrintShitTable
;	call	PrintMIDIShit
;	call	PrintUsedChannels

	call	printshit

endif

;--------------------
	call	MouseStat
	call	UpdatePattern		;Update the pattern to screen
	call	UpdateDifferentStuff	;Updates DragBars and diff. Digits
	call	KeyBoardHandler 	;Handles all keystrokes
	call	MouseHandler		;Handles all MouseMovements
	jmp	TrackerMain

Nisse	dd	0
ErrorHandler:
	mov	esp,StackSave
	movzx	ebx,ax
	cmp	SoundCard,1
	jz	GUSErrors
	cmp	SoundCard,5
	jz	GUSErrors
	cmp	SoundCard,6
	jz	GUSErrors
	cmp	ebx,10h
	jnz	NoGUSFix1
	mov	ebx,0fh
	jmp	GUSErrors
NoGUSFix1:
	cmp	ebx,0bh
	jnz	GUSErrors
	mov	ebx,1dh
	jmp	GUSErrors
GUSErrors:
	cmp	ebx,0ah
	jb	FatalError
	mov	secondpopup,0
	mov	SpecialSecondPopup,0
	mov	CurrentMenu,0
	call	PopPart
	call	PopPart
	mov	esi,[ErrorCodeTable+ebx*4]
	mov	Menu_Popup,1
	call	MouseArrow
	call	PopUpHandler
	mov	OldCurrentFileName,-1
	call	GetCurrPath
;	call	StartTimer
;	call	SetOrigVol
	jmp	TrackerMain
FatalError:
	mov	ax,3h
	int	10h
	mov	esi,[ErrorCodeTable+ebx*4]
	call	PrintText2
	jmp	_Exit

Global	olles:byte

KeyBoardDelayI	dw	1	;Orig Value
KeyBoardDelay	dw	0
KeyBoardRepeat1 dw	1	;Orig Value
KeyBoardRepeat2 dw	1	;Orig Value
KeyBoardRepeatI dw	1	;Orig Value
KeyBoardRepeat	dw	0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;The Main KeyBoardHandler
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
KeyBoardHandler     Proc    Near
	mov	ButtonCheck,0
	cmp	buttonhandlerstatus,0		;Check if the mouse handler
	jnz	_ret				;is activated

	cmp	KBDBufferFull,1
	jz	ReadTheBuffer
	mov	al,KBDBuffPtrR
	cmp	al,KBDBuffPtrW
	jz	_ret

ReadTheBuffer:
	mov	KBDBufferFull,0
	movzx	esi,KBDBuffPtrR
	mov	ax,word ptr [KBDBuffer+esi*2]
	inc	KBDBuffPtrR
	and	KBDBuffPtrR,0fh

	rol	ah,1
	movzx	ebx,al

	mov	[Keys+ebx],ah
	cmp	ah,1
	jz	KeyPressed

	call	CheckReleaseKeys
	mov	LastKeyPressed,0
	ret
KeyPressed:
	mov	LastKeyPressed,ebx

	cmp	ConfigKeysRead,1		;HUM!
	jz	_Ret

	cmp	DescEditNumber,-1
	jz	nokeyboardcheck
	call	DescKeyboard
	ret
nokeyboardcheck:

	cmp	InitInput,0
	jz	NoInputNow
	call	InputRoutine
	ret
NoInputNow:
	cmp	KBD4Request,1
	jz	SkipTempp1
	cmp	KBD5Request,1
	jz	SkipTempp1
	cmp	Menu_PopUp,0
	jz	NoPopupKey
;------------------------------
SkipTempp1:
	call	ScanTable
	cmp	KBD4Request,1
	jz	SkipTempp
	cmp	KBD5Request,1
	jz	SkipTempp
	cmp	SplitPlay,0
	jz	NoXXKeyBoard
SkipTempp:
	mov	esi,[edi]
	cmp	esi,Offset KeyBoard
	jnz	NoXXKeyBoard;_ret
	call	KeyBoard
	mov	ebx,KeyBoardNote
	cmp	ebx,0
	jz	_ret
	cmp	KBD1Request,0
	jz	CheckKBD2
	mov	edx,CurrentSplitOffset
	mov	[SplitTable+edx+1],bl
	call	UpdateSplitStatus
	call	PopUp_KBD2
	jmp	_ret
CheckKBD2:
	cmp	KBD2Request,0
	jz	CheckKBD3
	mov	edx,CurrentSplitOffset
	mov	[SplitTable+edx+2],bl
	call	UpdateSplitStatus
	jmp	_ret
CheckKBD3:
	cmp	KBD3Request,0
	jz	CheckKBD4
	mov	edx,CurrentSplitOffset
	mov	[SplitTable+edx+3],bl
	call	UpdateSplitStatus
	jmp	_ret
CheckKBD4:
	cmp	KBD4Request,0
	jz	CheckRelNote
	mov	KBD4Request,0
	sub	bl,2
	and	ebx,0ffh
	ConvertNote ebx ebx
	mov	eax,428*8363*16
	xor	edx,edx
	div	ebx
	cmp	eax,0ffffh
	jbe	NoC2Fix5
	mov	ax,62795
NoC2Fix5:
	movzx	ebp,CurrentSample
	mov	[SampleRates+ebp*2],ax
	call	PrintSampleInfo
	jmp	_ret
CheckRelNote:
	cmp	KBD5Request,0
	jz	_ret
	mov	KBD5Request,0
	movzx	ebp,CurrentSample
	sub	bl,50
	mov	[Relativenote+ebp],bl
	call	PrintRelNote
	jmp	_ret
NoXXKeyBoard:
	sub	edi,Offset KeyBoardTable

	mov	eax,edi
	mov	edi,20
	xor	edx,edx
	div	edi
	movzx	esi,Menu_PopUp
	dec	esi
	mov	esi,[PopUpTableKeys+esi*4]
ScanPopUpKeys:
	cmp	byte ptr [esi],-1
	jz	_ret
	cmp	[esi],al
	jz	GoToPopUp
	add	esi,5
	jmp	ScanPopUpKeys
GoToPopUp:
	jmp	dword ptr [esi+1]

;------------------------------
NoPopupKey:

	cmp	[Keys+1dh],1
	jz	LeftCtrl
	cmp	[Keys+38h],1
	jz	LeftAlt
	cmp	[Keys+2ah],1
	jz	LeftShift
	cmp	[Keys+3ah],1
	jz	CapsLock
	call	ScanTable
	jmp	[edi]

LeftShift:
	call	ScanTable
	add	edi,4
	jmp	[edi]
LeftCtrl:
	call	ScanTable
	add	edi,8
	jmp	[edi]
LeftAlt:
	call	ScanTable
	add	edi,12
	jmp	[edi]
CapsLock:
	call	ScanTable
	add	edi,16
	jmp	[edi]
RTZ_1:
	mov	KeyBoardDelay,0
	mov	KeyBoardRepeat,0
	mov	LastKeyPressed,0
;	sti
	ret
KeyBoardHandler  EndP

ScanTable:
	mov	edi,LastKeyPressed
	cmp	edi,89
	jb	NoExtended
	mov	ecx,16
	lea	esi,ExtendedKeys
	xor	eax,eax
CheckExtended:
	lodsb
	inc	esi
	cmp	eax,edi
	loopnz	CheckExtended
	jnz	RTZ
	movzx	edi,byte ptr [esi-1]
NoExtended:
	mov	KeyBoardPress,edi

	push	eax edx
	mov	eax,20
	mul	edi
	mov	edi,eax
	pop	edx eax
	add	edi,Offset KeyBoardTable
	ret
RTZ:
	mov	edi,Offset KeyBoardTable
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Checks the status of the Mouse
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
UpdateMouse	db	0
MouseB	dw	0
MouseX	dw	0
MouseY	dw	0
MouseStat:
	pushad
	mov	bh,UpdateMouse
	xor	bl,bl
	or	MouseX,bx
	mov	UpdateMouse,0
	cmp	HourGlass,1
	jz	NoDragDrop
	cmp	DragNumber,0	       ;Action=0 -> do nothing
	jz	NoDragDrop
	cmp	PressCheck,0
	jz	NoPC
	cmp	byte ptr [Keys+2ah],1
	jz	DragMove
	cmp	byte ptr [Keys+1dh],1
	jz	DragCopy
	cmp	byte ptr [Keys+38h],1
	jz	DragShadow
	jmp	PC
NoPC:
	cmp	ShiftPress,1
	jz	DragMove
	cmp	CtrlPress,1
	jz	DragCopy
	cmp	AltPress,1
	jz	DragShadow
PC:
	mov	PressCheck,0
	mov	[DragNumber],0		;No Action
	mov	[DragNumber+4],0	;Nr
	mov	[DragNumber+8],0	;Nothing
	mov	MouseX,-1
	mov	MouseCursor,0
	jmp	NoDragDrop
DragShadow:
	mov	MouseCursor,6
	jmp	NoDragDrop
DragMove:
	mov	MouseCursor,2
	jmp	NoDragDrop
DragCopy:
	mov	MouseCursor,3
NoDragDrop:
	mov	ax,3		;Get Button Status and Mouse Position
	int	33h
	cmp	bx,4
	jb	NoMouseFix
	mov	bx,0
NoMouseFix:
	cmp	FlipButtons,0
	jz	@@NoFlip
	ror	bx,1
	ror	bh,6
	or	bl,bh
	and	bx,3
@@NoFlip:
	mov	MouseB,bx
	cmp	MouseX,cx
	jnz	PutItInMe
	cmp	MouseY,dx
	jnz	PutItInMe
	popad
	ret
PutItInMe:
	cmp	MouseOnOff,0
	jz	AXEV„xel2
	cmp	HourGlass,1
	jz	AXEV„xel
	call	PutMouseBackground
AXEV„xel:
	mov	MouseX,cx
	mov	MouseY,dx
	cmp	HourGlass,1
	jz	AXEV„xel2
	call	GetMouseBackground
	call	PutMouse
AXEV„xel2:
	popad
	ret

Original	db	20,5,1
LeftKeyWait	db	1	;Button Repeats
RightKeyWait	db	1
BothKeyWait	db	1
DClickCounter	db	0	;Counter For DoubleClick
DoubleClick	db	0	;1 if a doubleclick
AmigaOkay	db	0	;1 if okay to update dragbars...
MouseOnceReleased	db	0
DoubleClickExpired	db	0
NoHit		db	0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;The Mouse Handler Routine
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MouseHandler	 Proc	 Near

	cmp	MouseB,0			;No Button
	jz	NoMoreMouse3


	mov	ButtonCheck,1
	cmp	ButtonHandlerStatus,1		;check if the mouse handler
	jz	nomoremouse			;is activated
	cmp	ButtonHandlerStatus,2
	jz	SkipDClick
	cmp	screenmarking,1
	jz	_ret

	cmp	MouseB,1
	jnz	SkipDClick

	cmp	DoubleClick,1
	jz	_ret
SkipDClick:

	cmp	MouseB,3
	jz	Skipp

	cmp	InputRepeatFix,1
	jz	_ret
Skipp:
	cmp	Pegsmoving,0
	jnz	_ret


	cmp	peggamove,0
	jnz	_ret

	;cmp	skojaren,0
	;jnz	_ret

	cmp	dragbarmouse,0
	jnz	_ret

	cmp	CaugthDragbar,1
	jz	NoMoreMouse

	cmp	AmigaDragbar,1
	jz	IfISayIt

	cmp	MouseOnDragBar,0
	jg	NoMoreMouse

IfISayIt:
	movzx	ebx,MouseB
	dec	ebx
	dec	[LeftKeyWait+ebx]
	jnz	_ret
	mov	al,[Original+ebx]
	mov	[LeftKeyWait+ebx],al
	mov	AmigaOkay,1

	cmp	MouseOnDragBar,0
	jle	NotOnDragBar

	cmp	AmigaDragbar,1
	jz	_ret

NotOnDragBar:
	cmp	MouseOnDragBar,0
	jl	NoInput
	jnz	NoMoreMouse

	cmp	InitInput,1
	jnz	NoInput
	call	InputRoutine
NoInput:
	cmp	DClickCounter,0
	jz	NoDoubleClick
	cmp	MouseOnceReleased,0
	jz	DontRetrigDclick
	mov	DoubleClick,1
NoDoubleClick:
	cmp	DoubleClickExpired,1
	jz	DontRetrigDclick
	mov	DClickCounter,30
DontRetrigDclick:

	cmp	MouseOnDragBar,-1
	jz	FileListSquare
	cmp	MouseOnDragBar,-2
	jz	MovePoint
	cmp	MouseOnDragBar,-3
	jz	ScrollPattern
	cmp	MouseOnDragBar,-4
	jz	EQEdDraw
	cmp	MouseOnDragBar,-5
	jz	MasterCurveSelect
	cmp	MouseOnDragBar,-6
	jz	SelectEnvCurve

	cmp	NoHit,1
	jz	_ret

	cmp	Menu_PopUp,0			;Check PopUp
	jz	NoPopUp
	movzx	esi,Menu_PopUp
	dec	esi
	mov	esi,[PopUpTable+esi*4]
	call	SearchMousePress
	cmp	ebx,0
	jz	NoHitMouse
	jmp	ebx

NoPopUp:
	lea	esi,BlockTable
	call	SearchMousePress
	movzx	ebp,word ptr [esi+8]
	movzx	ebx,word ptr [esi+10]
	cmp	ebx,2
	mov	bx,Word Ptr [CurrentMenu+ebx*2]
	jnz	NoMainScreenSpecialCheck
	cmp	ebx,0
	jnz	FixSpecialScreen

	cmp	ebp,3
	jz	NoMainScreenSpecialCheck
	cmp	ebp,4
	jnz	NoPiano
	mov	ebx,PianoScreen
	jmp	NoMainScreenSpecialCheck
NoPiano:
	mov	ebx,SampnameScreen
	jmp	NoMainScreenSpecialCheck
FixSpecialScreen:
	mov	ebp,3
NoMainScreenSpecialCheck:
	mov	ebp,[SubMenuTBL+ebp*4]
	mov	esi,[ebp+ebx*4]
	call	SearchMousePress
	cmp	ebx,0
	jz	NoHitMouse
	jmp	ebx

SearchMousePress:
	xor	ebx,ebx
	sub	esi,12
NextMouse:
	add	esi,12
	mov	ax,[esi]
	cmp	ax,-1
	jz	NoMoreMouseSearch
	cmp	ax,MouseX
	ja	NextMouse
	mov	ax,[esi+2]
	cmp	ax,MouseY
	ja	NextMouse
	mov	ax,[esi+4]
	cmp	ax,MouseX
	jb	NextMouse
	mov	ax,[esi+6]
	cmp	ax,MouseY
	jb	NextMouse
	mov	ebx,[esi+8]

	movzx	eax,word ptr [esi]			 ;save coords
	mov	ButtonHandlerX1,eax
	mov	ax,[esi+2]
	mov	ButtonHandlerY1,eax
	mov	ax,[esi+4]
	mov	ButtonHandlerX2,eax
	mov	ax,[esi+6]
	mov	ButtonHandlerY2,eax
NoMoreMouseSearch:
	ret

NoMoreMouse3:
	mov	OldMousePos,-1
	mov	DoubleClick,0
	mov	DoubleClickExpired,0
	cmp	LastPianoMouse,0
	jz	NoPianoPress
	mov	LastPianoMouse,0
	movzx	edi,CursorChannel
	mov	[KeyOffTable+edi],0

	movzx	ebx,byte ptr [CurrInst+edi]
	GetOffset ebx,eax,ENV_Flags
	bt	word ptr [eax],2			;Check Envelope ON
	jc	NoPianoPress
	cmp	SenseKeyOff,0
	jz	NoPianoPress
	mov	ecx,edi
	inc	ecx
	call	StopOneVoice

NoPianoPress:
	mov	NoHit,0
	mov	InputRepeatFix,0
	mov	CaugthDragbar,0
	cmp	PressedOnce,1
	jz	NoMoreMouse4
	cmp	PressedOnce,2
	jz	NoMoreMouse5
	cmp	DClickCounter,0
	jz	NoMoreMouse2
	mov	MouseOnceReleased,1
	jmp	NoMoreMouse2
NoMoreMouse5:
	mov	DclickCounter,0
NoMoreMouse4:
	mov	PressedOnce,0
	mov	MouseOnceReleased,0
NoMoreMouse2:
	mov	MouseOnDragBar,0
NoMoreMouse:
	mov	LeftKeyWait,1
	mov	RightKeyWait,1
	mov	BothKeyWait,1
	Ret
NoHitMouse:
	mov	NoHit,1
	Ret
MouseHandler  EndP

;LoadInfoBlock1	Proc	Near
;	pushad
;	lea	edx,PicturesFileName
;	call	FixPathFile
;	lea	edx,NewFileName

;	call	_OpenFileR
;	mov	ax,OpenErr
;	jc	ErrorHandler

;	call	_filesize
;	sub	eax,DatFileSize
;	sub	eax,FontFileSize
;	sub	eax,KeyMapFileSize
;	sub	eax,InfoBlockSize
;	sub	eax,InfoBlockSize
;	mov	bl,0
;	call	_LseekFile
;	mov	ax,SeekErr
;	jc	ErrorHandler

;	mov	ecx,700
;	lea	edx,InfoBlockBuffer1
;	call	_readfile
;	mov	ax,ReadErr
;	jc	ErrorHandler

;	call	_closefile
;	mov	ax,CloseErr
;	jc	ErrorHandler

;	popad
;	ret
;LoadInfoBlock1	EndP


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Just waits for the vertical retrace
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Sync	Proc	Near
	Pusha
	Mov	Dx,3dah
@l1:
	In	Al,dx
	Test	Al,8
	Jne	@l1
@l2:
	In	Al,dx
	Test	Al,8
	Je	@l2
	Popa
	Ret
EndP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
StartOld		dd	$
OldRow			dw	-1
OldPos			dw	-1
OldPos2 		dw	-1
OldPatt 		dw	-1
OldPatt2		dw	-1
OldPattName		db	-1
OldLen			dw	-1
OldBPM			dw	-1
OldSpeed		db	-1
OldBPMSave		dw	-1
OldCurrentInstrument	db	0
OldCurrentSample	dw	0
OldCurrentSampName	dw	0
OldCurrentInstName	db	-1
OldCurrentChannel	db	-1
OldCurrentFileName	dw	-1
OldCurrentDescLine	dd	-1
OldCurrentDescSize	dd	-1
OldTime_Hour		db	-1
OldTime_Min		db	-1
OldTime_Sec		db	-1
OldMasterVolume 	db	-1
OldInfoTextPtr		dd	-1
EndOld			dd	$
UpdateDifferentStuff	 Proc	 Near
	Pushad

IFE	RELEASE
	cmp	[Keys+2ah],1
	jnz	NoDumpCtrl

	cmp	[Keys+41],1
	jnz	NoDumpCtrl
	call	dumpit
NoDumpCtrl:

ENDIF

	cmp	menu_popup,41
	jz	skipmovecursor2
	cmp	menu_popup,39
	jz	skipmovecursor2
	cmp	menu_popup,29
	jz	skipmovecursor2
	call	GetSampOffset
skipmovecursor2:

	call	UpdateEqualizers	;1
	call	UpdateOverViewEQ	;2
	call	UpdateVolumeValues	;3

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  Pattern Update  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	cmp	Menu_DownScreen,3		;Check
	ja	PatternInfoUpdate

	cmp	MouseOnDragBar,1
	jnz	Quit1

	xor	ebx,ebx 			;Check PatternDragBar
	mov	ExtraLength,1
	mov	AmigaLength,4
	call	DragBarHandler
	mov	eax,Dword Ptr [DragBarTable+ebx+10] ;New Pos
	cmp	ax,CurrRow
	jz	Quit2
	mov	CurrRow,ax
	call	PosInit
	jmp	Quit2
Quit1:
	cmp	MouseOnDragBar,2		;Check PositionDragBar
	jnz	Quit2
	mov	ebx,1*24
	movzx	eax,Positions
	mov	dword ptr [DragBarTable+ebx+6],eax ;Max Pos
	mov	ExtraLength,1
	mov	AmigaLength,1
	call	DragBarHandler
	mov	eax,Dword Ptr [DragBarTable+ebx+10] ;New Pos
	cmp	ax,CurrPosition
	jz	Quit2
	mov	CurrPosition,ax
	mov	OldRow,-1
	mov	OldPos,-1

	cmp	JumpToStart,0
	jz	OrdPos1
	mov	ax,CurrRow
	mov	GotoRow,ax
	call	PosInit
	jmp	Quit3
OrdPos1:
	mov	CurrRow,0
	mov	GotoRow,0
	call	ClearForPlay
	call	PosInit
	jmp	Quit3
Quit2:
	mov	ax,CurrPosition
	cmp	ax,OldPos
	jz	Quit3
	mov	ebx,1*24			;Update PosDragbar
	movsx	eax,Positions
	mov	dword ptr [DragBarTable+ebx+6],eax ;Max Pos
	movzx	eax,CurrPosition
	mov	Dword Ptr [DragBarTable+ebx+10],eax
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	mov	ExtraLength,1
	call	DragBarHandler
	mov	MouseOnDragBar,al
	call	UpdateChannelInfo
Quit3:
	movzx	eax,CurrentChannel	     ;Update ChannelDragBar
	cmp	al,OldCurrentChannel
	jz	Quit4
	mov	OldCurrentChannel,al

	call	UpdateChannelInfo
	mov	OldRow,-1

	push	eax
	movzx	ebx,Menu_DownScreen
	add	ebx,2
	mov	eax,13*4
	mul	ebx
	mov	ebx,eax
	pop	eax

	mov	[DragBarData+ebx],eax
	movzx	eax,Channels
	add	al,MIDIChannels
	mov	[DragBarData+ebx+8],eax
	mov	[DragBarData+ebx+4],1

	cmp	al,6
	jb	NoBugFix2
	mov	al,6
NoBugFix2:
	mov	[DragBarData+116],eax
	mov	[DragBarData+168],eax

Quit4:

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PattInfo Update ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PatternInfoUpdate:
Quit5:

	movzx	ebx,CurrPosition	;Update Current Position
	cmp	bx,OldPos
	jz	Quit6
	mov	OldPos,bx

	cmp	PosedInput,1
	jz	QuitSSA
	mov	OldPos2,-1
	mov	CurrCursorPosition,bx
	mov	ax,CurrStartPosition
	cmp	bx,ax
	ja	Posit_IsBelow
	mov	CurrStartPosition,bx
	jmp	QuitSSA
Posit_IsBelow:
	add	ax,6
	cmp	bx,ax
	jb	QuitSSA
	sub	bx,6
	mov	CurrStartPosition,bx
QuitSSA:

	cmp	DigitInput,1
	jz	Quit6

	mov	ah,08h
	mov	cl,5
	move	edi,0a0000h+21*80+10
	movzx	ebx,CurrPosition
	call	MouseOff
	call	PutDecimal
	call	MouseOn

Quit6:
	mov	bx,CurrPatt		;Update Current Pattern
	cmp	bx,OldPatt
	jz	Quit7

	cmp	DigitInput,2
	jz	Quit7
	mov	OldPatt,bx
	mov	ah,08h
	mov	cl,4
	move	edi,0a0000h+38*80+88/8
	call	MouseOff
	call	PutDecimal
	call	MouseOn
Quit7:
	movzx	ebx,Positions
	cmp	bx,OldLen
	jz	Quit7_1
	cmp	DigitInput,3
	jz	Quit7_1
	mov	OldLen,bx
	mov	ah,08h
	mov	cl,5
	move	edi,0a0000h+55*80+10	;Update Length
	call	MouseOff
	call	PutDecimal
	call	MouseOn
Quit7_1:
	mov	ax,ModTempo		;Update BPM
	cmp	ax,OldBPM
	jz	Quit8
	cmp	TempoDisabled,0
	jz	NotDisabled
	mov	ax,ModTempo
	mov	OldBPMSave,ax
	and	eax,0ffffh
	mov	ModTempo,7d00h
	mov	HertzAdder,7d00h
	mov	OldBPM,7d00h
	mov	ah,08h
	move	edi,0a0000h+72*80+10
	call	MouseOff
	mov	cl,5
	lea	esi,Off
	call	PrintText
	call	MouseOn
	jmp	Quit8

NotDisabled:
	cmp	DigitInput,4
	jz	Quit8
	cmp	OldBpm,1
	jnz	Knutsson
	mov	ax,OldBpmSave
	mov	ModTempo,ax
	mov	HertzAdder,ax
Knutsson:
	mov	ax,ModTempo
	mov	OldBPM,ax
	mov	ah,08h
	mov	cl,3
	move	edi,0a0000h+(21+17*3)*80+10
	movzx	ebx,ModTempo
	shr	bx,8
	call	MouseOff
	call	PutDecimal
	add	edi,3
	mov	ebx,'.'
	call	PutCharacter
	inc	edi
	movzx	ebx,ModTempo
	and	ebx,0ffh
	mov	eax,26
	xchg	ebx,eax
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	mov	ah,08h
	mov	cl,1
	call	PutDecimal
	call	MouseOn
Quit8:
	mov	bl,ModSpeed
	cmp	bl,OldSpeed
	jz	Quit88
	mov	OldSpeed,bl

	mov	ah,08h
	mov	cl,2
	move	edi,0a0000h+(21+17+17+17)*80+4
	call	MouseOff
	and	ebx,0ffh
	call	PutDecimal
	call	MouseOn

Quit88:
	movzx	ebx,CurrPatt2
	cmp	bx,OldPatt2
	jz	Quit8_1
	mov	OldPatt2,bx
	call	PrintPattInfo
	mov	OldCurrentChannel,-1
	mov	OldPattName,-1

	movzx	ecx,Channels
	mov	al,Commands
	dec	al
FixTheComamnd:
	cmp	al,[Cmd+ecx-1]
	jae	Fatima
	mov	[Cmd+ecx-1],al
	cmp	ArrowPointer,0
	jz	Fatima
	shl	al,2
	add	al,3
	mov	ArrowPointer,al
Fatima:
	loop	FixTheComamnd

	cmp	Zoom,1
	jz	OhDamn
	mov	bl,Channels
	mov	bh,CurrentChannel
	add	bh,6
	cmp	bl,bh
	jae	Quit8_2
	sub	bl,6
	jge	Hubbe
	mov	bl,0
Hubbe:
	mov	CurrentChannel,bl
Quit8_2:
	mov	bl,Channels
	dec	bl
	cmp	bl,CursorChannel
	jae	Quit8_1
	mov	CursorChannel,bl
	jmp	Quit8_1
OhDamn:
	mov	bl,Channels
	dec	bl
	cmp	bl,CursorChannel
	jae	Damn1
	mov	CursorChannel,bl
Damn1:
	cmp	bl,CurrentChannel
	jae	Quit8_1
	mov	CurrentChannel,bl
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Upper Right Update ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Quit8_1:
	cmp	Menu_UpperScreen,0		;Check
	jnz	UpdateFileRequester

	cmp	MouseOnDragbar,3	;Check InstNameDragBar
	jnz	Quit9
	mov	ebx,2*24		;DB #
	movzx	eax,Samples
	mov	dword ptr [DragbarTable+ebx+6],eax
	movzx	eax,CurrentInstName
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	ExtraLength,12
	mov	AmigaLength,12
	call	DragBarHandler
	mov	eax,Dword Ptr [DragbarTable+ebx+10]
	cmp	eax,0
	jge	Noppe
	xor	eax,eax
Noppe:
	cmp	al,OldCurrentInstName
	jz	Quit9
	mov	CurrentInstName,al
	mov	OldCurrentInstName,al
	call	UpdateInstNames
Quit9:
	cmp	MouseOnDragbar,6	;Check MasterVolumeDragBar
	jnz	Quit9_2
	mov	ebx,5*24		;DB #
	mov	ExtraLength,1
	mov	AmigaLength,10
	call	DragBarHandler
	mov	eax,127
	sub	eax,Dword Ptr [DragbarTable+ebx+10]
	cmp	al,OldMasterVolume
	jz	Quit9_3
	mov	MasterVolume,al
	mov	EnvVolCheck,-1
	jmp	Quit9_3
Quit9_2:
	mov	al,MasterVolume 	    ;Update MasterVolumeDragBar
	cmp	al,OldMasterVolume
	jz	Quit9_3
	cmp	menu_popup,0
	jnz	Quit9_3
	mov	OldMasterVolume,al
	mov	eax,127
	sub	al,OldMasterVolume

	mov	ebx,5*24
	mov	Dword Ptr [DragBarTable+ebx+10],eax
	mov	ExtraLength,0
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	call	DragBarHandler
	mov	MouseOnDragBar,al
Quit9_3:
	mov	al,CurrentInstName    ;Update InstNameDragbar
	cmp	al,OldCurrentInstName
	jnz	NoQuit2
	mov	bl,CurrentInstrument
	cmp	bl,OldCurrentInstrument
	jz	Quit10
	mov	OldCurrentInstrument,bl
NoQuit2:
	mov	OldCurrentInstName,al
	mov	ebx,2*24	;DB #
	movzx	eax,Samples
	mov	dword ptr [DragbarTable+ebx+6],eax
	movzx	eax,CurrentInstName
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	mov	ExtraLength,12
	call	DragBarHandler
	mov	MouseOnDragBar,al
	call	UpdateInstNames
Quit10:
;	cmp	DoublePopup,1
;	jz	Quit13
	mov	al,Time_Hour		;Check Hour
	cmp	al,OldTime_Hour
	jz	Quit11_2
	mov	OldTime_Hour,al
	movzx	ebx,al
	mov	ah,08h
	mov	cl,2
	move	edi,0a0000h+171*80+344/8
	mov	MouseX1,342
	mov	MouseY1,169
	mov	MouseX2,362
	mov	MouseY2,183
	call	MouseOff
	call	PutDecimal
	call	MouseOn
	call	MouseReset
Quit11_2:
	mov	al,Time_Min		;Check Minutes
	cmp	al,OldTime_Min
	jz	Quit12
	mov	OldTime_Min,al
	movzx	ebx,al
	mov	ah,08h
	mov	cl,2
	move	edi,0a0000h+171*80+368/8
	mov	MouseX1,366
	mov	MouseY1,169
	mov	MouseX2,386
	mov	MouseY2,183
	call	MouseOff
	call	PutDecimal
	call	MouseOn
	call	MouseReset
Quit12:
	mov	al,Time_Sec		;Check Seconds
	cmp	al,OldTime_Sec
	jz	Quit13
	mov	OldTime_Sec,al
	movzx	ebx,al
	mov	ah,08h
	mov	cl,2
	move	edi,0a0000h+171*80+392/8
	mov	MouseX1,390
	mov	MouseY1,169
	mov	MouseX2,410
	mov	MouseY2,183
	call	MouseOff
	call	PutDecimal
	call	MouseOn
	call	MouseReset
Quit13:
	cmp	PrintBlock,0
	jz	Quit14_1

	mov	cl,CursorChannel
	cmp	MM_ChanStart,cl
	jz	@@Skippa
	mov	MM_ChanStart,cl
	mov	MM_ChanEnd,cl
	mov	MM_ChanPress,cl
	mov	oldrow,-1
@@Skippa:
	movzx	ebx,BlockStartRow
	movzx	ebp,CurrRow
	cmp	ebx,ebp
	jbe	NoSwapping
	xchg	ebx,ebp
NoSwapping:
	mov	ah,8
	mov	cl,3
	move	edi,0a0000h+170*80+160/8+4
	cmp	RowsHexDec,1
	jz	PrintRowsHex
	call	PutDecimal
	add	edi,7
	mov	ebx,ebp
	call	PutDecimal
	jmp	Quit14_1
PrintRowsHex:
	mov	cl,2
	call	PutHex
	add	edi,7
	mov	ebx,ebp
	call	PutHex

Quit14_1:
	cmp	PrintBlock,1
	jz	Quit14_2
	mov	eax,InfoTextPtr
	cmp	eax,OldInfoTextPtr
	jz	Quit14_2
	mov	OldInfoTextPtr,eax
	mov	ah,8
	move	edi,0a0000h+170*80+160/8
	mov	cl,14
	mov	esi,InfoTextPtr
	call	mouseoff
	call	PrintText
	movzx	ebx,Octave
	mov	cl,1
	move	edi,0a0000h+170*80+160/8+4
	call	PutDecimal
	add	edi,7

	mov	esi,KeyBoardNote	;Get Period
	mov	BitPlane,8
	call	PrintPeriod
	call	mouseon
Quit14_2:
	cmp	TuneStopped,1
	jz	UpdatePiano

	call	IndicateTime

	mov	eax,ANewSecond
	cmp	eax,-1
	jz	UpdatePiano

	mov	ebx,3600
	xor	edx,edx
	div	ebx
	mov	Time_Hour,al
	mov	eax,edx
	mov	ebx,60
	xor	edx,edx
	div	ebx
	mov	Time_Min,al
	mov	Time_Sec,dl

UpdatePiano:
	cmp	PianoScreen,1
	jnz	UpdateFileRequester
	call	UpdatePianoPress

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ File Requester ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
UpdateFileRequester:
	cmp	Menu_UpperScreen,3		;Check
	jnz	UpdatePosEditor

	cmp	MouseOnDragbar,5
	jnz	Quit15

	mov	ebx,4*24			   ;Check FileNamesDragBar
	mov	ExtraLength,12
	mov	AmigaLength,12
	call	DragBarHandler
	mov	eax,Dword Ptr [DragBarTable+ebx+10] ;New Pos
	cmp	ax,0
	jl	Quit15
	cmp	ax,OldCurrentFileName
	jz	Quit15
	mov	CurrentFileName,ax
	mov	OldCurrentFileName,ax
	call	UpdateFileList
Quit15:
	movzx	eax,CurrentFileName
	cmp	ax,OldCurrentFileName
	jz	Quit16
	mov	ebx,4*24			;Check FileNamesDragBar
	mov	ExtraLength,12
	mov	Dword Ptr [DragBarTable+ebx+10],eax	;New Pos
	mov	OldCurrentFileName,ax
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	call	DragBarHandler
	mov	MouseOnDragBar,al
	call	UpdateFileList
Quit16:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Position Editor ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
UpdatePosEditor:
	cmp	Menu_UpperLeft,0
	jz	UpdateOtherStuff
	cmp	Menu_UpperLeft,3
	jz	UpdateOtherStuff
	cmp	Menu_UpperLeft,1
	jnz	Quit18
	cmp	menu_popup,0
	jz	ContPosUpd
	mov	[CheckTable],12
	mov	[CheckTable+4],133
	mov	[CheckTable+8],13
	mov	[CheckTable+12],184
	call	CheckAgainstPopup
	jc	UpdateOtherStuff
ContPosUpd:
	cmp	MouseOnDragBar,8	;Check PositionDragBar
	jnz	Quit17
	mov	ebx,7*24
	movzx	eax,Positions
	mov	dword ptr [DragBarTable+ebx+6],eax ;Max Pos
	mov	ExtraLength,7
	mov	AmigaLength,7
	call	DragBarHandler
	mov	eax,Dword Ptr [DragBarTable+ebx+10] ;New Pos
	cmp	ax,CurrStartPosition
	jz	Quit17
	cmp	ax,Positions
	ja	Quit17
	mov	CurrStartPosition,ax
	call	ShowPosList
Quit17:
	mov	ax,CurrStartPosition
	cmp	ax,OldPos2
	jz	Quit18
	mov	OldPos2,ax

	mov	ebx,7*24
	movzx	eax,Positions
	mov	dword ptr [DragBarTable+ebx+6],eax ;Max Pos
	movzx	eax,CurrStartPosition
	mov	Dword Ptr [DragBarTable+ebx+10],eax
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	mov	ExtraLength,7
	call	DragBarHandler
	mov	MouseOnDragBar,al
	call	ShowPosList
Quit18:
	cmp	OldPattName,0
	jz	Quit19
	mov	OldPattName,0
	movzx	ebx,CurrPatt2
	mov	esi,[AllocTable+ebx*8]
	cmp	esi,0
	jnz	NoEmptyPattern3
	mov	esi,EmptyPattern
NoEmptyPattern3:
	mov	ah,1
	mov	cl,10
	move	edi,0a0000h+208*80+32/8
	call	MouseOff
	call	printtext
	call	MouseOn
Quit19:


UpdateOtherStuff:
	call	buttonhandler2
	call	fixbutton2

	cmp	mouseB,0
	jnz	nomousechange
	mov	xposa,0
	mov	nomouseon,0
	call	mouseon
	mov	pegsmoving,0
	cmp	markstartX,-1
	jz	skipupdatecurve
skipupdatecurve:
	mov	markstartX,-1
	mov	invertbyte,0
nomousechange:

	cmp	mouseB,0
	jz	nopegmove
	cmp	pegsmoving,0
	jz	nopegmove
	call	movepegs
nopegmove:

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Keys Config ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

							;move some stuff
;xxxxxxxxxxxxxxxxxxxxxxxx
	cmp	menu_popup,8
	jnz	quit16_2XXRR
	cmp	mouseondragbar,10
	jnz	Quit15_2XXRR

;	mov	ax,mousey
       ; cmp	 ax,descmousepos
       ; jz	 quit15_2xxRR
       ; mov	 descmousepos,ax

	mov	ebx,9*24
	mov	ExtraLength,16
	mov	AmigaLength,16
	call	DragBarHandler
	mov	eax,Dword Ptr [DragBarTable+ebx+10] ;New Pos
	cmp	eax,KeyLinePoint
	jz	quit15_2xxRR
	cmp	eax,0
	jl	quit15_2xxRR
	mov	KeyLinePoint,eax
	add	eax,keylinepoint
	inc	eax
	call	updatekeytext
	jmp	Quit16_2XXRR
Quit15_2XXRR:
	mov	ebx,9*24
	mov	eax,NumberOfKeyLines
	mov	dword ptr [DragBarTable+ebx+6],eax
	mov	eax,KeyLinePoint
	cmp	eax,OldkeyLinePoint
	jz	Quit16_2XXRR
NoDescPloppRR:
	mov	ExtraLength,16
	mov	Dword Ptr [DragBarTable+ebx+10],eax	;New Pos
	mov	OldKeyLinePoint,eax
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	call	DragBarHandler
	mov	MouseOnDragBar,al
Quit16_2XXRR:

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Option dragbar 1 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

							;move some stuff
	cmp	Menu_Popup,11
	jnz	Quit16_OptDrag1
	cmp	MouseOnDragbar,38
	jnz	Quit15_OptDrag1

	mov	ebx,37*24
	cmp	Dword Ptr [DragBarTable+ebx+6],16
	jbe	Quit15_OptDrag1
	mov	ExtraLength,16
	mov	AmigaLength,16
	call	DragBarHandler
	mov	eax,Dword Ptr [DragBarTable+ebx+10]	;New Pos
	mov	CurrentOptionList,eax
Quit15_OptDrag1:

	mov	ebx,37*24
	mov	eax,CurrentOptionList
	cmp	eax,OldCurrentOptionList
	jz	Quit16_OptDrag1
	mov	OldCurrentOptionList,eax
	mov	ExtraLength,16
	mov	Dword Ptr [DragBarTable+ebx+10],eax	;New Pos
;	mov	oldkeylinepoint,eax
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	call	DragBarHandler
	mov	MouseOnDragBar,al
	call	UpdateOptionText1
Quit16_OptDrag1:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Option dragbar 2 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
							;move some stuff
	cmp	menu_popup,11
	jnz	quit16_OptDrag2
	cmp	mouseondragbar,39
	jnz	Quit15_OptDrag2

	mov	ebx,38*24
	cmp	[Dragbartable+ebx+6],7
	jbe	Quit15_OptDrag2
	mov	ExtraLength,7
	mov	AmigaLength,7
	call	DragBarHandler
	mov	eax,Dword Ptr [DragBarTable+ebx+10]	;New Pos
	mov	CurrentHelpList,eax
Quit15_OptDrag2:

	mov	ebx,38*24
	mov	eax,CurrentHelpList
	cmp	eax,OldCurrentHelpList
	jz	Quit16_OptDrag2
	mov	OldCurrentHelpList,eax
	mov	ExtraLength,7
	mov	Dword Ptr [DragBarTable+ebx+10],eax	;New Pos
;	mov	oldkeylinepoint,eax
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	call	DragBarHandler
	mov	MouseOnDragBar,al
	call	UpdateOptionText3
Quit16_OptDrag2:
;----------------------------------------------


	cmp	menu_popup,41
	jz	skipmovecursor
	cmp	menu_popup,39
	jz	skipmovecursor
	cmp	menu_popup,29
	jz	skipmovecursor
	cmp	menu_downscreen,5
	jz	skipthiscmp__
	cmp	menu_downscreen,4
	jnz	skipmovecursor
skipthiscmp__:
	mov	eax,curradd
	cmp	eax,playoffold
	jz	skipmovecursor
	mov	playoffold,eax
	mov	playpegoff,eax
	mov	peghide,0
	mov	themovepeg,3
	cmp	downindicate,1
	jz	skipmovecursor
	cmp	Menu_popup,39
	jz	skipmovecursor
	cmp	Menu_popup,41
	jz	skipmovecursor
	cmp	Menu_popup,29
	jz	skipmovecursor
	cmp	Menu_popup,35
	jz	skipmovecursor
	cmp	Menu_popup,38
	jz	skipmovecursor
	call	movethepegs
skipmovecursor:
	call	putequalizer

	lea	eax,ShowRealModName
	cmp	optionchangeoffset,eax
	jnz	NoFuckMyCousin2
	mov	FileListStart,0
	mov	DontReadFileList,2
	mov	optionchangeoffset,0
NoFuckMyCousin2:

	lea	eax,MultiChanPlay
	cmp	optionchangeoffset,eax
	jnz	NoFuckMyCousin7
	mov	optionchangeoffset,0
	lea	edi,MIDIPriority
	mov	ecx,32
	xor	ax,ax
	rep	stosw
	mov	Priority,0
NoFuckMyCousin7:

	lea	eax,FontSelect
	cmp	optionchangeoffset,eax
	jnz	NoFuckMyCousin8
	mov	optionchangeoffset,0
	call	LoadFonts
	call	UpdateOptionScreen
	call	UpdateChannelInfo
	call	PrintAllEnvelopeNumbers
	call	PrintNames
	call	PrintShadowNR
	call	PrintModName
	call	PrintComposer
	call	PrintRowAdd
	mov	OldRow,-1
	mov	oldpos,-1
	mov	OldLen,-1
	mov	OldBPM,-1
	mov	OldSpeed,-1
	mov	OldCurrentFileName,-1
	mov	OldCurrentInstName,-1
	lea	eax,desctable
	mov	DescNowOffset,eax
	call	DrawDesc
	mov	oldpos2,-1
	lea	edi,oldputs
	mov	eax,-1
	mov	ecx,20
	rep	stosd

	push	esi
	mov	ah,18h
	mov	cl,MainPullTextLength
	move	edi,0a0000h+(3*80)
	lea	esi,MainPullText
	call	PrintPullText
	call	PutVersionText		; Update version on menu bar
	pop	esi

NoFuckMyCousin8:

	lea	eax,FontSelect2
	cmp	optionchangeoffset,eax
	jnz	NoFuckMyCousin9
	mov	optionchangeoffset,0
	call	LoadFonts
	call	UpdateOptionScreen
	call	UpdateChannelInfo
	call	PrintAllEnvelopeNumbers
	call	PrintNames
	call	PrintShadowNR
	call	PrintRowAdd
	mov	OldRow,-1
	mov	OldSpeed,-1
	lea	eax,desctable
	mov	DescNowOffset,eax
	call	DrawDesc
	lea	edi,oldputs
	mov	eax,-1
	mov	ecx,20
	rep	stosd
NoFuckMyCousin9:

	call	ADCSample	;Update sampling
	call	UpdateMIDI	;Check MIDI

	cmp	menu_popup,13
	jnz	skipstartsamp
	cmp	mouseB,2
	jnz	skipstartsamp
	;call	 starttosamp2
skipstartsamp:

	cmp	menu_popup,14
	jnz	skippastoppa
	cmp	sampling,1
	jnz	skippastoppa
	call	endstarttosamp2
skippastoppa:

	call	movesampledata
	cmp	menu_popup,14
	jnz	nonomm
	mov	eax,samplength
	mov	viewsamplength,eax
	mov	sampmarkstart,-1
nonomm:
	mov	ebx,ymoveup
	cmp	ebx,oldymoveup
	jz	skipsetsnulle1
	mov	oldymoveup,ebx
	cmp	ymoveup,65535
	jbe	boja1
	mov	ymoveup,65535
	mov	oldymoveup,65535
boja1:
	call	updateynumbers
	jmp	skipsetsnulle2
skipsetsnulle1:
	mov	ebx,ymovedown
	cmp	ebx,oldymovedown
	jz	skipsetsnulle2
	mov	oldymovedown,ebx
	cmp	ymovedown,65535
	jbe	boja2
	mov	ymovedown,65535
	mov	oldymovedown,65535
boja2:
	call	updateynumbers

skipsetsnulle2:
;----------------------------------------------------
;	movzx	eax,mouseY
;	mov	ebx,256
;	mul	ebx
;	mov	ebx,479
;	div	ebx
;	mov	leftequalizer,eax
;	movzx	eax,mouseX
;	mov	ebx,256
;	mul	ebx
;	mov	ebx,639
;	div	ebx
;	mov	rightequalizer,eax
	call	putequalizers
;	call	insertscopes
	call	putscopes


	cmp	menu_downscreen,4		;updatevalues
	jnz	endofview2_
	call	updatevalues
endofview2_:
	call	updatevolume
	call	movevolume


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Envelope Editor ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cmp	menu_DownScreen,7
	jnz	EnvedQuit10

	mov	ax,VolEnvStartCoord
	cmp	ax,OldVolEnvStartCoord
	jz	EnvQuit1
	mov	OldVolEnvStartCoord,ax
	mov	Envelope,0
	call	MoveEnvData
EnvQuit1:

	mov	ax,PanEnvStartCoord
	cmp	ax,OldPanEnvStartCoord
	jz	EnvQuit2
	mov	OldPanEnvStartCoord,ax
	mov	Envelope,1
	call	MoveEnvData
EnvQuit2:

	cmp	MouseOnDragbar,40	;Check SampNameDragBar
	jnz	EnvedQuit9
	mov	ebx,39*24		;DB #
	mov	eax,16
	mov	dword ptr [DragbarTable+ebx+6],eax
	mov	ax,CurrentSampName
	and	eax,0fh
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	ExtraLength,8
	mov	AmigaLength,8
	call	DragBarHandler
	mov	eax,Dword Ptr [DragbarTable+ebx+10]
	movzx	edx,CurrentInstrument
	shl	edx,4
	add	eax,edx
	cmp	ax,OldCurrentSampName
	jz	EnvedQuit9
	mov	CurrentSampName,ax
	mov	OldCurrentSampName,ax
	call	UpdateSampNames
EnvedQuit9:
	mov	ax,CurrentSampName    ;Update SampNameDragbar
	cmp	ax,OldCurrentSampName
	jnz	EnvedNoQuit2
	mov	bx,CurrentSample
	cmp	bx,OldCurrentSample
	jz	EnvedQuit10
	mov	OldCurrentSample,bx
EnvedNoQuit2:
	mov	OldCurrentSampName,ax
	mov	ebx,39*24		;DB #
	mov	eax,16
	mov	dword ptr [DragbarTable+ebx+6],eax
	mov	ax,CurrentSampName
	and	eax,0fh
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	mov	ExtraLength,8
	call	DragBarHandler
	mov	MouseOnDragBar,al
	call	UpdateSampNames
EnvedQuit10:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Help Screen ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cmp	menu_popup,32
	jnz	HelpQuit10

	cmp	MouseOnDragbar,41	;Check HelpDragBar
	jnz	HelpQuit9
	mov	ebx,40*24		;DB #
	movzx	eax,TotalHelpLines
	mov	dword ptr [DragbarTable+ebx+6],eax
	mov	ax,CurrentHelpLine
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	ExtraLength,26
	mov	AmigaLength,26
	call	DragBarHandler
	mov	eax,Dword Ptr [DragbarTable+ebx+10]
	cmp	ax,OldCurrentHelpLine
	jz	HelpQuit9
	mov	CurrentHelpLine,ax
	mov	OldCurrentHelpLine,ax
	call	UpdateHelpText
HelpQuit9:
	mov	ax,CurrentHelpLine	;Update HelpDragbar
	cmp	ax,OldCurrentHelpLine
	jz	HelpQuit10
	mov	OldCurrentHelpLine,ax
	mov	ebx,40*24		;DB #
	movzx	eax,TotalHelpLines
	mov	dword ptr [DragbarTable+ebx+6],eax
	mov	ax,CurrentHelpLine
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	mov	ExtraLength,26
	call	DragBarHandler
	mov	MouseOnDragBar,al
	call	UpdateHelpText
HelpQuit10:




;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Multi Dragbar ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	jmp	Bajsa
OldPosMulti	dd	0
OldTotalMulti	dd	0
Bajsa:

	mov	eax,[alloctable+1047*8]
	movzx	eax,word ptr [eax+2]
	cmp	eax,0
	jz	MultiQuit10
	cmp	menu_popup,29
	jnz	MultiQuit10

	mov	eax,[alloctable+1047*8]
	movzx	eax,word ptr [eax+2]
	cmp	eax,31
	ja	knukken1
	mov	PosMulti,0
	jmp	kukkena1
knukken1:
	sub	eax,31
	cmp	PosMulti,eax
	jbe	kukkena1
	mov	PosMulti,eax
kukkena1:



	cmp	MouseOnDragbar,42
	jnz	MultiQuit9
	mov	ebx,41*24		;DB #
	mov	eax,[alloctable+1047*8]
	movzx	eax,word ptr [eax+2]
	mov	dword ptr [DragbarTable+ebx+6],eax
	mov	eax,PosMulti
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	ExtraLength,31
	mov	AmigaLength,31
	call	DragBarHandler
	mov	eax,Dword Ptr [DragbarTable+ebx+10]
	cmp	eax,0
	jge	@@Fine
	xor	eax,eax
@@Fine:
	cmp	eax,OldPosMulti
	jz	MultiQuit9
	mov	PosMulti,eax
	mov	OldPosMulti,eax
	call	ShowMultiEffect
MultiQuit9:
	mov	eax,PosMulti
	mov	ecx,[alloctable+1047*8]
	movzx	ecx,word ptr [ecx+2]
	cmp	OldTotalMulti,ecx
	jnz	DoItKnollen
	mov	eax,PosMulti
	cmp	eax,OldPosMulti
	jz	MultiQuit10
DoItKnollen:
	mov	OldTotalMulti,ecx
	mov	OldPosMulti,eax
	mov	ebx,41*24		;DB #
	mov	eax,[alloctable+1047*8]
	movzx	eax,word ptr [eax+2]
	mov	dword ptr [DragbarTable+ebx+6],eax
	mov	eax,PosMulti
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	mov	ExtraLength,31
	call	DragBarHandler
	mov	MouseOnDragBar,al
	call	ShowMultiEffect
MultiQuit10:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Single Dragbar ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	jmp	Bajsa2
OldPosSingle	dd	0
Bajsa2:
	mov	eax,[alloctable+1047*8]
	movzx	eax,word ptr [eax+4]
	cmp	eax,0
	jz	SingleQuit10
	cmp	menu_popup,29
	jnz	SingleQuit10

	mov	eax,[alloctable+1047*8]
	movzx	eax,word ptr [eax+4]
	cmp	eax,12
	ja	knukken2
	mov	PosSingle,0
	jmp	kukkena2
knukken2:
	sub	eax,12
	cmp	PosSingle,eax
	jbe	kukkena2
	mov	PosSingle,eax
kukkena2:

	cmp	MouseOnDragbar,43
	jnz	SingleQuit9
	mov	ebx,42*24		;DB #
	mov	eax,[alloctable+1047*8]
	movzx	eax,word ptr [eax+4]
	mov	dword ptr [DragbarTable+ebx+6],eax
	mov	eax,PosSingle
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	ExtraLength,12
	mov	AmigaLength,12
	call	DragBarHandler
	mov	eax,Dword Ptr [DragbarTable+ebx+10]
	cmp	eax,0
	jge	@@FineSingle
	xor	eax,eax
@@FineSingle:
	cmp	eax,OldPosSingle
	jz	SingleQuit9
	mov	PosSingle,eax
	mov	OldPosSingle,eax
	call	ShowSingleEffect
SingleQuit9:
	mov	eax,PosSingle
	cmp	eax,OldPosSingle
	jz	SingleQuit10
	mov	OldPosSingle,eax
	mov	ebx,42*24		;DB #
	mov	eax,[alloctable+1047*8]
	movzx	eax,word ptr [eax+4]
	mov	dword ptr [DragbarTable+ebx+6],eax
	mov	eax,PosSingle
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	mov	ExtraLength,12
	call	DragBarHandler
	mov	MouseOnDragBar,al
	call	ShowSingleEffect
SingleQuit10:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ List Dragbar ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	jmp	Bajsa3
OldPosList	dd	0
Bajsa3:
	mov	eax,ListTableNumber
	cmp	eax,0
	jz	ListQuit10
	cmp	menu_popup,29
	jnz	ListQuit10


	mov	eax,ListTableNumber
	cmp	eax,10
	ja	knukken3
	mov	PosList,0
	jmp	kukkena3
knukken3:
	sub	eax,10
	cmp	PosList,eax
	jbe	kukkena3
	mov	PosList,eax
kukkena3:

	cmp	MouseOnDragbar,44
	jnz	ListQuit9
	mov	ebx,43*24		;DB #
	mov	eax,ListTableNumber
	mov	dword ptr [DragbarTable+ebx+6],eax
	mov	eax,PosList
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	ExtraLength,10
	mov	AmigaLength,10
	call	DragBarHandler
	mov	eax,Dword Ptr [DragbarTable+ebx+10]
	cmp	eax,0
	jge	@@FineList
	xor	eax,eax
@@FineList:
	cmp	eax,OldPosList
	jz	ListQuit9
	mov	PosList,eax
	mov	OldPosList,eax
	call	ShowListEffect
ListQuit9:
	mov	eax,PosList
	cmp	eax,OldPosList
	jz	ListQuit10
	mov	OldPosList,eax
	mov	ebx,43*24		;DB #
	mov	eax,ListTableNumber
	mov	dword ptr [DragbarTable+ebx+6],eax
	mov	eax,PosList
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	mov	ExtraLength,10
	call	DragBarHandler
	mov	MouseOnDragBar,al
	call	ShowListEffect
ListQuit10:

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Master Dragbar ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	jmp	Bajsa4
OldPosMast	dd	0
Bajsa4:
	cmp	menu_popup,39
	jz	Morot
	cmp	menu_popup,41
	jz	Morot
	jmp	MastQuit10
Morot:
	cmp	MouseOnDragbar,45
	jnz	MastQuit9
	mov	ebx,44*24		;DB #
	mov	eax,1000000
	sub	eax,MasterCurveYZoomPos
	shr	eax,4
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	eax,MasterCurveYZoomSize
	shr	eax,4
	mov	Word Ptr [DragbarTable+ebx+4],ax
	mov	ExtraLength,eax
	mov	AmigaLength,eax
	call	DragBarHandler
	mov	eax,Dword Ptr [DragbarTable+ebx+10]
	shl	eax,4
	cmp	eax,0
	jge	@@FineMast
	xor	eax,eax
@@FineMast:
	cmp	eax,OldPosMast
	jz	MastQuit9
	mov	OldPosMast,eax
	mov	ecx,1000000
	sub	ecx,eax
	mov	MasterCurveYZoomPos,ecx
	call	ViewMasterCurve
MastQuit9:
	mov	eax,1000000
	sub	eax,MasterCurveYZoomPos
	cmp	eax,OldPosMast
	jz	MastQuit10

	mov	OldPosMast,eax
	mov	ebx,44*24		;DB #
	shr	eax,4
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	mov	ecx,MasterCurveYZoomSize
	shr	ecx,4
	mov	word Ptr [DragbarTable+ebx+4],cx
	mov	ExtraLength,ecx

	call	DragBarHandler
	mov	MouseOnDragBar,al
	call	ViewMasterCurve
MastQuit10:

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Envelope Dragbar ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	jmp	Bajsa5
OldPosEnv	dd	0
Bajsa5:
	cmp	menu_popup,39
	jnz	EnvQuit10

	cmp	MouseOnDragbar,46
	jnz	EnvQuit9
	mov	ebx,45*24		;DB #
	mov	eax,1000000
	sub	eax,EnvCurveYZoomPos
	shr	eax,4
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	eax,EnvCurveYZoomSize
	shr	eax,4
	mov	Word Ptr [DragbarTable+ebx+4],ax
	mov	ExtraLength,eax
	mov	AmigaLength,eax
	call	DragBarHandler
	mov	eax,Dword Ptr [DragbarTable+ebx+10]
	shl	eax,4
	cmp	eax,0
	jge	@@FineEnv
	xor	eax,eax
@@FineEnv:
	cmp	eax,OldPosEnv
	jz	EnvQuit9
	mov	OldPosEnv,eax
	mov	ecx,1000000
	sub	ecx,eax
	cmp	ecx,EnvCurveYZoomSize
	jae	@@Gunde
	mov	ecx,EnvCurveYZoomSize
@@Gunde:
	mov	EnvCurveYZoomPos,ecx
	call	PutEnvelopeCurve
EnvQuit9:
	mov	eax,1000000
	sub	eax,EnvCurveYZoomPos
	cmp	eax,OldPosEnv
	jz	EnvQuit10

	mov	OldPosEnv,eax
	mov	ebx,45*24		;DB #
	shr	eax,4
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	ecx,EnvCurveYZoomSize
	shr	ecx,4
	mov	word Ptr [DragbarTable+ebx+4],cx
	mov	ExtraLength,ecx
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	call	DragBarHandler
	mov	MouseOnDragBar,al
	call	PutEnvelopeCurve
EnvQuit10:


;------------------------------------- Zyrics mousehandler

	cmp	buttonhandlerstatus,1
	jz	nothinghappends
	cmp	mouseondragbar,0
	jnz	nothinghappends
	cmp	inputrepeatfix,1
	jz	nothinghappends
	cmp	peggamove,1
	jz	nothinghappends
	cmp	pegsmoving,0
	jnz	nothinghappends
	cmp	screenmarking,0
	jnz	nothinghappends

	cmp	DescEditNumber,-1
	jnz	TheDescHandler
	cmp	dragbarmouse,0
	jnz	TheFixDragBar
	mov	dragbarselect,-1
	call	DescHandler

	call	fixdragbar
	call	PullDownHandler
	jmp	nothinghappends
TheDescHandler:
	call	DescHandler
	jmp	nothinghappends
TheFixDragbar:
	call	fixdragbar
	jmp	nothinghappends
TheDownHandler:
	call	PullDownHandler
	jmp	nothinghappends
nothinghappends:
	mov	dragbarspecial,1
	call	fixdragbar
	mov	dragbarspecial,0

;-----------------------------------

	call	CD_text 	;Utdate cd_text
	cmp	mouseB,0
	jnz	noscreenmarkziro
	mov	peggamove,0
	mov	ScreenMarking,0
noscreenmarkziro:
	cmp	screenmarking,0
	jz	nomarkscreen
	call	markscreen	;mark the screen
nomarkscreen:
	cmp	peggamove,0
	jz	nopeggaupdate
	call	setthepeg
nopeggaupdate:
	call	PutDescCords

				;end mojs

jmp lollo
descsave dd 0
lollo:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Description ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cmp	Menu_DownScreen,6
	jnz	DescQuit

	mov	ebx,[DescTable+1*4]      ;Update DescDragbar
	add	ebx,17
	mov	eax,[DescTable+12*4]
	mov	ecx,[DescTable+4*4]
	xor	edx,edx
	div	ecx
	cmp	ebx,eax
	jbe	snyfta
	sub	eax,17
	jmp	snyfta2
snyfta:
	mov	eax,[DescTable+4]
snyfta2:
	cmp	eax,0
	jge	@@snyfta
	mov	eax,0
@@snyfta:
	mov	descsave,eax

	cmp	MouseOnDragbar,9	;Check DescDragBar
	jnz	DescQuit9
	mov	ebx,8*24		;DB #
	mov	eax,[DescTable+12*4]
	mov	ecx,[DescTable+4*4]
	xor	edx,edx
	div	ecx

	mov	dword ptr [DragbarTable+ebx+6],eax
	mov	eax,DescSave ;[DescTable+4]
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	ExtraLength,17
	mov	AmigaLength,17
	call	DragBarHandler
	mov	eax,Dword Ptr [DragbarTable+ebx+10]
	cmp	eax,0
	jge	@@snyfta1
	mov	eax,0
@@snyfta1:

	cmp	eax,OldCurrentDescLine
	jz	DescQuit
	mov	[DescTable+4],eax
	mov	OldCurrentDescLine,eax
	lea	eax,desctable
	mov	DescNowOffset,eax
	call	DrawDesc
	mov	DescXOld,-1
	call	MoveDescCursor
	jmp	DescQuit



DescQuit9:
	mov	eax,DescSave
	cmp	eax,OldCurrentDescLine
	mov	OldCurrentDescLine,eax
	jnz	DescUpdt
	mov	eax,[DescTable+12*4]
	cmp	eax,OldCurrentDescSize
	jz	DescQuit
	mov	OldCurrentDescSize,eax
DescUpdt:
	mov	ebx,8*24		;DB #
	mov	eax,[DescTable+12*4]
	mov	ecx,[DescTable+4*4]
	xor	edx,edx
	div	ecx
	mov	dword ptr [DragbarTable+ebx+6],eax
	mov	eax,DescSave
	mov	Dword Ptr [DragbarTable+ebx+10],eax
	mov	al,MouseOnDragBar
	mov	MouseOnDragBar,0
	mov	ExtraLength,17
	call	DragBarHandler
	mov	MouseOnDragBar,al
DescQuit:
If PrintColorInfo
	mov	ah,0fh
	mov	cl,10
	move	edi,0a0000h
	mov	ebx,[SDBAR1]
	call	PutDecimal
	mov	ah,0fh
	mov	cl,10
	move	edi,0a0000h+11
	mov	ebx,[SDBAR2]
	call	PutDecimal
	mov	ah,0fh
	mov	cl,10
	move	edi,0a0000h+22
	mov	ebx,[SDBAR3]
	call	PutDecimal
	mov	ah,0fh
	mov	cl,10
	move	edi,0a0000h+33
	mov	ebx,[SDBAR4]
	call	PutDecimal
endif

	call	CDControl		;CD control
	call	PrintMarkDigits 	;Digits in Markpopup
	call	UdragControl		;Udrag control

	cmp	Menu_downscreen,4
	jz	NoSilence
	cmp	TuneForkStatus,0
	jz	NoSilence
	call	TuneForkOff
	call	UpdateChannelInfo
	mov	TuneForkStatus,0
NoSilence:

	call	DrawMain
	call	Playcheck
	call	ResampleMain

	cmp	Menu_Popup,0
	jnz	@@Skutt
	cmp	InitialSpecial,0
	jz	@@Skutt
	mov	al,AllowAutoLoad
	ror	al,1
	sar	al,8
	and	al,SongFinished
	jz	@@Skutt
	cmp	SongFinished,3
	jz	@@Fading

	call	CheckLoadName	;Check If any file to load
	jc	@@Skutt
	cmp	SongFinished,1
	jz	@@Load
	cmp	TuneStopped,1
	jz	@@Skutt2
	mov	SongFinished,3
	mov	al,MasterVolume
	mov	TempMasterVolume,al
@@Fading:
	dec	MasterVolume
	mov	EnvVolCheck,-1
	jnz	@@Skutt
	mov	al,TempMasterVolume
	mov	MasterVolume,al
@@Load:
	mov	TuneStopped,0
	call	LoadModuleKey
@@Skutt2:
	mov	SongFinished,0
@@Skutt:

	call	InsertPeak
	call	DrawSampling

	cmp	AllocFailed,1
	jnz	NoMess
	mov	AllocFailed,0
	lea	esi,XMSMemError
	mov	Menu_Popup,1
	call	PopUpHandler

	cmp	menu_downscreen,4
	jnz	nomess
	movzx	ebp,currentsample
	mov	eax,[ebp*4+sampleoffsetend]
	sub	eax,[ebp*4+sampleoffsetstart]
	mov	samplength,eax
	mov	viewsampoffset,0
	mov	viewsamplength,eax


	call	Allocsamplength
	call	viewsamp
	call	chooseplayform

;	mov	eax,offset ProtectSerialCrash+ 1543
;	mov	byte ptr [eax-1543],23


NoMess:
	cmp	mouseB,0
	jnz	nobokas
	mov	dword ptr [OldXY],-1
nobokas:

	call	checkpreviewkeys ;17B

	Popad
	Ret
UpdateDifferentStuff  EndP

;ProtectSerialCrash db	38

CheckBuff: ;------------------------------- Check buff
;Input:	 ebp=buff nr
;Output: eax=checksum
	mov	esi,[alloctable+ebp*8]
	mov	ecx,[alloctable+ebp*8+4]
	xor	eax,eax
CHeckLOop:
	movzx	ebx,byte ptr [esi]
	add	eax,ebx
	inc	esi

	loop	CheckLoop
LoadaNow:
	ret
;------------------------------------------
	;------------------------------------- checken

oldcurr	dd	-1
CRC1	dd	0
CRC2	dd	0
loopas	dd	1

DoCRC:
	dec	loopas
	jnz	afterchecken
	mov	loopas,4
	mov	eax,CurrentPlane
	cmp	eax,0
	jz	afterchecken
	cmp	oldcurr,eax
	jz	dochecken

	mov	ebp,1038
	call	CheckBuff
	mov	CRC1,eax
	cmp	CurrentPlane,2
	jnz	afterchecken
	mov	ebp,1039
	call	CheckBuff
	mov	CRC2,eax
	jmp	afterchecken

dochecken:
	mov	ebp,1038
	call	CheckBuff
	cmp	CRC1,eax
	jnz	errorcheck
	cmp	CurrentPlane,2
	jnz	afterchecken
	mov	ebp,1039
	call	CheckBuff
	cmp	CRC2,eax
	jnz	errorcheck
	jmp	afterchecken

errorcheck:
	call	sara4

afterchecken:
	ret
	;------------------------------------- checken






UpdatePattDrag:
	pushad
	movzx	ebx,Menu_DownScreen
	add	ebx,2
	mov	ax,13*4
	mul	ebx
	mov	ebx,eax

	mov	eax,[DragbarData+ebx]
	mov	CurrentChannel,al
	cmp	Zoom,0
	jz	Mus
	mov	CursorChannel,al
	mov	ArrowPointer,0
Mus:
	popad
	ret

Global	Dbug:near

Global	Dbyte:dword,Dnumber:byte
DByte		dd	0
DNumber 	db	0
Dbug	Proc	Near
	ife	Release
	pushad
	pushfd
	movzx	esi,DNumber
	mov	edi,esi
	lea	esi,[esi*8]
	lea	edi,[edi*2+edi]
	add	esi,edi
	move	edi,0a0000h+10
	add	edi,esi
	mov	ebx,DByte

	mov	ah,0fh
	mov	cl,10
	call	PutDecimal

	popfd
	popad
	endif
	ret
Dbug	EndP


TogglePiano:
	call	FixButton
dopiano:
	cmp	PianoScreen,1
	jz	SetDef
	mov	PianoScreen,1
	call	UpdateBlockBock
	call	menupiano
	ret

ToggleEQMouse:
	call	FixButton
ToggleEQ:
	cmp	PianoScreen,2
	jz	SetDef
	mov	PianoScreen,2
	call	UpdateBlockBock
	call	menupiano
	call	UpdateChannelInfo
	ret
SetDef:
	mov	PianoScreen,0
	call	UpdateBlockBock
	call	menupiano
	ret



AskContLoad	Proc	Near
	pushad

	mov	ax,CurrRow
	mov	OldRow,ax
	mov	ax,CurrPosition
	mov	OldPos,ax
	mov	OldPos2,ax
	mov	OldPattName,0
	mov	ax,CurrPatt
	mov	OldPatt,ax
	mov	OldPatt2,ax
	mov	ax,ModTempo
	mov	OldBPM,ax
	mov	bx,Positions
	mov	OldLen,bx
	mov	al,CurrentInstrument
	mov	OldCurrentInstrument,al
	mov	al,CurrentInstName
	mov	OldCurrentInstName,al
	mov	ax,OldCurrentSampName
	mov	OldCurrentSampName,ax
	mov	al,CurrentChannel
	mov	OldCurrentChannel,al
	mov	CurrPatt2,0
	mov	OldPatt2,0

	call	MouseArrow
	lea	esi,FileErrorMess
	mov	menu_popup,2
	call	PopupHandler
	call	MouseHourGlass
	cmp	popupstatus,0
	jz	Squirt
	clc
	popad
	ret
Squirt:
	stc
	popad
	ret
AskContLoad	EndP

ScrollPattern:
	cmp	MouseX,31
	jb	MM_ScrollLeft
	cmp	MouseX,600
	ja	MM_ScrollRight
	cmp	MouseY,261
	jb	MM_ScrollUp
	cmp	MouseY,462
	ja	MM_ScrollDown
	mov	LeftKeyWait,1
	jmp	MouseOnPattern
MM_ScrollLeft:
	cmp	CurrentChannel,0
	jz	_ret
	dec	CurrentChannel
	mov	MouseX,31
	jmp	MouseOnPattern
MM_ScrollRight:
	mov	al,Channels
	sub	al,6
	jl	_ret
	cmp	CurrentChannel,al
	jz	_ret
	inc	CurrentChannel
	mov	MouseX,600
	jmp	MouseOnPattern
MM_ScrollUp:
	test	Menu_DownScreen,1
	jz	@@ProtScrl
	cmp	CurrentSTRow,0
	jz	_ret
	dec	CurrentSTRow
	jmp	@@ScreamScrl

@@ProtScrl:
	cmp	CurrRow,0
	jz	_ret

@@ScreamScrl:
	dec	CurrRow
	mov	ax,CurrRow
	mov	GotoRow,ax
	movzx	ebx,CurrPatt2
	call	PattInit
	mov	MouseY,261
	jmp	MouseOnPattern

MM_ScrollDown:
	test	Menu_DownScreen,1
	jz	@@ProtScrl
	mov	ax,word ptr CurrPattLength
	sub	ax,15
	cmp	al,CurrentSTRow
	jz	_ret
	inc	CurrentSTRow
	jmp	@@ScreamScrl

@@ProtScrl:
	mov	ax,word ptr CurrPattLength
	dec	ax
	cmp	ax,CurrRow
	jz	_ret

@@ScreamScrl:
	inc	CurrRow
	mov	ax,CurrRow
	mov	GotoRow,ax
	movzx	ebx,CurrPatt2
	call	PattInit
	mov	MouseY,462
	jmp	MouseOnPattern

SetLinFreq:
	mov	LinFreq,1
	call	UpdateSongCfgScreen
	ret
SetAmFreq:
	mov	LinFreq,0
	call	UpdateSongCfgScreen
	ret


InitSpdArrUp:
	call	fixbutton
	cmp	InitSpeed,01fh
	jz	_ret
	inc	InitSpeed
	call	UpdateSongCfgScreen
	ret

InitSpdUDrag:
	mov	ValueProPixel,1024
	mov	UdragMaxValue,31
	mov	UdragMiniValue,1
	mov	UdragStatus,1
	lea	eax,InitSpeed
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,1
	lea	eax,UpdateSongCfgScreen
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	ret

InitSpdArrDn:
	call	fixbutton
	cmp	InitSpeed,1
	jz	_ret
	dec	InitSpeed
	call	UpdateSongCfgScreen
	ret

InitBPMArrUp:
	call	fixbutton
	mov	ax,InitBPM
	inc	ah
	cmp	ah,0
	jz	_ret
	mov	InitBPM,ax
	call	UpdateSongCfgScreen
	ret

InitBPMUDrag:
	mov	ValueProPixel,1024*2
	mov	UdragMaxValue,255
	mov	UdragMiniValue,32
	mov	UdragStatus,1
	lea	eax,InitBPM+1
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,1
	lea	eax,UpdateSongCfgScreen
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	ret

InitBPMArrDn:
	call	fixbutton
	mov	ax,InitBPM
	dec	ah
	cmp	ah,31
	jz	_ret
	mov	InitBPM,ax
	call	UpdateSongCfgScreen
	ret

InitBPMInput:
	movzx	eax,InitBPM	;Decimal part
	and	eax,0ffh
	mov	ecx,26
	xor	edx,edx
	div	ecx
	mov	ebx,eax

	movzx	eax,InitBPM	;Integer part
	shr	eax,8
	mov	ecx,10
	mul	ecx
	add	ebx,eax
	mov	TempModTempo,bx

	mov	DecimalPoint,1
	mov	edi,174*80+72/8
	mov	ecx,4
	mov	ax,0101h
	lea	ebp,TempModTempo
	mov	DigitTarget,ebp
	mov	DigitSize,2
	mov	DigitLimit,2559
	mov	DigitInput,19
	call	InputDigits
	ret

InitSpeedInput:
	movzx	ebx,InitSpeed
	mov	edi,155*80+96/8
	mov	ecx,2
	mov	ax,0101h
	lea	ebp,InitSpeed
	mov	DigitTarget,ebp
	mov	DigitSize,1
	mov	DigitLimit,31
	mov	DigitInput,20
	call	InputDigits
	ret

SelectMode1:
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,96	;Mode 1
	mov	ButtonY1,222
	mov	ButtonX2,109
	mov	ButtonY2,234
	mov	bl,0
	call	ButtonUpDown

	mov	ButtonX1,96	;Mode 2
	mov	ButtonY1,222+16
	mov	ButtonX2,109
	mov	ButtonY2,234+16
	mov	bl,1
	call	ButtonUpDown

	mov	ButtonX1,96	;Mode 3
	mov	ButtonY1,222+32
	mov	ButtonX2,109
	mov	ButtonY2,234+32
	mov	bl,1
	call	ButtonUpDown

	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	ret

UpdateSongCfgScreen:
	cmp	menu_upperleft,3
	jnz	_ret

	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,12
	mov	ButtonY1,115
	mov	ButtonX2,24
	mov	ButtonY2,126
	mov	bl,LinFreq
	xor	bl,1
	call	ButtonUpDown

	mov	ButtonY1,129
	mov	ButtonY2,140
	mov	bl,LinFreq
	call	ButtonUpDown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1

	call	MouseOff
	move	edi,0a0000h+155*80+96/8
	movzx	ebx,InitSpeed
	mov	ah,01h
	mov	cl,2
	call	PutDecimal

	mov	cl,3
	move	edi,0a0000h+174*80+72/8
	movzx	ebx,InitBPM
	shr	ebx,8
	call	PutDecimal
	add	edi,3
	mov	ebx,'.'
	call	PutCharacter
	inc	edi
	movzx	ebx,InitBPM
	and	ebx,0ffh
	mov	eax,26
	xchg	ebx,eax
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	mov	ah,01h
	mov	cl,1
	call	PutDecimal

	call	MouseOn
	ret


NotEnoughHiMem:
	sti
	mov	ax,HimemErrNF
	jmp	ErrorHandler

LoadFonts	Proc	Near
	pushad
	lea	edx,PicturesFileName
	call	FixPathFile
	lea	edx,NewFileName

	call	_OpenFileR
	mov	ax,OpenErr
	jc	ErrorHandler

	call	_filesize
	sub	eax,DatFileSize
	sub	eax,FontFileSize
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler

	movzx	eax,FontSelect
	mov	ebx,80*12*4
	mul	ebx
	mov	bl,1
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler

	mov	eax,80*12*4
	mov	ecx,eax
	mov	ebx,0
	mov	ebp,1040
	call	MemAlloc
	mov	edx,eax
	call	_readfile
	mov	ax,ReadErr
	jc	ErrorHandler

	call	_filesize
	sub	eax,DatFileSize
	sub	eax,FontFileSize
	add	eax,80*12*4*10		;Size of 1BPL font file
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler

	movzx	eax,FontSelect2
	mov	ebx,80*12*4*2
	mul	ebx
	mov	bl,1
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler

	mov	eax,80*12*4*2
	mov	ecx,eax
	mov	ebx,0
	mov	ebp,1041
	call	MemAlloc
	mov	edx,eax
	call	_readfile
	mov	ax,ReadErr
	jc	ErrorHandler

	call	_closefile
	mov	ax,CloseErr
	jc	ErrorHandler

	popad
	ret
LoadFonts	EndP

LoadKeyMap	Proc	Near
	pushad
	lea	edx,PicturesFileName
	call	FixPathFile
	lea	edx,NewFileName

	call	_OpenFileR
	mov	ax,OpenErr
	jc	ErrorHandler

	call	_filesize
	sub	eax,DatFileSize
	sub	eax,FontFileSize
	sub	eax,KeyMapFileSize
	mov	bl,0
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler

	movzx	eax,KeyMapSelect
	mov	ebx,2284
	mul	ebx
	mov	bl,1
	call	_LseekFile
	mov	ax,SeekErr
	jc	ErrorHandler

	mov	ecx,2100
	lea	edx,KeyboardTable
	call	_readfile
	mov	ax,ReadErr
	jc	ErrorHandler

	mov	ecx,184
	mov	edx,GUS_TempBuffPtr
	call	_readfile
	mov	ax,ReadErr
	jc	ErrorHandler

	call	_closefile
	mov	ax,CloseErr
	jc	ErrorHandler
	call	DecodeKeyMap

	popad
	ret
LoadKeyMap	EndP


;LoadInfoBlock	Proc	Near
;	pushad
;	lea	edx,PicturesFileName
;	call	FixPathFile
;	lea	edx,NewFileName
;	lea	edx,NewFileName

;	mov	ProtectSerialCrash,25

;	call	_OpenFileR
;	mov	ax,OpenErr
;	jc	ErrorHandler

;	call	_filesize
;	sub	eax,DatFileSize
;	sub	eax,FontFileSize
;	sub	eax,KeyMapFileSize
;	sub	eax,InfoBlockSize
;	mov	bl,0
;	call	_LseekFile
;	mov	ax,SeekErr
;	jc	ErrorHandler

;	mov	ecx,700
;	lea	edx,InfoBlockBuffer2
;	call	_readfile
;	mov	ax,ReadErr
;	jc	ErrorHandler

;	call	_closefile
;	mov	ax,CloseErr
;	jc	ErrorHandler

;	popad
;	ret
;LoadInfoBlock	EndP


;InfoBlockBuffer1	db	700 dup(0)


CRCCheck2Start:
	db	0
CRCCheck2End:

MakeCRCTable	Proc	Near
	pushad
	lea	ebp,CRCTable

MakeOuter:
	mov	ecx,[ebp+4]
	mov	esi,[ebp]
	cmp	esi,-1
	jz	_retp
	sub	ecx,esi
	xor	ebx,ebx
	xor	eax,eax
MakeInner:
	lodsb
	add	ebx,eax
	loop	MakeInner
	mov	[ebp+8],ebx
	add	ebp,12
	jmp	MakeOuter

	popad
	ret
MakeCRCTable	Endp


CheckCRCTable	Proc	Near
	pushad
	lea	ebp,CRCTable

CheckOuter:
	mov	ecx,[ebp+4]
	mov	esi,[ebp]
	cmp	esi,-1
	jz	_retp
	sub	ecx,esi
	xor	ebx,ebx
	xor	eax,eax
CheckInner:
	lodsb
	add	ebx,eax
	loop	CheckInner
	cmp	[ebp+8],ebx
	jnz	CRCCheckSumError
	add	ebp,12
	jmp	CheckOuter

	popad
	ret
CheckCRCTable	Endp

CRCCheckSumError:
	call	sara4
	sub	ebp,Offset CRCTable
	mov	eax,ebp
	mov	ebp,12
	xor	edx,edx
	div	ebp
	inc	eax
	mov	Dbyte,eax
	call	Dbug
	call	Waitkey
	popad
	ret


ife	Release
ToggleMouse:
	mov	UpdateMouse,80h
	xor	MouseCursor,4
	ret

endif





FixkeyboardLayout	Proc	Near
	pushad
	movzx	eax,KeyBoardLayout
	mov	ebx,[KeyBoardLayout1+eax*4]
	mov	KeyBoard_Table,ebx
	mov	ebx,[KeyBoardLayout2+eax*4]
	mov	KeyBoard_Shift,ebx
	mov	ebx,[KeyBoardLayout3+eax*4]
	mov	KeyBoard_AltGr,ebx
;	call	FixKeyboardTable
	popad
	ret
FixkeyboardLayout	EndP


ToggleSTArrow:
	xor	STArrow,1
	ret

RestoreMainScreen:
	pushad

	mov	Zoom,0
	mov	pianoscreen,0
	mov	Menu_DownScreen,0
	cmp	TrackerStyle,0
	jz	Gunde
	mov	Menu_DownScreen,1
Gunde:
	mov	[CurrentMenu+2],-1
	call	MenuHandler

	mov	menu_upperscreen,0
	mov	[CurrentMenu+4],-1
	call	menuhandler

	mov	menu_upperleft,2
	mov	[CurrentMenu+6],-1
	call	menuhandler

	mov	OldPos2,-1
	mov	OldPattName,-1
	call	PrintPattInfo

	call	UpdateBlockBock
	call	menupiano

	popad
	ret

DoubleC4:
	movzx	ebp,CurrentSample
	movzx	eax,[SampleRates+ebp*2]
	shl	eax,1
	cmp	eax,0ffffh
	jbe	C4RateFine1
	mov	eax,0ffffh
C4RateFine1:
	mov	[SampleRates+ebp*2],ax
	call	PrintSampleInfo
	ret

HalveC4:
	movzx	ebp,CurrentSample
	movzx	eax,[SampleRates+ebp*2]
	shr	eax,1
	mov	[SampleRates+ebp*2],ax
	call	PrintSampleInfo
	ret

;calls: eax=Inst Nr
;out:	carry=1 if Not Allowed
;	carry=0 if allowed
CheckForShadow:
	pushad
	GetOffset eax,eax,ENV_Shadow
	cmp	byte ptr [eax],0
	jz	_retp_clc
	lea	esi,ShadowText
	mov	Menu_Popup,1
	call	PopUpHandler
_retp_stc:
	stc
	popad
	ret
_retp_clc:
	clc
	popad
	ret

_ret_stc:
	stc
	ret
_ret_clc:
	clc
	ret

UndoGadget:
	call	ButtonHandler
	cmp	eax,0
	jnz	_ret
	jmp	SwapUndoBuffer

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Echo Editor
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

EchoEd_Vars	Label	Byte
EchoEd_From	db	0
EchoEd_To	db	0
EchoEd_Chan	db	0
EchoEd_Delay	db	0
EchoEd_Rate	db	0
EchoEd_Decay1	db	0
EchoEd_Decay2	db	0
EchoEd_WrapPatt db	0

EchoEd_FromArrUp:
	mov	ebp,0
	mov	eax,1
	jmp	FixEchoValue
EchoEd_FromArrDn:
	mov	ebp,0
	mov	eax,-1
	jmp	FixEchoValue

EchoEd_ToArrUp:
	mov	ebp,1
	mov	eax,1
	jmp	FixEchoValue

EchoEd_ToArrDn:
	mov	ebp,1
	mov	eax,-1
	jmp	FixEchoValue

EchoEd_ChanArrUp:
	mov	ebp,2
	mov	eax,1
	jmp	FixEchoValue

EchoEd_ChanArrDn:
	mov	ebp,2
	mov	eax,-1
	jmp	FixEchoValue

EchoEd_DelayArrUp:
	mov	ebp,3
	mov	eax,1
	jmp	FixEchoValue

EchoEd_DelayArrDn:
	mov	ebp,3
	mov	eax,-1
	jmp	FixEchoValue

EchoEd_RateArrUp:
	mov	ebp,4
	mov	eax,1
	jmp	FixEchoValue

EchoEd_RateArrDn:
	mov	ebp,4
	mov	eax,-1
	jmp	FixEchoValue

EchoEd_Decay1ArrUp:
	mov	ebp,5
	mov	eax,1
	jmp	FixEchoValue

EchoEd_Decay1ArrDn:
	mov	ebp,5
	mov	eax,-1
	jmp	FixEchoValue

EchoEd_Decay2ArrUp:
	mov	ebp,6
	mov	eax,1
	jmp	FixEchoValue

EchoEd_Decay2ArrDn:
	mov	ebp,6
	mov	eax,-1
	jmp	FixEchoValue

FixEchoValue:
	call	fixbutton
	cmp	ebp,5
	mov	cx,201
	jae	DecayInstead
	mov	cx,32
DecayInstead:
	movzx	bx,[EchoEd_Vars+ebp]
	add	bx,ax
	jl	_ret
	cmp	bx,cx
	jz	_ret
	mov	[EchoEd_Vars+ebp],bl
	call	UpdateEchoEdScreen
	ret

EchoEd_PreDef1TBL	db	 0, 2, 1,25,50,0
EchoEd_PreDef2TBL	db	 1, 2, 2,50,50,0
EchoEd_PreDef3TBL	db	15, 2, 2,40,60,1

EchoEd_PreDef1:
	lea	esi,EchoEd_PreDef1TBL
	jmp	EchoEd_PreDef
EchoEd_PreDef2:
	lea	esi,EchoEd_PreDef2TBL
	jmp	EchoEd_PreDef
EchoEd_PreDef3:
	lea	esi,EchoEd_PreDef3TBL
	jmp	EchoEd_PreDef
EchoEd_PreDef:
	lea	edi,EchoEd_Chan
	mov	ecx,6
	cmp	MouseB,1
	jz	@@GetIt
	xchg	edi,esi
@@GetIt:
	rep	movsb
	call	UpdateEchoEdScreen
	call	fixbutton
	ret

PutUpEchoEditor:
	call	ButtonHandler
	cmp	eax,0
	jnz	_ret
PutUpEchoEditor2:
	mov	Menu_popup,31
	call	MenuHandler
	ret

UpdateEchoEdScreen:
	call	MouseOff

	mov	ah,01h
	mov	cl,2
	mov	FontPlane,1

	move	edi,0a0000h+73*80+240/8 	;From
	movzx	ebx,EchoEd_From
	call	PutDecimal

	move	edi,0a0000h+73*80+368/8 	;To
	movzx	ebx,EchoEd_To
	call	PutDecimal

	move	edi,0a0000h+91*80+240/8 	;Chan
	movzx	ebx,EchoEd_Chan
	inc	ebx
	call	PutDecimal

	move	edi,0a0000h+109*80+240/8	;Delay
	movzx	ebx,EchoEd_Delay
	call	PutDecimal

	move	edi,0a0000h+127*80+240/8	;Rate
	movzx	ebx,EchoEd_Rate
	call	PutDecimal

	mov	cl,3

	move	edi,0a0000h+109*80+368/8	;Decay1
	movzx	ebx,EchoEd_Decay1
	call	PutDecimal

	move	edi,0a0000h+127*80+368/8	;Decay2
	movzx	ebx,EchoEd_Decay2
	call	PutDecimal

	move	edi,0a0000h+109*80+392/8	;Decay2
	mov	ebx,'%'
	call	PutCharacter

	move	edi,0a0000h+127*80+392/8	;Decay2
	mov	ebx,'%'
	call	PutCharacter

	mov	bl,EchoEd_WrapPatt
	xor	bl,1
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,249
	mov	ButtonY1,162
	mov	ButtonX2,293
	mov	ButtonY2,178
	call	ButtonUpDown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	call	MouseOn
	mov	FontPlane,0
	ret


ViewEchoEditor:

	lea	esi,EchoEditorPicture
	call	Drawpopup
	call	UpdateEchoEdScreen
	ret

ViewEQEdit:
	lea	esi,EQEditPicture
	call	Drawpopup
	ret

EchoEd_Wrap:
	mov	bl,EchoEd_WrapPatt
	xor	EchoEd_WrapPatt,1
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,249
	mov	ButtonY1,162
	mov	ButtonX2,293
	mov	ButtonY2,178
	call	ButtonUpDown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	ret

EchoEd_Cancel:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp

	mov	menu_popup,0
	call	menuhandler
	popad
	ret

EchoEd_ToUDrag:
	pushad
	lea	eax,EchoEd_To
	jmp	EchoEdUDrag
EchoEd_ChanUDrag:
	pushad
	lea	eax,EchoEd_Chan
	jmp	EchoEdUDrag
EchoEd_DelayUDrag:
	pushad
	lea	eax,EchoEd_Delay
	jmp	EchoEdUDrag
EchoEd_RateUDrag:
	pushad
	lea	eax,EchoEd_Rate
	jmp	EchoEdUDrag
EchoEd_Decay1UDrag:
	pushad
	lea	eax,EchoEd_Decay1
	mov	ValueProPixel,1024*2
	mov	UdragMaxValue,200
	jmp	EchoEdUDrag2
EchoEd_Decay2UDrag:
	pushad
	lea	eax,EchoEd_Decay2
	mov	ValueProPixel,1024*2
	mov	UdragMaxValue,200
	jmp	EchoEdUDrag2
EchoEd_FromUDrag:
	pushad
	lea	eax,EchoEd_From
EchoEdUDrag:
	mov	ValueProPixel,1024/2
	mov	UdragMaxValue,31
EchoEdUDrag2:
	mov	UdragStatus,1
	mov	UdragMiniValue,0
	mov	UdragVariableOffset,eax
	mov	UdragVariableSize,1
	lea	eax,UpdateEchoEdScreen
	mov	UdragMeanWhile,eax
	call	ButtonHandler
	popad
	ret


;------------------------------------------------------------
Echo_SourceRow		db	-1
Echo_SourceChannel	db	0
Echo_SourceOffset	dd	0
Echo_SourceVolume	dd	0
Echo_DestRow		db	0
Echo_DestChannel	db	0
Echo_NoteOffRow 	dw	0

EchoEd_Okay:
	pushad
	call	ButtonHandler
	cmp	eax,0
	jnz	_retp

	mov	al,EchoEd_To
	mov	Echo_DestChannel,al
	add	al,EchoEd_Chan
	cmp	al,Channels
	jb	@@NoProb
	mov	al,Channels
	dec	al
@@NoProb:
	mov	Echo_ChannelEnd,al
	call	StoreUndoBuffer
	movzx	ebx,CurrPatt2
	mov	eax,[AllocTable+ebx*8+4]
	mov	esi,[AllocTable+ebx*8]
	mov	ecx,eax
	mov	ebp,1037
	xor	ebx,ebx
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	TempBufferPtr,eax
	mov	edi,eax
	push	ecx esi
	rep	movsb
	pop	edi ecx

;	xor	al,al
;	add	edi,12
;	sub	ecx,12
;	rep	stosb

	mov	Echo_SourceRow,-1
	mov	al,EchoEd_To
	mov	Echo_DestChannel,al
	mov	Echo_LastNoteChan,al
@@NextEcho:
	mov	Echo_NoteOffRow,-1
	mov	Echo_DelayFlag,0
	mov	Echo_DelayFlag2,0

	call	CalcSourcePos
	jc	LastNoteToEcho
	mov	esi,Echo_SourceOffset
	call	CheckVolume

	shl	eax,16
	mov	Echo_SourceVolume,eax

	mov	al,Echo_SourceRow
	mov	Echo_DestRow,al
	dec	Echo_DestChannel

@@LoopEcho:
	call	CalcDestPos
	jc	@@NextEcho

	mov	eax,Echo_SourceVolume
	call	CalcVolume
	jc	@@NextEcho
	mov	Echo_SourceVolume,eax

	call	EchoNote
	jmp	@@LoopEcho

LastNoteToEcho:


	xor	ebx,ebx
@@LoopChannels:
	xor	ecx,ecx
@@LoopRows:
	push	ebx
	push	ecx
	call	CalcOffset
	mov	edi,esi
	add	esi,TempBufferPtr
	movzx	ebx,CurrPatt2
	add	edi,[AllocTable+ebx*8]

	mov	ecx,RowSize
@@ChkLoop:
	cmp	byte ptr [edi+ecx-1],0
	loopz	@@ChkLoop
	jnz	@@NoEcho
	mov	ecx,RowSize
	rep	movsb
@@NoEcho:

	pop	ecx
	pop	ebx

	inc	ecx
	cmp	ecx,CurrPattLength
	jnz	@@LoopRows
	inc	ebx
	cmp	bl,Channels
	jnz	@@LoopChannels

	mov	oldrow,-1
	mov	menu_popup,0
	call	menuhandler
	popad
	ret



Echo_LastNoteChan	db	0
;calculates source row/channel
CalcSourcePos	Proc	Near
	pushad
	movzx	ebx,EchoEd_From
	mov	Echo_SourceChannel,bl
	movsx	ecx,Echo_SourceRow
	inc	ecx
	call	CalcOffset
	add	esi,TempBufferPtr
@@NxtCheck:
	mov	Echo_SourceOffset,esi
	cmp	word ptr [esi],2
	jae	@@ANote
	call	CheckVolume	;
	cmp	eax,0		;
	jnz	@@AVol		;
	add	esi,ChRowSize
	inc	ecx
	cmp	ecx,CurrPattLength
	jnz	@@NxtCheck
	stc
	popad
	ret
@@AVol:
	mov	Echo_SourceRow,cl
	mov	al,Echo_LastNoteChan
	mov	Echo_DestChannel,al
	jmp	_retp_clc

@@ANote:
	mov	Echo_SourceRow,cl
	mov	al,Echo_DestChannel
	mov	Echo_LastNoteChan,al
	inc	ecx
	cmp	ecx,CurrPattLength
	jz	_retp_stc

	add	esi,ChRowSize
@@NxtCheck2:
	cmp	word ptr [esi],0
	jnz	@@ANoteOff
	add	esi,ChRowSize
	inc	ecx
	cmp	ecx,CurrPattLength
	jnz	@@NxtCheck2
	jmp	_retp_clc

@@ANoteOff:
	cmp	word ptr [esi],1
	jnz	_retp_clc
	sub	cl,Echo_SourceRow
	mov	Echo_NoteOffRow,cx
	clc
	popad
	ret
CalcSourcePos	EndP

;calculates offset
;in: ebx=channel
;    ecx=row
;out:esi=offset
CalcOffset	Proc	Near
	push	eax ebx ecx edx
	movzx	esi,Channels
	movzx	eax,Commands
	lea	eax,[eax*2+2]
	mov	RowSize,eax
	mul	esi
	mov	ChRowSize,eax

	mul	ecx
	mov	esi,eax
	movzx	ebx,byte ptr [ChanPos+ebx]
	mov	eax,RowSize
	mul	ebx
	add	esi,eax
	add	esi,12
	pop	edx ecx ebx eax
	ret
CalcOffset	EndP


;in:  esi=offset
;out: eax=volume
CheckVolume	Proc	Near
	pushad
	mov	edi,esi
	movzx	ecx,Commands
@@NxtCmd:
	add	esi,2
	cmp	byte ptr [esi],0ch
	jz	@@FoundVolume
	loop	@@NxtCmd

	movzx	edi,byte ptr [edi+1]
	shl	edi,4
	movzx	eax,[Volumes+edi]
	mov	[esp+28],eax

	popad
	ret
@@FoundVolume:
	movzx	eax,byte ptr [esi+1]
	mov	[esp+28],eax
	popad
	ret
CheckVolume	EndP



Echo_DelayFlag		db	0
Echo_ChannelEnd 	db	0
;calculates dest row/channel
CalcDestPos	Proc	Near
	pushad

	mov	al,Echo_ChannelEnd
	cmp	Echo_DestChannel,al
	jb	@@NoWrap
	mov	al,EchoEd_To
	mov	Echo_DestChannel,al
	jmp	@@Wrap
@@NoWrap:
	inc	Echo_DestChannel
@@Wrap:
	cmp	Echo_DelayFlag,1	;No delay occured?
	jz	@@DoRateInstead
	mov	Echo_DelayFlag,1
	mov	al,EchoEd_Delay
	inc	al
	add	Echo_DestRow,al
	jmp	@@SkipThisWorld
@@DoRateInstead:
	mov	al,EchoEd_Rate
	inc	al
	add	Echo_DestRow,al

@@SkipThisWorld:
	cmp	EchoEd_WrapPatt,1
	jz	@@CheckForWrap

	movzx	eax,Echo_DestRow
	cmp	eax,CurrPattLength
	jae	_retp_stc
	clc
	popad
	ret
@@CheckForWrap:
	movzx	eax,Echo_DestRow
	cmp	eax,CurrPattLength
	jb	_retp_clc
	mov	ebx,CurrPattLength
	sub	Echo_DestRow,bl
	clc
	popad
	ret

CalcDestPos	EndP

;in: eax=volume
FirstTry	db	0
EchoNote	Proc	Near
	pushad
	shr	eax,16
	mov	edx,eax
	mov	FirstTry,0
TestAgina:
	movzx	ebx,Echo_DestChannel
	movzx	ecx,Echo_DestRow
	call	CalcOffset
	movzx	ebx,CurrPatt2
	add	esi,[AllocTable+ebx*8]
	mov	edi,esi

	cmp	FirstTry,1
	jz	@@Skip1
	call	CheckVolume
	cmp	edx,eax
	jb	@@NoEcho

@@Skip1:
	movzx	ebx,Echo_SourceChannel
	movzx	ecx,Echo_SourceRow
	call	CalcOffset
	add	esi,TempBufferPtr
	mov	ebx,esi

	push	edi
	cmp	FirstTry,1
	jz	@@Skip
	mov	ecx,RowSize
	rep	movsb

	cmp	Echo_NoteOffRow,-1
	jz	@@Skip
	pushad
	movzx	ebx,Echo_DestChannel
	movzx	ecx,Echo_DestRow
	add	cx,Echo_NoteOffRow
	call	CalcOffset
	movzx	ebx,CurrPatt2
	add	esi,[AllocTable+ebx*8]
	mov	byte ptr [esi],1
	popad
@@Skip:
	pop	edi
	add	edi,2

	movzx	ecx,Commands
	mov	eax,ecx
	mov	esi,edi
@@Loopen:
	cmp	byte ptr [edi],0ch
	jz	@@FoundVolume
	add	edi,2
	loop	@@Loopen

	mov	ecx,eax
	mov	edi,esi
@@Loopen2:
	cmp	word ptr [edi],0
	jz	@@FoundVolumePlace
	add	edi,2
	loop	@@Loopen2
						;No commands free
	mov	bl,Commands
	cmp	bl,7
	jz	@@NotPossible
	inc	bl
	inc	Commands
	mov	TempCommands,bl
	mov	bl,Channels
	mov	TempChannels,bl
	call	FixPatternWidth			;Change pattern size
;	mov	ebx,1037
;	call	FixPatternWidth2
	mov	FirstTry,1
	jmp	TestAgina

@@NotPossible:
	mov	ecx,RowSize
	mov	edi,esi
	sub	edi,2
	mov	esi,ebx
	mov	al,0
	rep	stosb
	jmp	@@NoEcho

@@FoundVolumePlace:
	mov	byte ptr [edi],0ch
@@FoundVolume:
	mov	byte ptr [edi+1],dl
@@NoEcho:
	popad
	ret
EchoNote	EndP


;in:  eax=volume to calc
;out: eax=new volume
;     cf=1 if vol=0
Echo_DelayFlag2 db	0
CalcVolume	Proc	Near
	pushad
	cmp	Echo_DelayFlag2,1
	jz	@@Rate
	mov	Echo_DelayFlag2,1
	movzx	ebx,EchoEd_Decay1
	jmp	@@Delay
@@Rate:
	movzx	ebx,EchoEd_Decay2
@@Delay:
	mul	ebx
	mov	ebx,100
	div	ebx
	cmp	eax,7f0000h
	jbe	@@NoMaxVol
	mov	eax,7f0000h
	mov	[esp+28],eax
	jmp	_retp_stc
@@NoMaxVol:
	mov	[esp+28],eax

	shr	eax,16
	jz	_retp_stc
	clc
	popad
	ret
CalcVolume	EndP


IncAm:
	call	FixButton
	inc	Amplification
	jnz	@@UpOk
	mov	Amplification,255
@@UpOk:
	movzx	eax,Amplification
	sub	eax,16
	mov	[DragBarData+(13*4)*8+0],eax
	mov	[DragBarData+(13*4)*8+4],1
	call	CreatePostProcess
	ret

DecAm:
	call	FixButton
	dec	Amplification
	cmp	Amplification,16
	jae	@@DnOk
	mov	Amplification,16
@@DnOk:
	movzx	eax,Amplification
	sub	eax,16
	mov	[DragBarData+(13*4)*8+0],eax
	mov	[DragBarData+(13*4)*8+4],1
	call	CreatePostProcess
	ret

UpdateAmplify:
	mov	eax,[DragBarData+(13*4)*8+0]
	add	eax,16
	mov	Amplification,al
	call	CreatePostProcess
	ret

Shelling	db	0
IF PMODEWVERSION	;\\
;Format of EXEC parameter block
;Offset	Size	Description
;
; 00h	DWORD	32bit offset for environment
; 04h	WORD	selector for environment
; 06h	DWORD	32bit offset for command line
; 0Ah	WORD	selector for command line
; 0Ch	DWORD	16bit segment:offset of first FCB
; 10h	DWORD	16bit segment:offset of second FCB

;I think there are two more DWORDs after that, but they are unimportant for
;this function (they are only used for AL=1). Notice how the first two
;parameters are 32bit selector:offset pairs, but the last two are 16bit
;segment:offset pairs. I don't know why they did that, but we don't use the
;FCB parameters anyway so you need not worry about them. Just make sure that
;the environment and command line are set properly.

CMDLine 	db	0,0dh
LoadBlock	db	30 dup(0)

ComSpecEnv	db	'COMSPEC='
ComSpecLen	equ	$-ComSpecEnv
ComSpec_PTR	dd	0


Shell	Proc	Near
	pushad
	push	ds es
	mov	Shelling,1

	mov	edi,_env
	lea	edx,ComSpecEnv
@@CheckVar:
	mov	cl,ComSpecLen
	mov	ebx,edx
@@ScanVar:
	mov	al,byte ptr [edi]
	cmp	al,byte ptr [ebx]
	jnz	@@SkipVar
	inc	edi
	inc	ebx
	dec	cl
	jnz	@@ScanVar


	mov	Comspec_PTR,edi 	;Save address of the env

	lea	edi,TheColorTable
	call	fadedownpal

	mov	ax,3			;TextMode
	int	10h
	call	SetOldInt9
	call	RestoreVector24
	call	SetDrivePath


; 00h	DWORD	32bit offset for environment
	mov	eax,_env
	mov	dword ptr loadblock[0],eax

; 04h	WORD	selector for environment
	mov	dword ptr loadblock[4],ds


; 06h	DWORD	32bit offset for command line
	lea	eax,CMDLine
	mov	dword ptr loadblock[6],eax

; 0Ah	WORD	selector for command line
	mov	word ptr loadblock[0ah],ds


	lea	ebx,LoadBlock	;EXEC Param block
	mov	edx,Comspec_PTR


	mov	ax,4b00h
	int	21h

	pushf
	mov	ax,12h			;gfx mode
	int	10h

	lea	eax,FadeUpBuff
	call	setpcxpal

	call	SetNewInt9
	call	SetVector24
	mov	MouseB,1
	call	SetDrivePath2
	mov	MouseB,0

	mov	[CurrentMenu],0
	mov	eax,[PcxOffsets+12]
	mov	pcxx,0
	mov	pcxy,0
	call	ShowThePcx
	mov	eax,[PcxOffsets+16]
	mov	pcxx,0
	mov	pcxy,17
	call	ShowThePcx
	call	RestoreMainScreen

	push	esi
	mov	ah,18h
	mov	cl,MainPullTextLength
	move	edi,0a0000h+(3*80)
	lea	esi,MainPullText
	call	PrintPullText
	call	PutVersionText		; Update version on menu bar
	pop	esi

	mov	OldBPM,-1
	mov	OldSpeed,-1
	mov	OldLen,-1
	mov	OldPos,-1

	mov	Updatecolorsnotpalette,1
	call	UpdateTheColors
	mov	updatecolorsnotpalette,0
	lea	esi,TheColorTable
	call	fadeuppal		;fade up pal
	popf
	pop	es ds
	popad
	mov	Shelling,0
	ret

@@SkipVar:
	inc	edi			;Env space is terminated with "0,0"
	mov	al,[edi]
	cmp	al,0
	jnz	@@SkipVar
	inc	edi
	mov	al,[edi]
	cmp	al,0
	jnz	@@CheckVar

	pop	es ds
	stc
	popad
	mov	Shelling,0
	ret
Shell	EndP
ENDIF			;//




IF DOS32VERSION		;\\
ComSpecEnv	db	'COMSPEC='
ComSpecLen	equ	 $-ComSpecEnv
ComSpec_PTR		dd 0
Dummy_Cmd_Tail		db 1,' '

DosShellSize	dd	0
DosShellPtr	dd	0
ParmBlock	db	30 dup(0)

;Format of EXEC parameter block for AL=00h,01h,04h:
;Offset	Size	Description	(Table 0706)
; 00h	WORD	segment of environment to copy for child process (copy caller's
;		  environment if 0000h)
; 02h	DWORD	pointer to command tail to be copied into child's PSP
; 06h	DWORD	pointer to first FCB to be copied into child's PSP
; 0Ah	DWORD	pointer to second FCB to be copied into child's PSP
; 0Eh	DWORD	(AL=01h) will hold subprogram's initial SS:SP on return
; 12h	DWORD	(AL=01h) will hold entry point (CS:IP) on return
Shell	Proc	Near
	pushad
	mov	Shelling,1
	mov	edi,_env
	lea	edx,ComSpecEnv
@@CheckVar:
	mov	cl,ComSpecLen
	mov	ebx,edx
@@ScanVar:
	mov	al,byte ptr [edi]
	cmp	al,byte ptr [ebx]
	jnz	@@SkipVar
	inc	edi
	inc	ebx
	dec	cl
	jnz	@@ScanVar

	mov	Comspec_PTR,edi 	;Save address of the env

	lea	edi,TheColorTable
	call	fadedownpal

	mov	ax,3			;TextMode
	int	10h
	call	SetOldInt9
	call	RestoreVector24
	call	SetDrivePath
	call	SaveSwapBuffer
	mov	ax,0ee40h
	int	31h			;free the DOS shell memory

; Call the 32bit version of the "load and execute" DOS service

	mov	gs,_gssave		;Temp gs
	mov	ax,4B00h
	xor	edi,edi 		;DS:EDI -> environment
	mov	esi,Offset Dummy_Cmd_Tail	;DS:ESI -> command tail
	mov	edx,Comspec_PTR 	;DS:EDX -> ASCIIZ string
	int	21h
	pushf
	mov	gs,_selzero		;Restore gs


	mov	eax,DosShellSize	;Allocate DOS Shell Memory
	call	_gethimem
	mov	DosShellPtr,edx

	call	ReadSwapBuffer

	mov	ax,12h			;gfx mode
	int	10h

	lea	eax,FadeUpBuff
	call	setpcxpal

	call	SetNewInt9
	call	SetVector24
	mov	MouseB,1
	call	SetDrivePath2
	mov	MouseB,0

	mov	[CurrentMenu],0
	mov	eax,[PcxOffsets+12]
	mov	pcxx,0
	mov	pcxy,0
	call	ShowThePcx
	mov	eax,[PcxOffsets+16]
	mov	pcxx,0
	mov	pcxy,17
	call	ShowThePcx
	call	RestoreMainScreen

	push	esi
	mov	ah,18h
	mov	cl,MainPullTextLength
	move	edi,0a0000h+(3*80)
	lea	esi,MainPullText
	call	PrintPullText
	call	PutVersionText		; Update version on menu bar
	pop	esi

	mov	OldBPM,-1
	mov	OldSpeed,-1
	mov	OldLen,-1
	mov	OldPos,-1

	mov	Updatecolorsnotpalette,1
	call	UpdateTheColors
	mov	updatecolorsnotpalette,0
	lea	esi,TheColorTable
	call	fadeuppal		;fade up pal

	popf
	popad
	mov	Shelling,0
	ret

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
	mov	Shelling,0
	ret
Shell	EndP


SwapName	db	'vs.swp',0
SaveSwapBuffer:
	pushad
	lea	edx,SwapName
	call	FixPathFile
	lea	edx,NewFileName
	call	_createfile
	mov	ax,CreateErr
	jc	ErrorHandler

	mov	edx,DOSShellPtr
	mov	ecx,600*1024

	call	_writefile
	mov	ax,WriteErr
	jc	ErrorHandler

	call	_closefile
	mov	ax,CloseErr
	jc	ErrorHandler

	popad
	ret

ReadSwapBuffer:
	pushad
	lea	edx,SwapName
	call	FixPathFile
	lea	edx,NewFileName
	call	_openfileR
	mov	ax,SwapFileErr
	jc	ErrorHandler

	mov	edx,DOSShellPtr
	mov	ecx,600*1024
	call	_readfile
	mov	ax,SwapFileErr
	jc	ErrorHandler

	call	_closefile
	mov	ax,SwapFileErr
	jc	ErrorHandler

	lea	edx,NewFileName
	call	_Deletefile

	popad
	ret
ENDIF			;//


RightMousePullPress:
	mov	MainPullDownRightStatus,1
	ret

KeysCfgName	db	"keys_.tab",0
SaveKeyConfig	Proc	Near
	pushad
	call	EncodeKeyMap
	sub	edi,GUS_TempBuffPtr
	mov	ecx,edi
	lea	edx,KeysCfgName
	call	FixPathFile

	lea	edx,NewFileName
	call	_Createfile
	mov	edx,GUS_TempBuffPtr
	call	_Writefile
	call	_CloseFile
	popad
	ret
SaveKeyConfig	EndP

;Read from KeyboardTable and PlayKeys and put into GUS_TempBuffPtr
EncodeKeyMap	Proc	Near
	lea	esi,KeyBoardTable
	mov	edi,GUS_TempBuffPtr

@@NextKeyLoop:
	lodsd
	cmp	eax,-1
	jz	QuitKL
	mov	ecx,NrAllProcedures
	xor	ebx,ebx 		;Counter
@@SearchLoop:
	cmp	[AllProcedures+ebx*4],eax
	jz	@@Found
	inc	ebx
	loop	@@SearchLoop
	xor	ebx,ebx 		;Insert Dummy
@@Found:
	mov	eax,ebx
	stosd
	jmp	@@NextKeyLoop
QuitKL:
	lea	esi,PlayKeysTBL+1
	mov	ecx,46
@@NextKeyLoop2:
	push	ecx
	lodsd
	mov	ecx,NrAllProcedures
	xor	ebx,ebx 		;Counter
@@SearchLoop2:
	cmp	[AllProcedures+ebx*4],eax
	jz	@@Found2
	inc	ebx
	loop	@@SearchLoop2
	mov	ebx,-1			;Insert No Key
@@Found2:
	mov	eax,ebx
	stosd
	pop	ecx
	add	esi,2
	loop	@@NextKeyLoop2
	ret
EncodeKeyMap	EndP

;reads 2100 bytes from KeyBoardTable and converts into KeyBoardTable
;reads 184 bytes from GUS_TempBuffPtr and converts into PlayKeys
DecodeKeyMap	Proc	Near
	pushad
	lea	esi,KeyboardTable
GetNextKM:
	mov	eax,[esi]
	cmp	eax,-1
	jz	QuitLKM
	mov	eax,[AllProcedures+eax*4]
	mov	[esi],eax
	add	esi,4
	jmp	GetNextKM
QuitLKM:

	mov	esi,GUS_TempBuffPtr
	lea	edi,PlayKeysTBL+1
	mov	ecx,46
GetNextKM2:
	lodsd
	cmp	eax,-1
	jz	@@NoKey
	mov	eax,[AllProcedures+eax*4]
@@Retry:
	stosd
	add	edi,2
	loop	GetNextKM2
	popad
	ret
@@NoKey:
	xor	eax,eax
	jmp	@@Retry
DecodeKeyMap	EndP



N = 18900/3000
LPFilter	Proc	Near
	pushad

	mov	eax,SampLength
	shl	eax,2
	mov	UndoSampLength,eax
	call	AllocUndoLength
	mov	esi,SampMainOffset
	mov	edi,UndoBufferOffset
	add	edi,4
	mov	ecx,SampLength
MAF:
	xor	ebx,ebx
	mov	ebp,esi
	sub	ebp,N
	cmp	ebp,SampMainOffset
	jb	@@NotOkay
	movzx	ebx,byte ptr [ebp]
	shl	ebx,16
@@NotOkay:
	movzx	eax,byte ptr [esi]
	shl	eax,16
	sub	eax,ebx
	cdq
	mov	ebx,N
	idiv	ebx
	add	eax,[edi-4]
	inc	esi
	stosd
	loop	MAF

	mov	esi,UndoBufferOffset
	mov	edi,SampMainOffset
	mov	ecx,SampLength
@@Flupp:
	lodsd
	shr	eax,16
	stosb
	loop	@@Flupp

	mov	UndoSampLength,0
	call	AllocUndoLength

	popad
	ret
LPFilter	EndP

;f=Analog freq to remove
;fs=Sample freq
;B=(f/fs)*2*pi (Bandwidth)

;ê=(f/fs)*2*pi
;r=1-B/2

BS_Freq 	dw	5000		;Desired freq to filter (in hertz)
BS_BandWidth	dw	100		;Bandwidth of filter (in hertz)
BandWidth	dq	0
Omega		dq	0
Radius		dq	0
Const1		dq	0		;r*2*cos(ê)
Const2		dq	0		;r^2
Const3		dq	0		;2*cos(ê)
Temp		dw	0

BSFilter	Proc	Near
	pushad
	cli
	finit

	fild	BS_BandWidth		;Calc BandWidth
	movzx	ebx,CurrentSample
	call	GetSampleRate
	mov	Nisse,eax
	mov	Temp,ax
;	fild	GUSSampleFreq
	fild	Temp
	fdivp
	mov	Temp,2
	fild	Temp
	fmulp
	fldpi
	fmulp
	fstp	BandWidth

	fild	BS_Freq 		;Calc Omega
	fild	GUSSampleFreq
	fdivp
	mov	Temp,2
	fild	Temp
	fmulp
	fldpi
	fmulp
	fstp	Omega

	fld1				;Calc Radius
	fld	BandWidth
	mov	Temp,2
	fild	Temp
	fdivp
	fsubp
	fstp	Radius

	fld	Omega			;Calc Const
	fcos
	mov	Temp,2
	fild	Temp
	fmulp
	fst	Const3
	fld	Radius
	fmulp
	fstp	Const1

	fld	Radius
	fld	Radius
	fmulp
	fstp	Const2


	mov	eax,SampLength
	shl	eax,3
	mov	UndoSampLength,eax
	call	AllocUndoLength
	mov	esi,SampMainOffset
	mov	edi,UndoBufferOffset
	add	edi,2*8
	add	esi,2
	mov	ecx,SampLength

BSFilt:
	fld	Qword ptr [edi-1*8]
	fmul	Const1

	fld	Qword ptr [edi-2*8]
	fmul	Const2
	fsub

	movzx	ax,byte ptr [esi]
	mov	Temp,ax
	fiadd	Temp

	movzx	ax,byte ptr [esi-1]
	mov	Temp,ax
	fild	Temp
	fmul	Const3
	fsub

	movzx	ax,byte ptr [esi-2]
	mov	Temp,ax
	fiadd	Temp
	fstp	Qword ptr [edi]

	inc	esi
	add	edi,8
	loop	BSFilt

	mov	esi,UndoBufferOffset
	mov	edi,SampMainOffset
	mov	ecx,SampLength
@@Flupp:
	fld	Qword Ptr [esi]
	fistp	Temp
	mov	ax,Temp
	sar	ax,1
	stosb
	add	esi,8
	loop	@@Flupp

	mov	UndoSampLength,0
	call	AllocUndoLength
	sti
	popad
	ret
BSFilter	EndP

PlayLong:
	movzx	ebx,CurrentSample
	movzx	eax,[VoiceControl+ebx]
	mov	dx,[SampleRates+ebx*2]
	shr	al,2
	and	al,1
	mov	ebx,KeyBoardNote
	sub	ebx,2
	mov	bh,80h

	mov	esi,[AllocTable+1024*8]
	mov	ecx,[AllocTable+1024*8+4]
	call	SpeechEngine
	ret


MaxVolConst	equ	28
EqualizerTable	dw	28 dup(0)
EQShape 	dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b

EQDefault	dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b
		dw	1101101101101000b

OldEQVoluminaris	db	32 dup(0)
NewEQVoluminaris	db	32 dup(0)
UpdateOverViewEQ:
	pushad
	cmp	PianoScreen,2
	jnz	_retp
	cmp	Menu_UpperScreen,0
	jnz	_retp

	cmp	menu_popup,0
	jz	ContEQ
	cmp	menu_popup,23
	jz	ContEQ

	mov	[CheckTable],23
	mov	[CheckTable+4],187
	mov	[CheckTable+8],80
	mov	[CheckTable+12],221
	call	CheckAgainstPopup
	jc	_retp
ContEQ:

	mov	ah,8
	call	PlaneWriteProc
	mov	ah,3
	call	PlaneReadProc

	mov	MouseX1,158
	mov	MouseY1,194
	mov	MouseX2,158+15
	mov	MouseY2,222

	mov	edx,158 	;Start XCoord
	xor	ebp,ebp
	mov	ecx,32
NextEQ:
	push	ecx edx
	movzx	eax,byte ptr [ChanPos+ebp]

	movzx	ecx,[EQVol+eax]
	movzx	ebx,[NewEQVoluminaris+eax]

	cmp	[NewEQVoluminaris+eax],0
	jz	@@Fine
	sub	[NewEQVoluminaris+eax],2
	jg	@@Fine
	mov	[NewEQVoluminaris+eax],0
@@Fine:

	cmp	[MIDIChanTable+eax],0
	jnz	@@UEQ
	cmp	[Mute+eax],1
	jz	@@VolSet
@@UEQ:
	cmp	ebx,ecx
	jae	@@VolSet
	mov	[EQVol+eax],0
	shr	ecx,1
	add	ebx,ecx
	shr	ecx,1
	add	ebx,ecx
	mov	[NewEQVoluminaris+eax],bl
	cmp	bl,127
	jbe	@@VolSet
	mov	bl,127
	mov	[NewEQVoluminaris+eax],bl
@@VolSet:

;	movzx	eax,[ChannelMaster+ebp]
;	mul	ebx
;	movzx	ebx,GlobalVolume
;	mul	ebx
;	mov	ebx,127*127
;	div	ebx
;	mov	ebx,eax


	cmp	bl,[OldEQVoluminaris+ebp]
	jz	@@NoEQ
	mov	[OldEQVoluminaris+ebp],bl
	call	MouseOff
	move	edi,0a0000h+193*80
	call	DrawEQ
	call	MouseOn
@@NoEQ:
	pop	edx ecx
	inc	ebp
	add	edx,15
	add	MouseX2,15
	loop	NextEQ

	call	MouseReset

	popad
	ret


;In: ebx=Volume
;    edx=XOffset
DrawEQ:
	push	edx
	mov	eax,MaxVolConst
	mul	ebx
	mov	ebx,127
	div	ebx
	lea	esi,[EqualizerTable+eax*2]
	pop	eax

	xor	edx,edx
	mov	ebx,8
	div	ebx
	add	edi,eax
	mov	ecx,edx 	;Bit offs
	mov	ebx,NOT 03ffffh
	shr	ebx,cl
	not	ebx
	ror	bx,8
	ror	ebx,16
	ror	bx,8		;ebx=AND mask


	mov	edx,28
align	4
@@Loopen:
	and	dword ptr [edi],ebx
	movzx	eax,word ptr [esi]
	ror	eax,16
	shr	eax,cl
	ror	ax,8
	ror	eax,16
	ror	ax,8
	or	dword ptr [edi],eax
	add	esi,2
	add	edi,80
	dec	edx
	jnz	@@Loopen
	ret

PressEQ:
	movzx	eax,MouseX
	sub	eax,158
	mov	ebx,15
	xor	edx,edx
	div	ebx
	mov	ebx,eax
	inc	ebx
	call	MutePress
	ret

EQEditStart:
	mov	Menu_Popup,42
	call	MenuHandler
	lea	esi,EQShape
	lea	edi,EQEditBuff
	mov	ecx,28
	rep	movsw
	call	UpdateEQScreen
	ret


EQ_Okay:
	call	ButtonHandler
	cmp	eax,0
	jnz	_ret
	mov	popok,0
	mov	menu_popup,0
	call	menuhandler

	lea	esi,EQEditBuff
	lea	edi,EQShape
	mov	ecx,28
	rep	movsw
	call	UpdateChannelInfo
	ret

EQ_Cancel:
	call	ButtonHandler
	cmp	eax,0
	jnz	_ret
	mov	popok,0
	mov	menu_popup,0
	call	menuhandler
	ret

EQ_SetDef:
	call	ButtonHandler
	cmp	eax,0
	jnz	_ret

	lea	esi,EQDefault
	lea	edi,EQEditBuff
	mov	ecx,28
	rep	movsw
	call	UpdateEQScreen
	ret

EQEdClear:
	call	ButtonHandler
	cmp	eax,0
	jnz	_ret

	lea	edi,EQEditBuff
	xor	ax,ax
	mov	ecx,28
	rep	stosw
	call	UpdateEQScreen
	ret

EQEdFill:
	call	ButtonHandler
	cmp	eax,0
	jnz	_ret

	lea	edi,EQEditBuff
	mov	ax,NOT 7
	mov	ecx,28
	rep	stosw
	call	UpdateEQScreen
	ret


EQEditBuff	dw	28 dup(0)
UpdateEQScreen:
	call	DrawEQPreviewBig
	call	DrawEQPreviewSmall
	ret

DrawEQPreviewSmall:
	mov	ax,0802h
	mov	dx,3c4h
	out	dx,ax

	mov	ax,0304h
	mov	dx,3ceh 		;Set bitplane (read)
	out	dx,ax

	move	edi,0a0000h+48*80
	lea	esi,EQEditBuff

	mov	eax,312
	xor	edx,edx
	mov	ebx,8
	div	ebx
	add	edi,eax
	mov	ecx,edx 	;Bit offs
	mov	ebx,NOT 03ffffh
	shr	ebx,cl
	not	ebx
	ror	bx,8
	ror	ebx,16
	ror	bx,8		;ebx=AND mask


	mov	edx,28
align	4
@@Loopen:
	and	dword ptr [edi],ebx
	movzx	eax,word ptr [esi]
	ror	eax,16
	shr	eax,cl
	ror	ax,8
	ror	eax,16
	ror	ax,8
	or	dword ptr [edi],eax
	add	esi,2
	add	edi,80
	dec	edx
	jnz	@@Loopen
	ret

DrawEQPreviewBig:
	mov	ax,0802h
	mov	dx,3c4h
	out	dx,ax

	mov	ax,0304h
	mov	dx,3ceh 		;Set bitplane (read)
	out	dx,ax

	move	edi,0a0000h+48*80+200/8
	lea	esi,EQEditBuff
	mov	edx,28	;Y
@@ZoomY:
	mov	ebx,15	;Bit to test
	mov	ecx,13	;X
	lodsw
@@ZoomX:
	bt	ax,bx
	jnc	@@NoPlopp
	mov	byte ptr[edi+0*80],-1
	mov	byte ptr[edi+1*80],-1
	mov	byte ptr[edi+2*80],-1
	mov	byte ptr[edi+3*80],-1
	mov	byte ptr[edi+4*80],-1
	mov	byte ptr[edi+5*80],-1
	mov	byte ptr[edi+6*80],-1
	mov	byte ptr[edi+7*80],-1
	jmp	@@Plopp
@@NoPlopp:
	mov	byte ptr[edi+0*80],0
	mov	byte ptr[edi+1*80],0
	mov	byte ptr[edi+2*80],0
	mov	byte ptr[edi+3*80],0
	mov	byte ptr[edi+4*80],0
	mov	byte ptr[edi+5*80],0
	mov	byte ptr[edi+6*80],0
	mov	byte ptr[edi+7*80],0
@@Plopp:
	inc	edi
	dec	ebx
	loop	@@ZoomX

	add	edi,8*80-13
	dec	edx
	jnz	@@ZoomY
	ret

EQEdSquare:
	call	MouseOff
	mov	ax,0304h		;Read
	mov	dx,3ceh
	out	dx,ax

	movzx	ebx,MouseY
	and	ebx,not 7
	mov	eax,80
	mul	ebx
	movzx	ebx,MouseX
	shr	ebx,3
	add	eax,ebx
	move	edi,0a0000h
	add	edi,eax
	mov	al,byte ptr [edi]
	xor	al,-1
	mov	EQDrawByte,al
	call	MouseOn

	mov	LeftKeyWait,1
	mov	MouseOnDragBar,-4
	ret

EQDrawByte	db	0
EQEdDraw:
	mov	LeftKeyWait,1

	movzx	ebx,MouseY
	cmp	ebx,48
	jb	_ret
	cmp	ebx,271
	ja	_ret

	and	ebx,not 7
	mov	eax,80
	mul	ebx
	movzx	ebx,MouseX
	cmp	ebx,200
	jb	_ret
	cmp	ebx,303
	ja	_ret
	shr	ebx,3
	add	eax,ebx
	move	edi,0a0000h
	add	edi,eax

	call	MouseOff

	mov	ax,0802h		;Write
	mov	dx,3c4h
	out	dx,ax
	mov	al,EQDrawByte
	mov	byte ptr[edi+0*80],al
	mov	byte ptr[edi+1*80],al
	mov	byte ptr[edi+2*80],al
	mov	byte ptr[edi+3*80],al
	mov	byte ptr[edi+4*80],al
	mov	byte ptr[edi+5*80],al
	mov	byte ptr[edi+6*80],al
	mov	byte ptr[edi+7*80],al
	call	MouseOn

	lea	esi,EQEditBuff
	movzx	ebx,MouseY
	sub	ebx,48
	shr	ebx,3
	lea	esi,[esi+ebx*2]

	movzx	eax,MouseX
	sub	eax,200
	shr	eax,3
	mov	ebx,15
	sub	ebx,eax
	cmp	EQDrawByte,0
	jz	@@EQReset
	bts	word ptr [esi],bx
	call	DrawEQPreviewSmall
	ret
@@EQReset:
	btr	word ptr [esi],bx
	call	DrawEQPreviewSmall
	ret


IncDecSpd:
	cmp	MouseB,1
	jz	@@Increase
	mov	RightKeyWait,10
	cmp	ModSpeed,1
	jz	_ret
	dec     ModSpeed
	jmp	@@Cont
@@Increase:
	mov	LeftKeyWait,10
	cmp	ModSpeed,32
	jz	_ret
	inc     ModSpeed
@@Cont:
	mov	al,ModSpeed
	dec	al
	cmp	al,pt_counter
	jae	_Ret
	mov	pt_counter,al
	ret

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

CRCCheck1End:					;CRC Check!
	ret
	call	MakeCRCTable
	mov	ebx,[CRCTable+8]
	mov	Dbyte,ebx
	call	dbug
	ret

CRCTable	dd	CRCCheck1Start,CRCCheck1End,13408813
		dd	CRCCheck2Start,CRCCheck2End,0
		dd	-1


ThePointUp:
	mov	eax,0
	call	LocalCall
	ret
ThePointDown:
	mov	eax,1
	call	LocalCall
	ret
ThePointUdrag:
	mov	eax,2
	call	LocalCall
	ret
ThePointInput:
	mov	eax,3
	call	LocalCall
	ret
SelectLoop:
	mov	eax,4
	call	LocalCall
	ret
VoiceEnvPointUp:
	mov	eax,5
	call	LocalCall
	ret
VoiceEnvPointDown:
	mov	eax,6
	call	LocalCall
	ret
VoiceEnvPointUdrag:
	mov	eax,7
	call	LocalCall
	ret
SetCurve0:
	mov	eax,8
	call	LocalCall
	ret
SetCurve1:
	mov	eax,9
	call	LocalCall
	ret
SetCurve2:
	mov	eax,10
	call	LocalCall
	ret
TimeArrowUp:
	mov	eax,11
	call	LocalCall
	ret
TimeArrowDown:
	mov	eax,12
	call	LocalCall
	ret
TimeUdrag:
	mov	eax,13
	call	LocalCall
	ret
EnvelopeArrowUp:
	mov	eax,14
	call	LocalCall
	ret
EnvelopeArrowDown:
	mov	eax,15
	call	LocalCall
	ret
EnvelopeUdrag:
	mov	eax,16
	call	LocalCall
	ret
EnvLoopStartUp:
	mov	eax,17
	call	LocalCall
	ret
EnvLoopStartDown:
	mov	eax,18
	call	LocalCall
	ret
EnvLoopStartUdrag:
	mov	eax,19
	call	LocalCall
	ret
LenLoopStartTextInput:
	mov	eax,20
	call	LocalCall
	ret
EnvLoopendUp:
	mov	eax,21
	call	LocalCall
	ret
EnvLoopEndDown:
	mov	eax,22
	call	LocalCall
	ret
EnvLoopEndUdrag:
	mov	eax,23
	call	LocalCall
	ret
LenLoopEndTextInput:
	mov	eax,24
	call	LocalCall
	ret
EnvCurveArrowLeft:
	mov	eax,25
	call	LocalCall
	ret
EnvCurveArrowRight:
	mov	eax,26
	call	LocalCall
	ret
EnvCurveArrowUp:
	mov	eax,27
	call	LocalCall
	ret
EnvCurveArrowDown:
	mov	eax,28
	call	LocalCall
	ret
EnvCurveHorzZoomPlus:
	mov	eax,29
	call	LocalCall
	ret
EnvCurveHorzZoomMinus:
	mov	eax,30
	call	LocalCall
	ret
EnvCurveVertZoomPlus:
	mov	eax,31
	call	LocalCall
	ret
EnvCurveVertZoomMinus:
	mov	eax,32
	call	LocalCall
	ret
UpdateEnvCurveX:
	mov	eax,33
	call	LocalCall
	ret
SelectEnvCurve:
	mov	eax,34
	call	LocalCall
	ret
MasterCurveSelectFirst:
	mov	eax,35
	call	LocalCall
	ret
SelectEnvCurveFirst:
	mov	eax,36
	call	LocalCall
	ret
ShowMultiEffect:
	mov	eax,37
	call	LocalCall
	ret
ShowSingleEffect:
	mov	eax,38
	call	LocalCall
	ret
ShowListEffect:
	mov	eax,39
	call	LocalCall
	ret
ViewMasterCurve:
	mov	eax,40
	call	LocalCall
	ret
PutEnvelopeCurve:
	mov	eax,41
	call	LocalCall
	ret
EffectApply:
	mov	eax,42
	call	LocalCall
	ret
SetTimeVar:
	mov	eax,43
	call	LocalCall
	ret
SetTimeInvar:
	mov	eax,44
	call	LocalCall
	ret
VolFade1:
	mov	eax,45
	call	LocalCall
	ret
VolFade2:
	mov	eax,46
	call	LocalCall
	ret
VolFade3:
	mov	eax,47
	call	LocalCall
	ret
VolFade4:
	mov	eax,48
	call	LocalCall
	ret
VolFade5:
	mov	eax,49
	call	LocalCall
	ret
VolFade6:
	mov	eax,50
	call	LocalCall
	ret
EffectWaitCancel:
	mov	eax,51
	call	LocalCall
	ret
EffectWaitCancel2:
	mov	eax,52
	call	LocalCall
	ret
EffectAddMulti:
	mov	eax,53
	call	LocalCall
	ret

thesampleend:
	mov	eax,54
	call	LocalCall
	ret
SetTheNote:
	mov	eax,55
	call	LocalCall
	ret
SetTheRate:
	mov	eax,56
	call	LocalCall
	ret
VolLeft1:
	mov	eax,57
	call	LocalCall
	ret
VolLeft2:
	mov	eax,58
	call	LocalCall
	ret
VolRight1:
	mov	eax,59
	call	LocalCall
	ret
VolRight2:
	mov	eax,60
	call	LocalCall
	ret
SampleSetScopes:
	mov	eax,61
	call	LocalCall
	ret
SampleSetEqualizer:
	mov	eax,62
	call	LocalCall
	ret
SampStereo_Mono:
	mov	eax,63
	call	LocalCall
	ret
Samp8_16Bits:
	mov	eax,64
	call	LocalCall
	ret
SampleSetLinein:
	mov	eax,65
	call	LocalCall
	ret
SampleSetMic:
	mov	eax,66
	call	LocalCall
	ret
SampleSetCD:
	mov	eax,67
	call	LocalCall
	ret
starttosamp:
	mov	eax,68
	call	LocalCall
	ret
therateup:
	mov	eax,69
	call	LocalCall
	ret
theratedown:
	mov	eax,70
	call	LocalCall
	ret
rateinput:
	mov	eax,71
	call	LocalCall
	ret
therateUdrag:
	mov	eax,72
	call	LocalCall
	ret
CD_play:
	mov	eax,73
	call	LocalCall
	ret
CD_pause:
	mov	eax,74
	call	LocalCall
	ret
CD_stop:
	mov	eax,75
	call	LocalCall
	ret
CD_rewback:
	mov	eax,76
	call	LocalCall
	ret
CD_rewfwd:
	mov	eax,77
	call	LocalCall
	ret
CD_skipback:
	mov	eax,78
	call	LocalCall
	ret
CD_skipfwd:
	mov	eax,79
	call	LocalCall
	ret
CD_openclose:
	mov	eax,80
	call	LocalCall
	ret
JumpCDpos:
	mov	eax,81
	call	LocalCall
	ret
SaveCDpos:
	mov	eax,82
	call	LocalCall
	ret
ChangeCDtime:
	mov	eax,83
	call	LocalCall
	ret
CD_volumeDown:
	mov	eax,84
	call	LocalCall
	ret
CD_volumeUp:
	mov	eax,85
	call	LocalCall
	ret
SampleCDsync:
	mov	eax,86
	call	LocalCall
	ret
PeakClear:
	mov	eax,87
	call	LocalCall
	ret
EndStartToSamp:
	mov	eax,88
	call	LocalCall
	ret
StartTheSample:
	mov	eax,89
	call	LocalCall
	ret
UpdateCDVol:
	mov	eax,90
	call	LocalCall
	ret
UpdateInpVol:
	mov	eax,91
	call	LocalCall
	ret
TheSampleEnd2:
	mov	eax,92
	call	LocalCall
	ret
EndStartToSamp2:
	mov	eax,93
	call	LocalCall
	ret
CD_INIT:
	mov	eax,94
	call	LocalCall
	ret
PutEqualizers:
	mov	eax,95
	call	LocalCall
	ret
PutScopes:
	mov	eax,96
	call	LocalCall
	ret
CD_text:
	mov	eax,97
	call	LocalCall
	ret
CDControl:
	mov	eax,98
	call	LocalCall
	ret
InsertPeak:
	mov	eax,99
	call	LocalCall
	ret
DrawSampling:
	mov	eax,100
	call	LocalCall
	ret








LocalCall:
	call	[eax*4+LocalTable]
	ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MultiDragbar:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,42
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SingleDragbar:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,43
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ListDragbar:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,44
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MasterDragbar:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,45
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
EnvelopeDragbar:
	cmp	MouseOnDragBar,0
	jnz	Dummy
	mov	MouseOnDragBar,46
	ret

;InfoBlockBuffer2	db	1232 dup(0)

IF DOS32VERSION		;\\
ends
ENDIF			;//

;IF PMODEWVERSION	;\\
;_TEXT	ends
;ENDIF			;//
ends

end _main
end

;/ABS\05598036950196709373093730937309373093730937303582
