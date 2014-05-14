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
		local m = nil
		local n = 0
		while true do
			if word.terminal then
				m = n
			end
			local ch = string.byte(str, i + n)
			if word[ch] then
				word = word[ch]
				n = n + 1
			else
				break
			end
		end
		
		return m, m or 1
	end
	
	function obj.contain(str)
		local i = 1
		while true do
			local match, step = obj.match(str, i)
			assert(step>0)
			if match then
				return true
			end
			
			i = i + step
			if i>#str then
				break
			end
		end
		return false
	end

	function obj.replace(str)
		local result = {}
		local i = 1
		while true do
			local match, step = obj.match(str, i)
			assert(step>0)
			if match then
				table.insert(result, "**")--string.rep("*", step)
			else
				table.insert(result, str:sub(i, i))
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
SensitiveDictionary.insert("傻逼")
SensitiveDictionary.insert("QQ")
SensitiveDictionary.insert("123")

print( SensitiveDictionary.replace("我的QQ是123456，你就是个傻逼。") )
print( SensitiveDictionary.contain("234561") )
]]

return SensitiveWords
