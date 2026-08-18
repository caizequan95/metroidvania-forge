@icon("res://player/states/state.svg")
class_name PlayerState extends Node

var player : Player
var next_state : PlayerState

#region /// state references
# 这里是所有其他状态相关的参数
#endregion

# 状态初始化时调用
func init() -> void:
	pass
	
# 进入此状态时调用
func enter() -> void:
	pass

# 退出此状态时调用
func exit() -> void:
	pass
	
# 输入被按下时所做的处理
func handle_input(_event : InputEvent) -> PlayerState:
	return next_state

# 处理此状态中渲染进程时发生的事情
func process(delta: float) -> PlayerState:
	return next_state
	
# 处理此状态中物理进程发生的事情
func physics_process(delta: float) -> PlayerState:
	return next_state
	
