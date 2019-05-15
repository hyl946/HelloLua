
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月22日 12:10:42
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.baseUI.ButtonWithShadow"
require "zoo.panel.component.quitPanel.QuitPanelButton"
require 'zoo.panelBusLogic.guideAtlas.GuideAtlasPanel'

QuitPanelMode	= {
	QUIT_LEVEL	= 1,
	QUIT_GAME	= 2,
	NO_REPLAY	= 3,
}

local ButtonUIType = {
    kNormal = "button_Group_base" ,
    kWithSpeedUp = "button_Group_all" ,
}

local CLK_BLOCKER_DESC_KEY = "has_see_blocker_desc"

local function checkQuitPanelMode(mode)
	assert(mode == QuitPanelMode.QUIT_LEVEL or
		mode == QuitPanelMode.QUIT_GAME or mode == QuitPanelMode.NO_REPLAY)
end

local DebugPanel = class(CocosObject)

function DebugPanel:create(parentPanel, width, height)
	local panel = DebugPanel.new(CCNode:create())
	panel:init(parentPanel, width, height)
	return panel
end

function DebugPanel:init(parentPanel, width, height)
	local pWidth = parentPanel:getGroupBounds().size.width
	local pHeight = parentPanel:getGroupBounds().size.height
	self.width = width or pWidth
	self.height = height or 320
	local bg = LayerColor:createWithColor(ccc3(200, 200, 200), self.width, self.height)
	bg:setOpacity(255*0.6)
	bg:setTouchEnabled(true, 0, true)
	bg:setAnchorPoint(ccp(0, 1))
	bg:ignoreAnchorPointForPosition(false)
	self:addChild(bg)
	self.itemHeight = 80
	self.row = 0

	self:passLevelButtons(parentPanel)
	self:addScoreButtons(parentPanel)
	self:addTargetButtons(parentPanel)
	self:addStepButtons(parentPanel)
	self:addPropWeakGuideButtons(parentPanel)
	self:addDecTargetButtons(parentPanel)

	bg:changeWidthAndHeight(self.width, self.row*self.itemHeight)
end

function DebugPanel:getPosY()
	return -((self.row+1)*self.itemHeight + 1)
end

function DebugPanel:passLevelButtons(parentPanel)
	local button1 = QuitPanel:_createTestButton("成功过关", hex2ccc3("CCFF66"), 32, self.width/2 - 2, self.itemHeight - 2)
	button1:setPosition(ccp(1, self:getPosY()))
	button1:addEventListener(DisplayEvents.kTouchTap, function()

        if SpringFestival2019Manager.getInstance():getCurIsActSkill() then
            local step = 0
            if GameBoardLogic:getCurrentLogic() then
                step = GameBoardLogic:getCurrentLogic().theCurMoves
            end
            SpringFestival2019Manager.getInstance():initFlyPigLeftNum(step)
        end
        
		if parentPanel._PassLevelTappedCallback then parentPanel._PassLevelTappedCallback() end
		end)
	self:addChild(button1)

	local button2 = QuitPanel:_createTestButton("过关失败", hex2ccc3("FF6666"), 32, self.width/2 - 2, self.itemHeight - 2)
	button2:setPosition(ccp(self.width/2 + 1, self:getPosY()))
	button2:addEventListener(DisplayEvents.kTouchTap, function()

        if SpringFestival2019Manager.getInstance():getCurIsActSkill() then
            local step = 0
            if GameBoardLogic:getCurrentLogic() then
                step = GameBoardLogic:getCurrentLogic().theCurMoves
            end
            SpringFestival2019Manager.getInstance():initFlyPigLeftNum(step)
        end

		if parentPanel._FailGameTappedCallback then parentPanel._FailGameTappedCallback() end
	end)
	self:addChild(button2)
	self.row = self.row + 1
	return true
end

function DebugPanel:addScoreButtons(parentPanel)
	if parentPanel._AddScoreTappedCallback then
		local function addScore(score)
			parentPanel._AddScoreTappedCallback(score)
		end
		local scores = {10000, 50000, 100000}
		local width = self.width/#scores
		for i, v in ipairs(scores) do
			local button = QuitPanel:_createTestButton(string.format("加%dW分", v/10000), hex2ccc3("66CCFF"), 32, width - 2, self.itemHeight - 2)
			button:setPosition(ccp(width*(i-1) + 1, self:getPosY()))
			button:addEventListener(DisplayEvents.kTouchTap, function()
				addScore(v)
			end)
			self:addChild(button)
		end
		self.row = self.row + 1
		return true
	end
	return false
end

function DebugPanel:addTargetButtons(parentPanel)
	if parentPanel._AddTargetTappedCallback then
		local function addTarget(target)
			parentPanel._AddTargetTappedCallback(target)
		end
		local targets = {10, 50, 100}
		local width = self.width/#targets
		for i, v in ipairs(targets) do
			local button = QuitPanel:_createTestButton(string.format("加%d个", v), hex2ccc3("66CCFF"), 32, width - 2, self.itemHeight - 2)
			button:setPosition(ccp(width*(i-1) + 1, self:getPosY()))
			button:addEventListener(DisplayEvents.kTouchTap, function()
				addTarget(v)
			end)
			self:addChild(button)
		end
		self.row = self.row + 1
		return true
	end
	return false
end

function DebugPanel:addStepButtons(parentPanel)
	if parentPanel._UseUpMovesTappedCallback then
		local function addStep(step)
			parentPanel._UseUpMovesTappedCallback(step)
		end
		local steps = {1, -1, 5, -5}
		local width = self.width/#steps
		for i, v in ipairs(steps) do
			local button = QuitPanel:_createTestButton(string.format("加%d步", v), hex2ccc3("66CCFF"), 32, width - 2, self.itemHeight - 2)
			button:setPosition(ccp(width*(i-1) + 1, self:getPosY()))
			button:addEventListener(DisplayEvents.kTouchTap, function()
				addStep(v)
			end)
			self:addChild(button)
		end
		self.row = self.row + 1
		return true
	end
	return false
end

function DebugPanel:addDecTargetButtons(parentPanel)
	-- --
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--

	return false
end

function DebugPanel:addPropWeakGuideButtons(parentPanel)
	local needIgnoreChecks = {"__all"}
	local weakGuides = {
		{guideIdx = 500010100, gType = "weak", propId = 10001},
		{guideIdx = 5000101022, gType = "weak", propId = 10003},
		{guideIdx = 5000101031, gType = "weak", propId = 10005},
		{guideIdx = 5000101041, gType = "weak", propId = 10052},
		{guideIdx = 500010106, gType = "weak", propId = 10002},
		{guideIdx = 5000101081, gType = "weak", propId = 10056},
		{guideIdx = 5000101011, gType = "weak", propId = 10010},
	}
	local function addStep(data)
		GameGuideCheck:addIgnoreCheckTypes(data.guideIdx, needIgnoreChecks)
	end
	local maxCol = 6
	local width = self.width/maxCol

	local col = 1
	local button = QuitPanel:_createTestButton("弱引导>>", hex2ccc3("FF6633"), 24, width - 2, self.itemHeight - 2)
	button:setPosition(ccp(width*(col-1) + 1, self:getPosY()))
	self:addChild(button)

	col = col + 1
	for i, v in ipairs(weakGuides) do
		if col > maxCol then
			self.row = self.row + 1
			col = 2
		end
		local button = QuitPanel:_createTestButton(localize("prop.name."..v.propId), hex2ccc3("66CCCC"), 24, width - 2, self.itemHeight - 2)
		button:setPosition(ccp(width*(col-1) + 1, self:getPosY()))
		button:addEventListener(DisplayEvents.kTouchTap, function()
			addStep(v)
		end)
		self:addChild(button)
		col = col + 1
	end

	self.row = self.row + 1
	return true
end

---------------------------------------------------
-------------- QuitPanel
---------------------------------------------------

assert(not QuitPanel)
assert(BasePanel)
QuitPanel = class(BasePanel)
function QuitPanel:init(mode, boardLogic)
	checkQuitPanelMode(mode)
	-- assert(#{...} == 0)

	self.boardLogic = boardLogic

	------------------
	-- Get UI Resource
	-- ---------------
	--self.ui = ResourceManager:sharedInstance():buildGroup("quitPanel")
	self.ui	= self:buildInterfaceGroup("finalQuitPanel") --ResourceManager:sharedInstance():buildGroup("finalQuitPanel")

	----------------
	-- Init Base UI
	-- -------------
	BasePanel.init(self, self.ui, 'QuitPanel')

	-------------------
	-- Data
	-- ---------------
	self.mode = mode
	self.onReplayBtnTappedCallback		= false
	self.onQuitGameBtnTappedCallback	= false
	self.onClosePanelBtnTappedCallback	= false

	self.panelChildren = {}
	self.ui:getVisibleChildrenList(self.panelChildren)

	------------------------
	-- Variable To Indicate 
	-- ----------------------
	self.BTN_TAPPED_STATE_NONE		= 1
	self.BTN_TAPPED_STATE_BTN1_TAPPED	= 2
	self.BTN_TAPPED_STATE_BTN2_TAPPED	= 3
	self.BTN_TAPPED_STATE_BTN3_TAPPED	= 4
	self.btnTappedState			= self.BTN_TAPPED_STATE_NONE

	-----------------
	-- Get UI Resource
	-- --------------
	self.panelTitle		= self.ui:getChildByName("panelTitle")

	self.btn1Res		= self.ui:getChildByName("button1")
	self.btn2Res		= self.ui:getChildByName("button2")
	self.closeBtn		= self.ui:getChildByName("closeBtn")

	self.bg = self.ui:getChildByName("_newBg")

	self.atlasBtn = self.ui:getChildByName('atlasBtn')
	self.atlasBtn:setTouchEnabled(true, 0, true)
	self.atlasBtn:ad(DisplayEvents.kTouchTap, function () self:onAtlasBtnTapped() end)

	if LevelType.isActivityLevelType(self.boardLogic.levelType) then
		self.atlasBtn:removeFromParentAndCleanup(true)
		local bgWidth = self.bg:getPreferredSize().width
		local bgHeight = self.bg:getPreferredSize().height
		self.bg:setPreferredSize(CCSizeMake(bgWidth, bgHeight - 50))
	else
		if not CCUserDefault:sharedUserDefault():getBoolForKey(self:getClkBlockerDescKey(), false) then
			self.atlasBtnRedDot = Sprite:createWithSpriteFrameName("accountTipDot__uk__3" .. "0000")
			self.atlasBtnRedDot:setScale(0.8)
			self.atlasBtnRedDot:setPositionXY(-54, 15)
			self.atlasBtn:addChild(self.atlasBtnRedDot)
		end
	end
	----------------------------------
	-- When Opened In GamePlaySceneUI
	--
	-- Quit Level:
	-- btn1:	Replay Btn
	-- btn2:	Quit Level
	--------------------------------
	
	------------------------------
	-- When Opened In HomeScene
	--
	--	Quit Game:
	--  btn1:	Hlep
	--  btn2:	Quit Game
	--  ------------------------

	assert(self.panelTitle)
	assert(self.btn1Res)
	assert(self.btn2Res)
	assert(self.closeBtn)

	-----------------------
	-- Create UI Component
	-- -------------------
	self.btn1	= ButtonIconsetBase:create(self.btn1Res)--QuitPanelButton:create(self.btn1Res)
	self.btn2	= ButtonIconsetBase:create(self.btn2Res)--QuitPanelButton:create(self.btn2Res)

	self.btn1:setColorMode(kGroupButtonColorMode.blue)
	self.btn2:setColorMode(kGroupButtonColorMode.orange)
	self.btn1:useBubbleAnimation()
	self.btn2:useBubbleAnimation()

	--------------
	-- Init UI
	-- -----------
	self.panelTitle:setText("")
	
	-----------------
	-- Update View
	-- ---------------
	if self.boardLogic.theGamePlayType == GameModeTypeId.CLASSIC_ID then
		self:initButtons( ButtonUIType.kNormal )
	else
		self:initButtons( ButtonUIType.kWithSpeedUp )
	end
	

	if self.mode == QuitPanelMode.QUIT_LEVEL then
		-- btn1:	Replay Btn
		-- btn2:	Quit Level

		local pauseLabelKey	= "quit.panel.pause"
		local pauseLabelValue	= Localization:getInstance():getText(pauseLabelKey)
		self.panelTitle:setText(pauseLabelValue)
		
		local btn1LabelKey 	= "quit.panel.replay"
		local btn1LabelValue 	= Localization:getInstance():getText(btn1LabelKey)
		self.btn1:setString(btn1LabelValue)
		self.btn1:setIconByFrameName("common_icon/setting/icon_replay0000")
		--self.btn1.replayIcon:setVisible(true)

		local btn2LabelKey 	= "quit.panel.quit.level"
		local btn2LabelValue	= Localization:getInstance():getText(btn2LabelKey)
		self.btn2:setString(btn2LabelValue)
		self.btn2:setIconByFrameName("common_icon/setting/icon_quit0000")
		--self.btn2.quitIcon:setVisible(true)

	elseif self.mode == QuitPanelMode.QUIT_GAME then --never used
		--  btn1:	Hlep
		--  btn2:	Quit Game

		local btn1LabelKey	= "quit.panel.help"
		local btn1LabelValue	= Localization:getInstance():getText(btn1LabelKey)
		self.btn1:setString(btn1LabelValue)
		--self.btn1.helpIcon:setVisible(true)

		local btn2LabelKey	= "quit.panel.quit.game"
		local btn2LabelValue	= Localization:getInstance():getText(btn2LabelKey)
		self.btn2:setString(btn2LabelValue)
		--self.btn2.quitIcon:setVisible(true)
	elseif self.mode == QuitPanelMode.NO_REPLAY then
		local pauseLabelKey	= "quit.panel.pause"
		local pauseLabelValue	= Localization:getInstance():getText(pauseLabelKey)
		self.panelTitle:setText(pauseLabelValue)
		self.btn1:setVisible(false)
		self.btn1:setEnabled(false)
		local btn2LabelKey 	= "quit.panel.quit.level"
		local btn2LabelValue	= Localization:getInstance():getText(btn2LabelKey)
		self.btn2:setString(btn2LabelValue)
		self.btn2:setIconByFrameName("common_icon/setting/icon_quit0000", true)
		self.btn2:setPositionX(self.bg:getGroupBounds().size.width / 2 + 10)

	else
		assert(false)
	end
	local size = self.panelTitle:getContentSize()
	local scale = 65 / size.height
	self.panelTitle:setScale(scale)
	self.panelTitle:setPositionX((self.bg:getGroupBounds().size.width - size.width * scale) / 2)

	-------------------
	-- Add Event Listener
	-- ----------------
	local function onClosePanelBtnTapped(event)
		self:onCloseBtnTapped(event)
	end

	-- Btn1 Tapped
	local function onBtn1Tapped(event)
		self:onBtn1Tapped(event)
	end
	self.btn1:addEventListener(DisplayEvents.kTouchTap, onBtn1Tapped)

	-- Btn2 Tapped
	local function onBtn2Tapped(event)
		self:onBtn2Tapped(event)
	end
	self.btn2:addEventListener(DisplayEvents.kTouchTap, onBtn2Tapped)

	-- CLose Btn
	local function onCloseBtnTapped(event)
		self:onCloseBtnTapped(event)
	end

	self.closeBtn:setTouchEnabled(true, 0, true)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)

	if self:noPrebuffTip() then
		if self.ui:getChildByName('prebuff') then
			self.ui:getChildByName('prebuff'):removeFromParentAndCleanup(true)
		end
	else
		if self.ui:getChildByName('prebuff') then

			local grade, _, description = PreBuffLogic:getBuffInfos()

			local style = PreBuffLogic:getStyle() or 1


			local targetIconGroup = 'icon00' .. style

			for k = 1, 2 do
				local otherIconGroup = 'icon00' .. k
				local iconLayer = self.ui:getChildByName('prebuff'):getChildByName(otherIconGroup)
				if otherIconGroup == targetIconGroup then
					iconLayer:removeChildren(true)
					local UIHelper = require 'zoo.panel.UIHelper'
					local iconSpriteFrame = 'prebuff_icon_res/sp/' .. description .. '0000'
					local icon = UIHelper:createSpriteFrame('ui/prebuff_icons.json', iconSpriteFrame)
					if icon then
						iconLayer:addChild(icon)
						icon:setAnchorPoint(ccp(0, 1))
						icon:setPositionY(20)
						icon:setScale(0.8)
					end
				else
					iconLayer:removeFromParentAndCleanup(true)
				end
			end
		end
	end
end

function QuitPanel:initButtons( uiType )

    for k,v in pairs(ButtonUIType) do
        if v == uiType then

            self.settingUIModule = self.ui:getChildByName( v )

            self.musicBtn       = self.settingUIModule:getChildByName("musicBtn")
            self.soundBtn       = self.settingUIModule:getChildByName("soundBtn")
            self.notificationBtn        = self.settingUIModule:getChildByName("notificationBtn")
            

            self.musicBtnTip    = self.settingUIModule:getChildByName("musicBtnTip")
            self.soundBtnTip    = self.settingUIModule:getChildByName("soundBtnTip")
            self.notificationBtnTip = self.settingUIModule:getChildByName("notificationBtnTip")
            

            -- Set Music / Effect Pause Icon 
            if GamePlayMusicPlayer:getInstance().IsMusicOpen then
                self.soundBtn:getChildByName("disable"):setVisible(false)
                self.soundBtn:getChildByName("enable"):setVisible(true)
            end

            if GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen then
                self.musicBtn:getChildByName("disable"):setVisible(false)
                self.musicBtn:getChildByName("enable"):setVisible(true)
            end

            if CCUserDefault:sharedUserDefault():getBoolForKey("game.local.notification") then
                self.notificationBtn:getChildByName("disable"):setVisible(false)
                self.notificationBtn:getChildByName("enable"):setVisible(true)
            end


            local function onMusicBtnTapped()
                self:onMusicBtnTapped()
            end

            local function onSoundBtnTapped()
                self:onSoundBtnTapped()
            end

            local function onNotificationBtnTapped()
                self:onNotificationBtnTapped()
            end

            local function onSpeedBtnTapped()
                self:onSpeedBtnTapped()
            end


            self.musicBtn:setButtonMode(true)
            self.musicBtn:setTouchEnabled(true)
            self.musicBtn:addEventListener(DisplayEvents.kTouchTap, onMusicBtnTapped)

            self.soundBtn:setButtonMode(true)
            self.soundBtn:setTouchEnabled(true)
            self.soundBtn:addEventListener(DisplayEvents.kTouchTap, onSoundBtnTapped)

            self.notificationBtn:setButtonMode(true)
            self.notificationBtn:setTouchEnabled(true)
            self.notificationBtn:addEventListener(DisplayEvents.kTouchTap, onNotificationBtnTapped)


            if v == ButtonUIType.kNormal then
            	self.tips = {self.soundBtnTip, self.musicBtnTip, self.notificationBtnTip, self.wifiAutoDownlloadTip }
            elseif v == ButtonUIType.kWithSpeedUp then
                self.speedBtn        = self.settingUIModule:getChildByName("speedBtn")
                self.speedBtnTip = self.settingUIModule:getChildByName("speedBtnTip")

                local speedSwitch = GameSpeedManager:getGameSpeedSwitch()
            	self:updateSpeedButton( speedSwitch , true )

                self.tips = {self.soundBtnTip, self.musicBtnTip, self.notificationBtnTip, self.wifiAutoDownlloadTip , self.speedBtnTip}

                self.speedBtn:setButtonMode(true)
	            self.speedBtn:setTouchEnabled(true)
	            self.speedBtn:addEventListener(DisplayEvents.kTouchTap, onSpeedBtnTapped)
            end
        else
            local uiModule = self.ui:getChildByName( v )
            if uiModule then
                uiModule:removeFromParentAndCleanup(true)
            end
        end
    end
end


function QuitPanel:onSpeedBtnTapped(...)
    local speedSwitch = GameSpeedManager:getGameSpeedSwitch()
    local fpsWarning = GameSpeedManager:getFPSWarningTipFlag()

    local function doChange()
    	if type(speedSwitch) ~= "number" then speedSwitch = 0 end
	    speedSwitch = speedSwitch + 1
	    if speedSwitch > 2 then speedSwitch = 0 end
	    GameSpeedManager:setGameSpeedSwitch( speedSwitch )
	    self:updateSpeedButton( speedSwitch )
    end
    
    if fpsWarning then

        local text = {
            tip = Localization:getInstance():getText("game.speed.manager.fpsWarning.tipText"),
            yes = Localization:getInstance():getText("game.speed.manager.fpsWarning.tipbtn.yes"),
            no = Localization:getInstance():getText("game.speed.manager.fpsWarning.tipbtn.no"),
        }

        CommonTipWithBtn:showTip( text , "negative" , doChange , nil )
    else
        doChange()
    end
    
end

function QuitPanel:updateSpeedButton( level , donotShowTip )
    if type(level) ~= "number" then level = 0 end
    local uiLevel = level + 1
    for i = 1 , 3 do
        if uiLevel == i then
            self.speedBtn:getChildByName( "level_" .. tostring(i) ):setVisible(true)
        else
            self.speedBtn:getChildByName( "level_" .. tostring(i) ):setVisible(false)
        end
    end

    if not donotShowTip then
    	self.speedBtnTip:setString(Localization:getInstance():getText("game.setting.panel.speed.changed." .. tostring(uiLevel) )  )
    	self:playShowHideLabelAnim(self.speedBtnTip)
    end
end

function QuitPanel:noPrebuffTip()
	self.hasPreBuff = GameInitBuffLogic:hasInitBuffFromPreBuffAct()
	if not self.hasPreBuff or 
		not PreBuffLogic:isActOn() or
		(UserCallbackManager.getInstance():isActivitySupport() and 
		UserCallbackManager.getInstance():getBuffLeftSeconds() > 0) then 
		return true
	end
	return false 
end

function QuitPanel:onBtn1Tapped(event, ...)
	assert(#{...} == 0)

	if self.mode == QuitPanelMode.QUIT_LEVEL then

		if self.btnTappedState == self.BTN_TAPPED_STATE_NONE then
			self.btnTappedState = self.BTN_TAPPED_STATE_BTN1_TAPPED
		else
			return
		end

		self:onReplayBtnTapped(event)

	elseif self.mode == QuitPanelMode.QUIT_GAME then
		-- Help , Do Nothing
	else
		assert(false)
	end
end

function QuitPanel:onBtn2Tapped(event, ...)
	assert(#{...} == 0)

	if self.btnTappedState == self.BTN_TAPPED_STATE_NONE then
		self.btnTappedState = self.BTN_TAPPED_STATE_BTN2_TAPPED
	else
		return
	end

	if self.mode == QuitPanelMode.QUIT_LEVEL or self.mode == QuitPanelMode.NO_REPLAY then
		
		self:onQuitGameBtnTapped()
	elseif self.mode == QuitPanelMode.QUIT_GAME then
		if __ANDROID then
			require "zoo.platform.VivoPlatform"
			VivoPlatform:onEnd()
		end
		CCDirector:sharedDirector():endToLua()
		--self:onQuitGameBtnTapped()
	else
		assert(false)
	end
end

function QuitPanel:onMusicBtnTapped(...)	

	if GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen then
		GamePlayMusicPlayer:getInstance():pauseBackgroundMusic()
		self.musicBtn:getChildByName("disable"):setVisible(true) 
		self.musicBtn:getChildByName("enable"):setVisible(false) 
		self.musicBtnTip:setString(Localization:getInstance():getText("game.setting.panel.music.close.tip"))
	else
		GamePlayMusicPlayer:getInstance():resumeBackgroundMusic()
		self.musicBtn:getChildByName("disable"):setVisible(false) 
		self.musicBtn:getChildByName("enable"):setVisible(true) 
		self.musicBtnTip:setString(Localization:getInstance():getText("game.setting.panel.music.open.tip"))
	end

	self:playShowHideLabelAnim(self.musicBtnTip)
end


function QuitPanel:onSoundBtnTapped(...)
	if GamePlayMusicPlayer:getInstance().IsMusicOpen then
		GamePlayMusicPlayer:getInstance():pauseSoundEffects()
		self.soundBtn:getChildByName("disable"):setVisible(true) 
		self.soundBtn:getChildByName("enable"):setVisible(false) 
		self.soundBtnTip:setString(Localization:getInstance():getText("game.setting.panel.sound.close.tip"))
	else
		GamePlayMusicPlayer:getInstance():resumeSoundEffects()
		self.soundBtn:getChildByName("disable"):setVisible(false) 
		self.soundBtn:getChildByName("enable"):setVisible(true) 
		self.soundBtnTip:setString(Localization:getInstance():getText("game.setting.panel.sound.open.tip"))
	end

	self:playShowHideLabelAnim(self.soundBtnTip)
end

function QuitPanel:onNotificationBtnTapped(...)
	if _G.isLocalDevelopMode then printx(0, "GameSettingPanel:onNotificationBtnTapped Called !") end
	--if ConfigSavedToFile:sharedInstance().configTable.gameSettingPanel_isNotificationEnable then
	if not CCUserDefault:sharedUserDefault():getBoolForKey("game.local.notification") then
		--ConfigSavedToFile:sharedInstance().configTable.gameSettingPanel_isNotificationEnable = false
		CCUserDefault:sharedUserDefault():setBoolForKey("game.local.notification", true)
		self.notificationBtnTip:setString(Localization:getInstance():getText("game.setting.panel.notification.open.tip"))
		self.notificationBtn:getChildByName("disable"):setVisible(false) 
		self.notificationBtn:getChildByName("enable"):setVisible(true) 
	else
		--ConfigSavedToFile:sharedInstance().configTable.gameSettingPanel_isNotificationEnable = true
		CCUserDefault:sharedUserDefault():setBoolForKey("game.local.notification", false)
		self.notificationBtnTip:setString(Localization:getInstance():getText("game.setting.panel.notification.close.tip"))
		self.notificationBtn:getChildByName("disable"):setVisible(true) 
		self.notificationBtn:getChildByName("enable"):setVisible(false) 
	end

	self:playShowHideLabelAnim(self.notificationBtnTip)
	--ConfigSavedToFile:sharedInstance():serialize()
	CCUserDefault:sharedUserDefault():flush()
end


function QuitPanel:playShowHideLabelAnim(labelToControl, ...)

	local delayTime	= 3

	labelToControl:stopAllActions()

	local function showFunc()
		-- Hide All Tip
		for k,v in pairs(self.tips) do
			v:setVisible(false)
		end

		labelToControl:setVisible(true)
	end
	local showAction = CCCallFunc:create(showFunc)


	local delay	= CCDelayTime:create(delayTime)


	local function hideFunc()
		labelToControl:setVisible(false)
	end
	local hideAction = CCCallFunc:create(hideFunc)

	local actionArray = CCArray:create()
	actionArray:addObject(showAction)
	actionArray:addObject(delay)
	actionArray:addObject(hideAction)

	local seq = CCSequence:create(actionArray)
	--return seq
	
	labelToControl:runAction(seq)
end

function QuitPanel:onCloseBtnTapped(event, ...)
	assert(#{...} == 0)

	he_log_warning("this kind of panel pop remove anim can reused.")
	he_log_warning("reform needed !")

	GameGuide:sharedInstance():onGuideComplete()

	AdvertiseSDK:dismissDomobAD()

	local function animFinished()
		self.allowBackKeyTap = false
		PopoutManager:sharedInstance():remove(self, true)

		if self.onClosePanelBtnTappedCallback then
			self.onClosePanelBtnTappedCallback()
		end
	end

	self:playHideAnim(animFinished)
end

function QuitPanel:onReplayBtnTapped(event, ...)
	assert(#{...} == 0)

	local function hideAnimCallback()
		PopoutManager:sharedInstance():remove(self, true)

		if self.onReplayBtnTappedCallback then
			self.onReplayBtnTappedCallback()
		end
	end

	AdvertiseSDK:dismissDomobAD()

	self:playHideAnim(hideAnimCallback)
end

function QuitPanel:onQuitGameBtnTapped(event, ...)
	assert(#{...} == 0)
	Notify:dispatch("QuitNextLevelModeEvent", true)

	AdvertiseSDK:dismissDomobAD()
	
	PopoutManager:sharedInstance():remove(self, true)
	
	if self.onQuitGameBtnTappedCallback then
		self.onQuitGameBtnTappedCallback()
	end
	he_log_info("auto_test_tap_quit_level")
end

function QuitPanel:onEnterHandler(event, ...)
	assert(#{...} == 0)
	if event == "enter" then
		self.allowBackKeyTap = true
		self:playShowAnim(false)
	end
	BasePanel.onEnterHandler(self, event, ...)
end

function QuitPanel:createShowAnim(...)
	assert(#{...} == 0)

	he_log_warning("this show Anim is common to a type of panel !!!")
	he_log_warning("reform needed !")


	local centerPosX 	= self:getHCenterInParentX()
	local centerPosY	= self:getVCenterInParentY()
	if self.hasPreBuff then
		centerPosY = centerPosY - 150
	end

	---- Fade In Anim
	--for k,child in ipairs(self.panelChildren) do
	--	local fadeIn 		= CCFadeIn:create(0.5)
	--	local targetedAction 	= CCTargetedAction:create(child.refCocosObj, fadeIn)
	--	actionArray:addObject(targetedAction)
	--end


	local function initActionFunc()

		local initPosX	= centerPosX
		local initPosY	= centerPosY + 100
		self:setPosition(ccp(initPosX, initPosY))
	end
	local initAction = CCCallFunc:create(initActionFunc)

	-- Move To Center Anim
	local moveToCenter		= CCMoveTo:create(0.5, ccp(centerPosX, centerPosY))
	local backOut 			= CCEaseQuarticBackOut:create(moveToCenter, 33, -106, 126, -67, 15)
	local targetedMoveToCenter	= CCTargetedAction:create(self.refCocosObj, backOut)

	-- Action Array
	local actionArray = CCArray:create()
	actionArray:addObject(initAction)
	actionArray:addObject(targetedMoveToCenter)

	-- Seq
	local seq = CCSequence:create(actionArray)
	return seq

	--local spawn = CCSpawn:create(actionArray)
	--return spawn
end

--function QuitPanel:createHideAnim(...)
--	assert(#{...} == 0)
--
--	local actionArray = CCArray:create()
--
--	local centerPosX = self:getHCenterInParentX()
--	local centerPosY = self:getVCenterInParentY()
--
--	-- Fade Out Anim
--	for k,child in ipairs(self.panelChildren) do
--		local fadeOut		= CCFadeOut:create(0.5)
--		local targetedAction	= CCTargetedAction:create(child.refCocosObj, fadeOut)
--		actionArray:addObject(targetedAction)
--	end
--	
--	local curPosX 		= self:getPositionX()
--	local curPosY 		= self:getPositionY()
--	local newPosY		= curPosY
--	local moveDown 		= CCMoveTo:create(0.2, ccp(curPosX, newPosY))
--	local targetedMoveDown	= CCTargetedAction:create(self.refCocosObj, moveDown)
--	actionArray:addObject(targetedMoveDown)
--
--	local spawn = CCSpawn:create(actionArray)
--	return spawn
--end

function QuitPanel:playShowAnim(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	local showAnim 	= self:createShowAnim()

	local function finishCallback()
		if animFinishCallback then
			animFinishCallback()
		end
		he_log_info("auto_test_quit_panel_open")
	end
	local callbackAction = CCCallFunc:create(finishCallback)

	local seq = CCSequence:createWithTwoActions(showAnim, callbackAction)
	self:runAction(seq)
end

function QuitPanel:playHideAnim(animFinishCallback, ...)
	assert(type(animFinishCallback) == "function")
	assert(#{...} == 0)

	--local hideAnim = self:createHideAnim()
	--local callbackAction = CCCallFunc:create(animFinishCallback)

	--local seq = CCSequence:createWithTwoActions(hideAnim, callbackAction)
	--self:runAction(seq)
	
	animFinishCallback()
end

function QuitPanel:setOnReplayBtnTappedCallback(onReplayBtnTappedCallback, ...)
	assert(type(onReplayBtnTappedCallback) == "function")
	assert(#{...} == 0)

	self.onReplayBtnTappedCallback = onReplayBtnTappedCallback
end

function QuitPanel:setOnClosePanelBtnTapped(onClosePanelBtnTappedCallback, ...)
	assert(type(onClosePanelBtnTappedCallback) == "function")
	assert(#{...} == 0)

	self.onClosePanelBtnTappedCallback = onClosePanelBtnTappedCallback
end

function QuitPanel:setOnQuitGameBtnTappedCallback(onQuitGameBtnTappedCallback, ...)
	assert(type(onQuitGameBtnTappedCallback) == "function")
	assert(#{...} == 0)

	self.onQuitGameBtnTappedCallback = onQuitGameBtnTappedCallback
end

function QuitPanel:setOnPassLevelTappedCallback(callback)
	self._PassLevelTappedCallback = callback
end

function QuitPanel:setFailGameTappedCallback(callback)
	self._FailGameTappedCallback = callback
end

function QuitPanel:setAddScoreTappedCallback(callback)
	self._AddScoreTappedCallback = callback
end

function QuitPanel:setAddTargetTappedCallback(callback)
	self._AddTargetTappedCallback = callback
end

function QuitPanel:setUseUpMovesTappedCallback(callback)
	self._UseUpMovesTappedCallback = callback
end

function QuitPanel:setWhiteListUser(value)
	if value then
		local label = TextField:create("白名单用户", nil, 40)
		label:setColor(ccc3(190, 190, 190))
		label:setPosition(ccp(320, -120))
		self:addChild(label)
	end
end

function QuitPanel:create(quitPanelMode, boardLogic)
	checkQuitPanelMode(quitPanelMode)
	-- assert(#{...} == 0)

	local newQuitPanel = QuitPanel.new()
	newQuitPanel:loadRequiredResource(PanelConfigFiles.panel_game_setting)
	newQuitPanel:init(quitPanelMode, boardLogic)
	return newQuitPanel
end

function QuitPanel:_createTestButton(text, color, fntSize, width, height)
	color = color or ccc3(64,64,64)
	width = width or 80
	height = height or 50
	local btn = LayerColor:createWithColor(color, width, height)
	btn:setTouchEnabled(true, 0, true)
	-- btn:setOpacity(255 * 0.9)
	btn:addEventListener(DisplayEvents.kTouchTap, function(evt)
		btn:stopAllActions()
		btn:setOpacity(255)
		btn:runAction(CCSequence:createWithTwoActions(CCFadeTo:create(0.1, 255*0.5), CCFadeTo:create(0.2, 255)))
		end)

	fntSize = fntSize or 30
	local label = TextField:create(tostring(text), nil, fntSize)
	label:setColor(ccc3(255 - color.r, 255 - color.g, 255 - color.b))
	label:setAnchorPoint(ccp(0.5,0.5))
	label:setPositionX(width/2)
	label:setPositionY(height/2)
	btn.label = label
	btn:addChild(label)

	return btn
end

function QuitPanel:showDebugButton()
	if not self.debugButton then
		local function onclick()
			if self.debugPanel then
				self.debugPanel:removeFromParentAndCleanup(true)
				self.debugPanel = nil
			else
				local panel = DebugPanel:create(self)
				panel:setPosition(ccp(0, -80))
				self:addChild(panel)
				self.debugPanel = panel
			end
		end

		local button = QuitPanel:_createTestButton("测试集合", hex2ccc3("FFFF22"), 32, 140, 60)
		button:setPosition(ccp(12, -73))
		button:addEventListener(DisplayEvents.kTouchTap, onclick)
		self:addChild(button)
		self.debugButton = button
	end
end

function QuitPanel:onAtlasBtnTapped()
	if not self.boardLogic or not self.boardLogic.guideAtlas then return end
	DcUtil:UserTrack({category = 'newplayer', sub_category = 'book_enter'})
	local panel = GuideAtlasPanel:create(self.boardLogic.guideAtlas, self.boardLogic.level)
	panel:popout()

	CCUserDefault:sharedUserDefault():setBoolForKey(self:getClkBlockerDescKey(), true)
	if self.atlasBtnRedDot ~= nil and
	   not self.atlasBtnRedDot.isDisposed and
	   self.atlasBtnRedDot:getParent() ~= nil then
	   self.atlasBtnRedDot:removeFromParentAndCleanup(true)
	   self.atlasBtnRedDot = nil
	end
end

function QuitPanel:getClkBlockerDescKey( ... )
	if self.boardLogic ~= nil then
		local uid = UserManager:getInstance():getUID()
		return CLK_BLOCKER_DESC_KEY .. uid .. "l" .. self.boardLogic.level
	else
		return CLK_BLOCKER_DESC_KEY .. "testLevel"
	end
end

function QuitPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
end
