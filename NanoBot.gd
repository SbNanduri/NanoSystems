extends KinematicBody2D

var just_selected = false
var selected = false
var stopped = true

var id = 0

var approximate_destination
var actual_destination

var current_region_path = PoolVector2Array()
var current_region

var new_region_path = PoolVector2Array()
var position_node		# The position node, e.g RightUpperLeg1, or RightUpperLeg2

export var speed = 100	# was 2

const DEST_WEIGHT = 0.1

signal destination_active
signal position_entered
signal position_exited

func _ready():
	if get_node("../../Selection") != null:
		get_node("../../Selection").connect("to_select", self, "select")
	approximate_destination = position
	

	
	# function to receive the path generated earlier by the CirculationNavigation node
	if get_node("../../Circulation/CirculationNavigation") != null:
		get_node("../../Circulation/CirculationNavigation").connect("path_generated", self, "get_path")
	
	# Connections to the player
	if get_tree().get_nodes_in_group("Player").size():
		var player = get_tree().get_nodes_in_group("Player")[0]
		connect("position_entered", player, "change_properties_entered")
		connect("position_exited", player, "change_properties_exited")


func _physics_process(delta):
	# The nanobot goes along the paths; the first path is in the same region (e.g RightLeg), and the second path is in another region (e.g LeftLeg)
	if current_region_path.size():
		current_region_path = move_along_path(current_region_path)
		
	elif new_region_path.size():
		current_region = position_node.get_parent().get_parent().name
		new_region_path = move_along_path(new_region_path)
		
	# This occurs right after the nanobot reaches the location and then stopped is toggled so that it doesn't activate again
	elif not stopped:
		stopped = true
		emit_signal("position_entered", position_node.get_parent().name)


func select(bot):
	if bot == self:
		selected = true
		$Sprite.modulate = Color(0.224,1,0.078)


func get_path(paths, pos_node, bot_id):
	if bot_id == id:
		
		stopped = false		# A path is received when the nanobot is about to start moving so the nanobot is no longer stopped
		
		# This is the position_node at the destination of the nanobot
		if position_node != null:
			emit_signal("position_exited", position_node.get_parent().name)
		position_node = pos_node
		
		# if paths is an array, then it contains a to heart path in one region and a from heart path in another region
		if typeof(paths) == typeof([]):
			current_region_path = paths[0]
			new_region_path = paths[1]
			actual_destination = paths[1][-1]
		
		# if paths is not an array, then it is one single path from one point to another in the same region (e.g RightLeg)
		else:
			current_region_path = paths
			actual_destination = paths[-1]
			new_region_path = PoolVector2Array()

func move_along_path(path):
	var gap = path[0] - position
	
	position += gap.normalized() * speed
	
	if position.distance_to(path[0]) <= speed:
		position = path[0]
		path.remove(0)
	
	return path



		
		