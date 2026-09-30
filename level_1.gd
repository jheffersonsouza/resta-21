extends Control

const gameScenePath = "res://levels/level_2.tscn"

const withdrawExcuses = [
	"Saque de {saldo} em análise. Prazo: de 3 a 5 anos úteis.",
	"Sistema instável. Que tal apostar enquanto espera?",
	"Para sacar, confirme sua identidade com um Pix de R$ 9,90.",
	"Para sacar {saldo}, cumpra antes o rollover de {rollover} em apostas.",
	"Seu saque foi aprovado! Brincadeira, tá em análise.",
	"Nosso gerente saiu pra almoçar. Volta em 2031.",
	"Saque disponível apenas em dias de eclipse solar.",
	"Detectamos atividade suspeita: você tentou sacar.",
	"Valor mínimo para saque: {saldo} + R$ 0,01.",
	"Seu banco recusou. Qual banco? Todos.",
	"Saque realizado com sucesso! Na conta da Betzinha.",
	"Para sacar, envie selfie segurando RG, CPF e um boleto pago.",
	"Saque indisponível para CPFs terminados em 0, 1, 2, 3, 4, 5, 6, 7, 8 ou 9.",
	"Tem certeza? A próxima rodada é a da virada.",
	"Processando... processando... processando... tente amanhã.",
	"Erro 404: saque não encontrado.",
	"Taxa de saque: {saldo}. Coincidência: é exatamente o seu saldo.",
	"Saque agendado para 30 de fevereiro.",
	"Seu Pix de saque foi enviado por pombo-correio. Previsão: nunca.",
	"Você está na fila de saque. Posição: 4.815.162.342.",
	"Saque liberado ao indicar 10 amigos. Amigos de verdade não contam.",
	"Seu dinheiro está rendendo... pra gente.",
	"O influenciador que te indicou também tá esperando o saque dele.",
	"Saque bloqueado por excesso de sorte. Espera, que sorte?",
	"Para sacar, primeiro deposite o dobro de {saldo}.",
]
const emptyExcuses = [
	"Saldo zerado. Mas depositar ainda dá, viu?",
	"Sacar o quê? O vento?",
	"Você tem R$ 0,00 pra sacar. E mesmo assim tá em análise.",
	"Saldo insuficiente. Que tal um Pixzinho?",
	"Nada pra sacar. A casa agradece a preferência.",
	"Seu saldo foi reinvestido no iate da Betzinha.",
	"Zero reais. Mas o bônus de sorte continua ativo, confia.",
	"Não dá pra sacar o que já é nosso.",
	"Saque de R$ 0,00 aprovado! Confira seu extrato: R$ 0,00.",
	"Deposite R$ 50,00 e ganhe o direito de tentar sacar.",
]
const debtExcuses = [
	"Você deve {divida} pra Betzinha. Primeiro paga, depois sonha em sacar.",
	"Saldo negativo não saca. Só deposita, viu?",
	"Sua multa por espiar rende juros de 37% ao minuto.",
	"Quem espia as cartas da casa não saca. Regra nova, criada agora.",
	"Pra quitar {divida}, deposite {divida}. Ou o dobro, pra garantir.",
]

@onready
var statsNode : Label = get_node("Margin/Columns/Left/Stats")
@onready
var bonusNode : Label = get_node("Margin/Columns/Left/Bonus")
@onready
var valueNode : SpinBox = get_node("Margin/Columns/Left/ValueRow/Value")
@onready
var generatePixButton : Button = get_node("Margin/Columns/Left/GeneratePix")
@onready
var messageNode : Label = get_node("Margin/Columns/Left/Message")
@onready
var pixPanel : Control = get_node("Margin/Columns/PixPanel")
@onready
var pixInfoNode : Label = get_node("Margin/Columns/PixPanel/PixInfo")
@onready
var paidButton : Button = get_node("Margin/Columns/PixPanel/Paid")

var player : Player = Game.player
var pixValue = 0.0
var excuseBag = []
var emptyBag = []
var debtBag = []

func _ready() -> void:
	var profit = player.houseProfit()
	var profitText = "A casa já lucrou %s com você" % Composer.money(profit)
	if profit < 0:
		profitText = "Você tá %s na frente... por enquanto" % Composer.money(-profit)
	var balanceNote = "(saque em análise)" if player.balance >= 0 else "(você deve pra Betzinha)"
	statsNode.text = "Saldo: %s %s\n%s" % [Composer.money(player.balance), balanceNote, profitText]
	bonusNode.visible = player.fakeBonus != ""
	bonusNode.text = "Bônus ativo na próxima rodada: %s" % player.fakeBonus

func _on_generate_pix_pressed() -> void:
	pixValue = valueNode.value
	pixInfoNode.text = "Pix de %s para Betzinha da UFC\nEscaneie o QR Code com a câmera do celular" % Composer.money(pixValue)
	pixPanel.visible = true

func _on_paid_pressed() -> void:
	if paidButton.disabled:
		return
	paidButton.disabled = true
	generatePixButton.disabled = true
	valueNode.editable = false
	messageNode.text = "Confirmando pagamento... confia."
	await get_tree().create_timer(1.0).timeout
	player.deposit(pixValue)
	get_tree().change_scene_to_file(gameScenePath)

func _on_withdraw_pressed() -> void:
	if player.balance < 0:
		messageNode.text = _nextPhrase(debtBag, debtExcuses).format({"divida": Composer.money(-player.balance)})
	elif player.balance == 0:
		messageNode.text = _nextPhrase(emptyBag, emptyExcuses)
	else:
		var values = {"saldo": Composer.money(player.balance), "rollover": Composer.money(player.balance * 37)}
		messageNode.text = _nextPhrase(excuseBag, withdrawExcuses).format(values)

func _nextPhrase(bag : Array, phrases : Array):
	if bag.is_empty():
		bag.append_array(phrases)
		bag.shuffle()
	return bag.pop_back()
