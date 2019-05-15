--[[
 * MockConfigs
 * @date    2018-11-09 10:41:07
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

require "zoo.scenes.component.HomeScene.popoutQueue.HomeScenePopoutAction"

local BaseAction = class(HomeScenePopoutAction)
function BaseAction:ctor()
	self.name = "BaseAction"
end
function BaseAction:checkCanPopReturnTrue()
	self:onCheckPopResult(true)
end
function BaseAction:checkCanPopReturnFalse()
	self:onCheckPopResult(false)
end

function BaseAction:checkCanCacheReturnTrue(cache)
	self:onCheckCacheResult(true)
end
function BaseAction:checkCanCacheReturnFalse(cache)
	self:onCheckCacheResult(false)
end

function BaseAction:popout(next_action)
    next_action()
end

local function CreateAction( name, isCheckCache, isCheckSuccess, ... )
	local cls = class(BaseAction)
	if isCheckCache then
		if isCheckSuccess then
			cls.checkCache = BaseAction.checkCanCacheReturnTrue
		else
			cls.checkCache = BaseAction.checkCanCacheReturnFalse
		end
	else
		if isCheckSuccess then
			cls.checkCanPop = BaseAction.checkCanPopReturnTrue
		else
			cls.checkCanPop = BaseAction.checkCanPopReturnFalse
		end
	end

	local sources = {...}
	cls.ctor = function ( context )
		context.name = name
		context:setSource(unpack(sources))
	end

	return cls
end

local TopActions = {
	CreateAction('TopActions1', false, true, AutoPopoutSource.kInitEnter ),
	CreateAction('TopActions2', false, false, AutoPopoutSource.kInitEnter ),
	CreateAction('TopActions3', true, true, AutoPopoutSource.kInitEnter ),
	CreateAction('TopActions4', true, false, AutoPopoutSource.kInitEnter ),


	CreateAction('TopActions5', false, true, AutoPopoutSource.kSceneEnter ),
	CreateAction('TopActions6', false, true, AutoPopoutSource.kEnterForeground ),
	CreateAction('TopActions7', false, true, AutoPopoutSource.kTriggerPop ),
	CreateAction('TopActions8', false, true, AutoPopoutSource.kGamePlayQuit ),
	CreateAction('TopActions9', false, true, AutoPopoutSource.kReturnFromFAQ )
}

local OpenUrlActions = {
	CreateAction('OpenUrlActions1', true, true, AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground ),
	CreateAction('OpenUrlActions2', true, false, AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground ),
}

local NextLevelModeActions = {
	CreateAction('NextLevelModeActions1', true, true, AutoPopoutSource.kTriggerPop ),
	CreateAction('NextLevelModeActions2', true, false, AutoPopoutSource.kTriggerPop ),
	CreateAction('NextLevelModeActions3', true, true, AutoPopoutSource.kTriggerPop ),
	CreateAction('NextLevelModeActions4', true, true, AutoPopoutSource.kTriggerPop ),
	CreateAction('NextLevelModeActions5', true, true, AutoPopoutSource.kTriggerPop ),
}

local FeatureActions = {
	{AutoPopoutActionType.kSubFeatureNotify, CreateAction('kSubFeatureNotify1', true, true, AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground )},
	{AutoPopoutActionType.kSubFeatureNormal, CreateAction('kSubFeatureNormal1', false, true, AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kSceneEnter )},
	{AutoPopoutActionType.kSubFeatureSystem, CreateAction('kSubFeatureSystem1', false, true, AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kSceneEnter )},
}

local ActivityActions = {
	CreateAction('ActivityActions1', false, true, AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground ),
}

local GuideActions = {
	CreateAction('GuideActions1', false, true, AutoPopoutSource.kTriggerPop ),
}

return {
	{actionType = AutoPopoutActionType.kTop, 			actions = TopActions},
	{actionType = AutoPopoutActionType.kOpenUrl, 		actions = OpenUrlActions},
	{actionType = AutoPopoutActionType.kNextLevelMode, 	actions = NextLevelModeActions},

	{actionType = AutoPopoutActionType.kFeature, 		actions = FeatureActions},

	{actionType = AutoPopoutActionType.kActivity, 		actions = ActivityActions},
	{actionType = AutoPopoutActionType.kGuide, 			actions = GuideActions},
	{actionType = AutoPopoutActionType.kBottom, 		actions = {}},
}