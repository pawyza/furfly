extends Node2D

var menu_exit_trigger = false

func _ready():
	if Input.is_action_just_pressed("mute"):
		$AnimationPlayer.play("RESET")

func _process(delta):
	if Input.is_action_just_pressed("mute") and !$MenuAnimationPlayer.is_playing():
		if !AudioServer.is_bus_mute(0):
			AudioServer.set_bus_mute(0, true)
			$Menu_canvas/Menu/PanelContainer/MarginContainer/VBoxContainer/MarginContainer_2/HBoxContainer/CheckBox.button_pressed = true
			$MenuAnimationPlayer.play("mute")
		else:
			AudioServer.set_bus_mute(0, false)
			$Menu_canvas/Menu/PanelContainer/MarginContainer/VBoxContainer/MarginContainer_2/HBoxContainer/CheckBox.button_pressed = false
			$MenuAnimationPlayer.play("unmute")
			
	if Input.is_action_just_pressed("menu"):
		if !$Menu_canvas/Menu.visible:
			$Menu_canvas/Menu.show()
		else:
			$Menu_canvas/Menu.hide()

func _on_next_level_trigger_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if !menu_exit_trigger:
		print("########### Level_1 ##############")
		menu_exit_trigger = true
		$Player.shader_color_level = 1.0
		$Player.process_mode = Node.PROCESS_MODE_DISABLED
		$Menu.process_mode = Node.PROCESS_MODE_DISABLED
		$LevelManagerAnimationPlayer.play("menu_exit")

func menu_exit():
	$Menu.hide()
	$Level_1.process_mode = Node.PROCESS_MODE_INHERIT
	$Level_1.show()
	$Player.process_mode = Node.PROCESS_MODE_INHERIT
	$Player.global_transform.origin = $Level_1/SpawnPoint.global_transform.origin 

func _on_crt_check_box_toggled(button_pressed):
	print(button_pressed)
	$CRT.visible = button_pressed

func _on_mute_check_box_toggled(button_pressed):
	AudioServer.set_bus_mute(0, button_pressed)
	if button_pressed:
		$MenuAnimationPlayer.play("unmute")
	else:
		$MenuAnimationPlayer.play("mute")
