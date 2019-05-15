NextLevelButtonProxy = class()

local instance

function NextLevelButtonProxy:getInstance( ... )
	-- body
	if not instance then
		instance = NextLevelButtonProxy.new()
	end
	return instance
end

function NextLevelButtonProxy:ctor( ... )
	self.findTheWayEnabled = false
end

function NextLevelButtonProxy:getProxy( ... )

	if self.findTheWayEnabled then
		return {
			getButtonString = function ( ... )

				local FTWLocalLogic = require 'zoo.localActivity.FindingTheWay.FindingTheWayLocalLogic'
				return '闯特' .. FTWLocalLogic:getLevelIndex(FTWLocalLogic:selectOneLevel()) .. '关'
			end,
			onTap = function ( _, levelSuccessTopPanel )

				local FTWLocalLogic = require 'zoo.localActivity.FindingTheWay.FindingTheWayLocalLogic'
				levelSuccessTopPanel.parentPanel:changeToStartGamePanel(FTWLocalLogic:selectOneLevel())				
			end,
			shouldHideLevelTitle = function ( ... )
				return true
			end
		}
	end
end


function NextLevelButtonProxy:setFindTheWayEnabled(b)
	self.findTheWayEnabled = b
end

function NextLevelButtonProxy:onStartGamePanelPopout( source )
		-- printx(61, 'onStartGamePanelPopout', source)

	local FTWLocalLogic = require 'zoo.localActivity.FindingTheWay.FindingTheWayLocalLogic'

	if not (FTWLocalLogic:isActEnabled()) then
		self:setFindTheWayEnabled(false)
	end

	if not FTWLocalLogic:isFullStar() then
		self:setFindTheWayEnabled(false)
	end

	if source == StartLevelSource.kFindTheWay
	then
		self:setFindTheWayEnabled(true)
		return
	end

	if source == StartLevelSource.kPrePropExpire then
		return
	end

	if source == StartLevelSource.kFailPanel then
		return
	end

	if source == StartLevelSource.kSuccessPanel then
		return
	end

	if source == StartLevelSource.kReplayPanel then
		return
	end

	self:setFindTheWayEnabled(false)

end