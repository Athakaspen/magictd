extends Control

@onready var difficulty_text = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DifficultyText
@onready var close_button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CloseButton

func _ready():
	Singleton.menu = self
	Singleton.gameover_overlay = $"../Gameover"
	Singleton.youwin_overlay = $"../Youwin"
	open_menu()

func _input(event):
	if event.is_action_pressed("open_menu"):
		if not visible:
			open_menu()
		else:
			close_menu()

func open_menu():
	self.visible = true
	Singleton.game_paused = true
	Engine.time_scale = 0.0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_menu():
	self.visible = false
	$"../Youwin".visible = false
	Singleton.game_paused = false
	Singleton.min_difficulty = min(Singleton.min_difficulty, Singleton.cur_difficulty)
	Engine.time_scale = 1.0
	close_button.text = "  Back to Game  "
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_difficulty_slider_value_changed(value):
	Singleton.cur_difficulty = value
	difficulty_text.text = "Difficulty scale: " + str(value)

func _on_button_pressed():
	close_menu()

func _on_invert_x_toggled(toggled_on):
	%PlayerCharacter.is_inverted_x = toggled_on

func _on_invert_y_toggled(toggled_on):
	%PlayerCharacter.is_inverted_y = toggled_on
