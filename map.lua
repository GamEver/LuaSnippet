--支持多个索引的扩展table
local function map(...)
	local obj = {}

	local tables = {} --原始数据记录

	local indexs = {} --构建索引记录
	for _,name in ipairs({...}) do
		indexs[name] = {}
	end

	--目标值应该在数组中的位置，二分查找
	local function binarySearch(index, list, key, value)
		local low = 1
		local high = #index
		while low <= high do
			local mid = math.floor((low+high)/2)
			if list[index[mid]][key] > value then
				high = mid - 1
			elseif list[index[mid]][key] < value then
				low = mid + 1
			else
				return mid
			end
		end
		return low
	end

	--添加数据
	obj.add = function(t)
		--保存原始数据
		table.insert(tables, t)

		--建立索引
		for key,index in pairs(indexs) do
			if not t[key] then error("the table must have a key named '"..key.."'") end
			table.insert(index, binarySearch(index, tables, key, t[key]), #tables)
		end
	end

	--根据索引获取
	obj.get = function(index_name)
		--代理table
		local proxy = {}

		--是否具有索引，没有时使用原始数据
		local index = indexs[index_name]

		--设置元表
		setmetatable(proxy, {
			__pairs = function(_)
				local temp = index or tables
				return function(_, p)
					local k,idx = next(temp, p)
					if k then
						return k, index and tables[idx] or idx
					end
				end, temp
			end,
			__index = function(_, k)
				return index and tables[index[k]] or tables[k]
			end,
			__len = function()
				return #tables
			end,
			})
		return proxy
	end

	return obj
end

--[[
local function test()
	local a = map("id","value","type")
	a.add({id=1,value=2,type=3})
	a.add({id=3,value=1,type=2})
	a.add({id=2,value=3,type=1})
	a.add({id=4,value=4,type=4})

	local x = a.get("type")
	for k,v in pairs(x) do
		print(k, "{id="..v.id..", value="..v.value..", type="..v.type.."}")
	end
	print(x[1].id)
end

test()

//输出
1	{id=2, value=3, type=1}
2	{id=3, value=1, type=2}
3	{id=1, value=2, type=3}
4	{id=4, value=4, type=4}
2
]]

table.orderby = function(t, ...)
	local order = {...}
	table.sort(t, function(a, b)
		for _,k in pairs(order) do
			if a[k]~=b[k] then
				return a[k]<b[k]
			end
		end
	end)
end

local function test()
	local a = map("id","value","type")
	a.add({id=1,value=2,type=3})
	a.add({id=3,value=1,type=2})
	a.add({id=2,value=3,type=1})
	a.add({id=4,value=4,type=4})

	local x = a.get("type")
	print(#x)
	for k,v in pairs(x) do
		print(k, "{id="..v.id..", value="..v.value..", type="..v.type.."}")
	end
	print(x[1].id)
end

--test()

local function is_lua52_compatible()
	local compatible = {}
	setmetatable(compatible, {__len=function() return 1 end})
	return #compatible==1
end

assert(is_lua52_compatible(),"Please modify luajit Makefile 103 line to enable lua 5.2 compatible")

--[[
a = {{id=2,value=1,type=3},{id=3,value=1,type=2},{id=2,value=3,type=1},{id=4,value=4,type=4}}

for k,v in pairs(a) do
	print(k, "{id="..v.id..", value="..v.value..", type="..v.type.."}")
end

print()
print()
]]

--[[
table.orderby(a, "id", "value")

for k,v in pairs(a) do
	print(k, "{id="..v.id..", value="..v.value..", type="..v.type.."}")
end
]]