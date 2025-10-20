extends CharacterBody2D
class_name NPC

@export var potion_strenght: String = "Poção de Vida"
@export var potion_amount: int = 1

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

func _ready() -> void:
	# Conecta o sinal de colisão
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.has_method("add_to_inventory"):
		body.add_to_inventory(potion_strenght, potion_amount)
		print("🧙‍♂️ NPC deu ao jogador:", potion_amount, potion_strenght)

	else:
		print("⚠️ O corpo que entrou não possui método 'add_to_inventory'")
