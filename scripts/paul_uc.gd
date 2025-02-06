extends CharacterBody2D

@onready var debug_label: Label = $"../DEBUG_ui/DEBUG_label"

#values per wheel (effectively doubled for player control)
const IMPULSE = 300.0
const MAX_SPEED = 400.0

const MAX_ROTATION_RADIUS = 1000.0
const FRICTION = 5 #0.025
const SPIN_DAMPENING = 0.005
const COLLISION_SPEED_LOSS = 0.075 #applied per physics frame

const SPIN_SPEED_DAMPENING = 0.5
const HOLD_SPEED_DAMPENING = 0.25

var rotation_radius_left:float = MAX_ROTATION_RADIUS
var rotation_radius_right:float = MAX_ROTATION_RADIUS

var raw_speed_right:float = 0.0
var raw_speed_left:float = 0.0

#TODO: move to physics process scope if drawing is no longer necessary
var forward:Vector2
var left:Vector2
var right:Vector2

func _physics_process(delta: float) -> void:
	#input handling
	var right_forward:bool = Input.is_action_just_pressed("Right-wheel-up")
	var right_back:bool = Input.is_action_just_pressed("Right-wheel-down")
	var left_forward:bool = Input.is_action_just_pressed("Left-wheel-up")
	var left_back:bool = Input.is_action_just_pressed("Left-wheel-down")
	
	#radius init per frame
	rotation_radius_left = MAX_ROTATION_RADIUS
	rotation_radius_right = MAX_ROTATION_RADIUS
	
	#both wheels have opposite forces (spinning around self)
	var speed_right = raw_speed_right
	var speed_left = raw_speed_left
	if (sign(raw_speed_left) != sign(raw_speed_right) && raw_speed_left != 0.0 && raw_speed_right != 0.0 && abs(raw_speed_left + raw_speed_right) <= 50.0):
		rotation_radius_right = MAX_ROTATION_RADIUS * 0.05 if raw_speed_left > raw_speed_right else rotation_radius_right
		rotation_radius_left = MAX_ROTATION_RADIUS * 0.05 if raw_speed_left < raw_speed_right else rotation_radius_left
		#shitty hack to avoid making player a beyblade without modifying raw speed: 
		#uses alternative (lower) speed values for this frame
		speed_right = raw_speed_right * SPIN_SPEED_DAMPENING
		speed_left = raw_speed_left * SPIN_SPEED_DAMPENING
	
	#pushed a wheel
	if(left_forward || left_back):
		raw_speed_left += IMPULSE * ((int(left_forward)*2)-1)
		rotation_radius_right = MAX_ROTATION_RADIUS
	if(right_forward || right_back):
		raw_speed_right += IMPULSE * ((int(right_forward)*2)-1)
		rotation_radius_left = MAX_ROTATION_RADIUS
	
	#holding a wheel
	if (Input.is_action_pressed("Left-wheel-up") && Input.is_action_pressed("Left-wheel-down")):
		raw_speed_left = 0
		rotation_radius_left = MAX_ROTATION_RADIUS * 0.1
		speed_right = raw_speed_right * HOLD_SPEED_DAMPENING
		speed_left = raw_speed_left * HOLD_SPEED_DAMPENING
	if (Input.is_action_pressed("Right-wheel-up") && Input.is_action_pressed("Right-wheel-down")):
		raw_speed_right = 0
		rotation_radius_right = MAX_ROTATION_RADIUS * 0.1
		speed_right = raw_speed_right * HOLD_SPEED_DAMPENING
		speed_left = raw_speed_left * HOLD_SPEED_DAMPENING
	
	#floor friction
	#raw_speed_left = move_toward(raw_speed_left, 0.0, abs(raw_speed_left) * FRICTION)
	#raw_speed_right = move_toward(raw_speed_right, 0.0, abs(raw_speed_right) * FRICTION)
	raw_speed_left = move_toward(raw_speed_left, 0.0, FRICTION)
	raw_speed_right = move_toward(raw_speed_right, 0.0, FRICTION)
	
	#limit speed
	raw_speed_left = clampf(raw_speed_left, -MAX_SPEED, MAX_SPEED)
	raw_speed_right = clampf(raw_speed_right, -MAX_SPEED, MAX_SPEED)
	
	#calculate rotation radius DEPRECATED
	#rotation_radius_left = lerp(0.05, MAX_ROTATION_RADIUS, abs(speed_right-speed_left)/(MAX_SPEED*2))
	#rotation_radius_right = lerp(0.05, MAX_ROTATION_RADIUS, abs(speed_left-speed_right)/(MAX_SPEED*2))
	
	#debug instructions
	debug_label.text = 'speed: (' + str(raw_speed_left) + ' , ' + str(raw_speed_right) + ')'
	debug_label.text += '\nradius: (' + str(rotation_radius_left) + ' , ' + str(rotation_radius_right) + ')'
	debug_label.text += '\nrotation: ' + str(rotation)
	debug_label.text += '\nforward: ' + str(forward)
	debug_label.text += '\nright: ' + str(right)
	debug_label.text += '\nleft: ' + str(left)
	#end debug
	
	#rotate according to wheel speeds
	rotate(-(speed_right*delta)/rotation_radius_left)
	rotate((speed_left*delta)/rotation_radius_right)
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
		raw_speed_right = raw_speed_right * (1.0 - COLLISION_SPEED_LOSS)
		raw_speed_left = raw_speed_left * (1.0 - COLLISION_SPEED_LOSS)
	self.draw

#debug function
func _draw():
	draw_circle(Vector2(MAX_ROTATION_RADIUS,0), rotation_radius_left, Color.BLACK, false, 1)
	draw_circle(Vector2(-MAX_ROTATION_RADIUS,0), rotation_radius_right, Color.BLACK, false, 1)
	
	draw_line(Vector2(0.0,0.0), + (global_transform.basis_xform_inv(forward) * 250), Color.RED, 1)
	draw_line(Vector2(0,0), Vector2(0,0) + (global_transform.basis_xform_inv(left) * rotation_radius_left), Color.GREEN, 1)
	draw_line(Vector2(0,0), Vector2(0,0) + (global_transform.basis_xform_inv(right) * rotation_radius_right), Color.BLUE, 1)
