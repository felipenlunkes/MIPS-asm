##################################################################################################
#
# Algoritmo iterativo para realizar o c�lculo dos quadrados pares at� o n�mero inserido pelo usu�rio
#
# Aluno/autor: Felipe Miguel Nery Lunkes
#
# Data: 22/08/2018
#
# Disciplina de Organiza��o de Computadores I (DCC006)
#
#################################################################################################

.data
    
boasVindas:      .asciiz "\n\nDigite um numero para comecar: "
valores:         .asciiz "n^2: "
quebra:          .asciiz "\n"
somaValores:     .asciiz "\nSoma dos valores: "
naoPar:          .asciiz "\nO numero inserido nao e par! :-(\nInsira outro abaixo para continuar: "
Par:             .asciiz "\nEste numero e par! :-)\n"
saidaAoQuadrado: .asciiz "\nparaQuadrado: "
espaco:          .asciiz " "   
numeroZero:      .asciiz "\nO numero inserido nao pode ser utilizado (impossivel dividir por zero). Por favor, tente novamente: "

.text

# Ponto de entrada deste algoritmo

inicio:
        
      la $a0, boasVindas  # Carregar o endere�o da string
      li $v0, 4           # Servi�o do MARS para impress�o de string
      syscall             # Chamada de sistema
      
      addi $sp, $sp, -16  # Vamos separar espa�o para a pilha

# Solicitar n�mero. Est� separada pois pode ser chamada v�rias vezes, e n�o queremos executar o c�digo acima

solicitarNumero:
      
      li $v0, 5                # Servi�o para ler um n�mero inteiro  
      syscall                  # Chamada de sistema
      
      sw $v0, 12($sp)          # Vamos salvar este valor na pilha, para recuperar depois

      beqz $v0, divisaoPorZero # Verificar se o n�mero � 0, o que poderia gerar problemas na divis�o
      xor $t0, $t0, $t0        # Limpar $t0
      xor $t1, $t1, $t1        # Limpar $t1
      add $t0, $v0, $zero      # Mover para $t0 o valor recuperado do teclado
      addi $t1, $zero, 2       # Adicionar 2 em $t1
      div $t0, $t1             # Dividir por 2 para ver se � par - O resto fica em HI (usar mfhi para acessar o registrador)
      mfhi $t1                 # $t1 tem o resto. Se for 0, n�mero par. Se $t1 != 0, �mpar
      beqz $t1, numeroPar      # Se o valor de resto for 0, par!

# Se n�o for par, pedir ao usu�rio para inserir outro n�mero que seja par

.naoPar:
            
      la $a0, naoPar
      li $v0, 4
      syscall
         
      j solicitarNumero # Pulo incondicional para solicitar novo n�mero

# Se o n�mero inserido for zero, pedir ao usu�rio para inserir outro n�mero

divisaoPorZero:
            
      la $a0, numeroZero
      li $v0, 4
      syscall
         
      j solicitarNumero # Pulo incondicional para solicitar novo n�mero
      
# Se o n�mero for par, vamos come�ar daqui

numeroPar:

     lw $v0, 12($sp)       
     xor $s0, $s0, $s0   # O n�mero original ser� salvo aqui, ent�o vamos
     add $s0, $v0, $zero # Pronto
     xor $t0, $t0, $t0   # Limpar $t0
     xor $t1, $t1, $t1   # Limpar $t1
    
     la $a0, saidaAoQuadrado
     li $v0, 4
     syscall
     
     xor $a0, $a0, $a0 # Ser� usado como vari�vel para impress�o
     xor $a1, $a1, $a1 # Ser� usado como acumulador para a contagem de repeti��es
     sw $s0, 8($sp)    # Salvar o valor de $s0 - conven��o
     li $s0, 2         # Come�ar com 2, o primeiro n�mero par != 0

# Come�ando o loop com o valor definido em $a1, que ser� o acumulador do loop neste algoritmo
      
loopCalcular:
 
     xor $a0, $a0, $a0
     add $a0, $s0, $zero
     
     jal aoQuadrado      # Chamar aoQuadrado, para realizar o c�lculo do quadrado do n�mero em $a1
     
     sw $v0, 4($sp)      # Salvar o valor obtido desta conta, no registrador convencionado de retorno
     
     add $a0, $v0, $zero # Agora vamos imprimir na tela o valor retornado por aoQuadrado
     li $v0, 1           # Fun��o de imprimir n�mero inteiro
     syscall             # Chamada de sistema
         
     lw $a0, 0($sp)      # Recuperar o somat�rio total como primeiro par�metro para a fun��o soma
     lw $a1, 4($sp)      # Recuperar o valor da �ltima opera��o ao quadrado como segundo par�metro
     
     jal somar           # Agora, chamar a fun��o de soma, que recupera o valor salvo na pilha ap�s aoQuadrado e o soma com o valor anterior
                         # guardado na pilha
     
     sw $v0, 0($sp)      # Salvar na pilha o valor retornado pela fun��o
      
     lw $t0, 12($sp)     # Recuperar da pilha o valor inicial do usu�rio
     beq $s0, $t0, fim   # Verificar se o valor atual de $a1 e o recuperado s�o iguais. Se sim, pular para fim
 
     la $a0, espaco      # String que cont�m um espa�o 
     li $v0, 4           # Servi�o para imprimir uma string
     syscall             # Chamada de sistema
     
     addi $s0, $s0, 2    # Incrementar o contador em 2, para o pr�ximo n�mero par
              
     j loopCalcular      # Se o loop n�o tiver terminado, retornar para ele para continuar os c�lculos

# Fun��o aoQuadrado
#
# Fun��o respons�vel por elevar um n�mero ao quadrado
#
# Entrada:
#
# $a0 - N�mero que ser� elevado ao quadrado
#
# Sa�da:
#
# $v0 - n�mero ao quadrado 

aoQuadrado:

     sw $ra, 8($sp)    # Salvar endere�o de retorno

     mul $v0, $a0, $a0 # Salvar em $v0 o produto de $a0 com $a0
     sw $v0, 4($sp)    # Salvar o valor de $v0 na pilha, para ser usado por somar
     
     lw $ra, 8($sp)    # Recuperar o endere�o de retorno
     
     jr $ra            # Pular para o endere�o de retorno

# Fun��o somar
#
# Fun��o respons�vel por somar dois valores da pilha (somat�rio e �ltimo valor ao quadrado)
#
# Entrada:
#
# $a0 - Valor do somat�rio j� executado
# $a1 - Valor da �ltima opera��o de quadrado
#
# Sa�da:
#
# $v0 - valor somado
     
somar:
     
     sw $ra, 8($sp)     # Salvar endere�o de retorno

     xor $t2, $t2, $t2  # Limpar $t2
     add $v0, $a0, $a1  # Adicionar no registrador de retorno os dois par�metros
  
     lw $ra, 8($sp)     # Recuperar o endere�o de retorno
       
     jr $ra             # Pular para o endere�o de retorno

# Fim
#
# Esta �ltima etapa realiza a impress�o do somat�rio final, que est� na pilha, para o usu�rio
     
fim:

     la $a0, somaValores # Mensagem que informa que os valores ser�o impressos � seguir
     li $v0, 4           # Servi�o para a impress�o de strings
     syscall             # Chamada de sistema
	
     lw $a0, 0($sp)      # Recuperar somat�rio na pilha
     li $v0, 1           # Servi�o para a impress�o de valores inteiros
     syscall             # Chamada de sistema
     
     la $a0, quebra      # Uma quebra de linha 
     li $v0, 4           # Servi�o para a impress�o de strings
     syscall             # Chamada de sistema
    
     sw $s0, 8($sp)      # Recuperar o valor de $s0 - conven��o 
     addi $sp, $sp, 16   # Recuperar a pilha
     
     nop                 
