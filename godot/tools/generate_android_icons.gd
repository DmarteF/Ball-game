extends SceneTree


const SOURCE := "res://assets/icons/neon_idle_escape_app_icon_1024.png"
const OUTPUTS := {
	"res://assets/icons/android/neon_idle_escape_icon_192.png": Vector2i(192, 192),
	"res://assets/icons/android/neon_idle_escape_adaptive_foreground_432.png": Vector2i(432, 432),
	"res://assets/icons/android/neon_idle_escape_adaptive_background_432.png": Vector2i(432, 432),
}


func _initialize() -> void:
	var source_path := ProjectSettings.globalize_path(SOURCE)
	var image := Image.load_from_file(source_path)
	if image == null:
		push_error("Could not load icon source: %s" % source_path)
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/icons/android"))
	for output in OUTPUTS.keys():
		var copy := image.duplicate()
		var size: Vector2i = OUTPUTS[output]
		copy.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)
		var error: Error = copy.save_png(ProjectSettings.globalize_path(String(output)))
		if error != OK:
			push_error("Could not save icon: %s" % output)
			quit(1)
			return
	quit()
