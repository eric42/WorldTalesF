extends Resource
class_name UnitProfiles

var profiles := {
	"soldier": {"name": "Soldado", "hp":24, "attack":8, "defense":5, "speed":5, "portrait":"res://assets/portraits/soldier.png", "sprite":"res://assets/sprites/soldier_idle.png", "move_type":"infantry","weapon_type":"sword", "promotion":null},
	"archer": {"name": "Arqueiro", "hp":18, "attack":10, "defense":3, "speed":7, "portrait":"res://assets/portraits/archer.png","sprite":"res://assets/sprites/archer_idle.png","move_type":"infantry","weapon_type":"bow","promotion":"sniper"}
}
