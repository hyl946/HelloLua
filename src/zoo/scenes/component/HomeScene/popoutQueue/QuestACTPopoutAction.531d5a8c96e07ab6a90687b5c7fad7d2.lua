-- local UserCallBackPanel = require "zoo.localActivity.UserCallBackTest.Start"
QuestACTPopoutAction = class(HomeScenePopoutAction)

function QuestACTPopoutAction:ctor()
	self.name = "QuestACTPopoutAction"
	self:setSource(AutoPopoutSource.kSceneEnter, AutoPopoutSource.kGamePlayQuit, AutoPopoutSource.kTriggerPop)
	self.offlinePopCount = 0

	self.lastCheckTS = 0
	self.lastHasNet = true
end

function QuestACTPopoutAction:getActInfo()
	local actInfo 
	for k, v in pairs(UserManager:getInstance().actInfos or {}) do
	    if self.info[v.actId] then
	        actInfo = v
	        break
	    end
	end

	return actInfo
end

function QuestACTPopoutAction:checkCanPop()
	local ret = false
	local QuestActLogic = require 'zoo.quest.QuestActLogic'

	local function shouldPop( ... )
		return QuestActLogic:isActEnabled() and QuestActLogic:hasAnyRewards()
	end

	if shouldPop() then

		require "zoo.util.NetworkUtil"

		local function hasNet( ... )
			self.offlinePopCount = 0
			self:onCheckPopResult(shouldPop())
			self.lastHasNet = true
		end

		local function hasNoNet( ... )
			if shouldPop() and self.offlinePopCount <= 0 then
				self.offlinePopCount = self.offlinePopCount + 1
				self:onCheckPopResult(true)
			else
				self:onCheckPopResult(false)
			end
			self.lastHasNet = false
		end

		if Localhost:timeInSec() - self.lastCheckTS <= 10*60 and self.lastHasNet == false then
			hasNoNet()
			return
		end


		if NetworkUtil:isConnected() then
			PaymentNetworkCheck:getInstance():check(hasNet, hasNoNet)
			self.lastCheckTS = Localhost:timeInSec()
		else
			hasNoNet()
		end
	else
		self:onCheckPopResult(false)
	end
end

function QuestACTPopoutAction:popout(next_action)
	local QuestActLogic = require 'zoo.quest.QuestActLogic'
	if QuestActLogic:isActEnabled() then
		QuestActLogic:openMainPanel()
	end
end
