class_name DeadlandPlayer
extends CharacterBody2D

signal health_changed(value: int)
signal state_changed(value: String)

@export var walk_speed := 190.0
@export var run_speed := 310.0
@export var acceleration := 1500.0
@export var friction := 1900.0
@export var jump_velocity := -560.0
@export var gravity := 1500.0
@export var max_health := 100
var health := 100
var state := "idle"
var facing := 1
var coyote_time := 0.0
var jump_buffer := 0.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	health = max_health
	_build_animations()
	_set_state("idle")
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"): jump_buffer = 0.12
	else: jump_buffer = max(jump_buffer - delta, 0.0)
	if is_on_floor(): coyote_time = 0.1
	else:
		coyote_time = max(coyote_time - delta, 0.0)
		velocity.y += gravity * delta
	var axis := Input.get_axis("move_left", "move_right")
	var sprint := Input.is_action_pressed("run") and axis != 0.0
	var target := axis * (run_speed if sprint else walk_speed)
	velocity.x = move_toward(velocity.x, target, (acceleration if axis != 0.0 else friction) * delta)
	if jump_buffer > 0.0 and coyote_time > 0.0:
		velocity.y = jump_velocity
		jump_buffer = 0.0
		coyote_time = 0.0
	if axis != 0.0:
		facing = 1 if axis > 0.0 else -1
		sprite.flip_h = facing < 0
	move_and_slide()
	_update_state(axis, sprint)
	if Input.is_action_just_pressed("attack"): attack()
	if Input.is_action_just_pressed("shoot"): shoot()

func _update_state(axis: float, sprint: bool) -> void:
	var next := "idle"
	if not is_on_floor(): next = "jump" if velocity.y < 0.0 else "fall"
	elif abs(velocity.x) > 8.0: next = "run" if sprint else "walk"
	_set_state(next)

func _set_state(next: String) -> void:
	if next == state and sprite.animation == next: return
	state = next
	if sprite.sprite_frames.has_animation(next): sprite.play(next)
	state_changed.emit(state)

func _build_animations() -> void:
	var frames := {
		"idle": ["player_0_0"], "walk": ["player_0_1", "player_0_2"],
		"run": ["player_0_2", "player_0_3"], "jump": ["player_0_3"],
		"fall": ["player_1_0"], "attack": ["player_1_1"],
		"shoot": ["player_1_2"], "damage": ["player_1_3"], "death": ["player_1_3"]
	}
	for animation in frames:
		sprite.sprite_frames.add_animation(animation)
		sprite.sprite_frames.set_animation_speed(animation, 8.0 if frames[animation].size() > 1 else 1.0)
		sprite.sprite_frames.set_animation_loop(animation, animation in ["idle", "walk", "run"])
		for file_name in frames[animation]: sprite.sprite_frames.add_frame(animation, load("res://assets/" + file_name + ".png"))

func attack() -> void:
	_set_state("attack")
	await get_tree().create_timer(0.16).timeout
	for body in get_tree().get_nodes_in_group("zombies"):
		if global_position.distance_to(body.global_position) < 105.0 and sign(body.global_position.x - global_position.x) == facing: body.take_damage(25)
	await get_tree().create_timer(0.22).timeout
	if state == "attack": _set_state("idle")

func shoot() -> void:
	if int(get_meta("ammo", 7)) <= 0: return
	set_meta("ammo", int(get_meta("ammo", 7)) - 1)
	_set_state("shoot")
	var query := PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(facing * 700.0, 0.0), 4)
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if hit and hit.collider.is_in_group("zombies"): hit.collider.take_damage(34)
	await get_tree().create_timer(0.25).timeout
	if state == "shoot": _set_state("idle")

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	health_changed.emit(health)
	if health == 0:
		_set_state("death")
		set_physics_process(false)
	else:
		_set_state("damage")
		await get_tree().create_timer(0.2).timeout
		if health > 0: _set_state("idle")
