
---------------------------------------------------
-------------- TestScene
---------------------------------------------------

require "hecore.display.Director"
require "hecore.display.TextField"

require "zoo.ResourceManager"

assert(not TestScene)
assert(Scene)
TestScene = class(Scene)

function TestScene:init(...)
	assert(#{...} == 0)

	Scene.initScene(self)

	ResourceManager:sharedInstance():addJsonFile("flash/common/properties.json")


	local sprite255 = ResourceManager:sharedInstance():buildSprite("Prop_10018")
	local sprite100 = ResourceManager:sharedInstance():buildSprite("Prop_10018")
	local sprite50 = ResourceManager:sharedInstance():buildSprite("Prop_10018")

	sprite255:setOpacity(255)
	sprite100:setOpacity(100)
	sprite50:setOpacity(50)

	self:addChild(sprite255)
	self:addChild(sprite100)
	self:addChild(sprite50)

	sprite255:setPosition(ccp(100, 600))
	sprite100:setPosition(ccp(200, 600))
	sprite50:setPosition(ccp(300, 600))
	

	local rootSprite = ResourceManager:sharedInstance():buildSprite("Prop_10018")
	local childSprite = ResourceManager:sharedInstance():buildSprite("Prop_10018")
	local grandChild = ResourceManager:sharedInstance():buildSprite("Prop_10018")

	rootSprite:addChild(childSprite)
	childSprite:addChild(grandChild)

	rootSprite:setCascadeOpacityEnabled(true)
	childSprite:setCascadeOpacityEnabled(true)
	grandChild:setCascadeOpacityEnabled(true)
	rootSprite:setOpacity(100)
	childSprite:setOpacity(100)
	grandChild:setOpacity(100)

	self:addChild(rootSprite)

	rootSprite:setPosition(ccp(200,400))
end

function TestScene:create(...)
	assert(#{...} == 0)

	local newTestScene = TestScene.new()
	newTestScene:init()
	return newTestScene
end

local testScene = TestScene:create()
Director:sharedDirector():runWithScene(testScene)
