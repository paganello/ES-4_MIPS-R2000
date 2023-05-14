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

#Attesa di due secondi
li $t0, 15000000000     #Metto in t0 2 secondi di attesa (contatore)

routine0_adress:
    addi $t0, $t0, -1                   #decremento il contatore di 1
    bne $t0, $zero, routine0_adress     #Verifica che il contatore non sia uguale a 0 e continua il loop
    jr $ra

routine1_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine1_adress
    jr $ra
    
routine2_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine2_adress
    jr $ra
    
routine3_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine3_adress
    jr $ra
    
routine4_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine4_adress
    jr $ra
    
routine5_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine5_adress
    jr $ra
    
routine6_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine6_adress
    jr $ra
    
routine7_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine7_adress
    jr $ra
    
routine8_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine8_adress
    jr $ra
    
routine9_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine9_adress
    jr $ra
    
routine10_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine10_adress
    jr $ra
    
routine11_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine11_adress
    jr $ra
    
routine12_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine12_adress
    jr $ra
    
routine13_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine13_adress
    jr $ra
    
routine14_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine14_adress
    jr $ra
    
routine15_adress:
    addi $t0, $t0, -1
    bne $t0, $zero, routine15_adress
    jr $ra


#Core del programma

main:
 la $t1, START
 la $t2, COMMAND
 la $t3, LED
 
 lw $t4, START                               # Inserisce in t4 il contenuto di START
 beq $t4, 0x1000, controllo_comando          # Verifica che START corrisponde a 100H, se è true, va in "controllo_comando"
 jr $ra                                      # Esce dal programma


# Estrazione del comando COMMAND nei 2 nybble rispettivamente più significativi e meno significativi.
# Nel nybble meno significativi, effettuo il complemento bit a bit

controllo_comando:
    lb $t5, 0($t2)          # Esempio:                                   1110 0001  

    andi $t5, $t2, 0xF0     # Estraggo il nybble piu significativo  -->  1110 0000
    andi $t6, $t2, 0x0F     # Estraggo il nybble meno significativo -->  0000 0001
    xor	$t6, $t6, $t5       # --> 1110 0001 , mi permette di fare il complemento bit a bit.
    bne $t5, $t6, errore

    sll $t5, $t5, 2         # Moltiplica il nybble più significativo per 4 per ottenere l'offset
    lui $t7, ROUTINE_TABLE  # Carica l'indirizzo della Routine_Table nel registro t7
    add $t7, $t7, $t5       # Aggiunge a t7 il nibbly più significativo per calcolare l'indirizzo della routine richiesta
    jr $t7                  # Salta all'indirizzo della routine richiesta


# Il comando non è corretto, inibisce l'accettazione di dati per 60 secondi 

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
