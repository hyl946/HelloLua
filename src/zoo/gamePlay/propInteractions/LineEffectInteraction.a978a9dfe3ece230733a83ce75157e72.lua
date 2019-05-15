require 'zoo.gamePlay.propInteractions.BaseInteraction'
require 'zoo.itemView.PropsView'

-- 直接释放的横竖范围特效
LineEffectInteraction = class(BaseInteraction)
function LineEffectInteraction:ctor()
    self.waitingState = BaseInteractionState.new()
    self.touchedState = BaseInteractionState.new()
    self:setCurrentState(self.waitingState)
    self.startPos = nil
    self.itemPos = nil
end

function LineEffectInteraction:handleTouchBegin(x, y)
	-- printx(11, "============ Line Effect. Touch Begin!", x, y)
    if self.currentState == self.waitingState then
        self.startPos = nil

        local touchPos = self.boardView:TouchAt(x, y)
        if self:isGridPositionValid(touchPos) then
            self.isTypeColumn = false
            if self.controller.boardView.gamePropsType == GamePropsType.kColumnEffect 
                or self.controller.boardView.gamePropsType == GamePropsType.kColumnEffect_l
                then
                self.isTypeColumn = true
            end
            -- printx(11, "=== isColumn:", self.isTypeColumn)

            self.startPos = touchPos
            self.itemPos = touchPos
            self:setCurrentState(self.touchedState)

            self:showEffectRangeView(touchPos)
            self:checkGridDataValid(touchPos)
        end
    end
end

-- 滑动中...
function LineEffectInteraction:handleTouchMove(x, y)
    if self.currentState == self.touchedState and self.startPos then

        local touchPos = self.boardView:TouchAt(x, y)
        if not self:isGridPositionValid(touchPos) then
        	self:hideEffectRangeView()
        	self.itemPos = nil
        	return
        end

        -- 仍在同一个格子内
        if self.itemPos and BaseInteraction.isEqualPos(touchPos, self.itemPos) then
            return 
        end

        -- 更新滑动中的视图
        self:checkGridDataValid(touchPos)
        self:hideEffectRangeView()
        self:showEffectRangeView(touchPos)

        self.itemPos = touchPos
    end
end

function LineEffectInteraction:handleTouchEnd(x, y)
    -- printx(11, "============== Line Effect. touch end ==============", debug.traceback())
    local touchPos = self.boardView:TouchAt(x, y)
    self:hideEffectRangeView()

    local resetToWaiting = false

    if not self:isGridPositionValid(touchPos) then
        resetToWaiting = true
    end

    if not resetToWaiting and self.currentState == self.touchedState then
    	local targetValid = self:checkGridDataValid(touchPos)
    	if targetValid then
    		self.itemPos = touchPos
    		self:handleComplete()
    	else
    		resetToWaiting = true
    	end
    end

    if resetToWaiting then
        self.startPos = nil
        self.itemPos = nil
        self:setCurrentState(self.waitingState)
    end
end

-- 是否在格子上
function LineEffectInteraction:isGridPositionValid(touchedGrid)
	if not touchedGrid then 
		return false 
	end
    if not self.boardView.gameBoardLogic:isItemInTile(touchedGrid.x, touchedGrid.y) then
        return false
    end

    return true
end

-- 格子上对象是否是有效目标
function LineEffectInteraction:checkGridDataValid(touchedGrid)
	if self.boardView.gameBoardLogic:canUseLineEffectOnGrid(touchedGrid.x, touchedGrid.y) then
		return true
	else
        PropsView:playLineEffectDisableAnimation(self.boardView, IntCoord:create(touchedGrid.x, touchedGrid.y), self.isTypeColumn)
        return false
    end
end

-- 画面上提示特效范围
function LineEffectInteraction:showEffectRangeView(touchedGrid)
	self.boardView:showSelectRowOrColumnEffect(touchedGrid.x, touchedGrid.y, self.isTypeColumn)
end

-- 隐藏特效范围的提示
function LineEffectInteraction:hideEffectRangeView()
	self.boardView:removeSelectRowOrColumnEffect()
end

function LineEffectInteraction:onEnter()
    if _G.isLocalDevelopMode then printx(0, '>>> enter LineEffectInteraction') end
    self.startPos = nil
    self.itemPos = nil
    self:setCurrentState(self.waitingState)
end

function LineEffectInteraction:onExit()
    if _G.isLocalDevelopMode then printx(0, '--- exit  LineEffectInteraction') end
end

function LineEffectInteraction:handleComplete()
    if _G.isLocalDevelopMode then printx(0, 'LineEffectInteraction:handleComplete()') end
    if self.controller then
        self.controller:onInteractionComplete({itemPos = self.itemPos})
    end
    self:onEnter()
end