WukongGiftState = class(BaseStableState)

WukongBossConfig = {}
-- real config
WukongBossConfig[1] = {animal_num = 1, blood = 25, clouds = 0, drop_sapphire = 10, moves = 0, specialHitBlood = 3, 
                buffBlood = 4, buffRate = 0.3, addStepRate = 0.3, buffNum = 1, buffLimit = 3, deadbuffNum = 3}
WukongBossConfig[2] = {animal_num = 1, blood = 40, clouds = 0, drop_sapphire = 13, moves = 0, specialHitBlood = 3, 
                buffBlood = 4, buffRate = 0.3,  addStepRate = 0.3, buffNum = 1, buffLimit = 3, deadbuffNum = 3}
WukongBossConfig[3] = {animal_num = 1, blood = 55, clouds = 0, drop_sapphire = 17, moves = 0, specialHitBlood = 3, 
                buffBlood = 4, buffRate = 0.3, addStepRate = 0.3, buffNum = 1, buffLimit = 3, deadbuffNum = 3}
WukongBossConfig[4] = {animal_num = 1, blood = 65, clouds = 0, drop_sapphire = 25, moves = 13, specialHitBlood = 3, 
                buffBlood = 4, buffRate = 0.3, addStepRate = 0.3, buffNum = 1, buffLimit = 3, deadbuffNum = 3}
WukongBossConfig[5] = {animal_num = 2, blood = 90, clouds = 0, drop_sapphire = 20, moves = 5, specialHitBlood = 3, 
                buffBlood = 0, buffRate = 0.3, addStepRate = 0.3, buffNum = 0, buffLimit = 0, deadbuffNum = 0}

function WukongGiftState:create(context)
    local v = WukongGiftState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function WukongGiftState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function WukongGiftState:update(dt)
    
end

function WukongGiftState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kWukong]]) then
        printx(0, '!skip')
        self:onActionComplete()
        return
    end

    --self:onActionComplete()
    self:tryHandleCasting()
end

function WukongGiftState:tryHandleCasting()

    local mainLogic = self.mainLogic
    local gameItemMap = mainLogic.gameItemMap
    local boardmap = mainLogic.boardmap

    -- bonus time
    if mainLogic.isBonusTime then
        self:onActionComplete(1)
        return
    end

    -- get the lamps
    local monkeys = {}
    local castingMonkeys = {}
    for r = 1, #gameItemMap do
        for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item and item.ItemType == GameItemType.kWukong 
            	and ( item.wukongState == TileWukongState.kGift )
            	and item:isAvailable() then
                table.insert(monkeys, item)
            end
        end
    end

    if #monkeys == 0 then
        self:onActionComplete(2)
        return
    end

    local count = 0

    local function actionCallback()
        count = count + 1
        if count >= #castingMonkeys then
            self:onActionComplete(3)
            self.mainLogic:setNeedCheckFalling()
            --self.context:onEnter() --不会引起棋盘掉落
        end
    end


    for k, v in pairs(monkeys) do

        local monkey = v
        local moneyBoard = boardmap[monkey.y][monkey.x]
        if moneyBoard and moneyBoard.isWukongTarget then

        	
        	local action = GameBoardActionDataSet:createAs(
                        GameActionTargetType.kGameItemAction,
                        GameItemActionType.kItem_Wukong_Gift,
                        IntCoord:create(v.y, v.x),
                        nil,
                        GamePlayConfig_MaxAction_time
                    )
	        action.completeCallback = actionCallback
            local count = wukongCastingCount + 1
            if count > 5 then count = 5 end

			local buffBlood = WukongBossConfig[count].buffBlood
            --local buffRate = WukongBossConfig[count].buffRate
            local buffRate = 1 --必掉，不走配置
            --local addStepRate = WukongBossConfig[count].addStepRate
			local addStepRate = 1 --必掉，不走配置
			local buffNum = WukongBossConfig[count].buffNum
			local buffLimit = WukongBossConfig[count].buffLimit

            local banPositions = {}
			local function getPostion( count , fromRow, toRow)
				local result = {}
				result = GameExtandPlayLogic:getNormalPositionsForBoss(mainLogic, count , fromRow, toRow, banPositions)
                for k, v in pairs(result) do 
                    table.insert(banPositions, v)
                end

				return result
			end

            local addStepPositions = {}
            local lineAndColumnPositions = {}
            local warpPositions = {}

            local rand = mainLogic.randFactory:rand(1, 2)
            if true or rand == 1 then
                lineAndColumnPositions = getPostion( 2 , 7 , 9 )
                warpPositions = getPostion( 1 , 7 , 9 )
            else
                addStepPositions = getPostion( 1 , 7 , 9 )
            end

			--AnimalTypeConfig.kLine  kColumn  kWrap
			
			action.addStepPositions = addStepPositions
			action.lineAndColumnPositions = lineAndColumnPositions
			action.warpPositions = warpPositions

            --[[
			if #addStepPositions + #lineAndColumnPositions + #warpPositions > 0 then
				table.insert( castingMonkeys , monkey )
				self.mainLogic:addGameAction(action)
			end
            ]]
            self.mainLogic:addGameAction(action)
            table.insert( castingMonkeys , monkey )

            --dropProps()

			monkey.wukongState = TileWukongState.kReadyToChangeColor
        end
    end

    if #castingMonkeys == 0 then
    	self:onActionComplete(5)
    end
end

function WukongGiftState:onExit()
    BaseStableState.onExit(self)
end

function WukongGiftState:checkTransition()
    return self.nextState
end

function WukongGiftState:onActionComplete(aaaa)
    self.nextState = self:getNextState()
end

function WukongGiftState:getNextState( ... )
    -- body
    return nil
end

function WukongGiftState:getClassName( ... )
    -- body
    return "WukongGiftState"
end



-------------------------------------------------------------
WukongGiftInLoop = class(WukongGiftState)
function WukongGiftInLoop:create(context)
    local v = WukongGiftInLoop.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function WukongGiftInLoop:getClassName()
    return "WukongGiftInLoop"
end

function WukongGiftInLoop:getNextState()
    return self.context.balloonCheckStateInLoop
end

