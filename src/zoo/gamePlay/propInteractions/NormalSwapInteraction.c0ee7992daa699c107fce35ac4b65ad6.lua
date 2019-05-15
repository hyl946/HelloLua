require 'zoo.gamePlay.propInteractions.BaseInteraction'
require 'zoo.itemView.PropsView'

NormalSwapInteraction = class(BaseInteraction)
function NormalSwapInteraction:ctor()
    self.item1Pos = nil
    self.item2Pos = nil
    self.firstWaitingState = BaseInteractionState.new('firstWaitingState')
    self.firstTouchedState = BaseInteractionState.new('firstTouchedState')
    self.secondWaitingState = BaseInteractionState.new('secondWaitingState')
    self.secondTouchedState = BaseInteractionState.new('secondTouchedState')

    self.effectState = BaseInteractionState.new("effectState")
    self:setCurrentState(self.firstWaitingState) -- init

    self.lastBeginX = 0
    self.lastBeginY = 0
end

-----------------------------------------------------------------------------------------------
----------------------------新算法为了解决偶尔快速交换会卡住的问题-----------------------------
-----------------------------------------------------------------------------------------------

function NormalSwapInteraction:handleTouchBegin(x, y)

    local touchPos , offsetInGrid = self.boardView:TouchAt(x, y)

    self.lastBeginX = x
    self.lastBeginY = y
    self.lastBeginOffsetXInGrid = offsetInGrid.x
    self.lastBeginOffsetYInGrid = offsetInGrid.y

    if not self.boardView.gameBoardLogic:isItemInTile(touchPos.x, touchPos.y) then
        return
    end

    GameExtandPlayLogic:onItemTouchBegin( self.boardView.gameBoardLogic , touchPos.x , touchPos.y )

    if (self.currentState == self.firstWaitingState or 
         self.currentState == self.secondWaitingState ) and 
        self.boardView.gameBoardLogic:isCanEffectLikeProp(touchPos.x, touchPos.y) then
        self.item1Pos = touchPos
        self:setCurrentState(self.effectState)
        return
    end

    if not self.boardView.gameBoardLogic:isItemCanMoved(touchPos.x, touchPos.y) then
        return
    end

    if self.currentState == self.firstWaitingState then
        self.item1Pos = touchPos
        self:setCurrentState(self.firstTouchedState)
        self.boardView:focusOnItem(touchPos)
    elseif self.currentState == self.secondWaitingState then
        if not BaseInteraction.isEqualPos(touchPos, self.item1Pos) then -- 点击不同一个格子
            -- 可以交换
            if 0 < self.boardView.gameBoardLogic:canBeSwaped(self.item1Pos.x, self.item1Pos.y, touchPos.x, touchPos.y) then
                self.item2Pos = touchPos
                self:setCurrentState(self.secondTouchedState)
                self:handleComplete()
            else -- 不能交换
                self.item1Pos = touchPos
                self:setCurrentState(self.firstTouchedState)
                self.boardView:focusOnItem(touchPos)
            end
        else
            self.item1Pos = touchPos
            self:setCurrentState(self.firstTouchedState)
            self.boardView:focusOnItem(touchPos)
        end
    else 
        -- error
        assert(false, 'NormalSwapInteraction state error')
    end
end


-- 用于普通交换 & 强制交换
function NormalSwapInteraction:handleTouchMove(x, y)

    if not self.item1Pos then
        return 
    end

    if self.currentState == self.effectState then
        return
    end
    local disHorizontal = (x - self.lastBeginX) / GamePlayConfig_Tile_ScaleX
    local disVertical = (y - self.lastBeginY) / GamePlayConfig_Tile_ScaleY

    local disToTop = GamePlayConfig_Tile_Height - self.lastBeginOffsetYInGrid
    local disToBottom = self.lastBeginOffsetYInGrid
    local disToLeft = self.lastBeginOffsetXInGrid
    local disToRight = GamePlayConfig_Tile_Width - self.lastBeginOffsetXInGrid
    
    local dx = 0
    local dy = 0

    if disHorizontal > 0 then
        if disHorizontal >= disToRight then
            dx = 1
        end
    elseif disHorizontal < 0 then
        if math.abs(disHorizontal) >= disToLeft then
            dx = -1
        end
    end

    if dx == 0 then
        if disVertical > 0 then
            if disVertical >= disToTop then
                dy = -1
            end
        elseif disVertical < 0 then
            if math.abs(disVertical) >= disToBottom then
                dy = 1
            end
        end
    end
    

    local targetPos = nil
    if dx ~= 0 then
        targetPos = ccp(self.item1Pos.x , self.item1Pos.y + dx)
    elseif dy ~= 0 then
        targetPos = ccp(self.item1Pos.x + dy , self.item1Pos.y )
    end
    
    if targetPos then

        if not self.boardView.gameBoardLogic:isItemInTile(targetPos.x, targetPos.y) then --不在有效棋盘内
            return
        end

        if self.currentState == self.firstTouchedState and
            0 < self.boardView.gameBoardLogic:canBeSwaped(self.item1Pos.x, self.item1Pos.y, targetPos.x, targetPos.y) then
            --printx( 1 , "    canBeSwaped  !!!!!!!!!!!!!!!!!!!!")
            self.item2Pos = targetPos
            self:handleComplete()
        end
    end
end

function NormalSwapInteraction:handleTouchEnd(x, y)
    local touchPos = self.boardView:TouchAt(x, y)

    if self.currentState == self.firstTouchedState then
        if BaseInteraction.isEqualPos(self.item1Pos, touchPos) then
            self.item1Pos = touchPos
            if _G.isLocalDevelopMode then printx(0, touchPos.x, touchPos.y) end
        end
        self:setCurrentState(self.secondWaitingState)
    elseif self.currentState == self.effectState then
        self.item2Pos = touchPos
        if BaseInteraction.isEqualPos(self.item1Pos, touchPos) then -- 只能在原位置，否则视为取消，重新进入等待状态
            local gameItemMap = self.boardView.gameBoardLogic.gameItemMap
            if gameItemMap and gameItemMap[touchPos.y] and gameItemMap[touchPos.y][touchPos.x] then
                local item = gameItemMap[touchPos.x][touchPos.y]
                if item.hedgehogLevel > 1 then
                    self.controller.boardView.gamePropsType = GamePropsType.kHedgehogCrazy
                elseif item.wukongState == TileWukongState.kReadyToJump then
                   self.controller.boardView.gamePropsType = GamePropsType.kWukongJump
                end
            end
            self:handleComplete()
        else
            self.item1Pos = nil
            self.item2Pos = nil
            self:setCurrentState(self.firstWaitingState)
        end
    end
end

-----------------------------------------------------------------------------------------------
--[[
function NormalSwapInteraction:handleTouchBegin(x, y)

    local touchPos = self.boardView:TouchAt(x, y)
    if not touchPos then return end

    GameExtandPlayLogic:onItemTouchBegin( self.boardView.gameBoardLogic , touchPos.x , touchPos.y )

    if (self.currentState == self.firstWaitingState or 
         self.currentState == self.secondWaitingState ) and 
        self.boardView.gameBoardLogic:isCanEffectLikeProp(touchPos.x, touchPos.y) then
        self.item1Pos = touchPos
        self:setCurrentState(self.effectState)
        return
    end

    if not self.boardView.gameBoardLogic:isItemInTile(touchPos.x, touchPos.y) then
        return
    end

    if not self.boardView.gameBoardLogic:isItemCanMoved(touchPos.x, touchPos.y) then
        return
    end

    if self.currentState == self.firstWaitingState then
        self.item1Pos = touchPos
        self:setCurrentState(self.firstTouchedState)
        self.boardView:focusOnItem(touchPos)
    elseif self.currentState == self.secondWaitingState then
        if not BaseInteraction.isEqualPos(touchPos, self.item1Pos) then -- 点击不同一个格子
            -- 可以交换
            if 0 < self.boardView.gameBoardLogic:canBeSwaped(self.item1Pos.x, self.item1Pos.y, touchPos.x, touchPos.y) then
                self.item2Pos = touchPos
                self:setCurrentState(self.secondTouchedState)
                self:handleComplete()
            else -- 不能交换
                self.item1Pos = touchPos
                self:setCurrentState(self.firstTouchedState)
                self.boardView:focusOnItem(touchPos)
            end
        else
            self.item1Pos = touchPos
            self:setCurrentState(self.firstTouchedState)
            self.boardView:focusOnItem(touchPos)
        end
    else 
        -- error
        assert(false, 'NormalSwapInteraction state error')
    end
end


-- 用于普通交换 & 强制交换
function NormalSwapInteraction:handleTouchMove(x, y)
    local touchPos = self.boardView:TouchAt(x, y)
    if not touchPos then 
        return  
    end

    if not self.item1Pos then
        return 
    end

    if self.currentState == self.effectState then
        return
    end

    local targetPos = ccp(touchPos.x, touchPos.y)
    -- 目标位置修正
    if math.abs(self.item1Pos.x - touchPos.x) > 1 then
        local dx = self.item1Pos.x > touchPos.x and -1 or 1
        targetPos.x = self.item1Pos.x + dx
    elseif math.abs(self.item1Pos.y - touchPos.y) > 1 then
        local dy = self.item1Pos.y > touchPos.y and -1 or 1
        targetPos.y = self.item1Pos.y + dy
    end
    -- 不是棋盘上
    if not self.boardView.gameBoardLogic:isItemInTile(targetPos.x, targetPos.y) then
        return
    end

     -- 仍在同一个格子内
    if BaseInteraction.isEqualPos(targetPos, self.item1Pos) then
        return 
    end

    if self.currentState == self.firstTouchedState then
        if 0 < self.boardView.gameBoardLogic:canBeSwaped(self.item1Pos.x, self.item1Pos.y, targetPos.x, targetPos.y) then
            self.item2Pos = targetPos
            self:handleComplete()
        end
    end
end

function NormalSwapInteraction:handleTouchEnd(x, y)
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
    elseif self.currentState == self.effectState then
        self.item2Pos = touchPos
        if BaseInteraction.isEqualPos(self.item1Pos, touchPos) then -- 只能在原位置，否则视为取消，重新进入等待状态
            local gameItemMap = self.boardView.gameBoardLogic.gameItemMap
            if gameItemMap and gameItemMap[touchPos.y] and gameItemMap[touchPos.y][touchPos.x] then
                local item = gameItemMap[touchPos.x][touchPos.y]
                if item.hedgehogLevel > 1 then
                    self.controller.boardView.gamePropsType = GamePropsType.kHedgehogCrazy
                elseif item.wukongState == TileWukongState.kReadyToJump then
                   self.controller.boardView.gamePropsType = GamePropsType.kWukongJump
                end
            end
            self:handleComplete()
        else
            self.item1Pos = nil
            self.item2Pos = nil
            self:setCurrentState(self.firstWaitingState)
        end
    end
end
]]

function NormalSwapInteraction:onEnter()
    if _G.isLocalDevelopMode then printx(0, '>>> enter NormalSwapInteraction') end
    self.item1Pos = nil
    self.item2Pos = nil
    self:setCurrentState(self.firstWaitingState)
end

function NormalSwapInteraction:onExit()
    if _G.isLocalDevelopMode then printx(0, '--- exit  NormalSwapInteraction') end
end

function NormalSwapInteraction:handleComplete()
    if self.controller then
        self.controller:onInteractionComplete({item1Pos = self.item1Pos, item2Pos = self.item2Pos})
    end
    self:onEnter()
end