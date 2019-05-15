BuffBoomGenerateState = class(BaseStableState)

function BuffBoomGenerateState:create(context)
    local v = BuffBoomGenerateState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function BuffBoomGenerateState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function BuffBoomGenerateState:update(dt)
    
end

function BuffBoomGenerateState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    self.hasItemToHandle = false
    
    if self:tryCreateBuffByInitBuffPassedPlanList() then
        --do nothing
    elseif GameInitBuffLogic:hasBuffTypeD() then
    	if not self:tryCreateNewBuffBoom() then
    		self:onActionComplete()
    	end
    elseif GameInitBuffLogic:hasBuffOfTypeInLevel(InitBuffType.FIRECRACKER, {InitBuffCreateType.PRE_BUFF_ACTIVITY}) then    -- 由后续每轮生成
        if not self:tryCreateNewFirecracker() then
            self:onActionComplete()
        end
    else
    	self:onActionComplete()
    end
    
end

function BuffBoomGenerateState:tryCreateNewFirecracker()
    -- printx(11, "= = = PrePropsGenerateState:tryCreateNewFirecracker = = =")
    local maxAmount = 2 -- 初始第一个走的是前置道具的逻辑，不在此列考虑
    local firecrackerGeneratedByStep = math.max(self.mainLogic.generateFirecrackerTimesForPreBuff - 1, 0)
    if firecrackerGeneratedByStep >= maxAmount then
        return false
    end
    local realCostMove = self.mainLogic.realCostMoveWithoutBackProp
    local unlockAmount = math.floor(realCostMove / 10)
    local toGenerateAmount = math.min(unlockAmount - firecrackerGeneratedByStep, maxAmount - firecrackerGeneratedByStep)

    if toGenerateAmount >= 1 then
        local resultList = GameInitBuffLogic:tryCreateNewFirecrackerAndReturnPositon(toGenerateAmount)
        if resultList and #resultList > 0 then
            self:createAddFirecreackerAction(resultList)
            return true
        end
    end

    return false
end


function BuffBoomGenerateState:createAddFirecreackerAction(resultList)
    local function completeCallback()
        self.genCounter = self.genCounter - 1
        if self.genCounter <= 0 then
            self:onActionComplete()
        end
    end

    local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
    local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local destYInWorldSpace = visibleOrigin.y + visibleSize.height / 2 + 100
    local centerPosX = visibleOrigin.x + visibleSize.width / 2
    local totalSelected = #resultList
    local itemPadding = 190 - 10 * totalSelected

    self.genCounter = 0
    local itemIndex = 0

    for _, data in ipairs(resultList) do
        self.genCounter = self.genCounter + 1
        itemIndex = itemIndex + 1

        local action =  GameBoardActionDataSet:createAs(
            GameActionTargetType.kPropsAction,
            GameItemActionType.kAddBuffItemToBoard,
            nil,
            nil,
            GamePlayConfig_MaxAction_time)
        action.completeCallback = completeCallback
        action.initBuffResult = resultList

        local animeType , datas = GameInitBuffLogic:getAddBuffAnimeType()
        action.animeType = animeType
        action.animeTypeParameter = tostring(InitBuffType.FIRECRACKER)

        self.mainLogic:addGlobalCoreAction(action)
        SnapshotManager:stop()
    end
end


function BuffBoomGenerateState:tryCreateBuffByInitBuffPassedPlanList()
    local buffPosition = GameInitBuffLogic:tryCreateBuffPositonByInitBuffPassedPlanList()

    local function callback()
        self:onActionComplete()
    end

    if buffPosition and #buffPosition> 0 then
        local action =  GameBoardActionDataSet:createAs(
            GameActionTargetType.kPropsAction,
            GameItemActionType.kAddBuffItemToBoard,
            nil,
            nil,
            GamePlayConfig_MaxAction_time)
        action.completeCallback = callback
        action.initBuffResult = buffPosition

        -- GameInitBuffLogic:setAddBuffAnimeType( AddGameInitBuffAnimeType.kDefault )

        local animeType , datas = GameInitBuffLogic:getAddBuffAnimeType()
        action.animeType = animeType
        action.animeTypeParameter = datas

        self.mainLogic:addGlobalCoreAction(action)
        SnapshotManager:stop()

        return true
    end

    return false
end

function BuffBoomGenerateState:tryCreateNewBuffBoom()

	local realCostMove = self.mainLogic.realCostMoveWithoutBackProp
	local lastCreateBuffBoomMoveSteps = self.mainLogic.lastCreateBuffBoomMoveSteps

	if realCostMove > 10 and realCostMove % 10 == 1 and realCostMove > lastCreateBuffBoomMoveSteps then

		self.mainLogic.lastCreateBuffBoomMoveSteps = realCostMove

		local buffPosition = GameInitBuffLogic:tryCreateNewBuffBoomAndReturnPositon()

		local function callback()
			self:onActionComplete()
		end

        if buffPosition and #buffPosition > 0 then
            local action =  GameBoardActionDataSet:createAs(
                GameActionTargetType.kPropsAction,
                GameItemActionType.kAddBuffItemToBoard,
                nil,
                nil,
                GamePlayConfig_MaxAction_time)
            action.completeCallback = callback
            action.initBuffResult = buffPosition

            action.animeType = AddGameInitBuffAnimeType.kDefault
            action.animeTypeParameter = nil

            self.mainLogic:addGlobalCoreAction(action)
            SnapshotManager:stop()

            return true
        end
		
	end

	return false
end

function BuffBoomGenerateState:getClassName()
    return "BuffBoomGenerateState"
end

function BuffBoomGenerateState:checkTransition()
    return self.nextState
end

function BuffBoomGenerateState:onActionComplete(needEnter)
    self.nextState = self:getNextState()
    if needEnter then
    	self.context:onEnter()
    end
end

function BuffBoomGenerateState:getNextState()
    -- return self.context.checkHedgehogCrazyState
    return self.context.scoreBuffBottleGenrateState
end

function BuffBoomGenerateState:onExit()
    BaseStableState.onExit(self)
end