extends Node

const dict = {
	"intro":preload("res://assets/music/at_home.mp3"),
	'at_home1':preload("res://assets/music/at_home_creepy_1.mp3"),
	'at_home2':preload("res://assets/music/at_home_creepy_2.mp3"),
	'heavy_in':preload("res://assets/music/heavy_01.mp3"),
	'heavy_mid':preload("res://assets/music/heavy_03.mp3"),
	'boss_a':preload("res://assets/music/heavy_05_a.mp3"),
	'boss_b':preload("res://assets/music/heavy_05_b.mp3"),
	'rock_in':preload("res://assets/music/rock_no_bass .mp3"),
	'rock_1':preload("res://assets/music/rock_creepy_1.mp3"),
	'rock_2':preload('res://assets/music/rock_creepy_2.mp3')
}
const next_state = {
	'intro': 'intro',
	'at_home1':'at_home2',
	'at_home2':'at_home1',
	'heavy_in':'heavy_mid',
	'heavy_mid':'heavy_mid',
	'boss_a':'boss_b',
	'boss_b':'boss_a',
	'rock_in':'rock_1',
	'rock_1':'rock_2',
	'rock_2':'rock_1'
}

const events_to_states = {
	'home':'at_home1',
	'work':'rock_in',
	'factory':'heavy_in',
	'boss':'boss_a',
	'victory':'intro',
	'defeat':'at_home1'
}

var audio_player : AudioStreamPlayer = null
var state: String = 'intro'


func _ready() -> void:
	var new_audio_player := AudioStreamPlayer.new()
	new_audio_player.stream = dict.get(state, dict.get('intro'))
	new_audio_player.autoplay = true
	audio_player = new_audio_player
	add_child(new_audio_player)


func _process(delta: float) -> void:
	if audio_player:
		if !audio_player.playing:
			if audio_player.stream == dict.get(state, dict.get('intro')):
				state = next_state.get(state)
				
			audio_player.stream = dict.get(state, dict.get('intro'))
			audio_player.play()


func play_next(event: String) -> void:
	print("Setted next to play: " + event)
	state = events_to_states.get(event)
