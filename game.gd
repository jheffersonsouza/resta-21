#logica de gerico, entidade nao deve ter cartas ja que é um state temporario
# multiplos jogadores?
# dar cooldown pras ações instantaneas
# jogador puxa quantas quiser vs puxa so uma por turno
# se eu cortar o enum eu consigo em algo mais optimo e coerente para usar como id pras cartas (talvez a ideia do titulo como id)
class_name Game

signal ended(winner)

enum GameState {STARTED, ENDED}

const maxValue = 21
const drawDelaySeconds = 1

static var player : Player = Player.new("Jogador")
var house : Entity = Entity.new("Casa")

# FIXME: Nao ta virando const por algum motivo
var cards = _generateCards()
var avaliableCards = []

var gameState = GameState.STARTED
var isPlayerTurn = true
var isBusy = false
var skipCount = 0

var cheatChance = 0.75

var composer : Composer
var tree : SceneTree

func _init(composer, tree):
	self.tree = tree
	self.composer = composer

func start():
	self.avaliableCards = cards.duplicate()
	self.avaliableCards.shuffle()
	self.skipCount = 0
	player.reset()
	house.reset()
	gameState = GameState.STARTED
	isPlayerTurn = true
	isBusy = false
	composer.hideHouse = true
	await draw(player, 2, true)
	await draw(house, 2, true)

func end(winner : Entity):
	if winner == house:
		composer.hideHouse = false
	if (winner):
		composer.announce("%s ganhou com %s" % [winner.getId(), composer.sumText(winner)])
	else:
		composer.announce("Empate")
	gameState = GameState.ENDED
	ended.emit(winner)

func canPlayerAct():
	return gameState == GameState.STARTED and isPlayerTurn and not isBusy

func playerDraw():
	isBusy = true
	await draw(player)
	await tick(player)
	isBusy = false

func playerSkip():
	isBusy = true
	await skip(player)
	isBusy = false

func draw(entity: Entity, amount : int = 1, instant = false):
	skipCount = 0
	for i in range(0, amount):
		if entity == house and not instant:
			_rigDeck()
		var card = avaliableCards.pop_front()
		composer.renderDrawedCard(card, entity)
		composer.announce(entity.getId() + " puxou uma carta!")
		if not instant:
			await _wait(drawDelaySeconds)
		entity.cards.append(card)


func skip(entity : Entity):
	composer.announce(entity.getId() + " pulou a vez!")
	self.skipCount += 1
	await tick(entity)

func tick(entity : Entity):
	await _wait(1)
	if entity.getSumCards() > 21:
		#End game pra entidade
		var winner = _getEnemy(entity)
		end(winner)
		return
	if skipCount >= 2:
		# Comparação de placar e o carai a 4
		if (player.getSumCards() > house.getSumCards()):
			end(player)
		elif (player.getSumCards() < house.getSumCards()):
			end(house)
		else:
			end(null)
		return

	isPlayerTurn = !isPlayerTurn
	if not isPlayerTurn:
		await callAI()

func callAI():
	# Primeira ideia - puxa se tiver menos que o jogador
	if house.getSumCards() == 21:
		await skip(house)
		return
	if (house.getSumCards() <= player.getSumCards()):
		await draw(house)
		await tick(house)
		return
	await skip(house)

func _rigDeck():
	if randf() >= cheatChance:
		return
	var best = 0
	for i in range(1, avaliableCards.size()):
		if _houseScore(avaliableCards[i]) > _houseScore(avaliableCards[best]):
			best = i
	if best != 0:
		avaliableCards.push_front(avaliableCards.pop_at(best))

func _houseScore(card : Card):
	var total = Entity.sumOf(house.cards + [card])
	return total if total <= 21 else -total

#gambiarra pra pegar a entidade contraria, so deus na causa kkkk
func _getEnemy(entity):
	if (entity == player):
		return house
	else:
		return player


func _wait(seconds: float):
	await tree.create_timer(seconds).timeout

func _generateCards():
	var cards := []
	for i in range(0, 13):
		var score = i + 1
		if score > 10:
			score = 10
		if score == 1:
			score = 11
		cards.append(Card.new(Card.Suit.Spades, i + 1, score))
		cards.append(Card.new(Card.Suit.Hearts, i + 1, score))
		cards.append(Card.new(Card.Suit.Diamonds, i + 1, score))
		cards.append(Card.new(Card.Suit.Clubs, i + 1, score))
	return cards
