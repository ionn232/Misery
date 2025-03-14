extends CharacterBody2D

@onready var debug_label: Label = $"../ui/DEBUG_label"
@onready var push_timer: Timer = $PushTimer
@onready var sprite_handler_right: AnimatedSprite2D = $SpriteHandlerRight
@onready var sprite_handler_left: AnimatedSprite2D = $SpriteHandlerLeft
@onready var object_detector: Area2D = $ObjectDetector
@onready var time_limit: Timer = $"../TimeLimit"
@onready var sfx_movement: AudioStreamPlayer = $SfxMovement
@onready var sfx_movement2: AudioStreamPlayer = $SfxMovement2
@onready var sfx_movement3: AudioStreamPlayer = $SfxMovement3
@onready var sfx_movement4: AudioStreamPlayer = $SfxMovement4
@onready var sfx_movement5: AudioStreamPlayer = $SfxMovement5
@onready var sfx_movement6: AudioStreamPlayer = $SfxMovement6
@onready var sfx_movement7: AudioStreamPlayer = $SfxMovement7
@onready var sfx_movement8: AudioStreamPlayer = $SfxMovement8

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

var last_push:float = 0.0

var is_paused:bool = false

#TODO: move to physics process scope if drawing is no longer necessary
var forward:Vector2
var left:Vector2
var right:Vector2

func _ready() -> void:
	push_timer.wait_time = PUSH_BATCH_TIME
	sprite_handler_right.play("neutral")
	sprite_handler_left.play("neutral")
	Dialogic.timeline_ended.connect(resume_game)

func _physics_process(delta: float) -> void:
	if is_paused:
		return
	
	#input handling
	var input_right_forward = Input.is_action_just_pressed("Right-wheel-up")
	var input_right_back = Input.is_action_just_pressed("Right-wheel-down")
	var input_left_forward = Input.is_action_just_pressed("Left-wheel-up")
	var input_left_back = Input.is_action_just_pressed("Left-wheel-down")	#radius init per tick
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
		sprite_handler_left.play("brake")
	if (Input.is_action_pressed("Right-wheel-up") && Input.is_action_pressed("Right-wheel-down")):
		raw_speed_right = 0
		rotation_radius_right = MAX_ROTATION_RADIUS * 0.06
		speed_right = raw_speed_right * HOLD_SPEED_DAMPENING
		speed_left = raw_speed_left * HOLD_SPEED_DAMPENING
		queue_right_back = false
		queue_right_forward = false
		sprite_handler_right.play("brake")
	
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
	debug_label.text += '\nlast push: ' + str(last_push)
	#end debug
	
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
	
	#applies velocity and checks for collision
	var collision:bool = move_and_slide() 
	
	#reduce speed and undo rotation when collision detected
	if collision:
		raw_speed_right = raw_speed_right * (1.0 - COLLISION_SPEED_LOSS)
		raw_speed_left = raw_speed_left * (1.0 - COLLISION_SPEED_LOSS)
		rotate((speed_right*delta)/rotation_radius_left)
		rotate(-(speed_left*delta)/rotation_radius_right)
	
	#augment timer (used for input batching)
	last_push += delta
	
	#interact with objects
	if(Input.is_action_just_pressed("Interact")):
		var objectAreas:Array[Area2D] = object_detector.get_overlapping_areas()
		if (objectAreas.size() > 0 && objectAreas[0].name == 'ObjectArea'):
			var object:interactable = objectAreas[0].get_parent()
			object.interact()
			is_paused = true
			push_timer.paused = true
			time_limit.paused = true

#apply and dequeue inputs when timer ends
func wheelchair_push() -> void:
	#apply queued wheel pushes and reset
	if(queue_left_forward || queue_left_back):
		raw_speed_left += IMPULSE * ((int(queue_left_forward)*2)-1)
		rotation_radius_right = MAX_ROTATION_RADIUS
		sprite_handler_left.play("push") if queue_left_forward else sprite_handler_left.play("push_back")
		queue_left_back = false
		queue_left_forward = false
		var randf = randf()
		if randf() < 0.5:
			if randf < 0.1:
				sfx_movement.play()
			if randf < 0.2 && randf > 0.1:
				sfx_movement2.play()
			if randf < 0.3 && randf > 0.2:
				sfx_movement3.play()
			if randf < 0.4 && randf > 0.3:
				sfx_movement4.play()
			if randf < 0.5 && randf > 0.4:
				sfx_movement5.play()
			if randf < 0.6 && randf > 0.5:
				sfx_movement6.play()
			if randf < 0.7 && randf > 0.6:
				sfx_movement7.play()
			if randf < 0.8 && randf > 0.7:
				sfx_movement8.play()
		
	if(queue_right_forward || queue_right_back):
		raw_speed_right += IMPULSE * ((int(queue_right_forward)*2)-1)
		rotation_radius_left = MAX_ROTATION_RADIUS
		sprite_handler_right.play("push") if queue_right_forward else sprite_handler_right.play("push_back")
		queue_right_back = false
		queue_right_forward = false
		var randf = randf()
		if randf() < 0.5:
			if randf < 0.1:
				sfx_movement.play()
			if randf < 0.2 && randf > 0.1:
				sfx_movement2.play()
			if randf < 0.3 && randf > 0.2:
				sfx_movement3.play()
			if randf < 0.4 && randf > 0.3:
				sfx_movement4.play()
			if randf < 0.5 && randf > 0.4:
				sfx_movement5.play()
			if randf < 0.6 && randf > 0.5:
				sfx_movement6.play()
			if randf < 0.7 && randf > 0.6:
				sfx_movement7.play()
			if randf < 0.8 && randf > 0.7:
				sfx_movement8.play()
	last_push = 0.0

func resume_game():
	is_paused = false
	push_timer.paused = false
	time_limit.paused = false
