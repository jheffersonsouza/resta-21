class_name Composer

const DEBUG = true

var playerBoardNode : Node
var houseBoardNode : Node
var drawnCardNode : Node
var announcerNode : Node
var hideHouse = true

func _init(playerBoardNode, houseBoardNode, drawnCardNode, announcer):
	self.playerBoardNode = playerBoardNode
	self.houseBoardNode = houseBoardNode
	self.drawnCardNode = drawnCardNode
	self.announcerNode = announcer

func renderDrawedCard(card : Card, entity : Entity):
	var score = "1/11" if card.getValue() == 1 else str(card.getScore())
	if _isHidden(entity):
		drawnCardNode.text = "Carta puxada \n ?? (carta da casa)"
	else:
		drawnCardNode.text = "Carta puxada \n %s (+%s)"  % [card.displayText(), score]
	if DEBUG:
		print("CARD DRAWN:%s (+%s)" % [card.displayText(), score])

func announce(str):
	self.announcerNode.text = str
	if DEBUG:
		print("ANNOUNCED:"+ str)
	
func display_info(entity : Entity, info : String):
	var board : Node = self.playerBoardNode if entity is Player else self.houseBoardNode
	board.text = """%s
	%s
	Soma das cartas: %s
	Cartas Raw: %s
""" % [entity.getId(), info, sumText(entity), _cardsToString(entity)]

func sumText(entity : Entity):
	return "??" if _isHidden(entity) else str(entity.getSumCards())

static func money(value, decimals = 2):
	var parts = (("%." + str(decimals) + "f") % absf(value)).split(".")
	var integer = parts[0]
	var grouped = ""
	while integer.length() > 3:
		grouped = "." + integer.right(3) + grouped
		integer = integer.left(-3)
	return "%sR$ %s%s,%s" % ["-" if value < 0 else "", integer, grouped, parts[1]]

func _cardsToString(entity : Entity):
	var str = "\n"
	for i : Card in entity.getCards():
		str += ("[carta virada]" if _isHidden(entity) else i.displayText()) + "\n"
	return str

func _isHidden(entity : Entity):
	return hideHouse and not entity is Player
