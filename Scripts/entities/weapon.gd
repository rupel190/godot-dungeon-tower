extends Node3D

signal target_hit

@export var _dmg := 100
@export var _atk_range := 1.5

var _is_casting := false
var _active_target

@onready var sfx_whoosh: AudioStreamPlayer = $AudioWhoosh
@onready var sfx_charge: AudioStreamPlayer = $AudioWhoosh
@onready var sfx_spell: AudioStreamPlayer = $AudioWhoosh
@onready var ray: RayCast3D = RayCast3D.new()

func _ready() -> void:
	target_hit.connect(_on_target_hit)

	# Configure the reusable, top-level ray once
	add_child(ray)
	ray.set_collision_mask_value(1, false)
	ray.set_collision_mask_value(2, true)
	ray.target_position = Vector3.FORWARD * _atk_range
	ray.debug_shape_custom_color = Color(Color.LIGHT_SEA_GREEN)
	ray.debug_shape_thickness = 5

func _process(delta: float) -> void:
	if sfx_charge.get_playback_position() > 0.15:
		sfx_charge.stop()

func cast() -> void:
	if _is_casting:
		print("Already casting!")
		return

	_is_casting = true
	
	# DMG
	ray.force_raycast_update()
	var col := ray.get_collider()
	if col:
		print("Weapon collision: ", col)
		if col is Enemy and col.has_method("take_damage"):
			col.take_damage(self.get_parent(), _dmg)
	# FX
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK)
	sfx_whoosh.play()
	tween.tween_property(self, "rotation_degrees", Vector3(-55, 5, 15), 0.3)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "rotation_degrees", Vector3(0, 0, 0), 0.2 )
	tween.finished.connect(func(): _is_casting = false)

func charge() -> void:
	if !sfx_charge.playing:
		sfx_charge.play()
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation_degrees", Vector3(25, 5, 5), 0.7)

func _on_target_hit() -> void:
	sfx_spell.play()

func _spawn_spell() -> void:
	print("PEEW")
