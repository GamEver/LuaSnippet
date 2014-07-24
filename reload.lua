local function ReloadConfig()
	local function search(module, func)
		for path in string.gmatch(package.path, "[^;]+") do
			if func(path:gsub("?", module)) then
				break
			end
		end
	end
	local function copy(dst, src)
		for k in pairs(dst) do
			dst[k] = nil
		end
		for k,v in pairs(src) do
			dst[k] = v
		end
	end
	local function reload(moudle)
		search(moudle, function(path)
			local ret, err = loadfile(path)
			if not ret then
				--print(err)
			else
				copy(package.loaded[moudle], ret())
				return true
			end
		end)
	end

	reload('config')
end