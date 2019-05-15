require 'zoo.gamePlay.propInteractions.BaseInteraction'
require 'zoo.itemView.PropsView'

-- 用于刷子道具
RandomBirdInteraction = class(BaseInteraction)

function RandomBirdInteraction:ctor(boardView, controller)

end

function RandomBirdInteraction:handleTouchBegin(x, y)

end

function RandomBirdInteraction:handleTouchMove(x, y)

end

function RandomBirdInteraction:handleTouchEnd(x, y)
    if _G.isLocalDevelopMode then printx(0, 'RandomBirdInteraction:handleTouchEnd') end
    -- 为什么一定要放在touch end里才回调呢？
    -- 因为prop list animation处理播放动画是在touch end里面
    -- 因此，道具使用的confirm一定要在动画之后在调用才正常
    -- 因此，此处必须放在touch end，而不能比这更早
    self:handleComplete()
end

function RandomBirdInteraction:onEnter()
    if _G.isLocalDevelopMode then printx(0, '>>> enter RandomBirdInteraction') end
end

function RandomBirdInteraction:onExit()
    if _G.isLocalDevelopMode then printx(0, '--- exit  RandomBirdInteraction') end
end

function RandomBirdInteraction:handleComplete()
    if self.controller then 
        self.controller:onInteractionComplete()
    end
end