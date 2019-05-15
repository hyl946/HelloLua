UserTagAutomationCoditionGroupBean = class()

UserTagAutomationCoditionGroupType = {
	kAND = 1 ,
	kOR = 2 ,
}

function UserTagAutomationCoditionGroupBean:create( childList , groupType )
	local bean = UserTagAutomationCoditionGroupBean.new()
	bean:init( childList , groupType )
	return bean
end

function UserTagAutomationCoditionGroupBean:init( childList , groupType )
	self.childList = childList or {}
	self.groupType = groupType or UserTagAutomationCoditionGroupType.kAND
end

function UserTagAutomationCoditionGroupBean:addCondition( condition )
	table.insert( self.childList , condition )
end

function UserTagAutomationCoditionGroupBean:getConditions()
	return self.childList or {}
end

function UserTagAutomationCoditionGroupBean:getConditionByIndex( conditionIndex )
	return self.childList[conditionIndex]
end

function UserTagAutomationCoditionGroupBean:getConditionByConditionId( conditionId )
	if self.childList then
		for k,v in pairs(self.childList) do
			if v:getConditionId() == conditionId then
				return v
			end
		end
	end
end

function UserTagAutomationCoditionGroupBean:removeConditionByIndex( conditionIndex )
	if self.childList and self.childList[conditionIndex] then
		table.remove( self.childList , conditionIndex )
	end
end

function UserTagAutomationCoditionGroupBean:removeConditionByConditionId( conditionId )
	if self.childList then
		for k,v in pairs(self.childList) do
			if v:getConditionId() == conditionId then
				table.remove( self.childList , k )
				break
			end
		end
	end
end

function UserTagAutomationCoditionGroupBean:removeAllConditions()
	self.childList = {}
end

function UserTagAutomationCoditionGroupBean:checkCoditions()
	if not self.childList then
		return
	end

	local result = false

	if self.groupType == UserTagAutomationCoditionGroupType.kAND then
		result = true
	end

	for k,v in pairs(self.childList) do
		if v:checkCodition() then
			if self.groupType == UserTagAutomationCoditionGroupType.kOR then
				result = true
				break
			end
		else
			if self.groupType == UserTagAutomationCoditionGroupType.kAND then
				result = false
				break
			end
		end
	end

	return result
end