extends Node

var path_points = {}
var testing_follower = PathFollow2D.new()
var checking_path = false

var points_taken = []
const MIN_DEST_DIST = 10

onready var bot_follower = preload("res://bot_follower.tscn")

func _ready():
	for path in get_node("../Paths").get_children():
		path_points[path.name] = path.curve.get_baked_points()

func _physics_process(delta):
	for follower in get_tree().get_nodes_in_group("followers"):
		
		var test_pos = follower.position
		
		if follower.travelling:
			# Reparent the follower to a different path if the destination is along that path
			if (follower.get_parent().name != follower.chosen_path) and (follower.unit_offset == 0):
				follower.get_parent().remove_child(follower)
				get_node("../Paths/%s" % follower.chosen_path).add_child(follower)
				follower.set_owner(get_node("../Paths/%s" % follower.chosen_path))
				follower.current_path = follower.chosen_path

			if follower.current_path != follower.chosen_path:
				follower.offset -= abs(follower.speed)
				follower.should_go_forwards = null

			elif follower.should_go_forwards == null:
				"""
				if should_go_forwards is null, then we don't know if the follower should go forwards or backwards to 
				reach the destination. Therefore, a testing_follower is added to check the offset value at the closest
				point to the destination, and if the checked offset value is less than the bot_follower offset value,
				then we know that the destination is behind the bot_follower and so it has to go backwards. If it is
				greater than the bot_follower offset, the bot_follower has to go forwards.
				"""
				
				if testing_follower.get_parent() != null:
					testing_follower.get_parent().remove_child(testing_follower)
				get_node("../Paths/%s" % follower.chosen_path).add_child(testing_follower)
				testing_follower.offset = 0

				var testing_distance
				var smallest_testing_distance = 2000
				
				# Checking the distance between each point along the path and the actual destination. The unit offset of the testing_follower is then set to be the point at which the distance is the smallest
				for point in range(0, len(path_points[follower.current_path])):
					testing_distance = sqrt(pow((path_points[follower.current_path][point].x - follower.actual_destination.x), 2) + pow((path_points[follower.current_path][point].y - follower.actual_destination.y), 2))
					if testing_distance < smallest_testing_distance:
						smallest_testing_distance = testing_distance
						testing_follower.unit_offset = float(point)/len(path_points[follower.current_path])
				
				# Compares the test offset to the follower offset and if it is less than it, then the follower has to go backwards to reach it, so the should_go_forwards is false
				if testing_follower.offset < follower.offset:
					follower.should_go_forwards = false
				else:
					follower.should_go_forwards = true
			
			# if the follower should go forwards, then the offset is added to, otherwise it is taken away.
			elif follower.should_go_forwards:
				follower.offset += follower.speed
				if follower.unit_offset > 1:
					follower.unit_offset = 1
			else:
				follower.offset -= follower.speed
			
			var old_distance = sqrt(pow((test_pos.x - follower.actual_destination.x), 2) + pow((test_pos.y - follower.actual_destination.y), 2))
			var new_distance = sqrt(pow((follower.position.x - follower.actual_destination.x), 2) + pow((follower.position.y - follower.actual_destination.y), 2))
			
			if new_distance < 12:
				"""
				When the follower gets close enough to the destination, it is safe to assume that if the current distance 
				to the destination is less than the last distance, the follower is going in the right direction.
				
				If the follower was too far, it might be possible that the distance might need to increase temporarily before
				getting smaller again when getting closer to the destination, that is why the distances were not compared 
				before the follower got close 
				"""
				
				if old_distance - new_distance < 0:
					follower.offset -= follower.speed
					follower.travelling = false
					follower.should_go_forwards = null
					

func spawn_follower(bot_number):
	var follower_instance = bot_follower.instance()
	follower_instance.name = "bot_follower_%s" % bot_number
	follower_instance.id = bot_number
	follower_instance.current_path = 'LeftArm'
	get_node("../Paths/LeftArm").add_child(follower_instance)
	
	points_taken.append(null)

func place_destination(approx_destination, bot_id):
	"""
	When the destination_active signal is emitted by NanoBot.gd, it ends the mouse position as the destination,
	and the bot's id. This method then finds the closest point to the destination that is on a path and makes 
	that point the actual destination that the bot must travel to.
	"""
	
	var actual_destination
	var chosen_path
	
	var distance = 2000
	var dist_check		# Temporary distance value to check with the existing distance value to see which is smaller
	
	for path_name in path_points:
		for point_index in range(len(path_points[path_name])):
			dist_check = sqrt(pow((path_points[path_name][point_index].x - approx_destination.x), 2) + pow((path_points[path_name][point_index].y - approx_destination.y), 2))

			if (dist_check < distance):
				distance = dist_check
				actual_destination = path_points[path_name][point_index]
				chosen_path = path_name
					
	for follower in get_tree().get_nodes_in_group("followers"):
		if follower.id == bot_id:
			follower.actual_destination = actual_destination
			follower.chosen_path = chosen_path				# The path that the follower should be on to reach the destination eg. LeftArm, or RightArm
				
				
				
	