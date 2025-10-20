extends Node2D

# --- CONFIGURAÇÕES ---
@export var enemy_scene: PackedScene          # Cena do inimigo (ex: Enemy.tscn)
@export var spawn_interval: float = 2.0       # Tempo inicial entre spawns
@export var spawn_radius: float = 150.0       # Distância mínima do jogador
@export var spawn_range_max: float = 300.0    # Distância máxima do jogador
@export var player: Node2D                    # Referência ao jogador
@export var max_enemies: int = 30             # Limite de inimigos
@export var tilemap: TileMapLayer             # Camada de tilemap onde os inimigos podem nascer
@export var spawn_layer: int = 0              # Índice da camada (se precisar)

# --- VARIÁVEIS INTERNAS ---
var _time_passed: float = 0.0
var _difficulty_timer: float = 0.0
const MAX_ATTEMPTS: int = 30  # Limite de tentativas para evitar loop infinito

# --- LOOP PRINCIPAL ---
func _process(delta: float) -> void:
	if player == null or enemy_scene == null or tilemap == null:
		return

	# limita quantidade de inimigos
	var current_enemies = get_tree().get_nodes_in_group("enemies").size()
	if current_enemies >= max_enemies:
		return

	# controla tempo de spawn
	_time_passed += delta
	if _time_passed >= spawn_interval:
		_time_passed = 0
		spawn_enemy()

	# aumenta dificuldade com o tempo
	_difficulty_timer += delta
	if _difficulty_timer >= 5.0:
		_difficulty_timer = 0
		spawn_interval = max(0.5, spawn_interval - 0.1)
		print("Nova dificuldade! Intervalo de spawn:", spawn_interval)


# --- FUNÇÃO DE SPAWN ---
func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	
	var attempts := 0
	var spawn_pos: Vector2
	var valid_spawn := false
	
	while attempts < MAX_ATTEMPTS and not valid_spawn:
		attempts += 1

		# calcula posição aleatória em volta do jogador
		var angle = randf() * TAU
		var distance = randf_range(spawn_radius, spawn_range_max)
		spawn_pos = player.position + Vector2(cos(angle), sin(angle)) * distance

		# converte posição para coordenada de célula no tilemap
		var cell = tilemap.local_to_map(spawn_pos)

		# verifica se há tile preenchido nessa célula
		if tilemap.get_cell_source_id(cell) != -1:
			valid_spawn = true

	if valid_spawn:
		enemy.position = spawn_pos
		enemy.add_to_group("enemies")
		get_parent().add_child(enemy)
	else:
		print("⚠️ Nenhuma posição válida encontrada após", MAX_ATTEMPTS, "tentativas.")
