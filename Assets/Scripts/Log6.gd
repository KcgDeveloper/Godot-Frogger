extends Sprite                    

var leftEdge = Vector2(0,0)
var rightEdge = Vector2(1248,0)
var direction = Vector2.RIGHT

var speed = 60                  
onready var imageWidth = texture.get_width() * 2   

func _ready():
	pass 



func _process(delta):

	position += transform.x * speed * delta

	if (direction.x < 0 && position.x + imageWidth < leftEdge.x):               
		position.x = rightEdge.x + imageWidth
		
	elif (direction.x > 0 && position.x - imageWidth > rightEdge.x):            
		position.x = leftEdge.x - imageWidth


