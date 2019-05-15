
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月 6日 17:46:14
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- TestScene
---------------------------------------------------

require "hecore.display.Director"
require "hecore.display.TextField"

assert(not TestScene)
assert(Scene)
TestScene = class(Scene)

function TestScene:ctor()
end

function TestScene:init(...)
	assert(#{...} == 0)

	Scene.initScene(self)

	local layer = Layer:create()
	self:addChild(layer)
	local monospace = BitmapText:create("", "fnt/5_more_cd.fnt", -1, kCCTextAlignmentCenter)--LabelBMMonospaceFont:create(50, 50, 20, "fnt/5_more_cd.fnt")
	--monospace:setAnchorPoint(ccp(0,1))
	monospace:setPreferredSize(100,100)

	monospace:setString("8")
	layer:addChild(monospace)
	monospace:setPosition(ccp(200,200))



	local function callbackFunc()
		local string = "" .. math.floor(math.random() * 10)
		if _G.isLocalDevelopMode then printx(0, "begin", string) end

		layer:removeChildren(true)
		local monospace = BitmapText:create("", "fnt/5_more_cd.fnt", -1, kCCTextAlignmentCenter)
		monospace:setPreferredSize(100,100)
		monospace:setPosition(ccp(200,200))
		monospace:setString(string)
		layer:addChild(monospace)
		if _G.isLocalDevelopMode then printx(0, "end", string) end
	end
	
	local delay = CCDelayTime:create(1)
	local callbackAction = CCCallFunc:create(callbackFunc)
	local seq = CCSequence:createWithTwoActions(delay, callbackAction)
	local repeate = CCRepeat:create(seq, 12)
	layer:runAction(repeate)
end

function TestScene:create(...)
	assert(#{...} == 0)

	local newTestScene = TestScene.new()
	newTestScene:init()
	return newTestScene
end

local testScene = TestScene:create()
Director:sharedDirector():runWithScene(testScene)
