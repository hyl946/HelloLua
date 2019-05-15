require "zoo.ui.halo.haloCore.HaloBaseView"

HaloButton = class(HaloBaseView)

function HaloButton:ctor()

end

function HaloButton:create( haloButtonCreateData )
	local button = HaloButton.new()
	button:init(haloButtonCreateData or HaloButton:getDefaultCreateData())
	return button
end

function HaloButton:getDefaultCreateData( ... )
	return {

	}
end

function HaloButton:build( data )
	if self.data then
		--deInint
		self.testView:removeFromParentAndCleanup(true)
		self.testView = nil

		self.data = nil
	end

	self.testView = LayerColor:create()
	self.testView:setContentSize(CCSizeMake(200, 100))
	self.testView:setColor(hex2ccc3(255, 0, 0))
	self:addChild(self.testView)

	self.data = data


	-- just do once
	if not self._initMods then
		self._initMods = true
		self:addModByClass('zoo.ui.halo.mods.HaloInteractionMod', HaloInteractionMod:getDefaultCreateData())
	end
end