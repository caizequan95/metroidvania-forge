class_name Player extends CharacterBody2D

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
#endregion

func _ready() -> void:
	initalize_states()
	pass

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
	velocity.y += gravity * _delta
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
	#current_state.enter()
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
	pass

func update_direction() -> void:
	#var prev_direction : Vector2 = direction
	direction = Input.get_vector("left", "right", "up", "down")
	
	pass
