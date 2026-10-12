extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var health_bar: ProgressBar = $HUD/Health
@onready var state_label: Label = $HUD/State

func _ready() -> void:
	player.health_changed.connect(_on_health_changed)
	player.state_changed.connect(_on_state_changed)
	_on_health_changed(player.health)

func _on_health_changed(value: int) -> void:
	health_bar.value = value

func _on_state_changed(value: String) -> void:
	state_label.text = "STATE  " + value.to_upper()
