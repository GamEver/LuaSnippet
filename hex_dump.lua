local function hex_dump(str)
	local buf = {}
	for char in str:gmatch(".") do
		table.insert(buf, string.format("%02X", char:byte(1)))
	end
	
	return table.concat(buf, " ")
end

local str = "abc\nxyz"
print(hex_dump(str)) --61 62 63 0A 78 79 7A
