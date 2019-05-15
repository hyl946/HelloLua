TriggerHandler = class()

function TriggerHandler:tryMatch(mainLogic)

end

function TriggerHandler:handle(mainLogic)

end


VenomTargetHightlightHandler = class(TriggerHandler)

function VenomTargetHightlightHandler:tryMatch(mainLogic)
    local isMatch = false

    if not mainLogic.gameMode:is(OrderMode) and not mainLogic.gameMode:is(SeaOrderMode) then
        return isMatch
    end

    -- 可以确定GameMode就是OrderMode或者SeaOrderMode
    local hasNoOctopus = (not mainLogic.gameMode:hasOctopus())
    local targetIsVenom, targetVenomCount, finishedCount = mainLogic.gameMode:targetIsVenom()
    local venomCount = mainLogic.gameMode:getVenomCount()
    local venomIsNotEnough = (targetVenomCount - finishedCount > venomCount)
    return hasNoOctopus and targetIsVenom and (venomCount <= 3 and venomCount > 0) and venomIsNotEnough
end

function VenomTargetHightlightHandler:handle(mainLogic, matchResult)
    if self._hasShowRaccoon == nil then
        self._hasShowRaccoon = false
    end
    local showRaccoon = (not self._hasShowRaccoon and matchResult == true)
    if showRaccoon == true then
        self._hasShowRaccoon = true
    end
    if mainLogic.PlayUIDelegate then
        mainLogic.PlayUIDelegate.levelTargetPanel:highlightTarget('order4', 3, matchResult, showRaccoon)
    end
end