#  SuperTux - A 2D, Open-Source Platformer Game licensed under GPL-3.0-or-later
#  Copyright (C) 2022 Alexander Small <alexsmudgy20@gmail.com>
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 3
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
extends Control

enum IGNORE_BUTTON {Key,Pad,None}

export var show_button_type_names = false
export var action_to_remap = "move_left"
var being_changed = Global.REBIND_TYPE.None

onready var keyrebind = $ButContainer/RemapButtonKey
onready var gamepadrebind = $ButContainer/RemapButtonGamepad
onready var label = $ButContainer/Label
onready var button_type_text = [$ButContainer/RemapButtonKey/KeyboardText, $ButContainer/RemapButtonGamepad/ControllerText]

func _ready():
	for label in button_type_text:
		label.visible = show_button_type_names
	
	label.text = action_to_remap.capitalize()
	_set_button_text_to_control_action()

func _set_button_text_to_control_action(ignore_which: int = IGNORE_BUTTON.None):
	var keyact: InputEventKey = null
	var padact: InputEventJoypadButton = null
	var act_list = InputMap.get_action_list(action_to_remap)
	
	for i in act_list:
		if i is InputEventKey:
			keyact = i
		elif i is InputEventJoypadButton:
			padact = i
	if ignore_which != IGNORE_BUTTON.Key:
		keyrebind.flat = false
		keyrebind.disabled = false
		keyrebind.text = OS.get_scancode_string(keyact.scancode).to_upper()
	if ignore_which != IGNORE_BUTTON.Pad:
		gamepadrebind.flat = false
		gamepadrebind.disabled = false
		gamepadrebind.text = Input.get_joy_button_string(padact.button_index).to_upper()

func _on_RemapButtonKey_pressed():
	self.being_changed = Global.REBIND_TYPE.Key

func _on_RemapButtonGamepad_pressed():
	self.being_changed = Global.REBIND_TYPE.Gamepad

func _input(event):
	if being_changed == Global.REBIND_TYPE.None: return
	if event.is_echo(): return
	
	match being_changed:
		Global.REBIND_TYPE.Key:
			if event is InputEventKey:
				self.being_changed = Global.REBIND_TYPE.None
				var del_event: InputEvent
				var list = InputMap.get_action_list(action_to_remap)
				
				for i in list:
					if i is InputEventKey:
						del_event = i
				
				InputMap.action_erase_event(action_to_remap, del_event)
				InputMap.action_add_event(action_to_remap, event)
				
				print("Remapped key " + str(action_to_remap) + " to input " + event.as_text())
		Global.REBIND_TYPE.Gamepad:
			if event is InputEventJoypadButton:
				if not Input.is_joy_button_pressed(0, event.button_index): return
				self.being_changed = Global.REBIND_TYPE.None
				var del_event: InputEvent
				var list = InputMap.get_action_list(action_to_remap)
				
				for i in list:
					if i is InputEventJoypadButton:
						del_event = i
				
				InputMap.action_erase_event(action_to_remap, del_event)
				InputMap.action_add_event(action_to_remap, event)
				
				print("Remapped gamepad button " + str(action_to_remap) + " to input " + Input.get_joy_button_string(event.button_index))

# Makes the button say "Press a key..." when the button is being remapped
func _update_button_state(new_value):
	being_changed = new_value
	
	match being_changed:
		Global.REBIND_TYPE.Key:
			keyrebind.flat = true
			keyrebind.disabled = true
			keyrebind.text = "Press a Key..."
			_set_button_text_to_control_action(IGNORE_BUTTON.Key)
		Global.REBIND_TYPE.Gamepad:
			gamepadrebind.flat = true
			gamepadrebind.disabled = true
			gamepadrebind.text = "Press a Button..."
			_set_button_text_to_control_action(IGNORE_BUTTON.Pad)
		_:
			_set_button_text_to_control_action()

func _on_RemapButtonKey_mouse_entered():
	if being_changed != Global.REBIND_TYPE.Key: keyrebind.text = "Change"

func _on_RemapButtonKey_mouse_exited():
	if being_changed != Global.REBIND_TYPE.Key: _set_button_text_to_control_action()

func _on_RemapButtonGamepad_mouse_entered():
	if being_changed != Global.REBIND_TYPE.Gamepad: gamepadrebind.text = "Change"

func _on_RemapButtonGamepad_mouse_exited():
	if being_changed != Global.REBIND_TYPE.Gamepad: _set_button_text_to_control_action()
