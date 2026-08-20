class_name PlayerStateJump extends PlayerState

@export var jump_velocity : float = 450.0

func init() -> void:
	pass
	
# 进入此状态时调用
func enter() -> void:
	player.animation_player.play("jump")
	player.animation_player.pause()
	player.add_debug_indicator(Color.LIME_GREEN)
	player.velocity.y = -jump_velocity
	
	# 缓冲区跳跃bug修复:jump变为fall后0.1s左右按下短跳，结果是大跳
	if player.previous_state == fall and not Input.is_action_pressed("jump"):
		# 异步等待下一物理帧，再处理玩家坠落状态
		await get_tree().physics_frame
		player.velocity.y *= 0.5
		player.change_state(fall)
	pass

# 退出此状态时调用
func exit() -> void:
	player.add_debug_indicator(Color.YELLOW)
	pass
	
# 输入被按下时所做的处理
func handle_input(_event : InputEvent) -> PlayerState:
	# 跳跃过程中玩家释放跳跃键，则说明玩家想短跳，释放时直接进入坠落状态，将速度置为0会很突兀，衰减0.5倍效果比较自然
	if _event.is_action_released("jump"):
		player.velocity.y *= 0.5
		return fall
	return next_state

# 处理此状态中渲染进程时发生的事情
func process(_delta: float) -> PlayerState:
	set_jump_frame()
	return next_state
	
# 处理此状态中物理进程发生的事情
func physics_process(_delta: float) -> PlayerState:
	if player.is_on_floor():
		return idle
	elif player.velocity.y >= 0:
		return fall
	player.velocity.x = player.direction.x * player.move_speed
	return next_state
	
# 设置跳跃时动画帧
func set_jump_frame() -> void:
	# 玩家y方向上的力：-450到0之间，-450~0是向上跳跃
	# 跳跃动画帧数：0到1之间，其中0~0.5是向上跳跃动画帧，0.5~1是下落动画帧
	# 将y方向的力转换为跳跃动画帧数
	var frame : float = remap(player.velocity.y, -jump_velocity, 0.0, 0.0, 0.5)
	# 动画在跳跃状态进入时已设置暂停，此时需要强制更新动画
	player.animation_player.seek(frame, true)
	pass
