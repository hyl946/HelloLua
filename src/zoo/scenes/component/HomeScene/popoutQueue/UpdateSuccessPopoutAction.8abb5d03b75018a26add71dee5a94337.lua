
local UpdateMainPanel = require 'zoo.panel.UpdateMainPanel'

UpdateSuccessPopoutAction = class(HomeScenePopoutAction)

function UpdateSuccessPopoutAction:ctor( ... )
	self.name = "UpdateSuccessPopoutAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kSceneEnter)
end

function UpdateSuccessPopoutAction:checkCanPop()
--	if self.debug then
--		UserManager.getInstance().updateRewards = {{itemId = 10003, num = 8}}
--	end
    self:onCheckPopResult(UpdateMainPanel:canPopout() or self.debug)
end

function UpdateSuccessPopoutAction:popout( next_action )
	if UpdateMainPanel:canPopout() or self.debug then
		local panel = UpdateMainPanel:create( next_action )
		if panel then
			panel:popout()
		end
	else
		next_action()
	end
end