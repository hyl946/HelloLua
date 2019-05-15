--常量配置
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'

local RankRaceMeta = class()

function RankRaceMeta:ctor(data)
	self.data = data
end

--累计奖励配置
function RankRaceMeta:getBoxRewardConfig()
	local ret = {}

	for i = 1, 7 do
		local boxCfg = {}
        local dan = RankRaceMgr.getInstance():getCurBigDan()
        local rawBoxCfg = self.data:getMetaValue('boxReward'..dan..i) or '999|10060:1,50102:5'

		local tblBoxCfg = Misc:parse(rawBoxCfg, '|,:')

		if tblBoxCfg[1] and tblBoxCfg[1][1] then
			boxCfg.conditions = tonumber(tblBoxCfg[1][1][1]) or 1
		end

		boxCfg.rewards = {}
		for _, v in ipairs(tblBoxCfg[2]) do
			table.insert(boxCfg.rewards, {itemId = tonumber(v[1]) or 14, num = tonumber(v[2]) or 1})
		end
		table.insert(ret, boxCfg)
	end
	return ret
end


--转盘奖励配置
function RankRaceMeta:getLotteryConfig()
	local rawConfig = self:getRawLotteryConfig()
	local parsedConfig = Misc:parse(rawConfig, ',:')
	local ret = {}
	for i, v in ipairs(parsedConfig) do
		ret[i] = {
			itemId = tonumber(v[1]),
			num = tonumber(v[2]),
		}
	end
	return ret
end

function RankRaceMeta:getRawLotteryConfig()
	return self.data:getMetaValue('lotteryRewardA') or '14:2:25,10071:1:1500,10091:1:25,10069:1:1000,10092:1:25,10058:1:1000,10093:1:25,2:2000:1000'
end

--晋阶奖励配置
function RankRaceMeta:getDanRewardConfig( ... )

	local ret = {}

	for i = 2, 10 do
		local rawCfg = self.data:getMetaValue('promotionReward' .. i) or '14:1'

		local thisDan = {}

		local cfg = Misc:parse(rawCfg, ',:')
		for _, v in ipairs(cfg) do
			table.insert(thisDan, {itemId = tonumber(v[1]), num = tonumber(v[2])})
		end

		table.insert(ret, thisDan)
	end

	return ret
end



function RankRaceMeta:getReceiveGiftLimit( ... )
	return tonumber(self.data:getMetaValue('receiveGiftLimit') or '') or 3
end

function RankRaceMeta:getLotteryCost( ... )
	return tonumber(self.data:getMetaValue('lotteryCost') or '') or 999
end

function RankRaceMeta:getTaskTarget( ... )
	return tonumber(self.data:getMetaValue('taskTargetNum') or '') or 9999
end

function RankRaceMeta:getPromotionRate()
	local ret = {}
	for i = 1, 9 do
		local rawCfg = self.data:getMetaValue('promotionRate' .. i) or '5,30%'
		local cfg = Misc:parse(rawCfg, ',')
		table.insert(ret, {tonumber(cfg[1]), tostring(cfg[2])})
	end
	return ret
end

function RankRaceMeta:getDanDetails( ... )
	local ret = {}
	for i, v in ipairs(MetaManager:getInstance():getMoleWeeklyRaceConfig().propSkill) do
		ret[i] = {
			demage = v.damage,
			preFillPercent = tostring(tonumber(v.preFillPercent) * 100) .. '',
			throwColourAmount = v.throwColourAmount,
			throwEffectAmount = v.throwEffectAmount,
			_throwEffect = (tonumber(v.throwColourAmount) or 0) +  (tonumber(v.throwEffectAmount) or 0),
			_throwReward = MoleWeeklyRaceConfig:_getBossGroupConfig(i).demolishRewardIncrease,
			throwAddStepPercent = tostring(tonumber(v.throwAddStepPercent) * 100) .. '',
			skills = {'t'},
		}
		local rawSkillCfg = MetaManager:getInstance():getMoleWeeklyRaceConfig().groupConfig[i].skillWeight
		for _, vv in ipairs(rawSkillCfg) do
			table.insert(ret[i].skills, Misc:parse(vv, ':')[1])
		end
	end
	return ret
end

function RankRaceMeta:getLevelIdCfg( ... )
	local levelIdBase = tonumber(self.data:getMetaValue('levelIdBase') or 310000)
	local levelIdBeginWeek = tonumber(self.data:getMetaValue('levelIdBeginWeek') or 2524)
	local levelIdStep = tonumber(self.data:getMetaValue('levelIdStep') or 10)
	return levelIdBeginWeek, levelIdBase, levelIdStep
end

function RankRaceMeta:getNewLevelIdCfg()
	return self.data:getLevels() or {}
end

function RankRaceMeta:getInGameGiftNum( ... )

    local receiveGiftNumTable = self.data:getMetaValue('receiveGiftNum')

    local info = Misc:parse( receiveGiftNumTable, '|')
    local normalNum = tonumber( info[1] ) or 5

    local RankInfo = {}
    if info[2] then
        local RankNumTable = Misc:parse( info[2], ',') 
        local RankInfo1 = Misc:parse( RankNumTable[1], ':') 
        local RankInfo2 = Misc:parse( RankNumTable[2], ':') 

        RankInfo[1] = { rank = tonumber( RankInfo1[1] ), num = tonumber( RankInfo1[2] ) }
        RankInfo[2] = { rank = tonumber( RankInfo2[1] ), num = tonumber( RankInfo2[2] ) }
    end

    local lastWeekDan = self.data.lastWeekDan
    local lastWeekRank = self.data.lastWeekRank

    if #RankInfo > 0 and lastWeekDan == 10 then
        local getNum = 5
        if lastWeekDan <= RankInfo[2].rank then
            getNum = RankInfo[2].num
        elseif lastWeekDan <= RankInfo[1].rank then
            getNum = RankInfo[2].num
        end

        return getNum
    else
        return normalNum
    end
end

function RankRaceMeta:getUnlockConfig( ... )
	local UnlockConfig = Misc:parse(self.data:getMetaValue('levelTarget') or '9999,9999,9999,9999,9999,9999', ',')
	return table.map(tonumber, UnlockConfig)
end

function RankRaceMeta:getTargetBuffConfig( ... )
	local ret = {}
	for i = 1, 6 do
		local v = self.data:getMetaValue('bonus' .. i) or '0%'
		v = string.match(v, '(%d+)[^%d]*')
		if not v then
			v = 0
		end
		table.insert(ret, tonumber(v) or 0)
	end
	return ret
end

function RankRaceMeta:getUnlockBuffConfig( ... )
	local ret = {}
	for i = 1, 10 do
		local v = self.data:getMetaValue('unlock' .. i) or '9999,9999,9999,9999,9999'
		local vv = Misc:parse(v, ',')
		table.insert(ret, table.map(tonumber, vv))
	end
	return ret
end


function RankRaceMeta:getShareTargetNum( ... )
	local ret = tonumber(self.data:getMetaValue('receiveShareNum') or 5) or 5
	return ret
end

return RankRaceMeta