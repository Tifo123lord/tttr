class_name DeadlandZombie
extends CharacterBody2D

@export var speed := 68.0
@export var max_health := 100
var health := 100
var attack_cooldown := 0.0
var idle_clock := 0.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	health = max_health
	_build_animations()
	sprite.play("idle")
	add_to_group("zombies")

func _physics_process(delta: float) -> void:
	attack_cooldown = max(attack_cooldown - delta, 0.0)
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not player: return
	var offset := player.global_position - global_position
	if offset.length() > 60.0 and offset.length() < 700.0:
		velocity.x = move_toward(velocity.x, sign(offset.x) * speed, 500.0 * delta)
		sprite.flip_h = velocity.x < 0.0
		sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0.0, 800.0 * delta)
		sprite.play("idle")
		if offset.length() <= 60.0 and attack_cooldown <= 0.0:
			player.take_damage(8); attack_cooldown = 1.1
	move_and_slide()

func _build_animations() -> void:
	for name in ["idle", "walk", "hit", "death"]:
		sprite.sprite_frames.add_animation(name)
		sprite.sprite_frames.set_animation_loop(name, name in ["idle", "walk"])
		sprite.sprite_frames.set_animation_speed(name, 7.0)
	for i in range(6): sprite.sprite_frames.add_frame("walk", load("res://assets/zombie_%d.png" % i))
	sprite.sprite_frames.add_frame("idle", load("res://assets/zombie_0.png"))
	sprite.sprite_frames.add_frame("hit", load("res://assets/zombie_2.png"))
	sprite.sprite_frames.add_frame("death", load("res://assets/zombie_5.png"))

func take_damage(amount: int) -> void:
	health -= amount
	sprite.play("hit")
	if health <= 0:
		sprite.play("death")
		set_physics_process(false)
		await get_tree().create_timer(0.35).timeout
		queue_free()
