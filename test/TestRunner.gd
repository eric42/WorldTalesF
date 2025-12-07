extends Node2D

func _ready():
    var bm_scene = load("res://battle/BattleMap.tscn")
    var bm = bm_scene.instantiate()
    add_child(bm)
    # spawn sample units
    bm.spawn_unit("res://units/HeroUnit.tscn", Vector2i(1,2), "ally")
    bm.spawn_unit("res://units/HeroUnit.tscn", Vector2i(3,2), "enemy")
