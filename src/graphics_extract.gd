extends Control


@export var progress_label: Label
@export var progress_bar: Range
var thread: Thread


func _ready() -> void:
	thread = Thread.new()
	thread.start(_load_and_change_scene)


func _load_and_change_scene() -> void:
	DB.load_external_archive()
	_change_scene.call_deferred()


func _change_scene() -> void:
	#await get_tree().create_timer(0.08).timeout
	get_tree().change_scene_to_file("res://src/main.tscn")


func _exit_tree() -> void:
	thread.wait_to_finish()


func _process(_delta: float) -> void:
	if DB.zip_total_files == 0:
		return
	progress_label.text = "Progress: %d/%d" % [DB.zip_checked_files, DB.zip_total_files]
	progress_bar.max_value = DB.zip_total_files
	progress_bar.value = DB.zip_checked_files
