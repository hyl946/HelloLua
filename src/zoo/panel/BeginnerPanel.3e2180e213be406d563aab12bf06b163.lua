require "zoo.panel.basePanel.BasePanel"
require "zoo.net.OnlineGetterHttp"
require "zoo.baseUI.ButtonWithShadow"

BeginnerPanel = class(BasePanel)

function BeginnerPanel:create()
	local panel = BeginnerPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.BeginnerPanel)
	if panel:init() then
		return panel
	else
		panel = nil
		return nil
	end
end

function BeginnerPanel:isBaiduPlatform()
	if PlatformConfig:isBaiduPlatform() then
		return true
	end
	return false
end

function BeginnerPanel:init()
	self.rewardList = MetaManager.getInstance():getNewUserRewards()
	self.panelLuaName = "BeginnerPanel"
	if _G.isLocalDevelopMode then printx(0, table.tostring(self.rewardList)) end

	if WorldSceneShowManager:isRightGameVersion() then 
		self.ui = self:buildInterfaceGroup('spring_2017/BeginnerPanel2')
	else
		local gameVersion = string.split(_G.bundleVersion, '.')
		if gameVersion and gameVersion[2] and gameVersion[2] == '36' then 
			self.ui = self:buildInterfaceGroup('BeginnerPanelOlympic')
		else
			self.ui = self:buildInterfaceGroup('BeginnerPanel')
		end
	end

	BasePanel.init(self, self.ui)
	self.panelName = "beginnerPanel"
	self:setPositionForPopoutManager()

	self.bg = self.ui:getChildByName("_bg")
	self.captain = self.ui:getChildByName("captain")
	self.cmtText = self.ui:getChildByName("cmtText")
	--self.avlText = self.ui:getChildByName("avlText")
	self.btnGet = self.ui:getChildByName("btnGet")
	-- assert(self.captain)

	if WorldSceneShowManager:isRightGameVersion() then 
		self.captain:setVisible(false)
	end

	self.items = {}
	for i = 1, 4 do
		self.items[i] = self.ui:getChildByName("item"..i)
	end
	self.btnGet = GroupButtonBase:create(self.btnGet)

	if PlatformConfig:isPlatform(PlatformNameEnum.kCMGame) and DcUtil.getSubPlatform and DcUtil.getSubPlatform() == "he201507211442349840" then --江西移动活动
		self.captain:setText(Localization:getInstance():getText("beginner.panel.title"))
		self.cmtText:setString(Localization:getInstance():getText("enter.invite.code.panel.des.jxyd"))
	elseif self:isBaiduPlatform() then
		self.captain:setText(Localization:getInstance():getText("beginner.panel.title.baidu"))
		self.cmtText:setString(Localization:getInstance():getText("beginner.panel.cmt.text.baidu"))
	elseif PlatformConfig:isQQPlatform() then
		self.captain:setText(Localization:getInstance():getText("activity.gift.center.panel.title"))
		self.cmtText:setString(Localization:getInstance():getText("beginner.panel.cmt.text"))
	elseif __IOS and WorldSceneShowManager:isRightGameVersion() then 
		self.cmtText:setString(Localization:getInstance():getText("beginner.panel.cmt.text.apple"))
	else
		self.captain:setText(Localization:getInstance():getText("beginner.panel.title"))
		self.cmtText:setString(Localization:getInstance():getText("beginner.panel.cmt.text"))
	end
	local capSize = self.captain:getContentSize()
	local capScale = 65 / capSize.height
	self.captain:setScale(capScale)
	local bgSize = self.bg:getGroupBounds().size
	self.captain:setPositionX((bgSize.width - capSize.width * capScale) / 2 + self.bg:getPositionX())

	--self.avlText:setString(Localization:getInstance():getText("beginner.panel.avl.time"))
	self.btnGet:setString(Localization:getInstance():getText("beginner.panel.btn.get.text"))
	for i = 1, 4 do
		local sprite
		if self.rewardList[i].itemId == ItemType.COIN then
			sprite = Sprite:createWithSpriteFrameName("iconHeap_4uy30000")
			sprite:setAnchorPoint(ccp(0, 1))
		else
			sprite = ResourceManager:sharedInstance():buildItemGroup(self.rewardList[i].itemId)
		end
		local icon = self.items[i]:getChildByName("icon")
		local num = self.items[i]:getChildByName("num")

		local numFS = self.items[i]:getChildByName("num_fontSize")
		local label = TextField:createWithUIAdjustment(numFS, num)
		self.items[i]:addChild(label)
		local pos = icon:getPosition()
		sprite:setPosition(ccp(pos.x, pos.y))
		icon:getParent():addChildAt(sprite, icon:getZOrder())
		icon:removeFromParentAndCleanup(true)
		label:setString("x"..self.rewardList[i].num)
	end

	local function onGetTouched()
		self:getPresents()
	end
	self.btnGet:ad(DisplayEvents.kTouchTap, onGetTouched)

	return true
end

function BeginnerPanel:getPresents()
	self.btnGet:setEnabled(false)
	local context = self 

	local function onGetRewardComplete(evt)
		UserManager:getInstance().userExtend:setNewUserReward(2)
		UserService:getInstance().userExtend:setNewUserReward(2)
        Localhost:flushCurrentUserData()
		local rewards = evt.data
		if rewards and #rewards > 0 then
			self:openPackage()
			if self.getCallback then
				self.getCallback()
			end
		else
			PopoutManager:sharedInstance():remove(context, true)
		end
	end

	local function onGetRewardError(err)
		PopoutManager:sharedInstance():remove(context, true)
	end

	if UserManager:getInstance().userExtend:getNewUserReward() == 2 then
		local topLevel = tostring(UserManager.getInstance():getUserRef():getTopLevelId() or -1)
		local uid = getSafeUid()
		he_log_error(string.format("BeginnerPanel getPresents:%s==%s", topLevel, uid))
		onGetRewardError()
		return
	end

	local http = GetNewUserRewardsHttp.new()
	http:addEventListener(Events.kComplete, onGetRewardComplete)
	http:addEventListener(Events.kError, onGetRewardComplete)
	http:load(2)
--	SyncManager:getInstance():syncLite()
end

function BeginnerPanel:openPackage()
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	local home = HomeScene:sharedInstance()
	local width, spare = 60, 30
	local fullWidth = 5 * width + 4 * spare
	local startX = (vSize.width - fullWidth) / 2
	local function onOver()
		-- show tip for beginner
		local scene = HomeScene:sharedInstance()
		--scene.energyButton:showTip()
		scene:updateCoin()
	end

	for i,v in ipairs(self.rewardList) do
		local anim = FlyItemsAnimation:create({v})
		anim:setWorldPosition(ccp(startX + (i - 1) * (width + spare) + vOrigin.x, vSize.height / 2 + vOrigin.y))
		if v.itemId == ItemType.COIN then
			anim:setFinishCallback(onOver)
		end
		anim:play()
	end

	PopoutManager:sharedInstance():remove(self, true)

	if self.close_cb then self.close_cb() end
end

function BeginnerPanel:setGetCallback(callback)
	self.getCallback = callback
end

function BeginnerPanel:popout(close_cb)
	self.close_cb = close_cb
	PopoutQueue:sharedInstance():push(self)
end

function BeginnerPanel:getHCenterInScreenX(...)
	assert(#{...} == 0)

	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfWidth		= 718

	local deltaWidth	= visibleSize.width - selfWidth
	local halfDeltaWidth	= deltaWidth / 2

	return visibleOrigin.x + halfDeltaWidth
end