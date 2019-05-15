
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月 6日 17:46:14
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com


---------------------------------------------------
-------------- TestScene
---------------------------------------------------


require "hecore.display.Director"
require "hecore.display.TextField"


require "zoo.ResourceManager"


assert(not TestScene)
assert(Scene)
TestScene = class(Scene)

function TestScene:ctor()
end

function TestScene:init(...)
	assert(#{...} == 0)

	Scene.initScene(self)

	ResourceManager:sharedInstance():addJsonFile("flash/panels/panel-true-ui.json")

	local testUI = ResourceManager:sharedInstance():buildGroup("startGamePanel/levelInfoPanel")
	assert(testUI)

	testUI:setPosition(ccp(0, 600))

	self:addChild(testUI)

	--if _G.isLocalDevelopMode then printx(0, "self.className :" .. self.className) end
	--testUI:setOpacity(30)
end

function TestScene:create(...)
	assert(#{...} == 0)

	local newTestScene = TestScene.new()
	newTestScene:init()
	return newTestScene
end

local testScene = TestScene:create()
Director:sharedDirector():runWithScene(testScene)
