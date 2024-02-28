extends CanvasLayer
class_name Menu_Interface

enum UIState {
	CLOSE,
	BAG,
	SKILL_TREE,
	SETTING
}

var current_ui_state = UIState.CLOSE

func _ready():
	hide_all(UIState.CLOSE)
	current_ui_state = UIState.CLOSE

func _process(_delta):
	if !GameState.is_playing() && GameState.get_current_state() != GameState.State.PAUSED:
		return
	
	if GameInputMapper.is_action_just_pressed("inventory"):
		toggle_bag()

	if GameInputMapper.is_action_just_pressed("skill_tree"):
		toggle_skill_tree()
		
	if GameInputMapper.is_action_just_pressed("esc"):
		toggle_setting()

func hide_all(next_state):
	$Skill_Tree.hide()
	$Backpack.hide()
	$Setting.hide()
	if next_state == UIState.CLOSE && current_ui_state == UIState.CLOSE:
		return
	elif next_state == UIState.CLOSE || current_ui_state == UIState.CLOSE:
		if next_state == UIState.CLOSE:
			GameState.set_current_state(GameState.State.PLAYING)
		if current_ui_state == UIState.CLOSE:
			GameState.set_current_state(GameState.State.PAUSED)
	current_ui_state = next_state
		

func toggle_bag():
	if current_ui_state == UIState.BAG:
		print('case1')
		hide_all(UIState.CLOSE)
	else:
		print('case2')
		hide_all(UIState.BAG)
		$Backpack.show()

func toggle_skill_tree():
	if current_ui_state == UIState.SKILL_TREE:
		hide_all(UIState.CLOSE)
	else:
		hide_all(UIState.SKILL_TREE)
		$Skill_Tree.show()
		
func toggle_setting():
	if current_ui_state != UIState.CLOSE:
		hide_all(UIState.CLOSE)
	else:
		hide_all(UIState.SETTING)
		$Setting.show()
