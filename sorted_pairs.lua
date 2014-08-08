local function sorted_pairs(hash_table, reverse)
	local sort = {}
	for k in pairs(hash_table) do
		table.insert(sort, k)
	end
	table.sort(sort, function(a, b)
		if not reverse then
			return a<b
		else
			return a>b
		end
	end)
	
	local last_key = nil
	return function(t)
		local key, value = next(t, last_key)
		if key then
			last_key = key
			return value, hash_table[value]
		end
	end, sort
end

local x =
{
   a=1,
   b=3,
   c=5,
   d=7,
   e=9,
}

for k,v in pairs(x) do
	print(k, v)
end
print()

--通过key排序后输出
for k,v in sorted_pairs(x) do
	print(k, v)
end