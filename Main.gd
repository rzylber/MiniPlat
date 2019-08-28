extends Node2D

# pré carrega a cena da moeda (Coin) 
var Coin = preload("Coin.tscn")

# armazena a quantidade atual de pontos do jogador
var points = 0

# armazena o tempo máximo (atual) que a moeda fica na tela
var fase_delay = 20

# armazena os locais (Position2D, filhos de Locais) livres para aparecimento de moeda
var locais_livres

# armazena o ID que será usado para vincular uma moeda com um local
var id = 0
# armazena as relações moeda X local que estão em uso, na tela
# utilizo este mapa para devolver um local para locais_livres quando uma moeda sai da tela
var locais_usados = {}

# cira o gerador de números aleatórios
var rng = RandomNumberGenerator.new()

func _ready(): # esta função é chamada quando a cena é iniciada
	# inicializa o gerador de números aleatórios
	rng.randomize()
	
	# prepara a plataforma (tijolos que compõem o "chão" da plataforma)
	set_one_way_for_tiles()	
	
	# Insere todos os filhos de Locais (Position2D) em locais_livres	
	locais_livres = $Locais.get_children()
	
	# cria a primeira moeda
	create_coin()

func create_coin():
	# verifica se há locais livres para criação de moeda
	if locais_livres.size() > 0:
		# sorteia uma posição entre os locais livres
		var posicao_sorteada = rng.randi_range(0, locais_livres.size() - 1)
		# pega o item na posicao sorteada
		var local_sorteado = locais_livres[posicao_sorteada]
		# remove o local sorteado da lista de locais livres
		locais_livres.remove(posicao_sorteada)
		
		# cria a moeda no local
		create_coin_at(local_sorteado)
		
		# dispara um temporizador para criação da próxima moeda (tempo é aleatório)
		$TimerNewCoin.start(rng.randi_range(4,8))
		
func create_coin_at(local):
	# cria uma instância da cena de moeda
	var node = Coin.instance() as Area2D
	
	# incrementa 1 ao ID para identificar esta moeda na lista de usados
	id += 1
	# nomeia a moeda como "coin_ID" (id acima incrementado, ex: coin_1, coin_2, ...)
	node.name = "coin_" + String(id)
	# associa a nova moeda ao local utilizado (ex: coin_1 -> Local12)
	locais_usados[node.name] = local
	
	# posiciona a nova moeda na mesma localização do local utilizado
	node.translate(local.position)
	# inicializa a moeda com seu tempo de permanência sorteado - VIDE A CENA DA MOEDA (Coin.tscn)
	node.init(rng.randi_range(8,fase_delay))
	# conecta o sinal coin_caught com a função _on_coin_caught. 
	# Este sinal é disparado quando a moeda é CAPTURADA pelo usuário
	node.connect("coin_caught", self, "_on_coin_caught")
	# conecta o sinal coin_lost com a função _on_coin_lost. 
	# Este sinal é disparado quando a moeda é PERDIDA (tempo) pelo usuário
	node.connect("coin_lost", self, "_on_coin_lost")
	# adiciona a moeda a cena atual (filho do nó principal/raiz da cena)
	add_child(node)

# quando a moeda é capturada pelo usuário
func _on_coin_caught(coin):
	# incrementa 1 aos pontos atuais do usuário
	points += 1
	# a cada 5 pontos e enquanto fase_delay não for menor que 5
	if points % 5 == 0 and fase_delay > 5:
		# diminui a fase_delay em 2
		# a fase_delay é utilizada na função create_coin_at para determinar o tempo máximo
		# que uma moeda pode permanecer na tela. A cada 5 pontos do usuário, este tempo diminui.
		fase_delay -= 2
		# a linha abaixo é só para teste
		print("nova fase, delay: " + String(fase_delay))
	
	# atualiza o placar de pontos, na tela
	$CanvasLayer/Pontuacao.text = "Pontos: " + String(points)
	
	# cria uma nova moeda - COMENTADO
	# create_coin()
	
	# função (abaixo) que devolve o local utilizado pela moeda capturada a lista de locais_livres
	recover_local(coin)
	
# quando uma moeda é perdida pelo usuário (passou o tempo)
func _on_coin_lost(coin):
	# cria uma nova moeda
	create_coin()
	# função (abaixo) que devolve o local utilizado pela moeda capturada a lista de locais_livres
	recover_local(coin)
	
func recover_local(coin):
	# devolve o local utilizado pela moeda capturada a lista de locais_livres
	locais_livres.append(locais_usados[coin.name])
	# a linha abaixo é só para teste
	print("LIVRES:" + String(locais_livres.size()))

# função conectada com o sinal do Temporizador de nova moeda
func _on_TimerNewCoin_timeout():
	# cria uma nova moeda
	create_coin()

# prepara os tiles para que eles so colidam no seu lado de cima	
func set_one_way_for_tiles():
	# lista cada tile do TileMap e determina que eles só tenham colisão de um lado
	for id in $TileMap.tile_set.get_tiles_ids():
		$TileMap.tile_set.tile_set_shape_one_way(id, 0, true)
