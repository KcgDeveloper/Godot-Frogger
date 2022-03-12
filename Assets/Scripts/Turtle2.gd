extends Sprite                    ## TURTLE 2  

var leftEdge = Vector2(-64,0)
var rightEdge = Vector2(832,0)
var direction = Vector2.LEFT

var speed = -20                   
onready var imageWidth = texture.get_width() * 2  



func _process(delta):	

	position += transform.x * speed * delta
	
	if (position.x < 0 && position.x + imageWidth < leftEdge.x):               
		position.x = rightEdge.x + imageWidth
		
	elif (position.x > 0 && position.x - imageWidth > rightEdge.x):            
		position.x = leftEdge.x - imageWidth

