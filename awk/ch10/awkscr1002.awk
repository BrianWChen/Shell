function getFilename(  file){
	while (!file){
		printf("Enter a filenname:  ")
		getline < "-"
		file = $0
		if (system("test -r " file)){
			print file " not found"
			file = ""
		}
	}
	if (file!~/^\// ){
		"pwd" | getline
		close("pwd")
		file = $0 "/" file
	}
	return file
}

{
	getFilename()
}
