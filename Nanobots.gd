extends Node

onready var bot = preload("res://NanoBot.tscn")

signal bot_spawned

func _process(delta):
#	print(get_viewport().get_mouse_position())
	if Input.is_action_just_released("scroll_up"):
		var bot_instance = bot.instance()
		var bot_count = get_child_count()
		bot_instance.set_name("bot_%s" % bot_count)
		bot_instance.id = bot_count
		bot_instance.position = Vector2(875, 251)
		add_child(bot_instance)
		emit_signal("bot_spawned", bot_count)
	
	if Input.is_action_just_released("scroll_down") and get_child_count():
		var bot_to_delete = get_child(get_child_count() - 1)
		if bot_to_delete.position_node != null:
			bot_to_delete.emit_signal("position_exited", bot_to_delete.position_node.get_parent().name)
		bot_to_delete.queue_free()