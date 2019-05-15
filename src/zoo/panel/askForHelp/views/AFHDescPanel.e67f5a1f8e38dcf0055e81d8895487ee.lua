
local AFHDescPanel = class(BasePanel)
function AFHDescPanel:create()
	local panel = AFHDescPanel.new()
	panel:loadRequiredResource("ui/AskForHelp/panel_ask_for_help.json")
	panel:init()
	return panel
end

function AFHDescPanel:unloadRequiredResource( ... )
end

function AFHDescPanel:init()
	local ui = self:buildInterfaceGroup("AskForHelp/interface/DescPanel")
	BasePanel.init(self, ui)

	local close = ui:getChildByName("closeBtn")
	close:setTouchEnabled(true)
	close:setButtonMode(true)
	close:addEventListener(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped() end)

	local btnYes = GroupButtonBase:create(ui:getChildByName("btnYes"))
	btnYes:setString("知道了")
	btnYes:addEventListener(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped() end)

	local bound = ui:getChildByName("ph")
	bound:setVisible(false)
	local sSize = bound:getGroupBounds().size
	sSize = {width = sSize.width, height = sSize.height}

	local totalHeight = - 10
	local layer = Layer:create()

	local function setRichText(item, textLabel, str)
		textLabel:setVisible(false)
		local width = textLabel:getDimensions().width
		local pos = textLabel:getPosition()
		local richText = TextUtil:buildRichText(str, width, textLabel:getFontName(), textLabel:getFontSize(), textLabel:getColor())
		richText:setPosition(ccp(pos.x, pos.y))
		item:addChildAt(richText, textLabel:getZOrder())
		return richText
	end

	for i=1, 7 do
		local item = self:buildInterfaceGroup("AskForHelp/interface/DescItem")
		item:getChildByName("text"):setDimensions(CCSizeMake(sSize.width - 80, 0))

		item:getChildByName("text"):setString(localize("askforhelp.AFHDescPanel.item." ..tostring(i)))
		local totalCount = AskForHelpManager.getInstance():getConfig():getMaxDailyFriendHelpCount()
		if i == 1 and Achievement:getRightsExtra( "FriendLevelCount" ) > 0 then
			setRichText(item, item:getChildByName("text"), "可以请求好友帮忙成功闯过的关卡上限为" .. string.format("[#FF6600]%d[/#]",totalCount).."关。")
		elseif i == 1 then
			item:getChildByName("text"):setString("可以请求好友帮忙成功闯过的关卡上限为"..totalCount.."关。")
		end

		item:setPositionX(10)
		item:setPositionY(totalHeight)
		layer:addChild(item)
		local h = item:getChildByName("text"):getContentSize().height + 20
		totalHeight = totalHeight - (h < 80 and 80 or h)
	end

	if -totalHeight > sSize.height then
		local scroll = VerticalScrollable:create(sSize.width, sSize.height, true)
		scroll:setIgnoreHorizontalMove(false)
		local layout = ItemInLayout:create()
		layout:setContent(layer)
		layout:setHeight(-totalHeight)
		scroll:setContent(layout)
		scroll:updateScrollableHeight()
		local rSize = scroll:getGroupBounds().size
    	scroll:setPositionXY(bound:getPositionX(), bound:getPositionY())
		self.ui:addChild(scroll)
	else
		layer:setPositionXY(bound:getPositionX(), bound:getPositionY())
		self.ui:addChild(layer)
	end

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local size = self.ui:getChildByName("_bg"):getGroupBounds().size

	self.ui:setPositionX(visibleSize.width/2 - size.width/2)
	self.ui:setPositionY(-visibleSize.height/2 + size.height/2)
end

function AFHDescPanel:popout()
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function AFHDescPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

return AFHDescPanel