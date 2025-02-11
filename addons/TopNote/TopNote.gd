@tool
extends EditorPlugin
class_name TopNote

## TopNote plugin script & panel manager
##
## [b]Note:[/b] [color=yellow]experimental[/color] | You can use modify members for customize plugin with [code]@tool[/code] scripts. But just change propeties of members!

const PLACE = "res://addons/TopNote/settings.txt" ## File path to save settings
const DEFAULT = PanelPlace.BOTTOM ## Default place for panel

enum PanelPlace { ## Available places for panel
	BOTTOM, ## [color=orange]Panel[/color] | Buttom panel (together with Output, Debug, Animation, etc) [i][color=green]Recommended & Default[/color][/i]
	TOOLBAR, ## [color=orange]Popup[/color] | Main editor toolbar (next to play buttons)
	SPATIAL_EDITOR_MENU, ## [color=orange]Popup[/color] | The toolbar that appears when 3D editor is active
	SPATIAL_EDITOR_SIDE_LEFT, ## [color=yellow]experimental[/color] | [color=orange]Panel[/color] | Left sidebar of the 3D editor.
	SPATIAL_EDITOR_SIDE_RIGHT, ## [color=yellow]experimental[/color] | [color=orange]Panel[/color] | Right sidebar of the 3D editor.
	SPATIAL_EDITOR_BOTTOM, ## [color=yellow]experimental[/color] | [color=orange]Panel[/color] | Bottom panel of the 3D editor.
	CANVAS_EDITOR_MENU, ## [color=orange]Popup[/color] | The toolbar that appears when 2D editor is active
	CANVAS_EDITOR_SIDE_LEFT, ## [color=yellow]experimental[/color] | [color=orange]Panel[/color] | Left sidebar of the 2D editor.
	CANVAS_EDITOR_SIDE_RIGHT, ## [color=yellow]experimental[/color] | [color=orange]Panel[/color] | Right sidebar of the 2D editor.
	CANVAS_EDITOR_BOTTOM, ## [color=yellow]experimental[/color] | [color=orange]Panel[/color] | Bottom panel of the 2D editor.
	INSPECTOR, ## [color=yellow]experimental[/color] | [color=orange]Panel[/color] | Bottom section of the inspector.
	SLOT_LEFT_UL, ## [color=orange]Panel[/color] | Dock slot, left side, upper-left.
	SLOT_LEFT_BL, ## [color=orange]Panel[/color] | Dock slot, left side, bottom-left.
	SLOT_LEFT_UR, ## [color=orange]Panel[/color] | Dock slot, left side, upper-right.
	SLOT_LEFT_BR, ## [color=orange]Panel[/color] | Dock slot, left side, bottom-right.
	SLOT_RIGHT_UL, ## [color=orange]Panel[/color] | Dock slot, right side, upper-left.
	SLOT_RIGHT_BL, ## [color=orange]Panel[/color] | Dock slot, right side, bottom-left.
	SLOT_RIGHT_UR, ## [color=orange]Panel[/color] | Dock slot, right side, upper-right.
	SLOT_RIGHT_BR, ## [color=orange]Panel[/color] | Dock slot, right side, bottom-right.
}

static var place: PanelPlace ## [color=lightblue]Static[/color] | Current place for panel, from [enum PanelPlaces]
static var panel: Control ## [color=lightblue]Static[/color] | Instanced panel
static var button: Button ## [color=lightblue]Static[/color] | Instanced button (for show popup)
static var popup: Window ## [color=lightblue]Static[/color] | Popup window (parent of [member panel] in popup taged places)
var move_list: ItemList ## [color=lightgreen]Dynamic[/color] | Item list for move to function (from [member panel])

func _enter_tree():
	_load_place()
	panel = preload("res://addons/TopNote/Panel/Panel.tscn").instantiate()
	button = preload("res://addons/TopNote/Panel/Button.tscn").instantiate()
	popup = preload("res://addons/TopNote/Panel/Popup.tscn").instantiate()
	move_list = panel.get_child(1).get_child(0)
	if not move_list.item_selected.is_connected(self._move_to): move_list.item_selected.connect(self._move_to)
	_add_panel()


func _exit_tree():
	_remove_panel()


func _move_to(index):
	if place in [PanelPlace.TOOLBAR, PanelPlace.SPATIAL_EDITOR_MENU]:
		popup.hide()
	var file = FileAccess.open(PLACE, FileAccess.WRITE)
	file.store_string(str(index))
	file.close()
	_remove_panel()
	_enter_tree()


func _add_panel():
	if place in [PanelPlace.TOOLBAR, PanelPlace.SPATIAL_EDITOR_MENU]:
		popup.add_child(panel)
	match place:
		PanelPlace.BOTTOM:
			var button = add_control_to_bottom_panel(panel, "Top Note")
			button.tooltip_text = "TopNote"
		PanelPlace.TOOLBAR:
			EditorInterface.get_base_control().add_child(popup)
			add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, button)
			button.pressed.connect(self._show_popup)
		PanelPlace.SPATIAL_EDITOR_MENU:
			EditorInterface.get_base_control().add_child(popup)
			add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, button)
			button.flat = true
			button.pressed.connect(self._show_popup)
		PanelPlace.SPATIAL_EDITOR_SIDE_LEFT:
			add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_LEFT, panel)
		PanelPlace.SPATIAL_EDITOR_SIDE_RIGHT:
			add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_RIGHT, panel)
		PanelPlace.SPATIAL_EDITOR_BOTTOM:
			add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_BOTTOM, panel)
		PanelPlace.CANVAS_EDITOR_MENU:
			EditorInterface.get_base_control().add_child(popup)
			add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, button)
			button.flat = true
			button.pressed.connect(self._show_popup)
		PanelPlace.CANVAS_EDITOR_SIDE_LEFT:
			add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_LEFT, panel)
		PanelPlace.CANVAS_EDITOR_SIDE_RIGHT:
			add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_RIGHT, panel)
		PanelPlace.CANVAS_EDITOR_BOTTOM:
			add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, panel)
		PanelPlace.INSPECTOR:
			add_control_to_container(EditorPlugin.CONTAINER_INSPECTOR_BOTTOM, panel)
		PanelPlace.SLOT_LEFT_UL:
			add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, panel)
		PanelPlace.SLOT_LEFT_BL:
			add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BL, panel)
		PanelPlace.SLOT_LEFT_UR:
			add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, panel)
		PanelPlace.SLOT_LEFT_BR:
			add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, panel)
		PanelPlace.SLOT_RIGHT_UL:
			add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, panel)
		PanelPlace.SLOT_RIGHT_BL:
			add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, panel)
		PanelPlace.SLOT_RIGHT_UR:
			add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UR, panel)
		PanelPlace.SLOT_RIGHT_BR:
			add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BR, panel)


func _remove_panel():
	move_list.item_selected.disconnect(self._move_to)
	match place:
		PanelPlace.BOTTOM:
			remove_control_from_bottom_panel(panel) # <- WARNING
		PanelPlace.TOOLBAR:
			remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, button)
			EditorInterface.get_base_control().remove_child(popup)
			button.pressed.disconnect(self._show_popup)
		PanelPlace.SPATIAL_EDITOR_MENU:
			remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, button)
			EditorInterface.get_base_control().remove_child(popup)
			button.pressed.disconnect(self._show_popup)
		PanelPlace.SPATIAL_EDITOR_SIDE_LEFT:
			remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_LEFT, panel)
		PanelPlace.SPATIAL_EDITOR_SIDE_RIGHT:
			remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_RIGHT, panel)
		PanelPlace.SPATIAL_EDITOR_BOTTOM:
			remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_BOTTOM, panel)
		PanelPlace.CANVAS_EDITOR_MENU:
			EditorInterface.get_base_control().remove_child(popup)
			remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, button)
			button.pressed.disconnect(self._show_popup)
		PanelPlace.CANVAS_EDITOR_SIDE_LEFT:
			remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_LEFT, panel)
		PanelPlace.CANVAS_EDITOR_SIDE_RIGHT:
			remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_RIGHT, panel)
		PanelPlace.CANVAS_EDITOR_BOTTOM:
			remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, panel)
		PanelPlace.INSPECTOR:
			remove_control_from_container(EditorPlugin.CONTAINER_INSPECTOR_BOTTOM, panel)
		_:
			remove_control_from_docks(panel)


func _show_popup():
	popup.show()


func _load_place():
	if not FileAccess.file_exists(PLACE):
		place = DEFAULT
		return
	var file = FileAccess.open(PLACE, FileAccess.READ)
	place = int(file.get_as_text())
	file.close()
	if place == null:
		place = DEFAULT
		file = FileAccess.open(PLACE, FileAccess.WRITE)
		file.store_string(str(DEFAULT))
		file.close()


func _get_plugin_name():
	return "Top Note"

func _get_plugin_icon():
	return load("res://addons/TopNote/icon.svg")

func _handles(object: Object) -> bool:
	return object is Resource

func _edit(object: Object) -> void:
	if not is_instance_valid(panel): return
	if place in [PanelPlace.TOOLBAR, PanelPlace.CANVAS_EDITOR_MENU, PanelPlace.SPATIAL_EDITOR_MENU]: return
	if object is Resource and not object is Script:
		make_bottom_panel_item_visible(panel)
		panel.open_linked_note(object)
