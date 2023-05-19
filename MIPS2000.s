.data   0x10010000              # Inizializzazione .data a 0x10010000
START:     .word   0x00000000   # Inizializzazione START a 0x10010004
LED:       .half   0x0000       # Inizializzazione LED a 0x10010006
COMMAND:   .byte   0x00         # Inizializzazione COMMAND  0x10010007
pieroPelu: .byte   0x00


#Inizializzazione ROUTINE_TABLE

ROUTINETABLE:       .word     0x00000000     # 0x10010008

routine0Address:     .word    0x00000000    # 0x1001000C
routine1Address:     .word    0x00000000    # 0x10010010
routine2Address:     .word    0x00000000    # 0x10010014
routine3Address:     .word    0x00000000    # 0x10010018
routine4Address:     .word    0x00000000    # 0x1001001C
routine5Address:     .word    0x00000000    # 0x10010020
routine6Address:     .word    0x00000000    # 0x10010024
routine7Address:     .word    0x00000000    # 0x10010028
routine8Address:     .word    0x00000000    # 0x1001002C
routine9Address:     .word    0x00000000    # 0x10010030
routine10Address:    .word    0x00000000    # 0x10010034
routine11Address:    .word    0x00000000    # 0x10010038
routine12Address:    .word    0x00000000    # 0x1001003C
routine13Address:    .word    0x00000000    # 0x10010040
routine14Address:    .word    0x00000000    # 0x10010044
routine15Address:    .word    0x00000000    # 0x10010048

.text

routine0Address:
    addi $t0, $t0, -1                   # Decrementa il contatore di 1
    bne $t0, $zero, routine0_adress     # Verifica che il contatore non sia uguale a 0 e continua il loop
    jr $ra

routine1Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine1_adress
    jr $ra
    
routine2Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine2_adress
    jr $ra
    
routine3Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine3_adress
    jr $ra
    
routine4Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine4_adress
    jr $ra
    
routine5Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine5_adress
    jr $ra
    
routine6Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine6_adress
    jr $ra
    
routine7Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine7_adress
    jr $ra
    
routine8Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine8_adress
    jr $ra
    
routine9Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine9_adress
    jr $ra
    
routine10Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine10_adress
    jr $ra
    
routine11Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine11_adress
    jr $ra
    
routine12Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine12_adress
    jr $ra
    
routine13Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine13_adress
    jr $ra
    
routine14Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine14_adress
    jr $ra
    
routine15Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine15_adress
    jr $ra

#Core del programma

main: 
    la $v0, LED                             # Inserisce in v0 l'indirizzo di LED
    

# Verifica del contenuto di COMMAND che sia diverso da zero
    
ver_command:  
    la $t1, COMMAND
    lb  $t1, 0($t1)                     # Inserisce in t1 il contenuto di COMMAND
    andi $t1, $t1, 0x000000ff               # Moltiplica il contenuto di t1 con 0x000000ff, essendo che COMMAND è a 8 bit e un regitro è a 32 bit
    bne $t1, $zero, send_1000H_to_CPU       # Verifica che il contenuto di t1 sia diverso da zero, se è true, va in "send_1000H_to_CPU"
    j ver_command                           # salta a send_1000H_to_CPU


# Invia la parola 1000H nella cella a 16 bit denominata START

send_1000H_to_CPU:
    addi $t0, $zero,  0x1000              # Inserisce in t0 la parola 1000H in esadecimale
    la $t0, START 
    sw $t0, 0($t0)                        # Memorizza in START il contenuto di t0
    j controllo_start                       # salta a controllo_start


# Verifica del contenuto di start che corrisponda alla parola 1000H
# Estrazione del comando COMMAND nei 2 nybble rispettivamente più significativi e meno significativi. Nel nybble meno significativi, effettuo il complemento bit a bit

controllo_start:
    la  $t0, START 
    lw	$t0, 0($t0)  		            # Inserisce in t0 il contenuto di START
    addi $t2, $zero, 0x1000             # Inserisce il t2 il risultato della somma tra 0 e 1000H in esadecimale
    bne $t0, $t2, controllo_start       # Verifica che se il contenuto di t0 corrisponde al contenuto di t2, allora continua con l'istruzione successiva

    add $t2, $zero, $zero               # Azzera t2 
    add $t1, $zero, $zero               # Azzera t1
    add $t0, $zero, $zero               # Azzera t0
    li $t0, 15000000000                 # Carico in t0 il valore che serve per l'attesa nelle routine (t0 viene usato nelle routine ma lo inizializzo prima)

    la $t1, COMMAND 
    lb $t1, 0($t1)                         # Esempio: 1110 0001  
    andi $t1, $t1, 0x000000FF           # Moltiplica il contenuto di t1 con 0x000000FF, essendo che COMMAND è a 8 bit e un regitro è a 32 bit

    andi $t2, $t1, 0x000000F0           # Estraggo il nybble piu significativo  -->  1110 0000
    andi $t3, $t1, 0x0000000F           # Estraggo il nybble meno significativo -->  0000 0001
    xor	$t3, $t3, $t2                   # --> 1110 0001 , mi permette di fare il complemento bit a bit.
    bne $t1, $t3, errore

    sll $t2, $t2, 2                     # Moltiplica il nybble più significativo per 4 per ottenere l'offset
    la $t4, ROUTINETABLE               # Carica l'indirizzo della Routine_Table nel registro t4
    addu $t4, $t4, $t2                  # Aggiunge a t4 il nybble più significativo per calcolare l'indirizzo della routine richiesta
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


