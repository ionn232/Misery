extends CharacterBody2D

@onready var debug_label: Label = $"../DEBUG_label"

@export var allow_drift:bool = false

#values per wheel (effectively doubled for player control)
const IMPULSE = 250.0
const MAX_SPEED = 300.0

const ROTATION_RADIUS = 700
const FRICTION = 0.025
const SPIN_DAMPENING = 0.005
const COLLISION_SPEED_LOSS = 0.075 #applied per physics frame

var speed_right:float = 0.0
var speed_left: float = 0.0

#TODO: move to physics process scope if drawing is no longer necessary
var forward:Vector2
var left:Vector2
var right:Vector2

func _physics_process(delta: float) -> void:
	var right_forward:bool = Input.is_action_just_pressed("Right-wheel-up")
	var right_back:bool = Input.is_action_just_pressed("Right-wheel-down")
	var left_forward:bool = Input.is_action_just_pressed("Left-wheel-up")
	var left_back:bool = Input.is_action_just_pressed("Left-wheel-down")
	
	#pushed a wheel
	if(left_forward || left_back):
		speed_left += IMPULSE * ((int(left_forward)*2)-1)
	if(right_forward || right_back):
		speed_right += IMPULSE * ((int(right_forward)*2)-1)
	
	#holding a wheel
	if (Input.is_action_pressed("Left-wheel-up") && Input.is_action_pressed("Left-wheel-down")):
		speed_left = -speed_right * (1.0 - 0.19) #TODO: calculate value instead of hardcoding
	if (Input.is_action_pressed("Right-wheel-up") && Input.is_action_pressed("Right-wheel-down")):
		speed_right = -speed_left * (1.0 - 0.19) #TODO same shit
	
	#floor friction
	speed_left = move_toward(speed_left, 0.0, abs(speed_left) * FRICTION)
	speed_right = move_toward(speed_right, 0.0, abs(speed_right) * FRICTION)
	
	#limit speed
	speed_left = clampf(speed_left, -MAX_SPEED, MAX_SPEED)
	speed_right = clampf(speed_right, -MAX_SPEED, MAX_SPEED)
	
	#debug instructions
	debug_label.text = 'speed: (' + str(speed_left) + ' , ' + str(speed_right) + ')'
	debug_label.text += '\nrotation: ' + str(rotation)
	debug_label.text += '\nforward: ' + str(forward)
	debug_label.text += '\nright: ' + str(right)
	debug_label.text += '\nleft: ' + str(left)
	#end debug
	
	#rotate according to wheel speeds
	rotate(-(speed_right*delta)/ROTATION_RADIUS)
	rotate((speed_left*delta)/ROTATION_RADIUS)
	forward = transform.x.rotated(PI/2)
	right = -transform.x
	left = transform.x
	
	#translate speeds into velocity
	velocity.x = speed_left * forward.x
	velocity.y = speed_left * forward.y
	velocity.x += speed_right * forward.x 
	velocity.y += speed_right * forward.y
	
	var collision:bool = move_and_slide() #applies velocity and checks for collision
	#reduce speed when collision detected
	if collision:
		speed_right = speed_right * (1.0 - COLLISION_SPEED_LOSS)
		speed_left = speed_left * (1.0 - COLLISION_SPEED_LOSS)
	

#debug function
func _draw():
	draw_circle(Vector2(ROTATION_RADIUS,0), ROTATION_RADIUS, Color.BLACK, false, 1)
	draw_circle(Vector2(-ROTATION_RADIUS,0), ROTATION_RADIUS, Color.BLACK, false, 1)
	
	draw_line(Vector2(0.0,0.0), + (global_transform.basis_xform_inv(forward) * 250), Color.RED, 1)
	draw_line(Vector2(0,0), Vector2(0,0) + (global_transform.basis_xform_inv(left) * ROTATION_RADIUS), Color.GREEN, 1)
	draw_line(Vector2(0,0), Vector2(0,0) + (global_transform.basis_xform_inv(right) * ROTATION_RADIUS), Color.BLUE, 1)
