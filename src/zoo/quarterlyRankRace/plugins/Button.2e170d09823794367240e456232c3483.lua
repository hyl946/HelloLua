require 'zoo.quarterlyRankRace.plugins.BasePlugin'

local Button = class(BasePlugin)

function Button:onPluginInit( ... )

	if not BasePlugin.onPluginInit(self, ...) then return false end

	self.bEnabled = true

	self:setCDTime(1)

	return true
end

function Button:setEnabled( bEnabled )
	self.bEnabled = bEnabled
end

function Button:setCDTime( cdTime )
	if self.isDisposed then return end
	UIUtils:setTouchHandler(self, function ( ... )
		if self.bEnabled then
			self:callAncestors('onButtonTap', self.name)
		end
	end, nil, cdTime)
end

return Button