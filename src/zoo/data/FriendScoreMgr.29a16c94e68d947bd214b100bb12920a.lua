 
local FriendScoreMgr = class()

------------------------RefreshButton------------------------
local RefreshButton = class(BaseUI)
function RefreshButton:ctor()
end

function RefreshButton:init(ui)
	BaseUI.init(self, ui)
	self.bg = self.ui:getChildByName("bg")
	self:setEnabled(true)
end

function RefreshButton:ad(eventName, listener, context)
	self.ui:addEventListener(eventName, listener, context)
end

function RefreshButton:setEnabled(isEnabled)
	if self.isEnabled ~= isEnabled then
		self.isEnabled = isEnabled

		if self.ui and self.ui.refCocosObj then
			self.ui:setTouchEnabled(isEnabled, 0, true)

			if self.bg and self.bg.refCocosObj then
				if isEnabled then
					self.bg:clearAdjustColorShader()
				else
					self.bg:applyAdjustColorShader()
					self.bg:adjustColor(0,-1, 0, 0)
				end
			end
		end		
	end
end

function RefreshButton:create(ui)
	local btn = RefreshButton.new()
	btn:init(ui)
	return btn
end
-------------------------------------------------------------

local instance = nil
local UpdateInterval = 1800 
function FriendScoreMgr.getInstance()
    if not instance then
        instance = FriendScoreMgr.new()
        instance:init()
    end
    return instance
end

function FriendScoreMgr:init()
	self.scoreCaches = {}
end

function FriendScoreMgr:clearScoreCache(levelId)
	self.scoreCaches[levelId] = {}
	self.scoreCaches[levelId].scores = {}
	self.scoreCaches[levelId].updateTime = Localhost:timeInSec()
end

function FriendScoreMgr:updateScoreCache(levelId, _uid, _score, _star)
	table.insert(self.scoreCaches[levelId].scores, {uid = _uid, score = _score, star = _star})
end

function FriendScoreMgr:getScoreCaches(levelId)
	return self.scoreCaches[levelId].scores
end

function FriendScoreMgr:shouldUpdateFromServer(levelId)
	if self.scoreCaches[levelId] and self.scoreCaches[levelId].updateTime then
		local timePass = Localhost:timeInSec() - self.scoreCaches[levelId].updateTime
		return timePass > UpdateInterval
	else
		return true
	end
end

function FriendScoreMgr:createRefreshButton(ui)
	local btn = RefreshButton:create(ui)
	return btn
end

return FriendScoreMgr