## may want to rename this to "GameState" once we figure out what else it does

extends Node


func _input(_evt):
  if Input.is_action_just_pressed("restart_level"):
    $sfx_Restart.play()
    assert(OK == get_tree().reload_current_scene(), "reloading failed")

var scene = null
func _ready():
  scene = preload("res://src/auatoload.tscn")
  var instance = scene.instance()
  add_child(instance)
