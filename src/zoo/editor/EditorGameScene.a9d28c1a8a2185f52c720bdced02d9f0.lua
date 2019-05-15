require "hecore.display.TextField"

require "zoo.scenes.GamePlayScene"
require "zoo.config.LevelConfig"
require "zoo.data.DevTestLevelMapManager"
require "zoo.scenes.DevTestGamePlayScene"
require "zoo.editor.EditorStartPanel"
require "zoo.editor.EditorModeGameResource"

local isTestMode = true
local curEditorGameScene
local levelConfigFromAceEditor

local EditorResDic = {	"ui/HalloweenPumpkin", 
						"activity/DragonBoat2017",
						
						"flash/halloween_2015.png",
						"flash/hedgehog_road.png",
						"flash/spring2017",
						"flash/nationday2017",
						"flash/olympic",
						-- "flash/two_year_line_effect",
						-- "flash/magic_tile",
						-- "flash/sea_animal",

						-- "flash/scenes/gamePlaySceneUI/rainbow",

						-- "skeleton/chicken_mother_spring2017",
						-- "skeleton/bee_animation",
						-- "skeleton/sea_animal_animation",
						-- "flash/scenes/flowers/target_icon",
					}
-- 为活动临时恢复的资源，因为可能会影响正常的关卡和周赛关卡，所以特殊处理
local EditorResDicForActivityInEditorMode = {
						-- "flash/dig_block",
}
local EditorSkeletonResDic = {"skeleton/christmas_animation", "skeleton/wukong_animation"}
local simplejson = require("cjson")

local recordUrl = "http://10.130.137.97/animal-new-fc/editor.action?method=record&"  -- 存试玩数据地址
-- local zanUrl = "http://10.130.136.100/animal-fc-web/map.new.match.action" --animal开发测试地址  王阳机器
local zanUrl = "http://10.130.137.33:8090/animal-fc/map.new.match.action"


----------编辑器关卡内------------------------------EditorGamePlayScene-----------------------------------
local EDITOR_PLAY_RESULT = {
	QUIT = -1,
	SUCCESS = 1,
	FAIL = 0
}

--EditorGamePlayScene = class(DevTestGamePlayScene)
EditorGamePlayScene = class(DevTestGamePlayScene)

function EditorGamePlayScene:create(levelConfig , selectedItemsData)
	local scene = EditorGamePlayScene.new()
	scene:init( levelConfig , selectedItemsData )
	return scene
end

function EditorGamePlayScene:_createTestButton(text, color, fntSize, width, height)
	color = color or ccc3(64,64,64)
	width = width or 150
	height = height or 50
	local btn = LayerColor:createWithColor(color, width, height)
	btn:setTouchEnabled(true, 0, true)
	btn:setOpacity(255 * 0.75)

	fntSize = fntSize or 30
	local label = TextField:create(tostring(text), nil, fntSize)
	label:setAnchorPoint(ccp(0.5,0.5))
	label:setPositionX(width/2)
	label:setPositionY(height/2)
	btn.label = label
	btn:addChild(label)

	return btn
end

function EditorGamePlayScene:init( levelConfig , selectedItemsData, gamePlaySceneUiType )
	DevTestGamePlayScene.init(self, levelConfig , selectedItemsData, gamePlaySceneUiType )
	--self.propList:addFakeAllProp(999)
	self.editorPrePropsList = selectedItemsData or {}

	if self.levelType == GameLevelType.kSpring2017 then
		local vSize = CCDirector:sharedDirector():getVisibleSize()
		local addBombBtn = self:_createTestButton("炸弹+")
		local decBombBtn = self:_createTestButton("炸弹-")
		local function onTapped1()
			printx(0, "addBombBtn")
			local gameMode = self.gameBoardLogic.gameMode
			gameMode.encryptData.bombNum = gameMode.encryptData.bombNum + 1
			gameMode:updateUFOBombNum()
			gameMode:updateUFOAnimation()
		end
		addBombBtn:addEventListener(DisplayEvents.kTouchTap, onTapped1)
		local function onTapped2()
			printx(0, "decBombBtn")
			local gameMode = self.gameBoardLogic.gameMode
			if gameMode.encryptData.bombNum > 0 then
				gameMode.encryptData.bombNum = gameMode.encryptData.bombNum - 1
				gameMode:updateUFOBombNum()
				gameMode:updateUFOAnimation()
			end
		end
		decBombBtn:addEventListener(DisplayEvents.kTouchTap, onTapped2)
		addBombBtn:setPosition(ccp(100, vSize.height - 50))
		decBombBtn:setPosition(ccp(260, vSize.height - 50))
		self:addChild(addBombBtn)
		self:addChild(decBombBtn)
	end
end

function EditorGamePlayScene:zan()

	if (levelConfigFromAceEditor.header) then

		local config = CCUserDefault:sharedUserDefault()
		local alreadyZan = config:getIntegerForKey(levelConfigFromAceEditor.user..tostring(levelConfigFromAceEditor.uuID),0)
		
		if _G.isLocalDevelopMode then printx(0, levelConfigFromAceEditor.header..levelConfigFromAceEditor.user , alreadyZan) end
		
		local close = function()

		end

		local pos = function()
			if _G.isLocalDevelopMode then printx(0, "zan") end
			self:sendZanData()
			close()
		end

		if (not alreadyZan) then
		elseif (alreadyZan and alreadyZan > 0) then
		else
			local panel = TwoChoicePanel:create("给我点个赞不？", "赞", "不了","赞")
			panel.checkbox:setVisible(false)
			panel:setButton1TappedCallback(pos)
			panel:setButton2TappedCallback(close)
			panel:setCloseButtonTappedCallback(close)
			panel:popout()
		end
	end


end

function EditorGamePlayScene:addUsePropInfo(propID)
	self.propsList[#self.propsList + 1] = propID
end

function EditorGamePlayScene:sendZanData()
	local request = HttpRequest:createPost(zanUrl)
	local requestData = "method=like&id="..tostring(levelConfigFromAceEditor.uuID).."&auth="..levelConfigFromAceEditor.header
	request:addHeader("Authorization:Basic "..levelConfigFromAceEditor.header)

	if _G.isLocalDevelopMode then printx(0, "requestData ",requestData) end
	request:setPostData(requestData, #requestData)
	local function onCallback(response)
		if response.httpCode and response.httpCode == 200 then
			if response.errorCode == 0 then
				-- self:onRecordSuccess()
				CommonTip:showTip("点赞成功", "positive")

				local config = CCUserDefault:sharedUserDefault()
				config:setIntegerForKey(levelConfigFromAceEditor.user..tostring(levelConfigFromAceEditor.uuID),1)
				config:flush()
			else
				CommonTip:showTip("点赞失败", "positive")
			end
		else
			CommonTip:showTip("点赞失败", "positive")
		end
	end
	HttpClient:getInstance():sendRequest(onCallback, request)
end

function EditorGamePlayScene:sendResultData(data)
	local request = HttpRequest:createPost(recordUrl)
	local requestData = "data=" .. simplejson.encode(data)
	request:setPostData(requestData, #requestData)
	local function onCallback(response)
		if response.httpCode and response.httpCode == 200 then
			if response.errorCode == 0 then
				self:onRecordSuccess()
			else
				self:onRecordFail()
			end
		else
			self:onRecordFail()
		end
	end
	HttpClient:getInstance():sendRequest(onCallback, request)
end

function EditorGamePlayScene:onQuitLevel()
	if levelConfigFromAceEditor ~= nil and levelConfigFromAceEditor.record then
		local recordData = self:getRecordData()
		recordData["result"] = EDITOR_PLAY_RESULT.QUIT
		recordData["targetCount"] = 0
		self:sendResultData(recordData)
	end

	DevTestGamePlayScene.onQuitLevel(self)

	self:zan()
end

function EditorGamePlayScene:onRecordSuccess()
	CommonTip:showTip("试玩数据保存成功", "positive")
end

function EditorGamePlayScene:onRecordFail()
	CommonTip:showTip("试玩数据保存失败！！！！！", "positive")
end

function EditorGamePlayScene:getInFactCount()
	local ret = ""
	if (self.gameBoardLogic.theGamePlayType == GameModeTypeId.ORDER_ID) then
		for i,v in ipairs(self.gameBoardLogic.theOrderList) do
		    -- if _G.isLocalDevelopMode then printx(0, v.key1,vkey2,v.f1,v.v1) end
		    ret = ret .. tostring(v.key1)
		    ret = ret .. "_"
		    ret = ret .. tostring(v.key2)
		    ret = ret .. "_"
		    ret = ret .. tostring(v.f1)
		    ret = ret .. "_"
		    ret = ret .. tostring(v.v1)
		    ret = ret .. ";"
		end
	end
	return ret
end

function EditorGamePlayScene:getRecordData()
	local gameBoardLogic = self.gameBoardLogic
	
	local d = {}
	d["levelUUId"] = levelConfigFromAceEditor.uuID
	d["user"] = levelConfigFromAceEditor.user
	d["gameVersion"] = levelConfigFromAceEditor.version
	d["score"] = gameBoardLogic.totalScore
	d["star"] = gameBoardLogic.gameMode:getScoreStarLevel()
	d["step"] = gameBoardLogic.realCostMove
	d["leftStep"] = gameBoardLogic.leftMoveToWin
	d["scrollNum"] = 0
	if gameBoardLogic.passedCol then
		d["scrollNum"] = gameBoardLogic.passedCol
	elseif gameBoardLogic.passedRow then
		d["scrollNum"] = gameBoardLogic.passedRow
	end
	if #self.editorPrePropsList > 0 then
		d["prePropsList"] = {}
		for i=1, #self.editorPrePropsList do
			d["prePropsList"][#d["prePropsList"] + 1] = self.editorPrePropsList[i].id
		end
	end
	if #curEditorGameScene.propsList > 0 then
		d["propsList"] = curEditorGameScene.propsList
	end
	d["target"] = self:getInFactCount()
	if _G.isLocalDevelopMode then printx(0, table.tostring(d)) end
	return d
end

function EditorGamePlayScene:failLevel(levelId, score, star, stageTime, coin, targetCount, opLog, isTargetReached, failReason, ...)
	if levelConfigFromAceEditor ~= nil and levelConfigFromAceEditor.record then
		local recordData = self:getRecordData()
		recordData["result"] = EDITOR_PLAY_RESULT.FAIL
		recordData["targetCount"] = targetCount
		self:sendResultData(recordData)
	end
	
	DevTestGamePlayScene.failLevel(self, levelId, score, star, stageTime, coin, targetCount, opLog, isTargetReached, failReason, ...)

	self:zan()
end

function EditorGamePlayScene:passLevel(levelId, score, star, stageTime, coin, targetCount, opLog, bossCount, ...)
	if levelConfigFromAceEditor ~= nil and levelConfigFromAceEditor.record then
		local recordData = self:getRecordData()
		recordData["result"] = EDITOR_PLAY_RESULT.SUCCESS
		recordData["targetCount"] = targetCount
		self:sendResultData(recordData)
	end

	DevTestGamePlayScene.passLevel(self, levelId, score, star, stageTime, coin, targetCount, opLog, bossCount, ...)

	self:zan()
end


----------编辑器关卡外------------------------------EditorGameScene----------------------------------------
EditorGameScene = class(Scene)
function EditorGameScene:ctor()
	self.backButton = nil
	self.propsList = {}
end

function EditorGameScene:__getDependingSpecialAssetsList(levelConfig)
	local gameMode = levelConfig.gameMode
	local fileList = {}
	local levelType = LevelType:getLevelTypeByLevelId(levelConfig.level)
	fileList = levelConfig:getDependingSpecialAssetsList(levelType) or {}
	local toReplace

	if gameMode == GameModeType.HALLOWEEN then
		toReplace = {"flash/add_five_step_ani.plist", "flash/halloween_2015.plist", "flash/boss_pumpkin.plist", 
					 "flash/boss_pumpkin_die.plist", "flash/boss_pumpkin_ghost_1.plist", "flash/boss_pumpkin_ghost_2.plist"}
	elseif gameMode == GameModeType.HEDGEHOG_DIG_ENDLESS then
		toReplace = {"flash/hedgehog.plist","flash/hedgehog_road.plist","flash/hedgehog_target.plist","flash/christmas_other.plist", }
	elseif gameMode == GameModeType.WUKONG_DIG_ENDLESS then
	end

	if toReplace ~= nil and #toReplace > 0 then
		for i=1,#toReplace do
			local idx = table.indexOf(fileList, toReplace[i])
			if idx ~= nil then
				fileList[idx] = "editorRes/" .. fileList[idx]
			end
		end
	end

	return fileList
end

function EditorGameScene:dispose()
	if self.backButton then self.backButton:removeAllEventListeners() end
	self.backButton = nil
	_G.useDropBuffByEditor = false
	self:assetLoadFallBack()
	Scene.dispose(self)
	curEditorGameScene = nil
end

function EditorGameScene:create()
	local s = EditorGameScene.new()
	s:initScene()
	return s
end

function EditorGameScene:onInit()
	self:assetLoadByEditor()
	self:initDevTestLevel()
end

local backSpriteUtilGetRealResourceName
local backFrameLoaderGetRealResourceName
local backInterfaceBuilderGetRealResourceName

function _isResNeedBeMap(fileName)
	for _, v in pairs(EditorResDic) do
		-- printx(2, _isResNeedBeMap, fileName, v)
		if string.starts(fileName, v) then
			return true
		end
	end
	if _G.editorMode and _G.editorModeLevelType then
		local excludeLevelTypes = {GameLevelType.kMainLevel, GameLevelType.kHiddenLevel, GameLevelType.kSummerWeekly}
		if not table.exist(excludeLevelTypes, _G.editorModeLevelType) then
			for _, v in pairs(EditorResDicForActivityInEditorMode) do
				if string.starts(fileName, v) then
					return true
				end
			end
		end
	end
	return false
end

function EditorGameScene:getMappingFilePath(filePath)
	if _isResNeedBeMap(filePath) then
		return "editorRes/" .. filePath
	end
	return nil
end

function EditorGameScene:assetLoadByEditor()
	if backSpriteUtilGetRealResourceName == nil then
		backSpriteUtilGetRealResourceName = SpriteUtil.getRealResourceName 
		local function tempSpriteUtilGetRealResourceName( _, fileName )
			if _isResNeedBeMap(fileName) then
				fileName = "editorRes/" .. fileName
			end

		    return backSpriteUtilGetRealResourceName(_, fileName)
		end

		SpriteUtil.getRealResourceName = tempSpriteUtilGetRealResourceName

		backFrameLoaderGetRealResourceName = FrameLoader.getRealResourceName
		local function tempFrameLoaderGetRealResourceName( _, fileName )
			if _isResNeedBeMap(fileName) then
				fileName = "editorRes/" .. fileName
				return fileName
			end
			return backFrameLoaderGetRealResourceName(_, fileName)
		end
		FrameLoader.getRealResourceName = tempFrameLoaderGetRealResourceName

		backInterfaceBuilderGetRealResourceName = InterfaceBuilder.getRealResourceName
		local function tempInterfaceBuilderGetRealResourceName( _, fileName )
			if _isResNeedBeMap(fileName) then
				fileName = "editorRes/" .. fileName
			end
		    return backInterfaceBuilderGetRealResourceName(_, fileName)
		end

		InterfaceBuilder.getRealResourceName = tempInterfaceBuilderGetRealResourceName
	end
end

function EditorGameScene:assetLoadFallBack()
	SpriteUtil.getRealResourceName = backSpriteUtilGetRealResourceName
	backSpriteUtilGetRealResourceName = nil

	FrameLoader.getRealResourceName = backFrameLoaderGetRealResourceName
	backFrameLoaderGetRealResourceName = nil

	InterfaceBuilder.getRealResourceName = backInterfaceBuilderGetRealResourceName
	backInterfaceBuilderGetRealResourceName = nil
end

local testLevelId = nil
function EditorGameScene:initDevTestLevel()
	local testConfStr = levelConfigFromAceEditor
	local testData = table.deserialize(testConfStr)
	levelConfigFromAceEditor = testData
	-- if _G.isLocalDevelopMode then printx(0, "####### header is #######",levelConfigFromAceEditor.header) end

	local testConf = testData.levelCfg
	local useDropBuff = testData.useDropBuff
	_G.useDropBuffByEditor = useDropBuff
	testLevelId = testConf.totalLevel
	if (testLevelId == 9999) then
		testLevelId = testConf.id
	end
	if testConf.gameData.gameModeName == GameModeType.SPRING_HORIZONTAL_ENDLESS then
		testLevelId = 280204
	end

	if not testLevelId then 
		testLevelId = LevelMapManager:getInstance():getMaxLevelId() + 1
	end
	testConf.totalLevel = testLevelId
	testConf.uuID = testConf.id
	levelConfigFromAceEditor.uuID = testConf.id
	local levelType = LevelType:getLevelTypeByLevelId(testConf.totalLevel) or GameLevelType.kMainLevel
	if testConf.gameData.gameModeName == GameModeType.SPRING_HORIZONTAL_ENDLESS then
		levelType = GameLevelType.kOlympicEndless
	end
	_G.editorModeLevelType = levelType
	LevelMapManager:getInstance():addDevMeta(testConf)
	local levelMeta = LevelMapManager.getInstance():getMeta(testConf.totalLevel)
	local levelConfig = LevelConfig:create(testConf.totalLevel, levelMeta)
	LevelDataManager.sharedLevelData().levelDatas[testConf.totalLevel] = levelConfig
    local fileList = self:__getDependingSpecialAssetsList(levelConfig)
    -- if _G.isLocalDevelopMode then printx(0, "fileList",fileList) end
    local loader = FrameLoader.new()
    local function onFrameLoadComplete( evt )
        loader:removeAllEventListeners()
        local function pushNewScene()
       		if testData.autoPlayCount then
	       		local step = {randomSeed = 0, replaySteps = {}, level = testLevelId, selectedItemsData = {}}
				local newStartLevelLogic = NewStartLevelLogic:create( nil , step.level , {} , false , {} )
				newStartLevelLogic:startWithReplay( ReplayMode.kAuto , step )
				_G.__autoPlayCount = testData.autoPlayCount
				return
			end
        	if _G.__editorStartPanel ~= nil then 
        		self:removeChild(_G.__editorStartPanel) 
        	end
        	-- debug.debug()
        	if _G.isLocalDevelopMode then printx(0, "testLevelId+++++++++++++++++++++++",testLevelId) end
        	
        	self:handleBeforeStartLevel(testLevelId)

        	local status, result = pcall(function() _G.__editorStartPanel = EditorStartPanel:create(self, testLevelId, levelType) end)
        	 if status then
        	 	if _G.__editorStartPanel ~= nil then
   					_G.__editorStartPanel:setPosition(ccp(0, 1300))
   					self:addChild(_G.__editorStartPanel)
   				else
   				end
             else

        		local devTestGPS = EditorGamePlayScene:create( levelConfig, {})
    			self.devTestGPS = devTestGPS
    			devTestGPS.fileList = fileList
    			self:addChild(devTestGPS)

    			_G.currentEditorLevelScene = devTestGPS
        	 end
        end
       
        AsyncLoader:getInstance():waitingForLoadComplete(pushNewScene)
    end 

    FrameLoader:loadImageWithPlist("flash/buff_boom_res.plist")
   	FrameLoader:loadArmature("skeleton/BuffBoomAnimation")
	FrameLoader:loadArmature(PreBuffLogic:getInitFlyAnimSkeletonSourceName())

	FrameLoader:loadImageWithPlist("flash/firecrackerBlocker.plist")	-- Hmmm...

    local isActivitySupport = DragonBuffManager:getInstance():isActivitySupport()
    if isActivitySupport then
        FrameLoader:loadArmature('skeleton/dragonbuff')
    end

    for i,v in ipairs(fileList) do loader:add(v, kFrameLoaderType.plist) end
    loader:addEventListener(Events.kComplete, onFrameLoadComplete)
    loader:load()
end

function EditorGameScene:handleBeforeStartLevel(levelId)
	GameInitBuffLogic:clearInitBuff()
	GameInitBuffLogic:addBuffByTestFlag()
	if LevelType:isYuanxiao2017Level(levelId) then 
		InterfaceBuilder:createWithContentsOfFile("activity/DragonBoat2017/res/levelPlayRes.json")
	end
end

function EditorGameScene:addEditorRecordPropsInfo(itemID)
	self.propsList[#self.propsList + 1] = itemID
end

-- -- TEST PENG 
-- 给编辑器调用的开始游戏方法
function editorStartGame(dataCfg)
	_G.editorMode = true

	local data = simplejson.decode(dataCfg)
	local __do
	if data.isReplay then 
		__do = function ()
			require "zoo.panelBusLogic.NewStartLevelLogic"
			local step = data.data 
			local replaymode = ReplayMode.kNormal
			local newStartLevelLogic = NewStartLevelLogic:create(nil, step.level, {}, false, {})
			newStartLevelLogic:startWithReplay(replaymode , step)
		end
	else
		__do = function ()
			levelConfigFromAceEditor = dataCfg
			
			if curEditorGameScene == Director:sharedDirector():run() then
				Director:sharedDirector():pop(true)
				curEditorGameScene = nil
			end
			curEditorGameScene = EditorGameScene:create()
			Director:sharedDirector():pushScene(curEditorGameScene) 
		end
	end
	local status, msg = xpcall(__do , __G__TRACKBACK__)
	if not status then
	    if _G.isLocalDevelopMode then printx(-99, msg) end
	end
	return true
end

