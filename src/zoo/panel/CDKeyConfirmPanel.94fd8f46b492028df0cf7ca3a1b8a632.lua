require 'zoo.panel.basePanel.BasePanel'



---------------------------------------------------
---------------------------------------------------
-------------- CDKeyRewardRender
---------------------------------------------------
---------------------------------------------------
assert(not CDKeyRewardRender)
assert(BaseUI)
CDKeyRewardRender = class(BaseUI)

function CDKeyRewardRender:create(ui,reward)
	assert(ui)

	local panel = CDKeyRewardRender.new()
	panel.reward = reward
	panel:init(ui)
	return panel
end

function CDKeyRewardRender:init(ui)
	------------------
	-- Init Base Class
	-- ---------------
	BaseUI.init(self, ui)

	self:initData()

	self:initUI()
end

function CDKeyRewardRender:initData()

end

function CDKeyRewardRender:initUI()
	self.txtCount = TextField:createWithUIAdjustment(self.ui:getChildByName("txtCountFontSize"), self.ui:getChildByName("txtCount"))
	self.txtCount:removeFromParentAndCleanup(false)
	self.ui:addChild(self.txtCount)

	local num = self.reward.num
	if tonumber(num) > 9999 then
		coinString = math.floor(num / 10000) .. "万"
	else
		coinString = tostring(num)
	end

	self.txtCount:setString("x"..coinString)

	local prop = ResourceManager:sharedInstance():buildItemSprite(self.reward.itemId)
	prop:setVisible(true)
	prop:setScale(1.2)
	local w = prop:getContentSize().width * 1.2
	local h = prop:getContentSize().height * 1.2
	local holder = self.ui:getChildByName("mcHolder")
	holder:removeChildren(false)
	-- if _G.isLocalDevelopMode then printx(0, prop:getContentSize().width,prop:getContentSize().height,"content size") end
	prop:setPosition( ccp(-w/2,h/2))
	holder:addChild(prop)

	-- self.reward.itemId = 10092
	
	if ItemType:isTimeProp(self.reward.itemId)  then
        local time_prop_flag = ResourceManager:sharedInstance():createTimeLimitFlag(self.reward.itemId , true)
        holder:addChild(time_prop_flag)
        time_prop_flag:setAnchorPoint(ccp(0.5,0.5))
        local size = prop:getContentSize()
        time_prop_flag:setPosition( ccp( 0  , -35 ) )
    end

end



---------------------------------------------------
---------------------------------------------------
-------------- CDKeyRewardsLayer 
---------------------------------------------------
---------------------------------------------------
assert(not CDKeyRewardsLayer)
assert(BaseUI)
CDKeyRewardsLayer = class(BaseUI)

function CDKeyRewardsLayer:create(ui,rewards)
	assert(ui)
	-- assert(type(itemId) == "number")
	-- assert(type(itemNumber) == "number")
	-- assert(#{...} == 0)

	local panel = CDKeyRewardsLayer.new()
	panel.rewards = rewards
	panel:init(ui)
	return panel
end

function CDKeyRewardsLayer:init(ui)
	------------------
	-- Init Base Class
	-- ---------------
	BaseUI.init(self, ui)

	self:initData()

	self:initUI()
end

function CDKeyRewardsLayer:initData()
end


function CDKeyRewardsLayer:initUI()
	for i=1,8 do
		self["icon"..tostring(i)] = self.ui:getChildByName("icon"..tostring(i))
		self["icon"..tostring(i)]:setVisible(false)
	end

	self:initRewards()
end

function CDKeyRewardsLayer:initRewards()
	self.rewardsArray = {}
	local rewardsLen = #table.keys(self.rewards)
	assert(rewardsLen > 0, "no rewards config for exchange code!!!")
	for i = 1,rewardsLen do
		local v = self.rewards[i]
		local itemId 		= v.itemId
		local itemNumber	= v.num
		-- table.insert(rewardIds, itemId)
		-- table.insert(rewardAmounts, itemNumber)
		if _G.isLocalDevelopMode then printx(0, "====== reward ==== ",itemId,itemNumber) end
		table.insert(self.rewardsArray,v)
	end

	self.visibleLayer = self["icon"..tostring(rewardsLen)]
	self.visibleLayer:setVisible(true)
	local numChild = self.visibleLayer:getNumOfChildren()
	-- if _G.isLocalDevelopMode then printx(0, "child num",numChild) end

	for i=1,rewardsLen do
		local child = self.visibleLayer:getChildByName("icon" .. i)
		if (child) then
			local render = CDKeyRewardRender:create(child,self.rewardsArray[i])
		end
	end
end




---------------------------------------------------
---------------------------------------------------
-------------- CDKeyConfirmPanel 
---------------------------------------------------
---------------------------------------------------

CDKeyConfirmPanel = class(BasePanel)

function CDKeyConfirmPanel:create(data,callback)
	local panel = CDKeyConfirmPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.cd_key_confirm_panel)
	panel.data = data
	panel.rewards = data.data.rewardItems
	panel.onCloseCallback = callback
	-- if _G.isLocalDevelopMode then printx(0, panel.rewards,panel.onCloseCallback,"ffffffffffffff") end
	panel:init()
	return panel
end

function CDKeyConfirmPanel:unloadRequiredResource()
end

function CDKeyConfirmPanel:init()
	self:initData()

	self:initUI()
end

function CDKeyConfirmPanel:initData()
	-- 只保留前8个
	-- if (#table.keys(self.data)>8) then
	-- 	local tempd = {}
	-- 	local i = 0
	-- 	for k,v in pairs(self.data) do
	-- 		if ( i < 8) then
	-- 			tempd[k] = v
	-- 			i = i + 1
	-- 		end
	-- 	end

	-- 	self.data = tempd
	-- end

	if (#table.keys(self.rewards)>8) then
		local temp = {}
		local i = 0
		for k,v in pairs(self.rewards) do
			if ( i < 8) then
				temp[k] = v
				i = i + 1
			end
		end

		self.rewards = temp
	end

end

function CDKeyConfirmPanel:initUI()
	self.ui = self:buildInterfaceGroup("CDKeyConfirmPanel")

	BasePanel.init(self, self.ui)

	local function onCloseTap( ... )
		self:onCloseBtnTapped()
	end
	
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	local wSize = CCDirector:sharedDirector():getWinSize()
	local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	local size = self:getGroupBounds().size
	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()

	self.btnClose = self:createTouchButtonBySprite(self.ui:getChildByName("btnClose"), onCloseTap)
	
	-- line1
	self.mcFront = self.ui:getChildByName("mcFront")
	self.mcBack = self.ui:getChildByName("mcBack")
	self.btnGet = GroupButtonBase:create(self.ui:getChildByName("btnGet"))	
	self.btnGet:setColorMode(kGroupButtonColorMode.green)
	self.btnGet:setString(Localization:getInstance():getText('get_cdkey_button'))
	self.btnGet:addEventListener(DisplayEvents.kTouchTap, handler(self,self.onBtnGetTap))
	-- line2
	self.mcFront2 = self.ui:getChildByName("mcFront2")
	self.mcBack2 = self.ui:getChildByName("mcBack2")
	self.btnGet2 = GroupButtonBase:create(self.ui:getChildByName("btnGet2"))	
	self.btnGet2:setColorMode(kGroupButtonColorMode.green)
	self.btnGet2:setString(Localization:getInstance():getText('get_cdkey_button'))
	self.btnGet2:addEventListener(DisplayEvents.kTouchTap, handler(self,self.onBtnGetTap))

	self.rewardLayer = CDKeyRewardsLayer:create(self.ui:getChildByName("mcIconsLayer"),self.rewards)
	local l = #table.keys(self.rewards)
	if ( l > 0 and l < 5) then
		self.line = 1
	elseif ( l >=4 and l < 9) then
		self.line = 2
	else
		if _G.isLocalDevelopMode then printx(0, "Unsupport Len",l) end
	end

	if (self.line == 1) then
		self.mcFront:setVisible(true)
		self.mcBack:setVisible(true)
		self.btnGet:setVisible(true)
		self.mcFront2:setVisible(false)
		self.mcBack2:setVisible(false)
		self.btnGet2:setVisible(false)
	elseif (self.line == 2) then
		self.mcFront:setVisible(false)
		self.mcBack:setVisible(false)
		self.btnGet:setVisible(false)
		self.mcFront2:setVisible(true)
		self.mcBack2:setVisible(true)
		self.btnGet2:setVisible(true)
	else
		if _G.isLocalDevelopMode then printx(0, "unsupport line ",self.line) end
	end
end

function CDKeyConfirmPanel:onBtnGetTap()
	if _G.isLocalDevelopMode then printx(0, "============== get =================") end
	self:onCloseBtnTapped()
end


function CDKeyConfirmPanel:popout()
	self.allowBackKeyTap = true
	PopoutManager:sharedInstance():add(self, true, false)

	-- he_dumpGLObjectRefs()
end

function CDKeyConfirmPanel:onCloseBtnTapped( ... )

	self:onCDKeyConfirmPanelClosed(self.data)

	if (self.onCloseCallback) then
		self.onCloseCallback()
	end

	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false
end



-- ==========================================================
function CDKeyConfirmPanel:onCDKeyConfirmPanelClosed(data)
	-- local user = UserManager:getInstance().user
	-- local button = HomeScene:sharedInstance().coinButton
	-- HomeScene.sharedInstance():checkDataChange()
	-- -- button:updateView()
	self:playRewardAnim(data)
	-- if string.upper(enteredCodeStr) == "X30ASEHY33" then
	-- 	UserManager:getInstance().userExtend:setFlagBit(2, true)
	-- end
	-- if string.upper(enteredCodeStr) == "VVZHT9QS3R" then
	-- 	UserManager:getInstance().userExtend:setFlagBit(3, true)
	-- end
end

function CDKeyConfirmPanel:playRewardAnim(data) 
	local itemResPosInWorld = ccp(360,640)

	local anim = FlyItemsAnimation:create(data.data.rewardItems)
	anim:setWorldPosition(itemResPosInWorld)
	anim:setFinishCallback(function( ... )
		if not self.isDisposed then
			self:remove()
		end
	end)
	anim:play()

end





















