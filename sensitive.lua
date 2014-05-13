local function SensitiveWords()
	local obj = {}
	local trie = {}

	function obj.insert(str)
		local word = trie
		for i=1,#str do
			local ch = string.byte(str, i)
			if not word[ch] then word[ch] = {} end
			word = word[ch]
		end
		
		if word~=trie then word.terminal = true end
	end
	
	function obj.match(str, i)
		local word = trie
		local m = {1}
		local n = 0
		while true do
			if word.terminal then
				table.insert(m, n)
			end
			local ch = string.byte(str, i + n)
			if word[ch] then
				word = word[ch]
				n = n + 1
			else
				break
			end
		end
		
		return #m>1, m[#m]
	end

	function obj.replace(str)
		local result = {}
		local i = 1
		while true do
			local match, step = obj.match(str, i)
			if match then
				table.insert(result, "**")--string.rep("*", step)
			else
				table.insert(result, string.char(string.byte(str, i)))
			end
			
			i = i + step
			if i>#str then
				break
			end
		end
		
		return table.concat(result)
	end

	return obj
end

--[[
local SensitiveDictionary = SensitiveWords()
SensitiveDictionary.insert("ab")
SensitiveDictionary.insert("abcc")

print( SensitiveDictionary.replace("abcd") )
]]

return SensitiveWords
