require "zoo.baseUI.ButtonWithShadow"
require "zoo.panel.component.quitPanel.QuitPanelButton"

local LevelStrategyErrorPanel = class(BasePanel)
function LevelStrategyErrorPanel:init()
	self.ui	= self:buildInterfaceGroup("strategy_replay/StrategyErrorPanel")
	BasePanel.init(self, self.ui)

	self.onReplayBtnTappedCallback		= false
	self.onQuitGameBtnTappedCallback	= false

	self.panelTitle		= self.ui:getChildByName("panelTitle")

	self.btn1Res		= self.ui:getChildByName("button1")
	self.btn2Res		= self.ui:getChildByName("button2")
	self.closeBtn		= self.ui:getChildByName("closeBtn")

	self.tip	= self.ui:getChildByName("tip")
	self.tip:setString(localize("strategy.playback10"))

	self.bg = self.ui:getChildByName("_newBg")

	self.btn1	= ButtonIconsetBase:create(self.btn1Res)
	self.btn1:setColorMode(kGroupButtonColorMode.blue)
	self.btn1:useBubbleAnimation()

	self.panelTitle:setText(localize("quit.panel.pause"))
	local size = self.panelTitle:getContentSize()
	local scale = 65 / size.height
	self.panelTitle:setScale(scale)
	self.panelTitle:setPositionX((self.bg:getGroupBounds().size.width - size.width * scale) / 2)

	self.btn1:setString(localize("strategy.playback7"))
	self.btn1:setIconByFrameName("gamesetting_quit0000")

	self.btn1:addEventListener(DisplayEvents.kTouchTap, function (event)
		self:onQuitGameBtnTapped(event)
	end)
end

function LevelStrategyErrorPanel:onQuitGameBtnTapped(event)
	AdvertiseSDK:dismissDomobAD()
	PopoutManager:sharedInstance():remove(self, true)
	
	if self.onQuitGameBtnTappedCallback then
		self.onQuitGameBtnTappedCallback()
	end
end

function LevelStrategyErrorPanel:onEnterHandler(event)
	if event == "enter" then
		self.allowBackKeyTap = true
		self:playShowAnim(false)
	end
end

function LevelStrategyErrorPanel:createShowAnim()
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

function LevelStrategyErrorPanel:playShowAnim(animFinishCallback)
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

function LevelStrategyErrorPanel:setOnQuitGameBtnTappedCallback(onQuitGameBtnTappedCallback)
	self.onQuitGameBtnTappedCallback = onQuitGameBtnTappedCallback
end

function LevelStrategyErrorPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
end

function LevelStrategyErrorPanel:create()
	local panel = LevelStrategyErrorPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.panel_game_setting)
	panel:init()
	return panel
end

return LevelStrategyErrorPanel