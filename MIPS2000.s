.data   0x10010000              # Inizializzazione .data a 0x10010000

START:     .word   0x00000000   # Inizializzazione START a 0x10010004
LED:       .half   0x0000       # Inizializzazione LED a 0x10010006
COMMAND:   .byte   0xE1         # Inizializzazione COMMAND  0x10010007

.text

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
    la $t1, START 
    sw $t0, 0($t1)                        # Memorizza in START il contenuto di t0
    j controllo_start                      # salta a controllo_start


# Verifica del contenuto di start che corrisponda alla parola 1000H
# Estrazione del comando COMMAND nei 2 nybble rispettivamente più significativi e meno significativi. Nel nybble meno significativi, effettuo il complemento bit a bit

controllo_start:
    la  $t0, START 
    lw	$t1, 0($t0)  		            # Inserisce in t0 il contenuto di START
    addi $t2, $zero, 0x1000             # Inserisce il t2 il risultato della somma tra 0 e 1000H in esadecimale
    bne $t1, $t2, controllo_start       # Verifica che se il contenuto di t0 corrisponde al contenuto di t2, allora continua con l'istruzione successiva

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

    # Dato che quello che ha scritto bonse era una cacata pazzasca, l'ho rifatto:
    
    #sll $t2, $t2, 2                    # Moltiplica il nybble più significativo per 4 per ottenere l'offset
    #la $t4, routine0Address            # Carica l'indirizzo della Routine_Table nel registro t4
    srl $t2, $t2, 4                     # Shilto a desta di 4 posizioni => 1110 0000 --> 0000 1110
    andi $t3, $t2, 0x0000000C           # Moltiplico per 12(numero di byte che separa una label routine dall'altra) => ogni istruzione sono 1 word = 4 byte, devo saltare 3 istruzioni => 4*3 = 12 byte
                                        # Dato che il salto tra una routine e l'altra e' fisso, e dato che ogni comendo corrisponde a una routine,  moltiplico per 12 il comando.
    la $t4, routine0Address
    add $t3, $t3, $t4           # Ci sommo il valore della cella corrispondente alla prima label
    #addu $t4, $t4, $t2                 # Aggiunge a t4 il nybble più significativo per calcolare l'indirizzo della routine richiesta
    jal $t3                             # Salta all'indirizzo della routine richiesta

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



# Routine
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


