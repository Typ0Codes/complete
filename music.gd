extends Node

var player: AudioStreamPlayer

func _ready() -> void:
	player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = preload("res://unamed.mp3")  
	player.play()

func play() -> void:
	if not player.playing:
		player.play()

func stop() -> void:
	player.stop()
