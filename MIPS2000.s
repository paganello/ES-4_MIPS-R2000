.data
COMMAND_ADDR:   .byte   0
START_ADDR:     .word   0
LED_ADDR:       .half   0

COMMAND_TABLE:
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
    bne $t0, $zero, routine11_adress
    
routine14_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine12_adress
    
routine15_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine15_adress


#Effettuo il complemento bit a bit dei 4 bit meno significativi

main:
 li $t1, START
 li $t2, COMMAND
 li $t3, LED

#Estrazione del comando COMMAND nei 2 nybble rispettivamente più significativi e meno significativi.
#Nel nybble meno significativi, effettuo il complemento bit a bit

lb $t4, 0($t2)
andi $t4, $t2, 0xFO
andi $t5, $t2, 0x0F 
xor $t6, $t6, $t5

bne $t4, $t5, errore    #bisogna gestire lerrore


errore:
li $t7, 60


lampeggio:
li $t0, 15000000000
loop: addi $t0, $t0, -1
bne $t0, $zero, loop


loop:
lw $t4, 0($t1)
beq $t4,  , loop
