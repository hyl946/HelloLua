require "zoo.baseUI.ButtonWithShadow"
require "zoo.panel.component.quitPanel.QuitPanelButton"

local LevelStrategyPausePanel = class(BasePanel)
function LevelStrategyPausePanel:init()
	self.ui	= self:buildInterfaceGroup("strategy_replay/StrategyPausePanel")
	BasePanel.init(self, self.ui)

	self.onReplayBtnTappedCallback		= false
	self.onQuitGameBtnTappedCallback	= false
	self.onClosePanelBtnTappedCallback	= false

	self.musicBtn		= self.ui:getChildByName("musicBtn")
	self.soundBtn		= self.ui:getChildByName("effectBtn")
	self.panelTitle		= self.ui:getChildByName("panelTitle")

	self.btn1Res		= self.ui:getChildByName("button1")
	self.btn2Res		= self.ui:getChildByName("button2")
	self.closeBtn		= self.ui:getChildByName("closeBtn")

	self.soundBtnTip	= self.ui:getChildByName("soundBtnTip")
	self.musicBtnTip	= self.ui:getChildByName("musicBtnTip")

	self.tips	= {self.soundBtnTip, self.musicBtnTip}
	self.bg = self.ui:getChildByName("_newBg")

	self.btn1	= ButtonIconsetBase:create(self.btn1Res)
	self.btn2	= ButtonIconsetBase:create(self.btn2Res)

	self.btn1:setColorMode(kGroupButtonColorMode.blue)
	self.btn2:setColorMode(kGroupButtonColorMode.orange)
	self.btn1:useBubbleAnimation()
	self.btn2:useBubbleAnimation()

	if GamePlayMusicPlayer:getInstance().IsMusicOpen then
		self.soundBtn:getChildByName("disable"):setVisible(false) 
		self.soundBtn:getChildByName("enable"):setVisible(true) 
	else
		self.soundBtn:getChildByName("disable"):setVisible(true) 
		self.soundBtn:getChildByName("enable"):setVisible(false) 
	end

	if GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen then
		self.musicBtn:getChildByName("disable"):setVisible(false) 
		self.musicBtn:getChildByName("enable"):setVisible(true) 
	else
		self.musicBtn:getChildByName("disable"):setVisible(true) 
		self.musicBtn:getChildByName("enable"):setVisible(false) 
	end

	self.panelTitle:setText(localize("quit.panel.pause"))
	local size = self.panelTitle:getContentSize()
	local scale = 65 / size.height
	self.panelTitle:setScale(scale)
	self.panelTitle:setPositionX((self.bg:getGroupBounds().size.width - size.width * scale) / 2)

	self.btn1:setString(localize("strategy.playback1"))
	self.btn1:setIconByFrameName("gamesetting_replay0000")

	self.btn2:setString(localize("strategy.playback2"))
	self.btn2:setIconByFrameName("gamesetting_quit0000")

	self.musicBtn:setButtonMode(true)
	self.musicBtn:setTouchEnabled(true)
	self.musicBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onMusicBtnTapped()
	end)

	self.soundBtn:setButtonMode(true)
	self.soundBtn:setTouchEnabled(true)
	self.soundBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onSoundBtnTapped()
	end)

	self.btn1:addEventListener(DisplayEvents.kTouchTap, function (event)
		self:onReplayBtnTapped(event)
	end)

	self.btn2:addEventListener(DisplayEvents.kTouchTap, function (event)
		self:onQuitGameBtnTapped(event)
	end)

	self.closeBtn:setTouchEnabled(true, 0, true)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function (event)
		self:onCloseBtnTapped(event)
	end)
end

function LevelStrategyPausePanel:onMusicBtnTapped()	
	if GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen then
		GamePlayMusicPlayer:getInstance():pauseBackgroundMusic()
		self.musicBtn:getChildByName("disable"):setVisible(true) 
		self.musicBtn:getChildByName("enable"):setVisible(false) 
		self.musicBtnTip:setString(localize("game.setting.panel.music.close.tip"))
	else
		GamePlayMusicPlayer:getInstance():resumeBackgroundMusic()
		self.musicBtn:getChildByName("disable"):setVisible(false) 
		self.musicBtn:getChildByName("enable"):setVisible(true) 
		self.musicBtnTip:setString(localize("game.setting.panel.music.open.tip"))
	end

	self:playShowHideLabelAnim(self.musicBtnTip)
end


function LevelStrategyPausePanel:onSoundBtnTapped()
	if GamePlayMusicPlayer:getInstance().IsMusicOpen then
		GamePlayMusicPlayer:getInstance():pauseSoundEffects()
		self.soundBtn:getChildByName("disable"):setVisible(true) 
		self.soundBtn:getChildByName("enable"):setVisible(false) 
		self.soundBtnTip:setString(localize("game.setting.panel.sound.close.tip"))
	else
		GamePlayMusicPlayer:getInstance():resumeSoundEffects()
		self.soundBtn:getChildByName("disable"):setVisible(false) 
		self.soundBtn:getChildByName("enable"):setVisible(true) 
		self.soundBtnTip:setString(localize("game.setting.panel.sound.open.tip"))
	end

	self:playShowHideLabelAnim(self.soundBtnTip)
end


function LevelStrategyPausePanel:playShowHideLabelAnim(labelToControl)
	local delayTime	= 3
	labelToControl:stopAllActions()

	local function showFunc()
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
	labelToControl:runAction(seq)
end

function LevelStrategyPausePanel:onCloseBtnTapped(event)
	AdvertiseSDK:dismissDomobAD()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)

	if self.onClosePanelBtnTappedCallback then
		self.onClosePanelBtnTappedCallback()
	end
end

function LevelStrategyPausePanel:onReplayBtnTapped(event)
	AdvertiseSDK:dismissDomobAD()
	PopoutManager:sharedInstance():remove(self, true)

	if self.onReplayBtnTappedCallback then
		self.onReplayBtnTappedCallback()
	end
end

function LevelStrategyPausePanel:onQuitGameBtnTapped(event)
	AdvertiseSDK:dismissDomobAD()
	PopoutManager:sharedInstance():remove(self, true)
	
	if self.onQuitGameBtnTappedCallback then
		self.onQuitGameBtnTappedCallback()
	end
end

function LevelStrategyPausePanel:onEnterHandler(event)
	if event == "enter" then
		self.allowBackKeyTap = true
		self:playShowAnim(false)
	end
end

function LevelStrategyPausePanel:createShowAnim()
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

function LevelStrategyPausePanel:playShowAnim(animFinishCallback)
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

function LevelStrategyPausePanel:setOnReplayBtnTappedCallback(onReplayBtnTappedCallback)
	self.onReplayBtnTappedCallback = onReplayBtnTappedCallback
end

function LevelStrategyPausePanel:setOnClosePanelBtnTapped(onClosePanelBtnTappedCallback)
	self.onClosePanelBtnTappedCallback = onClosePanelBtnTappedCallback
end

function LevelStrategyPausePanel:setOnQuitGameBtnTappedCallback(onQuitGameBtnTappedCallback)
	self.onQuitGameBtnTappedCallback = onQuitGameBtnTappedCallback
end

function LevelStrategyPausePanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
end

function LevelStrategyPausePanel:create()
	local panel = LevelStrategyPausePanel.new()
	panel:loadRequiredResource(PanelConfigFiles.panel_game_setting)
	panel:init()
	return panel
end

return LevelStrategyPausePanel