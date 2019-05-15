GameMapSnapshot = class()

local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()

local kDefaultFileDir = "D:/level_share"
-- local kTempFile = kDefaultFileDir.."/tmp.png"
local kBoardSnap = kDefaultFileDir.."/level_board_%d.png"

function GameMapSnapshot:ctor()
	FrameLoader:loadPngOnly("editorRes/materials/game_bg.png")
end

function GameMapSnapshot.getInstance()
	if not GameMapSnapshot.s_instance then
		GameMapSnapshot.s_instance = GameMapSnapshot:create()
	end
	return GameMapSnapshot.s_instance
end

function GameMapSnapshot:create()
	local instance = GameMapSnapshot.new()
	instance:init()
	return instance
end

function GameMapSnapshot:init()
	self:reset()
end

function GameMapSnapshot:makeSurePaths(savePath)
	local sharePath = self:getLevelSharePath(savePath)
	local boardPath = self:getLevelBoardPath(savePath)
	-- local dirPath = string.gsub(rootPath, "/", "\\") -- replace / with \
	os.execute("mkdir "..string.gsub(savePath, "/", "\\"))
	os.execute("mkdir "..string.gsub(sharePath, "/", "\\"))
	os.execute("mkdir "..string.gsub(boardPath, "/", "\\"))
end

function GameMapSnapshot:getLevelSharePath(savePath)
	return savePath.."/share"
end

function GameMapSnapshot:getLevelBoardPath(savePath)
	return savePath.."/board"
end

function GameMapSnapshot:buildShareGroup(levelId, playBoard)
	local shareGroup = "level_snapshot/normal_level"
	local titleText = string.format("第%s关", levelId)

	if LevelType:isHideLevel( levelId ) then
		shareGroup = "level_snapshot/hidden_level"
		titleText = string.format("精英关%s", levelId - LevelConstans.HIDE_LEVEL_ID_START)
	end

	local builder = InterfaceBuilder:createWithContentsOfFile("editorRes/flash/level_snapshot.json")
	local levelShare = builder:buildGroup(shareGroup)

	local imgLayer = levelShare:getChildByName("img")
	local zOrder = imgLayer:getZOrder()
	local imgPos = imgLayer:getPosition()
	imgLayer:removeFromParentAndCleanup(true)

	local levelIdLabelHolder = levelShare:getChildByName("title"):getChildByName("level_id_holder")
	local levelIdBounds = levelIdLabelHolder:getGroupBounds()
	local labelRotation = levelIdLabelHolder:getRotation()

	levelShare:addChildAt(playBoard, zOrder)
	playBoard:setAnchorPoint(ccp(0, 1))
	playBoard:ignoreAnchorPointForPosition(false)
	playBoard:setRotation(-7.5)
	playBoard:setPosition(ccp(imgPos.x - 12, imgPos.y - 26))

	playBoard:getTexture():setAntiAliasTexParameters()

	local levelIdLabel = BitmapText:create(titleText, CCFileUtils:sharedFileUtils():fullPathForFilename("editorRes/font/level_id_numbers.fnt"), -1, kCCTextAlignmentCenter)
	levelIdLabel:setScale(levelIdLabelHolder:getScaleX(), levelIdLabelHolder:getScaleY())
	levelIdLabel:setRotation(labelRotation)
	levelIdLabel:setPosition(ccp(levelIdBounds.origin.x + levelIdBounds.size.width / 2 + 10, levelIdBounds.origin.y + levelIdBounds.size.height / 2 + 7))
	levelIdLabel:setPreferredSize(levelIdBounds.size.width, levelIdBounds.size.height)
	levelShare:addChild(levelIdLabel)

	levelIdLabelHolder:removeFromParentAndCleanup(true)

	return levelShare
end

function GameMapSnapshot:genSnapShot(levelId, saveDir, onFinish)
	local function onGenPlayBoardSnapShot(levelId, playBoard)
		local shareGroup = nil
		if playBoard then
			local saveName = string.format("jt0001%04d.jpg", levelId)
			if LevelType:isHideLevel( levelId ) then
				saveName = string.format("hide%04d.jpg", levelId - LevelConstans.HIDE_LEVEL_ID_START)
			end

			shareGroup = GameMapSnapshot:buildShareGroup(levelId, playBoard)

			local renderTexture = CCRenderTexture:create(720, 500)
	   		renderTexture:begin()
	   		shareGroup:setPosition(ccp(0, 500))
	    	shareGroup:visit()
	  		renderTexture:endToLua()
	  		renderTexture:saveToFile(string.format("%s/%s", self:getLevelSharePath(saveDir), saveName))

	  		if _G.isLocalDevelopMode then printx(0, string.format("success generate share: %d", levelId)) end
	  		if type(self.onGenerateResult) == "function" then self.onGenerateResult(levelId, true) end
	  	else
	  		if _G.isLocalDevelopMode then printx(0, string.format("failed generate share: %d", levelId)) end
	  		if type(self.onGenerateResult) == "function" then self.onGenerateResult(levelId, false) end
		end
		if onFinish then onFinish(levelId, shareGroup) end
	end
	local levelType = levelType or LevelType:getLevelTypeByLevelId(levelId)
	GameMapSnapshot:genPlayBoardSnapShot(levelId, levelType, saveDir, onGenPlayBoardSnapShot)
end

function GameMapSnapshot:genSnapshotWithRange(levelStart, levelEnd, saveDir, onFinish)
	assert(type(levelStart) == "number")
	assert(type(levelEnd) == "number")

	if levelStart > levelEnd then levelStart, levelEnd = levelEnd, levelStart end
	local function startGen(levelId)
		if self.hasStopped then
			if type(self.onStopCallback) == "function" then self.onStopCallback() end
			return
		end

		if levelId <= levelEnd then
			local function startNext()
				setTimeOut(function() startGen(levelId + 1) end, 0.1)
			end
			self:genSnapShot(levelId, saveDir, startNext)
		else
			if type(onFinish) == "function" then onFinish() end
		end
	end
	startGen(levelStart)
end

function GameMapSnapshot:genPlayBoardSnapShot(levelId, levelType, saveDir, onSuccess)
	local function callback()
		local scene = NewGamePlaySceneUI.new()
		local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID(levelId, false)
		scene:init(levelConfig, {}, GamePlaySceneUIType.kDev)

   		local gameBoardView = scene.gamePlayScene and scene.gamePlayScene.mygameboardview or nil
   		if not gameBoardView then return end
   		gameBoardView:resizeToFitScreenSnapShot()
   		gameBoardView:removeFromParentAndCleanup(false)
		gameBoardView:unRegisterAll()

   		scene:dispose()
  		scene = nil

		local imgPath = CCFileUtils:sharedFileUtils():fullPathForFilename("editorRes/materials/game_bg.png")
		local texture = CCTextureCache:sharedTextureCache():addImage(imgPath)
		local bg = Sprite:createWithTexture(texture)

   		local playScene = Layer:create()

   		bg:setPosition(ccp(360, 640-50))
   		playScene:addChild(bg)
   		playScene:addChild(gameBoardView)

   		local gameBoardWidth = 630 -- 棋盘 630 * 630
   		local snapRectWidth = 670 -- PlayScene截图大小 670 * 670
   		local gameBoardMargin = (snapRectWidth - gameBoardWidth) / 2 -- 棋盘截图边缘空白(上下左右都相等)
   		local gbPosX = (720 - gameBoardWidth) / 2
   		local gbPosY = (1280 - gameBoardWidth) / 2
   		-- gameBoardView:setScale(1)
   		-- local pos = gameBoardView:getPosition()
   		-- gameBoardView:setPosition(ccp(pos.x, pos.y))

   		local retSprite = nil
   		if gameBoardView then
   			local boardImgName = string.format("level_board_%d.png", levelId)
   			local savePath = string.format("%s/%s", self:getLevelBoardPath(saveDir), boardImgName)
	   		local playScenePos = ccp(0 - (gbPosX - gameBoardMargin), 0 - (gbPosY - gameBoardMargin) + 25)
   			playScene:setPosition(playScenePos)

			local renderTexture1 = CCRenderTexture:create(snapRectWidth, snapRectWidth)
	   		renderTexture1:beginWithClear(0, 0, 0, 0)
	    	playScene:visit()
	  		renderTexture1:endToLua()

	  		renderTexture1:saveToFile(savePath)

	  		CCTextureCache:sharedTextureCache():removeTextureForKey(savePath)
	  		local texture1 = CCTextureCache:sharedTextureCache():addImage(savePath)
	  		local sprite1 = Sprite:createWithTexture(texture1)--renderTexture1:getSprite()
	  		-- local sprite1 = Sprite:createWithTexture(texture)

	  		local renderTexture = CCRenderTexture:create(370, 370)
	   		renderTexture:beginWithClear(240, 242, 244, 0)
	   		sprite1:setScale(350 / snapRectWidth)
	   		sprite1:setPosition(ccp(185, 185))
	    	sprite1:visit()
	  		renderTexture:endToLua()

	  		renderTexture:saveToFile(savePath)
	  		CCTextureCache:sharedTextureCache():removeTextureForKey(savePath)
	  		local texture2 = CCTextureCache:sharedTextureCache():addImage(savePath)
	  		-- retSprite:setFlipY(true)
	  		retSprite = Sprite:createWithTexture(texture2)

	  		playScene:dispose()
	  		playScene = nil
	  	end

  		if onSuccess then onSuccess(levelId, retSprite) end
	end
	self:loadExtraResource(levelId, levelType, callback)
end

function GameMapSnapshot:loadExtraResource( levelId, levelType, callback )
	-- body
	local levelMeta = LevelMapManager.getInstance():getMeta(levelId)
	local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID(levelId)
	local fileList = levelConfig:getDependingSpecialAssetsList()
	local loader = FrameLoader.new()
	local function callback_afterResourceLoader()
		loader:removeAllEventListeners()
		if callback then callback() end
	end
	for i,v in ipairs(ResourceConfig.asyncPlist) do loader:add(v, kFrameLoaderType.plist) end
	for i,v in ipairs(fileList) do loader:add(v, kFrameLoaderType.plist) end
	loader:addEventListener(Events.kComplete, callback_afterResourceLoader)
	loader:load()
end

function GameMapSnapshot:addLevel(levelId)
	self:addLevelRange(levelId, levelId)
end

function GameMapSnapshot:addLevelRange(levelStart, levelEnd)
	assert(type(levelStart) == "number")
	assert(type(levelEnd) == "number")

	if type(levelStart) == "number" and type(levelEnd) == "number" then
		if levelStart > levelEnd then levelStart, levelEnd = levelEnd, levelStart end
		table.insert(self.levelRanges, {levelStart = levelStart, levelEnd = levelEnd})
	end
end

function GameMapSnapshot:addLevels(levelIds)
	local levelIdRanges = string.split(levelIds, ",")
	if #levelIdRanges > 0 then
		for _, v in pairs(levelIdRanges) do
			local range = string.split(v, "-")
			if #range > 0 then
				local levelStart = tonumber(range[1])
				local levelEnd = tonumber(range[2])
				if not levelEnd then levelEnd = levelStart end

				self:addLevelRange(levelStart, levelEnd)
			end
		end
	end
end

function GameMapSnapshot:reset()
	self.levelRanges = {}
	self.hasStopped = false
end

function GameMapSnapshot:start(saveDir, onFinish)
	self:makeSurePaths(saveDir)

	if #self.levelRanges > 0 then
		local function startGen(index)
			local range = self.levelRanges[index]
			if range then
				local function startNext()
					startGen(index + 1)
				end
				self:genSnapshotWithRange(range.levelStart, range.levelEnd, saveDir, startNext)
			else
				if type(onFinish) == "function" then onFinish() end
			end
		end
		startGen(1)
	else
		if type(onFinish) == "function" then onFinish() end
	end
end

function GameMapSnapshot:stop(onStopCallback)
	self.hasStopped = true
	self.onStopCallback = onStopCallback
end

GameMapSnapshotTool = class(CocosObject)

local function createLabel(text, size, color)
	text = text or ""
	size = size or 28
	local label = TextField:create(text , "Helvetica", size)
	label:setAnchorPoint(ccp(0, 0.5))
	label:ignoreAnchorPointForPosition(false)
	if color then label:setColor(color) end
	return label
end

function GameMapSnapshotTool:ctor()
	self.width = 680
	self.height = 240
end

function GameMapSnapshotTool:create()
	local ret = GameMapSnapshotTool.new(CCNode:create())
	ret:init()
	return ret
end

function GameMapSnapshotTool:createInputBox(text, boxSize, bgColor, fontSize, fontColor)
	text = text or ""
	bgColor = bgColor or ccc3(255, 255, 255)
	boxSize = boxSize or CCSizeMake(300, 40)
	fontSize = fontSize or 24
	fontColor = fontColor or ccc3(0, 0, 0)

	if _G.isLocalDevelopMode then printx(0, "createInputBox:", boxSize.width, boxSize.height) end
	local container = LayerColor:createWithColor(bgColor, boxSize.width, boxSize.height)

	local displayText = TextField:create("", nil, fontSize, CCSizeMake(boxSize.width, boxSize.height), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
	displayText:setPosition(ccp(boxSize.width / 2, boxSize.height / 2))
	displayText:setColor(fontColor)
	displayText:setString(text)
	container:addChild(displayText)
	container.displayText = displayText

	local inputBg1 = Scale9Sprite:createWithSpriteFrameName("ui_commons/ui_transparent_rect0000")
	inputBg1:setOpacity(0)
	local inputBg2 = Scale9Sprite:createWithSpriteFrameName("ui_commons/ui_transparent_rect0000")
	inputBg2:setOpacity(0)
	local textInput = TextInput:create(CCSizeMake(boxSize.width, boxSize.height), inputBg1, inputBg2)
	textInput:setFontColor(fontColor)
	textInput:setPosition(ccp(boxSize.width / 2, boxSize.height / 2))
	textInput:setText("")
	container:addChild(textInput)
	container.textInput = textInput

	local touchLayer = LayerColor:createWithColor(ccc3(255, 255, 255), boxSize.width, boxSize.height)
	touchLayer:setOpacity(0)
	touchLayer:setTouchEnabled(true, -999, true)
	local function onBoxTapped()
		local text = displayText:getString()
		displayText:setVisible(false)
		textInput:setText(text)
		textInput:openKeyBoard()
	end
	touchLayer:addEventListener(DisplayEvents.kTouchTap, onBoxTapped)
	container.touchLayer = touchLayer
	container:addChild(touchLayer)

	local function onTextChanged( ... )
		local text = textInput:getText()
		displayText:setString(text)
	end
	local function onTextEnd( ... )
		textInput:setText("")
	end
	local function onTextReturn( ... )
		displayText:setVisible(true)
	end
	textInput:ad(kTextInputEvents.kEnded, onTextEnd)
	textInput:ad(kTextInputEvents.kChanged, onTextChanged)
	textInput:ad(kTextInputEvents.kReturn, onTextReturn)

	container:setAnchorPoint(ccp(0, 1))
	container:ignoreAnchorPointForPosition(false)
	return container
end

function GameMapSnapshotTool:init()
	self:setContentSize(CCSizeMake(self.width, self.height))
	self:setAnchorPoint(ccp(0, 1))
	self:ignoreAnchorPointForPosition(false)

	local bg = LayerColor:createWithColor(ccc3(0, 0, 0), self.width, self.height)
	bg:setOpacity(255)
	self:addChild(bg)

	self.title = createLabel("关卡截图工具" , 28, ccc3(250, 250, 250))
	self.title:setPosition(ccp(10, self.height - 40))
	self.title:setColor(ccc3(255, 0, 0))
	self:addChild(self.title)

	local levelsLabel = createLabel("------------------------------------------------------------------" , 24, ccc3(250, 250, 250))
	levelsLabel:setPosition(ccp(15, self.height - 70))
	-- levelsLabel:setColor(ccc3(255, 0, 0))
	self:addChild(levelsLabel)

	local text = ""
	local pNormal9SpriteBg = Scale9Sprite:createWithSpriteFrameName("ui_commons/ui_transparent_rect0000")
	pNormal9SpriteBg:setOpacity(0)

	local box = self:createInputBox(text, CCSizeMake(520, 40))
	box:setAnchorPoint(ccp(0, 1))
	box:ignoreAnchorPointForPosition(false)
	box:setPosition(ccp(20, self.height - 100))
	self:addChild(box)

	local button = LayerColor:createWithColor(ccc3(80, 80, 80), 80, 40)
	local bLabel = createLabel("开始" , 28, ccc3(250, 250, 250))
	button.label = bLabel
	bLabel:setAnchorPoint(ccp(0.5, 0.5))
	bLabel:setPosition(ccp(40, 20))
	button:addChild(bLabel)
	button:setPosition(ccp(560, self.height - 140))
	button:setTouchEnabled(true)

	local logic = GameMapSnapshot:create()

	local onFinish = nil
	local onStartTapped = nil
	local onStopTapped = nil

	onFinish = function()
		_G.disable_item_debug_info = false
		_G.board_snapshot_mode = false

		button.label:setString("开始")
		button:removeAllEventListeners()
		button:addEventListener(DisplayEvents.kTouchTap, onStartTapped)
	end	

	onStopTapped = function()
		button:removeAllEventListeners()

		local function onStopCallback()
			_G.disable_item_debug_info = false
			_G.board_snapshot_mode = false

			button.label:setString("开始")
			button:addEventListener(DisplayEvents.kTouchTap, onStartTapped)
		end

		logic:stop(onStopCallback)
	end

	onStartTapped = function()
		_G.disable_item_debug_info = true
		_G.board_snapshot_mode = true
		button.label:setString("停止")
		button:removeAllEventListeners()
		button:addEventListener(DisplayEvents.kTouchTap, onStopTapped)

		logic:reset()

		local levelIds = box.displayText:getString()
		logic:addLevels(levelIds)

		logic:start(kDefaultFileDir, onFinish)
	end
	button:addEventListener(DisplayEvents.kTouchTap, onStartTapped)
	self:addChild(button)

	local desc1 = createLabel("默认存储路径: D:/level_share" , 20, ccc3(250, 250, 250))
	desc1:setPosition(ccp(20, self.height - 180))
	self:addChild(desc1)
	local desc2 = createLabel("关卡格式形如：100-120,133,10001-10035" , 20, ccc3(250, 250, 250))
	desc2:setPosition(ccp(20, self.height - 210))
	self:addChild(desc2)
end

function GameMapSnapshotTool:genByCmd(savePath, levels, onFinish)
	local function doSnap()
		_G.disable_item_debug_info = true
		_G.board_snapshot_mode = true

		local logic = GameMapSnapshot:create()
		logic:addLevels(levels)

		if _G.isLocalDevelopMode then printx("=====================================") end
		if _G.isLocalDevelopMode then printx("==== genByCmd:", levels, savePath) end
		if _G.isLocalDevelopMode then printx("=====================================") end
		
		savePath = savePath or kDefaultFileDir
		logic:start(savePath, onFinish)
	end
	xpcall(doSnap, function(err)
		local message = err
   	 	local traceback = debug.traceback("", 2)
    	printx(-99, message)
   		printx(-99, traceback)
		if onFinish then onFinish() end
	end)
end