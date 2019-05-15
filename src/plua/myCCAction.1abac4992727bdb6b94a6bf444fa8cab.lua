myCCAction = class()

function myCCAction:retain() end
function myCCAction:release() end


function myCCAction:ctor()
	self.curFrame = 0
	self.actionQuere = {}
	self.actionQuere[1] = self
	self.actionQuereLen = 0
end

function myCCAction:copy()
	local act = myCCAction.new()
	act.curFrame = 0
	act.onFnished = self.onFnished
	act.node = self.node
	return act
end

function myCCAction:update(dt)
	local len = self.actionQuereLen
	local curAction = nil
	local curActionIndex = 0
	for i=1, len do
		curAction = self.actionQuere[i]
		if curAction then
			curActionIndex = i
			break
		end
	end
	
	if curAction then
		local ret = curAction:actionUpdate(dt)
		if ret then
			self.actionQuere[curActionIndex] = nil
		end
		return false
	else
		return true
	end
	
end

function myCCAction:addAction(act)
	for k, a in pairs(act.actionQuere) do
		self.actionQuere[#self.actionQuere + 1] = a
	end
	self.actionQuereLen = #self.actionQuere
end

function myCCAction:actionUpdate(dt)
	if self.curFrame > 0 then
		if self.onFnished ~= nil then
			self.onFnished(self.node)
		end
		return true
	end
	self.curFrame = self.curFrame + 1
	return false
end

function myCCAction:create(onFnished, node)
	local act = myCCAction.new()
	act.curFrame = 0
	act.onFnished = onFnished
	act.node = node
	return act
end

function myCCAction:setTag(tag)
	self.tag = tag
end

function myCCAction:isDone()
	return true
end

CCSpeed = class(myCCAction)
function CCSpeed:create()
	return myCCAction:create()
end

CCFollow = class(myCCAction)
function CCFollow:create()
	return myCCAction:create()
end

CCRepeat = class(myCCAction)
function CCRepeat:create()
	return myCCAction:create()
end

CCRepeatForever = class(myCCAction)
function CCRepeatForever:create()
	return myCCAction:create()
end


CCRotateTo = class(myCCAction)
function CCRotateTo:create()
	return myCCAction:create()
end

CCRotateBy = class(myCCAction)
function CCRotateBy:create()
	return myCCAction:create()
end

CCMoveTo = class(myCCAction)
function CCMoveTo:create()
	return myCCAction:create()
end

CCMoveBy = class(myCCAction)
function CCMoveBy:create()
	return myCCAction:create()
end

CCSkewTo = class(myCCAction)
function CCSkewTo:create()
	return myCCAction:create()
end

CCSkewBy = class(myCCAction)
function CCSkewBy:create()
	return myCCAction:create()
end

CCJumpBy = class(myCCAction)
function CCJumpBy:create()
	return myCCAction:create()
end

CCJumpTo = class(myCCAction)
function CCJumpTo:create()
	return myCCAction:create()
end

CCBezierBy = class(myCCAction)
function CCBezierBy:create()
	return myCCAction:create()
end

CCBezierTo = class(myCCAction)
function CCBezierTo:create()
	return myCCAction:create()
end

HeBezierTo = class(myCCAction)
function HeBezierTo:create()
	return myCCAction:create()
end

CCScaleTo = class(myCCAction)
function CCScaleTo:create()
	return myCCAction:create()
end

CCSizeTo = class(myCCAction)
function CCSizeTo:create()
	return myCCAction:create()
end

CCScaleBy = class(myCCAction)
function CCScaleBy:create()
	return myCCAction:create()
end

CCBlink = class(myCCAction)
function CCBlink:create()
	return myCCAction:create()
end

CCFadeIn = class(myCCAction)
function CCFadeIn:create()
	return myCCAction:create()
end

CCFadeOut = class(myCCAction)
function CCFadeOut:create()
	return myCCAction:create()
end

CCFadeTo = class(myCCAction)
function CCFadeTo:create()
	return myCCAction:create()
end

CCTintTo = class(myCCAction)
function CCTintTo:create()
	return myCCAction:create()
end

CCTintBy = class(myCCAction)
function CCTintBy:create()
	return myCCAction:create()
end


CCEaseSineInOut = class(myCCAction)
function CCEaseSineInOut:create()
	return CCEaseSineInOut:new()
end

CCActionEase = class(myCCAction)
function CCActionEase:create()
	return CCActionEase:new()
end

CCEaseIn = class(myCCAction)
function CCEaseIn:create()
	return CCEaseIn:new()
end


CCEaseOut = class(myCCAction)
function CCEaseOut:create()
	return CCEaseOut:new()
end


CCEaseInOut = class(myCCAction)
function CCEaseInOut:create()
	return CCEaseInOut:new()
end

CCEaseExponentialIn = class(myCCAction)
function CCEaseExponentialIn:create()
	return CCEaseExponentialIn:new()
end

CCEaseExponentialOut = class(myCCAction)
function CCEaseExponentialOut:create()
	return CCEaseExponentialOut:new()
end


CCEaseExponentialInOut = class(myCCAction)
function CCEaseExponentialInOut:create()
	return CCEaseExponentialInOut:new()
end


CCEaseSineIn = class(myCCAction)
function CCEaseSineIn:create()
	return CCEaseSineIn:new()
end


CCEaseSineOut = class(myCCAction)
function CCEaseSineOut:create()
	return CCEaseSineOut:new()
end


CCEaseSineInOut = class(myCCAction)
function CCEaseSineInOut:create()
	return CCEaseSineInOut:new()
end


CCEaseElasticOut = class(myCCAction)
function CCEaseElasticOut:create()
	return CCEaseElasticOut:new()
end

CCEaseBounceOut = class(myCCAction)
function CCEaseBounceOut:create()
	return CCEaseBounceOut:new()
end

CCEaseBackIn = class(myCCAction)
function CCEaseBackIn:create()
	return CCEaseBackIn:new()
end

CCEaseBackOut = class(myCCAction)
function CCEaseBackOut:create()
	return CCEaseBackOut:new()
end





CCDelayTime = class(myCCAction)
function CCDelayTime:actionUpdate(dt)
	self.curTime = self.curTime + dt
	if self.curTime > self.time then
		if self.onFnished ~= nil then
			self.onFnished(node)
		end
		return true
	end
	return false	
end

function CCDelayTime:create(time)
	local delay = CCDelayTime:new()
	if type(time) ~= "number" then
		delay.time = 0
	else
		delay.time = time
	end
	
	delay.curTime = 0
	return delay
end

CCReverseTime = class(myCCAction)
function CCReverseTime:create()
	return myCCAction:create()
end

CCTargetedAction = class(myCCAction)
function CCTargetedAction:create()
	return myCCAction:create()
end

CCShow = class(myCCAction)
function CCShow:create()
	return myCCAction:create()
end

CCHide = class(myCCAction)
function CCHide:create()
	return myCCAction:create()
end

CCToggleVisibility = class(myCCAction)
function CCToggleVisibility:create()
	return myCCAction:create()
end

CCFlipY = class(myCCAction)
function CCFlipY:create()
	return myCCAction:create()
end

CCFlipX = class(myCCAction)
function CCFlipX:create()
	return myCCAction:create()
end

CCPlace = class(myCCAction)
function CCPlace:create()
	return myCCAction:create()
end

CCEaseSineOut = class(myCCAction)
function CCEaseSineOut:create()
	return CCEaseSineOut.new()
end

CCEaseElasticOut = class(myCCAction)
function CCEaseElasticOut:create()
	return CCEaseElasticOut.new()
end

CCEaseQuarticBackOut = class(myCCAction)
function CCEaseQuarticBackOut:create()
	return CCEaseQuarticBackOut.new()
end

CCParabolaMoveTo = class(myCCAction)
function CCParabolaMoveTo:create()
	return CCParabolaMoveTo.new()
end



CCCallFunc = class(myCCAction)
function CCCallFunc:create(callBack)
	local ccfun =  CCCallFunc.new(callBack)
	ccfun.onFnished = callBack
	return ccfun
end

CCAnimate = class(myCCAction)
function CCAnimate:create()
	return CCAnimate.new()
end



