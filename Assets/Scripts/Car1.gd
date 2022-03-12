extends Sprite                    ## Car 1  

var leftEdge = Vector2(-96,0)
var rightEdge = Vector2(832,0)
var direction = Vector2.LEFT

var speed = -40                  
onready var imageWidth = texture.get_width() * 2   

func _ready():
	pass 


## MOVE CAR 1
func _process(delta):

	position += transform.x * speed * delta

	if (direction.x < 0 && position.x + imageWidth < leftEdge.x):               
		position.x = rightEdge.x + imageWidth
		
	elif (direction.x > 0 && position.x - imageWidth > rightEdge.x):            
		position.x = leftEdge.x - imageWidth


