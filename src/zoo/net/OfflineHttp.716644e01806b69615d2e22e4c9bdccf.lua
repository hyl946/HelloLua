require "zoo.net.Http" 
-------------------------------------------------------------------------
--  Class include: StartLevelHttp, PassLevelHttp, UsePropsHttp, OpenGiftBlockerHttp
-------------------------------------------------------------------------

--
-- StartLevelHttp ---------------------------------------------------------
--
StartLevelHttp = class(HttpBase) --å¼€å§‹æŸä¸ªå…³å¡

--  <request>
--	  <property code="levelId" type="int" desc="å…³å¡id" />
--    <list code="itemList" ref="int" desc="ä½¿ç”¨é“å…·" />
--	  <property code="energyBuff" type="boolean" desc="æ˜¯å¦ä½¿ç”¨æ— é™ç²¾åŠ›buff" />
--	  <property code="requestTime" type="long" desc="请求时间" />
--  </request>
function StartLevelHttp:load(levelId, itemList, energyBuff, gameLevelType, usePropList, prebuffGrade, activityFlag, videoPropList)
	assert(levelId ~= nil, "levelId must not a nil")
	assert(type(itemList) == "table", "itemList not a table")

	local context = self
	local gameMode = LevelMapManager.getInstance():getLevelGameMode(levelId)
	assert(gameMode ~= nil, "gameMode id not found")

	if energyBuff == nil then energyBuff = false end
	
	local body = {levelId=levelId, gameMode=gameMode, itemList=itemList, energyBuff=energyBuff, activityFlag = gameLevelType, usePropList = usePropList, prebuffGrade = prebuffGrade}
	if activityFlag then 
		body = {levelId=levelId, gameMode=gameMode, itemList=itemList, energyBuff=energyBuff, activityFlag = activityFlag, usePropList = usePropList, prebuffGrade = prebuffGrade}
	end
	--推送召回相关 activityFlag  1为七夕关卡  2为推送召回卡关最高关卡 有特殊临时道具可用
	if RecallManager.getInstance():getRecallLevelState(levelId) then
		body = {levelId=levelId, gameMode=gameMode, itemList=itemList, energyBuff=energyBuff, activityFlag = 101, usePropList = usePropList, }
	end
	local jsonTable = {}
	local useJsonData = false

	local isActEnergyInfinite = CollectStarsYEMgr.getInstance():isBuffEffective(levelId)
	CollectStarsManager.getInstance():clearStarStageStart()
	if isActEnergyInfinite then
		useJsonData = true
		jsonTable[ CollectStarsManager.getInstance():getCollectStarsActid() ] = "infinite"
	end
	if useJsonData then
		body.json = table.serialize(jsonTable)
	end
	
	body.requestTime = Localhost:time()
	body.videoPropList = videoPropList

	if NetworkConfig.useLocalServer then
		if _G.isLocalDevelopMode then printx(0, " [ useLocalServer for StartLevelHttp ]", levelId, gameMode, itemList, energyBuff, gameLevelType) end
		local success, err = Localhost.getInstance():startLevel(levelId, gameMode, itemList, energyBuff, gameLevelType, nil, videoPropList)
		if success then
			local isBuffEffective , leftBuffCount= CollectStarsManager.getInstance():isBuffEffective(levelId)
			if isActEnergyInfinite and not isBuffEffective then
				he_log_error("jsma log CollectStars error levelId = ".. levelId .." leftBuffCount = " ..leftBuffCount )
			end
			if isBuffEffective then
				CollectStarsManager.getInstance():starStageStart(levelId)
			end
			if isActEnergyInfinite then
				CollectStarsManager.getInstance():useBuff()
				CollectStarsYEMgr.getInstance():setIngameFlag(true)
			else
				CollectStarsYEMgr.getInstance():setIngameFlag(false)
			end
			
			if levelId == UserService.getInstance().user:getTopLevelId() then
				UserManager:getInstance().userExtend:incrTopLevelFailCount(1)
				UserService:getInstance().userExtend:incrTopLevelFailCount(1)
				local c1 = UserTagManager:getTopLevelFailCounts() or 0
				--RemoteDebug:uploadLog( "StartLevelHttp:load  UserTagManager:updateTopLevelFailCounts" , c1 + 1  )
				UserTagManager:updateTopLevelFailCounts( c1 + 1 )
			end
			UserService.getInstance():cacheHttp(kHttpEndPoints.startLevel, body)
			-- 前端必须放到start level中，这样重玩处理时才不会因为没有pass level而少算一次打关
			UserManager.getInstance():incrPlayTimes()
			UserService.getInstance():incrPlayTimes()

			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

			for _,itemId in ipairs(itemList) do
				if itemId ~= 10015 and itemId ~= 10059 then
					local achi = Achievement:getAchi(AchiId.kTotalUsePropCount)
					local isExclude = false
					for _,tid in ipairs(achi.extra) do
						if tid == itemId then
							isExclude = true
							break
						end
					end

					if not isExclude then
						Notify:dispatch("AchiEventDataUpdate",AchiDataType.kUsePropAddCount, 1)
					end
				end
			end


			_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kUsePreProps, {
				itemList = itemList,
				usePropList = usePropList,
				videoPropList = videoPropList,
			}))

			context:onLoadingComplete()
		else
			he_log_info("start level fail, err: " .. err)
			context:onLoadingError(err)
		end
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("start level fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("start level success")
	    	context:onLoadingComplete()
	    end
	end
	self.transponder:call(kHttpEndPoints.startLevel, body, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- PassLevelHttp ---------------------------------------------------------
--
PassLevelHttp = class(HttpBase) --è¿‡å…³

function PassLevelHttp:calcSig(cacheHttp)
	local params = {}
	params.levelId = cacheHttp.levelId
	params.score = cacheHttp.score
	params.star = cacheHttp.star
	params.coin = cacheHttp.coin
	params.targetCount = cacheHttp.targetCount
	params.requestTime = cacheHttp.requestTime
	params.opLog = cacheHttp.opLog and true or false
	params.version = cacheHttp.version
	params.curMd5 = cacheHttp.curMd5
	params.curConfigMd5 = cacheHttp.curConfigMd5
	params.udid = MetaInfo:getInstance():getUdid()

    local paramKeys = {}
    for k, v in pairs(params) do
        table.insert(paramKeys, k)
    end
    table.sort(paramKeys)
    local md5Src = ""
    for _, v in pairs(paramKeys) do
        md5Src = md5Src..tostring(params[v])
    end
    local secret = "q6kkSK1ZTdXRE8XuSnXDAvpgQNU!CcaH"
    return HeMathUtils:md5(md5Src .. secret)
end

-- dispatched event.data = response.rewardItems é€šè¿‡å…³å¡èŽ·å¾—å¥–åŠ±

--  <request>
--	  <property code="levelId" type="int" desc="å…³å¡id" />
--	  <property code="score" type="int" desc="å…³å¡å¾—åˆ†" />
--    <property code="star" type="int" desc="å…³å¡æ˜Ÿçº§" />	
--    <property code="stageTime" type="int" desc="å…³å¡æ‰€ç”¨æ—¶é—´" />
--    <property code="coin" type="int" desc="å…³å¡å†…æŽ‰è½é“¶å¸æ•°é‡" />	
--	  <property code="targetCount" type="int" desc="å…³å¡å†…æ”¶é›†çš„ç›®æ ‡æ•°é‡"/>	
--	  <property code="opLog" type="string" desc="å½“æ¬¡è¿‡å…³çš„opertaion log"/>
--	  <property code="requestTime" type="long" desc="请求时间" />
--  </request>
--  <response>
--		<list code="rewardItems" ref="Reward" desc="é€šè¿‡å…³å¡èŽ·å¾—å¥–åŠ±"/>
--	</response>
function PassLevelHttp:load(levelId, score, star, stageTime, coin, targetCount, opLog, gameLevelType, costMove, extraData, sfFlag , seed , strategy , initAdjustStr, strategyInfo, extraRewards, guideLevel, isGiveUp, DataEx )
	assert(levelId ~= nil, "levelId must not a nil")
	assert(score ~= nil, "gameMode must not a nil")
	assert(star ~= nil, "star must not a nil")
	assert(stageTime ~= nil, "stageTime must not a nil")
	assert(coin ~= nil, "coin must not a nil")

--	2018 7月 30
--	<property code="json" type="string" desc="扩展字段，json格式，actId为key，内容自订" />
	local jsonTable = {}
	local context = self
	if _G.isLocalDevelopMode then printx(0, 'passLevel', levelId, score, star, stageTime, coin, targetCount, opLog, gameLevelType, costMove) end

	local gpc = GamePlayContext:getInstance()
	local playInfo = gpc:getPlayInfo()
	local achiInfo = {
		[AchiId.kTotalLineEffectCount] = playInfo.line_create,
		[AchiId.kTotalBombEffectCount] = playInfo.wrap_create,
		[AchiId.kTotalMagicBirdCount] = playInfo.bird_create,
		[AchiId.kTotalChangeEffectCount] = playInfo.line_line_swap 
											+ playInfo.line_wrap_swap 
											+ playInfo.wrap_wrap_swap 
											+ playInfo.bird_line_swap 
											+ playInfo.bird_wrap_swap
											+ playInfo.bird_bird_swap,
	}

	local achievementValues = {}
	for id,count in pairs(achiInfo) do
		table.insert(achievementValues, {first = id, second = count})
	end

	if gameLevelType == GameLevelType.kQixi and star < 1 then -- attention
		targetCount = 0
	end
	sfFlag = tonumber(sfFlag) or 0
	costMove = costMove or 0
	local actFlag = gameLevelType
	--召回功能最高关卡临时道具特殊处理 
	if RecallManager.getInstance():getRecallLevelState(levelId) then
		actFlag = 101
	end
	--
--
--

	local cv12 , cv13 = UpdatePassLevelHttpRPData( 76 , levelId , opLog )

	if sfFlag > 0 or StartupConfig:getInstance():isLocalDevelopMode() then
		-- debug模式全部上传，方便QA出现问题时回放
	else
		-- 检查是否需要上传oplog, 减少上传不必要的数据
		local uid = tonumber(UserManager:getInstance().user.uid)
		local uploadEnable = true -- uid and (uid % 100 < 5) -- 5% for test
		if not LevelType.isNeedUploadOpLog(gameLevelType) or not uploadEnable then
			opLog = nil
		else
			-- 只上传不低于原成绩的操作
			if gameLevelType == GameLevelType.kMainLevel or gameLevelType == GameLevelType.kHiddenLevel then
				local oriScore = UserService:getInstance():getUserScore( levelId )
				if --[[star < 3 or]] (oriScore and score < oriScore.score) then --为了配合打关攻略，小于三星的成绩也传opLog
					opLog = nil
				end
			end
		end
	end

	local oldStarForCollectStar = 0 
	local isNewFullStarArea = false
	local scoreNode = UserManager:getInstance():getUserScore(levelId)
	if scoreNode then
		oldStarForCollectStar = scoreNode.star or 0
	end
	if star>=3 then
		-- Record full star area
		local score = UserManager:getInstance():getUserScore(levelId)
		if not score or score.star<3 then
			local _,numFullStarArea = UserManager:getInstance():getAreaStarInfo()
			local oldStar = nil
			if score then
				oldStar = score.star
				score.star = star
			else
				local newLevelScore = ScoreRef.new()
				newLevelScore.levelId = levelId
				newLevelScore.star = star
				UserManager:getInstance():addUserScore(newLevelScore)
			end
			local _,numFullStarAreaNew = UserManager:getInstance():getAreaStarInfo()
			if oldStar then
				score.star = oldStar
			else
				UserManager:getInstance():removeUserScore(levelId)
			end
			isNewFullStarArea = numFullStarAreaNew>numFullStarArea
			-- print("isNewFullStarArea:",isNewFullStarArea,numFullStarAreaNew,numFullStarArea,levelId,star,oldStar)
		end
	end
	
	if opLog then
		-- DcUtil:logOpLog(levelId, score, stageTime, targetCount, opLog)
	end

	if NetworkConfig.useLocalServer then

		-- 根据
		-- 是否满五步 或 成功通关 或时间关超过30秒
		-- 来判断是否算活动次数
		local levelMeta = LevelMapManager.getInstance():getMeta(levelId)
		local gameData = levelMeta.gameData
		local levelModeType = gameData.gameModeName

		local extraStr = "0"
		if costMove >= 5 or star > 0 or (levelModeType == GameModeType.CLASSIC and stageTime >= 30) then
			extraStr = "1"
		end

		if gameLevelType == GameLevelType.kFourYears then
			if type(extraData) == "table" then
				extraStr = table.serialize(extraData)
			else
				extraStr = ""
			end
        elseif gameLevelType == GameLevelType.kSummerFish then
			if type(extraData) == "table" then
				extraStr = table.serialize(extraData)
			else
				extraStr = ""
			end
		elseif gameLevelType == GameLevelType.kOlympicEndless or gameLevelType == GameLevelType.kMidAutumn2018 then
			if type(extraData) == "table" and extraData.passedCol then
				extraStr = tostring(extraData.passedCol)
			end
		elseif gameLevelType == GameLevelType.kYuanxiao2017 then 
			extraStr = extraData
		end

		local usedProps = {}
		local stageInfo = StageInfoLocalLogic:getStageInfo( UserManager:getInstance().uid )
		if stageInfo and stageInfo.propsUsedInLevel then
			for itemId, num in pairs(stageInfo.propsUsedInLevel) do
				table.insert(usedProps, {itemId = itemId, num = num})
			end
		end
		local hasUsedProp = false
		if #usedProps > 0 then hasUsedProp = true end

		local QixiManager = require 'zoo.eggs.QixiManager'
		if QixiManager:getInstance():shouldSeeRose() then
			if type(extraData) == 'table' and extraData[1] == 'qixi2017' then
				extraStr = 'qixi2017'

				QixiManager:getInstance():incTodayRoseNum()
			end
		end

        if Thanksgiving2018CollectManager.getInstance():isActivitySupportAll() then
            local CollectNum = 0
            if GameBoardLogic:getCurrentLogic() then
                CollectNum = GameBoardLogic:getCurrentLogic().actCollectionNum
            end

            local shouldShow = Thanksgiving2018CollectManager.getInstance():shouldShowActCollection( levelId )
            if shouldShow then
                local extraData = Thanksgiving2018CollectManager.getInstance():getPasslevelExtraData(  levelId, star, CollectNum )
                jsonTable["4023"] = extraData
            end
        end

        if SpringFestival2019Manager.getInstance():getCurIsActSkill() then
            local step = 0
            step = SpringFestival2019Manager.getInstance().EndMoveStep
            local SkillIDList = SpringFestival2019Manager.getInstance().EndMoveSkillID

            if SkillIDList then
                local extra = {}
                extra.leftMove = step
                extra.gemIds = ""
                for i,v in ipairs(SkillIDList) do
                    if i == 1 then
                        extra.gemIds = ""..v
                    else
                        extra.gemIds = extra.gemIds..","..v
                    end
                end
                jsonTable[""..PigYearLogic:getActId()] = extra
            end
        end

        if gameLevelType == GameLevelType.kSummerFish then

            if DataEx and DataEx.SummerFishData then
                jsonTable["3011"] =  DataEx.SummerFishData
            end
	    end
		-- 在关卡内阵亡的小动物 铭记他们的数目 致以崇高的敬意
		-- -9999是通用的 3017是短期存在的专用字段，后面会删掉3017
		local gamePlayContext = GamePlayContext:getInstance()
		local playInfo = gamePlayContext:getPlayInfo()
		jsonTable["-9999"] = {
			color1 = playInfo.killed_animal_1,
			color2 = playInfo.killed_animal_2,
			color3 = playInfo.killed_animal_3,
			color4 = playInfo.killed_animal_4,
			color5 = playInfo.killed_animal_5,
			color6 = playInfo.killed_animal_6,
			line = gamePlayContext:getPlayInfoKilledLine(),
			wrap = gamePlayContext:getPlayInfoKilledWrap(),
			bird = gamePlayContext:getPlayInfoKilledBird(),
		}
		jsonTable["3017"] = table.clone(jsonTable["-9999"], true)

		CollectStarsManager.getInstance():doClearAutoAddBuff()
		if CollectStarsManager.getInstance():isBuffEffectiveForPassLevel(levelId , oldStarForCollectStar  , star) then
			jsonTable[ CollectStarsManager.getInstance():getCollectStarsActid() ] = "true"
			CollectStarsManager.getInstance():doAutoAddBuff(oldStarForCollectStar , star)
		end
		if DailyTasksManager.getInstance():canPassLevel(levelId ,isGiveUp ) then
			jsonTable["5004"] = "passlevel"
			DailyTasksManager.getInstance():deductionNum()
		end
		local levelMd5 = ""
		if LevelType:isMainLevel( levelId ) then
			local meta = LevelMapManager.getInstance():getMeta(levelId)
			if meta then
				levelMd5 = LevelDifficultyAdjustManager:getMD5ByLevelMeta(meta)
			end
		end

		-- local uid = UserManager:getInstance():getUID() or "12345"
 	-- 	if not MaintenanceManager:getInstance():isEnabledInGroup("LevelDifficultyAdjust" , "C2" , uid) then
 	-- 		--seed = 0
 	-- 	end

 		if not seed then
 			seed = 0
 		end

 		if not strategy then
 			strategy = 0
 		end

 		local gameBoardLogic = GameBoardLogic:getCurrentLogic()
 		local levelLeftMoves = nil
		local eventId = nil
 		if gameBoardLogic then
 			levelLeftMoves = gameBoardLogic.leftMoves
 			eventId = LevelDifficultyAdjustManager:getAIEventID()
 		end
		local paymentOrderIds = stageInfo and stageInfo.paymentOrderIds or nil

		local shouldCalcPrebuff = false
		if PreBuffLogic then
			shouldCalcPrebuff = PreBuffLogic:isActOn()
		end

		if _G.isLocalDevelopMode then printx(100, "actFlag============",actFlag) end

		if opLog then
			opLog = table.serialize(opLog)
		end

		local cacheHttp = 
		{
			levelId=levelId, 
			score=score, 
			star=star,
			stageTime=stageTime,
			coin=coin,
			targetCount=targetCount,
			requestTime=Localhost:time(), 
			activityFlag = actFlag,
			step = costMove,
			extra = extraStr,
			sfFlag = sfFlag,
			opLog = opLog,
			version = _G.bundleVersion,
			curMd5 = ResourceLoader.getCurVersion(), 	-- game version
			curConfigMd5 = LevelMapManager.getInstance():getLevelUpdateVersion(), -- level update version
			useSmallRes = _G.__use_small_res,
			usedProps = usedProps,
			seed = seed,								--此关卡使用的种子
			strategy = strategy,						--如果动态调整难度激活激活，告诉后端干预策略
			levelMd5 = levelMd5,						--单关配置的md5
			hasUsedProp = hasUsedProp,					--关卡内是否使用了道具（仅限背包内道具和前置道具，关卡内获得的临时道具不算）
			levelVersion = GamePlayClientVersion,		--客户端核心关卡逻辑的版本（前端维护）
			propGuideItem = IngamePropGuideManager:getInstance():getPassLevelParamAndClear(),
			virtualMode = initAdjustStr,
			strategyInfo = strategyInfo,
			extraRewards = extraRewards,
			guideLevel = (not shouldCalcPrebuff),
			levelLeftMoves = levelLeftMoves ,
			replayModeWhenStart = GamePlayContext:getInstance().replayModeWhenStart ,
			achievementValues = achievementValues,
			giveUp = isGiveUp,
			newFullStarArea = isNewFullStarArea,
			json = table.serialize(jsonTable),
			eventId = eventId,
			orderIds = paymentOrderIds,
			logicalFail = self.logicalFail ,
		}

		cacheHttp.cacheCode = PassLevelHttp:calcSig(cacheHttp)

		local topLevelId = UserService:getInstance().user:getTopLevelId()

		if self.logicalFail and topLevelId == levelId then
			local c1 = UserTagManager:getTopLevelLogicalFailCounts() or 0
			UserTagManager:updateTopLevelLogicalFailCounts( c1 + 1 )
		end
				
		if seed ~= 0 and strategy == 0 and not hasUsedProp then
			--DcUtil:DifficultyAdjustActivated( levelId , seed , levelMd5 )
		end

		if self.checkDiffAdjust then self:checkDiffAdjust(cacheHttp) end
		LevelDifficultyAdjustManager:clearCurrStrategyID()
		
		
		local result, success, err = Localhost.getInstance():passLevel(levelId, score, star, stageTime, coin, targetCount, opLog, gameLevelType)
		local warp , warpRpcount , warpRaddcount = Localhost:getWarp()

		

		local cv11 = nil
		local cv14 = nil
		if warpRaddcount and cv12 > 0 then
			if cv12 + warpRaddcount + 3 < cv13 then
				cv11 = true
				cv14 = warpRaddcount
			end
		end

		if cv11 then
			--
--
--

			if not warp then 
				warp = {} 
				warp.levelId = levelId
			end
			warp.cv11 = cv11
			warp.cv12 = cv12
			warp.cv13 = cv13
			warp.cv14 = cv14
			warp.cv1v = 2
		end

		if warp then
			jsonTable["4022"] = warp
			cacheHttp.json = table.serialize(jsonTable)
		end
		if err ~= nil then 
			context:onLoadingError(err)
			if _G.isLocalDevelopMode then printx(0, "PassLevelHttp fail " .. tostring(err)) end
		else 
			if levelId == topLevelId and star > 0 then
				UserManager:getInstance().userExtend:resetTopLevelFailCount()
				UserService:getInstance().userExtend:resetTopLevelFailCount()
				UserTagManager:onTopLevelChanged()
			end
			UserService.getInstance():cacheHttp(kHttpEndPoints.passLevel, cacheHttp)

			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

			if _G.isLocalDevelopMode then printx(0, "pass level success !") end
			if _G.isLocalDevelopMode then printx(0, "use local server !!") end

			-- if _G.isLocalDevelopMode then printx(0, table.tostring(result).."success:"..tostring(success)) end
			local mergedRewards = {}
			for k, v in pairs(result) do
				local item = mergedRewards[v.itemId]
				if not item then
					item = {itemId = v.itemId, num = v.num}
					mergedRewards[v.itemId] = item
				else
					item.num = item.num + v.num
				end
			end

			for k,v in pairs(mergedRewards) do
				if GamePlayContext:getInstance() and GamePlayContext:getInstance().rewards then
					local r = { itemId = v.itemId , num = v.num }
					table.insert( GamePlayContext:getInstance().rewards , r )
				end
				if v.itemId == ItemType.ENERGY_LIGHTNING then
					UserEnergyRecoverManager:sharedInstance():addEnergy(v.num)
		        else
					UserManager:getInstance():addReward(v)
					GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kStageEnd, v.itemId, v.num, DcSourceType.kLevelReward, levelId)
				end			
			end
			
			if MissionManager then
				local triggerContext = TriggerContext:create(TriggerContextPlace.OFFLINE)
				triggerContext:addValue( kHttpEndPoints.passLevel , {levelId=levelId,star=star,score=score} )
				MissionManager:getInstance():checkAll(triggerContext)
			end

			if star > 0 then
				UserManager.getInstance():removeJumpLevelRef(levelId)
				AskForHelpManager.getInstance():onPassLevel(levelId)
				if _G.isLocalDevelopMode then printx(0, 'UserManager removeJumpLevelRef') end
			end

			for id,count in pairs(achiInfo) do
				Notify:dispatch("AchiEventDataUpdate", id, count)
			end

			context:onLoadingComplete(result) 

			if MissionManager then
				local triggerContext = TriggerContext:create(TriggerContextPlace.ANY_WHERE)
				MissionManager:getInstance():checkAll(triggerContext)
			end
		end
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("pass level fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("pass level success")

		
			if _G.isLocalDevelopMode then printx(0, table.tostring(data.rewardItems)) end

			for k,v in pairs(data.rewardItems) do
				if v.itemId == ItemType.ENERGY_LIGHTNING then
					UserEnergyRecoverManager:sharedInstance():addEnergy(v.num)
		        else
		        	UserManager:getInstance():addReward(v)
					GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kStageEnd, v.itemId, v.num, DcSourceType.kLevelReward, levelId)
				end		
			end

			if MissionManager then
				local triggerContext = TriggerContext:create(TriggerContextPlace.OFFLINE)
				triggerContext:addValue( kHttpEndPoints.passLevel , data )
				MissionManager:getInstance():checkAll(triggerContext)
			end

	    	context:onLoadingComplete(data.rewardItems)

	    	if MissionManager then
				local triggerContext = TriggerContext:create(TriggerContextPlace.ANY_WHERE)
				MissionManager:getInstance():checkAll(triggerContext)
			end
	    end
	end
	
	self.transponder:call(kHttpEndPoints.passLevel, 
		{levelId=levelId, score=score, star=star,stageTime=stageTime,coin=coin,targetCount=targetCount, opLog=opLog, requestTime=Localhost:time(),
		newFullStarArea = isNewFullStarArea}, 
		loadCallback, rpc.SendingPriority.kHigh, false)
	
	LevelDifficultyAdjustManager:clearCurrStrategyID()
end


UpdateProfileHttpOffline = class(HttpBase)
function UpdateProfileHttpOffline:load(name, headUrl, snsPlatform, snsName, customProfile, adcode)
	
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("UpdateProfileHttp err" .. err)
			context:onLoadingError(err)
		else
			he_log_info("UpdateProfileHttp ok")
			context:onLoadingComplete(data)
		end
	end

	if customProfile then
		UserManager:getInstance().profile.customProfile = customProfile 
	end

	local birthDate = UserManager:getInstance().profile.birthDate
	local location = UserManager:getInstance().profile.location
	local constellation = UserManager:getInstance().profile.constellation
	local age = UserManager:getInstance().profile.age
	local gender = UserManager:getInstance().profile.gender
	local secret = UserManager:getInstance().profile.secret
	local fileId = UserManager:getInstance().profile.fileId

	UserService:getInstance().profile.name = UserManager:getInstance().profile.name
	UserService:getInstance().profile.headUrl = UserManager:getInstance().profile.headUrl
	if _G.isLocalDevelopMode then printx(0, "profile change", UserService:getInstance().profile.name) end
	UserService:getInstance().profile.snsMap = UserManager:getInstance().profile.snsMap
	UserService:getInstance().profile.constellation = constellation
	UserService:getInstance().profile.location = location
	UserService:getInstance().profile.birthDate = birthDate
	UserService:getInstance().profile.age = age
	UserService:getInstance().profile.gender = gender


	UserService:getInstance().profile.secret = secret
	UserService:getInstance().profile.fileId = fileId
	UserService:getInstance().profile.customProfile = customProfile


	if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
	else if _G.isLocalDevelopMode then printx(0, "Did not write data to the device.") end end
	
	GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kProfileUpdate))

	local dataTable = {
						name = name,
						headUrl = headUrl,
						snsPlatform = snsPlatform,
						snsName = snsName,
						constellation = constellation,
						birthDate = birthDate,
						location = location,
						age = age,
						gender = gender,
						secret = secret,
						fileId = fileId,
						customProfile = customProfile,
						adcode = adcode
					  }

	-- self.transponder:call(kHttpEndPoints.updateProfile, dataTable, loadCallback, rpc.SendingPriority.kHigh, false)




	local context = self
	if NetworkConfig.useLocalServer then
		UserService.getInstance():cacheHttp(kHttpEndPoints.updateProfile, dataTable)

		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end
		context:onLoadingComplete()
		Notify:dispatch("AchiEventDataUpdate",AchiDataType.kUseCustomHeadOrNickname, 1)
		Notify:dispatch("AchiEventDataUpdate",AchiDataType.kFillUpPersonalInfo, 1)
		return
	end

end

--
-- UsePropsHttp ---------------------------------------------------------
--
UsePropsHttp = class(HttpBase) --ä½¿ç”¨é“å…·

--  <request>
--	  <property code="type" type="int" desc="1:ä¸´æ—¶é“å…·,2:èƒŒåŒ…é“å…·" />
--	  <property code="levelId" type="int" desc="å½“å‰å…³å¡" />
--    <property code="gameMode" type="int" desc="æ¸¸æˆåœºæ™¯" />
--	  <property code="param" type="int" desc="param" />
--	  <list code="itemList" ref="int" desc="ä½¿ç”¨é“å…·" />
--  </request>
function UsePropsHttp:load(itemType, levelId, param, itemList, returnType,returnItemId,returnExpireTime)
	assert(itemType ~= nil, "itemType must not a nil")
	assert(levelId ~= nil, "levelId must not a nil")

	assert(type(itemList) == "table", "itemList not a table")

	local context = self
	local gameMode = LevelMapManager.getInstance():getLevelGameMode(levelId)
	gameMode = gameMode or 0
	param = param or 0

	local body = {
		type=itemType, 
		levelId=levelId, 
		gameMode=gameMode, 
		param=param, 
		itemList=itemList, 
		requestTime=Localhost:time(),

		returnType = returnType,
		returnItemId = returnItemId,
		returnExpireTime = returnExpireTime,
	}

	if NetworkConfig.useLocalServer then
		local success, err = Localhost.getInstance():useProps(
			itemType, levelId, gameMode, param, itemList,Localhost:time(),
			returnType,returnItemId,returnExpireTime
		)
		if err ~= nil then context:onLoadingError(err)
			if _G.isLocalDevelopMode then printx(0, "UsePropsHttp fail", tostring(err), table.tostring(itemList)) end
		else 
			if _G.kDevDropUseProp then -- for test
				context:onLoadingComplete()
				return
			end
			UserService.getInstance():cacheHttp(kHttpEndPoints.useProps, body)
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
			-- table.each(itemList, function (v)
			-- 	DcUtil:logUseItem(v, 1, levelId)
			-- 	end)
			local hasHourglass = false
			for _,it in ipairs(itemList) do
				local achi = Achievement:getAchi(AchiId.kTotalUsePropCount)
				local isExclude = false
				for _,tid in ipairs(achi.extra) do
					if tid == it then
						isExclude = true
						break
					end
				end

				if not isExclude then
					Notify:dispatch("AchiEventDataUpdate",AchiDataType.kUsePropAddCount, 1)
				end

				if it == ItemType.SMALL_ENERGY_BOTTLE or
					it == ItemType.MIDDLE_ENERGY_BOTTLE or
					it == ItemType.LARGE_ENERGY_BOTTLE
				then
					Notify:dispatch("AchiEventDataUpdate",AchiDataType.kUseEnergyAddCount, 1)
				elseif it == ItemType.HOURGLASS then
					hasHourglass = true
				end
			end


			_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kUsePreProps, {
				itemList = table.filter(itemList or {}, function ( v )
					return ItemType:inPreProp(v) or ItemType:inTimePreProp(v)
				end) or {}
			}))

			if hasHourglass then
				Notify:dispatch("AchiEventDataUpdate",AchiDataType.kSpeedUpFruitAddCount, 1)
			end

			context:onLoadingComplete() 
		end
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("useProps fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("useProps success")
	    	context:onLoadingComplete()
	    end
	end
	
	self.transponder:call(kHttpEndPoints.useProps, body, loadCallback, rpc.SendingPriority.kHigh, false)
end


--
-- OpenGiftBlockerHttp ---------------------------------------------------------
--
OpenGiftBlockerHttp = class(HttpBase) --é“å…·æŽ‰è½

--  <request>
--	  <property code="levelId" type="int" desc="å½“å‰å…³å¡" />
--	  <list code="itemList" ref="int" desc="æŽ‰è½é“å…·åˆ—è¡¨" />
--  </request>
function OpenGiftBlockerHttp:load(levelId, itemList)
	assert(levelId ~= nil, "itemID must not a nil")
	assert(type(itemList) == "table", "itemList not a table")

	local context = self
	local body = {levelId=levelId, itemList=itemList}

	if NetworkConfig.useLocalServer then
		if _G.isLocalDevelopMode then printx(0, " [ useLocalServer for OpenGiftBlockerHttp ]", levelId, itemList) end
		Localhost.getInstance():openGiftBlocker(levelId, itemList)
		UserService.getInstance():cacheHttp(kHttpEndPoints.openGiftBlocker, body)
		if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
		else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
		table.each(itemList, function (v)
			GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kStagePlay, v, 1, DcSourceType.kDrop, levelId)
			end)
		context:onLoadingComplete()
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("openGiftBlocker fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("openGiftBlocker success")
	    	context:onLoadingComplete()
	    end
	end
	
	self.transponder:call(kHttpEndPoints.openGiftBlocker, body, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetPropsInGameHttp = class(HttpBase)
function GetPropsInGameHttp:load(levelId, itemIds, actId)
	assert(type(levelId) == "number")
	assert(type(itemIds) == "table", "itemIds not a list")

	actId = actId or 0
	local context = self
	local body = {actId=actId, levelId=levelId, itemIds=itemIds}

	if NetworkConfig.useLocalServer then
		if _G.isLocalDevelopMode then printx(0, " [ useLocalServer for GetPropsInGameHttp ]", actId, levelId, itemIds) end
		if Localhost.getInstance():getPropsInGame(actId, levelId, itemIds) then
			UserService.getInstance():cacheHttp(kHttpEndPoints.getPropsInGame, body)
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
			-- table.each(itemIds, function (v)
			-- 	DcUtil:logRewardItem("gift_blocker", v, 1, levelId)
			-- 	end)
			context:onLoadingComplete()
		else
			if _G.isLocalDevelopMode then printx(0, "getPropsInGame failed.") end
			context:onLoadingError()
		end
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("GetPropsInGameHttp fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("GetPropsInGameHttp success")
	    	context:onLoadingComplete()
	    end
	end
	
	self.transponder:call(kHttpEndPoints.getPropsInGame, body, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- IngameHttp ---------------------------------------------------------
--
IngameHttp = class(HttpBase)
-- <request>
-- 	<property code="id" type="int" desc="当type=1时代表goodsId，type=2时代表充值id" />	
-- 	<property code="orderId" type="String" desc="订单id" />
-- 	<property code="channel" type="String" desc="短代渠道" />
-- 	<property code="ingameType" type="int" desc="短代支付类型，1：商品购买，2：充值" />
-- </request>
function IngameHttp:load(id, orderId, channel, ingameType, detail, tradeId)
	assert(id ~= nil, "id must not a nil")
	assert(orderId ~= nil, "orderId must not a nil")
	assert(channel ~= nil, "channel must not a nil")
	assert(ingameType ~= nil, "ingameType must not a nil")

	local puzzleStr = ""
	if __ANDROID then
		puzzleStr = ___puzzle__str___
	end

	local localTime = Localhost:time()
	local sigStr = HeMathUtils:md5(puzzleStr .. orderId .. localTime)

	local context = self
	local body = {id = id, orderId = orderId, channel = channel, ingameType = ingameType, detail = detail, tradeId=tradeId, requestTime=localTime,
		imsi = MetaInfo:getInstance():getImsi(),
		udid = MetaInfo:getInstance():getUdid(),
		version = _G.bundleVersion,
		puzzle = sigStr,
	}

	if NetworkConfig.useLocalServer then
		if _G.isLocalDevelopMode then printx(0, " [ useLocalServer for IngameHttp ]", id, orderId, channel, ingameType, detail) end
		local success, err = Localhost.getInstance():ingame( id, orderId, channel, ingameType, detail)
		if err ~= nil then context:onLoadingError(err)
			if _G.isLocalDevelopMode then printx(0, "IngameHttp fail", tostring(err)) end
		else
			UserService.getInstance():cacheHttp(kHttpEndPoints.ingame, body)
				
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

			context:onLoadingComplete() 
		end
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("ingame payment confirm fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("confirm ingame payment success")
	    	Localhost:ingame( id, orderId, channel, ingameType )
	    	
	    	if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

	    	context:onLoadingComplete()
	    end
	end
	self.transponder:call(kHttpEndPoints.ingame, body, loadCallback, rpc.SendingPriority.kHigh, false)
end

GetNewUserRewardsHttp = class(HttpBase)
-- <request>
-- 	<property code="type" type="int" desc="0:normal_new_user_reward, 1:baidu or 91iOS" />
-- </request>
-- <response>
-- 	<list code="rewardItems" ref="Reward" desc="rewards"/>
-- </response>

function GetNewUserRewardsHttp:load(id)
	local context = self

	if NetworkConfig.useLocalServer then
		local cacheHttp = { requestTime = Localhost:time(), id = id}
		
		local result, success, err = Localhost.getInstance():getNewUserRewards(id)
		if err ~= nil then context:onLoadingError(err)
			if _G.isLocalDevelopMode then printx(0, "GetNewUserRewardsHttp fail", tostring(err)) end
		else 
			UserService.getInstance():cacheHttp(kHttpEndPoints.getNewUserRewards, cacheHttp)
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

			if _G.isLocalDevelopMode then printx(0, "getNewUserRewards success !") end
			if _G.isLocalDevelopMode then printx(0, "use local server !!") end

			for k, v in pairs(result) do
				UserManager:getInstance():addReward(v)
				GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kTrunk, v.itemId, v.num, DcSourceType.kNewUserReward)
			end

			context:onLoadingComplete(result) 
		end
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("getNewUserRewards, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("getNewUserRewards success")
			for k, v in pairs(data.rewardItems) do
				UserManager:getInstance():addReward(v)
				GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kTrunk, v.itemId, v.num, DcSourceType.kNewUserReward)
			end
	    	context:onLoadingComplete(data.rewardItems)
	    end
	end
	
	self.transponder:call(kHttpEndPoints.getNewUserRewards, 
		{ requestTime = Localhost:time(), id = id},
		loadCallback, rpc.SendingPriority.kHigh, false)
end

SettingHttp = class(HttpBase)
function SettingHttp:load(settingFlag)
	actId = actId or 0
	local context = self
	local body = {setting=settingFlag}

	if NetworkConfig.useLocalServer then
		UserManager.getInstance().setting = settingFlag
		UserService.getInstance().setting = settingFlag
		
		UserService.getInstance():cacheHttp(kHttpEndPoints.setting, body)
		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end
		context:onLoadingComplete()
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("SettingHttp fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("SettingHttp success")
	    	context:onLoadingComplete()
	    end
	end
	
	self.transponder:call(kHttpEndPoints.setting, body, loadCallback, rpc.SendingPriority.kHigh, false)
end

UpdateMissionHttp = class(HttpBase)
-- progress是个字符串，格式是"current-total,current-total"
function UpdateMissionHttp:load(position, taskId, state, progress)
	local context = self

	if NetworkConfig.useLocalServer then
		UserService.getInstance():cacheHttp(kHttpEndPoints.updateMission, {position = position,
			taskId = taskId, state = state, progress = progress, requestTime = Localhost:time()})
		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end
		context:onLoadingComplete()
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("UpdateMissionHttp fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("UpdateMissionHttp success")
	    	context:onLoadingComplete()
	    end
	end
	
	self.transponder:call(kHttpEndPoints.updateMission, {position = position, taskId = taskId,
		state = state, progress = progress, requestTime = Localhost:time()}, loadCallback,
		rpc.SendingPriority.kHigh, false)
end

TriggerAchievement = class(HttpBase)
function TriggerAchievement:load( id )
	local context = self

	if NetworkConfig.useLocalServer then
		UserService.getInstance():cacheHttp(kHttpEndPoints.triggerAchievement, {id = id})
		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end
		context:onLoadingComplete()
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	-- loadCallback()
	self.transponder:call(kHttpEndPoints.triggerAchievement, {id = id}, loadCallback, rpc.SendingPriority.kHigh, false)
end


OpNotifyOfflineType = {
	kIOSScoreGuide = 1,	-- IOS评分引导
	kUnlockAreaByTime = 2,
	kSetBAFlag = 3,
	kFcm = 4,--防沉迷
	kiOSReview = 5, -- iOS评分
	kClearBAFlag = 6,
	kOppoLaunchReward = 7, --oppo游戏中心登录领奖
	kAdviseOpenNotification = 8,
	kTopLevelUserGetAllPlayCount = 9, -- 满级玩家直接给所有免费次数
	kExchangePreBombLine = 10, -- 前置道具拆分
	kExchangePreRefresh = 11,
	kSetGuideFlag = 13,
	kHuaweiPushUpateToken = 14,
	kSetPreBuffActivityEnergy = 15,
	kMixPreBombLine = 16,
	kPersonalInfoRewardTrigger = 17,
	kHeadFrameUpdateShowTime = 19,
	kWeeklyRaceStartLevel = 21,
	kWarpStep = 23,
	kWarpColor = 24,
	kWarpInitS = 26,
	kWarpHasTConfig = 27,
	kWarpLConfig = 28,
	kWarpULConfig = 29,
	kAct1027 = 30,
	kACT1030 = 32,
	kAfterBegEnergy = 33,
    kFifthAnniversary = 34,
}


OpNotifyOffline = class(HttpBase)
function OpNotifyOffline:load(requestType, param )
	local context = self

	if NetworkConfig.useLocalServer then
		UserService.getInstance():cacheHttp(kHttpEndPoints.opNotifyOffline, {type = requestType ,param = param})
		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end
		context:onLoadingComplete()
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end
	-- loadCallback()
	self.transponder:call(kHttpEndPoints.opNotifyOffline, {type = requestType,param = param}, loadCallback, rpc.SendingPriority.kHigh, false)
end


recordTopLevelRank = class(HttpBase)
function recordTopLevelRank:load(topLevelId)
	local context = self

	if NetworkConfig.useLocalServer then
		UserService.getInstance():cacheHttp("recordAndGetTopLevelRank", {topLevelId = topLevelId})
		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end
		context:onLoadingComplete()
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end

	self.transponder:call("recordAndGetTopLevelRank", {topLevelId = topLevelId}, loadCallback, rpc.SendingPriority.kHigh, false)	
end

OpNotifyOffineHttp = class(HttpBase)
function OpNotifyOffineHttp:load(opType, param)

	local context = self

	if NetworkConfig.useLocalServer then
		UserService.getInstance():cacheHttp(kHttpEndPoints.opNotify, {type = opType, param = param})
		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end
		context:onLoadingComplete()
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
	    	context:onLoadingComplete(data)
	    end
	end

	self.transponder:call(kHttpEndPoints.opNotify, {type = opType, param = param}, loadCallback, rpc.SendingPriority.kHigh, false)	
end

WPIAPOffineHttp = class(HttpBase)
function WPIAPOffineHttp:load(id, orderId, tradeId, detail)
	local localTime = Localhost:time()

	local channel = "wpiap"
	local ingameType = 2

	local context = self
	local body = {
		id = id, 
		orderId = orderId, 
		channel = channel, 
		ingameType = ingameType, 
		detail = detail, 
		tradeId=tradeId,
		requestTime=localTime,
		imsi = MetaInfo:getInstance():getImsi(),
		udid = MetaInfo:getInstance():getUdid(),
		version = _G.bundleVersion,
		puzzle = "",
	}

	if NetworkConfig.useLocalServer then
		if _G.isLocalDevelopMode then printx(0, " [ useLocalServer for wpIap ]", id, orderId, channel, ingameType, detail) end
		local success, err = Localhost.getInstance():ingame( id, orderId, channel, ingameType, detail)
		if err ~= nil then context:onLoadingError(err)
			if _G.isLocalDevelopMode then printx(0, "wpIap fail", tostring(err)) end
		else
			UserService.getInstance():cacheHttp(kHttpEndPoints.wpIngame, body)
				
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

			context:onLoadingComplete() 
		end
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("wpIap payment confirm fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("confirm wpIap payment success")
	    	Localhost:ingame( id, orderId, channel, ingameType )
	    	
	    	if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

	    	context:onLoadingComplete()
	    end
	end
	self.transponder:call(kHttpEndPoints.wpIngame, body, loadCallback, rpc.SendingPriority.kHigh, false)

end



StartNewLadyBugTaskHttp = class(HttpBase)

function StartNewLadyBugTaskHttp:load()

	local params = {
		requestTime = Localhost:time()
	}

	local context = self
	if NetworkConfig.useLocalServer then

		UserService.getInstance():cacheHttp(kHttpEndPoints.startNewLadyBugTask, params)


		local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
		local taskId = LadybugDataManager:getInstance():calcNextTaskId()

		if taskId then
			local info = {
				id = taskId - 1,
				reward = false,
				canReward = false,
				lastRewardTime = params.requestTime,
				lastFinishTime = params.requestTime,
				extra = '0',
				finishTime = 0
			}



			UserManager:getInstance().newLadyBugInfo:fromLua(info)
			UserService:getInstance().newLadyBugInfo:fromLua(info)

			if _G.isLocalDevelopMode then printx(0, 'print', table.tostring(UserService:getInstance().newLadyBugInfo)) end

			if NetworkConfig.writeLocalDataStorage then 
				Localhost:getInstance():flushCurrentUserData()
			else 
				if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
			end


			context:onLoadingComplete()

		else
			context:onLoadingError()
		end

		return
	end
end



GetRewardsOfflineHttp = class(HttpBase)
function GetRewardsOfflineHttp:load(rewardId)
	local params = {
		rewardId = rewardId
	}
	local context = self
	if NetworkConfig.useLocalServer then
		UserService.getInstance():cacheHttp(kHttpEndPoints.getRewards, params)

		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end
		context:onLoadingComplete()
		
		return
	end
end

MonthCardRewardHttp = class(HttpBase)
function MonthCardRewardHttp:load(requestTime, index)
	local params = {
		requestTime = requestTime,
		index = index,
	}
	local context = self
	if NetworkConfig.useLocalServer then
		UserService.getInstance():cacheHttp("monthCardReward", params)

		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end
		context:onLoadingComplete()
		return
	end
end

-- new
--
-- AskForHelpStartLevelHttp ---------------------------------------------------------
--
AFHStartLevelHttp = class(HttpBase) --å¼€å§‹æŸä¸ªå…³å¡

--  <request>
--	  <property code="levelId" type="int" desc="å…³å¡id" />
--    <list code="itemList" ref="int" desc="ä½¿ç”¨é“å…·" />
--	  <property code="energyBuff" type="boolean" desc="æ˜¯å¦ä½¿ç”¨æ— é™ç²¾åŠ›buff" />
--	  <property code="requestTime" type="long" desc="请求时间" />
--  </request>
-- prebuffGrade, activityFlag, videoPropList 这三个是我从正常打关复制过来的  代打使用视频的魔力鸟报错  需要videoPropList
function AFHStartLevelHttp:load(levelId, itemList, energyBuff, gameLevelType, usePropList, prebuffGrade, activityFlag, videoPropList)
	assert(levelId ~= nil, "levelId must not a nil")
	assert(type(itemList) == "table", "itemList not a table")

	local context = self
	local gameMode = LevelMapManager.getInstance():getLevelGameMode(levelId)
	assert(gameMode ~= nil, "gameMode id not found")

    if energyBuff == nil then energyBuff = false end
	
	local body = {levelId=levelId, gameMode=gameMode, itemList=itemList, energyBuff=energyBuff, activityFlag = gameLevelType, usePropList = usePropList, prebuffGrade = prebuffGrade}
	if activityFlag then 
		body = {levelId=levelId, gameMode=gameMode, itemList=itemList, energyBuff=energyBuff, activityFlag = activityFlag, usePropList = usePropList, prebuffGrade = prebuffGrade}
	end

	body.requestTime = Localhost:time()
    body.videoPropList = videoPropList

	if NetworkConfig.useLocalServer then
		if _G.isLocalDevelopMode then printx(0, " [ useLocalServer for AFHStartLevelHttp ]", levelId, gameMode, itemList, energyBuff, gameLevelType) end
		local success, err = Localhost.getInstance():startLevel(levelId, gameMode, itemList, energyBuff, gameLevelType, nil, videoPropList)
		if success then
			if levelId == UserService.getInstance().user:getTopLevelId() then
				UserManager:getInstance().userExtend:incrTopLevelFailCount(1)
				UserService:getInstance().userExtend:incrTopLevelFailCount(1)
				local c1 = UserTagManager:getTopLevelFailCounts() or 0
				--RemoteDebug:uploadLog( "AFHStartLevelHttp:load  UserTagManager:updateTopLevelFailCounts" , c1 + 1  )
				UserTagManager:updateTopLevelFailCounts( c1 + 1 )
			end
			UserService.getInstance():cacheHttp(kHttpEndPoints.subsStartLevel, body)
			-- 前端必须放到start level中，这样重玩处理时才不会因为没有pass level而少算一次打关
			UserManager.getInstance():incrPlayTimes()
			UserService.getInstance():incrPlayTimes()
			
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end


			_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kUsePreProps, {
				itemList = itemList,
				usePropList = usePropList,
				videoPropList = videoPropList,
			}))

			context:onLoadingComplete()
		else
			he_log_info("start level fail, err: " .. err)
			context:onLoadingError(err)
		end
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local loadCallback = function(endpoint, data, err)
		if err then
	    	he_log_info("start level fail, err: " .. err)
	    	context:onLoadingError(err)
	    else
	    	he_log_info("start level success")
	    	context:onLoadingComplete()
	    end
	end
	self.transponder:call(kHttpEndPoints.subsStartLevel, body, loadCallback, rpc.SendingPriority.kHigh, false)
end

--
-- AFHPassLevelHttp ---------------------------------------------------------
--
AFHPassLevelHttp = class(HttpBase)

function AFHPassLevelHttp:calcSig(cacheHttp)
	local params = {}
	params.levelId = cacheHttp.levelId
	params.subsUid = cacheHttp.subsUid
	params.score = cacheHttp.score
	params.star = cacheHttp.star
	params.coin = cacheHttp.coin
	params.targetCount = cacheHttp.targetCount
	params.requestTime = cacheHttp.requestTime
	params.opLog = cacheHttp.opLog and true or false
	params.version = cacheHttp.version
	params.curMd5 = cacheHttp.curMd5
	params.curConfigMd5 = cacheHttp.curConfigMd5
	params.udid = MetaInfo:getInstance():getUdid()

    local paramKeys = {}
    for k, v in pairs(params) do
        table.insert(paramKeys, k)
    end
    table.sort(paramKeys)
    local md5Src = ""
    for _, v in pairs(paramKeys) do
        md5Src = md5Src..tostring(params[v])
    end
    local secret = "q6kkSK1ZTdXRE8XuSnXDAvpgQNU!CcaH"
    return HeMathUtils:md5(md5Src .. secret)
end

-- dispatched event.data = response.rewardItems é€šè¿‡å…³å¡èŽ·å¾—å¥–åŠ±

--  <request>
--	  <property code="levelId" type="int" desc="å…³å¡id" />
--	  <property code="score" type="int" desc="å…³å¡å¾—åˆ†" />
--    <property code="star" type="int" desc="å…³å¡æ˜Ÿçº§" />	
--    <property code="stageTime" type="int" desc="å…³å¡æ‰€ç”¨æ—¶é—´" />
--    <property code="coin" type="int" desc="å…³å¡å†…æŽ‰è½é“¶å¸æ•°é‡" />	
--	  <property code="targetCount" type="int" desc="å…³å¡å†…æ”¶é›†çš„ç›®æ ‡æ•°é‡"/>	
--	  <property code="opLog" type="string" desc="å½“æ¬¡è¿‡å…³çš„opertaion log"/>
--	  <property code="requestTime" type="long" desc="请求时间" />
--  </request>
--  <response>
--		<list code="rewardItems" ref="Reward" desc="é€šè¿‡å…³å¡èŽ·å¾—å¥–åŠ±"/>
--	</response>
function AFHPassLevelHttp:load(levelId, score, star, stageTime, coin, targetCount, opLog, gameLevelType, costMove, extraData, sfFlag, subsUid, isGiveUp)
	assert(levelId ~= nil, "levelId must not a nil")
	assert(score ~= nil, "gameMode must not a nil")
	assert(star ~= nil, "star must not a nil")
	assert(stageTime ~= nil, "stageTime must not a nil")
	assert(coin ~= nil, "coin must not a nil")
	assert(subsUid ~= nil, "subsUid must not a nil")

	local context = self

	sfFlag = tonumber(sfFlag) or 0
	subsUid = tonumber(subsUid) or 0
	costMove = costMove or 0

	local gpc = GamePlayContext:getInstance()
	local playInfo = gpc:getPlayInfo()
	local achiInfo = {
		[AchiId.kTotalLineEffectCount] = playInfo.line_create,
		[AchiId.kTotalBombEffectCount] = playInfo.wrap_create,
		[AchiId.kTotalMagicBirdCount] = playInfo.bird_create,
		[AchiId.kTotalChangeEffectCount] = playInfo.line_line_swap 
											+ playInfo.line_wrap_swap 
											+ playInfo.wrap_wrap_swap 
											+ playInfo.bird_line_swap 
											+ playInfo.bird_wrap_swap
											+ playInfo.bird_bird_swap,
	}

	local achievementValues = {}
	for id,count in pairs(achiInfo) do
		table.insert(achievementValues, {first = id, second = count})
	end

	if NetworkConfig.useLocalServer then

		-- 根据
		-- 是否满五步 或 成功通关 或时间关超过30秒
		-- 来判断是否算活动次数
		local levelMeta = LevelMapManager.getInstance():getMeta(levelId)
		local gameData = levelMeta.gameData
		local levelModeType = gameData.gameModeName

		local extraStr = "0"
		if costMove >= 5 or star > 0 or (levelModeType == GameModeType.CLASSIC and stageTime >= 30) then
			extraStr = "1"
		end

		local usedProps = {}
		local stageInfo = StageInfoLocalLogic:getStageInfo( UserManager:getInstance().uid )
		if stageInfo and stageInfo.propsUsedInLevel then
			for itemId, num in pairs(stageInfo.propsUsedInLevel) do
				table.insert(usedProps, {itemId = itemId, num = num})
			end
		end

		local jsonTable = {}

		local gamePlayContext = GamePlayContext:getInstance()
		local playInfo = gamePlayContext:getPlayInfo()
		jsonTable["-9999"] = {
			color1 = playInfo.killed_animal_1,
			color2 = playInfo.killed_animal_2,
			color3 = playInfo.killed_animal_3,
			color4 = playInfo.killed_animal_4,
			color5 = playInfo.killed_animal_5,
			color6 = playInfo.killed_animal_6,
			line = gamePlayContext:getPlayInfoKilledLine(),
			wrap = gamePlayContext:getPlayInfoKilledWrap(),
			bird = gamePlayContext:getPlayInfoKilledBird(),
		}
		jsonTable["3017"] = table.clone(jsonTable["-9999"], true)
		

		if isGiveUp == nil then
			isGiveUp = false
		end

		local cacheHttp = 
		{
			levelId=levelId, 
			subsUid=subsUid,
			score=score, 		-- 
			star=star,
			stageTime=stageTime,
			coin=coin,
			targetCount=targetCount,
			requestTime=Localhost:time(), 
			activityFlag = actFlag,
			step = costMove,
			extra = extraStr,
			sfFlag = sfFlag,
			opLog = opLog,
			version = _G.bundleVersion,
			curMd5 = ResourceLoader.getCurVersion(), 	-- game version
			curConfigMd5 = LevelMapManager.getInstance():getLevelUpdateVersion(), -- level update version
			useSmallRes = _G.__use_small_res,
			usedProps = usedProps,
			achievementValues = achievementValues,
			json = table.serialize(jsonTable),
			giveUp = isGiveUp,
		}
		cacheHttp.cacheCode = AFHPassLevelHttp:calcSig(cacheHttp)
		
		local topLevelId = UserService:getInstance().user:getTopLevelId()
		local result, success, err = Localhost.getInstance():passLevelAFH(levelId, score, star, stageTime, coin, targetCount, opLog, gameLevelType)
		if err ~= nil then 
			context:onLoadingError(err)
			if _G.isLocalDevelopMode then printx(0, "AFHPassLevelHttp fail " .. tostring(err)) end
		else 
			-- if levelId == topLevelId and star > 0 then
			-- 	UserManager:getInstance().userExtend:resetTopLevelFailCount()
			-- 	UserService:getInstance().userExtend:resetTopLevelFailCount()
			-- end
			UserService.getInstance():cacheHttp(kHttpEndPoints.subsPassLevel, cacheHttp)
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

			local newRewards = {}	-- 代打只会收获COIN/ENERGY_LIGHTNING
			for k,v in pairs(result) do
				if v.itemId == ItemType.ENERGY_LIGHTNING then
					newRewards[ItemType.ENERGY_LIGHTNING] = v.num
					
					UserEnergyRecoverManager:sharedInstance():addEnergy(v.num)
		        elseif v.itemId == ItemType.COIN then
		        	newRewards[ItemType.COIN] = v.num

		        	UserManager:getInstance():addReward(v)
					GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kStageEnd, v.itemId, v.num, DcSourceType.kLevelRewardAFH, levelId)
				end		
			end

			if star > 0 then
				Notify:dispatch("AchiEventDataUpdate",AchiDataType.kHelpFriendPassAddCount, 1)
			end
			
			--[[if MissionManager then
				local triggerContext = TriggerContext:create(TriggerContextPlace.OFFLINE)
				triggerContext:addValue( kHttpEndPoints.subsPassLevel , {levelId=levelId,star=star,score=score} )
				MissionManager:getInstance():checkAll(triggerContext)
			end--]]

			--[[if star > 0 then
				UserManager.getInstance():removeJumpLevelRef(levelId)
				if _G.isLocalDevelopMode then printx(0, 'UserManager removeJumpLevelRef') end
			end--]]
			for id,count in pairs(achiInfo) do
				Notify:dispatch("AchiEventDataUpdate", id, count)
			end
			context:onLoadingComplete(newRewards) 

			--[[if MissionManager then
				local triggerContext = TriggerContext:create(TriggerContextPlace.ANY_WHERE)
				MissionManager:getInstance():checkAll(triggerContext)
			end--]]
		end
		return
	end

	if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end

	local loadCallback = function(endpoint, data, err)
		if err then
	    	context:onLoadingError(err)
	    else
			if _G.isLocalDevelopMode then printx(0, table.tostring(data.rewardItems)) end

			for k,v in pairs(data.rewardItems) do
				if v.itemId == ItemType.ENERGY_LIGHTNING then
					UserEnergyRecoverManager:sharedInstance():addEnergy(v.num)
		        else
		        	UserManager:getInstance():addReward(v)
					GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kStageEnd, v.itemId, v.num, DcSourceType.kLevelRewardAFH, levelId)
				end	
			end

			--[[if MissionManager then
				local triggerContext = TriggerContext:create(TriggerContextPlace.OFFLINE)
				triggerContext:addValue( kHttpEndPoints.subsPassLevel , data )
				MissionManager:getInstance():checkAll(triggerContext)
			end--]]

	    	context:onLoadingComplete(data.rewardItems)

	    	--[[if MissionManager then
				local triggerContext = TriggerContext:create(TriggerContextPlace.ANY_WHERE)
				MissionManager:getInstance():checkAll(triggerContext)
			end--]]
	    end
	end
	
	self.transponder:call(kHttpEndPoints.subsPassLevel, 
		{levelId=levelId, subsUid=subsUid, score=score, star=star,stageTime=stageTime,coin=coin,targetCount=targetCount, opLog=opLog, requestTime=Localhost:time()}, 
		loadCallback, rpc.SendingPriority.kHigh, false)
end



ChooseHeadFrameHttp = class(HttpBase)
function ChooseHeadFrameHttp:load(headFrame, headFrameExpire)
	local params = {
		headFrame = headFrame,
		headFrameExpire = headFrameExpire or 0,
	}
	local context = self
	if NetworkConfig.useLocalServer then
		UserService.getInstance():cacheHttp(kHttpEndPoints.chooseHeadFrame, params)

		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end
		context:onLoadingComplete()
		return
	end
end

UsePieceHttp = class(HttpBase)
function UsePieceHttp:load(skinType, group, position)
	local params = {
		skinType = skinType,
		group = group,
		position = position,
	}
	local context = self
	if NetworkConfig.useLocalServer then
		UserService.getInstance():cacheHttp(kHttpEndPoints.usePiece, params)

		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end
		context:onLoadingComplete()
		return
	end
end



SetSkinHttp = class(HttpBase)
function SetSkinHttp:load(skinType, group)
	local params = {
		skinType = skinType,
		group = group,
	}
	local context = self
	if NetworkConfig.useLocalServer then
		UserService.getInstance():cacheHttp(kHttpEndPoints.setSkin, params)

		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end
		context:onLoadingComplete()
		return
	end
end

Add5Lottery = class(HttpBase)
function Add5Lottery:load(costDiamonds, rewards, lotteryTime, costVoucher)
	local params = {
		costDiamonds = costDiamonds,
		rewards = rewards,
		requestTime = lotteryTime,
		costVoucher = costVoucher,
	}
	local context = self
	if NetworkConfig.useLocalServer then
		UserService.getInstance():cacheHttp(kHttpEndPoints.add5Lottery, params)

		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end
		context:onLoadingComplete()
		return
	end
end

ReturnPrePropsHttp = class(HttpBase)
function ReturnPrePropsHttp:load(itemList)
	local items = {}
	for i, item in ipairs(itemList) do
		items[i] = {first = item.propId, second = item.expireTime or 0}
	end
	local context = self
	if NetworkConfig.useLocalServer then
		UserService.getInstance():cacheHttp(kHttpEndPoints.returnPreProps, {items = items})
		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end
		context:onLoadingComplete()
		return
	end
end



function HttpBase:offlinePost(endPoint, params, onSuccess, onFail, onCancel)
	local http = HttpBase.new(false)
	function http:load( params )
		local context = self
		if NetworkConfig.useLocalServer then
			UserService.getInstance():cacheHttp(endPoint, params)
			if NetworkConfig.writeLocalDataStorage then 
				Localhost:getInstance():flushCurrentUserData()
			else 
				if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
			end
			context:onLoadingComplete()
			return
		end
	end
	if onSuccess then
		http:ad(Events.kComplete, onSuccess)
	end
	if onFail then
		http:ad(Events.kError, onFail)
	end
	if onCancel then
		http:ad(Events.kCancel, onCancel)
	end
	http:load(params)
end