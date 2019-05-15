--[[
 * XFShareAction
 * @date    2018-08-08 15:26:41
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

XFShareAction = class(HomeScenePopoutAction)

local XFLogic = require 'zoo.panel.xfRank.XFLogic'
local XFSharePanel = require 'zoo.panel.xfRank.XFSharePanel'

function XFShareAction:ctor( ... )
	self.name = "XFShareAction"
	self.isPopScene = true
    self:setSource(AutoPopoutSource.kGamePlayQuit)
end

local function getKey(rank)
	return 'xf.fullstar.share.' .. UserManager:getInstance():getCurRoundFullStar() .. '.' .. rank
end

function XFShareAction:checkCanPop()
	if self.debug then
		self.popoutContext = {
				rank = 1,
				ts = 1,
			}
		return self:onCheckPopResult(true)
	end

	if not XFLogic:isEnabled() then
		return self:onCheckPopResult(false)
	end
    
    XFLogic:checkIfMeJustOnServerRank(function ( extra, rank, ts  )
    	if extra and rank and rank > 0 and ts then
			local can = not XFLogic:readCache(getKey(rank))

			self.popoutContext = {
				rank = rank,
				ts = ts,
			}

			self:onCheckPopResult(can)
		else
			self:onCheckPopResult(false)
		end
	end)
end

function XFShareAction:popout( next_action )

	if not self.popoutContext then 
		if next_action then next_action() end
		return
	end

	local panel = XFSharePanel:create({
		profile = ProfileRef.new(UserManager:getInstance().profile:encode()),
		fullstar_ts = self.popoutContext.ts,
		fullstar_rank = self.popoutContext.rank,
	})

	-- panel:ad(PopoutEvents.kRemoveOnce, function ( ... )
	-- 	if next_action then next_action() end
	-- end)

	local key = getKey(self.popoutContext.rank)

	panel:popoutPush(function ( ... )
		XFLogic:writeCache(key, true)
	end)
	
end