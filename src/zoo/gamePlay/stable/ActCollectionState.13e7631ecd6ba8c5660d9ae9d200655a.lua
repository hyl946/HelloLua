
ActCollectionState = class(BaseStableState)

function ActCollectionState:create(context)
    local v = ActCollectionState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end
function ActCollectionState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function ActCollectionState:update(dt)
end

function ActCollectionState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    if ActCollectionLogic:isActEffectedLevel() then 
   		self:tryTurn() 
   	else
   		self:onActionComplete()
   	end
end

function ActCollectionState:tryTurn()
    if ActCollectionLogic:checkGenLimit() then 
    	local turnSuc = ActCollectionLogic:handleTurn(function ()
    		self:onActionComplete()
    	end)
    	if turnSuc then 
    		ActCollectionLogic:resetUseMove()
    	else
    		self:onActionComplete()
    	end 
    else
    	self:onActionComplete()
    end
end

function ActCollectionState:getClassName()
    return "ActCollectionState"
end

function ActCollectionState:checkTransition()
    return self.nextState
end

function ActCollectionState:onActionComplete()
    -- self.nextState = self:getNextState()	
    self.mainLogic:refreshComplete()
end

-- function ActCollectionState:getNextState()
--     return self.context.tileTransferState
-- end

function ActCollectionState:onExit()
    BaseStableState.onExit(self)
    self.nextState = nil
end


--Bonus State
-- WukongJumpState 跟在这个后面 现在不用先取消了
----
ActCollectionStateInBonus = class(BaseStableState)
function ActCollectionStateInBonus:create(context)
    local v = ActCollectionStateInBonus.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function ActCollectionStateInBonus:onEnter()
    BaseStableState.onEnter(self)

    if ActCollectionLogic:isActEffectedLevel() then 
        self.nextState = nil
        self:tryTurnRemain()
    else
        self:TurnRemainComplete()
    end
end

function ActCollectionStateInBonus:getClassName()
    return "ActCollectionStateInBonus"
end

function ActCollectionStateInBonus:getNextState()
    return self.context.bonusEffectState
end

function ActCollectionStateInBonus:TurnRemainComplete()
    self.nextState = self:getNextState()
end

function ActCollectionStateInBonus:tryTurnRemain()
    local RemainStep = self.mainLogic.theCurMoves or 0

    local InitNum = 0
    local CallBackNum = 0
    local function ActionCallBack()
        CallBackNum = CallBackNum + 1

        if CallBackNum == InitNum then
            self:TurnRemainComplete()
        end
    end

    if RemainStep > 0 then
        for i=1, RemainStep do
            ActCollectionLogic:addUseMove()
            if ActCollectionLogic:checkGenLimit() then 
        	    local turnSuc = ActCollectionLogic:handleTurn(function ()
                    ActionCallBack()
        	    end)

                if turnSuc then 
                    InitNum = InitNum + 1
        		    ActCollectionLogic:resetUseMove()
        	    end
            end
        end
    end

    local function initEnd()
        if not self.mainLogic.isDisposed then
            self:TurnRemainComplete()
        end
    end

    if InitNum > 0 then
        self.mainLogic:setNeedCheckFalling()
    else
        self:TurnRemainComplete()
    end

end

function ActCollectionStateInBonus:checkTransition()
    return self.nextState
end

function ActCollectionStateInBonus:onExit()
    BaseStableState.onExit(self)
    self.nextState = nil
end