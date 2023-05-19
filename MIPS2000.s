.data   0x10010000              # Inizializzazione .data a 0x10010000

START:     .word   0x00000000   # Inizializzazione START a 0x10010004
LED:       .half   0x0000       # Inizializzazione LED a 0x10010006
COMMAND:   .byte   0xE2         # Inizializzazione COMMAND  0x10010007

.text

main: 
    la $v0, LED                             # Inserisce in v0 l'indirizzo di LED
    

# Verifica del contenuto di COMMAND che sia diverso da zero
ver_command:  
    la $t1, COMMAND                         # Inserisce in t1 l'indirizzo della cella di COMMAND
    lb  $t1, 0($t1)                         # Inserisce in t1 il contenuto di COMMAND
    andi $t1, $t1, 0x000000ff               # Moltiplica il contenuto di t1 con 0x000000ff, essendo che COMMAND è a 8 bit e un regitro è a 32 bit
    bne $t1, $zero, send_1000H_to_CPU       # Verifica che il contenuto di t1 sia diverso da zero, se è true, va in "send_1000H_to_CPU"
    j ver_command                           # ripete ver_command visto che t1 è uguale a 0 e quindi COMMAND è uguale a 0


# Invia la parola 1000H nella cella a 16 bit denominata START

send_1000H_to_CPU:
    addi $t0, $zero, 0x1000                # Inserisce in t0 la parola 1000H
    la $t1, START                          # Inserisce in t1 l'indirizzo della cella di START
    sw $t0, 0($t1)                         # Memorizza in t1 (=START) il contenuto di t0
    j controllo_start                      # salta a controllo_start


# Verifica del contenuto di start che corrisponda alla parola 1000H
# Estrazione del comando COMMAND nei 2 nybble rispettivamente più significativi e meno significativi. Nel nybble meno significativi, effettuo il complemento bit a bit

controllo_start:
    la  $t0, START                      # Inserisce in t0 l'indirizzo della cella di START
    lw	$t1, 0($t0)  		            # Inserisce in t1 il contenuto di START
    addi $t2, $zero, 0x1000             # Inserisce in t2 la parola 1000He
    bne $t1, $t2, controllo_start       # Verifica che il contenuto di t0 corrisponda al contenuto di t2, se è true, continua con l'istruzione successiva se no ritorna all'inizio di "controllo_start)

    add $t2, $zero, $zero               # Azzera t2 
    add $t1, $zero, $zero               # Azzera t1
    add $t0, $zero, $zero               # Azzera t0
    li $t0, 15000000000                 # Carico in t0 il valore che serve per l'attesa nelle routine (t0 viene usato nelle routine ma lo inizializzo prima)

    la $t1, COMMAND                     # Inserisce in t1 l'indirizzo della cella di COMMAND
    lb $t1, 0($t1)                      # Inserisce in t1 il di COMMAND                    
    
                                        # Esempio: 1110 0001
    andi $t1, $t1, 0x000000FF           # Moltiplica il contenuto di t1 con 0x000000FF, essendo che COMMAND è a 8 bit e un regitro è a 32 bit


    #Problema: la porta xor per qualsiasi combinazione tu metti da sempre il risultato uguale a t1, anche se il complemento a 1 non viene rispettato
    #Soluzione: vado a recuperare il nybble piu sign., lo sposto a dx di 4, faccio inverso, contollo che sia uguale al bit meno sign.
    andi $t2, $t1, 0x000000F0           # Estraggo il nybble piu significativo  -->  1110 0000
    andi $t3, $t1, 0x0000000F           # Estraggo il nybble meno significativo -->  0000 0001
    srl $t2, $t2, 4                     # Shift a destra il nybble più significativo di 4 posizioni  -->  0000 1110
    not $t4, $t2                        # Nega il nybble più significativo facendo il complemento bit a bit  -->  1111 0001
    andi $t4, $t4, 0x0000000f           # Estraggo il complemento bit a bit -->  0000 0001
    bne $t4, $t3, errore                #Verifica che il contenuto di t3 sia diverso da t4, se è true, salta all'etichetta errore, se no continua

    mul $t3, $t2, 0x0000000C            # Moltiplico per 12 (numero di byte che separa una label routine dall'altra) => ogni istruzione sono 1 word = 4 byte, devo saltare 3 istruzioni => 4 * 3 = 12 byte
                                        # Dato che il salto tra una routine e l'altra e' fissom e ogni comando corrisponde ad una routine,  moltiplico per 12 il comando.
                                        
    la $t4, routine0Address             # Inserisce in t4 l'indirizzo della cella di routine0Address
    addu $t3, $t3, $t4                   # Aggiunge a t3 la somma tra l'offset tra le routine e il complemento bit a bit del nybble più significativo
    jal $t3                             # Salta all'indirizzo della routine richiesta

    j end                               # termina il programma


#Gestione dell'errore

errore:
    move $t3, $zero                 # Imposta il registro $t3 a 0


# Il comando non è corretto, inibisce l'accettazione di dati per 60 secondi 

    li $t5, 60                      # Imposta il contatore a 60 (numero di secondi) su t5
    li $a0, -2                      # Imposta il secondo contatore a 2 (numero di secondi) su a0


# lampeggio led

led_loop:
    sw $zero, 0($v0)                # Scrive il valore 0 nella cella LED (led spento)
    jal delay_loop                  # Salta alla funzione delay per un ritardo di 2 secondi

    li $t3, 0x8000                  # Imposta il valore 8000 nel registro $t3 (led acceso)
    sw $t3, 0($v0)                  # Scrive il valore 8000 nella cella LED (led acceso)
    jal delay_loop                  # Salta alla funzione delay per un ritardo di 2 secondi

    add $t5, $t5, $a0               # Sottrae 2 dal contatore dei secondi rimanenti
    beq $t5, $zero, end             # Salta al ciclo del led se il contatore non è zero
    j led_loop                      # ritorno a led loop e ricomincio il ciclo di lampeggio


# Gestione contatore per il lampeggio

delay_loop:
    addi $t4, $t4, -400         # Decrementa il contatore del ritardo di (1/500000000)*2 secondi, espresso in microsecondi
    bnez $t4, delay_loop        # Ripeti il ciclo finché il contatore non è zero
    jr $ra



# LISTA DELLE ROUTINE con ognuna il relativo loop

routine0Address:
    addi $t0, $t0, -1                   # Decrementa il contatore di 1
    bne $t0, $zero, routine0Address     # Verifica che il contatore non sia uguale a 0 e continua il loop
    jr $ra

routine1Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine1Address
    jr $ra
    
routine2Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine2Address
    jr $ra
    
routine3Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine3Address
    jr $ra
    
routine4Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine4Address
    jr $ra
    
routine5Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine5Address
    jr $ra
    
routine6Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine6Address
    jr $ra
    
routine7Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine7Address
    jr $ra
    
routine8Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine8Address
    jr $ra
    
routine9Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine9Address
    jr $ra
    
routine10Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine10Address
    jr $ra
    
routine11Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine11Address
    jr $ra
    
routine12Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine12Address
    jr $ra
    
routine13Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine13Address
    jr $ra
    
routine14Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine14Address
    jr $ra
    
routine15Address:
    addi $t0, $t0, -1
    bne $t0, $zero, routine15Address
    jr $ra


# Fine Programma
end:
    li $t7, 0x00000000          # Carico 0x00000000 in t7    
    move $t0, $t7               # Azzero t0
    move $t1, $t7               # Azzero t1
    move $t2, $t7               # Azzero t2
    move $t3, $t7               # Azzero t3
    move $t4, $t7               # Azzero t4
    move $t5, $t7               # Azzero t5
    j ver_command               # Ritorno alla verifica di command


