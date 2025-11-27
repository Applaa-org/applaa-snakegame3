extends Node

var score: int = 0
const VICTORY_SCORE = 100 # 10 food items at 10 points each

func add_score(points: int):
	score += points

func reset_score():
	score = 0