require 'zoo.gamePlay.propInteractions.BaseInteraction'
require 'zoo.itemView.PropsView'

ForceSwapInteraction = class(BaseInteraction)
function ForceSwapInteraction:ctor()
    self.item1Pos = nil
    self.item2Pos = nil
    self.firstWaitingState = BaseInteractionState.new('firstWaitingState')
    self.firstTouchedState = BaseInteractionState.new('firstTouchedState')
    self.secondWaitingState = BaseInteractionState.new('secondWaitingState')
    self.secondTouchedState = BaseInteractionState.new('secondTouchedState')
    self:setCurrentState(self.firstWaitingState) -- init
end

function ForceSwapInteraction:handleTouchBegin(x, y)

    local touchPos = self.boardView:TouchAt(x, y)
    if not touchPos then return end

    if not self.boardView.gameBoardLogic:isItemInTile(touchPos.x, touchPos.y) then
        return
    end

    if not self.boardView.gameBoardLogic:isItemCanMoved(touchPos.x, touchPos.y) then
        PropsView:playForceSwapDisableAnimation(self.boardView, IntCoord:create(touchPos.x, touchPos.y))
        return
    end

    if self.currentState == self.firstWaitingState then
        self.item1Pos = touchPos
        self:setCurrentState(self.firstTouchedState)
        self.boardView:focusOnItem(touchPos)

        self.swapHint = PropsAnimation:playSwapHintEffect(touchPos.x,touchPos.y,self.boardView)
    elseif self.currentState == self.secondWaitingState then
        if not BaseInteraction.isEqualPos(touchPos, self.item1Pos) then -- 点击不同一个格子
            -- 可以交换
            if self.boardView.gameBoardLogic:canUseForceSwap(self.item1Pos.x, self.item1Pos.y, touchPos.x, touchPos.y) then

                self.item2Pos = touchPos
                self:setCurrentState(self.secondTouchedState)
                self:handleComplete()
            else -- 不能交换
                self.item1Pos = touchPos
                self:setCurrentState(self.firstTouchedState)
                self.boardView:focusOnItem(touchPos)

                self:removeHint()
                self.swapHint = PropsAnimation:playSwapHintEffect(touchPos.x,touchPos.y,self.boardView)
            end
        else
            self.item1Pos = touchPos
            self:setCurrentState(self.firstTouchedState)
            self.boardView:focusOnItem(touchPos)
            
            self:removeHint()
            self.swapHint = PropsAnimation:playSwapHintEffect(touchPos.x,touchPos.y,self.boardView)
        end
    else 
        -- error
        assert(false, 'ForceSwapInteraction state error')
    end
end


-- 用于普通交换 & 强制交换
function ForceSwapInteraction:handleTouchMove(x, y)
    local touchPos = self.boardView:TouchAt(x, y)
    if not touchPos then 
        return  
    end

    if not self.item1Pos then
        return 
    end

    -- 不是棋盘上
    if not self.boardView.gameBoardLogic:isItemInTile(touchPos.x, touchPos.y) then
        return
    end

    -- 不能移动
    if not self.boardView.gameBoardLogic:isItemCanMoved(touchPos.x, touchPos.y) then
        -- 仅仅在上下左右4个方向上显示提示
        if (math.abs(self.item1Pos.x - touchPos.x) + math.abs(self.item1Pos.y - touchPos.y) == 1) then
            PropsView:playForceSwapDisableAnimation(self.boardView, IntCoord:create(touchPos.x, touchPos.y))
        end
        return
    end

     -- 仍在同一个格子内
    if BaseInteraction.isEqualPos(touchPos, self.item1Pos) then
        return 
    end

    if self.currentState == self.firstTouchedState then
    
        if self.boardView.gameBoardLogic:canUseForceSwap(self.item1Pos.x, self.item1Pos.y, touchPos.x, touchPos.y) then
            self.item2Pos = touchPos
            self:handleComplete()
        else -- 不能交换, 重新开始
            PropsView:playForceSwapDisableAnimation(self.boardView, IntCoord:create(self.item1Pos.x, self.item1Pos.y))

            self:removeHint()
            self.boardView:focusOnItem(nil)
            self.item1Pos = nil
            self.item2Pos = nil
            self:setCurrentState(self.firstWaitingState)
        end
    end
end

function ForceSwapInteraction:handleTouchEnd(x, y)
    local touchPos = self.boardView:TouchAt(x, y)
    if not touchPos then 
        return  
    end

    if self.currentState == self.firstTouchedState then
        if BaseInteraction.isEqualPos(self.item1Pos, touchPos) then
            self.item1Pos = touchPos
            if _G.isLocalDevelopMode then printx(0, touchPos.x, touchPos.y) end
        end
        self:setCurrentState(self.secondWaitingState)
    end
end

function ForceSwapInteraction:onEnter()
    if _G.isLocalDevelopMode then printx(0, '>>> enter ForceSwapInteraction') end
    self.item1Pos = nil
    self.item2Pos = nil
    self:setCurrentState(self.firstWaitingState)
end

function ForceSwapInteraction:onExit()
    if _G.isLocalDevelopMode then printx(0, '--- exit  ForceSwapInteraction') end
    self:removeHint()
end

function ForceSwapInteraction:removeHint( ... )
    if self.swapHint then
        self.swapHint:remove()
        self.swapHint = nil
    end
end

function ForceSwapInteraction:handleComplete()
    if self.controller then
        self.controller:onInteractionComplete({item1Pos = self.item1Pos, item2Pos = self.item2Pos})
    end
    self:onEnter()
end