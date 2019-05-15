require "zoo.util.MemClass"
require "zoo.util.IntCoord"
require "zoo.gamePlay.GameBoardData"
require "zoo.gamePlay.GameItemData"
require "zoo.gamePlay.GameMapInitialLogic"
require "zoo.gamePlay.BoardAction.GameBoardActionDataSet"
require "zoo.gamePlay.BoardAction.GameBoardActionRunner"
require "zoo.gamePlay.BoardLogic.SwapItemLogic"
require "zoo.gamePlay.BoardLogic.FallingItemLogic"
require "zoo.gamePlay.BoardLogic.NewFallingItemLogic"
-- require "zoo.gamePlay.BoardLogic.NewFallingItemLogicTem"
require "zoo.gamePlay.BoardLogic.FallingItemExecutorLogic"
-- require "zoo.gamePlay.BoardLogic.FallingItemExecutorLogic_old"
require "zoo.gamePlay.BoardLogic.ItemHalfStableCheckLogic"
require "zoo.gamePlay.BoardLogic.DestructionPlanLogic"
require "zoo.gamePlay.BoardLogic.DestroyItemLogic"
require "zoo.gamePlay.BoardLogic.RefreshItemLogic"
require "zoo.gamePlay.BoardLogic.DropBuffLogic"
require "zoo.gamePlay.BoardLogic.GlobalCoreActionLogic"
require "zoo.gamePlay.mode.GameModeFactory"
require "zoo.gamePlay.mode.LevelModeProcessor"
require "zoo.gamePlay.BoardLogic.GameExtandPlayLogic"
require "zoo.gamePlay.BoardLogic.ProductItemLogic"
require "zoo.gamePlay.GameItemOrderData"
require "zoo.gamePlay.GamePlayMusicPlayer"
require "zoo.gamePlay.SaveRevertData"
require "zoo.gamePlay.fsm.StateMachine"
require 'zoo.gamePlay.trigger.GamePlayEventTrigger'
require "zoo.util.FUUUManager"
require "zoo.util.ObstacleFootprintManager"
require "zoo.util.RandomFactory"
require "zoo.util.ClipBoardUtil"
require "zoo.gamePlay.ReplayDataManager"
require "zoo.gamePlay.SnapshotManager"
require 'zoo.panelBusLogic.guideAtlas.GuideAtlasLogic'
require "zoo.gamePlay.BoardLogic.ProductItemDiffChangeLogic"
require "zoo.gamePlay.BoardLogic.CertainPlayLogic.ChameleonLogic"
require "zoo.gamePlay.BoardLogic.Blocker206Logic"
require "zoo.gamePlay.SectionResumeManager"
require "zoo.gamePlay.ReplayAutoCheckManager"
require "zoo.gamePlay.AutoCheckLevelManager"
require "zoo.gamePlay.SectionData"
require "zoo.gamePlay.BoardLogic.CertainPlayLogic.PacmanLogic"
require "zoo.gamePlay.BoardLogic.CertainPlayLogic.TurretLogic"
require "zoo.gamePlay.BoardLogic.CertainPlayLogic.MoleWeeklyRaceLogic"
require "zoo.gamePlay.BoardLogic.CertainPlayLogic.GhostLogic"
require "zoo.gamePlay.BoardLogic.CertainPlayLogic.CommonMultipleHittingPriorityLogic"
require "zoo.gamePlay.BoardLogic.CertainPlayLogic.SunflowerLogic"
require "zoo.gamePlay.BoardLogic.CertainPlayLogic.SquidLogic"
require "zoo.gamePlay.BoardLogic.CertainPlayLogic.WanShengLogic"

local UserReviewLogic = require 'zoo.gamePlay.review.UserReviewLogic'

UseNewFallingLogic = nil

nativeImplement = require("hecore.nativeImplement")

local __encryptKeys = {
	theCurMoves = true, 
	totalScore = true, 
	ingredientsCount = true, 
	kLightUpLeftCount = true, 
	fireworkEnergy = true,
	coinDestroyNum = true,
	oringinTotalScore = true ,
}

GameBoardLogic = memory_class_simple(__encryptKeys)

--local encryptIndex = 0


function GameBoardLogic:ctor()

	-- debug.debug()

	self.testInfo = os.time()
	self.replayMode = ReplayMode.kNone
--	encryptIndex = encryptIndex + 1
--	self.encryptIndex = encryptIndex
	
	self.gameconfig = nil					-- 创建该游戏的选项
	self.posAdd = nil
	self.boardmap = nil;					-- 记录棋盘地形数据的矩阵
	self.backBoardMap = nil
	self.gameItemMap = nil;					-- 记录棋盘物体数据的矩阵
	self.backItemMap = nil

	self.gameActionList = {}
	self.destructionPlanList = {}
	self.stableDestructionPlanList = {}			-- 达到stable之后需要运行的DestructionPlan
	self.destroyActionList = {}
	self.fallingActionList = {}
	self.swapActionList = {}
	self.propActionList = {}
	self.globalCoreActionList = {}
	self.needCheckMatchList = {}		--需要检测三消的坐标列表, 格式 { { r = r1, c = c1 }, { r = r2, c = c2 } }

	self.mapColorList = nil;			--当前地图可选颜色列表
	self.numberOfColors = 3;			--地图方块颜色数量
	self.colortypes = nil;				--颜色集合
	self.dropCrystalStoneColors = nil   --染色宝宝掉落颜色

	self.level = 0;
	self.randomSeed = 0;

	self.swapHelpMap = nil; 			--帮助做交换和Match的辅助Map
	self.swapHelpList = nil;
	self.swapHelpMakePos = nil;

	self.needCheckFalling = true			-- 标志位确定是否需要检查掉落（开关，设置为true后执行掉落消除直至稳定时被设置为false,isFallingStable属性为结果）
	self.isFallingStable = false			-- 标志位，表示当前是否处于掉落稳定状态
	self.isFallingStablePreFrame = false 	-- 标志位，表示上一帧是否处于掉落稳定状态
	self.isRealFallingStable = false 	-- 标志位，表示当前是否处于掉落稳定状态，由于增加了onRealStable方法，只有这个方法执行后，isRealFallingStable才为true

	self.FallingHelpMap = nil;
	self.isBlockChange = false;

	self.EffectHelpMap = nil;			--匹配对格子的影响，数据为棋盘数组，-1表示格子上有消除，0表示不受影响，>0表示周边格子参与匹配的次数
	self.EffectSHelpMap = nil;			--好像没有任何引用？=___=
	self.EffectLightUpHelpMap = nil
	self.EffectChameleonHelpMap = nil 	--影响变色龙的周围消除记录，棋盘数组索引，每格中存入“颜色,类型(区分特效)”字符串组成的数组数据【目前只有格子上有变色龙才会记录】

	self.comboCount = 0;
	self.comboHelpDataSet = nil;		----连击帮助集合
	self.comboHelpList = nil;			----连击帮助列表
	self.comboHelpNumCountList = nil; 	----连击消除小动物数量
	self.comboSumBombScore = nil;		----连击的引爆分数
	self.totalScore = 0;
	self.oringinTotalScore = 0;
	self.coinDestroyNum = 0 			----销毁的银币数量

	self.balloonFrom = 0             ---------气球的剩余步数
	self.addMoveBase = GamePlayConfig_Add_Move_Base                 ---------气球爆炸增加的步数

	self.isWaitingOperation = false		----正在等待用户操作 

	self.isShowAdvise = false;

	self.theGamePlayType = 0;
	self.theGamePlayStatus = 0;			----当前游戏的状态
	self.theCurMoves = 0;				----当前剩余移动量
	self.realCostMove = 0 				----实际使用过的步数
	self.realCostMoveWithoutBackProp = 0
	self.scoreTargets = {1,2,3};

	self.ingredientsTotal = 0;			----需要掉落的豆荚总数
	self.ingredientsCount = 0;

	self.ingredientsProductDropList = {};		----可以掉落豆荚的掉落口列表

	self.kLightUpTotal = 0;
	self.kLightUpLeftCount = 0;			----剩余的冰层数量

	self.isGamePaused = false;			----是否暂停
	self.timeTotalLimit = 0;			----总时间限制
	self.timeTotalUsed = 0;				----总时间消耗
	self.extraTime 		= 0;
	self.flyingAddTime = 0

	self.stageStartTime = 0

	self.theOrderList = {};				----目标列表

	-- 重放代码记录
	self.replaying = false
	self.replaySteps = {}
	self.replayStep = 1
	self.replayWithDropBuff = false

	-- random bonus
	self.randomAnimalHelpList = {}		----最后随机时屏幕中所有可以被随机到的item

	--self.randFactory = HERandomObject:create(); -- rand(l, h) = [l, h]
	self.randFactory = RandomFactory:create("randFactory")
	--self.prePropRandFactory = HERandomObject:create();
	self.prePropRandFactory = RandomFactory:create("preProp")
	self.fallingLogicRandFactory = RandomFactory:create()
	-- local oldRandFunc = self.randFactory.rand
	-- self.randFactory.rand = function(this, s, e)
	-- 	local result = oldRandFunc(this, s, e)
	-- 	if _G.isLocalDevelopMode then printx(0, result, debug.traceback()) end
	-- 	return result
	-- end
	self.PlayUIDelegate = nil;

	-- step stable 相关
	self.hasUseRevertThisRound = false   ----是否在此次操作回合内使用过回退道具,游戏初始化后未操作前需要禁用回退
	self.isInStep = false 				----此次Falling&Match状态是否由swap操作引起，与之对应的是由道具操作引起
	self.isBonusTime = false

	self.isVenomDestroyedInStep = false ----是否在本次操作回合内消除过毒液

	self.isUFOWin = false
	self.UFOCollection = {}           ------ufo 收集的豌豆荚
	self.UFOSleepCD = 0 			-- UFO眩晕回合数
	self.oldUFOSleepCD = 0			-- 该回合开始前UFO晕眩回合数，用于回退一步处理

	self.pm25count = 0        --------pm2.5计数

	self.snailCount = 0
	self.snailMoveCount = 0

	self.setWriteReplayEnable = true     ----------是否可以写replay

	self.honeys = 0        ----------------蜂蜜罐破裂要传染的个数
	self.missileSplit = 0
	self.questionMarkFirstBomb = true
	self.isFirstRefreshComplete = true

	self.replay = nil               ------本关卡需要记录的replay
	self.allReplay = nil            ------所有replay信息

	self.toBeCollected = 0         ----将要被收集的数量

	self.digJewelLeftCount = 999 --步数挖地 当前还需要挖的宝石数量，为0时过关
	self.digJewelTotalCount = 999 --步数挖地 总共需要挖的宝石数量

	self.snailMark = false  -- 标记是否跑蜗牛，刺猬的逻辑，如果为false关卡内就不处理相关逻辑,主要为了减少计算量
	self.bigMonsterMark = true  --标记是否跑雪怪的逻辑，主要为了减少计算量
	self.chestSquareMark = true -- 标记是否跑大宝箱的逻辑，主要为了减少计算量

	self.blockReplayReord = 0

	self.lotusEliminationNum = 0
	self.lotusPrevStepEliminationNum = 0
	self.initLotusNum = 0
	self.currLotusNum = 0
	self.destroyLotusNum = 0

	self.fireworkEnergy = 0
	self.forbidChargeFirework = false 	--不允许给道具大招充能

	self.passFailedCount = false
	self.needUpdateSeaAnimalStaticData = false

	self.leftMoves = 0

	self.actCollectionNum = 0 		--活动收集物数量

	self.blockerCoverMaterialTotalNum = 0
	self.blocker207DestroyNum = 0
	self.lastCreateBuffBoomMoveSteps = 0
	self.pacmanGeneratedByStep = 0		--- 生成的吃豆人数量（通过步数）
	self.pacmanGeneratedByBoardMin = 0	---	生成的吃豆人数量（通过棋盘最少限制）
	self.ghostGeneratedByStep = 0		--- 生成的吃豆人数量（通过步数）
	self.ghostGeneratedByBoardMin = 0	---	生成的吃豆人数量（通过棋盘最少限制）

	self.generatedScoreBuffBottle = 0	-- 已生成的刷星瓶子数
	self.destroyedScoreBuffBottle = 0	-- 已使用的刷星瓶子数（提升检测效率用）
	self.scoreBuffBottleLeftSpecialTypes = nil 	--剩余特效池
	self.scoreBuffBottleInitAmount = nil 	-- 初始数量（断面用 & 回放）
	self.sunflowersAppetite = 0		-- 还需多少份太阳砂
	self.sunflowerEnergy = 0		-- 已经吃掉了多少份太阳
	self.generateFirecrackerTimes = 0	--生成过多少次爆竹
	self.generateFirecrackerTimesForPreBuff = 0
	self.squidOnBoard = nil  		-- 棋盘上的鱿鱼（优化检测效率用）
end


function GameBoardLogic:encryptionFunc( key, value )
--	if __encryptKeys[key] then
	assert(__encryptKeys[key])
		if value == nil then value = 0 end
		HeMemDataHolder:setInteger(self:getEncryptKey(key), value)
--		return true
--	end
--	return false
end

function GameBoardLogic:decryptionFunc( key )
--	if __encryptKeys[key] then
	assert(__encryptKeys[key])
		return HeMemDataHolder:getInteger(self:getEncryptKey(key))
--	end
--	return nil
end

function GameBoardLogic:getEncryptKey(key)
	return key .. "_" .. self.__class_id
end

function GameBoardLogic:dispose()
	GameBoardLogic._currentLogic = nil

	HanleBeforeFallingLogic:setNeedHanle(false)
	TimelyHammerGuideMgr.getInstance():clear()
	self:stopTargetTip()

	if self.theOrderList and #self.theOrderList > 0 then
		for i,v in ipairs(self.theOrderList) do v:dispose() end
		self.theOrderList = nil
	end

	self:stopMoveTileEffect()

	self.pre_prop_pos = nil

	self.isUFOWin = nil
	self.UFOCollection = nil
	self.gameconfig = nil
	self.posAdd = nil
	self.boardmap = nil
	self.gameItemMap = nil
	self.digItemMap = nil
	self.digBoardMap = nil

	self.mapColorList = nil
	self.colortypes = nil
	self.dropCrystalStoneColors = nil

	self.swapHelpMap = nil
	self.swapHelpList = nil
	self.swapHelpMakePos = nil

	self.gameActionList = nil
	self.FallingHelpMap = nil

	self.EffectHelpMap = nil
	self.EffectSHelpMap = nil
	self.EffectLightUpHelpMap = nil
	self.EffectChameleonHelpMap = nil

	self.comboHelpDataSet = nil
	self.comboHelpList = nil
	self.comboHelpNumCountList = nil
	self.comboSumBombScore = nil
	self.pm25 = nil
	self.pm25count = nil
	self.honeys =nil
	self.missileSplit = nil

	self:stopEliminateAdvise()

	self.fsm:dispose()
	self.fsm = nil

	self.replay = nil
	self.allReplay = nil
	self.toBeCollected = nil
	self.snailMark = false

	self.lotusEliminationNum = nil
	self.lotusPrevStepEliminationNum = nil
	self.initLotusNum = nil
	self.currLotusNum = nil
	self.destroyLotusNum = nil
	self.needUpdateSeaAnimalStaticData = nil
	self.snapshotModeEnable = false
	self.getProps = nil
	self.blockerCoverMaterialTotalNum = nil
	self.pacmanGeneratedByStep = nil
	self.pacmanGeneratedByBoardMin = nil
	self.ghostGeneratedByStep = nil
	self.ghostGeneratedByBoardMin = nil
	self.generatedScoreBuffBottle = nil
	self.destroyedScoreBuffBottle = nil
	self.scoreBuffBottleLeftSpecialTypes = nil
	self.scoreBuffBottleInitAmount = nil
	self.sunflowersAppetite = nil
	self.sunflowerEnergy = nil
	self.generateFirecrackerTimes = nil
	self.generateFirecrackerTimesForPreBuff = nil
	self.squidOnBoard = nil

	self.isDisposed = true

	LevelDifficultyAdjustManager:clearAICoreInfo()
	CollectStarsYEMgr.getInstance():setReplayFlag(false)
	ScoreBuffBottleLogic:clearInitAmountForReplay()		--清除刷星回放数据
	--self.initAdjustData = nil --这里如果删除，NewGameSceneUI中的onQuitCallback方法里会取不到，大量的旧逻辑在GameBoardLogic的dispose方法调用之后还在取值
end

function GameBoardLogic:create(replayMode)
	local v = GameBoardLogic.new()
	v.replayMode = replayMode or ReplayMode.kNone
	v:initBoard()

	GameBoardLogic._currentLogic = v
	return v
end

function GameBoardLogic:setProductItemLogicVersion(logicVer)
	self.logicVer = logicVer
end


function GameBoardLogic:getCurrentLogic()
	return GameBoardLogic._currentLogic
end

function GameBoardLogic:getInstance()--老子每次都记不住getCurrentLogic，受不了了！！！
	return self:getCurrentLogic()
end

function GameBoardLogic:initBoard()
	self.boardmap = {}
	self.backBoardMap = {}
	for i= 1,9 do
		self.boardmap[i] = {}
		self.backBoardMap[i] = {}
		for j=1,9 do
			self.boardmap[i][j] = GameBoardData:create();
		end
	end

	self.gameItemMap = {}
	self.backItemMap = {}
	for i=1,9 do
		self.gameItemMap[i] = {}
		self.backItemMap[i] = {}
		for j=1,9 do
			self.gameItemMap[i][j] = GameItemData:create();
		end
	end
  
	self.gameMode = nil

	self.mapColorList = {}
	self.colortypes = {}

	self.FallingHelpMap = {}
	self.EffectHelpMap = {}
	self.EffectChameleonHelpMap = nil

	self.comboCount = 0;
	self.comboHelpDataSet = nil;		----连击帮助集合
	self.comboHelpList = nil;			----连击帮助列表
	self.comboHelpNumCountList = nil; 	----连击消除小动物数量
	self.comboSumBombScore = nil;		----连击的引爆分数
	self.totalScore = 0;
	self.oringinTotalScore = 0;

	self.isWaitingOperation = false;

	self.isShowAdvise = false;

	self.theGamePlayType = 0;
	self.theGamePlayStatus = 0;			----当前游戏的状态
	self.theCurMoves = 0;				----当前剩余移动量
	self.scoreTargets = {1,2,3};

	self.ingredientsTotal = 0;			----需要掉落的豆荚总数
	self.ingredientsCount = 0;

	self.ingredientsProductDropList = {};		----可以掉落豆荚的掉落口列表

	self.kLightUpTotal = 0;
	self.kLightUpLeftCount = 0;			----剩余的冰层数量

	self.isGamePaused = false;			----是否暂停
	self.timeTotalLimit = 0;			----总时间限制
	self.extraTime = 0;					----获得的总额外时间
	self.timeTotalUsed = 0;				----总时间消耗

	self.theOrderList = {};				----目标列表
	self.hasDropDownUFO = false         -----ufo

	self.lotusEliminationNum = 0
	self.lotusPrevStepEliminationNum = 0
	self.initLotusNum = 0
	self.currLotusNum = 0
	self.destroyLotusNum = 0

	self.fsm = StateMachine:create(self)

	self.getProps = {}                    ---- 本关获得的道具

	self.blockerCoverMaterialTotalNum = 0
	self.pacmanGeneratedByStep = 0
	self.pacmanGeneratedByBoardMin = 0
	self.ghostGeneratedByStep = 0
	self.ghostGeneratedByBoardMin = 0
	self.generatedScoreBuffBottle = 0
	self.destroyedScoreBuffBottle = 0
	self.scoreBuffBottleLeftSpecialTypes = nil
	self.scoreBuffBottleInitAmount = nil
	self.sunflowersAppetite = 0
	self.sunflowerEnergy = 0
	self.generateFirecrackerTimes = 0
	self.generateFirecrackerTimesForPreBuff = 0
	self.squidOnBoard = nil

	-- CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()

	self.initAdjustData = nil


	if ResumeGamePlayPopoutActionCheckFlag == "checked" then
		ResumeGamePlayPopoutActionCheckFlag = "done"
	elseif ResumeGamePlayPopoutActionCheckFlag == "done" then
		return
	else
		if not _G.isLocalDevelopMode then
			he_log_error("ResumeGamePlayPopoutAction has passed !!! V3")
		end
		ResumeGamePlayPopoutActionCheckFlag = "done"
	end
end

----游戏逻辑更新循环
local _GARBAGE_MAP = {}
function GameBoardLogic:updateGame(dt)
	self.fsm:update(dt)
	self.gameMode:update(dt)

if(false) then
	local newMap = {}
	_GARBAGE_MAP[#_GARBAGE_MAP + 1] = newMap
	for i = 1, 1000 do
		newMap[i] = {1,2,3,4,5,6,7,8,9,0}
	end
end

end


-----------------------------------------------------------------------
--actived item type checking list
_G._ENABLE_UPDATE_FIELD_LOGIC_POSSIBILITY = false
--似乎是用来判断某些state是否可以跳过的
_FIELD_LOGIC_ID = {}
--check with itemType directly
_FIELD_LOGIC_ID[GameItemType.kBlocker199] = "GameItemType.kBlocker199"
_FIELD_LOGIC_ID[GameItemType.kMagicLamp] = "GameItemType.kMagicLamp"
_FIELD_LOGIC_ID[GameItemType.kDrip] = "GameItemType.kDrip"
_FIELD_LOGIC_ID[GameItemType.kBoss] = "GameItemType.kBoss"
_FIELD_LOGIC_ID[GameItemType.kWeeklyBoss] = "GameItemType.kWeeklyBoss"
_FIELD_LOGIC_ID[GameItemType.kWukong] = "GameItemType.kWukong"
_FIELD_LOGIC_ID[GameItemType.kMissile] = "GameItemType.kMissile"
_FIELD_LOGIC_ID[GameItemType.kBalloon] = "GameItemType.kBalloon"
_FIELD_LOGIC_ID[GameItemType.kCrystal] = "GameItemType.kCrystal"
_FIELD_LOGIC_ID[GameItemType.kKindMimosa] = "GameItemType.kKindMimosa"
_FIELD_LOGIC_ID[GameItemType.kMimosa] = "GameItemType.kMimosa"
_FIELD_LOGIC_ID[GameItemType.kBlackCuteBall] = "GameItemType.kBlackCuteBall"
_FIELD_LOGIC_ID[GameItemType.kOlympicBlocker] = "GameItemType.kOlympicBlocker"
_FIELD_LOGIC_ID[GameItemType.kRoost] = "GameItemType.kRoost"
_FIELD_LOGIC_ID[GameItemType.kBlocker211] = "GameItemType.kBlocker211"
_FIELD_LOGIC_ID[GameItemType.kSunflower] = "GameItemType.kSunflower"
_FIELD_LOGIC_ID[GameItemType.kSquid] = "GameItemType.kSquid"
_FIELD_LOGIC_ID[GameItemType.kWanSheng] = "GameItemType.kWanSheng"

--
--check with board data
_FIELD_LOGIC_ID.colorFilter = "colorFilter"
_FIELD_LOGIC_ID.magicTile = "magicTile"
_FIELD_LOGIC_ID.transmission = "transmission"
_FIELD_LOGIC_ID.sand = "sand"
_FIELD_LOGIC_ID.superCute = "superCute"
_FIELD_LOGIC_ID.blockerCover = "blockerCover"
_FIELD_LOGIC_ID.lotus = "lotus"
_FIELD_LOGIC_ID.rotationTileBlock = "rotationTileBlock"
_FIELD_LOGIC_ID.moveTile = "moveTile"
--
--other
_FIELD_LOGIC_ID.honeyBottle = "honeyBottle"
_FIELD_LOGIC_ID.dig = "dig"
_FIELD_LOGIC_ID.GameItemFurballType_kBrown = "GameItemFurballType.kBrown"
_FIELD_LOGIC_ID.GameItemFurballType_kGrey = "GameItemFurballType.kGrey"
_FIELD_LOGIC_ID.pacmanGenerate = "pacmanGenerate"
_FIELD_LOGIC_ID.pacmanEat = "pacmanEat"
_FIELD_LOGIC_ID.pacmanBlow = "pacmanBlow"
_FIELD_LOGIC_ID.ghostMove = "ghostMove"
_FIELD_LOGIC_ID.ghostAppear = "ghostAppear"
_FIELD_LOGIC_ID.squidRun = "squidRun"
_FIELD_LOGIC_ID.wanSheng = "wanSheng"


function GameBoardLogic:updateFieldLogicPossibility_activeAll()
	if(not self._fieldLogicPossibility)then
		self._fieldLogicPossibility = {}
		for k, v in pairs(_FIELD_LOGIC_ID) do
			self._fieldLogicPossibility[v] = 1
		end
	end
end

function GameBoardLogic:updateFieldLogicPossibility()

	self._fieldLogicPossibility = {}

	local gameItemMap = self.gameItemMap
    local gameBoardMap = self.boardmap

	local m = #gameItemMap
	for r = 1, m do
		local gameItemMapR = gameItemMap[r]
		local gameBoardMapR = gameBoardMap[r]

		local n = #gameItemMapR
		for c = 1, n do
			local item = gameItemMapR[c]
			local boardData = gameBoardMapR[c] 

			if item then
				local ItemType = item.ItemType

				local fieldID = _FIELD_LOGIC_ID[ItemType]
				if(fieldID) then
					self._fieldLogicPossibility[fieldID] = 1
				end

				if(item.honeyBottleLevel > 3) then
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.honeyBottle] = 1
				end
				if(item.digGroundLevel > 3 or item.digJewelLevel > 0) then
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.dig] = 1
				end
				if(item.furballType == GameItemFurballType.kBrown) then
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.GameItemFurballType_kBrown] = 1
				end
				if(item.furballType == GameItemFurballType.kGrey) then
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.GameItemFurballType_kGrey] = 1
				end
				if self._fieldLogicPossibility[_FIELD_LOGIC_ID.pacmanGenerate] ~= 1 
					and ItemType == GameItemType.kPacmansDen 
					and item:isVisibleAndFree() then
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.pacmanGenerate] = 1
				end
				if self._fieldLogicPossibility[_FIELD_LOGIC_ID.pacmanEat] ~= 1 
					and PacmanLogic:isReadyToEatPacman(self, item) then
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.pacmanEat] = 1
				end
				if self._fieldLogicPossibility[_FIELD_LOGIC_ID.pacmanBlow] ~= 1 
					and PacmanLogic:isReadyToBlowPacman(self, item) then
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.pacmanBlow] = 1
				end
				if self._fieldLogicPossibility[_FIELD_LOGIC_ID.ghostMove] ~= 1 
					and GhostLogic:isReadyToFlyGhost(self, item) or GhostLogic:isReadyToCollectGhost(self, item) then
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.ghostMove] = 1
				end
				if self._fieldLogicPossibility[_FIELD_LOGIC_ID.squidRun] ~= 1 
					and SquidLogic:isReadyToRunSquid(self, item) then
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.squidRun] = 1
				end
			end

			if boardData then
				if(boardData.colorFilterState ~= ColorFilterState.kStateNone) then 
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.colorFilter] = 1
				end
				if(boardData.isMagicTileAnchor) then 
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.magicTile] = 1
				end
				if(boardData.transType > 0) then 
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.transmission] = 1
				end
				if(boardData.sandLevel > 0) then 
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.sand] = 1
				end
				if(boardData.superCuteState == GameItemSuperCuteBallState.kInactive) then 
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.superCute] = 1
				end
				if(boardData.blockerCoverMaterialLevel == -1) then 
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.blockerCover] = 1
				end
				if(boardData.lotusLevel > 0) then 
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.lotus] = 1
				end
				if(boardData:isRotationTileBlock()) then 
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.rotationTileBlock] = 1
				end
				if(boardData.isMoveTile) then 
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.moveTile] = 1
				end
				if boardData.isGhostAppear then 
					self._fieldLogicPossibility[_FIELD_LOGIC_ID.ghostAppear] = 1
				end

			end

		end
	end

	if(_G.isLocalDevelopMode)then
		printx(0, "<< updateFieldLogicPossibility >>")
		for k,v in pairs(self._fieldLogicPossibility) do  
			printx(0, k .. ": is actived")
		end  		
		printx(0, "<< updateFieldLogicPossibility done >>")
	end

end

function GameBoardLogic:updateGlobalCoreAction(dt)

	if self.theGamePlayStatus == GamePlayStatus.kAferBonus 
		or self.theGamePlayStatus == GamePlayStatus.kWin 
		or self.theGamePlayStatus == GamePlayStatus.kFailed 
		then
		return
	end

	self.hasGlobalCoreAction = GlobalCoreActionLogic:update(self)
end

--local asynchronous = require("hecore.asynchronous"):new(9999)
--local st1, st2, st3, st4
function GameBoardLogic:fallingMatchUpdate(dt)
	-- printx(11 , "GameBoardLogic:fallingMatchUpdate  111  isFallingStable:["..tostring(self.isFallingStable).."]  isFallingStablePreFrame:["..tostring(self.isFallingStablePreFrame).."]  NEED CHECK:["..tostring(self.needCheckFalling).."]  dt:", dt)
	GameBoardActionRunner:runActionList(self, true)					-- 处理动作列表中的动作
	if self.needCheckFalling then	
		local st1 = DestructionPlanLogic:update(self)
		ItemHalfStableCheckLogic:checkAllMap(self)
		MatchItemLogic:checkPossibleMatch(self)
		local st2 = DestroyItemLogic:update(self)
		local st5 = HanleBeforeFallingLogic:handle(self)

		local st3 = nil
		if UseNewFallingLogic then
			st3 = NewFallingItemLogic:FallingGameItemCheck(self)
		else
			st3 = FallingItemLogic:FallingGameItemCheck(self)
		end
	
		local st4 = FallingItemExecutorLogic:update(self)
		ItemHalfStableCheckLogic:checkElasticAnimation(self)
		self.isFallingStablePreFrame = false
		self.isRealFallingStable = false
		-- printx(11, "fallingMatchUpdate  st1:"..tostring(st1)..",  st2:"..tostring(st2)..",  st3:"..tostring(st3)..",  st4:"..tostring(st4)..",  st5:"..tostring(st5)..",  hasGlobalCoreAction:"..tostring(self.hasGlobalCoreAction))
		self.isFallingStable = not st1 and not st2 and not st3 and not st4 and not st5 and not self.hasGlobalCoreAction
		-- printx(11, "GameBoardLogic:fallingMatchUpdate  222  isFallingStable:"..tostring(self.isFallingStable))
		HanleBeforeFallingLogic:setNeedHanle(self.isFallingStable)
		self.needCheckFalling = not self.isFallingStable

		if self.needClearBlcoker195Data then
			self:clearBlcoker195Data()
		end

		if(not self.needCheckFalling) then
			if(_G._ENABLE_UPDATE_FIELD_LOGIC_POSSIBILITY)then
				self:updateFieldLogicPossibility()
			else
				self:updateFieldLogicPossibility_activeAll()
			end
		end

	end
	self:tryStableHandle()

	--[[

	asynchronous:startFrame()

	repeat
		local tick = asynchronous:getTick() % 12
		if(tick == 0) then
			GameBoardActionRunner:runActionList(self, true)					-- 处理动作列表中的动作
		elseif(tick == 1) then
			if self.needCheckFalling then	
				st1 = DestructionPlanLogic:update(self)
			end
		elseif(tick == 2) then
			if self.needCheckFalling then	
				ItemHalfStableCheckLogic:checkAllMap(self)
			end
		elseif(tick == 3) then
			if self.needCheckFalling then	
				MatchItemLogic:checkPossibleMatch(self)
			end
		elseif(tick == 4) then
			if self.needCheckFalling then	
				st2 = DestroyItemLogic:update(self)
			end
		elseif(tick == 5) then
			if self.needCheckFalling then	
				HanleBeforeFallingLogic:handle(self)
			end
		elseif(tick == 6) then
			if self.needCheckFalling then	
				st3 = FallingItemLogic:FallingGameItemCheck(self)		
			end
		elseif(tick == 7) then
			if self.needCheckFalling then	
				st4 = FallingItemExecutorLogic:update(self)
			end
		elseif(tick == 8) then
			if self.needCheckFalling then	
				ItemHalfStableCheckLogic:checkElasticAnimation(self)
			end
		elseif(tick == 9) then
			if self.needCheckFalling then	
				self.isFallingStablePreFrame = false
				self.isFallingStable = not st1 and not st2 and not st3 and not st4
				HanleBeforeFallingLogic:setNeedHanle(self.isFallingStable)
				self.needCheckFalling = not self.isFallingStable

				if self.needClearBlcoker195Data then
					self:clearBlcoker195Data()
				end
			end
		elseif(tick == 10) then
			self:tryStableHandle()
		elseif(tick == 11) then
			asynchronous:breakFrame()
		end
	until(not asynchronous:updateFrame())
]]


--[[
	if self.needCheckFalling then	
		local st1 = DestructionPlanLogic:update(self)
		ItemHalfStableCheckLogic:checkAllMap(self)
		MatchItemLogic:checkPossibleMatch(self)
		local st2 = DestroyItemLogic:update(self)
		local st3 = FallingItemLogic:FallingGameItemCheck(self)		
		local st4 = FallingItemExecutorLogic:update(self)
		ItemHalfStableCheckLogic:checkElasticAnimation(self)
		
		if false then
			-- if _G.isLocalDevelopMode then printx(0, "-------------------------------------------") end
			-- printx( 1 , "   " ,  st1 ,  st2 ,  st3 ,  st4 , self.needCheckFalling)
			self:testEmpty()
			--debug.debug()
		end

		self.isFallingStablePreFrame = false
		self.isFallingStable = not st1 and not st2 and not st3 and not st4
		self.needCheckFalling = not self.isFallingStable

		if self.needClearBlcoker195Data then
			self:clearBlcoker195Data()
		end
	end
	self:tryStableHandle()
]]

end

-----------------------------
--重置被特效打中的map
-----------------------------
function GameBoardLogic:resetSpecialEffectList(actid)
	for r = 1, #self.gameItemMap do 
		for c = 1, #self.gameItemMap[r] do 
			local item = self.gameItemMap[r][c]
			if item.specialEffectList then 
				item.specialEffectList[actid] = nil 
			end
		end
	end
end

function GameBoardLogic:getTotalLimitTime()
	local extraTime = self.extraTime or 0
	return self.timeTotalLimit + extraTime
end

function GameBoardLogic:addExtraTime(extraTime)
	self.extraTime = self.extraTime or 0
	self.extraTime = self.extraTime + extraTime
end

function GameBoardLogic:numDestrunctionPlan()
	local count = 0
	for k, v in pairs(self.destructionPlanList) do
		count = count + 1
	end
	return count
end

function GameBoardLogic:getStableDestructionPlanListCount()
	if self.stableDestructionPlanList == nil then
		self.stableDestructionPlanList = {}
	end
	local n = 0
	for k,v in pairs(self.stableDestructionPlanList) do
		n = n + 1
	end
	return n
end

-------------------- ！ CAUTION  ! ---------------------
--	使用这个方法的诸位请注意，
--	由于种种不可知的原因，棋盘稳定时此方法也可能返回false
--	使用此方法时请多加注意。
--	
--	目前，在一个action中调用此方法的处理方式如下：
--	从需要用此方法判断微稳定的位置，将该action分隔。
--	后半段创建为一个新的action，放入stableDestructionPlanList。
--	在boardStableHandler()中，刷新棋盘item状态后（isItemAllStable()恢复有效），再处理stableDestructionPlanList中的后半段逻辑。
--------------------------------------------------------
function GameBoardLogic:isItemAllStable( passPosMap )
	if not passPosMap then passPosMap = {} end
	for r = 1, #self.gameItemMap do
		for c = 1, #self.gameItemMap[r] do
			local tempItem = self.gameItemMap[r][c]
			if not passPosMap[tostring(r) .. "_" .. tostring(c)] and tempItem and tempItem.isUsed and not tempItem.isEmpty 
				and tempItem.ItemType ~= GameItemType.kNone 
				and tempItem.ItemStatus ~= GameItemStatusType.kNone then

				return false
			end
		end
	end
	return true
end

function GameBoardLogic:tryStableHandle()
	-- printx(11 , "GameBoardLogic:tryStableHandle   " , self.isFallingStable , self.isFallingStablePreFrame)
	if self.isFallingStable and not self.isFallingStablePreFrame then
		self.isFallingStablePreFrame = true
		-- printx(11 , "   ----------------------------- tryStableHandle  self.totalScore = " , self.totalScore)
		if self.waitForElasticAnimation then
			self.waitForElasticAnimation = false
			----[[
			local scheduleId
			local function waitForElasticAnimationCallback( dt )
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleId)
				self:boardStableHandler()
			end
			scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(waitForElasticAnimationCallback,0.2,false);
			--]]
			
			--self:boardStableHandler()
		else
			self:boardStableHandler()
		end
		
	end
	self:testEmpty()
end

function GameBoardLogic:boardStableHandler()
	if self.isDisposed then return end
	-- printx(11 , "   ----------------------------- Stable  self.totalScore = " , self.totalScore)
	local gameItemMap = self.gameItemMap
	if gameItemMap then
		local m = #gameItemMap
		for r = 1, m do
			local gameItemMapR = gameItemMap[r]

			local n = #gameItemMapR
			for c = 1, n do
				local item = gameItemMapR[c]
				if item and item.ItemStatus == GameItemStatusType.kIsFalling then
					item:AddItemStatus( GameItemStatusType.kNone , true )
				end
			end
		end
	end
	-- printx(11, " + + + + + + + + + + + Item status refreshed at micro-stable status + + + + + + + + + + +")
	
	if self:getStableDestructionPlanListCount() > 0 then
		-- printx(11, " Has stable DestructionPlan ! ! ! ! !")
		for _, v in pairs(self.stableDestructionPlanList) do
			self:addDestructionPlanAction(v)
		end
		self.stableDestructionPlanList = {}
		self:setNeedCheckFalling()
		-- printx(11, "destructionPlanList:", table.tostringByKeyOrder(self.destructionPlanList))
	else
		-- printx(11, "---------- ENTER REAL STABLE ---------")
		self:onRealStable()
	end
end

function GameBoardLogic:onRealStable()
	ReplayDataManager:takeSnapshotForAntiCheating( self , "STB" )
	self.isRealFallingStable = true
	
	if self.snapshotModeEnable then
		self.lastSSModePauseType = "STB"
		self:pauseBySnapshotMode()
	else
		self.fsm:boardStableHandler()
	end
end

function GameBoardLogic:clearBlcoker195Data()
	if self.blocker195Jsq == nil then--间隔一帧再清理数据
		self.blocker195Jsq = 1
		return
	end
	if self.gameItemMap then
		for r = 1, #self.gameItemMap do
			for c = 1, #self.gameItemMap[r] do
				local item = self.gameItemMap[r][c]
				if item and item.isBlocker195Lock then
					item.isBlocker195Lock = nil
				end
			end
		end
		self.needClearBlcoker195Data = nil
		self.blocker195Jsq = nil 
	end
end

function GameBoardLogic:pauseBySnapshotMode()

	printx( 1 , "  ======================== GameBoardLogic:pauseBySnapshotMode ========================")
	printx( 1 , "  snapshotId = " , self.snapshotId)
	CheckPlay:checkSnapshotDiff( self.snapshotId )
	printx( 1 , "  ======================== ================================= ========================")
	self.snapshotId = self.snapshotId + 1
end

function GameBoardLogic:onAfterRefreshStableAndEndGame()
	--printx( 1 , "GameBoardLogic:onAfterRefreshStableAndEndGame --------------------" )

	self.fsm:afterRefreshStable(false)
	self:setGamePlayStatus(GamePlayStatus.kEnd)
	self.isAdviseBannedThisRound = true

	GameGuideData:sharedInstance():setGameStable(false)

	SectionResumeManager:addSection()
	SectionResumeManager:setNextSectionInfo( SectionData:create( SectionType.kSwapAndTryEndGame ) )

	ReplayDataManager:updateCurrSectionDataToReplay()
end

function GameBoardLogic:onAfterRefreshStable()
	--printx( 1 , "GameBoardLogic:onAfterRefreshStable --------------------" )

	local function onCallback()
		self.fsm:afterRefreshStable(true)
	end
	if self.realCostMove == 0 and GameInitBuffLogic:doUseRemindPreProps(onCallback) then
		self.fsm:afterRefreshStable(false)
	else
		self.fsm:afterRefreshStable(true)
	end

	if self.PlayUIDelegate --[[and self.isInStep]] then
		self.isAdviseBannedThisRound = false
		self.isAdviseBannedThisRound = self.isAdviseBannedThisRound or self.PlayUIDelegate:onGameStable()
	end
end

function GameBoardLogic:onSnapshotModeContinue()
	printx( 1 , "   GameBoardLogic:onSnapshotModeContinue")

	if self.lastSSModePauseType == "ARE" then
		self:onAfterRefreshStableAndEndGame()
	elseif self.lastSSModePauseType == "ARW" then
		self:onAfterRefreshStable()
	else
		self.fsm:boardStableHandler()
	end
end

function GameBoardLogic:markVenomDestroyedInStep()
	self.isVenomDestroyedInStep = true
end

function GameBoardLogic:refreshComplete()
	--printx( 1 , "   ----------------------------- refreshComplete  ")
	if self.hasDestroyGift then
		if self.PlayUIDelegate then
			self.isAdviseBannedThisRound = self.PlayUIDelegate:onGetItem("gift")
		end
	end

	if self.PlayUIDelegate and self.gameMode:is(MaydayEndlessMode) and self.theCurMoves > 0 then
		if self.firstProduceQuestionMark then
			self.PlayUIDelegate:tryFirstQuestionMark(self)
		end
		if self.isFullFirework then
			-- if self.theCurMoves == 1 then
			--self.PlayUIDelegate:onShowFullFireworkTip()
			self.PlayUIDelegate:onFullFirework()
		end
	end

	if self.PlayUIDelegate and self.gameMode:is(MoleWeeklyRaceMode) and self.theCurMoves > 0 then
		if self.firstBossDie == true and not self.moleBossData then
			GameGuide:sharedInstance():onHalloweenBossDie()
		end

        if self.isFullFirework then
            local bGuideIsComplete = GameGuideData:sharedInstance():containInGuidedIndex(310000006)
            if bGuideIsComplete then

                  --关闭飞出来的动画
--                if not GameGuideData:sharedInstance():getRunningGuide() then
--                    local delay = 1
--			        local springItem = self.PlayUIDelegate.propList:findSpringItem()
--	    	        springItem:playFlyNutAnim(delay)
--                    springItem.animPlayed = true
--                end
            end
		end
	end

	if self.isFirstRefreshComplete then 
		self.isFirstRefreshComplete = false
	elseif self.PlayUIDelegate and self.theGamePlayType == GameModeTypeId.TASK_UNLOCK_DROP_DOWN_ID then 
		-- debug.debug()
		self.PlayUIDelegate:playSquirrelMoveAnimation()
	end

	if self.levelType == GameLevelType.kSpring2017 and self.gameMode:is(SpringHorizontalEndlessMode) then
		if self.gameMode.onAfterRefreshStable then
			self.gameMode:onAfterRefreshStable()
		end
	end

	ScoreCountLogic:endCombo(self)

	if self.theGamePlayStatus == GamePlayStatus.kNormal then
		if self.gameMode.refreshFailedDirectSuccess == true or self.gameMode:reachEndCondition() then
			--printx( 1 , "   ----------------------------- refreshComplete  reachEndCondition !!!!")
			ReplayDataManager:takeSnapshotForAntiCheating( self , "ARE" )
			if self.snapshotModeEnable then
				self.lastSSModePauseType = "ARE"
				self:pauseBySnapshotMode()
			else
				self:onAfterRefreshStableAndEndGame()
			end
		else
			--printx( 1 , "   ----------------------------- refreshComplete  toWaiting !!!!")
			ReplayDataManager:takeSnapshotForAntiCheating( self , "ARW" )
			if self.snapshotModeEnable then
				self.lastSSModePauseType = "ARW"
				self:pauseBySnapshotMode()
			else
				self:onAfterRefreshStable()
			end
		end
	else
		self.fsm:afterRefreshStable(false)
	end
	
	self.isInStep = false
end

function GameBoardLogic:getIcePosList()
	local posList = {}
	local boardmap = self.boardmap or {}
    for r = 1, #boardmap do 
        for c = 1, #boardmap[r] do 
            local item = boardmap[r][c]
            if item and item.iceLevel > 0 then
            	local pos = self:getGameItemPosInView(r,c)
            	table.insert(posList, pos)
           	end
        end
    end

    return posList
end

function GameBoardLogic:getSnowPosList()
	local posList = {}
	for r = 1, #self.gameItemMap do
		for c  = 1, #self.gameItemMap[r] do 
			local item = self.gameItemMap[r][c]
			if item and item.snowLevel==1 then
            	local pos = self:getGameItemPosInView(r,c)
            	table.insert(posList, pos)
           	end
        end
    end

    return posList
end

function GameBoardLogic:getHoneyPosList()
	local posList = {}
	for r = 1, #self.gameItemMap do
		for c  = 1, #self.gameItemMap[r] do 
			local item = self.gameItemMap[r][c]
			if item and (item.honeyLevel>0) then
            	local pos = self:getGameItemPosInView(r,c)
            	table.insert(posList, pos)
           	end
        end
    end

    return posList
end

function GameBoardLogic:clearTargetTip()
	if self.targetTipIcons then
		for i,v in ipairs(self.targetTipIcons) do
			v:removeFromParentAndCleanup(true)
		end
	end
	self.targetTipIcons = {}
end

-- otherElementsLayer和GameBoardView在不同的子树上面
-- 直接计算effectSprite应该施加的scale比较困难
-- 通过计算boardView上面70个像素在world坐标上的宽度
-- 得到这个scale
function GameBoardLogic:getSingleGridWidth(parentLayer)
	local x1InWorld, x2InWorld = 
		parentLayer:convertToNodeSpace(self:getGameItemPosInView(1, 1)), 
		parentLayer:convertToNodeSpace(self:getGameItemPosInView(1, 2))
	return math.abs(x2InWorld.x - x1InWorld.x)
end

function GameBoardLogic:startTargetTip()
	--if _G.isLocalDevelopMode then printx(0, "ice count: ", self.kLightUpLeftCount) end
	if self.targetTipScheduleId then
		return
	end

	if self.timeOutID then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.timeOutID)
		self.timeOutID = nil
	end

	local function playTargetTip(posList, adjustColor)
		local width = self:getSingleGridWidth(self.PlayUIDelegate.otherElementsLayer)
		for i,v in ipairs(posList) do	
			local effectSprite 
			if adjustColor then 
				effectSprite = SpriteColorAdjust:createWithSpriteFrameName("targetTips_000.png")
				effectSprite:adjustColor(-0.6460, 1.0000, -0.1974, 0.387)
    			effectSprite:applyAdjustColorShader()
			else
				effectSprite = Sprite:createWithSpriteFrameName("targetTips_000.png")
			end
			local frames = SpriteUtil:buildFrames("targetTips_%03d.png", 0, 20)
			local animate = SpriteUtil:buildAnimate(frames, 1/40)
			effectSprite:play(animate, 0.1, 1, nil, true)
			effectSprite:setPosition(ccp(v.x, v.y))
			effectSprite:setScale(width/effectSprite:getContentSize().width)

			self.PlayUIDelegate.otherElementsLayer:addChild(effectSprite)
			table.insert(self.targetTipIcons, effectSprite)
		end
	end

	local function checkSnowTarget()
		local snowNumber = 0
		local honeyNumber = 0
		local snowTargetExist = false
		local honeyExist = false
		if self.theOrderList then
			for index,orderData in ipairs(self.theOrderList) do
				if orderData.key1 == GameItemOrderType.kSpecialTarget and orderData.key2 == GameItemOrderType_ST.kSnowFlower then
					snowNumber = orderData.v1 - orderData.f1
					if snowNumber > 0 then 
						snowTargetExist = true
					else
						snowTargetExist = false
					end
					--if _G.isLocalDevelopMode then printx(0, "left snowNumber: ", snowNumber) end
				end

				if orderData.key1 == GameItemOrderType.kOthers and orderData.key2 == GameItemOrderType_Others.kHoney then
					honeyNumber = orderData.v1 - orderData.f1
					if honeyNumber > 0  then 
						honeyTargetExist = true
					else
						honeyTargetExist = false
					end
					--if _G.isLocalDevelopMode then printx(0, "left honeyNumber: ", honeyNumber) end
				end
			end
		end

		local totalTargetNumber = snowNumber+honeyNumber
		return totalTargetNumber>0 and totalTargetNumber<=3, snowTargetExist, honeyTargetExist
	end

	function showTargetTip()
		self:clearTargetTip()
		--ice level
		if self.theGamePlayType == GameModeTypeId.LIGHT_UP_ID then--and self.kLightUpLeftCount<=80 then
			local icePosList = self:getIcePosList()
			if #icePosList <= 3 then
				--if _G.isLocalDevelopMode then printx(0, "@@@@@@@@start to show ice tip!!!!!") end
				playTargetTip(icePosList)
			end
		end

		--check for snow level
		if self.theGamePlayType == GameModeTypeId.ORDER_ID then
			local checkEnable, snowTargetExist, honeyTargetExist = checkSnowTarget()
			if checkEnable then
				if snowTargetExist then
					local snowPosList = self:getSnowPosList()
					--if _G.isLocalDevelopMode then printx(0, "@@@@@@@@start to show snow tip!!!!!") end
					playTargetTip(snowPosList, true)
				end

				if honeyTargetExist then
					local honeyPosList = self:getHoneyPosList()
					--if _G.isLocalDevelopMode then printx(0, "@@@@@@@@start to show honey tip!!!!!") end
					playTargetTip(honeyPosList)
				end
			end
		end

	end

	local scheduleTargetTip = function ()
		local targetTipScheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(showTargetTip, 5, false)	
		self.targetTipScheduleId = targetTipScheduleId
	end

	self.timeOutID = setTimeOut(function()
			showTargetTip()
			scheduleTargetTip()
		end, 3)
end

function GameBoardLogic:stopTargetTip()
	--if _G.isLocalDevelopMode then printx(0, "----------stop target tip") end
	if self.timeOutID then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.timeOutID)
		self.timeOutID = nil
	end

	if self.targetTipScheduleId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.targetTipScheduleId)
		self:hideTargetTip()
		self.targetTipScheduleId = nil
	end
end

function GameBoardLogic:hideTargetTip()
	--if _G.isLocalDevelopMode then printx(0, "todo: hide target tip!!!!!") end
	self:clearTargetTip()
end

function GameBoardLogic:startMoveTileEffect()
	local function showMoveTileEffect()
		if self.boardmap then
			for i = 1, #self.boardmap do
				for j = 1, #self.boardmap[i] do
					local board = self.boardmap[i][j]
					if board and board.isMoveTile then
						local roteMeta = board.tileMoveMeta:findRouteByPos(i, j, board.tileMoveReverse)
						if roteMeta then
							local itemView = self.boardView.baseMap[i][j]
							itemView:showMoveTileEffect(roteMeta:getDirection(board.tileMoveReverse))
						end
					end
				end
			end
		end
	end

	if self.moveTileEffectScheduleId then
		self:stopMoveTileEffect()
	end

	local moveTileEffectScheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(showMoveTileEffect, 10, false)	
	self.moveTileEffectScheduleId = moveTileEffectScheduleId
end

function GameBoardLogic:stopMoveTileEffect()
	if self.moveTileEffectScheduleId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.moveTileEffectScheduleId)
		self.moveTileEffectScheduleId = nil
		if self.boardmap then
			for i = 1, #self.boardmap do
				for j = 1, #self.boardmap[i] do
					local board = self.boardmap[i][j]
					if board and board.isMoveTile then
						local itemView = self.boardView.baseMap[i][j]
						itemView:hideMoveTileEffect()
					end
				end
			end
		end
	end
end

function GameBoardLogic:startEliminateAdvise()
	--if _G.isLocalDevelopMode then printx(0, "----------start advise") end
	if self.isAdviseBannedThisRound then
		return
	end

	local possibleSwapList = SwapItemLogic:calculatePossibleSwap(self)
	local targetPossibleSwap = possibleSwapList[math.random(#possibleSwapList)]
	self.targetPossibleSwap = targetPossibleSwap

	if not self.targetPossibleSwap then
		local replayData = self:getReplayRecordsData()
		if replayData then
			replayData.sectionData = nil
			replayData.lastSectionData = nil
		end
		assert(false, "startEliminateAdvise exception. replay="..table.serialize(replayData))
	end

	local function showEliminateAdvise(dt)
		if not self.targetPossibleSwap then 
			he_log_error("GameBoardLogic is disposed when showEliminateAdvise")
			return 
		end 
		self:showEliminateAdvise(dt)
	end

	if self.eliminateAdviseScheduleId then
		self:stopEliminateAdvise()
	end

	local eliminateAdviseScheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(showEliminateAdvise, 8.5, false)	
	self.eliminateAdviseScheduleId = eliminateAdviseScheduleId

	local function showSquirrelDoze( ... )
		-- body
		if self.PlayUIDelegate then 
			self.PlayUIDelegate:playSquirrelAnimation()
		end
	end
	local squirrelDozeScheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(showSquirrelDoze, 15, false)
	self.squirrelDozeScheduleId = squirrelDozeScheduleId

	if self.theGamePlayType == GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID then
		local r, c = self.gameMode:findHedgehogRC()
		if self.gameMode:checkIsShowTipToCrazy(r, c) then
			if self.PlayUIDelegate then
				local item = self.boardView.baseMap[r][c].itemSprite[ItemSpriteType.kSnail]
				local pos = item:getPositionInWorldSpace()
				self.PlayUIDelegate:playHandGuideAnimation(pos)
			end
		end
	end
end

function GameBoardLogic:stopEliminateAdvise()
	--if _G.isLocalDevelopMode then printx(0, "----------stop advise") end
	if self.eliminateAdviseScheduleId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.eliminateAdviseScheduleId)
		self:hideEliminateAdvise()
		self.eliminateAdviseScheduleId = nil
	end

	if self.squirrelDozeScheduleId then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.squirrelDozeScheduleId)
		self.squirrelDozeScheduleId = nil
	end

	if self.PlayUIDelegate then
		self.PlayUIDelegate:stopHandGuideAnimation()
	end

end

function GameBoardLogic:showEliminateAdvise(dt)
	local function getMirrorDir(dir)
		local result = { r = dir.r, c = dir.c }
		if dir.r ~= 0 then
			result.r = -result.r
		else
			result.c = -result.c
		end
		return result
	end
	if self.boardView and self.boardView.baseMap then
		for i, v in ipairs(self.targetPossibleSwap) do
			local itemView = self.boardView.baseMap[v.r][v.c]
			local dir = self.targetPossibleSwap["dir"]
			if i ~= 1 then
				dir = getMirrorDir(dir) 
			end
			itemView:showAdviseEffect(dir)
		end
		if not _G.dev_kxxxl then
			GamePlayMusicPlayer:playEffect(GameMusicType.kEliminateTip)
		end
	end
end

function GameBoardLogic:hideEliminateAdvise()
	if self.gameItemMap and self.targetPossibleSwap then
		for i, v in ipairs(self.targetPossibleSwap) do
			local itemView = self.boardView.baseMap[v.r][v.c]
			itemView:stopAdviseEffect()
			itemView:upDatePosBoardDataPos(self.gameItemMap[v.r][v.c], true)
		end
	end
end

function GameBoardLogic:setNeedCheckFalling()
	self.needCheckFalling = true
end

function GameBoardLogic:getBossCount()
	local bossCount = 0
	if self.theGamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID
		or self.theGamePlayType == GameModeTypeId.HALLOWEEN_ID 
		or self.theGamePlayType == GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID
		or self.theGamePlayType == GameModeTypeId.WUKONG_DIG_ENDLESS_ID 
		or self.theGamePlayType == GameModeTypeId.MOLE_WEEKLY_RACE_ID 
		then
		bossCount = self.maydayBossCount
	end
	return bossCount
end

function GameBoardLogic:getTargetCount()
	local targetCount = 0
	if self.theGamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID
		or self.theGamePlayType == GameModeTypeId.HALLOWEEN_ID 
		or self.theGamePlayType == GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID
		or self.theGamePlayType == GameModeTypeId.DIG_MOVE_ENDLESS_ID
		or self.theGamePlayType == GameModeTypeId.WUKONG_DIG_ENDLESS_ID 
		or self.theGamePlayType == GameModeTypeId.MOLE_WEEKLY_RACE_ID 
		then
		targetCount = self.digJewelCount:getValue()
	elseif self.theGamePlayType == GameModeTypeId.RABBIT_WEEKLY_ID then
		targetCount = self.rabbitCount:getValue()
	end

	if self.levelType == GameLevelType.kSpring2017 then
		targetCount = self.gameMode.encryptData.totalCollectChickenNum
	elseif self.levelType == GameLevelType.kFourYears then
		-- 蛋糕
		for _, v in ipairs(self.theOrderList) do
			if v.key1 == 6 and v.key2 == 4 then
				targetCount = v.v1
				break
			end
		end
    elseif self.levelType == GameLevelType.kSummerFish then
		-- 鱼
		for _, v in ipairs(self.theOrderList) do
			if v.key1 == 6 and v.key2 == 4 then
				targetCount = v.v1
				break
			end
		end

	elseif self.levelType == GameLevelType.kOlympicEndless or self.levelType == GameLevelType.kMidAutumn2018 then
		--targetCount = self.olympicScore or 0
		targetCount = self.gameMode.encryptData.currIceNum or 0
	elseif self.levelType == GameLevelType.kYuanxiao2017 then
		-- 铃铛数量
		for index,orderData in ipairs(self.theOrderList) do
			if orderData.key1 == GameItemOrderType.kSpecialTarget 
				and orderData.key2 == GameItemOrderType_ST.kCoin then
				
				targetCount = orderData.v1
				break
			end
		end
	elseif self.levelType == GameLevelType.kMoleWeekly then
		local finalAmount = MoleWeeklyRaceLogic:getFinalAmountForJewel(self)
		targetCount = finalAmount..","..self.yellowDiamondCount:getValue()
	end

	return targetCount
end

function GameBoardLogic:setGamePlayStatus(state)
	-- printx( 1 , "  ---------------------------   GameBoardLogic:setGamePlayStatus " , self.theGamePlayStatus , state , debug.traceback() , "\n")
	if (state ~= self.theGamePlayStatus) then
		if state == GamePlayStatus.kEnd then
			if self.PlayUIDelegate then
				self.PlayUIDelegate:setPauseBtnEnable(false)
			end
			if self.gameMode:reachTarget() then
				self.leftMoveToWin = self.theCurMoves
				ProductItemDiffChangeLogic:endLevel()
				GameInitDiffChangeLogic:endLevel()
				GameInitBuffLogic:endLevel()
				SnapshotManager:updateMoves( self )
				if self.theGamePlayType == GameModeTypeId.TASK_UNLOCK_DROP_DOWN_ID then
					self:setGamePlayStatus(GamePlayStatus.kAferBonus)
				else
					self:setGamePlayStatus(GamePlayStatus.kBonus)
				end
			else
				self.gameMode:afterFail()
			end
		elseif state == GamePlayStatus.kNormal then
			-- left empty
		elseif state == GamePlayStatus.kFailed then
			if _G.AutoCheckLeakInLevel then
				_G.debugWatchingObjects = false
			end

			local targetCount = self:getTargetCount()
			local opLog = nil
			local star = 0
			if self.theGamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID and self.gameMode:getFailReason() == 'refresh' then
				star = self.gameMode:getScoreStarLevel()
			end

			if self.PlayUIDelegate then
				FUUUManager:lastGameIsFUUU(true , true)--注意，下面两行顺序敏感，计算FUUU必须在onGameDefiniteFinish之前
				FUUUManager:onGameDefiniteFinish(false , self)
				MissionModel:getInstance():updateDataOnGameFinish(false , self)
				ReplayDataManager:onPassLevel( ReplayDataEndType.kFailed , self.totalScore)
				self.PlayUIDelegate:failLevel(self.level, self.totalScore, star, math.floor(self.timeTotalUsed), self:getGainCoinNumber(self.level, self.coinDestroyNum), targetCount, opLog, self.gameMode:reachTarget(), self.gameMode:getFailReason())
			end
			ProductItemDiffChangeLogic:endLevel()
			GameInitDiffChangeLogic:endLevel()
			GameInitBuffLogic:endLevel()
		elseif state == GamePlayStatus.kBonus then
			--printx( 1 , "   GamePlayStatus.kBonus ")
			-- if GameSpeedManager:getGameSpeedSwitch() > 0 then
			-- 	self.PlayUIDelegate.gameBoardView:createSpeedupTouchlayerForBonusTime( function () 
			-- 			GameSpeedManager:changeSpeedForCrashResumePlay()
			-- 		end)
			-- end
			TimelyHammerGuideMgr.getInstance():removeGuide(true)
			GameGuide:sharedInstance():onHedgehogCrazyClick(true)
			self.leftMoves = self.theCurMoves
			if self.dropBuffLogic then 
				self.dropBuffLogic:setDropBuffEnable(false)
			end
			if BombItemLogic:getNumSpecialBomb(self) > 0 
				or (self.gameMode:canChangeMoveToStripe() and self.theCurMoves > 0)
				or self.gameMode:is(MaydayEndlessMode)
				or self.gameMode:is(HedgehogDigEndlessMode)
				or self.gameMode:is(WukongMode)
				then
			 	self.comboCount = 0
		 	-- 	if _G.dev_kxxxl then
				-- 	GamePlayMusicPlayer:playEffect(GameMusicType.kXXLBonusTime)
				-- else
				-- 	GamePlayMusicPlayer:playEffect(GameMusicType.kBonusTime)
				-- end
				if self.PlayUIDelegate and self.PlayUIDelegate.effectLayer and not self.PlayUIDelegate.effectLayer.isDisposed then
					self.PlayUIDelegate.effectLayer:removeChildren(true)
				end
				-- if self.PlayUIDelegate and self.PlayUIDelegate.topEffectLayer and not self.PlayUIDelegate.topEffectLayer.isDisposed then
				-- 	self.PlayUIDelegate.topEffectLayer:removeChildren(true)
				-- 	self.PlayUIDelegate.topEffectLayer:addChild(CommonEffect:buildBonusEffect())
				-- end

				self.isBonusTime = true
				self.fsm:changeState(self.fsm.fallingMatchState)
				-- printx( 1 , "   ----------------------------- Stable  self.totalScore = " , self.totalScore , "  at kBonus")
				self.fsm:boardStableHandler()
			else
				local function endGame()
					self:setGamePlayStatus(GamePlayStatus.kAferBonus)
				end
				setTimeOut(endGame, 1)
			end
			self:addReplayReordPreviewBlock()
		elseif state == GamePlayStatus.kWin then
			-- if GameSpeedManager:getGameSpeedSwitch() > 0 then
			-- 	self.PlayUIDelegate.gameBoardView:removeSpeedupTouchlayerForBonusTime()
			-- end
			if _G.AutoCheckLeakInLevel then
				_G.debugWatchingObjects = false
			end
			if self.replaying then
				self.replaying = false
				if self.PlayUIDelegate and type(self.PlayUIDelegate.onReplayEnd) == "function" then
					self.PlayUIDelegate:onReplayEnd()

					local udid = MetaInfo:getInstance():getUdid() or "hasNoUdid"
					DcUtil:crashResumeEnd( 201 , self.PlayUIDelegate.levelId , self.replayStep - 1 , 
						UserManager.getInstance().user.uid , udid , self.PlayUIDelegate.replayData.uid , self.PlayUIDelegate.replayData.udid , self.PlayUIDelegate.replayDataMD5 )--恢复正常结束
				end
			end

			local targetCount = self:getTargetCount()
			local bossCount = self:getBossCount()

			local strategyInfo = LevelStrategyManager.getInstance():getStrategyInfo(self.leftMoves, self.gameMode:getScoreStarLevel())
			ReplayDataManager:setStrategyInfo(strategyInfo)

			FUUUManager:onGameDefiniteFinish(true , self)
			MissionModel:getInstance():updateDataOnGameFinish(true , self)
			ReplayDataManager:onPassLevel( ReplayDataEndType.kWin , self.totalScore)

			local replayData = self:getReplayRecordsData()
			-----------------sectionData先不要存到本地的大文件----------------
			if replayData then
				replayData.sectionData = nil
				replayData.lastSectionData = nil
			end
			------------------------------------------------------------------
			-- local opLog = table.serialize(replayData) 
			local opLog = replayData 

			if self.PlayUIDelegate then
				self.PlayUIDelegate:passLevel(self.level, self.totalScore, self.gameMode:getScoreStarLevel(), math.floor(self.timeTotalUsed), self:getGainCoinNumber(self.level, self.coinDestroyNum), targetCount, opLog, bossCount, self.activityForceShareData)			
			end
			if self.theGamePlayType ~= GameModeTypeId.DIG_TIME_ID and 
				self.theGamePlayType ~= GameModeTypeId.CLASSIC_ID and 
				self.theGamePlayType ~= GameModeTypeId.CLASSIC_MOVES_ID and
				self.theGamePlayType ~= GameModeTypeId.DIG_MOVE_ENDLESS_ID and
				self.theGamePlayType ~= GameModeTypeId.RABBIT_WEEKLY_ID and 
				self.theGamePlayType ~= GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID and 
				self.theGamePlayType ~= GameModeTypeId.SPRING_HORIZONTAL_ENDLESS_ID and 
				self.theGamePlayType ~= GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID then
				
				Notify:dispatch("AchiEventDataUpdate", AchiDataType.kLeftStep, self.leftMoveToWin)
			else
				Notify:dispatch("AchiEventDataUpdate", AchiDataType.kLeftStep, 1)
			end
			
			if self.theGamePlayType ~= GameModeTypeId.RABBIT_WEEKLY_ID then 
				--ShareManager:setShareData(ShareManager.ConditionType.PASS_STEP,self.realCostMove)
				--ShareManager:shareWithID( ShareManager.PASS_STEP )
				-- AchievementManager:onDataUpdate( AchievementManager.PASS_STEP, self.realCostMove )
			end
			
		elseif state == GamePlayStatus.kAferBonus then
			--printx( 1 , "   GamePlayStatus.kAferBonus ")
			local function gameResultShow( ... )
				-- body
				if (self.gameMode:getScoreStarLevel() > 0) then
					self:setGamePlayStatus(GamePlayStatus.kWin)
				else
					self:setGamePlayStatus(GamePlayStatus.kFailed)
				end
			end
			if self.theGamePlayType == GameModeTypeId.TASK_UNLOCK_DROP_DOWN_ID then
				self.PlayUIDelegate:playSquirrelGiveKeyAnimation(gameResultShow)
			else
				gameResultShow()
			end
			
		end

		if state ~= GamePlayStatus.kNormal then
			self:stopWaitingOperation()
		end
		self.theGamePlayStatus = state
	end
end

function GameBoardLogic:getGainCoinNumber(levelId, coinNum)
	local coinBlockerMeta = MetaManager.getInstance():getCoinBlockersByLevelId(levelId)
	if coinBlockerMeta and type(coinNum) == "number" then
		if coinNum > coinBlockerMeta.coin_amount then
			return coinBlockerMeta.coin_amount
		else
			return coinNum
		end
	end
	return 0
end

function GameBoardLogic:initByConfig(level, config, levelType, forceUseDropBuff , replayMode , replayData)
	self.originLevelConfig = config
	self.level = level
	self.levelType = levelType
	self.totalScore = 0
	self.oringinTotalScore = 0
	self.pre_prop_pos = {}
	self.useGuideRandomSeed = false
	--RemoteDebug:uploadLog("GameBoardLogic:initByConfig   config.randomSeed:",config.randomSeed)
	self.randomSeed = config.randomSeed
    self.SunmerFish3x3GetNum = config.SunmerFish3x3GetNum or 1

	if self.randomSeed == nil then self.randomSeed = 0 end

	local modeProcessorDatas = {}
	if config.pluginMode then
		if config.pluginMode.pluginSwitchInfo and config.pluginMode.pluginSwitchInfo.m1 then
			modeProcessorDatas.changeGlobalGravityBySwap = true
		end
	end
	self.modeProcessor = LevelModeProcessor:create( self , modeProcessorDatas )
	

	if not replayMode or replayMode == ReplayMode.kNone then
  		self.stageStartTime = Localhost:timeInSec()
		if GuideSeeds[level] then
			self.useGuideRandomSeed = true
		end
  		local aiSeed = LevelDifficultyAdjustManager:getAISeedValue()
  		if aiSeed and aiSeed ~= "null" then
  			if aiSeed > 0 then
  				self.randomSeed = aiSeed
  			elseif aiSeed == -2 then 
  				self.randomSeed = math.random(1, 1000)
  			end
  		end
	elseif replayData then
		self.useGuideRandomSeed = replayData.useGuideRandomSeed
  		self.stageStartTime = replayData.startTime
	end

 	if self.randomSeed ~= 0 then 
 		self.randFactory:randSeed(self.randomSeed)
 		self.prePropRandFactory:randSeed(self.randomSeed)
 	else
 		self.randomSeed = os.time()
 		self.randFactory:randSeed(self.randomSeed)
 		self.prePropRandFactory:randSeed(self.randomSeed)
 	end

 	GamePlayContext:getInstance():doGameInit(self)

 	self.fallingLogicRandFactory:randSeed(self.randomSeed)

	if _G.isLocalDevelopMode then printx(0, "level init id:", level, "randomSeed:", self.randomSeed) end

	self.theGamePlayType = LevelMapManager:getLevelGameModeByName(config.gameMode)

	--气球处理
	if config.balloonFrom then 
		self.balloonFrom = config.balloonFrom
	end

	if config.addMoveBase and config.addMoveBase > 0 then
		self.addMoveBase = tonumber(config.addMoveBase)
		if self.addMoveBase > 9 then
			self.addMoveBase = 9
		end
	end

	if config.addTime then
		self.addTime = tonumber(config.addTime)
		if self.addTime > 9 then
			self.addTime = 9
		end
	end

	self.uncertainCfg1 = config.uncertainCfg1
	self.uncertainCfg2 = config.uncertainCfg2
	self.hedgehogBoxCfg = config.hedgehogBoxCfg

	self.blockerCoverTarNum1 = config.blockerCoverTarNum1 or 0
	self.blockerCoverTarNum2 = config.blockerCoverTarNum2 or 0
	self.blockerCoverTarNum3 = config.blockerCoverTarNum3 or 0
	self.blocker195Nums = config.blocker195Nums
	self.blocker199Cfg = config.blocker199Cfg
	if config.blocker206Cfg then self.blocker206Cfg = table.clone(config.blocker206Cfg) end
	self.pacmanConfig = config.pacmanConfig
	self.ghostConfig = config.ghostConfig

	self.honeys = config.honeys
	self.missileSplit = config.missileSplit
	self.hasDropDownUFO = config.hasDropDownUFO or self.theGamePlayType == GameModeTypeId.RABBIT_WEEKLY_ID
	self.pm25 = config.pm25
	self.sunflowersAppetite = config.sunflowersAppetite

	-- 初始化神奇掉落规则
	self.dropBuffLogic = DropBuffLogic:create(self, config)
	if forceUseDropBuff == true then
		self.dropBuffLogic.canBeTriggered = true
	else
		self.dropBuffLogic.canBeTriggered = self.dropBuffLogic:checkIfCanBeTriggered(level)
	end

	self.guideAtlas = AnimalGuideAtlas:create(config)
	
	ColorFilterLogic:init(self)
	ActCollectionLogic:init(self)
	GameMapInitialLogic:init(self, config)
	FallingItemLogic:preUpdateHelpMap(self)

	self.gameMode = GameModeFactory:create(self)
	self.theCurMoves = config.moveLimit
	self.staticLevelMoves = self.theCurMoves
	if not self.theCurMoves then self.theCurMoves = 0 end
	if __WIN32 or _G.isLocalDevelopMode then
		-- self.theCurMoves = 1
	end
	self.scoreTargets = config.scoreTargets
	self.replaceColorMaxNum = config.replaceColorMaxNum

	self.singleDropCfg = config.singleDropCfg

	--------------------------------------------
	--以下字段是新掉落规则框架下的字段，
	--在ProductItemLogic:init中进行初始化
	self.singleDropConfigGroup = nil         --分组存储的掉落颜色配置
	self.productRuleGroup = nil              --分组存储的掉落规则配置
	self.productRuleConfig = nil             --储存每个掉落口对应的组ID，默认配置存在坐标0_0上
	self.productRuleGlobalConfig = nil       --全局配置的Q和P信息，将覆盖productRuleGroup里的对应字段
	self.cachePoolV2 = nil                   --新版cachePool，分组存储
	---------------------------------------------

	self:addAllItemsForMatchCheck()
	self.needCheckFalling = true
	self.isFallingStable = false
	self.isFallingStablePreFrame = false
	self.timeTotalUsed = 0
	self.theGamePlayStatus = GamePlayStatus.kPreStart
	self.ingredientsCount = 0

	self.gameMode:initModeSpecial(config)
	FUUUManager:update(self.gameMode)

	ProductItemLogic:init( self, config , self.logicVer or 1 )

	self.gamePlayEventTrigger = GamePlayEventTrigger:create()

	if self.replaying then
		self.initialMapData = self:getSaveDataForRevert()
	end

	SectionResumeManager:addSection()
	SectionResumeManager:setNextSectionInfo( SectionData:create( SectionType.kInit ) )

	SnapshotManager:init(self)
	ProductItemDiffChangeLogic:startLevel(self)
	Blocker206Logic:init(self)
	ObstacleFootprintManager:initData(self, config)

	self:generateExtraOrderItem()
end

function GameBoardLogic:generateExtraOrderItem( ... )
	if self.theOrderList then 
		for _, v in ipairs(self.theOrderList) do
			if v.key1 == GameItemOrderType.kOthers and v.key2 == GameItemOrderType_Others.kBiscuit then
				local _, totalMilks = self:getTotalMilksCountAndTarget()
				local milkOrderItem = GameItemOrderData:create(GameItemOrderType.kOthers, GameItemOrderType_Others.kMilks, totalMilks)
				local counts = #self.theOrderList
    			self.theOrderList[counts + 1] = milkOrderItem
			end
		end
		self._hadInvisibleOrderItems = true
	end
end

function GameBoardLogic:getViewableOrderList( ... )
	if self._hadInvisibleOrderItems then
		return table.filter(self.theOrderList, function ( v )
			return not v:isInvisible()
		end)
	else
		return self.theOrderList
	end
end

function GameBoardLogic:getSnailTotalCount( )
	-- body
	local orderlist = self.theOrderList
	for k, v in pairs(orderlist) do 
		if v.key1 ==GameItemOrderType.kSpecialTarget and v.key2 == GameItemOrderType_ST.kSnail then 
			return v.v1
		end
	end
	return 0
end

function GameBoardLogic:getSnailOnScreenCount( ... )
	-- body
	local result = 0
	for r = 1, #self.gameItemMap do
		for c  = 1, #self.gameItemMap[r] do 
			local item = self.gameItemMap[r][c]
			if item and item.isSnail then
				result = result + 1
			end
		end
	end 
	return result
end

function GameBoardLogic:onGameInit()
	GamePlayContext:getInstance():onGameInit( self )
	GamePlayContext:getInstance():setTestInfo( "levelStartProgress" , 
			{info = "levelStartProgress" , levelId = self.level , playId = GamePlayContext:getInstance():getIdStr() , p = 201} , true , testStartLevelInfoFilterUids )

	ReplayDataManager:onStartLevel(self)
	if self.replayMode == ReplayMode.kReview then
		UserReviewLogic:onStartLevel(self)
	end

	--捕捉关卡快照
	local function catchStep()
		SnapshotManager:catchStep(self)
	end 
	xpcall(catchStep, function(err)
    	local message = err
   	 	local traceback = debug.traceback("", 2)
    	if _G.isLocalDevelopMode then printx(-99, message) end
   		if _G.isLocalDevelopMode then printx(-99, traceback) end
   	end)

	if self.levelType == GameLevelType.kSummerWeekly then
		SeasonWeeklyRaceManager.getInstance():onGameInit()
	elseif self.levelType == GameLevelType.kMoleWeekly then
		if not self.replayMode or self.replayMode == ReplayMode.kNone then
			local http = OpNotifyOffline.new()
			http:load(OpNotifyOfflineType.kWeeklyRaceStartLevel) --必须在ReplayDataManager:onStartLevel之后
		end
	end

	if self.replayMode == ReplayMode.kResume and CrashResumeGamePlaySpeedUp then
		self.gameMode:onGameInit()
		if self.PlayUIDelegate and self.PlayUIDelegate.onResumeReplayStart and type(self.PlayUIDelegate.onResumeReplayStart) == "function" then
			self.PlayUIDelegate:onResumeReplayStart()
		end
	elseif self.replayMode == ReplayMode.kStrategy then 
		LevelStrategyLogic:onGameInit(self.PlayUIDelegate, function ()
			self.gameMode:onGameInit()
		end)
	elseif self.replayMode == ReplayMode.kSectionResume then 
		--self.gameMode:onGameInit()

		-- if self.buffsForReplayPassedPlan and #self.buffsForReplayPassedPlan > 0 then
		-- 	GameInitBuffLogic:updateInitBuffPassedPlanListByReplayData( self.buffsForReplayPassedPlan )
		-- end

		self.PlayUIDelegate:playLevelTargetPanelAnim(function () end , true) 

		self:setGamePlayStatus(GamePlayStatus.kNormal)
		--self.fsm:initState()
		--self.fsm:changeState( self.fsm.waitingState )
		

		if self.PlayUIDelegate and self.PlayUIDelegate.onResumeReplayStart and type(self.PlayUIDelegate.onResumeReplayStart) == "function" then
			self.PlayUIDelegate:onResumeReplayStart()
		end

		setTimeOut( function () 

			self.fsm:changeState( self.fsm.waitingState ) 
			self.boardView.isPaused = false

		end , 1) --至少要delay一帧，否则顶部的目标动画创建会有问题
		

		self.gameMode:onStartGame()
	elseif self.replayMode == ReplayMode.kAutoPlayCheck or self.replayMode == ReplayMode.kConsistencyCheck_Step2 then 
		self.gameMode:onGameInit()
		setTimeOut( function () AutoCheckLevelManager:showProgressInfo() end , 1)
	elseif self.replayMode == ReplayMode.kReview then
		self.gameMode:onGameInit()
		if self.PlayUIDelegate and self.PlayUIDelegate.onResumeReplayStart and type(self.PlayUIDelegate.onResumeReplayStart) == "function" then
			self.PlayUIDelegate:onResumeReplayStart()
		end
	else
		self.gameMode:onGameInit()
	end
	GamePlayContext:getInstance():setTestInfo( "levelStartProgress" , 
			{info = "levelStartProgress" , levelId = self.level , playId = GamePlayContext:getInstance():getIdStr() , p = 202} , true , testStartLevelInfoFilterUids )

	if _G.autoShowSectionToolBar then
		require "zoo.panel.SectionResumeToolbar"
		local toolbar = SectionResumeToolbar:create()
		toolbar:popout()
	end
end

function GameBoardLogic:getColorOfGameItem(r, c)--获取动物、水晶、gift、牢笼的颜色
	local color = 0
	if self:isPosValid(r, c) then
		local item = self.gameItemMap[r][c]
		if item:canBeCoverByMatch() then
			color = item._encrypt.ItemColorType
		end
	end
	return color
end

function GameBoardLogic:checkMatchQuick(r,c, color)	--快速检测如果r、c位置是color会怎样
	local x1 = self:getColorOfGameItem(r - 2 , c)
	local x2 = self:getColorOfGameItem(r - 1 , c)
	local x3 = self:getColorOfGameItem(r + 1 , c)
	local x4 = self:getColorOfGameItem(r + 2 , c)

	local y1 = self:getColorOfGameItem(r , c - 2)
	local y2 = self:getColorOfGameItem(r , c - 1)
	local y3 = self:getColorOfGameItem(r , c + 1)
	local y4 = self:getColorOfGameItem(r , c + 2)

	if (color == x2 and x1 == x2)
		or (color == x2 and color == x3)
		or (color == x3 and color == x4)
		or (color == y2 and y1 == y2)
		or (color == y2 and y3 == y2)
		or (color == y3 and y3 == y4)
		then
		return true
	end
	return false
end

----产生一个新的掉落数据
function GameBoardLogic:randomANewItemFallingData(r,c)
	local data = ProductItemLogic:product(self, r, c)

	ObstacleFootprintManager:addAppearOnCannonProduce(data)
	return data
end

function GameBoardLogic:randomColor()
	if self.dropBuffLogic and self.dropBuffLogic.dropBuffEnable then
		return self.dropBuffLogic:randomColor()
	end
	local x = self.randFactory:rand(1,#self.mapColorList)
	return self.mapColorList[x]
end

function GameBoardLogic:isColorTypeValid(colorType)
	return AnimalTypeConfig.isColorTypeValid(colorType)
end

function GameBoardLogic:isSpecialTypeValid(specialType)
	return AnimalTypeConfig.isSpecialTypeValid(specialType)
end

function GameBoardLogic:getBoardMap()
	return self.boardmap
end

function GameBoardLogic:getItemMap()
	return self.gameItemMap
end

function GameBoardLogic:isItemCanUsed(r,c)		--地图上可以被使用的地块
	if self.boardmap[r]
		and self.boardmap[r][c]
		and self.boardmap[r][c].isUsed
		then
		return true
	end
	return false
end

function GameBoardLogic:checkItemBlock(r,c)
	local item = self.gameItemMap[r][c];
	local board = self.boardmap[r][c];

	if item:checkBlock() then
		self.isBlockChange = true;
	end
	board.isBlock = item.isBlock;
	return self.isBlockChange
end

function GameBoardLogic:setChainBreaked()
	self.chainBreaked = true
end

function GameBoardLogic:setTileMoved()
	self.tileMoved = true
end

----更新Block的状态来影响下落
function GameBoardLogic:updateFallingAndBlockStatus()
	if self.isBlockChange or self.chainBreaked or self.tileMoved then
		FallingItemLogic:updateHelpMapByDeleteBlock(self)
		self.isBlockChange = false
		self.chainBreaked = false
		self.tileMoved = false
	end
end

function GameBoardLogic:isItemCanMoved(r,c)		--地图上可以被移动的Item
	if r > 0 and r<= #self.gameItemMap and c>0 and c<= #self.gameItemMap[r] then
		local item = self.gameItemMap[r][c]
		if item and item:canBeSwap() then
			return true
		end
end
	return false
end

function GameBoardLogic:isItemInTile(r, c)	-- 判断点击位置是否在棋盘有效位置中
	if r > 0 and r <= #self.boardmap and c > 0 and c <= #self.boardmap[r] then
		if self.boardmap[r] and self.boardmap[r][c] and self.boardmap[r][c].isUsed and
			self.gameItemMap[r] and self.gameItemMap[r][c] and self.gameItemMap[r][c].isUsed then
			return true
		end
	end
	return false
end

--可以被交换，但是不一定有匹配
function GameBoardLogic:canBeSwaped(r1,c1,r2,c2)
	if not self.isWaitingOperation or self.theGamePlayStatus ~= GamePlayStatus.kNormal then
		return 0
	end
	return SwapItemLogic:canBeSwaped(self, r1,c1,r2,c2)
end

function GameBoardLogic:canUseHammer(r, c)
	local item = self.gameItemMap[r][c]
	return item:canBeEffectByHammer()
end

function GameBoardLogic:canUseLineBrush(r, c)
	local itemData = self.gameItemMap[r][c]
	if itemData.ItemType ~= GameItemType.kAnimal or
		self:isSpecialTypeValid(itemData.ItemSpecialType) or 
		itemData:seizedByGhost()
		then
		return false
	end
	return true
end

function GameBoardLogic:canUseForceSwap(r1, c1, r2, c2)
	if not self:isItemCanMoved(r1, c1) or not self:isItemCanMoved(r2, c2) or
		not self:tileNextToEachOther(r1, c1, r2, c2) then
		return false
	end
	return true
end

function GameBoardLogic:canUseLineEffectOnGrid(r, c)
	local itemData = self.gameItemMap[r][c]
	return itemData:canBeEffectByLineEffectProp()
end

function GameBoardLogic:isNormal(item)
    if item.ItemType == GameItemType.kAnimal
	    and item.ItemSpecialType == 0 -- not special
	    and item:isAvailable()
	    and not item:hasLock() 
	    and not item:hasFurball()
	    then
	        return true
    end
    return false
end

function GameBoardLogic:canUseRandomBird()
	for r=1, #self.gameItemMap do
		for c = 1, #self.gameItemMap[r] do
			local item = self.gameItemMap[r][c]
			if item and self:isNormal(item) then
				return true
			end
		end
	end
	return false
end

function GameBoardLogic:canUseBroom(r, c)
	local rows = self:getBroomRows(r)
	return not (self:isRowEmpty(rows.r1) and self:isRowEmpty(rows.r2))
end

function GameBoardLogic:canUseOctopusForbid()
	if not self.octopusWait or tonumber(self.octopusWait) <= 0 then

		local octopusNum = 0
		for r = 1, #self.gameItemMap do 
			for c = 1, #self.gameItemMap[r] do 
				local item = self.gameItemMap[r][c]
				local board = self.boardmap[r][c]
				if item 
					and item.ItemType == GameItemType.kPoisonBottle
					and board.colorFilterBLevel == 0
					and item.blockerCoverLevel == 0
					and not item:hasActiveSuperCuteBall() 
					and not board.isReverseSide then
					octopusNum = octopusNum + 1
				end
			end
		end

		if octopusNum > 0 then
			return true
		else
			return false , 5
		end
	end

	return false , 3
end
--开始尝试交换两个Item，期间不能点击其他东西，交换结束后，可以匹配消除，则消除，不能则进行物品回调
function GameBoardLogic:startTrySwapedItem(r1,c1,r2,c2 , callback)
	local gameBoardActionItem1 = IntCoord:create(r1,c1)
	local gameBoardActionItem2 = IntCoord:create(r2,c2)
	local theAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameBoardAction,		--动作发起主体	--能够进行普通交换ard为主体
		GameBoardActionType.kStartTrySwapItem,		--动作类型	    --能够进行普通交换交换两个Item
		gameBoardActionItem1,						--动作物体1		
		gameBoardActionItem2,						--动作物体2		
		GamePlayConfig_SwapAction_CD)				--动作持续时间	--将引起一下次数据变化
	theAction.swapCallback = callback
	self:addSwapAction(theAction)
	GamePlayMusicPlayer:playEffect(GameMusicType.kSwap)
end

function GameBoardLogic:startWaitingOperation()
	self.isWaitingOperation = true
	self.gamePlayEventTrigger:chechMatch(self)
	self:onWaitingOperationChanged()
    TurretLogic:updateTurretLockStatus(self)	--解除炮塔锁定
	ProductItemDiffChangeLogic:onStepEnd()
	StageInfoLocalLogic:addStepProgressData(UserManager:getInstance().uid)
	SectionResumeManager:addSection()
	ReplayDataManager:updateGamePlayContext(false, true) --not force, not write file
	ReplayDataManager:updateCurrSectionDataToReplay()
    self:clearSrcSpecialCoverList() --清空特效原表
    self:revertSpringSkillUseType()
end

function GameBoardLogic:stopWaitingOperation()
	self.isWaitingOperation = false
	self:onWaitingOperationChanged()
end

function GameBoardLogic:onWaitingOperationChanged()
	if self.isWaitingOperation == true then
		if self.boardView.isPaused == false then
			self:startEliminateAdvise()
			self:startMoveTileEffect()
			self:startTargetTip()
		else
			self:stopEliminateAdvise()
			self:stopMoveTileEffect()
			self:stopTargetTip()
		end

		if self.PlayUIDelegate then

			local canUseProp = self.replayMode ~= ReplayMode.kReview
			self.PlayUIDelegate:setItemTouchEnabled(canUseProp)

			if self.hasUseRevertThisRound then
				self.PlayUIDelegate:setPropState(GamePropsType.kBack, 2, false)
			elseif not self.saveRevertData then
				-- init disable revert prop, left empty
			else
				self.PlayUIDelegate:setPropState(GamePropsType.kBack, nil, true)
			end		
			if self.PlayUIDelegate:hasInGameProp(GamePropsType.kRandomBird) then
				if not self:canUseRandomBird() then
					self.PlayUIDelegate:setPropState(GamePropsType.kRandomBird, 4, false)
				else
					self.PlayUIDelegate:setPropState(GamePropsType.kRandomBird, nil, true)
				end
			end

			if self.PlayUIDelegate:hasInGameProp(GamePropsType.kOctopusForbid) then

				local canuse , reason = self:canUseOctopusForbid()
				if canuse then
					self.PlayUIDelegate:setPropState(GamePropsType.kOctopusForbid, nil, true)
				else
					self.PlayUIDelegate:setPropState(GamePropsType.kOctopusForbid, reason , false)
				end
			end

		end
	elseif self.isWaitingOperation == false then
		self:stopEliminateAdvise()
		self:stopMoveTileEffect()
		self:stopTargetTip()
		if self.PlayUIDelegate then
			self.PlayUIDelegate:setItemTouchEnabled(false)
		end
		if self.boardView then
			self.boardView:stopOldSelectEffect()
		end
	end

end


----搞笑式移动两个方块----被绳子格挡住了
function GameBoardLogic:startTrySwapedItemFun(r1,c1,r2,c2)
	local gameBoardActionItem1 = IntCoord:create(r1,c1)
	local gameBoardActionItem2 = IntCoord:create(r2,c2)
	local theAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameBoardAction,		--动作发起主体	--能够进行普通交换ard为主体
		GameBoardActionType.kStartTrySwapItem_fun,		--动作类型	    --能够进行普通交换交换两个Item
		gameBoardActionItem1,						--动作物体1		
		gameBoardActionItem2,						--动作物体2		
		GamePlayConfig_SwapAction_Fun_CD)			--动作持续时间	--将引起一下次数据变化

	self:addSwapAction(theAction)
	GamePlayMusicPlayer:playEffect(GameMusicType.kSwapFun)
end

--添加一个新的动作到队列里面
function GameBoardLogic:addGameAction(theAction)
	self:addActionToList(theAction, self.gameActionList)
end

function GameBoardLogic:addDestructionPlanAction(theAction)
	self:addActionToList(theAction, self.destructionPlanList)
end

function GameBoardLogic:addStableDestructionPlanAction(theAction)
	self:addActionToList(theAction, self.stableDestructionPlanList)
end

function GameBoardLogic:addDestroyAction(theAction)
	self:addActionToList(theAction, self.destroyActionList)
end

function GameBoardLogic:addFallingAction(theAction)
	self:addActionToList(theAction, self.fallingActionList)
end

function GameBoardLogic:addSwapAction(theAction)
	self:addActionToList(theAction, self.swapActionList)

	self.fsm:onStartSwap()
end

function GameBoardLogic:addPropAction(theAction)
	self:addActionToList(theAction, self.propActionList)
	SnapshotManager:stop()
end

function GameBoardLogic:addGlobalCoreAction(theAction)
	self:addActionToList(theAction, self.globalCoreActionList)
end

local totalActIndex = 1 
function GameBoardLogic:addActionToList(theAction, theList , type)
	--[[
	totalActIndex = totalActIndex + 1

	local actCount = #theList + 1
	for i = 1, #theList do 					
		if theList[i] == nil then
			actCount = i
			break
		end
	end
	printx( 1 , "   GameBoardLogic:addActionToList  " .. type .. "    actCount = " , actCount)
	theAction.creatId = totalActIndex
	theList[actCount] = theAction
	theAction.actid = actCount
	--]]

	----[[
	local actCount = table.maxn(theList) + 1
	theList[actCount] = theAction
	theAction.actid = actCount	
	--]]
end

function GameBoardLogic:addNeedCheckMatchPoint(r, c)
	table.insert(self.needCheckMatchList, { r = r, c = c })
end

function GameBoardLogic:cleanNeedCheckMatchList()
	self.needCheckMatchList = nil
	self.needCheckMatchList = {}
end

function GameBoardLogic:getGamePlayType(...)
	assert(#{...} == 0)

	return self.theGamePlayType
end

function GameBoardLogic:getActionListCount()
	if self.gameActionList == nil then
		self.gameActionList = {}
	end
	local n = 0
	for k,v in pairs(self.gameActionList) do
		n = n + 1
	end
	return n;
end

--交换两个Item--并且尝试匹配消除
function GameBoardLogic:SwapedItemAndMatch(r1,c1,r2,c2, doSwap)	--doSwap==true表示确实进行交换，并且引起相应效果，doSwap==false表示仅仅判断是否能够交换

	self.hasAddMoveStep = nil
	local tempSaveDataForRevert = self:getSaveDataForRevert()
	
	local swapInfo = { { r = r1, c = c1 }, { r = r2, c = c2 } }
	self.swapInfo = swapInfo

	local ret = SwapItemLogic:SwapedItemAndMatch(self, r1, c1, r2, c2, doSwap) 
	if ret and doSwap then
		SectionResumeManager:setNextSectionInfo( 
			SectionData:create( SectionType.kSwap , { r = r1, c = c1 } , { r = r2, c = c2 } , nil )  
			)
		self:UseMoves()
		self.saveRevertData = tempSaveDataForRevert
		if self.PlayUIDelegate then
			self.PlayUIDelegate:onGameSwap({x = r1, y = c1}, {x = r2, y = c2})
		end
	else
		self.swapInfo = nil
	end
	return ret
end

--获取当前的数据快照用于回退，包含item、board地格、分数记录等数据
function GameBoardLogic:getSaveDataForRevert()
	local ret = SaveRevertData:create(self)
	return ret
end

function GameBoardLogic:getRevertPropInfo( ... )
	if self.saveRevertData then
		return self.saveRevertData:getUsePropInfo()
	end
end

function GameBoardLogic:setRevertGiftInfo(itemId,key)
	if self.saveRevertData then
		self.saveRevertData:addGiftInfo({ itemId=itemId,key=key })
	end
end

function GameBoardLogic:getRevertGiftInfos( ... )
	if self.saveRevertData then
		return self.saveRevertData:getGiftInfos()
	end
end


------返回魔力鸟非主动触发时消除的颜色类型------
function GameBoardLogic:getBirdEliminateColor()

    if self.level >= 500 and self.level <= 700 then
	    local colorlist = {}
	    ----1.求每个颜色的动物数量
	    for r=1,#self.gameItemMap do
		    for c=1,#self.gameItemMap[r] do
			    local item = self.gameItemMap[r][c]
			    if item:isColorful() then
				    if item.bombRes == nil or (item.bombRes.x == 0 and item.bombRes.y == 0) then 		----已经被引爆的不计入颜色
					    local originColor = AnimalTypeConfig.getOriginColorValue(item._encrypt.ItemColorType)
					    if (colorlist[originColor] == nil )then
						    colorlist[originColor] = 1
					    else
						    colorlist[originColor] = colorlist[originColor] + 1
					    end
				    end
			    end
		    end
	    end

	    local colorTypeList = {}
	    for i, v in ipairs(AnimalTypeConfig.colorTypeList) do
		    if colorlist[v] then
			    table.insert(colorTypeList, v)
		    end
	    end

	    local result = nil
	    if #colorTypeList > 0 then
		    result = colorTypeList[self.randFactory:rand(1, #colorTypeList)]
	    end
	    return result
    else
        local colorlist = {}
	    ----1.求每个颜色的动物数量
	    for r=1,#self.gameItemMap do
		    for c=1,#self.gameItemMap[r] do
			    local item = self.gameItemMap[r][c]
			    if item:isColorful() then
				    if item.bombRes == nil or (item.bombRes.x == 0 and item.bombRes.y == 0) then 		----已经被引爆的不计入颜色
					    local originColor = AnimalTypeConfig.getOriginColorValue(item._encrypt.ItemColorType)
					    if (colorlist[originColor] == nil )then
						    colorlist[originColor] = 1
					    else
						    colorlist[originColor] = colorlist[originColor] + 1
					    end
				    end
			    end
		    end
	    end

	    local colorTypeList = {}
	    for i, v in ipairs(AnimalTypeConfig.colorTypeList) do
		    if colorlist[v] then
                local info = {}
                info.color = v
                info.num = colorlist[v]
                info.colorIndex = i
			    table.insert(colorTypeList, info)
		    end
	    end

        --排序
        local function sortList( a,b )
            if a.num < b.num then
                return true
            elseif a.num == b.num then
                return a.colorIndex < b.colorIndex 
            else
                return false
            end
        end
        table.sort( colorTypeList, sortList )

        local smallNum = 0
        local samllList = {}
        local withoutSmallList = {}

        if colorTypeList and #colorTypeList > 0 then
            smallNum = colorTypeList[1].num

             for i,v in ipairs(colorTypeList) do
                if v.num == smallNum then
                    table.insert( samllList, v )
                else
                    table.insert( withoutSmallList, v )
                end
            end
        end

        if #withoutSmallList == 0 then
            withoutSmallList = colorTypeList
        end

	    local result = nil
	    if #withoutSmallList > 0 then
		    result = withoutSmallList[self.randFactory:rand(1, #withoutSmallList)].color
	    end
	    return result
    end
end

----返回地图上某个颜色的所有物体的Position----
function GameBoardLogic:getPosListOfColor(theColor)
	local posList = {}
	local count = 0

	if theColor and AnimalTypeConfig.isColorTypeValid(theColor) then 			----正确颜色才会有引爆
		for r=1,#self.gameItemMap do
			for c=1,#self.gameItemMap[r] do
				local item = self.gameItemMap[r][c];
				if (item._encrypt.ItemColorType == theColor and not item.colorFilterBLock) then
					count = count + 1;
					posList[count] = IntCoord:create(r,c)
				end
			end
		end
	end
	return posList
end

function GameBoardLogic:getPosListOfItemType(ptype, noColor)--返回ItemType相同的坐标
	local posList = {}
	local count = 0

	if ptype then
		for r=1,#self.gameItemMap do
			for c=1,#self.gameItemMap[r] do
				local item = self.gameItemMap[r][c];
				if item.ItemType == ptype and item._encrypt.ItemColorType ~= noColor and not item.colorFilterBLock then
					count = count + 1;
					posList[count] = IntCoord:create(r,c)
				end
			end
		end
	end
	return posList
end

----使用某个道具
function GameBoardLogic:canUseProps()
	if self:getActionListCount() == 0 then
		return true;
	end

	return false;
end

function GameBoardLogic:revertProps( ... )

	if not self.PlayUIDelegate then
		return
	end

	if not self.saveRevertData then
		return
	end

	local revertPropInfo = self:getRevertPropInfo()
	local revertGiftInfos = self:getRevertGiftInfos()

	if revertPropInfo then
		local realItemId = revertPropInfo.propId
		if revertPropInfo.usePropType == UsePropsType.EXPIRE then  
			realItemId = ItemType:getRealIdByTimePropId(revertPropInfo.propId) 
		end
	
		if realItemId == GamePropsType.kOctopusForbid or realItemId == GamePropsType.kOctopusForbid_l then
			self.octopusWait = nil
			self.PlayUIDelegate:setPropState(GamePropsType.kOctopusForbid,nil, true)
		end
	end

	for k,v in pairs(revertGiftInfos or {}) do
		v.r,v.c = self.saveRevertData:getItemPos(v.key)
	end

	-- 
	setTimeOut(function( ... )
		if self.PlayUIDelegate.isDisposed then
			return
		end
		if revertPropInfo then
			self.PlayUIDelegate:revertItem(
				revertPropInfo.propId,
				revertPropInfo.expireTime,
				revertPropInfo.usePropType
			)
		end
		for k,v in pairs(revertGiftInfos or {}) do
			local pos = nil
			if v.r and v.c then
				pos = self:getGameItemPosInView(v.r,v.c)
			end
			self.PlayUIDelegate:revertGiftItem(v.itemId,pos)
		end
	end,1.0)
end

function GameBoardLogic:setBrushType(animalType)
	self.forceBrushAnimalType = animalType
	self.boardView:setBrushType(animalType)
end

function GameBoardLogic:useProps(propsType, r1, c1, r2, c2, propsUseType, isGuideRefresh, noReplayRecord, noSectionResumeRecord)
	if _G.isLocalDevelopMode then printx( 1 , "   GameBoardLogic:useProps   " , propsType, r1, c1, r2, c2,propsUseType, isGuideRefresh, noReplayRecord) end
	--printx( 1 , "GameBoardLogic:useProps  " , debug.traceback() )
	if self.boardView then
		self.boardView:stopOldSelectEffect()
	end
	if not propsType then return false end

	-- 记录使用道具记录用于回滚
	if table.exist(SupportBackPropTypes,propsType) then
		self.hasUseRevertThisRound = false
		self.hasAddMoveStep = nil
		self.saveRevertData = self:getSaveDataForRevert()
		if self.PlayUIDelegate and self.PlayUIDelegate.getUsePropInfo then
			self.saveRevertData:setUsePropInfo(self.PlayUIDelegate:getUsePropInfo())
		end
	end

	if self:getActionListCount() == 0 then

		--必须先调用addPropsUsedInLevel，确保生成的数据是没有被道具影响过的棋盘生成的
		StageInfoLocalLogic:addPropsUsedInLevel(UserManager:getInstance().uid, propsType , propsType == GamePropsType.kAdd5 or propsType == GamePropsType.kBombAdd5)

		local user = UserManager:getInstance():getUserRef()
		local stageInfo = StageInfoLocalLogic:getStageInfo(user.uid)

		if stageInfo and not self:isVirtualPropType(propsType) then
			stageInfo:addUsePropLog(propsType)
		end

		local datas = {prop = propsType, pt=propsUseType, x1 = r1, y1 = c1, x2 = r2, y2 = c2}
		SnapshotManager:catchUseProp( datas )
	
		if propsType == GamePropsType.kRefresh 
			or propsType == GamePropsType.kRefresh_b 
			or propsType == GamePropsType.kRefresh_l
			then
			if RefreshItemLogic.tryRefresh(self, isGuideRefresh) then
				-----成功了----
				RefreshItemLogic:runRefreshAction(self, true)
				self.fsm:changeState(self.fsm.usePropState)
			end
		elseif propsType == GamePropsType.kAdd5 or propsType == GamePropsType.kBombAdd5 then
			self.theCurMoves = self.theCurMoves + 5
			self.hasAddMoveStep = { source = "Prop" , steps = 5 }
			
			if self.PlayUIDelegate and (not self.PlayUIDelegate.isDisposed) then
				self.PlayUIDelegate:useStepPropComplete(self.theCurMoves)
			end

			if self.gameMode:is(SpringHorizontalEndlessMode) then
				self.gameMode:logAddStep(5)
			end

            local bActivitySupport = SpringFestival2019Manager.getInstance():getCurIsAct()
            if bActivitySupport then
                local PicYearMeta = require "zoo.localActivity.PigYear.PicYearMeta"

                local info = {}
                table.insert( info, {itemId = PicYearMeta.ItemIDs.GEM_4, num = PicYearMeta.ADDFIVE_ADD_GETNUM}  )
                PigYearLogic:addRewards(info)
                SpringFestival2019Manager.getInstance():addGemNum( 4, PicYearMeta.ADDFIVE_ADD_GETNUM )
            end

			GamePlayMusicPlayer:playEffect( GameMusicType.kPropAdd5stepFlyon )

			SnapshotManager:catchStep( self )

			-- fallingMatchState
			if self.replaying then    --播放replay的特殊处理
				if self.replayMode == ReplayMode.kCheck or self.replayMode == ReplayMode.kQACheck then
					self.fsm.waitingState.nextState = self.fsm.waitingState
				else
					setTimeOut( function () 
							self.fsm.waitingState.nextState = self.fsm.waitingState
						end , 2.5 )
				end
			end
		elseif propsType == GamePropsType.kAdd15 then
			self.theCurMoves = self.theCurMoves + 15
			self.hasAddMoveStep = { source = "Prop" , steps = 15 }
			
			if self.PlayUIDelegate and (not self.PlayUIDelegate.isDisposed) then
				self.PlayUIDelegate:useStepPropComplete(self.theCurMoves, nil, 15)
			end

			if self.gameMode:is(SpringHorizontalEndlessMode) then
				self.gameMode:logAddStep(15)
			end

			GamePlayMusicPlayer:playEffect( GameMusicType.kPropAdd5stepFlyon )

			SnapshotManager:catchStep( self )

			if self.replaying then    --播放replay的特殊处理
				if self.replayMode == ReplayMode.kCheck or self.replayMode == ReplayMode.kQACheck then
					self.fsm.waitingState.nextState = self.fsm.waitingState
				else
					setTimeOut( function () 
							self.fsm.waitingState.nextState = self.fsm.waitingState
						end , 2.5 )
				end
			end
		elseif propsType == GamePropsType.kSwap 
			or propsType == GamePropsType.kSwap_l 
			or propsType == GamePropsType.kSwap_b
			then
			if _G.isLocalDevelopMode then printx(0, "********Swap") end
			if not r1 or not r2 or not c1 or not c2 then
				StageInfoLocalLogic:removeLastPropsUsedData( UserManager:getInstance().uid , propsType )
				return false
			end
			if not self:canUseForceSwap(r1, c1, r2, c2) then
				StageInfoLocalLogic:removeLastPropsUsedData( UserManager:getInstance().uid , propsType )
				return false
			end
			local propAction = GameBoardActionDataSet:createAs(GameActionTargetType.kPropsAction,
				GamePropsActionType.kSwap, IntCoord:create(r1,c1), IntCoord:create(r2, c2), GamePlayConfig_ForceSwapAction_CD)
			self:addPropAction(propAction)
			self.fsm:changeState(self.fsm.usePropState)

			GamePlayMusicPlayer:playEffect( GameMusicType.kPropSwap )
			if _G.isLocalDevelopMode then printx(0, "********TheEnd") end
		elseif propsType == GamePropsType.kLineBrush 
			or propsType == GamePropsType.kLineBrush_l 
			or propsType == GamePropsType.kLineBrush_b
			then
			if _G.isLocalDevelopMode then printx(0, "********LineBrush") end
			if not r1 or not c1 or not r2 or not c2 then
				StageInfoLocalLogic:removeLastPropsUsedData( UserManager:getInstance().uid , propsType )
				return false
			end
			if not self:canUseLineBrush(r1, c1) then
				StageInfoLocalLogic:removeLastPropsUsedData( UserManager:getInstance().uid , propsType )
				return false
			end

			-- 引导中强制变成指定方向的特效
			if GameGuide then
				local action = GameGuideData:sharedInstance():getRunningAction()
				if action and action.type == "useGiftTip" then
					if action.direction == "row" and c2 ~= 0 or 
						action.direction == "column" and r2 ~= 0 then
						r2,c2 = c2,r2
					end
				end
			end

			if self.forceBrushAnimalType and self.forceBrushAnimalType == AnimalTypeConfig.kColumn then
				r2, c2 = 0,1
			elseif self.forceBrushAnimalType and self.forceBrushAnimalType == AnimalTypeConfig.kLine then
				r2, c2 = 1,0
			end

			self:setBrushType(nil)

			local targetPos = IntCoord:create(r2, c2)
			local propAction = GameBoardActionDataSet:createAs(GameActionTargetType.kPropsAction,
				GamePropsActionType.kLineBrush, IntCoord:create(r1,c1), targetPos, GamePlayConfig_LineBrush_Animation_CD)
			self:addPropAction(propAction)
			self.fsm:changeState(self.fsm.usePropState)
			GamePlayMusicPlayer:playEffect( GameMusicType.kPropMagicwand )
			if _G.isLocalDevelopMode then printx(0, "TheEnd") end
		elseif propsType == GamePropsType.kHammer 
			or propsType == GamePropsType.kHammer_l 
			or propsType == GamePropsType.kHammer_b
			then
			if _G.isLocalDevelopMode then printx(0, "********Hammer") end
			if not r1 or not c1 then
				StageInfoLocalLogic:removeLastPropsUsedData( UserManager:getInstance().uid , propsType )
				return false
			end
			if not self:canUseHammer(r1, c1) then
				StageInfoLocalLogic:removeLastPropsUsedData( UserManager:getInstance().uid , propsType )
				return false
			end
			local propAction = GameBoardActionDataSet:createAs(GameActionTargetType.kPropsAction,
				GamePropsActionType.kHammer, IntCoord:create(r1,c1), nil, GamePlayConfig_Hammer_Animation_CD)
			self:addPropAction(propAction)
			self.fsm:changeState(self.fsm.usePropState)
			if _G.isLocalDevelopMode then printx(0, "********TheEnd") end
		elseif propsType == GamePropsType.kBack 
			or propsType == GamePropsType.kBack_b 
			or propsType == GamePropsType.kBack_l
			or propsType == GamePropsType.kSectionResumeBack
			then
			if _G.isLocalDevelopMode then printx(0, "********TheRevert") end
			self.hasUseRevertThisRound = true
			if self.saveRevertData then
				-- 回退道具
				self:revertProps()
				-- 防止中间加五步被重置
				if self.hasAddMoveStep then --非道具增加的步数都将被回滚
					if self.hasAddMoveStep.source == "Prop" or self.hasAddMoveStep.source == "tryAgainWhenFailed" then
						self.saveRevertData.theCurMoves = self.saveRevertData.theCurMoves + tonumber(self.hasAddMoveStep.steps)
					end
				end
				self.hasAddMoveStep = nil

				self.gameMode:revertDataFromBackProp()
				--[[
				if self.realCostMoveWithoutBackProp then
					self.realCostMoveWithoutBackProp = self.realCostMoveWithoutBackProp - 1
				end
				]]
				if self.PlayUIDelegate then
					local winSize = CCDirector:sharedDirector():getWinSize()
					local node = TimebackAnimation:create()
					node:setPosition(ccp(winSize.width / 2, winSize.height / 2))
					self.PlayUIDelegate.effectLayer:addChild(node)

					if self.realCostMove == 1 and self.PlayUIDelegate.propList and self.PlayUIDelegate.propList.leftPropList then
						local finded = self.PlayUIDelegate.propList.leftPropList:findItemByItemID( GamePropsType.kBack )
						if finded and finded.item then
							finded.item:setOpacity(130)
						end
					end
				end
				local propAction = GameBoardActionDataSet:createAs(GameActionTargetType.kPropsAction, GamePropsActionType.kBack, nil, nil, GamePlayConfig_Back_Animation_CD)
				self:addPropAction(propAction)
				self.fsm:changeState(self.fsm.usePropState)
				GamePlayMusicPlayer:playEffect( GameMusicType.kPropBack )
			end
			if _G.isLocalDevelopMode then printx(0, "********TheEnd") end
		elseif propsType == GamePropsType.kOctopusForbid or propsType == GamePropsType.kOctopusForbid_l then
			local action = GameBoardActionDataSet:createAs(
			        GameActionTargetType.kPropsAction, 
			        GamePropsActionType.kOctopusForbid,
			        nil, 
			        nil, 
			        GamePlayConfig_Back_AnimTime)
			action.addInfo = ''
			self:addPropAction(action)
			self.fsm:changeState(self.fsm.usePropState)
			self.octopusWait = 3
			if self.PlayUIDelegate then
				self.PlayUIDelegate:setPropState(GamePropsType.kOctopusForbid,3, false)
			end
			GamePlayMusicPlayer:playEffect( GameMusicType.kPropOctopus )
		elseif propsType == GamePropsType.kRandomBird then
			local action = GameBoardActionDataSet:createAs(
			        GameActionTargetType.kPropsAction, 
			        GamePropsActionType.kRandomBird,
			        IntCoord:create(r1, c1), 
			        nil, 
			        GamePlayConfig_Back_AnimTime)
			self:addPropAction(action)
			self.fsm:changeState(self.fsm.usePropState)
		elseif propsType == GamePropsType.kBroom or propsType == GamePropsType.kBroom_l then
			local rows = self:getBroomRows(r1)
			local action = GameBoardActionDataSet:createAs(
			        GameActionTargetType.kPropsAction, 
			        GamePropsActionType.kBroom,
			        nil, 
			        nil, 
			        GamePlayConfig_Back_AnimTime)
			action.rows = rows
			self:addPropAction(action)
			self.fsm:changeState(self.fsm.usePropState)
		elseif propsType == GamePropsType.kSpringFirework then
			local action = GameBoardActionDataSet:createAs(
		        GameActionTargetType.kPropsAction, 
		        GamePropsActionType.kMegaPropSkill,
		        nil, 
		        nil, 
		        GamePlayConfig_MaxAction_time)
			self:addPropAction(action)
			self.fsm:changeState(self.fsm.usePropState)
		elseif propsType == GamePropsType.kMoleWeeklyRaceSPProp then
			local action = GameBoardActionDataSet:createAs(
		        GameActionTargetType.kPropsAction, 
		        GamePropsActionType.kMoleWeeklyRaceSPProp,
		        nil, 
		        nil, 
		        GamePlayConfig_MaxAction_time)
			action.targetList, action.throwAddStepAmount, action.throwColourAmount, action.hpDamage = MoleWeeklyRaceLogic:getMoleSpecialPropsDatas(self)
			self:addPropAction(action)
			self.fsm:changeState(self.fsm.usePropState)
		elseif propsType == GamePropsType.kHedgehogCrazy then
			local action = GameBoardActionDataSet:createAs(
		        GameActionTargetType.kPropsAction, 
		        GamePropsActionType.kHedgehogCrazy,
		        nil, 
		        nil, 
		        GamePlayConfig_MaxAction_time)
			self:addPropAction(action)
			self.fsm:changeState(self.fsm.usePropState)
			self.hedgehogCrazyBuff = true
			local dc_data = {
				game_type = "stage",
				game_name = "2016_children_day",
				category = "other",
				sub_category = "children_day_crazy_click",
				t1 = 1,
			}
			DcUtil:activity(dc_data)
			GameGuide:sharedInstance():onHedgehogCrazyClick(true)
		elseif propsType == GamePropsType.kWukongJump then
			local action = GameBoardActionDataSet:createAs(
		        GameActionTargetType.kPropsAction, 
		        GamePropsActionType.kWukongJump,
		        nil, 
		        nil, 
		        GamePlayConfig_MaxAction_time)
			self:addPropAction(action)
			self.fsm:changeState(self.fsm.usePropState)
			--self.hedgehogCrazyBuff = true

			--[[
			local dc_data = {
				game_type = "stage",
				game_name = "christmas",
				category = "other",
				sub_category = "christmas_crazy_click"
			}
			DcUtil:activity(dc_data)
			]]
			--GameGuide:sharedInstance():onHedgehogCrazyClick(true)
		elseif propsType == GamePropsType.kNationDay2017Cast then
			local action = GameBoardActionDataSet:createAs(
		        GameActionTargetType.kPropsAction, 
		        GamePropsActionType.kNationDay2017Cast,
		        nil, 
		        nil, 
		        GamePlayConfig_MaxAction_time)
			self:addPropAction(action)
			self.fsm:changeState(self.fsm.usePropState)
        elseif propsType == GamePropsType.kJamSpeardHummer then
			local action = GameBoardActionDataSet:createAs(
		        GameActionTargetType.kPropsAction, 
		        GamePropsActionType.kJamSpeardHammer,
		        IntCoord:create(r1,c1), 
		        nil, 
		        GamePlayConfig_MaxAction_time)
			self:addPropAction(action)
			self.fsm:changeState(self.fsm.usePropState)
		elseif propsType == GamePropsType.kRowEffect 
			or propsType == GamePropsType.kRowEffect_l 
			or propsType == GamePropsType.kColumnEffect 
			or propsType == GamePropsType.kColumnEffect_l
			then
			local isColumn = false
			if propsType == GamePropsType.kColumnEffect 
	            or propsType == GamePropsType.kColumnEffect_l then
	            isColumn = true
	        end
			local action = GameBoardActionDataSet:createAs(
		        GameActionTargetType.kPropsAction, 
		        GamePropsActionType.kLineEffectProp,
		        IntCoord:create(r1,c1), 
		        nil, 
		        GamePlayConfig_MaxAction_time)
			action.isColumn = isColumn
			self:addPropAction(action)
			self.fsm:changeState(self.fsm.usePropState)
		end

		r1, c1, r2, c2 = r1 or 0, c1 or 0, r2 or 0, c2 or 0
		if (not self.replaying) 
			or self.replayMode == ReplayMode.kConsistencyCheck_Step1 
			or self.replayMode == ReplayMode.kAutoPlayCheck 
			or (self.replayMode == ReplayMode.kMcts and _G.launchCmds.domain) then
			-- SnapshotManager:stop()
			-- table.insert(self.replaySteps, {prop = propsType, x1 = r1, y1 = c1, x2 = r2, y2 = c2})
			if not noReplayRecord then 
				local userPropData = {prop = propsType, pt=propsUseType, x1 = r1, y1 = c1, x2 = r2, y2 = c2}
				self:addReplayStep( userPropData )
			end

			--[[
			if propsUseType == UsePropsType.FAKE then
				--self.PlayUIDelegate.propList:addFakeItemForReplay( propsType , -1 )
			end
			]]
			
			local runningScene = Director:sharedDirector():getRunningScene()		
			if runningScene.addEditorRecordPropsInfo ~= nil then
			   runningScene:addEditorRecordPropsInfo(propsType)
			end

			if GameGuide then
				GameGuide:sharedInstance():onUseProp(propsType, r1, c1, r2, c2)
			end
			if _G.isLocalDevelopMode then printx(0, "***********ReplayLog: Remembering Property usage!") end
		end

		self.boardView:dcUseProp(false, propsType)

		--StageInfoLocalLogic:addPropsUsedInLevel(UserManager:getInstance().uid, propsType , propsType == GamePropsType.kAdd5 or propsType == GamePropsType.kBombAdd5)
		
		if not noSectionResumeRecord then
			SectionResumeManager:setNextSectionInfo( 
				SectionData:create( SectionType.kUseProp , { r = r1, c = c1 } , { r = r2, c = c2 } , propsType )  
				)
		end

		self:checkUpdateLevelDifficultyAdjustByUseProp( propsUseType , propsType )

		GamePlayContext:getInstance():onUseProp( propsType , self.realCostMove , propsUseType )
      	ReplayDataManager:updateGamePlayContext(false)


		return true;
	else
		printx( 1 , "GameBoardLogic:useProps   self:getActionListCount() ~= 0")
	end
	return false;
end

function GameBoardLogic:checkUpdateLevelDifficultyAdjustByUseProp( propsUseType , propId )
	--printx( 1 , "GameBoardLogic:checkUpdateLevelDifficultyAdjustByUseProp ~~~~~~~~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" , propsUseType , propId )

	-- RemoteDebug:uploadLog( "GameBoardLogic" ,  "checkUpdateLevelDifficultyAdjustByUseProp  propsUseType" , propsUseType , 
	-- 	"propId" , propId , "self.replayMode" , self.replayMode , "self.replaying" , self.replaying )

	if self.replayMode == ReplayMode.kSectionResume and self.replaying then
		-- do nothing
	else

		--RemoteDebug:uploadLog( "GameBoardLogic" ,  "checkUpdateLevelDifficultyAdjustByUseProp  111"  )
		if propsUseType == UsePropsType.NORMAL or propsUseType == UsePropsType.EXPIRE 
			or (self.replayMode ~= ReplayMode.kSectionResume and propsUseType == UsePropsType.FAKE) then
			--RemoteDebug:uploadLog( "GameBoardLogic" ,  "checkUpdateLevelDifficultyAdjustByUseProp  222" ,LevelDifficultyAdjustManager.DAManager:getIsSatisfyPreconditions() )
			if LevelDifficultyAdjustManager:getDAManager():getIsSatisfyPreconditions() then
				--RemoteDebug:uploadLog( "GameBoardLogic" ,  "checkUpdateLevelDifficultyAdjustByUseProp  333" , LevelDifficultyAdjustManager:getDAManager():getIsPayUser()  )
				
				local count = LevelDifficultyAdjustManager:getDAManager():getTotalUsePropCount()
				LevelDifficultyAdjustManager:getDAManager():setTotalUsePropCount( count + 1 )

				if self.replayMode ~= ReplayMode.kResume and self.replayMode ~= ReplayMode.kReview then
					UserTagManager:updateTopLevelPropUsedCount( count + 1 )
				end


				LevelDifficultyAdjustManager:getDAManager():addThisPlayUsePropLog( propId )

				if propId == GamePropsType.kAdd5 
					or propId == GamePropsType.kAdd15 
					or propId == GamePropsType.kAdd1 
					or propId == GamePropsType.kAdd2 
				then
					local count = LevelDifficultyAdjustManager:getDAManager():getAddStepPropCount()
					LevelDifficultyAdjustManager:getDAManager():setAddStepPropCount( count + 1 )
				end

				LevelDifficultyAdjustManager:checkAdjustStrategyInLevel( self.level , self.realCostMove )
				LevelDifficultyAdjustManager:getDAManager():updateToReplayData() --update and flush
				
			end
		end

	end

end

function GameBoardLogic:isVirtualPropType(propType)
	if propType == kSpringPropItemID 
		or propType == GamePropsType.kWukongJump
		or propType == GamePropsType.kSpringFirework
		or propType == GamePropsType.kHedgehogCrazy
		or propType == GamePropsType.kNationDay2017Cast
		or propType == GamePropsType.kMoleWeeklyRaceSPProp
 		then
		 return true
	end
	return false
end

function GameBoardLogic:isUsePropsValid(propsType, r1, c1, r2, c2)
	if not propsType then return false end
	if self:getActionListCount() == 0 then
		if propsType == GamePropsType.kSwap 
			or propsType == GamePropsType.kSwap_l 
			or propsType == GamePropsType.kSwap_b
			then
			if not r1 or not r2 or not c1 or not c2 then
				return false
			end
			if not self:canUseForceSwap(r1, c1, r2, c2) then
				return false
			end
		elseif propsType == GamePropsType.kLineBrush 
			or propsType == GamePropsType.kLineBrush_l 
			or propsType == GamePropsType.kLineBrush_b
			then
			if not r1 or not c1 or not r2 or not c2 then
				return false
			end
			if not self:canUseLineBrush(r1, c1) then
				return false
			end
		elseif propsType == GamePropsType.kHammer 
			or propsType == GamePropsType.kHammer_l 
			or propsType == GamePropsType.kHammer_b
			then
			if not r1 or not c1 then
				return false
			end
			if not self:canUseHammer(r1, c1) then
				return false
			end
		elseif propsType == GamePropsType.kRowEffect 
			or propsType == GamePropsType.kRowEffect_l 
			or propsType == GamePropsType.kColumnEffect 
			or propsType == GamePropsType.kColumnEffect_l
			then
			if not r1 or not c1 then
				return false
			end
			if not self:canUseLineEffectOnGrid(r1, c1) then
				return false
			end
		end
		return true
	else
		he_log_error("[isUsePropsValid]game action list is not empty!!!size="..tostring(self:getActionListCount()))
		for k,v in pairs(self.gameActionList) do
			he_log_error( tostring(k) .. "st action type is :"..tostring(v.actionType))
		end
		
	end
	return false
end


function GameBoardLogic:isRowEmpty(rowNum)
	local gameItemMap = self.gameItemMap
	local isEmpty = true
	if gameItemMap[rowNum] then
		for c = 1, #gameItemMap[rowNum] do
			local item = gameItemMap[rowNum][c]
			if item and item.isEmpty == false then
				isEmpty = false
				break
			end
		end
	end
	return isEmpty
end

function GameBoardLogic:getBroomRows(r)
	local r1 = r
	local r2 = r1 - 1
	if r2 < 1 or (self:isRowEmpty(r2) and r1 < 9) then
		r2 = r1 + 1
	end

    -- 保证r1 < r2
    if r1 > r2 then
        local _t = r1
        r1 = r2
        r2 = _t
    end
    return {r1 = r1, r2 = r2}
end

----使用一次移动
function GameBoardLogic:UseMoves()
	self.realCostMove = self.realCostMove + 1
	self.realCostMoveWithoutBackProp = self.realCostMoveWithoutBackProp + 1
	self.gameMode:useMove()

	----豆荚关变化
	ProductItemLogic:addStep(self)

	-- 重新计算颜色掉落概率
	if self.dropBuffLogic then
		if self.newCompletedAnimalOrders then 
			-- 完成后只有下一步开始才重新计算概率，使用道具不考虑
			self.dropBuffLogic:onAnimalOrderCompleted(self.newCompletedAnimalOrders)
			self.newCompletedAnimalOrders = nil
		end

		self.dropBuffLogic:onUseMoves(self.realCostMove)
	end

	self:updateVariousDeedsOnUseMove()
	ActCollectionLogic:addUseMove()

	self:resetStepRecords()
end

--一些显示的更新
function GameBoardLogic:updateVariousDeedsOnUseMove()
	self:updateMoveTilesOnUseMove()
	PacmanLogic:updateDenProgressDisplay(self)
end

--local performance = require("hecore.performance"):new()
function GameBoardLogic:updateMoveTilesOnUseMove()

--performance:start()
--for i = 1, 1000 do

	if(nativeImplement.enabled) then
		_gameNative.GameBoardLogic_updateMoveTilesOnUseMove(self)
	else
		local boardmap = self.boardmap or {}
		for r = 1, #boardmap do 
			for c = 1, #boardmap[r] do 
				local board = boardmap[r][c]
				if board and board.isMoveTile then
            		board:onUseMoves()
           		end
			end
		end
	end

--end
--performance:finish("GameBoardLogic:updateMoveTilesOnUseMove")
end

--开始移动回合前，重置所有步数稳定处理搜需要的标识位及数据
function GameBoardLogic:resetStepRecords()
	self.isInStep = true 

	self.isVenomDestroyedInStep = false 

	self.hasUseRevertThisRound = false
end

--
--


function GameBoardLogic:tryDoOrderList(r, c, key1, key2, v1, rotation, p_pos)

	if key1 == GameItemOrderType.kAnimal then
		local animalIndex = AnimalTypeConfig.convertColorTypeToIndex(key2)
		GamePlayContext:getInstance():updatePlayInfo('killed_animal_' .. animalIndex, 1, true)
	end

	if key1 == GameItemOrderType.kSpecialBomb then
		if key2 == GameItemOrderType_SB.kLine then
			GamePlayContext:getInstance():updatePlayInfo('killed_line', 1, true)
		end
		if key2 == GameItemOrderType_SB.kWrap then
			GamePlayContext:getInstance():updatePlayInfo('killed_wrap', 1, true)
		end
		if key2 == GameItemOrderType_SB.kColor then
			GamePlayContext:getInstance():updatePlayInfo('killed_bird', 1, true)
		end
	end


	if v1 == nil then v1 = 1 end
	if self.gameMode:is(SpringHorizontalEndlessMode) then
		if key1 == GameItemOrderType.kSpecialTarget and key2 == GameItemOrderType_ST.kCoin then
			self.gameMode:collectChicken(v1, r, c)
		end
		-- 春节关只搜集小黄鸡
		return 
	end

	--四周年
	if key1 == 6 and (key2 == 5 or key2 == 6 or key2 == 7 or key2 == 8 or key2 == 9 ) then
		local order = nil
		for _, v in ipairs(self.theOrderList) do
			if v.key1 == 6 and v.key2 == 4 then
				order = v
				break
			end
		end

		if self.PlayUIDelegate and order then
			order.f1 = order.f1 + v1
			local pos_t = self:getGameItemPosInView(r,c)
			local num = order.v1 - order.f1
			if num < 0 then num = 0 end
			self.PlayUIDelegate:setTargetNumber(key1, key2, num, pos_t, rotation);
		end
		return true
	end

	if key1 == GameItemOrderType.kAnimal then key2 = AnimalTypeConfig.convertColorTypeToIndex(key2) end

	local ts = false
	for i,v in ipairs(self.theOrderList) do
		if v.key1 == key1 and v.key2 == key2 then
			if v.f1 < v.v1 and v.f1 + v1 >= v.v1 and key1 == GameItemOrderType.kAnimal then
				if self.dropBuffLogic and self.dropBuffLogic.dropBuffEnable then
					self.newCompletedAnimalOrders = self.newCompletedAnimalOrders or {}
					table.insert(self.newCompletedAnimalOrders, key2)
				end
			end
			v.f1 = v.f1 + v1;
			ts = true
			-- if _G.isLocalDevelopMode then printx(0, "@@@@@tryDoOrderList", v.key1,v.key2,v.f1, v.v1) end
			if self.PlayUIDelegate then 				-----向UI注册函数发起调用
				local pos_t = self:getGameItemPosInView(r,c);
				local num = v.v1 - v.f1;
				if num < 0 then num = 0; end;

				if p_pos and p_pos.x and p_pos.y then
					pos_t = p_pos
				end



				self.PlayUIDelegate:setTargetNumber(v.key1, v.key2, num, pos_t, rotation);
			end
		end
	end
	return ts;
end

function GameBoardLogic:addReplayStep( item )
	-- body
	if item and self.setWriteReplayEnable then

		table.insert(self.replaySteps, item)
		-- [[
		if isLocalDevelopMode then 
			self:WriteReplay("test.rep")
		end
		--]]

		ReplayDataManager:addReplayStep( item )
	end
end

function GameBoardLogic:ReadReplay(fileName, base)
	if not base then
		base = CCFileUtils:sharedFileUtils():fullPathForFilename("resource")
	end
	local path = base .. "/" .. fileName
	local hFile, err = io.open(path, "r")
	local text
	if hFile and not err then
		text = hFile:read("*a")
		io.close(hFile)
	end

	--local text = Localhost:readFromStorage(path)
	if text then
		return table.deserialize(text)
	end
	return nil
end

--关闭replay
function GameBoardLogic:setWriteReplayOff(  )
	-- body
	self.setWriteReplayEnable = false
end

function GameBoardLogic:getReplayRecordsData()
	-- printx( 1 , "   GameBoardLogic:getReplayRecordsData ")

	--[[
	local replay = {}
	replay.level = self.level
	replay.randomSeed = self.randomSeed
	replay.replaySteps = self.replaySteps
	-- 是否触发神奇掉落规则
	replay.hasDropBuff =  false
	if self.dropBuffLogic and self.dropBuffLogic.canBeTriggered then
		replay.hasDropBuff = true
	end

	replay.ctx = GamePlayContext:getInstance():encodeWeeklyData()
	replay.summerWeeklyData = table.copyValues( self.summerWeeklyData )
	replay.dragonBoatData = table.copyValues( self.dragonBoatData )
	replay.dragonBoatPropConfig = table.copyValues( self.dragonBoatPropConfig )
	replay.selectedItemsData = {}

	if self.selectedItemsData then
		for k, v in pairs(self.selectedItemsData) do 
			local v_r = {}
			v_r.id = v.id
			v_r.destXInWorldSpace = v.destXInWorldSpace
			v_r.destYInWorldSpace = v.destYInWorldSpace
			table.insert(replay.selectedItemsData, v_r)
		end
	end

	if not replay.rid then
		replay.rid = tostring( replay.level ) .. "_" .. tostring( Localhost:timeInSec() )
	end

	ReplayDataManager:setReplayId( replay.rid )
	]]

	local replay = ReplayDataManager:getCurrLevelReplayDataCopyWithoutSectionData()

	--[[
	replay.ctx = GamePlayContext:getInstance():encodeWeeklyData()
	replay.summerWeeklyData = table.copyValues( self.summerWeeklyData )
	replay.dragonBoatData = table.copyValues( self.dragonBoatData )
	replay.dragonBoatPropConfig = table.copyValues( self.dragonBoatPropConfig )
	]]

	return replay
end

function GameBoardLogic:WriteReplay(fileName, base)
	--[[
	if not base then
		base = CCFileUtils:sharedFileUtils():fullPathForFilename("resource")
	end

	local path = HeResPathUtils:getUserDataPath() .. "/" .. fileName
	local text
	if not self.replay then 
		local hFile, err = io.open(path, "r")
		if hFile and not err then
			text = hFile:read("*a")
			io.close(hFile)
		end
		self.allReplay = table.deserialize(text) or {}

		local replay = {}
		replay.level = self.level
		replay.randomSeed = self.randomSeed

		replay.replaySteps = self.replaySteps
		-- 是否触发神奇掉落规则
		replay.hasDropBuff =  false
		if self.dropBuffLogic and self.dropBuffLogic.canBeTriggered then
			replay.hasDropBuff = true
		end

		replay.ctx = GamePlayContext:getInstance():encodeWeeklyData()
		replay.summerWeeklyData = table.copyValues( self.summerWeeklyData )
		replay.dragonBoatData = table.copyValues( self.dragonBoatData )
		replay.dragonBoatPropConfig = table.copyValues( self.dragonBoatPropConfig )
		
		replay.selectedItemsData = {}

		for k, v in pairs(self.selectedItemsData) do 
			local v_r = {}
			v_r.id = v.id
			v_r.destXInWorldSpace = v.destXInWorldSpace
			v_r.destYInWorldSpace = v.destYInWorldSpace
			table.insert(replay.selectedItemsData, v_r)
		end
		table.insert(self.allReplay, replay)
		self.replay = replay

	end
	
	text = table.serialize(self.allReplay)
	Localhost:safeWriteStringToFile(text, path)
	]]
end

function  GameBoardLogic:copyStep()

	local replayData = ReplayDataManager:getCurrLevelReplayData()

	if replayData then
		replayData.sectionData = nil
		replayData.lastSectionData = nil
	end
	ClipBoardUtil.copyTextByCC(table.serialize( replayData ))
end

function GameBoardLogic:setSnapshotModeEnable()
	self.snapshotModeEnable = true
	self.snapshotId = 1
end

function GameBoardLogic:ReplayStart(playMode)
	self.replayError = nil
	self.replaying = true
	self.replayStep = 1
	self.replayMode = playMode
end

function GameBoardLogic:countReplayStep()
	if self.replayStep then
		self.replayStep = self.replayStep + 1
	end
end

function GameBoardLogic:isReplayMode()
	return self.PlayUIDelegate and self.PlayUIDelegate:isReplayMode()
end

function GameBoardLogic:Replay()
	if not self.resumeReplayStartTime then
		self.resumeReplayStartTime = Localhost:timeInSec()
	end
	--printx(1 , "GameBoardLogic:Replay   self.replayStep = " , self.replayStep)
	if self.replayError then -- 发生了错误
		--printx(1 , "GameBoardLogic:Replay   111" )
		self.replaying = false
		if self.PlayUIDelegate and type(self.PlayUIDelegate.onReplayErrorOccurred) == "function" then
			self.PlayUIDelegate:onReplayErrorOccurred(self.replayError)
		end
	else

		local function doSwap(r1, c1, r2, c2, propId)
			self:startTrySwapedItem(r1, c1, r2, c2)
		end

		local function doUseProp(r1, c1, r2, c2, propId , propsUseType)
			--self:startWaitingOperation()

			local usePropResult = nil

			if propId == GamePropsType.kRandomBird then
				local randomBirdPos = self:getPositionForRandomBird()
				usePropResult = self:useProps(propId, randomBirdPos.r , randomBirdPos.c ,r2,c2 , propsUseType)
			elseif propId == GamePropsType.kSpringFirework or propId == GamePropsType.kMoleWeeklyRaceSPProp then
				if self.PlayUIDelegate and self.PlayUIDelegate.propList and self.PlayUIDelegate.propList.rightPropList then
					local rightPropList = self.PlayUIDelegate.propList.rightPropList
					local springItem = rightPropList.springItem
					if springItem then
						if springItem.usedTimes then 
							springItem.usedTimes = springItem.usedTimes + 1
						end
						if springItem.setEnergy and type(springItem.setEnergy) == "function" then 
							springItem:setEnergy(0, false)
						end
					end
					usePropResult = self:useMegaPropSkill()
				else
					usePropResult = self:useMegaPropSkill()
				end
			elseif propId == GamePropsType.kNationDay2017Cast then
				usePropResult = self:useNationDay2017Cast()
            elseif propId >= GamePropsType.kSpringSkill1 and propId <= GamePropsType.kSpringSkill4 then
                usePropResult = self:replaySpringSkill( propId )
			else
				usePropResult = self:useProps(propId, r1,c1,r2,c2,propsUseType)
			end
			
			if self.PlayUIDelegate.replayMode == ReplayMode.kResume 
				or self.PlayUIDelegate.replayMode == ReplayMode.kStrategy 
				or self.PlayUIDelegate.replayMode == ReplayMode.kReview
				then
				self.PlayUIDelegate.propList:addFakeItemForReplay(propId, -1)
			end

			if not usePropResult then
				local runningScene = Director.sharedDirector():getRunningSceneLua()
				if runningScene and runningScene.isCheckReplayScene then
					runningScene:dp(Event.new("replay_error", {msg="use_prop_error"}))
				end
			end
		end

		local function doNextStep()

			local r1 = self.replaySteps[self.replayStep].x1
			local c1 = self.replaySteps[self.replayStep].y1
			local r2 = self.replaySteps[self.replayStep].x2
			local c2 = self.replaySteps[self.replayStep].y2
			local propId = self.replaySteps[self.replayStep].prop
			local propsUseType = self.replaySteps[self.replayStep].pt

			--printx(1 , "GameBoardLogic:Replay   333" )
            if not propId then
				--printx(1 , "GameBoardLogic:Replay   444" )
				if self.replayMode == ReplayMode.kStrategy then 
					LevelStrategyLogic:handGuideSwap(r1, c1, r2, c2, function () doSwap(r1, c1, r2, c2, propId) end)
				else
					doSwap(r1, c1, r2, c2, propId)
				end		
			else
				--printx(1 , "GameBoardLogic:Replay   555" )
				if self.replayMode == ReplayMode.kStrategy then 
					LevelStrategyLogic:handGuideProp(propId, function () doUseProp(r1, c1, r2, c2, propId , propsUseType) end)
				else
					doUseProp(r1, c1, r2, c2, propId , propsUseType)
				end	
			end

			self:countReplayStep()

			if self.PlayUIDelegate.onReplayProgressChanged and type(self.PlayUIDelegate.onReplayProgressChanged) == "function" then
				self.PlayUIDelegate:onReplayProgressChanged( self.replayStep - 1 , #self.replaySteps )
			end
		end

		local function doIndexSwap(index)
			local r1,c1,r2,c2
			if index >= 72 then
				index = index - 72
				r1 = math.floor(index / 9) + 1
				c1 = index % 9 + 1
				r2 = r1 + 1
				c2 = c1
			else
				r1 = math.floor(index / 8) + 1
				c1 = index % 8 + 1
				r2 = r1
				c2 = c1 + 1
			end
			-- he_log_error(r1 .. "-" .. c1 .. "-" .. r2 .. "-" .. c2)
			doSwap(r1, c1, r2, c2, nil)
		end

		local function getActions()
			local possibleSwapList = SwapItemLogic:calculatePossibleSwap(self, nil, true)
			local actions = {}
			for i = 1, #possibleSwapList do 
				local targetPossibleSwap = possibleSwapList[i]
				local r1 = targetPossibleSwap[1].r
				local c1 = targetPossibleSwap[1].c
				local r2 = r1 + targetPossibleSwap["dir"].r
				local c2 = c1 + targetPossibleSwap["dir"].c
				local index = 0
				if r1 == r2 then
					if c1 < c2 then
						index = (r1 - 1) * 8 + c1 - 1
					else
						index = (r2 - 1) * 8 + c2 - 1
					end
				end
				if c1 == c2 then
					if r1 < r2 then
						index = (r1 - 1) * 9 + c1 - 1
					else
						index = (r2 - 1) * 9 + c2 - 1
					end
					index = index + 72
				end
				actions[index] = true
			end
			return actions
		end

		if self.replayMode == ReplayMode.kSectionResume then

			local function dorevert( swapResultFun )
				local dataTable = self.PlayUIDelegate.sectionData
				if dataTable then
					local sectionData = SectionResumeManager:decodeByTable( dataTable )
					return SectionResumeManager:doRevert( sectionData , false , swapResultFun )
				else
					--revert error
					printx( 1 , "SectionResume Error !!!!!!!!!!!!!!!!!!!!")
					--self:startWaitingOperation()
					return 0
				end
			end

			local function replayEnd()
				self.replaying = false

				if self.PlayUIDelegate and type(self.PlayUIDelegate.onReplayEnd) == "function" then
					self.PlayUIDelegate:onReplayEnd()

					local udid = MetaInfo:getInstance():getUdid() or "hasNoUdid"
					DcUtil:crashResumeEnd( 200 , self.PlayUIDelegate.levelId , self.replayStep - 1 , 
						UserManager.getInstance().user.uid , udid , self.PlayUIDelegate.replayData.uid , self.PlayUIDelegate.replayData.udid , self.PlayUIDelegate.replayDataMD5 )--恢复正常结束
				end
			end
			--setTimeOut( dorevert , 3 )

			local function swapResultFun(result)
				replayEnd()
			end

			local dorevertResult = dorevert( swapResultFun )

			if dorevertResult == 2 then
				--last action is swap
			else
				replayEnd()
			end
			
			
			--setTimeOut( replayEnd , 1 )

			return
		end

		--printx(1 , "GameBoardLogic:Replay   222" )
		if self.replayMode == ReplayMode.kAuto or self.replayMode == ReplayMode.kConsistencyCheck_Step1 or self.replayMode == ReplayMode.kAutoPlayCheck then

			if self.replayMode == ReplayMode.kAutoPlayCheck then
				local maxstep = 100
				if self.replayData and self.replayData.maxstep then
					maxstep = self.replayData.maxstep
				end
				if self.realCostMove > maxstep then
					AutoCheckLevelManager:onCheckFinish( false , AutoCheckLevelFinishReason.kOverTooMushStep , self.realCostMove )
					if self.PlayUIDelegate and type(self.PlayUIDelegate.onReplayEnd) == "function" then
						self.PlayUIDelegate:onReplayEnd()
					end
					setTimeOut( function () AutoCheckLevelManager:nextCheck() end , 0.1 )
					return
				end

				if self.levelType == GameLevelType.kMoleWeekly and self.passedRow > 40 then
					AutoCheckLevelManager:onCheckFinish( true , AutoCheckLevelFinishReason.kFinished , self.realCostMove )
					if self.PlayUIDelegate and type(self.PlayUIDelegate.onReplayEnd) == "function" then
						self.PlayUIDelegate:onReplayEnd()
					end
					setTimeOut( function () AutoCheckLevelManager:nextCheck() end , 0.1 )
					return
				end
			end 

			if self.isFullFirework then
				-- doUseProp(0, 0, 0, 0, GamePropsType.kMoleWeeklyRaceSPProp)
				self:useMegaPropSkill( false , false , true , false)
			else
				local possibleSwapList = nil
				if math.random(0,9) < 1 then
					possibleSwapList = SwapItemLogic:calculatePossibleSwap(self, {PossibleSwapPriority.kNormal4})
				end
				if not possibleSwapList or #possibleSwapList == 0 then
					possibleSwapList = SwapItemLogic:calculatePossibleSwap(self)
				end
				local targetPossibleSwap = possibleSwapList[math.random(#possibleSwapList)]
				local r1 = targetPossibleSwap[1].r
				local c1 = targetPossibleSwap[1].c
				local r2 = r1 + targetPossibleSwap["dir"].r
				local c2 = c1 + targetPossibleSwap["dir"].c
				doSwap(r1, c1, r2, c2, nil)
			end
			
			return
		end

		if self.replayMode == ReplayMode.kMcts then
			local simplejson = require("cjson")
			if not self.playout then
				-- local resp = '{"method":"playout"}' 
				local resp = nil
				if not _G.launchCmds.mock then
					local mime = require("mime.core")
					if  _G.__startCmd then
						SectionResumeManager:revertBySerializedSectionData(mime.unb64(_G.__startCmd.snap))
						resp = '{"method":"nextStep", "action":' .. _G.__startCmd.action .. '}'
						if  _G.__startCmd.newSeed then
							resp = '{"method":"nextStep", "action":' .. _G.__startCmd.action .. ', "newSeed":' .. _G.__startCmd.newSeed ..'}'
						end
						_G.__startCmd = nil
					else
						local actions = getActions()
						local req = {
							result = nil,
							score = self.totalScore,
							-- targets = self.PlayUIDelegate.levelTargetPanel:getTargets(),
							actionList = table.keys(actions),
							method = "status",
						}
						if _G.launchCmds.cnn then
							local state = table.serialize(SnapshotManager:getStepState(self))
							state = compress(state)
							state = mime.b64(state)
							req.snap = state
						else
							req.snap = mime.b64(SectionResumeManager:getCurrSerializedSectionData())
						end
						-- he_log_error(table.tostring(req.actionList))
						StartupConfig:getInstance():sendMsg(simplejson.encode(req))
				        resp = StartupConfig:getInstance():receiveMsg()
			        end
			    else
			    	if not self.currentNode then
						self.currentNode = _G.__root
						local nextNode = self.currentNode
						while nextNode.choose do
							nextNode = nextNode.child[nextNode.choose]
						end
						if nextNode.exit then
							self.mctsFinish = true
						end
					elseif not self.currentNode.snap then
						self.currentNode.snap = SectionResumeManager:getCurrSerializedSectionData()
 					end
					if self.expansion then
						resp = '{"method":"playout"}' 
					else
						local preNode = nil
						while self.currentNode.choose do
							-- he_log_error("choose")
							preNode = self.currentNode
							self.currentNode = self.currentNode.child[self.currentNode.choose]
							if not self.currentNode.snap or self.mctsFinish then
								resp = '{"method":"nextStep", "action":' .. preNode.choose ..'}'
								break
							end
						end
						if not resp and self.mctsFinish then
							resp = '{"method":"playout"}' 
						end
						while not resp do
							preNode = self.currentNode
		 					if not self.currentNode.child then
		 						-- he_log_error("init actions")
		 						if not self.isRevert then
									if self.currentNode.snap then
										SectionResumeManager:revertBySerializedSectionData(self.currentNode.snap)
									end
									self.isRevert = true
								end
								self.currentNode.child = {}
								local actions = getActions()
		 						for k, v in pairs(actions) do 
		 							local newChild = {
										parent = self.currentNode,
										child = nil,
										signal = 0,
										success = 0,
										sum = 0
									}
									self.currentNode.child[k] = newChild
									if _G.launchCmds.random then
										newChild.child = {}
										for r = 1, 3 do
											local seed = math.random(1000000)
											-- local seed = r
											newChild.child[#newChild.child + 1] = {
												parent = newChild,
												child = nil,
												signal = 0,
												success = 0,
												seed = seed,
												sum = 0
											}
										end
									end

		 						end
							end
							for k, v in pairs(self.currentNode.child) do 
								if v.sum == 0 then
									-- he_log_error("expand child:" .. k)
									preNode = self.currentNode
									resp = '{"method":"nextStep", "action":' .. k .. '}'
									if _G.launchCmds.random then
										self.currentNode = v.child[math.random(#v.child)]
										seed = self.currentNode.seed
										resp = '{"method":"nextStep", "action":' .. k ..', "newSeed":' .. seed ..'}'
									else
										self.currentNode = v
									end
									self.expansion = true
									break
								end
							end
							if not resp then
								local index = 0
								local maxUct = -1
								for k, v in pairs(self.currentNode.child) do 
									local uct = v.signal / v.sum + math.sqrt(2) * math.sqrt(math.log(self.currentNode.sum) / v.sum)
									if uct > maxUct then
										maxUct = uct
										index = k
									end
								end
								-- he_log_error("uct select:" .. index)
								local chanceNode = self.currentNode.child[index]
								if _G.launchCmds.random then
									self.currentNode = chanceNode.child[math.random(#chanceNode.child)]
								else
									self.currentNode = chanceNode
								end
								if self.currentNode.exit or not self.currentNode.snap then
									if self.currentNode.seed then
										resp = '{"method":"nextStep", "action":' .. index ..', "newSeed":' .. self.currentNode.seed ..'}'
									else
										resp = '{"method":"nextStep", "action":' .. index ..'}'
									end
								end
							end
						end
						if resp then
							if not self.isRevert then
								if preNode.snap then
									SectionResumeManager:revertBySerializedSectionData(preNode.snap)
								end
								self.isRevert = true
							end
						end
					end
				end
				-- he_log_error(resp)
				local cmd = simplejson.decode(resp)
				if cmd.method == "nextStep" then
					if cmd.newSeed then
						self.randFactory:randSeed(cmd.newSeed)
					end
					doIndexSwap(cmd.action)
					return
				elseif cmd.method == "playout" then
					self.playout = true
					if cmd.newSeed then
						self.playoutFactory = RandomFactory:create()
						self.playoutFactory:randSeed(cmd.newSeed)
					end
				else
					he_log_error("you must send nextStep or playout now!")
				end
			end
			if self.playout then
				if _G.launchCmds.cnn then
					local actions = getActions()
					local req = {
						result = nil,
						score = self.totalScore,
						actionList = table.keys(actions),
						method = "status",
					}
					local state = table.serialize(SnapshotManager:getStepState(self))
					state = compress(state)
					state = mime.b64(state)
					req.snap = state
					StartupConfig:getInstance():sendMsg(simplejson.encode(req))
			        resp = StartupConfig:getInstance():receiveMsg()
			        local cmd = simplejson.decode(resp)
			        doIndexSwap(cmd.action)
			        return
			    end

				local possibleSwapList = SwapItemLogic:calculatePossibleSwap(self, nil, true)
				local index = 0
				if self.playoutFactory then
					index = self.playoutFactory:rand(1, #possibleSwapList)
				else
					index = math.random(#possibleSwapList)
				end
				local targetPossibleSwap = possibleSwapList[index]
				local r1 = targetPossibleSwap[1].r
				local c1 = targetPossibleSwap[1].c
				local r2 = r1 + targetPossibleSwap["dir"].r
				local c2 = c1 + targetPossibleSwap["dir"].c
				doSwap(r1, c1, r2, c2, nil)
			end
			return
		end

		if self.replayStep == #self.replaySteps and self.replayMode == ReplayMode.kResume then
			self.isCrashResumeDone = true
		end

		if self.replayStep <= #self.replaySteps then
			if SectionResumeManager:isTestDemoForAIEnable() then
				if self.replayStep >= SectionResumeManager:getTestDemoForAIEndStep() then

					SectionResumeManager:addTestDemoForAICount()
					local testCount = SectionResumeManager:getTestDemoForAICount()
					
					printx( 0 , "=======================  TestDemoForAI  ===============================" )
					printx( 0 , "count:" , testCount)
					printx( 0 , "theCurMoves:" , self.theCurMoves , "score:" , self.totalScore)
					printx( 0 , "=======================================================================" )
					CommonTip:showTip( "TestDemoForAI " .. tostring(testCount) ..  "   " ..  tostring(self.totalScore) )

					local function doRevert()
						SectionResumeManager:doRevertByIndex( SectionResumeManager:getTestDemoForAIStartStep() , 1 )
					end

					local function goOn()
						self.replayStep = SectionResumeManager:getTestDemoForAIStartStep()
						--self:startWaitingOperation()
					end
					setTimeOut( doRevert , 1 )
					setTimeOut( goOn , 2 )

				elseif not SectionResumeManager:getIsReverting() then
					doNextStep()
				end
			else
				if not SectionResumeManager:getIsReverting() then

					if self.replayMode == ReplayMode.kReview then

						local function reviewNextStep( ... )
							if self.isDisposed then return end
							doNextStep()
						end

						local function reviewNextStepError( errNsg )
							UserReviewLogic:onReplayError()
							-- self:setGamePlayStatus(GamePlayStatus.kFailed)

						end

						UserReviewLogic:onWaitingNextStep(self, reviewNextStep, reviewNextStepError)
					else
						doNextStep()
					end
				end
			end
		else
			--self:startWaitingOperation()
			--printx(1 , "GameBoardLogic:Replay   666" )
			if self.replayMode == ReplayMode.kStrategy then 
				if self.PlayUIDelegate and type(self.PlayUIDelegate.onReplayEnd) == "function" then
					self.PlayUIDelegate:onReplayEnd()
				end
			elseif self.replayMode == ReplayMode.kReview then
				if self.PlayUIDelegate and type(self.PlayUIDelegate.onReplayEnd) == "function" then
					self.PlayUIDelegate:onReplayEnd()
				end
				if self.PlayUIDelegate and type(self.PlayUIDelegate.replayResult) == "function" then
					self.PlayUIDelegate:replayResult(self.PlayUIDelegate.levelId, 0, 0, 0, 0, 0, false, '')
				end
			elseif (self.gameMode:is(ClassicMode) or self.gameMode:is(MaydayEndlessMode)) and self.replayMode ~= ReplayMode.kResume then
				--printx(1 , "GameBoardLogic:Replay   777" )
				self:setGamePlayStatus(GamePlayStatus.kEnd)
			else
				--printx(1 , "GameBoardLogic:Replay   888" )
				--self:checkCanMoveItem(0)
				self.replaying = false
				if self.PlayUIDelegate and type(self.PlayUIDelegate.onReplayEnd) == "function" then
					self.PlayUIDelegate:onReplayEnd()

					local udid = MetaInfo:getInstance():getUdid() or "hasNoUdid"
					DcUtil:crashResumeEnd( 200 , self.PlayUIDelegate.levelId , self.replayStep - 1 , 
						UserManager.getInstance().user.uid , udid , self.PlayUIDelegate.replayData.uid , self.PlayUIDelegate.replayData.udid , self.PlayUIDelegate.replayDataMD5 )--恢复正常结束
				end
				local ttt = Localhost:timeInSec() - self.resumeReplayStartTime
				--CommonTip:showTip("耗时：" .. tostring(ttt) , "negative", nil, 30)
				self.resumeReplayStartTime = nil
			end
		end
	end
end

function GameBoardLogic:checkReplayCanUseAddStep()
	-- printx( 1 , "GameBoardLogic:checkReplayCanUseAddStep !!!!!!!!!!!!!" )

	if self.replayMode == ReplayMode.kSectionResume then
		return false
	end

	if self.replaySteps and self.replaySteps[self.replayStep] then
		local maxStep = #self.replaySteps
		for i=self.replayStep, maxStep do
			local data = self.replaySteps[i]
			if data.prop and (tonumber(data.prop) == GamePropsType.kAdd5 or 
								tonumber(data.prop) == GamePropsType.kBombAdd5 or 
								tonumber(data.prop) == ItemType.TIMELIMIT_ADD_FIVE_STEP or 
								tonumber(data.prop) == ItemType.TIMELIMIT_ADD_BOMB_FIVE_STEP or 
								tonumber(data.prop) == ItemType.TIMELIMIT_48_ADD_BOMB_FIVE_STEP or 
								tonumber(data.prop) == ItemType.ADD_1_STEP or 
								tonumber(data.prop) == ItemType.ADD_2_STEP or 
								tonumber(data.prop) == ItemType.ADD_15_STEP) 
			then

				-- printx( 1 , "GameBoardLogic:checkReplayCanUseAddStep i =" , i , "maxStep =" , maxStep , "data =" , table.tostring(data) )
				return true, data.prop
			end
		end
	end
	return false
end

function GameBoardLogic:getGameItemPosInView_ForPreProp(r, c)
	self.posAdd = self.posAdd or ccp(0, 0)
	local tempX = (c - 0.5) * GamePlayConfig_Tile_Width
	local tempY = (GamePlayConfig_Max_Item_Y - r - 0.5 ) * GamePlayConfig_Tile_Height
	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	return ccp(tempX * GamePlayConfig_Tile_ScaleX + self.posAdd.x - visibleOrigin.x,
		tempY * GamePlayConfig_Tile_ScaleY + self.posAdd.y - visibleOrigin.y)
end

function GameBoardLogic:getGameItemPosInView(r, c)
	self.posAdd = self.posAdd or ccp(0, 0)
	local tempX = (c - 0.5) * GamePlayConfig_Tile_Width
	local tempY = (GamePlayConfig_Max_Item_Y - r - 0.5 ) * GamePlayConfig_Tile_Height
	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	return self.boardView:convertToWorldSpace(ccp(tempX, tempY))
end

-- 确定两个方块是否相邻
function GameBoardLogic:tileNextToEachOther(r1, c1, r2, c2)
	if not r1 or r1 <= 0 or r1 > #self.gameItemMap or not r2 or r2 <= 0 or r2 > #self.gameItemMap or
		not c1 or c1 <= 0 or c1 > #self.gameItemMap[r1] or not c2 or c2 <= 0 or c2 > #self.gameItemMap[r2] then
		return false
	end
	return (r1 == r2 and math.abs(c1 - c2) == 1) or (c1 == c2 and math.abs(r1 - r2) == 1)
end


function GameBoardLogic:isPosUsedByPreProp(x, y)
	local index = x*10+y
	return self.pre_prop_pos[index] == true
end

function GameBoardLogic:usePosForPreProp(x, y)
	local index = x*10+y
	self.pre_prop_pos[index] = true
end

function GameBoardLogic:preGameProp(propID, animCallback)

	local user = UserManager:getInstance():getUserRef()
	local stageInfo = StageInfoLocalLogic:getStageInfo(user.uid)
	if stageInfo then
		if propID and propID ~= 10015 then
			stageInfo:addUsePropLog(propID + 1000000)
		end
	end

	if propID == GamePropsType.kWrap_b
	or propID == GamePropsType.kWrapBomb_b
	or propID == GamePropsType.kBuffBoom_b
	or propID == GamePropsType.kRandomBird_b
	or propID == GamePropsType.kLineBomb_b then
		-- local y1, x1, t1, y2, x2, t2
		-- local validTargetItemList = {}
		-- local validCrystalList = {}
		-- for r = 1, #self.gameItemMap do
		-- 	for c = 1, #self.gameItemMap[r] do
		-- 		local item = self.gameItemMap[r][c]
		-- 		local board = self.boardmap[r][c]
		-- 		if item.isUsed 
		-- 			and item.ItemSpecialType == 0
		-- 			and item:isAvailable()
		-- 			and board.lotusLevel < 2
		-- 			then
		-- 			-- 防止多个前置道具使用相同的坐标
		-- 			if not self:isPosUsedByPreProp(r, c) then
		-- 				if item.ItemType == GameItemType.kAnimal then 
		-- 					table.insert(validTargetItemList, {r = r, c = c})
		-- 				elseif item.ItemType == GameItemType.kCrystal then
		-- 					table.insert(validCrystalList, {r = r, c = c})
		-- 				end
		-- 			end
					
		-- 		end
		-- 	end
		-- end	

		-- if #validTargetItemList + #validCrystalList >= 1 then
		-- 	local idx1, pos1, idx2, pos2
		-- 	if #validTargetItemList >= 2 then
		-- 		idx1 =self.prePropRandFactory:rand(1,#validTargetItemList)
		-- 		pos1 = validTargetItemList[idx1]
		-- 		table.remove(validTargetItemList, idx1)
		-- 		idx2 = self.prePropRandFactory:rand(1,#validTargetItemList)
		-- 		pos2 = validTargetItemList[idx2]
		-- 	elseif #validTargetItemList == 1 then 
		-- 		pos1 = validTargetItemList[1]
		-- 		if #validCrystalList == 0 then 
		-- 			pos2 = pos1
		-- 		else
		-- 			idx2 =  self.prePropRandFactory:rand(1,#validCrystalList)
		-- 			pos2 = validCrystalList[idx2]
		-- 		end
				
		-- 	else
		-- 		idx1 =  self.prePropRandFactory:rand(1,#validCrystalList)
		-- 		pos1 = validCrystalList[idx1]
		-- 		table.remove(validCrystalList, idx1)
		-- 		if #validCrystalList == 0 then 
		-- 			pos2 = pos1
		-- 		else
		-- 			idx2 =  self.prePropRandFactory:rand(1,#validCrystalList)
		-- 			pos2 = validCrystalList[idx2]
		-- 		end
				
		-- 	end

		-- 	x1 = pos1.c
		-- 	y1 = pos1.r
		-- 	x2 = pos2.c
		-- 	y2 = pos2.r

		-- 	if propID == GamePropsType.kWrap_b then

		-- 		local lineColumnRandList = {AnimalTypeConfig.kLine, AnimalTypeConfig.kColumn}
		-- 		t1 = lineColumnRandList[self.prePropRandFactory:rand(1, 2)]
		-- 		t2 = AnimalTypeConfig.kWrap

		-- 		local function finishColorBrush_b()
		-- 			self.gameItemMap[y1][x1].ItemType = GameItemType.kAnimal
		-- 			self.gameItemMap[y2][x2].ItemType = GameItemType.kAnimal
		-- 			self.gameItemMap[y1][x1]:changeItemType(self.gameItemMap[y1][x1]._encrypt.ItemColorType, t1)
		-- 			self.gameItemMap[y2][x2]:changeItemType(self.gameItemMap[y2][x2]._encrypt.ItemColorType, t2)
		-- 			self.gameItemMap[y1][x1].isNeedUpdate = true
		-- 			self.gameItemMap[y2][x2].isNeedUpdate = true
		-- 			if self.boardView then
		-- 				self.boardView:updateItemViewByLogic()			----界面展示刷新
		-- 				self.boardView:updateItemViewSelf()				----界面自我刷新
		-- 			end
		-- 		end
					
		-- 		if self.PlayUIDelegate then
		-- 			local lineData = { type = t1,r = y1, c = x1, pos = self:getGameItemPosInView_ForPreProp(y1, x1) }
		-- 			local wrapData = { type = t2,r = y2, c = x2, pos = self:getGameItemPosInView_ForPreProp(y2, x2) }
		-- 			self:usePosForPreProp(y1, x1)
		-- 			self:usePosForPreProp(y2, x2)
		-- 			animCallback(propID, lineData,wrapData,finishColorBrush_b)
		-- 		else
		-- 			finishColorBrush_b()
		-- 		end
		-- 	else
		-- 		local lineColumnRandList = {AnimalTypeConfig.kLine, AnimalTypeConfig.kColumn}
		-- 		t1 = lineColumnRandList[self.prePropRandFactory:rand(1, 2)]
		-- 		t2 = AnimalTypeConfig.kWrap

		-- 		local lineData = nil
		-- 		local wrapData = nil
		-- 		local function finish()
		-- 			if propID == GamePropsType.kWrapBomb_b then
		-- 				self.gameItemMap[y1][x1].ItemType = GameItemType.kAnimal
		-- 				self.gameItemMap[y1][x1]:changeItemType(self.gameItemMap[y1][x1]._encrypt.ItemColorType, t2)
		-- 				self.gameItemMap[y1][x1].isNeedUpdate = true
		-- 			elseif propID == GamePropsType.kLineBomb_b then
		-- 				self.gameItemMap[y1][x1].ItemType = GameItemType.kAnimal
		-- 				self.gameItemMap[y1][x1]:changeItemType(self.gameItemMap[y1][x1]._encrypt.ItemColorType, t1)
		-- 				self.gameItemMap[y1][x1].isNeedUpdate = true
		-- 			end
		-- 			if self.boardView then
		-- 				self.boardView:updateItemViewByLogic()			----界面展示刷新
		-- 				self.boardView:updateItemViewSelf()				----界面自我刷新
		-- 			end
		-- 		end
		-- 		if self.PlayUIDelegate then
		-- 			if propID == GamePropsType.kWrapBomb_b then
		-- 				wrapData = { type = t2,r = y1, c = x1, pos = self:getGameItemPosInView_ForPreProp(y1, x1) }
		-- 				self:usePosForPreProp(y1, x1)
		-- 			elseif propID == GamePropsType.kLineBomb_b then
		-- 				lineData = { type = t1,r = y1, c = x1, pos = self:getGameItemPosInView_ForPreProp(y1, x1) }
		-- 				self:usePosForPreProp(y1, x1)
		-- 			end
		-- 			animCallback(propID, lineData,wrapData,finish)
		-- 		else
		-- 			finish()
		-- 		end
		-- 	end
		-- else
		-- 	animCallback(propID)
		-- end

	elseif propID == GamePropsType.kRefresh_b then
		-- 纯界面道具，无动作
	elseif propID == GamePropsType.kAdd3_b then
		self.gameMode:getAddSteps(3)
	end
end

function GameBoardLogic:isPosValid(r, c)
	return r > 0 and r <= #self.gameItemMap and c > 0 and c <= #self.gameItemMap[r] 
end

function GameBoardLogic:getGameItemAt(r, c)
	if self:isPosValid(r, c) then
		return self.gameItemMap[r][c]
	end
	return nil
end

function GameBoardLogic:getIngredientsOnScreen( ... )
	-- body
	local result = 0
	for r = 1, #self.gameItemMap do 
		for c = 1, #self.gameItemMap[r] do 
			if self.gameItemMap[r][c].ItemType == GameItemType.kIngredient then 
				result = result + 1
			end
		end
	end
	return result - self.toBeCollected
end

function GameBoardLogic:getItemAmountByItemType(itemType, specialType, otherInfo, bIncludeDoubleSide)
	local function getCount(item, itemType, specialType, otherInfo)
		if item.ItemType == itemType then 
			if otherInfo then
				if item.ItemType == GameItemType.kPuffer then
					if item.pufferState == otherInfo then
						return 1
					end
				elseif item.ItemType == GameItemType.kBlocker195 then
					if item.subtype == otherInfo then
						return 1
					end
				end
			elseif specialType then
				if (item.ItemSpecialType == specialType) then
					return 1
				end
			else
				return 1
			end
		end

		return 0
	end

	local result = 0
	for r = 1, #self.gameItemMap do 
		for c = 1, #self.gameItemMap[r] do 
			local item = self.gameItemMap[r][c]
			local board = self.boardmap[r][c]

			result = result + getCount(item, itemType, specialType, otherInfo)
			if bIncludeDoubleSide and board:isDoubleSideTileBlock() then--计算包含双面翻转地格后面的障碍
				item = self.backItemMap[r][c]
				result = result + getCount(item, itemType, specialType, otherInfo)
			end
		end
	end
	return result
end

function GameBoardLogic:getFurballAmout( furballType )
	-- body
	local result = 0
	for r = 1, #self.gameItemMap do 
		for c = 1, #self.gameItemMap[r] do 
			if self.gameItemMap[r][c].furballType == furballType then 
				result = result + 1
			end
		end
	end
	return result
end

function GameBoardLogic:testEmpty()
	if true then return end
	-- printx( 1 , "   ======================================================")
	-- printx( 1 , "   ======================================================")
	-- printx( 1 , "   ============   GameBoardLogic:testEmpty   ============")
	-- printx( 1 , "   ======================================================")
	-- printx( 1 , "   ======================================================")
	local format = "item status map\n"
	--[[
	printx( 1 , "   AnimalTypeConfig.kBlue = " , tostring(AnimalTypeConfig.kBlue))
	printx( 1 , "   AnimalTypeConfig.kGreen = " , tostring(AnimalTypeConfig.kGreen))
	printx( 1 , "   AnimalTypeConfig.kOrange = " , tostring(AnimalTypeConfig.kOrange))
	printx( 1 , "   AnimalTypeConfig.kPurple = " , tostring(AnimalTypeConfig.kPurple))
	printx( 1 , "   AnimalTypeConfig.kRed = " , tostring(AnimalTypeConfig.kRed))
	printx( 1 , "   AnimalTypeConfig.kYellow = " , tostring(AnimalTypeConfig.kYellow))
	printx( 1 , "   AnimalTypeConfig.kDrip = " , tostring(AnimalTypeConfig.kDrip))
	]]
	for r=1,#self.gameItemMap do
		format = format.. "| "
		for c=1,#self.gameItemMap[r] do
			local item = self.gameItemMap[r][c]
			local board = self.boardmap[r][c]
			local p1 = item.ItemType
			-- local p2 = AnimalTypeConfig.convertColorTypeToIndex(item._encrypt.ItemColorType) or 0
			local p2 = board.gravitySkin
			local p3 = item.ItemStatus

			--if item:isAvailable() then p2 = "1" end
	 		--format = format .. p2 .. "-" .. item.ItemStatus .. "-" .. item.furballLevel .. "   "
	 		format = format .. tostring(board.gravity) .. "_" .. tostring(p2) .. "     "
		end

		format = format .. " | "

	-- 	-- for c=1,#self.gameItemMap[r] do
	 	
	-- 	-- end
		format = format .. "\n"
	end
	-- format = format .. "\nboard status map\n"
	-- for r = 1, #self.boardmap do
	-- 	for c = 1, #self.boardmap[r] do
	-- 		local board = self.boardmap[r][c]
	-- 		local flag = 0 
	-- 		if board.isMoveTile then flag = 1 end
	-- 		format = format .. string.format("%02d", flag) .. " "
	-- 	end
	-- 	format = format .. " | "
	-- 	format = format .. "\n"
	-- end
	-- mylog(format)
	-- debug.debug()
	if _G.isLocalDevelopMode then printx(-6, format) end
end

function GameBoardLogic:testItem()
	local r = 3
	local c = 2
	local item = self.gameItemMap[r][c]
	local itemView = self.boardView.baseMap[r][c]
	local dClipPos = nil
	if itemView.itemSprite[ItemSpriteType.kDisappearClipping] then
		dClipPos = itemView.itemSprite[ItemSpriteType.kDisappearClipping]:getPosition().y
		dClipPos = string.format("%0.1f", dClipPos)
	end

	if(isLocalDevelopMode) then
		print("item itemShow clippingUp " 
			.. tostring(itemView:getItemSprite(ItemSpriteType.kItem) ~= nil) .. " "
			.. tostring(itemView:getItemSprite(ItemSpriteType.kItemShow) ~= nil) .. " "
			.. tostring(itemView:getItemSprite(ItemSpriteType.kDisappearClipping) ~= nil) .. " "
			.. tostring(dClipPos)
			)
	end
end

function GameBoardLogic:quitLevel()
	local replayData = self:getReplayRecordsData()
	if replayData then
		replayData.sectionData = nil
		replayData.lastSectionData = nil
	end
	local opLog = table.serialize(replayData) 

	local targetCount = 0
	if self.theGamePlayType == GameModeTypeId.RABBIT_WEEKLY_ID then
		targetCount = self.rabbitCount:getValue()
	elseif self.levelType == GameLevelType.kMoleWeekly then
		local finalAmount = MoleWeeklyRaceLogic:getFinalAmountForJewel(self)
		targetCount = finalAmount..","..self.yellowDiamondCount:getValue()
	end

	if self.PlayUIDelegate then
		self.PlayUIDelegate:sendQuitLevelMessage(self.level, self.totalScore, self.gameMode:getScoreStarLevel(), math.floor(self.timeTotalUsed), self:getGainCoinNumber(self.level, self.coinDestroyNum), targetCount, opLog)
	end
end

function GameBoardLogic:getForbiddenOctopus()
	local result = {}
	for r = 1, #self.gameItemMap do
		for c = 1, #self.gameItemMap[r] do 
			local item = self.gameItemMap[r][c]
			local board = self.boardmap[r][c]
			if item.ItemType == GameItemType.kPoisonBottle and item.forbiddenLevel > 0 
					and not item:hasActiveSuperCuteBall() and not board.isReverseSide then
				local data 
				if board.colorFilterBLevel > 0 then 
					data = table.clone(item)
					data.isColorFilterBCover = true
				else
					data = item
				end
				table.insert(result, data)
			end
		end
	end
	return result
end

-- 是否有某一类型的item, 类型来自GameItemType
function GameBoardLogic:hasItemOfType(itemType)
	for r = 1, #self.gameItemMap do
		for c = 1, #self.gameItemMap[r] do 
			local item = self.gameItemMap[r][c]
			if item.ItemType == itemType then
				return true
			end
		end
	end

	for i = 1 , 9 do
		if self.backItemMap[i] then
			for j = 1 , 9 do 
				local item = self.backItemMap[i][j]
				if item and item.ItemType == itemType then
					return true
				end
			end
		end
	end

	return false
end

function GameBoardLogic:getItemAmountOfType(itemType, isFurball, isGhost)
	local itemAmount = 0
	local item
	for r = 1, #self.gameItemMap do
		for c = 1, #self.gameItemMap[r] do 
			item = self.gameItemMap[r][c]
			if item then
				if (not isFurball and not isGhost and (item.ItemType == itemType)) 
					or (isFurball and item.furballType == itemType) 
					or (isGhost and item:seizedByGhost())
					then
					itemAmount = itemAmount + 1
				end
			end
		end
	end

	for i = 1 , 9 do
		if self.backItemMap[i] then
			for j = 1 , 9 do 
				item = self.backItemMap[i][j]
				if item then
					if (not isFurball and not isGhost and (item.ItemType == itemType)) 
						or (isFurball and item.furballType == itemType) 
						or (isGhost and item:seizedByGhost())
						then
						itemAmount = itemAmount + 1
					end
				end
			end
		end
	end

	return itemAmount
end

function GameBoardLogic:areaDevidedByRope(x, y, xEnd, yEnd)
	local boardmap = self.boardmap
	local firstRow, lastRow = y, yEnd
	local firstCol, lastCol = x, xEnd

	local isDevided = false
	for r = y, yEnd do 
		if boardmap[r] then 
			for c = x, xEnd do
				local item = boardmap[r][c]
					
				if item then
					if r == firstRow then
						if c == firstCol then -- 左上角
							if lastCol > firstCol and item:hasRightRope() then
								isDevided = true
							end

							if lastRow > firstRow and item:hasBottomRope() then
								isDevided = true
							end
							--[[
							if item:hasBottomRope() or item:hasRightRope() then
								isDevided = true
							end
							]]
						elseif c == lastCol then -- 右上角
							if lastCol > firstCol and item:hasLeftRope() then
								isDevided = true
							end

							if lastRow > firstRow and item:hasBottomRope() then
								isDevided = true
							end
							--[[
							if item:hasBottomRope() or item:hasLeftRope() then
								isDevided = true
							end
							]]
						else
							if lastCol > firstCol and ( item:hasLeftRope() or item:hasRightRope() ) then
								isDevided = true
							end

							if lastRow > firstRow and item:hasBottomRope() then
								isDevided = true
							end
							--[[
							if item:hasLeftRope() or item:hasRightRope() or item:hasBottomRope() then
								isDevided = true
							end
							]]
						end
					elseif r == lastRow then
						if c == firstCol then -- 左下角
							if lastCol > firstCol and item:hasRightRope() then
								isDevided = true
							end

							if lastRow > firstRow and item:hasTopRope() then
								isDevided = true
							end
							--[[
							if item:hasTopRope() or item:hasRightRope() then
								isDevided = true
							end
							]]
						elseif c == lastCol then -- 右下角
							if lastCol > firstCol and item:hasLeftRope() then
								isDevided = true
							end

							if lastRow > firstRow and item:hasTopRope() then
								isDevided = true
							end
							--[[
							if item:hasTopRope() or item:hasLeftRope() then
								isDevided = true
							end
							]]
						else
							if lastCol > firstCol and ( item:hasLeftRope() or item:hasRightRope() ) then
								isDevided = true
							end

							if lastRow > firstRow and item:hasTopRope() then
								isDevided = true
							end
							--[[
							if item:hasTopRope() or item:hasLeftRope() or item:hasRightRope() then
								isDevided = true
							end
							]]
						end
					else
						if c == firstCol then -- 第一列
							if lastCol > firstCol and item:hasRightRope() then
								isDevided = true
							end

							if lastRow > firstRow and ( item:hasTopRope() or item:hasBottomRope() ) then
								isDevided = true
							end
							--[[
							if item:hasTopRope() or item:hasRightRope() or item:hasBottomRope() then
								isDevided = true
							end
							]]
						elseif c == lastCol then -- 最后一列
							if lastCol > firstCol and item:hasLeftRope() then
								isDevided = true
							end

							if lastRow > firstRow and ( item:hasTopRope() or item:hasBottomRope() ) then
								isDevided = true
							end
							--[[
							if item:hasTopRope() or item:hasLeftRope() or item:hasBottomRope() then
								isDevided = true
							end
							]]
						else
							if lastCol > firstCol and ( item:hasLeftRope() or item:hasRightRope() ) then
								isDevided = true
							end

							if lastRow > firstRow and ( item:hasTopRope() or item:hasBottomRope() ) then
								isDevided = true
							end
							--[[
							if item:hasRope() then
								isDevided = true
							end
							]]
						end
					end

					if isDevided then
						return true
					end
				end
			end
		end
	end
	return false
end

function GameBoardLogic:getPositionForRandomBird()
	local list = {}
	local function isNormal(item)
        if item.ItemType == GameItemType.kAnimal
        and item.ItemSpecialType == 0 -- not special
        and item:isAvailable()
        and not item:hasLock() 
        and not item:hasFurball()
        then
            return true
        end
        return false
    end
	for r=1, #self.gameItemMap do
		for c = 1, #self.gameItemMap[r] do
			local item = self.gameItemMap[r][c]
			if item and isNormal(item) then
				table.insert(list, {r = r, c = c})
			end
		end
	end


	local selector = self.randFactory:rand(1, #list)
	local selected = list[selector]

	if _G.isLocalDevelopMode then printx(0, table.tostring(selected)) end
	return selected
end

function GameBoardLogic:getMoleWeeklyBossData()
	return self.moleBossData
end

function GameBoardLogic:getLevelTargetGlobalPosition(id)
	local position = nil
	if self.PlayUIDelegate and self.PlayUIDelegate.levelTargetPanel then
		local levelTargetPanel = self.PlayUIDelegate.levelTargetPanel
		local targetItem = levelTargetPanel["c"..tostring(id)]
		if targetItem then
			local icon = targetItem.icon
			if icon and icon:getParent() then
				position = icon:getParent():convertToWorldSpace(icon:getPosition())
			end
		end
	end
	return position
end

function GameBoardLogic:getHalloweenBossLevelTargetPosition()
	local c1IconPosInScene = nil
	if self.PlayUIDelegate then
		local levelTargetPanel = self.PlayUIDelegate.levelTargetPanel
		if levelTargetPanel and levelTargetPanel.c1 then
			local c1Icon = levelTargetPanel.c1.icon
			if c1Icon and not c1Icon.isDisposed then
				local c1IconPos = c1Icon:getParent():convertToWorldSpace(c1Icon:getPosition())
				local scene = Director:sharedDirector():getRunningScene()
				c1IconPosInScene = scene:convertToNodeSpace(c1IconPos)
			end
		end
	end

	if not c1IconPosInScene then
		c1IconPosInScene = ccp(0,0)
	end
	return c1IconPosInScene
end

function GameBoardLogic:onMoleWeeklyBossDie(diePosition)
	local boss = self.moleBossData
	if not boss then return end
	
	self.maydayBossCount = self.maydayBossCount + 1
	if self.gameMode.onBossDie then
		self.gameMode:onBossDie()
	end

	if self.PlayUIDelegate then
--        setTimeOut(function ( ... )
--            if not self.isDisposed then
                local count = boss.dropItemsOnDie
	            self.digJewelCount:setValue(self.digJewelCount:getValue() + count)
		        local position = diePosition or ccp(0, 0)
		        self.PlayUIDelegate:setTargetNumber(0, 1, self.digJewelCount:getValue(), position, nil, true)
--            end
--         end, 2)
	end

	self.moleBossData = nil
end

function GameBoardLogic:addDigJewelCountWhenBossDie(addCount , fromPosition)
	self.digJewelCount:setValue(self.digJewelCount:getValue() + addCount)
	if self.PlayUIDelegate then
		local position = fromPosition or ccp(0, 0)
		for k = 1, addCount do 
			self.PlayUIDelegate:setTargetNumber(0, 1, self.digJewelCount:getValue(), position)
		end
	end
end

function GameBoardLogic:initMoleWeeklyBoss(bossConfig)
	if not bossConfig then return end
	self.moleBossData = 
	{
		totalBlood = bossConfig.blood, 
		dropItemsOnDie = bossConfig.demolishReward, 
		bossReleaseSkillGap = bossConfig.releaseSkillGap,
		bossGroupID = bossConfig.groupID,		--分组序号
		cA = bossConfig.cA,		--技能参数
		cB = bossConfig.cB,
		cC = bossConfig.cC,
		f = bossConfig.f,
		m = bossConfig.m,
		s = bossConfig.s,
		t = bossConfig.t,
		hit = 0, 
		bossLastReleaseSkillStep = self.realCostMove,	--从每一个boss的产生之时开始计算步数
		bossFirstSkillReleased = false,		--每个Boss的第一个技能有些特殊处理
		bossSkillHRoundCount = 0,			--特殊技能所需的轮次记录
		--目前没用的分界线
		normalHit = 1,
		specialHit = 1,
	}
end

local magicTileIdCounter = 0
local function getMagicTileId()
    magicTileIdCounter = magicTileIdCounter + 1
    return magicTileIdCounter
end


function GameBoardLogic:updateAllMagicTiles(boardmap)
    local boardmap = boardmap or self.boardmap
    for r = 1, #boardmap do 
        for c = 1, #boardmap[r] do 
            local item = boardmap[r][c]
            if item then
                if item.isMagicTileAnchor then
                    -- 如果没有初始化
                    if item.magicTileId == nil then
                        local id = getMagicTileId()
                        item.magicTileId = id
                        local currMagicTileIndex = 1
                        item.magicTileIndex = currMagicTileIndex
                        item.remainingHit = MoleWeeklyRaceParam.MAGIC_TILE_MAX_LIFE --GameBoardDataConfig.magicTileMaxLife
                        item.magicTileDisabledRound = 0
                        for i = r, r + 1 do 
                            for j = c, c + 2 do
                            	if boardmap[i] then
	                                local otherItem = boardmap[i][j]
	                                if otherItem then
	                                    otherItem.magicTileId = id
	                                    currMagicTileIndex = currMagicTileIndex + 1
	                                    otherItem.magicTileIndex = currMagicTileIndex
	                                end
	                            end
                            end
                        end
                    else
                    	local id = item.magicTileId
                    	local currMagicTileIndex = 1
                    	for i = r, r + 1 do 
                            for j = c, c + 2 do
                            	if boardmap[i] then
	                                local otherItem = boardmap[i][j]
	                                if otherItem then
	                                    otherItem.magicTileId = id
	                                    otherItem.magicTileIndex = currMagicTileIndex
	                                    currMagicTileIndex = currMagicTileIndex + 1
	                                end
	                            end
                            end
                        end
                    end
                end
            end
        end
    end
end

function GameBoardLogic:useNationDay2017Cast()
	self.gameMode.encryptData.bombNum = self.gameMode.encryptData.bombNum - 1
	return self:useProps(GamePropsType.kNationDay2017Cast)
end

function GameBoardLogic:useMegaPropSkill(notUseEnergy, noReplayRecord, updateEnergyView, noSectionResumeRecord)
	if not notUseEnergy then 
		self.fireworkEnergy = 0
		self.isFullFirework = false
		if updateEnergyView then
			self.PlayUIDelegate:setFireworkEnergy(self.fireworkEnergy)
		end
	end
	
	if self.levelType == GameLevelType.kMoleWeekly then
		return self:useProps(GamePropsType.kMoleWeeklyRaceSPProp, nil, nil, nil, nil, nil, nil, noReplayRecord, noSectionResumeRecord)
	else	--self.levelType == GameLevelType.kSummerWeekly
		return self:useProps(GamePropsType.kSpringFirework, nil, nil, nil, nil, nil, nil, noReplayRecord)
	end
end

function GameBoardLogic:chargeFirework(count, r, c)
	if self.forbidChargeFirework then return end

	self.fireworkEnergy = self.fireworkEnergy + count
	if self.PlayUIDelegate then
		-- if _G.isLocalDevelopMode then printx(0, "@@@@@@@@@@@@@@@fireworkEnergy updated: ", self.fireworkEnergy) end
		self.PlayUIDelegate:setFireworkEnergy(self.fireworkEnergy)
		self.PlayUIDelegate:playSpringCollectEffect(self:getGameItemPosInView(r, c))
	end
	if self.fireworkEnergy >= self.PlayUIDelegate:getFireworkEnergy() then
		self.isFullFirework = true
	end
end

function GameBoardLogic:onProduceQuestionMark(r, c)
    self.firstProduceQuestionMark = true
end

-- for new dc use
function GameBoardLogic:getStageIndex()
	return self.gameMode:getStageIndex()
end

-- for new dc use
function GameBoardLogic:getStageMoveLimit()
	return self.gameMode:getStageMoveLimit()
end

function GameBoardLogic:hasChainInNeighbors(r1, c1, r2, c2)
	if not self:isPosValid(r1, c1) or not self:isPosValid(r2, c2) then
		return false
	end

	local deltaR = r2 - r1
	local deltaC = c2 - c1
	local borad1 = self.boardmap[r1][c1]
	local borad2 = self.boardmap[r2][c2]
	if deltaC == 1 then
		return borad1:hasChainInDirection(ChainDirConfig.kRight) or borad2:hasChainInDirection(ChainDirConfig.kLeft)
	elseif deltaC == -1 then
		return borad1:hasChainInDirection(ChainDirConfig.kLeft) or borad2:hasChainInDirection(ChainDirConfig.kRight)
	elseif deltaR == 1 then
		return borad1:hasChainInDirection(ChainDirConfig.kDown) or borad2:hasChainInDirection(ChainDirConfig.kUp)
	elseif deltaR == -1 then
		return borad1:hasChainInDirection(ChainDirConfig.kUp) or borad2:hasChainInDirection(ChainDirConfig.kDown)
	end
	return false
end

function GameBoardLogic:isTheSameMatchData(r1, c1, r2, c2)
	if not self.swapHelpMap or not self:isPosValid(r1, c1) or not self:isPosValid(r2, c2) then
		return false
	end
	local matchId1 = math.abs(self.swapHelpMap[r1][c1])
	local matchId2 = math.abs(self.swapHelpMap[r2][c2])
	return matchId1 == matchId2
end

function GameBoardLogic:hasRopeInNeighbors(r1, c1, r2, c2)
	if not self:isPosValid(r1, c1) or not self:isPosValid(r2, c2) then
		return false
	end

	local deltaR = r2 - r1
	local deltaC = c2 - c1
	local borad1 = self.boardmap[r1][c1]
	local borad2 = self.boardmap[r2][c2]
	if deltaC == 1 then
		return borad1:hasRightRope() or borad2:hasLeftRope()
	elseif deltaC == -1 then
		return borad1:hasLeftRope() or borad2:hasRightRope()
	elseif deltaR == 1 then
		return borad1:hasBottomRope() or borad2:hasTopRope()
	elseif deltaR == -1 then
		return borad1:hasTopRope() or borad2:hasBottomRope()
	end
	return false
end

function GameBoardLogic:isCanEffectLikeProp( r, c )
	-- body
	if self.gameItemMap[r] and self.gameItemMap[r][c] then
		local item = self.gameItemMap[r][c]
		if item.hedgehogLevel > 1 then
			return true
		elseif item.wukongState == TileWukongState.kReadyToJump  then
			return true
		end
	end
	return false
	
end

function GameBoardLogic:isHedgehogCrazyBuffInBonusTime( ... )
	-- body
	if self.theGamePlayType == GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID then
		local r, c = self.gameMode:findHedgehogRC()
		return self.gameMode:checkHedgehogIsCrazy(r, c)
	end
	return false
end

-- colortype 染色宝宝自身的颜色
function GameBoardLogic:findCrystalStoneEffectColor(colortype)
	local colorNums = {}
	for r = 1, #self.gameItemMap do
		for c = 1, #self.gameItemMap[r] do
			local item = self.gameItemMap[r][c]
			if item:canBeCoverByCrystalStone() and colortype ~= item._encrypt.ItemColorType then
				local originColor = AnimalTypeConfig.getOriginColorValue(item._encrypt.ItemColorType)
				if colorNums[originColor] == nil then
					colorNums[originColor] = 1
				else
					colorNums[originColor] = colorNums[originColor] + 1
				end
			end
		end
	end

	local retColors = {}
	local tmpNum = 0
	for i, color in ipairs(AnimalTypeConfig.colorTypeList) do
		if colorNums[color] then
			local num = colorNums[color]
			if num > tmpNum then
				retColors = {}
				table.insert(retColors, color)
				tmpNum = num
			elseif num == tmpNum then
				table.insert(retColors, color)
			end
		end
	end

	if #retColors > 1 then
		return retColors[self.randFactory:rand(1, #retColors)]
	else
		return retColors[1] -- maybe nil
	end
end

function GameBoardLogic:tryBombCrystalStones(isSpecial)
	local num = 0
	for r = 1, #self.gameItemMap do
		for c = 1, #self.gameItemMap[r] do
			local item = self.gameItemMap[r][c]
			if item and item.ItemType == GameItemType.kCrystalStone then
				if (item.crystalStoneBombType and item.crystalStoneBombType > GameItemCrystalStoneBombType.kNone) then
					-- item.crystalStoneBombType = GameItemCrystalStoneBombType.kNone
					item:AddItemStatus(GameItemStatusType.kDestroy)
					local action = GameBoardActionDataSet:createAs(
						GameActionTargetType.kGameItemAction,
						GameItemActionType.kItemSpecial_CrystalStone_Destroy,
						IntCoord:create(r,c),
						nil,
						GamePlayConfig_SpecialBomb_CrystalStone_Destory_Time1)
					action.addInt = item._encrypt.ItemColorType
					action.isSpecial = isSpecial
					self:addDestroyAction(action)
					item.gotoPos = nil
					item.comePos = nil


					num = num + 1
				end
			end
		end
	end
	return num
end

function GameBoardLogic:randomSingleDropColor( itemId , r , c )
	local singleDropCfg = ProductItemLogic:getCurrSingleDropCfg( self , r , c )

	local limitedColors = nil
	if itemId and singleDropCfg then
		limitedColors = singleDropCfg[itemId]
	end

	if limitedColors and #limitedColors > 0 then
		local x = self.randFactory:rand(1,#limitedColors)
		return limitedColors[x]
	else
		local x = self.randFactory:rand(1,#self.mapColorList)
		return self.mapColorList[x]	
	end
end

function GameBoardLogic:getSingleDropLimitedColors(itemId , r , c)

	local singleDropCfg = ProductItemLogic:getCurrSingleDropCfg( self , r , c )
	-- local singleDropCfg = self.singleDropCfg

	local limitedColors = nil
	if itemId and singleDropCfg then
		limitedColors = singleDropCfg[itemId]
	end
	return limitedColors
end

function GameBoardLogic:getSingleDropConfig( r , c )
	local singleDropCfg = ProductItemLogic:getCurrSingleDropCfg( self , r , c )
	-- local singleDropCfg = self.singleDropCfg
	return singleDropCfg or {}
end

function GameBoardLogic:randomCrystalStoneColor()
	if self.dropCrystalStoneColors and #self.dropCrystalStoneColors > 0 then
		local x = self.randFactory:rand(1,#self.dropCrystalStoneColors)	
		return self.dropCrystalStoneColors[x]
	else
		local x = self.randFactory:rand(1,#self.mapColorList)
		return self.mapColorList[x]	
	end
end

function GameBoardLogic:addAllItemsForMatchCheck()
	self:cleanNeedCheckMatchList()
	for i = 1, #self.gameItemMap do
		for j = 1, #self.gameItemMap[i] do
			local item = self.gameItemMap[i][j]
			if item and item:canBeCoverByMatch() then
				self:addNeedCheckMatchPoint(i, j)
			end
		end
	end
end

function GameBoardLogic:getPositionCoverByCrystalStone(color1, color2, specialType)
	local posList = {}
	local colorToChange = color2
	if not colorToChange or colorToChange == 0 or color1 == colorToChange then
		colorToChange = self:findCrystalStoneEffectColor(color1)
	end

	if not specialType or specialType == 0 then
		if colorToChange then
			for i = 1, #self.gameItemMap do
				for j = 1, #self.gameItemMap[i] do
					local item = self.gameItemMap[i][j]
					if item and item:canBeCoverByCrystalStone() and item._encrypt.ItemColorType == colorToChange then
						table.insert(posList, IntCoord:create(i, j))
					end
				end
			end
		end
	else -- 特效交换
		for i = 1, #self.gameItemMap do
			for j = 1, #self.gameItemMap[i] do
				local item = self.gameItemMap[i][j]
				if item and item:canBeSpecialCoverByCrystalStone() then
					if (colorToChange and item._encrypt.ItemColorType == colorToChange) 
							or item._encrypt.ItemColorType == color1 then
						table.insert(posList, IntCoord:create(i, j))
					end
				end
			end
		end
	end
	return posList
end

function GameBoardLogic:addReplayReordPreviewBlock()
	self.blockReplayReord = self.blockReplayReord + 1
end

function GameBoardLogic:releasReplayReordPreviewBlock()
	self.blockReplayReord = self.blockReplayReord - 1
	if self.blockReplayReord <= 0 then
		self.blockReplayReord = 0
		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kShowReplayRecordPreview))
	end
end

function GameBoardLogic:addNewSuperTotemPos(totemPos)
	if not self.newSuperTotemsPos then
		self.newSuperTotemsPos = {}
	end
	table.insert(self.newSuperTotemsPos, totemPos)
end

function GameBoardLogic:tryBombSuperTotemsByForce()
	for r = 1, #self.gameItemMap do
		for c = 1, #self.gameItemMap[r] do
			local item = self.gameItemMap[r][c]
			if item and item:isActiveTotems() and item:isAvailable() then
				self:addNewSuperTotemPos( IntCoord:create(r, c) )
			end
		end
	end

	self:tryBombSuperTotems()
end

function GameBoardLogic:tryBombSuperTotems()
	if not self.newSuperTotemsPos or #self.newSuperTotemsPos < 1 then
		return
	end

	local newPosList = self.newSuperTotemsPos
	local oldExsitPos = nil
	local function isPosExistInList(posList, pos)
		if not posList or not pos then 
			return false end
		for _, v in pairs(posList) do
			if v.x == pos.x and v.y == pos.y then
				return true
			end
		end
		return false
	end

	for r = 1, #self.gameItemMap do
		for c = 1, #self.gameItemMap[r] do
			local item = self.gameItemMap[r][c]
			if item and item:isActiveTotems() and item:isAvailable() then
				local pos = IntCoord:create(r, c)
				if not isPosExistInList(newPosList, pos) then
					oldExsitPos = pos
					break
				end
			end
		end
	end

	local function calcArea(pos1, pos2)
		return (math.abs(pos1.x - pos2.x) + 1) * (math.abs(pos1.y - pos2.y) + 1)
	end

	local function buildResult(startPos, endPos)
		return {startPos = startPos, endPos = endPos}
	end

	local function getMaxAreaTotems(posList)
		if #posList == 2 then -- 只有2个，直接返回
			return buildResult(posList[1], posList[2])
		elseif #posList > 2 then
			local posPairs = {}
			local maxArea = 0
			-- 计算面积最大的组合
			for i = 1, #posList do
				for j = 1, #posList do
					if i ~= j then
						local area = calcArea(posList[i], posList[j])
						if area > maxArea then
							posPairs = {buildResult(posList[j], posList[i])}
							maxArea = area
						elseif area == maxArea then
							table.insert(posPairs, buildResult(posList[j], posList[i]))
						end
					end
				end
			end
			if #posPairs > 0 then -- 多于1组的随机返回一组
				local index = self.randFactory:rand(1, #posPairs)
				return posPairs[index]
			end
		end
		return nil
	end

	local function tryMatchSuperTotems(posList)
		local ret = {}
		if posList then
			while #posList > 1 do
				local match = getMaxAreaTotems(posList)
				if match then
					table.insert(ret, match)
					table.removeValue(posList, match.startPos)
					table.removeValue(posList, match.endPos)
				else
					break
				end
			end
		end
		return ret
	end

	local resultMatchs = {}
	if oldExsitPos then -- 优先计算原来已存在的超级小金刚
		if #newPosList > 0 then
			local matchPosList = {}
			local maxArea = 0	
			for _, v in pairs(newPosList) do
				local area = calcArea(oldExsitPos, v)
				if area > maxArea then
					matchPosList = {v}
					maxArea = area
				elseif area == maxArea then
					table.insert(matchPosList, v)
				end
			end
			local index = self.randFactory:rand(1, #matchPosList)
			local matchPos = matchPosList[index]

			table.removeValue(newPosList, matchPos)
			if #newPosList > 1 then
				resultMatchs = tryMatchSuperTotems(newPosList)
			end
			table.insert(resultMatchs, 1, buildResult(matchPos, oldExsitPos))
		end
	elseif #newPosList > 1 then
		resultMatchs = tryMatchSuperTotems(newPosList)
	end

	for _, v in pairs(resultMatchs) do
		--printx( 1 , "  ~~~~resultMatchs:", v.startPos.x..","..v.startPos.y, "--->", v.endPos.x..","..v.endPos.y)
		local action = GameBoardActionDataSet:createAs(
                GameActionTargetType.kGameItemAction,
                GameItemActionType.kItem_SuperTotems_Explode_part1,
                v.startPos,
                v.endPos,
                GamePlayConfig_MaxAction_time)

		local item1 = self.gameItemMap[v.startPos.x][v.startPos.y]
		item1.totemsState = GameItemTotemsState.kWattingBomb
		local item2 = self.gameItemMap[v.endPos.x][v.endPos.y]
		item2.totemsState = GameItemTotemsState.kWattingBomb

	    self:addDestructionPlanAction(action)

	    -- GameExtandPlayLogic:doAllBlocker211Collect(self, v.startPos.x, v.startPos.y, 0, true, 3)
	end

	self.newSuperTotemsPos = {}
end


function GameBoardLogic:sortProductPortals(posList)
	if #posList < 2 then return posList end

	local totemPosList = {}
	for r = 1, #self.gameItemMap do
		for c = 1, #self.gameItemMap[r] do
			local item = self.gameItemMap[r][c]
			if item and item.ItemType == GameItemType.kTotems 
					and item.totemsState ~= GameItemTotemsState.kWattingBomb 
					and item.totemsState ~= GameItemTotemsState.kBomb then
				local pos = IntCoord:create(r, c)
				table.insert(totemPosList, pos)
			end
		end
	end

	if #totemPosList > 0 then
		local randomTPos = totemPosList[self.randFactory:rand(1, #totemPosList)]
		local posToTotems = {}
		for index, pos in ipairs(posList) do
			table.insert(posToTotems, {index=index, pos=pos, d=math.abs(pos.y - randomTPos.y)})
		end

		-- mylog(">>>>>> has totoms in pos:", table.serialize(totemPosList))
		-- mylog(">>>>>> select pos:", table.serialize(randomTPos))

		table.sort(posToTotems, function(a, b) 
			if a.d > b.d then 
				return true
			elseif a.d == b.d then
				return a.index < b.index
			else
				return false
			end
		end)

		local newPosList = {}
		for _, v in ipairs(posToTotems) do
			-- mylog(">>>>>> posToTotems in order:", table.serialize(v))
			table.insert(newPosList, v.pos)
		end
		posList = newPosList
		-- debug.debug()
	end

	return posList
end

function GameBoardLogic:addScoreToTotal(r, c, addScore, colorType, posType, isBuffScore , oringinAddScore)
	if not oringinAddScore then oringinAddScore = addScore end

    if SpringFestival2019Manager.getInstance():getCurIsActSkill() then
        local addPercent = SpringFestival2019Manager.getInstance():getSkill2Info()
        addScore = addScore * (1+addPercent)

        if addScore % 5 ~= 0 then
            addScore = addScore + ( 5 - addScore % 5 )
        end
    end

	ScoreCountLogic:addScoreToTotal(self, addScore , oringinAddScore)
	self:addScoreAction(r, c, addScore, colorType, posType, isBuffScore)

	-- 添加大招能量
	if self.theGamePlayType == GameModeTypeId.MOLE_WEEKLY_RACE_ID and not self.isBonusTime then
		-- printx(11, "++++++++++++++++++++", addScore, r, c)
		self:chargeFirework(addScore, r, c)
	end
end

function GameBoardLogic:addScoreAction(r, c, addScore, colorType, posType, isBuffScore)
	local ScoreAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemScore_Get,
		IntCoord:create(r, c),
		nil,				
		1)
	ScoreAction.addInt = addScore
	ScoreAction.addInt2 = posType
	ScoreAction.isBuffScore = isBuffScore
	if colorType then
		ScoreAction.scoreColorIndex = AnimalTypeConfig.convertColorTypeToIndex(colorType)
	end
	self:addGameAction(ScoreAction)
end

function GameBoardLogic:playEliminateMusic(music)
	local MusicAction =	GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kEliminateMusic,
		nil,
		nil,
		1)
	MusicAction.music = music
	self:addDestroyAction(MusicAction)
end

function GameBoardLogic:setInitScrollCannon(initCannon)
	self.initScrollCannonData = initCannon
end

function GameBoardLogic:updateScrollCannon()
	if not self.boardmap or not self.initScrollCannonData then return end
	for c=1,9 do
    	for r=1,9 do
			local item = self.boardmap[r][c]
			if item and item.isUsed then 
				local preRow = self.boardmap[r-1]
				if not preRow or not preRow[c].isUsed then
					if not item.theGameBoardFallType or #item.theGameBoardFallType <= 0 then 
						item.theGameBoardFallType = self.initScrollCannonData[c] or {}
						if #item.theGameBoardFallType > 0 then 
							item.isProducer = true 
						end
					end
					break
				end
			end
		end
	end
end

function GameBoardLogic:difficultyAdjustActivated()
	if self.difficultyAdjustData then
		if self.difficultyAdjustData.adjustSeed and self.difficultyAdjustData.adjustSeed > 0 then
			return true 
		end
		if self.difficultyAdjustData.mode and self.difficultyAdjustData.mode > 0 then
			return true 
		end
	end

	return false
end

function GameBoardLogic:onTouchInWrongState(x, y)
	if self.setWriteReplayEnable then
		if not self.needCheckFalling then
			ReplayDataManager:onTrySwapFailedInStableState()
		end
	end
end

function GameBoardLogic:isHorizontalEndless()
	return self.theGamePlayType == GameModeTypeId.SPRING_HORIZONTAL_ENDLESS_ID
end

function GameBoardLogic:addJamSrcSpecial(r, c, bForceAdd )
	local bIsSafePos =  self:isPosValid(r, c)
    if bIsSafePos then
        local PosInfo = {}

        local itemData = self.gameItemMap[r][c]
        local boardData = self.boardmap[r][c]

        PosInfo.isJamSperad = boardData.isJamSperad
        if bForceAdd then
        	PosInfo.isJamSperad = true
        end
        PosInfo.x = r
        PosInfo.y = c
        return PosInfo
    end
end

--把特效的原点 数据记录列表
function GameBoardLogic:addSrcSpecialCoverToList( Item1Pos, Item2Pos, Item3Pos, Item4Pos )

    if self.theGamePlayType ~= GameModeTypeId.JAMSPREAD_ID then
        return 0
    end

    if self.SrcSpecialCoverList == nil then
        self.SrcSpecialCoverList = {}
    end

    local PosList = {}
    if Item1Pos then
        table.insert( PosList, IntCoord:create(Item1Pos.x,Item1Pos.y) )
    end

    if Item2Pos then
        table.insert( PosList, IntCoord:create(Item2Pos.x,Item2Pos.y) )
    end

    if Item3Pos then
        table.insert( PosList, IntCoord:create(Item3Pos.x,Item3Pos.y) )
    end

    if Item4Pos then
        table.insert( PosList, IntCoord:create(Item4Pos.x,Item4Pos.y) )
    end

    local Info = {}
    for i,v in pairs(PosList) do
        local PosInfo = self:addJamSrcSpecial(v.x, v.y)
        table.insert( Info, PosInfo )
    end
    table.insert( self.SrcSpecialCoverList, Info )

	return #self.SrcSpecialCoverList
end

--把特效的原点 数据记录列表
function GameBoardLogic:addSrcSpecialCoverToListEx( PosList, bForceAdd )
    if self.theGamePlayType ~= GameModeTypeId.JAMSPREAD_ID then
        return 0
    end

    if self.SrcSpecialCoverList == nil then
        self.SrcSpecialCoverList = {}
    end

    if not PosList then PosList = {} end

    local Info = {}
    for i,v in pairs(PosList) do
        local PosInfo = self:addJamSrcSpecial(v.x, v.y, bForceAdd)
        table.insert( Info, PosInfo )
    end
    table.insert( self.SrcSpecialCoverList, Info )

	return #self.SrcSpecialCoverList
end

--清空特效原点数据
function GameBoardLogic:clearSrcSpecialCoverList()
    if self.theGamePlayType ~= GameModeTypeId.JAMSPREAD_ID then
        return
    end

    if self.SrcSpecialCoverList then
        table.removeAll( self.SrcSpecialCoverList )
    end
end

--特效原点数据 是否有果酱
function GameBoardLogic:checkSrcSpecialCoverListIsHaveJamSperad( SrcSpecialCoverListID )
    if self.theGamePlayType ~= GameModeTypeId.JAMSPREAD_ID then
        return false
    end

    if not self.SrcSpecialCoverList then return false end

    local Info = self.SrcSpecialCoverList[SrcSpecialCoverListID]

    if not Info then return false end

    for i,v in pairs(Info) do
        if v.isJamSperad then
            return true
        end
    end

    return false
end

--检查当前位置是否可以阻挡果酱
function GameBoardLogic:CheckPosCanStopJamSperad( Pos, Pos2, justRemove )
    if self.theGamePlayType ~= GameModeTypeId.JAMSPREAD_ID then
        return false
    end

    local itemData = self.gameItemMap[Pos.x][Pos.y]
    local boardData = self.boardmap[Pos.x][Pos.y]
    
    if justRemove then
    	return false
    end
    if itemData.isBlock then
        local bBlock = itemData.isBlock
        if itemData.ItemType == GameItemType.kMagicLamp then 
             --大眼仔
            bBlock = false
        elseif itemData.ItemType == GameItemType.kBlocker199 then
            --水母 水母贝壳算block 
            if itemData.level == 0 then
                bBlock = false
            end
        end

        if bBlock then
            return bBlock
        end
    end

    if itemData:hasAnyFurball() then
        return true
    end

    if itemData:hasBlocker206() then
        return true
    end

    if itemData.ItemType == GameItemType.kCoin then --银币
        return true
    end

    if itemData.ItemType == GameItemType.kBlocker207 then --钥匙
        return true
    end

    if itemData.ItemType == GameItemType.kMissile then --冰峰导弹
        return true
    end

    if itemData.ItemType == GameItemType.kPuffer then --气鼓鱼
        return true
    end

    if itemData.ItemType == GameItemType.kCrystalStone then --染色宝宝
        return true
    end

    if itemData.ItemType == GameItemType.kBlocker195 then --刷星瓶
        return true
    end

    if itemData.ItemType == GameItemType.kHoneyBottle then --蜂蜜罐子
        return true
    end

    if itemData.ItemType == GameItemType.kWanSheng then --万生
        return true
    end

    if Pos2 then
        if self:hasChainInNeighbors(Pos.x,Pos.y,Pos2.x,Pos2.y ) then
            return true
        end
    end

    return false
end


function GameBoardLogic:getCurScoreAndStar( ... )
	local curScore = self.totalScore
	local curStar = 0
	for star, score in ipairs(self.scoreTargets) do
		if curScore >= score then
			curStar = star
		end
	end
	return curScore, curStar
end

function GameBoardLogic:revertSpringSkillUseType( ... )
    local item = self.PlayUIDelegate.propList:findItemByItemID(GamePropsType.kBack)
    if item and item.canNotUseThisSkillCD > 0 then
        item.canNotUseThisSkillCD = item.canNotUseThisSkillCD - 1 
        if item.canNotUseThisSkillCD <= 0 then
            item.canNotUseThisSkillCD = 0
            item:setEnable()
        end
    end
end

---replay 春节技能
function GameBoardLogic:replaySpringSkill( propID )
    
    local result = false
    local SkillID = propID - GamePropsType.kSpringSkill1 + 1

    --适配位置到技能
    local rightPropList = self.PlayUIDelegate.propList.rightPropList

    local WorldSpace = ccp(0,0)
    if rightPropList then
        local rightPropPos = rightPropList:getPosition()
        WorldSpace = rightPropList:getParent():convertToWorldSpace( ccp(rightPropPos.x+79/0.7,rightPropPos.y+45/0.7) )
    end

    if SkillID == 1 then
        local infectList = SpringFestival2019Manager.getInstance():GetSkill1Info()
        if #infectList > 0 then
            local action = GameBoardActionDataSet:createAs(
		                GameActionTargetType.kPropsAction, 
		                GamePropsActionType.kSpringFestival2019_Skill1,
		                nil,
		                nil, 
		                GamePlayConfig_MaxAction_time)
            action.canBeInfectItemList = infectList
            action.WorldSpace = IntCoord:create(WorldSpace.x,WorldSpace.y)
	        self:addPropAction( action )
	        self.fsm:changeState(self.fsm.usePropState)

            result = true
        end
    elseif SkillID == 2 then
        local action = GameBoardActionDataSet:createAs(
		            GameActionTargetType.kPropsAction, 
		            GamePropsActionType.kSpringFestival2019_Skill2,
		            nil,
		            nil, 
		            GamePlayConfig_MaxAction_time)
        action.WorldSpace = IntCoord:create(WorldSpace.x,WorldSpace.y)
	    self:addPropAction( action )
	    self.fsm:changeState(self.fsm.usePropState)

        result = true
    elseif SkillID == 3 then
        local PosList = SpringFestival2019Manager.getInstance():GetSkill3Info()
        if #PosList > 0 then
            local action = GameBoardActionDataSet:createAs(
		                GameActionTargetType.kPropsAction, 
		                GamePropsActionType.kSpringFestival2019_Skill3,
		                nil,
		                nil, 
		                GamePlayConfig_MaxAction_time)
            action.PosList = PosList
            action.WorldSpace = IntCoord:create(WorldSpace.x,WorldSpace.y)
	        self:addPropAction( action )
	        self.fsm:changeState(self.fsm.usePropState)

            result = true
        end
    elseif SkillID == 4 then
        local PosList = SpringFestival2019Manager.getInstance():GetSkill4Info()
        if #PosList > 0 then
            local action = GameBoardActionDataSet:createAs(
		                GameActionTargetType.kPropsAction, 
		                GamePropsActionType.kSpringFestival2019_Skill4,
		                nil,
		                nil, 
		                GamePlayConfig_MaxAction_time)
            action.PosList = PosList
            action.WorldSpace = IntCoord:create(WorldSpace.x,WorldSpace.y)
	        self:addPropAction( action )
	        self.fsm:changeState(self.fsm.usePropState)

            result = true
        end
    end

    return result
end

function GameBoardLogic:getTotalMilksCountAndTarget( ... )
	local target, count = 0, 0
	local m = #(self.boardmap)
	for r = 1, m do
		local n = #(self.boardmap[r])
		for c = 1, n do
			local boardData = self.boardmap[r][c]
			if boardData and boardData.isUsed then
				if boardData.biscuitData then
					local thisCount, thisTarget = boardData:getMilksCountAndTarget()
					target = target + thisTarget
					count = count + thisCount
				end
			end
		end
	end
	return count, target
end