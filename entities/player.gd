class_name Player
extends Entity

var balance = 0.0
var bet = 0.0
var totalDeposited = 0.0
var totalPaid = 0.0
var totalFined = 0.0
var fakeBonus = ""

func _init(name) -> void:
	super(name)

func deposit(value):
	bet = value
	totalDeposited += value
	fakeBonus = ""

func payout(multiplier):
	var prize = bet * multiplier
	balance += prize
	totalPaid += prize
	return prize

func fine():
	var value = maxf(balance, 0.0) + maxf(bet, 1.0)
	balance -= value
	totalFined += value
	return value

func houseProfit():
	return totalDeposited - totalPaid + totalFined

func newFakeBonus():
	var luck = ("%.4f" % randf_range(0.0001, 999.9999)).replace(".", ",")
	fakeBonus = "+%s%% de sorte e +%s de bônus" % [luck, Composer.money(randf_range(0.00001, 2.0), 5)]
	return fakeBonus

func resetWallet():
	balance = 0.0
	bet = 0.0
	totalDeposited = 0.0
	totalPaid = 0.0
	totalFined = 0.0
	fakeBonus = ""
