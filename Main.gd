extends Node2D

var Coin = preload("Coin.tscn")

var points = 0
var fase_delay = 20
var locais_livres

var id = 0
var locais_usados = {}

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	for id in $TileMap.tile_set.get_tiles_ids():
		$TileMap.tile_set.tile_set_shape_one_way(id, 0, true)
	
	# Insere os filhos de Locais como locais livres	
	locais_livres = $Locais.get_children()
	print("LIVRES:" + String(locais_livres.size()))
	
	create_coin()


func _on_coin_caught(coin):
	points += 1
	if points % 5 == 0 and fase_delay > 5:
		fase_delay -= 2
		print("nova fase, delay: " + String(fase_delay))
	$CanvasLayer/Pontuacao.text = "Pontos: " + String(points)
	create_coin()
	recover_local(coin)
	
func _on_coin_lost(coin):
	create_coin()
	recover_local(coin)
	
func recover_local(coin):
	# devolve o local aos livres
	# print("recover: " + coin.name + ", " + locais_usados[coin.name].name)
	locais_livres.append(locais_usados[coin.name])
	print("LIVRES:" + String(locais_livres.size()))
	
func create_coin():
	if locais_livres.size() > 0:
		# sorteia uma posição entre os locais livres
		var posicao_sorteada = rng.randi_range(0, locais_livres.size() - 1)
		# pega o item na posicao sorteada
		var local_sorteado = locais_livres[posicao_sorteada]
		# remove da lista de livres o local sorteado
		locais_livres.remove(posicao_sorteada)
		
		create_coin_at(local_sorteado)
		
		$TimerNewCoin.start(rng.randi_range(4,8))
	else:
		print("sem locais livres")
		
func create_coin_at(local):
	var node = Coin.instance() as Area2D
	
	id += 1
	node.name = "coin_" + String(id)
	# associa o novo nó ao local
	locais_usados[node.name] = local
	
	node.translate(local.position)
	node.init(rng.randi_range(8,fase_delay))
	node.connect("coin_caught", self, "_on_coin_caught")
	node.connect("coin_lost", self, "_on_coin_lost")
	add_child(node)

func _on_TimerNewCoin_timeout():
	create_coin()
