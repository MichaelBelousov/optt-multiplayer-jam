extends Node2D

const HamsterWheel = preload("res://src/hamster_wheel.gd")

func on_area_entered(body: Node) -> void:
  if body is HamsterWheel:
    victory()


var victory_satisified := false

func victory() -> void:
  print("victory!")
  var victory_overlay = preload("res://ui/VictoryOverlay.tscn").instance()
  get_tree().current_scene.add_child(victory_overlay)
  victory_satisified = true


func _unhandled_input(evt) -> void:
  if evt is InputEventKey and  evt.scancode == KEY_SPACE and evt.pressed:
    try_accept_victory()


func try_accept_victory() -> void:
  if not victory_satisified: return
  print("victory accepted!")
