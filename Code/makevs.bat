Echo.
Echo.
Echo **  Velvet Studio 2.01 **
Echo.
Echo.

choice **  Do you want to create the data file TRACKPIC.PRO? **
if errorlevel 2	goto nothanx
call picspro
move data\trackpic.pro .\ <data\yes
:nothanx

TASMX /m /q amsplay
TASMX /m /q Procs
TASMX /kh10000 /m /q /n Tracker /dRelease=1 /dMakeEXE=1

wlink system pmodew file ..\pmode\io_pmw,amsplay,tracker,procs name vs
rem pmwlite vs.exe
rem pmwsetup /L4095 vs.exe

copy /b vs.exe+trackpic.pro
