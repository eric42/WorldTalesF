extends Node2D
class_name BattleMap

const TILE_SIZE := 64
const GRID_W := 11
const GRID_H := 11

var units := [] #lista de heroUnit
var selected_unit: Node = null
var selectors := []
var highlights := []

@onready var Units := $Units
@onready var  HighlightsBlue := preload("res://ui/highlight_tile.tscn")
@onready var SelectorGold := preload("res://ui/selector_tile.tscn")
@onready var Grid := $Grid

var reachable_cells = []
#var highlight_scene = preload("res://battle/highlight_tile.tscn")

func _ready():
	print("BattleMap carregado")

func draw_grid():
	var drawer = Grid
	drawer.clear()
	
	for x in range(GRID_W):
		for y in range(GRID_H):
			var rect := Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			drawer.draw_rect(rect, Color(1,1,1,0.05), false)

func spawn_unit(packed_scene: PackedScene, grid_pos: Vector2i, faction: String):
	var u := packed_scene.instantiate() as Node2D
	Units.add_child(u)
	u.map = self_modulate
	u.faction = faction
	u.grid_pos = grid_pos
	u.position = grid_pos * TILE_SIZE
	units.append(u)

func show_movement_range(center: Vector2i, dist := 3):
	clear_highlights()
	
	for dx in range(-dist, dist + 1):
		for dy in range(-dist, dist + 1):
			var p := center + Vector2i(dx, dy)
			if abs(dx) + abs(dy) <= dist:
				if p.x >= 0 and p.x <= GRID_W and p.y >= 0 and p.y <= GRID_H:
					
					var h := HighlightsBlue.instantiate()
					Grid.add_child(h)
					h.position = p * TILE_SIZE
					highlights.append(h)

func show_selector(pos: Vector2i):
	clear_selector()
	var s := SelectorGold.instantiate()
	Grid.add_child(s)
	s.position = pos * TILE_SIZE
	selectors.append(s)

func clear_selector():
	for s in selectors:
		s.queue_free()
	selectors.clear()

func clear_highlights():
	for h in highlights:
		h.queue_free()
	highlights.clear()
