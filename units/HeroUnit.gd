extends Node2D
class_name HeroUnit

@export var faction: String = "ally"   # ally, ally_spirit, enemy, enemy_spirit, neutral

var grid_position: Vector2i

const FehPresetsScript := preload("res://scripts/feh_presets.gd")
var FehPresets: Node = null

func _ready() -> void:
	print("HeroUnit pronto! Faction =", faction)

	var sprite := $Sprite

	# garantir shader e criar material único
	var base_material: ShaderMaterial = sprite.material
	if base_material == null:
		base_material = ShaderMaterial.new()
		base_material.shader = preload("res://shaders/outline_glow_pulse_feh.gdshader")

	sprite.material = base_material.duplicate()

	# criar instância dos presets
	if FehPresets == null:
		FehPresets = FehPresetsScript.new()

	_apply_faction_preset()



func _apply_faction_preset() -> void:
	var sprite := $Sprite
	if not sprite: 
		print("⚠ HeroUnit: Sprite não encontrado.")
		return

	var mat := sprite.material as ShaderMaterial
	if mat == null:
		print("⚠ HeroUnit: Material não é ShaderMaterial.")
		return

	match faction:
		"ally":
			FehPresets.apply_outline_ally(mat)
		"ally_spirit":
			FehPresets.apply_outline_ally_spirit(mat)
		"enemy":
			FehPresets.apply_outline_enemy(mat)
		"enemy_spirit":
			FehPresets.apply_outline_enemy_spirit(mat)
		"neutral":
			FehPresets.apply_outline_neutral(mat)
		_:
			print("⚠ Faction desconhecida:", faction)
			FehPresets.apply_outline_neutral(mat)


func set_grid_position(pos: Vector2i) -> void:
	grid_position = pos
	global_position = pos * 64
