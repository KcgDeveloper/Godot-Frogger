extends Sprite              ## Player

signal is_player_home
signal on_water
signal run_over
signal progressScore


var IdleFrog = preload("res://Assets/Images/FroggerIdle.png")
var LeapFrog = preload("res://Assets/Images/FroggerLeap.png")
onready var hopSound = get_node("jumpAudio")

var player_run_over = false 
var canGetKey = false
var direction = Vector2.ZERO
var destination = Vector2.ZERO
var OnPlatform = false
var platformSpeed = 0.0
var alogParent = null
var hasPlayerDrowned = false
var midLeap = false
var testRayCast = false
var testRayColliderName = null 
var progressForward = 0
var maxProgressForward = 0.0
var singleProgressForward = 0.0


##########  GET_INPUT()  ##########
func get_input():
	if canGetKey == false:                      ## CAN`T PRESS KEY WHEN MID LEAP
		return
	if Input.is_action_just_pressed("ui_up"):
		rotation_degrees = 0
		leap(0,-64)

	if Input.is_action_just_pressed("ui_down"):
		rotation_degrees = 180
		leap(0,64)

	if Input.is_action_just_pressed("ui_left"):
		rotation_degrees = -90
		leap(-64,0)

	if Input.is_action_just_pressed("ui_right"):
		rotation_degrees = 90
		leap(64,0)

##########  LEAP()  ##########
func leap(vx,vy):
	hopSound.play()
	midLeap = true
	canGetKey = false                           
	destination = position + Vector2(vx,vy)    
	var i = 0
	texture = LeapFrog
	while (i < 10):
		i += 1
		yield(get_tree().create_timer(0.005),"timeout") 
		position = position.linear_interpolate(Vector2(destination), 0.5)
	position = destination
	texture = IdleFrog
	canGetKey = true
	midLeap = false
	calcProgress(vy)


########  CALCULATE EACH STEP FORWARD OF PLAYER -> PROGRESS UP SCREEN ########
func calcProgress(vy):
	progressForward += vy
	if !progressForward == 0:
		singleProgressForward = progressForward / 64         
	if abs(singleProgressForward) > maxProgressForward:       ## FURTHEST PLAYER GOT FOWARD SO FAR
		emit_signal("progressScore")
		maxProgressForward = abs(singleProgressForward)



##########  _PROCESS_DELTA()  ##########
func _process(delta):
	get_input()
	mvePlayerOnPlatform(delta)
	testRaycast()


########  MOVE THE PLAYER IF RIDING ON PLATFORM  #######
func mvePlayerOnPlatform(delta):
	if OnPlatform:
		position.x += self.platformSpeed * delta


########   CHECK RAYCAST (WATER)  ########
func testRaycast():
	if $RayCast2D.is_colliding():
		testRayColliderName = $RayCast2D.get_collider()
		testRayCast = true
	else:
		testRayColliderName = null
		testRayCast = false

	## NOT ON PLATFORM, NOT MIDLEAP & IS OVER WATER
	if OnPlatform == false && midLeap == false && testRayCast == true:  
		hasPlayerDrowned = true
		$RayCast2D.enabled = false     ## ON WATER -> TURN RAYCAST OFF
		emit_signal("on_water")



########  AREA OVERLAP -> ON LOG?  ########
func _on_Area2D_area_entered(area): 
	if area.is_in_group("Home"):                    ## PLAYER GOT HOME?                             
		emit_signal("is_player_home", area)        

	if area.is_in_group("Platform"):                ## PLAYER ON LOG
		alogParent = area.get_parent()
		self.platformSpeed = alogParent.speed * 4
		self.position.y = alogParent.position.y
		OnPlatform = true
	else:
		OnPlatform = false                          ## NOT ON PLATFORM
	
	if area.is_in_group("Obstacle") && player_run_over == false:  ## PLAYER HAS HIT OBTACLE
		player_run_over = true
		emit_signal("run_over")


########  AREA EXIT -> OFF LOG?  ########
func _on_Area2D_area_exited(area):
	OnPlatform = false   


########  SIGNAL SENT TO ENABLE RAYCAST2D TO CHECK FOR WATER  ########
func _on_FroggerMain_raycast_On():
	$RayCast2D.enabled = true


