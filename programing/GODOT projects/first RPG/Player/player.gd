extends KinematicBody2D
const MAX_SPEED=60
const ACCELERATION=500
const FRICTION=3500
const ROLL_SPEED= MAX_SPEED*1.5

enum{
	MOVE,
	ROLL,
	ATTACK
}
var state=MOVE
var velocity =Vector2.ZERO
var roll_vector=Vector2.DOWN  # see initially player di posotion uss direction ch hi roll hona chahida
var stats=PlayerStats
"""
var animationPlayer=null
func _ready():
	animationPlayer= $AnimationPlayer
"""
"""below is short code for above code"""
onready var animationPlayer=$AnimationPlayer
onready var animationTree=$AnimationTree
onready var animationState=animationTree.get("parameters/playback")
onready var swordHitbox=$HitboxPivot/SwordHitBox
onready var hurtbox=$HurtBox

func _ready():
	stats.connect("no_health",self,"queue_free()")
	animationTree.active=true
	swordHitbox.knockback_vector=roll_vector

func _physics_process(delta):
	match state:
		MOVE:
			 move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)
func move_state(delta):
	"""
	if Input.is_action_pressed("ui_right"):
		velocity.x =4
	elif Input.is_action_pressed("ui_left"):
		velocity.x=-4
	elif Input.is_action_pressed("ui_up"):
		velocity.y=-4
	elif Input.is_action_pressed("ui_down"):
		velocity.y=4
	else :
		velocity.x=0
		velocity.y=0
	"""
	var input_vector=Vector2.ZERO
	input_vector.x=Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	input_vector.y=Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")  # as down is posotive in gdscript
	input_vector=input_vector.normalized()
	"""normalized makes the hypotenuse vector also equal to the up down right left"""
	
	
	if input_vector !=Vector2.ZERO:
		"""
		if input_vector.x>0:
			animationPlayer.play("RunRight")
		else:
			animationPlayer.play("RunLeft")
		"""
		
		""" either you can do above code for animations or ou can use the animation tree as writen below  """
		roll_vector=input_vector
		swordHitbox.knockback_vector=input_vector
		animationTree.set("parameters/Idle/blend_position",input_vector)
		animationTree.set("parameters/Run/blend_position",input_vector)
		animationTree.set("parameters/Attack/blend_position",input_vector)
		animationTree.set("parameters/Roll/blend_position",input_vector)
		animationState.travel("Run")
		
		velocity +=input_vector * ACCELERATION *delta
		velocity=velocity.clamped(MAX_SPEED)
	
	else :
		animationState.travel("Idle")
		velocity=velocity.move_toward(Vector2.ZERO,FRICTION* delta)
	
	"""move_and_collide(velocity*delta)"""  
	
	"""see we have to multiply velocity with delta as if someone is experiencing frame drops so we multily its speed with a fraction by which its frame are droping and delta is that fraction"""
	"""so if movements are connected with frame rates we have to multiply with delta for every variable """
	
	move()
	"""above function returns argument passed to it"""
	if Input.is_action_just_pressed("attack"):
		state=ATTACK
	if Input.is_action_just_pressed("roll"):
		state=ROLL
	
func roll_state(delta):
	velocity=roll_vector* ROLL_SPEED
	animationState.travel("Roll")
	move()


func attack_state(delta):
	velocity= Vector2.ZERO
	animationState.travel("Attack")

func move():
	velocity=move_and_slide(velocity)

func roll_animation_finished():
	state=MOVE
func attack_animation_finished():
	state=MOVE

func _on_HurtBox_area_entered(area):
	if stats.health<=0:
		queue_free()
	stats.health-=1
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()











