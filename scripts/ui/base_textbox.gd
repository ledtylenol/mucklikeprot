extends PanelContainer
var t := 0.0
@onready var rich_text_label: RichTextTransition = $RichTextLabel
var tween: Tween

func _ready() -> void:
	tween = create_tween()
	tween.tween_property($RichTextLabel, "time", 1.0, $RichTextLabel.animation_time)
	
func _process(delta: float) -> void:
	t += delta
	if t > (1.0 / rich_text_label.animation_time)**5 and rich_text_label.time <=0.999:
		$RichTextLabel/AudioStreamPlayer.play()
		t = 0.0
	if Input.is_action_pressed("shoot") and rich_text_label.time <= 0.999:
		if tween:
			tween.stop()
		rich_text_label.time = 1.0
		$RichTextLabel/AudioStreamPlayer.play()
