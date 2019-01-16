extends Camera2D

export var zoom_amount = 1.2

func _ready():
	pass

func _process(delta):
	# Arrow Inputs
	if Input.is_key_pressed(KEY_UP):
		self.position.y -= 10
#		print("Hello")
	if Input.is_key_pressed(KEY_DOWN):
		self.position.y += 10
#		print("Bellow")
	if Input.is_key_pressed(KEY_LEFT):
		self.position.x -= 10
	if Input.is_key_pressed(KEY_RIGHT):
		self.position.x += 10
	
	
func _input(event):
	if (event is InputEventMouseMotion) and Input.is_mouse_button_pressed(BUTTON_MIDDLE):
		position -= event.relative * zoom[0]
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			#zoom in
			if event.button_index == BUTTON_WHEEL_UP:
				zoom /= zoom_amount
				
				#Camera shift to account for zoom
				position += (get_global_mouse_position() - position) * (zoom_amount - 1)
			
			#zoom out
			if event.button_index == BUTTON_WHEEL_DOWN:
				#Camera shift to account for zoom
				position -= (get_global_mouse_position() - position) * (zoom_amount - 1)
				
				zoom *= zoom_amount
				