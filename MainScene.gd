extends Node

func _ready():
	print("MainScene carregada!")

	$BattleMap.spawn_unit("res://units/HeroUnit.tscn", Vector2i(3,3), "ally")
	$BattleMap.spawn_unit("res://units/HeroUnit.tscn", Vector2i(7,7), "enemy")
