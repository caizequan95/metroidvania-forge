class_name PlayerStateCrouch extends PlayerState

# 减速系数，玩家奔跑时按下下蹲，速度不会立即变为0，而是逐渐降低
@export var deceleration_rate : float = 10

func init() -> void:
	pass
	
# 进入此状态时调用
func enter() -> void:
	player.animation_player.play("crouch")
	player.collision_stand.disabled = true
	player.collision_crouch.disabled = false
	pass

# 退出此状态时调用
func exit() -> void:
	player.collision_stand.disabled = false
	player.collision_crouch.disabled = true
	pass
	
# 输入被按下时所做的处理
func handle_input(_event : InputEvent) -> PlayerState:
	if _event.is_action_pressed("jump"):
		# 默认形状投射检测关闭以节省计算资源，仅在蹲伏且按下跳跃键时强制形状投射检测更新
		player.one_way_platfrom_shapecast.force_shapecast_update()
		if player.one_way_platfrom_shapecast.is_colliding() == true:
			player.position.y += 4
			return fall
		return jump
	return next_state

# 处理此状态中渲染进程时发生的事情
func process(delta: float) -> PlayerState:
	if player.direction.y <= 0.5:
		return idle
	return next_state
	
# 处理此状态中物理进程发生的事情
func physics_process(delta: float) -> PlayerState:
	player.velocity.x -= player.velocity.x * deceleration_rate * delta
	if player.is_on_floor() == false:
		return fall
	return next_state
	
