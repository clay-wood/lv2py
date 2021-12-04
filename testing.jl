### A Pluto.jl notebook ###
# v0.16.4

using Markdown
using InteractiveUtils

# ╔═╡ 2056320e-5328-4112-8303-c51be0ee87b0
using DelimitedFiles

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

# ╔═╡ 4f2937a6-270b-4513-8cdb-646d9f6b7933
begin
	filename = "p5595WGFrac10-21PressFilm";
	test_raw, footer = read_bin(filename, UInt32);
end

# ╔═╡ 1a5df692-1db4-4c93-bc3e-a9719666388d
expname = footer[1:32];

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

# ╔═╡ 55541b08-7f25-4f66-8e1c-0b25a2999696
println("lv2py version 24.10.2021\n\n")

# ╔═╡ c586eab0-a43e-44ff-b887-56a9cee4800d
# printstyled("lv2py version 24.10.2021", color=:red)

# ╔═╡ f8eafb16-b142-47dc-9252-3dd3186baa32
begin
	gain_flag = footer[49:64];
	ells = findall("l", gain_flag);
	n_chans_in_footer = length(ells);
end

# ╔═╡ 7e21c96b-4c31-4f3d-94c1-94d1135942eb
data = transpose(reshape(Float64.(test_raw[1:end-336]), (n_chans_in_footer+1, :)));

# ╔═╡ 041be9f5-0e97-4657-8068-e6ad334a5b50
begin
	
	n_rec = Int((filesize(filename) - 336)/((n_chans_in_footer + 1) * 4));
	n_rec_footer = parse(Int, footer[33:48]);
	
	if isequal(n_rec, n_rec_footer)
		println("File size and footer match.")
	
	else
		println("File size and footer DO NOT match.")

	end
end

# ╔═╡ ed59ae61-76ff-49a6-9444-b47a4bb24b1f
writedlm(filename*"PY.csv",  data, ',')

# ╔═╡ e7cb3e07-86a6-4b8f-a0a5-1b33971cc667
# println(n_rec == n_rec_footer ? "File size and footer match." : "File size and footer DO NOT match.")

# ╔═╡ 56bc5cda-3460-4156-999e-bada6fe1f540
# string.(test[end-335:end], base = 2)

# ╔═╡ 4b54d3a1-f29a-423c-bfae-54b3cc728bb7
# begin
# 	filename = "p5595WGFrac10-21PressFilm";
# 	# test = read(filename);
# 	test = bswap.(reinterpret(UInt16, read(filename)))
# end

# ╔═╡ e9e69657-c63b-47f3-972d-2babdaa3e3a4
# fileSize = stat(filename).size;

# ╔═╡ 659fdf94-ed3c-45c6-980e-f56de305df93
# 304/16

# ╔═╡ 5b193218-a1d6-4a6b-8047-96c8b9bbe9c4
# footer[65:80]

# ╔═╡ b24ecf13-8d2d-4e87-8830-550f38651969
# 68982 

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DelimitedFiles = "8bb1440f-4735-579b-a4ab-409b98df4dab"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
"""

# ╔═╡ Cell order:
# ╠═2056320e-5328-4112-8303-c51be0ee87b0
# ╠═9503e409-de4e-4515-9bc2-fa6731599295
# ╠═4f2937a6-270b-4513-8cdb-646d9f6b7933
# ╠═1a5df692-1db4-4c93-bc3e-a9719666388d
# ╠═bd3ceb94-cfb7-4e0b-ad49-abe04c8bd418
# ╠═55541b08-7f25-4f66-8e1c-0b25a2999696
# ╠═c586eab0-a43e-44ff-b887-56a9cee4800d
# ╠═f8eafb16-b142-47dc-9252-3dd3186baa32
# ╠═7e21c96b-4c31-4f3d-94c1-94d1135942eb
# ╠═041be9f5-0e97-4657-8068-e6ad334a5b50
# ╠═ed59ae61-76ff-49a6-9444-b47a4bb24b1f
# ╠═e7cb3e07-86a6-4b8f-a0a5-1b33971cc667
# ╠═56bc5cda-3460-4156-999e-bada6fe1f540
# ╠═4b54d3a1-f29a-423c-bfae-54b3cc728bb7
# ╠═e9e69657-c63b-47f3-972d-2babdaa3e3a4
# ╠═659fdf94-ed3c-45c6-980e-f56de305df93
# ╠═5b193218-a1d6-4a6b-8047-96c8b9bbe9c4
# ╠═b24ecf13-8d2d-4e87-8830-550f38651969
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
