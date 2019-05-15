require "zoo.gamePlay.GamePreStartContext"

GamePlayContext = class()

--for test ---------------------------------------------------
testStartLevelInfoFilterUids = {
	-- "622911509",
	-- "1797201330",
	-- "1061394970",
	-- "741137484",
	-- "1008286368",
	-- "1820791510",
	-- "1023568404",
	-- "150281440",
	-- "95956144",
	-- "1773727235",
	-- "33844648",
	-- "1813099642",
	-- "1405224178",
	-- "1795743251",
	-- "173344131",
	-- "377932025",
	-- "1814247120",
	-- "1005280955",
	-- "1364716337",
	-- "37766",
	-- "16838701",
	-- "383150435",
	-- "21301953",
	-- "322841139",
	-- "1007161305",
	-- "1262682445",
	-- "1318803655",
	-- "138345589",
	-- "151298439",
	-- "18615891",
	-- "120773356",
	-- "70991288",
	-- "1824382332",
	-- "31024351",
	-- "100224486",
	-- "1810761747",
	-- "1013874412",
	-- "1824823783",
	-- "261228784",
	-- "1786659073",
	-- "1100786072",
	-- "195921734",
	-- "506739909",
	-- "475753947",
	-- "214574827",
	-- "288324264",
	-- "783840602",
	-- "1001687643",
	-- "76154043",
	-- "402505352",
	-- "237752444",



	"28985",
	"10169",
	"26902",
	"33",

}

--------------------------------------------------------------
--这些playInfo中的字段，是为任务系统新添加的，支持后退一步和闪退回复，并且不发送给AI
local _quests_keys = {
	'killed_line',
	'killed_wrap',
	'killed_bird',
	'killed_animal_1',
	'killed_animal_2',
	'killed_animal_3',
	'killed_animal_4',
	'killed_animal_5',
	'killed_animal_6',
}


local _instance = nil

DeathLoopType = {
	kNone = 0 ,
	kColor = 1 ,
}

function GamePlayContext:getInstance()
	if not _instance then
		_instance = GamePlayContext.new()
		_instance:init()
	end
	return _instance
end

local localDataKey = "GPC_2"

local function createDefaultLevelInfo()
	local levelInfo = {}
	levelInfo.levelId = 0
	levelInfo.metaLevelId = 0
	levelInfo.playType = -1
	levelInfo.levelType = -1
	levelInfo.oldStar = 0
	levelInfo.oldScore = 0
	levelInfo.scoreRefIsNil = false --意味着这一关从未正常结束过，后端尚未创建数据
	levelInfo.lastPlayResult = false
	levelInfo.seedValue = nil
	levelInfo.aiSeedValue = nil
	levelInfo.aiEventId = nil
	levelInfo.aiAlgorithmTag = nil
	levelInfo.aiDataSetup = 0
	levelInfo.currTopLevelId = 0
	levelInfo.currTopLevelFailCount = 0
	levelInfo.currTopLevelLogicalFailCounts = 0

	return levelInfo
end

local function createDefaultUserInfo() --这里数据储存的都是游戏开始的一瞬间的值，而不是UserManager里的当前值
	local userInfo = {}
	userInfo.coin = 0
	userInfo.cash = 0
	userInfo.energy = 0
	userInfo.maxEnergy = 0
	userInfo.totalTrunkStar = 0
	userInfo.totalHideStar = 0

	return userInfo
end


local function createDefaultWeeklyData()
	local weeklyData = {}
	weeklyData.dailyDropPropCount = 0
	weeklyData.dailyDropPropCount2 = 0
	return weeklyData
end

local function createDefaultSummerWeeklyData()
	local summerWeeklyData = {}
	summerWeeklyData.dropPropsPercent = 0
	summerWeeklyData.orignalDropPropsPercent = 0
	return summerWeeklyData
end

local function createDefaultPlayInfo()
	local playInfo = {}

	playInfo.animal_destroy_count = 0

	playInfo.line_create = 0
	playInfo.wrap_create = 0
	playInfo.bird_create = 0

	playInfo.line_cover = 0
	playInfo.line_match_swap = 0
	
	playInfo.wrap_cover = 0
	playInfo.wrap_match_swap = 0

	playInfo.bird_cover = 0

	playInfo.line_line_swap = 0
	playInfo.line_wrap_swap = 0
	playInfo.wrap_wrap_swap = 0

	playInfo.bird_color_swap = 0
	playInfo.bird_line_swap = 0
	playInfo.bird_wrap_swap = 0
	playInfo.bird_bird_swap = 0



	--以下字段 支持后退一步 回退数据

	playInfo.killed_line = 0
	playInfo.killed_wrap = 0
	playInfo.killed_bird = 0
	playInfo.killed_animal_1 = 0
	playInfo.killed_animal_2 = 0
	playInfo.killed_animal_3 = 0
	playInfo.killed_animal_4 = 0
	playInfo.killed_animal_5 = 0
	playInfo.killed_animal_6 = 0



	--以上字段 支持后退一步 回退数据

	--[[
	playInfo.usePropLogInThisPlay = {}
	playInfo.usePropLogInThisPlay.log = {}
	playInfo.usePropLogInThisPlay.addStepCount = 0
	playInfo.totalUsePropCount = 0

	playInfo.satisfyPreconditionsForStrategy = false
	playInfo.isPayUser = false

	playInfo.colorNumMap = {}
	]]

	return playInfo
end

local function createDefaultGuideContext()
	local ctx = {}
	ctx.showRepeatGuideButton = false
	ctx.lastGuideStep = -1 --最靠后的一个引导的步数，如果整关没有引导，则为-1，棋盘初始化就有引导，则为0
	ctx.clickRepeatGuide = false
	ctx.allowRepeatGuide = false

	return ctx
end

function GamePlayContext:init()

	self.inLevel = false
	self.levelWillEnd = false

	self.levelInfo = createDefaultLevelInfo()
	self.userInfo = createDefaultUserInfo()
	self.playInfo = createDefaultPlayInfo()

	self.usePropList = {}
	self.buyPropList = {}
	self.buffs = {}
	self.weeklyData = createDefaultWeeklyData()
	self.summerWeeklyData = createDefaultSummerWeeklyData()
	self.nationDayData = nil
	self.guidedProp = 0
	self.replayModeWhenStart = ReplayMode.kNone
	self.levelFeatureMap = {}
	self.guideContext = createDefaultGuideContext()
	self.theGamePlayType = nil --关卡的玩法类型，区分不同的玩法，例如步数模式，时间关，挖地模式等
	self.levelType = nil --关卡类型，区分产品层面的不同类型关卡。不同的“关卡类型”，可能是同一种“关卡玩法类型”，例如可能有多个活动关卡都是挖地模式。
	self.replayData = nil
	self.isJumpedLevelWhenStart = false
	self.isHelpedLevelWhenStart = false
	self.preStartContext = nil
	self.lastSwapInfo = {}
	self.originLevelConfig = nil
	self.rewards = {}
	self.aiCostStepsArr = nil
	self.aiLeftStepsArr = nil
	self.aiInterveneArr = nil
	self.aiRepeatArr = nil
	self.aiPropUsedTotalIndex = nil
	self.aiPropUsedIndex = nil
	self.aiSeedFirstGetTime = nil
	self.syncExceptionOccur = false -- SyncExceptionLogic
	self.endlessLoopData = {}
end

function GamePlayContext:reset()
	self.playId = nil
	self.inLevel = false
	self.levelWillEnd = false
	self.levelInfo = createDefaultLevelInfo()
	self.userInfo = createDefaultUserInfo()
	self.playInfo = createDefaultPlayInfo()
	self.usePropList = {}
	self.buyPropList = {}
	self.buffs = {}
	self.weeklyData = createDefaultWeeklyData()
	self.summerWeeklyData = createDefaultSummerWeeklyData()
	self.nationDayData = nil
	self.guidedProp = 0
	self.replayModeWhenStart = ReplayMode.kNone
	self.levelFeatureMap = {}
	self.guideContext = createDefaultGuideContext()
	self.theGamePlayType = nil --关卡的玩法类型，区分不同的玩法，例如步数模式，时间关，挖地模式等
	self.levelType = nil --关卡类型，区分产品层面的不同类型关卡。不同的“关卡类型”，可能是同一种“关卡玩法类型”，例如可能有多个活动关卡都是挖地模式。
	self.replayData = nil
	self.isJumpedLevelWhenStart = false
	self.isHelpedLevelWhenStart = false
	self.preStartContext = nil
	self.lastSwapInfo = {}
	self.originLevelConfig = nil
	self.rewards = {}
	self.aiCostStepsArr = nil
	self.aiLeftStepsArr = nil
	self.aiInterveneArr = nil
	self.aiRepeatArr = nil
	self.fuuuOverview = nil
	self.aiPropUsedTotalIndex = nil
	self.aiPropUsedIndex = nil
	self.aiSeedFirstGetTime = nil
	if self.testInfo then
		for k,v in pairs(self.testInfo) do
			self:removeTestInfoLocalData(k)
			self.testInfo[k] = nil
		end
	end

	self.isDefaultDataState = true
	self.syncExceptionOccur = false
	self.endlessLoopData = {}
end

function GamePlayContext:setRevertData(data)
	if data then 
		self:revertPlayInfo(data.playInfo)
		self.aiPropUsedTotalIndex = data.aiPropUsedTotalIndex
		self.aiCostStepsArr = data.aiCostStepsArr and table.clone(data.aiCostStepsArr, true)
		self.aiLeftStepsArr = data.aiLeftStepsArr and table.clone(data.aiLeftStepsArr, true)
		self.aiInterveneArr = data.aiInterveneArr and table.clone(data.aiInterveneArr, true)
		self.aiRepeatArr = data.aiRepeatArr and table.clone(data.aiRepeatArr, true)
		self.fuuuOverview = data.fuuuOverview and table.clone(data.fuuuOverview, true)
		self.endlessLoopData = data.endlessLoopData and table.clone(data.endlessLoopData, true)
	end
end

function GamePlayContext:getRevertData()
	local data = {}
	data.playInfo = self.playInfo and table.clone(self.playInfo, true)
	data.aiPropUsedTotalIndex = self.aiPropUsedTotalIndex
	data.aiCostStepsArr = self.aiCostStepsArr and table.clone(self.aiCostStepsArr, true)
	data.aiLeftStepsArr = self.aiLeftStepsArr and table.clone(self.aiLeftStepsArr, true)
	data.aiInterveneArr = self.aiInterveneArr and table.clone(self.aiInterveneArr, true)
	data.aiRepeatArr = self.aiRepeatArr and table.clone(self.aiRepeatArr, true)
	data.fuuuOverview = self.fuuuOverview and table.clone(self.fuuuOverview, true)
	data.endlessLoopData = self.endlessLoopData and table.clone(self.endlessLoopData, true)
	return data
end

function GamePlayContext:updateAIPropUsedIndex(reset)
	if reset then
		self.aiPropUsedIndex = nil
	else
		if not self.aiPropUsedTotalIndex then
			self.aiPropUsedTotalIndex = -1
		else
			self.aiPropUsedTotalIndex = self.aiPropUsedTotalIndex - 1
		end
		self.aiPropUsedIndex = self.aiPropUsedTotalIndex
	end
end

function GamePlayContext:getAIPropUsedIndex()
	return self.aiPropUsedIndex
end

function GamePlayContext:addAIInterveneLog(realCostStep, realCostStepWithOutProp, leftSteps, interveneColor)
	if not self.aiCostStepsArr then self.aiCostStepsArr = {} end
	if not self.aiLeftStepsArr then self.aiLeftStepsArr = {} end
	if not self.aiInterveneArr then self.aiInterveneArr = {} end
	if not self.aiRepeatArr then self.aiRepeatArr = {} end
	if not self.fuuuOverview then self.fuuuOverview= {} end

	if not self.aiCostStepsArr[realCostStep] then
		self.aiCostStepsArr[realCostStep] = {}
	end 
	if not self.aiLeftStepsArr[realCostStep] then
		self.aiLeftStepsArr[realCostStep] = {}
	end
	if not self.aiInterveneArr[realCostStep] then
		self.aiInterveneArr[realCostStep] = {}
	end
	if not self.aiRepeatArr[realCostStep] then
		self.aiRepeatArr[realCostStep] = {}
	end
	self.fuuuOverview[realCostStep] = interveneColor

	local leftSteps = self:getAIPropUsedIndex() or leftSteps
	local leftStepsMaxNum = #self.aiLeftStepsArr[realCostStep]
	local newestLeftStep = self.aiLeftStepsArr[realCostStep][leftStepsMaxNum]
	local newestintervene = self.aiInterveneArr[realCostStep][leftStepsMaxNum]
	if newestLeftStep and newestLeftStep == leftSteps and newestintervene and newestintervene == interveneColor then
		self.aiRepeatArr[realCostStep][leftStepsMaxNum] = self.aiRepeatArr[realCostStep][leftStepsMaxNum] + 1
	else
		table.insert(self.aiCostStepsArr[realCostStep], realCostStepWithOutProp)
		table.insert(self.aiLeftStepsArr[realCostStep], leftSteps)
		table.insert(self.aiInterveneArr[realCostStep], interveneColor)
		table.insert(self.aiRepeatArr[realCostStep], 1)
	end

	-- printx(7, 'aiCostStepsArr-----', table.tostring(self.aiCostStepsArr))
	-- printx(7, 'aiLeftStepsArr-----', table.tostring(self.aiLeftStepsArr))
	-- printx(7, 'aiInterveneArr-----', table.tostring(self.aiInterveneArr))
	-- printx(7, 'aiRepeatArr--------', table.tostring(self.aiRepeatArr))
	-- printx(7, 'fuuuOverview-------', table.tostring(self.fuuuOverview))
	-- printx(7, 'fuuuOverviewDcStr-------', self:getFuuuOverviewDcStr())
	-- printx(7, 'getFuuuOverviewAvg-------', self:getFuuuOverviewAvg())
end

function GamePlayContext:getAIInterveneLog()
	return self.aiCostStepsArr, self.aiLeftStepsArr, self.aiInterveneArr, self.aiRepeatArr
end

function GamePlayContext:getFuuuOverview()
	return self.fuuuOverview
end

function GamePlayContext:getFuuuOverviewDcStr()
	local fuuuOverview = self:getFuuuOverview()
	local str
	if fuuuOverview then 
		for i,v in ipairs(fuuuOverview) do
			if not str then
				str = v .. ""
			else
				str = str .. "_" .. v
			end
		end
	end

	return str
end

function GamePlayContext:getFuuuOverviewAvg()
	local fuuuOverview = self:getFuuuOverview()
	if fuuuOverview and type(fuuuOverview) == 'table' then
		local num = #fuuuOverview
		if num > 0 then 
			return string.format("%.3f", table.sum(fuuuOverview) / num)
		else
			return nil
		end
	end
	return nil
end

function GamePlayContext:updateLastSwapInfo( r1, c1, r2, c2 )
	self.lastSwapInfo.startPos = { r = r1 , c = c1 }
	self.lastSwapInfo.endPos = { r = r2 , c = c2 }

	if r1 == r2 and c1 < c2 then
		self.lastSwapInfo.direction = DirectionType.kRight
	elseif r1 == r2 and c1 > c2 then
		self.lastSwapInfo.direction = DirectionType.kLeft
	elseif r1 < r2 and c1 == c2 then
		self.lastSwapInfo.direction = DirectionType.kDown
	elseif r1 > r2 and c1 == c2 then
		self.lastSwapInfo.direction = DirectionType.kUp
	end
end

function GamePlayContext:onUseProp( propid , step , usePropsType )
	local obj = {}
	obj.propId = propid
	obj.step = step
	obj.pt = usePropsType

	table.insert( self.usePropList , obj )
end

function GamePlayContext:hadUsedProp( propId )
	return table.find(self.usePropList or {}, function ( v )
		return v.propId == propId
	end)
end

function GamePlayContext:onBuyProp( feature, currencyType, cost, goodsId, goodsNum, levelId, activityId, source )
	if self.inLevel then
		if levelId and levelId > 0 then
			local goodMeta = MetaManager.getInstance():getGoodMeta( goodsId )

			if goodMeta and goodMeta.items and #goodMeta.items == 1 and goodMeta.items[1] then

				-- printx( 1 , "GamePlayContext:onBuyProp " , self.inLevel , feature , levelId , currencyType  )
				local item = goodMeta.items[1]
				local mainLogic = GameBoardLogic:getInstance()
				local obj = {}
				local __CostMoneyType = GamePreStartContext:getCostMoneyTypeConfig()
				local costMoneyType = 0

				if currencyType == DcDataCurrencyType.kCoin then
					costMoneyType = __CostMoneyType.kCoin
				elseif currencyType == DcDataCurrencyType.kGold then
					costMoneyType = __CostMoneyType.kGold
				elseif currencyType == DcDataCurrencyType.kRmb then
					costMoneyType = __CostMoneyType.kRMB
				end

				obj.propId = item.itemId

				if mainLogic then
					--由于self.inLevel是在reset方法里置空的，所以存在一个购买行为在mainLogic已经不存在了，但是整个GamePlayContext还没有销毁的情况下回调onBuyProp
					obj.step = mainLogic.realCostMove
				end
				obj.costMoney = cost
				obj.costMoneyType = costMoneyType
				obj.num = goodsNum

				table.insert( self.buyPropList , obj )

				SnapshotManager:buy( obj )
			end
		end
	end
end

function GamePlayContext:setData( key , value )
	self[key] = value
	--[[
	if self[key] then
		self[key] = value
	else
		assert( false , "GamePlayContext:setData    Key must be defined first !!") 
	end
	]]
end

function GamePlayContext:getData( key )
	return self[key]
end

function GamePlayContext:setAISeedData(mainLogic)
	self.levelInfo.aiDataSetup = 1

	self.levelInfo.aiSeedValue = LevelDifficultyAdjustManager:getAISeedValue()
	self.levelInfo.aiEventId = LevelDifficultyAdjustManager:getAIEventID()
	self.levelInfo.aiAlgorithmTag = LevelDifficultyAdjustManager:getAIAlgorithmTag()

	--colorProbs为空时，走本地难度调整，否则走AI难度调整
	if not LevelDifficultyAdjustManager:getAIColorProbs() then  
		--aiSeedValue是否为-1和-2其中之一 -1和-2的含义详见下面文档
		--https://happyelements.atlassian.net/wiki/spaces/HEAI/pages/232914973/SDK+v0.3
		local isAISpecial = false 
		if self.levelInfo.aiSeedValue and (self.levelInfo.aiSeedValue == -1 or self.levelInfo.aiSeedValue == -2) then
			isAISpecial = true 
		end
		--是否激活本地难度调整
		if mainLogic:difficultyAdjustActivated() then
			if isAISpecial then
				self.levelInfo.aiAlgorithmTag = self.levelInfo.aiAlgorithmTag and self.levelInfo.aiAlgorithmTag..'_fuuu' or 'ai_err'
			else
				self.levelInfo.aiAlgorithmTag = "offline-fuuu"
			end
		else
			--aiSeedValue不是-1和-2时
			if not isAISpecial then 
				self.levelInfo.aiAlgorithmTag = "offline"
			end
		end
	end
end

function GamePlayContext:setRandomSeed(randomSeed)
	self.levelInfo.seedValue = randomSeed
end

function GamePlayContext:startLevel( levelId , levelType )
	
end

function GamePlayContext:onStartLevelMessageSuccessed( levelId , levelType )
	self:reset()
	self.inLevel = true
	self.isDefaultDataState = false

	self.levelInfo.levelId = levelId
	self.levelInfo.metaLevelId = LevelMapManager.getInstance():getMetaLevelId(levelId)
	self.levelInfo.levelType = levelType

	local _a , _b , maxEnergy , isInfiniteEnergy = UserManager:getInstance():refreshEnergy()
	local user = UserManager:getInstance():getUserRef()
	--此处可能有坑，TBC
	self.userInfo.coin = user:getCoin()
	self.userInfo.cash = user:getCash()
	self.userInfo.energy = user:getEnergy()
	if isInfiniteEnergy then
		self.userInfo.energy = -1
		self.userInfo.maxEnergy = -1
	else
		self.userInfo.maxEnergy = maxEnergy
	end
	self.userInfo.totalTrunkStar = user:getStar()
	self.userInfo.totalHideStar = user:getHideStar()

	self.preStartContext = GamePreStartContext:getInstance()
	self.levelInfo.idStr = self.preStartContext:getPlayId()
	self.playId = self.levelInfo.idStr

	GamePreStartContext_reInstance()

	--------------------------------------------------------------

	local scoreRef = UserManager:getInstance():getUserScore( self.levelInfo.levelId )
	if scoreRef then
		self.levelInfo.scoreRefIsNil = false
		self.levelInfo.oldStar = scoreRef.star
		self.levelInfo.oldScore = scoreRef.score
	else
		self.levelInfo.scoreRefIsNil = true
		self.levelInfo.oldStar = 0
		self.levelInfo.oldScore = 0
	end

	local addBuffs = GameInitBuffLogic:getInitBuffs()

	if addBuffs and #addBuffs > 0 then
		for k, v in ipairs(addBuffs) do 
			local d = {}
			d.buffType = v.buffType
			d.createType = v.createType
			d.propId = v.propId
			table.insert( self.buffs , d )
		end
	end

	self.levelInfo.currTopLevelId = UserManager:getInstance():getUserRef():getTopLevelId()
	self.levelInfo.currTopLevelFailCount = UserTagManager:getTopLevelFailCounts()
	self.levelInfo.currTopLevelLogicalFailCounts = UserTagManager:getTopLevelLogicalFailCounts()
	
end

function GamePlayContext:onLevelConfigLoadFinish()
	
end

function GamePlayContext:onGamePlayScenePushed()
	
	self:setData( "isJumpedLevelWhenStart" , JumpLevelManager:getLevelPawnNum( self.levelInfo.levelId ) > 0 )
	self:setData( "isHelpedLevelWhenStart" , UserManager:getInstance():hasAskForHelpInfo( self.levelInfo.levelId ) )
end

-- call in GameboardLogic initByConfig
function GamePlayContext:doGameInit( mainLogic )
	-- 记录AI种子信息
	self:setAISeedData(mainLogic)
 	-- 记录本关使用随机种子
 	self:setRandomSeed(mainLogic.randomSeed)
end

-- 进入到游戏场景才调用
function GamePlayContext:onGameInit( mainLogic )
	self.originLevelConfig = mainLogic.originLevelConfig
	self.theGamePlayType = mainLogic.theGamePlayType  --玩法模式
	self.levelType = self.levelInfo.levelType  --关卡模式，不同的关卡模式可能基于相同的玩法模式

	self.levelInfo.playType = self.theGamePlayType

	GameSpeedManager:startLevel( self.levelInfo.levelId )
	if GameSpeedManager:getGameSpeedSwitch() > 0 then
		if self.theGamePlayType == GameModeTypeId.CLASSIC_ID then
			GameSpeedManager:resuleDefaultSpeed()
		else
			GameSpeedManager:changeSpeedForFastPlay()
		end
	end
end

function GamePlayContext:onLevelWillEnd()
	self.levelWillEnd = true
end

function GamePlayContext:endLevel()
	
	local totalEndLevelCountDatas = LocalBox:getData( "totalEndLevelCount" , localDataKey ) or {}
	local levelkey = "l" .. tostring(self.levelInfo.levelId)
	if not totalEndLevelCountDatas[ levelkey ] then
		totalEndLevelCountDatas[ levelkey ] = 0
	end
	totalEndLevelCountDatas[ levelkey ] = totalEndLevelCountDatas[ levelkey ] + 1
	LocalBox:setData( "totalEndLevelCount" , totalEndLevelCountDatas , localDataKey )

	self:reset()

	StageInfoLocalLogic:clearStageInfo( UserManager.getInstance().user.uid )

	if GameSpeedManager:getGameSpeedSwitch() > 0 then
		GameSpeedManager:resuleDefaultSpeed()
	end
	GameSpeedManager:endLevel()

	if self.replayData then
		for k,v in pairs( self.replayData.actContext ) do
			if v == Thanksgiving2018CollectManager.getInstance():getReplayFlag() then
				Thanksgiving2018CollectManager.getInstance():setNextPlayShouldShowActCollectionForReplay( false )
			end
		end
	end

	if self.preStartContext then
		self.preStartContext:reset()
		self.preStartContext = nil
	end
end

function GamePlayContext:getTotalEndLevelCount()
	local totalEndLevelCountDatas = LocalBox:getData( "totalEndLevelCount" , localDataKey ) or {}
	local levelkey = "l" .. tostring(self.levelInfo.levelId)
	return totalEndLevelCountDatas[ levelkey ] or 0
end

function GamePlayContext:onPropGuided(value)
	self.guidedProp = value
end

function GamePlayContext:getGuideContext()
	return self.guideContext or {}
end

function GamePlayContext:getFeatureMap()
	return self.levelFeatureMap
end

function GamePlayContext:getGuidedProp()
	return self.guidedProp
end

function GamePlayContext:getPlayInfo()
	return self.playInfo
end

function GamePlayContext:revertPlayInfo( playInfo )
	for k, v in pairs(playInfo or {}) do
		if table.indexOf(_quests_keys, k) ~= nil then
			self.playInfo[k] = v
		end
	end
end

function GamePlayContext:getFilteredPlayInfoForAI( ... )
	local filteredPlayInfo = {}
	for k, v in pairs(self.playInfo or {}) do
		if not table.indexOf(_quests_keys, k) then
			filteredPlayInfo[k] = v
		end
	end
	return filteredPlayInfo
end

function GamePlayContext:getPlayInfoForAI()
	local filteredPlayInfo = self:getFilteredPlayInfoForAI()
	local playInfoForAI = ObstacleFootprintManager:getMergedFinalPlayInfo(filteredPlayInfo)
	return playInfoForAI
end

function GamePlayContext:updatePlayInfo( keyname , num, pIgnoreGamePlayStatus)

	local ignoreGamePlayStatus = false
	if pIgnoreGamePlayStatus ~= nil then
		ignoreGamePlayStatus = pIgnoreGamePlayStatus
	end

	if not ignoreGamePlayStatus then
		if GameBoardLogic:getCurrentLogic() and 
			( GameBoardLogic:getCurrentLogic().theGamePlayStatus == GamePlayStatus.kEnd 
				or GameBoardLogic:getCurrentLogic().theGamePlayStatus == GamePlayStatus.kBonus
				or GameBoardLogic:getCurrentLogic().theGamePlayStatus == GamePlayStatus.kAferBonus
			) then
			return
		end
	end

	--printx( 1 , "GamePlayContext:updatePlayInfo ---------------  " ,  keyname , num , GameBoardLogic:getCurrentLogic().theGamePlayStatus  )
	if self.playInfo and self.playInfo[keyname] then
		local count = tonumber( self.playInfo[keyname] )
		self.playInfo[keyname] = count + tonumber(num)
		--printx( 1 , table.tostring(self.playInfo) )
	end
end

function GamePlayContext:getPlayInfoDCObj()
	local obj = nil
	
	if self.playInfo then
		obj = {}

		obj.p1 = self.playInfo.line_create       --合成直线、竖线特效的数量
		obj.p2 = self.playInfo.wrap_create       --合成爆炸特效的数量
		obj.p3 = self.playInfo.bird_create       --合成魔力鸟的数量

		obj.p4 = self.playInfo.line_cover        --直线特效被其它特效（包括障碍放招）触发的计数
		obj.p5 = self.playInfo.line_match_swap   --直线特效参与三消被触发的计数

		obj.p6 = self.playInfo.wrap_cover        --区域特效被其它特效（包括障碍放招）触发的计数
		obj.p7 = self.playInfo.wrap_match_swap   --区域特效参与三消被触发的计数

		obj.p8 = self.playInfo.bird_cover        --魔力鸟被其它特效（包括障碍放招）触发的计数

		obj.p9 = self.playInfo.line_line_swap    --直线特效和直线特效交换的计数
		obj.p10 = self.playInfo.line_wrap_swap   --直线特效和区域特效交换的计数
		obj.p11 = self.playInfo.wrap_wrap_swap   --区域特效和区域特效交换的计数

		obj.p12 = self.playInfo.bird_color_swap  --魔力鸟和动物交换的计数
		obj.p13 = self.playInfo.bird_line_swap   --魔力鸟和直线特效交换的计数
		obj.p14 = self.playInfo.bird_wrap_swap   --魔力鸟和区域特效交换的计数
		obj.p15 = self.playInfo.bird_bird_swap   --魔力鸟和魔力鸟交换的计数
	end

	return obj
end

function GamePlayContext:getPlayInfoDCStr()
	local obj = self:getPlayInfoDCObj()
	local str = nil
	if obj then
		str = ""
		for i = 1 , 15 do

			str = str .. tostring( obj["p" .. tostring(i)] ) 

			if i < 15 then
				str = str .. "_"
			end
			
		end
	end

	return str
end

function GamePlayContext:getIdStr()
	if self.levelInfo then
		return self.levelInfo.idStr
	end
end

function GamePlayContext:encodeContextDataForReplay()
	local obj = {}
	-- printx(11, "==============================================")
	-- printx(11, "GamePlayContext:encodeContextDataForReplay")
	-- printx(11, "==============================================")
	if self.weeklyData then
		obj.dc1 = self.weeklyData.dailyDropPropCount
		obj.dc2 = self.weeklyData.dailyDropPropCount2
		obj.dp1 = self.summerWeeklyData.dropPropsPercent
		obj.dp2 = self.summerWeeklyData.orignalDropPropsPercent
		obj.prop= self.guidedProp
	end

	obj.levelInfo = table.copyValues(self.levelInfo)

	local mainLogic = GameBoardLogic:getInstance()
	obj.moleWeeklyGroupID = MoleWeeklyRaceConfig:getRealCurrGroupID(mainLogic.replayMode)
	obj.guideContext = self.guideContext
	-- printx(11, "set moleWeeklyGroupID", obj.moleWeeklyGroupID)

	obj.scoreBuffBottleInitAmount = ScoreBuffBottleLogic:getScoreBuffBottleInitAmount()
	-- printx(11, "GamePlayContext: set scoreBuffBottleInitAmount to context", obj.scoreBuffBottleInitAmount)


	if self.playInfo then
		-- obj.upl = self.playInfo.usePropLogInThisPlay
		-- obj.spfs = self.playInfo.satisfyPreconditionsForStrategy
		-- obj.ipu = self.playInfo.isPayUser
		-- obj.tupc = self.playInfo.totalUsePropCount
		-- obj.cnm = self.playInfo.colorNumMap

		obj.v1 = self.playInfo.killed_line
		obj.v2 = self.playInfo.killed_wrap
		obj.v3 = self.playInfo.killed_bird
		obj.v4 = self.playInfo.killed_animal_1
		obj.v5 = self.playInfo.killed_animal_2
		obj.v6 = self.playInfo.killed_animal_3
		obj.v7 = self.playInfo.killed_animal_4
		obj.v8 = self.playInfo.killed_animal_5
		obj.v9 = self.playInfo.killed_animal_6

	end

	if self.usePropList then
		local result = {}
		for _, v in ipairs(self.usePropList) do
			table.insert(result, {v.propId, v.step, v.pt})
		end
		obj.upl2 = result
	end

	obj.aiPropUsedTotalIndex = self.aiPropUsedTotalIndex
	obj.aiCostStepsArr = self.aiCostStepsArr
	obj.aiLeftStepsArr = self.aiLeftStepsArr
	obj.aiInterveneArr = self.aiInterveneArr
	obj.aiRepeatArr = self.aiRepeatArr
	obj.fuuuOverview = self.fuuuOverview
	return obj
end

function GamePlayContext:getPlayInfoKilledLine( ... )
	return self.playInfo.killed_line
end

function GamePlayContext:getPlayInfoKilledWrap( ... )
	return self.playInfo.killed_wrap
end

function GamePlayContext:getPlayInfoKilledBird( ... )
	return self.playInfo.killed_bird
end

function GamePlayContext:decodeContextDataForReplay(data)
	-- printx(11, "=========== =========== ============== ==========")
	-- printx(11, "GamePlayContext:decodeContextDataForReplay")
	-- printx(11, "=========== =========== ============== ==========")
	-- printx(11, debug.traceback())

	if data then

		local obj = {}

		obj.dailyDropPropCount = data.dc1 or 0
		obj.dailyDropPropCount2 = data.dc2 or 0
		self.weeklyData = obj

		obj = {}
		
		obj.dropPropsPercent = data.dp1 or 0
		obj.orignalDropPropsPercent = data.dp2 or 0
		self.summerWeeklyData = obj

		if data.levelInfo then
			self.levelInfo = table.clone(data.levelInfo)
			self.playId = self.levelInfo.idStr
		end
		self.guidedProp = data.prop

		self.guideContext = data.guideContext or createDefaultGuideContext()

		
		if self.playInfo then
			-- if data.upl then
			-- 	self.playInfo.usePropLogInThisPlay = data.upl
			-- end
			-- if data.spfs then
			-- 	self.playInfo.satisfyPreconditionsForStrategy = data.spfs
			-- end
			-- if data.tupc then
			-- 	self.playInfo.totalUsePropCount = data.tupc
			-- end
			-- if data.cnm then
			-- 	self.playInfo.colorNumMap = data.cnm
			-- end
			-- self.playInfo.isPayUser = data.ipu or false

			self.playInfo.killed_line = data.v1 or 0 
			self.playInfo.killed_wrap = data.v2 or 0 
			self.playInfo.killed_bird = data.v3 or 0 
			self.playInfo.killed_animal_1 = data.v4 or 0 
			self.playInfo.killed_animal_2 = data.v5 or 0 
			self.playInfo.killed_animal_3 = data.v6 or 0 
			self.playInfo.killed_animal_4 = data.v7 or 0 
			self.playInfo.killed_animal_5 = data.v8 or 0 
			self.playInfo.killed_animal_6 = data.v9 or 0 
		end
		

		-- printx(11, "get moleWeeklyGroupID", data.moleWeeklyGroupID)
		if data.moleWeeklyGroupID then
			MoleWeeklyRaceConfig:setGroupIDForRevert(data.moleWeeklyGroupID)
		end

		ScoreBuffBottleLogic:setInitAmountForReplay(data.scoreBuffBottleInitAmount)


		if self.usePropList then
			for _, v in ipairs(data.upl2 or {}) do
				table.insert(self.usePropList, {
					propId = v[1],
					step = v[2],
					pt = v[3],
				})
			end
		end

		self.aiPropUsedTotalIndex = data.aiPropUsedTotalIndex
		self.aiCostStepsArr = data.aiCostStepsArr
		self.aiLeftStepsArr = data.aiLeftStepsArr
		self.aiInterveneArr = data.aiInterveneArr
		self.aiRepeatArr = data.aiRepeatArr
		self.fuuuOverview = data.fuuuOverview
		return obj
	end

	return nil
end


function GamePlayContext:encodeWeeklyData()
	if self.weeklyData then
		local obj = {}

		obj.dc1 = self.weeklyData.dailyDropPropCount
		obj.dc2 = self.weeklyData.dailyDropPropCount2
		obj.dp1 = self.summerWeeklyData.dropPropsPercent
		obj.dp2 = self.summerWeeklyData.orignalDropPropsPercent
		obj.prop= self.guidedProp

		return obj
	end

	return nil
end

function GamePlayContext:decodeWeeklyData(data)
	if data then

		local obj = {}

		obj.dailyDropPropCount = data.dc1 or 0
		obj.dailyDropPropCount2 = data.dc2 or 0
		self.weeklyData = obj

		obj = {}
		
		obj.dropPropsPercent = data.dp1 or 0
		obj.orignalDropPropsPercent = data.dp2 or 0
		self.summerWeeklyData = obj

		self.guidedProp = data.prop

		return obj
	end

	return nil
end

function GamePlayContext:encodeNationDayData()
	if self.nationDayData then
		local obj = {}
		obj.vl = {}
		if self.nationDayData.buffList then
			for _, v in pairs(self.nationDayData.buffList) do
				local d = {}
				d.t = v.buffType
				d.v = v.value
				table.insert(obj.vl, d)
			end
		end
		obj.g = self.nationDayData.isGuideLevel
		return obj
	end

	return nil
end

function GamePlayContext:decodeNationDayData(data)
	if data then
		local obj = {}
		obj.buffList = {}
		obj.isGuideLevel = data.g
		if data.vl then
			for _, v in pairs(data.vl) do
				local d = {}
				d.buffType = v.t
				d.value = v.v
				d.frameType = 1
				d.headUrl = "1"
				table.insert(obj.buffList, d)
			end
		end
		self.nationDayData = obj
		return obj
	end

	return nil
end

function GamePlayContext:getCurrentReplayMode()
	if GameBoardLogic:getCurrentLogic() and GameBoardLogic:getCurrentLogic().replayMode then
		return GameBoardLogic:getCurrentLogic().replayMode
	end

	return ReplayMode.kNone
end

function GamePlayContext:isResumeReplayMode()
	if GameBoardLogic:getCurrentLogic() 
		and GameBoardLogic:getCurrentLogic().replayMode 
		and (GameBoardLogic:getCurrentLogic().replayMode == ReplayMode.kResume or GameBoardLogic:getCurrentLogic().replayMode == ReplayMode.kReview)
		then
		return true
	end

	return false
end

--[[
function GamePlayContext:encodeSummerWeeklyData()
	if self.summerWeeklyData then
		local obj = {}

		obj.dp1 = self.summerWeeklyData.dropPropsPercent
		obj.dp2 = self.summerWeeklyData.orignalDropPropsPercent

		return obj
	end

	return nil
end

function GamePlayContext:decodeSummerWeeklyData(data)
	if data then
		local obj = {}

		obj.dropPropsPercent = data.dp1
		obj.orignalDropPropsPercent = data.dp2

		self.summerWeeklyData = obj

		return obj
	end

	return nil
end
]]

function GamePlayContext:getTestInfoFileKey(key)
	return HeResPathUtils:getUserDataPath() .. "/" .. "PCTI_" .. tostring(key) .. "_" .. tostring( UserManager:getInstance():getUID() or "12345" ) .. ".ds"
end

function GamePlayContext:getTestInfo( key )
	if self.testInfo then
		return self.testInfo[key]
	end

	return nil
end

function GamePlayContext:getTestInfoLocalString( key )

	local datatext = nil

	local function _getTestInfoLocalString()
		local filePath = self:getTestInfoFileKey(key)

		local hFile, err = io.open(filePath, "r")
		if hFile and not err then
			datatext = hFile:read("*a")
			io.close(hFile)
		end
	end
	
	pcall( _getTestInfoLocalString )

	return datatext
end

function GamePlayContext:removeTestInfoLocalData( key )

	local function _removeTestInfoLocalData()
		local filePath = self:getTestInfoFileKey(key)
		os.remove(filePath)
	end
	pcall( _removeTestInfoLocalData )
end


function GamePlayContext:setTestInfo( key , info , flushToStorage , filterByUids )

	local function _setTestInfo()
		if not info then
			return
		end

		if type(info) ~= "string" and type(info) ~= "table" and type(info) ~= "number" and type(info) ~= "boolean" then
			return
		end

		if filterByUids and type(filterByUids) == "table" then
			local curruid = tostring( UserManager:getInstance():getUID() or "12345" )
			if not table.includes( filterByUids , curruid ) then
				return
			end
		end

		if not self.testInfo then
			self.testInfo = {}
		end

		if not self.testInfo[key] then
			self.testInfo[key] = {}
		end

		self.testInfo[key] = info

		if flushToStorage then

			local filePath = self:getTestInfoFileKey(key)
			printx(1 , "GamePlayContext:setTestInfo  filePath " , filePath)
			local datastr = ""
			if type(info) == "table" then
				datastr = table.serialize( info )
			else
				datastr = tostring(info)
			end
			Localhost:safeWriteStringToFile( datastr , filePath )
		end
	end

	pcall( _setTestInfo )
end

