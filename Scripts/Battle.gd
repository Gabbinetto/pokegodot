class_name Battle extends CanvasLayer

enum BattleTypes {SINGLE, DOUBLE}
enum EnemyTypes {WILD, TRAINER}

@onready var actions_container: VBoxContainer = %Actions
@onready var fight_button: Button = %FightButton
@onready var pkmn_button: Button = %PkmnButton
@onready var bag_button: Button = %BagButton
@onready var run_button: Button = %RunButton
@onready var moves_container: Control = %Moves
@onready var moves_back_button: Button = $Moves/MovesBackButton

var battle_type: BattleTypes
var enemy_type: EnemyTypes

var friend_teams: Array[PokemonTeam]
var friend_side: Array[Pokemon]
var enemy_teams: Array[PokemonTeam]
var enemy_side: Array[Pokemon]

func _ready() -> void:
	fight_button.grab_focus()
	if enemy_type == EnemyTypes.TRAINER:
		run_button.disabled = true

	fight_button.pressed.connect(
		func():
			actions_container.hide()
			moves_container.show()
			moves_container.get_node("MoveSlots/Move1").grab_focus()
	)
	moves_back_button.pressed.connect(
		func():
			moves_container.hide()
			actions_container.show()
			fight_button.grab_focus()
	)

	# Checking teams
	#assert(friend_teams.size() > 0 and enemy_teams.size() > 0)
	#match battle_type:
		#BattleTypes.SINGLE:
			#assert(friend_teams.size() == 1)
			#assert(enemy_teams.size() == 1)
		#BattleTypes.DOUBLE:
			#assert(friend_teams.size() <= 2)
			#assert(enemy_teams.size() <= 2)

	# Setting first Pokemon
	for team in friend_teams:
		friend_side.append(team.get_first_healthy())
	for team in enemy_teams:
		enemy_side.append(team.get_first_healthy())
