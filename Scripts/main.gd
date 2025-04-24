extends Node2D

@onready var enemy_scene = preload("res://Scenes/enemy.tscn")
@onready var player = $Player
@onready var bot = $Bot
@onready var health_bar = $HealthBar
@onready var score_display = $Score

var vw
var vh
var walls
var spawn_timer = 0
var spawn_delay = 2.0

var score = 0

var enemies = []

func _ready() -> void:
  vw = get_viewport().size.x
  vh = get_viewport().size.y
  walls = [
    [[-100, vw + 100], [-100, -100]],
    [[vw + 100, vw + 100], [-100, vh + 100]],
    [[-100, vw + 100], [vh + 100, vh + 100]],
    [[-100, -100], [-100, vh + 100]]
  ]
  
  player.connect("lost_health", _on_player_lost_health)


func _process(delta: float) -> void:
  if spawn_timer <= 0:
    spawn_enemy()
    spawn_timer = randf_range(0.1, spawn_delay)
    spawn_delay = clamp(spawn_delay * 0.99, 0.75, 2.0)
  else:
    spawn_timer -= delta
    
  if bot:
    if len(enemies) > 1:
      for i in range(len(enemies) - 1, -1, -1):
        if !is_instance_valid(enemies[i]):
          enemies.remove_at(i)
        
      bot.pick_direction(enemies)

    
func spawn_enemy() -> void:
  var new_enemy = enemy_scene.instantiate()
  var spawn_wall = randi_range(0, 3)
  new_enemy.position.x = randi_range(walls[spawn_wall][0][0], walls[spawn_wall][0][1])
  new_enemy.position.y = randi_range(walls[spawn_wall][1][0], walls[spawn_wall][1][1])
  new_enemy.connect("enemy_died", _on_enemy_died)
  if player:
    new_enemy.targets.append(player)
  if bot:
    new_enemy.targets.append(bot)
  enemies.append(new_enemy)
  add_child(new_enemy)


func _on_player_lost_health():
  health_bar.text = "<3".repeat(player.health)

func _on_enemy_died():
  score += 1
  score_display.text = str(score)
