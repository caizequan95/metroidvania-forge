class_name PlayerStateFall extends PlayerState

# 土狼时间，允许玩家刚进入掉落状态的一小段时间内仍可以跳跃
@export var coyote_time : float = 0.125
# 跳跃缓冲时间，允许玩家掉落即将到达地面前一小段时间内按下的跳跃键可以在玩家着地后立即起跳
@export var jump_buffer_time : float = 0.2
# 掉落时重力系数略微增加，提升游戏利落感
@export var fall_gravity_multiplier : float = 1.165
var coyote_timer : float = 0
var buffer_timer : float = 0

func init() -> void:
	pass
	
# 进入此状态时调用
func enter() -> void:
	player.animation_player.play("jump")
	player.animation_player.pause()
	player.gravity_multiplier = fall_gravity_multiplier
	if player.previous_state == jump:
		coyote_timer = 0
	else:
		coyote_timer = coyote_time
	pass

# 退出此状态时调用
func exit() -> void:
	player.gravity_multiplier = 1.0
	buffer_timer = 0
	pass
	
# 输入被按下时所做的处理
func handle_input(_event : InputEvent) -> PlayerState:
	# 缓冲跳，坠落过程中按起跳开始计时（0.2s），计时结束前人物接触地面状态改变，则算作缓冲跳，人物不进入idle状态，而是直接进入jump状态，这样手感更好
	# 比如人物下落过程中发现前方滚石想要立即躲避，实际未到达地面按下了跳跃键，此功能会在玩家接触地面时立即起跳以躲避滚石
	if _event.is_action_pressed("jump"):
		if coyote_timer > 0:
			return jump
		else:
			buffer_timer = jump_buffer_time
	return next_state

# 处理此状态中渲染进程时发生的事情
func process(delta: float) -> PlayerState:
	coyote_timer -= delta
	buffer_timer -= delta
	set_jump_frame()
	return next_state
	
# 处理此状态中物理进程发生的事情
func physics_process(delta: float) -> PlayerState:
	if player.is_on_floor():
		#player.add_debug_indicator(Color.RED)
		if buffer_timer > 0:
			return jump
		return idle
	player.velocity.x = player.direction.x * player.move_speed
	return next_state
	
# 设置跳跃时动画帧
func set_jump_frame() -> void:
	# 玩家y方向上的力：0~600是向下坠落，设置了玩家下坠最大速度600
	# 跳跃动画帧数：0到1之间，其中0~0.5是向上跳跃动画帧，0.5~1是下落动画帧
	# 将y方向的力转换为跳跃动画帧数
	var frame : float = remap(player.velocity.y, 0, player.max_fall_velocity, 0.5, 1.0)
	# 动画在跳跃状态进入时已设置暂停，此时需要强制更新动画
	player.animation_player.seek(frame, true)
	pass
