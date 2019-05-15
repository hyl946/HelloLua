require "zoo.gamePlay.userTags.UserTagAutomationConfig"
require "zoo.gamePlay.userTags.UserTagManager"

local __instance = nil
UserTagAutomationManager = class()

function UserTagAutomationManager:init()

end

function UserTagAutomationManager:getInstance()
	if not __instance then
		__instance = UserTagAutomationManager.new()
	end

	return __instance
end

function UserTagAutomationManager:__checkTagHasChanged( nameKey , source )
	printx( 1 , "UserTagAutomationManager:__checkTagHasChanged ---------------------- nameKey =" , nameKey , "source =" , source)

	local tagId = UserTagNameKeyToTagIdMap[nameKey]

	printx( 1 , "UserTagAutomationLogicNames = " , table.tostring(UserTagAutomationLogicNames) , "\ntagId =" , tagId)

	if UserTagAutomationLogicNames[tagId] then

		local className = UserTagAutomationLogicNames[tagId]
		local oldTagVaule = UserTagModel:getInstance():getUserTagBySeries( nameKey )
		local _clazz = require( "zoo/gamePlay/userTags/conditions/" .. className .. ".lua" )

		local logic = _clazz:create()
		local hasChanged , newUpdateTagBean = logic:checkChange( oldTagVaule )
		printx( 1 , "UserTagAutomationManager:__checkTagHasChanged  hasChanged =" , hasChanged , "newUpdateTagBean =" , table.tostring(newUpdateTagBean))
		if hasChanged then

			local tagGroup = UserTagNameKeyToGroupMap[nameKey]
			UserTagModel:getInstance():updateTag( tagGroup , newUpdateTagBean , source )
			UserTagModel:getInstance():flushLocalData()
		end
	end
end


function UserTagAutomationManager:checkTagHasChanged( source )

	--printx( 1 , "UserTagAutomationManager:checkTagHasChanged ---------------------- " , source)

	if source == UserTagDCSource.kPassLevel then
		self:__checkTagHasChanged( UserTagNameKeyFullMap.kTopLevelDiff , source )
	end
	
end

function UserTagAutomationManager:trigger()

end

function UserTagAutomationManager:addAutomation()
	
end

function UserTagAutomationManager:removeAutomation()
	
end

function UserTagAutomationManager:clearutomation()
	
end

function UserTagAutomationManager:getAutomation()
	
end

function UserTagAutomationManager:runAutomation()
	
end