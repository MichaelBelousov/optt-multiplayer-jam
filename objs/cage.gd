extends Node2D

const HamsterWheel = preload("res://src/hamster_wheel.gd")

var has_hamster: bool = false setget set_has_hamster, get_has_hamster

func _ready():
  self.has_hamster = false # use self to invoke setter logic

func set_has_hamster(value: bool) -> void:
  $Hamster.visible = value
  has_hamster = value

func get_has_hamster() -> bool:
  return has_hamster

func on_area_entered(body: Node) -> void:
  if not has_hamster and body is HamsterWheel:
    body.remove_hamster()
    self.has_hamster = true
    $AudioStreamPlayer.play()
