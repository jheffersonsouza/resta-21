class_name Card


enum Suit {Spades = 0, Hearts = 1, Diamonds = 2, Clubs = 3}

var _suit : Suit 
var _value : int
var _score : int

func _init(suit, value, score):
	self._suit = suit
	self._value = value
	self._score = score
	
func getSuit():
	return self._suit

func getValue():
	return self._value
	
func getScore():
	return self._score

func displayText():
	var dictSuite = {0: "Espadas", 1: "Copas", 2: "Ouros", 3: "Paus"}
	var dictCards = {1: "Ás", 11: "Valette", 12: "Dama", 13: "Reis"}
	
	var _displayText = ""
	# Prefixo
	if (_value in dictCards.keys()):
		_displayText += dictCards[_value]
	else:
		_displayText += str(_value)
	# Naipe
	_displayText += " de %s" % dictSuite[_suit]
	
	return _displayText
