extends Node

enum State {
	NOT_STARTED,
	PLAYING,
	GAME_OVER,
	PAUSED,
	CUT_SCENE
}
var player_status
var save_pointx = 393
var save_pointy = 656

var minotaur_dead = false
var gate_1_opened = false

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

func set_player_status(status):
	player_status = status

func get_player_status():
	return player_status

func get_save_point():
	return 
	
func is_cutscene():
	return _current_state == State.CUT_SCENE
