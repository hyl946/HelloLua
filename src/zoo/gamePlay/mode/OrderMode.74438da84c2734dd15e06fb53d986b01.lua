OrderMode = class(MoveMode)

function OrderMode:initModeSpecial(config)
    if config.orderMap then
        for k,v in pairs(config.orderMap) do
            local ts1 = 0
            local ts2 = 0
            local ts3 = 0
            for k2,v2 in pairs(v) do
                if k2 == "k" then
                    local thestrings = v2:split("_")
                    ts1 = tonumber(thestrings[1])
                    ts2 = tonumber(thestrings[2])
                end
                if k2 == "v" then
                    ts3 = tonumber(v2)
                end
            end
            self:addToOrderList(ts1,ts2,ts3)
        end
    end
end

function OrderMode:useMove()
    if self._isWaitingBackProp then
        -- fail level
        self._isVenomFail = true
        self:setFailReason('venom')
        -- self.mainLogic:setGamePlayStatus(GamePlayStatus.kFailed)
    end
    MoveMode.useMove(self)
end

function OrderMode:afterFail()
    if self._isWaitingBackProp then
        self.mainLogic:setGamePlayStatus(GamePlayStatus.kFailed)
    else
        MoveMode.afterFail(self)
    end
end

function OrderMode:reachEndCondition()

    if self:targetIsVenom() 
        and not self:hasOctopus() 
        and not self:venomTargetReached() 
        and self:getVenomCount() == 0 
        and not self._isWaitingBackProp then
        -- 弹过提示就不再弹
        --[[
        if not self._hasShownPrompt and self.mainLogic.PlayUIDelegate then
            self.mainLogic.PlayUIDelegate:promptBackProp()
            self._hasShownPrompt = true
        end
        ]]
        -- 还是要等待回退道具
        self._isWaitingBackProp = true
    else

        if self._isVenomFail then
            return true
        else
            return  MoveMode.reachEndCondition(self) or self:checkOrderListFinished()
        end
    end
end

function OrderMode:reachTarget()
    return self:checkOrderListFinished()
end

function OrderMode:saveDataForRevert(saveRevertData)
    local mainLogic = self.mainLogic
    local cloneOrderList = {}
    for k, v in ipairs(mainLogic.theOrderList) do
        table.insert(cloneOrderList, v:copy())
    end
    saveRevertData.theOrderList = cloneOrderList
    saveRevertData._hadInvisibleOrderItems = mainLogic._hadInvisibleOrderItems
    MoveMode.saveDataForRevert(self,saveRevertData)
end

function OrderMode:revertDataFromBackProp()
    self._isWaitingBackProp = false
    local mainLogic = self.mainLogic
    mainLogic.theOrderList = mainLogic.saveRevertData.theOrderList
    mainLogic._hadInvisibleOrderItems = mainLogic.saveRevertData._hadInvisibleOrderItems
    MoveMode.revertDataFromBackProp(self)
end

function OrderMode:revertUIFromBackProp()
    local mainLogic = self.mainLogic
    for i,v in ipairs(mainLogic.theOrderList) do
        if mainLogic.PlayUIDelegate then
            local num = v.v1 - v.f1
            if num < 0 then num = 0 end
            mainLogic.PlayUIDelegate:revertTargetNumber(v.key1, v.key2, num)
        end
    end
    MoveMode.revertUIFromBackProp(self)
end

function OrderMode:checkOrderListFinished()
    for i,v in ipairs(self.mainLogic.theOrderList) do
        if v.f1 < v.v1 then
            return false
        end
    end
    return true
end

function OrderMode:addToOrderList(key1,key2,v1)
    local orderData = GameItemOrderData:create(key1,key2,v1)
    local counts = #self.mainLogic.theOrderList
    self.mainLogic.theOrderList[counts + 1] = orderData
end

function OrderMode:hasOctopus()
    -- 只初始一遍，避免重复遍历
    if not self._hasOctopus then
        self._hasOctopus = self.mainLogic:hasItemOfType(GameItemType.kPoisonBottle)
    end
    return self._hasOctopus
end

function OrderMode:targetIsVenom()
    local orderList = self.mainLogic.theOrderList
    local targetIsVenom = false
    local targetCount = 0
    local finishedCount = 0
    for k, v in pairs(orderList) do 
        if v.key1 == 4 and v.key2 == 3 then
            targetIsVenom = true
            targetCount = v.v1
            finishedCount = v.f1
        end
    end
    return targetIsVenom, targetCount, finishedCount
end

function OrderMode:getVenomCount()
    local gameItemMap = self.mainLogic.gameItemMap
    local count = 0
    for r = 1, #gameItemMap do 
        for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item and item.ItemType == GameItemType.kVenom then
                count = count + 1
            end
        end
    end

    local backItemMap = self.mainLogic.backItemMap
    for r = 1, 9 do 
        for c = 1, 9 do
            if backItemMap[r] and backItemMap[r][c] then
                local item = backItemMap[r][c]
                if item and item.ItemType == GameItemType.kVenom then
                    count = count + 1
                end
            end
        end
    end

    return count
end

function OrderMode:venomTargetReached()
    local orderList = self.mainLogic.theOrderList
    for k, v in pairs(orderList) do 
        if v.key1 == 4 and v.key2 == 3 then
            if v.v1 <= v.f1 then
                return true
            end
        end
    end
    return false
end