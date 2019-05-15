MF_HarvestFruit = class()

--[[
	获取value个果实
	parameters 果实类型 0任意类型 1银币 2精力 3风车币 
]]
function MF_HarvestFruit:check(condition , context)

	local result = false

	if not condition then
		return result
	end

	if context 
		and context:getPlace() == TriggerContextPlace.ONLINE_SETTER
		and context:getValue(kHttpEndPoints.pickFruit) then

		local conditionId = condition:getId()
		local targetValue = condition:getTargetValue()
		local parameters = condition:getParameters()
		local data = context:getValue(kHttpEndPoints.pickFruit)

		if type(data.reward) == "table" then
			local function checkValue()
				condition:setCurrentValue( condition:getCurrentValue() + 1 )

				if tonumber(condition:getCurrentValue()) >= tonumber(targetValue) then
					result = true
				end
			end

			if not parameters or #parameters == 0 then
				parameters = {}
				parameters[1] = 0
			end

			if tonumber(parameters[1]) == 0 then --不限制
				checkValue()
			elseif tonumber(parameters[1]) == 1 and context.data.reward.itemId == 2 then --仅银币
				checkValue()
			elseif tonumber(parameters[1]) == 2 and context.data.reward.itemId == 4 then  --仅精力
				checkValue()
			elseif tonumber(parameters[1]) == 3 and context.data.reward.itemId ~= 2 and context.reward.data.itemId ~= 4 then  --仅风车币
				checkValue()
			end

		end
	end 
	return result
end

return MF_HarvestFruit