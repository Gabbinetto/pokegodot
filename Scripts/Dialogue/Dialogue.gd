extends CanvasLayer
class_name Dialogue

# If true the dialogue will start automatically
# May be good for stuff like cutscenes at the start of a room
@export var autostart : = false

# Generally sizes and positions are based off of HGSS type of windows skin
# If you want to use another kind of window skin you should change all
# these values and adapt them to your type of windows skin

@export var window_skin : Texture # Dialogue box look
@export var window_rect : = Rect2(0, 288, 512, 96) # Dialogue box position and size
@export var region_rect : = Rect2(4, 2, 88, 44) # NinePatchRect region rect
@export var label_rect : = Rect2(18, 12, 456, 74) # Text box position and size

@export var patch_margin_left : = 22
@export var patch_margin_top : = 14
@export var patch_margin_right : = 44
@export var patch_margin_bottom : = 14

@export var dialogue_events : Array[DialogueEvent]

var arrow_scene # The arrow hinting at the player to press A or B

var window : NinePatchRect # Dialogue window
var label : Label # Text box
var current_event : DialogueEvent # Current running event
var arrow : AnimatedSprite2D

func _ready() -> void:
	visible = false
	
	if window_skin == null:
		window_skin = load('res://Graphics/Windowskins/speech hgss 1.png')
		
	# Setting up the NinePatchRect and the Label
	window = NinePatchRect.new()
	window.name = 'DialogueBox'
	window.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	window.texture = window_skin
	
	window.patch_margin_left = patch_margin_left
	window.patch_margin_top = patch_margin_top
	window.patch_margin_right = patch_margin_right
	window.patch_margin_bottom = patch_margin_bottom
	
	window.region_rect = region_rect
	window.position = window_rect.position
	window.size = window_rect.size
	add_child(window)
	
	# The label
	label = Label.new()
	label.label_settings = load('res://Scripts/Dialogue/dialogue_label_settings.tres')
	label.name = 'DialogueText'
	label.position = label_rect.position
	label.size = label_rect.size
	label.max_lines_visible = 3
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	window.add_child(label)
	
	arrow_scene = preload('res://Scenes/UI/DialogueArrow.tscn')
	arrow = arrow_scene.instantiate()
	arrow.visible = false
	window.add_child(arrow)
	
	if autostart:
		start_dialogue()
	
	
func start_dialogue():
	visible = true
	Globals.movement_enabled = false
	
	for event in dialogue_events:
		current_event = event
		event.run(self)
		await event.event_finished

	current_event = null
	visible = false
	Globals.movement_enabled = true

func _unhandled_input(input_event: InputEvent) -> void:
	if current_event != null:
		current_event.input(input_event, self)
