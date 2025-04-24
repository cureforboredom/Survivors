extends Node2D

@onready var enemy_scene = preload("res://Scenes/enemy.tscn")
@onready var player_scene = preload("res://Scenes/player.tscn")
@onready var bot_scene = preload("res://Scenes/bot.tscn")
@onready var health_bar = $HUD/HealthBar
@onready var score_display = $HUD/Score
@onready var game_over_message = $HUD/GameOver

var player = null
var bot = null

var vw
var vh
var walls
var spawn_timer = 0
var spawn_delay = 2.0

var score = 0
var high_score = 0

var enemies = []

func _ready() -> void:
  reset()

  vw = get_viewport().size.x
  vh = get_viewport().size.y
  walls = [
    [[-100, vw + 100], [-100, -100]],
    [[vw + 100, vw + 100], [-100, vh + 100]],
    [[-100, vw + 100], [vh + 100, vh + 100]],
    [[-100, -100], [-100, vh + 100]]
  ]
  

func _process(delta: float) -> void:
  if Input.is_action_just_pressed("reset"):
    reset()

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

func reset():
  for enemy in enemies:
    if is_instance_valid(enemy):
      enemy.queue_free()
  enemies = []

  var screen_size = get_viewport().get_visible_rect().size
  if player:
    player.queue_free()
  if bot:
    bot.queue_free()
  player = player_scene.instantiate()
  bot = bot_scene.instantiate()
  player.position = Vector2(screen_size.x / 3, screen_size.y / 2)
  bot.position = Vector2(screen_size.x / 3 * 2, screen_size.y / 2)
  add_child(player)
  add_child(bot)
  
  player.connect("lost_health", _on_player_lost_health)
  
  score = 0

  health_bar.text = "<3".repeat(player.health)
  score_display.text = str(score)
  game_over_message.visible = false

  
func death(p: Node2D):
  p.queue_free()
  if score > high_score:
    high_score = score
  game_over_message.text = "GAME OVER\nHIGH SCORE: " + str(high_score) + "\nHIT Y TO RESTART"
  game_over_message.visible = true

func _on_player_lost_health():
  health_bar.text = "<3".repeat(player.health)
  if player.health <= 0:
    death(player)
    player = null

func _on_enemy_died():
  score += 1
  score_display.text = str(score)