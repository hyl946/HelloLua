--[[
 * AchiBroadcastPanel
 * @date    2018-04-11 17:07:48
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

require 'zoo.panel.broadcast.AutoClosePanel'
AchiBroadcastPanel = class(AutoClosePanel)

local achiId = nil

function AchiBroadcastPanel:showBroadcast( id )
	achiId = id
end

function AchiBroadcastPanel:create(afterClose)
	local instance = AchiBroadcastPanel.new()
	instance:loadRequiredResource(PanelConfigFiles.common_message)
	instance:init(afterClose)
	return instance
end

function AchiBroadcastPanel:init(afterClose)
	BasePanel.init(self, self:buildInterfaceGroup('broadcast/achi'))
	self.afterClose = afterClose
	self.text = self.ui:getChildByName('text')
	self.text:setPreferredSize(self.text:getPreferredSize().width, 0)
	local link = self.ui:getChildByName("link")
	
	local state = Achievement:getState()

	self.achiId = achiId
	
	local icon_id = achiId
	-- if icon_id == 520 then
	-- 	icon_id = 70
	-- end
	local achi_icon = SpriteColorAdjust:createWithSpriteFrameName('achievement/icon/icon_'..icon_id..'0000')
	achi_icon:setScale(0.65)
	achi_icon:setPosition(ccp(70, -50))
	self.ui:addChild(achi_icon)

	local achi = Achievement:getAchi(achiId)
	if achi.type == AchiType.PROGRES then
		local level = achi:getCurReachedLevel()
		local numText = BitmapText:create(level..'级', "fnt/register2.fnt")
		numText:setScale(0.7)
		numText:setPosition(ccp(70, 32))
		achi_icon:addChild(numText)
	end

	if achiId == AchiId.kUnlockNewObstacle then
		local level = achi:getCurReachedLevel()
		local count = achi:getCurTarCount(level)
		local obstacleConfig = require "zoo.PersonalCenter.ObstacleIconConfig"
		if obstacleConfig[count] then
			local name = "area_icon_"..obstacleConfig[count].."0000"
			if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(name) == nil then
				FrameLoader:loadImageWithPlist("flash/quick_select_level.plist")
			end
			if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(name) ~= nil then
				local obstacle = Sprite:createWithSpriteFrameName(name)
				achi_icon:addChild(obstacle)
				obstacle:setScale(0.51)
				local size = achi_icon:getContentSize()
				obstacle:setAnchorPoint(ccp(0.5, 0.5))
				obstacle:setPositionXY(72, 82)
			end
		end
	end

	self.ui:setTouchEnabled(true, 0, true)

	local category = achi.category

	self.ui:addEventListener(DisplayEvents.kTouchTap, function ()
        AchiUIManager:openMainPanel(tonumber(category))
	end)

	-- self:enableAutoClose(function() self:closeRightNow() end)
	
end

function AchiBroadcastPanel:popout()
	if self.isDisposed then return end
	local achi = Achievement:getAchi(self.achiId)
	local name = localize("achievement.name."..(achi.id or achi.priority))
	if achi.type == AchiType.PROGRES then
		local level = achi:getCurReachedLevel()
		self.text:setString(localize("achievement.notification2", {name = name, num = level}))
	else
		self.text:setString(localize("achievement.notification1", {name = name}))
	end
	
	self.text:setPositionY(self.text:getPositionY() - 8)

	AutoClosePanel.popout(self)
	achiId = nil
end

function AchiBroadcastPanel:isNeedShow()
	return achiId ~= nil
end

function AchiBroadcastPanel:getPriority()
	return 1001
end