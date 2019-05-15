local SuperCls = require("zoo/localActivity/UserCallBackTest/src/component/DayRender.lua")
local LastDayRender = class(SuperCls)
local model = require("zoo/localActivity/UserCallBackTest/src/model/Model.lua"):getInstance()

local AWARD_STATE = {
	NORMAL = 1,
	AVAILABLE = 2,
	OPENED = 3
}

function LastDayRender:create(ui, id, priceTag)
	local render = LastDayRender.new()
	render:init(ui, id, priceTag)
	return render
end


function LastDayRender:init(ui, id, priceTag)
	self.ui = ui
	self.id = id
	self.priceTag = priceTag
	self.cfg = model.boxRewardCfg[id]--model:getRewardIDByDayID(id)
	self.bg = ui:getChildByName("bg")
	self.shine = ui:getChildByName('light')
	self.green_n = ui:getChildByName('green_n')
	self.yellow_n = ui:getChildByName('yellow_n')

	self:initBgClipping()
	self:initClippedAnimation()

	self:initStars()
	self.rewardCells = {}
end

function LastDayRender:initStars()
	local node = ArmatureNode:create('UserCallBackVer2/starlight')
	self.ui:addChild(node)
	node:setPosition(ccp(9, -18))
	node:playByIndex(0, 0)
end

function LastDayRender:initBgClipping()
	local posX, posY = self.bg:getPositionX(), self.bg:getPositionY()
	local rect = self.bg:getGroupBounds().size
	-- print(rect.width, rect.height) debug.debug()
	local zorder = self.bg:getZOrder()
	self.bg:removeFromParentAndCleanup(false)
	local clipping = ClippingNode.new(CCClippingNode:create(self.bg.refCocosObj))
	clipping:setAlphaThreshold(0.01)
	-- local clipping = LayerColor:create()
	-- clipping:setContentSize(CCSizeMake(rect.width, rect.height))
	-- clipping:setColor(ccc3(0,0,0))

	clipping:addChild(self.bg)
	self.bg:setPositionX(0)
	self.bg:setPositionY(rect.height)

	local reflection = self.ui:getChildByName('reflection')
	reflection:removeFromParentAndCleanup(false)
	clipping:addChild(reflection)

	local refPosX, refPosY = -420, 186
	reflection:setPositionX(refPosX)
	reflection:setPositionY(refPosY)
	local arr = CCArray:create()
	arr:addObject(CCPlace:create(ccp(refPosX, refPosY)))
	arr:addObject(CCMoveBy:create(1, ccp(622+420, 0)))
	arr:addObject(CCDelayTime:create(5))
	local action = CCSequence:create(arr)
	reflection:runAction(CCRepeatForever:create(action))

	self.ui:addChildAt(clipping, zorder)
	clipping:setPositionX(posX)
	clipping:setPositionY(posY - rect.height)
	self.bgClipping = clipping
end

function LastDayRender:toNormalState()   
	SuperCls.toNormalState(self)
end

function LastDayRender:toAvailableState()
	SuperCls.toAvailableState(self)
end
 
function LastDayRender:toOpenedState()
	SuperCls.toOpenedState()
end

function LastDayRender:getRewardPosInfo()
	if #self.cfg.rewards > 3 then return 175, -74, 110 end
	return 175, -74, 140
end

function LastDayRender:stopBtnAnim( ... )
	if self.ui.isDisposed then return end
	for i = 1, 6 do
		self.rewardShow:getChildByName('star'..i):stopAllActions()
		self.rewardShow:getChildByName('star'..i):setVisible(false)
	end
end


function LastDayRender:playGainAwardAnim()
	if self.ui.isDisposed then return end
	SuperCls.playGainAwardAnim(self)
	if self.receivedTag then
		self.receivedTag:setVisible(true)
		self.receivedTag:playByIndex(1, 1)
	end
end


function LastDayRender:initTags()
	local receivedTagName = 'UserCallBackVer2/GainAwardAnim'
	if self.priceTag then
		receivedTagName = 'UserCallBackVer2/GainAwardAnim_pricetag'
	end
	local todayId = model:getTodayID()
	if self.id ~= todayId + 1 then
		local node = ArmatureNode:create(receivedTagName)
		if self.state == AWARD_STATE.OPENED then
			node:playByIndex(0, 1)
		    node:update(10)
		    node:stop()
		    node:setVisible(true)
		    if self.priceTag then
				node:setPosition(ccp(10, -14))
			else
				node:setPosition(ccp(12, -4))
			end
		else
			node:playByIndex(0, 1)
			if self.priceTag then
				node:update(10)
				node:setVisible(true)
			else
		    	node:update(0.001)
		    	node:setVisible(false)
		    end
		    node:stop()
		    if self.priceTag then
				node:setPosition(ccp(10, -14))
			else
				node:setPosition(ccp(12, -4))
			end
		end
		self.ui:addChild(node)
		self.receivedTag = node
	end

	if self.id == todayId + 1 then
		local node = ArmatureNode:create('UserCallBackVer2/tomorrow')
		node:playByIndex(0, 1)
	    
	    self.ui:addChild(node)
		node:setPosition(ccp(8, -6))
		if model.received then
			node:update(0.3)
		    node:stop()
			node:setVisible(true)
		else
			node:update(0.001)
		    node:stop()
			node:setVisible(false)
		end
	    self.tomorrowTag = node
	end
end

return LastDayRender