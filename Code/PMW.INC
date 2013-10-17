Global	_Closefile:Near,_Createfile:Near,_CreateHiddenfile:Near
Global	_OpenfileW:Near,_OpenfileR:Near,_Deletefile:Near,_Lseekfile:Near,_Filesize:Near
Global	_Readfile:Near,_Writefile:Near,_Filecopy:Near,_Findfile:Near,_renfile:Near

Global	_getlomem:near,_gethimem:near
Global	_himemsize:near,_ret:near,_exit:near,_getirqmask:near
Global	_setirqmask:near,_rmpmirqset:near,_rmpmirqfree:near
Global  _setirqvect:near,_getirqvect:near
Global	SetupSystem:Near
Global	_seldata:word,_selzero:word,_code32a:dword,_pspa:dword,_Env:Dword,_gssave:word
Global  _DTA:Dword,DTABuffer:byte:128

Global  FileHandle:Word

; Convert physical pointer to realative pointer
Move    macro	reg, ptr
	mov	&reg,&ptr
	sub	&reg,_code32a
endm