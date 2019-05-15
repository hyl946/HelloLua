require "hecore.display.TextField"

require "zoo.scenes.GamePlayScene"
require "zoo.config.LevelConfig"
require "zoo.data.DevTestLevelMapManager"
require "zoo.scenes.DevTestGamePlayScene"

local isTestMode = true

GameChoiceScene = class(Scene)
function GameChoiceScene:ctor()
	self.backButton = nil
end
function GameChoiceScene:dispose()
	if self.backButton then self.backButton:removeAllEventListeners() end
	self.backButton = nil
	
	Scene.dispose(self)
end

function GameChoiceScene:create()
	local s = GameChoiceScene.new()
	s:initScene()
	return s
end

function GameChoiceScene:onInit()
	-- local winSize = CCDirector:sharedDirector():getWinSize()

	-- local function onTouchBackLabel(evt)
	-- 	Director:sharedDirector():popScene()
	-- 	Scene.dispose(self.devTestGPS)
	-- end

	-- local function buildLabelButton( label, x, y, func)
	-- 	local width = 250
	-- 	local height = 80
	-- 	local labelLayer = LayerColor:create()
	-- 	labelLayer:changeWidthAndHeight(width, height)
	-- 	labelLayer:setColor(ccc3(255, 0, 0))
	-- 	labelLayer:setPosition(ccp(x - width / 2, y - height / 2))
	-- 	labelLayer:setTouchEnabled(true, p, true)
	-- 	labelLayer:addEventListener(DisplayEvents.kTouchTap, func)
	-- 	self:addChild(labelLayer)

	-- 	local textLabel = TextField:create(label.."", nil, 32)
	-- 	textLabel:setPosition(ccp(width/2, height/4))
	-- 	textLabel:setAnchorPoint(ccp(0,0))
	-- 	labelLayer:addChild(textLabel)

	-- 	return labelLayer
	-- end 
	-- self.backButton = buildLabelButton("Back", 0, winSize.height-60, onTouchBackLabel)


	-- local function onTouchGamePlayLabel(evt)--点击开始游戏Label--->进入gameScene		
 --        local target = evt.target
 --        local levelId = target:getTag()
 --        local scene = GamePlayScene:create(levelId)
	-- 	Director:sharedDirector():pushScene(scene)
	-- 	scene.backButton:setVisible(true)
	-- 	scene.replayButton:setVisible(true)
	-- end

	-- local function buildLayerButton( label, x, y, func, tag)
	-- 	local width = 80
	-- 	local height = 40
	-- 	local labelLayer = LayerColor:create()
	-- 	labelLayer:changeWidthAndHeight(width, height)
	-- 	labelLayer:setColor(ccc3(255, 20, 0))
	-- 	labelLayer:setOpacity(50)
	-- 	labelLayer:setPosition(ccp(x - width / 2, y - height / 2))
	-- 	labelLayer:setTouchEnabled(true, p, true)
	-- 	labelLayer:addEventListener(DisplayEvents.kTouchTap, func)
	-- 	labelLayer:setTag(tag)
	-- 	self:addChild(labelLayer)

	-- 	local textLabel = TextField:create(label.."", nil, 28, CCSizeMake(width,height), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	-- 	textLabel:setAnchorPoint(ccp(0,0))
	-- 	labelLayer:addChild(textLabel)

	-- 	return labelLayer
	-- end 

	-- if isTestMode then
	-- 	local winSize = CCDirector:sharedDirector():getWinSize()
	-- 	local levels = LevelDataManager.sharedLevelData():getAllLevels()---获取可以提供的关卡的编号列表
	-- 	local len = #levels;
	-- 	local counts = 8
	-- 	local textWidth = math.floor(winSize.width / counts);	--一排的数量是8  所以宽度是textWidth
	-- 	local textHeight = math.floor(textWidth / 2); 			--每个label的高度

	-- 	for k,v in ipairs(levels) do
	-- 		local x = textWidth * (math.fmod(k - 1, counts) + 0.5)
	-- 		local y = textHeight * (math.floor((k - 1)/ counts) + 0.5)
	-- 		local gamePlayLabel = buildLayerButton(v, x, winSize.height - 130 - y, onTouchGamePlayLabel, v)
	-- 		gamePlayLabel:addEventListener(DisplayEvents.kTouchTap, onTouchGamePlayLabel)---注册点击事件
	-- 		self:addChild(gamePlayLabel)
	-- 	end
	-- end

	self:initDevTestLevel()
end

local testLevelId = nil
function GameChoiceScene:initDevTestLevel()
	local testConfStr = DevTestLevelMapManager.getInstance():getConfig("test1.json")

	local testConf = table.deserialize(testConfStr)
	local levelType = LevelType:getLevelTypeByLevelId(testConf.totalLevel) or GameLevelType.kMainLevel

	-- if not testLevelId then 
	-- 	testLevelId = LevelMapManager:getInstance():getMaxLevelId() + 1
	-- end
	-- testConf.totalLevel = testLevelId
	
	LevelMapManager:getInstance():addDevMeta(testConf)

	local levelMeta = LevelMapManager.getInstance():getMeta(testConf.totalLevel)
	local levelConfig = LevelConfig:create(testConf.totalLevel, levelMeta)
	LevelDataManager.sharedLevelData().levelDatas[testConf.totalLevel] = levelConfig

    local fileList = levelConfig:getDependingSpecialAssetsList(levelType)
    
    local loader = FrameLoader.new()
    local function onFrameLoadComplete( evt )
        loader:removeAllEventListeners()

        local function pushNewScene()
	        local devTestGPS = DevTestGamePlayScene:create(levelConfig, {})
			self.devTestGPS = devTestGPS
			devTestGPS.fileList = fileList
			self:addChild(devTestGPS)
        end
        
		AsyncLoader:getInstance():waitingForLoadComplete(pushNewScene)
    end 
   
    for i,v in ipairs(fileList) do loader:add(v, kFrameLoaderType.plist) end
    loader:addEventListener(Events.kComplete, onFrameLoadComplete)
    loader:load()

end