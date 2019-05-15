require "zoo.panel.areaUnlock.UnlockTipPanel"
require "zoo.panel.areaUnlock.BlockerInfoPanel"

AreaBlockerShow = class()

function AreaBlockerShow:create(areaId, cloudX, cloudY)
	local show = AreaBlockerShow.new()
	show:init(areaId, cloudX, cloudY)
	return show
end

function AreaBlockerShow:init(areaId, cloudX, cloudY)
	self.hasBlocker = false
	self.areaId = areaId
	self.cloudX = cloudX
	self.cloudY = cloudY
	if areaId < 4 then return end
	local firstNewObstacleLevels = MetaManager:getInstance().global.firstNewObstacleLevels
	-- print(table.tostring(firstNewObstacleLevels))
    local unLockLevel = (self.areaId - 1) * 15 + 1
    if table.indexOf(firstNewObstacleLevels, unLockLevel) == nil then
    	return
	end

	self.unLockLevel = unLockLevel
	local str = "area_icon_" .. areaId .. "0000"
	if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(str) then
		--RemoteDebug:uploadLog("AreaBlockerShow:init  A1 " , tostring(self) , areaId, cloudX, cloudY)
		self.hasBlocker = true
		self.blockerIcon = Sprite:createWithSpriteFrameName(str)
		self.blockerIcon:setPositionXY(-1, 0)
		self.blockerIcon:setScale(0.9 * 0.95)
		self.iconFg = Sprite:createWithSpriteFrameName("area_blocker_fg0000")
		self.iconFg:setAnchorPoint(ccp(0.5, 0.5))
		self.ui = Layer:create()
		self.iconContainner = Layer:create()
		self.ui:addChild(self.iconContainner)
		self.iconContainner:addChild(self.blockerIcon)
		self.ui:addChild(self.iconFg)
		self.ui.rawX = self.cloudX + 460
		self.ui.rawY = self.cloudY - 25
		self.ui:setPositionXY(self.ui.rawX, self.ui.rawY)

		self.glowAnim = Sprite:createEmpty() --播点点动画
		self.glowAnim:setTexture(self.blockerIcon:getTexture())
		self.ui:addChild(self.glowAnim)

		self:startFloat()
	end
end

function AreaBlockerShow:reinit(areaId, cloudX, cloudY)
	self:stopFloat()

	--RemoteDebug:uploadLog("AreaBlockerShow:reinit  P1 " , tostring(self) , areaId, cloudX, cloudY)
	if self.ui and self.ui:getParent() and not self.ui.isDisposed then
		--RemoteDebug:uploadLog("AreaBlockerShow:reinit  P2 " , tostring(self) , areaId, cloudX, cloudY)
		self.ui:removeFromParentAndCleanup(true)
	end

	self:init(areaId, cloudX, cloudY)

	--self:startFloat()
end

function AreaBlockerShow:hide( ... )
	if self.hasBlocker and self.ui ~= nil and not self.ui.isDisposed then
		self.ui:setVisible(false)
	end
end

local timeSlice = 0.03
local DotGenRadius = 65
local DotInitNum = 2
local GroupDotGenGapTime = 35
local DotGenGapTime = 3
local CenterX = 0
local CenterY = 0

function AreaBlockerShow:getOneGroupGlowAnim()
	if self.ui == nil or self.ui.isDisposed then return end

	self:createDot(DotInitNum)
	local addGap = 0
	for i = 1, 12 do
		addGap = addGap + DotGenGapTime + math.random(2, 4)
		local addNum = 1 + math.random(0, 1)
		self.glowAnim:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(timeSlice * addGap), 
																CCCallFunc:create(function( ... )
																	self:createDot(addNum)
																end)))
	end
end

function AreaBlockerShow:createDot(addNum)
	if self.ui == nil or self.ui.isDisposed then return end
	for i = 1, addNum do self.glowAnim:addChild(self:getADot(CenterX, CenterY, DotGenRadius, 60, 40, -20)) end
end

function AreaBlockerShow:getADot(centerX, centerY, dotRadius, randomRadius, flyX, flyY)
	local dotIcon = Sprite:createWithSpriteFrameName("area_blocker_fg_glow0000")
	dotIcon:setScale(0.7 + math.random())
	local angle = -math.pi * (0.5 - math.random())
	if angle < 0 then
		angle = angle - math.pi / 6
	else
		angle = angle + math.pi / 6
	end
	local radius = dotRadius + math.random(randomRadius)
	local dotPosX, dotPosY = centerX + radius * math.sin(angle), centerY + radius * math.cos(angle)
	dotIcon:setPositionXY(dotPosX, dotPosY)
	local toX, toY = flyX + math.random(6), -flyY - math.random(10)
	if angle < 0 then toX = -toX end
	local moveTime = timeSlice * (20 + math.random(3))
	local move = CCMoveBy:create(moveTime, ccp(toX, toY))
	local fadeOut = CCSequence:createWithTwoActions(CCDelayTime:create(moveTime / 3), CCFadeOut:create(moveTime * 2 / 3))
	local spawn = CCSpawn:createWithTwoActions(move, fadeOut)
	local del = CCCallFunc:create(function()
		if dotIcon.isDisposed or dotIcon:getParent() == nil then return end
		dotIcon:removeFromParentAndCleanup(true)
	end)
	dotIcon:runAction(CCSequence:createWithTwoActions(spawn, del))

	return dotIcon
end

function AreaBlockerShow:onIconTapped(event)
	local tipStr = localize("area.blockerShow.clkTip.otherInfo.area" .. self.areaId)
	CommonTip:showTip(tipStr, "positive")
	DcUtil:UserTrack({category = "cirrusshow", sub_category = "start", t1 = 3, t3 = self.areaId}, true)
	printx( 1 , tipStr)
end

function AreaBlockerShow:startFloat()
	--printx(1, "AreaBlockerShow:startFloat  " , debug.traceback() )
	if self.hasBlocker then
		self.ui:stopAllActions()
		self.ui:setPositionXY(self.ui.rawX, self.ui.rawY)
		self.glowAnim:removeChildren(true)
		local floatDown = CCMoveBy:create(2.1, ccp(0, -25))
  		local floatUp = CCMoveBy:create(2.1, ccp(0, 25))
		self.ui:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(floatDown, floatUp)))
		local getOneGroupGlowAnim = CCCallFunc:create(function() self:getOneGroupGlowAnim() end)
		local gapTime = CCDelayTime:create(timeSlice * GroupDotGenGapTime)
		self.ui:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(getOneGroupGlowAnim, gapTime)))

		--[[
		self.tappedCallback = function (event) 
			self:onIconTapped(event)
		end
		]]

		--self.iconContainner:removeAllEventListeners()
		--self.iconContainner:addEventListener(DisplayEvents.kTouchTap, self.tappedCallback)
	end
end

function AreaBlockerShow:stopFloat()
	--printx(1, "AreaBlockerShow:stopFloat  " , debug.traceback() )
	if self.hasBlocker then
		
		self.ui:stopAllActions()
		self.glowAnim:stopAllActions()
		self.glowAnim:removeChildren(true)
		
		--self.iconContainner:removeAllEventListeners()
	end
end

function AreaBlockerShow:fadeOut(levelNode, callBack)
	if self.hasBlocker then
		DcUtil:UserTrack({category = "cirrusshow", sub_category = "end", t1 = 3, t3 = self.areaId}, true)
		if self.ui and not self.ui.isDisposed then
			if not self.ui:isVisible() then
				callBack()
				return
			end
			local delay = CCDelayTime:create(timeSlice * 15)
			local call = CCCallFunc:create(function( ... )
				self:__fadeOut(levelNode, callBack)
			end)
			self.ui:runAction(CCSequence:createWithTwoActions(delay, call))

			-- self.ui:runAction(CCSequence:createWithTwoActions(delay, call))
			--其他地方，会调用stop，把action干掉
			setTimeOut(function ( ... )
				self:__fadeOut(levelNode, callBack)
			end, timeSlice * 15)
			
		else
			callBack()
		end
	else
		callBack()
	end
end

function AreaBlockerShow:__fadeOut(levelNode, callBack)
	if not self.ui or self.ui.isDisposed then
		callBack()
		return
	end

	self:stopFloat()
	local blockerAnimTime = 12
	local scaleTo = CCScaleTo:create(blockerAnimTime * timeSlice, 0.37)
	local fadeTo = CCFadeTo:create(blockerAnimTime * timeSlice, 127)
	local endCallBack = CCCallFunc:create(function( ... )
		if self.ui and not self.ui.isDisposed then
			self.ui:setVisible(false)
		end
	end)
	self.ui:runAction(CCSequence:createWithTwoActions(CCSpawn:createWithTwoActions(scaleTo, fadeTo), endCallBack))

	self.flyGlow = Sprite:createWithSpriteFrameName("area_blocker_fade_out_glow0000")
	self.flyGlow:setAnchorPoint(ccp(0.5, 0.5))
	self.flyGlow:setScaleX(1.048)
	self.flyGlow:setScaleY(0.897)
	self.flyGlow:setPositionXY(self.ui:getPositionX(), self.ui:getPositionY())
	self.ui:getParent():addChild(self.flyGlow)
	self.flyGlow:setVisible(false)
	local ary = CCArray:create()
	ary:addObject(CCDelayTime:create(timeSlice * 9))
	ary:addObject(CCCallFunc:create(function( ... )
		if self.flyGlow and not self.flyGlow.isDisposed then
			self.flyGlow:setVisible(true)
		end
	end))
	ary:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(timeSlice *3, 0.943, 0.872), CCFadeTo:create(timeSlice * 3, 153)))

	scaleTo = CCScaleTo:create(3 * timeSlice, 0.653, 0.66)
	fadeTo = CCFadeTo:create(3 * timeSlice, 199)
	local subAnim1 = CCSpawn:createWithTwoActions(scaleTo, fadeTo)
	scaleTo = CCScaleTo:create(6 * timeSlice, 0.468, 0.473)
	fadeTo = CCFadeTo:create(6 * timeSlice, 255)
	local subAnim2 = CCSpawn:createWithTwoActions(scaleTo, fadeTo)
	local glowToPos = levelNode:getPosition()
	glowToPos = ccp(glowToPos.x, glowToPos.y - 46)
	ary:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(timeSlice * 9, glowToPos), CCSequence:createWithTwoActions(subAnim1, subAnim2)))
	ary:addObject(CCCallFunc:create(function( ... )
		if self.flyGlow and not self.flyGlow.isDisposed then
			self:playNodeAnim(levelNode, callBack)
		else
			callBack()
		end
	end))
	ary:addObject(CCScaleTo:create(timeSlice * 3, 1.051, 0.982))
	ary:addObject(CCFadeTo:create(timeSlice * 3, 0))
	ary:addObject(CCCallFunc:create(function( ... )
		if self.flyGlow and not self.flyGlow.isDisposed then
			self.flyGlow:removeFromParentAndCleanup(true)
		end
	end))
	self.flyGlow:runAction(CCSequence:create(ary))
end

function AreaBlockerShow:playNodeAnim(levelNode, callBack)
	for i = 1, 11 do self.flyGlow:addChild(self:getADot(101, 100, 50, 40, 10, 10)) end
	callBack()
end

function AreaBlockerShow:checkTouched(gPos)
	if not self.hasBlocker then return false end
	if not self.ui:isVisible() then return false end

	if self.iconContainner:hitTestPoint(gPos, true) then
		return true
	end

	return false
end

function AreaBlockerShow:doTouched()
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	local topPassedLevelId = UserManager:getInstance():getTopPassedLevel()
	local unLockLevel = (self.areaId - 1) * 15 + 1
	if unLockLevel - topLevelId <= 15 and topPassedLevelId ~= unLockLevel - 1 then
		UnlockTipPanel:create(self.areaId, true):popout()
	else
	
		-- local tipStr = localize("area.blockerShow.clkTip.otherInfo.area" .. self.areaId)
		-- CommonTip:showTip(tipStr, "positive")
		BlockerInfoPanel:create(self.areaId):popout()
		DcUtil:UserTrack({category = "cirrusshow", sub_category = "start", t1 = 3, t3 = self.areaId}, true)
	end
	
end