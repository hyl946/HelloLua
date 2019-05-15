MF_CollectItem = class()

--[[
	自接受任务起，搜集value个关卡内物品。
	
	参数：
	parameters[1]物品类型,对应ItemType中的类型
]]
function MF_CollectItem:check(condition , context)
	
	local result = false

	if not condition then
		return result
	end

	if context 
		and context:getPlace() == TriggerContextPlace.OFFLINE
		and context:getValue(kHttpEndPoints.passLevel) then

		local conditionId = condition:getId()
		local targetValue = condition:getTargetValue()
		local parameters = condition:getParameters()
		local data = context:getValue(kHttpEndPoints.passLevel)

		if not parameters or #parameters == 0 then
			parameters = {}
			parameters[1] = ItemType.KWATER_MELON
		end
		
		local digJewelCount = MissionModel:getInstance():getLastPlayGameCache().digJewelCount
		
		if not digJewelCount then
			digJewelCount = 0
		end

		if tonumber(parameters[1]) == tonumber(ItemType.KWATER_MELON) then--收集夏日周赛的西瓜

			condition:setCurrentValue( condition:getCurrentValue() + digJewelCount )
			if condition:getCurrentValue() >= targetValue then
				result = true
			end
		end

	end
	
	return result
end

return MF_CollectItem