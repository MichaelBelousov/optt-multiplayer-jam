## may want to rename this to "GameState" once we figure out what else it does

extends Node


func _input(_evt):
  if Input.is_action_just_pressed("restart_level"):
    assert(OK == get_tree().reload_current_scene(), "reloading failed")
