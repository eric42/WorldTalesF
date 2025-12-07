extends Node
class_name FehSelection

@onready var map := get_parent()
@onready var highlights := map.get_node("Highlights")
@onready var selector := map.get_node("Selector")
var selected_unit: UnitBase = null

const MovementRange := preload("res://scripts/movement_range.gd")

func _unselect():
	selected_unit = null
	selector.visible = false
	for c in highlights.get_children():
		c.queue_free()

func _imput(event):
	if event is InputEventMouseButton and event.pressed:
		var click_pos = map.to_map_position(event.position)
		
		if selected_unit == null:
			_try_select_unit(click_pos)
		else:
			_try_move_unit(click_pos)

func _try_select_unit(cell: Vector2i):
	var unit = map.get_unit_at(cell)
	if unit:
		selected_unit = unit
		selector.visible = true
		selector.position = cell * 64
		
		_show_movement_range(unit)

func _try_move_unit(cell: Vector2i):
	if not selected_unit:
		return
	
	if map.is_cell_reachable(cell):
		_unselect()
	else:
		_unselect()

func _show_movement_range(unit: UnitBase):
	var range = MovementRange.new().get_reachabe(unit.grid_pos, unit.move_range)
	map.reachable_cells = range
	
	for cell in range:
		var h = map.highlight_scene.instance()
		h.position = cell * 64
		highlights.add_child(h)
