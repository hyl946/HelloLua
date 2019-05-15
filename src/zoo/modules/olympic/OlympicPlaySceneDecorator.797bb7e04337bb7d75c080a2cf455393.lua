---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-08-02 10:48:54
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-08-08 16:23:19
---------------------------------------------------------------------------------------
require "zoo.modules.olympic.OlympicPlaySceneTopNode"

OlympicPlaySceneDecorator = class()

function OlympicPlaySceneDecorator:decoPlayScene(gamePlayScene)
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
		-- local nPosY = bossLayer:convertToNodeSpace(ccp(0, topNodePosY)).y
		local topNode = OlympicPlaySceneTopNode:create(gamePlayScene, topNodePosY)
		-- bossLayer:addChild(topNode)

		-- local topSize = topNode:getContentSize()
		-- local minY = visibleOrigin.y + visibleSize.height - topSize.height
		-- topNode:setPosition(ccp(0, topNodePosY))

		local mainLogic = gamePlayScene.gameBoardLogic

		local frontAnimalGlobalPosX = gameBoardView:convertToWorldSpace(ccp(90, 0)).x -- 105 - 15
		local followAnimalGlobalPosX = gameBoardView:convertToWorldSpace(ccp(35, 0)).x
		topNode:initAnimals(mainLogic.frontAnimalId or 1, frontAnimalGlobalPosX, followAnimalGlobalPosX)

		gamePlayScene.olympicTopNode = topNode
	end

	local boardBg = Sprite:createWithSpriteFrameName("olympic_board_bg")
	if boardBg then
		boardBg:setScale(0.985)
		boardBg:setAnchorPoint(ccp(0, 1))
		boardBg:ignoreAnchorPointForPosition(false)
		boardBg:setPosition(ccp(44, 580))
		gameBoardView:addChildAt(boardBg, -1)
	end
end