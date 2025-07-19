# We want one empty line between groups of exported properties, plain variables, and onready variables.
class_name Player extends CharacterBody2D
@export var speed := 200
@export var jump_velocity := -400
var start_health := 100
var current_health := 100
@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	health_bar.max_value = start_health
	health_bar.value = current_health
