extends Control

# --- Botões ---
@onready var start_btn = %Button

# --- Players de som ---
@onready var click_sound = $ClickSound
@onready var music_player = $MusicPLayer

func _ready():
	# Conecta sinais de clique
	start_btn.pressed.connect(_on_start_pressed)

	
	# Conecta sinais de hover (passar mouse)
	start_btn.mouse_entered.connect(_on_button_hovered)

func _play_click():
	if click_sound:
		click_sound.play()

func _on_start_pressed():
	_play_click()
	print("Iniciando jogo...")
	get_tree().change_scene_to_file("res://Levels/level1.tscn")
	
# Som ao passar mouse
func _on_button_hovered():
	_play_click()
