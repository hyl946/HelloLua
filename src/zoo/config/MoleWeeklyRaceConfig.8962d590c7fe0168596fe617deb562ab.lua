require 'zoo.quarterlyRankRace.RankRaceMgr'

MoleWeeklyRaceConfig = {}
--[[
blood           总血量
normalHit       消除一个普通动物减少的血量
specialHit      消除一个特效动物减少的血量
dropItemsOnDie  Boss死亡掉落收集物的数量
releaseSkillGap boss死之前，每隔多少步释放一次boss技能
]]--

local savedConfigData
local tempGroupIDForRevert
local groupIDForRevert

function MoleWeeklyRaceConfig:getConfigData()
    if self.savedConfigData then
        return self.savedConfigData
    else
        return MetaManager.getInstance():getMoleWeeklyRaceConfig()
    end
end

function MoleWeeklyRaceConfig:setSavedConfig(savedConfig)
    self.savedConfigData = savedConfig
end

function MoleWeeklyRaceConfig:hasSavedConfig()
    if self.savedConfigData then
        return true
    else
        return false
    end
end

function MoleWeeklyRaceConfig:resetConfig()
    self.savedConfigData = nil
    self.groupIDForRevert = 0

    if self.tempGroupIDForRevert and self.tempGroupIDForRevert > 0 then
        self.groupIDForRevert = self.tempGroupIDForRevert
        self.tempGroupIDForRevert = 0
    end
end

function MoleWeeklyRaceConfig:setGroupIDForRevert(val)
    -- printx(11, "========== MoleWeeklyRaceConfig:setGroupIDForRevert,", val)
    self.tempGroupIDForRevert = val
end

function MoleWeeklyRaceConfig:_getCurrBossCount(mainLogic)
    local bossCount = mainLogic:getBossCount() + 1      --初始为0，死亡时才会增加计数，所以用作序号时需要增1
    return bossCount
end

function MoleWeeklyRaceConfig:getCurrGroupID(replayMode)
    if self.groupIDForRevert and self.groupIDForRevert > 0 then
        -- printx(11, "use groupIDForRevert")
        return self.groupIDForRevert
    else
        -- printx(11, "use Real CurrGroupID")
        return self:getRealCurrGroupID(replayMode)
    end
end

function MoleWeeklyRaceConfig:getRealCurrGroupID(replayMode)
    -- printx(11, "======================== MoleWeeklyRaceConfig:getCurrGroupID", debug.traceback())
    local groupID = 0
    if RankRaceMgr and RankRaceMgr:getInstance() and RankRaceMgr:getInstance():getData() then
        groupID = RankRaceMgr:getInstance():getData():getDan()
        -- printx(11, "Get Mole Boss GroupID from Data:", groupID)
    end

    local config = MoleWeeklyRaceConfig:getConfigData()
    if config and config.bossConfig then
        if not groupID or groupID <= 0 then groupID = config.defaultGroupID end   --未获得分组信息，选取默认组别
    end

    if not groupID or groupID <= 0 then groupID = 1 end     --能说什么呢，最后一道防线
	
	if replayMode and replayMode == ReplayMode.kAutoPlayCheck then
        return 10
    end

    return groupID
end

function MoleWeeklyRaceConfig.genNewBoss(mainLogic)
    local bossCount = MoleWeeklyRaceConfig:_getCurrBossCount(mainLogic)
    -- printx(11, " = = = = MoleWeeklyRaceConfig.genNewBoss.  bossCount = = = =", bossCount)

    local bossData
    local bossID = 1
    local bloodAddition = 0
    local rewardAddition = 0

    local config = MoleWeeklyRaceConfig:getConfigData()
    if config and config.bossConfig then
        local bossConfig = config.bossConfig
        bossID = math.min(MoleWeeklyRaceConfig:getTableLength(bossConfig), bossCount)
        bloodAddition = math.max((bossCount - MoleWeeklyRaceConfig:getTableLength(bossConfig)) * config.bossBloodOverflowAddition, 0)
        rewardAddition = math.max((bossCount - MoleWeeklyRaceConfig:getTableLength(bossConfig)) * config.bossRewardOverflowAddition, 0)

        local groupID = MoleWeeklyRaceConfig:getCurrGroupID(mainLogic.replayMode)
        local additionConfig = MoleWeeklyRaceConfig:_getBossGroupConfig(groupID)
        -- printx(11, "additionConfig", table.tostring(additionConfig), groupID)
        if additionConfig then
            bloodAddition = bloodAddition + additionConfig.bloodIncrease
            rewardAddition = rewardAddition + additionConfig.demolishRewardIncrease
        end

        bossData = {}
        local origData = bossConfig[bossID]
        for k,_ in pairs(origData) do
            bossData[k] = origData[k]
        end
        bossData.blood = bossData.blood + bloodAddition
        bossData.demolishReward = bossData.demolishReward + rewardAddition
        bossData.groupID = groupID
    end
    -- printx(11, " bossData ", table.tostring(bossData))
    return bossData
end

function MoleWeeklyRaceConfig:_getBossGroupConfig(currGroupID)
    local groupConfig

    local config = MoleWeeklyRaceConfig:getConfigData()
    if config and config.groupConfig then
        -- printx(11, "groupConfig lenght", table.maxn(config.groupConfig), #config.groupConfig, MoleWeeklyRaceConfig:getTableLength(config.groupConfig))
        local groupID = math.min(MoleWeeklyRaceConfig:getTableLength(config.groupConfig), currGroupID)
        groupConfig = config.groupConfig[groupID]
    end

    return groupConfig
end

function MoleWeeklyRaceConfig:getTableLength(targetTable)
    local amountVal = 0
    for k,v in pairs(targetTable) do
        amountVal = amountVal + 1
    end
    return amountVal
end

------------------- SKILL  ------------------------

function MoleWeeklyRaceConfig:_getCurrSkillWeightArr(groupID)
    local groupConfig = MoleWeeklyRaceConfig:_getBossGroupConfig(groupID)
    if groupConfig then
        return groupConfig.skillWeight
    end
    return nil
end

function MoleWeeklyRaceConfig:getCurrSkillTypeArr(groupID)
    local skillTypeArr = {}
    local skillWeight = MoleWeeklyRaceConfig:_getCurrSkillWeightArr(groupID)
    if skillWeight then
        for _, str in ipairs(skillWeight) do
            local weightArr = string.split(str, ":")
            table.insert(skillTypeArr, weightArr[1])
        end
    end
    table.insert(skillTypeArr, "t")
    return skillTypeArr
end

function MoleWeeklyRaceConfig:hasMagicTileSkill(groupID)
    local skillWeight = MoleWeeklyRaceConfig:_getCurrSkillWeightArr(groupID)
    if skillWeight then
        for _, str in ipairs(skillWeight) do
            local weightArr = string.split(str, ":")
            if weightArr[1] == MoleWeeklyBossSkillType.DEAVTIVATE_MAGIC_TILE then 
                return true
            end
        end
    end
    return false
end

function MoleWeeklyRaceConfig:genNewSkill(mainLogic, bossData, forbidMagicTileSkill)
    -- printx(11, "++++++++  MoleWeeklyRaceConfig.genNewSkill ++++++. forbidMagicTileSkill:", forbidMagicTileSkill)
    local skillType = nil
    local skillParam = 0

    local config = MoleWeeklyRaceConfig:getConfigData()

    --第某个boss，强制第一次释放H技能
    local bossSpecialSkillRound = 0
    local bossSpecialSkillCastRound = 0
    if config and config.specialSkillBossNo then
        bossSpecialSkillRound = config.specialSkillBossNo
        bossSpecialSkillCastRound = config.specialSkillBossCastNo
    end
    -- printx(11, "bossSpecialSkillRound:"..bossSpecialSkillRound.."  bossSpecialSkillCastRound:"..bossSpecialSkillCastRound)
    -- printx(11, "CurrBossCount:"..MoleWeeklyRaceConfig:_getCurrBossCount(mainLogic))
    if MoleWeeklyRaceConfig:_getCurrBossCount(mainLogic) == bossSpecialSkillRound then
        bossData.bossSkillHRoundCount = bossData.bossSkillHRoundCount + 1
        if bossData.bossSkillHRoundCount == bossSpecialSkillCastRound then
            skillType = MoleWeeklyBossSkillType.SEED
            if bossData[skillType] then
                skillParam = bossData[skillType]
            end

            return skillType, skillParam
        end
    end

    --没有符合条件的目标地格的情况下，屏蔽S技能的出现（已废弃，永远为false）
    local forbidSkillS = false
    if forbidMagicTileSkill then forbidSkillS = true end

    local sumWeight = 0
    local skillWeight = MoleWeeklyRaceConfig:_getCurrSkillWeightArr(bossData.bossGroupID)
    if not skillWeight then return nil, nil end
    for _, str in ipairs(skillWeight) do
        local weightArr = string.split(str, ":")
        if forbidSkillS and weightArr[1] == MoleWeeklyBossSkillType.DEAVTIVATE_MAGIC_TILE then 
            --屏蔽技能S
        elseif bossData.lastSkillName and weightArr[1] == bossData.lastSkillName then
            --屏蔽刚使用过的技能
        else
            local weight = tonumber(weightArr[2])
            sumWeight = sumWeight + weight
        end
    end
    -- printx(11, "sumWeight", sumWeight)
    local index = mainLogic.randFactory:rand(1, sumWeight)
    -- printx(11, "index", index)

    local currWeight = 0
    for _, str in ipairs(skillWeight) do
        local weightArr = string.split(str, ":")
        local typeStr = weightArr[1]
        local weight = tonumber(weightArr[2])
        if forbidSkillS and typeStr == MoleWeeklyBossSkillType.DEAVTIVATE_MAGIC_TILE then 
            --屏蔽技能S
        elseif bossData.lastSkillName and weightArr[1] == bossData.lastSkillName then
            --屏蔽刚使用过的技能
        else
            currWeight = currWeight + weight
            if index <= currWeight then
                skillType = typeStr
                break
            end
        end
    end

    if skillType and bossData[skillType] then
        skillParam = bossData[skillType]
    end

    -- printx(11, "skillType, skillParam", skillType, skillParam)
    return skillType, skillParam
end

--------------------------------- PropSkill -----------------------------
function MoleWeeklyRaceConfig:genNewPropSkill()
    -- printx(11, " = = = MoleWeeklyRaceConfig:genNewPropSkill = = = ")
    local currentPropSkill

    local config = MoleWeeklyRaceConfig:getConfigData()
    if config and config.propSkill then

		local mainLogic = GameBoardLogic:getInstance()
        local groupID = MoleWeeklyRaceConfig:getCurrGroupID(mainLogic.replayMode)
        groupID = math.min(groupID, MoleWeeklyRaceConfig:getTableLength(config.propSkill))
        
        currentPropSkill = {}
        local origData = config.propSkill[groupID]
        for k,_ in pairs(origData) do
            currentPropSkill[k] = origData[k]
        end
        currentPropSkill.maxVal = config.propSkillFullValue
    end

    -- printx(11, " currentPropSkill ", table.tostring(currentPropSkill))
    return currentPropSkill
end

--------------------------------- CollectTarget -----------------------------
function MoleWeeklyRaceConfig:getCollectTargetAmount()
    local targetAmount = 0
    if RankRaceMgr and RankRaceMgr:getInstance() then
        targetAmount = RankRaceMgr:getInstance():getUnlockTarget()
        -- printx(11, "Get Collect Target Amount from Data:", targetAmount)
    end
    return targetAmount
end
