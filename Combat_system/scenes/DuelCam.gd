extends Camera2D
class_name DuelCamera

#configuracoes
@export var pan_speed := 6.0 #velocidade de pan(lerp)
@export var zoom_speed := 6.0 #velociade do zoom(lerp)
@export var impact_zoom := 1.4 #zoom aplicado no impacto critico
@export var focus_padding := 120 #espaco extra ao focar 2 personagens
@export var shake_decay := 0.85 #quanto do shake é reduzido a cada frame

#---estado interno---
var default_pos := Vector2.ZERO
var default_zoom := Vector2.ONE
var _shake_intensity := 0.0
var _shake_time := 0.0

func _ready():
	default_pos = global_position
	default_zoom = zoom

#salva posicao e zoom iniciais
func save_default():
	default_pos = global_position
	default_zoom = zoom

#restaura posicao e zoom iniciais
func reset_focus():
	var tw = create_tween()
	tw.tween_property(self, "global_position", default_pos, 0.5).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "zoom", default_zoom, 0.5).set_trans(Tween.TRANS_SINE)
	await tw.finished

#focar os dois personagens
func focus_on_pair(a: Node2D, b: Node2D) -> void:
	var mid = (a.global_position + b.global_position) * 0.5
	var distance = a.global_position.distance_to(b.global_position)
	var ideal_zoom = clamp(600.0 / (distance + focus_padding), 0.7, 1.2)      
	
	var tw = create_tween()
	tw.tween_property(self, "global_position", mid, 0.45).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "zoom", Vector2(ideal_zoom, ideal_zoom), 0.45).set_trans(Tween.TRANS_SINE)
	await tw.finished

#pan para o atacante
func pan_to_attacker(a: Node2D):
	var target = a.global_position + Vector2(-50, -30)
	var tw = create_tween()
	tw.tween_property(self, "global_position", target, 0.45).set_trans(Tween.TRANS_SINE)
	await tw.finished

#pan para o defensor
func pan_to_defender(d: Node2D):
	var target = d.global_position + Vector2(-50, -30)
	var tw = create_tween()
	tw.tween_property(self, "global_position", target, 0.45).set_trans(Tween.TRANS_SINE)
	await  tw.finished

#zoom cinematografico pequeno(critico)
func zoom_on_impact(mult := 1.25):
	var base_zoom = zoom
	var target_zoom = base_zoom * mult
	
	var tw = create_tween()
	tw.tween_property(self, "zoom", target_zoom, 0.12).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "zoom", base_zoom, 0.25).set_delay(0.1).set_trans(Tween.TRANS_SINE)
	await tw.finished

#shake de camera(impacto)
func shake(intensity := 20.0, duration := 0.25):
	_shake_intensity = intensity
	_shake_time = duration
	
	while _shake_time > 0:
		_shake_time -= get_process_delta_time()
		_shake_intensity *= shake_decay
		await get_tree().process_frame
	
	#reset final
	position = position

#update do shake
func _process(delta):
	if _shake_time > 0:
		offset = Vector2(randf_range(-_shake_intensity, _shake_intensity),
		randf_range(-_shake_intensity, _shake_intensity))
	else:
		offset = Vector2.ZERO
