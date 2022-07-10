##################################################################################################
#
# Algoritmo iterativo para realizar o cálculo dos quadrados pares até o número inserido pelo usuário
#
# Aluno/autor: Felipe Miguel Nery Lunkes
#
# Data: 22/08/2018
#
# Disciplina de Organização de Computadores I (DCC006)
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
        
      la $a0, boasVindas  # Carregar o endereço da string
      li $v0, 4           # Serviço do MARS para impressão de string
      syscall             # Chamada de sistema
      
      addi $sp, $sp, -16  # Vamos separar espaço para a pilha

# Solicitar número. Está separada pois pode ser chamada várias vezes, e não queremos executar o código acima

solicitarNumero:
      
      li $v0, 5                # Serviço para ler um número inteiro  
      syscall                  # Chamada de sistema
      
      sw $v0, 12($sp)          # Vamos salvar este valor na pilha, para recuperar depois

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

     lw $v0, 12($sp)       
     xor $s0, $s0, $s0   # O número original será salvo aqui, então vamos
     add $s0, $v0, $zero # Pronto
     xor $t0, $t0, $t0   # Limpar $t0
     xor $t1, $t1, $t1   # Limpar $t1
    
     la $a0, saidaAoQuadrado
     li $v0, 4
     syscall
     
     xor $a0, $a0, $a0 # Será usado como variável para impressão
     xor $a1, $a1, $a1 # Será usado como acumulador para a contagem de repetições
     sw $s0, 8($sp)    # Salvar o valor de $s0 - convenção
     li $s0, 2         # Começar com 2, o primeiro número par != 0

# Começando o loop com o valor definido em $a1, que será o acumulador do loop neste algoritmo
      
loopCalcular:
 
     xor $a0, $a0, $a0
     add $a0, $s0, $zero
     
     jal aoQuadrado      # Chamar aoQuadrado, para realizar o cálculo do quadrado do número em $a1
     
     sw $v0, 4($sp)      # Salvar o valor obtido desta conta, no registrador convencionado de retorno
     
     add $a0, $v0, $zero # Agora vamos imprimir na tela o valor retornado por aoQuadrado
     li $v0, 1           # Função de imprimir número inteiro
     syscall             # Chamada de sistema
         
     lw $a0, 0($sp)      # Recuperar o somatório total como primeiro parâmetro para a função soma
     lw $a1, 4($sp)      # Recuperar o valor da última operação ao quadrado como segundo parâmetro
     
     jal somar           # Agora, chamar a função de soma, que recupera o valor salvo na pilha após aoQuadrado e o soma com o valor anterior
                         # guardado na pilha
     
     sw $v0, 0($sp)      # Salvar na pilha o valor retornado pela função
      
     lw $t0, 12($sp)     # Recuperar da pilha o valor inicial do usuário
     beq $s0, $t0, fim   # Verificar se o valor atual de $a1 e o recuperado são iguais. Se sim, pular para fim
 
     la $a0, espaco      # String que contém um espaço 
     li $v0, 4           # Serviço para imprimir uma string
     syscall             # Chamada de sistema
     
     addi $s0, $s0, 2    # Incrementar o contador em 2, para o próximo número par
              
     j loopCalcular      # Se o loop não tiver terminado, retornar para ele para continuar os cálculos

# Função aoQuadrado
#
# Função responsável por elevar um número ao quadrado
#
# Entrada:
#
# $a0 - Número que será elevado ao quadrado
#
# Saída:
#
# $v0 - número ao quadrado 

aoQuadrado:

     sw $ra, 8($sp)    # Salvar endereço de retorno

     mul $v0, $a0, $a0 # Salvar em $v0 o produto de $a0 com $a0
     sw $v0, 4($sp)    # Salvar o valor de $v0 na pilha, para ser usado por somar
     
     lw $ra, 8($sp)    # Recuperar o endereço de retorno
     
     jr $ra            # Pular para o endereço de retorno

# Função somar
#
# Função responsável por somar dois valores da pilha (somatório e último valor ao quadrado)
#
# Entrada:
#
# $a0 - Valor do somatório já executado
# $a1 - Valor da última operação de quadrado
#
# Saída:
#
# $v0 - valor somado
     
somar:
     
     sw $ra, 8($sp)     # Salvar endereço de retorno

     xor $t2, $t2, $t2  # Limpar $t2
     add $v0, $a0, $a1  # Adicionar no registrador de retorno os dois parâmetros
  
     lw $ra, 8($sp)     # Recuperar o endereço de retorno
       
     jr $ra             # Pular para o endereço de retorno

# Fim
#
# Esta última etapa realiza a impressão do somatório final, que está na pilha, para o usuário
     
fim:

     la $a0, somaValores # Mensagem que informa que os valores serão impressos à seguir
     li $v0, 4           # Serviço para a impressão de strings
     syscall             # Chamada de sistema
	
     lw $a0, 0($sp)      # Recuperar somatório na pilha
     li $v0, 1           # Serviço para a impressão de valores inteiros
     syscall             # Chamada de sistema
     
     la $a0, quebra      # Uma quebra de linha 
     li $v0, 4           # Serviço para a impressão de strings
     syscall             # Chamada de sistema
    
     sw $s0, 8($sp)      # Recuperar o valor de $s0 - convenção 
     addi $sp, $sp, 16   # Recuperar a pilha
     
     nop                 
