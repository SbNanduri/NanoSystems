extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	pass

func spawn_follower(bot_number):
	var follower = PathFollow2D.new()
	follower.name = "bot_follower_%s" % bot_number
	print(follower.position)
	
	follower.unit_offset += 0.1