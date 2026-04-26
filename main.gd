extends Control # 继承Control类。

@onready var user_name: TextEdit = $UserName # 声明变量text_edit并将其绑定到节点UserName上。
@onready var black_seat: Label = $BlackSeat # 声明变量black_seat并将其绑定到节点BlackSeat上。
@onready var white_seat: Label = $WhiteSeat # 声明变量white_seat并将其绑定到节点WhiteSeat上。
@onready var gobang_board: GobangBoard = $GobangBoard # 声明变量gobang_board并将其绑定到节点GobangBoard上。
@onready var result: Panel = $Result # 声明变量result并将其绑定到节点Result上。



const PORT = 8888 # 定义常量PORT。

var peer := ENetMultiplayerPeer.new() # 声明变量peer并创建ENetMultiplayerPeer实例。


# Called when the node enters the scene tree for the first time.
# 混合使用制表符和空格进行缩进。
func _ready() -> void: # 节点第一次进入场景树时调用。
	# 监听事件
	multiplayer.peer_connected.connect(on_peer_connected) # 连接到其他玩家时触发。
	gobang_board.game_over.connect(on_game_over) # 游戏结束时触发。




# 创建房间，局域网内的服务端
func _on_host_btn_pressed() -> void: # 点击Host按钮，创建房间。
	var err := peer.create_server(PORT) # 创建服务端，绑定端口为8888。
	if err!= OK: # 如果创建服务端失败，打印错误信息。
		print(err) # 打印错误信息。
		return # 退出函数。
	multiplayer.multiplayer_peer = peer # 将创建好的服务端实例赋值给全局变量。
	black_seat.text = user_name.text # 设置黑棋座位的用户名。
	Global.uid = multiplayer.get_unique_id() # 加入自己的唯一标识符。
	
func _on_join_btn_pressed() -> void: # 加入房间，连接到局域网内的服务端。
	var err := peer.create_client("127.0.0.1", PORT) # 创建客户端，连接到本地的8888端口。
	if err!= OK: # 如果创建客户端失败，打印错误信息。
		print(err) # 打印错误信息。
		return # 退出函数。
	multiplayer.multiplayer_peer = peer # 将创建好的客户端实例赋值给全局变量。
	white_seat.text = user_name.text # 设置白棋座位的用户名。
	Global.uid = multiplayer.get_unique_id() # 加入自己的唯一标识符。

func on_peer_connected(id: int): # 监听到其他玩家连接时触发。
	print("peer connected ", id)  # 打印连接信息。
	# 设置对方的用户名
	set_seat_name.rpc(user_name.text) # 调用远程过程调用，设置对方的用户名。




@rpc("any_peer")   # 声明远程过程调用。
func set_seat_name(s: String): # 设置座位的用户名。
	if multiplayer.is_server(): # 判断是否是服务端。
		white_seat.text = s # 设置白棋座位的用户名。
		# get_remote_sender_id在rpc函数中有效，获取发送端的peer id
		Global.add_peer(multiplayer.get_remote_sender_id()) # 加入对手的唯一标识符。
	else: # 客户端
		black_seat.text = s # 设置黑棋座位的用户名。
		Global.add_peer(multiplayer.get_unique_id()) # 加入自己的唯一标识符。



func on_game_over(): # 游戏结束时触发。
	if not Global.is_my_turn(): # 判断是否是自己的回合。
		var label = result.get_node("Label") as Label # 获取Label节点。
		label.text = "YOU LOSE" # 设置Label的文本。
	result.show() # 显示结果面板。
