require 'zoo.gamePlay.propInteractions.BaseInteraction'
require 'zoo.itemView.PropsView'

-- 用于刷子道具
BrushInteraction = class(BaseInteraction)
function BrushInteraction:ctor(boardView, controller)
    self.waitingState = BaseInteractionState.new()
    self.touchedState = BaseInteractionState.new()
    self:setCurrentState(self.waitingState)
    self.itemPos = nil
    self.startPos = nil
    self.direction = nil
end

function BrushInteraction:handleTouchBegin(x, y)
    local touchPos = self.boardView:TouchAt(x, y)
    if not touchPos then
        return
    end

    if not self.boardView.gameBoardLogic:isItemInTile(touchPos.x, touchPos.y) then
        return
    end
    
    if not self.boardView.gameBoardLogic:canUseLineBrush(touchPos.x, touchPos.y)
    or not self.boardView.gameBoardLogic:isItemCanMoved(touchPos.x,touchPos.y) then
        PropsView:playLineBrushDisableAnimation(self.boardView, IntCoord:create(touchPos.x, touchPos.y))
        return 
    end

    self.boardView:focusOnItem(touchPos)
    
    if self.currentState == self.waitingState then
        self.itemPos = touchPos
        self.startPos = ccp(x, y)
        self:setCurrentState(self.touchedState)
    end
end

function BrushInteraction:handleTouchMove(x, y)

end

function BrushInteraction:handleTouchEnd(x, y)
    local touchPos = self.boardView:TouchAt(x, y)
    if not touchPos then
        return 
    end

    if self.currentState == self.touchedState then

        local absDeltaX = math.abs(x - self.startPos.x)
        local absDeltaY = math.abs(y - self.startPos.y)
        local animalType = 0
        self.direction = {x = 0, y = 0}
        if absDeltaX > absDeltaY then
            animalType = AnimalTypeConfig.kLine
            if x >= self.startPos.x then 
                self.direction.x = 1
            else 
                self.direction.x = -1 
            end
            self.direction.y = 0
        else
            animalType = AnimalTypeConfig.kColumn
            self.direction.x = 0
            if y >= self.startPos.y then
                self.direction.y = 1
            else
                self.direction.y = -1
            end
        end
        self:handleComplete()
    end
end

function BrushInteraction:onEnter()
    if _G.isLocalDevelopMode then printx(0, '>>> enter BrushInteraction') end
    self.itemPos = nil
    self.startPos = nil
    self.direction = nil
    self:setCurrentState(self.waitingState)
end

function BrushInteraction:onExit()
    if _G.isLocalDevelopMode then printx(0, '--- exit  BrushInteraction') end
end

function BrushInteraction:handleComplete()
    if self.controller then 
        self.controller:onInteractionComplete({itemPos = self.itemPos, direction = self.direction})
    end
    self:onEnter()
end