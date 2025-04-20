extends Interface

func _ready() -> void:
  self.create_room()

func _process(_delta: float) -> void:
  var to_print = ""
  var msg = [""]
  while !["None", "Closed"].has(msg[0]):
    if !msg[0].is_empty():
      to_print += msg[0] + " "
      for d in msg[1]:
        to_print += "%4.2f " % d
      to_print += "\n"
    msg = self.receive()
  if !to_print.is_empty():
    printraw(to_print)

  if Input.is_action_just_pressed("mouse_left_click"):
    var mouse_pos = get_viewport().get_mouse_position()
    self.send("click", [mouse_pos.x, mouse_pos.y])