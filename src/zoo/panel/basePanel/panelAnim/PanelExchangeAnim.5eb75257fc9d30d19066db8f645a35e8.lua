

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年10月28日 15:56:29
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com


---------------------------------------------------
-------------- PanelExchangeAnim
---------------------------------------------------

assert(not PanelExchangeAnim)
assert(PanelPopRemoveAnim)
PanelExchangeAnim = class(PanelPopRemoveAnim)

function PanelExchangeAnim:ctor()
end

function PanelExchangeAnim:init(panelToControl, ...)
	assert(panelToControl)
	assert(#{...} == 0)

	-- Init Base Class
	PanelPopRemoveAnim.init(self, panelToControl)

	-- Create Content Anim
	self.contentAnim = PanelContentAnim:create(panelToControl)
end

function PanelExchangeAnim:show(animFinishCallbck, ...)
	assert(animFinishCallbck == false or type(animFinishCallbck) == "function")
	assert(#{...} == 0)

	--------------
	-- Pop Out Panel
	-- --------------
	PopoutManager:sharedInstance():add(self.panelToControl, true, false)

	---------------
	-- Move To Initial Pos
	-- ------------------
	local initPos	= self:getPopShowPos()
	self.panelToControl:setPosition(ccp(initPos.x, initPos.y))

	-----------------
	-- Play Show Content Anim
	-- ----------------------

	-- Show Content Action
	local showContentAct = self.contentAnim:getShowContentAction()

	-- Call Back
	local function finishCallback()
		if animFinishCallbck then
			animFinishCallbck()
		end
	end
	local callbackAct = CCCallFunc:create(finishCallback)

	-- Seq
	local seq = CCSequence:createWithTwoActions(showContentAct, callbackAct)

	self.panelToControl:runAction(seq)
end

function PanelExchangeAnim:hide(animFinishCallbck, ...)
	assert(animFinishCallbck == false or type(animFinishCallbck) == "function")
	assert(#{...} == 0)

	-------------------
	-- Play Hide Content Anim
	-- -----------------------

	-- Hide Content Action
	local hideContentAct = self.contentAnim:getHideContentAction()

	-- Hide Content Action Finish Callback
	local function contentActFinishCallback()

		-- Remove Self From 
		PopoutManager:sharedInstance():remove(self.panelToControl, true)

		if animFinishCallbck then
			animFinishCallbck()
		end
	end
	local contentActCallbackAction = CCCallFunc:create(contentActFinishCallback)

	-- Seq
	local seq = CCSequence:createWithTwoActions(hideContentAct, contentActCallbackAction)

	self.panelToControl:runAction(seq)
end

function PanelExchangeAnim:create(panelToControl, ...)
	assert(panelToControl)
	assert(#{...} == 0)

	local newPanelExchangeAnim = PanelExchangeAnim.new()
	newPanelExchangeAnim:init(panelToControl)
	return newPanelExchangeAnim
end
