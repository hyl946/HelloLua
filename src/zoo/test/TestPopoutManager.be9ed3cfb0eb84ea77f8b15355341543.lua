
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月 6日 17:46:14
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com


---------------------------------------------------
-------------- TestScene
---------------------------------------------------


require "hecore.display.Director"
require "hecore.display.TextField"


require "hecore.ui.PopoutManager"



assert(not TestScene)
assert(Scene)
TestScene = class(Scene)

function TestScene:init(...)
	assert(#{...} == 0)

	---
	Scene.initScene(self)




	-- Test Label
	local startLabel = TextField:create("Start" , Helvetica, 40)
	local labelWrapper = Layer:create()
	labelWrapper:addChild(startLabel)

	labelWrapper:setPosition(ccp(100, 500))
	self:addChild(labelWrapper)
	labelWrapper:setTouchEnabled(true)



	local function onLabelTapped()

		local color = LayerColor:create()
		color:setColor(ccc3(255, 0, 0))
		color:changeWidthAndHeight(400, 400)

		color:setPositionY(-400)

		--self:addChild(color)

		assert(PopoutManager:sharedInstance():add(color, true, false))
	end

	labelWrapper:addEventListener(DisplayEvents.kTouchTap, onLabelTapped)

	--self:addChild(color)
	--local colorParent = color:getParent()
	--local colorPos	= color:getPosition()
	--local posInWorldPos = colorParent:convertToWorldSpace(ccp(colorPos.x, colorPos.y))

	--if _G.isLocalDevelopMode then printx(0, "in world pos x: " .. posInWorldPos.x) end
	--if _G.isLocalDevelopMode then printx(0, "in world pos y: " .. posInWorldPos.y) end
end

function TestScene:create(...)
	assert(#{...} == 0)

	local newTestScene = TestScene.new()
	newTestScene:init()
	return newTestScene
end

local testScene = TestScene:create()
Director:sharedDirector():runWithScene(testScene)


