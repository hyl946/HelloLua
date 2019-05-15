require "zoo.ui.halo.haloCore.HaloBaseView"
require "zoo.ui.halo.haloCore.HaloBaseMod"
require "zoo.ui.halo.mods.HaloInteractionMod"


local function createTestBtn( pos, name )
	-- body
	local root = HaloBaseView:create()
	root:setName(name)
	Director:sharedDirector():run():addChild(root)
	local sp = Sprite:createWithSpriteFrameName('ui_scale9/ui_yellow_green_scale90000')
	root:addChild(sp)
	sp:setScale(2)
	root:setPositionX(pos.x)
	root:setPositionY(pos.y)

	local m = HaloInteractionMod:create()
	root:addMod(m)

	m:watch(HaloTouchEvent.TAP, function ( ... )
		printx(61, 'tap ', root:getName())
		root:removeFromParentAndCleanup(false)
		Director:sharedDirector():run():addChild(root)
	end)
end

createTestBtn(ccp(200, 200), 'button1')
createTestBtn(ccp(200, 400), 'button2')
createTestBtn(ccp(200, 600), 'button3')