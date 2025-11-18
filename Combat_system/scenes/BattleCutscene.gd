extends CanvasLayer
class_name BattleCutscene

signal cutscene_finished

@onready var  attacker_sprite: Sprite2D = $Characters/Attacker/AttackerSprite
@onready var defender_sprite: Sprite2D = $Characters/Defender/DefenderSprite
@onready var attacker_voice: AudioStreamPlayer = $Characters/Attacker/Voice if has_node("Characters/Attacker/Voice") else null
@onready var defender_voice: AudioStreamPlayer = $Characters/Defender/Voice if has_node("Characters/Defender/Voice") else null
@onready var attacker_glow: Light2D = $Characters/Attacker/VoiceGLow if has_node("Characters/Attacker/VoiceGLow") else null
@onready var defender_glow: Light2D = $Characters/Defender/VoiceGlow if has_node("Characters/Defender/VoiceGlow") else null

@onready var dialogue_label: Label = $Dialogue
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var duel_cam: Camera2D = $DuelCam
@onready var final_flash: ColorRect = $FinalFlash
@onready var final_text: Label = $FinalText
@onready var cutscene_music: AudioStreamPlayer = $CutsceneMusic
@onready var sfx_player: AudioStreamPlayer = $SFX
@onready var zoom_overlay: ColorRect = $ZoomOverlay if has_node("ZoomOverlay") else null

# Dialogue profiles resource (strings or dicts with {text, voice})
var dialogue_profiles := preload("res://Combat_system/data/DialogueProfiles.gd")

# Dados atuais da cutscene (unidades)
var attacker_unit = null
var defender_unit = null

# Parâmetros ajustáveis
var CRIT_SLOWMO := 0.28
var CRIT_SLOWMO_DURATION := 0.9
var FINAL_SLOWMO := 0.22
var FINAL_SLOWMO_DURATION := 0.9
var FLASH_MAX_ALPHA := 1.0
var FLASH_IN_TIME := 0.08
var FLASH_OUT_TIME := 0.35
var ZOOM_IMPACT := 1.8
var ZOOM_IN_TIME := 0.14
var ZOOM_OUT_TIME := 0.45
var SHAKE_INTENSITY := 22
var SHAKE_DURATION := 0.45
var BGM_FADE_DB := -18.0
var BGM_FADE_OUT_TIME := 0.6
var BGM_FADE_IN_TIME := 1.0
var BGM_PITCH_SLOW := 0.7

# estado interno
var _blur_following := false
var _blur_target_node : Node2D = null
var _zoom_mat: ShaderMaterial = null

func _ready():
	#prepara overlay shader se existir
	if zoom_overlay:
		_zoom_mat = zoom_overlay.material as ShaderMaterial
		#inicializa parametros
		_zoom_mat.set_shader_parameter("blur_strength", 0.0)
		_zoom_mat.set_shader_parameter("center", Vector2(0.5, 0.5))
	
	#garante texto invisivel
	if final_text:
		final_text.visible = false
	
	#final flash invisivel
	if final_flash:
		final_flash.modulate.a = 0.0
	

#API publica
# setup(attacker: Unit, defender: Unit) -> configura sprites, nomes, etc
func setup(attacker: Node, defender: Node) -> void:
	attacker_unit = attacker
	defender_unit = defender
	
	# define sprites/portraits se a Unit expor 'portrait' ou sprite_path
	if attacker_unit and attacker.has_method("load_sprite") and attacker_unit.has_variable("sprite_path"):
		attacker_unit.load_sprite() #geralmente define seu próprio Sprite2D
		# também atualizamos o sprite usado na cutscene (se quiser usar portrait)
	
	if defender_unit and defender_unit.has_method("load_sprite") and defender_unit.has_variable("sprite_path"):
		defender_unit.load_sprite()
	
	# preferir portrait para cutscene sprites se existir
	if attacker_unit and attacker_unit.has_variable("portrait") and attacker_unit.portrait:
		attacker_sprite.texture = attacker_unit.portrait
	elif attacker_unit and attacker_unit.has_variable("sprite_path"):
		attacker_sprite.texture = load(attacker_unit.sprite_path) if attacker_unit.sprite_path != "" else attacker_sprite.texture
	
	if defender_unit and defender_unit.has_variable("portrait"):
		defender_sprite.texture = defender_unit.portrait
	elif defender_unit and attacker_unit.has_variable("sprite_path"):
		defender_sprite.texture = load(defender_unit.sprite_path) if defender_unit.sprite_path != "" else defender_sprite.texture
	
	#reset glows
	if attacker_glow:
		attacker_glow.energy = 0.0
	
	if defender_glow:
		defender_glow.energy = 0.0
	

#inicia a cutscene (async)
func start_cutscene() -> void:
	
	#toca musica se nao estar tocando
	if cutscene_music and cutscene_music.stream:
		cutscene_music.volume_db = 0
		cutscene_music.play()
	
	#posiciona a camera para mostrar os dois(se tiver metodo)
	if duel_cam and duel_cam.has_method("save_default"):
		duel_cam.focus_on_pair(attacker_sprite, defender_sprite)
	
	#aguarda a camera posicionar(tweak)
	await get_tree().create_timer(0.45).timeout
	
	#intro line
	await  _play_line(attacker_unit, "intro")
	await  _play_line(defender_unit, "intro")
	
	#ataque / sequencia principal
	await _play_attack_sequence()
	
	#finalizacao
	cutscene_music.stop() if cutscene_music else null
	emit_signal("cutscene_finished")
	
	return
	

#-----funçoes internas de fluxo-----
#reproduz a sequencia de ataque (dialogue -> effects -> decide final blow
func _play_attack_sequence() -> void:
	
	#pre-ataque: animacao intro se existir
	if anim_player.has_animation("intro"):
		anim_player.play("intro")
		await  anim_player.animation_finished
	
	#pan para atacante
	if duel_cam and duel_cam.has_method("pan_to_attacker") and attacker_sprite:
		await  duel_cam.pan_to_attacker(attacker_sprite)
	
	#escolher se é critico usado o resultado real (se attacker_untit forneceu info),
	#mas por seguraca aceitamos um campo temporario em attacker_unit.last_attack_result
	var is_crit := false
	if attacker_unit and attacker_unit.has_variable("last_attack_result"):
		if typeof(attacker_unit.last_attack_result) == TYPE_DICTIONARY:
			is_crit = bool(attacker_unit.last_attack_result.get("critical", false))
		else:
			#fallback RNG (20%)
			is_crit = randf() < 0.20
	
	#play attack line
	if is_crit:
		await  _play_line(attacker_unit, "critical")
		#efeitos criticos: slow motion + sound + camera zoom
		await  _play_critical_effects(attacker_sprite)
	else:
		await  _play_line(attacker_unit, "attack")
	
	#tocar som de ataque
	if sfx_player and sfx_player.stream:
		sfx_player.play()
	
	#espera animacao de ataque
	if anim_player.has_animation("attack_sequence"):
		anim_player.play("attack_sequence")
		await anim_player.animation_finished
	else:
		await  get_tree().create_timer(0.7).timeout
	
	#depois do impacto: verificar hp do defensor(se exposto)
	var defender_hp: int = defender_unit.hp if defender_unit and defender_unit.has_variable("hp") else -1
	if defender_hp <= 0:
		#golpe letal -> final blow cinematic
		await  play_final_blow(attacker_sprite, defender_sprite, "FINAL STRIKE!")
		#espera possivel animacao de morte do defender
		if defender_unit and defender_unit.has_method("play_death_animation"):
			defender_unit.play_death_animation()
			if defender_unit.has_node("AnimationPlayer"):
				await  defender_unit.get_node("AnimationPlayer").animation_finished
			else:
				#se defender com hp baixo - fala low_hp
				if defender_unit and defender_unit.has_variable("hp") and defender_unit.has_variable("max_hp"):
					if defender_unit.hp < defender_unit.max_hp * 0.3:
						await _play_line(defender_unit, "low_hp")
			
			#small cooldown
			await  get_tree().create_timer(0.25).timeout

#toca um "line" (intro/attack/critical/low_hp/victory/death)
#aceita strings ou dictionaries {text, voice}
func _play_line(unit: Node, context: String) -> void:
	if not unit:
		return
	
	var utype : Node = unit.unit_type if unit.has_variable("unit_type") else str(unit.name).to_lower()
	var entries = dialogue_profiles.profiles.get(utype, {}).get(context, [])
	if typeof(entries) == TYPE_NIL or entries.empty():
		return
	
	var line_data = entries[randi() % entries.size()]
	
	var text = ""
	var voice_path = ""
	if typeof(line_data) == TYPE_DICTIONARY:
		text = line_data.get("text", "")
		voice_path = line_data.get("voice", "")
	else:
		text = str(line_data)
	
	#mostra texto
	if dialogue_label:
		dialogue_label.text = "%s: %s" % [ (unit.name if unit.has_variable("name") else utype.capitalize()), text]
	
	#tocar voz (preferir voice_path, caso contrario tentar voice set in  unit
	var voice_player: AudioStreamPlayer = null
	
	if unit == attacker_unit:
		if attacker_voice:
			voice_player = attacker_voice
	else:
		if defender_voice:
			voice_player = defender_voice	
	
	if voice_path != "" and voice_player:
		voice_player.stream = load(voice_path)
		voice_player.play()
	elif  voice_player and unit.has_varible("voice_set") and typeof(unit.voice_set) == TYPE_STRING:
		#tentar tocar um arquivo aleatorio do voice_set
		#nao faz leitura de pasta - requer paths explicitos nas profiles para  para simplicidade
		pass
	
	#animacao facial e glow
	var glow: Light2D = null
	
	if unit == attacker_unit:
		glow = attacker_glow
	else:
		glow = defender_glow
	
	if glow == null:
		return  # ignora efeito se não existir glow
	
	var face_anim_player = null
	if unit and unit.has_node("AnimationPlayer"):
		face_anim_player = unit.get_node("AnimationPlayer")
	if face_anim_player and face_anim_player.has_animation("talk"):
		face_anim_player.play("talk")

	if glow:
		# brilho curto
		var tw = create_tween()
		tw.tween_property(glow, "energy", 2.0, 0.18)
		tw.tween_property(glow, "energy", 0.0, 0.45).set_delay(0.9)
	
	# aguarda duração base da fala (se existir voz, esperar fim; senão, timer)
	if voice_player and voice_player.playing:
		# esperar enquanto estiver tocando (sem travar se slowmo ocorrer)
		while voice_player.playing:
			await get_tree().process_frame
	else:
		await get_tree().create_timer(1.2).timeout

	# para animação facial
	if face_anim_player and face_anim_player.has_animation("talk"):
		face_anim_player.stop()
	

#----efeitos criticos/final----
#efeito critico: slow motion curto + camera zoom + som
func _play_critical_effects(focus_node: Node2D) -> void:
	#reduz tempo e faz musica respirar
	var prev_time = Engine.time_scale
	Engine.time_scale = CRIT_SLOWMO
	if cutscene_music:
		var t = create_tween()
		t.tween_property(cutscene_music, "volume_db", BGM_FADE_DB, 0.25)
	
	#rapida espera dramatica
	await  get_tree().create_timer(CRIT_SLOWMO_DURATION * 0.35).timeout
	
	#zoom no impacto
	if duel_cam and duel_cam.has_method("zoom_on_impact"):
		await  duel_cam.zoom_on_impact(1.25)
	
	#restaura tempo/musica
	Engine.time_scale = prev_time
	if cutscene_music:
		var t2 = create_tween()
		t2.tween_property(cutscene_music, "volume_db", 0.0, 0.8)
	await  get_tree().create_timer(0.05).timeout

#final blow cinematic (golpe letal), centraliza camera, slowmo forte, flash branco, zoom blur e texto
func play_final_blow(attacker_node: Node2D, defender_node: Node2D, text := "FINAL STRIKE!") -> void:
	#garante overlay visivel por cima (canaslayer já esta acima)
	visible = true
	
	#prepara camera
	if duel_cam and duel_cam.has_method("save_default"):
		duel_cam.save_default()
	if duel_cam and duel_cam.has_method("focus_on_pair"):
		duel_cam.focus_on_pair(attacker_node, defender_node)
	
	#breve espera para enquadramento
	await  get_tree().create_timer(0.45).timeout
	
	# fade BGM + pitch slow
	if cutscene_music:
		var fade = create_tween()
		fade.tween_property(cutscene_music, "volume_db", BGM_FADE_DB, BGM_FADE_OUT_TIME)
		cutscene_music.pitch_scale = BGM_PITCH_SLOW
	
	#slow motion
	var prev_time := Engine.time_scale
	Engine.time_scale = FINAL_SLOWMO
	
	#aumentar zoom-blur (segue atacante)
	if _zoom_mat and _blur_target_node:
		#obs: centre atualizado por _process()
		_zoom_mat.set_shader_parameter("blur_strengh", 0.0)
	
	if zoom_overlay:
		#centraliza shader no atacante(converter posicao)
		_set_zoom_center_to_node(attacker_node)
		#tween blur in
		var twb = create_tween()
		twb.tween_property(_zoom_mat, "shader_parameter/blur_strength", 0.85, 0.35).set_trans(Tween.TRANS_SINE)
	#delay dramatico
	await  get_tree().create_timer(0.35).timeout
	
	#zoom in camera e flash + impact sound
	if duel_cam and duel_cam.has_method("zoom_on_impact"):
		#simultaneo: zoom + flash
		var tz = create_tween()
		tz.tween_property(duel_cam, "zoom", Vector2(ZOOM_IMPACT, ZOOM_IMPACT), ZOOM_IN_TIME).set_trans(Tween.TRANS_BACK)
	
	#flash in
	if final_flash:
		final_flash.modulate.a = 0.0
		var tf = create_tween()
		tf.tween_property(final_flash, "modulate:a", FLASH_MAX_ALPHA, FLASH_IN_TIME)
	
	#play impact sound
	if sfx_player and sfx_player.stream:
		sfx_player.play()
	
	#show text
	if final_text:
		final_text.visible = true
		final_text.modulate.a = 0.0
		final_text.scale = Vector2(1, 1)
		var tt = create_tween()
		tt.tween_property(final_text, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_SINE)
		tt.tween_property(final_text, "scale", Vector2(1.3, 1.3), 0.12).set_trans(Tween.TRANS_BACK)
		
		#camera shake(if camera has shake method, else do local shake)
		if duel_cam and duel_cam.has_method("shake"):
			await duel_cam.shake(SHAKE_INTENSITY, SHAKE_DURATION)
		else:
			#fallback: small global viewport shake
			await _local_shake(SHAKE_INTENSITY, SHAKE_DURATION)
		
		#revert blur
		if _zoom_mat:
			var tr = create_tween()
			tr.tween_property(_zoom_mat, "shader_parameter/blur_strength", 0.0, 0.6).set_trans(Tween.TRANS_SINE)
		
		#fade flash and text out
		if final_flash:
			var fo = create_tween()
			fo.tween_property(final_flash, "modulate:a", 0.0, FLASH_OUT_TIME)
		if final_text:
			var ft = create_tween()
			ft.tween_property(final_text, "modulate:a", 0.0, 0.35)
			
		#restore camera zoom to base(if duel_cam has reset)
		if duel_cam and duel_cam.has_method("reset_focus"):
			duel_cam.reset_focus()
		
		#restore time and music
		Engine.time_scale = prev_time
		if  cutscene_music:
			var fin = create_tween()
			fin.tween_property(cutscene_music, "volume_db", 0.0, BGM_FADE_IN_TIME)
			cutscene_music.pitch_scale = 1.0
		
		#small final wait
		await get_tree().create_timer(0.25).timeout
	
	#cleanup visuals
	if final_text:
		final_text.visible = false
	visible = false
	
	return


#----- util helpers ------
func _local_shake(intensity := 10, duration := 0.25) -> void:
	var original_pos = duel_cam.global_position if duel_cam else Vector2.ZERO
	var t = 0.0
	while t < duration:
		if duel_cam:
			duel_cam.global_position = original_pos + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		await  get_tree().create_timer(0.02).timeout
		t += 0.02
	
	if duel_cam:
		duel_cam.global_position = original_pos 
	
# Atualiza 'center' do zoom shader para um node (converte global_position -> uv)
func _set_zoom_center_to_node(node: Node2D) -> void:
	if not _zoom_mat or not node:
		return
	
	var vp = get_viewport()
	var cam := duel_cam if duel_cam else vp.get_camera_2d()
	var screen_pos = cam.get_camera_transform().xform_inv(node.global_position) if false else cam.unproject_position(node.global_position)
	
	#unproject_position retorna coordenadas de tela, converter para uv
	var screen_size = vp.get_visible_rect().size
	var uv =  Vector2(clamp(screen_pos.x / screen_size.x, 0.0, 1.0), clamp(screen_pos.y / screen_size.y, 0.0, 1.0))
	_zoom_mat.set_shader_parameter("center", uv)
	

#permitr o shader seguir o atacante em tempo real
func follow_blur_on(node: Node2D):
	_blur_target_node = node
	_blur_following = true
	
func stop_follow_blur():
	_blur_following = false
	_blur_target_node = null
	
func _process(delta: float) -> void:
	if _blur_following and _blur_target_node and _zoom_mat:
		#suaviza o centro(lerp)
		var vp = get_viewport()
		var screen_pos = duel_cam.unproject_position(_blur_target_node.global_position) if duel_cam else vp.get_camera_2d().unproject_position(_blur_target_node.global_position)
		var screen_size = vp.get_visible_rect().size
		var uv_new = Vector2(clamp(screen_pos.x / screen_size.x, 0.0, 1.0), clamp(screen_pos.y / screen_size.y, 0.0, 1.0))
		var prev = _zoom_mat.get_shader_parameter("center")
		_zoom_mat.set_shader_parameter("center", prev.lerp(uv_new, 0.25))
