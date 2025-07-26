class_name Transition extends Control

## Screen transition
##
## Plays a screen transition, having an in and out animation, controlled
## through code. [br]
## The base class has no built-in animation. It's supposed to be used in scenes which overwrite
## the [method play_in] and [method play_in] methods. It's managed 
## by the [TransitionManager].

@warning_ignore("unused_signal")
signal finished ## Plays when either [method play_in] or [method play_out] are done

var params: Dictionary[String, Variant] = {} ## Optional parameters the transition may use.


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL


## Plays the transtiotion when it comes in, like a fade in.
func play_in() -> void:
	pass


## Plays the transtiotion when it goes out, like a fade out.
func play_out() -> void:
	pass
