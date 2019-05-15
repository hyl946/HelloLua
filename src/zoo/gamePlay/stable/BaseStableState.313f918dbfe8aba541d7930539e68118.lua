
BaseStableState = class()

function BaseStableState:ctor()
	
end

function BaseStableState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function BaseStableState:create(context)
	local v = BaseStableState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function BaseStableState:update(dt)
	
end

function BaseStableState:onEnter()
	if(isLocalDevelopMode) then
		printx( -1 , "---->>>> " .. self:getClassName() .. " state enter")
	end
	self.isUpdateStopped = false
end

function BaseStableState:onExit()
	if(isLocalDevelopMode) then
		printx( -1 , "----<<<< " .. self:getClassName() .. " state exit")
	end
end

function BaseStableState:getClassName( ... )
	assert(false)
	return "BaseStableState"
end

function BaseStableState:checkTransition()
	
end

function BaseStableState:stopUpdate()
	self.isUpdateStopped = true
end
