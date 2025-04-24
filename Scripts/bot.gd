extends AnimatableBody2D

@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
@onready var poly = $Polygon2D
@onready var collider = $CollisionPolygon2D
@onready var gun = $Gun

const MAX_SPEED = 1200

var screen_size

var direction = PI / 2

var closest_enemy

var panic = false

var velocity = Vector2(0, 0)

var bullets = []
var shot_timer = 0

func _ready() -> void:
  collider.polygon = poly.polygon
  screen_size = get_viewport().get_visible_rect().size

func _physics_process(delta: float) -> void:
  if panic:
    position = Vector2(screen_size.x / 2, screen_size.y / 2)
    panic = false
    return

  var move = Vector2(1, 0).rotated(direction)
  velocity += move * delta * MAX_SPEED

  var aim
  if closest_enemy:
    aim = (position - (closest_enemy.position + Vector2(0, closest_enemy.speed * 0.1).rotated(closest_enemy.direction))).normalized()
  else:
    aim = Vector2(0, 0)
  var new_rotation = aim.rotated(PI / 2.0).angle() + PI
  gun.rotation = lerp_angle(gun.rotation, new_rotation, 0.2)

  if shot_timer <= 0:
    shot_timer = 0.24
    var new_bullet = bullet_scene.instantiate()
    get_tree().current_scene.add_child(new_bullet)
    new_bullet.global_position = gun.global_position + Vector2(0, -50).rotated(gun.rotation)
    new_bullet.direction = gun.rotation
    new_bullet.speed = 1000

  shot_timer -= delta

  velocity = clamp(velocity, Vector2(-MAX_SPEED, -MAX_SPEED), Vector2(MAX_SPEED, MAX_SPEED))
  var new_position = position + velocity * delta
  new_position = new_position.clamp(Vector2(25, 25), Vector2(screen_size.x - 25, screen_size.y - 25))
  position = new_position
  velocity *= Vector2(0.925, 0.925)

func pick_direction(enemies: Array):
  closest_enemy = enemies[0]
  
  for enemy in enemies:
    var enemy_distance = (position - enemy.position).length()
    if enemy_distance < (position - closest_enemy.position).length():
      closest_enemy = enemy
  
  if (position - closest_enemy.position).length() < 10:
    panic = true
    return

  elif (position - closest_enemy.position).length() < 200:
    var summed_enemy_directions = Vector2(0, 0)
    var summed_weights = 0
  
    for enemy in enemies:
      var enemy_direction = position - enemy.position
      var enemy_distance = enemy_direction.length()
      if enemy_distance == 0:
        enemy_distance = 0.1
      var weight = (position - closest_enemy.position).length() / enemy_distance
      summed_weights += weight
      summed_enemy_directions += Vector2(enemy_direction.x * weight, enemy_direction.y * weight)
      
    var weighted_average_enemy_direction = Vector2(summed_enemy_directions.x / summed_weights,
                                                  summed_enemy_directions.y / summed_weights)

    if abs(weighted_average_enemy_direction.angle() - (position - closest_enemy.position).angle()) < (PI / 16):
      weighted_average_enemy_direction = weighted_average_enemy_direction.rotated(PI / 16)
    
    direction = weighted_average_enemy_direction.angle()
  else:
    var wall_dists = {
      position.x: "left",
      position.y: "top",
      screen_size.x - position.x: "right",
      screen_size.y - position.y: "bottom"
    }

    wall_dists.sort()
    
    if wall_dists.keys()[0] < 100:
      match wall_dists.values()[0]:
        "left":
          direction = Vector2(1, 0).angle()
        "top":
          direction = Vector2(0, 1).angle()
        "right":
          direction = Vector2(-1, 0).angle()
        "bottom":
          direction = Vector2(0, -1).angle()

    else:
      direction = (closest_enemy.position - position).angle()
