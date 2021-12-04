using DelimitedFiles, HDF5, REPL.TerminalMenus
#import REPL
#using REPL.TerminalMenus


function FileSelector()
	fileList = readdir();
	fileList = fileList[.!isdir.(fileList)];
	notDotFiles = isempty.(findall.(".", fileList));
	options = fileList[notDotFiles]
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

function read_bin(file_name, T; swap_endian=false)
    y = Vector{T}(undef, Int((filesize(file_name) - 0) / sizeof(T)))
    read!(file_name, y)
	footerStr = read(file_name, String)[end-335:end]
    if swap_endian
        y .= bswap.(y)  # In place broadcast of bswap over `y` is probably the neatest way to write this.
    end
    return y, footerStr
end

function getNchans(gain)
	ells = findall("l", gain);
	footerChans = length(ells);
	return footerChans
end

function getRecs(file_name, footerChans, foot)
	n_rec = Int((filesize(file_name) - 336)/((footerChans + 1) * 4));
	n_rec_foot = parse(Int, foot);
	
	if isequal(n_rec, n_rec_foot)
		println("File size and footer match.")
	
	else
		println("File size and footer DO NOT match.")

	end
	return n_rec_foot, n_rec
end

function getChanNames(num_channels, foot)
	names = Array{String}(undef, num_channels)
	
	for aa = 1:num_channels
	names[aa] = split(foot[(81+(16*(aa-1))):(96+(15*(aa-1)))], "  ", keepempty=false)[1]
	end
	
	prepend!(names, ["Time"])
	
	return names
end

function saveHDF5(ExpName, channels, Dat)
	h5open(string(ExpName)*"_py.h5", "w") do file
			g = create_group(file, "mechData") # create a group
			for (index, value) in enumerate(channels)
				g[value] = Dat[index,:]
			end                 
		end
end

function lv2py(file_name)
	T = UInt32
	dat_raw, footer = read_bin(file_name, T);
	println("lv2py version 24.10.2021\n\n")
	
	# expname = footer[1:32];
	expname = split(footer[1:32]," ", keepempty=false)[1];
	
	n_chans_in_footer = getNchans(footer[49:64])
	n_rec_footer, n_rec = getRecs(file_name, n_chans_in_footer, footer[33:48])
	
	println("Reading file "*string(expname)*" (24-bit file). There are "*string(stat(file_name).size)*" bytes of data, "*string(n_rec)*" recs, "*string(n_chans_in_footer+1)*" chans.")
	
	
	data = reshape(Float64.(dat_raw[1:end-336]), (n_chans_in_footer+1, :));
	
	chanNames = getChanNames(n_chans_in_footer, footer)
	
	# return data
	
	saveHDF5(expname, chanNames, data)

	# writedlm(file_name*"PY.csv",  data, ',')
end


Filename = FileSelector()

if Filename != "CANCEL"
	lv2py(Filename)
end