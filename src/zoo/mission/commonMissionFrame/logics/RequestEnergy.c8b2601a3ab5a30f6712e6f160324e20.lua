RequestEnergy = class()

--local logic = RequestEnergy.new()

function RequestEnergy:check(id , value , parameters , context)
	printx( 1 , "  RequestEnergy  id = " .. tostring(id) .. 
		"  value = " .. tostring(value) .. 
		"  parameters = " .. tostring(parameters) .. 
		"  context = " .. tostring(context)
		)

	local result = false
	local activityData = AnniversaryTaskManager:getInstance().activityData

	if context 
		and context.id == "SendFreegiftHttpSuccess" 
		and tonumber(activityData.currTaskType) == AnniversaryTaskType.kRequestEnergy then

		local ids = context.data.receiverUids
		
		if ids and type(ids) == "table" and #ids > 0 then

			AnniversaryTaskManager:getInstance():dispatchEvent({
					name=AnniversaryTaskManager.EVENTS.kProgressChanged,
					data=activityData,
					target=AnniversaryTaskManager:getInstance()
				})

			if tonumber(activityData.currTaskProgressValue) + #ids >= value then
				
				activityData.currTaskProgressValue = value
				activityData.currTaskStatus = 1
				result = true

				AnniversaryTaskManager:getInstance():dispatchEvent({
					name=AnniversaryTaskManager.EVENTS.kTaskStatusChanged,
					data=activityData,
					target=AnniversaryTaskManager:getInstance()
				})

			else
				activityData.currTaskProgressValue = activityData.currTaskProgressValue + #ids
			end
		end
	end

	return result
end

return RequestEnergy