extends Navigation2D


const HEART_POSITION = Vector2(873, 166)


signal path_generated


func _ready():
	pass


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func place_destination(current_bot_pos, approximate_destination, bot_id, current_region):
	var actual_destination
	var position_node
	var min_distance = 99999
	var distance
	
	var bot_destinations = []
	
	for bot in get_tree().get_nodes_in_group("nanobots"):
		if bot.id != bot_id:
			bot_destinations.append(bot.actual_destination)
	
	
	for pos in get_tree().get_nodes_in_group("BotPositions"):
		distance = pos.position.distance_to(approximate_destination)
		
		if (distance < min_distance) and not (pos.position in bot_destinations):
			min_distance = distance
			actual_destination = pos.position
			position_node = pos
	
	# If there are more nanobots than positions, the position_node will be null
	if position_node != null:

		var destination_region = position_node.get_parent().get_parent().name
	
		if destination_region == current_region:
			var path = get_simple_path(current_bot_pos, actual_destination)
			path.remove(0)
			emit_signal("path_generated", path, position_node, bot_id)
		else:
			var path_to_heart = get_simple_path(current_bot_pos, HEART_POSITION)
			var path_from_heart = get_simple_path(HEART_POSITION, actual_destination)
			path_to_heart.remove(0)
			for i in range(10):
				path_from_heart.insert(0, path_from_heart[0])
			emit_signal("path_generated", [path_to_heart, path_from_heart], position_node, bot_id)
		
	
	
	
	
	
	
	
	
	
	
	