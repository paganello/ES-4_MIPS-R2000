.data
COMMAND:   .byte   0
START:     .word   0x1000
LED:       .half   0

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
 la $t1, START
 la $t2, COMMAND
 la $t3, LED

# Estrazione del comando COMMAND nei 2 nybble rispettivamente più significativi e meno significativi.
# Nel nybble meno significativi, effettuo il complemento bit a bit

lb $t4, 0($t2)          # esempio:                                1110 0001  
andi $t4, $t2, 0x0F     # Estraggo il nybble piu significativo --> 0000 0001
andi $t5, $t2, 0xF0     # Estraggo il nybble meno significativo --> 1110 0000

xor	$t5, $t5, $t4       # --> 1110 0001 , mi permette di fare il complemento bit a bit.

bne $t4, $t5, errore    # Bisogna gestire l'errore


sll $t4, $t4, 2


errore:
    li $t1, 60          # Imposta il contatore a 60 (numero di secondi)
    li $t4, 2           # Imposta il secondo contatore a 2 (numero di secondi)

led_loop:
    sw $zero, 0($t0)    # Scrive il valore 0 nella cella LED (led spento)
    move $t3, $zero     # Imposta il registro $t3 a 0
    sw $ra, 4($sp)
    jal delay           # Chiamata alla funzione delay per un ritardo di 2 secondi

    li $t3, 0x8000      # Imposta il valore 0x8000 nel registro $t3 (led acceso)
    sw $t3, 0($t0)      # Scrive il valore 0x8000 nella cella LED (led acceso)
    jal delay           # Chiamata alla funzione delay per un ritardo di 2 secondi

    addi $t1, $t1, -2   # Sottrae 2 dal contatore dei secondi rimanenti
    beq $t1, $zero, end_loop # Salta al ciclo del led se il contatore non è zero
    jal delay_loop


delay_loop:
    addi $t4, $t4, -400  # Decrementa il contatore del ritardo di (1/500000000)*2 secondi, espresso in microsecondi
    bnez $t4, delay_loop # Ripeti il ciclo finché il contatore non è zero


end_loop:
    lw $ra, 4($sp)
    jr $ra               # Ritorna alla chiamata della funzione

