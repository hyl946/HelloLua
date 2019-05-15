
StockExchangePanel = class(BasePanel)

function StockExchangePanel:create( items,closeCallback )
	local s = StockExchangePanel.new()
	s:loadRequiredResource(PanelConfigFiles.cd_key_exchange_panel)
	s:init(items,closeCallback)
	return s
end

function StockExchangePanel:init( items,closeCallback )
	self.closeCallback = closeCallback
	self.ui	= self:buildInterfaceGroup("stock_exchange_info_panel")
	BasePanel.init(self, self.ui)

	-- item.materialDesc = string.rep(item.materialDesc,100)
	-- items = { item,item,item,item }
	-- items[1].extra = "http://www.baidu.com"
	-- items = { items[1],items[1],items[1],items[1], }

	local desc = self.ui:getChildByName("desc")
	if #items > 1 then
		-- 
		desc:setString(Localization:getInstance():getText("stock.exchange.code.panel.desc"))
	else
		desc:setString(tostring(items[1].materialDesc))
	end

	local descOriginSize = desc:getContentSize()
	desc:setDimensions(CCSizeMake(descOriginSize.width,0))
	local descSize = desc:getContentSize()
	local diffY = descSize.height - descOriginSize.height

	local tip = self.ui:getChildByName("tip")
	-- "消息会保存在兑换中心10天"
	tip:setString(Localization:getInstance():getText("stock.exchange.code.panel.tip"))

	local code = self.ui:getChildByName("code")

	if #items == 1 then
		self:setCodeInfo(code,items[1])
	else
		code.name = nil
		code:setVisible(false)
		local codeSize = code:getGroupBounds().size
		local codeLayout = VerticalTileLayout:create(codeSize.width)
		codeLayout:setItemVerticalMargin(10)

		if #items == 2 then
			codeLayout:setPositionX(code:getPositionX())
			codeLayout:setPositionY(code:getPositionY() + codeSize.height + 10)

			codeLayout.name = "code"
			self.ui:addChild(codeLayout)
			
			diffY = diffY + codeSize.height + 10
		else
			local codeScroll = VerticalScrollable:create(
				codeSize.width,codeSize.height * 2.5
			)
			codeScroll:setPositionX(code:getPositionX())
			codeScroll:setPositionY(code:getPositionY() + codeSize.height * 1.5)
			codeScroll:setContent(codeLayout)
			codeScroll:setScrollableHeight(codeSize.height*#items + 10*(#items-1))

			codeScroll.name = "code"
			self.ui:addChild(codeScroll)

			diffY = diffY + codeSize.height * 1.5
		end

		for k,v in pairs(items) do
			local code = self:buildInterfaceGroup("stock_exchange_info")

			self:setCodeInfo(code,v)

			local item = VerticalTileItem.new(CCNode:create())
			item:setContent(code)
			item:setHeight(codeSize.height)
			codeLayout:addItem(item)
		end
	end


	local btn = GroupButtonBase:create(self.ui:getChildByName("btn"))
	btn:setString("知道了")
	btn:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:onCloseBtnTapped()
	end)

	for k,v in pairs({"code","btn","tip"}) do
		local u = self.ui:getChildByName(v)
		u:setPositionY(u:getPositionY() - diffY)
	end
	for k,v in pairs({"bg","bg2"}) do
		local u = self.ui:getChildByName(v)		
		local size = u:getPreferredSize()
		u:setPreferredSize(CCSizeMake(size.width,size.height + diffY))
	end

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local size = self.ui:getChildByName("bg"):getPreferredSize()
	self.ui:setScale(math.min(1,visibleSize.height/size.height))
end


function StockExchangePanel:setCodeInfo( codeUi,item )
	local codeText = codeUi:getChildByName("text")
	codeText:setString(tostring(item.ticketCode))
	
	local textBounds = codeText:boundingBox()
	codeText:setAnchorPoint(ccp(0.5,0.5))

	codeText:setPositionX(textBounds:getMidX())
	codeText:setPositionY(textBounds:getMidY())
	codeText:setDimensions(CCSizeMake(0,0))

	local bg = codeUi:getChildByName("bg")
	codeText:setScale(math.min(1,(bg:getContentSize().width - 40)/codeText:getContentSize().width))

	local codeLink = codeUi:getChildByName("link")
	if item.extra and string.len(item.extra) > 0 then 
		codeLink:setTouchEnabled(true)
		codeLink:setButtonMode(true)
		codeLink:addEventListener(DisplayEvents.kTouchTap,function( ... )
			OpenUrlUtil:openUrl(item.extra)
		end)
	else
		codeLink:setVisible(false)
	end
	-- 
	self:setLongTouchListener(codeUi,function( ... )
		ClipBoardUtil.copyText(tostring(item.ticketCode))

		CommonTip:showTip(Localization:getInstance():getText("stock.exchange.code.panel.copyText"))
	end)
end

function StockExchangePanel:setLongTouchListener(codeUi,listener)
    codeUi:setTouchEnabled(true)

    local beginPos = nil

    local function touchBegin( evt )
        if self.timeId then
            cancelTimeOut(self.timeId)
        end

        beginPos = evt.globalPosition

        self.timeId = setTimeOut(function( ... )
            self.timeId = nil

            if self.isDisposed then
                return
            end
            if listener then
                listener()
            end

        end,0.5)
    end

    function touchMove( evt )
        if self.timeId and ccpDistanceSQ(beginPos,evt.globalPosition) > 10 then
            cancelTimeOut(self.timeId)
            self.timeId = nil
        end
    end

    local function touchEnd( ... )
        if self.timeId then
            cancelTimeOut(self.timeId)
            self.timeId = nil
        end
    end

    codeUi:addEventListener(DisplayEvents.kTouchBegin,touchBegin)
    codeUi:addEventListener(DisplayEvents.kTouchMove,touchMove)
    codeUi:addEventListener(DisplayEvents.kTouchEnd,touchEnd)
end


function StockExchangePanel:popout( ... )
	PopoutManager:add(self,true,false)

	self:setToScreenCenterVertical()
	self:setToScreenCenterHorizontal()
	self.allowBackKeyTap = true
end

function StockExchangePanel:onCloseBtnTapped( ... )
	PopoutManager:remove(self)

	if self.closeCallback then
		self.closeCallback()
	end
end