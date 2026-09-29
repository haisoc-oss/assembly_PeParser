.586
.MODEL  Flat,StdCall
OPTION  CaseMap:None
.stack 4096
ExitProcess PROTO,dwExitCode:DWORD

include C:\masm32\include\windows.inc 
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
include C:\Users\Acer-PC\Downloads\Irvine32-master\Irvine32.inc

includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\user32.lib
includelib C:\Users\Acer-PC\Downloads\Irvine32-master\Irvine32.lib
includelib C:\Users\Acer-PC\Downloads\Irvine32-master\Kernel32.Lib

.data
Increaste_to_save DWORD 0
Increse_amount DWORD 0
count DWORD 0
buffer DWORD 0
FileName BYTE "C:\\Users\\Acer-PC\\Downloads\\user32\\user32.dll",0
fileHande DWORD ?
save_esi DWord ?
save_esi_for_function DWord ?
tao_hua_day_la_lan_cuoi_can_1_bien_de_luu_esi DWord ?
tao_hua_day_la_lan_cuoi_can_1_bien_de_luu_esi_p2 DWord ?

byte_de_den_section_header = 0F8h

e_lfanew_location DWORD 1 dup (?)
e_lfanew DWORD ?
e_lfanew_Length = 500

section_header DWORD 25 dup (?)
section_header_location DWORD ?

Virtual_address_section DWORD 10 dup (?)
Virtual_size_section DWORD 10 dup (?)
Virtual_address_section_end DWORD ?


Raw_address_section DWORD 10 dup (?)
Raw_size_section DWORD 10 dup (?)
Raw_address_section_end DWORD ?

Import_Directory_RVA DWORD ?
Export_Directory_RVA DWORD ?

Nemo_location DWORD ?
Nemo_location_ss2 DWORD 0
Nemo_location_ss3_for_Name DWORD 0

Value_of_Import_directory DWORD 500 dup (?)
Value_of_Export_directory DWORD 28 dup (?)

List_of_RVA_to_OFT DWORD  500 dup (?)
List_of_RVA_To_DLL_Name DWORD 500 dup (?)
List_of_RVA_to_IAT DWORD 500 dup (?)

RVA_offset_function  DWORD 500 dup (?)
Raw_offset_DLL_Name DWORD 500 dup (?)
Raw_offset_function_name DWORD 500 dup (?)

Store_Hint WORD 500 dup (?)

Store_name_of_this_DLL byte 500 dup (?)
Store_value_of_EAT DWORD ?
Store_value_of_EOT_Before WORD 2000 dup(?)
Store_value_of_EOT_After WORD 2000 dup(?)
Store_value_of_ENT_Before DWORD 2000 dup(?)
Store_value_of_ENT_After DWORD 2000 dup(?)
Store_value_of_Number_Of_name DWORD ?
Store_value_of_Number_Of_function DWORD ?
store_value_of_Base DWORD ?
store_RAW_OFFSET_of_export_function_name BYTE 50 dup(?)

Save_RVA_for_export_ENT DWORD ?

Raw_offset_of_each_entry_in_EAT DWORD ?
Does_this_MF_have_Name DWORD ?

Name_of_this_DLL byte "Name of this DLL: ",0
DLL_name_mess byte "*",0
splite_mess byte "*********************" ,0
OFT_mess byte "	OriginalFirstThunk (Import Lookup Table - ILT): ",0
IAT_mess byte "	FirstThunk (Import Address Table - IAT): ",0
Entry_mess byte "	Entry:",0
Fun_name_mess byte "		Function name: ",0
Function_RVA_mess byte "		RVA: ",0
Hin_mess byte "		Hint: ",0
Export_table_format byte "Ordinal		Funciont_RVA		Name_Ordinal		Name					Forwarder",0
Margin byte "	",


.code

main PROC
	push 0
	push FILE_ATTRIBUTE_NORMAL
	push OPEN_EXISTING
	push 0
	push 0
	push GENERIC_READ 
	push offset FileName
	call CreateFile

	mov fileHande ,eax

	push 500
	push offset e_lfanew_location					;value store value of e_lfanew
	push 3Ch										; location that we need to found e_lfanew_location (raw offset)
	call Moving_dory
	

	mov eax ,e_lfanew_location[0]
	mov e_lfanew , eax ; luu gia tri cua e_lfanew

	ADD eax ,byte_de_den_section_header
	mov section_header_location ,eax

	
	push 500
	push offset section_header				;value store value of section_header
	push section_header_location			; location that we need to found section_header (raw offset)
	call Moving_dory


	;vong lap de xac dinh vi tri va dung luong cua cac section
	mov esi,2
	create_section_list:
		mov eax , section_header[esi*4]
		mov save_esi , esi
		sub esi ,2
		sub esi , Increse_amount
 		add esi ,Increaste_to_save
		mov Virtual_size_section[esi*4] ,eax
		mov esi,save_esi

		inc esi
		mov eax , section_header[esi*4]
		mov save_esi , esi
		sub esi ,3
		sub esi , Increse_amount
		add esi ,Increaste_to_save
		mov Virtual_address_section[esi*4] ,eax 
		mov esi,save_esi

		inc esi
		mov eax , section_header[esi*4]
		mov save_esi , esi
		sub esi, 4
	    sub esi , Increse_amount
		add esi ,Increaste_to_save
		mov Raw_size_section[esi*4] ,eax
		mov esi,save_esi


		inc esi
		mov eax , section_header[esi*4]
		mov save_esi , esi
		sub esi ,5
		sub esi , Increse_amount
		add esi ,Increaste_to_save
		mov Raw_address_section[esi*4] ,eax
		mov esi,save_esi

	inc Increaste_to_save
	inc count
	add Increse_amount ,10
	add esi , 10
	sub esi ,3
	cmp count ,6
	jne create_section_list

	mov eax ,e_lfanew
	add eax ,080h

	; move pointer to RVA of import directory
	push FILE_BEGIN
	push 0
	push eax									 ; location store the RVA of import directory
	push fileHande
	call SetFilePointer

	; read RVA of import directory
	push 0
	push offset buffer
	push 4
	push offset Import_Directory_RVA 
	push fileHande
	call ReadFile

	push Import_Directory_RVA					;call Finding_Nemo to find raw offset of import directory
	call Finding_Nemo

	push 500
	push offset Value_of_Import_directory					;value store value of Import_directory	
	push Nemo_location										; location that we need to found Import_directory value (raw offset)
	call Moving_dory

	mov esi,0
	mov Increse_amount,0
	mov Increaste_to_save,0
	Find_OFT_NAME_IAT_of_DLL:
		mov count,0

		mov eax , Value_of_Import_directory[esi*4] ; take Value_of_Import_directory and save to eax
		mov save_esi , esi 
		sub esi , Increse_amount
		add esi ,Increaste_to_save
		mov List_of_RVA_to_OFT[esi*4] ,eax ; save Value_of_Import_directory to List_of_RVA_to_OFT
		cmp eax ,0						   ; check if the first element Import_directory arrray is null or not , if it is nul , inc count 1
		jne NULL1						   ;purpose is to check if this is the last element of Import directory array or not, (last value of Import directory is null)
		inc count
NULL1:	mov esi,save_esi
		

		inc esi												
		inc esi
		inc esi
		mov eax , Value_of_Import_directory[esi*4]
		mov save_esi , esi
		sub esi ,3
		sub esi , Increse_amount
		add esi ,Increaste_to_save
		mov List_of_RVA_To_DLL_Name[esi*4] ,eax
		cmp eax ,0										; check part 2
		jne NULL2
		inc count
NULL2:	mov esi,save_esi
		

		inc esi
		mov eax , Value_of_Import_directory[esi*4]
		mov save_esi , esi
		sub esi, 4
	    sub esi , Increse_amount
		add esi ,Increaste_to_save
		mov List_of_RVA_to_IAT[esi*4] ,eax
		cmp eax ,0										; check part 3
		jne NULL3
		inc count
NULL3:	mov esi,save_esi


	inc Increaste_to_save
	add Increse_amount ,5
	add esi, 5
	sub esi,4
	mov save_esi,esi
	cmp count , 3					; if count =3 mean all three value is NULL , is it end of Import_directory -> break
	jne Find_OFT_NAME_IAT_of_DLL

	mov esi,0
	mov save_esi,0
	prinf_DLL_name_loop:
		mov esi ,save_esi
		mov eax,List_of_RVA_To_DLL_Name[esi*4]		
		push List_of_RVA_To_DLL_Name[esi*4]						;find raw offset location of each DLL name 
		call Finding_Nemo
		
		push 500
		push offset Raw_offset_DLL_Name							;value store value of each DLL_name	
		push Nemo_location										;location that we need to found each DLL_name (raw offset)
		call Moving_dory

		mov edx ,offset DLL_name_mess
		call WriteString

		mov edx , offset Raw_offset_DLL_Name					;print DLL name (import dll)
		call WriteString
		call Crlf

		mov edx , offset OFT_mess
		call WriteString
		mov eax , List_of_RVA_to_OFT[esi*4]
		call WriteHex
		call Crlf


		mov edx , offset IAT_mess
		call WriteString
		mov eax , List_of_RVA_to_IAT[esi*4]
		call WriteHex

		call Crlf
		call Crlf
		call Crlf

		mov eax, List_of_RVA_to_OFT[esi*4]
		push  List_of_RVA_to_OFT[esi*4]
		call Finding_Nemo

		push 500
		push offset RVA_offset_function
		push Nemo_location
		call Moving_dory
		
		mov save_esi ,esi
		mov esi ,0
		print_function_of_DLL:	
			mov edx ,offset Entry_mess
			call WriteString
			call Crlf

			push RVA_offset_function[esi*4]
			mov save_esi_for_function ,esi			; this "save_esi_for_function" because Finding_Nemo function mov the save_esi back to esi , and because save_esi always =1 make esi wrong , so need another save to save esi before and after call Finding_Nemo
			call Finding_Nemo
			mov esi, save_esi_for_function

			mov eax ,Nemo_location
			add eax , 02h

			push 50
			push offset Raw_offset_function_name
			push eax
			call Moving_dory

			mov edx , offset Fun_name_mess
			call WriteString

			mov edx, offset Raw_offset_function_name
			call WriteString
			call Crlf

			push 500
			push offset Store_Hint
			push Nemo_location
			call Moving_dory

			mov edx , offset Hin_mess
			call WriteString
			mov eax ,0
			mov  ax, Store_Hint[0]
			call WriteHex
			call Crlf

			mov edx, offset Function_RVA_mess
			call WriteString

			mov eax ,RVA_offset_function[esi*4]
			call WriteHex
			call Crlf
			call Crlf


			inc esi
			cmp RVA_offset_function[esi*4],0
			jne print_function_of_DLL
		mov esi ,save_esi

	mov edx, offset splite_mess
	call WriteString
	call Crlf


	inc esi
	mov save_esi ,esi
	inc esi
	cmp List_of_RVA_To_DLL_Name[esi*4],0
	jne prinf_DLL_name_loop


	;------------------------------------------------------------------------------------------------------
	;parse export

	mov eax ,e_lfanew
	add eax ,078h

	; move pointer to RVA of export directory
	push FILE_BEGIN
	push 0
	push eax  ; location store the RVA of export directory
	push fileHande
	call SetFilePointer

	; read RVA of import directory
	push 0
	push offset buffer
	push 4
	push offset Export_Directory_RVA 
	push fileHande
	call ReadFile

	push Export_Directory_RVA		;call Finding_Nemo to find raw offset of import directory
	call Finding_Nemo

	add Nemo_location, 0Ch

	push 500
	push offset Value_of_Export_directory					;value store value of Export_directory	
	push Nemo_location										; location that we need to found Export_directory value (raw offset)
	call Moving_dory

	push Value_of_Export_directory[0]						;Find offset of this DLL name
	call Finding_Nemo

	push 500
	push offset Store_name_of_this_DLL						;Read this DLL name
	push Nemo_location
	call Moving_dory

	mov edx , offset Name_of_this_DLL 
	call WriteString

	mov edx, offset Store_name_of_this_DLL 
	call WriteString
	call Crlf

	mov edx , offset Export_table_format
	call WriteString
	call Crlf

	mov eax , Value_of_Export_directory[4]					;take Base
	mov store_value_of_Base ,eax

	mov eax , Value_of_Export_directory[8]					;take number_of_function
	mov Store_value_of_Number_Of_function ,eax

	mov eax , Value_of_Export_directory[12]					;take number_of_name
	mov Store_value_of_Number_Of_name,eax
	call VCL_sao_khong_sap_xep_tu_dau						; sap xep lai EOT

	push Value_of_Export_directory[16]						;Find offset EAT
	call Finding_Nemo
	
	mov eax ,Nemo_location
	mov Nemo_location_ss2,eax
	

	mov esi,0
	mov save_esi,0
	mov save_esi_for_function ,0
	mov Does_this_MF_have_Name,0
	Print_export_table:
		mov eax , store_value_of_Base
		call WriteHex

		push 10
		push offset Store_value_of_EAT							;read offset of EAT
		push Nemo_location_ss2
		call Moving_dory
		
		mov edx ,offset Margin
		call WriteString

		mov eax , Store_value_of_EAT
		call WriteHex
		

		push Does_this_MF_have_Name
		call Dose_this_mother_F_have_name_check

		add Nemo_location_ss2,04h
		inc esi
		inc Does_this_MF_have_Name
		inc store_value_of_Base
		cmp Store_value_of_Number_Of_function, esi
		jne Print_export_table
	
	

		

	invoke ExitProcess,0

main endp








Finding_Nemo proc Nemo: DWORD  ; function use to convert RVA to raw offset
	mov esi ,0
	find_nemo:
		mov eax ,Virtual_address_section[esi*4]
		add eax , Virtual_size_section[esi*4]
		inc esi
		cmp eax ,Nemo
		jl find_nemo	

	dec esi
	mov eax ,Virtual_address_section[esi*4]
	sub Nemo ,eax
	mov eax , Raw_address_section[esi*4]
	add Nemo ,eax
	mov eax , Nemo 
	mov Nemo_location ,eax
	mov esi,save_esi				;doan nay gay ra 1 so van di co 1 so ham cx sd esi trong khi goi Finding_Nemo , gay ra roi loan esi
		ret
Finding_Nemo ENDP

Moving_dory proc Nemo_Location: DWORD, pstore_value: DWORD, Byte_Read: DWORD
		push FILE_BEGIN
		push 0
		push Nemo_Location  ; location store value of import directory
		push fileHande
		call SetFilePointer

		; read value import directory
		push 0
		push offset buffer
		push Byte_Read
		push pstore_value 
		push fileHande
		call ReadFile
		ret
Moving_dory ENDP

VCL_sao_khong_sap_xep_tu_dau proc
	push Value_of_Export_directory[24]						;Find offset EAT
	call Finding_Nemo

	push 2000
	push offset Store_value_of_EOT_Before						;read offset of EAT
	push Nemo_location
	call Moving_dory

	push Value_of_Export_directory[20]						;Find offset ENT
	call Finding_Nemo
	
	push 4000
	push offset Store_value_of_ENT_Before					;read value of ENT
	push Nemo_location
	call Moving_dory



	mov esi,0
	mov count,0
	mov ebx,0
	VCL_lai_den_luot_tao_sap_xep:
		mov eax,0
		mov bx, Store_value_of_EOT_Before[esi*2]
		mov ecx ,Store_value_of_ENT_Before[esi*4]
		inc esi
		mov save_esi ,esi
		find_smallest:
			cmp Store_value_of_Number_Of_name,esi
			je done
			cmp bx , Store_value_of_EOT_Before[esi*2]
			pushf
			inc esi
			popf
			jb find_smallest
			dec esi
			mov ax, bx
			mov bx ,Store_value_of_EOT_Before[esi*2]	
			mov Store_value_of_EOT_Before[esi*2], ax
			mov Save_RVA_for_export_ENT , ecx
			mov ecx , Store_value_of_ENT_Before[esi*4]
			mov eax ,Save_RVA_for_export_ENT
			mov Store_value_of_ENT_Before[esi*4],eax
			inc esi
			jmp find_smallest	
		
		
done:	mov esi , save_esi
		dec esi
		mov Store_value_of_EOT_After[esi*2],bx
		mov Store_value_of_ENT_After[esi*4] ,ecx
		inc esi
		cmp Store_value_of_Number_Of_name,esi
		jne VCL_lai_den_luot_tao_sap_xep
		ret

VCL_sao_khong_sap_xep_tu_dau ENDP

Dose_this_mother_F_have_name_check proc Does_This_MF_Have_Name: DWORD
	mov tao_hua_day_la_lan_cuoi_can_1_bien_de_luu_esi,esi
	mov esi , save_esi
	mov ecx,0
	mov cx ,Store_value_of_EOT_After[esi*2]
	cmp Does_this_MF_have_Name,ecx
	jne	This_MF_dont_have_name
	mov edx ,offset Margin
	call WriteString
	call WriteString
	mov eax , Does_this_MF_have_Name
	call WriteHex

	push Store_value_of_ENT_After[esi*4]		;find the location (raw offset) of each export function name
	mov save_esi_for_function ,esi			; this "save_esi_for_function" because Finding_Nemo function mov the save_esi back to esi , and because save_esi always =1 make esi wrong , so need another save to save esi before and after call Finding_Nemo
	call Finding_Nemo
	mov esi, save_esi_for_function

	push 50
	push offset store_RAW_OFFSET_of_export_function_name					;move to the the location (raw offset) of that export function name
	push Nemo_location
	call Moving_dory

	mov edx ,offset Margin
	call WriteString
	call WriteString
	mov edx, offset store_RAW_OFFSET_of_export_function_name				;print export function name
	call WriteString

	push Nemo_location
	call Lai_de_them_ca_cai_forwarder

	inc esi
	mov save_esi,esi
	mov esi , tao_hua_day_la_lan_cuoi_can_1_bien_de_luu_esi
	call Crlf
	ret

	This_MF_dont_have_name:
	mov save_esi,esi
	mov esi , tao_hua_day_la_lan_cuoi_can_1_bien_de_luu_esi
	call Crlf
	ret

	This_MF_have_name:

Dose_this_mother_F_have_name_check ENDP

Lai_de_them_ca_cai_forwarder proc Export_function_name_location: DWORD
	mov tao_hua_day_la_lan_cuoi_can_1_bien_de_luu_esi_p2 ,esi
	mov esi,0
	check_forwarder:
		cmp store_RAW_OFFSET_of_export_function_name[esi],0
		pushf
		inc esi
		popf
		jne check_forwarder
		add Export_function_name_location, esi
		mov esi,tao_hua_day_la_lan_cuoi_can_1_bien_de_luu_esi_p2
		inc esi
		push Store_value_of_ENT_After[esi*4]		;find the location (raw offset) of each export function name
		mov save_esi_for_function ,esi			; this "save_esi_for_function" because Finding_Nemo function mov the save_esi back to esi , and because save_esi always =1 make esi wrong , so need another save to save esi before and after call Finding_Nemo
		call Finding_Nemo
		mov esi, save_esi_for_function
		mov eax ,Nemo_location
		cmp eax ,Export_function_name_location
		je no_eo_co_forwarder

		push 50
		push offset store_RAW_OFFSET_of_export_function_name					;move to the the location (raw offset) of that export function name
		push Export_function_name_location
		call Moving_dory

		cmp store_RAW_OFFSET_of_export_function_name[0],'N'
		jne no_eo_co_forwarder
		cmp store_RAW_OFFSET_of_export_function_name[1],'T'
		jne no_eo_co_forwarder
		cmp store_RAW_OFFSET_of_export_function_name[2],'D'
		jne no_eo_co_forwarder
		cmp store_RAW_OFFSET_of_export_function_name[3],'L'
		jne no_eo_co_forwarder
		cmp store_RAW_OFFSET_of_export_function_name[4],'L'
		jne no_eo_co_forwarder

		mov edx ,offset Margin
		call WriteString
		call WriteString
		call WriteString
		call WriteString
		mov edx, offset store_RAW_OFFSET_of_export_function_name				;print export function name
		call WriteString
		dec esi
		ret
	
		no_eo_co_forwarder:
		dec esi
		ret
Lai_de_them_ca_cai_forwarder ENDP
end main