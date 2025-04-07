extends Node

signal save_is_ready()

enum Saved_property {DIFFICULTY, VOLUME, LANGUAGE, SCREEN_MODE, TUTORIAL}

var config: ConfigFile = ConfigFile.new()
var save_data: Dictionary = {} # Saved_property:Variant
var is_loaded: bool = false

const SAVE_FILE_NAME: String = "user://save.cfg"

func _ready() -> void:
	is_loaded = load_save()
	save_is_ready.emit()


func save_property(property_name: Saved_property, value: Variant, category: String = "UserConfig") -> void:
	save_data[property_name] = value
	config.set_value(category, str(property_name), value)
	print(str(property_name))
	if config.save(SAVE_FILE_NAME) != OK:
		printerr("Save not avalaible")


func save_properties(values_to_save: Dictionary, category: String = "UserConfig") -> void: #values_to_save => Saved_property:Variant 
	for save_value: Saved_property in values_to_save.keys():
		config.set_value(category, str(save_value), values_to_save[save_value])
	config.save(SAVE_FILE_NAME)


func load_save() -> bool:
	if config.load(SAVE_FILE_NAME) != OK:
		printerr("Cant't load ",SAVE_FILE_NAME)
		return false

	for section: String in config.get_sections():
		for property: int in Saved_property.size():
			if not config.has_section_key(section, str(property)): continue
			save_data[property] = config.get_value(section, str(property))
	human_readable_save_file()
	return true

func human_readable_save_file() -> void:
	for i: int in save_data.keys():
		print(Saved_property.keys()[i]," = ", save_data[i])
