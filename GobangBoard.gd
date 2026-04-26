class_name GobangBoard #定义类名
extends Control #继承自Control类




#设置棋盘的大小
const BOARD_SIZE = 15 #棋盘的格数
const CELL_SIZE = 40 #每个格子的大小

#棋盘状态枚举
enum {
	EMPTY, #空格
	BLACK, #黑棋
	WHITE #白棋
}

signal game_over #游戏结束信号

var is_game_over := false #游戏是否结束


#初始化棋盘状态 二维数组
var board = [] #二维数组

var cur_color = BLACK #当前的颜色

#初始化棋盘
func _ready() -> void: #初始化棋盘
	#初始化棋盘状态
	for i in range(BOARD_SIZE): #初始化二维数组
		board.append([]) #添加一行
		for j in range(BOARD_SIZE): #添加一列
			board[i].append(EMPTY) #添加空格

#绘制棋盘
func _draw() -> void: #绘制棋盘
	#绘制棋盘线
	for i in range(BOARD_SIZE): #遍历棋盘每个格子
		draw_line(Vector2(i * CELL_SIZE, 0), Vector2(i * CELL_SIZE, (BOARD_SIZE - 1) * CELL_SIZE), Color.BLACK) #绘制横线
		draw_line(Vector2(0, i * CELL_SIZE), Vector2((BOARD_SIZE - 1) * CELL_SIZE, i * CELL_SIZE), Color.BLACK) #绘制竖线

	#绘制棋子
	for i in range(BOARD_SIZE): #遍历棋盘每个格子
		for j in range(BOARD_SIZE): #遍历棋盘每个格子
			var cell_Color = board[i][j] #获取棋子颜色
			if cell_Color == BLACK: #绘制黑棋
				draw_circle(Vector2(i * CELL_SIZE, j * CELL_SIZE), CELL_SIZE / 3.0, Color.BLACK) #绘制圆形
			elif cell_Color == WHITE: #绘制白棋
				draw_circle(Vector2(i * CELL_SIZE, j * CELL_SIZE), CELL_SIZE / 3.0, Color.WHITE) #绘制圆形

#处理输入 _input->_gui_input->unhandled_input
func _gui_input(event : InputEvent) -> void: #处理鼠标事件
	if event is InputEventMouseButton and event.is_pressed(): #鼠标左键按下

		if Global.is_my_turn() == false or is_game_over: #如果不是自己的回合或者游戏结束
			return #退出游戏

		event = event as InputEventMouseButton #转换为鼠标事件
		var pos = event.position #获取鼠标位置
		var x = int((pos.x + CELL_SIZE / 2.0) / CELL_SIZE) #计算所在的格子x坐标
		var y = int((pos.y + CELL_SIZE / 2.0) / CELL_SIZE) #计算所在的格子y坐标
		#检测坐标是否合法
		if x >= 0 and x < BOARD_SIZE and y >= 0 and y < BOARD_SIZE and board[x][y] == EMPTY: #在棋盘内且为空格
			set_board.rpc(x, y, cur_color) #调用RPC函数设置棋盘

@rpc("any_peer","call_local") #声明RPC函数
func set_board(x: int, y: int, color: int): #设置棋盘
	board[x][y] = cur_color #设置为当前颜色
	queue_redraw() #重新绘制棋盘
	#判断胜负
	if check_win() != EMPTY: #判断是否有胜利者
		print("Game Over:",cur_color) #输出游戏结束信息
		game_over.emit() #发送游戏结束信号
		is_game_over = true #设置游戏结束标志
		return #退出游戏
	cur_color = WHITE if cur_color == BLACK else BLACK #切换颜色
	Global.end_turn() #通知服务器切换回合




#检测胜负
func check_win(): #检测胜负
	var directions = [ #定义方向数组
		Vector2(1, 0),  #水平方向
		Vector2(0, 1),  #竖直方向
		Vector2(1, 1),  #右下方向
		Vector2(1, -1)  #右上方向

		   ]

	for i in range(BOARD_SIZE):  #遍历棋盘每个格子
		for j in range(BOARD_SIZE):  #遍历棋盘每个格子
			if board[i][j] == EMPTY:  #如果为空格
				continue  #跳过
			for dir in directions:  #遍历每个方向
				var count = 1  #初始化计数器
				for k in range(1, 5):  #遍历每个方向的5个格子
					var x = i + dir.x * k  #计算坐标
					var y = j + dir.y * k  #计算坐标
					if x < 0 or x >= BOARD_SIZE or y < 0 or y >= BOARD_SIZE:  #超出棋盘范围
						break  #退出循环
					if board[x][y] != board[i][j]:  #如果颜色不同
						break  #退出循环
					count += 1  #计数器加1
				if count >= 5:  #如果连成5个
					return board[i][j]  #返回胜利者颜色
	return EMPTY  #没有胜利者
