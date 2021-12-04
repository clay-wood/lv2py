### A Pluto.jl notebook ###
# v0.16.4

using Markdown
using InteractiveUtils

# ╔═╡ 2056320e-5328-4112-8303-c51be0ee87b0
using DelimitedFiles, HDF5

# ╔═╡ 9503e409-de4e-4515-9bc2-fa6731599295
function read_bin(file_name, T; swap_endian=false)
    y = Vector{T}(undef, Int((filesize(file_name) - 0) / sizeof(T)))
    read!(file_name, y)
	footerStr = read(file_name, String)[end-335:end]
    if swap_endian
        y .= bswap.(y)  # In place broadcast of bswap over `y` is probably the neatest way to write this.
    end
    return y, footerStr
end

# ╔═╡ 8c1cb95c-2fc5-48de-a09c-00b4cd5ce921
function getNchans(gain)
	ells = findall("l", gain);
	footerChans = length(ells);
	return footerChans
end

# ╔═╡ 1c5bd20b-b9e1-4420-b2b0-ea064d3a596d
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

# ╔═╡ 69ad3f3e-75da-41df-b81b-7b84d9c291c9
function saveHDF5(ExpName, channels, Dat)
	h5open(string(ExpName)*"_py.h5", "w") do file
			g = create_group(file, "mechData") # create a group
			for (index, value) in enumerate(channels)
				g[value] = Dat[index,:]
			end                 
		end
end

# ╔═╡ 558c328a-4857-4e6d-9f80-2bdc81507d2a
# function input(prompt::AbstractString="")::String
# 	print(prompt)
# 	return chomp(readline())
# end

# ╔═╡ 19667507-b6ca-4c51-989b-4a5e774516d5
data[1,:]

# ╔═╡ 6c3698f2-c352-4abc-9197-5ff66199d1e6
dat_raw, footer = read_bin("p5595WGFrac10-21PressFilm", UInt32);

# ╔═╡ 74395c77-8f26-4b0f-83ef-8204bfe4bcb2
n_chans_in_footer = getNchans(footer[49:64])

# ╔═╡ 44213e88-6d6d-473f-8999-45de1a310c51
function getChanNames(num_channels, foot)
	names = Array{String}(undef, num_channels)
	
	for aa = 1:n_chans_in_footer
	names[aa] = split(foot[(81+(16*(aa-1))):(96+(15*(aa-1)))], "  ", keepempty=false)[1]
	end
	
	prepend!(names, ["Time"])
	
	return names
end

# ╔═╡ 030580ea-580e-4b94-bbca-70846c1a679e
function lv2py(file_name)
	T = UInt32
	dat_raw, footer = read_bin(file_name, T);
	println("lv2py version 24.10.2021\n\n")
	
	# expname = footer[1:32];
	expname = split(footer[1:32]," ", keepempty=false)[1];
	
	n_chans_in_footer = getNchans(footer[49:64])
	n_rec_footer, n_rec = getRecs(file_name, n_chans_in_footer, footer[33:48])
	# gain_flag = footer[49:64];
	# ells = findall("l", gain_flag);
	# n_chans_in_footer = length(ells);
	
# 	n_rec = Int((filesize(filename) - 336)/((n_chans_in_footer + 1) * 4));
# 	n_rec_footer = parse(Int, footer[33:48]);
	
# 	if isequal(n_rec, n_rec_footer)
# 		println("File size and footer match.")
	
# 	else
# 		println("File size and footer DO NOT match.")

# 	end
	
	println("Reading file "*string(expname)*" (24-bit file). There are "*string(stat(file_name).size)*" bytes of data, "*string(n_rec)*" recs, "*string(n_chans_in_footer+1)*" chans.")
	
	
	data = reshape(Float64.(dat_raw[1:end-336]), (n_chans_in_footer+1, :));
	
	chanNames = getChanNames(n_chans_in_footer, footer)
	
	# return data
	
	saveHDF5(expname, chanNames, data)

	# writedlm(file_name*"PY.csv",  data, ',')
end

# ╔═╡ 450b832d-7847-415f-b7bd-300761d7dddf
lv2py("p5595WGFrac10-21PressFilm")

# ╔═╡ ca123a5d-742f-4eaa-8f1d-fc2b7acd0050
footer[33:48]

# ╔═╡ 8e0bf8cf-7702-4cf4-bd1d-1acde3810b85
footer[49:64]

# ╔═╡ 345ece07-534f-4321-9870-4b7d82f6b6c7
dayTime = footer[65:80]

# ╔═╡ 9b10d811-d435-4038-8734-f934a78f031d
h5open("test.h5", "w") do file
    g = create_group(file, "mygroup") # create a group
    g["dset1"] = 3.2                  # create a scalar dataset inside the group
    attributes(g)["Description"] = "This group contains only a single dataset" # an attribute
end

# ╔═╡ 2345bf72-76e0-4431-bbf6-0b18fe1143d6
for (index, value) in enumerate(chanNames)
	g[index] = data[value]
end

# ╔═╡ bd3ceb94-cfb7-4e0b-ad49-abe04c8bd418
# lv2look version: 28.10.2016


# Reading file p5595WGFrac10-21PressFilm: 24-bit File has 828120 bytes of data, 68982 recs, 3 chans
# First recs are:
# 	time, ch2, ch3
# 	10000, 1932036, 1454930  

# Experiment p5595WGFrac10-21Pre began at 10:45 AM on 10/15/21
# n_chans = 3, nrecs = 68982
# Channel 2 (Hor DCDT    ) was recorded at +/- 10.0 volts
# Channel 3 (Hor LOAD    ) was recorded at +/- 10.0 volts

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DelimitedFiles = "8bb1440f-4735-579b-a4ab-409b98df4dab"
HDF5 = "f67ccb44-e63f-5c2f-98bd-6dc0ccc4ba2f"

[compat]
HDF5 = "~0.15.6"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Blosc]]
deps = ["Blosc_jll"]
git-tree-sha1 = "84cf7d0f8fd46ca6f1b3e0305b4b4a37afe50fd6"
uuid = "a74b3585-a348-5f62-a45c-50e91977d574"
version = "0.7.0"

[[Blosc_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Lz4_jll", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "e747dac84f39c62aff6956651ec359686490134e"
uuid = "0b7ba130-8d10-5ba8-a3d6-c5182647fed9"
version = "1.21.0+0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "31d0151f5716b655421d9d75b7fa74cc4e744df2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.39.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[HDF5]]
deps = ["Blosc", "Compat", "HDF5_jll", "Libdl", "Mmap", "Random", "Requires"]
git-tree-sha1 = "83173193dc242ce4b037f0263a7cc45afb5a0b85"
uuid = "f67ccb44-e63f-5c2f-98bd-6dc0ccc4ba2f"
version = "0.15.6"

[[HDF5_jll]]
deps = ["Artifacts", "JLLWrappers", "LibCURL_jll", "Libdl", "OpenSSL_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "fd83fa0bde42e01952757f01149dd968c06c4dba"
uuid = "0234f1f7-429e-5d53-9886-15a909be8d59"
version = "1.12.0+1"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Lz4_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5d494bc6e85c4c9b626ee0cab05daa4085486ab1"
uuid = "5ced341a-0733-55b8-9ab6-a4889d929147"
version = "1.9.3+0"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╠═2056320e-5328-4112-8303-c51be0ee87b0
# ╠═9503e409-de4e-4515-9bc2-fa6731599295
# ╠═8c1cb95c-2fc5-48de-a09c-00b4cd5ce921
# ╠═1c5bd20b-b9e1-4420-b2b0-ea064d3a596d
# ╠═44213e88-6d6d-473f-8999-45de1a310c51
# ╠═69ad3f3e-75da-41df-b81b-7b84d9c291c9
# ╠═558c328a-4857-4e6d-9f80-2bdc81507d2a
# ╠═030580ea-580e-4b94-bbca-70846c1a679e
# ╠═450b832d-7847-415f-b7bd-300761d7dddf
# ╠═19667507-b6ca-4c51-989b-4a5e774516d5
# ╠═6c3698f2-c352-4abc-9197-5ff66199d1e6
# ╠═74395c77-8f26-4b0f-83ef-8204bfe4bcb2
# ╠═ca123a5d-742f-4eaa-8f1d-fc2b7acd0050
# ╠═8e0bf8cf-7702-4cf4-bd1d-1acde3810b85
# ╠═345ece07-534f-4321-9870-4b7d82f6b6c7
# ╠═9b10d811-d435-4038-8734-f934a78f031d
# ╠═2345bf72-76e0-4431-bbf6-0b18fe1143d6
# ╠═bd3ceb94-cfb7-4e0b-ad49-abe04c8bd418
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
