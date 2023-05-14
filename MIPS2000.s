.data
COMMAND:   .byte   0
START:     .word   0x1000
LED:       .half   0


ROUTINE_TABLE:
    .word   routine0_adress 
    .word   routine1_adress
    .word   routine2_adress
    .word   routine3_adress
    .word   routine4_adress
    .word   routine5_adress
    .word   routine6_adress
    .word   routine7_adress
    .word   routine8_adress
    .word   routine9_adress
    .word   routine10_adress
    .word   routine11_adress
    .word   routine12_adress
    .word   routine13_adress
    .word   routine14_adress
    .word   routine15_adress    


.text
move $t0, 2

routine0_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine0_adress
    

routine1_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine1_adress
    
routine2_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine2_adress
    
routine3_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine3_adress
    
routine4_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine4_adress
    
routine5_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine5_adress
    
routine6_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine6_adress
    
routine7_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine7_adress
    
routine8_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine8_adress
    
routine9_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine9_adress
    
routine10_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine10_adress
    
routine11_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine11_adress
    
routine12_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine12_adress
    
routine13_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine13_adress
    
routine14_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine14_adress
    
routine15_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine15_adress


#Effettuo il complemento bit a bit dei 4 bit meno significativi


#Core del programma

main:
 li $t1, START
 li $t2, COMMAND
 li $t3, LED
 
 lw $t4, START
 beq $t4, START, controllo_comando
 jr $ra


#Estrazione del comando COMMAND nei 2 nybble rispettivamente più significativi e meno significativi.
#Nel nybble meno significativi, effettuo il complemento bit a bit

controllo_comando:
lb $t5, 0($t2)          #Esempio:                                   1110 0001  
andi $t5, $t2, 0xF0     #Estraggo il nybble piu significativo  -->  1110 0000
andi $t6, $t2, 0x0F     #Estraggo il nybble meno significativo -->  0000 0001

xor	$t6, $t6, $t5       # --> 1110 0001 , mi permette di fare il complemento bit a bit.

bne $t5, $t6, errore

sll $t5, $t5, 2
lui $t7, ROUTINE_TABLE
add $t7, $t7, $t5
jr $t7



# Il comando non è corretto, inibisce l'accettazione di dati per 60 secondi
errore:
li $t8, 60              # Carica il conteggio di 60 secondi in $t6



# Effettua il lampeggio
lampeggio:
li $t.., 15000000000
loop: addi $t0, $t0, -1
bne $t0, $zero, loop
