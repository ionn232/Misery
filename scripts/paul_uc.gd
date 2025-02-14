extends CharacterBody2D

@onready var debug_label: Label = $"../DEBUG_ui/DEBUG_label"
@onready var push_timer: Timer = $PushTimer

signal process_push

#values per wheel (effectively doubled for player control)
const IMPULSE = 300.0
const MAX_SPEED = 400.0

#default rotation radius when pushing one wheel (others scale from this)
const MAX_ROTATION_RADIUS = 1000.0

#push cooldown (batch intervals) IN SECONDS
const PUSH_BATCH_TIME = 0.333 #20 frames

#dampening factors, linear progression
const FRICTION = 500
const COLLISION_SPEED_LOSS = 0.075 
const SPIN_SPEED_DAMPENING = 0.01
const HOLD_SPEED_DAMPENING = 0.25

var rotation_radius_left:float = MAX_ROTATION_RADIUS
var rotation_radius_right:float = MAX_ROTATION_RADIUS

#store true speed, some frames use fake values as a hack
var raw_speed_right:float = 0.0
var raw_speed_left:float = 0.0

#inputs queued for next batch
var queue_right_forward:bool = false
var queue_right_back:bool = false
var queue_left_forward:bool = false
var queue_left_back:bool = false

#TODO: move to physics process scope if drawing is no longer necessary
var forward:Vector2
var left:Vector2
var right:Vector2

func _ready() -> void:
	push_timer.wait_time = PUSH_BATCH_TIME

func _physics_process(delta: float) -> void:
	#input handling
	var input_right_forward = Input.is_action_just_pressed("Right-wheel-up")
	var input_right_back = Input.is_action_just_pressed("Right-wheel-down")
	var input_left_forward = Input.is_action_just_pressed("Left-wheel-up")
	var input_left_back = Input.is_action_just_pressed("Left-wheel-down")
	
	#radius init per tick
	rotation_radius_left = MAX_ROTATION_RADIUS
	rotation_radius_right = MAX_ROTATION_RADIUS
	
	#speed init per tick
	var speed_right = raw_speed_right
	var speed_left = raw_speed_left
	
	#both wheels have opposite forces (spinning around self)
	if (sign(raw_speed_left) != sign(raw_speed_right) && raw_speed_left != 0.0 && raw_speed_right != 0.0 && abs(raw_speed_left + raw_speed_right) <= 10.0):
		rotation_radius_right = MAX_ROTATION_RADIUS * 0.001 if raw_speed_left > raw_speed_right else rotation_radius_right
		rotation_radius_left = MAX_ROTATION_RADIUS * 0.001 if raw_speed_left < raw_speed_right else rotation_radius_left
		#shitty hack to avoid making player a beyblade without modifying raw speed: 
		#uses alternative (lower) speed values for this tick
		speed_right = raw_speed_right * SPIN_SPEED_DAMPENING
		speed_left = raw_speed_left * SPIN_SPEED_DAMPENING
	
	#queue direction per wheel for next push. Overwrite if new. Prioritize forward if both pressed on same frame.
	if(input_left_forward || input_left_back):
		queue_left_forward = input_left_forward
		queue_left_back = !input_left_forward
	if(input_right_forward || input_right_back):
		queue_right_forward = input_right_forward
		queue_right_back = !input_right_forward
	
	#holding a wheel. Deque wheel push.
	if (Input.is_action_pressed("Left-wheel-up") && Input.is_action_pressed("Left-wheel-down")):
		raw_speed_left = 0
		rotation_radius_left = MAX_ROTATION_RADIUS * 0.06
		speed_right = raw_speed_right * HOLD_SPEED_DAMPENING
		speed_left = raw_speed_left * HOLD_SPEED_DAMPENING
		queue_left_back = false
		queue_left_forward = false
	if (Input.is_action_pressed("Right-wheel-up") && Input.is_action_pressed("Right-wheel-down")):
		raw_speed_right = 0
		rotation_radius_right = MAX_ROTATION_RADIUS * 0.06
		speed_right = raw_speed_right * HOLD_SPEED_DAMPENING
		speed_left = raw_speed_left * HOLD_SPEED_DAMPENING
		queue_right_back = false
		queue_right_forward = false
	
	#floor friction
	raw_speed_left = move_toward(raw_speed_left, 0.0, FRICTION * delta)
	raw_speed_right = move_toward(raw_speed_right, 0.0, FRICTION * delta)
	
	#limit speed
	raw_speed_left = clampf(raw_speed_left, -MAX_SPEED, MAX_SPEED)
	raw_speed_right = clampf(raw_speed_right, -MAX_SPEED, MAX_SPEED)
	
	#start or stop pushing procedure according to inputs and queue
	if ((input_right_forward|| input_right_back|| input_left_forward||input_left_back) && push_timer.time_left == 0.0):
		push_timer.start()
	elif ((!queue_right_forward && !queue_right_back && !queue_left_forward && !queue_left_back)):
		push_timer.stop()
	
	#debug instructions
	debug_label.text = 'speed: (' + str(raw_speed_left) + ' , ' + str(raw_speed_right) + ')'
	debug_label.text += '\nradius: (' + str(rotation_radius_left) + ' , ' + str(rotation_radius_right) + ')'
	debug_label.text += '\nrotation: ' + str(rotation)
	debug_label.text += '\nforward: ' + str(forward)
	debug_label.text += '\nright: ' + str(right)
	debug_label.text += '\nleft: ' + str(left)
	debug_label.text += '\ntimer: ' + str(push_timer.time_left)
	#end debug
	
	#rotate according to wheel speeds (wheel distance / radius)
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

#apply and dequeue inputs when timer ends
func wheelchair_push() -> void:
	#apply queued wheel pushes and reset
	if(queue_left_forward || queue_left_back):
		raw_speed_left += IMPULSE * ((int(queue_left_forward)*2)-1)
		rotation_radius_right = MAX_ROTATION_RADIUS
		queue_left_back = false
		queue_left_forward = false
	if(queue_right_forward || queue_right_back):
		raw_speed_right += IMPULSE * ((int(queue_right_forward)*2)-1)
		rotation_radius_left = MAX_ROTATION_RADIUS
		queue_right_back = false
		queue_right_forward = false


#debug function
func _draw():
	draw_circle(Vector2(MAX_ROTATION_RADIUS,0), rotation_radius_left, Color.BLACK, false, 1)
	draw_circle(Vector2(-MAX_ROTATION_RADIUS,0), rotation_radius_right, Color.BLACK, false, 1)
	
	draw_line(Vector2(0.0,0.0), + (global_transform.basis_xform_inv(forward) * 250), Color.RED, 1)
	draw_line(Vector2(0,0), Vector2(0,0) + (global_transform.basis_xform_inv(left) * rotation_radius_left), Color.GREEN, 1)
	draw_line(Vector2(0,0), Vector2(0,0) + (global_transform.basis_xform_inv(right) * rotation_radius_right), Color.BLUE, 1)
