local AchiCenterScene = class(Scene)
local achiPanel
function AchiCenterScene:create()
	local s = AchiCenterScene.new()
	s:initScene()
	return s
end

function AchiCenterScene:onKeyBackClicked()
	Director:sharedDirector():popScene()
end

function AchiCenterScene:createAchiPanel(tabIndex, showGuide)
	if not achiPanel or achiPanel.isDisposed then 
	    local scene = AchiCenterScene:create(pageName)
	    Director:sharedDirector():pushScene(scene)

	    achiPanel = require('zoo.PersonalCenter.achi.panel.AchiPanel'):create(tabIndex, showGuide)
	    achiPanel:popout()
	end
end

function AchiCenterScene:createAchiRankPanel()
    
end

function AchiCenterScene:createAchiExplainPanel()
    
end

return AchiCenterScene