
local AFHLevelFailedLogic = class()

function AFHLevelFailedLogic:ctor()
end

function AFHLevelFailedLogic:create(levelId, quitcallback, ...)
	assert(type(levelId) == "number")
	assert(#{...} == 0)

	local instance = AFHLevelFailedLogic.new()
	instance:init(levelId, quitcallback)
	return instance
end

function AFHLevelFailedLogic:init(levelId, quitcallback, ...)
	assert(type(levelId) == "number")
	assert(#{...} == 0)

	self.levelId = levelId
	self.quitcallback = quitcallback
end

function AFHLevelFailedLogic:start(...)
	assert(#{...} == 0)
	
	local function onPanelSelected(retry)
		if not retry then
			self:invokeCbk()
			AskForHelpManager:getInstance():leaveMode()
			return
		end

		local senderUid = AskForHelpManager:getInstance():getDoneeUId()
		local function onCheckFinished(ret)
   			if ret then
   			    local function startLevel()
					AskForHelpManager:getInstance():enterMode(senderUid)
   			        HomeScene:sharedInstance().worldScene:startLevel(self.levelId, StartLevelType.kAskForHelp)
   			    end
   			    HomeScene:sharedInstance():runAction(CCCallFunc:create(startLevel))
   			else
   			    AskForHelpManager:getInstance():leaveMode()
   			end
		end
		self:invokeCbk()
   		AskForHelpManager:getInstance():pocessDecision(true, senderUid, self.levelId, onCheckFinished)
	end

	local AFHLevelFailedPanel = require 'zoo.panel.askForHelp.views.AFHLevelFailed'
	AFHLevelFailedPanel:create(onPanelSelected):popout()
end

function AFHLevelFailedLogic:invokeCbk()
	if type(self.quitcallback) == "function" then
		self.quitcallback()
	end
end

return AFHLevelFailedLogic
