extends Control

var destination_rect

const APPROX_VALUE = 1

export var rect_dim = Vector2(10, 10)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func draw_destination(bot_pos, destination):
	# Draws a square at the destination of the NanoBot
	if (destination > (bot_pos + Vector2(APPROX_VALUE, APPROX_VALUE))) or \
		destination < (bot_pos - Vector2(APPROX_VALUE, APPROX_VALUE)):
		destination_rect = Rect2(destination - rect_dim/2, rect_dim)
	else:
		destination_rect = Rect2(Vector2(0, 0), Vector2(0, 0))
	update()

func _draw():
	if destination_rect != null:
		draw_rect(destination_rect, Color(1,0,0))