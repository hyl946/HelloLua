QuickPayConfirmUnitWithOneGift = class(BasePanel)


function QuickPayConfirmUnitWithOneGift:create(itemlist)
	local panel = QuickPayConfirmUnitWithOneGift.new()
	panel:loadRequiredResource("ui/ali_payment.json")
	panel:init( itemlist )
	return panel
end



function QuickPayConfirmUnitWithOneGift:init(itemlist)
	self.ui = self:buildInterfaceGroup("quickPayConfirmPanel/QuickPayConfirmUnitWithOneGift")
    BasePanel.init(self, self.ui)

    if #itemlist == 2 then

    	for k,v in ipairs(itemlist) do
    		self:buildItem( k , v.itemId , v.num )
    	end
    	
    end
end

function QuickPayConfirmUnitWithOneGift:buildItem(index , itemId , itemNum)

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