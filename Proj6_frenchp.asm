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

STRING_SIZE		= 11 ; maximum length for user input string
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
; userPrompt	= (input) address of prompt string
; userString	= (output) address of user string memory location
; bytesRead		= (output) address of bytes read variable
; STRING_SIZE and STRING_BUFFER are global variables
;
; returns: 
; [userString]	= user string
; [bytesRead]	= number of bytes read
; ---------------------------------------------------------------------------------
mGetString MACRO userPrompt, userString, bytesRead
	PUSH	EDX
	PUSH	ECX
	PUSH	EAX
	mDisplayString userPrompt
	MOV		EDX, userString
	MOV		ECX, STRING_BUFFER
	CALL	ReadString
	MOV		EDI, [bytesRead]
	MOV		[EDI], EAX
	POP		EAX
	POP		ECX
	POP		EDX
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
instructions1	BYTE "Please provide 10 signed integers, in the range [-2,147,483,648 : +2,147,483,647] (inclusive).",13,10,0
instructions2	BYTE "I will then display the numbers, their sum, and their (truncated) average.",13,10,13,10,0
prompt			BYTE "Please enter a signed integer: ",0
error			BYTE "Error: Invalid input.",13,10,0
summary			BYTE "You entered these numbers:",13,10,0
sumText			BYTE "The sum of these numbers is: ",0
avgText			BYTE "The truncated average of these numbers is: ",0
farewell		BYTE 13,10,"Have a nice day!",13,10,13,10,0
delimiter		BYTE ", ",0
linebreak		BYTE 13,10,0

intString		BYTE STRING_BUFFER DUP(0)

userInt			SDWORD -1
intArray		SDWORD INT_ARRAY_SIZE DUP(?)
sumValue		SDWORD 0
avgValue		SDWORD -1
userLength		DWORD 0

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
	PUSH	OFFSET error
	PUSH	OFFSET userLength
	PUSH	OFFSET prompt
	PUSH	OFFSET intString
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
	MOV		ESI, OFFSET intArray
_displayNumbers:
	PUSH	[ESI]
	PUSH	OFFSET intString
	CALL	WriteVal
	CMP		ECX, 1
	JLE		_skipDelimiter
	mDisplayString OFFSET delimiter
_skipDelimiter:
	ADD		ESI, TYPE intArray
	LOOP	_displayNumbers

	mDisplayString OFFSET linebreak


	mDisplayString OFFSET sumText
	PUSH	OFFSET intArray
	PUSH	INT_ARRAY_SIZE
	PUSH	OFFSET sumValue
	CALL	ArraySum

	PUSH	sumValue
	PUSH	OFFSET intString
	CALL	WriteVal

	mDisplayString OFFSET linebreak

	mDisplayString OFFSET avgText

	; TODO - calculate avgValue from sumValue

	PUSH	avgValue
	PUSH	OFFSET intString
	CALL	WriteVal

	mDisplayString OFFSET linebreak

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
; [ebp+24]		= address of error string for invalid input
; [ebp+20]		= address of string length variable
; [ebp+16]		= address user prompt string
; [ebp+12]		= address of integer string
; [ebp+8]		= address of sdword output variable to store result
; STRING_SIZE, STRING_BUFFER, ASCII_0, ASCII_9, ASCII_PLUS, and ASCII_MINUS are global constants
;
; returns: input from user stored to [[ebp+8]]
; ---------------------------------------------------------------------------------
ReadVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD
_getNewString:
	mGetString [EBP+16], [EBP+12], [EBP+20]

	;mDisplayString [EBP+12]

	MOV		EBX, [EBP+20]
	MOV		ECX, [EBX]
	MOV		ESI, [EBP+12]

	CLD
	LODSB
	MOV		EDX, 0
	CMP		AL, ASCII_MINUS
	JNE		_skipNegative
	MOV		EDX, 1

_skipNegative:
	MOV		ESI, [EBP+12]
	ADD		ESI, ECX
	DEC		ESI

	STD

	MOV		EDI, 0
	MOV		EBX, 1
_loopBuildInt:
	LODSB
	CMP		AL, ASCII_PLUS
	JE		_endPositive
	CMP		AL, ASCII_MINUS
	JE		_endNegative
	CMP		AL, ASCII_0
	JL		_error
	CMP		AL, ASCII_9
	JG		_error
	SUB		AL, ASCII_0
	MOVZX	EAX, AL
	CMP		EDX, 1
	JNE		_skipInitialNegation
	NEG		EBX
_skipInitialNegation:
	IMUL	EBX
	ADD		EDI, EAX
	JO		_error
	MOV		EAX, EBX
	MOV		EBX, 10
	IMUL	EBX
	MOV		EBX, EAX
	MOV		EDX, 0
	LOOP	_loopBuildInt
	JMP		_endBuildInt

_endNegative:
	DEC		ECX
	JMP		_endBuildInt

_endPositive:
	DEC		ECX
	JMP		_endBuildInt

_endBuildInt:
	JECXZ	_success
_error:
	mDisplayString [EBP+24]
	JMP		_getNewString

_success:

	MOV		EAX, EDI

	MOV		EDI, [EBP+8]
	MOV		[EDI], EAX

	POPAD
	POP		EBP
	RET		20
ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Prints a given SDWORD integer to console
;
; Postconditions: [[ebp+8]] will be overwritten with string value of [ebp+12]
;
; Receives:
; [ebp+12]		= signed integer value to print to console
; [ebp+8]		= address of string array which will be changed to string value of number
; STRING_BUFFER, ASCII_0, ASCII_9, ASCII_PLUS, and ASCII_MINUS are global constants
; ---------------------------------------------------------------------------------
WriteVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	MOV		EDI, [EBP+8]
	CLD



	MOV		ESI, [EBP+12]
	CMP		ESI, 0
	JGE		_skipNegation
	MOV		EAX, ASCII_MINUS
	STOSB
	NEG		ESI

_skipNegation:

	MOV		ECX, STRING_SIZE-2
	MOV		EAX, 1
	MOV		EBX, 10
_loopDivisor:
	IMUL		EBX
	LOOP	_loopDivisor

	MOV		EBX, EAX

_loopDigit:
	MOV		EAX, ESI
	CMP		EBX, EAX
	JG		_skipStore
	CDQ
	IDIV	EBX
	MOV		ESI, EDX
	ADD		EAX, ASCII_0
	STOSB
_skipStore:
	CMP		EBX, 1
	JBE		_endLoopDigit
	MOV		EAX, EBX
	MOV		EBX, 10
	CDQ
	IDIV	EBX
	MOV		EBX, EAX
	JMP		_loopDigit

_endLoopDigit:
	MOV		EAX, 0
	STOSB

	mDisplayString [EBP+8]

	POPAD
	POP		EBP
	RET		8
WriteVal ENDP

WriteValOld PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	MOV		ECX, STRING_SIZE
	DEC		ECX

	MOV		EDI, [EBP+8]
	ADD		EDI, STRING_SIZE
	DEC		EDI
	STD

_loopDigit:
	MOV		EAX, ESI
	MOV		EBX, 10
	CDQ
	IDIV	EBX
	MOV		ESI, EAX
	ADD		EDX, ASCII_0
	MOV		EAX, EDX
	STOSB
	DEC		ECX
	CMP		ESI, 0
	JG		_loopDigit
	
	MOV		EAX, 42
	MOV		EBX, 0
_loopNull:
	STOSB
	INC		EBX
	LOOP	_loopNull


	mDisplayString [EBP+8]

	POPAD
	POP		EBP
	RET		8
WriteValOld ENDP

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
	PUSHAD

	MOV		ESI, [EBP+16]
	MOV		EDI, [EBP+8]

	MOV		ECX, [EBP+12]
_loopSum:
	MOV		EAX, [ESI]
	ADD		[EDI], EAX
	ADD		ESI, 4
	LOOP	_loopSum

	POPAD
	POP		EBP
	RET		12
ArraySum ENDP


END main
