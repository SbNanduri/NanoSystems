extends Control

var active = false
var start_outside = false
var starting_corner = Vector2()
var opposite_corner = Vector2()
var box =Rect2()

var limit_pos
var limit_size
export var limit_extension = Vector2(10, 10)

signal to_select
signal destination_active

func _ready():
	# function to get the actual destination position and generate the path
	connect("destination_active", get_node("../Circulation/CirculationNavigation"), "place_destination")
	
	rect_size = get_viewport().get_visible_rect().size
	limit_pos = get_node("../Body").position - limit_extension
	limit_size = get_node("../Body").size + 2 * limit_extension

func _process(delta):
	create_box()
	generate_destinations()


func create_box():
	var mouse_pos = get_global_mouse_position()
	if Input.is_action_just_pressed("left_click"):
		if (mouse_pos - limit_pos) == (mouse_pos - limit_pos).abs():
			starting_corner = mouse_pos
		else:
			start_outside = true
	elif Input.is_action_pressed("left_click") and not start_outside:
		active = true
		if ((mouse_pos - limit_pos) == (mouse_pos - limit_pos).abs()) and \
			(((limit_pos + limit_size) - mouse_pos) == ((limit_pos + limit_size) - mouse_pos).abs()):
			opposite_corner = mouse_pos
		elif ((mouse_pos - limit_pos) != (mouse_pos - limit_pos).abs()) or \
			(((limit_pos + limit_size) - mouse_pos) != ((limit_pos + limit_size) - mouse_pos).abs()):
			# Change this so that it works for the right and bottom of the screen. (Find out the dimensions and stuff)
			var x = limit_pos.x
			var y = limit_pos.y
			var width = limit_size.x
			var height = limit_size.y
			
			if (mouse_pos.x > x) and (mouse_pos.x < x + width):
				x = mouse_pos.x
			if mouse_pos.y > y and (mouse_pos.y < y + height):
				y = mouse_pos.y
			
			if (mouse_pos.x > x + width):
				x = limit_pos.x + limit_size.x
			if (mouse_pos.y > y + height):
				y = limit_pos.y + limit_size.y
			
			opposite_corner = Vector2(x, y)
			
			
	elif Input.is_action_just_released("left_click"):
		active = false
		start_outside = false
		for bot in get_tree().get_nodes_in_group("nanobots"):
			bot.selected = false
	else:
		active = false
	
	if active:
		var left = min(starting_corner.x, opposite_corner.x)
		var top = min(starting_corner.y, opposite_corner.y)
		box = Rect2(Vector2(left, top), Vector2(abs(starting_corner.x - opposite_corner.x), abs(starting_corner.y - opposite_corner.y)))
		
	elif box != null:
		#Selection of the bots
		for bot in get_tree().get_nodes_in_group("nanobots"):
			var size = bot.get_child(1).shape.extents * bot.scale * bot.get_child(1).scale * 2		# Size of the collision box
			var bot_pos = bot.position - size/2			# bot.position gives the center of the NanoBot node so we subtract size/2 to find the top_left corner
			var bot_rect = Rect2(bot_pos, size)			#Constructs a rect given the top left corner and the width and height
			
#			if box.get_area() > 10:
			if box.encloses(bot_rect) or bot_rect.encloses(box):
				emit_signal("to_select", bot)
			else:
				bot.get_node("Sprite").modulate = Color(1, 1, 1)

#			elif box.get_area() < 50:
#				if bot_rect.encloses(box):
#					emit_signal("to_select", bot)

		
		box = null
		
	update()
	
	

func generate_destinations():
	if Input.is_action_just_pressed("right_click") and (get_global_mouse_position() == get_global_mouse_position().abs()):
		for bot in get_tree().get_nodes_in_group("nanobots"):
			if bot.selected:
				bot.selected = false
				bot.get_node("Sprite").modulate = Color(1,1,1)
				bot.approximate_destination = get_viewport().get_mouse_position()
				emit_signal("destination_active", bot.position, bot.approximate_destination, bot.id, bot.current_region)
		
		
		
		
		

func _draw():
#	draw_set_transform(get_global_transform().inverse()[2], 0, Vector2(1, 1))
	if box != null:
		draw_rect(box, Color(0.224,1,0.078), false)
		draw_rect(box, Color(0.224,1,0.078, 0.2))





