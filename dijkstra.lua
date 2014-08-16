--最短路径
local function ShortestPath(graph, src)

	local function ExtractMin(dist, path)
		local minDist = math.huge
		local nearest = nil
		for v,_ in pairs(path) do
			if dist[v] < minDist then
				minDist = dist[v]
				nearest = v
			end
		end
		return nearest
	end

	local dist = {}			--距离
	local prev = {}			--路径如何到达
	local path = {}			--已经完成扫描的路径

	for i in pairs(graph) do
		path[i] = true
		dist[i] = math.huge		--不可到达
	end

	dist[src] = 0

	while true do
		local u = ExtractMin(dist, path)
		if not u then break end

		path[u] = nil
		for _,v in ipairs(graph[u].adjacent_locations) do
			local alt = dist[u] + 1alt
			if not dist[v] or (alt < dist[v]) then
				dist[v] = alt
				prev[v] = u
			end
		end
	end

	return dist		--return dist, prev
end