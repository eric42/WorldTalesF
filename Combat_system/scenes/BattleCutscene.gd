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
