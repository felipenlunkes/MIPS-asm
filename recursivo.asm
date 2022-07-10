##################################################################################################
#
# Algoritmo recursivo para realizar o cálculo dos quadrados pares até o número inserido pelo usuário
#
# Aluno/autor: Felipe Miguel Nery Lunkes
#
# Data: 24/08/2018
#
# Disciplina de Organização de Computadores I (DCC006)
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
        
      la $a0, boasVindas  # Carregar o endereço da string
      li $v0, 4           # Serviço do MARS para impressão de string
      syscall             # Chamada de sistema
      
      addi $sp, $sp, -20  # Vamos separar espaço para a pilha

# Solicitar número. Está separada pois pode ser chamada várias vezes, e não queremos executar o código acima

solicitarNumero:
      
      li $v0, 5                # Serviço para ler um número inteiro  
      syscall                  # Chamada de sistema
      
      sw $v0, 16($sp)          # Vamos salvar este valor na pilha, para recuperar depois

      beqz $v0, divisaoPorZero # Verificar se o número é 0, o que poderia gerar problemas na divisão
      xor $t0, $t0, $t0        # Limpar $t0
      xor $t1, $t1, $t1        # Limpar $t1
      add $t0, $v0, $zero      # Mover para $t0 o valor recuperado do teclado
      addi $t1, $zero, 2       # Adicionar 2 em $t1
      div $t0, $t1             # Dividir por 2 para ver se é par - O resto fica em HI (usar mfhi para acessar o registrador)
      mfhi $t1                 # $t1 tem o resto. Se for 0, número par. Se $t1 != 0, ímpar
      beqz $t1, numeroPar      # Se o valor de resto for 0, par!

# Se não for par, pedir ao usuário para inserir outro número que seja par

.naoPar:
            
      la $a0, naoPar
      li $v0, 4
      syscall
         
      j solicitarNumero # Pulo incondicional para solicitar novo número

# Se o número inserido for zero, pedir ao usuário para inserir outro número

divisaoPorZero:
            
      la $a0, numeroZero
      li $v0, 4
      syscall
         
      j solicitarNumero # Pulo incondicional para solicitar novo número
      
# Se o número for par, vamos começar daqui

numeroPar:

     la $a0, saidaAoQuadrado
     li $v0, 4
     syscall
     
     lw $s0, 16($sp)     # Adicionar o parâmetro numérico, o valor máximo  
     xor $a1, $a1, $a1
     xor $a3, $a3, $a3
     
    # li $a3, 2
     
calcular:
     
     jal salvarRetorno   # Chamar aoQuadrado, para realizar o cálculo do quadrado do número em $a1
    
.soma:

     la $a0, somaValores # Mensagem que informa que os valores serão impressos à seguir
     li $v0, 4           # Serviço para a impressão de strings
     syscall             # Chamada de sistema
     
     lw $a0, 4($sp)
     li $v0, 1
     syscall
     
     j fim
          
salvarRetorno:

     sw $ra, 0($sp)

# Função recursiva abaixo
          
aoQuadradoESomar:

      sw $ra, 12($sp)          # Salvar endereço de retorno
      lw $t0, 16($sp)          # Recuperar da pilha o valor inicial do usuário	
      sw $s0, 8($sp)           # Salvar o parâmetro
      
      addi $a3, $a3, 2
       
      ble $a3, $t0, .processar # Se menor ou igual o valor inserido pelo usuário, continuar aqui
      
      jr $ra                   # Pular para o endereço de retorno da função que chamou
			
.processar:		
      
      mul $v0, $a3, $a3        # Salvar em $v0 o produto de $a0 com $a0
      
      lw $t2, 4($sp)           # Recuperar da pilha o somatório até a rodada anterior
      add $t2, $t2, $v0        # Adicionar o valor calculado nesta rodada
      sw $t2, 4($sp)           # De volta a pilha, para ser recuperado depois
      
      add $a0, $v0, $zero      # Preparar o valor do quadrado calculado, para a impressão
        
      li $v0, 1                # Função de impressão de número inteiro do MARS
      syscall                  # Chamada de sistema
      
      la $a0, espaco           # String que contém um espaço 
      li $v0, 4                # Serviço para imprimir uma string
      syscall                  # Chamada de sistema
                           
      jal aoQuadradoESomar     # Retornar
    
      lw $s0, 8($sp)           # Recuperar o valor de $s0 - convenção
      lw $ra, 0($sp)           # Recuperar o endereço de retorno

      jr $ra
 
fim:

      nop
