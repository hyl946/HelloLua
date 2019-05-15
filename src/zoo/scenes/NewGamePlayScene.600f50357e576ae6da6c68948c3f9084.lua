require "zoo.scenes.GamePlayScene"
require "zoo.gamePlay.BoardLogic.GameInitBuffLogic"

NewGamePlayScene = class(GamePlayScene)

function NewGamePlayScene:create( levelConfig , replayMode , replayData , playSceneUIType, forceUseDropBuff , strategyData , passAllDiffAdjust )
	local s = NewGamePlayScene.new()
	s.levelConfig = levelConfig
	s.replayMode = replayMode
	s.replayData = replayData
	s.gamelevel = levelConfig.level
	s.playSceneUIType = playSceneUIType
	s.levelType = LevelType:getLevelTypeByLevelId( s.gamelevel )
	s.forceUseDropBuff = forceUseDropBuff
	s.strategyData = strategyData
	s.passAllDiffAdjust = passAllDiffAdjust
	s:initScene()
	return s
end


function NewGamePlayScene:onInit()

	printx(0 , "------------------ NewGamePlayScene:onInit ---------------------" )

	local winSize = CCDirector:sharedDirector():getWinSize()
	CommonEffect:reset()

	if _G.isLocalDevelopMode then 
		printx(0, "after create button",os.date()) 
	end

	

	if not self.replayMode or self.replayMode == ReplayMode.kNone then
		if GameGuide and self.playSceneUIType and self.playSceneUIType == GamePlaySceneUIType.kNormal then
			self.levelConfig.randomSeed, self.allowRepeatGuide = GameGuide:sharedInstance():onGameInit(self.gamelevel)
			GamePlayContext:getInstance().guideContext.allowRepeatGuide = self.allowRepeatGuide
		end
	else
		self.allowRepeatGuide = false
		if GamePlayContext:getInstance().guideContext then
			self.allowRepeatGuide = GamePlayContext:getInstance().guideContext.allowRepeatGuide or false
		end
	end


	if not DoNotChangeUseNewFallingLogicByMaintenanceManager then
		--DoNotChangeUseNewFallingLogicByMaintenanceManager为true意味着通过debug按钮指定了掉落版本，这时将无视Maintenance开关版本
		--所以只有在DoNotChangeUseNewFallingLogicByMaintenanceManager 不为 true 时，才会在进关卡时将UseNewFallingLogic置空，并在重新计算
		UseNewFallingLogic = nil
	end

	local function tryEnableNewFallingLogic()
		--DoNotChangeUseNewFallingLogicByMaintenanceManager为true意味着通过debug按钮指定了掉落版本，这时将无视Maintenance开关版本
		if not UseNewFallingLogic and not DoNotChangeUseNewFallingLogicByMaintenanceManager then


			local __fallingLogic = tonumber(self.levelConfig.fallingLogic) or 0

			if __fallingLogic > 0 then

				local uid = UserManager:getInstance():getUID() or "12345"

				if __fallingLogic >= 1.1 and __fallingLogic < 1.2 --[[and MaintenanceManager:getInstance():isEnabledInGroup( "NewFallingLogic" , "MK1_1" , uid )]] then
					--因为历史遗留问题，__fallingLogic可能等于1.100000000000001
					UseNewFallingLogic = 1.1
				else
					UseNewFallingLogic = nil
				end

			else
				UseNewFallingLogic = nil
			end
			
		end

		-- if HEAICore:getInstance():isEnable(self.gamelevel) then
		if self.gamelevel >= 500 and self.gamelevel <= 700 then 
			--和AI组沟通，500~700关永远锁到旧掉落算法，不再判断HEAICore开关，因为开关已经被开放到所有关卡段号
			--另外，这个修改会导致模拟器在运行AI打关时，500~700以外的关卡可能使用新算法，这也是预期（保持和线上玩家一致）
			UseNewFallingLogic = nil
		end

		DiffAdjustQAToolManager:print( 1 , "tryEnableNewFallingLogic  UseNewFallingLogic =" , tostring(UseNewFallingLogic) )

		return UseNewFallingLogic
	end

	local logicVer = 1

	if not self.replayMode 
		or self.replayMode == ReplayMode.kNone 
		or self.replayMode == ReplayMode.kAutoPlayCheck 
		or self.replayMode == ReplayMode.kMcts then
		logicVer = ReplayDataManager:checkProductItemLogicVersion( self.gamelevel , self.levelConfig )
		tryEnableNewFallingLogic()
	else
		logicVer = self.replayData.PDTLogic or 1
		UseNewFallingLogic = self.replayData.fallingVer
	end
	
	self.mygameboardlogic = GameBoardLogic:create(self.replayMode);
	self.mygameboardlogic:setProductItemLogicVersion( logicVer )

	GameInitDiffChangeLogic:startLevel( self.mygameboardlogic )
	GameInitBuffLogic:startLevel( self.mygameboardlogic )

	

	SectionResumeManager:startLevel( self.mygameboardlogic , logicVer )

	LevelDifficultyAdjustManager:clearBefourStartLevel()

	if not self.levelConfig.randomSeed then self.levelConfig.randomSeed = 0 end

	if not self.replayMode or self.replayMode == ReplayMode.kNone then --正常打关，非录像回放

		local isGuideLevel = false
		if self.levelConfig.randomSeed ~= 0 then
			isGuideLevel = true
		end 

		local isPayUser = LevelDifficultyAdjustManager:getDAManager():checkIsPayUser()
		LevelDifficultyAdjustManager:getDAManager():setIsPayUser( isPayUser )

		local totalUsePropCount = UserTagManager:getTopLevelPropUsedCount()
		LevelDifficultyAdjustManager:getDAManager():setTotalUsePropCount( totalUsePropCount , true )

		local topLevelFailCounts = UserTagManager:getTopLevelLogicalFailCounts()
		LevelDifficultyAdjustManager:getDAManager():setFailCounts( topLevelFailCounts )

		if self.passAllDiffAdjust then
			self.mygameboardlogic.difficultyAdjustData = nil
		else
			LevelDifficultyAdjustManager:updateContext(self.gamelevel)
			self.mygameboardlogic.difficultyAdjustData = LevelDifficultyAdjustManager:checkAdjustStrategy()
		end
		
		if self.mygameboardlogic.difficultyAdjustData then
			local adjustSeed = nil

			if not isGuideLevel then --不是引导关
				if self.mygameboardlogic.difficultyAdjustData.seed and #self.mygameboardlogic.difficultyAdjustData.seed > 0 then
					local idx = LevelDifficultyAdjustManager:getRandomIndex()
 					if self.mygameboardlogic.difficultyAdjustData.seed[idx] then
 						self.levelConfig.randomSeed = self.mygameboardlogic.difficultyAdjustData.seed[idx]
 						adjustSeed = self.levelConfig.randomSeed
 					else
 						--RemoteDebug:uploadLog( "DiffAdjust pass 3"  )
 					end
 				elseif self.mygameboardlogic.difficultyAdjustData.propSeed then
 					self.levelConfig.randomSeed = self.mygameboardlogic.difficultyAdjustData.propSeed
 					LevelDifficultyAdjustManager:addPropSeedUsedLog( self.gamelevel , self.levelConfig.randomSeed )
				else
					if self.mygameboardlogic.difficultyAdjustData.seed then
						--RemoteDebug:uploadLog( "DiffAdjust pass 2"  )
					end
				end

				self.mygameboardlogic.difficultyAdjustData.adjustSeed = adjustSeed
				-- DiffAdjustQAToolManager:print( 1 , "NewGamePlayScene  doAdjustStrategy 111" )
				LevelDifficultyAdjustManager:doAdjustStrategy( self.mygameboardlogic )
				LevelDifficultyAdjustManager:updateCurrStrategyID( self.mygameboardlogic.difficultyAdjustData , adjustSeed )
			else
				LevelDifficultyAdjustManager:setLastUnactivateReason( 99 )
				if self.mygameboardlogic.difficultyAdjustData.seed then
					--RemoteDebug:uploadLog( "DiffAdjust pass 1"  )
				end
			end

			--[[
			RemoteDebug:uploadLog( "DiffAdjust  mode:" .. 
										tostring(self.mygameboardlogic.difficultyAdjustData.mode) .. " ds:" .. 
										tostring(self.mygameboardlogic.difficultyAdjustData.ds) .. " seed:" .. tostring(adjustSeed) )
										]]
		else
			--RemoteDebug:uploadLog( "DiffAdjust break 1"  )
		end

		if not isGuideLevel then --不是引导关
			GameInitDiffChangeLogic:checkEnableAdjust( self.gamelevel )
		else
			--RemoteDebug:uploadLog( "GameInitDiffChangeLogic break 4"  )
			DcUtil:VirtualSeedEnabled( levelId , nil , nil , nil , nil , nil , 4)
		end
	else

		if self.replayData.strategyDCInfo then
			
			if self.replayMode == ReplayMode.kSectionResume then
				if self.replayData.strategyDCInfo.nd1 and #self.replayData.strategyDCInfo.nd1 > 0 then
					LevelDifficultyAdjustManager:setStrategyIDList( self.replayData.strategyDCInfo.nd1 )
				end

				if self.replayData.strategyDCInfo.nd2 and #self.replayData.strategyDCInfo.nd2 > 0 then
					LevelDifficultyAdjustManager:setStrategyDataList( self.replayData.strategyDCInfo.nd2 )
				end
			end

			LevelDifficultyAdjustManager:setLastUnactivateReason( self.replayData.strategyDCInfo.nd3 )
		end

		local daManagerData = self.replayData.daManager

		if daManagerData then
			if self.replayMode == ReplayMode.kSectionResume then
				LevelDifficultyAdjustManager:getDAManager():buildSelfByReplayData( daManagerData ) --还原所有数据
			else
				LevelDifficultyAdjustManager:getDAManager():setIsPayUser( daManagerData.k1 )
				LevelDifficultyAdjustManager:getDAManager():setIsSatisfyPreconditions( daManagerData.k2 )
				LevelDifficultyAdjustManager:getDAManager():setFailCounts( daManagerData.k3 )
				LevelDifficultyAdjustManager:getDAManager():setTotalUsePropCount( daManagerData.k5 , true ) --只还原TotalUsePropCount的初始值，而不是最终值
			end
		end

		if self.strategyData then
			--RemoteDebug:uploadLog( "NewGamePlayScene:onInit  !!!  " , self.strategyData.seed , self.strategyData.mode , self.strategyData.ds )
			local adjustSeed = nil

			----[[
			if self.strategyData.seed then
				self.levelConfig.randomSeed = self.strategyData.seed
				adjustSeed = self.levelConfig.randomSeed
			elseif self.strategyData.propSeed then
				self.levelConfig.randomSeed = self.strategyData.propSeed
			elseif self.strategyData.aiSeed then
				self.levelConfig.randomSeed = self.strategyData.aiSeed
			end
			--]]
			--printx( 1 , "NewGamePlayScene:onInit  levelConfig.randomSeed = " ， levelConfig.randomSeed ， "  strategyData.seed = " , strategyData.seed )

			self.mygameboardlogic.difficultyAdjustData = {}
			self.mygameboardlogic.difficultyAdjustData.mode = self.strategyData.mode
			self.mygameboardlogic.difficultyAdjustData.ds = self.strategyData.ds
			self.mygameboardlogic.difficultyAdjustData.seed = {}
			table.insert( self.mygameboardlogic.difficultyAdjustData.seed , self.strategyData.seed )
			self.mygameboardlogic.difficultyAdjustData.adjustSeed = self.strategyData.seed
			self.mygameboardlogic.difficultyAdjustData.propSeed = self.strategyData.propSeed
			self.mygameboardlogic.difficultyAdjustData.aiSeed = self.strategyData.aiSeed

			-- DiffAdjustQAToolManager:print( 1 , "NewGamePlayScene  doAdjustStrategy 222" )
			LevelDifficultyAdjustManager:updateContext(self.gamelevel, true)
			LevelDifficultyAdjustManager:doAdjustStrategy(self.mygameboardlogic, true)
			LevelDifficultyAdjustManager:updateCurrStrategyID(self.mygameboardlogic.difficultyAdjustData, self.strategyData.seed, true)

			if self.replayMode ~= ReplayMode.kSectionResume then

				if self.replayData.strategyDCInfo then
					--既然self.strategyData不为空，那么nd1和nd2的第一位一定为PreStart数据，需要还原
					if self.replayData.strategyDCInfo.nd1 and #self.replayData.strategyDCInfo.nd1 > 0 then
						local tab = {}
						table.insert( tab , self.replayData.strategyDCInfo.nd1[1] )
						LevelDifficultyAdjustManager:setStrategyIDList( tab )
					end

					if self.replayData.strategyDCInfo.nd2 and #self.replayData.strategyDCInfo.nd2 > 0 then
						local tab = {}
						table.insert( tab , self.replayData.strategyDCInfo.nd2[1] )
						LevelDifficultyAdjustManager:setStrategyDataList( tab )
					end
					--后续数据不用还原，会在回放过程中被再次添加
				end
				
			end

			if self.replayData then
				if self.replayData.aiCoreInfo then
					LevelDifficultyAdjustManager:setAICoreInfo(table.clone(self.replayData.aiCoreInfo))
				end

				if self.replayData.groupInfo then
					LevelDifficultyAdjustManager:resumeUserGroupInfoByReplay( self.replayData.groupInfo )
				end

				if self.replayData.tplist then
					LevelDifficultyAdjustManager:buildLevelTargetProgressDataByReplayDataStr( self.replayData.tplist , self.replayData.tpTotalSteps )
				end
			end
		end

		-- if self.replayMode == ReplayMode.kSectionResume then
		-- 	LevelDifficultyAdjustManager:checkAdjustStrategyInLevelByLastLocalData()
		-- end

		if self.replayData and self.replayData.vsdata then
			local initAdjustData = {}
			initAdjustData.centerR = self.replayData.vsdata.r
			initAdjustData.centerC = self.replayData.vsdata.c
			initAdjustData.oringinTypeIndex = self.replayData.vsdata.oti
			initAdjustData.typeIndex = self.replayData.vsdata.ti
			initAdjustData.patternIndex = self.replayData.vsdata.pi

			self.mygameboardlogic.initAdjustData = initAdjustData
		end

		if self.replayData then

			if self.replayData.buffsV2 and #self.replayData.buffsV2 > 0 then
				local buffsForReplay = {}
				for k,v in ipairs(self.replayData.buffsV2) do
					local d = {}
					d.buffType = v.bt
					d.createType = v.ct
					d.propId = v.pid
					table.insert( buffsForReplay , d )
				end
				self.mygameboardlogic.buffsForReplay = buffsForReplay
				GameInitBuffLogic:setFlag_isReplayAndHasBuff(true)
			end

			-- if self.replayData.buffsV3 and #self.replayData.buffsV3 > 0 then
			-- 	local buffsForReplayPassedPlan = {}
			-- 	for k,v in ipairs(self.replayData.buffsV3) do
			-- 		local d = {}
			-- 		d.buffType = v.bt
			-- 		d.createType = v.ct
			-- 		d.propId = v.pid
			-- 		table.insert( buffsForReplayPassedPlan , d )
			-- 	end
			-- 	self.mygameboardlogic.buffsForReplayPassedPlan = buffsForReplayPassedPlan
			-- 	GameInitBuffLogic:setFlag_isReplayAndHasBuff(true)
			-- end
			
			
			if self.replayData.act5003Effctive then
				CollectStarsYEMgr.getInstance():setReplayFlag(true) 
			end
		end
	end
	

	self.mygameboardlogic:initByConfig(self.gamelevel, self.levelConfig , self.levelType, self.forceUseDropBuff , self.replayMode , self.replayData);

	if self.replayMode == ReplayMode.kSectionResume then --必须在self.mygameboardlogic:initByConfig之后，因为必须在ProductItemDiffChangeLogic:startLevel之后调用
		local daManagerData = self.replayData.daManager

		if daManagerData then
			local colorMap = LevelDifficultyAdjustManager:getDAManager():getColorCountMap()
			ProductItemDiffChangeLogic:setStepColorNumMap( colorMap )
		end
	end

	--获取处理完之后的map，进行view的初始化
	local pos, width, height
	self.mygameboardview, pos, width, height = GameBoardView:createByGameBoardLogic(self.mygameboardlogic , self.replayMode)
	self:addChild(self.mygameboardview)

	he_log_info("auto_test_enter_play_scene")

--[[
	local performanceLog = require("hecore.debug.PerformanceLog")
	if(performanceLog.enabled) then
		self._performanceLog = performanceLog:new("GamePlayScene")
	end
]]

end