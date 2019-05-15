require "zoo.ui.halo.haloCore.HaloBaseMod"



-- CCLayer 在 onExit 和 onEnter 都有对 touchDelegate的处理 
-- 暂时不知道 阳仔说的 显示层次 和 touch 处理次序 不一致的情况 是 怎么发生的
-- 所以暂时不做任何处理




local function genEventType( t )
	return 'halo.touch.event.' .. t
end

HaloTouchEvent = {
	TOUCH_DOWN = genEventType(1),          -- 在触区内按下
	TOUCH_UP = genEventType(2),            -- 在触区内按下 又弹起（可在触区外弹起）
	TAP = genEventType(3),                 -- 在触区内按下 又弹起，必须都在触区内，并且不能滑太远
	TOUCH_MOVE = genEventType(4),          -- 在触区内按下 移动 （移动到触区外仍然可疑触发这个事件）
	LONG_PRESS = genEventType(5),          -- 在触区内按下 持续一段时间后 触发, 也不能滑太远
}


HaloTouchEventName = function ( eventType )
	return table.keyOf(HaloTouchEvent, eventType)
end

HaloInteractionMod = class(HaloBaseMod)


function HaloInteractionMod:onAttachTo( owner )
	if not self.data then return end

	self.notifyTap = preventContinuousClick(function ( ... )
		self:notify(HaloTouchEvent.TAP)
	end, self.data.minClickInterval)

	
	local inputLayer = Layer:create()
	self:getTargetHolder():addChild(inputLayer)
	inputLayer.refCocosObj:setZOrder(-100000)
	self.inputLayer = inputLayer
	self.inputLayer:setTouchEnabled(isTouchEnable, priority, isSwallowsTouches, hitTestFunc, careParent, alwaysUseHitTestFunc)
	self:registerInputHandler(self.inputLayer, self:getTargetHolder())
end

function HaloInteractionMod:onDetachFrom( owner )
	if self:getTargetHolder().isDisposed then return end
	if not self.data then return end
	self.inputLayer:removeFromParentAndCleanup(true)
end

function HaloInteractionMod:hadAttached( ... )
	return self:getTargetHolder() ~= nil
end

function HaloInteractionMod:build( data )
	-- brute reinit, for simple
	if self:hadAttached() then
		self:onDetachFrom(self:getTargetHolder())
		self.data = data
		self:onAttachTo(self:getTargetHolder())
	else
		self.data = data
	end
end

function HaloInteractionMod:create(haloInteractionModCreateData)
	local mod = HaloInteractionMod.new()
	mod:init(haloInteractionModCreateData or HaloInteractionMod:getDefaultCreateData())
	return mod
end

function HaloInteractionMod:getDefaultCreateData( ... )
	return {
		minClickInterval = 0.3,
		longPressNeedTime = 1, -- negative value means disable
		blockPenetration = true,
	}
end

function HaloInteractionMod:registerInputHandler( inputLayer, owner )

	self.touchedPos = ccp(0, 0)
	self.slideTooFar = false
	self.longPressTimer = nil

    local function onTouchCurrentLayer( eventType, x, y)
    	if inputLayer.isDisposed then 
			return false 
		end
        local worldPosition = ccp(x, y)
        if eventType == CCTOUCHBEGAN then
			if inputLayer.isDisposed then 
				return false 
			end
			if not inputLayer:isRealVisible() then
				return false
			end
			if not inputLayer:hitTestSafeArea(worldPosition) then
		    	return false
		    end
			local hit = false
			hit = owner:hitTestPoint(worldPosition, true) 
            if hit then
            	self.touchedPos = worldPosition
            	self.slideTooFar = false
					
				if self.data.longPressNeedTime > 0 then
					self.longPressTimer = setTimeOut(function ( ... )
						self.longPressTimer = nil
						if (not self.slideTooFar) then
							self:notify(HaloTouchEvent.LONG_PRESS)
						end
					end, self.data.longPressNeedTime)
				end

				self:notify(HaloTouchEvent.TOUCH_DOWN)

                return true
            else 
			    return false 
		    end
		elseif eventType == CCTOUCHMOVED then
			local deltaDistance = ccpDistance(self.touchedPos, worldPosition)
		    if deltaDistance >= 30 then 
		    	self.slideTooFar = true
		    end
			self:notify(HaloTouchEvent.TOUCH_MOVE)
		elseif eventType == CCTOUCHENDED then
			if self.longPressTimer then
		    	cancelTimeOut(self.longPressTimer)
		    	self.longPressTimer = nil
		    end
			self:notify(HaloTouchEvent.TOUCH_UP)

			local hit = false
			hit = owner:hitTestPoint(worldPosition, true) 

			if (not self.slideTooFar) and hit then
				self.notifyTap()
			end

		elseif eventType == CCTOUCHCANCELLED then	
			if self.longPressTimer then
		    	cancelTimeOut(self.longPressTimer)
		    	self.longPressTimer = nil
		    end
			self:notify(HaloTouchEvent.TOUCH_UP)
        end
    end

    local swallow = self.data.blockPenetration
    inputLayer:registerScriptTouchHandler(onTouchCurrentLayer, false, 0, swallow)
    inputLayer.refCocosObj:setTouchEnabled(true)
end

function HaloInteractionMod:ctor()
	self._className = "src.zoo.ui.halo.mods.HaloInteractionMod"
end


-- function HaloInteractionMod:init( createData )
-- 	self:build( createData )
-- end


function HaloInteractionMod:setTargetHolder( targetHolder )
	HaloBaseMod.setTargetHolder(self, targetHolder)
	self:onAttachTo(self:getTargetHolder())
end

function HaloInteractionMod:__onTargetHolderChanged( oldTargetHolder , targetHolder )
	self:onDetachFrom(oldTargetHolder)
	self:onAttachTo(targetHolder)
end

function HaloInteractionMod:notify( eventType, ... )
	if self:hadAttached() then
		printx(61, '[HaloInteractionMod]TS:' .. HeTimeUtil:getCurrentTimeMillis(), self:getTargetHolder():getName(), HaloTouchEventName(eventType))
		HaloBaseMod.notify(self, eventType, ...)
	end
end

return HaloInteractionMod