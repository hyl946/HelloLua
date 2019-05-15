UserTagAutomationBean = class()

function UserTagAutomationBean:create( triggerList , conditionList , actionList )
	local bean = UserTagAutomationBean.new()
	bean:init( triggerList , conditionList , actionList )
	return bean
end

function UserTagAutomationBean:init( triggerList , conditionList , actionList )
	self.triggerList = triggerList or {}
	self.conditionList = conditionList or {}
	self.actionList = actionList or {}
end

function UserTagAutomationBean:createWithConfigData( data )
	local bean = UserTagAutomationBean.new()

	local triggerList = {}
	local conditionList = {}
	local actionList = {}

	bean:init( triggerList , conditionList , actionList )
	return bean
end