---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-12-26 17:53:22
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2017-09-05 20:09:37
---------------------------------------------------------------------------------------
require "zoo.modules.spring2017.SpringAnimations"

SpringPlaySceneDecorator = class()

function SpringPlaySceneDecorator:buildTopAnimations()
	local container = CocosObject.new(CCNode:create())

	-- local ll = LayerColor:createWithColor(ccc3(255, 0, 0), 720, 10)
	-- ll:setPosition(ccp(-360, -5))
	-- container:addChild(ll)

	local chickenMother = SpringAnimations:createChickenMother()
	chickenMother:setPosition(ccp(246-360, 210))
	container:addChildAt(chickenMother, 2)
	container.chickenMother = chickenMother

	chickenMother:setCollectPercent(0)

	return container
end

local chickenPos = {{x=115-360, y=140}, {x=365-360, y=345}, {x=620-360, y=80}}
function SpringPlaySceneDecorator:addChicken(gamePlayScene, id)
	local container = gamePlayScene.topAnimationsNode
	if container and id and chickenPos[id] then
		local chicken = SpringAnimations:createChicken(id)
		if id == 3 then
			chicken:setScaleX(-1)
		end
		local pos = chickenPos[id]
		chicken:setPosition(ccp(pos.x, pos.y))
		container:addChildAt(chicken, 1)
	end
end

function SpringPlaySceneDecorator:decoPlayScene(gamePlayScene)
	-- InterfaceBuilder:preloadAsset("flash/spring2017/in_game.json")

	local winSize 	= CCDirector:sharedDirector():getWinSize()
	local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()

	local gameBoardView = gamePlayScene.gameBoardView

	local scale = 1
	if __isWildScreen then
		scale = math.max(visibleSize.width/960, visibleSize.height/1280)

		local gameBgNode = gamePlayScene.gameBgNode
		if gameBgNode then
			gameBgNode:setAnchorPoint(ccp(0.5, 1))
			gameBgNode:setScale(scale)
			gameBgNode:setPosition(ccp(visibleOrigin.x + visibleSize.width / 2, visibleOrigin.y + visibleSize.height))
		end
	end

	local bossLowerLayer = gamePlayScene.bossLowerLayer
	if bossLowerLayer then
		local topAnimations = SpringPlaySceneDecorator:buildTopAnimations()
		bossLowerLayer:addChild(topAnimations)

		topAnimations:setScale(scale)

		local posY = visibleOrigin.y + visibleSize.height - 400 * scale

		topAnimations:setPosition(ccp(visibleOrigin.x + visibleSize.width / 2, posY))

		gamePlayScene.topAnimationsNode = topAnimations

		-- gamePlayScene.addSpringChickenById = function(self, id)
		-- 	SpringPlaySceneDecorator:addChicken(self, id)
		-- end

		-- SpringPlaySceneDecorator:addChicken(gamePlayScene, 1)
		-- SpringPlaySceneDecorator:addChicken(gamePlayScene, 2)
		-- SpringPlaySceneDecorator:addChicken(gamePlayScene, 3)
	end

	-- local bg = Sprite:createWithSpriteFrameName("spring2017_ingame/spring_board_bg0000")
	-- bg:setPosition(ccp(349, 245))
	-- gameBoardView:addChildAt(bg, -1)
end