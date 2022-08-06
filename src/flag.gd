extends Node2D

const HamsterWheel = preload("res://src/hamster_wheel.gd")

func on_area_entered(body: Node) -> void:
  if body is HamsterWheel:
    victory()


var victory_satisified := false


func victory() -> void:
  if not victory_satisified:
    victory_satisified = true
    var victory_overlay = preload("res://ui/VictoryOverlay.tscn").instance()
    get_tree().current_scene.add_child(victory_overlay)
    $sfx_Victory.play()


func _unhandled_input(evt) -> void:
  if evt is InputEventKey and  evt.scancode == KEY_SPACE and evt.pressed and is_network_master():
    try_accept_victory()


func try_accept_victory() -> void:
  if not victory_satisified: return
  rpc("goto_next_level")


remotesync func goto_next_level() -> void:
  var cur_scene = get_tree().get_current_scene()
  match cur_scene.name:
    "Level1":
      get_tree().change_scene("res://levels/Level2.tscn")
    "Level2":
      get_tree().change_scene("res://levels/Level3.tscn")
    "Level3":
      get_tree().change_scene("res://levels/victory_level.tscn")
    _:
      push_error("no other levels should ever be loaded with a victory condition")
