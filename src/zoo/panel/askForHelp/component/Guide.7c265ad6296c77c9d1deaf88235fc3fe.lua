local ASFGuide = class()

function ASFGuide:create(messageButton, guidePanelName, callback)
	local inst = ASFGuide.new()
	return inst:init(messageButton, guidePanelName, callback)
end

function ASFGuide:init(messageButton, guidePanelName, callback)
    self.messageButton = messageButton

	local tPos = self.messageButton:getPosition()

	local layer = nil
	local function tryRemoveGuide()
		callback(true)
	end
    local panel = GameGuideUI:panelS(nil, {panelName = guidePanelName, align = 'winYU'}, true)
    panel:setPosition(ccp(tPos.x - 70, tPos.y-200))

    local trueMask = GameGuideUI:mask(204, 1, ccp(0, 0), 0, false, nil, nil, false)
    trueMask:setFadeIn(0.5, 0.3)

    layer = Layer:create()
    layer:addChild(trueMask)
    layer:addChild(panel)

    local context = self
	function layer:hitTestPoint(worldPosition, useGroupTest)
		if not context.messageButton then 
			tryRemoveGuide()
			return false
		end
        if context.messageButton:hitTestPoint(worldPosition, useGroupTest) then
            tryRemoveGuide()
			return false
		end
		return true
	end

	layer:setTouchEnabled(true, -1, true)
	layer:addEventListener(DisplayEvents.kTouchTap, function () tryRemoveGuide() end)

    return layer
end

return ASFGuide