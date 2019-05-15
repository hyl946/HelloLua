MF_HarvestFruit = class()

--local logic = HarvestFruit.new()

--[[
	获取value个果实
	parameters 果实类型 0任意类型 1银币 2精力 3风车币 
]]
function MF_HarvestFruit:check(id , value , parameters , context)
	printx( 1 , "  HarvestFruit  id = " .. tostring(id) .. 
		"  value = " .. tostring(value) .. 
		"  parameters = " .. tostring(parameters) .. 
		"  context = " .. tostring(context)
		)

	local result = false
	local activityData = AnniversaryTaskManager:getInstance().activityData
	
	if context 
		and context.id == "PickFruitHttpSuccess" 
		and tonumber(activityData.currTaskType) == AnniversaryTaskType.kHarvestFruit then
		printx( 1 , "   HarvestFruit:check 111")
		if type(context.data.reward) == "table" then
			printx( 1 , "   HarvestFruit:check 222")
			local function checkValue()
				printx( 1 , "   HarvestFruit:check 444  " .. tostring(activityData.currTaskProgressValue) )
				activityData.currTaskProgressValue = tonumber(activityData.currTaskProgressValue) + 1
				printx( 1 , "   HarvestFruit:check 555  " .. tostring(activityData.currTaskProgressValue) )

				AnniversaryTaskManager:getInstance():dispatchEvent({
					name=AnniversaryTaskManager.EVENTS.kProgressChanged,
					data=activityData,
					target=AnniversaryTaskManager:getInstance()
				})

				if tonumber(activityData.currTaskProgressValue) >= tonumber(value) then
					result = true

					activityData.currTaskStatus = 1
					printx( 1 , "   HarvestFruit:check 666")
					AnniversaryTaskManager:getInstance():dispatchEvent({
						name=AnniversaryTaskManager.EVENTS.kTaskStatusChanged,
						data=activityData,
						target=AnniversaryTaskManager:getInstance()
					})
				end
			end

			if tonumber(parameters) == 0 then
				printx( 1 , "   HarvestFruit:check 333")
				checkValue()
			elseif tonumber(parameters) == 1 and context.data.reward.itemId == 2 then
				checkValue()
			elseif tonumber(parameters) == 2 and context.data.reward.itemId == 4 then
				checkValue()
			elseif tonumber(parameters) == 3 and context.data.reward.itemId ~= 2 and context.reward.data.itemId ~= 4 then
				checkValue()
			end

		end


	end 
	

	return result
end

return MF_HarvestFruit