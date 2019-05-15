local FLGLogic = require 'zoo.panel.fullLevelGift.FLGLogic'
local UIHelper = require 'zoo.panel.UIHelper'

require 'zoo.panel.component.common.BubbleItem'

local REWARD_NUM = 2

local FLGSendPanel = class(BasePanel)

function FLGSendPanel:getAnim1( node )
	local animationInfo = {
		secondPerFrame = 0.6 / 20,
		object	= {
			node = node,
			deltaScaleX	= 180 / 81.35,
			deltaScaleY	= 180 / 81.25,
			originalScaleX	= 1,
			originalScaleY	= 1
		},

		keyFrames = {
			{ tweenType = "normal", frameIndex = 1, x = -4.10, y = 4.30,	sx = 1.097, sy = 1.097},
			{ tweenType = "normal", frameIndex = 6, x = -7.35, y = 9.0,	sx = 1.18, sy = 1.266},
			{ tweenType = "normal", frameIndex = 9, x = -9.40, y = 4.0,	sx = 1.246, sy = 1.091},
			{ tweenType = "normal", frameIndex = 11,x = -1.95, y = 1.05,	sx = 1.004, sy = 0.995},
			{ tweenType = "normal", frameIndex = 15,x = -6.60, y = 7.80,	sx = 1.162, sy = 1.195},
			{ tweenType = "normal", frameIndex = 17,x = -3.85, y = 1.70,	sx = 1.10, sy = 1,005},
			{ tweenType = "static", frameIndex = 20,x = -4.25, y = 4.20,	sx = 1.081, sy = 1.083}
		}
	}

	local bubbleAction = FlashAnimBuilder:sharedInstance():buildTimeLineAction(animationInfo)
	return bubbleAction
end


function FLGSendPanel:getAnim2( node )
	local animationInfo = {
		secondPerFrame = 1 / 24,
		object = {
			node = node,
			deltaScaleX	= 180 / 67.05,		-- Scale The The Animation Data To Match Cur Object Size
			deltaScaleY	= 180 / 67.05,			
			originalScaleX	= 1,	-- The Base To Apply The Scale
			originalScaleY	= 1
		},
		keyFrames = {
			{ tweenType = "normal",  x = -4.35, y = 4.40, sx = 1.089, sy = 1.089, frameIndex = 1},
			{ tweenType = "normal",  x = -2.60, y = 4.40, sx = 1.041, sy = 1.089, frameIndex = 11},
			{ tweenType = "normal",  x = -4.35, y = 2.70, sx = 1.089, sy = 1.054, frameIndex = 21},
			{ tweenType = "static",  x = -4.35, y = 4.40, sx = 1.089, sy = 1.089, frameIndex = 26},
		}
	}

	local bubbleAction = FlashAnimBuilder:sharedInstance():buildTimeLineAction(animationInfo)
	return bubbleAction
end

function FLGSendPanel:create()
    local panel = FLGSendPanel.new()
    panel:init()
    return panel
end

function FLGSendPanel:init()
    local ui = UIHelper:createUI("ui/full_level_gift_panel.json", "FLG/panel")
	BasePanel.init(self, ui)

	local rewards = self:getRewardsCfg() or {}


	for i = 1, REWARD_NUM do
		local rewardItem = rewards[i]
		assert(rewardItem, "FLGSendPanel: there is not proper rewards cfg")
		local rewardUI = self.ui:getChildByPath('reward_' .. i)


		if rewardItem.itemId == 10012 then
			rewardUI.holder:setAnchorPointCenterWhileStayOrigianlPosition()
			rewardUI.holder:setScale(rewardUI.holder:getScaleX() * 1.2)	
		end

		rewardUI:setRewardItem(rewardItem, true, true, 'fnt/profile2018.fnt')
		self['rewardUI_' .. i] = rewardUI


		local ___cloure = i
		UIUtils:setTouchHandler(rewardUI, function ( ... )
			if self.isDisposed then return end
			self:select(___cloure)
		end)

	end

	self:select(1)

	UIHelper:buildGroupBtn(self.ui:getChildByPath('btn'), '发红包', function ( ... )
		if self.isDisposed then return end
		self:onTapSendBtn()
	end)

	self.ui:getChildByPath('label'):setString(localize('flg.send.pane.label'))
	local friendNum = FriendManager.getInstance():getFriendCount() or 1
	self.ui:getChildByPath('bottomTxt'):setString(string.format('红包将发放给你的%d位好友', friendNum))

	-- self.ui:getChildByPath('closeBtn'):setVisible(false)

	self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
end

function FLGSendPanel:select( rewardIndex )
	if self.isDisposed then return end

	if self.curRewardIndex ~= rewardIndex then

		self.curRewardIndex = rewardIndex

		for i = 1, REWARD_NUM do
			self['rewardUI_' .. i]:getChildByPath('checked'):setVisible(i == rewardIndex)
		end
	end

end

function FLGSendPanel:onTapSendBtn( ... )
	if self.isDisposed then return end

	local rewardCfg = self:getRewardsCfg()[self.curRewardIndex]

	DcUtil:UserTrack({category='TopLevelBonus', sub_category='Gift_Send ', t1 = rewardCfg.itemId .. "_" .. rewardCfg.num})	

	FLGLogic:sendGift(rewardCfg, function ( ... )
		if self.isDisposed then return end
		CommonTip:showTip(localize('flg.send.gift.success', {
			num = FriendManager:getInstance():getFriendCount() or 1
		}), 'positive')
		self:_close()
	end, function ( ... )
		if self.isDisposed then return end
		self.ui:getChildByPath('closeBtn'):setVisible(true)
		CommonTip:showTip(localize('send.panel.nointernet.tip'))
	end, function ( ... )
		if self.isDisposed then return end
		self.ui:getChildByPath('closeBtn'):setVisible(true)
		CommonTip:showTip(localize('send.panel.nointernet.tip'))
	end)
end



function FLGSendPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function FLGSendPanel:popout()
	PopoutManager:sharedInstance():add(self, true)
	self:popoutShowTransition()
end

function FLGSendPanel:popoutPush()
	PopoutQueue:sharedInstance():push(self, true)
end

function FLGSendPanel:popoutShowTransition( ... )
	if self.isDisposed then return end
	self.allowBackKeyTap = __WIN32


	for i = 1, REWARD_NUM do
		local rewardUI = self.ui:getChildByPath('reward_' .. i)
		local action1 = self:getAnim1(rewardUI:getChildByPath('bg'))
		local array = CCArray:create()
		array:addObject(CCDelayTime:create(0.5 + i * 0.2))
		array:addObject(action1)
		array:addObject(CCCallFunc:create(function ( ... )
			if self.isDisposed then return end
			if rewardUI.isDisposed then return end
			local action2 = self:getAnim2(rewardUI:getChildByPath('bg'))
			rewardUI:getChildByPath('bg'):runAction(CCRepeatForever:create(action2))
		end))
		rewardUI:getChildByPath('bg'):runAction(CCSequence:create(array))
	end

	FLGLogic:onPopoutOutBox()
end


function FLGSendPanel:onCloseBtnTapped( ... )
	if self.isDisposed then return end
	FLGLogic:disableSend()
    self:_close()
end

function FLGSendPanel:getRewardsCfg( ... )
	local Misc = require 'zoo.quarterlyRankRace.utils.Misc'
	local cfg = Misc:parse(MetaManager:getInstance():getFullLevelGifts(), ',:')

	if #cfg >= 2 then
		return {
			{itemId = tonumber(cfg[#cfg - 1][1]) or 2, num = tonumber(cfg[#cfg - 1][2]) or 1},
			{itemId = tonumber(cfg[#cfg][1]) or 2, num = tonumber(cfg[#cfg][2]) or 1},
		}
	else
		return {
			{itemId = 2, num = 3000},
			{itemId = 10012, num = 3},
		}
	end
end


return FLGSendPanel
