require "zoo.ui.halo.haloCore.HaloBaseView"
require "zoo.ui.halo.buttons.HaloButton"
require "zoo.ui.halo.haloCore.HaloBaseMod"
require "zoo.ui.halo.mods.HaloInteractionMod"


local function createTestBtn( pos, name )
	local a = HaloButton:create()
	a:setName(name)
	a:setPosition(pos)
	Director:sharedDirector():run():addChild(a)
end

createTestBtn(ccp(200, 200), 'test-a')