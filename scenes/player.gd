extends RigidBody2D

var flying_started : bool = false
var is_on_ground : bool = true

var jump_strength : int = 0

@onready var animation_tree : AnimationTree = $AnimationTree

enum STATES { IDLE, CHARGE, JUMP, FLY, LAND, DEAD, CATCH_RIGHT, CATCH_LEFT, CATCH_IDLE_RIGHT, CATCH_IDLE_LEFT, CATCH_JUMP_RIGHT, CATCH_JUMP_LEFT, CATCH_CHARGE_RIGHT, CATCH_CHARGE_LEFT }
var last_state : STATES
var current_state : STATES

func _ready():
	current_state = STATES.IDLE

func _process(delta):
	print_state_changes()
	animation_manager()
	state_machine_process()
	capture_events()

func _physics_process(delta):
	state_machine_physics_process()
	
### STATE MACHINES ###

func state_machine_process():
	match current_state:
		STATES.IDLE:
			pass
		STATES.CHARGE:
			check_direction()
		STATES.JUMP:
			pass
		STATES.FLY:
			pass
		STATES.LAND:
			pass
		STATES.DEAD:
			pass
		STATES.CATCH_RIGHT:
			pass
		STATES.CATCH_LEFT:
			pass
		STATES.CATCH_IDLE_RIGHT:
			pass
		STATES.CATCH_IDLE_LEFT:
			pass
		STATES.CATCH_CHARGE_RIGHT:
			check_direction()
		STATES.CATCH_CHARGE_LEFT:
			check_direction()
		STATES.CATCH_JUMP_RIGHT:
			pass
		STATES.CATCH_JUMP_LEFT:
			pass

func print_state_changes():
	if last_state != current_state:
		print(STATES.find_key(last_state) + " -> " + STATES.find_key(current_state))
		last_state = current_state

func state_machine_physics_process():
	match current_state:
		STATES.IDLE:
			pass
		STATES.CHARGE:
			jump_charging()
		STATES.JUMP:
			jump_release()
		STATES.FLY:
			uncatch()
			check_if_on_ground()
			flying_check()
		STATES.LAND:
			pass
		STATES.DEAD:
			pass
		STATES.CATCH_RIGHT:
			catch()
		STATES.CATCH_LEFT:
			catch()
		STATES.CATCH_IDLE_RIGHT:
			pass
		STATES.CATCH_IDLE_LEFT:
			pass
		STATES.CATCH_CHARGE_RIGHT:
			jump_charging()
		STATES.CATCH_CHARGE_LEFT:
			jump_charging()
		STATES.CATCH_JUMP_RIGHT:
			jump_release()
		STATES.CATCH_JUMP_LEFT:
			jump_release()

### ANIMATION MANAGMENT ###

func animation_manager():
	animation_tree["parameters/conditions/idle"] = current_state == STATES.IDLE
	animation_tree["parameters/conditions/is_charging"] = current_state == STATES.CHARGE
	animation_tree["parameters/conditions/is_flying"] = current_state == STATES.FLY
	animation_tree["parameters/conditions/jump"] = current_state == STATES.JUMP
	animation_tree["parameters/conditions/land"] = current_state == STATES.LAND
	animation_tree["parameters/conditions/dead"] = current_state == STATES.DEAD
	animation_tree["parameters/conditions/catch_right"] = current_state == STATES.CATCH_RIGHT
	animation_tree["parameters/conditions/catch_left"] = current_state == STATES.CATCH_LEFT
	animation_tree["parameters/conditions/catch_idle_right"] = current_state == STATES.CATCH_IDLE_RIGHT
	animation_tree["parameters/conditions/catch_idle_left"] = current_state == STATES.CATCH_IDLE_LEFT
	animation_tree["parameters/conditions/catch_jump_right"] = current_state == STATES.CATCH_JUMP_RIGHT
	animation_tree["parameters/conditions/catch_jump_left"] = current_state == STATES.CATCH_JUMP_LEFT
	animation_tree["parameters/conditions/catch_is_charging_right"] = current_state == STATES.CATCH_CHARGE_RIGHT
	animation_tree["parameters/conditions/catch_is_charging_left"] = current_state == STATES.CATCH_CHARGE_LEFT

### EVENTS CAPTURING ###

func capture_events():
	if Input.is_action_pressed("ui_up") and current_state == STATES.IDLE:
		current_state = STATES.CHARGE
	elif Input.is_action_pressed("ui_up") and current_state == STATES.CATCH_IDLE_LEFT:
		current_state = STATES.CATCH_CHARGE_LEFT
	elif Input.is_action_pressed("ui_up") and current_state == STATES.CATCH_IDLE_RIGHT:
		current_state = STATES.CATCH_CHARGE_RIGHT
	elif Input.is_action_just_released("ui_up") and current_state == STATES.CHARGE:
		current_state = STATES.JUMP
	elif Input.is_action_just_released("ui_up") and current_state == STATES.CATCH_CHARGE_RIGHT:
		current_state = STATES.CATCH_JUMP_RIGHT
	elif Input.is_action_just_released("ui_up") and current_state == STATES.CATCH_CHARGE_LEFT:
		current_state = STATES.CATCH_JUMP_LEFT
	
	if Input.is_action_just_pressed("ui_select") and current_state == STATES.FLY and !$Catchable_area_left.get_overlapping_bodies().is_empty():
		current_state = STATES.CATCH_LEFT
	elif Input.is_action_just_pressed("ui_select") and current_state == STATES.FLY and !$Catchable_area_right.get_overlapping_bodies().is_empty():
		current_state = STATES.CATCH_RIGHT
	elif Input.is_action_just_released("ui_select") and (current_state == STATES.CATCH_LEFT or current_state == STATES.CATCH_IDLE_LEFT or current_state == STATES.CATCH_RIGHT or current_state == STATES.CATCH_IDLE_RIGHT):
		current_state = STATES.FLY
#

enum DIRECTIONS { UP, LEFT, RIGHT}
var last_direction : DIRECTIONS = DIRECTIONS.UP

func check_direction():
	if Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		$Direction_buffer.start()

	if Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
		last_direction = DIRECTIONS.LEFT
	elif Input.is_action_pressed("ui_right")and !Input.is_action_pressed("ui_left"):
		last_direction = DIRECTIONS.RIGHT
	elif $Direction_buffer.is_stopped():
		last_direction = DIRECTIONS.UP

### ACTIONS LOGIC ###

func jump_charging():
	if $Charge_timer.is_stopped():
		$Charge_timer.start()

func _on_charge_timer_timeout():
	if jump_strength < 100:
		jump_strength += 1

var triggered_jump_direction : DIRECTIONS 

func jump_release():
	triggered_jump_direction = last_direction

func jump():
	uncatch()
	$Charge_timer.stop()
	
	var direction : Vector2
	if triggered_jump_direction == DIRECTIONS.LEFT:
		direction = Vector2(-3, -5)
	elif triggered_jump_direction == DIRECTIONS.RIGHT:
		direction = Vector2(3, -5)
	elif triggered_jump_direction == DIRECTIONS.UP:
		direction = Vector2(0, -7)
	print("jump")
	print(jump_strength)
	apply_central_impulse(direction * jump_strength)
	jump_strength = 0
	current_state = STATES.FLY

func check_if_on_ground():
	is_on_ground = !$Ground_detector.get_overlapping_bodies().is_empty()

func flying_check():
	if !flying_started:
		$Land_checker.start()
		flying_started = true

func _on_land_checker_timeout():
	if is_on_ground:
		flying_started = false
		current_state = STATES.LAND
	else:
		$Land_checker.start()

func landed():
	current_state = STATES.IDLE

func catch():
	linear_velocity = Vector2(0, 0)
	gravity_scale = 0.0
	
func uncatch():
	gravity_scale = 1.0

func catch_idle():
	if current_state == STATES.CATCH_RIGHT:
		current_state = STATES.CATCH_IDLE_RIGHT
	elif current_state == STATES.CATCH_LEFT:
		current_state = STATES.CATCH_IDLE_LEFT


#### old code

#var on_catchable_object : bool = false
#var catched : bool = false
#
#var left_the_ground : bool = false
#var is_on_ground : bool = true
#
#var jump_strength : int = 0
#
#@onready var animation_tree : AnimationTree = $AnimationTree

#func _ready():
#	animation_tree["parameters/conditions/idle"] = true
#
#func  _process(delta):
#	check_direction()
#
#func _physics_process(delta):
#	check_if_on_ground()
#	if $Catchable_area.get_overlapping_bodies().size() != 0:
#		on_catchable_object = true
#	else:
#		on_catchable_object = false
#
#	if animation_tree["parameters/conditions/is_flying"] == true:
#		flying_check()
#
#	if Input.is_action_just_pressed("ui_select") and animation_tree["parameters/conditions/is_flying"] == true:
#		catch()
#	elif catched and Input.is_action_just_released("ui_select") and (animation_tree["parameters/conditions/catch_idle_left"] == true or animation_tree["parameters/conditions/catch_left"] == true):
#		uncatch()
#
#	if is_on_ground or catched:
#		if Input.is_action_pressed("ui_up") and (animation_tree["parameters/conditions/idle"] == true or animation_tree["parameters/conditions/catch_idle_left"] == true):
#			jump_charging()
#		elif Input.is_action_just_released("ui_up") and (animation_tree["parameters/conditions/is_charging"] == true or animation_tree["parameters/conditions/catch_is_charging_left"] == true):
#			jump_release()
#
#func jump_charging():
#	if catched:
#		animation_tree["parameters/conditions/catch_idle_left"] = false
#		animation_tree["parameters/conditions/catch_is_charging_left"] = true
#	else:
#		animation_tree["parameters/conditions/idle"] = false
#		animation_tree["parameters/conditions/is_charging"] = true
#
#	if $Charge_timer.is_stopped():
#		$Charge_timer.start()
#
#func _on_charge_timer_timeout():
#	if jump_strength < 100:
#		jump_strength += 1
#
#enum DIRECTIONS { UP, LEFT, RIGHT}
#var last_direction : DIRECTIONS = DIRECTIONS.UP
#
#func check_direction():
#	if Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
#		$Direction_buffer.start()
#
#	if Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
#		last_direction = DIRECTIONS.LEFT
#	elif Input.is_action_pressed("ui_right")and !Input.is_action_pressed("ui_left"):
#		last_direction = DIRECTIONS.RIGHT
#	elif $Direction_buffer.is_stopped():
#		last_direction = DIRECTIONS.UP
#
#func jump_release():
#	triggered_jump_direction = last_direction
#	if catched:
#		animation_tree["parameters/conditions/catch_is_charging_left"] = false
#		animation_tree["parameters/conditions/catch_jump_left"] = true
#	else:
#		animation_tree["parameters/conditions/is_charging"] = false
#		animation_tree["parameters/conditions/jump"] = true
#
#var triggered_jump_direction : DIRECTIONS 
#
#func jump():
#	if catched:
#		animation_tree["parameters/conditions/catch_jump_left"] = false
#		animation_tree["parameters/conditions/is_flying"] = true
#		uncatch()
#	else:
#		animation_tree["parameters/conditions/jump"] = false
#		animation_tree["parameters/conditions/is_flying"] = true
#
#	var direction : Vector2
#
#	if triggered_jump_direction == DIRECTIONS.LEFT:
#		direction = Vector2(-3, -5)
#		print("jump released left")
#		## TODO jump left animation + particles
#	elif triggered_jump_direction == DIRECTIONS.RIGHT:
#		direction = Vector2(3, -5)
#		print("jump released right")
#		## TODO jump right animation + particles
#	elif triggered_jump_direction == DIRECTIONS.UP:
#		direction = Vector2(0, -7)
#		print("jump release up")
#		## TODO jump up animation + particles
#
#	apply_central_impulse(direction * jump_strength)
#	$Charge_timer.stop()
#	jump_strength = 0
#
#func flying_check():
#	if !is_on_ground:
#		left_the_ground = true
#
#	if is_on_ground and left_the_ground:
#		animation_tree["parameters/conditions/is_flying"] = false
#		animation_tree["parameters/conditions/land"] = true
#		left_the_ground = false
#	elif catched:
#		animation_tree["parameters/conditions/is_flying"] = false
#		animation_tree["parameters/conditions/catch_left"] = true
#
#func _on_animation_tree_animation_finished(anim_name):
#	if anim_name == "Land":
#		animation_tree["parameters/conditions/land"] = false
#		animation_tree["parameters/conditions/idle"] = true
#	elif anim_name == "Catch":
#		animation_tree["parameters/conditions/catch_left"] = false
#		animation_tree["parameters/conditions/catch_idle_left"] = true
#
#func catch():
#	if on_catchable_object and !catched:
#		linear_velocity = Vector2(0, 0)
#		catched = true
#		gravity_scale = 0.0
#
#func uncatch():
#	if on_catchable_object and catched:
#		catched = false
#		gravity_scale = 1.0
#		animation_tree["parameters/conditions/catch_idle_left"] = false
#		animation_tree["parameters/conditions/is_flying"] = true
#
#func check_if_on_ground():
#	is_on_ground = !$Ground_detector.get_overlapping_bodies().is_empty()
