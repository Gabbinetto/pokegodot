extends Control
class_name PartyMenu

signal closed

@onready var back_button: TextureButton = $BackButton
@onready var slots_container: Node2D = $Slots
@onready var slots: Array[Node] = slots_container.get_children()

var selection_options: Array[Node]

var current_selected: = 0:
	set(value):
		
		value = clampi(value, 0, selection_options.size() - 1)
		
		current_selected = value
		selection_options[current_selected].grab_focus()


func _ready() -> void:
	# Set the player team to the slots 
	for i in slots.size():
		slots[i].pokemon = GameVariables.player_team[i]

	back_button.pressed.connect(close)
	
	for slot in slots:
		var other_slots = slots.duplicate()
		other_slots.erase(slot)
		for other in other_slots:
			slot.focus_changed.connect(func():
				other.focused = false
			)
		slot.focus_changed.connect(func():
			back_button.hide()
			back_button.show()
		)
		back_button.focus_entered.connect(func():
			slot.focused = false
		)
	
	_load_selection_options()
	self.current_selected = selection_options.size() - 1


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		self.current_selected += 2
	elif event.is_action_pressed("ui_up"):
		self.current_selected -= 2 if current_selected != selection_options.size() - 1 else 1
	elif event.is_action_pressed("ui_right"):
		self.current_selected += 1
	elif event.is_action_pressed("ui_left"):
		self.current_selected -= 1
	elif event.is_action_pressed("B"):
		close()

func _load_selection_options() -> void:
	selection_options = slots.filter(func(slot): return slot.pokemon != null)
	selection_options.append(back_button)

func close() -> void:
	closed.emit()
	queue_free()
