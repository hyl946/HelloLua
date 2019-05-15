require 'zoo.gamePlay.propInteractions.BaseInteraction'
require 'zoo.itemView.PropsView'

-- 用于刷子道具
BroomInteraction = class(BaseInteraction)

function BroomInteraction:ctor(boardView, controller)
    self.itemPos = nil
    self.waitingState = BaseInteraction.new()
    self.touchedState = BaseInteraction.new()
    self:setCurrentState(self.waitingState)
end

function BroomInteraction:handleTouchBegin(x, y)

    local touchPos = self.boardView:TouchAt(x, y)
    if not touchPos then
        return
    end

    if not self.boardView.gameBoardLogic:isItemInTile(touchPos.x, touchPos.y) then
        return
    end

    if self.currentState == self.waitingState then
        if self.boardView.gameBoardLogic:canUseBroom(touchPos.x, touchPos.y) then
            self.itemPos = {r = touchPos.x, c = touchPos.y}
            self:setCurrentState(self.touchedState)
        else
            PropsView:playBroomDisableAnimation(self.boardView, IntCoord:create(touchPos.x, touchPos.y))
        end
    end
end

function BroomInteraction:handleTouchMove(x, y)

end

function BroomInteraction:handleTouchEnd(x, y)
    local touchPos = self.boardView:TouchAt(x, y)
    if not touchPos then
        return 
    end

    if self.currentState == self.touchedState then
        -- 只有开始和结束在同一个格子，才认为是合法的操作
        if self.itemPos.r == touchPos.x and self.itemPos.c == touchPos.y then
            self:handleComplete()
        else
            -- 操作失败，或视为用户放弃
            self:setCurrentState(self.waitingState)
        end
    end
end

function BroomInteraction:onEnter()
    if _G.isLocalDevelopMode then printx(0, '>>> enter BroomInteraction') end
end

function BroomInteraction:onExit()
    if _G.isLocalDevelopMode then printx(0, '--- exit  BroomInteraction') end
end

function BroomInteraction:handleComplete()
    if self.controller then 
        self.controller:onInteractionComplete({itemPos = self.itemPos})
    end
end