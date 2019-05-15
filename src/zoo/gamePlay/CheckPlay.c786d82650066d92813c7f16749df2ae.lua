require "zoo.scenes.CheckPlayScene"
local mime = require("mime.core")
local simplejson = require("cjson")

CheckPlay = {}

--[[

checkPlayDataForm

[
	{
		"level":8,
		"replaySteps":[
			{"x2":4,"x1":3,"y2":3,"y1":3},
			{"x2":7,"x1":6,"y2":7,"y1":7},
			{"x2":5,"x1":4,"y2":4,"y1":4},
			{"x2":5,"x1":4,"y2":6,"y1":6},
			{"x2":4,"x1":4,"y2":6,"y1":5}
		],
		"hasDropBuff":false,
		"randomSeed":1388138716,
		"selectedItemsData":{}
	}
]


]]

CheckPlay.RESULT_ID = {
	
	kSuccess = 200 , --成功结束游戏
	kCrash = -1 ,  --中途crash
	kUnknow = 0 ,  --未知错误
	kSwapFail = 1 ,--某一步执行了一次无法交换的Swap，自动中止并报错返回
	kNotEnd = 2 ,  --所有的操作步骤已经执行完毕，但游戏并没有结束
	kHasCheckTaskRunning = 3 , --上一次的校验还在进行中
	kScoreNotMatch = 4, -- 校验分数不匹配
	kScoreIsClose = 5 , --校验分数不匹配但很接近
	kUsePropError = 6 , --使用道具发生错误，但未crash
}

CheckPlay.runningPlayDiffData = nil
CheckPlay.runningCheckId = 0
CheckPlay.checkIdLogMap = {}

CheckPlay.repeatForever = false

function CheckPlay:getCheckScene(playData , version, checkType)

	if not playData then return nil end

	--printx( 1 , "   CheckPlay:getCheckScene  playData.level = " , playData.level)
	--printx( 1 , "   CheckPlay:getCheckScene  playData = " , table.tostring(playData))
	-----------------------------兼容PlayDemo模式------------------------------
	local levelMeta = LevelMapManager.getInstance():getMeta( playData.level )
	if not levelMeta then 
		local testConfStr = DevTestLevelMapManager.getInstance():getConfig("test1.json")
		local testConf = table.deserialize(testConfStr)
		testConf.totalLevel = levelId
		LevelMapManager:getInstance():addDevMeta(testConf)
	end
	--------------------------------------------------------------------------

	LevelDataManager.sharedLevelData().levelDatas = {}

	local alwaysCreateNewInstance = true
	local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID( playData.level , alwaysCreateNewInstance )

	--printx( 1 , "   CheckPlay:getCheckScene  222222222222222")
	local numVersion = tonumber(_G.bundleVersion:split(".")[2])
	if version then
		numVersion = tonumber(version:split(".")[2])
	end

	

	if numVersion and tonumber(numVersion) >= 47 then
		
		require "zoo.panelBusLogic.NewStartLevelLogic"

		if tonumber(numVersion) == 56 then
			function NewGamePlaySceneUI:endReplay() --结束整个replay,退出gamePlayScene
				self:forceQuitPlay()
				if self.replayMode ~= ReplayMode.kCheck then
					GameSpeedManager:resuleDefaultSpeed()
				end
			end
		end

		if tonumber(numVersion) == 47 or tonumber(numVersion) == 48 or tonumber(numVersion) == 49 then

			function NewStartLevelLogic:createGamePlayScene()

				--print("RRR   NewStartLevelLogic:createGamePlayScene --------------  self:isReplayMode()" , self:isReplayMode() )
				local runningScene = Director:sharedDirector():getRunningSceneLua()
				if runningScene.name == "GamePlaySceneUI" then
					runningScene.disposResourceCache = false
					Director:sharedDirector():popScene(true)
				end

				local function pushNewScene()

					local gamePlayScene	= nil
					local selectedItemsData = self.itemList or {}

					if self:isReplayMode() then

						selectedItemsData = self.replayData.selectedItemsData

						-- if self.replayMode == ReplayMode.kNormal then
						-- 	gamePlayScene = NewGamePlaySceneUI:createWithReplayData( self.levelConfig  , self.replayMode , self.replayData )
						-- elseif self.replayMode == ReplayMode.kSnapshot then
						-- 	gamePlayScene = NewGamePlaySceneUI:createWithReplayData( self.levelConfig  , self.replayMode , self.replayData )
						-- elseif self.replayMode == ReplayMode.kCheck then
						-- 	gamePlayScene = NewGamePlaySceneUI:createWithReplayData( self.levelConfig  , self.replayMode , self.replayData )
						-- elseif self.replayMode == ReplayMode.kResume then
						-- 	--self.levelConfig
							gamePlayScene = NewGamePlaySceneUI:createWithReplayData( self.levelConfig  , self.replayMode , self.replayData )
						-- end

					else
						selectedItemsData = self.itemList or {}
						gamePlayScene = NewGamePlaySceneUI:create(self.levelConfig , selectedItemsData)
					end


					assert(gamePlayScene)
					gamePlayScene.fileList = self.fileList --为了结束关卡时卸载资源
					--print("RRR   NewStartLevelLogic:createGamePlayScene  Director:sharedDirector():pushScene(gamePlayScene)")
					Director:sharedDirector():pushScene(gamePlayScene)

				    if self.delegate and self.delegate.onDidEnterPlayScene then 
				    	self.delegate:onDidEnterPlayScene(gamePlayScene)
				    end

				    if not self:isReplayMode() then
				    	if MissionManager then
							local triggerContext = TriggerContext:create(TriggerContextPlace.START_LEVEL_AND_CREATE_GAME_PLAY_SCENE)
							triggerContext:addValue( "data" , self )
							MissionManager:getInstance():checkAll(triggerContext)
						end

					    Notify:dispatch("AchiEventStartLevel", self.levelId, self.levelType)
				    end
				end
				if self.replayMode == ReplayMode.kCheck then
					pushNewScene() --校验模式没有异步加载的资源，ResourceConfig.asyncPlist里的资源已被合并到ResourceConfig.plist同步加载
				else
					AsyncLoader:getInstance():waitingForLoadComplete(pushNewScene)
				end
			end

			function NewGamePlaySceneUI:onReplayEndHandler()

				if self:isReplayMode() then

					if self.replayMode == ReplayMode.kCheck then
						local function endReplay()
							if self.checkPlayIsEnd then
								self.checkPlayIsEnd = nil
								return
							end
							if CheckPlay then
								CheckPlay:checkResult(CheckPlay.RESULT_ID.kNotEnd, {} , self.gameBoardLogic)
							end
							self:endReplay()
						end
						setTimeOut(endReplay, 0.1)
					elseif self.replayMode == ReplayMode.kResume 
						or self.replayMode == ReplayMode.kReview
					then
						self:onResumeReplayEnd()
						self.replayMode = ReplayMode.kNone
					end
					
				end
			end

			function NewGamePlaySceneUI:replayResult( levelId, score, star, coin, targetCount, bossCount )
				
				if self:isReplayMode() and self.replayMode == ReplayMode.kCheck then

					local ret = {}
					ret.levelId = levelId
					ret.totalScore = score
					ret.star = star
					ret.coin = coin
					ret.bossCount = bossCount or 0
					ret.targetCount = targetCount or 0

					if _G.isLocalDevelopMode then printx(0, "=====================Check Play Result=====================") end
					if _G.isLocalDevelopMode then printx(0, "=====================   Ver   1.0.1   =====================") end
					if _G.isLocalDevelopMode then printx(0, table.tostring(ret)) end
					if _G.isLocalDevelopMode then printx(0, "===========================================================") end

					local function endReplay()

						if CheckPlay then
							local retCode = CheckPlay:checkReplayReusltData(ret)
							CheckPlay:checkResult(retCode, ret , self.gameBoardLogic)
						end
						self:endReplay()
						self.checkPlayIsEnd = true
					end
					setTimeOut(endReplay, 0.1)
				end
			end
		end
		
		local newStartLevelLogic = NewStartLevelLogic:create( nil , playData.level , {} , false , {} )
		--newStartLevelLogic:startWithReplay( ReplayMode.kCheck , playData )
		newStartLevelLogic:startWithReplay(checkType or ReplayMode.kCheck , playData )

		return nil
	else
		return CheckPlayScene:createWithLevelConfig( levelConfig , playData , version )
	end

end

function CheckPlay:getCheckPlayDiffTable()

	if self.checkIdLogMap[self.runningCheckId] then
		return nil
	else
		if not self.runningPlayDiffData then
			self.runningPlayDiffData = {}
		end

		self.checkIdLogMap[self.runningCheckId] = true

		return self.runningPlayDiffData
	end
end

function CheckPlay:resetCheckId()
	self.runningCheckId = 0
end

function CheckPlay:setQACheckData(score)
	self.score = score
end

function CheckPlay:check(checkId, diffData, playData, version, checkType)
	-- body
	printx( 1 , "   CheckPlay:check  ====================================================================")
	printx( 1 , "   CheckPlay:check  ====================================================================")
	printx( 1 , "   CheckPlay:check  =========================     START       ==========================")
	printx( 1 , "   CheckPlay:check  =========================== Ver  1.0.1 =============================")
	printx( 1 , "   CheckPlay:check  ====================================================================")

	if self.runningCheckId ~= 0 then

		CheckPlay:checkResult( CheckPlay.RESULT_ID.kHasCheckTaskRunning ,
								{ newCheckId = checkId , lastCheckId = self.runningCheckId } )
		return
	end

	self.runningPlayDiffData = diffData
	self.runningPlayData = playData
	self.runningCheckId = checkId

	--local scene = ReplayGameScene:create(levelId, self.replayTable[target:getTag()])
	local scene = CheckPlay:getCheckScene(playData, version, checkType)
	
	if scene then 
		scene:startCheckReplay() 
	end
	--Director:sharedDirector():pushScene(scene)

end

function CheckPlay:checkReplayReusltData( ret )
	assert(ret)
	if self.score ~= ret.totalScore then

		local diffScore = math.abs( tonumber(self.score) - tonumber(ret.totalScore) )
		if tonumber(diffScore) / tonumber(self.score) <= 0.2 then
			return CheckPlay.RESULT_ID.kScoreIsClose
		else
			return CheckPlay.RESULT_ID.kScoreNotMatch
		end
	end
	return CheckPlay.RESULT_ID.kSuccess
end

function CheckPlay:createFailedStatisticsData( resultId , mainlogic )

	local levelId = mainlogic.level
	local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID(levelId)
	local boardmap = mainLogic.boardmap
	local gameItemMap = mainLogic.gameItemMap
	local initialMapData = mainLogic.initialMapData
	local theCurMoves = mainLogic.theCurMoves			----当前剩余移动量
	local realCostMove = mainLogic.realCostMove 		----实际使用过的步数


	for r=1,#initialMapData.gameItemMap do
		format = format.. "| "
		for c=1,#initialMapData.gameItemMap[r] do
			local item = initialMapData.gameItemMap[r][c]
			local board = initialMapData.boardmap[r][c]
			local portal = 0
			if board:hasExitPortal() then portal = portal + 1 end
			if board:hasEnterPortal() then portal = portal + 2 end
	 		format = format .. string.format("%02d", item.ItemType) .. "   "
		end

		format = format .. " | "

	-- 	-- for c=1,#self.gameItemMap[r] do
	-- 	-- end
		format = format .. "\n"
	end

	if resultId == CheckPlay.RESULT_ID.kSwapFail then

	elseif resultId == CheckPlay.RESULT_ID.kNotEnd then

	elseif resultId == CheckPlay.RESULT_ID.kScoreNotMatch then

	end
end

function CheckPlay:checkResult( resultId , resultData , mainlogic)
	-- body
	self.checkIdLogMap[self.runningCheckId] = nil

	if CheckPlay.repeatForever then --这里面都是测试代码

		if resultData and resultData.totalScore and resultData.totalScore ~= 36055 then
			self:check( self.runningCheckId , self.runningPlayDiffData , self.runningPlayData )
		end
	end
	self.runningCheckId = 0

	--local datas = self:createFailedStatisticsData( resultId , mainlogic )

	print("CheckPlay:checkResult    " ,  resultId , resultData , mainlogic)
	self:sendToServer(resultId,resultData)
	StartupConfig:getInstance():receive()
end


function CheckPlay:initParam(clientId,checkId,diff,gameData,clientMd5,score,version)
	self.clientId = clientId
	self.checkId = checkId
	self.clientMd5 = clientMd5
	self.score = score
	self.version = version
end


function CheckPlay:heardBeat()

end

-- {
-- 	"cmd" : "report",
-- 	"argv": {"clientId": 1, "taskId": "56ea5eb3a82622ebdb1a2e4a", "resultCode" : 0, "resultMsg": ""}
-- }
function CheckPlay:sendToServer(resultId,resultData)
	if _G.isLocalDevelopMode then printx(0, ">>>>>>>> check result >>>>>>>>",resultId,resultData) end

	local ret = {}
	ret["cmd"] = "report"
	local tArgv = {}
	tArgv["taskId"] = self.checkId
	tArgv["resultCode"] = resultId
	tArgv["resultMsg"] = simplejson.encode( resultData )
	ret["argv"] = tArgv

	local tmp = simplejson.encode(ret)
	if _G.isLocalDevelopMode then printx(0, "report sendToServer",tmp) end
	StartupConfig:getInstance():send(tmp)
end


-- ========= call from cpp =============
	-- std::string s_pid(pid);
	-- std::string s_diff(diff);
	-- std::string s_oplog(oplog);
	-- std::string s_clientMd5(clientMd5);
	-- std::string s_score(score);
	-- std::string s_version(version);
function checkInLua(clientId,checkId,diff,gameData,clientMd5,score,version)
	if _G.isLocalDevelopMode then printx(0, ">>>>>>>>> start check in lua >>>>>>>>>>>>>>>>>>>") end
	if _G.isLocalDevelopMode then printx(0, "clientId",clientId) end
	if _G.isLocalDevelopMode then printx(0, "checkId",checkId) end
	-- if _G.isLocalDevelopMode then printx(0, "diff",diff) end
	if _G.isLocalDevelopMode then printx(0, "gameData",gameData) end
	if _G.isLocalDevelopMode then printx(0, "clientMd5",clientMd5) end
	if _G.isLocalDevelopMode then printx(0, "score",score) end
	if _G.isLocalDevelopMode then printx(0, "version",version) end
	

	CheckPlay:initParam(clientId,checkId,diff,gameData,clientMd5,score,version)

	local dst = mime.unb64(diff)
	local currTime = os.time()
	local diffJson
	if dst then
	    local filePath = HeResPathUtils:getUserDataPath() .. "/testlevel_" .. tostring(checkId) .. "_" .. tostring(currTime) .. ".inf"
	    local file, err = io.open(filePath, "wb")

	    if file and not err then
	        file:write(dst)
            file:flush()
            file:close()
        end
		local decodeContent = HeFileUtils:decodeFile(filePath)
		diffJson = table.deserialize(decodeContent)
		os.remove(filePath)
	end
	-- gameData
    local data = "{\"level\":1,\"replaySteps\":[{\"x2\":4,\"x1\":3,\"y2\":5,\"y1\":5},{\"x2\":4,\"x1\":4,\"y2\":6,\"y1\":5},{\"x2\":5,\"x1\":5,\"y2\":7,\"y1\":6},{\"x2\":3,\"x1\":2,\"y2\":3,\"y1\":3}],\"hasDropBuff\":false,\"randomSeed\":1461830956,\"selectedItemsData\":{}}"
    tData = simplejson.decode(gameData)

    CheckPlay:check(checkId,diffJson,tData , version)

	return true
end


function CheckPlay:checkSnapshotDiff( snapshotId )

	local context = ReplayDataManager
	if context.checkSnapshotData and context.snapshotData then
		
		local logSS = context.checkSnapshotData[snapshotId]
		local currSS = context.snapshotData.snapshots[snapshotId]

		if logSS and currSS and logSS.sid == currSS.sid and currSS.sid == snapshotId then
			--printx( 1 , "   logSS.ts ~= currSS.ts " , logSS.ts , currSS.ts)
			if logSS.ts ~= currSS.ts then
				printx( 1 , "  分数不对！ old =" , logSS.ts , "  new =" , currSS.ts)
			end

		end
	end
end

function CheckPlay:loadLocalReplaySS()

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
				ReplayDataManager.checkSnapshotData = output
			end
			printx( 1 , "   #checkSnapshotData = " , #output )
		end
	end
end