Blocker199State = class(BaseStableState)

function Blocker199State:create(context)
    local v = Blocker199State.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function Blocker199State:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function Blocker199State:update(dt)
    
end

function Blocker199State:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    self.hasItemToHandle = false

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kBlocker199]]) then
        printx(0, '!skip')
        self:onActionComplete()
        return
    end

    self:tryChangeColor()
end

function Blocker199State:tryChangeColor()
    local mainLogic = self.mainLogic
    local gameItemMap = mainLogic.gameItemMap
    local changeBlockerCount = 0
    local jsq = 0

    -- bonus time
    if mainLogic.isBonusTime then
        self:onActionComplete()
        return
    end

    local function actionCallback()
        jsq = jsq + 1
        if jsq >= changeBlockerCount then
            self.hasItemToHandle = true
            self:onActionComplete()
        end
    end

    for r = 1, #gameItemMap do
        for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item and item.ItemType == GameItemType.kBlocker199 then
            	--if _G.isLocalDevelopMode then printx(0, tostring(item:isAvailable()), item.level, tostring(item.isActive), item._encrypt.ItemColorType) end
            	if item:isAvailable() and item.level == 0 and item.isActive and item._encrypt.ItemColorType == 0 then
                    self.needCheckMatch = true
            		changeBlockerCount = changeBlockerCount + 1
            		local possibleColors = GameMapInitialLogic:getPossibleColorsForItem(mainLogic, item.y, item.x)
            		local targetColors = {}

                    local blocker199ColorCfg
                    if item.blocker199Colors and #item.blocker199Colors > 0 then
                        blocker199ColorCfg = item.blocker199Colors
                    else
                        blocker199ColorCfg = mainLogic.blocker199Cfg
                    end

            		for _, color in ipairs(blocker199ColorCfg) do--如果是blocker配置了、地图上没有的颜色
			            if not table.exist(mainLogic.mapColorList, color) and not ColorFilterLogic:checkColorMatch(r, c, color) then
			                table.insert(targetColors, color)
			            end
			        end
            		for _, color in ipairs(blocker199ColorCfg) do--地图上可以出现并且配置了的颜色
			            if table.exist(possibleColors, color) then
			                table.insert(targetColors, color)
			            end
			        end

			        local newColor = nil
			        if #targetColors == 0 then
			            newColor = blocker199ColorCfg[mainLogic.randFactory:rand(1, #blocker199ColorCfg)]
			        else
			            newColor = targetColors[mainLogic.randFactory:rand(1, #targetColors)]
			        end

			        item._encrypt.ItemColorType = newColor
                    if item.flag then
                        item.subtype = self:getNextSubType(item.blocker199Dirs, item.subtype)
                    end
			        local action = GameBoardActionDataSet:createAs(
                        GameActionTargetType.kGameItemAction,
                        GameItemActionType.kItem_Blocker199_Reinit,
                        IntCoord:create(item.y, item.x),
                        nil,
                        GamePlayConfig_MaxAction_time
                    )
			        action.completeCallback = actionCallback
                    action.type = item.subtype
			        action.color = newColor
                    action.isRotation = item.flag
			        self.mainLogic:addGameAction(action)
                    if not item.flag then item.flag = true end
                end
            end
        end
    end

    if changeBlockerCount == 0 then--没有需要变色的直接完成
        self:onActionComplete()
        return
    end
end

function Blocker199State:getNextSubType(blocker199DirCfg, curDirType)
    local curDirIndex
    local nextDirIndex
    if not blocker199DirCfg then blocker199DirCfg = {1,2,3,4} end
    for i,v in ipairs(blocker199DirCfg) do
        if v == curDirType then
            curDirIndex = i
            break
        elseif v > curDirType then
            nextDirIndex = i
            break
        end
    end
    local maxDirNum = #blocker199DirCfg
    if curDirIndex then
        if curDirIndex == maxDirNum then
            return blocker199DirCfg[1]
        else
            return blocker199DirCfg[curDirIndex + 1]
        end
    else
        return blocker199DirCfg[nextDirIndex] or blocker199DirCfg[1]
    end
end

function Blocker199State:getClassName()
    return "Blocker199State"
end

function Blocker199State:checkTransition()
    return self.nextState
end

function Blocker199State:onActionComplete()

    if self.needCheckMatch then
        local result = ItemHalfStableCheckLogic:checkAllMapWithNoMove(self.mainLogic)
        self.nextState = self:getNextState()
        if result then
            self.mainLogic:setNeedCheckFalling()
            self.context.needLoopCheck = true
        else
            self.context:onEnter()
        end
    else

        self.nextState = self:getNextState()
        if self.hasItemToHandle then
            self.context:onEnter()
        end
    end
end

function Blocker199State:getNextState()
    return self.context.squidRunState
    -- return self.context.dripCastingStateInLast_B
    --return self.context.wukongReinitState
end

function Blocker199State:onExit()
    BaseStableState.onExit(self)
    self.hasItemToHandle = nil
    self.nextState = nil
    self.needCheckMatch = nil
end