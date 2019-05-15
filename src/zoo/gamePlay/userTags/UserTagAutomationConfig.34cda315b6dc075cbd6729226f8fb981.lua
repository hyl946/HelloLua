require "zoo.gamePlay.userTags.UserTagModel"

UserTagAutomationConfig = {}

UserTagAutomationConditionNames = {}
UserTagAutomationLogicNames = {}

for k,v in pairs(UserTagNameKeyFullMap) do
	local tagId = UserTagNameKeyToTagIdMap[v]
	UserTagAutomationLogicNames[tagId] = string.upper( string.sub( v , 1 , 1) ) .. string.sub( v , 2) .. "Logic"
end


UserTagAutomationConditionNames[1] = "topLevelRangeCondition"
UserTagAutomationConditionNames[2] = "uidRangeCondition"
UserTagAutomationConditionNames[3] = "versionRangeCondition"
UserTagAutomationConditionNames[4] = "platformRangeCondition"
UserTagAutomationConditionNames[5] = "lastPayTimeCondition"

----[[
printx( 0 , "===============================================================================================" )
printx( 0 , "============================== UserTagAutomationLogicNames ====================================" )
printx( 0 , "===============================================================================================" )
printx( 0 , table.tostring(UserTagAutomationLogicNames))
printx( 0 , "===============================================================================================" )
--]]

