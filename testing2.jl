import REPL
using REPL.TerminalMenus

function FileSelector()
	test = readdir();
	notDotFiles = isempty.(findall.(".", test));
	options = test[notDotFiles]
	append!(options, ["CANCEL"])


	menu = RadioMenu(options, pagesize=4)
	
	# `request` displays the menu and returns the index after the
	#   user has selected a choice
	choice = request("Choose LabVIEW binary file in current directory:", menu)
	
	if choice != -1
		println("File chosen: ", options[choice])

	elseif choice == "CANCEL"
		println("lv2py cancelled")

	else
		println("Menu canceled.")
	end

	return options[choice]
end

filename = FileSelector()
println(filename)