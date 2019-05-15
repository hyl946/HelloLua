local SupeCls = require("zoo/localActivity/UserCallBackTest/src/model/ActModel.lua")
local ActRewardModel = class(SupeCls)

--[[
	继承自ActModel
	领奖活动的Model基类，包含以下功能
	初始化 init 【需继承重写】
	领取奖励，当前奖励领取信息
	返回领宝箱需要的累计计数（getCurTargetCount 这个函数需要重写）
	更新icon对应tip
]]

function ActRewardModel:init(actKey, config, http, constants)
	self.boxRewardCfg = {}
	self.hasGainRewards = {} --这个数据需要在info数据里面再写一遍。不同的info接口存储名字可能不同， 通过复写ActRewardModel:gainReward(id)
	SupeCls.init(self, actKey, config, http, constants)
end

function ActRewardModel:reward(id, extra, successCallback, failCallback, cancelCallback)
	local function onSuccess( evt )
		self:getActivityRewardSucess(evt, successCallback)
	end

	local function onFail( evt ) 
		self:getActivityRewardFail(evt, failCallback)
	end

	local function onCancel()
		self:getActivityRewardCancel(cancelCallback)
	end

	local http = self.http.activityReward.new(true)
	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)
	http:setCancelCallback(onCancel)
	http:syncLoad(self.config.actId, id, extra)
end

function ActRewardModel:getActivityRewardSucess(evt, successCallback)
	self:gainReward(evt.data.rewardId)

	UserManager:getInstance():addRewards(evt.data.rewardItems)
	UserService:getInstance():addRewards(evt.data.rewardItems)
	GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kActivityInner, evt.data.rewardItems, DcSourceType.kActPre.."recall_reward", nil, self.config.actId)
	
	Localhost:getInstance():flushCurrentUserData()
	HomeScene:sharedInstance():checkDataChange()

	if successCallback then
		successCallback(evt.data.rewardItems)
	end
	self:updateRewardTipView()
end

function ActRewardModel:gainReward(id)
	self.hasGainRewards[#self.hasGainRewards + 1] = id
end

function ActRewardModel:getActivityRewardFail(evt, failCallback)
	local errcode = evt and evt.data or nil
 	if errcode then
 		local scene = Director:sharedDirector():run()
		if  scene ~= nil and scene:is(HomeScene) then
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errcode)), "negative")
		end
	else
		CommonTip:showTip(Localization:getInstance():getText("3009.error.tip.getAward.netErr"), "negative")
	end
	
	if failCallback then 
		failCallback() 
	end
end

function ActRewardModel:getActivityRewardCancel(cancelCallback)
	if cancelCallback then cancelCallback() end
end

function ActRewardModel:hasAvailableReward( ... )
	return self:hasBoxReward()
end

function ActRewardModel:hasBoxReward( ... )
	local rewards = self.hasGainRewards or {}
	local targetCount = self:getCurTargetCount()
	
	local hasReward = false
	local minIdx = -1
	for i=1, #self.boxRewardCfg do
		local isReward = self:hasGainReward(self.boxRewardCfg[i].rewardId)
		local canReward = targetCount >= self.boxRewardCfg[i].conditions

		if canReward then 
			minIdx = i
			if not isReward then
				hasReward = true
				break
			end
		end
	end
	return hasReward, minIdx
end

function ActRewardModel:hasNextBoxToAchive()
	local rewards = self.hasGainRewards or {}
	local targetCount = self:getCurTargetCount() or 0
	
	local hasBoxToAchive = false
	local minIdx = -1
	for i=1, #self.boxRewardCfg do
		local lackTarget = targetCount < self.boxRewardCfg[i].conditions
		if lackTarget then 
			hasBoxToAchive = true
			minIdx = i
			break
		end
	end
	
	return hasBoxToAchive, minIdx
end

function ActRewardModel:hasGainReward(rewardId)
	return table.exist(self.hasGainRewards, rewardId)
end

--------------------这个函数需要重写，返回领宝箱需要的累计计数
function ActRewardModel:getCurTargetCount( ... )
	return 0
end

function ActRewardModel:updateRewardTipView()

	local rewardFlag = 0
	local model = require("zoo/localActivity/UserCallBackTest/src/model/Model.lua"):getInstance()
    if model and not model.received then
    	rewardFlag = 1
    end
	local userCallbackActInfo = UserManager:getInstance().userCallbackActInfo
	if userCallbackActInfo then
		userCallbackActInfo.rewardFlag = rewardFlag
	end
	HomeScene:sharedInstance():buildHomeSceneUserCallBackButton()
end



return ActRewardModel