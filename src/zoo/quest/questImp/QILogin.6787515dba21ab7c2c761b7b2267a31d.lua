local Quest = require 'zoo.quest.Quest'


local QILogin = class(Quest)

function QILogin:_isFinished( ... )
	return true
end

function QILogin:registerAllListener( ... )
end

function QILogin:createIcon( ... )
	local UIHelper = require 'zoo.panel.UIHelper'
	local icon = UIHelper:createSpriteFrame('flash/quest-icon.json', 'quest-icon-dir/70000')
	icon:setScale(0.8)
	return icon
end


return QILogin