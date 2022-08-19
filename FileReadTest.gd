tool
extends EditorScript


var file = 'res://PBS/pokemon.txt'

func _run():
	load_file(file)

func load_file(file):

	var f = File.new()
	var target = '[GALLADE]'
	var found = false
	f.open(file, File.READ)
	
	
	while (not f.eof_reached()) and (not found): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		if line == target:
			found = true
			
	print(target)

	for i in 32:
		var line = f.get_line()
		if line == '#-------------------------------':
			break
		print(line)

	f.close()
	return
