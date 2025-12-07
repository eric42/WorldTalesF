extends Node2D
class_name UnitBase

@export var faction: String = "ally"
var grid_pos: Vector2i
var move_range := 3

func set_grid_position(pos: Vector2i):
	grid_pos = pos
	global_position = pos * 64
