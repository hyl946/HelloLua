--mitalk sdk下线提示
MiTalkRemovePopoutAction = class(HomeScenePopoutAction)

function MiTalkRemovePopoutAction:ctor()
end

function MiTalkRemovePopoutAction:popout()
	local MiTalkRemoveManager = require 'zoo.panel.mitalkremove.MiTalkRemoveManager'
	local popoutType, isPop = MiTalkRemoveManager:getPopoutType()
	if isPop then 
		MiTalkRemoveManager:popout(popoutType, isPop, function( ... )
			self:next()
		end)
	else
		self:placeholder()
		self:next()
	end
end

function MiTalkRemovePopoutAction:getConditions()
    return {"enter","enterForground"}
end