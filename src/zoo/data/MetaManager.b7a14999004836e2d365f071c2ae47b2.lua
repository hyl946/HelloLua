require "hecore.class"
require "zoo.model.LuaXml"
require "zoo.data.DataRef"
require "zoo.data.MetaRef"

require 'zoo.data.LevelDiffcultFlag'

local debugMetaData = false

local instance = nil
MetaManager = {
}

function MetaManager.getInstance()
	if not instance then instance = MetaManager end
	return instance
end

local function parseItemDict(metaXML, childName, cls )
	local result = {}
	
	local xmlList = xml.find(metaXML, childName)
	for i,v in ipairs(xmlList) do
		local p = cls.new()
		p:fromLua(v)
		result[p.id] = p
	end
	return result
end 



local function parseItemDictNotSort(metaXML, childName, cls )
	local result = {}
	
	local xmlList = xml.find(metaXML, childName)
	for i,v in ipairs(xmlList) do
		local p = cls.new()
		p:fromLua(v)
		table.insert( result , p)
	end
	return result
end

function MetaManager:loadSingleMeta( source )
	local nodename, name, pattern, func = unpack(source)
	self[name] = func(self.metaXML, nodename, pattern)
	self.loader_count = self.loader_count + 1
	if self.loader_count >= self.max_cout then
		self:loadFinished()
	end
end

function MetaManager:loadFinished()
	LevelConfigGroupMgr.getInstance():initialize()
	
	self.metaXML = nil

	-- cuccwo 包计费新加计费代码，临时特殊处理
	if __ANDROID and PlatformConfig:isPlatform(PlatformNameEnum.kCUCCWO) then
		if self.goodsPayCode[10002] then
			self.goodsPayCode[10002].uniPayCode = "170223574295"
			self.goodsPayCode[10002].uniPayCode2 = "905885970820140113183434813800055"
		end
		if self.goodsPayCode[10003] then
			self.goodsPayCode[10003].uniPayCode = "170223574296"
			self.goodsPayCode[10003].uniPayCode2 = "905885970820140113183434813800056"
		end
	end
end

function MetaManager:addToLoader( loader )
	loader:add({'global', 'global', GlobalServerConfig, function (metaXML, childName, cls)
		local confList = xml.find(metaXML, childName)
		local conf = cls.new()
		conf:fromLua(confList)
		return conf
	end}, kFrameLoaderType.meta)

	self.max_cout = 1
	self.loader_count = 0
	local function Add( nodename, pattern, func, name )
		func = func or parseItemDict
		name = name or nodename
		loader:add({nodename, name, pattern, func}, kFrameLoaderType.meta)
		self.max_cout = self.max_cout + 1
	end

	local metaXML = self.metaXML

	Add('gamemode_prop', GameModePropMetaRef)
	
	Add('coin_blocker', CoinBlockerMetaRef)

	Add('freegift', FreegiftMetaRef)

	Add('goods', GoodsMetaRef)
	Add('level_reward', LevelRewardMetaRef)
	Add('level_trigger_config', LevelTriggerMetaRef, nil, 'level_trigger')

	Add('invite_reward', InviteRewardMetaRef)
	Add('level', LevelMetaRef)
	Add('level_area', LevelAreaMetaRef)
	Add('fruits', FruitsMetaRef)
	Add('mark', MarkMetaRef)
	Add('fruits_upgrade', FruitsUpgradeMetaRef)
	Add('headframe', HeadFrameMetaRef)
	Add('star_reward', StarRewardMetaRef)
	Add('gift_blocker', GiftBlockerMetaRef)
	Add('hide_area', HideAreaMetaRef)
	Add('ladybug_reward', LadybugRewardMetaRef)
	Add('prop', PropMetaRef)
	Add('product', ProductMetaRef)
	Add('product_android', ProductMetaRef)
	Add('goods_pay_code', GoodsPayCodeMetaRef, nil, 'goodsPayCode')
	Add('activity_rewards', ActivityRewardsMetaRef)
	Add('rewards', RewardsRef)
	Add('task', MissionRef, nil, 'missions')
	Add('task_creat_info', MissionCreateInfoRef, nil, 'mission_create_info')
	Add('share_config', ShareConfigRef)
	Add('level_config_group', LevelConfigGroupRef)
	Add('notification_client', NotificationMetaRef, nil, 'local_notification')

	local levelDifficultyLocal = require("zoo.loader.LevelDifficultyUpdateProcessor").new()
	local localLevelDifficultyCfg = levelDifficultyLocal:getLocalCofig()
	if localLevelDifficultyCfg ~= nil and #localLevelDifficultyCfg > 0 then
		self.level_difficulty = table.deserialize(localLevelDifficultyCfg) or {}
	else
		Add('level_difficulty', LevelDifficultyRef)
	end

	Add('level_farmstar', LevelFarmstarRef, parseItemDictNotSort)
	Add('user_tag', UserTagMetaRef)

	self:parseMoleWeeklyRaceConfig(metaXML)

	Add('area_task', AreaTaskMetaRef)
	Add('area_task_reward', AreaTaskRewardMetaRef)
	Add('four_star_adjust', FourStarAdjustMetaRef)
	Add('common_rank_reward', CommonRankRewardRef)
	Add('diffAdjust_addColorStrength', DiffAdjustAddColorStrengthRef)
end

function MetaManager:initialize()
	-- local path = "meta/meta_client.xml"
	-- path = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
	-- local metaXML = xml.load(path)

	local path = "meta/meta_client.inf"
	if __IOS_FB then  -- TW facebook
	 	path = "meta/fb_meta_client.inf"
	end
	path = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
	local meta_client = HeFileUtils:decodeFile(path)
	local metaXML = xml.eval(meta_client)

	-- 配置解析出错处理
	if not metaXML then
		local filemd5 = ""
		if not string.starts(path, "apk") then
			filemd5 = HeMathUtils:md5File(path)
		end
		local content = string.sub(tostring(meta_client), 1, 100)
		he_log_error(string.format("meta error: path:%s,md5:%s,content:%s", path, filemd5, content))
	end

	self.metaXML = metaXML
	
	if __WP8 then
		self.product_wp8 = parseItemDict(metaXML, "product_android", ProductMetaRef)
		self.product_wp8[1].mmPaycode = "30000827625109"
		self.product_wp8[2].mmPaycode = "30000827625110"
		self.product_wp8[3].mmPaycode = "30000827625111"
	end
end

function MetaManager:getRewards(rewardId)
	local rewardInfo = self.rewards[rewardId]
	if rewardInfo then
		return rewardInfo.rewards 
	end
end

--获取推荐的刷新关卡关
function MetaManager:getLevelFarmStar(  )
	return self.level_farmstar 
end


function MetaManager:parseMoleWeeklyRaceConfig(metaXML)
	self.moleWeeklyRaceConf = {}

	local constsConf = MoleWeeklyConstsRef.new()
	constsConf:fromLua(xml.find(metaXML, "mole_weekly_race_consts"))
	for k, v in pairs(constsConf) do
		self.moleWeeklyRaceConf[k] = tonumber(v)
	end
	-- printx(11, "moleConfig consts: ", table.tostringByKeyOrder(self.moleWeeklyRaceConf))

	self.moleWeeklyRaceConf.bossConfig = parseItemDict(metaXML, 'mole_weekly_race_bossConfig', MoleWeeklyBossRef)
	self.moleWeeklyRaceConf.groupConfig = parseItemDict(metaXML, 'mole_weekly_race_groupConfig', MoleWeeklyGroupRef)
	self.moleWeeklyRaceConf.propSkill = parseItemDict(metaXML, 'mole_weekly_race_propSkill', MoleWeeklyPropSkillRef)
	-- printx(11, "bossConfig conf: ", table.tostring(self.moleWeeklyRaceConf.bossConfig))
	-- printx(11, "propSkill conf: ", table.tostring(self.moleWeeklyRaceConf.propSkill))
	-- printx(11, "moleConfig conf: ", table.tostring(self.moleWeeklyRaceConf))
end

function MetaManager:getMoleWeeklyRaceConfig()
	return self.moleWeeklyRaceConf
end

function MetaManager:getUserTagConfig(nameKey)
	local datas = nil

	if self.user_tag then
		for k,v in pairs(self.user_tag) do
			if tostring(v.tagName) == tostring(nameKey) then

				datas = {}

				local durationTimeStr = tostring(v.durationTime)
				local durationTimeArr = string.split( durationTimeStr , ";")
				if durationTimeArr and #durationTimeArr > 0 then
					for i = 1 , #durationTimeArr do
						local str = durationTimeArr[i]
						local kvs = string.split( str , "_")
						if #kvs == 2 then
							if not datas.durationTime then
								datas.durationTime = {}
							end
							datas.durationTime[tostring(kvs[1])] = tonumber(kvs[2])
						else
							datas.durationTime = tonumber(kvs[1])
							break
						end
					end
				end


				local topLevelLengthStr = tostring(v.topLevelLength)
				local topLevelLengthArr = string.split( topLevelLengthStr , ";")
				if topLevelLengthArr and #topLevelLengthArr > 0 then
					for i = 1 , #topLevelLengthArr do
						local str = topLevelLengthArr[i]
						local kvs = string.split( str , "_")
						if #kvs == 2 then
							if not datas.topLevelLength then
								datas.topLevelLength = {}
							end
							datas.topLevelLength[tostring(kvs[1])] = tonumber(kvs[2])
						else
							datas.topLevelLength = tonumber(kvs[1])
							break
						end
					end
				end


				local dcStrategyStr = tostring(v.dcStrategy)
				local dcStrategyArr = string.split( dcStrategyStr , ";")
				if dcStrategyArr and #dcStrategyArr > 0 then
					for i = 1 , #dcStrategyArr do
						local str = dcStrategyArr[i]
						local kvs = string.split( str , "_")
						if #kvs == 2 then
							if not datas.dcStrategy then
								datas.dcStrategy = {}
							end
							datas.dcStrategy[tostring(kvs[1])] = tonumber(kvs[2])
						else
							datas.dcStrategy = tonumber(kvs[1])
							break
						end
					end
				end

				break
			end
		end
	end
	return datas
end

function MetaManager:getActivityRewardsByActID(actID)
	local rewards = {}
	for _, v in pairs(self.activity_rewards) do
		if tonumber(v.activityId) == tonumber(actID) then
			local rewardCfg = v
			if rewardCfg.activityId ~= nil then rewardCfg.activityId = tonumber(rewardCfg.activityId) end
			if rewardCfg.conditions ~= nil then rewardCfg.conditions = tonumber(rewardCfg.conditions) end
			if rewardCfg.rewardId ~= nil then rewardCfg.rewardId = tonumber(rewardCfg.rewardId) end
			rewards[#rewards + 1] = rewardCfg
		end
	end
	return rewards
end

function MetaManager:inviteReward_getInviteRewardMetaById(id, ...)
	assert(type(id) == "number")
	assert(#{...} == 0)

	for k,v in pairs(self.invite_reward) do

		if v.id == id then
			return v
		end
	end

	return false
end

function MetaManager:ladybugReward_getLadyBugRewardMeta(taskId, ...)
	assert(type(taskId) == "number")
	assert(#{...} == 0)

	for k,v in pairs(self.ladybug_reward) do
		if v.id == taskId then
			return v
		end
	end

	return false
end

function MetaManager:starReward_getRewardLevel(starNum, ...)
	assert(type(starNum) == "number")
	assert(#{...} == 0)


	local nearestLevel	= false

	for k,v in ipairs(self.star_reward) do

		if starNum >= v.starNum then

			if not nearestLevel or
				nearestLevel.starNum < v.starNum then
				nearestLevel = v
			end
		end
	end

	return nearestLevel
end

function MetaManager:starReward_getNextRewardLevel(starNum, ...)
	assert(type(starNum) == "number")
	assert(#{...} == 0)


	local nextNearestLevel	= false

	for k,v in ipairs(self.star_reward) do

		if starNum < v.starNum then

			if not nextNearestLevel or
				nextNearestLevel.starNum > v.starNum then
				nextNearestLevel = v
			end
		end
	end

	return nextNearestLevel
end

function MetaManager:starReward_getStarRewardMetaById(id, ...)
	assert(type(id) == "number")
	assert(#{...} == 0)

	for k,v in ipairs(self.star_reward) do

		assert(type(v.id) == "number")
		if v.id == id then
			return v
		end
	end

	return false
end

function MetaManager:isMinLevelAreaId( levelId )
	for i,v in pairs(self.level_area) do
		if v.minLevel == levelId then return true end
	end
	return false
end

function MetaManager:isMaxLevelAreaId( levelId )
	for i,v in pairs(self.level_area) do
		if v.maxLevel == levelId then return true end
	end
	return false
end

function MetaManager:getLevelAreaById( levelId )
	return self.level_area[levelId]
end
--根据关卡id得到 level_area 中的id
--直接复制拿走 local areaId = MetaManager:getInstance():getAreaIDByLevelID( levelId )
function MetaManager:getAreaIDByLevelID( levelId )

	local ret = table.find( self.level_area ,  function ( areaData )
		return areaData.maxLevel >= levelId and areaData.maxLevel <= levelId
	end )
	if ret then return ret.id end
	return nil
end



function MetaManager:getCoinBlockersByLevelId( levelId )
	for i, v in pairs(self.coin_blocker) do 
		if v.level == levelId then 
			return v 
		end
	end
	return nil
	-- return self.coin_blocker[levelId]
end

function MetaManager:getPropMeta(propId)
	return self.prop[propId]
end
function MetaManager:getGoodMeta(goodId) 
	return self.goods[goodId]
end
function MetaManager:getGoodPayCodeMeta(goodId)
	return self.goodsPayCode[goodId]
end

function MetaManager:getProductAndroidMeta(goodId)
	return self.product_android[goodId]
end

function MetaManager:updateProductAndroidByServer(info)
	local p = ProductMetaRef.new()
	p:fromLua(info)
	self.product_android[p.id] = p 
end

function MetaManager:getGoodMetaByItemID( itemId )
	for k,v in pairs(self.goods) do
		--RewardItemRef
		if #v.items == 1 and v.items[1].itemId == itemId then
			return v
		end
	end
	return nil
end

function MetaManager:getLevelRewardByLevelId( levelId )
	for k,v in pairs(self.level_reward) do
		if v.levelId == levelId then return v end
	end
	return nil
	--return self.level_reward[levelId]
end

function MetaManager:getLevelDifficultyAll()
	return self.level_difficulty or {}
end


function MetaManager:getLevelDifficultyByLevelId(levelId)
	local getID = tonumber(levelId)
	for k,v in pairs(self.level_difficulty) do
		local dataID = tonumber(v.id)
		if dataID ~= nil and getID ~= nil and dataID == getID then return v end
	end
	return nil
end

function MetaManager:getMarkByNum( markNum )
	local achiExtra = Achievement:getRightsExtra("MarkCoinIncomeTimes")
	local markByNum = self.mark[markNum]
	if achiExtra > 0 and markByNum and not UserManager.getInstance().markV2Active then
		local markMeta = table.copyValues(markByNum)
		for _,reward in ipairs(markMeta.rewards) do
			if reward.itemId == 2 then
				reward.num = reward.num + achiExtra * reward.num
			end
		end
		return markMeta
	else
		return markByNum
	end
end

--获取成就权益 对银币的加成
function MetaManager:getAchiCoinExtraNum()
    local achiExtra = Achievement:getRightsExtra("MarkCoinIncomeTimes")
	if achiExtra > 0 and UserManager.getInstance().markV2Active then
		return 0.05 -- 增加5%
	else
		return 0
	end
end

function MetaManager:getGameModePropByModeId( gameMode )
	return self.gamemode_prop[gameMode]
end

function MetaManager:getLevelAreaRefByLevelId(levelId, ...)
	assert(type(levelId) == "number")
	assert(#{...} == 0)

	for k,v in pairs(self.level_area) do

		if tonumber(v.minLevel) <= levelId and
			levelId <= tonumber(v.maxLevel) then
			return v
		end
	end

	return nil
end

function MetaManager:getNextLevelAreaRefByLevelId(levelId, ...)
	assert(#{...} == 0)

	local curLevelArea	= self:getLevelAreaRefByLevelId(levelId)
	local nextLevelArea	= false

	if curLevelArea then
		local curLevelAreaMaxLevel = tonumber(curLevelArea.maxLevel)
		if curLevelAreaMaxLevel <= self:getMaxNormalLevelByLevelArea() then 	--保证当前check的关卡是在当前版本配置允许的最高关之内
			local nextLevelAreaMinLevel	= curLevelAreaMaxLevel + 1
			nextLevelArea = self:getLevelAreaRefByLevelId(nextLevelAreaMinLevel)
		end
	end

	return nextLevelArea
end

function MetaManager:getMaxNormalLevelByLevelArea()
	if self.maxNormalLevelByLevelArea then
		return self.maxNormalLevelByLevelArea
	end

	local maxLevel = 0
	local maxLevelTop = nil

	for k,v in pairs(self.level_area) do
		if v.top == true then 
			maxLevelTop = v.maxLevel
			break
		end
		if v.maxLevel > maxLevel and v.maxLevel < 9999 then 
			maxLevel = v.maxLevel
		end
	end
	if maxLevelTop then 
		maxLevel = maxLevelTop
	end
	self.maxNormalLevelByLevelArea = maxLevel
	return maxLevel
end

function MetaManager:getAreaUnlockTimeInfo(topLevelId)
	local infoTable = {}
	local topAreaId = nil
	for k,v in pairs(self.level_area) do
		if v.minLevel > topLevelId then 
			if v.startTime then 
				local info = {}
				for m,n in pairs(v) do
					if m ~= "class" and m ~= "declare" then 
						info[m] = n
					end
				end
				table.insert(infoTable, info)
			end
		end
		if v.top then
			topAreaId = v.id
		end
	end
	return infoTable, topAreaId
end

function MetaManager:getHideUnlockTimeInfo()
	local infoTable = {}
	for k,v in pairs(self.hide_area) do
		if v.startTime then 
			local info = {}
			for m,n in pairs(v) do
				if m ~= "class" and m ~= "declare" then 
					info[m] = n
				end
			end
			table.insert(infoTable, info)
		end
	end

	return infoTable
end

function MetaManager:getFourStarUnlockTimeInfo()
	local infoTable = {}
	for k,v in pairs(self.four_star_adjust) do
		if v.startTime then 
			local info = {}
			for m,n in pairs(v) do
				if m ~= "class" and m ~= "declare" then 
					info[m] = n
				end
			end
			table.insert(infoTable, info)
		end
	end

	return infoTable
end

function MetaManager:getTaskLevelId(areaId)
	for k, v in pairs(self.level_area) do 
		if tonumber(areaId) == tonumber(v.id) then 
			return v.unlockTaskLevelId
		end
	end
end

function MetaManager:isTaskCanUnlockLevalArea(areaId)
	if self:getTaskLevelId(areaId) then 
		return true
	else
		return false
	end
end

function MetaManager:getAreaIdByTaskLevelId(taskLevelId)
	for k, v in pairs(self.level_area) do 
		if v.unlockTaskLevelId and v.unlockTaskLevelId == taskLevelId then 
			return v.id 
		end
	end
end

function MetaManager:getHideAreaLevelIds()
	local hideAreaLevelIds = {}
	local HIDE_LEVEL_ID_START = 10000
	for k,hideArea in pairs(self.hide_area) do
		local hideLevels = hideArea.hideLevelRange
		for i,v in ipairs(hideLevels) do
			table.insert(hideAreaLevelIds, HIDE_LEVEL_ID_START + v)
		end		
	end

	local function levelIdSorter(pre, next)
		return pre < next
	end

	table.sort(hideAreaLevelIds, levelIdSorter)
	
	return hideAreaLevelIds
end

function MetaManager:getHideAreaByHideLevelId(levelId)
	levelId = levelId - LevelMapManager.getInstance().hiddenNodeRange
	for k, hideArea in pairs(self.hide_area) do
		local hideLevels = hideArea.hideLevelRange
		for i, v in ipairs(hideLevels) do
			if v == levelId then
				return hideArea
			end
		end		
	end
	return nil
end

function MetaManager:getGiftBlockerByLevelId(levelId)
	if self.gift_blocker then
		for k, v in pairs(self.gift_blocker) do
			if v.level == levelId then
				return v
			end
		end
	end
	
	return nil
end

function MetaManager:getEnterInviteCodeReward()
	return self.global.enter_invite_code_reward
end

function MetaManager:getInitBagSize()
	return self.global.initBagSize
end

function MetaManager:getBagCapacity()
	return self.global.bag_capacity
end

function MetaManager:getFailLevelNumToShowJump()
	return self.global.failLevelNumToShowJump
end

function MetaManager:getProductMetaByID( id )
	for k, v in pairs(self.product) do
		if v.id == id then
			return v
		end
	end
	
	return nil
end

function MetaManager:getProductMetaByGoodsId( goodsId )
	for k, v in pairs(self.product) do
		if v.goodsId == goodsId then
			return v
		end
	end
	
	return nil
end

function MetaManager:getDailyMaxSendGiftCount()
	return self.global.daily_max_send_gift_count + Achievement:getRightsExtra( "SendReceiveEnergyNum" )
end

function MetaManager:getDailyMaxReceiveGiftCount()
	return self.global.daily_max_receive_gift_count + Achievement:getRightsExtra( "SendReceiveEnergyNum" )
end

function MetaManager:getFreegift(topLevel)
	local res
	if _G.isLocalDevelopMode then printx(0, "topLevel", topLevel) end
	if self.freegift and #self.freegift > 0 then
		res = self.freegift[1]
	else
		return nil
	end
	for k, v in ipairs(self.freegift) do
		if topLevel < v.topLevel then
			if _G.isLocalDevelopMode then printx(0, "v.topLevel", v.topLevel) end
			return res.item[1]
		else
			if _G.isLocalDevelopMode then printx(0, "v.topLevel", v.topLevel) end
			res = v
		end
	end
	return res.item[1]
end

function MetaManager:getNewUserRewards()
	if PlatformConfig:isBaiduPlatform() then
		return self.global.new_user_reward_baidu
	else
		return self.global.new_user_reward_normal
	end
end

function MetaManager:getMarketConfig()
	return self.market_config
end

function MetaManager:getFruitGrowCycle()
	return self.global.fruit_grow_cycle
end

function MetaManager:getCrowCountNum()
	return self.global.fruit_crow_count_num
end

function MetaManager:getInviteFriendCount()
	return self.global.invite_friends_count
end


----------------------------------------------------------------------------------------------------------------------------------------------------------------
--配置格式  | 为分割符   解锁等级|普通推送ABTest (a  b  a,b)|360推送ABTest(a  b  a,b)|
--                       普通推送奖励ID(-1代表无奖励)|普通推送奖励|
--                       360推送奖励ID(-1代表无奖励)|360推送奖励|推送周期|
--						 QQ推送ABTest(c  d  c,d)|QQ推送奖励ID(-1代表无奖励)|QQ推送奖励|
--						 当前普通推送优先(qq,phone,none三选一)|
--						 绑定手机是否有奖|绑定360是否有奖|绑定QQ是否有奖|推荐绑定功能是否开启(true  false)
-- v2|true|17|phone|none=a,b;7;14:10|360=a,b;8;14:10|qq=c,b;11;10013:1|wechat=a,b;12;10013:1
-- 例子(前端默认值)：     "17|a,b|a,b|7|14:10|8|14:10|7|c,d|11|10013:1|phone|true|true|true|true"
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function MetaManager:parsePushBindLogic()
	if self.pushBindMeta == nil then
		local defaultCfg = "v2|true|17|phone|7|phone=a,b;7;14:10|360=a,b;8;14:10"
		-- local defaultCfg = "17|a,b|a,b|7|14:10|8|14:10|7|c,d|11|10013:1|phone|true|true|true|true"
		local configStr = nil
		if UserManager.getInstance() ~= nil and 
			UserManager.getInstance().global ~= nil and 
			UserManager.getInstance().global.pushBindConfigV2 ~= nil then
			-- 新版配置
			configStr = UserManager.getInstance().global.pushBindConfigV2
			self.newPushBindMeta = PushBindMetaRef.new(configStr)
		end

		if configStr == nil then
			configStr = PushBindingLogic:getLocalString("pushBindConfigLocal")
		end

		configStr = configStr or defaultCfg
		local localCfg = PushBindingLogic:getLocalString("pushBindConfigLocal", defaultCfg)
		local localPushMeta = nil
		if PushBindingLogic:getAwardTimeLeft() > 0 then--领奖期间忽视配置更新，领奖阶段结束后，新配置生效
			if localCfg ~= configStr and localCfg ~= nil and #localCfg > 0 then
				configStr = localCfg
			end
		elseif localCfg ~= configStr then--线上配置发生变更，推送相关本地数据重置
			localPushMeta = PushBindMetaRef.new(localCfg)
		end

		self.pushBindMeta = PushBindMetaRef.new(configStr)
		if not self.newPushBindMeta then
			self.newPushBindMeta = self.pushBindMeta
		end
		if localPushMeta and (localPushMeta.ver ~= self.pushBindMeta.ver or localPushMeta.pushType ~= self.pushBindMeta.pushType) then
			PushBindingLogic:resetData()
		end
		PushBindingLogic:writeLocalString("pushBindConfigLocal", configStr)
	end
end

function MetaManager:pushLogicEnable()
	return self.pushBindMeta and self.pushBindMeta.pushEnable or false
end

function MetaManager:isPushBindQQ()
	return self.pushBindMeta.pushType == "qq"
end

function MetaManager:isPushRewardEnable(bindType)
 	local pushName  = PlatformConfig:getPlatformAuthName(bindType)
	return self.pushBindMeta:isPushRewardEnable(pushName)
end

function MetaManager:isPushBindType(bindType)
 	local pushName  = PlatformConfig:getPlatformAuthName(bindType)
	return self.pushBindMeta.pushType == pushName
end

function MetaManager:getPushBindType()
	return self.pushBindMeta.pushType
end

function MetaManager:pushPhoneAwardEanble()
	return self.pushBindMeta:isPushRewardEnable("phone")
end

function MetaManager:push360AwardEanble()
	return self.pushBindMeta:isPushRewardEnable("360")
end

function MetaManager:pushQQAwardEanble()
	return self.pushBindMeta:isPushRewardEnable("qq")
end

function MetaManager:isPushBindPhone()
	return self.pushBindMeta.pushType == "phone"
end

function MetaManager:isPushNone()
	return self.pushBindMeta.pushType == "none"
end

function MetaManager:getAllPushBindTypes()
	local ret = {}
	local pushPriority = self.pushBindMeta and self.pushBindMeta.pushPriority or {}
	for _, v in ipairs(pushPriority) do
		local authType = PlatformConfig:getPlatformAuthByName(v)
		if authType then table.insert(ret, authType) end
	end
	return ret
end

function MetaManager:getPushBindUnlockLevel()
	return self.newPushBindMeta.pushBindUnlockLevel or 17
end

function MetaManager:getPushBindCycle()
	return self.newPushBindMeta.pushBindCycle or 7
end

function MetaManager:getPushBindPhoneABCfg()
	return self.newPushBindMeta:getPushABTest("phone", "a,b")
end

function MetaManager:getPushBind360ABCfg()
	return self.newPushBindMeta:getPushABTest("360", "a,b")
end

function MetaManager:getPushBindQQCDCfg( ... )
	return self.newPushBindMeta:getPushABTest("qq", "c,d")
end

function MetaManager:getPushBindQQRewardID( ... )
	return self.newPushBindMeta:getPushRewardId("qq")
end

function MetaManager:getPushBindQQReward( ... )
	return self.newPushBindMeta:getPushReward("qq")
end

function MetaManager:getPushBindPhoneRewardID()
	return self.newPushBindMeta:getPushRewardId("phone")
end

function MetaManager:getPushBindPhoneReward()
	return self.newPushBindMeta:getPushReward("phone")
end

function MetaManager:getPushBind360RewardID()
	return self.newPushBindMeta:getPushRewardId("360")
end

function MetaManager:getPushBind360Reward()
	return self.newPushBindMeta:getPushReward("360")
end

function MetaManager:getPushBindReward(bindType)
 	local pushName  = PlatformConfig:getPlatformAuthName(bindType)
	return self.newPushBindMeta:getPushReward(pushName)
end

function MetaManager:getPushBindRewardId(bindType)
 	local pushName  = PlatformConfig:getPlatformAuthName(bindType)
	return self.newPushBindMeta:getPushRewardId(pushName)
end

function MetaManager:getPushBindABTest(bindType, default)
	default = default or "a,b"
 	local pushName  = PlatformConfig:getPlatformAuthName(bindType)
	return self.newPushBindMeta:getPushABTest(pushName, default)
end

function MetaManager:getMissionMeta()
	return self.missions
end

function MetaManager:getMissionIdMeta(missionId)
	for i,v in pairs(self.missions) do
		if v.id == missionId then
			return v
		end
	end
	return nil
end

function MetaManager:getMissionTypeData(typeId)
	if not typeId then
		return self.mission_create_info
	else
		for i,v in ipairs(self.mission_create_info) do
			if v.id == typeId then
				return v
			end
		end
		return nil
	end
end

function MetaManager:getMissionIdMetaByType(typeId)
	local ret = {}
	for i,v in pairs(self.missions) do
		if table.indexOf(v.cType, typeId) then
			table.insert(ret, v)
		end
	end
	return ret
end

function MetaManager:getGoodsMetaByAreaId(areaId)
	if not self.areaId2GoodsIdMap then
		self.areaId2GoodsIdMap = {}
		local item = nil
		for _, meta in pairs(self.goods) do
			item = meta.items and meta.items[1] or nil
			if item and item.itemId > 40000 and item.itemId < 50000 then
				self.areaId2GoodsIdMap[item.itemId] = meta
			end
		end
	end
	return self.areaId2GoodsIdMap[areaId]
end

function MetaManager:checkLevelTrigger(levelId, triggerType)
	for k,v in pairs(self.level_trigger) do
		if v.levelId == levelId then 
			return v:isEnable(triggerType) 
		end
	end
	return false 
end

function MetaManager:getActParams(levelId)
	local actParams1, actParams2
	for k,v in pairs(self.level_trigger) do
		if v.levelId == levelId then 
			actParams1 = v.actParams1
			actParams2 = v.actParams2
			break 
		end
	end
	return actParams1 or 0, actParams2 or 0
end



function MetaManager:getLevelDifficultFlag_ForStartPanel( levelId )
	local hasPassedLevel = UserManager:getInstance():hasPassedLevelEx( levelId )
	-- local animalScore = UserService.getInstance():getUserScore( levelId )
	local shouldShowGift = false
	if hasPassedLevel ==false then
		shouldShowGift = true
	end

	if not shouldShowGift then
		local friendHelp = UserManager.getInstance():hasPassedByTrick( levelId )
		if friendHelp  then
			shouldShowGift = true
		end
	end

	return self:getLevelDifficultFlag( levelId ) , shouldShowGift
end

function MetaManager:getLevelDifficultFlag( levelId )
	local difficult_2_levelIds = self.global.difficult_2_levelIds
	local difficult_1_levelIds = self.global.difficult_1_levelIds
	
	-- if 1 then
	-- 	return LevelDiffcultFlag.kExceedinglyDifficult
	-- end
	
	if table.exist(difficult_2_levelIds, levelId) then
		return LevelDiffcultFlag.kExceedinglyDifficult
	elseif table.exist(difficult_1_levelIds, levelId) then
		return LevelDiffcultFlag.kDiffcult
	else
		return LevelDiffcultFlag.kNormal
	end
end

function MetaManager:getLevelExtraRewards( levelId )

	local reward_config = ''
	local flag = self:getLevelDifficultFlag(levelId)
	if flag == LevelDiffcultFlag.kExceedinglyDifficult then
		reward_config = self.global.difficult_2_reward
	elseif flag == LevelDiffcultFlag.kDiffcult then
		reward_config = self.global.difficult_1_reward
	else

	end
--	reward_config = self.global.difficult_2_reward	
	local coinIncrease ,extraEnergy= string.match(reward_config, '(%d+%%*),(%d+%%*)')
	-- local extraEnergy = 0
	--coinIncrease 	银币额外增加的倍数
	--extraEnergy 	精力额外增加的数量

	if coinIncrease and extraEnergy then
		if string.sub(coinIncrease, -1, -1) == '%' then
			coinIncrease = (tonumber(string.sub(coinIncrease, 1, -2)) or 0) / 100
		end
		if string.sub(extraEnergy, -1, -1) == '%' then
			extraEnergy = (tonumber(string.sub(extraEnergy, 1, -2)) or 0) / 100
		end
		-- extraEnergy = tonumber(coinIncrease) or 0
	else
		coinIncrease = 0
		extraEnergy = 0
	end

	return {
		coinIncrease = coinIncrease,
		extraEnergy = extraEnergy,
	}
end

function MetaManager:getAreaTaskCfgByLevelId( levelId )
	local levelAreaRef = self:getLevelAreaRefByLevelId(levelId)
	if levelAreaRef then
		local areaId = levelAreaRef.id
		if areaId then
			return self:getAreaTaskCfg(areaId)
		end
	end
end

function MetaManager:getAreaTaskCfg( areaId )

	local levelAreaRef = self:getLevelAreaById(areaId)
	if not levelAreaRef then return end

	local levelBase = levelAreaRef.minLevel

	local areaTaskRef = nil

	for id, v in reverse_ipair(self.area_task) do
		if v.areaRange[1] <= areaId and areaId <= v.areaRange[2] then
			areaTaskRef = v
		end
	end

	if areaTaskRef then

		local rewards1 = self.area_task_reward[areaTaskRef.task1.rewardId or -1] or {}
		local rewards2 = self.area_task_reward[areaTaskRef.task2.rewardId or -1] or {}
		local rewards3 = self.area_task_reward[areaTaskRef.task3.rewardId or -1] or {}

		local taskCfg = {
			areaId = areaId,
			tasks = {
				[1] = {
					levelId = levelBase + (areaTaskRef.task1.levelIndexInArea or 0) - 1,
					duration = areaTaskRef.task1.duration or 0,
					rewards = rewards1.rewards or {},
					rewardsList = rewards1.rewardsList or {},
					rewardId = rewards1.id,
				},
				[2] = {
					levelId = levelBase + (areaTaskRef.task2.levelIndexInArea or 0) - 1,
					duration = areaTaskRef.task2.duration or 0,
					rewards = rewards2.rewards or {},
					rewardsList = rewards2.rewardsList or {},
					rewardId = rewards2.id,
				},
				[3] = {
					levelId = levelBase + (areaTaskRef.task3.levelIndexInArea or 0) - 1,
					duration = areaTaskRef.task3.duration or 0,
					rewards = rewards3.rewards or {},
					rewardsList = rewards3.rewardsList or {},
					rewardId = rewards3.id,
				},
			}
		}

		return taskCfg
	end
end

function MetaManager:getCommonRankRewardsByActId( actId )
	return table.filter(self.common_rank_reward or {}, function ( v )
		return v.activity == actId
	end)
end

function MetaManager:getScoreBuffBottleEffectPercent()
	return self.global.scoreBuffBottle_effectPercent
end

function MetaManager:getScoreBuffBottleSpecialTypes()
	return self.global.scoreBuffBottle_specialTypes
end

function MetaManager:getFullLevelGifts( ... )
	return self.global.full_level_gifts or "2:3000,10012:3"
end

function MetaManager:getProductItemDiffChangeFalsifyConfig()
	if not self.diffAdjust_addColorStrength then
		assert( false , "diffAdjust_addColorStrength is nil !!!")
		require "zoo.gamePlay.config.ProductItemDiffChangeFalsifyConfig"
		return ProductItemDiffChangeFalsifyConfig
	end

	if not self.productItemDiffChangeFalsifyConfig then

		local datas = {}
		datas[ProductItemDiffChangeMode.kAddColor] = {}
		datas[ProductItemDiffChangeMode.kAddColor]["kNormalLevel"] = {}
		datas[ProductItemDiffChangeMode.kAIAddColor] = {}
		datas[ProductItemDiffChangeMode.kAIAddColor]["kNormalLevel"] = {}

		for k , v in pairs( self.diffAdjust_addColorStrength ) do
			if v.mode == 3 then
				datas[ProductItemDiffChangeMode.kAddColor]["kNormalLevel"][v.ds] = v
			elseif v.mode == 4 then
				datas[ProductItemDiffChangeMode.kAIAddColor]["kNormalLevel"][v.ds] = v
			end
		end

		self.productItemDiffChangeFalsifyConfig = datas
	end

	return self.productItemDiffChangeFalsifyConfig
end