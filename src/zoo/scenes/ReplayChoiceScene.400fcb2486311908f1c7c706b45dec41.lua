require "hecore.display.TextField"

require "zoo.config.LevelConfig"
require "zoo.scenes.CheckPlayScene"
require "zoo.gamePlay.CheckPlay"

local isTestMode = true

ReplayChoiceScene = class(Scene)
function ReplayChoiceScene:ctor()
	self.backButton = nil
	self.replayTable = nil
	self.nextPageButton = nil
	self.prePageButton = nil
	self.showingReplays = {}
	self.startIndex = 1
end
function ReplayChoiceScene:dispose()
	if self.backButton then self.backButton:removeAllEventListeners() end
	if self.nextPageButton then self.nextPageButton:removeAllEventListeners() end
	if self.prePageButton then self.prePageButton:removeAllEventListeners() end

	for i = 1, #self.showingReplays do
		self.showingReplays[i]:removeAllEventListeners()
		self.showingReplays[i] = nil
	end
	self.showingReplays = nil

	if self.replayTable then
		for i = 1, #self.replayTable do
			self.replayTable[i] = nil
		end
		self.replayTable = nil
	end

	self.backButton = nil
	self.nextPageButton = nil
	self.prePageButton = nil
	
	Scene.dispose(self)
end

function ReplayChoiceScene:create()
	local s = ReplayChoiceScene.new()
	s:initScene()
	return s
end

function ReplayChoiceScene:onInit()
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	local function onTouchGameReplayLabel(evt)
        local target = evt.target
        --[[
        local levelId = self.replayTable[target:getTag()].level
        --HeGameDefault:setFpsValue(10000)
        local scene = CheckPlayScene:create(levelId, self.replayTable[target:getTag()])
		scene:startReplay()
		]]--

		require "zoo.panelBusLogic.NewStartLevelLogic"
		local replayData = self.replayTable[target:getTag()]
		local newStartLevelLogic = NewStartLevelLogic:create(nil, replayData.level, {}, false, {})
		newStartLevelLogic:startWithReplay(ReplayMode.kNormal, replayData)
	end

	local function buildLayerButton(label, x, y, func, tag)
		local width = 160
		local height = 40
		local labelLayer = LayerColor:create()
		labelLayer:changeWidthAndHeight(width, height)
		labelLayer:setColor(ccc3(255, 20, 0))
		labelLayer:setOpacity(50)
		labelLayer:setPosition(ccp(x - width / 2, y - height / 2))
		labelLayer:setTouchEnabled(true, p, true)
		labelLayer:addEventListener(DisplayEvents.kTouchTap, func)
		labelLayer:setTag(tag)
		self:addChild(labelLayer)

		local textLabel = TextField:create(label.."", nil, 28, CCSizeMake(width,height), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
		textLabel:setAnchorPoint(ccp(0,0))
		labelLayer:addChild(textLabel)

		return labelLayer
	end

	local function listReplayButtons()

		local textLabel = TextField:create("（先登入一个账号后才能读取他的回放信息哦）", nil, 28, CCSizeMake(600, 30), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
		textLabel:setAnchorPoint(ccp(0,0))
		textLabel:setPosition(ccp(0, vSize.height - 145))
		self:addChild(textLabel)

		local counts = 4
		local textWidth = math.floor(vSize.width / counts);
		local textHeight = math.floor(textWidth / 4);

		local endIndex = ((vSize.height - 120) / textHeight - 2) * 4
		if _G.isLocalDevelopMode then printx(0, self.startIndex, endIndex, #self.replayTable) end
		if endIndex > #self.replayTable - self.startIndex then
			endIndex = #self.replayTable - self.startIndex
		end
		if _G.isLocalDevelopMode then printx(0, self.startIndex, endIndex) end

		endIndex = math.ceil(endIndex)

		for i = endIndex, 1, -1 do
			local x = textWidth * (math.fmod(endIndex - i, counts) + 0.5)
			local y = textHeight * (math.floor((endIndex - i)/ counts) + 0.5)

			local gameReplayLabel = buildLayerButton(self.replayTable[self.startIndex + i].level .. "(".. #self.replayTable[self.startIndex + i].replaySteps ..")",
				x, vSize.height - 160 - y + vOrigin.y, onTouchGameReplayLabel, self.startIndex + i)
			gameReplayLabel:addEventListener(DisplayEvents.kTouchTap, onTouchGameReplayLabel)
			table.insert(self.showingReplays, gameReplayLabel)
			self:addChild(gameReplayLabel)
		end
	end

	local function onTouchBackLabel(evt)
		if self.testUpdateScheduler then
			Director:getScheduler():unscheduleScriptEntry(self.testUpdateScheduler)
		end
		self.testContext = nil
		Director:sharedDirector():popScene()
	end

	local function onTouchNextPage(evt)
		for i = 1, #self.showingReplays do
			self.showingReplays[i]:removeAllEventListeners()
			if self.showingReplays[i]:getParent() then
				self.showingReplays[i]:getParent():removeChild(self.showingReplays[i], false)
			end
			self.showingReplays[i] = nil
		end

		self.startIndex = self.startIndex + 80
		if self.startIndex >= #self.replayTable then
			self.startIndex = 0
		end

		listReplayButtons()
	end

	local function onTouchPrePage(evt)
		for i = 1, #self.showingReplays do
			self.showingReplays[i]:removeAllEventListeners()
			if self.showingReplays[i]:getParent() then
				self.showingReplays[i]:getParent():removeChild(self.showingReplays[i], false)
			end
			self.showingReplays[i] = nil
		end

		self.startIndex = self.startIndex - 80
		if self.startIndex >= #self.replayTable or self.startIndex < 0 then
			self.startIndex = 0
		end

		listReplayButtons()
	end

	local function onDoTest()
		self:doTest()
	end

	local function buildLabelButton(label, x, y, func)
		local width = 150
		local height = 80
		local labelLayer = LayerColor:create()
		labelLayer:changeWidthAndHeight(width, height)
		labelLayer:setColor(ccc3(255, 0, 0))
		labelLayer:setPosition(ccp(x, y - height / 2))
		labelLayer:setTouchEnabled(true, p, true)
		labelLayer:addEventListener(DisplayEvents.kTouchTap, func)
		self:addChild(labelLayer)

		local textLabel = TextField:create(label.."", nil, 32)
		textLabel:setPosition(ccp(width/4 - 20, height/4))
		textLabel:setAnchorPoint(ccp(0,0))
		labelLayer:addChild(textLabel)

		return labelLayer
	end 
	self.backButton = buildLabelButton("< 返回", 0, vSize.height - 60 + vOrigin.y, onTouchBackLabel)
	self.nextPageButton = buildLabelButton("下一页", 250, vSize.height - 60 + vOrigin.y, onTouchNextPage)
	self.prePageButton = buildLabelButton("上一页", 450, vSize.height - 60 + vOrigin.y, onTouchPrePage)
	self.testButton = buildLabelButton("(°▽°〃)", 630, vSize.height - 60 + vOrigin.y, onDoTest)

	local function getAllReplays()
		local replayData = ReplayDataManager:readCheckReplayData()
		if replayData then return replayData.datas end
		return nil
	end

	if isTestMode then
		--self.replayTable = getAllReplays("test.rep")
		--printx(11, "currentID:", currentID)
		self.replayTable = getAllReplays()
		if not self.replayTable or #self.replayTable == 0 then return end

		self.startIndex = 0
		listReplayButtons()
	end
end

function ReplayChoiceScene:__doTest(context)
	--printx( 1 , "   ReplayChoiceScene:__doTest")

	if context.state == "fileLoadFailed" or context.state == "testDone" then
		if context.state == "fileLoadFailed" then
			self:printText( "fileLoadFailed !!!\nmake sure the 'data/oplog.txt' exist !" )
		end
		
		if self.testUpdateScheduler then
			Director:getScheduler():unscheduleScriptEntry(self.testUpdateScheduler)
		end
		self.testContext = nil
		return
	end

	if context.state == "waiting" then

		local path = HeResPathUtils:getUserDataPath() .. "/oplog.txt"
		local hFile, err = io.open(path, "r")
		local text
		if hFile and not err then
			text = hFile:read("*a")
			io.close(hFile)
			context.originString = text
			context.jsq = 0
			context.state = "fileLoaded"
		else
			context.state = "fileLoadFailed"
		end

		return

	elseif context.state == "fileLoaded" then

		context.dataString = string.split(context.originString, '\n')
		context.state = "count"

	elseif context.state == "count" then

		context.counter = 0 

		if not context.datas then
			context.datas = {}
			context.datas_levelId = {}
			context.datas_steps = {}
		end

		local testString = ""

		while( #context.dataString > 0 and context.counter < 50 ) do
			local str = table.remove( context.dataString )
			local testTable = table.deserialize(str)

			table.insert( context.datas , testTable )

			local stepStr = table.serialize( testTable.replaySteps )
			local stepMD5 = HeMathUtils:md5(stepStr)

			if not context.datas_steps[stepMD5] then
				context.datas_steps[stepMD5] = {num=0 , level=testTable.level}
			end
			context.datas_steps[stepMD5].num = context.datas_steps[stepMD5].num + 1


			context.counter = context.counter + 1
			testString = testString .. '\n' .. "level:" .. tostring(testTable.level) .. "   md5:" .. stepMD5
		end

		

		local print_1 = "\nfind log num : " .. tostring( #context.datas ) .. "   remind:" .. tostring(#context.dataString)
		print_1 = print_1 .. "\n" .. testString
		self:printText( tostring(print_1) .. '\n' .. tostring("         --------->   running") )

		if #context.dataString == 0 --[[or context.jsq > 1000]] then
			printx( 1 , "  ============================= ReplayDataTest ======================================")
			local print_2 = ""
			printx( 1 , "   #context.datas_steps = " , #context.datas_steps)
			for k,v in pairs(context.datas_steps) do
				if v.num > 1 then
					if _G.isLocalDevelopMode then printx(0, v.num , "     " , v.level , "     " , k) end
					print_2 = print_2 .. "\ncheat level:" .. tostring(v.level) ..  "   num:" .. tostring(v.num) .. "                stepMD5:" .. k
				end
			end

			print_2 = print_2 .. "\ntotal log num : " .. tostring( #context.datas )
			self:printText( print_2 )

			context.state = "testDone"
			printx( 1 , "  =============================      Done      ======================================")
		end


	elseif context.state == "count2" then

		context.jsq = context.jsq + 1

		if not context.opStr then
			context.opStr = context.originString
		end

		if not context.datas then
			context.datas = {}
			context.datas_levelId = {}
			context.datas_steps = {}
		end
		
		local function findOneLog()
			local testIndex = string.find( context.opStr , '\n' )
			local testTable = nil
			local returnStr = nil
			if testIndex and testIndex > 0 then
				local testStr = string.sub( context.opStr ,1,testIndex )
				testTable = table.deserialize(testStr)
				returnStr = testStr
				context.opStr = string.sub( context.opStr ,testIndex + 1 )
			else
				testTable = table.deserialize(context.opStr)
				returnStr = context.opStr
				context.opStr = nil
			end
			
			return testTable , returnStr
		end

		context.counter = 0 
		local testString = ""

		--if _G.isLocalDevelopMode then printx(0,  context.opStr , context.counter ) end
		----[[
		while( context.opStr ~= nil and context.counter < 2 ) do

			local log , printStr = findOneLog()

			table.insert( context.datas , log )
			--[[
			if not context.datas_levelId[log.level] then
				context.datas_levelId[log.level] = {}
			end
			table.insert( context.datas_levelId[log.level] , log )

			if not context.datas_steps[log.replaySteps] then
				context.datas_steps[log.replaySteps] = {num=0 , level=log.level}
			end

			context.datas_steps[log.replaySteps].num = context.datas_steps[log.replaySteps].num + 1
			]]

			--printx( 1 , "  log.replaySteps = " , log.replaySteps)
			local tableStr = table.serialize( log.replaySteps )
			--printx( 1 , " tableStr = " , tableStr)
			local md5str = HeMathUtils:md5(tableStr)
			--printx( 1 , " md5str = " , md5str)
			if not context.datas_steps[md5str] then
				context.datas_steps[md5str] = {num=0 , level=log.level}
			end
			context.datas_steps[md5str].num = context.datas_steps[md5str].num + 1

			context.counter = context.counter + 1

			testString = testString .. '\n' .. "level:" .. tostring(log.level) .. "   md5:" .. md5str
		end
		--]]

		

		

		local print_1 = "find log num : " .. tostring( #context.datas )
		print_1 = print_1 .. "\n" .. testString
		self:printText( tostring(print_1) .. '\n' .. tostring("         --------->   running") )

		if context.opStr == nil --[[or context.jsq > 1000]] then
			printx( 1 , "  ============================= ReplayDataTest ======================================")
			local print_2 = ""

			for k,v in pairs(context.datas_steps) do
				if v.num > 1 then
					if _G.isLocalDevelopMode then printx(0, v.num , "     " , v.level , "     " , k) end
					print_2 = print_2 .. "\ncheat level:" .. tostring(v.level) ..  "   num:" .. tostring(v.num) .. "                stepMD5:" .. k
				end
			end

			print_2 = print_2 .. "\ntotal log num : " .. tostring( #context.datas )
			--print_2 = print_2 .. "\nlevel type num : " .. tostring( #context.datas_levelId )

			--[[
			for k,v in pairs(context.datas_steps) do
				if v.num > 1 then
					print_2 = print_2 .. "\ncheat level:" .. tostring(v.level) ..  "   num:" .. tostring(v.num)
				end
			end
			]]

			

			self:printText( print_2 )

			context.state = "testDone"
			printx( 1 , "  =============================      Done      ======================================")
		end

	end

end

function ReplayChoiceScene:printText(text)
	if self.testContext then

		self.testContext.printText:setString( text )
		if _G.isLocalDevelopMode then printx(0, text) end

		local wSize = Director:sharedDirector():getWinSize()
		local size = self.testContext.printText:getGroupBounds().size
		self.testContext.printText:setPosition( ccp( 25 , wSize.height - 200 - size.height ) )
	end
end

function ReplayChoiceScene:doTest()

	printx( 1 , "   ReplayChoiceScene:doTest")
	self.testContext = {}
	self.testContext.state = "waiting"

	if not self.testContext.printPad then
		local layer = LayerColor:create()
		local wSize = Director:sharedDirector():getWinSize()
		layer:changeWidthAndHeight(wSize.width, wSize.height - 160)
		layer:setTouchEnabled(true, 0, true)
		layer:setColor(ccc4(0,0,0,255))
		--layer:setOpacity(255)
		layer:setPosition(ccp( 0,0) )
		self:addChild(layer)

		local text = TextField:create("wating...", nil, 18)
		text:setHorizontalAlignment(kCCTextAlignmentLeft)
		text:setAnchorPoint(ccp(0, 0))
		text:setPosition( ccp( 25 , wSize.height - 200 ) )
		layer:addChild(text)
		self.testContext.printText = text
		self.testContext.printPad = layer
	end

	self:printText( "wating..." )

	--text:setString("RRR abc")

	local function _onTime(dt)
		self:__doTest(self.testContext)
	end

	if self.testUpdateScheduler then
		Director:getScheduler():unscheduleScriptEntry(self.testUpdateScheduler)
	end

	self.testUpdateScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(_onTime, 1/60 , false)
end