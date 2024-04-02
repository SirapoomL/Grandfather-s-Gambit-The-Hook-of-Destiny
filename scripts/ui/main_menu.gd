extends CanvasLayer

signal start_game

var panel
var score_label
var game_title
var start_button 
var quit_to_desktop_button

# Called when the node enters the scene tree for the first time.
func _ready():
	#get_tree().change_scene_to_file("res://scene/DemoComponents/demo.tscn")
	
	panel = $Panel
	game_title = $Panel/GameTitle
	start_button = $Panel/VBoxContainer/StartButton
	quit_to_desktop_button = $Panel/VBoxContainer/QuitToDesktopButton
	score_label = $ScoreLabel

	# Connect the button's "pressed" signal to this script.
	start_button.connect("pressed",Callable(self, "_on_start_button_pressed"))
	quit_to_desktop_button.connect("pressed",Callable(self, "_on_quit_to_desktop_button_pressed"))

	# hide score label
	score_label.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func show_message(text):
	game_title.text = text
	$MessageTimer.start()
	
func show_game_over():
	show_message("Game Over!")
	panel.show()
	# change the word "Start" to "Restart"
	start_button.text = "Restart"

func show_main_menu():
	show_message("Grandfather's Gambit\nThe Hook Of Destiny")
	panel.show()
	# change the word "Restart" to "Start"
	start_button.text = "Start"
	score_label.hide()
	
func update_score(score):
	score_label.text = str(score)
	
func _on_start_button_pressed():
	panel.hide()
	score_label.show()
	# Emit the signal when the button is pressed.
	start_game.emit()

func _on_message_timer_timeout():
	pass

func _on_quit_to_desktop_button_pressed():
	get_tree().quit()




