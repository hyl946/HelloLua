local DEFAULT_ICON_MARGIN = 5 --px
local NUM_9_ICON_MARGIN_SCALE = 0.7

local SINGLE_PAGE_ANIM_DURATION = 0.07

local SCALE_FACTOR = 0.256

----------------------- PAGER CLASS ------------------
Pager = class(Layer)

function Pager:create(numOfPages, groupName)
	assert(numOfPages > 0)
	assert(groupName)
	local instance = Pager.new()
	instance:loadRequiredResource(PanelConfigFiles.bag_panel_ui)
	instance:init(numOfPages, groupName)
	return instance

end

function Pager:ctor()
	
end

function Pager:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:create(panelConfigFile)
end

function Pager:init(numOfPages, groupName)
	assert(numOfPages > 0)

	Layer.initLayer(self)

	self.__index = 1
	self.numOfPages = numOfPages or 1
	self.icons = {}
	self.width = 0
	self.height = 0
	self.iconMargin = DEFAULT_ICON_MARGIN
	self.groupName = groupName

	if self.numOfPages == 0 then self.numOfPages = 1 end



	for i=1, self.numOfPages do
		local icon = self.builder:buildGroup(groupName)--ResourceManager:sharedInstance():buildGroup(groupName)
		local size = icon:getGroupBounds().size
		self.icons[i] = icon
		local rect = icon:getChildByName('txt_fontSize')
		local txt = icon:getChildByName('txt')
		local newLabel = TextField:createWithUIAdjustment(rect, txt)
		-- use newLabel to replace txt, which is removed by createWithUIAdjustment
		newLabel.name = 'txt'
		icon:addChild(newLabel)
		local x = (size.width + self.iconMargin) * (i - 1)
		icon:setPosition(ccp(x, 0))
		self:addChild(self.icons[i])
	end

	-- self:activateIcon(self.__index)
	-- for i=2, self.numOfPages do
	-- 	self:deactivateIcon(i)
	-- end
	self.icons[1]:getChildByName('txt'):setString(1)
	for i=2, self.numOfPages do
		self.icons[i]:getChildByName('activated'):setScale(SCALE_FACTOR)
	end

	self.width = self:getGroupBounds().width
	self.height = self:getGroupBounds().height

	self:updateShow()
end

function Pager:addPage()
	self.numOfPages = self.numOfPages + 1
	local icon = ResourceManager:sharedInstance():buildGroup(self.groupName)
	local size = icon:getGroupBounds().size
	self.icons[self.numOfPages] = icon
	local rect = icon:getChildByName('txt_fontSize')
	local txt = icon:getChildByName('txt')
	local newLabel = TextField:createWithUIAdjustment(rect, txt)
	-- use newLabel to replace txt, which is removed by createWithUIAdjustment
	newLabel.name = 'txt'
	icon:addChild(newLabel)
	local x = (size.width + self.iconMargin) * (self.numOfPages - 1)
	icon:setPosition(ccp(x, 0))
	icon:getChildByName('activated'):setScale(SCALE_FACTOR)
	self:addChild(icon)

	-- local curPos = self:getPosition()
	-- self:setPosition(ccp(curPos.x - size.width, curPos.y))

	self:updateShow()
end

function Pager:updateShow()
	local marginScale = self.numOfPages>=9 and NUM_9_ICON_MARGIN_SCALE or 1
	print("Pager:updateShow()",self.numOfPages,marginScale)
	for i,v in ipairs(self.icons) do
		local size = v:getGroupBounds().size
		local x = (size.width + self.iconMargin) * marginScale * (i - 1)
		print("Pager:updateShow()",i,size.width,marginScale)
		v:setPosition(ccp(x,0))
	end
end

function Pager:activateIcon(index)
	local icon = self.icons[index]
	if icon then

		local txt = icon:getChildByName('txt')
		local activated = icon:getChildByName('activated')

		local zoomIn = CCScaleTo:create(SINGLE_PAGE_ANIM_DURATION, 1)
		txt:setString(index)
		txt:setVisible(true)
		activated:setScale(SCALE_FACTOR)
		activated:runAction(zoomIn)
	end
end

function Pager:deactivateIcon(index)
	local icon = self.icons[index]
	if icon then

		local txt = icon:getChildByName('txt')
		local activated = icon:getChildByName('activated')		
		local zoomOut = CCScaleTo:create(SINGLE_PAGE_ANIM_DURATION, SCALE_FACTOR)

		txt:setVisible(false)
		activated:runAction(zoomOut)
	end
end

function Pager:next()
	if self.__index < self.numOfPages then
		self:deactivateIcon(self.__index)
		self:activateIcon(self.__index + 1)
		self.__index = self.__index + 1
	end
	-- self:goto(self.__index + 1)
	--print ('pager: ', self.__index)
end

function Pager:prev()
	if (self.__index > 1) then
		self:deactivateIcon(self.__index)
		self:activateIcon(self.__index - 1)
		self.__index = self.__index - 1
	end
	-- self:goto(self.__index - 1)
	-- print ('pager: ', self.__index)
end

function Pager:goto(index)
	if index == self.__index then return end
	if index >= 1 and index <= self.numOfPages then 
		for i, v in ipairs(self.icons) do
			self:deactivateIcon(i)
		end
		self:activateIcon(index)
		self.__index = index
	end
	-- print ('pager: ', self.__index)
end

