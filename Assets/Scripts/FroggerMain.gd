extends Node                    ## FROGGER MAIN ##

signal raycast_On

onready var deadPlayer = get_node("DeadPlayer")

onready var homes1 = get_node("HomeBank/HomeArea2D1")
onready var homes2 = get_node("HomeBank/HomeArea2D2")
onready var homes3 = get_node("HomeBank/HomeArea2D3")
onready var homes4 = get_node("HomeBank/HomeArea2D4")
onready var homes5 = get_node("HomeBank/HomeArea2D5")
onready var homes = [homes1, homes2, homes3, homes4, homes5]

onready var timerWarningSound = get_node("timerWarningSound")
onready var squashSound = get_node("squashSound")
onready var plopSound = get_node("plopSound")
onready var allHomesOccupiedMusic = get_node("all_homes_music_play")

## GAME VARIABLES ##
var lives
var score
var timerBonus = 0
var time = 0
var display_time = 0
var timer_on = false
var timerWarning = false
var playerStartposition = Vector2(416, 930)
var isGameover = false
var playerJustDied = false
var old_destination = Vector2.ZERO
var warningTime = 6

########  READY()  ########
func _ready():
	newGame()


########  HUD -> SCORES ETC  ########
func updateHud():
	$TopBar/LivesLabel.text = "%02d" % + lives
	$TopBar/ScoreLabel.text = "%05d" % + score
	$TopBar/TimerLabel.text = "%02d" % + display_time


########  PROCESS(DELTA)  ########
func _process(delta):
	if isGameover == true:
		can_new_game()
	countdown(delta)
	updateHud()


########  TIMER COUNTDOWN  ########
func countdown(delta):
	if (timer_on):
		time -= delta
	if (time < warningTime && timerWarning == false):
		timerWarning = true
		timerWarningSound.play()
	if time < 0:
		timer_on = false
		if playerJustDied == false:
			squashSound.play()  ## SQUASHSOUND ##
			died()
	display_time = int(fmod(time, 60))


########  WAITING FOR KEY PRESS FOR NEW GAME (AFTER GAME OVER OR GAME START) ########
func can_new_game():
	if Input.is_action_just_pressed("ui_accept"):
		## PRESSED 'ENTER or SPACE' FOR NEW GAME   
		isGameover = false                          
		newGame()

########  SET NEW GAME  ########
func newGame():
	$GameOverText.visible = false
	$PlayGameText.visible = false
	lives = 3
	score = 0
	time = 300
	display_time = 30
	$Player.visible = false
	yield(get_tree().create_timer(1.0),"timeout")
	rsetVars()


########  GAME OVER ROUTINE  ########
func gameOver():
	$Player.visible = false
	$GameOverText.visible = true
	yield(get_tree().create_timer(2.0),"timeout")
	$PlayGameText.visible = true
	isGameover = true                              



########  A NEW LEVEL ROUTINE  ########
func newLevel():                                           ## GIVING TIME TO PLAY MUSIC WITH YIELDS
	$Player.visible = false
	yield(get_tree().create_timer(0.5),"timeout")
	set_homes_un_occupied()
	$NextLevel.visible = true
	yield(get_tree().create_timer(3.0),"timeout")
	$NextLevel.visible = false
	rsetVars()




########  SET HOMEs UNOCCUPIED -> END OF LEVEL  ########
func set_homes_un_occupied():
	for n in range(homes.size()):
		yield(get_tree().create_timer(0.3),"timeout")
		homes[n].get_child(1).visible = false              ## SET HOME TO NOT VISIBLE


########  LOST A LIVE BUT LIVES LEFT -> RESPAWN  ########
func respawn():
	$Player.visible = false
	yield(get_tree().create_timer(1.0),"timeout")
	rsetVars()


########  RESET SOME VARIABLES  -> READY TO GO AGAIN (HAS Lives 1~3) ########
func rsetVars():
	$Player.position = playerStartposition
	$Player.visible = true
	$Player.OnPlatform = false
	$Player.midLeap = false
	$Player.testRayCast = false
	$Player.hasPlayerDrowned = false
	$Player.progressForward = 0
	$Player.maxProgressForward = 0
	$Player.canGetKey = true
	$Player.player_run_over = false
	playerJustDied = false                   ## STOPS MULTIPLE DEATHS AT ONCE
	time = 30
	display_time = 30
	timer_on = true
	emit_signal("raycast_On")



########  PLAYER DIED  ########
func died():
	playerJustDied = true
	timer_on = false
	$Player.visible = false
	$Player.canGetKey = false
	showDeadPlayer()
	lives -= 1
	if lives > 0:
		respawn()
	else:
		gameOver()


########  SHOW DEAD PLAYER  ########
func showDeadPlayer():
	if $Player.position.x < 0:                      ## IF PLAYER OFFSCREEN REPOSITION DEADPLAYER
		deadPlayer.position.x = 30
		deadPlayer.position.y = $Player.position.y
	elif $Player.position.x > 840:
		deadPlayer.position.x = 806
		deadPlayer.position.y = $Player.position.y
	else:
		deadPlayer.position = $Player.position
	deadPlayer.visible = true
	$Player.position = playerStartposition  
	yield(get_tree().create_timer(1.0),"timeout")
	deadPlayer.visible = false


########  ARE ALL HOMES OCCUPIED?  ########
func are_homes_cleared():
	for n in range(homes.size()):
		if !homes[n].get_child(1).visible:         ## IF HOME SPRITEs NOT VISIBLE
			respawn()                              ## STILL AN EMPTY HOMES LEFT
			return false                           ## AT LEAST 1 HOME UNT OCCUPIED
	return true                                    ## ALL HOMES OCCUPIED


########  IS THIS CURRENT HOME OCCUPIED?  ########
func is_home_occupied(area):
	for n in range(homes.size()):
		if homes[n] == area:
			if !homes[n].get_child(1).visible:     ## IF 'NOT OCCUPIED' return TRUE
				return true
	return false                                   ## ELSE RETURN FALSE 'OCCUPIED'

########  SET OCCUPIED HOME  ########
func set_home_occupied(area):
	for n in range(homes.size()):
		if homes[n] == area:
			if !homes[n].get_child(1).visible:        ## IF 'NOT OCCUPIED' then 'OCCUPY'
				homes[n].get_child(1).visible = true  ## SET HOME TO VISIBLE
				score += 50
				score += display_time * 10                                



##########  HOME BANK IS AN OBSTACLE  ##########
func _on_HomeBankArea2D_area_entered(_area):
	if playerJustDied == false:
		died()



##########  PLAYER ATTEMPTING TO ENTER HOME  ##########
func _on_HomeArea2D_area_entered(_area):
	if are_homes_cleared():                ## IF ALL HOMES OCCUPIED NEED TO DO A NEW LEVEL SCENE
		allHomesOccupiedMusic.play()
		score += 1000
		timer_on = false
		newLevel()


########  SIGNAL SENT FROM PLAYER TO MAIN WHEN PLAYER ENTERS A HOME ########
func _on_Player_is_player_home(area):
	if is_home_occupied(area):          ## TRUE IF NOT OCCUPIED
		plopSound.play()                ## PLAY SOUND (GOT HOME)
		set_home_occupied(area)         ## IF NOT OCCUPIED (TRUE) THEN OCCUPY
	else: 
		if playerJustDied == false:     ## HOME OCCUPIED SO DIED
			squashSound.play()          ## PLAY SQUASH SOUND **
			died()



########  PLAYER HAS LEFT PLAY AREA -> DIED!  ########
func _on_PlayArea_area_exited(_area):         ## EXITED PLAY AREA
	if playerJustDied == false:
		squashSound.play() 
		died()


########  PLAYER ON WATER -> DIE  ########
func _on_Player_on_water():
	if playerJustDied == false:
		plopSound.play()  
		died()



########  RUN OVER ON ROAD  ########
func _on_Player_run_over():
	if playerJustDied == false:
		squashSound.play() 
		died()


########  SCORE WHEN PLAYER MOVES FORWARD  ########
func _on_Player_progressScore():
	score += 10

