--------------------------------------------------------------------------------
--背包扩容Panel
--------------------------------------------------------------------------------
require "hecore.display.Director"
require "hecore.ui.LayoutBuilder"
require "hecore.ui.Button"
require "hecore.display.Layer"

BuyPackageCellPanel = class(Layer)

function BuyPackageCellPanel:ctor()
	self.container = nil
end

function BuyPackageCellPanel:create( container )
	self.container = container
	local s = BuyPackageCellPanel.new()
	s:initLayer()
	return s
end

function BuyPackageCellPanel:initLayer()

	BuyPackageCellPanel.super.initLayer(self)
    local builder = LayoutBuilder:createWithContentsOfFile("flash/scenes/shop/package_shop.json")
    self.panelUI = builder:build("buy_package_cell")	
	--关闭
	local function onClosePanel(evt)
		PopoutManager:sharedInstance():remove(self.container.targetInfoPanel,true)
        self.container.panelUI:getChildByName("package"):runAction(CCMoveBy:create(0.5, ccp(280, 0)))      
        self.container.packageTableUI:runAction(CCMoveBy:create(0.5, ccp(280, 0)))      
        self.container.panelUI:getChildByName("shop"):runAction(CCMoveBy:create(0.5, ccp(-210, 0)))      
        self.container.shopTableUI:runAction(CCMoveBy:create(0.5, ccp(-210, 0)))             
		self.container.targetInfoPanel = nil
	end
	local bt_panel_close = Button:create(self.panelUI:getChildByName("shop_return"))
	bt_panel_close:addEventListener(Events.kStart, onClosePanel)
    if _G.isLocalDevelopMode then printx(0, self.panelUI:getPosition().x,self.panelUI:getPosition().y) end
    self.panelUI:setPosition(ccp(0,-1280))
	self:addChild(self.panelUI)

end
