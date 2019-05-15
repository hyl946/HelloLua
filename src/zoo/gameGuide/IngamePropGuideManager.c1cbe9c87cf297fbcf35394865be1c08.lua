local STRONG_TYPE = 'strong'
local WEAK_TYPE = 'weak'
local EXTRA_TYPE = 'extra'


IngamePropGuideManager = class()


local instance 
function IngamePropGuideManager:getInstance()
    if not instance then
        instance = IngamePropGuideManager.new()
        instance:init()
    end
    return instance
end

function IngamePropGuideManager:init()

end

local function foreach_item(callback)
    local logic = GameBoardLogic:getCurrentLogic()
    for r=1, 9 do
        for c=1, 9 do
            if logic.gameItemMap[r] and logic.gameItemMap[r][c] then
                callback(logic.gameItemMap[r][c],r,c)
            end
        end
    end
end

local function foreach_board(callback)
    local logic = GameBoardLogic:getCurrentLogic()
    for r=1, 9 do
        for c=1, 9 do
            if logic.boardmap[r] and logic.boardmap[r][c] then
                callback(logic.boardmap[r][c],r,c)
            end
        end
    end
end

local function exist_board(r, c)
    local logic = GameBoardLogic:getCurrentLogic()
    if logic.gameItemMap[r] and logic.gameItemMap[r][c] then
        return true
    end
end

local function get_item(r, c)
    local logic = GameBoardLogic:getCurrentLogic()
    if logic.gameItemMap[r] and logic.gameItemMap[r][c] then
        return logic.gameItemMap[r][c]
    end
end

-- 子函数 检查魔法棒条件
function IngamePropGuideManager:tryTriggerBrush()
    local birds = {}
    local bird_pos = {}
    foreach_item(
        function(item, r, c)  
            if item.ItemSpecialType == AnimalTypeConfig.kColor and RefreshItemLogic.isItemMovable(item) then
                table.insert(birds, item)
                table.insert(bird_pos, {r=r, c=c})
            end
        end)
    local function getFromTo()
        local function isValideNeighbor(r, c, bird_r, bird_c)
            local item
            local gameItemMap = GameBoardLogic:getCurrentLogic().gameItemMap
            if gameItemMap[r] and gameItemMap[r][c] then
                item = gameItemMap[r][c]
            end
            if item then
                if GameBoardLogic:getCurrentLogic():canUseLineBrush(r, c)
                and RefreshItemLogic.isItemMovable(item)
                and SwapItemLogic:canBeSwaped(GameBoardLogic:getCurrentLogic(), r, c, bird_r, bird_c) == 1 then 
                    return true
                end
            end
            return false
        end
        for k, v in pairs(birds) do
            local item = v
            local r, c = bird_pos[k].r, bird_pos[k].c
            local neighbors = {{r=r, c=c-1}, {r=r, c=c+1}, {r=r-1,c=c}, {r=r+1,c=c}}
            for k, v in pairs(neighbors) do
                if isValideNeighbor(v.r, v.c, r, c) then
                    from = {r=r,c=c}
                    to = {r=v.r,c=v.c}
                    return from, to
                end
            end
        end
        return nil
    end
    local from, to = getFromTo()
    -- 保证from始终在左边或者上面
    if not from then
        return false
    end
    local newFrom, newTo
    if from.r == to.r then
        if from.c < to.c then
            newFrom = from
            newTo = to
        else
            newFrom = to
            newTo = from
        end
    else
        if from.r < to.r then
            newFrom = from
            newTo = to
        else
            newFrom = to
            newTo = from
        end
    end

    -- if __WIN32 then
    --     self.brush_data = {from={r=3,c=3},to={r=3,c=4}}
    --     return true
    -- end
    self.brush_data = {from = newFrom, to = newTo, animal = to}
    return true
end

-- 子函数 检查强制交换
function IngamePropGuideManager:tryTriggerForceSwapSpecial()
    local pos = {}
    local logic = GameBoardLogic:getCurrentLogic()
    local up, down, left, right, middle = 1,2,3,4,5
    local function getUp(r, c)
        return r-1, c
    end
    local function getDown(r, c)
        return r+1, c
    end
    local function getLeft(r, c)
        return r, c-1
    end
    local function getRight(r, c)
        return r, c+1
    end
    local function getPos(dir, r, c)
        if dir == up then
            return getUp(r, c)
        elseif dir == down then
            return getDown(r, c)
        elseif dir == left then
            return getLeft(r, c)
        elseif dir == right then
            return getRight(r, c)
        end
        return r, c
    end

    local sets = {
        {left, middle, right},
        {up, middle, down},
        {left, middle, down},
        {right, middle, down},
        {left, middle, up},
        {right, middle, up},
    }  
    local function reverseSet(set)
        local new = {set[3], set[2], set[1]}
        return new
    end
    local function judge(set, r, c)
        local a_r, a_c = getPos(set[1], r, c)
        local m_r, m_c = getPos(set[2], r, c)
        local b_r, b_c = getPos(set[3], r, c)
        local item_a = get_item(a_r, a_c)
        local item_middle = get_item(m_r, m_c)
        local item_b = get_item(b_r, b_c)
        if item_a and item_middle and item_b then
            if item_a:isSpecial() and not item_middle:isSpecial() and item_b:isSpecial() then
                if SwapItemLogic:canBeSwaped(logic, a_r, a_c, m_r, m_c) ~= 1 and logic:canUseForceSwap(a_r, a_c, m_r, m_c)
                    and SwapItemLogic:canBeSwaped(logic, b_r, b_c, m_r, m_c) == 1 then
                    local color = item_a._encrypt.ItemColorType
                    if not SwapItemLogic:_trySwapedMatchItem(logic, b_r, b_c, m_r, m_c, false) then
                        return true
                    end
                elseif SwapItemLogic:canBeSwaped(logic, a_r, a_c, m_r, m_c) == 1 and SwapItemLogic:canBeSwaped(logic, b_r, b_c, m_r, m_c) == 1 then
                    if not SwapItemLogic:_trySwapedMatchItem(logic, a_r, a_c, m_r, m_c, false)
                    and not SwapItemLogic:_trySwapedMatchItem(logic, b_r, b_c, m_r, m_c, false) then
                        return true
                    end
                end
            end
        end
        return false
    end
    foreach_item(function(middle_item, r, c)

        for k, v in pairs(sets) do
            if judge(v, r, c) then
                local swap_r, swap_c = getPos(v[1], r, c)
                local other_r, other_c = getPos(v[3], r, c)
                table.insert(pos, {swap={r=swap_r, c=swap_c}, middle={r=r, c=c}, other={r=other_r, c=other_c}})
            end
            local reversed_set = reverseSet(v)
            if judge(reversed_set, r, c) then
                local swap_r, swap_c = getPos(reversed_set[1], r, c)
                local other_r, other_c = getPos(reversed_set[3], r, c)
                table.insert(pos, {swap={r=swap_r, c=swap_c}, middle={r=r, c=c}, other={r=other_r, c=other_c}})
            end
        end
    end)

    if #pos > 0 then
        self.swap_data = pos[math.random(1, #pos)]
        return true
    else
        return false
    end

    -- if __WIN32 then
    --     return false
    -- end
end

function IngamePropGuideManager:tryTriggerForceSwapIngredient()
    local pos = {}
    local logic = GameBoardLogic:getCurrentLogic()
    foreach_item(function(item, r, c)
        if item.ItemType == GameItemType.kIngredient then
            local down = {r=r+1, c=c}
            if exist_board(down.r, down.c) then
                local down_item = get_item(down.r, down.c)
                if down_item.ItemType ~= GameItemType.kIngredient then
                    if SwapItemLogic:canBeSwaped(logic, r, c, down.r, down.c) ~= 1 and logic:canUseForceSwap(r, c, down.r, down.c) then
                        -- 不能交换但是可以强制交换
                        table.insert(pos, {swap = {r=r,c=c}, middle={r=down.r,c=down.c}})
                    elseif SwapItemLogic:canBeSwaped(logic, r, c, down.r, down.c) == 1 and not SwapItemLogic:_trySwapedMatchItem(logic, r, c, down.r, down.c, false) then
                        -- 可以交换，但是交换不能产生匹配
                        table.insert(pos, {swap = {r=r,c=c}, middle={r=down.r,c=down.c}})
                    end
                end
            end
        end
    end)
    if #pos > 0 then
        self.swap_ingredient_data = pos[math.random(1, #pos)]
        return true
    else
        return false
    end
end

function IngamePropGuideManager:tryTriggerHammer()
    local logic = GameBoardLogic:getCurrentLogic()
    local target_types = {}
    local pos = {}
    if logic.theGamePlayType == GameModeTypeId.LIGHT_UP_ID then
        -- 冰块
        foreach_board(function(item, r, c)
            if item.iceLevel > 0 then
                if logic:canUseHammer(r, c) then
                    table.insert(pos, {r=r, c=c})
                end
            end
        end)
    elseif logic.theGamePlayType == GameModeTypeId.DIG_MOVE_ID then
        -- 云块
        foreach_item(function(item, r, c)
            if (item.ItemType == GameItemType.kDigGround or item.ItemType == GameItemType.kDigJewel) 
            and item.digJewelLevel and item.digJewelLevel > 0 then
                if logic:canUseHammer(r, c) then
                    table.insert(pos, {r=r, c=c})
                end
            end
        end)
    elseif logic.theGamePlayType == GameModeTypeId.DROP_DOWN_ID then
        -- foreach_item(function(item, r, c)
        --     if item.ItemType == GameItemType.kIngredient then
        --         local item_dowm = get_item(r+1, c)
        --         if item_dowm then
        --             if logic:canUseHammer(r+1, c) then
        --                 table.insert(pos, {r=r+1, c=c})
        --             end
        --         end
        --     end
        -- end)
    elseif logic.theGamePlayType == GameModeTypeId.SEA_ORDER_ID then
        -- 海洋生物
        local allAnimals = logic.gameMode.allSeaAnimals
        local boardmap = logic.boardmap
        if allAnimals then
            for k, v in pairs(allAnimals) do
                for r = v.y, v.yEnd do 
                    for c = v.x, v.xEnd do
                        if boardmap[r][c].iceLevel and boardmap[r][c].iceLevel > 0 or
                            (boardmap[r][c].tileBlockType == 1 and boardmap[r][c].isReverseSide) then
                            if logic:canUseHammer(r, c) then
                                table.insert(pos, {r=r, c=c})
                            end
                        end
                    end
                end
            end
        end
        -- foreach_board(function(item, r, c)
        --     if item.seaAnimalType ~= nil then
        --         if logic:canUseHammer(r, c) then
        --             table.insert(pos, {r=r, c=c})
        --         end
        --     end
        -- end)
    else
        -- 雪块、银币、毒液
        local item_types = {}
        for k, v in pairs(logic.theOrderList) do
            -- 雪块
            if v.key1 == GameItemOrderType.kSpecialTarget and v.key2 == GameItemOrderType_ST.kSnowFlower then
                table.insert(item_types, GameItemType.kSnow)
            end 
            if v.key1 == GameItemOrderType.kSpecialTarget and v.key2 == GameItemOrderType_ST.kCoin then
                table.insert(item_types, GameItemType.kCoin)
            end 
            if v.key1 == GameItemOrderType.kSpecialTarget and v.key2 == GameItemOrderType_ST.kVenom then
                table.insert(item_types, GameItemType.kVenom)
            end
        end
        foreach_item(function (item, r, c)
            if table.exist(item_types, item.ItemType) then
                if logic:canUseHammer(r, c) then
                    table.insert(pos, {r=r, c=c})
                end
            end
        end)
    end
    if #pos > 0 then
        self.hammer_data = pos[math.random(#pos)]
        return true
    else
        return false
    end
end
    
local FREQ_HIGH = 4
local FREQ_MID = 3
local FREQ_LOW = 2
local FREQ_NONE = 1

function IngamePropGuideManager:getUserFrequency(propId)
    --[[
    local userTag = LevelDifficultyAdjustManager:getUserTag()
    local propTag = nil
    if userTag then
        propTag = userTag.propTag
    end
    ]]

    local propTag = UserTagManager:getUserTag( UserTagNameKeyFullMap.kUsePropFrequency )
    
    if not propTag then return false end
    -- print(table.tostring(propTag)) debug.debug()
    for k, v in pairs(propTag) do
        if v.first == propId then
            return v.second
        end
    end
    return false
end


local function getPropGuide()
    -- 容错处理
    -- print('1111111') debug.debug()
    local manager = UserManager:getInstance()
    local ret = manager.propGuideInfo
    if not ret then
        ret = {}
        ret.lastMatchDay = 0
        ret.lastStrongGuideItems = {}
        ret.lastMainLevelIdByItem = {}
        ret.lastMatchDayByItem = {}
        ret.lastMainLevelId = 0
        ret.lastHideLevelId = 0
        ret.lastHideLevelIdByItem = {}
        ret.strongGuideNumByItem = {}
        ret.lastExtraLevelIdByItem = {}
        manager.propGuideInfo = ret
    end
    return ret
end

local function getWeek(day)
    return math.floor((day+3)/7)
end
local function getDay(ts)
    return math.floor((ts + 8*3600)/(24*3600))
end
local function getMainAreaIndex(levelId)
    return math.ceil(levelId / 15)
end
local function getHideAreaIndex(levelId)
    local realId = levelId - 10000
    local index = math.ceil(realId / 3)
    return index
end 

function IngamePropGuideManager:_checkLastTimeStrong(propId)
    return table.exist(getPropGuide().lastStrongGuideItems, propId)
end

function IngamePropGuideManager:_isFirstTimeGuide(propId)
    local item = table.find(getPropGuide().strongGuideNumByItem, function (v) return v.first == propId end)
    if item and item.second > 0 then
        return false
    else
        return true
    end
end


local function getGap(propId)
    local gap = 2
    local checkValue = 300
    if propId == 10001 then -- 刷新
        checkValue = 400
    elseif propId == 10002 then -- 后退
        checkValue = 100
    elseif propId == 10010 then -- 锤子
        checkValue = 400
    elseif propId == 10005 then -- 魔法棒
        checkValue = 400
    elseif propId == 10003 then -- 交换
        checkValue = 100
    elseif propId == 10052 then -- 章鱼冰
        checkValue = 300
    end
    local manager = UserManager:getInstance()
    if manager.user:getTopLevelId() <= checkValue then
        gap = 2
    else
        gap = 1
    end
    return gap
end

-- 每隔3关（周赛：天）可触发1次
-- 
function IngamePropGuideManager:_checkWeekly(propId, levelId, isLowFreq)
    local gap = 1
    -- if isLowFreq then
    --     gap = getGap(propId)
    -- end

    local today = getDay(Localhost:timeInSec())
    if today - getPropGuide().lastMatchDay <= 3 then
        return false
    end
    local map = getPropGuide().lastMatchDayByItem
    for k, v in pairs(map) do
        if v.first == propId then
            local lastDay = v.second
            local lastWeek = getWeek(lastDay)
            local thisWeek = getWeek(today)
            if thisWeek - lastWeek > gap then
                return true
            else
                -- if _G.isLocalDevelopMode and _G.__testPropGuide then
                --     DcUtil:UserTrack({source='wenkan', info='_checkWeekly', propId=propId, levelId=levelId})
                -- end
                return false
            end
        end
    end
    return true
end

function IngamePropGuideManager:_checkMainLevel(propId, levelId, isLowFreq)
    local gap = 1--多少个区域
    --[[if isLowFreq then
        gap = getGap(propId)
    end]]
    if levelId - getPropGuide().lastMainLevelId <= 3 then
        -- print('xxxxxxxxxxxx levelId', levelId, ' lastMainLevelId', getPropGuide().lastMainLevelId)
        return false
    end
    local map = getPropGuide().lastMainLevelIdByItem
    for k, v in pairs(map) do
        if v.first == propId then
            local lastLevelId = v.second
            local lastAreaIndex = getMainAreaIndex(lastLevelId)
            local currentAreaIndex = getMainAreaIndex(levelId)
            -- print('currentAreaIndex', currentAreaIndex, 'lastAreaIndex', lastAreaIndex)
            if currentAreaIndex - lastAreaIndex > gap then
                -- print('aaaaaaaaaaa')
                return true
            else
                -- print('bbbbbbbb')
                -- if _G.isLocalDevelopMode and _G.__testPropGuide then
                --     DcUtil:UserTrack({source='wenkan', info='_checkMainLevel', propId=propId, levelId=levelId})
                -- end
                return false
            end
        end
    end
    -- print('cccccccccccc')
    -- 没有记录
    return true
end

function IngamePropGuideManager:_checkSubMainLevel(propId, levelId)--当主线关主规则不成立的情况下，检测最高关是否已经失败5次以上，可以额外触发一次弱引导
    if UserManager.getInstance().user:getTopLevelId() == levelId and UserTagManager:getTopLevelFailCounts() > 5 then 
        local gap = 1
        local map = getPropGuide().lastExtraLevelIdByItem
        for k, v in pairs(map) do
            if v.first == propId then
                local lastLevelId = v.second
                local lastAreaIndex = getMainAreaIndex(lastLevelId)
                local currentAreaIndex = getMainAreaIndex(levelId)
                if currentAreaIndex - lastAreaIndex > gap then
                    return true
                else
                    return false
                end
            end
        end
        return true
    end

    return false
end

function IngamePropGuideManager:_checkHideLevel(propId, levelId)
    local gap = 1

    if levelId - getPropGuide().lastHideLevelId <= 3 then
        return false
    end
    local map = getPropGuide().lastHideLevelIdByItem
    for k, v in pairs(map) do
        if v.first == propId then
            local lastLevelId = v.second
            local lastAreaIndex = getHideAreaIndex(lastLevelId)
            local currentAreaIndex = getHideAreaIndex(levelId)
            if currentAreaIndex - lastAreaIndex > gap then
                return true
            else
                -- if _G.isLocalDevelopMode and _G.__testPropGuide then
                --     DcUtil:UserTrack({source='wenkan', info='_checkHideLevel', propId=propId, levelId=levelId})
                -- end
                return false
            end
        end
    end
    return true
end

-- 高频用户
-- 弱引导
function IngamePropGuideManager:getHighFreqGuideType(propId, levelId)
    local check_passed = false
    if propId == 10056 or propId == 10055 then 
        -- 周赛道具
        check_passed = self:_checkWeekly(propId, levelId)
    else
        if LevelType:isMainLevel(levelId) then
            check_passed = self:_checkMainLevel(propId, levelId)
        elseif LevelType:isHideLevel(levelId) then
            check_passed = self:_checkHideLevel(propId, levelId)
        end
    end

    if check_passed then
        return WEAK_TYPE
    else
        return false
    end
end

-- 中频用户
-- 强引导+弱引导
-- 触发引导时，优先触发强引导。 
-- 某种道具的强引导触发过1次后，后续再触发时改为弱引导。
function IngamePropGuideManager:getMidFreqGuideType(propId, levelId)
    local check_passed = false
    local isFirstTime = self:_isFirstTimeGuide(propId)
    if propId == 10056 or propId == 10055 then 
        -- 周赛道具
        check_passed = self:_checkWeekly(propId, levelId)
    else
        if LevelType:isMainLevel(levelId) then
            check_passed = self:_checkMainLevel(propId, levelId)
        elseif LevelType:isHideLevel(levelId) then
            check_passed = self:_checkHideLevel(propId, levelId)
        end
    end

    if check_passed then
        if isFirstTime then
            return STRONG_TYPE
        else
            return WEAK_TYPE
        end
    else
        return false
    end
end 

function IngamePropGuideManager:getLowFreqGuideType(propId, levelId)
    local check_passed = false
    local isLastTimeStrong = self:_checkLastTimeStrong(propId)
    if propId == 10056 or propId == 10055 then 
        -- 周赛道具
        check_passed = self:_checkWeekly(propId, levelId, true)
    else
        if LevelType:isMainLevel(levelId) then
            check_passed = self:_checkMainLevel(propId, levelId, true)
        elseif LevelType:isHideLevel(levelId) then
            check_passed = self:_checkHideLevel(propId, levelId)
        end
    end

    if check_passed then
        -- print('6666666')
        if isLastTimeStrong then
            -- print('7777777')
            return WEAK_TYPE
        else
            -- print('888888888888')
            return STRONG_TYPE
        end
    else
        return false
    end
end

function IngamePropGuideManager:getPropGuideType(propId, levelId)
    if not propId or not levelId then return false end
    local freq = self:getUserFrequency(propId, levelId)
    --print('11111111 freq', freq)
    if freq == FREQ_LOW or freq == FREQ_NONE then
        -- print('22222222')
        return self:getLowFreqGuideType(propId, levelId)
    elseif freq == FREQ_MID then
        -- print('333333333333')
        return self:getMidFreqGuideType(propId, levelId)
    elseif freq == FREQ_HIGH then
        -- print('44444444444')
        return self:getHighFreqGuideType(propId, levelId)
    end

    return false
end

function IngamePropGuideManager:reachLimit(propId)
    local limit = 4
    local current = 0
    local map = getPropGuide().strongGuideNumByItem
    -- print(table.tostring(map))
    for k, v in pairs(map) do
        if v.first == propId then
            current = v.second
        end
    end
    -- print('current', current)
    local ret = current >= limit
    return ret
end

function IngamePropGuideManager:getCurrentCount(propId)
    local current = 0
    local map = getPropGuide().strongGuideNumByItem
    for k, v in pairs(map) do
        if v.first == propId then
            current = v.second
        end
    end
    return current
end

-- 检查条件写在这
function IngamePropGuideManager:checkCondition(propId, type, levelId)
    if type ~= EXTRA_TYPE then 
        local _type = self:getPropGuideType(propId, levelId)

        if _type == STRONG_TYPE and self:reachLimit(propId) then
            _type = WEAK_TYPE
        end
      
        local levelId_ok = false
        if LevelType:isMainLevel(levelId) then
            -- 代打、跳关、已经通过的不触发
            levelId_ok = (not UserManager:getInstance():hasPassedLevelEx(levelId))
        elseif LevelType:isHideLevel(levelId) then
            levelId_ok = (levelId == MetaModel:sharedInstance():getTopHiddenLevelId())
        elseif LevelType:isSummerMatchLevel(levelId) then
            levelId_ok = true
        end

        return _type == type and levelId_ok
    else
        local levelId_ok = false
        if LevelType:isMainLevel(levelId) then
            -- 代打、跳关、已经通过的不触发
            levelId_ok = (not UserManager:getInstance():hasPassedLevelEx(levelId)) and 
            (not GameGuide:sharedInstance():checkHaveGuide(levelId)) and 
            (self:_checkSubMainLevel(propId, levelId))
        end

        return levelId_ok
    end
end

function IngamePropGuideManager:getBroomData()
    local ret = 0
    local logic = GameBoardLogic:getCurrentLogic()
    foreach_item(function(item,r,c)
        if item.ItemType == GameItemType.kBoss then
            ret = r
        end
    end)
    return ret, self:getCurrentCount(10056)
end

function IngamePropGuideManager:getHammerData()
    return self.hammer_data, self:getCurrentCount(10010)
end

function IngamePropGuideManager:getBrushData()
    return self.brush_data, self:getCurrentCount(10005)
end

function IngamePropGuideManager:getSwapData()
    return self.swap_data, self:getCurrentCount(10003)
end

function IngamePropGuideManager:getSwapIngredientData()
    return self.swap_ingredient_data, self:getCurrentCount(10003)
end

function IngamePropGuideManager:getTwoStepsData(propId)
    return {}, self:getCurrentCount(propId)
end

function IngamePropGuideManager:clearHammerData()
    self.hammer_data = nil
end

function IngamePropGuideManager:clearBrushData()
    self.brush_data = nil
end

function IngamePropGuideManager:clearSwapData()
    self.swap_data = nil
end

function IngamePropGuideManager:clearSwapIngredientData()
    self.swap_ingredient_data = nil
end

function IngamePropGuideManager:getPassLevelParamAndClear()
    local value = self._passLevelParam
    self:clearPassLevelParam()
    return value
end

function IngamePropGuideManager:clearPassLevelParam()
    self._passLevelParam = 0
end

function IngamePropGuideManager:onFinishGuide(propId, type, levelId, denied)
    
    local function get(map, first)
        for k, v in pairs(map) do
            if v.first == first then
                return v
            end
        end
    end

    if type == EXTRA_TYPE then
        local data = get(getPropGuide().lastExtraLevelIdByItem, propId)
        if data then
            data.second = levelId
        else
            table.insert(getPropGuide().lastExtraLevelIdByItem, {first = propId, second=levelId})
        end
        self._passLevelParam = -(1000000 + propId)
    else
        if propId == 10056 or propId == 10055 then 
            getPropGuide().lastMatchDay = getDay(Localhost:timeInSec())
            local data = get(getPropGuide().lastMatchDayByItem, propId)
            if data then
                data.second = getDay(Localhost:timeInSec())
            else
                table.insert(getPropGuide().lastMatchDayByItem, {first = propId, second=getDay(Localhost:timeInSec())})
            end

        else
            if LevelType:isMainLevel(levelId) then
                getPropGuide().lastMainLevelId = levelId
                local data = get(getPropGuide().lastMainLevelIdByItem, propId)
                if data then
                    data.second = levelId
                else
                    table.insert(getPropGuide().lastMainLevelIdByItem, {first = propId, second=levelId})
                end

            elseif LevelType:isHideLevel(levelId) then
                getPropGuide().lastHideLevelId = levelId
                local data = get(getPropGuide().lastHideLevelIdByItem, propId)
                if data then
                    data.second = levelId
                else
                    table.insert(getPropGuide().lastHideLevelIdByItem, {first = propId, second=levelId})
                end            
            end
        end

        if type == STRONG_TYPE then
            if not denied then
                -- 接受了强引导，就记录一下
                if not self:_checkLastTimeStrong(propId) then
                    table.insert(getPropGuide().lastStrongGuideItems, propId)
                end
            end
        end

        if type == STRONG_TYPE and not denied then
            self._passLevelParam = 1 * propId
            local map = getPropGuide().strongGuideNumByItem
            local item = table.find(map, function(v) return v.first == propId end)
            if item then
                item.second = item.second + 1
            else
                table.insert(map, {first = propId, second = 1})
            end
            -- print(table.tostring(getPropGuide().strongGuideNumByItem))
            -- debug.debug()
        else
            self._passLevelParam = -1 * propId
        end
    end

    GamePlayContext:getInstance():onPropGuided(self._passLevelParam)
    ReplayDataManager:updateGamePlayContext()
end

-- 闪退恢复的时候调用
function IngamePropGuideManager:setGuidedProp(value)
    self._passLevelParam = value
end


function IngamePropGuideManager:onConfirmPropUsed()
    if self.propUsedCallback then
        self.propUsedCallback() 
        self.propUsedCallback = nil
    end
end

function IngamePropGuideManager:onSwaped()
    if self.swapCallback then
        self.swapCallback()
        self.swapCallback = nil
    end
end

function IngamePropGuideManager:onForceSwaped()
    if self.forceSwapCallback then
        self.forceSwapCallback()
        self.forceSwapCallback = nil
    end
end