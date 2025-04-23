extends Node2D

@onready var enemy_scene = preload("res://Scenes/enemy.tscn")
@onready var player = $Player

var vw
var vh
var walls
var spawn_timer = 0

func _ready() -> void:
  vw = get_viewport().size.x
  vh = get_viewport().size.y
  walls = [
    [[-100, vw+100], [-100, -100]],
    [[vw+100, vw+100], [-100, vh+100]],
    [[-100, vw+100], [vh+100, vh+100]],
    [[-100, -100], [-100, vh+100]]
  ]


func _process(delta: float) -> void:
  if spawn_timer <= 0:
    spawn_enemy()
    spawn_timer = randf_range(0.5, 2.0)
  else:
    spawn_timer -= delta
    
func spawn_enemy() -> void:
  var new_enemy = enemy_scene.instantiate()
  var spawn_wall = randi_range(0, 3)
  new_enemy.position.x = randi_range(walls[spawn_wall][0][0], walls[spawn_wall][0][1])
  new_enemy.position.y = randi_range(walls[spawn_wall][1][0], walls[spawn_wall][1][1])
  new_enemy.targets.append(player)
  add_child(new_enemy)
