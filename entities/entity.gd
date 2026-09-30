class_name Entity

var id: String
var cards : Array

func _init(name) -> void:
	self.id = name
	self.cards = []

func getSumCards():
	return sumOf(cards)

static func sumOf(hand):
	var sum = 0
	var aces = 0
	for card : Card in hand:
		sum += card.getScore()
		if card.getValue() == 1:
			aces += 1
	while sum > 21 and aces > 0:
		sum -= 10
		aces -= 1
	return sum
	
func getCards():
	return cards
	
func getId():
	return self.id
	
func reset():
	cards = []
