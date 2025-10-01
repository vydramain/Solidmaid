extends Node

static func log(caller: Object, msg: String) -> void:
	var current_scene = caller.get_tree().current_scene
	var scene_name = current_scene.name if current_scene else "NO_CURRENT_SCENE"
	var place = str(caller.get_path())
	print("[{scene} | {place}] {msg}".format({
		"scene": scene_name,
		"place": place,
		"msg": msg
	}))


# Music state management
const dict = {
	"intro": preload("res://assets/music/at_home.mp3"),
	"at_home1": preload("res://assets/music/at_home_creepy_1.mp3"),
	"at_home2": preload("res://assets/music/at_home_creepy_2.mp3"),
	"heavy_in": preload("res://assets/music/heavy_01.mp3"),
	"heavy_mid": preload("res://assets/music/heavy_03.mp3"),
	"boss_a": preload("res://assets/music/heavy_05_a.mp3"),
	"boss_b": preload("res://assets/music/heavy_05_b.mp3"),
	"rock_in": preload("res://assets/music/rock_no_bass.mp3"),
	"rock_1": preload("res://assets/music/rock_creepy_1.mp3"),
	"rock_2": preload("res://assets/music/rock_creepy_2.mp3")
}

const next_state = {
	"intro": "intro",
	"at_home1": "at_home2",
	"at_home2": "at_home1",
	"heavy_in": "heavy_mid",
	"heavy_mid": "heavy_mid",
	"boss_a": "boss_b",
	"boss_b": "boss_a",
	"rock_in": "rock_1",
	"rock_1": "rock_2",
	"rock_2": "rock_1"
}

const events_to_states = {
	"home": "at_home1",
	"work": "rock_in",
	"factory": "heavy_in",
	"boss": "boss_a",
	"victory": "intro",
	"defeat": "at_home1"
}

var audio_player: AudioStreamPlayer = null
var state: String = "intro"


func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = dict.get(state, dict.get("intro"))
	audio_player.autoplay = true
	add_child(audio_player)
	Custom_Logger.log(self, "Initialized AudioStreamPlayer with state: '%s'" % state)


func _process(delta: float) -> void:
	if not audio_player:
		return

	if not audio_player.playing:
		var previous_state = state
		state = next_state.get(state, state)
		audio_player.stream = dict.get(state, dict.get("intro"))
		audio_player.play()
		Custom_Logger.log(self, "Audio finished for state '%s'. Transitioned to next state '%s'" % [previous_state, state])


func play_next(event: String) -> void:
	if not events_to_states.has(event):
		Custom_Logger.log(self, "Received unknown event '%s'. No state change applied." % event)
		return

	var previous_state = state
	state = events_to_states[event]
	audio_player.stream = dict.get(state, dict.get("intro"))
	audio_player.play()
	Custom_Logger.log(self, "Event '%s' triggered. Changed state from '%s' to '%s' and started playback." % [event, previous_state, state])
