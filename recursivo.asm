##################################################################################################
#
# Algoritmo recursivo para realizar o c�lculo dos quadrados pares at� o n�mero inserido pelo usu�rio
#
# Aluno/autor: Felipe Miguel Nery Lunkes
#
# Data: 24/08/2018
#
# Disciplina de Organiza��o de Computadores I (DCC006)
#
#################################################################################################

.data
    
boasVindas:      .asciiz "\n\nDigite um numero para comecar: "
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
      
      addi $sp, $sp, -20  # Vamos separar espa�o para a pilha

# Solicitar n�mero. Est� separada pois pode ser chamada v�rias vezes, e n�o queremos executar o c�digo acima

solicitarNumero:
      
      li $v0, 5                # Servi�o para ler um n�mero inteiro  
      syscall                  # Chamada de sistema
      
      sw $v0, 16($sp)          # Vamos salvar este valor na pilha, para recuperar depois

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

     la $a0, saidaAoQuadrado
     li $v0, 4
     syscall
     
     lw $s0, 16($sp)     # Adicionar o par�metro num�rico, o valor m�ximo  
     xor $a1, $a1, $a1
     xor $a3, $a3, $a3
     
    # li $a3, 2
     
calcular:
     
     jal salvarRetorno   # Chamar aoQuadrado, para realizar o c�lculo do quadrado do n�mero em $a1
    
.soma:

     la $a0, somaValores # Mensagem que informa que os valores ser�o impressos � seguir
     li $v0, 4           # Servi�o para a impress�o de strings
     syscall             # Chamada de sistema
     
     lw $a0, 4($sp)
     li $v0, 1
     syscall
     
     j fim
          
salvarRetorno:

     sw $ra, 0($sp)

# Fun��o recursiva abaixo
          
aoQuadradoESomar:

      sw $ra, 12($sp)          # Salvar endere�o de retorno
      lw $t0, 16($sp)          # Recuperar da pilha o valor inicial do usu�rio	
      sw $s0, 8($sp)           # Salvar o par�metro
      
      addi $a3, $a3, 2
       
      ble $a3, $t0, .processar # Se menor ou igual o valor inserido pelo usu�rio, continuar aqui
      
      jr $ra                   # Pular para o endere�o de retorno da fun��o que chamou
			
.processar:		
      
      mul $v0, $a3, $a3        # Salvar em $v0 o produto de $a0 com $a0
      
      lw $t2, 4($sp)           # Recuperar da pilha o somat�rio at� a rodada anterior
      add $t2, $t2, $v0        # Adicionar o valor calculado nesta rodada
      sw $t2, 4($sp)           # De volta a pilha, para ser recuperado depois
      
      add $a0, $v0, $zero      # Preparar o valor do quadrado calculado, para a impress�o
        
      li $v0, 1                # Fun��o de impress�o de n�mero inteiro do MARS
      syscall                  # Chamada de sistema
      
      la $a0, espaco           # String que cont�m um espa�o 
      li $v0, 4                # Servi�o para imprimir uma string
      syscall                  # Chamada de sistema
                           
      jal aoQuadradoESomar     # Retornar
    
      lw $s0, 8($sp)           # Recuperar o valor de $s0 - conven��o
      lw $ra, 0($sp)           # Recuperar o endere�o de retorno

      jr $ra
 
fim:

      nop
