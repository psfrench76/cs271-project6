TITLE String Converter   (Proj6_frenchp.asm)

; Author: Patrick French
; Last Modified: 12-5-23
; OSU email address: frenchp@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  6            Due Date: 12-10-23
; Description: This program prompts the user for 10 32-bit signed integers, validates that they are
;	valid integers in the range, converts them to integer format, calculates the sum and truncated
;	average, and then prints the numbers, the sum, and the average to the console.
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
; STRING_BUFFER is a global variable
;
; returns: 
; [userString]	= user string
; [bytesRead]	= number of bytes read
; ---------------------------------------------------------------------------------
mGetString MACRO userPrompt, userString, bytesRead
	PUSH	EDX
	PUSH	ECX
	PUSH	EAX
	PUSH	EDI

	; Prompt user
	mDisplayString userPrompt

	; Get string from user
	MOV		EDX, userString
	MOV		ECX, STRING_BUFFER
	CALL	ReadString

	; Save bytes read to [bytesRead]
	MOV		EDI, [bytesRead]
	MOV		[EDI], EAX

	POP		EDI
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

	; Write string to output
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

intString		BYTE STRING_BUFFER DUP(0)					; intermediate string for conversion

userInt			SDWORD -1									; intermediate variable for int conversion
intArray		SDWORD INT_ARRAY_SIZE DUP(?)
sumValue		SDWORD 0
avgValue		SDWORD -1
userLength		DWORD 0

.code
; ---------------------------------------------------------------------------------
; Name: main
;
; Introduces program; Prompts user for input, manages conversion to integers;
;	Displays numbers, calls ArraySum for the sum and calculates the average, and displays
;	all of the above.
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
	; Set up loop to get 10 numbers
	MOV		ECX, INT_ARRAY_SIZE
	MOV		EDI, OFFSET intArray
_loopGetNumber:
	; Set up call to ReadVal
	PUSH	OFFSET error
	PUSH	OFFSET userLength
	PUSH	OFFSET prompt
	PUSH	OFFSET intString
	PUSH	OFFSET userInt
	CALL	ReadVal

	; save converted integer to intArray
	MOV		EAX, userInt
	MOV		[EDI], EAX
	ADD		EDI, TYPE intArray
	LOOP	_loopGetNumber

; --------------------------
; Displays numbers, calculates and displays sum and average,
; and says goodbye
; --------------------------
	; Show summary text
	mDisplayString OFFSET summary

	; Set up loop to display 10 numbers
	MOV		ECX, INT_ARRAY_SIZE
	MOV		ESI, OFFSET intArray
_loopDisplayNumbers:

	; Set up call to WriteVal
	PUSH	[ESI]
	PUSH	OFFSET intString
	CALL	WriteVal

	; Skip value delimiter if this was the last value, otherwise print it
	CMP		ECX, 1
	JLE		_skipDelimiter
	mDisplayString OFFSET delimiter

	; Go to next number
_skipDelimiter:
	ADD		ESI, TYPE intArray
	LOOP	_loopDisplayNumbers

	; Print sum text
	mDisplayString OFFSET linebreak
	mDisplayString OFFSET sumText

	; Set up call to ArraySum
	PUSH	OFFSET intArray
	PUSH	INT_ARRAY_SIZE
	PUSH	OFFSET sumValue
	CALL	ArraySum

	; Print value from ArraySum
	PUSH	sumValue
	PUSH	OFFSET intString
	CALL	WriteVal

	; Print average text
	mDisplayString OFFSET linebreak
	mDisplayString OFFSET avgText

	; Calculate truncated average based on sumValue
	MOV		EAX, sumValue
	MOV		EBX, INT_ARRAY_SIZE
	CDQ
	IDIV	EBX
	MOV		avgValue, EAX

	; Display truncated average
	PUSH	avgValue
	PUSH	OFFSET intString
	CALL	WriteVal

	; Say goodbye
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
; Postconditions: [[ebp+12]] will be overwritten with user provided string value
;
; Receives:
; [ebp+24]		= address of error string for invalid input
; [ebp+20]		= address of string length variable
; [ebp+16]		= address user prompt string
; [ebp+12]		= address of integer string
; [ebp+8]		= address of sdword output variable to store result
; ASCII_0, ASCII_9, ASCII_PLUS, and ASCII_MINUS are global constants
;
; returns: input from user stored to [[ebp+8]]
; ---------------------------------------------------------------------------------
ReadVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	; Get new string from mGetString
_getNewString:
	mGetString [EBP+16], [EBP+12], [EBP+20]

	; Get string length and string location for iteration
	MOV		EBX, [EBP+20]
	MOV		ECX, [EBX]
	MOV		ESI, [EBP+12]

	; Check first character for minus sign; set EDX=1 for negative, EDX=0 for positive
	CLD
	LODSB
	MOV		EDX, 0
	CMP		AL, ASCII_MINUS
	JNE		_skipNegative
	MOV		EDX, 1
_skipNegative:

	; Reset ESI to end of string, set direction flag to traverse backwards
	MOV		ESI, [EBP+12]
	ADD		ESI, ECX
	DEC		ESI
	STD

	; Accumulate integer value in EDI, and 10's place multiplier in EBX
	MOV		EDI, 0
	MOV		EBX, 1
_loopBuildInt:

	; Get next character, check for sign characters -- if sign, terminate loop.
	LODSB
	CMP		AL, ASCII_PLUS
	JE		_endSign
	CMP		AL, ASCII_MINUS
	JE		_endSign

	; Check that the character is a valid digit
	CMP		AL, ASCII_0
	JL		_error
	CMP		AL, ASCII_9
	JG		_error

	; Convert to int value by subtracting ASCII_0. Set EAX to initial value
	SUB		AL, ASCII_0
	MOVZX	EAX, AL

	; Negate EBX (10's place multiplier) if EDX indicates sign is negative (only happens once)
	CMP		EDX, 1
	JNE		_skipInitialNegation
	NEG		EBX
_skipInitialNegation:

	; Multiply digit by 10's place multiplier to get correct place, add to EDI
	IMUL	EBX
	ADD		EDI, EAX

	; Error if overflow
	JO		_error

	; Multiply 10's place accumulator by 10
	MOV		EAX, EBX
	MOV		EBX, 10
	IMUL	EBX
	MOV		EBX, EAX

	MOV		EDX, 0					; Ensure EDX is 0 for next iteration so negation is not repeated
	LOOP	_loopBuildInt
	JMP		_endBuildInt

	; Decrement ECX in case of encountering sign character
_endSign:
	DEC		ECX

	; If there are any characters left after getting here, it's an error
_endBuildInt:
	JECXZ	_success

	; Display error message and start over
_error:
	mDisplayString [EBP+24]
	JMP		_getNewString

_success:
	; Move number value from EDI into final destination, the intArray parameter
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
; ASCII_0 and ASCII_MINUS are global constants
; ---------------------------------------------------------------------------------
WriteVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD
	; TODO - bug: -2147483648 displayed as -0 (but value is correct in integer representation)
	; Set EDI to intermediate string array address
	MOV		EDI, [EBP+8]
	CLD

	; Set ESI to integer value, check for negative, add minus to string if negative and
	; negate ESI to simplify arithmetic
	MOV		ESI, [EBP+12]
	CMP		ESI, 0
	JGE		_skipNegation
	MOV		EAX, ASCII_MINUS
	STOSB
	NEG		ESI
_skipNegation:

	; Count number of digits in integer, and build 10's place multiplier in EAX
	MOV		EAX, 1
	MOV		EBX, 10
_loopDivisor:
	IMUL	EBX

	; Once the 10's place multiplier is bigger than the integer, or overflows, stop
	JO		_breakDivisorLoop
	CMP		EAX, ESI
	JLE		_loopDivisor

	; Subtract one digit, and move 10's place multiplier to EBX
_breakDivisorLoop:
	IDIV	EBX
	MOV		EBX, EAX

	; get integer from ESI, divide by 10's place multiplier to get largest digit
_loopDigit:
	MOV		EAX, ESI
	CDQ
	IDIV	EBX

	; Set ESI to remainder for next loop, convert this digit to ascii and store
	MOV		ESI, EDX
	ADD		EAX, ASCII_0
	STOSB

	; Unless we're already at the last digit, divide 10's place multiplier by 10
	CMP		EBX, 1
	JBE		_endLoopDigit
	MOV		EAX, EBX
	MOV		EBX, 10
	CDQ
	IDIV	EBX
	MOV		EBX, EAX
	JMP		_loopDigit

	; Add null termination
_endLoopDigit:
	MOV		EAX, 0
	STOSB

	; Call mDisplayString
	mDisplayString [EBP+8]

	POPAD
	POP		EBP
	RET		8
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
;
; Returns:
; [[ebp+8]]		= Array sum result
; ---------------------------------------------------------------------------------
ArraySum PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	; Set up source (array) and destination (integer)
	MOV		ESI, [EBP+16]
	MOV		EDI, [EBP+8]

	; Add each element to [EDI]
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
