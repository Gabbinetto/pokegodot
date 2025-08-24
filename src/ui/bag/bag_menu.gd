class_name BagMenu extends Control

signal closed

const MENU_SCENE: PackedScene = preload("res://src/ui/bag/bag_menu.tscn")
const BAG_ITEM_SCENE: PackedScene = preload("res://src/ui/bag/bag_item.tscn")

@export var focus_rect: Control
@export var pocket_name: Label
@export var description: Label
@export var scroll_bar: Slider
@export var scroll_container: ScrollContainer
@export var item_icon: TextureRect
@export var background: TextureRect
@export var bag_sprite: TextureRect
@export var slots_container: BoxContainer
@export var dummy_bag_item: BagItem
@export var close_button: BagItem
@export var pocket_buttons: Control
@export var backgrounds: Dictionary[Bag.Pockets, Texture2D]
@export var male_bag_sprites: Dictionary[Bag.Pockets, Texture2D]
@export var female_bag_sprites: Dictionary[Bag.Pockets, Texture2D]

static var last_opened_pocket: Bag.Pockets = Bag.Pockets.ITEMS

var _bag_item_size: Vector2

# TODO: Finish whole implementation

func _ready() -> void:
	_bag_item_size = dummy_bag_item.size
	dummy_bag_item.queue_free()

	scroll_container.scroll_vertical_custom_step = _bag_item_size.y + slots_container.get_theme_constant("separation")

	close_button.refresh()
	close_button.pressed.connect(closed.emit)
	set_pocket.call_deferred(last_opened_pocket, true)

	for button: BaseButton in pocket_buttons.get_children():
		button.pressed.connect(set_pocket.bind(button.get_index()))

	get_viewport().gui_focus_changed.connect(_on_gui_focus)
	scroll_bar.value_changed.connect(_on_scroll_value_changed)

	if TransitionManager.transition:
		TransitionManager.play_out()


func set_pocket(pocket: Bag.Pockets, force: bool = false) -> void:
	if pocket == BagMenu.last_opened_pocket and not force:
		return

	BagMenu.last_opened_pocket = pocket

	pocket_name.text = Bag.POCKET_NAMES.get(pocket, "???")
	background.texture = backgrounds.get(pocket, backgrounds.values()[0])
	if PlayerData.gender == PlayerData.MALE:
		bag_sprite.texture = male_bag_sprites.get(pocket, male_bag_sprites.values()[0])
	else:
		bag_sprite.texture = female_bag_sprites.get(pocket, female_bag_sprites.values()[0])
	pocket_buttons.get_child(pocket).button_pressed = true


	var items: Array[String] = Bag.get_pocket(pocket)

	if slots_container.get_child_count() - 1 < items.size():
		for i: int in abs(slots_container.get_child_count() - 1 - items.size()):
			slots_container.add_child(BAG_ITEM_SCENE.instantiate())
	elif slots_container.get_child_count() - 1 > items.size():
		for i: int in abs(slots_container.get_child_count() - 1 - items.size()):
			slots_container.get_child(i).queue_free()
	slots_container.move_child(close_button, slots_container.get_child_count() - 1)

	for i: int in items.size():
		var item: Item = Item.get_item(items[i])
		slots_container.get_child(i).item = item
	
	for node: Control in slots_container.get_children():
		var index: int = node.get_index()
		if index == 0:
			node.focus_neighbor_top = node.get_path()
		else:
			node.focus_neighbor_top = slots_container.get_child(index - 1).get_path()
		node.focus_neighbor_left = node.get_path()
		node.focus_neighbor_right = node.get_path()
		if index == slots_container.get_child_count() - 1:
			node.focus_neighbor_bottom = node.get_path()
		else:
			node.focus_neighbor_bottom = slots_container.get_child(index + 1).get_path()
		
	
	slots_container.get_child(0).grab_focus.call_deferred()

	scroll_bar.max_value = slots_container.get_child_count() - 1


func _on_scroll_value_changed(value: int) -> void:
	if value < 0 or value >= slots_container.get_child_count():
		return
	slots_container.get_child(floori(scroll_bar.max_value - value)).grab_focus.call_deferred()


func _scroll_to_index(index: int) -> void:
	scroll_container.ensure_control_visible(slots_container.get_child(index))


func _on_gui_focus(node: Control) -> void:
	if node.get_parent() == slots_container:
		scroll_bar.set_value_no_signal(scroll_bar.max_value - node.get_index())
		focus_rect.show()
		var deferred: Callable = func():
			focus_rect.global_position = node.global_position + focus_rect.get_meta("offset", Vector2.ZERO)
		deferred.call_deferred()
		if node.item:
			item_icon.texture = node.item.texture
			description.text = node.item.description
		else:
			item_icon.texture = null
			description.text = ""
	else:
		focus_rect.hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		set_pocket(
			min(BagMenu.last_opened_pocket + 1, Bag.Pockets.values()[-1])
		)
	elif event.is_action_pressed("ui_left"):
		set_pocket(
			max(BagMenu.last_opened_pocket - 1, Bag.Pockets.values()[0])
		)
	elif event.is_action_pressed("ui_cancel"):
		closed.emit()


static func create() -> BagMenu:
	return MENU_SCENE.instantiate()
