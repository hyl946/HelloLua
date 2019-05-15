require 'zoo.panel.payConfirm.QuickPayConfirmUnitWithOneGift'

QuickPayConfirmBasePanel = class(BasePanel)


function QuickPayConfirmBasePanel:create(itemlist, totalPrice, payType , confirmCallback , cancelCallback)
	local panel = QuickPayConfirmBasePanel.new()
	panel:loadRequiredResource("ui/ali_payment.json")
	panel:init( itemlist, totalPrice, payType , confirmCallback , cancelCallback)
	return panel
end



function QuickPayConfirmBasePanel:init(itemlist, totalPrice, payType , confirmCallback , cancelCallback)
	self.ui = self:buildInterfaceGroup("quickPayConfirmPanel/QuickPayConfirmContainner")
    BasePanel.init(self, self.ui)

    self.confirmCallback = confirmCallback
    self.cancelCallback = cancelCallback

    self.confirmBtn = GroupButtonBase:create(self.ui:getChildByName("btnOK"))
    self.confirmBtn:setString(Localization:getInstance():getText("确定"))
    self.confirmBtn:addEventListener(DisplayEvents.kTouchTap, function ()
        self:onConfirmed()
    end)

    self.closeBtn = self.ui:getChildByName("btnClose")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function() 
            self:onClosed()
        end)

    self.panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
    self.ui:addChild(self.panelTitle)

    local price = tostring(math.floor( totalPrice / 100 )) .. ".00"

    if payType == Payments.WECHAT then
    	self.panelTitle:setString(Localization:getInstance():getText("wechat.kf.pay2.wc"))
    	self.ui:getChildByName("tip_price"):setString(localize("wechat.kf.pay2.text")..":¥"..price)
    else
    	self.panelTitle:setString(Localization:getInstance():getText("alipay.pay.kf.confirm1"))
    	self.ui:getChildByName("tip_price"):setString(localize("alipay.pay.kf.confirm")..":¥"..price)
    end

    self.itemUnitRect = self.ui:getChildByName("unit_rect_1")
    self.itemUnitRectSize = self.itemUnitRect:getGroupBounds().size
    self.itemUnitRectPos = ccp( self.itemUnitRect:getPositionX() , self.itemUnitRect:getPositionY() )

    if not itemlist then itemlist = {} end
    self.itemUnit = self:buildItemUnit( itemlist )
    self.itemUnit:setPosition( self.itemUnitRectPos )
    self.ui:addChild( self.itemUnit )  

    self.itemUnitRect:removeFromParentAndCleanup(true)
end

function QuickPayConfirmBasePanel:buildItemUnit( itemlist )

	local unit = nil

	if #itemlist == 2 then
		unit = QuickPayConfirmUnitWithOneGift:create( itemlist )
	else
		unit = QuickPayConfirmUnitWithMultiGifts:create( itemlist )
	end
	
	return unit
end

function QuickPayConfirmBasePanel:onConfirmed()
	if self.confirmCallback then
        self.confirmCallback()
    end
    self:removeSelf()
end

function QuickPayConfirmBasePanel:onClosed()
	if self.cancelCallback then
        self.cancelCallback()
    end
    self:removeSelf()
end

function QuickPayConfirmBasePanel:popout()
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():add(self, true, false)
end

function QuickPayConfirmBasePanel:removeSelf()
    PopoutManager:sharedInstance():remove(self, true)
end

return QuickPayConfirmBasePanel