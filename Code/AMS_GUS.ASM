;/ACS\=p



;/ABS\03622010310406700006000060000600006045310440001866
GF1BUGFIX       equ     4
MIDI_TX_IRQ     equ     01h
MIDI_RX_IRQ     equ     02h

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ GUS Stuff ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Align 4
The_Ultrasound_port_Addresses   Label Dword
GUS_Voice               dw  102h        ;GF1 Synthesizer
GUS_Command             dw  103h
GUS_Data_Low            dw  104h
GUS_Data_High           dw  105h
GUS_IRQ_status          dw  006h
GUS_DRAM                dw  107h
GUS_TIMER_Ctrl          dw  008h
GUS_TIMER_Data          dw  009h
MIDI_Control            dw  100h        ;MIDI Interface
MIDI_Data               dw  101h
Mix_Control             dw  000h        ;BOARD CONTROL ONLY
IRQDMA_Ctrl             dw  00Bh
Revision                dw  506h
Ultrasound_ports_ends   Label Dword
PanPosition             db      8 dup(40h,0b0h,0b0h,40h)
PanPosition_Orig        db      8 dup(40h,0b0h,0b0h,40h)
PC_GUSTimer             db      0               ;0=PC timer, 1=GUS timer


SkipClickRemoval        db      0

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Tables ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Gus_Voltable    dw      01500h,07ff0h,08ff0h,09800h,09ff0h,0a400h,0a800h,0ac00h
                dw      0aff0h,0b200h,0b400h,0b600h,0b800h,0ba00h,0bc00h,0be00h
                dw      0bff0h,0c100h,0c200h,0c300h,0c400h,0c500h,0c600h,0c700h
                dw      0c800h,0c900h,0ca00h,0cb00h,0cc00h,0cd00h,0ce00h,0cf00h
                dw      0cff0h,0d080h,0d100h,0d180h,0d200h,0d280h,0d300h,0d380h
                dw      0d400h,0d480h,0d500h,0d580h,0d600h,0d680h,0d700h,0d780h
                dw      0d800h,0d880h,0d900h,0d980h,0da00h,0da80h,0db00h,0db80h
                dw      0dc00h,0dc80h,0dd00h,0dd80h,0de00h,0de80h,0df00h,0df80h
                dw      0dff0h,0e040h,0e080h,0e0c0h,0e100h,0e140h,0e180h,0e1c0h
                dw      0e200h,0e240h,0e280h,0e2c0h,0e300h,0e340h,0e380h,0e3c0h
                dw      0e400h,0e440h,0e480h,0e4c0h,0e500h,0e540h,0e580h,0e5c0h
                dw      0e600h,0e640h,0e680h,0e6c0h,0e700h,0e740h,0e780h,0e7c0h
                dw      0e800h,0e840h,0e880h,0e8c0h,0e900h,0e940h,0e980h,0e9c0h
                dw      0ea00h,0ea40h,0ea80h,0eac0h,0eb00h,0eb40h,0eb80h,0ebc0h
                dw      0ec00h,0ec40h,0ec80h,0ecc0h,0ed00h,0ed40h,0ed80h,0edc0h
                dw      0ee00h,0ee40h,0ee80h,0eec0h,0ef00h,0ef40h,0ef80h,0efc0h

;       0x1500, ;4e20
;       0x9300,0xA900,0xB400,0xBC00,0xC180,0xC580,0xC980,0xCD80,
;       0xCF40,0xD240,0xD440,0xD640,0xD840,0xDA40,0xDC40,0xDE40,
;       0xDEF0,0xDFA0,0xE1A0,0xE2A0,0xE3A0,0xE4A0,0xE5A0,0xE6A0,
;       0xE7A0,0xE8A0,0xE9A0,0xEAA0,0xEBA0,0xECA0,0xEDA0,0xEEA0,
;       0xEEF0,0xEFE0,0xEF60,0xF1E0,0xF160,0xF1E0,0xF260,0xF2E0,
;       0xF360,0xF3E0,0xF460,0xF4E0,0xF560,0xF5E0,0xF660,0xF6E0,
;       0xF760,0xF7E0,0xF860,0xF8E0,0xF960,0xF9E0,0xFA60,0xFAF0,
;       0xFB70,0xFBF0,0xFC70,0xFCF0,0xFD70,0xFD90,0xFDB0,0xFDD0

GUS_Voices      dw      44100,41160,38587,36317,34300,32494,30870,29400,28063
                dw      26843,25725,24696,23746,22866,22050,21289,20580,19916,19293


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Macros ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


OutB    MACRO   port, value
        mov     dx,port         ;; Write a byte to port 'port'
        mov     al,value
        out     dx,al
ENDM

Break   MACRO
        int     3
        cli
ENDM


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Procedures ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

EnableRampIRQ   db      0       ;20h = Enable
;Ramp Volume from bx to bp
Ramp    Proc    Near
        mov     dx,GUS_Command
        mov     al,0dh
        out     dx,al
        add     dx,2
        mov     al,2           ;Stop Ramping
        out     dx,al

        mov     ah,0
        cmp     bx,bp
        jz      NotGus
        jb      DontChangeDirection
        mov     ah,01000000b
        xchg    bx,bp
DontChangeDirection:

        mov     dx,GUS_Command
        mov     al,07h                  ;VolRampStart
        out     dx,al
        xchg    ax,bx
        inc     dx
        out     dx,ax
        dec     dx

        mov     al,08h                  ;VolRampEnd
        out     dx,al
        mov     ax,bp
        inc     dx
        out     dx,ax
        dec     dx

        mov     al,0dh
        out     dx,al
        mov     al,bh
        add     dx,2
        or      al,EnableRampIRQ
        out     dx,al
NotGus:
        ret
Ramp    EndP

irq_stub_buf2   db      21 dup(?)
irq_stub_buf3   db      21 dup(?)
Old_PM_Vec2     df      0
Old_PM_Vec3     df      0
Old_RM_Vec2     dd      0
Old_RM_Vec3     dd      0
MixerSave       db      0

GUS_InitSoundCard       Proc    Near
        Pushad
        pushf
        mov     StackSave,esp

        call    Ultra16_GetVolumes

        mov     dx,SoundCard_BasePort
        in      al,dx
        mov     MixerSave,al

        mov     ax,00001011b                    ;Turn Off
        call    GUS_Mixer

        call    GUS_Search                      ;See if there's an ultrasound

IF TRANVERSION          ;\\
        mov     bl,SoundCard_IRQ                ;Set New IRQ Vector  (PM)
        mov     edx,offset GUS_IRQ
        call    _setirqvect

        mov     bl,SoundCard_IRQ                ;Set New IRQ Vector  (RM)
        mov     edx,offset GUS_IRQ
        mov     edi,offset irq_stub_buf2        ;set real mode IRQ callback
        call    _rmpmirqset
        mov     Old_RM_Vec2,eax                 ;store old real mode IRQ vector
ENDIF                   ;//


IF DOS32VERSION OR PMODEWVERSION        ;\\
        mov     bl,SoundCard_IRQ                ;Get old IRQ Vector  (PM)
        call    _getirqvect
        mov     dword ptr Old_PM_Vec2,edx
        mov     word ptr Old_PM_Vec2+4,cx

        mov     bl,SoundCard_IRQ                ;Set New IRQ Vector  (PM)
        lea     edx,GUS_IRQ
        mov     cx,cs
        call    _setirqvect
ENDIF                   ;//


IF TRANVERSION
       mov     bl,SoundCard_MIDIIRQ    ;Set New MIDI IRQ Vector  (PM)
       mov     edx,offset GUS_IRQ
       call    _setirqvect

       mov     bl,SoundCard_MIDIIRQ    ;Set New MIDI IRQ Vector  (RM)
       mov     edx,offset GUS_IRQ
       mov     edi,offset irq_stub_buf3;set real mode IRQ callback
       call    _rmpmirqset
       mov     Old_RM_Vec3,eax         ;store old real mode IRQ vector
ELSE
       mov     bl,SoundCard_MIDIIRQ            ;Get old MIDI IRQ Vector  (PM)
       call    _getirqvect
       mov     dword ptr Old_PM_Vec3,edx
       mov     word ptr Old_PM_Vec3+4,cx

       mov     bl,SoundCard_MIDIIRQ            ;Set New MIDI IRQ Vector  (PM)
       lea     edx,GUS_IRQ
       mov     cx,cs
       call    _setirqvect
ENDIF

;*
	mov     bl,SoundCard_IRQ        ;Enable IRQ
	xor     al,al
	call    _setirqmask
;*

        call    GUS_Init

        mov     eax,GUS_DramSize
        sub     eax,32                          ;1:st byte fix!!!!
        sub     eax,GUS_RollOverDataSize
        mov     GUS_DramFree,eax
        mov     [GUS_FreeTable+4],eax
        mov     eax,GUS_RollOverDataSize
        add     eax,32
        mov     [GUS_FreeTable],eax             ;1:st byte fix!!!!

        mov     TimerRate,11652                 ;102.4 Hz

        mov     ax,00001001b                    ;Turn On
        call    GUS_Mixer
        popf
        Popad
        Ret
GUS_InitSoundCard       EndP

StartGUSTimer   Proc    Near
        pushad
        cli
        mov     al,045h                         ;Enable Timer 1 IRQ
        mov     cl,00000100b
        call    GUS_B

        mov     al,046h                         ;Init Timer Count
        mov     cl,134
        call    GUS_B

        mov     dx,GUS_TIMER_Data               ;Start Timer
        mov     al,00000001b
        out     dx,al

        mov     al,TuneStoppedSave
        mov     TuneStopped,al

        sti
        popad
        ret
StartGUSTimer   EndP

StopGUSTimer    Proc    Near
        pushad
        cli
        mov     al,045h                         ;Disable IRQ
        mov     cl,00000000b
        call    GUS_B

        mov     al,TuneStopped
        mov     TuneStoppedSave,al
        mov     TuneStopped,1

        sti
        popad
        ret
StopGUSTimer    EndP



GUS_DeInitSoundCard     Proc    Near
        mov     ax,00001011b                    ;Turn off Speaker
        call    GUS_Mixer

        mov     ah,SoundCard_DMA1               ;Shut Down DMA
        call    DMA_shutdown

        mov     ah,SoundCard_DMA2               ;Shut Down DMA
        call    DMA_shutdown

        call    Ultrasound_Init
        mov     ecx,100
@@LL:   call    GUS_Delay
        loop    @@LL

IF TRANVERSION          ;\\
        mov     bl,SoundCard_IRQ                ;Set Old IRQ Vector
        mov     eax,Old_RM_Vec2                 ;Restore old real mode IRQ vector
        call    _rmpmirqfree

        mov     bl,SoundCard_MIDIIRQ            ;Set Old IRQ Vector
        mov     eax,Old_RM_Vec3                 ;Restore old real mode IRQ vector
        call    _rmpmirqfree
ENDIF                   ;//

IF DOS32VERSION OR PMODEWVERSION                ;\\
        mov     bl,SoundCard_IRQ                ;Set old IRQ Vector  (PM)
        mov     edx,dword ptr Old_PM_Vec2
        mov     cx,word ptr Old_PM_Vec2+4
        call    _setirqvect

        mov     bl,SoundCard_MIDIIRQ            ;Set old MIDI Vector (PM)
        mov     edx,dword ptr Old_PM_Vec3
        mov     cx,word ptr Old_PM_Vec3+4
        call    _setirqvect
ENDIF                   ;//

        cmp     SoundCard,5
        jnz     @@NoCodec
        call    Ultra16DeInit                   ;Deinit Codec
@@NoCodec:

        call    Ultra16_SetVolumes

        mov     dx,SoundCard_BasePort           ;Set to initial values
        mov     al,MixerSave
        or      al,8                            ;Needed???
        out     dx,al

;       mov     ah,SoundCard_DMA1               ;Shut Down DMA
;       call    DMA_shutdown

;       mov     ah,SoundCard_DMA2               ;Shut Down DMA
;       call    DMA_shutdown

        ret
GUS_DeInitSoundCard     EndP

;AX-Mixer control
;bit 0: 0=Enable LineIn
;bit 1: 0=Enable LineOut
;bit 2: 1=Enable Mic
;bit 3: 1=Enable Latches
GUS_Mixer       Proc    Near
        push    dx ax
        mov     dx,SoundCard_BasePort
        out     dx,al
        pop     ax dx
        ret
GUS_Mixer       EndP

;-------------------------------
; ** Main Mixer ** (Record)
; Calls:
;       DL:     0=MONO,1=Stereo
;       DH:     0=8bit, 1=16bit
;       CL:     1=LineIn
;       CH:     1=Mic In
;       AL:     1=CD In
;       BX:     Volume:Line:LLRR, MIC: MM00
;-------------------------------
GUS_MainMixer:
IFE     PLAYER
        pushad
        mov     Stereo,dl
        mov     SampleBits,dh

        push    ax
        mov     al,1000b
        xor     cl,1
        shl     ch,2
        or      al,ch
        or      al,cl
        call    GUS_Mixer
        pop     ax
        cmp     SoundCard,5
        jnz     _retp
        call    Ultra16CDIn
        call    Mono_Input_Level
        call    Stereo_Input_Level
        call    CD_Input_Level
        popad
ENDIF
        ret

GUS_Init        Proc    Near
        mov     bl,SoundCard_IRQ
        mov     bh,SoundCard_MIDIIRQ
        mov     cl,SoundCard_DMA1
        mov     ch,SoundCard_DMA2

        call    Ultrasound_Reset
        call    GUS_SizeDRAM
        and     eax,0000fh
        shl     eax,18
        mov     GUS_DramSize,eax
        mov     GUS_DramSize2,eax
        call    ChangeActiveVoices

        call    GetGUSVersion

        cmp     SoundCard,5
        jnz     _ret

        call    Ultra16Init             ;Init Codec

        ret
GUS_Init        Endp

GUS_B   Proc    Near
        mov     dx,GUS_Command
        out     dx,al
        add     dl,2
        mov     al,cl
        out     dx,al
        ret
GUS_B   EndP

GUS_W   Proc    Near
        mov     edx,dword ptr GUS_Command
        out     dx,al
        inc     dl
        mov     eax,ecx
        out     dx,ax
        ret
GUS_W   EndP

Read_GUS_ByteRegister   Proc      Near
        mov     edx,dword ptr GUS_Command
        out     dx,al
        add     dl,2
        in      al,dx
        ret
Read_GUS_ByteRegister   EndP

;GUSVersion     db      0
GetGUSVersion   Proc    Near
        pushad
        mov     dx,Revision
        in      al,dx
        and     eax,0ffh
        mov     SoundCardSub,eax
        popad
        ret
GetGUSVersion   EndP

Comment %
ÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸
³    COMPLETELY RESET THE GRAVIS ULTRASOUND                                ³
³                                                                          ³
³                                                                          ³
³ INPUT:                                                                   ³
³       BL = GF1  IRQ number  ( IRQ must be 0,2,3,5,7,11,12 or 15 )        ³
³       BH = MIDI IRQ number                                               ³
³       CL = DMA Playback channel  ( DMA must be 0,1,3,5,6 or 7 )          ³
³       CH = DMA Record channel                                            ³
³                                                                          ³
³ OUTPUT:                                                                  ³
³    The function will fail if an illegal DMA or IRQ number is selected    ³
³    and/or if the card has was not detected                               ³
³                                                                          ³
³      If function successful the carry is cleared and                     ³
³       the card is fully reset and all voices are initalized              ³
³                                                                          ³
³ Other registers of the GF1 are set as follows                            ³
³        LINE OUT enabled                                                  ³
³        DMA IRQ disabled                                                  ³
³NOTES:                                                                    ³
³     o    This function should only need to be used once by your program. ³
³     o    Both PICs ( 8259's ) mask registers might be modified.          ³
³     o    If the IRQ number is ZERO then the Ultrasound is programmed     ³
³          with that IRQ disabled.                                         ³
³     o    If the DMA channel is ZERO then the Ultrasound is programmed    ³
³          with that DMA disabled.                                         ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ%
GF1     db      0
MIDI1    db      0
Ultrasound_Reset        Proc    Near
        pushad
        and     bx,0f0fh
        and     cx,0707h
        mov     GF1,bl              ; Save IRQ's
        mov     MIDI1,bh

;****   convert IRQ numbers into register value   *****
        movzx   edx,bl
        and     dl,dl
        jz      Zero_IRQ1
        mov     dl,IRQ_reg_list[edx]
        and     dl,dl
        jz      invalid_setting
Zero_IRQ1:
        mov     IRQ_control,dl

        movzx   edx,bh
        and     dl,dl
        jz      Zero_IRQ2
        mov     dl,IRQ_reg_list[edx]
        and     dl,dl
        jz      invalid_setting
        shl     dl,3
Zero_IRQ2:
        or      IRQ_control,dl

        cmp     bh,bl                   ;Chech if both IRQ
        jne     diff_IRQs               ; are equal then
        and     bl,bl                   ;( Except when zero)
        jz      diff_IRQs
        and     IRQ_control,0111b       ;Clear Channel 2 IRQ
        or      IRQ_control,40h         ;and turn on bit 6
diff_IRQs:

;****   convert DMA number into register value   *****
        movzx   edx,cl
        and     dl,dl
        jz      Zero_DMA1
        mov     dl,DMA_reg_list[edx]
        and     dl,dl
        jz      invalid_setting
Zero_DMA1:
        mov     DMA_control,dl

        movzx   edx,ch
        and     dl,dl
        jz      Zero_DMA2
        mov     dl,DMA_reg_list[edx]
        and     dl,dl
        jz      invalid_setting
        shl     dl,3
Zero_DMA2:
        or      DMA_control,dl

        cmp     ch,cl                   ;Chech if both DMAs
        jne     diff_DMAs               ;are equal then
        and     cl,cl                   ;(Except when zero)
        jz      diff_DMAs
        and     DMA_control,0111b       ;Clear Channel 2 DMA
        or      DMA_control,40h         ;and turn on bit 6.
diff_DMAs:

Gus_detected:
        cli                             ;must not be disturbed

        mov     ax,SoundCard_BasePort
        mov     ecx,offset The_Ultrasound_port_Addresses
PAdrLoop:
        add     [ecx],ax
        add     ecx,2
        cmp     ecx,offset Ultrasound_ports_ends
        jb      PAdrLoop

; The code below sets the DMA and IRQ  settings of the Ultrasound

        mov     ecx,200h                ;delay a bit
        loop $


;/* Set up for Digital ASIC */
        mov     dx,SoundCard_BasePort
        add     dx,0fh
        mov     al,5
        out     dx,al                   ;Seems to be a undocumented register

        OutB    Mix_Control,00000011b
        OutB    IRQDMA_Ctrl,0

        mov     dx,SoundCard_BasePort
        add     dx,0fh
        mov     al,0
        out     dx,al


;First do DMA control register
        outb    Mix_Control,00000011b
        mov     dx,IRQDMA_Ctrl
        mov     al,DMA_control
        or      al,80h
        out     dx,al

;IRQ CONTROL REG
        OutB    Mix_Control,01000011b
        OutB    IRQDMA_Ctrl,IRQ_control

;First do DMA control register
;       OutB    Mix_Control,00000011b
;       OutB    IRQDMA_Ctrl,DMA_control

;IRQ CONTROL REG
;       OutB    Mix_Control,01000011b
;       OutB    IRQDMA_Ctrl,IRQ_control

;IRQ CONTROL, ENABLE IRQ
;Just to Lock out writes to irq\dma register ...
        OutB    GUS_Voice,0

;Enable output & irq, disable line & mic input
        OutB    Mix_Control,00000011b

;Just to Lock out writes to IRQ\DMA register ...
        OutB    GUS_Voice,0

        OutB    GUS_TIMER_Ctrl,4


;Unmask the IRQ lines  for the GF1 and MIDI IRQ settings
;NOTE: the pin labled IRQ 2 on the BUS connects to IRQ 9 of the PIC
;controllers. The IRQ 2 on the PIC is used for slave.
;The ultrasound SDK ( Software Development Kit ) says that the GUS can use
;IRQ 2 this means you must actually hook IRQ 9.

        in      al,0A1h
        mov     ah,al
        in      al,21h
        mov     cl,GF1                  ;Get GF1 IRQ
        cmp     cl,2                    ;Gotta put right IRQ 2
        jne     j3
        mov     cl,9
j3:
        mov     ebx,1
        shl     ebx,cl
        not     ebx
        and     eax,ebx
        mov     cl,MIDI1                 ;Get MIDI IRQ
        cmp     cl,2                    ;Gotta put right IRQ 2
        jne     j4
        mov     cl,9
j4:
        mov     ebx,1
        shl     ebx,cl
        not     ebx
        and     eax,ebx
        out     021h,al
        mov     al,ah
        out     0A1h,al
        sti

        call    Ultrasound_Init

;enable output & IRQ, disable line & mic input
        OutB    Mix_Control,0001001b

;outp just to Lock out writes to IRQ\DMA register ...
;       OutB    GUS_Voice,0

        clc
        popad
        ret

Invalid_setting:
        stc
        popad
        ret
Ultrasound_Reset        EndP


comment %
ÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸
³           INITALIZE  THE  ULTRASOUND'S  VOICES                           ³
³                                                                          ³
³   IN:  nothing                                                           ³
³                                                                          ³
³  OUT:   All 32 voices have initalized , cleared buffered IRQ's           ³
³         enables line out                                                 ³
³  Each of the 32 voices are set as follows                                ³
³                                                                          ³
³Frequency     = 0                                                         ³
³Voice stopped                                                             ³
³Bi-directional looping off                                                ³
³IRQs disabled                                                             ³
³Current Volume = 0                                                        ³
³Active Number of Voices = 14                                              ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ%
Ultrasound_Init Proc    Near
;        call    Ultrasound_Detect
;        jnc     GUSok
;        stc
;        ret
;GUSok:
        cli
        pushad

;/* Pull a reset on the GF1 */
        mov     al,04Ch
        mov     cl,00000000b
        call    GUS_B

;/* Wait a little while ... */
        mov     ecx,20
J56:    call    GUS_delay
        loop    J56

;/* Release Reset */
        mov     al,04Ch
        mov     cl,00000001b
        call    GUS_B

;/* Wait a little while ... */
        mov     ecx,20
J57:    call    GUS_delay
        loop    J57

;/* Reset the MIDI port also */
;        mov     edx,dword ptr MIDI_control
;        mov     al,00000011b
;        out     dx,al
	outb	MIDI_control,00000011b

        mov     ecx,20
J58:    call    GUS_delay
        loop    J58

;        mov     al,10000000b
;        out     dx,al
	outb	MIDI_control,10000000b

;/* Clear all interrupts. */
        mov     al,41h                  ;DRAM DMA Control Register
        mov     cl,0
        call    GUS_B
        mov     al,045h                 ;Timer Control Register
        mov     cl,0
        call    GUS_B
        mov     al,049h                 ;Sampling Control Register
        mov     cl,0
        call    GUS_B

        mov     al,0Eh                  ;set active voices to 32
        mov     cl,31 OR 0C0h
        call    GUS_B

;/* Clear interrupts on voices. */

        call    ClearInterrupt


        mov     al,0Eh                  ;set active voices to 14 again
        mov     cl,13 OR 0C0h
        call    GUS_B


        ;/* Set up GF1 Chip for interrupts & enable DACs. */
        mov     al,04Ch
        mov     cl,00000111b
        call    GUS_B

        sti
        clc
        popad
        ret
Ultrasound_Init EndP

ClearInterrupt  Proc    Near
        mov     BL,0
stop_loop:
        OutB    GUS_Voice,BL            ;select voice to operate with
        mov     al,00h                  ;set Voice control
        mov     cl,00000010b            ;(Stop voice )
        call    GUS_B
        mov     al,0Dh                  ;set Volume Ramp control
        mov     cl,00000010b            ;(Stop ramping)
        call    GUS_B
        mov     al,06h                  ;Set Volume Ramp speed
        mov     cl,00001111b
        call    GUS_B
        mov     al,09h                  ;Current Volume fully off
        xor     ecx,ecx
        call    GUS_W
        call    GUS_delay               ;Wait 4.8 micos. or more.

        inc     bl
        cmp     bl,32
        jb      stop_loop

;/* Reading the status ports will clear the IRQs. */

        mov     edx,dword ptr GUS_IRQ_status      ; Read
        in      al,dx
        mov     al,041h                 ;DRAM DMA Control Register
        call    read_GUS_ByteRegister
        mov     al,049h                 ;Sampling  Control Register
        call    read_GUS_ByteRegister
ClrFIFO:
        mov     al,08Fh                 ;IRQ source Register
        call    read_GUS_ByteRegister
        and     al,11000000b
        cmp     al,11000000b            ;keep on reading to clear IRQ's
        jnz     ClrFIFO
        ret
ClearInterrupt  EndP

GUS_Search      Proc    Near
        cmp     SoundCard_BasePort,0
        jnz     FoundIt
        mov     SoundCard_BasePort,210h
TestIt:
        call    GUS_Probe
        jnc     FoundIt
        add     SoundCard_BasePort,10h
        cmp     SoundCard_BasePort,270h
        jb      TestIt
        stc
        ret
FoundIt:
        clc
        ret
GUS_Search      EndP

GUS_Delay       Proc    Near
        push    ax ecx dx
        mov     dx,SoundCard_BasePort
        mov     ecx,14
Fluke:  in      al,dx
        loop    Fluke
        pop     dx ecx ax
        ret
GUS_Delay       EndP

GUS_Probe       Proc    Near
        pusha
        mov     dx,SoundCard_BasePort
        add     dx,GUS_Command          ; 103h
        mov     al,4Ch
        out     dx,al
        add     dx,2                    ; 105h
        mov     al,0
        out     dx,al
        call    GUS_Delay
        call    GUS_Delay
        sub     dx,2                    ; 103h
        mov     al,4Ch
        out     dx,al
        add     dx,2                    ; 105h
        mov     al,1
        out     dx,al
        mov     ax,0AAh
        mov     bx,0
        mov     cx,0
        call    GUS_Poke
        mov     ax,055h
        mov     bx,1
        call    GUS_Poke
        mov     bx,0
        call    GUS_Peek
        push    ax
        mov     ax,0
        call    GUS_Poke
        sub     dx,2                    ; 103h
        mov     al,4Ch
        out     dx,al
        add     dx,2                    ; 105h
        mov     al,0
        out     dx,al
        pop     ax
        cmp     al,0AAh
        jnz     Nope
        popa
        clc
        ret
Nope:
        popa
        stc
        ret
GUS_Probe       EndP

GUS_ChangeActiveVoices Proc Near
        Pushad
        cli
        mov     dx,GUS_Command          ;Enable ALL voices
        mov     al,0eh
        out     dx,al
        add     dx,2
        mov     al,31 OR 0c0h
        out     dx,al

        call    ClearInterrupt

        mov     dx,GUS_Command
        mov     al,0eh
        out     dx,al
        add     dx,2
        mov     al,AllocChannels
        dec     al
        cmp     al,13
        ja      DontChangeFlugan
        mov     al,13
DontChangeFlugan:
        or      al,11000000b
        out     dx,al
        mov     al,AllocChannels
        sub     al,14
        jg      NoFix
        xor     ax,ax
NoFix:
        movzx   ebx,al
        mov     ax,[GUS_Voices+ebx*2]
        mov     GUS_Divisor,ax

        sti
        Popad
        Ret
GUS_ChangeActiveVoices EndP

;IN: BX:CX Set to whatever.
;OUT: AL=Value
GUS_Peek        Proc    Near
        push    dx
        mov     dx,SoundCard_BasePort
        add     dx,103h                 ; 103h
        mov     al,43h
        out     dx,al

        inc     dx                      ; 104h
        mov     ax,cx
        out     dx,ax
        dec     dx                      ; 103h
        mov     al,44h
        out     dx,al

        add     dx,2                    ; 105h
        mov     al,bl
        out     dx,al
        add     dx,2                    ; 107h
        in      al,dx
        pop     dx
        ret
GUS_Peek        EndP

; BX:CX Set to whatever.
; AX Value to poke
GUS_Poke        Proc    Near
        push    dx ax
        mov     dx,SoundCard_BasePort
        add     dx,103h
        mov     al,43h
        out     dx,al
        inc     dx
        mov     ax,cx
        out     dx,ax
        dec     dx
        mov     al,44h
        out     dx,al
        add     dx,2
        mov     al,bl
        out     dx,al
        add     dx,2
        pop     ax
        out     dx,al
        pop     dx
        ret
GUS_Poke        EndP

GUS_SizeDRAM    Proc    Near
        push    bx cx
        xor     bx,bx
        xor     cx,cx
DRAMLoop:
        push    cx
        mov     cx,0
        mov     ax,0AAh
        call    GUS_Poke
        call    GUS_Peek
        pop     cx
        cmp     al,0AAh
        jnz     Exit

        push    cx
        mov     cx,0
        mov     ax,033h
        call    GUS_Poke
        call    GUS_Peek
        pop     cx
        cmp     al,033h
        jnz     Exit

        add     bx,4
        inc     cx
        cmp     cx,5
        jb      DRAMLoop
        dec     cx
Exit:
        mov     ax,cx
        pop     cx bx
        ret
GUS_SizeDRAM    EndP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls:
;EBX=SampleNr
;[AllocTable+1024*8]=Source
;SampleOffsetMem=Destination
;EDX=128 - conv
;EDX=0   - no conv
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GUS_MoveSample  Proc    Near
        pushad
        pushf
;       mov     StackSave,esp

        and     ebx,0fffh
        mov     cl,[VoiceControl+ebx]
        bt      cx,2
        setc    cl
        movzx   ax,cl
        shl     ax,6
        or      dx,ax

        push    ebx                     ;Resize Buffer
        mov     ebp,1024
        mov     eax,GF1BUGFIX
        shl     eax,cl
        add     eax,ds:[AllocTable+ebp*8+4]
        xor     ebx,ebx
        call    MemAlloc
        jc      NotEnoughHiMem
        mov     esi,eax
        mov     edi,eax
        pop     ebx

        mov     eax,[SampleOffsetEnd+ebx*4]
        push    esi
        shl     eax,cl
        add     edi,eax
        cmp     [LoopEnd+ebx*4],0
        jz      NoLisebergsLoopen
        mov     eax,[LoopStart+ebx*4]
        shl     eax,cl
        add     esi,eax
        push    ecx
        mov     eax,GF1BUGFIX
        shl     eax,cl
        mov     ecx,eax
        rep     movsb
        pop     ecx
        jmp     LisebergsLoopen
NoLisebergsLoopen:
        push    ecx
        mov     ecx,GF1BUGFIX
        mov     al,[edi-1]
        rep     stosb
        pop     ecx
LisebergsLoopen:
        pop     esi

        mov     eax,[SampleOffsetEnd+ebx*4]
        add     eax,GF1BUGFIX
        shl     eax,cl
        mov     ecx,eax

        mov     eax,SampleOffsetMem
        mov     [SampleOffsetStart+ebx*4],eax
        add     [SampleOffsetEnd+ebx*4],eax
        add     [LoopStart+ebx*4],eax
        add     [LoopEnd+ebx*4],eax

        push    ecx
        mov     cl,[VoiceControl+ebx]
        bt      cx,2
        setc    cl
        shl     eax,cl
        mov     SampleOffsetMem,eax
        pop     ecx


        push    ebx
        mov     ThisSpecialCase,ebx
        mov     ebx,esi

        movzx   ebp,DMAOnOff
        call    ds:[DMAorNot+ebp*4]
        pop     ebx

        mov     cl,[VoiceControl+ebx]           ;Resize
        bt      cx,2
        setc    cl
        mov     ebp,1024
        mov     eax,[SampleOffsetEnd+ebx*4]
        sub     eax,[SampleOffsetStart+ebx*4]
        shl     eax,cl
        xor     ebx,ebx
        call    MemAlloc
        jc      NotEnoughHiMem



        popf
        popad
        ret
GUS_MoveSample  EndP
DMAorNot        dd      GUS_DumpSampleToDRAM,GUS_DMASampleToDram

;-----------------------------------
; calls:  EAX   - Destination
;         EBX   - Source
;         ECX   - Bytes to dump
;          DL   - 128 = Conv, 0 = No Conv
;-----------------------------------
GUS_MoveTuneForkSample  Proc    Near
IFE     PLAYER
        pushad
        mov     ecx,104
        movzx   ebp,DMAOnOff
        call    ds:[DMAorNot+ebp*4]
        popad
ENDIF
        ret
GUS_MoveTuneForkSample  EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls EAX = Address in GUS to put/get sample
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Start_GUS_Dma   Proc    Near
        pushad
        mov     edi,eax
        test    SoundCard_DMA1,100b
        jz      _8bitDMA
;---- do 16 bit DMA address translation.
        mov     eax,edi
        shr     edi,1
        adc     edi,0
        and     edi,01ffffh     ; zero out bit 17..19
        and     eax,0c0000h     ; get bits 18 and 19
        or      edi,eax
_8bitDMA:
        shr     edi,4
        adc     edi,0
        mov     al,042h                       ; DMA Start Address
        mov     ecx,edi
        call    GUS_W

;********* Set the GUS's DMA Control Register  ****************

        mov     al,041h                 ;DRAM DMA Control Register
        mov     ah,SoundCard_DMA1
        and     ah,100b
        mov     cl,00100001b            ;Write, 650KB/s, 16bit data, 16/8bit DMA
        or      cl,ah
        or      cl,Convert
        call    GUS_B                   ;The DMA cycle will now start
        popad
        ret
Start_GUS_Dma   EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Dump sample to Ram
; calls:  EAX   - Offset (in DRAM) to dump to
;         EBX   - Offset (in memory) to sample
;         ECX   - Bytes to dump
;          DL   - 128 = Conv, 0 = No Conv
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ThisSpecialCase dd      0       ;Current Sample

GUS_DumpSampleToDRAM    Proc    Near
        pushad
        push    word ptr TransferBits


;--..--
        push    ecx
        mov     ecx,ThisSpecialCase
        mov     cl,[VoiceControl+ecx]
        bt      cx,2
        setc    cl
        ror     cl,1
        mov     TransferBits,cl
        pop     ecx
;--..--
        and     dl,80h
        mov     Convert,dl
        mov     di,ax
        shr     eax,16
        mov     si,ax
        mov     dx,GUS_Command
        mov     al,44h          ; Dump upper byte, only do it on carry from now
        out     dx,al           ; on.
        add     dx,2
        push    ax
        mov     ax,si
        out     dx,al
        pop     ax
        sub     dx,2
        mov     ah,TransferBits
        and     ah,Convert
@@MainLoop:
        mov     al,43h
        out     dx,al
        inc     dx
        push    ax
        mov     ax,di
        out     dx,ax
        pop     ax
        dec     dx
        add     di,1
        jnc     @@DumpByte
        inc     si
        mov     al,44h
        out     dx,al
        add     dx,2
        push    ax
        mov     ax,si
        out     dx,al
        pop     ax
        sub     dx,2

        mov     al,43h
        out     dx,al
        inc     dx
        push    ax
        mov     ax,di
        out     dx,ax
        pop     ax
        dec     dx
@@DumpByte:
        add     dx,4
        mov     al,[ebx]
        xor     Convert,ah
        xor     al,Convert
        inc     ebx
        out     dx,al
        sub     dx,4
        loop    @@MainLoop

        pop     word ptr TransferBits
        popad
        ret
GUS_DumpSampleToDRAM    EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Get GUS memory
; calls:  EAX   - Offset (in DRAM) to dump from
;         EBX   - Offset (in memory) to buffer
;         ECX   - Samples to get
;          DL   - 128 if convert, 0 if not
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Convert         db      0
TransferBits    db      0
GUS_GetSampleFromDRAM   Proc    Near
        cmp     DMAOnOff,1
        jz      GUS_DMASampleFromDRAM
        pushad
        push    word ptr Convert
        and     dl,80h
        mov     Convert,dl
;--..--
        mov     edx,ecx
        movzx   ecx,CurrentSample
        mov     cl,[VoiceControl+ecx]
        bt      cx,2
        setc    cl
        mov     TransferBits,cl
        ror     TransferBits,1
        shl     edx,cl
        shl     eax,cl
        mov     ecx,edx
;--..--
        mov     di,ax
        shr     eax,16
        mov     si,ax
        mov     dx,GUS_Command
        mov     al,44h          ; Dump upper byte, only do it on carry from now
        out     dx,al           ; on.
        add     dx,2
        push    ax
        mov     ax,si
        out     dx,al
        pop     ax
        sub     dx,2
        mov     ah,TransferBits
        and     ah,Convert
@@MainLoop2:
        mov     al,43h
        out     dx,al
        inc     dx
        push    ax
        mov     ax,di
        out     dx,ax
        pop     ax
        dec     dx
        add     di,1
        jnc     @@GetByte
        inc     si
        mov     al,44h
        out     dx,al
        add     dx,2
        push    ax
        mov     ax,si
        out     dx,al
        pop     ax
        sub     dx,2

        mov     al,43h
        out     dx,al
        inc     dx
        push    ax
        mov     ax,di
        out     dx,ax
        pop     ax
        dec     dx

@@GetByte:
        add     dx,4
        in      al,dx
        xor     Convert,ah
        xor     al,Convert
        mov     [ebx],al
        inc     ebx
        sub     dx,4
        loop    @@MainLoop2

        pop     word ptr Convert
        popad
        ret
GUS_GetSampleFromDRAM   EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls: EBX = Sample #
;       EDI = Channel
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GUS_PlayVoice Proc  Near
        and     ebx,0fffh
        jz      _ret

GUS_KeyBoardPlayVoice:
        pushad
        mov     dx,GUS_Voice
        mov     ax,di                   ;Voice #
        out     dx,al

        mov     eax,[SampleOffsetStart+ebx*4]
        call    Convert16Bit
        mov     SampleOffsetStart2,eax
        mov     eax,[SampleOffsetEnd+ebx*4]
        call    Convert16Bit
        mov     SampleOffsetEnd2,eax
        mov     eax,[LoopStart+ebx*4]
        call    Convert16Bit
        mov     LoopStart2,eax
        mov     eax,[LoopEnd+ebx*4]
        call    Convert16Bit
        mov     LoopEnd2,eax

        mov     al,[VoiceControl+ebx]
        and     al,01011111b
        or      al,3
        xor     cl,cl
        btr     PlayDirection,edi
        rcl     cl,2
        btr     PlayDirection+4,edi
        rcl     cl,5
        or      al,cl
        mov     VoiceCtrl,al

        mov     dx,GUS_Command
        mov     al,0                    ;Voice Control
        out     dx,al
        add     dx,2
        mov     al,VoiceCtrl
        out     dx,al

        mov     dx,GUS_Command
        mov     al,02h                  ;Starting Address HIGH
        out     dx,al
        mov     eax,LoopStart2
        shr     eax,7
        inc     dx                      ;104
        out     dx,ax

        mov     dx,GUS_Command
        mov     al,3h                   ;Starting Address LOW
        out     dx,al
        mov     eax,LoopStart2
        shl     ax,9
        inc     dx                      ;104
        out     dx,ax

        mov     dx,GUS_Command
        mov     al,0Ah                  ;Current Address HIGH
        out     dx,al
        mov     eax,SampleOffsetStart2
        test    VoiceCtrl,40h
        jz      ForwardPlay
        mov     eax,SampleOffsetEnd2
ForwardPlay:
        test    [SkipFlag+edi*2],00008h
        jz      SkipSampleOffset
        test    VoiceCtrl,40h
        jz      ForwardPlay5
        mov     eax,SampleOffsetStart2
ForwardPlay5:
        mov     cl,[SampOffset+edi]
        shl     cx,8
        and     ecx,0ffffh
        add     eax,ecx
SkipSampleOffset:
        shr     eax,7
        inc     dx                      ;104
        out     dx,ax

        mov     dx,GUS_Command
        mov     al,0bh                  ;Current Address LOW
        out     dx,al
        mov     eax,SampleOffsetStart2
        test    VoiceCtrl,40h
        jz      ForwardPlay2
        mov     eax,SampleOffsetEnd2
ForwardPlay2:
        test    [SkipFlag+edi*2],00008h
        jz      SkipSampleOffset2
        test    VoiceCtrl,40h
        jz      ForwardPlay6
        mov     eax,SampleOffsetStart2
ForwardPlay6:
        mov     cl,[SampOffset+edi]
        shl     cx,8
        and     ecx,0ffffh
        add     eax,ecx
SkipSampleOffset2:
        shl     ax,9
        inc     dx                      ;104
        out     dx,ax

        test    VoiceCtrl,8
        jz      NoLooping
        mov     edx,LoopStart2
        cmp     LoopEnd2,edx
        jz      NoLooping
        btr     SpecialBreakByte,edi
        jc      NoLooping

        mov     dx,GUS_Command
        mov     al,04h                  ;End Address HIGH
        out     dx,al
        mov     eax,LoopEnd2
        shr     eax,7
        inc     dx                      ;104
        out     dx,ax

        mov     dx,GUS_Command
        mov     al,05h                  ;End Address LOW
        out     dx,al
        mov     eax,LoopEnd2
        shl     ax,9
        inc     dx                      ;104
        out     dx,ax
        jmp     Looping

NoLooping:
        and     VoiceCtrl,11110111b
        mov     dx,GUS_Command
        mov     al,04h                  ;End Address HIGH
        out     dx,al
        mov     eax,SampleOffsetEnd2
        shr     eax,7
        inc     dx                      ;104
        out     dx,ax

        mov     dx,GUS_Command
        mov     al,05h                  ;End Address LOW
        out     dx,al
        mov     eax,SampleOffsetEnd2
        shl     ax,9
        inc     dx                      ;104
        out     dx,ax

Looping:
        btr     EnvPanCheck,edi
        jc      PanPotSet

        mov     ah,[FineTunes+ebx]
        and     ah,0f0h
        jz      ChanPanPot
        mov     [CurrentChannelPanPot+edi],ah
        jmp     PanPotSet

ChanPanPot:
        mov     ah,[PanPosition+edi]
        mov     [CurrentChannelPanPot+edi],ah

PanPotSet:
        bts     EnvPanCheck,edi
        mov     ah,VoiceCtrl
        and     ah,11111100b
        or      ah,EnableWaveIRQ                ;Enable IRQ
        mov     [PlayInfo+edi],ah

        mov     ecx,1
        call    ENV_NextChannel
        popad
        ret
GUS_PlayVoice EndP

;in ebx=SampleNr
;   eax=offset
Convert16Bit:
        push    ebx
        mov     bl,[VoiceControl+ebx]
        bt      bx,2
        jnc     No16bitTweak
        mov     ebx,eax
        shl     ebx,1
        and     eax,0001ffffh
        and     ebx,000c0000h
        or      eax,ebx
No16bitTweak:
        pop     ebx
        ret

;Calls: cx+1  = Voice to stop
GUS_StopOneVoice    Proc    Near
        push    esi ecx ax dx
        cli
        movzx   ecx,cx
        dec     ecx
        mov     [StopRampTable+ecx],1
        lea     esi,StopRampTable
        call    RampDownNeededChannels

        mov     dx,GUS_Voice
        mov     ax,cx                   ;Voice #
        out     dx,al

        mov     dx,GUS_Command
        mov     al,0                    ;Voice Control
        out     dx,al
        add     dx,2
        mov     al,2
        out     dx,al
        call    GUS_Delay

        sti
        pop     dx ax ecx esi
        ret
GUS_StopOneVoice    EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls: EAX = Size Wanted (in samples)
;       CurrentSample
;Ret:   CY=1 if error
;       EAX = Offset to dump sample
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SizeAllocated   dd      0
AllocFailed     db      0
GUS_DramFree    dd      0               ;Total Free Dram (even fragmented)
GUS_FreeTable   dd      160 dup(0)      ;Increase )?(
GUS_TableSize   equ     80              ;Size of FreeTable
DidCompress     db      0               ;set to 1 if a compress occured
AllocBits       db      0               ;Bits of sample
GUS_Alloc       Proc    Near
        Pushad
        mov     SizeAllocated,eax       ;Assume allocation went ok.
        add     eax,GF1BUGFIX
;--..--
        movzx   ecx,CurrentSample
        mov     cl,[VoiceControl+ecx]
        bt      cx,2
        setc    cl
        mov     AllocBits,cl
        shl     eax,cl
;--..--
        mov     ecx,GUS_TableSize
        lea     edi,GUS_FreeTable+4
SearchFree:
        cmp     [edi],eax
        jae     GotArea
IWasWrong:
        add     edi,8
        loop    SearchFree

        mov     ecx,GUS_TableSize               ;Search for biggest free size
        lea     edi,GUS_FreeTable-8
        cmp     dword ptr [edi+8],0
        jz      NoMemLeft                       ;if 0 mem left
SearchZero:
        add     edi,8
        cmp     dword ptr [edi],0
        loopnz  SearchZero
        sub     edi,4
        mov     eax,[edi]                       ;Get size
        dec     eax
        and     eax,not 31
        mov     AllocFailed,1
        jmp     GotArea
NoMemLeft:
        mov     SizeAllocated,0
        mov     AllocFailed,1
        popad
        stc
        ret

GotArea:
        test    eax,31          ;eax=size
        jz      Aligned1
        and     eax,not 31      ;Align 32
        add     eax,32
Aligned1:
        mov     ebx,[edi-4]     ;ebx=offset
        test    ebx,31
        jz      Aligned2
        and     ebx,not 31      ;Align 32
        add     ebx,32
Aligned2:
        cmp     AllocBits,0
        jz      NoSpecial16Alloc

        cmp     eax,262142      ;Max Sample Size INCLUSIVE pad bytes
        jbe     FitsInBank
        mov     eax,262112      ;In bytes
        mov     AllocFailed,1
FitsInBank:

        mov     edx,ebx         ;edx=StartOffset
        mov     ebp,ebx         ;ebp=StartOffset
        add     edx,eax         ;edx=EndOffset
        shr     edx,18          ;End Offs 256k Aligned downwards
        shr     ebp,18          ;Start Offs 256k Aligned downwards
        cmp     edx,ebp         ;Same Bank?
        jz      NoSpecial16Alloc;If yes, no problem!

        shl     edx,18          ;edx=new 256k aligned StartOffset
        mov     ebp,edx         ;ebp=new 256k aligned StartOffset
        sub     edx,ebx         ;Aligned EndOffset-StartOffs=Dummy
        mov     ebx,ebp         ;ebx=new 256k aligned StartOffset
        mov     ebp,edx         ;ebp=unused space before samp
        add     edx,eax         ;edx=new size (including dummy space)

        cmp     [edi],edx       ;Does it fit?
        jb      IWasWrong       ;Nope

        sub     GUS_DramFree,eax;Yep
        push    eax
        mov     eax,edx         ;Total Size
        add     eax,[edi-4]     ;eax=offset to unused space
        sub     edx,[edi]       ;edx=unused space after samp
        neg     edx
        mov     [edi],ebp

        mov     edi,GUS_TableSize
        dec     edi
        mov     [GUS_FreeTable+edi*8],eax
        mov     [GUS_FreeTable+edi*8+4],edx
        pop     eax
        jmp     Special16Alloc

NoSpecial16Alloc:
        sub     GUS_DramFree,eax
        sub     [edi],eax
        jnz     OfTheWorld
        mov     Dword Ptr [edi-4],0
        jmp     Special16Alloc
OfTheWorld:
        add     [edi-4],eax
Special16Alloc:
        call    OptimizeTable
        call    GUS_SortTable

;--..--
        mov     cl,AllocBits
        shr     ebx,cl
;--..--
        mov     SampleOffsetMem,ebx

        shr     eax,cl
        sub     eax,GF1BUGFIX
        jge     @@Fine
        xor     eax,eax
@@Fine:

        mov     SizeAllocated,eax

;...
;       mov     eax,DumPtr
;       mov     [DumTable+eax*4],ebx
;       inc     DumPtr
;...
        mov     [esp+28],ebx
        mov     al,AllocFailed          ;Set carry if needed
        rcr     al,1
        Popad
        Ret
GUS_Alloc       EndP

Global  DumTable:Dword:100
DumPtr          dd      0
DumTable        dd      100 dup(0)

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls: EAX = Size to Disalloc (in samples)
;       ESI = Offset to Disalloc
;       CurrentSample
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GUS_Disalloc     Proc    Near
        Pushad
        add     eax,GF1BUGFIX
;--..--
        movzx   ecx,CurrentSample
        mov     cl,[VoiceControl+ecx]
        bt      cx,2
        setc    cl
        shl     eax,cl
        shl     esi,cl
;--..--
        lea     edi,GUS_FreeTable-8
        mov     ecx,GUS_TableSize
SearchEnd:
        add     edi,8
        cmp     Dword ptr [edi],0
        jnz     Nofisk
        cmp     Dword ptr [edi+4],0     ;This IS Correct!
Nofisk:
        loopnz  SearchEnd
        jnz     ErrorEnd
        mov     [edi],esi
        test    eax,31
        jz      Aligned3
        and     eax,not 31      ;Align 32
        add     eax,32
Aligned3:
        mov     [edi+4],eax
        add     GUS_DramFree,eax
        call    GUS_SortTable
        clc
        Popad
CompressAgain:
        mov     DidCompress,0
        call    GUS_CompressTable
        cmp     DidCompress,1
        jz      CompressAgain
        call    OptimizeTable
        call    GUS_SortTable
        Ret
ErrorEnd:
        call    sara4
        stc
        Popad
        Ret
GUS_Disalloc    EndP

GUS_SortTable   Proc    Near                    ;Sort table
        Pushad
        lea     edi,GUS_FreeTable+4
        mov     esi,edi
        mov     ecx,GUS_TableSize
        dec     ecx
        mov     ebp,ecx
BigLoopen:
        push    ecx
        push    edi
        push    esi
        mov     ecx,ebp
        mov     eax,[edi]
SmallLoopen:
        add     esi,8
        cmp     [esi],eax
        jae     NoSwap
        cmp     dword ptr [esi],0
        jz      NoSwap
        mov     ebx,[edi]
        xchg    ebx,[esi]
        mov     [edi],ebx
        mov     eax,ebx
        mov     ebx,[edi-4]
        xchg    ebx,[esi-4]
        mov     [edi-4],ebx

NoSwap:
        loop    SmallLoopen
        pop     esi
        pop     edi
        pop     ecx
        dec     ebp
        add     esi,8
        add     edi,8
        loop    BigLoopen


        Popad
        Ret
GUS_SortTable   EndP

GUS_CompressTable       Proc    Near            ;Check near areas
        Pushad
        mov     ecx,GUS_TableSize
        lea     edi,GUS_FreeTable
CompLoop:
        lea     esi,GUS_FreeTable
        push    ecx
        mov     eax,[edi]
        add     eax,[edi+4]
        mov     ecx,GUS_TableSize
CompLoop2:
        push    ecx
        cmp     eax,[esi]
        jnz     DontCompress
        cmp     eax,0
        jz      DontCompress
        mov     DidCompress,1
        mov     eax,[edi+4]
        add     eax,[esi+4]
        mov     [edi+4],eax
        mov     Dword Ptr [esi],0
        mov     Dword Ptr [esi+4],0
        pop     ecx
        jmp     QuitFirst
DontCompress:
        pop     ecx
        add     esi,8
        loop    CompLoop2
QuitFirst:
        pop     ecx
        add     edi,8
        loop    CompLoop
        Popad
        Ret
GUS_CompressTable       EndP

OptimizeTable   Proc    Near            ;Removes spaces in table
        Pushad
        lea     edi,GUS_FreeTable
        mov     ecx,GUS_TableSize

OptimTable:
        cmp     Dword ptr [edi],0
        jnz     NoSlisk
        cmp     Dword ptr [edi+4],0
        jnz     NoSlisk
        push    ecx edi
        dec     ecx
        shl     ecx,1
        mov     esi,edi
        add     esi,8
        rep     movsd
        mov     dword ptr [edi],0
        mov     dword ptr [edi+4],0
        pop     edi ecx
        sub     edi,8
NoSlisk:
        add     edi,8
        loop    OptimTable

        Popad
        Ret
OptimizeTable   EndP

;xxxxxxxxxxxxxxxxxxxxxxxxx
WaveTableHit    dd      0
VolumeRampHit   dd      0
UpdateChannels  db      0       ;Set to 1 if to call AMSPLAY
GUS_IRQ     Proc    Near
        pushad
        pushfd
        push    gs ds es
        mov     ds,cs:_seldata
        mov     gs,cs:_selzero
        cld
;clear the ignore flags. These flags are needed because we get lots of
;'double' interrupts. This will only allow one interrupt per voice
        mov     WaveTableHit,0
        mov     VolumeRampHit,0

NextPoll:               ;First, find out who has an interrupt pending
        mov     dx,GUS_IRQ_status
        in      al,dx

        cmp     al,0
        jnz     @@NoCodec

        cmp     SoundCard,5
        jnz     Exit_ISR

        mov     dx,Codec_Base
        add     dx,Codec_Status
        in      al,dx
        and     al,CODEC_INT
        jz      Exit_ISR
        call    Codec_Handler
        jmp     Exit_ISR
@@NoCodec:

        mov     ah,al

        btr     ax,0                    ;look for a MIDI IRQ
        jc      Was_MIDI_TX

        btr     ax,1                    ;look for a MIDI IRQ
        jc      Was_MIDI_RX

        btr     ax,2                    ;look for a Timer 1 IRQ
        jc      Was_Timer_IRQ

        btr     ax,7                    ;look for a DMA TC IRQ
        jc      Was_DMA_TC

; Must read the IRQ source register to clear the FIFO interrupts

Poll:
        cli
        mov     al,8fh
        call    Read_GUS_ByteRegister
        sti
        test    ah,20h
        jnz     WaveTableIRQ
        test    ah,40h
        jnz     VolumerampIRQ
Poll3:
        and     al,0c0h
        cmp     al,0c0h
        jnz     Poll
Exit_ISR:
        cmp     UpdateChannels,1
        jz      AMSPLAY2

        mov     al,020h                 ;EOI to PICs
        out     0A0h,al
        out     020h,al
        pop     es ds gs
        popfd
        popad
        sti
        iRetD

Was_DMA_TC:     ; Read DRAM DMA control register to allow more DRAM DMA IRQs.
        push    ax
        cmp     Sampling,0
        jnz     SamplingReset
        mov     dx,GUS_Command
        mov     al,041h                 ;DRAM DMA Control Register
        out     dx,al
        mov     dx,GUS_DATA_High        ;Read
        in      al,dx
        mov     DMAPlay_TC,1
        pop     ax
        jmp     NextPoll

SamplingReset:
        mov     dx,GUS_Command
        mov     al,049h                 ;Sample DMA Control Register
        out     dx,al
        mov     dx,GUS_DATA_High        ;Read
        in      al,dx
        mov     DMAPlay_TC,1

        cmp     Sampling,3
        jz      Exit_Fnutte

        mov     ecx,GUS_RollOverDataSize
        shr     ecx,1
        xor     SamplingBuffOff,ecx

        mov     ebx,DMABuffer_Phys
        add     ebx,SamplingBuffOff
        mov     al,01010100b            ;DMA mode register (read from GUS)
        mov     ah,SoundCard_DMA2       ;Channel number ( 0..7 )
        call    DMA_setup               ;Do it

        pushad
        mov     dx,GUS_Command
        mov     al,49h                  ;Sampling Control Register
        out     dx,al
        mov     dx,GUS_Data_High
        mov     al,Stereo               ;Stereo
        shl     al,1
        or      al,00100001b            ;GO + IRQ Enable
        mov     ah,SoundCard_DMA2       ;8/16 bits
        and     ah,100b
        or      al,ah
        out     dx,al
        popad
        pop     ax
        jmp     NextPoll

Exit_Fnutte:
        call    StopADC
        pop     ax
        jmp     NextPoll

WaveTableIRQ:
        push    ax
        and     al,1fh
        movzx   edi,al
        bt      WaveTableHit,edi
        jc      Spratt
        bts     WaveTableHit,edi
        mov     dx,GUS_Voice
        out     dx,al

        mov     cl,3
        mov     al,0
        call    GUS_B
Spratt:
        pop     ax
        jmp     Poll3

VolumerampIRQ:
        push    ax
        mov     edi,eax
        and     edi,1fh
        bt      VolumeRampHit,edi
        jc      Spratt
        bts     VolumeRampHit,edi

        mov     ax,di
        mov     dx,GUS_Voice
        out     dx,al

        mov     al,0dh
        mov     cl,3h          ;Stop Ramping
        call    GUS_B
        pop     ax
        jmp     Poll3


MIDI_Status     db      0
MIDIBuffer      db      32 dup(0)
MIDIBuffLen     db      0
MIDIBuffPtrR    db      0
MIDIBuffPtrW    db      0

Was_MIDI_TX:
        push    ax
        mov     dx,MIDI_Control         ;Get MIDI status
        in      al,dx
        mov     MIDI_Status,al

        mov     dx,MIDI_control         ;Reset IRQ
        mov     al,10000000b
        out     dx,al

        mov     ecx,10
T58:    call    GUS_delay
        loop    T58

        mov     dx,MIDI_control
        mov     al,10100000b
        out     dx,al

;       mov     dx,MIDI_Data            ;Clear IRQ
;       out     dx,al
;       in      al,dx

        pop     ax
        jmp     NextPoll

Was_MIDI_RX:
        push    ax

        mov     dx,MIDI_Control         ;Get MIDI status
        in      al,dx
        mov     MIDI_Status,al

        mov     dx,MIDI_Data            ;Clear IRQ
        in      al,dx

	cmp	al,0f8h		; Don't care about Active Sensing bytes
	jz	@@dontstore

        movzx   ebx,MIDIBuffPtrW
        mov     [MIDIBuffer+ebx],al
        inc     MIDIBuffPtrW
        and     MIDIBuffPtrW,31
        inc     MIDIBuffLen

@@dontstore:

;       mov     edx,dword ptr MIDI_control
;       mov     al,10100000b
;       out     dx,al

        pop     ax
        jmp     NextPoll


Was_Timer_IRQ:
        push    ax
        mov     al,045h                         ;Disable IRQ
        mov     cl,00000000b
        call    GUS_B

        call    GUS_Delay

        mov     al,045h                         ;Enable IRQ
        mov     cl,00000100b
        call    GUS_B

;        mov     al,046h                         ;Init Speed
;        mov     cl,134
;        call    GUS_B

;        mov     dx,GUS_TIMER_Data               ;Start Timer
;        mov     al,10000001b
;        out     dx,al

        pop     ax
        mov     UpdateChannels,1
        jmp     NextPoll


Codec_Handler:
        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,IRQ_STATUS
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        in      al,dx                   ;Status

        and     al,(PLAYBACK_IRQ OR CAPTURE_IRQ OR TIMER_IRQ)

        test    al,PLAYBACK_IRQ
        jz      NoCodecPlayBack

        ;_codec_data.play_func();

        push    ax
        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,IRQ_STATUS
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,(CAPTURE_IRQ OR TIMER_IRQ)
        out     dx,al
        pop     ax
NoCodecPlayBack:
        test    al,CAPTURE_IRQ
        jz      NoCodecRecord

        push    ax
        mov     DMAPlay_TC,1

        mov     dx,Codec_Base           ;Clear IRQ
        add     dx,Codec_Addr
        mov     al,IRQ_STATUS
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,(PLAYBACK_IRQ OR TIMER_IRQ)
        out     dx,al
        pop     ax

        cmp     Sampling,3
        jz      Exit_CodecCapture

        push    ax
        mov     ecx,GUS_RollOverDataSize
        shr     ecx,1
        xor     SamplingBuffOff,ecx

        mov     ebx,DMABuffer_Phys
        add     ebx,SamplingBuffOff
        mov     al,01000100b            ;DMA mode register (read from GUS)
        mov     ah,SoundCard_DMA2       ;Channel number ( 0..7 )
        call    DMA_setup               ;Do it
        pop     ax


NoCodecRecord:
        test    al,TIMER_IRQ
        jz      NoCodecTimer
        ;_codec_data.timer_func();

        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,IRQ_STATUS
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,(PLAYBACK_IRQ OR CAPTURE_IRQ)
        out     dx,al

NoCodecTimer:
        ret

Exit_CodecCapture:
        call    StopADC
        ret


GUS_IRQ  EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Dump Sample to GUS
; calls:  SampleOffsetMem  - Offset (in DRAM) to dump to
;         EBX   - Offset (in memory) to sample
;         ECX   - Bytes to dump
;          DL   - 128 = Conv, 0 = No Conv
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SampPtr         dd      0
SampleSize      dd      0
TransferSize    dd      0
GUS_DMASampleToDram     Proc    Near
        pushad
        mov     Convert,dl
        mov     SampPtr,ebx
        mov     SampleSize,ecx
NextChunk:
        mov     esi,SampPtr
        mov     edi,DMABuffer
        mov     ecx,GUS_RollOverDataSize
        call    CalcTransferSize
        mov     TransferSize,ecx
        rep     movsb
        mov     SampPtr,esi
        mov     ecx,TransferSize

;       cmp     ecx,SampleSize
;       jb      TransferIt
;       mov     ecx,SampleSize
;TransferIt:
        push    ecx
        mov     ebx,DMABuffer_Phys
        mov     al,01011000b            ;DMA mode register (Write To GUS)
        mov     ah,SoundCard_DMA1       ;Channel number ( 0..7 )
        call    DMA_setup               ;Do it

        mov     eax,SampleOffsetMem
        add     SampleOffsetMem,ecx
        call    Start_GUS_Dma

        mov     ecx,70*2
WaitTC: call    sync
        cmp     DMAPlay_TC,0
        loopz   WaitTC
        jz      TimoutERROR
        mov     DMAPlay_TC,0

        pop     ecx
        sub     SampleSize,ecx
        jnz     NextChunk

        mov     al,041h                 ;Stop DMA
        mov     cl,00000000b            ;Stop IRQ's
        call    GUS_B

        mov     ah,SoundCard_DMA1       ;Channel number ( 0..7 )
        call    DMA_shutdown

        Popad
        Ret
TimoutERROR:

        mov     al,041h                 ;Stop DMA
        mov     cl,00000000b            ;Stop IRQ's
        call    GUS_B

        mov     ah,SoundCard_DMA1       ;Channel number ( 0..7 )
        call    DMA_shutdown

        mov     VolumeRampHit,0
        mov     DMAPlay_TC,0
        mov     ax,TimeOutErr
        jmp     ErrorHandler
GUS_DMASampleToDram  EndP


;in ECX = Requested size
;   SampleOffsetMem=Offset in GUS
;out ECX = Allowed Size
CalcTransferSize:
        push    eax ebx edx
        mov     eax,SampleOffsetMem
        mov     ebx,eax
        shr     ebx,18                  ;Start Bank
        add     eax,ecx
        shr     eax,18                  ;End Bank
        cmp     eax,ebx
        jz      @@Okay

        shl     eax,18
        sub     eax,SampleOffsetMem
        mov     ecx,eax
@@Okay:
        cmp     ecx,SampleSize
        jbe     @@Okay2
        mov     ecx,SampleSize
@@Okay2:
        pop     edx ebx eax
        ret


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Get GUS memory via DMA
; calls:  EAX   - Offset (in DRAM) to get from
;         EBX   - Offset (in memory) to buffer
;         ECX   - Bytes to get
;          DL   - 128 if convert, 0 if not
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GUS_DMASampleFromDRAM   Proc    Near
        pushad
        mov     Convert,dl
        or      Convert,2
;--..--
        mov     edx,ecx
        movzx   ecx,CurrentSample
        mov     cl,[VoiceControl+ecx]
        bt      cx,2
        setc    cl

        push    dx                      ;16 or 8 bits sample transfer
        movzx   dx,cl
        shl     dx,6
        or      Convert,dl
        pop     dx

        shl     edx,cl
        shl     eax,cl
        mov     ecx,edx
;--..--

        mov     SampleOffsetMem,eax
        mov     SampPtr,ebx
        mov     SampleSize,ecx

NextChunk2:
        mov     ecx,GUS_RollOverDataSize
        call    CalcTransferSize
        mov     TransferSize,ecx
;       cmp     ecx,SampleSize
;       jb      TransferIt2
;       mov     ecx,SampleSize
;TransferIt2:
        push    ecx
        mov     ebx,DMABuffer_Phys
        mov     al,01010100b            ;DMA mode register (read)
        mov     ah,SoundCard_DMA1       ;Channel number (0..7)
        call    DMA_setup               ;Do it

        mov     eax,SampleOffsetMem
        call    Start_GUS_Dma

        mov     ecx,70*2
WaitT2: call    sync
        cmp     DMAPlay_TC,0
        loopz   WaitT2
        jz      TimoutERROR
        mov     DMAPlay_TC,0
        pop     ecx


        test    Convert,40h
        jnz     @@Convert16Bits

        push    ecx                     ;Convert 8 Bits
        mov     ah,Convert
        and     ah,128
        mov     edi,SampPtr
        mov     esi,DMABuffer
ConvertGetLoopen:
        lodsb
        xor     al,ah
        stosb
        loop    ConvertGetLoopen
        mov     SampPtr,edi
        pop     ecx
        jmp     @@FinishConcert

@@Convert16Bits:                        ;Convert 16 Bits
        push    ecx edx
        shr     ecx,1
        mov     dh,Convert
        and     dh,128
        mov     edi,SampPtr
        mov     esi,DMABuffer
ConvertGetLoopen2:
        lodsw
        xor     ah,dh
        stosw
        loop    ConvertGetLoopen2
        mov     SampPtr,edi
        pop     edx ecx
@@FinishConcert:

        add     SampleOffsetMem,ecx
        sub     SampleSize,ecx
        jnz     NextChunk2

        mov     al,041h                 ;Stop DMA
        mov     cl,00000000b            ;Stop IRQ's
        call    GUS_B

;****** program the 8237 DMA contollers  *************
;       mov     al,00000100b             ; DMA mode register
;       mov     ah,SoundCard_DMA1          ; Channel number ( 0..7 )
;       call    DMA_setup

        popad
        ret
GUS_DMASampleFromDRAM   EndP

PositionJumpT   dw      -1      ;GUS Clickremoval system
CurrRowT        dw      0
GotoRowT        dw      -1
CurrPositionT   dw      0
PatternOffsetT  dd      0
CommandsT       db      0
ChannelsT       db      0
RowSizeT        dd      0
ChRowSizeT      dd      0

CheckNextRow    Proc    Near
        cmp     SkipClickRemoval,1
        jz      _ret
        pushad
        mov     ax,PositionJump
        mov     PositionJumpT,ax
        mov     ax,GotoRow
        mov     GotoRowT,ax
        mov     ax,CurrRow
        mov     CurrRowT,ax
        mov     ax,CurrPosition
        mov     CurrPositionT,ax
;-------------------------------------
        cmp     GotoRowT,-1             ;Check for Row Jump
        jz      NoRowJumpT
        mov     ax,GotoRowT
        mov     CurrRowT,ax
NoRowJumpT:

        cmp     PositionJumpT,-1        ;Check for Pos Jump
        jz      NoPositionJumpT
        movzx   ecx,PositionJumpT
        mov     CurrPositionT,cx
NoPositionJumpT:
        cmp     GotoRowT,-1
        jnz     YesT
        cmp     PositionJumpT,-1
        jz      No_T
YesT:
        cmp     PatternPlay,0
        jz      NoPattPlayT
        movzx   ebx,CurrPatt2
        call    PattInitT
        jmp     PattPlayT
NoPattPlayT:
        call    PosInitT
PattPlayT:
;       mov     GotoRowT,-1
;       mov     PositionJumpT,-1
        jmp     NewRowT
No_T:
;       mov     GotoRowT,-1
;       mov     PositionJumpT,-1

        movzx   ebx,CurrPatt2
        mov     eax,[AllocTable+ebx*8]
        cmp     eax,0
        jnz     NoEmptyPatt3T
        mov     eax,EmptyPattern
NoEmptyPatt3T:
        movzx   cx,[eax+10]
        inc     CurrRowT
        cmp     CurrRowT,cx
        jbe     OnePatternT
        mov     CurrRowT,0
        cmp     PatternPlay,1           ;If only play one pattern
        jz      OnePatternT
        inc     CurrPositionT
OnePatternT:
        call    PosInitT

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Read Channels ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NewRowT:
        xor     edi,edi
        movzx   ecx,ChannelsT
        mov     esi,PatternOffsetT      ;Get it
UpdateRowsLoopT:
        push    ecx
        push    esi
        cmp     [Mute+edi],1
        jz      NoNote2T
        mov     [RampDownTable+edi],0

        movzx   edx,byte ptr [esi]
;       movzx   ebx,byte ptr [esi]

        and     dx,0feh
        and     dx,7fh          ;Clear KeyOff and Nr Of Commands
        jz      CheckCommandsT
        mov     [RampDownTable+edi],1
CheckCommandsT:

        xor     ebp,ebp
MultipleCommandsT:
        lodsw
        xchg    al,ah           ;Bx=SampNr, Ax=Command, Dx=Note
        and     ah,3fh          ;Clear NOC
        cmp     ah,3
        jz      Noperre
        cmp     ah,5
        jz      NoPerre
        cmp     ah,15h
        jz      NoPerre
        ror     ax,4
        shr     ah,4
        cmp     al,0edh
        jnz     Perre
        cmp     ah,0
        jz      Perre
Noperre:
        mov     [RampDownTable+edi],0
Perre:
        add     ebp,2
        push    ebx
        movzx   ebx,CommandsT
        shl     ebx,1
        cmp     ebp,ebx
        pop     ebx
        jb      MultipleCommandsT

NoNote2T:
        pop     esi
        pop     ecx
        inc     edi
        add     esi,RowSizeT
        loop    UpdateRowsLoopT

        popad
        ret
CheckNextRow    EndP

PosInitT        Proc    Near
        movzx   ebx,CurrPositionT       ;init a new pattern
        cmp     bx,Positions
        jb      NoWorry2T
        mov     ebx,0
        mov     CurrPositionT,0
NoWorry2T:
        shl     ebx,1
        add     ebx,PatternOrderPtr
        movzx   ebx,word ptr [ebx]
PattInitT:
        mov     eax,[AllocTable+ebx*8]
        cmp     eax,0
        jnz     NoEmptyPatt1T
        mov     eax,EmptyPattern
NoEmptyPatt1T:
        mov     PatternOffsetT,eax
        add     PatternOffsetT,12

        movzx   ebx,byte ptr [eax+10]
        inc     ebx

        mov     dl,[eax+11]
        mov     dh,dl
        and     dl,31
        inc     dl
        shr     dh,5
        mov     ChannelsT,dl
        mov     CommandsT,dh

        movzx   ecx,dl          ;Get RowSize and ChRowSize
        movzx   eax,dh
        lea     eax,[eax*2+2]
        mov     RowSizeT,eax
        mul     ecx
        mov     ChRowSizeT,eax

        mov     ax,CurrRowT
        cmp     bx,ax
        ja      NoLenProbbT
        mov     CurrRowT,0
NoLenProbbT:
        movzx   ebx,CurrRowT
        mov     eax,ChRowSizeT
        mul     ebx
        add     PatternOffsetT,eax
        ret
PosInitT    Endp

;calls: ESI=Table to read from
RampDownNeededChannels  Proc    Near
        Pushad
        movzx   ecx,Channels
        xor     edi,edi
RampNextChannel:
        cmp     byte ptr [esi+edi],0
        jz      DontRampDown

        mov     dx,GUS_Voice
        mov     ax,di                   ;Voice #
        out     dx,al

        movzx   ebx,[GUS_OldVolume+edi]
        mov     bx,[Gus_VolTable+ebx*2]
        mov     bp,[Gus_VolTable]
        mov     [GUS_OldVolume+edi],0

        pusha
        mov     al,06h                  ;Set Volume Ramp speed
        mov     cl,00111111b
        call    GUS_B
        call    ramp                    ;Ramp Volume from bx to bp
        popa

DontRampDown:
        inc     edi
        loop    RampNextChannel


        movzx   ecx,Channels
        xor     edi,edi
CheckRampChannel:
        cmp     byte ptr [esi+edi],0
        jz      DontCheckRamp

        mov     dx,GUS_Voice
        mov     ax,di                   ;Voice #
        out     dx,al

        mov     dx,GUS_Command
        mov     al,08dh
        out     dx,al
        add     dx,2
        in      al,dx
        test    al,00000011b
        jz      CheckRampChannel
        mov     byte ptr [esi+edi],0

DontCheckRamp:
        inc     edi
        loop    CheckRampChannel

        popad
        ret
RampDownNeededChannels  EndP

GUS_SetZeroVol     Proc    Near
        Pushad
        cli
        mov     ax,00001011b
        call    GUS_Mixer
        sti
        Popad
        Ret
GUS_SetZeroVol  EndP

GUS_SetOrigVol     Proc    Near
        Pushad
        cli
        mov     ax,00001001b
        call    GUS_Mixer
        sti
        Popad
        Ret
GUS_SetOrigVol  EndP

;Calls: EAX=Volume, EDI=Channel
GUS_SetVolume   Proc    Near
        push    ax
        mov     dx,GUS_Voice
        mov     ax,di                   ;Voice #
        out     dx,al
        pop     ax

        mov     bp,[Gus_VolTable+eax*2]         ;Ramp Volume from bx to bp
        movzx   ecx,[GUS_OldVolume+edi]
        mov     [GUS_OldVolume+edi],al
        mov     bx,[Gus_VolTable+ecx*2]

        sub     ax,cx
        cwd                                     ;ABS
        xor     ax,dx
        sub     ax,dx

        mov     cl,00111111b                    ;Fast
        cmp     ax,20
        ja      SetFastVol
        mov     cl,00001111b                    ;Slow
SetFastVol:

        mov     al,06h                  ;Set Volume Ramp speed
        call    GUS_B
        call    ramp
        ret
GUS_SetVolume   EndP

;edi=chan
GUS_SetTheFreq  Proc    Near
        pushad
        mov     dx,GUS_Voice
        mov     ax,di                   ;Voice #
        out     dx,al

        cmp     LinFreq,1
        jz      GUS_LinearFreq

        movzx   ecx,[CurrNoteTable+edi]
        sub     ecx,2
        ConvertNote ecx ecx

        sub     cx,[VibPeriod+edi*2]             ;428*4*8363*C2
        add     cx,[VibratoTable+edi*2]          ;--------------
        add     cx,[FineTuneTable+edi*2]         ;16*8363*period
        add     ecx,[SlideTable+edi*4]
        jecxz   GUS_EndFreq

        movzx   eax,GUS_Divisor ;(428*C2*1024)/(period*GUS_Divisor)
        mul     ecx
        mov     ebx,eax

        mov     edx,0dh
        mov     eax,0a7790000h            ;428*1024*8363*16
        div     ebx
        mov     si,ax

        mov     dx,GUS_Command
        mov     al,1
        out     dx,al
        inc     dx
        mov     ax,si           ;Frequency! Hertz*1024/GUS_Divisor
        out     dx,ax
GUS_EndFreq:
        popad
        ret


GUS_LinearFreq:
        movzx   ebx,[CurrNoteTable+edi]
        sub     ebx,2

        xor     eax,eax
        sub     ax,[VibPeriod+edi*2]
        add     ax,[VibratoTable+edi*2]
        add     ax,[FineTuneTable+edi*2]
        cwde
        add     eax,[SlideTable+edi*4]
        sar     eax,4
        cdq
        mov     ecx,16
        idiv    ecx
        sub     ebx,eax
        shl     ebx,4
        sub     ebx,edx
        mov     eax,[LinFreqTable+ebx*4]

        movzx   ebx,word ptr [CurrSample+edi*2]
        movzx   ebx,word ptr [SampleRates+ebx*2]
        mul     ebx
        movzx   ebx,GUS_Divisor
        shl     ebx,16
        div     ebx
        mov     si,ax

        mov     dx,GUS_Command
        mov     al,1
        out     dx,al
        inc     dx
        mov     ax,si
        out     dx,ax

        popad
        ret
GUS_SetTheFreq      EndP

GUS_StartTheChannels    Proc    near
        pushad
        movzx   ecx,AllocChannels
        xor     edi,edi
StartChannels:
        btr     KBDPlayFlag,edi
        jc      StartKBD3

        test    [SkipFlag+edi*2],00004h
        jnz     SkipPlayVoice2

StartKBD3:
        movzx   ebx,CurrentSample
        cmp     [CurrSample+edi*2],bx
        jnz     NotLastVoice
        mov     LastVoice,di
NotLastVoice:
        mov     dx,GUS_Voice
        mov     ax,di                   ;Voice #
        out     dx,al

        mov     dx,GUS_Command
        mov     al,0                    ;Voice Control
        out     dx,al
        add     dx,2                    ;105
        mov     al,[PlayInfo+edi]
        out     dx,al                   ;Voice Control Register

SkipPlayVoice2:
        or      [SkipFlag+edi*2],00004h
        inc     edi
        loop    StartChannels
        popad
        ret
GUS_StartTheChannels    EndP

;Calls:  ah=panpot
;        di=channel
GUS_SetPanpot       Proc    Near
        push    eax dx ebx

        push    ax
        mov     dx,GUS_Voice
        mov     ax,di                   ;Voice #
        out     dx,al
        pop     ax

        shr     ah,4
        mov     dx,GUS_Command
        mov     al,0ch
        out     dx,al
        add     dx,2
        mov     al,ah
        cmp     al,7
        ja      NoPPFix
        dec     al
NoPPFix:
        mov     ah,[EnvPanPot+edi]
        shr     ah,4
        sub     ah,8

        add     al,ah
        jg      PanBel1
        mov     al,0
PanBel1:
        cmp     al,15
        jbe     PanBel2
        mov     al,15
PanBel2:
        out     dx,al
        pop     ebx dx eax
        ret
GUS_SetPanpot       EndP

GUS_ClearTheSamples:
        xor     eax,eax
        lea     edi,SampleOffsetStart
        mov     ecx,22*MaxSamples/4
        rep     stosd
        mov     samples,1
        lea     edi,GUS_FreeTable
        mov     ecx,GUS_TableSize
        xor     al,al
        rep     stosb

IF      PLAYER
        mov     ebx,32
        cmp     LoadFXEngine,0
        jz      @@NoFX
ENDIF
        mov     ebx,GUS_RollOverDataSize
        add     ebx,32
@@NoFX:

        mov     eax,GUS_DramSize2
        sub     eax,ebx                         ;1:st byte fix!!!!
        mov     GUS_DramFree,eax
        mov     [GUS_FreeTable+4],eax
        mov     eax,ebx                         ;1:st byte fix!!!!
        mov     SampleOffsetMem,eax
        mov     [GUS_FreeTable],eax


        mov     ebp,1043
        call    MemDisalloc
        mov     ebp,1028
        call    MemDisalloc
        mov     ebp,1029
        call    MemDisalloc
        mov     ebp,1034
        call    MemDisalloc
        ret

;--------------------------------------------------------------- 10
GUS_CMD10:
        push    ax
        mov     dx,GUS_Voice
        mov     ax,di                   ;Voice #
        out     dx,al
        mov     dx,GUS_Command
        mov     al,80h                  ;Voice Control
        out     dx,al
        add     dx,2                    ;105
        in      al,dx
        mov     cl,al
        pop     ax

        cmp     al,2
        ja      _ret
        cmp     al,1
        jz      Backwards
        cmp     al,2
        jz      PingPongOn
        btr     PlayDirection,edi
        jmp     WriteToGUS
Backwards:
        bts     PlayDirection,edi
        jmp     WriteToGUS
PingPongOn:
        test    [VoiceControl+ebx],00001000b
        jz      _ret
        bts     PlayDirection+4,edi
        jmp     WriteToGUS

WriteToGUS:
        xor     ebx,ebx
        and     cl,10101111b
        bt      PlayDirection,edi
        rcl     bl,2
        bt      PlayDirection+4,edi
        rcl     bl,5

        or      cl,bl
        sub     dx,2
        mov     al,0                    ;Voice Control
        out     dx,al
        mov     al,cl
        add     dx,2                    ;105
        out     dx,al
        call    GUS_Delay
;       sub     dx,2
;       mov     al,0                    ;Voice Control
;       out     dx,al
;       add     dx,2                    ;105
;       mov     al,cl
        out     dx,al
        ret

;--------------------------------------------------------------- E8
GUS_CMDE8:
        mov     dx,GUS_Voice
        mov     ax,di                   ;Voice #
        out     dx,al
        movzx   ebx,word ptr [CurrSample+edi*2]

        mov     dx,GUS_Command
        mov     al,04h                  ;End Address HIGH
        out     dx,al
        mov     eax,[SampleOffsetEnd+ebx*4]
        shr     eax,7
        inc     dx                      ;104
        out     dx,ax

        mov     dx,GUS_Command
        mov     al,05h                  ;End Address LOW
        out     dx,al
        mov     eax,[SampleOffsetEnd+ebx*4]
        shl     ax,9
        inc     dx                      ;104
        out     dx,ax

        mov     dx,GUS_Command
        mov     al,80h                  ;Voice Control
        out     dx,al
        add     dx,2                    ;105
        in      al,dx
        and     al,11100111b
        mov     ah,al

        mov     dx,GUS_Command
        mov     al,0                    ;Voice Control
        out     dx,al
        add     dx,2                    ;105
        mov     al,ah
        out     dx,al                   ;Voice Control Register
        ret

Ultrasnd        db      'ULTRASND='
UltraLen        equ      $-ultrasnd


IF TRANVERSION          ;\\
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;                               Read Environment
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;Reads the Environment variables
;
; Calls: None
;
; Out:
; Carry=1 No Variable found
; Carry=0 Variable found
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
AMS_GetGUSEnv   Proc    Near
        pushad
IFNDEF WATCOM
        mov     edi,_pspa
        movzx   edi,word ptr gs:[edi+2Ch] ; Get the Environment segment value
        shl     edi,4
ELSE
        mov     edi,_env
ENDIF
        lea     edx,Ultrasnd
CheckVar:
        mov     cl,UltraLen
        mov     ebx,edx
ScanVar:
        mov     al,byte ptr gs:[edi]
        cmp     al,byte ptr [ebx]
        jnz     SkipVar
        inc     edi
        inc     ebx
        dec     cl
        jnz     ScanVar

        mov     SoundCard,1

        xor     ebx,ebx
        mov     cl,3
GetGUSPort:
        shl     bx,4
        mov     dl,byte ptr gs:[edi]
        inc     edi
        sub     dl,'0'
        or      bl,dl
        dec     cl
        jnz     GetGUSPort

        mov     SoundCard_BasePort,bx
        inc     edi                     ;skip past comma

GetGUSDMA:
        mov     bl,byte ptr gs:[edi]
        sub     bl,'0'
        mov     SoundCard_DMA1,bl
        add     edi,2                   ;skip past comma

        mov     bl,byte ptr gs:[edi]
        sub     bl,'0'
        mov     SoundCard_DMA2,bl
        add     edi,2                   ;skip past comma

GetGUSIRQ:
        cmp     byte ptr gs:[edi+2],','
        jz      GUSIRQ1x
        mov     bl,byte ptr gs:[edi]
        sub     bl,'0'
        mov     SoundCard_IRQ,bl
        add     edi,2
        jmp     GetGUSMIDIIRQ
GUSIRQ1x:
        mov     bl,byte ptr gs:[edi+1]
        sub     bl,'0'
        add     bl,10
        mov     SoundCard_IRQ,bl
        add     edi,3
GetGUSMIDIIRQ:
        cmp     byte ptr gs:[edi+1],0
        jnz     GUSIRQ1x2
        mov     bl,byte ptr gs:[edi]
        sub     bl,'0'
        mov     SoundCard_MIDIIRQ,bl
        jmp     ExitGUS
GUSIRQ1x2:
        mov     bl,byte ptr gs:[edi+1]
        sub     bl,'0'
        add     bl,10
        mov     SoundCard_MIDIIRQ,bl
        jmp     ExitGUS
SkipVar:
        inc     edi                     ;Env space is terminated with "0,0"
        mov     al,gs:[edi]
        cmp     al,0
        jnz     SkipVar
        inc     edi
        mov     al,gs:[edi]
        cmp     al,0
        jnz     CheckVar

        stc
        popad
        ret
ExitGUS:
        clc
        popad
        ret
AMS_GetGUSEnv   EndP
ENDIF                   ;//


IF DOS32VERSION OR PMODEWVERSION        ;\\

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;                               Read Environment
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;Reads the Environment variables
;
; Calls: None
;
; Out:
; Carry=1 No Variable found
; Carry=0 Variable found
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
AMS_GetGUSEnv   Proc    Near

IF	AUTODETECT_SC
        pushad
        mov     edi,_env
        lea     edx,Ultrasnd
CheckVar:
        mov     cl,UltraLen
        mov     ebx,edx
ScanVar:
        mov     al,byte ptr [edi]
        cmp     al,byte ptr [ebx]
        jnz     SkipVar
        inc     edi
        inc     ebx
        dec     cl
        jnz     ScanVar

        mov     SoundCard,1

        xor     ebx,ebx
        mov     cl,3
GetGUSPort:
        shl     bx,4
        mov     dl,byte ptr [edi]
        inc     edi
        sub     dl,'0'
        or      bl,dl
        dec     cl
        jnz     GetGUSPort

        mov     SoundCard_BasePort,bx
        inc     edi                     ;skip past comma

GetGUSDMA:
        mov     bl,byte ptr [edi]
        sub     bl,'0'
        mov     SoundCard_DMA1,bl
        add     edi,2                   ;skip past comma

        mov     bl,byte ptr [edi]
        sub     bl,'0'
        mov     SoundCard_DMA2,bl
        add     edi,2                   ;skip past comma

GetGUSIRQ:
        cmp     byte ptr [edi+2],','
        jz      GUSIRQ1x
        mov     bl,byte ptr [edi]
        sub     bl,'0'
        mov     SoundCard_IRQ,bl
        add     edi,2
        jmp     GetGUSMIDIIRQ
GUSIRQ1x:
        mov     bl,byte ptr [edi+1]
        sub     bl,'0'
        add     bl,10
        mov     SoundCard_IRQ,bl
        add     edi,3
GetGUSMIDIIRQ:
        cmp     byte ptr [edi+1],0
        jnz     GUSIRQ1x2
        mov     bl,byte ptr [edi]
        sub     bl,'0'
        mov     SoundCard_MIDIIRQ,bl
        jmp     ExitGUS
GUSIRQ1x2:
        mov     bl,byte ptr [edi+1]
        sub     bl,'0'
        add     bl,10
        mov     SoundCard_MIDIIRQ,bl
        jmp     ExitGUS
SkipVar:
        inc     edi                     ;Env space is terminated with "0,0"
        mov     al,[edi]
        cmp     al,0
        jnz     SkipVar
        inc     edi
        mov     al,[edi]
        cmp     al,0
        jnz     CheckVar

        stc
        popad
        ret
ExitGUS:
        clc
        popad
ELSE
        stc
ENDIF
        ret
AMS_GetGUSEnv   EndP
ENDIF                   ;//


GUS_TurnOnSoundCard:
        push    ax
        mov     ax,01001001b            ;Turn On
        call    GUS_Mixer
        pop     ax
        ret

GUS_StartTimer      Proc    Near
        pushad

        cmp     IntsOn,1
        jz      SkipTStart

        cmp     TimerSelect,0
        jz      UseThePC

        mov     PC_GUSTimer,1
        call    StartGUSTimer
        jmp     SkipTStart

UseThePC:
        mov     PC_GUSTimer,0
        call    StartInts

SkipTStart:
        mov     IntsOn,1
        popad
        ret
GUS_StartTimer      EndP


GUS_StopTimer       Proc    Near
        pushad
        cmp     IntsOn,0
        jz      SkipTStop

        cmp     PC_GUSTimer,0
        jz      StopThePC

        call    StopGUSTimer
        jmp     SkipTStop

StopThePC:
        call    StopInts
SkipTStop:
        mov     IntsOn,0
        popad
        ret
GUS_StopTimer       EndP


;ax=voice, ebx=sample #
GUS_GetCurrAdd      Proc    Near
        pushad
        mov     dx,GUS_Voice
        out     dx,al
        mov     dx,GUS_Command
        mov     al,8ah
        out     dx,al
        call    GUS_Delay
        inc     dx
        in      ax,dx
        shl     eax,16
        dec     edx
        mov     al,8bh
        out     dx,al
        call    GUS_Delay
        inc     dx
        in      ax,dx
        shr     eax,9
        and     eax,0fffffh

        mov     bl,[VoiceControl+ebx]
        bt      bx,2
        jnc     No16bitTweak2
        mov     ebx,eax
        and     eax,0001ffffh
        and     ebx,000c0000h
        shr     ebx,1
        or      eax,ebx
No16bitTweak2:
        mov     CurrAdd,eax
        popad
        ret
GUS_GetCurrAdd      EndP

;di=Voice
GUS_SetCurrAdd      Proc    Near
        pushad
        mov     ax,di
        mov     dx,GUS_Voice
        out     dx,al
        mov     dx,GUS_Command
        mov     al,0Ah                  ;Current Address HIGH
        out     dx,al
        mov     eax,CurrAdd
        shr     eax,7
        inc     dx                      ;104
        out     dx,ax

        mov     dx,GUS_Command
        mov     al,0bh                  ;Current Address LOW
        out     dx,al
        mov     eax,CurrAdd
        shl     ax,9
        inc     dx                      ;104
        out     dx,ax
        popad
        ret
GUS_SetCurrAdd      EndP


;EDI=Channel
GUS_SetSampleLoop   Proc    Near
        pushad
        movzx   edi,LastVoice
        movzx   ebx,CurrentSample

        mov     dx,GUS_Voice
        mov     ax,di                   ;Voice #
        out     dx,al
        mov     eax,80h                 ;Voice Control
        call    Read_GUS_ByteRegister
        mov     ah,al
        and     ah,00000011b
        jnz     QQ                      ;Not Running

        mov     eax,[LoopEnd+ebx*4]

        call    Convert16Bit
        mov     LoopEnd2,eax

        mov     eax,[LoopStart+ebx*4]
        call    Convert16Bit
        mov     LoopStart2,eax

        cmp     eax,LoopEnd2
        jz      QQ

        mov     dx,GUS_Command
        mov     al,02h                  ;Starting Address HIGH
        out     dx,al
        mov     eax,LoopStart2
        shr     eax,7
        inc     dx                      ;104
        out     dx,ax

        mov     dx,GUS_Command
        mov     al,3h                   ;Starting Address LOW
        out     dx,al
        mov     eax,LoopStart2
        shl     ax,9
        inc     dx                      ;104
        out     dx,ax

        mov     dx,GUS_Command
        mov     al,04h                  ;End Address HIGH
        out     dx,al
        mov     eax,LoopEnd2
        shr     eax,7
        inc     dx                      ;104
        out     dx,ax

        mov     dx,GUS_Command
        mov     al,05h                  ;End Address LOW
        out     dx,al
        mov     eax,LoopEnd2
        shl     ax,9
        inc     dx                      ;104
        out     dx,ax
QQ:     popad
        ret
GUS_SetSampleLoop   EndP


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;                                Sampling part
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

GUS_ChangeSamplingFreq:
IFE     PLAYER
        pushad
        cmp     SoundCard,5
        jnz     @@NoCodec
        call    Ultra16SetFreq          ;Set Rec freq
        popad
        ret

@@NoCodec:
        mov     eax,9878400
        movzx   ebx,SampleFreq
        shl     ebx,4
        xor     edx,edx
        div     ebx
        sub     al,2
        mov     SampleRate,al
        cmp     SampleRate,12
        jae     SampleTryAgain
        mov     SampleRate,12
SampleTryAgain:
        mov     eax,9878400
        movzx   ebx,SampleRate
        add     ebx,2
        shl     ebx,4
        xor     edx,edx
        div     ebx
        mov     GUSSampleFreq,ax

        cmp     SampleFreq,ax
        jb      SampRateOK
        cmp     SampleRate,12
        jz      SampRateOK
        dec     SampleRate
        jmp     SampleTryAgain

SampRateOK:
        mov     dx,GUS_Command
        mov     al,48h          ;Sampling Frequency
        out     dx,al
        mov     dx,GUS_Data_High
        mov     al,SampleRate
        out     dx,al
        popad
ENDIF
        ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Start the ADC, Called at startup (Big Popup on)
; Calls: None
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GUS_StartADC    Proc    Near
IFE     PLAYER
        pushad
        cli

        mov     ah,SoundCard_DMA1       ;Shut down playing DMA
        call    DMA_ShutDown

        mov     ah,SoundCard_DMA2       ;Shut down Rec DMA
        call    DMA_ShutDown

        mov     SamplingBuffOff,0
        mov     DMAPlay_TC,0

        cmp     SoundCard,5
        jnz     NoCodec

        mov     al,SampleBits
        shl     al,7
        mov     SampleConvert,al
        call    Ultra16RecFormat        ;Set Stereo/Mono, 8/16 bits rec
        call    Ultra16RecordData       ;Start recording
        sti
        popad
        ret
NoCodec:
        mov     SampleConvert,128
        mov     ecx,GUS_RollOverDataSize
        shr     ecx,1
        mov     ebx,DMABuffer_Phys
        mov     al,01010100b            ;DMA mode register (read)
        mov     ah,SoundCard_DMA2       ;Channel number ( 0..7 )
        call    DMA_setup               ;Do it

        mov     dx,GUS_Command
        mov     al,49h                  ;Sampling Control Register
        out     dx,al
        mov     dx,GUS_Data_High
        mov     al,Stereo               ;Stereo
        shl     al,1
        or      al,00100001b            ;GO + IRQ Enable
        mov     ah,SoundCard_DMA2       ;8/16 Bits
        and     ah,100b
        or      al,ah
        out     dx,al
        sti
        popad
ENDIF
        ret
GUS_StartADC    EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Stop the ADC, Called at end (Big Popup off)
; Calls: None
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GUS_StopADC     Proc    Near
IFE     PLAYER
        pushad
        cli

        cmp     SoundCard,5
        jnz     @@NoCodec

        call    Ultra16StopRecordDma
        mov     Sampling,0
        mov     DMAPlay_TC,0
        mov     ah,SoundCard_DMA1
        call    DMA_ShutDown
        mov     ah,SoundCard_DMA2
        call    DMA_ShutDown
        sti
        popad
        ret
@@NoCodec:

        mov     dx,GUS_Command
        mov     al,49h          ;Sampling Control Register
        out     dx,al
        mov     dx,GUS_Data_High
        xor     al,al
        out     dx,al

        mov     Sampling,0
        mov     DMAPlay_TC,0
        mov     ah,SoundCard_DMA2
        call    DMA_ShutDown

        sti
        popad
ENDIF
        ret
GUS_StopADC   EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls: None
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GUS_FixStartSample  Proc    Near
IFE     PLAYER
        pushad
        mov     ebx,[AllocTable+1024*8]
        mov     SampPtr,ebx
        mov     ecx,[AllocTable+1024*8+4]
        mov     SampleSize,ecx

        xor     ebp,ebp
SearrchArgain:
        add     ebp,8
        cmp     dword ptr ds:[GUS_FreeTable+ebp],0       ;Get Biggest free GUS chunk.
        jnz     SearrchArgain

        mov     ecx,ds:[GUS_FreeTable+ebp-4]

        cmp     SampleSize,ecx
        jbe     NoProblemosNow
        mov     SampleSize,ecx
NoProblemosNow:
        popad
ENDIF
        ret
GUS_FixStartSample  EndP





;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;                                Codec Code
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

Codec_Base      dw      034Ch

Codec_Addr      dw      0               ;register select
Codec_Data      dw      1               ;loc to read/write data
Codec_Status    dw      2
Codec_PIO       dw      3

Codec_Setup     db      0               ;init bits
Codec_Version   db      0

Image_CodecS    Struc
Playfrq         db      ? ;00h
Recfreq         db      ? ;00h
Lic             db      ? ;00h
Ric             db      ? ;00h
La1ic           db      ? ;80h
Ra1ic           db      ? ;80h
La2ic           db      ? ;80h
Ra2ic           db      ? ;80h
Loc             db      ? ;80h
Roc             db      ? ;80h
Pdfr            db      ? ;20h
Ic              db      ? ;08h
Pc              db      ? ;00h
Ti              db      ? ;00h
Mi              db      ? ;40h  ;Mode 2
Lbc             db      ? ;00h
Pbru            db      ? ;00h
Pbrl            db      ? ;00h
Afei            db      ? ;80h
Afeii           db      ? ;01h
Llic            db      ? ;00h
Rlic            db      ? ;00h
Tlb             db      ? ;00h
Thb             db      ? ;00h
Afs             db      ? ;00h
Mioc            db      ? ;00h
Cdfr            db      ? ;20h
Cbru            db      ? ;00h
Cbrl            db      ? ;00h
EndS

Image_Codec     Image_CodecS <00h,00h,00h,00h,80h,80h,80h,80h,80h,80h,20h,08h,00h,00h,40h,00h,00h,00h,80h,01h,00h,00h,00h,00h,00h,00h,20h,00h,00h>


Ultra16RecTable dw      5510,6620,8000,9600,11025,16000,18900,22050,27420,32000,33075,37800,44100,48000
Ultra16BitsTbl  db         1,  15,   0,  14,    3,    2,    5,    7,    4,    6,   13,    9,   11,   12

AUTOCALIB       equ     08h             ;Auto calibrate
CALIB_IN_PROGRESS       equ      20h    ;Auto calibrate in progress
CAPTURE_ENABLE  equ     02h             ;Capture enable
CAPTURE_IRQ     equ     20h
CD_LEFT_INPUT   equ     04h             ;Left Aux #2 input control
CD_RIGHT_INPUT  equ     05h             ;Right Aux #2 input control
CODEC_INIT      equ     80h             ;CODEC is initializing
CODEC_INT       equ     01h             ;Interrupt status
CODEC_MCE       equ     40h             ;Mode change enable
IFACE_CTRL      equ     09h             ;Interface control
IRQ_ENABLE      equ     02h             ;Interrupt enable
IRQ_STATUS      equ     18h             ;Irq status register
LEFT_LINE_IN    equ     12h             ;Left line input control
MISC_INFO       equ     0ch             ;Miscellaneaous information
MONO_IO_CTRL    equ     1ah             ;Mono input/output control
MUTE_INPUT      equ     80h             ;Mute this input's source
PIN_CTRL        equ     0ah             ;Pin control
PLAYBACK_IRQ    equ     10h
PLAYBACK_ENABLE equ     01h             ;Playback enable
PLAYBK_FORMAT   equ     08h             ;Clock and data format
REC_FORMAT      equ     1ch             ;Record format
REC_LWR_CNT     equ     1fh             ;Record lower count
REC_UPR_CNT     equ     1eh             ;Record upper count
RIGHT_LINE_IN   equ     13h             ;Right line input control
SINGLE_DMA      equ     04h             ;Use single DMA channel
TEST_INIT       equ     0bh             ;Test and initialization
TIMER_IRQ       equ     40h
TYPE_STEREO     equ     10h             ;Stereo mode

Ultra16Init     Proc    Near
IFE     PLAYER
        pushad
        mov     ax,Codec_Base           ;Ultra16Probe
        sub     ax,30ch
        shr     ax,4
        or      al,01000000b            ;Enable Codec
        mov     ah,SoundCard_DMA2       ;Rec DMA
        and     ah,100b
        shl     ah,2
        or      al,ah
        mov     ah,SoundCard_DMA1       ;PlayDMA
        and     ah,100b
        shl     ah,3
        or      al,ah
        mov     Codec_Setup,al
        mov     dx,SoundCard_BasePort   ;Program the interface
        add     dx,106h
        out     dx,al

        mov     dx,Codec_Base           ;clear any pending IRQs
        add     dx,Codec_Status
        in      al,dx
        xor     al,al
        out     dx,al

        mov     ecx,1000
@@WaitInit:
        mov     dx,Codec_Base
        in      al,dx
        and     al,CODEC_INIT
        loopnz  @@WaitInit

        call    Ultra16Revision
        cmp     Codec_Version,1
        jb      @@SkipInit
        cmp     Codec_Version,15
        jae     @@SkipInit

;       or      Image_Codec.Ic,SINGLE_DMA       ;Combine DMA's

        cli
        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,(CODEC_MCE OR IFACE_CTRL)
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,Image_Codec.Ic
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,IFACE_CTRL
        out     dx,al
        sti

@@SkipInit:

        call    Ultra16EnableIrqs       ;Enable IRQ's from Codec

        popad
ENDIF
        ret
Ultra16Init     EndP


Ultra16DeInit   Proc    Near
IFE     PLAYER
        pushad
        cli

        mov     dx,SoundCard_Baseport   ;Gotta clear out MAX DMA latches...
        add     dx,106h
        mov     al,Codec_Setup
        and     al,not 10h
        out     dx,al

        mov     al,Codec_Setup
        out     dx,al

        and     al,not 20h
        out     dx,al

        mov     al,Codec_Setup
        out     dx,al

        call    Ultra16DisableIrqs      ;Disable IRQ's from Codec

        mov     dx,Codec_Base           ;Clear any pending IRQs
        add     dx,Codec_Status
        in      al,dx
        xor     al,al
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,(CODEC_MCE OR IFACE_CTRL)
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,Image_Codec.ic
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,IFACE_CTRL
        out     dx,al

        sti
        popad
ENDIF
        ret
Ultra16DeInit   EndP


Ultra16Revision Proc    Near
IFE     PLAYER
        pushad

        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,MISC_INFO
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,Image_Codec.Mi
        out     dx,al

        in      al,dx
        and     al,0fh
        mov     Codec_Version,al

        popad
ENDIF
        ret
Ultra16Revision EndP

;Stereo On/Off, 8/16 bits recording
Ultra16RecFormat        Proc    Near
IFE     PLAYER
        pushad

        mov     al,Image_Codec.Cdfr     ;isolate the format bits...
        and     al,0fh
        cmp     SampleBits,0
        jz      @@No16Bits
        or      al,040h                 ;16 bit, twos comp, little endian

;       pushad
;       call    sync
;       call    sync
;       mov     dx,Codec_Base
;       add     dx,Codec_Status
;       in      al,dx
;       and     al,CODEC_INT
;       mov     byte ptr dbyte,al
;       call    dbug
;       call    Codec_Handler
;       popad
@@No16Bits:
        cmp     Stereo,0
        jz      @@NoStereo
        or      al,TYPE_STEREO
@@NoStereo:

        call    Wait_mce_cdfr           ;input: al

        popad
ENDIF
        ret
Ultra16RecFormat        EndP


;in al=format
Wait_mce_cdfr   Proc    Near
IFE     PLAYER
        pushad

        mov     Image_codec.cdfr,al

        cli
        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,(CODEC_MCE OR REC_FORMAT)
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,Image_codec.cdfr
        out     dx,al

        in      al,dx                   ;ERRATA SHEETS ...
        in      al,dx                   ;ERRATA SHEETS ...

        mov     dx,Codec_Base           ;Wait till sync is done...
        add     dx,Codec_Addr
@@Again:
        in      al,dx
        and     al,80h
        jnz     @@Again

@@Again2:
        mov     al,REC_FORMAT           ;Turn off the MCE bit
        out     dx,al

        in      al,dx                   ;Need this. outp doesn't always take...
        cmp     al,REC_FORMAT
        jnz     @@Again2

        call    AutoCalibrate

        sti
        popad
ENDIF
        ret
Wait_mce_cdfr   EndP





;in al=format
Wait_mce_pdfr   Proc    Near
IFE     PLAYER
        pushad

        mov     Image_codec.pdfr,al

        cli
        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,(CODEC_MCE OR PLAYBK_FORMAT)
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,Image_codec.pdfr
        out     dx,al

        in      al,dx                   ;ERRATA SHEETS ...
        in      al,dx                   ;ERRATA SHEETS ...

        mov     dx,Codec_Base           ;Wait till sync is done...
        add     dx,Codec_Addr
@@Again:
        in      al,dx
        and     al,80h
        jnz     @@Again

@@Again2:
        mov     al,PLAYBK_FORMAT        ;Turn off the MCE bit
        out     dx,al

        in      al,dx                   ;Need this. outp doesn't always take...
        cmp     al,PLAYBK_FORMAT
        jnz     @@Again2

        call    AutoCalibrate

        sti
        popad
ENDIF
        ret
Wait_mce_pdfr   EndP

AutoCalibrate   Proc    Near
IFE     PLAYER
        pushad
        cli
        ;Now, if in auto calibrate, wait for it to finish
        mov     al,Image_Codec.ic
        and     al,AUTOCALIB
        jz      NoAutoCalib

        mov     dx,Codec_Base
        add     dx,Codec_Addr
@@Again:
        mov     al,TEST_INIT
        out     dx,al

        in      al,dx
        cmp     al,TEST_INIT
        jnz     @@Again


@@Again2:
        mov     dx,Codec_Base
        add     dx,Codec_Data
        in      al,dx
        and     al,CALIB_IN_PROGRESS
        jz      NoAutoCalib

        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,TEST_INIT
        out     dx,al
        jmp     @@Again2

NoAutoCalib:

        sti
        popad
ENDIF
        ret
AutoCalibrate   EndP

;In:  SampleFreq
;Out: GUSSampleFreq,SampleFreq

Ultra16SetFreq  Proc    Near
IFE     PLAYER
        pushad
        mov     al,Image_Codec.pdfr
        and     al,0f0h

        mov     dx,SampleFreq
        mov     ecx,14
        xor     ebx,ebx
@@Again:
        cmp     [Ultra16RecTable+ebx*2],dx
        jae     FoundHertz
        inc     ebx
        loop    @@Again

FoundHertz:
        mov     dx,[Ultra16RecTable+ebx*2]
        mov     GUSSampleFreq,dx

        or      al,[Ultra16BitsTbl+ebx]

        call    Wait_mce_pdfr

        popad
ENDIF
        ret
Ultra16SetFreq  EndP

Ultra16EnableIrqs       Proc    Near
IFE     PLAYER
        pushad
        cli

        mov     dx,Codec_Base                   ;Enable IRQS from CODEC...
        add     dx,Codec_Addr
        mov     al,IRQ_STATUS
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        xor     al,al
        out     dx,al

        mov     dx,Codec_Base                   ;part of clearing IRQ...
        add     dx,Codec_Status
        xor     al,al
        out     dx,al

        mov     Image_Codec.pc,IRQ_ENABLE

        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,PIN_CTRL
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,Image_Codec.pc
        out     dx,al

        sti
        popad
ENDIF
        ret
Ultra16EnableIrqs       EndP

Ultra16DisableIrqs      Proc    Near
IFE     PLAYER
        pushad
        cli

        mov     dx,Codec_Base                   ;Enable IRQS from CODEC...
        add     dx,Codec_Addr
        mov     al,IRQ_STATUS
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        xor     al,al
        out     dx,al

        mov     dx,Codec_Base                   ;part of clearing IRQ...
        add     dx,Codec_Status
        xor     al,al
        out     dx,al

        mov     Image_Codec.pc,NOT IRQ_ENABLE

        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,PIN_CTRL
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,Image_Codec.pc
        out     dx,al

        sti
        popad
ENDIF
        ret
Ultra16DisableIrqs      EndP



Ultra16RecordData       Proc    Near
IFE     PLAYER
        pushad
        cli

;       mov     al,Codec_Setup          ;Enable Codec
;       or      al,01000000b
;       mov     dx,SoundCard_BasePort   ;Program the interface
;       add     dx,106h
;       out     dx,al

        cmp     SampleBits,0
        jz      @@No16Bits
        mov     dx,SoundCard_BasePort   ;Init
        add     dx,106h
        mov     al,Codec_Setup
        mov     ah,al
        and     al,not 10h
        out     dx,al

        mov     al,ah
        out     dx,al
        sti
@@No16Bits:

        mov     ecx,GUS_RollOverDataSize;Ultra16PrimeRecord
        shr     ecx,1
        mov     ebx,DMABuffer_Phys
        mov     al,01000100b            ;DMA mode register (read)
        mov     ah,SoundCard_DMA2       ;Channel number ( 0..7 )
        call    DMA_setup               ;Do it

        mov     al,Image_Codec.cdfr     ;Set up the counts...
        and     al,0E0h                 ;isolate the format bits

        cmp     al,040h                 ;16 bit little endian
        jz      Was
        cmp     al,0C0h                 ;16 bit big endian
        jnz     NotWas
Was:
        shr     ecx,1
        jmp     NotWas2
NotWas:
        cmp     al,0A0h                 ;16 bit ADPCM
        jnz     NotWas2
        shr     ecx,2
        jmp     NotWas3
NotWas2:
        test    Image_codec.cdfr,TYPE_STEREO
        jz      NotWas3
        shr     ecx,1
NotWas3:
        dec     ecx                     ;Send the size to Codec

        cli
        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,REC_LWR_CNT
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,cl
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,REC_UPR_CNT
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,ch
        out     dx,al

        mov     dx,Codec_Base           ;Kick off codec here...
        add     dx,Codec_Addr
        mov     al,(CODEC_MCE OR IFACE_CTRL)
        out     dx,al

        or      Image_Codec.ic,CAPTURE_ENABLE   ;PLAYBACK_ENABLE?

        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,Image_Codec.ic
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,IFACE_CTRL
        out     dx,al
        sti

        popad
ENDIF
        ret
Ultra16RecordData       EndP


Ultra16StopRecordDma    Proc    Near
IFE     PLAYER
        pushad
        cli

        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,(CODEC_MCE OR IFACE_CTRL)
        out     dx,al

        and     Image_Codec.ic,NOT CAPTURE_ENABLE

        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,Image_Codec.ic
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,IFACE_CTRL
        out     dx,al

;       mov     al,Codec_Setup          ;Disable Codec
;       and     al,10111111b
;       mov     dx,SoundCard_BasePort   ;Program the interface
;       add     dx,106h
;       out     dx,al

        sti
        popad
ENDIF
        ret
Ultra16StopRecordDma    EndP


;IN:al=0-> off, al=1->on
Ultra16CDIn     Proc    Near
IFE     PLAYER
        pushad
        cmp     al,1
        jz      @@CDInOn
        or      Image_codec.la2ic,MUTE_INPUT
        or      Image_codec.ra2ic,MUTE_INPUT
        jmp     @@CDCont
@@CDInOn:
        and     Image_codec.la2ic,NOT MUTE_INPUT
        and     Image_codec.ra2ic,NOT MUTE_INPUT
@@CDCont:
        cli

        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,CD_LEFT_INPUT
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,Image_codec.la2ic
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,CD_RIGHT_INPUT
        out     dx,al

        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,Image_codec.ra2ic
        out     dx,al

        sti
        popad
ENDIF
        ret
Ultra16CDIn     EndP


MAX_MicSave     db      0
MAX_RLineSave   db      0
MAX_LLineSave   db      0
MAX_RCDSave     db      0
MAX_LCDSave     db      0
Ultra16_GetVolumes      proc    Near
        pushad
        cli
        mov     dx,Codec_Base           ;Mic
        add     dx,Codec_Addr
        mov     al,MONO_IO_CTRL
        out     dx,al
        mov     dx,Codec_Base
        add     dx,Codec_Data
        in      al,dx
        mov     MAX_MicSave,al

        mov     dx,Codec_Base           ;Right
        add     dx,Codec_Addr
        mov     al,RIGHT_LINE_IN
        out     dx,al
        mov     dx,Codec_Base
        add     dx,Codec_Data
        in      al,dx
        mov     MAX_RLineSave,al

        mov     dx,Codec_Base           ;Left
        add     dx,Codec_Addr
        mov     al,LEFT_LINE_IN
        out     dx,al
        mov     dx,Codec_Base
        add     dx,Codec_Data
        in      al,dx
        mov     MAX_LLineSave,al

        mov     dx,Codec_Base           ;CD Right
        add     dx,Codec_Addr
        mov     al,CD_RIGHT_INPUT
        out     dx,al
        mov     dx,Codec_Base
        add     dx,Codec_Data
        in      al,dx
        mov     MAX_RCDSave,al

        mov     dx,Codec_Base           ;CD Left
        add     dx,Codec_Addr
        mov     al,CD_LEFT_INPUT
        out     dx,al
        mov     dx,Codec_Base
        add     dx,Codec_Data
        in      al,dx
        mov     MAX_LCDSave,al
        popad
        sti
        ret
Ultra16_GetVolumes      EndP

Ultra16_SetVolumes      Proc    Near
        pushad

        mov     bh,MAX_MicSave
        call    Mono_Input_Level

        mov     bl,MAX_RLineSave
        mov     bh,MAX_LLineSave
        call    Stereo_Input_Level

        mov     bl,MAX_RCDSave
        mov     bh,MAX_LCDSave
        call    CD_Input_Level

        popad
        ret
Ultra16_SetVolumes      EndP

;IN: BH=Volume (0-255)
Mono_Input_Level        Proc    Near
IFE     PLAYER
        pushad
        inc     bh
        neg     bh
        shr     bh,4
        and     image_codec.mioc,NOT 0fh
        or      image_codec.mioc,bh

        cli
        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,MONO_IO_CTRL
        out     dx,al
        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,image_codec.mioc
        out     dx,al
        sti
        popad
ENDIF
        ret
Mono_Input_Level        EndP


;IN: BX=Volume (0-255) LLRR
Stereo_Input_Level      Proc    Near
IFE     PLAYER
        pushad
        inc     bh
        inc     bl
        neg     bh
        neg     bl
        shr     bh,3
        shr     bl,3
        and     image_codec.rlic,NOT 01fh       ;Right
        or      image_codec.rlic,bl

        and     image_codec.llic,NOT 01fh       ;Left
        or      image_codec.llic,bh

        cli
        mov     dx,Codec_Base           ;Right
        add     dx,Codec_Addr
        mov     al,RIGHT_LINE_IN
        out     dx,al
        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,image_codec.rlic
        out     dx,al

        mov     dx,Codec_Base           ;Left
        add     dx,Codec_Addr
        mov     al,LEFT_LINE_IN
        out     dx,al
        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,image_codec.llic
        out     dx,al
        sti
        popad
ENDIF
        ret
Stereo_Input_Level      EndP

;IN: BX=Volume (0-255) LLRR
CD_Input_Level  Proc    Near
IFE     PLAYER
        pushad
        inc     bh
        inc     bl
        neg     bh
        neg     bl
        shr     bh,3
        shr     bl,3
        and     image_codec.ra2ic,NOT 01fh      ;Right
        or      image_codec.ra2ic,bl

        and     image_codec.la2ic,NOT 01fh      ;Left
        or      image_codec.la2ic,bh

        cli
        mov     dx,Codec_Base           ;Right
        add     dx,Codec_Addr
        mov     al,CD_RIGHT_INPUT
        out     dx,al
        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,image_codec.ra2ic
        out     dx,al

        mov     dx,Codec_Base           ;Left
        add     dx,Codec_Addr
        mov     al,CD_LEFT_INPUT
        out     dx,al
        mov     dx,Codec_Base
        add     dx,Codec_Data
        mov     al,image_codec.la2ic
        out     dx,al
        sti
        popad
ENDIF
        ret
CD_Input_Level  EndP

MAXsnd  db      'ULTRA16='
MAXLen  equ      $-MAXsnd

IF TRANVERSION          ;\\
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;                               Read Environment
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;Reads the Environment variables
;
; Calls: None
;
; Out:
; Carry=1 No Variable found
; Caryy=0 Variable found
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
AMS_GetMAXEnv   Proc    Near
        pushad
        mov     edi,_pspa
        movzx   edi,word ptr gs:[edi+2Ch] ; Get the Environment segment value
        shl     edi,4
        lea     edx,MAXsnd
@@CheckVar:
        mov     cl,MAXLen
        mov     ebx,edx
@@ScanVar:
        mov     al,byte ptr [edi]
        cmp     al,byte ptr [ebx]
        jnz     @@SkipVar
        inc     edi
        inc     ebx
        dec     cl
        jnz     @@ScanVar

        xor     ebx,ebx
        xor     edx,edx
        mov     cl,3
GetMAXPort:
        shl     bx,4
        mov     dl,byte ptr [edi]
        inc     edi
        sub     dl,'0'
        cmp     dl,9
        jb      @@YeahYeah
        sub     dl,7
@@YeahYeah:
        or      bl,dl
        dec     cl
        jnz     GetMAXPort
        mov     Codec_Base,bx
        jmp     ExitMAX

@@SkipVar:
        inc     edi                     ;Env space is terminated with "0,0"
        mov     al,[edi]
        cmp     al,0
        jnz     @@SkipVar
        inc     edi
        mov     al,[edi]
        cmp     al,0
        jnz     @@CheckVar

        stc
        popad
        ret
ExitMAX:
        mov     SoundCard,5
        clc
        popad
        ret
AMS_GetMAXEnv   EndP
ENDIF                   ;//



IF DOS32VERSION OR PMODEWVERSION                ;\\
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;                               Read Environment
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;Reads the Environment variables
;
; Calls: None
;
; Out:
; Carry=1 No Variable found
; Carry=0 Variable found
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
AMS_GetMAXEnv   Proc    Near
IF	AUTODETECT_SC
        pushad
        mov     edi,_env
        lea     edx,MAXsnd
@@CheckVar:
        mov     cl,MAXLen
        mov     ebx,edx
@@ScanVar:
        mov     al,byte ptr [edi]
        cmp     al,byte ptr [ebx]
        jnz     @@SkipVar
        inc     edi
        inc     ebx
        dec     cl
        jnz     @@ScanVar

        xor     ebx,ebx
        xor     edx,edx
        mov     cl,3
GetMAXPort:
        shl     bx,4
        mov     dl,byte ptr [edi]
        inc     edi
        sub     dl,'0'
        cmp     dl,9
        jb      @@YeahYeah
        sub     dl,7
@@YeahYeah:
        or      bl,dl
        dec     cl
        jnz     GetMAXPort
        mov     Codec_Base,bx
        jmp     ExitMAX

@@SkipVar:
        inc     edi                     ;Env space is terminated with "0,0"
        mov     al,[edi]
        cmp     al,0
        jnz     @@SkipVar
        inc     edi
        mov     al,[edi]
        cmp     al,0
        jnz     @@CheckVar

        stc
        popad
        ret
ExitMAX:
        mov     SoundCard,5
        clc
        popad
ELSE
        stc
ENDIF
        ret
AMS_GetMAXEnv   EndP
ENDIF                   ;//


;cl=8 - Looping On, cl=0 - Looping Off
LoopMode        Proc    Near
        pushad
        mov     dx,GUS_Command          ;Read
        mov     al,80h                  ;Voice Control
        out     dx,al
        add     dx,2                    ;105
        in      al,dx
        and     al,not 8
        or      al,cl
        mov     ah,al

        mov     dx,GUS_Command          ;Write
        mov     al,0                    ;Voice Control
        out     dx,al
        add     dx,2                    ;105
        mov     al,ah
        out     dx,al
        popad
        ret
LoopMode        EndP


;eax=offset in GUS
;ecx=bytes to transfer
PadWord dw      0
MoveRollOverSample      Proc    Near
        cmp     RollSize,0
        jz      _ret
        pushad
        push    eax
        mov     ebx,ecx
        mov     edi,DMABuffer

        pushad                          ;Clear DMA Buffer
        mov     al,0
        rep     stosb
        popad

        mov     esi,RollPtr
        cmp     ecx,RollSize
        jbe     @@Okay
        mov     ecx,RollSize
@@Okay:
        mov     LastRollPos,ecx
        add     LastRollPos,eax

        sub     RollSize,ecx
        add     RollPtr,ecx
        push    ecx
        rep     movsb
        pop     ecx

        cmp     RollPos,0
        jz      WritePad
        mov     esi,DMABuffer
        mov     ax,[esi]
        mov     PadWord,ax
        jmp     SkipPad
WritePad:
        mov     edi,DMABuffer
        mov     ax,PadWord
        mov     [edi+8192],ax
        add     ecx,2
SkipPad:
        mov     ebx,DMABuffer_Phys
        mov     al,01011000b            ;DMA mode register (Write To GUS)
        mov     ah,SoundCard_DMA1       ;Channel number ( 0..7 )
        call    DMA_setup               ;Do it

        mov     al,RollConvert
        mov     Convert,al
        pop     eax
        call    Start_GUS_DMA

;       xor     bx,bx                   ;Extend buffer
;       xor     cx,cx
;       call    GUS_Peek

;       xor     bx,bx
;       mov     cx,16384
;       call    GUS_Poke

;       xor     bx,bx
;       mov     cx,1
;       call    GUS_Peek

;       xor     bx,bx
;       mov     cx,16385
;       call    GUS_Poke

        popad
        ret
MoveRollOverSample      EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Calls:
;
;eax=RollBits
;bl =RollNote
;ecx=RollSize
;edx=C4 Rate
;esi=RollPtr
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
EnableWaveIRQ           db      0
RollPtr                 dd      0               ;Ptr to speech sample
RollSize                dd      0               ;Size of SpeechSample
RollSampPos             dd      8192,0
RollPos                 dd      0
RollBits                dd      0               ;1=16 bits sample
RollNote                db      0
RollHitCounter          dd      -1              ;Nr of 8k blocks
TmpRollHitCounter       dd      0
RollConvert             db      0

Speech_C4Rate           dw      0
GUS_SpeechEngine        Proc    Near
IF      PLAYER
        cmp     LoadFXEngine,0                  ;If not installed
        jz      _ret
ENDIF

        call    GUS_StopSpeech

        mov     RollOverPos,8192
        mov     Speech_C4Rate,dx

        pushad
        mov     RollSize,ecx
        mov     RollPtr,esi
        mov     RollBits,eax
        mov     RollNote,bl
        mov     RollConvert,0
        mov     eax,ecx
        shr     eax,13
        mov     TmpRollHitCounter,eax

        mov     eax,RollBits            ;11000000b if 16 bit conversion
        shl     al,6
        or      RollConvert,al

;       mov     ah,SoundCard_DMA1       ;Channel number ( 0..7 )
;       call    DMA_ShutDown

;       mov     ah,SoundCard_DMA2       ;Channel number ( 0..7 )
;       call    DMA_ShutDown

        movzx   di,AllocChannels
        dec     di
        mov     CurrAdd,0
        call    GUS_SetCurrAdd

        mov     DMAPlay_TC,0
        mov     eax,0                           ;Offset In GUS
        mov     ecx,8192                        ;Fill whole buffer 1:st time
        mov     RollPos,1
        call    MoveRollOverSample

        mov     ecx,70*2                        ;Wait for finish
@@Wait: call    sync
        cmp     DMAPlay_TC,0
        loopz   @@Wait
        mov     DMAPlay_TC,0

        mov     eax,8192
        mov     ecx,8192
        mov     RollPos,0
        call    MoveRollOverSample

        cmp     TmpRollHitCounter,0
        jnz     NotSmall
        mov     eax,LastRollPos
        mov     RollOverPos,eax
NotSmall:
        mov     ebx,1                           ;Use Sample nr 1

        mov     eax,RollBits
        shl     al,2
                  ;-d-bl6--
        or      al,00001000b
        mov     [VoiceControl+ebx],al

        mov     [SampleOffsetStart+ebx*4],0
        mov     [LoopStart+ebx*4],0
        mov     eax,16384
        mov     ecx,RollBits
        shr     eax,cl
        mov     [SampleOffsetEnd+ebx*4],eax
        mov     [LoopEnd+ebx*4],eax
        mov     ax,Speech_C4Rate
        mov     [SampleRates+ebx*2],ax
        mov     [Volumes+ebx],127

        mov     edi,3                           ;Chan 0-3
        mov     al,70h                          ;Pan
        mov     ah,RollNote                     ;Note
        mov     cl,127                          ;Vol
        call    FXEngine

        mov     eax,TmpRollHitCounter
        mov     RollHitCounter,eax

        popad
        ret
GUS_SpeechEngine        EndP

LastRollPos     dd      0
RollOverPos     dd      8192
PollRollOverPos Proc    Near
        cmp     RollHitCounter,0
        jl      _ret
        mov     ecx,RollOverPos
        movzx   eax,AllocChannels
        dec     eax
        mov     ebx,1
        call    GetCurrAdd

        push    ecx
        mov     ecx,RollBits
        shl     CurrAdd,cl
        pop     ecx

        cmp     RollPos,0
        jz      Firstpart
        cmp     CurrAdd,ecx
        ja      NoHit
        jmp     Hit
Firstpart:
        cmp     CurrAdd,ecx
        jb      NoHit
Hit:
        dec     RollHitCounter
        jg      NoLastTime
;       jl      StopTheShit
        call    LoopModeOff
        mov     eax,LastRollPos         ;Play Last Part
        call    SetEndAddress
;       mov     RollOverPos,eax
        mov     RollHitCounter,-1
;       mov     RollPos,0
        mov     DMAPlay_TC,0
        ret
;StopTheShit:
;       movzx   ecx,AllocChannels
;       call    StopOneVoice

;       mov     DMAPlay_TC,0
;       mov     ah,SoundCard_DMA1       ;Channel number ( 0..7 )
;       call    DMA_ShutDown

;       ret
NoLastTime:
        xor     RollPos,1
        mov     eax,RollPos
        mov     ecx,8192
        mov     eax,[RollSampPos+eax*4]
        call    MoveRollOverSample

NoHit:
        ret
PollRollOverPos EndP

GUS_StopSpeech  Proc    Near
        pushad
        mov     RollHitCounter,-1
        mov     ah,SoundCard_DMA1       ;Channel number ( 0..7 )
        call    DMA_ShutDown
        mov     DMAPlay_TC,0
        movzx   ecx,AllocChannels
        call    StopOneVoice
        popad
        ret
GUS_StopSpeech  EndP

GUS_CheckSpeech Proc    Near
        pushad
        cmp     RollHitCounter,-1
        jnz     _Retp_clc
        jmp     _Retp_stc
GUS_CheckSpeech EndP

_Retp_clc:
        popad
        clc
        ret
_Retp_stc:
        popad
        stc
        ret

LoopModeOff     Proc    Near
        pushad
        movzx   eax,AllocChannels       ;Voice #
        dec     eax
        mov     dx,GUS_Voice
        out     dx,al

        mov     dx,GUS_Command          ;Read
        mov     al,80h                  ;Voice Control
        out     dx,al
        add     dx,2                    ;105
        in      al,dx
        and     al,not 8
        mov     ah,al

        mov     dx,GUS_Command          ;Write
        mov     al,0                    ;Voice Control
        out     dx,al
        add     dx,2                    ;105
        mov     al,ah
        out     dx,al
        popad
        ret
LoopModeOff     EndP

;eax=end addy
SetEndAddress   Proc    Near
        pushad
        mov     ebx,eax
        mov     ecx,RollBits
        shr     ebx,cl

        movzx   eax,AllocChannels       ;Voice #
        dec     eax
        mov     dx,GUS_Voice
        out     dx,al

        mov     dx,GUS_Command
        mov     al,04h                  ;End Address HIGH
        out     dx,al
        mov     eax,ebx
        shr     eax,7
        inc     dx                      ;104
        out     dx,ax

        mov     dx,GUS_Command
        mov     al,05h                  ;End Address LOW
        out     dx,al
        mov     eax,ebx
        shl     ax,9
        inc     dx                      ;104
        out     dx,ax
        popad
        ret
SetEndAddress   EndP

comment %
TestCODEC:
        pushad
        mov     dx,Codec_Base
        add     dx,Codec_Addr
        mov     al,24
        out     dx,al
        mov     dx,Codec_Base
        add     dx,Codec_Data
        in      al,dx
        and     eax,0ffh
        mov     dbyte,eax
        mov     dnumber,1
        call    dbug
        popad
        ret
%

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²


