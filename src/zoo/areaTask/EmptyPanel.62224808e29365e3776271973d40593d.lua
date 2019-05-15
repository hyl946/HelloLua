
local UIHelper = require 'zoo.panel.UIHelper'

local EmptyPanel = class(BasePanel)

function EmptyPanel:create(callback)
    local panel = EmptyPanel.new()
    panel:init(callback)
    return panel
end

function EmptyPanel:init(callback)
    local ui = Layer:create()
	BasePanel.init(self, ui)
	self.callback = callback
end

function EmptyPanel:_close()
	PopoutManager:sharedInstance():remove(self)
end

function EmptyPanel:popout()
	PopoutQueue:sharedInstance():push(self, false)
end

function EmptyPanel:popoutShowTransition( ... )
	if self.callback then
		self.callback(self)
	end
end

return EmptyPanel