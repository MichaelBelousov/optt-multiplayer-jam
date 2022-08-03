## may want to rename this to "GameState" once we figure out what else it does

extends Node


func _input(evt):
  if Input.is_action_just_pressed("restart_level"):
    var cur_scene = get_tree().get_current_scene()
    if cur_scene.name == "Level1":
      get_tree().change_scene("res://src/test.tscn")
    else:
      push_error("attempted to restart the level, but the level was unknown")