AdvancedLoggerPadRender = class(Layer)

function AdvancedLoggerPadRender:create( width, height, data )


	-- bg不能设置visible为false，因为bg是全部显示对象的容器。。。
	--local sp = CCSprite:createWithSpriteFrameName("bg_render0000")
	

	local s = AdvancedLoggerPadRender.new()
	--s.bg = sp
	s:init(width, height, data)
	return s
end

function AdvancedLoggerPadRender:init( width, height, data )
	-- body
	self.width = width
	self.height = height
	self.data = data

	Layer.initLayer(self)

	self:ignoreAnchorPointForPosition(false)
	self:setAnchorPoint(ccp(0, 1))

	local text = TextField:create("", nil, 16 , CCSizeMake( 600 , 500), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	text:setColor(ccc3(0, 0, 0))
	--text:setPosition(ccp(5, 595))
	text:ignoreAnchorPointForPosition(false)
	text:setAnchorPoint(ccp(0, 0))

	text:setString("Test Info Test Info Test Info Test Info Test Info Test Info Test Info Test Info Test Info Test Info Test Info Test nfo")
	--text:setText("TestInfoTestInfoTestInfoTestInfoTestInfo")
	--text:setText("TTTTTTTTTTTTTTTTTTTTTTTTTTTT")
	

	local layer = LayerColor:create()
	layer:setOpacity(200)
	layer:setColor((ccc3(255,0,0)))
	layer:setContentSize(CCSizeMake( 600 , 500 ))
	layer:ignoreAnchorPointForPosition(false)
	layer:setAnchorPoint(ccp(0, 1))
	--layer:setTouchEnabled(true, 0, true)
	

	self:addChild(layer)
	self:addChild(text)

end


AdvancedLoggerPad = class(Layer)

function AdvancedLoggerPad:create(datas)
	local layer = AdvancedLoggerPad.new()
	layer:init()
	return layer
end


function AdvancedLoggerPad:init()

	Layer.initLayer(self)
	--local scene = Director:sharedDirector():getRunningScene()
	printx( 1 , "   AdvancedLoggerPad:createLogPad  1")
	self.panelWidth = 600
	self.panelHeight = 600

	local layer = LayerColor:create()
	layer:setOpacity(100)
	layer:setColor((ccc3(255,255,255)))
	layer:setContentSize(CCSizeMake( self.panelWidth, self.panelHeight ))
	layer:setTouchEnabled(true, 0, true)

	local winsize = CCDirector:sharedDirector():getWinSize()
	--scene:addChild(layer) 
	layer:setPosition(ccp((winsize.width-self.panelWidth)/2, (winsize.height-self.panelHeight)/2))

	--[[
	local text = TextField:create("", nil, 16 , CCSizeMake( 600 , 595), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	text:setColor(ccc3(0, 0, 0))
	text:setPosition(ccp(5, 595))
	text:setAnchorPoint(ccp(0, 1))

	text:setString("TestInfo TestInfo TestInfo TestInfo TestInfo TestInfo TestInfo TestInfo TestInfo TestInfo TestInfo TestInfo")
	--text:setText("TestInfoTestInfoTestInfoTestInfoTestInfo")
	--text:setText("TTTTTTTTTTTTTTTTTTTTTTTTTTTT")
	layer:addChild(text)
	]]


	local touchLayer = LayerColor:create()
	touchLayer:setOpacity(0)
	touchLayer:setColor((ccc3(255,255,255)))
	touchLayer:setContentSize(CCSizeMake( self.panelWidth, self.panelHeight))
	--touchLayer:setTouchEnabled(true, 0, true)
	--[[
	kTouchBegin = "touchBegin",
	kTouchEnd = "touchEnd",
	kTouchMove = "touchMove",
	
	kTouchTap = "touchTap",

	kTouchItem = "touchItem",

	kTouchMoveIn	= "touchMoveIn",
	kTouchMoveOut	= "touchMoveOut",
	]]
	--touchLayer:addEventListener(DisplayEvents.kTouchBegin, function (evt) self:onTouchBegin(evt) end )
	--touchLayer:addEventListener(DisplayEvents.kTouchEnd, function (evt) self:onTouchEnd(evt) end )
	--touchLayer:addEventListener(DisplayEvents.kTouchMove, function (evt) self:onTouchMove(evt) end )

	layer:addChild(touchLayer)
	layer.text = text

	self:addChild(layer)
	self.ui = layer

	--self.ui:addChild( AdvancedLoggerPadRender:create() )

	local tabWidth = 500
	local tabHeight = 500

	-- simple clipping
	local clipping = SimpleClippingNode:create()
	clipping:setContentSize(CCSizeMake(tabWidth,tabHeight))
	clipping:setRecalcPosition(true)
    clipping:setAnchorPoint(ccp(0, 1))
    clipping:ignoreAnchorPointForPosition(false)
    clipping:setPosition(ccp(0, tabHeight))

	local layer2 = LayerColor:create()
	layer2:setOpacity(50)
	--layer2:setAnchorPoint(ccp(0, 1))
	layer2:setColor((ccc3(0,0,0)))
	layer2:setContentSize(CCSizeMake( 1000, 1000 ))


	local text2 = TextField:create("", nil, 16 , CCSizeMake( 600 , 500), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	text2:setColor(ccc3(0, 0, 0))
	--text2:setPosition(ccp(5, 595))
	text2:ignoreAnchorPointForPosition(false)
	text2:setAnchorPoint(ccp(0, 0))

	text2:setString("Test Info Test Info\n Test Info Test\n Info Test Info Test Info\n Test Info Test Info Test Info\n Test Info Test Info Test nfo")
	--self.ui:addChild( text2 )

	clipping:addChild(layer2)
	clipping:addChild(text2)

	--[[
    
    ]]

	-- clipping:setPositionX(9)
	-- clipping:setPositionY(-tabHeight-6)
	--clipping:setPositionX(0)
	--clipping:setPositionY(-tabHeight)
	--clipping:setRecalcPosition(true)
	self.ui:addChild(clipping)

	--local tableView = QuickTableView:create( tabWidth,tabHeight, AdvancedLoggerPadRender)
	--tableView:setPositionX(0)
	--tableView:setPositionY(0)
	--clipping:addChild(tableView)
end

function AdvancedLoggerPad:onTouchBegin(evt)
	printx( 1 , "  -------------touchBegin    " ,evt.globalPosition.x , evt.globalPosition.y)
	AdvancedLogger:log( tostring(evt.globalPosition.x) .. "_" ..  tostring(evt.globalPosition.y) )
end

function AdvancedLoggerPad:onTouchEnd(evt)
	printx( 1 , "  -------------touchEnd    " ,evt.globalPosition.x , evt.globalPosition.y)
			--AdvancedLogger:log( evt )
end

function AdvancedLoggerPad:onTouchMove(evt)
	printx( 1 , "  -------------touchMove    " ,evt.globalPosition.x , evt.globalPosition.y)
			--AdvancedLogger:log( evt )
end

function AdvancedLoggerPad:updateText(text)
	printx( 1 , "   AdvancedLoggerPad:updateText  " , text)
	if text then
		self.ui.text:setString(text)
	end
end

--[[
function AdvancedLoggerPad:init(itemlist)
	self.ui = self:buildInterfaceGroup("quickPayConfirmPanel/AdvancedLoggerPad")
    BasePanel.init(self, self.ui)

    if #itemlist == 2 then

    	for k,v in ipairs(itemlist) do
    		self:buildItem( k , v.itemId , v.num )
    	end
    	
    end
end

function AdvancedLoggerPad:buildItem(index , itemId , itemNum)

	local realPropId = ItemType:getRealIdByTimePropId(itemId)
	local itemIcon	= ResourceManager:sharedInstance():buildItemSprite(realPropId)
	local itemSize = itemIcon:getGroupBounds().size

	local iconRect = self.ui:getChildByName("icon_size_"  .. tostring(index))
	local iconSize = iconRect:getGroupBounds().size
	local iconPos = ccp( iconRect:getPositionX() , iconRect:getPositionY() )

	itemIcon:setScaleX( iconSize.width / itemSize.width )
	itemIcon:setScaleY( iconSize.height / itemSize.height )
	itemIcon:setPosition( iconPos ) 
	self.ui:addChild(itemIcon)
	iconRect:removeFromParentAndCleanup(true)

	local label, labelSize = self.ui:getChildByName("labelPrice_" .. tostring(index)), self.ui:getChildByName("labelPrice_size_"  .. tostring(index))
    label = TextField:createWithUIAdjustment(labelSize, label)
    self.ui:addChild(label)
 
    if not self.itemList then self.itemList = {} end
    table.insert( self.itemList , label )

    if index == 1 then
    	label:setString( tostring(itemNum) )
    else
    	label:setString( "x" .. tostring(itemNum) )
    end
    
end
]]

