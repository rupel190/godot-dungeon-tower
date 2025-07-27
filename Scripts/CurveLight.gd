@tool
extends Light3D
class_name CurveLight
#LIGHT THAT CHANGES OVER TIME


@export var time_scale:float = 0.1
@export var color_energy:Gradient = Gradient.new()

var time:float
func _physics_process(delta: float) -> void:
	time += delta * time_scale
	if time >= 1:
		time = 0
	var color_and_energy:Color =  color_energy.sample(time)
	
	light_energy = color_and_energy.a
	
	light_color = color_and_energy
	
