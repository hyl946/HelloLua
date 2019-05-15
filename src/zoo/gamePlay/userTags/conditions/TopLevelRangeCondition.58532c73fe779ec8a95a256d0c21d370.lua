TopLevelRangeCondition = class(UserTagAutomationCoditionBean)

function TopLevelRangeCondition:create( conditionId , parameters )
	local bean = TopLevelRangeCondition.new()
	bean:init( conditionId , parameters )
	return bean
end

function TopLevelRangeCondition:init( conditionId , parameters )
	self.conditionId = conditionId
	self.parameters = parameters
end

function TopLevelRangeCondition:checkCodition()

	local user = UserManager:getInstance():getUserRef()
	local topLevelId = user:getTopLevelId()
	local minTopLevelId = nil
	local maxTopLevelId = nil

	if self.parameters then
		if self.parameters[1] then
			minTopLevelId = tonumber(self.parameters[1])
		end

		if self.parameters[2] then
			minTopLevelId = tonumber(self.parameters[2])
		end
	end
	
	if minTopLevelId and maxTopLevelId then

		if maxTopLevelId == 0 then
			maxTopLevelId = 99999999
		end

		if minTopLevelId <= topLevelId <= maxTopLevelId then
			return true
		end
	end

	return false
end

return TopLevelRangeCondition