require 'zoo.util.OpenUrlUtil'
require 'zoo.panel.broadcast.AutoClosePanel'

CommonMessagePanel = class(AutoClosePanel)

function CommonMessagePanel:createWithConfig(config, afterClose)
	return CommonMessagePanel:create(
		config.id,
		tonumber(config.type),
		config.text,
		config.linkText,
		config.linkUrl,
		config.priority,
		afterClose
	)
end

function CommonMessagePanel:create(id, type, text, linkText, linkURL, priority, afterClose)
	local instance = CommonMessagePanel.new()
	instance:loadRequiredResource(PanelConfigFiles.common_message)
	instance:init(id, type, text, linkText, linkURL, priority, afterClose)
	return instance
end

function CommonMessagePanel:init(id, type, text, linkText, linkURL, priority, afterClose)
	BasePanel.init(self, self:buildInterfaceGroup('broadcast/panel'))

	self.afterClose = afterClose
	self.linkURL = linkURL
	self.priority = priority
	self.id = id
	self.type = type

	self.bg = self.ui:getChildByName('bg')
	self.text = self.ui:getChildByName('text')
	self.link = self.ui:getChildByName('link')
	local linkHeight = self.link:getDimensions().height
	
	self.ui:getChildByName('icon'..(3-type)):removeFromParentAndCleanup(true)

	self.text:setPositionX(self.text:getPositionX() - 5)
	self.text.oldHeight = self.text:getDimensions().height
	self.text:setDimensions(CCSizeMake(
		self.text:getDimensions().width,
		0
	))
	self.text:setString(text)

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
			DcUtil:UserTrack({category = "broadcast",
				sub_category = "link",
				other = self:getID(),
				version = 0
			})
			OpenUrlUtil:openUrl(self.linkURL)
		end, self)
		self.link:setPositionX(self.link:getPositionX() - 36)
	end

	self:enableAutoClose(function() self:closeRightNow() end)

end

function CommonMessagePanel:getID()
	return self.id
end

function CommonMessagePanel:getType()
	return self.type
end

function CommonMessagePanel:getPriority()
	return self.priority
end