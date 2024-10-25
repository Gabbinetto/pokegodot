extends Control

@export var id: String = "BULBASAUR"
@export var form: int = 0
var pokemon: Species

func _ready() -> void:
	pokemon = Species.new(id, form)
	print(pokemon)

	$Name.text = pokemon.name
	$FormNumber.text = "Form: %s" % pokemon.form_number
	$FormName.text = pokemon.form_name
	$Types.text = "%s %s" % [Types.Enum.find_key(pokemon.types[0]), Types.Enum.find_key(pokemon.types[1])]
	$Abilities.text = str(pokemon.abilities)
	$HiddenAbilities.text = str(pokemon.hidden_abilities)
	var stats: GridContainer = %Stats
	for stat: String in pokemon.base_stats:
		stats.get_node(stat).text = str(pokemon.base_stats[stat])
		stats.get_node(stat + "2").value = pokemon.base_stats[stat]
		stats.get_node(stat + "3").text = str(pokemon.evs[stat])
	
	for move: Dictionary in pokemon.moves:
		%MovesLabel.text += "%s: %s\n" % [move.level, move.id]
	for move: String in pokemon.tutor_moves:
		%TutorMovesLabel.text += "%s\n" % move
	for move: String in pokemon.egg_moves:
		%EggMovesLabel.text += "%s\n" % move