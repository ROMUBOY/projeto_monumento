extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var label: Label = $CanvasLayer/PanelContainer/Label
@onready var panel_container: PanelContainer = $CanvasLayer/PanelContainer

const base_text = "Press [F] to "

var active_areas = []
var can_interact = true

func register_area(area: InteractionArea):
	active_areas.push_back(area)

func unregister_area(area: InteractionArea):
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)

func _process(delta: float) -> void:
	if active_areas.size() > 0 && can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player)
		label.text = base_text + active_areas[0].action_name
		##label.global_position = active_areas[0].global_position
		 ## Pega a posição global do nó fora do CanvasLayer
		#var global_position = active_areas[0].get_global_position()
		#
		## Obtém a transformação do CanvasLayer
		#var canvas_transform = label.get_viewport().get_canvas_transform()
		#
		## Converte a posição global para a posição local do CanvasLayer
		#var local_position = canvas_transform.affine_inverse() * global_position
		#
		## Define a posição do nó dentro do CanvasLayer
		#label.position = local_position
		#label.global_position.y -= 36
		#label.global_position.x -= label.size.x / 2
		panel_container.show()
	else:
		panel_container.hide()

func _sort_by_distance_to_player(area1, area2):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		
	var area1_to_player = player.global_position.distance_to(area1.global_position)
	var area2_to_player = player.global_position.distance_to(area2.global_position)
	return area1_to_player < area2_to_player

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && can_interact:
		if active_areas.size() > 0:
			can_interact = false
			panel_container.hide()
			
			await active_areas[0].interact.call()
			
			can_interact = true
