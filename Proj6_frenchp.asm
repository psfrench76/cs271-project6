TITLE String Converter   (Proj6_frenchp.asm)

; Author: Patrick French
; Last Modified: 12-5-23
; OSU email address: frenchp@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  6            Due Date: 12-10-23
; Description: TODO - description
;
; TODO
;

INCLUDE Irvine32.inc

STRING_SIZE		= 12 ; maximum length for user input string
STRING_BUFFER	= (STRING_SIZE + 1) ; user input string buffer length (includes null terminator)
INT_ARRAY_SIZE	= 10 ; size of integer array
ASCII_0			= 48 ; ascii value for the character 0
ASCII_9			= 57 ; ascii value for the character 9
ASCII_PLUS		= 43 ; ascii value for the character +
ASCII_MINUS		= 45 ; ascii value for the character -

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Prints a given prompt to the console, and stores the user's input to [userString]
;
; Preconditions: 
;
; Receives:
; userPrompt		= (input) address of prompt string
; userString	= (output) address of user string memory location
; bytesRead		= (output) address of variable to store number of bytes read
; STRING_SIZE and STRING_BUFFER are global variables
;
; returns: 
; [userString]	= user string
; [bytesRead]	= number of bytes read
; ---------------------------------------------------------------------------------
mGetString MACRO userPrompt, userString, bytesRead

; todo - macro

ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Prints the string stored at a given memory address to console
;
; Preconditions: The string at stringAddr must be null-terminated
;
; Receives:
; stringAddr	= address of string to display
;
; returns: None
; ---------------------------------------------------------------------------------
mDisplayString MACRO stringAddr
	PUSH	EDX

	MOV		EDX, stringAddr
	CALL	WriteString

	POP		EDX
ENDM

.data
programIntro	BYTE "String Converter, by Patrick French",13,10,13,10,0
instructions1	BYTE "Please provide 10 signed integers, in the range [–2,147,483,648 : +2,147,483,647] (inclusive).",13,10,0
instructions2	BYTE "I will then display the numbers, their sum, and their (truncated) average.",13,10,13,10,0
prompt			BYTE "Please enter a signed integer: ",0
error			BYTE "Error: Invalid input.",13,10,0
summary			BYTE "You entered these numbers:",13,10,0
sumText			BYTE "The sum of these numbers is: ",0
avgText			BYTE "The truncated average of these numbers is: ",0
farewell		BYTE 13,10,"Have a nice day!",13,10,13,10,0

userInput		BYTE STRING_BUFFER DUP(0)

userInt			SDWORD -1
intArray		SDWORD INT_ARRAY_SIZE DUP(?)
sumValue		DWORD -1
avgValue		DWORD -1

.code
; ---------------------------------------------------------------------------------
; Name: main
;
; TODO - Description
; ---------------------------------------------------------------------------------
main PROC
; --------------------------
; Introduces program, prints instructions
; --------------------------
	mDisplayString OFFSET programIntro
	mDisplayString OFFSET instructions1
	mDisplayString OFFSET instructions2

; --------------------------
; Collects user input, validates, stores
; --------------------------
	MOV		ECX, INT_ARRAY_SIZE
	MOV		EDI, OFFSET intArray
_getNumber:
	PUSH	OFFSET prompt
	PUSH	OFFSET userInt
	CALL	ReadVal
	MOV		EAX, userInt
	MOV		[EDI], EAX
	ADD		EDI, TYPE intArray
	LOOP	_getNumber

; --------------------------
; Displays numbers, calculates and displays sum and average,
; and says goodbye
; --------------------------
	mDisplayString OFFSET summary

	MOV		ECX, INT_ARRAY_SIZE
_displayNumbers:
	PUSH	5
	CALL	WriteVal
	LOOP	_displayNumbers

	mDisplayString OFFSET sumText
	PUSH	OFFSET intArray
	PUSH	INT_ARRAY_SIZE
	PUSH	OFFSET sumValue
	CALL	ArraySum

	PUSH	sumValue
	CALL	WriteVal

	mDisplayString OFFSET avgText

	; TODO - calculate avgValue from sumValue

	PUSH	avgValue
	CALL	WriteVal


	mDisplayString OFFSET farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Prompts user for an input string, validates that it is a valid signed integer, and
; converts it to a signed integer and stores it in a variable given by [ebp+8]
;
; Receives:
; [ebp+12]		= address user prompt string
; [ebp+8]		= address of sdword output variable to store result
; STRING_SIZE, STRING_BUFFER, ASCII_0, ASCII_9, ASCII_PLUS, and ASCII_MINUS are global constants
;
; returns: input from user stored to [[ebp+8]]
; ---------------------------------------------------------------------------------
ReadVal PROC
	PUSH	EBP
	MOV		EBP, ESP

	; todo - everything

	MOV		EDI, [EBP+8]
	MOV		EAX, 5
	MOV		[EDI], EAX

	POP		EBP
	RET		8
ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Prints a given SDWORD integer to console
;
; Receives:
; [ebp+8]		= signed integer value to print to console
; ASCII_0, ASCII_9, ASCII_PLUS, and ASCII_MINUS are global constants
; ---------------------------------------------------------------------------------
WriteVal PROC
	PUSH	EBP
	MOV		EBP, ESP

	; Todo - int to string conversion
	mDisplayString OFFSET prompt

	POP		EBP
	RET		4
WriteVal ENDP

; ---------------------------------------------------------------------------------
; Name: ArraySum
;
; Calculates the sum of a given SDWORD integer array
;
; Preconditions: [ebp+16] is an SDWORD array populated with signed integers
;
; Receives:
; [ebp+16]		= address of sdword array to sum
; [ebp+12]		= number of elements in sdword array
; [ebp+8]		= (output) address of SDWORD variable to store result
; ---------------------------------------------------------------------------------
ArraySum PROC
	PUSH	EBP
	MOV		EBP, ESP

	; todo - sum array

	POP		EBP
	RET		12
ArraySum ENDP


END main
