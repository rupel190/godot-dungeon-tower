extends ShapeCast3D
class_name PlayerInteractCast

@export var interact_label : RichTextLabel
var curr_dialogue : String


var show_prompt:bool = false
func _physics_process(delta: float) -> void:
	
	var collider = null
	if is_colliding():
		for collider_idx in get_collision_count():
			if get_collider(collider_idx) is Interactable:
				collider = get_collider(collider_idx)
	
	if collider != null:
		
		if collider is Interactable:
			if collider.can_be_interacted == false:
				return
			if collider.prompt_action == "interact":
				# interact_label Logic
				if interact_label.text == collider.get_prompt()+ " ["+collider.get_key()+"]":
					pass
				else:
					show_prompt = true
					if collider.get_key().is_empty() == false:
						interact_label.text = collider.get_prompt()+ " ["+collider.get_key()+"]"
					else:
						interact_label.text = collider.get_prompt()
				# Key Pressed Logic
				if collider._hasDialogue:
					curr_dialogue = collider.dialouge
					if Input.is_action_just_pressed(collider.prompt_action):
						collider.run_dialogue()

				elif Input.is_action_just_pressed(collider.prompt_action):
					collider.interact(owner)
				
			else:
				interact_label.text = collider.get_prompt()
	else:
		show_prompt = false
	
	if show_prompt:
		interact_label.modulate.a += 0.1
	else:
		interact_label.modulate.a = clamp(interact_label.modulate.a - 0.1,0,1)
