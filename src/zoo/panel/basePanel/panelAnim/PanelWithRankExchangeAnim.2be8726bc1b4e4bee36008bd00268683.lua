
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年10月28日 15:50:08
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.panel.basePanel.panelAnim.PanelWithRankPopRemoveAnim"
require "zoo.panel.basePanel.panelAnim.PanelContentAnim"

---------------------------------------------------
-------------- PanelWithRankExchangeAnim
---------------------------------------------------

assert(not PanelWithRankExchangeAnim)
assert(PanelWithRankPopRemoveAnim)

PanelWithRankExchangeAnim = class(PanelWithRankPopRemoveAnim)

function PanelWithRankExchangeAnim:ctor()
end

function PanelWithRankExchangeAnim:init(panelToControl, topPanel, rankList, ...)
	assert(panelToControl)
	assert(topPanel)
	assert(rankList)
	assert(#{...} == 0)

	-- Init Base
	PanelWithRankPopRemoveAnim.init(self, panelToControl, topPanel, rankList)

	-- Create Content Anim
	--self.contentAnim = PanelContentAnim:create(topPanel)
end

function PanelWithRankExchangeAnim:show(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	-- Pop Out Panel
	--PopoutManager:sharedInstance():add(self.panelToControl, true, false)
	
	-- Move Panel To The Initial Pos
	local topPanelInitPos	= self:getTopPanelShowPos()
	self.topPanel:setPosition(ccp(topPanelInitPos.x, topPanelInitPos.y))
	
	-- Play Show Content Anim
	local contentAnim = self.contentAnim:getShowContentAction()

	-- Play Show Rank List Anim
	local showRankListAnim = self:getRankListPopAct()

	-- Finish Callback
	local function actionFinishCallback()

		if animFinishCallback then
			animFinishCallback()
		end
	end
	local finishCallbackAction = CCCallFunc:create(actionFinishCallback)

	--- Action Array
	local array = CCArray:create()
	array:addObject(contentAnim)
	array:addObject(showRankListAnim)
	array:addObject(finishCallbackAction)

	-- Seq
	local seq = CCSequence:create(array)

	self.panelToControl:runAction(seq)
end

function PanelWithRankExchangeAnim:hide(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	-- Play Hide Rank List Anim
	local hideRankListAct	= self:getRankListRemoveAct()

	-- Play Hide Content Anim
	local hideContentAnim	= self.contentAnim:getHideContentAction()

	-- Action Finish Callback
	local function actionFinishCallback()
		-- Remove From PopoutManager
		--PopoutManager:sharedInstance():remove(self.panelToControl, true)

		if animFinishCallback then
			animFinishCallback()
		end
	end
	local callbackAction	= CCCallFunc:create(actionFinishCallback)

	-- Action Array
	local array = CCArray:create()
	array:addObject(hideRankListAct)
	array:addObject(hideContentAnim)
	array:addObject(callbackAction)

	-- Seq
	local seq = CCSequence:create(array)

	self.panelToControl:runAction(seq)
end

function PanelWithRankExchangeAnim:create(panelToControl, topPanel, rankList, ...)
	assert(panelToControl)
	assert(topPanel)
	assert(rankList)
	assert(#{...} == 0)

	local newPanelWithRankExchangeAnim = PanelWithRankExchangeAnim.new()
	newPanelWithRankExchangeAnim:init(panelToControl, topPanel, rankList)
	return newPanelWithRankExchangeAnim
end
