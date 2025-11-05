# InputManager.gd
# This script should be set as an Autoload (Singleton) in Project Settings.
extends Node

# --- Signals for System/Meta Toggles (Prioritizes UI) ---
# Signals must be emitted using .emit() in Godot 4.x
signal pause_toggled
signal selected
signal accepted
signal move_up
signal move_down
signal move_left
signal move_right

# --- 1. System/Meta Input Handling (Uses _unhandled_input) ---

# This function only receives input events that have NOT been consumed by 
# UI elements (Control nodes) or other _input() functions.
func _unhandled_input(event: InputEvent) -> void:
	var handled :bool = false
	# A. Pause Toggle (Typically ESC or a dedicated 'Start' button)
	if event.is_action_pressed("ui_cancel"):
		# We assume if the UI didn't take it, the user wants a system action.
		pause_toggled.emit()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_accept"):
		# We assume if the UI didn't take it, the user wants a system action.
		accepted.emit()
		get_viewport().set_input_as_handled()
		return		
	if event.is_action_pressed("ui_select"):
		# We assume if the UI didn't take it, the user wants a system action.
		selected.emit()
		get_viewport().set_input_as_handled()
		return		
				
	if event.is_action_pressed("ui_up"):
		# We assume if the UI didn't take it, the user wants a system action.
		move_up.emit() 
		handled = true
	if event.is_action_pressed("ui_down"):
		# We assume if the UI didn't take it, the user wants a system action.
		move_down.emit()
		handled = true
	if event.is_action_pressed("ui_left"):
		# We assume if the UI didn't take it, the user wants a system action.
		move_left.emit()
		handled = true
	if event.is_action_pressed("ui_right"):
		# We assume if the UI didn't take it, the user wants a system action.
		move_right.emit()
		handled = true
				
		
	if handled:
		get_viewport().set_input_as_handled()
		return
		
		
# --- 2. Gameplay Input Access (Called from _process or _physics_process) ---
# A. Unified Movement Vector (Combines Digital/Analog Input)
# This is ideal for CharacterBody movement in 2D or 3D.
func get_movement_vector() -> Vector2:
	# Input.get_axis() automatically combines opposing input actions 
	# (e.g., 'A' and 'D', or Left Stick X-axis) into a single float from -1.0 to 1.0.
	
	# NOTE: You must define 'move_left', 'move_right', 'move_forward', 
	# and 'move_backward' in the Project Settings Input Map.
	var x_axis: float = Input.get_axis("move_left", "move_right")
	var y_axis: float = Input.get_axis("move_forward", "move_backward")
	
	# Normalize the vector to prevent faster diagonal movement (e.g., length is 1.0).
	return Vector2(x_axis, y_axis).normalized()

# B. Continuous/Held Actions
# Returns true as long as the action is held down (used for movement, charging, etc.).
func is_action_pressed(action_name: StringName) -> bool:
	return Input.is_action_pressed(action_name)

# C. One-Shot Actions
# Returns true only on the frame the action was initially pressed (used for jump, fire, etc.).
func is_action_just_pressed(action_name: StringName) -> bool:
	return Input.is_action_just_pressed(action_name)

# D. Mouse/Camera Look (Analog Input using Delta)
# This function is used to get the rotation delta from mouse movement.
# NOTE: This uses the raw event data, typically handled in a separate camera script's _input().
# However, defining the check here maintains consistency.
# Since mouse look often needs high priority and consumption, this function 
# checks the raw event type, often used by a camera script for mouse look.
func get_mouse_look_delta(event: InputEvent) -> Vector2:
	if event is InputEventMouseMotion:
		# returns the relative movement of the mouse since the last frame
		return event.relative
	return Vector2.ZERO

# E. Get Raw Axis Value (Useful for Triggers)
# Returns a float between 0.0 and 1.0 for analog triggers (e.g., L2/R2).
func get_raw_axis_value(action_name: StringName) -> float:
	# Note: Requires the action to be set up as a trigger/axis in the Input Map.
	return Input.get_action_strength(action_name)
