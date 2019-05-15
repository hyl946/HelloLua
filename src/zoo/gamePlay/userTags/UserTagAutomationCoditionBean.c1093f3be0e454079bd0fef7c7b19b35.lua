UserTagAutomationCoditionBean = class()

function UserTagAutomationCoditionBean:create( conditionId , parameters )
	--should be overwrite
	local bean = UserTagAutomationCoditionBean.new()
	bean:init( conditionId , parameters )
	return bean
end

function UserTagAutomationCoditionBean:init( conditionId , parameters )
	--should be overwrite
	self.conditionId = -1
end

function UserTagAutomationCoditionBean:checkCodition()
	--should be overwrite
	return false
end

function UserTagAutomationCoditionBean:getConditionId()
	return self.conditionId
end