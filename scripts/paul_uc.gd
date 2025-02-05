extends CharacterBody2D

@onready var debug_label: Label = $"../DEBUG_label"

const IMPULSE = 500.0
const MAX_SPEED = 600.0
const ROTATION_RADIUS = 700
const FRICTION = 0.025
const SPIN_DAMPENING = 0.05
const COLLISION_SPEED_LOSS = 0.075 #applied per physics frame

var speed:float = 0.0
var spin_left:float = 0.0
var spin_right:float = 0.0

#TODO: move to physics process scope if drawing is no longer necessary
var forward:Vector2
var left:Vector2
var right:Vector2

func _physics_process(delta: float) -> void:
	var right_forward:bool = Input.is_action_just_pressed("Right-wheel-up")
	var right_back:bool = Input.is_action_just_pressed("Right-wheel-down")
	var left_forward:bool = Input.is_action_just_pressed("Left-wheel-up")
	var left_back:bool = Input.is_action_just_pressed("Left-wheel-down")
	
	if (left_forward || left_back):
		speed += 0.5 * IMPULSE * ((int(left_forward)*2)-1)
		spin_right = float(left_forward || left_back)
	elif (right_forward || right_back):
		speed += 0.5 * IMPULSE * ((int(right_forward)*2)-1)
		spin_left = float(right_forward || right_back)
	#if (left_forward || left_back || right_forward || right_back):
		#speed = IMPULSE/2 * (float(left_forward) + float(right_forward) - float(left_back) - float(left_forward))
		##spin_right = float(left_forward || left_back)
		##spin_left = float(right_forward || right_back)
	else:
		speed = move_toward(speed, 0.0, abs(speed) * FRICTION)
		if (spin_left > 0.0 && spin_right > 0.0):
			spin_left = maxf(0.0, move_toward(spin_left, 0.0, spin_left * SPIN_DAMPENING))
			spin_right = maxf(0.0, move_toward(spin_right, 0.0, spin_right * SPIN_DAMPENING))
	
	#limit speed
	speed = clampf(speed, -MAX_SPEED, MAX_SPEED)
	
	#debug instructions
	debug_label.text = 'speed: ' + str(speed)
	debug_label.text += '\nrotation: ' + str(rotation)
	debug_label.text += '\nforward: ' + str(forward)
	debug_label.text += '\nright: ' + str(right)
	debug_label.text += '\nleft: ' + str(left)
	debug_label.text += '\nspin right: ' + str(spin_right)
	debug_label.text += '\nspin left: ' + str(spin_left)
	#end debug
	
	rotate(((speed*delta)/ROTATION_RADIUS) * spin_right)
	rotate(-((speed*delta)/ROTATION_RADIUS) * spin_left)
	
	forward = transform.x.rotated(PI/2)
	right = -transform.x
	left = transform.x
	
	velocity.x = speed * forward.x
	velocity.y = speed * forward.y
	
	
	var collision:bool = move_and_slide() #applies velocity and checks for collision
	#reduce speed when collision detected
	if collision:
		speed = speed * (1.0 - COLLISION_SPEED_LOSS)
	

#debug function
func _draw():
	draw_circle(Vector2(ROTATION_RADIUS,0), ROTATION_RADIUS, Color.BLACK, false, 1)
	draw_circle(Vector2(-ROTATION_RADIUS,0), ROTATION_RADIUS, Color.BLACK, false, 1)
	
	draw_line(Vector2(0.0,0.0), + (global_transform.basis_xform_inv(forward) * 250), Color.RED, 1)
	draw_line(Vector2(0,0), Vector2(0,0) + (global_transform.basis_xform_inv(left) * ROTATION_RADIUS), Color.GREEN, 1)
	draw_line(Vector2(0,0), Vector2(0,0) + (global_transform.basis_xform_inv(right) * ROTATION_RADIUS), Color.BLUE, 1)
