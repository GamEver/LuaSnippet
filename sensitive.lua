local function SensitiveWords()
	local obj = {}
	local dict = {}

	function obj.insert(str)
		local word = dict
		for i=1,#str do
			local ch = string.byte(str, i)
			if not word[ch] then word[ch] = {} end
			word = word[ch]
		end
		word.terminal = true
	end
	
	function obj.match(str, i)
		local word = dict
		local n = 0
		while true do
			local ch = string.byte(str, i + n)
			if word[ch] then
				word = word[ch]
				n = n + 1
			else
				if word.terminal then
					return true, n
				end
				break
			end
		end
		
		return false, 1
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

SensitiveDictionary.insert("傻逼")
SensitiveDictionary.insert("逼")
SensitiveDictionary.insert("QQ")

print( SensitiveDictionary.replace("我的QQ是123456，你真是个傻逼逼") )
]]

return SensitiveWords
