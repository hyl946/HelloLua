require "zoo.gameTools.GameMapSnapshot"

GameToolsScene = class(Scene)

function GameToolsScene:create()
	local scene = GameToolsScene.new()
	scene:initScene()
	return scene
end

function GameToolsScene:onInit()
	local origin = Director:sharedDirector():getVisibleOrigin()
	local size = Director:sharedDirector():getVisibleSize()
	-- set bg
	local bg = LayerColor:createWithColor(ccc3(255, 255, 255), size.width, size.height)
	bg:setPosition(ccp(origin.x, origin.y))
	self:addChild(bg)
	-- add back button
	local backBtn = LayerColor:createWithColor(hex2ccc3("00BFFF"), 120, 60)
	backBtn:setPosition(ccp(origin.x + 30, origin.y + size.height - 80))
	backBtn:setTouchEnabled(true)
	backBtn:ad(DisplayEvents.kTouchTap, function() self:onBackButtonTapped() end)
	self:addChild(backBtn)
	local backLabel = TextField:create("<BACK" , "Helvetica", 32)
	backLabel:setPosition(ccp(60, 30))
	backLabel:setColor(ccc3(250, 250, 250))
	backBtn:addChild(backLabel)


	local gameMapSnapshotTool = GameMapSnapshotTool:create()
	local contentSize = gameMapSnapshotTool:getContentSize()
	gameMapSnapshotTool:setPosition(ccp(origin.x + size.width / 2 - contentSize.width / 2, origin.y + size.height - 150))
	self:addChild(gameMapSnapshotTool)
end

function GameToolsScene:onBackButtonTapped()
	Director:sharedDirector():popScene()
end
