extends Node

signal bgm_finished
signal sfx_finished


## Commonly used sounds. For ease of access.
const SOUNDS: Dictionary[String, AudioStream] = {
	"GUI_MENU_CLOSE": preload("res://assets/audio/sfx/GUI menu close.ogg"),
	"GUI_MENU_OPEN": preload("res://assets/audio/sfx/GUI menu open.ogg"),
	"GUI_SEL_BUZZER": preload("res://assets/audio/sfx/GUI sel buzzer.ogg"),
	"GUI_SEL_CANCEL": preload("res://assets/audio/sfx/GUI sel cancel.ogg"),
	"GUI_SEL_CURSOR": preload("res://assets/audio/sfx/GUI sel cursor.ogg"),
	"GUI_SEL_DECISION": preload("res://assets/audio/sfx/GUI sel decision.ogg"),
}

var _bgm_1: AudioStreamPlayer
var _bgm_2: AudioStreamPlayer
var _sfx: AudioStreamPlayer

var _using_bgm_2: bool = false


func _ready() -> void:
	_bgm_1 = AudioStreamPlayer.new()
	_bgm_2 = AudioStreamPlayer.new()
	_sfx = AudioStreamPlayer.new()
	
	_bgm_1.bus = &"BGM"
	_bgm_2.bus = &"BGM"
	_sfx.bus = &"SFX"
	
	
	add_child(_bgm_1)
	add_child(_bgm_2)
	add_child(_sfx)
	
	_bgm_1.name = "BGM1"
	_bgm_2.name = "BGM2"
	_sfx.name = "SFX"
	
	_bgm_1.set("parameters/looping", true)
	_bgm_2.set("parameters/looping", true)
	_bgm_2.volume_linear = 0.0

	_bgm_1.finished.connect(bgm_finished.emit)
	_bgm_2.finished.connect(bgm_finished.emit)
	_sfx.finished.connect(sfx_finished.emit)


func get_bgm(current: bool = true) -> AudioStreamPlayer:
	if not current:
		return _bgm_1 if _using_bgm_2 else _bgm_2
	return _bgm_2 if _using_bgm_2 else _bgm_1


func play_bgm(sound: Variant, from_position: float = 0.0) -> void:
	var stream: AudioStream = _check_sound(sound)

	get_bgm().stream = stream
	get_bgm().play(from_position)


func fade_bgm(sound: Variant, duration: float = 1.0) -> Tween:
	var stream: AudioStream = _check_sound(sound)
	
	var from: AudioStreamPlayer = get_bgm(true)
	var to: AudioStreamPlayer = get_bgm(false)
	
	to.stream = stream
	
	var tween: Tween = create_tween()
	tween.tween_callback(to.play)
	tween.tween_property(from, "volume_linear", 0, duration)
	tween.parallel().tween_property(to, "volume_linear", 1, duration)
	tween.tween_callback(from.stop)
	tween.tween_callback(set.bind("_using_bgm_2", not _using_bgm_2))

	return tween


func play_sfx(sound: Variant, from_position: float = 0.0) -> void:
	if _sfx.playing:
		_sfx.stop()
		_sfx.stream = null
	
	var stream: AudioStream = _check_sound(sound)
	
	_sfx.stream = stream
	_sfx.play(from_position)
	


func _check_sound(sound: Variant) -> AudioStream:
	if typeof(sound) == TYPE_STRING:
		return load(sound)
	elif typeof(sound) == TYPE_OBJECT and sound is AudioStream:
		return sound
	else:
		push_error("\"sound\" is not a valid sound to play. Must be a path (String) or AudioStream")
		return
