extends Node

var cur_cost = 4
var cur_range = 1.0

var network_manager : NetworkManager
var menu : Control
var gameover_overlay : Control
var youwin_overlay : Control

var cur_difficulty : float = 1.0
var min_difficulty : float = 1000

var game_paused : bool = false

func game_over():
	gameover_overlay.visible = true
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()

func game_win():
	youwin_overlay.visible = true
	if min_difficulty >= 3:
		youwin_overlay.get_node("CenterContainer/PanelContainer/MarginContainer/VBoxContainer/omg").visible = true
	else:
		youwin_overlay.get_node("CenterContainer/PanelContainer/MarginContainer/VBoxContainer/tryharder").visible = true
