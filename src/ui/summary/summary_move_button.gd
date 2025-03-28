class_name SummaryMoveButton extends Button


@export var move: PokemonMove:
	set(value):
		move = value
		_refresh()
@export var move_type: TextureRect
@export var move_name: Label
@export var move_pp: Label

func _refresh() -> void:
	if not move:
		return
	
	move_type.texture = Types.ICONS[move.type]
	move_name.text = move.name
	move_pp.text = "PP %d/%d" % [move.pp, move.total_pp] 


func _ready() -> void:
	_refresh()
