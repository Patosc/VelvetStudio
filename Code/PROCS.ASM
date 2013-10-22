;/ACS\=d

DOS32VERSION	=	0
PMODEWVERSION	=	1

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
.model flat
.code

; Stack already defined in tracker.asm - Vic

;_stack	 segment para stack 'STACK'
;	 db 1000h dup(?)
;_stack	 ends
;
;_TEXT	segment use32 dword public 'CODE'
;	assume	cs:_TEXT,ds:_TEXT
Include PMW.inc
ENDIF			;//

Int3		Macro
IF	DEBUGON
	cli
	int	3
ENDIF
EndM

jumps
Locals

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

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Envelope Stuff ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ENV_SplitKBD		equ	0
ENV_Flags		equ	120		;FLAGS: fedcba9876543210
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

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ErrorCodes
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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


ConvertNote	Macro In,Out
	push	eax
	mov	eax,In
	call	Getperiod
	mov	Out,eax
	pop	eax
	endm


GetOffset Macro inst,out,off
	push	ebx ebp
	mov	ebx,inst
	mov	ebp,off
	call	GO
	pop	ebp ebx
	mov	out,TempOffs
	endm


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Procedures
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


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
;GO:	push	eax edx
;	add	ebp,InstrumentInfo
;	mov	eax,716
;	dec	ebx
;	mul	ebx
;	add	ebp,eax
;	mov	TempOffs,ebp
;	pop	edx eax
;	ret
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

Global	Dbug:near
Global	Dbyte:dword,Dnumber:byte


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
Global sampleoffsetstart:dword,channelnamesptr:dword,keyboardtable:dword,pt_PeriodTable:DWord
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

Global Loadpopup1:near,Savepopup1:near,dumpdownscreen:near,Buttonupdownmem:near
Extrn  Skipput:byte,sizex:dword
Public Buttonx1,Buttony1,Buttonx2,Buttony2
Public ButtonC1,Buttonc2,ButtonXstart,ButtonXend,LineColor,Buttonedisave,buttonstartsave,buttonplane,buttonsave,Fastpic
Global check:byte,pullmode:byte
Global loadpopup2:near,savepopup2:near,putarrow:near
Global optiondrag1:near,optiondrag2:near,sampletogus:near
Global viewsamp:near,samplechange:near,updateplayform:near
Global nomouseon:byte,equalizerinformation:byte:6,movethepegs:near,peghide:byte
Global Rowwrap:byte,themovepeg:byte
Global sampleedstop:near,resetequ:near,Opel:near
Global samplength:dword,saveundo:near,putsplit2:near
Global clearthesong:near,clearsamples:near,clearallshit:near
global	maskx:dword,masky:dword,unpackmasktext:near,writemasktext:near
global pcxs_x1:dword,pcxs_x2:dword,pcxs_y1:dword,pcxs_y2:dword
global	skippasample:byte,ramtable:word
global	printsamplerate:near,samplerate2:dword
global	choosemake:dword,makepicture:dword
global	buttonspecial:byte,undobufferoffset:dword,allocsamplength:near,alloccliplength:near
global	nisse1:dword,nisse2:dword,nisse3:dword,nisse4:dword,nisse5:dword,nissa:near
Global	BoxClipByte:dword:16
global testnewpal:byte
Global SplitPopupPicture:word,ClearPicture:word,OptimPicture:word,Pop3Picture:word,Popup1Picture:word,Popup2Picture:word,TextPicture:word,SecondPopup:dword
global	thecolortable:byte:16*3,FormSelect:byte,KeysPopupSpecial:byte
global SpecialTextOffset:dword,SpecialSecondPopup:byte
Global EndSampleModeAll:Byte,Oldputs:dword:20,MemErrorStatus:byte
global _bretp:near

Include Procs2.asm
Include Global.asm
Include Diskop.Asm
Include EnvEd.Asm
Include PosEd.asm
Include Procs1.Inc
Include Sampla.asm


;Puts a text in textmode
;Calls: ESI = Offset to  text
PrintText2	Proc	Near
	Pushad
	mov	edx,esi
	mov	ah,9
	int	21h
	Popad
	Ret
PrintText2	EndP

BitPlane	db	0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls EBX = Number to print (Used In PatternUpdate)
;     BitPlane = BPL
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PutNumber2    Proc    Near
	Pushad
	mov	esi,eax

	mov	ecx,2
	mov	edx,ebx
	shl	edx,24
	xor	ebx,ebx
PutLoopen2:

	xor	eax,eax
	shld	eax,edx,4
	shl	edx,4
	mov	bl,[HexTable+eax]
	cmp	FillDot,0
	jz	@@Skip
	cmp	bl,'0'
	jnz	@@Skip
	mov	bl,3
@@Skip:
	mov	ah,BitPlane

	call	MM_CheckOther
	call	PutCharacter
	inc	PrintCounter

	inc	edi
	loop	PutLoopen2

	Popad
	Ret
PutNumber2	EndP

HexTable	db	  '0123456789ABCDEF'
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Puts a Hex Value
;Calls:  AH = BitPlane
;	 CL = Nr of Digits
;	EBX = Value to print
;	EDI = Scr. Position
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

PutHex	Proc	Near
	Pushad
	mov	dh,ah
	movzx	ecx,cl
	shl	ecx,2
	ror	ebx,cl
	shr	ecx,2
PutLoopen:
	xor	eax,eax
	shld	eax,ebx,4
	shl	ebx,4
	mov	al,[HexTable+eax]
	push	ebx
	movzx	ebx,al
	mov	ah,dh
	call	PutCharacter
	pop	ebx
	inc	edi
	loop	PutLoopen
	Popad
	Ret
PutHex	EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Puts a Text
;Calls:  AH = BitPlane
;	 CL = Nr of Letters
;	EDI = Scr. Position
;	ESI = Ptr to text
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintText     Proc    Near
	Pushad
	movzx	ecx,cl
TextLoopen:
	lodsb
	cmp	al,'ý'
	jnz	Text
	mov	al,'M'
Text:
;	or	al,1
	movzx	ebx,al
	call	PutCharacter
	inc	edi
	loop	TextLoopen
SkipText:
	Popad
	Ret
PrintText  EndP

Cursor0a db	00111111b,11111111b
	db	00011111b,11111111b
	db	00001111b,11111111b
	db	00000111b,11111111b
	db	00000011b,11111111b
	db	00000001b,11111111b
	db	00000000b,11111111b
	db	00000000b,01111111b
	db	00000000b,00111111b
	db	00000000b,00011111b
	db	00000000b,00011111b
	db	00000000b,11111111b
	db	00000000b,01111111b
	db	11110000b,01111111b
	db	11111000b,00111111b
	db	11111000b,00111111b

Cursor0b db	00000000b,00000000b
	db	01000000b,00000000b
	db	01100000b,00000000b
	db	01110000b,00000000b
	db	01111000b,00000000b
	db	01111100b,00000000b
	db	01111110b,00000000b
	db	01111111b,00000000b
	db	01111111b,10000000b
	db	01111111b,11000000b
	db	01111110b,00000000b
	db	01101110b,00000000b
	db	00000111b,00000000b
	db	00000111b,00000000b
	db	00000011b,10000000b
	db	00000000b,00000000b

Cursor1a db	00001111b,11100000b
	db	00000111b,11000000b
	db	11000111b,11000000b
	db	11000111b,11000001b
	db	11001111b,11100101b
	db	10001111b,11100010b
	db	00011111b,11110000b
	db	00111111b,11111000b
	db	00111111b,11111000b
	db	00011111b,11110000b
	db	10001111b,11100010b
	db	11001111b,11100101b
	db	11000111b,11000001b
	db	11000111b,11000000b
	db	00000111b,11000000b
	db	00001111b,11100000b

Cursor1b db	00000000b,00000000b
	db	11110000b,00011111b
	db	00010000b,00010000b
	db	00010000b,00010110b
	db	00100000b,00001010b
	db	00100000b,00001001b
	db	01000000b,00000100b
	db	10000000b,00000011b
	db	10000000b,00000010b
	db	01000000b,00000100b
	db	00100000b,00001001b
	db	00100000b,00001010b
	db	00010000b,00010110b
	db	00010000b,00010000b
	db	11110000b,00011111b
	db	00000000b,00000000b

Cursor2a db	00111111b,11111111b
	db	00011111b,10111011b
	db	00001111b,10010011b
	db	00000111b,10101011b
	db	00000011b,10111011b
	db	00000001b,10111011b
	db	00000000b,11111111b
	db	00000000b,01111111b
	db	00000000b,00111111b
	db	00000000b,00011111b
	db	00000000b,00011111b
	db	00000000b,11111111b
	db	00000000b,01111111b
	db	11110000b,01111111b
	db	11111000b,00111111b
	db	11111000b,00111111b

Cursor2b db	00000000b,00000000b
	db	01000000b,01000100b
	db	01100000b,01101100b
	db	01110000b,01010100b
	db	01111000b,01000100b
	db	01111100b,01000100b
	db	01111110b,00000000b
	db	01111111b,00000000b
	db	01111111b,10000000b
	db	01111111b,11000000b
	db	01111110b,00000000b
	db	01101110b,00000000b
	db	00000111b,00000000b
	db	00000111b,00000000b
	db	00000011b,10000000b
	db	00000000b,00000000b

Cursor3a db	00111111b,11111111b
	db	00011111b,11001111b
	db	00001111b,10110111b
	db	00000111b,10111111b
	db	00000011b,10110111b
	db	00000001b,11001111b
	db	00000000b,11111111b
	db	00000000b,01111111b
	db	00000000b,00111111b
	db	00000000b,00011111b
	db	00000000b,00011111b
	db	00000000b,11111111b
	db	00000000b,01111111b
	db	11110000b,01111111b
	db	11111000b,00111111b
	db	11111000b,00111111b

Cursor3b db	00000000b,00000000b
	db	01000000b,00110000b
	db	01100000b,01001000b
	db	01110000b,01000000b
	db	01111000b,01001000b
	db	01111100b,00110000b
	db	01111110b,00000000b
	db	01111111b,00000000b
	db	01111111b,10000000b
	db	01111111b,11000000b
	db	01111110b,00000000b
	db	01101110b,00000000b
	db	00000111b,00000000b
	db	00000111b,00000000b
	db	00000011b,10000000b
	db	00000000b,00000000b

Cursor4a db	00000000b,11111111b
	db	01111110b,11111111b
	db	01111110b,11111111b
	db	01111110b,11111111b
	db	01111110b,11111111b
	db	01111110b,11111111b
	db	01111110b,11111111b
	db	01111110b,11111111b
	db	01111110b,11111111b
	db	01111110b,11111111b
	db	01111110b,11111111b
	db	01111110b,11111111b
	db	01111110b,11111111b
	db	01111110b,11111111b
	db	01111110b,11111111b
	db	00000000b,11111111b

Cursor4b db	 11111111b,00000000b
	db	10000001b,00000000b
	db	10000001b,00000000b
	db	10000001b,00000000b
	db	10000001b,00000000b
	db	10000001b,00000000b
	db	10000001b,00000000b
	db	10000001b,00000000b
	db	10000001b,00000000b
	db	10000001b,00000000b
	db	10000001b,00000000b
	db	10000001b,00000000b
	db	10000001b,00000000b
	db	10000001b,00000000b
	db	10000001b,00000000b
	db	11111111b,00000000b

Cursor5a db	 11110111b,11111111b
	db	 11100011b,11111111b
	db	 11000001b,11111111b
	db	 10000000b,11111111b
	db	 10000000b,11111111b
	db	 11100011b,11111111b
	db	 10000000b,11111111b
	db	 10000000b,11111111b
	db	 10000000b,11111111b
	db	 11100011b,11111111b
	db	 10000000b,11111111b
	db	 10000000b,11111111b
	db	 11000001b,11111111b
	db	 11100011b,11111111b
	db	 11110111b,11111111b
	db	 11111111b,11111111b

Cursor5b db	 00000000b,00000000b
	db	 00001000b,00000000b
	db	 00011100b,00000000b
	db	 00111110b,00000000b
	db	 00001000b,00000000b
	db	 00001000b,00000000b
	db	 00001000b,00000000b
	db	 00111110b,00000000b
	db	 00001000b,00000000b
	db	 00001000b,00000000b
	db	 00001000b,00000000b
	db	 00111110b,00000000b
	db	 00011100b,00000000b
	db	 00001000b,00000000b
	db	 00000000b,00000000b
	db	 00000000b,00000000b

Cursor6a db	00111111b,11111111b
	db	00011111b,11100111b
	db	00001111b,11011011b
	db	00000111b,11011111b
	db	00000011b,11100111b
	db	00000001b,11111011b
	db	00000000b,11011011b
	db	00000000b,01100111b
	db	00000000b,00111111b
	db	00000000b,00011111b
	db	00000000b,00011111b
	db	00000000b,11111111b
	db	00000000b,01111111b
	db	11110000b,01111111b
	db	11111000b,00111111b
	db	11111000b,00111111b

Cursor6b db	00000000b,00000000b
	db	01000000b,00011000b
	db	01100000b,00100100b
	db	01110000b,00100000b
	db	01111000b,00011000b
	db	01111100b,00000100b
	db	01111110b,00100100b
	db	01111111b,00011000b
	db	01111111b,10000000b
	db	01111111b,11000000b
	db	01111110b,00000000b
	db	01101110b,00000000b
	db	00000111b,00000000b
	db	00000111b,00000000b
	db	00000011b,10000000b
	db	00000000b,00000000b

Cursor7a db	00111111b,11111111b
	db	00011111b,11000111b
	db	00001111b,11011011b
	db	00000111b,11011101b
	db	00000011b,11011101b
	db	00000001b,11011101b
	db	00000000b,11000011b
	db	00000000b,01111111b
	db	00000000b,00111111b
	db	00000000b,00011111b
	db	00000000b,00011111b
	db	00000000b,11111111b
	db	00000000b,01111111b
	db	11110000b,01111111b
	db	11111000b,00111111b
	db	11111000b,00111111b

Cursor7b db	00000000b,00000000b
	db	01000000b,00111000b
	db	01100000b,00100100b
	db	01110000b,00100010b
	db	01111000b,00100010b
	db	01111100b,00100010b
	db	01111110b,00111100b
	db	01111111b,00000000b
	db	01111111b,10000000b
	db	01111111b,11000000b
	db	01111110b,00000000b
	db	01101110b,00000000b
	db	00000111b,00000000b
	db	00000111b,00000000b
	db	00000011b,10000000b
	db	00000000b,00000000b


AllocTable	dd	1053*2 dup(0)	;BufferPtr | Buffer size
Cmd		db	96 dup(0)	;Command to show at screen
ViewTable	db	624*2	dup(0)	;max,min,max,min... etc
ZoomBuffer	dd	2*151	 dup(0)
gardellen	db	1010	 dup(0)
updatebuffa	db	32*100	dup(0)
		;±±±± LAYOUT ±±±±
CO1	db	"Repeat len/end  "
	db	"Vol hex/dec     "
	db	"Inst hex/dec    "
	db	"Sample hex/dec  "
	db	"Row hex/dec     "
	db	"Vol Indicator   "
	db	"Zero Display    "
	db	"Helpbar stepsize"
	db	"Pattern Style   "
	db	"Pattern Font    "
	db	"Other Font      "
	db	-1
		;±±±±± EDIT ±±±±±
CO2	db	"Edit style      "
	db	"Dragbar style   "
	db	"Ins. Pattern    "
	db	"Ins, Change row "
	db	"Block Paste     "
	db	"Auto Accept     "
	db	"Keyboard Mode   "
	db	"MIDI Device Mode"
	db	"Multi KeyBoard  "
	db	"Key off Sense   "
	db	"Pattern Mode    "
	db	"Jump Start      "
	db	"Position change "
	db	"RowSkip         "
	db	"Piano Select    "
	db	"Channel Lock    "
	db	"Language        "
	db	"Mouse           "
	db	-1
		;±±± Messages ±±±
CO3	db	"Load Song Warn  "
	db	"Load Inst Warn  "
	db	"Load Samp Warn  "
	db	"Save Warning    "
	db	-1
		;±±± Disk op  ±±±
CO4	db	"Use CFG for LMB "
	db	"Names to show   "
	db	"Extension add   "
	db	"FT Sample       "
	db	"Convert Samples "
	db	"Auto Close      "
	db	"Auto name       "
	db	"Sample Packing  "
	db	"Amiga samples   "
	db	"Save 3 or 5 Oct."
	db	"Load 31 MOD samp"
	db	"Multiple samples"
	db	"Filelist Sort   "
	db	-1
		;±±±± Player ±±±±
CO5	db	"Panpot          "
	db	"Frequency       "
	db	-1
		;±±± Samp Ed ±±±±
CO6	db	"Cursor Move     "
	db	"Auto play all   "
	db	"Auto play area  "
	db	"Auto play screen"
	db	"Auto play offset"
	db	"Correct Sample  "
	db	"Stop CD-ROM 1   "
	db	"Stop CD-ROM 2   "
	db	"View all        "
	db	"Zoom area       "
	db	"Zoom back       "
	db	"Convert         "
	db	"Copy            "
	db	"Zero            "
	db	"Preserve        "
	db	"Normalize vol   "
	db	"Reverse         "
	db	"Preview time    "
	db	"Enable CD       "
	db	-1
		;±± Equalizers ±±
CO7	db	"X size          "
	db	"Y size          "
	db	"Location        "
	db	"Speed up        "
	db	"Speed down      "
	db	-1
		;±±±± Desc ed ±±±
CO8	db	"Row wrap        "
	db	"InsertStart on  "
	db	"Show End of line"
	db	-1
		;±±±± Inst ed ±±±
CO9	db	"Auto Piano      "
	db	-1

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


		;±±±± LAYOUT ±±±±
COS1	db	"Repeat end      "
	db	"Repeat len      "
	db	-1
	db	"Decimal         "
	db	"Hexadecimal     "
	db	-1
	db	"Decimal         "
	db	"Hexadecimal     "
	db	-1
	db	"Decimal         "
	db	"Hexadecimal     "
	db	-1
	db	"Decimal         "
	db	"Hexadecimal     "
	db	-1
	db	"No              "
	db	"Yes             "
	db	-1
	db	"Display Zeros   "
	db	"Display dots    "
	db	-1
	db	"No help bars    "
	db	"1               "
	db	"2               "
	db	"3               "
	db	"4               "
	db	"5               "
	db	"6               "
	db	"7               "
	db	"8               "
	db	-1
	db	"ProTracker      "
	db	"ScreamTracker   "
	db	-1
	db	"Ordinary    [RD]"
	db	"Enhanced   [TAP]"
	db	"Thin       [TAP]"
	db	"Simple 1   [TAP]"
	db	"Simple 2   [TAP]"
	db	"Funky [Negspect]"
	db	"Tiny1 [Negspect]"
	db	"Tiny2 [Negspect]"
	db	"Plain [Negspect]"
	db	"Spect [Negspect]"
	db	-1
	db	"Ordinary    [RD]"
	db	"Enhanced   [TAP]"
	db	"Thin       [TAP]"
	db	"Simple 1   [TAP]"
	db	"Simple 2   [TAP]"
	db	"Funky [Negspect]"
	db	"Tiny1 [Negspect]"
	db	"Tiny2 [Negspect]"
	db	"Plain [Negspect]"
	db	"Spect [Negspect]"
	db	-1
		;±±±±± EDIT ±±±±±
COS2	db	"FastTracker     "
	db	"Protracker      "
	db	-1
	db	"'Sticky'        "
	db	"'Non-sticky'    "
	db	-1
	db	"No              "
	db	"Yes             "
	db	-1
	db	"Never           "
	db	"Inserting up    "
	db	"Inserting down  "
	db	"Always          "
	db	-1
	db	"Remain current  "
	db	"To end of block "
	db	-1
	db	"No auto accept  "
	db	"Auto accept     "
	db	"Not in Pos.ed   "
	db	-1
	db	"Mono Keyboard   "
	db	"Poly Keyboard   "
	db	"Flex Keyboard   "
	db	-1
	db	"Mono MIDI Device"
	db	"Poly MIDI Device"
	db	"Flex MIDI Device"
	db	-1
	db	"Priority Off    "
	db	"Priority Flex   "
	db	"Priority On     "
	db	-1
	db	"Off             "
	db	"On              "
	db	-1
	db	"Standard Pattern"
	db	"Extended Pattern"
	db	-1
	db	"Go to start     "
	db	"Remain at row   "
	db	-1
	db	"Off             "
	db	"On when editing "
	db	"On when playing "
	db	"On              "
	db	"Stop            "
	db	-1
	db	"Inc/dec ONE row "
	db	"Inc/dec RowSkip "
	db	-1
	db	"Incremental     "
	db	"Sample-based    "
	db	-1
	db	"Disable         "
	db	"Enable          "
	db	-1
	db	"Swedish         "
	db	"US              "
	db	-1
	db	"RightHanded     "
	db	"LeftHanded      "
	db	-1
		;±±±±±± MESSAGES ±±±
COS3	db	"Disable         "
	db	"Enable          "
	db	-1
	db	"Disable         "
	db	"Enable          "
	db	-1
	db	"Disable         "
	db	"Enable          "
	db	-1
	db	"Disable         "
	db	"Enable          "
	db	-1
		;±±±±± FILE REQ ±±±
COS4	db	"Don't use CFG   "
	db	"Use CFG Defaults"
	db	-1
	db	"Only DOS name   "
	db	"DOS name + real "
	db	-1
	db	"Disable         "
	db	"Enable          "
	db	-1
	db	"Load FT1 sample "
	db	"Load RAW sample "
	db	-1
	db	"Enable          "
	db	"Disable         "
	db	-1
	db	"Disable         "
	db	"Enable          "
	db	-1
	db	"Disable         "
	db	"Enable          "
	db	-1
	db	"Disable         "
	db	"Method 1        "
	db	-1
	db	"Disable         "
	db	"Enable          "
	db	-1
	db	"3 Octaves       "
	db	"5 Octaves       "
	db	-1
	db	"Disable         "
	db	"Enable          "
	db	-1
	db	"As samples      "
	db	"As instruments  "
	db	"Ask when loading"
	db	-1
	db	"Sort by Name    "
	db	"Sort by Ext     "
	db	-1
		;±±±±± PLAYER ±±±±
COS5	db	"Enable cmd 8    "
	db	"Disable cmd 8   "
	db	-1
	db	"Amiga Freq.     "
	db	"Linear Freq.    "
	db	-1
		;±±±±± SAMP.ED. ±±±
COS6	db	"Enable          "
	db	"Disable         "
	db	-1
	db	"Enable          "
	db	"Disable         "
	db	-1
	db	"Enable          "
	db	"Disable         "
	db	-1
	db	"Enable          "
	db	"Disable         "
	db	-1
	db	"Enable          "
	db	"Disable         "
	db	-1
	db	"Resample        "
	db	"Change C4 rate  "
	db	"Do nothing      "
	db	-1
	db	"Continue playing"
	db	"Stop CD.        "
	db	"Pause CD.       "
	db	-1
	db	"Continue playing"
	db	"Stop CD.        "
	db	-1
	db	"Remove mark     "
	db	"Preserve mark   "
	db	-1
	db	"Remove mark     "
	db	"Preserve mark   "
	db	-1
	db	"Remove mark     "
	db	"Preserve mark   "
	db	-1
	db	"Remove mark     "
	db	"Preserve mark   "
	db	-1
	db	"Remove mark     "
	db	"Preserve mark   "
	db	-1
	db	"Remove mark     "
	db	"Preserve mark   "
	db	-1
	db	"Remove mark     "
	db	"Preserve mark   "
	db	-1
	db	"Remove mark     "
	db	"Preserve mark   "
	db	-1
	db	"Remove mark     "
	db	"Preserve mark   "
	db	-1
	db	"1 second        "
	db	"2 seconds       "
	db	"3 seconds       "
	db	"4 seconds       "
	db	"5 seconds       "
	db	"6 seconds       "
	db	"7 seconds       "
	db	"8 seconds       "
	db	"9 seconds       "
	db	-1
	db	"Disable CD      "
	db	"Enable CD       "
	db	-1

		;±±±±± EQUALIZERS ±±±
COS7	db	"1 digit         "
	db	"3 digits        "
	db	"5 digits        "
	db	"7 digits        "
	db	"9 digits        "
	db	"11 digits       "
	db	-1
	db	"10 pixels       "
	db	"20 pixels       "
	db	"30 pixels       "
	db	"40 pixels       "
	db	"50 pixels       "
	db	"60 pixels       "
	db	"70 pixels       "
	db	"80 pixels       "
	db	"90 pixels       "
	db	-1
	db	"No Equalizers   "
	db	"Up              "
	db	"Down            "
	db	-1
	db	"Immediate       "
	db	"Very fast       "
	db	"Fast            "
	db	"Normal          "
	db	"Slow            "
	db	"Very slow       "
	db	-1
	db	"Very fast       "
	db	"Fast            "
	db	"Normal          "
	db	"Slow            "
	db	"Very slow       "
	db	"None            "
	db	-1
		;±±±±± Desc editor±±±±
COS8	db	"Disable         "
	db	"Enable          "
	db	-1
	db	"Disable         "
	db	"Enable          "
	db	-1
	db	"Disable         "
	db	"Enable          "
	db	-1
		;±±±±± Inst editor±±±±
COS9	db	"Disable         "
	db	"Enable, loose   "
	db	"Enable, stuck   "
	db	-1

COH1	db	"Repeat end:                        "	;HelpText 1.1
	db	"Displays the starting byte for the "
	db	"sample loop, and the ending byte   "
	db	"for the sample loop.               "
	db	"                                   "
	db	"Repeat len:                        "
	db	"Displays the starting byte for the "
	db	"sapmle loop, and the length (in    "
	db	"bytes) of a sample loop.           "
	db	-1

	db	"Decimal:                           "	;HelpText 1.2
	db	"Displays the volume indicator      "
	db	"(besides the channel number) in    "
	db	"decimal format (0-127).            "
	db	"                                   "
	db	"Hexadecimal:                       "
	db	"Displays the volume indicator      "
	db	"(besides the channel number) in    "
	db	"hexadecimal format ($00-$7F).      "
	db	"                                   "
	db	"Note that this affects ONLY the    "
	db	"volume indicator, and not the      "
	db	"actual volume commands in the      "
	db	"patterndata, etc.                  "
	db	-1

	db	"Decimal:                           "	;HelpText 1.3
	db	"Displays the numbers of the        "
	db	"instrument in the instrument list  "
	db	"in decimal format. (0-255)         "
	db	"                                   "
	db	"Hexadecimal:                       "
	db	"Displays the numbers of the        "
	db	"instrument in the instrument list  "
	db	"in hexadecimal format. ($00-$FF)   "
	db	"                                   "
	db	"Note that this affects ONLY the    "
	db	"instrument listing, and not the    "
	db	"instrument numbers in the          "
	db	"patterndata, etc. It is recommended"
	db	"you leave this in hex format, so it"
	db	"corresponds with the patterndata   "
	db	"hex instrument numbers.            "
	db	-1

	db	"Decimal:                           "	;HelpText 1.4
	db	"Displays the RepBeg/RepEnd byte    "
	db	"numbers in the sample editor in    "
	db	"decimal format.                    "
	db	"                                   "
	db	"Hexadecimal:                       "
	db	"Displays the RepBeg/RepEnd byte    "
	db	"numbers in the sample editor in    "
	db	"hexadecimal format.                "
	db	-1

	db	"Decimal:                           "	;HelpText 1.5
	db	"Displays the row counter next to   "
	db	"the patterndata in decimal format. "
	db	"Note that if the number of rows in "
	db	"a pattern exceed 100 ($64), the    "
	db	"row number will wrap back to 00.   "
	db	"                                   "
	db	"Hexadecimal:                       "
	db	"Displays the row counter next to   "
	db	"the patterndata in hexadecimal     "
	db	"format.                            "
	db	-1

	db	"No:                                "	;HelpText 1.6
	db	"Turns off the volume indicator next"
	db	"to the channel numbers, if they    "
	db	"annoy you for some reason.         "
	db	"                                   "
	db	"Yes:                               "
	db	"Displays the current volume of the "
	db	"instrument next to each channel    "
	db	"number.                            "
	db	-1

	db	"Display Zeros:                     "	;HelpText 1.7
	db	"Will display a 0000 in place of a  "
	db	"blank command in the patterndata.  "
	db	"                                   "
	db	"Display dots:                      "
	db	"Will display a series of dots      "
	db	"rather than 0000 in place of a     "
	db	"blank command; makes the screen    "
	db	"look more tidy.                    "
	db	-1

	db	"No help bars:                      "	;HelpText 1.8
	db	"No highlighting of patterndata.    "
	db	"                                   "
	db	"1-8:                               "
	db	"Selecting 1-8 will highlight every "
	db	"x'th row in the pattern, so that   "
	db	"sequencing and placing notes on the"
	db	"downbeat is easier.                "
	db	-1

	db	"ProTracker:                        "	;HelpText 1.9
	db	"Displays a ProTracker-style        "
	db	"pattern; patterndata with a        "
	db	"highlight bar across the middle of "
	db	"the block. When tracking, the      "
	db	"current row is highlighted by the  "
	db	"middle bar.                        "
	db	"                                   "
	db	"ScreamTracker:                     "
	db	"Displays a ScreamTracker-style     "
	db	"pattern; patterndata with a cursor "
	db	"on the current field entry. When   "
	db	"tracking, the current row is       "
	db	"indicated by the row the cursor is "
	db	"on.                                "
	db	-1

	db	"Pattern Fonts are used in the      "	;HelpText 1.10
	db	"patterndata and most text fields.  "
	db	-1

	db	"Other Fonts are used on some       "	;HelpText 1.11
	db	"information fields, and some button"
	db	"displays.                          "
	db	-1


COH2	db	"FastTracker:                       "	;Helptext 2.1
	db	"Will change the current pattern if "
	db	"you change the position            "
	db	"                                   "
	db	"Protracker:                        "
	db	"Will not change the current pattern"
	db	"when changing positions, this is   "
	db	"the default in Protracker          "
	db	-1

	db	"'Sticky':                          "	;HelpText 2.2
	db	"The dragbar will move exactly where"
	db	"you click'n'drag your mouse on the "
	db	"bar area.                          "
	db	"                                   "
	db	"'Non-sticky':                      "
	db	"If you click outside of the        "
	db	"dragbar, it will move the contents "
	db	"in the list one page.              "
	db	"(Windows-style).                   "
	db	-1

	db	"No:                                "	;HelpText 2.3
	db	"When inserting a new pattern in the"
	db	"Position Editor, the tracker will  "
	db	"always place 0 as the new pattern  "
	db	"number.                            "
	db	"                                   "
	db	"Yes:                               "
	db	"When inserting a new pattern in the"
	db	"Position Editor, the tracker will  "
	db	"copy the pattern number of the     "
	db	"current position.                  "
	db	-1

	db	"Never:                             "	;HelpText 2.4
	db	"After any insert (eg: Ctrl-I, Ins) "
	db	"operation, the tracker will not    "
	db	"change the current cursor position."
	db	"                                   "
	db	"Inserting up:                      "
	db	"If inserting a space above the     "
	db	"CursorPos, change the row position "
	db	"to the beginning row inserted.     "
	db	"                                   "
	db	"Inserting down:                    "
	db	"If inserting a space below the     "
	db	"CursorPos, change the row position "
	db	"to the end row inserted.           "
	db	"                                   "
	db	"Always:                            "
	db	"After any insert operation, the    "
	db	"tracker will change the current    "
	db	"row position to the row inserted.  "
	db	-1

	db	"Remain current:                    "	;HelpText 2.5
	db	"After a block paste (Ctrl-P)       "
	db	"operation, the tracker will remain "
	db	"at the current cursor position.    "
	db	"                                   "
	db	"To end of block:                   "
	db	"After a block paste (Ctrl-P)       "
	db	"operation, the tracker will move   "
	db	"the cursor to the end of the pasted"
	db	"block.                             "
	db	-1

	db	"Auto-accept is used in input fields"	;HelpText 2.6
	db	"(such as the position editor, or   "
	db	"the instrument name fields).       "
	db	"                                   "
	db	"No auto accept:                    "
	db	"The tracker will not automatically "
	db	"end input if the end of the input  "
	db	"field has been reached. Input is   "
	db	"finished only when the user presses"
	db	"Enter.                             "
	db	"                                   "
	db	"Auto accept:                       "
	db	"The tracker will automatically end "
	db	"input if the end of the input field"
	db	"has been reached.                  "
	db	"                                   "
	db	"Not in Pos.ed:                     "
	db	"The tracker will automatically end "
	db	"input if the end of the input field"
	db	"has been reached, except in the    "
	db	"Position Editor, where input is    "
	db	"finished only when the user presses"
	db	"Enter.                             "
	db	-1

	db	"Mono keyboard:                     "	;HelpText 2.7:
	db	"Keyboard notes are sensed          "
	db	"instantly, and in editmode, are put"
	db	"into patterndata the moment the key"
	db	"is pressed. (As such, chords cannot"
	db	"be played at all).                 "
	db	"                                   "
	db	"Poly keyboard:                     "
	db	"Keyboard notes are sensed only when"
	db	"the key is lifted, and in editmode,"
	db	"multiple keys can be pressed,      "
	db	"writing notes to the next empty    "
	db	"channel (can be used to create     "
	db	"chords).                           "
	db	"                                   "
	db	"Flex keyboard:                     "
	db	"Functions as a poly keyboard,      "
	db	"except in editmode, where it       "
	db	"becomes a mono keyboard.           "
	db	-1

	db	"Mono MIDI device:                  "	;HelpText 2.8:
	db	"Only one key sensed at a time. Not "
	db	"possible to play chords.           "
	db	"                                   "
	db	"Poly MIDI device:                  "
	db	"Notes can be hit simultaneously and"
	db	"will be played on any free channel."
	db	"In editmode, all notes hit will be "
	db	"inserted in unlocked channels, thus"
	db	"making it easy to insert chords in "
	db	"your patterns.                     "
	db	"                                   "
	db	"Flex MIDI device:                  "
	db	"Functions as a poly keyboard, but  "
	db	"changes to mono keyboard when you  "
	db	"enter editmode.                    "
	db	-1

	db	"The Multi Keyboard mode is only    "	;HelpText 2.9
	db	"active when Poly Keyboard mode is  "
	db	"on. If Poly Keyboard mode is off,  "
	db	"notes will always be played or     "
	db	"inserted in the current channel no "
	db	"matter what this setting is.       "
	db	"                                   "
	db	"(Notice that this setting also     "
	db	"affects the MIDI device keyboard.) "
	db	"                                   "
	db	"Priority off:                      "
	db	"Notes are always played in the     "
	db	"current channel, and so only one   "
	db	"note can be played at a time.      "
	db	"                                   "
	db	"Priority flex:                     "
	db	"Notes are played on all empty      "
	db	"channels, allowing simulaneous     "
	db	"notes (and thus chords) to be      "
	db	"played, except in editmode, when   "
	db	"notes are inserted on the current  "
	db	"channel.                           "
	db	"                                   "
	db	"Priority on:                       "
	db	"Notes are played on all empty      "
	db	"channels, allowing simultaneous    "
	db	"notes (and thus chords) to be      "
	db	"played.                            "
	db	-1

	db	"Off:                               "	;HelpText 2.10
	db	"KeyOff notes do not affect the     "
	db	"volume if no instrument envelope is"
	db	"being used.                        "
	db	"                                   "
	db	"On:                                "
	db	"KeyOff notes set the volume of a   "
	db	"sample to 0 if no instrument       "
	db	"envelope is being used.            "
	db	-1

	db	"Standard Pattern:                  "	;HelpText 2.11
	db	"The patterndata screen shows only  "
	db	"one pattern at a time.             "
	db	"                                   "
	db	"Extended Pattern:                  "
	db	"The patterndata screen shows the   "
	db	"previous and next pattern as well  "
	db	"as the current pattern, separated  "
	db	"by a space of one row.             "
	db	-1

	db	"Go to start:                       "	;HelpText 2.12
	db	"Whenever a position jump           "
	db	"(Shift-Left/Right) occurs, the     "
	db	"tracker will move to row 0 of the  "
	db	"new pattern.                       "
	db	"                                   "
	db	"Remain at row:                     "
	db	"Whenever a position jump           "
	db	"(Shift-Left/Right) occurs, the     "
	db	"tracker will keep the current row  "
	db	"position in the new pattern.       "
	db	-1

	db	"Off:                               "	;HelpText 2.13
	db	"The tracker will not change        "
	db	"positions, if the cursor scrolls   "
	db	"off the current pattern (past the  "
	db	"beginning and end rows).           "
	db	"                                   "
	db	"On when editing:                   "
	db	"The tracker will change the current"
	db	"position if the cursor scrolls off "
	db	"the current pattern, but only in   "
	db	"editing mode. In playing mode, the "
	db	"tracker will not change positions. "
	db	"                                   "
	db	"On when playing:                   "
	db	"The tracker will change the current"
	db	"position if the cursor scrolls off "
	db	"the current pattern, but only in   "
	db	"playing mode. In editing mode, the "
	db	"tracker will not change positions. "
	db	"                                   "
	db	"On:                                "
	db	"The tracker will change the current"
	db	"position if the cursor scrolls off "
	db	"the current pattern, regardless of "
	db	"whether it's in editmode or playing"
	db	"mode.                              "
	db	"                                   "
	db	"Stop:                              "
	db	"The tracker will neither change    "
	db	"position nor wrap the pattern      "
	db	-1

	db	"Inc/dec ONE row:                   "	;HelpText 2.14
	db	"The tracker will increase/decrease "
	db	"the CursorPos by one row when a    "
	db	"movement key (up/down) is pressed. "
	db	"                                   "
	db	"Inc/dec RowSkip:                   "
	db	"The tracker will increase/decrease "
	db	"the CursorPos by the RowSkip value "
	db	"when a movement key (up/down is    "
	db	"pressed).                          "
	db	"                                   "
	db	"Note: This can be toggled on-the-  "
	db	"fly with [Ctrl T].                 "
	db	-1

	db	"Piano Select affects how sample    "	;HelpText 2.15
	db	"numbers are written to the piano,  "
	db	"in the instrument editor.          "
	db	"                                   "
	db	"Incremental:                       "
	db	"When the LMB is pressed on a piano "
	db	"key, the sample number assigned to "
	db	"that note is increased by one. When"
	db	"the RMB is pressed on a piano key, "
	db	"the sample number decreases by one."
	db	"                                   "
	db	"Sample-based:                      "
	db	"The sample number assigned to the  "
	db	"note on the piano key depends on   "
	db	"the current sample selected in the "
	db	"instrument editor (like FastTracker"
	db	"II).                               "
	db	-1

	db	"Disable:                           "	;HelpText 2.16
	db	"Disables the Channel Lock function,"
	db	"so it's taken out of the [Ctrl A]  "
	db	"round robin sequence.              "
	db	"                                   "
	db	"Enable:                            "
	db	"Enables the Channel Lock function. "
	db	-1

	db	"Swedish:                           "	;HelpText 2.17
	db	"Chooses a Swedish keyboard layout. "
	db	"                                   "
	db	"US:                                "
	db	"Chooses a USA keyboard layout.     "
	db	-1

	db	"RightHanded:                       "	;HelpText 2.18
	db	"The left mouse button functions as "
	db	"Button 1 (referred to as LMB in the"
	db	"helptext/documentation), and the   "
	db	"right mouse button functions as    "
	db	"Button 2 (referred to as RMB).     "
	db	"                                   "
	db	"LeftHanded:                        "
	db	"The right mouse button functions as"
	db	"Button 1 (referred to as LMB in the"
	db	"helptext/documentation), and the   "
	db	"left mouse button functions as     "
	db	"Button 2 (referred to as RMB).     "
	db	-1

COH3	db	"Disable:                           "	;HelpText 3.1
	db	"Suppress the display of 'Abandon   "
	db	"current song?' when loading another"
	db	"module.                            "
	db	"                                   "
	db	"Enable:                            "
	db	"Displays 'Abandon current song?'   "
	db	"when loading another module.       "
	db	-1

	db	"Disable:                           "	;HelpText 3.2
	db	"Suppress the display of 'Overwrite "
	db	"existing instrument?' when loading "
	db	"a new instrument over an existing  "
	db	"instrument.                        "
	db	"                                   "
	db	"Enable:                            "
	db	"Displays 'Overwrite existing       "
	db	"instrument?' when loading a new    "
	db	"instrument over an existing        "
	db	"instrument.                        "
	db	-1

	db	"Disable:                           "	;HelpText 3.3
	db	"Suppress the display of 'Overwrite "
	db	"existing sample?' when loading a   "
	db	"new sample over an existing sample."
	db	"                                   "
	db	"Enable:                            "
	db	"Displays 'Overwrite existing       "
	db	"sample?' when loading a new sample "
	db	"over an existing sample.           "
	db	-1

	db	"Disable:                           "	;HelpText 3.4
	db	"Suppress the warning displayed when"
	db	"saving .MOD/.S3M format files.     "
	db	"                                   "
	db	"Enable:                            "
	db	"Displays a warning when saving     "
	db	"files as .MOD or .S3M.             "
	db	-1

COH4	db	"Don't use CFG:                     "	;HelpText 4.1
	db	"RMB will set new default path that "
	db	"can be recalled with LMB.          "
	db	"Use CFG:                           "
	db	"LMB will always fetch path from the"
	db	"configured paths                   "
	db	-1

	db	"Decide whether to display the dos  "	;HelpText 4.2
	db	"filename only, or the dosname and  "
	db	"the real name of the file.         "
	db	-1

	db	"Enable:                            "	;HelpText 4.3
	db	"When saving, diskoption will auto- "
	db	"matcally add an extension on the   "
	db	"filename                           "
	db	"                                   "
	db	"Disable:                           "
	db	"Diskoption won't touch the file-   "
	db	"extension at all.                  "
	db	-1

	db	"FT1 Sample:                        "	;HelpText 4.4
	db	"This option will load the loop info"
	db	"stored with samples saved in FT1.  "
	db	"(Loop info is stored in the file's "
	db	"date and time settings)            "
	db	"                                   "
	db	"RAW Sample:                        "
	db	"This option doesn't load the loop. "
	db	-1

	db	"Enable:                            "	;HelpText 4.5
	db	"Automatically convert the raw      "
	db	"samples between unsigned and signed"
	db	"when loading                       "
	db	"                                   "
	db	"Disable:                           "
	db	"Don't convert the samples when     "
	db	"loading.                           "
	db	-1

	db	"Enable:                            "	;HelpText 4.6
	db	"Disk Option window will always     "
	db	"close after loading a song.        "
	db	"                                   "
	db	"Disable:                           "
	db	"Disk Option window will stay open. "
	db	-1

	db	"Enable:                            "	;HelpText 4.7
	db	"VS will automatically insert a dos "
	db	"compatiable name suggestion for the"
	db	"file to save in the filename field."
	db	"                                   "
	db	"Disable:                           "
	db	"The filename field will not be     "
	db	"modified.                          "
	db	-1

	db	"Decide which packing method to use "	;HelpText 4.8
	db	"on samples.                        "
	db	-1

	db	"Enable:                            "	;HelpText 4.9
	db	"This option will zero the two first"
	db	"bytes of the sample when saving a  "
	db	".MOD file. This is useful ONLY if  "
	db	"you want to use the song with an   "
	db	"Amiga replay routine.              "
	db	"                                   "
	db	"Disable:                           "
	db	"This should be used in normal cases"
	db	"since it won't destroy the sample. "
	db	-1

	db	"Choose whether to save 3 or 5      "	;HelpText 4.10
	db	"octaves when saving a MOD.         "
	db	-1

	db	"Enable this if you always want to  "	;HelpText 4.11
	db	"load 31 samples when loading a MOD,"
	db	"even if not all 31 are used. (Good "
	db	"if you don't want to miss some info"
	db	"text in the MOD.)                  "
	db	-1

	db	"If you load multiple samples, this "	;HelpText 4.12
	db	"option decides how they are loaded."
	db	"                                   "
	db	"As samples:                        "
	db	"This option will load all samples  "
	db	"to the current instrument.         "
	db	"                                   "
	db	"As Instruments:                    "
	db	"This option will treat the samples "
	db	"as instrument, and they will be    "
	db	"loaded with different inst.numbers "
	db	-1

	db	"Choose method to sort the filelist "	;HelpText 4.13
	db	"in.                                "
	db	"                                   "
	db	"Sort by Name:                      "
	db	"Sorts by the dos filename only.    "
	db	"                                   "
	db	"Sort by Ext:                       "
	db	"Sorts by extension first, then by  "
	db	"the filename.                      "
	db	-1

COH5	db	"Decide whether you want panpot to  "	;HelpText 5.1
	db	"be enabled or not.                 "
	db	-1

	db	"Linear frequency:                  "	;HelpText 5.2
	db	"The more correct way of modifying  "
	db	"the frequency amplitude when using "
	db	"vibrato, sliding etc.              "
	db	"                                   "
	db	"Amiga frequency:                   "
	db	"The amplitudes change with the     "
	db	"frequency. (For compatibility with "
	db	"old songs.)                        "
	db	-1

COH6	db      "This option controls whether the   "	;HelpText 6.1
	db      "cursor should move when unmarking  "
	db      "an area or not.                    "
	db	-1
	db	"This option, when enabled, will    "	;HelpText 6.2
	db	"automatially set the 'ALL' button  "
	db	"to play the whole sample, when no  "
	db	"area is marked and play screen is  "
	db	"disabled.                          "
	db	-1
	db	"This option, when enabled, will    "	;HelpText 6.3
	db	"automatially set the 'AREA' button "
	db	"to play the marked area when one   "
	db	"exists.                            "
	db	-1
	db	"This option, when enabled, will    "	;HelpText 6.4
	db	"automatially set the 'SCREEN'      "
	db	"button to play the shown part of   "
	db	"the sample, when zoomed.           "
	db	-1
	db	"This option, when enabled, will    "	;HelpText 6.5
	db	"automatially set the 'OFFSET'      "
	db	"button to play from the current    "
	db	"cursor position when no area is    "
	db	"marked.                            "
	db	-1
	db	"This option affects the post-      "	;HelpText 6.6
	db	"processing of the sample after you "
	db	"have sampled someting. This is made"
	db	"because most soundcards can't      "
	db	"record in any given frequency.     "
	db	"                                   "
	db	"Resample:                          "
	db	"This option automatically resamples"
	db	"the sample to match the desired    "
	db	"frequency.                         "
	db	"                                   "
	db	"Change C-4 Rate:                   "
	db	"If you don't want to touch the     "
	db	"sample data, you can enable this   "
	db	"option. It will only change the C-4"
	db	"rate so that the correct frequency "
	db	"will be found on note C-4.         "
	db	"                                   "
	db	"Do Nothing:                        "
	db	"If you choose not to postprocess at"
	db	"all, the sample's frequency will   "
	db	"probably differ a bit from what you"
	db	"want, but in some cases this is ok."
	db	-1
	db	"This option controls the CD-ROM    "	;HelpText 6.7
	db	"when you quit the sample pop-up.   "
	db	-1
	db	"This option controls the CD-ROM    "	;HelpText 6.8
	db	"when you quit Velvet Studio.       "
	db	-1
	db	"This option decides whether the    "	;HelpText 6.9
	db	"marked area should disappear when  "
	db	"you press the 'View All' button    "
	db	-1
	db	"This option decides whether the    "	;HelpText 6.10
	db	"marked area should disappear when  "
	db	"you press the 'Zoom Area' button   "
	db	-1
	db	"This option decides whether the    "	;HelpText 6.11
	db	"marked area should disappear when  "
	db	"you press the 'Zoom Back' button   "
	db	-1
	db	"This option decides whether the    "	;HelpText 6.12
	db	"marked area should disappear when  "
	db	"you press the 'Convert' button     "
	db	-1
	db	"This option decides whether the    "	;HelpText 6.13
	db	"marked area should disappear when  "
	db	"you press the 'Copy' button        "
	db	-1
	db	"This option decides whether the    "	;HelpText 6.14
	db	"marked area should disappear when  "
	db	"you press the 'Zero' button        "
	db	-1
	db	"This option decides whether the    "	;HelpText 6.15
	db	"marked area should disappear when  "
	db	"you press the 'Preserve' button    "
	db	-1
	db	"This option decides whether the    "	;HelpText 6.16
	db	"marked area should disappear when  "
	db	"you press the 'Normalize' button   "
	db	-1
	db	"This option decides whether the    "	;HelpText 6.17
	db	"marked area should disappear when  "
	db	"you press the 'Reverse' button     "
	db	-1
	db	"When you press PREVIEW or TEST     "	;HelpText 6.18
	db	"in the effectengine, this option   "
	db	"will set the time the precalculated"
	db	"effect will be played.             "
	db	-1
	db	"If you have trouble with your CD-  "	;HelpText 6.19
	db	"ROM, you can disable this feature  "
	db	"by setting the correct parameter   "
	db	"here.                              "
	db	-1

COH7	db	"Decide which horisontal size you   "	;HelpText 7.1
	db	"want for the big equalizers (on the"
	db	"pattern data).                     "
	db	-1

	db	"Decide the vertical size for the   "	;HelpText 7.2
	db	"big equalizers (on the patt. data)."
	db	-1

	db	"Choose the location for the big    "	;HelpText 7.3
	db	"equalizers or turn them off if you "
	db	"don't like them.                   "
	db	-1

	db	"Choose the up speed for the big    "	;HelpText 7.4
	db	"equalizers. (Very fast is usually  "
	db	"good.)                             "
	db	-1

	db	"Choose the down speed for the big  "	;HelpText 7.5
	db	"equalizers. (Fast is usually good.)"
	db	-1

COH8	db	"Enable if you want the cursor to   "	;HelpText 8.1
	db	"wrap to the next line when reaching"
	db	"the end of the current line.       "
	db	-1

	db	"Enable this if you want to enter   "	;HelpText 8.2
	db	"the Desc Edit with InsertMode on.  "
	db	-1

	db	"Decide if you want the 'EndOfLine' "	;HelpText 8.3
	db	"row to be displayed on screen.     "
	db	-1

COH9	db	"Display mode for the Piano when    "	;HelpText 9.1
	db	"entering the Instrument Editor.    "
	db	"                                   "
	db	"Disable:                           "
	db	"The Piano will never be affected.  "
	db	"                                   "
	db	"Enable, loose:                     "
	db	"The Piano will be shown when you   "
	db	"enter the Inst Editor and will not "
	db	"be removed when exiting.           "
	db	"                                   "
	db	"Enable, stuck:                     "
	db	"The Piano will be shown when you   "
	db	"enter the Inst Editor and removed  "
	db	"when exiting.                      "
	db	-1

Cursor	dd	Cursor0a,Cursor0b,Cursor1a,Cursor1b,Cursor2a,Cursor2b,Cursor3a,Cursor3b,Cursor4a,Cursor4b,Cursor5a,Cursor5b,Cursor6a,Cursor6b,Cursor7a,Cursor7b


Mouse	db		 4*16*4 dup (0) 	  ;Background save buffer
Mouse2	db		 4*16*4 dup (0) 	  ;Background save buffer
MouseCursor	db	0
GetMouseBackground	Proc	Near
	cmp	nomouseon,1
	jz	_ret
	pushad

	lea	edi,Mouse
	move	esi,0a0000h
	movzx	ecx,MouseY
	mov	ebx,ecx
	shl	ebx,4
	shl	ecx,6
	add	ecx,ebx 	;ecx=YCoord

	movzx	ebx,MouseX
	shr	ebx,3
	add	ecx,ebx
	add	esi,ecx 	;Byteoffset
	mov	ByteOff,esi

	movzx	ebx,MouseX
	mov	ecx,ebx
	and	ebx,not 7
	sub	ecx,ebx 	;BitOffset

kalle=0
	mov	ebx,4
	mov	ax,0004h
GetBack:
	movzx	ebp,MouseCursor
	mov	ebp,[Cursor+ebp*8]
	mov	esi,ByteOff
	mov	dx,3ceh 	;Read mask register
	out	dx,ax
	push	ax
	rept 16
	lodsd
	movzx	edx,word ptr [ebp]
	not	dx
	ror	dx,8
	ror	edx,16
	ror	edx,cl
	ror	dx,8
	ror	edx,16
	ror	dx,8
	mov	dword ptr [Mouse2+kalle],edx
	and	eax,edx
	stosd
	add	ebp,2
	add	esi,80-4
	kalle=kalle+4
	endm
	pop	ax
	inc	ah
	dec	ebx
	jnz	GetBack

	popad
	ret
GetMouseBackground	Endp

PutMouseBackground	Proc	Near
	cmp	nomouseon,1
	jz	_ret
	pushad

	lea	esi,Mouse

	mov	bx,0100h
kalle=0
	mov	ecx,4
PutBack:
	mov	dx,3c4h 	;Write mask register
	mov	al,02h
	mov	ah,bh
	out	dx,ax

	mov	dx,3ceh
	mov	al,04h
	mov	ah,bl
	out	dx,ax

	mov	edi,ByteOff

	push	ax
	rept 16
	lodsd
	mov	edx,dword ptr [Mouse2+kalle]
	not	edx
	and	[edi],edx
	or	[edi],eax
	add	edi,80
	kalle=kalle+4
	endm
	pop	ax

	shl	bh,1
	inc	bl
	loop	PutBack

	popad
	ret
PutMouseBackground	Endp

WMR	dw	0	;ReadMask
RMR	dw	0	;WriteMask
ScreenRightMask dw	0
ScreenRightMask1 dw	 0
ByteOff dd	0	;ByteOffset to Background
BitOff	dw	0	;BitOffset in byte

Mama	dw	0000000000111111b
	dw	0000000001111111b
	dw	0000000011111111b
	dw	0000000111111111b
	dw	0000001111111111b
	dw	0000011111111111b
	dw	0000111111111111b
	dw	0001111111111111b
	dw	0011111111111111b
	dw	0111111111111111b
nomouseon	db	0

PutMouse	Proc	Near
	cmp	nomouseon,1
	jz	_ret
	pushad
	mov	WMR,0102h
	mov	RMR,0004h
	mov	ScreenRightMask,-1
	mov	ScreenRightMask1,0

;AND
	movzx	ebx,MouseX
	mov	ecx,ebx
	mov	edx,ebx
	and	ebx,not 7
	sub	ecx,ebx 	;BitOffset
	mov	BitOff,cx
	cmp	edx,629
	jbe	NoRightFix

	mov	ecx,640-16
	sub	ecx,edx
	neg	ecx
	sub	cx,6
	mov	cx,[Mama+ecx*2]
	mov	ScreenRightMask1,cx
	not	cx
	mov	ScreenRightMask,cx

NoRightFix:
	mov	cx,BitOff
	mov	edx,4
BPLLoop1:
	push	edx
	movzx	esi,MouseCursor
	mov	esi,[Cursor+esi*8]
	mov	edi,ByteOff	;ByteOffset
	mov	dx,3c4h 	;Write mask register
	mov	ax,WMR
	out	dx,ax
	mov	dx,3ceh 	;Read mask register
	mov	ax,RMR
	out	dx,ax
	shl	byte ptr WMR+1,1
	inc	byte ptr RMR+1

	mov	edx,16
MouseYLoop2:
	mov	eax,-1
	lodsw
	ror	ax,8
	or	ax,ScreenRightMask1
	ror	eax,16
	ror	eax,cl
	ror	ax,8
	ror	eax,16
	ror	ax,8
	and	[edi],eax
	add	edi,80
	dec	edx
	jnz	MouseYLoop2

	pop	edx
	dec	edx
	jnz	BPLLoop1

;OR
	mov	WMR,0102h
	mov	RMR,0004h
	mov	edx,4
	mov	cx,BitOff
BPLLoop2:
	push	edx
	movzx	esi,MouseCursor
	mov	esi,[Cursor+esi*8+4]
	mov	edi,ByteOff	;ByteOffset
	mov	dx,3c4h 	;Write mask register
	mov	ax,WMR
	out	dx,ax
	mov	dx,3ceh 	;Read mask register
	mov	ax,RMR
	out	dx,ax
	shl	byte ptr WMR+1,1
	inc	byte ptr RMR+1

	mov	edx,16
MouseYLoop3:
	xor	eax,eax
	lodsw
	ror	ax,8
	and	ax,ScreenRightMask
	ror	eax,16
	ror	eax,cl
	ror	ax,8
	ror	eax,16
	ror	ax,8
	or	[edi],eax
	add	edi,80
	dec	edx
	jnz	MouseYLoop3

	pop	edx
	dec	edx
	jnz	BPLLoop2

	popad
	ret
PutMouse	EndP


irq_stub_buf	db	21 dup(?)	; buffer for IRQ callback stub
;irq_stub_buf2	db	21 dup(?)	; buffer for IRQ callback stub
Old_PM_Int9	df	0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Sets the new Keyboard Handler
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetNewInt9	Proc	Near
	pushad
	cli

	mov	bl,1				;Get Pmode IRQ vector
	call	_GetIrqVect
	mov	dword ptr Old_PM_Int9,edx
	mov	word ptr Old_PM_Int9+4,cx

	mov	bl,1				;Set Pmode IRQ vector
	lea	edx,NewInt9
	mov	cx,cs
	call	_SetIrqVect

;	mov	bl,1
;	mov	edi,offset irq_stub_buf 	;set real mode IRQ 1 callback
;	lea	edx,NewInt9
;	call	_rmpmirqset
;	mov	OldInt9Real,eax 		;store old real mode IRQ 1 vector

	sti
	popad
	ret
SetNewInt9	ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Sets the old Keyboard Handler
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetOldInt9	Proc	Near
	pushad
	cli

	mov	bl,1				;Set Pmode IRQ vector
	mov	edx,dword ptr Old_PM_Int9
	mov	cx,word ptr Old_PM_Int9+4
	call	_SetIrqVect

;	mov	bl,1
;	mov	eax,OldInt9Real 		;restore old real mode IRQ 1 callback
;	call	_rmpmirqfree

	sti
	popad
	ret
SetOldInt9	Endp

KBDBuffer	db	32 dup(0)
KBDBuffPtrR	db	0
KBDBuffPtrW	db	0
KBDBufferFull	db	0

LastKey 	dw	0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;The New Keyboard Handler
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NewInt9 	Proc	Near
	pushad
	pushfd
	push	ds es gs
	cli
	mov	ds,cs:_seldata
	mov	es,cs:_seldata
	mov	gs,cs:_selzero

	in	al,60h
	movzx	ebx,al
	cmp	al,0E0h
	jne	SetScanCode
	mov	E0Flag,128
	jmp	NotAgain
SetScanCode:
	and	bl,01111111b
	add	bx,E0Flag
	mov	E0Flag,0
	and	ax,10000000b
	xor	al,10000000b

	or	bh,al
	cmp	bx,LastKey
	jnz	ANewKey

;	jmp	notagain	;
	dec	KeyBoardDelay			;KeyBoard Delay
	jg	NotAgain
	jz	NowCheckRepeat
	mov	ax,KeyBoardDelayI
	mov	KeyBoardDelay,ax
	jmp	NotAgain

NowCheckRepeat:
	mov	KeyBoardDelay,1
	dec	KeyBoardRepeat
	jg	NotAgain
NoRepeatscky:
	mov	ax,KeyBoardRepeatI
	mov	KeyBoardRepeat,ax
	jmp	PutToKBDTable
ANewKey:

	mov	LastKey,bx
	mov	KeyBoardDelay,0
PutToKBDTable:
	cmp	KBDBufferFull,1
	jz	NotAgain
	movzx	eax,KBDBuffPtrW
	mov	word ptr [KBDBuffer+eax*2],bx
	inc	al
	and	al,0fh
	cmp	al,KBDBuffPtrR
	jz	FullBuffer
	mov	KBDBuffPtrW,al
	jmp	NotAgain
FullBuffer:
	mov	KBDBufferFull,1
NotAgain:
	in	al,61h
	or	al,80h
	out	61h,al
	and	al,7fh
	out	61h,al

	mov	al,20h
	out	20h,al

	pop	gs es ds
	popfd
	popad
	sti
	iretd
NewInt9 	Endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Initializes the Mouse
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MouseInit	Proc	Near
	pushad
	mov	ax,0		;Initialize mouse
	int	33h
	or	ax,ax
	mov	ax,NoMouseErr
	jz	ErrorHandler

	mov	ecx,10		;Turn On Cursor
@@Nxt:
	mov	ax,1
	int	33h
	loop	@@Nxt

	mov	ax,2		;Turn Off Cursor
	int	33h

	mov	ax,4		;Set Mouse Cursor Position
	mov	cx,0
	mov	dx,0
	int	33h

	mov	ax,7		;Set Minimum and Maximum Horizontal
	mov	cx,0
	mov	dx,638
	int	33h

	mov	ax,8		;Set Minimum and Maximum Vertical
	mov	cx,0
	mov	dx,478
	int	33h

	mov	ax,15		;Set Mickey/Pixel Ratio
	mov	cx,10			;x
	mov	dx,cx			;y
	int	33h
	popad
	ret
MouseInit	Endp

MouseX1 	dw	0
MouseX2 	dw	639
MouseY1 	dw	0
MouseY2 	dw	479

HourGlass	db	0	;1=Hourglass
MouseOnOff	db	0	;1=ON
Moff		db	0
MouseOn Proc	Near
	cmp	nomouseon,1
	jz	_ret
	cmp	moff,1
	jz	_ret
	cmp	MouseOnOff,1
	jz	_ret
	mov	MouseOnOff,1
;	jmp	RealMouseOn	;..........
	cmp	HourGlass,1
	jz	RealMouseOn

	push	bx

	mov	bl,0
	call	SetReset

	call	GetMouseBackground
	call	PutMouse

	mov	bl,SaveSetReset
	call	SetReset
	pop	bx
	ret
RealMouseOn:
	pushad
	call	SetMouseShape
	mov	ax,1		;Show cursor
	int	33h
	popad
	ret
MouseOn EndP

MouseReset	Proc	Near
	mov	MouseX1,0
	mov	MouseX2,639
	mov	MouseY1,0
	mov	MouseY2,479
	ret
MouseReset	EndP


SaveSetReset	db	0
MouseOff Proc	Near
	cmp	nomouseon,1
	jz	_ret
	cmp	moff,1
	jz	_ret
	cmp	MouseOnOff,0
	jz	_ret

;	jmp	RealMouseOff	;..........
	cmp	HourGlass,1
	jz	RealMouseOff

	push	eax
	mov	ax,MouseY
	cmp	ax,MouseY2
	jae	_ret2
	add	ax,16
	cmp	ax,MouseY1
	jbe	_ret2

	mov	ax,MouseX
	cmp	ax,MouseX2
	jae	_ret2
	add	ax,16
	cmp	ax,MouseX1
	jbe	_ret2

	push	dx
	mov	dx,3ceh 		;Enable Set/Reset
	mov	al,01h
	out	dx,al

	mov	dx,3cfh
	in	al,dx
	mov	SaveSetReset,al

	push	bx
	mov	bl,0
	call	SetReset
	pop	bx
	pop	dx
	pop	eax

	mov	MouseOnOff,0
	call	PutMouseBackground
	ret
RealMouseOff:
	mov	MouseOnOff,0
	pushad
	mov	ax,2		;Hide cursor
	int	33h
	popad
	ret
_ret2:
	pop	eax
	ret
MouseOff EndP

MouseHourGlass	Proc	Near
	cmp	HourGlass,1
	jz	_ret

	call	MouseOff
	mov	HourGlass,1
	call	MouseOn
	ret
MouseHourGlass	EndP

MouseArrow	Proc	Near
	cmp	HourGlass,0
	jz	_ret
	call	MouseOff
	mov	HourGlass,0
	call	MouseOn
	ret
MouseArrow	EndP

ClipJumpTbl	dd	@TB0,@TB1,@TB2,@TB3,@TB4,@TB5,@TB6,@TB7,@TB8,@TB9,@TB10,@TB11,@TB12,@TB13,@TB14,@TB15,@TB16,@TB17,@TB18,@TB19,@TB20,@TB21,@TB22,@TB23,@TB24,@TB25
ClipCallTbl	dd	@QB0,@QB1,@QB2,@QB3,@QB4,@QB5,@QB6,@QB7,@QB8,@QB9,@QB10,@QB11,@QB12,@QB13,@QB14,@QB15,@QB16,@QB17,@QB18,@QB19,@QB20,@QB21,@QB22,@QB23,@QB24,@QB25

ClipJumpTbl2	dd	@2TB0,@2TB1,@2TB2,@2TB3,@2TB4,@2TB5,@2TB6,@2TB7,@2TB8,@2TB9,@2TB10,@2TB11,@2TB12,@2TB13,@2TB14,@2TB15,@2TB16,@2TB17,@2TB18,@2TB19,@2TB20,@2TB21,@2TB22,@2TB23,@2TB24,@2TB25
ClipCallTbl2	dd	@2QB0,@2QB1,@2QB2,@2QB3,@2QB4,@2QB5,@2QB6,@2QB7,@2QB8,@2QB9,@2QB10,@2QB11,@2QB12,@2QB13,@2QB14,@2QB15,@2QB16,@2QB17,@2QB18,@2QB19,@2QB20,@2QB21,@2QB22,@2QB23,@2QB24,@2QB25

PullSaveSize	dd	0,0,0
TheBPlane	dd	0

InvertText	db	0
FontPlane	dd	0
PatternUpdate	db	0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Put a Character in VGA 16 col mode
;
;Calls: EDI = PutOffset
;	EBX = Character
;	 AH = BPL
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PutCharacter	 Proc	 Near
	cmp	ah,08h
	jz	Put2BPL
	Pushad
	mov	byte ptr TheBPlane,ah

	mov	esi,[AllocTable+1040*8]
	lea	ebx,[ebx+ebx*2] 	;Get offset to char
	lea	ebx,[ebx*4]
	add	esi,ebx

	mov	dx,3c4h 		;Write mask register
	and	ah,0fh
	mov	al,02h
	out	dx,ax

	cmp	PatternUpdate,1
	jz	NoClipping

	mov	eax,CurrentPlane
	cmp	eax,FontPlane
	jz	CheckPullClip
	lea	ebx,PopUpPlane1
	cmp	FontPlane,0
	jz	DoClipping
	lea	ebx,PopUpPlane2
	jmp	DoClipping
CheckPullClip:
	cmp	PullMode,0		;Clip?
	jz	NoClipping

	lea	ebx,BoxClipByte
DoClipping:
	mov	eax,edi 		;get X and Y coord on screen
	add	eax,_Code32a
	sub	eax,0a0000h
	xor	edx,edx
	mov	ebp,80
	div	ebp			;EDX=X, EAX=Y

	xor	ebp,ebp
ClipNext:
	cmp	edx,[ebx]
	jb	XNoClip
	cmp	edx,[ebx+8]
	jae	XNoClip

	cmp	eax,[ebx+4]
	ja	YNoClip
	mov	ecx,[ebx+4]
	sub	ecx,eax
	mov	ebp,ecx
	add	ebp,13
	cmp	ebp,25
	jbe	ClipMe
	jmp	XNoClip
YNoClip:
	cmp	eax,[ebx+12]
	ja	XNoClip
	mov	ecx,[ebx+12]
	sub	ecx,eax
	mov	ebp,ecx
	inc	ebp
	cmp	ebp,12
	jbe	ClipMe
	mov	ebp,12
	jmp	ClipMe
XNoClip:
	add	ebx,16
	cmp	Dword ptr [ebx],-1
	jnz	ClipNext
	jmp	NoClipping
ClipMe:
	cmp	PatternUpdate,2
	jz	PrintThisToScreen

	cmp	PullMode,0
	jnz	PullDownClip

	mov	ecx,FontPlane;CurrentPlane
	add	edx,[AllocTable+ecx*8+1038*8]	;Offs+PrintX
	sub	edx,[ebx]			;-ClipX
	sub	eax,[ebx+4]			;PrintY-ClipY
	mov	ebx,[PopUpPlane1Width+ecx*4]	;Get Width

	mov	ecx,edx
	mul	ebx
	add	ecx,eax 			;ecx=offs to save buff

	mov	eax,ebp
	cmp	eax,12
	jbe	Case2
	sub	eax,12
Case2:
	dec	eax
	mul	ebx
	add	ecx,eax

	mov	ah,InvertText
	call	[ClipCallTbl+ebp*4]

PrintThisToScreen:
	mov	ah,InvertText
	jmp	[ClipJumpTbl+ebp*4]
PullDownClip:
	sub	edx,[ebx]			;PrintX-ClipX
	sub	eax,[ebx+4]			;PrintY-ClipY
	mov	ecx,[ebx+8]			;Get Width
	sub	ecx,[ebx]

	sub	ebx,Offset BoxClipByte
	shr	ebx,4

	add	edx,[PicOffsets+ebx*4]		;Offs+PrintX
	add	edx,GUS_TempBuffPtr
	cmp	TheBPlane,1
	jz	@koko
	add	edx,[PullSaveSize+ebx*4]
	add	edx,[PullSaveSize+ebx*4]
	add	edx,[PullSaveSize+ebx*4]
@koko:
	mov	ebx,edx
	mul	ecx
	add	ebx,eax
	xchg	ecx,ebx 			;ecx=offs to save buff

	mov	eax,ebp
	cmp	eax,12
	jbe	Case2_
	sub	eax,12
Case2_:
	dec	eax
	mul	ebx
	add	ecx,eax

	mov	ah,InvertText
	call	[ClipCallTbl+ebp*4]
	mov	ah,InvertText
	jmp	[ClipJumpTbl+ebp*4]

NoClipping:
	mov	ah,InvertText

	cmp	PrintCounter,-1
	jz	@TB0
	mov	[edi-80],ah
@TB0:
	mov	al,[esi]			;Top To Bottom (clips top)
	xor	al,ah
	mov	[edi],al
@TB1:
	mov	al,[esi+1]
	xor	al,ah
	mov	[edi+80*1],al
@TB2:
	mov	al,[esi+2]
	xor	al,ah
	mov	[edi+80*2],al
@TB3:
	mov	al,[esi+3]
	xor	al,ah
	mov	[edi+80*3],al
@TB4:
	mov	al,[esi+4]
	xor	al,ah
	mov	[edi+80*4],al
@TB5:
	mov	al,[esi+5]
	xor	al,ah
	mov	[edi+80*5],al
@TB6:
	mov	al,[esi+6]
	xor	al,ah
	mov	[edi+80*6],al
@TB7:
	mov	al,[esi+7]
	xor	al,ah
	mov	[edi+80*7],al
@TB8:
	mov	al,[esi+8]
	xor	al,ah
	mov	[edi+80*8],al
@TB9:
	mov	al,[esi+9]
	xor	al,ah
	mov	[edi+80*9],al
@TB10:
	mov	al,[esi+10]
	xor	al,ah
	mov	[edi+80*10],al
@TB11:
	mov	al,[esi+11]
	xor	al,ah
	mov	[edi+80*11],al
@TB12:
	Popad
	Ret

@TB25:
	mov	al,[esi+11]			;Bottom to Top (clips bottom)
	xor	al,ah
	mov	[edi+80*11],al
@TB24:
	mov	al,[esi+10]
	xor	al,ah
	mov	[edi+80*10],al
@TB23:
	mov	al,[esi+9]
	xor	al,ah
	mov	[edi+80*9],al
@TB22:
	mov	al,[esi+8]
	xor	al,ah
	mov	[edi+80*8],al
@TB21:
	mov	al,[esi+7]
	xor	al,ah
	mov	[edi+80*7],al
@TB20:
	mov	al,[esi+6]
	xor	al,ah
	mov	[edi+80*6],al
@TB19:
	mov	al,[esi+5]
	xor	al,ah
	mov	[edi+80*5],al
@TB18:
	mov	al,[esi+4]
	xor	al,ah
	mov	[edi+80*4],al
@TB17:
	mov	al,[esi+3]
	xor	al,ah
	mov	[edi+80*3],al
@TB16:
	mov	al,[esi+2]
	xor	al,ah
	mov	[edi+80*2],al
@TB15:
	mov	al,[esi+1]
	xor	al,ah
	mov	[edi+80*1],al
@TB14:
	mov	al,[esi+0]
	xor	al,ah
	mov	[edi+80*0],al
@TB13:
	popad
	ret



;-----------------------------------------------
@QB12:
	mov	al,[esi+11]			;Mem put
	xor	al,ah
	mov	[ecx],al   ;*11
	sub	ecx,ebx
@QB11:
	mov	al,[esi+10]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@QB10:
	mov	al,[esi+9]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@QB9:
	mov	al,[esi+8]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@QB8:
	mov	al,[esi+7]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@QB7:
	mov	al,[esi+6]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@QB6:
	mov	al,[esi+5]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@QB5:
	mov	al,[esi+4]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@QB4:
	mov	al,[esi+3]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@QB3:
	mov	al,[esi+2]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@QB2:
	mov	al,[esi+1]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@QB1:
	mov	al,[esi+0]
	xor	al,ah
	mov	[ecx],al
@QB0:
	ret

;------------------------------------------------

@QB13:
	mov	al,[esi+0]			;Mem put 2
	xor	al,ah
	mov	[ecx],al   ;*0
	add	ecx,ebx
@QB14:
	mov	al,[esi+1]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@QB15:
	mov	al,[esi+2]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@QB16:
	mov	al,[esi+3]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@QB17:
	mov	al,[esi+4]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@QB18:
	mov	al,[esi+5]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@QB19:
	mov	al,[esi+6]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@QB20:
	mov	al,[esi+7]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@QB21:
	mov	al,[esi+8]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@QB22:
	mov	al,[esi+9]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@QB23:
	mov	al,[esi+10]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@QB24:
	mov	al,[esi+11]
	xor	al,ah
	mov	[ecx],al
@QB25:
	Ret

PutCharacter  EndP


Temp_EBX	dd	0
;xxxxxxxxxxxxxxxx
Put2BPL:
	pushad
	mov	esi,[AllocTable+1041*8]
	lea	ebx,[ebx+ebx*2] 	;Get offset to char
	lea	ebx,[ebx*4]
	add	esi,ebx

	mov	dx,3c4h 		;Write mask register
	mov	ax,0202h
	out	dx,ax

	mov	eax,CurrentPlane
	cmp	eax,FontPlane
	jz	CheckPullClip2
	lea	ebx,PopUpPlane1
	cmp	FontPlane,0
	jz	DoClipping2
	lea	ebx,PopUpPlane2
	jmp	DoClipping2
CheckPullClip2:
	lea	ebx,BoxClipByte
	cmp	PullMode,0		;Clip?
	jz	NoClipping2

DoClipping2:
	mov	eax,edi 		;get X and Y coord on screen
	add	eax,_Code32a
	sub	eax,0a0000h
	xor	edx,edx
	mov	ebp,80
	div	ebp			;EDX=X, EAX=Y

	xor	ebp,ebp
ClipNext2:
	cmp	edx,[ebx]
	jb	XNoClip2
	cmp	edx,[ebx+8]
	jae	XNoClip2

	cmp	eax,[ebx+4]
	ja	YNoClip2
	mov	ecx,[ebx+4]
	sub	ecx,eax
	mov	ebp,ecx
	add	ebp,13
	cmp	ebp,25
	jbe	ClipMe2
	mov	ebp,25
	jmp	ClipMe2
YNoClip2:
	cmp	eax,[ebx+12]
	ja	XNoClip2
	mov	ecx,[ebx+12]
	sub	ecx,eax
	mov	ebp,ecx
	inc	ebp
	cmp	ebp,12
	jbe	ClipMe2
	mov	ebp,12
	jmp	ClipMe2
XNoClip2:
	add	ebx,16
	cmp	Dword ptr [ebx],-1
	jnz	ClipNext2
	jmp	NoClipping2
ClipMe2:
	cmp	PullMode,0
	jnz	PullDownClip2

	mov	ecx,FontPlane;CurrentPlane
	add	edx,[AllocTable+ecx*8+1038*8]	;Offs+PrintX
	add	edx,[PopUpPlane1Size+ecx*4]   ;BPL 1
	sub	edx,[ebx]			;-ClipX
	sub	eax,[ebx+4]			;PrintY-ClipY
	mov	ebx,[PopUpPlane1Width+ecx*4]  ;Get Width
	mov	ecx,edx
	mul	ebx
	add	ecx,eax 			;ecx=offs to save buff

	mov	eax,ebp
	cmp	eax,12
	jbe	Case22
	sub	eax,12
Case22:
	dec	eax
	mul	ebx
	add	ecx,eax
PullCont:
	push	esi
	mov	ah,InvertText
	mov	edx,ecx
	call	[ClipCallTbl2+ebp*4]
	add	esi,80*12*4
	mov	ecx,FontPlane;CurrentPlane
	add	edx,[PopUpPlane1Size+ecx*4]
	add	edx,[PopUpPlane1Size+ecx*4]
	mov	ecx,edx
	call	[ClipCallTbl2+ebp*4]
	pop	esi

PrintThisToScreen2:
	mov	ah,InvertText
	mov	ebp,[ClipJumpTbl2+ebp*4]
	mov	edx,2
	jmp	ebp

PullDownClip2:
	sub	edx,[ebx]			;PrintX-ClipX
	sub	eax,[ebx+4]			;PrintY-ClipY
	mov	ecx,[ebx+8]			;Get Width
	sub	ecx,[ebx]

	sub	ebx,Offset BoxClipByte
	shr	ebx,4

	add	edx,[PicOffsets+ebx*4]		;Offs+PrintX
	add	edx,GUS_TempBuffPtr
	add	edx,[PullSaveSize+ebx*4]	;bpl 1
	mov	Temp_EBX,ebx

	mov	ebx,edx
	mul	ecx
	add	ebx,eax
	xchg	ecx,ebx 			;ecx=offs to save buff

	mov	eax,ebp
	cmp	eax,12
	jbe	Case22_
	sub	eax,12
Case22_:
	dec	eax
	mul	ebx
	add	ecx,eax

	push	esi
	mov	ah,InvertText
	mov	edx,ecx
	call	[ClipCallTbl2+ebp*4]
	add	esi,80*12*4
	mov	ecx,Temp_EBX
	add	edx,[PullSaveSize+ecx*4]	;bpl 3
	add	edx,[PullSaveSize+ecx*4]
	mov	ecx,edx
	call	[ClipCallTbl2+ebp*4]
	pop	esi

	mov	ah,InvertText
	mov	ebp,[ClipJumpTbl2+ebp*4]
	mov	edx,2
	jmp	ebp

NoClipping2:
	mov	edx,2
	lea	ebp,@Loop1
	mov	ah,InvertText
@Loop1:
	cmp	PrintCounter,-1
	jz	@2TB0
	mov	[edi-80],ah
@2TB0:
	mov	al,[esi]			;Top To Bottom (clips top)
	xor	al,ah
	mov	[edi],al
@2TB1:
	mov	al,[esi+1]
	xor	al,ah
	mov	[edi+80*1],al
@2TB2:
	mov	al,[esi+2]
	xor	al,ah
	mov	[edi+80*2],al
@2TB3:
	mov	al,[esi+3]
	xor	al,ah
	mov	[edi+80*3],al
@2TB4:
	mov	al,[esi+4]
	xor	al,ah
	mov	[edi+80*4],al
@2TB5:
	mov	al,[esi+5]
	xor	al,ah
	mov	[edi+80*5],al
@2TB6:
	mov	al,[esi+6]
	xor	al,ah
	mov	[edi+80*6],al
@2TB7:
	mov	al,[esi+7]
	xor	al,ah
	mov	[edi+80*7],al
@2TB8:
	mov	al,[esi+8]
	xor	al,ah
	mov	[edi+80*8],al
@2TB9:
	mov	al,[esi+9]
	xor	al,ah
	mov	[edi+80*9],al
@2TB10:
	mov	al,[esi+10]
	xor	al,ah
	mov	[edi+80*10],al
@2TB11:
	mov	al,[esi+11]
	xor	al,ah
	mov	[edi+80*11],al
@2TB12:
	dec	edx
	jz	_retp
	add	esi,80*12*4
	push	ax dx
	mov	dx,3c4h 		;Write mask register
	mov	ax,0802h
	out	dx,ax
	pop	dx ax
	jmp	ebp

@2TB25:
	mov	al,[esi+11]			;Bottom to Top (clips bottom)
	xor	al,ah
	mov	[edi+80*11],al
@2TB24:
	mov	al,[esi+10]
	xor	al,ah
	mov	[edi+80*10],al
@2TB23:
	mov	al,[esi+9]
	xor	al,ah
	mov	[edi+80*9],al
@2TB22:
	mov	al,[esi+8]
	xor	al,ah
	mov	[edi+80*8],al
@2TB21:
	mov	al,[esi+7]
	xor	al,ah
	mov	[edi+80*7],al
@2TB20:
	mov	al,[esi+6]
	xor	al,ah
	mov	[edi+80*6],al
@2TB19:
	mov	al,[esi+5]
	xor	al,ah
	mov	[edi+80*5],al
@2TB18:
	mov	al,[esi+4]
	xor	al,ah
	mov	[edi+80*4],al
@2TB17:
	mov	al,[esi+3]
	xor	al,ah
	mov	[edi+80*3],al
@2TB16:
	mov	al,[esi+2]
	xor	al,ah
	mov	[edi+80*2],al
@2TB15:
	mov	al,[esi+1]
	xor	al,ah
	mov	[edi+80*1],al
@2TB14:
	mov	al,[esi+0]
	xor	al,ah
	mov	[edi+80*0],al
@2TB13:
	dec	edx
	jz	_retp
	add	esi,80*12*4
	push	dx ax
	mov	dx,3c4h 		;Write mask register
	mov	ax,0802h
	out	dx,ax
	pop	ax dx
	jmp	ebp


;-----------------------------------------------
@2QB12:
	mov	al,[esi+11]			;Mem put
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@2QB11:
	mov	al,[esi+10]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@2QB10:
	mov	al,[esi+9]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@2QB9:
	mov	al,[esi+8]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@2QB8:
	mov	al,[esi+7]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@2QB7:
	mov	al,[esi+6]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@2QB6:
	mov	al,[esi+5]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@2QB5:
	mov	al,[esi+4]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@2QB4:
	mov	al,[esi+3]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@2QB3:
	mov	al,[esi+2]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@2QB2:
	mov	al,[esi+1]
	xor	al,ah
	mov	[ecx],al
	sub	ecx,ebx
@2QB1:
	mov	al,[esi+0]
	xor	al,ah
	mov	[ecx],al
@2QB0:
	ret

;------------------------------------------------

@2QB13:
	mov	al,[esi+0]			;Mem put 2
	xor	al,ah
	mov	[ecx],al   ;*0
	add	ecx,ebx
@2QB14:
	mov	al,[esi+1]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@2QB15:
	mov	al,[esi+2]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@2QB16:
	mov	al,[esi+3]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@2QB17:
	mov	al,[esi+4]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@2QB18:
	mov	al,[esi+5]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@2QB19:
	mov	al,[esi+6]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@2QB20:
	mov	al,[esi+7]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@2QB21:
	mov	al,[esi+8]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@2QB22:
	mov	al,[esi+9]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@2QB23:
	mov	al,[esi+10]
	xor	al,ah
	mov	[ecx],al
	add	ecx,ebx
@2QB24:
	mov	al,[esi+11]
	xor	al,ah
	mov	[ecx],al
@2QB25:
	Ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Puts a Decimal Value
;Calls:  AH = BitPlane
;	 CL = Nr of Digits
;	EBX = Value to print
;	EDI = Scr. Position
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PutDecimal     Proc    Near
	pushad
	movzx	ecx,cl
	dec	ecx
	jecxz	OnlyOne

	mov	ch,ah
	mov	ebp,ecx
	xor	ch,ch
	mov	eax,ebx
PutLoop:
	xor	edx,edx
	mov	ebx,10
	div	ebx
	push	dx
	loop	PutLoop
	movzx	ebx,ax
	mov	ecx,ebp
	mov	ah,ch
	xor	ch,ch
	add	bx,30h
	call	PutCharacter
	inc	edi
GetLoop:
	pop	bx
OnlyOne_1:
	add	bx,30h
	call	PutCharacter
	inc	edi
	loop	GetLoop
	popad
	Ret
OnlyOne:
	mov	ecx,1
	jmp	OnlyOne_1
PutDecimal  EndP

PrintModName	Proc	Near
	Pushad
	cmp	Menu_UpperScreen,0		;Check menu
	jnz	QuitPrintMN
	cmp	PianoScreen,0
	jnz	QuitPrintMN
	call	MouseOff
	mov	ah,1
	move	edi,0a0000h+189*80+376/8
	lea	esi,SongName
	mov	cl,30
	call	PrintText
	call	MouseOn
QuitPrintMN:
	Popad
	Ret
PrintModName	EndP

PrintComposer	Proc	Near
	Pushad
	cmp	Menu_UpperScreen,0		;Check menu
	jnz	QuitPrintMN
	cmp	Pianoscreen,0
	jnz	QuitPrintMN
	call	MouseOff
	mov	ah,1
	move	edi,0a0000h+207*80+376/8
	lea	esi,Composer
	mov	cl,30
	call	PrintText
	call	MouseOn
	Popad
	Ret
PrintComposer	EndP

CurrentInstName 	db	0	;Samplename to put first on screen
TotalSampaas		dd	0	;Shit
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Updates the InstrumentNames
;Calls: CurrentInstName
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
UpdateInstNames     Proc    Near
	cmp	Menu_UpperScreen,0		;Check
	jnz	_ret
	Pushad

	move	edi,0a0000h+21*80+344/8
	mov	esi,InstNamesPtr
	mov	edx,12

	movzx	eax,CurrentInstName
	movzx	bx,Samples
	sub	bx,11
	jle	LessThan11_3
	cmp	ax,bx
	jbe	Fluke
	jmp	LessThan11_2
LessThan11_3:
	mov	bx,0
	movzx	edx,Samples
LessThan11_2:
	mov	CurrentInstName,bl
Fluke:
	mov	TotalSampaas,12
	sub	TotalSampaas,edx

	push	edx
	movzx	eax,CurrentInstName
	mov	ebx,30
	mul	ebx
	add	esi,eax
	pop	edx

	mov	MouseX1,343
	mov	MouseX2,617
	mov	MouseY1,20
	mov	MouseY2,165
	call	MouseOff
	movzx	ebp,CurrentInstName
	inc	ebp
	shl	ebp,4
PrintSampleLoopen:
	mov	ax,0f0eh
	push	edi
	mov	ebx,ebp
	shr	ebx,4
	mov	ch,bl
	push	edx
	GetOffset ebx,edx,ENV_Shadow
	cmp	byte ptr [edx],0
	jz	@@NoShadow
;	mov	ch,byte ptr [edx]
	mov	ax,0f0dh
@@NoShadow:
	pop	edx
	cmp	InstNameInput,1
	jz	NoInverse
	cmp	bl,CurrentInstrument
	jnz	NoInverse
	cmp	Sample0,1
	jz	NoInverse
	mov	InvertText,-1
NoInverse:
	mov	bl,al
	call	SetReset

	mov	cl,3
	movzx	ebx,ch
	cmp	SampHexDec,0
	jz	PutDec1
	call	PutHex
	jmp	PutHex1
PutDec1:
	call	PutDecimal
PutHex1:
	add	edi,3
	mov	ebx,' '

	call	CheckInstEmpty2
	jnc	Ajfasikern

	push	esi edi eax edx
	mov	bx,bp
	shr	bx,4
	xor	esi,esi
	mov	ecx,16*16
ScanForSample2:
	cmp	[SplitTable+esi],bl
	jz	GotSplitSample2
Resumer:
	add	esi,4
	loop	ScanForSample2
	jmp	QuitSplit2

GotSplitSample2:
	mov	eax,esi
	shr	eax,6
	cmp	[SplitOnOff+eax],0
	jz	Resumer
	mov	ebx,eax
	add	ebx,4
	pop	edx eax edi esi
	jmp	Ajfasikern
QuitSplit2:
	pop	edx eax edi esi
	mov	ebx,3
Ajfasikern:
	call	putcharacter
	inc	edi
	mov	cl,30
	call	printtext
	add	esi,30
	pop	edi
	add	edi,12*80
	add	ebp,16
	mov	InvertText,0
	dec	edx
	jnz	PrintSampleLoopen

	mov	ecx,TotalSampaas
	cmp	ecx,12
	ja	DontClearar
	jecxz	DontClearar
	lea	esi,Spaces
	mov	ah,0fh
ClearSampleLoopen:
	push	cx
	mov	cl,34
	call	printtext
	pop	cx
	add	edi,12*80
	loop	ClearSampleLoopen

DontClearar:
	mov	bl,0
	call	SetReset
	call	MouseOn
	call	MouseReset
	Popad
	Ret
UpdateInstNames  EndP

UpdateChannelInfo     Proc    Near
	Pushad
	cmp	Menu_DownScreen,3	;Check
	ja	SkipUpdateChannel
	call	MouseOff
	move	edi,0a0000h+244*80+32/8
	movzx	ebp,CurrentChannel
	mov	ecx,1
	cmp	Menu_DownScreen,2	;Zoomed PT Pattern
	jz	NoChange
	cmp	Menu_DownScreen,3	;Zoomed ST Pattern
	jz	NoChange

	mov	ecx,6
NoChange:
	push	ecx
	mov	eax,ebp
	cmp	al,Channels
	jae	ClearOnly

	lea	esi,Spaces;Samp
	mov	al,[ChanPos+ebp]
	mov	ah,8h
	mov	cl,4
	cmp	DisplayVolume,1
	jz	NoPrintii
	call	PrintText	;Print SAMP/MIDI
NoPrintii:
	add	edi,5
	movzx	ebx,al
	mov	ah,1h
	mov	cl,2
	call	PutDecimal	;Print Ch Nr

	movzx	ebx,byte ptr [ChanPos+ebp]
	push	ebx
	mov	eax,' '
	cmp	[Mute+ebx],0
	jz	Olla3
	mov	eax,'M'
	cmp	[Mute+ebx],1
	jz	Olla3
	mov	eax,'L'
Olla3:
	mov	ebx,eax
	add	edi,3
	mov	ah,8h
	call	PutCharacter	;Print M (Mute)
	pop	ebx

	add	edi,2
	movzx	ebx,[Cmd+ebx]
	mov	cl,1
	call	PutDecimal	;Print Comm. Nr

	mov	eax,ebp
	cmp	ChanNameInputSlot,al
	jz	PrintOnly

	pushad			;Print ChannelName
	movzx	ebx,byte ptr [ChanPos+ebp]
	mov	eax,11
	mul	ebx
	add	eax,ChannelNamesPtr
	mov	esi,eax
	mov	ah,1
	mov	cl,11
	sub	edi,10+80*18
	call	printtext
	popad
	jmp	PrintOnly

ClearOnly:
	push	edi
	mov	ebx,' '
	lea	esi,Spaces
	inc	edi
	mov	ah,8
	mov	cl,2
	call	PrintText
	add	edi,7
	mov	cl,1
	call	PutCharacter
	add	edi,2
	call	PutCharacter
	mov	ah,1
	sub	edi,5
	mov	cl,2
	call	PrintText
	sub	edi,80*18+5
	mov	ecx,ebp
	cmp	ChanNameInputSlot,cl
	jz	NoThgin
	mov	cl,11
	call	PrintText
NoThgin:
	pop	edi
	add	edi,10

PrintOnly:
	inc	ebp
	add	edi,2
	pop	ecx
	loop	NoChange

	call	MouseOn
SkipUpdateChannel:

	cmp	DisplayVolume,0
	jz	NoPrintii2
	lea	edi,UpdateVolumeValues-32
	mov	al,-1
	mov	ecx,32
	rep	stosb
NoPrintii2:
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


	mov	MouseX1,158
	mov	MouseY1,194
	mov	MouseX2,158+15
	mov	MouseY2,222

	mov	edx,158
	xor	ebp,ebp
	mov	ecx,32
NextOlla:
	push	ecx edx ebp
	movzx	ebx,byte ptr [ChanPos+ebp]
	mov	eax,0	;None
	cmp	[Mute+ebx],0
	jz	@@Olla
	mov	eax,1	;Mute
	cmp	[Mute+ebx],1
	jz	@@Olla
	mov	eax,2	;Lock
@@Olla:
	call	MouseOff
	call	DrawEQBitMap
	call	MouseOn
	pop	ebp edx ecx
	inc	ebp
	add	edx,15
	add	MouseX2,15
	loop	NextOlla

	call	MouseReset


	Popad
	Ret
UpdateChannelInfo  EndP

EQBitMapTBL	dd	EQ0,EQ1,EQ2

EQ0		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000000000000000b

EQ1		dw	1110000000111000b
		dw	1110000000111000b
		dw	1110000000111000b
		dw	1110000000111000b
		dw	1110000000111000b
		dw	1111000001111000b
		dw	0111000001110000b
		dw	0111000001110000b
		dw	0111100011110000b
		dw	0011100011100000b
		dw	0011110111100000b
		dw	0001111111000000b
		dw	0000111110000000b
		dw	0000111110000000b
		dw	0000111110000000b
		dw	0000111110000000b
		dw	0001111111000000b
		dw	0011110111100000b
		dw	0011100011100000b
		dw	0111100011110000b
		dw	0111000001110000b
		dw	0111000001110000b
		dw	1111000001111000b
		dw	1110000000111000b
		dw	1110000000111000b
		dw	1110000000111000b
		dw	1110000000111000b
		dw	1110000000111000b

EQ2		dw	0000000000000000b
		dw	0000000000000000b
		dw	0000111111000000b
		dw	0001111111100000b
		dw	0001100001100000b
		dw	0001111111100000b
		dw	0000111111000000b
		dw	0000011110000000b
		dw	0000001100000000b
		dw	0000001100000000b
		dw	0000001100000000b
		dw	0000001100000000b
		dw	0000001100000000b
		dw	0000001100000000b
		dw	0000001100000000b
		dw	0000001100000000b
		dw	0000001100000000b
		dw	0000001100000000b
		dw	0000001100000000b
		dw	0000001100000000b
		dw	0000001100000000b
		dw	0000001100000000b
		dw	0001111100000000b
		dw	0000111100000000b
		dw	0001111100000000b
		dw	0000001100000000b
		dw	0000000000000000b
		dw	0000000000000000b


;In: eax=BitMap
;    edx=XOffset
DrawEQBitMap:

	push	eax edx
	mov	ax,0102h
	mov	dx,3c4h
	out	dx,ax

	mov	ax,0004h
	mov	dx,3ceh 		;Set bitplane (read)
	out	dx,ax
	pop	edx eax


	move	edi,0a0000h+193*80
	mov	esi,[EQBitMapTBL+eax*4]
	mov	eax,edx

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



InputTemp	db	80 dup(0)	;TempBuffer for InputRoutine
InputCursor	dd	0		;Cursor (relative EDI)
InitInput	db	0		;1 If Called once, Set to 0 when quit.
InputTable	dd	0,0,0,0,0	;SaveTable for Variables
Inputlimit	db	48,49,50,51,52,53,54,55,56,57, 65,66,67,68,69,70, 97,98,99,100,101,102
InputRepeatFix	db	0
InputVirtMax	db	0

InputDelta	dd	0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls:
;	EDI = ScreenPos
;	ESI = TextBuffer
;	ECX = MaxLen (visible length)
;	AH  = Bitplane
;	AL  = 1 Dec	+10h = Fontplane 1
;	      2 Hex	+20h = Fontplane 2
;	      3 Text
;	InputVirtMax = Virtual Max. i.e scrollable length
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
InputRoutine	 Proc	 Near
	Pushad

	cmp	InitInput,1
	jz	AlreadyCalled
	mov	InputRepeatFix,1
	mov	OldPattName,0

	mov	InputDelta,0
	mov	[InputTable+0],eax
	mov	[InputTable+4],ecx
	mov	[InputTable+8],esi
	mov	[InputTable+12],edi
	movzx	eax,InputVirtMax
	cmp	eax,0
	jnz	@@Booze
	mov	eax,ecx
@@Booze:
	mov	[InputTable+16],eax
	mov	InputVirtMax,0
	cmp	PosedInput,0
	jnz	Oops
	mov	InputCursor,0
	mov	eax,edi
	mov	ebx,80
	xor	edx,edx
	div	ebx
	shl	edx,3
	movzx	ebx,MouseX
	sub	ebx,edx
	jl	Oops
	shr	ebx,3
	cmp	ebx,[InputTable+4]
	jb	oops2
	mov	ebx,[InputTable+4]
	dec	ebx
oops2:
	mov	InputCursor,ebx
Oops:
	lea	edi,InputTemp

	pushad
	xor	al,al
	mov	ecx,80
	rep	stosb
	popad

	mov	ecx,[InputTable+16]
	rep	movsb
	mov	InitInput,1
	jmp	PrintInputText
AlreadyCalled:

	cmp	InputRepeatFix,1
	jz	NoClearInput2
	cmp	MouseB,1
	jz	AcceptInput
	cmp	MouseB,2
	jz	AcceptInput
NoClearInput2:
	cmp	MouseB,3
	jnz	NoClearInput
	lea	edi,InputTemp
	mov	ecx,80
	mov	al,'0'
	cmp	DigitInput,0
	jnz	Julin
	mov	al,0
Julin:
	rep	stosb
	mov	BothKeyWait,-1
	jmp	AcceptInput
NoClearInput:

	call	ScanTable
	sub	edi,Offset KeyBoardTable
	push	eax edx
	mov	eax,edi
	mov	edi,20
	xor	edx,edx
	div	edi
	mov	edi,eax
	pop	edx eax
	cmp	edi,1		;ESC
	jz	AbortInput
	cmp	edi,28		;ENTER
	jz	AcceptInput
	cmp	edi,89		;ENTER
	jz	AcceptInput
	cmp	edi,96		;Arrow Up
	jz	InputArrowUp
	cmp	edi,72		;Arrow Up
	jz	InputArrowUp
	cmp	edi,98		;Arrow Left
	jz	InputArrowLeft
	cmp	edi,75		;Arrow Left
	jz	InputArrowLeft
	cmp	edi,99		;Arrow Right
	jz	InputArrowRight
	cmp	edi,77		;Arrow Right
	jz	InputArrowRight
	cmp	edi,101 	;Arrow Down
	jz	InputArrowDown
	cmp	edi,80		;Arrow Down
	jz	InputArrowDown
	cmp	edi,95		;Home
	jz	InputHome
	cmp	edi,71		;Home
	jz	InputHome
	cmp	edi,100 	;End
	jz	InputEnd
	cmp	edi,79		;End
	jz	InputEnd
	cmp	edi,103 	;Insert
	jz	InputInsert
	cmp	edi,82		;Insert
	jz	InputInsert
	cmp	edi,104 	;Delete
	jz	InputDelete
	cmp	edi,83		;Insert
	jz	InputDelete
	cmp	edi,14		;BackSpace
	jz	InputBackSpace

	cmp	byte ptr [Keys+58],1
	jnz	NoCapslock
	call	ToggleCapsLock
NoCapslock:

	mov	esi,KeyBoard_AltGR		;If ALT GR is pressed
	cmp	byte ptr [Keys+0b8h],1
	jz	SearchKey

	mov	esi,KeyBoard_Table		;If SHIFT is pressed
	cmp	byte ptr [Keys+2ah],1
	jz	ShiftIsPressed
	cmp	byte ptr [Keys+36h],0
	jz	NoShiftPressed
ShiftIsPressed:
	call	CapsLockSkip
	jc	DoShift
	cmp	TheCapsLock,1
	jz	SearchKey
Doshift:
	mov	esi,KeyBoard_Shift

	jmp	SearchKey
NoShiftPressed:
	call	CapsLockSkip
	jc	SearchKey
	cmp	TheCapsLock,1
	jz	DoShift
SearchKey:
	movzx	eax,byte ptr [esi]
	cmp	eax,0
	jz	QuitInputRoutine
	add	esi,2
	cmp	eax,edi
	jnz	SearchKey
	mov	al,[esi-1]
					;Check if key is valid
	lea	esi,InputLimit
	mov	ebx,[InputTable+0]
	and	bl,0fh
	cmp	bl,3			;If text to print
	jz	PrintInputText1
	mov	ecx,10
	cmp	bl,1			;If decimal number
	jz	PrintInputDigit
	mov	ecx,22			;Hex
PrintInputDigit:
	cmp	byte ptr [esi],al
	jz	PrintInputText1
	inc	esi
	loop	PrintInputDigit
	jmp	QuitInputRoutine	;No Valid key

PrintInputText1:
	lea	esi,InputTemp
	add	esi,InputCursor
	cmp	Insert,0
	jz	NoInsert1
	push	esi
	std
	lea	edi,InputTemp
	add	edi,[InputTable+16]
	mov	esi,edi
	dec	esi
	mov	ecx,[InputTable+16]
	sub	ecx,InputCursor
	rep	movsb
	cld
	pop	esi
NoInsert1:
	mov	[esi],al
	jmp	InputArrowRight

DecimalPoint	db	0
PrintInputText:
	mov	eax,[InputTable+0]
	mov	bl,al
	and	al,0fh
	shr	bl,4
	mov	byte ptr FontPlane,bl
	mov	ecx,[InputTable+4]
	lea	esi,InputTemp
	mov	InputDelta,0

	cmp	ecx,InputCursor
	ja	@@NoProbb
	mov	edi,InputCursor
	inc	edi
	sub	edi,ecx
	add	esi,edi
	mov	InputDelta,edi
@@NoProbb:
	move	edi,0a0000h
	add	edi,[InputTable+12]
	call	mouseoff

	mov	edx,-1
	push	edi
	cmp	DecimalPoint,0
	jz	DontPrintDecimal
	sub	cl,DecimalPoint
	call	PrintText
	add	esi,ecx
	add	edi,ecx
	inc	edi
	mov	edx,ecx
	mov	cl,DecimalPoint
DontPrintDecimal:
	call	PrintText
	mov	FontPlane,0
	pop	edi

	cmp	InputCursor,edx
	jnz	DontIncIC
	inc	edi
DontIncIC:

	dec	ah
	shr	ah,1
	Mov	Dx,3ceh 				;Read mask register
	Mov	Al,04h
	Out	Dx,Ax
	add	edi,InputCursor
	sub	edi,InputDelta
	cmp	Insert,0
	jz	InsertOn

	irp	I,0,1,2,3,4,5				;Print Cursor (Ins ON)
	xor	byte ptr [edi+80*I],-1
	endm
InsertOn:
	irp	I,6,7,8,9,10,11 			;Print Cursor (Ins OFF)
	xor	byte ptr [edi+80*I],-1
	endm
	jmp	QuitInputRoutine


InputInsert:
	xor	Insert,1
	jmp	PrintInputText

InputDelete:
	lea	edi,InputTemp
	add	edi,InputCursor
	mov	esi,edi
	inc	esi
	mov	ecx,[InputTable+16]
	sub	ecx,InputCursor
	rep	movsb
	dec	edi
	xor	al,al
	mov	bl,byte ptr [InputTable+0]
	and	bl,0fh
	cmp	bl,3
	jz	Text2
	mov	al,'0'
Text2:
	stosb
	jmp	PrintInputText

InputBackSpace:
	mov	eax,InputCursor
	dec	eax
	jl	QuitInputRoutine
	mov	InputCursor,eax

	lea	edi,InputTemp
	add	edi,InputCursor
	cmp	Insert,0
	jz	InsertOff
	mov	esi,edi
	inc	esi
	mov	ecx,[InputTable+16]
	sub	ecx,InputCursor
	rep	movsb
	dec	edi
InsertOff:
	xor	al,al
	mov	bl,byte ptr [InputTable+0]
	and	bl,0fh
	cmp	bl,3
	jz	Text3
	mov	al,'0'
Text3:
	stosb
	jmp	PrintInputText

InputArrowUp:
	cmp	PosedInput,0
	jz	PrintInputText
	mov	ax,CurrStartPosition
	cmp	ax,CurrCursorPosition
	jnz	NoChangeCurrStart1
	cmp	CurrStartPosition,0
	jz	PrintInputText
	dec	CurrStartPosition
NoChangeCurrStart1:
	dec	CurrCursorPosition
	mov	PosedInput,2
	jmp	AcceptInput

InputArrowDown:
	cmp	PosedInput,0
	jz	PrintInputText
	mov	ax,CurrStartPosition
	add	ax,6
	cmp	ax,CurrCursorPosition
	jnz	NoChangeCurrStart2
	inc	ax
	cmp	ax,Positions
	jz	PrintInputText
	inc	CurrStartPosition
NoChangeCurrStart2:
	inc	CurrCursorPosition
	mov	PosedInput,2
	jmp	AcceptInput

InputArrowLeft:
	mov	eax,InputCursor
	dec	eax
	jl	QuitInputRoutine
	mov	InputCursor,eax
	jmp	PrintInputText

InputArrowRight:
	mov	eax,InputCursor
	inc	eax
	cmp	eax,[InputTable+16]
	jz	SPrintInputText
	inc	InputCursor
	jmp	PrintInputText

SPrintInputText:
	cmp	PosedInput,1
	jz	CheckPosedd
	cmp	AutoAccept,0
	jnz	AcceptInput
	jmp	PrintInputText
CheckPosedd:
	cmp	AutoAccept,1
	jz	AcceptInput
	jmp	PrintInputText

InputHome:
	mov	InputCursor,0
	jmp	PrintInputText

InputEnd:
	lea	esi,InputTemp
	mov	ecx,[InputTable+16]
	dec	ecx
InputEndScan:
	cmp	[InputTemp+ecx],0
	loopz	InputEndScan
	jz	ItsZXerer
	inc	ecx
ItsZXerer:
	mov	InputCursor,ecx
	jmp	PrintInputText

AcceptInput:
	lea	esi,InputTemp
	mov	edi,[InputTable+8]
	mov	ecx,[InputTable+16]
	rep	movsb
AbortInput:
ContAccept:
	mov	ChanNameInputSlot,-1
	mov	InitInput,0
	mov	eax,[InputTable+0]
	mov	bl,al
	and	al,0fh
	shr	bl,4
	mov	byte ptr FontPlane,bl
	mov	ecx,[InputTable+4]
	mov	esi,[InputTable+8]
	move	edi,0a0000h
	add	edi,[InputTable+12]
	call	MouseOff

	mov	edx,-1
	push	edi
	cmp	DecimalPoint,0
	jz	DontPrintDecimal2
	sub	cl,DecimalPoint
	call	PrintText
	add	esi,ecx
	add	edi,ecx
	inc	edi
	mov	edx,ecx
	mov	cl,DecimalPoint
DontPrintDecimal2:
	call	PrintText
	mov	FontPlane,0
	pop	edi

	cmp	InputCursor,edx
	jnz	DontIncIC2
	inc	edi
DontIncIC2:

	mov	OldPattName,-1
	mov	PatternNameInput,0
	cmp	FileNameInput,0
	jz	NoFileNameInput
	mov	FileNameInput,0
	call	ParsePath
	call	UpdateFileList
	mov	ax,CurrentFileName
	mov	OldCurrentFileName,ax

NoFileNameInput:
	cmp	InstNameInput,0
	jz	NoinstInput
	mov	InstNameInput,0
	mov	FileEdited,1
	mov	OldCurrentInstName,-1
	jmp	QuitInputRoutine
NoInstInput:
	cmp	SampleNameInput,0
	jz	NoSampleInput
	mov	SampleNameInput,0
	mov	FileEdited,1
	mov	OldCurrentSampName,-1
	jmp	QuitInputRoutine
Nosampleinput:
	cmp	DigitInput,0		;Check if Digit requires updating...
	jnz	ConvertAsciiToDigit
	jmp	QuitInputRoutine
FixAllNeededStuff:
	cmp	DigitInput,1
	jnz	CheckPatternUpdate
	mov	FileEdited,1
	mov	DigitInput,0
	mov	OldPos2,-1
	mov	OldPos,-1
	cmp	TuneStopped,0
	jz	Ayways
	movzx	ebx,CurrPosition
	shl	ebx,1
	add	ebx,PatternOrderPtr
	movzx	ebx,word ptr [ebx]
	mov	CurrPatt,bx
	cmp	ProTrackerEditing,1
	jz	QuitInputRoutine
Ayways:
	call	PosInit
	mov	OldRow,-1
	jmp	QuitInputRoutine
CheckPatternUpdate:
	cmp	DigitInput,2
	jnz	CheckSongLengthUpdate
	mov	FileEdited,1
	mov	DigitInput,0
	movzx	ebx,CurrPosition
	shl	ebx,1
	add	ebx,PatternOrderPtr
	movzx	ebx,word ptr [ebx]
	mov	ah,08h
	mov	cl,4
	move	edi,0a0000h+38*80+88/8
	call	MouseOff
	call	PutDecimal
	call	MouseOn
	mov	OldPos,-1
	mov	OldPos2,-1
	cmp	ProTrackerEditing,1
	jz	QuitInputRoutine

	call	StopAllVoices
	call	ClearForPlay
	call	PosInit
	mov	pt_counter,0
	mov	OldRow,-1
	mov	OldPattName,-1
	jmp	QuitInputRoutine
CheckSongLengthUpdate:
	cmp	DigitInput,3
	jnz	CheckBPMUpdate
	mov	FileEdited,1
	mov	DigitInput,0
	mov	OldPos,-1
	mov	OldPos2,-1
	cmp	TempPositions,0
	jnz	ItsNotZeroAnyway
	mov	TempPositions,1
ItsNotZeroAnyway:
	movzx	eax,TempPositions
	shl	eax,1
	mov	ebp,1030		;Allocate Positions
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	PatternOrderPtr,eax
	mov	ax,TempPositions
	mov	Positions,ax
	jmp	QuitInputRoutine
CheckBPMUpdate:
	cmp	DigitInput,4
	jnz	CheckSampleNrUpdate
	mov	DigitInput,0
	mov	ax,TempModTempo
	mov	cx,10
	xor	dx,dx
	div	cx
	mov	bx,ax
	shl	bx,8

	mov	ax,dx
	mov	cx,26
	mul	cx
	or	ax,bx

	cmp	ah,32
	ja	NoFix1
	mov	ah,32
NoFix1:
	mov	ModTempo,ax
	mov	OldBPM,-1
	mov	HertzAdder,ax
	mov	OldPos,-1
	mov	OldPos2,-1
	mov	DecimalPoint,0

	jmp	QuitInputRoutine
CheckSampleNrUpdate:
	cmp	DigitInput,5
	jnz	CheckRepBegUpdate
	mov	DigitInput,0
	movzx	ax,CurrentInstrument
	cmp	ax,0
	jnz	NoItsNotZero
	movzx	ax,Sample0
	mov	CurrentInstrument,al
	jmp	YesItsZero
NoItsNotZero:
	mov	Sample0,0
YesItsZero:
	shl	ax,4
	mov	CurrentSample,ax
	call	PrintSampleInfo
	call	SampleToRAM

	cmp	AutoName,0
	jz	Kula
	pushad
	call	Getname2
	popad
Kula:
	movzx	bx,CurrentInstName
	mov	al,CurrentInstrument
	cmp	al,OldCurrentInstrument
	jz	DontUpdateit3

	cmp	ax,bx
	jb	UpdateIt1
	add	bx,12
	cmp	ax,bx
	jb	DontUpdateIt3

	mov	OldCurrentInstrument,al
	sub	al,12
	mov	CurrentInstName,al
	mov	OldCurrentInstName,-1
	jmp	DontUpdateIt3
UpdateIt1:
	mov	CurrentInstName,al
	mov	OldCurrentInstName,-1
DontUpdateIt3:


	jmp	QuitInputRoutine
CheckRepBegUpdate:
	cmp	DigitInput,6
	jnz	CheckRepEndUpdate
	mov	FileEdited,1
	mov	DigitInput,0
	movzx	ebp,CurrentSample
	mov	ebx,[SampleOffsetStart+ebp*4]
	add	[LoopStart+ebp*4],ebx
	cmp	EndOrLen,0
	jz	NoRepEndFix
	mov	ebx,RepeatLengthSave
	add	ebx,[LoopStart+ebp*4]
	mov	RepeatLengthSave,0
	mov	[LoopEnd+ebp*4],ebx
NoRepEndFix:
	call	PrintSampleInfo
	call	SetSampleLoop
	mov	peghide,0
	mov	themovepeg,1
	call	movethepegs
	jmp	QuitInputRoutine
CheckRepEndUpdate:
	cmp	DigitInput,7
	jnz	CheckC2RateUpdate
	mov	FileEdited,1
	mov	DigitInput,0
	movzx	ebp,CurrentSample
	mov	ebx,[LoopEnd+ebp*4]
	cmp	EndOrLen,0
	jz	NoRepBegInput_Fix
	add	ebx,[LoopStart+ebp*4]
	cmp	ebx,[LoopStart+ebp*4]
	jz	ItsNotLooped
	jmp	RepBegInput_Fix
NoRepBegInput_Fix:
	add	ebx,[SampleOffsetStart+ebp*4]
RepBegInput_Fix:
	cmp	ebx,[LoopStart+ebp*4]
	ja	ItsLooped
	mov	ebx,[LoopStart+ebp*4]
	cmp	ebx,[SampleOffsetStart+ebp*4]
	jz	ItsNotLooped
;	inc	ebx
	jmp	ItsLooped
ItsNotLooped:
	mov	[LoopEnd+ebp*4],ebx
	call	PrintSampleInfo
	call	SetSampleLoop
	mov	peghide,0
	mov	themovepeg,2
	call	movethepegs
	jmp	QuitInputRoutine
ItsLooped:
	mov	[LoopEnd+ebp*4],ebx
	call	PrintSampleInfo
	call	SetSampleLoop
	mov	peghide,0
	call	movethepegs
	jmp	QuitInputRoutine
CheckC2RateUpdate:
	cmp	DigitInput,8
	jnz	CheckSampleRate
	mov	FileEdited,1
	mov	DigitInput,0
	movzx	ebp,CurrentSample
	cmp	[SampleRates+ebp*2],522
	jae	@@Ful
	mov	[SampleRates+ebp*2],522
@@Ful:
	call	PrintSampleInfo
	jmp	QuitInputRoutine
CheckSampleRate:
	cmp	DigitInput,9
	jnz	CheckVolumeUpdate
	cmp	samplerate2,2000
	jae	skipsettrate
	mov	samplerate2,2000
SkipSettRate:
	call	printsamplerate
	call	SetFrequenzy
	mov	FileEdited,1
	mov	DigitInput,0
	jmp	QuitInputRoutine
CheckVolumeUpdate:
	cmp	DigitInput,10
	jnz	CheckPattern2Update
	mov	FileEdited,1
	mov	DigitInput,0
	call	PrintSampleInfo
	jmp	QuitInputRoutine
CheckPattern2Update:
	cmp	DigitInput,11
	jnz	CheckPattern3Update
	mov	FileEdited,1
	mov	DigitInput,0
	movzx	ebx,CurrPatt2
	pushad
	call	PattInit
	popad
	mov	ah,08h
	mov	cl,4
	move	edi,0a0000h+191*80+88/8
	call	MouseOff
	call	PutDecimal
	call	MouseOn
	mov	OldPos,-1
	mov	OldPos2,-1
	mov	OldRow,-1
	mov	OldPattName,-1
	jmp	QuitInputRoutine
CheckPattern3Update:
	cmp	DigitInput,12
	jnz	CheckChannelUpdate
	call	ShowPosList
	cmp	PosedInput,2
	jz	PosEditorInput3
	mov	FileEdited,1
	mov	DigitInput,0
	mov	PosedInput,0
	call	ShowPosList

	movzx	ebx,CurrCursorPosition
	shl	ebx,1
	add	ebx,PatternOrderPtr
	movzx	ebx,word ptr [ebx]
	mov	CurrPatt,bx
	mov	CurrPatt2,bx
	call	PosInit

	mov	OldRow,-1
	mov	OldPos,-1
	mov	OldPos2,-1
	mov	OldPattName,-1
	jmp	QuitInputRoutine
CheckChannelUpdate:
	cmp	DigitInput,13
	jnz	CheckChannelPosition
	mov	DigitInput,0
	cmp	TempChannels,0
	jnz	NoBugFix
	mov	TempChannels,1
NoBugFix:
ChanUDragMeanWhile2:
	mov	al,TempChannels
	mov	ebx,PatternStart
	mov	ah,Commands
	mov	TempCommands,ah
	call	FixPatternWidth
	mov	Channels,al

	cmp	al,6
	jb	NoBugFix2
	mov	al,6
NoBugFix2:
	and	eax,0ffh
	mov	[DragBarData+116],eax
	mov	[DragBarData+168],eax

	call	PrintPattInfo
	mov	Oldrow,-1
	mov	OldCurrentChannel,-1

	mov	al,Channels
	dec	al
	cmp	al,CursorChannel
	jae	NoBugFix3
	mov	CursorChannel,al
NoBugFix3:
	mov	al,CurrentChannel
	add	al,6
	cmp	al,Channels
	jbe	QuitInputRoutine
	mov	al,Channels
	sub	al,6
	jge	WellIAgree
	mov	al,0
WellIAgree:
	mov	CurrentChannel,al
	jmp	QuitInputRoutine
CheckChannelPosition:
	cmp	DigitInput,14
	jnz	CheckMaxCommands
	mov	DigitInput,0
	call	UpdateChannelInfo
	mov	OldRow,-1
	jmp	QuitInputRoutine
CheckMaxCommands:
	cmp	DigitInput,15
	jnz	CheckMaxChannels
	mov	DigitInput,0
	cmp	DefaultCommands,0
	jnz	Fanfar
	mov	DefaultCommands,1
	jmp	Fanfar
CheckMaxChannels:
	cmp	DigitInput,16
	jnz	CheckMaxPatterns
	mov	DigitInput,0
	cmp	DefaultChannels,0
	jnz	Fanfar
	mov	DefaultChannels,1
	jmp	Fanfar
CheckMaxPatterns:
	cmp	DigitInput,17
	jnz	CheckMaxPositions
	mov	DigitInput,0
	cmp	DefaultRows,0
	jnz	Fanfar
	mov	DefaultRows,1
Fanfar:
	call	UpdatePattDefScreen
	call	AllocateEmptyPattern
	call	PrintPattInfo
	jmp	QuitInputRoutine
CheckMaxPositions:
	cmp	DigitInput,18
	jnz	CheckMaxSampBuff
	mov	DigitInput,0
	call	UpdateSCScreen
	call	SC_ChangeReplay
	cmp	PlayFreq,5000
	jae	QuitInputRoutine
	mov	PlayFreq,5000
	call	UpdateSCScreen
	jmp	QuitInputRoutine
CheckMaxSampBuff:
	cmp	DigitInput,19
	jnz	CheckMaxClipBuff
	mov	DigitInput,0
	mov	ax,TempModTempo
	mov	cx,10
	xor	dx,dx
	div	cx
	mov	bx,ax
	shl	bx,8

	mov	ax,dx
	mov	cx,26
	mul	cx
	or	ax,bx

	cmp	ah,32
	ja	@@Nofix1
	mov	ah,32
@@Nofix1:
	mov	InitBPM,ax
	mov	DecimalPoint,0
	call	UpdateSongCfgScreen
	jmp	QuitInputRoutine
CheckMaxClipBuff:
	cmp	DigitInput,20
	jnz	CheckVolSpeed
	mov	DigitInput,0
	cmp	InitSpeed,0
	jnz	@@Skip
	mov	InitSpeed,1
@@Skip:
	call	UpdateSongCfgScreen
	jmp	QuitInputRoutine

CheckVolSpeed:
	cmp	DigitInput,25
	jnz	CheckPanSpeed
	mov	DigitInput,0
	call	PrintEnvVolSpeed
	jmp	QuitInputRoutine
CheckPanSpeed:
	cmp	DigitInput,26
	jnz	CheckVibSpeed
	mov	DigitInput,0
	call	PrintEnvPanSpeed
	jmp	QuitInputRoutine
CheckVibSpeed:
	cmp	DigitInput,27
	jnz	CheckFadeOut
	mov	DigitInput,0
	call	PrintVibSpeed
	jmp	QuitInputRoutine
CheckFadeOut:
	cmp	DigitInput,28
	jnz	CheckZyricInput
	mov	DigitInput,0
	jmp	QuitInputRoutine
CheckZyricInput:
	cmp	DigitInput,29
	jnz	QuitInputRoutine
	call	AfterZyricInput
	mov	DigitInput,0
	jmp	QuitInputRoutine
QuitInputRoutine:
	call	mouseon
	Popad
	Ret
PosEditorInput3:
	mov	PosedInput,1
	call	mouseon
	Popad
	jmp	PosEditorInput2
InputRoutine  EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls:
;	EDI = ScreenPos
;	EBX = Number
;	ECX = MaxLen
;	AH  = Bitplane
;	AL  = 1 Dec
;	      2 Hex
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DigitBuffer	db	8 dup(0)	;Original Number (in ascii form)
InputDigits	Proc	Near
	Pushad
	cmp	MouseB,3
	jnz	NoDigitErase
	mov	ebx,0
NoDigitErase:

	cmp	al,2
	jz	ConvertToHex

;ConvertToDecimal:
	pushad
	lea	edi,DigitBuffer
	movzx	ecx,cl
	dec	ecx
	jecxz	OnlyOne2

	mov	ch,ah
	mov	ebp,ecx
	xor	ch,ch
	mov	eax,ebx
PutLoop2:
	xor	edx,edx
	mov	ebx,10
	div	ebx
	push	dx
	loop	PutLoop2
	movzx	ebx,ax
	mov	ecx,ebp
	mov	ah,ch
	xor	ch,ch
	add	bx,30h
	mov	al,bl
	stosb
GetLoop2:
	pop	bx
OnlyOne_12:
	add	bx,30h
	mov	al,bl
	stosb
	loop	GetLoop2
	popad
	jmp	DoneConvert
OnlyOne2:
	mov	ecx,1
	jmp	OnlyOne_12

ConvertToHex:
	pushad
	lea	edi,DigitBuffer
	shl	ecx,2
	ror	ebx,cl
	shr	ecx,2
PutLoopenH:
	xor	eax,eax
	shld	eax,ebx,4
	shl	ebx,4
	mov	al,[HexTable+eax]
	stosb
	loop	PutLoopenH
	popad

DoneConvert:
	lea	esi,DigitBuffer
	call	InputRoutine

	Popad
	Ret
InputDigits  EndP

DigitTable	dd	0,1,10,100,1000,10000,100000,1000000,10000000
DigitSize	db	3	;1=byte,2=word,3=dword
DigitTarget	dd	0	;Offset to put number
DigitInput	db	0	;Nr of Digit to be changed (check Tracker.cod)
DigitLimit	dd	0	;Limit of the value
ConvertAsciiToDigit:
	mov	eax,[InputTable+0]
	and	al,0fh
	mov	ecx,[InputTable+4]
	mov	esi,[InputTable+8]

	cmp	al,2
	jz	ConvertAsciiToHex
	mov	ebp,[DigitTable+ecx*4]

	xor	ebx,ebx
Convert1Loopen:
	lodsb
	sub	al,30h
	movzx	eax,al
	mul	ebp
	add	ebx,eax
	mov	eax,ebp
	mov	ebp,10
	xor	edx,edx
	div	ebp
	mov	ebp,eax
	loop	Convert1Loopen

WriteByte:
	cmp	ebx,DigitLimit
	jbe	No_Change
	mov	ebx,DigitLimit
No_Change:
	mov	ebp,DigitTarget
	cmp	DigitSize,1
	jz	PutByte
	cmp	DigitSize,2
	jz	PutWord
	mov	dword ptr [ebp],ebx
	jmp	FixAllNeededStuff
PutByte:
	mov	byte ptr [ebp],bl
	jmp	FixAllNeededStuff
PutWord:
	mov	word ptr [ebp],bx
	jmp	FixAllNeededStuff

ConvertAsciiToHex:
	xor	eax,eax
	xor	ebx,ebx
Convert2Loopen:
	lodsb
	sub	al,30h
	cmp	al,10
	jb	GotHexChar
	sub	al,7
	cmp	al,10h
	jb	GotHexChar
	sub	al,20h
GotHexChar:
	shl	eax,28
	shld	ebx,eax,4
	loop	Convert2Loopen
	jmp	WriteByte

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls:
;	EAX = Channel to Cut from
;	EBX = TempOffset
;	ECX = Row to Cut from
;	EDX = Rows to Cut
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Cut_Command	Proc	Near
	cmp	edx,0
	jz	Dummy
	push	eax
	push	ebx
	push	ecx
	push	edx
	movzx	eax,byte ptr [ChanPos+eax]
	mov	edi,ebx

	push	ecx eax edi		;Clear
	mov	ecx,7*2*256+2
	xor	al,al
	rep	stosb
	pop	edi eax ecx

	call	CheckPatternStart_Edit
	mov	esi,PatternStart
	push	edx
	mov	ebx,RowSize		;Channel
	mov	[edi],bx
	add	edi,2

	mul	ebx
	add	esi,eax
	mov	eax,ChRowSize		;Row
	mul	ecx
	add	esi,eax
	add	esi,2

	pop	edx
	mov	ax,dx
	add	ax,cx
	sub	ax,word ptr CurrPattLength
	jle	NoRowChange3
	sub	dx,ax
	jle	NoCut2
NoRowChange3:
	xor	ax,ax
CutLoopen2:
	push	edi esi
	push	esi
	mov	ecx,RowSize
	sub	ecx,2
	rep	movsb
	pop	edi
	mov	ecx,RowSize
	sub	ecx,2
	rep	stosb
	pop	esi edi
	add	edi,RowSize
	sub	edi,2
	add	esi,ChRowSize
	dec	edx
	jnz	CutLoopen2
NoCut2:
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret
Cut_Command  EndP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls:
;	EAX = Channel to Copy from
;	EBX = TempOffset
;	ECX = Row to Copy from
;	EDX = Rows to Copy
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Copy_Command	 Proc	 Near
	cmp	edx,0
	jz	Dummy
	push	eax
	push	ebx
	push	ecx
	push	edx
	movzx	eax,byte ptr [ChanPos+eax]
	mov	edi,ebx

	push	ecx eax edi		;Clear
	mov	ecx,7*2*256+2
	xor	al,al
	rep	stosb
	pop	edi eax ecx

	call	CheckPatternStart_View
	mov	esi,PatternStart
	push	edx
	mov	ebx,RowSize		;Channel
	mov	[edi],bx
	add	edi,2
	mul	ebx
	add	esi,eax
	mov	eax,ChRowSize		;Row
	mul	ecx
	add	esi,eax
	add	esi,2

	pop	edx
	mov	ax,dx
	add	ax,cx
	sub	ax,word ptr CurrPattLength
	jle	NoRowChange2
	sub	dx,ax
	jle	NoCopy2
NoRowChange2:
	xor	ax,ax
CopyLoopen2:
	push	esi
	mov	ecx,RowSize
	sub	ecx,2
	rep	movsb
	pop	esi
	add	esi,ChRowSize
	dec	edx
	jnz	CopyLoopen2
NoCopy2:
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	Ret
Copy_Command  EndP

Least		dd	0
CutRowSize	dd	0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls:
;	EAX = Channel to paste on
;	EBX = TempOffset
;	ECX = Row to paste on
;	EDX = Rows to Paste
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Paste_Command	Proc	Near
	cmp	edx,0
	jz	Dummy
	push	eax
	push	ebx
	push	ecx
	push	edx
	movzx	eax,byte ptr [ChanPos+eax]
	mov	esi,ebx

	movzx	ebx,word ptr [esi]
	cmp	ebx,0
	jz	NoPaste2
	mov	CutRowSize,ebx		;ebx=buffer's size
	sub	CutRowSize,2
	mov	Least,ebx
	cmp	ebx,RowSize
	jbe	Fiffi

	push	esi
	mov	esi,RowSize
	mov	Least,esi
	lea	esi,CommandCut
	mov	Menu_Popup,2
	call	PopUpHandler
	pop	esi
	cmp	PopupStatus,0
	jz	Fiffi
	mov	Least,ebx

	sub	bl,2
	shr	bl,1
	mov	TempCommands,bl
	mov	bh,Channels
	mov	TempChannels,bh
	call	FixPatternWidth
	mov	Commands,bl
	call	PrintPattInfo

Fiffi:
	add	esi,2

	sub	Least,2

	call	CheckPatternStart_Edit
	mov	edi,PatternStart
	push	edx
	mov	ebx,RowSize		;Channel
	mul	ebx
	add	edi,eax
	mov	eax,ChRowSize		;Row
	mul	ecx
	add	edi,eax
	add	edi,2

	pop	edx
	mov	ax,dx
	add	ax,cx
	sub	ax,word ptr CurrPattLength
	jle	NoRowChange
	sub	dx,ax
	jle	NoPaste2
NoRowChange:
	xor	ax,ax
PasteLoopen2:
	push	esi
	push	edi
	mov	ecx,RowSize
	sub	ecx,2
	rep	stosb
	pop	edi
	push	edi
	mov	ecx,Least
	rep	movsb
	pop	edi
	pop	esi
	add	edi,ChRowSize
	add	esi,CutRowSize
	dec	edx
	jnz	PasteLoopen2
NoPaste2:
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret
Paste_Command	EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls:
;	EAX = Channel to Cut from
;	EBX = TempOffset
;	ECX = Row to Cut from
;	EDX = Rows to Cut
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Cut_Channel	Proc	Near
	cmp	edx,0
	jz	Dummy
	push	eax
	push	ebx
	push	ecx
	push	edx
	movzx	eax,byte ptr [ChanPos+eax]
	mov	edi,ebx

	push	ecx eax edi		;Clear
	mov	ecx,512
	xor	al,al
	rep	stosb
	pop	edi eax ecx

	call	CheckPatternStart_Edit
	mov	esi,PatternStart
	push	edx
	mov	ebx,RowSize		;Channel
	mul	ebx
	add	esi,eax
	mov	eax,ChRowSize		;Row
	mul	ecx
	add	esi,eax
	pop	edx
	mov	ax,dx
	add	ax,cx
	sub	ax,word ptr CurrPattLength
	jle	NoRowChange6
	sub	dx,ax
	jle	NoCut
NoRowChange6:
	xor	ax,ax
CutLoopen1:
	push	edi esi
	push	esi
	movsw
	pop	edi
	stosw
	pop	esi edi
	add	edi,2
	add	esi,ChRowSize
	dec	edx
	jnz	CutLoopen1
NoCut:
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret
Cut_Channel	EndP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls:
;	EAX = Channel to Kill from
;	ECX = Row to Cut from
;	EDX = Rows to Cut
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Kill_SampleChannel	Proc	Near
	cmp	edx,0
	jz	Dummy
	push	eax
	push	ebx
	push	ecx
	push	edx
	movzx	eax,byte ptr [ChanPos+eax]
	call	CheckPatternStart_Edit
	mov	edi,PatternStart
	push	edx
	mov	ebx,RowSize		;Channel
	mul	ebx
	add	edi,eax
	mov	eax,ChRowSize		;Row
	mul	ecx
	add	edi,eax
	pop	edx
	xor	ax,ax
	mov	bl,CurrentInstrument
KillLoopen2:
	cmp	bl,[edi+1]
	jnz	DontKillr
	push	edi
	mov	ecx,RowSize
	rep	stosb
	pop	edi
DontKillr:
	add	edi,ChRowSize
	dec	edx
	jnz	KillLoopen2
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret
Kill_SampleChannel	EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls:
;	EAX = Channel to Kill from
;	ECX = Row to Cut from
;	EDX = Rows to Cut
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Kill_Channel	 Proc	 Near
	cmp	edx,0
	jz	Dummy
	push	eax
	push	ebx
	push	ecx
	push	edx
	movzx	eax,byte ptr [ChanPos+eax]
	call	CheckPatternStart_Edit
	mov	edi,PatternStart
	push	edx
	mov	ebx,RowSize		;Channel
	mul	ebx
	add	edi,eax
	mov	eax,ChRowSize		;Row
	mul	ecx
	add	edi,eax
	pop	edx
	xor	ax,ax
KillLoopen:
	push	edi
	mov	ecx,RowSize
	rep	stosb
	pop	edi
	add	edi,ChRowSize
	dec	edx
	jnz	KillLoopen
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret
Kill_Channel	 EndP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls:
;	EAX = Channel to Copy from
;	EBX = TempOffset
;	ECX = Row to Copy from
;	EDX = Rows to Copy
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Copy_Channel	Proc	Near
	cmp	edx,0
	jz	Dummy
	push	eax
	push	ebx
	push	ecx
	push	edx
	movzx	eax,byte ptr [ChanPos+eax]
	mov	edi,ebx

	push	ecx eax edi		;Clear
	mov	ecx,512
	xor	al,al
	rep	stosb
	pop	edi eax ecx

	call	CheckPatternStart_View
	mov	esi,PatternStart
	push	edx
	mov	ebx,RowSize		;Channel
	mul	ebx
	add	esi,eax
	mov	eax,ChRowSize		;Row
	mul	ecx
	add	esi,eax
	pop	edx
	mov	ax,dx
	add	ax,cx
	sub	ax,word ptr CurrPattLength
	jle	NoRowChange5
	sub	dx,ax
	jle	NoCopy
NoRowChange5:
	xor	ax,ax
CopyLoopen1:
	push	esi
	movsw
	pop	esi
	add	esi,ChRowSize
	dec	edx
	jnz	CopyLoopen1
NoCopy:
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret
Copy_Channel	Endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls:
;	EAX = Channel to paste on
;	EBX = TempOffset
;	ECX = Row to paste on
;	EDX = Rows to Paste
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Paste_Channel	Proc	Near
	cmp	edx,0
	jz	Dummy
	push	eax
	push	ebx
	push	ecx
	push	edx
	movzx	eax,byte ptr [ChanPos+eax]
	mov	esi,ebx
	call	CheckPatternStart_Edit
	mov	edi,PatternStart
	push	edx
	mov	ebx,RowSize		;Channel
	mul	ebx
	add	edi,eax
	mov	eax,ChRowSize		;Row
	mul	ecx
	add	edi,eax
	pop	edx
	mov	ax,dx
	add	ax,cx
	sub	ax,word ptr CurrPattLength
	jle	NoRowChange4
	sub	dx,ax
	jle	NoPaste
NoRowChange4:
	xor	ax,ax
PasteLoopen1:
	push	edi
	movsw
	pop	edi
	add	edi,ChRowSize
	dec	edx
	jnz	PasteLoopen1
NoPaste:
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret
Paste_Channel	EndP


IF DOS32VERSION
Int24	dd	0	;Fatal Error save
SetVector24	proc	near
	pushad

	mov	eax,gs:[24h*4]
	mov	Int24,eax

	mov	ax,0EE21h
	mov	esi,Offset DriveNotReady
	int	31h
	jc	_retp_stc

	mov	gs:[24h*4],dx
	mov	gs:[24h*4+2],cx

	clc
	popad
	ret
_retp_stc:
	stc
	popad
	ret
SetVector24	endp

RestoreVector24 proc	near
	pushad

	mov	eax,Int24
	mov	gs:[24h*4],eax

	popad
	ret
RestoreVector24     endp

Crit_Error	db	0
DriveNotReady	Proc	Far
	push	ecx
	push	ds
	mov	ds,cs:_seldata
	call	sara4
	mov	ecx,4
ff:	call	sync
	loop	ff
	call	sara4
	mov	ds:Crit_Error,0
	mov	al,0
	pop	ds
	pop	ecx
	retf
DriveNotReady	EndP


ENDIF

IF PMODEWVERSION
OLD_PM_24	df	0
SetVector24	proc	near
	pushad
	mov	ax,0204h
	mov	bl,24h		;Get old interrupt
	int	31h
	mov	dword ptr Old_PM_24,edx
	mov	word ptr Old_PM_24+4,cx

	mov	ax,0205h	;Set new interrupt
	mov	bl,24h
	mov	cx,cs
	lea	edx,DriveNotReady
	int	31h

	clc
	popad
	ret
_retp_stc:
	stc
	popad
	ret
SetVector24	endp

RestoreVector24 proc	near
	pushad

	mov	ax,0205h
	mov	bl,24h
	mov	edx,dword ptr Old_PM_24
	mov	cx,word ptr Old_PM_24+4
	int	31h

	popad
	ret
RestoreVector24     endp

Crit_Error	db	0
DriveNotReady	Proc	Far
	push	ecx
	push	ds
	mov	ds,cs:_seldata
	call	sara4
	mov	ecx,4
ff:	call	sync
	loop	ff
	call	sara4
	mov	ds:Crit_Error,0
	mov	al,0
	pop	ds
	pop	ecx	
	iretd
DriveNotReady	EndP


ENDIF



PrintPattInfo	  Proc	  Near
	Pushad
	cmp	Menu_UpperLeft,2		;Check menu
	jnz	DontPrint
	mov	MouseX1,84
	mov	MouseY1,137
	mov	MouseX2,120
	mov	MouseY2,204

	call	CheckPatternStart_View
	mov	ebp,PatternStart
	sub	ebp,12
	call	MouseOff
	mov	ah,8

	mov	bl,byte ptr [ebp+11]
	and	ebx,31
	inc	ebx
	mov	cl,2
	move	edi,0a0000h+140*80+104/8
	call	PutDecimal

	movzx	ebx,byte ptr [ebp+11]
	shr	bl,5
	mov	cl,1
	move	edi,0a0000h+157*80+112/8
	call	PutDecimal

	movzx	ebx,byte ptr [ebp+10]
	inc	ebx
	move	edi,0a0000h+174*80+96/8
	mov	cl,3
	cmp	RowsHexDec,1
	jz	PrintItHex
	call	PutDecimal
	jmp	DontPrintItHex
PrintItHex:
	call	PutHex
DontPrintItHex:

	movzx	ebx,CurrPatt2
	move	edi,0a0000h+191*80+88/8
	mov	cl,4
	call	PutDecimal

	call	MouseOn
	call	mousereset
DontPrint:
	Popad
	Ret
PrintPattInfo  EndP

UpdateSplitStatus	Proc	Near
	pushad
	mov	BitPlane,1
	mov	KBD1Request,0			;Clear it
	mov	KBD2Request,0
	mov	KBD3Request,0
	movzx	ebx,CurrentSplit
	mov	bl,[SplitOnOff+ebx]
	xor	bl,1
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	ButtonX1,525-8
	mov	ButtonY1,115
	mov	ButtonX2,591
	mov	ButtonY2,130
	call	ButtonUpDown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1

	call	MouseOff
	mov	ah,01h
	mov	cl,2
	move	edi,0a0000h+100*80+256/8
	movzx	ebx,CurrentSplit
	mov	FontPlane,1
	call	PutDecimal

	movzx	eax,CurrentSplit
	mov	ebx,16*4
	mul	ebx
	mov	ecx,eax

	movzx	eax,CurrentZone
	mov	ebx,4
	mul	ebx
	add	ecx,eax
	mov	CurrentSplitOffset,ecx
	mov	edx,ecx

	mov	ah,01h
	mov	cl,2
	move	edi,0a0000h+117*80+256/8
	movzx	ebx,CurrentZone
	call	PutDecimal

	mov	cl,3
	move	edi,0a0000h+100*80+376/8
	movzx	esi,byte ptr [SplitTable+edx+1]
	cmp	esi,2
	jae	NoKBD1Fix
	mov	[SplitTable+edx+1],0
	mov	esi,0
NoKBD1Fix:
	call	PrintPeriod

	mov	cl,3
	move	edi,0a0000h+117*80+376/8
	movzx	esi,byte ptr [SplitTable+edx+2]
	cmp	esi,2
	jae	NoKBD2Fix
	mov	[SplitTable+edx+2],0
	mov	esi,0
NoKBD2Fix:
	call	PrintPeriod

	mov	cl,3
	move	edi,0a0000h+134*80+376/8
	movzx	esi,byte ptr [SplitTable+edx+3]
	cmp	esi,2
	jae	NoKBD3Fix
	mov	[SplitTable+edx+3],0
	mov	esi,0
NoKBD3Fix:
	call	PrintPeriod

	mov	cl,3
	move	edi,0a0000h+134*80+256/8
	movzx	ebx,byte ptr [SplitTable+edx]
	mov	CurrentInstrument,bl

	movzx	ax,bl
	shl	ax,4
	mov	CurrentSample,ax
	mov	CurrentSampName,ax

	mov	ah,01h
	cmp	SampHexDec,0
	jz	PutDec7
	call	PutHex
	jmp	PutHex7
PutDec7:
	call	PutDecimal			;Put Current Sample
PutHex7:
	mov	FontPlane,0
	call	MouseOn
	popad
	ret
UpdateSplitStatus	EndP
PeriodText	db	'---Off'
		db	'C-0C#0D-0D#0E-0F-0F#0G-0G#0A-0A#0B-0'
		db	'C-1C#1D-1D#1E-1F-1F#1G-1G#1A-1A#1B-1'
		db	'C-2C#2D-2D#2E-2F-2F#2G-2G#2A-2A#2B-2'
		db	'C-3C#3D-3D#3E-3F-3F#3G-3G#3A-3A#3B-3'
		db	'C-4C#4D-4D#4E-4F-4F#4G-4G#4A-4A#4B-4'
		db	'C-5C#5D-5D#5E-5F-5F#5G-5G#5A-5A#5B-5'
		db	'C-6C#6D-6D#6E-6F-6F#6G-6G#6A-6A#6B-6'
		db	'C-7C#7D-7D#7E-7F-7F#7G-7G#7A-7A#7B-7'
		db	'C-8C#8D-8D#8E-8F-8F#8G-8G#8A-8A#8B-8'
		db	'C-9C#9D-9D#9E-9F-9F#9G-9G#9A-9A#9B-9'
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Prints the period in ESI to EDI
;bitplane=BitPlane
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PrintPeriod	Proc	Near
	pushad
	mov	ah,BitPlane
	mov	cl,3
	lea	esi,[esi+esi*2]
	add	esi,Offset PeriodText
	call	PrintText
	popad
	ret
PrintPeriod	EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Checks if to change sample, due to split.
; In:  EBX - Sample nr
;      KeyBoardNote - Note
; Out: EBX - New Sample Nr
;      KeyBoardNote - New Note
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SplitKeyBoard	Proc	Near
	push	eax
	push	ecx
	push	edx
	push	esi
	push	edi

	cmp	SplitPlay,1
	jz	QuitSplit

	xor	esi,esi
	mov	ecx,16*16
ScanForSample:
	cmp	[SplitTable+esi],bl
	jz	GotSplitSample
ResumeSearch:
	add	esi,4
	loop	ScanForSample
	jmp	QuitSplit

GotSplitSample:
	mov	eax,esi
	shr	eax,6
	cmp	[SplitOnOff+eax],0
	jz	ResumeSearch
	shl	eax,6
	mov	esi,eax
	mov	ecx,16
	movzx	eax,byte ptr KeyBoardNote
ScanForNotes:
	cmp	al,[SplitTable+esi+1]
	jb	NextNote
	cmp	al,[SplitTable+esi+2]
	ja	NextNote
	movzx	eax,byte ptr [SplitTable+esi]
	cmp	al,Samples
	ja	QuitSplit

	push	ecx
	xor	edi,edi
	mov	ecx,16*16
Noaf:
	cmp	byte ptr [SplitTable+edi],al
	jz	Itsad
ResumeSearch3:
	add	edi,4
	loop	Noaf
	pop	ecx
	jmp	Kulle
Itsad:
	mov	edx,edi
	shr	edx,6
	cmp	[SplitOnOff+edx],0
	jz	ResumeSearch3
	shl	edx,6

	pop	ecx
	mov	edi,esi
	and	edi,not 63
	cmp	edx,edi
	jb	QuitSplit
Kulle:
	mov	ebx,eax 		;New sample
	cmp	[SplitTable+esi+3],11
	jz	QuitSplit		;No Transpose
	mov	al,[SplitTable+esi+3]
	sub	al,[SplitTable+esi+1]
	add	al,byte ptr KeyBoardNote
	cmp	al,0
	jl	QuitSplit
	cmp	al,107
	ja	QuitSplit
	mov	byte ptr KeyBoardNote,al
	jmp	QuitSplit
NextNote:
	add	esi,4
	loop	ScanForNotes
QuitSplit:
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	eax
	ret
SplitKeyBoard	EndP

SampleToRAM	Proc	Near
	pushad
	cmp	menu_downscreen,5
	jz	skipcompare
	cmp	menu_downscreen,4
	jnz	Nofiff
skipcompare:
	call	updateshadows
	movzx	ebx,CurrentSample
	mov	SampLength,0
	mov	SampBits,0
	bt	word ptr [VoiceControl+ebx],2
	rcl	SampBits,1

	mov	ecx,[SampleOffsetEnd+ebx*4]
	sub	ecx,[SampleOffsetStart+ebx*4]
	mov	SampLength,ecx
	call	allocsamplength
	cmp	SampLength,0
	jz	Nofiff1

	mov	eax,[SampleOffsetStart+ebx*4]
	mov	ebx,SampMainOffset
	mov	edx,128
	call	MouseHourGlass
	call	GetSampleFromDRAM
	call	MouseArrow
Nofiff1:
	mov	sampmarkstart,-1
	mov	playpegoff,0
	mov	undosamplength,0

	call	MouseOff
	call	ViewAll2
	call	MouseOn

	lea	edi,oldputs
	mov	eax,-1
	mov	ecx,20
	rep	stosd

Nofiff: popad
	ret
SampleToRAM	EndP

SampleToGUS	Proc	Near
	pushad
	movzx	ebx,CurrentSample
	mov	esi,[SampleOffsetStart+ebx*4]
	mov	eax,[SampleOffsetEnd+ebx*4]
	sub	eax,esi
	jz	Nofaff
	call	DisallocSample
Nofaff:
	mov	eax,[SampleOffsetStart+ebx*4]
	mov	[SampleOffsetStart+ebx*4],0
	sub	[LoopStart+ebx*4],eax
	sub	[LoopEnd+ebx*4],eax
	mov	eax,SampLength
	mov	ecx,eax
	mov	[SampleOffsetEnd+ebx*4],eax
	cmp	eax,0
	jz	_retp
	push	eax
	and	byte ptr [voicecontrol+ebx],not 4h  ;16 bits
	mov	eax,SampBits
	shl	eax,2
	or	[VoiceControl+ebx],al
	pop	eax
	call	AllocSample
	jnc	NoMOVErr
	call	FixAllocSampleError
NoMOVErr:
	mov	edx,128
	call	MouseHourGlass
	call	MoveSample
	jc	ErrorHandler
	call	MouseArrow
	call	SetSampOffset
	mov	eax,[AllocTable+1024*8] 	;To inform Zyric what's going on
	mov	SampMainOffset,eax
	popad
	ret
SampleToGUS	EndP

UpdateRowSize	dd	0
PrintCounter	db	-1
SetResetMask	db	0
FillDot 	db	0

;calls: bitplane=bpl
;	edi=offset, ebx=row, ah=bpl to print row number in.
PrintOneRow_PT	  proc	  near
	push	edi ebx eax
	movzx	eax,UpdateCommands
	lea	eax,[eax*2+2]
	mov	UpdateRowSize,eax

	mov	SetResetMask,00h
	cmp	BitPlane,18h
	jz	NoHelpBars

	mov	BitPlane,07h
	mov	SetResetMask,06h

	cmp	ScreamTrackerHelpBars,0
	jz	NoHelpBars
	xor	edx,edx
	movzx	eax,ScreamTrackerHelpBars
	xchg	eax,ebx
	div	ebx
	cmp	edx,0
	jnz	NoHelpBars
	mov	SetResetMask,05h
NoHelpBars:
	pop	eax ebx edi
	call	MouseOff

	push	bx
	mov	bl,SetResetMask
	call	SetReset
	pop	bx

	cmp	ebx,0
	jl	DoTheRow
	cmp	ebx,UpdateRows
	jae	DoTheRow

	push	cx ebx
	mov	cl,2
	cmp	RowsHexDec,1
	jz	PrintItHex1
agg:	cmp	ebx,100
	jb	Itsfien
	sub	ebx,100
	jmp	Agg
Itsfien:
	call	PutDecimal
	jmp	DontPrintItHex1
PrintItHex1:
	call	PutHex
DontPrintItHex1:
	pop	ebx cx

DoTheRow:
	cmp	ebx,UpdateRows
	jae	Clew
	cmp	ebx,0
	jge	DoTheRow2
Clew:
	push	ebx			;Clear row num
	mov	ebx,' '
	mov	ah,07h
	call	PutCharacter
	inc	edi
	call	PutCharacter
	dec	edi
	pop	ebx
DoTheRow2:
	cmp	Menu_DownScreen,2
	jz	ZoomedPTPattern
	cmp	Menu_DownScreen,3
	jz	ZoomedPTPattern

	pushad
	add	edi,3
	movzx	ebp,CurrentChannel
	mov	ecx,6
PrintOneRow:
	push	esi

	mov	PrintCounter,0
	mov	edx,ebp
	cmp	dl,UpdateChannels
	jae	ClearInstead
	cmp	ebx,0
	jl	ClearInstead
	cmp	ebx,UpdateRows
	jae	ClearInstead

	push	ebx
	movzx	eax,byte ptr [ChanPos+ebp]
	mov	ebx,UpdateRowSize
	mul	ebx
	add	esi,eax
	pop	ebx

	call	MM_CheckPeriod
	push	esi
	movzx	esi,byte ptr [esi]	;Get Period
	call	PrintPeriod
	inc	PrintCounter
	pop	esi

	push	UpdateCurrRow
	mov	UpdateCurrRow,-1
	call	MM_CheckPeriod
	push	ebx
	add	edi,3
	mov	ebx,' '
	cmp	BitPlane,18h
	jz	MM_Fill2
	cmp	ScreamTrackerHelpBars,0
	jz	MM_Fill2
ClearAnywway3:
	mov	al,InvertText
	mov	InvertText,0
	mov	ah,03h
	call	PutCharacter
	add	edi,3
	call	PutCharacter
	sub	edi,3
	mov	InvertText,al
MM_Fill2:
	mov	ah,BitPlane
	call	PutCharacter
	add	edi,3
	call	PutCharacter
	sub	edi,2
	pop	eax
	pop	UpdateCurrRow

	movzx	ebx,byte ptr [esi+1]	;Get Samplenr
	cmp	bl,0
	jnz	@@Skip
	mov	dl,ShowZero
	mov	FillDot,dl
@@Skip:
	call	putnumber2
	add	edi,3
	mov	FillDot,0

	movzx	edx,byte ptr [ChanPos+ebp]
	movzx	ebx,byte ptr [Cmd+edx]
	cmp	bl,Commands
	jb	NoToneFix
	mov	bl,Commands
	dec	bl
	mov	byte ptr [Cmd+edx],bl
NoToneFix:
	mov	edx,ebx
	cmp	word ptr [esi+edx*2+2],0	  ;Check CommandByte
	jnz	@@NoEmpty
	mov	bl,ShowZero
	mov	FillDot,bl
@@NoEmpty:
	movzx	ebx,byte ptr [esi+edx*2+2]	  ;Get CommandByte
	call	putnumber2
	add	edi,2
	movzx	ebx,byte ptr [esi+edx*2+3]	  ;Get CommandData
	call	putnumber2
	xchg	eax,ebx
	add	edi,3
	mov	FillDot,0
	jmp	PrintInstead

ClearInstead:
	mov	InvertText,0
	push	ecx ebx
	xor	eax,eax
	mov	ecx,11
	mov	ebx,' '
	mov	ah,03h
	cmp	Bitplane,18h
	jnz	ClearOneRow3
	mov	ah,BitPlane
ClearOneRow3:
	call	PutCharacter
	inc	edi
	loop	ClearOneRow3
	pop	ebx ecx
	inc	edi
PrintInstead:
	pop	esi
	inc	ebp
	loop	PrintOneRow
	add	MouseY1,13
	add	MouseY2,13
	call	MouseOn
	mov	PrintCounter,-1
	mov	InvertText,0
	popad
	ret

ZoomedPTPattern:
	pushad
	add	edi,3
	movzx	ebp,CurrentChannel

	cmp	ebx,0
	jl	SkipPORPT
	cmp	ebx,UpdateRows
	jae	SkipPORPT

	movzx	eax,byte ptr [ChanPos+ebp]
	mov	ecx,UpdateRowSize
	mul	ecx
	add	esi,eax

	mov	PrintCounter,0
	call	MM_CheckPeriod
	push	esi
	movzx	esi,byte ptr [esi]	  ;Get Period
	call	PrintPeriod
	inc	PrintCounter
	pop	esi

	push	UpdateCurrRow
	mov	UpdateCurrRow,-1
	call	MM_CheckPeriod
	push	ebx
	add	edi,3
	mov	ebx,' '
	mov	ah,03h
	cmp	Bitplane,18h
	jz	MM_Fill1
	cmp	ScreamTrackerHelpBars,0
	jz	MM_Fill1
ClearAnywway33:
	mov	al,InvertText
	mov	InvertText,0
	mov	ah,03h
	call	PutCharacter
	add	edi,3
	call	PutCharacter
	sub	edi,3
	mov	InvertText,al
MM_Fill1:
	mov	ah,BitPlane
	call	PutCharacter
	add	edi,3
	call	PutCharacter
	sub	edi,2
	pop	eax
	pop	UpdateCurrRow

	movzx	ebx,byte ptr [esi+1]	    ;Get Samplenr
	cmp	bl,0
	jnz	@@Skip2
	mov	dl,ShowZero
	mov	FillDot,dl
@@Skip2:
	call	putnumber2
	mov	FillDot,0

	add	edi,3
	add	esi,2
	xor	edx,edx
	mov	ecx,7
PrintCommandLoopen:
	cmp	dl,UpdateCommands
	jae	ClearInstead2
	cmp	word ptr [esi],0	;Check CommandByte
	jnz	@@NoEmpty2
	mov	bl,ShowZero
	mov	FillDot,bl
@@NoEmpty2:
	movzx	ebx,byte ptr [esi]	;Get CommandByte
	call	putnumber2
	add	edi,2
	movzx	ebx,byte ptr [esi+1]	;Get CommandData
	call	putnumber2
	add	edi,3
	add	esi,2
	mov	FillDot,0
	jmp	PrintInstead2
ClearInstead2:
	mov	InvertText,0
	push	eax ecx edi
	xor	eax,eax
	mov	ecx,4
	mov	ebx,' '
	mov	ah,BitPlane
ClearOneRow4:
	call	PutCharacter
	inc	edi
	loop	ClearOneRow4
	pop	edi ecx eax
	add	edi,5
PrintInstead2:
	inc	edx
	loop	PrintCommandLoopen
	add	MouseY1,13
	add	MouseY2,13
	call	MouseOn
	mov	PrintCounter,-1
	mov	InvertText,0
	popad
	ret
PrintOneRow_PT	EndP


MM_CheckOther:
	push	eax ebx
	mov	ebx,ebp
	cmp	bl,MM_ChanStart
	jb	MM_COEnd
	cmp	bl,MM_ChanEnd
	ja	MM_COEnd
	cmp	si,MM_RowStart
	jb	MM_COEnd
	cmp	si,MM_RowEnd
	ja	MM_COEnd

	mov	al,PrintCounter
	inc	al
	shr	al,2

	cmp	bl,MM_ChanStart
	jnz	MM_COEnd2
	cmp	al,MM_Start
	jb	MM_COEnd
	cmp	bl,MM_ChanEnd
	jnz	MM_COEnd3
	cmp	al,MM_End
	ja	MM_COEnd
	jmp	MM_COEnd3
MM_COEnd2:
	cmp	bl,MM_ChanEnd
	jnz	MM_COEnd3

	cmp	al,MM_End
	ja	MM_COEnd

MM_COEnd3:
	mov	InvertText,-1
	jmp	MM_COFinal
MM_COEnd:
	mov	InvertText,0
MM_COFinal:
	cmp	bl,CursorChannel
	jnz	NoInve2
	cmp	si,UpdateCurrRow
	jnz	NoInve2
	mov	al,PrintCounter
	cmp	al,UpdateArrowPointer
	jnz	NoInve2
	xor	InvertText,-1
NoInve2:
	pop	ebx eax
	ret

MM_CheckPeriod:
	push	eax
	mov	eax,ebp
	cmp	al,MM_ChanStart
	jb	MM_CPEnd
	cmp	al,MM_ChanEnd
	ja	MM_CPEnd
	cmp	bx,MM_RowStart
	jb	MM_CPEnd
	cmp	bx,MM_RowEnd
	ja	MM_CPEnd

	cmp	al,MM_ChanStart
	jnz	MM_CPEnd2
	cmp	MM_Start,0
	jnz	MM_CPEnd
MM_CPEnd2:
	mov	InvertText,-1
	jmp	MM_CPFinal
MM_CPEnd:
	mov	InvertText,0
MM_CPFinal:

	cmp	al,CursorChannel
	jnz	NoInve
	cmp	bx,UpdateCurrRow
	jnz	NoInve
	mov	al,PrintCounter
	cmp	al,UpdateArrowPointer
	jnz	NoInve
	xor	InvertText,-1
NoInve:
	pop	eax
	ret


CrazyTable	db 1,1,1,1,1,1,1,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1
SkipPORPT:
	mov	PrintCounter,0
	mov	ecx,11+6*4
	mov	ebx,' '
	xor	esi,esi
	xor	edx,edx
	mov	ah,07h
ClearOneRow_PTZoomed2:
	call	PutCharacter
	mov	dl,[CrazyTable+esi]
	add	edi,edx
	inc	esi
	loop	ClearOneRow_PTZoomed2
	add	MouseY1,13
	add	MouseY2,13
	call	MouseOn
	mov	PrintCounter,-1
	popad
	ret

PrintSampleInfo     Proc    Near
	Pushad
	mov	al,OldCurrentInstrument
	cmp	CurrentInstrument,al
	jz	NoUpd
	mov	CurrentPanPoint,0
	mov	CurrentVolPoint,0
	mov	VolEnvStartCoord,0
	mov	PanEnvStartCoord,0
	call	UpdateEnvelopeScreen
NoUpd:
	cmp	Menu_UpperLeft,2
	jz	PrintPattSampleInfo
	cmp	Menu_UpperLeft,0
	jnz	QuitPrintSampleInfo
	mov	KBD4Request,0
	call	MouseOff

	mov	ah,08h
	mov	cl,3
	move	edi,0a0000h+89*80+88/8
	mov	ebx,' '
	call	CheckInstEmpty
	jnc	NoInstBa2
	mov	ebx,3
NoInstBa2:
	call	PutCharacter
	inc	edi
	movzx	ebx,CurrentInstrument


	cmp	Sample0,0
	jz	NoItsNotEvenClose
	mov	ebx,0
NoItsNotEvenClose:
	mov	ebp,ebx
	cmp	SampHexDec,0
	jz	PutDec2
	call	PutHex
	jmp	PutHex2
PutDec2:
	call	PutDecimal			;Put Current Inst
PutHex2:
	movzx	ebp,CurrentSample
	mov	cl,7
	move	edi,0a0000h+106*80+64/8
	mov	ebx,[SampleOffsetEnd+ebp*4]
	sub	ebx,[SampleOffsetStart+ebp*4]
	jz	NoAdd1
NoAdd1:
	cmp	LenHexDec,0
	jz	PutDec3
	call	PutHex
	jmp	PutHex3
PutDec3:
	call	PutDecimal			;Put Sample Length
PutHex3:

	mov	cl,7
	move	edi,0a0000h+123*80+64/8
	mov	ebx,[LoopStart+ebp*4]
	sub	ebx,[SampleOffsetStart+ebp*4]
	jz	NoAdd2
NoAdd2:
	cmp	LenHexDec,0
	jz	PutDec4
	call	PutHex
	jmp	PutHex4
PutDec4:
	call	PutDecimal			;Put Rep Beg
PutHex4:

	mov	cl,7
	move	edi,0a0000h+140*80+64/8
	mov	ebx,[LoopEnd+ebp*4]
	cmp	EndOrLen,0
	jz	RepeatEndan
	sub	ebx,[LoopStart+ebp*4]
	jmp	NoAdd3
RepeatEndan:
	sub	ebx,[SampleOffsetStart+ebp*4]
	jz	NoAdd3
NoAdd3:
	cmp	LenHexDec,0
	jz	PutDec5
	call	PutHex
	jmp	PutHex5
PutDec5:
	call	PutDecimal			;Print Rep End
PutHex5:
	cmp	C2Mode,0
	jz	PrintC2Numbers

	mov	ah,8
	mov	cl,2
	move	edi,0a0000h+157*80+80/8
	lea	esi,Spaces
	call	PrintText
	call	GetCurrC2RateInPeriod
	add	esi,2
	move	edi,0a0000h+157*80+(80/8)+2
	mov	BitPlane,8
	call	PrintPeriod
	jmp	SkipC2Print

PrintC2Numbers:
	mov	cl,5
	move	edi,0a0000h+157*80+80/8
	movzx	ebx,[SampleRates+ebp*2]
	call	PutDecimal			;Print SampleRate
SkipC2Print:

	mov	ah,8
	mov	cl,1
	move	edi,0a0000h+174*80+104/8
	movzx	ebx,[FineTunes+ebp]
	and	ebx,0fh
	cmp	ebx,0
	jz	PutSpace
	cmp	ebx,8
	jb	PutPositive1
	mov	ebx,'-'
	jmp	PutMore
PutPositive1:
	mov	ebx,'+'
	jmp	PutMore
PutSpace:
	mov	ebx,' '
PutMore:
	call	PutCharacter			;print + or -

	mov	cl,1
	move	edi,0a0000h+174*80+112/8
	movzx	ebx,[FineTunes+ebp]
	and	ebx,0fh
	cmp	ebx,8
	jb	PutPositive
	sub	bl,16
	neg	bl
PutPositive:
	call	PutHex				;Put Finetune

	mov	cl,1
	move	edi,0a0000h+191*80+104/8
	movzx	ebx,[FineTunes+ebp]
	shr	ebx,4
	cmp	ebx,8
	jz	PutSpace2
	ja	PutPositive12
	cmp	ebx,0
	jz	ChannelPanPot
	mov	ebx,'-'
	jmp	PutMore2
PutPositive12:
	mov	ebx,'+'
	jmp	PutMore2
PutSpace2:
	mov	ebx,' '
PutMore2:
	call	PutCharacter			;print + or -

	mov	cl,1
	move	edi,0a0000h+191*80+112/8
	movzx	ebx,[FineTunes+ebp]
	shr	ebx,4
	cmp	ebx,8
	ja	PutPositive2
	sub	bl,16
	neg	bl
PutPositive2:
	sub	ebx,8
	call	PutHex				;Put PanPot
	jmp	Volly
ChannelPanPot:
	mov	ebx,'C'
	call	PutCharacter
	inc	edi
	mov	ebx,'h'
	call	PutCharacter

Volly:
	mov	cl,3
	move	edi,0a0000h+208*80+96/8
	movzx	ebx,[Volumes+ebp]
	cmp	VolumeHexDec,0
	jz	PutDec6
	call	PutHex
	jmp	PutHex6
PutDec6:
	call	PutDecimal			;Put Volume
PutHex6:
	call	MouseOn
	jmp	QuitPrintSampleInfo

PrintPattSampleInfo:
	mov	MouseX1,84
	mov	MouseY1,103
	mov	MouseX2,120
	mov	MouseY2,136
	call	mouseoff

	mov	ah,08h
	mov	cl,3
	move	edi,0a0000h+106*80+88/8
	mov	ebx,' '
	call	CheckInstEmpty
	jnc	NoInstBa
	mov	ebx,3
NoInstBa:
	call	putcharacter
	inc	edi
	movzx	ebx,CurrentInstrument
	cmp	Sample0,0
	jz	NoItsNotEvenClose2
	mov	ebx,0
NoItsNotEvenClose2:
	mov	ebp,ebx
	cmp	SampHexDec,0
	jz	Put_Dec2
	call	PutHex
	jmp	Put_Hex2
Put_Dec2:
	call	PutDecimal			;Put Current Inst
Put_Hex2:
	move	edi,0a0000h+123*80+96/8+1
	movzx	ebx,CurrentSample
	and	ebx,0fh
	mov	cl,2
	cmp	SampHexDec,0
	jz	Put__Dec2
	call	PutHex
	jmp	Put__Hex2
Put__Dec2:
	call	PutDecimal			;Put Current Sample
Put__Hex2:
	call	mouseon
	call	mousereset
	call	PrintRelNote

QuitPrintSampleInfo:
	call	MouseOn
	Popad
	Ret
PrintSampleInfo  EndP


BackCol Proc	Near
	Pushad
	mov	dx,3dah
	in	al,dx
	mov	dx,3c0h
	mov	al,31h
	out	dx,al
	mov	al,EditMode
	shl	al,1
	out	dx,al
	Popad
	Ret
BackCol EndP

ButtX1Sav	dd	164
ButtY1Sav	dd	191
ButtX2Sav	dd	176
ButtY2Sav	dd	202
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Move button cords
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:  ButtonHandlerX1 = X1 on screen
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MoveButtonCords Proc	Near
	push	eax
	mov	eax,ButtonhandlerX1
	mov	ButtonX1,eax
	mov	eax,ButtonhandlerY1
	mov	ButtonY1,eax
	mov	eax,ButtonhandlerX2
	mov	ButtonX2,eax
	mov	eax,ButtonhandlerY2
	mov	ButtonY2,eax
	pop	eax
	ret
MoveButtonCords Endp

MoveButtonCords2 Proc	 Near
	push	eax
	mov	eax,ButtonhandlerX1
	mov	ButtonX1,eax
	mov	ButtX1Sav,eax
	mov	eax,ButtonhandlerY1
	mov	ButtonY1,eax
	mov	ButtY1Sav,eax
	mov	eax,ButtonhandlerX2
	mov	ButtonX2,eax
	mov	ButtX2Sav,eax
	mov	eax,ButtonhandlerY2
	mov	ButtonY2,eax
	mov	ButtY2Sav,eax
	pop	eax
	ret
MoveButtonCords2 Endp

ReleaseLastButton Proc	  Near
	Pushad
	push	ButtonX1 ButtonX2 ButtonY1 ButtonY2
	mov	eax,ButtX1Sav
	mov	ButtonX1,eax
	mov	eax,ButtY1Sav
	mov	ButtonY1,eax
	mov	eax,ButtX2Sav
	mov	ButtonX2,eax
	mov	eax,ButtY2Sav
	mov	ButtonY2,eax
	call	ButtonUpDown
	pop	ButtonY2 ButtonY1 ButtonX2 ButtonX1
	Popad
	Ret
ReleaseLastButton EndP

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Fix Button
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ButtonX1_	dd	0
ButtonY1_	dd	0
ButtonX2_	dd	0
ButtonY2_	dd	0
Buttonspecial	db	0		;shows if a button is down
ButtonCheck	db	0		;1=From Mouse 2=From Keyboard
FixButton	Proc	Near
	pushad
	cmp	ButtonCheck,0
	jz	skipbuttondown

	cmp	buttonspecial,1
	jz	skipbuttondown
	mov	buttonspecial,1
	call	movebuttoncords
	mov	eax,ButtonX1
	mov	ButtonX1_,eax
	mov	eax,ButtonY1
	mov	ButtonY1_,eax
	mov	eax,ButtonX2
	mov	ButtonX2_,eax
	mov	eax,ButtonY2
	mov	ButtonY2_,eax

	mov	bl,0
	call	buttonupdown
skipbuttondown:
	popad
	ret
FixButton	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Fix Button 2
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FixButton2	 Proc	 Near
	push	eax
	cmp	buttonspecial,1
	jnz	skipfixbutton

	cmp	mouseB,0
	jz	buttoncancel2

	movzx	ebx,mouseX
	movzx	ecx,mouseY

	cmp	ebx,buttonhandlerx1		;check if it's still on the
	jb	buttoncancel2			;button
	cmp	ebx,buttonhandlerx2
	ja	buttoncancel2
	cmp	ecx,buttonhandlery1
	jb	buttoncancel2
	cmp	ecx,buttonhandlery2
	ja	buttoncancel2
	jmp	skipfixbutton
buttoncancel2:

	mov	eax,ButtonX1_
	mov	ButtonX1,eax
	mov	eax,ButtonY1_
	mov	ButtonY1,eax
	mov	eax,ButtonX2_
	mov	ButtonX2,eax
	mov	eax,ButtonY2_
	mov	ButtonY2,eax
	mov	bl,1
	call	buttonupdown
	mov	buttonspecial,0
skipfixbutton:
	pop	eax
	ret
FixButton2	 Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Button Handler
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:  ButtonHandlerX1 = X1 on screen
;	  ButtonHandlerY1 = Y1 on screen
;	  ButtonHandlerX2 = X2 on screen
;	  ButtonHandlerY2 = Y2 on screen
;
; Return:
;	  eax = Button status	0. Mouse is pulled
;				1. Mouse is waiting
;				2. Mouse is canceled
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ButtonHandlerX1 	dd	0
ButtonHandlerY1 	dd	0
ButtonHandlerX2 	dd	0
ButtonHandlerY2 	dd	0
ButtonHandlerStatus	db	0	;1=a button is down 0=no button is down
ButtonHandlerReturn	dd	0	;the return
ButtonHandler	Proc	Near
	pushad
	cmp	buttonhandlerstatus,2
	jz	buttonpulled
	cmp	buttonhandlerstatus,1
	jz	nobuttondown
	mov	buttonhandlerreturn,1
	call	movebuttoncords
	mov	bl,0
	call	buttonupdown
nobuttondown:
	mov	buttonhandlerstatus,1
	popad
	mov	eax,buttonhandlerreturn
	ret
buttonpulled:
	mov	buttonhandlerstatus,0
	popad
	mov	eax,buttonhandlerreturn
	ret
ButtonHandler	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				Button Handler 2
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls: None
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ButtonHandler2	Proc	Near
	pushad
	cmp	buttonhandlerstatus,0		;staff to the button handler
	jz	quitbutt2

	movzx	eax,mouseB
	cmp	eax,0
	jz	justzero
	mov	LastBeforeUp,eax
justzero:

	cmp	mouseB,0			;is it up or down?
	jnz	quitbutt2

	movzx	ebx,mouseX
	movzx	ecx,mouseY

	cmp	ebx,buttonhandlerx1
	jb	buttoncancel
	cmp	ebx,buttonhandlerx2
	ja	buttoncancel
	cmp	ecx,buttonhandlery1
	jb	buttoncancel
	cmp	ecx,buttonhandlery2
	ja	buttoncancel

	mov	buttonhandlerreturn,0
	mov	buttonhandlerstatus,2
	mov	eax,LastBeforeUp
	mov	mouseB,ax
	jmp	movebuttonup

buttoncancel:
	mov	buttonhandlerstatus,0
	mov	buttonhandlerreturn,2

movebuttonup:
	call	movebuttoncords
	mov	bl,1
	call	buttonupdown

Quitbutt2:
	popad
	ret
ButtonHandler2	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Button Up-Down
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;	 ButtonX1 = Target x1
;	 ButtonY1 = Target y1
;	 ButtonX2 = Target x2
;	 ButtonY2 = Target y2
;	 ButtonC1 = Light color number
;	 ButtonC2 = Dark color number
;	       Bl = (1=Up 0=Down)
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ButtonX1	dd	0
ButtonY1	dd	0
ButtonX2	dd	0
ButtonY2	dd	0
ButtonC1	db	0
ButtonC2	db	0
ButtonXstart	dd	0
ButtonXend	dd	0
LineColor	dd	0
ButtonEdisave	dd	0
ButtonStartSave dd	0
Buttonplane	dd	0
Buttonsave	dd	0
ButtonUpDown	Proc	Near
	pushad
	xor	bl,1

	mov	buttonC1,14
	mov	buttonC2,12
	cmp	bl,1
	jz	noflipphere
	mov	al,buttonC1
	xchg	al,buttonC2
	mov	buttonC1,al
noflipphere:

	move	edi,0a0000h			;set edi
	mov	eax,buttony1
	mov	ebx,80
	mul	ebx
	mov	ebx,buttonx1
	add	edi,eax

	call	mouseoff

	mov	eax,buttonx1			;fill first line
	mov	buttonxstart,eax
	mov	eax,buttonx2
	mov	buttonxend,eax
	movzx	eax,buttonC1
	mov	linecolor,eax
	call	filllinebutton
	add	edi,80

	;mov	 eax,buttonx1			 ;fill second line
	;mov	 buttonxstart,eax
	;mov	 eax,buttonx2
	;dec	 eax
	;mov	 buttonxend,eax
	;movzx	 eax,buttonC1
	;mov	 linecolor,eax
	;call	 filllinebutton

	;mov	 eax,buttonx2			 ;fill second line a dot
	;mov	 buttonxstart,eax
	;mov	 buttonxend,eax
	;movzx	 eax,buttonC2
	;mov	 linecolor,eax
	;call	 filllinebutton
	;add	 edi,80
						;fill line down
	mov	ecx,buttony2
	sub	ecx,buttony1
	sub	ecx,1
linedownloop:
	push	ecx

	mov	eax,buttonx1			;fill first two dots
	mov	buttonxstart,eax
	;inc	 eax
	mov	buttonxend,eax
	movzx	eax,buttonC1
	mov	linecolor,eax
	call	filllinebutton

	mov	eax,buttonx2			;fill second two dots
	mov	buttonxend,eax
	;dec	 eax
	mov	buttonxstart,eax
	movzx	eax,buttonC2
	mov	linecolor,eax
	call	filllinebutton
	add	edi,80

	pop	ecx
	loop	linedownloop

	;mov	 eax,buttonx1			 ;fill second from end dot
	;mov	 buttonxstart,eax
	;mov	 buttonxend,eax
	;movzx	 eax,buttonC1
	;mov	 linecolor,eax
	;call	 filllinebutton

	;mov	 eax,buttonx1			 ;fill second from end line
	;inc	 eax
	;mov	 buttonxstart,eax
	;mov	 eax,buttonx2
	;mov	 buttonxend,eax
	;movzx	 eax,buttonC2
	;mov	 linecolor,eax
	;call	 filllinebutton
	;add	 edi,80

	mov	eax,buttonx1			;fill end line
	mov	buttonxstart,eax
	mov	eax,buttonx2
	mov	buttonxend,eax
	movzx	eax,buttonC2
	mov	linecolor,eax
	call	filllinebutton

	call	mouseon

	popad
	ret

;	ButtonXstart = X start
;	  ButtonXend = X end
;	   LineColor = line color
;		 edi = filloffset (only y)
FillLineButton:
	pushad
	mov	eax,buttonxstart		;Prepare edi
	shr	eax,5
	shl	eax,2
	add	edi,eax
	mov	buttonedisave,edi

	mov	buttonplane,1

	mov	ecx,3
Filllineloop2:
	push	ecx

	mov	eax,buttonplane 		;choose bitplane
	mov	ebx,eax
	mov	ecx,linecolor
	and	ebx,ecx
	mov	buttonsave,ebx
	shl	eax,8

	mov	al,02h				;Set bitplane (write)
	mov	dx,3c4h
	out	dx,ax

	mov	dx,3ceh 			;Set bitplane (read)
	shr	ah,1
	mov	al,4
	out	dx,ax

	mov	ebp,buttonxend
	sub	ebp,buttonxstart
	inc	ebp
	mov	eax,buttonxstart
	mov	buttonstartsave,eax
	mov	edi,buttonedisave		;restore edi
Filllineloop1:

	mov	ecx,buttonstartsave		;fix the first dword
	and	ecx,31
	mov	eax,0ffffffffh
	shr	eax,cl

	mov	ebx,ebp 			;check if shorter then 32 pix
	add	ebx,ecx
	cmp	ebx,32
	ja	morefillnow

	mov	ecx,32				;fix of on the right
	sub	ecx,ebx 			;if just one dword
	mov	ebx,0ffffffffh
	shl	ebx,cl
	and	eax,ebx
	ror	ax,8
	ror	eax,16
	ror	ax,8
	xor	eax,0ffffffffh			;move out a dword to the screen
	and	[edi],eax
	cmp	buttonsave,0
	jz	buttonjump1
	xor	eax,0ffffffffh
	or	[edi],eax
buttonjump1:
	jmp	endfillloop1

morefillnow:
	ror	ax,8
	ror	eax,16
	ror	ax,8
	xor	eax,0ffffffffh			;move out a dword to the screen
	and	[edi],eax
	cmp	buttonsave,0
	jz	buttonjump2
	xor	eax,0ffffffffh
	or	[edi],eax
buttonjump2:

	mov	eax,32				;add some stuff it is
	sub	eax,ecx 			;the when next byte
	sub	ebp,eax
	add	buttonstartsave,eax
	add	edi,4
	jmp	filllineloop1

endfillloop1:

	shl	buttonplane,1
	pop	ecx
	loop	filllineloop2


	popad
	ret
ButtonUpDown	Endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;				 Button Up-Down 2
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Calls:
;	 ButtonX1 = Target x1
;	 ButtonY1 = Target y1
;	 ButtonX2 = Target x2
;	 ButtonY2 = Target y2
;	 ButtonC1 = Light color number
;	 ButtonC2 = Dark color number
;	       Bl = (1=Up 0=Down)
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ButtonX1_2		dd	0
ButtonY1_2		dd	0
ButtonX2_2		dd	0
ButtonY2_2		dd	0
ButtonC1_2		db	0
ButtonC2_2		db	0
ButtonXstart_2		dd	0
ButtonXend_2		dd	0
LineColor_2		dd	0
ButtonEdisave_2 	dd	0
ButtonStartSave_2	dd	0
Buttonplane_2		dd	0
Buttonsave_2		dd	0
ButtonUpDown2	 Proc	 Near
	pushad
	xor	bl,1

	mov	buttonC1_2,3
	mov	buttonC2_2,4
	cmp	bl,1
	jz	noflipphere_2
	mov	al,buttonC1_2
	xchg	al,buttonC2_2
	mov	buttonC1_2,al
noflipphere_2:

	move	edi,0a0000h			;set edi
	mov	eax,buttony1_2
	mov	ebx,80
	mul	ebx
	mov	ebx,buttonx1_2
	add	edi,eax

	call	mouseoff

	mov	eax,buttonx1_2			  ;fill first line
	mov	buttonxstart_2,eax
	mov	eax,buttonx2_2
	mov	buttonxend_2,eax
	movzx	eax,buttonC1_2
	mov	linecolor_2,eax
	call	filllinebutton_2
	add	edi,80

	mov	eax,buttonx1_2			  ;fill second line
	mov	buttonxstart_2,eax
	mov	eax,buttonx2_2
	dec	eax
	mov	buttonxend_2,eax
	movzx	eax,buttonC1_2
	mov	linecolor_2,eax
	call	filllinebutton_2

	mov	eax,buttonx2_2			  ;fill second line a dot
	mov	buttonxstart_2,eax
	mov	buttonxend_2,eax
	movzx	eax,buttonC2_2
	mov	linecolor_2,eax
	call	filllinebutton_2
	add	edi,80
						;fill line down
	mov	ecx,buttony2_2
	sub	ecx,buttony1_2
	sub	ecx,3
linedownloop_2:
	push	ecx

	mov	eax,buttonx1_2			  ;fill first two dots
	mov	buttonxstart_2,eax
	inc	eax
	mov	buttonxend_2,eax
	movzx	eax,buttonC1_2
	mov	linecolor_2,eax
	call	filllinebutton_2

	mov	eax,buttonx2_2			  ;fill second two dots
	mov	buttonxend_2,eax
	dec	eax
	mov	buttonxstart_2,eax
	movzx	eax,buttonC2_2
	mov	linecolor_2,eax
	call	filllinebutton_2
	add	edi,80

	pop	ecx
	loop	linedownloop_2

	mov	eax,buttonx1_2			  ;fill second from end dot
	mov	buttonxstart_2,eax
	mov	buttonxend_2,eax
	movzx	eax,buttonC1_2
	mov	linecolor_2,eax
	call	filllinebutton_2

	mov	eax,buttonx1_2			  ;fill second from end line
	inc	eax
	mov	buttonxstart_2,eax
	mov	eax,buttonx2_2
	mov	buttonxend_2,eax
	movzx	eax,buttonC2_2
	mov	linecolor_2,eax
	call	filllinebutton_2
	add	edi,80

	mov	eax,buttonx1_2			  ;fill end line
	mov	buttonxstart_2,eax
	mov	eax,buttonx2_2
	mov	buttonxend_2,eax
	movzx	eax,buttonC2_2
	mov	linecolor_2,eax
	call	filllinebutton_2

	call	mouseon

	popad
	ret

;	ButtonXstart = X start
;	  ButtonXend = X end
;	   LineColor = line color
;		 edi = filloffset (only y)
FillLineButton_2:
	pushad
	mov	eax,buttonxstart_2		 ;Prepare edi
	shr	eax,5
	shl	eax,2
	add	edi,eax
	mov	buttonedisave_2,edi

	mov	buttonplane_2,1

	mov	ecx,3
Filllineloop2_2:
	push	ecx

	mov	eax,buttonplane_2		  ;choose bitplane
	mov	ebx,eax
	mov	ecx,linecolor_2
	and	ebx,ecx
	mov	buttonsave_2,ebx
	shl	eax,8

	mov	al,02h				;Set bitplane (write)
	mov	dx,3c4h
	out	dx,ax

	mov	dx,3ceh 			;Set bitplane (read)
	shr	ah,1
	mov	al,4
	out	dx,ax

	mov	ebp,buttonxend_2
	sub	ebp,buttonxstart_2
	inc	ebp
	mov	eax,buttonxstart_2
	mov	buttonstartsave_2,eax
	mov	edi,buttonedisave_2		  ;restore edi
Filllineloop1_2:

	mov	ecx,buttonstartsave_2		  ;fix the first dword
	and	ecx,31
	mov	eax,0ffffffffh
	shr	eax,cl

	mov	ebx,ebp 			;check if shorter then 32 pix
	add	ebx,ecx
	cmp	ebx,32
	ja	morefillnow_2

	mov	ecx,32				;fix of on the right
	sub	ecx,ebx 			;if just one dword
	mov	ebx,0ffffffffh
	shl	ebx,cl
	and	eax,ebx
	ror	ax,8
	ror	eax,16
	ror	ax,8
	xor	eax,0ffffffffh			;move out a dword to the screen
	and	[edi],eax
	cmp	buttonsave_2,0
	jz	buttonjump1_2
	xor	eax,0ffffffffh
	or	[edi],eax
buttonjump1_2:
	jmp	endfillloop1_2

morefillnow_2:
	ror	ax,8
	ror	eax,16
	ror	ax,8
	xor	eax,0ffffffffh			;move out a dword to the screen
	and	[edi],eax
	cmp	buttonsave_2,0
	jz	buttonjump2_2
	xor	eax,0ffffffffh
	or	[edi],eax
buttonjump2_2:

	mov	eax,32				;add some stuff it is
	sub	eax,ecx 			;the when next byte
	sub	ebp,eax
	add	buttonstartsave_2,eax
	add	edi,4
	jmp	filllineloop1_2

endfillloop1_2:

	shl	buttonplane_2,1
	pop	ecx
	loop	filllineloop2_2
	popad
	ret
ButtonUpDown2	Endp

WaitKey:
	push	ax
	pushfd
WaitKey2:
	in	al,60h
;	cmp	al,1ch
;	jz	Wkey
	cmp	al,57
	jnz	WaitKey2
Wkey:
	in	al,60h
	cmp	al,57
	jz	WKey
	popfd
	pop	ax
	ret

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

OnlyPut 	db	0	;0=unpack+put 1=just put
FixS		dd	0	;size in x (/8)   (si)
TheXsizeT	dd	0	;size in x (/8)   (di)
pcxx2		dd	0
pcxy2		dd	0
ShowThePcx_Mem	Proc	Near
	pushad
	push	eax
	lea	esi,pcxx
	lea	edi,copysavebuff
	mov	ecx,19
	rep	movsd

	mov	eax,pcxs_x2
	sub	eax,pcxs_x1
	inc	eax
	shr	eax,3
;	add	eax,fixproblem
	mov	thexsizeT,eax

	pop	esi
						;save sourcer
	movzx	eax,word ptr [esi+4]
	mov	pcxs_x1,eax
	movzx	eax,word ptr [esi+6]
	mov	pcxs_y1,eax
	movzx	eax,word ptr [esi+8]
	mov	pcxs_x2,eax
	movzx	eax,word ptr [esi+10]
	mov	pcxs_y2,eax


	cmp	onlyput,1
	jz	skipunpacken
						;Un³ack the picture :)
	mov	edi,GUS_TempBuffPtr		   ³
	mov	eax,pcxplanes
	mov	ebx,pcxs_x2
	shr	ebx,2
	mul	ebx
	movzx	ebx,word ptr [esi+10]
	mul	ebx
	movzx	ebp,word ptr [esi+8]
	shr	ebp,1
	add	ebp,eax
	add	ebp,edi
	add	esi,128
PcxUnpack_GG:
	lodsb
	bt	ax,7
	jnc	NotPacked_GG
	bt	ax,6
	jc	Packed_GG
NotPacked_GG:
	stosb
	cmp	edi,ebp
	jz	endpack_GG
	jmp	Pcxunpack_GG
Packed_GG:
	and	al,63
	movzx	ecx,al
	lodsb
packaloop_GG:
	stosb
	cmp	edi,ebp
	jz	endpack_GG
	loop	packaloop_GG
	jmp	PcxUnpack_GG
endpack_GG:

skipunpacken:

	mov	eax,pcxy2			;Save pcxy2
	mov	ebx,theXsizeT
	mul	ebx
	shl	eax,2
	mov	pcxysave,eax

	mov	eax,pcxs_x2			;Prepare ecx
	mov	ebx,pcxx2
	mov	ecx,ebx
	shr	ecx,3
	add	ebx,eax
	shr	ebx,3
	sub	ebx,ecx
	dec	ebx
	mov	pcxecx,ebx

	cmp	ebx,0				;Prepare single byte
	jge	noonlyoneGG
	mov	eax,pcxs_x2
	mov	ebx,pcxx2
	mov	ecx,ebx
	add	ecx,eax
	mov	eax,ebx
	shr	ebx,3
	shl	ebx,3
	sub	eax,ebx
	mov	ebx,ecx
	shr	ebx,3
	shl	ebx,3
	sub	ecx,ebx
	sub	ecx,eax
	inc	ecx

	mov	bx,7
	sub	bx,ax
	mov	ax,bx
	xor	bx,bx

pcxmakebitsGG:					  ;Make single xor byte
	bts	bx,ax
	dec	ax
	loop	pcxmakebitsGG
	xor	bl,0ffh
	mov	pcxbittar,bl
noonlyoneGG:

	mov	eax,pcxx2		      ;Prepare the shifts
	mov	ebx,eax
	shr	ebx,3
	shl	ebx,3
	sub	eax,ebx
	mov	ebx,eax
	add	eax,32
	add	ebx,8
	mov	byte ptr [ror1GG+2],al
	mov	byte ptr [ror2GG+2],al
	mov	byte ptr [ror3GG+2],al
	mov	byte ptr [rol1GG+2],bl

	mov	eax,pcxy2			 ;Prepare edi
	mov	ebx,theXsizeT
	mul	ebx
	shl	eax,2
	mov	ebx,pcxx2
	shr	ebx,3
	add	eax,ebx
	mov	ebx,pcxbuffer
	add	eax,ebx
	mov	pcxedisave,eax

	mov	eax,pcxx2		      ;Prepare startdots
	mov	ebx,eax
	shr	eax,3
	mov	ecx,pcxbuffer
	add	ecx,eax
	mov	startedi,ecx
	shl	eax,3
	sub	ebx,eax
	mov	al,[ebx+pcxtable1]
	mov	pcxstartand,al

	mov	eax,pcxs_x2			;Prepare enddots
	sub	eax,pcxs_x1
	add	eax,pcxx2
	mov	ebx,eax
	shr	eax,3
	mov	ecx,pcxbuffer
	add	ecx,eax
	mov	endedi,ecx
	shl	eax,3
	sub	ebx,eax
	mov	al,[ebx+pcxtable2]
	mov	pcxendand,al


	lea	esi,GUS_TempBuffPtr

	mov	ecx,pcxs_y2			;Main row loop
	inc	ecx
PcxMoveMainLoopGG:
	push	ecx


	xor	ebp,ebp 			;Main plane loop
	mov	ecx,pcxplanes
PcxMovePlanesGG:
	push	ecx


	mov	edi,pcxedisave			;Set edi

	cmp	pcxecx,0			;Check if one byte
	jl	PutOneByteGG

	mov	ebx,startedi			;Clear edistart
	add	ebx,pcxysave
	mov	al,pcxstartand
	and	[ebx],al

	mov	ebx,endedi			;Clear ediend
	add	ebx,pcxysave
	mov	al,pcxendand
	and	[ebx],al

	xor	eax,eax 			;Prepare picture move loop
	lodsw
	ror	ax,8
ror1GG: ror	eax,99
	mov	bl,pcxstartand
	xor	bl,0ffh
	and	ah,bl
	or	[edi],ah
	inc	edi
	mov	ecx,pcxecx
	cmp	ecx,0
	jz	PcxMoreJumpGG

PcxMoveScreenLoopGG:				  ;Picture move loop
rol1GG: rol	eax,99
	lodsb
ror2GG: ror	eax,99
	mov	[edi],ah
	inc	edi
	loop	PcxMoveScreenLoopGG
PcxMoreJumpGG:

	mov	bl,pcxendand			;Or the last byte
	xor	bl,0ffh
	and	al,bl
	or	[edi],al

AfterAByteGG:
	inc	ebp				;Loops the planes
	add	esi,fixs ;problem
	mov	edi,theXsizeT
	add	pcxedisave,edi
	pop	ecx
	loop	PcxMovePlanesGG

	mov	edi,theXsizeT
	add	PcxYsave,edi			;Loops the row
	pop	ecx
	loop	PcxMoveMainLoopGG

	mov	fixs,0

	lea	edi,pcxx
	lea	esi,copysavebuff
	mov	ecx,19
	rep	movsd
	popad
	ret
PutOneByteGG:					  ;Ands one byte
	mov	bl,pcxbittar
	and	[edi],bl
	xor	bl,0ffh

	lodsw					;Ors one byte
	ror	ax,8
ror3GG: ror	eax,99
	and	ah,bl
	or	[edi],ah
	jmp	AfterAByteGG
ShowThePcx_Mem	EndP

ValidKeys	db	11,2,3,4,5,6,7,8,9,10,30,48,46,32,18,33
ValidKeys2	db	11,2,3,4,5,6,7,0,0,0,0,0,0,0,0,0
Sample0 	db	0
KeyBoardNote	dd	0
Octave		db	3	;Octave (0-9)
EditMode	db	0	;1 if EditMode is on
CursorChannel	db	0	;The channels the cursor is on
ScanCodes	db	44,31,45,32,46,47,34,48,35,49,36,50	;C-0 - B-0
		db	16, 3,17, 4,18,19, 6,20, 7,21, 8,22	;C-1 - B-1
		db	23,10,24,11,25,26,13,27 		;C-2 - G-2
		db	51,38,52,39,53				;C-1 - E-1
KeyBoard:
	mov	eax,KeyBoardPress
	cmp	EditMode,0
	jz	NoEdit
	cmp	ArrowPointer,0
	jnz	DontPlaySample
NoEdit:
	mov	ecx,46				;Scan in special table
	xor	esi,esi
@@ScanTBL:
	cmp	byte ptr [PlayKeysTBL+esi],al
	jnz	@@Skutt
	cmp	dword ptr [PlayKeysTBL+esi+1],0
	jz	@@Skutt
	jmp	dword ptr [PlayKeysTBL+esi+1]
@@Skutt:
	add	esi,6
	loop	@@ScanTBL

	xor	edx,edx
	mov	ecx,37
GetKey:
	cmp	al,[ScanCodes+edx]
	jz	GotTheKey
	inc	edx
	loop	GetKey
	mov	KeyBoardNote,0
	jmp	Dummy

GotTheKey:
	cmp	edx,32
	jb	NoSpecialKey
	sub	edx,20
NoSpecialKey:
	cmp	KeyBoardMode,0
	jz	NoMIDIStyle
	cmp	EditMode,0
	jz	NotKBD2CKH
	cmp	KeyBoardMode,2
	jz	NoMIDIStyle
NotKBD2CKH:
	call	MIDIStyle
	ret
NoMIDIStyle:
	movzx	ebx,Octave
	lea	ebx,[ebx+ebx*2]
	shl	ebx,2
	add	ebx,2
	add	edx,ebx
	cmp	edx,121
	ja	Dummy
MousePlay:
	mov	KeyBoardNote,edx
	mov	OldInfoTextPtr,-1

	movzx	edi,CursorChannel		;Current Channel
	movzx	edi,byte ptr [ChanPos+edi]
	cmp	[Mute+edi],2
	jz	_ret
	cmp	KeyBoardMode,0
	jz	FakePress
	cmp	EditMode,0
	jz	NoFakePress
	cmp	KeyBoardMode,2
	jnz	NoFakePress
FakePress:
	mov	[MIDIChanTable+edi],-1
NoFakePress:
	movzx	ebx,CurrentInstrument		;Current Instrument

	cmp	menu_downscreen,4		;If SampleEditor
	jz	SampleEditorKeyBoardPlay
	cmp	menu_downscreen,5		;If SampleEditor
	jz	SampleEditorKeyBoardPlay

	call	SplitKeyBoard		;EBX=Inst,KeyboardNote
	mov	CurrentInstrument,bl	;New Current Instrument

	mov	edx,KeyBoardNote
	mov	eax,edx
	call	GetSplitCurrSample	;EDX=KBD Note, BL=Inst| Out:EDX=Note,BX=Sample
	call	PlaySample		;EAX=Note (unspl),EDX=Note(spl),EBX=Sample,EDI=Channel
	mov	edx,KeyBoardNote
	cmp	EditMode,0
	jz	Dummy
	mov	edx,KeyBoardNote

DontPlaySample:
	call	CalculateOffset
	mov	dh,CurrentInstrument
	movzx	ebx,ArrowPointer
	cmp	ebx,0
	jz	ArrowOnNote
	inc	esi
	lea	ebp,ValidKeys
	dec	ebx
	cmp	ebx,2
	jb	ArrowOnSampleNr
	sub	ebx,2
	and	ebx,3

	lea	ebp,ValidKeys2
	inc	esi
	movzx	eax,[Cmd+edi]
	shl	eax,1
	add	esi,eax
MustBe:
	cmp	ebx,0
	jz	ArrowOnSampleNr
	lea	ebp,ValidKeys
	cmp	ebx,1
	jz	ArrowOnSampleNr
	sub	ebx,2
	inc	esi
	jmp	MustBe
NoteOff:
	cmp	EditMode,0
	jz	Dummy
	cmp	ArrowPointer,0
	jnz	dummy
	call	CalculateOffset
	movzx	edi,CursorChannel
	mov	[KeyOffTable+edi],0
	mov	dx,1
ArrowOnNote:
	cmp	Sample0,1
	jnz	Galenskap
	mov	dh,0
Galenskap:
	mov	byte ptr [esi],dl
	mov	byte ptr [esi+1],dh
	movzx	dx,RowAdder
	mov	OldRow,-1
	cmp	RecMode,1
	jz	Dummy
	mov	ax,CurrRow
	add	ax,dx
	call	AddXRows
	mov	oldx,-1
	ret

ArrowOnSampleNr:
	xor	eax,eax
	mov	ecx,16
	mov	edx,KeyBoardPress
CheckValidKey:
	cmp	[ebp+eax],dl
	jz	ItsValid
	inc	eax
	loop	CheckValidKey
	jmp	Dummy
ItsValid:
	mov	ah,[esi]
	cmp	ebx,1
	jz	ArrowOnSampleNrLow
	and	ah,0fh
	shl	al,4
	or	ah,al
	mov	[esi],ah
	movzx	dx,RowAdder
	mov	OldRow,-1
	cmp	RecMode,1
	jz	Dummy
	mov	ax,CurrRow
	add	ax,dx
	call	AddXRows
	mov	oldx,-1
	ret
ArrowOnSampleNrLow:
	and	ah,0f0h
	or	ah,al
	mov	[esi],ah
	movzx	dx,RowAdder
	mov	OldRow,-1
	cmp	RecMode,1
	jz	Dummy
	mov	ax,CurrRow
	add	ax,dx
	call	AddXRows
	mov	oldx,-1
	ret


PlaySample0	db	0
SampleEditorKeyBoardPlay:
	cmp	CurrentInstrument,0
	jz	Dummy

	call	GetSplitCurrSample	;EDX=KBD Note, BL=Inst| Out:EDX=Note,BX=Sample

	mov	al,[FineTunes+ebx]
	mov	[FineTunes],al
	mov	ax,[SampleRates+ebx*2]
	mov	[SampleRates],ax
	mov	al,[Relativenote+ebx]
	mov	[Relativenote],al
	mov	al,[Volumes+ebx]
	mov	[Volumes],al
	mov	al,[VoiceControl+ebx]
	mov	[VoiceControl],al
	cmp	PlayForm,1
	jz	PlayAll
	cmp	PlayForm,2
	jz	PlayArea
	cmp	PlayForm,3
	jz	PlayScreen
	cmp	PlayForm,4
	jz	PlayOffset

PlayAll:
	mov	eax,[SampleOffsetStart+ebx*4]
	mov	[SampleOffsetStart],eax
	mov	eax,[LoopStart+ebx*4]
	mov	[LoopStart],eax
	mov	eax,[SampleOffsetEnd+ebx*4]
	mov	[SampleOffsetEnd],eax
	mov	eax,[LoopEnd+ebx*4]
	mov	[LoopEnd],eax
	jmp	dotherest

PlayArea:
	cmp	SampMarkStart,-1
	jz	Dummy
	mov	eax,[SampleOffsetStart+ebx*4]
	add	eax,SampMarkStart
	mov	[SampleOffsetStart],eax
	mov	[LoopStart],eax
	mov	eax,[SampleOffsetStart+ebx*4]
	add	eax,SampMarkEnd
	mov	[SampleOffsetEnd],eax
	mov	[LoopEnd],eax
	jmp	DoTheRest
PlayScreen:
	mov	eax,[SampleOffsetStart+ebx*4]
	add	eax,ViewSampOffset
;	sub	eax,SampMainOffset
	mov	[SampleOffsetStart],eax
	mov	[LoopStart],eax
	add	eax,ViewSampLength
	mov	[SampleOffsetEnd],eax
	mov	[LoopEnd],eax
	jmp	DoTheRest
PlayOffset:
	mov	eax,[SampleOffsetStart+ebx*4]
	add	eax,playpegoff
	mov	[SampleOffsetStart],eax
	mov	[LoopStart],eax
	mov	eax,[SampleOffsetEnd+ebx*4]
	mov	[SampleOffsetEnd],eax
	mov	[LoopEnd],eax

DoTheRest:
	mov	PlaySample0,1
	mov	eax,KeyBoardNote

	call	PlaySample		;EAX=Note (unspl),EDX=Note(spl),EBX=Sample,EDI=Channel
	mov	PlaySample0,0
	mov	[CurrSample+edi*2],bx

	mov	[SampleOffsetStart],0
	mov	[LoopStart],0
	mov	[LoopEnd],0
	mov	[SampleOffsetEnd],0
	mov	[FineTunes],0
	mov	[SampleRates],0
	mov	[RelativeNote],0
	mov	[Volumes],0
	mov	[VoiceControl],0
	mov	oldx,-1
	ret

Dammy:
	call	sara4
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Dummy2:
	sti
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Dummy:
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FasterArrowUp:
	mov	ax,KeyBoardRepeat2
	mov	KeyBoardRepeat,ax
	jmp	ArrowUp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FasterArrowDown:
	mov	ax,KeyBoardRepeat2
	mov	KeyBoardRepeat,ax
	jmp	ArrowDown
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FastestArrowUp:
	mov	ax,KeyBoardRepeat1
	mov	KeyBoardRepeat,ax
	jmp	ArrowUp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FastestArrowDown:
	mov	ax,KeyBoardRepeat1
	mov	KeyBoardRepeat,ax
	jmp	ArrowDown
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ		;Enter
InsPatt1:
	movzx	ecx,Channels
	mov	al,InsertAdd
	mov	InsertAdd,0
	push	ax
InsertPattLoop:
	push	ecx
	mov	eax,ecx
	dec	eax
	call	InsNote3
	pop	ecx
	loop	InsertPattLoop
	pop	ax
	mov	InsertAdd,al
	cmp	InsertAdd,2
	jb	Dummy
	mov	ecx,CurrPattLength
	dec	ecx
	cmp	cx,CurrRow
	jz	_ret
	inc	CurrRow
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ		;BackSpace
InsPatt2:
	cmp	EditMode,0
	jz	Dummy
	movzx	ecx,Channels

	cmp	InsertAdd,0
	jz	InsertPattLoop2
	cmp	InsertAdd,2
	jz	InsertPattLoop2
	cmp	CurrRow,0
	jz	Dummy
InsertPattLoop2:
	push	ecx
	mov	eax,ecx
	dec	eax
	movzx	ecx,CurrRow

	cmp	InsertAdd,1
	jz	NoAdd
	cmp	InsertAdd,3
	jz	NoAdd
	inc	ecx
NoAdd:
	mov	edx,CurrPattLength
	mov	ebx,GUS_TempBuffPtr
	call	Cut_Channel
	add	ebx,512
	call	Cut_Command

	dec	ecx
	mov	ebx,GUS_TempBuffPtr
	call	Paste_Channel
	add	ebx,512
	call	Paste_Command

	call	CheckPatternStart_Edit
	mov	edi,PatternStart	;Clear
	mov	ebx,RowSize
	mul	ebx
	add	edi,eax
	mov	ebx,ChRowSize
	mov	eax,CurrPattLength
	dec	eax
	mul	ebx
	add	edi,eax
	mov	ecx,RowSize
	xor	al,al
	rep	stosb

	pop	ecx
	loop	InsertPattLoop2
	mov	OldRow,-1
	cmp	InsertAdd,0
	jz	Dummy
	cmp	InsertAdd,2
	jz	Dummy
	dec	CurrRow
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
InsCmd1:
	cmp	EditMode,0
	jz	Dummy
	movzx	eax,CursorChannel
	mov	ebx,GUS_TempBuffPtr
	movzx	ecx,CurrRow
	mov	edx,CurrPattLength
	call	Cut_Command

	push	ax
	mov	ax,CurrRow
	inc	ax
	cmp	ax,word ptr CurrPattLength
	pop	ax
	jz	Dummy
	inc	CurrRow
	movzx	ecx,CurrRow
	mov	edx,CurrPattLength
	mov	ebx,GUS_TempBuffPtr
	call	Paste_Command
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
InsCmd2:
	cmp	EditMode,0
	jz	Dummy
	movzx	eax,CursorChannel
	dec	CurrRow
	jge	ContInsCmd2
	mov	CurrRow,0
	jmp	Dummy
ContInsCmd2:
	movzx	ecx,CurrRow
	inc	ecx
	mov	edx,CurrPattLength
	mov	ebx,GUS_TempBuffPtr
	call	Cut_Command

	movzx	ecx,CurrRow
	mov	ebx,GUS_TempBuffPtr
	call	Paste_Command
	call	CheckPatternStart_Edit
	mov	edi,PatternStart	;Clear
	mov	ebx,RowSize
	movzx	eax,CursorChannel
	mul	ebx
	add	edi,eax
	mov	ebx,ChRowSize
	mov	eax,CurrPattLength
	dec	eax
	mul	ebx
	add	edi,eax
	mov	ecx,RowSize
	sub	ecx,2
	xor	al,al
	add	edi,2
	rep	stosb
	ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DeleteBlock:
	cmp	MM_Start,-1
	jz	_ret
	call	StoreUndoBuffer
	mov	PrintBlock,0
	mov	OldRow,-1
	mov	OldInfoTextPtr,-1
	jmp	DelNewBlock
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
C2Mode	db	0
SwitchC2Mode:
	mov	dword ptr [OldPuts+17*4],-1
	mov	dword ptr [OldPuts+8*4],-1
	xor	C2Mode,1
	call	PrintSampleInfo
	ret

AllocateEmptyPattern:
	movzx	eax,DefaultChannels
	movzx	ebx,DefaultCommands
	movzx	ecx,DefaultRows
	call	GetPatternSize2 	;Allocate one pattern
	mov	eax,PatternSize2
	add	eax,12
	mov	ebp,1033		;Allocate Empty Pattern
	mov	ebx,1
	call	MemAlloc
	jc	NotEnoughHiMem
	mov	EmptyPattern,eax
	movzx	ecx,DefaultRows
	dec	ecx
	add	eax,5			;To maybe avoid a bug.
	add	eax,5
	mov	dl,DefaultCommands
	mov	dh,DefaultChannels
	shl	dl,5
	dec	dh
	or	dl,dh
	mov	byte ptr [eax],cl
	mov	byte ptr [eax+1],dl

	movzx	ebx,CurrPatt2
	call	Pattinit
	mov	oldrow,-1
	mov	OldCurrentChannel,-1
	call	FixAllocChannels
	ret

CheckInstEmpty2:
	pushad
	jmp	CheckInstEmpty3
CheckInstEmpty	Proc	Near
	pushad
	movzx	ebp,CurrentInstrument
	shl	ebp,4
CheckInstEmpty3:
	xor	esi,esi
	mov	ecx,16
NxtSmp2:
	mov	eax,[SampleOffsetEnd+ebp*4]
	sub	eax,[SampleOffsetStart+ebp*4]
	jle	NoSmp2
	mov	esi,1
NoSmp2:
	inc	ebp
	loop	NxtSmp2
	rcr	esi,1
	popad
	ret
CheckInstEmpty	EndP


BL_Channel	db	0
BL_Action	dw	0	;BITS: 0=Copy, 1=Clear

BL_Width	dd	0
BL_Rows 	dw	0
BL_Zoom 	dd	0
BL_Start	dd	0
BL_Commands	dd	0

BL_SourceAdd	dd	0
BL_ZoomSourceAdd dd	0
BL_SkipRows	dd	0

CutNewBlock:
	mov	BL_Action,00000011b
	call	FixBlock
	jmp	MM_UnMarkBlock
CopyNewBlock:
	mov	BL_Action,00000001b
	call	FixBlock
	jmp	MM_UnMarkBlock
PasteNewBlock:
	mov	JoinPaste,0
	jmp	NewBlock
JoinPasteNewBlock:
	mov	JoinPaste,1
NewBlock:
	cmp	[AllocTable+1036*8],0
	jz	_ret
	call	CheckPatternStart_Edit
	mov	eax,[AllocTable+1036*8]

	mov	edx,[eax]		;Read Header
	mov	BL_Width,edx
	mov	BL_ZoomSourceAdd,edx
	mov	edx,[eax+4]
	mov	BL_Rows,dx
	mov	edx,[eax+8]
	mov	BL_Zoom,edx
	mov	edx,[eax+12]
	mov	BL_Start,edx
	mov	edx,[eax+16]
	mov	BL_Commands,edx
	add	eax,20
	mov	esi,eax
	mov	al,CursorChannel
	mov	BL_Channel,al
	jmp	BL_Block2

FixBlock:
	cmp	MM_Start,-1
	jz	_ret
	call	BlockSize

	push	ebx
	add	eax,20
	mov	ebp,1036		;Allocate Block
	xor	ebx,ebx
	call	MemAlloc
	jc	NotEnoughHiMem
	pop	ebx
	mov	BL_Rows,bx

	mov	[eax],ecx		;Store Header
	mov	[eax+4],ebx
	movzx	edx,MM_Zoom
	mov	[eax+8],edx
	movzx	edx,MM_Start
	mov	[eax+12],edx
	movzx	edx,Commands
	mov	[eax+16],edx
	add	eax,20
	mov	edi,eax
	mov	bl,MM_ChanStart
	mov	BL_Channel,bl

	call	CheckPatternStart_View
BL_Block:					;COPY/CUT
	mov	esi,PatternStart
	movzx	eax,MM_RowStart
	mov	ebx,ChRowSize
	mul	ebx
	add	esi,eax
	movzx	ebp,BL_Channel
	movzx	ebp,byte ptr [ChanPos+ebp]
	mov	eax,RowSize
	mul	ebp
	add	esi,eax

	movzx	ecx,MM_RowEnd
	sub	cx,MM_RowStart
	inc	cx
	mov	ebp,ecx
	xor	al,al

	mov	bl,BL_Channel
	cmp	bl,MM_ChanStart
	jz	BL_ChS
	cmp	bl,MM_ChanEnd
	jz	BL_ChE
	mov	ecx,RowSize
BL_Loop:
	bt	BL_Action,0
	jnc	BL_NoCopy
	push	ecx esi
	rep	movsb
	pop	esi ecx
BL_NoCopy:
	bt	BL_Action,1
	jnc	BL_NoClear
	push	ecx edi
	mov	edi,esi
	rep	stosb
	pop	edi ecx
BL_NoClear:
	add	esi,ChRowSize
	dec	ebp
	jnz	BL_Loop
	jmp	BL_Cont
BL_ChS:
	mov	bl,MM_ChanStart
	cmp	bl,MM_ChanEnd
	jz	BL_SameChan
	movzx	ebx,MM_Start
	lea	esi,[esi+ebx*2]
	sub	bl,Commands
	dec	bl
	neg	bl
	lea	ecx,[ebx*2]
	jmp	BL_Loop
BL_SameChan:
	movzx	ebx,MM_Start
	lea	esi,[esi+ebx*2]
	mov	bl,MM_End
	sub	bl,MM_Start
	inc	bl
	lea	ecx,[ebx*2]
	jmp	BL_Loop
BL_ChE:
	movzx	ebx,MM_End
	inc	ebx
	lea	ecx,[ebx*2]
	jmp	BL_Loop

BL_Cont:
	inc	BL_Channel
	mov	bl,BL_Channel
	cmp	bl,MM_ChanEnd
	jbe	BL_Block
	ret

BL_Block2:					;PASTE
	mov	BL_SkipRows,0
	mov	edi,PatternStart
	movzx	eax,CurrRow
	mov	ebx,ChRowSize
	mul	ebx
	add	edi,eax
	movzx	ebp,BL_Channel
	movzx	ebp,byte ptr [ChanPos+ebp]
	mov	eax,RowSize
	mul	ebp
	add	edi,eax

	movzx	ebp,BL_Rows			;Get rows to paste
	mov	eax,CurrPattLength
	sub	ax,CurrRow
	cmp	eax,ebp
	jae	BL_NoRowFix
	sub	ebp,eax
	mov	BL_SkipRows,ebp
	mov	ebp,eax
BL_NoRowFix:
	mov	ecx,BL_Start			;Get bytes to paste
	sub	ecx,BL_Commands
	neg	ecx
	lea	ecx,[ecx*2+2]

	sub	BL_Width,ecx
	jge	BL_NoWidthFix
	add	BL_Width,ecx
	mov	ecx,BL_Width
	mov	BL_Width,0
BL_NoWidthFix:
	mov	BL_SourceAdd,ecx

	cmp	BL_Zoom,0
	jnz	BL_PasteZoom
BL_Paste:
	mov	ebx,BL_Start
	lea	ebx,[ebx*2]
	add	ebx,ecx
	cmp	ebx,RowSize
	jbe	BL_NoWidthFix2
	mov	ecx,RowSize
	mov	ebx,BL_Start
	lea	ebx,[ebx*2]
	sub	ecx,ebx
BL_NoWidthFix2:
	mov	eax,BL_Start			;Get paste Offset
	lea	edi,[edi+eax*2]
	mov	BL_Start,0
BL_Loop2:
	cmp	JoinPaste,0
	jz	BL_NoJoinPaste

	push	ecx edi
	dec	edi
BL_ChkNext:
	inc	edi
	cmp	byte ptr [edi],0
	loopz	BL_ChkNext
	pop	edi ecx
	jnz	SkipPaste

BL_NoJoinPaste:
	push	ecx esi edi
	rep	movsb
	pop	edi esi ecx
SkipPaste:
	add	esi,BL_SourceAdd
	add	edi,ChRowSize
	dec	ebp
	jnz	BL_Loop2
	mov	eax,BL_SkipRows
	mov	ebp,BL_SourceAdd
	mul	ebp
	add	esi,eax
	jmp	BL_Cont2

BL_Cont2:
	mov	OldRow,-1
	cmp	BL_Width,0
	jz	BL_CheckJump
	inc	BL_Channel
	mov	bl,BL_Channel
	inc	bl
	cmp	bl,Channels
	jbe	BL_Block2
BL_CheckJump:
	cmp	BlockPasteForward,0
	jz	_ret
	movzx	eax,BL_Rows
	sub	eax,BL_SkipRows
	add	ax,CurrRow
	jmp	AddXRows

BL_PasteZoom:
	mov	eax,BL_ZoomSourceAdd
	mov	BL_SourceAdd,eax
	cmp	BL_Start,0
	jz	BL_Paste
	mov	BL_Start,0

	movzx	eax,ArrowPointer
	inc	eax
	shr	eax,2

	lea	ebx,[eax*2]
	add	ebx,ecx
	cmp	ebx,RowSize
	jbe	BL_NoWidthFix3
	mov	ecx,RowSize
	lea	ebx,[eax*2]
	sub	ecx,ebx
BL_NoWidthFix3:

	cmp	eax,0
	jz	BL_Add2

	lea	edi,[edi+eax*2]
	jmp	BL_Loop2
BL_Add2:
	add	edi,2
	jmp	BL_Loop2

DelNewBlock:				;Delete and Drag notes up
	mov     BL_Action,00000010b
	cli
	call    FixBlock
	sti
	mov	bl,MM_ChanStart
	mov	BL_Channel,bl

@@BL_Block:
	mov	edi,PatternStart
	movzx	eax,MM_RowStart
	mov	ebx,ChRowSize
	mul	ebx
	add	edi,eax
	movzx	ebp,BL_Channel
	movzx	ebp,byte ptr [ChanPos+ebp]
	mov	eax,RowSize
	mul	ebp
	add	edi,eax
	mov	esi,eax

	add	esi,PatternStart
	movzx	eax,MM_RowEnd
	inc	eax
	mov	ebx,ChRowSize
	mul	ebx
	add	esi,eax

	mov	ecx,CurrPattLength
	dec	ecx
	sub	cx,MM_RowEnd
	jecxz	MM_UnMarkBlock
	mov	ebp,ecx
	xor	al,al

	mov	bl,BL_Channel
	cmp	bl,MM_ChanStart
	jz	@@BL_ChS
	cmp	bl,MM_ChanEnd
	jz	@@BL_ChE
	mov	ecx,RowSize
@@BL_Loop:
;	 bt	 BL_Action,0
;	 jnc	 @@BL_NoCopy
	push	ecx esi edi
	rep	movsb
	pop	edi esi ecx
;@@BL_NoCopy:
;	 bt	 BL_Action,1
;	 jnc	 @@BL_NoClear
	push	ecx edi
	mov	edi,esi
	rep	stosb
	pop	edi ecx
;@@BL_NoClear:
	add	esi,ChRowSize
	add	edi,ChRowSize
	dec	ebp
	jnz	@@BL_Loop
	jmp	@@BL_Cont
@@BL_ChS:
	mov	bl,MM_ChanStart
	cmp	bl,MM_ChanEnd
	jz	@@BL_SameChan
	movzx	ebx,MM_Start
	lea	esi,[esi+ebx*2]
	lea	edi,[edi+ebx*2]
	sub	bl,Commands
	dec	bl
	neg	bl
	lea	ecx,[ebx*2]
	jmp	@@BL_Loop
@@BL_SameChan:
	movzx	ebx,MM_Start
	lea	esi,[esi+ebx*2]
	lea	edi,[edi+ebx*2]
	mov	bl,MM_End
	sub	bl,MM_Start
	inc	bl
	lea	ecx,[ebx*2]
	jmp	@@BL_Loop
@@BL_ChE:
	movzx	ebx,MM_End
	inc	ebx
	lea	ecx,[ebx*2]
	jmp	@@BL_Loop

@@BL_Cont:
	inc	BL_Channel
	mov	bl,BL_Channel
	cmp	bl,MM_ChanEnd
	jbe	@@BL_Block
	jmp	MM_UnMarkBlock


InsNewBlock:
	call	CheckPatternStart_Edit
	mov	eax,[AllocTable+1036*8]
	cmp	eax,0
	jz	_ret

	mov	edx,[eax]		;Read Header
	mov	BL_Width,edx
	mov	BL_ZoomSourceAdd,edx
	mov	edx,[eax+4]
	mov	BL_Rows,dx
	mov	edx,[eax+8]
	mov	BL_Zoom,edx
	mov	edx,[eax+12]
	mov	BL_Start,edx
	mov	edx,[eax+16]
	mov	BL_Commands,edx
	mov	al,CursorChannel
	mov	BL_Channel,al
	call	@@BL_Block
	jmp	PasteNewBlock

@@BL_Block:					 ;INSERT
	mov	esi,PatternStart
	mov	eax,CurrPattLength
	sub	ax,CurrRow
	sub	ax,BL_Rows
	jle	_ret
	mov	ebp,eax 			;Rows to move
	dec	ax
	add	ax,CurrRow
	mov	ebx,ChRowSize
	mul	ebx
	add	esi,eax
	movzx	ebx,BL_Channel
	movzx	ebx,byte ptr [ChanPos+ebx]
	mov	eax,RowSize
	mul	ebx
	add	esi,eax
	mov	edi,eax

	add	edi,PatternStart
	mov	eax,CurrPattLength
	dec	eax
	mov	ebx,ChRowSize
	mul	ebx
	add	edi,eax

	mov	ecx,BL_Start			;Get bytes to paste
	sub	ecx,BL_Commands
	neg	ecx
	lea	ecx,[ecx*2+2]
;	mov	ecx,RowSize

	sub	BL_Width,ecx
	jge	@@BL_NoWidthFix
;	add	BL_Width,ecx
;	mov	ecx,BL_Width
	mov	BL_Width,0
@@BL_NoWidthFix:
;	mov	BL_SourceAdd,ecx

	cmp	BL_Zoom,0
	jnz	@@BL_PasteZoom
@@BL_Paste:
	mov	ebx,BL_Start
	lea	ebx,[ebx*2]
	add	ebx,ecx
	cmp	ebx,RowSize
	jbe	@@BL_NoWidthFix2
	mov	ecx,RowSize
	mov	ebx,BL_Start
	lea	ebx,[ebx*2]
	sub	ecx,ebx
@@BL_NoWidthFix2:
	mov	eax,BL_Start			;Get paste Offset
	lea	edi,[edi+eax*2]
	lea	esi,[esi+eax*2]
	mov	BL_Start,0
@@BL_Loop2:
	push	ecx esi edi
	rep	movsb
	pop	edi esi ecx
	sub	esi,ChRowSize
	sub	edi,ChRowSize
	dec	ebp
	jnz	@@BL_Loop2

	mov	OldRow,-1
	cmp	BL_Width,0
	jz	_ret
	inc	BL_Channel
	mov	bl,BL_Channel
	inc	bl
	cmp	bl,Channels
	jbe	@@BL_Block
	ret

@@BL_PasteZoom:
;	mov	eax,BL_ZoomSourceAdd
;	mov	BL_SourceAdd,eax
	cmp	BL_Start,0
	jz	@@BL_Paste
	mov	BL_Start,0

	movzx	eax,ArrowPointer
	inc	eax
	shr	eax,2

	lea	ebx,[eax*2]
	add	ebx,ecx
	cmp	ebx,RowSize
	jbe	@@BL_NoWidthFix3
	mov	ecx,RowSize
	lea	ebx,[eax*2]
	sub	ecx,ebx
@@BL_NoWidthFix3:

	cmp	eax,0
	jz	@@BL_Add2

	lea	edi,[edi+eax*2]
	lea	esi,[esi+eax*2]
	jmp	@@BL_Loop2
@@BL_Add2:
	add	edi,2
	jmp	@@BL_Loop2


;Out: EAX=Size
;     EBX=Rows
;     ECX=Width
BlockSize	Proc
	xor	ecx,ecx
	mov	dl,MM_ChanStart
	cmp	dl,MM_ChanEnd
	jz	BL_OneChannel
	movzx	eax,Commands
	inc	al
	sub	al,MM_Start
	lea	ecx,[eax*2]
	movzx	eax,Commands
	inc	al
BL_NextChan:
	inc	dl
	cmp	dl,MM_ChanEnd
	jz	BL_ChanEnd
	lea	ecx,[ecx+eax*2]
	jmp	BL_NextChan
BL_ChanEnd:
	movzx	eax,MM_End
	inc	eax
	lea	ecx,[ecx+eax*2]
	jmp	BL_GotWidth
BL_OneChannel:
	movzx	eax,MM_End
	sub	al,MM_Start
	inc	al
	lea	ecx,[ecx+eax*2]
BL_GotWidth:
	movzx	eax,MM_RowEnd
	sub	ax,MM_RowStart
	inc	ax
	mov	ebx,eax
	mul	ecx
	ret
BlockSize	EndP

CheckReleaseKeys	Proc	Near
	pushad
	cmp	ebx,89
	jb	NoExtended
	mov	ecx,16
	lea	esi,ExtendedKeys
	xor	eax,eax
CheckExtended:
	lodsb
	inc	esi
	cmp	eax,ebx
	loopnz	CheckExtended
	jnz	QuitRelCheck
	movzx	ebx,byte ptr [esi-1]
NoExtended:
	xor	edx,edx
	mov	ecx,37
GetKey2:
	cmp	bl,[ScanCodes+edx]
	jz	RightKeys
	inc	edx
	loop	GetKey2
	jmp	QuitRelCheck
RightKeys:
	cmp	KeyBoardMode,0
	jz	NoMIDIStyle2
	cmp	EditMode,0
	jz	MAT
	cmp	KeyBoardMode,2
	jz	NoMIDIStyle2
MAT:
	mov	al,0
	mov	ah,bl
	add	ah,128
	call	GetFreeChannel
	jmp	QuitRelCheck
NoMIDIStyle2:
	call	NormalKBDOff
QuitRelCheck:
	popad
	ret
CheckReleaseKeys	EndP

NormalKBDOff	Proc	Near
	pushad
	movzx	edi,CursorChannel
	mov	[MIDIChanTable+edi],0
	mov	[KeyOffTable+edi],0
	mov	LastKeyPressed,0
	movzx	ebx,byte ptr [CurrInst+edi]
	GetOffset ebx,eax,ENV_Flags
	bt	word ptr [eax],2			;Check Envelope ON
	jc	QuitKBDOff
	cmp	SenseKeyOff,0
	jz	QuitKBDOff
	mov	ecx,edi
	inc	ecx
	call	StopOneVoice
QuitKBDOff:
	popad
	ret
NormalKBDOff	EndP

SetReset:
	push	ax dx
	mov	dx,3ceh 		;Enable Set/Reset
	mov	al,01h
	out	dx,al

	mov	dx,3cfh
	mov	al,bl
	out	dx,al

	mov	dx,3ceh 		;Set/Reset
	mov	al,00h
	out	dx,al

	mov	dx,3cfh
	mov	al,00h
	out	dx,al
	pop	dx ax
	ret

;IF PMODEWVERSION	;\\
;SetMouseShape	Proc	near
;	pushad
;	push	es
;	mov	es,_seldata
;	mov	ax,9		;Change Shape
;	xor	bx,bx		;Column of hotspot
;	xor	cx,cx		;Row of hotspot
;	lea	edx,Cursor1a	;Offset to Buffer
;	int	33h
;	pop	es
;	popad
;	ret
;SetMouseShape	EndP
;ENDIF			;//

;IF DOS32VERSION		;\\
SetMouseShape	Proc	near
	pushad
	lea	esi,Cursor1a	;Offset to Buffer
	mov	ecx,64		;Bytes in Buffer
	call	DOSPrepare

	mov	ax,9		;Change Shape
	xor	bx,bx		;Column of hotspot
	xor	cx,cx		;Row of hotspot
	xor	dx,dx		;Offset relative 0
	push	33h
	call	DOSInterrupt
	popad
	ret
SetMouseShape	EndP
;ENDIF			;//



IF DOS32VERSION		;\\
;------------------------------------
;Emulate DOS Interrupt using a buffer
;to pass info to int routine.
;
;Calls:
;esi=Buffer to use in DOS Interrupt
;ecx=Bytes in buffer
;------------------------------------
DOSPrepare	Proc	Near
	pushad
	push	esi ecx
	mov	ax,0ee02h	;Get real mode info
	int	31h
	mov	Real_DS,ax
	mov	Real_ES,ax
	pop	ecx esi

	and	eax,0ffffh
	shl	eax,4
	sub	eax,ebx
	mov	edi,eax
	rep	movsb
	popad
	ret
DOSPrepare	EndP

;------------------------------------------------------------
; Procedure to call a DOS interrupt.
;
; Expects the intrrupt number pushed on the stack.
;
;  e.g	  push	10h
;	  call	DOSinterrupt
;	  jc   error
; Real mode ES and DS registers are passed via varibles Real_ES and Real_DS.
;
;
; As explained in the DOS32 documentaion, DOS32 initally handles all interrupts
; such that calling a protected mode interrupt will automatically call
; the same interrupt number in real mode.  However, using this method there
; is no way to specify the values of the real mode SEGMENT registers.
; Some of the VESA calls require ES:DI to point to buffers and so
; we need to use INT31h AX=300h service to call a real mode interrupt.
; The procedure below does exactly that...
;
;------------------------------------------------------------
DOSInterrupt	PROC
	push	dword ptr 0		;ignore  SS, SP
	lea	esp,[esp-8]		;ignore  CS, IP ,FS, GS
	push	[DOS_segs]		;push DS and ES
	pushfw
	pushad
	mov	edi,esp
	mov	ax,0300h
	xor	cx,cx
	movzx	ebx,Byte Ptr [esp+36h]	;Get int number from stack param
	int	31h			;Emulate Real Mode Interrupt
	popad
	popfw
	pop	[DOS_segs]		;get DS and ES
	lea	esp,[esp+12]		;Ignore SS,SP,CS,IP,FS,GS
	sti
	ret	4			;return ingnoring parameter
DOSInterrupt	ENDP
ENDIF			;//


;------------------------------------
;Emulate DOS Interrupt using a buffer
;to pass info to int routine.
;
;Calls:
;esi=Buffer to use in DOS Interrupt
;ecx=Bytes in buffer
;------------------------------------
IF PMODEWVERSION	;\\
_DOSSelector	dd	0
DOSPrepare	Proc	Near
	pushad
	push	esi ecx

	mov	ebx,ecx	;Get # of paragraphs
	shr	ebx,4
	and	ecx,0fh
	jz	@@Skip
	inc	ebx
@@Skip:
	mov	ax,4800h		;Alloc mem
	int	21h
	mov	_DOSSelector,eax
	jc	_DOSErr

	mov	bx,ax			;Selector
	mov	ax,06h			;Get Linear address
	int	31h
	shl	ecx,16
	mov	cx,dx
	mov	eax,ecx			;Lin Add

	shr	eax,4			;Seg
	mov	Real_DS,ax
	mov	Real_ES,ax
	pop	ecx esi

	and	eax,0ffffh
	shl	eax,4
	mov	edi,eax
	rep	movsb
	popad
	ret
_DOSErr:
	call	sara4
	mov	ah,2
	mov	dl,7
	int	21h
	pop	ecx esi
	popad
	stc
	ret
DOSPrepare	EndP

;------------------------------------------------------------
; Procedure to call a DOS interrupt.
;
; Expects the intrrupt number pushed on the stack.
;
;  e.g	  push	10h
;	  call	DOSinterrupt
;	  jc   error
; Real mode ES and DS registers are passed via varibles Real_ES and Real_DS.
;------------------------------------------------------------
DOSInterrupt	PROC
	push	dword ptr 0		;ignore  SS, SP
	lea	esp,[esp-8]		;ignore  CS, IP ,FS, GS
	push	[DOS_segs]		;push DS and ES
	pushfw
	pushad
	mov	edi,esp
	mov	ax,0300h
	xor	cx,cx
	movzx	ebx,Byte Ptr [esp+36h]	;Get int number from stack param
	int	31h			;Emulate Real Mode Interrupt
	popad
	popfw
	pop	[DOS_segs]		;get DS and ES
	lea	esp,[esp+12]		;Ignore SS,SP,CS,IP,FS,GS

	push	es
	mov	es,_DOSSelector
	mov	ax,4900h		;Disalloc mem
	int	21h
	pop	es

	sti
	ret	4			;return ingnoring parameter
DOSInterrupt	ENDP


ENDIF			;//




IF DOS32VERSION		;\\
ends
ENDIF			;//

;IF PMODEWVERSION	;\\
;_TEXT	ends
;ENDIF			;//
ends

end

;/ABS\08735081500376108759087590875908759087590875905821
