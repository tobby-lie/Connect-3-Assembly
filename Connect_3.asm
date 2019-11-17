TITLE test3.asm
;===================================================================================
; Author:  Tobby Lie
; Date:  23 April 2018
; Description: final Coding Exam (Connect 3)
;
; Last updated: 4/24/18 3:58PM
; ====================================================================================

Include Irvine32.inc 

; ====================================================================================
;// PROTO
ClearRegisters proto							;// ClearRegisters
; ====================================================================================
printGrid proto,								;// printGrid
ptrCoordinates:ptr byte
; ====================================================================================
spaceColor proto,								;// spaceColor
currentSpace:dword
; ====================================================================================
placePiece proto,								;// placePiece
ptrTheGrid:ptr byte,
columnChoice:dword,
whichPlayer:byte
; ====================================================================================
CompVComp proto,								;// compVcomp
ptrGrid:ptr byte
; ====================================================================================
clearBoard proto,								;// clearBoard
ptrtheGrid:ptr byte
; ====================================================================================
checkWinHoriz proto,							;// checkWinHoriz
ptrGrid:ptr byte
; ====================================================================================
checkWinVert proto,								;// checkWinVert
ptrGrid2:ptr byte
; ====================================================================================
checkWinDiagP1 proto,							;// checkWinDiagP1
ptrGrid3:ptr byte
; ====================================================================================
checkWinDiagP2 proto,							;// checkWinDiagP2
ptrGrid4:ptr byte
; ====================================================================================
PvP proto,										;// PvP
ptrtheGameGrid:ptr byte,
ptrPlayerWins:ptr dword,
ptrPlayerLosses:ptr dword,
ptrPlayerDraws:ptr dword
; ====================================================================================
PvC proto,										;// PvC
ptrtheGameGrid1:ptr byte,
ptrPlayerWins1:ptr dword,
ptrPlayerLosses1:ptr dword,
ptrPlayerDraws1:ptr dword
; ====================================================================================
;//Macros
ClearEAX textequ <mov eax, 0>
ClearEBX textequ <mov ebx, 0>
ClearECX textequ <mov ecx, 0>
ClearEDX textequ <mov edx, 0>
ClearESI textequ <mov esi, 0>
ClearEDI textequ <mov edi, 0>
; ====================================================================================
.data
; ====================================================================================
linedivider byte "==========", 0Ah, 0Dh, 0h
Menuprompt byte 'MAIN MENU', 0Ah, 0Dh,			;// Menu prompt is one string
'==========', 0Ah, 0Dh,
'1. Player 1 vs Player 2', 0Ah, 0Dh,
'2. Player 1 vs Computer 1', 0Ah, 0Dh,
'3. Computer 1 vs Computer 2', 0Ah, 0Dh, 
'4. Exit: ',0Ah, 0Dh, 0h	
useroption byte 0h		
errormessage byte 'You have entered an invalid option. Please try again.', 0Ah, 0Dh, 0h			;//Error message
tableB byte 0, 0, 0, 0 							;// table of characters (4x4)
Rowsize = ($-tableB)
	byte 0, 0, 0, 0 
	byte 0, 0, 0, 0
	byte 0, 0, 0, 0
sizeOfRow byte 0								;// size of one row of characters
defaultcolor = lightGray + (black * 16)			;// to make color changes easier
bluecolor = blue + (blue * 16)
yellowcolor = yellow + (yellow * 16)
playerwincounter dword 0						;// counts games won by player 1
playerlosscounter dword 0						;// counts games lost by player 1
playerdrawcounter dword 0						;// counts games come to a tie
player1wins byte "Player 1 wins: ",0h			;// messages for win, loss, draw counters
player1losses byte "Player 1 losses: ", 0h
player1draws byte "Game ties: ", 0h
; ====================================================================================
.code
; ====================================================================================
main PROC
; ====================================================================================

call randomize									 ;// seed randomize
invoke ClearRegisters							 ;// clears registers

begin:

call clrscr

mov edx, offset linedivider						;// display counter of wins, losses, draws
call writestring

mov edx, offset player1wins
call writestring
mov eax, playerwincounter
call writedec
call crlf

mov edx, offset player1losses
call writestring
mov eax, playerlosscounter
call writedec
call crlf

mov edx, offset player1draws
call writestring
mov eax, playerdrawcounter
call writedec
call crlf

mov edx, offset linedivider
call writestring


mov edx, offset menuprompt						 ;// menu prompt
call WriteString
call readhex
mov useroption, al								 ;// readhex holds input in al and will then be moved into useroption

opt1:											 ;// pvp option
cmp useroption, 1
jne opt2
invoke PvP, addr tableB, addr playerwincounter, addr playerlosscounter, addr playerdrawcounter
invoke clearBoard, addr tableB
call crlf
call waitmsg
call clrscr

jmp begin


opt2:											;// pvc option
cmp useroption, 2
jne opt3
invoke PvC, addr tableB, addr playerwincounter, addr playerlosscounter, addr playerdrawcounter
invoke clearBoard, addr tableB
call crlf
call waitmsg
call clrscr

jmp begin

opt3:											;// cvc option
cmp useroption, 3
jne opt4
invoke CompVComp, addr tableB
invoke clearBoard, addr tableB
call crlf
call waitmsg
call clrscr

jmp begin

opt4:											;// quit program
cmp useroption, 4
jne oops
jmp quitit
oops:											;// error message for invalid input
push edx
mov edx, offset errormessage
call writestring
call waitmsg
pop edx
jmp begin

quitit:											;// quit program

exit
; ====================================================================================
main ENDP
; ====================================================================================
;// Procedures
; == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
PvC proc,
ptrtheGameGrid1:ptr byte,
ptrPlayerWins1:ptr dword,
ptrPlayerLosses1:ptr dword,
ptrPlayerDraws1:ptr dword
;// Description:  player vs computer
;// Requires:  all registers
;// Returns:  number of wins, losses or draws will be updated
.data
rVal2 dword 0									;// holds computer randval
playerTracker2 byte 0							;// tracks current player
numTurns2 byte 0								;// should not exceed 16
counter2 byte 0
winMessage5 byte "Player ",0h					;// win message
winMessage6 byte " has won!", 0h
winnerwinnerchickendinner2 dword 0				;// flag for win status
currentplayermessage5 byte "Player ", 0h		;// who is the current player
currentplayermessage6 byte "'s turn", 0h
drawmessage2 byte "It's a tie!", 0h				;// message for draw
playerInput1 dword 0							;// holds the player column input
promptforinput1 byte "Please input a column number from 1-4: ",0h	;// prompt for input
invalidcolinput1 byte "Invalid input! Must input a number from 1-4.",0h	;//invalid input
fullcolinput1 byte "Invalid! Column is full, try again.", 0h	;// the column is full
.code
mov ebx, ptrtheGameGrid1		
mov winnerwinnerchickendinner2, 0

mov counter2, 16d
mov playertracker2, 1
play2:
call clrscr

mov edx, offset currentplayermessage5			;// who is the current player
call writestring
movzx eax, playertracker2
call writedec
mov edx, offset currentplayermessage6
call writestring
call crlf

invoke printGrid, ptrtheGameGrid1				;// print the grid 
cmp playertracker2, 2
jne noneedtodelay								;// delay if computer
mov eax, 2000
call delay
noneedtodelay:
call crlf

cmp playertracker2, 1							;// if player 2 do not collect input
jne notUser

mov edx, offset promptforinput1
call writestring
call readdec
mov playerinput1, eax

cmp playerinput1, 1
jae checkrangept2of2
mov edx, offset invalidcolinput1				;// validate input
call writestring
call crlf
call waitmsg
jmp play2
checkrangept2of2:
cmp playerinput1, 4
jbe goodtogo1
mov edx, offset invalidcolinput1
call writestring
call crlf
call waitmsg
jmp play2
goodtogo1:

jmp isuser

notUser:
mov playerinput1, 0								;// randomize computer choice
mov eax, 4
call randomRange
inc eax
mov playerinput1, eax

isuser:

invoke placePiece, ptrtheGameGrid1, playerinput1, playerTracker2	;// place piece into matrix

push ebx

mov edx, 0										;// check for win in all directions of board
invoke checkWinHoriz, ptrtheGameGrid1
mov winnerwinnerchickendinner2, edx
cmp winnerwinnerchickendinner2, 0
jne nomoreChecks2

invoke checkWinvert, ptrtheGameGrid1
mov winnerwinnerchickendinner2, edx
cmp winnerwinnerchickendinner2, 0
jne nomorechecks2

invoke checkWinDiagP1, ptrtheGameGrid1
mov winnerwinnerchickendinner2, edx
cmp winnerwinnerchickendinner2, 0
jne nomorechecks2

invoke checkWinDiagP2, ptrtheGameGrid1
mov winnerwinnerchickendinner2, edx
cmp winnerwinnerchickendinner2, 0
jne nomorechecks2

nomorechecks2:

pop ebx

cmp ebx, -1											;// if input is invalid, then get input again
jne validInput1

cmp playertracker2, 2
je noneedforprompt
mov edx, offset fullcolinput1						;// check if column is full
call writestring
call crlf
call waitmsg
noneedforprompt:
jmp play2
validInput1:
cmp playertracker2, 1								;// change players if need be
jne player2turn2
mov playertracker2, 2
jmp goAgain2
player2turn2:
mov playertracker2, 1

goAgain2:

cmp winnerwinnerchickendinner2, -1					;// check for winners
jne maybep2pt2
mov playertracker2, 1
jmp tothemessages2
maybep2pt2:
cmp winnerwinnerchickendinner2, -2					
jne nowinner2
mov playertracker2, 2

tothemessages2:
call crlf
mov edx, offset winmessage5							;// if winner occurs, display that and leave proc
call writestring
movzx eax, playertracker2
call writedec
mov edx, offset winmessage6
call writestring
call crlf
cmp playertracker2, 1
jne onedidnotwin1
mov ecx, ptrplayerwins1								;// need to update counters for wins, losses, draws
mov eax, 1
add [ecx], eax
jmp outofLoop2
onedidnotwin1:
mov ecx, ptrplayerlosses1
mov eax, 1
add [ecx], eax
jmp outofLoop2
nowinner2:
call clrscr
dec counter2
cmp counter2, 0
je outofLoop2
jmp play2

outofLoop2:

cmp winnerwinnerchickendinner2, 0					;// check for draw message
jne thereisawinner2
mov edx, offset drawmessage2
call writestring
mov ecx, ptrplayerdraws1
mov eax, 1
add [ecx], eax
thereisawinner2:

ret
PvC endp 

PvP proc,
ptrtheGameGrid:ptr byte,
ptrPlayerWins:ptr dword,
ptrPlayerLosses:ptr dword,
ptrPlayerDraws:ptr dword
;// Description:  player vs player
;// Requires:  all registers
;// Returns:  number of wins, losses or draws will be updated

;// almost all comments for this proc will be the same as pvc
.data
rVal1 dword 0
playerTracker1 byte 0
numTurns1 byte 0									;// should not exceed 16
counter1 byte 0
winMessage3 byte "Player ",0h
winMessage4 byte " has won!", 0h
winnerwinnerchickendinner1 dword 0
currentplayermessage3 byte "Player ", 0h
currentplayermessage4 byte "'s turn", 0h
drawmessage1 byte "It's a tie!", 0h
playerInput dword 0
promptforinput byte "Please input a column number from 1-4: ",0h
invalidcolinput byte "Invalid input! Must input a number from 1-4.",0h
fullcolinput byte "Invalid! Column is full, try again.", 0h	
.code
mov ebx, ptrtheGameGrid
mov winnerwinnerchickendinner1, 0

mov counter1, 16d
mov playertracker1, 1
play1:
call clrscr

mov edx, offset currentplayermessage3			;// need to display current player
call writestring
movzx eax, playertracker1
call writedec
mov edx, offset currentplayermessage4
call writestring
call crlf

invoke printGrid, ptrtheGameGrid
call crlf

mov edx, offset promptforinput
call writestring
call readdec
mov playerinput, eax

cmp playerinput, 1									;// validate input
jae checkrangept2
mov edx, offset invalidcolinput
call writestring
call crlf
call waitmsg
jmp play1
checkrangept2:
cmp playerinput, 4
jbe goodtogo
mov edx, offset invalidcolinput
call writestring
call crlf
call waitmsg
jmp play1
goodtogo:

invoke placePiece, ptrtheGameGrid, playerinput, playerTracker1		;// place the piece

push ebx

mov edx, 0
invoke checkWinHoriz, ptrtheGameGrid
mov winnerwinnerchickendinner1, edx					;// need to check for winner in each direction
cmp winnerwinnerchickendinner1, 0
jne nomoreChecks1

invoke checkWinvert, ptrtheGameGrid
mov winnerwinnerchickendinner1, edx
cmp winnerwinnerchickendinner1, 0
jne nomorechecks1

invoke checkWinDiagP1, ptrtheGameGrid
mov winnerwinnerchickendinner1, edx
cmp winnerwinnerchickendinner1, 0
jne nomorechecks1

invoke checkWinDiagP2, ptrtheGameGrid
mov winnerwinnerchickendinner1, edx
cmp winnerwinnerchickendinner1, 0
jne nomorechecks1

nomorechecks1:

pop ebx

cmp ebx, -1
jne validInput
mov edx, offset fullcolinput					;// is the column full
call writestring
call crlf
call waitmsg
jmp play1
validInput:
cmp playertracker1, 1
jne player2turn1
mov playertracker1, 2							;// change players
jmp goAgain1
player2turn1:
mov playertracker1, 1

goAgain1:

cmp winnerwinnerchickendinner1, -1				;// who is the winner
jne maybep2pt1
mov playertracker1, 1
jmp tothemessages1
maybep2pt1:
cmp winnerwinnerchickendinner1, -2
jne nowinner1
mov playertracker1, 2

tothemessages1:
call crlf
mov edx, offset winmessage3						;// print win messages
call writestring
movzx eax, playertracker1
call writedec
mov edx, offset winmessage4
call writestring
call crlf
cmp playertracker1, 1
jne onedidnotwin
mov ecx, ptrplayerwins							;// update win, loss, draw counters
mov eax, 1
add [ecx], eax
jmp outofLoop1
onedidnotwin:
mov ecx, ptrplayerlosses
mov eax, 1
add [ecx], eax
jmp outofLoop1
nowinner1:
call clrscr
dec counter1
cmp counter1, 0
je outofLoop1
jmp play1

outofLoop1:

cmp winnerwinnerchickendinner1, 0				;// is there a draw?
jne thereisawinner1
mov edx, offset drawmessage1
call writestring
mov ecx, ptrplayerdraws
mov eax, 1
add [ecx], eax
thereisawinner1:

ret
PvP endp 

checkwinVert proc,
ptrGrid2:ptr byte
;// Description:  check win in vertical direction of board
;// Requires:  all registers
;// Returns:  return -1 in edx if there is a win
.data
holdThatCounter1 dword 0
spotCounter1 byte 0
holdesi1 dword 0
.code
mov edx, 0
mov ebx, ptrGrid2
mov spotCounter1, 0
mov esi, 0
mov ecx, 4
checkvertP1:									;// checks each column for 3 in a row
mov holdThatcounter1, ecx

	mov ecx, 2
	mov ebx, ptrgrid2
	checkvertcolp1:
	mov spotcounter1, 0

	movzx edx, byte ptr [ebx + esi]				;// traverses each column and keeps a tally of all player 1 spotss
	cmp edx, 1
	jne next6
	inc spotCounter1
	next6:
	add ebx, rowSize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next7
	inc spotCounter1
	next7:
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next8
	inc spotCounter1
	next8:

	mov edx, 0									;// if a winner is discovered, return -1 in edx
	cmp spotCounter1, 3
	jne noWin2
	mov edx, -1
	jmp getout1
	noWin2:

	mov ebx, ptrGrid2
	add ebx, rowSize
	loop checkvertcolp1

inc esi
mov ecx, holdThatcounter1
loop checkvertP1

mov edx, 0
mov ebx, ptrGrid2
mov spotCounter1, 0
mov esi, 0
mov ecx, 4
checkvertP2:									;// same as above except for player 2
mov holdThatcounter1, ecx

	mov ecx, 2
	mov ebx, ptrgrid2
	checkvertcolp2:
	mov spotcounter1, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next9
	inc spotCounter1
	next9:
	add ebx, rowSize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next10
	inc spotCounter1
	next10:
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next11
	inc spotCounter1
	next11:

	mov edx, 0
	cmp spotCounter1, 3
	jne noWin3
	mov edx, -2
	jmp getout1
	noWin3:

	mov ebx, ptrGrid2
	add ebx, rowSize
	loop checkvertcolp2

inc esi
mov ecx, holdThatcounter1
loop checkvertP2

getout1:
ret
checkWinvert endp

checkWinHoriz proc,
ptrGrid1:ptr byte
;// Description:  check for a winner in each row
;// Requires:  all registers
;// Returns:  return -1 in edx if there is a win
.data
holdThatCounter dword 0
spotCounter byte 0
holdesi dword 0
.code
mov edx, 0
mov ebx, ptrGrid1
mov spotCounter, 0

mov ecx, 4
checkhorizP1:								;// check each row for 3 in a row
mov holdThatcounter, ecx

	mov ecx, 2
	mov esi, 0
	checkhorizRowp1:						;// traverse each row and tally all positions for player 1
	mov spotcounter, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next
	inc spotCounter
	next:
	inc esi
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next1
	inc spotCounter
	next1:
	inc esi
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next2
	inc spotCounter
	next2:

	mov edx, 0
	cmp spotCounter, 3
	jne noWin
	mov edx, -1
	jmp getout
	noWin:

	mov esi, 1
	loop checkhorizRowp1

add ebx, rowSize
mov ecx, holdThatcounter
loop checkHorizp1

mov edx, 0
mov ebx, ptrGrid1
mov spotCounter, 0
mov ecx, 4
checkhorizP2:								;// same as above but for player 2
mov holdThatcounter, ecx

	mov ecx, 2
	mov esi, 0
	checkhorizRowp2:
	mov spotcounter, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next3
	inc spotCounter
	next3:
	inc esi
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next4
	inc spotCounter
	next4:
	inc esi
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next5
	inc spotCounter
	next5:

	mov edx, 0
	cmp spotCounter, 3								;// if winner found return -2 in edx for player 2
	jne noWin1
	mov edx, -2
	jmp getout
	noWin1:

	mov esi, 1
	loop checkhorizRowp2

add ebx, rowSize
mov ecx, holdThatcounter
loop checkHorizp2

getout:
ret
checkWinHoriz endp

checkWinDiagP1 proc,
ptrGrid3:ptr byte
;// Description:  check diagonal wins for player 1
;// Requires:  all registers
;// Returns:  return -1 or -2 in edx if winner found
.data
holdThatCounter2 dword 0
spotCounter2 byte 0
holdesi2 dword 0
.code
;////////////
	mov edx, 0
	mov ebx, ptrGrid3
	mov spotCounter2, 0
	mov esi, 0
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next12
	inc spotCounter2
	next12:
	inc esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next13
	inc spotCounter2
	next13:
	inc esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next14
	inc spotCounter2
	next14:

	mov edx, 0
	cmp spotCounter2, 3
	jne noWin4
	mov edx, -1
	jmp getout2
	noWin4:

	;// P1 L to R part 2
	mov esi, 1
	mov ebx, ptrGrid3
	add ebx, rowsize
	mov edx, 0

	mov spotCounter2, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next15
	inc spotCounter2
	next15:
	inc esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next16
	inc spotCounter2
	next16:
	inc esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next17
	inc spotCounter2
	next17:

	mov edx, 0
	cmp spotCounter2, 3
	jne noWin5
	mov edx, -1
	jmp getout2
	noWin5:

	;// P1 R to L part 1
	mov esi, 3
	mov ebx, ptrGrid3
	mov edx, 0

	mov spotCounter2, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next18
	inc spotCounter2
	next18:
	dec esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next19
	inc spotCounter2
	next19:
	dec esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next20
	inc spotCounter2
	next20:

	mov edx, 0
	cmp spotCounter2, 3
	jne noWin6
	mov edx, -1
	jmp getout2
	noWin6:

	;// R to L part 2
	mov esi, 2
	mov ebx, ptrGrid3
	add ebx, rowsize
	mov edx, 0

	mov spotCounter2, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next21
	inc spotCounter2
	next21:
	dec esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next22
	inc spotCounter2
	next22:
	dec esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next23
	inc spotCounter2
	next23:

	mov edx, 0
	cmp spotCounter2, 3
	jne noWin7
	mov edx, -1
	jmp getout2
	noWin7:

	;// L to R intermediate pt 1
	mov esi, 1
	mov ebx, ptrGrid3
	mov edx, 0

	mov spotCounter2, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next24
	inc spotCounter2
	next24:
	inc esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next25
	inc spotCounter2
	next25:
	inc esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next26
	inc spotCounter2
	next26:

	mov edx, 0
	cmp spotCounter2, 3
	jne noWin8
	mov edx, -1
	jmp getout2
	noWin8:

	;// L to R intermediate pt 2
	mov esi, 0
	mov ebx, ptrGrid3
	add ebx, rowsize
	mov edx, 0

	mov spotCounter2, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next27
	inc spotCounter2
	next27:
	inc esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next28
	inc spotCounter2
	next28:
	inc esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next29
	inc spotCounter2
	next29:

	mov edx, 0
	cmp spotCounter2, 3
	jne noWin9
	mov edx, -1
	jmp getout2
	noWin9:

	;/////
	;// R to L intermediate pt 1
	mov esi, 2
	mov ebx, ptrGrid3
	mov edx, 0

	mov spotCounter2, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next30
	inc spotCounter2
	next30:
	dec esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next31
	inc spotCounter2
	next31:
	dec esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next32
	inc spotCounter2
	next32:

	mov edx, 0
	cmp spotCounter2, 3
	jne noWin10
	mov edx, -1
	jmp getout2
	noWin10:

	;// R to L intermediate pt 2
	mov esi, 3
	mov ebx, ptrGrid3
	add ebx, rowsize
	mov edx, 0

	mov spotCounter2, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next33
	inc spotCounter2
	next33:
	dec esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next34
	inc spotCounter2
	next34:
	dec esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 1
	jne next35
	inc spotCounter2
	next35:

	mov edx, 0
	cmp spotCounter2, 3
	jne noWin11
	mov edx, -1
	jmp getout2
	noWin11:

getout2:
ret
checkWinDiagP1 endp

;//////
checkWinDiagP2 proc,
ptrGrid4:ptr byte
.data
holdThatCounter3 dword 0
spotCounter3 byte 0
holdesi3 dword 0
.code

	mov edx, 0
	mov ebx, ptrGrid4
	mov spotCounter3, 0
	mov esi, 0
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next36
	inc spotCounter3
	next36:
	inc esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next37
	inc spotCounter3
	next37:
	inc esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next38
	inc spotCounter3
	next38:

	mov edx, 0
	cmp spotCounter3, 3
	jne noWin12
	mov edx, -2
	jmp getout3
	noWin12:

	;// P1 L to R part 2
	mov esi, 1
	mov ebx, ptrGrid4
	add ebx, rowsize
	mov edx, 0

	mov spotCounter3, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next39
	inc spotCounter3
	next39:
	inc esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next40
	inc spotCounter3
	next40:
	inc esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next41
	inc spotCounter3
	next41:

	mov edx, 0
	cmp spotCounter3, 3
	jne noWin13
	mov edx, -2
	jmp getout3
	noWin13:

	;// P1 R to L part 1
	mov esi, 3
	mov ebx, ptrGrid4
	mov edx, 0

	mov spotCounter3, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next42
	inc spotCounter3
	next42:
	dec esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next43
	inc spotCounter3
	next43:
	dec esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next44
	inc spotCounter3
	next44:

	mov edx, 0
	cmp spotCounter3, 3
	jne noWin14
	mov edx, -2
	jmp getout3
	noWin14:

	;// R to L part 2
	mov esi, 2
	mov ebx, ptrGrid4
	add ebx, rowsize
	mov edx, 0

	mov spotCounter3, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next45
	inc spotCounter3
	next45:
	dec esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next46
	inc spotCounter3
	next46:
	dec esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next47
	inc spotCounter3
	next47:

	mov edx, 0
	cmp spotCounter3, 3
	jne noWin15
	mov edx, -2
	jmp getout3
	noWin15:

	;// L to R intermediate pt 1
	mov esi, 1
	mov ebx, ptrGrid4
	mov edx, 0

	mov spotCounter3, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next48
	inc spotCounter3
	next48:
	inc esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next49
	inc spotCounter3
	next49:
	inc esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next50
	inc spotCounter3
	next50:

	mov edx, 0
	cmp spotCounter3, 3
	jne noWin16
	mov edx, -2
	jmp getout3
	noWin16:

	;// L to R intermediate pt 2
	mov esi, 0
	mov ebx, ptrGrid4
	add ebx, rowsize
	mov edx, 0

	mov spotCounter3, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next51
	inc spotCounter3
	next51:
	inc esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next52
	inc spotCounter3
	next52:
	inc esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next53
	inc spotCounter3
	next53:

	mov edx, 0
	cmp spotCounter3, 3
	jne noWin17
	mov edx, -2
	jmp getout3
	noWin17:

	;/////
	;// R to L intermediate pt 1
	mov esi, 2
	mov ebx, ptrGrid4
	mov edx, 0

	mov spotCounter3, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next54
	inc spotCounter3
	next54:
	dec esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next55
	inc spotCounter3
	next55:
	dec esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next56
	inc spotCounter3
	next56:

	mov edx, 0
	cmp spotCounter3, 3
	jne noWin18
	mov edx, -2
	jmp getout3
	noWin18:

	;// R to L intermediate pt 2
	mov esi, 3
	mov ebx, ptrGrid4
	add ebx, rowsize
	mov edx, 0

	mov spotCounter3, 0

	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next57
	inc spotCounter3
	next57:
	dec esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next58
	inc spotCounter3
	next58:
	dec esi
	add ebx, rowsize
	movzx edx, byte ptr [ebx + esi]
	cmp edx, 2
	jne next59
	inc spotCounter3
	next59:

	mov edx, 0
	cmp spotCounter3, 3
	jne noWin19
	mov edx, -2
	jmp getout3
	noWin19:

getout3:
ret
checkWinDiagP2 endp
;//////

clearBoard proc,
ptrtheGrid:ptr byte
.data
holdMyCount dword 0
.code
mov ebx, ptrtheGrid

mov ecx, 4
clearIt:
mov holdMyCount, ecx

	mov esi, 0
	mov ecx, 4
	clearRow:
	mov eax, 0
	mov byte ptr [ebx + esi], al
	inc esi
	loop clearRow

mov ecx, holdMyCount
add ebx, rowSize
loop clearIt
ret
clearBoard endp

placePiece proc,
ptrTheGrid:ptr byte,
columnChoice:dword,
whichPlayer:byte
.data
currentRow byte 0
.code
mov currentRow, 0
mov esi, columnChoice
dec esi
mov ebx, ptrTheGrid

mov eax, 0
mov al, RowSize
mul currentRow
		;// if column is full then return -1 in ebx

;movzx eax, ax
;add ebx, eax			;// check first spot to see if column is full
movzx edx, byte ptr[ebx + esi]
cmp edx, 0
je checkrow2
mov ebx, -1
jmp goBack
checkrow2:
add ebx, RowSize
movzx edx, byte ptr [ebx + esi]
cmp edx, 0
je checkRow3
sub ebx, RowSize
movzx edx, whichPlayer
mov byte ptr [ebx + esi], dl
jmp goBack
checkRow3:
add ebx, RowSize
movzx edx, byte ptr [ebx + esi]
cmp edx, 0
je checkRow4
sub ebx, RowSize
movzx edx, whichPlayer
mov byte ptr [ebx + esi], dl
jmp goBack
checkRow4:
add ebx, RowSize
movzx edx, byte ptr [ebx + esi]
cmp edx, 0
je Row4
sub ebx, RowSize
movzx edx, whichPlayer
mov byte ptr [ebx + esi], dl
Row4:
movzx edx, whichPlayer
mov byte ptr [ebx + esi], dl

goBack:
ret
placePiece endp

printGrid proc,
ptrCoordinates:ptr byte
.data
blankSpace byte "    ", 0h
divider byte "|", 0h
coordinates byte "| 1  | 2  | 3  | 4  |",0h
line byte "---------------------", 0h
sizeOfRow1 byte 0 
countHolder dword 0
currentrowIndex byte 0
.code
mov currentRowIndex, 0
mov eax, 0
mov ebx, ptrCoordinates
mov esi, 0
mov edx, offset coordinates
call writestring
call crlf
;// will take in the tableB array so that you can check which coordinates to print and how to do that
mov edx, offset line
call writestring

mov ecx, 4
displayGrid:
call crlf

mov countHolder, ecx

	mov ecx, 4
	mov esi, 0
	displayRow:
	mov eax, 0 
	mov edx, offset divider
	call writestring

	mov al, byte ptr [ebx + esi]
	movzx eax, al

	invoke spaceColor, eax

	mov edx, offset blankSpace
	call writestring

	mov eax, defaultcolor
	call settextcolor

	inc esi
	loop displayRow

call crlf
mov edx, offset line
call writestring

add ebx, rowSize
mov ecx, countHolder
loop displaygrid


ret
printGrid endp

spaceColor proc,
currentSpace:dword

mov eax, currentSpace

cmp eax, 0
jne tryblue
mov eax, defaultcolor
call settextcolor
jmp loopagain

tryblue :
cmp eax, 1
jne tryYellow
mov eax, bluecolor
call settextcolor
jmp loopagain

tryYellow :
cmp eax, 2
jne loopAgain
mov eax, yellowcolor
call settextcolor

loopagain :

ret
spacecolor endp

CompVComp proc,
ptrGrid:ptr byte
.data
rVal dword 0
playerTracker byte 0
numTurns byte 0		;// should not exceed 16
counter byte 0
winMessage1 byte "Player ",0h
winMessage2 byte " has won!", 0h
winnerwinnerchickendinner dword 0
currentplayermessage1 byte "Player ", 0h
currentplayermessage2 byte "'s turn", 0h
drawmessage byte "It's a tie!", 0h
.code
mov ebx, ptrGrid
mov winnerwinnerchickendinner, 0

mov counter, 16d
mov playertracker, 1
play:
mov rVal, 0
mov eax, 4
call randomRange
inc eax
mov rVal, eax

invoke placePiece, ptrGrid, rval, playerTracker

push ebx

mov edx, 0
invoke checkWinHoriz, ptrGrid
mov winnerwinnerchickendinner, edx
cmp winnerwinnerchickendinner, 0
jne nomoreChecks

invoke checkWinvert, ptrGrid
mov winnerwinnerchickendinner, edx
cmp winnerwinnerchickendinner, 0
jne nomorechecks

invoke checkWinDiagP1, ptrGrid
mov winnerwinnerchickendinner, edx
cmp winnerwinnerchickendinner, 0
jne nomorechecks

invoke checkWinDiagP2, ptrGrid
mov winnerwinnerchickendinner, edx
cmp winnerwinnerchickendinner, 0
jne nomorechecks

nomorechecks:

pop ebx

call clrscr

mov edx, offset currentplayermessage1
call writestring
movzx eax, playertracker
call writedec
mov edx, offset currentplayermessage2
call writestring
call crlf

cmp ebx, -1
je play
cmp playertracker, 1
jne player2turn
mov playertracker, 2
jmp goAgain
player2turn:
mov playertracker, 1

goAgain:

invoke printGrid, ptrGrid
cmp winnerwinnerchickendinner, -1
jne maybep2
mov playertracker, 1
jmp tothemessages
maybep2:
cmp winnerwinnerchickendinner, -2
jne nowinner
mov playertracker, 2
tothemessages:
call crlf
mov edx, offset winmessage1
call writestring
movzx eax, playertracker
call writedec
mov edx, offset winmessage2
call writestring
call crlf
jmp outofLoop
nowinner:
mov eax, 2000
call delay
dec counter
cmp counter, 0
je outofLoop
jmp play

outofLoop:

cmp winnerwinnerchickendinner, 0
jne thereisawinner
mov edx, offset drawmessage
call writestring
thereisawinner:

ret
CompVComp endp
; ====================================================================================
ClearRegisters Proc
;// Description:  Clears the registers EAX, EBX, ECX, EDX, ESI, EDI
;// Requires:  Nothing
;// Returns:  Nothing, but all registers will be cleared.

cleareax
clearebx
clearecx
clearedx
clearesi
clearedi

ret
ClearRegisters ENDP
; ====================================================================================
; ====================================================================================
END main
; ====================================================================================