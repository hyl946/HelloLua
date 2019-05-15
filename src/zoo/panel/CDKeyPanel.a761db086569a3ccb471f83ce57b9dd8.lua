
require "zoo.panel.component.common.SoftwareKeyboardInput"
require "zoo.panel.CDKeyConfirmPanel"
require "zoo.panel.StockExchangePanel"

CDKeyPanel = class(BasePanel)

function CDKeyPanel:create(cdkeyBtnPosInWorldSpace)
	local newCDKeyPanel = CDKeyPanel.new()
	newCDKeyPanel:loadRequiredResource(PanelConfigFiles.BeginnerPanel)
	newCDKeyPanel:init(cdkeyBtnPosInWorldSpace)
	return newCDKeyPanel
end

function CDKeyPanel:init(cdkeyBtnPosInWorldSpace)

	----------------------
	-- Get UI Componenet
	-- -----------------
	self.ui	= self:buildInterfaceGroup("cdkey")--ResourceManager:sharedInstance():buildGroup("cdkey")

	--------------------
	-- Init Base Class
	-- --------------
	BasePanel.init(self, self.ui)
	self.ui:setTouchEnabled(true, 0, true)

	-------------------
	-- Get UI Componenet
	-- -----------------
	--self.panelTitle			= self.ui:getChildByName("titleLabel")
	self.panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
	self.ui:addChild(self.panelTitle)
	self.getRewardBtnRes	= self.ui:getChildByName("getRewardBtn")
	self.text1 				= self.ui:getChildByName("text1")
	self.text2 				= self.ui:getChildByName("text2")
	self.text3 				= self.ui:getChildByName("text3")

	--------------------
	-- Create UI Componenet
	-- ----------------------
	self.getRewardBtn		= GroupButtonBase:create(self.getRewardBtnRes)

	--------------
	-- Init UI
	-- ----------
	self.ui:setTouchEnabled(true, 0, true)

	----------------
	-- Update View
	-- --------------
	self.panelTitle:setString(Localization:getInstance():getText("exchange.code.panel.exchange.center"))
	self.getRewardBtn:setString(Localization:getInstance():getText("enter.invite.code.panel.receive.reward.btn"))
	self.text1:setString(Localization:getInstance():getText("exchange.code.panel.enter.text1"))
	self.text2:setString(Localization:getInstance():getText("exchange.code.panel.enter.text2"))

	if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
		self.text3:setString(Localization:getInstance():getText("exchange.code.panel.enter.text4"))
	else
		self.text3:setString(Localization:getInstance():getText("exchange.code.panel.enter.text3"))
	end

	if PlatformConfig:isBaiduPlatform() or 
	   PlatformConfig:isPlatform(PlatformNameEnum.kUC) or
	   PlatformConfig:isPlatform(PlatformNameEnum.kWDJ) or
	   PlatformConfig:isPlatform(PlatformNameEnum.kJinli) or
	   PlatformConfig:isPlatform(PlatformNameEnum.kJinliPre) or
	   WXJPPackageUtil.getInstance():isWXJPPackage() then
		self.text2:setVisible(false)
		self.text3:setVisible(false)
	end

	if PlatformConfig:isPlatform(PlatformNameEnum.kOppo) then
		self.text1:setVisible(false)
		self.text2:setVisible(false)
		self.text3:setVisible(false)
	end
	
	
	local function popupCDKeyConfirmPanel(data,callback)
		local function popoutPanel()
			self:setVisible(false)
			local panel = CDKeyConfirmPanel:create(data,callback)
			panel:popout()
		end
		AsyncLoader:getInstance():waitingForLoadComplete(popoutPanel)
	end


	local function onGetRewardBtnTapped(event)
		if self.isDisposed then return end
		local enteredCodeStr = self.input:getText()
		

		local function onSuccess(data)

			local  function onCDKeyConfirmPanelClosed()
				local user = UserManager:getInstance().user
				local button = HomeScene:sharedInstance().coinButton
				HomeScene.sharedInstance():checkDataChange()
				button:updateView()
				-- self:playRewardAnim(data) -- move to CDKeyConfirmPanel
				if string.upper(enteredCodeStr) == "X30ASEHY33" then
					UserManager:getInstance().userExtend:setFlagBit(2, true)
				end
				if string.upper(enteredCodeStr) == "VVZHT9QS3R" then
					UserManager:getInstance().userExtend:setFlagBit(3, true)
				end

				-- add
				self:remove()
			end


			if self.isDisposed then return end
			self.getRewardBtn:setEnabled(true)
			self.inputBlock:setTouchEnabled(false)

			if _G.isLocalDevelopMode then printx(0, "GetExchangeCodeRewardHttp::onSuccess") end
			-- HomeScene.sharedInstance().coinButton:updateView()
			-- data.data.rewardItems 
			local exchangeCodeInfo = data.data.exchangeCodeInfo
			if exchangeCodeInfo then
				local function closeCallback( ... )
					-- body
					self:updateEchangeCodeInfo()
				end
				CDKeyManager:getInstance():showCollectInfoPanel(exchangeCodeInfo, closeCallback)
			else
				popupCDKeyConfirmPanel(data,onCDKeyConfirmPanelClosed)
			end

			DcUtil:getCDKeyReward(string.upper(enteredCodeStr))
		end

		local function onFail(err)
			if self.isDisposed then return end
			if _G.isLocalDevelopMode then printx(0, "GetExchangeCodeRewardHttp::onFail") end
			self.getRewardBtn:setEnabled(true)
			self.inputBlock:setTouchEnabled(false)
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err.data)), "negative")
		end

		local function onCancel()
			if self.isDisposed then return end
			self.getRewardBtn:setEnabled(true)
			self.inputBlock:setTouchEnabled(false)
		end
		
		if string.len(enteredCodeStr) > 0 then
			local function onUserHasLogin()
				local index = string.find(enteredCodeStr, "%W")
				if index ~= nil then
					onFail({data = 730743})
				else
					self.getRewardBtn:setEnabled(false)
					self.inputBlock:setTouchEnabled(true, 0, true)
					local http = GetExchangeCodeRewardHttp.new(true)
					http:ad(Events.kComplete, onSuccess)
					http:ad(Events.kError, onFail)
					http:ad(Events.kCancel, onCancel)
					-- 增加平台 和机型 
					http:load(string.upper(enteredCodeStr),MetaInfo:getInstance():getMachineType())
				end
			end
			RequireNetworkAlert:callFuncWithLogged(onUserHasLogin)
		end
	end -- end onGetRewardBtnTapped



	self.getRewardBtn:addEventListener(DisplayEvents.kTouchTap, onGetRewardBtnTapped)
	self.getRewardBtn:useBubbleAnimation()
	
	-- close button
	self.closeBtn = self.ui:getChildByName("closebtn")
	self.closeBtn:setTouchEnabled(true, 0, false)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap,  function(event) self:onCloseBtnTapped(event) end)

	self.nameLabel = self.ui:getChildByName("touch")
	self.nameLabel:getChildByName("touch"):removeFromParentAndCleanup(true)	
	self.nameLabel:getChildByName("label"):setString(Localization:getInstance():getText("exchange.code.panel.enter.text"))
	self.nameLabel:getChildByName("inputBegin"):setVisible(false)

	-- if not __IOS then
		-- self.nameLabel:getChildByName("label"):setVisible(false)
	-- end
	self:updateEchangeCodeInfo()
	self:initInput()
end

function CDKeyPanel:updateEchangeCodeInfo( )
	-- body
	if self.isDisposed then return end
	local rewardInfo = self.ui:getChildByName("text_info")
	rewardInfo:setVisible(false)

	local stockInfo = self.ui:getChildByName("stock_info")
	if not stockInfo.originPosX then
		stockInfo.originPosX = stockInfo:getPositionX()
	end
	stockInfo:setVisible(false)

	local function closeCallback( ... )
					-- body
		self:updateEchangeCodeInfo()
	end

	local function onRewardInfoTapped( ... )
		-- body
		if CDKeyManager:getInstance():isInfoFull() then
			CDKeyManager:getInstance():showRewardInfoPanel()
		else
			CDKeyManager:getInstance():showCollectInfoPanel(nil, closeCallback)
		end
	end

	local function onStockTapped( ... )
		local stockPanel = StockExchangePanel:create(
			CDKeyManager:getInstance().stockExchangeCodes
		)
		stockPanel:popout()
	end

	if CDKeyManager:getInstance():hasReward() then
		rewardInfo:setVisible(true)
		rewardInfo:setTouchEnabled(true, 0, false)
		rewardInfo:setButtonMode(true)
		if CDKeyManager:getInstance():isInfoFull() then
			rewardInfo:getChildByName("bg2"):setVisible(false)
			rewardInfo:getChildByName("bg"):setVisible(true)
		else
			rewardInfo:getChildByName("bg2"):setVisible(true)
			rewardInfo:getChildByName("bg"):setVisible(false)
		end
		rewardInfo:removeAllEventListeners()
		rewardInfo:addEventListener(DisplayEvents.kTouchTap, onRewardInfoTapped)
	end

	if CDKeyManager:getInstance():hasStock() then
		stockInfo:setVisible(true)
		if not CDKeyManager:getInstance():hasReward() then
			stockInfo:setPositionX(stockInfo.originPosX + 175)
		else
			stockInfo:setPositionX(stockInfo.originPosX)
		end
		
		stockInfo:setTouchEnabled(true, 0, false)
		stockInfo:removeAllEventListeners()
		stockInfo:addEventListener(DisplayEvents.kTouchTap, onStockTapped)
	end
end

function CDKeyPanel:initInput()
	local inputSelect = self.nameLabel:getChildByName("inputBegin")
	local inputSize = inputSelect:getContentSize()
	local inputPos = inputSelect:getPosition()
	inputSelect:setVisible(true)
	inputSelect:removeFromParentAndCleanup(false)
	
	local function onTextBegin()
		if self.isDisposed then return end
		if self.input then
			self.input:setText("")
			self.nameLabel:getChildByName("label"):setString("")
		end
	end

	local function onTextEnd()
		if _G.isLocalDevelopMode then printx(0, "~~~ text end ~~~") end
		self.input:setVisible(true)
		if self.isDisposed then return end
		if self.input then
			
			local text = self.input:getText() or ""
	
			if text ~= "" then
				local codeMatch = string.find(text,"^[0-9a-zA-Z]+$");
				if not codeMatch or codeMatch~=1 then 
					CommonTip:showTip(Localization:getInstance():getText("error.tip.cdkey.content"), "negative",nil,2);
					self.input:setText("");
				end
			end
			self.nameLabel:getChildByName("label"):setString("")
		end
	end

	local function onTextChanged() 
		local text = self.input:getText() or ""
		local len = utfstrlen(self.input:getText())
		if _G.isLocalDevelopMode then printx(0, " >>> text changed >>>",text,len) end

		-- 当输入大于一定长度时，启用智能匹配
		if ( len > 20) then
			local it = string.gmatch (text, "[0-9a-zA-Z]+")

			for w in it do
			  if (#w >=10 ) then
			    -- if _G.isLocalDevelopMode then printx(0, "===>",w) end
			    self.input:setText(tostring(w))
			    self.input:setPlaceHolder("")
			    self.input:setVisible(false)
			    break
			  end
			end
		end
	end

	local position = ccp(inputPos.x + inputSize.width/2, inputPos.y - inputSize.height/2 + 5)
	local input = TextInputIm.new()
    input:init(inputSize, Scale9Sprite:createWithSpriteFrameName("img/beginnerpanel_ui_empty0000"))
	input.originalX_ = position.x
	input.originalY_ = position.y
	input:setText("")
	input:setPosition(position)
	input:setFontColor(ccc3(217,194,101))
	-- input:setMaxLength(15)
	input:ad(kTextInputEvents.kBegan, onTextBegin)
	input:ad(kTextInputEvents.kEnded, onTextEnd)
	input:ad(kTextInputEvents.kChanged,onTextChanged)
	self.nameLabel:addChild(input)
	self.input = input
	local inputBlock = LayerColor:create()
	local rectSize = input:getGroupBounds().size
	inputBlock:setContentSize(CCSizeMake(rectSize.width, rectSize.height))
	inputBlock:ignoreAnchorPointForPosition(false)
	inputBlock:setAnchorPoint(ccp(0.5, 0.5))
	inputBlock:setOpacity(0)
	inputBlock:setPosition(position)
	self.nameLabel:addChild(inputBlock)
	self.inputBlock = inputBlock
	inputSelect:dispose()
end

function CDKeyPanel:onCloseBtnTapped(event, ...)
	assert(event)
	assert(#{...} == 0)

	if not self.isOnCloseBtnTappedCalled then
		self.isOnCloseBtnTappedCalled = true
		self:remove()
	end
end

function CDKeyPanel:registerCloseCallback(closeCallback, ...)
	assert(type(closeCallback) == "function")
	assert(#{...} == 0)

	self.closeCallback = closeCallback
end

function CDKeyPanel:playRewardAnim(data) 
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

function CDKeyPanel:popout()
	function self:popoutShowTransition()
		self:setToScreenCenterHorizontal()
		self:setToScreenCenterVertical()
	end
	PopoutQueue:sharedInstance():push(self, true, false)
end

function CDKeyPanel:remove(...)
	PopoutManager:sharedInstance():remove(self, true)

	if self.closeCallback then
		self.closeCallback()
	end
end

function CDKeyPanel:onEnterHandler(event, ...)
	if event == "enter" then
		self.allowBackKeyTap = true
        self:runAction(self:createShowAnim())
	end
end

function CDKeyPanel:onEnterAnimationFinished()

end

function CDKeyPanel:createShowAnim()
    local centerPosX    = self:getHCenterInParentX()
    local centerPosY    = self:getVCenterInParentY()

    local function initActionFunc()
        local initPosX  = centerPosX
        local initPosY  = centerPosY + 100
        self:setPosition(ccp(initPosX, initPosY))
    end
    local initAction = CCCallFunc:create(initActionFunc)
    local moveToCenter      = CCMoveTo:create(0.5, ccp(centerPosX, centerPosY))
    local backOut           = CCEaseQuarticBackOut:create(moveToCenter, 33, -106, 126, -67, 15)
    local targetedMoveToCenter  = CCTargetedAction:create(self.refCocosObj, backOut)

    local function onEnterAnimationFinished() self:onEnterAnimationFinished() end
    local actionArray = CCArray:create()
    actionArray:addObject(initAction)
    actionArray:addObject(targetedMoveToCenter)
    actionArray:addObject(CCCallFunc:create(onEnterAnimationFinished))
    return CCSequence:create(actionArray)
end

function CDKeyPanel:getHCenterInScreenX(...)
	assert(#{...} == 0)

	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfWidth		= 694

	local deltaWidth	= visibleSize.width - selfWidth
	local halfDeltaWidth	= deltaWidth / 2

	return visibleOrigin.x + halfDeltaWidth
end