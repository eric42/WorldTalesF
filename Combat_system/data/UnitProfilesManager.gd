extends Node
class_name UnitProfilesManager
var data = preload("res://combat_system/data/UnitProfiles.gd").new()

func spawn_unit(unit_type:String, custom_name:String="", is_enemy:bool=false) -> Node2D:
	var scene = preload("res://combat_system/units/Unit.tscn")
	var u = scene.instantiate()
	var profile = data.profiles.get(unit_type)
	if profile:
		u.unit_type = unit_type
		u.name = custom_name if custom_name != "" else profile.name
		u.hp = profile.hp
		u.max_hp = profile.hp
		u.attack = profile.attack
		u.defense = profile.defense
		u.speed = profile.speed
		u.move_type = profile.move_type
		u.weapon_type = profile.weapon_type
		u.protrait = load(profile.portrait)
		u.load_sprite(profile.sprite)
		u.is_enemy = is_enemy
	return u
		
