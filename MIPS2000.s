.data   0x10000000              # Inizializzazione .data a 0x10000000
START:     .word   0x00000000   # Inizializzazione START a 0x10000004
LED:       .half   0x00000000   # Inizializzazione LED a 0x10000006
COMMAND:   .byte   0x00000000   # Inizializzazione COMMAND  0x10000007


#Inizializzazione ROUTINE_TABLE

ROUTINE_TABLE:   .word  0x10000008     # {da chiedere a abbadini se gli indirizzamenti vanno bene}

routine0_adress:     .word    0x1000000C
routine1_adress:     .word    0x10000010
routine2_adress:     .word    0x10000014
routine3_adress:     .word    0x10000018
routine4_adress:     .word    0x1000001C
routine5_adress:     .word    0x10000020
routine6_adress:     .word    0x10000024
routine7_adress:     .word    0x10000028
routine8_adress:     .word    0x1000002C
routine9_adress:     .word    0x10000030
routine10_adress:    .word    0x10000034
routine11_adress:    .word    0x10000038
routine12_adress:    .word    0x1000003C
routine13_adress:    .word    0x10000040
routine14_adress:    .word    0x10000044
routine15_adress:    .word    0x10000048

.text

routine0_adress:
    addi $t0, $t0, -1                   # Decrementa il contatore di 1
    bne $t0, $zero, routine0_adress     # Verifica che il contatore non sia uguale a 0 e continua il loop
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
    la $v0, LED                             # Inserisce in v0 l'indirizzo di LED
    

# Verifica del contenuto di COMMAND che sia diverso da zero
    
ver_command:  
    lb  $t1, 0(COMMAND)                     # Inserisce in t1 il contenuto di COMMAND
    andi $t1, $t1, 0x000000ff               # Moltiplica il contenuto di t1 con 0x000000ff, essendo che COMMAND è a 8 bit e un regitro è a 32 bit
    bne $t1, $zero, send_1000H_to_CPU       # Verifica che il contenuto di t1 sia diverso da zero, se è true, va in "send_1000H_to_CPU"
    j ver_command                           # salta a send_1000H_to_CPU


# Invia la parola 1000H nella cella a 16 bit denominata START

send_1000H_to_CPU:
    addi $t0, $zero, 0x31303030480a         # Inserisce in t0 la parola 1000H in esadecimale
    sw $t0, 0(START)                        # Memorizza in START il contenuto di t0
    j controllo_start                       # salta a controllo_start


# Verifica del contenuto di start che corrisponda alla parola 1000H
# Estrazione del comando COMMAND nei 2 nybble rispettivamente più significativi e meno significativi. Nel nybble meno significativi, effettuo il complemento bit a bit

controllo_start:
    lw	$t0, 0(START)		            # Inserisce in t0 il contenuto di START
    addi $t2, $zero, 0x31303030480a     # Inserisce il t2 il risultato della somma tra 0 e 1000H in esadecimale
    bne $t0, $t2, controllo_start       # Verifica che se il contenuto di t0 corrisponde al contenuto di t2, allora continua con l'istruzione successiva

    add $t2, $zero, $zero               # Azzera t2 
    add $t1, $zero, $zero               # Azzera t1
    add $t0, $zero, $zero               # Azzera t0
    li $t0, 15000000000                 # Carico in t0 il valore che serve per l'attesa nelle routine (t0 viene usato nelle routine ma lo inizializzo prima)

    lb $t1, 0(COMMAND)                  # Esempio: 1110 0001  
    andi $t1, $t1, 0x000000FF           # Moltiplica il contenuto di t1 con 0x000000FF, essendo che COMMAND è a 8 bit e un regitro è a 32 bit

    andi $t2, $t1, 0x000000F0           # Estraggo il nybble piu significativo  -->  1110 0000
    andi $t3, $t1, 0x0000000F           # Estraggo il nybble meno significativo -->  0000 0001
    xor	$t3, $t3, $t2                   # --> 1110 0001 , mi permette di fare il complemento bit a bit.
    bne $t1, $t3, errore

    sll $t2, $t2, 4                     # Shift a sinistra il nybble più significativo per 16 per ottenere l'offset
    la $t4, ROUTINE_TABLE               # Carica l'indirizzo della Routine_Table nel registro t7
    add $t4, $t4, $t2                   # Aggiunge a t7 il nybble più significativo per calcolare l'indirizzo della routine richiesta
    jal $t4                             # Salta all'indirizzo della routine richiesta

    j end
    # termina il programma {da chiedere all'ingegnere abbadini}


# Allocazione spazio dello stack delle chiamate

errore:
    move $t3, $zero                 # Imposta il registro $t3 a 0


# Il comando non è corretto, inibisce l'accettazione di dati per 60 secondi 

    li $t5, 60                      # Imposta il contatore a 60 (numero di secondi) t1
    li $a0, -2                      # Imposta il secondo contatore a 2 (numero di secondi) t4


# lampeggio led

led_loop:
    sw $zero, 0($v0)                # Scrive il valore 0 nella cella LED (led spento)
    jal delay_loop                  # Chiamata alla funzione delay per un ritardo di 2 secondi

    li $t3, 0x00001F40              # Imposta il valore 0x8000 nel registro $t3 (led acceso) {da chiedere a abbadini il valore da settare => esadecimale o decimale o testo?}
    sw $t3, 0($v0)                  # Scrive il valore 0x8000 nella cella LED (led acceso)
    jal delay_loop                  # Chiamata alla funzione delay per un ritardo di 2 secondi

    add $t5, $t5, $a0               # Sottrae 2 dal contatore dei secondi rimanenti
    beq $t5, $zero, end             # Salta al ciclo del led se il contatore non è zero
    j led_loop                      # ritorno a led loop e ricomincio il ciclo di lampeggio


# Gestione contatore per il lampeggio

delay_loop:
    addi $t4, $t4, -400         # Decrementa il contatore del ritardo di (1/500000000)*2 secondi, espresso in microsecondi
    bnez $t4, delay_loop        # Ripeti il ciclo finché il contatore non è zero
    jr $ra

# Fine programma

end:
    li $t7, 0x00000000          # Carico 0x00000000 in t7    
    move $t0, $t7               # Azzero t0
    move $t1, $t7               # Azzero t1
    move $t2, $t7               # Azzero t2
    move $t3, $t7               # Azzero t3
    move $t4, $t7               # Azzero t4
    move $t5, $t7               # Azzero t5
    j ver_command               # Ritorno alla verifica di command


