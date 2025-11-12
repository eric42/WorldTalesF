extends Node2D
class_name Unit

var unit_name: String = "Unit"
var unit_type: String = "soldier"
var hp: int = 20
var max_hp: int = 20
var attack: int = 8
var defense: int = 3
var speed: int = 5
var level: int = 1
var xp: int = 0
var move_type: String = "infantry"
var weapon_type: String = "sword"
var portrait: Texture2D
var is_enemy: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var hpbar: ProgressBar = $HPBar
@onready var sfx: AudioStreamPlayer = $SFX

func load_sprite(path:String):
	sprite.texture = load(path)
	
func take_damage(d:int):
	hp = clamp(hp - d, 0, max_hp)
	hpbar.value = hp
	
func gain_xp(amount:int):
	xp += amount
	if xp >= 100:
		xp -= 100
		var stat_changes = level_up()
		return stat_changes
	return{}
	
func level_up() -> Dictionary:
	level += 1
	var stat_changes = {"hp": randi_range(1,3), "attack": randi_range(0,2), "defense": randi_range(0,2), "speed": randi_range(0,1)}
	max_hp += stat_changes["hp"]
	hp = max_hp
	attack += stat_changes["attack"]
	defense += stat_changes["defense"]
	speed += stat_changes["speed"]
	return stat_changes
