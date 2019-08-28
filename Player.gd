extends KinematicBody2D

# constante de velocidade
const SPEED = 60
# constante de gravidade
const GRAVITY_SPEED = 140
# constante para efeito de aceleração
const UP_FACTOR = 8
# constante de força máxima de salto
const UP_BOOST = -230

# armazena a aceleração de salta
var jumping_accum=GRAVITY_SPEED

# armazena a velocidade do personagem
var velocity = Vector2()
# armazena o estado do personagem (Movendo ou não)
var moving = false

func _ready(): # esta função é chamada quando a cena é iniciada
	# coloca a animação do personagem como PARADO (idle)
	$Sprite/AP.play("idle")

func _physics_process(delta): # esta função é chamada a cada FRAME do jogo (60 fps)
	# verifica se o personagem está em contato com o chão
	if is_on_floor():
		# verifica se a tecla de SETA DIREITA (->) está pressionada
		if Input.is_action_pressed("ui_right"):
			# determina que a velocidade horizontal (x) do personagem seja SPEED (vide constantes acima)
			velocity.x = SPEED
			# "desinverte" a imagem do personagem (não "flipa")
			$Sprite.flip_h = false
			# aciona a animação de CAMINHANDO (walking) do personagem
			$Sprite/AP.play("walking")
			# marca o estado do personagem como MOVENDO
			moving = true
		# SENÃO: verifica se a tecla de SETA ESQUERDA (<-) está pressionada
		elif Input.is_action_pressed("ui_left"):
			# determina que a velocidade horizontal (x) do personagem seja -SPEED (vide constantes acima)
			velocity.x = -SPEED
			# inverte a imagem do personagem horizontalmente ("flipa")
			$Sprite.flip_h = true
			# aciona a animação de CAMINHANDO (walking) do personagem
			$Sprite/AP.play("walking")
			# marca o estado do personagem como MOVENDO
			moving = true
		# SENÃO...
		else:
			# determina que a velocidade horizontal do personagem seja nula
			velocity.x = 0
			# marca o estado do personagem como NÃO MOVENDO
			moving = false
			# aciona a animação de PARADO (idle)
			$Sprite/AP.play("idle")
		
		# verifica se a tecla de espaço foi pressionada
		if Input.is_action_pressed("ui_accept"):
			# toca o som de salto
			$JumpSound.play()
			# determina que a aceleração de salto seja máxima
			jumping_accum = UP_BOOST
	else:
		# não está em contato com o solo, aciona animação de salto
		# MELHORAR: está acionando várias vezes! :-(
		$Sprite/AP.play("jumping")
		
	# verifica se a aceleração de salto é maior (negativamente) do que a velocidade da gravidade
	if jumping_accum < GRAVITY_SPEED:
		# vai diminuindo a velocidade, em quanto sobe, ou aumentando, enquanto desce
		jumping_accum += UP_FACTOR
		# determina que a velocidade vertical do personagem seja igual a jumping_accum
		velocity.y = jumping_accum
	else: # senão
		# velocidade é a da gravidade
		velocity.y = GRAVITY_SPEED	
	
	# somente nesta linha utilizamos as váriáveis para REALMENTE, alterar a posição do personagem!
	# O segundo parâmetro (Vector2(0,-1)) determina a NORMAL (física) do solo, 
	# para determinarmos quando o personagem está em contato com o chão
	move_and_slide(velocity, Vector2(0,-1))