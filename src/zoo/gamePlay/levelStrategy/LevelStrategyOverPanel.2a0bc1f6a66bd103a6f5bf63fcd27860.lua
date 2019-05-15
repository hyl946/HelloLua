require "zoo.baseUI.ButtonWithShadow"
require "zoo.panel.component.quitPanel.QuitPanelButton"

local LevelStrategyOverPanel = class(BasePanel)
function LevelStrategyOverPanel:init()
	self.ui	= self:buildInterfaceGroup("strategy_replay/StrategyOverPanel")
	BasePanel.init(self, self.ui)

	self.onReplayBtnTappedCallback		= false
	self.onQuitGameBtnTappedCallback	= false

	self.panelTitle		= self.ui:getChildByName("panelTitle")

	self.btn1Res		= self.ui:getChildByName("button1")
	self.btn2Res		= self.ui:getChildByName("button2")
	self.closeBtn		= self.ui:getChildByName("closeBtn")

	self.tip	= self.ui:getChildByName("tip")
	self.tip:setString(localize("strategy.playback3", {n = '\n'}))

	self.bg = self.ui:getChildByName("_newBg")

	self.btn1	= ButtonIconsetBase:create(self.btn1Res)
	self.btn2	= ButtonIconsetBase:create(self.btn2Res)

	self.btn1:setColorMode(kGroupButtonColorMode.blue)
	self.btn2:setColorMode(kGroupButtonColorMode.orange)
	self.btn1:useBubbleAnimation()
	self.btn2:useBubbleAnimation()

	self.panelTitle:setText(localize("strategy.playback4"))
	local size = self.panelTitle:getContentSize()
	local scale = 65 / size.height
	self.panelTitle:setScale(scale)
	self.panelTitle:setPositionX((self.bg:getGroupBounds().size.width - size.width * scale) / 2)

	self.btn1:setString(localize("strategy.playback5"))
	self.btn1:setIconByFrameName("gamesetting_replay0000")

	self.btn2:setString(localize("strategy.playback6"))
	self.btn2:setIconByFrameName("gamesetting_quit0000")

	self.btn1:addEventListener(DisplayEvents.kTouchTap, function (event)
		self:onReplayBtnTapped(event)
	end)

	self.btn2:addEventListener(DisplayEvents.kTouchTap, function (event)
		self:onQuitGameBtnTapped(event)
	end)
end

function LevelStrategyOverPanel:onReplayBtnTapped(event)
	AdvertiseSDK:dismissDomobAD()
	PopoutManager:sharedInstance():remove(self, true)

	if self.onReplayBtnTappedCallback then
		self.onReplayBtnTappedCallback()
	end
end

function LevelStrategyOverPanel:onQuitGameBtnTapped(event)
	AdvertiseSDK:dismissDomobAD()
	PopoutManager:sharedInstance():remove(self, true)
	
	if self.onQuitGameBtnTappedCallback then
		self.onQuitGameBtnTappedCallback()
	end
end

function LevelStrategyOverPanel:onEnterHandler(event)
	if event == "enter" then
		self.allowBackKeyTap = true
		self:playShowAnim(false)
	end
end

function LevelStrategyOverPanel:createShowAnim()
	local centerPosX 	= self:getHCenterInParentX()
	local centerPosY	= self:getVCenterInParentY()

	local function initActionFunc()
		local initPosX	= centerPosX
		local initPosY	= centerPosY + 100
		self:setPosition(ccp(initPosX, initPosY))
	end
	local initAction = CCCallFunc:create(initActionFunc)

	local moveToCenter		= CCMoveTo:create(0.5, ccp(centerPosX, centerPosY))
	local backOut 			= CCEaseQuarticBackOut:create(moveToCenter, 33, -106, 126, -67, 15)
	local targetedMoveToCenter	= CCTargetedAction:create(self.refCocosObj, backOut)

	local actionArray = CCArray:create()
	actionArray:addObject(initAction)
	actionArray:addObject(targetedMoveToCenter)

	local seq = CCSequence:create(actionArray)
	return seq
end

function LevelStrategyOverPanel:playShowAnim(animFinishCallback)
	local showAnim 	= self:createShowAnim()

	local function finishCallback()
		if animFinishCallback then
			animFinishCallback()
		end
	end
	local callbackAction = CCCallFunc:create(finishCallback)

	local seq = CCSequence:createWithTwoActions(showAnim, callbackAction)
	self:runAction(seq)
end

function LevelStrategyOverPanel:setOnReplayBtnTappedCallback(onReplayBtnTappedCallback)
	self.onReplayBtnTappedCallback = onReplayBtnTappedCallback
end

function LevelStrategyOverPanel:setOnQuitGameBtnTappedCallback(onQuitGameBtnTappedCallback)
	self.onQuitGameBtnTappedCallback = onQuitGameBtnTappedCallback
end

function LevelStrategyOverPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
end

function LevelStrategyOverPanel:create()
	local panel = LevelStrategyOverPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.panel_game_setting)
	panel:init()
	return panel
end

return LevelStrategyOverPanel