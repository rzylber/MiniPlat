extends KinematicBody2D

const SPEED = 60
const GRAVITY_SPEED = 140
const UP_FACTOR = 8
const UP_BOOST = -230

var jumping_accum=GRAVITY_SPEED

var velocity = Vector2()
var moving = false

func _ready():
	$Sprite/AP.play("idle")

func _physics_process(delta):
	if is_on_floor():
		if Input.is_action_pressed("ui_right"):
			velocity.x = SPEED
			$Sprite.flip_h = false
			$Sprite/AP.play("walking")
			moving = true
		elif Input.is_action_pressed("ui_left"):
			velocity.x = -SPEED
			$Sprite.flip_h = true
			$Sprite/AP.play("walking")
			moving = true
		else:
			velocity.x = 0
			moving = false
			$Sprite/AP.play("idle")
		
		if Input.is_action_pressed("ui_accept"):
			$JumpSound.play()
			jumping_accum = UP_BOOST
	else:
		$Sprite/AP.play("jumping")
		
	
	if jumping_accum < GRAVITY_SPEED:
		jumping_accum += UP_FACTOR
		velocity.y = jumping_accum
	else:
		velocity.y = GRAVITY_SPEED	
	
	move_and_slide(velocity, Vector2(0,-1))