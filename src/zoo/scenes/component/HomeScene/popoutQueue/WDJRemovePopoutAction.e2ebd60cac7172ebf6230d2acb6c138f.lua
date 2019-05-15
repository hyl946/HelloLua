--豌豆荚sdk下线提示
WDJRemovePopoutAction = class(HomeScenePopoutAction)

function WDJRemovePopoutAction:ctor()
end

function WDJRemovePopoutAction:popout()
	local WDJRemoveManager = require 'zoo.panel.wdjremove.WDJRemoveManager'
	local popoutType, isPop = WDJRemoveManager:getPopoutType()
	if isPop then 
		WDJRemoveManager:popout(popoutType, isPop, function( ... )
			self:next()
		end)
	else
		self:placeholder()
		self:next()
	end
end

function WDJRemovePopoutAction:getConditions()
    return {"enter","enterForground"}
end