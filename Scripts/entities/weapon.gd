extends Node3D

signal target_hit

@onready var sfx_whoosh: AudioStreamPlayer = $AudioWhoosh
@onready var sfx_charge = $AudioCharge
@onready var sfx_spell = $AudioSpell

func _ready() -> void:
	target_hit.connect(_on_target_hit)
	
func _process(delta: float) -> void:
	print (sfx_charge.get_playback_position())
	if sfx_charge.get_playback_position() > 0.15:
			sfx_charge.stop()
	
func cast():
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK)
	sfx_whoosh.play()
	tween.tween_property(self, "rotation_degrees", Vector3(-55, 5, 15), 0.3)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "rotation_degrees", Vector3(0, 0, 0), 0.2 )
	
	_spawn_spell()

func charge():
	if !sfx_charge.playing:
		sfx_charge.play()
		
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation_degrees", Vector3(25, 5, 5), 0.7)

func _on_target_hit():
	sfx_spell.play()

func _spawn_spell():
	print("PEEW")
	
	
	
	
