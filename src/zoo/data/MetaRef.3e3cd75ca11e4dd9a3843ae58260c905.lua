require "zoo.util.MemClass"

local debugDataRef = false


--
-- RewardItemRef ---------------------------------------------------------
--

REWARDITEM_AWARDTYPE=
{
	--普通
	NORMAL = 0,
	--奖励加成来自 关卡难度标记
	LEVELDIFFCULTFLAG  = 1 ,
    --奖励加成来自 签到加成
	MARKADD  = 2 ,
}

RewardItemRef = class()
function RewardItemRef:ctor(itemId, num,awardType)
	self.itemId = itemId or 0
	self.num = num or 0
	--马俊松 加一个类型 标记这个奖励是哪来的
	self.awardType = awardType or REWARDITEM_AWARDTYPE.NORMAL
end

--
-- util func ---------------------------------------------------------
--

local function parseItemDict( src )
	if not src then return {} end
	assert(type(src) == "string")

	local result = {}
	local items = src:split(",")

	if items and #items > 0 then
		for i,v in ipairs(items) do
			local content = v:split(":")
			if content and #content > 0 then
				local key = tonumber(content[1])
				local value = tonumber(content[2])
				result[#result + 1] = RewardItemRef.new(key, value)
				-- table.insert(result, RewardItemRef.new(key, value))
			end
		end
	end

	if debugDataRef then
		if _G.isLocalDevelopMode then printx(0, "parseItemDict", #result) end
	end
	return result
end 

local function parseItemList( src )
	if not src then return {} end
	assert(type(src) == "string")

	local result = {}
	local items = src:split(",")

	if items and #items > 0 then
		for i,v in ipairs(items) do
			result[i] = tonumber(v)
		end
	end

	if debugDataRef then
		if _G.isLocalDevelopMode then printx(0, "parseItemList", #result) end
	end
	return result
end

local function parseConditionRewardList(src)
	if type(src) ~= "string" then return {} end

	local result = {}
	local rewards = string.split(src, ";")

	if rewards then
		for i, v in ipairs(rewards) do
			local reward = RewardsWithConditionRef.new()
			reward:fromLua(v)
			result[i] = reward
		end
		table.sort(result, function(a,b) return a.condition < b.condition end)
		for index, k in ipairs(result) do
			k.id = index
		end
	end
	return result
end

function parseIngameLimitDict( src )
	if not src then return {} end
	assert(type(src) == "string")

	local result = {}
	local items = src:split(",")

	if items and #items > 0 then
		for i,v in ipairs(items) do
			local content = v:split(":")
			if content and #content == 4 then

				local key = tonumber(content[1])
				local value = { daily= tonumber(content[3]),monthly= tonumber(content[4])  }
				result[key] = value

			end
		end
	end

	return result
end 
--
-- GlobalServerConfig ---------------------------------------------------------
--
GlobalServerConfig = class()
function GlobalServerConfig:ctor()
	self.single_item = 10
	self.ice = 1000
	self.blocker = 100
	self.collect = 10000
	self.lock = 100
	self.coin = 5
	self.cuteBall = 100
	self.crystalBall = 100
	self.strip = 200
	self.wrap = 250
	self.color = 300
	self.mixed_strip_strip = 500
	self.mixed_wrap_strip = 1000
	self.mixed_wrap_wrap = 1500
	self.mixed_color_strip = 2000
	self.mixed_color_color = 5000
	self.mixed_wrap_color = 2500
	self.multiple_wrap = 1
	self.multiple_strip = 0.5
	self.multiple_strip_strip = 2
	self.multiple_color = 1.5
	self.multiple_wrap_wrap = 3
	self.multiple_wrap_strip = 2.5
	self.multiple_color_wrap = 3.5
	self.multiple_color_strip = 3
	self.moveTranslateToStrip = 2500
	self.multiple_color_color = 4
	self.freeUnlockBagConfig = {2,5,10,16,25,36}
	self.translateStripBlast = 200
	self.compound_strip = 2
	self.initBagSize = 20 --18
	self.daily_max_send_gift_count = 5
	self.daily_max_receive_gift_count = 5
	self.compound_wrap = 3
	self.compound_color = 6
	self.user_energy_init_count = 30
	self.user_energy_max_count = 30
	self.invite_friends_count = 10
	self.invite_friends_continue_day = 60
	self.user_energy_request_get = 1
	self.daily_max_request_energy_count = 10
	self.user_energy_recover_time_unit = 480000
	self.user_energy_level_consume = 5
	self.fruit_grow_cycle = 180000
	self.bag_capacity = 10
	self.time_max_request_energy_receive_count = 5
	self.user_init_coin = 30000
	self.star_pot_view = {0,18,36}
	self.join_QQ_panel_reward = {}
	self.disable_payment = false
	--果树相关配置
	self.fruit_crow_count_num = 5
	self.promotion_qq_new_user_reward = {}
	self.energy_fruit_ratio = 18
	self.bug_mission_start = 2
	self.qq_new_user_reward = {}
	self.replace_color_upgrade = 400
	self.digTreasure_play_num = 5
	self.current_digger_match = 1
	self.fillSign = {}
	self.score_game_day = 5
	self.score_game_reward = {}
	self.enter_invite_code_reward = {}
	self.new_user_reward_normal = {}
	self.new_user_reward_baidu = {}
	self.new_user_reward_qq = {}
	self.week_match_levels = {}
	self.rabbit_week_match_levels = {}
	self.summer_week_match_levels = {}
	self.ingame_limit = {}
	self.ingame_limit_low = {}
	self.weekRankMinNum = 0
	self.weekSurpassLimit = 200
	self.weekSurpassReward = {}
	self.weekWeeklyReward = {}
	self.failLevelNumToShowJump = 999
	self.firstNewObstacleLevels = {}
	self.missionAutoLaunch = 0
	self.showLoginRewardTipDay = 0
	self.messagePagesOrder = {}

	self.difficult_1_levelIds = {  }
	self.difficult_2_levelIds = { }
	self.difficult_1_reward = ''
	self.difficult_2_reward = ''

end
function GlobalServerConfig:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil of GlobalServerConfig") end
		return		
	end

	for k,v in pairs(src) do
		if type(v) == "table" then
			local key = v.key
			local value = v[1]
			if key == "freeUnlockBagConfig" or key == "star_pot_view" or key == "fillSign" then
				value = parseItemList(value)
			elseif key == "join_QQ_panel_reward" or key == "score_game_reward" or key == "enter_invite_code_reward" or key == "new_user_reward_normal" or key == "new_user_reward_baidu" or key == "new_user_reward_qq" then
				value = parseItemDict(value)
			elseif key == "disable_payment" then
				value = (value == "true")
			elseif key == "fillSign" then
				local addMarkPrice = {}
				local ss = string.split(value, ",")
				for ids, mpi in ipairs(ss) do
					table.insert(addMarkPrice, tonumber(mpi))
				end
				value = addMarkPrice
				if _G.isLocalDevelopMode then printx(0, "fillSign", table.tostring(value)) end
			elseif key == 'week_match_levels' then
				value = parseItemList(value)
			elseif key == 'rabbit_week_match_levels' then
				value = parseItemList(value)
			elseif key == 'summer_week_match_levels' then
				value = parseItemList(value)
			elseif key == "autumn_week_match_levels" then
				value = parseItemList(value)
			elseif key == "winter_week_match_levels" then
				value = parseItemList(value)
			elseif key == "spring_week_match_levels" then
				value = parseItemList(value)
			elseif key == "summer_week_match_levels_2016" then
				value = parseItemList(value)
			elseif key == 'ingame_limit' then 
				value = parseIngameLimitDict(value)
			elseif key == 'ingame_limit_low' then 
				value = parseIngameLimitDict(value)
			elseif key == 'weekSurpassReward' then
				value = parseItemDict(value)
			elseif key == "weekWeeklyReward" then
				value = parseConditionRewardList(value)
			elseif key == "winterWeeklyReward" then
				value = parseConditionRewardList(value)
			elseif key == "firstNewObstacleLevels" then
				value = parseItemList(value)
			elseif key == "messagePagesOrder" then
				value = parseItemList(value)
			elseif key == "substitute_limit" then

			elseif key == 'difficult_1_levelIds' or key == 'difficult_2_levelIds' then
				value = parseItemList(value)
			elseif key == 'difficult_1_reward' or key == 'difficult_2_reward' then
				
			elseif key == "scoreBuffBottle_specialTypes" then
				value = parseItemList(value)
			else
				value = tonumber(value)
			end

			if value == nil then if _G.isLocalDevelopMode then printx(0, "GlobalServerConfig value should not be nil, key="..key) end end
			self[key] = value

			if debugDataRef then
				if _G.isLocalDevelopMode then printx(0, key, value) end
			end
		end		
	end
end
function GlobalServerConfig:getAddMarkPirce( addMarkNum )
	addMarkNum = addMarkNum or 0
	local price = self.fillSign[addMarkNum]
	if price == nil then return 0
	else return price end
end
--
-- MetaRef ---------------------------------------------------------
--
MetaRef = class()
function MetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil") end
		return
	end

	for k,v in pairs(src) do
		if type(k) == "string" then
			self[k] = tonumber(v)
			if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
		end
	end
end

function MetaRef.parseConditionRewardList(src)
	return parseConditionRewardList(src)
end


--
-- DiggerMatchGemRewardMetaRef ---------------------------------------------------------
--
-- <diggerMatchGemReward id="1" gemCount="1" rewards="2:100"/> 
DiggerMatchGemRewardMetaRef = class(MetaRef)
function DiggerMatchGemRewardMetaRef:ctor()
	self.id = 0
	self.gemCount = 1
	self.rewards = {}
end
function DiggerMatchGemRewardMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at DiggerMatchGemRewardMetaRef:fromLua") end
		return
	end

	for k,v in pairs(src) do
		if k == "rewards" then
			self.rewards = parseItemDict(v)
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
end

--
-- GameModePropMetaRef ---------------------------------------------------------
--
-- <gamemode_prop id="1" gamemode="Classic moves" ingameProps="10001,10010,10002,10003,10005,10004" initProps="10018,10015,10007"/>  
GameModePropMetaRef = class(MetaRef)
function GameModePropMetaRef:ctor()
	self.id = 0
	self.gamemode = ""
	self.ingameProps = {}
	self.initProps = {}
end
function GameModePropMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at GameModePropMetaRef:fromLua") end
		return
	end

	for k,v in pairs(src) do
		if k == "ingameProps" then
			self.ingameProps = parseItemList(v)
		elseif k == "initProps" then
			self.initProps = parseItemList(v)
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
end

--
-- CoinBlockerMetaRef ---------------------------------------------------------
--
-- <coin_blocker id="1" coin_amount="50" level="91"/>   
CoinBlockerMetaRef = class(MetaRef)
function CoinBlockerMetaRef:ctor()
	self.id = 0
	self.coin_amount = 0
	self.level = 0
end

--
-- VipLevelMetaRef ---------------------------------------------------------
--
-- <vip_level id="0" vipExp="10"/>  
VipLevelMetaRef = class(MetaRef)
function VipLevelMetaRef:ctor()
	self.id = 0
	self.vipExp = 0
end

--
-- MarketPromotionMetaRef ---------------------------------------------------------
--
-- <market_promotion id="1" condition="1:999" contractId="12345678" rewards="2:100"/> 
MarketPromotionMetaRef = class(MetaRef)
function MarketPromotionMetaRef:ctor()
	self.id = 0
	self.condition = {}
	self.contractId = 0
	self.rewards = {}
end
function MarketPromotionMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at MarketPromotionMetaRef:fromLua") end
		return
	end

	for k,v in pairs(src) do
		if k == "rewards" then
			self.rewards = parseItemDict(v)
		elseif k == "condition" then
			self.condition = parseItemDict(v)
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
end

--
-- FreegiftMetaRef ---------------------------------------------------------
--
-- <freegift id="1" item="2:300" topLevel="30"/>  
FreegiftMetaRef = class(MetaRef)
function FreegiftMetaRef:ctor()
	self.id = 0
	self.item = {}
	self.topLevel = 0
end
function FreegiftMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at FreegiftMetaRef:fromLua") end
		return
	end

	for k,v in pairs(src) do
		if k == "item" then
			self.item = parseItemDict(v)
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
end

--
-- GoodsMetaRef ---------------------------------------------------------
--
-- <goods id="1" coin="0" discountQCash="0" fCash="99" items="10001:1" level="1" limit="0" on="1" point="0" qCash="39" sort="6"/>  
GoodsMetaRef = class(MetaRef)
function GoodsMetaRef:ctor()
	self.id = 0
	self.coin = 0
	self.discountQCash = 0
	self.fCash = 0
	self.items = {}
	self.level = 0
	self.limit = 0
	self.on = 0
	self.point = 0
	self.qCash = 0
	self.sort = 0
	self.fCash = 0
	self.discountFCash = 0
	self.sign = nil
	self.thirdRmb = 0
end
function GoodsMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at GoodsMetaRef:fromLua") end
		return
	end

	local function parseTag(src)
		local tags  = src:split(',')
		local ret = {}
		for k, v in pairs(tags) do 
			table.insert(ret, tonumber(v))
		end
		return ret
	end

	for k,v in pairs(src) do
		if k == "items" then
			self.items = parseItemDict(v)
		elseif k == 'tag' then
			self.tag = parseTag(v)
		elseif k == "beginDate" then
			self.beginDate = tostring(v)
		elseif k == "endDate" then
			self.endDate = tostring(v)
		elseif k == "sign" then 
			self.sign = tostring(v)
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end

	if __IOS_FB then -- facebook使用fCash字段
		self.qCash = self.fCash
		self.discountQCash = self.discountFCash
	end
end

function GoodsMetaRef:getCash()
	--current we use qCash
	if self.discountQCash > 0 then return self.discountQCash 
	else return self.qCash end
end

--static
function GoodsMetaRef:isSupplyEnergyGoods( goodsId )
	if goodsId == 23 or goodsId == 34 then return true
	else return false end
end

--
-- GoodsPayCodeMetaRef ---------------------------------------------------------
--
-- <goodsPayCode id="1" mmPayCode="30000807400101" uniPayCode="140121023049" miPayCode="com.xiaomi.xiaoxiaole.code1" price="3" />
GoodsPayCodeMetaRef = class(MetaRef)
function GoodsPayCodeMetaRef:ctor()
	self.id = 0
	self.props = ""
	self.mmPayCode = ""
	self.mmPayCode_two = ""
	self.mmPayCode_three = ""
	self.uniPayCode = ""
	self.miPayCode = ""
	self.ctPayCode = ""
	self.ctCustomPayCode = ""
	self.price = ""
end
function GoodsPayCodeMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at GoodsPayCodeMetaRef:fromLua") end
		return
	end

	for k,v in pairs(src) do
		if k == "id" then
			self[k] = tonumber(v)
			if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
		elseif type(k) == "string" then
			self[k] = tostring(v)
			if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
		end
	end
end

--
-- LevelRewardMetaRef ---------------------------------------------------------
--
-- <level_reward id="2" failNum="3" failTips="2,3" levelId="2" oneStarDefaultReward="2:20" oneStarReward="2:300" threeStarDefaultReward="2:35" threeStarReward="2:300,4:3" twoStarDefaultReward="2:25" twoStarReward="2:300,4:2"/>  

LevelRewardMetaRef = class(MetaRef)
function LevelRewardMetaRef:ctor()
	self.id = 0
	self.failNum = 0
	self.failTips = 0
	self.levelId = 0
	self.oneStarDefaultReward = {}
	self.oneStarReward = {}
	self.threeStarDefaultReward = {}
	self.threeStarReward = {}
	self.twoStarDefaultReward = {}
	self.twoStarReward = {}
	self.fourStarReward = {}
	self.fourStarDefaultReward = {}

	self.newRewardItemsIndex = {}
	self.defaultRewardItemsIndex = {}
	self.skipLevel = 0    --跳关需要花费的金豆荚数

	self.difficultyDegree = 100
	self.difStar1 = 1
	self.difStar2 = 1
	self.difStar3 = 1
	self.difStar4 = 1
end
function LevelRewardMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at LevelRewardMetaRef:fromLua") end
		return
	end
	local dictItems = {oneStarReward=1, oneStarDefaultReward=1, twoStarReward=1, twoStarDefaultReward=1, threeStarReward=1, threeStarDefaultReward=1, fourStarReward=1,fourStarDefaultReward=1}
	for k,v in pairs(src) do
		if dictItems[k]~= nil then
			self[k] = parseItemDict(v)
		else 
			if k == "moneyTreeReward" then 
				self.moneyTreeReward = parseItemDict(v)
			elseif k == "failTips" then
				self.failTips = parseItemList(v)
			else
				if type(k) == "string" then
					self[k] = tonumber(v)
					if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
				end
			end			
		end
	end

	self.newRewardItemsIndex[1] = self.oneStarReward
	self.newRewardItemsIndex[2] = self.twoStarReward
	self.newRewardItemsIndex[3] = self.threeStarReward
	self.newRewardItemsIndex[4] = self.fourStarReward

	self.defaultRewardItemsIndex[1] = self.oneStarDefaultReward
	self.defaultRewardItemsIndex[2] = self.twoStarDefaultReward
	self.defaultRewardItemsIndex[3] = self.threeStarDefaultReward
	self.defaultRewardItemsIndex[4] = self.fourStarDefaultReward
end
function LevelRewardMetaRef:getNewStarRewards( star )
	return self.newRewardItemsIndex[star]
end

function LevelRewardMetaRef:getDefaultStarRewards( star )
	return self.defaultRewardItemsIndex[star]
end

function LevelRewardMetaRef:getSkipLevelSpend( ... )
	-- body
	return self.skipLevel
end
--
-- InviteRewardMetaRef ---------------------------------------------------------
--
-- <invite_reward id="1" condition="0:1" rewards="2:500"/>  
InviteRewardMetaRef = class(MetaRef)
function InviteRewardMetaRef:ctor()
	self.id = 0
	self.condition = {}
	self.rewards = {}
end
function InviteRewardMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at InviteRewardMetaRef:fromLua") end
		return
	end

	for k,v in pairs(src) do
		if k == "condition" then
			self.condition = parseItemDict(v)
		elseif k == "rewards" then
			self.rewards = parseItemDict(v)
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
end

--
-- LevelMetaRef ---------------------------------------------------------
--
-- <level id="1" exp="10"/>  
LevelMetaRef = class(MetaRef)
function LevelMetaRef:ctor()
	self.id = 0
	self.exp = 0
end

--
-- QgameVipDailyRewardMetaRef ---------------------------------------------------------
--
-- <qq_game_vip_daily_reward id="1" reward="10012:2,2:1000" type="1" vipLevel="1"/>  

QgameVipDailyRewardMetaRef = class(MetaRef)
function QgameVipDailyRewardMetaRef:ctor()
	self.id = 0
	self.reward = {}
	self.type = 0
	self.vipLevel = 0
end
function QgameVipDailyRewardMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at QgameVipDailyRewardMetaRef:fromLua") end
		return
	end
	for k,v in pairs(src) do
		if k == "reward" then
			self.reward = parseItemDict(v)
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
end

--
-- DecoMetaRef ---------------------------------------------------------
--
-- <deco id="20001" type="1"/> 
DecoMetaRef = class(MetaRef)
function DecoMetaRef:ctor()
	self.id = 0
	self.type = 0
end

--
-- LevelAreaMetaRef ---------------------------------------------------------
--
-- <level_area id="40001" maxLevel="15" minLevel="1" star="0"/>  
LevelAreaMetaRef = class(MetaRef)
function LevelAreaMetaRef:ctor()
	self.id = 0
	self.maxLevel = 0
	self.minLevel = 0
	self.star = 0
	self.unlockTaskLevelId = nil
	self.top = false 
	self.startTime = nil
end

function LevelAreaMetaRef:fromLua(src)
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at GoodsPayCodeMetaRef:fromLua") end
		return
	end

	for k,v in pairs(src) do
		if k == "top" then
			self[k] = string.lower(tostring(v)) == "true"
			if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
		elseif k == "startTime" then 
			self[k] = tostring(v)
			if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
		elseif type(k) == "string" then
			self[k] = tonumber(v)
			if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
		end
	end
end

--
-- FuncMetaRef ---------------------------------------------------------
--
-- <func id="30001" type="1"/>  
FuncMetaRef = class(MetaRef)
function FuncMetaRef:ctor()
	self.id = 0
	self.type = 0
end

--
-- FruitsMetaRef ---------------------------------------------------------
--
-- <fruits id="1" level="1" reward="2:1150,4:1" upgrade="100"/>  

FruitsMetaRef = class(MetaRef)
function FruitsMetaRef:ctor()
	self.id = 0
	self.level = 0
	self.reward = {}
	self.upgrade = 0
end
function FruitsMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at FruitsMetaRef:fromLua") end
		return
	end
	for k,v in pairs(src) do
		if k == "reward" then
			self.reward = parseItemDict(v)
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
end

--
-- MarkMetaRef ---------------------------------------------------------
--
-- <mark id="1" rewards="2:1000" type="1"/>  

MarkMetaRef = class(MetaRef)
function MarkMetaRef:ctor()
	self.id = 0
	self.rewards = {}
	self.type = 0
end
function MarkMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at MarkMetaRef:fromLua") end
		return
	end
	for k,v in pairs(src) do
		if k == "rewards" then
			self.rewards = parseItemDict(v)
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
end

--
-- AchiMetaRef ---------------------------------------------------------
--
-- <achi id="1" type="3"/>  
AchiMetaRef = class(MetaRef)
function AchiMetaRef:ctor()
	self.id = 0
	self.type = 0
end

--
-- DiggerMatchRankRewardMetaRef ---------------------------------------------------------
--
-- <digger_match_rank_reward id="1" maxRange="1" minRange="1" rewards="2:100"/> 

DiggerMatchRankRewardMetaRef = class(MetaRef)
function DiggerMatchRankRewardMetaRef:ctor()
	self.id = 0
	self.maxRange = 0
	self.minRange = 0
	self.rewards = {}
end
function DiggerMatchRankRewardMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at DiggerMatchRankRewardMetaRef:fromLua") end
		return
	end
	for k,v in pairs(src) do
		if k == "rewards" then
			self.rewards = parseItemDict(v)
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
end

--
-- DiggerMatchGemRewardMetaRef ---------------------------------------------------------
--
-- <digger_match_gem_reward id="1" gemCount="1" rewards="2:100"/> 

--jDiggerMatchGemRewardMetaRef = class(DiggerMatchRankRewardMetaRef)
--jfunction DiggerMatchGemRewardMetaRef:ctor()
--j	self.id = 0
--j	self.gemCount = 0
--j	self.rewards = {}
--jend

--
-- FruitsUpgradeMetaRef ---------------------------------------------------------
--
-- <fruits_upgrade id="3" coin="120000" level="3" lock="false" pickCount="4" plus="50" upgradeCondition="2:2"/>  

FruitsUpgradeMetaRef = class(MetaRef)
function FruitsUpgradeMetaRef:ctor()
	self.id = 0
	self.coin = 0
	self.level = 0
	self.lock = false
	self.pickCount = 0
	self.plus = 0
	self.upgradeCondition = {}
end
function FruitsUpgradeMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at FruitsUpgradeMetaRef:fromLua") end
		return
	end
	for k,v in pairs(src) do
		if k == "upgradeCondition" then
			self.upgradeCondition = parseItemDict(v)
		elseif k == "newUpgradeCondition" then
			self.newUpgradeCondition = parseItemDict(v)
		elseif k == "lock" then
			self.lock = (v == "true")
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
	--这里不读取 phoneLoginLimit 字段 因为应用宝已经去手机登录了 在果树界面会让玩家绑定别的 比如微信
	self.upgradeCondition = self.newUpgradeCondition
end


--
-- HeadFrameMetaRef ---------------------------------------------------------
--
-- <headframe id="6012" endTime="2019-07-19 19:00:00"/> 

HeadFrameMetaRef = class(MetaRef)
function HeadFrameMetaRef:ctor()
	self.id = 0
	self.endTime = 0
end
function HeadFrameMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at HeadFrameMetaRef:fromLua") end
		return
	end
	for k,v in pairs(src) do

		if k == "endTime" then 
			self[k] = tostring(v)
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end

end

--
-- QqVipDailyRewardMetaRef ---------------------------------------------------------
--
-- <qq_vip_daily_reward id="1" reward="10012:1,2:500" type="1" vipLevel="1"/>  

QqVipDailyRewardMetaRef = class(MetaRef)
function QqVipDailyRewardMetaRef:ctor()
	self.id = 0
	self.reward = {}
	self.type = 0
	self.vipLevel = 0
end
function QqVipDailyRewardMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at QqVipDailyRewardMetaRef:fromLua") end
		return
	end
	for k,v in pairs(src) do
		if k == "reward" then
			self.reward = parseItemDict(v)
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
end

--
-- StarRewardMetaRef ---------------------------------------------------------
--
-- <star_reward id="1" reward="10013:2" starNum="24"/>  

StarRewardMetaRef = class(MetaRef)
function StarRewardMetaRef:ctor()
	self.id = 0
	self.reward = {}
	self.starNum = 0
	self.delta = 0
	self.rewardString = nil
end
function StarRewardMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at StarRewardMetaRef:fromLua") end
		return
	end
	for k,v in pairs(src) do
		if k == "reward" then
			self.reward = parseItemDict(v)
			self.rewardString = v
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
end

--
-- DiscountNotifyMetaRef ---------------------------------------------------------
--
-- <discount_notify id="1" conditions="1:3,2:2" goods="37:7" mode="2"/>  

DiscountNotifyMetaRef = class(MetaRef)
function DiscountNotifyMetaRef:ctor()
	self.id = 0
	self.conditions = {}
	self.goods = {}
	self.mode = 0
end
function DiscountNotifyMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at DiscountNotifyMetaRef:fromLua") end
		return
	end
	for k,v in pairs(src) do
		if k == "conditions" then
			self.conditions = parseItemDict(v)
		elseif k == "goods" then
			self.goods = parseItemDict(v)
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
end

--
-- GiftBlockerMetaRef ---------------------------------------------------------
--
-- <gift_blocker id="5" level="10013" prop_id="10026,10025"/> 

GiftBlockerMetaRef = class(MetaRef)
function GiftBlockerMetaRef:ctor()
	self.id = 0
	self.prop_id = {}
	self.level = 0
end
function GiftBlockerMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at GiftBlockerMetaRef:fromLua") end
		return
	end
	for k,v in pairs(src) do
		if k == "prop_id" then
			self.prop_id = parseItemList(v)
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
end

--
-- HideAreaMetaRef ---------------------------------------------------------
--
-- <hide_area id="1" continueLevels="1-44" hideAreaId="0" hideLevelRange="1-3"/>  

HideAreaMetaRef = class(MetaRef)
function HideAreaMetaRef:ctor()
	self.id = 0
	self.continueLevels = {0,1}
	self.hideAreaId = 0
	self.hideLevelRange = {0,1}
	self.hideReward = {}
	self.startTime = nil
	self.inDesign = false
end
local function parseHideAreaLevel( src )
	if not src then return {} end
	assert(type(src) == "string")
	local content = src:split("-")
	local beginNum = tonumber(content[1])
	local endNum = tonumber(content[2])
	local result = {}
	for i = beginNum, endNum do
		table.insert(result, i)
	end
	return result
end 
function HideAreaMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at HideAreaMetaRef:fromLua") end
		return
	end
	for k,v in pairs(src) do
		if k == "continueLevels" then
			self.continueLevels = parseHideAreaLevel(v)
		elseif k == "hideLevelRange" then
			self.hideLevelRange = parseHideAreaLevel(v)
		elseif k == "hideReward" then
			self.hideReward = parseItemDict(v)
		elseif k == "startTime" then 
			self[k] = tostring(v)
		elseif k == "inDesign" then
			self.inDesign = (v == "true")
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
end

--
-- LadybugRewardMetaRef ---------------------------------------------------------
--
-- <ladybug_reward id="1" goalType="1:12" missionReward="2:3000,10013:2" timeLimit="24"/>  

LadybugRewardMetaRef = class(MetaRef)
function LadybugRewardMetaRef:ctor()
	self.id = 0
	self.goalType = {}
	self.missionReward = {}
	self.timeLimit = 0
end
function LadybugRewardMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at LadybugRewardMetaRef:fromLua") end
		return
	end
	for k,v in pairs(src) do
		if k == "goalType" then
			self.goalType = parseItemDict(v)
		elseif k == "missionReward" then
			self.missionReward = parseItemDict(v)
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
end


--
-- PropMetaRef ---------------------------------------------------------
--
-- <prop id="10004" confidence="0" maxUsetime="0" reward="1" sell="100" type="true" unlock="1" useable="false" value="5"/>  

PropMetaRef = class(MetaRef)
function PropMetaRef:ctor()
	self.id = 0
	self.confidence = 0
	self.maxUsetime = 0
	self.reward = 0
	self.sell = 0
	self.type = true
	self.unlock = 0
	self.useable = false
	self.value = 0
	self.expireTime = 0
end
function PropMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at PropMetaRef:fromLua") end
		return
	end
	for k,v in pairs(src) do
		if k == "type" then
			self.type = (v == "true")
		elseif k == "useable" then
			self.useable = (v == "true")
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
				if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
			end
		end
	end
end

--
-- ProductMetaRef ---------------------------------------------------------
--
-- <product id="1" cash="60" productId="com.happyelements.animal.gold.cn.1" discount="10"/>
ProductMetaRef = class(MetaRef)
function ProductMetaRef:ctor()
	self.id = 0
	self.cash = 0
	self.productId = ""
	self.show = true
	self.showCode = 0
	discount = 10
end
function ProductMetaRef:fromLua(src)
	if not src then
		if _G.isLocalDevelopMode then printx(0, "		[WARNING] lua data is nil at ProductMetaRef:fromLua") end
		return
	end

	for k, v in pairs(src) do
		if k == "productId" then
			self.productId = v
		elseif k == "show" then
			self.show = v == "1"
			self.showCode = tonumber(v) or 0
		elseif k == "tag" then
			self.tag = v
		else
			if type(k) == "string" then
				self[k] = tonumber(v)
			end
			if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
		end
	end
end

MarketConfigRef = class(MetaRef)
function MarketConfigRef:ctor()
	self.goods = {}
	self.id = 0
	self.textKey = ''
end
function MarketConfigRef:fromLua(src)
	if not src then
		if _G.isLocalDevelopMode then printx(0, "		[WARNING] lua data is nil at MarketConfigRef:fromLua") end
		return
	end

	for k, v in pairs(src) do
		if k == 'id' then
			self.id = tonumber(v)
		elseif k == 'textKey' then
			self.textKey = v
		elseif type(v) == 'table' then
			table.insert(self.goods, tonumber(v.id))
		end
	end
end

WeeklyRaceExchangeMetaRef = class(MetaRef)
function WeeklyRaceExchangeMetaRef:ctor()
end

function WeeklyRaceExchangeMetaRef:fromLua(src)
	if not src then
		if _G.isLocalDevelopMode then printx(0, "		[WARNING] lua data is nil at MarketConfigRef:fromLua") end
		return
	end

	local function parseDailyRewardBox(id, str)
		assert(str)
		local reward = {}
		local step1 = str:split("=")
		reward.id = id
		reward.needCount = tonumber(step1[1])
		reward.items = parseItemDict(step1[2])
		return reward
	end

	self.dailyRewardBoxes = {}
	for k, v in pairs(src) do 
		if k == 'id' then 
			self.id = tonumber(v)
		elseif k == 'coinExchangeReward' then
			self.coinExchangeReward = parseItemDict(v)
		elseif k == 'energyExchangeReward' then
			self.energyExchangeReward = parseItemDict(v)
		elseif k == 'surpassReward' then
			self.surpassReward = parseItemDict(v)
		elseif k == 'reward1' then
			self.dailyRewardBoxes[1] = parseDailyRewardBox(1, v)
		elseif k == 'reward2' then
			self.dailyRewardBoxes[2] = parseDailyRewardBox(2, v)
		elseif k == 'reward3' then
			self.dailyRewardBoxes[3] = parseDailyRewardBox(3, v)
		elseif k == 'reward4' then
			self.dailyRewardBoxes[4] = parseDailyRewardBox(4, v)
		else
			self[k] = tonumber(v)
		end
	end
end

WeeklyRaceDailyLimitMetaRef = class(MetaRef)
function WeeklyRaceDailyLimitMetaRef:ctor()
end

function WeeklyRaceDailyLimitMetaRef:fromLua(src)
	if not src then
		if _G.isLocalDevelopMode then printx(0, "		[WARNING] lua data is nil at MarketConfigRef:fromLua") end
		return
	end

	for k, v in pairs(src) do 
		self[k] = tonumber(v)
	end
end


WeeklyRaceGemRewardMetaRef = class(MetaRef)
function WeeklyRaceGemRewardMetaRef:ctor()
end

function WeeklyRaceGemRewardMetaRef:fromLua(src)
	if not src then
		if _G.isLocalDevelopMode then printx(0, "		[WARNING] lua data is nil at MarketConfigRef:fromLua") end
		return
	end

	for k, v in pairs(src) do 
		if k == 'id' then 
			self.id = tonumber(v)
		elseif k == 'reward1' then
			self.reward1 = parseItemDict(v)
		elseif k == 'reward2' then
			self.reward2 = parseItemDict(v)
		elseif k == 'reward3' then
			self.reward3 = parseItemDict(v)
		elseif k == 'reward4' then
			self.reward4 = parseItemDict(v)
		elseif k == 'reward5' then
			self.reward5 = parseItemDict(v)
		else
			self[k] = tonumber(v)
		end
	end
end

CnValentineMetaRef = class(MetaRef)
function CnValentineMetaRef:fromLua(src)
	if not src then
		if _G.isLocalDevelopMode then printx(0, "		[WARNING] lua data is nil at MarketConfigRef:fromLua") end
		return
	end

	for k, v in pairs(src) do
		if k == 'id' then
			self.id = tonumber(v)
		elseif k == 'num' then
			self.num = tonumber(v)
		elseif k == 'rewards' then
			self.rewards = parseItemDict(v)
		else 
			self[k] = v
		end
	end
end

ActivityRewardsMetaRef = class(MetaRef)
function ActivityRewardsMetaRef:fromLua(src)
	if not src then
		if _G.isLocalDevelopMode then printx(0, "		[WARNING] lua data is nil at ActivityRewardsMetaRef:fromLua") end
		return
	end

	for k, v in pairs(src) do
		if k == "rewards" then 
			self.rewards = parseItemDict(v) 
		elseif k == "id" then
			self.id = tonumber(v)
		else
			self[k] = v
		end
	end
end

RewardsRef = class(MetaRef)
function RewardsRef:fromLua(src)
	if not src then return end
	for k, v in pairs(src) do
		if k == "rewards" then
			self.rewards = parseItemDict(v)
		else self[k] = tonumber(v) end
	end
end

RewardsWithConditionRef = class(MetaRef)
function RewardsWithConditionRef:ctor()
	self.id = 0
	self.condition = 0
	self.items = {}
end

function RewardsWithConditionRef:fromLua(src)
	if type(src) == "string" then
		local vals = string.split(src, "=")
		local condition = 0
		local items = {}
		if #vals > 1 then
			condition = tonumber(vals[1])
			items = parseItemDict(vals[2])
		elseif #vals == 1 then
			items = parseItemDict(vals[1])
		end
		self.condition = condition
		self.items = items
	end
end

SummerWeeklyLevelRewardsRef = class(MetaRef)
function SummerWeeklyLevelRewardsRef:ctor()
	self.id = 0
	self.levelId = 0
	self.dailyRewards = {} 		-- 每日奖励list
	self.weeklyRewards = {}		-- 每周奖励
	self.rankRewards = {}		-- 排名奖励
	self.surpassRewards = {}	-- 每超越一名好友的奖励
	self.rankMinNum = 20		-- 进入排行榜的最低成绩
	self.surpassLimit = 200		-- 超越好友奖励最大奖励人数
end

function SummerWeeklyLevelRewardsRef:fromLua(src)
	local function parseDailyRewards(src)
		if type(src) ~= "string" then return {} end
		local ret = {}
		local dailyRewards = string.split(src, "|")
		if dailyRewards and #dailyRewards > 0 then
			for i, v in ipairs(dailyRewards) do
				ret[i] = parseConditionRewardList(v)
			end
		end
		-- if _G.isLocalDevelopMode then printx(0, "dailyRewards:", tostring(ret)) end
		return ret
	end

	for k, v in pairs(src) do
		if k == 'id' then 
			self.id = tonumber(v)
		elseif k == "levelId" then	
			self.levelId = tonumber(v)
		elseif k == 'dailyReward' then
			self.dailyRewards = parseDailyRewards(v)
		elseif k == 'weeklyReward' then
			self.weeklyRewards = parseConditionRewardList(v)
		elseif k == 'rankReward' then
			self.rankRewards = parseConditionRewardList(v)
		elseif k == 'surpassReward' then
			self.surpassRewards = parseItemDict(v)
		elseif k == 'rankMinNum' then
			self.rankMinNum = tonumber(v)
		elseif k == 'surpassLimit' then
			self.surpassLimit = tonumber(v)
		else
			self[k] = tonumber(v)
		end
	end
end

AutumnWeeklyLevelRewardsRef = class(MetaRef)
function AutumnWeeklyLevelRewardsRef:ctor()
	self.id = 0
	self.day = 0
	self.dailyRewards = {} 		-- 每日奖励list
end

function AutumnWeeklyLevelRewardsRef:fromLua(src)
	for k, v in pairs(src) do
		if k == 'id' then 
			self.id = tonumber(v)
		elseif k == "day" then	
			self.day = tonumber(v)
		elseif k == 'dailyReward' then
			self.dailyRewards = parseConditionRewardList(v)
		end
	end
end

LevelStatusRef = class(MetaRef)

MissionRef = class(MetaRef)
function MissionRef:ctor()
	self.id = 0
	self.mType = 0
	self.cType = {}
	self.condition = {}
end

function MissionRef:fromLua(src)
	for k,v in pairs(src) do
		if k == "cType" then
			self.cType = string.split(v, ',')
			for i,v in ipairs(self.cType) do
				self.cType[i] = tonumber(v)
			end
		elseif k == "condition" then
			self.condition = string.split(v, ',')
			for i,v in ipairs(self.condition) do
				local values = string.split(v, ':')
				self.condition[i] = {}
				for j, w in ipairs(values) do
					table.insert(self.condition[i], tonumber(w))
				end
			end
		else
			self[k] = tonumber(v)
		end
	end
end

MissionCreateInfoRef = class(MetaRef)
function MissionCreateInfoRef:ctor()
	self.id = 0
	self.special = false
	self.weekly = 0
	self.daily = 0
	self.minLevel = 0
	self.maxLevel = 0
	self.priority = 0
	self.minLogin = 0
	self.maxLogin = 0
	self.maxReturn = 0
	self.maxSignIn = 0
end

function MissionCreateInfoRef:fromLua(src)
	for k,v in pairs(src) do
		if k == "special" then
			self.special = string.lower(v) == "true"
		else
			self[k] = tonumber(v) or 0
		end
	end
end

ShareConfigRef = class(MetaRef)
function ShareConfigRef:fromLua( src )
	for k,v in pairs(src) do
		self[k] = v
	end
end

LevelConfigGroupRef = class(MetaRef)
function LevelConfigGroupRef:fromLua( src )
	for k,v in pairs(src) do
		self[k] = v
	end
end

LevelDifficultyRef = class(MetaRef)
function LevelDifficultyRef:fromLua(src)
	for k, v in pairs(src) do
		self[k] = tonumber(v) or 0
	end
end
LevelFarmstarRef = class(MetaRef)
function LevelFarmstarRef:fromLua(src)
	for k, v in pairs(src) do
		self[k] = tonumber(v) or 0
	end
end



UserTagMetaRef = class(MetaRef)
function UserTagMetaRef:fromLua(src)
	for k, v in pairs(src) do
		self[k] = v
	end
end

--
-- LevelTriggerMetaRef ---------------------------------------------------------
--
LevelTriggerMetaRef = class(MetaRef)
function LevelTriggerMetaRef:ctor()
	self.id = 0 
	self.levelId = 0
	self.strategy = false
end

function LevelTriggerMetaRef:fromLua(src)
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at GoodsPayCodeMetaRef:fromLua") end
		return
	end

	for k,v in pairs(src) do
		if k == "id" or  k == "levelId" or k == "actParams1" or k == "actParams2" then
			self[k] = tonumber(v)
			if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
		elseif k == "strategy" then
			self[k] = string.lower(tostring(v)) == "true"
			if debugDataRef then if _G.isLocalDevelopMode then printx(0, k, v) end end
		end
	end
end

function LevelTriggerMetaRef:isEnable(triggerType)
	if triggerType == "strategy" then 
		return self.strategy
	end
	return false 
end

NotificationMetaRef = class(MetaRef)
function NotificationMetaRef:ctor()

end

function NotificationMetaRef:fromLua(src)
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at NotificationMetaRef:fromLua") end
		return
	end

	for k,v in pairs(src) do
		self[k] = v
	end
end

-----------------------------------------------------------
PushBindDetailRef = class()

function PushBindDetailRef:ctor()
	self.name = nil
	self.abTestType = "a,b"
	self.rewardId = -1
	self.rewards = nil
	self.rewardEnable = false
end

function PushBindDetailRef:fromString(str)
	local array1 = string.split(str, "=")
	local array2 = string.split(array1[2], ";")
	self.name = array1[1]
	self.abTestType = array2[1]
	self.rewardId = tonumber(array2[2]) or -1
	self.rewards = array2[3]
	self.rewardEnable = self.rewardId > 0
end

PushBindMetaRef = class()

function PushBindMetaRef:ctor(configStr)
	self.pushEnable = false
	self.pushBindUnlockLevel = 17
	self.pushType = "none"
	self.pushBindCycle = 7
	self.pushCfg = {}
	self.pushPriority = {}
	self.ver = nil
	if configStr then
		self:fromString(configStr)
	end
end

function PushBindMetaRef:_fromStringV2(configStr)
	local cfgArray = string.split(configStr, "|")
	self.pushEnable = (cfgArray[1] == "true")
	self.pushBindUnlockLevel = tonumber(cfgArray[2])
	self.pushType = cfgArray[3]
	self.pushBindCycle = tonumber(cfgArray[4])
	self.pushCfg = {}
	self.pushPriority = {}
	self.ver = "v2"
	for i = 5, #cfgArray do
		local detail = PushBindDetailRef.new()
		detail:fromString(cfgArray[i])
		self.pushCfg[detail.name] = detail
		table.insert(self.pushPriority, detail.name)
	end
	return self
end

function PushBindMetaRef:_fromStringV1(configStr)
	local bindCfgAry = string.split(configStr, "|")
	self.pushEnable = (bindCfgAry[16] == nil) or (bindCfgAry[16] == "true")
	self.pushType = bindCfgAry[12] or "phone"
	self.pushBindCycle = tonumber(bindCfgAry[8])
	self.pushBindUnlockLevel = tonumber(bindCfgAry[1])
	self.pushCfg = {}
	self.pushPriority = {}
	self.ver = nil

	local phoneMeta = PushBindDetailRef.new()
	phoneMeta.name = "phone"
	phoneMeta.abTestType = bindCfgAry[2]
	phoneMeta.rewardId = tonumber(bindCfgAry[4])
	phoneMeta.rewards = bindCfgAry[5]
	phoneMeta.rewardEnable = (bindCfgAry[13] == "true")
	self.pushCfg[phoneMeta.name] = phoneMeta
	table.insert(self.pushPriority, phoneMeta.name)

	local qihooMeta = PushBindDetailRef.new()
	qihooMeta.name = "360"
	qihooMeta.abTestType = bindCfgAry[3]
	qihooMeta.rewardId = tonumber(bindCfgAry[6])
	qihooMeta.rewards = bindCfgAry[7]
	qihooMeta.rewardEnable = (bindCfgAry[14] == "true")
	self.pushCfg[qihooMeta.name] = qihooMeta
	table.insert(self.pushPriority, qihooMeta.name)

	local qqMeta = PushBindDetailRef.new()
	qqMeta.name = "qq"
	qqMeta.abTestType = bindCfgAry[9]
	qqMeta.rewardId = tonumber(bindCfgAry[10])
	qqMeta.rewards = bindCfgAry[11]
	qqMeta.rewardEnable = (bindCfgAry[15] == "true")
	self.pushCfg[qqMeta.name] = qqMeta
	table.insert(self.pushPriority, qqMeta.name)
end

function PushBindMetaRef:fromString(configStr)
	local ver = nil
	local _configStr = configStr
	local firstSpIdx = string.find(configStr, "|")
	if firstSpIdx then
		ver = string.sub(configStr, 1, firstSpIdx-1)
	end
	if ver == "v2" then
		_configStr = string.sub(configStr, firstSpIdx+1)
		self:_fromStringV2(_configStr)
	else
		self:_fromStringV1(_configStr)
	end
end

function PushBindMetaRef:getPushDetail(pushName)
	if not pushName then return nil end
	return self.pushCfg[pushName]
end

function PushBindMetaRef:isPushRewardEnable(pushName)
	local detail = self:getPushDetail(pushName)
	return detail and detail.rewardEnable or false
end

function PushBindMetaRef:getPushABTest(pushName, default)
	local detail = self:getPushDetail(pushName)
	return detail and detail.abTestType or default
end

function PushBindMetaRef:getPushRewardId(pushName)
	local detail = self:getPushDetail(pushName)
	return detail and detail.rewardId or -1
end

function PushBindMetaRef:getPushReward(pushName)
	local detail = self:getPushDetail(pushName)
	return detail and detail.rewards or nil
end

------------------------- Mole Weekly Ref    START   --------------------------
MoleWeeklyConstsRef = class(MetaRef)
function MoleWeeklyConstsRef:ctor()
	self.defaultGroupID = 0
	self.bossBloodOverflowAddition = 0
	self.bossRewardOverflowAddition = 0
	self.specialSkillBossNo = 0
	self.specialSkillBossCastNo = 0
	self.propSkillFullValue = 0
end

function MoleWeeklyConstsRef:fromLua(src)
	for k, v in pairs(src) do
		if type(v) == "table" then
			local key = v.key
			local value = v[1]
			self[key] = value
		end		
	end
end

MoleWeeklyBossRef = class(MetaRef)
function MoleWeeklyBossRef:ctor()
	self.id = 0
	self.blood = 0
	self.demolishReward = 0
	self.cA = 0
	self.cB = 0
	self.cC = 0
	self.f = 0
	self.m = 0
	self.s = 0
	self.t = 0
end

MoleWeeklyGroupRef = class(MetaRef)
function MoleWeeklyGroupRef:ctor()
	self.id = 0
	self.skillWeight = ""
	self.bloodIncrease = 0
	self.demolishRewardIncrease = 0
end

function MoleWeeklyGroupRef:fromLua(src)
	if not src then
		return
	end

	for k, v in pairs(src) do
		if k == "skillWeight" then 
			local weightItems = v:split(",")
			self.skillWeight = weightItems
		elseif type(k) == "string" then
			self[k] = tonumber(v)
		end
	end
end

MoleWeeklyPropSkillRef = class(MetaRef)
function MoleWeeklyPropSkillRef:ctor()
	self.id = 0
	self.damage = 0
	self.preFillPercent = 0
	self.throwEffectAmount = 0
	self.throwColourAmount = 0
end
------------------------- Mole Weekly Ref     END   --------------------------



AreaTaskMetaRef = class(MetaRef)
function AreaTaskMetaRef:ctor()
	self.id = 0
	self.areaRange = {0, 0}
	self.task1 = {}
	self.task2 = {}
	self.task3 = {}
end
function AreaTaskMetaRef:fromLua(src)
	for k, v in pairs(src) do
		if k == 'id' then 
			self.id = tonumber(v)
		elseif k == 'areaRange' then

			local fields = string.split(v, '~') or {}
			local s, e = fields[1], fields[2]

			if s and e then
				self.areaRange = {
					tonumber(s) or 0,
					tonumber(e) or 0,
				}
			end
		elseif k == 'task1' then
			self.task1 = self:parseRewardCfg(v)
		elseif k == 'task2' then
			self.task2 = self:parseRewardCfg(v)
		elseif k == 'task3' then
			self.task3 = self:parseRewardCfg(v)
		end
	end
end

function AreaTaskMetaRef:parseRewardCfg( v )
	local ret = table.map(tonumber, string.split(v, ','))
	return {
		levelIndexInArea = ret[1], -- 1 ~ 15
		duration = ret[2] * 60 * 1000,
		rewardId = ret[3],
	}
end

FourStarAdjustMetaRef = class(MetaRef)
function FourStarAdjustMetaRef:ctor()
	self.id = 0
	self.levels = {}
	self.startTime = nil
end

function FourStarAdjustMetaRef:fromLua( src )
	if not src then
		if _G.isLocalDevelopMode then printx(0, "  [WARNING] lua data is nil at FourStarAdjustMetaRef:fromLua") end
		return
	end
	local function parseLevels(src)
		if not src then return {} end
		assert(type(src) == "string")

		local result = {}
		local levels = src:split(",")

		if levels and #levels > 0 then
			for i,v in ipairs(levels) do
				table.insert(result, tonumber(v))
			end
		end
		return result
	end

	for k,v in pairs(src) do
		if k == "levels" then
			self.levels = parseLevels(v)
		elseif k == "startTime" then 
			self[k] = tostring(v)
		elseif k == "top" then
			self[k] = string.lower(tostring(v)) == "true"
		else 
			if type(k) == "string" then
				self[k] = tonumber(v)
			end
		end
	end
end

AreaTaskRewardMetaRef = class(MetaRef)
function AreaTaskRewardMetaRef:ctor()
	self.id = 0
	--旧方案 仍在使用
	self.rewards = {}
	--新方案
	self.rewardsList = {
		{},
		{},
		{},
	} 
end

function AreaTaskRewardMetaRef:fromLua(src)
	local Misc = require 'zoo.quarterlyRankRace.utils.Misc'
	for k, v in pairs(src) do
		if k == 'id' then 
			self.id = tonumber(v)
		elseif k == 'rewards' then
			for _, item in ipairs(Misc:parse(v, ',:')) do
				table.insert(self.rewards, {
					itemId = tonumber(item[1]) or 2,
					num = tonumber(item[2]) or 1,
				})
			end
		elseif k == 'rewardsList' then
			for groupIndex, rewards in ipairs(Misc:parse(v, '|,:')) do
				if self.rewardsList[groupIndex] then
					for _, rewardItem in ipairs(rewards) do
						table.insert(self.rewardsList[groupIndex], {
							itemId = tonumber(rewardItem[1]) or 2,
							num = tonumber(rewardItem[2]) or 1,
						})
					end
				end
			end
		end
	end
end


CommonRankRewardRef = class(MetaRef)
function CommonRankRewardRef:ctor()
	self.id = 0
	self.activity = 0
	self.maxRange = 0
	self.minRange = 0
	self.rewards = {}
end

function CommonRankRewardRef:fromLua( src )
	local Misc = require 'zoo.quarterlyRankRace.utils.Misc'
	for k, v in pairs(src) do
		if k == 'id' then 
			self.id = tonumber(v)
		elseif k == 'activity' then
			self.activity = tonumber(v) or 0
		elseif k == 'maxRange' then
			self.maxRange = tonumber(v) or 0
		elseif k == 'minRange' then
			self.minRange = tonumber(v) or 0
		elseif k == 'rewards' then
			for _, item in ipairs(Misc:parse(v, ',:')) do
				table.insert(self.rewards, {
					itemId = tonumber(item[1]) or 2,
					num = tonumber(item[2]) or 1,
				})
			end
		end
	end
end


DiffAdjustAddColorStrengthRef = class(MetaRef)
function DiffAdjustAddColorStrengthRef:ctor()
	self.id = 0
	self.mode = 0
	self.ds = 0

	self.ruleA_n1 = 0
	self.ruleA_m1 = 0
	self.ruleA_n2 = 0
	self.ruleA_m2 = 0
	self.ruleA_n3 = 0
	self.ruleA_m3 = 0
	self.ruleA_n4 = 0
	self.ruleA_m4 = 0

	self.ruleB_n1 = 0
	self.ruleB_m1 = 0
	self.ruleB_n2 = 0
	self.ruleB_m2 = 0
	self.ruleB_n3 = 0
	self.ruleB_m3 = 0
	self.ruleB_n4 = 0
	self.ruleB_m4 = 0

	self.ruleC_n1 = 0
	self.ruleC_m1 = 0
	self.ruleC_n2 = 0
	self.ruleC_m2 = 0
	self.ruleC_n3 = 0
	self.ruleC_m3 = 0
	self.ruleC_n4 = 0
	self.ruleC_m4 = 0

end

function DiffAdjustAddColorStrengthRef:fromLua( src )
	for k , v in pairs( src ) do
		self[k] = tonumber( v )
	end
end