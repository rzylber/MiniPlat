extends Area2D

signal coin_caught
signal coin_lost

func _on_Coin_body_entered(body):
	if "Player" in body.name:
		visible = false
		emit_signal("coin_caught", self)
		$CatchSound.play()
		
func init(delay):
	$Timer.wait_time = delay
	$Timer.start()

func _on_CatchSound_finished():
	queue_free()


func _on_Timer_timeout():
	emit_signal("coin_lost", self)
	queue_free()
