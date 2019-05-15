require 'zoo.panel.askForHelp.AskForHelpHttpUtil'

local cfg = require 'zoo.panel.askForHelp.AskForHelpCfg'
local AskForHelpData = require 'zoo.panel.askForHelp.AskForHelpData'
local Timer = require('zoo.panel.askForHelp.component.Timer')

AFHEvents = {
	kAFHNewCaller = "afh.newCaller",		-- 新的代打请求
	kAFHSuccessEvent = "afh.successEvent",	-- 新的代打成功消息
};

AskForHelpManager = class(EventDispatcher)
function AskForHelpManager:ctor( ... )
	self.helpData = nil
end

local instance
function AskForHelpManager:getInstance( ... )
	if not instance then
		instance = AskForHelpManager.new()
	end
	return instance
end

function AskForHelpManager:init( ... )
	self.levelStarted = false
	self.helpData = self:getHelpDataFromLocal()
	self.cfg = cfg.new()
	self.passDayTimer = Timer:create()
	self.isInited = true

	self:startPassDayCountDown()
	self:getHelpDataFromServer(nil, nil, true)

	-- listener
	local function onNewCaller(evt)
		local dat = evt.data or {}
		if dat._isCached then return end

		self:dispatchEvent(Event.new(AFHEvents.kAFHNewCaller))
	end
	EmergencySystem:getInstance():addEventListener(kEmergencyEvents.kAFHNewCaller, onNewCaller)


	local function onSuccessEvent(evt)
		local dat = evt.data or {}

		local uid = dat.uid or '12345'
		local levelId = dat.levelId or 1

		local topLevel = UserManager:getInstance().user:getTopLevelId()
		if topLevel == levelId then
			UserService.getInstance():onLevelUpdate(1, levelId, 0)

			local levelType = LevelType:getLevelTypeByLevelId(levelId)
			
			Notify:dispatch("AchiEventCleanData")
			Notify:dispatch("AchiEventSetData", AchiDataType.kOldIsJumpLevel, false)
			Notify:dispatch("AchiEventSetData", AchiDataType.kForbidShare, true)
			Notify:dispatch("AchiEventPassLevel", levelId, levelType)
			if FLGOutboxPopoutAction then
				Notify:dispatch("AutoPopoutEventAwakenAction", FLGOutboxPopoutAction)
			end

		end

		local function onBoradCast(uid, levelId)
			local topLevel = UserManager:getInstance().user:getTopLevelId()
			if topLevel ~= levelId then return end

			local name = FriendManager.getInstance():getFriendName(uid)
			local info = Localization:getInstance():getText("askforhelp.boradcast.passedLevel.msg", {name=name or "", level=levelId})
			BroadcastManager:getInstance():showTip(info)
		end

		if dat._isCached then
			-- just broadcast this msg
			return onBoradCast(uid, levelId)
		end

		local LevelHelpedLogic = require "zoo.panelBusLogic.LevelHelpedLogic"
		local logic = LevelHelpedLogic:create(dat, GameLevelType.kMainLevel)
		logic:start()

		self:dispatchEvent(Event.new(AFHEvents.kAFHSuccessEvent))
		_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kAfterAFHSuccess, {}))
	end
	EmergencySystem:getInstance():addEventListener(kEmergencyEvents.kAFHSuccessEvent, onSuccessEvent)

	Notify:register("AchiUpgradeEvent", self.onAchiUpgrade, self)
end

function AskForHelpManager:onAchiUpgrade()
	if Achievement:getRightsExtra( "FriendLevelCount" ) > 0 and not self.hasAddFriendCount then
		self.helpData.leftAskNum = self.helpData.leftAskNum + Achievement:getRightsExtra( "FriendLevelCount" )
		self.hasAddFriendCount = true
	end
end

function AskForHelpManager:getConfig()
	return self.cfg
end

function AskForHelpManager:isEnabled( ... )
	if WXJPPackageUtil.getInstance():isWXJPPackage() then return false end
	if not self.isInited then return false end

	if _G.isLocalDevelopMode then
    	local scene = Director:sharedDirector():getRunningSceneLua()
    	-- 编辑器试玩
		if scene and EditorGamePlayScene and scene:is(EditorGamePlayScene) then
			return false
		end
	end
		
	local function switcherFunc()
		if not self.cfg.isEnabled then return false end
		return true
	end

	local function versionFunc()
		local vers = string.split(_G.bundleVersion, ".")
		if tonumber(vers[1]) <= 1 and tonumber(vers[2]) < self.cfg.minVersion then
			return false
		end
        return true
	end

	local function levelFunc()
		local level = UserManager.getInstance().user:getTopLevelId()
		return level >= self.cfg.minPlayerLevel
	end

	local function moneyFunc()
		if self.cfg.allUserEnable then return true end

		local userExtend = UserManager:getInstance().userExtend
		return not userExtend.payUser
	end

	local entryFunc = {}
	table.insert(entryFunc, switcherFunc)
	table.insert(entryFunc, versionFunc)
	table.insert(entryFunc, levelFunc)
	table.insert(entryFunc, moneyFunc)

	for _, func in ipairs(entryFunc) do
		if func() == false then return false end
	end
	return true
end

function AskForHelpManager:dailyQuota()
	return table.size(self.helpData.dailyAskedLevelIds or {}) > 0
end

function AskForHelpManager:askEnabled()
	if not self:isEnabled() then return false end
	if self.helpData.leftAskNum <= 0 then return false end
	return true
end

function AskForHelpManager:versionSupport()
	local vers = string.split(_G.bundleVersion, ".")
	if tonumber(vers[1]) <= 1 and tonumber(vers[2]) < self.cfg.minVersion then
		return false
	end
    return true
end

function AskForHelpManager:startPassDayCountDown()
	if not self.passDayTimer:started() then
		self.passDayTimer:startTimer()
	end

	local dayEnd = Localhost:getDayStartTimeByTS(Localhost:timeInSec()) + 86400 +2
	self.passDayTimer:addTimeEventCallback(dayEnd, function () self:onPassDay() end)
end

function AskForHelpManager:enterMode(doneeUId, isWxFriend)
	self.doneeUId = doneeUId
	self.isWxFriend = isWxFriend
end

function AskForHelpManager:leaveMode()
	self.doneeUId = nil
	self.isWxFriend = nil
end

function AskForHelpManager:isInMode()
	if self.doneeUId then return true end
	return false
end

function AskForHelpManager:getDoneeUId()
	return self.doneeUId
end

function AskForHelpManager:onPassDay()
	self:startPassDayCountDown()
	self.helpData:onPassDay()
end

function AskForHelpManager:onBroadcast(askData, sucData)
    local function onShowMsg(info)
        BroadcastManager:getInstance():showTip(info)
    end

	local asks = askData or {}
	for k,v in pairs(asks) do
        -- uid && levelId
		if v.first and v.second then
            local name = FriendManager.getInstance():getFriendName(v.first)
			local info = Localization:getInstance():getText("askforhelp.boradcast.askForHelp.msg", {name=name or "", levelId=v.second})
    		onShowMsg(info)
		end
	end

	local sucs = sucData or {}
    --uid && levelId
    if sucs.first and sucs.second then
        local name = FriendManager.getInstance():getFriendName(sucs.first)
		local info = Localization:getInstance():getText("askforhelp.boradcast.passedLevel.msg", {name=name or "", level=sucs.second})
    	onShowMsg(info)
	end
end

-- 更新闯关数据
function AskForHelpManager:onFailLevel(levelId)
	local idTopLevel = UserManager:getInstance().user:getTopLevelId()
	if idTopLevel ~= levelId then
		return
	end
	self.helpData:onFailLevel(levelId)
	self:flushToStorage()
end

function AskForHelpManager:onHelpOtherFinished(doneeUId, success)
	if success then
		self.helpData.dailyHelpOtherCount = self.helpData.dailyHelpOtherCount + 1
		self:flushToStorage()
	end
end

function AskForHelpManager:shouldShowFuncIcon(levelId)
	--[[RemoteDebug:uploadLog("shouldShowFuncIcon", self:isEnabled(), levelId, UserManager:getInstance().userExtend.topLevelFailCount, 
	self.helpData.mruLevelId, self.doneeUId, self.helpData.leftAskNum, table.tostring(self.helpData.dailyAskedLevelIds))--]]
	if not self:isEnabled() then return false end

	local function levelCheck()
		local topLevelId = UserManager:getInstance().user:getTopLevelId() or 0
		if levelId ~= topLevelId then return false end

		local failCount = UserManager:getInstance().userExtend.topLevelFailCount
		if self.helpData.mruLevelId > 0 and failCount >= self.cfg.failureThreshold then
			return true
		end
		return false
	end

	local function modeCheck()
		if self.doneeUId ~= nil then return false end
		if UserManager:getInstance():hasAskForHelpInfo(levelId) then return false end
		if UserManager:getInstance():hasPassedLevelEx(levelId) then return false end
		return true
	end

	local entryFunc = {}
	table.insert(entryFunc, levelCheck)
	table.insert(entryFunc, modeCheck)
	for _, func in ipairs(entryFunc) do
		if func() == false then return false end
	end
	return true
end

function AskForHelpManager:addAskedLevelId(val)
	local levelId = val or UserManager:getInstance().user:getTopLevelId()
	table.insertIfNotExist(self.helpData.dailyAskedLevelIds, levelId)
end

function AskForHelpManager:addRecentHelpOtherRecords(uid, levelId, success)
	if not uid or not levelId then return end
	local uid = tostring(uid) or ""
	for k,v in pairs(self.helpData.recentHelpOtherRecords) do
		if v.success == success and v.levelId == levelId and v.uid == uid then 
			return
		end
	end

	local v = HelpedInfoRef.new()
	v.success = success
	v.levelId = levelId
	v.uid = uid
	table.insert(self.helpData.recentHelpOtherRecords, v)
end

function AskForHelpManager:needPopout(levelId)
	if not self:shouldShowFuncIcon(levelId) then return false end
	if self.helpData.leftAskNum <= 0 then return false end
	if self.helpData.dailyPopoutQuato <= 0 then return false end
	if self.helpData:hasHelped() then return false end
	if table.indexOf(self.helpData.dailyPopoutLevels, levelId) then return false end
	if table.indexOf(self.helpData.dailyAskedLevelIds, levelId) then return false end

	--[[if UserManager:getInstance():getUserExtendRef():getNotConsumeEnergyBuff() > Localhost:time() then
		return false
	end
	local curEnergy = UserEnergyRecoverManager:sharedInstance():getEnergy() or 0
	if curEnergy >= 5 then return false end--]]
	local failCount = UserManager:getInstance().userExtend.topLevelFailCount or 0
	if failCount ~= self.cfg.popoutThreshold then
		return false
	end

	return true
end

function AskForHelpManager:descDailyPopoutQuta(levelId)
	table.insertIfNotExist(self.helpData.dailyPopoutLevels, levelId)
	self.helpData.dailyPopoutQuato = self.helpData.dailyPopoutQuato - 1
	self:flushToStorage()
end

function AskForHelpManager:errorTip(evt)
	local errcode = evt and evt.data or nil
	if errcode then
		local key = "askforhelp.error.tip." ..tostring(errcode)
		if key == Localization:getInstance():getText(key) then
			key = "error.tip."..tostring(errcode)
		end
		setTimeOut(function ( ... ) CommonTip:showTip(Localization:getInstance():getText(key), "negative") end, 0.001)
	end
end

function AskForHelpManager:pocessDecision(fromMessageCenter, subsUid, levelId, callback)
	local function handleDecisionFunc(ret)
		if type(callback) == "function" then
			callback(ret)
		end
	end

	local function onHelpDataLoaded()
		-- 各种检测

		local function onRequestSuccess(evt)
			-- 可以帮助
			handleDecisionFunc(true)
		end

		local function onRequestFail(evt)
			self:errorTip(evt)
			handleDecisionFunc(false, evt)
		end

		local function onRequestCancel()
			handleDecisionFunc(false)
		end

		local http = AskForHelpCheckConditionHttp.new(true)
    	http:ad(Events.kComplete, onRequestSuccess)
    	http:ad(Events.kError, onRequestFail)
    	http:ad(Events.kCancel, onRequestCancel)
		http:syncLoad({levelId=levelId, subsUid=subsUid})
	end

	local function onHelpDataLoadFail()
		handleDecisionFunc(false)
	end

	self:loadData(onHelpDataLoaded, onHelpDataLoadFail, true)
end

kFriendFrom = table.const {
	EUNKNOWN_SNS = 1, -- 无法初始化的snsFriends
	ENEARBY = 2,      -- 附近的人，摇一摇
	EINVITE_CODE = 3, -- 输消消乐号  邀请有礼回馈邀请人 friends中已经存在的非snsFriends好友
	EQR_CODE = 4,     -- 扫码
	EWDJ = 5,         -- wdj
	E360 = 6,         -- 360
	ELINK = 7,        -- 微信链接
	EPHONE = 8,       -- 手机通讯录
	EJPQQ = 9,        -- jpqq
	EQQ = 10,         -- qq
	EJPWX = 11,       -- 微信（精品包才可能有）
	EMI = 12,         -- 米聊
}

kAskForHelpSnsEnum = table.const {
	EXXL = 1,
	EPHONE = 2,
	EQQ = 3,
	EWX = 4,
}

kAskForHelpGuideEnum = table.const {
	EGUIDE_MAIL = 1,
	EGUIDE_FAILLEVEL = 2,
}

local Bits = class(DataRef) --用户相关扩展信息
function Bits:ctor(val)
	self.val = val or 0
end
function Bits:isFlagBitSet(bitIndex)
	if bitIndex < 1 then bitIndex = 1 end
	local mask = math.pow(2, bitIndex-1) -- e.g.: mask: 0010
	local bit = require("bit")
	return mask == bit.band(self.val, mask) -- e.g.:1111 & 0010 = 0010
end
function Bits:setFlagBit(bitIndex, setToTrue)
	self.val = self.val or 0
	if bitIndex < 1 then bitIndex = 1 end
	local mask = math.pow(2, bitIndex - 1) -- e.g.: maks: 0010
	local bit = require("bit")
	if setToTrue == true or setToTrue == 1 then 
		self.val = bit.bor(self.val, mask) -- e.g. 1100 | 0010 = 1110
	else
		if mask == bit.band(self.val, mask) then 
			self.val = self.val - mask -- e.g.: 1110 - 0010 = 1100
		end
	end
	return self.val
end
function Bits:value()
	return self.val
end

function AskForHelpManager:needGuidance(eType)
    if not self.helpData then return false end

	local bits = Bits.new(self.helpData.eGuide)
	return not bits:isFlagBitSet(eType)
end

function AskForHelpManager:setHasGuidanced(eType)
	local bits = Bits.new(self.helpData.eGuide)
	bits:setFlagBit(eType, true)
	self.helpData.eGuide = bits:value()
    self:flushToStorage()
end

-- 4:微信 -→ 3:qq -→ 2:手机通讯录 -→1:开心消消乐好友
function AskForHelpManager:getPlatformEnum(friendFrom)
	local bits = Bits.new(friendFrom)
	if bits:isFlagBitSet(kFriendFrom.ELINK) or bits:isFlagBitSet(kFriendFrom.EJPWX) then
		return kAskForHelpSnsEnum.EWX
	elseif bits:isFlagBitSet(kFriendFrom.EJPQQ) or bits:isFlagBitSet(kFriendFrom.EQQ) then
		return kAskForHelpSnsEnum.EQQ
	elseif bits:isFlagBitSet(kFriendFrom.EPHONE) then
		return kAskForHelpSnsEnum.EPHONE
	end
	return kAskForHelpSnsEnum.EXXL
end

function AskForHelpManager:getSnsEnum(uid)
	assert(uid, "should not a nil")
	if not uid then return kAskForHelpSnsEnum.EXXL end

	local friends = FriendManager.getInstance().friends or {}
	local profile = friends[tostring(uid)]
	if not profile then return kAskForHelpSnsEnum.EXXL end

	if not profile.friendSource then return kAskForHelpSnsEnum.EXXL end

	return self:getPlatformEnum(profile.friendSource)
end

-- 开始请求好友代打
function AskForHelpManager:onAskForHelp(levelId, panelforhide, forcePopout)

	local function onCheck()
		-- 总次数不足
		if self.helpData.leftAskNum <= 0 then
			local LevelNoQuota = require "zoo.panel.askForHelp.views.AFHLevelNoQuota"
			local panel = LevelNoQuota:create(nil, panelforhide)
			return false, panel:popout()
		end

		-- 今天已被成功代打
		if self.helpData:hasHelped() then
			 return false, CommonTip:showTip(localize('askforhelp.dailyAsked.quotaOver'), 'negative') 
		end
		return true
	end

	if not onCheck() then return end

	local function onLoadDataSuccess(evt)
		local data = evt.data or {}
		local candidates = data.friendIds or {}

		if not onCheck() then return end

		local maxLevel = MetaManager:getInstance():getMaxNormalLevelByLevelArea()
		local topLevel = UserManager:getInstance().user:getTopLevelId()
		local friends = FriendManager.getInstance().friends or {}
		local helpData = AskForHelpManager.getInstance():getHelpData()

		local function filter(uid)
			if helpData:hasAskedFriend(uid) then 
				return false
			end
			return true
		end

		local validFriends = {}	--好友的最高等级比自己高，且必须是自己闯过的
		for k,v in pairs(candidates) do
			local profile = friends[tostring(v)]
			if profile then
				local tlevel = profile.topLevelId or 0
				if (tlevel >= topLevel or tlevel == maxLevel) and filter(v) then
					local val = {}
					val.topLevelId = tlevel
					val.friendSource = self:getPlatformEnum(profile.friendSource or 0)
					val.updateTime = profile.updateTime
					val.uid = v
					table.insert(validFriends, val)
				end
			end
		end

		if forcePopout == true then
			self:descDailyPopoutQuta(levelId)
		end

		local function onFinished()
		end

		if table.size(validFriends) > 0 then
			-- 显示好友选择面板
			local FriendsSelector = require "zoo.panel.askForHelp.views.FriendsSelector"
			local panel = FriendsSelector:create(validFriends, topLevel, onFinished, panelforhide)
			panel:popout()
		else
			-- 好友不足
			local panel = nil
			if self.cfg:shareDisabled() then
				local AFHFromAddFriends = require 'zoo.panel.askForHelp.views.AFHFromAddFriends'
				panel = AFHFromAddFriends:create(onFinished)
			else
				local AFHFromWeixin = require 'zoo.panel.askForHelp.views.AFHFromWeixin'
				panel = AFHFromWeixin:create(onFinished)
			end
			-- 提示加好友
			panel:popout()
		end
	end
	
	if forcePopout == true then
		self:getHelpDataFromServer(onLoadDataSuccess, nil, false, levelId)
	else
		PaymentNetworkCheck.getInstance():check(function ()
			self:getHelpDataFromServer(onLoadDataSuccess, nil, false, levelId)
		end, function ()
			CommonTip:showTip(localize("forcepop.tip3"))
		end)
	end
end

function AskForHelpManager:onHelpless( onPropInfoPanelClosed )
	local function dummy() end

	if self.cfg:shareDisabled() then
		local AFHFromAddFriends = require 'zoo.panel.askForHelp.views.AFHFromAddFriends'
		panel = AFHFromAddFriends:create(dummy)
	else
		local AFHFromWeixin = require 'zoo.panel.askForHelp.views.AFHFromWeixin'
		panel = AFHFromWeixin:create(dummy)
	end
	-- 提示加好友
	panel:popout()
	local function removeOnceComplete()
		if onPropInfoPanelClosed then
			onPropInfoPanelClosed()
		end
	end
	panel:addEventListener(PopoutEvents.kRemoveOnce, removeOnceComplete)

end

function AskForHelpManager:onPassLevel(levelId)
	local levelId = levelId or 1
	if UserManager:getInstance():hasAskForHelpInfo(levelId) then
		UserManager:getInstance():removeAskForHelpInfo(levelId)
		self.helpData.leftAskNum = self.helpData.leftAskNum + 1
		self:flushToStorage()
	end
end

function AskForHelpManager:shareDisabled()
	return self.cfg:shareDisabled()
end

function AskForHelpManager:incHelpedSuccessCount()
	self.helpData.totalHelpOtherCount = self.helpData.totalHelpOtherCount + 1
end

function AskForHelpManager:getHeadFrameDur()
	return self.cfg.headFrameValidDays * 3600 * 24
end

function AskForHelpManager:hasNewHeadFrame()
	if self.helpData.totalHelpOtherCount < self.cfg.headFrameThreshold then return false end
	if (self.helpData.totalHelpOtherCount % self.cfg.headFrameThreshold) == 0 then
		return true
	end
	return false
end

function AskForHelpManager:getTotalHelpOtherCount()
	return self.helpData and self.helpData.totalHelpOtherCount or 0
end

function AskForHelpManager:getTotalBeHelpedCount()
	return UserManager:getInstance().subsTotalBeHelpedCount or 0
end

function AskForHelpManager:getHelpData()
	return self.helpData
end

function AskForHelpManager:getHelpDataFromLocal()
	local helpData = self:readFromStorage()
	if not helpData then
		helpData = AskForHelpData.new()
	end
	return helpData
end

function AskForHelpManager:loadData(onFinish, onFail, withAnim)
	self:getHelpDataFromServer(onFinish, onFail, not withAnim)
end

function AskForHelpManager:readFromStorage()
	local data = Localhost.getInstance():readAskForHelpData()
	if data then
		return AskForHelpData:fromRespData(data)
	end
	return nil
end

function AskForHelpManager:flushToStorage()
	if self.helpData then
		self.helpData:flushToStorage()
	end
end

function AskForHelpManager:getHelpDataFromServer(onSuccess, onFail, inBackground, levelId)
	if not levelId then
		local levelId = UserManager.getInstance().user:getTopLevelId()
		if not self:isEnabled() or self.helpData:hasCached(levelId) then
			if onSuccess then onSuccess() end
			return
		end
	end

	local function onRequestSuccess(evt)
		self.helpData = AskForHelpData:synWithServer(self.helpData, evt.data, levelId)
		self:flushToStorage()
		if onSuccess then onSuccess(evt) end
	end

	local function onRequestFail(evt)
		if onFail then onFail(evt) end
	end

	local function onRequestCancel()
		if onFail then onFail() end
	end

	local http = AskForHelpGetInfoHttp.new(true)
    http:ad(Events.kComplete, onRequestSuccess)
    http:ad(Events.kError, onRequestFail)
    http:ad(Events.kCancel, onRequestCancel)
	http:syncLoad({levelId=levelId})
end

function AskForHelpManager:hasNewMessageFlag()
	local uid = UserManager:getInstance():getUID()
	return CCUserDefault:sharedUserDefault():getBoolForKey("askforhelp.hasNewMessage" ..uid, false) 
end

function AskForHelpManager:setNewMessageFlag(isHave)
	local uid = UserManager:getInstance():getUID()
	return CCUserDefault:sharedUserDefault():setBoolForKey("askforhelp.hasNewMessage" ..uid, isHave) 
end

