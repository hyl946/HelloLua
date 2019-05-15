
ChanceUtils = class()

-- return table of index
-- return {} by error
function ChanceUtils:randomSortByChance(tab)
	if not tab or #tab == 0 then return {} end
	local res, newTab, key = {}, {}, {}
	for k, v in ipairs(tab) do
		if v < 0 then return {} end
		table.insert(key, k)
		table.insert(newTab, v)
	end
	while #tab > #res do
		local index = ChanceUtils:randomSelectByChance(newTab)
		if index == 0 then return {} end
		table.insert(res, key[index])
		table.remove(key, index)
		table.remove(newTab, index)
	end
	return res
end

-- return index
-- return 0 by error
function ChanceUtils:randomSelectByChance(tab)
	if not tab or #tab == 0 then return 0 end
	local total = 0
	for k, v in ipairs(tab) do
		if v < 0 then return 0 end
		total = total + v
	end
	if total == 0 then return 0 end
	local random = math.random(total)
	while true do
		for k, v in ipairs(tab) do
			random = random - v
			if random < 0 then return k end
		end
	end
end