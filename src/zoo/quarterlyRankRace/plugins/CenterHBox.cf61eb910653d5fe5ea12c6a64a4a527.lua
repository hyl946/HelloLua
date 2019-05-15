
local HBox = require 'zoo.quarterlyRankRace.plugins.HBox'

local CenterHBox = class(HBox)

function CenterHBox:onPluginInit( ... )

	if not HBox.onPluginInit(self, ...) then return false end

	self.layout:setAlignment(HorizontalAlignments.kCenter)
	
	return true
end

return CenterHBox