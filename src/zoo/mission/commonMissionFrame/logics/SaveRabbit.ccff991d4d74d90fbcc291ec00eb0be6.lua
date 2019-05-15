SaveRabbit = class()

--local logic = SaveRabbit.new()

function SaveRabbit:check(id , value , parameters , context)
	printx( 1 , "  SaveRabbit  id = " .. tostring(id) .. 
		"  value = " .. tostring(value) .. 
		"  parameters = " .. tostring(parameters) .. 
		"  context = " .. tostring(context)
		)

	local result = false
	local activityData = AnniversaryTaskManager:getInstance().activityData

	if context 
		and context.id == "PassLevelLogicPassRabbiteSuccess" 
		and tonumber(activityData.currTaskType) == AnniversaryTaskType.kSaveRabbit then

		local newnum = activityData.currTaskProgressValue + tonumber(context.data.targetCount)
		if newnum >= value then
			newnum = value
			result = true
		end

		activityData.currTaskProgressValue = newnum

		AnniversaryTaskManager:getInstance():dispatchEvent({
			name=AnniversaryTaskManager.EVENTS.kProgressChanged,
			data=activityData,
			target=AnniversaryTaskManager:getInstance()
		})

		if result then
			activityData.currTaskStatus = 1

			AnniversaryTaskManager:getInstance():dispatchEvent({
				name=AnniversaryTaskManager.EVENTS.kTaskStatusChanged,
				data=activityData,
				target=AnniversaryTaskManager:getInstance()
			})
		end
	end

	return result
end

return SaveRabbit