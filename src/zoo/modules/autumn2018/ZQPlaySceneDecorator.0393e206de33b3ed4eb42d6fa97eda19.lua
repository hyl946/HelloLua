
require "zoo.modules.autumn2018.ZQPlaySceneTopNode"

ZQPlaySceneDecorator = class()

function ZQPlaySceneDecorator:decoPlayScene(gamePlayScene)
	local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local gameBg = gamePlayScene.gameBgNode
	local gameBoardView = gamePlayScene.gameBoardView
	local posY = (10 - gameBoardView.startRowIndex) * 70
	local gPos = gameBoardView:convertToWorldSpace(ccp(0, posY))

	local topNodePosY = gPos.y
	if gameBg and gameBg.updateGameBgPosition then
		local finalPos = gameBg:updateGameBgPosition(gPos)
		topNodePosY = finalPos.y
	end

	local bossLayer = gamePlayScene.bossLayer
	if bossLayer then
		local topNode = ZQPlaySceneTopNode:create(gamePlayScene, topNodePosY)
		local mainLogic = gamePlayScene.gameBoardLogic

		local frontAnimalGlobalPosX = gameBoardView:convertToWorldSpace(ccp(90, 0)).x -- 105 - 15
		local followAnimalGlobalPosX = gameBoardView:convertToWorldSpace(ccp(35, 0)).x
		topNode:initAnimals(mainLogic.frontAnimalId or 1, frontAnimalGlobalPosX, followAnimalGlobalPosX)

		gamePlayScene.olympicTopNode = topNode
	end

	local grassBgSp = Sprite:createWithSpriteFrameName("autumn_ingame_bg6")
	if grassBgSp then 
		local pos = gameBoardView:convertToNodeSpace(ccp(visibleOrigin.x, 0))
		grassBgSp:setAnchorPoint(ccp(0, 0))
		grassBgSp:ignoreAnchorPointForPosition(false)
		grassBgSp:setPosition(ccp(pos.x, 556))
		gameBoardView:addChildAt(grassBgSp, -1)
	end
end