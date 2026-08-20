class_name PlayerStateRun extends PlayerState

func init() -> void:
	pass
	
# 进入此状态时调用
func enter() -> void:
	player.animation_player.play("run")
	pass

# 退出此状态时调用
func exit() -> void:
	pass
	
# 输入被按下时所做的处理
func handle_input(_event : InputEvent) -> PlayerState:
	if _event.is_action_pressed("jump"):
		return jump
	return next_state

# 处理此状态中渲染进程时发生的事情
func process(delta: float) -> PlayerState:
	if player.direction.x == 0:
		return idle
	elif player.direction.y > 0.5:
		return crouch
	return next_state
	
# 处理此状态中物理进程发生的事情
func physics_process(delta: float) -> PlayerState:
	player.velocity.x = player.direction.x * player.move_speed
	if player.is_on_floor() == false:
		return fall
	return next_state
	
