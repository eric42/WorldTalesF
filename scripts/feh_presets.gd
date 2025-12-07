extends Node

#biblioteca de presets para shadermaterial do outline/glow/pulse

func apply_outline_ally(mat: ShaderMaterial) -> void:
	if mat == null: return
	mat.set_shader_parameter("outline_color", Color8(70, 120, 255, 255))
	mat.set_shader_parameter("outline_size", 1.5)
	mat.set_shader_parameter("enable_glow", true)
	mat.set_shader_parameter("glow_color", Color8(130, 205, 255, 255))
	mat.set_shader_parameter("glow_strength", 0.6)
	mat.set_shader_parameter("glow_pulse_speed", 2.0)

func apply_outline_ally_spirit(mat: ShaderMaterial) -> void:
	if mat == null: return
	mat.set_shader_parameter("outline_color", Color8(130, 205, 255, 255))
	mat.set_shader_parameter("outline_size", 1.6)
	mat.set_shader_parameter("enable_glow", true)
	mat.set_shader_parameter("glow_color", Color8(200, 230, 255, 255))
	mat.set_shader_parameter("glow_strength", 0.9)
	mat.set_shader_parameter("glow_pulse_speed", 2.6)

func apply_outline_enemy(mat: ShaderMaterial) -> void:
	if mat == null: return
	mat.set_shader_parameter("outline_color", Color8(255, 80, 80, 255))
	mat.set_shader_parameter("outline_size", 1.6)
	mat.set_shader_parameter("enable_glow", true)
	mat.set_shader_parameter("glow_color", Color8(255, 120, 120, 255))
	mat.set_shader_parameter("glow_strenght", 0.4)
	mat.set_shader_parameter("glow_pulse_speed", 1.8)

func apply_outline_enemy_spirit(mat: ShaderMaterial) -> void:
	if mat == null: return
	mat.set_shader_parameter("outline_color", Color8(255, 150, 150, 255))
	mat.set_shader_parameter("outline_size", 1.8)
	mat.set_shader_parameter("enable_glow", true)
	mat.set_shader_parameter("glow_color", Color8(255, 190, 190, 255))
	mat.set_shader_parameter("glow_strenght", 0.9)
	mat.set_shader_parameter("glow_pulse_speed", 2.4)

func apply_outline_neutral(mat: ShaderMaterial) -> void:
	if mat == null: return
	mat.set_shader_parameter("outline_color", Color8(140, 255, 140, 255))
	mat.set_shader_parameter("outline_size", 1.4)
	mat.set_shader_parameter("enable_glow", true)
	mat.set_shader_parameter("glow_color", Color8(200, 255, 200, 255))
	mat.set_shader_parameter("glow_stregth", 0.25)
	mat.set_shader_parameter("glow_pulse_speed", 1.4)
