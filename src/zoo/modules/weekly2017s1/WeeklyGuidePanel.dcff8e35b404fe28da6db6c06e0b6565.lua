require "zoo.panel.basePanel.BasePanel"

local WeeklyGuidePanel = class(BasePanel)

function WeeklyGuidePanel:create(itemId, rowDelta, callback)
	local panel = WeeklyGuidePanel.new()
	panel:loadRequiredResource("ui/WeeklyGuidePanel.json")
	panel:init(itemId, rowDelta, callback)
	return panel
end

function WeeklyGuidePanel:init(itemId, rowDelta, callback)
	self.ui = self:buildInterfaceGroup("weekly_2017_s1_guide/WeeklyGuidePanel") 
	BasePanel.init(self, self.ui)
	self.itemId = itemId
	self.rowDelta = rowDelta
	self.guideEndCB = callback
	self.bgUI = self.ui:getChildByName("bg")

    if ItemType:isTimeProp(itemId) then itemId = ItemType:getRealIdByTimePropId(itemId) end
	local itemIcon = ResourceManager:sharedInstance():buildItemSprite(itemId)
	local holder = self.bgUI:getChildByName("iconPlaceHolder")
	local bSize = holder:getGroupBounds().size
	if itemIcon then 
		local iSize = itemIcon:getGroupBounds().size
		local scale = bSize.width / iSize.width
		itemIcon:setScale(scale/0.6)
		itemIcon:setPositionXY(holder:getPositionX(), holder:getPositionY())
		self.bgUI:addChild(itemIcon)
	end
	holder:removeFromParentAndCleanup(true)

	local tile = self.bgUI:getChildByName("title")
	tile:setRichText("[#B40D68]"..Localization:getInstance():getText("prop.name."..tostring(itemId)).."[/#]")

	local tip = self.bgUI:getChildByName("tip")
	tip:setRichText("向上再" .. 
                    string.format("[#B40D68]滚%d行[/#]，",rowDelta) ..
                    "有机\n会获得该道具哦~",
                    "003366")

	self.bgUI:setTouchEnabled(true, 0, true)
	self.bgUI:addEventListener(DisplayEvents.kTouchTap, function ()
		if self.isDisposed then return end
		self:removePopout()
	end)
end

function WeeklyGuidePanel:popout()
	local scene = Director:sharedDirector():getRunningScene()
	if scene then 
		local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
		scene:addChild(self)
		self:setPositionXY(visibleOrigin.x - 40,visibleOrigin.y + 350)

		local function onTimeOut()
			if self.isDisposed then return end
			self:removePopout()
		end
		self.timeoutId = setTimeOut(onTimeOut, 5)
	end
end

function WeeklyGuidePanel:removePopout()
	if self.timeoutId then cancelTimeOut(self.timeoutId) end
	self.timeoutId = nil
	self:removeFromParentAndCleanup(true)
end

function WeeklyGuidePanel:dispose()
	BasePanel.dispose(self)	
	if self.guideEndCB then 
		self.guideEndCB() 
		self.guideEndCB = nil
	end
end

return WeeklyGuidePanel