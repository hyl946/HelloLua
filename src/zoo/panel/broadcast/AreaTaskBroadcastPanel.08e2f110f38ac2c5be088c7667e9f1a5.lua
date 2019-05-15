require 'zoo.util.OpenUrlUtil'
require 'zoo.panel.broadcast.AutoClosePanel'
require "zoo.panel.WechatFriendPanel"
require "zoo.panel.ConsumeHistoryPanel"

AreaTaskBroadcastPanel = class(AutoClosePanel)

function AreaTaskBroadcastPanel:create(taskInfo, rewards, afterClose)
	local instance = AreaTaskBroadcastPanel.new()
	instance:loadRequiredResource(PanelConfigFiles.common_message)
	instance:init(taskInfo, rewards, afterClose)
	return instance
end

function AreaTaskBroadcastPanel:init(taskInfo, rewards, afterClose)
	BasePanel.init(self, self:buildInterfaceGroup('broadcast/area_task'))
	self.afterClose = afterClose

	self.bg = self.ui:getChildByName('bg')
	self.text = self.ui:getChildByName('text')

	local rewardTxt = {}
	for _, v in pairs(rewards) do

		if ItemType:isMergableItem(v.itemId) then
			table.insert(rewardTxt, string.format("%s", localize('prop.name.' .. v.itemId, {num = v.num})))
		else
			table.insert(rewardTxt, string.format("%sx%s", localize('prop.name.' .. v.itemId), v.num)) 
		end
	end

	-- self.text:setPositionX(self.text:getPositionX() - 5)
	self.text.oldHeight = self.text:getDimensions().height
	self.text:setDimensions(CCSizeMake(
		self.text:getDimensions().width,
		0
	))

	self.text:setString(localize('area.goal.reward.announcement', {
		num = taskInfo.levelId or 1,
		reward = table.concat(rewardTxt, '、'),
	}))

	local linkText = '查看'

	self.link = self.ui:getChildByName('link')

	if linkText then
		self.link:setDimensions(CCSizeMake(0, 0))
		self.link:setString(linkText)
	else
		self.link:removeFromParentAndCleanup(true)
		self.link = nil
	end

	if self.link then
		local underLine = LayerColor:createWithColor(
			ccc4(0x36, 0x9e, 0x1a), 
			self.link:getContentSize().width,
			2
		)
		self.link:addChild(underLine)

		local bounds = self.bg:getGroupBounds(self.ui)
		local rightX = bounds.origin.x + self.bg:getPreferredSize().width
		local deltaX = self.link:getGroupBounds(self.ui).origin.x + self.link:getContentSize().width - rightX
		self.link:setPositionX(self.link:getPositionX() - deltaX)
	end

	self.text.newHeight = self.text:getContentSize().height

	local contentHeight = self.text.newHeight

	if self.link then
		self.link:setPositionY(self.text:getPositionY() - self.text.newHeight - 12)
		contentHeight = self.text.newHeight + self.text:getGroupBounds(self.ui).origin.y - self.link:getGroupBounds(self.ui).origin.y
	end

	if contentHeight + 30 < self.bg:getPreferredSize().height then
	else
		self.bg:setPreferredSize(CCSizeMake(
			self.bg:getPreferredSize().width,
			contentHeight + 30
		))
	end

	local deltaY = (self.bg:getPreferredSize().height - contentHeight) / 2
	if self.link then
		self.text:setPositionY(-deltaY-10)
	else
		self.text:setPositionY(-deltaY)
	end
	if self.link then
		self.link:setPositionY(self.text:getPositionY() - self.text.newHeight - 12)
	end

	if self.link then
		local linkInput = Layer:create()
		self.link:removeFromParentAndCleanup(false)
		linkInput:setPosition(ccp(self.link:getPositionX(), self.link:getPositionY() + 5))
		self.link:setPosition(ccp(0, 0))
		self.ui:addChild(linkInput)
		linkInput:addChild(self.link)

		linkInput:setTouchEnabled(true)
		linkInput:addEventListener(DisplayEvents.kTouchBegin,function()
			local levelId = taskInfo.levelId
			Notify:dispatch("QuitNextLevelModeEvent")

			local areaId = math.floor((levelId - 1) / 15) + 40001
			local AreaTaskInfoPanel = require 'zoo.areaTask.AreaTaskInfoPanel'
			AreaTaskInfoPanel:create(areaId):popout()
		end, self)
		self.link:setPositionX(self.link:getPositionX() - 36)
	end


	self:enableAutoClose(function() self:closeRightNow() end)
end


function AreaTaskBroadcastPanel:getPriority()
	return 1002
end


function AreaTaskBroadcastPanel:isCareGuide()
    return false
end

function AreaTaskBroadcastPanel:isCarePanel()
    return false
end

function AreaTaskBroadcastPanel:isCareHomeQueue()
	return false
end