extends AnimatedSprite2D

var timer: Timer
@export var countdown_seconds = 12

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout) # mui importando
	add_child(timer)
	
	self
	animation_finished.connect(_on_fuse_finished)
	
	# Decelerate animation to match countdown
	var timer_speed_scale = _calc_animation_duration()/countdown_seconds 
	timer.start(countdown_seconds)
	play('default', timer_speed_scale)

func _calc_animation_duration(): 
	var animation_speed = speed_scale
	var anim_name = 'default'
	var fps = sprite_frames.get_animation_speed(anim_name)
	var allframes_duration = 0
	var absolute_duration = 0
	sprite_frames.set_animation_loop(anim_name, false)
	
	for n in sprite_frames.get_frame_count(anim_name):
		var frame_duration = sprite_frames.get_frame_duration(anim_name, n) 
		allframes_duration += frame_duration
	return (allframes_duration / fps) * speed_scale
	
	
func _on_timer_timeout():
	print('Countdown finished!')
	#GameManager.timer_finished()
	
func _on_fuse_finished():
	print('Animation finished!')
	#GameManager.animation_finished()
	
