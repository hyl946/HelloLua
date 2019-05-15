
local fontName = "Droid Sans Fallback"
local fontSize = 30.0
local fontColor = "003300"	--ccc3(00,0x33,00)

AnnouncementPanel = class(BasePanel)

function AnnouncementPanel:create(posType, announcements)
	local panel = AnnouncementPanel.new()
	panel:loadRequiredResource("ui/announcement_panel.json")
	panel:init(posType, announcements)
	return panel	
end
function AnnouncementPanel:ctor( ... )
	self.cells = {}
end
function AnnouncementPanel:dispose( ... )
	for _,v in pairs(self.cells) do
		v:dispose()
	end

	BasePanel.dispose(self)
end

function AnnouncementPanel:init(posType, announcements)
	if _G.isLocalDevelopMode then printx(0, "AnnouncementPanel:init") end

	AnnoucementMgr.getInstance():refreshLocalData(posType, announcements)

	self.ui = self:buildInterfaceGroup("AnnouncementPanel/panel2")
	BasePanel.init(self, self.ui)

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()

	local bg = self.ui:getChildByName("bg")
	local size = bg:getGroupBounds().size

	local btn = self.ui:getChildByName('closeButton')
	btn:setTouchEnabled(true)
	btn:addEventListener(DisplayEvents.kTouchTap,function(event) self:onKeyBackClicked() end)

	local title = self.ui:getChildByName('title')

	local tableWidth = size.width - 60
	local tableHeight = size.height - 160

	self.onlyOneAnnounce = #announcements == 1
	for i,v in ipairs(announcements) do
		table.insert(self.cells,self:buildCell(i,v,tableWidth))
	end

	local function setPanelHeight(height)
		local originalSize = self.ui:getGroupBounds().size
		local originalHeight = originalSize.height
		local originalWidth = originalSize.width
		local scale = height / originalHeight
		local diffHeight = height - originalHeight
		self.ui:getChildByName('bg'):setPreferredSize(CCSizeMake(originalWidth, height))
		self.ui:getChildByName('bottom_deco'):setPositionY(self.ui:getChildByName('bottom_deco'):getPositionY() - diffHeight)
		self.ui:getChildByName('stamp'):setPositionY(self.ui:getChildByName('stamp'):getPositionY() - diffHeight)
		self.ui:getChildByName('left_deco'):setScaleY(scale)
		self.ui:getChildByName('right_deco'):setScaleY(scale)
	end

	local extendPanelHeight = 150
	-- topMargin是为了不挡住上面“开心消消乐”字样
	if #announcements == 1 then
		self.topMargin = 500
	else -- 多于一条的时候，面板略微拉长
		self.topMargin = 400
		tableHeight = tableHeight + extendPanelHeight
		setPanelHeight(size.height + extendPanelHeight)
	end

	self.tableView = self:buildTableView(tableWidth,tableHeight)
	self.tableView:setPositionX(700/2 - tableWidth/2 + 10) -- 微调
	self.tableView:setPositionY(title:getPositionY() - 100)

	self.ui:addChild(self.tableView)
end

function AnnouncementPanel:buildTableView(width,height)
	local layout = VerticalTileLayout:create(width)
	for k, v in pairs(self.cells) do 
		local item = ItemInClippingNode:create()
		item:setContent(v)
		v:setAnchorPoint(ccp(0, 0))
		-- item:setHeight(300)
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

function AnnouncementPanel:buildCell(i, announcement, width)
	local announceLabel = announcement.announcementContent
	if not self.onlyOneAnnounce then
		announceLabel = i .. "." .. announceLabel
	end

	local text = TextField:createStaticRichText(announceLabel, width, fontName, fontSize, fontColor)

	local container = CocosObject:create()

	DcUtil:UserTrack({category = "announcement",
		sub_category = "trigger",
		other = announcement.id,
		version = 0
	})

	if string.len(announcement.linkText or "") > 0 and string.len(announcement.link or "") > 0 then 
		local link = self:buildInterfaceGroup("AnnouncementPanel/link")

		local linkText = link:getChildByName("text")
		local linkLine = link:getChildByName("line")

		linkText:setDimensions(CCSizeMake(0,0))
		linkText:setString(announcement.linkText)
		linkLine:setScaleX(linkText:getContentSize().width/linkLine:getContentSize().width)
		local linkSize = link:getGroupBounds().size

		text:setPositionX(0)
		text:setPositionY(linkSize.height + 35)
		link:setPositionX(text:getGroupBounds().size.width - linkSize.width - 10) -- 微调
		link:setPositionY(linkSize.height + 30)

		container:addChild(text)
		container:addChild(link)

		link:setButtonMode(true)
		link:setTouchEnabled(true)
		link:addEventListener(DisplayEvents.kTouchTap,function ( ... )
			DcUtil:UserTrack({category = "announcement",
				sub_category = "link",
				other = announcement.id,
				version = 0
			})
			local openSuccess = false
			local linkUrl = string.gsub(announcement.link, " ", "")
			if __IOS then
				openSuccess = UIApplication:sharedApplication():openURL(NSURL:URLWithString(linkUrl))
			elseif __ANDROID then
				openSuccess = luajava.bindClass("com.happyelements.android.utils.HttpUtil"):openUri(linkUrl)
			elseif __WP8 then
				Wp8Utils:OpenUrl(linkUrl)
			end
			if openSuccess then
				DcUtil:UserTrack({category = "announcement",
					sub_category = "success",
					other = announcement.id,
					version = 0
				})
			end
		end)
		link.hitTestPoint = function(s,worldPosition, useGroupTest) 				
			if self.tableView:boundingBox():containsPoint(self:convertToNodeSpace(worldPosition)) then
		 		return CocosObject.hitTestPoint(s,worldPosition, useGroupTest)
		 	else
		 		return false
		 	end
		end

	else
		text:setAnchorPoint(ccp(0,0))
		text:setPositionX(0)
		text:setPositionY(30)

		container:addChild(text)
	end

	local newContainer = Layer:create()
	newContainer:addChild(container)
	container:setPositionY(0-container:getGroupBounds().size.height)
	return newContainer
end

function AnnouncementPanel:popout(closeCallback)
	PopoutQueue:sharedInstance():push(self, false, false)
	self.allowBackKeyTap = true

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local scale = visibleSize.height / 1280

	local bounds = self.ui:getChildByName("bg"):getGroupBounds()

	self:setPositionX(visibleSize.width/2 - bounds.size.width/2)
	self:setPositionY(-visibleSize.height/2 + bounds.size.height/2)
	self.closeCallback = closeCallback
end

function AnnouncementPanel:onKeyBackClicked()
	PopoutManager:sharedInstance():remove(self)
	self.allowBackKeyTap = false
	if self.closeCallback then
		self.closeCallback() 
	end
end