class_name Player extends CharacterBody2D
const DEBUG_JUMP_INDICATOR = preload("uid://1n5lkptfbcul")

#region /// 就绪变量
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_stand: CollisionShape2D = $CollisionStand
@onready var collision_crouch: CollisionShape2D = $CollisionCrouch
@onready var one_way_platfrom_shapecast: ShapeCast2D = $OneWayPlatfromShapecast
@onready var animation_player: AnimationPlayer = $AnimationPlayer
#endregion

#region /// 导出变量，可在编辑器中修改
@export var move_speed : float = 150.0
@export var max_fall_velocity : float = 600.0
#endregion

#region /// 状态机参数
var states : Array[PlayerState]
var current_state : PlayerState :
	get : return states.front()
var previous_state : PlayerState :
	get : return states[1]
#endregion

#region /// 常规参数
var direction : Vector2 = Vector2.ZERO
var gravity : float = 980
var gravity_multiplier : float = 1.0
#endregion

func _ready() -> void:
	initalize_states()
	#Engine.time_scale = 0.5
	pass

# 当一个输入事件尚未被处理时，才进入此方法，执行当前状态的输入处理方法
func _unhandled_input(event : InputEvent) -> void:
	change_state(current_state.handle_input(event))
	pass

# 渲染更新进程，每渲染一帧就运行一次
func _process(_delta: float) -> void:
	update_direction()
	change_state(current_state.process(_delta))
	pass

# 物理更新进程，每秒60次
func _physics_process(_delta: float) -> void:
	velocity.y += gravity * _delta * gravity_multiplier
	# 限制y方向上的力在-1000到+600之间，-1000是最大上升力，+600是最大下落力
	velocity.y = clampf(velocity.y, -1000.0, max_fall_velocity)
	move_and_slide()
	change_state(current_state.physics_process(_delta))
	pass

func initalize_states() -> void:
	states = []
	# 获取所有状态
	for c in $States.get_children():
		if c is PlayerState:
			states.append(c)
			c.player = self
	
	if states.size() == 0:
		return
	
	# 初始化所有状态
	for state in states:
		state.init()
	
	change_state(current_state)
	current_state.enter()
	$Label.text = current_state.name
	pass

func change_state(new_state : PlayerState) -> void:
	# 检查是否有新状态、新状态和当前状态相同则不处理
	if new_state == null:
		return
	elif new_state == current_state:
		return
	# 则退出当前状态
	if current_state:
		current_state.exit()
	# 加入新的状态
	states.push_front(new_state)
	current_state.enter()
	states.resize(3)
	$Label.text = current_state.name
	#if current_state.name == "Idle":
		#$Label.text = "待机"
	#elif current_state.name == "Run":
		#$Label.text = "奔跑"
	#elif current_state.name == "Crouch":
		#$Label.text = "蹲下"
	#elif current_state.name == "Jump":
		#$Label.text = "跳跃"
	#elif current_state.name == "Fall":
		#$Label.text = "下落"
	pass

func update_direction() -> void:
	var prev_direction : Vector2 = direction
	
	var x_axis = Input.get_axis("left", "right")
	var y_axis = Input.get_axis("up", "down")
	direction = Vector2(x_axis, y_axis)
	
	if prev_direction.x != direction.x:
		if direction.x < 0:
			sprite.flip_h = true
		elif direction.x > 0:
			sprite.flip_h = false
	pass

#调试指示器，实例化一个指示器场景附加到场景根节点，并在3秒后移除
func add_debug_indicator(color : Color = Color.RED) -> void:
	var d : Node2D = DEBUG_JUMP_INDICATOR.instantiate()
	get_tree().root.add_child(d)
	d.global_position = global_position
	d.modulate = color
	await get_tree().create_timer(3.0).timeout
	d.queue_free()
	pass
