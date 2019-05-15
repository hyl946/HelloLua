---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2017-09-05 20:10:15
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2017-09-11 18:07:45
---------------------------------------------------------------------------------------
NationDay2017PlaySceneDecorator = class()

function NationDay2017PlaySceneDecorator:buildTopAnimations()
	local container = CocosObject.new(CCNode:create())

	local chickenMother = NationDay2017Ufo:create()
	if __isWildScreen then
		chickenMother:setPosition(ccp(0, 280))
	else
		chickenMother:setPosition(ccp(0, 250))
	end
	container:addChildAt(chickenMother, 2)
	container.chickenMother = chickenMother

	return container
end

function NationDay2017PlaySceneDecorator:decoPlayScene(gamePlayScene)
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
		local topAnimations = NationDay2017PlaySceneDecorator:buildTopAnimations()
		bossLowerLayer:addChild(topAnimations)

		topAnimations:setScale(scale)

		local posY = visibleOrigin.y + visibleSize.height - 400 * scale

		topAnimations:setPosition(ccp(visibleOrigin.x + visibleSize.width / 2, posY))

		gamePlayScene.topAnimationsNode = topAnimations
	end
end