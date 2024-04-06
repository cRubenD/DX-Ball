.386
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
window_title DB "DX-BALL",0
area_width EQU 1000
area_height EQU 600
area DD 0

scor DD 0, 0

stop_paleta DD 0

final DB 0

startminge DB 0

format DB "%d ", 0

counter DD 0 ; numara evenimentele de tip timer
contor DD 23
contor2 DD 0

click DB 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc
include pxDXBall_Cover.inc

; buton de start al jocului
button_x EQU 460
button_y EQU 250
button_size EQU 80

; paleta 
paleta_x EQU 460
paleta_y EQU 520
paleta_size EQU 80

; mingea 
minge_x EQU 495
minge_y EQU 510
minge_size EQU 10

mingex dd 495
mingey dd 510
mingesize dd 10

;margine
margine_x dd 15
margine_xx dd 995
margine_y dd 30
margine_yy dd 570

x DB -1
y DB -1

; corpuri
corp_x dd 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850,
	   100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850 
	   
corp2_x	dd 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750

corp_xx dd 240, 290, 340, 390, 440, 490, 540, 590, 640, 690, 740, 790, 140, 190, 240, 290, 340, 390, 440, 490, 540, 590, 640, 690, 740, 790, 840, 890,
		 140, 190, 240, 290, 340, 390, 440, 490, 590, 640, 690, 740, 790, 840, 890
		 
corp2_xx dd	240, 290, 340, 390, 440, 490, 540, 590, 640, 690, 740, 790

corp_y dd 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150,
	    200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200
		
corp2_y	dd 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250
		 
corp_yy dd 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170,
		 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220
		 
corp2_yy dd	270, 270, 270, 270, 270, 270, 270, 270, 270, 270, 270, 270
		 
paleta_xx dd 0, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240, 260, 280, 300, 320, 340, 360, 380, 400, 420, 440, 460, 480, 500, 520, 540, 560, 580, 600, 620, 640, 
			660, 680, 700, 720, 740, 760, 780, 800, 820, 840, 860, 880, 900, 920
			
paleta2_xx dd 80, 100, 120, 140, 160, 180, 200, 220, 240, 260, 280, 300, 320, 340, 360, 380, 400, 420, 440, 460, 480, 500, 520, 540, 560, 580, 600, 620, 640, 
			660, 680, 700, 720, 740, 760, 780, 800, 820, 840, 860, 880, 900, 920, 940, 960, 980, 1000
			
verificare dd 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
verificare2 dd 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			
.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	lea esi, var_0
	
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
	add esi, eax
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
	mov dword ptr [edi], 0FFFFFFh
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

line_horizontal macro x, y, len, color
local bucla_line
	mov eax, y ; eax = y
	mov ebx, area_width 
	mul ebx ; eax = y * area_width
	add eax, x 
	shl eax, 2 ; eax = (y * area_width + x) * 4
	add eax, area
	mov ecx, len
bucla_line:
	mov dword ptr[eax], color
	add eax, 4
	loop bucla_line
endm

line_vertical macro x, y, len, color
local bucla_line
	mov eax, y ; eax = y
	mov ebx, area_width 
	mul ebx ; eax = y * area_width
	add eax, x 
	shl eax, 2 ; eax = (y * area_width + x) * 4
	add eax, area
	mov ecx, len
bucla_line:
	mov dword ptr[eax], color
	add eax, area_width * 4
	loop bucla_line
endm

make_button macro x, y, len, color
	line_horizontal x, y, len, color
	line_horizontal x, y + len/2, len, color
	line_vertical x, y, len/2, color
	line_vertical x + len, y, len/2, color
endm

make_paleta macro x, y, len, color
	line_horizontal x, y, len, color
	line_horizontal x, y + len/4, len, color
	line_vertical x, y, len/4, color
	line_vertical x + len, y, len/4, color
endm
	
desenare macro button_x, button_y, button_size, color
local draw_loop, draw_done, draw_pixel_loop, mai_departe, dreptunghi
    push ebp
    mov ebp, esp
    push ebx
    push esi
	push ecx

    ;CALCUL MARIME
    mov edx, button_size
    shr edx, 1
    mov ebx, button_y
	mov ecx, button_size
	cmp ecx, 40
	jae dreptunghi
    add ebx, button_size
	jmp mai_departe
	dreptunghi:
		add ebx, edx
	mai_departe:
    ;ITERATE THROUGH ROWS
    mov esi, button_y
    cmp esi, ebx
    jae draw_done
	
	mov edx, color

    draw_loop:
        ;CALCULATE ROW ADDRESS
        mov eax, esi
        imul eax, area_width
        add eax, button_x
        shl eax, 2
        add eax, area

        ;DRAW THE ROW
        mov ecx, button_size
        draw_pixel_loop:
            mov [eax], edx
            add eax, 4
            loop draw_pixel_loop

        ;NEXT ROW
        inc esi
        cmp esi, ebx
        jb draw_loop

    draw_done:
	pop ecx
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
endm	


; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	cmp eax, 3
	jz move_paleta  ; am apasat o tasta 
	;mai jos e codul care initializeaza fereastra cu pixeli albi
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

	cmp click, 1
	jz start_minge
	

	mov eax, [ebp+arg2]
	cmp eax, button_x
	jl button_fail
	cmp eax, button_x + button_size 
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, button_y
	jl button_fail
	cmp eax, button_y + button_size
	jg button_fail
	
	; s-a dat click in buton, pregatim zona pentru inceperea jocului
	
	inc click
	
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0
	push area
	call memset
	add esp, 12

	make_paleta paleta_x, paleta_y, paleta_size, 0FFh
	desenare minge_x, minge_y, minge_size, 0008000H
	
	; am creat si dreptunghiuri speciale, pentru bonusuri

	mov edi, 0
	corpuri: 
	cmp edi, 43
	ja vect2
	
	desenare corp_x[4*edi], corp_y[4*edi], 40, 0FF0000h
	
	inc edi
	jmp corpuri
	
	vect2:
	mov edi, 0
	corpuri2:
	cmp edi, 11
	ja desenam
	
	desenare corp2_x[4*edi], corp2_y[4*edi], 40, 0FF0000h
	inc edi
	jmp corpuri2
	
	desenam:
	desenare 450, 150, 40, 0FFFF00h ; pozitia 19
	desenare 700, 100, 40, 0FFFF00h ; pozitia 10
	desenare 300, 200, 40, 0FFFF00h ; pozitia 32
	desenare 600, 250, 40, 000FF000h
	desenare 150, 150, 40, 000FF000h
	
button_fail:
	
move_paleta:   ; daca apasam right sau left arrow se va misca paleta
	cmp stop_paleta, 1
	jae final_draw
	cmp click, 0
	jz final_draw
	mov esi, contor
	shl esi, 2
	mov eax, [ebp+arg2]
	cmp eax, 39
	jz dreapta
	cmp  eax, 37
	jz stanga
	jmp final_draw
	
	dreapta:
	cmp esi, 184
	jz final_draw
	
	line_horizontal paleta_xx[esi], paleta_y, paleta_size, 0
	line_horizontal paleta_xx[esi], paleta_y + paleta_size/4, paleta_size, 0
	line_vertical paleta_xx[esi], paleta_y, paleta_size/4, 0
	line_vertical paleta2_xx[esi], paleta_y, paleta_size/4, 0
	inc contor
	mov esi, contor
	shl esi, 2
	line_horizontal paleta_xx[esi], paleta_y, paleta_size, 0FFh
	line_horizontal paleta_xx[esi], paleta_y + paleta_size/4, paleta_size, 0FFh
	line_vertical paleta_xx[esi], paleta_y, paleta_size/4, 0FFh
	line_vertical paleta2_xx[esi], paleta_y, paleta_size/4, 0FFh

	jmp move_minge
	jmp final_draw
	
	stanga:
	cmp esi, 0
	jz final_draw
	
	line_horizontal paleta_xx[esi], paleta_y, paleta_size, 0
	line_horizontal paleta_xx[esi], paleta_y + paleta_size/4, paleta_size, 0
	line_vertical paleta_xx[esi], paleta_y, paleta_size/4, 0
	line_vertical paleta2_xx[esi], paleta_y, paleta_size/4, 0
	dec contor
	mov esi, contor
	shl esi, 2
	line_horizontal paleta_xx[esi], paleta_y, paleta_size, 0FFh
	line_horizontal paleta_xx[esi], paleta_y + paleta_size/4, paleta_size, 0FFh
	line_vertical paleta_xx[esi], paleta_y, paleta_size/4, 0FFh
	line_vertical paleta2_xx[esi], paleta_y, paleta_size/4, 0FFh
	
	jmp move_minge
	
	jmp final_draw	
	
move_minge:  ; inainte sa lansam mingea, aceasta se va deplasa odata cu paleta
	cmp startminge, 1
	jae final_draw
	mov esi, contor2
	shl esi, 2
	mov eax, [ebp+arg2]
	cmp eax, 39
	jz dreapta2
	cmp  eax, 37
	jz stanga2
	jmp final_draw
	
	dreapta2:
	desenare mingex, mingey, minge_size, 0
	add mingex, 20
	desenare mingex, mingey, minge_size, 0008000H

	jmp final_draw
	
	stanga2:
	desenare mingex, mingey, minge_size, 0
	sub mingex, 20
	desenare mingex, mingey, minge_size, 0008000h
	
	jmp final_draw
	
start_minge:
	inc startminge
	jmp final_draw
	
evt_timer:
	cmp startminge, 0
	jz final_draw
	
	; mingea se afla in miscare, asa ca o redesenez la fiecare moment de timp
	
	desenare mingex, mingey, mingesize, 0
	mov edi, mingex
	cmp edi, margine_x
	jbe margine_stanga
	cmp edi, margine_xx
	jae margine_dreapta
	mov edi, mingey
	cmp edi, margine_y
	jbe margine_sus
	cmp edi, margine_yy
	jz margine_jos
	cmp edi, 510 ; inaltimea unde e paleta
	jz contact_paleta
	jmp coordonate
	
	contact_paleta:
	mov edi, mingex
	mov esi, contor
	shl esi, 2
	cmp edi, paleta_xx[esi]
	jb coordonate
	cmp edi, paleta2_xx[esi]
	jbe paleta
	
	margine_stanga:  ; mingea vine de la -x, -y sau -x, +y 
	cmp y, 1
	jz poz3
	jmp poz1
	
	margine_dreapta: ;mingea vine de la +x, +y sau +x, -y
	cmp y, 1
	jz poz4
	jmp poz2
	
	paleta: ;mingea vine de la +x, +y sau -x, +y
	cmp x, 1
	jz poz1
	jmp poz2
	
	margine_jos: ;mingea vine de la +x, +y sau -x, +y
	inc final
	jmp end_game
	
	margine_sus: ;mingea vine de la +x, -y sau -x, -y
	cmp x, 1
	jz poz3
	jmp poz4
	
	poz1:   ; +x, -y
	add mingex, 20
	sub mingey, 20
	mov x, 1
	mov y, -1
	jmp desenare_minge
	
	poz2:  ; -x, -y
	sub mingex, 20
	sub mingey, 20
	mov x, -1
	mov y, -1
	jmp desenare_minge
	
	poz3:   ; +x, +y
	add mingex, 20
	add mingey, 20
	mov x, 1
	mov y, 1
	jmp desenare_minge
	
	poz4:   ; -x, +y
	sub mingex, 20
	add mingey, 20
	mov x, -1
	mov y, 1
	jmp desenare_minge
	
	coordonate:
	cmp x, 1
	jz verif
	cmp y, 1
	jz poz4
	jmp poz2
	verif:
	cmp y, 1
	jz poz3
	jmp poz1
	
	desenare_minge:
	desenare mingex, mingey, mingesize, 0008000h
	
	mov esi, 0
	sparg2:
	mov edi, mingex
	cmp esi, 11
	ja a_doua
	cmp verificare2[4*esi], 1
	jz nu_sparg2
	cmp edi, corp2_x[4*esi]
	jb capat_minge2
	cmp edi, corp2_xx[4*esi]
	ja capat_minge2
	mov edi, mingey
	cmp edi, corp2_y[4*esi]
	jb capat_minge2
	cmp edi, corp2_yy[4*esi]
	ja capat_minge2
	jmp bonusminge2
	
	capat_minge2:
	mov edi, mingex
	add edi, mingesize
	cmp edi, corp2_x[4*esi]
	jb nu_sparg2
	cmp edi, corp2_xx[4*esi]
	ja nu_sparg2
	mov edi, mingey
	add edi, mingesize
	cmp edi, corp2_y[4*esi]
	jb nu_sparg2
	cmp edi, corp2_yy[4*esi]
	ja nu_sparg2
	
	bonusminge2:
	mov edi, mingex
	cmp edi, 600
	jb sterg2
	cmp edi, 640
	ja sterg2
	mov edi, mingey
	cmp edi, 250
	jb sparg2
	cmp edi, 270
	ja sterg2
	add mingesize, 3
	
	sterg2:
	mov edi, esi
	desenare corp2_x[4*edi], corp2_y[4*edi], 40, 0
	mov verificare2[4*edi], 1
	cmp [scor], 9
	jae zeci2
	inc [scor]
	jmp sari2
	zeci2:
	inc [scor+4]
	mov [scor], 0
	
	sari2:
	cmp x, 1
	jz verific2
	cmp y, 1
	jz schimb2
	mov y, 1
	jmp nu_sparg2
	
	verific2:
	cmp y, 1
	jz schimb2
	mov y, 1
	jmp nu_sparg2
	
	schimb2:
	mov y, -1	
	
	nu_sparg2:
	inc esi
	jmp sparg2
	
	a_doua:
	mov esi, 0
	sparg:
	mov edi, mingex
	cmp esi, 43
	ja final_draw
	cmp verificare[4*esi], 1
	jz nu_sparg
	cmp edi, corp_x[4*esi]
	jb capat_minge
	cmp edi, corp_xx[4*esi]
	ja capat_minge
	mov edi, mingey
	cmp edi, corp_y[4*esi]
	jb capat_minge
	cmp edi, corp_yy[4*esi]
	ja capat_minge
	jmp bonusminge
	
	capat_minge:
	mov edi, mingex
	add edi, mingesize
	cmp edi, corp_x[4*esi]
	jb nu_sparg
	cmp edi, corp_xx[4*esi]
	ja nu_sparg
	mov edi, mingey
	add edi, mingesize
	cmp edi, corp_y[4*esi]
	jb nu_sparg
	cmp edi, corp_yy[4*esi]
	ja nu_sparg
	cmp esi, 10
	jz bonusgalben1
	cmp esi, 19
	jz bonusgalben2
	cmp esi, 32
	jz bonusgalben3
	
	bonusminge:
	mov edi, mingex
	cmp edi, 150
	jb sterg
	cmp edi, 190
	ja sterg
	mov edi, mingey
	cmp edi, 150
	jb sparg
	cmp edi, 170
	ja sterg
	add mingesize, 3
	jmp sterg

	bonusgalben1:
	desenare 700, 100, 40, 0
	desenare 650, 100, 40, 0
	desenare 750, 100, 40, 0
	desenare 650, 150, 40, 0
	desenare 700, 150, 40, 0
	desenare 750, 150, 40, 0
	mov verificare[4*10], 1
	mov verificare[4*9], 1
	mov verificare[4*11], 1
	mov verificare[4*23], 1
	mov verificare[4*24], 1
	mov verificare[4*25], 1
	
	cmp [scor], 4
	jae zeciG1
	add [scor], 6
	jmp sariG1
	zeciG1:
	inc [scor+4]
	sub [scor], 4
	sariG1:
	
	cmp x, 1
	jz verificG1
	cmp y, 1
	jz schimbG1
	mov y, 1
	jmp nu_spargG1
	
	verificG1:
	cmp y, 1
	jz schimbG1
	mov y, 1
	jmp nu_spargG1
	
	schimbG1:
	mov y, -1	
	
	nu_spargG1:
	inc esi
	jmp sparg
	
	bonusgalben2:
	
	desenare 450, 150, 40, 0
	desenare 400, 100, 40, 0
	desenare 450, 100, 40, 0
	desenare 500, 100, 40, 0
	desenare 400, 150, 40, 0
	desenare 500, 150, 40, 0
	desenare 500, 200, 40, 0
	desenare 400, 200, 40, 0
	desenare 450, 200, 40, 0
	
	mov verificare[4*4], 1
	mov verificare[4*5], 1
	mov verificare[4*6], 1
	mov verificare[4*19], 1
	mov verificare[4*18], 1
	mov verificare[4*20], 1
	mov verificare[4*34], 1
	mov verificare[4*36], 1
	mov verificare[4*35], 1
	
	cmp [scor], 1
	jae zeciG2
	add [scor], 9
	jmp sariG2
	zeciG2:
	inc [scor+4]
	dec [scor]
	sariG2:
	
	cmp x, 1
	jz verificG2
	cmp y, 1
	jz schimbG2
	mov y, 1
	jmp nu_spargG2
	
	verificG2:
	cmp y, 1
	jz schimbG2
	mov y, 1
	jmp nu_spargG2
	
	schimbG2:
	mov y, -1	
	
	nu_spargG2:
	inc esi
	jmp sparg
	
	bonusgalben3:	
	
	desenare 300, 200, 40, 0
	desenare 250, 200, 40, 0
	desenare 350, 200, 40, 0
	desenare 350, 150, 40, 0
	desenare 300, 150, 40, 0
	desenare 250, 150, 40, 0
	desenare 250, 200, 40, 0
	desenare 300, 200, 40, 0
	desenare 350, 200, 40, 0
	
	mov verificare[4*32], 1
	mov verificare[4*31], 1
	mov verificare[4*33], 1
	mov verificare[4*15], 1
	mov verificare[4*16], 1
	mov verificare[4*17], 1
	mov verificare2[4*1], 1
	mov verificare2[4*3], 1
	mov verificare2[4*2], 1
	
	cmp [scor], 1
	jae zeciG3
	add [scor], 9
	jmp sariG3
	zeciG3:
	inc [scor+4]
	dec [scor]
	sariG3:
	
	cmp x, 1
	jz verificG3
	cmp y, 1
	jz schimbG3
	mov y, 1
	jmp nu_spargG3
	
	verificG3:
	cmp y, 1
	jz schimbG3
	mov y, 1
	jmp nu_spargG3
	
	schimbG3:
	mov y, -1	
	
	nu_spargG3:
	inc esi
	jmp sparg
	
	sterg:
	mov edi, esi
	desenare corp_x[4*edi], corp_y[4*edi], 40, 0
	mov verificare[4*edi], 1
	cmp [scor], 9
	jae zeci
	inc [scor]
	jmp sari
	zeci:
	inc [scor+4]
	mov [scor], 0
	sari:
	cmp x, 1
	jz verific
	cmp y, 1
	jz schimb
	mov y, 1
	jmp nu_sparg
	
	verific:
	cmp y, 1
	jz schimb
	mov y, 1
	jmp nu_sparg
	
	schimb:
	mov y, -1	
	
	nu_sparg:
	inc esi
	jmp sparg
	
	inc counter
	
cmp click, 1
je final_draw
	
afisare_litere:
	
	;scriem un mesaj
	make_text_macro 'P', area, 470, 100
	make_text_macro 'R', area, 480, 100
	make_text_macro 'O', area, 490, 100
	make_text_macro 'I', area, 500, 100
	make_text_macro 'E', area, 510, 100
	make_text_macro 'C', area, 520, 100
	make_text_macro 'T', area, 530, 100
	
	make_text_macro 'L', area, 495, 120
	make_text_macro 'A', area, 505, 120
	
	make_text_macro 'A', area, 460, 140	
	make_text_macro 'S', area, 470, 140
	make_text_macro 'A', area, 480, 140
	make_text_macro 'M', area, 490, 140
	make_text_macro 'B', area, 500, 140
	make_text_macro 'L', area, 510, 140
	make_text_macro 'A', area, 520, 140
	make_text_macro 'R', area, 530, 140
	make_text_macro 'E', area, 540, 140
	
	make_text_macro 'D', area, 470, 180
	make_text_macro 'X', area, 480, 180
	make_text_macro '-', area, 490, 180
	make_text_macro 'B', area, 500, 180
	make_text_macro 'A', area, 510, 180
	make_text_macro 'L', area, 520, 180
	make_text_macro 'L', area, 530, 180
	
	make_text_macro 'S', area, 475, 260
	make_text_macro 'T', area, 485, 260
	make_text_macro 'A', area, 495, 260
	make_text_macro 'R', area, 505, 260
	make_text_macro 'T', area, 515, 260
	
	make_button button_x, button_y, button_size, 0FFh
	
cmp final, 0
jz final_draw
	
end_game:
	make_text_macro 'E', area, 470, 70
	make_text_macro 'N', area, 480, 70
	make_text_macro 'D', area, 490, 70
	make_text_macro ' ', area, 500, 70
	make_text_macro 'G', area, 510, 70
	make_text_macro 'A', area, 520, 70
	make_text_macro 'M', area, 530, 70
	make_text_macro 'E', area, 540, 70
	
	make_text_macro 'S', area, 475, 180
	make_text_macro 'C', area, 485, 180
	make_text_macro 'O', area, 495, 180
	make_text_macro 'R', area, 505, 180
	make_text_macro 'E', area, 515, 180
	
	mov edx, [scor]
	add edx, '0'
	make_text_macro edx, area, 550, 180
	mov edx, [scor+4]
	add edx, '0'
	make_text_macro edx, area, 540, 180
	inc stop_paleta

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
