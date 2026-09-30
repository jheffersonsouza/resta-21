extends Node2D

const betScenePath = "res://levels/level_1.tscn"
const Player = preload("res://entities/player.gd")
const Composer = preload("res://entities/composer.gd")
const Card = preload("res://entities/card.gd")

@onready
var playerBoardNode = get_node("PlayerTextBoard")
@onready
var houseBoardNode = get_node("HouseTextBoard")
@onready
var drawnCardNode= get_node("DrawnCardText")
@onready
var announcer = get_node("TextAnnouncer")

@onready
var drawButton : Button = get_node("Draw")
@onready
var skipButton : Button = get_node("Skip")
@onready
var proceedButton : Button = get_node("Proceed")
@onready
var restartButton : Button = get_node("Restart")
@onready
var betResultNode : Label = get_node("BetResult")
@onready
var peekButton : Button = get_node("Peek")

var game : Game
var composer : Composer
var player : Player = Game.player
var fineValue = 0.0

func _ready() -> void:
	composer = Composer.new(playerBoardNode, houseBoardNode, drawnCardNode, announcer)
	game = Game.new(composer, get_tree())
	game.ended.connect(_on_game_ended)
	await game.start()
	#for c in generateCards():
		#print("Suite: %s - Valor: %d - Score %d" % [c.getSuit(), c.getValue(), c.getScore()])
		#print(c.displayText())

func _process(delta: float) -> void:
	composer.display_info(player, "Aposta: " + Composer.money(player.bet))
	composer.display_info(game.house, "Lucro: " + Composer.money(player.houseProfit()))
	drawButton.disabled = not game.canPlayerAct()
	skipButton.disabled = not game.canPlayerAct()
	proceedButton.disabled = game.gameState != Game.GameState.ENDED
	restartButton.disabled = game.isBusy
	peekButton.disabled = not composer.hideHouse

func _on_draw_pressed() -> void:
	if game.canPlayerAct():
		await game.playerDraw()
	else:
		print("nao eh a vez do jogador")

func _on_skip_pressed() -> void:
	if game.canPlayerAct():
		await game.playerSkip()
	else:
		print("nao eh")

func _on_proceed_pressed() -> void:
	if (game.gameState == Game.GameState.ENDED):
		get_tree().change_scene_to_file(betScenePath)

func _on_restart_pressed() -> void:
	if not game.isBusy:
		player.resetWallet()
		get_tree().change_scene_to_file(betScenePath)

func _on_peek_pressed() -> void:
	if not composer.hideHouse:
		return
	composer.hideHouse = false
	fineValue = player.fine()
	betResultNode.text = "Tentou roubar espiando as cartas da casa? Multa de %s! Seu saldo: %s kkkk" % [Composer.money(fineValue), Composer.money(player.balance)]

func _on_game_ended(winner) -> void:
	var text
	if winner == player:
		text = "Ganhou %s! Foi pro saldo (saque em análise)." % Composer.money(player.payout(2))
	elif winner == game.house:
		player.payout(0)
		text = "Perdeu %s. Não desanima! Na próxima rodada você terá %s" % [Composer.money(player.bet), player.newFakeBonus()]
	else:
		text = "Empate: %s voltou pro saldo." % Composer.money(player.payout(1))
	if fineValue > 0:
		text += "\nMulta por espiar a casa: %s" % Composer.money(fineValue)
	betResultNode.text = text
