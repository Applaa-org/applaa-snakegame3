extends Node2D

@onready var snake: CharacterBody2D = $Snake
@onready var food_spawn_timer: Timer = $FoodSpawnTimer
@onready var score_label: Label = $UI/ScoreLabel
@onready var game_area: Rect2 = $GameArea.get_rect()

func _ready():
	Global.reset_score()
	update_score_label()
	snake.connect("ate_food", _on_snake_ate_food)
	snake.connect("hit_obstacle", _on_snake_hit_obstacle)
	spawn_food()

func update_score_label():
	score_label.text = "Score: %d" % Global.score

func spawn_food():
	var food_scene = preload("res://scenes/Food.tscn")
	var new_food = food_scene.instantiate()
	
	# Find a valid position away from the snake
	var valid_position = false
	while not valid_position:
		var x = snapped(randf_range(game_area.position.x, game_area.end.x), 20)
		var y = snapped(randf_range(game_area.position.y, game_area.end.y), 20)
		new_food.position = Vector2(x, y)
		
		# Check if position overlaps with snake body
		valid_position = true
		for segment in snake.get_body_segments():
			if segment.global_position.distance_to(new_food.position) < 10:
				valid_position = false
				break
	
	add_child(new_food)

func _on_snake_ate_food():
	Global.add_score(10)
	update_score_label()
	
	if Global.score >= Global.VICTORY_SCORE:
		get_tree().change_scene_to_file("res://scenes/VictoryScreen.tscn")
	else:
		spawn_food()

func _on_snake_hit_obstacle():
	get_tree().change_scene_to_file("res://scenes/DefeatScreen.tscn")