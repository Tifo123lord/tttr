extends CanvasLayer

func _ready() -> void:
	for button in get_tree().get_nodes_in_group("mobile_input"):
		button.button_down.connect(_press.bind(button.get_meta("action", "")))
		button.button_up.connect(_release.bind(button.get_meta("action", "")))

func _press(action: String) -> void:
	Input.action_press(action)

func _release(action: String) -> void:
	Input.action_release(action)
