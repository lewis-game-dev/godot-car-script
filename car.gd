extends KinematicBody

export var max_speed = 20
export var acceleration = 0.2
export var rotation_speed = 1.0
export var max_wheel_rotation = 25

export (NodePath) var back_right_wheel
export (NodePath) var back_left_wheel
export (NodePath) var front_right_wheel
export (NodePath) var front_left_wheel
export (NodePath) var floor_front_cast

export var button_up = "up"
export var button_down = "down"
export var button_left = "left"
export var button_right = "right"

var speed = 0
var grav = 1
var wheel_dampen = 0
var scale_object
var floor_normal

var fr_wheel_start_rotation
var fl_wheel_start_rotation

func _input(event):
	if event is InputEventMouseMotion:
		$Camera.rotation_degrees.y -= event.relative.x*0.3
		
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
func _ready():
	scale_object = scale
	
	fr_wheel_start_rotation = get_node(front_right_wheel).rotation_degrees.y
	fl_wheel_start_rotation = get_node(front_left_wheel).rotation_degrees.y
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector3()
	wheel_dampen = speed/30
	if wheel_dampen > 1.5:
		wheel_dampen = 1.5
	
	#this is for controllers
	var left_amount = Input.get_action_strength(button_left)
	var right_amount = Input.get_action_strength(button_right)
	var up_amount = Input.get_action_strength(button_up)
	var down_amount = Input.get_action_strength(button_down)
	
	#this is for rotating the car according to the floor
	if get_node_or_null(floor_front_cast) and is_on_floor():
		floor_normal = get_node(floor_front_cast).get_collision_normal()
		if get_node(floor_front_cast).is_colliding():
			global_transform.basis.y = lerp(global_transform.basis.y,get_node(floor_front_cast).get_collision_normal(),0.01)
			scale = scale_object
			
				
				
				
	if not is_on_floor():
		rotation_degrees.x = lerp(rotation_degrees.x,-90,0.005)
	
	#this is for move foward and backwards
	if is_on_floor():
		if Input.is_action_pressed(button_up):
			if speed < max_speed:
				speed += acceleration*2 * up_amount
			
		if Input.is_action_pressed(button_down):
			if speed > 0:
				speed -= acceleration*4 * down_amount
				
			else:
				if speed > -max_speed:
					speed -= acceleration * down_amount

	if not Input.is_action_pressed(button_up):
		if speed < 0:
			speed += acceleration/2
			
	if  not Input.is_action_pressed(button_down):
		if speed > 0:
			speed -= acceleration/2
				
	if not Input.is_action_pressed(button_up) and not Input.is_action_pressed(button_down):
		if speed <= 1 and speed >= -1:
			speed = 0

	#this is for moving left and right
	if speed >= 1 or speed <= -1 and is_on_floor() and get_node(floor_front_cast).is_colliding():
		if Input.is_action_pressed(button_left):
			rotation_degrees.y += rotation_speed * left_amount * wheel_dampen
		
		elif Input.is_action_pressed(button_right):
			rotation_degrees.y -= rotation_speed * right_amount * wheel_dampen
			
		
	#this is for moving the wheels	
	if get_node_or_null(front_left_wheel) and get_node_or_null(front_right_wheel) and get_node_or_null(back_left_wheel) and get_node_or_null(back_right_wheel):
		
		get_node(front_left_wheel).rotation_degrees.x -= speed
		get_node(front_right_wheel).rotation_degrees.x -= speed
		get_node(back_left_wheel).rotation_degrees.x -= speed
		get_node(back_right_wheel).rotation_degrees.x -= speed
		
		if Input.is_action_pressed(button_left):

			if get_node(front_left_wheel).rotation_degrees.y < max_wheel_rotation:
				get_node(front_left_wheel).rotation_degrees.y += 2 * left_amount
				get_node(front_right_wheel).rotation_degrees.y += 2 * left_amount

		elif Input.is_action_pressed(button_right):

			if get_node(front_left_wheel).rotation_degrees.y > -max_wheel_rotation:
				get_node(front_left_wheel).rotation_degrees.y -= 2 * right_amount
				get_node(front_right_wheel).rotation_degrees.y -= 2 * right_amount

		if not Input.is_action_pressed(button_left) and not Input.is_action_pressed(button_right):
			if get_node(front_left_wheel).rotation_degrees.y > 0:
				get_node(front_left_wheel).rotation_degrees.y -= 2
				get_node(front_right_wheel).rotation_degrees.y -= 2

			if get_node(front_left_wheel).rotation_degrees.y < 0:
				get_node(front_left_wheel).rotation_degrees.y += 2
				get_node(front_right_wheel).rotation_degrees.y += 2

	#gravity
	velocity.y += grav
	
	if is_on_floor():
		grav = -1
	else:
		grav -= 0.2
	
	velocity -= transform.basis.z*speed
	move_and_slide_with_snap(velocity,Vector3.DOWN,Vector3.UP, true)
