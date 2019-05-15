local Misc = require('zoo.quarterlyRankRace.utils.Misc')
local Vector2d = require('zoo.quarterlyRankRace.utils.Vector2d')
local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
local UIHelper = require 'zoo.panel.UIHelper'
local RankRaceGetRewardPanel = require 'zoo.quarterlyRankRace.view.RankRaceGetRewardPanel'

local MIN_SPEED = 3

local xiaodong_mode = true

local function getIconByItemId(itemId, index)
	return Misc:getItemSprite(itemId)
end

local function printx( ... )
	-- body
end

local function standardAngle2(angle)
	if angle < -180 then
		while angle < -180 do angle = angle + 360 end
	end
	if angle > 180 then
		while angle > 180 do angle = angle - 360 end
	end
	return angle
end


local function standardAngle(angle)
	if angle < 0 then
		while angle < 0 do angle = angle + 360 end
	end
	if angle > 360 then
		while angle > 360 do angle = angle - 360 end
	end
	return angle
end


local function callAncestors(self, methodName, ... )
	if self.isDisposed then return end
	local node = self:getParent()
	while node do
		if node[methodName] then
			if node[methodName](node, ...) then
				return true
			end
		end
		node = node:getParent()
	end
	return false
end

local TurnCtrl = class()

function TurnCtrl:ctor(config)

	self.model = config.model
	self.meta = self.model:getMeta()
	self.turnHolder = config.turnHolder
	self.armaturePath = config.armaturePath
	self.armatureName = config.armatureName

	local parent = self.turnHolder:getParent()
	local ui = self.turnHolder
	self.ui = ui

	-- ui:setPositionX(-8)
	-- ui:setPositionY(-22)

	self.ui:scheduleUpdateWithPriority(function ( ... )
		self:update(...)
	end, 0)

	self.rewardConfig = self.meta:getLotteryConfig()


	self.start = self.ui:getChildByPath('startBtn')
	UIUtils:setTouchHandler(self.start, function ( ... )
    	if self.isDisposed then return end
		self:autoStart()


    end)


	-- local effect = Misc:createArmature2(self.armaturePath, self.armatureName)
	-- effect:playByIndex(0, 0)
	-- self.start:addChild(effect)

	-- effect:setScale(1.123)
	-- effect:setPosition(ccp(51, -44))

	-- self.startEff = effect
	self.isBusy = false
	self:buildTurnTable()

	self:refresh()
	self:refreshLight()

	self.model:addObserver(self)

end

function TurnCtrl:onNotify( action, ...)

	if self.ui.isDisposed then return end

	if self['_onNotify_' .. action] then
		self['_onNotify_' .. action](self, ...)
	end	
end

function TurnCtrl:_onNotify_kTargetCountChange1( ... )
	self:refresh()

	if not self:isBlock() then
		if self.model:canDrawLottery() then
			local params = {...}
			--有动画要飞时 等动画飞完再刷新 光和手的显示
			if not params[1] then 
				self:refreshLight()
				callAncestors(self.ui, 'playHandAnim')
			end
		end
	end
end

function TurnCtrl:_onNotify_kRefreshCanLotteryShow()
	if not self:isBlock() then
		if self.model:canDrawLottery() then
			self:refreshLight()
			callAncestors(self.ui, 'playHandAnim')
		end
	end
end

function TurnCtrl:buildTurnTable()


	self.turntable = self.ui:getChildByPath('turntable')


	local offsetX = -1.5
	local offsetY = 1

	for _, v in ipairs(self.turntable:getChildrenList() or {}) do
		v:setPositionX(v:getPositionX() + offsetX)
		v:setPositionY(v:getPositionY() + offsetY)
	end


	self.pointer = self.ui:getChildByPath('pointer')

	self.pointer.y = self.pointer:getPositionY()

	local bg = self.turntable:getChildByPath('bg')
	for i = 1, 8 do 
		local reward = self.rewardConfig[i]
		self:buildRewardItem(i, reward)
	end

	self:refreshPointer()

	self:createPhysicsNodes()

	self:stayRotate(0)

	self:buildLight()

	self:setEnabled(true)

end

function TurnCtrl:buildLight( ... )
	if self.ui.isDisposed then return end
	self.light2 = self.turntable:getChildByPath('light2')
end

function TurnCtrl:refreshLight( ... )
	if self.ui.isDisposed then return end

	self.light2:stopAllActions()

	if self.enabled then
		self.light2:runAction(CCRepeatForever:create(
			CCSequence:createWithTwoActions(
				CCFadeIn:create(0.4),
				CCFadeOut:create(0.4)
			)
		))
		self.light2:setVisible(true)
	else
		self.light2:stopAllActions()
		self.light2:setVisible(false)
	end
end

function TurnCtrl:createPhysicsNodes( ... )
	local function createNode( ... )
		local node = LayerColor:createWithColor(ccc3(0, 0, 255), 16, 16)
		node:ignoreAnchorPointForPosition(false)
		node:setAnchorPoint(ccp(1, 1))
		node:setVisible(false)
		return node
	end
	self.turntablePhysicsNodes = {}
	local turntableR = 280
	for i = 1, 8 do
		local angle = (i-1) * math.pi/4 + math.pi/8
		local node = createNode()
		self.turntable:addChild(node)
		node:setPositionX(turntableR * math.cos(angle) )
		node:setPositionY(turntableR * math.sin(angle) )
		self.turntable:addChild(node)

		table.insert(self.turntablePhysicsNodes, node)
	end
	local function calcTurnCircle( ... )
		local physicsOrigin = self.turntable:convertToWorldSpace(ccp(0, 0))
		local tmp = self.turntablePhysicsNodes[1]:convertToWorldSpace(ccp(0, 0))
		local physicsRadius = math.sqrt((tmp.x - physicsOrigin.x)*(tmp.x - physicsOrigin.x)+(tmp.y - physicsOrigin.y)*(tmp.y - physicsOrigin.y))
		return physicsOrigin, physicsRadius
	end
	self.calcTurnCircle = calcTurnCircle



	self.pointerPhysicsNodes = {}

	for i = 1, 999 do
		local node = self.pointer:getChildByPath('shape'):getChildByPath(tostring(i))
		if node then
			table.insert(self.pointerPhysicsNodes, node)
		else
			break
		end
	end

	self.pointerPhysics = {
		speed = 0,
	}

	self.pointer:getChildByPath('shape'):setVisible(false)

	-- ____AAAA = function ( ... )
		-- self:stayRotate(-180)
	-- end

	-- ____BBBB = function ( ... )
		-- body
		-- CommonTip:showTip('xx')
		-- self:setTargetAngle(0)
		-- self:notCalcStopping(-180, -180)
	-- end

	-- ____CCCC = function ( ... )
		-- body
		-- self.turntable:setRotation(0)
	-- -- end

	-- ____AAAA = function ( ... )

	-- 		local PopoutManagerProxy = require('activity/KitchenGodsDay/src/view/PopoutManagerProxy.lua')
	-- 		PopoutManagerProxy:hide()

	-- 		self:refresh()
	-- 		self:moveToTop()
	-- 		self:createLevelAnim()

	-- 		LevelUpSharePanel:create(function ( ... )

	-- 			if self.ui.isDisposed then
	-- 				if done then done() end
	-- 				return
	-- 			end

	-- 			self:revert()

	-- 			PopoutManagerProxy:revert()


	-- 			if done then done() end
	-- 		end):popout()
	-- 	-- body
	-- end
end


function TurnCtrl:refreshPointer( ... )

end

function TurnCtrl:buildRewardItem(index, reward)
	local itemUI = self.turntable:getChildByPath('item'..index)
	local numberUI = itemUI:getChildByPath('number')
	numberUI:changeFntFile('fnt/event_default_digits.fnt')
	numberUI.fntFile = 'fnt/event_default_digits.fnt'
	local numberSize = itemUI:getChildByPath('numberSize')
	numberUI = TextField:createWithUIAdjustment(numberSize, numberUI)
	itemUI:addChild(numberUI)

	local iconHolder = itemUI:getChildByPath('icon')
	iconHolder:setOpacity(0)
	numberUI:setString('x'..tostring(reward.num))

	local icon = self:getIconByItemId(reward.itemId, index)
	local iconHolderBounds = iconHolder:getGroupBounds(itemUI)
	local size = iconHolderBounds.size

	if reward.itemId == 10088 then
		size = CCSizeMake(size.width * 1.3, size.height * 1.3)
	end

	local centerPos = ccp(iconHolderBounds:getMidX(), iconHolderBounds:getMidY())


	itemUI:addChild(icon)
	layoutUtils.scaleNodeToSize(icon, CCSizeMake(size.width*1.1, size.height*1.1), itemUI)
	icon:setScaleX(icon:getScaleY())
	layoutUtils.setNodeCenterPos(icon, centerPos, itemUI)

	self:updateTimeFlag(itemUI, reward.itemId)

	local angle = (index-1) * 360 / 8 * math.pi / 180
	local radius = 235

	itemUI:setPosition(ccp(radius * math.sin(angle), radius * math.cos(angle)))
end

function TurnCtrl:updateTimeFlag(containerUI, itemId)
	local timeFlag = containerUI:getChildByPath('time_flag')
	local timeFlag1 = containerUI:getChildByPath('time_flag1')
	local isTimeProp, timePropType = ItemType:isTimeProp(itemId)
	if isTimeProp then
		if not timePropType or timePropType == TimeLimitPropType.k24Hour then
			if timeFlag1 then timeFlag1:setVisible(false) end
			if timeFlag then
				timeFlag:removeFromParentAndCleanup(false)
				containerUI:addChild(timeFlag)
			end 
		elseif timePropType and timePropType == TimeLimitPropType.k48Hour then 
			if timeFlag then timeFlag:setVisible(false) end
			if timeFlag1 then
				timeFlag1:removeFromParentAndCleanup(false)
				containerUI:addChild(timeFlag1)
			end 
		end
	else
		if timeFlag then timeFlag:setVisible(false) end
		if timeFlag1 then timeFlag1:setVisible(false) end
	end
end

function TurnCtrl:getPoints()
	return 100
end

function TurnCtrl:refresh(b)
	if self.ui.isDisposed then return end

	if self.model:canDrawLottery() then
		self:setEnabled(true)
	else
		self:setEnabled(false)
	end

end


function TurnCtrl:getIconByItemId(itemId, index, isBig)
	return getIconByItemId(itemId, index, isBig)
end


function TurnCtrl:setEnabled(enabled)

	if self.ui.isDisposed then return end


	if enabled == self.enabled then 
		return
	end

	self.enabled = enabled
	self.turntable:setTouchEnabled(enabled, 0, true)
	if enabled then
		self.turntable:removeEventListenerByName(DisplayEvents.kTouchBegin)
		self.turntable:addEventListener(DisplayEvents.kTouchBegin, function(evt) 
			if self.ui.isDisposed then return end
			self:onTouchBegin(evt) 
		end)
	else
		self.turntable:removeEventListenerByName(DisplayEvents.kTouchBegin)
	end

	local startBtn = self.ui:getChildByPath('start')

	if (not self.enabled) and (not self.isBusy) then
		self.turntable:setTouchEnabled(true, 0, true)
		self.turntable:addEventListener(DisplayEvents.kTouchBegin, function(evt) 
		end)
	end
end

function TurnCtrl:isBlock( ... )
	return self.isBusy
end


local frameCounter = 0

function TurnCtrl:update( ... )
	if not self.ui then
		return 
	end
	if self.ui.isDisposed then return end

	frameCounter = frameCounter + 1
	if frameCounter >= 3600 then
		frameCounter = 0
	end
end

function TurnCtrl:onMoneyChange( ... )
    if not self.ui then
		return 
	end
	if self.ui.isDisposed then return end

	if not self.isBusy then
		self:refresh()
	end
end

function TurnCtrl:autoStart()

	if self.isBusy then
		return
	end

	if self.enabled == true then
		local p1 = ccp(0, 100)
		local p2 = ccp(180, 100)
		local p3 = ccp(360, 100)

		p1 = self.ui:convertToWorldSpace(p1)
		p2 = self.ui:convertToWorldSpace(p2)
		p3 = self.ui:convertToWorldSpace(p3)

		self:onTouchBegin({globalPosition = p1})
		self:onTouchMove({globalPosition = p2})
		self:onTouchEnd({globalPosition = p3}, true)
	else
        local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
        if SaijiIndex == 1 then
		    CommonTip:showTip(localize('rank.race.lottery.not.enough'))
        else
            CommonTip:showTip(localize('rank.race.lottery.not.enough.s2'))
        end
	end
end



function TurnCtrl:onTouchBegin(evt)

	if self.isBusy then return end


	self.pointerPhysics.not_update = false

	self.turntable:removeEventListenerByName(DisplayEvents.kTouchBegin)
	local pos = self.turntable:getParent():convertToWorldSpace(ccp(self.turntable:getPositionX(), self.turntable:getPositionY()))
	self.posX, self.posY = pos.x, pos.y
	local angle = -math.atan2(evt.globalPosition.y - self.posY, evt.globalPosition.x - self.posX)
	local rotation = self.turntable:getRotationX()
	while rotation < -90 or rotation > 270 do
		if rotation > 270 then rotation = rotation - 360
		else rotation = rotation + 360 end
	end
	self.startRotation = angle * 180 / math.pi - rotation
	self.rotationRec = {}
	self.lastRotation = rotation
	self.lastRotationTime = self.curTime or 0

	self.turntable:addEventListener(DisplayEvents.kTouchMove, function(evt) 
		if self.ui.isDisposed then return end
		self:onTouchMove(evt) 
	end)
	self.turntable:addEventListener(DisplayEvents.kTouchEnd, function(evt) 
		if self.ui.isDisposed then return end
		self:onTouchEnd(evt) 
	end)
	self:onDragBegin()
end


function TurnCtrl:onTouchMove(evt)
	if self.isBusy then return end

	local angle = -math.atan2(evt.globalPosition.y - self.posY, evt.globalPosition.x - self.posX)
	self.turntable:setRotation(angle * 180 / math.pi - self.startRotation)
	if #self.rotationRec >= 10 then table.remove(self.rotationRec, 1) end
	local rotation = self.turntable:getRotationX()
	while rotation < -90 or rotation > 270 do
		if rotation > 270 then rotation = rotation - 360
		else rotation = rotation + 360 end
	end
	table.insert(self.rotationRec, rotation - self.lastRotation)

	local dt = (self.curTime or 0) - self.lastRotationTime
	local deltaRotation = rotation - self.lastRotation

	if math.abs(dt) > 1/70.0 then
		self.turntablePhysics.speed = deltaRotation / dt
		self.turntablePhysics.drag = true
	end

	self.lastRotation = rotation
	self.lastRotationTime = self.curTime or 0

	if self.schedule then Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule) end
	local function onTimeOut()
		self.rotationRec = {} 
	end
	self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeOut, 0.1, false)
end




function TurnCtrl:onTouchEnd(evt, isAuto)
	if self.isBusy then return end

	self.turntable:removeEventListenerByName(DisplayEvents.kTouchMove)
	self.turntable:removeEventListenerByName(DisplayEvents.kTouchEnd)
	if self.schedule then Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule) end
	local angle = -math.atan2(evt.globalPosition.y - self.posY, evt.globalPosition.x - self.posX)
	self.turntable:setRotation(angle * 180 / math.pi - self.startRotation)
	local sum = 0
	for k, v in ipairs(self.rotationRec) do
		local rotation = v

		if rotation > 180 then rotation = rotation - 360
		elseif rotation < -180 then rotation = rotation + 360 end


		sum = sum + rotation
	end
	local rotation = self.turntable:getRotationX()
	while rotation < -90 or rotation > 270 do
		if rotation > 270 then rotation = rotation - 360
		else rotation = rotation + 360 end
	end
	self.turntable:addEventListener(DisplayEvents.kTouchBegin, function(evt) 
		if self.ui.isDisposed then return end
		self:onTouchBegin(evt) 
	end)
	sum = sum + rotation - self.lastRotation
	sum = sum / (#self.rotationRec + 1)
	if math.abs(sum) > 7 then
		if sum > 0 then sum = 7
		elseif sum < -7 then sum = -7 end
	end
	if math.abs(sum) > MIN_SPEED then
		local speed = sum

		if isAuto then
			speed = math.abs(speed)
		end

		self:onDragEnd(speed / math.pi * 180)

		self.turntablePhysics.drag = false

	else
		self.turntablePhysics.drag = false

		-- CommonTip:showTip('起手速度太慢，不能算是有效抽奖，转盘复位，请重新再来')

		self.turntablePhysics.speed = 0
		self.pointerPhysics.speed = 0

		self.turntable:setRotation(0)
		self.pointer:setRotation(0)

	end
end



function TurnCtrl:setTargetAngle(target, range)
	self.target, self.range = -target, range
end


function TurnCtrl:stayRotate(sumSpeed)

	self.turntablePhysics = {
		speed = sumSpeed,
		constant = true,
		state = 1,
	}

	local function onUpdate(deltaTime)
		if self.ui.isDisposed then return end
		if self:onPhysicsUpdate(deltaTime) then
			self.turntablePhysics.idle = true
		end
	end
	self.turntable:unscheduleUpdate()
	self.turntable:scheduleUpdateWithPriority(onUpdate, 0)
end

local backTime = 0.5
local maxDelta = 1 / 40

function TurnCtrl:onPhysicsUpdate( real_dt )

	real_dt = math.min(real_dt, maxDelta)
	local targetSpeed = MIN_SPEED / math.pi * 180 


	local dt = real_dt

	if self.ui.isDisposed then return end

	self.lastTime = self.curTime or 0
	self.curTime = self.lastTime + dt

	local g = -9.8 * 4
	local damping = 0.15

	local turntable_damping = 0.5
	if not self.turntablePhysics.drag then
		if (not xiaodong_mode) or self.turntablePhysics.state ~= 2 then
			self.turntable:setRotation(self.turntable:getRotationX() + dt * self.turntablePhysics.speed)
		end
	end

	local function updateTurn( a, dt )
		if (self.turntablePhysics.speed - a * dt) * self.turntablePhysics.speed <= 0 then
			self.turntablePhysics.speed = 0
		else
			self.turntablePhysics.speed = self.turntablePhysics.speed - a * dt
		end
	end

	if self.turntablePhysics.finalTarget and self.turntablePhysics.tmp then

		if self.turntablePhysics.state == 1 then

			local curRotation = standardAngle(self.turntable:getRotationX())
			local speed = self.turntablePhysics.speed

			if math.abs(self.turntablePhysics.speed) <= targetSpeed then

				self.turntablePhysics.state = 0

				self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.05), CCCallFunc:create(function ( ... )
					if not self.turntablePhysics then return end
					self.turntablePhysics.state = 2
				end)))	
			else

				if not self.turntablePhysics.a_1 then

					local dv2 = targetSpeed*targetSpeed - math.abs(self.turntablePhysics.speed)*math.abs(self.turntablePhysics.speed)

					dv2 = math.abs(dv2)

					local delta = math.sqrt(dv2) / 50 * 360
					delta = math.max(delta, 180)
					delta = math.min(delta, 360)

					if self.turntablePhysics.speed < 0 then
						delta = - delta
					end

					self.turntablePhysics.a_1 =  dv2 / 2 / delta
				end

				updateTurn(self.turntablePhysics.a_1, dt)

			end

		elseif self.turntablePhysics.state == 2 then

			if not self.turntablePhysics.a_2 then

				local curRotation = standardAngle(self.turntable:getRotationX())
				local speed = self.turntablePhysics.speed

				
				local delta = self.turntablePhysics.finalTarget - curRotation 
				delta = standardAngle(delta)

				local extraDelta = 360

				delta = delta + extraDelta

				if self.turntablePhysics.speed < 0 then
					while delta > 0 do
						delta = delta - 360
					end
					delta = delta - extraDelta
				end

				if xiaodong_mode then

					local exactTarget = self.turntablePhysics.exactTarget
					local backMode = math.random() < 0.15
					if exactTarget then
						backMode = false
					end

					if backMode then
						if delta >= 0 then
							delta = delta + 22.5
						else
							delta = delta - 22.5
						end

						backTime = 0.8
					else

						local rdm = math.random(30)
						if exactTarget then
							rdm = 15
						end

						if delta >= 0 then
							delta = delta + (rdm - 15)
						else
							delta = delta - (rdm - 15)
						end

						backTime = 0
					end

					local a = self.turntablePhysics.speed * self.turntablePhysics.speed / (2 * delta)
					self.turntablePhysics.a_2 = a
					self.turntablePhysics.total_time_2 = self.turntablePhysics.speed / self.turntablePhysics.a_2
					self.turntablePhysics.time_counter_2 = 0

					if backMode then
						local extraAngle = 2 --回退的角度
						local backAngle = 13
						if delta < 0 then
							extraAngle = -2
							backAngle = -13
						end

						local a1 = CCEaseSineOut:create(CCRotateBy:create(self.turntablePhysics.total_time_2, delta + extraAngle))
						local a2 = CCEaseSineInOut:create(CCRotateBy:create(backTime, - backAngle))

						self.turntablePhysics.total_time_2 = self.turntablePhysics.total_time_2 + backTime


						local array = CCArray:create()
						array:addObject(a1)
						array:addObject(a2)
						array:addObject(CCDelayTime:create(0.2))
						array:addObject(CCCallFunc:create(function ( ... )
							if not self.turntablePhysics then return end
							self.turntablePhysics.all_finished = true
						end))


						self.turntable:runAction(CCSequence:create(
							array
						))

						self.turntable:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(math.max(self.turntablePhysics.total_time_2 - backTime, 0.01)), CCCallFunc:create(function ( ... )

							if self.isDisposed then return end
							if not self.turntablePhysics then return end


							self.turntablePhysics.time_counter_2_finished = true

							if not self.pointerBacking then


								self.pointerBacking = true
								self.pointer:runAction(CCSequence:createWithTwoActions(CCEaseSineOut:create(CCRotateTo:create(backTime, 0)), CCCallFunc:create(function ( ... )
									if not self.turntablePhysics then return end

									self.pointerBacking = false

								end)))


								self.pointerPhysics.not_update = true
							end

						end)))

					else

						local array = CCArray:create()
						array:addObject(CCEaseSineOut:create(CCRotateBy:create(self.turntablePhysics.total_time_2, delta)))
						array:addObject(CCDelayTime:create(0.2))
						array:addObject(CCCallFunc:create(function ( ... )
							if not self.turntablePhysics then return end
							self.turntablePhysics.all_finished = true
						end))
						self.turntable:runAction(CCSequence:create(array))

						local array2 = CCArray:create()
						array2:addObject(CCDelayTime:create(math.max(self.turntablePhysics.total_time_2 - 0.8, 0.01)))
						array2:addObject(CCCallFunc:create(function ( ... )
							if not self.turntablePhysics then return end
							self.turntablePhysics.time_counter_2_finished = true
						end))
						self.turntable:runAction(CCSequence:create(array2))
					end
					
				end                                                                    

			end

			if xiaodong_mode then
				updateTurn(self.turntablePhysics.a_2, dt)

				self.turntablePhysics.time_counter_2 = self.turntablePhysics.time_counter_2 + real_dt

			end
		else
			updateTurn(0, dt)
		end

	end

	if self.turntablePhysics.total_time_2 and self.turntablePhysics.time_counter_2 then
		if self.turntablePhysics.total_time_2 + 0.5 < self.turntablePhysics.time_counter_2 then
			if not self.turntablePhysics.idle then
				return true
			end
		end
	end


	if self.turntablePhysics.all_finished then
		if not self.turntablePhysics.idle then
			return true
		end
	end




	local curRotation = self.pointer:getRotationX()

	if not self.pointerPhysics.not_update then
		self.pointerPhysics.speed = self.pointerPhysics.speed + math.sin(curRotation / 180 * math.pi) * g * dt * 60
		self.pointer:setRotation(self.pointer:getRotationX() + self.pointerPhysics.speed * dt)
	end

	if self.pointer:getRotation() > 75 then
		self.pointer:setRotation(75)
		self.pointerPhysics.speed = 0
	end
	if self.pointer:getRotation() < -75 then
		self.pointer:setRotation(-75)
		self.pointerPhysics.speed = 0
	end

	self.pointerPhysics.speed = math.pow(damping, dt * 5) * self.pointerPhysics.speed


	local function isInInner( pos, polygon )
		for i = 1, #polygon do

			local node1 = polygon[i]
			local node2

			if i >= #polygon then
				node2 =  polygon[1]
			else
				node2 = polygon[i + 1]
			end

			local pA = node1:convertToWorldSpace(ccp(0, 0))
			local pB = node2:convertToWorldSpace(ccp(0, 0))

			local vA = Vector2d.new(pA.x, pA.y)
			local vB = Vector2d.new(pB.x, pB.y)

			local vAB = vB:sub(vA)

			local vC = Vector2d.new(pos.x, pos.y)
			local vAC = vC:sub(vA)


			local angle = vAB:angleTo(vAC)
			if angle > math.pi or angle < 0 then
				return false
			end

		end

		return true
	end


	--求解二元一次方程组
	-- Ax+By+C=0
	-- Dx+Ey+F=0
	local function solve__( A, B, C, D, E, F )

		local function determinant( n1, n2, n3, n4 )
			return n1 * n4 - n2 * n3
		end

		local kk =  determinant(A, B, D, E)
		if kk == 0 then
			return
		end

		local X = determinant(-C, B, -F, E) / kk
		local Y = determinant(A, -C, D, -F) / kk


		return X, Y
	end


	--求直线交点，返回参数
	local function solve_segment_segment( pa, pb, pc, pd )
		local A = (pb.x - pa.x)
		local B = - (pd.x - pc.x)
		local C = pa.x - pc.x

		local D = (pb.y - pa.y)
		local E = - (pd.y - pc.y)
		local F = pa.y - pc.y

		local t1, t2 = solve__(A, B, C, D, E, F)

		-- printx(61, A, B, C, D, E, F)

		if t1 and t2 then
			return t1, t2
		end
	end


	--圆和线段求交点p, 返回值 直线参数方程 参数t, p = (pb - pa) * t + pa 
	local function solve_circle_segment( origin, radius, pa, pb, infinite)


		local va = Vector2d.new(pa.x, pa.y)
		local vb = Vector2d.new(pb.x, pb.y)

		local line = {
			normal = vb:sub(va):rotate(math.pi/2):normalize(),
		}

		line.d = solve_segment_segment({x = 0, y = 0}, {x = 0+line.normal.x, y = 0+line.normal.y}, pa, pb)

		local distance_origin_to_line = Vector2d.new(origin.x, origin.y):dot(line.normal) - line.d

		if math.abs(distance_origin_to_line) > radius then
			return
		end

		local half__ = math.sqrt(radius*radius - distance_origin_to_line * distance_origin_to_line)

		local pAB_normal = vb:sub(va):normalize()

		local A = Vector2d.new(origin.x, origin.y):add(line.normal:mul(-distance_origin_to_line)):add(pAB_normal:mul(half__))
		local B = Vector2d.new(origin.x, origin.y):add(line.normal:mul(-distance_origin_to_line)):sub(pAB_normal:mul(half__))

		
		local t1 = (A.x - pa.x)/(pb.x - pa.x)
		local t2 = (B.x - pa.x)/(pb.x - pa.x)

		if math.abs(pb.x - pa.x) < 0.001 then
			t1 = (A.y - pa.y)/(pb.y - pa.y)
			t2 = (B.y - pa.y)/(pb.y - pa.y)
		end

		if infinite then
			return t1, t2
		end

		local t
		if t1 >= 0 and t1 <= 1 then
			t = t1
		elseif t2 >= 0 and t2 <= 1 then
			t = t2
		end

		return t
	end

	local function solve_circle_poly( origin, radius, nodes , side)

		if side < 0 then

			for i = 1, #nodes - 1 do
				local pa = nodes[i]:convertToWorldSpace(ccp(0, 0))
				local pb = nodes[i+1]:convertToWorldSpace(ccp(0, 0))

				local t = solve_circle_segment(origin, radius, pa, pb)

				if t then
					return {
						x = (pb.x - pa.x) * t + pa.x,
						y = (pb.y - pa.y) * t + pa.y,
					}, Vector2d.new(pb.x, pb.y):sub(Vector2d.new(pa.x, pa.y)):rotate(math.pi/2):normalize()
				end

			end
		else
			for i = #nodes, 2, -1 do
				local pa = nodes[i-1]:convertToWorldSpace(ccp(0, 0))
				local pb = nodes[i]:convertToWorldSpace(ccp(0, 0))

				local t = solve_circle_segment(origin, radius, pa, pb)

				if t then
					return {
						x = (pb.x - pa.x) * t + pa.x,
						y = (pb.y - pa.y) * t + pa.y,
					}, Vector2d.new(pb.x, pb.y):sub(Vector2d.new(pa.x, pa.y)):rotate(math.pi/2):normalize()
				end

			end
		end
	end

	local function processPointer( key )

		local pointerPhysicsNodes = {
			self.pointerPhysicsNodes,
		}

		local pointers = {
			self.pointer,
		}

		local pointerPhysicss = {
			self.pointerPhysics,
		}


		
		for i = 1, 8 do
			local node = self.turntablePhysicsNodes[i]
			local pos = node:convertToWorldSpace(ccp(0, 0))
			if isInInner(pos, pointerPhysicsNodes[key]) then

				local origin, radius = self.calcTurnCircle()

				local tmpPB = pointerPhysicsNodes[key][7]:convertToWorldSpace(ccp(0, 0))
				local tmpPA = pointers[key]:convertToWorldSpace(ccp(0, 0))

				local v_tmpPB = Vector2d.new(tmpPB.x, tmpPB.y)
				local v_tmpPA = Vector2d.new(tmpPA.x, tmpPA.y)

				local function __cal_which_side( ... )

					local pos = Vector2d.new(pos.x, pos.y)

					local mid_line = v_tmpPB:sub(v_tmpPA)
					local node_line = pos:sub(v_tmpPA)

					return mid_line:cross(node_line)

				end


				local pos, normal = solve_circle_poly(origin, radius, pointerPhysicsNodes[key], __cal_which_side())

				local contact_p = pos

				if contact_p then

					contact_p = Vector2d.new(contact_p.x, contact_p.y)

					local pointer_r = contact_p:sub(v_tmpPA)

					local pointer_speed_normal = pointer_r:rotate(-math.pi/2):normalize()

					local normal = pointer_speed_normal

					local pointer_speed = pointer_speed_normal:mul(pointerPhysicss[key].speed * pointer_r:length() * math.pi / 180)

					local turntable_speed_normal = Vector2d.new(contact_p.x, contact_p.y):sub(Vector2d.new(origin.x, origin.y)):rotate(-math.pi/2):normalize()
					local turntable_speed = turntable_speed_normal:mul(self.turntablePhysics.speed * radius  * math.pi / 180 )
					local turntable_speed_component = turntable_speed:dot(normal)



					local mid_line = v_tmpPB:sub(v_tmpPA)


					if mid_line:cross(pointer_r) * (turntable_speed:dot(Vector2d.new(1, 0)) - pointer_speed:dot(Vector2d.new(1, 0))) > 0 then

					else
						if (not self.turntablePhysics.time_counter_2_finished) or self.turntablePhysics.drag then
							pointerPhysicss[key].speed = pointerPhysicss[key].speed + ((turntable_speed_component - pointer_speed:dot(normal) )/ pointer_r:length()  / ( math.pi / 180) )
						end
					end

				end

				break
			end
		end

	end

	if self.ui:getChildByPath('pointer'):isVisible() then
		processPointer(1)
	end

end


function TurnCtrl:notCalcStopping(sumSpeed, exactTarget)
	local finalTarget = standardAngle(self.target)
	local clockWise = sumSpeed >= 0

	self.turntablePhysics = {
		speed = sumSpeed,
		constant = false,
		finalTarget = finalTarget,
		tmp = true,
		state = 1,
		exactTarget = exactTarget,
	}

	local function onUpdate(deltaTime)
		if self.ui.isDisposed then return end
		if self:onPhysicsUpdate(deltaTime) then
			self.turntablePhysics.idle = true
			self.isBusy = false
			self:setEnabled(true)

		end	

	end
	self.turntable:unscheduleUpdate()

	if not exactTarget then
		self.turntable:scheduleUpdateWithPriority(onUpdate, 0)
	else
		self.turntable:stopAllActions()
		self.turntable:runAction(CCSequence:createWithTwoActions(
				CCRotateTo:create(0.5, 360*2+22.5),
				CCCallFunc:create(function ()
					self:onTurnFinish()
				end)
			))
	end
end


function TurnCtrl:calcStopping(sumSpeed)

	local finalTarget = standardAngle(self.target)
	local clockWise = sumSpeed >= 0

	self.turntablePhysics = {
		speed = sumSpeed,
		constant = false,
		finalTarget = finalTarget,
		tmp = true,
		state = 1, 
	}

	local function onUpdate(deltaTime)
		if self.ui.isDisposed then return end
		if self:onPhysicsUpdate(deltaTime) then
			self.turntablePhysics.idle = true

			self:onTurnFinish()
		end	
	end
	self.turntable:unscheduleUpdate()
	self.turntable:scheduleUpdateWithPriority(onUpdate, 0)
end


function TurnCtrl:onDragBegin()
end

function TurnCtrl:onDragEnd(speed)
	self:playCostAnim()

	local function findNormalIndex( ... )
		-- local index = 2
		-- for key, value in ipairs(self.rewardConfig) do

		-- 	if not Meta:isObjectId(value.itemId) then
		-- 		index = key
		-- 		break
		-- 	end
		-- end
		-- return index
		return 2
	end


	local function onSuccess(index, itemId, num)
		if self.ui.isDisposed then return end
		self:setTargetAngle(45 * (index - 1), 20)
		self.rewardItem = {
			itemId = itemId,
			num = num,
		}
		self:calcStopping(speed)
		
	end
	local function onFail(err)
		if self.ui.isDisposed then return end

		self:setTargetAngle(45*(findNormalIndex() - 1), 20)
		self:notCalcStopping(speed)
		
		-- CommonTip:showTip('因为网络问题，抽奖失败，请退出游戏重新刷新数据')

		if err and err.data then
			CommonTip:showTip(localize('error.tip.' .. err.data))
		end

	end
	local function onCancel()
		if self.ui.isDisposed then return end

		self:setTargetAngle(45*(findNormalIndex() - 1), 20)
		self:notCalcStopping(speed)

		-- CommonTip:showTip('因为网络问题，抽奖失败，请退出游戏重新刷新数据')
	end
	
	self.isBusy = true
	self:setEnabled(false)

	self:stayRotate(speed)

	self:sendRewardHttp(onSuccess, onFail, onCancel)
end

function TurnCtrl:playCostAnim()
	
end

function TurnCtrl:dispose( ... )
	self.model:removeObserver(self)
	self.ui:removeFromParentAndCleanup(true)
end

function TurnCtrl:sendRewardHttp(onSuccess, onFail, onCancel)
	self.model:receiveLotteryRewards(function ( rewards)
		local rewardItem = rewards[1]
		local index
		for key, value in ipairs(self.rewardConfig) do
			if value.itemId == rewardItem.itemId and value.num == rewardItem.num then
				index = key
				break
			end
		end

		if not index then
			if onCancel then
				onCancel()
			end
			return 
		end

		if onSuccess then
			onSuccess(index, rewardItem.itemId, rewardItem.num)
		end
	end, onFail, onCancel)
	
end

function TurnCtrl:onTurnFinish()

	if self.ui.isDisposed then
		if done then done() end
		return
	end

	local rewardItem = self.rewardItem

	local asyncRunner = Misc.AsyncFuncRunner.new()

	asyncRunner:add(function ( done )
		if self.ui.isDisposed then
			if done then done() end
			return
		end

		local rewardItem = {
			itemId = rewardItem.itemId,
			num = rewardItem.num
		}

		RankRaceGetRewardPanel:create(rewardItem):popout(done)

	end)


	asyncRunner:add(function ( done )

		if self.ui.isDisposed then
			if done then done() end
			return
		end

		self.isBusy = false
		self:setEnabled(true)
		self:refresh()


		self:refreshLight()
		callAncestors(self.ui, 'playHandAnim')

		
		if done then
			done()
		end

	end)

	asyncRunner:run()
end




return TurnCtrl