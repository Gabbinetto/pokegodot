extends Control

@export var pokemon_id: = "BULBASAUR"
@export var form_number: = 0

@onready var sprite: TextureRect = %Sprite

var species: PokemonSpecies
var sprites: Array[Texture]
var current_sprite: = 0

func _ready() -> void:
	if form_number > 0:
		species = PokemonForm.new(pokemon_id, form_number)
	else:
		species = PokemonSpecies.new(pokemon_id)
	
	sprites.append(species.front)
	sprites.append(species.front_s)
	if species.front_f:
		sprites.append(species.front_f)
		sprites.append(species.front_f_s)
	sprites.append(species.back)
	sprites.append(species.back_s)
	if species.back_f:
		sprites.append(species.back_f)
		sprites.append(species.back_f_s)
	
	sprite.texture = sprites[current_sprite]
	%SpriteTimer.timeout.connect(
		func():
			current_sprite += 1
			if current_sprite >= sprites.size():
				current_sprite = 0
			sprite.texture = sprites[current_sprite]
	)
	
	for node in %Stats.get_children():
		node.set_value(species.base_stats.get(node.name))

	%Icon.texture = species.icon
	%IconShiny.texture = species.icon_s

	var moves_text: = ""
	for move in species.moves:
		moves_text += "%2d: %s\n" % move
	%Moves.get_node("Label").text = moves_text
	%TutorMoves.get_node("Label").text = "\n".join(species.tutor_moves)
	%EggMoves.get_node("Label").text = "\n".join(species.egg_moves)

func _process(delta: float) -> void:
	if Engine.get_frames_drawn() % 20 == 0:
		%Icon.frame = 1 if %Icon.frame == 0 else 0
		%IconShiny.frame = not bool(%Icon.frame)

func _input(event: InputEvent) -> void:
	const SCROLL: = 10
	
	if event.is_action("scroll_up"):
		position.y += SCROLL
	if event.is_action("scroll_down"):
		position.y -= SCROLL
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		position.y = 0
