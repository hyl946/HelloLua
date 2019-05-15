-- local CompBindSNS = require "zoo.panel.areaUnlock.CompBindSNS"
local CompFriendHelp
if __ANDROID then
	CompFriendHelp = require "zoo.panel.areaUnlock.CompFriendHelp"
elseif __IOS or __WIN32 then
	CompFriendHelp = require "zoo.panel.areaUnlock.IosCompFriendHelp"
end
local CompPay = require "zoo.panel.areaUnlock.CompPay"
local CompStarNum = require "zoo.panel.areaUnlock.CompStarNum"
local CompTime = require "zoo.panel.areaUnlock.CompTime"

AreaUnlockPanel = class(BasePanel)
local PanelType = {WITH_SNS_BIND = 1, NO_SNS_BIND = 2}

local LOCAL_DATA_FILE = "areaUnlock"
AreaUnlockPanel.LOCAL_DATA_FILE = LOCAL_DATA_FILE

function AreaUnlockPanel:create(lockedCloudId, totalStar, neededStar, unlockCloudSucessCallBack, closeBtnCallback, closeCallback)
	local function popoutPanel(decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable)
		local panel = AreaUnlockPanel.new()
		if __ANDROID or __WIN32 then
			panel:initPaymentData(decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable)
		end
		panel:init(lockedCloudId, totalStar, neededStar, unlockCloudSucessCallBack, closeBtnCallback, closeCallback)
		panel:popout()
	end
	
	if __ANDROID  or __WIN32 then 
    	local goodMeta	= MetaManager.getInstance():getGoodMetaByItemID(lockedCloudId)
        PaymentManager.getInstance():getBuyItemDecision(popoutPanel, goodMeta.id)
    else
        popoutPanel()
    end
end

function AreaUnlockPanel:initPaymentData(decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable)
    self.adDecision = decision
    self.adPaymentType = paymentType
    self.dcAndroidStatus = dcAndroidStatus
    self.adRepayChooseTable = repayChooseTable
    if __ANDROID or __WIN32 then 
        if self.adDecision ~= IngamePaymentDecisionType.kPayWithWindMill then
        	self.androidRmbBuy = true
        end
    end
end

function AreaUnlockPanel:init(lockedCloudId, totalStar, neededStar, unlockCloudSucessCallBack, closeBtnCallback, closeCallback)

	-- local hasSnsComp = self:hasSnsComp(lockedCloudId)
    self.closeBtnCallback = closeBtnCallback
    self.closeCallback = closeCallback
	self:loadRequiredResource(PanelConfigFiles.unlock_cloud_panel_new)
	-- if hasSnsComp then
		-- self.ui = self:buildInterfaceGroup('area_unlock/panelWithSns')
	-- else
		self.ui = self:buildInterfaceGroup('area_unlock/panelNoSns')
	-- end

	self.BTN_TAPPED_STATE_CLOSE_BTN_TAPPED = 1
	self.BTN_TAPPED_STATE_ASK_FRIEND_BTN_TAPPED	= 2
	self.BTN_TAPPED_STATE_NONE = 3
	self.btnTappedState = self.BTN_TAPPED_STATE_NONE

	BasePanel.init(self, self.ui)
	self.lockedCloudId = lockedCloudId

	local function success()
		GameGuide:sharedInstance():forceStopGuide()
		GameGuide:sharedInstance():tryStartGuide()
		if unlockCloudSucessCallBack then unlockCloudSucessCallBack() end
	end

	self.unlockCloudSucessCallBack = success
	self.closeBtn = self.ui:getChildByName("closeBtn")
	self.closeBtn:setTouchEnabled(true, 0, true)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function() 
		if not self.closeBtn.inClk then
			self.closeBtn.inClk = true
			self:onCloseBtnTapped()
		end
	end)
	self.ui:getChildByName("otherWayLabel"):setString(localize("unlock.cloud.desc2"))
	-- if self:hasSnsComp() then
		-- self.compBindSNS = CompBindSNS:create(self, self.ui:getChildByName("bindSNS"))
	-- end
	self.compFriendHelp = CompFriendHelp:create(self, self.ui:getChildByName("friendHelp"))
	self.compStarNum = CompStarNum:create(self, self.ui:getChildByName("starNum"), totalStar, neededStar)
	self.compPay = CompPay:create(self, self.ui:getChildByName("compPay"), self.androidRmbBuy)
	self.compTime = CompTime:create(self, self.ui:getChildByName("timeUI"))
end

-- function AreaUnlockPanel:hasSnsComp()
-- 	if WXJPPackageUtil.getInstance():isWXJPPackage() then return false end

-- 	local has360Auth = PlatformConfig:hasAuthConfig(PlatformAuthEnum.k360)
-- 	local hasBind360 = UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.k360) ~= nil
-- 	if has360Auth then
-- 		return not hasBind360
-- 	else
-- 		local hasPhoneAuth = PlatformConfig:hasAuthConfig(PlatformAuthEnum.kPhone)
-- 		local hasBindPhone = UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.kPhone) ~= nil
-- 		local hasWechatAuth = PlatformConfig:hasAuthConfig(PlatformAuthEnum.kWechat, true)
-- 		local hasBindWechat = UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.kWechat) ~= nil

-- 		return (hasPhoneAuth and not hasBindPhone) or (hasWechatAuth and not hasBindWechat)
-- 	end
	
-- 	return false
-- end

function AreaUnlockPanel:tryRemoveGuide()
	if self.ui and self.ui.isDisposed then return end
	if self.armature and not self.armature.isDisposed then
		self.armature:removeFromParentAndCleanup(true)
		self.armature = nil
	end
end

function AreaUnlockPanel:popout()
	self.allowBackKeyTap = true
	PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
	self:setToScreenCenterVertical()
	self:setToScreenCenterHorizontal()
	RealNameManager:addConsumptionLabelToPanel(self, true)
	-- self:tryShowGuide()
end

function AreaUnlockPanel:tryShowGuide()
	local hasFirstPopout = CCUserDefault:sharedUserDefault():getBoolForKey('panel.unlockCloud.hasRunGuide') and not __WIN32
	if hasFirstPopout then
		return
	end
	local armature = CommonSkeletonAnimation:createTutorialMoveIn2()
	local function animationCallback()
		if self.isDisposed then return end
		self:tryRemoveGuide()
	end
	armature:removeAllEventListeners()
	armature:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
	local askFriend = (FriendManager.getInstance():getFriendCount() >= 3)
	local scene = Director:sharedDirector():getRunningScene()
	if not scene then return end
	scene:addChild(armature, SceneLayerShowKey.POP_OUT_LAYER)
	self.armature = armature
	if askFriend then
		local pos = self.compFriendHelp:getGuideBtnPos()
		armature:setPosition(pos)
	else
		local pos = ccp(573, 587)
		armature:setPosition(pos)
	end
	CCUserDefault:sharedUserDefault():setBoolForKey('panel.unlockCloud.hasRunGuide', true)
end

function AreaUnlockPanel:remove(animFinishCallback)
	if not self.isDisposed then 
		PopoutManager:sharedInstance():removeWithBgFadeOut(self, animFinishCallback, true)
		self:tryRemoveGuide()
	end
	if self.closeCallback then
		self.closeCallback()
	end
end

function AreaUnlockPanel:onCloseBtnTapped()

	if self.btnTappedState == self.BTN_TAPPED_STATE_NONE then
		self.btnTappedState = self.BTN_TAPPED_STATE_CLOSE_BTN_TAPPED
	else
		return
	end

	self:remove(false)
	if self.closeCallback then
		self.closeCallback(self.isUnlockSuccess, self.friendIdsSent)
	end

	if self.compFriendHelp and self.compFriendHelp.askFriendUnlockSuccess then
		self.compFriendHelp.askFriendUnlockSuccess = false
		NotificationGuideManager.getInstance():popoutIfNecessary(NotiGuideTriggerType.kFriendUnlock)
	end

	if __WIN32 then
		-- self.unlockCloudSucessCallBack()
	end
	-- PopoutQueue:sharedInstance():popAllInPopoutQueue()
end

function AreaUnlockPanel:toTimeUnlockState()
	if not self.inTimeUnlockState then
		if self.compPay ~= nil then self.compPay:hide() end
	end
end

function AreaUnlockPanel:dispose()
	self.compTime:stopTimer()
	BasePanel.dispose(self)
end

function AreaUnlockPanel:onEnterForeGround()
	if self.ui == nil or self.ui.isDisposed then return end
	self:runAction(CCCallFunc:create(function()
		self.compTime:updateTimeUnlock()
	end))
end