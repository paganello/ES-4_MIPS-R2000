.data   0x10010000              # Inizializzazione .data a 0x10010000

START:     .word   0x00000000   # Inizializzazione START a 0x10010000
LED:       .half   0x0000       # Inizializzazione LED a 0x10010004
COMMAND:   .byte   0x00         # Inizializzazione COMMAND  0x10010006

.text

main: 
    la $v0, LED                             # Inserisce in v0 l'indirizzo di LED
    

# Verifica del contenuto di COMMAND che sia diverso da zero
ver_command:  
    la $t1, COMMAND                         # Inserisce in t1 l'indirizzo della cella di COMMAND
    lb  $t1, 0($t1)                         # Inserisce in t1 il contenuto di COMMAND
    andi $t1, $t1, 0x000000ff               # Moltiplica il contenuto di t1 con 0x000000ff, essendo che COMMAND è a 8 bit e un registro è a 32 bit
    bne $t1, $zero, send_1000H_to_CPU       # Verifica che il contenuto di t1 sia diverso da zero, se è true, va in "send_1000H_to_CPU"
    j ver_command                           # ripete ver_command visto che t1 è uguale a 0 e quindi COMMAND è uguale a 0


# Invia la parola 1000H nella cella a 16 bit denominata START

send_1000H_to_CPU:
    addi $t0, $zero, 0x1000                # Inserisce in t0 la parola 1000H
    la $t1, START                          # Inserisce in t1 l'indirizzo della cella di START
    sw $t0, 0($t1)                         # Memorizza in t1 (=START) il contenuto di t0
    j controllo                            # salta a controllo_start


# Verifica del contenuto di start che corrisponda alla parola 1000H
# Estrazione del comando COMMAND nei 2 nybble rispettivamente più significativi e meno significativi. Nel nybble meno significativi, effettuo il complemento bit a bit

controllo:
    # Verifico START
    la  $t0, START                      # Inserisce in t0 l'indirizzo della cella di START
    lw	$t1, 0($t0)                     # Inserisce in t1 il contenuto di START
    addi $t2, $zero, 0x1000             # Inserisce in t2 la parola 1000He
    bne $t1, $t2, controllo             # Verifica che il contenuto di t0 corrisponda al contenuto di t2, se è true, continua con l'istruzione successiva se no ritorna all'inizio di (controllo_start)

    # Azzero i registri
    add $t2, $zero, $zero               # Azzera t2 
    add $t1, $zero, $zero               # Azzera t1
    add $t0, $zero, $zero               # Azzera t0
    addu $t0, $zero, 0xEE6B2800         # Carica in t0 il valore che serve per l'attesa nelle routine (t0 viene usato nelle routine ma lo inizializzo prima)

    la $t1, COMMAND                     # Inserisce in t1 l'indirizzo della cella di COMMAND
    lb $t1, 0($t1)                      # Inserisce in t1 il di COMMAND  --> Esempio: 1110 0001                 
    andi $t1, $t1, 0x000000FF           # Moltiplica il contenuto di t1 con 0x000000FF, essendo che COMMAND è a 8 bit e un registro è a 32 bit => azzera tutti i bit tranne quelli che mi servono
    andi $t2, $t1, 0x000000F0           # Estrae il nybble piu significativo  -->  1110 0000 => azzera tutti i bit tranne quelli che mi servono
    andi $t3, $t1, 0x0000000F           # Estrae il nybble meno significativo -->  0000 0001 => azzera tutti i bit tranne quelli che mi servono
    
    # Verifica la correttezza di COMMAND
    srl $t2, $t2, 4                     # Shift a destra il nybble più significativo di 4 posizioni  -->  0000 1110
    not $t4, $t2                        # Nega il nybble più significativo facendo il complemento bit a bit  -->  1111 0001
    andi $t4, $t4, 0x0000000f           # Estrae il complemento bit a bit -->  0000 0001
    bne $t4, $t3, errore                # Verifica che il contenuto di t3 sia diverso da t4, se è true, salta all'etichetta errore, se no continua

    # Se va bene computo e salto alla cella della label con la relativa routine
    mul $t3, $t2, 0x0000000C            # Trova l'offset => Moltiplico per 12 (numero di byte che separa una label routine dall'altra) => ogni istruzione sono 1 word = 4 byte, deve saltare 3 istruzioni => 4 * 3 = 12 byte
                                        # Dato che il salto tra una routine e l'altra e' fisso e ogni comando corrisponde ad una routine, moltiplico per 12 il comando.                         
    la $t4, routine0Address             # Carica in t4 l'indirizzo della cella di routine0Address (prima routine)
    addu $t3, $t3, $t4                  # Somma all'offest l'indirizzo della prima routine, le altre sono in fila dopo di essa a distanza di 12 byte l'una dall'altra
    jal $t3                             # Salta all'indirizzo della routine e aggiorna $ra in modo che terminata la routine posso andare a JALM+4 -> istruzione successiva a questa

    j end                               # termina il programma


#Gestione dell'errore
errore:
    andi $t3, $t3, 0x00000000           # Imposta il registro $t3 a 0
    andi $t2, $t2, 0x00000000           # Imposta il registro $t2 a 0
    addi $t5, $zero, 0x0000003C         # Imposta il contatore a 60 (numero di secondi) su t5
    addu $t2, $zero, 0x77359400         # 2.000.000.000 
    addu $t3, $zero, 0x00008000         # Imposta il valore 8000 nel registro $t3 (led acceso)

# lampeggio led
led_loop:
    add $t4, $zero, $t2                 # Mette in t4 il contenuto di t2
    sw $zero, 0($v0)                    # Scrive il valore 0 nella cella LED (led spento)
    jal delay_loop                      # Salta alla funzione delay per un ritardo di 2 secondi

    add $t4, $zero, $t2                 # Mette in t4 il contenuto di t2
    sw $t3, 0($v0)                      # Scrive il valore 8000 nella cella LED (led acceso)
    jal delay_loop                      # Salta alla funzione delay per un ritardo di 2 secondi

    addi $t5, $t5, -0x00000002          # Sottrae 2 dal contatore dei secondi rimanenti
    beq $t5, $zero, end                 # Salta al ciclo del led se il contatore non è zero
    j led_loop                          # ritorna a led loop e ricomincio il ciclo di lampeggio

# Gestione contatore per il lampeggio
delay_loop:                             # 2.000.000.000 / 4 = 500.000.000 cicli = 1 sec, dato che abbiamo 2 istruzioni => 2*1 = 2 secondi
    addi $t4, $t4, -0x00000004          # Decrementa il contatore del ritardo di (1/500000000)*2 secondi, espresso in nanosecondi = 4
    bnez $t4, delay_loop                # Ripete il ciclo finché il contatore non è zero
    jr $ra




# LISTA DELLE ROUTINE con ognuna il relativo loop
routine0Address:
    addi $t0, $t0, -0x00000004           # Decrementa il contatore di 1
    bne $t0, $zero, routine0Address      # Verifica che il contatore non sia uguale a 0 e continua il loop
    jr $ra

routine1Address:
    addi $t0, $t0, -0x00000004 
    bne $t0, $zero, routine1Address
    jr $ra
    
routine2Address:
    addi $t0, $t0, -0x00000004 
    bne $t0, $zero, routine2Address
    jr $ra
    
routine3Address:
    addi $t0, $t0, -0x00000004 
    bne $t0, $zero, routine3Address
    jr $ra
    
routine4Address:
    addi $t0, $t0, -0x00000004 
    bne $t0, $zero, routine4Address
    jr $ra
    
routine5Address:
    addi $t0, $t0, -0x00000004 
    bne $t0, $zero, routine5Address
    jr $ra
    
routine6Address:
    addi $t0, $t0, -0x00000004 
    bne $t0, $zero, routine6Address
    jr $ra
    
routine7Address:
    addi $t0, $t0, -0x00000004 
    bne $t0, $zero, routine7Address
    jr $ra
    
routine8Address:
    addi $t0, $t0, -0x00000004 
    bne $t0, $zero, routine8Address
    jr $ra
    
routine9Address:
    addi $t0, $t0, -0x00000004 
    bne $t0, $zero, routine9Address
    jr $ra
    
routine10Address:
    addi $t0, $t0, -0x00000004 
    bne $t0, $zero, routine10Address
    jr $ra
    
routine11Address:
    addi $t0, $t0, -0x00000004 
    bne $t0, $zero, routine11Address
    jr $ra
    
routine12Address:
    addi $t0, $t0, -0x00000004 
    bne $t0, $zero, routine12Address
    jr $ra
    
routine13Address:
    addi $t0, $t0, -0x00000004 
    bne $t0, $zero, routine13Address
    jr $ra
    
routine14Address:
    addi $t0, $t0, -0x00000004 
    bne $t0, $zero, routine14Address
    jr $ra
    
routine15Address:
    addi $t0, $t0, -0x00000004 
    bne $t0, $zero, routine15Address
    jr $ra


# Fine Programma
end:
    addu $t0, $zero, 0x10010004     # Carica in t0 l'indirizzo di LED
    sw $zero, 0($t0)                # Azzera il registro LED
    andi $t7, $t7, 0x00000000       # Carica 0x00000000 in t7    
    move $t0, $t7                   # Azzera t0
    move $t1, $t7                   # Azzera t1
    move $t2, $t7                   # Azzera t2
    move $t3, $t7                   # Azzera t3
    move $t4, $t7                   # Azzera t4
    move $t5, $t7                   # Azzera t5
    j ver_command                   # Ritorna alla verifica di command

