
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月19日 16:10:00
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

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

	-- -----------------------
	-- Test True Cpp Class
	-- ------------------------

	--local bmFontBatch = LabelBMFontBatch:create("fnt/level_seq_n_energy_cd.png",
	--					"fnt/level_seq_n_energy_cd.fnt",
	--					100)
	--for index = 1,10 do
	--	local posX = 200
	--	local posY = index * 100
	--	local label = bmFontBatch:createLabel("123")
	--	label:setPosition(ccp(posX, posY))
	--	bmFontBatch:addChild(label)
	--end

	--local bmFontBatchCocosObject = CocosObject.new(bmFontBatch)
	--self:addChild(bmFontBatchCocosObject)


	-------------------------
	-- Test Lua Wrapping
	-- -----------------------

	local labelBatch = BMFontLabelBatch:create("fnt/level_seq_n_energy_cd.png",
							"fnt/level_seq_n_energy_cd.fnt",
							100)

	for index = 1,10 do

		local posX = 200
		local posY = index * 100
		local label = labelBatch:createLabel("123")
		assert(label)
		assert(label.refCocosObj)
		label:setPosition(ccp(posX, posY))

		--self:addChild(label)
		labelBatch:addChild(label)

		local fadeOut = CCFadeOut:create(2)
		label:runAction(fadeOut)

		-- ??
		--local pos = label.refCocosObj:getPosition()
	end

	self:addChild(labelBatch)
end

function TestScene:create(...)
	assert(#{...} == 0)

	local newTestScene = TestScene.new()
	newTestScene:init()
	return newTestScene
end

local testScene = TestScene:create()
Director:sharedDirector():runWithScene(testScene)
