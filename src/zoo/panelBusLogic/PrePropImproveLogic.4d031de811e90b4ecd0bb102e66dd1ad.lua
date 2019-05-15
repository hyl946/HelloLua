

local BIG_R = 1
local MID_R = 2
local SMALL_R = 3
local NO_PAY = 4 

local exclude_level_types = 
{
    GameLevelType.kTaskForRecall , 
    GameLevelType.kTaskForUnlockArea , 
    GameLevelType.kOlympicEndless, 
    GameLevelType.kMidAutumn2018,
    GameLevelType.kSpring2017,
    GameLevelType.kSpring2018,
    GameLevelType.kFourYears,
    GameLevelType.kYuanxiao2017, 
    GameLevelType.kSummerWeekly,
    GameLevelType.kMoleWeekly,
    GameLevelType.kSummerFish,
    GameLevelType.kJamSperadLevel,
    GameLevelType.kSpring2019,
}

local pre_prop_indices = 
{
    [ItemType.ADD_THREE_STEP] = 1,
    [ItemType.INITIAL_2_SPECIAL_EFFECT] = 2,
    [ItemType.INGAME_PRE_REFRESH] = 3,
    [ItemType.PRE_WRAP_BOMB] = 4,
    [ItemType.PRE_LINE_BOMB] = 5,
}

local old_pre_props = 
{
    {ItemType.TIMELIMIT_ADD_THREE_STEP, ItemType.ADD_THREE_STEP},
    {ItemType.TIMELIMIT_INITIAL_2_SPECIAL_EFFECT, ItemType.INITIAL_2_SPECIAL_EFFECT},
    -- {ItemType.TIMELIMIT_INGAME_PRE_REFRESH, ItemType.INGAME_PRE_REFRESH},
}

-- 后四种道具现在已经不用了  19/3/6
local new_pre_props = 
{
    {ItemType.TIMELIMIT_ADD_THREE_STEP, ItemType.ADD_THREE_STEP},
    {ItemType.TIMELIMIT_INITIAL_2_SPECIAL_EFFECT, ItemType.INITIAL_2_SPECIAL_EFFECT},
    -- {ItemType.TIMELIMIT_INGAME_PRE_REFRESH, ItemType.INGAME_PRE_REFRESH},
    {ItemType.TIMELIMIT_PRE_WRAP_BOMB, ItemType.PRE_WRAP_BOMB},
    {ItemType.TIMELIMIT_PRE_LINE_BOMB, ItemType.PRE_LINE_BOMB}
}

local old_panel_names = 
{
    'guide_dialogue_trigger_2',
    'guide_dialogue_trigger_3',
    -- 'guide_dialogue_trigger_1', 
}

local panel_names = 
{
    'guide_dialogue_trigger_2_new',
    'guide_dialogue_trigger_3_new',
    -- 'guide_dialogue_trigger_1_new',    
    'guide_dialogue_trigger_new_wrap',
    'guide_dialogue_trigger_new_line',
}

local tempData={}

PrePropImproveLogic = class()

function PrePropImproveLogic:isNewGuideLogic()
    if __WIN32 then return false end
    local uid = UserManager:getInstance().user.uid or '12345'
    local isEnabled = MaintenanceManager:getInstance():isEnabledInGroup('NewPrePropGuide', 'A1', uid) --线上：false 19/3/6
    return isEnabled
end


function PrePropImproveLogic:isNewItemLogic()
    if __WIN32 then return false end
    local ret = UserManager:getInstance():hasBAFlag(128) or false
    return ret
end

--[[
FYI!
    （非刷新）前置道具数量为0时：
    1）7800≤当前银币数＜10000，默认推荐刷新。2）10000≤当前银币数＜36000，默认推荐加3步。3）当前银币数≥36000，推荐加3步及爆炸直线特效两种道具的概率分别为50%。
    （非刷新）前置道具数量不为0时：
    1）有单一一种前置道具（非刷新）时，引导该道具使用。
    2）有两种前置道具共存时，按优先级推荐：加3步，爆炸直线特效
]]

function PrePropImproveLogic:tryTriggerGuide(levelId, levelType, failReason, panelCallback)

    -- if not __WIN32 then

        if not PrePropImproveLogic:isNewGuideLogic() then
            return false
        end

        if table.exist(exclude_level_types) then
            return false -- return
        end
        if levelId < 21 then
            return false -- return
        end
        -- print(GameGuideData:sharedInstance():getContinuousFailedNum()) debug.debug()
        if GameGuideData:sharedInstance():getContinuousFailedNum() < 2 then
            return false -- return
        end
        -- time level
        if GameBoardLogic:getCurrentLogic() and GameBoardLogic:getCurrentLogic().theGamePlayType == GameModeTypeId.CLASSIC_ID then
            return false -- return
        end
    -- end

    local function yesCallback(propId)
        if panelCallback then
            panelCallback(true, propId)
        end
    end
    local function closeCallback()
        if panelCallback then
            panelCallback(false)
        end
    end

    local pre_props
    if PrePropImproveLogic:isNewItemLogic() then
        pre_props = new_pre_props
    else
        pre_props = old_pre_props
    end
    local action = {array = {}, panelNameRandomList = {}, panDelay=0, panFade=0.1}
    -- 顺序遍历，保证优先级是加3步>爆炸直线>刷新>爆炸>直线
    for i, v in ipairs(pre_props) do
        local time_prop = v[1]
        local normal_prop = v[2]
        -- 临时刷新很特殊
        -- 需求要求，即使有10015，也不优先推
        if normal_prop ~= 10015 then
            if UserManager:getInstance():getUserPropNumber(time_prop) > 0 
                or UserManager:getInstance():getUserPropNumber(normal_prop) > 0 then
                -- 有道具就可以推了
                table.insert(action.array, {propId = normal_prop})
                table.insert(action.panelNameRandomList, panel_names[i])
                GameGuideRunner:playBuyPreProp(action, yesCallback, closeCallback, failReason)
                FUUUManager:clearContinuousFailuresForGuide(levelId , true)
                return true  -- return
            end
        end
    end


    local coin_num = UserManager:getInstance().user:getCoin()


    if PrePropImproveLogic:isNewItemLogic() then
        if coin_num < 10000 then
            -- 需求要求：除刷新外，如果玩家拥有该前置道具，先推
            -- 如果没有那两个，就按银币数推
            -- 如果银币数不够，就看玩家有没有前置刷新
            local time_prop = 10070
            local normal_prop = 10015
            if UserManager:getInstance():getUserPropNumber(time_prop) > 0 
                or UserManager:getInstance():getUserPropNumber(normal_prop) > 0 then
                -- 有道具就可以推了
                table.insert(action.array, {propId = normal_prop})
                table.insert(action.panelNameRandomList, 'guide_dialogue_trigger_1_new')
                GameGuideRunner:playBuyPreProp(action, yesCallback, closeCallback, failReason)
                FUUUManager:clearContinuousFailuresForGuide(levelId , true)
                return true  -- return
            else
                return false
            end
        elseif coin_num < 18000 then
            table.insert(action.array, {propId = ItemType.ADD_THREE_STEP}) 
            table.insert(action.panelNameRandomList, panel_names[pre_prop_indices[ItemType.ADD_THREE_STEP]])

        else
            table.insert(action.array, {propId = ItemType.PRE_WRAP_BOMB}) 
            table.insert(action.panelNameRandomList, panel_names[pre_prop_indices[ItemType.PRE_WRAP_BOMB]])

            table.insert(action.array, {propId = ItemType.PRE_LINE_BOMB}) 
            table.insert(action.panelNameRandomList, panel_names[pre_prop_indices[ItemType.PRE_LINE_BOMB]])

        end
        GameGuideRunner:playBuyPreProp(action, yesCallback, closeCallback, failReason)
        FUUUManager:clearContinuousFailuresForGuide(levelId , true)
        return true -- return
    else
        if coin_num < 7800 then
            -- 需求要求：除刷新外，如果玩家拥有该前置道具，先推
            -- 如果没有那两个，就按银币数推
            -- 如果银币数不够，就看玩家有没有前置刷新
            local time_prop = 10070
            local normal_prop = 10015
            if UserManager:getInstance():getUserPropNumber(time_prop) > 0 
                or UserManager:getInstance():getUserPropNumber(normal_prop) > 0 then
                -- 有道具就可以推了
                table.insert(action.array, {propId = normal_prop})
                table.insert(action.panelNameRandomList, 'guide_dialogue_trigger_1_new')
                GameGuideRunner:playBuyPreProp(action, yesCallback, closeCallback, failReason)
                FUUUManager:clearContinuousFailuresForGuide(levelId , true)
                return true  -- return
            else
                return false
            end
        -- elseif coin_num < 10000 then
        --     table.insert(action.array, {propId = ItemType.INGAME_PRE_REFRESH}) 
        --     table.insert(action.panelNameRandomList, panel_names[pre_prop_indices[ItemType.INGAME_PRE_REFRESH]])

        elseif coin_num < 36000 then
            table.insert(action.array, {propId = ItemType.ADD_THREE_STEP}) 
            table.insert(action.panelNameRandomList, panel_names[pre_prop_indices[ItemType.ADD_THREE_STEP]])
        else
            table.insert(action.array, {propId = ItemType.ADD_THREE_STEP}) 
            table.insert(action.panelNameRandomList, panel_names[pre_prop_indices[ItemType.ADD_THREE_STEP]])

            table.insert(action.array, {propId = ItemType.INITIAL_2_SPECIAL_EFFECT}) 
            table.insert(action.panelNameRandomList, panel_names[pre_prop_indices[ItemType.INITIAL_2_SPECIAL_EFFECT]])

        end
        GameGuideRunner:playBuyPreProp(action, yesCallback, closeCallback, failReason)
        FUUUManager:clearContinuousFailuresForGuide(levelId , true)
        return true -- return
    end
end

local PrePropPriority = table.const{
    [ItemType.TIMELIMIT_PRE_RANDOM_BIRD]            = 1,
    [ItemType.PRE_RANDOM_BIRD]                      = 5,
    -- [ItemType.TIMELIMIT_PRE_BUFF_BOOM]              = 10,
    -- [ItemType.PRE_BUFF_BOOM]                        = 15,
    [ItemType.TIMELIMIT_PRE_FIRECRACKER]            = 10,
    [ItemType.PRE_FIRECRACKER]                      = 15,
    [ItemType.TIMELIMIT_ADD_THREE_STEP]             = 20,
    [ItemType.ADD_THREE_STEP]                       = 25,
    [ItemType.TIMELIMIT_INITIAL_2_SPECIAL_EFFECT]   = 30,
    [ItemType.INITIAL_2_SPECIAL_EFFECT]             = 35,
    [ItemType.PRE_WRAP_BOMB]                        = 40,
    [ItemType.PRE_LINE_BOMB]                        = 45,
    [ItemType.INGAME_PRE_REFRESH]                   = 50,
}

function PrePropImproveLogic:getInitialProps(levelId, refreshTimeProps)
    if refreshTimeProps then -- 刷新限时道具状态
        UserManager.getInstance():getAndUpdateTimeProps()
    end

    local newInitialProps = {}
    local metaModel = MetaModel:sharedInstance()
    local metaManager = MetaManager.getInstance()
    local levelModeTypeId = metaModel:getLevelModeTypeId(levelId)
    if not levelModeTypeId or not metaManager.gamemode_prop[levelModeTypeId] then
        return newInitialProps
    end

    local initialProps = metaManager.gamemode_prop[levelModeTypeId].initProps
    local excludeList={
        ItemType.PRE_WRAP_BOMB,
        ItemType.PRE_LINE_BOMB,
        ItemType.INGAME_PRE_REFRESH,
        ItemType.PRE_BUFF_BOOM,
    }   --新版本取消了前置刷新
    if PrePropImproveLogic:isNewItemLogic() then
        excludeList={
            ItemType.INITIAL_2_SPECIAL_EFFECT,
            ItemType.INGAME_PRE_REFRESH
        }
    end
    local isEffective, privilegePropIDs = PrivilegeMgr.getInstance():isPrivilegeEffctive(PrivilegeType.kPreProp)
    for k,v in pairs(initialProps) do
        local propId = tonumber(v)
        if not table.includes(excludeList, propId) then
            local isEnabled = false
            local info = {}
            local count = UserManager.getInstance():getUserPropNumberWithAllType(propId)
            -- if propId == ItemType.PRE_BUFF_BOOM or propId == ItemType.PRE_RANDOM_BIRD then
            -- if propId == ItemType.PRE_BUFF_BOOM then
            --     if count > 0 and GameGuide:isPreBuffBoomAndBirdLevel(levelId) then
            --         isEnabled = true
            --     else
            --         isEnabled = false
            --     end
            -- else
                isEnabled = true
            -- end
            if isEnabled then 
                info.propId = propId
                info.autoUse = PrePropImproveLogic:isAutoUse(levelId) and count > 0
                if isEffective and table.includes(privilegePropIDs, propId) then 
                    info.privilegeFree = true
                    info.autoUse = false        --有特权免费的 就不需要自动使用了
                end

                info.unLockLevel = 1
                local realPropId = ItemType:getRealIdByTimePropId(propId)
                -- printx(11, "getInitialProps, propId:"..propId.." realPropId:"..realPropId)
                if realPropId then
                    local propData = MetaManager.getInstance().prop[realPropId]
                    if propData then
                        local unLockLevel = propData.unlock
                        if unLockLevel and unLockLevel > 0 then
                            info.unLockLevel = unLockLevel
                        end
                    end
                end

                table.insert(newInitialProps, info)
            end
        end
    end

    -- if levelId > 21 and #newInitialProps > 0 then 
    -- 小于21级也要根据解锁与否排序
    if #newInitialProps > 0 then 
        table.sort(newInitialProps, function (a, b)
            if (a.unLockLevel <= levelId) and (b.unLockLevel > levelId) then
                return true
            elseif (a.unLockLevel > levelId) and (b.unLockLevel <= levelId) then
                return false
            end

            if a.autoUse and not b.autoUse then 
                return true
            elseif not a.autoUse and b.autoUse then
                return false
            else
                if a.privilegeFree and not b.privilegeFree then 
                    return true
                elseif not a.privilegeFree and b.privilegeFree then
                    return false
                else
                     --到这里肯定是均未解锁或均解锁
                    if a.unLockLevel > levelId then
                        if a.unLockLevel < b.unLockLevel then
                            return true
                        else
                            return false
                        end
                    else
                        local aPri = PrePropPriority[a.propId] or 100
                        local bPri = PrePropPriority[b.propId] or 100
                        return aPri < bPri
                    end
                end
            end
        end)
    end

    return newInitialProps
end

function PrePropImproveLogic:_dataKey()
    return "PrePropImproveLogic_" .. UserManager:getInstance().uid ..".ds"
end

function PrePropImproveLogic:_readData()
    return Localhost.getInstance():readFromStorage(PrePropImproveLogic:_dataKey()) or {}
end

function PrePropImproveLogic:_saveData(data)
    --printx(0,"PrePropImproveLogic:_saveData:",table.tostring(data),debug.traceback())

    Localhost.getInstance():writeToStorage(data, PrePropImproveLogic:_dataKey())
end

function PrePropImproveLogic:onLevelEnd(isPass,level)
    local data = self:_readData() or {}
    --printx(0,"----PrePropImproveLogic:onLevelEnd:",tostring(isPass).."-"..tostring(level)..tostring(UserManager.getInstance():getTopPassedLevel())..table.tostring(data))
    if level~=UserManager.getInstance():getTopPassedLevel()+1 then
        return
    end
    if isPass then
        data={}
    else
        if data["topLevel"]~=level then
            data={}
            data["topLevel"]=level
        end
        data["tryTimes"]=(data["tryTimes"] or 0)+1
    end
    PrePropImproveLogic:_saveData(data)
end

--24284019 前置道具优化
function PrePropImproveLogic:isNewLogicEnabled()
    local isEnabled = MaintenanceManager:getInstance():isEnabledInGroup('PrePropImproveLogic', 'A1', UserManager:getInstance().uid)
    return isEnabled
end

--是否触发自动勾选 24284019 前置道具优化
function PrePropImproveLogic:isAutoUse(level)
    if not PrePropImproveLogic:isNewLogicEnabled() then
        return false
    end
    --主线关等级最高的关卡时，连续1次在该关卡闯关失败，则触发默认勾选
    local data = self:_readData() or {}
    if level<=21 then
        return false
    end
    printx(0,"PrePropImproveLogic:isAutoUse:",level,table.tostring(data))
    if not data["topLevel"] or data["topLevel"]~=level then
        printx(0,"PrePropImproveLogic:isAutoUse():not last topLevel")
        return false
    end
    local tryTimes = (data["tryTimes"] or 0)+1
    if tryTimes==2 then
        printx(0,"PrePropImproveLogic:isAutoUse():TRUE t2")
        return true
    end
    if tryTimes==3 then
        local justCancelAutoUsed = data["justCancelAutoUsed"]
        local isAutoUse  = justCancelAutoUsed
        local isShowFlash = not isAutoUse
        printx(0,"PrePropImproveLogic:isAutoUse():t3",isAutoUse,isShowFlash)
        return isAutoUse,isShowFlash
    end
    printx(0,"PrePropImproveLogic:isAutoUse():FALSE")
    return false
end

--是否显示道具闪光 仅对最高关连续两次失败后第三次尝试，且第二次使用了前置道具的情况下显示
function PrePropImproveLogic:isShowFlash(level)
    local _,isShowFlash = PrePropImproveLogic:isAutoUse(level)
    return isShowFlash
end

function PrePropImproveLogic:onStartGame(level,itemList)
    if level~=UserManager.getInstance():getTopPassedLevel()+1 then
        return
    end
    -- print("PrePropImproveLogic:onStartGame",level,table.tostring(itemList),debug.traceback())
    local data = self:_readData() or {}
    --print("-----------PrePropImproveLogic:onStartGame",level,table.tostring(itemList),table.tostring(data),debug.traceback())
    itemList = itemList or {}
    data["justUsed"] = #itemList>0
    data["justAutoUsed"] = tempData.justAutoUsed

    local list = tempData.justAutoUsedList or {}
    
    local allIn = true
    local allCancel = true
    for i,v in ipairs(list) do
        local isIn = table.includes(itemList,v)
        if isIn then
            allCancel=false
        else
            allIn=false
        end
    end

    if tempData.justAutoUsed and #list>0 then
        local params = {}
        params.category = "stage"
        params.sub_category = "stage_end"
        params.levelID = level
        params.tryTimes = data["tryTimes"] or 0
        -- params.default_item = allCancel and 0 or (allIn and 2 or 1)
        -- params.default_select = tempData.justAutoUsed and 1 or 2
        params.default_item = table.concat(list,",")
        params.itemList = table.concat(itemList,",")
        params.playId = GamePlayContext:getInstance():getIdStr()
        print("-----------------------------------------------PrePropImproveLogic:onStartGame()",allIn,allCancel,table.tostring(params),debug.traceback())
        DcUtil:UserTrack(params)
    end

    data["justCancelAutoUsed"] = not allIn
    data["topLevel"]=level
    PrePropImproveLogic:_saveData(data)

    tempData.justAutoUsedList = nil
    tempData.justAutoUsed = nil
end