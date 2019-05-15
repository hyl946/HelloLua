JumpLevelIcon = class()
require "zoo.panel.jumpLevel.JumpLevelPanel"
function JumpLevelIcon:create( ui, levelId, levelType, parentPanel, isFakeIcon , parentPanelFail)
	-- body
	local s = JumpLevelIcon.new()
	s:init(ui, levelId, levelType, parentPanel, isFakeIcon,parentPanelFail)
	return s
end

function JumpLevelIcon:setJumpCallBack( onTappedCallBack )
	self.onTappedCallBack = onTappedCallBack
end

function JumpLevelIcon:init( ui, levelId, levelType, parentPanel, isFakeIcon,parentPanelFail)
	-- body
	self.ui = ui
	self.levelId = levelId
	self.levelType = levelType
	self.parentPanel = parentPanel
	self.parentPanelFail = parentPanelFail
	self.isFakeIcon = isFakeIcon
	local function onTapped(evt)
		if self.onTappedCallBack then 
			self.onTappedCallBack()
		else
			self:onTapped()
		end
	end

	local function onTouchOutSide(evt)
		printx( 100 , "   JumpLevelIcon :onTapped onTouchOutSide  onTouchOutSide " )

		if self.parentPanel and not self.parentPanel.isDisposed and self.parentPanel.closeTwoBtnAction then
			self.parentPanel:closeTwoBtnAction()
		end
		if self.parentPanelFail and not self.parentPanelFail.isDisposed and self.parentPanelFail.closeTwoBtnAction then
			self.parentPanelFail:closeTwoBtnAction()
		end
	end
	ui:setTouchEnabledWithMoveInOut(true, 0, false)
	ui:addEventListener(DisplayEvents.kTouchBeginOutSide, onTouchOutSide)
	ui:addEventListener(DisplayEvents.kTouchBegin, onTapped)
	


	ui:setTouchEnabled(true, 0, true)
end

function JumpLevelIcon:setEnabled(value)
	self.ui:setTouchEnabled(value)
end

function JumpLevelIcon:onTapped( ... )
	
	if self.isFakeIcon then
		CommonTip:showTip(localize('skipLevel.tips9', {replace1 = 40}), 'positive')
		return
	end
	-- body
	local function onSuccess( data )
		-- body
		local pawnNum = 0
		if data.data and data.data.pawnNum then
			pawnNum = data.data.pawnNum
		end
		local level_reward = MetaManager.getInstance():getLevelRewardByLevelId(self.levelId)
		if level_reward and level_reward.skipLevel ~= pawnNum then
			level_reward.skipLevel = pawnNum
		end
		if pawnNum > 0 then
			if self.parentPanel and not self.parentPanel.isDisposed then
				self.parentPanel:recordCallback()
				self.parentPanel:onCloseBtnTapped()
			end
			local isStartGamePanel = (self.parentPanel and self.parentPanel:is(LevelInfoPanel))
			local s = JumpLevelPanel:create(self.levelId, self.levelType, isStartGamePanel)
			s:popout()
		else
			CommonTip:showTip(Localization:getInstance():getText("skipLevel.tips11"), "negative")
			self.ui:removeFromParentAndCleanup(true)
		end
		
	end

	local function onFail( err )
		local err_code = tonumber(err.data or 0) 
		CommonTip:showTip(localize('error.tip.'..err_code), "negative",nil, 2)
	end

	local http = GetLevelPawnNumHttp.new(true)
	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)
	http:load(self.levelId)
	
end
