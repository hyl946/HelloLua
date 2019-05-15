CheckLevelPassed = class()

--local logic = CheckLevelPassed.new()

--[[
	是否通过某一关卡
	value 关卡Id
	parameters 通过时的最低星级
]]
function CheckLevelPassed:check(id , value , parameters , context)
	
	local result = false

	if context and context.id == "PassLevelHttpSuccess" then

		local activityData = AnniversaryTaskManager:getInstance().activityData
		local toplv = UserManager:getInstance():getUserRef():getTopLevelId()

		if activityData and tonumber(activityData.currTaskType) <= AnniversaryTaskType.kPass4Star then

			if tonumber(activityData.currTaskType) == AnniversaryTaskType.kPassLevel then
				if tonumber(context.data.levelId) == tonumber(toplv) 
					and tonumber(activityData.currTaskProgressValue) < tonumber(context.data.levelId) then

					activityData.currTaskProgressValue = context.data.levelId

					AnniversaryTaskManager:getInstance():dispatchEvent({
						name=AnniversaryTaskManager.EVENTS.kProgressChanged,
						data=activityData,
						target=AnniversaryTaskManager:getInstance()
					})
				end
			end

			if tonumber(context.data.levelId) == tonumber(value) and tonumber(context.data.star) >= tonumber(parameters) then
				result = true

				if tonumber(activityData.currTaskType) == AnniversaryTaskType.kPass3Star 
					or tonumber(activityData.currTaskType) == AnniversaryTaskType.kPass4Star then

					activityData.currTaskProgressValue = context.data.levelId
					
					AnniversaryTaskManager:getInstance():dispatchEvent({
						name=AnniversaryTaskManager.EVENTS.kProgressChanged,
						data=activityData,
						target=AnniversaryTaskManager:getInstance()
					})

				end

				activityData.currTaskStatus = 1

				AnniversaryTaskManager:getInstance():dispatchEvent({
					name=AnniversaryTaskManager.EVENTS.kTaskStatusChanged,
					data=activityData,
					target=AnniversaryTaskManager:getInstance()
				})
			end

		end
	end
	return result
end

return CheckLevelPassed