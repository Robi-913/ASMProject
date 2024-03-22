.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Poker",0
area_width EQU 640
area_height EQU 480
area DD 0


b_x_h equ 250
b_y_h equ 440
b_size_h equ 120

b_x_v equ 250
b_y_v equ 391
b_size_v equ 50


verificare1 dd 0
verificare2 dd -1
verificare3 dd 0
counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
arg5 equ 24


low_ equ 1; nr min de carti
max_ equ 52; nr maxim de carti
format db "%d ", 0
vec db 7 dup(0)
lungime db $-vec
poz_precedenta dd 0

vector_culoare db 5 dup(0)
vector_carte db 6 dup(0)
vector_carti_frecventa_fullhouse db 14 dup(0)
vector_carti_frecventa_straight db 14 dup(0)
vector_carti_frecventa_three db 14 dup(0)
vector_carti_frecventa_twopair db 14 dup(0)
vector_carti_frecventa_onepair db 14 dup(0)


card_ dd 0
poz_x_card dd 75
poz_y_card dd 170

buton_skin dd 0

cards_punctaj dd 0

symbol_width EQU 10
symbol_height EQU 20
image_width EQU 48; cat de lata este imaginea
image_height EQU 100; cat de inalta este imaginea
image_width_2 EQU 24; cat de lata este imaginea
image_height_2 EQU 100; cat de inalta este imaginea
include digits.inc
include letters.inc
include cards.inc
include proiect.inc

.code

; arg1 - nr de carti pe care vrem sa il generam
generare_carti proc
    
	push ebp
    mov ebp, esp 
    sub esp, 4
	
	
    mov ecx, [ebp+arg1]; afiseaza atatea numere random cate vreau
	mov esi, poz_precedenta; pointer pentru  vector
	
	rand:
	mov eax, 0; am initializt eax cu 0 unde vom pune valoarea random
	rdtsc ; pune eax o valoare oarecare
	mov ebx, 0; initializam  ebx cu 0 
	mov ebx, max_
	sub ebx, low_; formam numarul cu care modulom pentru a avea un nr intre 0 si 51
	mov edx, 0; in edx vine un nr generat random 
	div ebx ; face inpartia sa primim nr 
	add edx, low_
	
	mov ebx,-1; folosim acum ebx pe post de pozitie in vector
	
	verificare:
	inc ebx; ebxul devine 0
	cmp dl, vec[ebx]; compar elemetul generat cu primul elemt din vector
	je rand; daca is egale sarim sa generam alt nr
	cmp vec[ebx],0
	je printare; daca pe pozitia vectorului este -1 atunci sarim sa afisam nr generat
	cmp ebx,max_
	je printare; in caz ca ebx ajunge la 4 atunci inseamna ca nu mai avem elemnte in vector 
	jmp verificare
	
	
	
	printare:
	mov vec[esi], dl; mut in vector elemntul ca sa il putem a verifica daca avem dubluri de nr
	inc esi; trecem la urmatorul el al vectorului
	
	loop rand; repetam tot procesul
	
	mov poz_precedenta, esi
	
	mov esp, ebp
	pop ebp
	ret 
generare_carti endp

generare_carti_macro macro count

    push count
	call generare_carti
	add esp, 4
endm


sort_cards proc 

    push ebp
    mov ebp, esp 
   
   
   
    lea esi, vec
	mov ebx, 0
	sort:	
	mov eax, 0
    mov al, [esi]
    cmp ah, [esi+1]
    je stop_sort	
    cmp al, [esi + 1]               
    jle next_sort                

    xchg al, [esi + 1]              
    mov [esi], al 

 
    next_sort:
	inc esi
	jmp sort
	
	
	stop_sort:
	inc ebx
	lea esi, vec
	cmp bl, lungime
	jl sort

	mov esp, ebp
	pop ebp
	ret 
sort_cards endp

sort_cards_macro macro

    call sort_cards
endm

generare_carte_noua_macro macro arg
   generare_carti_macro 1
	mov ebx, 0
	mov bl, vec[5]
	mov vec[arg], bl
	mov vec[5], 0
	dec poz_precedenta

endm

; Make an image at the given coordinates
; arg1 - pointer to the pixel vector
; arg2 - x of drawing start position
; arg3 - y of drawing start position
; arg4 - the pozition of a card
make_image_1 proc
	push ebp
	mov ebp, esp
	pusha
    
	
	lea esi, var_0
	

	mov ecx, image_height
	mov eax, image_width
	mul ecx
	mov ecx, 4
	mul ecx
	mov ecx, [ebp+arg4]
	dec ecx
	mul ecx
	
	add esi, eax
	

draw_image:
    
	mov ecx, image_height
	;add ecx, 132
	
	
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, image_height 
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, image_width; store drawing width for drawing loop
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov ebx, buton_skin
	cmp ebx, 1
	jne skip_culoare_1
	shl eax, 100
	skip_culoare_1:
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	
	loop loop_draw_lines
	
	
	res_img:
	popa
	mov esp, ebp
	pop ebp
	ret
make_image_1 endp

; simple macro to call the procedure easier
make_image_1_macro macro drawArea, x, y, nr_cards; adaugam o variabila noua la functia de generare a imaginii care reprezinta a cata carte o vrem
	push nr_cards; devine arg4
	push y
	push x
	push drawArea
	call make_image_1
	add esp, 16; avem 4 argumente deci eliberam stiva cu 16 
endm



make_image_2 proc
	push ebp
	mov ebp, esp
	pusha
    
	
	lea esi, var_1
	

	mov ecx, image_height_2
	mov eax, image_width_2
	mul ecx
	mov ecx, 4
	mul ecx
	mov ecx, [ebp+arg4]
	dec ecx
	mul ecx
	
	add esi, eax
	

	
draw_image:
    
	mov ecx, image_height_2
	;add ecx, 132
	
	
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, image_height_2
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, image_width_2; store drawing width for drawing loop
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov ebx, buton_skin
	cmp ebx, 1
	jne skip_culoare_2
	shl eax, 100
	skip_culoare_2:
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	
	loop loop_draw_lines
	
	
	res_img:
	popa
	mov esp, ebp
	pop ebp
	ret
make_image_2 endp

; simple macro to call the procedure easier
make_image_2_macro macro drawArea, x, y, nr_cards; adaugam o variabila noua la functia de generare a imaginii care reprezinta a cata carte o vrem
	push nr_cards; devine arg4
	push y
	push x
	push drawArea
	call make_image_2
	add esp, 16; avem 4 argumente deci eliberam stiva cu 16 
endm



make_image_project proc
	push ebp
	mov ebp, esp
	pusha
    
	
	lea esi, project_imige

	mov ecx, [ebp +arg5]
	mov eax, 48
	mul ecx
	mov ecx, 4
	mul ecx
	mov ecx, [ebp+arg4]
	dec ecx
	mul ecx
	
	add esi, eax
	

	
draw_image:
    
	mov ecx, [ebp +arg5]
	;add ecx, 132
	
	
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, [ebp +arg5]
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, 48; store drawing width for drawing loop
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	
	loop loop_draw_lines
	
	
	res_img:
	popa
	mov esp, ebp
	pop ebp
	ret
make_image_project endp

make_image_project_macro macro drawArea, x, y, nrim, height; adaugam o variabila noua la functia de generare a imaginii care reprezinta a cata carte o vrem
	push height; devine arg5
	push nrim; devine arg4
	push y
	push x
	push drawArea
	call make_image_project
	add esp, 20; avem 5 argumente deci eliberam stiva cu 16 
endm

horizontal macro x, y, len, color
local bucla_linie
 	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, len
	bucla_linie:
	mov dword ptr[eax], color
	add eax, 4
	loop bucla_linie
endm



vertical macro x, y, len, color
local bucla_linie
 	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, len
	bucla_linie:
	mov dword ptr[eax], color
	add eax, 4*area_width
	loop bucla_linie
endm


backround macro x, y, len, color
local bucla
    mov eax, y
	imul eax, area_height
	add eax, x
	imul eax, 4
	add eax, area
	mov ecx, len

bucla:
    mov dword ptr[eax], color
	add eax, 4
	loop bucla

endm
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax ;jk
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 09d03fch
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

resetare_vector_frecventa_fullhouse_macro macro
	
	local Loop_vector_carte_frecventa_reset
	
	mov ecx, 14
	mov esi, 0
	
	Loop_vector_carte_frecventa_reset:
	
	mov vector_carti_frecventa_fullhouse[esi], 0
	inc esi
	loop Loop_vector_carte_frecventa_reset

endm

resetare_vector_frecventa_straight_macro macro
	
	local Loop_vector_carte_frecventa_reset
	
	mov ecx, 14
	mov esi, 0
	
	Loop_vector_carte_frecventa_reset:
	
	mov vector_carti_frecventa_straight[esi], 0
	inc esi
	loop Loop_vector_carte_frecventa_reset

endm

resetare_vector_frecventa_three_macro macro
	
	local Loop_vector_carte_frecventa_reset
	
	mov ecx, 14
	mov esi, 0
	
	Loop_vector_carte_frecventa_reset:
	
	mov vector_carti_frecventa_three[esi], 0
	inc esi
	loop Loop_vector_carte_frecventa_reset

endm

resetare_vector_frecventa_twopair_macro macro
	
	local Loop_vector_carte_frecventa_reset
	
	mov ecx, 14
	mov esi, 0
	
	Loop_vector_carte_frecventa_reset:
	
	mov vector_carti_frecventa_twopair[esi], 0
	inc esi
	loop Loop_vector_carte_frecventa_reset

endm

resetare_vector_frecventa_onepair_macro macro
	
	local Loop_vector_carte_frecventa_reset
	
	mov ecx, 14
	mov esi, 0
	
	Loop_vector_carte_frecventa_reset:
	
	mov vector_carti_frecventa_onepair[esi], 0
	inc esi
	loop Loop_vector_carte_frecventa_reset

endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
 
	push ebp
	mov ebp, esp
	pusha
	
	pornire:
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
	mov edi, area
	mov ecx, area_height
	mov ebx, [ebp+arg3]
	and ebx, 7
	inc ebx
	
	
	mov eax, [ebp+arg2]
	cmp eax, 250
	jl afisare_litere
	cmp eax, 370
	jg afisare_litere
	mov eax, [ebp+arg3]
	cmp eax, 390
	jl afisare_litere
	cmp eax,440
	jg afisare_litere
	
	
	jmp dispare_litere
	
	
	
evt_timer:
	inc counter
	
	
afisare_litere:
    backround 0, 0, area_width*area_height, 09d03fch
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	mov esi, verificare1
	cmp esi, 0
	jg dispare_litere
	
	
	horizontal b_x_h, b_y_h, b_size_h, 0fcb103h
	horizontal b_x_h, b_y_h-1, b_size_h, 0fcb103h
	horizontal b_x_h, b_y_h-2, b_size_h, 0fcb103h
	horizontal b_x_h, b_y_h-50, b_size_h, 0fcb103h
	horizontal b_x_h, b_y_h-49, b_size_h, 0fcb103h
	horizontal b_x_h, b_y_h-48, b_size_h, 0fcb103h
	
	vertical b_x_v, b_y_v, b_size_v, 0fcb103h
	vertical b_x_v+1, b_y_v, b_size_v, 0fcb103h
	vertical b_x_v+2, b_y_v, b_size_v, 0fcb103h
	vertical b_x_v+120, b_y_v, b_size_v, 0fcb103h
	vertical b_x_v+119, b_y_v, b_size_v, 0fcb103h
	vertical b_x_v+118, b_y_v, b_size_v, 0fcb103h
	
	
	
	
	make_text_macro 'D', area, 260, 405
	make_text_macro 'E', area, 270, 405
	make_text_macro 'A', area, 280, 405
	make_text_macro 'L', area, 290, 405
	
	make_text_macro 'C', area, 310, 405
	make_text_macro 'A', area, 320, 405
	make_text_macro 'R', area, 330, 405
	make_text_macro 'D', area, 340, 405
	make_text_macro 'S', area, 350, 405
	
	
	make_image_project_macro area, 190, 70, 1, 200
	make_image_project_macro area, 238, 70, 2, 200
	make_image_project_macro area, 286, 70, 3, 200
	make_image_project_macro area, 334, 70, 4, 200
	make_image_project_macro area, 382, 70, 5, 200


	make_image_project_macro area, 140, 370, 11, 100
	make_image_project_macro area, 188, 370, 12, 100
	
	make_image_project_macro area, 382, 370, 11, 100
	make_image_project_macro area, 430, 370, 12, 100
	
	
	
	make_text_macro 'A', area, 460, 20
	make_text_macro 'R', area, 470, 20
	make_text_macro 'D', area, 480, 20
	make_text_macro 'E', area, 490, 20
	make_text_macro 'L', area, 500, 20
	make_text_macro 'E', area, 510, 20
	make_text_macro 'A', area, 520, 20
	make_text_macro 'N', area, 530, 20
	
	make_text_macro 'R', area, 550, 20
	make_text_macro 'O', area, 560, 20
	make_text_macro 'B', area, 570, 20
	make_text_macro 'E', area, 580, 20
	make_text_macro 'R', area, 590, 20
	make_text_macro 'T', area, 600, 20

	
	
	jmp final_draw
	
	
dispare_litere:
   inc verificare1
 
ecran_carti:

	
	backround 0, 0, area_width*area_height, 09d03fch
	
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	
	
	mov esi, verificare2
	
	cmp esi, 0
	jl generare_carte
	jmp afisare_carti
	generare_carte:
	generare_carti_macro 5
	sort_cards_macro
	inc verificare2
	
afisare_carti:



	horizontal b_x_h, b_y_h-330, b_size_h, 0fcb103h
	horizontal b_x_h, b_y_h-331, b_size_h, 0fcb103h
	horizontal b_x_h, b_y_h-332, b_size_h, 0fcb103h
	horizontal b_x_h, b_y_h-380, b_size_h, 0fcb103h
	horizontal b_x_h, b_y_h-379, b_size_h, 0fcb103h
	horizontal b_x_h, b_y_h-378, b_size_h, 0fcb103h
	
	vertical b_x_v, b_y_v-330, b_size_v, 0fcb103h
	vertical b_x_v+1, b_y_v-330, b_size_v, 0fcb103h
	vertical b_x_v+2, b_y_v-330, b_size_v, 0fcb103h
	vertical b_x_v+120, b_y_v-330, b_size_v, 0fcb103h
	vertical b_x_v+119, b_y_v-330, b_size_v, 0fcb103h
	vertical b_x_v+118, b_y_v-330, b_size_v, 0fcb103h
	
	
	make_text_macro 'S', area, 290, 76
	make_text_macro 'K', area, 300, 76
	make_text_macro 'I', area, 310, 76
	make_text_macro 'N', area, 320, 76
	
	
	make_text_macro 'B', area, 580, 15
	make_text_macro 'A', area, 590, 15
	make_text_macro 'C', area, 600, 15
	make_text_macro 'K', area, 610, 15
	
	mov ebx, [ebp+arg2]
	cmp ebx, 580
	jl skin
	cmp ebx, 610
	jg skin
	mov ebx, [ebp+arg3]
	cmp ebx, 15
	jl skin
	cmp ebx, 35
	jg skin
	
	mov verificare2, -1
	mov verificare1, 0
	
	
	skin:
	mov ebx, [ebp+arg2]
	cmp ebx, 250
	jl cards_afisare
	cmp ebx, 370
	jg cards_afisare
	mov ebx, [ebp+arg3]
	cmp ebx, 60
	jl cards_afisare
	cmp ebx, 110
	jg cards_afisare
	
	
	add buton_skin, 1
	mov eax, buton_skin
	cmp eax, 1
	
	je cards_afisare
	mov buton_skin, 0
	
	
	cards_afisare:
	
	mov eax, 0
	mov al, vec[0]
	mov card_, eax
	make_image_1_macro area,72, poz_y_card, card_
	make_image_2_macro area,120, poz_y_card, card_
	
	mov edx, 0
	mov ecx, 13
	div ecx
	inc al
	cmp dl, 0
	je as0
	mov vector_culoare[0], al
	mov vector_carte[0], dl
	jmp as_next0
	as0:
	mov dl, 13
	dec al
	mov vector_culoare[0], al
	mov vector_carte[0], dl
	
	as_next0:
	
	; push eax
	; push edx
	; push offset format
	; call printf
	; add esp, 12
	
	
	mov ebx, [ebp+arg2]
	cmp ebx, 71
	jl next_card1
	cmp ebx, 145
	jg next_card1
	mov ebx, [ebp+arg3]
	cmp ebx, 170
	jl next_card1
	cmp ebx, 270
	jg next_card1
	jmp generare_carte_noua0
	
	next_card1:
	mov eax, 0
	mov al, vec[1]
	mov card_, eax
	make_image_1_macro area,172, poz_y_card, card_
	make_image_2_macro area,220, poz_y_card, card_
	
	mov edx, 0
	mov ecx, 13
	div ecx
	inc al
	cmp dl, 0
	je as1
	mov vector_culoare[1], al
	mov vector_carte[1], dl
	jmp as_next1
	as1:
	mov dl, 13
	dec al
	mov vector_culoare[1], al
	mov vector_carte[1], dl
	
	as_next1:
	
	; push eax
	; push edx
	; push offset format
	; call printf
	; add esp, 12
	
	mov ebx, [ebp+arg2]
	cmp ebx, 171
	jl next_card2
	cmp ebx, 245
	jg next_card2
	mov ebx, [ebp+arg3]
	cmp ebx, 170
	jl next_card2
	cmp ebx, 270
	jg next_card2
	jmp generare_carte_noua1
	
	next_card2:
	mov eax, 0
	mov al, vec[2]
	mov card_, eax
	make_image_1_macro area,272, poz_y_card, card_
	make_image_2_macro area,320, poz_y_card, card_
	
	mov edx, 0
	mov ecx, 13
	div ecx
	inc al
	cmp dl, 0
	je as2
	mov vector_culoare[2], al
	mov vector_carte[2], dl
	jmp as_next2
	as2:
	mov dl, 13
	dec al
	mov vector_culoare[2], al
	mov vector_carte[2], dl
	
	as_next2:
	
	; push eax
	; push edx
	; push offset format
	; call printf
	; add esp, 12
	
	
	mov ebx, [ebp+arg2]
	cmp ebx, 271
	jl next_card3
	cmp ebx, 345
	jg next_card3
	mov ebx, [ebp+arg3]
	cmp ebx, 170
	jl next_card3
	cmp ebx, 270
	jg next_card3
	jmp generare_carte_noua2
	
	next_card3:
	mov eax, 0
	mov al, vec[3]
	mov card_, eax
	make_image_1_macro area,372, poz_y_card, card_
	make_image_2_macro area,420, poz_y_card, card_
	
	mov edx, 0
	mov ecx, 13
	div ecx
	inc al
	cmp dl, 0
	je as3
	mov vector_culoare[3], al
	mov vector_carte[3], dl
	jmp as_next3
	as3:
	mov dl, 13
	dec al
	mov vector_culoare[3], al
	mov vector_carte[3], dl
	
	
	as_next3:
	
	; push eax
	; push edx
	; push offset format
	; call printf
	; add esp, 12
	
	mov ebx, [ebp+arg2]
	cmp ebx, 371
	jl next_card4
	cmp ebx, 445
	jg next_card4
	mov ebx, [ebp+arg3]
	cmp ebx, 170
	jl next_card4
	cmp ebx, 270
	jg next_card4
	jmp generare_carte_noua3
	
	next_card4:
	mov eax, 0
	mov al, vec[4]
	mov card_, eax
	make_image_1_macro area,472, poz_y_card, card_
	make_image_2_macro area,520, poz_y_card, card_
	
	mov edx, 0
	mov ecx, 13
	div ecx
	inc al
	cmp dl, 0
	je as4
	mov vector_culoare[4], al
	mov vector_carte[4], dl
	jmp as_next4
	as4:
	mov dl, 13
	dec al
	mov vector_culoare[4], al
	mov vector_carte[4], dl
	
	as_next4:
	
	; push eax
	; push edx
	; push offset format
	; call printf
	; add esp, 12
	
	mov ebx, [ebp+arg2]
	cmp ebx, 471
	jl next_card
	cmp ebx, 545
	jg next_card
	mov ebx, [ebp+arg3]
	cmp ebx, 170
	jl next_card
	cmp ebx, 270
	jg next_card
	jmp generare_carte_noua4
	
	
	next_card:
	sort_cards_macro
	jmp cards_hands
	
	generare_carte_noua0:
	generare_carte_noua_macro 0
	jmp next_card1
	
	generare_carte_noua1:
	generare_carte_noua_macro 1
	jmp next_card2
	
	generare_carte_noua2:
	generare_carte_noua_macro 2
	jmp next_card3
	
	generare_carte_noua3:
	generare_carte_noua_macro 3
	jmp next_card4
	
	generare_carte_noua4:
	generare_carte_noua_macro 4
	jmp next_card
	
	
	cards_hands:
	
	resetare_vector_frecventa_fullhouse_macro
	resetare_vector_frecventa_straight_macro
	resetare_vector_frecventa_three_macro
	resetare_vector_frecventa_twopair_macro
	resetare_vector_frecventa_onepair_macro
	
	
	straight_flash:
	lea esi, vector_culoare
	lea edi, vector_carte
	mov ecx, 4
	mov ebx, 0
	
	push ecx
	
	L_straight_flash_culoare:
	
	mov eax, 0
	mov al, [esi]
	cmp al, [esi+1]
	je incrementare_straight_flash
	jmp skip_L_straight_flash
	
	incrementare_straight_flash:
	inc esi
	inc bl
	
	skip_L_straight_flash:
	loop L_straight_flash_culoare
	
	pop ecx
	cmp bl, 4
	je L_straight_flash_carti
	jmp four_of_a_kind
	
	L_straight_flash_carti:
	
	mov eax, 0
	mov al, [edi]
	mov ah, [edi+1]
	sub ah, al
	cmp ah, 1
	je incrementare_straight_flash1
	jmp skip_L_straight_flash1
	
	incrementare_straight_flash1:
	inc edi
	inc bh
	
	skip_L_straight_flash1:
	
	loop L_straight_flash_carti
	
	cmp bh, 4
	je afisare_mesaj_straight_flash
	jmp four_of_a_kind
	
	afisare_mesaj_straight_flash:
	
	make_text_macro 'S', area, 240, 390
	make_text_macro 'T', area, 250, 390
	make_text_macro 'A', area, 260, 390
	make_text_macro 'I', area, 270, 390
	make_text_macro 'G', area, 280, 390
	make_text_macro 'H', area, 290, 390
	make_text_macro 'T', area, 300, 390
	
	
	make_text_macro 'F', area, 320, 390
	make_text_macro 'L', area, 330, 390
	make_text_macro 'U', area, 340, 390
	make_text_macro 'S', area, 350, 390
	make_text_macro 'H', area, 360, 390
	

	mov eax, 0
	mov al, vector_carte[0]
	add al, vector_carte[1]
	add al, vector_carte[2]
	add al, vector_carte[3]
	add al, vector_carte[4]
	
	
	mov ebx, 10
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 295, 430
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 305, 430
	
	

	jmp final_draw
	
	
	four_of_a_kind:
	mov ebx, 0
	lea esi, vector_carte
	lea edi, vector_carte
	mov ecx, 4
	
	
	L_four_of_a_kind:
	
	chack_four_of_a_kind:
	
	
	mov al,[edi]
	cmp al, [esi+1]
	je incrementare_four_of_a_kind
	jmp skip_L_four_of_a_kind
	
	incrementare_four_of_a_kind:
	inc esi
	inc ebx
	jmp chack_four_of_a_kind
	
	skip_L_four_of_a_kind:
	inc esi
	
	loop L_four_of_a_kind
	
	cmp ebx, 0
	jne comparare_finala_four
	
	lea esi, vector_carte
	lea edi, vector_carte
	mov ecx, 4
	
	L_four_of_a_kind1:
	
	chack_four_of_a_kind1:
	
	
	mov al,[edi+1]
	cmp al, [esi+2]
	je incrementare_four_of_a_kind1
	jmp skip_L_four_of_a_kind1
	
	incrementare_four_of_a_kind1:
	inc esi
	inc ebx
	jmp chack_four_of_a_kind1
	
	skip_L_four_of_a_kind1:
	inc esi
	
	loop L_four_of_a_kind1
	
	
	comparare_finala_four:
	cmp ebx, 3
	jge afisare_mesaj_four_of_a_kind
	jmp full_house
	
	afisare_mesaj_four_of_a_kind:
	
	make_text_macro 'F', area, 240, 390
	make_text_macro 'O', area, 250, 390
	make_text_macro 'U', area, 260, 390
	make_text_macro 'R', area, 270, 390
	
	make_text_macro 'O', area, 290, 390
	make_text_macro 'F', area, 300, 390
	
	make_text_macro 'A', area, 320, 390
	
	make_text_macro 'K', area, 340, 390
	make_text_macro 'I', area, 350, 390
	make_text_macro 'N', area, 360, 390
	make_text_macro 'D', area, 370, 390
	
	mov eax, 0
	mov al, vector_carte[0]
	add al, vector_carte[1]
	add al, vector_carte[2]
	add al, vector_carte[3]
	add al, vector_carte[4]
	
	
	mov ebx, 10
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 295, 430
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 305, 430
	
	
	jmp final_draw
	
	
	full_house:
	
	mov esi, 0
	mov ebx, 0
	
	check_full_house:
	
	mov bl, vector_carte[esi]
	
	cmp bl, 0
	je stop_checking
	
	add vector_carti_frecventa_fullhouse[ebx], 1
	inc esi
	jmp check_full_house
	
	stop_checking:
	
	mov ecx, 14
	mov esi, 0
	mov eax, 0
	mov edi, 0
	
	verificare_tree_ofakind:
	mov al, vector_carti_frecventa_fullhouse[esi]
	
	cmp al, 0
	je inc_full_house
	
	cmp al, 3
	je check_full_house_pair
	
	inc esi
	jmp verificare_tree_ofakind
	
	inc_full_house:
	
	inc esi
	cmp esi, 14
	jg flush
	jmp verificare_tree_ofakind
	
	check_full_house_pair:
	
	mov al, vector_carti_frecventa_fullhouse[edi]
	
	cmp al, 0
	je inc_full_house_pair
	
	cmp al, 2
	je afisare_mesaj_full_house
	
	inc edi
	jmp check_full_house_pair
	
	inc_full_house_pair:
	inc edi
	cmp edi, 14
	jg flush
	jmp check_full_house_pair
	
	afisare_mesaj_full_house:
	
	
	make_text_macro 'F', area, 260, 390
	make_text_macro 'U', area, 270, 390
	make_text_macro 'L', area, 280, 390
	make_text_macro 'L', area, 290, 390
	
	make_text_macro 'H', area, 310, 390
	make_text_macro 'O', area, 320, 390
	make_text_macro 'U', area, 330, 390
	make_text_macro 'S', area, 340, 390
	make_text_macro 'E', area, 350, 390
	
	mov eax, 0
	mov al, vector_carte[0]
	add al, vector_carte[1]
	add al, vector_carte[2]
	add al, vector_carte[3]
	add al, vector_carte[4]
	
	
	mov ebx, 10
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 295, 430
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 305, 430
	
	
	jmp final_draw
	
	
	flush:
	
	lea esi, vector_culoare
	mov eax, 0
	mov ecx, 4
	
	L_flush:
	
	mov ah, [esi]
	cmp ah, [esi+1]
	jne inc_flush
	
	add al, 1
	inc esi
	jmp next_L_lush
	
	inc_flush:
	inc esi
	
	next_L_lush:
	loop L_flush
	
	cmp al, 4
	je afisare_mesaj_flush
	
	jmp straight
	
	afisare_mesaj_flush:
	
	
	make_text_macro 'F', area, 285, 390
	make_text_macro 'L', area, 295, 390
	make_text_macro 'U', area, 305, 390
	make_text_macro 'S', area, 315, 390
	make_text_macro 'E', area, 325, 390
	
	mov eax, 0
	mov al, vector_carte[0]
	add al, vector_carte[1]
	add al, vector_carte[2]
	add al, vector_carte[3]
	add al, vector_carte[4]
	
	
	mov ebx, 10
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 295, 430
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 305, 430
	
	
	jmp final_draw
	
	
	straight:
	
	mov esi, 0
	mov ebx, 0
	
	check_straight:
	
	mov bl, vector_carte[esi]
	
	cmp bl, 0
	je stop_checking_s
	
	add vector_carti_frecventa_straight[ebx], 1
	inc esi
	jmp check_straight
	
	stop_checking_s:
	
	
	
	;verificare 5 unu dupa altul
	lea esi, vector_carti_frecventa_straight
	mov ebx, 0
	mov ecx, 0
	mov edi, 0
	
	verificare_straight:
	
	cmp ecx, 14
	je three_ofa_kind
	
	mov bl, [esi]
	cmp bl, 0
	je incrementare_straight
	
	
	cmp bl, 1
	jne incrementare_straight
	
	inc bh
	inc esi
	inc ecx
	
	cmp bh, 5
	je afisare_mesaj_straight
	jmp verificare_straight
	
	
	
	incrementare_straight:
	mov bh, 0
	inc esi
	inc ecx
	jmp verificare_straight
	
	
	
	afisare_mesaj_straight:
	
	make_text_macro 'S', area, 270, 390
	make_text_macro 'T', area, 280, 390
	make_text_macro 'R', area, 290, 390
	make_text_macro 'A', area, 300, 390
	make_text_macro 'I', area, 310, 390
	make_text_macro 'G', area, 320, 390
	make_text_macro 'H', area, 330, 390
	make_text_macro 'T', area, 340, 390
	
	
	mov eax, 0
	mov al, vector_carte[0]
	add al, vector_carte[1]
	add al, vector_carte[2]
	add al, vector_carte[3]
	add al, vector_carte[4]
	
	
	mov ebx, 10
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 295, 430
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 305, 430

	
	jmp final_draw
	
	three_ofa_kind:
	
	mov esi, 0
	mov ebx, 0
	
	
	check_threeofa_kind:
	
	mov bl, vector_carte[esi]
	
	cmp bl, 0
	je stop_checking_t
	
	add vector_carti_frecventa_three[ebx], 1
	inc esi
	jmp check_threeofa_kind
	
	stop_checking_t:
	
	mov ecx, 14
	mov esi, 0
	mov eax, 0
	mov edi, 0
	
	verificare_three_ofakind:
	mov al, vector_carti_frecventa_three[esi]
	
	cmp al, 0
	je inc_three_of_kind
	
	cmp al, 3
	je afisare_mesaj_three_ofa_kind
	
	inc esi
	jmp verificare_three_ofakind
	
	inc_three_of_kind:
	
	inc esi
	cmp esi, 14
	jg two_pair
	jmp verificare_three_ofakind
	
	afisare_mesaj_three_ofa_kind:
	
	make_text_macro 'T', area, 240, 390
	make_text_macro 'H', area, 250, 390
	make_text_macro 'R', area, 260, 390
	make_text_macro 'E', area, 270, 390
	make_text_macro 'E', area, 280, 390

	
	make_text_macro 'O', area, 295, 390
	make_text_macro 'F', area, 305, 390
	
	make_text_macro 'A', area, 320, 390
	
	make_text_macro 'K', area, 335, 390
	make_text_macro 'I', area, 345, 390
	make_text_macro 'N', area, 355, 390
	make_text_macro 'D', area, 365, 390
	
	
	mov eax, 0
	mov al, vector_carte[0]
	add al, vector_carte[1]
	add al, vector_carte[2]
	add al, vector_carte[3]
	add al, vector_carte[4]
	
	
	mov ebx, 10
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 295, 430
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 305, 430
	
	jmp final_draw
	
	two_pair:
	
	mov esi, 0
	mov ebx, 0
	
	check_two_pair:
	
	mov bl, vector_carte[esi]
	
	cmp bl, 0
	je stop_checking_two
	
	add vector_carti_frecventa_twopair[ebx], 1
	inc esi
	jmp check_two_pair
	
	stop_checking_two:
	
	mov ecx, 14
	mov esi, 0
	mov eax, 0
	mov edx, 0
	
	verificare_twopair:
	mov al, vector_carti_frecventa_twopair[esi]
	
	cmp esi, 14
	je one_pair
	
	cmp al, 0
	je inc_twopair
	
	cmp al, 2
	je  verificare_two_pair
	
	inc_twopair:
	inc esi
	jmp verificare_twopair
	
	verificare_two_pair:
	inc edx
	inc esi
	cmp edx, 2
	je afisare_mesaj_twopair
	jmp verificare_twopair
	
	
	afisare_mesaj_twopair:
	
	make_text_macro 'T', area, 270, 390
	make_text_macro 'W', area, 280, 390
	make_text_macro 'O', area, 290, 390

	
	make_text_macro 'P', area, 310, 390
	make_text_macro 'A', area, 320, 390
	make_text_macro 'I', area, 330, 390
	make_text_macro 'R', area, 340, 390
	
	
	mov eax, 0
	mov al, vector_carte[0]
	add al, vector_carte[1]
	add al, vector_carte[2]
	add al, vector_carte[3]
	add al, vector_carte[4]
	
	
	mov ebx, 10
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 295, 430
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 305, 430

	
	jmp final_draw
	
	one_pair:
	
	mov esi, 0
	mov ebx, 0
	
	check_one_pair:
	
	mov bl, vector_carte[esi]
	
	cmp bl, 0
	je stop_checking_one
	
	add vector_carti_frecventa_onepair[ebx], 1
	inc esi
	jmp check_one_pair
	
	stop_checking_one:
	
	mov ecx, 14
	mov esi, 0
	mov eax, 0
	
	verificare_onepair:
	mov al, vector_carti_frecventa_onepair[esi]
	
	cmp esi, 14
	je high_card
	
	cmp al, 0
	je inc_onepair
	
	cmp al, 2
	je  afisare_mesaj_onepair
	
	inc_onepair:
	inc esi
	jmp verificare_onepair
	
	
	afisare_mesaj_onepair:
	
	make_text_macro 'O', area, 270, 390
	make_text_macro 'N', area, 280, 390
	make_text_macro 'E', area, 290, 390

	
	make_text_macro 'P', area, 310, 390
	make_text_macro 'A', area, 320, 390
	make_text_macro 'I', area, 330, 390
	make_text_macro 'R', area, 340, 390
	
	
	mov eax, 0
	mov al, vector_carte[0]
	add al, vector_carte[1]
	add al, vector_carte[2]
	add al, vector_carte[3]
	add al, vector_carte[4]
	
	
	mov ebx, 10
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 295, 430
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 305, 430
	
	jmp final_draw
	
	high_card:
	
	lea esi, vector_carte
	mov ebx, 0
	mov eax, 0
	mov bl, [esi]
	
	
	verificare_high_card:
	cmp eax, 5
	je afisare_mesaj_high_card
	
	cmp bl, [esi]
	jl restabilire_high_card
	
	
	inc eax
	inc esi
	jmp verificare_high_card
	
	restabilire_high_card:
	mov bl, [esi]
	inc esi
	inc eax
	jmp verificare_high_card
	
	afisare_mesaj_high_card:
	
	make_text_macro 'H', area, 265, 390
	make_text_macro 'I', area, 275, 390
	make_text_macro 'G', area, 285, 390
	make_text_macro 'H', area, 295, 390

	
	make_text_macro 'C', area, 315, 390
	make_text_macro 'A', area, 325, 390
	make_text_macro 'R', area, 335, 390
	make_text_macro 'D', area, 345, 390
	
	mov eax, 0
	mov al, vector_carte[0]
	add al, vector_carte[1]
	add al, vector_carte[2]
	add al, vector_carte[3]
	add al, vector_carte[4]
	
	
	mov ebx, 10
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 295, 430
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 305, 430

	
final_draw:

	popa
	mov esp, ebp
	pop ebp
	ret
draw endp



start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start