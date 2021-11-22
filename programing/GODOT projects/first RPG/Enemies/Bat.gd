extends KinematicBody2D
const EnemyDeathEffect=preload("res://Effects/EnemyDeathEffect.tscn")
var knockback=Vector2.ZERO
var velocity=Vector2.ZERO

export var ACCELERATION=300
export var MAX_SPEED=30
export var FRICTION=200
enum{
	IDLE,
	CHASE,
	WANDER
}
var state =CHASE
onready var sprite =$AnimateedSprite
onready var stats =$Stats
onready var playerDetectionZone=$PlayerDetectionZone
onready var hurtbox=$HurtBox
func _ready():
	print(stats.max_health)
	
	
func _physics_process(delta):
	knockback=knockback.move_toward(Vector2.ZERO, FRICTION*delta)
	knockback=move_and_slide(knockback)

	match state :
		IDLE:
			velocity=velocity.move_toward(Vector2.ZERO, FRICTION*delta)
			seek_player()
		WANDER:
			pass
		CHASE:
			var player= playerDetectionZone.player
			if player!=null:
				var direction =(player.global_position-global_position).normalized()
				velocity=velocity.move_toward(direction*MAX_SPEED, ACCELERATION*delta)
			else:
				state=IDLE
			sprite.flip_h=velocity.x <0
	velocity=move_and_slide(velocity)
func seek_player():
	if playerDetectionZone.can_see_player():
		state=CHASE

func _on_HurtBox_area_entered(area):
	stats.health-=area.damage
	knockback=area.knockback_vector* 100
	hurtbox.create_hit_effect()

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect=EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position=global_position
