extends CharacterBody2D

signal ate_food
signal hit_obstacle

const MOVE_SPEED: float = 20.0 # The size of one grid cell
@onready var move_timer: Timer = $MoveTimer

var direction: Vector2 = Vector2.RIGHT
var next_direction: Vector2 = Vector2.RIGHT
var body_segments: Array[Sprite2D] = []
var body_segment_scene: PackedScene = preload("res://scenes/SnakeBody.tscn")

func _ready():
	move_timer.start()
	# Add initial body segments
	add_body_segment(position - Vector2(20, 0))
	add_body_segment(position - Vector2(40, 0))

func _unhandled_input(event):
	if event.is_action_pressed("ui_right") and direction != Vector2.LEFT:
		next_direction = Vector2.RIGHT
	elif event.is_action_pressed("ui_left") and direction != Vector2.RIGHT:
		next_direction = Vector2.LEFT
	elif event.is_action_pressed("ui_up") and direction != Vector2.DOWN:
		next_direction = Vector2.UP
	elif event.is_action_pressed("ui_down") and direction != Vector2.UP:
		next_direction = Vector2.DOWN

func _on_move_timer_timeout():
	move()

func move():
	direction = next_direction
	
	var last_position = position
	var new_head_position = position + direction * MOVE_SPEED
	
	# Check for wall collision
	var game_area = get_parent().get_node("GameArea").get_rect()
	if not game_area.has_point(new_head_position):
		hit_obstacle.emit()
		set_physics_process(false) # Stop moving
		return

	# Move body segments
	if body_segments.size() > 0:
		var last_segment = body_segments.pop_back()
		get_parent().remove_child(last_segment)
		last_segment.queue_free()
		
		var new_segment = body_segment_scene.instantiate()
		new_segment.position = last_position
		body_segments.insert(0, new_segment)
		get_parent().add_child(new_segment)

	position = new_head_position
	
	# Check for self collision
	for segment in body_segments:
		if position.distance_to(segment.position) < 1:
			hit_obstacle.emit()
			set_physics_process(false)
			return

func _on_area_2d_body_entered(body):
	if body.is_in_group("food"):
		body.queue_free()
		grow()
		ate_food.emit()

func grow():
	var last_segment_pos = position
	if body_segments.size() > 0:
		last_segment_pos = body_segments[-1].position
	add_body_segment(last_segment_pos)

func add_body_segment(pos: Vector2):
	var new_segment = body_segment_scene.instantiate()
	new_segment.position = pos
	body_segments.append(new_segment)
	get_parent().add_child(new_segment)

func get_body_segments() -> Array[Sprite2D]:
	return body_segments