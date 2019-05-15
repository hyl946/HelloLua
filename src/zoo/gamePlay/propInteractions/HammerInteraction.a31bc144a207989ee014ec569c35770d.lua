require 'zoo.gamePlay.propInteractions.BaseInteraction'
require 'zoo.itemView.PropsView'

-- 用于锤子道具
HammerInteraction = class(BaseInteraction)
function HammerInteraction:ctor(boardView, controller)
    self.waitingState = BaseInteractionState.new('waitingState')
    self:setCurrentState(self.waitingState)
end

function HammerInteraction:handleTouchBegin(x, y)
    if _G.isLocalDevelopMode then printx(0, 'HammerInteraction:handleTouchBegin()') end
    local touchPos = self.boardView:TouchAt(x, y)

    if not touchPos then
        return 
    end

    if not self.boardView.gameBoardLogic:isItemInTile(touchPos.x, touchPos.y) then
        return
    end

    if self.currentState == self.waitingState then
        if self.boardView.gameBoardLogic:canUseHammer(touchPos.x, touchPos.y) then
            self.itemPos = touchPos
            self:handleComplete()
        else
            if self.controller.boardView.gamePropsType == GamePropsType.kJamSpeardHummer then
                PropsView:playJamSpeardHammerDisableAnimation(self.boardView, IntCoord:create(touchPos.x, touchPos.y))
            else
                PropsView:playHammerDisableAnimation(self.boardView, IntCoord:create(touchPos.x, touchPos.y))
            end
        end
    end
end

function HammerInteraction:handleTouchMove(x, y)

end

function HammerInteraction:handleTouchEnd(x, y)

end

function HammerInteraction:onEnter()
    if _G.isLocalDevelopMode then printx(0, '>>> enter HammerInteraction') end
end

function HammerInteraction:onExit()
    if _G.isLocalDevelopMode then printx(0, '--- exit  HammerInteraction') end
end

function HammerInteraction:handleComplete()
    if _G.isLocalDevelopMode then printx(0, 'HammerInteraction:handleComplete()') end
    if self.controller then
        self.controller:onInteractionComplete({itemPos = self.itemPos})
    end
    self:onEnter()
end