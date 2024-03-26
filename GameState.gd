extends Node

enum State {
	NOT_STARTED,
	PLAYING,
	GAME_OVER,
	PAUSED
}

@onready var _current_state  = State.NOT_STARTED

func set_current_state(value):
	if value in State.values():
		_current_state = value
	else:
		push_error("Invalid state")

func get_current_state():
	return _current_state

func get_current_state_str():
	return State.find_key(_current_state)

func is_playing():
	return _current_state == State.PLAYING

func is_paused():
	return _current_state == State.PAUSED
