--------------------------------------------------------------------------------
--卖出物品Panel
--------------------------------------------------------------------------------
require "hecore.display.Director"
require "hecore.ui.LayoutBuilder"
require "hecore.ui.Button"
require "hecore.display.Layer"

local visibleSize = CCDirector:sharedDirector():getVisibleSize()
SellPropPanel = class(Layer)

function SellPropPanel:ctor()
	self.container = nil
end

function SellPropPanel:create( container )
	self.container = container
	local s = SellPropPanel.new()
	s:initLayer()
	return s
end

function SellPropPanel:initLayer()

	SellPropPanel.super.initLayer(self)
    local builder = LayoutBuilder:createWithContentsOfFile("flash/scenes/shop/package_shop.json")
    self.panelUI = builder:build("sell_prop")	

	--关闭
	local function onClosePanel(evt)    
		PopoutManager:sharedInstance():remove(self.container.targetInfoPanel )
        self.container.panelUI:getChildByName("package"):runAction(CCMoveBy:create(0.5, ccp(280, 0)))      
        self.container.packageTableUI:runAction(CCMoveBy:create(0.5, ccp(280, 0)))      
        
        self.container.panelUI:getChildByName("shop"):runAction(CCMoveBy:create(0.5, ccp(-210, 0)))      
        self.container.shopTableUI:runAction(CCMoveBy:create(0.5, ccp(-210, 0)))             
		self.container.targetInfoPanel = nil
	end
	local bt_panel_close = Button:create(self.panelUI:getChildByName("shop_return"))
	bt_panel_close:addEventListener(Events.kStart, onClosePanel)
    self.panelUI:setPosition(ccp(0,-1280))
	self:addChild(self.panelUI)

end
