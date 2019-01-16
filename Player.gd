extends KinematicBody2D

const DEFAULT_VALUES = {'max speed': 200, 'acceleration': 50, 
'floor friction': 0.2, 'air friction': 0.001, 
'jump': 500, 'hold': 0, 'strength': 10, 'gravity': 35}

const MAX_MOD = {'max speed': 500, 'acceleration': 100, 'jump': 1000}			# The maximum values for the various attributes

const UPPER_LEG_MOD = {'max speed': 25, 'acceleration': 25, 'floor friction': 0.2, 'air friction': 0.05, 'jump': 75}		# The modifiers for the upper leg
const LOWER_LEG_MOD = {'max speed': 75, 'acceleration': 25, 'jump': 25}		# The modifiers for the upper leg
const FOOT_MOD = {'max speed': 10, 'acceleration': 10, 'jump': 10}		# The modifiers for the foot


const HAND_MOD = {'hold': 1, 'strength': 10}		# The modifiers for the hand

var current_values = {'max speed': DEFAULT_VALUES['max speed'], 'acceleration': DEFAULT_VALUES['acceleration'], 
					  'floor friction': DEFAULT_VALUES['floor friction'], 'air friction': DEFAULT_VALUES['air friction'], 
					  'jump': DEFAULT_VALUES['jump'], 'hold': DEFAULT_VALUES['hold'], 'strength': DEFAULT_VALUES['strength'],
					'gravity': DEFAULT_VALUES['gravity']}



var motion = Vector2()

func _ready():
	print("Max Speed: ", current_values['max speed'], " Jump: ", current_values['jump'] )
	print("Hold: ", current_values['hold'])
	
func _physics_process(delta):
	self.motion.y += current_values['gravity']
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		self.motion.y = -current_values['jump']
	
	
	
	if is_on_floor():
		x_movement(current_values['acceleration'], current_values['max speed'], current_values['floor friction'])
	
	elif not (is_on_ceiling() or is_on_wall()):
		var slowed_motion = lerp(motion.x, 0, current_values['air friction'])
		if self.motion.x > 0:
			motion.x = floor(slowed_motion)
		else:
			motion.x = ceil(slowed_motion)
	
	if is_on_ceiling():
		self.motion.y = 0
		if current_values['hold'] and not Input.is_key_pressed(KEY_S):
			motion.x = 0
			self.motion.y = -10*current_values['gravity']
			if current_values['hold'] == 2:
				# Make this a function of strength
				x_movement(current_values['acceleration'], current_values['max speed'], current_values['floor friction'])
	
	if test_move(transform, Vector2(1, 0)) and Input.is_key_pressed(KEY_D):
		motion.x += 10
	elif test_move(transform, Vector2(-1, 0)) and Input.is_key_pressed(KEY_A):
		motion.x -= 10
		
	if is_on_wall():
		motion.x = 0
		var key_to_release
		if get_slide_collision(0).normal.x < 0:
			key_to_release = KEY_A
		else:
			key_to_release = KEY_D
		
		if current_values['hold'] and (not Input.is_key_pressed(key_to_release)) and not (Input.is_key_pressed(KEY_S) and is_on_floor()):
			self.motion.x = -200*get_slide_collision(0).normal.x
			self.motion.y = 0
			if current_values['hold'] == 1:
				wall_climbing(1, current_values['acceleration'], current_values['max speed'])
			if current_values['hold'] == 2:
				# Make this a function of strength
				wall_climbing(2, current_values['acceleration'], current_values['max speed'])
		
		elif Input.is_key_pressed(key_to_release):
			if key_to_release == KEY_A:
				motion.x -= current_values['jump']
			elif key_to_release == KEY_D:
				motion.x += current_values['jump']
			if (current_values['hold'] == 2) and Input.is_action_pressed("jump"):
				motion.y -= current_values["jump"]
	
	move_and_slide(motion, Vector2(0, -1))
	
	# Has to be called after move_and_slide because if it is called before, is_on_floor alternates between true and false if standing on ground
	if is_on_floor():
		motion.y = 0


func x_movement(acceleration, max_speed, friction):
	if Input.is_key_pressed(KEY_D) and not Input.is_key_pressed(KEY_A):
		self.motion.x = min(motion.x + acceleration, max_speed)
	elif Input.is_key_pressed(KEY_A) and not Input.is_key_pressed(KEY_D):
		self.motion.x = max(motion.x - acceleration, -max_speed)
	if (not is_on_wall()) or (Input.is_key_pressed(KEY_A) and Input.is_key_pressed(KEY_D)):
		var slowed_motion = lerp(motion.x, 0, friction)
		# ceil and floor are used because of pixel graphics, so that the pixels stay in the grid
		if self.motion.x > 0:
			motion.x = floor(slowed_motion)
		else:
			motion.x = ceil(slowed_motion)

func wall_climbing(holding_value, acceleration, max_speed):
	if holding_value == 1:
		if Input.is_key_pressed(KEY_S):
			self.motion.y = min(motion.y + acceleration, max_speed)
	
	if holding_value == 2:
		if Input.is_key_pressed(KEY_S) and not Input.is_key_pressed(KEY_W):
			self.motion.y = min(motion.y + acceleration, max_speed)
		elif Input.is_key_pressed(KEY_W) and not Input.is_key_pressed(KEY_S):
			self.motion.y = max(motion.y - acceleration, -max_speed)
		if (Input.is_key_pressed(KEY_S) and Input.is_key_pressed(KEY_W)):
			self.motion.y = 0


func change_properties_entered(part):
	if (part == 'RightUpperLeg') or (part == 'LeftUpperLeg'):
		current_values['max speed'] += UPPER_LEG_MOD['max speed']
		current_values['acceleration'] += UPPER_LEG_MOD['acceleration']
		current_values['jump'] += UPPER_LEG_MOD['jump']
		
	elif (part == 'RightLowerLeg') or (part == 'LeftLowerLeg'):
		current_values['max speed'] += LOWER_LEG_MOD['max speed']
		current_values['acceleration'] += LOWER_LEG_MOD['acceleration']
		current_values['jump'] += LOWER_LEG_MOD['jump']
		
	elif (part == 'RightFoot') or (part == 'LeftFoot'):
		current_values['max speed'] += FOOT_MOD['max speed']
		current_values['acceleration'] += FOOT_MOD['acceleration']
		current_values['jump'] += FOOT_MOD['jump']
	
	elif (part == 'RightHand') or (part == 'LeftHand'):
		current_values['strength'] += HAND_MOD['strength']
		current_values['hold'] += HAND_MOD['hold']
	
	print("Max Speed: ", current_values['max speed'], " Jump: ", current_values['jump'] )
	print("Hold: ", current_values['hold'])
	
func change_properties_exited(part):
	if (part == 'RightUpperLeg') or (part == 'LeftUpperLeg'):
		current_values['max speed'] -= UPPER_LEG_MOD['max speed']
		current_values['acceleration'] -= UPPER_LEG_MOD['acceleration']
		current_values['jump'] -= UPPER_LEG_MOD['jump']
	
	elif (part == 'RightLowerLeg') or (part == 'LeftLowerLeg'):
		current_values['max speed'] -= LOWER_LEG_MOD['max speed']
		current_values['acceleration'] -= LOWER_LEG_MOD['acceleration']
		current_values['jump'] -= LOWER_LEG_MOD['jump']
	
	elif (part == 'RightFoot') or (part == 'LeftFoot'):
		current_values['max speed'] -= FOOT_MOD['max speed']
		current_values['acceleration'] -= FOOT_MOD['acceleration']
		current_values['jump'] -= FOOT_MOD['jump']
		
	elif (part == 'RightHand') or (part == 'LeftHand'):
		current_values['strength'] -= HAND_MOD['strength']
		current_values['hold'] -= HAND_MOD['hold']
		
	print("Max Speed: ", current_values['max speed'], " Jump: ", current_values['jump'])
	print("Hold: ", current_values['hold'])
		
		