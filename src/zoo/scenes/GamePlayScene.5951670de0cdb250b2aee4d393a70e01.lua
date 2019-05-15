require "hecore.display.TextField"
require "zoo.config.LevelConfig"

-- require "zoo.gamePlay.GameBoardLogic"
require "zoo.gamePlay.GameBoardView"
require "zoo.gamePlay.GamePlayConfig"

GamePlayScene = class(Scene)
function GamePlayScene:ctor()
	self.backButton = nil
	self.replayButton = nil
	self.replayMode = false
	self.gamelevel = 0;
	self.forceUseDropBuff = false

	self.mygameboardlogic = nil;
	self.mygameboardview = nil;
	self.clippingnode = nil
	self.initScheduler = nil;
end
function GamePlayScene:dispose()
	--[[
	新的录像保存机制在ReplayDataManager里处理，这里不需要了
	if self.playSceneUIType == GamePlaySceneUIType.kNormal and (not isLocalDevelopMode) then
		self.mygameboardlogic:WriteReplay("test.rep")
	end
	]]
	if self.mygameboardlogic then self.mygameboardlogic:dispose() end
	if self.backButton then self.backButton:removeAllEventListeners() end
	if self.replayButton then self.replayButton:removeAllEventListeners() end
	self.backButton = nil
	self.replayButton = nil
	self.gamelevel = nil

	self.mygameboardlogic = nil;
	self.mygameboardview = nil;
	self.clippingnode = nil
	self.initScheduler = nil;

	if(self._performanceLog) then
		self._performanceLog:uploadLog()
		self._performanceLog:free()
	end

	Scene.dispose(self)
end

function GamePlayScene:create(level, playSceneUIType, levelType, forceUseDropBuff)
	local s = GamePlayScene.new()
	s.gamelevel = level
	s.playSceneUIType = playSceneUIType
	s.levelType = levelType
	s.forceUseDropBuff = forceUseDropBuff
	s:initScene()
	return s
end

function GamePlayScene:getGameBoardLogic(...)
	assert(#{...} == 0)

	return self.mygameboardlogic
end

-------初始化整个游戏---进入暂时暂停的状态
function GamePlayScene:setGameInit()
	local context = self;

	local function _updateGame(dt)
		context:_Inner_GameInit()
	end
	local time_cd = 0
	self.initScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(_updateGame, time_cd, false)
end

function GamePlayScene:_Inner_GameInit()	
	if self.mygameboardlogic then
		self.mygameboardlogic.isWaitingOperation = false;
	end
	if self.mygameboardview then
		self.mygameboardview.isPaused = true;
	end
	Director:getScheduler():unscheduleScriptEntry(self.initScheduler)
end

function GamePlayScene:setGameStop()
	if self.mygameboardview then
		self.mygameboardview.isPaused = true;
		self.mygameboardlogic:onWaitingOperationChanged()
	end
end

function GamePlayScene:setGameRemuse()
	if self.mygameboardview then
		self.mygameboardview.isPaused = false;
		self.mygameboardlogic:onWaitingOperationChanged()
	end
end


function GamePlayScene:onInit()
end
