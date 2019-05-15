local MauNumberOnePanel = class(BasePanel)

function MauNumberOnePanel:ctor()
end

function MauNumberOnePanel:init(closeCallback)
	self.ui = self:buildInterfaceGroup('mau_number_one/mainPanel')
    BasePanel.init(self, self.ui)
    self.closeCallback = closeCallback

    self.iconPh = self.ui:getChildByName("iconPh")
    self.iconPh:setVisible(false)

    self.closeBtn = self.ui:getChildByName('closeBtn')	
	self.closeBtn:setTouchEnabled(true, 0, false)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onCloseBtnTap()
	end)
	self.closeBtn:setVisible(false)

    self.shareBtn = GroupButtonBase:create(self.ui:getChildByName("shareBtn"))
    self.shareBtn:setString(localize("分享"))
    self.shareBtn:ad(DisplayEvents.kTouchTap, function ()
    	self:onShareBtnTap()
    end)
	self.shareBtn:useBubbleAnimation()
    self.shareBtn:setVisible(false)

    self.delayBtn = GroupButtonBase:create(self.ui:getChildByName("delayBtn"))
    self.delayBtn:setColorMode(kGroupButtonColorMode.orange)
    self.delayBtn:setString(localize("暂不领取"))
    self.delayBtn:ad(DisplayEvents.kTouchTap, function ()
    	self:onCloseBtnTap()
    end)

    self.receiveBtn = GroupButtonBase:create(self.ui:getChildByName("receiveBtn"))
    self.receiveBtn:setString(localize("领取奖励"))
    self.receiveBtn:ad(DisplayEvents.kTouchTap, function ()
    	self:onReceiveBtnTap()
    end)
	self.receiveBtn:useBubbleAnimation()
end

function MauNumberOnePanel:onCloseBtnTap()
	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false
	if self.closeCallback then self.closeCallback() end
end

function MauNumberOnePanel:onShareBtnTap()
	DcUtil:activity({category='energy', sub_category='push_share_button'})
	self.shareBtn:setEnabled(false)
	local function onShareSuccess()
		self:onCloseBtnTap()
	end

	local function onShareFail()
		self.shareBtn:setEnabled(true)
	end

	local function onShareCancel()
		self.shareBtn:setEnabled(true)
	end
	MauNumberOneManager.getInstance():shareLink(onShareSuccess, onShareFail, onShareCancel)
end

function MauNumberOnePanel:onReceiveBtnTap()
	DcUtil:activity({category='energy', sub_category='push_reward_button'})
	self.allowBackKeyTap = false
	self.delayBtn:setEnabled(false)
	self.receiveBtn:setEnabled(false)
	local rewards = MauNumberOneManager.getInstance():getRewards()

	local function onFlyFinish()
		if self.isDisposed then return end
		local shareType = SnsUtil.getShareType()
		if shareType == PlatformShareEnum.kMiTalk then
			self:onCloseBtnTap()
		else
			self.allowBackKeyTap = true
			self.delayBtn:setVisible(false)
			self.receiveBtn:setVisible(false)
			self.closeBtn:setVisible(true)
			self.shareBtn:setVisible(true)
		end
	end

	local function onUseSuccess()
		if self.isDisposed then return end
		local bounds = self.iconPh:getGroupBounds()
		local anim = FlyItemsAnimation:create(rewards)
		-- anim:setScale(1.5)
		anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
		anim:setFinishCallback(onFlyFinish)
		anim:play()			
	end

	local function onAddSuccess()
		if self.isDisposed then return end
		MauNumberOneManager.getInstance():useInfiniteEnergy(rewards, onUseSuccess)
		MauNumberOneManager.getInstance():removeIconBtn()
	end

	local function onAddFail(errCode)
		if self.isDisposed then return end
		if errCode == 731927 then 		--错误码活动过期
			CommonTip:showTip(localize("活动已过期~"), "negative")
			self:closeWithIconBtnRemove()
			return
		elseif errCode == 731032 then 	--错误码已领过
		 	CommonTip:showTip(localize("不能重复领取~"), "negative")
		 	self:closeWithIconBtnRemove()
		 	return
		end

		CommonTip:showTip(localize("领取失败~"), "negative")
		self.allowBackKeyTap = true
		self.delayBtn:setEnabled(true)
		self.receiveBtn:setEnabled(true)
	end
	
	if rewards then 
		MauNumberOneManager.getInstance():addInfiniteEnergy(rewards, onAddSuccess, onAddFail)
	else
		if _G.isLocalDevelopMode then assert(false, "MauNumberOnePanel:onReceiveBtnTap()---rewards is not exist") end
		CommonTip:showTip(localize("活动数据错误~"), "negative")
		self:closeWithIconBtnRemove()
	end
end

function MauNumberOnePanel:closeWithIconBtnRemove()
	self:onCloseBtnTap()
	MauNumberOneManager.getInstance():removeIconBtn()
end

function MauNumberOnePanel:popout()
	self.allowBackKeyTap = true
	PopoutQueue:sharedInstance():push(self, true, false)
end

function MauNumberOnePanel:popoutShowTransition()
	MauNumberOneManager.getInstance():updateLastPoptime()

	local uisize = self.ui:getGroupBounds().size
	local director = Director:sharedDirector()
    local origin = director:getVisibleOrigin()
    local size = director:getVisibleSize()
    local hr = size.height / uisize.height
    local wr = size.width / uisize.width
    if hr < 1 then
    	self:setScale((hr < wr) and hr or wr)
    end

    local centerPosX = self:getHCenterInParentX()
    local centerPosY = self:getVCenterInParentY()
        
    self:setPosition(ccp(centerPosX, centerPosY))
end

function MauNumberOnePanel:create(closeCallback)
	local panel = MauNumberOnePanel.new()
	panel:loadRequiredResource("tempFunctionRes/mauNumberOne/panel.json")
	panel:init(closeCallback)
	return panel
end

return MauNumberOnePanel