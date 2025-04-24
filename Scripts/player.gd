extends AnimatableBody2D

@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
@onready var poly = $Polygon2D
@onready var collider = $CollisionPolygon2D
@onready var hurt_box = $HurtBox
@onready var hurt_box_collider = $HurtBox/CollisionPolygon2D
@onready var gun = $Gun

const MAX_SPEED = 2550

var health = 3

var velocity = Vector2(0, 0)

var bullets = []
var shot_timer = 0

signal lost_health

func _ready() -> void:
  collider.polygon = poly.polygon
  hurt_box_collider.polygon = poly.polygon
  hurt_box.connect("body_entered", _on_hurt_box_entered)

func _physics_process(delta: float) -> void:
  if Input.is_action_just_pressed("left") or \
    Input.is_action_just_pressed("right"):
      velocity.x *= 0.8
  if Input.is_action_just_pressed("forward") or \
    Input.is_action_just_pressed("back"):
      velocity.y *= 0.8
  var move = Vector2(Input.get_axis("left", "right"), Input.get_axis("forward", "back"))
  velocity += move * delta * MAX_SPEED

  var aim = Vector2(Input.get_axis("aim_left", "aim_right"), Input.get_axis("aim_forward", "aim_back"))
  if aim:
    var new_rotation = aim.rotated(PI / 2).angle()
    gun.rotation = lerp_angle(gun.rotation, new_rotation, 0.1)

  if shot_timer <= 0:
    shot_timer = 0.12
    var new_bullet = bullet_scene.instantiate()
    add_child(new_bullet)
    new_bullet.global_position = gun.global_position + Vector2(0, -50).rotated(gun.rotation)
    new_bullet.direction = gun.rotation
    # velocity += Vector2(0, 110).rotated(gun.rotation)

  shot_timer -= delta

  velocity = clamp(velocity, Vector2(-MAX_SPEED, -MAX_SPEED), Vector2(MAX_SPEED, MAX_SPEED))
  var new_position = position + velocity * delta
  new_position = new_position.clamp(Vector2(25, 25), get_viewport().get_visible_rect().size)
  position = new_position
  velocity *= Vector2(0.925, 0.925)

func _on_hurt_box_entered(body: Node2D):
  if body is Enemy:
    body.queue_free()
    health -= 1
    lost_health.emit()
