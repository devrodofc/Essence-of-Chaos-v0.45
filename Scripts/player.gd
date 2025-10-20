extends CharacterBody2D
class_name Player

@export var speed: float = 125
@export var max_health: int = 50
var health: int = max_health
@export var attack_damage: int = 25

@onready var animation: AnimationPlayer = $Animation
@onready var texture: Sprite2D = $Texture
@onready var attack_area: Area2D = $AttackArea

var is_attacking: bool = false
var dead: bool = false

var attack_finished_callback: Callable

# Guarda posição original do ataque (para flip)
var attack_area_original_x: float

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
var knockback_duration: float = 0.15
var knockback_force: float = 200

func _ready() -> void:
	attack_finished_callback = Callable(self, "_on_attack_finished")

	if attack_area:
		attack_area_original_x = attack_area.position.x
		attack_area.connect("body_entered", Callable(self, "_on_attack_area_body_entered"))
		attack_area.monitoring = false
	else:
		push_warning("⚠️ AttackArea não encontrado!")

func _physics_process(delta: float) -> void:
	if dead:
		return  # Nenhum processamento se estiver morto

	# Knockback
	if knockback_timer > 0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.3)
		knockback_timer -= delta
	else:
		_process_movement(delta)

	move_and_slide()

	_process_attack_input()

# ------------------ MOVIMENTO ------------------
func _process_movement(_delta: float) -> void:
	var direction := Input.get_vector("Left", "Right", "Up", "Down")

	if is_attacking:
		velocity = Vector2.ZERO
		return

	velocity = direction * speed

	if direction != Vector2.ZERO:
		animation.play("run")
		# Espelha sprite e área de ataque
		if direction.x < 0:
			texture.flip_h = true
			attack_area.position.x = -abs(attack_area_original_x)
		elif direction.x > 0:
			texture.flip_h = false
			attack_area.position.x = abs(attack_area_original_x)
	else:
		animation.play("idle")

# ------------------ ATAQUE ------------------
func _process_attack_input() -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking and not dead:
		start_attack()

func start_attack() -> void:
	is_attacking = true
	animation.play("attack")

	if not animation.is_connected("animation_finished", attack_finished_callback):
		animation.animation_finished.connect(attack_finished_callback)

	if attack_area:
		attack_area.monitoring = true

func _on_attack_finished(anim_name: String) -> void:
	if anim_name == "attack":
		is_attacking = false
		if animation.is_connected("animation_finished", attack_finished_callback):
			animation.animation_finished.disconnect(attack_finished_callback)
		if attack_area:
			attack_area.monitoring = false

func _on_attack_area_body_entered(body: Node) -> void:
	if body == self:
		return
	if is_attacking and body.has_method("take_damage"):
		body.take_damage(attack_damage, self)
		print("💥 Machadada! Dano causado:", attack_damage)

# ------------------ DANO E MORTE ------------------
func take_damage(amount: int, attacker: Node = null) -> void:
	if dead:
		return

	health -= amount
	print("💢 Player tomou ", amount, " de dano! Vida atual:", health)

	if health <= 0:
		die()
		return

	if attacker:
		apply_knockback(attacker)

func apply_knockback(attacker: Node) -> void:
	var knock_dir: Vector2 = (position - attacker.position).normalized()
	knockback_velocity = knock_dir * knockback_force
	knockback_timer = knockback_duration

func die() -> void:
	if dead:
		return
	dead = true
	is_attacking = false
	velocity = Vector2.ZERO
	if attack_area:
		attack_area.monitoring = false

	print("☠️ Player morreu!")
	animation.play("death")

	# Bloqueia controles
	set_physics_process(false)
	set_process_input(false)

	# Espera animação terminar antes de mostrar tela
	animation.animation_finished.connect(_on_death_animation_finished)

func _on_death_animation_finished(anim_name: String) -> void:
	if anim_name == "death":
		_show_death_screen()

func _show_death_screen() -> void:
	get_tree().change_scene_to_file("res://Title/GameOver.tscn")
