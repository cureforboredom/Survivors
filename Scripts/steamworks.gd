extends Node

func _ready() -> void:
  initialize_steam()

func initialize_steam() -> void:
  var initialize_response: Dictionary = Steam.steamInitEx()
  print("Did Steam initialize?: %s" % initialize_response)

  if initialize_response['status'] > Steam.STEAM_API_INIT_RESULT_OK:
    print("Failed to initialize Steam, shutting down: %s" % initialize_response)
    get_tree().quit()
    
func _process(_delta: float) -> void:
  Steam.run_callbacks()