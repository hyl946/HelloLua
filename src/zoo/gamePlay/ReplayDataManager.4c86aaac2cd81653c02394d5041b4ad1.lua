ReplayDataManager = {}
ReplayDataManager.lastCrashReplay = nil
ReplayDataManager.lastCrashReplayHasResumed = false
ReplayDataManager.lastLaunchHasCrashed = false

local checkReplayCacheFileName = "dnwInfo.rep"
local lastSuccessReplayFileName = "lsrf.rep"
local checkReplayDataFileName = "checkReplayData"
local maxReplayDefaultNum = 300
local maxReplayDefaultDayDelay = 14
local maxReplayNum = maxReplayDefaultNum
local maxReplayDayDelay = maxReplayDefaultDayDelay

local passLevelRankInfo = {}

ReplayDataEndType = table.const{
	
	kWin = 1 ,
	kFailed = 2 ,
	kQuit = 3 ,
	kTryAgain = 4 ,

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
	kReview = 13,			 --用于给玩家使用的回放模式
}

local function nowTime()
	return os.time() + (__g_utcDiffSeconds or 0)
end

local function rencode(str)
	local datalenth = string.len(str)
	local len1 = math.floor( datalenth / 6.8 )
	local len2 = math.ceil( len1 * 2.1 )
	local len3 = len2 + len1
	local len4 = len3 + len1
	local len5 = datalenth

	local str1 = string.sub( str , 1 , len1 ) 
	local str2 = string.sub( str , len1 +1 , len2 ) 
	local str3 = string.sub( str , len2 +1 , len3 ) 
	local str4 = string.sub( str , len3 +1 , len4 ) 
	local str5 = string.sub( str , len4 +1 , datalenth ) 

	--[[
	print("rdecode  str1 = " , str1)
	print("rdecode  str2 = " , str2)
	print("rdecode  str3 = " , str3)
	print("rdecode  str4 = " , str4)
	print("rdecode  str5 = " , str5)
	]]

	return str4 .. str3 .. str1 .. str5 .. str2
end

local function rdecode(str)
	local datalenth = string.len(str)
	local len1 = math.floor( datalenth / 6.8 )
	local len2 = math.ceil( len1 * 2.1 )
	local len3 = len2 + len1
	local len4 = len3 + len1
	local len5 = datalenth

	local l1 = len1
	local l2 = len2 - len1
	local l3 = len3 - len2
	local l4 = len4 - len3
	local l5 = len5 - len4

	--[[
	print("rdecode  len1 = " , len1)
	print("rdecode  len2 = " , len2)
	print("rdecode  len3 = " , len3)
	print("rdecode  len4 = " , len4)
	print("rdecode  len5 = " , len5)

	print("rdecode  l1 = " , l1)
	print("rdecode  l2 = " , l2)
	print("rdecode  l3 = " , l3)
	print("rdecode  l4 = " , l4)
	print("rdecode  l5 = " , l5)

	print( "LLL " , tonumber( l1 + l2 + l3 + l4 + l5) , datalenth ,  tonumber( l1 + l2 + l3 + l4 + l5) == datalenth )
	]]

	--[[
	local str1 = string.sub( str , datalenth - len1 + 1 , datalenth ) 
	local str2 = string.sub( str , datalenth - len2 + 1 , datalenth - len1 ) 
	local str3 = string.sub( str , 1 , tonumber(datalenth - len2) ) 
	]]
	local str1 = string.sub( str , l4 + l3 + 1 , l4 + l3 + l1 ) 
	local str2 = string.sub( str , datalenth - l2 + 1 , datalenth ) 
	local str3 = string.sub( str , l4 + 1 , l4 + l3 ) 
	local str4 = string.sub( str , 1 , l4 ) 
	local str5 = string.sub( str , l4 + l3 + l1 + 1 , l4 + l3 + l1 + l5 ) 

	--[[
	print("rdecode  str1 = " , str1)
	print("rdecode  str2 = " , str2)
	print("rdecode  str3 = " , str3)
	print("rdecode  str4 = " , str4)
	print("rdecode  str5 = " , str5)
	]]

	return str1 .. str2 .. str3 .. str4 .. str5
end

local function getCurrUid()
	return UserManager:getInstance():getUID() or "12345"
end

local function getCurrUdid()
	return MetaInfo:getInstance():getUdid() or "hasNoUdid"
end

function ReplayDataManager:formatReplaySteps(replaySteps, version)

	local function resovlePos(pos)
		local params = nil
		if type(pos) == "string" then
			 params = string.split(pos, ",")
		end
		if params and #params > 1 then
			return tonumber(params[1]), tonumber(params[2])
		else
			return 0, 0
		end
	end

	if tonumber(version) == 2 then
		local ret = {}
		if replaySteps then
			for _, v in ipairs(replaySteps) do
				local params = string.split(v, ":")
				if params[1] == "p" then
					local x1, y1 = resovlePos(params[4])
					local x2, y2 = resovlePos(params[5])
					table.insert(ret, { prop = tonumber(params[2]) , pt = tonumber(params[3]) , x1 = x1, y1 = y1, x2 = x2, y2 = y2  })
				else
					local x1, y1 = resovlePos(params[1])
					local x2, y2 = resovlePos(params[2])
					table.insert(ret, {x1 = x1, y1 = y1, x2 = x2, y2 = y2})
				end
			end
		end
		-- if _G.isLocalDevelopMode then printx(0, "formatReplaySteps:", table.tostring(ret)) end
		return ret
	else
		return replaySteps
	end
end

function ReplayDataManager:getHasReplayOnInitAndResumeFailed()
	return self.hasReplayOnInitAndResumeFaile or false
end

function ReplayDataManager:setHasReplayOnInitAndResumeFailed(value)
	self.hasReplayOnInitAndResumeFaile = value
end

function ReplayDataManager:getCurrLevelReplayData()
	return self.currLevelReplayData
end

function ReplayDataManager:clearCurrLevelReplayData()
	self.currLevelReplayData = nil
end

function ReplayDataManager:getCurrLevelReplayDataCopyWithoutSectionData()
	local datas = {}

	if self.currLevelReplayData then
		for k,v in pairs(self.currLevelReplayData) do
			if k ~= "sectionData"
				and k ~= "lastSectionData" then

				datas[k] = v

			end
		end
	end

	return datas
end

function ReplayDataManager:updatePropBagInfo()
	local datas = {}

	local function check( propId )
		local prop = UserManager.getInstance():getUserProp( tonumber(propId) )
		local num = prop and prop.num or 0
		if num > 0 then
			datas["p" .. tostring(propId)] = num
		end
	end

	check( ItemType.ADD_FIVE_STEP )
	check( ItemType.ADD_BOMB_FIVE_STEP )
	check( ItemType.ADD_15_STEP )
	check( ItemType.TIMELIMIT_ADD_BOMB_FIVE_STEP )
	check( ItemType.TIMELIMIT_48_ADD_BOMB_FIVE_STEP )
	check( ItemType.TIMELIMIT_ADD_FIVE_STEP )

	
	self.currLevelReplayData.propBagInfo = datas
end

function ReplayDataManager:initPropUseInfo()
	self.currLevelReplayData.propUseInfo = {}
end

function ReplayDataManager:updatePropUseInfo( propId )
	if self.currLevelReplayData and self.currLevelReplayData.propUseInfo then

		if propId == ItemType.ADD_FIVE_STEP or
			propId == ItemType.ADD_BOMB_FIVE_STEP or
			propId == ItemType.ADD_15_STEP or
			propId == ItemType.TIMELIMIT_ADD_BOMB_FIVE_STEP or
			propId == ItemType.TIMELIMIT_48_ADD_BOMB_FIVE_STEP or
			propId == ItemType.TIMELIMIT_ADD_FIVE_STEP
			then

			if not self.currLevelReplayData.propUseInfo["p" .. tostring(propId)] then
				self.currLevelReplayData.propUseInfo["p" .. tostring(propId)] = 1
			else
				self.currLevelReplayData.propUseInfo["p" .. tostring(propId)] = self.currLevelReplayData.propUseInfo["p" .. tostring(propId)] + 1
			end
		end
	end
end

function ReplayDataManager:onStartLevel(gameBoardLogic)

	--printx( 1 , "   ReplayDataManager:onStartLevel  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	--self.replaySteps = {}
	self.snapshotData = {}

	self.uploadReplayReasons = {}
	self.gameBoardLogic = gameBoardLogic

	if gameBoardLogic.replayMode == ReplayMode.kNone 
		or gameBoardLogic.replayMode == ReplayMode.kConsistencyCheck_Step1 
		or gameBoardLogic.replayMode == ReplayMode.kConsistencyCheck_Step2 
		or gameBoardLogic.replayMode == ReplayMode.kAutoPlayCheck 
		or (gameBoardLogic.replayMode == ReplayMode.kMcts and _G.launchCmds.domain)
		then

		self.setWriteReplayEnable = true

		local replay = {}

		replay.ver = 2
		replay.PDTLogic = gameBoardLogic.logicVer
		replay.fallingVer = UseNewFallingLogic
		-- replay.allowRepeatGuide = gameBoardLogic.PlayUIDelegate.gamePlayScene.allowRepeatGuide
		--replay.idStr = tostring(getCurrUid()) .. tostring(getCurrUdid()) .. tostring(nowTime())
		replay.idStr = GamePlayContext:getInstance():getIdStr()
		replay.info = "NRCD2050"--NewReplayCheckData 搜索用关键字
		replay.passed = 0
		replay.score = -1
		replay.startTime = gameBoardLogic.stageStartTime

		replay.uid = getCurrUid()
		replay.udid = getCurrUdid()

		replay.level = gameBoardLogic.level
		replay.meta_level = LevelMapManager.getInstance():getMetaLevelId(gameBoardLogic.level)
		replay.randomSeed = gameBoardLogic.randomSeed
		replay.curMd5 = ResourceLoader.getCurVersion() 	-- game version
		replay.curConfigMd5 = LevelMapManager.getInstance():getLevelUpdateVersion() -- level update version
		replay.mini = _G.__use_small_res
		replay.useGuideRandomSeed = gameBoardLogic.useGuideRandomSeed

		replay.actContext = {}

		replay.replaySteps = {}
		-- 是否触发神奇掉落规则
		replay.hasDropBuff =  false
		if gameBoardLogic.dropBuffLogic and gameBoardLogic.dropBuffLogic.canBeTriggered then
			replay.hasDropBuff = true
		end
		replay.selectedItemsData = {}
		--[[
		--不能在这里初始化，必须放到ReplayDataManager:updateSelectedItemsData()里，因为要兼容引导+3步的情况，这时没有selectedItemsData不代表此关没用前置道具
		for k, v in pairs(gameBoardLogic.selectedItemsData) do 
			local v_r = {}
			v_r.id = v.id
			v_r.destXInWorldSpace = v.destXInWorldSpace
			v_r.destYInWorldSpace = v.destYInWorldSpace
			table.insert(replay.selectedItemsData, v_r)
		end
		--]]

		replay.ctx = GamePlayContext:getInstance():encodeContextDataForReplay()
		--replay.summerWeeklyData = table.copyValues(gameBoardLogic.summerWeeklyData)
		--replay.dragonBoatData = table.copyValues(gameBoardLogic.dragonBoatData)
		--replay.dragonBoatPropConfig = table.copyValues(gameBoardLogic.dragonBoatPropConfig)

		replay.daManager = LevelDifficultyAdjustManager:getDAManager():getDataForReplayData()
		replay.userGroupInfo = LevelDifficultyAdjustManager:getUserGroupInfoForReplay()

		replay.currTime = nowTime()
		replay.rct = os.date("%Y%m%d%H%M%S", replay.currTime) -- readale current time

		replay.context = {}

		replay.dieState = nil -- 可能卡死的情况
		replay.userActs = nil -- 用户行为，如：截屏

		replay.strategyID = LevelDifficultyAdjustManager:getCurrStrategyID()
		replay.aiCoreInfo = LevelDifficultyAdjustManager:getAICoreInfo()

		if replay.strategyID and replay.strategyID >= 14000000 then

			local datastr , staticTotalSteps = LevelDifficultyAdjustManager:getLevelTargetProgressDataStrForReplay( replay.level )
			replay.tplist = datastr
			replay.tpTotalSteps = staticTotalSteps

		end

		replay.strategyDCInfo = {}

		replay.strategyDCInfo.nd1 = LevelDifficultyAdjustManager:getStrategyIDList() or {}
		--if #replay.strategyDCInfo.nd1 == 0 then replay.strategyDCInfo.nd1 = nil end

		replay.strategyDCInfo.nd2 = LevelDifficultyAdjustManager:getStrategyDataList() or {}
		--if #replay.strategyDCInfo.nd2 == 0 then replay.strategyDCInfo.nd2 = nil end

		replay.strategyDCInfo.nd3 = LevelDifficultyAdjustManager:getLastUnactivateReason()
		if replay.strategyDCInfo.nd3 == 0 then replay.strategyDCInfo.nd3 = nil end

		-- if (not replay.strategyDCInfo.nd1) and (not replay.strategyDCInfo.nd2) and (not replay.strategyDCInfo.nd3) then
		-- 	replay.strategyDCInfo = nil
		-- end

 		--table.insert(gameBoardLogic.allReplay, replay)

		if gameBoardLogic.initAdjustData then
			replay.vsdata = {}
			replay.vsdata.r = gameBoardLogic.initAdjustData.centerR
			replay.vsdata.c = gameBoardLogic.initAdjustData.centerC
			replay.vsdata.oti = gameBoardLogic.initAdjustData.oringinTypeIndex
			replay.vsdata.ti = gameBoardLogic.initAdjustData.typeIndex
			replay.vsdata.pi = gameBoardLogic.initAdjustData.patternIndex
		end

		self.currLevelReplayData = replay
		--self:updateSelectedItemsData(gameBoardLogic.selectedItemsData)
		local buffsV2 = GameInitBuffLogic:getInitBuffs()
		self:updateBuffsData( buffsV2 , 1 )

		-- local buffsV3 = GameInitBuffLogic:getInitBuffPassedPlanList()
		-- self:updateBuffsData( buffsV3 , 2 )

		-- replay.buffAnimeType

		if _G.useSectionWhenCrash or MaintenanceManager:getInstance():isEnabledInGroup( "CrashResumeNew" , "useSection" , getCurrUid() ) then
			local sectionData = SectionResumeManager:getCurrSectionData()
			if sectionData then
				replay.sectionData = SectionResumeManager:encodeBySection( sectionData )
			end
		end

		replay.allowResumeCount = 5

		if CollectStarsYEMgr.getInstance():isBuffIngameEffective() then
			replay.act5003Effctive = true
		end

		replay.scoreLogs = {} 
		
		-- local FTWLocalLogic = require 'zoo.localActivity.FindingTheWay.FindingTheWayLocalLogic'
		-- if FTWLocalLogic:isFTWEnabled() then
		-- 	replay.ftwData = FTWLocalLogic:getDataForRevert()
		-- end

		self:updatePropBagInfo()
		self:initPropUseInfo()
	elseif gameBoardLogic.replayMode == ReplayMode.kResume then
		self.setWriteReplayEnable = true
		self.currLevelReplayData = gameBoardLogic.PlayUIDelegate.replayData
		self.currLevelReplayData.isResumeReplay = true
		if self.currLevelReplayData.allowResumeCount and self.currLevelReplayData.allowResumeCount > 0 then
			self.currLevelReplayData.allowResumeCount = self.currLevelReplayData.allowResumeCount - 1
		else
			self.currLevelReplayData.allowResumeCount = 0
		end
		self:updatePropBagInfo()
		self:initPropUseInfo()
	elseif gameBoardLogic.replayMode == ReplayMode.kReview then
		self.setWriteReplayEnable = false
		self.currLevelReplayData = gameBoardLogic.PlayUIDelegate.replayData
		self.currLevelReplayData.isResumeReplay = true
		self.currLevelReplayData.allowResumeCount = 0
		self:updatePropBagInfo()
		self:initPropUseInfo()
	elseif gameBoardLogic.replayMode == ReplayMode.kSectionResume then
		self.setWriteReplayEnable = true
		self.currLevelReplayData = gameBoardLogic.PlayUIDelegate.replayData
		self.currLevelReplayData.isSectionResumeReplay = true
		if self.currLevelReplayData.allowResumeCount and self.currLevelReplayData.allowResumeCount > 0 then
			self.currLevelReplayData.allowResumeCount = self.currLevelReplayData.allowResumeCount - 1
		else
			self.currLevelReplayData.allowResumeCount = 0
		end
		self:updatePropBagInfo()
		self:initPropUseInfo()
	else
		self.setWriteReplayEnable = false
		self.currLevelReplayData = nil
	end

	if AskForHelpManager:getInstance():isInMode() then
		self.setWriteReplayEnable = false
		self.currLevelReplayData = nil
	end

	----------------------------------------------
	--注意，以下两行顺序敏感
	self:checkNeedFlushReplayDataByCache() --先检测本地有没有已存在的缓存文件，有的话先合并

	if gameBoardLogic.replayMode == ReplayMode.kNone then --只有正常打关才记录
		self:flushReplayCache() --将本次闯关录像写入本地缓存文件
	end
	
	----------------------------------------------
	if UserManager:getInstance().global.maxReplayNum then
		maxReplayNum = tonumber(UserManager:getInstance().global.maxReplayNum)
	else
		maxReplayNum = maxReplayDefaultNum
	end

	if UserManager:getInstance().global.maxReplayDayDelay then
		maxReplayDayDelay = tonumber(UserManager:getInstance().global.maxReplayDayDelay)
	else
		maxReplayDayDelay = maxReplayDefaultDayDelay
	end

	if not _G.RDM_ScreenShotLitener or _G.RDM_ScreenShotLitener ~= ReplayDataManager.kScreenShotLitener then
		if _G.RDM_ScreenShotLitener then
			GlobalEventDispatcher:getInstance():removeEventListener(kGlobalEvents.kUserTakeScreenShot, _G.RDM_ScreenShotLitener)
			_G.RDM_ScreenShotLitener = nil
		end
		_G.RDM_ScreenShotLitener = function()
			ReplayDataManager:onTakeScreenSnapshot()
		end
		ReplayDataManager.kScreenShotLitener = _G.RDM_ScreenShotLitener
		GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kUserTakeScreenShot, _G.RDM_ScreenShotLitener)
	end

	self:checkNeedSetActContextWhenLevelStart()
end

function ReplayDataManager:updateGamePlayContext(forceFlush, noIO)
	if self.gameBoardLogic and ( forceFlush or self.gameBoardLogic.replayMode == ReplayMode.kNone ) then
		if self.currLevelReplayData then
			self.currLevelReplayData.ctx = GamePlayContext:getInstance():encodeContextDataForReplay()
			if not noIO then
				self:flushReplayCache()
			end
		end
	end
end

function ReplayDataManager:updateGameScore( forceFlush, noIO )
	if self.gameBoardLogic and ( forceFlush or self.gameBoardLogic.replayMode == ReplayMode.kNone ) then
		if self.currLevelReplayData and self.currLevelReplayData.scoreLogs then
			local index = table.size(self.currLevelReplayData.scoreLogs) + 1
			self.currLevelReplayData.scoreLogs["n" .. index] = self.gameBoardLogic.totalScore
			printx(61, '"n" .. index', self.gameBoardLogic.totalScore)
			if not noIO then
				self:flushReplayCache()
			end
		end
	end
end

function ReplayDataManager:updateRankRaceContext(forceFlush, data)
	if self.gameBoardLogic and ( forceFlush or self.gameBoardLogic.replayMode == ReplayMode.kNone ) then
		if self.currLevelReplayData then
			self.currLevelReplayData.rankRaceCtx = data
			self:flushReplayCache()
		end
	end
end

function ReplayDataManager:updateNationDayCtxData()
	if self.gameBoardLogic and self.gameBoardLogic.replayMode == ReplayMode.kNone then
		if self.currLevelReplayData then
			self.currLevelReplayData.ndCtx = GamePlayContext:getInstance():encodeNationDayData()
			self:flushReplayCache()
		end
	end
end

function ReplayDataManager:updateBuffsData(addBuffs , ver)
	if self.currLevelReplayData and addBuffs and #addBuffs > 0 then

		if ver == 1 then
			if not self.currLevelReplayData.buffsV2 then
				self.currLevelReplayData.buffsV2 = {}
			end

			for k, v in pairs(addBuffs) do 
				local d = {}
				d.bt = v.buffType
				d.ct = v.createType
				d.pid = v.propId
				table.insert( self.currLevelReplayData.buffsV2, d )
			end
		elseif ver == 2 then
			if not self.currLevelReplayData.buffsV3 then
				self.currLevelReplayData.buffsV3 = {}
			end

			for k, v in pairs(addBuffs) do 
				local d = {}
				d.bt = v.buffType
				d.ct = v.createType
				d.pid = v.propId
				table.insert( self.currLevelReplayData.buffsV3, d )
			end
		end
		
	end
end

function ReplayDataManager:updateSelectedItemsData(selectedItemsData)
	--[[前置道具已被buff替代
	if self.currLevelReplayData and self.currLevelReplayData.selectedItemsData then
		for k, v in pairs(selectedItemsData) do 
			local v_r = {}
			v_r.id = v.id
			v_r.destXInWorldSpace = v.destXInWorldSpace
			v_r.destYInWorldSpace = v.destYInWorldSpace
			table.insert( self.currLevelReplayData.selectedItemsData, v_r )
		end
	end
	]]
end

function ReplayDataManager:onUpdateContext()
	--printx( 1 , "   ReplayDataManager:onUpdateContext  self.gameBoardLogic = " , self.gameBoardLogic , "  self.currLevelReplayData = " , self.currLevelReplayData)
	local function doUpdateContext()
		if self.gameBoardLogic and self.currLevelReplayData then
			if self.gameBoardLogic.fsm then
				local fsm = self.gameBoardLogic.fsm
				if fsm.currentState == fsm.waitingState then
					self.currLevelReplayData.context.currState = "waiting"
				elseif fsm.currentState == fsm.fallingMatchState then
					self.currLevelReplayData.context.currState = "fallingMatch"
					local stableFSM = fsm.fallingMatchState.stableFSM
					if stableFSM then

						if stableFSM.currentState then
							self.currLevelReplayData.context.currStable = stableFSM.currentState:getClassName()
						end

						if stableFSM.priorityLogic then
							self.currLevelReplayData.context.priorityLogic = stableFSM.priorityLogic
						end
					end

				elseif fsm.currentState == fsm.swapState then
					self.currLevelReplayData.context.currState = "swap"
				elseif fsm.currentState == fsm.usePropState then
					self.currLevelReplayData.context.currState = "useProp"
				end
			end
		end
	end
	pcall(doUpdateContext)
end

function ReplayDataManager:onPassLevel(result , totalScore)

	if self.currLevelReplayData then
		self.currLevelReplayData.passed = result

		self:onUpdateContext()

		if totalScore then
			self.currLevelReplayData.score = totalScore
		end

		if self.gameBoardLogic.replayMode == ReplayMode.kNone then
			if result == ReplayDataEndType.kWin then
				self:flushToLastSuccessReplayCache()
			end
		end

		self:flushReplayCache()
	end

	self:checkNeedFlushReplayDataByCache()

	self.gameBoardLogic = nil
end

function ReplayDataManager:setReplayId(id)
	--printx( 1 , "   ReplayDataManager:setReplayId ----------------------------- " , id)
	if self.currLevelReplayData then
		--printx( 1 , "  ReplayDataManager:setReplayId  2222")
		self.currLevelReplayData.rid = id
	end

	if self.snapshotData then
		self.snapshotData.rid = id
	end
end

function ReplayDataManager:addReplayStep( item )
	if item and self.setWriteReplayEnable and self.currLevelReplayData and self.currLevelReplayData.replaySteps then
		
		if self.gameBoardLogic and self.gameBoardLogic.totalScore and tonumber(self.gameBoardLogic.totalScore) > 0 then
			self.currLevelReplayData.score = self.gameBoardLogic.totalScore
		end

		local formatItem = nil
		if item.prop then
			if not item.pt then item.pt = 0 end
			formatItem = string.format("p:%d:%d:%d,%d:%d,%d", item.prop, item.pt , item.x1 or 0, item.y1 or 0, item.x2 or 0, item.y2 or 0)
			self:updatePropUseInfo( tonumber(item.prop) )
		else
			formatItem = string.format("%d,%d:%d,%d", item.x1 or 0, item.y1 or 0, item.x2 or 0, item.y2 or 0)

			self.currLevelReplayData.dieState = nil
		end

		if self.gameBoardLogic 
			and self.gameBoardLogic.theGamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID 
			and SeasonWeeklyRaceManager.getInstance() 
			and type(SeasonWeeklyRaceManager.getInstance().getReplayPassFriendInfo) == "function" then

			self.currLevelReplayData.weeklySubmarineData = {}

			local nextData , nnextData = SeasonWeeklyRaceManager.getInstance():getReplayPassFriendInfo( self.gameBoardLogic:getTargetCount() )

			self.currLevelReplayData.weeklySubmarineData[1] = nextData
			self.currLevelReplayData.weeklySubmarineData[2] = nnextData
		end

		table.insert(self.currLevelReplayData.replaySteps, formatItem)

		self.currLevelReplayData.lastSectionData = self.currLevelReplayData.sectionData
		self.currLevelReplayData.sectionData = nil
		self:flushReplayCache()

	end
end

function ReplayDataManager:updateCurrSectionDataToReplay()
	if not _G.useSectionWhenCrash and not MaintenanceManager:getInstance():isEnabledInGroup( "CrashResumeNew" , "useSection" , getCurrUid() ) then
		return
	end

	local sectionData = SectionResumeManager:getCurrSectionData()
	if sectionData and self.currLevelReplayData then
		self.currLevelReplayData.sectionData = SectionResumeManager:encodeBySection( sectionData )
		self.currLevelReplayData.lastSectionData = nil
		self:flushReplayCache()
	end
end

function ReplayDataManager:rpEncode( dataTable )
	
	if not dataTable then return nil end

	local str1 = amf3.encode( dataTable )
	local str2 = mime.b64(str1)
	local finStr = rencode( str2 )

	return finStr
end

function ReplayDataManager:rpDecode( dataStr )

	if not dataStr then return nil end

	local definStr = rdecode( dataStr )
	local str1 = mime.unb64(definStr)
	local dataTable = amf3.decode(str1) or {}

	return dataTable
end

function ReplayDataManager:flushToLastSuccessReplayCache( ... )
	if not self.currLevelReplayData or 
		not self.currLevelReplayData.replaySteps then
		return
	end
	local function doFlushReplayCache()
		local lastSuccessReplayPathname = HeResPathUtils:getUserDataPath() .. "/" .. lastSuccessReplayFileName
		local finStr = self:rpEncode( self.currLevelReplayData )
		Localhost:safeWriteStringToFile(finStr, lastSuccessReplayPathname)
	end

	if self.setWriteReplayEnable then
		pcall(doFlushReplayCache)
	end
end

function ReplayDataManager:readLastSuccessReplayCache( ... )
	local lastSuccessReplayPathname = HeResPathUtils:getUserDataPath() .. "/" .. lastSuccessReplayFileName
	return self:readAndDecodeLocalReplayData(lastSuccessReplayPathname)
end


function ReplayDataManager:flushReplayCache()

	if maxReplayNum <= 0 then
		return
	end

	if not self.currLevelReplayData or 
		not self.currLevelReplayData.replaySteps then
		return
	end

	local function doFlushReplayCache()
		local checkReplayCachePath = HeResPathUtils:getUserDataPath() .. "/" .. checkReplayCacheFileName
		--local checkReplayCacheText = table.serialize( self.currLevelReplayData )

		local finStr = self:rpEncode( self.currLevelReplayData )
		Localhost:safeWriteStringToFile(finStr, checkReplayCachePath)

		if __ANDROID and _G.OutPutTestReplayData then
			local localFileTestPath = "//sdcard/AAA_LastCrashReplay.txt"
			local strTest = table.serialize( self.currLevelReplayData )
			Localhost:safeWriteStringToFile( strTest , localFileTestPath)
		end
		
	end

	pcall(doFlushReplayCache)
end

function ReplayDataManager:readAndDecodeLocalReplayData(pathname)
	local checkReplayCachePath = pathname or (HeResPathUtils:getUserDataPath() .. "/" .. checkReplayCacheFileName)
	local checkReplayCacheText = nil
	
	local hFile, err = io.open(checkReplayCachePath, "rb")
	if hFile and not err then
		checkReplayCacheText = hFile:read("*a")
		io.close(hFile)
	end

	local replayCache = self:rpDecode( checkReplayCacheText )
	return replayCache
end

function ReplayDataManager:checkNeedFlushReplayDataByCache( checkResultCallback )

	local function doCheckNeedFlushReplayDataByCache()

		local replayCache = self:readAndDecodeLocalReplayData()

		--local replayCache = table.deserialize(checkReplayCacheText) or {}
		
		if replayCache and replayCache.level and type(replayCache.level) == "number" then
			-- Need Flush Replay Data By Cache
			local sectionData = replayCache.sectionData
			local lastSectionData = replayCache.lastSectionData
			replayCache.sectionData = nil
			replayCache.lastSectionData = nil

			local returnTabel = table.clone( replayCache )

			returnTabel.sectionData = sectionData
			returnTabel.lastSectionData = lastSectionData

			local result = self:flushReplayDataByCache( replayCache )

			if checkResultCallback then
				checkResultCallback( returnTabel )
			end
		else
			if checkResultCallback then
				checkResultCallback( nil )
			end
		end
	end
	
	pcall(doCheckNeedFlushReplayDataByCache)
end

function ReplayDataManager:flushReplayDataByCache(replayCache)

	--[[
	if tostring(getCurrUid()) ~= tostring(replayCache.uid) then
		return false
	end

	if tostring(replayCache.udid) == "hasNoUdid" or tostring(getCurrUdid()) ~= tostring(replayCache.udid) then
		return false
	end
	]]

	local function removeFiles(path, isDir)
		if HeFileUtils:exists(path) then 
			if isDir then 
				return HeFileUtils:removeDir(path)
			else
				return HeFileUtils:removeFile(path)
			end
		end
		return true
	end

	local checkReplayCachePath = HeResPathUtils:getUserDataPath() .. "/" .. checkReplayCacheFileName

	if not removeFiles(checkReplayCachePath , false) then
		DcUtil:crashResumeDeleteFileFailed( replayCache.idStr )
	end
   	--os.remove(checkReplayCachePath)


	if replayCache and replayCache.weeklySubmarineData then
		replayCache.weeklySubmarineData = nil --这个周赛数据仅用于闪退恢复，不真正保存，因为很大，可能造成DC打点被截断
	end

	if maxReplayNum <= 0 then
		return true
	end

	local checkReplayDataPath = HeResPathUtils:getUserDataPath() .. "/" .. checkReplayDataFileName .. "_" .. tostring( replayCache.uid ) .. ".rep"

	local replayData = self:readCheckReplayData( checkReplayDataPath )

	if tostring(replayCache.udid) == "hasNoUdid" or tostring(getCurrUdid()) ~= tostring(replayCache.udid) or tostring(replayData.udid) ~= tostring(replayCache.udid) then
		replayData = {}
		replayData.udid = getCurrUdid()
		replayData.datas = {}
	end

	replayCache.uid = nil
	replayCache.udid = nil
	replayCache.idStr = nil
	table.insert( replayData.datas , replayCache )

	self:uploadReplayIfNeeded(replayCache)

	if #replayData.datas > maxReplayNum then
		local needRemoveNum = #replayData.datas - maxReplayNum
		local newReplayData = {}
		newReplayData.udid = replayData.udid
		newReplayData.datas = {}
		for i = tonumber(needRemoveNum + 1) , tonumber(needRemoveNum + maxReplayNum) do
			table.insert( newReplayData.datas , replayData.datas[i] )
		end

		replayData = newReplayData
	end

	local newReplayData = {}
	newReplayData.udid = replayData.udid
	newReplayData.datas = {}
	local nowtime = nowTime()

	for i = 1 , #replayData.datas do
		local leveldata = replayData.datas[i]

		if nowtime - leveldata.currTime <= tonumber(3600*24*maxReplayDayDelay) then
			table.insert( newReplayData.datas , leveldata )
		end
	end
	replayData = newReplayData

	if replayData and replayData.datas and #replayData.datas > 0 then
		local newDataText = table.serialize( replayData )
		Localhost:safeWriteStringToFile( newDataText , checkReplayDataPath)
	end

   	return true
end

function ReplayDataManager:createTestReplayData()

end

function ReplayDataManager:readCheckReplayData( filePath )
	local checkReplayDataPath = HeResPathUtils:getUserDataPath() .. "/" .. checkReplayDataFileName .. "_" .. tostring(getCurrUid()) .. ".rep"

	if filePath ~= nil then
		checkReplayDataPath = filePath
	end

	local checkReplayDataText = nil
	
	local hFile, err = io.open(checkReplayDataPath, "rb")
	if hFile and not err then
		checkReplayDataText = hFile:read("*a")
		io.close(hFile)
	end

	local defaultData = {}
	defaultData.udid = getCurrUdid()
	defaultData.datas = {}

	local replayData = table.deserialize(checkReplayDataText) or defaultData
	--local replayData = amf3.decode(checkReplayDataText) or defaultData

	return replayData
end

function ReplayDataManager:checkNeedResumeGamePlayByReplayData()
	if self.lastLaunchHasCrashed and self.lastCrashReplay and not self.lastCrashReplayHasResumed then
		return true
	end

	return false
end

function ReplayDataManager:getLastCrashReplay()
	return self.lastCrashReplay
end

function ReplayDataManager:deletLastCrashReplay()

	local function doDeletLastCrashReplay()
		local checkReplayCachePath = HeResPathUtils:getUserDataPath() .. "/" .. checkReplayCacheFileName
   		os.remove(checkReplayCachePath)

   		self.lastCrashReplay = nil
	end
	

	pcall(doDeletLastCrashReplay)
end

function ReplayDataManager:checkLastLaunchHasCrashedInLevel()
	return self.lastLaunchHasCrashed
end

function ReplayDataManager:getLastCrashReplayHasResumed()
	return self.lastCrashReplayHasResumed
end

function ReplayDataManager:setLastCrashReplayHasResumed(value)
	self.lastCrashReplayHasResumed = value
end

function ReplayDataManager:__checkUploadReplay(uploadReplay)
	uploadReplay = uploadReplay or 0
	uploadReplay = tonumber(uploadReplay)

	local cNum = 1000000000
	if uploadReplay >= cNum then

		local actType = math.floor( uploadReplay / cNum )
		local levelId = math.floor( ( uploadReplay - (cNum * actType) ) / 100 )

		if actType == 1 then
			self:forceToUpload( levelId , true , false)
		elseif actType == 2 then
			self:forceToUpload( levelId , false , true)
		elseif actType == 3 then
			self:forceToUpload( levelId , true , true)
		end

	elseif uploadReplay == 1 then
		self:forceToUpload( 0 , true , false)
	elseif uploadReplay == 2 then
		self:forceToUpload( 0 , false , true)
	elseif uploadReplay == 3 then
		self:forceToUpload( 0 , true , true)
	else
		self:forceToUpload( 0 , true , false)
	end
end

function ReplayDataManager:checkUploadReplayByCommonEvent(datas)
	--printx( 1 , "checkUploadReplayByCommonEvent  ------!!!!!!!!!!!!!!!!!!!!------  datas:" , datas )

	local uploadReplay = datas or 0
	uploadReplay = tonumber(uploadReplay)
	self:checkForceToUploadReplay( uploadReplay )
end

function ReplayDataManager:checkForceToUploadReplay( uploadReplay )
	--printx( 1 , "ReplayDataManager:checkForceToUploadReplay     uploadReplay" , uploadReplay )
	local uploadReplay = uploadReplay or 0

	local function checkCallback(replayData)
		if replayData then

			self.lastCrashReplay = replayData
			self.lastCrashReplayHasResumed = false
			self.lastLaunchHasCrashed = true

		end
	end

	self:checkNeedFlushReplayDataByCache( checkCallback )

	if uploadReplay == 0 and UserManager:getInstance() and UserManager:getInstance().userExtend and UserManager:getInstance().userExtend.uploadReplay then
		uploadReplay = tonumber( UserManager:getInstance().userExtend.uploadReplay )
	end

	local function updateTestInfo()
		local testInfoStr = GamePlayContext:getInstance():getTestInfoLocalString("levelStartProgress")
		if testInfoStr then
			local data = table.deserialize( testInfoStr )
			GamePlayContext:getInstance():removeTestInfoLocalData("levelStartProgress")

			if tonumber(data.p) ~= 202 and tonumber(data.p) ~= 999 then
				he_log_error( "PCTI  " .. testInfoStr )
			end
		end
	end

	if uploadReplay and uploadReplay > 0 then
		self:__checkUploadReplay( uploadReplay )
	end

	--pcall(updateTestInfo)
end

function ReplayDataManager:forceToUpload( levelId , traceToBI , traceToServer )

	--printx( 1 , "ReplayDataManager:forceToUpload  ----------------" , levelId , traceToBI , traceToServer )
	if self.lastForceToUploadTime and tonumber(os.time()) - tonumber(self.lastForceToUploadTime) < 10 then
		return
	end
	self.lastForceToUploadTime = os.time()

	local function doForceToUpload()
		local replayData = self:readCheckReplayData()

		--printx( 1 , "ReplayDataManager:forceToUpload   replayData =" , replayData , tostring(replayData.udid) , tostring(getCurrUdid()) , #replayData.datas)
		local datalist = {}

		if not replayData then
			local http = OpNotifyHttp.new(true)
			http:load( OpNotifyType.kReplayDataUploaded , -1 )
			return
		end

		if tostring(replayData.udid) ~= tostring(getCurrUdid()) then
			local http = OpNotifyHttp.new(true)
			http:load( OpNotifyType.kReplayDataUploaded , -2 )
			return
		end

		if #replayData.datas <= 0 then
			local http = OpNotifyHttp.new(true)
			http:load( OpNotifyType.kReplayDataUploaded , -1 )
			return
		end

		local uploadResult = 0

		for k,v in ipairs(replayData.datas) do

			local passlogic = false
			if levelId and levelId ~= 0 then
				if v.level ~= levelId then
					passlogic = true
				end
			end

			if not passlogic then
				local tableStr = table.serialize( v )
				--he_log_error( tableStr )

				--DcUtil:forceUploadReplayData( tableStr )

				--printx( 1 , "ReplayDataManager:forceToUpload  v.level" , v.level)
				
				if traceToBI then
					DcUtil:forceUploadReplayData( 
						HeMathUtils:base64Encode(tableStr, string.len(tableStr)) , 
						v.info , v.ver , v.level , v.passed , v.score , v.currTime , #v.replaySteps )

					uploadResult = 1
				end

				if traceToServer then

					table.insert( datalist , HeMathUtils:base64Encode(tableStr, string.len(tableStr)) )
					uploadResult = 2
				end
			end
		end

		if uploadResult > 0 then
			local http = OpNotifyHttp.new(true)
			http:load( OpNotifyType.kReplayDataUploaded , 0 )
			UserManager:getInstance().userExtend.uploadReplay = 0

			if uploadResult == 2 then
				--printx( 1 , "ReplayDataManager:checkUploadReplay  SyncManager.getInstance():addAfterSyncHttp~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ " , debug.traceback())
				SyncManager.getInstance():addAfterSyncHttp( 
					"uploadReplay" , 
					{datas = datalist} , 
					nil , 
					{allowMergers = false} 
				)

				SyncManager:getInstance():syncLite()
			end
		end
	end

	--doForceToUpload()
	pcall(doForceToUpload)
end

function ReplayDataManager:getReplayRecordsData()
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
	return replay
	]]
end

function ReplayDataManager:doTest()
	local function tttttest()
		--self:loadLocalReplaySS()
		self:TTTTest()
	end

	xpcall(tttttest , function(err)
        message = err
        traceback = debug.traceback("", 2)

        if _G.isLocalDevelopMode then printx(-99, message) end
        if _G.isLocalDevelopMode then printx(-99, traceback) end
      end)
end

function ReplayDataManager:TTTTest()
	local levels = {}

	local str = "132,155:158"
	if UserManager:getInstance().global.replaySnapshotLevels then
		--str = tostring(UserManager:getInstance().global.replaySnapshotLevels)
	end
	
	local arr = str:split(",")
	printx( 1 , "  arr = " , table.tostring(arr))

	if arr and #arr > 0 then
		for k,v in ipairs( arr ) do
			local arr2 = v:split(":")

			if arr2 and #arr2 > 1 then

				local maxlv = arr2[2]

				if tostring(maxlv) == "max" then
					maxlv = tonumber(MetaManager.getInstance():getMaxNormalLevelByLevelArea())
				end

				for i = tonumber(arr2[1]) , tonumber(maxlv) do
					levels[i] = true
				end

			else
				levels[tostring(tonumber(v))] = true
			end
		end
	end

	printx( 1 , " +++++++++++++++++++++++++++++++++++++++++++++")
	printx( 1 , "  " , table.tostring(levels))
	printx( 1 , " +++++++++++++++++++++++++++++++++++++++++++++")
end


--------------------------  Snapshot  -----------------------------------


function ReplayDataManager:takeSnapshotForAntiCheating( mainlogic , dType )
	--printx( 1 , "   ReplayDataManager:takeSnapshotForAntiCheating 1")

	if not MaintenanceManager:getInstance():isAvailbleForUid("uploadReplaySnapshot", UserManager:getInstance().uid, 100) then
		--printx( 1 , "   ReplayDataManager:takeSnapshotForAntiCheating 2")
		return
	end

	if mainlogic.levelType ~= GameLevelType.kMainLevel and not mainlogic.replaying then
		--printx( 1 , "   ReplayDataManager:takeSnapshotForAntiCheating 3")
		return
	end

	local function doaction()
		--printx( 1 , "   ReplayDataManager:takeSnapshotForAntiCheating 4")
		self:__takeSnapshotForAntiCheating( mainlogic , dType )
	end

	pcall( doaction )
end

function ReplayDataManager:__takeSnapshotForAntiCheating( mainlogic , dType )
	local gameMode = mainlogic.gameMode
	local level = mainlogic.level
	local levelType = mainlogic.levelType
	local totalScore = mainlogic.totalScore

	if not self.snapshotData then 
		self.snapshotData = {} 
	end

	if not self.snapshotData.snapshots then
		self.snapshotData.snapshots = {}
	end

	self.snapshotData.level = level
	self.snapshotData.levelType = levelType

	local snapshot = {}
	snapshot.maps = {}
	snapshot.sid = 0
	snapshot.ts = totalScore
	snapshot.cm = mainlogic.theCurMoves
	snapshot.rm = mainlogic.realCostMove
	snapshot.dt = dType

	for r=1,#mainlogic.gameItemMap do
		for c=1,#mainlogic.gameItemMap[r] do
			local item = mainlogic.gameItemMap[r][c]
			local board = mainlogic.boardmap[r][c]

			local unit = ""
			local ver = "1"
			unit = unit .. ver

			if ver == "1" then
				unit = unit .. "_" .. tostring(item.ItemType)
				unit = unit .. "_" .. tostring(item.showType)
				if type(item._encrypt.ItemColorType) == "table" then
					unit = unit .. "_" .. tostring( AnimalTypeConfig.convertColorTypeToIndex( item._encrypt.ItemColorType ) )
				else
					unit = unit .. "_" .. tostring(item._encrypt.ItemColorType)
				end
				unit = unit .. "_" .. tostring( AnimalTypeConfig.convertSpecialTypeToIndex( item.ItemSpecialType ) )
				unit = unit .. "_" .. tostring(item.lampLevel)
				unit = unit .. "_" .. tostring(item.honeyBottleLevel)
				unit = unit .. "_" .. tostring(item.magicStoneLevel)
				unit = unit .. "_" .. tostring(item.lotusLevel)
				unit = unit .. "_" .. tostring(item.pufferState)
				unit = unit .. "_" .. tostring(item.totemsState)
				unit = unit .. "_" .. tostring(item.missileLevel)
				unit = unit .. "_" .. tostring(item.beEffectByMimosa and 1 or 0)
				unit = unit .. "_" .. tostring(item.beEffectBySuperCute and 1 or 0)
				unit = unit .. "_" .. tostring(board.iceLevel)
			elseif ver == "2" then

			end

			if not snapshot.maps[r] then
				snapshot.maps[r] = ""
			end

			if snapshot.maps[r] == "" then
				snapshot.maps[r] = unit
			else
				snapshot.maps[r] = snapshot.maps[r] .. ";" .. unit
			end
		end
	end

	snapshot.sid = #self.snapshotData.snapshots + 1
	table.insert( self.snapshotData.snapshots , snapshot )

	--printx( 1 , "   ReplayDataManager:takeSnapshotForAntiCheating  #self.snapshotData.snapshots = " , #self.snapshotData.snapshots)
	--[[
	local tableStr = table.serialize( snapshot )
	local md5str = HeMathUtils:base64Encode(tableStr, string.len(tableStr))
	local amfdata = amf3.encode(snapshot)

	local testFilePath1 = HeResPathUtils:getUserDataPath() .."/".."test_str"
	local testFilePath2 = HeResPathUtils:getUserDataPath() .."/".."test_md5"
	local testFilePath3 = HeResPathUtils:getUserDataPath() .."/".."test_amf"
	--printx( 1 , "   " , amfdata)

	Localhost:safeWriteStringToFile( tableStr , testFilePath1 )
	Localhost:safeWriteStringToFile( md5str , testFilePath2 )
	Localhost:safeWriteStringToFile( amfdata , testFilePath3 )
	]]

	--local amfdata = amf3.encode(snapshot)
	--DcUtil:uploadReplaySnapshotsData( amfdata , self.snapshotData.level , self.snapshotData.rid , snapshot.sid )
end

function ReplayDataManager:checkNeedAutoUploadByVerifyRank( levelId , rankPosition , reachNewPosition )
	if _G.isLocalDevelopMode then printx(0,  "RRR   ReplayDataManager:checkNeedAutoUploadByVerifyRank  --------------  "  , levelId , rankPosition , reachNewPosition ) end

	if not MaintenanceManager:getInstance():isAvailbleForUid("uploadReplaySnapshot", UserManager:getInstance().uid, 100) then
		--if _G.isLocalDevelopMode then printx(0,  "RRR   ReplayDataManager:checkNeedAutoUploadByVerifyRank  --------------  Snapshot 开关未开启") end
		--BroadcastManager:getInstance():showTestTip("Snapshot 开关未开启")
		return
	end

	if self.gameBoardLogic and self.gameBoardLogic.replaying then
		--if _G.isLocalDevelopMode then printx(0,  "RRR   ReplayDataManager:checkNeedAutoUploadByVerifyRank  --------------  Snapshot 回放模式") end
		--BroadcastManager:getInstance():showTestTip("Snapshot 回放模式")
		return
	end

	if not reachNewPosition then return end

	local maxrank = 500
	local levels = {}

	if UserManager:getInstance().global then

		if UserManager:getInstance().global.replaySnapshotThreshold then
			maxrank = tonumber(UserManager:getInstance().global.replaySnapshotThreshold)
		end

		local str = "870:max"
		if UserManager:getInstance().global.replaySnapshotLevels then
			str = tostring(UserManager:getInstance().global.replaySnapshotLevels)
		end
		
		local arr = str:split(",")
		if arr and #arr > 0 then
			for k,v in ipairs( arr ) do
				local arr2 = v:split(":")

				if arr2 and #arr2 > 1 then

					local maxlv = arr2[2]

					if tostring(maxlv) == "max" then
						maxlv = tonumber(MetaManager.getInstance():getMaxNormalLevelByLevelArea())
					end

					for i = tonumber(arr2[1]) , tonumber(maxlv) do
						levels[i] = true
					end
				else
					levels[tonumber(v)] = true
				end
			end
		end
	end

	if not levels[tonumber(levelId)] then
		--if _G.isLocalDevelopMode then printx(0,  "RRR   ReplayDataManager:checkNeedAutoUploadByVerifyRank  --------------  Snapshot 关卡不支持") end
		--BroadcastManager:getInstance():showTestTip("Snapshot 关卡不支持")
		return
	end

	--printx( 1 , "   rankPosition = " , rankPosition , "  maxrank = " , maxrank , "    tonumber(rankPosition) > maxrank " , tonumber(rankPosition) > maxrank)
	if rankPosition and tonumber(rankPosition) > maxrank then 
		--if _G.isLocalDevelopMode then printx(0,  "RRR   ReplayDataManager:checkNeedAutoUploadByVerifyRank  --------------  Snapshot 排名不支持") end
		--BroadcastManager:getInstance():showTestTip("排名不支持 --> " .. tostring(maxrank))
		return 
	end

	local function doaction()
		self:__checkNeedAutoUploadByVerifyRank( levelId )
	end

	pcall( doaction )
end

function ReplayDataManager:__checkNeedAutoUploadByVerifyRank( levelId )

	--printx( 1 , "   ReplayDataManager:__checkNeedAutoUploadByVerifyRank  !!!!!!!!!!!!!!!!")
	if self.snapshotData and self.snapshotData.snapshots and #self.snapshotData.snapshots > 0 then
		local logData = {}

		for k,v in ipairs( self.snapshotData.snapshots ) do

			local smallData = {}

			local rdata = ""

			for k1,v1 in ipairs( v.maps ) do
				if rdata == "" then
					rdata = v1
				else
					rdata = rdata .. ":" .. v1
				end
			end

			smallData["data"] = rdata
			smallData.info = tostring(v.sid) .. "_" .. tostring(v.ts) .. "_" .. tostring(v.cm) .. "_" .. tostring(v.rm) .. "_" .. tostring(v.dt)
			local tableStr = table.serialize( smallData )
			local md5str = HeMathUtils:base64Encode(tableStr, string.len(tableStr))
			--printx( 1 , "   ReplayDataManager:checkNeedAutoUploadByVerifyRank   \n" , tableStr)
			DcUtil:uploadReplaySnapshotsData( md5str , self.snapshotData.level , self.snapshotData.rid )
			
		end

		self.snapshotData = nil
	else
		BroadcastManager:getInstance():showTestTip(str)
	end
end



function ReplayDataManager:loadLocalReplaySS()

	local filePath = HeResPathUtils:getUserDataPath() .. "/" .. "replaySS.csv"
	local file = io.open(filePath, "rb")
	local simplejson = require("cjson")
	local mime = require("mime.core")
	if file then
		local data = file:read("*a") 
		file:close()

		if data then
			local result = nil 
			--local function decodeAmf3() result = amf3.decode(data) end
			--TODO: decypt data
			--pcall(decodeAmf3)

			local oringiStr = data

			local output = {}

			for k in string.gmatch( oringiStr , "{[^{|^}]+}" ) do
				--printx( 1 , "    --------------------------------------------------------")

				local sData = simplejson.decode( k )
				--printx( 1 , "   sData.datastr = " .. sData.datastr)
				local datamap = mime.unb64(sData.datastr)
				--printx( 1 , "   sData.datastr = " , datamap)
				sData.datastr = simplejson.decode( datamap )

				local info = sData.datastr.info:split("_")
				sData.sid = tonumber(info[1])
				sData.ts = tonumber(info[2])
				sData.cm = tonumber(info[3])
				sData.rm = tonumber(info[4])
				sData.dt = tostring(info[5])

				local map1 = sData.datastr.data:split(":")
				local maps = {}
				for i = 1 , #map1 do
					local map2 = map1[i]:split(";")
					for k = 1 , #map2 do
						local map3 = map2[i]:split("_")
						local unit = {}
						local ver = map3[1]

						if tostring(ver) == "1" then
							unit.ver = ver
							unit.ItemType = tonumber( map3[2] )
							unit.showType = tonumber( map3[3] )
							unit._encrypt.ItemColorType = tonumber( map3[4] )
							unit.ItemSpecialType = tonumber( map3[5] )
							unit.lampLevel = tonumber( map3[6] )
							unit.honeyBottleLevel = tonumber( map3[7] )
							unit.magicStoneLevel = tonumber( map3[8] )
							unit.lotusLevel = tonumber( map3[9] )
							unit.pufferState = tonumber( map3[10] )
							unit.totemsState = tonumber( map3[11] )
							unit.missileLevel = tonumber( map3[12] )
							unit.beEffectByMimosa = tonumber( map3[13] )
							unit.beEffectBySuperCute = tonumber( map3[14] )
							unit.iceLevel = tonumber( map3[15] )
						end

						if not maps[i] then
							maps[i] = {}
						end

						maps[i][k] = unit
					end
				end

				sData.maps = maps
				sData.datastr = nil

				printx( 1 , "  sData ========================= " , sData.sid , sData.ts , #output)
				output[sData.sid] = sData
			end

			if #output > 0 then
				self.checkSnapshotData = output
			end
			printx( 1 , "   #checkSnapshotData = " , #output )
		end
	end
end

function ReplayDataManager:checkSnapshotDiff(snapshotId)

	if self.checkSnapshotData and self.snapshotData then
		
		local logSS = self.checkSnapshotData[snapshotId]
		local currSS = self.snapshotData.snapshots[snapshotId]

		if logSS and currSS and logSS.sid == currSS.sid and currSS.sid == snapshotId then
			--printx( 1 , "   logSS.ts ~= currSS.ts " , logSS.ts , currSS.ts)
			if logSS.ts ~= currSS.ts then
				printx( 1 , "  分数不对！ old =" , logSS.ts , "  new =" , currSS.ts)
			end

		end
	end

end

function ReplayDataManager:addUploadReplayReason(reason, value)
	if not reason then return end
	self.uploadReplayReasons = self.uploadReplayReasons or {}
	self.uploadReplayReasons[reason] = value or true
end

function ReplayDataManager:hasUploadReplayReasons()
	return not table.isEmpty(self.uploadReplayReasons)
end

function ReplayDataManager:uploadReplayForReasons(replayCache, reasons)
	local dcData = {}
	for k, v in pairs(reasons) do
		dcData[k] = v
	end
	local v = replayCache
	local tableStr = table.serialize( v )
	if tableStr then
		local datastr = HeMathUtils:base64Encode(tableStr, string.len(tableStr))
		DcUtil:uploadReplayData("upload_for_reasons", datastr , 
			v.info , v.ver , v.level , v.passed , v.score , v.currTime , #v.replaySteps, dcData)
	end
end

function ReplayDataManager:uploadReplayIfNeeded(replayCache)
	if not replayCache then return end

	if self:hasUploadReplayReasons() then
		self:uploadReplayForReasons(replayCache, self.uploadReplayReasons)
		return
	end

	local dcData = {}
	local needUpdate = false
	if replayCache.dieState then
		needUpdate = true
		dcData.may_die = 1
	end
	if replayCache.userActs and replayCache.userActs.sn then
		needUpdate = true
		dcData.user_ss = 1
	end
	if needUpdate then
		local v = replayCache
		local datastr = nil
		if _G.isLocalDevelopMode or MaintenanceManager:getInstance():isAvailbleForUid("AutoUploadReplay", UserManager:getInstance().uid, 100) then
			local tableStr = table.serialize( v )
			datastr = HeMathUtils:base64Encode(tableStr, string.len(tableStr))
		end
		DcUtil:uploadReplayData("auto_upload_replay", datastr , 
			v.info , v.ver , v.level , v.passed , v.score , v.currTime , #v.replaySteps, dcData)
	end
end

function ReplayDataManager:onTrySwapFailedInStableState()
	if self.setWriteReplayEnable and self.gameBoardLogic and self.currLevelReplayData then
		local fsm = self.gameBoardLogic.fsm
		local stableFSM = fsm.fallingMatchState.stableFSM
		local enterTimestamp = stableFSM.stableEnterTimestamp
		local totalWaitTime = os.time() - enterTimestamp
		if enterTimestamp > 0 and totalWaitTime >= 2 then -- >=2s才记录
			local stateName = stableFSM.priorityLogic
			if not stateName or stateName == "none" then
				stateName = stableFSM.currentState and stableFSM.currentState:getClassName() or "none"
			end
			if _G.isLocalDevelopMode then printx(0, "onTrySwapFailedInStableState", stateName, totalWaitTime) end
			
			if self.currLevelReplayData.dieState ~= stateName then
				self.currLevelReplayData.dieState = stateName
				self:flushReplayCache()
			end
		end
	end
end

function ReplayDataManager:onTakeScreenSnapshot()
	if self.setWriteReplayEnable and self.gameBoardLogic and self.currLevelReplayData then
		local userActs = self.currLevelReplayData.userActs or {}
		if type(userActs.sn) ~= "table" then
			userActs.sn = {}
		end
		table.insert(userActs.sn, self.gameBoardLogic.realCostMove)
	 	self.currLevelReplayData.userActs = userActs
	 	self:flushReplayCache()
	end
end

function ReplayDataManager:setStrategyInfo(info)
	if self.currLevelReplayData then 
		self.currLevelReplayData.strategyInfo = info
	 	self:flushReplayCache()
	end
end

function ReplayDataManager:checkNeedSetActContextWhenLevelStart( )
	local function isMainLevel()
		return LevelType:isMainLevel(self.currLevelReplayData.level)
	end

	if not self.currLevelReplayData then
		return
	end

	if isMainLevel()  then
        if Thanksgiving2018CollectManager.getInstance():shouldShowActCollection( self.currLevelReplayData.level ) then
            self:setActContext( Thanksgiving2018CollectManager.getInstance():getReplayFlag() )
        end
	end

    if  CollectStarsManager.getInstance():isBuffEffective( self.currLevelReplayData.level ) then
        self:setActContext('CollectStars2018/Config.lua')
    end

end

function ReplayDataManager:setActContext( actPathKey )
	if self.currLevelReplayData and self.currLevelReplayData.actContext then 
		table.insert( self.currLevelReplayData.actContext , tostring(actPathKey) )
	end
end

function ReplayDataManager:checkResumeEnableByActContext( actPathKey )
	if actPathKey == 'RotaryTable201805/Config.lua' then
		return CountdownPartyManager.getInstance():isActivitySupport()
--    elseif actPathKey == 'DragonBuff/Config.lua' then
--		return DragonBuffManager.getInstance():isActivitySupport()
--    elseif actPathKey == 'QiXi201807/Config.lua' then
--		return Qixi2018CollectManager.getInstance():isActivitySupport()
--    elseif actPathKey == 'Act4021_OppoRank/Config.lua' then
--		return Qixi2018CollectManager.getInstance():isActivityOppoRankSupport()
	elseif actPathKey == 'CollectStars2018/Config.lua' then
		return CollectStarsManager.getInstance():isActivitySupport()
    elseif actPathKey == Thanksgiving2018CollectManager.getInstance():getReplayFlag() then
		return Thanksgiving2018CollectManager.getInstance():isActivitySupport()
	end

	return true
end


function ReplayDataManager:checkProductItemLogicVersion( levelId , levelConfig )

	local logicVer = 1

	local __productLogic = tonumber(levelConfig.productLogic) or 0

	if __productLogic == 0 then

		local uid = UserManager:getInstance():getUID() or "12345"
		-- if MaintenanceManager:getInstance():isEnabledInGroup("NewProductItemLogic" , "ON" , uid) then
			if GuideSeeds[levelId] then
				logicVer = 1
			else
				logicVer = 2
			end
		-- end

	else
		logicVer = __productLogic
	end

	--if HEAICore:getInstance():isEnable(levelId) and ( levelId >= 500 and levelId <= 700 ) then
	if levelId >= 500 and levelId <= 700 then
		--和AI组沟通，500~700关永远锁到旧生成口算法，不再判断HEAICore开关，因为开关已经被开放到所有关卡段号
		--另外，这个修改会导致模拟器在运行AI打关时，500~700以外的关卡可能使用新算法，这也是预期（保持和线上玩家一致）
		logicVer = 1
	end

	return logicVer
end