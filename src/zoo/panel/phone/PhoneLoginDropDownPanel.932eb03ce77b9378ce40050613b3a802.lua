local visibleOrigin = Director.sharedDirector():getVisibleOrigin()
local visibleSize = Director.sharedDirector():getVisibleSize()

PhoneLoginDropDownPanel = class(BasePanel)
function PhoneLoginDropDownPanel:create( phoneNumber, pos )
	local panel = PhoneLoginDropDownPanel.new()
	panel:loadRequiredResource("ui/login.json")
	panel:init(phoneNumber,pos)
	return panel
end
-- function PhoneLoginDropDownPanel:loadRequiredJson( panelConfigFile )
-- 	-- self.panelConfigFile = panelConfigFile
-- 	self.builder = InterfaceBuilder:create(panelConfigFile)
-- end
function PhoneLoginDropDownPanel:init( phoneNumber,pos )
	self.ui = self:buildInterfaceGroup("login/drowDownPanel")
	BasePanel.init(self, self.ui)
	
	self.size = self.ui:getChildByName("bg"):getGroupBounds().size
	self.size = {width = self.size.width, height = self.size.height}

	self:updatePostion(pos)

	local function onTouch( eventType, x, y )
		if eventType == "began" then
			local leftBottom = self.ui:convertToWorldSpace(ccp(0,-self.size.height))
			local rightTop = self.ui:convertToWorldSpace(ccp(self.size.width,0))

			if not (x > leftBottom.x and x < rightTop.x and y > leftBottom.y and y < rightTop.y) then
				self:onKeyBackClicked()
				-- return true
			end
		end
		return true
	end
	local touchLayer = CCLayer:create()
	touchLayer:registerScriptTouchHandler(onTouch,false,0,true)
	touchLayer:setTouchEnabled(true)
	self.ui:addChild(CocosObject.new(touchLayer))

	local phoneList = Localhost:readCachePhoneListData()
	if string.len(phoneNumber) == 11 then 
		table.removeValue(phoneList,phoneNumber)
		table.insert(phoneList,1,phoneNumber)
	end 
	self.cells = {}
	for i,v in ipairs(phoneList) do
		local cell = self:buildInterfaceGroup("login/drowDownItem")
		
		cell:getChildByName("text1"):setVisible(i == 1)
		cell:getChildByName("bg1"):setVisible(i == 1)
		cell:getChildByName("text2"):setVisible(i ~= 1)
		cell:getChildByName("bg2"):setVisible(i ~= 1)

		cell:getChildByName("text1"):setVerticalAlignment(kCCVerticalTextAlignmentCenter)
		cell:getChildByName("text2"):setVerticalAlignment(kCCVerticalTextAlignmentCenter)

		cell:getChildByName("text1"):setAnchorPoint(ccp(0,0.5))		
		cell:getChildByName("text2"):setAnchorPoint(ccp(0,0.5))

		cell:getChildByName("text1"):setPositionY(-cell:getGroupBounds().size.height/2)
		cell:getChildByName("text2"):setPositionY(-cell:getGroupBounds().size.height/2)

		if i == 1 then 
			cell:getChildByName("text1"):setString(v)
		else
			cell:getChildByName("text2"):setString(v)
		end
		cell:setTouchEnabled(true)
		cell:addEventListener(DisplayEvents.kTouchTap,function( ... )
			self:remove()
			if self.selectCompleteCallback then 
				self.selectCompleteCallback(v)
			end
		end)
		table.insert(self.cells,cell)
	end

	local listView = self:buildListView(self.size.width,self.size.height - 3)
	listView:setPositionY(-1)
	self.ui:addChild(listView)

end

function PhoneLoginDropDownPanel:updatePostion( pos )
	self:setPositionX(pos.x + visibleOrigin.x)
	self:setPositionY(-visibleSize.height + pos.y - visibleOrigin.y)
end

function PhoneLoginDropDownPanel:popout( ... )
	PopoutManager:sharedInstance():add(self,false,true)
end
function PhoneLoginDropDownPanel:remove( ... )
	PopoutManager:sharedInstance():remove(self)
end
function PhoneLoginDropDownPanel:onKeyBackClicked( ... )
	self:remove()
	if self.selectCompleteCallback then 
		self.selectCompleteCallback(nil)
	end
end
function PhoneLoginDropDownPanel:buildListView(width,height)
	local layout = VerticalTileLayout:create(width)
	layout:setItemVerticalMargin(0)
	for k, v in pairs(self.cells) do 
		local item = ItemInClippingNode:create()
		item:setContent(v)
		-- v:setAnchorPoint(ccp(0, 0))
		item:setHeight(height/3)
		item:setParentView(container)
		layout:addItem(item)
	end

	local layoutHeight = layout:getHeight()
	if layoutHeight > height then		
		local container = VerticalScrollable:create(width, height, true, false)
		container:setContent(layout)
		return container
	else
		return layout
	end
end
function PhoneLoginDropDownPanel:setSelectCompleteCallback( selectCompleteCallback )
	self.selectCompleteCallback = selectCompleteCallback
end
