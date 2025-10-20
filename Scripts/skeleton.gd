extends CharacterBody2D
class_name Inimigo

@export var speed: float = 40
@export var max_health: int = 50
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.5
@export var attack_range: float = 25
@export var player: Player

@onready var animation: AnimatedSprite2D = $Sprite

var player_chase: bool = false
var is_attacking: bool = false
var attack_timer: Timer
var health: int = max_health

# Knockback suave
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_duration: float = 0.15
var knockback_timer: float = 0.0
var knockback_force: float = 200

func _ready() -> void:
	# Timer de cooldown do ataque
	attack_timer = Timer.new()
	add_child(attack_timer)
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))

func _physics_process(_delta: float) -> void:
	# Aplica knockback se houver
	if knockback_timer > 0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.2)
		knockback_timer -= _delta
	else:
		velocity = Vector2.ZERO
		if player_chase and player:
			var direction = player.position - position
			var distance_to_player = direction.length()
			if distance_to_player > attack_range + 5 and not is_attacking:
				velocity = direction.normalized() * speed
				animation.play("walk")
				animation.flip_h = direction.x < 0
			elif distance_to_player <= attack_range and not is_attacking and attack_timer.is_stopped():
				attack_player()
			else:
				if not is_attacking:
					animation.play("idle")
		else:
			if not is_attacking:
				animation.play("idle")

	move_and_slide()

func _on_detection_area_body_entered(body: Node) -> void:
	if body is Player:
		player = body
		player_chase = true

func _on_detection_area_body_exited(body: Node) -> void:
	if body == player:
		player = null
		player_chase = false

# Ataque do inimigo
func attack_player() -> void:
	if player and attack_timer.is_stopped():
		is_attacking = true
		velocity = Vector2.ZERO
		animation.play("attack")

		var hit_timer = Timer.new()
		hit_timer.wait_time = 0.3
		hit_timer.one_shot = true
		add_child(hit_timer)
		hit_timer.start()

		await hit_timer.timeout
		hit_timer.queue_free()

		if player and (player.position - position).length() <= attack_range:
			player.take_damage(attack_damage, self)  # Passa self para knockback

		attack_timer.start()

func _on_attack_timer_timeout() -> void:
	is_attacking = false

# Receber dano do player com knockback suave
func take_damage(amount: int, attacker: Player) -> void:
	health -= amount
	print("Inimigo tomou ", amount, " de dano! Vida atual: ", health)

	if health <= 0:
		die()
	elif attacker:
		var knock_dir = (position - attacker.position).normalized()
		knockback_velocity = knock_dir * knockback_force
		knockback_timer = knockback_duration

func die() -> void:
	print("Inimigo morreu!")
	queue_free()
