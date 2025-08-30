extends Node3D

signal target_hit

@export var _dmg = 100

var _is_casting = false
var _active_target

@onready var sfx_whoosh: AudioStreamPlayer = $AudioWhoosh
@onready var sfx_charge = $AudioWhoosh
@onready var sfx_spell = $AudioWhoosh

func _ready() -> void:
	target_hit.connect(_on_target_hit)
	
func _process(delta: float) -> void:
	if sfx_charge.get_playback_position() > 0.15:
			sfx_charge.stop()
			
			
func cast():
	if !_is_casting:
		_is_casting = true
		# FX
		var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK)
		sfx_whoosh.play()
		tween.tween_property(self, "rotation_degrees", Vector3(-55, 5, 15), 0.3)
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "rotation_degrees", Vector3(0, 0, 0), 0.2 )
		tween.finished.connect(func(): _is_casting = false)
		# DMG
		if(_active_target and _active_target is Enemy and _active_target.has_method("take_damage")):
			print("ENEMY HIT")
			_active_target.take_damage(self.get_parent(), _dmg)
	else:
		print("Already casting!")
	
func charge():
	if !sfx_charge.playing:
		sfx_charge.play()
		
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation_degrees", Vector3(25, 5, 5), 0.7)

func _on_target_hit():
	sfx_spell.play()

func _spawn_spell():
	print("PEEW")


func _on_body_entered(body: Node3D) -> void:
	_active_target = body

func _on_body_exited(body: Node3D) -> void:
	_active_target = null
	
