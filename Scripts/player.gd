extends AnimatableBody2D

const MAX_SPEED = 2750

@onready var poly = $Polygon2D
@onready var collider = $CollisionPolygon2D
@onready var gun = $Gun

var velocity = Vector2(0, 0)

var bullets = []

func _ready() -> void:
  collider.polygon = poly.polygon

func _physics_process(delta: float) -> void:
  if Input.is_action_just_pressed("left") or \
    Input.is_action_just_pressed("right"):
      velocity.x *= 0.85
  if Input.is_action_just_pressed("forward") or \
    Input.is_action_just_pressed("back"):
      velocity.y *= 0.85
  var move = Vector2(Input.get_axis("left", "right"), Input.get_axis("forward", "back"))
  velocity += move * delta * MAX_SPEED
  velocity = clamp(velocity, Vector2(-MAX_SPEED, -MAX_SPEED), Vector2(MAX_SPEED, MAX_SPEED))
  position += velocity * delta
  velocity *= Vector2(0.925, 0.925)

  var aim = Vector2(Input.get_axis("aim_left", "aim_right"), Input.get_axis("aim_forward", "aim_back")).normalized()
  if aim:
    var new_rotation = aim.rotated(PI / 2.0).angle()
    gun.rotation = lerp_angle(gun.rotation, new_rotation, 0.15)

  if Input.is_action_just_pressed("shoot"):
    print("Shoot")
