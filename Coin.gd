extends Area2D

# prepara os novos sinais que serão disparados por esta cena
signal coin_caught
signal coin_lost

# função chamada externamente para determinar e iniciar o comportamento da moeda
func init(delay):
	# determina o tempo de vida da moeda na tela
	$Timer.wait_time = delay
	# inicia o temporizador (contagem de tempo)
	$Timer.start()

# função disparada quando há contato de um objeto (como o personage) com a moeda 
func _on_Coin_body_entered(body):
	# verifica se o objeto que entrou em contato com a moeda é o Personagem
	if "Player" in body.name:
		# some com a moeda
		visible = false
		# emite o sinal de CAPTURADA
		emit_signal("coin_caught", self)
		# toca o som de captura
		$CatchSound.play()

# função disparada quando a música de captura termina de tocar
func _on_CatchSound_finished():
	# remove a moeda da memória do jogo
	queue_free()

# função disparada quando o temporizador termina
# o tempo deste temporizado é determinado na função init (acima)
func _on_Timer_timeout():
	# emite o sinal de moeda perdida
	emit_signal("coin_lost", self)
	# remove a moeda da memória do jogo
	queue_free()
