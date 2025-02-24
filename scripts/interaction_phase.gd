extends Node2D

@onready var vn: Node2D = $VN

func load_scene(index:int):
	match index:
		0: #test scene
			vn.timeline_name = 'test0'
		1: #interaction 1 (neutral)
			vn.timeline_name = '1neutral'
		2: #interaction 1 (happy)
			vn.timeline_name = '1happy'
		3: #interaction 1 (mad)
			vn.timeline_name = '1mad'
		4: #final interaction (neutral)
			vn.timeline_name = '2neutral'
		5: #final interaction (happy)
			vn.timeline_name = '2happy'
		6: #final interaction (mad)
			vn.timeline_name = '2mad'
	vn.test_ready()
	
