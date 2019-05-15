require "zoo.panel.CDKeyPanel"

HomeSceneButtonsBar = class(BaseUI)
local ButtonState = table.const{
	kNoButton = 0,
}
function HomeSceneButtonsBar:ctor()
	
end

function HomeSceneButtonsBar:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_s_i_right_bar')
	
	BaseUI.init(self, self.ui)

	self.buttonsInfoTable = {}

	self.blueBtn = HideAndShowButton:create(self.ui:getChildByName("blueBtn"))
	self.blueBtn:setEnable(false)
	self.blueBtn:ad(DisplayEvents.kTouchTap, function ()
		self:onBlueBtnTap()
	end)

	HomeSceneButtonsManager.getInstance():setBtnGroupBar(self)
end

local function getBgNameByBtnCount(count)
	if count >= 1 and count <= 4 then
		return 'buttonBar_bg' .. count
	elseif count == 5 then
		-- return 'buttonBar_bg6'
		return 'buttonBar_bg4',485
	elseif count == 6 then
		-- return 'buttonBar_bg6'
		return 'buttonBar_bg4',485
	elseif count == 7 then
		-- return 'buttonBar_bg8'
		return 'buttonBar_bg4',605
	elseif count == 8 then
		-- return 'buttonBar_bg8'
		return 'buttonBar_bg4',605
	elseif count == 9 or count == 10 then
		return 'buttonBar_bg4',720
	elseif count == 11 or count == 12 then
		return 'buttonBar_bg4',840
	elseif count == 13 or count == 14 then
		return 'buttonBar_bg4',960
	elseif count == 15 or count == 16 then
		return 'buttonBar_bg4',1080
	end
	return ret
end

function HomeSceneButtonsBar:initBg(count)
	local bgName,height = getBgNameByBtnCount(count)

	local bg = ResourceManager:sharedInstance():buildGroup(bgName)

	if height then
		local bgSprite = bg:getChildByName("sprite")
		local bgSize = bgSprite:getContentSize()
		local bounds = bgSprite:boundingBox()
		bgSprite:setVisible(false)

		local newSprite = Scale9Sprite:createWithSpriteFrame(
			bgSprite:displayFrame(),
			CCRectMake(bgSize.width/3,bgSize.height/2,bgSize.width/3,2)
		)		
		newSprite:setPreferredSize(CCSizeMake(bgSize.width,height))
		newSprite:setAnchorPoint(ccp(0,1))
		newSprite:setPositionX(bgSprite:getPositionX())
		newSprite:setPositionY(height - bgSize.height + bgSprite:getPositionY())
		bg:addChild(newSprite)
	end

	local x = -2
	local y = 0

	bg:setPosition(ccp(x, y))
	self.ui:addChildAt(bg, 0)
	self.bg = bg
	self.animBg = bg
end

function HomeSceneButtonsBar:onBgTap()
	local node = CocosObject.new(CCNode:create())
	local function delayHide()
		self:hideButtons()
		node:removeFromParentAndCleanup(true)
	end
	node:runAction(CCCallFunc:create(delayHide))
	HomeScene:sharedInstance():addChild(node)
end

function HomeSceneButtonsBar:onBlueBtnTap()
	self:hideButtons()
end

function HomeSceneButtonsBar:forceDisable(value)
	self._forceDisabled = value
end

function HomeSceneButtonsBar:isForceDisabled()
	return self._forceDisabled == true
end

function HomeSceneButtonsBar:showButtons(endCallback, forceShow)
	if HomeScene:sharedInstance().updateVersionButton then
		self.isUpdateButtonVisibleJustNow = HomeScene:sharedInstance().updateVersionButton:isVisible()
		if self.isUpdateButtonVisibleJustNow then
			HomeScene:sharedInstance().updateVersionButton:setVisible(false)
		end
	end

	self.isOpen = true

	if self.isPlayingAnim and not forceShow then
		return
	end
	self.isPlayingAnim = true

	self:initBg(HomeSceneButtonsManager:getInstance():getButtonCount())
	local size = self.bg:getGroupBounds().size
	--黑背景动画
	local bgWidth, bgHeight = size.width, size.height --HomeSceneButtonsManager.getInstance():getBarBgSize()

	--加号按钮动画
	-- self.bg:setTouchEnabled(false)
	self.blueBtn:setEnable(false)
	self.blueBtn:playAni(function ()
		self.blueBtn:setEnable(true)
		self.isPlayingAnim = false

		if endCallback then 
			endCallback()
		end
	end)

	local seqArr = CCArray:create()
	seqArr:addObject(CCScaleTo:create(2/24, 0.9, 1))
    seqArr:addObject(CCScaleTo:create(2/24, 1.1, 1.1))
    seqArr:addObject(CCScaleTo:create(2/24, 0.95, 1))
    seqArr:addObject(CCScaleTo:create(1/24, 1.05, 1.05))
    seqArr:addObject(CCScaleTo:create(1/24, 1, 1))
    seqArr:addObject(CCCallFunc:create(function ()
    	-- self.bg:setTouchEnabled(true, 0, false)

    	for i,v in ipairs(self.buttonsInfoTable) do
    		v.wrapper:setTouchEnabled(true, 0, true)
    	end

    	if not self.clickLayer then
	    	local clickLayer = LayerColor:create()
	    	clickLayer:setColor(ccc3(50,50,50))
	    	clickLayer:setOpacity(0)
	    	-- local clickLayer = Layer:create()
	    	self:addChild(clickLayer)
			-- Director:sharedDirector():getRunningScene():addChild(clickLayer)
			self.clickLayer = clickLayer
			clickLayer:ad(DisplayEvents.kTouchTap, 
			function () 
				if not self.isDisposed and self.isOpen then 
					self:runAction(CCCallFunc:create(function () self:hideButtons() end))
				end 
			end)
			clickLayer.hitTestPoint = function ()
				return true
			end
	    	clickLayer:setTouchEnabled(true, 0, false)
	    end
    end))

    -- --加防点击穿透层
    local touchLayer = LayerColor:create()
    touchLayer:setColor(ccc3(255,0,0))
    touchLayer:setOpacity(0)
    touchLayer:setContentSize(CCSizeMake(bgWidth, bgHeight-120))
    touchLayer:setTouchEnabled(true, 0, true)
    touchLayer:setPosition(ccp(-bgWidth+63, 57))
    self.animBg:addChild(touchLayer)

	self.animBg:runAction(CCSequence:create(seqArr))

	local btns = HomeSceneButtonsManager.getInstance():getBtns()
	
	for row, rowConfig in pairs(btns) do
		for col,btnConfig in ipairs(rowConfig) do
			local buttonNode = {}
			buttonNode.btn = btnConfig.btn
			if row == 1 then 
				buttonNode.row = col + 1 
			else
				buttonNode.row = col
			end
			buttonNode.wrapper = buttonNode.btn.wrapper
			buttonNode.wrapper:setTouchEnabled(false)

			buttonNode.btn:removeFromParentAndCleanup(false)
			buttonNode.btn = HomeSceneButtonsManager.getInstance():addLayerColorWrapper(buttonNode.btn, btnConfig.anchorIsCenter)
			self:addChild(buttonNode.btn)

			buttonNode.btn:setPosition(ccp(btnConfig.posX, btnConfig.posY))
			buttonNode.btn:setScale(0)
			table.insert(self.buttonsInfoTable, buttonNode)
		end
	end

	for i,v in ipairs(self.buttonsInfoTable) do
		local seqArr1 = CCArray:create()
		seqArr1:addObject(CCDelayTime:create(v.row * 0.05 - 0.05))
		seqArr1:addObject(CCScaleTo:create(3/24, 0.9))
	    seqArr1:addObject(CCScaleTo:create(2/24, 1.1))
	    seqArr1:addObject(CCScaleTo:create(2/24, 0.95))
	    seqArr1:addObject(CCScaleTo:create(1/24, 1.05))
	    seqArr1:addObject(CCScaleTo:create(1/24, 1))
	    v.btn:stopAllActions()
		v.btn:runAction(CCSequence:create(seqArr1))
	end

end

function HomeSceneButtonsBar:hideButtons(callback, forceHide)
	if HomeScene:sharedInstance().updateVersionButton and self.isUpdateButtonVisibleJustNow then
		HomeScene:sharedInstance().updateVersionButton:setVisible(true)
	end
	if not self.isOpen then
		return
	end
	
	if self.isPlayingAnim and not forceHide then
		return 
	end
	self.isPlayingAnim = true

	self.bg:setTouchEnabled(false)
	self.blueBtn:setEnable(false)

	local seqArr = CCArray:create()
	seqArr:addObject(CCScaleTo:create(1/24, 1.05))
    seqArr:addObject(CCScaleTo:create(2/24, 0.4))
    seqArr:addObject(CCHide:create())
	self.animBg:runAction(CCSequence:create(seqArr))

	local buttonTypeTable = HomeSceneButtonsManager.getInstance():getBtns()
	local onelineBtnNum = #buttonTypeTable[2]
	for i,v in ipairs(self.buttonsInfoTable) do
		v.wrapper:setTouchEnabled(false)
		local seqArr1 = CCArray:create()
		local time = onelineBtnNum * 1/24 - v.row * 1/24
		seqArr1:addObject(CCDelayTime:create(time))
	    seqArr1:addObject(CCScaleTo:create(1/24, 1.1))
	    seqArr1:addObject(CCScaleTo:create(2/24, 0))
	    v.btn:stopAllActions()
		v.btn:runAction(CCSequence:create(seqArr1))
	end


	self.blueBtn:playAni(function ()
		for k, v in pairs(self.buttonsInfoTable) do
			local layerWrapper = v.btn
			layerWrapper:removeFromParentAndCleanup(false)
			local realBtn = layerWrapper:getChildAt(0)
			if realBtn then
				realBtn:removeFromParentAndCleanup(false)
				HomeSceneButtonsManager:getInstance():addBtnToContainer(realBtn)
			end
			layerWrapper:dispose()
		end

		self.isOpen = false
		self.isPlayingAnim = false

		if self.clickLayer then
			self.clickLayer:removeFromParentAndCleanup(true)
			self.clickLayer = nil
		end

		if self.bg then
			self.bg:removeFromParentAndCleanup(true)
			self.bg = nil
		end
		if callback then
			callback()
		end
		self.buttonsInfoTable = {}
		self.btnBarEvent:dispatchCloseEvent()
		self:removePopout()
	end)
end

function HomeSceneButtonsBar:popout(endCallback)
	self:showButtons(endCallback)
end

function HomeSceneButtonsBar:removePopout()
	-- HomeSceneButtonsManager.getInstance():setBtnGroupBar(nil)
	-- self:removeFromParentAndCleanup(true)
end

function HomeSceneButtonsBar:popoutBagPanel()
	local bagButtonPos 				= self.bagButton:getPosition()
	local bagButtonParent			= self.bagButton:getParent()
	local bagButtonPosInWorldSpace	= bagButtonParent:convertToWorldSpace(ccp(bagButtonPos.x, bagButtonPos.y))
	local panel = BagPanel:createBagPanel(bagButtonPosInWorldSpace)
	if panel then 
		panel:popout()
	end
end

function HomeSceneButtonsBar:popoutFriendRankingPanel()
	self.friendButton.wrapper:setTouchEnabled(false)
	local function __reset()
		if self.friendButton then self.friendButton.wrapper:setTouchEnabled(true) end
	end
--	self:runAction(CCSequence:createWithTwoActions(
--	               CCDelayTime:create(0.2), CCCallFunc:create(__reset)
--	               ))
	createFriendRankingPanel( nil, __reset )
end

function HomeSceneButtonsBar:popoutFruitTreePanel()
	local function success()
		if self.isDisposed then return end
		self.fruitTreeButton.wrapper:setTouchEnabled(false)
		self:runAction(CCCallFunc:create(function()
			local scene = FruitTreeScene:create()
			Director:sharedDirector():pushScene(scene)
			self.fruitTreeButton.wrapper:setTouchEnabled(true, 0, true)
		end))
	end
	local function fail(err, skipTip)
		if self.isDisposed then return end
		if not skipTip then CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err))) end
	end
	local function updateInfo()
		FruitTreeSceneLogic:sharedInstance():updateInfo(success, fail)
	end
	local function onLoginFail()
		fail(-2, true)
	end
	RequireNetworkAlert:callFuncWithLogged(updateInfo, onLoginFail)
end

function HomeSceneButtonsBar:popoutStarRewardPanel()
	local starRewardBtnPos = self.starRewardButton:getPosition()
	local starRewardBtnParent = self.starRewardButton:getParent()
	local starRewardBtnPosInWorldSpace = starRewardBtnParent:convertToWorldSpace(ccp(starRewardBtnPos.x, starRewardBtnPos.y))

	local starRewardBtnSize	= self.starRewardButton.wrapper:getGroupBounds().size

	starRewardBtnPosInWorldSpace.x = starRewardBtnPosInWorldSpace.x + starRewardBtnSize.width / 2
	starRewardBtnPosInWorldSpace.y = starRewardBtnPosInWorldSpace.y - starRewardBtnSize.height / 2

	local starRewardPanel = StarRewardPanel:create(starRewardBtnPosInWorldSpace)
	if starRewardPanel then
		-- starRewardPanel:registerCloseCallback(onStarRewardPanelClose)
		starRewardPanel:popout()
	end
end

function HomeSceneButtonsBar:popoutMessageCenter()
	local function callback(result, evt)
		if result == "success" then
			Director:sharedDirector():pushScene(MessageCenterScene:create())
			if self.isDisposed then return end
			if self.messageButton then
				self.messageButton:updateView()
			end
		else
			if PrepackageUtil:isPreNoNetWork() then
				PrepackageUtil:showInGameDialog()
			else
				local message = ''
				local err_code = tonumber(evt.data)
				if err_code then message = Localization:getInstance():getText("error.tip."..err_code) end
				CommonTip:showTip(message, "negative")
			end
		end
	end
	FreegiftManager:sharedInstance():update(true, callback)
end

function HomeSceneButtonsBar:popoutMarkPanel()
	
    if not UserManager:getInstance().markV2Active then
        local bounds = self.markButton.wrapper:getGroupBounds()
	    local worldPos = ccp(bounds:getMidX(),bounds:getMidY())

        local panel = MarkPanel:create(worldPos)
	    panel:popout()
    else
        Mark2019Manager.getInstance():showMark2019Panel(nil, nil, 4)
    end
end

function HomeSceneButtonsBar:createButton(buttonType)
	local button = ButtonState.kNoButton
	if buttonType == HomeSceneButtonType.kNull then 
	elseif buttonType == HomeSceneButtonType.kBag then
		button = BagButton:create()
		self.bagButton = button
		self.bagButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
			if self.isDisposed then return end
			DcUtil:iconClick("click_bag_icon")
			-- PopoutQueue:sharedInstance():removeAllInNextLevelModel(109)
			self:popoutBagPanel()
		end)
	elseif buttonType == HomeSceneButtonType.kFriends then
		button = FriendButton:create()
		self.friendButton = button
		self.friendButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
			if self.isDisposed then return end
			local dcData = {}
			dcData.category = "add_friend"
			dcData.sub_category = "click_partner_icon"
			DcUtil:log(AcType.kUserTrack, dcData, true)
			-- PopoutQueue:sharedInstance():removeAllInNextLevelModel(110)
			self:popoutFriendRankingPanel()
		end)
	elseif buttonType == HomeSceneButtonType.kTree then
		button = FruitTreeButton:create()
		self.fruitTreeButton = button
		local function onFruitBtnTap()
			if self.isDisposed then return end
			DcUtil:iconClick("click_fruiter_icon")
			-- PopoutQueue:sharedInstance():removeAllInNextLevelModel(111)
			self:popoutFruitTreePanel()
		end
		self.fruitTreeButton.wrapper:addEventListener(DisplayEvents.kTouchTap, onFruitBtnTap)
		self.fruitTreeButton.onClick = onFruitBtnTap
	elseif buttonType == HomeSceneButtonType.kMail then
		button = MessageButton:create()
		self.messageButton = button
		self.messageButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
			if self.isDisposed then return end
			DcUtil:iconClick("click_letters_icon")
			-- PopoutQueue:sharedInstance():removeAllInNextLevelModel(112)
			self:popoutMessageCenter()
		end)
	elseif buttonType == HomeSceneButtonType.kStarReward then
		button = StarRewardButton:create()
		self.starRewardButton = button
		self.starRewardButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
			if self.isDisposed then return end
			DcUtil:iconClick("click_stars_seward_icon")
			-- PopoutQueue:sharedInstance():removeAllInNextLevelModel(113)
			self:popoutStarRewardPanel()
		end)
	elseif buttonType == HomeSceneButtonType.kMark then
		button = MarkButton:create()
		self.markButton = button
		self.markButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
			if self.isDisposed then return end
			DcUtil:iconClick("click_sign_icon")
			-- PopoutQueue:sharedInstance():removeAllInNextLevelModel(114)
			self:popoutMarkPanel()
		end)
	elseif buttonType == HomeSceneButtonType.kMission then
		button = MissionButton:create(true)
		if _G.__use_small_res then
			button.wrapper:setPosition( ccp( 0 , -38 ) )
		else
			button.wrapper:setPosition( ccp( 0 , -46 ) )
		end
		
		self.missionButton = button

		-- self.missionButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
		-- 	if self.isDisposed then return end
		-- end)

    elseif buttonType == HomeSceneButtonType.kCdkeyBtn then
        button = CDKeyButton:create()
        button.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
            if self.isDisposed then return end
            -- PopoutQueue:sharedInstance():removeAllInNextLevelModel(115)
            self:onCdkeyBtnTapped()
        end)
        self.cdkeyBtn = button
    elseif buttonType == HomeSceneButtonType.kRealName then
    	local RealNameButton = require 'zoo.panel.RealName.RealNameButton'
		button = RealNameButton:create()
        self.realNameIcon = button
    elseif buttonType == HomeSceneButtonType.kWDJRemove then
    	local WDJRemoveButton = require 'zoo.panel.wdjremove.WDJRemoveButton'
		button = WDJRemoveButton:create()
        self.wdjRemoveIcon = button
    elseif buttonType == HomeSceneButtonType.kMiTalkRemove then
    	local MiTalkRemoveButton = require 'zoo.panel.mitalkremove.MiTalkRemoveButton'
		button = MiTalkRemoveButton:create()
        self.mitalkRemoveIcon = button
    elseif buttonType == HomeSceneButtonType.kWXJPHub then
    	local WXJPHubButton = require 'zoo.scenes.component.HomeScene.iconButtons.WXJPGameHubButton'
		button = WXJPHubButton:create()
		self.wxjpHubButton = button
		self.wxjpHubButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
			if self.isDisposed then return end
			-- PopoutQueue:sharedInstance():removeAllInNextLevelModel(116)
			WXJPPackageUtil.getInstance():openGameHub()
		end)
	elseif buttonType == HomeSceneButtonType.kWXJPGroup then
    	local WXJPGroupButton = require 'zoo.scenes.component.HomeScene.iconButtons.WXJPInterestGroupButton'
		button = WXJPGroupButton:create()
		self.wxjpGroupButton = button
		self.wxjpGroupButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
			if self.isDisposed then return end
			-- PopoutQueue:sharedInstance():removeAllInNextLevelModel(117)
			WXJPPackageUtil.getInstance():openInterestGroup(true)
		end)
	else
		button = MarkButton:create()
	end

	return button
end

function HomeSceneButtonsBar:onCdkeyBtnTapped()
    -- self:hideButtons()
    if not self.cdkeyBtn or self.cdkeyBtn.isDisposed then return end
    DcUtil:UserTrack({ category='setting', sub_category="setting_click", action = 'exchange_code'})
    local position = self.cdkeyBtn:getPosition()
    local parent = self.cdkeyBtn:getParent()
    local wPos = parent:convertToWorldSpace(ccp(position.x, position.y))
    local panel = CDKeyPanel:create(wPos)
    if panel then
        panel:popout()
    end
end

function HomeSceneButtonsBar:getBtnByType(buttonType)
	local targetBtn = nil
	if buttonType == HomeSceneButtonType.kBag then
		targetBtn = self.bagButton
	elseif buttonType == HomeSceneButtonType.kFriends then
		targetBtn = self.friendButton
	elseif buttonType == HomeSceneButtonType.kTree then
		targetBtn = self.fruitTreeButton
	elseif buttonType == HomeSceneButtonType.kMail then
		targetBtn = self.messageButton
	elseif buttonType == HomeSceneButtonType.kStarReward then
		targetBtn = self.starRewardButton
	elseif buttonType == HomeSceneButtonType.kMark then
		targetBtn = self.markButton
	elseif buttonType == HomeSceneButtonType.kMission then
		targetBtn = self.missionButton
	elseif buttonType == HomeSceneButtonType.kRealName then
		targetBtn = self.realNameIcon
	elseif buttonType == HomeSceneButtonType.kWDJRemove then
		targetBtn = self.wdjRemoveIcon
	elseif buttonType == HomeSceneButtonType.kMiTalkRemove then
		targetBtn = self.mitalkRemoveIcon
	end
	return targetBtn
end

function HomeSceneButtonsBar:create(btnBarEvent)
	local bar = HomeSceneButtonsBar.new()
	bar.btnBarEvent = btnBarEvent
	bar:init()
	bar:createPermanentButtons()
	return bar
end


function HomeSceneButtonsBar:createPermanentButtons()
	local iOSInReview = false
    if __IOS and MaintenanceManager:getInstance():isInReview() then
        iOSInReview = true
    end
	if not (PrepackageUtil:isPreNoNetWork() or __IOS_FB or WXJPPackageUtil.getInstance():isGuestLogin()) and
		not FriendRecommendManager:friendsButtonOutSide() then
		HomeScene:sharedInstance():addIcon(self:createButton(HomeSceneButtonType.kFriends), true)
	end	
	-- local showCdkeyBtn = RequireNetworkAlert:popout(nil, 2) and MaintenanceManager:getInstance():isEnabled("CDKeyCode") or __WIN32
	-- if PlatformConfig:isPlayDemo() then showCdkeyBtn = false end
	if not iOSInReview then -- iOS提审时需要隐藏兑换按钮，为此把信件icon挪到了左下角按钮里
		HomeScene:sharedInstance():addIcon(self:createButton(HomeSceneButtonType.kCdkeyBtn), true)
	end

	if WXJPPackageUtil.getInstance():isWXJPPackage() then 
		local authorType = SnsProxy:getAuthorizeType()
		if authorType == PlatformAuthEnum.kJPQQ then 
		elseif authorType == PlatformAuthEnum.kJPWX then 
			-- HomeScene:sharedInstance():addIcon(self:createButton(HomeSceneButtonType.kWXJPHub), true)
		end
	end
end

function HomeSceneButtonsBar:flyFromLayoutBar(btnIcon, startCallback, endCallback)
	local hideBtnSize = CCSizeMake(96, 96)
	local scene = HomeScene:sharedInstance()
	local endPos = btnIcon:getParent():convertToNodeSpace(scene.hideAndShowBtn:getPositionInWorldSpace())

	-- 隐藏tip,并取消弹出记录
	if btnIcon.tip and btnIcon.stopHasNotificationAnim then
		btnIcon:stopHasNotificationAnim()
		IconButtonManager:getInstance():revertShowTime(btnIcon)
	end
	if btnIcon.disableTip then
		btnIcon:disableTip()
	end

	local sequence = CCArray:create()
	local spawn = CCArray:create()
	spawn:addObject(CCEaseBackIn:create(CCMoveTo:create(1, endPos)))
	spawn:addObject(CCScaleTo:create(1, 1))
	if startCallback then 
		sequence:addObject(CCCallFunc:create(startCallback))
	end
	sequence:addObject(CCSpawn:create(spawn))
	btnIcon:stopAllActions()
	btnIcon:runAction(CCSequence:create(sequence))
	local totalTime = 1.1 -- Spawn时间
	-- 防止btnIcon被remove，回调会不能执行到
	self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(totalTime), CCCallFunc:create(
		function ()  
			if btnIcon and not btnIcon.isDisposed then
				btnIcon:setScale(1)
			end
			if scene.hideAndShowBtn then
				scene.hideAndShowBtn:playtip('飞走的图标，在这里可以打开哟！')
			end
			if endCallback then 
				endCallback() 
			end 
		end)))
end
