extends Node # 继承自Node类


var uid: int 
var all_peers :Array[int] = [1] # 所有客户端的peer id
var cur_round: int = 0 # 当前回合数

#添加客户端的peer id
func add_peer(id: int): 
	all_peers.append(id) # 添加客户端的peer id


#判断是否是自已的回合
func is_my_turn() -> bool: 
	return all_peers[cur_round % 2] == uid # 取余数，判断是否是当前回合的客户端

#回合结束
func end_turn(): 
	cur_round += 1 # 回合数加1
	print("回合结束！", cur_round) # 打印回合数
