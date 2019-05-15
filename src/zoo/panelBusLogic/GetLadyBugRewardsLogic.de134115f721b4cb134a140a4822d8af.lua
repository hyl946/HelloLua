
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年12月27日 15:33:19
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- GetLadyBugRewardsLogic
---------------------------------------------------

assert(not GetLadyBugRewardsLogic)
GetLadyBugRewardsLogic = class()

function GetLadyBugRewardsLogic:init(taskId, ...)
	assert(type(taskId) == "number")
	assert(#{...} == 0)

	self.taskId = taskId
end

function GetLadyBugRewardsLogic:start(isShowTip, onSuccessCallback, onFailedCallback, ...)
	assert(type(isShowTip) == "boolean")
	assert(false == onSuccessCallback or type(onSuccessCallback) == "function")
	assert(false == onFailedCallback or type(onFailedCallback) == "function")
	assert(#{...} == 0)
	
	local function onSendMsgSuccess()

		local ladyBugInfo = UserManager:getInstance():ladyBugInfos_getLadyBugInfoById(self.taskId)
		assert(ladyBugInfo)

		ladyBugInfo.reward = 1

		ladyBugInfo = UserService:getInstance():ladyBugInfos_getLadyBugInfoById(self.taskId)
		assert(ladyBugInfo)

		ladyBugInfo.reward = 1

		if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
		else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
		
		if onSuccessCallback then
			onSuccessCallback()
		end
	end

	self:sendGetLadyBugRewardsMsg(isShowTip, onSendMsgSuccess, onFailedCallback)
end

function GetLadyBugRewardsLogic:sendGetLadyBugRewardsMsg(isShowTip, onSuccessCallback, onFailedCallback, ...)
	assert(type(isShowTip) == "boolean")
	assert(false == onSuccessCallback or type(onSuccessCallback) == "function")
	assert(false == onFailedCallback or type(onFailedCallback) == "function")
	assert(#{...} == 0)

	if not self.receiveItemMsgSended then
		self.receiveItemMsgSended = true
		
		local function onSuccess()
			if _G.isLocalDevelopMode then printx(0, "GetLadyBugRewardsLogic:sendGetLadyBugRewardsMsg Called ! Success !!") end
			if onSuccessCallback then
				onSuccessCallback()
			end
		end

		local function onFailed(evt)
			if _G.isLocalDevelopMode then printx(0, "GetLadyBugRewardsLogic:sendGetLadyBugRewardsMsg Called ! Failed !!") end
			if onFailedCallback then
				onFailedCallback(evt)
			end
		end

		local http = GetLadyBugRewards.new(isShowTip)
		http:addEventListener(Events.kComplete, onSuccess)
		http:addEventListener(Events.kError, onFailed)
		http:syncLoad(self.taskId)
	end
end

function GetLadyBugRewardsLogic:create(taskId, ...)
	assert(type(taskId) == "number")
	assert(#{...} == 0)

	local newGetLadyBugRewardsLogic = GetLadyBugRewardsLogic.new()
	newGetLadyBugRewardsLogic:init(taskId)
	return newGetLadyBugRewardsLogic
end
