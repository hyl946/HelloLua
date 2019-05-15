require 'plua.simpleClass'
require 'zoo.data.MetaManager'
require 'zoo.gamePlay.GamePlayContext'
require 'zoo.gamePlay.GameItemData'
require "zoo.gamePlay.config.GamePlayGlobalConfigs"
require 'zoo.util.ObstacleFootprintManager'


GamePropsType = table.const
{
	kNone = 0,					--空
	kRefresh = 10001,			--游戏中 刷新
	kBack = 10002,				--游戏中 后退一步
	kSwap = 10003,				--游戏中 强制交换
	kAdd5 = 10004,				--游戏中 +5步
	kBombAdd5 = 10078,			--周赛游戏中 +5步 清全屏 
	kAdd15 = 10086,
	kLineBrush = 10005,			--游戏中 条纹刷子
	kColorBrush_b = 10006,		--游戏前置 球----魔力鸟	----随机
	kWrap_b = 10007,			--游戏前置 糖纸
	kColorBrush = 10008,		--游戏中 颜色刷子
	kTelescope = 10009,			--游戏中 望远镜
	kHammer = 10010,			--游戏中 锤子

	kRefresh_b = 10015,			--游戏前置 刷新
	kBack_b = 10016,			--游戏前置 后退一步
	kSwap_b = 10017,			--游戏前置 强制交换
	kAdd3_b = 10018,			--游戏前置 +3
	kLineBrush_b = 10019,		--游戏前置 条纹刷子
	kHammer_b = 10024,			--游戏前置 锤子
	kWrapBomb_b = 10081,		--游戏前置 爆炸
	kLineBomb_b = 10082, 		--游戏前置 直线

	kRefresh_l = 10025,			--临时刷新
	kHammer_l = 10026,			--临时锤子
	kLineBrush_l = 10027,		--临时条纹刷子
	kSwap_l	= 10028,			--临时强制交换

	kOctopusForbid = 10052,		--章鱼冰道具
	kOctopusForbid_l = 10053,	--章鱼冰道具 临时
	kRandomBird    =  10055, 	--随机魔力鸟
	kBroom			= 10056,	--女巫扫把
	kBroom_l		= 10057,    --女巫扫把 临时

	kBack_l          = 10065,    --后退 临时

	kBuffBoom_b     = 10089,    --开局导弹
	kRandomBird_b	= 10087,

	kFirecracker_b	= 10099,	-- 开局爆竹

	kMoleWeeklyRaceSPProp = 99995,  --鼹鼠周赛道具大招
	kSectionResumeBack = 99996,  --断面恢复虚拟道具，游戏业务逻辑不会使用
	kWukongJump = 99997,    --使蜗牛疯狂
	kHedgehogCrazy = 99998,    --使蜗牛疯狂
	kSpringFirework = 99999, 	--春节爆竹
	kNationDay2017Cast = 99996, 	--国庆技能

	kRowEffect = 10105,			--游戏中 横特效
    kRowEffect_l = 10108,		--游戏中 横特效(临时)
    kColumnEffect = 10109,		--游戏中 竖特效
    kColumnEffect_l = 10112,	--游戏中 竖特效(临时)
}


ReplayMode = {
	
	kNone = 0,              --玩家正常打关
	kNormal = 1 ,           --普通回放
	kSnapshot = 2 ,         --快照模式回放
	kCheck = 3 ,            --防作弊校验
	kResume = 4 ,           --闪退恢复
	kStrategy = 5,			--关卡攻略功能回放
	kAuto = 6,              --自动随机打关，无限加五步
	kQACheck = 7,           --
	kMcts = 8,              --AI打关
	kConsistencyCheck_Step1 = 9,      --一致性校验，自动随机打关，无限加五步，过关后保存所有断面数据和回放数据，并用回放数据启动kConsistencyCheck_Step2
	kConsistencyCheck_Step2 = 10,     --一致性校验，用kConsistencyCheck_Step1的回放数据回放操作，并记录下所有断面数据，并和kConsistencyCheck_Step1的断面数据对比
	kSectionResume = 11,     --断面恢复，使用断面数据直接恢复到闪退时的状态
	kAutoPlayCheck = 12,     --自动打关，随机交换，无限加五步，过关后统计使用步数
}


UserManager = {}
function UserManager:getInstance()
	return UserManager
end
function UserManager:getUID()
	return '12345'
end
UserManager.user = {
	topLevelId=1000,
}
function UserManager:getUserScore( ... )
	return {star=3}
end


ResUtils = {}
function ResUtils:getDropRuleItemId(itemID)
	if type(itemID) == 'number' then
		return itemID
	else
		local ids = string.split(itemID, '_')
		return tonumber(ids[1]), ids[2]
	end
end


ScoreBuffBottleLogic = {}
function ScoreBuffBottleLogic:hasScoreBuffForAsset(levelID)
	return false
end


---------------------------------------------------------------

caseObstacleFootprint = class(UnittestTask)

function caseObstacleFootprint:ctor()
	UnittestTask.ctor(self)

end

function caseObstacleFootprint:run(callback_success_message)

	if false then
		require 'zoo.model.MetaModel'
		require 'zoo.util.BigInt'
		require 'zoo.util.IntCoord'
		require 'zoo.net.LevelType'
		require 'zoo.data.LevelMapManager'
		require 'zoo.config.LevelConfig'
		-- require 'zoo.gamePlay.ReplayDataManager'
		require 'zoo.gamePlay.BoardLogic.GameInitBuffLogic'
		require 'zoo.localActivity.DragonBuff.DragonBuffManager'

		MetaManager:initialize()
		LevelMapManager.getInstance():initialize()

		for i = 100, 1500, 100 do
			self:dumpLevelConfig(i)
			self:printTarget(i)
		end
	end
	
	self:run_(100, false,
			{
			  goldenPod_collect = 0,
			  crystalBall_yellow = 0,
			  crystalBall_red = 0,
			  crystalBall_eliminate = 0,
			  coin_appear = 0,
			  crystalBall_appear = 0,
			  coin_blockEffect = 0,
			  crystalBall_blue = 0,
			  crystalBall_brown = 0,
			  crystalBall_green = 0,
			  coin_eliminate = 0,
			  crystalBall_purple = 0,
			}
		)

	self:run_(200, false,
			{
			  poison_eliminate = 0,
			  gift_10065 = 0,
			  ice_eliminate = 0,
			  gift_10025 = 0,
			  ice_hit = 0,
			  gift_10026 = 0,
			  brownFurball_generateSubItem = 0,
			  brownFurball_appear = 0,
			  cage_eliminate = 0,
			  greyFurball_eliminate = 0,
			  poison_appear = 0,
			}
		)

	self:run_(300, false,
			{
			  roost_appear = 0,
			  poison_appear = 0,
			  roost_hit = 0,
			  roost_generateSubItem = 0,
			  octopus_generateSubItem = 0,
			  poison_eliminate = 0,
			  snow_eliminate = 0,
			  snow_hit = 0,
			}
		)

	self:run_(400, false,
			{
			  goldenPod_collect = 0,
			  conveyor_covered_timestep = 0,
			  snow_hit = 0,
			  snow_eliminate = 0,
			}
		)

	self:run_(500, false,
			{
			  sand_eliminate = 0,
			  snow_eliminate = 0,
			  snow_hit = 0,
			  mimosa_covered_timestep = 0,
			}
		)

	self:run_(600, false,
			{
			  ice_hit = 0,
			  coin_blockEffect = 0,
			  ice_eliminate = 0,
			  coin_eliminate = 0,
			  coin_appear = 0,
			}
		)

	self:run_(700, false,
			{
			  coin_appear = 0,
			  coin_blockEffect = 0,
			  conveyor_covered_timestep = 0,
			  coin_eliminate = 0,
			  goldenPod_collect = 0,
			}
		)

	self:run_(800, false,
			{
			  goldenPod_collect = 0,
			  genie_attack = 0,
			  genie_hit = 0,
			  trapdoor_covered_timestep = 0,
			  conveyor_covered_timestep = 0,
			  snow_hit = 0,
			  snow_eliminate = 0,
			}
		)

	self:run_(900, false,
			{
			  conveyor_covered_timestep = 0,
			  pufferfish_eliminate = 0,
			  icicle_hit = 0,
			  coin_blockEffect = 0,
			  lotusPond_expand = 0,
			  icicle_eliminate = 0,
			  lotusPond_upgrade = 0,
			  coin_appear = 0,
			  pufferfish_hit_target = 0,
			  lotusPond_eliminate = 0,
			  coin_eliminate = 0,
			  pufferfish_blockEffect = 0,
			}
		)

	self:run_(1000, false,
			{
			  roost_appear = 0,
			  magicStone_hit = 0,
			  magicStone_hit_target = 0,
			  coin_appear = 0,
			  icicle_eliminate = 0,
			  coin_blockEffect = 0,
			  brownFurball_generateSubItem = 0,
			  cloud_hit = 0,
			  pufferfish_eliminate = 0,
			  pufferfish_blockEffect = 0,
			  cloud_eliminate = 0,
			  pufferfish_hit_target = 0,
			  cage_eliminate = 0,
			  icicle_hit = 0,
			  roost_hit = 0,
			  greyFurball_eliminate = 0,
			  brownFurball_appear = 0,
			  roost_generateSubItem = 0,
			  coin_eliminate = 0,
			  diamondCloud_collect = 0,
			}
		)

	self:run_(1100, false,
			{
			  goldenPod_collect = 0,
			  magicStone_hit_target = 0,
			  magicStone_hit = 0,
			  pufferfish_eliminate = 0,
			  roost_hit = 0,
			  roost_generateSubItem = 0,
			  roost_appear = 0,
			  conveyor_covered_timestep = 0,
			  thunderBird_hit_target = 0,
			  pufferfish_hit_target = 0,
			  thunderBird_attack = 0,
			  trapdoor_covered_timestep = 0,
			  snow_eliminate = 0,
			  snow_hit = 0,
			  pufferfish_blockEffect = 0,
			}
		)

	self:run_(1200, false,
			{
			  magicStone_hit_target = 0,
			  stump_eliminate = 0,
			  magicStone_hit = 0,
			  stump_generateSubItem = 0,
			  sand_eliminate = 0,
			  icicle_hit = 0,
			  greyFurball_eliminate = 0,
			  leafPile_eliminate = 0,
			  icicle_eliminate = 0,
			  brownFurball_generateSubItem = 0,
			  leafPile_hit = 0,
			  stump_hit = 0,
			  brownFurball_appear = 0,
			  snow_hit = 0,
			  snow_eliminate = 0,
			}
		)

	self:run_(1300, false,
			{
			  jellyfish_attack = 0,
			  jellyfish_active = 0,
			  lotusPond_eliminate = 0,
			  icicle_eliminate = 0,
			  pufferfish_hit_target = 0,
			  snow_eliminate = 0,
			  pufferfish_blockEffect = 0,
			  conveyor_covered_timestep = 0,
			  explosiveBottle_hit = 0,
			  icicle_hit = 0,
			  magicStone_hit_target = 0,
			  lotusPond_expand = 0,
			  magicStone_hit = 0,
			  explosiveBottle_eliminate = 0,
			  lotusPond_upgrade = 0,
			  snow_hit = 0,
			  jellyfish_hit_target = 0,
			  pufferfish_eliminate = 0,
			  jellyfish_hit = 0,
			}
		)

	self:run_(1400, false,
			{
			  frozenMissile_hit_target = 0,
			  poison_appear = 0,
			  cage_eliminate = 0,
			  leafPile_eliminate = 0,
			  padlock_unlocked_timestep = 0,
			  leafPile_hit = 0,
			  stump_hit = 0,
			  snow_eliminate = 0,
			  pufferfish_blockEffect = 0,
			  poison_eliminate = 0,
			  stump_eliminate = 0,
			  padlockKey_eliminate = 0,
			  frozenMissile_eliminate = 0,
			  starBottle_hugeAttack = 0,
			  starBottle_attack = 0,
			  snow_hit = 0,
			  pufferfish_hit_target = 0,
			  starBottle_active = 0,
			  pufferfish_eliminate = 0,
			  stump_generateSubItem = 0,
			}
		)

	self:run_(1500, false,
			{
			  jellyfish_attack = 0,
			  jellyfish_active = 0,
			  lotusPond_eliminate = 0,
			  coin_appear = 0,
			  icicle_eliminate = 0,
			  coin_blockEffect = 0,
			  chameleonEgg_eliminate = 0,
			  snow_eliminate = 0,
			  conveyor_covered_timestep = 0,
			  padlockKey_eliminate = 0,
			  padlock_unlocked_timestep = 0,
			  explosiveBottle_hit = 0,
			  explosiveBottle_eliminate = 0,
			  icicle_hit = 0,
			  starBottle_hugeAttack = 0,
			  jellyfish_hit_target = 0,
			  snow_hit = 0,
			  starBottle_attack = 0,
			  lotusPond_expand = 0,
			  lotusPond_upgrade = 0,
			  starBottle_active = 0,
			  coin_eliminate = 0,
			  jellyfish_hit = 0,
			}
		)

	callback_success_message(true, "")
end

function caseObstacleFootprint:dumpLevelConfig(levelId)
	local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID(levelId);
	local bin = amf3.encode(levelConfig)
	local file = io.open('levelconfig_' .. tostring(levelId) .. '.cfg', 'wb')
	file:write(bin)
	file:close()

	local fileList , featureMap = levelConfig:getDependingSpecialAssetsList(GameLevelType.kMainLevel , ReplayMode.kNone)
	local bin = amf3.encode(featureMap)
	local file = io.open('levelfeature_' .. tostring(levelId) .. '.cfg', 'wb')
	file:write(bin)
	file:close()

end

function caseObstacleFootprint:loadLevelConfig(levelId)
	local path = './src/zoo/unittest/data/levelconfig_' .. tostring(levelId) .. '.cfg'
	path = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
	local file = io.open(path, 'rb')
	local bin = file:read("*all")
	file:close()
	local config = amf3.decode(bin)

	local path = './src/zoo/unittest/data/levelfeature_' .. tostring(levelId) .. '.cfg'
	path = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
	local file = io.open(path, 'rb')
	local bin = file:read("*all")
	file:close()
	local feature = amf3.decode(bin)

	return config, feature
end

function caseObstacleFootprint:printTarget(levelId)
	local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID(levelId);
	local fileList , featureMap = levelConfig:getDependingSpecialAssetsList(GameLevelType.kMainLevel , ReplayMode.kNone)
	GamePlayContext:getInstance().levelFeatureMap = featureMap

	-- ObstacleFootprintManager:initData(nil, levelConfig)
	ObstacleFootprintManager.footprintMap = {}
	ObstacleFootprintManager:fillInFeatureKeyOnInit(levelConfig)
	local ret = ObstacleFootprintManager.footprintMap
	local s = table.tostring(ret)
	print('\n')
	print(tostring(levelId))
	print(s)
	print('\n')
end

function caseObstacleFootprint:run_(levelId, verbose, target)


	local levelConfig, featureMap = self:loadLevelConfig(levelId)
	-- local s = table.tostring(levelConfig)
	-- print('\n')
	-- print(s)
	-- print('\n')
	-- debug.debug()

	-- print(featureMap)
	-- print(table.tostring(featureMap))
	GamePlayContext:getInstance().levelFeatureMap = featureMap

	-- ObstacleFootprintManager:initData(nil, levelConfig)
	ObstacleFootprintManager.footprintMap = {}
	ObstacleFootprintManager:fillInFeatureKeyOnInit(levelConfig)
	local ret = ObstacleFootprintManager.footprintMap
	if verbose then
		local s = table.tostring(ret)
		print('\n')
		print(s)
		print('\n')
		debug.debug()
	end
	self:validate(ret, target)
end

function caseObstacleFootprint:validate(ret, target)
	table.compare(ret, target)
end
