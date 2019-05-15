local PRIORITY = {
	kTASK = 1,
	kNDJ = 2,
}

local min_p = PRIORITY.kTASK
local max_p = PRIORITY.kNDJ


local FlowerIconPriority = {
	PRIORITY = PRIORITY
}

local typeMapVisibleCheckFunc = {
	
}

local typeMapVisibleRefreshFunc = {
	
}
 

function FlowerIconPriority:canShow( kType, levelId, ... )
	
	for i = min_p, max_p do

		local bVisible = false
		if typeMapVisibleCheckFunc[i] then
			bVisible = typeMapVisibleCheckFunc[i](levelId or 1, ...)
		end

		if i == kType then
			return bVisible
		else
			if bVisible then
				return false
			end
		end
	end
	return false
end

function FlowerIconPriority:setCheckFunc( kType, func )
	typeMapVisibleCheckFunc[kType] = func
end

function FlowerIconPriority:setRefreshFunc( kType, func )
	typeMapVisibleRefreshFunc[kType] = func
end

function FlowerIconPriority:refresh( ... )
	for _, v in pairs(typeMapVisibleRefreshFunc) do
		v()
	end
end

return FlowerIconPriority