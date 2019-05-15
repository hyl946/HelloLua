PlayPluginGame = class()
printx( 1 , "  PlayPluginGamePlayPluginGamePlayPluginGame")
--local logic = PlayPluginGame.new()

function PlayPluginGame:check(id , value , parameters , context)
	printx( 1 , "  PlayPluginGame  id = " .. tostring(id) .. 
		"  value = " .. tostring(value) .. 
		"  parameters = " .. tostring(parameters) .. 
		"  context = " .. tostring(context)
		)

	local result = false
	
	local activityData = AnniversaryTaskManager:getInstance().activityData

	if context 
		and context.id == "PlayPluginGameDone" 
		and tonumber(activityData.currTaskType) == AnniversaryTaskType.kPlayPluginGame then

		printx( 1 , "   isGameFin = " == tostring(context.isGameFin))
		if context.isGameFin and activityData.currTaskStatus == 0 then
			activityData.currTaskStatus = 1
			result = true

			AnniversaryTaskManager:getInstance():dispatchEvent({
				name=AnniversaryTaskManager.EVENTS.kTaskStatusChanged,
				data=activityData,
				target=AnniversaryTaskManager:getInstance()
			})
		else
			result = false

			local taskData = context.taskData
			local taskManager = AnniversaryTaskManager:getInstance()
			local nowtime = os.time() + (__g_utcDiffSeconds or 0)
			if taskData then
				taskManager:buildData(
				taskData , 
				activityData.leftUpdateChance , 
				nowtime , 
				activityData.todayCompletedTasksNum)

				printx( 1 , "   PlayPluginGameDone  dispatchEvent   kTaskRefreshed ")
				taskManager:dispatchEvent({
					name=AnniversaryTaskManager.EVENTS.kTaskRefreshed,
					data=activityData,
					target=taskManager
				})
			end
		end
	end
	
	return result
end

return PlayPluginGame