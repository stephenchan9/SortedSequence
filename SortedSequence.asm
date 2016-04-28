
INCLUDE Irvine32.inc

.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

;Variables of String prompts with declared variables. 
.data
str1 BYTE "CPSC240 Assignment #3  written by: Stephen Chan, Daniel Berumen",0			
str2 BYTE "Step 1: Populate the array with random integers from 0 to 100",0
str3 BYTE "Array of 10 numbers",0
str4 BYTE "Index  Data",0
str5 BYTE "Step 2: Sort the array",0
str6 BYTE "Array of 10 numbers sorted",0
str7 BYTE "Step 3: Search the array",0
str8 BYTE "Currently the array stores:",0
str9 BYTE "Enter an integer data to search: ",0
str10 BYTE "Found: ",0
str11 BYTE "Not Found!",0
str12 BYTE "Press any key to search again or 'Q' or 'q' to quit:",0
space BYTE "       ",0
array DWORD 10 dup(0)
userVal DWORD ?
																			
.code
;-------------------------------------------------------
; displayPrompt MACRO
; This macro is used to display the string headers and other text.
; Receives: str
;------------------------------------------------------- 
displayPrompt MACRO str		;Macro displaying string prompts
	push edx
	mov edx, OFFSET str		
	call WriteString
	call Crlf
	call Crlf
	pop edx
ENDM

;-------------------------------------------------------
; displayArray MACRO 
; This macro displays the contents of the array
; Receives: array
;------------------------------------------------------- 
displayArray MACRO array	;Macro displaying contents of array
	LOCAL L1
	mov esi, OFFSET array
	mov ecx, LENGTHOF array
	mov ebx,0
	mov edx, OFFSET space
	L1:
		mov eax,ebx
		call WriteDec
		call WriteString
		mov eax, [esi]
		call WriteDec
		call Crlf
		add esi,4
		inc ebx
		loop L1
ENDM

;-------------------------------------------------------
; procedure1 proc uses eax,ecx,esi
; Assigns values to the array that are randomized.
; Receives: pArray, Count, MxNum
; Returns: 
;------------------------------------------------------- 
procedure1 PROC USES eax ecx esi, pArray:PTR DWORD, Count:DWORD, maxNum:DWORD
	mov esi, pArray
	mov ecx, Count
	mov eax, maxNum
	call Randomize
	L1: 
		push eax
		call RandomRange
		mov [esi], eax
		add esi, 4
		pop eax
		loop L1
	ret
procedure1 ENDP

;-------------------------------------------------------
; procedure2 proc uses eax,ecx,esi
; Sorts the array using a BubbleSort.
; Receives: pArray, Count
; Returns: 
;------------------------------------------------------- 
procedure2 PROC USES eax ecx esi, pArray: PTR DWORD, Count:DWORD
	mov ecx, Count
	dec ecx
	L1: 
		push ecx
		mov esi, pArray
	L2:
		mov eax, [esi]
		cmp [esi+4], eax
		jge L3
		xchg eax, [esi+4]
		mov [esi],eax
	L3: 
		add esi,4
		loop L2
		pop ecx
		loop L1
	L4: 
		ret
procedure2 ENDP

;-------------------------------------------------------
; procedure3 proc uses ebx,edx,esi,edi
; Performs a binary search in the array looking for the UserVal.
; Receives: pArray, Count, searchVal
; Returns: eax(Indexed value)
;------------------------------------------------------- 
procedure3 PROC USES ebx edx esi edi,
	pArray:PTR DWORD,
	Count:DWORD,
	searchVal:DWORD
LOCAL first:DWORD,
	last:DWORD,
	mid:DWORD
	mov first,0
	mov eax,Count
	dec eax
	mov last,eax
	mov edi,searchVal
	mov ebx,pArray
L1:
	mov eax,first
	cmp eax,last
	jg L5
	mov eax,last
	add eax,first
	shr eax,1
	mov mid,eax
	;EDX=values[mid]
	mov esi,mid
	shl esi,2
	mov edx,[ebx+esi]
	
	cmp edx,edi
	jge L2
	mov eax,mid
	inc eax
	mov first,eax
	jmp L4
L2: 
	cmp edx,edi
	jle L3
	mov eax,mid
	dec eax
	mov last,eax
	jmp L4
L3:
	mov eax,mid
	jmp L9
L4:
	jmp L1
L5:
	mov eax,-1
L9: 
	ret
procedure3 ENDP


main proc
	call Clrscr						;Clears Screen and displays prompts for Procedure 1
	displayPrompt str1
	displayPrompt str2
	displayPrompt str3
	displayPrompt str4

	INVOKE procedure1,				;Passes array and values in order to assign random values to the array
		ADDR array,10,100
	displayArray array				;Displays contents of array
	

	call WaitMsg					;Clears screen and displays prompts for Procedure 2
	call Clrscr
	displayPrompt str1
	displayPrompt str5
	displayPrompt str6
	displayPrompt str4

	INVOKE procedure2,				;Passes in array and length of array to bubblesort procedure
		ADDR array,10
	displayArray array				;Displays contents of array

	call WaitMsg					;Start of Procedure 3 
	call Clrscr

Search:								;This loop prompts for value to be searched
	displayPrompt str1		
	displayPrompt str7
	displayPrompt str8
	displayArray array
	mov edx, OFFSET str9
	call WriteString
	call ReadDec
	mov userVal,eax

	INVOKE procedure3,
		ADDR array,10,userVal		;Calls the binary search procedure
	cmp eax,-1
	jne Success						;Jumps if value is found
	displayPrompt str11				;Prompt displays if not found
	jmp RepeatSearch				;Jumps to repeat the search

Success:
	displayPrompt str10				;Displays the Value to the screen
	displayPrompt str4
	call WriteDec
	mov edx, OFFSET space
	call WriteString
	mov eax,userVal
	call WriteDec
	call Crlf
	jmp RepeatSearch

RepeatSearch:
	mov edx, OFFSET str12		;Header prompting the user to enter q to quit or enter any key to continue
	call WriteString 
	call ReadChar				

	cmp al,'q'					;Compares user with lower case q character
	je quit						
	cmp al,'Q'					;Compares with Upper case Q
	je quit						
	
	call Crlf					
	call Clrscr					;Clear the screen
	jnz Search					;Loop back to Search

quit:
	invoke ExitProcess,0
main endp
end main

