class_name PokemonForm extends PokemonSpecies

var mega_stone: String = ""
var mega_move: String = ""
var mega_message: int = 0
var unmega_form: int = 0
var pokedex_form: int = 0

func _init(id: String, form_number: int) -> void:
	self.data = Global.pokemons.get(id, {})
	var form_data: Dictionary = Global.forms.get(id + "_" + str(form_number), {})
	for key in form_data:
		self.data[key] = form_data[key]
	super(id)

	# Texture
	front = load(Global.FRONT_SPRITES_PATH + self.id + "_%d" % form_number + ".png")
	back = load(Global.BACK_SPRITES_PATH + self.id + "_%d" % form_number + ".png")
	front_s = load(Global.SHINY_FRONT_SPRITES_PATH + self.id + "_%d" % form_number + ".png")
	back_s = load(Global.SHINY_BACK_SPRITES_PATH + self.id + "_%d" % form_number + ".png")
	front_f = load(Global.FRONT_SPRITES_PATH + self.id + "_%d" % form_number + "_female.png") if FileAccess.file_exists(Global.FRONT_SPRITES_PATH + self.id + "_%d" % form_number + "_female.png") else null
	back_f = load(Global.BACK_SPRITES_PATH + self.id + "_%d" % form_number + "_female.png") if FileAccess.file_exists(Global.BACK_SPRITES_PATH + self.id + "_%d" % form_number + "_female.png") else null
	front_f_s = load(Global.SHINY_FRONT_SPRITES_PATH + self.id + "_%d" % form_number + "_female.png") if FileAccess.file_exists(Global.SHINY_FRONT_SPRITES_PATH + self.id + "_%d" % form_number + "_female.png") else null
	back_f_s = load(Global.SHINY_BACK_SPRITES_PATH + self.id + "_%d" % form_number + "_female.png") if FileAccess.file_exists(Global.SHINY_BACK_SPRITES_PATH + self.id + "_%d" % form_number + "_female.png") else null
	icon = load(Global.ICONS_SPRITES_PATH + self.id + "_%d" % form_number + ".png")
	icon_s = load(Global.SHINY_ICONS_SPRITES_PATH + self.id + "_%d" % form_number + ".png") if FileAccess.file_exists(Global.SHINY_ICONS_SPRITES_PATH + self.id + "_%d" % form_number + ".png") else null
	footprint = load(Global.FOOTPRINTS_SPRITES_PATH + self.id + "_%d" % form_number + ".png") if FileAccess.file_exists(Global.FOOTPRINTS_SPRITES_PATH + self.id + "_%d" % form_number + ".png") else footprint
