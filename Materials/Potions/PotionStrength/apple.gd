extends Area2D

@onready var sprite: AnimatedSprite2D = $Anim

var y_inicial: float
var tempo: float = 0.0

func _ready() -> void:
	y_inicial = sprite.position.y
	connect("body_entered", Callable(self, "_on_body_entered"))
	
func _process(delta: float) -> void:
	# Faz o item flutuar
	tempo += delta * 2.0
	sprite.position.y = y_inicial + sin(tempo) * 5.0

func _on_body_entered(body):
	if body.name == "Player":  # ou verifique um grupo, ex: body.is_in_group("player")
		emit_signal("collected")
		queue_free()  # remove o item da cena (como se fosse coletado)
