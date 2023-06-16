extends CanvasLayer
class_name HUD

const PartyMenu: PackedScene = preload("res://Scenes/UI/Hud/PartyMenu.tscn")

@onready var main_menu: PanelContainer = $MainWindowContainer
@onready var buttons_container: VBoxContainer = $MainWindowContainer/PanelContainer/Buttons
@onready var pokedex_button: Button = $MainWindowContainer/PanelContainer/Buttons/PokedexButton
@onready var pokemon_button: Button = $MainWindowContainer/PanelContainer/Buttons/PokemonButton
@onready var bag_button: Button = $MainWindowContainer/PanelContainer/Buttons/BagButton
@onready var trainer_button: Button = $MainWindowContainer/PanelContainer/Buttons/TrainerButton
@onready var save_button: Button = $MainWindowContainer/PanelContainer/Buttons/SaveButton
@onready var options_button: Button = $MainWindowContainer/PanelContainer/Buttons/OptionsButton
@onready var exit_button: Button = $MainWindowContainer/PanelContainer/Buttons/ExitButton

var buttons: Array[Node]

func _ready() -> void:
	hide()
	
	buttons = buttons_container.get_children()

	trainer_button.text = GameVariables.player_name
	
	pokedex_button.visible = Flags.pokedex_unlocked
	
	var show_pokemon = false
	for pokemon in GameVariables.player_team.values():
		if pokemon != null:
			show_pokemon = true
			break
	pokemon_button.visible = show_pokemon

	for button in buttons:
		if button.visible:
			button.grab_focus()
			break
	
	pokemon_button.pressed.connect(_open_party_menu)
	exit_button.pressed.connect(close)

func _open_party_menu():
	var menu: = PartyMenu.instantiate()
	main_menu.hide()
	menu.closed.connect(func():
		main_menu.show()
		pokemon_button.grab_focus()
	)
	add_child(menu)

func open():
	show()
	pokemon_button.grab_focus()
	Globals.movement_enabled = false
	
func close():
	hide()
	Globals.movement_enabled = true
