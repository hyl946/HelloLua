local DayRender = class()
local model = require("zoo/localActivity/UserCallBackTest/src/model/Model.lua"):getInstance()

local AWARD_STATE = {
	NORMAL = 1,
	AVAILABLE = 2,
	OPENED = 3
}

function DayRender:create(ui, id, priceTag)
	local render = DayRender.new()
	render:init(ui, id, priceTag)
	return render
end

function DayRender:init(ui, id, priceTag)
	self.ui = ui
	self.id = id
	self.priceTag = priceTag
	self.cfg = model.boxRewardCfg[id]--model:getRewardIDByDayID(id)
	-- if id == 1 and UserCallbackManager.getInstance():getUserGroup() == UserCallbackManager.UserGroup.kGroupNewB then 
	-- 	self.cfg = {}
	-- 	self.cfg.rewards = model:getBuffIconNames()
	-- end
	self.bg = ui:getChildByName("bg")
	self.shine = ui:getChildByName('light')
	self.green_n = ui:getChildByName('green_n')
	self.yellow_n = ui:getChildByName('yellow_n')

	if self.id > 1 then
		self:initClippedAnimation()
	end
	self.rewardCells = {}
end



function DayRender:initClippedAnimation()
	local posX, posY = self.green_n:getPositionX(), self.green_n:getPositionY()
	local rect = self.green_n:getGroupBounds().size
	-- print(rect.width, rect.height) debug.debug()
	local zorder = self.green_n:getZOrder()
	local clipping = ClippingNode:create({size=rect})
	-- local clipping = LayerColor:create()
	-- clipping:setContentSize(CCSizeMake(rect.width, rect.height))
	-- clipping:setColor(ccc3(0,0,0))

	self.green_n:removeFromParentAndCleanup(false)
	clipping:addChild(self.green_n)
	self.green_n:setPositionX(0)
	self.green_n:setPositionY(rect.height*2)
	self.ui:addChild(clipping)
	clipping:setPositionX(posX)
	clipping:setPositionY(posY - rect.height*2)
	self.clipping = clipping
	self.posY = posY


	local sprite = Sprite:createWithSpriteFrameName('user_callback_arrow_0000')
	sprite:setAnchorPoint(ccp(0, 1))
	local ph = self.ui:getChildByName('ph')
	ph:setVisible(false)
	ph:getParent():addChild(sprite)
	sprite:setPositionX(ph:getPositionX())
	sprite:setPositionY(ph:getPositionY())
	sprite:play(SpriteUtil:buildAnimate(SpriteUtil:buildFrames("user_callback_arrow_%04d", 0,59), 1/20), 0, 0)

	-- if __WIN32 then
	-- 	clipping:setInverted(true)
	-- end

	self.greenSize = {width=rect.width, height=rect.height}
end

function DayRender:fillClippedAnimation(playAnim)
	
	if playAnim then
		local time = 0.5
		self.clipping:runAction(CCMoveBy:create(time, ccp(0, self.greenSize.height)))
		self.green_n:runAction(CCMoveBy:create(time, ccp(0, -self.greenSize.height)))
	else
		self.clipping:setPositionY(self.posY - self.greenSize.height)
		self.green_n:setPositionY(self.greenSize.height)
	end
end

--需要重写
function DayRender:calcState()
	if self.id < model:getTodayID() then
		return AWARD_STATE.OPENED
	elseif self.id > model:getTodayID() then
		if model.received and self.id == model:getTodayID() + 1 and
		(model.endTime / 1000) > (Localhost:getDayStartTimeByTS(Localhost:timeInSec() + 86400) + 2) then
			return AWARD_STATE.AVAILABLE
		else
			return AWARD_STATE.NORMAL
		end
	else
		if model.received then
			return AWARD_STATE.OPENED
		else
			return AWARD_STATE.AVAILABLE
		end
	end

	return AWARD_STATE.NORMAL
end

function DayRender:refresh()
	print(self.id, 'refresh')
	if self.ui.isDisposed then return end
	self.state = self:calcState()
	if self.state == AWARD_STATE.NORMAL then
		print(self.id, 'toNormalState')
		self:toNormalState()
	elseif self.state == AWARD_STATE.AVAILABLE then
		print(self.id, 'toAvailableState')
		self:toAvailableState()
	elseif self.state == AWARD_STATE.OPENED then
		print(self.id, 'toOpenedState')
		self:toOpenedState()
	end
	self:addRewardShow()
	self:initTags()
end

function DayRender:initTags()
	local receivedTagName = 'UserCallBackVer2/GainAwardAnim'
	if self.priceTag then
		receivedTagName = 'UserCallBackVer2/GainAwardAnim_pricetag'
	end
	if self.state == AWARD_STATE.OPENED or self.state == AWARD_STATE.AVAILABLE or self.id == 7 then
		local node = ArmatureNode:create(receivedTagName)
		if self.state == AWARD_STATE.OPENED then
			node:playByIndex(0, 1)
		    node:update(10)
		    node:stop()
		    node:setVisible(true)
		else
			node:playByIndex(0, 1)
		    node:update(0.001)
		    node:stop()
		    node:setVisible(false)
		end
		self.ui:addChild(node)
		node:setPosition(ccp(5, -18))
		self.receivedTag = node
	end

	local todayId = model:getTodayID()
	if self.id == todayId + 1 and not model:isActEnd() then
		local node = ArmatureNode:create('UserCallBackVer2/tomorrow')
		node:playByIndex(0, 1)
	    
	    self.ui:addChild(node)
		node:setPosition(ccp(3, -18))
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

function DayRender:playTomorrowAnim()
	if self.ui.isDisposed then return end
	if self.tomorrowTag then
		local function doPlay()
			self.tomorrowTag:setVisible(true)
			self.tomorrowTag:playByIndex(0, 1)
		end
		self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(doPlay)))
	end
end

function DayRender:playGainAwardAnim()
-- debug.debug()
	if self.ui.isDisposed then return end
	if self.receivedTag then
		self.receivedTag:setVisible(true)
		self.receivedTag:playByIndex(0, 1)
	end
	if self.shine ~= nil then
		self.shine:setVisible(false)
		self.shine:stopAllActions()
	end
	if self.id > 1 then
	    self:fillClippedAnimation(true)
	end
end

function DayRender:toNormalState()
	if self.ui.isDisposed then return end
	if self.shine ~= nil then
		self.shine:setVisible(false)
		self.shine:stopAllActions()
	end
end

function DayRender:toAvailableState()
	if self.ui.isDisposed then return end
	if self.shine ~= nil then
		self.shine:setVisible(model.received == false)
		self.shine:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeOut:create(0.9), CCFadeIn:create(0.9))))
	end
end

function DayRender:toOpenedState()
	if self.ui.isDisposed then return end
	if self.shine ~= nil then
		self.shine:setVisible(false)
		self.shine:stopAllActions()
	end
	if self.id > 1 then
		self:fillClippedAnimation(false)
	end
end

function DayRender:addRewardShow()
	local canAdd, builder = self:canAddRewardShow()
	if canAdd then
		-- if self.id == 1 and UserCallbackManager.getInstance():getUserGroup() == UserCallbackManager.UserGroup.kGroupNewB then
		-- 	self:addBuffItems(builder)
		-- else
			self:addItems(builder)
		-- end
	end
end

function DayRender:getRewardPosInfo()
	local startX, startY, gapX = 195, -70, 140
	if self.id == 7 then
		startY = -65
	end
	if #self.cfg.rewards == 5 then
		gapX = 85
		if self.id == 1 then
			startX = 185
		end
	elseif #self.cfg.rewards > 3 then
		gapX = 110
	elseif #self.cfg.rewards == 3 then
		startX = 220
	elseif #self.cfg.rewards == 2 then
		startX = 280
	end
	return startX, startY, gapX
end

function DayRender:addItems(builder)
	local startX, startY, gapX = self:getRewardPosInfo()
	local function normalizeNum(num)
		if num >= 10000 then
			return tostring(num/10000)..'万'
		else
			return tostring(num)
		end
	end

	-- print("-------------- "..table.tostring(self.cfg.rewards) )
	for i = 1, #self.cfg.rewards do
		local reward = self.cfg.rewards[i]
		local rewardCell = builder:buildGroup("UserCallBackVer2/rewardCell")
		rewardCell.reward = reward
		local iconC = rewardCell:getChildByName("iconC")
		local pos = iconC:getPosition()

		local bBuffItem = reward.Buff

		local icon = nil 
		if bBuffItem then
			local BuffLevel = reward.BuffLevel
			icon = builder:buildGroup("UserCallBackVer2/prebuff_icon/buff_icon_"..BuffLevel)
			reward.num = 1
		else
			local itemId = reward.itemId
			if ItemType:isTimeProp(itemId) then
				itemId = ItemType:getRealIdByTimePropId(itemId)
			end 
			icon = ResourceManager:sharedInstance():buildItemSprite(itemId)
		end

		icon:setAnchorPoint(ccp(0.5, 0.5))
		icon:setScale(0.85)
		icon:setPositionXY(pos.x, pos.y)
		iconC:getParent():addChildAt(icon, 0)
		iconC:removeFromParentAndCleanup(true)

		local fntFile = "ui/UserCallBackTest/fnt/user_callback_numbers.fnt"
		-- local fntFile = "fnt/target_amount.fnt"
		self.rewardNumTf = BitmapText:create('', fntFile)
		if reward.itemId and reward.itemId == 2 then
			self.rewardNumTf:setText("x" .. normalizeNum(reward.num))
		else
			self.rewardNumTf:setText("x" .. reward.num)
		end
		self.rewardNumTf:setAnchorPoint(ccp(0.5, 0.5))
		-- self.rewardNumTf:setPreferredSize(200, 40)
		self.rewardNumTf:setPosition(ccp(pos.x, pos.y - 40))
		rewardCell:addChild(self.rewardNumTf)

		rewardCell:setPositionXY(startX, startY)
		self.ui:addChild(rewardCell)
		startX = startX + gapX
		self.rewardCells[i] = rewardCell
	end
end

function DayRender:canAddRewardShow()
	if model ~= nil then
	 	local mainPanel = model:getMainPanel()
	 	if mainPanel ~= nil and mainPanel.ui ~= nil and not mainPanel.ui.isDisposed then
	 		local builder = mainPanel.builder
	 		if builder ~= nil then
	 			return true, builder
	 		end
	 	end
	end

	return false
end

function DayRender:playShowAnim(callBack)
	if self.ui.isDisposed then return end
	self.rawX = self.ui:getPositionX()
	self.rawY = self.ui:getPositionY()
	local  rawX, rawY = self.rawX, self.rawY
	local timeSlice = 0.03
	local ary = CCArray:create()
	if self.id == 1 then
		self.ui:setPositionXY(rawX, rawY + 105)--877.3 984.7 1039.15
		self.ui:setVisible(false)
		ary:addObject(CCDelayTime:create(timeSlice * 12))
		ary:addObject(CCCallFunc:create(function() self.ui:setVisible(true) end))
		ary:addObject(CCMoveTo:create(timeSlice * 2, ccp(rawX, rawY)))
		ary:addObject(CCCallFunc:create(callBack))
	elseif self.id == 2 then
		self.ui:setPositionXY(rawX, rawY + 111)--749.1 860.1 903
		self.ui:setVisible(false)
		ary:addObject(CCDelayTime:create(timeSlice * 11))
		ary:addObject(CCCallFunc:create(function() self.ui:setVisible(true) end))
		ary:addObject(CCMoveTo:create(timeSlice, ccp(rawX, rawY)))
		ary:addObject(CCCallFunc:create(callBack))
	elseif self.id == 3 then
		self.ui:setPositionXY(rawX, rawY + 125)--620.9 735.9 767.15
		self.ui:setVisible(false)
		ary:addObject(CCDelayTime:create(timeSlice * 9))
		ary:addObject(CCCallFunc:create(function() self.ui:setVisible(true) end))
		ary:addObject(CCMoveTo:create(timeSlice * 2, ccp(rawX, rawY)))
		ary:addObject(CCDelayTime:create(timeSlice))
		ary:addObject(CCCallFunc:create(callBack))
	elseif self.id == 4 then
		self.ui:setPositionXY(rawX, rawY + 120)--493.7 613.7
		self.ui:setVisible(false)
		ary:addObject(CCDelayTime:create(timeSlice * 7))
		ary:addObject(CCCallFunc:create(function() self.ui:setVisible(true) end))
		ary:addObject(CCMoveTo:create(timeSlice * 2, ccp(rawX, rawY)))
		ary:addObject(CCDelayTime:create(timeSlice * 8))
		ary:addObject(CCCallFunc:create(callBack))
	elseif self.id == 5 then
		self.ui:setPositionXY(rawX, rawY + 122)--369.5 491.5
		self.ui:setVisible(false)
		ary:addObject(CCDelayTime:create(timeSlice * 4))
		ary:addObject(CCCallFunc:create(function() self.ui:setVisible(true) end))
		ary:addObject(CCMoveTo:create(timeSlice * 3, ccp(rawX, rawY)))
		ary:addObject(CCDelayTime:create(timeSlice * 8))
		ary:addObject(CCCallFunc:create(callBack))
	elseif self.id == 6 then
		self.ui:setPositionXY(rawX, rawY + 149)--220.7 369.3 
		self.ui:setVisible(false)
		ary:addObject(CCDelayTime:create(timeSlice))
		ary:addObject(CCCallFunc:create(function() self.ui:setVisible(true) end))
		ary:addObject(CCMoveTo:create(timeSlice * 3, ccp(rawX, rawY)))
		ary:addObject(CCDelayTime:create(timeSlice * 8))
		ary:addObject(CCCallFunc:create(callBack))
	elseif self.id == 7 then
		self.ui:setPositionXY(rawX, rawY + 23) --195.9
		ary:addObject(CCMoveTo:create(timeSlice * 2, ccp(rawX, rawY)))
		ary:addObject(CCDelayTime:create(timeSlice * 11))
		ary:addObject(CCCallFunc:create(callBack))
	end

	self.ui:runAction(CCSequence:create(ary))
end

function DayRender:playShowAnim2(callBack)
	if self.ui.isDisposed then return end
	local  rawX, rawY = self.rawX, self.rawY
	local timeSlice = 0.09
	local ary = CCArray:create()
	if self.id == 1 then
		ary:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(timeSlice, ccp(rawX, rawY - 55)), CCScaleTo:create(timeSlice, 1, 1.056)))
		ary:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(timeSlice, ccp(rawX, rawY)), CCScaleTo:create(timeSlice, 1, 1)))
		ary:addObject(CCCallFunc:create(callBack))
	elseif self.id == 2 then
		ary:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(timeSlice, ccp(rawX, rawY - 43)), CCScaleTo:create(timeSlice, 1, 1.056)))
		ary:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(timeSlice, ccp(rawX, rawY)), CCScaleTo:create(timeSlice, 1, 1)))
		ary:addObject(CCCallFunc:create(callBack))
	elseif self.id == 3 then
		ary:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(timeSlice, ccp(rawX, rawY - 31)), CCScaleTo:create(timeSlice, 1, 1.056)))
		ary:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(timeSlice, ccp(rawX, rawY)), CCScaleTo:create(timeSlice, 1, 1)))
		ary:addObject(CCCallFunc:create(callBack))
	elseif self.id == 4 then
		ary:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(timeSlice, ccp(rawX, rawY - 21)), CCScaleTo:create(timeSlice, 1, 1.056)))
		ary:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(timeSlice, ccp(rawX, rawY)), CCScaleTo:create(timeSlice, 1, 1)))
		ary:addObject(CCCallFunc:create(callBack))
	elseif self.id == 5 then
		ary:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(timeSlice, ccp(rawX, rawY - 17)), CCScaleTo:create(timeSlice, 1, 1.056)))
		ary:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(timeSlice, ccp(rawX, rawY)), CCScaleTo:create(timeSlice, 1, 1)))
		ary:addObject(CCCallFunc:create(callBack))
	elseif self.id == 6 then
		ary:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(timeSlice, ccp(rawX, rawY - 10)), CCScaleTo:create(timeSlice, 1, 1.056)))
		ary:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(timeSlice, ccp(rawX, rawY)), CCScaleTo:create(timeSlice, 1, 1)))
		ary:addObject(CCCallFunc:create(callBack))
	elseif self.id == 7 then
		ary:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(timeSlice, ccp(rawX, rawY - 7)), CCScaleTo:create(timeSlice, 1, 1.056)))
		ary:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(timeSlice, ccp(rawX, rawY)), CCScaleTo:create(timeSlice, 1, 1)))
		ary:addObject(CCCallFunc:create(callBack))
	end

	self.ui:runAction(CCSequence:create(ary))
end

function DayRender:dispose()
	-- body
end

return DayRender