local FTWUI = require 'zoo.localActivity.FindingTheWay.FindingTheWayUI'
local FTWLocalLogic = require 'zoo.localActivity.FindingTheWay.FindingTheWayLocalLogic'

local FindingTheWayGamePlaySceneDecorator = {}

local PAD_OFFSET_X = 100
local PAD_OFFSET_Y = -50

function FindingTheWayGamePlaySceneDecorator:decoPlayScene(gamePlaySceneUI)

	local anim

	if FTWLocalLogic:getMode() == FTWLocalLogic.MODE.kAddStarMode then
		anim = FTWUI:createAddStarUI()
		anim.name = 'FTWAddStarAnim'
	elseif FTWLocalLogic:getMode() == FTWLocalLogic.MODE.kFullStarMode then
		anim = FTWUI:createAddLevelUI(gamePlaySceneUI.levelId)
		anim.name = 'FTWAddLevelAnim'
	end



	local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()

	local gameBoardView = gamePlaySceneUI.gameBoardView

	local posY = (10 - gameBoardView.startRowIndex) * 70
	local posX = (10 - gameBoardView.startColIndex) * 70
	local gPos = gameBoardView:convertToWorldSpace(ccp(posX, posY))



	if anim then
		anim:playByIndex(0, 1)
		anim:update(0.01)
		anim:stop()
		anim:update()
		gamePlaySceneUI.otherElementsLayer:addChild(anim)

		-- if visibleSize.height / visibleSize.width >= 800 / 480 then
			local bounds = anim:getGroupBounds()
			local animWidth = bounds.size.width
			local animHeight = bounds.size.height

			local minX = gamePlaySceneUI.otherElementsLayer:convertToNodeSpace(gPos).x + animWidth/2
			local posX = visibleOrigin.x + visibleSize.width - anim:getGroupBounds().size.width/2 - 5

			if posX > minX then
				anim:setPositionX(posX)
				anim:setPositionY(gamePlaySceneUI.otherElementsLayer:convertToNodeSpace(gPos).y + 20)
			else
				anim:setPositionX(posX)
				anim:setPositionY(gamePlaySceneUI.otherElementsLayer:convertToNodeSpace(gPos).y + 20)
			end

			anim.hide_pos = ccp(anim:getPositionX(), anim:getPositionY())
			anim.show_pos = ccp(anim:getPositionX(), anim:getPositionY())
		-- else
			-- anim:setPositionX(visibleOrigin.x + visibleSize.width - anim:getGroupBounds().size.width/2 - 5)
			-- anim:setPositionY(gamePlaySceneUI.otherElementsLayer:convertToNodeSpace(gPos).y - 15)
		-- end

		if visibleSize.height / visibleSize.width <= 1100 / 768 then
			anim:setPositionY(anim:getPositionY() + PAD_OFFSET_Y)
			anim:setPositionX(anim:getPositionX() + PAD_OFFSET_X)
			anim.hide_pos = ccp(anim:getPositionX(), anim:getPositionY())
			anim.show_pos = ccp(anim:getPositionX() - PAD_OFFSET_X, anim:getPositionY())
		end

		function anim:playInitShow( ... )
			if self.isDisposed then return end
			self:show(

				TimerUtil.addAlarm(function ( ... )
					if self.isDisposed then return end
					self:hide()
				end, 2, 1)
			)
		end

	end



end

return FindingTheWayGamePlaySceneDecorator