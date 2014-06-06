module('http', package.seeall)

function string:split(delimiter)
	if #delimiter==0 then return {self} end

	local result = {}
	local position = 1
		
	repeat
		local delim_start, delim_end = self:find(delimiter, position, true)
		
		local temp = ""
		if delim_start then
			temp = self:sub(position, delim_start - 1)
			position = delim_end + 1
		else
			temp = self:sub(position)
		end
		
		if temp~="" then
			table.insert(result, temp)
		end
		
	until not delim_start
	return result
end

function string:lines(i)
	local count = 1
	for line in self:gmatch("[^\r\n]+") do
		if count==i then return line end
		count = count + 1
	end
	return self
end

function escape(s)
	local str, _ = string.gsub(s, "([^A-Za-z0-9_])", function(c)
		return string.format("%%%02X", string.byte(c))
	end)
	return str
end

function unescape(s)
	s = string.gsub(s, "+", " ")
	return string.gsub(s, "%%(%x%x)", function(hex)
		return string.char(tonumber(hex, 16))
	end)
end

--GET http://127.0.0.1:8080/favicon.ico/dfg HTTP/1.1\r\n……
function prase_method(s)
	return s:lines(1):match("(.*)%s(.*)%s(.*)")
end

local parting = "\r\n\r\n"
function prase_request(s)
	local pos = string.find(s, parting)
	if pos then return string.sub(s, 1, pos-1), string.sub(s, pos + #parting) end
end

--xx=sdf&sdfdf=12312
function prase_param(s)
	local attrs = {}
	for _, str in ipairs(s:split("&")) do
		local pos = string.find(str, "=")
		if pos then 
			attrs[string.sub(str, 1, pos-1)] = string.sub(str, pos + 1)
		end
	end
	return attrs
end

-- <url> ::= <scheme>://<authority>/<path>;<params>?<query>#<fragment>
-- http://username:password@hostname:port/path?arg=value#anchor
function prase_url(url)
	local parsed = {}
	
	url = string.gsub(url, "#(.*)$", function(s)
		parsed.fragment = s
		return ""
	end)
	
	url = string.gsub(url, "^([%w][%w%+%-%.]*)%:", function(s)
		parsed.scheme = s
		return ""
	end)
	
	url = string.gsub(url, "^//([^/]*)", function(s)
		parsed.authority = s
		return ""
	end)
	
	url = string.gsub(url, "%?(.*)", function(s)
		parsed.query = s
		return ""
	end)
	
	parsed.path = string.gsub(url, "%;(.*)", function(s)
		parsed.params = s
		return ""
	end)
	
	return parsed
end

function build_handle()
	local obj = {}
	local indexs = {}
	
	obj.bind = function(...)
		local args = {...}
		indexs[#indexs+1] = {}
		indexs[#indexs].value = table.remove(args, #args)
		indexs[#indexs].key = args
	end
	
	obj.match = function(...)
		for _, info in ipairs(indexs) do
			for i, v in pairs({...}) do
				if info.key[i]==obj.any or info.key[i]==v then
					if i==#info.key then
						return info.value
					end
				else
					break
				end
			end
		end
	end
	
	return obj
end

function build_params(params)
	local str = {}
	for k,v in pairs(params) do
		table.insert(str, k)
		table.insert(str, "=")
		table.insert(str, escape(tostring(v)))
		table.insert(str, "&")
	end
	table.remove(str)
	return table.concat(str)
end
