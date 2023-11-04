.eqv IN_ADRESS_HEXA_KEYBOARD 	0xFFFF0012
.eqv OUT_ADRESS_HEXA_KEYBOARD 	0xFFFF0014
.eqv SEVENSEG_LEFT 		0xFFFF0011 	# Dia chi cua den led 7 doan trai.
.eqv SEVENSEG_RIGHT 		0xFFFF0010 	# Dia chi cua den led 7 doan phai
# Bit 0 = doan a;
# Bit 1 = doan b; 
# Bit 2 = doan c; 
# Bit 3 = doan d; 
# Bit 4 = doan e; 
# Bit 5 = doan f; 
# Bit 6 = doan g; 
# Bit 7 = dau .
.data
error1: 	.asciiz 	"Syntax ERROR \n \[OK]: Cancel " 
error2: 	.asciiz 	"Math ERROR \n \[OK]: Cancel " 
daucong:	.asciiz		"+" 
dautru:		.asciiz		"-"
daunhan:	.asciiz		"*"
dauchia:	.asciiz		"/"
daubang:	.asciiz		"="
mess1:		.asciiz		" , Du:"
enter:		.asciiz 	"\n"
#Chuyen doi cod qua chuoi 7 bit hien thi tren led
zero:  .byte 0x3f	#0x11=0=0111111
one:   .byte 0x6	#0X21=1=0000110
two:   .byte 0x5b	#0x41=2=1011011
three: .byte 0x4f	#0x81=3=1001111
four:  .byte 0x66	#0X12=4=1100110
five:  .byte 0x6d	#0x22=5=1101100
six:   .byte 0x7d	#0x42=6=1111101
seven: .byte 0x7	#0x82=7=0000111
eight: .byte 0x7f	#0x14=8=1111111
nine:  .byte 0x6f	#0x24=9=1101111
.text
#===========================================================================
MAIN:		jal 	SET			#khai bao cac thanh ghi	
	s2:	li	$s1,0x3f		#khi nhap s2 thi bat dau reset led trai ve 0 (tuc led phai cu ve 0)		
	loop: 	nop
		nop
		b 	loop
  begin:	
  	#nhap du lieu va xu ly
  		beq 	$t0,2,endbegin		#neu phim e duoc an thi ket thuc chuong trinh
		nop
	f1:	jal	CONVERT1		#chuyen ki tu vua nhap ve dang so 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
		nop
	sfx:     jal 	CHECK			#Kiem tra du lieu va nhay den mot trong nhung ham f2,f3,f4,f5,f6
		nop
	f2:	jal	Math_ERROR		#Quay Lai ham MAIN tinh bieu thuc moi
		nop
	f3:	jal	Syntax_ERROR		#Quay Lai ham MAIN tinh bieu thuc moi
		nop
	f4:	jal	ThemVaoS1		#Them so vua nhap vao so thu nhat s2=s2*10+$t8	
		nop
		jal	SHOWLED			#In ra Led 7 thanh
		nop
		b 	loop
	f5:	jal	ThemVaoS2		#Them so vua nhap vao so thu hai s2=s3*10+$t8
		nop
		jal	SHOWLED			#In ra Led 7 thanh
		nop
		b 	loop	
	f6: 	jal 	TinhToan		#Thuc hien viec tinh +-*/
		nop
		
	#thuc hien xu ly ket qua
	f7:	jal 	CONVERT2		#chuyen doi so thanh 2 so hang chuc va don vi
		nop				
		add	$t6,$t3,$zero		#chuyen doi so thanh ma hien thi tren led 7 thanh
		jal 	CONVERT3		#input $t6 1-9; output $s6 ma hien thi
		add	$s0,$s6,$zero
		nop
		add	$t6,$t4,$zero		#chuyen doi so thanh ma hien thi tren led 7 thanh
		jal 	CONVERT3		#input $t6 1-9; output $s6 ma hien thi
		add	$s1,$s6,$zero
		nop
	f8:	jal	SHOWLED			#In kq ra Led 7 thanh
		nop
		jal 	PRINTCALC		#In ra chi tiet phep tinh 
		nop
		b 	MAIN			#nhay den phep toan tiep theo
   endbegin: 	
END:
		li 	$v0, 10
		syscall
#=========================================================================
#KHAI BAO CAC THANH GHI SU DUNG TRONG CHUONG TRINH
SET:		
	# Enable the interrupt of Keyboard matrix 4x4 of Digital LabSim
	li 	$t1, IN_ADRESS_HEXA_KEYBOARD
	li 	$t3, 0x80 			
	sb 	$t3, 0($t1)
	#khai bao cac thanh ghi
	li 	$s0,0x3f	#so hien thi tren led trai
	li	$s1,0x3f	#so hien thi tren led phai
	li	$s2,0	#so thu nhat
	li	$s3,0	#so thu hai
	li	$s4,10	#toan tu
	li	$s5,0	#ket qua
	li	$s7,0	#gia tri led phai cu
	li	$t0,0	#kiem tra phim nhap vao la so (0) ,toan tu (1), end (2)
	li 	$t1,-1 	#kiem tra phim truoc la so (0), toan tu (1)
	li 	$t2,0   #vi tri dang nhap lieu hien tai la chua nhap gi (0) ,so thu nhat (1), so thu hai (2)
	li	$t3,0	#gia tri so o led trai
	li	$t4,0	#gia tri so o led phai
	li	$t5,0 	#thanh ghi chua cac gia tri tuc thoi
	li	$t6,0 	#thanh ghi luu gia tri bien x trong ham convert2,convert3
	li	$s6,0	#thanh ghi luu gia tra ve trong ham convert3
	li	$t7,0  	#luu gia tri phan du trong phep chia
	li	$t8,0 	#gia tri cua phim vua nhap vao 0,1,2,3,4,5,6,7,8,9,10(+),11(-),12(*),13(/),14(=)
	li	$t9,0	#gia tri cua code nhap tu ban phim 
	jr 	$ra
#---------------------------------------------------------------
#---------------------------------------------------------------
#FUNCTION 1		#FUNCTION 1  		#FUNCTION 1 
CONVERT1:	add	$t1,$t0,$zero		#luu lai loai phim cua phim truoc
		add	$s7,$s1,$zero		#luu lai gia tri led phai cu
		li	$t0,0			#neu la toan hang
		add	$a0,$t9,$zero		#lay code tu $t9
		ori	$t5,$zero,0x11
		beq 	$a0,$t5,case_zero
		ori	$t5,$zero,0x21
		beq 	$a0,$t5,case_one
		ori	$t5,$zero,0x41
		beq 	$a0,$t5,case_two
		li	$t5,0xffffff81
		beq 	$a0,$t5,case_three
		ori	$t5,$zero,0x12
		beq 	$a0,$t5,case_four
		ori	$t5,$zero,0x22
		beq 	$a0,$t5,case_five
		ori	$t5,$zero,0x42
		beq 	$a0,$t5,case_six
		li	$t5,0xffffff82
		beq 	$a0,$t5,case_seven
		ori	$t5,$zero,0x14
		beq 	$a0,$t5,case_eight
		ori	$t5,$zero,0x24
		beq 	$a0,$t5,case_nine
		li	$t0,1			#neu la toan tu
		ori	$t5,$zero,0x44
		beq 	$a0,$t5,case_add
		li	$t5,0xffffff84
		beq 	$a0,$t5,case_sub
		ori	$t5,$zero,0x18
		beq 	$a0,$t5,case_mul
		ori	$t5,$zero,0x28
		beq 	$a0,$t5,case_div
		li	$t5,0xffffff88
		beq 	$a0,$t5,case_equ
		li	$t0,2			#neu la phim tat
		ori	$t5,$zero,0x11
		beq 	$a0,0x00000048,return

	case_zero:
		lb	$s1,zero		#cap nhat led phai
		li	$t8,0			#ki tu vua nhap
		j	update1
	case_one:
		lb	$s1,one			#cap nhat led phai
		li	$t8,1			#ki tu vua nhap
		j	update1
	case_two:
		lb	$s1,two			#cap nhat led phai
		li	$t8,2			#ki tu vua nhap
		j	update1
	case_three:
		lb	$s1,three		#cap nhat led phai
		li	$t8,3			#ki tu vua nhap
		j	update1
	case_four:
		lb	$s1,four		#cap nhat led phai
		li	$t8,4			#ki tu vua nhap
		j	update1
	case_five:
		lb	$s1,five		#cap nhat led phai
		li	$t8,5			#ki tu vua nhap
		j	update1
	case_six:
		lb	$s1,six			#cap nhat led phai
		li	$t8,6			#ki tu vua nhap
		j	update1
	case_seven:
		lb	$s1,seven		#cap nhat led phai
		li	$t8,7			#ki tu vua nhap
		j	update1
	case_eight:
		lb	$s1,eight		#cap nhat led phai
		li	$t8,8			#ki tu vua nhap
		j	update1
	case_nine:
		lb	$s1,nine		#cap nhat led phai
		li	$t8,9			#ki tu vua nhap
		j	update1
	case_add:
		li	$t8,10			#ki tu vua nhap
		nop
		jr 	$ra
		nop
	case_sub:
		li	$t8,11			#ki tu vua nhap
		nop
		jr 	$ra
		nop
	case_mul:
		li	$t8,12			#ki tu vua nhap
		nop
		jr 	$ra
		nop
	case_div:
		li	$t8,13			#ki tu vua nhap
		nop
		jr 	$ra
		nop
	case_equ:
		li	$t8,14			#ki tu vua nhap
		nop
		jr 	$ra
		nop
	end_cv:
	update1:	
		add	$s0,$s7,0
		nop
		jr 	$ra
		nop
#---------------------------------------------------------------
#FUNCTION 7		#FUNCTION 7		#FUNCTION 7	
CONVERT2:
	li	$t3,0	#gia tri so o led trai
	li	$t4,0	#gia tri so o led phai
	li	$t5,10
	div	$t6,$t5
	mflo	$t6
	mfhi	$t4	#led ben trai o chu so hang don vi
	div	$t6,$t5
	mflo	$t6
	mfhi	$t3	#led ben phai o chu so hang chuc
	jr	$ra
CONVERT3:
		bne 	$t6,0,case_1
		lb	$s6,zero
		jr	$ra
	case_1:	bne 	$t6,1,case_2
		lb	$s6,one
		jr	$ra
	case_2:	bne 	$t6,2,case_3
		lb	$s6,two
		jr	$ra
	case_3:	bne 	$t6,3,case_4
		lb	$s6,three
		jr	$ra
	case_4:	bne 	$t6,4,case_5
		lb	$s6,four
		jr	$ra
	case_5:	bne 	$t6,5,case_6
		lb	$s6,five
		jr	$ra
	case_6:	bne 	$t6,6,case_7
		lb	$s6,six
		jr	$ra
	case_7:	bne 	$t6,7,case_8
		lb	$s6,seven
		jr	$ra
	case_8:	bne	$t6,8,case_9
		lb	$s6,eight
		jr	$ra
	case_9:	lb	$s6,nine
		jr	$ra
#---------------------------------------------------------------
#GOTO FUNCTION x	#GOTO FUNCTION x 	#GOTO FUNCTION x
CHECK:
	beq	$t2,1,khu1
	beq	$t2,2,khu2
	khu0: #kiem tra vi tri nhap 0
		beq	$t0,$zero,GOTO_F4
		beq	$t8,14,GOTO_F6
		j	GOTO_F3
	khu1: #kiem tra vi tri nhap 1
		beq	$t0,$zero,GOTO_F4	#kiem tra loai phim nhap vao la so
		beq	$t8,14,GOTO_F6		#phim nhap vao la dau =
		add	$s4,$t8,0		#neu la toan tu thi luu lai
		li	$t2,2
		j	GOTO_S2
	
	khu2:#kiem tra vi tri nhap 2
		beq	$t0,$zero,GOTO_F5	#kiem tra loai phim nhap vao la so,neu co thi nhap vao s2
		nop	
		ori	$t5,$zero,14
		bne	$t8,$t5,khu2_1		#kiem tra co phai dau bang hay khong
		beq	$t1,$zero,GOTO_F6	#neu la dau bang thi kiem tra ki tu truoc do la toan tu hay khong,neu co thi tinh toa
	khu2_1:
		nop
		ori 	$t5,$zero,1
		beq	$t1,$t5,GOTO_F3		#phim hien tai la toan tu, neu phim truoc do la toan tu-> error
		j 	GOTO_F6
	GOTO_F2:#Math_ERROR
		la	$ra,f2
		jr 	$ra
	GOTO_F3:#Syntax_ERROR
		la	$ra,f3
		jr 	$ra
	GOTO_F4:#ThemVaoS1
		li	$t2,1
		la	$ra,f4
		jr 	$ra
	GOTO_F5:#ThemVaoS2
		la	$ra,f5
		jr 	$ra
	GOTO_F6:#TinhToan
		la	$ra,f6
		jr 	$ra
	GOTO_S2:
		la	$ra,s2
		jr 	$ra
	
	
#---------------------------------------------------------------
#FUNCTION 2,3		#FUNCTION 2,3		#FUNCTION 2,3
#BAO LOI !!!
Syntax_ERROR:	
		li 	$v0, 55
		la 	$a0, error1
		li 	$a1, 0
		syscall
		la	$ra,MAIN
		jr 	$ra

Math_ERROR:	li 	$v0, 55
		la 	$a0, error2
		li 	$a1, 0
		syscall
		la	$ra,MAIN
		jr 	$ra
#---------------------------------------------------------------
#---------------------------------------------------------------

ThemVaoS1:
	add 	$s0,$s7,$zero	#dich chuyen led phai sang trai
	add	$t5,$s2,$s2	#t5=2s2
	sll	$s2,$s2,3	#s2(+)=8s2
	add	$s2,$s2,$t5	#s2(+)=10s2
	add	$s2,$s2,$t8	#s2(+)=10s2+t8(so moi them vao)
	add	$t6,$s2,$zero	#t6=s2  convert2(t6)
	jr 	$ra
ThemVaoS2:
	add 	$s0,$s7,$zero	#dich chuyen led phai sang trai
	add	$t5,$s3,$s3	#t5=2s3
	sll	$s3,$s3,3	#s3(+)=8s3
	add	$s3,$s3,$t5	#s3(+)=10s3
	add	$s3,$s3,$t8	#s3(+)=10s3+t8(so moi them vao)
	add	$t6,$s3,$zero	#t6=s3  convert2(t6)
	jr 	$ra
TinhToan:
	beq     $s4,10,cong
	beq	$s4,11,tru
	beq	$s4,12,nhan
	beq	$s4,13,chia
	cong:
		add 	$s5,$s2,$s3 	#s5=so1 + so 2
		j	finish
	tru:
		sub	$s5,$s2,$s3	#s5=s01 - so2
		j	finish
		nop
	nhan:
		mul	$s5,$s2,$s3
		j	finish
		nop
	chia:	beq	$s3,$zero,div_error
		div 	$s2,$s3
		mflo	$s5
		mfhi	$t7
		j	finish
		nop
		div_error:
		la	$ra,f2 			#Math error
		jr	$ra
		nop     
	finish:	
		add	$t6,$s5,$zero	#t6=s2  convert2(t6)
		jr 	$ra		
SHOWLED:
	show_7seg_left: 
		li 	$k0, SEVENSEG_LEFT 	# assign port's address
		sb 	$s0, 0($k0) 		# assign new value
		nop
	show_7seg_right:
		li 	$k0, SEVENSEG_RIGHT 	# assign port's address
		sb 	$s1, 0($k0) 		# assign new value
		nop
		jr 	$ra
		nop
PRINTCALC:
	beq     $s4,10,incong
	beq	$s4,11,intru
	beq	$s4,12,innhan
	beq	$s4,13,inchia
   incong:
	li 	$v0, 1
	move 	$a0, $s2
	syscall
	li 	$v0, 11
	li 	$a0, '+'
	syscall
	li 	$v0, 1
	move 	$a0,$s3
	syscall
	li 	$v0, 11
	li 	$a0, '='
	syscall
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	jr 	$ra
    intru:
	li 	$v0, 1
	move 	$a0, $s2
	syscall
	li 	$v0, 11
	li 	$a0, '-'
	syscall
	li 	$v0, 1
	move 	$a0,$s3
	syscall
	li 	$v0, 11
	li 	$a0, '='
	syscall
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	nop
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	jr 	$ra
    innhan:
	li 	$v0, 1
	move	$a0, $s2
	syscall
	li 	$v0, 11
	li 	$a0, '*'
	syscall
	li 	$v0, 1
	move 	$a0,$s3
	syscall
	li 	$v0, 11
	li	$a0, '='
	syscall
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	nop
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	jr 	$ra
   inchia:
	li 	$v0, 1
	move 	$a0, $s2
	syscall
	li 	$v0, 11
	li 	$a0, '/'
	syscall
	li 	$v0, 1
	move 	$a0,$s3
	syscall
	li 	$v0, 11
	li 	$a0, '='
	syscall
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	nop
	la 	$a0,mess1
        li 	$v0, 4     
        syscall
        li 	$v0, 1
	move	$a0, $t7
	syscall
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	jr 	$ra
#===========================================================================================
# XU LY NGAT
.ktext 0x80000180
	# SAVE the current REG FILE to stack
	IntSR: 	addi 	$sp,$sp,4 		# Save $ra because we may change it later
		sw 	$ra,0($sp)
		addi 	$sp,$sp,4 		# Save $ra because we may change it later
		sw 	$at,0($sp)
	# Processing		
	get_cod:li 	$k0, IN_ADRESS_HEXA_KEYBOARD
		li 	$k1, OUT_ADRESS_HEXA_KEYBOARD
		li	$a2, 0x01
	get_cod_loop:				#lap va kiem tra ma cua phim
		addi 	$a1,$a2,0x80
		sll 	$a2,$a2,1
		sb 	$a1,0($k0) 		# must reassign expected row
		lb 	$a0,0($k1)
		beq 	$a0,$zero,get_cod_loop
		add	$t9,$a0,0		#luu code vao $t9
	
return:		la 	$a3,begin
		mtc0 	$a3, $14
		eret # Return from exception
