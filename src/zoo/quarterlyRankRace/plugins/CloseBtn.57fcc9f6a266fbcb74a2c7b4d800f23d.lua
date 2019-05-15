require 'zoo.quarterlyRankRace.plugins.BasePlugin'

local CloseBtn = class(BasePlugin)

function CloseBtn:onPluginInit( ... )

	if not BasePlugin.onPluginInit(self, ...) then return false end

	UIUtils:setTouchHandler(self, function ( ... )
		self:callAncestors('onCloseBtnTapped')
	end)

	return true
end

return CloseBtn