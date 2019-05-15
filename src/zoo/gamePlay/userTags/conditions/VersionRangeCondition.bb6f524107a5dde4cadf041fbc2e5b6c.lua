VersionRangeCondition = class(UserTagAutomationCoditionBean)

function VersionRangeCondition:create( conditionId , parameters )
	local bean = VersionRangeCondition.new()
	bean:init( conditionId , parameters )
	return bean
end

function VersionRangeCondition:init( conditionId , parameters )
	self.conditionId = conditionId
	self.parameters = parameters
end

function VersionRangeCondition:checkCodition()	

	local curVersion = _G.bundleVersion

	local uid = UserManager:getInstance():getUID()
	local uidStr = tostring( uid )
	local uidNumber = tonumber( string.sub( uidStr , -4 ) )
	local minNumber = nil
	local maxNumber = nil

	if self.parameters then

		local versionStr = tostring(self.parameters)
		--string.slipt()
		if self.parameters[1] then
			minNumber = tonumber(self.parameters[1])
		end

		if self.parameters[2] then
			maxNumber = tonumber(self.parameters[2])
		end
	end
	
	if uidNumber and minNumber and maxNumber then

		if minNumber < uidNumber <= maxNumber then
			return true
		end
	end

	return false
end

return VersionRangeCondition